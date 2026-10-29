"""
:author:  Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import re
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import error


class FSPUnits:
    """
    FSP unit parser.
    """

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")

    def connect_fsp_units_to_configuration_identifiers(self):
        units = [self.bts.bbmods, self.bts.smods]
        if units:
            return self._connect_unit_to_configuration_identifier(units)
        return {}

    def _connect_unit_to_configuration_identifier(self, units):
        unit_dict = {}
        for unit_list in units:
            for unit in unit_list:
                nmbr = self._get_location_of(unit)
                unit_dict = self._connect_unit_name_to_dist_name(nmbr, unit.name, unit_dict)
        return unit_dict

    def _get_location_of(self, unit):
        nmbr = ""
        if "FBB" in unit.name:  # FBBA/FBBC
            nmbr = self._get_fbb_location(nmbr, unit.name)
        elif "ASC" in unit.name:
            nmbr = self._get_asc_location(nmbr, unit.name)
        else:  # FSPD/FSPC/FBIP/ABIA/ABIB
            nmbr = self._get_other_units_location(nmbr, unit.name)
        return nmbr

    def _connect_unit_name_to_dist_name(self, nmbr, unit_name, unit_dict):
        if "ASIL" or "ASIB" in unit_name:
            return unit_dict
        if "ASC" in unit_name or "ABIP" in unit_name or "ABIQ" in unit_name:
            parse_fsp = re.compile(
                r".*RAT-1/(?P<fsp>BTS_L-{bts_side}/EQM_L-1.*BOARD_L-\d+)".format(bts_side=self.bts.side))
        else:
            parse_fsp = re.compile(
                r".*RAT-1/(?P<fsp>BTS_L-{bts_side}/EQM_L-1.*/(BBMOD_L-\d+|SMOD_L-\d+))/BBU_L-\d+.*".format(
                    bts_side=self.bts.side))
        fsp_mo = self.admin.get_managed_objects("BBU_L")
        fsp_mo.extend(self.admin.get_managed_objects("BOARD_L"))  # ASOE/ASCE/ABIP
        if fsp_mo:
            for mo in fsp_mo:
                match = parse_fsp.match(mo["distName"])
                if match:
                    if str(mo["parameters"]["nodeId"]) == str(nmbr):
                        fsp = match.group("fsp")
                        unit_dict[unit_name] = fsp
                        return unit_dict
        error("Could not get 'nodeId' value of 'BBU' or 'BOARD' object from IM for unit {}".format(unit_name))
        return unit_dict

    def _get_other_units_location(self, nmbr, unit_name):
        if ('.' in unit_name and unit_name[-1] == '1') or (
                unit_name[-1] == '1' and '.' not in unit_name and "4" in self.bts.side):
            # Fullrack location is 0x22 ABIA2.1 OR location is 0x22 ABIA1, right
            nmbr = '34'
        elif ('.' in unit_name and unit_name[-1] == '2') or (
                unit_name[-1] == '2' and '.' not in unit_name and "4" in self.bts.side):
            # Fullrack location is 0x23 ABIA2.2 OR location is 0x22 ABIA2, right
            nmbr = '35'
        elif ('.' in unit_name and unit_name[-1] == '3') or (
                unit_name[-1] == '3' and '.' not in unit_name and "4" in self.bts.side):
            # Fullrack location is 0x24 ABIA2.3 OR location is 0x22 ABIA3, right
            nmbr = '36'
        elif unit_name[-1] == '1' and "2" in self.bts.side:
            nmbr = '50'
        elif unit_name[-1] == '2' and "2" in self.bts.side:
            nmbr = '51'
        elif unit_name[-1] == '3' and "2" in self.bts.side:
            nmbr = '52'
        elif unit_name[-1] == '1':  # location is 0x12 ABIA1, left
            nmbr = '18'
        elif unit_name[-1] == '2':  # location is 0x13 ABIA2, left
            nmbr = '19'
        elif unit_name[-1] == '3':  # location is 0x14 ABIA3, left
            nmbr = '20'
        return nmbr

    @staticmethod
    def _get_asc_location(nmbr, unit_name):
        if "1" in unit_name:
            nmbr = '16'
        return nmbr

    def _get_fbb_location(self, nmbr, unit_name):
        if ("1" in unit_name or "2" in unit_name) and "2" in self.bts.side:
            nmbr = "51"
        elif "1" in unit_name:  # location is 0x13 (19 as decimal)
            nmbr = "19"
        elif "2" in unit_name:  # location is 0x14 (20 as decimal)
            nmbr = '20'
        return nmbr
