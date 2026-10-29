*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_2MAPO_2CUS
...               release-SBTS24R2    team-CN3ET    owner-lixia.zhou
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{x2_link_with_ENB2}
...    @{LTE5382}
...    @{CB010763}

@{PARAMS_IN_SCF_ENB2}
...    @{LTE5382}
...    @{CB010763}

@{x2_link_with_ENB2}
...    LNBTS/LNADJ-2:adjEnbId=2
...    LNBTS/LNADJ-2:cPlaneIpAddr=10.0.1.4
...    LNBTS/LNADJ-2:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJ-2:rlfBasedRCRsupported=false
...    LNBTS/LNADJ-2:plmnId:mcc=262
...    LNBTS/LNADJ-2:plmnId:mnc=3
...    LNBTS/LNADJ-2:plmnId:mncLength=2

@{CB010763}
...    LNCEL-1/CATMCEL-0:actHighHarqInSlimCarrierCatM=true
...    LNCEL-1/CATMCEL-0:actMultiHarqCatM=true
...    LNCEL-1/CATMCEL-0:dlsUsePartPrbCatM=sf0 and sf5 used as invalid subframe
...    LNCEL-2/CATMCEL-0:actHighHarqInSlimCarrierCatM=true
...    LNCEL-2/CATMCEL-0:actMultiHarqCatM=true
...    LNCEL-2/CATMCEL-0:dlsUsePartPrbCatM=sf0 and sf5 used as invalid subframe
...    LNCEL-3/CATMCEL-0:actHighHarqInSlimCarrierCatM=false
...    LNCEL:nbIoTMode=disabled
...    LNCEL/SIB-0:sib2xTransmit=false
...    delete:LNCEL-1/LNHOX-1
...    LNCEL:maxCrSibDl=26
...    delete:LNCEL/CDFIM-1:csfbRegParam1xRtt

@{PARAMS_IN_SWCONFIG}
...    ${L2flag}
...    ${TAbsMaxCrLimit}

@{PARAMS_IN_SWCONFIG_ENB2}
...    ${L2flag}
...    ${TAbsMaxCrLimit}

${L2flag}    0x1E0149=0xC0A00000
${TAbsMaxCrLimit}    0xF0071=17

@{LTE5382}
...    LNBTS:integrityPrefL:eia1=0
...    LNBTS:integrityPrefL:eia0=1
...    LNBTS:integrityPrefL:eia3=0
...    LNBTS:integrityPrefL:eia2=0
...    LNBTS:cipherPrefL:eea1=0
...    LNBTS:cipherPrefL:eea0=1
...    LNBTS:cipherPrefL:eea3=0
...    LNBTS:cipherPrefL:eea2=0
...    CATMPR-1:mibRepEnabledCatM=false
...    LNCEL:pdcchAggSib=8
...    LNCEL:actLdPdcch=true
...    LNCEL:adaptPdcchDwellTime=50
...    LNCEL:dlsDciCch=DCI format 1A
...    LNCEL:raPreGrASize=40
...    LNCEL:redBwRbUlConfig:redBwMaxRbUl=25
...    LNCEL:redBwRbUlConfig:redBwMinRbUl=1
...    LNCEL:raSmallMcsUl=2
...    LNCEL/CATMCEL-0:actAmcCatM=Both Downlink and Uplink enabled
...    LNCEL/CATMCEL-0:actDynamicRepMpdcchCatM=true
...    LNCEL/CATMCEL-0:actDynamicRepMpdschCatM=true
...    LNCEL/CATMCEL-0:actDynamicRepMpuschCatM=true
...    LNCEL/CATMCEL-0:actDynamicRepVoLTECatM=true
...    LNCEL/CATMCEL-0:startingCovLevelPagingOptCatM=Coverage Level 0
...    LNCEL/CATMCEL-0:actConvVoiceCatM=true
...    delete:LNBTS/LNCEL/CATMCEL-0:threshServingLowQR9CatM
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0:actCatM=true
...    LNCEL/LNCEL_FDD-0:actDlSlimCarrier=true
...    LNCEL/LNCEL_FDD-0:actSlimCoexCatM=true
...    LNCEL/LNCEL_FDD-0:blankedPucch=4
...    LNCEL/LNCEL_FDD-0:catMProfId=1
...    LNCEL/LNCEL_FDD-0:dlChBw=5 MHz
...    LNCEL/LNCEL_FDD-0:numBlankDlPrbsDown=2
...    LNCEL/LNCEL_FDD-0:numBlankDlPrbsUp=2
...    LNCEL/LNCEL_FDD-0:ulChBw=5 MHz
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=2
...    LNCEL:maxPdcchAgg=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL/SIB-0:siWindowLen=20ms
...    delete:LNCEL/SIB-0:threshServingLowQR9
...    LNCEL/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...    LNCEL/SIB-0:cellSelectionInfoV920:qQualMinR9=-34
...    LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=5 MHz
...    delete:LNCEL/CAREL-1
...    delete:LNCEL/MBSFNCEL-0

@{HO_reestablish_param}
...    @{HO_param}
...    @{Enable_inter_enb_reestablish}

@{HO_reestablish_param_ENB2}
...    @{HO_param_ENB2}
...    @{Enable_inter_enb_reestablish_ENB2}

@{HO_param}
...    LNBTS/CATMPR-1:inactivityTimerCatM=30
...    LNCEL/CATMCEL-0:actIntraFreqHoCatM=true
...    LNBTS/CATMODPR-0:freqLayListCatM=1400
...    LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-2:ecgiLcrId=1
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-3/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-3/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-3/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-3/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-2:ecgiLcrId=2
...    LNCEL-3/LNREL-2:handoverAllowed=allowed
...    LNCEL-3/LNREL-2:removeAllowed=false
...    LNCEL-3/LNREL-3:ecgiPlmnId:mcc=262
...    LNCEL-3/LNREL-3:ecgiPlmnId:mnc=3
...    LNCEL-3/LNREL-3:ecgiPlmnId:mncLength=2
...    LNCEL-3/LNREL-3:ecgiAdjEnbId=2
...    LNCEL-3/LNREL-3:ecgiLcrId=51
...    LNCEL-3/LNREL-3:handoverAllowed=allowed
...    LNCEL-3/LNREL-3:removeAllowed=false

@{HO_param_ENB2}
...    LNBTS/CATMPR-1:inactivityTimerCatM=30
...    LNCEL/CATMCEL-0:actIntraFreqHoCatM=true
...    LNBTS/CATMODPR-0:freqLayListCatM=1400
...    LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=1
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:removeAllowed=false

@{Enable_inter_enb_reestablish}
...    LNADJ-2:rlfBasedRCRsupported=true
...    LNCEL/CATMCEL-0:actRLFbasedRCRCatM=true
...    LNBTS:actRLFbasedRCR=true
...    LNCEL:t301Guard=1990
...    LNBTS:actRLFbasedRCRConfigL1=true
...    LNBTS:actRLFbasedRCREnhanced=true
...    LNBTS:actRLFbasedRCREnhancedIntra=true
...    LNBTS:actRLFbasedRCRTargetCRNTI=true
...    LNBTS:rlfBasedRCRdefault=true

@{Enable_inter_enb_reestablish_ENB2}
...    LNADJ-255:rlfBasedRCRsupported=true
...    LNCEL/CATMCEL-0:actRLFbasedRCRCatM=true
...    LNBTS:actRLFbasedRCR=true
...    LNCEL:t301Guard=1990
...    LNBTS:actRLFbasedRCRConfigL1=true
...    LNBTS:actRLFbasedRCREnhanced=true
...    LNBTS:actRLFbasedRCREnhancedIntra=true
...    LNBTS:actRLFbasedRCRTargetCRNTI=true
...    LNBTS:rlfBasedRCRdefault=true

${ue_eutra_capabilities_catm_harqdelay}    SEPARATOR=
...    D41800C325C1851E044A34A9D9B79A60CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFFFFFFFFFF80100382C00000
...    000004500000000590200424000AB8087214D4180000000A48400002008000

${ue_eutra_capabilities_catm_harqdelay_harqbundling}    SEPARATOR=
...    D41800C325C1851E044A34A9D9B79A60CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFF8CFFFFFFFFFFF80100382C00000
...    000004500000000590200424000AB8087214D4180000000A48400022008000

@{B3_case3_param}
...    LNCEL-1/CATMCEL-0:actHighHarqCatM=8 HARQ
...    LNCEL-1/CATMCEL-0:actHARQBundlingCatM=true
...    LNCEL-1/CATMCEL-0:harqThrForBundlingCatM=8
...    LNCEL-1/CATMCEL-0:dlLADownFactorCatM=1
...    LNCEL-1/CATMCEL-0:dlMcsThrForBundlingCatM=MCS13
...    LNCEL-2/CATMCEL-0:actHighHarqCatM=8 HARQ
...    LNCEL-2/CATMCEL-0:actHARQBundlingCatM=false
...    @{HO_param}

@{B3_case3_param_ENB2}
...    LNCEL-1/CATMCEL-0:actHighHarqCatM=8 HARQ

@{B3_case4_param}
...    LNCEL-1/CATMCEL-0:actHighHarqCatM=8 HARQ
...    LNCEL-1/CATMCEL-0:actHARQBundlingCatM=false
...    LNCEL-2/CATMCEL-0:actHighHarqCatM=8 HARQ
...    LNCEL-2/CATMCEL-0:actHARQBundlingCatM=false

@{B3_case4_param_ENB2}
...    LNCEL-1/CATMCEL-0:actHighHarqCatM=8 HARQ
...    LNCEL-1/CATMCEL-0:actHARQBundlingCatM=false

${schedule_nb}        
...    ce-SchedulingEnhancement-r14 eq 'range2' and mpdcch-Narrowband-r13 eq 2 

${Expect_Msg}    physicalConfigDedicated contains (${schedule_nb}) and (numberPRB-Pairs-v1310 contains ("setup : n6"))

${nb_prbPair}
...    physicalConfigDedicated contains (mpdcch-Narrowband-r13 eq 2) and (numberPRB-Pairs-v1310 contains ("setup : n6"))

${schedule_bundling}        
...    physicalConfigDedicated contains (ce-SchedulingEnhancement-r14 eq 'range2' and ce-HARQ-AckBundling-r14 eq 'on') 

*** Test Cases ***
CB010763-SR-B-B3_ET_03_01_high_harq_configured_correctly_with_ue_handover
    [Documentation]
    ...     == Requirement: ==
    ...     CB010763-SR-B-B3_US3
    ...     High HARQ configuration on UE for Handover with CB010763 enabled.
    ...
    ...     == Precondition: ==
    ...     ENB1
    ...         LNCEL-1/CATMCEL-0:actHighHarqCatM=8 HARQ
    ...         LNCEL-1/CATMCEL-0:actHARQBundlingCatM=true
    ...         LNCEL-2/CATMCEL-0:actHighHarqCatM=8 HARQ
    ...         LNCEL-2/CATMCEL-0:actHARQBundlingCatM=true
    ...         LNCEL-3/CATMCEL-0:actHighHarqCatM=disabled
    ...     ENB2
    ...         LNCEL-1/CATMCEL-0:actHighHarqCatM=8 HARQ
    [Setup]    B3_case3_setup
    [Tags]
    CATM HARQ bundling UE attach    ue_id=1    cell_id=3    enb_id=1
    UE1 HO from cell3 to cell2
    CATM HARQ bundling UE attach    ue_id=2    cell_id=51    enb_id=2
    Inter gnb ho from enb2 cell51 to enb1 cell1    ue_id=2
    CATM HARQ bundling UE attach with msg check    ue_id=3    cell_id=1    enb_id=1
    Create bearer with qci1 for UE3
   
CB010763-SR-B-B3_ET_04_01_high_harq_configured_correctly_with_ue_reestablish
    [Documentation]
    ...     == Requirement: ==
    ...     CB010763-SR-B-B3_US4
    ...     High HARQ configuration on UE for reestablishment with CB010763 enabled.
    ...
    ...     == Precondition: ==
    ...     ENB1
    ...         LNCEL-1/CATMCEL-0:actHighHarqCatM=8 HARQ
    ...         LNCEL-1/CATMCEL-0:actHARQBundlingCatM=false
    ...     ENB2
    ...         LNCEL-1/CATMCEL-0:actHighHarqCatM=8 HARQ
    ...         LNCEL-1/CATMCEL-0:actHARQBundlingCatM=false
    [Setup]    B3_case4_setup
    [Tags]
    CATM HARQ delay UE attach to cell    ue_id=1    cell_id=1
    UE1 trigger reestablish to serving cell1
    UE1 trigger reestablish to cell1 during X2 ho to cell51
    UE1 trigger reestablish to cell51 during X2 ho to cell51

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup 2CUS Env    tl_type=3CELLs_FDD    tl_type_enb2=3CELLs_FDD
    Config Alias
    Set UE parameters

Config Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    create enb alias    ENB_1    enb_id=1    id_type=wts
    create enb alias    ENB_2    enb_id=2    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus
    Create CELL alias    alias=CELL_2    cell_id=2    cell_type=cus
    Create CELL alias    alias=CELL_3    cell_id=3    cell_type=cus
 
Set UE parameters
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Egate Command    ue_enb_param id=1 spid=34

Perform Steps After Onair
    @{lnadj}    Create List    LNADJ-2:cPlaneIpAddr=10.0.1.4    LNADJ-2:x2LinkStatus=available
    Object Should Exist    ${lnadj}    timeout=300
    Delta Commission Parameters    ${HO_reestablish_param}
    Delta Commission Parameters ENB2    ${HO_reestablish_param_ENB2}
    Object Should Exist    LNCEL-1/LNREL-2:ecgiAdjEnbId=2
    Object Should Exist ENB2    LNCEL-1/LNREL-2:ecgiAdjEnbId=1

Inter gnb ho from enb2 cell51 to enb1 cell1
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${Expect_Msg})  
    ...    alias=INTER_HANDOVER    overall_timeout=18
    execute uex command    ue_ho id=${ue_id} enb=1 cell=1
    Flow Occurred As Expected    alias=INTER_HANDOVER

CATM HARQ delay UE attach to cell
    [Arguments]    ${ue_id}=1    ${cell_id}=3
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities_catm_harqdelay} cell=${cell_id}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (physicalConfigDedicated contains (ce-SchedulingEnhancement-r14 eq 'range2') ) 
    ...    alias=SCH_RANG2    overall_timeout=18
    ${ret1}=    Execute Uex Command    ${V_1}
    Flow Occurred As Expected    alias=SCH_RANG2
   
CATM HARQ bundling UE attach with msg check
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${enb_id}=1
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities_catm_harqdelay_harqbundling} enb=${enb_id} cell=${cell_id}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${schedule_bundling}) 
    ...    alias=SCH_RANG2    overall_timeout=18
    ${ret1}=    Execute Uex Command    ${V_1}
    Flow Occurred As Expected    alias=SCH_RANG2

CATM HARQ bundling UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${enb_id}=1
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities_catm_harqdelay_harqbundling} enb=${enb_id} cell=${cell_id}
    ${ret1}=    Execute Uex Command    ${V_1}
    
UE1 HO from cell3 to cell2
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${Expect_Msg}) 
    ...    alias=HANDOVER    overall_timeout=18
    Execute Uex Command    ue_ho id=1 enb=1 cell=2
    Flow Occurred As Expected    alias=HANDOVER

UE1 trigger reestablish to serving cell1
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReestablishment (${Expect_Msg}) 
    ...    alias=REESTABLISH    overall_timeout=18
    Execute Uex Command    ue_rrc_reestablish id=1 cause=otherFailure 
    Flow Occurred As Expected    alias=REESTABLISH

UE1 trigger reestablish to cell1 during X2 ho to cell51
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReestablishment (${Expect_Msg}) 
    ...    alias=REESTABLISH    overall_timeout=18
    Execute Uex Command    ue_ho id=1 enb=2 cell=51 fail=src phase=T304_expiry
    Flow Occurred As Expected    alias=REESTABLISH

UE1 trigger reestablish to cell51 during X2 ho to cell51
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${nb_prbPair}) 
    ...    alias=HORequest    overall_timeout=18
    Execute Uex Command    ue_ho id=1 enb=2 cell=51 fail=dest phase=T304_expiry
    Flow Occurred As Expected    alias=HORequest

Create bearer with qci1 for UE3
   Expect message flow
    ...    UE_3:RRC_RRCConnectionReconfiguration (${schedule_bundling}) 
    ...    alias=BEARER    overall_timeout=18
    Execute Uex Command    bearer_add ue=3 qci=1 mbr_ul=26 mbr_dl=26 gbr_dl=26 gbr_ul=26
    Flow Occurred As Expected    alias=BEARER

B3_case3_setup
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${B3_case3_param}
    Delta Commission Parameters ENB2    ${B3_case3_param_ENB2}

B3_case4_setup
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${B3_case4_param}
    Delta Commission Parameters ENB2    ${B3_case4_param_ENB2}