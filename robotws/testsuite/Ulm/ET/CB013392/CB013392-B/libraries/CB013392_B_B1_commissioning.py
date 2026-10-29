from testsuite.Ulm.ET.L2.libraries.ScfChanges import ScfChanges
import importlib

a_meas_profile = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-A.configurations.CB013392_A_profile")


def get_data_for_commissioning(scf_data: str, tdd_cells='11', fdd_cell='7'):
    scf_changes = ScfChanges(scf_data)
    add_changes_for_NRBTS(scf_changes)
    create_NRMEAS_PROFILE(scf_changes)
    create_and_populate_NRMEASPR_IAF(scf_changes, 1)
    create_and_populate_NRMEASPR_IAF(scf_changes, 2)
    create_NRMEASPR_MA_SA(scf_changes)
    add_changes_for_NRHOIF_and_NRREL(scf_changes)
    other_cell_changes(scf_changes)
    # for HO from FDD cell 7 to TDD cell 4
    create_nrrel_for_fdd_cell(scf_changes, fdd_cell)
    return scf_changes.get_modifications_for_commissioning()


# ====================================================================================================[120 characters]
def create_nrrel_for_fdd_cell(scf_changes_object: ScfChanges, tdd_cells):
    # needed for handover to TDD cell 4
    nrrel_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}/NRREL-1"

    param_dict = {
                    "cellIndividualSsbRsrpOffset": "0dB",
                    "cellIndividualSsbRsrqOffset": "0dB",
                    "cellIndvSsbRsrpOffsetForRI": "0",
                    "cellIndvSsbRsrqOffsetForRI": "0",
                    "gNbId": "1",
                    "gNbIdLength": "22",
                    "handoverAllowedSA": "allowed",
                    "handoverAllowedSARedCap": "forbidden",
                    "isRplCellForPSCell": "false",
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


def add_changes_for_NRBTS(scf_changes_object: ScfChanges):
    regex_nrbts = f"MRBTS-1/NRBTS-1"
    nrbts_changes = {
        "actMeasurementProfile": "SA+NSA",
        "actMeasurementProfReselForCA": "pcInSaUlAndDlCaSupported",
        "actMeasBasedSCellAdditionSa": ["disabled"],
        "actBufferBasedSCellAddition": "disabled",
        "sCellActivationMethod": "blind",
        "actMeasBasedSCellAdditionNsa": "false",
        "actInterFreqHoSA": "true",
        "actIntraFreqHoSA": "true",
        "actIntraNrNgHo": "basicTargetOnly",
        "tNgRelocExecDeltN": "3000",
        "suppCnPartialAdNgHo": "false",
        "actCarAgPmCount": "true",
        "actOverheatingAssistance": "false",
        # To avoid UEs getting idle
        "nsaInactivityTimer": "7200",
        "srbInactivityTimerSA": "600",
        "drbInactivityTimerSA": "600"
    }
    for p_name, value in nrbts_changes.items():
        scf_changes_object.add_change({"regex": regex_nrbts, "p_name": p_name, "value": value})


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


def create_NRMEASPR_MA_SA(scf_changes_object: ScfChanges):
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
    meas_profile_param_list = {"nrMeasPrIafDN": f"NRMEASPR_IAF-2"}
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
            {"measPrPriority": 10,
             "nrMeasPrMaSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1"},
            {"measPrPriority": 20,
             "nrMeasPrMaSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2"}]})


def create_NRMEAS_PROFILE(scf_changes_object: ScfChanges, profile=1):
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRMEAS_PROFILE-{profile}"})


def add_changes_for_NRHOIF_and_NRREL(scf_changes_object: ScfChanges):
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRCELL-[0-9]+/NRHOIF-[0-9]+",
                                   "p_name": "a2BasedPCellSwitchEnabled", "value": "false"})
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRCELL-[0-9]+/NRHOIF-[0-9]+",
                                   "p_name": "a1BasedPCellSwitchEnabled", "value": "false"})
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRCELL-[348]/NRREL-1",
                                   "p_name": "sCellAdditionMethod", "value": "blind"})
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRCELL-[34]/NRREL-1",
                                   "p_name": "sCellOperationalMode", "value": "dlAndUl"})


def other_cell_changes(scf_changes_object: ScfChanges):
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRCELL-[0-9]+",
                                   "p_name": "sCellDeactivationTimerGNB", "value": "infinity"})
    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-5/NRREL-10', 'operation': 'delete'})
    scf_changes_object.add_change({"regex": "MRBTS-1/NRBTS-1/NRCELL-[0-9]+",
                                   "p_name": "a2MeasSCellRelEnabled", "value": "none"})
