*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO
...            owner-zhang.yige    team-SGT&A    release-SBTS23R4
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{32SSB}
...    @{beamswitch}
...    @{OSI}
...    @{Paging}

${SYSCOM_FLAG}    ${True}

@{Paging}
...    MRBTS-1/NRBTS-1:actPaging=true
...    MRBTS-1/NRBTS-1:drxDefaultPaging=v256
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=10
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=60
...    MRBTS-1/NRBTS-1/NRCELL-1:numOfPagingFrames=quaterT
...    MRBTS-1/NRBTS-1/NRCELL-1:pagingOffset=1
...    MRBTS-1/NRBTS-1/NRCELL-1:numPagingOccsnPagingFrame=two
...    MRBTS-1/NRBTS-1/NRCELL-1:fPdcchMonOccsnPo=0,92
...    MRBTS-1/NRBTS-1/NRCELL-1:pagingTargetRate=pagingDciAggregation
...    MRBTS-1/NRBTS-1/NRCELL-5:pagingTargetRate=pagingDciAggregation

@{Delta_Params_Paging_MCS}
...    MRBTS-1/NRBTS-1/NRCELL-1:pagingTargetRate=MCS9_SF0
...    MRBTS-1/NRBTS-1/NRCELL-5:pagingTargetRate=MCS4_SF2

@{Recover_Params_Paging_MCS}
...    MRBTS-1/NRBTS-1/NRCELL-1:pagingTargetRate=pagingDciAggregation
...    MRBTS-1/NRBTS-1/NRCELL-5:pagingTargetRate=pagingDciAggregation

@{OSI}
...    NRCELL-1:actOsiMismatchCheck=true
...    NRCELL-5:actOsiMismatchCheck=true
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1:multiFreqBandIndicatorNR=257
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1:intraFreqNCellList:physCellId=54
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIAFIM-1:intraFreqNCellList:qOffsetCell=-22dB

@{32SSB}
...    NRCELL:actBeamforming=true
...    NRCELL:beamSet:basicBeamSet=beamSetAbf_32A
...    NRCELL-5:beamSet:basicBeamSet=beamSetAbf_32B
...    NRCELL-6:beamSet:basicBeamSet=beamSetAbf_32B
...    NRCELL-7:beamSet:basicBeamSet=beamSetAbf_32B
...    NRCELL-8:beamSet:basicBeamSet=beamSetAbf_32B
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=32 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1:systemInformationTargetRate=251

@{beamswitch}
...    NRCELL:actRrcReconfigAtBeamSwitch=false

${SA_Capa_Support_n257_FR2_16CSIRS_TRS}    SEPARATOR=
...    E1A25000574F7603560003C42800580F40000980219008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F23CFB1E7D812647
...    BF41DFB06FD8246C69F640FB049D834EC1AF62CF920020301262C011306E412006341A0140601CCE00540B40378E3087000A8F3F1436011FB
...    660AA40078F0021C40021150283DFC8106400000C00600385C2168800300080400006806A0740050C000401503A0060C008200A83D00000C8
...    000004200801820100105C800740700D8E3C5806C71E2C20D8E3C50A40340002000C00620001000600310000800300187A0B100F801C01000
...    40500603009401800180F80524A00C00000000003925000000724A01C000000000000000000003001BA400810040000000004100000000010
...    4030000000000000010015DA816809C0110080400090840014401010000000000008000000000004000000000000800200400840401002010
...    0400000200C01814294404008D00

${filter1}    SEPARATOR=
    ...    3gpp.rnti == 65534 && DlData_PdschGrant.mcs == 9 && 3gpp.subcellid == 0 && DlData_PdschGrant.patternId_item == 8 && 3gpp.slot == 0
    ...    && DlData_PdschGrant.numOfPrb == 1
${filter2}    SEPARATOR=
    ...    3gpp.rnti == 65534 && DlData_PdschGrant.mcs == 9 && 3gpp.subcellid == 0 && DlData_PdschGrant.patternId_item == 39 && 3gpp.slot == 51
    ...    && DlData_PdschGrant.numOfPrb == 1
${filter3}    SEPARATOR=
    ...    3gpp.rnti == 65534 && DlData_PdschGrant.mcs == 4 && 3gpp.subcellid == 4 && DlData_PdschGrant.patternId_item == 40 && 3gpp.slot == 0
    ...    && DlData_PdschGrant.numOfPrb == 4
${filter4}    SEPARATOR=
    ...    3gpp.rnti == 65534 && DlData_PdschGrant.mcs == 4 && 3gpp.subcellid == 4 && DlData_PdschGrant.patternId_item == 36 && 3gpp.slot == 51
    ...    && DlData_PdschGrant.numOfPrb == 4
${ue_num_All}    20
@{pm_couter_B012}
...    NRCELL-1:${NRPAG_PAGING_SUCC_SENT}==4
...    NRCELL-1:${NRPAG_PAG_DROP_MAX_PGRCD_EXCD}==0
...    NRCELL-5:${NRPAG_PAGING_SUCC_SENT}==4
...    NRCELL-5:${NRPAG_PAG_DROP_MAX_PGRCD_EXCD}==0

${ue_num_B013}    10
@{pm_couter_B013}
...    NRCELL-1:${NRPAG_PAGING_SUCC_SENT}>=2
...    NRCELL-1:${NRPAG_PAG_DROP_MAX_PGRCD_EXCD}>=1
...    NRCELL-5:${NRPAG_PAGING_SUCC_SENT}>=2
...    NRCELL-5:${NRPAG_PAG_DROP_MAX_PGRCD_EXCD}>=1

${NRPAG_PAGING_SUCC_SENT}    M55331C00001
#This counter indicates the total number of RRC Paging messages scheduled for broadcast at 5G-L2-PS.
${NRPAG_PAG_DROP_MAX_PGRCD_EXCD}    M55331C00002
#This counter indicates the total number of Paging message dropped at 5G-L2-PS when the number of Paging Records
#per Paging message exceeds the max count (R&D Parameter:rdMaxNumPagingRecords 0x5801BE which default is 8). Counted at a NRCELL level

*** Test Cases ***
CB008285_ET_A017_FR2_SA_Cells_with_32SSB_and_beam_group_change_successfully
    [Documentation]
    ...    1. This user scenario describes when how to configure Beam Group to UE and how Beam Group change works in FR2 SA Cell.
    ...    Configuration:
    ...    cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...    configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...    2.Test Case Steps:
    ...          a. set UE capa for n257, maxConfiguredResourceSetsPerCC=32 for UE1,maxConfiguredResourceSetsPerCC =16 for UE2,3
    ...          b. UE1 L3 CALL setup
    ...          c. UE2,3 L3 CALL setup and trigger beamgroup change from SSB0<patternId 8> to SSB10<patternId 18> to SSB23<patternId 31>
    ...    3. Expected Results:
    ...        Step a: UE capa updated
    ...        Step b: UE1 L3 CALL setup Successfully.
    ...        Step c: UE2,3 L3 CALL setup and trigger beamgroup change successfully.
    [Tags]     QC_300513    A017    LABEL-8T(8*100MHz_TDD_n257)    test
    Update UE capa    ue_num_start=1    ue_num_end=1    SA_Capa_perUE_Full=${SA_Capa_Support_n257_FR2}
    Update UE capa    ue_num_start=2    ue_num_end=3    SA_Capa_perUE_Full=${SA_Capa_Support_n257_FR2_16CSIRS_TRS}
    UE Attach To Target Cell Then Send And Verify Throughput
    Start To Capture GNB BIP Log    tag=gnb_bip
    UE Beamgroup Change    ue_id=2    cell=1
    UE Beamgroup Change    ue_id=3    cell=5
    sleep    3s    Wait for beamgroup change triggered
    Stop To Capture GNB BIP Log    tag=gnb_bip
    check wireshark log    ${CURDIR}/a2a_A017/a2a.ini    wait_string=rrcReconfiguration::73

CB008285_ET_B012_5GC002314_K001_Verify_Paging_for_different_pagingTargetRateIndex_with_feature_flag_enable_disable_TDD
    [Documentation]
    ...    1. This user scenario describes Verify Paging for different pagingTargetRateIndex
    ...    Configuration:
    ...    cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...    configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...    online set pagingTargetRate for NRCELL1: MCS9_SF0 and NRCELL5: MCS4_SF2
    ...    2.Test Case Steps:
    ...          a. online set pagingTargetRate for NRCELL1: MCS9_SF0 and NRCELL5: MCS4_SF2
    ...          b. set UE capa for n257
    ...          c. UE1,UE2 register on NRCELL1 without PDU session, UE3,4 register on NRCELL5 without PDU session
    ...          d. trigger UEs idle, and paging ALL UEs from AMF
    ...          e. check paging messages scheduled correctly with MCS, PRB, pattern ID<mapping to SSB0,SSB31>
    ...          f. check legacy paging counter updated correctly
    ...          g. online recover pagingTargetRate for NRCELL1: MCS9_SF0 and NRCELL5: MCS4_SF2
    ...    3. Expected Results:
    ...        Step a: pagingTargetRate modified Successfully.
    ...        Step c: UE1-4 Register Successfully.
    ...        Step d: UE1-4 in RRC-idle state. and then ALL UEs paged up successfully.
    ...        Step e: check paging messages scheduled correctly with MCS, PRB, pattern ID<mapping to SSB0,SSB31>
    ...        Step f: counter pegged correctly
    ...        Step g: pagingTargetRate modified Successfully back to pagingDciAggregation
    [Tags]     QC_302795    B012     LABEL-8T(8*100MHz_TDD_n257)    test
    OnlineParamChange    ${Delta_Params_Paging_MCS}
    Update UE capa    SA_Capa_perUE_Full=${SA_Capa_Support_n257_FR2}
    clear counter files    wait=${False}
    SA UE Register    cell=1    ue_num_start=1    ue_num_end=2
    SA UE Register    cell=5    ue_num_start=3    ue_num_end=4
    Make UE to idle    ue_num=4
    Paging From AMF
    UE Deregister From GNB    ue_num=4
    Check Paging Messages Scheduling shall be correctly
    check counters    ${pm_couter_B012}
    OnlineParamChange    ${Recover_Params_Paging_MCS}

CB008285_ET_B013_5GC002314_K005_Verify_paging_counter_update_TDD
    [Documentation]
    ...    1. This user scenario describes Verification of paging counters for every paging message arrival and
    ...       paging drop counter for more than paging messages arrival with FR2 SA Cells.
    ...    Configuration:
    ...    cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...    cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...    configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...    2.Test Case Steps:
    ...          a. set 5G-S-TMSI for 10 UEs, 5G-S-TMSI mod 1024 =1 for ALL UEs
    ...          b. UE1-UE10 register on NRCELL1 without PDU session
    ...          c. trigger UEs idle, and paging ALL UEs from AMF
    ...          d. check legacy paging counter updated correctly
    ...    3. Expected Results:
    ...        Step a: 5G-S-TMSI mod 1024 =1 to make sure UEs paging could be scheduled in same Paging message.
    ...        Step b: UE1-10 Register Successfully.
    ...        Step c: UE1-10 in RRC-idle state. and then ALL UEs paged up successfully.
    ...        Step d: counter pegged correctly
    [Tags]     QC_302805    B013     LABEL-8T(8*100MHz_TDD_n257)
    Update UE capa    SA_Capa_perUE_Full=${SA_Capa_Support_n257_FR2}
    Set 5G-TMSI
    clear counter files
    SA UE Register    ue_num_end=${ue_num_B013}    cell=1
    Make UE to idle    ue_num=${ue_num_B013}
    Start To Capture GNB BIP Log    tag=gnb_bip
    Paging for All UEs from AMF and expect one paging
    Stop To Capture GNB BIP Log    tag=gnb_bip
    Reset 5G-TMSI
    check counters    ${pm_couter_B013}
    UE Deregister From GNB    ue_num=${ue_num_B013}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/8cells_ecpri    ue_count=${ue_num_All}

Paging From AMF
    Start To Capture GNB BIP Log    tag=gnb_bip
    Paging for All UEs from AMF and expect one paging
    Stop To Capture GNB BIP Log    tag=gnb_bip

Set 5G-TMSI
    ${cmd}    catenate    SEPARATOR=
    ...    amf_registration_param id=1 tmsi=1,1025,2049,3073,4097,5121,6145,7169,8193,9217,10241,11265,12289,13313,14337,15361,
    ...    16385,17409,18433,19457,20481,21505,22529,23553,24577,25601,26625,27649,28673,29697,30721,31745,32769
    Execute Egate Command    ${cmd}

Reset 5G-TMSI
    Execute Egate Command    amf_registration_param id=1 reset

Update UE capa
    [Arguments]    ${ue_num_start}=1    ${ue_num_end}=${ue_num_All}    ${SA_Capa_perUE_Full}=none
    FOR    ${index}    IN RANGE    ${ue_num_start}    ${ue_num_end}+1
        ${cmd}    catenate    ue_param id=${index} ue_nr_capabilities=${SA_Capa_perUE_Full}
        Execute Egate Command    ${cmd}
    END

SA UE Register
    [Arguments]    ${cell}    ${ue_num_start}=1    ${ue_num_end}=${ue_num_All}
    FOR    ${index}    IN RANGE    ${ue_num_start}    ${ue_num_end}+1
        Execute Egate Command    ue_change_location id=${index} enb=2 cell=${cell}
        Execute Egate Command    ue_register id=${index}    pass_regexp=NG RM Register
    END

Paging for All UEs from AMF and expect one paging
    Execute Egate Command    amf_paging_param id=1 default_drx=256 max_paging_retries=10
    Execute Egate Command    amf_paging_start id=1 ue=all    pass_regexp=No response for SERVICE-REQUEST    timeout=60

Make UE to idle
    [Arguments]    ${ue_num}=${ue_num_All}
    FOR    ${index}    IN RANGE    1    ${ue_num}+1
        Execute Egate Command    ue_ng_ctx_release id=${index} cause=NAS_normal_release    pass_regexp=UE Context Release Complete
    END

UE Deregister From GNB
    [Arguments]    ${ue_num}=${ue_num_All}
    FOR    ${index}    IN RANGE    1    ${ue_num}+1
        Execute Egate Command    ue_deregister id=${index} ue_deregister_type=switch_off    pass_regexp=detached
    END

Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=7 ue=all
    Update Cfg    set_qosflow id=3 5qi=8 ue=all
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all qos_flows=2,1,3 qos_rules=1,2 amf=1

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir    cell_id=1
    Cells Should Be OnAir    cell_id=5

UE Attach To Target Cell Then Send And Verify Throughput
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=1 nwslice=1
    ...    pass_regexp=QoS Routing Table    timeout=10s
    Send And Verify Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=100 trf_id=1    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=40 trf_id=1    pass_regexp=UE ${ue_id}: UDP UL
    Verify Throuput on Pcell    ue_id=${ue_id}    sleep_time=10s

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=1    ${pcell_tput_except_dl}=90    ${pcell_tput_except_ul}=35    ${sleep_time}=10s    ${scell}=0
    sleep    ${sleep_time}
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell}    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000>${pcell_tput_except_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell}    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${pcell_tput_except_ul}

UE Beamgroup Change
    [Arguments]    ${ue_id}=1    ${cell}=1
    UE Attach To Target Cell Then Send And Verify Throughput     ue_id=${ue_id}    cell_id=${cell}    pdu_id=1
    Beamgroup Change Trigger Active    ue_id=${ue_id}
    Beamgroup Change Trigger Deactive    ue_id=${ue_id}
    Verify Throuput on Pcell    ue_id=${ue_id}    sleep_time=10s

Beamgroup Change Trigger Active
    [Arguments]    ${ue_id}=1
    Beam Testmod Set    ue_id=${ue_id}    profile_id=1    Initial=0,1,2,3,7,8,9,10    bestbeam=0    beamaction=attach
    sleep    8s    Wait for beam choose
    Beam Testmod Set    ue_id=${ue_id}    profile_id=2    Initial=0    bestbeam=10    beamaction=switch
    sleep    8s    Wait for beam switch finished
    Beam Testmod Set    ue_id=${ue_id}    profile_id=3    Initial=10    bestbeam=23    beamaction=switch
    sleep    10s    Wait for beam switch finished

Beam Testmod Set
    [Arguments]    ${ue_id}=1    ${profile_id}=1    ${Initial}=0    ${bestbeam}=0    ${beamaction}=attach
    ${cmd}    catenate    beam_control_testmode_nr profile_id=${profile_id} beamType=Analog ueBeamIndexInitial=${Initial} ssbeam_bestbeam=${bestbeam}
    ...    ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    Execute Egate Command    ${cmd}
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=beam_control profile_id=${profile_id} action=activate beamaction=${beamaction}

Beamgroup Change Trigger Deactive
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=beam_control profile_id=1 action=deactivate
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=beam_control profile_id=2 action=deactivate
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=beam_control profile_id=3 action=deactivate

Check BIP Messages
    [Arguments]    ${filter}
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}gnb_bip_logs_gnb_bip/mirroring_L2L1.pcap    ${filter}
    should be equal As Numbers    ${number}    4

Check Paging Messages Scheduling shall be correctly
    Check BIP Messages    filter=${filter1}
    Check BIP Messages    filter=${filter2}
    Check BIP Messages    filter=${filter3}
    Check BIP Messages    filter=${filter4}
