from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')
bts0_id = tl.gnbs[0].dus[0].global_bts_id
du_operations = GnbDuOperations()
commissioning = GnbCommissioning()
asirmod_runtime_distname = "MRBTS-{}/EQM_R-4/APEQM_R-1/ASIRMOD_R-1".format(bts0_id)


def verify_expected_asihub_sw_version(expected_sw):
    """
    Verify asihub active SW version as expected

    :param expected_sw: dict e.g. {'ASIHUB': 'ASIHUB25.01.R01', 'ASIHUB2.0': 'ASIHUB2.0_24.12.R21'}
    """
    asirmod_params = commissioning.get_all_params_under_class_name(
        class_name="com.nokia.srbts.eqmr:ASIRMOD_R", bts_id=0, du_id=0, scf_export_type="runtimeObjects"
    )
    wrong_sw_version = [asirmod for asirmod in asirmod_params if
                        (asirmod['params']['productName'] == 'APHG' and
                         asirmod['params']['activeSwVersion'] != expected_sw['ASIHUB2.0']) or
                        (asirmod['params']['productName'] == 'APHA' and
                         asirmod['params']['activeSwVersion'] != expected_sw['ASIHUB'])]
    if wrong_sw_version:
        raise NotExpectedAsiHubSwVersion([{"Expected ASIHUB SW versions": expected_sw}, wrong_sw_version])


class NotExpectedAsiHubSwVersion(Exception):
    pass
