*** Settings ***
Suite Setup       Common Suite Setup and Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CIT
...               CLOUD_R4LAPO_CUS    OAM2    release-TL15A    owner-kang.xiang    old-zhuo.zhang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  LNCEL-1:phyCellId=1
...  LNBTS-1:anrOmExtEnable=true
...  ANRPRL-0:nrLimitIntraFreq=0
...  LNBTS-1/ANR-0:pciIpAdrMap:dlEarfcn=38000
...  LNBTS-1/ANR-0:pciIpAdrMap:ipAdr=10.0.1.32
...  LNBTS-1/ANR-0:pciIpAdrMap:pci=101
...  LNBTS-1:actUeBasedAnrIntraFreqLte=false
...  LNBTS-1:actUeBasedAnrInterFreqLte=false
...  LNBTS-1:actUeBasedAnrUtran=false
...  LNBTS-1:actAnrRtt=false
...  LNBTS-1:actIfHo=enabled
...  LNBTS-1:actSelMobPrf=false
...  LNBTS-1/MODPR-0:autoAdapt=true
...  LNCEL-1/LNHOIF-1:eutraCarrierInfo=38000
...  LNCEL-1/LNCEL_TDD-0:earfcn=38100
...  LNCEL-2/LNCEL_TDD-0:earfcn=38100
...  LNCEL-3/LNCEL_TDD-0:earfcn=38100
...  LNBTS-1:tX2RelocPrep=10000
...  @{delete_paralist}
@{delete_paralist}
...  delete:LNADJ.*
...  delete:LNADJL.*

${ue_eutra_capabilities}    SEPARATOR=
...    CD9FF4F9B2E7500010610102912464D0312040E07FFFFFFFFCA18800182008295020022A0060B3FFFFFFFE014FFFFFFFFC

*** Test Cases ***
LTE492+ New cell discovered by UE Interfrequency
    [Tags]
    Cus UE attach to eNB1
    Cus Report Inter-freq A2
    Cus Report Inter-freq A3 And Expect X2AP Establishment
    sleep    5s
    Cus Report Inter-freq A3 And Expect Inter-eNB handover
    Check LNADJ And LNREL

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup Cus Env    tl_type=3CELLs    ue_count=10
    #Debug Enter Into Egate
    Create Alias
    Execute Egate Command    mme_timer T_S1APInitialContextSetup=5000ms    #avoid T_S1APInitialContextSetup fail
    Execute Egate Command    trace_sim on mme=1 protocol=s1
    Execute Egate Command    trace uec=1 protocol=rrc on

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus

Cus UE attach to eNB1
    [Arguments]    ${ueid}=1    ${cellid}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}    ${sleeptime}=0
    Execute Uex Command    ue_param id=${ueid} csfb_rat=utran_geran voice_domain_preference=lte_preferred
    Execute Uex Command    ue_param id=${ueid} ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ue_attach id=${ueid} cell=${cellid} selected_plmn=262:03
    sleep    ${sleeptime}

Modify Yaml
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.32
    ...      x2_peers: none
    ...      cells:
    ...        - {id: 1, technology: lte, tac: 33, pci: '33:2', earfcn: '38000:38000', duplex_mode: 'TDD'}

Cus Report Inter-freq A2
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration ( measIdToAddModList contains (measId eq 14) )
    ...    alias=LTE492_flow1    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=1 event=A2 srsrp=30 srsrq=15
    Flow Occurred As Expected    alias=LTE492_flow1

Cus Report Inter-freq A3 And Expect X2AP Establishment
    Execute Uex Command    ue_measurement_send id=1 srsrp=30 srsrq=15 phycell_id=101 nrsrp=80 nrsrq=34 event=A3

Cus Report Inter-freq A3 And Expect Inter-eNB handover
    Execute Uex Command    ue_measurement_send id=1 srsrp=30 srsrq=15 phycell_id=101 nrsrp=80 nrsrq=34 event=A3
    Wait Until Keyword Succeeds    20s    5s    Check Ue Enb Location    ueid=1    wait_string=3

Wait iFLBRetryTimer
    sleep    ${${iFLBRetryTimer}+2}    #sleep a litter longer than retryTimer

Check LNADJ And LNREL
    @{pids_sys}    Get Linux Process Id    wts_state_stats
    FOR    ${pid}    IN    @{pids_sys}
        Run Keyword And Ignore Error    Kill Linux Process    ${pid}
    END
    Object Should Exist    LNADJ:adjEnbId=3
    Object Should Exist    LNCEL-1\/LNREL-388:ecgiAdjEnbId=3

Check Ue Enb Location
    [Arguments]    ${ueid}    ${wait_string}
    ${ue_info}    Execute UEx Command    get_enb_id ue=${ueid}
    ${enb_id}=      Convert To String     ${ue_info}
    should be equal    ${enb_id}    ${wait_string}