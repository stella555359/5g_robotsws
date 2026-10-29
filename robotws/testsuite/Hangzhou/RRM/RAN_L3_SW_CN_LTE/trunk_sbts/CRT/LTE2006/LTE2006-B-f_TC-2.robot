*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO
...               DevHZ5_FV    owner-chendong.he
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${LNCEL11}    LNCEL-1
${LNCEL21}    LNCEL-2
${LNCEL22}    LNCEL-3
${LNCEL23}    LNCEL-4
${LNCEL31}    LNCEL-5
${LNCEL32}    LNCEL-6
${CELL21}    2
${CELL22}    3
${CELL23}    4
${CELL31}    5
${CELL32}    6

@{PARAMS_IN_SCF}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=false
...    LNBTS-1:actFlexScellSelect=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1:multScellReleaseTimer=0
...    LNBTS-1:actZUC=true
...    LNBTS-1:actCiphering=true
...    LNBTS-1:nullFallback=true
...    LNBTS-1:cipherPrefL:eea0=1
...    LNBTS-1:cipherPrefL:eea1=8
...    LNBTS-1:cipherPrefL:eea2=8
...    LNBTS-1:cipherPrefL:eea3=9
...    LNBTS-1:integrityPrefL:eia0=0
...    LNBTS-1:integrityPrefL:eia1=8
...    LNBTS-1:integrityPrefL:eia2=8
...    LNBTS-1:integrityPrefL:eia3=9
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=0
...    ${LNCEL11}/LNCEL_FDD-0:dlChBw=5 MHz
...    ${LNCEL11}/LNCEL_FDD-0:ulChBw=5 MHz
...    ${LNCEL21}/LNCEL_FDD-0:dlChBw=5 MHz
...    ${LNCEL21}/LNCEL_FDD-0:ulChBw=5 MHz
...    ${LNCEL22}/LNCEL_FDD-0:dlChBw=5 MHz
...    ${LNCEL22}/LNCEL_FDD-0:ulChBw=5 MHz
...    ${LNCEL23}/LNCEL_FDD-0:dlChBw=5 MHz
...    ${LNCEL23}/LNCEL_FDD-0:ulChBw=5 MHz
...    ${LNCEL31}/LNCEL_FDD-0:dlChBw=5 MHz
...    ${LNCEL31}/LNCEL_FDD-0:ulChBw=5 MHz
...    ${LNCEL32}/LNCEL_FDD-0:dlChBw=5 MHz
...    ${LNCEL32}/LNCEL_FDD-0:ulChBw=5 MHz
...    ${LNCEL11}/CAREL-2:lcrId=${CELL21}
...    ${LNCEL11}/CAREL-2:lnBtsId=1
...    ${LNCEL11}/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL11}/CAREL-2:pcellSwapAllowed=allowed
...    ${LNCEL11}/CAREL-2:scellPrio=3
...    ${LNCEL11}/CAREL-3:lcrId=${CELL22}
...    ${LNCEL11}/CAREL-3:lnBtsId=1
...    ${LNCEL11}/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL11}/CAREL-3:pcellSwapAllowed=allowed
...    ${LNCEL11}/CAREL-3:scellPrio=5
...    ${LNCEL11}/CAREL-4:lcrId=${CELL23}
...    ${LNCEL11}/CAREL-4:lnBtsId=1
...    ${LNCEL11}/CAREL-4:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL11}/CAREL-4:pcellSwapAllowed=allowed
...    ${LNCEL11}/CAREL-4:scellPrio=5
...    ${LNCEL11}/CAREL-5:lcrId=${CELL31}
...    ${LNCEL11}/CAREL-5:lnBtsId=1
...    ${LNCEL11}/CAREL-5:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL11}/CAREL-5:pcellSwapAllowed=allowed
...    ${LNCEL11}/CAREL-5:scellPrio=3
...    ${LNCEL11}/CAREL-6:lcrId=${CELL32}
...    ${LNCEL11}/CAREL-6:lnBtsId=1
...    ${LNCEL11}/CAREL-6:maxNumOfSuppMimoLayer=2-layer
...    ${LNCEL11}/CAREL-6:pcellSwapAllowed=allowed
...    ${LNCEL11}/CAREL-6:scellPrio=5
...    ${LNCEL21}/LNCEL_FDD-0:earfcnDL=1700
...    ${LNCEL21}/LNCEL_FDD-0:earfcnUL=19700
...    ${LNCEL22}/LNCEL_FDD-0:earfcnDL=1700
...    ${LNCEL22}/LNCEL_FDD-0:earfcnUL=19700
...    ${LNCEL23}/LNCEL_FDD-0:earfcnDL=1700
...    ${LNCEL23}/LNCEL_FDD-0:earfcnUL=19700
...    ${LNCEL31}/LNCEL_FDD-0:earfcnDL=3000
...    ${LNCEL31}/LNCEL_FDD-0:earfcnUL=21000
...    ${LNCEL32}/LNCEL_FDD-0:earfcnDL=3000
...    ${LNCEL32}/LNCEL_FDD-0:earfcnUL=21000
&{cacap}
...    CC3+2=1
...    CC2=1
${ue_eutra_capabilities}    ${EMPTY}
${withoutsetenv}    ${False}
@{Commission_for_Priority}
...    ${LNCEL23}:maxNumActDrb=1
...    ${LNCEL23}:maxNumCaConfUe=1
...    ${LNCEL23}:maxNumCaConfUeDc=1
...    ${LNCEL23}:maxNumCaConfUe3c=1
...    ${LNCEL23}:maxNumQci1Drb=0
...    ${LNCEL23}:maxNumActUE=1
...    ${LNCEL23}/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=1
...    ${LNCEL23}/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrcEmergency=16
...    ${LNCEL23}/LNCEL_FDD-0/MPUCCH_FDD-0:minNumRrc=0
...    ${LNCEL23}/LNCEL_FDD-0/MPUCCH_FDD-0:minNumRrcNoDrb=0
...    ${LNCEL11}/CAREL-2:scellPrio=4
...    ${LNCEL11}/CAREL-4:scellPrio=1
...    ${LNCEL11}/CAREL-3:scellPrio=5
...    ${LNCEL11}/CAREL-5:scellPrio=5
...    ${LNCEL11}/CAREL-6:scellPrio=5

${V_1}    SEPARATOR=
...    d5b80485001040c20d850bf85fc2fe17f0bf85fffffffffc00801c1e40000000152a56e
...    20e07000000420003800000230001c00000120000e000000b6000708000042000384000
...    0230001c2000016c0006100002061000040e3000008c00071800005b00018c000101b60
...    00103840000200001c6000010000382fe17f0bf85fc2fe17f0bf85fc2fe17f0bf85fc2f
...    e17f0bf9410000018e9f027c09f027c09f827c09f027809e027f09f027e09e027c09f0114468c200055000200452a0

${V_2}    SEPARATOR=
...    d5b80485001040c20d850bf85fc2fe17f0bf85fffffffffc00801c1e40000000152a56e
...    22307000000420003800000230001c00000120000e000000b6000708000042000384000
...    0230001c2000016c0006100002061000040e3000008c00071800005b00018c000101b60
...    00105800000210010800160000008400460005800000210016c000e00000084020b0000
...    004600230002c000001180090000b00000046002d8001c0000011804161000008400460
...    005840000210016c00161000008c00460005840000230016c000e1000008c0207080002
...    4600038400012d8001c6000096c000e1000008000071800004000058400002000118001
...    63000008000420003b60000200001db0000108001630000080005b00230bf85fc2fe17f
...    0bf85fc2fe17f0bf85fc2fe17f0bf85fc2fe17f0bf85fc2fe17f0bf85fc2fe17f0bf85f
...    c2fe17f0bf85fc2fe17f0bf85fc2fe17f282000003473e04f813e04f813f04f813e04f0
...    13c04fe13e04fc13c04f013e04f013c04f813e04fc13e04f813c04f813c04f813c04f01
...    3e04f813e04f813e04f813e04fc08a234610002a80010022950

*** Test Cases ***
LTE2006-B-f_TC-2_Two_SCells_added_after_connection_re-establishment
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    Attach 3CC and 2CC UE
    Add Scell for 3CC and 2CC
    Trigger Event A6 for Scell
    Collect UE Realtime Total Traffic    ueid=1
    Collect UE Realtime Total Traffic    ueid=3
    Reestablishment 3CC and 2CC UE

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=9CELLs_FDD
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc on
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus

Attach 3CC and 2CC UE
    ${DL_2CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq 1700)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 1
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration ( ${DL_2CC_scell_addition} )
    ...    alias=LTE2006-B-f_flow1    overall_timeout=30
    UE Attach To Pcell    ueid=1    ue_eutra_capabilities=${V_1}
    Flow Occurred As Expected    alias=LTE2006-B-f_flow1
    ${DL_3CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and cellIdentification-r10 contains (
    ...    physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq 1700),
    ...    sCellIndex-r10 eq 2 and cellIdentification-r10 contains (
    ...    physCellId-r10 eq 5 and dl-CarrierFreq-r10 eq 3000) and
    ...    sCellIndex-r10 ne 3
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_3:RRC_RRCConnectionReconfiguration ( ${DL_3CC_scell_addition} )
    ...    alias=LTE2006-B-f_flow2    overall_timeout=30
    UE Attach To Pcell    ueid=3    ue_eutra_capabilities=${V_2}
    Flow Occurred As Expected    alias=LTE2006-B-f_flow2

UE Attach To Pcell
    [Arguments]    ${ueid}=1    ${cellid}=1    ${ue_eutra_capabilities}=${V_1}    ${sleeptime}=0
    Execute Uex Command    ue_param id=${ueid} ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ue_attach id=${ueid} cell=${cellid} selected_plmn=262:03
    sleep    ${sleeptime}

Add Scell for 3CC and 2CC
    Increase Traffic To Add Scells    ueid=1    tp=38    sleeptime=5
    Increase Traffic To Add Scells    ueid=3    tp=38    sleeptime=5

Increase Traffic To Add Scells
    [Arguments]    ${ueid}=1    ${tp}=38    ${sleeptime}=5
    Execute Uex Command    trf_data_start ue=${ueid} dir=dl protocol=udp Mbps=${tp} trf_id=1 stats=true
    sleep    ${sleeptime}

Trigger Event A6 for Scell
    ${DL_scell_swap_1}    catenate
    ...    sCellToReleaseList-r10 contains (1) and
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 2,
    ...    sCellIndex-r10 eq 1 and cellIdentification-r10 contains (
    ...    physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq 1700)
    ...    )
	...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_3:RRC_RRCConnectionReconfiguration ( ${DL_scell_swap_1} )
    ...    alias=LTE2006-B-f_flow3    overall_timeout=30
    Report A6 To Trigger Scell Swap    ueid=3    cellid=${CELL22}
    Flow Occurred As Expected    alias=LTE2006-B-f_flow3
    ${DL_scell_swap_2}    catenate
    ...    sCellToReleaseList-r10 contains (2) and
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2 and cellIdentification-r10 contains (
    ...    physCellId-r10 eq 6 and dl-CarrierFreq-r10 eq 3000)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_3:RRC_RRCConnectionReconfiguration ( ${DL_scell_swap_2} )
    ...    alias=LTE2006-B-f_flow4    overall_timeout=30
    Report A6 To Trigger Scell Swap    ueid=3    cellid=${CELL32}
    Flow Occurred As Expected    alias=LTE2006-B-f_flow4

Report A6 To Trigger Scell Swap
    [Arguments]    ${ueid}=1    ${cellid}=${CELL22}
    ${measurement_command}    catenate
    ...    ue_measurement_send id=${ue_id} event=A6 phycell_id=${cellid} nrsrp=80 nrsrq=17 srsrp=75 srsrq=18
    ...     scell=1 scell_rsrp=40 scell_rsrq=30 amount=1
    Execute Uex Command    ${measurement_command}

Collect UE Realtime Total Traffic
    [Arguments]    ${ueid}=1
    Execute Uex Command    get_ue_stats id=${ueid} type=dl_rlc scell=0-4

Reestablishment 3CC and 2CC UE
    ${reestablish_check_UE3}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and cellIdentification-r10 contains (
    ...    physCellId-r10 eq 5 and dl-CarrierFreq-r10 eq 3000),
    ...    sCellIndex-r10 eq 2 and cellIdentification-r10 contains (
    ...    physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq 1700) and
    ...    sCellIndex-r10 ne 3
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_3:RRC_RRCConnectionReconfiguration ( ${reestablish_check_UE3} )
    ...    alias=LTE2006-B-f_flow5    overall_timeout=30
    Execute Uex Command    ue_rrc_reestablish id=3 cell=1 enb=1
    Flow Occurred As Expected    alias=LTE2006-B-f_flow5
    ${reestablish_check_UE1}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and cellIdentification-r10 contains (
    ...    physCellId-r10 eq 5 and dl-CarrierFreq-r10 eq 3000)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 1
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration ( ${reestablish_check_UE1} )
    ...    alias=LTE2006-B-f_flow6    overall_timeout=30
    Execute Uex Command    ue_rrc_reestablish id=1 cell=1 enb=1
    Flow Occurred As Expected    alias=LTE2006-B-f_flow6