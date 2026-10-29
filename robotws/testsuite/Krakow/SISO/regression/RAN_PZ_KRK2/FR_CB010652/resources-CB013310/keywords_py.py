from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger

BuiltIn = BuiltIn()


def verify_if_specified_buttons_are_active_or_greyed_out_in_config_man(dict_expected):
    """requires prior use of AsirWebEM.login"""
    assert len(dict_expected) > 0, "Empty expected buttons dict"

    dict_actual = BuiltIn.run_keyword("AsirWebEM.get_config_man_buttons_clickability_status")

    logger.info("expected buttons dict: {}".format(dict_expected))
    logger.info("actual buttons dict: {}".format(dict_actual))

    for button in dict_expected:
        assert dict_actual[button] == dict_expected[button], ("Wrong grey out status of '{}' button. Actual: {}, "
                                                              "Expected: {}".format(button,
                                                                                    dict_actual[button],
                                                                                    dict_expected[button]))

    logger.info("All specified buttons have active/greyed out status as expected")
