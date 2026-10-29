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

@{PARAMS_IN_SCF}    @{SNSSAI}    @{PLMN}    @{TRACKINGAREA}

@{SNSSAI}
...    MRBTS-1/NRBTS-1/SNSSAI-1:sd=13714341
...    MRBTS-1/NRBTS-1/SNSSAI-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-1:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    MRBTS-1/NRBTS-1/SNSSAI-2:sd=13714342
...    MRBTS-1/NRBTS-1/SNSSAI-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-2:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}
...    MRBTS-1/NRBTS-1/SNSSAI-3:sd=13714343
...    MRBTS-1/NRBTS-1/SNSSAI-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-3:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-3:nrPlmnDNList=${NRPLMNDNLIST}
...    MRBTS-1/NRBTS-1/SNSSAI-4:sd=13714344
...    MRBTS-1/NRBTS-1/SNSSAI-4:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-4:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-4:nrPlmnDNList=${NRPLMNDNLIST}

@{PLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3

@{TRACKINGAREA}
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    NRCELL:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200

@{fault_7105}    fault_id=7105    fault_name=Cells of the TAC barred due to slicing criteria

${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1
@{snssaiDN_1_4}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-4|snssaiDN=SNSSAI-4
@{snssaiDN_1_2_4}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-4|snssaiDN=SNSSAI-4
@{snssaiDN_1_2_3_4}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-4|snssaiDN=SNSSAI-4
@{snssaiDN_1_2_3}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
@{snssaiDN_2_3}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3

*** Test Cases ***
5GC001008-ET-TA01_Verify_the_last_Slice_delete_and_add_on_AMF_side_when_cell_barred_when_slice_support_by_RAN_and_alarm_7105
    [Documentation]
    ...    1. This user scenario describes the successful AMF update procedure to add a S-NSSAI supported by the RAN. For example,
    ...       the purpose of this test case is to check following scenarios:
    ...       1)Slice modify on AMF success.
    ...       2)Slice status on Ran should be changed.
    ...    2. This user scenario describes the successful SA slice deletion/addition in an existing TAC on RAN,when
    ...       slice support or not support by AMF, combined 5GC001008_ET_EA05,5GC001008_ET_EA13 and 5GC001008_ET_EA14.
    ...       For example, the purpose of this test case is to check following scenarios:
    ...       1)Slice can be deleted/added at OAM successfully.
    ...       2)New configuration update.
    ...    2. TAC-200: SLICE1
    ...       AMF-1: SLICE1/SLICE2/SLICE3/SLICE4
    ...    3. Test Case Steps:
    ...       a. update AMF slice from SLICE1/SLICE2/SLICE3/SLICE4 to SLICE2(TAC not support)
    ...       b. update AMF slice from SLICE2 to SLICE1/SLICE2(TAC support SLICE1)
    ...    4. Expected Results:
    ...       a. cell barred and fault 7105 raised
    ...       b. cell unbarred and fault 7105 clear
    [Tags]    QC_61972    ta01    ta04
    Update slice at the AMF1 side    nwslice=2    cellbarred=barred    config_ack=cell is barred
    fm fault should be raised    ${fault_7105}
    Update slice at the AMF1 side    nwslice=1,2    cellbarred=unbarred
    fm fault should be cleared    ${fault_7105}
    set TAC support SNSSAI-1 and SNSSAI-4
    Add an AMF1 supported slice2 to the TAC
    Add an AMF1 not supported slice3 to the TAC
    delete an AMF1 not supported slice4 to the TAC
    delete an AMF1 supported slice1 to the TAC
    check wireshark log    ${CURDIR}/a2a_TA01_TA04/a2a.ini    wait_string=GNBCUConfigurationUpdateAcknowledge::18

*** Keywords ***
Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,200 plmn=311:489
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 ue=all amf=1
    Update Cfg    set_nwslice id=4 snssai=0x01:0xD143A8 ue=all amf=1

Update slice at the AMF1 side
    [Arguments]   ${nwslice}=1    ${cellbarred}=unbarred    ${config_ack}=Received AMF Configuration Acknowledge from GNB-2
    Execute Egate Command    amf_config_update id=1 nwslice=${nwslice}    ${config_ack}
    object should exist    NRCELL-1:barringStatus=${cellbarred}
    object should exist    NRCELL-2:barringStatus=${cellbarred}
    Cells Should Be Onair    check_sib=${False}

set TAC support SNSSAI-1 and SNSSAI-4
    delta commission parameters    ${snssaiDN_1_4}
    Cells Should Be Onair    check_sib=${False}

Add an AMF1 supported slice2 to the TAC
    delta commission parameters    ${snssaiDN_1_2_4}
    Cells Should Be Onair    check_sib=${False}

Add an AMF1 not supported slice3 to the TAC
    delta commission parameters    ${snssaiDN_1_2_3_4}
    Cells Should Be Onair    check_sib=${False}

delete an AMF1 not supported slice4 to the TAC
    delta commission parameters    ${snssaiDN_1_2_3}
    Cells Should Be Onair    check_sib=${False}

delete an AMF1 supported slice1 to the TAC
    delta commission parameters    SNSSAI-1:administrativeState=Locked
    delta commission parameters    ${snssaiDN_2_3}
    Cells Should Be Onair    check_sib=${False}
