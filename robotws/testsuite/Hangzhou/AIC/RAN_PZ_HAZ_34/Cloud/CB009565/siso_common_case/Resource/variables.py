from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger

tl = BuiltIn().get_variable_value("${tl}")

all_gnbs = tl.gnbs
all_gnbs_detail = []
for single_gnbs in all_gnbs:
    single_cu = single_gnbs.cu
    cu_ssh_addr = single_cu.oam_ssh_connection_details.addr
    cu_ssh_username = single_cu.oam_ssh_connection_details.username
    cu_ssh_password = single_cu.oam_ssh_connection_details.password
    cu_webem_addr = single_cu.oam_http_connection_details.addr
    cu_webem_username = single_cu.oam_http_connection_details.username
    cu_webem_password = single_cu.oam_http_connection_details.password

    all_dus = single_gnbs.dus
    all_dus_detail = []
    for single_du in all_dus:
        du_webem_addr = single_du.oam_http_connection_details.addr
        du_webem_username = single_du.oam_http_connection_details.username
        du_webem_password = single_du.oam_http_connection_details.password
        single_du_detail = {
            "du_webem_addr": du_webem_addr,
            "du_webem_username": du_webem_username,
            "du_webem_password": du_webem_password,
        }
        all_dus_detail.append(single_du_detail)
    single_gnbs_detail = {
        "cu_ssh_addr": cu_ssh_addr,
        "cu_ssh_username": cu_ssh_username,
        "cu_ssh_password": cu_ssh_password,
        "cu_webem_addr": cu_webem_addr,
        "cu_webem_username": cu_webem_username,
        "cu_webem_password": cu_webem_password,
        "all_dus_detail": all_dus_detail,
    }
    rus_du = []
    for single_du in all_dus:
        ru_list = single_du.fhgws[0].rus
        rus_singledu = []
        for ru in ru_list:
            ru_info = {}
            ru_info['addr'] = ru.default_ssh_connection_details.addr
            ru_info['username'] = ru.default_ssh_connection_details.username
            ru_info['password'] = ru.default_ssh_connection_details.password
            ru_info['ru_type'] = ru.ru_hw_group
            if ru.serial_number:
                ru_info['serial_number'] = ru.serial_number
            if ru.lmp_connection:
                ru_info['ctrl_addr'] = ru.lmp_connection.addr
                ru_info['ctrl_username'] = ru.lmp_connection.username
                ru_info['ctrl_password'] = ru.lmp_connection.password
            rus_singledu.append(ru_info)
        rus_du.append(rus_singledu)
    all_gnbs_detail.append(single_gnbs_detail)

print(all_gnbs_detail)

ALLOWED_ACTIVE_FAULTS = [
    61524,  # SSH enabled
    61652,  # R&D Service Port enabled
    # 4334,  # Serial console activated
    4655,  # Service account root access is enabled
    4654,  # Ethernet port security is disabled
    4592,  # BTS Reset Cause
    4459,  # User Account has Default Password
    61649,  # LMP access via port $port
    4687,  # CPRI RU Migration to eCPRI Mode Required
    4340,  # Previously downloaded plan [planId] was overwritten by a new plan [planId]
    61074,  # CRL Update failure
    6327,  # Setup of X2 connectivity to gNB failed
    # 6506,  # SSD log storage overdraw
    4420,  # GPS receiver alarm: firmware upgrade ongoing
    4293,  # IP Traffic Capacity Limit
    4773,  # Radio unit reset triggered by peer BTS
    8000,
    49,
    4675,
    4405,
    4681
]

ALLOWED_HISTORY_FAULTS = [
    61524,  # SSH enabled
    61652,  # R&D Service Port enabled
    # 4334,  # Serial console activated
    4655,  # Service account root access is enabled
    4654,  # Ethernet port security is disabled
    4592,  # BTS Reset Cause
    4459,  # User Account has Default Password
    61649,  # LMP access via port $port
    4687,  # CPRI RU Migration to eCPRI Mode Required
    4340,  # Previously downloaded plan [planId] was overwritten by a new plan [planId]
    61074,  # CRL Update failure
    6327,  # Setup of X2 connectivity to gNB failed
    # 6506,  # SSD log storage overdraw
    4420,  # GPS receiver alarm: firmware upgrade ongoing
    4293,  # IP Traffic Capacity Limit
    4773,  # Radio unit reset triggered by peer BTS
    8000,
    49,
    4675,
    4405,
    16,
    4298,
    4681
]

LIST__SYSLOG_ERROR_allowed = [
    'grep -v "findActiveCellPosition() failed"',
    'grep -v "NOT send NetworkPlanUpdateInd!"',
    'grep -v "No active cell with nrCellId"',
    'grep -v "No valid X2 Ipaddress"',
    'grep -v "releasing index failed."',
    'grep -v "Pm Agent fails to register dataset for cplaneCaProfile1SecAgg"',
    'grep -v "Post bsr files failed"',
    'grep -v "NRCELL_L does not have beamWeightFileData set"',
    'grep -v "POST parameters failed"',
    'grep -v "Could not find ru_bp_l"',
    'grep -v "instanceId not in RmodR"',
    'grep -v "Invalid carrier operation response received from FH"',
    'grep -v "Request with expected json failed with status: 200"',
    'grep -v "rmodAId not in RmodL"',
    'grep -v "Response received for delete from FhConfig not OK or GET failed for"',
]
