*** Settings ***
Documentation    a example to test iperf triffic.

Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Resource          ../Airphone_resource.robot

*** Variables ***
@{ALLOWED_FAULT}

*** Test Cases ***
one UE do traffic
    [Tags]    c1
    UE Register To GNB    ue_id=1
    Wait A While
    UE Setup PDU session    ue_id=1
    iperf_dl_traffic_should_be_ok    ue_id=1
    iperf_ul_traffic_should_be_ok    ue_id=1
    UE Deregister From GNB    ue_id=1

multiple UE do traffic
    [Tags]    c2
    SA Attach Two UEs
    iperf_dl_traffic_should_be_ok    ue_id=1
    iperf_ul_traffic_should_be_ok    ue_id=1
    iperf_dl_traffic_should_be_ok    ue_id=2
    iperf_ul_traffic_should_be_ok    ue_id=2
    SA Detach Two UEs

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

UE Register To GNB
    [Arguments]    ${ue_id}
    Perform Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered

UE Deregister From GNB
    [Arguments]    ${ue_id}
    Perform Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

Wait A While
    Sleep    10s

Modify Cfg
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

UE Setup PDU session
    [Arguments]    ${ue_id}    ${pdu}=1    ${nwslice}=1    ${gw}=1
    Perform Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=${gw}    Initial Context Setup Successful

SA Attach Two UEs
    UE Register To GNB    ue_id=1
    UE Register To GNB    ue_id=2
    Wait A While
    UE Setup PDU session    ue_id=1
    UE Setup PDU session    ue_id=2    gw=2

SA Detach Two UEs
    UE Deregister From GNB    ue_id=1
    UE Deregister From GNB    ue_id=2
