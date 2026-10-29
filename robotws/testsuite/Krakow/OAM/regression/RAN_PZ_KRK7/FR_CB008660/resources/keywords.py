from robot.libraries.BuiltIn import logger
from taf.rfrl.bts.devices.exceptions import AsirOperationFailed

import testsuite.Krakow.resources.RAN_PZ_KRK7.tools.keywords as keywords
from testsuite.Krakow.OAM.regression.RAN_PZ_KRK7.FR_CB008660.resources import variables
from testsuite.Krakow.OAM.regression.RAN_PZ_KRK7.FR_CB008660.resources.asir_scf_parser import (
    ScfXmlParser,
    namespace,
)


def has_managed_object_configured_parameter(scf_path: str, dist_name: str, parameter: str):
    """
    Checks if desired object (identified by unique dist_name within SCF xml file) has configured parameter.

    :param str scf_path: path to SCF file
    :param str dist_name: distname uniquely identifying object from SCF (attribute 'distName' of managedObject element)
    :param str parameter: parameter of object to be check

    :return dict:
        {"parameter": parameter, "value": found value of parameter } if there is desired parameter or
        {} (empty dict) if there is no desired parameter
    """
    with ScfXmlParser(SCF_path=scf_path) as root:
        managed_object = ScfXmlParser.get_managed_object_by_dist_name(root, dist_name=dist_name)
        managed_object_parameters = ScfXmlParser.get_managed_objects_parameters(managed_object)
        found_parameter = managed_object_parameters.get(parameter)
        if found_parameter:
            logger.debug(
                f"The {dist_name} managed object has configured parametr '{parameter}' with value"
                f" {found_parameter}."
            )
            return {"parameter": parameter, "value": found_parameter}

        logger.debug(
            f"The {dist_name} managed object has not configured parametr '{parameter}', all configured"
            f" parameters within this object are: {managed_object_parameters}."
        )
        return {}


def check_if_all_managed_objects_of_provided_nidd_class_has_not_configured_desired_parameter(
    scf_path: str, nidd_class: str, parameter: str, mode: str = "ASIR"
):
    """Checks that none of the objects of `nidd_class` has parameter `parameter` configured.

    :param str scf_path:
    :param str nidd_class:
    :param str parameter: parameter to be checked within nidd_class objects
    :param str mode: if set to "ASIR" analyses "ASIR" SCF, otherwise checks SCF as normal SCF, defaults to "ASIR"
    :raises Exception: if there are at least one object of provided nidd_class with defined parameter
        (no matter of value)
    """
    with ScfXmlParser(SCF_path=scf_path) as root:
        managed_objects = ScfXmlParser.get_managed_object_list_by_nidd_class(root, nidd_class=nidd_class, mode=mode)
        logger.debug(f"Found managed objects by NIDD '{nidd_class}' class = {managed_objects}")

        managed_objects_with_provided_parameter = []
        for managed_object in managed_objects:
            managed_object_dist_name = managed_object.attrib["distName"]
            parameter_of_managed_object = has_managed_object_configured_parameter(
                scf_path=scf_path,
                dist_name=managed_object_dist_name,
                parameter=parameter,
            )
            if parameter_of_managed_object:
                managed_objects_with_provided_parameter.append(
                    {
                        "distName": managed_object_dist_name,
                        "sourceline": managed_object.sourceline,
                        "parameter_value": parameter_of_managed_object["value"],
                    }
                )

        if not managed_objects_with_provided_parameter:
            logger.debug(
                f"None of {len(managed_objects)} found managed objects "
                f"by NIDD '{nidd_class}' has configured parameter '{parameter}'"
            )
        else:
            list_of_incorrectly_configured_objects = [
                f"Object '{found_object['distName']}' at line {found_object['sourceline']} "
                f"has value of {parameter} set to {found_object['parameter_value']}"
                for found_object in managed_objects_with_provided_parameter
            ]
            message = "\n".join(list_of_incorrectly_configured_objects)
            raise Exception(
                f"There are {len(managed_objects_with_provided_parameter)} found objects by NIDD"
                f" '{nidd_class}' with configured parameter '{parameter}'!"
                f"\n{message}"
            )


def has_antAntlPrDN_has_shortened_name(
    scf_path: str,
    dist_name: str = variables.CHANNEL_1_DIST_NAME,
    antAntlPrDN_desired_value: str = variables.ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_VALUE,
):
    """Checks if SCF has set parameter antAntlPrDN of ASI-1/BTS-1/CELL-1/CHANNELGROUP-1/CHANNEL-1 shortened.

    :param str scf_path:
    :param str dist_name: _description_, defaults to variables.CHANNEL_1_DIST_NAME
    :param str antAntlPrDN_desired_value: defaults to variables.ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_VALUE
    :raises Exception: _description_
    :raises Exception: _description_
    :return _type_: _description_
    """
    with ScfXmlParser(scf_path) as root:
        managed_object = ScfXmlParser.get_managed_object_by_dist_name(root, dist_name)
        antAntlPrDN_xpath = ".//ns:list[@name='antAntlPrDN']//ns:p"
        antAntlPrDN_element = managed_object.xpath(
            antAntlPrDN_xpath, namespaces=namespace
        )

        logger.console(ScfXmlParser.get_managed_objects_parameters(managed_object))

        if not antAntlPrDN_element:
            raise Exception(
                f"There are no antAntlPrDN parameter within '{dist_name}'!"
                f" All parameters are: {type(antAntlPrDN_element)}"
            )

        # the antAntlPrDN parameter is a list, but test scenario. requires checking only first elem. of that list
        antAntlPrDN_SCF_value = antAntlPrDN_element[0].text
        if not antAntlPrDN_desired_value == antAntlPrDN_SCF_value:
            raise Exception(
                f"The antAntlPrDN value from SCF has value '{antAntlPrDN_SCF_value}', but is should"
                f" has '{antAntlPrDN_desired_value}'!"
            )

        return True


def perform_asir_commissioning_with_validation_error_check():
    """Tries to update *incorrect* parameter value for ASIR and checks if there are properly raised error.

    :raises Exception: if despite incorrect value there are no errors raised from Asir
    """
    has_failed = False
    try:
        keywords.update_parameter_of_asir_configuration(
            asir_dist_name=variables.CHANNEL_1_DIST_NAME,
            parameter=variables.ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_PARAMETER,
            value=variables.ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_INCORRECT_VALUE,
            index=0,
        )
    except AsirOperationFailed as e:
        has_failed = True
        # TODO: add check desc. of AsirOperationFailed to have 'Validation failed: invalid parameters.'
        logger.debug(f"Correctly handled 'AsirOperationFailed' exception: {e}, {dir(e)}")

    if has_failed:
        logger.debug(
            f"ASIR correctly handled validation error with {variables.CHANNEL_1_DIST_NAME}:"
            f"{variables.ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_PARAMETER}:"
            f"{variables.ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_INCORRECT_VALUE}"
        )
        return True
    else:
        raise Exception(
            "ASIR had to raise AsirOperationFailed error, but has commissioned without interruptions!"
            f"Changed parameter {variables.CHANNEL_1_DIST_NAME}:"
            f"{variables.ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_PARAMETER}:"
            f"{variables.ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_INCORRECT_VALUE}"
        )
