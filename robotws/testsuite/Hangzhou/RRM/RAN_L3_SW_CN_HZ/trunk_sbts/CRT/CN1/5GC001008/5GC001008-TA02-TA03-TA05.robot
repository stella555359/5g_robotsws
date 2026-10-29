*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-wen.y.xu    release-5G20A    5GC001008
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2cells_ecpri

@{PARAMS_IN_SCF}    @{SNSSAI}    @{PLMN}    @{TRACKINGAREA}    @{barred_timer}

@{SNSSAI}
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:sst=1
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:administrativeState=Unlocked
...    SNSSAI-2:sst=1
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-3:administrativeState=Unlocked
...    SNSSAI-3:sst=1
...    SNSSAI-3:sd=13714343
...    SNSSAI-3:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-4:administrativeState=Unlocked
...    SNSSAI-4:sst=1
...    SNSSAI-4:sd=13714344
...    SNSSAI-4:nrPlmnDNList=${NRPLMNDNLIST}

@{PLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3

@{TRACKINGAREA}
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

@{barred_timer}
...    NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=30
...    NRBTS-1:waitForRecovBeforeCellBarringTimer=45
...    NRBTS-1:x2LinkSupervisionTmr=0

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1
@{snssaiDN_1_2}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
@{snssaiDN_1_2_3}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
@{snssaiDN_1_2_3_4}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-4|snssaiDN=SNSSAI-4
@{snssaiDN_1_3_4}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-4|snssaiDN=SNSSAI-4
@{snssaiDN_2}    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2

@{fault_7105}    fault_id=7105    fault_name=Cells of the TAC barred due to slicing criteria

${sctpWaitTimeInitSeqRetry}    30
${waitForRecovBeforeCellBarringTimer}    45
${waitForRecovBeforeCellBarringTimer_timeout}    25    #${waitForRecovBeforeCellBarringTimer}-${sctpWaitTimeInitSeqRetry}+10

*** Test Cases ***
5GC001008-ET-TA02_Verify_AMF_supported_Slice_addition_into_TAC_on_RAN_side_when_cell_barred_and_alarm_7105
    [Documentation]
    ...    1. This user scenario describes the successful SA slice addition in existing TAC and NG update procedure,
    ...       when all cells of the TAC are barred and slice is supported by the AMF.
    ...       For example, the purpose of this test case is to check following scenarios:
    ...         1) Slice add successfully.
    ...         2) The barred cell added one slice supported by AMF could change to unbarred.
    ...       will cover 5GC001008-ET-EA008 and 5GC001008-ET-PC005
    ...    2. TAC-200: SLICE1/SLICE2
    ...       AMF-1: SLICE1/SLICE2/SLICE3/SLICE4
    [Tags]    QC_61976    ta02
    Update AMF to SNSSAI-3 which is not supported by TAC
    fm fault should be raised    ${fault_7105}
    Add SNSSAI-3 to the TAC
    fm fault should be cleared    ${fault_7105}
    check wireshark log    ${CURDIR}/a2a_TA02_TA03_TA05/a2a_RAN_add_slice.ini    wait_string=GNBDUConfigurationUpdateAcknowledge::2
    [Teardown]    Recover slice setting on AMF and TAC

5GC001008-ET-TA03_Slice_deletion_on_AMF_side_when_slice_supported_by_RAN_and_it_is_not_the_last_slice_of_a_TAC
    [Documentation]
    ...    1. This user scenario describes the successful AMF update procedure to delete a S-NSSAI supported by the
    ...       RAN. The slice deleted is not the last of a TAC. when deleted is last slice, cell will is barred.
    ...       will cover 5GC001008-ET-EA022
    ...    2. TAC-200: SLICE1/SLICE2
    ...       AMF-1: SLICE1/SLICE2/SLICE3/SLICE4
    [Tags]    QC_61975    ta03    EDA-01834761
    sa ue register and pdu setup    ue_id=1    nwslice=1
    Trigger slice delete on AMF
    fm fault should be raised    ${fault_7105}
    recover slice setting on AMF
    fm fault should be cleared    ${fault_7105}
    check wireshark log    ${CURDIR}/a2a_TA02_TA03_TA05/a2a_AMF_dele_add_slice.ini    wait_string=GNBDUConfigurationUpdateAcknowledge::2
    drop and setup NGlink
    fault 7105 not exist before cellBarringRecoveryTimer timeout
    [Teardown]    Recover slice setting on AMF and TAC

5GC001008-ET-TA05_Verify_lock_and_unlocked_slice_and_slice_deletion_from_TAC_when_cell_unbarred
    [Documentation]
    ...    1. This user scenario describes the successful slice lock in an existing TAC and NG update procedure, when all
    ...       cells of the TAC are unbarred and slice is supported by the AMF.
    ...       will cover 5GC001008-ET-O005/006/012
    ...    2. TAC-200: SLICE1/SLICE2/SLICE3/SLICE4
    ...       AMF-1: SLICE1/SLICE2/SLICE3/SLICE4
    [Tags]    QC_61974    ta05
    TAC support all SNSSAI
    Modify SNSSAI-1 Status    Locked
    sa ue register and pdu setup    ue_id=1    nwslice=1    cmd_pdu_regexp=RAN slice not supported
    release ues    ue_type=all
    Modify SNSSAI-1 Status    Unlocked
    sa ue register and pdu setup    ue_id=1    nwslice=1
    Trigger SNSSAI-2 Locked and delete in TAC
    check wireshark log    ${CURDIR}/a2a_TA02_TA03_TA05/a2a_slice_lock_unlock_del.ini    wait_string=GNBCUConfigurationUpdate::3

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 ue=all amf=1
    Update Cfg    set_nwslice id=4 snssai=0x01:0xD143A8 ue=all amf=1

Recover slice setting on AMF and TAC
    recover slice setting on AMF
    ${SNSSAI_Locked}    create list    SNSSAI-2:administrativeState=Locked
    ...    SNSSAI-3:administrativeState=Locked    SNSSAI-4:administrativeState=Locked
    ${SNSSAI_Unlocked}    create list    SNSSAI-2:administrativeState=Unlocked
    ...    SNSSAI-3:administrativeState=Unlocked    SNSSAI-4:administrativeState=Unlocked
    delta commission parameters    ${SNSSAI_Locked}
    delta commission parameters    ${snssaiDN_1_2}
    delta commission parameters    ${SNSSAI_Unlocked}
    Common Test Teardown And Stop Capture Logs

Update AMF to SNSSAI-3 which is not supported by TAC
    Execute Egate Command    amf_config_update id=1 nwslice=3    gNB=2: Cell 1 is barred
    object should exist    NRCELL-1:barringStatus=barred
    object should exist    NRCELL-2:barringStatus=barred
    Cells Should Be Onair    check_sib=${False}

Add SNSSAI-3 to the TAC
    delta commission parameters    ${snssaiDN_1_2_3}    #add slice3
    object should exist    NRCELL-1:barringStatus=unbarred
    object should exist    NRCELL-2:barringStatus=unbarred
    Cells Should Be Onair    check_sib=${False}

recover slice setting on AMF
    Execute Egate Command    amf_config_update id=1 nwslice=1,2,3,4    Received AMF Configuration Acknowledge from GNB-2

Trigger slice delete on AMF
    Execute Egate Command    amf_config_update id=1 nwslice=2    Received AMF Configuration Acknowledge from GNB-2    sleep_time=5
    Execute Egate Command    amf_config_update id=1 nwslice=3    gNB=2: Cell 1 is barred
    object should exist    NRCELL-1:barringStatus=barred
    object should exist    NRCELL-2:barringStatus=barred
    Cells Should Be Onair    check_sib=${False}

drop and setup NGlink
    Execute Egate Command    link_drop link=ng by=amf:1 to=gnb:2    All NG links are down
    object should exist    SERVEDAMF-1:ngLinkStatus=Inactive
    object should exist    NRCELL-1:barringStatus=unbarred
    object should exist    NRCELL-2:barringStatus=unbarred
    wait until keyword succeeds    ${sctpWaitTimeInitSeqRetry}    5s    object should exist    SERVEDAMF-1:ngLinkStatus=Active

fault 7105 not exist before cellBarringRecoveryTimer timeout
    fm fault should be cleared    ${fault_7105}
    sleep    ${waitForRecovBeforeCellBarringTimer_timeout}
    fm fault should be cleared    ${fault_7105}

TAC support all SNSSAI
    delta commission parameters    ${snssaiDN_1_2_3_4}
    Cells Should Be Onair    check_sib=${False}

Modify SNSSAI-1 Status
    [Arguments]    ${status}=Unlocked
    delta commission parameters    SNSSAI-1:administrativeState=${status}
    Cells Should Be Onair    check_sib=${False}

sa ue register and pdu setup
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${cmd_pdu_regexp}=QoS Routing Table
    Execute Egate Command    ue_register id=${ue_id} nwslice=${nwslice}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice} gw=${ue_id}    ${cmd_pdu_regexp}

Trigger SNSSAI-2 Locked and delete in TAC
    delta commission parameters    SNSSAI-2:administrativeState=Locked
    delta commission parameters    ${snssaiDN_1_3_4}
    object should not exist    ${snssaiDN_2}
    Cells Should Be Onair    check_sib=${False}
