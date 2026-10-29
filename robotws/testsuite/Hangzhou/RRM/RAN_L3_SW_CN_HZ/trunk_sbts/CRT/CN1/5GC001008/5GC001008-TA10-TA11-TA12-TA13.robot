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

@{PARAMS_IN_SCF}    @{SNSSAI}    @{PLMN}    @{TRACKINGAREA}    @{timer}

@{SNSSAI}
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:administrativeState=Unlocked
...    SNSSAI-1:sst=1
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:administrativeState=Unlocked
...    SNSSAI-2:sst=1
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-3:sd=13714343
...    SNSSAI-3:administrativeState=Unlocked
...    SNSSAI-3:sst=1
...    SNSSAI-3:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-4:sd=13714344
...    SNSSAI-4:administrativeState=Unlocked
...    SNSSAI-4:sst=1
...    SNSSAI-4:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-5:sd=16222222
...    SNSSAI-5:administrativeState=Unlocked
...    SNSSAI-5:sst=1
...    SNSSAI-5:nrPlmnDNList=${NRPLMNDNLIST}

@{PLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3

@{TRACKINGAREA}
...    TRACKINGAREA-100:fiveGsTac=100
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-5|snssaiDN=SNSSAI-5
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-5|snssaiDN=SNSSAI-5
...    TRACKINGAREA-300:fiveGsTac=300
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-5|snssaiDN=SNSSAI-5
...    TRACKINGAREA-400:fiveGsTac=400
...    TRACKINGAREA-400:snssaiList:snssaiDN=SNSSAI-4|snssaiDN=SNSSAI-4
...    TRACKINGAREA-400:snssaiList:snssaiDN=SNSSAI-5|snssaiDN=SNSSAI-5
...    NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

@{timer}
...    NRBTS-1:waitForRecovBeforeCellBarringTimer=60
...    NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=239
...    delete:NRBTS-1:ngInducedCellDeactDelayTimer

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1

@{fault_7105}    fault_id=7105    fault_name=Cells of the TAC barred due to slicing criteria
@{fault_7304}    fault_id=7304    fault_name=NG SCTP endpoint broken

*** Test Cases ***
5GC001008-ET-TA12-TA13_Verify_AMF_supported_or_not_supported_slices_addition_via_muilt_new_TAC_and_new_cell_on_RAN_side_and_alarm_7105
    [Documentation]
    ...    1. This user scenario describes the successful SA slice addition via new TAC and NG update procedure,
    ...       when slice is supported or not support by the AMF.
    ...    2. This user scenario describes the successful slice lock/unlock in an existing TAC and NG update procedure,
    ...       when all cells of the TAC are unbarred and slice is supported by the AMF
    [Tags]    QC_61965    ta12    ta13
    Lock CELL2 and modify TAC200 to TAC300 then Unlock CELL2
    Online modify CELL2 from TAC300 to TAC400
    Modify SNSSAI-2 to be not supported by AMF
    Lock CELL2 and modify TAC400 to TAC200 then Unlock CELL2
    fault 7105 raised and CELL2 barred
    Modify SNSSAI-2 to be supported by AMF
    fault 7105 cleared and CELL2 unbarred
    Lock SNSSAI-2 then fault 7105 raised and CELL2 barred
    Unlock SNSSAI-2 then fault 7105 cleared and CELL2 unbarred
    check wireshark log    ${CURDIR}/a2a_TA10_TA11_TA12_TA13/a2a_slice_add_lock_unlock.ini    wait_string=GNBDUConfigurationUpdateAcknowledge::28

5GC001008-ET-TA10-TA11_Verify_NG_link_with_slicing_when_abort_SCTP_and_rebuild_SCTP
    [Documentation]
    ...    1. This user scenario describes the successful SA cell setup with NG Setup procedure between the gNB and the AMF, with slicing,
    ...       when TACs are configured with different list of slices.
    ...    2. This user scenario describes the SCTP association failure with AMF with slicing.
    ...    3. This user scenario describes the successful slice SST/SD modification in an existing TAC.
    [Tags]    QC_61967    ta10    ta11
    Modify SNSSAI-2 to be not supported by AMF
    fault 7105 raised and CELL2 barred
    Trigger F1 setup and fault 7105 raised
    Trigger NG SCTP link broken
    check alarm 7304 and not alarm 7105
    NG SCTP recovery
    check alarm 7105 and not alarm 7304
    Modify SNSSAI-2 to be supported by AMF
    fault 7105 cleared and CELL2 unbarred
    check wireshark log    ${CURDIR}/a2a_TA10_TA11_TA12_TA13/a2a_f1_setup_sctp_drop.ini    wait_string=NGSetupResponse::2

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,300,400 plmn=311:489
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a6 amf=1 ue=all
    Update Cfg    set_nwslice id=3 snssai=0x01:0xd143a7 amf=1 ue=all
    Update Cfg    set_nwslice id=4 snssai=0x01:0xd143a8 amf=1 ue=all
    Update Cfg    set_nwslice id=5 snssai=0x01:0xd143a9 amf=1 ue=all

Trigger F1 setup and fault 7105 raised
    delta commission parameters    NRDU-1:gNbDuId=1
    Cells Should Be Onair    check_sib=${False}
    fault 7105 raised and CELL2 barred

Modify SNSSAI-2 to be not supported by AMF
    delta commission parameters    SNSSAI-2:administrativeState=Locked
    ${params}    create list    SNSSAI-2:sd=16777214    SNSSAI-2:sst=128
    delta commission parameters    ${params}
    delta commission parameters    SNSSAI-2:administrativeState=Unlocked

Trigger NG SCTP link broken
    execute command on enb    iptables -t filter -A OUTPUT -p sctp --dport 38412 -j DROP
    execute command on enb    ip6tables -t filter -A OUTPUT -p sctp --dport 38412 -j DROP
    object should exist    SERVEDAMF-1:ngLinkStatus=Inactive    timeout=180

check alarm 7304 and not alarm 7105
    fm fault should be raised    ${fault_7304}
    fm fault should be cleared    ${fault_7105}
    object should exist    SERVEDAMF-1:ngLinkStatus=Inactive
    object should exist    NRCELL-2:barringStatus=barred

NG SCTP recovery
    execute command on enb    iptables -t filter -F OUTPUT
    execute command on enb    ip6tables -t filter -F OUTPUT
    object should exist    SERVEDAMF-1:ngLinkStatus=Active    timeout=180

check alarm 7105 and not alarm 7304
    fm fault should be raised    ${fault_7105}
    fm fault should be cleared    ${fault_7304}
    object should exist    SERVEDAMF-1:ngLinkStatus=Active
    object should exist    NRCELL-2:barringStatus=barred

Modify SNSSAI-2 to be supported by AMF
    delta commission parameters    SNSSAI-2:administrativeState=Locked
    ${params}    create list    SNSSAI-2:sd=13714342    SNSSAI-2:sst=1
    delta commission parameters    ${params}
    delta commission parameters    SNSSAI-2:administrativeState=Unlocked

fault 7105 raised and CELL2 barred
    fm fault should be raised    ${fault_7105}
    object should exist    NRCELL-2:barringStatus=barred

fault 7105 cleared and CELL2 unbarred
    fm fault should be cleared    ${fault_7105}
    object should exist    NRCELL-2:barringStatus=unbarred

Lock CELL2 and modify TAC200 to TAC300 then Unlock CELL2
    Lock Cell2
    delta commission parameters    NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
    Unlock Cell2

Online modify CELL2 from TAC300 to TAC400
    delta commission parameters    NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-400

Lock SNSSAI-2 then fault 7105 raised and CELL2 barred
    delta commission parameters    SNSSAI-2:administrativeState=Locked
    fault 7105 raised and CELL2 barred

Unlock SNSSAI-2 then fault 7105 cleared and CELL2 unbarred
    delta commission parameters    SNSSAI-2:administrativeState=Unlocked
    fault 7105 cleared and CELL2 unbarred

Lock CELL2 and modify TAC400 to TAC200 then Unlock CELL2
    Lock Cell2
    delta commission parameters    NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
    Unlock Cell2