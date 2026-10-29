*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    VRF4_SG11    CB011080    owner_suxu
#Resource          resources/CB011080_resource.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_FILE}                Full_SCF_CB011080_A201.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_XML}                 ${CURDIR}/Config/wts/iphy_CB011080.xml
#${WTS_CFG}                  basic_CB011080.lua
#${SWCONFIG_PARAM_GNB}       0x890071=1
#${UE_1}                     1
#${UE_7}                     7
#${AMF1_REGION}              1:2:2
#${AMF2_REGION}              2:3:3
#${5CC}                      5
#${6CC}                      6
#@{5CC_DL_TPUT_LIST}         280    180    135    150    200
#@{6CC_DL_TPUT_LIST}         280    35    180    135    150    200
#@{2CC_UL_TPUT_LIST}         40    45
#
#@{5CC_SCELL_PCI_1}          52    53    54    55
#@{6CC_SCELL_PCI_3T3F}       51    52    53    54    55
#
#
#*** Test Cases ***
#CB011080_ET_A201_Verify_Feature_Deactivation_Via_MaxNumSCellsDlFr1
#    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}    #swconfig_param=${SWCONFIG_PARAM_GNB}
#    ...        AND    Configure IP For UEC2
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...        AND    Common Test Setup
#    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
#    Single Ue Attach    ${UE_1}    ${AMF1_REGION}
#    Check SA All Scell PhysicalID With UE ID    ${UE_1}    ${6CC_SCELL_PCI_3T3F}    ${6CC}
#    Start SA UE Big DL Traffic Internal    ${UE_1}    1300
#    Sleep    30s    reason=wait 30s for traffic statble
#    Wait Until Keyword Succeeds    30s    10s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_1}    ${6CC_DL_TPUT_LIST}    ${6CC}
#    Deactivation 6CC Via maxNumSCellsDlFr1
#
#*** Keywords ***
#Deactivation 6CC Via maxNumSCellsDlFr1
#    [Documentation]    This keyword is to verify Deactivate CB011080 by setting NRBTS/NRCELL.maxNumSCellsDlFr1 = 4 for cell 7
#    ...    NRRELs for cell 7 is: cell 2/3/4/5/6 to setup 3T3F CA.
#    ...    Fdd cell 1:40MHz, Fdd cell 2:10MHz, Fdd cell 3:40MHz, Fdd cell 4:30MHz
#    ...    Tdd cell 5:40MHz, Tdd cell 6:60MHz, Tdd cell 7:80MHz
#    ...    UE1 Tdd cell 7+Fdd cell 2+Fdd cell 3+Fdd cell 4+Tdd cell 5+Tdd cell 6
#    ...    UE7 Tdd cell 7+Fdd cell 3+Fdd cell 4+Tdd cell 5+Tdd cell 6
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-7    maxNumScellsDlFr1    4
#    Single Ue Attach    ${UE_7}    ${AMF2_REGION}
#    Check SA All Scell PhysicalID With UE ID    ${UE_7}    ${5CC_SCELL_PCI_1}    ${5CC}
#    Start SA UE Big DL Traffic Internal    ${UE_7}    1200
#    Sleep    20s    reason=wait 20s for traffic statble
#    Wait Until Keyword Succeeds    30s    10s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_7}    ${5CC_DL_TPUT_LIST}    ${5CC}
#
#    Start SA UE Big UL Traffic Internal    ${UE_1}    150
#    Start SA UE Big UL Traffic Internal    ${UE_7}    150
#    Sleep    20s    reason=wait 20s for traffic statble
#    Wait Until Keyword Succeeds    30s    10s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_1}    ${6CC_DL_TPUT_LIST}    ${6CC}
#    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_7}    ${5CC_DL_TPUT_LIST}    ${5CC}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_1}    ${2CC_UL_TPUT_LIST}    ${6CC}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_7}    ${2CC_UL_TPUT_LIST}    ${5CC}
