package org.fao.geonet.api.records;

import java.util.Iterator;

import org.apache.commons.lang.StringUtils;
import org.fao.geonet.exceptions.SchematronValidationErrorEx;
import org.fao.geonet.exceptions.XSDValidationErrorEx;
import org.jdom.Element;
import org.jdom.output.XMLOutputter;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.XML;


/**
 *
 * This exception wraps a JSON report with validation errors
 * Can be extended to support all possible exceptions and xml formats
 * The JSON format is
 * [{xpath:"element in error", message:"Error description"},...]
 *
 */
public class ValidationErrorsException extends Exception {

    private String message = "";


    public ValidationErrorsException(XSDValidationErrorEx e) {
        JSONObject xmlJSONObj;
        try {
            xmlJSONObj = XML.toJSONObject(e.getMessage());

            String errorList = null;
            if(xmlJSONObj.get("xsderrors")!=null) {
                if (xmlJSONObj.get("xsderrors") instanceof JSONArray) {
                    JSONArray xsderrors = (JSONArray)xmlJSONObj.get("xsderrors");
                    for (int index = 0; index <  xsderrors.length() ; index++) {
                        JSONObject xsdError = xsderrors.getJSONObject(index);
                        if(((JSONObject) xsdError).get("error")  instanceof JSONArray) {
                            errorList += ((JSONArray)((JSONObject) xsdError).get("error")).toString();
                        } else {
                            errorList += ((JSONObject)((JSONObject) xsdError).get("error")).toString();
                        }
                    }
                } else if (xmlJSONObj.get("xsderrors") instanceof JSONObject) {
                    JSONObject xsderrors = (JSONObject)xmlJSONObj.get("xsderrors");
                    if(((JSONObject) xsderrors).get("error")  instanceof JSONArray) {
                        errorList = ((JSONArray) xsderrors.get("error")).toString();
                    } else {
                        errorList = ((JSONObject) xsderrors.get("error")).toString();
                    }
                } else {
                    errorList = "";
                }
            }

            // JSON structure not supported
            if(errorList.equals("")) {
                this.message = xmlJSONObj.toString();
            } else {
                this.message = errorList;
            }

        } catch (Exception e1) {
            this.message = e.getMessage();
        }

    }


    public ValidationErrorsException(SchematronValidationErrorEx e) {

        JSONObject xmlJSONObj;
        try {
            Element report = (Element) e.getObject();
            XMLOutputter outp = new XMLOutputter();
            xmlJSONObj = XML.toJSONObject(outp.outputString(report));

            JSONArray convertedReport = new JSONArray();

            JSONArray validationRules = (JSONArray) ((JSONObject) xmlJSONObj.get("geonet:schematronerrors")).get("geonet:report");
            for (int i = 0; i < validationRules.length(); i ++) {
                JSONObject reportV = new JSONObject();
                convertReport(validationRules.getJSONObject(i), reportV);

                if (reportV.getJSONArray("errorList").length() > 0) {
                    convertedReport.put(reportV);
                }
            }
            String errorList = convertedReport.toString();

            // JSON structure not supported
            if(errorList.equals("")) {
                this.message = xmlJSONObj.toString();
            } else {
                this.message = errorList;
            }

        } catch (Exception e1) {
            this.message = e.getMessage();
        }

    }

    private void convertReport(Object object, JSONObject report) throws JSONException {
        JSONArray errorList = new JSONArray();

        // Check if current node is a JsonObject or a JsonArray
        // then apply the correct logic
        if (object instanceof JSONObject) {
            JSONObject json = (JSONObject) object;

            if (StringUtils.isNotEmpty(((JSONObject) object).getString("geonet:rule"))) {
                boolean process = hasKey(json, "svrl:schematron-output");

                if (process) {
                    JSONObject schematronOutput = (JSONObject) json.get("svrl:schematron-output");

                    String schematronTitle = schematronOutput.getString("title");
                    report.put("title", schematronTitle);

                    boolean processFailedRules = hasKey(schematronOutput, "svrl:failed-assert");;

                    if (processFailedRules) {
                        if (schematronOutput.get("svrl:failed-assert") instanceof JSONObject) {
                            JSONObject current = (JSONObject) schematronOutput.get("svrl:failed-assert");

                            JSONObject reportElement = new JSONObject();
                            //reportElement.put("xpath", current.get("location"));
                            reportElement.put("message", current.get("svrl:text"));
                            errorList.put(reportElement);

                        } else if (schematronOutput.get("svrl:failed-assert") instanceof JSONArray) {
                            JSONArray failedRules = (JSONArray) schematronOutput.get("svrl:failed-assert");

                            for (int j = 0; j < failedRules.length(); j++) {
                                JSONObject current = failedRules.getJSONObject(j);
                                JSONObject reportElement = new JSONObject();
                                //reportElement.put("xpath", current.get("location"));
                                reportElement.put("message", current.get("svrl:text"));
                                errorList.put(reportElement);

                            }
                        }
                    }
                }
            }
        }

        report.put("errorList", errorList);
    }


    private boolean hasKey(JSONObject obj, String key) {
        Iterator it = obj.keys();
        boolean hasKey = false;
        while (it.hasNext() && !hasKey) {
            hasKey = ((String) it.next()).equalsIgnoreCase(key);
        }

        return hasKey;
    }

    @Override
    public String getMessage() {

        return this.message.trim();

    }

}
