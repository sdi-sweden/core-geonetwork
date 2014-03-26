package org.fao.geonet.services.region;

import java.util.Collection;
import java.util.Collections;

import jeeves.server.context.ServiceContext;

import org.opengis.referencing.crs.CoordinateReferenceSystem;

import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.GeometryFactory;

public class DbRegionsDAO extends RegionsDAO {

	public static final String CATEGORY_NAME = "database";

	private GeometryFactory factory = new GeometryFactory();

	@Override
	public Collection<String> getRegionCategoryIds(ServiceContext context)
			throws Exception {
		return Collections.singleton(CATEGORY_NAME);
	}

	@Override
	public Request createSearchRequest(ServiceContext context) throws Exception {
		DbRequest req = new DbRequest(context);
		return req;
	}

	@Override
	public Geometry getGeom(ServiceContext context, String id,
			boolean simplified, CoordinateReferenceSystem projection)
			throws Exception {
		Region region = createSearchRequest(context).id(id).get();
        if(region == null) {
            return null;
        }

        Geometry geometry = factory.toGeometry(region.getBBox(projection));
        geometry.setUserData(region.getBBox().getCoordinateReferenceSystem());

        return geometry;
	}

}
