import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"

TC5GC002479_AA_01 = {
    "Duration_SCFLoad": "20",
    "Duration_ValidationError": "270",
    "Duration_Validation": "140",
    "Duration_Activation": "575",
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
            "primary_ip_address": "10.57.251.186",
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
            "primary_ip_address": "2a00:8a00:8000:136:10:57:251:104",
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
