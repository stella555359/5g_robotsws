from robot.libraries.BuiltIn import BuiltIn
from taf.internal.aliasing.exceptions import AliasLookupError
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, warning, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import EnvironmentIssue, UnexpectedRestartCounterValue


class SMODs:
    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.scf = BuiltIn().get_library_instance("SCF")
        self.bts = None

    def _fill_smod_information(self, smod_mo, smod_mos, realtime_mos, remote=False):
        smod = SCI()
        parameter_dict = smod_mo["parameters"]
        product_name = self.get_smod_name(smod_mo)
        smod.name = product_name + smod_mo["distName"][-1]
        smod.dist_name = smod_mo["distName"]
        smod.serial_number = parameter_dict["serialNumber"]
        smod.master = SMODs.smod_is_master(parameter_dict)
        smod.remote = remote
        for rmo in realtime_mos:
            parameter_d = rmo["parameters"]
            if smod.serial_number == parameter_d["serialNumber"]:
                if len(smod_mos) > 1 and smod.name[-1] != parameter_d["horizontalPosition"]:
                    self.logger.debug(f"{smod.dist_name} {smod.name} {parameter_d['horizontalPosition']}")
                    info(f"Number in SMOD name ({smod.name}) differs from horizontalPosition "
                         f"({parameter_d['horizontalPosition']}), using horizontalPosition as number in the "
                         f"name of SMOD.")
                    smod.name = smod.name[:-1] + str(parameter_d["horizontalPosition"])
                smod.config_dn = parameter_d["configDN"]
                smod.r_dist_name = rmo["distName"]
        return smod

    def get_smod_connections(self):
        smod_mos_remote = None
        realtime_mos_remote = None
        smod_mos = self.admin.get_managed_objects("SMOD_L")
        realtime_mos = self.admin.get_managed_objects("SMOD_R")
        try:  # If RFS in use, remote admin can be found
            smod_mos_remote = self.admin.get_managed_objects("SMOD_L", connection="remote")
            realtime_mos_remote = self.admin.get_managed_objects("SMOD_R", connection="remote")
        except AliasLookupError:  # Not a RFS environment
            pass
        smod_list = []
        for smod_mo in smod_mos:
            smod = self._fill_smod_information(smod_mo, smod_mos, realtime_mos)
            smod_list.append(smod)
        if smod_mos_remote:
            for remote_smod_mo in smod_mos_remote:
                remote_smod = self._fill_smod_information(remote_smod_mo, smod_mos_remote, realtime_mos_remote,
                                                          remote=True)
                smod_list.append(remote_smod)
        return smod_list

    def check_if_position_in_subrack(self, fullrack):
        """
        Checks if positionInSubrack is found from com.nokia.srbts.eqm:SMOD class, for example:
        <p name="positionInSubrack">RightSide</p> and sets parameter position_in_subrack to True of False.

        :param bool fullrack: If fullrack is False, checks if positionInSubrack is found from SMOD class.
        """
        position_in_subrack = ""
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        try:
            if not fullrack:
                # object_distname = self.scf.get_distname_based_on_class("com.nokia.srbts.eqm:SMOD")[0]
                # position_in_subrack =
                # self.scf.get_value_from_scf(dist_name=object_distname, p_name="positionInSubrack")
                for smod in self.bts.bts_info['requestMessage']['systemModules']:
                    if "positionInSubrack" in smod:
                        position_in_subrack = smod["positionInSubrack"]
                self.logger.debug("Value of positionInSubrack: {}".format(position_in_subrack))
                print(f"Value of positionInSubrack: {position_in_subrack}")
                if position_in_subrack:
                    return position_in_subrack
                else:
                    self.logger.debug("positionInSubrack attribute is not found from the SCF file -> side of rack is "
                                      "not shown in alarms")
                    return ""
            else:
                info("Fullrack environment, positionInSubrack is not checked because other SMOD should be Right and "
                     "other Left.")
                return ""
        except IndexError:
            warning("Could not find value of positionInSubrack of com.nokia.srbts.eqm:SMOD class. "
                    "It is not defined.")
            return ""

    def get_master_smod_productname(self, parse_name=True, add_smod_number=True):
        """
        Get Master SMOD ProductName. If fullrack in question returns productName of master smod.
        :param bool parse_name: If set True returns f.ex. ASIA if set False returns  f.ex. ASIA AirScale Common
        :param bool add_smod_number: Default is True, returns for example ASIA1. NOTE parse_name should also be True.
        """
        if add_smod_number and parse_name:
            if not self.bts:
                self.bts = BuiltIn().get_library_instance("BTS")
            for sm in self.bts.smods:
                if sm.master:
                    return sm.name
            error("Master SMOD is not found from self.bts.smods")
            raise EnvironmentIssue
        smod_mos = self.admin.get_managed_objects("SMOD_L")
        if smod_mos:
            for smod_mo in smod_mos:
                parameter_dict = smod_mo["parameters"]
                if "productName" in parameter_dict:
                    if self.smod_is_master(parameter_dict):
                        product_name = parameter_dict["productName"]
                        if "FSMF" in product_name:
                            product_name = "FSMr3"
                        return product_name if not parse_name else product_name.split(" ")[0]
                    else:
                        self.logger.debug(f"Node id {parameter_dict['nodeIdOwn']} is {parameter_dict['productName']} "
                                          f"and it is slave. Node id {parameter_dict['nodeIdMaster']} is master.")
                else:
                    error("productName is not found from SMOD_L -object.")
                    raise EnvironmentIssue
        error("SMOD_L is not found.")
        raise EnvironmentIssue

    @staticmethod
    def get_smod_name(smod_mo):
        """
        Parse SMOD name from productName. If fullrack in question returns productName of master smod.
        """
        parameter_dict = smod_mo["parameters"]
        if "productName" in parameter_dict:
            product_name = parameter_dict["productName"]
            if "FSMF" in product_name:
                product_name = "FSMr3"
            return product_name.split(" ")[0]
        else:
            error("productName is not found from SMOD_L -object.")
            raise EnvironmentIssue

    @staticmethod
    def smod_is_master(parameter_dict):
        if parameter_dict["nodeIdMaster"] == parameter_dict["nodeIdOwn"]:
            return True
        else:
            return False

    def get_restart_counter(self):
        """ Gets restartCounter value of SMOD_L object. """
        try:
            smod_mo = self.admin.get_managed_objects("SMOD_L")
        except AliasLookupError:
            if not self.bts:
                self.bts = BuiltIn().get_library_instance("BTS")
            self.bts.check_if_admin_connection_available(create_connection=True)
            smod_mo = self.admin.get_managed_objects("SMOD_L")
        self.logger.debug(smod_mo)
        if not smod_mo:
            error("SMOD_L objects are not found.")
            raise EnvironmentIssue
        for smod in smod_mo:
            if "parameters" not in smod:
                error("Parameters is not found from SMOD_L.")
                raise EnvironmentIssue
            parameter_dict = smod["parameters"]
            if "restartCounter" in parameter_dict:
                counter_value = parameter_dict["restartCounter"]
                if "resetReason" in parameter_dict and "restartCause" in parameter_dict:
                    info(f"RestartCounter has value {counter_value}. Latest restartCause was "
                         f"'{parameter_dict['restartCause']}' and resetReason was '{parameter_dict['resetReason']}'")
                elif "resetType" in parameter_dict and "resetCategory" in parameter_dict:
                    info(f"RestartCounter has value {counter_value}. Latest resetType was "
                         f"'{parameter_dict['resetType']}' and resetCategory was '{parameter_dict['resetCategory']}'")
                else:
                    error(f"resetReason/resetType and/or restartCause/resetCategory were not found from the SMOD_L. "
                          f"RestartCounter has value {counter_value}.")
                return counter_value
            else:
                error("RestartCounter is not found from the SMOD_L, NOK.")
                raise EnvironmentIssue

    def check_value_of_restart_counter(self, expected_value="0", raise_error=False, info_text=""):
        """
        Compares given value to value of restartCounter.
        If value differs from given value:
            if raise_error is True: raises error and fails test
            if raise_error is False: give warning that restartCounter is not expected

        :param str expected_value: Default value is 0.
        :param bool raise_error: Default value is False, if True fails the test if value differs.
        :param str info_text: Default is empty, can be given more info for warning/error message.
        """
        extra_info = BuiltIn().get_variable_value("${EXTRA_INFO_FOR_LOOP}", default="")
        extra_info = extra_info.replace("_", " ")
        counter_value = self.get_restart_counter()
        warn_from_counter = BuiltIn().get_variable_value("${WARN_FROM_COUNTER}")
        self.logger.debug("Variable WARN_FROM_COUNTER has value {}".format(warn_from_counter))
        if int(counter_value) != int(expected_value):
            loop = "Loop {}: ".format(self.logger.loop + 1)
            if raise_error:
                error(f"{loop}{info_text}{extra_info}restartCounter has value {counter_value}, but it should have value"
                      f" {expected_value}. NOK.")
                raise UnexpectedRestartCounterValue
            elif not warn_from_counter:
                self.logger.debug(f"{extra_info} Counter value is not 0, but will not warn about it ")
            else:
                warning(f"{loop}{info_text}{extra_info}restartCounter has value {counter_value}, but it should have "
                        f"value {expected_value}. NOK.")
        else:
            self.logger.debug(f"RestartCounter has expected value ({expected_value})")

    @staticmethod
    def compare_counter_values(previous_counter, current_counter):
        """
        Compares two counter values and verifies that previous value is lesser than current value.
        :param str previous_counter: Value usually between 0-3.
        :param str current_counter: Value usually between 0-3.
        """
        if int(current_counter) < int(previous_counter):
            error("Current value of restartCounter is {} and it's value is lesser than previous "
                  "value of restartCounter {}. NOK.".format(current_counter, previous_counter))
            raise UnexpectedRestartCounterValue
        elif int(current_counter) == int(previous_counter):
            error("Current value of restartCounter equals to previous value of "
                  "restartCounter ({} == {}). Value of restartCounter has not been updated. "
                  "NOK.".format(current_counter, previous_counter))
            raise UnexpectedRestartCounterValue
        elif int(current_counter) > int(previous_counter):
            if int(current_counter) - int(previous_counter) != 1:
                error("Difference between current value of restartCounter and previous value of "
                      "restartCounter is not 1 ({} - {} = {}). NOK.".format(
                          current_counter, previous_counter, int(current_counter) - int(previous_counter)))
                raise UnexpectedRestartCounterValue
            else:
                info("Value of restartCounter has been updated as expected ({} - {} = 1), OK.".format(
                    current_counter, previous_counter))
        else:
            error("Counter values {} and {} are in unknown format.".format(
                current_counter, previous_counter))
            raise EnvironmentIssue

    def get_restart_cause(self, write_to_error=True):
        """
        Get restart cause of SMOD. If write_to_error is set True writes restart cause to error message. If set to False
        returns restart cause.

        :param bool write_to_error: Default is True if set False returns restart cause
        :return None/str: Returns restart cause if write_to_error is False, otherwise writes restar cause to error
                          messages.
        """
        smod_mo = self.admin.get_managed_objects("SMOD_L")
        if not smod_mo:
            error("SMOD_L objects are not found.")
            raise EnvironmentIssue
        for smod in smod_mo:
            if "parameters" not in smod:
                error("Parameters is not found from SMOD_L.")
                raise EnvironmentIssue
            parameter_dict = smod["parameters"]
            mo_name = smod["distName"]
            if "restartCause" in parameter_dict:
                cause_value = parameter_dict["restartCause"]
                if write_to_error:
                    error(f"Latest restartCause was {cause_value} ({mo_name})")
                else:
                    return cause_value
            elif "resetType" in parameter_dict and "resetCategory" in parameter_dict:
                cause_value = f"{parameter_dict['resetType']}: {parameter_dict['resetCategory']}"
                if write_to_error:
                    error(f"Latest restartCause was {cause_value} ({mo_name})")
                else:
                    return cause_value
            else:
                error("restartCause is not found from the SMOD_L, NOK.")
                raise EnvironmentIssue

    def get_unit_path_of_smod(self):
        """Gets information from SMOD for unit_path that is used in alarms."""
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        bts_id = self.bts.get_parameter_value_from_bts_info("btsId")
        unit_path = "[{}] MRBTS-{}".format(self.bts.bts_name, bts_id)
        return unit_path

    def check_if_smod_with_given_version(self, smod_version, print_to_eventlog=True):
        """
        Check if SMOD is given version.

        :param str smod_version: Version of SMOD that is checked. For example ASIB.
        :param bool print_to_eventlog: If True prints to eventlog, if False prints just to debugger log.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        if any(sm for sm in self.bts.smods if smod_version in sm.name):
            info(f"SMOD with version {smod_version} is found.") if print_to_eventlog else self.logger.debug(
                f"SMOD with version {smod_version} is found.")
            return True
        else:
            info(f"SMOD with version {smod_version} is NOT found.") if print_to_eventlog else self.logger.debug(
                f"SMOD with version {smod_version} is NOT found.")
            return False


class SCI:
    def __init__(self):
        self.name = ""
        self.dist_name = ""
        self.r_dist_name = ""  # Real-time
        self.serial_number = ""
        self.master = True
        self.config_dn = ""
        self.remote = False
