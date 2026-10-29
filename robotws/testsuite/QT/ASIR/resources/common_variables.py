from robot.libraries.BuiltIn import BuiltIn

ue_info = BuiltIn().get_variable_value('${tl.ues[0]}')
BBMOD_type = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].airscale.common_units[0].hardware_type}')
TL_Name = BuiltIn().get_variable_value('${tl.tl_cloud_topology}')

ASIR_ALARMS = {
    'Default_list_of_alarms': [],
    'Config_Reset': [3060]
}

x2_alarms = ['No X2 link available', 'No X2 link available for a specific LTEENB',
             'Setup of X2 connectivity to gNB failed']

ADDITIONAL_ALARMS_FOR_TESTS = {
    'Comm_and_Recomm': ['Failure detected on assigned antennas',
                        'Antennas assignment not available', 'NgGnbInitFullReset', 'NgGnbInitPartialReset'],
    'BBMOD_Reset': ['NgGnbInitFullReset', 'NgGnbInitPartialReset'],
    'SW_Upgrade': ['BTS Reset Cause'],
    'L3_Call': [],
}

TLs_data = {
    "krk-9010": {
        "Jenkins_node": "QT-4G_TDD_ASIA_APHA_ASIR-KRK-9010",
        "Cell_for_call": "LNCELL-1",
    },
    "krk-9180": {
        "Jenkins_node": "QT-CPRI_FDD_NSA_ASIL_APHG_ASIR-KRK-9180",
        "Cell_for_call": "LNCELL-2",
        "Alarms": {
            "Comm_and_Recomm": x2_alarms,
            "BBMOD_Reset": x2_alarms,
            "SW_Upgrade": x2_alarms,
            "L3_Call": x2_alarms,
        }
    },
    "krk-9121": {
        "Jenkins_node": "QT-4G_FDD_ASOE_APHG_ASIR-KRK-9121",
        "Cell_for_call": "LNCEL-1",
        "Alarms": {
            "Comm_and_Recomm": x2_alarms,
            "BBMOD_Reset": x2_alarms,
            "SW_Upgrade": x2_alarms,
            "L3_Call": x2_alarms,
        }
    },
    "krk-9189": {
        "Jenkins_node": "QT-eCPRI_TDD_NSA_ASIL_APHG_ASIR-KRK-9189",
        "Cell_for_call": "LNCEL-1",
        "Alarms": {
            "Comm_and_Recomm": x2_alarms,
            "BBMOD_Reset": x2_alarms,
            "SW_Upgrade": x2_alarms,
            "L3_Call": x2_alarms,
        }
    },
    "krk-9124": {
        "Jenkins_node": "QT-4G_FDD_ASOE_APHG_ASIR-KRK-9124",
        "Cell_for_call": "LNCEL-1",
        "Alarms": {
            "Comm_and_Recomm": x2_alarms,
            "BBMOD_Reset": x2_alarms,
            "SW_Upgrade": x2_alarms,
            "L3_Call": x2_alarms,
        }
    },
    "krk-9147": {
        "Jenkins_node": "QT-CPRI_TDD_NSA_ASIM_APHA_ASIR-KRK-9147",
        "Cell_for_call": "LNCEL-1",
        "Alarms": {
            "Comm_and_Recomm": x2_alarms,
            "BBMOD_Reset": x2_alarms,
            "SW_Upgrade": x2_alarms,
            "L3_Call": x2_alarms,
        }
    },
    "krk-9142": {
        "Jenkins_node": "QT-CPRI_TDD_SA_ASIL_APHG_ASIR-KRK-9142",
        "Cell_for_call": "LNCEL-2",
    },
    "krk-9127": {
        "Jenkins_node": "QT-CPRI_FDD_SA_ASIB_APHG_ASIR-KRK-9127",
        "Cell_for_call": "NRCELL-0",
    },
    "krk-9179": {
        "Jenkins_node": "QT-CPRI_TDD_NSA_ASIL_APHA_ASIR-KRK-9179",
        "Cell_for_call": "LNCELL-1",
        "Alarms": {
            "Comm_and_Recomm": x2_alarms,
            "BBMOD_Reset": x2_alarms,
            "SW_Upgrade": x2_alarms,
            "L3_Call": x2_alarms,
        }
    },
    "krk-9181": {
        "Jenkins_node": "QT-4G_FDD_ASOE_APHG_ASIR-KRK-9181",
        "Cell_for_call": "LNCELL-1",
    },
    "krk-9129": {
        "Jenkins_node": "QT-eCPRI_TDD_SA_ASIM_APHG_ASIR-KRK-9129",
        "Cell_for_call": "LNCELL-2",
    },
    "krk-9130": {
        "Jenkins_node": "QT-CPRI_FDD_SA_ASIB_APHG_ASIR-KRK-9130",
        "Cell_for_call": "NRCELL-0",
    },
    "krk-9133": {
        "Jenkins_node": "QT-CPRI_TDD_NSA_ASIL_APHA_ASIR-KRK-9133",
        "Cell_for_call": "LNCEL-1",
        "Alarms": {
            "Comm_and_Recomm": x2_alarms,
            "BBMOD_Reset": x2_alarms,
            "SW_Upgrade": x2_alarms,
            "L3_Call": x2_alarms,
        }
    },
    "krk-9145": {
        "Jenkins_node": "QT-CPRI_TDD_NSA_ASIL_APHA_ASIR-KRK-9145",
        "Cell_for_call": "LNCEL-1",
        "Alarms": {
            "Comm_and_Recomm": x2_alarms,
            "BBMOD_Reset": x2_alarms,
            "SW_Upgrade": x2_alarms,
            "L3_Call": x2_alarms,
        }
    },
    "krk-9125": {
        "Jenkins_node": "QT-4G_FDD_ASOE_APHG_ASIR-KRK-9125",
        "Cell_for_call": "LNCEL-1",
    },
    "krk-9132": {
        "Jenkins_node": "QT-4G_FDD_ASOE_APHG_ASIR-KRK-9132",
        "Cell_for_call": "LNCEL-1",
    },
    "krk-9188": {
        "Jenkins_node": "QT-eCPRI_TDD_SA_ASIM_APHG_ASIR-KRK-9188",
        "Cell_for_call": "LNCEL-2",
    },
    "krk-9052": {
        "Jenkins_node": "QT-CPRI_FDD_SA_ASIL_APHG_ASIR-KRK-9052",
        "Cell_for_call": "NRCELL-0",
    },
    "krk-9187": {
        "Jenkins_node": "QT-eCPRI_TDD_SA_ASIM_APHG_ASIR-KRK-9187",
        "Cell_for_call": "LNCEL-2",
    },
    "krk-9146": {
        "Jenkins_node": "QT-CPRI_FDD_SA_ASIL_APHG_ASIR-KRK-9146",
        "Cell_for_call": "NRCELL-0",
    }
}
