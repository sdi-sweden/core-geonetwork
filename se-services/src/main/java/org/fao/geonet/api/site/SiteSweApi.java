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

package site;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.api.API;
import org.fao.geonet.api.tools.i18n.LanguageUtils;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.util.MailUtil;
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

import javax.servlet.ServletRequest;
import java.util.Locale;
import java.util.ResourceBundle;

@EnableWebMvc
@Service
@RequestMapping(value = {
    "/api/site",
    "/api/" + API.VERSION_0_1 +
        "/site"
})
@Api(value = "site",
    tags = "site",
    description = "Site SWE related operations")
/**
 * API for site related operations.
 *
 * @author Jose García
 */
public class SiteSweApi {

    @Autowired
    SettingManager settingManager;

    @Autowired
    LanguageUtils languageUtils;

    @ApiOperation(value = "Sent site feedback mails",
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
            String username,
        @ApiParam(value = "Organisation of the user sending the feedback",
            required = false)
        @RequestParam (required = false)
            String organisation,
        @ApiParam(value = "Mail of the user sending the feedback",
            required = true)
        @RequestParam
            String email,
        @ApiParam(value = "Comments for the mail",
            required = true)
        @RequestParam
            String comments,
        ServletRequest request)
        throws Exception {

        Locale locale = languageUtils.parseAcceptLanguage(request.getLocales());
        ResourceBundle messages = ResourceBundle.getBundle("org.fao.geonet.api.SeMessages", locale);

        String fromDescr = username;

        if (StringUtils.isNotEmpty(organisation)) {
            fromDescr += " (" + organisation + ")";
        }
        boolean mailSendOk =
            MailUtil.sendMailToAdmin(email, fromDescr, "Feedback",  comments, this.settingManager);

        if (mailSendOk) {
            return new ResponseEntity<>(messages.getString("feedback_mail_ok"), HttpStatus.OK);

        } else {
            return new ResponseEntity<>(messages.getString("feedback_mail_error"), HttpStatus.PRECONDITION_FAILED);
        }
    }
}
