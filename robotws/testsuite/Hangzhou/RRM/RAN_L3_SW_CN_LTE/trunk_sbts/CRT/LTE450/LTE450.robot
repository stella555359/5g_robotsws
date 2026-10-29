*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO    team-DevHZ5_SG8
...               owner-chao.3.zhang,ying.shang    release-SBTS17A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNCEL-1/LNREL-1:cellIndOffNeigh=0dB
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1450
...    @{PARAMS_FOR_MME2}
@{PARAMS_FOR_MME2}
...    LNBTS-1/LNMME-1:ipAddrPrim=10.0.1.5
...    LNBTS-1/LNMME-1:transportNwId=0
...    LNBTS-1/LNMME-1:mmeRatSupport=Wideband-LTE
@{PARAMS_FOR_X2HO}
...    LNBTS-1:actLTES1Ho=false
...    LNBTS-1/LNADJ-0:adjEnbId=2
...    LNBTS-1/LNADJ-0:cPlaneIpAddr=10.0.1.31
...    LNCEL-1/LNREL-1:handoverAllowed=allowed

*** Test Cases ***
LTE450-MME-Capacity-Value-Change
    [Documentation]    Parmeter relMmeCap indicates the relative MME capacity assigned to the MME.
    ...    When two MMEs relative capacity are same, two MMEs will be load balanced. When one MME's relative capacity change to 0,
    ...    new UEs will not choose this MME. This parameter will not effect X2 handover, so When one MME's relative capacity change to 0,
    ...    X2 Handover between two MMEs should be successful.
    [Tags]
    Verify Two MMEs Load Balanced When The Two MMEs Relative MME Capacity Are Same
    Verify The Enb Do Not Choose The Second MME For New Accessed UEs When The MME Relative MME Capacity Is Zero
    Verify X2 Handover Is Successful Between Two Enbs After Relative MME Capacity Is Changed

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=30    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts

Modify Yaml
    Update Yaml    EPC/MME/1    id: '1'    type: 'simulated'    pool: ['1:1']    s1: '10.0.1.1'
    Add Yaml    EPC/MME
    ...    - id: 2
    ...      type: simulated
    ...      pool: ['2:2']
    ...      s1: 10.0.1.5
    Add Yaml    EPC/MME_POOL_AREA
    ...    - id: 2
    ...      plmn: '262:03'
    ...      mmegi: 2
    ...      tac_list: 33
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.31
    ...      x2: 10.0.1.31
    ...      x2_peers: none
    ...      cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '10:1', earfcn: '1450:19450', bw: 20, eci: '0x0000201', status: enabled}

Verify Two MMEs Load Balanced When The Two MMEs Relative MME Capacity Are Same
    Change MME Capacity    id=1    poolid=1:1    capacity=25    enb_id=1
    Change MME Capacity    id=2    poolid=1:1    capacity=25    enb_id=2
    Number Of Active UEs On MME-2 Should Not Less Than 1 When Attach Multi UEs

Verify The Enb Do Not Choose The Second MME For New Accessed UEs When The MME Relative MME Capacity Is Zero
    Change MME Capacity    id=2    poolid=1:1    capacity=0    enb_id=2
    Number Of Active UEs On MME-2 Should Be 0 When Attach Multi UEs

Verify X2 Handover Is Successful Between Two Enbs After Relative MME Capacity Is Changed
    Delta Commission Parameters And Wait Cells Onair    ${PARAMS_FOR_X2HO}
    UE handover    ue_id=16    enb_id=2    cell_id=1
    Execute Egate Command    enb_param id=2 ho_source=x2
    Wait for Handover complete
    UE handover    ue_id=16    enb_id=1    cell_id=1

Change MME Capacity
    [Arguments]    ${id}    ${poolid}    ${capacity}    ${enb_id}
    Execute Egate Command    mme_config_update id=${id} pool=${poolid} relative_cap=${capacity}
    ...    MME Configuration Update Acknowledged for eNb ${enb_id}

Number of Active UEs On The Second MME
    ${out}=    Execute Egate Command    mme_disp    Configured MMEs
    ${lines}=    Get Lines Matching Pattern    string=${out}    pattern=2*ACTIVE*
    ${n}=    Fetch From Right    ${lines}    -
    ${mme2ues}=    Convert to Integer    ${n}
    [Return]    ${mme2ues}

Number Of Active UEs On MME-2 Should Not Less Than 1 When Attach Multi UEs
    Execute Uex Command    ue_attach id=1-14 cell=1
    ${mme2ues}=    Number of Active UEs On The Second MME
    Should Be True    ${mme2ues}>${0}
    Execute Uex Command    ue_detach id=1-14

Number Of Active UEs On MME-2 Should Be 0 When Attach Multi UEs
    Execute Uex Command    ue_attach id=16-30 cell=1
    ${mme2ues}=    Number of Active UEs On The Second MME
    Should Be True    ${mme2ues}==${0}

UE handover
    [Arguments]    ${ue_id}    ${enb_id}    ${cell_id}
    Expect message flow
    ...    ENB_${enb_id}:X2AP_HandoverRequestAcknowledge
    ...    alias=UE_Handover    overall_timeout=20
    Execute Uex Command    ue_ho id=${ue_id} enb=${enb_id} cell=${cell_id}
    Flow Occurred As Expected    alias=UE_Handover

Wait for Handover complete
    sleep    3s
