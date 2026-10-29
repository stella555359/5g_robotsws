*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4P
...               DEVHZ5_SG1    release-TL19    owner-pei.han
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  @{earfcn}
...  @{x2link}
...  @{LTE4088}
...  @{LTE4193}
...  @{LTE4575}
...  @{Other}
...  @{Closed_Loop_MIMO_4x4}
@{earfcn}
...  LNCEL-1/LNCEL_TDD-0:earfcn=39750
...  LNCEL-2/LNCEL_TDD-0:earfcn=39948
...  LNCEL-3/LNCEL_TDD-0:earfcn=40146
@{x2link}
...  LNBTS/LNADJGNB-1:administrativeState=unlocked
...  LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...  LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...  LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...  LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...  LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...  LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...  LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
@{LTE4088}
...  LNBTS:actLteNrDualConnectivity=true
...  LNBTS:tLteNrDualConnectPrep=10000
...  LNCEL-1:defaultLnRelGnbCellId=1
...  LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
@{LTE4193}
...  LNBTS:actDynTrigLteNrDualConnectivity=true
...  LNCEL-1/LNCEL_TDD-0:actAutoPucchAlloc=true
...  LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeRrHo=10
...  LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeTcHo=15
...  LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumEmergencySessions=10
...  LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrc=10
...  LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrcNoDrb=5
...  LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchSrPeriodUpperLimit=20
...  LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:actLbPucchReg=true
...  LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:lbPucchRPrId=1
...  LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:selectPrachRegion=None
...  LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...  LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...  LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...  LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...  LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...  LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=1
...  LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN630000}
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=78
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...  LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1
...  LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...  LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...  LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...  LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...  LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...  LNBTS/NRDCDPR-0:tProhibitPhr=0sf
@{LTE4575}
...  LNBTS:actCAggrLteNrDualConnectivity=disabled
...  LNBTS:enableBwCombCheck=true
...  LNCEL-1:puschAckOffI=10
...  LNCEL-1:puschRiOffI=3
...  LNCEL-1:puschCqiOffI=8
...  LNCEL-2:puschAckOffI=10
...  LNCEL-2:puschRiOffI=3
...  LNCEL-2:puschCqiOffI=8
...  LNCEL-3:puschAckOffI=10
...  LNCEL-3:puschRiOffI=3
...  LNCEL-3:puschCqiOffI=8
${ue_nr_capabilities}    CE00000001C8F5C0302800001939980000CC00100002600001349880000018060010000001
${ue_eutra_nr_capabilities}    C18040440B2800E26800001022059410713400001010041000180404008010800040202004008400040101002007
${ue_eutra_capabilities_44}
...  SEPARATOR=
...  DD98002A0106030737FFF839BFFFBFE7FF5F44240110C853A1504194E9525C7E7BF8000000000812F05012FC0000000B370030030421801821
...  0C00C00C00841082080304208200C1082080304218210A006006084304218210C1086004B1F551830603A0001240E80004D03A0001040C2000
...  410318001001C2000414608016100020A3041460826E0E6FFFF0737FFF839BFFFC1CDFFFE0E6FFFF0737FFF839BFFFC1CDFFFE0E6FFFF0737F
...  FF839BFFFC1CDFFFE0E6FFFF0737FFF839BFFFC1CDFFFE0E6FFFF0737FFF839BFFFC1CDFFFE0E6FFFF0737FFF839BFFFC1CDFFFE0E6FFFF073
...  7FFF839BFFFC1CDFFFD80B00003F620602C00002387600001B21E3F11F8000073600020208000280A020202020200080200802008020080200
...  8020080200000000A02808280A020A02808280A02020330401F32B4C0320FE6F50003006D9200004000020971C0500002010061304D7816FF9
...  020077FC810820EFF9022041042C18000010220000
@{Other}
...  LNCEL-1:actModulationSchemeDl=64QAM
...  LNCEL-1:actLdPdcch=true
...  LNCEL-1/LNCEL_TDD-0:maxNrSymPdcch=3
...  LNCEL-1:adaptPdcchDwellTime=0
...  LNCEL-1:mbrSelector=ueCapability
@{Closed_Loop_MIMO_4x4}
...  LNCEL-1/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...  LNCEL-1/LNCEL_TDD-0:activatedMimoTM=TM4
...  LNCEL-1/LNCEL_TDD-0:csiRsConfigInfo:csiRsPwrOffset=0
...  LNCEL-1/LNCEL_TDD-0:csiRsConfigInfo:csiRsResourceConf=rsc0
...  LNCEL-1/LNCEL_TDD-0:csiRsConfigInfo:csiRsSubfrConf=14
...  LNCEL-1/LNCEL_TDD-0:csiRsConfigInfo:numOfCsiRsAntennaPorts=4
...  LNCEL-1/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=30
...  LNCEL-1/LNCEL_TDD-0:csiRepSubmode=submode1
@{PARAMS_IN_IPHY_XML}
...  GeneralSettings:SelectAntCnt=4
@{Online_Param_44}
...  LNCEL-1/LNCEL_TDD-0:activatedMimoTM=TM4
${Wait_For_Throughtput_stable_ENDC}    60s
${Wait_For_Throughtput_stable_Start_traffic}    10s

*** Test Cases ***
LTE4575-A-o_ET_44_01_Sprintconfig_MIMO Reconfiguration Triggered by EN-DC Setup for non-CA mode from TM4 four layers to TM4 two layers
    [Tags]    RAN_4G    RAN_4G_TDD    CDRT
    OnlineParamChange    @{Online_Param_44}
    Set ue parameters before attach
    UE attach_44
    Add NR PDCP bearer
    Start traffic
    Trigger B1 report to setup ENDC
    Get Throughput Ave and Verify    Target=75

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    Create UE Alias    UE_1    ue_id=1   id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    # modify UE bearer
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 6, pdn: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...    gnb_id: '0x00007'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.11
    ...    x2_peers: none
    ...    cells:
    ...    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '630000:630000',
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

Set ue parameters before attach
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    ue_param id=1 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Egate Command    ue_param id=1 nr_supported_bands=78
    Execute Egate Command    ue_cqi_param id=1 scell=0-2 rank=4
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms

UE attach_44
    [Arguments]    ${ue_id}=1
	${attach_query}    catenate
    ...    physicalConfigDedicated contains (transmissionMode-r10 eq 'tm4') and
	...    antennaInfoDedicatedPCell-v10i0 contains (maxLayersMIMO-r10 eq 'fourLayers')
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${attach_query})
    ...    alias=attach    overall_timeout=20
    ${V_1}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} \ ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities_44} cell=1
    Execute Uex Command    ${V_1}
	Flow Occurred As Expected    alias=attach
	
Add NR PDCP bearer
    [Arguments]    ${ue_id}=1
	${bearer_query}    catenate
	...    eventB1-NR-r15 is present and
	...    drb-ToAddModList contains (eps-BearerIdentity eq 6) and
	...    measIdToAddModList contains (measId eq 17)
    Expect Message Flow
	...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${bearer_query})
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=bearer    overall_timeout=20
    Execute Uex Command    bearer_add ue=1 qci=6
	Flow Occurred As Expected    alias=bearer

Start traffic
    [Arguments]    ${ue_id}=1
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp Mbps=150
    Execute Uex Command    trf_data_start ue=${ue_id} dir=ul protocol=udp Mbps=150
    Sleep    ${Wait_For_Throughtput_stable_Start_traffic}

Trigger B1 report to setup ENDC
    [Arguments]    ${ue_id}=1
	${endc_query}    catenate
    ...    physicalConfigDedicated contains (transmissionMode-r10 eq 'tm4' and
	...    pmi-RI-Report-r9 eq 'setup' and
	...    and antennaInfoDedicatedPCell-v10i0 is present)
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (physicalConfigDedicated contains (transmissionMode-r10 eq 'tm4'))
	...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=ENDC    overall_timeout=20
	Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (maxLayersMIMO-r10 eq 'twoLayers')
    ...    alias=not_expect  overall_timeout=10
    Execute Uex Command    ue_measurement_send id=1 event=B1_NR phycell_id=1 nrsrp=60
	Flow Occurred As Expected    alias=ENDC
    Flow Not Occurred For Message    alias=not_expect
    Sleep    ${Wait_For_Throughtput_stable_ENDC}

Get Throughput Ave and Verify
    [Arguments]    ${Target}=0    ${ue_id}=1
    check average throughput    ${ue_id}    ${Target}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir