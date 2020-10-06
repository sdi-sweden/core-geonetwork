package org.fao.geonet.utils;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.LineIterator;
import org.apache.commons.lang.StringUtils;
import org.junit.Ignore;
import org.junit.Test;

public class ValidationLogFileParser {

//	@Test
	@Ignore
	public void parseLogFile() throws IOException {

	    String path = "C:\\tmp\\PROD_Metadata_validation_20200930.log";
	    File theFile = FileUtils.getFile(path);
	    File summaryFile = FileUtils.getFile("C:\\tmp\\metadata_validation_summary.log");
	    
	    LineIterator it = FileUtils.lineIterator(theFile, "UTF-8");
	    Integer lineCount = 0;
	    Integer errorCount = 0;
	    boolean findErrorMsg = false;
	    try {
	        while (it.hasNext()) {
	            String line = it.nextLine();
	            lineCount++;
	            boolean svf = isValidation(line);
	            if (svf) {
	            	errorCount++;
	            	String metadataID = getMetadataIDFromLine(line);
	            	addToSummary(summaryFile, "Found Validation Failure for " + metadataID);
	            	findErrorMsg = true;	            	
	            }
	            if (findErrorMsg) {
	            	if (lineContainsErrorMsg(line)) {
	            		printErrorMsg(summaryFile, line);
	            	}
	            }
	            if (endOfErrorMsgsForRecord(line)) {
	            	findErrorMsg = false;
	            	addToSummary(summaryFile, "");
	            }
	        }
	    } finally {
	        LineIterator.closeQuietly(it);
	    }
	    addToSummary(summaryFile, "Line Count = " + lineCount);
	    addToSummary(summaryFile, "XSD Validation Failure count = " + errorCount);
	    
	}

private void addToSummary(File out, String string) throws IOException {
    	FileUtils.writeStringToFile(out, string + "\r\n", StandardCharsets.UTF_8, true);
	}

private boolean endOfErrorMsgsForRecord(String line) {
	if (StringUtils.contains(line, "</gmd:MD_Metadata>")) {
		return true;
	}
	return false;	}

private void printErrorMsg(File summaryFile, String line) throws IOException {

	String msg = StringUtils.substringBetween(line, "geonet:xsderror=\"", ">");
	addToSummary(summaryFile, msg);
}

private boolean lineContainsErrorMsg(String line) {
	if(StringUtils.contains(line, "geonet:xsderror=")) {
    	return true;
    }
	return false;
}

private String getMetadataIDFromLine(String line) {
    Integer idStartPos = StringUtils.indexOf(line, " (");
    Integer idEndPos = StringUtils.indexOf(line, ") b");
    return StringUtils.substring(line, idStartPos+2, idEndPos);
}

private boolean isValidation(String line) {
    if (line.contains("- Metadata (")) {
    	return true;
    }
	return false;	 
}

}
