*** Settings ***
Documentation      CB006137
Resource           ./CB006137_resource.robot
Resource           ./resources/CB006137_BB_resource.robot
Resource           ./../CUDU_L2/common_setup_teardown.robot
Suite Setup        CB006137_BB_resource.Common Suite Setup 2
#Test Teardown      Run Keywords    Send Swconfig for GNB    ${gnb_swconfig}
#...                AND    Common Test Teardown 2
Suite Teardown     Common Suite Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    CN1_SG09_SM1    CB006137

*** Variables ***
${SCF_PATH}                 ${CURDIR}/config/SCF
${LOCAL_WTS_DIR}            ${CURDIR}/config/WTS/
${WTS_DIR}                  /opt/iphy/latest
${6137_BB012_SCF}           ${SCF_PATH}/CB006137_BB012_LOLO.xml
${6137_BB004_SCF}           ${SCF_PATH}/CB006137_BB004_LOLO.xml
${6137_BB007_SCF}           ${SCF_PATH}/CB006137_BB007_LOLO.xml
${6137_BB023_SCF}           ${SCF_PATH}/CB006137_BB023_LOLO.xml
${IPHY_1F_1T}               ${CURDIR}/config/WTS/iphy_1F_1T_LOLO.xml
${gnb_swconfig}             /home/ute/.ute-ca/executions/1/configs/topology_configs/node_1/SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE/swconfig_gnb.txt
${SWCONFIG_PARAM_BB007}     0x58057F=16;
${SWCONFIG_PARAM_BB012}     0x58057F=16;
${WTS_CFG_BB012}            CB006137_BO_AB_Nina.cfg
${WTS_AP_XML}               airphone.xml
${UE_ID}                    3
${2CC_1F1T_SCELL}           ('1', '50', '41')
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}


*** Test Cases ***
#CB006137-ET-BB004_UE_back_to_scell_center_from_scell_edge_when_only_UL_RLQ_is_bad
#    [Tags]     caseBB004    qianwu    Owner_qianwu
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB012}
#    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB004_SCF}    iphy_file=${IPHY_1F_1T}    swconfig_param=${SWCONFIG_PARAM_BB012}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    ...        AND    Common Test Setup 2
#    SA Attach    ${UE_ID}
#    Scell Addition Triggered By A1 Event    ${UE_ID}
#    Get And Check Scell Infos    ${2CC_1F1T_SCELL}
#    Start SA UL Big Traffic Internal    ${UE_ID}    mbps=100
#    Sleep    10s    reason=Wait for traffic stable
#    Check UL TP On Target    ${UE_ID}    0    1    50
#    Capture And Decode TTitrace
#    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1/
#    Check Scell Suspend Resume When Bad RLQ
#    Start SA DL Big Traffic Internal    ${UE_ID}    mbps=400
#    Sleep    10s    reason=Wait for traffic stable
#    Check DL TP On Target    ${UE_ID}    0    1    200
#    Capture And Decode TTitrace    3
#    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/3/
#    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/3/
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    SA 5G Detach    ${UE_ID}

CB006137-ET-BB012_UL_and_DL_traffic_2_symbols_needed_for_PDCCH
    [Tags]     caseBB012    qianwu    Owner_qianwu
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB012}
    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB012_SCF}    iphy_file=${IPHY_1F_1T}    swconfig_param=${SWCONFIG_PARAM_BB012}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
    ...        AND    Common Test Setup 2
    SA Attach    ${UE_ID}
    Scell Addition Triggered By A1 Event    ${UE_ID}
    Get And Check Scell Infos    ${2CC_1F1T_SCELL}
    Start SA UL Big Traffic Internal    ${UE_ID}    mbps=200
    Start SA DL Big Traffic Internal    ${UE_ID}    mbps=400
    Sleep    10s    reason=Wait for traffic stable
    Check UL TP On Target    ${UE_ID}    0    1    50
    Check DL TP On Target   ${UE_ID}    0    1    200
    Capture And Decode TTitrace
    Get and Check PM Counter for Symbol
    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
    SA 5G Detach    ${UE_ID}
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1/
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1/

#CB006137-ET-BB007_SCell_UL_schedule_recovery_from_suspending_due_to_uplink_radio_link_quality_recovery
#    [Tags]     caseBB007    lading
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB012}
#    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB007_SCF}    iphy_file=${IPHY_1F_1T}    swconfig_param=${SWCONFIG_PARAM_BB007}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
#    ...        AND    Common Test Setup 2
#    SA Attach    ${UE_ID}
#    Scell Addition Triggered By A1 Event    ${UE_ID}
#    Get And Check Scell Infos    ${2CC_1F1T_SCELL}
#    Start SA UL Big Traffic Internal    ${UE_ID}    mbps=200
#    Start SA DL Big Traffic Internal    ${UE_ID}    mbps=400
#    Sleep    10s    reason=Wait for traffic stable
#    Check UL TP On Target    ${UE_ID}    0    1    50
#    Check DL TP On Target   ${UE_ID}    0    1    50
#    Capture And Decode TTitrace
#    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1/
#    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1/
#    Start Ttitrace With Streaming Mode    2
#    Trigger BLER To GNB
#    Sleep    5s    reason=Wait for Bler triggered
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
#    Check Scell RlqAlgorithm for BB07 case    2
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    SA 5G Detach    ${UE_ID}

#CB006137-ET-BB023_UE_enter_to_bad_RLQ_cell_edge_during_UE_report_CQI0
#    [Tags]     caseBB009    suqian
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB012}
#    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB023_SCF}    iphy_file=${IPHY_1F_1T}    swconfig_param=${SWCONFIG_PARAM_BB012}
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
