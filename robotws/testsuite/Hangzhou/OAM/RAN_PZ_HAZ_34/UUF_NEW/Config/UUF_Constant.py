# PUBLIC_ACCOUNT = 'ca_5Gauto'
# PUBLIC_PASSWORD = 'AKCp5bBh9XG9iCkcCJLwt6CHuVdgHPyJVAuB7V6vSHfet7X6ZXfjZRqEMLxn36rfqRfhoQzKc'
PUBLIC_ACCOUNT = 'to5gran'
PUBLIC_PASSWORD = 'Compass20250601'


Recovery_Action_Active_Fault_Keyword = {
    16: ["Recovery Action Reset RU"],
    23: ["Recovery Action Upgrade Current Software"],
    # 1850: ["Recovery Action Upgrade Current Software"],
    1850: ["Recovery Action Wait Auto Upgrade", "Recovery Action Upgrade Current Software"],
    4082: ["Recovery Action Clear FallBack Fault"],
    4083: ["Recovery Action Clear FallBack Fault"],
    4085: ["Recovery Action Clear FallBack Fault"],
    1900: ["Recovery Action Reset RU"],
    1920: ["Recovery Action Reset RU"],
    6450: ["Recovery Action Catch Snapshot"],
    # "others": ["Recovery Action Reset Site"],
}

Active_Fault_Sequence = [
    4082, 4083, 4085,
    23, 1850,
    16, 1900, 1920,
    6450,
]

Recovery_Action_Final = [
    "Recovery Action Reset Site"
]


Log_Collection_Category = {
    "gnb_log": ["gnb_snapshot", "gnb_syslog"],
    "enb_log": ["enb_snapshot", "enb_syslog"],
    "ru_log": ["ru_general_log", "ru_serial_log", "ru_syslog"],
    "snapshot": ["gnb_snapshot", "enb_snapshot"],
    "syslog": ["gnb_syslog", "enb_syslog", "ru_syslog"],
    "async": ["async_alarm_snapshot"],
}


Log_Collection_Type = [
    "passlog",
    "gnb_snapshot",
    "gnb_syslog",
    "enb_snapshot",
    "enb_syslog",
    "ru_general_log",
    "ru_serial_log",
    "ru_syslog",
    "async_alarm_snapshot",
    "check_error_snapshot",
]


Check_Point_Type = [
    # upgraded testline check
    "wait_for_minutes",
    "sw_version",
    "sw_upgrade_downtime",
    "validate_error",
    "nms_status",
    "amf_status",
    "pm_report",
    "blackbox",
    "syslog_error",

    # netact operations
    "netact_operations",
    "cm_upload",
    "cm_provision",
    "fm_auto_upload",
    "fm_manual_upload",
    "swm_upload",

    # all testline check
    "cell_status",
    "hardware_status",
    "cablink_status",
    "active_faults",
    "history_faults",
    "power_meter",

]


Default_LMI_ON_RU = [
    "AHBCC",
    "AEQE",
    "AEQP",
    "AEQD"
]


REL7_RU_LIST = [
    "AVQE",
    "AVQL",
    "AVQC",
    "AVQQ",
    "AVQQA",
    "AVHA",
]


MADE2_RU_TYPE = [
    "AQQL",
    "AQQK",
    "AQQY"
]


REL5_RU_LIST = [
    "AHFII",
    "AHBCC",
    "AHPE",
    "AHLOA",
    "AHFIB",
    "AHFIG",
    "AHPB",
    "AHEH",
    "AHLOB",
]


Downtime_With_Different_Config = {
    'SBTS21B': 1080,
    'SBTS22R1': 1008,
    'SBTS22R2': 1008,
    'SBTS22R3': 1200,
    'SBTS22R4': 1200,
    'SBTS23R1': 1230,
    'SBTS23R2': 1230,
    'SBTS23R3': 1230,
    'SBTS23R4': 1380,
    'SBTS24R1': 1440,
    'SBTS24R2': 1440,
    'SBTS00': 1440,
}


OldFault4592_System_Module = [
    # ASIK RESET REASON IS SAME AS OUTDOOR, not support in 24R3 CB007964 as there is no FPGA support
    "ASOE",  # 26R1 CNI-132211 - for ASOE/ASOF
    "ASOF",  # 26R1 CNI-132211 - for ASOE/ASOF
    "ASIK",
]


NewFault4592_System_Module = [
    "ASIL",
    "ASIM",
    "ASIB",
    "ASIA",
    "ASOG",  # 25R2 CNI-135218 - for ASOG/ASOH
    "ASOH",  # 25R2 CNI-135218 - for ASOG/ASOH
]


Fault4589_Check_List = [
    "AVQC",
    "AVQQ",
    "AVHA",
]


# RU_GW_IP = {
#     '192.168.100.100': 'ccsShell.sh rad -pw 0x10042 0xC0A86464',
#     '192.168.100.200': 'ccsShell.sh rad -pw 0x10042 0xC0A864C8',
#     '192.168.101.100': 'ccsShell.sh rad -pw 0x10042 0xC0A86564',
#     '192.168.101.200': 'ccsShell.sh rad -pw 0x10042 0xC0A865C8',
#     '192.168.100.10': 'ccsShell.sh rad -pw 0x10042 0xC0A8640A',
# }

RU_LOGIN_PROMPT = {
    "AEHC": "stratix10-aehb login:",
    "AZHL": "stratix10-azqp login:",
    "AZQS": "stratix10-azqp login:",
    "AZQP": "stratix10-azqp login:",
    "AVQL": "simics-mars login:",
    "AVQE": "simics-mars login:",
    "AVQQ": "simics-mars login:",
    "AVQQA": "simics-mars login:",
    "AHFII": "made2 login:",
    "AHLOB": "made2 login:",
    "AQQQA": "ct-zynqmp login:",
    "AQQQ": "ct-zynqmp login:",
    "AQQL": "ct-zynqmp login:",
    "AEQY": "stratix10-aeqb login:",
    "AEQN": "stratix10-aeqn login:",
}
