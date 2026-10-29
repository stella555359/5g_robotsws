from testsuite.Ulm.ET.L2.libraries.ScfChanges import ScfChanges
import logging
import importlib

a_profile = importlib.import_module("testsuite.Ulm.ET.CB013392.CB013392-A.configurations.CB013392_A_profile")


def get_data_for_commissioning(scf_data: str, tdd_cells='3', fdd_cells='8'):
    scf_changes = ScfChanges(scf_data)
    add_changes_for_NRBTS(scf_changes)
    add_changes_for_NRCELLGRP(scf_changes)

    create_and_populate_NRHOIF(scf_changes, tdd_cells)
    create_NRMEAS_PROFILE(scf_changes)
    create_and_populate_NRMEASPR_IAF(scf_changes, 1)
    create_and_populate_NRMEASPR_IAF(scf_changes, 2)
    create_NRMEASPR_MA_SA(scf_changes)
    update_nrrel_for_tdd(scf_changes, tdd_cells)
    add_changes_for_tdd_NRCELL_config(scf_changes, tdd_cells)
    add_changes_for_fdd_NRCELL_config(scf_changes, fdd_cells)
    add_changes_for_NRDU(scf_changes)
    add_changes_for_NRMOPR(scf_changes)
    return scf_changes.get_modifications_for_commissioning()


def add_changes_for_NRBTS(scf_changes_object: ScfChanges):
    regex_nrbts = f"MRBTS-1/NRBTS-1"
    nrbts_changes = {
        "actRfspIndex": "true",
        "actMeasurementProfile": "SA+NSA",
        "actMeasurementProfReselForCA": "pcInSaUlCaSupported",
        "actMeasBasedSCellAdditionSa": ["A1-based"],
        "sCellActivationMethod": "bufferBased",
        "actMeasBasedSCellAdditionNsa": "false",
        "actA2SgnbRelease": "true",
        "actIntraMeNBMobility": "true",
        "actRedirect": "true",
        "actIntraFreqHoSA": "true",
        "actCarAgPmCount": "true"
    }
    for p_name, value in nrbts_changes.items():
        scf_changes_object.add_change({"regex": regex_nrbts, "p_name": p_name, "value": value})


def add_changes_for_NRCELLGRP(scf_changes_object: ScfChanges):
    regex_nrcellgrp = f"MRBTS-1/NRBTS-1/NRCELLGRP-2"
    scf_changes_object.add_change({"regex": regex_nrcellgrp, "p_name": "numberOfTransmittedSsBlocks",
                                   "value": "1 beam"})


def update_nrrel_for_tdd(scf_changes_object: ScfChanges, tdd_cells):
    tdd_nrcell_nrrel_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}/NRREL-1"
    scf_changes_object.add_change({"regex": tdd_nrcell_nrrel_regex, "p_name": "sCellOperationalMode",
                                   "value": "dlAndUl"})
    scf_changes_object.add_change({"regex": tdd_nrcell_nrrel_regex, "p_name": "sCellAdditionMethod",
                                   "value": "covBasedA1"})


def create_and_populate_NRHOIF(scf_changes_object: ScfChanges, tdd_cells):
    regex_nrhoif_tdd = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}/NRHOIF-1"
    scf_changes_object.add_change({"regex": regex_nrhoif_tdd})
    param_dict = {"freqBandIndicatorNR": "25",
                  "a3MeasEnabled": "rsrp",
                  "a5MeasEnabled": "rsrp",
                  "ifhoSsbScs": "15KHz",
                  "ifhoSsbSmtcDuration": "sf1",
                  "ifhoSsbSmtcPeriodicity": "sf10",
                  "cellDepType": "SA+NSA",
                  "scs": "15 KHz",
                  "thresholdPCellSwitchTargetRsrp": "80"
                  }
    for p_name, value in param_dict.items():
        scf_changes_object.add_change({"regex": regex_nrhoif_tdd, "p_name": p_name, "value": value})

    a3_a5_lists = {
        "a3MeasSsbRsrp": a_profile.NRHOIF_A3_MEAS_DICT[tdd_cells]["a3MeasSsbRsrp"],
        "a5MeasSsbRsrp": a_profile.NRHOIF_A5_MEAS_DICT[tdd_cells]["a5MeasSsbRsrp"]
    }

    for list_name, list_parameters in a3_a5_lists.items():
        for p_name, value in list_parameters.items():
            scf_changes_object.add_change({"regex":  regex_nrhoif_tdd,  "list_name": list_name,
                                           "p_name": p_name, "value":     value})

    regex_nrhoif = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}/NRHOIF-[0-9]+"
    scf_changes_object.add_change({"regex": regex_nrhoif, "p_name": "a2BasedPCellSwitchEnabled", "value": "false"})


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

        all_event_list = [a1_lists, a_profile.B2_IAF_1]
    else:
        a1_lists = {
            "a1MeashoSsbRsrp": {
                "a1HysteresishoSsbRsrp": "1",
                "a1ThresholdhoSsbRsrp": "61",
                "a1TimeToTriggerhoSsbRsrp": "ms64"
            },
            "a1MeashoPrefNRLayerSsbRsrp": {
                "a1HysteresisSsbRsrp": "0",
                "a1ThresholdhoSsbRsrp": "60",
                "a1TimeToTriggerhoSsbRsrp": "ms40"
            }
        }
        a2_lists = {
            "a2MeasReleaseSsbRsrp": {
                "a2HysteresisReleaseSsbRsrp": "0",
                "a2ThresholdReleaseSsbRsrp": "34",
                "a2TimeToTriggerReleaseSsbRsrp": "ms480"}
        }

        all_event_list = [a1_lists, a2_lists, a_profile.B2_IAF_2]
    for event_list in all_event_list:
        for list_name, list_parameters in event_list.items():
            for p_name, value in list_parameters.items():
                scf_changes_object.add_change({"regex": regex, "list_name": list_name,
                                               "p_name": p_name, "value": value})


def create_NRMEASPR_MA_SA(scf_changes_object: ScfChanges):
    # for NRMEASPR_MA_SA-1
    meas_prof_ma_sa_regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1"
    meas_profile_param_list = {"nrMeasPrIafDN": f"NRMEASPR_IAF-1",
                               "redCap": "none"}
    for p_name, value in meas_profile_param_list.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_sa_regex, "p_name": p_name, "value": value})

    pcCapabilityList = {
        "uePowerClass": "ue-PowerClass2",
        "freqBandIndicatorNR": "41"
    }
    for p_name, value in pcCapabilityList.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_sa_regex, "list_name": "pcCapabilityList",
                                       "p_name": p_name, "value": value})

    # for NRMEASPR_MA_SA-2
    meas_prof_ma_sa_regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2"
    meas_profile_param_list = {"nrMeasPrIafDN": f"NRMEASPR_IAF-2",
                               "redCap": "none"}
    for p_name, value in meas_profile_param_list.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_sa_regex, "p_name": p_name, "value": value})

    pcCapabilityList = {
        "uePowerClass": "ue-PowerClass3",
        "freqBandIndicatorNR": "41"
    }
    for p_name, value in pcCapabilityList.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_sa_regex, "list_name": "pcCapabilityList",
                                       "p_name": p_name, "value": value})

    scf_changes_object.add_change({
        "regex": "MRBTS-1/NRBTS-1/NRCELL-[0-9]+",
        "list_name": "measPrMaSAList",
        "whole_list": [
            {"measPrPriority": 10,
             "nrMeasPrMaSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1"},
            {"measPrPriority": 20,
             "nrMeasPrMaSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2"}]})


def create_NRMEAS_PROFILE(scf_changes_object: ScfChanges, profile=1):
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-{profile}"})


def add_changes_for_tdd_NRCELL_config(scf_changes_object: ScfChanges, tdd_cells, measurement_method="rsrp"):
    default_measurements = ["a1MeashoEnabled", "a1MeashoEnabledSA", "a1MeasSCellAddEnabled",
                            "a2MeashoEnabled", "a2MeashoEnabledSA", "a2MeasRedirectEnabled", "a2MeasReleaseEnabled",
                            "a2MeasPCellSwitchEnabled", "a3MeasEnabled", "a5MeasEnabled"]
    tdd_nrcell_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}"
    for measurement in default_measurements:
        scf_changes_object.add_change({"regex": tdd_nrcell_regex, "p_name": measurement, "value": measurement_method})

    nr_cell_changes = {
        "actBeamforming": "true",
        "numberOfRxBeamforming": "4Rx",
        "pMaxNROwnCell": "23",
        "prachConfigurationIndex": "9",
        "increasePUSCHPrepTimeULCA": "false"
    }
    for nr_name, nr_value in nr_cell_changes.items():
        scf_changes_object.add_change({"regex": tdd_nrcell_regex, "p_name": nr_name,
                                       "value": nr_value})

    meas_dict = {
        "a1MeashoSsbRsrp": a_profile.A1_MEAS_DICT[tdd_cells]["a1MeashoSsbRsrp"],
        "a1MeashoSsbRsrpSA": a_profile.A1_MEAS_DICT[tdd_cells]["a1MeashoSsbRsrpSA"],
        "a1MeasSCellAddSsbRsrp": a_profile.A1_MEAS_DICT[tdd_cells]["a1MeasSCellAddSsbRsrp"],
        "a2MeashoSsbRsrp": a_profile.A2_MEAS_DICT[tdd_cells]["a2MeashoSsbRsrp"],
        "a2MeashoSsbRsrpSA": a_profile.A2_MEAS_DICT[tdd_cells]["a2MeashoSsbRsrpSA"],
        "a2MeasRedirectSsbRsrp": a_profile.A2_MEAS_DICT[tdd_cells]["a2MeasRedirectSsbRsrp"],
        "a2MeasReleaseSsbRsrp": a_profile.A2_MEAS_DICT[tdd_cells]["a2MeasReleaseSsbRsrp"],
        "a2MeasPCellSwitchSsbRsrp": a_profile.A2_MEAS_DICT[tdd_cells]["a2MeasPCellSwitchSsbRsrp"],
        "a3MeasSsbRsrp": a_profile.A3_MEAS_DICT[tdd_cells]["a3MeasSsbRsrp"],
        "a5MeasSsbRsrp": a_profile.A5_MEAS_DICT[tdd_cells]["a5MeasSsbRsrp"],
    }
    for meas_name, meas_value in meas_dict.items():
        for p_name, value in meas_value.items():
            scf_changes_object.add_change({"regex": tdd_nrcell_regex, "p_name": p_name,
                                           "value": value, "list_name": meas_name})


def add_changes_for_fdd_NRCELL_config(scf_changes_object: ScfChanges, fdd_cells, measurement_method="rsrp"):
    regex = f"MRBTS-1/NRBTS-1/NRCELL-{fdd_cells}"
    default_measurements = ["a1MeashoEnabled", "a1MeashoEnabledSA", "a2MeashoEnabledSA",
                            "a2MeasRedirectEnabled", "a2MeasReleaseEnabled", "a2MeasPCellSwitchEnabled"]
    for measurement in default_measurements:
        scf_changes_object.add_change({"regex": regex, "p_name": measurement, "value": measurement_method})

    ssb_dict = {
        "a1MeashoSsbRsrp": a_profile.A1_MEAS_DICT[fdd_cells]["a1MeashoSsbRsrp"],
        "a1MeashoSsbRsrpSA": a_profile.A1_MEAS_DICT[fdd_cells]["a1MeashoSsbRsrpSA"],
        "a2MeashoSsbRsrpSA": a_profile.A2_MEAS_DICT[fdd_cells]["a2MeashoSsbRsrpSA"],
        "a2MeasRedirectSsbRsrp": a_profile.A2_MEAS_DICT[fdd_cells]["a2MeasRedirectSsbRsrp"],
        "a2MeasReleaseSsbRsrp": a_profile.A2_MEAS_DICT[fdd_cells]["a2MeasReleaseSsbRsrp"],
        "a2MeasPCellSwitchSsbRsrp": a_profile.A2_MEAS_DICT[fdd_cells]["a2MeasPCellSwitchSsbRsrp"]
    }
    for ssb_name, ssb_param in ssb_dict.items():
        for p_name, value in ssb_param.items():
            scf_changes_object.add_change({"regex": regex, "list_name": ssb_name,
                                           "p_name": p_name, "value": value})


def add_changes_for_NRDU(scf_changes_object: ScfChanges):
    regex_nrdu = f"MRBTS-1/NRBTS-1/NRDU-1"
    scf_changes_object.add_change({"regex": regex_nrdu, "p_name": "actNonBfAndBfCa", "value": "true"})

    whole_list = ["ca_Fdd_Fdd",
                  "ca_Fdd_Fr1Tdd_Sa",
                  "ca_Fr1Tdd_Fdd_Sa",
                  "ca_Fr1Tdd_Fdd_Sa_WithUl",
                  "ca_Fdd_Any_Sa",
                  "ca_Fr1Tdd_Sa",
                  "ca_Fdd_Fr1Tdd_Sa_WithUl",
                  "ca_Fr1Tdd_Any_Sa"
                  ]
    scf_changes_object.add_change({"regex": regex_nrdu, "whole_list": whole_list,
                                   "list_name": "carrierAggregationSupportList"})


def add_changes_for_NRMOPR(scf_changes_object: ScfChanges):
    regex_nrmopr = f"MRBTS-1/NRBTS-1/NRMOPR_SA-1"
    scf_changes_object.add_change({"regex": regex_nrmopr, "p_name": "a2MeasRedirectEnabled", "value": "rsrp"})


if __name__ == '__main__':
    import json
    import os

    xml_loc = r'/home/ute/DEVELOPMENT/robotws/CB008127_A_B2/commissioning/'
    xml_file = 'current_scf.xml'
    with_api = True
    from taf.sbts.oam.coam.admin import admin

    api = admin()
    con = api.connect_to()
    if with_api:
        api.get_current_scf_file(xml_loc,
                                 xml_file, 10, con)
        with open(os.path.join(xml_loc, xml_file), 'r') as f:
            file_content = f.read()
    else:
        logging.basicConfig(level=logging.DEBUG)
        with open(os.path.join(xml_loc, xml_file), 'r') as f:
            file_content = f.read()
    from time import perf_counter

    start = perf_counter()
    scf_changes_for_commissioning = get_data_for_commissioning(file_content)
    print("execution time: ", perf_counter() - start)
    json_file_path = os.path.join(xml_loc, 'commissioning.json')
    with open(json_file_path, 'w') as f:
        json.dump(scf_changes_for_commissioning, f, indent=4)
    if with_api:
        try:
            api.perform_delta_recommissioning(delta_file=json_file_path,
                                              skip_parameter_relation_errors=True,
                                              connection=con)
        except Exception as e:
            print(e)
        api.teardown_all_aliases_for_admin()
