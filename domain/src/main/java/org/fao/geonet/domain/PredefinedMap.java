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

package org.fao.geonet.domain;

import java.io.Serializable;

import javax.persistence.Access;
import javax.persistence.AccessType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EntityListeners;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;

import org.fao.geonet.entitylistener.PredefinedMapEntityListenerManager;

import com.fasterxml.jackson.annotation.JsonSetter;

/**
 * Represents a predefined map. This is a JPA Entity object and is contained in a database table.
 *
 * @author Jose García
 */
@Entity
@Access(AccessType.PROPERTY)
@EntityListeners(PredefinedMapEntityListenerManager.class)
@SequenceGenerator(name=PredefinedMap.ID_SEQ_NAME, initialValue=100, allocationSize=1)
public class PredefinedMap extends GeonetEntity implements Serializable {
    static final String ID_SEQ_NAME = "predefinedmap_id_seq";

    private int _id;
    private String _name;
    private String _description;
    private int _position;
    private Boolean _enabled;
    private String _map;
    private String _image;

    /**
     * Id of the predefined map. This is automatically generated so when creating a new object leave this blank and allow the database or JPA set
     * the value for you on save.
     */
    @Id
    @GeneratedValue (strategy = GenerationType.SEQUENCE, generator = ID_SEQ_NAME)
    public int getId() {
        return _id;
    }

    /**
     * Set the id of the predefined map. This is automatically generated so when creating a new object leave this blank and allow the database or
     * JPA set the value for you on save.
     *
     * @param id the id
     * @return this predefined map object
     */
    public PredefinedMap setId(final int id) {
        this._id = id;
        return this;
    }

    /**
     * Get the name of the predefined map.
     */
    @Column(nullable = false, unique = true, length = 255)
    public String getName() {
        return _name;
    }

    /**
     * Set the predefined map name.
     *
     * @param name the new predefined map name
     * @return this predefined map object
     */
    @JsonSetter("title")
    public PredefinedMap setName(final String name) {
        this._name = name;
        return this;
    }

    /**
     * Get the description of the predefined map.
     */
    @Column
    public String getDescription() {
        return _description;
    }

    /**
     * Set the predefined map description.
     *
     * @param description the new predefined map description
     * @return this predefined map object
     */
    @JsonSetter("description")
    public PredefinedMap setDescription(final String description) {
        this._description = description;
        return this;
    }

    /**
     * Get the position of the predefined map.
     */
    @Column
    public int getPosition() {
        return _position;
    }

    /**
     * Set the position of the predefined map.
     *
     * @param position the predefined map position
     * @return this predefined map object
     */
    public PredefinedMap setPosition(final int position) {
        this._position = position;
        return this;
    }

    /**
     * Return if the predefined map is enabled.
     *
     */
    @Column
    public Boolean isEnabled() {
        return _enabled;
    }

    /**
     * Sets the predefined map status.
     *
     * @param enabled the predefined map status
     * @return this predefined map object
     */
    public PredefinedMap setEnabled(final Boolean enabled) {
        this._enabled = enabled;
        return this;
    }


    /**
     * Return WMC map related to the predefined map.
     *
     * @return the zip/postal code
     */
    @Column(columnDefinition="TEXT")
    public String getMap() {
        return _map;
    }

    /**
     * Set the wmc map.
     *
     * @param map the wmc map
     * @return this predefined map object
     */
    public PredefinedMap setMap(final String map) {
        this._map = map;
        return this;
    }

    /**
     * Return image related to the predefined map.
     *
     * @return the map image
     */
    @Column
    public String getImage() {
        return this._image;
    }

    /**
     * Set the image related to the predefined map.
     *
     * @param image the map image
     * @return this predefined map object
     */
    @JsonSetter("link")
    public PredefinedMap setImage(String image) {
        this._image = image;
        return this;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        PredefinedMap that = (PredefinedMap) o;

        if (_id != that._id) return false;
        if (_position != that._position) return false;
        if (!_name.equals(that._name)) return false;
        if (!_description.equals(that._description)) return false;
        if (!_enabled.equals(that._enabled)) return false;
        if (!_map.equals(that._map)) return false;
        return _image.equals(that._image);

    }

    @Override
    public int hashCode() {
        int result = _id;
        result = 31 * result + _name.hashCode();
        result = 31 * result + _description.hashCode();
        result = 31 * result + _position;
        result = 31 * result + _enabled.hashCode();
        result = 31 * result + _map.hashCode();
        result = 31 * result + _image.hashCode();
        return result;
    }
}
