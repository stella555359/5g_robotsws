*** Settings ***
Resource           ./CB006137_resource.robot
Resource           ./resources/CB006137_BB_resource.robot
Resource           ./../CUDU_L2/common_setup_teardown.robot
Suite Setup        CB006137_BB_resource.Common Suite Setup 2
Test Teardown      Run Keywords    Send Swconfig for GNB    ${gnb_swconfig}
...                AND    Common Test Teardown 2
Suite Teardown     Common Suite Teardown 2
Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    CN1_SG09_SM1    CB006137

*** Variables ***
${SCF_PATH}                 ${CURDIR}/config/SCF
${LOCAL_WTS_DIR}            ${CURDIR}/config/WTS/
${WTS_DIR}                  /opt/iphy/latest
${6137_BB012_SCF}           ${SCF_PATH}/CB006137_BB012.xml
${6137_BB016_SCF}           ${SCF_PATH}/CB006137_BB016.xml
${6137_BB009_SCF}           ${SCF_PATH}/CB006137_BB009.xml
${6137_BB004_SCF}           ${SCF_PATH}/CB006137_BB004.xml
${6137_BB007_SCF}           ${SCF_PATH}/CB006137_BB007.xml
${IPHY_1F_1T}               ${CURDIR}/config/WTS/iphy_1F_1T.xml
${IPHY_7737}                ${CURDIR}/config/WTS/iphy_7737.xml
${gnb_swconfig}             /home/ute/testline_init_results/configs/sm_swconfig.txt
${SWCONFIG_PARAM_BB007}     0x58057F=16;
${SWCONFIG_PARAM_BB012}     0x58057F=16;
${SWCONFIG_PARAM_BB016}     0x58057F=16;0x580497=1;
${WTS_CFG_BB012}            CB006137_BO_AB_Nina.cfg
${WTS_CFG_BB016}            CB006137_7737.cfg
${WTS_AP_XML}               airphone.xml
${UE_ID}                    3
${2CC_1F1T_SCELL}           ('1', '50', '41')
&{GNB_ASIK}                 ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik


*** Test Cases ***
CB006137-ET-BB004_UE_back_to_scell_center_from_scell_edge_when_only_UL_RLQ_is_bad
    [Tags]     caseBB004    qianwu    Owner_qianwu
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB012}
    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB004_SCF}    iphy_file=${IPHY_1F_1T}    swconfig_param=${SWCONFIG_PARAM_BB012}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
    ...        AND    Common Test Setup 2
    SA Attach    ${UE_ID}
    Scell Addition Triggered By A1 Event    ${UE_ID}
    Get And Check Scell Infos    ${2CC_1F1T_SCELL}
    Start SA UL Big Traffic Internal    ${UE_ID}    mbps=100
    Sleep    10s    reason=Wait for traffic stable
    Check UL TP On Target    ${UE_ID}    0    1    50
    Capture And Decode TTitrace
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1/
    Check Scell Suspend Resume When Bad RLQ
    Start SA DL Big Traffic Internal    ${UE_ID}    mbps=400
    Sleep    10s    reason=Wait for traffic stable
    Check DL TP On Target    ${UE_ID}    0    1    200
    Capture And Decode TTitrace    3
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/3/
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/3/
    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
    SA 5G Detach    ${UE_ID}

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

CB006137-ET-BB016_4CC_capable_UE_call_with_pcell_and_scell_intra_core
    [Tags]     caseBB016    dguan    Owner_dguan
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB016}
    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB016_SCF}    iphy_file=${IPHY_7737}    swconfig_param=${SWCONFIG_PARAM_BB016}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}    enb_id=2    target_id=1
    ...        AND    Common Test Setup 2
    SA Attach    1
    Start SA UL Big Traffic Internal    ue_id=1    mbps=200
    Start SA DL Big Traffic Internal    ue_id=1    mbps=800
    Check Scell Active Status    cell_nums=4    scell_active_status=activated
    Capture And Decode TTItrace    log_id=BB016
    ta_a2a.Check Log With Au2anlysis    ${CURDIR}/A2A/CB006137_7737.ini
    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace/BB016
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/BB016/
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/BB016/
    SA Stop Data Traffic Internal    ue_id=1    pdu_id=1
    Sleep    3s    reason=Wait for traffic stable
    Check Scell Active Status    cell_nums=4    scell_active_status=deactivated
    Start SA UL Big Traffic Internal    ue_id=1    mbps=200
    Start SA DL Big Traffic Internal    ue_id=1    mbps=800
    Sleep    3s    reason=Wait for traffic stable
    Check Scell Active Status    cell_nums=4    scell_active_status=activated
	
CB006137-ET-BB007_SCell_UL_schedule_recovery_from_suspending_due_to_uplink_radio_link_quality_recovery
    [Tags]     caseBB007    lading
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB012}
    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB007_SCF}    iphy_file=${IPHY_1F_1T}    swconfig_param=${SWCONFIG_PARAM_BB007}
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
    Check DL TP On Target   ${UE_ID}    0    1    50
    Capture And Decode TTitrace
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1/
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1/
    Start Ttitrace With Streaming Mode    2
    Trigger BLER To GNB
    Sleep    5s    reason=Wait for Bler triggered
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
    Check Scell RlqAlgorithm for BB07 case    2
    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
    SA 5G Detach    ${UE_ID}

CB006137-ET-BB009_UE_move_to_Scell_Uplink_bad_RLQ_with_64QAM_configuration
    [Tags]     caseBB009    suqian
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB012}	
    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB009_SCF}    iphy_file=${IPHY_1F_1T}    swconfig_param=${SWCONFIG_PARAM_BB012}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}
    ...        AND    Common Test Setup 2	
    SA Attach    ${UE_ID}
    Scell Addition Triggered By A1 Event    ${UE_ID}
    Get And Check Scell Infos    ${2CC_1F1T_SCELL}
    Start SA UL Big Traffic Internal    ${UE_ID}    mbps=100
    Sleep    10s    reason=Wait for traffic stable
    Check UL TP On Target    ${UE_ID}    0    1    50
    Start SA DL Big Traffic Internal    ${UE_ID}    mbps=400	
    Sleep    10s    reason=Wait for traffic stable
    Check DL TP On Target   ${UE_ID}    0    1    200
    Capture And Decode TTitrace
    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1/
    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1/
    Check pcell and Scell Suspend Resume When Bad RLQ
	
*** Keywords ***
