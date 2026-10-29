*** Settings ***
Documentation    ...
##Test Setup         Common Test Setup
#Test Teardown      Common Test Teardown    debug
#Suite Teardown     Common Suite Teardown    debug
#Force Tags         CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G
#...                SBTS00    CN1_SG06_SM1    CB008950    owner_qiaren
#
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_FILE}                8950_2F_6T_SCF_A301.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_2F_4T}               ${CURDIR}/Config/wts/iphy_2F_6T.xml
##${SWCONFIG_PARAM_GNB}      0x58057F=16;0x580641=1;0x58057a=3;0x58062d=1;0x580692=1
#${WTS_CFG}                  CB008950_2F_6T.cfg
#
#@{2CA_UE_LIST}               1    2    3
#@{2CC_DL_TPUT_LIST}          58    380
#@{2CC_UL_TPUT_LIST}          30    30
#@{UE1_SCELL_PHYSICALID_LIST}       60
#@{UE2_SCELL_PHYSICALID_LIST}       61
#@{UE3_SCELL_PHYSICALID_LIST}       62
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB008950_ET_A301_Scell_Selection_During_A1_Scell_Addition_Euqal_ScellPrio
#    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_2F_4T}
#    #[Setup]    Run Keywords      Suite Setup Update GNB    force_reboot=True
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...        AND    Common Test Setup
#    SA 5G CA Attach    ue_id=1    pdu_id=1
#    Trigger A1 Scell Addition    ue_id=1    srsrp_nr=110    phycell_id=50
#    Check SA All Scell PhysicalID With UE ID    ue_id=1    scell_physicalid_list=${UE1_SCELL_PHYSICALID_LIST}    cc_num=2
#
#    SA 5G CA Attach    ue_id=2
#    Trigger A1 Scell Addition    ue_id=2    srsrp_nr=110    phycell_id=50
#    Check SA All Scell PhysicalID With UE ID    ue_id=2    scell_physicalid_list=${UE2_SCELL_PHYSICALID_LIST}    cc_num=2
#
#	SA 5G CA Attach    ue_id=3
#    Trigger A1 Scell Addition    ue_id=3    srsrp_nr=110    phycell_id=50
#    Check SA All Scell PhysicalID With UE ID    ue_id=3    scell_physicalid_list=${UE3_SCELL_PHYSICALID_LIST}    cc_num=2
#
#    SA Multi UE Start DL And UL Traffic    ue_id_list=${2CA_UE_LIST}    dl_mbps=500    ul_mbps=60
#    Sleep   20s    reason=wait for data is stable
#    Log To Console   xsf sleep 20s............
#    #Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CA_UE_LIST}    ${2CC_UL_TPUT_LIST}    ${2CC_DL_TPUT_LIST}    2
#    Check Multi UE DLCA And ULnonCA L1 Cell tput    ue_id_list=${2CA_UE_LIST}    exp_ul_tput=30    exp_dl_tput_list=${2CC_DL_TPUT_LIST}    cc_num=2
#
#    Capture Logs And Check TTitrace    log_idx=1
#
#*** Keywords ***
#Capture Logs And Check TTitrace
#    [Arguments]    ${log_idx}
#    #Capture BIP Log By Admin Method    capture_time=2s    log_subdir=BIP/${log_idx}
#    CUDU_L2 Capture And Decode TTitrace    log_id=${log_idx}    duration=1
#    CUDU_L2 Check DTXNACK Rate    log_id=${log_idx}
#    CUDU_L2 Check UL DTXCRC Rate    log_id=${log_idx}
