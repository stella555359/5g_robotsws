*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    CN1_SQ6    CB011081
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./Resources/CB011081_resource.robot
#
#*** Variables ***
#### Suite level ###
#${SCF_PATH}                     ${CURDIR}/Config
#${WTS_CFG}                      basic_CB011081_A101_A201.cfg
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${IPHY}                         ${CURDIR}/Resources/wts/iphy_CB011081.xml
#@{LOG_NAME_LIST}                snapshot    btsLog
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#${UEC_REACTION_TIME}            100
#### A101 ###
#${FULL_SCF_CB011081_A101}       Full_SCF_CB011081_A101.xml
#${5CC_DL_DATA_001}              1000
#${5CC_UL_DATA_001}              100
#${6CC_DL_DATA_001}              1400
#${6CC_UL_DATA_001}              100
#@{5CC_SCELL_PCI_1}              53    54    55    56
#@{6CC_SCELL_PCI_1}              50    51    53    55    56
#${UE3}                          3
#${UE8}                          8
#${5CC_NUM}                      5
#${6CC_NUM}                      6
#@{5CC_EXP_DL_TPUT_LIST_001}     10    10    10    10    10
#@{6CC_EXP_DL_TPUT_LIST_001}     10    10    10    10    10    10
#@{2CC_EXP_UL_TPUT_LIST_001}     10    10
#
#*** Test Cases ***
#CB011081_ET_A101_Activate_Feature_With_FDD_As_Pcell_For_DL_6CC_CA
#    [Tags]    Owner_zbu    CRT
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_CB011081_A101}    iphy_file=${IPHY}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#    ...    AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...    AND    Common Test Setup
#    CA UE Attach And Start DL UL Traffic
#    ...    ${UE8}    ${5CC_SCELL_PCI_1}    ${5CC_NUM}    ${5CC_DL_DATA_001}    ${5CC_UL_DATA_001}
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-3    maxNumScellsDlFr1    5
#    CA UE Attach And Start DL UL Traffic
#    ...    ${UE3}    ${6CC_SCELL_PCI_1}    ${6CC_NUM}    ${6CC_DL_DATA_001}    ${6CC_UL_DATA_001}
#    Wait Until Keyword Succeeds    60s    3sec
#    ...    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE8}    ${5CC_EXP_DL_TPUT_LIST_001}    ${5CC_NUM}
#    Wait Until Keyword Succeeds    60s    3sec
#    ...    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE8}    ${2CC_EXP_UL_TPUT_LIST_001}    ${5CC_NUM}
#    Wait Until Keyword Succeeds    60s    3sec
#    ...    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE3}    ${6CC_EXP_DL_TPUT_LIST_001}    ${6CC_NUM}
#    Wait Until Keyword Succeeds    60s    3sec
#    ...    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE3}    ${2CC_EXP_UL_TPUT_LIST_001}    ${6CC_NUM}
#    [Teardown]    Common Test Teardown
