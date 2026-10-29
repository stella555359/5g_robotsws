*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=0x580692=1;
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    RAN_5G    Owner_w13li    CN1_SQ6
#...               CB009169
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}       ${CURDIR}/Config
#${FULL_SCF}       9169_SCF_AWHHF_100M_AHLOA_10M_902.xml
#${IPHY_FILE}      ${CURDIR}/Resources/wts/iphy_AWHHF_AHLOA_902.xml
#${WTS_LOCAL}      ${CURDIR}/Resources/wts
#${WTS_CFG}        CB009169_BE_902.cfg
#${WTS_AP_XML}     airphone.xml
#${WTS_DIR}        /opt/wts/latest
#${DL_TRF}         900
#${UL_TRF}         200
#${UE}             1
#${PCELL}          50
#${SCELL}          51
#${RSRP}           100
#${DL_PEAK}        830
#${UL_PEAK}        120
#${RSRP_A2}        30
#
#*** Test Cases ***
#CB009169_ET_BE902_T_F_100Mhz_10Mhz_1UE_TDD_CPRI_Cell_As_Pcell_ABIO_Scell_A1_AddItion_A2_Release
#    #Set Reordering Timer    500    300
#    SA 5G CA Attach    ${UE}
#    Trigger A1 Scell Addition    ${UE}    ${RSRP}    ${PCELL}
#    Check SA Scell PhysicalID With UE ID     ${UE}    ${SCELL}    1
#    Start SA UE Big DL Traffic Internal    ${UE}    ${DL_TRF}
#    Start SA UE Big UL Traffic Internal    ${UE}    ${UL_TRF}
#    Wait Until Keyword Succeeds    5min    6s    Check CA Cell Sum Average Throughput    ${UE}    dl    ${DL_PEAK}    2
#    Wait Until Keyword Succeeds    5min    6s    Check CA Cell Sum Average Throughput    ${UE}    ul    ${UL_PEAK}    2
#    Trigger A2 Scell Release    ${UE}    1    ${RSRP_A2}    ${PCELL}
#    Trigger A1 Scell Addition    ${UE}    ${RSRP}    ${PCELL}
#    Wait Until Keyword Succeeds    5min    6s    Check CA Cell Sum Average Throughput    ${UE}    dl    ${DL_PEAK}    2
#    Wait Until Keyword Succeeds    5min    6s    Check CA Cell Sum Average Throughput    ${UE}    ul    ${UL_PEAK}    2
#    SA 5G Detach    ${UE}
#
#
