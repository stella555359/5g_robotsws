from robot.libraries.BuiltIn import BuiltIn
bts_id = BuiltIn().get_variable_value("${GNB_ID}")

netacts = {
    "srnclab1044": {
        "IP": "10.43.48.76",
        "URL": "srnclab1044lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab1045": {
        "IP": "10.43.48.123",
        "URL": "srnclab1045lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab1046": {
        "IP": "10.43.48.163",
        "URL": "srnclab1046lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab1047": {
        "IP": "10.43.48.192",
        "URL": "srnclab1047lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab1052": {
        "IP": "10.63.2.159",
        "URL": "srnclab1052lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab1054": {
        "IP": "10.63.2.215",
        "URL": "srnclab1054lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab1057": {
        "IP": "10.68.122.63",
        "URL": "srnclab1057lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab2002": {
        "IP": "10.82.47.111",
        "URL": "srnclab2002lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab2007": {
        "IP": "10.82.47.57",
        "URL": "srnclab2007lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab2010": {
        "IP": "10.82.47.125",
        "URL": "srnclab2010lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab2014": {
        "IP": "10.82.47.190",
        "URL": "srnclab2014lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab2021": {
        "IP": "10.99.113.94",
        "URL": "srnclab2021lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab2028": {
        "IP": "10.99.113.232",
        "URL": "srnclab2028lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab3006": {
        "IP": "10.99.127.156",
        "URL": "srnclab3006lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab3007": {
        "IP": "10.99.127.179",
        "URL": "srnclab3007lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab3008": {
        "IP": "10.99.127.210",
        "URL": "srnclab3008lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab3009": {
        "IP": "10.53.6.18 ",
        "URL": "srnclab3009lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
    "srnclab3010": {
        "IP": "10.53.6.46",
        "URL": "srnclab3010lbwas.srnblr.nsn-rdnet.net",
        "MR_ASI": "MRC-ASIR/MR-ASIR",
        "MR_MRBTS": "MRC-BTS/MR-BTS",
    },
}

allowASiLocalUserDefaultPasswordFalse = [{
    'distName': f"ASI-{bts_id}/SECPRM-1",
    'parameters': [{
        'operation': "update",
        'parameterName': "allowASiLocalUserDefaultPassword",
        'value': "false"}]}]

allowASiLocalUserDefaultPasswordTrue = [{
    'distName': f"ASI-{bts_id}/SECPRM-1",
    'parameters': [{
        'operation': "update",
        'parameterName': "allowASiLocalUserDefaultPassword",
        'value': "true"}]}]
