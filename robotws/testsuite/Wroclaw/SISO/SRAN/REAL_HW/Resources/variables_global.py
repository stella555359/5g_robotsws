SW_BUILDS_DIR_PATH = "/home/ute/Downloads/SW/"
SETUP_CHECK_ONAIR_STATE_TIMEOUT = 200
SETUP_CHECK_4001_ALARM_AFTER_SWUPDATE_TIMEOUT = 120
CONFIGURATION_STARTUP_TIMEOUT = 360
BBMOD_STARTUP_TIMEOUT = 200
LTE_RAT_RESET_TIMEOUT = 180
NR_RAT_RESET_TIMEOUT = 180
CONFIGURATION_SWUPDATE_TIMEOUT = 1200
RESET_CONFIGURATION_STARTUP_TIMEOUT = 600
FID_4590_TIMEOUT = 360
BASIC_ADMIN_PROCEDURES_TIMEOUT = 60
FAULT_10_TIMEOUT = 200
RADIO_AVAILABILITY_TIMEOUT = 350
GLOBAL_TOPOLOGY_CONFIGS_REPOSITORY = '/home/ute/testline_init_results/execution/configs/topology_configs'

MARVIN_ORGANIZATION = 'VRF_WRO4'
MARVIN_SITE = 'dev'

SW_UPGRADE_PATH = {
    'SBTS23R2': 'SBTS23R1',
    'SBTS23R3': 'SBTS23R2',
    'SBTS23R4': 'SBTS23R3',
    'SBTS24R1': 'SBTS23R4',
    'SBTS22R2': 'SBTS22R1',
    'SBTS22R3': 'SBTS22R2',
    'SBTS22R4': 'SBTS22R3',
    'SBTS23R1': 'SBTS22R4',
    'SBTS00': 'SBTS23R4'
}

RF_POWER_LEVEL_CONVERSIONS = {
    'UHFE': {'MIN': 30.0, 'MAX': 46.5, 'TxGainSupport': True},
    'UDIA': {'MIN': 00.1, 'MAX': 19.0, 'TxGainSupport': True},
    'UHFC': {'MIN': 30.0, 'MAX': 46.0, 'TxGainSupport': True},
    'UHFA': {'MIN': 28.8, 'MAX': 47.8, 'TxGainSupport': True},
    'UHMA': {'MIN': 30.0, 'MAX': 46.0, 'TxGainSupport': True},
    'FRIG': {'MIN': 36.0, 'MAX': 47.8, 'TxGainSupport': False},
    'AZRB': {'MIN': 14.0, 'MAX': 27.0, 'TxGainSupport': False},
    'UHHB': {'MIN': 30.0, 'MAX': 46.0, 'TxGainSupport': True}
}
# Based on https://nokia.sharepoint.com/sites/uuf4all/SitePages/Stop&Fix-for-Truck-Roll.aspx
TRUCK_ROLL_FID_LIST = [
    10,
    1806,
    4341,
    4352,
    4383
]

TRUCK_ROLL_RECIPIENTS_LIST = [
    "I_SRAN_PROD_SISO_WRO_CRT1@internal.nsn.com",
    "I_SRAN_PROD_SISO_WRO_CRT2@internal.nsn.com",
    "I_SRAN_PROD_SISO_WRO_CRT3@internal.nsn.com",
    "I_SRAN_PROD_SISO_WRO_CRTDEV@internal.nsn.com",
    "I_SRAN_PROD_SISO_WRO_CRTM@internal.nsn.com"
]

TRUCK_ROLL_CM_MAINTAINERS_LIST = [
    "piotr.baranowski@nokia.com",
    "hubert.nowakowski@nokia.com",
    "kamil.malecki@nokia.com",
    "patrycjusz.jablonski@nokia.com",
    "anna.plecha@nokia.com",
    "karol.bielenny@nokia.com",
    "mateusz.chryplewicz@nokia.com",
    "malgorzata.ficek@nokia.com",
    "tomasz.lojewski@nokia.com",
    "paulina.ryzner@nokia.com",
    "ewa.pyrka@nokia.com",
    "krzysztof.harupa@nokia.com",
    "tomasz.pawlaczyk@nokia.com",
    "dariusz.wojarski@nokia.com",
    "krzysztof.pekala@nokia.com",
    "artur.kaczybura@nokia.com",
    "katarzyna.zacharuk@nokia.com",
    "karol.biernat@nokia.com",
    "jakub.mortka@nokia.com",
    "jedrzej.grzelak@nokia.com",
    "przemyslaw.kempa@nokia.com",
    "slawomir.jastrzebski@nokia.com",
    "piotr.korczynski@nokia.com",
    "anna.maciejewska@nokia.com",
    "daniel.bartkowiak@nokia.com",
    "mateusz.kawka@nokia.com",
    "szymon.natanek@nokia.com",
    "malgorzata.piecyk-celuch@nokia.com",
    "krzysztof.malolepszy@nokia.com",
    "izabela.wencel@nokia.com",
    "dominika.1.wojcik@nokia.com",
    "aleksandra.zalewska@nokia.com",
]

# alarm resource for KW "FM Await For Fault" from FM_Faults.robot

FAULT_10 = [
    "7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION",
    "7115 BASE STATION INFORMATION",
    "7116 BASE STATION SERVICE PROBLEM",
    "7650 BASE STATION FAULTY",
    "7651 BASE STATION OPERATION DEGRADED",
    "7652 BASE STATION NOTIFICATION",
    "7653 CELL FAULTY",
    "7654 CELL OPERATION DEGRADED",
]

FAULT_49 = [
    "7102 BASE STATION RESOURCE BLOCKED BY USER",
    "7653 CELL FAULTY",
]

FAULT_1868 = [
    "7114 CELL SERVICE PROBLEM",
    "7653 CELL FAULTY",
]

FAULT_2087 = [
    "7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION",
    "7115 BASE STATION INFORMATION",
    "7116 BASE STATION SERVICE PROBLEM",
    "7650 BASE STATION FAULTY",
    "7651 BASE STATION OPERATION DEGRADED",
    "7652 BASE STATION NOTIFICATION",
    "7653 CELL FAULTY",
]

FAULT_4141 = [
    "7113 BASE STATION ANTENNA LINE PROBLEM",
    "7115 BASE STATION INFORMATION",
    "7652 BASE STATION NOTIFICATION",
    "7654 CELL OPERATION DEGRADED",
]

FAULT_4142 = [
    "7113 BASE STATION ANTENNA LINE PROBLEM",
    "7115 BASE STATION INFORMATION",
    "7652 BASE STATION NOTIFICATION",
    "7654 CELL OPERATION DEGRADED",
]

FAULT_4569_4588 = [
    "7115 BASE STATION INFORMATION",
    "7652 BASE STATION NOTIFICATION",
    "7655 CELL NOTIFICATION",
]

FAULT_1937 = [
    "7115 BASE STATION INFORMATION",
    "7116 BASE STATION SERVICE PROBLEM",
    "7652 BASE STATION NOTIFICATION",
    "7653 CELL FAULTY",
    "7654 CELL OPERATION DEGRADED",
]

FAULT_1927 = [
    "7115 BASE STATION INFORMATION",
    "7116 BASE STATION SERVICE PROBLEM",
    "7652 BASE STATION NOTIFICATION",
    "7654 CELL OPERATION DEGRADED",
    "7655 CELL NOTIFICATION",
]

FAULT_1938 = [
    "7115 BASE STATION INFORMATION",
    "7116 BASE STATION SERVICE PROBLEM",
    "7652 BASE STATION NOTIFICATION",
    "7653 CELL FAULTY",
    "7654 CELL OPERATION DEGRADED",
]

FAULT_4003 = [
    "7115 BASE STATION INFORMATION",
    "7655 CELL NOTIFICATION",
]

FAULT_1972 = [
    "7115 BASE STATION INFORMATION",
    "7652 BASE STATION NOTIFICATION",
    "7655 CELL NOTIFICATION",
]

FAULT_4656 = [
    "7100 BASE STATION HARDWARE PROBLEM",
    "7651 BASE STATION OPERATION DEGRADED",
]

FAULT_6921 = [
    "7100 BASE STATION HARDWARE PROBLEM",
    "7115 BASE STATION INFORMATION",
    "7652 BASE STATION NOTIFICATION",
    "7653 CELL FAULTY",
    "7654 CELL OPERATION DEGRADED",
]

FAULT_4699 = [
    "7100 BASE STATION HARDWARE PROBLEM",
    "7115 BASE STATION INFORMATION",
    "7652 BASE STATION NOTIFICATION",
    "7654 CELL OPERATION DEGRADED",
    "7655 CELL NOTIFICATION",
]

FAULT_4700 = [
    "7100 BASE STATION HARDWARE PROBLEM",
    "7115 BASE STATION INFORMATION",
    "7652 BASE STATION NOTIFICATION",
    "7654 CELL OPERATION DEGRADED",
    "7655 CELL NOTIFICATION",
]

FAULT_4701 = [
    "7100 BASE STATION HARDWARE PROBLEM",
    "7115 BASE STATION INFORMATION",
    "7652 BASE STATION NOTIFICATION",
    "7654 CELL OPERATION DEGRADED",
    "7655 CELL NOTIFICATION",
]

FAULT_6450 = [
    "7115 BASE STATION INFORMATION",
    "7652 BASE STATION NOTIFICATION",
]

# alarm resource END

KPIs = {
    'kpi54a': {'description': 'Power-on RU startup availability. RU power on <-> Last cell up',
               'unit': 's', 'category': 'Performance', 'kpi_type': 'None'},
    'kpi54b': {'description': 'Power-on RU startup availability. RU power on <-> First cell up',
               'unit': 's', 'category': 'Performance', 'kpi_type': 'None'},
    'kpi3': {'description': 'Power-On BTS Startup. Start Point: BTS Power ON End Point: First Cell Up',
             'unit': 's', 'category': 'Performance', 'kpi_type': 'None'}
}
