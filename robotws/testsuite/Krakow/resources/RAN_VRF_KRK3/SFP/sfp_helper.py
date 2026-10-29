"""
Library used to collect (Q)SFP data and to verify if dynamic and static parameters have valid values.
Based on feature 5GC000614 Link Diagnostic and Monitoring.

:copyright: Nokia Networks
:author: Marek Bodziony, Dominik Baran
:contact: marek.bodziony@nokia.com
:maintainer: Marek Bodziony
:contact: marek.bodziony@nokia.com
"""
import logging
from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations, login_logout_GUI
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.nms.netact.facade import Netact
from testsuite.Krakow.resources.RAN_VRF_KRK3.SFP import sfps_for_test
from testsuite.Krakow.resources.RAN_VRF_KRK3.SFP.exceptions import SfpParametersError


class SfpHelper(GenericDuOperations):
    """
    Class contains methods to collect (Q)SFP data and to verify if dynamic and static parameters have valid values.
    """
    ROBOT_LIBRARY_SCOPE = "TEST SUITE"
    sfp_dynamic_parameters = ["TXSupplyVoltage", "TXBiasCurrent", "TXOpticalPowerUW", "TXOpticalPowerDBM",
                              "RXOpticalPowerUW", "RXOpticalPowerDBM", "LCV", "BER", "moduleTemperature"]
    sfp_static_parameters = ["dateCode", "waveLength", "transmissionRate", "nominalSignalingRate"]
    sfp_hardware_parameters = ["complianceCode", "vendor", "vendorPartNumber", "vendorRevision", "serialNumber",
                               "connectorType", "physicalPort"]
    sfp_static_rx_params = ["rxPowerHighAlarmThreshold", "rxPowerHighWarnThreshold", "rxPowerLowAlarmThreshold",
                            "rxPowerLowWarnThreshold"]
    sfp_static_tx_params = ["txPowerHighAlarmThreshold", "txPowerHighWarnThreshold", "txPowerLowAlarmThreshold",
                            "txPowerLowWarnThreshold"]
    sfp_static_temp_params = ["temperatureHighAlarmThreshold", "temperatureLowAlarmThreshold"]
    tl = get_builtin_value(param_name="tl")

    def __init__(self):
        """
        Constructor of Sfp class.
        """
        super(SfpHelper, self).__init__(bts_type="GNB")
        self._netact = None

    @property
    def netact(self):
        if not self._netact:
            self._netact = Netact()
            self._netact.add_web_url(self.tl.nms.netact.https_main_info.addr,
                                     self.tl.nms.netact.https_main_info.username,
                                     self.tl.nms.netact.https_main_info.password)
            return self._netact
        else:
            return self._netact

    @login_logout_GUI
    def get_sfp_links_status(self, bts_id=0, du_id=0):
        """
        Get SFP links data from BTS
        :param bts_id:      BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:            BTS internal SFP links database
        """
        sfp_links_details = self.admin.get_sfp_links(connection=self.rest_alias.format(bts_id, du_id))
        logging.info("SFP full data from BTS:\n{}".format(sfp_links_details))
        return sfp_links_details

    def get_sfp_data_for_rmod(self):
        """
        Get SFP links data for RMOD
        :return:        list of dicts with SFP links parameters (static and dynamic) for RMOD
        """
        return self._get_sfp_data_for_module(module_type="rmod")

    def get_sfp_data_for_bbmod(self):
        """
        Get SFP links data for BBMOD
        :return:        list of dicts with SFP links parameters (static and dynamic) for BBMOD
        """
        return self._get_sfp_data_for_module(module_type="bbmod")

    def get_sfp_data_for_smod(self):
        """
        Get SFP links data for SMOD
        :return:        list of dicts with SFP links parameters (static and dynamic) for SMOD
        """
        return self._get_sfp_data_for_module(module_type="smod")

    @login_logout_GUI
    def _get_sfp_data_for_module(self, module_type, bts_id=0, du_id=0):
        """
        Get SFP links data from BTS for specific module (SMOD, BBMOD or RMOD)
        :param module_type: type of module for which SFP data should collected: SMOD, BBMOD or RMOD
        :param bts_id:      BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:            list of dicts with SFP links parameters (static and dynamic) for specific module
        """
        link_direction = "source"
        link_type = "connected"
        if module_type == "bbmod":
            link_direction = "destination"
        elif module_type == "smod":
            link_type = "notConnected"
        sfp_list_for_module = list()
        sfp_links_details = self.admin.get_sfp_links(connection=self.rest_alias.format(bts_id, du_id))
        logging.info("SFP full data from BTS:\n{}".format(sfp_links_details))
        sfp_links = sfp_links_details[link_type]
        for i in range(len(sfp_links)):
            sfp = dict()
            sfp["dynamic"] = self._get_sfp_dynamic_data(sfp_links[i], link_direction)
            sfp["static"] = self._get_sfp_static_data(sfp_links[i], link_direction, module_type)
            sfp_list_for_module.append(sfp)
        return sfp_list_for_module

    def _get_sfp_dynamic_data(self, sfp_link, link_direction):
        """
        Get SFP dynamic parameters from SFP link database object
        :param sfp_link:        SFP link database object
        :param link_direction:  depending on module type: "source" (SMOD, RMOD) or "destination" (BBMOD)
        :return:                dict with SFP dynamic parameters
        """
        sfp_dynamic_data = dict()
        sfp_measurements = sfp_link["data"]["measurements"]
        for measurement in self.sfp_dynamic_parameters:
            measurement_value = sfp_measurements[measurement][link_direction]
            if isinstance(measurement_value, list):
                sfp_dynamic_data[measurement] = measurement_value[0]
            else:
                sfp_dynamic_data[measurement] = measurement_value
        return sfp_dynamic_data

    def _get_sfp_static_data(self, sfp_link, link_direction, module_type):
        """
        Get SFP all static parameters from SFP link database object
        :param sfp_link:        SFP link database object
        :param link_direction:  depending on module type: "source" (SMOD, RMOD) or "destination" (BBMOD)
        :param module_type:     type of module for which SFP data should collected: SMOD, BBMOD or RMOD
        :return:                dict with SFP static parameters
        """
        sfp_static_data = dict()
        static_params = self._get_static_params_values(sfp_link, link_direction)
        hardware_params = self._get_hardware_params_values(sfp_link, link_direction)
        rx_threshold_params = self._get_rx_threshold_params_values(sfp_link, link_direction)
        tx_threshold_params = self._get_tx_threshold_params_values(sfp_link, link_direction)
        temp_threshold_params = self._get_temp_threshold_params_values(sfp_link, link_direction)
        sfp_static_data.update(static_params)
        sfp_static_data.update(hardware_params)
        sfp_static_data.update(rx_threshold_params)
        sfp_static_data.update(tx_threshold_params)
        sfp_static_data.update(temp_threshold_params)
        if module_type != "smod":
            sfp_static_data["linkSpeed"] = sfp_link["data"]["linkSpeed"]["value"]
            sfp_static_data["fiberLength"] = sfp_link["data"]["fiberLength"]["value"]
        return sfp_static_data

    def _get_static_params_values(self, sfp_link, link_direction):
        """
        Get SFP static parameters from SFP link database object
        :param sfp_link:        SFP link database object
        :param link_direction:  depending on module type: "source" (SMOD, RMOD) or "destination" (BBMOD)
        :return:                dict with SFP static parameters
        """
        sfp_static_params = dict()
        for param in self.sfp_static_parameters:
            logging.info("logs: {}".format(sfp_link["details"]["staticParameters"]))
            sfp_static_params[param] = sfp_link["details"]["staticParameters"][param][link_direction]
        return sfp_static_params

    def _get_hardware_params_values(self, sfp_link, link_direction):
        """
        Get SFP hardware parameters from SFP link database object
        :param sfp_link:        SFP link database object
        :param link_direction:  depending on module type: "source" (SMOD, RMOD) or "destination" (BBMOD)
        :return:                dict with SFP hardware parameters
        """
        sfp_hardware_params = dict()
        for hardware_param in self.sfp_hardware_parameters:
            sfp_hardware_params[hardware_param] = \
                sfp_link["details"]["hardwareParameters"][hardware_param][link_direction]
        return sfp_hardware_params

    def _get_rx_threshold_params_values(self, sfp_link, link_direction):
        """
        Get SFP RX threshold parameters from SFP link database object
        :param sfp_link:        SFP link database object
        :param link_direction:  depending on module type: "source" (SMOD, RMOD) or "destination" (BBMOD)
        :return:                dict with SFP RX threshold parameters
        """
        return self._get_threshold_params_values(sfp_link, self.sfp_static_rx_params, link_direction)

    def _get_tx_threshold_params_values(self, sfp_link, link_direction):
        """
        Get SFP TX threshold parameters from SFP link database object
        :param sfp_link:        SFP link database object
        :param link_direction:  depending on module type: "source" (SMOD, RMOD) or "destination" (BBMOD)
        :return:                dict with SFP TX threshold parameters
        """
        return self._get_threshold_params_values(sfp_link, self.sfp_static_tx_params, link_direction)

    def _get_temp_threshold_params_values(self, sfp_link, link_direction):
        """
        Get SFP temperature threshold parameters from SFP link database object
        :param sfp_link:        SFP link database object
        :param link_direction:  depending on module type: "source" (SMOD, RMOD) or "destination" (BBMOD)
        :return:                dict with SFP temperature threshold parameters
        """
        return self._get_threshold_params_values(sfp_link, self.sfp_static_temp_params, link_direction)

    @staticmethod
    def _get_threshold_params_values(sfp_link, threshold_params, link_direction):
        """
        Get SFP threshold parameters from SFP link database object
        :param sfp_link:            SFP link database object
        :param threshold_params:    list of thresholds to fetch from SFP link database object
        :param link_direction:      depending on module type: "source" (SMOD, RMOD) or "destination" (BBMOD)
        :return:                    dict with SFP threshold parameters
        """
        sfp_threshold_params = dict()
        for threshold in threshold_params:
            sfp_threshold_params[threshold] = sfp_link["details"]["thresholds"][threshold][link_direction]
        return sfp_threshold_params

    @staticmethod
    def check_if_sfp_dynamic_parameters_have_valid_values(sfp, temp_min=0, temp_max=75,
                                                          voltage_min=0, voltage_max=6550,
                                                          bias_min=0, bias_max=131, tx_rx_power_units="dBm",
                                                          tx_power_uw_min=0, tx_power_uw_max=1737,
                                                          tx_power_dbm_min=-40, tx_power_dbm_max=2.4,
                                                          rx_power_uw_min=0, rx_power_uw_max=1737,
                                                          rx_power_dbm_min=-40, rx_power_dbm_max=2.4):
        """
        Check if SFP dynamic parameters have valid values.
        :param sfp_list_for_module:     list of dicts with SFP dynamic and static parameters
        :param temp_min:                min acceptable value of SFP module temperature
        :param temp_max:                max acceptable value of SFP module temperature
        :param voltage_min:             min acceptable value of SFP module TX supply voltage
        :param voltage_max:             max acceptable value of SFP module TX supply voltage
        :param bias_min:                min acceptable value of SFP module TX bias current
        :param bias_max:                max acceptable value of SFP module TX bias current
        :param tx_rx_power_units:       units of Tx/Rx power params (WebEM: uW+dBm, Snapshot: uW, PM counters: dBm)
        :param tx_power_uw_min:         min acceptable value of SFP module TX optical power (uW)
        :param tx_power_uw_max:         max acceptable value of SFP module TX optical power (uW)
        :param tx_power_dbm_min:        min acceptable value of SFP module TX optical power (dBm)
        :param tx_power_dbm_max:        max acceptable value of SFP module TX optical power (dBm)
        :param rx_power_uw_min:         min acceptable value of SFP module RX optical power (uW)
        :param rx_power_uw_max:         max acceptable value of SFP module RX optical power (uW)
        :param rx_power_dbm_min:        min acceptable value of SFP module RX optical power (dBm)
        :param rx_power_dbm_max:        max acceptable value of SFP module RX optical power (dBm)
        """
        number_of_SPFs = 4
        if len(sfp) == 0:
            raise SfpParametersError("No SFP parameters from PM counters in Snapshot")
        for idx in range(0, number_of_SPFs):
            assert temp_min <= sfp["M40007C2"][idx] <= temp_max, (f"Module temperature {sfp['M40007C2'][idx]}'C is out"
                                                                  f" of the range: {temp_min}'C - {temp_max}'C")
            assert voltage_min <= sfp["M40007C10"][idx] <= voltage_max, (f"'Transceiver Tx supply voltage' "
                                                                         f"{sfp['M40007C10'][idx]}mV is out of the "
                                                                         f"range: {voltage_min}mV - {voltage_max}mV")
            assert bias_min <= sfp["M40015C7"][idx] <= bias_max, (f"'Transceiver Tx bias current' "
                                                                  f"{sfp['M40015C7'][idx]}mA is out of the range: "
                                                                  f"{bias_min}mA - {bias_max}mA")
            assert bias_min <= sfp["M40015C8"][idx] <= bias_max, (f"Transceiver Tx bias current {sfp['M40015C8'][idx]}"
                                                                  f"mA is out of the range: "
                                                                  f"{bias_min}mA - {bias_max}mA")
            if "uW" in tx_rx_power_units:
                assert rx_power_uw_min <= sfp["M40015C1"][idx] <= rx_power_uw_max, (f"'SBTS_SFPBM_RX_POWER_LANE_MIN'"
                                                                                    f" {sfp['M40015C1'][idx]}uW is out"
                                                                                    f" of the range: {rx_power_uw_min}"
                                                                                    f"uW - {rx_power_uw_max}uW")
                assert rx_power_uw_min <= sfp["M40015C2"][idx] <= rx_power_uw_max, (f"'SBTS_SFPBM_RX_POWER_LANE_MAX'"
                                                                                    f" {sfp['M40015C2'][idx]}uW is out"
                                                                                    f" of the range: {rx_power_uw_min}"
                                                                                    f"uW - {rx_power_uw_max}uW")
                assert tx_power_uw_min <= sfp["M40015C4"][idx] <= tx_power_uw_max, (f"'SBTS_SFPBM_TX_POWER_LANE_MIN' "
                                                                                    f"{sfp['M40015C4'][idx]}uW is out "
                                                                                    f"of the range: {tx_power_uw_min}"
                                                                                    f"uW - {tx_power_uw_max}uW")
                assert tx_power_uw_min <= sfp["M40015C5"][idx] <= tx_power_uw_max, (f"'SBTS_SFPBM_TX_POWER_LANE_MAX' "
                                                                                    f"{sfp['M40015C5'][idx]}uW is out "
                                                                                    f"of the range: {tx_power_uw_min}"
                                                                                    f"uW - {tx_power_uw_max}uW")

            if "dBm" in tx_rx_power_units:
                assert rx_power_dbm_min <= sfp["M40015C1"][idx] <= rx_power_dbm_max, (f"'SBTS_SFPBM_RX_POWER_LANE_MIN'"
                                                                                      f" {sfp['M40015C1'][idx]}dBm is "
                                                                                      f"out of the range: "
                                                                                      f"{rx_power_dbm_min}dBm "
                                                                                      f"- {rx_power_dbm_max}dBm")
                assert rx_power_dbm_min <= sfp["M40015C2"][idx] <= rx_power_dbm_max, (f"'SBTS_SFPBM_RX_POWER_LANE_MAX'"
                                                                                      f" {sfp['M40015C2'][idx]}dBm is "
                                                                                      f"out of the range: "
                                                                                      f"{rx_power_dbm_min}dBm "
                                                                                      f"- {rx_power_dbm_max}dBm")
                assert tx_power_dbm_min <= sfp["M40015C4"][idx] <= tx_power_dbm_max, (f"'SBTS_SFPBM_TX_POWER_LANE_MIN' "
                                                                                      f"{sfp['M40015C4'][idx]}dBm is "
                                                                                      f"out of the range: "
                                                                                      f"{tx_power_dbm_min}dBm "
                                                                                      f"- {tx_power_dbm_max}dBm")
                assert tx_power_dbm_min <= sfp["M40015C5"][idx] <= tx_power_dbm_max, (f"'SBTS_SFPBM_TX_POWER_LANE_MAX'"
                                                                                      f" {sfp['M40015C5'][idx]}dBm is"
                                                                                      f" out of the range: "
                                                                                      f"{tx_power_dbm_min}dBm "
                                                                                      f"- {tx_power_dbm_max}dBm")

    def check_if_sfp_dynamic_parameters_have_valid_values_in_pm_counters_for_bbmod(self, sfp_list_for_module):
        """
        Check if SFP dynamic parameters in PM counters have valid values for BBMOD
        :param sfp_list_for_module:     list of dicts with SFP dynamic and static parameters
        """
        self.check_if_sfp_dynamic_parameters_have_valid_values(sfp_list_for_module, tx_rx_power_units="dBm")

    def check_if_sfp_dynamic_parameters_have_valid_values_in_pm_counters_for_rmod(self, sfp_list_for_module,
                                                                                  voltage_min=0, voltage_max=6550):
        """
        Check if SFP dynamic parameters have valid values in PM counters for RMOD.
        WARNING: Due to CB006006 from 22R4 only 'TXSupplyVoltage' parameter is available in PM counters for RMOD.
        :param sfp_list_for_module:     list of dicts with SFP dynamic and static parameters
        :param voltage_min:             min acceptable value of SFP module TX supply voltage
        :param voltage_max:             max acceptable value of SFP module TX supply voltage
        """
        sw_version = self.get_bts_sw_version()
        if "SBTS22R3" not in sw_version:
            for sfp in sfp_list_for_module:
                assert voltage_min <= sfp["dynamic"]["TXSupplyVoltage"] <= voltage_max, \
                    "'Transceiver Tx supply voltage' is out of the range: {}mV - {}mV".format(voltage_min, voltage_max)
        else:
            self.check_if_sfp_dynamic_parameters_have_valid_values(sfp_list_for_module, tx_rx_power_units="dBm")

    def check_if_sfp_dynamic_parameters_from_pm_counters_have_valid_values(self, sfp_list_for_module):
        """
        Check if SFP dynamic parameters in PM counters have valid values.
        :param sfp_list_for_module:     list of dicts with SFP dynamic and static parameters
        """
        self.check_if_sfp_dynamic_parameters_have_valid_values(sfp_list_for_module, tx_rx_power_units="dBm")

    def check_if_sfp_dynamic_parameters_from_snapshot_have_valid_values(self, sfp_list_for_module):
        """
        Check if SFP dynamic parameters in Snapshot have valid values.
        :param sfp_list_for_module:     list of dicts with SFP dynamic and static parameters
        """
        self.check_if_sfp_dynamic_parameters_have_valid_values(sfp_list_for_module, tx_rx_power_units="uW")

    def check_if_sfp_static_rx_parameters_have_valid_values(self, sfp_list_for_module, sfps_in_test):
        """
        Check if SFP static RX parameters have valid values.
        :param sfp_list_for_module:     list of dicts with SFP dynamic and static parameters
        :param sfps_in_test:            list of SFP used in test
        """
        logging.info("SFPs used in test: {}".format(sfps_in_test))
        sfps_hw = self.get_sfps_hw_details(sfps_in_test)
        module_index = 0
        for sfp_hw in sfps_hw:
            hw_params = [sfp_hw.rx_power_high_alarm_threshold, sfp_hw.rx_power_high_warn_threshold,
                         sfp_hw.rx_power_low_alarm_threshold, sfp_hw.rx_power_low_warn_threshold]
            self._check_if_static_power_parameters_have_valid_values(sfp_list_for_module[module_index],
                                                                     self.sfp_static_rx_params,
                                                                     sfps_in_test[module_index], hw_params)
            module_index += 1

    def check_if_sfp_static_tx_parameters_have_valid_values(self, sfp_list_for_module, sfps_in_test):
        """
        Check if SFP static TX parameters have valid values.
        :param sfp_list_for_module:     list of dicts with SFP dynamic and static parameters
        :param sfps_in_test:            list of SFP used in test
        """
        logging.info("SFPs used in test: {}".format(sfps_in_test))
        sfps_hw = self.get_sfps_hw_details(sfps_in_test)
        module_index = 0
        for sfp_hw in sfps_hw:
            hw_params = [sfp_hw.tx_power_high_alarm_threshold, sfp_hw.tx_power_high_warn_threshold,
                         sfp_hw.tx_power_low_alarm_threshold, sfp_hw.tx_power_low_warn_threshold]
            self._check_if_static_power_parameters_have_valid_values(sfp_list_for_module[module_index],
                                                                     self.sfp_static_tx_params,
                                                                     sfps_in_test[module_index], hw_params)
            module_index += 1

    @staticmethod
    def _check_if_static_power_parameters_have_valid_values(sfp_for_module, sfp_static_power_params, sfp_hw, hw_params):
        """
        Check if SFP static power parameters have valid values.
        :param sfp_for_module:              dicts with SFP dynamic and static parameters
        :param sfp_static_power_params:     list of SFP power parameters
        :param sfp_hw:                      SFP used in test
        :param hw_params:                   power parameters of SFP used in test
        """
        for i in range(len(sfp_static_power_params)):
            sfp_param_value = sfp_for_module["static"][sfp_static_power_params[i]]
            assert sfp_param_value == hw_params[i], "{}; Value of parameter '{}'='{}dBm' is different than expected:" \
                                                    " '{}dBm'".format(sfp_hw, sfp_static_power_params[i],
                                                                      sfp_param_value, hw_params[i])
            logging.info("{}; SFP parameter '{}'='{}' is as expected '{}'".format(sfp_hw,
                                                                                  sfp_static_power_params[i],
                                                                                  sfp_param_value, hw_params[i]))

    def check_if_sfp_static_hw_parameters_have_valid_values_for_bbmod(self, sfp_list_for_module, sfps_in_test):
        """
        Check if SFP static hardware SFP/QSFP parameters have valid values for BBMOD.
        :param sfp_list_for_module:     list of dicts with SFP dynamic and static parameters
        :param sfps_in_test:            list of SFP used in test
        """
        self._check_if_sfp_static_hw_parameters_have_valid_values_for_module(sfp_list_for_module, sfps_in_test,
                                                                             module_type="bbmod")

    def check_if_sfp_static_hw_parameters_have_valid_values_for_rmod(self, sfp_list_for_module, sfps_in_test):
        """
        Check if SFP static hardware SFP/QSFP parameters have valid values for RMOD.
        :param sfp_list_for_module:     list of dicts with SFP dynamic and static parameters
        :param sfps_in_test:            list of SFP used in test
        """
        self._check_if_sfp_static_hw_parameters_have_valid_values_for_module(sfp_list_for_module, sfps_in_test,
                                                                             module_type="rmod")

    def check_if_sfp_static_hw_parameters_have_valid_values_for_smod(self, sfp_list_for_module, sfp_in_test):
        """
        Check if SFP static hardware SFP/QSFP parameters have valid values for SMOD.
        :param sfp_list_for_module:     list of dicts with SFP dynamic and static parameters
        :param sfp_in_test:             parameters of SFP used in test
        """
        self._check_if_sfp_static_hw_parameters_have_valid_values_for_module(sfp_list_for_module, sfp_in_test,
                                                                             module_type="smod")

    def check_if_sfp_static_temperature_parameters_have_valid_values(self, sfp_list_for_module, sfps_in_test):
        """
        Check if SFP static temperature SFP/QSFP parameters have valid values for given module.
        :param sfp_list_for_module:     list of dicts with SFP dynamic and static parameters
        :param sfps_in_test:            list of SFP used in test
        """
        logging.info("SFPs used in test: {}".format(sfps_in_test))
        sfps_hw = self.get_sfps_hw_details(sfps_in_test)
        module_index = 0
        for sfp in sfp_list_for_module:
            hw_params = [sfps_hw[module_index].temperature_high_alarm_threshold,
                         sfps_hw[module_index].temperature_low_alarm_threshold]
            for i in range(len(self.sfp_static_temp_params)):
                sfp_param_value = sfp["static"][self.sfp_static_temp_params[i]].strip()
                assert sfp_param_value == hw_params[i], "{}; Value of parameter '{}'='{}' is different than expected" \
                                                        " '{}'".format(sfps_in_test[module_index],
                                                                       self.sfp_static_temp_params[i],
                                                                       sfp_param_value, hw_params[i])
                logging.info("{}; SFP parameter '{}'='{}' is as expected '{}'".format(sfps_in_test[module_index],
                                                                                      self.sfp_static_temp_params[i],
                                                                                      sfp_param_value, hw_params[i]))
            module_index += 1

    @staticmethod
    def get_sfps_hw_details(sfps):
        sfps_hw = []
        for sfp in sfps:
            sfps_hw.append(sfps_for_test.sfp_dict[sfp])
        return sfps_hw

    def _check_if_sfp_static_hw_parameters_have_valid_values_for_module(self, sfp_list_for_module, sfps_in_test,
                                                                        module_type):
        """
        Check if SFP static hardware SFP/QSFP parameters have valid values.
        :param sfp_list_for_module:     list of dicts with SFP dynamic and static parameters
        :param sfps_in_test:            list of SFP used in test
        :param module_type:             type of module for which SFP data should be checked: SMOD, BBMOD or RMOD
        """
        logging.info("SFPs used in test: {}".format(sfps_in_test))
        sfps_hw = self.get_sfps_hw_details(sfps_in_test)
        module_index = 0
        static_params = list()
        static_params.extend(self.sfp_static_parameters)
        static_params.extend(self.sfp_hardware_parameters)
        static_params.remove("physicalPort")
        for sfp in sfp_list_for_module:
            hw_params = [sfps_hw[module_index].date_code, sfps_hw[module_index].wave_length,
                         sfps_hw[module_index].transmission_rate, sfps_hw[module_index].nominal_signaling_rate,
                         sfps_hw[module_index].compliance_code, sfps_hw[module_index].vendor,
                         sfps_hw[module_index].vendor_part_number, sfps_hw[module_index].vendor_revision,
                         sfps_hw[module_index].serial_number, sfps_hw[module_index].connector_type]
            for i in range(len(static_params)):
                sfp_param_value = sfp["static"][static_params[i]].strip()
                if static_params[i] == "complianceCode" and sfp_param_value == "UNKNOWN":
                    logging.info("{}; Valid revision for '{}' param can't be found ('{}'). Skipping verification of "
                                 "this SFP parameter.".format(sfps_in_test[module_index], static_params[i],
                                                              sfp_param_value))
                    continue
                if static_params[i] == "transmissionRate":
                    sfp_param_value = (str(float(sfp_param_value)).strip())
                assert sfp_param_value == hw_params[i], "{}; Value of parameter '{}'='{}' is different than expected" \
                                                        " '{}'".format(sfps_in_test[module_index], static_params[i],
                                                                       sfp_param_value, hw_params[i])
                logging.info("{}; SFP parameter '{}'='{}' is as expected '{}'".format(sfps_in_test[module_index],
                                                                                      static_params[i],
                                                                                      sfp_param_value, hw_params[i]))
            self._check_if_physical_port_have_valid_value(module_type, sfp, sfps_in_test[module_index])
            module_index += 1

    def _check_if_physical_port_have_valid_value(self, module_type, sfp, sfp_hw):
        """
        Check if SFP physical port parameter have valid value depending on module type.
        :param module_type:     type of module for which SFP data should be checked: SMOD, BBMOD or RMOD
        :param sfp:             dict with SFP dynamic and static parameters
        :param sfp_hw:          SFP used in test
        """
        port_num = self.get_sfps_hw_details([sfp_hw])[0].physical_port
        if module_type == "rmod":
            sfp_physical_port = "OPT_IF{}".format(port_num)
        elif module_type == "bbmod":
            sfp_physical_port = "RF{}".format(port_num)
        else:
            sfp_physical_port = "EIF{}".format(port_num)
        physical_port = sfp["static"]["physicalPort"]
        assert physical_port == sfp_physical_port, "{}; Value of parameter 'physicalPort'='{}' is different than " \
                                                   "expected: '{}'".format(sfp_hw, physical_port, sfp_physical_port)
        logging.info("{}; SFP parameter 'physicalPort'='{}' is as expected '{}'".format(sfp_hw, physical_port,
                                                                                        sfp_physical_port))

    def _get_sfp_static_data_from_netact(self, module_type):
        """
        Get dict with SFP static data from NetAct
        :param module_type:            type of module for which SFP data should be checked: SMOD, BBMOD or RMOD
        :return:                       dict with SFP static data
        """
        if module_type == "rmod":
            sfp_mo = 'PLMN-PLMN/MRBTS-{mrbts_id}/EQM_R-4/APEQM_R-1/RMOD_R-1/SFP_R-1'.format(
                mrbts_id=self.tl.gnbs[0].global_bts_id)
            cablink_mo = 'PLMN-PLMN/MRBTS-{mrbts_id}/EQM_R-4/HWTOP_R-1/CABLINK_R-1003'.format(
                mrbts_id=self.tl.gnbs[0].global_bts_id)
        elif module_type == "bbmod":
            sfp_mo = 'PLMN-PLMN/MRBTS-{mrbts_id}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1'.format(
                mrbts_id=self.tl.gnbs[0].global_bts_id)
            cablink_mo = 'PLMN-PLMN/MRBTS-{mrbts_id}/EQM_R-4/HWTOP_R-1/CABLINK_R-1003'.format(
                mrbts_id=self.tl.gnbs[0].global_bts_id)
        else:
            sfp_mo = 'PLMN-PLMN/MRBTS-{mrbts_id}/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-1'.format(
                mrbts_id=self.tl.gnbs[0].global_bts_id)

        sfp_static_data = {}
        actual_conf = self.netact.get_actual_configuration()
        actual_sfp_mo = self.netact.get_managed_object(actual_conf, sfp_mo)
        for static_parameter in \
                self.sfp_static_parameters + self.sfp_static_tx_params + self.sfp_static_rx_params + \
                self.sfp_static_temp_params + self.sfp_hardware_parameters:
            if static_parameter == "vendor":
                sfp_static_data['vendor'] = actual_sfp_mo.parameters['vendorName']
            else:
                sfp_static_data[static_parameter] = actual_sfp_mo.parameters[static_parameter]
        if module_type != "smod":
            actual_cablink_mo = self.netact.get_managed_object(actual_conf, cablink_mo)
            sfp_static_data["linkSpeed"] = actual_cablink_mo.parameters["linkSpeed"]
            sfp_static_data["fiberLength"] = actual_cablink_mo.parameters["fiberLength"]
        logging.info("SFP static data from NetAct: {}".format(sfp_static_data))
        return sfp_static_data

    def check_if_sfp_static_parameters_from_netact_have_valid_values(self, sfps_in_test, module_type):
        """
        Check if SFP parameters in NetAct have valid values.
        :param sfps_in_test:    list of SFP used in test
        :param module_type:     type of module for which SFP data should be checked: SMOD, BBMOD or RMOD
        """
        netact_data = self._get_sfp_static_data_from_netact(module_type)
        sfps_hw = self.get_sfps_hw_details(sfps_in_test)
        sfp_hw = sfps_hw[0]
        hw_params = [sfp_hw.date_code, sfp_hw.wave_length, sfp_hw.transmission_rate, sfp_hw.nominal_signaling_rate,
                     sfp_hw.tx_power_high_alarm_threshold, sfp_hw.tx_power_high_warn_threshold,
                     sfp_hw.tx_power_low_alarm_threshold, sfp_hw.tx_power_low_warn_threshold,
                     sfp_hw.rx_power_high_alarm_threshold, sfp_hw.rx_power_high_warn_threshold,
                     sfp_hw.rx_power_low_alarm_threshold, sfp_hw.rx_power_low_warn_threshold,
                     sfp_hw.temperature_high_alarm_threshold, sfp_hw.temperature_low_alarm_threshold,
                     sfp_hw.compliance_code, sfp_hw.vendor,
                     sfp_hw.vendor_part_number, sfp_hw.vendor_revision,
                     sfp_hw.serial_number, sfp_hw.connector_type]
        for static_parameter, hw_static_value in zip(netact_data, hw_params):
            if static_parameter == 'complianceCode' and netact_data[static_parameter] == 'UNKNOWN':
                logging.info("Valid revision for 'complianceCode' param can't be found."
                             "Skipping verification of this SFP parameter.")
                continue
            assert netact_data[static_parameter].strip() == hw_static_value.strip(), \
                "Value of parameter '{}'='{}' is different than expected: {}".format(static_parameter,
                                                                                     netact_data[static_parameter],
                                                                                     hw_static_value)
        self._check_fiber_length_and_physical_port_for_sfp_in_netact(netact_data, module_type)

    # TODO: Check if verification of physical_port working properly with NetAct
    def _check_fiber_length_and_physical_port_for_sfp_in_netact(self, netact_data, module_type):
        """
        Check if SFP parameters 'fiberLength' and 'physicalPort' in NetAct have valid values.
        :param netact_data:     dict with SFP parameters from Netact
        :param module_type:     type of module for which SFP data should be checked: SMOD, BBMOD or RMOD
        """
        sfp = dict()
        sfp["static"] = netact_data
        self._check_if_physical_port_have_valid_value(module_type, sfp, 1)
        if module_type != 'smod':
            assert int(netact_data["fiberLength"]) > 0, \
                "Value of parameter 'fiberLength'={}mm should be greater than 0".format(netact_data["fiberLength"])
