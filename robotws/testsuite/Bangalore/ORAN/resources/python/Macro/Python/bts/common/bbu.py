# -*- coding: utf-8 -*-
"""
Generic keywords for BTS.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""

import logging
import time
import os

from datetime import datetime
from abc import abstractmethod

from moler.util.moler_test import MolerTest
from moler.exceptions import DeviceChangeStateFailure
from moler.device import DeviceFactory

from taf.internal.sbts.admin.exceptions \
    import (AdminApiConnectionClosedException,
            AdminApiProcedureFailureException)
from taf.sbts.oam.coam.admin.exceptions \
    import IncorrectParameterValue, DataNotAvailable
from taf.internal.robot_typecasts import to_boolean, time_to_seconds
from taf.pdu import pdu

from testsuite.Bangalore.ORAN.resources.python.Macro.Python.exceptions \
    import (IncorrectSfpData,
            NoConnectedSfp,
            WrongPduStatus,
            ParameterChangingError,
            UnexpectedBtsResetOccurred,
            SiteNotOnAir,
            InvalidStatuses,
            SwDownloadDurationNotMet,
            AverageSwDownloadDurationNotMet,
            FileNotFound)
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.\
    generic_bts \
    import GenericBts, login_logout, login_logout_GUI
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.hanging_resources \
    import HangingResources
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.utilities \
    import (load_moler_configuration_from_tl,
            return_all_key_paths_and_values_from_iterable)
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.helpers \
    import tl_config
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    transfer_files \
    import upload_files


class GenericBbu(GenericBts):
    """Base keywords for eNB and gNB"""

    def __init__(self, bts_type):
        """
        Constructor of GenericBbbu class.
        :param bts_type: GNB|ENB
        :return: None
        """
        super(GenericBbu, self).__init__(bts_type=bts_type)
        self.uptime = {}

    @login_logout
    def reset_bts(self, bts_id=0, wait_for_reconnection=True, du_id=0):
        """
        Reset BTS and wait for reconnection.

        :param bts_id:int, BTS id - related to Test Line configuration.
        :param wait_for_reconnection:bool, flag which define if admin
                                     api will wait for reconnection to bts.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :return: None
        """
        self.admin.reset_site(connection=self.rest_alias.format(bts_id, du_id),
                              wait_for_reconnection=wait_for_reconnection,
                              timeout=1200)

    @login_logout_GUI
    def reset_gnss_via_gui(self, bts_id=0, du_id=0):
        """
        Reset GNSS using GUI
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :return:    None
        """
        self.gui_coam.reset_gnss()
        time.sleep(10)

    @login_logout_GUI
    def reset_abil_via_gui(self, bts_id=0, du_id=0):
        """
        Reset abil using GUI
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :return:    None
        """
        self.gui_coam.reset_abil()

    @login_logout_GUI
    def lock_abil_via_gui(self, bts_id=0, du_id=0):
        """
        Lock abil using GUI
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :return:    None
        """
        self.gui_coam.lock_abil()

    @login_logout_GUI
    def unlock_abil_via_gui(self, bts_id=0, du_id=0):
        """
        Unlock abil using GUI
        :param bts_id:  ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :return:    None
        """
        self.gui_coam.unlock_abil()

    @login_logout_GUI
    def reset_bts_via_gui(self, bts_id=0, du_id=0):
        """
        Reset BTS from GUI
        param bts_id:int, BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :return: None
        """
        self.gui_coam.reset_site()

    def bts_power_on(self, bts_id=0, du_id=0, confirm=True):
        """
        Power on BTS using power switch.
        param bts_id:int, BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :param confirm: if true set value will be checked afterwards and
                        if it is not set the exception is raised
        :return: None
        """
        obj_pdu = pdu()
        pdu_port = tl_config.get_bts_pdu_port(bts_id=bts_id,
                                              du_id=du_id,
                                              bts_type=self.bts_type)
        port_nr = self._setup_pdu(obj_pdu, pdu_port)
        obj_pdu.power_on(port_nr)
        if confirm:
            time.sleep(5)
            port_status = obj_pdu.get_port_status(port=port_nr)
            if port_status == "on":
                logging.info("Port {} powered on for BTS{}"
                             .format(port_nr, bts_id))
            else:
                raise WrongPduStatus("Port {} is NOT ON for BTS{}".
                                     format(port_nr, bts_id))

    def bts_power_off(self, bts_id=0, du_id=0, confirm=True):
        """
        Power off BTS using power switch.
        param bts_id:int, BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :param confirm: if true set value will be checked afterwards and
                        if it is not set the exception is raised
        :return: None
        """
        obj_pdu = pdu()
        pdu_port = tl_config.get_bts_pdu_port(bts_id=bts_id,
                                              du_id=du_id,
                                              bts_type=self.bts_type)
        port_nr = self._setup_pdu(obj_pdu, pdu_port)
        obj_pdu.power_off(port_nr)
        if confirm:
            time.sleep(5)
            port_status = obj_pdu.get_port_status(port=port_nr)
            if port_status == "off":
                logging.info("Port {} powered off for BTS{}".
                             format(port_nr, bts_id))
            else:
                raise WrongPduStatus("Port {} is NOT OFF for BTS{}".
                                     format(port_nr, bts_id))

    @staticmethod
    def _setup_pdu(obj_pdu, pdu_port):
        """
        This method was created to keep backward compatibility -
             will be removed in future.
        :return: port_nr
        """
        if hasattr(pdu_port, 'addr'):
            logging.warning("Wrong configuration of pdu_port - "
                            "please use PduPort class. "
                            "Your test will be working but support "
                            "for wrong configuration "
                            "will be removed in the future")
            obj_pdu.setup_pdu(model=pdu_port, host=pdu_port.addr,
                              login=pdu_port.login,
                              password=pdu_port.password)
            port_nr = pdu_port.port_numbers[0]
        else:
            bts_pdu = pdu_port.pdu
            obj_pdu.setup_pdu(model=bts_pdu, host=bts_pdu.addr,
                              login=bts_pdu.login,
                              password=bts_pdu.password)
            port_nr = pdu_port.port_no

        return port_nr

    @login_logout
    def verify_bts_is_onair(self, bts_id=0, du_id=0):
        """
        Verify if bts operational state is OnAir.
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :return: None
        """

        self._verify_bts_is_in_state(state='onair',
                                     bts_id=bts_id,
                                     du_id=du_id)

    def verify_statuses_on_fsm(self, bts_id=0, du_id=1, fsm_id=1,
                               operational_state="enabled",
                               procedural_status="configured",
                               availability_status="online",
                               administrative_state="unlocked"):
        """
        Verify if statuses are correct on fsm
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id:   DU id(Distributed Unit) - id related to
                       Test Line configuration - gnb.dus[]
        :param fsm_id:  FSM_id
        :param operational_state:    Operational state of bts.
        :param procedural_status:   Procedural status of bts.
        :param availability_status:    Availability status of bts.
        :param administrative_state:    Administrative state of bts.
        :return:    None
        """
        self._verify_common_unit_state(bts_id=bts_id,
                                       ops=operational_state,
                                       avs=availability_status,
                                       admin_state=administrative_state,
                                       proc_state=procedural_status,
                                       timeout=30, du_id=du_id - 1)

    def verify_statuses_on_fbb(self, bts_id=0, du_id=1, abil_id=1,
                               operational_state="enabled",
                               procedural_status="configured",
                               availability_status="online",
                               administrative_state="unlocked"):
        """
        Verify if statuses are correct on fbb
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id:   DU id(Distributed Unit) - id related to
                        Test Line configuration - gnb.dus[]
        :param abil_id: FBB id
        :param operational_state:    Operational state of bts.
        :param procedural_status:   Procedural status of bts.
        :param availability_status:    Availability status of bts.
        :param administrative_state:    Administrative state of bts.
        :return:    None
        """

        self._verify_capacity_unit_state(bts_id=bts_id, ops=operational_state,
                                         avs=availability_status,
                                         admin_state=administrative_state,
                                         proc_state=procedural_status,
                                         timeout=30, du_id=du_id - 1)

    @login_logout
    def check_statuses_on_gnss(self, bts_id=0, du_id=0, gnss_id=1):
        """
        Check statuses on GNSS
        :param bts_id: BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[].
        :param gnss_id: GNSS id
        :return: GNSS status
        """
        gnss_status_check = self.admin.\
            get_gnsses_statuses(connection=self.rest_alias.
                                format(bts_id, du_id))
        gnss_status = {
            "availabilityStatus": gnss_status_check["GNSSE_R-" + str(gnss_id)]
            ["availabilityStatus"],
            "operationalState": gnss_status_check["GNSSE_R-" + str(gnss_id)]
            ["operationalState"],
            "administrativeState": gnss_status_check["GNSSE_R-" + str(gnss_id)]
            ["administrativeState"]}

        return gnss_status

    def verify_statuses_on_gnss(self, bts_id=0, du_id=0, gnss_id=1,
                                operational_state="enabled",
                                availability_status="online",
                                administrative_state="unlocked"):
        """
        Verify statuses on GNSS
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id:   DU id(Distributed Unit) - id related to
                       Test Line configuration - gnb.dus[].
        :param gnss_id: GNSS id
        :param operational_state:    Operational state of bts.
        :param availability_status:    Availability status of bts.
        :param administrative_state:    Administrative state of bts.
        :return: None
        """
        expected_statuses = {
            "availabilityStatus": availability_status,
            "operationalState": operational_state,
            "administrativeState": administrative_state
        }
        try:
            gnss_statuses = self.check_statuses_on_gnss(bts_id=bts_id,
                                                        du_id=du_id - 1,
                                                        gnss_id=gnss_id)
            for status in expected_statuses:
                if expected_statuses[status].lower() != \
                        gnss_statuses[status].lower():
                    logging.info("Expected status {}, actual status {}"
                                 "".format(expected_statuses[status],
                                           gnss_statuses[status]))
                    raise InvalidStatuses
        except KeyError as e:
            raise DataNotAvailable("Cannot get expected status info: {}".
                                   format(repr(e)))

    @login_logout
    def verify_bts_is_not_commissioned(self, bts_id=0, du_id=0):
        """
        Verify if bts operational state is OnAir.
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :return: None
        """

        self._verify_bts_is_in_state('notcommissioned', bts_id, du_id)

    @abstractmethod
    def _get_bts_state(self, bts_id=0, du_id=0):
        pass

    @login_logout
    def get_bts_sw_version(self, bts_id=0, du_id=0):
        """
        Get current software version provided by M-Plane
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :return: Version number as a string, for e.g.
                 '5G20A_GNB_0000_000846_000397'
        """
        sw_ver = self.admin.get_sw_version(timeout=10,
                                           connection=self.rest_alias.
                                           format(bts_id, du_id))
        return sw_ver

    @login_logout
    def get_bts_info(self, bts_id=0, du_id=0):
        """
        Get current bts status
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :return: bts info
        """
        bts_info = self.admin.get_bts_info(timeout=10,
                                           connection=self.rest_alias.
                                           format(bts_id, du_id))
        return bts_info

    @login_logout
    def set_certificate_automatic_managment(self, reference_number,
                                            preshared_key,
                                            bts_id=0,
                                            du_id=0):
        """
        Set certificate automatic managment.
        :param string reference_number: Reference number
        :param string preshared_key: Pre-shared key
        :param bts_id: BTS(eNB/gNB) id - related to
                       Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                     Test Line configuration - gnb.dus[]
        """
        self.admin.set_certificate_automatic_managment(
            reference_number, preshared_key,
            connection=self.rest_alias.format(bts_id, du_id))

    @login_logout
    def verify_configuration_parameters_values(self, param_dict, bts_id=0,
                                               du_id=0):
        """
        Verify that given parameters have given values.
        :param param_dict: dictionary where the main key is a
                 distNames of the managedObject
                 where given parameters are located and the value is
                 dictionary with parameters and their
        expected values,
        e.g. {  distName1: {
                  param1: expected_value1,
                  param2: expected_value2
                },
                distName2: {
                  param1: expected_value1,
                  param2: expected_value2
                }
            }
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :return: None
        """
        self._verify_configuration_parameters_values(param_dict=param_dict,
                                                     bts_id=bts_id,
                                                     du_id=du_id)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def _get_current_bts_uptime_value(self, bts_id=0, du_id=0):
        """
        Get uptime value and timestamp from BTS [in seconds]
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                    Test Line configuration - gnb.dus[]
        :return: current BTS uptime [seconds]
        """
        try:
            gnb = DeviceFactory.get_device(name=self.ssh_alias.
                                           format(bts_id, du_id))
            gnb.goto_state("FCT")
        except DeviceChangeStateFailure as err:
            MolerTest.error("Couldn't correctly establish connection "
                            "to FCT BTS\n{}".format(repr(err)))
            MolerTest.steps_end()
        cat_cmd = gnb.get_cmd(cmd_name="cat", cmd_params={'path':
                                                          '/proc/uptime'})
        uptime = {'timestamp': int(float(time.time())), 'value':
                  int(float(cat_cmd()['LINES'][0].split(" ")[0]))}
        logging.info("Current uptime on BTS: {}".format(uptime))
        MolerTest.steps_end()
        return uptime

    def wait_for_site_to_be_onair(self, bts_id=0, timeout=900, interval=10,
                                  du_id=0):
        """
        Wait for site to be onair until timeout
        :param bts_id:  BTS id - related to Test Line configuration.
        :param timeout:  Time in seconds to wait for site to go onair
        :param interval:  time in seconds between each status check
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :return: None
        """
        start_time = time.time()
        while time.time() < start_time + time_to_seconds(time=timeout):
            try:
                self.verify_bts_is_onair(bts_id=bts_id, du_id=du_id)
                logging.info("Bts is 'OnAir")
                break
            except IncorrectParameterValue:
                time.sleep(time_to_seconds(time=interval))
            except (AdminApiConnectionClosedException,
                    AdminApiProcedureFailureException):
                time.sleep(time_to_seconds(time=interval))
        else:
            raise SiteNotOnAir("Timeout passed. Bts status in not onAir")

    def verify_object_exist_in_configuration(
            self,
            object_name,
            number_of_objects=1,
            bts_id=0,
            du_id=0):
        """
        Verifies if given number of objects with given name exists in
        testline configuration
        :param object_name: Name of object in testline configuration
        :param number_of_objects:   Number of objects that should exist
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration
                     - gnb.dus[]
        :return: None
        """
        object_name_list = self.get_object_name_list(object_name=object_name,
                                                     bts_id=bts_id)
        if len(object_name_list) != int(number_of_objects):
            raise Exception("Wrong number of object exists")

    @login_logout_GUI
    def get_object_name_list(self, object_name, bts_id=0, du_id=0):
        """
        Get list of objects matching given object name
        :param object_name: Name of object in testline configuration
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration
                     - gnb.dus[]
        :return: list of objects
        """
        object_name_list = self.gui_coam.get_object_name_list(
            object_name=object_name)
        return object_name_list

    @login_logout_GUI
    def get_gnb_parameter_value_via_gui(
            self,
            dist_name,
            param_name,
            param_abbr,
            bts_id=0,
            du_id=0):
        """
        Get and return the value of specified parameter.
        :param param_name: parameter name filter to locate target parameter.
        :param dist_name: dist name to locate the parameter.
                        Please use MRBTS-{}/NRBTS-{} format.
        :param param_abbr: abbreviation of the parameter.
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration
                      - gnb.dus[]
        :return: value of the specified parameter.
        """
        dist_name = self.adjust_dist_name(dist_name, bts_id, du_id)
        param_value = self.gui_coam.get_parameter_value(
            dist_name=dist_name, filter_param=param_name, abbr=param_abbr)
        return param_value

    def save_bts_uptime(self, bts_id=0, du_id=0):
        """
        Set uptime value and timestamp to current BTS value [in seconds]
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration
                      - gnb.dus[]
        :return: None
        """
        bts_name = self.ssh_alias.format(bts_id, du_id)
        self.uptime[bts_name] = self._get_current_bts_uptime_value(
            bts_id=bts_id, du_id=du_id)

    def verify_no_bts_reboot_since_last_saved_uptime(self, bts_id=0, du_id=0):
        """
        Verify that BTS has not been rebooted by comparison of current
        uptime value
        with the previous one set.
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration
                     - gnb.dus[]
        :return: None
        """
        bts_name = self.ssh_alias.format(bts_id, du_id)
        current_uptime = self._get_current_bts_uptime_value(bts_id, du_id)
        try:
            last_uptime = self.uptime[bts_name]
        except KeyError:
            raise IncorrectParameterValue(
                "Uptime value not set on bts, "
                "save uptime before using this method.")
        last_boot_time = last_uptime['timestamp'] - last_uptime['value']
        current_boot_time = current_uptime['timestamp'] - \
            current_uptime['value']
        logging.debug("Last boot time: {}, current boot time: {}".
                      format(last_boot_time, current_boot_time))
        if (current_boot_time - last_boot_time) > 5:
            raise UnexpectedBtsResetOccurred(
                "BTS has been rebooted, current uptime:{} < {}".
                format(current_uptime, last_uptime))
        logging.info("BTS current uptime: {}[seconds], last uptime: {}".
                     format(current_uptime, last_uptime))

    @login_logout
    def _verify_common_unit_state(self, bts_id=0, ops="enabled", avs="online",
                                  admin_state="unlocked",
                                  proc_state="configured", timeout=30,
                                  du_id=0):
        """
        Gets ASIK(Common Unit) state and verifies against the state that
        tester demands

        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param ops: operationalState of Common Unit
        :param avs: availabilityStatus of Common Unit
        :param admin_state: administrativeState of Common Unit
        :param proc_state: proceduralState of Common Unit
        :param timeout: timeout for positive procedure result
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration
                      - gnb.dus[]
        :return: None
        """
        system_module_info = self.admin.get_fsm_info(
            connection=self.rest_alias. format(
                bts_id, du_id), timeout=timeout)
        for system in system_module_info:
            assert system['status']['operationalState'].lower() == \
                ops.lower(), "Operational state: {} != {}".\
                format(system['status']['operationalState'], ops)
            assert system['status']['availabilityStatus'].lower() == \
                avs.lower(), "Availability status: {} != {}".\
                format(system['status']['availabilityStatus'], avs)
            assert system['status']['administrativeState'].lower() == \
                admin_state.lower(), "Administrative state: {} != {}".\
                format(system['status']['administrativeState'], admin_state)
            assert system['status']['proceduralStatus'].lower() == \
                proc_state.lower(), "Procedural state: {} != {}".\
                format(system['status']['proceduralStatus'], proc_state)
        logging.info("ASIK(Common Unit) states are as declared")

    @login_logout
    def _verify_capacity_unit_state(
            self,
            bts_id=0,
            ops="enabled",
            avs="online",
            admin_state="unlocked",
            proc_state="configured",
            timeout=30,
            du_id=0):
        """
        Gets ABIL(Capacity Unit) state and verifies against the state that
        tester demands

        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param ops: operationalState of Common Unit
        :param avs: availabilityStatus of Common Unit
        :param admin_state: administrativeState of Common Unit
        :param proc_state: proceduralStatus of Common Unit
        :param timeout: timeout for positive procedure result
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration
         - gnb.dus[]
        :return: None
        """
        system_module_info = self.admin.get_fbb_info(
            connection=self.rest_alias.format(
                bts_id, du_id), timeout=timeout)
        for system in system_module_info:
            assert system['status']['operationalState'].lower() == ops.lower(
            ), "Operational state: {} != {}".\
                format(system['status']['operationalState'], ops)
            assert system['status']['availabilityStatus'].lower() == avs.lower(
            ), "Availability status: {} != {}".\
                format(system['status']['availabilityStatus'], avs)
            assert system['status']['administrativeState'].lower() == \
                   admin_state.lower(), "Administrative state: {} != {}".\
                   format(system['status']['administrativeState'], admin_state)
            assert system['status']['proceduralStatus'].\
                   lower() == proc_state.lower(), \
                   "Procedural state: {} != {}".\
                   format(system['status']['proceduralStatus'], proc_state)
        logging.info("ABIL(Capacity Unit) states are as declared")

    @load_moler_configuration_from_tl()
    def _verify_virtual_nodes_running(self, bts_id=0, du_id=0):
        """
        Verify that all node status are in RUNNING state

        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return: None
        """
        bts = DeviceFactory.get_device(
            name=self.ssh_alias.format(
                bts_id, du_id))
        bts.goto_state('FCT')
        lxcls_cmd = bts.get_cmd(
            cmd_name='lxc_ls', cmd_params={
                'options': '-f'})
        all_nodes = lxcls_cmd()['RESULT']
        for node in all_nodes:
            assert node['State'] == 'RUNNING', \
                "Node {} is not in running state".format(node)
        logging.info("All nodes are in RUNNING state")

    @login_logout
    def verify_du_availability(self, bts_id=0, timeout=30, du_id=0):
        """
        Checking testline DU availabilty

        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param timeout: timeout for positive procedure result
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return: None
        """
        bts_sync_status = self.admin.get_bts_sync_source_status(
            connection=self.rest_alias.format(bts_id, du_id))
        if bts_sync_status['tuningMode'].lower() not in [
                'normal', 'normal tuning']:
            raise IncorrectParameterValue(
                "Bts sync status:{},expected:'Normal'".format(
                    bts_sync_status['tuningMode']))
        self._verify_common_unit_state(
            bts_id=bts_id, du_id=du_id, timeout=timeout)
        self._verify_capacity_unit_state(
            bts_id=bts_id, du_id=du_id, timeout=timeout)
        self._verify_virtual_nodes_running(bts_id=bts_id, du_id=du_id)

    @login_logout
    def verify_procedural_and_blocking_state(
            self,
            bts_id=0,
            timeout=30,
            procedural_states=["OnAir"],
            du_id=0):
        """
        Verify BTS Procedural State and blocking State

        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param timeout: timeout for positive procedure result
        :param procedural_states: BTS procedural States, Configured or
        OnAir/Commissioned
        :type procedural_states: str/list
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return: None
        """
        bts_status = self.admin.get_bts_statuses(
            connection=self.rest_alias.format(
                bts_id, du_id), timeout=timeout)
        assert bts_status['proceduralState'] in procedural_states, \
            'Incorrect procedural state: {} != {}'.format(
                bts_status['proceduralState'], procedural_states)
        assert bts_status['blockingState'].lower() == "unblocked", \
            'Incorrect blocking state: {} != {}'.format(
                bts_status['blockingState'].lower(), "unblocked")
        logging.info("Correct procedural and blocking state")

    def verify_site_availability(self, bts_id=0, timeout=30, du_id=0):
        """
        Check testline availabilty

        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
        :param timeout: timeout for positive procedure result
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return:
        """
        procedural_states = ["Configured", "OnAir", "Commissioned"]
        self.verify_procedural_and_blocking_state(
            bts_id=bts_id,
            du_id=du_id,
            procedural_states=procedural_states,
            timeout=timeout)
        self.verify_du_availability(
            bts_id=bts_id, du_id=du_id, timeout=timeout)
        if self.bts_type == "GNB":
            self.precheck_for_cell_setup(gnb_id=bts_id, du_id=du_id)

    @login_logout_GUI
    def get_bts_configuration_via_gui(self, bts_id=0, du_id=0):
        """
        Save BTS comissioning file
        :param bts_id: eNB/gNB id related to bts configuration
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return: path to commisioaning file ie.
                /tmp/tmpUGAahWtaf_selenium_coam_download/
                scf_MRBTS-10297_5G_mmW_AEUD_TL297_20200404-0944.xml
        """
        path = self.gui_coam.backup_bts_site_configuration()
        return path

    @login_logout_GUI
    def upload_bts_configuration_via_gui(self, path, bts_id=0, du_id=0):
        """
        Load, validate and activate BTS comissioning file
        :param path: path to saved BTS comissioning ie.
               /tmp/tmpUGAahWtaf_selenium_coam_download/
               scf_MRBTS-10297_5G_mmW_AEUD_TL297_20200404-0944.xml
        :param bts_id: eNB/gNB id related to bts configuration
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return:
        """
        self.gui_coam.load_commissioning_file_and_check_load_status(path)
        self.gui_coam.validate_plan()
        self.gui_coam.activate_plan()

    @login_logout
    def get_bts_configuration_file(
            self,
            bts_id,
            local_dir='/tmp',
            config_type=None,
            filename='current_scf.xml',
            du_id=0):
        """
        Download configuration file (scf) from bts to local directory on
        device where keyword is run.
        :param local_dir: directory on local device where file is saved
        :param config_type: type of configuration file, one of the type:
                            configuration, configurationAndRuntimeObjects,
                            runtimeObjects. When None (default value) -
                            default AdminAPI behavior is chosen.
        :param filename: name of saved scf file. Default: current_scf.xml.
        :param bts_id: eNB/gNB id related to bts configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        """
        path_to_file = "{}/{}".format(local_dir, filename)
        self.admin.get_current_scf_file(
            connection=self.rest_alias.format(
                bts_id,
                du_id),
            local_dir_path=local_dir,
            file_name=filename,
            export_type=config_type)
        return path_to_file

    @login_logout_GUI
    def verify_if_parameter_changed_to_incorrect_value_via_gui(
            self, dist_name, parameter, value, node_index=0,
            bts_id=0, du_id=0):
        """
        Change value for incorrect value and try to activate plan
        :param dist_name: dist name to locate the parameter
        :param parameter: parameter name to change
        :param value: value to set parameter
        :param node_index: param to filter child node if other params
            can not locate only one
        :param bts_id: eNB/gNB id related to bts configuration
        :param du_id: DU id(Distributed Unit) - id related to Test
                 Line configuration - gnb.dus[]
        :return:
        """
        self.change_parameter_via_gui(
            dist_name,
            parameter,
            value,
            int(node_index),
            bts_id,
            du_id=du_id)
        if self.gui_coam.activate_plan():
            raise ParameterChangingError(
                "Value wasn't out of range, plan had been activated")

    @login_logout_GUI
    def verify_if_parameter_changed_to_correct_value_via_gui(
            self, dist_name, parameter, value, node_index=0,
            bts_id=0, du_id=0):
        """
        Change value for incorrect value and try to activate plan
        :param dist_name: dist name to locate the parameter
        :param parameter: parameter name to change
        :param value: value to set parameter
        :param node_index: param to filter child node if other params
        can not locate only one
        :param bts_id: eNB/gNB id related to bts configuration
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return:
        """
        self.change_parameter_via_gui(
            dist_name,
            parameter,
            value,
            int(node_index),
            bts_id,
            du_id=du_id)
        if not self.gui_coam.activate_plan(activate_plan_despite_errors=True):
            raise ParameterChangingError(
                "Value wasn't out of range, plan not activated")

    def change_parameter_via_gui(
            self,
            dist_name,
            parameter,
            value,
            node_index=0,
            bts_id=0,
            du_id=0):
        """
        Change value and activate plan from GUI
        :param dist_name: dist name to locate the parameter
        :param parameter: parameter name to change
        :param value: value to set parameter
        :param node_index: param to filter child node if other params
        can not locate only one
        :param bts_id: eNB/gNB id related to bts configuration
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return:
        """
        dist_name = self.adjust_dist_name(dist_name, bts_id, du_id)
        self.gui_coam.set_parameter_value(
            dist_name, parameter, value, int(node_index))
        self.gui_coam.validate_plan()

    @login_logout
    def _get_sfp_data_from_bts(self, bts_id=0, du_id=0):
        """
        author:         Maciej Russek, maciej.russek@nokia.com
        maintainer:     Maciej Russek, maciej.russek@nokia.com
        Get SFP links data from BTS
        :param bts_id:      BTS(eNB/gNB) id - related to Test Line
        configuration
        :param du_id:       DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return:            BTS internal SFP links database
        """
        return self.admin.get_sfp_links(
            connection=self.rest_alias.format(
                bts_id, du_id))

    def _check_if_sfp_data_is_correct(self, sfp_link_data):
        """
        author:         Maciej Russek, maciej.russek@nokia.com
        maintainer:     Maciej Russek, maciej.russek@nokia.com

        Check if all SFP parameters are present as readable data
        :return:        List with incorrect data if any exists
        """
        incorrect_data_list = []
        sfp_link_keys_and_values = list(
            return_all_key_paths_and_values_from_iterable(sfp_link_data))
        sfp_details = sfp_link_data['data']['linkPorts']
        for key_and_value in sfp_link_keys_and_values:
            try:
                if '?' in str(key_and_value[-1]):
                    incorrect_data_list.append([sfp_details, key_and_value])
            except UnicodeEncodeError:
                if '?' in str(key_and_value[-1].encode("utf-8")):
                    incorrect_data_list.append([sfp_details, key_and_value])

        return incorrect_data_list

    def _check_if_all_connected_sfp_data_is_correct(self, sfp_data):
        """
        author:         Maciej Russek, maciej.russek@nokia.com
        maintainer:     Maciej Russek, maciej.russek@nokia.com

        Check if any connected SFP link exists then if its parameters are
        present as readable data
        """
        incorrect_data_list = []
        try:
            connected_sfp_links = sfp_data['connected']
        except KeyError:
            raise NoConnectedSfp()

        for connected_sfp_link in connected_sfp_links:
            incorrect_data_list.extend(
                self._check_if_sfp_data_is_correct(connected_sfp_link))

        if incorrect_data_list:
            raise IncorrectSfpData(incorrect_data_list)

    def verify_sfp_data(self, bts_id=0, du_id=0):
        """
        author:         Maciej Russek, maciej.russek@nokia.com
        maintainer:     Maciej Russek, maciej.russek@nokia.com

        Get SFP links data from BTS then heck if all SFP parameters are
        present as readable data
        :param bts_id:      BTS(eNB/gNB) id - related to Test Line
        configuration
        :param du_id:       DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        """
        bts_sfp_data = self._get_sfp_data_from_bts(bts_id, du_id)
        self._check_if_all_connected_sfp_data_is_correct(bts_sfp_data)

    def _verify_bts_is_in_state(self, state, bts_id=0, du_id=0):
        """
        Verify if bts is in specific operational state.
        :param state: operational state in which is bts;
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return: None
        """

        state = str(state).lower()
        acceptable_states = ('onair', 'notcommissioned')
        assert state in acceptable_states
        bts_state = self._get_bts_state(bts_id, du_id)

        if bts_state != state:
            raise IncorrectParameterValue(
                "{} is not in {} state.Current unexpected state is:{}".format(
                    bts_id, state, bts_state))
        else:
            logging.info(
                "{} is {} as expected.".format(
                    self.rest_alias.format(
                        bts_id, du_id), state))

    @load_moler_configuration_from_tl()
    def upload_swconfig(
            self,
            sw_config_path,
            bts_id=0,
            du_id=0,
            reboot_after_upload=False):
        """
        Copy a local swconfig file to /rom/ directory.
        :param sw_config_path: local path to swconfig.
        :param bts_id: BTS(gNB) id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param reboot_after_upload: reboot DU after upload
        """

        bts_name = self.ssh_alias.format(bts_id, du_id)
        upload_files(local_dir=os.path.dirname(sw_config_path),
                     local_file=os.path.basename(sw_config_path),
                     remote_dir='/rom/',
                     device_name=bts_name,
                     new_file_name='swconfig.txt',
                     )

        if reboot_after_upload:
            bts = DeviceFactory.get_device(bts_name)
            reboot_cmd = bts.get_cmd(cmd_name='reboot')
            reboot_cmd()

    @login_logout_GUI
    def reset_capacity_unit_from_gui(
            self, bts_id=0, du_id=0, capacity_unit_id=0):
        """
        Reset capacity unit with specified number from BTS side.

        :param bts_id:BTS id - related to Test Line configuration. Default: 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param capacity_unit_id:   ID of capacity unit. Default: 0
        :return:                None
        """
        self.gui_coam.reset_abil(
            abil_index=str(
                int(capacity_unit_id) + 1),
            timeout=60)

    @login_logout_GUI
    def get_bts_certificates_via_gui(self, bts_id=0, du_id=0):
        """
        author:         Maciej Russek, maciej.russek@nokia.com
        maintainer:     Maciej Russek, maciej.russek@nokia.com

        Keyword for getting certificates info at BTS Certificates tab.
        :param bts_id:              BTS id - related to Test Line configuration
        :param du_id:               DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return:                    BTS certificates dictionaries
        """
        return self.gui_coam.get_certificates()

    @load_moler_configuration_from_tl()
    def _verify_if_flag_exists_in_swconfig(
            self, swconfig, flag, bts_id=0, du_id=0):
        """
        Verifies if flag exists in swconfig.txt

        :param swconfig:        Path to swconfig.txt file
        :param flag:            Flag which is verified
        :param bts_id:          BTS id - related to Test Line configuration
        :param du_id:           DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return:                Grepped dictionary
        """
        bts_name = self.ssh_alias.format(bts_id, du_id)
        bts = DeviceFactory.get_device(bts_name)
        grep_cmd = bts.get_cmd(cmd_name='grep',
                               cmd_params={
                                   'options': '{} {}'.format(flag, swconfig)
                               })
        return grep_cmd()['LINES']

    @load_moler_configuration_from_tl()
    def set_swconfig_flag(
            self,
            flag,
            value,
            reboot_after_set=False,
            swconfig='/rom/swconfig.txt',
            bts_id=0,
            du_id=0):
        """
        Set swconfig flag with given value

        :param flag:                String representation of hexadecimal
        value of the flag
        :param value:               Value to be set
        :param reboot_after_set:    Flag to reboot BTS after setting
        :param swconfig:            Path to swconfig.txt file
        :param bts_id:              BTS id - related to Test Line configuration
        :param du_id:               DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        """

        bts_name = self.ssh_alias.format(bts_id, du_id)
        bts = DeviceFactory.get_device(bts_name)
        scripts = [
            r's/^{}=[0x]*[[:digit:]]*$/{}={}/g'.format(flag, flag, value)]

        if self._verify_if_flag_exists_in_swconfig(
                swconfig=swconfig, flag=flag):
            sed_cmd = bts.get_cmd(cmd_name='sed',
                                  cmd_params={
                                      'options': '-i',
                                      'scripts': scripts,
                                      'input_files': [swconfig]
                                  })
            sed_cmd()
        else:
            echo_cmd = bts.get_cmd(cmd_name='echo',
                                   cmd_params={
                                       'options': "{}={} >> {}".
                                       format(flag, value, swconfig),
                                   })
            echo_cmd()
        if reboot_after_set:
            reboot_cmd = bts.get_cmd(cmd_name='reboot')
            reboot_cmd()

    @login_logout
    def measure_software_download_to_du_time(self, path,
                                             success_rate,
                                             average_target,
                                             timeout,
                                             bts_id=0,
                                             du_id=0):
        """
        Perform DU update, measure time and verify if meet average
        time target and success rate ratio.
        :param path: list of absolute paths on VM with
                      expected DU build to update
        :param bts_id:  default BTS id
        :param du_id: default DU id
        :param success_rate: Target PASSED to RUNS ratio
        :param average_target: Target sw download time in seconds.
        :param timeout:  time in seconds to wait for sw download
        """
        maximum_target = 1.2 * float(average_target)
        runs = len(path)
        download_state = None
        passed = 0
        failed = 0
        passed_run_times = []
        for p in path:
            try:
                start_update_time = time.time()
                logging.info("Start SW download: {}".format(datetime.now()))
                download_state = self.admin.\
                    update_software(sw_package=p, should_activate=False,
                                    timeout=int(timeout),
                                    connection=self.rest_alias.
                                    format(bts_id, du_id))
                end_update_time = time.time()
                time.sleep(60)

                if download_state == 'Software update has been completed':
                    sw_download_duration = end_update_time - start_update_time
                    logging.info("SW Download duration of {}: {}".
                                 format(p, round(sw_download_duration, 2)))
                    if sw_download_duration < 300:
                        runs -= 1
                        logging.warning("Duration too short - build "
                                        "was already downloaded")
                    elif sw_download_duration <= maximum_target:
                        passed_run_times.append(round(sw_download_duration, 2))
                        passed += 1
                    else:
                        failed += 1
                else:
                    logging.warning("SW Download of {} with state {}"
                                    .format(p, download_state))
                    failed += 1

            except FileNotFound:
                logging.warning("FileNotFoundError: {}".format(p))
                runs -= 1

            except DataNotAvailable:
                logging.warning("DataNotAvailable: SW download "
                                "state of {} is {}".
                                format(p, download_state))
                failed += 1

        exceptions = []
        if len(passed_run_times) > 0:
            average_sw_download_time = sum(passed_run_times) / \
                len(passed_run_times)
            logging.info("Average SW download duration {}".
                         format(average_sw_download_time))

            if int(average_target) <= int(average_sw_download_time):
                exceptions.append(
                    AverageSwDownloadDurationNotMet(
                        "Average "
                        "download time "
                        "{}s exceed "
                        "presume value {}s". format(
                            average_sw_download_time,
                            average_target)))

            passed_ratio = passed / runs
            if float(passed_ratio) < float(success_rate):
                exceptions.append(
                    SwDownloadDurationNotMet("Runs: {}, Failed: {}, Ratio: {} "
                                             "Target not met".
                                             format(runs, failed, passed_ratio)
                                             ))

        if exceptions:
            raise SwDownloadDurationNotMet("\n".join([repr(e)
                                                      for e in exceptions]))
        elif runs == 0:
            raise SwDownloadDurationNotMet("No software download was "
                                           "performed.")
        else:
            logging.info("Runs: {}, Ratio: {}, Avg time: {} "
                         "Max time: {}".format(runs, passed_ratio,
                                               round(average_sw_download_time,
                                                     2),
                                               max(passed_run_times)))


class EnbBbu(GenericBbu):
    """Class contains Base keywords for eNB"""

    bts_type = 'ENB'

    def __init__(self):
        """
        Constructor of Enb class.
        """

        super(EnbBbu, self).__init__(bts_type=EnbBbu.bts_type)

    def _get_bts_state(self, bts_id=0, du_id=0):
        return str(self.admin.get_mrbts_state(connection=self.rest_alias.
                                              format(bts_id, du_id))).lower()

    @load_moler_configuration_from_tl()
    def verify_hanging_resources(self, enb_id=0, raise_exception=False,
                                 du_id=0):
        """
        Verify if hanging resources exist on BTS.

        :param enb_id: eNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit)-id related to
                      Test Line configuration - enb.dus[]
        :param raise_exception: If set to True - raise HangingResourcesDetected
                                exception.
                                Otherwise log warning
        """

        enb = DeviceFactory.get_device(name=self.ssh_alias.
                                       format(enb_id, du_id))
        vhr = HangingResources(device=enb)
        vhr.verify_hanging_resources(raise_exception=to_boolean(raise_exception
                                                                ))


class GnbBbu(GenericBbu):
    """Class contains Base keywords for gNB"""

    bts_type = 'GNB'

    def __init__(self):
        """
        Constructor of Gnb class.
        """
        super(GnbBbu, self).__init__(bts_type=GnbBbu.bts_type)

    def _get_bts_state(self, bts_id=0, du_id=0):
        statuses = self.admin.get_bts_statuses(connection=self.rest_alias.
                                               format(bts_id, du_id))
        try:
            bts_state = statuses['proceduralState'].lower()
        except KeyError as e:
            raise DataNotAvailable(
                "Cannot get BTS from response. Response: {}. "
                "Error details: {}".format(statuses, repr(e)))

        return bts_state

    @login_logout
    def get_cu_type(self, gnb_id=0, du_id=0):
        """
        Get the gNB CU Type i.e NSA or SA

        :param gnb_id: gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                      Test Line configuration - gnb.dus[]
        :return: gNB CU Type
        :rtype: str
        """
        mrbts = self.get_bts_instance_id(bts_id=gnb_id, du_id=du_id)
        nrbts = self.get_global_bts_id(bts_id=gnb_id, du_id=du_id)

        return self._get_object_parameters_dict(
            dist_name="MRBTS-{}/NRBTS-{}".format(mrbts, nrbts), bts_id=gnb_id,
            du_id=du_id)['gNbCuType']

    @load_moler_configuration_from_tl()
    @login_logout
    def precheck_for_cell_setup(self, gnb_id=0, du_id=0):
        """
        Verify BTS F1 setup and x2link listening port status
        :param gnb_id: gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
                       Test Line configuration - gnb.dus[]
        :return: None
        """
        bts = DeviceFactory.get_device(name=self.ssh_alias.
                                       format(gnb_id, du_id))
        bts.goto_state('FCT')
        netstat_cmd = bts.get_cmd(cmd_name='netstat',
                                  cmd_params={'options': '-na'})
        netstat_result = netstat_cmd()
        bts_cu_type = self.get_cu_type(bts_id=gnb_id, du_id=du_id)
        port = ":36422" if bts_cu_type == "NSA" else ":38462"
        for connection in netstat_result['INTERNET_CONNECTIONS']:
            if ':38472' in connection['local address'] or port in \
                    connection['local address']:
                if connection['state'] != 'LISTEN':
                    raise IncorrectParameterValue("{} is not in "
                                                  "'LISTEN' state".
                                                  format(connection))
