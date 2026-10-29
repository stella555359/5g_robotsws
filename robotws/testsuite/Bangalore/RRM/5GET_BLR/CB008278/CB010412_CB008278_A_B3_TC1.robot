*** Settings ***
Force Tags      CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED


Resource         ../CB007145/resources/common/CB007145_Resource.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/AIC_Common_Keywords.robot
Resource         ../resources/robot/Common_Keywords.robot
Resource            ../resources/robot/common_log_collection.robot
Resource            ../resources/robot/Airphone.robot
Resource            ../resources/robot/WTS_Runner_Keywords.robot
Resource          ../resources/robot/configuration_id.robot
Library             ../resources/python/IphyUpdate.py
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner

Suite Setup         Run keywords     Test Suite Setup
...                 AND              AIC Software Build Info
...                 AND              Fetch Taf Library used in TL
...                 AND              Prepare AIC TL with all config files   ${VCU_SCF_PATH}    ${VDU_SCF_PATH}    ${RMOD_name}   ${iphy_file_path}
...                 AND    log to console   loading cfg file....
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}


Suite Teardown      Run Keyword     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Documentation
...
...             author:            Mundanad Vishnu
...             maintainer:        mundanad.vishnu@nokia.com
...
...             INTRODUCTION:     Multiple UE SA data call on 10MHZ TDD with Frame Strcuture 5GC001208 and CB006878 enable
...             TEST SET NAME:    CB008278-A Basic 10 MHz support for CHILE AEHC
...             TESTING SPLIT:    Refer CB008278 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB010412 CFAM, CB008278 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_18745, 5G_RAN_USR_RRM_20066



*** Variables ***

${RMOD_name}        AEHC
${wts_cfg_file}     ${CURDIR}/config/basic_10Mhz_Aic.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      ${1}
${sa_ue_id2}      ${2}
${sa_ue_id3}      ${3}
${gscn_value}     6483

${VDU_SCF_PATH}         ${CURDIR}/config/vDU_8278.xml
${VCU_SCF_PATH}         ${CURDIR}/config/vCU_8278.xml
${iphy_file_path}       ${CURDIR}/config/iphy_10Mhz_Aic.xml



*** Test Cases ***
[1]CB008278-A#B3_TC1_MultipleUE_SA_call_TDD_10MHz_CB006878_enable_frameStructureType_5GC001208
    [Setup]         Run keywords    Log to console     \n-----> Test Setup <-----
    ...             AND             Testcase Setup

    set test variable      ${LOG_PATH}
    Start Syslog Monitoring
    Start CPIF_CPRT Monitoring
    log to console   UE attach trigerring now...
    sleep     30s
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
#Step 1. Attach SA UE-1,2,3 on cell-1 and Start Data Traffic
    MultiUE Register should be Successful    ${sa_ue_id1}    ${sa_ue_id3}     ${1}    ${1}
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id3}   Traffic_rate=mbps     dl_rate=150
    ...    pdu_id=${1}     trf_id=${1}   qfi_id=${1}
    MultiUE Trigger UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id3}   Traffic_rate=mbps     ul_rate=15
    ...    pdu_id=${1}     trf_id=${1}   qfi_id=${1}
    sleep  30s
    Validate DL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id3}   dl_rate=35   pdu_id=${1}     qfi_id=${1}
    Validate UL Traffic For MultiUE for SA    ${sa_ue_id1}    ${sa_ue_id3}   ul_rate=4    pdu_id=${1}     qfi_id=${1}
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id3}
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id3}
    Stop and Collect CPIF_CPRT Monitoring
    Stop and Collect Syslog Monitoring
