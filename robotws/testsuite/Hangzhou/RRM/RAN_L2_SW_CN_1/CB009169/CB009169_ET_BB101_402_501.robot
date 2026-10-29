*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT
#...               SBTS00    CN1_SQ6    CB009169
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
##CB009169-ET-BB101
#${DELTA_SCF_001}               Delta_CB009169_ULCA_basic_with_PRB_Blanking.json
#${WTS_CFG_001}                 basic_setup_CB009169_BB.cfg
##CB009169_ET_BB402
#${DELTA_SCF_402}               Delta_CB009169_ULCA_402.json
#${WTS_CFG_402}                 basic_setup_CB009169_mutiue.cfg
##CB009169_ET_BB501
#${DELTA_SCF_501}               Delta_CB009169_ULCA_501.json
#${WTS_CFG_501}                 basic_setup_CB009169_mutiue.cfg
#${WTS_LOCAL}                   ${CURDIR}/Resources/wts
#${SCF_PATH}                    ${CURDIR}/Config
#${WTS_DIR}                     /opt/wts/latest
## ${SWCONFIG_PARAM}              0x580692=1
#@{SCELL_PHYSICALID_LIST}       50    52
#${2CC_UE_ID}                   1
#@{2CC_UE_ID_LIST}              1
#${2CC_DL_DATA}                 600
#${2CC_UL_DATA}                 100
#@{2CC_EXP_DL_TPUT_LIST_101}    400    30
#@{2CC_EXP_UL_TPUT_LIST_101}    25    5
#${2CC_DL_SMALL_DATA}                 80
#${2CC_UL_SMALL_DATA}                 15
#${UE_NUM}                      8
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB009169-ET-BB101_Verify_Single_UE_T_F_ULCA_Interworking_With_PRB_Blanking
#    [Tags]    Owner_fanjin
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${DELTA_SCF_001}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_001}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_001}
#    SA 5G CA Attach    ${2CC_UE_ID}
#    Trigger A1 Scell Addition    ${2CC_UE_ID}    srsrp_nr=95    phycell_id=52
#    Start SA UE Big DL Traffic Internal    ${2CC_UE_ID}    ${2CC_DL_DATA}
#    Start SA UE Big UL Traffic Internal    ${2CC_UE_ID}    ${2CC_UL_DATA}
#    Sleep    10s    reason=wair for data is stable
#    Wait Until Keyword Succeeds    60s    3sec    Check Multi UE DLCA And 2CCULCA L1 Cell Tput
#    ...    ${2CC_UE_ID_LIST}    ${2CC_EXP_UL_TPUT_LIST_101}    ${2CC_EXP_DL_TPUT_LIST_101}    2
#    Capture Convert Format Ttitrace With Streaming Mode    3s
#    Verify PDSCH Resource Schedule Behavior With PRB Blanking
#    Verify PUSCH Resource Schedule Behavior With PRB Blanking
#    [Teardown]    Common Test Teardown
#
#CB009169_ET_BB402_Verify_Single_UE_T_F_ULCA_Interworking_With_Adaptive_Retransmission_64QAM
#    [Tags]    Owner_melwu
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${DELTA_SCF_402}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_402}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_402}
#    SA 5G CA Attach    ${2CC_UE_ID}
#    Check SA All Scell PhysicalID With UE ID    ${2CC_UE_ID}    ${SCELL_PHYSICALID_LIST}    2
#    SA Start DL Traffic Internal    ue_id=${2CC_UE_ID}    pdu_id=1    mbps=${2CC_DL_DATA}    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${2CC_UE_ID}    pdu_id=1    mbps=${2CC_UL_DATA}    trf_id=1
#    Sleep    10s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CC_UE_ID_LIST}    ${2CC_EXP_UL_TPUT_LIST_101}    ${2CC_EXP_DL_TPUT_LIST_101}    2
#    Add Bler To Scell ULDL Channel    ${2CC_UE_ID}    0    40    20
#    Add Bler To Scell ULDL Channel    ${2CC_UE_ID}    1    40    20
#    Capture Convert Format Ttitrace With Streaming Mode    1s
#    Save Egate Log    ${test_log_directory}
#    Verify Regular And Reserved MCS Used
##    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}
#    [Teardown]    Common Test Teardown
#
#CB009169_ET_BB501_Verify_Multiple_UEs_T_F_UL_CA_Interworking_With_FDM_BF_Enable_WithoutBeamrefine
#    [Tags]    Owner_melwu
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${DELTA_SCF_501}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_501}
#    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_501}
#    SA Muilt UE Register And PDU Session Setup    ${UE_NUM}
#    SA Do MultiUE Traffic    ${UE_NUM}    ${2CC_DL_SMALL_DATA}    ${2CC_UL_SMALL_DATA}
#    Capture Convert Format Ttitrace With Streaming Mode    1s
#    Verify DL And UL Per Slot Ue Numbers
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#Verify PDSCH Resource Schedule Behavior With PRB Blanking
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BB${/}CB009169_BB_PrbBlanking_PDSCH.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#
#Verify PUSCH Resource Schedule Behavior With PRB Blanking
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BB${/}CB009169_BB_PrbBlanking_PUSCH.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#
#Verify Regular And Reserved MCS Used
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BB${/}CB009169_BB402.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming
#
#SA Muilt UE Register And PDU Session Setup
#    [Arguments]    ${max_ue_num}
#    : FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
#    \    SA 5G Attach    ${ue_id}
#    \    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=1
#    \    SA 5G PDU Session Setup    ue_id=${ue_id}    pdu_id=1
#
#SA Do MultiUE Traffic
#    [Arguments]    ${max_ue_num}    ${dl_tput}=60    ${ul_tput}=15
#    : FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
#    \    SA Start DL Traffic Internal    ue_id=${ue_id}    pdu_id=1    mbps=${dl_tput}    trf_id=1
#    \    SA Start UL Traffic Internal    ue_id=${ue_id}    pdu_id=1    mbps=${ul_tput}    trf_id=1
#
#Verify DL And UL Per Slot Ue Numbers
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BB${/}CB009169_BB501.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#
