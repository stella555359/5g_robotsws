from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import error, info
from robot.libraries.BuiltIn import BuiltIn


class LedControl(object):
    """
    Library for controlling LEDs.
    """

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.bbmods = BuiltIn().get_library_instance("BBMODs")

    def check_colors_of_leds(self, expected_colors):
        """
        Compare LED colors to expected colors.

        :param list expected_colors: List of expected colors.
        :raise AssertionError: If expected colors are not found in LED colors.

        :return bool: True if colors are correct.
        """
        success = True
        led_colors = self.get_led_color_from_webem()
        for value in expected_colors:
            if value not in led_colors.values():
                error("Expected color {} not found in LED colors.".format(value))
                raise AssertionError(
                    f"Expected colors {expected_colors}, but got {led_colors.values()}"
                )
        return success

    def get_led_color_from_webem(self):
        """
        Get LED color from WebEM.

        :return dict: Dictionary of DistNames and respective LED colors.
        """
        color_list = {}
        led_label = self.admin.get_managed_objects("LED_L")
        bbmods = self.bts.bbmods
        smods = self.bts.smods
        for bbmod in bbmods:
            if not led_label:
                continue
            for element in led_label:
                if 'distName' not in element or "BBMOD" not in element['distName']:
                    continue
                if bbmod.l_dist_name not in element['distName']:
                    continue
                if 'parameters' not in element or 'ledState' not in element['parameters']:
                    continue
                color_list[element['distName']] = element['parameters']['ledState']
                bbmod_in_question = element['distName']
                info(f"LED color of {bbmod_in_question} is {element['parameters']['ledState']}.")
            for smod in smods:
                for smod_element in led_label:
                    if 'distName' not in smod_element or "SMOD" not in smod_element['distName']:
                        continue
                    if smod.dist_name not in smod_element['distName']:
                        continue
                    if 'parameters' not in smod_element or 'ledState' not in smod_element['parameters']:
                        continue
                    color_list[smod_element['distName']] = smod_element['parameters']['ledState']
                    smod_in_question = smod_element['distName']
                    info(f"LED color of {smod_in_question} is {smod_element['parameters']['ledState']}.")
        return color_list
