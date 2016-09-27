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

package org.fao.geonet.services.metadata;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;

import org.apache.lucene.document.Document;
import org.apache.lucene.index.Term;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.TopDocs;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.Group;
import org.fao.geonet.domain.OperationAllowed;
import org.fao.geonet.domain.OperationAllowedId;
import org.fao.geonet.domain.Profile;
import org.fao.geonet.domain.ReservedGroup;
import org.fao.geonet.domain.ReservedOperation;
import org.fao.geonet.domain.User;
import org.fao.geonet.domain.UserGroup;
import org.fao.geonet.domain.UserGroupId;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.SelectionManager;
import org.fao.geonet.kernel.mef.MEFLibIntegrationTest.ImportMetadata;
import org.fao.geonet.kernel.search.IndexAndTaxonomy;
import org.fao.geonet.kernel.search.SearchManager;
import org.fao.geonet.repository.GroupRepository;
import org.fao.geonet.repository.OperationAllowedRepository;
import org.fao.geonet.repository.UserGroupRepository;
import org.fao.geonet.repository.UserRepository;
import org.fao.geonet.repository.specification.GroupSpecs;
import org.fao.geonet.repository.specification.OperationAllowedSpecs;
import org.fao.geonet.services.AbstractServiceIntegrationTest;
import org.fao.geonet.services.metadata.Publish.PublishReport;
import org.junit.Before;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.domain.Specifications;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.security.core.context.SecurityContextHolder;

import com.google.common.base.Joiner;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

import jeeves.constants.Jeeves;
import jeeves.server.context.ServiceContext;

public class PublishTest extends AbstractServiceIntegrationTest {

    private List<String> metadataIds;
    @Autowired
    private Publish publishService;
    @Autowired
    private OperationAllowedRepository allowedRepository;
    @Autowired
    private GroupRepository groupRepository;
    @Autowired
    private UserGroupRepository userGroupRepository;
    @Autowired
    private UserRepository userRepository;
    
    private Group sampleGroup;
    private int sampleGroupId;
    @Autowired
    private DataManager dataManager;
    @Autowired
    private SearchManager searchManager;


    @Before
    public void setUp() throws Exception {
        final List<Group> all = groupRepository.findAll(Specifications.not(GroupSpecs.isReserved()));
        this.sampleGroup = all.get(0);
        this.sampleGroupId = this.sampleGroup.getId();

        final ServiceContext serviceContext = createServiceContext();
        loginAsAdmin(serviceContext);

        final ImportMetadata importMetadata = new ImportMetadata(this, serviceContext);
        importMetadata.getMefFilesToLoad().add("mef2-example-2md.zip");
        importMetadata.invoke();

        this.metadataIds = importMetadata.getMetadataIds();
        publishService.testing = true;
    }

    @Test
    public void testPublishSingleAsReviewer() throws Exception {
        final User user = getNewUser("user1", Profile.Reviewer);

        getNewUserGroup(user, sampleGroup, Profile.Reviewer);
        loginAs(user);
        
        final String metadataId = metadataIds.get(0);

        allowedRepository.deleteAll();
        dataManager.indexMetadata(metadataId, true);

        MockHttpServletRequest request = new MockHttpServletRequest();
        request.getSession();
        PublishReport report = publishService.publish("eng", request, metadataId, false);
        assertCorrectReport(report, 1, 0, 0, 0);
        assertPublishedInIndex(true, metadataId, false);

        report = publishService.publish("eng", request, metadataId, false);
        assertCorrectReport(report, 0, 0, 1, 0);
        assertPublishedInIndex(true, metadataId, false);

        assertEquals(10, allowedRepository.count());
        int iMetadataId = Integer.parseInt(metadataId);
        final int viewId = ReservedOperation.view.getId();
        final int downloadId = ReservedOperation.download.getId();
        final int allGroupId = ReservedGroup.all.getId();
        final int featuredId = ReservedOperation.featured.getId();
        assertNotNull("ALL, View not found", allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, viewId));
        assertNotNull("ALL, Download not found", allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, downloadId));
        assertNotNull("ALL, Feature not found", allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, featuredId));
//        assertNotNull("Sample Group, Feature not found", allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(sampleGroupId, iMetadataId, featuredId));

        allowedRepository.deleteAll();
        dataManager.indexMetadata(metadataId, true);
        assertPublishedInIndex(false, metadataId, false);

        SecurityContextHolder.clearContext();

        report = publishService.publish("eng", request, metadataId, false);
        assertCorrectReport(report, 0, 0, 0, 1);
        assertPublishedInIndex(false, metadataId, false);

        allowedRepository.save(new OperationAllowed(new OperationAllowedId(iMetadataId, allGroupId, downloadId)));
        allowedRepository.save(new OperationAllowed(new OperationAllowedId(iMetadataId, allGroupId, featuredId)));
        allowedRepository.save(new OperationAllowed(new OperationAllowedId(iMetadataId, sampleGroupId, featuredId)));

        report = publishService.publish("eng", request, metadataId, false);
        assertCorrectReport(report, 0, 0, 1, 0);
        assertEquals(4, allowedRepository.count());
        assertNotNull(allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, viewId));
        assertNotNull(allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, downloadId));
        assertNotNull(allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, featuredId));
        assertNotNull(allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(sampleGroupId, iMetadataId, featuredId));
    }

    
    @Test
    public void testPublishSingleAsEditor() throws Exception {
        final User user = getNewUser("user2", Profile.Editor);  
        getNewUserGroup(user, sampleGroup, Profile.Editor);
        loginAs(user);
        
        final String metadataId = metadataIds.get(0);

        allowedRepository.deleteAll();
        dataManager.indexMetadata(metadataId, true);

        MockHttpServletRequest request = new MockHttpServletRequest();
        request.getSession();
        
        PublishReport report = publishService.publish("eng", request, metadataId, false);
        assertCorrectReport(report, 0, 0, 0, 1);
        assertPublishedInIndex(false, metadataId, false);

        report = publishService.publish("eng", request, metadataId, false);
        assertCorrectReport(report, 0, 0, 1, 0);
        assertPublishedInIndex(false, metadataId, false);

        allowedRepository.deleteAll();
        dataManager.indexMetadata(metadataId, true);
        assertPublishedInIndex(false, metadataId, false);

        SecurityContextHolder.clearContext();

        report = publishService.publish("eng", request, metadataId, false);
        assertCorrectReport(report, 0, 0, 0, 1);
        assertPublishedInIndex(false, metadataId, false);

        int iMetadataId = Integer.parseInt(metadataId);
        final int viewId = ReservedOperation.view.getId();
        final int downloadId = ReservedOperation.download.getId();
        final int allGroupId = ReservedGroup.all.getId();
        final int featuredId = ReservedOperation.featured.getId();
        allowedRepository.save(new OperationAllowed(new OperationAllowedId(iMetadataId, allGroupId, featuredId)));
        allowedRepository.save(new OperationAllowed(new OperationAllowedId(iMetadataId, sampleGroupId, featuredId)));

        report = publishService.publish("eng", request, metadataId, false);
        assertCorrectReport(report, 0, 0, 1, 0);
        assertEquals(4, allowedRepository.count());
        assertNotNull(allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, viewId));
        assertNotNull(allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, downloadId));
        assertNotNull(allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, featuredId));
        assertNotNull(allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(sampleGroupId, iMetadataId, featuredId));
    }

    @Test
    public void testPublishSingleSkippingIntranet() throws Exception {
        final String metadataId = metadataIds.get(0);

        allowedRepository.deleteAll();
        dataManager.indexMetadata(metadataId, true);

        MockHttpServletRequest request = new MockHttpServletRequest();
        request.getSession();

        PublishReport report = publishService.publish("eng", request, metadataId, true);
        assertCorrectReport(report, 1, 0, 0, 0);
        assertPublishedInIndex(true, metadataId, true);

        report = publishService.publish("eng", request, metadataId, true);
        assertCorrectReport(report, 0, 0, 1, 0);
        assertPublishedInIndex(true, metadataId, true);

        allowedRepository.deleteAll();
        dataManager.indexMetadata(metadataId, true);
        assertPublishedInIndex(false, metadataId, true);

        SecurityContextHolder.clearContext();

        report = publishService.publish("eng", request, metadataId, true);
        assertCorrectReport(report, 0, 0, 0, 1);
        assertPublishedInIndex(false, metadataId, true);

        int iMetadataId = Integer.parseInt(metadataId);
        final int viewId = ReservedOperation.view.getId();
        final int downloadId = ReservedOperation.download.getId();
        final int allGroupId = ReservedGroup.all.getId();
        allowedRepository.save(new OperationAllowed(new OperationAllowedId(iMetadataId, allGroupId, viewId)));
        allowedRepository.save(new OperationAllowed(new OperationAllowedId(iMetadataId, allGroupId, downloadId)));
        final int featuredId = ReservedOperation.featured.getId();
        allowedRepository.save(new OperationAllowed(new OperationAllowedId(iMetadataId, allGroupId, featuredId)));
        allowedRepository.save(new OperationAllowed(new OperationAllowedId(iMetadataId, sampleGroupId, featuredId)));

        report = publishService.publish("eng", request, metadataId, false);
        assertCorrectReport(report, 0, 0, 1, 0);
        assertEquals(4, allowedRepository.count());
        assertNotNull(allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, viewId));
        assertNotNull(allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, downloadId));
        assertNotNull(allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, featuredId));
        assertNotNull(allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(sampleGroupId, iMetadataId, featuredId));
    }


    @Test
    public void testPublishSingleAsAdministrator() throws Exception {
        final String metadataId = metadataIds.get(0);

        allowedRepository.deleteAll();
        dataManager.indexMetadata(metadataId, true);

        MockHttpServletRequest request = new MockHttpServletRequest();
        request.getSession();

        PublishReport report = publishService.publish("eng", request, metadataId, false);
        assertCorrectReport(report, 1, 0, 0, 0);
        assertPublishedInIndex(true, metadataId, false);

        report = publishService.publish("eng", request, metadataId, false);
        assertCorrectReport(report, 0, 0, 1, 0);
        assertPublishedInIndex(true, metadataId, false);

        allowedRepository.deleteAll();
        dataManager.indexMetadata(metadataId, true);
        assertPublishedInIndex(false, metadataId, false);

        SecurityContextHolder.clearContext();

        report = publishService.publish("eng", request, metadataId, false);
        assertCorrectReport(report, 0, 0, 0, 1);
        assertPublishedInIndex(false, metadataId, false);

        int iMetadataId = Integer.parseInt(metadataId);
        final int allGroupId = ReservedGroup.all.getId();
        final int viewId = ReservedOperation.view.getId();
        final int downloadId = ReservedOperation.download.getId();
        final int featuredId = ReservedOperation.featured.getId();
        allowedRepository.save(new OperationAllowed(new OperationAllowedId(iMetadataId, sampleGroupId, featuredId)));

        report = publishService.publish("eng", request, metadataId, false);
        assertCorrectReport(report, 0, 0, 1, 0);
        assertEquals(3, allowedRepository.count());
        assertNotNull("All Group viewID not found",allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, viewId));
        assertNotNull("All Group downloadID not found",allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, downloadId));
        assertNull("All Group featureID found",allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(allGroupId, iMetadataId, featuredId));
        assertNotNull("Sample Group featureID not found",allowedRepository.findOneById_GroupIdAndId_MetadataIdAndId_OperationId(sampleGroupId, iMetadataId, featuredId));
    }

    @Test
    public void testPublishMultiple() throws Exception {
        allowedRepository.deleteAll();

        MockHttpServletRequest request = new MockHttpServletRequest();
        request.getSession();
        String ids = Joiner.on(",").join(this.metadataIds);

        PublishReport report = publishService.publish("eng", request, ids, false);
        assertCorrectReport(report, 3, 0, 0, 0);

        report = publishService.publish("eng", request, ids, false);
        assertCorrectReport(report, 0, 0, 3, 0);

        allowedRepository.deleteAll(OperationAllowedSpecs.hasMetadataId(this.metadataIds.get(0)));

        report = publishService.publish("eng", request, ids, false);
        assertCorrectReport(report, 1, 0, 2, 0);

        allowedRepository.deleteAll(OperationAllowedSpecs.hasMetadataId(this.metadataIds.get(0)));

        SecurityContextHolder.clearContext();

        report = publishService.publish("eng", request, ids, false);
        assertCorrectReport(report, 0, 0, 2, 1);

    }

    @Test
    public void testUnpublishSingle() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.getSession();
        final String metadataId = metadataIds.get(0);

        PublishReport report = publishService.unpublish("eng", request, metadataId, false);
        assertCorrectReport(report, 0, 1, 0, 0);


        report = publishService.unpublish("eng", request, metadataId, false);
        assertCorrectReport(report, 0, 0, 1, 0);

        report = publishService.publish("eng", request, metadataId, false);
        assertCorrectReport(report, 1, 0, 0, 0);

        SecurityContextHolder.clearContext();

        report = publishService.unpublish("eng", request, metadataId, false);
        assertCorrectReport(report, 0, 0, 0, 1);
    }

    @Test
    public void testUnpublishMultiple() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.getSession();
        String ids = Joiner.on(",").join(this.metadataIds);

        PublishReport report = publishService.unpublish("eng", request, ids, false);
        assertCorrectReport(report, 0, 3, 0, 0);

        report = publishService.unpublish("eng", request, ids, false);
        assertCorrectReport(report, 0, 0, 3, 0);

        report = publishService.publish("eng", request, this.metadataIds.get(0), false);
        assertCorrectReport(report, 1, 0, 0, 0);

        report = publishService.unpublish("eng", request, ids, false);
        assertCorrectReport(report, 0, 1, 2, 0);

        report = publishService.publish("eng", request, ids, false);
        assertCorrectReport(report, 3, 0, 0, 0);

        SecurityContextHolder.clearContext();

        report = publishService.unpublish("eng", request, ids, false);
        assertCorrectReport(report, 0, 0, 0, 3);
    }

    @Test
    public void testUnpublishSelection() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.getSession();
        ServiceContext context = createServiceContext();
        loginAsAdmin(context);

        request.getSession(true).setAttribute(Jeeves.Elem.SESSION, context.getUserSession());

        SelectionManager sm = SelectionManager.getManager(context.getUserSession());
        final HashSet<String> selection = Sets.newHashSet(toUUID(metadataIds.get(0)), toUUID(metadataIds.get(1)));
        sm.addAllSelection(SelectionManager.SELECTION_METADATA, selection);

        PublishReport report = publishService.unpublish("eng", request, null, false);
        assertCorrectReport(report, 0, 2, 0, 0);

        report = publishService.unpublish("eng", request, null, false);
        assertCorrectReport(report, 0, 0, 2, 0);

        report = publishService.publish("eng", request, this.metadataIds.get(0), false);
        assertCorrectReport(report, 1, 0, 0, 0);

        report = publishService.unpublish("eng", request, null, false);
        assertCorrectReport(report, 0, 1, 1, 0);

        report = publishService.publish("eng", request, null, false);
        assertCorrectReport(report, 2, 0, 0, 0);

        SecurityContextHolder.clearContext();

        report = publishService.unpublish("eng", request, null, false);
        assertCorrectReport(report, 0, 0, 0, 2);
    }

    private String toUUID(String mdId) throws Exception {
        return this.dataManager.getMetadataUuid(mdId);
    }

    private void assertCorrectReport(PublishReport report, int published, int unpublished, int unmodified, int disallowed) {
        assertEquals(report.toString() + " (published)", published, report.getPublished());
        assertEquals(report.toString() + " (unmodified)", unmodified, report.getUnmodified());
        assertEquals(report.toString() + " (unpublished)", unpublished, report.getUnpublished());
        assertEquals(report.toString() + " (dissallowed)", disallowed, report.getDisallowed());
    }

    private void assertPublishedInIndex(boolean published, String metadataId, boolean skipIntranet) throws IOException {
        try (IndexAndTaxonomy indexReader = this.searchManager.getIndexReader(null, -1)) {
            final IndexSearcher searcher = new IndexSearcher(indexReader.indexReader);
            final TopDocs docs = searcher.search(new TermQuery(new Term(Geonet.IndexFieldNames.ID, metadataId)), 1);
            final Document document = indexReader.indexReader.document(docs.scoreDocs[0].doc);
            List<ReservedGroup> reserveGroup = Lists.newArrayList(ReservedGroup.all);
            if(!skipIntranet) {
                reserveGroup.add(ReservedGroup.intranet);
            }
            for (ReservedGroup reservedGroup : reserveGroup) {
                final String[] values = document.getValues(Geonet.IndexFieldNames.GROUP_PUBLISHED);
                final String expectedInIndex = Geonet.IndexFieldNames.GROUP_PUBLISHED + ":" + reservedGroup;
                assertEquals(expectedInIndex + " is not in " + Arrays.asList(values),
                    published, Arrays.asList(values).contains("" + reservedGroup.name()));
            }
        }
    }
    
    private User getNewUser(String userName, Profile profile) {
        User user = new User().setUsername(userName);
        user.getSecurity().setPassword("password" + userName);
        user.setProfile(profile);
        return user = userRepository.save(user);        
    }

//    private Group getNewGroup(String groupName) {
//        return groupRepository.save(new Group().setName(groupName ));
//    }
    
    private UserGroup getNewUserGroup(User user, Group group, Profile profile) {
        UserGroup userGroup = new UserGroup().setGroup(group).setUser(user).setId(new UserGroupId(user, group));
        userGroup.setProfile(profile);
        return userGroup = userGroupRepository.saveAndFlush(userGroup);
    }
   
}
