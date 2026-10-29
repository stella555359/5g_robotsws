from taf.ul.alarms_watchdog import Alarm
import socket
import re
import os


service_account_root_access_enabled = Alarm(fault_id="4655")
lmp_access_via_port_443 = Alarm(fault_id="61649")
ethernet_port_security_disabled = Alarm(fault_id="4654")
ssh_enabled = Alarm(fault_id="61524")
rd_service_port_enabled = Alarm(fault_id="61652")
certificates = Alarm(fault_id="61510")
topp = Alarm(fault_id="4298")
xn_link = Alarm(fault_id="7307")
x2_link = Alarm(fault_id="7324")
cert1 = Alarm(fault_id="61618")
cert2 = Alarm(fault_id="61011")
mfbi = Alarm(fault_id="6278")
third_part = Alarm(fault_id="8000")
x2_transport = Alarm(fault_id="7308")
revoked = Alarm(fault_id="61074")
response_pki = Alarm(fault_id="61510")
failure_3rd_party_tool = Alarm(fault_id="8000")
x2_inter = Alarm(fault_id="4291")
failure_internal_3rd_part_tool = Alarm(fault_id="6261")

tl_specific_variables = {
    "7_16_UTE5G281": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
            certificates,
            topp,
            xn_link,
            mfbi,
            third_part,
            x2_transport,
            revoked,
            response_pki,
            failure_3rd_party_tool,
            x2_inter,

        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
            certificates,
            topp,
            xn_link,
            mfbi,
            third_part,
            x2_transport,
            revoked,
            response_pki,
            failure_3rd_party_tool,
            x2_inter,

        ],
        "CUSTOM_ALLOWED_ALARMS_4G": [
            certificates,
            topp,
            x2_link,
            cert1,
            cert2,
            mfbi,
            third_part,
            x2_transport,
            revoked,
            response_pki,
            failure_3rd_party_tool,
            x2_inter,

        ],
        "CUSTOM_ALLOWED_ALARMS_5G": [
            certificates,
            topp,
            x2_link,
            cert1,
            cert2,
            mfbi,
            third_part,
            x2_transport,
            revoked,
            response_pki,
            failure_3rd_party_tool,
            x2_inter,

        ]
    },
    "7_16_UTE5G282": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
            failure_internal_3rd_part_tool,

        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
            failure_internal_3rd_part_tool,

        ],
        "CUSTOM_ALLOWED_ALARMS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
            failure_internal_3rd_part_tool,

        ],
        "CUSTOM_ALLOWED_ALARMS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
            failure_internal_3rd_part_tool,

        ]
    },
    "7_16_UTE5G108": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "CUSTOM_ALLOWED_ALARMS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "CUSTOM_ALLOWED_ALARMS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ]
    },
    "7_16_UTE5G280": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
            response_pki,
            mfbi,
            failure_3rd_party_tool,
            x2_inter,
            revoked,

        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
            response_pki,
            mfbi,
            failure_3rd_party_tool,
            x2_inter,

        ],
        "CUSTOM_ALLOWED_ALARMS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
            response_pki,
            mfbi,
            failure_3rd_party_tool,
            x2_inter,
            revoked,

        ],
        "CUSTOM_ALLOWED_ALARMS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
            response_pki,
            mfbi,
            failure_3rd_party_tool,
            x2_inter,
            revoked,

        ]
    },
    "7_16_UTE5G278": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "CUSTOM_ALLOWED_ALARMS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "CUSTOM_ALLOWED_ALARMS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
        ]
    },
    "7_16_UTE5G169": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "CUSTOM_ALLOWED_ALARMS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "CUSTOM_ALLOWED_ALARMS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
        ]
    },
    "7_16_UTE5G107": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "CUSTOM_ALLOWED_ALARMS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "CUSTOM_ALLOWED_ALARMS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
        ]
    },
    "7_16_UTE5G313": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "CUSTOM_ALLOWED_ALARMS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "CUSTOM_ALLOWED_ALARMS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
        ]
    },
    "7_16_UTE5G106": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "CUSTOM_ALLOWED_ALARMS_4G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,

        ],
        "CUSTOM_ALLOWED_ALARMS_5G": [
            service_account_root_access_enabled,
            lmp_access_via_port_443,
            ethernet_port_security_disabled,
            ssh_enabled,
            rd_service_port_enabled,
        ]
    },
}


def check_hostname():
    host = socket.gethostname().replace("-", "_")
    return host[0: -2] if re.search(r"_\d$", host) else host


def check_if_file_exist(path_to_file):
    return os.path.isfile(path_to_file)


def find_path():
    hostname = check_hostname()
    return f"/home/ute/testline_configuration/{hostname}"


def check_if_mumin_file():
    return f"{find_path()}/mumin.yaml" if check_if_file_exist(f"{find_path()}/mumin.yaml") else None


def init_path():
    return f"{find_path()}/__init__.py" if check_if_file_exist(f"{find_path()}/__init__.py") else None


def check_if_cm_execution():
    return False if os.environ.get("CM_EXECUTION_ID") is None else True


def init_path():
    return f"{find_path()}/__init__.py" if check_if_file_exist(f"{find_path()}/__init__.py") else None
