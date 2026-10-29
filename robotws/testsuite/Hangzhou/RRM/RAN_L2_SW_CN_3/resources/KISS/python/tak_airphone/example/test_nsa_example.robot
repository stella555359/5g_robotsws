*** Settings ***
Resource     ../../../robot/common_resource.robot
Suite Setup        Common Suite Setup
Suite Teardown     Common Suite Teardown

*** Variables ***
${UE_ID}            1

*** Test Cases ***
NSA Example
    Releated parameters is set correctly
    Cell is up
    UE can attach successfully to 5G cell
    DL and UL data is normal

*** Keywords ***
Releated parameters is set correctly
    Backup Scf    ${TEST_LOG_DIRECTORY()}    after_commission_scf.xml
    Download All Common Config Files From Golden Server
    Find Match WTS CFG Files And Copy To WorkSpace    scfc_file=${TEST_LOG_DIRECTORY()}/after_commission_scf.xml

Cell is up
    Modify TL VM And AP SCTP Configuration
    Start WTS And Wait BTS Until Onair    ${WTS_CFG_FULL_PATH}

UE can attach successfully to 5G cell
    Airphone NSA Attach    ${UE_ID}

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
