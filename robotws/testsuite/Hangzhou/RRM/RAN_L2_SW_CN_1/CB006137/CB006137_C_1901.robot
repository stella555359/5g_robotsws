*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_w13li    SBTS00    SBTS23R1
#...               CN1_SQ6    CB006137
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/config
#${FULL_SCF}         6137_C_1901_SCF.xml
#${IPHY_FILE}        ${CURDIR}/config/WTS/6137_1901_2T_3F_iphy.xml
#${WTS_LOCAL}        ${CURDIR}/config/WTS
#${WTS_CFG}          6137_C_1901.cfg
#${WTS_AP_XML}       airphone.xml
#${WTS_DIR}          /opt/wts/latest
#${UE}               1
#${PCELL}            50
#${SCELL}            60
#${DL_TRF}           300
#${UL_TRF}           150
#${PCELL_DL_PEAK}    43
#${PCELL_UL_PEAK}    16
#${SCELL_DL_PEAK}    109
#${SCELL_UL_PEAK}    14
#${RSRP}             120
#${RSRP_A2}          30
#
#*** Test Cases ***
#CB006137_ET_C1901_Single_UE_Setup_With_A1_Addition_A2_Release_FddPcell_5M_TddScell_20M_ULBuffer_Trigger
#    SA 5G CA Attach    ${UE}
#    Add And Active Scell
#    Release Scell And Add It Again
#    SA 5G Detach    ${UE}
#
#*** Keywords ***
#Check All Cell ULDL Tput
#    Wait Until Keyword Succeeds    5min    6s    Check CA UE Pcell Scell Cell TPut On Target    ${UE}    ul    pcell    0    ${PCELL_UL_PEAK}
#    Wait Until Keyword Succeeds    5min    6s    Check CA UE Pcell Scell Cell TPut On Target    ${UE}    ul    scell    1    ${SCELL_UL_PEAK}
#    Wait Until Keyword Succeeds    5min    6s    Check CA UE Pcell Scell Cell TPut On Target    ${UE}    dl    pcell    0    ${PCELL_DL_PEAK}
#    Wait Until Keyword Succeeds    5min    6s    Check CA UE Pcell Scell Cell TPut On Target    ${UE}    dl    scell    1    ${SCELL_DL_PEAK}
#
#Add And Active Scell
#    Trigger A1 Scell Addition    ${UE}    ${RSRP}    ${PCELL}
#    Start SA UE Big UL Traffic Internal    ${UE}    ${UL_TRF}
#    Sleep    2s    reason=wait for scell activation
#    Check SA Scell PhysicalID With UE ID    ${UE}    ${SCELL}    1
#    Start SA UE Big DL Traffic Internal    ${UE}    ${DL_TRF}
#    Check All Cell ULDL Tput
#
#Release Scell And Add It Again
#    Trigger A2 Scell Release    ${UE}    1    ${RSRP_A2}    ${SCELL}    2
#    Trigger A1 Scell Addition    ${UE}    ${RSRP}    ${PCELL}    3
#    Check SA Scell PhysicalID With UE ID    ${UE}    ${SCELL}    1
#    Check All Cell ULDL Tput
