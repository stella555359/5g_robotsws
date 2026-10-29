"""
:author: Sara Nowak Mateusz Potoniec
:contact: sara.nowak@nokia.com mateusz.potoniec@nokia.com
:maintainer: sara.nowak@nokia.com mateusz.potoniec@nokia.com
"""

from robot.api import logger
from robot.api.deco import keyword

from taf.sbts.oam.coam.admin import admin
from taf.internal.sbts.admin import exceptions as admin_exceptions
from taf.rfrl.utilities.robot.general import get_builtin_value


class AdminApiConnectionError(Exception):
    pass


class DataRetrievalError(Exception):
    pass


class IncorrectLinkModeParameterValue(Exception):
    pass


class IncorrectSFPAdministrativeStatus(Exception):
    pass


class sfp_operations:
    def __init__(self):
        _tl = get_builtin_value(param_name="tl")
        _instance_path = f'MRBTS-{_tl.gnbs[0].instance_id}'

        self.sfp_dist_name = f"{_instance_path}/EQM-1/APEQM-1/CABINET-1"
        self.link_mode_params_dist_name = f"{_instance_path}/EQM_R-1/HWTOP_R-1/CABLINK_R"
        self.link_mode_params_list = ['linkModeConfiguration', 'linkModeData', 'linkModeSynchronization']

        self.admin_api = admin()

    @keyword()
    def lock_sfp(self, sfp_id=1, smod_id=1, timeout=60):
        """
        Locks the specified SFP module.

        :param sfp_id: SFP module ID (default is 1)
        :param smod_id: Baseband module ID (default is 2)
        :param timeout: Timeout for the operation in seconds (default is 60)
        """

        self.perform_sfp_operation(sfp_id=sfp_id, smod_id=smod_id, action="Lock", timeout=timeout)

    @keyword()
    def unlock_sfp(self, sfp_id=1, smod_id=1, timeout=60):
        """
        Unlocks the specified SFP module.

        :param sfp_id: SFP module ID (default is 1)
        :param smod_id: Baseband module ID (default is 2)
        :param timeout: Timeout for the operation in seconds (default is 60)
        """
        self.perform_sfp_operation(sfp_id=sfp_id, smod_id=smod_id, action="Unlock", timeout=timeout)

    @keyword()
    def check_if_sfp_is_locked(self, sfp_id=1, smod_id=1):
        """
        Checks if the specified SFP module is locked.

        :param sfp_id: SFP module ID (default is 1)
        :param smod_id: Baseband module ID (default is 2)
        """

        status = self._get_sfp_administrative_status(sfp_id=sfp_id, smod_id=smod_id)
        if status.lower() != "locked":
            raise IncorrectSFPAdministrativeStatus(f"SFP {sfp_id} is not locked, current status: {status}")
        logger.info(f"SFP {sfp_id} is locked as expected.")

    @keyword()
    def check_if_sfp_is_unlocked(self, sfp_id=1, smod_id=1):
        """
        Checks if the specified SFP module is unlocked.

        :param sfp_id: SFP module ID (default is 1)
        :param smod_id: Baseband module ID (default is 2)
        """

        status = self._get_sfp_administrative_status(sfp_id=sfp_id, smod_id=smod_id)
        if status.lower() != "unlocked":
            raise IncorrectSFPAdministrativeStatus(f"SFP {sfp_id} is not unlocked, current status: {status}")
        logger.info(f"SFP {sfp_id} is unlocked as expected.")

    @keyword()
    def perform_sfp_operation(self, sfp_id=1, smod_id=1, action="Lock", timeout=60):
        """
        Performs the specified action (Lock or Unlock) on the SFP module.

        :param sfp_id: SFP module ID (default is 1)
        :param smod_id: Baseband module ID (default is 2)
        :param action: Action to perform, either "Lock" or "Unlock" (default is "Lock")
        :param timeout: Timeout for the operation in seconds (default is 60)
        """

        dist_name, connection = f"{self.sfp_dist_name}/SMOD-{smod_id}/SFP-{sfp_id}/LANE-1", None
        try:
            connection = self.admin_api.connect_to(bts_host='192.168.255.129')
            if len(connection.get_parameter_by_distname(dist_name=dist_name)) > 0:
                if action == "Lock":
                    logger.info(f"Locking SFP id {sfp_id}")
                    connection.lock(dist_name=dist_name, timeout=timeout)
                elif action == "Unlock":
                    logger.info(f"Unlocking SFP id {sfp_id}")
                    connection.unlock(dist_name=dist_name, timeout=timeout)
                else:
                    raise ValueError("Action must be either 'Lock' or 'Unlock'.")
        except (admin_exceptions.AdminApiConnectionClosedException, admin_exceptions.AdminApiProcedureFailureException,
                admin_exceptions.AdminApiNoResponseException,
                admin_exceptions.AdminApiTerminatedException, ValueError) as error:
            raise AdminApiConnectionError(f"Failed to connect to Admin API or perform Lock/Unlock: {error}")
        finally:
            if connection:
                self.admin_api.teardown()

    def _get_sfp_administrative_status(self, sfp_id=1, smod_id=1):
        """
        Retrieves the administrative status of the specified SFP module.

        :param sfp_id: SFP module ID (default is 1)
        :param smod_id: Baseband module ID (default is 2)

        :return: Administrative status of the SFP module
        """

        dist_name, connection, data = f"{self.sfp_dist_name}/SMOD-{smod_id}/SFP-{sfp_id}/LANE-1", None, None
        try:
            connection = self.admin_api.connect_to(bts_host='192.168.255.129')
            data = connection.get_parameter_by_distname(dist_name=dist_name)
        except (admin_exceptions.AdminApiConnectionClosedException, admin_exceptions.AdminApiProcedureFailureException,
                admin_exceptions.AdminApiNoResponseException, admin_exceptions.AdminApiTerminatedException) as error:
            raise AdminApiConnectionError(f"Failed to connect to Admin API or retrieve SFP lock status: {error}")
        finally:
            if connection:
                self.admin_api.teardown()
        if data:
            status = data[0]['parameters']['administrativeState']
            logger.info(f"SFP {sfp_id} Administrative Status: {status}")
            return status
        raise DataRetrievalError(f"No data retrieved from Admin API for SFP {sfp_id} administrative status.")

    @keyword()
    def check_link_mode_parameters(self, link_mode_configuration=True, link_mode_data=True,
                                   link_mode_synchronization=True, cablink_id=1001):
        """
        Checks the link mode parameters against the desired values.

        :param link_mode_configuration: Expected value for linkModeConfiguration (default is True)
        :param link_mode_data: Expected value for linkModeData (default is True)
        :param link_mode_synchronization: Expected value for linkModeSynchronization (default is True)
        """

        fail = False
        incorrect_parameters = {}
        data = self._get_link_mode_parameters(cablink_id)
        return data

    def _get_link_mode_parameters(self, cablink_id):
        """
        Retrieves the link mode parameters from the Admin API.

        :return: Dictionary containing link mode parameters
        """

        connection, data = None, None
        try:
            connection = self.admin_api.connect_to(bts_host='192.168.255.129')
            data = connection.get_parameter_by_distname(
                dist_name=f"{self.link_mode_params_dist_name}-{cablink_id}",
                parameter_list=self.link_mode_params_list
            )
        except (admin_exceptions.AdminApiConnectionClosedException, admin_exceptions.AdminApiProcedureFailureException,
                admin_exceptions.AdminApiNoResponseException, admin_exceptions.AdminApiTerminatedException) as error:
            raise AdminApiConnectionError(f"Failed to connect to Admin API or retrieve data: {error}")
        finally:
            if connection:
                self.admin_api.teardown()
        if data:
            link_mode_configuration = data[0]['parameters']['linkModeConfiguration']
            link_mode_data = data[0]['parameters']['linkModeData']
            link_mode_synchronization = data[0]['parameters']['linkModeSynchronization']
            logger.info(f"Link Mode Configuration: {link_mode_configuration}")
            logger.info(f"Link Mode Data: {link_mode_data}")
            logger.info(f"Link Mode Synchronization: {link_mode_synchronization}")
            return {
                'linkModeConfiguration': bool(link_mode_configuration),
                'linkModeData': bool(link_mode_data),
                'linkModeSynchronization': bool(link_mode_synchronization)
            }
        raise DataRetrievalError("No data retrieved from Admin API for link mode parameters.")
