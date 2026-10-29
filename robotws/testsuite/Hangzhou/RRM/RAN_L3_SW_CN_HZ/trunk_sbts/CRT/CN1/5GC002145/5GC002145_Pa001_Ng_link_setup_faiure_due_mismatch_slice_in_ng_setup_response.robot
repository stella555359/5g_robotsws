*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    CRT    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-DevHZ5_SG2    owner-yuhua.zhu    release-5G19B
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri
@{FAULTS_EXCLUDED_CHECKING}    7304

@{PARAMS_IN_SCF}
...    NRBTS-1:actNgcFlexSaMode=true
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-2:amfIPAddress=10.0.1.102
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:sst=1
...    SNSSAI-1:sd=13714341

@{SNSSAIDNLIST}
...  TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...  TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2

*** Test Cases ***
5GC002145-ET-Pa001 Ng link setup faiure due mismatch slice in ng setup response
    [Documentation]
    ...    1. gNB-CU-CP triggers the NGAP NG Setup procedure towards the AMF. The list of supported S-NSSAI(s) per TAC per PLMN
    ...       is provided in the NGAP NG Setup Request message.AMF responds with the NGAP NG Setup Response message but none of the S-NSSAIs
    ...       provided in the message for the PLMN are supported by the gNB.gNB-CU-CP rejects the message with a NGAP
    ...       Error Indication message with cause set to "Slice(s) not supported"
    ...    2. This user scenario describes the case where the gNB attempts to setup the NG-C connection with an AMF and the AMF sends a failure
    ...       response due to mismatch of configured S-NSSAI(s) (none in common)
    [Tags]    QC_87026    EDA-02523987
    Trigger NG Link Setup But Ignore
    Check Error Indication And Ng Link Status
    add standard slice2
    Check AMF2 should be Active
    Lock AMF2 and NGlink is Inactive
    modify slice2 to non-standard
    Unlock AMF2 and NGlink is Active

*** Keywords ***
Modify Cfg
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xFFFFFF amf=2 ue=all
    Update Cfg    set_nwslice id=3 snssai=0x01:0xd143a6 amf=2 ue=all

Perform Steps After Onair
    check wireshark log    ${CURDIR}/a2a_P001/a2a_AMF2.ini    wait_string=NGSetupFailure::2
    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-2:ngLinkStatus=Inactive

Trigger NG Link Setup But Ignore
    Execute Egate Command    amf_ng_setup_param id=1 action=logical_error nwslice=2 nth=1 ntimes=5    # set precondition for drop NG_Setup_Req
    Delta Commission Parameters    SERVEDAMF-1:administrativeState=Locked
    Delta Commission Parameters    SERVEDAMF-1:administrativeState=Unlocked

Check Error Indication And Ng Link Status
    ${egate_console}=    Set Variable    NgAP:ERROR_INDICATION\(RAN_UE_NGAP_ID=NONE, AMF_UE_NGAP_ID=NONE, Cause=RAN slice not supported\) received
    Wait Until Keyword Succeeds    120s    10s    RRC Should Contain    ${egate_console}
    Check WireShark Log    ${CURDIR}${/}a2a_P001${/}a2a.ini    wait_string=ErrorIndication
    Object Should Exist    MRBTS-1/NRBTS-1/SERVEDAMF-1:ngLinkStatus=Inactive

add standard slice2
    ${params}    create list    SNSSAI-2:administrativeState=Unlocked    SNSSAI-2:sst=1    ${SNSSAIDNLIST}
    delta commission parameters    ${params}

Check AMF2 should be Active
    delta commission parameters    SERVEDAMF-2:administrativeState=Locked
    delta commission parameters    SERVEDAMF-2:administrativeState=Unlocked
    object should exist    SERVEDAMF-2:ngLinkStatus=Active

Lock AMF2 and NGlink is inactive
    delta commission parameters    SERVEDAMF-2:administrativeState=Locked
    object should exist    SERVEDAMF-2:ngLinkStatus=Inactive

modify slice2 to non-standard
    delta commission parameters    SNSSAI-2:administrativeState=Locked
    delta commission parameters    SNSSAI-2:sd=13714342
    delta commission parameters    SNSSAI-2:administrativeState=Unlocked

Unlock AMF2 and NGlink is active
    delta commission parameters    SERVEDAMF-2:administrativeState=Unlocked
    object should exist    SERVEDAMF-2:ngLinkStatus=Active