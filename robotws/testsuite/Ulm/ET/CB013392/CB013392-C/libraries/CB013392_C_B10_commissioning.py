import importlib

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.L2.libraries.ScfChanges import ScfChanges

c_meas_profile = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-C.configurations.CB013392_C_profile")


def get_data_for_commissioning(scf_data: str, tdd_cell='4', fdd_cells='2'):
    scf_changes = ScfChanges(scf_data)
    add_changes_for_NRBTS(scf_changes)
    create_NRMEAS_PROFILE(scf_changes)
    create_and_populate_NRMEASPR_IAF(scf_changes, 1)
    create_and_populate_NRMEASPR_IAF(scf_changes, 2)
    create_NRMEASPR_MA_NSA(scf_changes)
    create_and_populate_NRMEASPR_IEF(scf_changes, 1)
    create_and_populate_NRMEASPR_IEF(scf_changes, 2)
    prepare_for_A1_A4_inter_freq_mobility(scf_changes)
    return scf_changes.get_modifications_for_commissioning()


def add_changes_for_NRBTS(scf_changes_object: ScfChanges):
    regex_nrbts = "MRBTS-1/NRBTS-1"

    if "TC01" in BuiltIn().get_variable_value("${scenario_name}"):
        PrefNrLayerVar = "none"
    else:
        PrefNrLayerVar = "NSA"

    nrbts_changes = {
        "actMeasurementProfile": "SA+NSA",
        "actMeasProfPowerCoordNSA": "activated",
        "actA1HoPrefNRLayer": PrefNrLayerVar
    }
    for p_name, value in nrbts_changes.items():
        scf_changes_object.add_change({"regex": regex_nrbts, "p_name": p_name, "value": value})


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


def create_NRMEASPR_MA_NSA(scf_changes_object: ScfChanges, freq="71", cell="4"):
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


def create_NRMEAS_PROFILE(scf_changes_object: ScfChanges, profile=1):
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-{profile}"})


def prepare_for_A1_A4_inter_freq_mobility(scf_changes_object: ScfChanges):
    # Cell changes for A4
    regex_nrcell = f"MRBTS-1/NRBTS-1/NRCELL-[0-9]+"
    a4_changes = {
        "a4Fr1SupervisionTimer": "10000",
        "a4Fr2SupervisionTimer": "6000",
        "a4MeasMaxNumber": "5",
        "a4RetryTimer": "5"
    }
    for p_name, value in a4_changes.items():
        scf_changes_object.add_change({"regex": regex_nrcell, "p_name": p_name,
                                       "value": value, "list_name": "a4PeriodicMeasControlNSA"})

    # HOIF changes for cell 4
    regex_hoif = f"MRBTS-1/NRBTS-1/NRCELL-4/NRHOIF-2"
    hoif_changes = {
        "a4MeasHigherPrioFreqEnabled": "rsrp",
        "a4PriorityForHigherPrioFreqHo": "10"
    }
    for p_name, value in hoif_changes.items():
        scf_changes_object.add_change({"regex": regex_hoif, "p_name": p_name, "value": value})

    a4_values = c_meas_profile.NRHOIF_A4_MEAS_DICT["4"]["a4MeasSsbRsrp"]
    for p_name, value in a4_values.items():
        scf_changes_object.add_change({"regex": regex_hoif, "list_name": "a4MeasSsbRsrp",
                                       "p_name": p_name, "value": value})

    # Cell 4 changes for A1
    regex_nrcell_4 = f"MRBTS-1/NRBTS-1/NRCELL-4"
    a1_changes = {
        "a1MeashoPrefNRLayerEnabled": "rsrp",
        "a4MeasHigherPrioFreqMaxReact": "5"
    }
    for p_name, value in a1_changes.items():
        scf_changes_object.add_change({"regex": regex_nrcell_4, "p_name": p_name, "value": value})

    a1_values = c_meas_profile.A1_MEAS_DICT_B10_Alt["4"]["a1MeashoPrefNRLayerSsbRsrp"]
    for p_name, value in a1_values.items():
        scf_changes_object.add_change({"regex": regex_nrcell_4, "list_name": "a1MeashoPrefNRLayerSsbRsrp",
                                       "p_name": p_name, "value": value})
