from testsuite.Ulm.ET.L2.libraries.ScfChanges import ScfChanges
import logging
import importlib

a_meas_profile = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-A.configurations.CB013392_A_profile")


# ====================================================================================================[120 characters]
def get_data_for_commissioning(scf_data: str, tdd_cells='3', tdd_scell='4', fdd_scell='8'):
    scf_changes = ScfChanges(scf_data)
    add_changes_for_NRBTS(scf_changes)
    other_cell_changes(scf_changes)
    create_NRMEAS_PROFILE(scf_changes)
    create_and_populate_NRMEASPR_IAF(scf_changes, 1)
    create_and_populate_NRMEASPR_IAF(scf_changes, 2)
    create_NRMEASPR_MA_SA(scf_changes)
    create_and_populate_NRMEASPR_IEF(scf_changes, 1)
    create_and_populate_NRMEASPR_IEF(scf_changes, 2)
    create_nrrel_for_tdd_pcell(scf_changes, tdd_cells)
    add_changes_for_tdd_NRCELL_config(scf_changes, tdd_cells)
    add_changes_for_tdd_scell_NRCELL_config(scf_changes, tdd_scell)
    add_changes_for_fdd_scell_NRCELL_config(scf_changes, fdd_scell)
    add_changes_for_NRDU(scf_changes)
    return scf_changes.get_modifications_for_commissioning()


def add_changes_for_NRBTS(scf_changes_object: ScfChanges):
    regex_nrbts = f"MRBTS-1/NRBTS-1"
    nrbts_changes = {
        "actMeasurementProfile": "SA+NSA",
        "actMeasurementProfReselForCA": "pcInSaUlCaSupported",
        "actMeasBasedSCellAdditionSa": ["A1-based"],
        "actBufferBasedSCellAddition": "disabled",
        "sCellActivationMethod": "blind",
        "actMeasBasedSCellAdditionNsa": "false",
        "actA2SgnbRelease": "true",
        "actIntraMeNBMobility": "true",
        "actRedirect": "true",
        "actIntraFreqHoSA": "true",
        "actCarAgPmCount": "true",
        "actOverheatingAssistance": "false"
    }
    for p_name, value in nrbts_changes.items():
        scf_changes_object.add_change({"regex": regex_nrbts, "p_name": p_name, "value": value})


def other_cell_changes(scf_changes_object: ScfChanges):
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRCELL-[0-9]+",
                                   "p_name": "sCellDeactivationTimerGNB", "value": "infinity"})

    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-5/NRREL-10', 'operation': 'delete'})


def create_and_populate_NRMEASPR_IEF(scf_changes_object: ScfChanges, profile=1):
    regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IEF-{profile}"
    if profile == 1:
        event_list = a_meas_profile.B3_IEF_1
    else:
        event_list = a_meas_profile.B3_IEF_2
    for list_name, list_parameters in event_list.items():
        for p_name, value in list_parameters.items():
            scf_changes_object.add_change({"regex": regex, "list_name": list_name,
                                           "p_name": p_name, "value": value})


# ====================================================================================================[120 characters]
def create_nrrel_for_tdd_pcell(scf_changes_object: ScfChanges, tdd_cells):
    # PCell NRREL to TDD SCell 4
    nrrel_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}/NRREL-2"

    param_dict = {
                    "cellIndividualSsbRsrpOffset": "0dB",
                    "cellIndividualSsbRsrqOffset": "0dB",
                    "gNbId": "1",
                    "gNbIdLength": "22",
                    "handoverAllowedSA": "allowed",
                    "handoverAllowedSARedCap": "forbidden",
                    "isRplCellForPSCell": "false",
                    "lcrId": "4",
                    "nrDcAllowed": "false",
                    "removeNotAllowed": "true",
                    "sCellAdditionMethod": "covBasedA1",
                    "sCellOperationalMode": "dlOnly"
                 }
    for p_name, value in param_dict.items():
        scf_changes_object.add_change({"regex": nrrel_regex, "p_name": p_name, "value": value})

    plmn_value_dict = {"gnbPlmn": {
        "mcc": "310",
        "mnc": "260",
        "mncLength": "3"
    }}
    for meas_name, meas_value in plmn_value_dict.items():
        for p_name, value in meas_value.items():
            scf_changes_object.add_change({"regex": nrrel_regex, "p_name": p_name,
                                           "value": value, "list_name": meas_name})


# ====================================================================================================[120 characters]
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

        all_event_list = [a1_lists, a_meas_profile.B3_IAF_1]
    else:
        a1_lists = {
            "a1MeashoSsbRsrp": {
                "a1HysteresishoSsbRsrp": "1",
                "a1ThresholdhoSsbRsrp": "61",
                "a1TimeToTriggerhoSsbRsrp": "ms64"
            },
            "a1MeashoPrefNRLayerSsbRsrp": {
                "a1HysteresisSsbRsrp": "1",
                "a1ThresholdhoSsbRsrp": "61",
                "a1TimeToTriggerhoSsbRsrp": "ms40"
            }
        }
        a2_lists = {
            "a2MeasReleaseSsbRsrp": {
                "a2HysteresisReleaseSsbRsrp": "0",
                "a2ThresholdReleaseSsbRsrp": "34",
                "a2TimeToTriggerReleaseSsbRsrp": "ms480"}
        }

        all_event_list = [a1_lists, a2_lists, a_meas_profile.B3_IAF_2]
    for event_list in all_event_list:
        for list_name, list_parameters in event_list.items():
            for p_name, value in list_parameters.items():
                scf_changes_object.add_change({"regex": regex, "list_name": list_name,
                                               "p_name": p_name, "value": value})


def create_NRMEASPR_MA_SA(scf_changes_object: ScfChanges):
    # Profile 1 with power class-2
    meas_prof_ma_sa_regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1"
    meas_profile_param_list = {"nrMeasPrIafDN": f"NRMEASPR_IAF-1",
                               "nrMeasPrIefDefaultDN": f"NRMEASPR_IEF-1"}
    for p_name, value in meas_profile_param_list.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_sa_regex, "p_name": p_name, "value": value})

    pcCapabilityList = {
        "uePowerClass": "ue-PowerClass2",
        "freqBandIndicatorNR": "41"
    }
    for p_name, value in pcCapabilityList.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_sa_regex, "list_name": "pcCapabilityList",
                                       "p_name": p_name, "value": value})

    # Profile 2 with power class-3
    meas_prof_ma_sa_regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2"
    meas_profile_param_list = {"nrMeasPrIafDN": f"NRMEASPR_IAF-2",
                               "nrMeasPrIefDefaultDN": f"NRMEASPR_IEF-2"}
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


# ====================================================================================================[120 characters]
def create_NRMEASPR_MA_SA_without_powerclass(scf_changes_object: ScfChanges):
    meas_prof_ma_sa_regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1"
    meas_profile_param_list = {"nrMeasPrIafDN": f"NRMEASPR_IAF-1",
                               "nrMeasPrIefDefaultDN": f"NRMEASPR_IEF-1"}
    for p_name, value in meas_profile_param_list.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_sa_regex, "p_name": p_name, "value": value})

    meas_prof_ma_sa_regex = f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2"
    meas_profile_param_list = {"nrMeasPrIafDN": f"NRMEASPR_IAF-2",
                               "nrMeasPrIefDefaultDN": f"NRMEASPR_IEF-2"}
    for p_name, value in meas_profile_param_list.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_sa_regex, "p_name": p_name, "value": value})

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
                            "a2MeasSCellRelEnabled", "a3MeasEnabled", "a5MeasEnabled"]
    tdd_nrcell_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}"
    for measurement in default_measurements:
        scf_changes_object.add_change({"regex": tdd_nrcell_regex, "p_name": measurement, "value": measurement_method})

    nr_cell_changes = {
        "a2MeasPCellSwitchEnabled": "none",
        "increasePUSCHPrepTimeULCA": "false",
        "actULSchedInactiveBwp": "false",
        "actPowerSavingBWP": "false"
    }
    for nr_name, nr_value in nr_cell_changes.items():
        scf_changes_object.add_change({"regex": tdd_nrcell_regex, "p_name": nr_name, "value": nr_value})

    meas_dict = {
        "a1MeashoSsbRsrp": a_meas_profile.A1_MEAS_DICT[tdd_cells]["a1MeashoSsbRsrp"],
        "a1MeashoSsbRsrpSA": a_meas_profile.A1_MEAS_DICT[tdd_cells]["a1MeashoSsbRsrpSA"],
        "a1MeasSCellAddSsbRsrp": a_meas_profile.A1_MEAS_DICT[tdd_cells]["a1MeasSCellAddSsbRsrp"],
        "a2MeashoSsbRsrp": a_meas_profile.A2_MEAS_DICT[tdd_cells]["a2MeashoSsbRsrp"],
        "a2MeashoSsbRsrpSA": a_meas_profile.A2_MEAS_DICT[tdd_cells]["a2MeashoSsbRsrpSA"],
        "a2MeasRedirectSsbRsrp": a_meas_profile.A2_MEAS_DICT[tdd_cells]["a2MeasRedirectSsbRsrp"],
        "a2MeasReleaseSsbRsrp": a_meas_profile.A2_MEAS_DICT[tdd_cells]["a2MeasReleaseSsbRsrp"],
        "a2MeasSCellRelSsbRsrp": a_meas_profile.A2_MEAS_DICT[tdd_cells]["a2MeasSCellRelSsbRsrp"],
        "a2MeasPCellSwitchSsbRsrp": a_meas_profile.A2_MEAS_DICT[tdd_cells]["a2MeasPCellSwitchSsbRsrp"],
        "a3MeasSsbRsrp": a_meas_profile.A3_MEAS_DICT[tdd_cells]["a3MeasSsbRsrp"],
        "a5MeasSsbRsrp": a_meas_profile.A5_MEAS_DICT[tdd_cells]["a5MeasSsbRsrp"]
    }
    for meas_name, meas_value in meas_dict.items():
        for p_name, value in meas_value.items():
            scf_changes_object.add_change({"regex": tdd_nrcell_regex, "p_name": p_name,
                                           "value": value, "list_name": meas_name})

    scf_changes_object.add_change({
        "regex": f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}",
        "list_name": "cellBwpList",
        "whole_list": [
            {
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "bwpDN": "MRBTS-1/NRBTS-1/BWP_PROFILE-194",
                "cellBwpId": "0",
                "pdcchResourcePreference": "peakRate"
            },
            {
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "bwpDN": "MRBTS-1/NRBTS-1/BWP_PROFILE-219",
                "cellBwpId": "1",
                "pdcchResourcePreference": "peakRate"
            }
        ]
    })

    # adapt PCell NRREL to FDD SCell 8
    nrrel_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}/NRREL-1"
    scf_changes_object.add_change({"regex": nrrel_regex, "p_name": "sCellOperationalMode", "value": "dlAndUl"})


# ====================================================================================================[120 characters]
def add_changes_for_tdd_scell_NRCELL_config(scf_changes_object: ScfChanges, tdd_cells):

    tdd_nrcell_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}"

    nr_cell_changes = {
        "increasePUSCHPrepTimeULCA": "false",
        "actULSchedInactiveBwp": "false",
        "actPowerSavingBWP": "false"
    }
    for nr_name, nr_value in nr_cell_changes.items():
        scf_changes_object.add_change({"regex": tdd_nrcell_regex, "p_name": nr_name, "value": nr_value})

    scf_changes_object.add_change({
        "regex": f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}",
        "list_name": "cellBwpList",
        "whole_list": [
            {
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "bwpDN": "MRBTS-1/NRBTS-1/BWP_PROFILE-191",
                "cellBwpId": "0",
                "pdcchResourcePreference": "peakRate"
            },
            {
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "bwpDN": "MRBTS-1/NRBTS-1/BWP_PROFILE-218",
                "cellBwpId": "1",
                "pdcchResourcePreference": "peakRate"
            },
            {
                "actPdcchCceFragmentControl": "false",
                "actUpperThrAckNackFiltering": "false",
                "actUpperThrAckNackHrFiltering": "false",
                "bwpDN": "MRBTS-1/NRBTS-1/BWP_PROFILE-237",
                "cellBwpId": "2",
                "pdcchResourcePreference": "peakRate"
            }
        ]
    })


# ====================================================================================================[120 characters]
def add_changes_for_fdd_scell_NRCELL_config(scf_changes_object: ScfChanges, fdd_cells):

    tdd_nrcell_regex = f"MRBTS-1/NRBTS-1/NRCELL-{fdd_cells}"
    scf_changes_object.add_change({"regex": tdd_nrcell_regex, "p_name": "pMaxNROwnCell", "value": "26"})


def add_changes_for_NRDU(scf_changes_object: ScfChanges):
    regex_nrdu = f"MRBTS-1/NRBTS-1/NRDU-1"
    whole_list = ["ca_Fdd_Fdd",
                  "ca_Fdd_Fr1Tdd_Sa",
                  "ca_Fr1Tdd_Fdd_Sa",
                  "ca_Fr1Tdd_Fdd_Sa_WithUl",
                  "ca_Fdd_Any_Sa",
                  "ca_Fr1Tdd_Sa",
                  "ca_Fdd_Fr1Tdd_Sa_WithUl",
                  "ca_Fdd_Fr1Tdd_Nsa",
                  "ca_Fr1Tdd_Nsa",
                  "ca_Fr1Tdd_Any_Sa",
                  "ca_Fr1Tdd_Fr1Tdd_Sa_WithUl"
                  ]
    scf_changes_object.add_change({"regex": regex_nrdu, "whole_list": whole_list,
                                   "list_name": "carrierAggregationSupportList"})


# ====================================================================================================[120 characters]
if __name__ == '__main__':
    import json
    import os
    from taf.sbts.oam.coam.admin import admin
    api = admin()
    con = api.connect_to()
    xml_loc = '/home/ute/logs/CB013392_A_B3/commissioning'
    xml_file = 'current_scf.xml'
    use_gnb_xml_as_ref = True
    perform_commissioning = False
    # with use_gnb_xml_as_ref activates the connection to the gnb. without it there will be no interaction with the gnb.
    # running without is faster since all the code is only in python.
    if use_gnb_xml_as_ref:
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

    if perform_commissioning:
        try:
            api.perform_delta_recommissioning(delta_file=json_file_path,
                                              skip_parameter_relation_errors=False,
                                              connection=con)
        except Exception as e:
            print(e)
        api.teardown_all_aliases_for_admin()
