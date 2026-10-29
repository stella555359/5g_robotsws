import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

CASE_INPUT_5GC001543 = {
    "SectionGNB": {
        "MRBTS": "MRBTS-19605",
        "NRBTS": "NRBTS-19605",
        "MRBTS_1": "MRBTS-350",
    },
    "SectionNETACT": {
        "HZ_NETACT_INFO": {
            "HZ_NETACT_URL": "https://shanxilbwas.sui6.srnhz.nsn-rdnet.net",
            "HZ_NETACT_USER": "omc",
            "HZ_NETACT_PASSWORD": "Nokia126_",
        },
        "CMSERVER_INFO": {
            "CMSERVERIP": "10.110.144.140",
            "CMSERVERUSER": "root",
            "CMSERVERPWD": "arthur",
        },
    },
}
CASE_INPUT_5GC000092 = {
    "FDSWNEW": "LN_WN_FDSW21C_0000_000028_000000",
    "FDSWOLD": "LN_WN_FDSW18A_0000_100164_000000",
    "IPSECSERVER_INFO": {
        "IPSECSERVERIP": "10.57.143.155",
        "IPSECUSER": "admin",
        "IPSECPASSWD": "admin",
    },
    "SectionGNB": {
        "MRBTS": "MRBTS-1975",
        "NRBTS": "NRBTS-1975",
        "MRBTS_1": "MRBTS-350",
        "BTSMED": "FALSE",
        "BOARD": "ASIK",
        "SN": "L1182708275",
    },
    "SectionNETACT": {
        "SWMSERVERIP": "10.110.144.140",
        "HZ_NETACT_INFO": {
            "HZ_NETACT_URL": "https://shanxilbwas.sui6.srnhz.nsn-rdnet.net",
            "HZ_NETACT_USER": "omc",
            "HZ_NETACT_PASSWORD": "Nokia126_",
        },
        "CMSERVER_INFO": {
            "CMSERVERIP": "10.110.144.140",
            "CMSERVERUSER": "root",
            "CMSERVERPWD": "arthur",
        },
        "NetActName": {"shanxi"},
        "MR": {
            "$maintenanceRegionId": "5GSC-HZ",
            "$maintenanceRegionCId": "5GSC-HZ",
        },
    },
    "5GC000092_NCF": {
        "protocol": "NE3S",
        "ipv4": {
            "primary_ip_address": "10.57.251.189",
            "primary_prefix_length": "29",
            "primary_gateway": "10.57.251.185",
            "identification_entity_ip_address": "10.110.144.153",
        },
        "ipv4CATLS": {
            "CMPServer": "10.57.167.7",
            "CMPPort": "8080",
            "CMPSubject": "DC=cmp, O=nokia, OU=ivtrans, CN=IPsecTest",
            "CMPDir": "pkix/",
            "VNPGateway": "10.57.251.178",
        },
        "ipv6": {
            "primary_ip_address": "2a00:8a00:8000:136:10:57:251:103",
            "primary_prefix_length": "125",
            "primary_gateway": "2a00:8a00:8000:136:10:57:251:101",
            "identification_entity_ip_address": "2a00:8a00:8000:163::1240",
        },
        "ipv6CATLS": {
            "CMPServer": "2a00:8a00:8000:136:10:57:167:7",
            "CMPPort": "8080",
            "CMPSubject": "DC=cmp, O=nokia, OU=ivtrans, CN=IPsecTest",
            "CMPDir": "pkix/",
            "VNPGateway": "2a00:8a00:8000:136:10:57:251:ba",
        },
    },
}
prefix_of_release = "5G_"

CASE_INPUT_5GC002479 = {
    "TLConfiguration": "1ASIK_3ABIL_TDD",
    "StreamPrefix": "SBTS00_ENB_9999",
    # 'NETACT_URL':'https://na20lbwas.qin1.srnhz.nsn-rdnet.net',
    "NETACT_URL": "https://shanxilbwas.sui6.srnhz.nsn-rdnet.net",
    "NETACT_USER": "omc",
    # 'NETACT_PASSWORD':'Nokia123!',
    "NETACT_PASSWORD": "Nokia126_",
    # 'NETACT_LOGSERVER_IP':'10.107.178.201',
    "NETACT_LOGSERVER_IP": "10.110.144.134",
    "NETACT_LOGSERVER_USERNAME": "root",
    "NETACT_LOGSERVER_PASSWORD": "arthur",
    "5GC002479_HA_KPI1a": {
        "WebUI_reset_times": "5",
        "SFPCooledTransceiver": "True",  # The value of SFPCooledTransceiver to TL
    },
    "5GC002479_HA_KPI3": {
        "Power_reset_times": "5",
        "SFPCooledTransceiver": "True",  # The value of SFPCooledTransceiver to TL
    },
    "CB006939_HA_KPI51a": {
        "RF_Reset_Times": "5",
        "SFPCooledTransceiver": [
            {"Declaration": "True"},
            {"Declaration": "True"},
            {"Declaration": "False"},
            {"Declaration": "False"},
            {"Declaration": "True"},
            {"Declaration": "True"},
        ],  # The value of SFPCooledTransceiver to different RMOD,In order from RMOD1
    },
    "CB006939_HA_KPI54a": {
        "RU_Reset_Times": "3",
        "SFPCooledTransceiver": [
            {"Declaration": "True"},
            {"Declaration": "True"},
            {"Declaration": "False"},
            {"Declaration": "False"},
            {"Declaration": "True"},
            {"Declaration": "True"},
        ],  # The value of SFPCooledTransceiver to different RMOD,In order from RMOD1
    },
    "5GC002479_HA_KPI5": {
        "SFPCooledTransceiver": [
            {"Declaration": "True"},
            {"Declaration": "False"},
            {"Declaration": "True"},
        ],  # The value of SFPCooledTransceiver to different BBMOD,In order from BBMOD1
    },
    "5GC002479_IA": {
        "OriginalStream": "SBTS21B_ENB_0000",
        "OriginalStreamSCF": "OriginalStreamSCF.xml",
        "SFPCooledTransceiver": "True",  # The value of SFPCooledTransceiver to TL
    },
}

CASE_INPUT_CB007958 = {
    "mPlaneIpAddress": "7.7.7.7",
    "mPlaneIpPrefix": 24,
    "defaultGateway": "10.71.215.97",
    "identificationServerIpAddress": "10.110.144.153",
    "secondaryMPlaneIpAddress": "10.71.215.101",
    "secondaryMPlaneIpPrefix": 29,
}
