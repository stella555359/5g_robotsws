*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Make TL Ready
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CB009169    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_suxu    CN1_SQ6    SBTS00
#Resource          Resources/CB009169_Common.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/Config/
#${FULL_SCFC}                 SCF_CB009169_ET_BE.xml
#${IPHY_XML}                  ${CURDIR}/Resources/wts/iphy_CB009169_ET_BE_APLOO.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/Resources/wts
#${WTS_AP_XML}                airphone.xml
#${WTS_CFG}                   CB009169_ET_BE301.cfg
#@{5UE_LIST}                  1    2    3    4    5
#@{UE_RELEASED_LIST}          4    5
#@{2CA_UE_LIST}               1    2
#@{3NONUE_LIST}               3    4    5
#@{UE3_LIST}                  3
#@{UE6_LIST}                  6
#@{2CC_DL_TPUT_LIST}          110    30
#@{2CC_UL_TPUT_LIST}          15    20
#@{NONCA_DLTPUT_LIST}         35
#@{NONCA_DL_TPUT_LIST_2}      195
#@{2CC_SCELL_PHYSICALID_LIST}         52
#
#*** Test Cases ***
#CB009169_ET_BE301_T_F_100Mhz_20Mhz_MultiUE_Cell_Lock_With_Graceful_Cell_Shutdown_Disable_On_Scell_ABIO
#    2 CA UE Attach And 3 NonCA UE Attach
#    SA Multi UE Start DL And UL Traffic    ue_id_list=${2CA_UE_LIST}    dl_mbps=400    ul_mbps=80
#    SA Multi UE Start DL And UL Traffic    ue_id_list=${3NONUE_LIST}    dl_mbps=200    ul_mbps=80
#    Sleep   20s    reason=wait for data is stable
#    Check Multi UE DLCA And ULnonCA L1 Cell tput    ue_id_list=${3NONUE_LIST}    exp_ul_tput=20    exp_dl_tput_list=${NONCA_DLTPUT_LIST}    cc_num=1
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${2CA_UE_LIST}    ${2CC_UL_TPUT_LIST}    ${2CC_DL_TPUT_LIST}    2
#    #Capture Logs And Check TTitrace    log_idx=1
#    Set UE To Center Or Edge
#    Log To Console     Performs Cell lock on FDD cell 3...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-3    administrativeState    Locked
#    Wait Until Keyword Succeeds    2min    10s    Verify Multi UEs Released    ${UE_RELEASED_LIST}
#    SA 5G CA Attach    ue_id=6
#    Verify UE3 UE6 Is Normal
#
#
#*** Keywords ***
#Suite Setup Make TL Ready
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}    swconfig_param=0x580692=1
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1    actGrflShdn    false
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#
#2 CA UE Attach And 3 NonCA UE Attach
#    [Documentation]    This keyword is to attach 2 CA UE and 3 nonCA UE:
#	...    UE1 is in FDD cell3 center; UE2 is in FDD cell3 edge; UE3 is in either FDD cell3 center or edge;
#	...    UE4 is FDD cell3-edge UE; UE5 is FDD cell3-center UE.
#    ...    Tdd cell 11:(100MHz,band77), Fdd cell 3:(20MHz,band66)
#    ...    UE1 Tdd cell 11+Fdd cell 3
#    ...    UE2 Tdd cell 11+Fdd cell 3
#    ...    UE3 Tdd cell 11 nonCA
#    ...    UE4 Fdd cell 3 nonCA
#    ...    UE5 Fdd celSA 5G CA Attachl 3 nonCA
#    SA 5G CA Attach    ue_id=1    pdu_id=1
#    Trigger A1 Scell Addition    ue_id=1    srsrp_nr=100    phycell_id=61
#    Check SA All Scell PhysicalID With UE ID    ue_id=1    scell_physicalid_list=${2CC_SCELL_PHYSICALID_LIST}    cc_num=2
#    SA 5G CA Attach    ue_id=2
#    Trigger A1 Scell Addition    ue_id=2    srsrp_nr=100    phycell_id=61
#    Check SA All Scell PhysicalID With UE ID    ue_id=2    scell_physicalid_list=${2CC_SCELL_PHYSICALID_LIST}    cc_num=2
#    SA Multi NonCA UE Attach    ${3NONUE_LIST}
#
#Set UE To Center Or Edge
#    Set PHR Testmode    profile_id=1    phr_mode=Fixed    phr_start=0    phr_max=23
#    Set PHR Testmode    profile_id=2    phr_mode=Fixed    phr_start=30    phr_max=23
#    Set UE To Center    UE_ID=1    scell=1
#    Set UE To Edge    UE_ID=2    scell=1
#    Set UE To Edge    UE_ID=4    scell=0
#    Set UE To Center    UE_ID=5    scell=0
#
#Verify UE3 UE6 Is Normal
#    SA Multi UE Start DL And UL Traffic    ue_id_list=${UE6_LIST}    dl_mbps=300    ul_mbps=80
#    Check Multi UE DLCA And ULnonCA L1 Cell tput    ue_id_list=${UE3_LIST}    exp_ul_tput=65    exp_dl_tput_list=${NONCA_DL_TPUT_LIST_2}    cc_num=1
#    Wait Until Keyword Succeeds    1min    10s   Check Multi UE DLCA And ULnonCA L1 Cell tput    ${UE6_LIST}    20    ${NONCA_DL_TPUT_LIST_2}    1
#
#Capture Logs And Check TTitrace
#    [Arguments]    ${log_idx}
#    #Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/${log_idx}
#    CUDU_L2 Capture And Decode TTitrace    log_id=${log_idx}    duration=3
#    CUDU_L2 Check DTXNACK Rate    log_id=${log_idx}
#    CUDU_L2 Check UL DTXCRC Rate    log_id=${log_idx}
#
