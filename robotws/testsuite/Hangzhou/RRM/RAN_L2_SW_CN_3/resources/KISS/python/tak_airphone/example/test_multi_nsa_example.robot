*** Settings ***
Resource     ../../../robot/common_resource.robot
Library    taf.wts.config

Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

*** Variables ***
${UE_ID_STR_1}            3...6,8
${UE_ID_STR_2}            2,5...7,9
${UE_ID}                  1

*** Test Cases ***
Multi UE NSA Example
    #BTS state is configured and RRU is online
    #Releated parameters is set correctly
    #Cell is up
    UEs can attach successfully to 5G cell


*** Keywords ***
Releated parameters is set correctly
    Backup Scf    ${TEST_LOG_DIRECTORY()}    after_commission_scf.xml
    Download All Common Config Files From Golden Server
    Find Match WTS CFG Files And Copy To WorkSpace    scfc_file=${TEST_LOG_DIRECTORY()}/after_commission_scf.xml
    Load Cfg    ${WTS_CFG_FULL_PATH}
    Add Ue     1-10    NSA    cell=1    change_pdn_ip=${True}
    Save Cfg    ${WTS_CFG_FULL_PATH}

Cell is up
    Modify TL VM And AP SCTP Configuration
    Start WTS And Wait BTS Until Onair    ${WTS_CFG_FULL_PATH}

UEs can attach successfully to 5G cell
    Airphone NSA Attach    ${UE_ID_STR_1}
    Airphone NSA Attach    ${UE_ID}
    Wait Stable Timer    1s
    DL and UL data is normal
    Airphone NSA Detach    ${UE_ID_STR_1}
    Wait Stable Timer    2s
    Airphone NSA Attach    ${UE_ID_STR_2}
    Wait Stable Timer    5s
    Airphone NSA Detach All

Wait Stable Timer
    [Arguments]    ${time}
    Sleep    ${time}

BTS state is configured and RRU is online
    Reboot TestLine And Make Sure GNB is Configured

DL and UL data is normal
    Airphone NSA Start Data Traffic    ${UE_ID}     DL    100M
    Airphone NSA Start Data Traffic    ${UE_ID}     UL    50M
    Wait Throughput Timer    10s
    ${nsa_dl_tput}=    Airphone NSA Get Throughput        ${UE_ID}     DL
    ${nsa_ul_tput}=    Airphone NSA Get Throughput        ${UE_ID}     UL
    Airphone NSA Stop Data Traffic     ${UE_ID}     DL
    Airphone NSA Stop Data Traffic     ${UE_ID}     UL
    ${dl_assert_status}=    Evaluate    100*1000*0.5<int(${nsa_dl_tput})
    ${ul_assert_status}=    Evaluate    50*1000*0.5<int(${nsa_ul_tput})
    Should Be True    ${dl_assert_status}
    Should Be True    ${ul_assert_status}

