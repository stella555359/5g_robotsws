from taf.config.scf import scf
from taf.config.scf.exceptions import MultipleMatches
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from robot.errors import HandlerExecutionFailed


BuiltIn = BuiltIn()
scf = scf()


class WrongBehaviorError(Exception):
    pass


def _extract_values_of_params_given_from_scf(scf_file_path, params):
    scf.load_scf(scf_file_path)
    actual = []
    for param in params:
        values = scf.get_all_values_from_scf(dist_name=param['para_mo'], p_name=param['para_abbr'])
        number_of_matches = len(values)
        if number_of_matches > 1:
            raise MultipleMatches(number_of_matches)
        value = None if number_of_matches == 0 else values[0]
        actual.append({'para_abbr': param['para_abbr'], 'para_mo': param['para_mo'], 'value': value})
    logger.info("Actual parameters: {}".format(actual))
    return actual


def compare_actual_asir_params(scf_file_path, expected):
    actual = _extract_values_of_params_given_from_scf(scf_file_path, expected)
    return actual == expected


def verify_asir_params(scf_file_path, expected):
    actual = _extract_values_of_params_given_from_scf(scf_file_path, expected)
    assert actual == expected, "Actual values aren't as expected. Actual: {}, Expected: {}".format(actual, expected)


def verify_user_cannot_modify_params_in_asir_webem(params):
    BuiltIn.run_keyword("AsirWebem.enter_config_man", "sub_menu=edit")
    for param in params:
        try:
            BuiltIn.run_keyword("AsirWebem.modify_parameter", [param])
        except HandlerExecutionFailed as e:
            if e.message == "Text parameter value is disabled" or e.message == "Select parameter value is disabled" \
                    or e.message.startswith("InvalidElementStateException"):
                logger.info("Modification of parameter {} in ASiR WebEM's Parameter editor failed as expected..".format(
                    param['para_abbr']), also_console=True)
                logger.info("with exception: {}.".format(e))
                continue
            else:
                raise e

        BuiltIn.run_keyword("AsirWebem.save_screenshot", "${LOG_PATH}/fail_due_to_forbidden_param_modified.png")
        raise WrongBehaviorError(
            "Fail due to param {} modified successfully, while its modification should be rejected.".format(
                param['para_abbr']))


def verify_config_man_button_status(dict_expected):
    """requires prior use of AsirWebEM.login"""
    assert len(dict_expected) > 0, "Empty expected buttons dict"

    dict_actual = BuiltIn.run_keyword("AsirWebEM.get_config_man_buttons_clickability_status")

    logger.info("expected buttons dict: {}".format(dict_expected))
    logger.info("actual buttons dict: {}".format(dict_actual))

    for button in dict_expected:
        assert dict_actual[button] == dict_expected[button], ("Wrong clickability status of '{}' button. Actual: {}, "
                                                              "Expected: {}".format(button,
                                                                                    dict_actual[button],
                                                                                    dict_expected[button]))

    logger.info("All specified buttons have active/disabled status as expected")
