"""
:author:  Valtteri Lamberg
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

from robot.libraries.BuiltIn import BuiltIn


class UnitPathParser:
    def __init__(self):
        self.bts = BuiltIn().get_library_instance("BTS")

    def get_radio_unit_path_for_alarm(self, rmod):
        """
        Get radio unit path for alarm.

        :param str rmod: The radio in question, given as for example '(1.1.1.1)' or 'RMOD-1'
        :return tuple(str, str): Returns bts_name and radio_scf_dist_name
        """
        bts_name = self.bts.get_parameter_value_from_bts_info('btsName')
        for radio in self.bts.radios:
            if "." in rmod:
                rmod_location = rmod[rmod.find("("):]  # '(1.1.1.1)'
                if rmod_location in radio.name:
                    return "[{}] {}".format(bts_name, radio.scf_dist_name)
            else:  # RMOD-1
                if rmod in radio.scf_dist_name:
                    return "[{}] {}".format(bts_name, radio.scf_dist_name)
