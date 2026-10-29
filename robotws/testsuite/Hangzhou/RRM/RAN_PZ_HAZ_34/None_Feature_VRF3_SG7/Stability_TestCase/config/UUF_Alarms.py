from UUF_Constant import *


Trunk_Roll_Fault_List = [
    10,
    1806,
    4341,
    4352,
    4383,
]


ALLOWED_ACTIVE_FAULTS_PREPARE = [
    4681,  # Sanity Check Error
    4652,  # Independent SW upgrade for shared RU unaligned between BTSs
]


SERIAL_CONSOLE_ACTIVE_FAULTS = [
    4334,  # Serial console activated
]


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
]
ALLOWED_HISTORY_FAULTS = [
    61524,  # SSH enabled
    61652,  # R&D Service Port enabled
    4334,  # Serial console activated
    4655,  # Service account root access is enabled
    4654,  # Ethernet port security is disabled
    4592,  # BTS Reset Cause
    4459,  # User Account has Default Password
    61649,  # LMP access via port $port
    4687,  # CPRI RU Migration to eCPRI Mode Required
    4340,  # Previously downloaded plan [planId] was overwritten by a new plan [planId]
    61074,  # CRL Update failure
    6327,  # Setup of X2 connectivity to gNB failed
    7107,  # Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    7300,  # No X2 link available
    7319,  # No X2 link available for a specific LTEENB
    1936,  # Unit (module) temperature is high
    4420,  # GPS receiver alarm: firmware upgrade ongoing
    # 6506,  # SSD log storage overdraw
    4293,  # IP Traffic Capacity Limit
]


DSS_ACTIVE_FAULTS = []
DSS_HISTORY_FAULTS = [
    62003,  # Transport layer connection lost in XP interface
    7508,  # EN DSS Setup Failure - Max EN DSS Counter Value reached - No DSS Partner Cell
    7509,  # EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM
    7511,  # EN DSS Keep Alive Procedure Time out
    7513,  # EN DSS De-activated on partner side

    # Enb
    6134,  # EN DSS De-activated on partner side
    6129,  # EN DSS Setup Failure - Max EN DSS Counter Value reached - No DSS Partner Cell
]


CONCURRENT_ALLOWED_ACTIVE_FAULTS = []
CONCURRENT_ALLOWED_HISTORY_FAULTS = [
    10,  # No connection to unit
    1898,  # PPS reference missing
    4298,  # ToP reference missing
    4452,  # Phase error exceeds the interference limit
    16,  # Unit synchronization failed
    4405,  # No usable time reference available
    4220,  # Radio slave has taken temporary radio master role
    4530,  # TD-LTE radio disabled
]

MORAN_ALLOWED_ACTIVE_FAULTS = [
    4651,  # Active RF SW in newer version not aligned with any BTS
]
MORAN_ALLOWED_HISTORY_FAULTS = [
    4651,  # Active RF SW in newer version not aligned with any BTS
    10,  # No connection to unit
    1898,  # PPS reference missing
    4298,  # ToP reference missing
    4452,  # Phase error exceeds the interference limit
    16,  # Unit synchronization failed
    4220,  # Radio slave has taken temporary radio master role
]


RU_ALLOWED_ACTIVE_FAULTS = {
    # 1234: ["AEQN", "XXXX"],
    # 5678: ["XXXX"]
}
RU_ALLOWED_HISTORY_FAULTS = {
    1815: REL5_RU_LIST,
    # 1234: ["AEQN", "XXXX"],
    # 5678: ["XXXX"]
}


SOFTWARE_NOT_RESET_ALLOWED_ACTIVE_FAULTS = [
    4681,
]
SOFTWARE_NOT_RESET_ALLOWED_HISTORY_FAULTS = [
    23,
]


RU_NOT_DETECTED_ACTIVE_FAULTS = [
    10,  # No connection to unit
    23,  # Incompatible SW version detected
    1850,  # SW corrupted
    1900,  # RF module configuring failed
    1907,  # TX out of order
    1920,  # No feedback signal
]
CELL_NOT_ONAIR_ACTIVE_FAULTS = RU_NOT_DETECTED_ACTIVE_FAULTS + [

]
