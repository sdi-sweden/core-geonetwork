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

package org.fao.geonet.util;

import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.mail.Session;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.mail.DefaultAuthenticator;
import org.apache.commons.mail.Email;
import org.apache.commons.mail.EmailException;
import org.apache.commons.mail.HtmlEmail;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.setting.Settings;
import org.fao.geonet.utils.Log;

/**
 * Utility class to send mails. Supports both html and plain text. It usually
 * takes the settings from the database, but you can also indicate all params.
 *
 * @author Jitendra. P. Patil
 */
public class MetadataFeedbackSweMailUtil {

    public static final String LOG_MODULE_NAME = "geonetwork";
    
    private static final String TO_EMAILID_LIST = "toEmailIdList";
    private static final String EMAIL_SUBJECT = "emailSubject";
    private static final String EMAIL_BODY = "emailBody";
    private static final String SETTING_MANAGER = "settingManager";
    private static final String FROM = "from";
    private static final String EMPTY_STRING = "";
    private static final String MAIL_SMTP_SSL_TRUST = "mail.smtp.ssl.trust";
    private static final String STAR = "*";
    
    /**
     * Send an html mail. Will use transfer object to read all email related parameters.
     *
     * @param pTransferObj
     */
	public static boolean sendHtmlEmail(Map<String, Object> pTransferObj) {
		boolean isSuccess = false;
		HtmlEmail email = new HtmlEmail();
		configureBasics(pTransferObj, email);

		// Setting email subject
		String emailSubject = (String) pTransferObj.get(EMAIL_SUBJECT);
		email.setSubject(emailSubject);

		// Setting email body
		try {
			String emailBody = (String) pTransferObj.get(EMAIL_BODY);
			email.setHtmlMsg(emailBody);
		} catch (EmailException e1) {
			Log.error("Error setting email HTML content. Subject:" + emailSubject, e1);
			return false;
		}

		// Setting recipients
		@SuppressWarnings("unchecked")
		List<String> toEmailIdList = (List<String>) pTransferObj.get(TO_EMAILID_LIST);
		for (String recipeint : toEmailIdList) {
			try {
				email.addTo(recipeint); // Should it be bcc?
			} catch (EmailException e) {
				Log.error(LOG_MODULE_NAME, "Error setting email BCC address " + recipeint, e);
				return false;
			}
		}
		isSuccess = send(email);
		
		return isSuccess;
	}

    private static Boolean send(final Email email) {
        try {
            email.send();
        } catch (EmailException e) {
            Log.error(LOG_MODULE_NAME, "Error sending email \"" + email.getSubject() + "\"", e);
            return false;
        }

        return true;
    }

    /**
     * Create data information to compose the mail
     *
     * @param hostName
     * @param smtpPort
     * @param from
     * @param username
     * @param password
     * @param email
     * @param ssl
     * @param tls
     * @param ignoreSslCertificateErrors
     */
    private static void configureBasics(String hostName, Integer smtpPort,
                                        String from, String username, String password, Email email, Boolean ssl,
                                        Boolean tls, Boolean ignoreSslCertificateErrors) {
        if (hostName != null) {
            email.setHostName(hostName);
        } else {
            throw new IllegalArgumentException(
                "Missing settings in System Configuration (see Administration menu) - cannot send mail");
        }
        if (StringUtils.isNotBlank(smtpPort + "")) {
            email.setSmtpPort(smtpPort);
        } else {
            throw new IllegalArgumentException(
                "Missing settings in System Configuration (see Administration menu) - cannot send mail");
        }
        if (username != null) {
            email.setAuthenticator(new DefaultAuthenticator(username, password));
        }

        email.setDebug(true);

        if (tls != null && tls) {
            email.setStartTLSEnabled(tls);
            email.setStartTLSRequired(tls);
        }

        if (ssl != null && ssl) {
            email.setSSLOnConnect(ssl);
            if (StringUtils.isNotBlank(smtpPort + "")) {
                email.setSslSmtpPort(smtpPort + "");
            }
        }

        if (ignoreSslCertificateErrors != null && ignoreSslCertificateErrors) {
            try {
                Session mailSession = email.getMailSession();
                Properties p = mailSession.getProperties();
                p.setProperty(MAIL_SMTP_SSL_TRUST, STAR); // "mail.smtp.ssl.trust" = "*"

            } catch (EmailException e) {
                // Ignore the exception. Can't be reached because the host name is always set above or an
                // IllegalArgumentException is thrown.
            }
        }

        if (StringUtils.isNotBlank(from)) {
            try {
                email.setFrom(from);
            } catch (EmailException e) {
                throw new IllegalArgumentException(
                    "Invalid 'from' email setting in System Configuration (see Administration menu) - cannot send " +
                        "mail", e);
            }
        } else {
            throw new IllegalArgumentException(
                "Missing settings in System Configuration (see Administration menu) - cannot send mail");
        }
    }

    /**
     * Configure the basics (hostname, port, username, password,...)
     *
     * @param pTransferObject
     * @param email
     */
    private static void configureBasics(Map<String, Object> pTransferObject, Email email) {
    	SettingManager settingManager = (SettingManager) pTransferObject.get(SETTING_MANAGER);
    	
    	// Core attributes for email transport: start
        String username = settingManager.getValue(Settings.SYSTEM_FEEDBACK_MAILSERVER_USERNAME);
        String password = settingManager.getValue(Settings.SYSTEM_FEEDBACK_MAILSERVER_PASSWORD);
        Boolean ssl = settingManager.getValueAsBool(Settings.SYSTEM_FEEDBACK_MAILSERVER_SSL, false);
        Boolean tls = settingManager.getValueAsBool(Settings.SYSTEM_FEEDBACK_MAILSERVER_TLS, false);
        String hostName = settingManager.getValue(Settings.SYSTEM_FEEDBACK_MAILSERVER_HOST);
        Integer smtpPort = Integer.valueOf(settingManager.getValue(Settings.SYSTEM_FEEDBACK_MAILSERVER_PORT));
        Boolean ignoreSslCertificateErrors = settingManager.getValueAsBool(Settings.SYSTEM_FEEDBACK_MAILSERVER_IGNORE_SSL_CERTIFICATE_ERRORS, false);
    	// Core attributes for email transport: end
        
        String from = (String) pTransferObject.get(FROM);
        if(from == null || from.trim().equalsIgnoreCase(EMPTY_STRING)) {
        	from = settingManager.getValue(Settings.SYSTEM_FEEDBACK_EMAIL);
        }
        configureBasics(hostName, smtpPort, from, username, password, email, ssl, tls, ignoreSslCertificateErrors);
    }
    
}
