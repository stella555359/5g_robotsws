SW_BUILDS_DIR_PATH = "/home/ute/Downloads/SW/cloud/"

TEST_CASES_THAT_NEED_MIRROR_PACKAGES = [
    "Incompatible_RF_SW_alarm",
    "SW_update",
    "SW Download"
]

STARTUP = {
    'SITE_RESET': {
        'AirScale': {
            'SBTS23R2': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS23R3': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS23R4': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS24R1': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS22R2': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS22R3': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS22R4': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS23R1': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS00': {'3': 194, '6': 234, '15': 320, '36': 380},
            '5G21B': {'3': 194, '6': 234, '15': 320, '36': 380},
            '5G20A': {'3': 194, '6': 234, '15': 320, '36': 380},
            '5G20B': {'3': 194, '6': 234, '15': 320, '36': 380},
            '5G21A': {'3': 194, '6': 234, '15': 320, '36': 380}},
        'FSMr3': {
            'SBTS23R2': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS23R3': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS23R4': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS24R1': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS22R2': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS22R3': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS22R4': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS23R1': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS00': {'3': 194, '6': 234, '15': 320, '36': 380},
            '5G20B': {'3': 194, '6': 234, '15': 320, '36': 380},
            '5G21A': {'3': 194, '6': 234, '15': 320, '36': 380},
            '5G20A': {'3': 194, '6': 234, '15': 320, '36': 380}},
    },
    'POWER_RESET': {
        'AirScale': {
            'SBTS23R2': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS23R3': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS23R4': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS24R1': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS22R2': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS22R3': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS22R4': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS23R1': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS00': {'3': 194, '6': 234, '15': 320, '36': 380},
            '5G21B': {'3': 194, '6': 234, '15': 320, '36': 380},
            '5G20A': {'3': 194, '6': 234, '15': 320, '36': 380},
            '5G20B': {'3': 194, '6': 234, '15': 320, '36': 380},
            '5G21A': {'3': 194, '6': 234, '15': 320, '36': 380},
        },
        'FSMr3': {
            'SBTS23R2': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS23R3': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS23R4': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS24R1': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS22R2': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS22R3': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS22R4': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS23R1': {'3': 194, '6': 234, '15': 320, '36': 380},
            'SBTS00': {'3': 194, '6': 234, '15': 320, '36': 380}}},
    'CELL': 120,
    'RF': {
        'STND': 150,
        'MAA': 240},
    'RECOVERY_MODE': 15,
    'CHAIN_RADIO': 60,
    'DETECTION_TIME': {
        'standard': 600,
        'recommissioning': 1000,
        'sw_upgrade': 1600,
        'hw': 1200,
    }
}

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

ALARM_SCHEME = {
    '10'
    '23'
    '48'
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
    "wojciech.bodzek@nokia.com",
]

OPTICAL_SWITCHES_MATRIX = {
    '10x2': 'mol 10x(1x2)',
    '10x4': 'mol 12x(2x12)',
    '5x3': 'mol 5x(2x6)',
    '5x4': 'mol 5x(2x6)',
    '6x4': 'mol 6x(2x6)',
    '6x3': 'mol 6x(2x6)',
}
