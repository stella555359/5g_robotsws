from testsuite.Ulm.ET.L2.libraries.ScfChanges import ScfChanges
import logging
import importlib

c_meas_profile = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-C.configurations.CB013392_C_profile_AEQE")


def get_data_for_commissioning(scf_data: str, tdd_cells='', fdd_cells=''):
    scf_changes = ScfChanges(scf_data)
    # -------------------------------------------------------------------------------------------------[120 characters]
    add_changes_for_NRBTS(scf_changes)
    add_changes_for_tdd_NRCELL_config(scf_changes, tdd_cell="1", measurement_method="rsrp")
    add_changes_for_tdd_NRCELL_config(scf_changes, tdd_cell="2", measurement_method="rsrq")
    add_changes_for_fdd_NRCELL_config(scf_changes, fdd_cell="3", measurement_method="none")
    add_changes_for_fdd_NRCELL_config(scf_changes, fdd_cell="4", measurement_method="none")
    create_and_populate_NRMEASPR_IAF(scf_changes, profile=1)
    create_and_populate_NRMEASPR_IAF(scf_changes, profile=2)
    create_NRMEASPR_MA_NSA(scf_changes, freq="78")
    create_and_populate_NRMEASPR_IEF(scf_changes, profile=1)
    create_and_populate_NRMEASPR_IEF(scf_changes, profile=2)
    create_and_populate_NRHOIF(scf_changes, tdd_cell="1", ssbFrequency="647616")
    create_and_populate_NRHOIF(scf_changes, tdd_cell="2", ssbFrequency="636576")
    # -------------------------------------------------------------------------------------------------[120 characters]
    return scf_changes.get_modifications_for_commissioning()


def other_cell_changes(scf_changes_object: ScfChanges):
    regex = "MRBTS-1/NRBTS-1/NRCELL-[0-9]+"
    a2MeasReleaseSsbRsrp_dict = {"a2HysteresisReleaseSsbRsrp": "6",
                                 "a2ThresholdReleaseSsbRsrp": "27",
                                 "a2TimeToTriggerReleaseSsbRsrp": "ms480"}
    for p_name, value in a2MeasReleaseSsbRsrp_dict.items():
        scf_changes_object.add_change({"regex": regex, "list_name": "a2MeasReleaseSsbRsrp",
                                       "p_name": p_name, "value": value})


def add_changes_for_NRBTS(scf_changes_object: ScfChanges):
    regex_nrbts = "MRBTS-1/NRBTS-1"
    nrbts_changes = {
        "actMeasProfPowerCoordNSA": "activated",
        "actA2SgnbRelease": "true",
        "actInterFreqInterGnbMobilityNSA": "true",
        "actInterFreqIntraGnbMobilityNSA": "true",
        "actIntraFreqInterGnbMobilityNSA3x": "true",
        "actIntraFreqIntraGnbMobilityNSA": "true",
        "actIntraMeNBMobility": "true",
        "actMeasurementProfile": "SA+NSA"
    }
    for p_name, value in nrbts_changes.items():
        scf_changes_object.add_change({"regex": regex_nrbts, "p_name": p_name, "value": value})


def add_changes_for_NRCELLGRP(scf_changes_object: ScfChanges):
    regex_nrcellgrp = "MRBTS-1/NRBTS-1/NRCELLGRP-2"
    scf_changes_object.add_change({"regex": regex_nrcellgrp, "p_name": "numberOfTransmittedSsBlocks",
                                   "value": "1 beam"})
    regex_nrcellgrp = "MRBTS-1/NRBTS-1/NRCELLGRP-3"
    scf_changes_object.add_change({"regex": regex_nrcellgrp, "p_name": "numberOfTransmittedSsBlocks",
                                   "value": "1 beam"})


def create_and_populate_NRHOIF(scf_changes_object: ScfChanges, tdd_cell, freqBandIndicatorNR="78",
                               ssbFrequency="636576"):
    regex_nrhoif_tdd = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cell}/NRHOIF-1"
    scf_changes_object.add_change({"regex": regex_nrhoif_tdd})
    # -------------------------------------------------------------------------------------------------[120 characters]
    param_dict = {"a1BasedPCellSwitchEnabled": "false",
                  "a2BasedPCellSwitchEnabled": "false",
                  "a3MeasEnabled": "rsrp",
                  "a4MeasEnDcSteeringEnabled": "none",
                  "a4MeasHigherPrioFreqEnabled": "none",
                  "a4MeasNrDcEnabled": "none",
                  "a4MeasSCellAddEnabled": "none",
                  "a5MeasEnabled": "rsrp",
                  "cellDepType": "SA+NSA",
                  "deriveSsbIndexFromCell": "true",
                  "freqBandIndicatorNR": freqBandIndicatorNR,
                  "ifhoSsbScs": "30 KHz",
                  "ifhoSsbSmtcDuration": "sf5",
                  "ifhoSsbSmtcPeriodicity": "sf20",
                  "numberOfTransmittedSsBlocks": "1 beam",
                  "scs": "30 KHz",
                  "ssBurstSetPeriod": "10",
                  "ssbFrequency": ssbFrequency}
    for p_name, value in param_dict.items():
        scf_changes_object.add_change({"regex": regex_nrhoif_tdd, "p_name": p_name, "value": value})
    # -------------------------------------------------------------------------------------------------[120 characters]
    a3_a5_lists = {"a3MeasSsbRsrp": c_meas_profile.C_B8_NRHOIF_A3_MEAS_DICT["a3MeasSsbRsrp"],
                   "a3MeasSsbRsrq": c_meas_profile.C_B8_NRHOIF_A3_MEAS_DICT["a3MeasSsbRsrq"],
                   "a5MeasSsbRsrp": c_meas_profile.C_B8_NRHOIF_A5_MEAS_DICT["a5MeasSsbRsrp"],
                   "a5MeasSsbRsrq": c_meas_profile.C_B8_NRHOIF_A5_MEAS_DICT["a5MeasSsbRsrq"]}
    for list_name, list_parameters in a3_a5_lists.items():
        for p_name, value in list_parameters.items():
            scf_changes_object.add_change({"regex": regex_nrhoif_tdd,
                                           "list_name": list_name,
                                           "p_name": p_name,
                                           "value": value})


def create_and_populate_NRMEASPR_IEF(scf_changes_object: ScfChanges, profile=1):
    regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IEF-{profile}"
    if profile == 1:
        event_list = c_meas_profile.C_B8_IEF_1
    else:
        event_list = c_meas_profile.C_B8_IEF_2
    for list_name, list_parameters in event_list.items():
        for p_name, value in list_parameters.items():
            scf_changes_object.add_change({"regex": regex,
                                           "list_name": list_name,
                                           "p_name": p_name,
                                           "value": value})


def create_and_populate_NRMEASPR_IAF(scf_changes_object: ScfChanges, profile=1):
    regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-{profile}"
    if profile == 1:
        event_list = c_meas_profile.C_B8_IAF_1
    else:
        event_list = c_meas_profile.C_B8_IAF_2
    for list_name, list_parameters in event_list.items():
        for p_name, value in list_parameters.items():
            scf_changes_object.add_change({"regex": regex,
                                           "list_name": list_name,
                                           "p_name": p_name,
                                           "value": value})


def create_NRMEASPR_MA_NSA(scf_changes_object: ScfChanges, freq="78"):
    # Profile 1 ---------------------------------------------------------------------------------------[120 characters]
    meas_prof_ma_nsa_regex = "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1"
    meas_profile_param_list = {"nrMeasPrIafDN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-1"}
    for p_name, value in meas_profile_param_list.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_nsa_regex, "p_name": p_name, "value": value})
    pcCapabilityList = {"uePowerClass": "ue-PowerClass2",
                        "freqBandIndicatorNR": freq}
    for p_name, value in pcCapabilityList.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_nsa_regex, "list_name": "pcCapabilityList",
                                       "p_name": p_name, "value": value})
    # Profile 2 ---------------------------------------------------------------------------------------[120 characters]
    meas_prof_ma_nsa_regex = "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2"
    meas_profile_param_list = {"nrMeasPrIafDN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-2"}
    for p_name, value in meas_profile_param_list.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_nsa_regex, "p_name": p_name, "value": value})
    pcCapabilityList = {"uePowerClass": "ue-PowerClass3",
                        "freqBandIndicatorNR": freq}
    for p_name, value in pcCapabilityList.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_nsa_regex, "list_name": "pcCapabilityList",
                                       "p_name": p_name, "value": value})
    # Profile priorities: Cell 1 ----------------------------------------------------------------------[120 characters]
    scf_changes_object.add_change({
        "regex": "MRBTS-1/NRBTS-1/NRCELL-1",
        "list_name": "measPrMaNSAList",
        "whole_list": [
            {"measPrPriority": 10, "nrMeasPrMaNSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1"},
            {"measPrPriority": 20, "nrMeasPrMaNSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2"}]})
    # Profile priorities: Cell 2 ----------------------------------------------------------------------[120 characters]
    scf_changes_object.add_change({
        "regex": "MRBTS-1/NRBTS-1/NRCELL-2",
        "list_name": "measPrMaNSAList",
        "whole_list": [
            {"measPrPriority": 10, "nrMeasPrMaNSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1"},
            {"measPrPriority": 20, "nrMeasPrMaNSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2"}]})


def delete_unnecessary_NRREL(scf_changes_object: ScfChanges):
    nrrel_to_be_deleted = ['MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1',
                           'MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2',
                           'MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3',
                           'MRBTS-1/NRBTS-1/NRCELL-1/NRREL-4',
                           'MRBTS-1/NRBTS-1/NRCELL-2/NRREL-1',
                           'MRBTS-1/NRBTS-1/NRCELL-2/NRREL-2',
                           'MRBTS-1/NRBTS-1/NRCELL-2/NRREL-4',
                           'MRBTS-1/NRBTS-1/NRCELL-3/NRREL-1',
                           'MRBTS-1/NRBTS-1/NRCELL-3/NRREL-2',
                           'MRBTS-1/NRBTS-1/NRCELL-3/NRREL-3',
                           'MRBTS-1/NRBTS-1/NRCELL-3/NRREL-4',
                           'MRBTS-1/NRBTS-1/NRCELL-4/NRREL-1',
                           'MRBTS-1/NRBTS-1/NRCELL-4/NRREL-3',
                           'MRBTS-1/NRBTS-1/NRCELL-4/NRREL-1',
                           'MRBTS-1/NRBTS-1/NRCELL-4/NRREL-2',
                           'MRBTS-1/NRBTS-1/NRCELL-4/NRREL-3'
                           ]
    for nrrel_regex in nrrel_to_be_deleted:
        scf_changes_object.add_change({'regex': nrrel_regex, 'operation': 'delete'})


def create_NRMEAS_PROFILE(scf_changes_object: ScfChanges, profile=1):
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-{profile}"})


def add_changes_for_tdd_NRCELL_config(scf_changes_object: ScfChanges, tdd_cell, measurement_method="rsrp"):
    default_measurements = ["a1MeashoEnabled", "a2MeashoEnabled",
                            "a2MeasReleaseEnabled",
                            "a3MeasEnabled", "a5MeasEnabled"]
    nrcell_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cell}"
    for measurement in default_measurements:
        if measurement_method == "rsrp" and (measurement == "a1MeashoEnabled" or measurement == "a2MeashoEnabled"):
            temp_measurement_method = "rsrpCombined"
        else:
            temp_measurement_method = measurement_method
        scf_changes_object.add_change({"regex": nrcell_regex,
                                       "p_name": measurement,
                                       "value": temp_measurement_method})
    # -------------------------------------------------------------------------------------------------[120 characters]
    nr_cell_changes = {
        "pMaxNROwnCell": "26",
        "absThreshSsbRsrpConsolidation": "1",
        "absThreshSsbRsrqConsolidation": "1",
        "measGapSelectionSA": "favourUeThroughput",
        "sMeasConfigSsbRsrp": "1"
    }
    for nr_name, nr_value in nr_cell_changes.items():
        scf_changes_object.add_change({"regex": nrcell_regex,
                                       "p_name": nr_name,
                                       "value": nr_value})
    # -------------------------------------------------------------------------------------------------[120 characters]
    meas_dict = {
        "a2MeasReleaseSsbRsrp": {
            "a2HysteresisReleaseSsbRsrp": "0",
            "a2ThresholdReleaseSsbRsrp": "24",
            "a2TimeToTriggerReleaseSsbRsrp": "ms480"
        },
        "a2MeasReleaseSsbRsrq": {
            "a2HysteresisReleaseSsbRsrq": "0",
            "a2ThresholdReleaseSsbRsrq": "23",
            "a2TimeToTriggerReleaseSsbRsrq": "ms480"
        },
        "a3MeasSsbRsrp": {
            "a3HysteresisSsbRsrp": "0",
            "a3OffsetSsbRsrp": "0",
            "a3TimeToTriggerSsbRsrp": "ms320"
        },
        "a3MeasSsbRsrq": {
            "a3HysteresisSsbRsrq": "0",
            "a3OffsetSsbRsrq": "0",
            "a3TimeToTriggerSsbRsrq": "ms320"
        },
        "a5MeasSsbRsrp": {
            "a5HysteresisSsbRsrp": "0",
            "a5Threshold1SsbRsrp": "82",
            "a5Threshold2SsbRsrp": "87",
            "a5TimeToTriggerSsbRsrp": "ms100"
        },
        "a5MeasSsbRsrq": {
            "a5HysteresisSsbRsrq": "0",
            "a5Threshold1SsbRsrq": "82",
            "a5Threshold2SsbRsrq": "87",
            "a5TimeToTriggerSsbRsrq": "ms100"
        }
    }
    for meas_name, meas_value in meas_dict.items():
        for p_name, value in meas_value.items():
            scf_changes_object.add_change({"regex": nrcell_regex,
                                           "p_name": p_name,
                                           "value": value,
                                           "list_name": meas_name})


def add_changes_for_fdd_NRCELL_config(scf_changes_object: ScfChanges, fdd_cell, measurement_method="rsrp"):
    default_measurements = ["a2MeasReleaseEnabled"]
    nrcell_regex = f"MRBTS-1/NRBTS-1/NRCELL-{fdd_cell}"
    for measurement in default_measurements:
        scf_changes_object.add_change({"regex": nrcell_regex,
                                       "p_name": measurement,
                                       "value": measurement_method})
