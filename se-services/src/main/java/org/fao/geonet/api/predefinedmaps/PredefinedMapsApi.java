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

package org.fao.geonet.api.predefinedmaps;

import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.api.API;
import org.fao.geonet.api.exception.ResourceNotFoundException;
import org.fao.geonet.domain.PredefinedMap;
import org.fao.geonet.domain.responses.StatusResponse;
import org.fao.geonet.exceptions.BadParameterEx;
import org.fao.geonet.repository.PredefinedMapRepository;
import org.fao.geonet.resources.Resources;
import org.fao.geonet.utils.IO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

import javax.servlet.ServletRequest;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

@EnableWebMvc
@Service
@RequestMapping(value = {
    "/api/predefinedmaps",
    "/api/" + API.VERSION_0_1 +
        "/predefinedmaps"
})
@Api(value = "predefinedmaps",
    tags = "predefinedmaps",
    description = "Predefined maps related operations")
/**
 * API for predefined maps related operations.
 *
 * @author Jose García
 */
public class PredefinedMapsApi {
    @Autowired
    private PredefinedMapRepository predefinedMapRepository;

    @ApiOperation(value = "Retrieve a list of predefined maps",
        nickname = "retrievePredefinedMaps")
    @RequestMapping(
        value = "/",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseStatus(value = HttpStatus.OK)
    @ResponseBody
    public List<PredefinedMap> retrievePredefinedMaps(ServletRequest request)
        throws Exception {

        return predefinedMapRepository.findAll();
    }

    @ApiOperation(value = "Retrieve a  predefined maps",
        nickname = "retrievePredefinedMap")
    @RequestMapping(
        value = "/{id}",
        method = RequestMethod.GET)
    @ResponseStatus(value = HttpStatus.OK)
    @ResponseBody
    public PredefinedMap retrievePredefinedMap(
        @ApiParam(value = "Predefined map identifier",
            required = true)
        @PathVariable
            Integer id,
        ServletRequest request)
        throws Exception {

        PredefinedMap predefinedMap = predefinedMapRepository.findOne(id);

        return predefinedMap;
    }

    @ApiOperation(value = "Creates a predefined map",
        nickname = "createPredefinedMap")
    @RequestMapping(
        value = "/",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseStatus(value = HttpStatus.CREATED)
    @ResponseBody
    public StatusResponse createPredefinedMap(
        @ApiParam(
                value = "Predefined map name",
                required = true
        )
        @RequestParam
        final String name,
        @ApiParam(
                value = "Predefined map status",
                required = true
        )
        @RequestParam
        final Boolean enabled,
        @ApiParam(
                value = "Predefined map position",
                required = true
        )
        @RequestParam
        final int position,
        @ApiParam(
                value = "Predefined map context",
                required = true
        )
        @RequestParam
        final String mapContext,
        @ApiParam(
                value = "Predefined map image",
                required = true
        )
        @RequestParam
        final MultipartFile image,
        ServletRequest request)
        throws Exception {

        saveFile(image);

        PredefinedMap predefinedMap = new PredefinedMap();
        predefinedMap.setName(name);
        predefinedMap.setEnabled(enabled);
        predefinedMap.setPosition(position);
        predefinedMap.setMap(mapContext);
        predefinedMap.setImage(image.getOriginalFilename());

        predefinedMapRepository.save(predefinedMap);

        return new StatusResponse("Predefined map created");
    }


    /*@ApiOperation(value = "Updates a predefined map",
        nickname = "updatePredefinedMap")
    @RequestMapping(
        value = "/{id}",
        method = RequestMethod.POST,
        produces = MediaType.TEXT_PLAIN_VALUE)
    @ResponseStatus(value = HttpStatus.CREATED)
    @ResponseBody
    public ResponseEntity<String> updatePredefinedMap(
        @ApiParam(value = "Predefined map identifier",
            required = true)
        @PathVariable
            Integer id,
        @ApiParam(value = "Predefined map details",
            required = true)
        @RequestBody
            PredefinedMap predefinedMap,
        ServletRequest request)
        throws Exception {

        predefinedMapRepository.save(predefinedMap);

        return new ResponseEntity<>("Updated", HttpStatus.OK);
    }*/


    @ApiOperation(value = "Updates a predefined map",
            nickname = "updatePredefinedMap")
    @RequestMapping(
            value = "/{id}",
            method = RequestMethod.POST,
            produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseStatus(value = HttpStatus.OK)
    @ResponseBody
    public StatusResponse updatePredefinedMap(
            @ApiParam(value = "Predefined map identifier",
                    required = true)
            @PathVariable
                    Integer id,
            @ApiParam(
                    value = "Predefined map name",
                    required = true
            )
            @RequestParam
            final String name,
            @ApiParam(
                    value = "Predefined map status",
                    required = true
            )
            @RequestParam
            final Boolean enabled,
            @ApiParam(
                    value = "Predefined map position",
                    required = true
            )
            @RequestParam
            final int position,
            @ApiParam(
                    value = "Predefined map context",
                    required = true
            )
            @RequestParam
            final String mapContext,
            @ApiParam(
                    value = "Predefined map image",
                    required = true
            )
            @RequestParam
            final MultipartFile image,
            ServletRequest request)
            throws Exception {

        PredefinedMap predefinedMap = predefinedMapRepository.findOne(id);

        if (predefinedMap == null) {
            throw new ResourceNotFoundException("No predefined map with id: "
                    + id);
        }

        saveFile(image);

        predefinedMap.setName(name);
        predefinedMap.setEnabled(enabled);
        predefinedMap.setPosition(position);
        predefinedMap.setMap(mapContext);
        predefinedMap.setImage(image.getOriginalFilename());

        predefinedMapRepository.save(predefinedMap);

        return new StatusResponse("Predefined map updated");
    }

    @ApiOperation(value = "Deletes a predefined map",
        nickname = "deletePredefinedMap")
    @RequestMapping(
        value = "/{id}",
        method = RequestMethod.DELETE,
        produces = MediaType.TEXT_PLAIN_VALUE)
    @ResponseStatus(value = HttpStatus.CREATED)
    @ResponseBody
    public ResponseEntity<String> deletePredefinedMap(
        @ApiParam(value = "Predefined map identifier",
            required = true)
        @PathVariable
            Integer id,
        ServletRequest request)
        throws Exception {

        PredefinedMap predefinedMap = predefinedMapRepository.findOne(id);

        if (predefinedMap == null) {
            throw new ResourceNotFoundException("No predefined map with id: "
                    + id);
        }

        predefinedMapRepository.delete(predefinedMap);

        return new ResponseEntity<>("Deleted", HttpStatus.OK);
    }


    private void checkFileName(String fileName) throws Exception {
        if (fileName.contains("..")) {
            throw new BadParameterEx(
                    "Invalid character found in resource name.",
                    fileName);
        }

        if ("".equals(fileName)) {
            throw new Exception("File name is not defined.");
        }
    }


    private void saveFile(MultipartFile image) throws Exception {
        ApplicationContext appContext = ApplicationContextHolder.get();

        Path directoryPath = Resources.locateHarvesterLogosDirSMVC(appContext);

        Path filePath = directoryPath.resolve(image.getOriginalFilename());
        if (Files.exists(filePath)) {
            IO.deleteFile(filePath, true, "Deleting file");
            filePath = directoryPath.resolve(image.getOriginalFilename());
        }

        filePath = Files.createFile(filePath);

        try (OutputStream stream = Files.newOutputStream(filePath)) {
            int read;
            byte[] bytes = new byte[1024];
            InputStream is = image.getInputStream();
            while ((read = is.read(bytes)) != -1) {
                stream.write(bytes, 0, read);
            }
        }
    }
}
