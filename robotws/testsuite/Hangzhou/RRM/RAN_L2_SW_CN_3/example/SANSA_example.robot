*** Settings ***
Documentation    Author: lily.l.xu@nokia-sbell.com
...              \n SANSA L3 call example case for RAN HZ L2 SW3.

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown

Resource          ../resources/KISS/robot/common_resource.robot
Force Tags        CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD    CLOUD_5G_I_KL_AP_KL_SANSA_L1B_CPRI_CMWV_TDD    Owner_lilxu

*** Variables ***
${NSA_UE_ID}    11
${SA_UE_ID}     1
${PDU_ID}       1
${GW_ID}        1
${SLICE_ID}     1


*** Test Cases ***
SANSA Example Case
    BTS state is configured and RRU is online
    Download all config files
    Cell is up
    NSA UE can attach successfully to 5G cell
    NSA DL and UL data is normal
    Set traffic type to internal
    SA UE can attach successfully to 5G cell
    SA DL and UL data is normal
    NSA UE can detach successfully
    SA UE can detach successfully

*** Keywords ***
BTS state is configured and RRU is online
    Reboot TestLine And Make Sure GNB is Configured

Download all config files
    Backup Scf    ${TEST_LOG_DIRECTORY()}    after_commission_scf.xml
    Download All Common Config Files From Golden Server
    Find Match WTS CFG Files And Copy To WorkSpace    scfc_file=${TEST_LOG_DIRECTORY()}/after_commission_scf.xml

Cell is up
    Modify TL VM And AP SCTP Configuration
    Start WTS And Wait BTS Until Onair    ${WTS_CFG_FULL_PATH}    timeout=480

NSA UE can attach successfully to 5G cell
    Airphone NSA Attach    ${NSA_UE_ID}

NSA DL and UL data is normal
    Airphone NSA Start Data Traffic    ${NSA_UE_ID}     DL    100M
    Airphone NSA Start Data Traffic    ${NSA_UE_ID}     UL    50M
    Wait Throughput Timer    10s
    ${nsa_dl_tput}=    Airphone NSA Get Throughput        ${NSA_UE_ID}     DL
    ${nsa_ul_tput}=    Airphone NSA Get Throughput        ${NSA_UE_ID}     UL
    Airphone NSA Stop Data Traffic     ${NSA_UE_ID}     DL
    Airphone NSA Stop Data Traffic     ${NSA_UE_ID}     UL

NSA UE can detach successfully
    Airphone NSA Detach    ${NSA_UE_ID}

Set traffic type to internal
    Airphone Set Traffic Type    ${SA_UE_ID}    ${PDU_ID}    internal

SA UE can attach successfully to 5G cell
    Airphone SA Attach    ${SA_UE_ID}    300
    Airphone Pdu Session Setup    ${SA_UE_ID}    ${PDU_ID}    ${SLICE_ID}   ${GW_ID}

SA DL and UL data is normal
    Airphone SA Start Data Traffic    ${SA_UE_ID}     DL    100M    pdu_id=${PDU_ID}
    Airphone SA Start Data Traffic    ${SA_UE_ID}     UL    50M     pdu_id=${PDU_ID}
    Wait Throughput Timer    10s
    ${sa_dl_tput}=    Airphone SA Get Throughput        ${SA_UE_ID}     DL    ${PDU_ID}
    ${sa_ul_tput}=    Airphone SA Get Throughput        ${SA_UE_ID}     UL    ${PDU_ID}
    Airphone SA Stop Data Traffic     ${SA_UE_ID}     BI    ${PDU_ID}

SA UE can detach successfully
    Airphone SA Detach    ${SA_UE_ID}



