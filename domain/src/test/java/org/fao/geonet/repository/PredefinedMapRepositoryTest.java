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

package org.fao.geonet.repository;

import org.fao.geonet.domain.PredefinedMap;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.Assert.assertEquals;

public class PredefinedMapRepositoryTest extends AbstractSpringDataTest {

    @Autowired
    PredefinedMapRepository _repo;

    @Test
    public void testFindOne() {
        PredefinedMap predefinedMap1 = newPredefinedMap();
        predefinedMap1 = _repo.save(predefinedMap1);

        PredefinedMap predefinedMap2 = newPredefinedMap();
        predefinedMap2 = _repo.save(predefinedMap2);

        assertEquals(predefinedMap2, _repo.findOne(predefinedMap2.getId()));
        assertEquals(predefinedMap1, _repo.findOne(predefinedMap1.getId()));
    }
    private PredefinedMap newPredefinedMap() {
        return newPredefinedMap(_inc);
    }

    public static PredefinedMap newPredefinedMap(AtomicInteger inc) {
        int val = inc.incrementAndGet();
        PredefinedMap predefinedMap = new PredefinedMap().setName("name" + val).
            setMap("map" + val).setPosition(inc.get()).setEnabled(true);
        return predefinedMap;
    }

}
