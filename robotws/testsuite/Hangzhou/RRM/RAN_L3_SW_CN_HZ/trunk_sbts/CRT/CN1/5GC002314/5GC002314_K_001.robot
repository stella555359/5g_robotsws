*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
...    owner-baijie.zhu    release-5G20A
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:actPaging=true
...    MRBTS-1/NRBTS-1:drxDefaultPaging=v128
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=60
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=60
...    MRBTS-1/NRBTS-1/NRCELL-1:numOfPagingFrames=quaterT
...    MRBTS-1/NRBTS-1/NRCELL-1:pagingOffset=1
...    MRBTS-1/NRBTS-1/NRCELL-1:numPagingOccsnPagingFrame=two
...    MRBTS-1/NRBTS-1/NRCELL-1:pagingTargetRate=MCS0_SF2
...    MRBTS-1/NRBTS-1/NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    MRBTS-1/NRBTS-1/NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    MRBTS-1/NRBTS-1/NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    MRBTS-1/NRBTS-1/NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciPagingAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1:dciPagingAggregationLevel=AL4
...    MRBTS-1/NRBTS-1/NRCELLGRP-0:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1:systemInformationTargetRate=157
...    MRBTS-1/NRBTS-1/NRCELL-1:fPdcchMonOccsnPo=0,1
...    @{ADD_PARAMS}
@{ADD_PARAMS}
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=SA+NSA
@{Delta_Params_01}
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=1|searchSpaceId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=1
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=2|searchSpaceId=2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=2
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=3|searchSpaceId=3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=3
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=2|searchSpaceId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=4|searchSpaceId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type0A|searchSpaceId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=1|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0_1|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n0|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n2|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n0|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl1|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=5|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type1|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:coresetId=0|searchSpaceId=6
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:dciFormat=formats0-0-And-1-0|searchSpaceId=6
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:duration=3|searchSpaceId=6
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:monitoringSymbolWithinSlot=symbol_0|searchSpaceId=6
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL16=n1|searchSpaceId=6
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL2=n0|searchSpaceId=6
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL4=n4|searchSpaceId=6
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:numOfPdcchCandidatesInAL8=n2|searchSpaceId=6
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:periodicity=sl5|searchSpaceId=6
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceId=6|searchSpaceId=6
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:searchSpaceType=Type2|searchSpaceId=6
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_COMMON-1:searchSpaceCommon:slotOffset=0|searchSpaceId=6

*** Test Cases ***
5GC002314-ET-K001 Verify Paging for different pagingTargetRateIndex with feature flag enable disable_TDD
    [Documentation]     K001:To verify the Paging for different pagingTargetRateIndex with feature flag enable disable TDD
    ...    Also covers the case K002:To verify Paging for Ns greater than 1 when firstPdcchMonitoringOccasionOfPo is present_TDD
    [Tags]    QC_62348
    Update The CoresetCommon
    L3 call is successful    ue_id=1
    Paging from AMF
    UE Deregister From GNB
    Check endmarker counter shall be correct
    Check BIP log for case K001

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=10
    Comment    Debug Enter Into Egate

Update The CoresetCommon
    Delta commission parameters    ${Delta_Params_01}
    cells should be onair

L3 call is successful
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    Initial Context Setup Successful


Paging from AMF
    Wait UE idle
    Start to Capture GNB and AP Bip Log    tag=pagingUE1
    execute egate command    amf_paging_param id=1 default_drx=128 max_paging_retries=10
    execute egate command    amf_paging_start id=1 ue=1    Paging stop in UE with RAN UE NGAP ID
    Stop to Capture GNB and AP Bip Log    tag=pagingUE1     sleep_timer=2s

Wait UE idle
    sleep    50

UE Deregister From GNB
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    detached

Check endmarker counter shall be correct
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}gnb_bip_logs_pagingUE1/mirroring_L2L1.pcap
    ...    3gpp.rnti == 65534 && DlData_PdschGrant.mcs == 0
    should be equal As Numbers    ${number}    1

Check BIP log for case K001
    ${slot}=    Get Wireshark Field Value old    cap_file=${SAVE LOG DIRECTORY}${/}gnb_bip_logs_pagingUE1/mirroring_L2L1.pcap
    ...    element_expression=_3gpp.slot
    ...    display_filter=DlData_PdschGrant.mcs == 0 && 3gpp.rnti == 65534
    ${slotn}=    Convert To Integer    0x@{slot}[0]
    Should be equal As Numbers    ${slotn}    0
    ${sfn}=    Get Wireshark Field Value old    cap_file=${SAVE LOG DIRECTORY}${/}gnb_bip_logs_pagingUE1/mirroring_L2L1.pcap
    ...    element_expression=_3gpp.sfn
    ...    display_filter=DlData_PdschGrant.mcs == 0 && 3gpp.rnti == 65534
    ${sfn1}=    set variable    ${sfn}[0]
    ${sfn_10}    convert to integer    0x${sfn1[2:4]}${sfn1[0:2]}
    ${PF_offset}=    set variable    1
    ${sum}=    Evaluate    ${sfn_10}+${PF_offset}
    ${mod}=    Evaluate    ${sum}%128
    Should be equal As Numbers    ${mod}    4

