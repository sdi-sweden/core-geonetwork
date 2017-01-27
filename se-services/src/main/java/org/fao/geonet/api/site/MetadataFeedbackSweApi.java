/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

package org.fao.geonet.api.site;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;

import javax.servlet.ServletRequest;

import org.fao.geonet.api.API;
import org.fao.geonet.api.tools.i18n.LanguageUtils;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.util.MetadataFeedbackSweMailUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;

@EnableWebMvc
@Service
@RequestMapping(value = {
    "/api/metadata",
    "/api/" + API.VERSION_0_1 +
        "/metadata"
})
@Api(value = "metadata",
    tags = "metadata",
    description = "Metadata Feedback")
/**
 * API for sending feedback email for Metadata.
 *
 * @author Jitendra Patil
 */
public class MetadataFeedbackSweApi {

    @Autowired
    SettingManager settingManager;

    @Autowired
    LanguageUtils languageUtils;

    private static final String EMPTY_STRING = "";
    private static final String BLANK_SPACE = " ";
    private static final String SEMI_COLON = ";";
    private static final String COMMA = ",";
    private static final String MAIL_LINE_SEPARATOR_HTML = "<br />";
    private static final String MISSING_FORM_VALUE = "Ej angivet";
    private static final String MAIL_BODY_HEADER_TEMPLATE = "********* %s ************";
    private static final String MAIL_BODY_FOOTER = "*****************************************";
    private static final String MAIL_CONTACT_HEADER = " Contact Information ";
    private static final String MAIL_CONTACT_NAME_PREFIX = "Name: ";
    private static final String MAIL_CONTACT_EMAIL_PREFIX = "E-mail: ";
    private static final String MAIL_CONTACT_ORG_PREFIX = "Organisation: ";
    private static final String MAIL_COMMENTS_HEADER = "Comments:";
    private static final String METADATA_MAIL_SUCCESS_MSG = "metadataEmailSuccessMsg";
    private static final String METADATA_MAIL_ERROR_MSG = "metadataEmailErrorMsg";
    private static final String ADDITIONAL_EMAILID_LIST = "additionalEmailIdList";
    private static final String METADATA_MAIL_SUBJECT = "metadataEmailSubject";
    
    private static final String TO_EMAILID_LIST = "toEmailIdList";
    private static final String EMAIL_SUBJECT = "emailSubject";
    private static final String EMAIL_BODY = "emailBody";
    private static final String SETTING_MANAGER = "settingManager";
    
    @ApiOperation(value = "Send metadata feedback email",
        nickname = "sendFeedback")
    @RequestMapping(
        value = "/feedback-swe",
        method = RequestMethod.POST,
        produces = MediaType.TEXT_PLAIN_VALUE)
    @ResponseStatus(value = HttpStatus.OK)
    @ResponseBody
    public ResponseEntity<String> sendFeedback(
        @ApiParam(value = "Name of the user sending the feedback",
            required = true)
        @RequestParam
            String name,
        @ApiParam(value = "Organisation of the user sending the feedback",
            required = false)
        @RequestParam (required = false)
            String org,
        @ApiParam(value = "Email of the user sending the feedback",
            required = true)
        @RequestParam
            String email,
        @ApiParam(value = "Comments for the email",
            required = true)
        @RequestParam
            String comments,
        @ApiParam(value = "Title of the metadata",
            required = false)
        @RequestParam
            String metadataTitle,
        @ApiParam(value = "semicolon seperated metadata Address. Can be more than 1",
            required = true)
        @RequestParam
            String metadataToAddress,
        ServletRequest request)
        throws Exception {
    	
        //Locale locale = languageUtils.parseAcceptLanguage(request.getLocales());
    	Locale swedishLocale = new Locale("sv", "SE");
        ResourceBundle messages = ResourceBundle.getBundle("org.fao.geonet.api.SeMessages", swedishLocale);

       // Compute all params here: start
       // Few hard coding here
        Map<String, Object> pTransferObj = new HashMap<String, Object>();
        pTransferObj.put(SETTING_MANAGER, this.settingManager);
        
        String  metadataEmailSubject = messages.getString(METADATA_MAIL_SUBJECT);
        
        String additionalEmailIdList = messages.getString(ADDITIONAL_EMAILID_LIST);
        
        String mailToAddress = EMPTY_STRING;
        if(metadataToAddress != null && !metadataToAddress.equalsIgnoreCase(EMPTY_STRING)) {
        	String[] metadataToAddressArr = metadataToAddress.split(SEMI_COLON);        	
        	for(int i=0; i< metadataToAddressArr.length; i++) {
        		if(!metadataToAddressArr[i].trim().equalsIgnoreCase(EMPTY_STRING)) {
        			mailToAddress += metadataToAddressArr[i].trim() + COMMA;
        		}
        	}
        }
        mailToAddress += additionalEmailIdList; // 1. To whom should email be send
        List<String> toEmailIdList = Arrays.asList(mailToAddress.split(COMMA));
        pTransferObj.put(TO_EMAILID_LIST, toEmailIdList);
        
        metadataEmailSubject += BLANK_SPACE + metadataTitle.trim(); // 2. Email subject
        pTransferObj.put(EMAIL_SUBJECT, metadataEmailSubject);
        
        String lineSeparator = MAIL_LINE_SEPARATOR_HTML;
        StringBuilder mailBodyBuf = new StringBuilder(); // 3. Email body
        String mailBodyHeader = String.format(MAIL_BODY_HEADER_TEMPLATE, MAIL_CONTACT_HEADER);
        mailBodyBuf.append(mailBodyHeader);
        mailBodyBuf.append(lineSeparator);
        
        // name
        mailBodyBuf.append(MAIL_CONTACT_NAME_PREFIX);
        if(name == null || name.trim().length() <= 0) {
        	mailBodyBuf.append(MISSING_FORM_VALUE);        	
        } else {
        	mailBodyBuf.append(name.trim());	
        }
        mailBodyBuf.append(lineSeparator);
        
        // email
        mailBodyBuf.append(MAIL_CONTACT_EMAIL_PREFIX);
        if(email == null || email.trim().length() <= 0) {
        	mailBodyBuf.append(MISSING_FORM_VALUE);
        } else {
        	mailBodyBuf.append(email.trim());      	
        }
        mailBodyBuf.append(lineSeparator);
        
        // org
        mailBodyBuf.append(MAIL_CONTACT_ORG_PREFIX);
        if(org == null || org.trim().length() <= 0) {
        	mailBodyBuf.append(MISSING_FORM_VALUE);
        } else {
        	mailBodyBuf.append(org.trim());        	
        }
        mailBodyBuf.append(lineSeparator);
        
        // end of contact info
        mailBodyBuf.append(lineSeparator);
        
        // comments
        mailBodyBuf.append(MAIL_COMMENTS_HEADER);
        mailBodyBuf.append(lineSeparator);
        if(comments == null || comments.trim().length() <= 0) {
        	mailBodyBuf.append(MISSING_FORM_VALUE);       	
        } else {
        	mailBodyBuf.append(comments.trim());
        }
        mailBodyBuf.append(lineSeparator);
        // end of comments
        mailBodyBuf.append(lineSeparator);

        mailBodyBuf.append(MAIL_BODY_FOOTER);
        mailBodyBuf.append(lineSeparator);
        
        pTransferObj.put(EMAIL_BODY, mailBodyBuf.toString());
        // Compute all params here: end
        
       
       boolean mailSendOk = MetadataFeedbackSweMailUtil.sendHtmlEmail(pTransferObj);

        if (mailSendOk) {
        	String metadataEmailSuccessMsg = messages.getString(METADATA_MAIL_SUCCESS_MSG);
        	metadataEmailSuccessMsg = "<font color='#32cd32'>" + metadataEmailSuccessMsg + "</font>";
            return new ResponseEntity<>(metadataEmailSuccessMsg, HttpStatus.OK);

        } else {
            String metadataEmailErrorMsg = messages.getString(METADATA_MAIL_ERROR_MSG);
        	metadataEmailErrorMsg = "<font color='#FF0000'>" + metadataEmailErrorMsg + "</font>";
            return new ResponseEntity<>(metadataEmailErrorMsg, HttpStatus.OK);
        }
    }
}
