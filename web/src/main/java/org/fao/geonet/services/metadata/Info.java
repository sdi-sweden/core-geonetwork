package org.fao.geonet.services.metadata;

import java.sql.SQLException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;

import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.exceptions.MetadataNotFoundEx;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.services.Utils;
import org.jdom.Element;

public class Info implements Service {

	private static final boolean showOnlyCurrentStatus = true;

	private static final Set<String> allowedProfiles;

	static {
		allowedProfiles = new HashSet<String>();
		allowedProfiles.add(Geonet.Profile.ADMINISTRATOR);
	}

	@Override
	public void init(String appPath, ServiceConfig params) throws Exception {}

	@Override
	public Element exec(Element params, ServiceContext context)
			throws Exception {

		// checkAccess(context);

		GeonetContext gc = (GeonetContext) context
				.getHandlerContext(Geonet.CONTEXT_NAME);
		DataManager dataMan = gc.getDataManager();

		Dbms dbms = (Dbms) context.getResourceManager()
				.open(Geonet.Res.MAIN_DB);

		String id = Utils.getIdentifierFromParameters(params, context);

		int iLocalId = -1;

		try{
			iLocalId = Integer.parseInt(id);
		}
		catch(Exception e){
			throw new MetadataNotFoundEx(id);
		}

		Element mdInfo = getMdInfo(iLocalId, dataMan, dbms);

		if(mdInfo == null){
			throw new MetadataNotFoundEx(id);
		}

		Element resp = new Element("response");

		resp.addContent(mdInfo);

		Element status = getStatus(iLocalId, dataMan, dbms);
		resp.addContent(status);

		String ownerIdStr = mdInfo.getChildText("owner");
		if (ownerIdStr != null) {
			int ownerId = Integer.parseInt(ownerIdStr);

			String myProfile = context.getUserSession().getProfile();

			Element owner = getOwner(ownerId, myProfile, dataMan, dbms);
			resp.addContent(owner);
		}

		GetAdminOper getAdminOper = new GetAdminOper();
		Element oper = getAdminOper.exec(params, context);
		oper.setName("privileges");
		resp.addContent(oper);

		return resp;
	}

	private Element getOwner(int id, String sessProfile, DataManager dataMan, Dbms dbms)
			throws Exception {

		Element elUser = dbms.select("SELECT * FROM Users WHERE id=?", id);

		Element rec = elUser.getChild("record");

		if (rec != null) {
			rec.setName("owner");
			rec = (Element) rec.detach();

			String userProfile = rec.getChildText("profile");

			Element groups = getGroups(id, sessProfile, userProfile, dbms);
			rec.addContent(groups);
		} else {
			rec = new Element("owner");
		}

		return rec;
	}

	private Element getGroups(int id, String sessProfile, String userProfile, Dbms dbms) throws SQLException {

		Element elGroups = new Element(Geonet.Elem.GROUPS);

		Element theGroups;

//		if (sessProfile.equals(Geonet.Profile.ADMINISTRATOR) && (userProfile.equals(Geonet.Profile.ADMINISTRATOR))) {
//			theGroups = dbms.select("SELECT id, name, description FROM Groups");
//		} else {
			theGroups = dbms.select("SELECT id, name, description, profile FROM UserGroups, Groups WHERE groupId=id AND userId=?",id);
//		}

		@SuppressWarnings("unchecked")
		List<Element> list = theGroups.getChildren();
		for (Element group : list) {
			group.setName("group");
			elGroups.addContent((Element)group.clone());
		}

		return elGroups;
	}

	private Element getMdInfo(int id, DataManager dataMan, Dbms dbms)
			throws Exception {
		String query = "SELECT id, uuid, schemaId, isTemplate, isHarvested, createDate, "
				+ "       changeDate, source, title, root, owner, groupOwner, displayOrder "
				+ "FROM   Metadata " + "WHERE id=?";

		@SuppressWarnings("rawtypes")
		List list = dbms.select(query, id).getChildren();

		if (list.size() == 0)
			return null;

		Element record = (Element) list.get(0);
		record.setName("info");

		record = (Element) record.detach();
		return record;
	}

	private Element getStatus(int id, DataManager dataMan, Dbms dbms)
			throws Exception {
		Element respStatus = new Element("statuses");

		Element status = dataMan.getStatus(dbms, id);
		if (status != null) {
			@SuppressWarnings("unchecked")
			List<Element> statusKids = status.getChildren();

			int statusCount = statusKids.size();

			respStatus.setAttribute("available", Integer.toString(statusCount));
			respStatus.setAttribute("onlyCurrent", Boolean.toString(showOnlyCurrentStatus));

			if( showOnlyCurrentStatus && statusCount > 1 ){
				statusCount = 1;
			}

			for(int i=0; i < statusCount; i++){
				Element kid = statusKids.get(i);
				kid.setName("status");
				respStatus.addContent(((Element)kid.clone()).detach());
			}
		}

		respStatus = (Element) respStatus.detach();
		return respStatus;
	}

//	private void checkAccess(ServiceContext context) throws Exception {
//
//		UserSession usrSess = context.getUserSession();
//
//		if (usrSess == null || !usrSess.isAuthenticated()) {
//			throw new OperationNotAllowedEx("Unauthorized request");
//		}
//
//		String myProfile = usrSess.getProfile();
//
//		if (myProfile == null || !allowedProfiles.contains(myProfile)) {
//			throw new OperationNotAllowedEx("Unauthorized request");
//		}
//	}

}
