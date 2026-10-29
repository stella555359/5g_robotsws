# copyright: Nokia 5G RAN
# Contact: I_MN_5G_RAN_IV4_LINE_HZG_7_IV@internal.nsn.com
DICT__blackbox_name_basic = {
    'ASIA': '',
    'ASIK': '',
    'ASIM': 'Timestamp|ram|bootImage|runtimeImage',
    'ASOE': 'Timestamp|ram|i2c|mdio|socEth',
    'ASOF': 'Timestamp|ram|i2c|mdio|socEth',
    'ASOG': 'Timestamp|ram|bootImage|crtm|BootFlash',
    'ASOH': 'Timestamp|ram|bootImage|crtm|BootFlash',
    'ASIL': '',
    'ASIB': '',
    'ABIL': '',
    'ABIP': 'Timestamp|ram|bootImage',
    'ABIQ': 'Timestamp|ram|bootImage',
    'ABIN': '',
    'ABIO': '',
}

DICT__blackbox_name_extended = {
    'ASIA': '',
    'ASIK': '',
    'ASIM': 'Timestamp|ram|mdio|spi|pcie|BootFlashVisibility',
    'ASOE': 'Timestamp|ram|runtimeImage',
    'ASOF': 'Timestamp|ram|i2c|mdio|socEth',
    'ASOG': 'Timestamp|ram|spi|pcie|BootFlashVisibility',
    'ASOH': 'Timestamp|ram|spi|pcie|BootFlashVisibility',
    'ASIL': '',
    'ASIB': '',
    'ABIL': '',
    'ABIP': 'Timestamp|ram|spi|pcie|BootFlashVisibility',
    'ABIQ': 'Timestamp|ram|pcie|BootFlashVisibility',
    'ABIN': '',
    'ABIO': '',
}

DICT__BBMOD_TL = {
    '845': ['2']
}

LIST__BBPlatform_ignore = {'ABIC', 'ABIA'}
LIST__L1BB_ignore = {'ABIL'}
LIST__L1_2file_product = {'ABIO', 'ASOE', 'ASOF'}
LIST__BB_2file_product = {'ABIL', 'ASIK'}
LIST__RMOD_ignore = {'AWHHF', 'AWHHK', 'AEQN', 'AWHQE'}
LIST__BB_timestamp_ingore = {'ABIL'}
