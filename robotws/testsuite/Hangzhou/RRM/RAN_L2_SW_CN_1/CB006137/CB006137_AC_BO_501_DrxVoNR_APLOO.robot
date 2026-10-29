*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Make TL Ready
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CB006137    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_suxu    CN1_SQ6    SBTS00    SBTS23R1
#Resource          resources/6137_BO_lib.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config/
#${FULL_SCFC}                 CB006137_AC501.xml
#${IPHY_XML}                  ${CURDIR}/config/WTS/iphy_6137_AC501.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/config/WTS
#${WTS_CFG}                   basic_setup_vonr_AC501.cfg
#${CA_UE_ID}                  1
#${SCELL1_PCI}                51
#${SCELL2_PCI}                60
#${SCELL3_PCI}                61
#${GBR_TPUT_DL}               20
#${GBR_TPUT_UL}               10
#@{4CC_DL_TPUT_LIST}          35    80    300    300
#@{2CC_UL_TPUT_LIST}          18    25
#
#*** Test Cases ***
#CB006137_ET_AC501_BO_1UE_DrxVoNR_2CC_UL_CA
#    SA 5G CA Attach    ue_id=${CA_UE_ID}
#    Check SA Scell PhysicalID With UE ID    ${CA_UE_ID}    ${SCELL1_PCI}    1
#    Check SA Scell PhysicalID With UE ID    ${CA_UE_ID}    ${SCELL2_PCI}    2
#    Check SA Scell PhysicalID With UE ID    ${CA_UE_ID}    ${SCELL3_PCI}    3
#    Trigger 5QI 5 Setup    ${CA_UE_ID}
#    Trigger 5QI 1 Setup    ${CA_UE_ID}
#    Check RRC Reconfig For VoNRDrx Profile2
#    Start SA VONR GBR DL And UL Traffic    ueId=${CA_UE_ID}    qfi_id=3    dl_trf=${GBR_TPUT_DL}    ul_trf=${GBR_TPUT_UL}
#    Wait Until Keyword Succeeds    15s    5s    SA UE Check Throughput    ${CA_UE_ID}    dl_tp_threshold=19    ul_tp_threshold=0.5    qfi=3
#    Start nonGBR Traffic And Check Tput    ${CA_UE_ID}    900    60    800    35
#    Check Scell Activated And DRX Configuration    scellNum=3
#    Wait Until Keyword Succeeds    15s    5s    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${CA_UE_ID}    ${2CC_UL_TPUT_LIST}    2
#    Wait Until Keyword Succeeds    15s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${CA_UE_ID}    ${4CC_DL_TPUT_LIST}    4
#    SA UE Check Throughput    ${CA_UE_ID}    dl_tp_threshold=15    ul_tp_threshold=1    qfi=3
#    Run Keyword And Ignore Error    Capture Logs And Check TTitrace    log_idx=1
#
#*** Keywords ***
#Suite Setup Make TL Ready
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#
#Start nonGBR Traffic And Check Tput
#    [Arguments]    ${ue}    ${dl_trf}    ${ul_trf}    ${dl_peak_tput}    ${ul_peak_tput}
#    Start SA UL Big Traffic Internal    ${ue}    ${ul_trf}
#    Start SA UE Big DL Traffic Internal    ${ue}    ${dl_trf}
#    Wait Until Keyword Succeeds    30s    5s    SA UE Check Throughput    ${CA_UE_ID}    ${dl_peak_tput}    ${ul_peak_tput}    qfi=1
#Capture Logs And Check TTitrace
#    [Arguments]    ${log_idx}
#    #Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/${log_idx}
#    CUDU_L2 Capture And Decode TTitrace    log_id=${log_idx}    duration=3
#    CUDU_L2 Check DTXNACK Rate    log_id=${log_idx}
#    CUDU_L2 Check UL DTXCRC Rate    log_id=${log_idx}
