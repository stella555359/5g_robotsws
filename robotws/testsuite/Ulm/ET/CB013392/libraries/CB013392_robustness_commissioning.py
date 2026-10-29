import importlib
import logging

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.L2.libraries.ScfChanges import ScfChanges
mp_profile = importlib.import_module("testsuite.Ulm.ET.CB013392.configurations.robustness_profile")


# ====================================================================================================[120 characters]
def get_data_for_commissioning(scf_data: str, sa_fdd_scell='8', nsa_fdd_ho_cell='10'):
    scf_changes = ScfChanges(scf_data)
    add_changes_for_NRBTS(scf_changes)
    other_cell_changes(scf_changes)
    create_NRMEAS_PROFILE(scf_changes)
    create_and_populate_NRMEASPR_IAF(scf_changes, 1)
    create_and_populate_NRMEASPR_IAF(scf_changes, 2)
    create_NRMEASPR_MA_SA(scf_changes)
    add_changes_for_fdd_scell_NRCELL_config(scf_changes, sa_fdd_scell)
    # for C_B2 (NSA HO TC)
    create_NRMEASPR_MA_NSA(scf_changes)
    create_nrrel_for_fdd_cell(scf_changes, nsa_fdd_ho_cell)
    add_changes_for_nsa_fdd_cell_NRCELL_config(scf_changes, nsa_fdd_ho_cell)
    # for additional HO from FDD cell 7 to TDD cell 4
    create_nrrel_for_fdd_cell(scf_changes, "7")
    sw_build = BuiltIn().get_variable_value("${sw_build}")
    logging.info("sw_build = %s" % sw_build)
    if '25R' in sw_build:
        logging.info("Apply SCF changes to avoid relation error on 25Rx builds")
        add_changes_for_tdd_NRCELL_config(scf_changes, "3")
        add_changes_for_tdd_scell_NRCELL_config(scf_changes, "4")
    return scf_changes.get_modifications_for_commissioning()


def add_changes_for_tdd_NRCELL_config(scf_changes_object: ScfChanges, tdd_cell):
    tdd_nrcell_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cell}"
    nr_cell_changes = {
        "actULSchedInactiveBwp": "false",
        "actPowerSavingBWP": "false"
    }
    for nr_name, nr_value in nr_cell_changes.items():
        scf_changes_object.add_change({"regex": tdd_nrcell_regex, "p_name": nr_name, "value": nr_value})

    scf_changes_object.add_change({
        "regex": f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cell}",
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


# ====================================================================================================[120 characters]
def add_changes_for_tdd_scell_NRCELL_config(scf_changes_object: ScfChanges, tdd_cell):
    tdd_nrcell_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cell}"
    nr_cell_changes = {
        "actULSchedInactiveBwp": "false",
        "actPowerSavingBWP": "false"
    }
    for nr_name, nr_value in nr_cell_changes.items():
        scf_changes_object.add_change({"regex": tdd_nrcell_regex, "p_name": nr_name, "value": nr_value})

    scf_changes_object.add_change({
        "regex": f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cell}",
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


def add_changes_for_NRBTS(scf_changes_object: ScfChanges):
    regex_nrbts = f"MRBTS-1/NRBTS-1"
    nrbts_changes = {
        "actMeasurementProfile": "SA+NSA",
        "actMeasurementProfReselForCA": "pcInSaUlAndDlCaSupported",
        "actMeasBasedSCellAdditionSa": ["A1-based"],
        "actBufferBasedSCellAddition": "disabled",
        "sCellActivationMethod": "blind",
        "actMeasBasedSCellAdditionNsa": "true",
        "actA2SgnbRelease": "true",
        "actIntraMeNBMobility": "true",
        "actRedirect": "true",
        "actIntraFreqHoSA": "true",
        "actCarAgPmCount": "true",
        "actOverheatingAssistance": "false",
        # For C_B2 (NSA HO TC)
        "actMeasProfPowerCoordNSA": "activated",
        # To avoid UEs getting idle
        "nsaInactivityTimer": "7200",
        "srbInactivityTimerSA": "600",
        "drbInactivityTimerSA": "600"
    }
    for p_name, value in nrbts_changes.items():
        scf_changes_object.add_change({"regex": regex_nrbts, "p_name": p_name, "value": value})


def other_cell_changes(scf_changes_object: ScfChanges):
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRCELL-[0-9]+",
                                   "p_name": "sCellDeactivationTimerGNB", "value": "infinity"})

    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-5/NRREL-10', 'operation': 'delete'})


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

        all_event_list = [a1_lists, mp_profile.IAF_1_CA]
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
                "a2HysteresisReleaseSsbRsrp": "1",
                "a2ThresholdReleaseSsbRsrp": "27",
                "a2TimeToTriggerReleaseSsbRsrp": "ms320"}
        }

        all_event_list = [a1_lists, a2_lists, mp_profile.IAF_2_CA]
    for event_list in all_event_list:
        for list_name, list_parameters in event_list.items():
            for p_name, value in list_parameters.items():
                scf_changes_object.add_change({"regex": regex, "list_name": list_name,
                                               "p_name": p_name, "value": value})


def create_NRMEASPR_MA_SA(scf_changes_object: ScfChanges):
    # Profile 1 with power class-2
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

    # Profile 2 with power class-3
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


# ====================================================================================================[120 characters]
def add_changes_for_nsa_fdd_cell_NRCELL_config(scf_changes_object: ScfChanges, fdd_cell):
    fdd_nrhoif_regex = f"MRBTS-1/NRBTS-1/NRCELL-{fdd_cell}/NRHOIF-[0-9]+"
    scf_changes_object.add_change({"regex": fdd_nrhoif_regex, "p_name": "a3MeasEnabled", "value": "rsrp"})


def add_changes_for_fdd_scell_NRCELL_config(scf_changes_object: ScfChanges, fdd_cells):
    tdd_nrcell_regex = f"MRBTS-1/NRBTS-1/NRCELL-{fdd_cells}"
    scf_changes_object.add_change({"regex": tdd_nrcell_regex, "p_name": "pMaxNROwnCell", "value": "26"})


def create_NRMEASPR_MA_NSA(scf_changes_object: ScfChanges, cell="11"):
    # Profile 1
    meas_prof_ma_nsa_regex = "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1"
    meas_profile_param_list = {"nrMeasPrIafDN": "NRMEASPR_IAF-1"}
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
    meas_profile_param_list = {"nrMeasPrIafDN": "NRMEASPR_IAF-2"}
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
        "regex": "MRBTS-1/NRBTS-1/NRCELL-[0-9]+",
        "list_name": "measPrMaNSAList",
        "whole_list": [
            {"measPrPriority": 10,
             "nrMeasPrMaNSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1"},
            {"measPrPriority": 20,
             "nrMeasPrMaNSADN": "MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2"}]})
