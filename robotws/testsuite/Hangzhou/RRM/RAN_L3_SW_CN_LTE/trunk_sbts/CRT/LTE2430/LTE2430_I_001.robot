*** Settings ***
Documentation     | I.LTE2430.001 Ue inactivity handling wo HO |
...               |The purpose of this test case is to verify correct implementation and interworking of QCI1 protection timer (LTE2430), S1
...               |inactivity timer/C-Plance inactivity timer(LTE562-c), user data inactivity timer and S1 signalling connection inactivity timer.
...               |1. Ue has setup DRBs and SRBs -> user plane inactivity timer is directly derived from inactivity timer in SCF file, C-Plane
...               |inactivity timer is set to 10 sec (exception, in case of Initial context setup request message without CSFB IE C-Plane inactivity
...               |timer is stopped, only user plane inactivity timer active).
...               |2. Ue has no DRB setup and initial message to MME was answered already by MME -> user plane inactivity timer not applicable, C-Pl
...               |ane inactivity timer is set fixed to 60 sec.
...               |3. Ue has no DRB setup and initial message to MME was not answered by MME -> user plane inactivity timer not applicable, C-Plane
...               |inactivity timer is set fixed to 60 sec but before in any case S1 signaling connection timer with 16 sec will expire.
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    team-CN3ET    owner-xu.wang    release-L15A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS-1:actCSFBRedir=Enabled
...    LNBTS-1:actEmerCallRedir=Enabled
...    LNBTS-1:actRedirect=enabled
...    LNBTS-1:actMultGbrBearers=true
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNBTS-1:actERabModify=true
...    LNBTS-1:actRrcConnNoActivity=true
...    LNCEL:qci1ProtectionTimer=${qci1ProtectionTimer}
...    LNCEL:inactivityTimer=${inactivityTimer}
${qci1ProtectionTimer}    60
${inactivityTimer}    30
${UE_PDN1_IP}     11.1.0.1

*** Test Cases ***
2430_I_001_06_Mixed User Data Activity And QCI1 Protection Prohibit Ue Inactivity Release Until User Data Inactivity detected
    [Documentation]    | LTE2430->true |
    ...    | User Data inactivity Timer->30 |
    ...    | ulm:mixed user data activity and QCI1 protection prohibit Ue inactivity release until user data inactivity detected |
    ...    | IDENTITY REQUEST not implemented in WTS:https://jira3.int.net.nokia.com/browse/CNI-41693, once it's supported , modify the step |
    ...    | original design is MME send IDENTITY REQUEST, not implemented yet,see CNI:https://jira3.int.net.nokia.com/browse/CNI-41693 |
    ...    | use other s1 activity event-->Ue context modify instead |
    [Tags]
    CUS UE Attach To ENB
    QCI1 Setup Instantly
    UE Release Prohibited
    UE Release After User Data Inactivity Timer Expired

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Execute Egate Command    trace_sim on mme=1 enb=1 uec=1 protocol=x2,s1,rrc on
    Create UE Alias    alias=UE_1    ue_id=1    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...      - {qci: 5, default: on, pdn: 2}
    ...      - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 2}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2

CUS UE Attach To ENB
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains ( qCI eq 8 ) and length(E-RABToBeSetupListCtxtSUReq) eq 1)
    ...    alias=attach    overall_timeout=20
    Execute Uex Command    ue_attach id=1 cell=1
    Flow Occurred As Expected    alias=attach

QCI1 Setup Instantly
    expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (qCI eq 5))
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (qCI eq 1))
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=pdn2_qci5_qci1     overall_timeout=10
    execute uex command    ue_pdn_connect id=1 apn=nokia_2.net
    execute uex command    bearer_add ue=1 qci=1 apn=nokia_2.net mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    flow occurred as expected    alias=pdn2_qci5_qci1

UE Release Prohibited
    expect message will not occur
    ...    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq 'user-inactivity')
    ...    alias=not_release    overall_timeout=${${qci1ProtectionTimer}+${inactivityTimer}*3-4}
    Single Ping Before QCI1 Protection Timer Expired
    Single Ping Before User Data Inactivity Timer Expired
    Single Ping Before User Data Inactivity Timer Expired
    Single Ping Before User Data Inactivity Timer Expired
    Ue Ctx Modify Instantly
    flow not occurred for message    alias=not_release

Single Ping Before QCI1 Protection Timer Expired
    sleep    ${${qci1ProtectionTimer}-3}
    Run Keyword And Ignore Error    Execute Cmd On Pc    ping -c 1 -W 1 ${UE_PDN1_IP}
    ${ue_info}    execute uex command    get_ue_info id=1
    should be equal    ${ue_info["state"]}    ACTIVE

Single Ping Before User Data Inactivity Timer Expired
    sleep    ${${inactivityTimer}-3}
    Run Keyword And Ignore Error    Execute Cmd On Pc    ping -c 1 -W 1 ${UE_PDN1_IP}
    ${ue_info}    execute uex command    get_ue_info id=1
    should be equal    ${ue_info["state"]}    ACTIVE

Ue Ctx Modify Instantly
    expect message flow
    ...    MME_1:S1AP_UEContextModificationRequest
    ...    MME_1:S1AP_UEContextModificationResponse
    ...    alias=uectxmod     overall_timeout=10
    Execute Egate Command    ue_mod_ctx id=1 ambr_ul=2000
    flow occurred as expected    alias=uectxmod

UE Release After User Data Inactivity Timer Expired
    expect message will not occur
    ...    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq 'user-inactivity')
    ...    alias=not_release    overall_timeout=${${inactivityTimer}-5}
    expect message flow
    ...    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq 'user-inactivity')
    ...    alias=release    overall_timeout=${inactivityTimer}
    flow not occurred for message    alias=not_release
    flow occurred as expected    alias=release