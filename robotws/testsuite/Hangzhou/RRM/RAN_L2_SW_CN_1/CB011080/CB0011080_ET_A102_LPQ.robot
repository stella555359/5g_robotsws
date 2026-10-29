*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    VRF4_SG11    CB011080    owner_peafu
#Resource          resources/CB011080_resource.robot
#
#*** Variables ***
#${SCF_PATH}                ${CURDIR}/Config/
#${SCFC_FILE}               SCF_CB0011080_ET_A102_LPQ.xml
#${LOCAL_WTS_DIR}           ${CURDIR}/Config/wts/
#${WTS_DIR}                 /opt/iphy/latest
#${IPHY_XML}                ${CURDIR}/Config/wts/iphy_CB0011080_ET_A102_LPQ.xml
#${WTS_CFG}                 CB0011080_ET_A102_LPQ.cfg
#${UE_2}                    6
#${UE_8}                    60
#${5CC}                     5
#${6CC}                     6
#@{5CC_DL_TPUT_LIST_1UE}    300    70    170    60    400
#@{5CC_DL_TPUT_LIST_2UE}    180    70    120    50    230
#@{6CC_DL_TPUT_LIST_2UE}    180    70    80    120    50    230
#@{2CC_UL_TPUT_LIST_1UE}    40    70
#@{2CC_UL_TPUT_LIST_2UE}    15    30
#@{5CC_SCELL_PCI_1}         51    53    54    57
#@{6CC_SCELL_PCI_2T4F}      51    52    53    54    57
#
#*** Test Cases ***
#CB011080_ET_A102_Verify_UE_2T4F_Activation_6CCs_DLCA_2CCs_ULCA
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}
#    ...    AND    Configure IP For UEC2
#    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...    AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...    AND    Common Test Setup
#    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
#    SA 5G CA Attach    ${UE_2}    pdu_id=1
#    Run Keyword And Ignore Error    Check SA All Scell PhysicalID With UE ID    ${UE_2}    ${5CC_SCELL_PCI_1}    ${5CC}
#    Start SA UE Big DL Traffic Internal    ${UE_2}    1200
#    Start SA UE Big UL Traffic Internal    ${UE_2}    150
#    Sleep    30s    reason=wait 20s for traffic statble
#    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_2}    ${5CC_DL_TPUT_LIST_1UE}    ${5CC}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_2}    ${2CC_UL_TPUT_LIST_1UE}    ${5CC}
#    Activation 6CC Via MaxNumSCellsDlFr1
#    Run Keyword And Ignore Error    Capture And Check TTitrace Logs    1
#
#*** Keywords ***
#Activation 6CC Via MaxNumSCellsDlFr1
#    [Documentation]    This keyword is to verify activate CB011080 by setting NRBTS/NRCELL.maxNumSCellsDlFr1 = 5 for cell 6
#    ...    NRRELs for cell 6 is: cell 1/2/3/4/7 to setup 2T4F CA.
#    ...    Fdd cell 1:25MHz, Fdd cell 2:15MHz, Fdd cell 3:40MHz, Fdd cell 4:20MHz
#    ...    Tdd cell 5:80MHz, Tdd cell 6:80MHz, Tdd cell 7:100MHz
#    ...    UE2 Tdd cell 6+Fdd cell 1+Fdd cell 3+Fdd cell 4+Tdd cell 7
#    ...    UE8 Tdd cell 6+Fdd cell 1+Fdd cell 2+Fdd cell 3+Fdd cell 4+Tdd cell 7
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-6    maxNumScellsDlFr1    5
#    Sleep    100s    reason=wait for online change done
#    SA 5G CA Attach    ${UE_8}    pdu_id=1
#    Run Keyword And Ignore Error    Check SA All Scell PhysicalID With UE ID    ${UE_8}    ${6CC_SCELL_PCI_2T4F}    ${6CC}
#    Start SA UE Big DL Traffic Internal    ${UE_8}    1200
#    Start SA UE Big UL Traffic Internal    ${UE_8}    150
#    Sleep    30s    reason=wait 20s for traffic statble
#    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_2}    ${5CC_DL_TPUT_LIST_2UE}    ${5CC}
#    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_8}    ${6CC_DL_TPUT_LIST_2UE}    ${6CC}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_2}    ${2CC_UL_TPUT_LIST_2UE}    ${5CC}
#    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_8}    ${2CC_UL_TPUT_LIST_2UE}    ${6CC}
