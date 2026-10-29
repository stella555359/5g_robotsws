*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    VRF4_SG11    CB011080    owner_zhacao
#Resource          resources/CB011080_resource.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_FILE}                Full_SCF_CB011080_A102.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_XML}                 ${CURDIR}/Config/wts/iphy_CB011080.xml
#${WTS_CFG}                  basic_CB011080.lua
#${UE_2}                     2
#${UE_8}                     8
#${AMF1_REGION}              1:2:2
#${AMF2_REGION}              2:3:3
#${5CC}                      5
#${6CC}                      6
#@{5CC_DL_TPUT_LIST}         100    100    100    80    100
#@{6CC_DL_TPUT_LIST}         100    100    50    100    80    100
#@{2CC_UL_TPUT_LIST}         25    40
#
#@{5CC_SCELL_PCI_1}          50    52    53    56
#@{6CC_SCELL_PCI_2T4F}       50    51    52    53    56
#
#
#*** Test Cases ***
#CB011080_ET_A102_Verify_UE_2T4F_Activation_6CCs_DLCA_2CCs_ULCA
#    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}
#    ...        AND    Configure IP For UEC2
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...        AND    Common Test Setup
#    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
#    Single Ue Attach    ${UE_2}    ${AMF1_REGION}
#    Check SA All Scell PhysicalID With UE ID    ${UE_2}    ${5CC_SCELL_PCI_1}    ${5CC}
#    Start SA UE Big DL Traffic Internal    ${UE_2}    1250
#    Sleep    20s    reason=wait 20s for traffic statble
#    Wait Until Keyword Succeeds    30s    10s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_2}    ${5CC_DL_TPUT_LIST}    ${5CC}
#    Activation 6CC Via maxNumSCellsDlFr1
#    Run Keyword And Ignore Error    Capture And Check TTitrace Logs    1
#
#*** Keywords ***
#Activation 6CC Via maxNumSCellsDlFr1
#    [Documentation]    This keyword is to verify activate CB011080 by setting NRBTS/NRCELL.maxNumSCellsDlFr1 = 5 for cell 6
#    ...    NRRELs for cell 6 is: cell 1/2/3/4/6 to setup 2T4F CA.
#    ...    Fdd cell 1:40MHz, Fdd cell 2:10MHz, Fdd cell 3:40MHz, Fdd cell 4:30MHz
#    ...    Tdd cell 5:40MHz, Tdd cell 6:60MHz, Tdd cell 7:80MHz
#    ...    UE2 Tdd cell 6+Fdd cell 1+Fdd cell 3+Fdd cell 4+Tdd cell 7
#    ...    UE8 Tdd cell 6+Fdd cell 1+Fdd cell 2+Fdd cell 3+Fdd cell 4+Tdd cell 7
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-6    maxNumScellsDlFr1    5
#    Single Ue Attach    ${UE_8}    ${AMF2_REGION}
#    Check SA All Scell PhysicalID With UE ID    ${UE_8}    ${6CC_SCELL_PCI_2T4F}    ${6CC}
#    Start SA UE Big DL Traffic Internal    ${UE_8}    1450
#    Sleep    20s    reason=wait 20s for traffic statble
#    Wait Until Keyword Succeeds    30s    10s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_8}    ${6CC_DL_TPUT_LIST}    ${6CC}
#
#    Start SA UE Big UL Traffic Internal    ${UE_2}    150
#    Start SA UE Big UL Traffic Internal    ${UE_8}    150
#    Sleep    20s    reason=wait 20s for traffic statble
#    Wait Until Keyword Succeeds    30s    10s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_2}    ${5CC_DL_TPUT_LIST}    ${5CC}
#    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_8}    ${6CC_DL_TPUT_LIST}    ${6CC}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_2}    ${2CC_UL_TPUT_LIST}    ${5CC}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_8}    ${2CC_UL_TPUT_LIST}    ${6CC}
