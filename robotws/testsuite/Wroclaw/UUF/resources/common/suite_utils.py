from temporary_alarms import tl_qc_id, BRANCH_RELEASE
from vm_operations import check_hostname
from robot.libraries.BuiltIn import BuiltIn
import os
from taf.rfrl.csv4all.resources.utilities import utilities
import json


def check_qc_id_label(sw_release):
    release = "SBTS00" if sw_release == "SBTS00" else "BRANCH"
    test_name = check_test_name()
    return test_name + "_" + release


def check_test_name():
    suite_name = BuiltIn().get_variable_value('${SUITE_NAME}')
    test_name = ''
    if "UPGRADE" in suite_name.upper():
        test_name = "UPGRADE"
    elif "RESET" in suite_name.upper():
        test_name = "RESET"
    elif "NETACT" in suite_name.upper():
        bucket = check_bucket()
        if bucket:
            test_name = "NETACT" if "BUCKET_8_1" == bucket.upper() else "UPGRADE"
    return test_name


def check_bucket():
    hostname = check_hostname()
    for bucket, hostnames in tl_qc_id.items():
        if hostname in tl_qc_id[bucket]["hosts"]:
            return bucket


def check_qc_id(sw_release):
    hostname = check_hostname()
    qc_id_label = check_qc_id_label(sw_release)
    for bucket, values in tl_qc_id.items():
        if hostname in tl_qc_id[bucket]["hosts"]:
            utilities.test_logger(
                f"{bucket}: {hostname}, qc_id: {tl_qc_id[bucket][qc_id_label]}"
            )
            return tl_qc_id[bucket][qc_id_label]
    utilities.test_logger(f"The {hostname} does not have any QC_ID assigned in the tl_qc_id dictionary.")


def check_preliminary_upgrade_qc_id(sw_release):
    hostname = check_hostname()
    release = "SBTS00" if sw_release == "SBTS00" else "BRANCH"
    qc_id_label = f"UPGRADE_{release}"
    for bucket, values in tl_qc_id.items():
        if hostname in tl_qc_id[bucket]["hosts"]:
            utilities.test_logger(
                f"{bucket}: {hostname}, preliminary_upgrade_qc_id: {tl_qc_id[bucket][qc_id_label]}"
            )
            return tl_qc_id[bucket][qc_id_label]


def check_qc_project(sw_release):
    return "RAN_VRF" if sw_release == "SBTS00" or sw_release == BRANCH_RELEASE else "RAN_ST"


def check_decoupling_path():
    if os.environ.get("CM_TAGS") is None:
        raise Exception("Not Cloud Execution, Suite Will be aborted!")
    cm_tags = json.loads(os.getenv("CM_TAGS", "[]"))
    initial_5g = [tag.split("=")[1] for tag in cm_tags if "INITIAL_5G".lower() in tag.lower()]
    utilities.test_logger(f"5G initial build: {initial_5g}", "WARN")
    if not initial_5g:
        raise Exception("The INITIAL_5G tag is not set, Suite Will be aborted!")
    return initial_5g


def check_if_cm_execution():
    return False if os.environ.get("CM_EXECUTION_ID") is None else True


def check_uuf_tags():
    uuf_tags = ("UUF_CUSTOMER", "UUF_CONFIGURATION", "UPDATE_PATH", "UUF_BUILD")
    if os.environ.get("CM_TAGS"):
        cm_tags = json.loads(os.getenv("CM_TAGS", "[]"))
        return [tag.upper() for tag in cm_tags if tag.upper() in uuf_tags]


def check_username():
    if BuiltIn().get_variable_value("${TESTER_NAME}"):
        utilities.test_logger(f'SUITE_USERNAME: {BuiltIn().get_variable_value("${TESTER_NAME}")}')
        return BuiltIn().get_variable_value("${TESTER_NAME}")
    if check_if_cm_execution():
        username = os.getenv("CM_USERNAME")
        utilities.test_logger(f"CM_USERNAME: {username}")
        return username
    json_path = "/opt/ute/reservation.json"
    if os.path.exists(json_path):
        with open(json_path, 'r') as reservation_json:
            reservation_content = reservation_json.read()
            user = json.loads(reservation_content)["user"]
        utilities.test_logger(f"RESERVATION_USERNAME: {user}")
        return user


def set_username(username):
    json_path = "/opt/ute/execution.context.json"
    if os.path.exists(json_path):
        try:
            with open(json_path, 'r') as execution_context_json:
                content = json.load(execution_context_json)
            content["CM_USERNAME"] = username
            with open(json_path, 'w') as execution_context_json:
                json.dump(content, execution_context_json)
        except Exception as e:
            print(e)


def set_tester_name():
    username = check_username()
    if username:
        BuiltIn().set_suite_variable("${TESTER_NAME}", username)
    else:
        utilities.test_logger(f"Tester's name was not provided!", "WARN")


def set_rp_variables():
    BuiltIn().set_suite_variable("${RP_CA}", "VRF_OAM")
    BuiltIn().set_suite_variable("${RP_LOCATION}", "VRF_WRO3")
    BuiltIn().set_suite_variable("${RP_ORGANIZATION}", "VRF_WRO3_T03")


def set_qc_tags_and_variables_if_needed(sw_candidate):
    sw_release = sw_candidate.split("_")[0].upper()
    qc_report = BuiltIn().get_variable_value("${QC_REPORT}")
    if sw_release == BRANCH_RELEASE or sw_release == "SBTS00":
        if qc_report:
            qc_id = check_qc_id(sw_release)
            qc_project = check_qc_project(sw_release)
            if qc_id:
                utilities.test_logger(f"Setting qc variables for the execution on the {sw_release} release")
                BuiltIn().set_tags(f"QC_{qc_id}")
                BuiltIn().set_tags(f"QCP_{qc_project}")
                BuiltIn().set_tags("QCD_MN_RAN")
                BuiltIn().set_suite_variable("${TEST_QC_ID}", str(qc_id))
                BuiltIn().set_suite_variable("${QC_PROJECT}", qc_project)
                BuiltIn().set_suite_variable("${QC_DOMAIN}", "MN_RAN")
                if check_test_name() == "RESET":
                    preliminary_upgrade_qc_id = check_preliminary_upgrade_qc_id(sw_release)
                    BuiltIn().set_tags(f"PRELIMINARY_UPGRADE_QC_ID_{preliminary_upgrade_qc_id}")
                    BuiltIn().set_suite_variable("${PRELIMINARY_UPGRADE_QC_ID}", str(preliminary_upgrade_qc_id))
            else:
                utilities.test_logger(f"")
        else:
            utilities.test_logger(f"QC REPORT set to '{qc_report}'")
    else:
        if not qc_report:
            utilities.test_logger(f"QC REPORT set to '{qc_report}'")
        utilities.test_logger("It is not a trunk or main branch execution, so setting QC variables is not necessary")
