from testsuite.Ulm.ET.L2.libraries.ScfChanges import ScfChanges
import logging
import importlib

c_meas_profile = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-C.configurations.CB013392_C_profile")


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
    create_NRMEASPR_MA_NSA(scf_changes)
    create_and_populate_NRMEASPR_IEF(scf_changes, 1)
    create_and_populate_NRMEASPR_IEF(scf_changes, 2)
    delete_unnecessary_NRREL(scf_changes)
    add_changes_for_NRDU(scf_changes)
    other_cell_changes(scf_changes)
    scf_changes.add_change({"regex": "MRBTS-1/NRBTS-1/NRCELL-[0-9]+",
                            "p_name": "a2MeasSCellRelEnabled",
                            "value": "none"})
    prepare_incoming_handover(scf_changes)  # for C#B2 and to avoid relation errors
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
        "actMeasurementProfile": "SA+NSA",
        "actInterFreqIntraGnbMobilityNSA": "true",
        "actIntraFreqIntraGnbMobilityNSA": "true",
        # "actMeasurementProfReselForCA": "pcInSaUlAndDlCaSupported",
        "actMeasBasedSCellAdditionSa": ["disabled"],
        "sCellActivationMethod": "blind",
        "actMeasBasedSCellAdditionNsa": "false",
        "actInterFreqHoSA": "true",
        "actIntraFreqHoSA": "true",
        "actIntraNrNgHo": "basicTargetOnly",
        "tNgRelocExecDeltN": "3000",
        "suppCnPartialAdNgHo": "false",
        "actCarAgPmCount": "true",
        "actMeasProfPowerCoordNSA": "activated",
        "actA2SgnbRelease": "true"
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

        regex_other = "MRBTS-1/NRBTS-1/NRCELL-11/NRHOIF-[2-4]"
        scf_changes_object.add_change({"regex": regex_other, "p_name": "a2BasedPCellSwitchEnabled", "value": "false"})

    for p_name, value in param_dict.items():
        scf_changes_object.add_change({"regex": regex_nrhoif_tdd, "p_name": p_name, "value": value})

    a3_a5_lists = {
        "a3MeasSsbRsrp": c_meas_profile.NRHOIF_A3_MEAS_DICT[tdd_cells]["a3MeasSsbRsrp"],
        "a5MeasSsbRsrp": c_meas_profile.NRHOIF_A5_MEAS_DICT[tdd_cells]["a5MeasSsbRsrp"]
    }
    for list_name, list_parameters in a3_a5_lists.items():
        for p_name, value in list_parameters.items():
            scf_changes_object.add_change({"regex":  regex_nrhoif_tdd,  "list_name": list_name,
                                           "p_name": p_name, "value":     value})


def create_and_populate_NRMEASPR_IEF(scf_changes_object: ScfChanges, profile=1):
    regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IEF-{profile}"
    if profile == 1:
        event_list = c_meas_profile.IEF_1
    else:
        event_list = c_meas_profile.IEF_2
    for list_name, list_parameters in event_list.items():
        for p_name, value in list_parameters.items():
            scf_changes_object.add_change({"regex": regex, "list_name": list_name,
                                           "p_name": p_name, "value": value})


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
        all_event_list = [a1_lists, a2_lists, c_meas_profile.B1_IAF_1]
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
                "a2TimeToTriggerRedirectSsbRsrp": "ms64"}
        }
        all_event_list = [a1_lists, a2_lists, c_meas_profile.B1_IAF_2]
    for event_list in all_event_list:
        for list_name, list_parameters in event_list.items():
            for p_name, value in list_parameters.items():
                scf_changes_object.add_change({"regex":  regex,  "list_name": list_name,
                                               "p_name": p_name, "value":     value})


def create_NRMEASPR_MA_NSA(scf_changes_object: ScfChanges, freq="41", cell="11"):
    # Profile 1
    meas_prof_ma_nsa_regex = "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1"
    meas_profile_param_list = {"nrMeasPrIafDN": "NRMEASPR_IAF-1",
                               "nrMeasPrIefDefaultDN": "NRMEASPR_IEF-1"}
    for p_name, value in meas_profile_param_list.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_nsa_regex, "p_name": p_name, "value": value})

    pcCapabilityList = {
        "uePowerClass": "ue-PowerClass2",
        "freqBandIndicatorNR": freq
    }
    for p_name, value in pcCapabilityList.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_nsa_regex, "list_name": "pcCapabilityList",
                                       "p_name": p_name, "value": value})

    # Profile 2
    meas_prof_ma_nsa_regex = "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2"
    meas_profile_param_list = {"nrMeasPrIafDN": "NRMEASPR_IAF-2",
                               "nrMeasPrIefDefaultDN": "NRMEASPR_IEF-2"}
    for p_name, value in meas_profile_param_list.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_nsa_regex, "p_name": p_name, "value": value})

    pcCapabilityList = {
        "uePowerClass": "ue-PowerClass3",
        "freqBandIndicatorNR": freq
    }
    for p_name, value in pcCapabilityList.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_nsa_regex, "list_name": "pcCapabilityList",
                                       "p_name": p_name, "value": value})

    # Profile priorities
    scf_changes_object.add_change({
        "regex": f"MRBTS-1/NRBTS-1/NRCELL-{cell}",
        "list_name": "measPrMaNSAList",
        "whole_list": [
            {"measPrPriority": 10,
             "nrMeasPrMaNSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1"},
            {"measPrPriority": 20,
             "nrMeasPrMaNSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2"}]})


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
                           'MRBTS-1/NRBTS-1/NRCELL-11/NRREL-1',
                           'MRBTS-1/NRBTS-1/NRCELL-11/NRREL-3',
                           'MRBTS-1/NRBTS-1/NRCELL-12/NRREL-1',
                           'MRBTS-1/NRBTS-1/NRCELL-12/NRREL-2',
                           'MRBTS-1/NRBTS-1/NRCELL-12/NRREL-3'
                           ]
    for nrrel_regex in nrrel_to_be_deleted:
        scf_changes_object.add_change({'regex': nrrel_regex, 'operation': 'delete'})


def create_NRMEAS_PROFILE(scf_changes_object: ScfChanges, profile=1):
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-{profile}"})


def add_changes_for_tdd_NRCELL_config(scf_changes_object: ScfChanges, tdd_cells, increase_pusch="false",
                                      scell_op_mode="dlOnly", measurement_method="rsrp"):
    default_measurements = ["a1MeashoEnabled", "a2MeashoEnabled",
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
        "sCellDeactivationTimerGNB": "infinity",
        "enDcSyncStatus": "synchronous"
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
        "a1MeasSCellAddSsbRsrp": {
            "a1HysteresisSCellAddSsbRsrp": "0",
            "a1ThresholdSCellAddSsbRsrpFDD": "90",
            "a1ThresholdSCellAddSsbRsrpTDD": "110",
            "a1TimeToTriggerSCellAddSsbRsrp": "320ms",
        },
        "a2MeashoSsbRsrp": c_meas_profile.A2_MEAS_DICT[tdd_cells]["a2MeashoSsbRsrp"],
        "a2MeasRedirectSsbRsrp": {
            "a2HysteresisRedirectSsbRsrp": "6",
            "a2ThresholdRedirectSsbRsrp": "35",
            "a2TimeToTriggerRedirectSsbRsrp": "ms64"
        },
        "a2MeasPCellSwitchSsbRsrp": c_meas_profile.A2_MEAS_PCELL_SWITCH_DICT[tdd_cells]['a2MeasPCellSwitchSsbRsrp'],
        "a3MeasSsbRsrp": c_meas_profile.A3_MEAS_DICT[tdd_cells]["a3MeasSsbRsrp"],
        "a5MeasSsbRsrp": {
            "a5HysteresisSsbRsrp": "2",
            "a5Threshold1SsbRsrp": "3",
            "a5Threshold2SsbRsrp": "4",
            "a5TimeToTriggerSsbRsrp": "ms480"
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
    scf_changes_object.add_change({"regex": "MRBTS-1/NRBTS-1/NRCELL-12",
                                   "p_name": "increasePUSCHPrepTimeULCA",
                                   "value": 'false'})
    scf_changes_object.add_change({"regex": "MRBTS-1/NRBTS-1/NRCELL-12", "p_name": "guardPeriodLength",
                                   "value": "6Symbols", "list_name": "tddFrameStructure"})


def add_changes_for_fdd_NRCELL_config(scf_changes_object: ScfChanges, fdd_cells, measurement_method="rsrp"):
    # For fixing relation errors in cell 1 and 3
    regex = f"MRBTS-1/NRBTS-1/NRCELL-[13]"
    default_measurements = ["a2MeasReleaseEnabled"]
    for measurement in default_measurements:
        scf_changes_object.add_change({"regex": regex, "p_name": measurement, "value": "none"})

    # For test cases
    regex = f"MRBTS-1/NRBTS-1/NRCELL-{fdd_cells}"
    default_measurements = ["a2MeasPCellSwitchEnabled",
                            "a2MeasRedirectEnabled", "a2MeasReleaseEnabled"]
    for measurement in default_measurements:
        scf_changes_object.add_change({"regex": regex, "p_name": measurement, "value": measurement_method})

    ssb_dict = {
        "a1MeashoSsbRsrp": {
            "a1HysteresishoSsbRsrp": 0,
            "a1ThresholdhoSsbRsrp": 60,
            "a1TimeToTriggerhoSsbRsrp": "ms480"
        },
        "a2MeashoSsbRsrp": c_meas_profile.A2_MEAS_DICT[fdd_cells]["a2MeashoSsbRsrp"],
        "a2MeasRedirectSsbRsrp": {
            "a2HysteresisRedirectSsbRsrp": "6",
            "a2ThresholdRedirectSsbRsrp": "35",
            "a2TimeToTriggerRedirectSsbRsrp": "ms64"
        },
        "a2MeasPCellSwitchSsbRsrp": c_meas_profile.A2_MEAS_PCELL_SWITCH_DICT[fdd_cells]['a2MeasPCellSwitchSsbRsrp'],
        "a3MeasSsbRsrp": c_meas_profile.A3_MEAS_DICT[fdd_cells]["a3MeasSsbRsrp"],
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


if __name__ == '__main__':
    import json
    import os
    from taf.sbts.oam.coam.admin import admin
    api = admin()
    con = api.connect_to()
    XML_LOC = '/home/ute/logs/CB013392_C_B1/commissioning'
    XML_FILE = 'current_scf.xml'
    USE_GNB_XML_AS_REF = True
    PERFORM_COMMISSIONING = False
    # with USE_GNB_XML_AS_REF activates the connection to the gnb. without it there will be no interaction with the gnb.
    # running without is faster since all the code is only in python.
    if USE_GNB_XML_AS_REF:
        api.get_current_scf_file(XML_LOC,
                                 XML_FILE, 10, con)
        with open(os.path.join(XML_LOC, XML_FILE), 'r') as f:
            file_content = f.read()
    else:
        logging.basicConfig(level=logging.DEBUG)
        with open(os.path.join(XML_LOC, XML_FILE), 'r') as f:
            file_content = f.read()
    from time import perf_counter
    start = perf_counter()
    scf_changes_for_commissioning = get_data_for_commissioning(file_content)
    print("execution time: ", perf_counter() - start)
    json_file_path = os.path.join(XML_LOC, 'commissioning.json')
    with open(json_file_path, 'w') as f:
        json.dump(scf_changes_for_commissioning, f, indent=4)

    if PERFORM_COMMISSIONING:
        try:
            api.perform_delta_recommissioning(delta_file=json_file_path,
                                              skip_parameter_relation_errors=True,
                                              connection=con)
        except Exception as e:
            print(e)
        api.teardown_all_aliases_for_admin()
