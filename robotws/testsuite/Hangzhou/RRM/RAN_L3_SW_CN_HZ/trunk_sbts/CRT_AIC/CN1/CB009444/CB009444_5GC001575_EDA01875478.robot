*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_Aic    master_vDU    CRT
...    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    owner-jianfen.shen    release-5G23R3    team-DevHZ5_SG02    vDUCNF00

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot
#Resource    /home/ute/.pyenv/versions/3.9.14/envs/test_repo/lib/python3.9/site-packages/taf/rfrl/cbts/robot/vdu/vdu_cm.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/1du/2cell
${SA_UE_ID_1}    1
${NSA_UE_ID_1}    31
${SA_UE_ID_2}    2
${NSA_UE_ID_2}    32
${SA_UE_ID_3}    3
${NSA_UE_ID_3}    33
${SA_UE_ID_4}    4
${NSA_UE_ID_4}    34
@{PARAMS_IN_SCF_CU}
@{PARAMS_IN_SCF_DU1}

@{PARAMS_DELETE_CELL1}
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8
...    delete:NRCELL-1
...    delete:NRCELLGRP-1
...    NRBTS/NRDU-1:refNrCellGroup=2

@{PARAMS_ADD_CELL1}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1:vlanId=${tl.gnbs[${0}].dus[${0}].fhuc_vlans[0]}
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-1/PHYANT-1
...    NRCELL-1:actAdaptiveSr=false
...    NRCELL-1:actCceSplit=false
...    NRCELL-1:actCsiMeasEthFlowControl=PastTputBased
...    NRCELL-1:actEnhancedVoNR=false
...    NRCELL-1:actGBRAdmissionControl=off
...    NRCELL-1:actPrachMultiplexing=false
...    NRCELL-1:actVoNR=false
...    NRCELL-1:configuredEpsTac=4580
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-1:dlMuMaxNumPairedUEs=8
...    NRCELL-1:drxWactDlEnabled=false
...    NRCELL-1:drxWactUlEnabled=false
...    NRCELL-1:enDcSyncStatus=synchronous
...    NRCELL-1:gscnOrSsPbchArfcn=7880
...    NRCELL-1:iniNumSCellsToActivate=0
...    NRCELL-1:mcsIndexForArtificialLoad=0
...    NRCELL-1:msg1FrequencyStart=4
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-1:nrarfcn=636666
...    NRCELL-1:nrofHARQProcessesForPDSCH=16
...    NRCELL-1:numOfPagingFrames=halfT
...    NRCELL-1:pagingOffset=1
...    NRCELL-1:physCellId=50
...    NRCELL-1:prachConfigurationIndex=93
...    NRCELL-1:pucchDataDtxNumOfSamples=30
...    NRCELL-1:puschDataDtxNumOfSamples=30
...    NRCELL-1:raResponseWindow=sl20
...    NRCELL-1:reqMinNumPuschPrb=19
...    NRCELL-1:rloConsecDtxThreshold=2
...    NRCELL-1:rloDtxRatioThreshold=50
...    NRCELL-1:rloPathLossThreshold=130
...    NRCELL-1:rsrpThresholdSSB=37
...    NRCELL-1:ssPbchBlockPower=10
...    NRCELL-1:targetTotalLoad=0
...    NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-1
...    NRCELL-1:ueConnectionEstablishmentMode=useDedicatedBwp
...    NRCELL-1:ulDMRSAdditionalPosition=One additional DMRS
...    NRCELL-1:ullaIniMcs=1
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-1:cellBwpList:actPdcchCceFragmentControl=false|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-0
...    NRCELL-1:cellBwpList:cellBwpId=1|bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-1
...    NRCELL-1:csirsBeamMgmt:csirsBmMgmtDensity=density3
...    NRCELL-1:csirsForTracking:csirsTrackingPeriod=80ms
...    NRCELL-1:dlDataDmrsFdm:actDlDataDmrsFdm=false
...    NRCELL-1:dlPtrs:dlPtrsFreqDensityThresNrb0=278
...    NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-1:dtxOptimizedScheduler:caSupportEnabled=false
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRCELL-1:tddFrameStructure:frameStructureType=tdLte
...    NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols
...    NRCELL-1:tddFrameStructure:lteToNrFrameShift=3ms
...    NRCELL-1:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL-1:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-1:ulDataDmrsFdm:actUlDataDmrsFdm=false
...    NRCELL-1:ulPowerControlCommon:p0NominalPucch=-90
...    NRCELL-1:ulPowerControlCommon:p0NominalPusch=-96
...    NRCELL-1:ulPowerControlCommon:p0NominalSrs=-80
...    NRCELL-1:ulPtrs:actUlPtrs=false
...    NRCELL-1:ulPtrs:ulPtrsFreqDensityThresNrb0=278
...    NRCELL-1:ulPtrsForTransPrecoding:ulPtrsSampleDensityThresNrb0=1
...    NRCELL-1:pMax=260                        
...    NRCELL-1:ssbScs=30 KHz 
...    NRCELL-1:timingAdvanceOffset=n25600
...    NRCELL-1:nrCellIdentity=16385
...    NRCELLGRP-1:scs=30 KHz
...    NRCELLGRP-1:nackFloodControlF1:dataFlowResumeThrFR1=5
...    NRCELLGRP-1:nrCellList=1
...    NRBTS/NRDU-1:refNrCellGroup=1,2

*** Test Cases ***
CB009444-ET_5GC001575_EDA01875478_Verify_Cloud_gNB_TDD_cmWave_delete_then_add_cell_is_successful
    [Documentation]
    ...    1. The purpose of this test case is to check du cell delete and add scenarios:
    ...    01875478: [Verizon Cloud NPI 5G20B_10.1100.1105 CTX]Fault 7104-Matching ServedCell not found over F1-C
    ...    NOT cleared on CU1330015 after DUs rehome from CU1330015 to CU1330016
    ...    2. Test Case Steps:
    ...       a. UEs register to cell1 and cell2
    ...       b. Lock Cell1 on CU
    ...       c. Delete Cell1 on DU
    ...       d. Unlock Cell1 on CU, new UE register to cell2
    ...       e. Add Cell1 on DU, new UE register to cell1
    ...    3. Expected Results:
    ...       a: UE1,11 register on CELL1. UE2,12 register on Cell2
    ...       b: Lock Cell1 on CU successfully, UE1,11 detached, UE2,12 active
    ...       c: Cell delete successfully on DU. No '7104-Matching ServedCell not found over F1-C' alarm raised on CU.
    ...       d: Unlock Cell1 on CU successfully, '7104-Matching ServedCell not found over F1-C' alarm raised on CU.
    ...          new UE register to cell2 successfully.
    ...       e: Cell add successfully on DU. '7104-Matching ServedCell not found over F1-C' alarm cleared on CU.
    ...          new UE register to cell1 successfully
    [Tags]    QC_
    #Run Keyword And Ignore Error    Delta Commission Parameters Du    ${PARAMS_DELETE_CELL1}
    #Run Keyword And Ignore Error    Delta Commission Parameters Du    ${PARAMS_ADD_CELL1}
    UEs Register To Cell1 And Cell2
    UEs On Cell1 Are Released After Lock Cell1
    Delete Cell1 On DU
    Unlock Cell1 And Register New UEs To Cell2
    Add Cell1 On DU And Register New UEs To Cell1
    Release Ues    ue_type=all

*** Keywords ***
NSA UE Attach and Traffic
    [Arguments]    ${ue_id}=11    ${target_cell}=1    ${cmd_regexp}=UE IS ACTIVE    ${cmd_endc_regexp}=reported successful RA
    Execute Egate Command    ue_attach id=${ue_id}    ${cmd_regexp}
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg    ${cmd_endc_regexp}
    traffic should be ok    ue_id=${ue_id}    type=NSA

SA UE Attach and Traffic
    [Arguments]    ${ue_id}=1    ${target_cell}=1    ${pdu_id}=1    ${gw_id}=1    ${nwslice}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${target_cell}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table
    traffic should be ok    ue_id=${ue_id}    type=SA

UEs Register To Cell1 And Cell2
    SA UE Attach and Traffic    ue_id=${SA_UE_ID_1}    target_cell=1
    NSA UE Attach and Traffic    ue_id=${NSA_UE_ID_1}    target_cell=1
    SA UE Attach and Traffic    ue_id=${SA_UE_ID_2}    target_cell=2
    NSA UE Attach and Traffic    ue_id=${NSA_UE_ID_2}    target_cell=2

UEs On Cell1 Are Released After Lock Cell1
    delta commission parameters cu    NRCELL-1:administrativeState=Locked
    cells should be onair du    cell_id=2
    Execute Egate Command    disp_ue id=${SA_UE_ID_1}    OFF
    Execute Egate Command    disp_ue id=${NSA_UE_ID_1}    ACTIVE    ##NSA UE active on LTE
    Execute Egate Command    disp_ue id=${SA_UE_ID_2}    ACTIVE
    Execute Egate Command    disp_ue id=${NSA_UE_ID_2}    ACTIVE

Delete Cell1 On DU
    delta commission parameters du    ${PARAMS_DELETE_CELL1}
    cells should be onair du    cell_id=2
    Check fault 7104 and alarm 7114 non-exist

Unlock Cell1 And Register New UEs To Cell2
    delta commission parameters cu    NRCELL-1:administrativeState=Unlocked
    cells should be onair du    cell_id=2
    Check fault 7104 and alarm 7114 exist
    SA UE Attach and Traffic    ue_id=${SA_UE_ID_3}    target_cell=2
    NSA UE Attach and Traffic    ue_id=${NSA_UE_ID_3}    target_cell=2

Add Cell1 On DU And Register New UEs To Cell1
    delta commission parameters du    ${PARAMS_ADD_CELL1}

    cells should be onair du    timeout=300
    Check fault 7104 and alarm 7114 non-exist
    SA UE Attach and Traffic    ue_id=${SA_UE_ID_4}    target_cell=1
    NSA UE Attach and Traffic    ue_id=${NSA_UE_ID_4}    target_cell=1

Check fault 7104 and alarm 7114 exist
    [Arguments]    ${fault_id}=7104    ${alarm_id}=7114    ${severity}=Critical
    ...    ${alarm_name}=CELL SERVICE PROBLEM
    ...    ${fault_name}=Matching ServedCell not found over F1-C
    ...    ${alarming_object}=NRCELL-1
    ${fault7104_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object}
    Fm Fault Should Be Raised Cu Aic    ${fault7104_alarm7114}

Check fault 7104 and alarm 7114 non-exist
    [Arguments]    ${fault_id}=7104    ${alarm_id}=7114    ${severity}=Critical
    ...    ${alarm_name}=CELL SERVICE PROBLEM
    ...    ${fault_name}=Matching ServedCell not found over F1-C
    ...    ${alarming_object}=NRCELL-1
    ${fault7104_alarm7114}    Create List    fault_id=${fault_id}    alarm_id=${alarm_id}    severity=${severity}
    ...    alarm_name=${alarm_name}    fault_name=${fault_name}    alarming_object=${alarming_object}
    Fm Fault Should Be Cleared Cu Aic    ${fault7104_alarm7114}