from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils import taf_ue
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name, \
    wait_for_online_state, load_scf, _validate_path
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.CB009142.resources.test_specific_keywords_9142 import (
    resolve_custom_scf_path,
)
from testsuite.Wroclaw.RRM.resources.decorators import logged_keyword


@logged_keyword
def verify_tput_15316(ue1):
    taf_ue.check_data_transfer_is_alive(dt_name=f'{ue1}_DT_DL')


@logged_keyword
def upload_scf_15316(testcase, config_dir=None, skip_relation_errors=False):
    if config_dir is None:
        config_dir = _validate_path("{}/testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB015316/custom_scf".
                                    format(robot_globals.execdir()))
    load_scf(scf_path=resolve_custom_scf_path(testcase, config_dir), skip_relation_errors=skip_relation_errors)


@logged_keyword
def get_counters_for_cell_id(counters, cellId='301', ammount_of_collected_counters=24):
    cell_counters = counters['M55308C11002'][cellId]
    return cell_counters


@logged_keyword
def Compare_Feature_on_Feature_off(featureoff, featureon, iterationAmmount):
    iterationAmmount = int(iterationAmmount)

    featureoff = featureoff[-iterationAmmount:]
    featureon = featureon[-iterationAmmount:]

    featureoff_filtered = [x for x in featureoff if x != 0]
    featureon_filtered = [x for x in featureon if x != 0]

    if not featureoff_filtered or not featureon_filtered:
        raise ValueError("One of list is empty")

    Average_feature_off = sum(featureoff_filtered) / len(featureoff_filtered)
    Average_feature_on = sum(featureon_filtered) / len(featureon_filtered)

    blog("average for feature off", Average_feature_off)
    blog("average for feature on", Average_feature_on)

    assert Average_feature_off < Average_feature_on, (
        f"Avg feature_off ({Average_feature_off}) is higher than feature_on ({Average_feature_on})"
    )
