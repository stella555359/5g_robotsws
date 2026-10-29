from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value("${GNB_ID}")
cell_id = BuiltIn().get_variable_value("${CELL_ID}")

netacts = {
    "srnclab1043": {
        "IP": "10.43.48.48",
        "URL": "srnclab1043lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab1044": {
        "IP": "10.43.48.76",
        "URL": "srnclab1044lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab1045": {
        "IP": "10.43.48.123",
        "URL": "srnclab1045lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "espoo"
    },
    "srnclab1046": {
        "IP": "10.43.48.159",
        "URL": "srnclab1046lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab1047": {
        "IP": "10.43.48.192",
        "URL": "srnclab1047lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab2001": {
        "IP": "10.41.18.90",
        "URL": "srnclab2001lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab2002": {
        "IP": "10.82.47.15",
        "URL": "srnclab2002lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "espoo"
    },
    "srnclab2003": {
        "IP": "10.82.47.46",
        "URL": "srnclab2003lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab2010": {
        "IP": "10.82.47.125",
        "URL": "srnclab2010lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab2014": {
        "IP": "10.82.47.190",
        "URL": "srnclab2014lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab2015": {
        "IP": "10.82.47.159",
        "URL": "srnclab2015lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab2019": {
        "IP": "10.99.102.28",
        "URL": "srnclab2019lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab2021": {
        "IP": "10.99.113.94",
        "URL": "srnclab2021lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "dallas"
    },
    "srnclab2024": {
        "IP": "10.99.113.46",
        "URL": "srnclab2024lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab2028": {
        "IP": "10.99.113.232",
        "URL": "srnclab2028lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "dallas"
    },
    "srnclab3006": {
        "IP": "10.99.127.156",
        "URL": "srnclab3006lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab3007": {
        "IP": "10.99.127.179",
        "URL": "srnclab3007lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "espoo"
    },
    "srnclab3008": {
        "IP": "10.99.127.210",
        "URL": "srnclab3008lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab3009": {
        "IP": "10.53.6.18",
        "URL": "srnclab3009lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab3010": {
        "IP": "10.53.6.46",
        "URL": "srnclab3010lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab3016": {
        "IP": "10.41.128.18",
        "URL": "srnclab3016lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "dallas"
    },
    "srnclab3017": {
        "IP": "10.41.128.44",
        "URL": "srnclab3017lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab3018": {
        "IP": "10.41.128.72",
        "URL": "srnclab3018lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab3019": {
        "IP": "10.41.128.101",
        "URL": "srnclab3019lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab3020": {
        "IP": "10.41.128.129",
        "URL": "srnclab3020lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "espoo"
    },
    "srnclab3021": {
        "IP": "10.41.128.155",
        "URL": "srnclab3021lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
    "srnclab3022": {
        "IP": "10.41.128.183",
        "URL": "srnclab3022lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
        "CMP": "srnblr"
    },
}

cmps = {
    "cmp_srnblr": [{
        "distName": f"MRBTS-{bts_id}/MNL-1/CERTH-1/CMP-1",
        "operation": "update",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "caSubjectName",
                "value": "CN=srnblrna1"
            },
            {
                "operation": "update",
                "parameterName": "serverHost",
                "value": "10.96.129.254"
            },
            {
                "operation": "update",
                "parameterName": "serverPath",
                "value": "pkix"
            },
            {
                "operation": "update",
                "parameterName": "serverPort",
                "value": "8080"
            },
            {
                "operation": "update",
                "parameterName": "keyLength",
                "value": "2048"
            },
        ]
    }],
    "cmp_espoo": [{
        "distName": f"MRBTS-{bts_id}/MNL-1/CERTH-1/CMP-1",
        "operation": "update",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "caSubjectName",
                "value": "C=CN, O=NOKIA, CN=EspooCloudRANTest"
            },
            {
                "operation": "update",
                "parameterName": "serverHost",
                "value": "10.27.175.216"
            },
            {
                "operation": "update",
                "parameterName": "serverPath",
                "value": "pkix"
            },
            {
                "operation": "update",
                "parameterName": "serverPort",
                "value": "8081"
            },
            {
                "operation": "update",
                "parameterName": "keyLength",
                "value": "4096"
            },
        ]
    }],
    "cmp_dallas": [{
        "distName": f"MRBTS-{bts_id}/MNL-1/CERTH-1/CMP-1",
        "operation": "update",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "caSubjectName",
                "value": "C=US, O=Nokia, OU=SRN NAM, CN=Load1"
            },
            {
                "operation": "update",
                "parameterName": "serverHost",
                "value": "10.52.126.109"
            },
            {
                "operation": "update",
                "parameterName": "serverPath",
                "value": "pkix"
            },
            {
                "operation": "update",
                "parameterName": "serverPort",
                "value": "8080"
            },
            {
                "operation": "update",
                "parameterName": "keyLength",
                "value": "2048"
            },
        ]
    }]
}

key = {
    "cmp_srnblr": {
        "reference_number": "56215",
        "preshared_key": "X2gd-4PJa-QLo2-rk9k"
    },
    "cmp_espoo": {
        "reference_number": "37416",
        "preshared_key": "ccRT-XnWF-W4pG-MuGp"
    },
    "cmp_dallas": {
        "reference_number": "46477",
        "preshared_key": "cEnL-2hYp-mEq8-TV9q"
    }
}

earfcn_700 = [{
    'distName': f'MRBTS-{bts_id}/LNBTS-{bts_id}/LNCEL-21/LNCEL_FDD-0',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'earfcnDL',
            'value': '700'},
        {
            'operation': 'update',
            'parameterName': 'earfcnUL',
            'value': '18700'},
    ]}]

earfcn_1800 = [{
    'distName': f'MRBTS-{bts_id}/LNBTS-{bts_id}/LNCEL-21/LNCEL_FDD-0',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'earfcnDL',
            'value': '1800'},
        {
            'operation': 'update',
            'parameterName': 'earfcnUL',
            'value': '19800'},
    ]}]

oamtls_on = [{
    'distName': f'MRBTS-{bts_id}/MNL-1/MNLENT-1/MPLANENW-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'oamTls',
            'value': 'forced'},
    ]}]

oamtls_off = [{
    'distName': f'MRBTS-{bts_id}/MNL-1/MNLENT-1/MPLANENW-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'oamTls',
            'value': 'off'},
    ]}]
