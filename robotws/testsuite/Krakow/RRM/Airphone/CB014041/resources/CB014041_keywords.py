"""
author: Dawid Chuchnowski, dawid.chuchnowski@nokia.com
maintainer: Dawid Chuchnowski, dawid.chuchnowski@nokia.com
"""
import logging
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from CB014041_frozen_parameters import FROZEN_PARAMETERS


tl = BuiltIn().get_variable_value("${tl}")
gnb_ip = tl.gnbs[0].cu.oam_http_connection_details.addr


def validate_scf_and_return_relation_errors(scf_filepath):
    """
    Perform SCF validation and returns list of relation errors
    @param scf_filepath: path to SCF
    """
    admin_cli = admin()
    admin_cli.setup_admin(bts_host=gnb_ip, alias='admin_gnb')
    result = admin_cli.validate_scf(scf_file=scf_filepath,
                                    connection='admin_gnb', timeout=60, skip_parameter_relation_errors=True)
    relation_errors = [error['feedback'] for error in result['pdlValidationResult']['logs']['relationErrors']]
    for error in relation_errors:
        logging.info(error)
    admin_cli.teardown('admin_gnb')
    return relation_errors


def check_relation_errors_for_specified_parameters(parameters, relation_errors):
    """
    Checks that provided relation errors occurred

    @param parameters: list of frozen BTS parameters
    @param relation_errors: relation errors fetched from SCF validation
    """
    for param in parameters:
        logging.info(f"Looking for {param}: '{FROZEN_PARAMETERS[param]}' in relation errors...")
        assert FROZEN_PARAMETERS[param] in relation_errors, f"Correct relation error for {param} not found"
        logging.info(f"...OK.")
