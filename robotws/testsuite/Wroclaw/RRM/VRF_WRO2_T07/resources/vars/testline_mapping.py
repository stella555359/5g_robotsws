#  Testline names mapping in WRO6 team. First keys are VM hostnames.

import socket

hostname = socket.gethostname()

TL_MAP = {
    "7-16-UTE5GCLOUDT121": {
        "testline_name": "7_16_UTE5GCLOUDT121",
        "testline_name_scout": "7_16_UTE5GCLOUDT121",
        "testline_label": "CLOUD_5G_CLASSICAL_NSA_HMD_ASIKL_ABILB1_3xAHCA_ENB",
        "owner": "lukasz.adamski@nokia.com"
    },
    "7-16-UTE5GCLOUDT119": {
        "testline_name": "7_16_UTE5GCLOUDT119",
        "testline_name_scout": "7_16_UTE5GCLOUDT119",
        "testline_label": "CLOUD_5G_CLASSICAL_SA_VIAVI_ASIBL_ABILB1_3xAHCA_ENB",
        "owner": "marcin.wolczynski@nokia.com"
    },
    "CI_MOCK": {
        "testline_name": "MOCK",
        "testline_name_scout": "MOCK",
        "testline_label": "MOCK",
        "owner": "MOCK"
    },
}

if hostname not in TL_MAP.keys():
    hostname = "CI_MOCK"

TL_NAME = TL_MAP[hostname]["testline_name"]
TL_NAME_SCOUT = TL_MAP[hostname]["testline_name_scout"]
TL_OWNER = TL_MAP[hostname]["owner"]
TL_LABEL = TL_MAP[hostname]["testline_label"]
