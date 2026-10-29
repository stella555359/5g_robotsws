from robot.libraries.BuiltIn import BuiltIn
import os

gNB_host = BuiltIn().get_variable_value('${tl.enbs[0].airscale.common_units[${enb_index}].lmp_connection.addr}')
gNB_login = BuiltIn().get_variable_value('${tl.enbs[0].airscale.common_units[${enb_index}].lmp_connection.username}')
gNB_password = BuiltIn().get_variable_value('${tl.enbs[0].airscale.common_units[${enb_index}].lmp_connection.password}')

params_commisioning_to_check = {
    'MRBTS-76140/LNBTS-76140/LNCEL-1': {
        'actUlpcMethod': 'PuschIAwPucchCL',
    },
    'MRBTS-76140/LNBTS-76140/LNCEL-1/LNCEL_FDD-0': {
        'dlChBw': '20 MHz',
        'ulChBw': '20 MHz',
    }
}

statuses_after_reset_hub = {
    'operationalState': 'enabled', 'commissioned': 'Yes', 'localState': 'unblocked',
    'hardwareState': 'working', 'softwareState': 'configured', 'activeStatusLEDColor': 'Green',
    'faultStatusLEDColor': 'Off', 'powerStatusLEDColor': 'Green'
}

ADDITIONAL_ALARMS_FOR_TESTS = {
    'Cell_block_unblock': ['Cell blocked'],
    'DHCP_verify': ['BTS Reset Cause'],
    'Comm_and_Recomm': ['BTS Reset Cause', 'Failure detected on assigned antennas',
                        'Antennas assignment not available'],
    'BBU_Reset': ['BTS Reset Cause', 'Failure detected on assigned antennas'],
    'Hub_reset': ['Failure detected on assigned antennas'],
}

PARAMETERS_TO_CHANGE_BY_WEBEM = [
            {
                'param_name': 'tCellDelNB',
                'operation': 'update',
                'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-10/NBIOT_FDD-0',
                'value': '90',
            },
            {
                'param_name': 'tCellDelNB',
                'operation': 'update',
                'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-20/NBIOT_FDD-0',
                'value': '90',
            },
            {
                'param_name': 'tHalfRrcConNB',
                'operation': 'update',
                'dist_name': 'MRBTS-76170/LNBTS-76170/NBIOTPR-0',
                'value': '200',
            },
]

GUARDBAND_TO_INBAND_PARAMETERS = [
            {
                'param_name': 'nbIoTMode',
                'operation': 'update',
                'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-1',
                'value': 'inband',
            },
            {
                'param_name': 'nbIoTMode',
                'operation': 'update',
                'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-10',
                'value': 'inband',
            },
            {
                'param_name': 'inbandPRBIndexDL',
                'operation': 'update',
                'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-10/NBIOT_FDD-0',
                'value': '19',
            },
            {
                'param_name': 'inbandPRBIndexUL',
                'operation': 'update',
                'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-10/NBIOT_FDD-0',
                'value': '26',
            },
            {
                'param_name': 'nbIoTMode',
                'operation': 'update',
                'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-2',
                'value': 'inband',
            },
            {
                'param_name': 'dlsDciCch',
                'operation': 'update',
                'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-2',
                'value': 'DCI format 1A',
            },
            {
                'param_name': 'nbIoTMode',
                'operation': 'update',
                'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-20',
                'value': 'inband',
            },
            {
                'param_name': 'inbandPRBIndexDL',
                'operation': 'update',
                'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-20/NBIOT_FDD-0',
                'value': '17',
            },
            {
                'param_name': 'inbandPRBIndexUL',
                'operation': 'update',
                'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-20/NBIOT_FDD-0',
                'value': '24',
            },
]

PARAMETERS_TO_POWER_LEVEL_MODIFICATIONS_AT_15MHZ = [
    {
        'param_name': 'inbandPRBIndexDL',
        'operation': 'update',
        'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-20/NBIOT_FDD-0',
        'value': '47',
    },
    {
        'param_name': 'dlPwrBoost',
        'operation': 'update',
        'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-20/NBIOT_FDD-0',
        'value': '60',
    },
]

PARAMETERS_TO_CHANGE_1_CELL_5MHZ_GB_FROM_1_CELL_20MHZ = [
    {
        'param_name': 'earfcnDL',
        'operation': 'update',
        'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-1/LNCEL_FDD-0',
        'value': '8140',
    },
    {
        'param_name': 'earfcnUL',
        'operation': 'update',
        'dist_name': 'MRBTS-76170/LNBTS-76170/LNCEL-1/LNCEL_FDD-0',
        'value': '26140',
    },
]

CURDIR = '{}'.format(os.path.dirname(os.path.realpath(__file__)))
Config_Dir = os.path.join(CURDIR, 'config')
Delta_Commisioning_B25_1_cell_gb_ASiR_WebEM = 'delta_asir__FDD_B25_20M_cell_with_GB.xml'
Delta_Commisioning_B25_1_cell_gb_WebEM = 'delta_gnb_FDD_B25_20M_cell_with_GB.json'
Delta_Commisioning_B25_1_cell_5MHz_gb_WebEM = 'gnb_delta_FDD_B25_5M_cell_with_GB.json'
Delta_Commisioning_B2_2_cells_ngb_ASiR_WebEM = 'delta_asir_FDD_B2_20M_2cells.xml'
Delta_Commisioning_B2_2_cells_ngb_WebEM = 'delta_gnb_FDD_B2_20M_2cells.json'
Delta_Commisioning_B66_B25_2_cells_gb_WebEM = 'gnb_FDD_B66_20M_1cell_and_B25_5M_1cell_with_GB.json'
Delta_Commisioning_B66_B25_2_cells_gb_ASiR_WebEM = 'asir_FDD_B66_20M_1cell_and_B25_5M_1cell_with_GB.xml'
