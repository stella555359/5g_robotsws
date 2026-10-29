*** Settings ***
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4PPP
...               team-DevHZ5_SG9    owner-yingping.lou    release-SBTS19A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CBRS_PARAM}
...    @{CBRS_CA}
...    @{FIX_RELATION_ERRORS}

@{CBRS_CA}
...    LNBTS-${BTS_INFO.ID}:actDLCAggr=true
...    LNBTS-${BTS_INFO.ID}/LNBTS_TDD-0:actCbrs=true
...    LNBTS-${BTS_INFO.ID}:actEnhCbrsCAggr=true
...    LNBTS-${BTS_INFO.ID}/LNBTS_TDD-0:numTxWithHighNonGbr=1
...    LNBTS-${BTS_INFO.ID}:actAdvStepwiseScellAdd=off
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:lcrId=${CELL2_INFO.ID}
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:lnBtsId=1
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:scellPrio=1
...    LNCEL-${CELL1_INFO.ID}/CAREL-2:lcrId=${CELL3_INFO.ID}
...    LNCEL-${CELL1_INFO.ID}/CAREL-2:lnBtsId=1
...    LNCEL-${CELL1_INFO.ID}/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:lnBtsId=1
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:scellPrio=1
...    LNCEL-${CELL1_INFO.ID}/CAREL-2:lcrId=${CELL3_INFO.ID}
...    LNCEL-${CELL1_INFO.ID}/CAREL-2:lnBtsId=1
...    LNCEL-${CELL1_INFO.ID}/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-${CELL1_INFO.ID}/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-${CELL1_INFO.ID}/CAREL-2:scellPrio=1
...    LNCEL-${CELL1_INFO.ID}/CAREL-3:lcrId=${CELL4_INFO.ID}
...    LNCEL-${CELL1_INFO.ID}/CAREL-3:lnBtsId=1
...    LNCEL-${CELL1_INFO.ID}/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-${CELL1_INFO.ID}/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL-${CELL1_INFO.ID}/CAREL-3:scellPrio=1
...    LNBTS-${BTS_INFO.ID}/LNCEL-${CELL1_INFO.ID}/LNCEL_FDD-0:earfcnDL=700
...    LNBTS-${BTS_INFO.ID}/LNCEL-${CELL2_INFO.ID}/LNCEL_FDD-0:earfcnDL=900
...    LNBTS-${BTS_INFO.ID}/LNCEL-${CELL3_INFO.ID}/LNCEL_TDD-0:earfcn=55490
...    LNBTS-${BTS_INFO.ID}/LNCEL-${CELL4_INFO.ID}/LNCEL_TDD-0:earfcn=55290
...    LNCEL-${CELL1_INFO.ID}/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-${CELL1_INFO.ID}/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-${CELL2_INFO.ID}/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-${CELL2_INFO.ID}/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-${CELL3_INFO.ID}/LNCEL_TDD-0:chBw=10 MHz
...    LNCEL-${CELL4_INFO.ID}/LNCEL_TDD-0:chBw=10 MHz
@{CBRS_PARAM}
...    LNBTS-${BTS_INFO.ID}/CBSD-1:supportedSpectrumV2=1073741823
...    LNBTS-${BTS_INFO.ID}/CBSD-1:antennaGain=8
...    LNCEL-${CELL3_INFO.ID}/CBSDCEL-0:maxGrantPwrRed=10
...    LNCEL-${CELL3_INFO.ID}/CBSDCEL-0:desiredPmax=320
...    LNCEL-${CELL4_INFO.ID}/CBSDCEL-0:maxGrantPwrRed=10
...    LNCEL-${CELL4_INFO.ID}/CBSDCEL-0:desiredPmax=320
@{FIX_RELATION_ERRORS}
...    LNBTS:actFlexScellSelect=true
...    LNCEL:caPoolId=1
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actFlowCtrlEnh=false
@{CBRS_MODIFY_EARFCN}
#...    LNCEL-${CELL3_INFO.ID}/LNCEL_TDD-0:earfcn=${CELL3_NEW_EARFCN}
...    LNCEL-${CELL3_INFO.ID}/LNCEL_TDD-0:chBw=20 MHz
@{CBRS_MODIFYBACK_EARFCN}
#...    LNCEL-${CELL3_INFO.ID}/LNCEL_TDD-0:earfcn=${CELL3_ORIGIN_EARFCN}
...    LNCEL-${CELL3_INFO.ID}/LNCEL_TDD-0:chBw=10 MHz
${UE_CAP_2A_2A_48A_48A_}
...    SEPARATOR=
...    CDB80281077C102013FFFFFFFC00801C1E7FFFFFFFD52A56E28507040000410003820000378002C1000010400DE000B0400004100378083C10
...    00010400DE006F000982000020801BC00DE006F000502010080402013FFFFFFFC514478C90
${CELL3_ORIGIN_EARFCN}    55490
${CELL3_NEW_EARFCN}    55540
${EXPECTED_TP_EACH_SCELL}    30000
@{SCELL_LIST}
...    0
...    1
...    2
...    3
${DELTA_RATE}     0.1
@{LTE5267-A-c-01_Parameters_For_Bad_Channel_Quality}
...    ${BTS_INFO.LNBTS}:actAdvScellMeas=true
...    ${CELL3_INFO.LNCELL}:scellNotDetectableThr=26
...    ${CELL3_INFO.LNCELL}:scellBadChQualThr=27
...    ${CELL3_INFO.LNCELL}:scellGoodChQualThr=27
...    ${BTS_INFO.LNBTS}:multScellReleaseTimer=30
@{LTE5267-A-c-01_RECOVER_ENV}
...    @{CBRS_MODIFYBACK_EARFCN}
...    @{LTE5267-A-c-01_RESTORE_LTE1541_PARAM}
@{LTE5267-A-c-01_RESTORE_LTE1541_PARAM}
...    ${BTS_INFO.LNBTS}:actAdvScellMeas=false
...    ${CELL3_INFO.LNCELL}:scellNotDetectableThr=4
...    ${CELL3_INFO.LNCELL}:scellBadChQualThr=6
...    ${CELL3_INFO.LNCELL}:scellGoodChQualThr=8
...    ${BTS_INFO.LNBTS}:multScellReleaseTimer=0
...    ${CELL2_INFO.LNCELL}:scellNotDetectableThr=4
...    ${CELL2_INFO.LNCELL}:scellBadChQualThr=6
...    ${CELL2_INFO.LNCELL}:scellGoodChQualThr=8
...    ${CELL4_INFO.LNCELL}:scellNotDetectableThr=4
...    ${CELL4_INFO.LNCELL}:scellBadChQualThr=6
...    ${CELL4_INFO.LNCELL}:scellGoodChQualThr=8
@{LTE5267-A-d-03_RECONF_A3_SCF}
...    LNBTS-${BTS_INFO.ID}:actA3ScellSelect=true
@{LTE5267-A-d-03_CBRS_MODIFY_CHBW}
...    LNCEL-${CELL3_INFO.ID}/LNCEL_TDD-0:chBw=${LTE5267-A-d-03_CELL3_NEW_CHBW}
#...    LNCEL-${CELL3_INFO.ID}/LNCEL_TDD-0:earfcn=${LTE5267-A-d-03_CELL3_NEW_EARFCN}
${UE_CAP_NO_MEASUREMENT_GAP_2A_2A_48A_48A_}
...    SEPARATOR=
...    CDB80281077C102013FFFFFFFC00801C1E7FFFFFFFD52A56E28507040000410003820000378002C1000010400DE000B0400004100378083C10
...    00010400DE006F000982000020801BC00DE006F000502010080402013FFFFFFFC514478C90
${LTE5267-A-d-03_CELL3_NEW_EARFCN}    55540
${LTE5267-A-d-03_CELL3_NEW_EARFCN_1}    55440
${LTE5267-A-d-03_CELL3_NEW_CHBW}    20 MHz
@{LTE5267-A-d-03_RECOVER_ENV}
...    LNBTS-${BTS_INFO.ID}:actA3ScellSelect=false
#...    LNCEL-${CELL3_INFO.ID}/LNCEL_TDD-0:earfcn=55290
...    LNCEL-${CELL3_INFO.ID}/LNCEL_TDD-0:chBw=10 MHz
@{LTE5267_C_a_SCF}
...    @{LTE5267_C_a_Cell1_Param}
...    @{LTE5267_C_a_Cell2_Param}
@{LTE5267_C_a_Cell1_Param}
...    delete:LNCEL-${CELL1_INFO.ID}/CAREL-2
...    delete:LNCEL-${CELL1_INFO.ID}/CAREL-3
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:lcrId=${CELL3_INFO.ID}
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:lnBtsId=1
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:scellPrio=1
...    delete:LNCEL-${CELL1_INFO.ID}/CAREL-1:beamformingInScellAllowed
@{LTE5267_C_a_Cell2_Param}
...    LNCEL-${CELL2_INFO.ID}:scellFastSchedulingSelect=normal
...    LNCEL-${CELL2_INFO.ID}:actScellConfigForHiDemand=false
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
@{LTE5267_C_a_RECOVER_ENV}
...    delete:LNCEL-${CELL2_INFO.ID}/CAREL-1
...    delete:LNCEL-${CELL2_INFO.ID}/CAREL-2
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:lcrId=${CELL2_INFO.ID}
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:lnBtsId=1
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-${CELL1_INFO.ID}/CAREL-1:scellPrio=1
...    delete:LNCEL-${CELL1_INFO.ID}/CAREL-1:beamformingInScellAllowed
...    LNCEL-${CELL1_INFO.ID}/CAREL-2:lcrId=${CELL3_INFO.ID}
...    LNCEL-${CELL1_INFO.ID}/CAREL-2:lnBtsId=1
...    LNCEL-${CELL1_INFO.ID}/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-${CELL1_INFO.ID}/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-${CELL1_INFO.ID}/CAREL-2:scellPrio=1
...    delete:LNCEL-${CELL1_INFO.ID}/CAREL-2:beamformingInScellAllowed
...    LNCEL-${CELL1_INFO.ID}/CAREL-3:lcrId=${CELL4_INFO.ID}
...    LNCEL-${CELL1_INFO.ID}/CAREL-3:lnBtsId=1
...    LNCEL-${CELL1_INFO.ID}/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-${CELL1_INFO.ID}/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL-${CELL1_INFO.ID}/CAREL-3:scellPrio=1
...    delete:LNCEL-${CELL1_INFO.ID}/CAREL-3:beamformingInScellAllowed
...    @{CBRS_MODIFYBACK_EARFCN}
@{PARAMS_IN_SWCONFIG}
...    0x45000B=1
${UE_CAP_2A_48A_48A}    CDB80281077C102013FFFFFFFC00801C1E7FFFFFFFD52A56E281070400006F000582000037801BC000408087FFFFFFF8A288F192
${UE_ID}          1,101,102
${UE101}          101
${UE102}          102
#### LTE1541 parameter refer to case:LTE1541_B_c_001_Deconfiguration_of_scell_due_to_non_detection_3CC_to_2CC
${BTS_INFO.ID}    1
${CELL1_INFO.ID}    1
${CELL2_INFO.ID}    2
${CELL3_INFO.ID}    3
${CELL4_INFO.ID}    4
${BTS_INFO.LNBTS}    LNBTS-1
${CELL3_INFO.LNCELL}    LNCELL-3
${CELL2_INFO.LNCELL}    LNCELL-2
${CELL4_INFO.LNCELL}    LNCELL-4

*** Test Cases ***
LTE5267-A_d_03-reconfigure A3 measurement for candidate CBSD SCell after bandwidth and frequency change
    [Documentation]    LTE5267 cross with LTE2276
    ...    1. UE attach at cell1
    ...    2. Modify CBRS frequency F3 to F3m, and bandwith from 10M to 20M
    ...    3. UE send cell2 A3 mesurement report
    ...    4. Send traffic and make UE L2 buffer full
    ...    5. UE send cell3 A3 measurement report
    ...    6. UE send cell4 A3 measurement report
    ...    7. Checking UE CA combination and Uu message
    ...    8. UE detach
    [Tags]
    Do Delta Commission and Wait for Cell Start Up    ${LTE5267-A-d-03_RECONF_A3_SCF}
    Cus UE attach to eNB1    ue_eutra_capabilities=${UE_CAP_NO_MEASUREMENT_GAP_2A_2A_48A_48A_}
    Do Delta Commission and Wait for Cell Start Up    ${LTE5267-A-d-03_CBRS_MODIFY_CHBW}
    Single UE Report Measurement For Candidate Scell    ${UE1}    ${CELL2_INFO.ID}    type=A3    measid=5    nrsrp=50    nrsrq=24
    ...    allowaddormod=False    sleeptime=10
    Send Traffic and Cell2 is Configured as Scell
    UE Send CBRS Cell A3 Measurement Report to Trigger Scell Configured

*** Keywords ***
Common Suite Setup And Setup Cus Env
    Common Suite Setup
    Start SAS Server
    Setup CUS Env    tl_type=2CELLs_FDD_3CELLs_TDD_2B2_2B48    ue_count=500
    #Debug enter into egate
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc on
    Create Alias
    Set UE CA Capbility

Set UE CA Capbility
    Execute Uex Command    ue_param id=1-10 ue_eutra_capabilities=${UE_CAP_2A_2A_48A_48A_}
    Execute Uex Command    ue_param id=101-110 ue_eutra_capabilities=${UE_CAP_2A_48A_48A_}

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus

Cus UE attach to eNB1
    [Arguments]    ${ueid}=1    ${cellid}=1    ${ue_eutra_capabilities}=${UE_CAP_NO_MEASUREMENT_GAP_2A_2A_48A_48A_}    ${sleeptime}=0
    Execute Uex Command    ue_param id=${ueid} csfb_rat=utran_geran voice_domain_preference=lte_preferred
    Execute Uex Command    ue_param id=${ueid} ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ue_attach id=${ueid} cell=${cellid} selected_plmn=262:03
    sleep    ${sleeptime}

Single UE Report Measurement For Candidate Scell
    [Arguments]    ${ueid}=3001    ${cellid}=${CELL21}    ${scellid}=1    ${type}=A6    ${measid}=3    ${nrsrp}=80
    ...    ${nrsrq}=17    ${allowaddormod}=${True}    ${sleeptime}=2
    ${command_measurement_report_a3}    catenate
    ...    ue_measurement_send id=${ueid} srsrp=75 srsrq=28 phycell_id=${cellid}
    ...    nrsrp=${nrsrp} nrsrq=${nrsrq} event=${type} meas_id_blacklist=1
    Execute Uex Command    ${command_measurement_report_a3}
    sleep    ${sleeptime}

Send Traffic and Cell2 is Configured as Scell
    ${DL_2CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq 900)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 1
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration ( ${DL_2CC_scell_addition} )
    ...    alias=LTE5267-A-b_001_flow1    overall_timeout=30
    Execute Uex Command    trf_data_start ue=${UE1} dir=dl protocol=udp Mbps=100 trf_id=1 stats=true
    Flow Occurred As Expected    alias=LTE5267-A-b_001_flow1

UE Send CBRS Cell A3 Measurement Report to Trigger Scell Configured
    ${DL_3CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2 and cellIdentification-r10 contains (
    ...    physCellId-r10 eq 3) and
    ...    sCellIndex-r10 ne 3
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration ( ${DL_3CC_scell_addition} )
    ...    alias=LTE5267-A-b_001_flow2    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${UE1} event=A3 srsrp=75 srsrq=28 phycell_id=3 nrsrp=50 nrsrq=24
    Flow Occurred As Expected    alias=LTE5267-A-b_001_flow2
    ${DL_4CC_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2,
    ...    sCellIndex-r10 eq 3 and cellIdentification-r10 contains (physCellId-r10 eq 4)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 3
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration ( ${DL_4CC_scell_addition} )
    ...    alias=LTE5267-A-b_001_flow3    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${UE1} event=A3 srsrp=75 srsrq=28 phycell_id=4 nrsrp=50 nrsrq=24
    Flow Occurred As Expected    alias=LTE5267-A-b_001_flow3

Do Delta Commission and Wait for Cell Start Up
    [Arguments]    ${delta_commission_file}
    Delta Commission Parameters    ${delta_commission_file}
    Cells Should Be OnAir    timeout=480
