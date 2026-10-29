import importlib

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.L2.libraries.ScfChanges import ScfChanges

c_meas_profile = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-C.configurations.CB013392_C_profile")


def get_data_for_commissioning(scf_data: str, nsa_tdd_ho_cell='3'):
    scf_changes = ScfChanges(scf_data)
    add_changes_for_NRBTS(scf_changes)
    create_NRMEAS_PROFILE(scf_changes)
    create_and_populate_NRMEASPR_IAF(scf_changes, 1)
    create_and_populate_NRMEASPR_IAF(scf_changes, 2)
    create_NRMEASPR_MA_NSA(scf_changes)
    create_and_populate_NRMEASPR_IEF(scf_changes, 1)
    create_and_populate_NRMEASPR_IEF(scf_changes, 2)
    create_NRREL_and_add_HOIF_changes_for_tdd_cell(scf_changes, nsa_tdd_ho_cell)
    return scf_changes.get_modifications_for_commissioning()


def add_changes_for_NRBTS(scf_changes_object: ScfChanges):
    regex_nrbts = "MRBTS-1/NRBTS-1"
    nrbts_changes = {
        "actMeasurementProfile": "SA+NSA",
        "actMeasProfPowerCoordNSA": "activated",
        # To avoid UEs getting idle during manual testing
        "nsaInactivityTimer": "7200",
        "srbInactivityTimerSA": "600",
        "drbInactivityTimerSA": "600"
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


def create_NRMEASPR_MA_NSA(scf_changes_object: ScfChanges):
    # Profile 1
    meas_prof_ma_nsa_regex = "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1"
    meas_profile_param_list = {"nrMeasPrIafDN": "NRMEASPR_IAF-1",
                               "nrMeasPrIefDefaultDN": "NRMEASPR_IEF-1"}
    for p_name, value in meas_profile_param_list.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_nsa_regex, "p_name": p_name, "value": value})

    pcCapabilityList = {
        "uePowerClass": "ue-PowerClass2",
        "freqBandIndicatorNR": "41"
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
        "freqBandIndicatorNR": "41"
    }
    for p_name, value in pcCapabilityList.items():
        scf_changes_object.add_change({"regex": meas_prof_ma_nsa_regex, "list_name": "pcCapabilityList",
                                       "p_name": p_name, "value": value})

    # Profile priorities
    scf_changes_object.add_change({
        "regex": f"MRBTS-1/NRBTS-1/NRCELL-[0-9]+",
        "list_name": "measPrMaNSAList",
        "whole_list": [
            {"measPrPriority": 10,
             "nrMeasPrMaNSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1"},
            {"measPrPriority": 20,
             "nrMeasPrMaNSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2"}]})


def create_NRMEAS_PROFILE(scf_changes_object: ScfChanges, profile=1):
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-{profile}"})


# ====================================================================================================[120 characters]
def create_NRREL_and_add_HOIF_changes_for_tdd_cell(scf_changes_object: ScfChanges, tdd_cell):
    # needed for handover to TDD cell 4
    nrrel_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cell}/NRREL-2"

    param_dict = {
                    "cellIndividualSsbRsrpOffset": "0dB",
                    "cellIndividualSsbRsrqOffset": "0dB",
                    "cellIndvSsbRsrpOffsetForRI": "0",
                    "cellIndvSsbRsrqOffsetForRI": "0",
                    "gNbId": "1",
                    "gNbIdLength": "22",
                    "handoverAllowedSA": "allowed",
                    "handoverAllowedSARedCap": "forbidden",
                    "isRplCellForPSCell": "true",
                    "lcrId": "4",
                    "nrDcAllowed": "false",
                    "removeNotAllowed": "true"
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

    nrhoif_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cell}/NRHOIF-[0-9]+"
    scf_changes_object.add_change({"regex": nrhoif_regex, "p_name": "a3MeasEnabled", "value": "rsrp"})
