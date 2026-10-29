from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.ALD.Python.Resources.ALDExceptions import RfLockUnsuccessfulException, \
     RfUnlockUnsuccessfulException, RMODStatusNotOkException, IncorrectRadioException, RfResetUnsuccessfulException


class AldRMOD:

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.bts_status = BuiltIn().get_library_instance("BTSSTATUS")
        self.admin = BuiltIn().get_library_instance("ADMIN")

    def reset_radio(self, given_radio):
        """
        Resets given radio

        :param given_radio: RMOD-x
        :raises RfResetUnsuccessfulException: If resetting RF failed
        """
        radios = self._pre_check_for_radio_functions(given_radio)

        for function_form in radios:
            if given_radio in function_form:
                status = self.admin.reset_unit(function_form, timeout=180, detailed_output=True)
                error_code = status["errorCode"]
                if error_code == 0:
                    info("RF reset successful")
                else:
                    error("RF reset not successful, error code is: {}".format(error_code))
                    raise RfResetUnsuccessfulException
                self.check_radio_statuses()

    def lock_radio(self, given_radio):
        """
        Checks if given_radio is valid and locks the given radio

        :param given_radio: RMOD-x
        :raises RfLockUnsuccessfulException: If locking the radio failed
        """
        radios = self._pre_check_for_radio_functions(given_radio)

        for function_form in radios:
            if given_radio in function_form:
                status = self.admin.lock(function_form, timeout=60, detailed_output=True)
                error_code = status["errorCode"]
                if error_code == 0:
                    info("RF lock successful")
                else:
                    error("RF lock not successful, error code is: {}".format(error_code))
                    raise RfLockUnsuccessfulException

    def unlock_radio(self, given_radio):
        """
        Checks if given_radio is valid and locks the given radio. Also checks the status of given radio

        :param given_radio: RMOD-x
        :raises RfUnlockUnsuccessfulException: If unlocking the radio failed
        """
        radios = self._pre_check_for_radio_functions(given_radio)

        for function_form in radios:
            if given_radio in function_form:
                status = self.admin.unlock(function_form, timeout=60, detailed_output=True)
                error_code = status["errorCode"]
                if error_code == 0:
                    info("RF unlock successful")
                else:
                    error("RF unlock not successful, error code is: {}".format(error_code))
                    raise RfUnlockUnsuccessfulException
                self.check_radio_statuses()

    def get_radio_dist_names(self):
        """
        Gets information about radios from bts_info

        :returns List[Tuple(str, str)]: (configured radio, runtime radio)
        """
        radio_tuple_list = []
        for antenna in self.bts.antennae:
            config_name = antenna.dist_name.split("/")
            config_name = "{}/{}".format(config_name[-2], config_name[-1])
            runtime_name = antenna.runtime_dist_name.split("/")
            runtime_name = "{}/{}".format(runtime_name[-2], runtime_name[-1])
            radio_tuple_list.append((config_name, runtime_name))
        return radio_tuple_list

    def _get_function_form_for_rmod(self):
        """
        Get distname form for rf lock, unlock and reset functions.
        Distname is e.g. MRBTS-xxxxx/EQM-x/APEQM-x/RMOD-x

        :returns: List(str) function form
        """
        function_form_list = []
        for antenna in self.bts.antennae:
            config_name = antenna.dist_name.split("/")
            function_form = "{}/{}/{}/{}".format(config_name[-5], config_name[-4], config_name[-3], config_name[-2])
            if function_form not in function_form_list:
                function_form_list.append(function_form)
        return function_form_list

    def _pre_check_for_radio_functions(self, given_radio):
        """
        Used to check if given radio is given in the correct form (RMOD-x)

        :param given_radio: RMOD-x
        :raises IncorrectRadioException: If given_radio was not found from environment's radios
        """
        radios = self._get_function_form_for_rmod()
        given_radio_in_radios = False
        for function_form in radios:
            if given_radio in function_form:
                given_radio_in_radios = True

        if not given_radio_in_radios:
            error("Given radio: {} was not found from radios".format(given_radio))
            raise IncorrectRadioException
        else:
            info("Given radio: {} found from radio".format(given_radio))
        return radios

    def check_radio_statuses(self):
        """
        Checks the statuses of radios. If even one status is not ok, waits 30s and checks the status of not ok radios
        """
        checked_radios = []
        sleep_count = 0
        info("Checking radio status")
        BuiltIn().sleep("30s")
        for i in range(10):
            if checked_radios and len(checked_radios) == len(self.bts.radios):
                break
            statuses = self.bts_status.get_current_radio_status(print_info=False)
            for radio, status in statuses.items():
                if radio not in checked_radios:
                    if "availabilityStatus" not in status:
                        info("{} status is OK".format(radio))
                        checked_radios.append(radio)
                    else:
                        info("{} status is: {} -> NOT OK, sleeping for 30s".format(radio, status["availabilityStatus"]))
                        BuiltIn().sleep("30s")
                        sleep_count += 1

        if sleep_count >= 10:
            error("RMOD statuses were not OK in 300 seconds.")
            raise RMODStatusNotOkException
