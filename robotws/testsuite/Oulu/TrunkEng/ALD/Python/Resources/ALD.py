from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.ALD.Python.Resources.LNA import LNA
from testsuite.Oulu.TrunkEng.ALD.Python.Resources.ALDExceptions import UnallowedState


class MHADetails:

    def __init__(self):
        self.name = ""
        self.serial_number = ""
        self.product_code = ""
        self.lnas = []
        self.operating_mode = ""
        self.uncommissioned = False
        self.ret = False
        self.status = None
        self.antl_list = None


class SbtsAldMha:

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.alarms = BuiltIn().get_library_instance("ALARMS")
        self.lna = LNA()

    def find_bts_related_mha_units(self, prints=True):
        """
        Finds all MHA objects from BTS and returns them as a list. Returns RET units separately in ret_units list.

        :return List[MHA], list[RET]: list of MHA objects, list of RET objects
        """
        mha_units = []
        ret_units = []
        mhas = self._get_mha_tuples()
        for config_mha, runtime_mha, mha_object in mhas:
            mha = MHADetails()
            params = mha_object["parameters"]
            mha.serial_number = params["serialNumber"]
            mha.product_code = params["productCode"]
            mha.operating_mode = params["controlProtocol"]
            if params["mhaType"] and "UNCOMMISSIONED" not in config_mha:
                self._get_lnas_and_handle_mha(mha, params, config_mha, mha_units, prints=prints)
            elif "UNCOMMISSIONED" in config_mha:
                self._handle_uncommissioned_mha(mha, mha_units, params, config_mha)
            else:
                self._handle_ret(mha, params, runtime_mha, config_mha, ret_units)
        return mha_units, ret_units

    def check_mha_states(self, wanted_state, antennaline, lna="", both_lnas=True, only_wanted_state=False):
        """
        Checks the states of MHAs (and if given, RET units)

        :param str wanted_state: Wanted state of MHA, can be OK, degraded, failed, not installed, dependency, off line
        :param antennaline: e.g. RMOD-x/ANTL-x
        :param lna: lna1 or lna2 for ALDEmulator
        :param both_lnas: If true, checks both emulator related lnas
        :param only_wanted_state: If true, overrides wanted_state check based on cablinkType
        """
        success = True
        mha_units, ret_units = self.find_bts_related_mha_units()
        for mha in mha_units:
            formatted_lna = self._check_given_lna(lna, uncommissioned=mha.uncommissioned)
            if not mha.uncommissioned and not mha.ret:
                success = (self._mha_status_handling(antennaline, mha, wanted_state, both_lnas, given_lna=formatted_lna)
                           and success)
            elif mha.uncommissioned:
                modified_wanted_state = "not installed" if wanted_state == "power off" else wanted_state
                success = (self._mha_status_handling(antennaline, mha, modified_wanted_state, both_lnas,
                                                     given_lna=formatted_lna) and success)
        if ret_units:
            success = self._ret_status_handling(ret_units, antennaline, wanted_state,
                                                only_wanted_state=only_wanted_state) and success
        if not success:
            raise UnallowedState

    def find_unit_paths_for_ret(self, antennaline, ret_units):
        """
        Finds unit paths for RET units
        """
        unit_paths = []
        for ret in ret_units:
            if antennaline in ret.name:
                rets = self._get_objects("RETU_A")
                ret_name_for_comparison = ret.name.split("/")[-1]
                for retu in rets:
                    ret_dn = retu["distName"].replace("_A", "")
                    if ret_name_for_comparison in ret_dn:
                        ret_dn = ret_dn.split("/")
                        unit_path = "[{}] {}/{}/{}/{}/{}".format(self.bts.bts_name, ret_dn[-5], ret_dn[-4], ret_dn[-3],
                                                                 ret_dn[-2], ret_dn[-1])
                        if unit_path not in unit_paths:
                            unit_paths.append(unit_path)
        return unit_paths

    def add_10_alarm_for_ald(self, antennaline, add_to_allowed_alarms=False, skip_rets=False,
                             skip_normals=False, runtime_alarm_ret=False):

        """
        Adds 10 alarm for ald, in case of External or Uncommissioned LNAs, severity is minor (7652).
        For RET units, if RET is an external RET, severity is minor (7652)

        :param antennaline: RMOD-x/ANTL-x
        :param add_to_allowed_alarms: True if adding alarm to allowed in addition to expected
        :param skip_rets: Temporary fix for changes with RETs
        :param skip_normals: Temporary fix for changes with RETs
        :param runtime_alarm_ret: True if alarm is added during runtime. Temporary fix for changes with RETs
        """
        mha_units, ret_units = self.find_bts_related_mha_units()
        added_lnas = []
        added_rets = []
        info("In ALD, lte441-a is considered to be active to be able to use Degraded cells instead of Faulty cells")
        lte441a_active = True
        if not skip_normals:
            for mha in mha_units:
                for lna in mha.lnas:
                    lna_search = lna.dc if not mha.uncommissioned else lna.dist_name
                    if antennaline in lna_search:
                        # Uncommissioned LNA
                        if not lna.dc and not lna.data:
                            self._add_expected_or_allowed_alarm(add_to_allowed_alarms, "10",
                                                                "Antenna Line Device failure", "7652",
                                                                lna_hw_path=lna.hw_path)
                            added_lnas.append(lna.hw_path)
                            continue
                        lna_unit_paths = self._find_unit_paths_for_lnas(antennaline=antennaline, mha_units=mha_units)
                        for lna_unit_path in lna_unit_paths:
                            if lna_unit_path not in added_lnas:
                                # External LNA
                                if lna.dc and not lna.data:
                                    self._add_expected_or_allowed_alarm(add_to_allowed_alarms, "10",
                                                                        "Antenna Line Device failure",
                                                                        "7652", unit_path=lna_unit_path)
                                    added_lnas.append(lna_unit_path)
                                    break
                                # Normal LNA
                                if lna.dc and lna.data and (lna.unit_path in lna_unit_path):
                                    if not add_to_allowed_alarms:
                                        alarm_info_list = ["7654", "10", "Antenna Line Device failure",
                                                           "Major", lna_unit_path, None]
                                        self.alarms.select_alarming_cells_according_to_commissioning(
                                            list(lna.cells.keys()), alarm_info_list, lte441a_active)
                                    else:
                                        self.alarms.add_allowed_alarm(fault_id="10",
                                                                      fault_name="Antenna Line Device failure",
                                                                      alarm_id="7654", unit_path=lna_unit_path)
                                    added_lnas.append(lna_unit_path)
                                    break

        if ret_units:
            for ret in ret_units:
                result = self._check_cablink_for_ret(ret)
                if (skip_rets and not result) or (not skip_rets and result) or (not skip_rets and not skip_normals):
                    for antl_dn in ret.antl_list:
                        if antennaline in ret.name:
                            split_ret_name = ret.name.split("/")[-1]
                            ret_unit_paths = self.find_unit_paths_for_ret(antennaline=antennaline, ret_units=ret_units)
                            for ret_unit_path in ret_unit_paths:
                                if ret_unit_path not in added_rets:
                                    # External RET
                                    if antl_dn == "external" or runtime_alarm_ret:
                                        if not add_to_allowed_alarms:
                                            if not self.check_lna_alarm_already_added("10",
                                                                                      "Antenna Line Device failure",
                                                                                      ret_unit_path):
                                                self.alarms.add_expected_alarm(fault_id="10",
                                                                               fault_name="Antenna Line Device failure",
                                                                               alarm_id="7652",
                                                                               unit_path=ret_unit_path)
                                        else:
                                            self.alarms.add_allowed_alarm(fault_id="10",
                                                                          fault_name="Antenna Line Device failure",
                                                                          alarm_id="7652", unit_path=ret_unit_path)
                                        added_rets.append(ret_unit_path)
                                        break
                                    # Normal RET
                                    else:
                                        if split_ret_name in ret_unit_path:
                                            self._add_expected_or_allowed_alarm(add_to_allowed_alarms, "10",
                                                                                "Antenna Line Device failure", "7654",
                                                                                unit_path=ret_unit_path)
                                            added_rets.append(ret_unit_path)
                                            break
        self.remove_duplicate_alarms()

    def _add_expected_or_allowed_alarm(self, add_to_allowed_alarms, fault_id, fault_name, alarm_id, unit_path=None,
                                       lna_hw_path=None):
        if not add_to_allowed_alarms:
            self.alarms.add_expected_alarm(fault_id=fault_id, fault_name=fault_name, alarm_id=alarm_id,
                                           unit_path=unit_path, hw_path=lna_hw_path)
        else:
            self.alarms.add_allowed_alarm(fault_id=fault_id, fault_name=fault_name, alarm_id=alarm_id,
                                          unit_path=unit_path, hw_path=lna_hw_path)

    @staticmethod
    def check_is_other_lna_external(lna, mha):
        other_lna = mha[0] if lna.name == mha[1].name else mha[1]
        return other_lna if other_lna.dc and not other_lna.data else None

    @staticmethod
    def check_is_other_lna_normal(lna, mha):
        other_lna = mha[0] if lna.name == mha[1].name else mha[1]
        return other_lna if other_lna.dc and other_lna.data else None

    def add_other_lna_alarm(self, lna, mha, fault_id, fault_name, unit_path, lte441a_active, lna_type,
                            second_path=None, emulator_alarm="", severity=""):
        if lna_type == "normal":
            other_lna = self.check_is_other_lna_normal(lna, mha)
        else:
            other_lna = self.check_is_other_lna_external(lna, mha)
        if other_lna and not self.alarms.active_category_alarms:
            if lna_type == "normal":
                alarm_info_list = [emulator_alarm if emulator_alarm else "7654", fault_id, fault_name,
                                   severity if severity else "Major",
                                   second_path if second_path else unit_path, None]
                self.alarms.select_alarming_cells_according_to_commissioning(
                    list(lna.cells.keys()),
                    alarm_info_list,
                    lte441a_active)
            else:
                self.alarms.add_expected_alarm(fault_id=fault_id, fault_name=fault_name,
                                               alarm_id="7652", unit_path=second_path if second_path else unit_path)
            return True

    def check_lna_alarm_already_added(self, fault_id, fault_name, path):
        """
        If category alarms are on and lna has already reported an alarm, then RET should not report another alarm
        """
        if self.alarms.active_category_alarms:
            for alarm in self.alarms.expected_alarms:
                if fault_id in alarm.fault_id and fault_name in alarm.fault_name and path in alarm.unit_path:
                    return True
        return False

    def remove_duplicate_alarms(self):
        duplicates_list = set([x for x in self.alarms.expected_alarms if self.alarms.expected_alarms.count(x) > 1])
        for duplicate in duplicates_list:
            self.alarms.remove_expected_alarms(alarm_id=duplicate.alarm_id, fault_id=duplicate.fault_id,
                                               fault_name=duplicate.fault_name, only_first_alarm=True)

    def add_1834_or_1835_alarm_for_ald(self, antennaline, fault_id, fault_name, add_to_allowed_alarms=False):
        mha_units, ret_units = self.find_bts_related_mha_units()
        info("In ALD, lte441-a is considered to be active to be able to use Degraded cells instead of Faulty cells")
        lte441a_active = True
        added_mhas = []
        for mha in mha_units:
            for lna in mha.lnas:
                lna_search = lna.dc if not mha.uncommissioned else lna.dist_name
                if (antennaline in lna_search) and lna.dc and lna.data:
                    lna_unit_paths = self._find_unit_paths_for_lnas(antennaline=antennaline, mha_units=mha_units)
                    for lna_unit_path in lna_unit_paths:
                        if lna_unit_path not in added_mhas:
                            if not add_to_allowed_alarms:
                                alarm_info_list = ["7654", fault_id, fault_name, "Major", lna_unit_path, None]
                                self.alarms.select_alarming_cells_according_to_commissioning(
                                    list(lna.cells.keys()),
                                    alarm_info_list,
                                    lte441a_active)
                            else:
                                self.alarms.add_allowed_alarm(fault_id=fault_id, fault_name=fault_name,
                                                              alarm_id="7654", unit_path=lna_unit_path)
                            added_mhas.append(lna_unit_path)
                            break
        self.remove_duplicate_alarms()

    def add_1836_alarm_for_ald(self, antennaline, fault_id, fault_name, add_to_allowed_alarms=False):
        """
        Adds 1836 cleware alarm, alarm_id is 7654 in all cases because it won't be converted to 7113 if alarm_id is 7652
        """
        mha_units, ret_units = self.find_bts_related_mha_units()
        added_antls_not_ret = []
        added_antls = []
        all_ext = self._go_through_mhas_connected_to_antennaline_and_check_if_all_are_ext(antennaline, mha_units)
        antl_unit_paths = self._find_unit_paths_for_antl(antennaline=antennaline)
        for antl_unit_path in antl_unit_paths:
            if antl_unit_path not in added_antls_not_ret:
                if all_ext:
                    self.alarms.add_expected_alarm(fault_id=fault_id, fault_name=fault_name,
                                                   alarm_id="7652",
                                                   severity="Minor", unit_path=antl_unit_path)
                    self.alarms.add_allowed_alarm(fault_id=fault_id, fault_name=fault_name,
                                                  alarm_id="7654", unit_path=antl_unit_path)
                else:
                    self.alarms.add_expected_alarm(fault_id=fault_id, fault_name=fault_name,
                                                   alarm_id="7654",
                                                   severity="Major", unit_path=antl_unit_path)
                    self.alarms.add_allowed_alarm(fault_id=fault_id, fault_name=fault_name,
                                                  alarm_id="7652", unit_path=antl_unit_path)
                added_antls_not_ret.append(antl_unit_path)

        if ret_units:
            for ret in ret_units:
                for antl_dn in ret.antl_list:
                    if antennaline in ret.name:
                        antl_unit_paths = self._find_unit_paths_for_antl(antennaline=antennaline)
                        for antl_unit_path in antl_unit_paths:
                            if antl_unit_path not in added_antls:
                                if antl_dn == "external":
                                    if not add_to_allowed_alarms:
                                        if not self.check_lna_alarm_already_added(fault_id, fault_name, antl_unit_path):
                                            self.alarms.add_expected_alarm(fault_id=fault_id, fault_name=fault_name,
                                                                           alarm_id="7652", unit_path=antl_unit_path)
                                    else:
                                        self.alarms.add_allowed_alarm(fault_id=fault_id, fault_name=fault_name,
                                                                      alarm_id="7652", unit_path=antl_unit_path)
                                    added_antls.append(antl_unit_path)
                                    break
                                else:
                                    self._add_expected_or_allowed_alarm(add_to_allowed_alarms, fault_id, fault_name,
                                                                        "7654", unit_path=antl_unit_path)
                                    added_antls.append(antl_unit_path)
        self.remove_duplicate_alarms()

    def add_emulator_alarm(self, antennaline, fault_id, fault_name, given_lna,
                           second_given_lna=None, add_to_allowed_alarms=False):
        """
        This function adds alarms related to ALDEmulator. You can give this function either one or two LNAs.
        Depending on second_given_lna, this function will add alarm for just one LNA or both LNAs.
        Adds only one alarm by default
        """
        added_lnas = []
        mha_units, _ = self.find_bts_related_mha_units()
        first_lna_unit_path = self._find_unit_path_for_lna(antennaline, mha_units, given_lna=given_lna)
        second_lna_unit_path = ""
        second_lna_form = ""
        info("In ALD, lte441-a is considered to be active to be able to use Degraded cells instead of Faulty cells")
        lte441a_active = True
        if second_given_lna:
            second_lna_unit_path = self._find_unit_path_for_lna(antennaline, mha_units, checked_lna=first_lna_unit_path,
                                                                given_lna=second_given_lna)
        for mha in mha_units:
            first_lna_form = self._check_given_lna(given_lna, uncommissioned=mha.uncommissioned)
            if second_given_lna:
                second_lna_form = self._check_given_lna(second_given_lna, uncommissioned=mha.uncommissioned)
            for lna in mha.lnas:
                lna_search = lna.dc if not mha.uncommissioned else lna.dist_name
                if antennaline in lna_search:
                    if first_lna_form in lna.dist_name:
                        # Uncommissioned LNA
                        if not lna.dc and not lna.data:
                            self._emulator_alarm_addition_and_conditions(lna, fault_id, fault_name,
                                                                         add_to_allowed_alarms, mha, lte441a_active,
                                                                         unit_path=lna.hw_path)
                            added_lnas.append(first_lna_unit_path)
                        if first_lna_unit_path not in added_lnas:
                            should_break = self._emulator_alarm_addition_and_conditions(lna, fault_id, fault_name,
                                                                                        add_to_allowed_alarms, mha,
                                                                                        lte441a_active,
                                                                                        unit_path=first_lna_unit_path,
                                                                                        second=second_lna_unit_path)
                            added_lnas.append(first_lna_unit_path)
                            if should_break:
                                break
                            else:
                                continue
                    elif second_given_lna and second_lna_form in lna.dist_name:
                        if second_lna_unit_path not in added_lnas:
                            should_break = self._emulator_alarm_addition_and_conditions(lna, fault_id, fault_name,
                                                                                        add_to_allowed_alarms, mha,
                                                                                        lte441a_active,
                                                                                        unit_path=second_lna_unit_path,
                                                                                        second=first_lna_unit_path)
                            added_lnas.append(second_lna_unit_path)
                            if should_break:
                                break
                            else:
                                continue
        self.remove_duplicate_alarms()

    def check_if_tested_antennaline_has_cell_effects_on_tested_cells(self, antennaline):
        mha_units, ret_units = self.find_bts_related_mha_units(prints=False)
        cell_effects = False
        for mha in mha_units:
            if not mha.uncommissioned:
                for lna in mha.lnas:
                    if (lna.dc and lna.data) and antennaline in lna.dc:
                        cell_effects = True

        if ret_units:
            for ret in ret_units:
                for antl_dn in ret.antl_list:
                    if antennaline in ret.name:
                        if antl_dn != "external":
                            cell_effects = True
        return cell_effects

    @staticmethod
    def _go_through_mhas_connected_to_antennaline_and_check_if_all_are_ext(antennaline, mha_units):
        normal_lnas = []
        for mha in mha_units:
            for lna in mha.lnas:
                if antennaline in lna.dist_name:
                    if lna.dc and lna.data:
                        normal_lnas.append(lna.dist_name)
        return True if not normal_lnas else False

    def _find_unit_path_for_lna(self, antennaline, mha_units, checked_lna=None, given_lna=None):
        """
        Used for MHAEmulator
        :param antennaline:
        :param mha_units:
        :param checked_lna:
        :param given_lna:
        :return:
        """
        for mha in mha_units:
            formatted_lna = self._check_given_lna(given_lna, uncommissioned=mha.uncommissioned)
            for lna in mha.lnas:
                if not mha.uncommissioned:
                    lna_search = lna.dc
                else:
                    lna_search = lna.dist_name
                if antennaline in lna_search:
                    if formatted_lna and not mha.uncommissioned:
                        if formatted_lna in lna.unit_path:
                            if checked_lna:
                                unit_path = "[{}] {}".format(self.bts.bts_name, lna.unit_path)
                                if unit_path != checked_lna:
                                    return unit_path
                                else:
                                    break
                            else:
                                unit_path = "[{}] {}".format(self.bts.bts_name, lna.unit_path)
                                return unit_path
                    else:
                        if checked_lna:
                            unit_path = "[{}] {}".format(self.bts.bts_name, lna.unit_path)
                            if unit_path != checked_lna:
                                return unit_path

                        else:
                            unit_path = "[{}] {}".format(self.bts.bts_name, lna.unit_path)
                            return unit_path

    def _find_unit_paths_for_lnas(self, antennaline, mha_units, given_lna=None):
        unit_paths = []
        for mha in mha_units:
            formatted_lna = self._check_given_lna(given_lna, uncommissioned=mha.uncommissioned)
            for lna in mha.lnas:
                if antennaline in lna.dc:
                    if formatted_lna:
                        if formatted_lna in lna.unit_path:
                            unit_path = "[{}] {}".format(self.bts.bts_name, lna.unit_path)
                            if unit_path not in unit_paths:
                                unit_paths.append(unit_path)
                            else:
                                break
                    else:
                        unit_path = "[{}] {}".format(self.bts.bts_name, lna.unit_path)
                        if unit_path not in unit_paths:
                            unit_paths.append(unit_path)
                        else:
                            break
        return unit_paths

    def _find_unit_paths_for_antl(self, antennaline):
        """
        Used to find unit paths for alarms going through antennalines
        """
        unit_paths = []
        for antenna in self.bts.antennae:
            antenna_dist_name = antenna.dist_name
            if antennaline in antenna_dist_name:
                antl_unit_path = "[{}] {}".format(self.bts.bts_name, antenna_dist_name)
                if antl_unit_path not in unit_paths:
                    unit_paths.append(antl_unit_path)
        return unit_paths

    def _emulator_alarm_addition_and_conditions(self, lna, fault_id, fault_name, add_to_allowed_alarms, mha,
                                                lte441a_active, unit_path, second=None):
        """
        Checks which type of LNA the LNA is and sets alarm_id for normal LNAs, and 7652 (minor) for
        external or uncommissioned LNAs
        """
        no_cells_alarms = ["1871", "1872", "1873", "1874"]
        # Normal LNA
        should_break = False
        alarm_id = "7655" if fault_id in no_cells_alarms or not lna.cells else "7654"
        severity = "Major" if alarm_id == "7654" else "Minor"
        if lna.dc and lna.data:
            if not add_to_allowed_alarms:
                if second:
                    should_break = self.add_other_lna_alarm(lna, mha.lnas, fault_id, fault_name, unit_path,
                                                            lte441a_active, "external", second_path=second,
                                                            emulator_alarm=alarm_id, severity=severity)
                if fault_id not in no_cells_alarms:
                    alarm_info_list = [alarm_id, fault_id, fault_name, severity, unit_path, None]
                    self.alarms.select_alarming_cells_according_to_commissioning(
                        list(lna.cells.keys()),
                        alarm_info_list,
                        lte441a_active)
                else:
                    self.alarms.add_expected_alarm(fault_id=fault_id, fault_name=fault_name,
                                                   alarm_id=alarm_id, unit_path=unit_path)
            else:
                self.alarms.add_allowed_alarm(fault_id=fault_id, fault_name=fault_name, unit_path=unit_path)
            return should_break
        # External LNA
        elif lna.dc and not lna.data:
            if not add_to_allowed_alarms:
                if second:
                    should_break = self.add_other_lna_alarm(lna, mha.lnas, fault_id, fault_name, unit_path,
                                                            lte441a_active, "normal", second_path=second,
                                                            emulator_alarm=alarm_id, severity=severity)
                self.alarms.add_expected_alarm(fault_id=fault_id, fault_name=fault_name,
                                               alarm_id="7652", unit_path=unit_path)
            else:
                self.alarms.add_allowed_alarm(fault_id=fault_id, fault_name=fault_name, unit_path=unit_path)
            return should_break
        # Uncommissioned MHA
        elif not lna.dc and not lna.data:
            if not add_to_allowed_alarms:
                self.alarms.add_expected_alarm(fault_id=fault_id, fault_name=fault_name,
                                               alarm_id="7652", hw_path=unit_path)
            else:
                self.alarms.add_allowed_alarm(fault_id=fault_id, fault_name=fault_name, hw_path=unit_path)
            return False

    @staticmethod
    def _check_given_lna(given_lna, uncommissioned=False):
        """
        Checks given lna for ALDEmulator, given_lna is either lna1 or lna2
        """
        if given_lna:
            if given_lna == "lna1":
                return "LNA_R-1" if uncommissioned else "LNA-1"
            elif given_lna == "lna2":
                return "LNA_R-2" if uncommissioned else "LNA-2"

    @staticmethod
    def _check_status_and_print_info(ald_unit, wanted_state, ald="LNA"):
        """
        Checks status and prints information in _status_handling
        :param ald_unit: LNA or RET object
        :param wanted_state: Can be OK, degraded, failed, not installed, dependency or off line
        :param str ald: LNA or RET
        :returns: True if status is OK, False otherwise
        """
        name = ald_unit.dist_name if ald == "LNA" else ald_unit.name
        if ald_unit.status == wanted_state:
            info(f"CORRECT {ald} STATUS, {name} status is {ald_unit.status}, wanted state is: {wanted_state}")
            return True
        else:
            error(f"INCORRECT {ald} STATUS, {name} Status is: {ald_unit.status}, wanted state is: {wanted_state}")
            return False

    def _mha_status_handling(self, antennaline, mha, wanted_state,  both_lnas, given_lna=""):
        """
        Handles checks and output for LNA statuses

        :param antennaline: RMOD-x/ANTL-x
        :param MHADetails mha: MHA object
        :param string wanted_state: can be OK, degraded, failed, not installed, dependency or off line
        :param given_lna: Either lna1 or lna2 for ALDEmulator
        :param both_lnas: Checks both lnas for ALDEmulator, used in returncode tests
        :raises UnallowedState: If MHA state is incorrect
        """
        checked_lnas = []
        correct_status = True
        rf_from_antl = antennaline.split("/")[0]
        for lna in mha.lnas:
            if lna.dist_name not in checked_lnas:
                lna_search = lna.dc if not mha.uncommissioned else lna.dist_name
                if antennaline in lna_search:
                    if given_lna:
                        if given_lna in lna.dist_name:
                            correct_status = self._check_status_and_print_info(lna, wanted_state) and correct_status
                        else:
                            correct_status = (self._check_status_and_print_info(lna, wanted_state="OK")
                                              and correct_status)
                    elif both_lnas:
                        correct_status = (self._check_status_and_print_info(lna, wanted_state)
                                          and correct_status)
                    else:
                        error(f"Status check is skipped for {lna.name} ({lna.dist_name})")
                else:
                    if rf_from_antl in lna_search and wanted_state == "dependency":  # In case of RF lock
                        correct_status = (self._check_status_and_print_info(lna, wanted_state=wanted_state)
                                          and correct_status)
                    else:
                        correct_status = self._check_status_and_print_info(lna, wanted_state="OK") and correct_status
                checked_lnas.append(lna.dist_name)
        return correct_status

    def _check_cablink_for_ret(self, ret):
        radio_connected_to_ret = ret.name.split("/")[0]
        for radio in self.bts.radios:
            if radio_connected_to_ret in radio.scf_dist_name:
                # Returns False if RP3_01Link, True if EthLink or CPRILink
                return radio.cablink_type != "RP3_01Link"

    def _ret_status_handling(self, ret_units, antennaline, wanted_state, only_wanted_state=False):
        success = True
        for ret in ret_units:
            if antennaline in ret.name:
                # If cablinkType of radio connected to RET is RP3_01Link (OBSAI radio) wanted_state == wanted_state,
                # otherwise (CPRI-n or eCPRI radios) wanted_state == "OK"
                wanted_state_is_ok = self._check_cablink_for_ret(ret)
                if wanted_state_is_ok:
                    # After RF Lock/Unlock/Reset, RET statuses connected to CPRI radios are wanted_state == wanted_state
                    if not only_wanted_state:
                        success = self._check_status_and_print_info(ret, "OK", "RET") and success
                    else:
                        success = self._check_status_and_print_info(ret, wanted_state, "RET") and success
                else:
                    success = self._check_status_and_print_info(ret, wanted_state, "RET") and success
            else:
                success = self._check_status_and_print_info(ret, "OK", "RET") and success
        return success

    def _get_lnas_and_handle_mha(self, mha, params, config_mha, mha_units, prints=True):
        """
        Handles non-RET and commissioned MHAs

        :param MHADetails mha: MHA object
        :param obj params: Index of _get_objects("ALD_R")
        :param config_mha: configured MHA distname
        :param mha_units: List of MHA units
        """
        printed_lnas = []
        mha.name = config_mha
        self._check_mha_status(mha, params)
        lnas = self.lna.find_lnas_from_bts()
        for lna in lnas:
            if config_mha in lna.dist_name:
                mha.lnas.append(lna)
                if lna.dist_name not in printed_lnas:
                    if prints:
                        self.lna.print_lna_details(lna)
                    printed_lnas.append(lna.dist_name)
        mha_units.append(mha)
        self._print_mha_details(mha)

    def _link_rmod_antl_to_ret(self, runtime_mha, config_mha):
        """
        Links RMODs and ANTLs to ALD for RET unit

        :param runtime_mha:
        :param config_mha:
        :returns: e.g. RMOD-x/ANTL-x/ALD-x
        """
        loglinks = self._get_objects("LOGLINK_R")
        radios = self.lna.rmod.get_radio_dist_names()
        for config_radio, runtime_radio in radios:
            for loglink in loglinks:
                first_endpoint = loglink["parameters"]["firstEndpointDN"]
                second_endpoint = loglink["parameters"]["secondEndpointDN"]
                if runtime_mha in first_endpoint or runtime_mha in second_endpoint:
                    if runtime_radio in first_endpoint or runtime_radio in second_endpoint:
                        return "{}/{}".format(config_radio, config_mha)

    def _handle_ret(self, mha, params, runtime_mha, config_mha, ret_units):
        """
        Handles RET units

        :param MHADetails mha: MHA object
        :param params: Index of _get_objects("ALD_R")
        :param config_mha: E.g. ALD-x
        :param ret_units: List of RET units
        """
        mha.ret = True
        mha.name = self._link_rmod_antl_to_ret(runtime_mha, config_mha)
        mha.antl_list = self._check_external_ret(config_mha)
        self._check_mha_status(mha, params)
        ret_units.append(mha)
        self._print_mha_details(mha)

    def _check_external_ret(self, config_mha):
        antenna_dist_names = []
        rets = self._get_objects("RETU_A")
        for ret in rets:
            ret_dn = ret["distName"].replace("_A", "")
            if config_mha in ret_dn:
                antenna_dn_list = ret["parameters"]["antlDNList"]
                for antenna_dn in antenna_dn_list:
                    if "external" not in antenna_dn:
                        antenna_dn = antenna_dn.replace("_A", "")
                        antenna_dist_names.append(antenna_dn)
                    else:
                        antenna_dist_names.append(antenna_dn)
        return antenna_dist_names

    def _handle_uncommissioned_mha(self, mha, mha_units, params, config_mha):
        """
        Gets and sets information about uncommissioned MHA (and LNAs)

        :param MHADetails mha: MHA object
        :param mha_units: List of MHA objects
        :param params: Index of _get_objects("ALD_R")
        :param config_mha: E.g. UNCOMMISSIONED (ALD_R-x)
        """
        added_lnas = []
        mha.uncommissioned = True
        mha.name = config_mha
        info("LNA statuses for {}".format(config_mha))
        mha_to_be_given = config_mha.strip("UNCOMMISSIONED ()")
        lnas = self.lna.find_lnas_from_bts(uncommissioned=True, given_mha=mha_to_be_given)
        for lna in lnas:
            if "LNA_R" in lna.dist_name and lna.dist_name not in added_lnas:
                added_lnas.append(lna.dist_name)
                mha.lnas.append(lna)
                self.lna.print_lna_details(lna)
        self._check_mha_status(mha, params)
        mha_units.append(mha)
        self._print_mha_details(mha)

    @staticmethod
    def _check_mha_status(mha, params):
        """
        Checks status of MHA

        :param MHADetails mha: MHA object
        :param obj params: index of _get_objects("ALD_R")
        """
        if params["availabilityStatus"] is None:
            mha.status = "OK"
        else:
            mha.status = params["availabilityStatus"]

    @staticmethod
    def _print_mha_details(mha):
        info("status: {}, name: {}, lnas: {}, operating mode: {}, uncommissioned: {}, ret: {},"
             " serial number: {}, product code: {}, antl list: {}".format(mha.status, mha.name,
                                                                          [lna.name for lna in mha.lnas],
                                                                          mha.operating_mode,
                                                                          mha.uncommissioned, mha.ret,
                                                                          mha.serial_number,
                                                                          mha.product_code, mha.antl_list))

    def _get_objects(self, obj):
        objects = self.admin.get_managed_objects(obj, timeout=10)
        return objects

    def _get_mha_tuples(self):
        """
        Gets information about MHA from get_managed_objects()

        :return List[Tuple(str, str, Any)]:
        ((configured MHA distname or UNCOMMISSIONED (ALD_R-x)), runtime MHA distname, MHA object)
        """
        mha_tuples = []
        mhas = self._get_objects("ALD_R")
        for mha in mhas:
            params = mha["parameters"]
            if params["configDN"] is not None:
                runtime_dist_name = mha["distName"].split("/")
                runtime_dist_name = runtime_dist_name[-1]
                config_dist_name = params["configDN"].replace("_A", "")
                config_dist_name = config_dist_name.split("/")
                config_dist_name = config_dist_name[-1]
                mha_tuples.append((config_dist_name, runtime_dist_name, mha))
            else:
                runtime_dist_name = mha["distName"].split("/")
                runtime_dist_name = runtime_dist_name[-1]
                uncommissioned_mha = "UNCOMMISSIONED ({})".format(runtime_dist_name)
                mha_tuples.append((uncommissioned_mha, runtime_dist_name, mha))
        return mha_tuples
