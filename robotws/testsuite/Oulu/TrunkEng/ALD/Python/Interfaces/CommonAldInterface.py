from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import error
from testsuite.Oulu.TrunkEng.ALD.Python.Resources.ALDExceptions import AntennaLineNotFound
from testsuite.Oulu.TrunkEng.ALD.Python.Resources import ALD, AldRMOD, FEG


class CommonAldInterface:

    def __init__(self):
        self.ald = ALD.SbtsAldMha()
        self.bts = BuiltIn().get_library_instance("BTS")
        self.rmod = AldRMOD.AldRMOD()
        self.feg = FEG.FEG()

    def find_bts_related_mha_units(self):
        """
        Finds all MHA objects from BTS and returns them as a list. Returns RET units separately

        :returns List[MHA], List[RET]: List of MHA units and list of RET units
        """
        mha_units, ret_units = self.ald.find_bts_related_mha_units()
        return mha_units, ret_units

    def check_mha_states(self, wanted_state, antennaline, lna="", both_lnas=True, only_wanted_state=False):
        """
        Checks the LNA states from MHAs (and if found, checks RET units' states)

        :param str wanted_state: OK, degraded, failed, not installed, dependency or off line
        :param str antennaline: RMOD-x/ANTL-x
        :param str lna: lna1 or lna2 from ALDEmulator
        :param boolean both_lnas: True if used in ALDEmulator return code related status checks
        :param boolean only_wanted_state: overrides cablinkType check in case of RETs
        """
        self.ald.check_mha_states(wanted_state, antennaline, lna=lna, both_lnas=both_lnas,
                                  only_wanted_state=only_wanted_state)

    def add_10_alarm_for_ald(self, antennaline, add_to_allowed_alarms=False, skip_rets=False,
                             skip_normals=False, runtime_alarm_ret=False):
        """
        Adds expected alarms for all LNAs and RETs that are connected to the antennaline parameter

        :param antennaline: RMOD-x/ANTL-x
        :param add_to_allowed_alarms: True if adding alarm to allowed instead of expected
        :param skip_rets: Temporary fix for changes with RETs
        :param skip_normals: Temporary fix for changes with RETs
        :param runtime_alarm_ret: Temporary fix for changes with RETs
        :return:
        """
        self.ald.add_10_alarm_for_ald(antennaline=antennaline, add_to_allowed_alarms=add_to_allowed_alarms,
                                      skip_rets=skip_rets, skip_normals=skip_normals,
                                      runtime_alarm_ret=runtime_alarm_ret)

    def add_1834_or_1835_alarm_for_ald(self, antennaline, fault_id, fault_name, add_to_allowed_alarms=False):
        """
        Adds expected alarms for given antennaline

        :param antennaline: RMOD-x/ANTL-x
        :param fault_id: e.g. 1834 or 1835
        :param fault_name: e.g. Antenna Line Device failure
        :param add_to_allowed_alarms: True if adding to allowed instead of expected
        :return:
        """
        self.ald.add_1834_or_1835_alarm_for_ald(antennaline=antennaline, fault_id=fault_id, fault_name=fault_name,
                                                add_to_allowed_alarms=add_to_allowed_alarms)

    def add_1836_alarm_for_ald(self, antennaline, fault_id, fault_name, add_to_allowed_alarms=False):
        """
        Adds expected alarms for given antennaline

        :param antennaline: RMOD-x/ANTL-x
        :param fault_id: e.g. 1836
        :param fault_name: e.g. Antenna Line Device failure
        :param add_to_allowed_alarms: True if adding to allowed instead of expected
        :return:
        """
        self.ald.add_1836_alarm_for_ald(antennaline=antennaline, fault_id=fault_id, fault_name=fault_name,
                                        add_to_allowed_alarms=add_to_allowed_alarms)

    def add_emulator_alarm(self, antennaline, fault_id, fault_name, given_lna,
                           second_given_lna=None, add_to_allowed_alarms=False):
        """
        Adds ALDEmulator related alarms.

        :param str antennaline: RMOD-x/ANTL-x
        :param str fault_id: e.g. 1870
        :param str fault_name: e.g. Mast Head Amplifier fault
        :param str given_lna: e.g. lna1 or lna2
        :param (optional) str second_given_lna: used in return code tests, given_lna=lna1, second_given_lna=lna2
        :param (optional) boolean add_to_allowed_alarms: True if adding to allowed alarms instead of expected
        """

        self.ald.add_emulator_alarm(antennaline=antennaline, fault_id=fault_id, fault_name=fault_name,
                                    given_lna=given_lna, second_given_lna=second_given_lna,
                                    add_to_allowed_alarms=add_to_allowed_alarms)

    def reset_radio(self, given_radio):
        """
        Resets the given radio

        :param str given_radio: RMOD-x
        """
        self.rmod.reset_radio(given_radio)

    def lock_radio(self, given_radio):
        """
        Locks the given radio

        :param str given_radio: RMOD-x
        """
        self.rmod.lock_radio(given_radio)

    def unlock_radio(self, given_radio):
        """
        Unlocks the given radio

        :param str given_radio: RMOD-x
        """
        self.rmod.unlock_radio(given_radio)

    def check_radio_statuses(self):
        self.rmod.check_radio_statuses()

    def calculate_and_check_feg(self):
        """
        Calculates FEG and checks if value is OK

        :returns List[Tuple(str, int)]: (antennaline, FEG value)
        """
        feg_tuples = self.feg.calculate_and_check_feg()
        return feg_tuples

    def compare_feg_values(self, feg_before, feg_now, affected_antennalines=None):
        """
        Compares the FEG values between feg_before and feg_now. If affected_antennalines is given,
        FEG values have to change. Otherwise, FEG values are not allowed to change

        :param List[Tuple(str, int)] feg_before: get FEG tuples from calculate_and_check_feg
        :param List[Tuple(str, int)] feg_now: get FEG tuples from calculate_and_check_feg
        :param (Optional) List[str] affected_antennalines: If given, check affected antennalines
        """
        self.feg.compare_feg_values(feg_before, feg_now, affected_antennalines=affected_antennalines)

    def get_antenna_line_object(self, antl):
        """
        Get cells from antenna line.

        :param str antl: Antenna line name, for example, RMOD-1/ANTL-1
        """
        for antenna in self.bts.antennae:
            if antl in antenna.dist_name:
                return antenna
        error(f"Could not find antenna object with name {antl}.")
        raise AntennaLineNotFound(f"Could not find antenna object with name {antl}.")

    def check_if_tested_antennaline_has_cell_effects_on_tested_cells(self, antennaline):
        """
        Checks if tested antennaline connected to MHA/RET has cell effects.
        If the RET/MHA is normal e.g. not EXT/uncommissioned, there should be some cell effects.
        If RET/MHA is EXT/uncommissioned, the cell should have degraded as its availabilityStatus.

        :param str antennaline: RMOD-x/ANTL-x
        """
        return self.ald.check_if_tested_antennaline_has_cell_effects_on_tested_cells(antennaline)
