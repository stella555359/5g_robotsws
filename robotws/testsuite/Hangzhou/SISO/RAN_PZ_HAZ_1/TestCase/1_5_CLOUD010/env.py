import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "MODEL": "askey",
        "UE_ID": "0",
        "BAND": "66",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
    },
    {
        "TYPE": "UE",
        "MODEL": "askey",
        "UE_ID": "0",
        "BAND": "5",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
    },
]


SUPPORTED_CALL = False

REQUIRE_PACKAGES = "Active"

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

RF_FACTORY_SW_STORAGE = \
    {
        "6Q175121185":
            {
                'LOGIN': 'siso',
                'PASSWORD': 'siso',
                'HOST_IP': '10.106.211.194',
                'SW_PATH': '/home/siso/LTE/Factory_SW/',
                'RRUuser': 'root',
                'RRUpassword': '',
                'IMAGE_FILE': 'FRM-rfsw-image-install_20170901151555-multi.tar',
                'checksum': '0xd516d872',
                'fileVersion': 'install_20170901151555-multi',
                'BuildName': 'FRM57.08.R03C',
                'BuildVersion': 'FRM57.08.R03C'
            }
    }

tl_config = sys.modules[__name__]
