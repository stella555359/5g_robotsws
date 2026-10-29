*** Settings ***
Documentation    ...
#Resource           ./CB006137_resource.robot
#Resource           ./resources/CB006137_BB_resource.robot
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup        CB006137_BB_resource.Common Suite Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    CN1_SG09_SM1    CB006137
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/config/SCF
#${LOCAL_WTS_DIR}            ${CURDIR}/config/WTS/
#${WTS_DIR}                  /opt/iphy/latest
#${6137_BB023_SCF}           ${SCF_PATH}/CB006137_BB023.xml
#${6137_BB020_SCF}           ${SCF_PATH}/CB006137_BB020.xml
#${6137_BB027_SCF}           ${SCF_PATH}/CB006137_BB027.xml
#${6137_BB031_SCF}           ${SCF_PATH}/CB006137_BB031.xml
#${IPHY_1F_1T}               ${CURDIR}/config/WTS/iphy_1F_1T.xml
#${IPHY_2F_2T}               ${CURDIR}/config/WTS/iphy_2F_2T_BB039.xml
#${SWCONFIG_PARAM_BB023}     0x58057F=16;
#${WTS_CFG_BB012}            CB006137_BO_AB_Nina.cfg
#${WTS_CFG_BB039}            CB006137_BB039.cfg
#${WTS_CFG_BB027}            CB006137_BB027.cfg
#${UE_ID}                    3
#${UE_ID_B027}               1
#${UE1_ID}                   1
#${2CC_1F1T_SCELL}           ('1', '50', '41')
#${4CC_2F2T_SCELL}           ('1', '50', '71'), ('2', '60', '77'), ('3', '61', '41')
#&{GNB_ASIK}                 ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
#
#
#*** Test Cases ***
#CB006137-ET-BB023_UE_enter_to_bad_RLQ_cell_edge_during_UE_report_CQI0
#    [Tags]     caseBB009    suqian
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB012}
#    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB023_SCF}    iphy_file=${IPHY_1F_1T}    swconfig_param=${SWCONFIG_PARAM_BB023}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    ...        AND    Common Test Setup 2
#    SA Attach    ${UE_ID}
#    Scell Addition Triggered By A1 Event    ${UE_ID}
#    Get And Check Scell Infos    ${2CC_1F1T_SCELL}
#    Start SA UL Big Traffic Internal    ${UE_ID}    mbps=100
#    Sleep    10s    reason=Wait for traffic stable
#    Check UL TP On Target    ${UE_ID}    0    1    50
#    Start SA DL Big Traffic Internal    ${UE_ID}    mbps=400
#    Sleep    10s    reason=Wait for traffic stable
#    Check DL TP On Target   ${UE_ID}    0    1    200
#    Capture And Decode TTitrace
#    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1/
#    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1/
#    Check scell Bad RLQ and then Overheating
#    SA 5G Detach    ${UE_ID}
#
#CB006137-ET-BB020_Overheating_handing_with_CQI_equal_0
#    [Tags]     caseBB020    dguan
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB039}
#    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB020_SCF}    iphy_file=${IPHY_2F_2T}    swconfig_param=${SWCONFIG_PARAM_BB023}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    ...        AND    Common Test Setup 2
#    SA Attach    1
#    Scell Addition Triggered By A1 Event    ue_id=1    srsrp_nr=120
#    Start SA UL Big Traffic Internal    ue_id=1    mbps=100
#    Start SA DL Big Traffic Internal    ue_id=1    mbps=600
#    Sleep    10s    reason=Wait for traffic stable
#    Check Scell Active Status    cell_nums=4    scell_active_status=activated
#    Check DL TP On Target    1    0    1-3    300
#    Check UL TP On Target    1    0    1-3    70
#    Capture And Decode TTitrace    log_id=BB020_1
#    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/BB020_1/
#    Check Scell Suspend Resume When CQI overheating for BB020
#    SA 5G Detach    1
#
#CB006137-ET-BB027_Overheating_Assistance_Information_report_asking_to_activate_scell
#    [Tags]     caseBB027    haiyliu    Owner_haiyliu
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB027}
#    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB027_SCF}    iphy_file=${IPHY_2F_2T}    swconfig_param=${SWCONFIG_PARAM_BB023}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    ...        AND    Common Test Setup 2
#    SA Attach    ${UE_ID_B027}
#    Scell Addition Triggered By A1 Event    ${UE_ID_B027}    1    120
#    Start SA UL Big Traffic Internal    ue_id=1    mbps=200
#    Start SA DL Big Traffic Internal    ue_id=1    mbps=600
#    Sleep    10s    reason=Wait for logs
#    Check UL TP On Target    ${UE_ID_B027}    0    3    60
#    Check DL TP On Target    ${UE_ID_B027}    0    1-3    550
#    Capture And Decode TTItrace    log_id=1
#    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    Send Send Assistance Information And Check Scell Active Status    2    ${UE_ID_B027}    2    1    1    deactivated
#    Start Small Data And Check Scell Deactive    3    ${UE_ID_B027}    200    600
#    Start Big Data And Check Scell Active    4    ${UE_ID_B027}    200    600
#    Send Send Assistance Information And Check Scell Active Status    5    ${UE_ID_B027}    3    1    1
#    Send Send Assistance Information And Check Scell Active Status    6    ${UE_ID_B027}    0    0    3    deactivated
#
#CB006137-ET-BB031_UL_power_recover_after_UE_report_CQI_not_equal_0
#    [Tags]     caseBB031    qianwu    Owner_qianwu
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB027}
#    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB031_SCF}    iphy_file=${IPHY_2F_2T}    swconfig_param=${SWCONFIG_PARAM_BB023}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    ...        AND    Common Test Setup 2
#    SA Attach    ${UE1_ID}
#    Scell Addition Triggered By A1 Event    ${UE1_ID}    srsrp_nr=120
#    Get And Check Scell Infos    ${4CC_2F2T_SCELL}
#    Start SA UL Big Traffic Internal    ${UE1_ID}    mbps=200
#    Start SA DL Big Traffic Internal    ${UE1_ID}    mbps=650
#    Sleep    10s    reason=Wait for traffic stable
#    Check TP On Target For 4CC    ${UE1_ID}    ul    0-3    100
#    Check TP On Target For 4CC    ${UE1_ID}    dl    0-3    600
#    Send Assistance Information To GNB    ue_id=1    operation=yes    reducedCCsDL=1    reducedCCsUL=1
#    Sleep    30s    reason=Wait for DL scell deactivated
#    Check Scell Active Status    cell_nums=3    scell_active_status=deactivated
#    Check UL PowerRecover After CQI Not Equal 0
#    Capture And Decode TTitrace    log_id=5
#    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/5/
#    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/5/
#    SA Stop Data Traffic Internal    ${UE1_ID}    pdu_id=1
#    SA 5G Detach    ${UE1_ID}
#*** Keywords ***
