*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    master_classicalbts_all    STATE_CONFIGURED
#...               CRT    RAN_5G    FR1    SBTS00    CN1_SQ6    CB009855
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./Resources/CB009855_resource.robot
#
#*** Variables ***
#### Common parameters ###
#${SCF_PATH}                      ${CURDIR}/Config
#${WTS_LOCAL}                     ${CURDIR}/Resources/wts
#${WTS_CFG}                       basic_B1500.cfg
#${3T3F_IPHY}                     ${CURDIR}/Resources/wts/iphy_B1500_3T3F.xml
#@{UE_LIST}                       1    2    3    4    5    6
#@{5CC_SCELL_PCI}                 51    52    53    54
#@{SCELL_PHYSICALID_LIST}         ${5CC_SCELL_PCI}    ${5CC_SCELL_PCI}    ${5CC_SCELL_PCI}    ${5CC_SCELL_PCI}    ${5CC_SCELL_PCI}
#...                              ${5CC_SCELL_PCI}
#${DL_DATA}                       480
#${UL_DATA}                       50
#${5CC_NUM}                       5
#@{2CC_EXP_UL_TPUT_LIST}          10    2
#@{5CC_EXP_DL_TPUT_LIST}          50    10    10    10    10
#${FULL_SCF_CB009855_ET_B1500}    Full_SCF_CB009855_ET_B1500.xml
#@{LOG_NAME_LIST}                 snapshot    btsLog    sosreport
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB009855-ET-B1501_Verify_5CC_DL_CA_IWK_with_ACSI_when_have_UL_data
#    [Tags]    Owner_y7li
#    Run Keywords    Test Setup Update GNB    scf_file=${Full_SCF_CB009855_ET_B1500}    iphy_file=${3T3F_IPHY}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    Start Gnb BIP Log
#    SA Multi UE Attach With Scell Blind Addition    ${UE_LIST}    ${SCELL_PHYSICALID_LIST}    ${5CC_NUM}
#    Trigger CQI Jitter
#    SA Multi UE Start DL And UL Traffic    ${UE_LIST}    ${DL_DATA}    ${UL_DATA}
#    Capture Convert Format Ttitrace With Streaming Mode    0.5s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    Wait Until Keyword Succeeds    30s    5sec    Check Multi UE DLCA Cell L1 Tput    ${UE_LIST}    ${5CC_EXP_DL_TPUT_LIST}    ${5CC_NUM}
#    Wait Until Keyword Succeeds    30s    5sec    Check Multi UE ULCA Cell L1 Tput    ${UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${5CC_NUM}
#    SA Multi UE Stop DL Traffic    ${UE_LIST}
#    SA Multi UE Stop UL Traffic    ${UE_LIST}
#    A2A Check ACSI On PUSCH
#    [Teardown]    Common Test Teardown
#
#CB009855-ET-B1502_Verify_5CC_DL_CA_IWK_with_ACSI_when_no_UL_data
#    [Tags]    Owner_y7li
#    Run Keywords    Clear Egate
#    ...    AND    Test Setup Update GNB    scf_file=${Full_SCF_CB009855_ET_B1500}    iphy_file=${3T3F_IPHY}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    Start Gnb BIP Log
#    SA Multi UE Attach With Scell Blind Addition    ${UE_LIST}    ${SCELL_PHYSICALID_LIST}    ${5CC_NUM}
#    Trigger CQI Jitter
#    SA Multi UE Start DL Traffic    ${UE_LIST}    ${DL_DATA}
#    Start Ttitrace With Streaming Mode
#    Sleep    0.8s    reason=capture short ttitracelog
#    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    Wait Until Keyword Succeeds    30s    5sec    Check Multi UE DLCA Cell L1 Tput    ${UE_LIST}    ${5CC_EXP_DL_TPUT_LIST}    ${5CC_NUM}
#    SA Multi UE Stop DL Traffic    ${UE_LIST}
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#    A2A Check ACSI UCI Only
#    [Teardown]    Test Teardown Recover Env    scf_file=${SCF_TEST_BAK_FILE}    iphy_file=${IPHY_TEST_BAK_FILE}
#
#*** Keywords ***
#Trigger CQI Jitter
#    ute_wtssim.Execute Egate Command    cmd=csi_override_testmode_nr profile_id=4 cqi_mode=varying cqi=6,8,15,11,13,12,4,10,9,7,5,2,1,3,14
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=1,2,3,4,5,6 scell=0 testmode=csi_override profile_id=4 action=activate
#
#A2A Check ACSI On PUSCH
#    ${UE1_CRNTI}=    Get Crnti From Egate Log    1
#    Set Suite Variable    ${UE1_CRNTI}
#    ${UE2_CRNTI}=    Get Crnti From Egate Log    2
#    Set Suite Variable    ${UE2_CRNTI}
#    ${UE3_CRNTI}=    Get Crnti From Egate Log    3
#    Set Suite Variable    ${UE3_CRNTI}
#    ${UE4_CRNTI}=    Get Crnti From Egate Log    4
#    Set Suite Variable    ${UE4_CRNTI}
#    ${UE5_CRNTI}=    Get Crnti From Egate Log    5
#    Set Suite Variable    ${UE5_CRNTI}
#    ${UE6_CRNTI}=    Get Crnti From Egate Log    6
#    Set Suite Variable    ${UE6_CRNTI}
#    Check Log With Au2anlysis    ${CURDIR}/A2A/CB009855_B/B1500_a2a.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#
#A2A Check ACSI UCI Only
#    ${UE1_CRNTI}=    Get Crnti From Egate Log    1
#    Set Suite Variable    ${UE1_CRNTI}
#    ${UE2_CRNTI}=    Get Crnti From Egate Log    2
#    Set Suite Variable    ${UE2_CRNTI}
#    ${UE3_CRNTI}=    Get Crnti From Egate Log    3
#    Set Suite Variable    ${UE3_CRNTI}
#    ${UE4_CRNTI}=    Get Crnti From Egate Log    4
#    Set Suite Variable    ${UE4_CRNTI}
#    ${UE5_CRNTI}=    Get Crnti From Egate Log    5
#    Set Suite Variable    ${UE5_CRNTI}
#    ${UE6_CRNTI}=    Get Crnti From Egate Log    6
#    Set Suite Variable    ${UE6_CRNTI}
#    Check Log With Au2anlysis    ${CURDIR}/A2A/CB009855_B/B1500_a2a_noULTHP.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace_streaming/
