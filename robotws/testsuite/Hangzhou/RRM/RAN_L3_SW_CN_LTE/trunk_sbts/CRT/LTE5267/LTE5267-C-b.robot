*** Settings ***
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO
...               team-DevHZ5_SG9    owner-chendong.he    release-SBTS20A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS-${BTS_INFO.ID}:actTraceOvlProt=false    # activates the overload protection mechanism will not print debug and info syslog
...    @{Delete_CAREL}
...    @{CBRS}
...    @{OVERLOAD_PARAMS}
...    @{CBRS_PARAM}
...    LNBTS-1:actAmbrModCaTrigger=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNCEL-1:actFlowCtrlEnh=true
...    LNCEL-2:actFlowCtrlEnh=true
...    LNCEL-5:actFlowCtrlEnh=true
...    LNCEL-5:actCaArchEnhImp=off
...    LNCEL-5:caPoolId=0
...    MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1:bbCardUsage=1
...    MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-2:bbCardUsage=1
...    MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-3:bbCardUsage=1
@{Delete_CAREL}
...    delete:LNCEL-${CELL1_INFO.ID}/CAREL-2
...    delete:LNCEL-${CELL1_INFO.ID}/CAREL-3
...    LNBTS-${BTS_INFO.ID}/CBSD-1:supportedSpectrumV2=1073741823

@{CBRS}
...    LNBTS-${BTS_INFO.ID}:actDLCAggr=true
...    LNBTS-${BTS_INFO.ID}/LNBTS_TDD-0:actCbrs=true
...    LNBTS-${BTS_INFO.ID}:actEnhCbrsCAggr=true
...    LNBTS-${BTS_INFO.ID}/LNBTS_TDD-0:numTxWithHighNonGbr=1
...    LNBTS-${BTS_INFO.ID}:actAdvStepwiseScellAdd=off
...    LNCEL-${CELL2_INFO.ID}:scellFastSchedulingSelect=normal
...    LNCEL-${CELL2_INFO.ID}:actScellConfigForHiDemand=false
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:lcrId=${CELL3_INFO.ID}
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:lnBtsId=1
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:scellPrio=1
...    delete:LNCEL-${CELL1_INFO.ID}/CAREL-1:beamformingInScellAllowed
...    LNCEL-${CELL2_INFO.ID}/CAREL-1:lcrId=${CELL3_INFO.ID}
...    LNCEL-${CELL2_INFO.ID}/CAREL-1:lnBtsId=1
...    LNCEL-${CELL2_INFO.ID}/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-${CELL2_INFO.ID}/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-${CELL2_INFO.ID}/CAREL-1:scellPrio=1
...    delete:LNCEL-${CELL2_INFO.ID}/CAREL-1:beamformingInScellAllowed
...    LNCEL-${CELL2_INFO.ID}/CAREL-2:lcrId=${CELL4_INFO.ID}
...    LNCEL-${CELL2_INFO.ID}/CAREL-2:lnBtsId=1
...    LNCEL-${CELL2_INFO.ID}/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-${CELL2_INFO.ID}/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-${CELL2_INFO.ID}/CAREL-2:scellPrio=1
...    delete:LNCEL-${CELL2_INFO.ID}/CAREL-2:beamformingInScellAllowed
...    LNBTS-${BTS_INFO.ID}/LNCEL-${CELL1_INFO.ID}/LNCEL_FDD-0:earfcnDL=700
...    LNBTS-${BTS_INFO.ID}/LNCEL-${CELL2_INFO.ID}/LNCEL_FDD-0:earfcnDL=900
...    LNCEL-${CELL1_INFO.ID}/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-${CELL1_INFO.ID}/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-${CELL2_INFO.ID}/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-${CELL2_INFO.ID}/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-${CELL3_INFO.ID}/LNCEL_TDD-0:chBw=10 MHz
...    LNCEL-${CELL4_INFO.ID}/LNCEL_TDD-0:chBw=10 MHz
@{CBRS_PARAM}
...    LNBTS-${BTS_INFO.ID}/CBSD-1:antennaGain=8
...    LNCEL-${CELL3_INFO.ID}/CBSDCEL-0:maxGrantPwrRed=10
...    LNCEL-${CELL3_INFO.ID}/CBSDCEL-0:desiredPmax=320
...    LNCEL-${CELL4_INFO.ID}/CBSDCEL-0:maxGrantPwrRed=10
...    LNCEL-${CELL4_INFO.ID}/CBSDCEL-0:desiredPmax=320
@{OVERLOAD_PARAMS}
...    LNBTS-${BTS_INFO.ID}:actCplaneOvlHandling=true
...    LNBTS-${BTS_INFO.ID}:caConfigRatioOvl1=0
...    LNBTS-${BTS_INFO.ID}:cpovlha:enableInHoRed=OVL2only
...    LNBTS-${BTS_INFO.ID}:cpovlha:enableRrcConnRed=OVL2only
@{PARAMS_IN_EMIL}
...    0x3661
@{RECOVER_CELL3_EARFCN}
...    LNCEL-${CELL3_INFO.ID}/LNCEL_TDD-0:chBw=10 MHz
@{PARAMS_IN_VENDOR}
...    LNBTS_FDD:ovlIpcPoolUsageL2=50
...    LNBTS_TDD:ovlIpcPoolUsageL2=50
...    LNBTS:ovlOccurrences=1
...    LNBTS:ovlThrOvl1=1
...    LNBTS:ovlThrOvl2=1
...    LNBTS:ovlTimer=60
@{PARAMS_IN_SWCONFIG}
...    0x00130040=1
...    0x45000B=1
#TUecRadEnableCPlaneOverloadLogs
@{CBRS_MODIFY_EARFCN}
...    LNBTS-${BTS_INFO.ID}/LNCEL-${CELL3_INFO.ID}/LNCEL_TDD-0:chBw=20 MHz
@{CBRS_MODIFY_EARFCN_2}
...    LNBTS-${BTS_INFO.ID}/LNCEL-${CELL3_INFO.ID}/LNCEL_TDD-0:chBw=10 MHz
${UE_CAP_2A_48A_48A}    CDB80281077C102013FFFFFFFC00801C1E7FFFFFFFD52A56E281070400006F000582000037801BC000408087FFFFFFF8A288F192
${UE_CAP_NO_CA}    CDB80281077C102013FFFFFFFC00801C1E7FFFFFFFD52A56E281070400004200058200002100108000408087FFFFFFF8A288F192
${UE_ID_LIST_1}    5-100
${UE_ID_LIST_2}    105-200
${UE101}          101
${UE102}          102
${CELL3_NEW_EARFCN}    55440
${EXPECTED_LEAST_TP_EACH_SCELL}    10000
${OVERLOAD_MSG}    .*-UEC.*Updating time spent on level Overload2
${NOT_OVERLOAD_MSG}    .*-UEC.*Updating time spent on level MinorLoad
${UTE_WIRESHARK_FLAG}    ${False}
${BTS_INFO.ID}    1
${CELL1_INFO.ID}    1
${CELL2_INFO.ID}    2
${CELL3_INFO.ID}    3
${CELL4_INFO.ID}    4


*** Test Cases ***
LTE5267-C-b_handling multiple UEs upon frequency change for CBSD SCell while eNB in overload
    [Documentation]    LTE5267 cross with LTE1407
    ...    1. UE1 attach at cell1, UE101,UE102 attach cell2
    ...    2. Send traffic to UE1 and UE101 to triffger CA.
    ...    3. Simulate Cplane in overload state
    ...    4. Stop traffic and Modify CBRS frequency F3 to F3m
    ...    5. Send traffic to UE1,UE101,UE102
    ...    6. Check no scell(Cell-3) added back
    ...    7. Recover env and Cplane not in overload
    ...    8. Stop traffic and Modify CBRS frequency F3m to F3n
    ...    9. Check scell(Cell-3) added back for UE1 and UE101, Scell(cell3,cell-4) configured for UE102
    ...    10. Ue detach
    [Tags]
    Multi UE Attach and Checking Scell is Configured
    Trigger Cplane Overload With Multiple Ue Attach
    Do Delta Commission and Wait for Cell Start Up    ${CBRS_MODIFY_EARFCN}
    Execute Uex Command And Expect Error    ue_attach id=${UE_ID_LIST_1} cell=1 ue_eutra_capabilities=${UE_CAP_NO_CA} interval=0
    ...    ElixirException
    sleep    10s    #wait reach overload state
    Execute Uex Command And Expect Error    ue_attach id=${UE_ID_LIST_2} cell=2 ue_eutra_capabilities=${UE_CAP_NO_CA} interval=0
    ...    ElixirException
    sleep    10s    #wait reach overload state
    Checking Cplane Reach Overload State
    Send Traffic and Check No scell Add Back for Cplane overload
    Recover no Overload
    Do Delta Commission and Wait for Cell Start Up    ${CBRS_MODIFY_EARFCN_2}
    Send Traffic and Check Scell Add Back
    Check Traffic Go Through Scells
    [Teardown]    Common Case Teardown and Recover ENV

*** Keywords ***
Common Suite Setup And Setup Cus Env
    Common Suite Setup
    Start SAS Server
    Setup CUS Env    tl_type=2CELLs_FDD_3CELLs_TDD_2B2_2B48    ue_count=500
    #Debug enter into egate
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc on
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_101    ue_id=101    id_type=cus
    Create UE Alias    UE_102    ue_id=102    id_type=cus

Multi UE Attach and Checking Scell is Configured
    [Documentation]    
    Execute Uex Command    ue_param id=1-10 ue_eutra_capabilities=${UE_CAP_2A_48A_48A}
    Execute Uex Command    ue_param id=101-110 ue_eutra_capabilities=${UE_CAP_2A_48A_48A}
    Single UE Attach To Pcell    ueid=1    cellid=1
    UE1 Send Traffic to Trigger CA
    Single UE Attach To Pcell    ueid=${UE101}    cellid=2
    UE101 Send Traffic to Trigger CA    ueid=${UE101}
    Single UE Attach To Pcell    ueid=${UE102}    cellid=2

Single UE Attach To Pcell
    [Arguments]    ${ueid}=3001    ${cellid}=1    ${sleeptime}=0
    Execute Uex Command    ue_attach id=${ueid} cell=${cellid}
    sleep    ${sleeptime}

UE1 Send Traffic to Trigger CA
    [Arguments]    ${ueid}=1    ${alias_name}=LTE5267_C_b_flow1
    # Trigger B2_B48 2CC DL CA on Cell1
    ${DL_2CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 3)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 1
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration ( ${DL_2CC_scell_addition} )
    ...    alias=${alias_name}    overall_timeout=20
    Execute Uex Command    trf_data_start ue=${ueid} dir=dl protocol=udp Mbps=100 trf_id=1 stats=true
    Execute Uex Command    trf_data_start ue=${ueid} dir=ul protocol=udp Mbps=100 trf_id=1 stats=true
    Flow Occurred As Expected    alias=${alias_name}

UE101 Send Traffic to Trigger CA
    [Arguments]    ${ueid}=101    ${cellid}=1    ${alias_name}=LTE5267_C_b_flow2
    # Trigger B2_B48_B48 3CC DL CA on Cell2
    ${DL_3CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2 and cellIdentification-r10 contains (
    ...    physCellId-r10 eq 3) and
    ...    sCellIndex-r10 ne 3
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_${ueid}:RRC_RRCConnectionReconfiguration ( ${DL_3CC_scell_addition} )
    ...    alias=${alias_name}    overall_timeout=20
    Execute Uex Command    trf_data_start ue=${ueid} dir=dl protocol=udp Mbps=100 trf_id=1 stats=true
    Execute Uex Command    trf_data_start ue=${ueid} dir=ul protocol=udp Mbps=100 trf_id=1 stats=true
    Flow Occurred As Expected    alias=${alias_name}

UE102 Send Traffic to Trigger CA
    [Arguments]    ${ueid}=101    ${cellid}=1    ${alias_name}=LTE5267_C_b_flow8
    UE101 Send Traffic to Trigger CA    ueid=${ueid}    cellid=${cellid}    alias_name=${alias_name}

Trigger Cplane Overload With Multiple Ue Attach
    Build UEC Overload Bts Log Info
    Execute Uex Command And Expect Error    ue_attach id=${UE_ID_LIST_1} cell=1 ue_eutra_capabilities=${UE_CAP_NO_CA} interval=0
    ...    ElixirException
    #    ...    Can't make sure these UEs attach successfully for setting Cplane overload threshold low
    Execute Uex Command And Expect Error    ue_attach id=${UE_ID_LIST_2} cell=2 ue_eutra_capabilities=${UE_CAP_NO_CA} interval=0
    ...    ElixirException
    #    ...    Can't make sure these UEs attach successfully for setting Cplane overload threshold low
    Checking Cplane Reach Overload State

Send traffic and Check scell add back
    UE1 Send Traffic to Trigger CA    ueid=${UE1}    alias_name=LTE5267_C_b_flow6
    UE101 Send Traffic to Trigger CA    ueid=${UE101}    alias_name=LTE5267_C_b_flow7
    UE102 Send Traffic to Trigger CA    ueid=${UE102}    alias_name=LTE5267_C_b_flow8

Send traffic and Check No scell add back for Cplane overload
    UE1 Send Traffic and Check No Scell Configured    ueid=${UE1}
    UE101 Send Traffic and Check No Scell Configured    ueid=${UE101}
    UE102 Send Traffic and Check No Scell Configured    ueid=${UE102}

UE1 Send Traffic and Check No Scell Configured
    [Arguments]    ${ueid}
    ${DL_2CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 3)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 1
    Expect Message Will Not Occur
    ...    UE_1:RRC_RRCConnectionReconfiguration ( ${DL_2CC_scell_addition} )
    ...    alias=LTE5267_C_b_flow3    overall_timeout=20
    UE Send Traffic and Check No Scell Configured    ueid=${UE1}
    Flow Not Occurred For Message    alias=LTE5267_C_b_flow3

UE101 Send Traffic and Check No Scell Configured
    [Arguments]    ${ueid}
    ${DL_3CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2 and cellIdentification-r10 contains (
    ...    physCellId-r10 eq 3) and
    ...    sCellIndex-r10 ne 3
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Will Not Occur
    ...    UE_101:RRC_RRCConnectionReconfiguration ( ${DL_3CC_scell_addition} )
    ...    alias=LTE5267_C_b_flow4    overall_timeout=20
    UE Send Traffic and Check No Scell Configured    ueid=${UE101}
    Flow Not Occurred For Message    alias=LTE5267_C_b_flow4

UE102 Send Traffic and Check No Scell Configured
    [Arguments]    ${ueid}
    ${DL_3CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2 and cellIdentification-r10 contains (
    ...    physCellId-r10 eq 3) and
    ...    sCellIndex-r10 ne 3
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Will Not Occur
    ...    UE_101:RRC_RRCConnectionReconfiguration ( ${DL_3CC_scell_addition} )
    ...    alias=LTE5267_C_b_flow5    overall_timeout=20
    UE Send Traffic and Check No Scell Configured    ueid=${UE102}
    Flow Not Occurred For Message    alias=LTE5267_C_b_flow5

UE Send Traffic and Check No Scell Configured
    [Arguments]    ${ueid}
    Execute Uex Command    trf_data_stop ue=${ueid} trf_id=1 dir=ul
    Execute Uex Command    trf_data_stop ue=${ueid} trf_id=1 dir=dl
    Execute Uex Command    trf_data_start ue=${ueid} dir=dl protocol=udp Mbps=100 trf_id=1
    Execute Uex Command    trf_data_start ue=${ueid} dir=ul protocol=udp bps=10000 trf_id=1

Recover no Overload
    Delete Noise UE
    Checking Cplane Not In Overload State
    Execute Uex Command    trf_data_stop ue=${UE1} trf_id=1 dir=ul
    Execute Uex Command    trf_data_stop ue=${UE1} trf_id=1 dir=dl
    Execute Uex Command    trf_data_stop ue=${UE101} trf_id=1 dir=ul
    Execute Uex Command    trf_data_stop ue=${UE101} trf_id=1 dir=dl
    Execute Uex Command    trf_data_stop ue=${UE102} trf_id=1 dir=ul
    Execute Uex Command    trf_data_stop ue=${UE102} trf_id=1 dir=dl

Delete Noise UE
    Execute Uex Command And Expect Error    ue_detach id=${UE_ID_LIST_1},${UE_ID_LIST_2}    RuntimeError
    Execute Uex Command    get_ue_summary

Do Delta Commission and Wait for Cell Start Up
    [Arguments]    ${delta_commission_file}
    Delta Commission Parameters    ${delta_commission_file}
    Cells Should Be OnAir

Checking Cplane Reach Overload State
    Start syslog    log_dir=${SAVE LOG DIRECTORY}    log_name=overload.log    ip=192.168.255.126    alias=overload
    Wait Until Keyword Succeeds    5min    2s    Checking Overload State    regexp=${OVERLOAD_MSG1}    alias=overload
    Wait Until Keyword Succeeds    5min    2s    Checking Overload State    regexp=${OVERLOAD_MSG2}    alias=overload
    collect_syslog_results    alias=overload

Checking Overload State
    [Arguments]    ${regexp}    ${alias}
    ${counter}    ute_syslog.Count Syslog Messages    regexp=${regexp}    alias=${alias}
    Should be True    ${counter}>2

Checking Cplane Not In Overload State
    Start syslog    log_dir=${SAVE LOG DIRECTORY}    log_name=not_overload.log    ip=192.168.255.126    alias=not_overload
    Wait Until Keyword Succeeds    8min    10s    Checking Overload State    regexp=${NOT_OVERLOAD_MSG1}    alias=not_overload
    Wait Until Keyword Succeeds    8min    10s    Checking Overload State    regexp=${NOT_OVERLOAD_MSG2}    alias=not_overload
    collect_syslog_results    alias=not_overload

Common Case Teardown and Recover ENV
    Do Delta Commission and Wait for Cell Start Up    ${RECOVER_CELL3_EARFCN}
    Common Test Teardown And Stop Capture Logs

Build UEC Overload Bts Log Info
    ${cell1_uec_node}    Get UEC node    1
    ${cell2_uec_node}    Get UEC node    2
    ${OVERLOAD_MSG1}    set variable    FCT-${cell1_uec_node[2:]}-${OVERLOAD_MSG}
    ${OVERLOAD_MSG2}    set variable    FCT-${cell2_uec_node[2:]}-${OVERLOAD_MSG}
    ${NOT_OVERLOAD_MSG1}    set variable    FCT-${cell1_uec_node[2:]}-${NOT_OVERLOAD_MSG}
    ${NOT_OVERLOAD_MSG2}    set variable    FCT-${cell2_uec_node[2:]}-${NOT_OVERLOAD_MSG}
    Set Suite Variable    ${OVERLOAD_MSG1}
    Set Suite Variable    ${OVERLOAD_MSG2}
    Set Suite Variable    ${NOT_OVERLOAD_MSG1}
    Set Suite Variable    ${NOT_OVERLOAD_MSG2}

Check Dl Traffic On Scell
    [Arguments]    ${ueid}    ${scellid}
    ${bearer_state_dl}=    Execute Uex Command    get_ue_stats id=${ueid} type=dl_rlc scell=${scellid}
    ${cur_scell_tput}=    Get Current Scell Traffic Value    ue_stats_output=${bearer_state_dl}    scellid=${scellid}
    Should be true    ${cur_scell_tput}>${EXPECTED_LEAST_TP_EACH_SCELL}

Get Current Scell Traffic Value
    [Arguments]    ${ue_stats_output}    ${scellid}
    ${UE_dict}=      Set Variable      &{ue_stats_output}[UE]
    ${Scell_dict}=      Set Variable      &{UE_dict}[Scell-${scellid}]
    ${value}=      Convert To Integer     &{Scell_dict}[cur]
    [Return]    ${value}

Check Traffic Go Through Scells
    Check Dl Traffic On Scell    ueid=${UE1}    scellid=1
    Check Dl Traffic On Scell    ueid=${UE101}    scellid=1
    Check Dl Traffic On Scell    ueid=${UE102}    scellid=1

