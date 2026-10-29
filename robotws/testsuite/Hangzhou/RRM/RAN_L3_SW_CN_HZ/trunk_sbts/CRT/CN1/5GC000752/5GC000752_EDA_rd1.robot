*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  RAN_5G_FDD  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD  team-SG2
...  owner-dan.liu  release-19A
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SWCONFIG}    ${rdForceUeCapaCsiReportWithoutPmi}=1   
${rdForceUeCapaCsiReportWithoutPmi}    0x59006a
#0x59006a--rdForceUeCapaCsiReportWithoutPmi  0 : use UE capa , 1 : force supported, 2 : force not supported [default]

*** Test Cases ***
5GC000752_EDA165_PR578834_Verify_PDSCHMIMOlayer_is_1
    [Documentation]
    ...    1. The purpose to verify 5GC000752_EDA165_PR578834 when rd be set to 1, ue call success and with correct info.
    ...    2. Test Case Step:
    ...        a, UE-1 attach success with not support PMI

    [Tags]    QC_81268 
    SA UE Attach and check   1    
    Check Wireshark Log    ${CURDIR}${/}a2a_752rd1${/}a2a_rd1.ini    wait_string=UEContextModificationResponse::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_register id=${ue_id}    is now Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${pdu_id} ue=${ue_id} nwslice=1    Initial Context Setup Successful

SA UE Attach and check
    [Arguments]    ${ue_id}=1
    SA UE attach
    traffic should be ok    ue_id=${ue_id}    type=SA
    [Teardown]    SA UE Deregister From GNB

SA UE Deregister From GNB
    [Arguments]  ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached
