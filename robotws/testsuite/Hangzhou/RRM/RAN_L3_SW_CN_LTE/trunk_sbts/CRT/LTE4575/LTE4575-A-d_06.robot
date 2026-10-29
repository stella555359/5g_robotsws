*** Settings ***
Documentation     UC:LBT3110-B-d Optional ignoring of CAC_UL value (Samsung interoperation)
...               This sub-feature is verify flag ulCacIgnore
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               DEVHZ5_SG1    owner-ziwei.1.wang    release-FL19
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
@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNCEL-1/CAREL-1:lcrId=3
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:lcrId=4
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:maxNumUeDl=7
...    LNCEL/LNCEL_FDD-0:maxNumUeUl=7
...    LNCEL:caPoolId=1
...    LNCEL:maxNumScells=3
...    LNBTS-1:actFlexScellSelect=true
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=2870
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=2970
...    LNCEL:actFlowCtrlEnh=false
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.31
...    delete:LNBTS-1/LNADJ-255
...    LNCEL-1/CAREL-3:lcrId=2
...    LNCEL-1/CAREL-3:lnBtsId=1
...    LNCEL-1/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-3:scellPrio=3
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
@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=8000
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNCEL-3:defaultLnRelGnbCellId=1
...    LNCEL-2:defaultLnRelGnbCellId=1
...    LNBTS:qciTab8:lteNrDualConnectSupport=disabled
...    delete:LNBTS:qciTab8:nrPdcpProfIdx
@{LTE4193}
...    LNBTS:actDynTrigLteNrDualConnectivity=false
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
...    LNCEL-4/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
@{LTE4575}
...    LNBTS:actCAggrLteNrDualConnectivity=blind_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
@{modulation}
...    LNCEL:actModulationSchemeDl=64QAM
...    LNCEL:actLdPdcch=true
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=3
...    LNCEL:adaptPdcchDwellTime=0
...    LNCEL:mbrSelector=ueCapability
${ue_eutra_capabilities_d}
...    SEPARATOR=
...    DD98004001040CA0102E0B82EFC1BB13400506EE1200000000BC22025F800000016CA0060050420821041006084300300304018200C1086006
...    00442080108010420800840082100018210410820803042082104100608410420821041006084104208200C108208410401821041082080304
...    208200C108208030420821041006006004B41F551850301840008216100020A3040460800E100020A30400B1820080841011820038C1004042
...    0800E30401011820018C10040640B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B
...    82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0BB014000066C843C3C3C5C23F8B90F0F0F0F0F0F0F0F0F0F0E21E1E1E1C000117EC80000040
...    41004010040000014040501010000005014043000C002002002002002002001004010040100401004010040100401004010040100401004010
...    0401004010040000268003E71E00020406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E380C000040200C2609A1
...    43C037FC00000E800000184000
${ue_nr_capabilities}    CE00000001C8F5C0302800001939980000CC00100002600001349880000018060010000001
${ue_eutra_nr_capabilities_06}
...    SEPARATOR=
...    C10040961B06004041C4D000C13800000010201306004041C2800000201B06004040818389A0000080360C0080810307018000018063000080
...    400020101002004040080110000402000100808010023000080400020100008040400801180004020001008000402020040080
@{OnlineChangeList_06}
...    LNBTS:actDynTrigLteNrDualConnectivity=false
@{pcellswap}
...    LNBTS:actPcellSwap=true
...    LNBTS:actIfHo=enabled
...    LNCEL-1:pcellSwapConfig:numCaUeThreshold=5
...    LNCEL-1:pcellSwapConfig:puschLoadIndexThr=0.01
...    LNCEL-2:pcellSwapConfig:numCaUeThreshold=10
...    LNCEL-2:pcellSwapConfig:puschLoadIndexThr=10
...    LNCEL-3:pcellSwapConfig:numCaUeThreshold=10
...    LNCEL-3:pcellSwapConfig:puschLoadIndexThr=10
...    LNCEL:loadSettings:cellCapClass=100
...    LNCEL:loadSettings:mlbEicicOperMode=allUes
...    LNCEL:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL:loadSettings:targetLoadGbrDl=50
...    LNCEL:loadSettings:targetLoadNonGbrDl=75
...    LNCEL:loadSettings:targetLoadPdcch=90
...    LNCEL:loadSettings:ulCacIgnore=false
...    LNCEL:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL:loadSettings:ulStaticCac=100
...    LNCEL-3/CAREL-1:lcrId=1
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-3/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-3/CAREL-1:scellPrio=3
...    LNCEL-3/CAREL-2:lcrId=4
...    LNCEL-3/CAREL-2:lnBtsId=1
...    LNCEL-3/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-3/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-3/CAREL-2:scellPrio=3
...    LNCEL-3:scellFastSchedulingSelect=normal
...    LNCEL-3:dlCaMinPcellCqi=0
...    LNCEL-3:dlCaMinPcellCqiQci1=0
...    LNCEL-3:ulCaMinPcellSinr=0
...    LNCEL-3:ulCaMinPcellSinrQci1=0
@{Online_del_nrPdcpProf}
...    LNBTS:qciTab8:lteNrDualConnectSupport=disabled
...    delete:LNBTS:qciTab8:nrPdcpProfIdx
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001

*** Test Cases ***
LTE4575-A-d_ET_06_01_UE is in the CA mode and EN-DC is triggered after PCell swap
    [Tags]
    onlinechange_06
    Set ue parameters before ENDC setup
    UE attach to cell1    ue_id=1
    Trigger pcell swap
    Add PDCP bearer to trigger ENDC

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml    
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
    
Set ue parameters before ENDC setup
    Execute Egate Command     ue_param id=1 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Egate Command     ue_param id=1 nr_supported_bands=78
    Execute Egate Command     gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command     gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command     gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command     enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command     enb_timer T_DC_Overall=5000ms

UE attach to cell1
    [Arguments]    ${ue_id}=1
    ${3cc}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 2 and physCellId-r10 eq 4 and dl-CarrierFreq-r10 eq 2970)
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${3cc})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=attach_scell    overall_timeout=20
    ${V_4}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_06} \
    ...    ue_eutra_capabilities=${ue_eutra_capabilities_d} cell=1
    sleep    3s    #wait for reconfig of scell setup after attach success
    ${ret}    Execute Uex Command     ${V_4}
    Flow Occurred As Expected    alias=attach_scell

onlinechange_06
    Delta Commission Parameters    ${OnlineChangeList_06}
    Delta Commission Parameters    ${Online_del_nrPdcpProf}
    Cells Should Be OnAir

Trigger pcell swap
    [Arguments]    ${ue_id}=1    ${Bearer_ID}=1    
    ${swap}    catenate
    ...    sCellToReleaseList-r10 contains (2,1) and
    ...    (sCellToAddModList-r10 contains ((sCellIndex-r10 eq 2) and (physCellId-r10 eq 1) and (dl-CarrierFreq-r10 eq 1500)))
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${swap})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
	...    UE_${ue_id}:RRC_RRCConnectionReconfiguration
	...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=pcell_swap    overall_timeout=20
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp Mbps=150
    Execute Uex Command    trf_data_start ue=${ue_id} dir=ul protocol=udp Mbps=150
    sleep    20    #wait trf take effect
    Flow Occurred As Expected    alias=pcell_swap

Add PDCP bearer to trigger ENDC
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    ENB_1:X2AP_SgNBAdditionRequestAcknowledge
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=ENDC    overall_timeout=20
    Execute Uex Command    bearer_add ue=1 qci=6
    Flow Occurred As Expected    alias=ENDC
