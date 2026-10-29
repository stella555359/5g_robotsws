*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT
#...               SBTS00    CN1_SQ6    CB009855
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#### Common parameters ###
#${SWCONFIG_PARAM}
#${SCF_PATH}                    ${CURDIR}/Config
#${WTS_LOCAL}                   ${CURDIR}/Resources/wts
#${WTS_CFG}                     basic_A009_A013.cfg
#${3T3F_IPHY}                   ${CURDIR}/Resources/wts/iphy_3T_3F.xml
#${BIP_CSV_NAME}                5GBipL2L1_filtering_off.csv
#${FILTER}                      uldata_pucchreceiverespps || uldata_puschreceiverespharqd || uldata_puschreceiverespps
#@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot    3gpp.rnti    uci.pusch.part1bits    data.data
#${PREFERENCE}                  preferences_A009_A013
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#### A016 ###
#${FULL_SCF_CB009855_ET_A016}       FULL_CB009855_robustness_SCF.xml
#${UE1}                         1
#${UE2}                         2
#@{5CC_SCELL_PCI}               51    52    53    54
#@{5CC_CHECK}                   ${5CC_SCELL_PCI}
#${DL_DATA_016}                 1500
#${UL_DATA_016}                 100
#${5CC_NUM}                     5
#@{2CC_EXP_UL_TPUT_LIST_016}    10    5
#@{5CC_EXP_DL_TPUT_LIST_016}    50    10    50    50    10
#${SRSRP_NR}                    105
#${PCELL_ID}                    55
#${TIMER}                       5s
#
#*** Test Cases ***
#CB009855-ET-A016_Verify_3T2F_DL_CA_With_Scell_Lock
#    [Tags]    Owner_zbu
#    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_CB009855_ET_A016}    iphy_file=${3T3F_IPHY}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    5CC UE Attach And A1 Triggered    ${UE1}
#    Scell Locked And Unlocke Several Times
#    Start Gnb BIP Log
#    5CC UE Attach And A1 Triggered    ${UE2}
#    Capture Convert Format Ttitrace With Streaming Mode    3s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/BIP/
##    [Teardown]    Test Teardown Recover Env    scf_file=${SCF_TEST_BAK_FILE}    iphy_file=${IPHY_TEST_BAK_FILE}
#    [Teardown]    Common Test Teardown
#
#
#*** Keywords ***
#5CC UE Attach And A1 Triggered
#    [Arguments]    ${ue_id}
#    UE Attach And Start DL UL Big Traffic
#    ...    ${ue_id}    ${5CC_SCELL_PCI}    ${5CC_NUM}    ${DL_DATA_016}    ${UL_DATA_016}
#    Check 5CC CA UE DL And UL Pcell Scell TP On Target    ${ue_id}
#
#UE Attach And Start DL UL Big Traffic
#    [Arguments]    ${ue_id}    ${scell_physical_ids}    ${cc_num}    ${dl_data}    ${ul_data}
#    SA 5G CA Attach    ${ue_id}
#    Trigger A1 Scell Addition    ${ue_id}    ${SRSRP_NR}    ${PCELL_ID}
#    Check SA All Scell PhysicalID With UE ID      ${ue_id}    ${scell_physical_ids}    ${cc_num}
#    Start SA UE Big DL Traffic Internal    ${ue_id}    ${dl_data}
#    Log To Console    ...DL data start...
#    Sleep    ${Timer}
#    Start SA UE Big UL Traffic Internal    ${ue_id}    ${ul_data}
#    Log To Console     ...UL data start...
#    Sleep    ${TIMER}
#
#
#Check 5CC CA UE DL And UL Pcell Scell TP On Target
#    [Arguments]    ${ue_id}
#    Check UE DL All Pcell Scell TP On Target For Single UE    ${ue_id}    ${5CC_EXP_DL_TPUT_LIST_016}    ${5CC_NUM}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE     ${ue_id}    ${2CC_EXP_UL_TPUT_LIST_016}    ${5CC_NUM}
#
#Scell Locked And Unlocke Several Times
#    [Arguments]    ${item}=5
#    : FOR    ${num}    IN RANGE    1    ${item}+1
#    \   Scell Locked
#    \   Scell Unlocked
#
#
#Scell Locked
#    Log To Console    Enable graceful shutdown for cell 2...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-2    administrativeState    Locked
#    Log To Console    Enable graceful shutdown for cell 3...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-3    administrativeState    Locked
#    Log To Console    Enable graceful shutdown for cell 4...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-4    administrativeState    Locked
#    Log To Console    Enable graceful shutdown for cell 5...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-5    administrativeState    Locked
#
#Scell Unlocked
#    Log To Console    disable graceful shutdown for cell 2...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-2    administrativeState    Unlocked
#    Log To Console    disable graceful shutdown for cell 3...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-3    administrativeState    Unlocked
#    Log To Console    disable graceful shutdown for cell 4...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-4    administrativeState    Unlocked
#    Log To Console    disable graceful shutdown for cell 5...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-5    administrativeState    Unlocked
