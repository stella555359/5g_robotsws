
import os
from datetime import datetime
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.SCF import SCF
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (ClassNotFoundFromCommissioning,
                                                                        CommissioningFailure)


class ParameterCommissioning(object):
    def __init__(self):
        """
        ParameterCommissioning is a collection of commissioning methods that ParameterChange needs.
        """

        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.scf = SCF()

    def check_if_class_exists(self, class_of_element, parameter_to_change):
        """
        Check if class of parameter to be updated exits. This check is needed because for example NOKLTE:LNBTS class is
        not found from 5G environments.
        :param str class_of_element: Class to be searched for example NOKLTE:LNBTS
        :param str parameter_to_change: Name of element which value will be updated for example txPathFailureMode
        :raise
        """
        elements = self.scf.get_class_dict(class_of_element)
        self.logger.debug(elements)  # Elements and values
        if not elements:
            error("Class {} is not found from the scf, unable to update {}".format(
                class_of_element, parameter_to_change))
            raise ClassNotFoundFromCommissioning

    @staticmethod
    def wait_after_commissioning():
        info("Wait 30s after commissioning")
        BuiltIn().sleep("30s")
        info("Done")

    def update_parameter(self, new_value, parameter_to_change, dist_name):
        """
        Update parameter -method performs parameter recommissioning.
        param str new_value: Value to be re-commissioned
        param str parameter_to_change: Parameter that's value is re-commissioned
        param srt dist_name: DistName of the parameter to be changed
        """
        try:
            status = self.admin.perform_parameter_recommissioning(
                dist_name=dist_name, parameter=parameter_to_change, value=new_value, operation="update",
                skip_parameter_relation_errors=False, timeout=900)
            success_status = status['commissioningResult']['activationResult']['resultNode']['parameters']['result']
            if success_status == "Success":
                info("Parameter recommissioning successful")
            else:
                error(f"Parameter recommissioning failed, status: {success_status}")
                raise CommissioningFailure
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AdminApiTerminatedException, AdminApiConnectionClosedException, AliasLookupError,
                AliasInUse) as admin_error:
            info(f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            error(f"Unable to perform parameter recommissioning. {admin_error.__class__.__name__}:{admin_error} "
                  f"was raised.")
            raise CommissioningFailure
        self.wait_after_commissioning()

    def update_multiple_parameters_of_object(self, dist_name, parameter_value_dict_list):
        """
        Update multiple parameter of object -method performs parameter recommissioning to multiple parameters of same
        object.

        param srt dist_name: DistName of the parameter to be changed
        param list parameter_value_dict_list:  Parameter that's value is re-commissioned as key and value to be
                                          re-commissioned
        """
        try:
            self.admin.perform_object_recommissioning(
                dist_name=dist_name, parameter=parameter_value_dict_list, operation="update",
                skip_parameter_relation_errors=True, timeout=900)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AdminApiTerminatedException, AdminApiConnectionClosedException, AliasLookupError,
                AliasInUse) as admin_error:
            info(f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            error(f"Unable to perform object recommissioning. {admin_error.__class__.__name__}:{admin_error} "
                  f"was raised.")
            raise CommissioningFailure
        self.wait_after_commissioning()

    def add_to_delta(self, dist_name, element_name, element_value, delta_file):
        """
        Add distName, element and element value to delta file.

        :param str dist_name: Object distName.
        :param str element_name: Name of parameter to update.
        :param str element_value: Value of element.
        :param str delta_file: ID of delta JSON.
        """
        info("Add distName: {},  element: {} and value of element: {} to delta file".format(
            dist_name, element_name, element_value))
        try:
            self.admin.append_parameter_update_to_delta(dist_name, element_name, element_value, delta_id=delta_file)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AdminApiTerminatedException, AdminApiConnectionClosedException, AliasLookupError,
                AliasInUse) as admin_error:
            info(f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            error(f"Unable to append parameter update to delta. {admin_error.__class__.__name__}:{admin_error} "
                  f"was raised.\n")
            raise CommissioningFailure

    def add_list_items_to_delta(self, dist_name, list_name, parameter_dict, delta_file):
        """
        Add list items to delta file.
        :param str dist_name: Object distName.
        :param str list_name: Name of the list to which items are added.
        :param delta_file: ID of delta JSON.

        # :param args: List items to be added.
        # :param kwargs: Additional keyword arguments.
        """
        try:
            self.admin.append_list_items_to_delta(dist_name, list_name, parameter_dict, delta_id=delta_file)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AdminApiTerminatedException, AdminApiConnectionClosedException, AliasLookupError,
                AliasInUse) as admin_error:
            info(f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            error(f"Unable to append list parameter update to delta. {admin_error.__class__.__name__}:{admin_error} "
                  f"was raised.")
            raise CommissioningFailure

    def save_delta_file_and_perform_recommissioning(self, delta_file):
        """
        Save delta file to logs and perform recommissioning.

        :param str delta_file: ID of delta JSON.
        """
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        path_to_delta_file = os.path.join(self.logger.log_dir, "delta_file_{}.json".format(timestamp))
        info("Save delta file to {}".format(path_to_delta_file))
        try:
            self.admin.save_delta(path_to_delta_file, delta_id=delta_file)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AdminApiTerminatedException, AdminApiConnectionClosedException, AliasLookupError,
                AliasInUse) as admin_error:
            info(f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            error(f"Unable to save delta and perform commissioning. {admin_error.__class__.__name__}:{admin_error}.")
            raise CommissioningFailure
        info("Delta file is saved.")
        self.recommissioning_with_delta_file(path_to_delta_file)

    def recommissioning_with_delta_file(self, path_to_delta_file):
        """
        Perform delta recommissioning with given delta file.

        :param str path_to_delta_file: Path to delta file.
        :raise CommissioningFailure if there are problems in commissioning.
        """
        info("Perform delta recommissioning.")
        try:
            result = self.admin.perform_delta_recommissioning(path_to_delta_file, skip_parameter_relation_errors=True,
                                                              timeout=900)
            info("Delta recommissioning done.")
            self.logger.debug(result)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AdminApiTerminatedException, AdminApiConnectionClosedException, AliasLookupError,
                AliasInUse) as admin_error:
            info(f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            error(f"Unable to perform delta recommissioning. {admin_error.__class__.__name__}:{admin_error} was raised")
            raise CommissioningFailure

    def get_all_dist_names(self, class_of_parameter, fail_test=True):
        """
        Get all distNames of class.

        :param str class_of_parameter: Class to be searched from SCF. For example com.nokia.srbts.eqm:BBMOD.
        :param bool fail_test: Default is True and then fails if class is not found. If False then prints that not found
                               but doesn't fail.
        :return list: Return list of distNames or empty list if nothing found and set to not fail the test.
        """
        dist_name_list = []
        elements = self.scf.get_class_dict(class_of_parameter)
        if not elements:
            if fail_test:
                error("Class {} is not found from the scf.".format(class_of_parameter))
                raise ClassNotFoundFromCommissioning
            else:
                info("Class {} is not found from the scf.".format(class_of_parameter))
        if elements:
            self.logger.debug(elements)
            for dist_name in elements:
                if dist_name not in dist_name_list:
                    dist_name_list.append(dist_name)
        return dist_name_list
