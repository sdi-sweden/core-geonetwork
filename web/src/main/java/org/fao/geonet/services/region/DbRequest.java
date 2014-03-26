package org.fao.geonet.services.region;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jeeves.resources.dbms.Dbms;
import jeeves.server.context.ServiceContext;

import org.apache.commons.logging.LogFactory;
import org.fao.geonet.constants.Geonet;
import org.geotools.geometry.jts.ReferencedEnvelope;
import org.jdom.Element;
import org.opengis.referencing.crs.CoordinateReferenceSystem;

public class DbRequest extends Request {

	private static org.apache.commons.logging.Log LOG = LogFactory.getLog(DbRequest.class);

	private static final CoordinateReferenceSystem WGS84 = Region.WGS84;

	private ServiceContext mContext;
	private List<Integer> mIds;
	private List<String> mLabels;

	public DbRequest(ServiceContext context) {
		this.mContext = context;
		mIds = new ArrayList<Integer>();
		mLabels = new ArrayList<String>();
	}

	@Override
	public Request id(String regionId) {
		this.mIds.add(Integer.parseInt(regionId));
        return this;
	}

	@Override
	public Request label(String labelParam) {
		this.mLabels.add(labelParam);
        return this;
	}

	@Override
	public Request categoryId(String categoryIdParam) {
		return this;
	}

	@Override
	public Request maxRecords(int maxRecordsParam) {
		return this;
	}

	private String createWhereId(){
		StringBuilder sb = new StringBuilder();

		if(!mIds.isEmpty()){
			sb.append(" AND (id IN (");
			sb.append( createQ(mIds.size()) );
			sb.append("))");
		}
		return sb.toString();
	}

	private String createWhereLabels(){
		StringBuilder sb = new StringBuilder();

		if(!mLabels.isEmpty()){
			sb.append(" AND (langid IN (");
			sb.append( createQ( mLabels.size() ) );
			sb.append("))");
		}
		return sb.toString();
	}

	private String createQ(int count){
		StringBuilder sb = new StringBuilder();

		for(int i = 0; i < count; i++){
			sb.append("?");

			if( i < count-1){
				sb.append(",");
			}
		}
		return sb.toString();
	}


	@Override
	public Collection<Region> execute() throws Exception {
		Dbms dbms = (Dbms) mContext.getResourceManager().open(Geonet.Res.MAIN_DB);

		StringBuilder query = new StringBuilder("SELECT * FROM regionsdes, regions WHERE id=iddes");

		query.append( createWhereId() );
		query.append( createWhereLabels() );

		if(LOG.isDebugEnabled()){
			LOG.debug(query.toString());
		}

	    List<Object> args = new ArrayList<Object>();
	    args.addAll(mIds);
	    args.addAll(mLabels);

		Element select = dbms.select(query.toString(), (Object[]) args.toArray(new Object[args.size()]));

		@SuppressWarnings("unchecked")
		List<Element> records = (List<Element>) select.getChildren();

		Collection<DbRegion> regionCollection = collectRegions(records);

		List<Region> regions = new ArrayList<Region>(regionCollection.size());

		boolean hasGeom = false;
		Map<String, String> categoryLabels = Collections.<String, String>emptyMap();

		for(DbRegion dbRegion : regionCollection){
			Region region = new Region(dbRegion.getId(), dbRegion.getLabels(), DbRegionsDAO.CATEGORY_NAME, categoryLabels, hasGeom, dbRegion.getBbox() );
	        regions.add(region);
		}

		return regions;
	}

	private Collection<DbRegion> collectRegions(List<Element> records){
		Map<String, DbRegion> regionCollector = new HashMap<String, DbRegion>();

		for(Element record : records){

			String id = record.getChildText("id");

			DbRegion dbRegion = regionCollector.get(id);

			if(dbRegion == null){
	            double west = Double.parseDouble(record.getChildText("west") );
	            double east = Double.parseDouble(record.getChildText("east"));
	            double north = Double.parseDouble(record.getChildText("north"));
	            double south = Double.parseDouble(record.getChildText("south"));
	            ReferencedEnvelope bbox = new ReferencedEnvelope(west, east, south, north, WGS84);

				dbRegion = new DbRegion(id, bbox);
			}

			String lang = record.getChildText("langid");
			String label = record.getChildText("label");

			dbRegion.addLabel( lang,label );

			regionCollector.put(id, dbRegion);
		}

		return regionCollector.values();
	}


	class DbRegion{
		private ReferencedEnvelope bbox;
		private String id;
		private Map<String, String> labels;

		public DbRegion(String id, ReferencedEnvelope bbox) {
			this.id = id;
			this.bbox = bbox;
			labels = new HashMap<String, String>();
		}

		public void addLabel(String lang, String label) {
			this.labels.put(lang, label);
		}

		public String getId() {
			return id;
		}

		public ReferencedEnvelope getBbox() {
			return bbox;
		}

		public Map<String, String> getLabels(){
			return labels;
		}
	}
}
