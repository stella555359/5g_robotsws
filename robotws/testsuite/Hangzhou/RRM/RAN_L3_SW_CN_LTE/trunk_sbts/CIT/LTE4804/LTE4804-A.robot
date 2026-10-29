*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    owner-yili.chen    team-DEVHZ5_SG6    release-SBTS20B
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{LTE4575}
...    @{modulation}
...    @{pcellswap}
...    @{LTE4804}
...    @{LTE4549}
...    @{LTE5003}
...    @{fix_case_relation_err}
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1600
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreqHpue=2
...    LNCEL-1/LNHOIF-1:threshold3InterFreqHpue=26
...    LNCEL-1/LNHOIF-1:threshold3aInterFreqHpue=28
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreqQci1=4
...    LNCEL-1/LNHOIF-1:threshold3InterFreqQci1=25
...    LNCEL-1/LNHOIF-1:threshold3aInterFreqQci1=27
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL-1/LNHOIF-1:threshold3InterFreq=24
...    LNCEL-1/LNHOIF-1:threshold3aInterFreq=26
@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:maxNumUeDl=7
...    LNCEL/LNCEL_FDD-0:maxNumUeUl=7
...    LNCEL:caPoolId=1
...    LNCEL:maxNumScells=2
...    LNBTS-1:actFlexScellSelect=true
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=2870
...    LNCEL:actFlowCtrlEnh=false
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.31
...    delete:LNBTS-1/LNADJ-255
...    LNCEL-1/CAREL-1:scellPrio=3
...    delete:LNCEL-1/CAREL-2:beamformingInScellAllowed
...    delete:LNCEL-3/CAREL-1:beamformingInScellAllowed
...    delete:LNCEL-3/CAREL-2:beamformingInScellAllowed
...    LNBTS-1:actFlexCaMgmt=true
...    LNCEL:actCaArchEnhImp=off
...    LNCEL-1:actScellConfigForHiDemand=false
...    LNCEL-3:actScellConfigForHiDemand=false
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=10
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=3070
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=21070
...    LNCEL-3/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-4/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-4/LNCEL_FDD-0:ulChBw=10 MHz
...    LNBTS-1/CADPR-0:maxNumMimoLayerFdd=12
@{x2link}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-2/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-3/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-4/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-4/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-4/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-4/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-4/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-4/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=8000
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNCEL-3:defaultLnRelGnbCellId=1
...    LNCEL-2:defaultLnRelGnbCellId=1
...    LNCEL-4:defaultLnRelGnbCellId=1
@{LTE4193}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...    ${EMPTY}
...    LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:actB1NrBeamMeas=false|lcrId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=633440
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNCEL-4/LNCEL_FDD-0:actAutoPucchAlloc=true
@{LTE4575}
...    LNBTS:actCAggrLteNrDualConnectivity=blind_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
@{modulation}
...    LNCEL:actModulationSchemeDl=64QAM
...    LNCEL:actLdPdcch=true
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=3
...    LNCEL:adaptPdcchDwellTime=0
...    LNCEL:mbrSelector=ueCapability
${ue_eutra_capabilities_01}
...    SEPARATOR=
...    DD980030830008081705C177E0DD89A0028372F97E0DD89A5E190117BF06EC4D5918210C2084308210C1086084104018210C00C00C10060803
...    0421801801108200168FAA8C280C1C208020A30410B08200828C1051820858410041420828C1041C208020A1041640B82E0B82E0B82E0B82E0
...    B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0BBF140000
...    66C843C3C3C5C23F8B90F0F0F0F0F0F0F0F0F0F0E21E1E1E1C000117E0C00002040411019A000F9C78000810182030385898D8E0EA0FDFF12D
...    6980642FF37A80018036C9000020000104B8E03000010080309826850F00DFF0000028000001840000
${ue_nr_capabilities}    CE00000001C8F5C0302800001939980000CC00100002600001349880000018060010000001
${ue_eutra_nr_capabilities_01}
...    SEPARATOR=
...    C10060B71B02004040C180389A0000000FD00000000081B8981002060E2680000103F400000000206E360400818103071340000101FA000000
...    0010371302004081C4D00000607E80000000040DC4C080103070080000201FA000000001020100100600901360010083000080400020100008
...    04040080110000402000100808010023000080400020100008040400801100004020001008080100220000804000201010020040
@{pcellswap}
...    LNBTS:actPcellSwap=true
...    LNBTS:actIfHo=enabled
...    LNCEL-1:pcellSwapConfig:numCaUeThreshold=5|puschLoadIndexThr=0.01
...    LNCEL:loadSettings:cellCapClass=100
...    LNCEL:loadSettings:mlbEicicOperMode=allUes
...    LNCEL:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL:loadSettings:targetLoadGbrDl=50
...    LNCEL:loadSettings:targetLoadNonGbrDl=75
...    LNCEL:loadSettings:targetLoadPdcch=90
...    LNCEL:loadSettings:ulCacIgnore=false
...    LNCEL:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL:loadSettings:ulStaticCac=100
...    LNCEL-2:pcellSwapConfig:numCaUeThreshold=10|puschLoadIndexThr=10
...    LNCEL-3:pcellSwapConfig:numCaUeThreshold=10|puschLoadIndexThr=10
...    LNCEL-3/CAREL-1:lcrId=1
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-3/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-3/CAREL-1:scellPrio=3
...    LNCEL-3/CAREL-2:lcrId=2
...    LNCEL-3/CAREL-2:lnBtsId=1
...    LNCEL-3/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-3/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-3/CAREL-2:scellPrio=3
...    LNCEL-3:scellFastSchedulingSelect=normal
...    LNCEL-3:dlCaMinPcellCqi=0
...    LNCEL-3:dlCaMinPcellCqiQci1=0
...    LNCEL-3:ulCaMinPcellSinr=0
...    LNCEL-3:ulCaMinPcellSinrQci1=0
#@{PARAMS_IN_SWCONFIG}
#...  0x00130060 = 1
#ENDC SETUP
@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference
@{PARAMS_IN_EMIL}
...    0x2381
...    0x2382
...    0x74EB
...    0x74F2
...    0x74F3
...    0x74F4
...    0x2495
...    0x7560
...    0x7561
...    0x7562
...    0x7563
...    0x759C
...    0x759D
...    0x75E7
...    0x75DC
...    0x75DD
...    0x75DE
...    0x75DF
...    0x75E8
...    0x7539
...    0x753A
@{LTE4804}
...    LNBTS:actRCREnDc=RCR-servingCell
@{LTE5003}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNCEL:actFlowCtrlEnh=true
@{disable_LTE5003}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS:actInterFreqRstdMeasSupp=false
...    LNBTS:actRCREnDc=RCR-servingCell
...    LNCEL:actFlowCtrlEnh=true
@{disable LTE4804}
...    LNBTS:actRCREnDc=disabled
@{Enable RSTD and disable LTE5003}
...    LNBTS:actInterFreqRstdMeasSupp=true
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNCEL:actFlowCtrlEnh=false
@{fix_case_relation_err}
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled
...    LNCEL-1:eTputFilterConfig=51
...    LNCEL-1:eTputInitMcs=20
...    LNCEL-2:eTputFilterConfig=51
...    LNCEL-2:eTputInitMcs=20
...    LNCEL-3:eTputFilterConfig=51
...    LNCEL-3:eTputInitMcs=20
...    LNCEL-4:eTputFilterConfig=51
...    LNCEL-4:eTputInitMcs=20
...    delete:LNCEL-1/MBSFNCEL-0
#joy.dong@nokia-sbell.com insisted \ to disable LTE5003

*** Test Cases ***
LTE4804-A-a-b-D-b_ET_01_01_RRC Re-Establishment to Serving Cell with SCG Split bearer with dynamic ENDC
    [Tags]
    OnlineParamChange    ${disable_LTE5003}
    UE attach to cell1 and trigger ENDC    ue_id=1
    Trigger RRC Reestablishment with gap    ue_id=1
    OnlineParamChange    ${Enable RSTD and disable LTE5003}
    UE attach to cell1 and trigger ENDC without gap    ue_id=3
    Trigger RRC Reestablishment without gap    ue_id=3
    OnlineParamChange    ${disable LTE4804}
    UE attach to cell1 and trigger ENDC    ue_id=2
    Trigger RRC Reestablishment but failed    ue_id=2

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Execute Egate Command    ue_cqi_param id=1 set=1 scell=0-7 ignore_codebook_subset_restriction=on
    Execute Egate Command    ue_cqi_param id=1 set=2 scell=0-7 ignore_codebook_subset_restriction=on
    Set ue parameters before ENDC setup

Set ue parameters before ENDC setup
    Execute Egate Command    ue_param id=1-3 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Egate Command    ue_param id=1-3 nr_supported_bands=78
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=1:1
    Execute Egate Command    ue_enb_param id=1-3 ue_config_release_r9=rel15
    
Modify Yaml    
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...    gnb_id: '0x00007'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.11
    ...    x2_peers: none
    ...    cells:
    ...    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '633408:633408',
    ...    tdd_cell: yes}
    
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1: 10.0.1.3
    ...    cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1400:19400', bw: 20}
    ...        - {id: 22, technology: lte, tac: 33, pci: '3:1', earfcn: '5920:23920', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '3:2', earfcn: '8770:26770', bw: 20}
    Update Yaml    UEs/UE_sets/1    release: 15

UE attach to cell1 and trigger ENDC
    [Arguments]    ${ue_id}
    ${V_1}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_01}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities_01} cell=1
    Execute Uex Command    ${V_1}
    Add MCG bearer    ue_id=${ue_id}
    Start DL Data to trigger 3CC    ue_id=${ue_id}
    Trigger ENDC setup    ue_id=${ue_id}

Add MCG bearer
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=bearer_add    overall_timeout=10
    Execute Uex Command    bearer_add ue=${ue_id} qci=6
    Flow Occurred As Expected    alias=bearer_add    
    
Start DL Data to trigger 3CC
    [Arguments]    ${ue_id}
    ${3cc}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 2 and physCellId-r10 is present)
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${3cc})
    ...    alias=ca_flow    overall_timeout=20
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp Mbps=150
    Flow Occurred As Expected    alias=ca_flow
    
Trigger ENDC setup
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=endc_setup    overall_timeout=10    
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B1_NR srsrp=79 phycell_id=1 nrsrp=58
    Flow Occurred As Expected    alias=endc_setup

Trigger RRC Reestablishment with gap
    [Arguments]    ${ue_id}    
    Expect Message Flow
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentRequest
    ...    ENB_1:X2AP_SgNBReleaseRequest
    ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (gapOffset is present)
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=RRE_with_gap    overall_timeout=10
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentReject
    ...    alias=RRE_no_reject    overall_timeout=10
    Execute Uex Command    ue_rrc_reestablish id=${ue_id} cause=otherFailure
    Flow Occurred As Expected    alias=RRE_with_gap
    Flow Not Occurred For Message    alias=RRE_no_reject
    Trigger ENDC setup    ue_id=${ue_id}
    Execute Uex Command    trf_data_stop ue=${ueid} trf_id=1 dir=dl

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE attach to cell1 and trigger ENDC without gap
    [Arguments]    ${ue_id}
    ${V_1}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_01}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities_01} cell=1
    Execute Uex Command    ${V_1}
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (gp0 eq 30)
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=set_measOffset    overall_timeout=10
    Execute Uex Command and Expect Error    ue_mgaps_start id=${ue_id} type=InterFreqRSTD carrierFreq=1600 measOffset=30    ValueError
    Flow Occurred As Expected    alias=set_measOffset
    Add MCG bearer without gap    ue_id=${ue_id}
    Start DL Data to trigger 3CC    ue_id=${ue_id}
    Trigger ENDC setup    ue_id=${ue_id}

Trigger RRC Reestablishment without gap
    [Arguments]    ${ue_id}    
    Expect Message Flow
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentRequest
    ...    ENB_1:X2AP_SgNBReleaseRequest
    ...    ENB_1:X2AP_SgNBReleaseRequestAcknowledge
    ...    alias=RRE_without_gap    overall_timeout=10
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (gp0 is present)
    ...    alias=RRE_without_gap_not_expect    overall_timeout=10
    Execute Uex Command    ue_rrc_reestablish id=${ue_id} cause=otherFailure
    Flow Occurred As Expected    alias=RRE_without_gap
    Flow Not Occurred For Message    alias=RRE_without_gap_not_expect
    Trigger ENDC setup    ue_id=${ue_id}

Add MCG bearer without gap
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=bearer_add    overall_timeout=10
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (gapOffset is present)
    ...    alias=no_gap    overall_timeout=10
    Execute Uex Command    bearer_add ue=${ue_id} qci=6
    Flow Occurred As Expected    alias=bearer_add
    Flow Not Occurred For Message    alias=no_gap
    
Trigger RRC Reestablishment but failed
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReestablishmentReject
    ...    alias=RRE_failed    overall_timeout=10
    Execute Uex Command and Expect Error    ue_rrc_reestablish id=${ue_id} cause=otherFailure    sErrRachFail
    Flow Occurred As Expected    alias=RRE_failed 
