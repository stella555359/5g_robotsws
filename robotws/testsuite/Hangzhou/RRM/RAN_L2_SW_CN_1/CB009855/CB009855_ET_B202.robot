*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown    debug
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    CN1_SQ6    CB009855
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#### Suite level ###
#${SCF_PATH}                     ${CURDIR}/Config
#${WTS_CFG_3T3F}                 basic_B202_IWK_DLCA.cfg
#${WTS_LOCAL}                    ${CURDIR}/Resources/wts
#${3T3F_IPHY}                    ${CURDIR}/Resources/wts/iphy_B202_3T3F.xml
#@{LOG_NAME_LIST}                snapshot    btsLog
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#### B202 ###
#${FULL_SCF_CB009855_B202}        FULL_SCF_CB009855_B202_IWK_DLCA.xml
#@{UE_LIST_B202}                  1    2    3    4
#@{3T2F_SCELL_PCI_B202}           50    51    52    53
#@{2T3F_SCELL_PCI_B202}           50    51    53    54
#@{3F2T_SCELL_PCI_B202}           50    52    54    55
#@{2F3T_SCELL_PCI_B202}           50    52    53    55
#@{SCELL_PCI_LIST_B202}           ${3T2F_SCELL_PCI_B202}    ${2T3F_SCELL_PCI_B202}    ${3F2T_SCELL_PCI_B202}           ${2F3T_SCELL_PCI_B202}
#${DL_DATA_B202}                  500
#${UL_DATA_B202}                  50
#${CC_NUM}                        5
#@{UE_LIST_3T2F}                  1
#@{UE_LIST_2T3F}                  2
#@{UE_LIST_3F2T}                  3
#@{UE_LIST_2F3T}                  4
#@{3T2F_EXP_DL_TPUT_LIST_B202}    200    10    10    70    70
#@{3T2F_EXP_UL_TPUT_LIST_B202}    20    2
#@{2T3F_EXP_DL_TPUT_LIST_B202}    200    10    10    100    20
#@{2T3F_EXP_UL_TPUT_LIST_B202}    20    2
#@{3F2T_EXP_DL_TPUT_LIST_B202}    10    10    100    20    200
#@{3F2T_EXP_UL_TPUT_LIST_B202}    5    20
#@{2F3T_EXP_DL_TPUT_LIST_B202}    10    10    70    70    200
#@{2F3T_EXP_UL_TPUT_LIST_B202}    5    20
#
#
#*** Test Cases ***
#CB009855-B202_Verify_UE_3T2F_2T3F_DLCA_Interworking_With_Legacy_DL_CA_5UE
#    [Tags]    Owner_fanjin    CRT
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_CB009855_B202}    iphy_file=${3T3F_IPHY}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_3T3F}
#    ...    AND    Suite Setup Start WTS And Check OnAir
#    SA Multi UE Attach With Scell Blind Addition    ${UE_LIST_B202}    ${SCELL_PCI_LIST_B202}    ${CC_NUM}
#    SA Multi UE Start DL And UL Traffic    ${UE_LIST_B202}    ${DL_DATA_B202}    ${UL_DATA_B202}
#    Sleep    10s    reason=wait for all UEs traffic statble
#    Verify Multi UE DLUL L1 Tput
#    Run Keyword And Ignore Error    Start Gnb BIP Log
#    Run Keyword And Ignore Error    Capture Convert Format Ttitrace With Streaming Mode    0.5s    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#    Run Keyword And Ignore Error    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/BIP/
#    [Teardown]    Common Test Teardown
#
#*** Keywords ***
#Verify Multi UE DLUL L1 Tput
#    Wait Until Keyword Succeeds    60s    3sec    Check Multi UE DLCA And 2CCULCA L1 Cell Tput
#    ...    ${UE_LIST_3T2F}    ${3T2F_EXP_UL_TPUT_LIST_B202}    ${3T2F_EXP_DL_TPUT_LIST_B202}    ${CC_NUM}
#    Wait Until Keyword Succeeds    60s    3sec    Check Multi UE DLCA And 2CCULCA L1 Cell Tput
#    ...    ${UE_LIST_2T3F}    ${2T3F_EXP_UL_TPUT_LIST_B202}    ${2T3F_EXP_DL_TPUT_LIST_B202}    ${CC_NUM}
#    Wait Until Keyword Succeeds    60s    3sec    Check Multi UE DLCA And 2CCULCA L1 Cell Tput
#    ...    ${UE_LIST_3F2T}    ${3F2T_EXP_UL_TPUT_LIST_B202}    ${3F2T_EXP_DL_TPUT_LIST_B202}    ${CC_NUM}
#    Wait Until Keyword Succeeds    60s    3sec    Check Multi UE DLCA And 2CCULCA L1 Cell Tput
#    ...    ${UE_LIST_2F3T}    ${2F3T_EXP_UL_TPUT_LIST_B202}    ${2F3T_EXP_DL_TPUT_LIST_B202}    ${CC_NUM}
