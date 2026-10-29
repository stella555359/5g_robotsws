from robot.libraries.BuiltIn import BuiltIn
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.lib.scf_process as scf_process

# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value('${tl}')

# # Defined in common_setup_teardown.robot
SCF_DEFAULT_FILE_PATH = BuiltIn().get_variable_value('${SCF_DEFAULT_FILE_PATH}')
SUITE_LOG_PATH = BuiltIn().get_variable_value('${SUITE_LOG_PATH}')
IS_ASOD_ASOE_ASOF = BuiltIn().get_variable_value('${is_asod_asoe_asof}')

DN_MRBTS = 'MRBTS-' + str(tl.gnbs[0].instance_id)
DN_NRBTS = DN_MRBTS + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
DN_LNBTS = DN_MRBTS + '/LNBTS-' + str(tl.enbs[0].global_bts_id)
DN_NRCELL_1 = DN_NRBTS + '/NRCELL-1'
DN_LNCEL = DN_LNBTS + '/LNCEL-1'

BWP_ID_10M = [DN_NRBTS + '/BWP_PROFILE-5', DN_NRBTS + '/BWP_PROFILE-31']
BWP_ID_20M = [DN_NRBTS + '/BWP_PROFILE-4', DN_NRBTS + '/BWP_PROFILE-33']
BWP_ID_40M = [DN_NRBTS + '/BWP_PROFILE-15', DN_NRBTS + '/BWP_PROFILE-39']

cellbar = ''

BWPDN_10M = [
    dict(
        dist_name=DN_NRCELL_1,
        list_name='cellBwpList',
        index=0,
        p_name='bwpDN',
        value=BWP_ID_10M[0]),
    dict(
        dist_name=DN_NRCELL_1,
        list_name='cellBwpList',
        index=1,
        p_name='bwpDN',
        value=BWP_ID_10M[1]),
]

BWPDN_20M = [
    dict(
        dist_name=DN_NRCELL_1,
        list_name='cellBwpList',
        index=0,
        p_name='bwpDN',
        value=BWP_ID_20M[0]),
    dict(
        dist_name=DN_NRCELL_1,
        list_name='cellBwpList',
        index=1,
        p_name='bwpDN',
        value=BWP_ID_20M[1]),
]

BWPDN_40M = [
    dict(
        dist_name=DN_NRCELL_1,
        list_name='cellBwpList',
        index=0,
        p_name='bwpDN',
        value=BWP_ID_40M[0]),
    dict(
        dist_name=DN_NRCELL_1,
        list_name='cellBwpList',
        index=1,
        p_name='bwpDN',
        value=BWP_ID_40M[1]),
]

DELETE_SCF_NRCELL2 = [
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2'),
    dict(dist_name=DN_NRBTS + '/NRCELL-2'),
    dict(dist_name=DN_NRBTS + '/NRCELLGRP-1'),
    dict(dist_name=DN_NRBTS + '/NRDU-1', list_name='refNrCellGroup', index='-1'),
]

DELETE_SCF_LTE = [
    dict(dist_name=DN_LNBTS),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-1'),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1'),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/TEST-1'),
]

DELETE_SCF_NR = [
    dict(dist_name=DN_MRBTS + '/MNL-1/TCEADM-1'),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1'),
    dict(dist_name=DN_NRBTS),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1'),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2'),
]

MODIFY_SCF_NR_BW_10M = [
    dict(dist_name=DN_NRCELL_1 + '/NRCELL_FDD-1', p_name='chBwDl', value='10MHz'),
    dict(dist_name=DN_NRCELL_1 + '/NRCELL_FDD-1', p_name='chBwUl', value='10MHz'),
]

MODIFY_SCF_NR_BW_20M = [
    dict(dist_name=DN_NRCELL_1 + '/NRCELL_FDD-1', p_name='chBwDl', value='20MHz'),
    dict(dist_name=DN_NRCELL_1 + '/NRCELL_FDD-1', p_name='chBwUl', value='20MHz'),
]

MODIFY_SCF_LTE_BW_10M = [
    dict(dist_name=DN_LNCEL + '/LNCEL_FDD-0', p_name='dlChBw', value='10 MHz'),
    dict(dist_name=DN_LNCEL + '/LNCEL_FDD-0', p_name='ulChBw', value='10 MHz'),
]

MODIFY_SCF_NR_FREQ_N25 = [
    dict(dist_name=DN_NRCELL_1, p_name='freqBandIndicatorNR', value='25'),
    dict(dist_name=DN_NRCELL_1 + '/NRCELL_FDD-1', p_name='nrarfcnDl', value='392500'),
    dict(dist_name=DN_NRCELL_1 + '/NRCELL_FDD-1', p_name='nrarfcnUl', value='376500'),
]

MODIFY_SCF_LTE_FREQ_B25 = [
    dict(dist_name=DN_LNCEL + '/LNCEL_FDD-0', p_name='earfcnDL', value='8140'),
    dict(dist_name=DN_LNCEL + '/LNCEL_FDD-0', p_name='earfcnUL', value='26140'),
]

MODIFY_SCF_LTE_CELL_BAR = [
    dict(dist_name=DN_LNCEL + '/SIB-0', p_name='cellBarred', value='notBarred'),
]

MODIFY_SCF_DISABLE_FEATURE = [
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/FEATCADM-1',
         p_name='actAutNrRrcConStAtSlCellDetRec',
         value='false'),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/FEATCADM-1',
         p_name='actNrAutCntRachStpSlCellDetRec',
         value='false'),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/FEATCADM-1',
         p_name='actNrAutNgCommSlCellDetRec',
         value='false'),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/FEATCADM-1',
         p_name='actNrAutPrachAccSltSlCellDetRec',
         value='false'),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/FEATCADM-1',
         p_name='actNrAutRxPwrAntSlCellDetRec',
         value='false'),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/FEATCADM-1',
         p_name='actNrAutRxPwrDiff2AntSlCellDetRec',
         value='false'),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/FEATCADM-1',
         p_name='actNrAutRxPwrSlCellDetRec',
         value='false'),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/FEATCADM-1',
         p_name='actNrAutTxPwrSlCellDetRec',
         value='false'),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/FEATCADM-1',
         p_name='actNrRrcSuccRateSlCellCuDetRec',
         value='false'),
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/FEATCADM-1',
         p_name='actNrRrcSuccRateSlCellDuDetRec',
         value='false'),
]

if IS_ASOD_ASOE_ASOF is True:
    MODIFY_SCF_SMOD_TYPE_NR = [
        dict(
            dist_name=DN_MRBTS + '/EQM-1/APEQM-1/CABINET-1/SMOD-1/BBCAP-1',
            p_name='smodBoardConfigType',
            value='NRFDD'),
    ]
    MODIFY_SCF_SMOD_TYPE_LTE = [
        dict(
            dist_name=DN_MRBTS + '/EQM-1/APEQM-1/CABINET-1/SMOD-1/BBCAP-1',
            p_name='smodBoardConfigType',
            value='LTEFDD'),
    ]
else:
    MODIFY_SCF_SMOD_TYPE_NR = [
        dict(
            dist_name=DN_MRBTS + '/EQM-1/APEQM-1/CABINET-1/BBMOD-1',
            p_name='bbmodBoardConfigType',
            value='NRFDD'),
    ]
    MODIFY_SCF_SMOD_TYPE_LTE = [
        dict(
            dist_name=DN_MRBTS + '/EQM-1/APEQM-1/CABINET-1/BBMOD-1',
            p_name='bbmodBoardConfigType',
            value='LTEFDD'),
    ]

MODIFY_SCF_NR_POWER_SAVING = [
    dict(
        dist_name=DN_NRBTS + '/NRPGRP-1',
        list_name='lbpsCellList',
        index=0,
        p_name='nrCellId',
        value='2'
    ),
    dict(
        dist_name=DN_NRBTS + '/NRPGRP-1',
        list_name='lbpsCellPeriodList',
        index=0,
        p_name='nrCellId',
        value='2'
    ),
]

# Generate SCF template for different BW and band frequency
scf_template_generate = scf_process.SCFProcess()

scf_template_generate.SCFProcess(
    scf_template_path=SCF_DEFAULT_FILE_PATH,
    scf_process_folder=SUITE_LOG_PATH,
    list_para_to_delete=DELETE_SCF_NRCELL2,
    scf_file_name_after_process='SCF_TEMPLATE_RFS_N66_40M_B66_20M.xml',
)

scf_template_generate.SCFProcess(
    scf_template_path=SCF_DEFAULT_FILE_PATH,
    scf_process_folder=SUITE_LOG_PATH,
    list_para_to_delete=DELETE_SCF_NRCELL2,
    list_para_to_modify=BWPDN_20M + MODIFY_SCF_NR_BW_20M + MODIFY_SCF_NR_FREQ_N25 +
    MODIFY_SCF_LTE_BW_10M + MODIFY_SCF_LTE_FREQ_B25,
    scf_file_name_after_process='SCF_TEMPLATE_RFS_N25_20M_B25_10M.xml',
)

scf_template_generate.SCFProcess(
    scf_template_path=SCF_DEFAULT_FILE_PATH,
    scf_process_folder=SUITE_LOG_PATH,
    list_para_to_delete=DELETE_SCF_NRCELL2 + DELETE_SCF_LTE,
    list_para_to_modify=MODIFY_SCF_SMOD_TYPE_NR + BWPDN_10M + MODIFY_SCF_NR_BW_10M,
    scf_file_name_after_process='SCF_TEMPLATE_NR_N66_10M.xml',
)

scf_template_generate.SCFProcess(
    scf_template_path=SCF_DEFAULT_FILE_PATH,
    scf_process_folder=SUITE_LOG_PATH,
    list_para_to_delete=DELETE_SCF_NRCELL2 + DELETE_SCF_LTE,
    list_para_to_modify=MODIFY_SCF_SMOD_TYPE_NR + BWPDN_20M + MODIFY_SCF_NR_BW_20M +
    MODIFY_SCF_NR_FREQ_N25,
    scf_file_name_after_process='SCF_TEMPLATE_NR_N25_20M.xml',
)

scf_template_generate.SCFProcess(
    scf_template_path=SCF_DEFAULT_FILE_PATH,
    scf_process_folder=SUITE_LOG_PATH,
    list_para_to_delete=DELETE_SCF_LTE,
    list_para_to_modify=MODIFY_SCF_SMOD_TYPE_NR + BWPDN_10M + MODIFY_SCF_NR_BW_10M +
    MODIFY_SCF_NR_POWER_SAVING,
    scf_file_name_after_process='SCF_TEMPLATE_NR_N66_10M_2CC.xml',
)

scf_template_generate.SCFProcess(
    scf_template_path=SCF_DEFAULT_FILE_PATH,
    scf_process_folder=SUITE_LOG_PATH,
    list_para_to_delete=DELETE_SCF_NR,
    list_para_to_modify=MODIFY_SCF_SMOD_TYPE_LTE + MODIFY_SCF_LTE_CELL_BAR + MODIFY_SCF_DISABLE_FEATURE +
    MODIFY_SCF_LTE_BW_10M + MODIFY_SCF_LTE_FREQ_B25,
    scf_file_name_after_process='SCF_TEMPLATE_LTE_B25_10M.xml',
)

# SCF_DEFAULT_FILE_PATH = 'BASE SCF'
SCF_PATH_RFS_N25_20M_B25_10M = SUITE_LOG_PATH + '/SCF_TEMPLATE_RFS_N25_20M_B25_10M.xml'
SCF_PATH_RFS_N66_40M_B66_20M = SUITE_LOG_PATH + '/SCF_TEMPLATE_RFS_N66_40M_B66_20M.xml'
SCF_PATH_NR_N66_10M = SUITE_LOG_PATH + '/SCF_TEMPLATE_NR_N66_10M.xml'
SCF_PATH_NR_N25_20M = SUITE_LOG_PATH + '/SCF_TEMPLATE_NR_N25_20M.xml'
SCF_PATH_NR_N66_10M_2CC = SUITE_LOG_PATH + '/SCF_TEMPLATE_NR_N66_10M_2CC.xml'
SCF_PATH_LTE_B25_10M = SUITE_LOG_PATH + '/SCF_TEMPLATE_LTE_B25_10M.xml'
