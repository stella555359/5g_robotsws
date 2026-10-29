from testsuite.Ulm.ET.L2.libraries.ScfChanges import ScfChanges
import importlib

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

a_meas_profile = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-A.configurations.CB013392_A_profile")
e_meas_profile = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-E.configurations.CB013392_E_profile")

rbi = BuiltIn()


def get_data_for_commissioning(scf_data: str, tdd_cells='11', fdd_cells='2'):
    scf_changes = ScfChanges(scf_data)
    add_changes_for_NRBTS(scf_changes)
    add_changes_for_NRCELLGRP(scf_changes)

    create_and_populate_NRHOIF(scf_changes, tdd_cells, '25', '392650')
    add_changes_for_tdd_NRCELL_config(scf_changes, tdd_cells, "false", "dlOnly")
    add_changes_for_fdd_NRCELL_config(scf_changes, fdd_cells)

    create_NRMEAS_PROFILE(scf_changes)
    create_and_populate_NRMEASPR_IAF(scf_changes, 1)
    create_and_populate_NRMEASPR_IAF(scf_changes, 2)
    add_changes_for_NRDU(scf_changes)
    scf_changes.add_change({"regex": "MRBTS-1/NRBTS-1/NRCELL-[0-9]+",
                            "p_name": "a2MeasSCellRelEnabled",
                            "value": "none"})
    prepare_incoming_handover(scf_changes)

    delete_unnecessary_nrrel_kpi(scf_changes)
    activate_RFSP(scf_changes)
    create_NRMEASPR_MA_SA_KPI(scf_changes)
    create_and_populate_NRMEASPR_IAF_3(scf_changes, 3)
    modify_NRHOIF_for_HO_from_11_TO_1(scf_changes)
    enable_meas_group_in_NRPMRNL(scf_changes)
    create_and_populate_NRCABMCCP(scf_changes)
    change_reporting_interval(scf_changes)
    return scf_changes.get_modifications_for_commissioning()


def add_changes_for_NRBTS(scf_changes_object: ScfChanges):
    regex_nrbts = f"MRBTS-1/NRBTS-1"
    nrbts_changes = {
        "actMeasurementProfile": "SA+NSA",
        "actMeasurementProfReselForCA": "pcInSaUlAndDlCaSupported",
        "actMeasBasedSCellAdditionSa": ["disabled"],
        "sCellActivationMethod": "blind",
        "actMeasBasedSCellAdditionNsa": "false",
        "actInterFreqHoSA": "true",
        "actIntraFreqHoSA": "true",
        "actIntraNrNgHo": "basicTargetOnly",
        "tNgRelocExecDeltN": "3000",
        "suppCnPartialAdNgHo": "false",
        "actCarAgPmCount": "true"
    }
    for p_name, value in nrbts_changes.items():
        scf_changes_object.add_change({"regex": regex_nrbts, "p_name": p_name, "value": value})


def add_changes_for_NRCELLGRP(scf_changes_object: ScfChanges):
    regex_nrcellgrp = "MRBTS-1/NRBTS-1/NRCELLGRP-2"
    scf_changes_object.add_change({"regex": regex_nrcellgrp, "p_name": "numberOfTransmittedSsBlocks",
                                   "value": "1 beam"})
    # TC02
    regex_nrcellgrp = "MRBTS-1/NRBTS-1/NRCELLGRP-3"
    scf_changes_object.add_change({"regex": regex_nrcellgrp, "p_name": "numberOfTransmittedSsBlocks",
                                   "value": "1 beam"})


def create_and_populate_NRHOIF(scf_changes_object: ScfChanges, tdd_cells, ho_to_cell_freq, ho_to_cell_ssbFrequency,
                               is_ho=False):
    regex_nrhoif_tdd = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}/NRHOIF-1"
    scf_changes_object.add_change({"regex": regex_nrhoif_tdd})
    param_dict = {"freqBandIndicatorNR": ho_to_cell_freq,
                  "a3MeasEnabled": "rsrp",
                  "a5MeasEnabled": "rsrp",
                  "ifhoSsbScs": "15KHz",
                  "ifhoSsbSmtcDuration": "sf1",
                  "ifhoSsbSmtcPeriodicity": "sf10",
                  "cellDepType": "SA+NSA",
                  "scs": "15 KHz",
                  "thresholdPCellSwitchTargetRsrp": "80"
                  }
    if not is_ho:
        regex_nrhoif = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}/NRHOIF-[0-9]+"
        scf_changes_object.add_change({"regex": regex_nrhoif, "p_name": "a2BasedPCellSwitchEnabled", "value": "false"})
    else:
        param_dict["a1BasedPCellSwitchEnabled"] = "false"
        param_dict["a2BasedPCellSwitchEnabled"] = "false"
        param_dict["a4MeasEnDcSteeringEnabled"] = "none"
        param_dict["a4MeasHigherPrioFreqEnabled"] = "none"
        param_dict["a4MeasNrDcEnabled"] = "none"
        param_dict["a4MeasSCellAddEnabled"] = "none"
        param_dict["numberOfTransmittedSsBlocks"] = "1 beam"
        param_dict["ssBurstSetPeriod"] = "20"
        param_dict["ssbFrequency"] = ho_to_cell_ssbFrequency
        param_dict["scs"] = "30 KHz"
        param_dict["ifhoSsbScs"] = "30 KHz"
    for p_name, value in param_dict.items():
        scf_changes_object.add_change({"regex": regex_nrhoif_tdd, "p_name": p_name, "value": value})
    a3_a5_lists = {
        "a3MeasSsbRsrp": a_meas_profile.NRHOIF_A3_MEAS_DICT[tdd_cells]["a3MeasSsbRsrp"],
        "a5MeasSsbRsrp": a_meas_profile.NRHOIF_A5_MEAS_DICT[tdd_cells]["a5MeasSsbRsrp"]
    }
    for list_name, list_parameters in a3_a5_lists.items():
        for p_name, value in list_parameters.items():
            scf_changes_object.add_change({"regex":  regex_nrhoif_tdd,  "list_name": list_name,
                                           "p_name": p_name, "value":     value})


def add_changes_for_tdd_NRCELL_config(scf_changes_object: ScfChanges, tdd_cells, increase_pusch="false",
                                      scell_op_mode="dlOnly", measurement_method="rsrp"):
    default_measurements = ["a1MeashoEnabled", "a1MeashoEnabledSA", "a2MeashoEnabled", "a2MeashoEnabledSA",
                            "a2MeasRedirectEnabled", "a2MeasReleaseEnabled", "a2MeasPCellSwitchEnabled",
                            "a3MeasEnabled", "a5MeasEnabled"]
    tdd_nrcell_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}"
    for measurement in default_measurements:
        scf_changes_object.add_change({"regex": tdd_nrcell_regex, "p_name": measurement, "value": measurement_method})
    nr_cell_changes = {
        "actBeamforming": "false",
        "numberOfRxBeamforming": "2Rx",
        "pMaxNROwnCell": "26",
        "prachConfigurationIndex": "97",
        "absThreshSsbRsrqConsolidation": "0",
        "ifhoSsbSmtcOffset": "1",
        "measGapSelection": "balancedChoice",
        "measGapSelectionSA": "balancedChoice",
        "absThreshSsbRsrpConsolidation": "80",
        "sMeasConfigSsbRsrp": "0",
        "sCellDeactivationTimerGNB": "infinity"
    }
    for nr_name, nr_value in nr_cell_changes.items():
        scf_changes_object.add_change({"regex": tdd_nrcell_regex, "p_name": nr_name,
                                       "value": nr_value})
    meas_dict = {
        "a1MeashoSsbRsrp": {
            "a1HysteresishoSsbRsrp": "0",
            "a1ThresholdhoSsbRsrp": "90",
            "a1TimeToTriggerhoSsbRsrp": "ms128"
        },
        "a1MeashoSsbRsrpSA": {
            "a1HysteresishoSsbRsrpSA": "0",
            "a1HysteresisHoSsbRsrpVoNr": "0",
            "a1ThresholdhoSsbRsrpSA": "60",
            "a1ThresholdHoSsbRsrpVoNr": "90",
            "a1TimeToTriggerhoSsbRsrpSA": "ms480",
            "a1TimeToTriggerHoSsbRsrpVoNr": "ms0"
        },
        "a1MeashoSsbRsrqSA": {
            "a1HysteresishoSsbRsrqSA": "0",
            "a1ThresholdhoSsbRsrqSA": "63",
            "a1TimeToTriggerhoSsbRsrqSA": "ms480"
        },
        "a1MeasSCellAddSsbRsrp": {
            "a1HysteresisSCellAddSsbRsrp": "0",
            "a1ThresholdSCellAddSsbRsrpFDD": "90",
            "a1ThresholdSCellAddSsbRsrpTDD": "110",
            "a1TimeToTriggerSCellAddSsbRsrp": "320ms",
        },
        "a2MeashoSsbRsrp": a_meas_profile.A2_MEAS_DICT[tdd_cells]["a2MeashoSsbRsrp"],
        "a2MeashoSsbRsrpSA": {
            "a2HysteresishoSsbRsrpSA": "4",
            "a2HysteresisHoSsbRsrpVoNr": "0",
            "a2ThresholdhoSsbRsrpSA": "37",
            "a2ThresholdHoSsbRsrpVoNr": "80",
            "a2TimeToTriggerhoSsbRsrpSA": "ms0",
            "a2TimeToTriggerHoSsbRsrpVoNr": "ms0"
        },
        "a2MeashoSsbRsrqSA": {
            "a2HysteresishoSsbRsrqSA": "0",
            "a2ThresholdhoSsbRsrqSA": "49",
            "a2TimeToTriggerhoSsbRsrqSA": "ms480"
        },
        "a2MeasRedirectSsbRsrp": {
            "a2HysteresisRedirectSsbRsrp": "6",
            "a2ThresholdRedirectSsbRsrp": "35",
            "a2TimeToTriggerRedirectSsbRsrp": "ms64"
        },
        "a2MeasRedirectSsbRsrq": {
            "a2HysteresisRedirectSsbRsrq": "8",
            "a2ThresholdRedirectSsbRsrq": "50",
            "a2TimeToTriggerRedirectSsbRsrq": "ms80"
        },
        "a2MeasReleaseSsbRsrp": {
            "a2HysteresisReleaseSsbRsrp": "4",
            "a2ThresholdReleaseSsbRsrp": "42",
            "a2TimeToTriggerReleaseSsbRsrp": "ms640"
        },
        "a2MeasPCellSwitchSsbRsrp": a_meas_profile.A2_MEAS_PCELL_SWITCH_DICT[tdd_cells]['a2MeasPCellSwitchSsbRsrp'],
        "a3MeasSsbRsrp": a_meas_profile.A3_MEAS_DICT[tdd_cells]["a3MeasSsbRsrp"],
        "a5MeasSsbRsrp": {
            "a5HysteresisSsbRsrp": "2",
            "a5Threshold1SsbRsrp": "3",
            "a5Threshold2SsbRsrp": "4",
            "a5TimeToTriggerSsbRsrp": "ms480"
        },
        "a5MeasSsbRsrq": {
            "a5HysteresisSsbRsrq": "2",
            "a5Threshold1SsbRsrq": "0",
            "a5Threshold2SsbRsrq": "0",
            "a5TimeToTriggerSsbRsrq": "ms480"
        },
        "beamSet": {
            "basicBeamSet": "beamSet_1",
            "leftEdgeAngle": "60",
            "nrBtsBeamRefinementP2": "false",
            "rightEdgeAngle": "60"
        },
        "tddFrameStructure": {
            "frameStructureType": "tdLte",
            "guardPeriodLength": "6Symbols",
            "lteToNrFrameShift": "0ms",
            "tdLteUlDlConfig": "tdLteConfig2"
        }
    }
    for meas_name, meas_value in meas_dict.items():
        for p_name, value in meas_value.items():
            scf_changes_object.add_change({"regex": tdd_nrcell_regex, "p_name": p_name,
                                           "value": value, "list_name": meas_name})
    if tdd_cells == "11":
        tdd_nrcell_nrrel_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}/NRREL-2"
        scf_changes_object.add_change({"regex": tdd_nrcell_nrrel_regex, "p_name": "sCellAdditionMethod",
                                       "value": "blind"})
        scf_changes_object.add_change({"regex": tdd_nrcell_nrrel_regex, "p_name": "sCellOperationalMode",
                                       "value": scell_op_mode})

    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}",
                                   "p_name": "increasePUSCHPrepTimeULCA",
                                   "value": increase_pusch})


def add_changes_for_fdd_NRCELL_config(scf_changes_object: ScfChanges, fdd_cells, measurement_method="rsrp"):
    regex = f"MRBTS-1/NRBTS-1/NRCELL-{fdd_cells}"
    default_measurements = ["a1MeashoEnabledSA", "a2MeashoEnabledSA", "a2MeasPCellSwitchEnabled",
                            "a2MeasRedirectEnabled", "a2MeasReleaseEnabled"]
    for measurement in default_measurements:
        scf_changes_object.add_change({"regex": regex, "p_name": measurement, "value": measurement_method})

    ssb_dict = {
        "a1MeashoSsbRsrp": {
            "a1HysteresishoSsbRsrp": 0,
            "a1ThresholdhoSsbRsrp": 60,
            "a1TimeToTriggerhoSsbRsrp": "ms480"
        },
        "a1MeashoSsbRsrpSA": {
            "a1HysteresishoSsbRsrpSA": 0,
            "a1ThresholdhoSsbRsrpSA": 60,
            "a1TimeToTriggerhoSsbRsrpSA": "ms480"
        },
        "a1MeashoSsbRsrqSA": {
            "a1HysteresishoSsbRsrqSA": 0,
            "a1ThresholdhoSsbRsrqSA": 63,
            "a1TimeToTriggerhoSsbRsrqSA": "ms480"
        },
        "a2MeashoSsbRsrp": a_meas_profile.A2_MEAS_DICT[fdd_cells]["a2MeashoSsbRsrp"],
        "a2MeashoSsbRsrpSA": {
            "a2HysteresishoSsbRsrpSA": 0,
            "a2ThresholdhoSsbRsrpSA": 34,
            "a2TimeToTriggerhoSsbRsrpSA": "ms480"
        },
        "a2MeashoSsbRsrqSA": {
            "a2HysteresishoSsbRsrqSA": 0,
            "a2ThresholdhoSsbRsrqSA": 49,
            "a2TimeToTriggerhoSsbRsrqSA": "ms480"
        },
        "a2MeasRedirectSsbRsrp": {
            "a2HysteresisRedirectSsbRsrp": "6",
            "a2ThresholdRedirectSsbRsrp": "35",
            "a2TimeToTriggerRedirectSsbRsrp": "ms64"
        },
        "a2MeasRedirectSsbRsrq": {
            "a2HysteresisRedirectSsbRsrq": "8",
            "a2ThresholdRedirectSsbRsrq": "50",
            "a2TimeToTriggerRedirectSsbRsrq": "ms80"
        },
        "a2MeasReleaseSsbRsrp": {
            "a2HysteresisReleaseSsbRsrp": "4",
            "a2ThresholdReleaseSsbRsrp": "42",
            "a2TimeToTriggerReleaseSsbRsrp": "ms640"
        },
        "a2MeasPCellSwitchSsbRsrp": a_meas_profile.A2_MEAS_PCELL_SWITCH_DICT[fdd_cells]['a2MeasPCellSwitchSsbRsrp'],
        "a3MeasSsbRsrp": a_meas_profile.A3_MEAS_DICT[fdd_cells]["a3MeasSsbRsrp"],
        "a5MeasSsbRsrp": {
            "a5HysteresisSsbRsrp": "5",
            "a5Threshold1SsbRsrp": "6",
            "a5Threshold2SsbRsrp": "7",
            "a5TimeToTriggerSsbRsrp": "ms80"
        }
        }
    for ssb_name, ssb_param in ssb_dict.items():
        for p_name, value in ssb_param.items():
            scf_changes_object.add_change({"regex": regex, "list_name": ssb_name,
                                           "p_name": p_name, "value": value})
    scf_changes_object.add_change({"regex": regex, "p_name": "pMaxNROwnCell",
                                   "value": "26"})
    fdd_nrcell_nrrel_regex = f"MRBTS-1/NRBTS-1/NRCELL-{fdd_cells}/NRREL-3"
    scf_changes_object.add_change({"regex": fdd_nrcell_nrrel_regex, "p_name": "sCellOperationalMode",
                                   "value": "dlOnly"})


def create_NRMEAS_PROFILE(scf_changes_object: ScfChanges, profile=1):
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-{profile}"})


def create_and_populate_NRMEASPR_IAF(scf_changes_object: ScfChanges, profile=1):
    regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-{profile}"
    if profile == 1:
        a1_lists = {
            "a1MeashoPrefNRLayerSsbRsrp": {
                "a1HysteresisSsbRsrp": "0",
                "a1ThresholdhoSsbRsrp": "60",
                "a1TimeToTriggerhoSsbRsrp": "ms40"},
            "a1MeashoSsbRsrp": {
                "a1HysteresishoSsbRsrp": "0",
                "a1ThresholdhoSsbRsrp": "60",
                "a1TimeToTriggerhoSsbRsrp": "ms480"}
        }
        a2_lists = {
            "a2MeasRedirectSsbRsrp": {
                "a2HysteresisRedirectSsbRsrp": "2",
                "a2ThresholdRedirectSsbRsrp": "34",
                "a2TimeToTriggerRedirectSsbRsrp": "ms0"}
        }
        all_event_list = [a1_lists, a2_lists, a_meas_profile.B1_IAF_1]
    else:
        a1_lists = {
            "a1MeashoPrefNRLayerSsbRsrp": {
                "a1HysteresisSsbRsrp": "0",
                "a1ThresholdhoSsbRsrp": "60",
                "a1TimeToTriggerhoSsbRsrp": "ms40"},
            "a1MeashoSsbRsrp": {
                "a1HysteresishoSsbRsrp": "1",
                "a1ThresholdhoSsbRsrp": "61",
                "a1TimeToTriggerhoSsbRsrp": "ms64"},
        }
        a2_lists = {
            "a2MeasRedirectSsbRsrp": {
                "a2HysteresisRedirectSsbRsrp": "6",
                "a2ThresholdRedirectSsbRsrp": "35",
                "a2TimeToTriggerRedirectSsbRsrp": "ms64"},
            "a2MeasReleaseSsbRsrp": {
                "a2HysteresisReleaseSsbRsrp": "0",
                "a2ThresholdReleaseSsbRsrp": "34",
                "a2TimeToTriggerReleaseSsbRsrp": "ms480"}
        }
        all_event_list = [a1_lists, a2_lists, a_meas_profile.B1_IAF_2]
    for event_list in all_event_list:
        for list_name, list_parameters in event_list.items():
            for p_name, value in list_parameters.items():
                scf_changes_object.add_change({"regex":  regex,  "list_name": list_name,
                                               "p_name": p_name, "value":     value})


def add_changes_for_NRDU(scf_changes_object: ScfChanges):
    regex_nrdu = "MRBTS-1/NRBTS-1/NRDU-1"
    scf_changes_object.add_change({"regex": regex_nrdu, "p_name": "actNonBfAndBfCa", "value": "true"})
    whole_list = ["ca_Fdd_Fdd",
                  "ca_Fdd_Fr1Tdd_Sa",
                  "ca_Fr1Tdd_Fdd_Sa",
                  "ca_Fr1Tdd_Fdd_Sa_WithUl",
                  "ca_Fdd_Any_Sa",
                  "ca_Fr1Tdd_Sa",
                  "ca_Fdd_Fr1Tdd_Sa_WithUl"
                  ]

    scf_changes_object.add_change({"regex": regex_nrdu, "whole_list": whole_list,
                                   "list_name": "carrierAggregationSupportList"})


def prepare_incoming_handover(scf_changes_object: ScfChanges):
    ho_from_cell = '12'
    ho_to_cell_freq_band = '41'
    ho_to_cell_ssbFrequency = '528750'
    create_and_populate_NRHOIF(scf_changes_object, ho_from_cell, ho_to_cell_freq_band, ho_to_cell_ssbFrequency, True)
    add_changes_for_tdd_NRCELL_config(scf_changes_object, ho_from_cell, increase_pusch="false", scell_op_mode="dlOnly")


def change_reporting_interval(scf_changes_object: ScfChanges):
    rep_interval = rbi.get_variable_value("${pm_reporting_interval}")
    regex_rep_interval = "MRBTS-1/MNL-1/MNLENT-1/PMCADM-1"
    scf_changes_object.add_change({"regex": regex_rep_interval, "p_name": "reportingIntervalPm", "value": rep_interval})


def modify_NRHOIF_for_HO_from_11_TO_1(scf_changes_object: ScfChanges):
    regex_nrhoif_tdd = f"MRBTS-1/NRBTS-1/NRCELL-11/NRHOIF-4"
    param_dict = {"a3MeasEnabled": "rsrp",
                  "a5MeasEnabled": "rsrp",
                  "ifhoSsbSmtcPeriodicity": "sf10",
                  "numberOfTransmittedSsBlocks": "6 beams"
                  }
    for p_name, value in param_dict.items():
        scf_changes_object.add_change({"regex": regex_nrhoif_tdd, "p_name": p_name, "value": value})
    a3_a5_lists = {
        "a3MeasSsbRsrp": a_meas_profile.NRHOIF_A3_MEAS_DICT['11']["a3MeasSsbRsrp"],
        "a5MeasSsbRsrp": a_meas_profile.NRHOIF_A5_MEAS_DICT['11']["a5MeasSsbRsrp"]
    }
    for list_name, list_parameters in a3_a5_lists.items():
        for p_name, value in list_parameters.items():
            scf_changes_object.add_change({"regex":  regex_nrhoif_tdd,  "list_name": list_name,
                                           "p_name": p_name, "value":     value})


def delete_unnecessary_nrrel_kpi(scf_changes_object: ScfChanges):
    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1', 'operation': 'delete'})
    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2', 'operation': 'delete'})
    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3', 'operation': 'delete'})
    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-1/NRREL-4', 'operation': 'delete'})

    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-2/NRREL-1', 'operation': 'delete'})
    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-2/NRREL-2', 'operation': 'delete'})
    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-2/NRREL-4', 'operation': 'delete'})

    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-3/NRREL-1', 'operation': 'delete'})
    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-3/NRREL-2', 'operation': 'delete'})
    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-3/NRREL-3', 'operation': 'delete'})
    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-3/NRREL-4', 'operation': 'delete'})

    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-11/NRREL-3', 'operation': 'delete'})
    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-11/NRREL-4', 'operation': 'delete'})

    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-12/NRREL-1', 'operation': 'delete'})
    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-12/NRREL-2', 'operation': 'delete'})
    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-12/NRREL-3', 'operation': 'delete'})


def activate_RFSP(scf_changes_object: ScfChanges):
    regex_nrbts = f"MRBTS-1/NRBTS-1"
    scf_changes_object.add_change({"regex": regex_nrbts, "p_name": "actRfspIndex", "value": "true"})
    scf_changes_object.add_change({"regex": regex_nrbts, "p_name": "actLatencyPmCount", "value": "true"})


def create_NRMEASPR_MA_SA_KPI(scf_changes_object: ScfChanges):
    # Profile 1
    meas_prof_ma_sa_regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1"
    meas_profile_param_list = {"nrMeasPrIafDN": f"NRMEASPR_IAF-1"}
    for p_name, value in meas_profile_param_list.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_sa_regex, "p_name": p_name, "value": value})

    pcCapabilityList = {
        "uePowerClass": "ue-PowerClass2",
        "freqBandIndicatorNR": "41"
    }
    for p_name, value in pcCapabilityList.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_sa_regex, "list_name": "pcCapabilityList",
                                       "p_name": p_name, "value": value})

    # Profile 2
    meas_prof_ma_sa_regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2"
    meas_profile_param_list = {"nrMeasPrIafDN": f"NRMEASPR_IAF-2",
                               "rfspIndex": e_meas_profile.RFSP_PRIO_GNB_MEASPR[2]
                               }
    for p_name, value in meas_profile_param_list.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_sa_regex, "p_name": p_name, "value": value})

    pcCapabilityList = {
        "uePowerClass": "ue-PowerClass3",
        "freqBandIndicatorNR": "41"
    }
    for p_name, value in pcCapabilityList.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_sa_regex, "list_name": "pcCapabilityList",
                                       "p_name": p_name, "value": value})

    # Profile 3
    meas_prof_ma_sa_regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-3"
    meas_profile_param_list = {"nrMeasPrIafDN": f"NRMEASPR_IAF-3",
                               "rfspIndex": e_meas_profile.RFSP_PRIO_GNB_MEASPR[3]}
    for p_name, value in meas_profile_param_list.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_sa_regex, "p_name": p_name, "value": value})

    pcCapabilityList = {
        "uePowerClass": "ue-PowerClass3",
        "freqBandIndicatorNR": "41"
    }
    for p_name, value in pcCapabilityList.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_sa_regex, "list_name": "pcCapabilityList",
                                       "p_name": p_name, "value": value})

    # Profile priorities
    scf_changes_object.add_change({
        "regex": "MRBTS-1/NRBTS-1/NRCELL-[0-9]+",
        "list_name": "measPrMaSAList",
        "whole_list": [
            {"measPrPriority": 5,
             "nrMeasPrMaSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1"},
            {"measPrPriority": 10,
             "nrMeasPrMaSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2"},
            {"measPrPriority": 20,
             "nrMeasPrMaSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-3"}]})


def create_and_populate_NRMEASPR_IAF_3(scf_changes_object: ScfChanges, profile):

    regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-{profile}"
    a1_lists = {
        "a1MeashoPrefNRLayerSsbRsrp": {
            "a1HysteresisSsbRsrp": "0",
            "a1ThresholdhoSsbRsrp": "60",
            "a1TimeToTriggerhoSsbRsrp": "ms40"},
        "a1MeashoSsbRsrp": {
            "a1HysteresishoSsbRsrp": "0",
            "a1ThresholdhoSsbRsrp": "60",
            "a1TimeToTriggerhoSsbRsrp": "ms480"}
    }
    a2_lists = {
        "a2MeasRedirectSsbRsrp": {
            "a2HysteresisRedirectSsbRsrp": "2",
            "a2ThresholdRedirectSsbRsrp": "34",
            "a2TimeToTriggerRedirectSsbRsrp": "ms0"}
    }
    all_event_list = [a1_lists, a2_lists, e_meas_profile.E1_IAF_3]
    for event_list in all_event_list:
        for list_name, list_parameters in event_list.items():
            for p_name, value in list_parameters.items():
                scf_changes_object.add_change({"regex":  regex,  "list_name": list_name,
                                               "p_name": p_name, "value":     value})


def create_and_populate_NRCABMCCP(scf_changes_object: ScfChanges):
    # required for miNrCABMCCP="5min"
    nrcabmccp_regex = f"MRBTS-1/NRBTS-1/NRPMRNL-1/NRCABMCCP-1"
    scf_changes_object.add_change({"regex": nrcabmccp_regex})
    freqBandNr_list = {
        "caBandwidthClassDlNr": "A",
        "caBandwidthClassUlNr": "A",
        "freqBandIndicatorNr": "41"
    }
    for p_name, value in freqBandNr_list.items():
        scf_changes_object.add_change({"regex": nrcabmccp_regex, "list_name": "freqBandNr",
                                       "p_name": p_name, "value": value})
    scf_changes_object.add_change({"regex": nrcabmccp_regex, "p_name": "ueConType", "value": "SA or NSA"})


def enable_meas_group_in_NRPMRNL(scf_changes_object):
    regex_nrpmrnl = f"MRBTS-1/NRBTS-1/NRPMRNL-1"
    interval = rbi.get_variable_value("${pm_reporting_interval}")
    nrpmrnl_changes = [
        "miNrAngDistribution",
        "miNrBeamforming",
        "miNrBeamforming2",
        "miNrBfConfig",
        "miNrBrc",
        "miNrCABMCCP",
        "miNrCCD",
        "miNrCUCM",
        "miNrCaCu",
        "miNrCaDu",
        "miNrCaDu01",
        "miNrCaDuCp",
        "miNrCellAvailPosCell",
        "miNrCellAvailability",
        "miNrCellGroupMeas",
        "miNrCellUtilPerNrg",
        "miNrCellUtilPerPLMN",
        "miNrCellUtilization",
        "miNrDlHarq",
        "miNrDlHarqLowSEMCS",
        "miNrDlSignalQuality",
        "miNrDlSignalQuality2",
        "miNrE1InterfaceBts",
        "miNrE1InterfaceCell",
        "miNrE1InterfaceCuCpNsa",
        "miNrE1InterfaceCuCpSa",
        "miNrE1InterfaceCuUp",
        "miNrE1InterfaceCuUpNsa",
        "miNrE1InterfaceCuUpSa",
        "miNrE2InterfaceBts",
        "miNrE2SubscriptionBts",
        "miNrEcpriUpFCp",
        "miNrEirp",
        "miNrEnDssPerCell",
        "miNrF1CC",
        "miNrF1CD",
        "miNrF1UB1Interface",
        "miNrF1UCInterface",
        "miNrF1UDInterface",
        "miNrF1UInterfaceCUpmqap",
        "miNrF1UInterfaceDUPmqap",
        "miNrF1UU",
        "miNrGnss",
        "miNrHighRlcCell",
        "miNrHighRlcCellNrpmqap",
        "miNrHighRlcLatNrpmqap",
        "miNrHighRlcReport",
        "miNrHoInterruptCuUp",
        "miNrIfPsCellChange",
        "miNrInterGnbMobilityCellCuNsa",
        "miNrInterGnbMobilityCellCuSa",
        "miNrInterGnbMobilityNsaPmqap",
        "miNrInterGnbNgMobilitySaPmqap",
        "miNrInterGnbXnMobilitySaPmqap",
        "miNrInterRATMobilitySaPmqap",
        "miNrIntraGnbMobilityCellCuSa",
        "miNrIntraGnbMobilityNsaPmqap",
        "miNrIntraGnbMobilitySaPmqap",
        "miNrL2HiCUBearerpmqap",
        "miNrLowRlcCellNrpmqap",
        "miNrLowRlcReport",
        "miNrLteMgPerCell",
        "miNrLteMobilityReport",
        "miNrMLInferEngDu",
        "miNrMLManServDu",
        "miNrMacPduTput",
        "miNrMacSduReport",
        "miNrMaxCABMCCP",
        "miNrMaxCellCuNrpmqap",
        "miNrMeasProfileInterFreq",
        "miNrMeasProfileInterRat",
        "miNrMeasProfileIntraFreq",
        "miNrMeasProfileMappingNSA",
        "miNrMeasProfileMappingSA",
        "miNrMeasProfileSCell",
        "miNrMgPerCell",
        "miNrMobilityReport",
        "miNrMobilityReportCu",
        "miNrMobilityReportDu",
        "miNrNAECL",
        "miNrNGCC",
        "miNrNREMO",
        "miNrNRMOP",
        "miNrNRPFW",
        "miNrNTRAF",
        "miNrNeighborLteNrCuNsa",
        "miNrNeighborNrNrCuNsa",
        "miNrNeighborNrNrCuSa",
        "miNrNgInterface",
        "miNrNgInterfaceNrpmqap",
        "miNrNgUReport",
        "miNrNgcFlexInterface",
        "miNrNsaAcCuNrpmqap",
        "miNrPDCP1Report",
        "miNrPDCP2Report",
        "miNrPDCPCell",
        "miNrPRBthroughputpmqap",
        "miNrPaging",
        "miNrPagingStrategy",
        "miNrPdcch",
        "miNrPdcch2",
        "miNrPdcpC",
        "miNrPdcpCellNrpmqap",
        "miNrPdcpLatNrpmqap",
        "miNrPowerSavingBwp",
        "miNrPsCellChange",
        "miNrRANS",
        "miNrRANSPeakUE",
        "miNrRRCC",
        "miNrRRCD",
        "miNrRSACU",
        "miNrRSADU",
        "miNrRSANB",
        "miNrRSUP",
        "miNrRacCu",
        "miNrRacDu",
        "miNrRachUsage",
        "miNrRadBearer",
        "miNrRadQualpmqap",
        "miNrRelReportCu",
        "miNrResourceUtilizationPerCell",
        "miNrRim",
        "miNrRip",
        "miNrRipSample",
        "miNrRlfPerCell",
        "miNrRtwp",
        "miNrS1UInterface",
        "miNrSSBPM",
        "miNrSaAcDuNrpmqap",
        "miNrSaAdjGnb",
        "miNrSaCuNrpmqap",
        "miNrSignalQualityLowSEMCS",
        "miNrSlicingCuCp",
        "miNrSlicingCuUp",
        "miNrSpareBts",
        "miNrSpareCellCU",
        "miNrSpareCellCUPlmn",
        "miNrSpareCellDU",
        "miNrSpareCellDUPlmn",
        "miNrSrb3C",
        "miNrSrb3D",
        "miNrSrsQuality",
        "miNrSrvcAvaStats",
        "miNrStreamMeasure",
        "miNrTimingAdvance",
        "miNrUeQuan",
        "miNrUeStatNrpmqap",
        "miNrUeState",
        "miNrUlHarq",
        "miNrUlHarqLowSEMCS",
        "miNrUlHarqOne",
        "miNrUlSignalQuality",
        "miNrUlSignalQuality2",
        "miNrX2CB",
        "miNrX2CC",
        "miNrX2UB1Interface",
        "miNrX2UInterface",
        "miNrX2UInterfacepmqap",
        "miNrX2ccNrpmqap",
        "miNrXNUInterfaceCUBts",
        "miNrXNUInterfaceCUPmqap",
        "miNrXNUInterfaceDUPmqap",
        "miNrXnCCInterface",
        "miNrXnInterface"
        ]
    for p_name in nrpmrnl_changes:
        scf_changes_object.add_change({"regex": regex_nrpmrnl, "p_name": p_name, "value": interval})
