package org.fao.geonet.kernel;

import org.fao.geonet.domain.Schematron;
import org.fao.geonet.domain.SchematronRequirement;

public class ApplicableSchematron {
    final SchematronRequirement requirement;
    final Schematron schematron;

    ApplicableSchematron(SchematronRequirement requirement, Schematron schematron) {
        this.requirement = requirement;
        this.schematron = schematron;
    }
}
