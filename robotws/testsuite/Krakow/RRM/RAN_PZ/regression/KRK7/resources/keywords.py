"""
:copyright: Nokia Networks
:author: Bartlomiej Bienko, Wioleta Swies
:contact: bartlomiej.bienko@nokia.com, wioleta.swies@nokia.com
:maintainer: Bartlomiej Bienko, Wioleta Swies
:contact: bartlomiej.bienko@nokia.com, wioleta.swies@nokia.com

Common keywords used in regression for RRM tests in SG7
"""

from pathlib import Path
from pprint import PrettyPrinter
import os
import time
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb import ClassicalBts

from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from robot.libraries.BuiltIn import BuiltIn, logger
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK7.resources.attenuator import AttenuatorInterface
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK7.resources.methods import GnbWeb as gnb
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK7.resources.pcap_collector import PcapCollector
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations, EnbDuOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning, EnbCommissioning
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification, EnbAlarmVerification
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate, EnbSwUpdate
from taf.rfrl.bts.commissioning import perform_full_commissioning_on_classical_gnb, \
    perform_full_commissioning_on_classical_enb


# - - - - - - - - - - Connection related methods  - - - - - - - - -


def get_test_pcs_from_testline_configuration():
    config = BuiltIn().get_variable_value("${{{}}}".format("tl"), None).test_pcs
    return config


def get_gnbs_from_testline_configuration():
    config = BuiltIn().get_variable_value("${{{}}}".format("tl"), None).gnbs
    return config


def get_enbs_from_testline_configuration():
    config = BuiltIn().get_variable_value("${{{}}}".format("tl"), None).enbs
    return config


def get_ip_for_bts_instance(bts_instance):
    if isinstance(bts_instance, RealEnb):
        return bts_instance.oam_ip.v4.split("/")[0]
    return bts_instance.cu.backhaul_site_oam_ip.v4.split("/")[0]


def get_username_for_bts_instance(bts_instance):
    if isinstance(bts_instance, RealEnb) or isinstance(bts_instance, ClassicalBts):
        gnbs = get_gnbs_from_testline_configuration()[0]
        return gnbs.cu.oam_http_connection_details.username
    raise Exception('Bts is not RealEnb or ClassicalBts instance')


def get_password_for_bts_instance(bts_instance):
    if isinstance(bts_instance, RealEnb) or isinstance(bts_instance, ClassicalBts):
        gnbs = get_gnbs_from_testline_configuration()[0]
        return gnbs.cu.oam_http_connection_details.password
    raise Exception('Bts is not RealEnb or ClassicalBts instance')


def get_mrbts_id_for_bts_instance(bts_instance):
    if isinstance(bts_instance, RealEnb):
        return bts_instance.global_bts_id
    return bts_instance.cu.global_bts_id


def get_oam_connection_details_from_bts_instance(bts_instance):
    return {
        "ip": get_ip_for_bts_instance(bts_instance),
        "username": get_username_for_bts_instance(bts_instance),
        "password": get_password_for_bts_instance(bts_instance),
        "mrbts_id": get_mrbts_id_for_bts_instance(bts_instance),
    }


def get_gnb_from_testline_configuration_basing_on_id(gnbId):
    gnbs = get_gnbs_from_testline_configuration()

    for gnb in gnbs:
        if gnb.instance_id == gnbId:
            return gnb
    raise Exception(f"There are no gNB with id = {gnbId}! Present gNBs are: {[gnb.instance_id for gnb in gnbs]}")


def get_list_of_all_bts_ip_address():
    gnbs = get_gnbs_from_testline_configuration()
    gnbs_ip = [get_ip_for_bts_instance(gnb) for gnb in gnbs]

    enbs = get_enbs_from_testline_configuration()
    enbs_ip = [get_ip_for_bts_instance(enb) for enb in enbs]
    logger.debug(f"IP of all BTS: {gnbs_ip + enbs_ip}")
    return gnbs_ip + enbs_ip


def get_hostname_for_test_pcs():
    test_pcs = get_test_pcs_from_testline_configuration()
    hostnames = [regexp_to_get_hostname(pc.default_ssh_connection_details.addr) for pc in test_pcs]
    return hostnames


def regexp_to_get_hostname(host):
    return host.split('.')[0].replace('-', '_')

# - - - - - - - - - - Recommisioning methods - - - - - - - - - - - -


def set_a4_periodic_meas_control_nsa(fr1_supervision_timer,
                                     fr2_supervision_timer,
                                     meas_max_number,
                                     retry_timer,
                                     gnb_instance_id=0,
                                     cell_id=1):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    gnb_api.set_a4_periodic_meas_control_nsa(fr1_supervision_timer=fr1_supervision_timer,
                                             fr2_supervision_timer=fr2_supervision_timer,
                                             meas_max_number=meas_max_number,
                                             retry_timer=retry_timer,
                                             cell_id=cell_id)


def set_a4_periodic_meas_control_nsa_for_gnb2(fr1_supervision_timer,
                                              fr2_supervision_timer,
                                              meas_max_number,
                                              retry_timer,
                                              gnb_instance_id=1,
                                              cell_id=1):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    gnb_api.set_a4_periodic_meas_control_nsa(fr1_supervision_timer,
                                             fr2_supervision_timer,
                                             meas_max_number,
                                             retry_timer,
                                             cell_id=cell_id)


def set_a4_meas_higher_prio_freq_disabled(nrhoif_list, cell_id, a4_prio_freq_enabled='none', gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    for nrhoif_id in nrhoif_list:
        gnb_api.set_a4_meas_higher_prio_freq_disabled(a4_prio_freq_enabled=a4_prio_freq_enabled,
                                                      nrhoif_id=nrhoif_id,
                                                      cell_id=cell_id)


def get_arfcn_ssb_pbch(cell_id, gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    return gnb_api.get_arfcn_ssb_pbch(cell_id)


def get_ssb_frequency_and_rsrp(nrhoif_list, cell_id, gnb_instance_id=0):
    freq_rsrp_list = []
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    for nrhoif_id in nrhoif_list:
        out = gnb_api.get_ssb_frequency_and_rsrp(nrhoif_id, cell_id)
        freq_rsrp_list.extend(out)
    return freq_rsrp_list


def get_ssb_frequency(nrhoif_id, cell_id, gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    return gnb_api.get_ssb_frequency(nrhoif_id=nrhoif_id, cell_id=cell_id)


def set_a4_measurement_ssb_rsrp(hysteresis_rsrp,
                                threshold_rsrp,
                                time_to_trigger_rsrp,
                                nrhoif_list,
                                cell_id,
                                gnb_instance_id=0):
    if not isinstance(nrhoif_list, list):
        nrhoif_list = [nrhoif_list]

    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))

    for nrhoif_id in nrhoif_list:
        gnb_api.set_a4_measurement_ssb_rsrp(hysteresis_rsrp=hysteresis_rsrp,
                                            threshold_rsrp=threshold_rsrp,
                                            time_to_trigger_rsrp=time_to_trigger_rsrp,
                                            nrhoif_id=nrhoif_id,
                                            cell_id=cell_id)


def get_target_pci(cell_num, gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    return gnb_api.get_target_pci_from_nr_adj_object(cell_num)


def get_enb_b1_threshold_nr_rsrp(carrier_freq, enb_instance_id=0):
    enb_instance = get_enbs_from_testline_configuration()[enb_instance_id]
    enb_api = gnb(**get_oam_connection_details_from_bts_instance(enb_instance))
    return enb_api.get_enb_b1_threshold_nr_rsrp(carrier_freq)


def set_enb_b1_threshold_nr_rsrp(carrier_freq, b1_threshold_rsrp, enb_instance_id=0):
    enb_instance = get_enbs_from_testline_configuration()[enb_instance_id]
    enb_api = gnb(**get_oam_connection_details_from_bts_instance(enb_instance))
    return enb_api.set_enb_b1_threshold_nr_rsrp(carrier_freq, b1_threshold_rsrp)


def toggle_a2MeashoEnabled(enabled, gnb_instance_id=0):
    """
    Enables or disables A2 Measurement NSA for HO
    """
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    gnb_api.toggle_a2MeashoEnabled(enabled=enabled)


def toggle_a2MeashoEnabledSA(enabled, nrcell_id=1, gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    parameter = 'a2MeashoEnabledSA'
    dist_name = f"MRBTS-{gnb_instance.global_bts_id}/NRBTS-{gnb_instance.global_bts_id}/NRCELL-{nrcell_id}"

    desired_value = {
        True: 'rsrp',
        False: 'none',
    }

    gnb_api.perform_parameter_recommissioning(dist_name=dist_name,
                                              parameter=parameter,
                                              operation="update",
                                              value=desired_value[enabled])


def set_event_threshold(event, value, gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    gnb_api.set_treshold_ho_ssb_rsrp(event=event, value=value)


def set_a1_measho_ssb_rsrp(a1ThresholdhoSsbRsrp,
                           a1HysteresishoSsbRsrp=0,
                           a1TimeToTriggerhoSsbRsrp="ms480",
                           gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    gnb_api.set_a1MeashoSsbRsrp(a1HysteresishoSsbRsrp=a1HysteresishoSsbRsrp,
                                a1ThresholdhoSsbRsrp=a1ThresholdhoSsbRsrp,
                                a1TimeToTriggerhoSsbRsrp=a1TimeToTriggerhoSsbRsrp)


def set_a1_measho_pref_nr_layer_ssb_rsrp(a1ThresholdhoSsbRsrp,
                                         a1HysteresishoSsbRsrp=0,
                                         a1TimeToTriggerhoSsbRsrp="ms480",
                                         gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    gnb_api.set_a1MeashoPrefNRLayerSsbRsrp(a1HysteresishoSsbRsrp=a1HysteresishoSsbRsrp,
                                           a1ThresholdhoSsbRsrp=a1ThresholdhoSsbRsrp,
                                           a1TimeToTriggerhoSsbRsrp=a1TimeToTriggerhoSsbRsrp)


def set_a2_measho_ssb_rsrp(a2ThresholdhoSsbRsrp,
                           a2HysteresishoSsbRsrp=0,
                           a2TimeToTriggerhoSsbRsrp="ms480",
                           gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    gnb_api.set_a2MeashoSsbRsrp(a2HysteresishoSsbRsrp=a2HysteresishoSsbRsrp,
                                a2ThresholdhoSsbRsrp=a2ThresholdhoSsbRsrp,
                                a2TimeToTriggerhoSsbRsrp=a2TimeToTriggerhoSsbRsrp)


def set_a4_higher_priority(priority_list, cell_id, gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    gnb_api.set_a4_higher_priority(priority_list, cell_id)


def set_a1_meas_ho_pref_nr_layer_enabled(a1_enabled, gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    gnb_api.set_a1_meas_ho_pref_nr_layer_enabled(a1_enabled=a1_enabled)


def set_act_a1_ho_pref_nr_layer(actA1HoPrefNRLayer, gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    gnb_api.set_act_a1_ho_pref_nr_layer(actA1HoPrefNRLayer=actA1HoPrefNRLayer)


def get_report_interval_ho_nsa(gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    return gnb_api.get_report_interval_ho_nsa()


def get_report_amount_ho_nsa(gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    return gnb_api.get_report_amount_ho_nsa()


def set_a2_meas_ho_nsa(a2MeasReleaseEnabled,
                       a2MeasRedirectEnabled,
                       a2MeashoEnabled,
                       a2MeashoEnabledSA,
                       nr_cell_id,
                       gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    dist_name = f"MRBTS-{gnb_instance.global_bts_id}/NRBTS-{gnb_instance.global_bts_id}/NRCELL-{nr_cell_id}"
    gnb_api.perform_parameter_recommissioning(dist_name=dist_name, parameter="a2MeasReleaseEnabled",
                                              operation="update", value=a2MeasReleaseEnabled)
    gnb_api.perform_parameter_recommissioning(dist_name=dist_name, parameter="a2MeasRedirectEnabled",
                                              operation="update", value=a2MeasRedirectEnabled)
    gnb_api.perform_parameter_recommissioning(dist_name=dist_name, parameter="a2MeashoEnabled",
                                              operation="update", value=a2MeashoEnabled)
    gnb_api.perform_parameter_recommissioning(dist_name=dist_name, parameter="a2MeashoEnabledSA",
                                              operation="update", value=a2MeashoEnabledSA)


def calculate_supervision_retry_loop_time_sec(supervision_timer, retry_timer, a4meas_max_number):
    """
    Calculates time for single loop in which the MR's are dropped

    :param str supervision_timer: Time of supervisionTimer from WebEM, given in miliseconds
    :param str retry_timer: Time of retryTimer from WebEM, given in seconds
    :param str a4meas_max_number: Number of single supervision&retry exectuion times within one loop

    :return float number of seconds of loop time
    """
    supervision_timer_num = float(supervision_timer) / 1000
    retry_timer_num = float(retry_timer)
    a4meas_max_number_int = int(a4meas_max_number)
    return ((supervision_timer_num + retry_timer_num) * a4meas_max_number_int) + supervision_timer_num


def calculate_(supervision_timer, retry_timer, a4meas_max_number):
    """
    Calculates time for single loop in which the MR's are dropped

    :param str supervision_timer: Time of supervisionTimer from WebEM, given in miliseconds
    :param str retry_timer: Time of retryTimer from WebEM, given in seconds
    :param str a4meas_max_number: Number of single supervision&retry exectuion times within one loop

    :return float number of seconds of loop time
    """
    supervision_timer_num = float(supervision_timer) / 1000
    retry_timer_num = float(retry_timer)
    a4meas_max_number_int = int(a4meas_max_number)
    return (supervision_timer_num + retry_timer_num) * a4meas_max_number_int


def set_a4_meas_higher_prio_freq_max_react(max_react, cell_id, gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    gnb_api.set_a4_meas_higher_prio_freq_max_react(max_react, cell_id)


def get_x2c_ip_address(gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    x2c_ip_addr = gnb_instance.cu.x2c.v4.split("/")[0]
    return x2c_ip_addr


def get_current_hostname_for_running_test():
    hostname = os.popen('hostname').read().replace('-', '_')
    return hostname


# - - - - - - - - - - eNB/gNB relations and mapping methods  - - - - - - - - - -


def change_SgNB_addition_cell_on_eNB(gnbId_to_addition, cellId_to_addition, enb_instance_id=0):
    endc_nrcell_mapping = map_endcmeasconf_with_nrcells()

    gnb_nidd = f"NRBTS-{gnbId_to_addition}"
    nrcelL_nidd = f"NRCELL-{cellId_to_addition}"
    desired_mapping = None
    for endc in endc_nrcell_mapping:
        mapped_nrcell = endc_nrcell_mapping[endc]
        if gnb_nidd in mapped_nrcell and nrcelL_nidd in mapped_nrcell:
            desired_mapping = endc_nrcell_mapping.pop(endc)
            break

    if not desired_mapping:
        raise Exception(f"Improper mapped nrcell! desired_mapping: {desired_mapping}")

    enb_instance = BuiltIn().get_variable_value("${{{}}}".format("tl"), None).enbs[enb_instance_id]
    enb_api = gnb(**get_oam_connection_details_from_bts_instance(enb_instance))

    parameter = "b1ThresholdNrRsrp"
    enabled = {
        True: "46",    # -156 + 46  = -110
        False: "126",  # -156 + 126 = -30
    }

    for endc, nrcell in map_endcmeasconf_with_nrcells().items():
        if cellId_to_addition in nrcell.split('/')[-1]:
            enb_api.perform_parameter_recommissioning(dist_name=endc, parameter=parameter,
                                                      operation="update", value=enabled[True])
        else:
            enb_api.perform_parameter_recommissioning(dist_name=endc, parameter=parameter,
                                                      operation="update", value=enabled[False])


def get_endcmeasconf_configuration_from_eNB(enb_instance_id=0):
    enb_instance = BuiltIn().get_variable_value("${{{}}}".format("tl"), None).enbs[enb_instance_id]
    enb_api = gnb(**get_oam_connection_details_from_bts_instance(enb_instance))

    nidd_class = "ENDCDMEASCONF_A"
    result = enb_api.get_managed_objects(class_name=nidd_class)
    return result


def get_gnbs_nrcells_from_init():
    gnbs = get_gnbs_from_testline_configuration()
    nrcells = []
    for gnb_instance in gnbs:
        logger.debug(f"Now connecting to gNB with credentials: "
                     f"{get_oam_connection_details_from_bts_instance(gnb_instance)}")
        gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
        result = gnb_api.get_managed_objects('NRCELL_R')
        nrcells += result
    log_to_console_formated_dict(nrcells)
    logger.debug(f"quantity of NRCELLs on all gNBs are {len(nrcells)}")
    return nrcells


def map_endcmeasconf_with_nrcells():
    """
    Maps eNB EMDCMEASCONF objects to corresponding NRCELLs basing on carrierFreqNrCell to arfcnSsbPbch value
    """
    endcmeasconfs = get_endcmeasconf_configuration_from_eNB()
    nrcells = get_gnbs_nrcells_from_init()
    endc_nrcell_mapping = {}
    for endcmeasconf in endcmeasconfs:
        carrierFreqNRCell = endcmeasconf['parameters']['carrierFreqNrCell']
        for nrcell in nrcells:
            arfcnSsbPbch = nrcell['parameters']['arfcnSsbPbch']
            if carrierFreqNRCell == arfcnSsbPbch:
                endc_nrcell_mapping[endcmeasconf['distName']] = nrcell['distName']

    parsed_endc_nrcell_mapping = {}

    for endc, nrcell in endc_nrcell_mapping.items():
        parsed_endc_nrcell_mapping[gnb.prepare_distname_basing_on_configured_distname(distname=endc, mode='A')] = \
            gnb.prepare_distname_basing_on_configured_distname(distname=nrcell, mode='R')
    log_to_console_formated_dict(f"parsed_endc_nrcell_mapping: {parsed_endc_nrcell_mapping}")
    return parsed_endc_nrcell_mapping

# - - - - - - - - - - NRHOIF-related methods - - - - - - - - - - - - -


def get_nrhoif_list(gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    return gnb_api.get_all_nrhoif_distname_list()


def get_all_nrhoif_configuration_list(gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    return gnb_api.get_all_nrhoif_configuration_list()


def get_fr1_nrhoif_list(gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    return gnb_api.get_fr1_nrhoif_list()


def get_fr2_nrhoif_distname_list(gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    return gnb_api.get_fr1_nrhoif_distname_list()


def toggle_event_a_on_desired_nrhoif(fr, event, enabled, gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    return gnb_api.toggle_event_a_on_desired_nrhoif(fr=fr, event=event, enabled=enabled)


def toggle_all_a_events_on_all_nrhoif(enabled, gnb_instance_id=0):
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    frs = ['FR1', 'FR2']
    events = ['A3', 'A4', 'A5']
    for fr in frs:
        for event in events:
            gnb_api.toggle_event_a_on_desired_nrhoif(fr=fr, event=event, enabled=enabled)


def toggle_events_a_on_desired_nrhoifs(mapping, gnb_instance_id=0, filter_by_nrcell_id=None):
    """
    Toggle desired A events (A3/A4/A5) on all NRHOIF basing on their FR - FR1 or FR2
    :param dict mapping: describing which events should be enabled on which NRHOIFs;
       the required keys are 'FR1' and 'FR2', values of each key are lists containing string ('A3', 'A4', 'A5')
       which determines type of events that should be turn on of all NRHOIFs of desired type.
    :param int gnb_instance_id: determines which gnb_instance (basing of __init__.py) should be use
    """
    gnb_instance = get_gnbs_from_testline_configuration()[gnb_instance_id]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    gnb_api.toggle_events_a_on_desired_nrhoifs(mapping=mapping, filter_by_nrcell_id=filter_by_nrcell_id)


def save_nrhoif_configuration_to_python_module(path_to_module="/tmp/nrhoif.py", gnb_instance_id=0):
    """
    Fetches NRHOIF configuration from gNB and encapsulates it as python module.

    :param str path_to_modules: path (with filename) where NRHOIF configuration should be stored
    """
    formatter = PrettyPrinter(indent=1)
    variable_name = "nrhoifs"
    nrhoif_configuration_value = get_all_nrhoif_configuration_list(gnb_instance_id=gnb_instance_id)
    path, filename = '/'.join(path_to_module.split('/')[:-1]), path_to_module.split('/')[-1]
    Path(path).mkdir(parents=True, exist_ok=True)
    with open(path_to_module, 'w') as nrhoif_module:
        value = formatter.pformat(nrhoif_configuration_value)
        nrhoif_module.write(f"{variable_name} = \\\n {value}")

# - - - - - - - - - - Attenuation-related methods - - - - - - - - -


def create_attenuation_interface(port_no):
    return AttenuatorInterface(main_port=port_no)


def attenuate(attenuator, attenuation_value, port_no=None):
    attenuator.attenuate(attenuation_value=attenuation_value, port_no=port_no)


def turn_off_attenuation(attenuator, port_no=None):
    attenuator.disable_attenuation(port_no=port_no)


def evaluate_attenuation_delay(retry_timer_sec):
    """
    Attenuation should start during SuperVisionTimer
    As reference point the UE attachment is considered
    Description below is associated with Feature CB007517:
        1. UE Attaches to LTE
        2. During next 2 sec. UE Addition to SgNB Occurs
        3. The RetryTimer lasts
        4. The SupervisionTimer starts
    """
    addition_from_attach_avg_time = 2
    return addition_from_attach_avg_time + int(retry_timer_sec)


def turn_off_attenuation_on_many_ports(attenuator, ports):
    for port in ports:
        attenuator.disable_attenuation(port_no=port)


# - - - - - - - - - - Additional, helper methods - - - - - - - - - -


def log_to_console_formated_dict(dict_to_log):
    formated_dict = PrettyPrinter(indent=2).pformat(dict_to_log)
    logger.debug(formated_dict)


def archivize_logs(archive_name,
                   archive_path,
                   pdml_path,
                   pcap_path):
    """
    Example Usage of keyword:
        Archivize Logs    archive_name=${TEST_NAME}
        ...               archive_path=/tmp
        ...               pdml_path=/tmp/collected_packets.pdml
        ...               pcap_path=/tmp/collected_packets.pcap
    """
    PcapCollector().archivize_logs(archive_name, archive_path, pdml_path, pcap_path)


def save_scf_of_desired_gnb_in_robot_logs_directory(gnb_instance_index=0,
                                                    path=BuiltIn().get_variable_value("${OUTPUT DIR}"),
                                                    file_name='SCF.xml',):
    """
    Saves SCF of desired gNB from __init__.py file to the logs directory

    :param int gnb_instance_index: index of tl.gnbs[] list from __init__.py
    :param str path: output path, by default it is robot logs directory provided after '-d' robot command
    :param str file_name: name of scf file
    """
    gnb_instance = BuiltIn().get_variable_value("${{{}}}".format("tl"), None).gnbs[gnb_instance_index]
    gnb_api = gnb(**get_oam_connection_details_from_bts_instance(gnb_instance))
    gnb_api.save_site_commissioning_file(path=path, file_name=file_name)


def wait_for_synchronization(delay):
    time.sleep(delay)
