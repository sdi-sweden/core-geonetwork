<%-- 
/**
 * Copyright © Lantmäteriet
 *    
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *    
 *    http://www.apache.org/licenses/LICENSE-2.0
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
*/
 --%>
<%@page isErrorPage="true" import="java.io.*" %>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@page import="javax.servlet.jsp.ErrorData"%>
<%@page import="java.lang.StringBuilder"%>
<%@page import="org.apache.commons.logging.Log"%>
<%@page import="org.apache.commons.logging.LogFactory"%>
<%@page import="org.lmv.geodata.common.server.HttpStatus" %>
<%@page import="org.lmv.geodata.common.server.security.owasp.encoder.spec.*" %>
<%
    Log log = LogFactory.getLog("exceptionHandler.jsp");
    
    StringBuilder sbPageTitle = new StringBuilder();
    sbPageTitle.append("Error report ");
    
    boolean handled = false; // Set to true after handling the error
    ErrorData ed = null;
    
    // Get the PageContext
    if(pageContext != null) 
    {
    
        // Get the ErrorData
        try 
        {
            ed = pageContext.getErrorData();
        } 
        catch(NullPointerException ne) {
            // If the error page was accessed directly, a NullPointerException
            // is thrown at (PageContext.java:514).
            // Catch and ignore it... it effectively means we can't use the ErrorData
        }
    
        // Display error details for the user
        if(ed != null) 
        {
            int errorCode = ed.getStatusCode();
            if(errorCode > 0)
            {
                sbPageTitle.append(" - ");
                sbPageTitle.append(errorCode);
                sbPageTitle.append(" ");
                sbPageTitle.append(HttpStatus.getStatusText(errorCode));                
            }
                
        }
    }
%>
<%-- 
References:
http://wiki.metawerx.net/wiki/CustomErrorPagesInTomcat
http://wiki.metawerx.net/wiki/Web.xml.ErrorPage
http://www.stardeveloper.com/articles/display.html?article=2001072401&page=1
--%>
<!--
Unless this text is here, if your page is less than 513 bytes, Internet Explorer will display it's "Friendly HTTP Error Message",
and your custom error will never be displayed.  This text is just used as filler.
This is a useless buffer to fill the page to 513 bytes to avoid display of Friendly Error Pages in Internet Explorer
This is a useless buffer to fill the page to 513 bytes to avoid display of Friendly Error Pages in Internet Explorer
This is a useless buffer to fill the page to 513 bytes to avoid display of Friendly Error Pages in Internet Explorer
-->
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>  
    <head>
        <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
        <title><%=sbPageTitle.toString() %></title>
    </head>
    <body>
        <h2><%=sbPageTitle.toString() %></h2>
        <div class="errorInfo" >
        <%
            IEncoder encoder = EncoderUtil.getEncoder(pageContext.getServletContext());
            
            // Display error details for the user
            if(ed != null) 
            {
                // Check if we got an error message, e.g. if we used response.sendError(errorCode, "Error message").
                String errorInfo = (String)request.getAttribute("javax.servlet.error.message");
                /*
                if(errorInfo != null)
                {
                    // FIXME Hack to not display error info containing stacktrace
                    if(encoder != null && errorInfo.indexOf("Stacktrace") < 0)
                    {
                        String cleanedErrorInfo = encoder.encodeForHTML(errorInfo);
                        out.println("<p>Info: " + cleanedErrorInfo + "</p>");
                    }
                }
                */
                // Output details about the HTTP error
                // (this should show error msg, e.g. 404 Not Found, and the name of the missing page)
                int errorCode = ed.getStatusCode();
                String errorMsg = "ErrorCode: " + Integer.toString(errorCode);
                if(errorCode > 0)
                    errorMsg += " " + HttpStatus.getStatusText(errorCode);
                out.println("<br />" + errorMsg);
                if(encoder != null && ed.getRequestURI() != null)
                {
                    String cleanedURI = encoder.encodeForHTML(ed.getRequestURI());
                    
                    out.println("<br />URL: " + cleanedURI);
                }
                
                Throwable theThrowable = ed.getThrowable();
                if(theThrowable != null)
                {
                    // Log the uncaught exception
                    StringBuilder builder = new StringBuilder();
                    builder.append(errorMsg);
                    builder.append(". ");
                    builder.append("Unhandled exception. ");
                    builder.append(errorMsg);
                    builder.append(" URL: ");
                    builder.append(ed.getRequestURI());
                    builder.append(" Servlet: ");
                    builder.append(ed.getServletName());
                    log.error(builder.toString(), theThrowable);
                }
                else if(errorInfo != null)
                {
                    // Log the error info
                    StringBuilder builder = new StringBuilder();
                    builder.append(errorMsg);
                    builder.append(". ");
                    builder.append("Error info: ");
                    builder.append(errorInfo);
                    builder.append(" URL: ");
                    builder.append(ed.getRequestURI());
                    builder.append(" Servlet: ");
                    builder.append(ed.getServletName());
                    log.error(builder.toString());
                    
                }
                
                // Error handled successfully, set a flag
                handled = true;
            }
            
            // Check if the error was handled
            if(!handled) {
            %>
                <p>No information about this error was available.</p>
            <%
            }
        %>  
        </div>
    </body>
</html>
