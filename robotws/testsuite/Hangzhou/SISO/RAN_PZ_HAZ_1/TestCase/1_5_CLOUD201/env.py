import sys

UE_INFO = [
    {
        "TYPE": "SISO_UE",
        "MODEL": "AT_simcom",
        "UE_ID": "0",
        "BAND": "41",
        "NETWORK_TYPE": "4G,SA",
        "STATUS": "Enabled",
        "RESET":  "TRUE",
        # "ALL_CELL_BARRED": "True",
    },
]

# This dict is used for case "SWDL For Incompatible Load SW RRU", Other cases don't need this dict.
RF_INCOMPATIBLE_SW_STORAGE = {
    '6Q181710303': {
        'LOGIN': 'siso',
        'PASSWORD': 'siso',
        'HOST_IP': '10.106.211.194',
        'SW_PATH': '/home/siso/LTE/Factory_SW/',
        'RRUuser': 'root',
        'RRUpassword': '',
        'IMAGE_FILE_23R2': 'FRM-rfsw-image-install_20230316151252-multi.tar',
        'IMAGE_FILE_23R1': 'FRM-rfsw-image-install_20230104150549-multi.tar',
        'IMAGE_FILE_22R4': 'FRM-rfsw-image-install_20230125164106-multi.tar',
        'checksum_23R2': '0xdaecbc67',
        'checksum_23R1': '0x50e9fc2b',
        'checksum_22R4': '0x219219b1',
        'fileVersion_23R2': 'install_20230316151252-multi',
        'fileVersion_23R1': 'install_20230104150549-multi',
        'fileVersion_22R4': 'install_20230125164106-multi',
        'BuildName_23R2': 'RF.FRM5.23R2.20230316.005',
        'BuildVersion_23R2': 'RF.FRM5.23R2.20230316.005',
        'BuildName_23R1': 'RF.FRM5.23R1.20230104.001',
        'BuildVersion_23R1': 'RF.FRM5.23R1.20230104.001',
        'BuildName_22R4': 'RF.FRM5.22R4.20230125.002',
        'BuildVersion_22R4': 'RF.FRM5.22R4.20230125.002',
    },
}

tl_config = sys.modules[__name__]
