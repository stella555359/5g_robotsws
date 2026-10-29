*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO
...            owner-tingjian.mao    team-SGT&A    release-SBTS23R4
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{beamswitch}
...    @{5GC001008_flag}
...    @{32SSB}
...    @{5GC000732}
...    @{security_algo}

@{5GC000732}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecover=10000ms

@{security_algo}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9

@{32SSB}
...    NRCELL:actBeamforming=true
...    NRCELL:beamSet:basicBeamSet=beamSetAbf_32A
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=32 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1:systemInformationTargetRate=251
...    delete:NRCELL:ranAC

@{5GC001008_flag}
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
...    MRBTS-1/NRBTS-1/SNSSAI-5:sd=16222222
...    MRBTS-1/NRBTS-1/SNSSAI-5:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/SNSSAI-5:sst=1
...    MRBTS-1/NRBTS-1/SNSSAI-5:nrPlmnDNList=${NRPLMNDNLIST}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-100:fiveGsTac=100
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-100:snssaiList:snssaiDN=SNSSAI-5|snssaiDN=SNSSAI-5
...    TRACKINGAREA-300:fiveGsTac=300
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-5|snssaiDN=SNSSAI-5
...    TRACKINGAREA-400:fiveGsTac=400
...    TRACKINGAREA-400:snssaiList:snssaiDN=SNSSAI-4|snssaiDN=SNSSAI-4
...    TRACKINGAREA-400:snssaiList:snssaiDN=SNSSAI-5|snssaiDN=SNSSAI-5
...    TRACKINGAREA-500:fiveGsTac=500
...    TRACKINGAREA-500:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-500:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    TRACKINGAREA-500:snssaiList:snssaiDN=SNSSAI-5|snssaiDN=SNSSAI-5
...    NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-500
...    NRCELL-3:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-500
...    NRCELL-4:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-500
...    NRCELL-5:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    NRCELL-6:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-500
...    NRCELL-7:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-500
...    NRCELL-8:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-500

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

@{beamswitch}
...    NRCELL:actRrcReconfigAtBeamSwitch=false
...    NRCELL:prachConfigurationIndex=175

@{fault_7105}    fault_id=7105    fault_name=Cells of the TAC barred due to slicing criteria

*** Test Cases ***
CB008285-ET-B009_B010_Verify_the_last_Slice_delete_and_add_on_AMF_side_when_cell_barred_when_slice_support_by_RAN_and_alarm_7105
    [Documentation]
    ...    1. This user scenario describes This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...      1). This user scenario describes the successful AMF update procedure to add a S-NSSAI supported by the RAN. For example,
    ...          the purpose of this test case is to check following scenarios:
    ...          1)Slice modify on AMF success.
    ...          2)Slice status on Ran should be changed.
    ...      2). This user scenario describes the successful SA slice deletion/addition in an existing TAC on RAN,when
    ...         slice support or not support by AMF, combined 5GC001008_ET_EA05,5GC001008_ET_EA13 and 5GC001008_ET_EA14.
    ...         For example, the purpose of this test case is to check following scenarios:
    ...         1)Slice can be deleted/added at OAM successfully.
    ...         2)New configuration update.
    ...      3). This CASE only checks the status of CELL1(8285 scope only in PCELL)
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...       configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...       TAC-200: SLICE1
    ...       AMF-1: SLICE1/SLICE2/SLICE3/SLICE4
    ...    3. Test Case Steps:
    ...      1). Steps:
    ...       a. update AMF slice from SLICE1/SLICE2/SLICE3/SLICE4 to SLICE2(TAC not support)
    ...       b. update AMF slice from SLICE2 to SLICE1/SLICE2/SLICE5(TAC support SLICE1)
    ...       c. set TAC200 support slice1 slice4
    ...       d. set TAC200 support slice1 slice2 slice4
    ...       e. set TAC200 support slice1 slice2 slice3 slice4
    ...       f. set TAC200 support slice1 slice2 slice3
    ...       g. set TAC200 support slice2 slice3
    ...      2). Expected Results:
    ...       a. cell barred and fault 7105 raised
    ...       b. cell unbarred and fault 7105 clear
    ...       c. The configuration is modified successfully, and the cell is normal
    ...       d. The configuration is modified successfully, and the cell is normal
    ...       e. The configuration is modified successfully, and the cell is normal
    ...       f. The configuration is modified successfully, and the cell is normal
    ...       g. The configuration is modified successfully, and the cell is normal
    [Tags]    QC_302786    B009    B010
    Update slice at the AMF1 side    nwslice=2    cellbarred=barred
    fm fault should be raised    ${fault_7105}
    Update slice at the AMF1 side    nwslice=1,2,5    cellbarred=unbarred
    fm fault should be cleared    ${fault_7105}
    set TAC200 support slice1 slice4
    set TAC200 support slice1 slice2 slice4
    set TAC200 support slice1 slice2 slice3 slice4
    set TAC200 support slice1 slice2 slice3
    set TAC200 support slice2 slice3
    AMF Reset
    check wireshark log    ${CURDIR}/a2a_B009_B010/a2a.ini    wait_string=GNBCUConfigurationUpdateAcknowledge::42


CB008285-ET-B011_Verify_AMF_supported_or_not_supported_slices_addition_via_muilt_new_TAC_and_new_cell_on_RAN_side_and_alarm_7105
    [Documentation]
    ...    1. This user scenario describes This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...       This user scenario describes the successful SA slice addition via new TAC and NG update procedure,
    ...       when slice is supported or not support by the AMF.
    ...       This user scenario describes the successful slice lock/unlock in an existing TAC and NG update procedure,
    ...       when all cells of the TAC are unbarred and slice is supported by the AMF
    ...       This CASE only checks the status of CELL5(8285 scope only in PCELL)
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...       configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...       TAC-100: SLICE2,SLICE5
    ...       TAC-200: SLICE1
    ...       TAC-300: SLICE3,SLICE5
    ...       TAC-400: SLICE4,SLICE5
    ...       TAC-500: SLICE1,SLICE3,SLICE5
    ...       AMF-1: SLICE1/SLICE2/SLICE3/SLICE4
    ...    3. Test Case Steps:
    ...      1). Steps:
    ...       a. Lock CELL5 and modify TAC100 to TAC300 then Unlock CELL5
    ...       b. Online modify CELL5 from TAC300 to TAC400
    ...       c. Modify SNSSAI-2 to be not supported by AMF(snssai-2 used by tac-100)
    ...       d. Lock CELL5 and modify TAC400 to TAC100 then Unlock CELL5
    ...       e. Modify SNSSAI-2 to be supported by AMF(snssai-2 used by tac-100)
    ...       f. Lock SNSSAI-2 then fault 7105 raised and CELL5 barred
    ...       g. Unlock SNSSAI-2 then fault 7105 cleared and CELL5 unbarred
    ...       h. check wireshark
    ...      2). Expected Results:
    ...       a. Lock CELL5 success then modify the parameters are successful and the cell is normal,Normal unlock cell5
    ...       b. The parameters modify successful,After operation, the cell state meets the expectation
    ...       c. The parameters modify successful,After operation, the cell state meets the expectation(cell5 no change)
    ...       d. Lock CELL5 success then modify the parameters are successful and the cell is normal,Normal unlock cell5
    ...          fault 7105 raised and CELL5 barred
    ...       e. The parameters modify successful,After operation, the cell state meets the expectation,fault 7105 cleared
    ...          and CELL5 unbarred
    ...       f. Lock SNSSAI-2 then fault 7105 raised and CELL5 barred
    ...       g. Unlock SNSSAI-2 then fault 7105 cleared and CELL5 unbarred
    ...       h. check wireshark is normal
    [Tags]    QC_302785    B011
    Lock CELL5 and modify TAC100 to TAC300 then Unlock CELL5
    Online modify CELL5 from TAC300 to TAC400
    Modify SNSSAI-2 to be not supported by AMF
    Lock CELL5 and modify TAC400 to TAC100 then Unlock CELL5
    fault 7105 raised and CELL5 barred
    Modify SNSSAI-2 to be supported by AMF
    fault 7105 cleared and CELL5 unbarred
    Lock SNSSAI-2 then fault 7105 raised and CELL5 barred
    Unlock SNSSAI-2 then fault 7105 cleared and CELL5 unbarred
    check wireshark log    ${CURDIR}/a2a_B011/a2a.ini    wait_string=GNBDUConfigurationUpdateAcknowledge::32

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/8cells_ecpri

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_n257_FR2}
    Update Cfg    set_amf_region id=1 tac_list=0,100,200,300,400 plmn=311:489
    Update Cfg    set_amf id=1 daemon=10.0.2.1:22222 ng=10.0.1.1:38412 region=1 set_id=1 pointer=1
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all amf=1
    Update Cfg    set_nwslice id=3 snssai=0x01:0xD143A7 ue=all amf=1
    Update Cfg    set_nwslice id=4 snssai=0x01:0xD143A8 ue=all amf=1
    Update Cfg    set_nwslice id=5 snssai=0x01:0xd143a9 ue=all amf=1

Update slice at the AMF1 side
    [Arguments]    ${nwslice}=1    ${cellbarred}=unbarred    ${config_ack}=Received AMF Configuration Acknowledge from GNB-2
    Execute Egate Command    amf_config_update id=1 nwslice=${nwslice}    pass_regexp=${config_ack}
    object should exist    NRCELL-1:barringStatus=${cellbarred}
    object should exist    NRCELL-5:barringStatus=unbarred
    Cells Should Be Onair    check_sib=${False}

set TAC200 support slice1 slice4
    delta commission parameters    ${snssaiDN_1_4}

set TAC200 support slice1 slice2 slice4
    delta commission parameters    ${snssaiDN_1_2_4}
    Cells Should Be Onair    check_sib=${False}

set TAC200 support slice1 slice2 slice3 slice4
    delta commission parameters    ${snssaiDN_1_2_3_4}
    Cells Should Be Onair    check_sib=${False}

set TAC200 support slice1 slice2 slice3
    delta commission parameters    ${snssaiDN_1_2_3}
    Cells Should Be Onair    check_sib=${False}

set TAC200 support slice2 slice3
    delta commission parameters    SNSSAI-1:administrativeState=Locked
    delta commission parameters    ${snssaiDN_2_3}
    Cells Should Be Onair    check_sib=${False}

fault 7105 raised and CELL5 barred
    fm fault should be raised    ${fault_7105}
    object should exist    NRCELL-5:barringStatus=barred

fault 7105 cleared and CELL5 unbarred
    fm fault should be cleared    ${fault_7105}
    object should exist    NRCELL-5:barringStatus=unbarred

Lock CELL5 and modify TAC100 to TAC300 then Unlock CELL5
    Lock Cell5
    delta commission parameters    NRCELL-5:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
    Unlock Cell5

Online modify CELL5 from TAC300 to TAC400
    delta commission parameters    NRCELL-5:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-400

Lock SNSSAI-2 then fault 7105 raised and CELL5 barred
    delta commission parameters    SNSSAI-2:administrativeState=Locked
    fault 7105 raised and CELL5 barred

Unlock SNSSAI-2 then fault 7105 cleared and CELL5 unbarred
    delta commission parameters    SNSSAI-2:administrativeState=Unlocked
    fault 7105 cleared and CELL5 unbarred

Lock CELL5 and modify TAC400 to TAC100 then Unlock CELL5
    Lock Cell5
    delta commission parameters    NRCELL-5:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
    Unlock Cell5

Modify SNSSAI-2 to be supported by AMF
    delta commission parameters    SNSSAI-2:administrativeState=Locked
    ${params}    create list    SNSSAI-2:sd=13714342    SNSSAI-2:sst=1
    delta commission parameters    ${params}
    delta commission parameters    SNSSAI-2:administrativeState=Unlocked

Modify SNSSAI-2 to be not supported by AMF
    delta commission parameters    SNSSAI-2:administrativeState=Locked
    ${params}    create list    SNSSAI-2:sd=16777214    SNSSAI-2:sst=128
    delta commission parameters    ${params}
    delta commission parameters    SNSSAI-2:administrativeState=Unlocked

AMF Reset
    Update slice at the AMF1 side    nwslice=1,2,3,4,5    cellbarred=unbarred
    delta commission parameters    SNSSAI-1:administrativeState=Unlocked
    Cells Should Be Onair    check_sib=${False}
