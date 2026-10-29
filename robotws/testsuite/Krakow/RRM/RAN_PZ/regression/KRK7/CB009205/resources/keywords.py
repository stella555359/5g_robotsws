"""
Keywrods related and used with Feature CB009205

:copyright: Nokia Networks
:author: Bartlomiej Bienko
:maintainer: Bartlomiej Bienko
:contact: bartlomiej.bienko@nokia.com
"""

import testsuite.Krakow.RRM.RAN_PZ.regression.KRK7.CB009205.resources.variables as variables
import testsuite.Krakow.RRM.RAN_PZ.regression.KRK7.resources.keywords as rrm_krk7_keywords
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK7.resources.methods import GnbWeb as gnb


def toggle_actA2SgnbRelease(gnb_instance_index=0, nrbts_id="1", enabled=True):
    if not isinstance(enabled, bool):
        raise Exception(f"The 'enabled' keyword argument should be boolean, but it is type of {type(enabled)}!")

    gnbs = rrm_krk7_keywords.get_gnbs_from_testline_configuration()
    gnb_instance = gnbs[gnb_instance_index]
    gnb_api = gnb(**rrm_krk7_keywords.get_oam_connection_details_from_bts_instance(gnb_instance))
    all_nrbts_distnames = gnb_api.get_commissioning_distanmes_by_managed_class(managed_class="NRBTS")
    desired_nrbts_distname_list = gnb_api.filter_distname_by_id_of_nidd_class(distnames=all_nrbts_distnames,
                                                                              nidd_class="NRBTS",
                                                                              id=str(nrbts_id))

    if not desired_nrbts_distname_list:
        raise Exception(f"There are no NRBTS with id={nrbts_id}! All NRBTS are: {all_nrbts_distnames}")

    desired_nrbts_distname = desired_nrbts_distname_list[0]

    value = {
        True: "true",
        False: "false"
    }

    gnb_api.perform_parameter_recommissioning(dist_name=desired_nrbts_distname,
                                              parameter="actA2SgnbRelease",
                                              value=value[enabled],
                                              operation="update")


def toggle_a1MeashoEnabledSa(gnb_instance_index=0, nrcell_id="1", enabled=True):
    if not isinstance(enabled, bool):
        raise Exception(f"The 'enabled' keyword argument should be boolean, but it is type of {type(enabled)}!")

    gnbs = rrm_krk7_keywords.get_gnbs_from_testline_configuration()
    gnb_instance = gnbs[gnb_instance_index]
    gnb_api = gnb(**rrm_krk7_keywords.get_oam_connection_details_from_bts_instance(gnb_instance))
    all_nrcell_distnames = gnb_api.get_commissioning_distanmes_by_managed_class(managed_class="NRCELL")
    desired_nrcell_distname_list = gnb_api.filter_distname_by_id_of_nidd_class(distnames=all_nrcell_distnames,
                                                                               nidd_class="NRCELL",
                                                                               id=str(nrcell_id))

    if not desired_nrcell_distname_list:
        raise Exception(f"There are no NRCELL with id={nrcell_id}! All NRBTS are: {desired_nrcell_distname_list}")

    desired_nrcell_distname = desired_nrcell_distname_list[0]

    value = {
        True: "rsrp",
        False: "none"
    }

    gnb_api.perform_parameter_recommissioning(dist_name=desired_nrcell_distname,
                                              parameter="a1MeashoEnabledSA",
                                              value=value[enabled],
                                              operation="update")


def toggle_a1MeashoPrefNRLayerEnabled_on_desired_nrcell(gnb_instance_index=0, nrcell_id=1, enabled=True):
    if not isinstance(enabled, bool):
        raise Exception(f"The 'enabled' keyword argument should be boolean, but it is type of {type(enabled)}!")

    gnbs = rrm_krk7_keywords.get_gnbs_from_testline_configuration()
    gnb_instance = gnbs[gnb_instance_index]
    gnb_api = gnb(**rrm_krk7_keywords.get_oam_connection_details_from_bts_instance(gnb_instance))
    all_nrcells_distnames = gnb_api.get_commissioning_distanmes_by_managed_class(managed_class="NRCELL")
    desired_nrcell_distname_list = gnb_api.filter_distname_by_id_of_nidd_class(distnames=all_nrcells_distnames,
                                                                               nidd_class="NRCELL",
                                                                               id=str(nrcell_id))
    if not desired_nrcell_distname_list:
        raise Exception(f"There are no NRCELL with id={nrcell_id}! All NRCELLs are: {all_nrcells_distnames}")

    desired_nrcell_distname = desired_nrcell_distname_list[0]

    value = {
        True: "rsrp",
        False: "none"
    }

    gnb_api.perform_parameter_recommissioning(dist_name=desired_nrcell_distname,
                                              parameter="a1MeashoPrefNRLayerEnabled",
                                              operation="update",
                                              value=value[enabled])


def toggle_actA1HoPrefNRLayer(gnb_instance_index=0, nrbts_id="1", nrcell_id="1", enabled=True):
    if not isinstance(enabled, bool):
        raise Exception(f"The 'enabled' keyword argument should be boolean, but it is type of {type(enabled)}!")

    gnbs = rrm_krk7_keywords.get_gnbs_from_testline_configuration()
    gnb_instance = gnbs[gnb_instance_index]
    gnb_api = gnb(**rrm_krk7_keywords.get_oam_connection_details_from_bts_instance(gnb_instance))
    all_nrbts_distnames = gnb_api.get_commissioning_distanmes_by_managed_class(managed_class="NRBTS")
    desired_nrbts_distname_list = gnb_api.filter_distname_by_id_of_nidd_class(distnames=all_nrbts_distnames,
                                                                              nidd_class="NRBTS",
                                                                              id=str(nrbts_id))

    if not desired_nrbts_distname_list:
        raise Exception(f"There are no NRBTS with id={nrbts_id}! All NRBTS are: {all_nrbts_distnames}")

    desired_nrbts_distname = desired_nrbts_distname_list[0]

    value = {
        True: "NSA",
        False: "none"
    }

    commisioning_data = [
        {
            "distName": desired_nrbts_distname,
            "operation": "update",
            "parameters": [
                {"parameterName": "actA1HoPrefNRLayer", "value": value[enabled], "operation": "update"}
            ]
        }
    ]

    all_nrcells_distnames = gnb_api.get_commissioning_distanmes_by_managed_class(managed_class="NRCELL")
    desired_nrcell_distname_list = gnb_api.filter_distname_by_id_of_nidd_class(distnames=all_nrcells_distnames,
                                                                               nidd_class="NRCELL",
                                                                               id=str(nrcell_id))

    if not desired_nrcell_distname_list:
        raise Exception(f"There are no NRCELL with id={nrcell_id}! All NRCELLs are: {all_nrcells_distnames}")

    desired_nrcell_distname = desired_nrcell_distname_list[0]
    commisioning_data.append({
        "distName": desired_nrcell_distname,
        "operation": "update",
        "parameters": variables.actA1HoPrefNrLayer_configuration_enabled[enabled]
    })

    commisioning_data.append({
        "distName": desired_nrcell_distname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "a4MeasHigherPrioFreqMaxReact",
                "value": variables.max_react_default_value if enabled else "",
                "operation": "update" if enabled else "delete"
            }
        ]
    })

    gnb_api.perform_delta_recommissioning(delta_file=commisioning_data)


def enable_feature_CB009205(nrbts_id, nrcell_id, gnb_instance_index=0, enabled=True):
    if not isinstance(enabled, bool):
        raise Exception(f"The 'enabled' keyword argument should be boolean, but it is type of {type(enabled)}!")

    actA2SgnbRelease_value_for_CB009205 = {  # if CB009205 is enabled the actA2SgnbRelease should be turned off
        True: False,
        False: True,
    }

    toggle_actA2SgnbRelease(gnb_instance_index=gnb_instance_index,
                            nrbts_id=nrbts_id,
                            enabled=actA2SgnbRelease_value_for_CB009205[enabled])

    toggle_a1MeashoPrefNRLayerEnabled_on_desired_nrcell(gnb_instance_index=gnb_instance_index,
                                                        nrcell_id=nrcell_id,
                                                        enabled=enabled)

    a1MeashoEnabledSa_value_for_CB009205 = {  # if CB009205 is enabled the a1MeashoEnabledSa should be turned off
        True: False,
        False: True,
    }

    toggle_a1MeashoEnabledSa(gnb_instance_index=gnb_instance_index,
                             nrcell_id=nrcell_id,
                             enabled=a1MeashoEnabledSa_value_for_CB009205[enabled])

    toggle_actA1HoPrefNRLayer(gnb_instance_index=gnb_instance_index,
                              nrbts_id=nrbts_id,
                              nrcell_id=nrcell_id,
                              enabled=enabled)


def set_a4_measurement_ssb_rsrp(gnb_instance, hysteresis_rsrp, threshold_rsrp, time_to_trigger_rsrp, high_priority,
                                nrhoif_list=None):
    gnb_api = gnb(**rrm_krk7_keywords.get_oam_connection_details_from_bts_instance(gnb_instance))
    if high_priority:
        gnb_api.set_a4_measurement_ssb_rsrp(hysteresis_rsrp=hysteresis_rsrp,
                                            threshold_rsrp=threshold_rsrp,
                                            time_to_trigger_rsrp=time_to_trigger_rsrp,
                                            high_priority=high_priority)
    else:
        for nrhoif_id in nrhoif_list:
            gnb().set_a4_measurement_ssb_rsrp(hysteresis_rsrp=hysteresis_rsrp,
                                              threshold_rsrp=threshold_rsrp,
                                              time_to_trigger_rsrp=time_to_trigger_rsrp,
                                              nrhoif_id=nrhoif_id)


def configure_supervision_retry_timers_on_desired_gnb(gnb_instance_from_init_index,
                                                      fr1_supervision_timer,
                                                      fr2_supervision_timer,
                                                      meas_max_number,
                                                      retry_timer,
                                                      nrcell_id):
    gnbs = rrm_krk7_keywords.get_gnbs_from_testline_configuration()
    desired_gnb = gnbs[gnb_instance_from_init_index]
    gnb_api = gnb(**rrm_krk7_keywords.get_oam_connection_details_from_bts_instance(desired_gnb))
    gnb_api.set_a4_periodic_meas_control_nsa(fr1_supervision_timer=fr1_supervision_timer,
                                             fr2_supervision_timer=fr2_supervision_timer,
                                             meas_max_number=meas_max_number,
                                             retry_timer=retry_timer,
                                             cell_id=nrcell_id)


def configure_thresholds_for_event_a1_on_desired_gnb(gnb_instance_from_init_index,
                                                     nrcell_id,
                                                     a1ThresholdhoSsbRsrp,
                                                     a1HysteresishoSsbRsrp,
                                                     a1TimeToTriggerhoSsbRsrp):
    gnbs = rrm_krk7_keywords.get_gnbs_from_testline_configuration()
    desired_gnb = gnbs[gnb_instance_from_init_index]
    gnb_api = gnb(**rrm_krk7_keywords.get_oam_connection_details_from_bts_instance(desired_gnb))
    gnb_api.set_a1MeashoSsbRsrp(a1HysteresishoSsbRsrp=a1HysteresishoSsbRsrp,
                                a1ThresholdhoSsbRsrp=a1ThresholdhoSsbRsrp,
                                a1TimeToTriggerhoSsbRsrp=a1TimeToTriggerhoSsbRsrp,
                                nrcell=nrcell_id)


def configure_all_events_for_all_nrhoifs(gnb_instance_from_init_index,
                                         nrcell_id,
                                         enabled=True):
    gnbs = rrm_krk7_keywords.get_gnbs_from_testline_configuration()
    desired_gnb = gnbs[gnb_instance_from_init_index]
    gnb_api = gnb(**rrm_krk7_keywords.get_oam_connection_details_from_bts_instance(desired_gnb))

    nrhoifs_to_toggle_event = gnb_api.get_all_nrhoif_distname_list_filtered_by_nrcell(nrcell_id=nrcell_id)
    events_to_enable = ['A3', 'A4', 'A5']
    for event in events_to_enable:
        gnb_api.toggle_event_on_nrhoifs(nrhoifs_distnames=nrhoifs_to_toggle_event,
                                        event=event,
                                        enabled=enabled)


def toggle_event_a2_on_desired_nrcell(gnb_instance_from_init_index,
                                      nrcell_id,
                                      a2MeasReleaseEnabled,
                                      a2MeasRedirectEnabled,
                                      a2MeashoEnabled,
                                      a2MeashoEnabledSA):
    gnbs = rrm_krk7_keywords.get_gnbs_from_testline_configuration()
    desired_gnb = gnbs[gnb_instance_from_init_index]
    gnb_api = gnb(**rrm_krk7_keywords.get_oam_connection_details_from_bts_instance(desired_gnb))

    dist_name = f"MRBTS-{gnb_api.mrbts_id}/NRBTS-{gnb_api.mrbts_id}/NRCELL-{nrcell_id}"
    gnb_api.perform_parameter_recommissioning(dist_name=dist_name, parameter="a2MeasReleaseEnabled",
                                              operation="update", value=a2MeasReleaseEnabled)
    gnb_api.perform_parameter_recommissioning(dist_name=dist_name, parameter="a2MeasRedirectEnabled",
                                              operation="update", value=a2MeasRedirectEnabled)
    gnb_api.perform_parameter_recommissioning(dist_name=dist_name, parameter="a2MeashoEnabled",
                                              operation="update", value=a2MeashoEnabled)
    gnb_api.perform_parameter_recommissioning(dist_name=dist_name, parameter="a2MeashoEnabledSA",
                                              operation="update", value=a2MeashoEnabledSA)
