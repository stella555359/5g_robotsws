def _convert_binary_string_to_int(bin_str):
    if bin_str is not None:
        return int(str(bin_str), 2)
    else:
        return None


def _hex_to_bin(hexval):
    thelen = len(hexval) * 4
    binval = bin(int(hexval, 16))[2:]
    while ((len(binval)) < thelen):
        binval = '0' + binval
    return binval


class MobilityParameters:
    def __init__(self, hex_ie):
        """
        Based on LTE_CP_67309
        :param hex_ie: mobilityParameters IE in hex string. (without 0x at the beggining)
        :return:
        """
        self.hex_string = hex_ie
        self.binary_string = _hex_to_bin(self.hex_string)
        self.mobility_parameters_struct = [
            {"Index": 1, "IE": "RecordType", "Length": 8, "Including_IE": False, "Value": None},
            {"Index": 2, "IE": "SIDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 3, "IE": "SID", "Length": 15, "Including_IE": False, "Value": None},
            {"Index": 4, "IE": "NIDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 5, "IE": "NID", "Length": 16, "Including_IE": False, "Value": None},
            {"Index": 6, "IE": "MULT_SIDSIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 7, "IE": "MULT_SIDs", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 8, "IE": "MULT_NIDSIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 9, "IE": "MULT_NIDS", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 10, "IE": "REG_ZONEIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 11, "IE": "REG_ZONE", "Length": 12, "Including_IE": False, "Value": None},
            {"Index": 12, "IE": "TOTAL_ZONESIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 13, "IE": "TOTAL_ZONES", "Length": 3, "Including_IE": False, "Value": None},
            {"Index": 14, "IE": "ZONE_TIMERIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 15, "IE": "ZONE_TIMER", "Length": 3, "Including_IE": False, "Value": None},
            {"Index": 16, "IE": "PACKET_ZONE_IDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 17, "IE": "PZIDHystParametersIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 18, "IE": "P_REVIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 19, "IE": "P_REV", "Length": 8, "Including_IE": False, "Value": None},
            {"Index": 20, "IE": "MIN_P_REVIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 21, "IE": "MIN_P_REV", "Length": 8, "Including_IE": False, "Value": None},
            {"Index": 22, "IE": "NEG_SLOT_CYCLE_INDEX_SUPIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 23, "IE": "ENCRYPT_MODEIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 24, "IE": "ENC_SUPPORTEDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 25, "IE": "SIG_ENCRYPT_SUPIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 26, "IE": "MSG_INTEGRITY_SUPIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 27, "IE": "SIG_INTEGRITY_SUP_INCLIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 28, "IE": "SIG_INTEGRITY_SUPIncluded", "Length": 1, "Including_IE": False, "Value": None},

            {"Index": 29, "IE": "AUTHIncluded", "Length": 1, "Including_IE": True, "Value": None},
            {"Index": 30, "IE": "AUTH", "Length": 2, "Including_IE": False, "Value": None},
            {"Index": 31, "IE": "MAX_NUM_ALT_SOIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 32, "IE": "MAX_NUM_ALT_SO", "Length": 3, "Including_IE": False, "Value": None},
            {"Index": 33, "IE": "USE_SYNC_IDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 34, "IE": "MS_INIT_POS_LOC_SUP_INDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 35, "IE": "MOB_QOSIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 36, "IE": "BAND_CLASS_INFO_REQIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 37, "IE": "BAND_CLASSIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 38, "IE": "BAND_CLASSIncluded", "Length": 5, "Including_IE": False, "Value": None},
            {"Index": 39, "IE": "BYPASS_REG_INDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 40, "IE": "ALT_BAND_CLASSIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 41, "IE": "MAX_ADD_SERV_INSTANCEIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 42, "IE": "HOME_REGIncluded", "Length": 1, "Including_IE": True, "Value": None},
            {"Index": 43, "IE": "HOME_REG", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 44, "IE": "FOR_SID_REGIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 45, "IE": "FOR_SID_REG", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 46, "IE": "FOR_NID_REGIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 47, "IE": "FOR_NID_REG", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 48, "IE": "POWER_UP_REGIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 49, "IE": "POWER_UP_REG", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 50, "IE": "POWER_DOWN_REGIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 51, "IE": "POWER_DOWN_REG", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 52, "IE": "PARAMETER_REGIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 53, "IE": "PARAMETER_REG", "Length": 1, "Including_IE": False, "Value": None},

            {"Index": 54, "IE": "REG_PRDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 55, "IE": "REG_PRD", "Length": 7, "Including_IE": False, "Value": None},
            {"Index": 56, "IE": "REG_DISTIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 57, "IE": "PREF_MSID_TYPEIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 58, "IE": "PREF_MSID_TYPE", "Length": 2, "Including_IE": False, "Value": None},
            {"Index": 59, "IE": "EXT_PREF_MSID_TYPEIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 60, "IE": "MEID_REQDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 61, "IE": "MCCIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 62, "IE": "MCC", "Length": 10, "Including_IE": False, "Value": None},
            {"Index": 63, "IE": "IMSI_11_12Included", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 64, "IE": "IMSI_11_12", "Length": 7, "Including_IE": False, "Value": None},
            {"Index": 65, "IE": "IMSI_T_SUPPORTEDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 66, "IE": "IMSI_T_SUPPORTED", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 67, "IE": "RECONNECT_MSG_INDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 68, "IE": "RER_MODE_SUPPORTEDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 69, "IE": "TKZ_MODE_SUPPORTEDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 70, "IE": "TKZ_IDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 71, "IE": "PILOT_REPORTIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 72, "IE": "PILOT_REPORTIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 73, "IE": "AUTO_FCSO_ALLOWEDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 74, "IE": "SDB_IN_RCNM_INDIncluded", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 75, "IE": "FPC_FCH_Included", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 76, "IE": "FPC_FCH_INIT_SETPT_RC3", "Length": 8, "Including_IE": False, "Value": None},
            {"Index": 77, "IE": "FPC_FCH_INIT_SETPT_RC4", "Length": 8, "Including_IE": False, "Value": None},
            {"Index": 78, "IE": "FPC_FCH_INIT_SETPT_RC5", "Length": 8, "Including_IE": False, "Value": None},
            {"Index": 79, "IE": "FPC_FCH_INIT_SETPT_RC11", "Length": 8, "Including_IE": False, "Value": None},
            {"Index": 80, "IE": "FPC_FCH_INIT_SETPT_RC11", "Length": 8, "Including_IE": False, "Value": None},
            {"Index": 81, "IE": "T_ADD_Included", "Length": 1, "Including_IE": False, "Value": None},

            {"Index": 82, "IE": "PILOT_INC_Included", "Length": 1, "Including_IE": True, "Value": None},
            {"Index": 83, "IE": "PILOT_INC", "Length": 4, "Including_IE": False, "Value": None},
            {"Index": 84, "IE": "RAND_Included", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 85, "IE": "LP_SEC_Included", "Length": 1, "Including_IE": True, "Value": None},
            {"Index": 86, "IE": "LP_SEC", "Length": 8, "Including_IE": False, "Value": None},
            {"Index": 87, "IE": "LTM_OFF_Included", "Length": 1, "Including_IE": True, "Value": None},
            {"Index": 88, "IE": "LTM_OFF", "Length": 6, "Including_IE": False, "Value": None},
            {"Index": 89, "IE": "DAYLT_Included", "Length": 1, "Including_IE": True, "Value": None},
            {"Index": 90, "IE": "DAYLT", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 91, "IE": "GCSNAL2AckTimer_Included", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 92, "IE": "GCSNAL2AckTimer", "Length": 8, "Including_IE": False, "Value": None},
            {"Index": 93, "IE": "GCSNASequenceContextTimer_Include", "Length": 1, "Including_IE": False, "Value": None},
            {"Index": 94, "IE": "GCSNASequenceContextTimer", "Length": 8, "Including_IE": False, "Value": None}
        ]
        self._load_bin_data_to_mobility_parameters_ie()

    def _load_bin_data_to_mobility_parameters_ie(self):
        iterator_index = 0
        fill_next_ie = True
        for ie in self.mobility_parameters_struct:
            if fill_next_ie:
                if ie["Including_IE"] and self.binary_string[iterator_index] == "0":
                    fill_next_ie = False
                ie["Value"] = self.binary_string[iterator_index: iterator_index + ie["Length"]]
                iterator_index += ie["Length"]
            else:
                fill_next_ie = True

    def get_ie_value(self, ie_name, convert_to_int=True):
        for ie in self.mobility_parameters_struct:
            if ie["IE"] == ie_name:
                if convert_to_int:
                    return _convert_binary_string_to_int(ie["Value"])
                else:
                    return ie["Value"]
        raise KeyError

    def get_lp_sec(self):
        return self.get_ie_value("LP_SEC")

    def get_ltm_off(self):
        return self.get_ie_value("LTM_OFF")

    def get_daylt(self):
        return self.get_ie_value("DAYLT")

    def print_mobility_parameters_struct(self):
        for ie in self.mobility_parameters_struct:
            print("%s: %s = %s" % (ie["Index"], ie["IE"], _convert_binary_string_to_int(ie["Value"])))
            print("\n")


if __name__ == '__main__':
    mob_ie = MobilityParameters("0080018000fc002248542405808075fc039ffffe009818181818089494cac8")
    print(mob_ie.print_mobility_parameters_struct())
