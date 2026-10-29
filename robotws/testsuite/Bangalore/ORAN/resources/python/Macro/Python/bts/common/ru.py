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
import re
import datetime
import time
import os

from taf.pdu import pdu
from taf.sbts.oam.coam.admin.exceptions import DataNotAvailable
from taf.internal.sbts.admin.exceptions \
    import AdminApiConnectionClosedException
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from moler.exceptions import CommandFailure, DeviceChangeStateFailure,\
    MolerException
from testsuite.Bangalore.ORAN.resources.python.Macro.\
    Python.utilities import load_moler_configuration_from_tl, \
    get_log_path
from testsuite.Bangalore.ORAN.resources.python.Macro.\
    Python.transfer_files import download_files
from testsuite.Bangalore.ORAN.resources.python.Macro.\
    Python.bts.generic_bts import GenericBts, login_logout,\
    login_logout_GUI
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    exceptions import (WrongRadioModuleStatus,
                       CertificateVerificationError,
                       WrongNumberOfRadios,
                       SshConnectionFailed,
                       ComponentIsNotOnline,
                       UptimeTooLong,
                       WrongParameterSettings,
                       FileNotFound,
                       WrongPduStatus,
                       ValidationError,
                       ListsAreNotEqual,
                       InvalidStatuses,
                       AmswissknifeOperationNotAvailable)
from testsuite.Bangalore.ORAN.resources.python.Macro.\
    Python.helpers import tl_config


class GenericRu(GenericBts):
    """RU(Radio Unit) keywords for eNB and gNB"""

    @load_moler_configuration_from_tl()
    def update_ru_ip_address_if_needed(self, bts_id=0, du_id=0):
        def remove_ip_address_from_dhcp_leases_dict(ru_ip):
            for _mac in dhcp_leases:
                if dhcp_leases[_mac]['ip'] == ru_ip:
                    del dhcp_leases[_mac]
                    break

        not_working_ru = []
        dhcp_leases = self.get_dhcp_leases(bts_id, du_id)
        number_of_ru_in_tl = tl_config.get_count_of_radios(
            bts_id=bts_id, du_id=du_id, bts_type=self.bts_type)
        for ru_id in range(number_of_ru_in_tl):
            ru_name = self.ssh_ru_alias.format(bts_id, du_id, ru_id)
            ru = DeviceFactory.get_device(name=ru_name,
                                          establish_connection=False)
            try:
                ru.goto_state('RU', log_stacktrace_on_fail=False)
                remove_ip_address_from_dhcp_leases_dict(ru.ru_ip_address)
            except (CommandFailure, DeviceChangeStateFailure):
                not_working_ru.append(ru_name)

        for ru_name in not_working_ru:
            for mac in dhcp_leases:
                ip = dhcp_leases[mac]['ip']
                container_id = dhcp_leases[mac]['container_id']

                ru = DeviceFactory.get_device(name=ru_name,
                                              establish_connection=False)
                logging.debug("[{}] Trying to use IP: [{}], CONTAINER: [{}]".
                              format(ru_name, ip, container_id))
                ru.ru_ip_address = ip
                ru.container_id = container_id
                try:
                    ru.goto_state('RU', log_stacktrace_on_fail=False)
                    logging.info("[{}] New RU parameters validated.\nIP:"
                                 " [{}]\nCONTAINER: [{}]".
                                 format(ru_name, ip, container_id))
                    del dhcp_leases[mac]
                    break
                except (CommandFailure, DeviceChangeStateFailure):
                    logging.debug("[{}] Go to RU state FAILED with "
                                  "IP [{}]".format(ru_name, ip))

    @login_logout
    def check_statuses_on_ru(self, bts_id=0, du_id=0, ru_id=1):
        """
        Check statuses on Radio Unit

        :param bts_id:          BTS id - related to Test
         Line configuration. Default: 0
        :type bts_id:           int
        :param du_id:           DU id - related to Test Line
        configuration - gnb.dus[]. Default: 0
        :return:                distName as string
        :param ru_id:           ID of radio unit. Default: 1
        :type ru_id:            int
        :rtype:                 dict
        """
        ru_status_check = self.admin.get_frm(
            connection=self.rest_alias.format(bts_id, du_id))
        ru_status = {"availabilityStatus": ru_status_check[ru_id-1]["status"]["availabilityStatus"],
                     "proceduralStatus": ru_status_check[ru_id-1]["status"]["proceduralStatus"],
                     "operationalState": ru_status_check[ru_id-1]["status"]["operationalState"],
                     "administrativeState": ru_status_check[ru_id-1]["status"]["administrativeState"]}

        return ru_status

    def verify_statuses_on_ru(self, bts_id=0, du_id=1, ru_id=1,
                              operational_state="enabled",
                              procedural_status="configured",
                              availability_status="online",
                              administrative_state="unlocked"):
        """
        Check statuses on Radio Unit

        :param bts_id:              BTS id - related to Test Line
         configuration. Default: 0
        :type bts_id:               int
        :param du_id:               DU id - related to Test Line
        configuration - gnb.dus[]. Default: 0
        :return:                    distName as string
        :param ru_id:               ID of radio unit. Default: 1
        :type ru_id:                int
        :param operational_state    expected operationalState of Radio Unit
        :type operational_state     str
        :param procedural_status    expected proceduralStatus of Radio Unit
        :type procedural_status     str
        :param availability_status  expected availabilityStatus of Radio Unit
        :type availability_status   str
        :param administrative_state expected administrativeState of Radio Unit
        :type administrative_state  str
        """
        expected_statuses = {
            "availabilityStatus": availability_status,
            "operationalState": operational_state,
            "proceduralStatus": procedural_status,
            "administrativeState": administrative_state
        }
        try:
            ru_statuses = self.check_statuses_on_ru(bts_id=bts_id,
                                                    du_id=du_id-1,
                                                    ru_id=ru_id)
            logging.info("ru status {}".format(ru_statuses))
            for status in expected_statuses:
                if expected_statuses[status].lower() != \
                        ru_statuses[status].lower():
                    logging.info("Expected status {},"
                                 " actual status {}".format(expected_statuses[status], ru_statuses[status]))
                    raise InvalidStatuses
        except KeyError as e:
            raise DataNotAvailable("Cannot get expected status"
                                   " info: {}".format(repr(e)))

    def _get_ru_dist_name(self, bts_id, ru_id, du_id=0):
        """
        Get whole distName for specified radio unit.

        :param bts_id:          BTS id - related to Test Line
         configuration. Default: 0
        :type bts_id:           int
        :param ru_id:   ID of radio unit. Default: 1
        :type ru_id:    int
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return:                distName as string
        :rtype:                 str
        """
        bts_runtime_info = self.admin.get_bts_info(
            connection=self.rest_alias.format(bts_id, du_id))
        _re_ru_dist_name = self.patterns.re_ru_dist_name.format(ru_id)
        determine_pattern = re.search(_re_ru_dist_name, str(bts_runtime_info))
        if not determine_pattern:
            raise DataNotAvailable("Radio Unit distName not found")
        else:
            return determine_pattern.group('RU_DIST_NAME')

    @login_logout
    def reset_radio_unit(self, bts_id=0, radio_unit_id=1,
                         du_id=0, timeout=120, force_radio_reset=False):
        """
        Reset radio unit with specified number from BTS side.
        :param bts_id:          BTS id - related to Test Line
        configuration. Default: 0
        :type bts_id:           int
        :param radio_unit_id:   ID of radio unit. Default: 1
        :type radio_unit_id:    int
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :param timeout: defaults to 120s
        :param force_radio_reset: defaults to False
        :return:                None
        """
        dist_name = self._get_ru_dist_name(
            bts_id=bts_id, ru_id=radio_unit_id, du_id=du_id)
        self.admin.reset_unit(
            dist_name, timeout=timeout, connection=self.rest_alias.format(
                bts_id, du_id), force_radio_reset=force_radio_reset)

    @login_logout
    def reset_all_radio_unit(self, bts_id=0, du_id=0):
        """
        Reset all radio units on gNB.
        :param bts_id:          BTS id - related to Test Line
         configuration. Default: 0
        :type bts_id:           int
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return:                None
        """
        all_ru_ids = self._get_all_radio_ids(bts_id=bts_id, du_id=du_id)
        for ru_id in all_ru_ids:
            dist_name = self._get_ru_dist_name(bts_id=bts_id,
                                               ru_id=ru_id,
                                               du_id=du_id)
            self.admin.reset_unit(
                dist_name, timeout=120,
                connection=self.rest_alias.format(bts_id, du_id))

    @login_logout_GUI
    def reset_radio_unit_from_GUI(self, bts_id=0, radio_unit_id=1, du_id=0):
        """
        Reset radio unit with specified number from BTS side.
        :param bts_id:          BTS id - related to Test
         Line configuration. Default: 0
        :type bts_id:           int
        :param radio_unit_id:   ID of radio unit. Default: 1
        :type radio_unit_id:    int
        :param du_id: DU id(Distributed Unit) - id related
         to Test Line configuration - gnb.dus[]
        :return:                None
        """
        self.gui_coam.reset_ru_from_site_view(
            ru_index=radio_unit_id, timeout=60, type_="RMOD")

    @login_logout
    def reset_all_radio_unit_from_GUI(self, bts_id=0, du_id=0):
        """
        Reset all radio units on gNB.
        :param bts_id:          BTS id - related to Test
         Line configuration. Default: 0
        :type bts_id:           int
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return:                None
        """

        all_ru_ids = self._get_all_radio_ids(bts_id=bts_id, du_id=du_id,
                                             runtime=False)
        for ru_id in all_ru_ids:
            self.reset_radio_unit_from_GUI(bts_id=bts_id,
                                           radio_unit_id=ru_id, du_id=du_id)

    @login_logout_GUI
    def get_radio_unit_led_status_from_GUI(self, bts_id=0, ru_id=0, du_id=0):
        """
        Get Radio Unit LED status from WebUi.
        :param bts_id:          BTS id - related to Test
        Line configuration. Default: 0
        :type bts_id:           int
        :param ru_id:   ID of radio unit. Default: 0
        :type ru_id:    int
        :param du_id:           ID of Distribution Unit. Default: 0
        :type du_id:            int
        :return:                Radio Unit Led Status
        :param logout:          If logout from WebUI at the end
        :type  logout:          boolean
        :rtype:                 str
        """

        hw_name = tl_config.get_radio_unit_type(bts_id=bts_id,
                                                du_id=du_id, ru_id=ru_id,
                                                bts_type="GNB")
        hw_info = self.gui_coam.get_hw_info(hw_name)
        return hw_info["Status"]["Availability status"]

    def verify_radio_unit_online_led_status(self, bts_id=0, du_id=0, ru_id=0):
        """
        Verify if Radio Unit LED status equals to "Online" string.
        :param bts_id:          BTS id - related to Test
         Line configuration. Default: 0
        :type bts_id:           int
        :param ru_id:   ID of radio unit. Default: 0
        :type ru_id:    int
        :param du_id:           ID of Distribution Unit. Default: 0
        :type du_id:            int
        :return:                Radio Unit Led Status
        :param logout:          Flag for logout from WebUI at the end
        :type  logout:          boolean
        """
        ru_status = self.get_radio_unit_led_status_from_GUI(
            bts_id=bts_id, du_id=du_id, ru_id=ru_id)
        if ru_status != "Online":
            raise WrongRadioModuleStatus(
                "{} is not in Online status. "
                "Current status is: {}".format(ru_id, ru_status)
            )

    def verify_radio_unit_offline_led_status(self, bts_id=0, du_id=0, ru_id=0):
        """
        Verify if Radio Unit LED status equals to "Offline" string.
        :param bts_id:          BTS id - related to Test Line
        configuration. Default: 0
        :type bts_id:           int
        :param ru_id:   ID of radio unit. Default: 0
        :type ru_id:    int
        :param du_id:           ID of Distribution Unit. Default: 0
        :type du_id:            int
        :return:                Radio Unit Led Status
        :param logout:          Flag for logout from
         WebUI at the end
        :type  logout:          boolean
        """
        ru_status = self.get_radio_unit_led_status_from_GUI(bts_id=bts_id,
                                                            du_id=du_id,
                                                            ru_id=ru_id)
        if ru_status != "Offline":
            raise WrongRadioModuleStatus(
                "{} is not in Offline status. Current "
                "status is: {}".format(ru_id, ru_status)
            )

    def verify_radio_unit_not_installed_led_status(
            self, bts_id=0, du_id=0, ru_id=0):
        """
        Verify if Radio Unit LED status equals to
        "NotInstalled" string.
        :param bts_id:          BTS id - related to Test
         Line configuration. Default: 0
        :type bts_id:           int
        :param ru_id:   ID of radio unit. Default: 0
        :type ru_id:    int
        :param du_id:           ID of Distribution Unit.
        Default: 0
        :type du_id:            int
        :return:                Radio Unit Led Status
        :param logout:          Flag for logout from
        WebUI at the end
        :type  logout:          boolean
        """
        ru_status = self.get_radio_unit_led_status_from_GUI(
            bts_id=bts_id, du_id=du_id, ru_id=ru_id)
        if ru_status != "NotInstalled":
            raise WrongRadioModuleStatus(
                "{} is not in NotInstalled status. Current"
                " status is: {}".format(ru_id, ru_status)
            )

    def get_count_of_radio_extension_modules(self, bts_id=0, du_id=0,
                                             ru_id=None):
        """
        Get count of radio extension modules from testline
        configuration under specific ru, or if ru_id = None
        get count of all radio extension modules
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :param ru_id: Radio unit id
        :return: count of radio extension modules
        """
        if ru_id is None:
            number_of_radio_extension_modules = 0
            number_of_ru = tl_config.get_count_of_radios(
                bts_id=bts_id, du_id=du_id, bts_type=self.bts_type)
            for radio_unit_id in range(number_of_ru):
                number_of_radio_extension_modules += \
                    self.get_count_of_radio_extension_modules(
                        bts_id=bts_id,
                        du_id=du_id,
                        ru_id=radio_unit_id)
        else:
            number_of_radio_extension_modules = \
                tl_config.get_count_of_ru_extensions(bts_id=bts_id,
                                                     du_id=du_id,
                                                     ru_id=ru_id,
                                                     bts_type=self.bts_type)
        return number_of_radio_extension_modules

    def get_count_of_radios(self, bts_id=0, du_id=0):
        """
        Get count of radios in Test Line configuration
        :param bts_id:  BTS id - related to Test
         Line configuration.
        :param du_id: DU id(Distributed Unit) - id related
         to Test Line configuration - gnb.dus[]
        :return: count of radios
        """
        number_of_ru = tl_config.get_count_of_radios(
            bts_id=bts_id, du_id=du_id, bts_type=self.bts_type)
        return number_of_ru

    def power_reset_radio_unit(
            self, bts_id=0, radio_unit_id=None, du_id=0):
        """
        Power reset Radio Unit using pdu.
        :param bts_id:    int, BTS id - related to
        Test Line configuration.
        :param radio_unit_id:    position of RU in rus table
        from Test Line configuration.
                                 If None all radio units are reset.
        :param du_id: DU id(Distributed Unit) - id related to
         Test Line configuration - gnb.dus[]
        """
        if radio_unit_id is None:
            number_of_ru = tl_config.get_count_of_radios(
                bts_id=bts_id, du_id=du_id, bts_type=self.bts_type)
            for ru_id in range(number_of_ru):
                self.power_reset_radio_unit(
                    bts_id=bts_id, radio_unit_id=ru_id, du_id=du_id)
            return

        obj_pdu, pdu_config = self._radio_pdu_setup(
            bts_id=bts_id, du_id=du_id, ru_id=radio_unit_id)
        obj_pdu.power_off(pdu_config.port_no)
        port_nr = pdu_config.port_no
        obj_pdu.power_off(port_nr)
        time.sleep(5)
        port_status = obj_pdu.get_port_status(port=port_nr)
        if port_status == "off":
            logging.info("Port {} powered off for RU{}".format(port_nr, radio_unit_id))
        else:
            raise WrongPduStatus("Port {} is not OFF for RU{}".format(
                port_nr, radio_unit_id))

        obj_pdu.power_on(pdu_config.port_no)
        time.sleep(10)
        port_status = obj_pdu.get_port_status(port=port_nr)
        if port_status == "on":
            logging.info("Port {} powered on for RU{}".format(
                port_nr, radio_unit_id))
        else:
            raise WrongPduStatus("Port {} is "
                                 "not ON for RU{}".format(port_nr, radio_unit_id))

    @login_logout
    def verify_if_rau_and_rac_are_online(self, bts_id=0, du_id=0):
        """
        Verify is RAC and RAU are online
        :param bts_id:          BTS id - related to
        Test Line configuration. Default: 0
        :param du_id: DU id(Distributed Unit) - id related
         to Test Line configuration - gnb.dus[]
        """
        bts_info = self.admin.get_bts_info(
            connection=self.rest_alias.format(bts_id, du_id))
        rac = bts_info['basebandModules'][0]['status']['availabilityStatus']
        rau = bts_info['systemModules'][0]['status']['availabilityStatus']
        if rac != 'Online' and rau != "Online":
            raise ComponentIsNotOnline("RAU and RAC should be online,"
                                       " but are: RAU is {} and "
                                       "RAC is {}"
                                       .format(rau, rac))

    @login_logout_GUI
    def lock_radio_unit_from_GUI(self, bts_id=0, radio_unit_id=1,
                                 du_id=0):
        """
        Lock radio unit with specified number from BTS side.
        :param bts_id:          BTS id - related to Test Line
         configuration. Default: 0
        :type bts_id:           int
        :param radio_unit_id:   ID of radio unit. Default: 1
        :type radio_unit_id:    int
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :type du_id:            int
        :return:                None
        """
        self.gui_coam.lock_ru(ru_index=radio_unit_id, timeout=60,
                              type_="RMOD")

    @login_logout_GUI
    def unlock_radio_unit_from_GUI(self, bts_id=0, radio_unit_id=1,
                                   du_id=0):
        """
        Unlock radio unit with specified number from BTS side.
        :param bts_id:          BTS id - related to Test Line
         configuration. Default: 0
        :type bts_id:           int
        :param radio_unit_id:   ID of radio unit. Default: 1
        :type radio_unit_id:    int
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :type du_id:            int
        :return:                None
        """
        self.gui_coam.unlock_ru(
            ru_index=radio_unit_id, timeout=60, type_="RMOD")

    @login_logout
    def lock_radio_unit(self, bts_id=0, radio_unit_id=1,
                        du_id=0):
        """
        Lock radio unit on gNB.
        :param bts_id:          BTS id - related to Test
         Line configuration. Default: 0
        :type bts_id:           int
        :param radio_unit_id:   ID of radio unit. Default: 1
        :type radio_unit_id:    int
        :param du_id: DU id(Distributed Unit) - id related to
         Test Line configuration - gnb.dus[]
        :return:                None
        """
        dist_name = self._get_ru_dist_name(
            bts_id=bts_id, ru_id=radio_unit_id, du_id=du_id)
        self.admin.lock_RU(
            dist_name, connection=self.rest_alias.format(bts_id,
                                                         du_id))

    @login_logout
    def unlock_radio_unit(self, bts_id=0, radio_unit_id=1,
                          du_id=0):
        """
        Unlock radio unit on gNB.
        :param bts_id:          BTS id - related to Test
        Line configuration. Default: 0
        :type bts_id:           int
        :param radio_unit_id:   ID of radio unit. Default: 1
        :type radio_unit_id:    int
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return:                None
        """
        dist_name = self._get_ru_dist_name(
            bts_id=bts_id, ru_id=radio_unit_id, du_id=du_id)
        self.admin.unlock_RU(
            dist_name, connection=self.rest_alias.format(bts_id,
                                                         du_id))

    @login_logout
    def lock_all_radio_unit(self, bts_id=0, du_id=0):
        """
        Lock all radio unit on gNB.
        :param bts_id:          BTS id - related to
        Test Line configuration. Default: 0
        :type bts_id:           int
        :param du_id: DU id(Distributed Unit) - id related
        to Test Line configuration - gnb.dus[]
        :return:                None
        """
        all_ru_ids = self._get_all_radio_ids(bts_id=bts_id, du_id=du_id)
        for ru_id in all_ru_ids:
            dist_name = self._get_ru_dist_name(
                bts_id=bts_id, ru_id=ru_id, du_id=du_id)
            self.admin.lock_RU(dist_name,
                               connection=self.rest_alias.format(
                                   bts_id, du_id))

    @login_logout
    def unlock_all_radio_unit(self, bts_id=0, du_id=0):
        """
        Unlock all radio unit on gNB.
        :param bts_id:          BTS id - related to Test
        Line configuration. Default: 0
        :type bts_id:           int
        :param du_id: DU id(Distributed Unit) - id related t
        o Test Line configuration - gnb.dus[]
        :return:                None
        """
        all_ru_ids = self._get_all_radio_ids(bts_id=bts_id, du_id=du_id)
        for ru_id in all_ru_ids:
            dist_name = self._get_ru_dist_name(
                bts_id=bts_id, ru_id=ru_id, du_id=du_id)
            self.admin.unlock_RU(dist_name,
                                 connection=self.rest_alias.format(
                                     bts_id, du_id))

    def _radio_pdu_setup(self, bts_id=0, du_id=0, ru_id=0):
        """
        Prepares PDU configuration for RU and returns a tuple
        of PDU object and prepared PDU configuration for specific
        PDU type.
        :param bts_id:          BTS ID - related to TL configuration
        :param du_id:           Distributed Unit ID
        :param ru_id:           Radio Unit ID
        :return:                Tuple of set up PDU object and
        prepared PDU configuration.
        """
        obj_pdu = pdu()
        bts_conf = self.get_bts_config(bts_id)
        pdu_config = bts_conf.dus[int(du_id)].rus[int(ru_id)].pdu_port
        pdu_attributes = [a for a in dir(pdu_config.pdu)
                          if not (a.startswith('__'))]
        pdu_values = [getattr(pdu_config.pdu, a) for a in
                      pdu_attributes]
        pdu_dict = dict(zip(pdu_attributes, pdu_values))
        model = pdu_dict.pop('vendor')
        host = pdu_dict.pop('addr')
        pdu_dict.pop('pdu_ports')
        pdu_dict.pop('port_numbers')
        for k in list(pdu_dict.keys()):
            if not pdu_dict[k]:
                del pdu_dict[k]
        pdu_dict['model'] = model
        pdu_dict['host'] = host
        obj_pdu.setup_pdu(**pdu_dict)
        return obj_pdu, pdu_config

    def radio_unit_power_off(self, bts_id=0, radio_unit_id=None,
                             du_id=0, confirm=True):
        """
        Power off radio unit using PDU
        :param bts_id:          BTS id - related to Test Line
         configuration. Default: 0
        :param radio_unit_id:    position of RU in rus table
        from Test Line configuration.
                                 If None all RUs are powered off.
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :param confirm: if true set value will be checked afterwards
        and if it is not set the exception is raised
        """
        if radio_unit_id is None:
            number_of_ru = tl_config.get_count_of_radios(
                bts_id=bts_id, du_id=du_id, bts_type=self.bts_type)
            for ru_id in range(number_of_ru):
                self.radio_unit_power_off(
                    bts_id=bts_id, radio_unit_id=ru_id, du_id=du_id)
            return

        obj_pdu, pdu_config = self._radio_pdu_setup(
            bts_id=bts_id, du_id=du_id, ru_id=radio_unit_id)
        obj_pdu.power_off(pdu_config.port_no)
        port_nr = pdu_config.port_no
        if confirm:
            time.sleep(10)
            port_status = obj_pdu.get_port_status(port=port_nr)
            if port_status == "off":
                logging.info("Port {} powered off for"
                             " RU{}".format(port_nr, radio_unit_id))
            else:
                raise WrongPduStatus("Port {} is not OFF "
                                     "for RU{}".format(port_nr, radio_unit_id))

    def radio_unit_power_on(self, bts_id=0, radio_unit_id=None,
                            du_id=0, confirm=True):
        """
        Power on radio unit using PDU
        :param bts_id:          BTS id - related to Test Line
         configuration. Default: 0
        :param radio_unit_id:    position of RU in rus table from
        Test Line configuration.
                                 If None all RUs are powered on.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :param confirm: if true set value will be checked afterwards
        and if it is not set the exception is raised
        """
        if radio_unit_id is None:
            number_of_ru = tl_config.get_count_of_radios(bts_id=bts_id,
                                                         du_id=du_id,
                                                         bts_type=self.bts_type)
            for ru_id in range(number_of_ru):
                self.radio_unit_power_on(bts_id=bts_id,
                                         radio_unit_id=ru_id,
                                         du_id=du_id)
            return
        obj_pdu, pdu_config = self._radio_pdu_setup(bts_id=bts_id,
                                                    du_id=du_id,
                                                    ru_id=radio_unit_id)
        obj_pdu.power_off(pdu_config.port_no)
        port_nr = pdu_config.port_no
        obj_pdu.power_on(port_nr)
        if confirm:
            time.sleep(10)
            port_status = obj_pdu.get_port_status(port=port_nr)
            if port_status == "on":
                logging.info("Port {} powered on for RU{}".format(
                    port_nr, radio_unit_id))
            else:
                raise WrongPduStatus("Port {} is not ON for RU{}".format(
                    port_nr, radio_unit_id))

    def _verify_radio_module_status(self, bts_state, operational_state,
                                    availability_status,
                                    administrative_state):
        """
        Check if statuses of all params are correct
        :param bts_state            BTS state - related to Test
         Line status. Default: online
        :type bts_state:            basestring
        :param operational_state    Operational state of bts.
         Default: none
        :type operational_state     basestring
        :param availability_status  Availability status of BTS.
         Default: none
        :type availability_status   basestring
        :param administrative_state BTS state checked only if BTS
         state is locked or unlocked
        :type administrative_state  basestring
        :return                     none
        """
        info = ("BTS status is: {}, operational state is: {}, "
                "availability status is: {},administrative state "
                "is: {}".format(bts_state, operational_state,
                                availability_status,
                                administrative_state))

        if bts_state == "online" and operational_state == "Enabled" and \
                availability_status == "Online":
            logging.info(info)
        elif bts_state == "offline" and operational_state == "Disabled" and\
                availability_status == "Offline":
            logging.info(info)
        elif bts_state == "locked" and operational_state == "Enabled" and \
                availability_status == "Online" \
                and administrative_state == "Locked":
            logging.info(info)
        elif bts_state == "unlocked" and operational_state == "Enabled" and\
                availability_status == "Online" \
                and administrative_state == "Unlocked":
            logging.info(info)
        elif bts_state == "unavailable" and operational_state == "Disabled" \
                and availability_status == "NotInstalled":
            logging.info(info)
        elif bts_state == "degraded" and operational_state == "Enabled" \
                and availability_status == "Degraded":
            logging.info(info)
        else:
            raise WrongRadioModuleStatus(info)

    @login_logout
    def verify_radio_unit_status(self, radio_unit_id=1, bts_id=0,
                                 bts_state="online", du_id=0):
        """
         Check radio unit statuses for given radio.
         :param radio_unit_id:  RU ID - related to RMODs
         configuration. Default: 1
         :param bts_id:      BTS id - related to Test Line
         configuration. Default: 0
         :param bts_state:   BTS state - related to Test Line
          status. Default: online
         :param du_id: DU id(Distributed Unit) - id related to
         Test Line configuration - gnb.dus[]
         :return:
         """
        rmod_info = self._get_ru_info(bts_id, du_id, radio_unit_id)
        operational_state = (rmod_info["status"]["operationalState"])
        availability_status = (rmod_info["status"]["availabilityStatus"])
        administrative_state = (rmod_info["status"]["administrativeState"])
        self._verify_radio_module_status(bts_state,
                                         operational_state,
                                         availability_status,
                                         administrative_state)

    @login_logout
    def verify_all_radio_module_status(self, bts_id=0,
                                       bts_state="online",
                                       du_id=0):
        """
        Get number of radios, and check module status for each one
        :param bts_id:      BTS id - related to Test Line
        configuration. Default: 0
        :param bts_state:   BTS state - related to Test Line status.
         Default: online
        :param du_id: DU id(Distributed Unit) - id related to
         Test Line configuration - gnb.dus[]
        :return:
        """
        attempt = 1
        max_attempts = 3
        while attempt <= max_attempts:
            try:
                bts_info = self.admin.get_bts_info(
                    connection=self.rest_alias.format(bts_id, du_id), timeout=60)
                rmods_info = bts_info["radioModules"]["rmod"]
                frm_info = self.admin.get_frm(
                    connection=self.rest_alias.format(bts_id, du_id),
                    timeout=60)
                break
            except AdminApiConnectionClosedException as e:
                logging.warning(
                    "[AdminApiConnectionClosedException] {}".format(repr(e)))
                self.disconnect(bts_id=bts_id, du_id=du_id)
                self.connect(bts_id=bts_id, du_id=du_id)

            attempt = attempt + 1

        number_of_radios = len(frm_info)
        ru_in_wrong_status = []
        for radio_index in range(number_of_radios):
            operational_state = (
                rmods_info[radio_index]["status"]["operationalState"])
            availability_status = (
                rmods_info[radio_index]["status"]["availabilityStatus"])
            administrative_state = (
                rmods_info[radio_index]["status"]["administrativeState"])
            try:
                self._verify_radio_module_status(
                    bts_state, operational_state, availability_status,
                    administrative_state)
            except WrongRadioModuleStatus as e:
                ru_in_wrong_status.append({"ru_id": int(rmods_info[radio_index]['id']['configuration'][-1]),
                                           "error msg": e})
        if ru_in_wrong_status:
            raise WrongRadioModuleStatus("Wrong statuses for "
                                         "RU IDs: {}".format(ru_in_wrong_status), ru_in_wrong_status)

    def wait_for_radio_unit_online_status(self, radio_unit_id=None,
                                          timeout=300, step=20,
                                          bts_id=0, du_id=0):
        """

        :param radio_unit_id:  RU ID - related to RMODs
        configuration. If None wait for all RUs. Default: None
        :param bts_id:         BTS id - related to Test Line
        configuration. Default: 0
        :param timeout:        time in seconds the method waits
        for ru online status
        :param step:           time interval in seconds
        :param du_id: DU id(Distributed Unit) - id related to
         Test Line configuration - gnb.dus[]
        :return: None
        """
        start_time = time.time()
        while (time.time() - start_time) < timeout:
            try:
                if radio_unit_id is None:
                    logging.info("Checking if all RUs are online")
                    self.verify_all_radio_module_status(bts_id=bts_id,
                                                        du_id=du_id)
                else:
                    logging.info("Checking if RU{} is online".format(radio_unit_id))
                    self.verify_radio_unit_status(radio_unit_id=radio_unit_id,
                                                  bts_id=bts_id, du_id=du_id)
                return
            except WrongRadioModuleStatus:
                logging.warning(
                    "RU{} not online. Checking again...".format(
                        "s" if radio_unit_id is None else
                        radio_unit_id))
                time.sleep(step)
        raise WrongRadioModuleStatus(
            "RU{} not online after {}s of waiting".format(
                "s" if radio_unit_id is None else
                radio_unit_id, timeout))

    def _get_all_radio_ids(self, bts_id=0, du_id=0, runtime=True,
                           extension=False):
        """
        Get list of radio unit ids
        :param bts_id:      BTS id - related to Test Line
        configuration. Default: 0
        :param du_id: DU id(Distributed Unit) - id related
        to Test Line configuration - gnb.dus[]
        :param runtime:     If True use runtime radio object,
        if False configuration radio object. Default True
        :param extension:   If True get ids for all radio
        units - including extensions.

        :return:             list of all available radio unit IDs
        """
        radio_ids = list()
        all_ru_info = self.admin.get_frm(
            connection=self.rest_alias.format(bts_id, du_id))
        for ru_info in all_ru_info:
            if self._is_extension_radio(ru_info) and not extension:
                continue
            if runtime:
                ru_name = ru_info['id']['runtime']
            else:
                ru_name = ru_info['id']['configuration']
            pattern = re.search(r'(?P<RU_ID>\d+)$', ru_name)
            radio_id = pattern.group("RU_ID")
            if radio_id is None:
                raise DataNotAvailable("Radio Unit ID not found")
            radio_ids.append(int(radio_id))
        return radio_ids

    @staticmethod
    def _is_extension_radio(ru_info):
        _re_am_port = re.compile(r'^AM\d+$')
        for port_info in ru_info['ports']:
            if _re_am_port.search(port_info['label']):
                return True
        return False

    @load_moler_configuration_from_tl()
    def get_dhcp_leases(self, bts_id=0, du_id=0):
        """
        Get dhcp lease from file and put into dictionary
        :param bts_id:    BTS id - related to Test Line
         configuration. Default: 0
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return: {78:f9:b4:9f:d3:cf} = {
                    "ip": 192.168.254.145,
                    "starts": 2020/04/15 06:40:43,
                    "ends": 2020/04/15 06:47:43,
                    "cltt": 2020/04/15 06:47:43,
                    "vendor-class-identifier": LLS-MP-1-RM,
                    "radio_variant": ECPRI_RP1,
                    'container_id': '0x1018'
                }
        """
        bts = DeviceFactory.get_device(name=self.ssh_alias.format(
            bts_id, du_id))
        ssh_leases_dict = dict()
        container_id = self._get_container_id_gnb2ru(dev_name=bts.name)
        bts.change_fhnet_container_id(container_id=container_id)
        if container_id is not None:
            bts.goto_state("FHNET")
            leases_file_name = 'dhcp.leases'
            lease_dir_path_v1 = r'/var/tmp/radio-dhcpd/'
            lease_dir_path_v2 = r'/ram/radio-dhcpd/'
            try:
                bts.get_cmd(cmd_name="ls",
                            cmd_params={"path": lease_dir_path_v1})()
                lease_path = os.path.join(lease_dir_path_v1, leases_file_name)
            except CommandFailure:
                lease_path = os.path.join(lease_dir_path_v2, leases_file_name)
        else:
            bts.goto_state("FCT")
            lease_path = r'/tmp/radio-dhcpd/dhcp.leases'
        cat_cmd = bts.get_cmd(cmd_name="cat", cmd_params={"path": lease_path})
        output = cat_cmd()['LINES']
        ip_pattern = re.compile(r'\d+(?:\.\d+){3}')
        ethernet_pattern = re.compile(
            r'\s*hardware\s+ethernet\s+(?P<Adress>.+);')
        starts_pattern = re.compile(r'\s*starts\s+\d\s+(?P<Datetime>.+);')
        ends_pattern = re.compile(r'\s*ends\s+\d\s+(?P<Datetime>.+);')
        cltt_pattern = re.compile(r'\s*cltt\s+\d\s+(?P<Datetime>.+);')
        vendor_pattern = re.compile(
            r'\s*set\s+vendor-class-identifier\s=\s"+(?P<Vci>.+)";')
        radio_variant_pattern = re.compile(
            r'\s*set\s+radio_variant\s=\s"+(?P<Variant>.+)";')
        closing_bracket_pattern = re.compile(r'}$')
        inner_dict = dict.fromkeys(["ip", "starts", "ends", "cltt",
                                    "vendor-class-identifier",
                                    "radio_variant"])
        for lines in output:
            ips = ip_pattern.search(lines)
            ethernets = ethernet_pattern.match(lines)
            starts = starts_pattern.match(lines)
            ends = ends_pattern.match(lines)
            cltts = cltt_pattern.match(lines)
            vendor_class_identifier = vendor_pattern.match(lines)
            radio_variant = radio_variant_pattern.match(lines)
            closing_bracket = closing_bracket_pattern.match(lines)
            inner_dict['container_id'] = container_id
            if ips is not None:
                inner_dict["ip"] = ips.group(0)
            elif ethernets is not None:
                ethernet = ethernets.group('Adress')
            elif starts is not None:
                inner_dict["starts"] = starts.group('Datetime')
            elif ends is not None:
                inner_dict["ends"] = ends.group('Datetime')
            elif cltts is not None:
                inner_dict["cltt"] = cltts.group('Datetime')
            elif vendor_class_identifier is not None:
                inner_dict["vendor-class-identifier"] = \
                    vendor_class_identifier.group('Vci')
            elif radio_variant is not None:
                inner_dict["radio_variant"] = radio_variant.group(
                    'Variant')
            elif closing_bracket is not None:
                ssh_leases_dict[ethernet] = inner_dict
                inner_dict = dict.fromkeys(["ip", "starts", "ends",
                                            "cltt",
                                            "vendor-class-identifier",
                                            "radio_variant"])
        logging.debug("ssh_leases_dict: {}".format(ssh_leases_dict))
        return ssh_leases_dict

    def get_valid_dhcp_leases(self, bts_id=0, du_id=0):
        """
        Verify if current date is between start and end date
        from DHCP file
        :param bts_id:    BTS id - related to Test Line
        configuration. Default: 0
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return: {"78:f9:b4:9f:d3:cf": {
                    "ip": 192.168.254.145,
                    "starts": 2020/04/15 06:40:43,
                    "ends": 2020/04/15 06:47:43,
                    "cltt": 2020/04/15 06:47:43,
                    "vendor-class-identifier": LLS-MP-1-RM,
                    "radio_variant": ECPRI_RP1,
                     "container_id": "0x1018"
                }
            }
        """
        ssh_leases_dict = self.get_dhcp_leases(bts_id=bts_id, du_id=du_id)
        time_format = "%Y/%m/%d %H:%M:%S"
        current_time_format = "%d-%m-%Y %H:%M:%S"
        bts = DeviceFactory.get_device(name=self.ssh_alias.format(bts_id,
                                                                  du_id))
        date_cmd = bts.get_cmd(cmd_name="date", cmd_params={'options': "-u"})
        date_time = date_cmd()
        get_time = "{} {}".format(
            date_time["DATE"]["FULL"], date_time["TIME"]["FULL"])
        ssh_leases_dict_valid = dict()
        for key in ssh_leases_dict.keys():
            values_dict = ssh_leases_dict[key]
            start_time = time.mktime(datetime.datetime.strptime(
                values_dict['starts'], time_format).timetuple())
            end_time = time.mktime(datetime.datetime.strptime(
                values_dict['ends'], time_format).timetuple())
            current_time = time.mktime(datetime.datetime.strptime(
                get_time, current_time_format).timetuple())
            if (start_time <= current_time) and (current_time <= end_time):
                ssh_leases_dict_valid[key] = ssh_leases_dict[key]
        return ssh_leases_dict_valid

    @load_moler_configuration_from_tl()
    def _get_ru_ssh_params(self, number_of_ru, bts_id=0, du_id=0):
        """
        From dhcp config file get parameters which allowed
        ssh connection
        :param number_of_ru: number of radio unit in webem
        :param bts_id:    BTS id - related to Test Line
         configuration. Default: 0
        :param du_id: DU id(Distributed Unit) - id related
        to Test Line configuration - gnb.dus[]
        :return: {'login':root,
                  'password': asmr,
                  'expected_prompt': r'[.*hw-.*] .*?$?}
        """
        ssh_params_list = []
        for index in range(number_of_ru):
            ru = DeviceFactory.get_device(
                name=self.ssh_ru_alias.format(bts_id, du_id, index),
                establish_connection=False)
            configuration = ru.get_configurations(source_state='FHNET', dest_state='RU')
            ssh_params = {'login': configuration['command_params']['login'],
                          'password': configuration['command_params']['password'],
                          'expected_prompt': configuration['command_params']['expected_prompt']}
            if ssh_params not in ssh_params_list:
                ssh_params_list.append(ssh_params)
        return ssh_params_list

    def verify_connection_with_all_ru(self, dhcp_dict, bts_id=0, du_id=0):
        """
        Connect via ssh with all radio units connected to BTS
        :param dhcp_dict: dictionary with dhcp config
        :param bts_id:    BTS id - related to Test Line
         configuration. Default: 0
        :param du_id: DU id(Distributed Unit) - id related to
         Test Line configuration - gnb.dus[]
        """
        number_of_ru_in_tl = tl_config.get_count_of_radios(
            bts_id=bts_id, du_id=du_id, bts_type=self.bts_type)
        if number_of_ru_in_tl == len(dhcp_dict.keys()):
            ssh_params_list = self._get_ru_ssh_params(
                number_of_ru=number_of_ru_in_tl,
                bts_id=bts_id, du_id=du_id)
        else:
            raise WrongNumberOfRadios("Number of radios in BTS config is not"
                                      " equal to number of radios in DHCP "
                                      "config")
        self.update_ru_ip_address_if_needed(bts_id=bts_id, du_id=du_id)
        counter = 0
        for radio_index, mac_adress in enumerate(dhcp_dict):
            ip_adress = dhcp_dict[mac_adress]['ip']
            for ssh_params in ssh_params_list:
                bts = DeviceFactory.get_device(
                    name=self.ssh_alias.format(bts_id, du_id))
                if self._get_container_id_gnb2ru(bts.name):
                    logging.info("Go to state FHNET...")
                    bts.goto_state("FHNET")
                expected_prompt = r'{}'.format(ssh_params['expected_prompt'])
                ssh_cmd = self._ssh_to_ru(ip_adress, ssh_params['login'],
                                          ssh_params['password'],
                                          expected_prompt, bts_id, du_id)
                exit_cmd = bts.get_cmd(cmd_name="exit")
                try:
                    ssh_cmd()
                    logging.info("connected to RU{} "
                                 "from {} RUs".format(radio_index,
                                                      number_of_ru_in_tl))
                    exit_cmd()
                    break
                except CommandFailure:
                    counter = counter+1
                    logging.info("counter: {}".format(counter))
                    if counter == len(ssh_params_list):
                        raise SshConnectionFailed("SSH failed, couldn't "
                                                  "login to RU with"
                                                  " given params")
                    continue

    @load_moler_configuration_from_tl()
    def verify_configuration_parameters_in_soap_logs(
            self, rx_tx_parameters=None, parameters=None, bts_id=0,
            du_id=0):
        """
        Verify if rx and tx parameters have the same values and if
        other parameter is equal given value
        :param rx_tx_parameters: list of parameters to find in soap
        logs in rx and tx
        :param parameters: dictionary of parameters and values to
         check in soap logs
        :param bts_id: BTS id - related to Test Line configuration.
         Default: 0
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        """
        self.update_ru_ip_address_if_needed(bts_id=bts_id, du_id=du_id)
        soap_files = self._download_soap_file(local_dir="/tmp",
                                              bts_id=bts_id,
                                              du_id=du_id)
        for soap_file in soap_files:
            param_dict = self._get_parameter_from_soap_file(
                file_path=soap_file, rx_tx_parameters=rx_tx_parameters,
                parameters=parameters)
            if rx_tx_parameters is not None:
                for rx_tx_parameter in rx_tx_parameters:
                    first_list_element = param_dict['tx'][rx_tx_parameter][0]
                    if all(elem ==
                           first_list_element for elem in
                           param_dict['tx'][rx_tx_parameter])\
                            and all(elem ==
                                    first_list_element
                                    for elem in
                                    param_dict['rx'][rx_tx_parameter]):
                        continue
                    else:
                        raise WrongParameterSettings(
                            "tx and rx versions of {} are "
                            "not equal".format(rx_tx_parameter))
            if parameters is not None:
                for key in parameters:
                    for index in range(len(param_dict['param'][key])):
                        parameter = param_dict['param'][key][index]
                        if int(parameter) < 0 or int(parameter) > 255:
                            raise WrongParameterSettings("{} is not between "
                                                         "0 and 255. Value "
                                                         "is {}"
                                                         .format(parameters,
                                                                 parameter))

    def _get_parameter_from_soap_file(self, file_path,
                                      rx_tx_parameters=None, parameters=None):
        """
        For list of rx and tx parameters and dictionary of
        other paramters function returns dictionary with parameter
        values, divided for rx, tx, and parameter.
        :param file_path: path to soap file
        :param rx_tx_parameters: list of parameters to find in soap
         logs in rx and tx
        :param parameters: dictionary of parameters and values to
        check in soap logs
        :return: param_dict with 3 main key, rx, tx, and param,
        conataining dictionaries, with parameter as main key
        and i.e as value list of values taken from sopa file
         {
             'rx':  {
                    u'cyclicPrefix': ['NORMAL_CP', 'NORMAL_CP',
                     'NORMAL_CP', 'NORMAL_CP'],
                    u'defaultSubcarrierSpacing': ['KHZ_120',
                     'KHZ_120', 'KHZ_120', 'KHZ_120']
                    },
            'param':{
                    u'fftSamplingOffset': ['16', '16', '16', '16']
                    },
            'tx':   {
                    u'cyclicPrefix': ['NORMAL_CP', 'NORMAL_CP',
                    'NORMAL_CP', 'NORMAL_CP', 'NORMAL_CP',  'NORMAL_CP'],
                    u'defaultSubcarrierSpacing': ['KHZ_120', 'KHZ_120',
                     'KHZ_120', 'KHZ_120', 'KHZ_120', 'KHZ_120']
                    }
        }
        """
        pat_start = '(?<='
        pat_end = '</parameterName><newValue>).+?(?=</newValue>)'
        param_dict = {'tx': {},
                      'rx': {},
                      'param': {}}
        log_lines = open(file_path, 'r').readlines()
        for log_line in log_lines:
            if rx_tx_parameters is not None:
                for rx_tx_parameter in rx_tx_parameters:
                    try:
                        param_dict['tx'][rx_tx_parameter]
                    except KeyError:
                        param_dict['tx'].update({rx_tx_parameter: []})
                    match_tx = re.search(r'TxArrayCarrier', log_line)
                    if match_tx is not None:
                        pattern_param = r'{}{}{}'.format(
                            pat_start, rx_tx_parameter, pat_end)
                        param_value = re.search(pattern_param, log_line)
                        if param_value is not None:
                            param_dict['tx'][rx_tx_parameter].append(
                                param_value.group(0))
                    try:
                        param_dict['rx'][rx_tx_parameter]
                    except KeyError:
                        param_dict['rx'].update({rx_tx_parameter: []})
                    match_rx = re.search(r'RxArrayCarrier', log_line)
                    if match_rx is not None:
                        pattern_param = r'{}{}{}'.format(pat_start,
                                                         rx_tx_parameter, pat_end)
                        param_value = re.search(pattern_param, log_line)
                        if param_value is not None:
                            param_dict['rx'][rx_tx_parameter].append(
                                param_value.group(0))
            if parameters is not None:
                for parameter in parameters:
                    try:
                        param_dict['param'][parameter]
                    except KeyError:
                        param_dict['param'].update({parameter: []})
                    pattern_param = r'{}{}{}'.format(
                        pat_start, parameter, pat_end)
                    param_value = re.search(pattern_param, log_line)
                    if param_value is not None:
                        param_dict['param'][parameter].append(
                            param_value.group(0))
        return param_dict

    def _download_soap_file(self, local_dir="/tmp", bts_id=0, du_id=0):
        """
        Download SOAP file with configuration, from all RU
        connected to tl, and save them local in
        chosen folder
        :param local_dir: directory, where the
        soap file will be downloaded
        :param bts_id: BTS id - related to Test
        Line configuration. Default: 0
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        """
        number_of_ru_in_tl = tl_config.get_count_of_radios(
            bts_id=bts_id, du_id=du_id, bts_type=self.bts_type)
        soap_files_list = []
        for radio_index in range(number_of_ru_in_tl):
            gnb_name = self.ssh_alias.format(bts_id, du_id)
            ru_name = self.ssh_ru_alias.format(bts_id,
                                               du_id,
                                               radio_index)
            ru = DeviceFactory.get_device(name=ru_name)
            ru.goto_state("RU")
            cd_cmd = ru.get_cmd(cmd_name="cd", cmd_params={'path': "/run"})
            tar_cmd = ru.get_cmd(cmd_name="gunzip",
                                 cmd_params={'archive_name': ["UnitOAM_SOAP_Log0.xml.gz"]})
            ls_cmd = ru.get_cmd(cmd_name="ls")
            cd_cmd()
            if 'UnitOAM_SOAP_Log0.xml.gz' in ls_cmd()['files']:
                tar_cmd()
            try:
                bts = DeviceFactory.get_device(name=gnb_name)
                bts.goto_state("FCT")
                download_files(local_dir=local_dir,
                               remote_file='UnitOAM_SOAP_Log0.xml',
                               device_name=ru_name,
                               remote_dir='/run',
                               new_file_name="UnitOAM_SOAP_"
                                             "Log{}.xml".format(radio_index))
                soap_files_list.append("{}/UnitOAM_SOAP_Log{}.xml".format(
                    local_dir, radio_index))
                return soap_files_list
            except CommandFailure:
                raise FileNotFound("There is no UnitOAM files on this RU")

    def _ssh_to_ru(self, host, login, password, expected_prompt,
                   bts_id=0, du_id=0):
        """
        Make ssh connection to Radio Unit
        :param host: host name from tl config ie. 192.168.255.129
        :param login: login from tl config ie. root
        :param password: password from tl config ie. asmr
        :param expected_prompt: expected prompt from
        tl config ie. r'[.*hw-.*] .*?$?}
        :param bts_id:    BTS id - related to Test
        Line configuration. Default: 0
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return:
        """
        bts = DeviceFactory.get_device(name=self.ssh_alias.format(bts_id,
                                                                  du_id))
        ssh_cmd = bts.get_cmd(
            cmd_name="ssh",
            cmd_params={'host': host, 'login': login, 'password': password,
                        'expected_prompt': expected_prompt,
                        'allowed_newline_after_prompt': True},
            check_state=True)
        return ssh_cmd

    def verify_ru_configuration_via_gui(self, bts_id=0, ru_id=0, du_id=0):
        """
        Comapare lists of parameters from GUI and Radio
         Unit for RU's and extensions, if they are equal
        :param bts_id:    bts id - related to Test
         Line configuration.
        :param ru_id: Radio unit id
        :param du_id:     id related to Test Line
         configuration - gnb.dus[]
        """
        number_of_ext = tl_config.get_count_of_ru_extensions(bts_id,
                                                             du_id, ru_id=ru_id)
        if number_of_ext > 0:
            ext_info_gui = self._get_all_ext_info_via_gui(
                bts_id=bts_id, du_id=du_id, number_of_ext=number_of_ext)
            ext_info = self._get_all_ext_info(
                bts_id=bts_id, du_id=du_id, number_of_ext=number_of_ext)
            for ext in ext_info_gui.keys():
                for param in ext_info_gui[ext].keys():
                    diff_list = [(ext, param, ext_info[ext][param]) for
                                 param in ext_info_gui[ext].keys() if
                                 ext_info[ext][param] !=
                                 ext_info_gui[ext][param]]
                    if diff_list:
                        raise ListsAreNotEqual("Information about"
                                               " extensions in GUI are "
                                               "invalid: {}".format(diff_list))
        radio_info_gui = self._get_all_ru_info_via_gui(bts_id=bts_id,
                                                       du_id=du_id)
        radio_info = self._get_all_ru_info(bts_id=bts_id, du_id=du_id)

        for radio_gui in radio_info_gui.keys():
            for radio in radio_info.keys():
                same = True
                for param in radio_info_gui[radio_gui].keys():
                    if same is True:
                        if radio_info[radio][param] != \
                                radio_info_gui[radio_gui][param]:
                            same = False
                if same is True:
                    radio_info.pop(radio)
                    break

        if radio_info:
            raise ListsAreNotEqual("Information about radio "
                                   "in GUI are invalid: {} {}".format(radio_info, radio_info_gui))

    @load_moler_configuration_from_tl()
    def _get_all_ru_info(self, bts_id=0, du_id=0):
        """
        Get information about radio unit:  product code, hw type,
        serial number and make from it a dict
        :param bts_id:    bts id - related to Test Line configuration.
        :param du_id:     id related to Test Line configuration - gnb.dus[]
        :return: 'radio 1': {'Product code': u'475166A.101',
        'HW version': u'101', 'Serial number': u'YK202200102'}
        """
        all_radios = self.get_count_of_radios(bts_id=bts_id, du_id=du_id)
        ru_info_path = "/mnt/factory/configs/unit/"
        self.update_ru_ip_address_if_needed(bts_id=bts_id, du_id=du_id)
        radio_info = {}
        for radio_id in range(all_radios):
            ru_name = self.ssh_ru_alias.format(bts_id, du_id, radio_id)
            ru = DeviceFactory.get_device(name=ru_name)
            ru.goto_state("RU")
            cat_product_code = ru.get_cmd(cmd_name="cat", cmd_params={
                'path': "{}core_assembly_product_code.txt"
                                          .format(ru_info_path)})
            product_code = cat_product_code()['LINES']
            hw_code = str(product_code)[-5:]
            hw_code = hw_code[:3]
            cat_serial_number = ru.get_cmd(cmd_name="cat", cmd_params={
                'path': "{}core_assembly_serial_number.txt"
                                           .format(ru_info_path)})
            serial_number = cat_serial_number()['LINES']
            ru_dict = {
                "Serial number": serial_number[0],
                "Product code": product_code[0],
                "HW version": hw_code}
            radio_info["radio {}".format(radio_id + 1)] = ru_dict
        return radio_info

    @load_moler_configuration_from_tl()
    def _get_all_ext_info(self, bts_id=0, du_id=0, number_of_ext=1):
        """
        Get information about radio unit extensions: product code,
        serial number and make from it a dict
        :param bts_id:    bts id - related to Test Line configuration.
        :param du_id:     id related to Test Line configuration - gnb.dus[]
        :param number_of_ext:     number of ext in configuration
        :return: 'extension 1': {'Product code': u'475166A.101',
        'Serial number': u'YK202200102'}
        """
        extension_info = {}
        self.update_ru_ip_address_if_needed(bts_id=bts_id, du_id=du_id)
        all_radios = self.get_count_of_radios(bts_id=bts_id, du_id=du_id)
        for radio_id in range(all_radios):
            ru_name = self.ssh_ru_alias.format(bts_id, du_id, radio_id)
            ru = DeviceFactory.get_device(name=ru_name)
            ru.goto_state("RU")
            for ext_id in range(number_of_ext):
                get_ext_info = ru.get_cmd(
                    cmd_name="run_script",
                    cmd_params={'script_command': "am_flash -a {} -u >"
                                                  " ext_info{}.txt".format(ext_id+1, ext_id)})
                cat_ext_info = ru.get_cmd(cmd_name="cat",
                                          cmd_params={
                                              'path':
                                                  '/home/root/ext_info{}.'
                                                  'txt'.format(ext_id)})
                get_ext_info()
                cat = cat_ext_info()['LINES']
                for param in cat:
                    if "serial" in param:
                        serial_number = re.search(r'\'(.*?)\'', param).group(1)
                    if "unit code" in param:
                        product_code = re.search(r'\'(.*?)\'', param).group(1)
                ext_dict = {
                    "Serial number": serial_number,
                    "Product code": product_code}
                extension_info["extension {}".format(ext_id + 1)] = ext_dict
        return extension_info

    def _get_all_ru_info_via_gui(self, bts_id=0, du_id=0):
        """
        Get information about radio unit via GUI: product code,
         hw type, serial number and make from it a dict
        :param bts_id:    bts id - related to Test Line configuration.
        :param du_id:     id related to Test Line configuration - gnb.dus[]
        :return: 'radio 1': {'Product code': u'475166A.101',
        'HW version': u'101', 'Serial number': u'YK202200102'}
        """
        all_radios = self.get_count_of_radios(bts_id=bts_id,
                                              du_id=du_id)
        radio_info = {}
        for radio_id in range(all_radios):
            ru_info = self._get_ru_info_via_gui(ru_id=radio_id + 1,
                                                bts_id=bts_id,
                                                du_id=du_id)
            ru_dict = {
                "Serial number": ru_info['Serial number'],
                "Product code": ru_info['Product code'],
                "HW version": ru_info['HW version']}
            radio_info["radio {}".format(radio_id + 1)] = ru_dict
        return radio_info

    def _get_all_ext_info_via_gui(self, bts_id=0, du_id=0, number_of_ext=1):
        """
        Get information about radio unit extensions via GUI:
        product code, serial number and make from it a dict
        :param bts_id:    bts id - related to Test Line configuration.
        :param du_id:     id related to Test Line configuration
        - gnb.dus[]
        :param number_of_ext:     number of ext in configuration
        :return: 'extension 1': {'Product code': u'475166A.101',
        'Serial number': u'YK202200102'}
        """
        extension_info = {}
        for ext_id in range(number_of_ext):
            ext_info = self._get_ext_info_via_gui(bts_id=bts_id,
                                                  du_id=du_id,
                                                  number_of_ext=ext_id+2)
            ext_dict = {
                "Serial number": ext_info['Serial number'],
                "Product code": ext_info['Product code']}
            extension_info["extension {}".format(ext_id + 1)] = ext_dict
        return extension_info

    @login_logout_GUI
    def _get_ext_info_via_gui(self, bts_id=0, du_id=0, number_of_ext=1):
        """
        Get information about radio unit via GUI
        :param bts_id:    bts id - related to Test Line configuration.
        :param du_id:     id related to Test Line configuration - gnb.dus[]
        :param number_of_ext:     number of extensions in configuration
        :return: ru info list
        """
        ext_info = self.gui_coam.get_ru_info(type_="RMOD",
                                             ru_index=number_of_ext)
        return ext_info

    @login_logout_GUI
    def _get_ru_info_via_gui(self, bts_id=0, ru_id=1, du_id=1):
        """
        Get information about radio unit via GUI
        :param ru_id:     id of the radio unit
        :param bts_id:    bts id - related to Test Line configuration.
        :param du_id:     id related to Test Line configuration - gnb.dus[]
        :return: ru info list
        """
        ru_info = self.gui_coam.get_ru_info(type_="RMOD", ru_index=ru_id)
        return ru_info

    def _get_ru_info(self, bts_id=0, du_id=1, ru_id=1, bts_info=None):
        """
        Get information about radio unit.
        :param bts_id:    bts id - related to Test Line configuration.
        :param du_id:     id related to Test Line
        configuration - gnb.dus[]
        :param ru_id:     id of the radio unit
        :param bts_info:  results of method get_bts_info - it
         obtain automatically if not passed
        :return: ru info dict of parameters
        """
        ru_info = None
        rmod_id_regex = re.compile(r'RMOD-(?P<RMOD_ID>\d+)')

        if not bts_info:
            bts_info = self.admin.get_bts_info(
                connection=self.rest_alias.format(bts_id, du_id))

        for rmod_info in bts_info['radioModules']['rmod']:
            rmod_match = rmod_id_regex.search(rmod_info['id']['configuration'])
            if rmod_match and rmod_match.group('RMOD_ID') == int(ru_id):
                ru_info = rmod_info
                break

        return ru_info

    def _add_new_rmod_based_on_existing_rmod_to_configuration_via_gui(
            self, prodCodePlanned, rmod_id_to_copy_from,
            rmod_id, bts_id=0, du_id=0):
        """
        Adds a new RMOD object to configuration based on an existing
        RMOD object without activating plan.
        :param prodCodePlanned:          value of prodCodePlanned
        parameter of new RMOD
        :param rmod_id_to_copy_from:     id of RMOD that new
         RMOD will be based on
        :param rmod_id:                  id of the new RMOD
        :param bts_id:                   bts id - related to
        Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return: None
        """

        dist_name = self.adjust_dist_name("MRBTS-{}/EQM-1/APEQM-1",
                                          bts_id=bts_id, du_id=du_id)
        rmod_dist_name = dist_name + '/RMOD-' + str(rmod_id)

        self.gui_coam.add_object(object_name=dist_name,
                                 object_class_name='RMOD',
                                 plan_to_copy_from='CURRENT_BTS_CONF-1',
                                 copy_from=dist_name + '/RMOD-' + str(rmod_id_to_copy_from),
                                 include_subobject=True,
                                 id_value=rmod_id)
        self.gui_coam.set_parameter_value(dist_name=rmod_dist_name,
                                          filter_param='Product code planned',
                                          new_value=prodCodePlanned)
        self.gui_coam.validate_plan()

    @login_logout_GUI
    def add_new_rmod_based_on_existing_rmod_to_configuration_via_gui(
            self, prodCodePlanned, rmod_id_to_copy_from,
            rmod_id, bts_id=0, du_id=0):
        """
        Adds a new RMOD object to configuration based on an existing
         RMOD object
        :param prodCodePlanned:          value of prodCodePlanned
         parameter of new RMOD
        :param rmod_id_to_copy_from:     id of RMOD that new RMOD
         will be based on
        :param rmod_id:                  id of the new RMOD
        :param bts_id:                   bts id - related to
        Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return: None
        """
        self._add_new_rmod_based_on_existing_rmod_to_configuration_via_gui(
            prodCodePlanned, rmod_id_to_copy_from,
            rmod_id, bts_id=bts_id, du_id=du_id)
        self.gui_coam.activate_plan()

    @login_logout
    def verify_if_all_radio_modules_online(
            self, raise_exception=True, bts_id=0, du_id=0):
        """
        Verify if all radio modules availability statuses are online.
        :param bts_id:             bts id - ID related to
        Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return:
        """
        bts_info = self.admin.get_bts_info(
            connection=self.rest_alias.format(bts_id, du_id))
        frm_info = self.admin.get_frm(
            connection=self.rest_alias.format(bts_id, du_id))
        number_of_radios = len(frm_info)
        radios_not_online = []
        for radio_index in range(number_of_radios):
            availability_status = (
                bts_info["radioModules"]["rmod"][radio_index]["status"][
                    "availabilityStatus"])
            if availability_status != 'Online':
                radios_not_online.append(
                    frm_info[radio_index]['id']['configuration'])

        if raise_exception and len(radios_not_online) > 0:
            raise WrongRadioModuleStatus(radios_not_online)
        return radios_not_online

    def _add_new_loglink_via_gui(self, loglinkId, loglinkName,
                                 first_rmod_id, second_rmod_id,
                                 bts_id=0, du_id=0):
        """
        Adds a new loglink for extension module to intergrate with
         RU without activating plan

        :param loglink_id:                  id of the new loglink
        :param loglinkName:                 name of the new loglink
        :param first_rmod_id:               first endpoint RMOD id
        :param second_rmod_id:              second endpoint RMOD id
        :param bts_id:                      bts id - related to
        Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return: None
        """

        dist_name = self.adjust_dist_name("MRBTS-{}/EQM-1/HWTOP-1",
                                          bts_id=bts_id, du_id=du_id)
        loglink_dist_name = dist_name + '/LOGLINK-' + str(loglinkId)

        rmod_dist_name = self.adjust_dist_name("MRBTS-{}/EQM-1/APEQM-1",
                                               bts_id=bts_id, du_id=du_id)
        first_rmod_dist_name = rmod_dist_name + '/RMOD-' + str(first_rmod_id)
        second_rmod_dist_name = rmod_dist_name + '/RMOD-' + str(second_rmod_id)

        self.gui_coam.add_object(object_name=dist_name,
                                 object_class_name='LOGLINK',
                                 id_value=loglinkId,
                                 is_load_default_values=True)
        self.gui_coam.set_parameter_value(dist_name=loglink_dist_name,
                                          filter_param='First endpoint '
                                                       'distinguished Name',
                                          new_value=first_rmod_dist_name)
        self.gui_coam.set_parameter_value(dist_name=loglink_dist_name,
                                          filter_param='Logical link name',
                                          new_value=loglinkName)
        self.gui_coam.set_parameter_value(dist_name=loglink_dist_name,
                                          filter_param='Second endpoint '
                                                       'distinguished name',
                                          new_value=second_rmod_dist_name)

        self.gui_coam.validate_plan()

    @login_logout_GUI
    def add_new_loglink_via_gui(
            self, loglinkId, loglinkName, first_rmod_id,
            second_rmod_id, bts_id=0, du_id=0):
        """
        Adds a new loglink for extension module to intergrate with RU

        :param loglink_id:                  id of the new loglink
        :param loglinkName:                 name of the new loglink
        :param first_rmod_id:               first endpoint RMOD id
        :param second_rmod_id:              second endpoint RMOD id
        :param bts_id:                      bts id - related to
        Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return: None
        """

        self._add_new_loglink_via_gui(loglinkId, loglinkName,
                                      first_rmod_id, second_rmod_id,
                                      bts_id=bts_id,
                                      du_id=du_id)
        self.gui_coam.activate_plan()

    @login_logout_GUI
    def set_loglink_name_via_gui(self, loglinkId, loglinkName,
                                 bts_id=0, du_id=0):
        """
        Change name of existing loglink to incorrect and verify
        validation error

        :param loglinkId:                   id of the existing loglink
        :param loglinkName:                 name of the loglink
        :param bts_id:                      bts id - related to Test
         Line configuration.
        :param du_id:                       DU id(Distributed Unit) -
        id related to Test Line configuration - gnb.dus[]
        :return:                            None
        """

        dist_name = self.adjust_dist_name("MRBTS-{}/EQM-1/HWTOP-1",
                                          bts_id=bts_id, du_id=du_id)
        loglink_dist_name = dist_name + '/LOGLINK-' + str(loglinkId)
        self.gui_coam.set_parameter_value(dist_name=loglink_dist_name,
                                          filter_param='Logical link name',
                                          new_value=loglinkName)
        self.gui_coam.validate_plan()
        validation_relation_errors = self.gui_coam.get_relation_errors()
        if validation_relation_errors:
            raise ValidationError(errors=validation_relation_errors)
        self.gui_coam.activate_plan()

    def set_incorrect_loglink_name_and_verify_error_via_gui(
            self, loglinkId, incorrect_name,
            error_content="EXTMOD-1",
            bts_id=0, du_id=0):
        """
        Change name of existing loglink to incorrect and verify
         validation error

        :param loglinkId:                   id of the existing loglink
        :param incorrect_name               incorrect name of the loglink
        :param error_content                content of validation
        error message to compare
        :param bts_id:                      bts id - related to Test
         Line configuration.
        :param du_id:                       DU id(Distributed Unit) -
         id related to Test Line configuration - gnb.dus[]
        :return:                            None
        """

        try:
            self.set_loglink_name_via_gui(
                loglinkId, incorrect_name, bts_id=bts_id,
                du_id=du_id)
        except ValidationError as e:
            errors = e.errors
            errors_keys = errors.keys()
            if len(errors_keys) > 1:
                raise Exception("Too many components report"
                                " validation error: {}".format(errors))
            if len(errors[errors_keys[0]]) > 1:
                raise Exception("Too many validation "
                                "errors: {}".format(errors))
            if error_content not in errors[errors_keys[0]][0]:
                raise Exception(
                    "Wrong validation error: {}".format(
                        errors[errors_keys[0]][0]))

    def collect_ccs_shell_logs(self, bts_id=0, du_id=0, ru_id=None,
                               log_dir=None):
        """
        Collect ccsShell logs from RU
        :param bts_id:  BTS id - related to Test Line configuration. Default: 0
        :param du_id:   DU id(Distributed Unit) - id related
        to Test Line configuration. Default: 0
        :param ru_id:   Position of RU in rus table from Test
        Line configuration. If None - run on all rus
        :param log_dir: local directory path where logs will be downloaded.
                        If None - default logs dir will be used:
                         ${OUTPUT DIR}/Logs/<timestamp>
        """
        self.update_ru_ip_address_if_needed(bts_id=bts_id, du_id=du_id)
        ru_ids = [ru_id] if ru_id else range(
            tl_config.get_count_of_radios(bts_id=bts_id,
                                          du_id=du_id,
                                          bts_type=self.bts_type))
        if log_dir is None:
            log_dir = get_log_path()

        for _ru_id in ru_ids:
            remote_file = self._collect_ccs_shell_logs(
                bts_id=bts_id, du_id=du_id, ru_id=_ru_id)
            download_files(local_dir=log_dir,
                           remote_file=os.path.basename(remote_file),
                           remote_dir=os.path.dirname(remote_file),
                           device_name=self.ssh_ru_alias.format(
                               bts_id, du_id, _ru_id))

    @load_moler_configuration_from_tl()
    def _collect_ccs_shell_logs(self, bts_id=0, du_id=0, ru_id=0, timeout=60):
        """
        Collect ccsShell logs from RU
        :param bts_id:      BTS id - related to Test Line configuration.
         Default: 0
        :param du_id:       DU id(Distributed Unit) - id related
        to Test Line configuration. Default: 0
        :param ru_id:       Position of RU in rus table from Test
         Line configuration. Default: 0
        :param timeout:     timeout for collecting logs
        """

        ru_name = self.ssh_ru_alias.format(bts_id, du_id, ru_id)
        ru = DeviceFactory.get_device(ru_name)
        ru.goto_state("RU")

        file_name = '{}_log.zip'.format(ru_name)
        log_path = os.path.join('/ram', file_name)
        collect_logs = ru.get_cmd(
            cmd_name="run_script",
            cmd_params={'script_command': 'ccsShell.sh log -c full -a -z {}'.format(log_path)})
        collect_logs(timeout=timeout)
        return log_path


class EnbRu(GenericRu):
    """Class contains RU(Radio Unit) keywords for eNB"""

    bts_type = 'ENB'

    def __init__(self):
        """
        Constructor of Enb class.

        """
        super(EnbRu, self).__init__(bts_type=EnbRu.bts_type)

    def _get_container_id_gnb2ru(self, dev_name):
        return None


class GnbRu(GenericRu):
    """Class contains RU(Radio Unit) keywords for gNB"""

    bts_type = 'GNB'

    def __init__(self):
        """
        Constructor of Gnb class.

        """
        super(GnbRu, self).__init__(bts_type=GnbRu.bts_type)

    @load_moler_configuration_from_tl()
    def verify_ru_certificate_integrity(
            self, certificate_file_name, gnb_id=0,
            radio_unit_id=None,
            certificate_dir="/etc/ssl/certs/", du_id=0):
        """
        Verify that radio unit certificate file is present and
        verify it's integrity.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param gnb_id:    gNB id - related to Test Line configuration.
        Default: 0
        :param radio_unit_id:    radio unit id - related to Test
        Line configuration.
                                 If None certificate on each radio unit
                                 is checked.
        :param certificate_dir:    directory where certificate file is
        located. Default: /etc/ssl/certs/
        :param certificate_file_name:    name of certificate file.
        Default: NokiaModule.pem
        :return: None
        """
        self.update_ru_ip_address_if_needed(bts_id=gnb_id, du_id=du_id)
        if radio_unit_id is None:
            number_of_ru = tl_config.get_count_of_radios(
                bts_id=gnb_id, du_id=du_id, bts_type=self.bts_type)
            for ru_id in range(number_of_ru):
                self.verify_ru_certificate_integrity(
                    gnb_id=gnb_id, radio_unit_id=ru_id,
                    certificate_dir=certificate_dir,
                    certificate_file_name=certificate_file_name, du_id=du_id)
            return

        ru = DeviceFactory.get_device(self.ssh_ru_alias.format(
            gnb_id, du_id, radio_unit_id))
        ru.goto_state("RU")
        self._verify_ru_certificate_file_present(
            radio_unit_device=ru, certificate_dir=certificate_dir,
            certificate_file_name=certificate_file_name)
        openssl_cmd = ru.get_cmd(
            cmd_name='openssl_x509_text_in',
            cmd_params={'path': certificate_dir+certificate_file_name})
        try:
            openssl_cmd()
        except CommandFailure as e:
            raise CertificateVerificationError("Decoding certificate file "
                                               "on RU {} ended with "
                                               "error: {}".format(radio_unit_id, e))

    def _verify_ru_certificate_file_present(self, radio_unit_device,
                                            certificate_dir,
                                            certificate_file_name):
        """
        Verify that radio unit certificate file is present in given location.
        :param radio_unit_device:    radio unit moler device
        :param certificate_dir:     directory where certificate file is located
        :param certificate_file_name:    name of certificate file
        :return: None
        """
        cd_cmd = radio_unit_device.get_cmd(
            cmd_name='cd', cmd_params={'path': certificate_dir})
        ls_cmd = radio_unit_device.get_cmd(
            cmd_name='ls',
            cmd_params={'options': '-al | grep "{}"'.format(
                certificate_file_name)})
        cd_cmd()
        ls_cmd_output = ls_cmd()
        file_names = [file_name for file_name in ls_cmd_output["files"].keys()]
        if certificate_file_name in file_names:
            logging.info("Certificate file '{}' has been found".format(
                certificate_file_name))
        else:
            raise DataNotAvailable(
                "Certificate file '{}' does not exist in"
                " path {}".format(certificate_file_name, certificate_dir))

    @login_logout
    def verify_restart_occured_on_all_ru(
            self, bts_id=0, time=120, du_id=0, runtime=False):
        """
        Verifies if restart occured on all RUs in given time.
        :param bts_id:          BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :param time:            Time in seconds, that will
        be compared to uptime
        :param runtime:  If True use runtime radio object, if False
         configuration radio object. Default False
        :return: none
        """
        all_ru_ids = self._get_all_radio_ids(
            bts_id=bts_id, du_id=du_id, runtime=runtime)
        for ru_id in all_ru_ids:
            self.verify_ru_restart_occured(
                bts_id=bts_id, time=time, ru_id=ru_id-1, du_id=du_id)

    @load_moler_configuration_from_tl()
    def verify_ru_restart_occured(self, bts_id=0, time=120, ru_id=0, du_id=0):
        """
        Verifies if RU uptime is shorter that given time, indicating
        that Ru restart occurred.
        :param bts_id:          BTS id - related to Test Line
         configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :param time:            Time in seconds, that will be
        compared to uptime
        :param ru_id:           Radio Unit id - related to Test
         Line configuration
        :return: none
        """
        self.update_ru_ip_address_if_needed(bts_id=bts_id, du_id=du_id)
        ru = DeviceFactory.get_device(name=self.ssh_ru_alias.format(
            bts_id, du_id, ru_id))
        ru.goto_state(state="RU")

        uptime_cmd = ru.get_cmd(cmd_name="uptime")
        uptime_result = uptime_cmd()['UPTIME_SECONDS']

        if uptime_result > int(time):
            raise UptimeTooLong("Expected uptime: < {}s, "
                                "actual uptime: {}s".format(time, uptime_result))

        MolerTest.steps_end()
        return

    @load_moler_configuration_from_tl()
    def _get_container_id_gnb2ru(self, dev_name):
        """
        Get container id to connect to RU from GNB console.
        :param dev_name: Moler name of gnb.
        :return: String with container id.
        """
        container_id = None
        containers = ("0x2018", "0x1018")
        try:
            dev = DeviceFactory.get_device(dev_name)
            dev.goto_state("FCT")
            cmd = dev.get_cmd(cmd_name="lxc_ls")
            ret = cmd()

            for current_container in containers:
                for container_row in ret['RESULT']:
                    if current_container in container_row:
                        logging.debug("Found Container "
                                      "id ='{}'".format(current_container))
                        container_id = current_container
                        return container_id
        except MolerException as me:
            logging.warning("Cannot get proper name of virtual "
                            "machine because of: '{}'.".format(repr(me)))
        logging.info("Cannot find any container from: {}.".format(containers))
        return container_id

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    @login_logout
    def provoke_ru_supervision_failure(self, bts_id=0, du_id=0):
        """
        Provokes RU supervision failures by blocking communication,
        using iptables rules.
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return: none
        """
        gnb = DeviceFactory.get_device(name=self.ssh_alias.format(bts_id,
                                                                  du_id))

        container_id = self._get_container_id_gnb2ru(dev_name=gnb.name)
        gnb.change_fhnet_container_id(container_id=container_id)
        if container_id is not None:
            gnb.goto_state("FHNET")
        else:
            gnb.goto_state("FCT")

        add_iptables_rule_cmd_1 = gnb.get_cmd(
            cmd_name="iptables",
            cmd_params={'options': '-A INPUT -p udp --dport 13001 -j DROP'})
        add_iptables_rule_cmd_2 = gnb.get_cmd(
            cmd_name="iptables",
            cmd_params={'options': '-A OUTPUT -p udp --dport 13100 -j DROP'})

        add_iptables_rule_cmd_1()
        add_iptables_rule_cmd_2()

        MolerTest.steps_end()
        return

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    @login_logout
    def restore_ru_supervision(self, bts_id=0, du_id=0):
        """
        Restores RU supervision by removinf iptables rules.
        :param bts_id:  BTS id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :return: none
        """
        gnb = DeviceFactory.get_device(name=self.ssh_alias.format(bts_id,
                                                                  du_id))

        container_id = self._get_container_id_gnb2ru(dev_name=gnb.name)
        gnb.change_fhnet_container_id(container_id=container_id)
        if container_id:
            gnb.goto_state("FHNET")
        else:
            gnb.goto_state("FCT")

        remove_iptables_rule_cmd_1 = gnb.get_cmd(
            cmd_name="iptables",
            cmd_params={'options': '-D INPUT -p udp --dport 13001 -j DROP'})
        remove_iptables_rule_cmd_2 = gnb.get_cmd(
            cmd_name="iptables",
            cmd_params={'options': '-D OUTPUT -p udp --dport 13100 -j DROP'})

        remove_iptables_rule_cmd_1()
        remove_iptables_rule_cmd_2()

        MolerTest.steps_end()
        return

    @load_moler_configuration_from_tl()
    def get_ru_discard_rules_info(
            self, gnb_id=0, du_id=0, radio_unit_id=0, rate_limit=False,
            table="filter"):
        """
        Retrieve discard packet counter from RU
        :param gnb_id:    BTS id - related to Test Line configuration.
        Default: 0
        :param du_id: DU id(Distributed Unit) - id related to
         Test Line configuration - gnb.dus[]
        :param radio_unit_id: RU id - related to Test line
        configuration - gnbs.dus.rus[]
        :param rate_limit: chain counter flag - set to True for
        DISCARD-RATE-LIMIT, False for DISCARD
        :param table: table to get values from, filter or pre_filter
        :return: int with counter value
        """
        if table == 'filter':
            table_type = 'table ip filter'
            nft_options = 'list ' + table_type
        elif table == 'pre_filter':
            table_type = 'table netdev pre_filter'
            nft_options = "list " + table_type
        else:
            raise ValueError("table: invalid type: should be:"
                             " filter or pre_filter")
        self.update_ru_ip_address_if_needed(bts_id=gnb_id, du_id=du_id)
        ru = DeviceFactory.get_device(
            self.ssh_ru_alias.format(gnb_id, du_id, radio_unit_id))
        ru.goto_state("RU")
        nft_list_cmd = ru.get_cmd(cmd_name="nft",
                                  cmd_params={"options": nft_options})
        ret = nft_list_cmd()
        if rate_limit:
            return ret[table_type]['chain DISCARD-RATE-LIMIT']['counter']['packets']
        elif rate_limit is False:
            return ret[table_type]['chain DISCARD']['counter']['packets']
        else:
            for line in ret['table ip filter']['chain OUTPUT']['LINES']:
                if line.lower().startswith('icmp'):
                    return line
            raise ValueError(
                "NFT: OUTPUT rule for rate limiting ICMP traffic not found")

    @load_moler_configuration_from_tl()
    def _execute_amswissknife_on_radio_module(
            self, operation, panel_id, gnb_id=0, du_id=0,
            ru_id=0):
        """
        Execute amswissknife command on radio module to enable or disable beams,
         according to panel_id parameter:
        0 - main radio unit, 1 - first extension panel, 2 - second extension
        panel
        :param operation:   operation to perform, use 'enable' or 'disable'
        :param panel_id:    -a flag in amswissknife command, id of radio module
        :param gnb_id:      gNB id - related to Test Line configuration.
        :param du_id:       DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param ru_id:       RU id - ID related to Test Line configuration.
        """
        command_options_dict = {
            'enable': ['-a {} -s runtime -n 0'.format(panel_id), '-a 0 -s runtime -n 1'],
            'disable': ['-a {} -s disabled -n 0'.format(panel_id), '-a 0 -s disabled -n 1']
        }
        self.update_ru_ip_address_if_needed(bts_id=gnb_id, du_id=du_id)
        ru_name = self.ssh_ru_alias.format(gnb_id, du_id, ru_id)
        ru = DeviceFactory.get_device(ru_name)
        ru.goto_state("RU")
        try:
            for options in command_options_dict[operation]:
                am_swissknife_cmd = ru.get_cmd(
                    cmd_name="amswissknife",
                    cmd_params={'options': options})
                am_swissknife_cmd()
        except KeyError:
            AmswissknifeOperationNotAvailable(operation)

    def enable_beams(self, panel_id=0, gnb_id=0, du_id=0, ru_id=0):
        """
        Enable beams on hardware pointed by panel_id parameter.
        :param panel_id:    -a flag in amswissknife command, id of
        radio module;
                            0 - main radio unit (default), 1 - first
                             extension panel, 2 - second extension panel
        :param gnb_id:      gNB id - related to Test Line configuration.
        :param du_id:       DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param ru_id:       RU id - ID related to Test Line configuration.
        """
        self._execute_amswissknife_on_radio_module(
            'enable', panel_id=panel_id, gnb_id=gnb_id, du_id=du_id, ru_id=ru_id)

    def disable_beams(self, panel_id=0, gnb_id=0, du_id=0, ru_id=0):
        """
        Disable beams on hardware pointed by panel_id parameter.
        :param panel_id:    -a flag in amswissknife command, id of radio module;
                            0 - main radio unit (default), 1 - first extension
                             panel, 2 - second extension panel
        :param gnb_id:      gNB id - related to Test Line configuration.
        :param du_id:       DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param ru_id:       RU id - ID related to Test Line configuration.
        """
        self._execute_amswissknife_on_radio_module(
            'disable', panel_id=panel_id, gnb_id=gnb_id, du_id=du_id,
            ru_id=ru_id)
