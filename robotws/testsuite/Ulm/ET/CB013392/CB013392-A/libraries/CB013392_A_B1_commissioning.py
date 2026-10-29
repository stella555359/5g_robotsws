from testsuite.Ulm.ET.L2.libraries.ScfChanges import ScfChanges
import importlib

a_profile = importlib.import_module("testsuite.Ulm.ET.CB013392.CB013392-A.configurations.CB013392_A_profile")


def get_data_for_commissioning(scf_data: str, tdd_cells='3', fdd_cells='8'):
    scf_changes = ScfChanges(scf_data)

    add_changes_for_NRBTS(scf_changes)
    create_NRMEAS_PROFILE(scf_changes)
    create_and_populate_NRMEASPR_IAF(scf_changes, 1)
    create_and_populate_NRMEASPR_IAF(scf_changes, 2)
    create_NRMEASPR_MA_SA(scf_changes)
    add_changes_for_tdd_NRCELL_config(scf_changes, tdd_cells)
    add_changes_for_other_tdd_NRCELL_config(scf_changes, "4")
    add_changes_for_fdd_NRCELL_config(scf_changes, fdd_cells)
    add_changes_for_disabled_actMeasBasedSCellAdditionSa(scf_changes)
    other_cell_changes(scf_changes)

    return scf_changes.get_modifications_for_commissioning()


def add_changes_for_NRBTS(scf_changes_object: ScfChanges):
    regex_nrbts = f"MRBTS-1/NRBTS-1"

    nrbts_changes = {
        "actRfspIndex": "true",
        "actMeasurementProfile": "SA+NSA",
        "actMeasurementProfReselForCA": "pcInSaUlCaSupported",
        "actMeasBasedSCellAdditionSa": ["disabled"],
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
    tdd_nrcell_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cells}"

    default_measurements = ["a1MeashoEnabled", "a1MeashoEnabledSA", "a1MeasSCellAddEnabled",
                            "a2MeashoEnabled", "a2MeashoEnabledSA", "a2MeasRedirectEnabled", "a2MeasReleaseEnabled",
                            "a3MeasEnabled", "a5MeasEnabled"]
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


# ====================================================================================================[120 characters]
def add_changes_for_other_tdd_NRCELL_config(scf_changes_object: ScfChanges, tdd_cell):
    tdd_nrcell_regex = f"MRBTS-1/NRBTS-1/NRCELL-{tdd_cell}"

    nr_cell_changes = {
        "increasePUSCHPrepTimeULCA": "false",
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


def add_changes_for_fdd_NRCELL_config(scf_changes_object: ScfChanges, fdd_cells):
    regex = f"MRBTS-1/NRBTS-1/NRCELL-{fdd_cells}"
    scf_changes_object.add_change({'regex': regex, 'p_name': 'a2MeasSCellRelEnabled', 'value': 'none'})
    scf_changes_object.add_change({'regex': regex, 'p_name': 'pMaxNROwnCell', 'value': '26'})


def add_changes_for_disabled_actMeasBasedSCellAdditionSa(scf_changes_object: ScfChanges):
    hoif_regex = f"MRBTS-1/NRBTS-1/NRCELL-[0-9]+/NRHOIF-[0-9]"
    hoif_changes = {
        "a1BasedPCellSwitchEnabled": "false",
        "a2BasedPCellSwitchEnabled": "false"
    }
    for nr_name, nr_value in hoif_changes.items():
        scf_changes_object.add_change({"regex": hoif_regex, "p_name": nr_name, "value": nr_value})

    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRCELL-[0-9]+",
                                   "p_name": "a2MeasSCellRelEnabled", "value": "none"})

    for cell in [3, 4, 8]:
        scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRCELL-{cell}/NRREL-1",
                                       "p_name": "sCellAdditionMethod", "value": "blind"})


def other_cell_changes(scf_changes_object: ScfChanges):
    scf_changes_object.add_change({"regex": f"MRBTS-1/NRBTS-1/NRCELL-[0-9]+",
                                   "p_name": "sCellDeactivationTimerGNB", "value": "infinity"})
    scf_changes_object.add_change({'regex': 'MRBTS-1/NRBTS-1/NRCELL-5/NRREL-10', 'operation': 'delete'})
