*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT    team-DevHZ5_SG1
...               CLOUD_R4LAPO_CUS    release-SBTS23R3    owner-pei.han
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_VENDOR}
...    LNBTS:reportTimerIFSBA4=5000ms
...    LNBTS:reportTimerIFLBA4=5000ms
...    LNBTS:reportTimerEndcA5=5000ms
${UTE_WIRESHARK_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    @{PARAMS_For_CB008909}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19600
...    LNBTS:actMultBearers=true
...    LNBTS:actMultGbrBearers=true
...    LNBTS:actIfHo=enabled
...    LNBTS:actRedirect=disabled
...    LNCEL:threshold1=75
...    @{PARAMS_For_Neighbor_eNB}
...    @{PCMD_Setup}
...    @{PARAMS_FOR_PMQAP}
...    @{MRO_Counter_Related}
@{PARAMS_For_CB008909}
...    LNCEL:actServBasedHoQciX=true
...    LNBTS:reportTimerSBHoQciXA5=${reportTimerSBHoQciXA5}
...    LNBTS:qciTab2:servBasedHoAllowed=forbidden
...    LNBTS:qciTab3:servBasedHoAllowed=forbidden
...    LNBTS:qciTab4:servBasedHoAllowed=allowed
...    LNBTS:qciTab5:servBasedHoAllowed=forbidden
...    LNBTS:qciTab6:servBasedHoAllowed=forbidden
...    LNBTS:qciTab7:servBasedHoAllowed=forbidden
...    LNBTS:qciTab8:servBasedHoAllowed=allowed
...    LNBTS:qciTab9:servBasedHoAllowed=forbidden
...    LNBTS:qciTab65:servBasedHoAllowed=forbidden
...    LNBTS:qciTab66:servBasedHoAllowed=forbidden
...    LNBTS:qciTab67:servBasedHoAllowed=forbidden
...    LNBTS:qciTab69:servBasedHoAllowed=forbidden
...    LNBTS:qciTab70:servBasedHoAllowed=forbidden
...    LNBTS:qciTabOperator:servBasedHoAllowed=forbidden
...    LNCEL-1/LNHOIF-1:thresholdRsrpSBHoQciXFilter=-98
...    LNCEL-1/LNHOIF-1:thresholdRsrqSBHoQciXFilter=-120
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1600
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-2:thresholdRsrpSBHoQciXFilter=-98
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=38000
...    LNCEL-1/LNHOIF-2:measurementBandwidth=mbw100
...    LNBTS:actSelMobPrf=false
...    LNBTS/MODPR-0:freqLayListServBasedHoQciX=1600,38000
...    LNBTS/MODPR-0:autoAdapt=false
@{PARAMS_For_Neighbor_eNB}
...    LNBTS/LNADJ-255:adjEnbId=2
...    LNBTS/LNADJ-255:cPlaneIpAddr=10.0.1.31
...    LNBTS/LNADJ-255:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJ-255:plmnId:mnc=3
...    LNBTS/LNADJ-255:plmnId:mcc=262
...    LNBTS/LNADJ-255:plmnId:mncLength=2
...    LNBTS/LNADJ-254:adjEnbId=3
...    LNBTS/LNADJ-254:cPlaneIpAddr=10.0.1.32
...    LNBTS/LNADJ-254:cPlaneIpAddrCtrl=oamControlled
...    LNBTS/LNADJ-254:plmnId:mnc=3
...    LNBTS/LNADJ-254:plmnId:mcc=262
...    LNBTS/LNADJ-254:plmnId:mncLength=2
...    LNBTS/LNADJ-254/LNADJL-1:fDlEarfcn=38000
...    LNBTS/LNADJ-254/LNADJL-1:phyCellId=31
...    LNBTS/LNADJ-254/LNADJL-1:tac=33
...    LNBTS/LNADJ-254/LNADJL-1:ecgiLcrId=31
...    LNCEL-1/LNREL-3:ecgiAdjEnbId=3
...    LNCEL-1/LNREL-3:ecgiLcrId=31
...    LNCEL-1/LNREL-3:handoverAllowed=onlyS1
...    LNCEL-1/LNREL-3:removeAllowed=false
...    LNCEL-1/LNREL-3:cellIndOffNeigh=0dB
...    LNBTS/MODPR-0:freqLayListLte=1400
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-3/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-3/LNHOIF-1:thresholdRsrpSBHoQciXFilter=-98
...    LNCEL-3/LNHOIF-1:thresholdRsrqSBHoQciXFilter=-120
@{LTE5150_LTE6607}
...    LNBTS:actEndcHo=enabled
...    LNBTS:actUeCapEndcHo=true
...    LNCEL:iFEndcHoRetryTimer=10
...    LNBTS:blockEndcHoRetryAtHoFromTrg=no blocking
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=38000
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=true
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=41
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=38000
...    LNCEL-1/LNHOIF-2:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-2:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-2:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-2:thresholdRsrpSBHoQciXFilter=-98
...    LNCEL-1/LNHOIF-2:thresholdRsrqSBHoQciXFilter=-120
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    LNBTS/MODPR-0:freqLayEndcHoList:freqLayer=38000
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true
...    LNBTS:actLteNrDualConnectivity=false
...    LNBTS:actDynTrigLteNrDualConnectivity=false
@{param_handover_for_case19}
...    @{LTE5150_LTE6607}
...    LNCEL-3/LNHOIF-1:thresholdRsrpSBHoQciXFilter=-98
...    LNCEL-3/LNHOIF-1:thresholdRsrqSBHoQciXFilter=-120
...    LNCEL-3/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-3/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-3/LNHOIF-1:measurementBandwidth=mbw100
...    LNBTS/MODPR-0:freqLayListLte=1400
...    LNBTS/MODPR-0:freqLayListServBasedHoQciX=1600
@{param_recovery_for_case19}
...    LNBTS/MODPR-0:freqLayListServBasedHoQciX=1600,38000
...    LNBTS:actEndcHo=disabled
...    LNBTS:actUeCapEndcHo=false
...    LNBTS/MODPR-0:freqLayListLte=1400
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=noRetries
...    delete:LNCEL:iFEndcHoRetryTimer
...    delete:LNBTS:blockEndcHoRetryAtHoFromTrg
...    delete:LNBTS/MODPR-0:freqLayEndcHoList
...    delete:LNBTS/CAGENB-0/CAIMLBP-0
${ue_eutra_capabilities}
...    SEPARATOR=
...    DD9FF44083000894204F82E0B8004FBF06FCCF650801102008295000028331D9FE0DD89A5E190117BF06EC4D5858210C2084308210C108608
...    410025A0FAA8C28141C208020A30410B08200828C1051820858410041420828C1041C208020A104103082008207280020B205C1705C1705C1
...    705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705
...    DF8A0000336421E1E1E2E11FC5C878787878787878787878710F0F0F0E00008BF060000102020880CD0007CE3C0004080C10181C2C4C6C707
...    507EFF896B4D03217F9A00EA000600DB24000080000412E780C000048080C2609A143C037FC00000A00000061000880004
@{LTE5603}
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1:reportTimerIFSPIDA5=5000ms
...    LNBTS-1/LNCEL-1:actInterFreqSPIDBasedHo=all triggers
...    LNBTS-1/LNCEL-1/LNHOIF-3:thresholdRsrpIFSPIDFilter=-140
...    LNBTS-1/LNCEL-1/LNHOIF-3:thresholdRsrqIFSPIDFilter=-12
...    LNCEL-1/LNHOIF-3:thresholdRsrpSBHoQciXFilter=-98
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=38100
...    LNBTS-1/LNCEL-1:moPrMappingList=${EMPTY}
...    LNBTS-1/MODPR-0:freqLayListSPIDBasedHo=38100
@{Disable_LTE5603}
...    LNBTS-1:actSelMobPrf=false
...    LNBTS-1/LNCEL-1:actInterFreqSPIDBasedHo=none
...    delete:LNCEL-1/LNHOIF-3
@{LB}
...    LNBTS/MODPR-0:freqLayListLte=1400,1600
...    LNCEL:actInterFreqLB=true
...    LNCEL:actServRlqInterFreqLB=false
...    LNCEL:iFLBA4ActLim=20
...    LNCEL:iFLBLoadThresholds:iFLBHighLoadPdcch=1
...    LNCEL:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=1
...    LNCEL:iFLBLoadThresholds:iFLBHighLoadGBRDL=60
...    LNCEL:iFLBLoadThresholds:iFLBRetryTimer=${${iFLBRetryTimer}*2}
...    LNCEL:iFLBLoadThresholds:iFLBBearCheckTimer=0
...    LNCEL:iFLBLoadThresholds:maxNumAmleNeigh=16
...    delete:LNCEL:intraFreqLbLoadThresholds
...    LNCEL:loadSettings:cellCapClass=100
...    LNCEL:loadSettings:targetLoadNonGbrDl=1
...    LNCEL:loadSettings:targetLoadPdcch=1
...    LNCEL:loadSettings:targetLoadGbrDl=50
...    LNCEL:loadSettings:mlbEicicOperMode=allUes
...    LNCEL:loadSettings:nomNumPrbNonGbr=10
...    LNCEL:loadSettings:ulStaticCac=100
...    LNCEL:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL:loadSettings:ulCacIgnore=false
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=1
@{Disable_LB}
...    LNCEL:actInterFreqLB=false
${iFLBRetryTimer}    5
${reportTimerSBHoQciXA5}    5000ms
@{PCMD_Setup}
...    LNBTS:actPCMDReport=true
...    LNBTS/CTRLTS-1:extTraceReporting:extCellTraceRep=true
...    LNBTS/CTRLTS-1/MTRACE-1:actPCMDReporting=true
...    LNBTS/CTRLTS-1/MTRACE-1:jobType=TraceOnly
...    LNBTS/CTRLTS-1/MTRACE-1:tceIpAddress=10.0.1.1
...    LNBTS/CTRLTS-1/MTRACE-1:tceCellTracePortNum=49150
...    LNBTS/CTRLTS-1/MTRACE-1:lcrId=1
...    LNBTS/CTRLTS-1/MTRACE-1:traceRrcSetting=None
...    LNBTS/CTRLTS-1/MTRACE-1:traceS1Setting=None
...    LNBTS/CTRLTS-1/MTRACE-1:traceX2Setting=None
...    LNBTS/CTRLTS-1/MTRACE-1:actUeThroughputMR=false
...    LNBTS/CTRLTS-1/MTRACE-1:cellVendorSpecTracing:cellTaTracing=false
@{PARAMS_FOR_PMQAP}
...    LNBTS-1/PMRNL-1:mtHandoversPMQAP=15min
...    LNBTS-1/PMRNL-1/PMQAP-1:cfgQCIRange=1
...    LNBTS-1/PMRNL-1/PMQAP-1:cfgPRI=20
...    LNBTS-1/PMRNL-1/PMQAP-2:cfgQCIRange=4
...    LNBTS-1/PMRNL-1/PMQAP-2:cfgPRI=20
...    LNBTS-1/PMRNL-1/PMQAP-3:cfgQCIRange=2-8
...    LNBTS-1/PMRNL-1/PMQAP-3:cfgPRI=20
...    LNBTS-1/PMRNL-1/PMQAP-5:cfgQCIRange=2-8
...    LNBTS-1/PMRNL-1/PMQAP-5:cfgPRI=20
...    MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
...    delete:LNBTS-1/PMRNL-1/PMQAP-1:cfgARPRange
...    delete:LNBTS-1/PMRNL-1/PMQAP-1:cfgUECategory
...    delete:LNBTS-1/PMRNL-1/PMQAP-1:pLMNID
...    LNBTS-1/PMRNL-1/PMQAP-2:cfgARPRange=${empty}
...    LNBTS-1/PMRNL-1/PMQAP-2:cfgUECategory=${empty}
...    LNBTS-1/PMRNL-1/PMQAP-2:pLMNID=${empty}
...    LNBTS-1/PMRNL-1/PMQAP-3:cfgARPRange=${empty}
...    LNBTS-1/PMRNL-1/PMQAP-3:cfgUECategory=${empty}
...    LNBTS-1/PMRNL-1/PMQAP-3:pLMNID:cfgMCC=262
...    LNBTS-1/PMRNL-1/PMQAP-3:pLMNID:cfgMNC=3
...    LNBTS-1/PMRNL-1/PMQAP-3:pLMNID:cfgMNCLength=2
...    LNBTS-1/PMRNL-1/PMQAP-5:cfgARPRange=${empty}
...    LNBTS-1/PMRNL-1/PMQAP-5:cfgUECategory=${empty}
...    LNBTS-1/PMRNL-1/PMQAP-5:pLMNID:cfgMCC=262
...    LNBTS-1/PMRNL-1/PMQAP-5:pLMNID:cfgMNC=4
...    LNBTS-1/PMRNL-1/PMQAP-5:pLMNID:cfgMNCLength=2
...    LNBTS-1:actQCIPLMNIDProfiles=true
...    LNBTS-1:actFlexQCIARPPMProfiles=true
@{MRO_Counter_Related}
...    LNCEL:tStoreUeCntxt=10000
...    LNCEL:tPingPong=10000

@{PM_Counters_CB008909}
...    LNCEL-1/MCC-262/MNC-03:${HO_SB_NON_QCI1_ATT}=3
...    LNCEL-1/MCC-262/MNC-03:${HO_SB_NON_QCI1_SUCC}=3
...    LNCEL-1/PMQAP-1:${HO_SB_ATT_PROFILE}=0
...    LNCEL-1/PMQAP-1:${HO_SB_SUCC_PROFILE}=0
...    LNCEL-1/PMQAP-2:${HO_SB_ATT_PROFILE}=1
...    LNCEL-1/PMQAP-2:${HO_SB_SUCC_PROFILE}=1
...    LNCEL-1/PMQAP-3:${HO_SB_ATT_PROFILE}=4
...    LNCEL-1/PMQAP-3:${HO_SB_SUCC_PROFILE}=4
...    LNCEL-1/PMQAP-5:${HO_SB_ATT_PROFILE}=0
...    LNCEL-1/PMQAP-5:${HO_SB_SUCC_PROFILE}=0

${HO_SB_NON_QCI1_ATT}    M8021C59
${HO_SB_NON_QCI1_SUCC}    M8021C60
${HO_SB_ATT_PROFILE}    M8089C9
${HO_SB_SUCC_PROFILE}    M8089C10

@{MRO_Counters}
...    LNCEL-1:${MRO_EARLY_TYPE1_HO}=0
...    LNCEL-1:${MRO_EARLY_TYPE1_HO_NB}=0
...    LNCEL-1:${MRO_LATE_HO}=0
...    LNCEL-1:${MRO_LATE_HO_NB}=0
...    LNCEL-3:${MRO_LATE_HO}=0
...    LNCEL-3:${MRO_LATE_HO_NB}=0
...    LNCEL-1:${MRO_EARLY_TYPE2_HO}=0
...    LNCEL-1:${MRO_EARLY_TYPE2_HO_NB}=0
...    LNCEL-1:${MRO_PING_PONG_HO_NB}=0
...    LNCEL-1/MCC-262/MNC-03:${HO_SB_NON_QCI1_ATT}=4
...    LNCEL-1/MCC-262/MNC-03:${HO_SB_NON_QCI1_SUCC}=3

${MRO_EARLY_TYPE1_HO}    M8021C21
${MRO_EARLY_TYPE1_HO_NB}    M8015C17
${MRO_EARLY_TYPE2_HO}    M8021C22
${MRO_EARLY_TYPE2_HO_NB}    M8015C18
${MRO_LATE_HO}    M8021C20
${MRO_LATE_HO_NB}    M8015C16
${MRO_PING_PONG_HO_NB}    M8015C20
${ue_eutra_capabilities_case19}
...    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B9832692A750B5F9D3A00000001D00000002E9000000004E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000037
...    F7FFDB4000420070D9000000005EE800000020254A8389D0100000208001C2000404208002180004400008A000118000238000480000920001
...    280002580004C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003
...    A7400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000074
...    00000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000074000
...    00003A00000001D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000
...    0000000202388425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C280203050F010000000E3002000000640
${ue_MRDC_capabilities_case19}    0108080164C01C2800000000B2500E1400000000420001008080100200200806004008
${ue_nr_capabilities_case19}    00000000010100200000600001401002C94038500000000164C01C28000000

*** Test Cases ***
CB008909-SR-A-B8_ET_42_01_Counters and PCMD check
    [Documentation]    This case verifies counters include PMQAP Profile counters and PCMD values;
    [Tags]
    [Setup]    Start TCE And Start To Capture Logs
    Clear Counter Files
    Start Rtpm Counter
    UE Attach with QCIx SBHO eA5    ue_id=1
    Trigger intra-eNB QCIx SBHO    ue_id=1
    UE Attach with QCIx SBHO eA5    ue_id=2
    Trigger inter-eNB S1 QCIx SBHO    ue_id=2
    UE Attach with QCIx SBHO eA5    ue_id=6
    Trigger inter-eNB X2 QCIx SBHO    ue_id=6
    Release All UEs
    check rtpm counters    ${PM_Counters_CB008909}
    Check WireShark Log    ${CURDIR}/a2a/a2a.ini
    [Teardown]    Stop TCE And Stop Capture Logs

CB008909-SR-A-B8_ET_43_01_No MRO Counters Pegging in Case of QCIx SBHO
    [Documentation]    This case verifies MRO counters will not increase when QCIx SBHO happen;
    [Tags]
    Clear Counter Files
    Start Rtpm Counter
    UE Attach with QCIx SBHO eA5    ue_id=1
    Trigger inter-eNB X2 QCIx SBHO failed and reestablishment to source cell_MRO_Early_Type1_HO    ue_id=1
    UE Attach with QCIx SBHO eA5    ue_id=2
    Trigger intra-eNB QCIx SBHO failed and reestablishment to target cell_MRO_Late_HO    ue_id=2
    UE Attach with QCIx SBHO eA5    ue_id=3
    Trigger intra-eNB QCIx SBHO then reestablishment to source cell_MRO_Early_Type2_HO    ue_id=3
    UE Attach with QCIx SBHO eA5    ue_id=4
    Trigger intra-eNB QCIx SBHO    ue_id=4
    Trigger HO back to Cell-1 before tPingPong     ue_id=4
    Release All UEs
    check rtpm counters    ${MRO_Counters}
	
CB008909-SR-A-B5-B6_ET_19_02_No ENDC-HO Measurement when QCIx-SBHO Enabled
    [Documentation]    This case verifies the CB008909 Interacts with LTE5150 and LTE6607;
    ...    step1: Attach UE-1 to Cell-1 with QCIx bearer QCI-8,Attach successfully and QCIx SBHO eA5 measurements configure
    ...    No EN-DC HO A5 measurement configure;
    ...    step2: UE-2 HO to Cell-2 and HO back to Cell-1,No QCIx SBHO eA5 configure and No EN-DC HO A5 measurement configure;
    ...    step3: Attach UE-2 to Cell-1 with QCI-6,Attach successfully and EN-DC HO A5 measurement configure;
    ...    step4: UE-2 E-RAB setup QCIx bearer QCI-8 before reportTimerEndcA5 expired,
    ...    QCIx SBHO eA5 measurements configure, deactivate EN-DC HO A5 measurement;
    ...    step5: UE-2 E-RAB release QCIx bearer QCI-8,After iFEndcHoRetryTimer, EN-DC HO A5 configure;
    [Tags]    run
    Online parameter change      ${param_handover_for_case19}
    UE Attach to eNB1 Cell1 with QCIx_SBHO eA5 and wo ENDC HO A5    ${ue_eutra_capabilities_case19}    ${ue_MRDC_capabilities_case19}
    ...    ${ue_nr_capabilities_case19}    ue_id=1    cell_id=1    earfcn=1600    reportConfigId=4
    UE handover to cell3 and handover back    ue_id=1
    UE Attach to eNB1 Cell1 with ENDCHO eA5    ${ue_eutra_capabilities_case19}    ${ue_MRDC_capabilities_case19}     ${ue_nr_capabilities_case19}
    ...    ue_id=7    cell_id=1    earfcn=38000    reportConfigId=4
    Add one NON_GBR QCIx bearer with QCIx_SBHO eA5 and deactive ENDC a5    ue_id=7     qci=8
    Relese QCIx bearer bearer    ue_id=7     qci=8
    Release All UEs
    [Teardown]     Restore Env and Capture Logs    ${param_recovery_for_case19}


CB008909-SR-A-B5-B6_ET_20_02_No LB LE A4 Measurement when QCIx-SBHO Enabled
    [Documentation]    This case verifies the 'UE enabled for CB008909' (See URSC.4020) is not considered as LB candidate;
    ...    step1: Attach UE-1 to Cell-1 to trigger Cell-1 into LB status;
    ...    step2: Attach UE-2 to Cell-1 with QCIx bearer, then QCIx SBHO A5 configured without LB HO A4;
    ...    step3: UE-2 trigger RRC Reestablish, no QCIx SBHO A5 and LB HO A4 configured;
    ...    step4: Attach UE-3 without QCIx bearer, LB HO A4 configured;
    ...    step5: UE-3 Add QCIx bearer to deactivate LB HO A4 and QCIx SBHO A5 configured;
    ...    step6: UE-3 trigger QCIx release, then LB HO A4 reconfigured after iFLBRetryTimer;
    ...    step7: UE-3 Add QCIx bearer to deactivate LB HO A4 and QCIx SBHO A5 configured;
    ...    step8: UE-3 trigger QCIx SBHO from eNB-1 Cell-1 to eNB-2 Cell-1;
    ...    step9: UE-3 trigger HO from eNB-2 Cell-1 to eNB-1 Cell-1; and no QCIx SBHO A5 and LB HO A4 configured.
    [Tags]    run
    Online parameter change     ${LB}
    UE Attach to trigger Cell into LB    ue_id=1
    UE Attach with QCIx SBHO eA5 without LB HO A4    ue_id=2
    Trigger UE Reestablish    ue_id=2
    UE Attach with LB HO A4    ue_id=5
    Add QCIx bearer to deactivate LB HO A4    ue_id=5
    Release QCIx Bearer to Retry LB HO A4    ue_id=5
    Add QCIx bearer to deactivate LB HO A4 again    ue_id=5
    Trigger inter-eNB X2 QCIx SBHO    ue_id=5
    Trigger inter-eNB HO From sim-eNB2 to eNB1 Cell-1    ue_id=5
    Release All UEs
    [Teardown]     Restore Env and Capture Logs    ${Disable_LB}

CB008909-SR-A-B5-B6_ET_21_02_No SPID A5 Measurement when QCIx-SBHO Enabled
    [Documentation]    This case verifies:
    ...    CB008909 Interacts with LTE5603;
    ...    LTE5603: SPID based mobility trigger;
    ...    CB008909 is prioritized over SPID based handover. With both features enabled the 'UE enabled for CB008909' (See URSC.4020)
    ...    is not considered as SPID based handover candidate during any SPIDHO trigger (ICS, incoming HO),
    ...    i.e. SPIDHO measurements are not tried even if CB008909 measurements could not start.
    ...    step1: Attach UE-1 to Cell-1 with QCIx bearer, then QCIx SBHO A5 configured without SPID HO A5;
    ...    step2: UE-1 trigger RRC Reestablish, no QCIx SBHO A5 and LB HO A4 configured;
    ...    step3: Attach UE-3 without QCIx bearer, SPID HO A5 configured;
    ...    step4: UE-3 Add QCIx bearer to deactivate SPID HO A5 and QCIx SBHO A5 configured;
    ...    step5: UE-3 trigger QCIx SBHO from eNB-1 Cell-1 to eNB-2 Cell-1;
    ...    step6: UE-3 trigger HO from eNB-2 Cell-1 to eNB-1 Cell-1; no QCIx SBHO A5 and SPID HO A5 configured.
    [Tags]
    Online parameter change     ${LTE5603}
    UE Attach with QCIx SBHO eA5 without SPID SBHO A5    ue_id=1
    Trigger UE Reestablish    ue_id=1
    UE Attach with SPID SBHO A5    ue_id=5
    Add QCIx bearer to deactivate SPID HO A5    ue_id=5
    Trigger inter-eNB X2 QCIx SBHO    ue_id=5
    Trigger inter-eNB HO From sim-eNB2 to eNB1 Cell-1    ue_id=5
    Release All UEs
    [Teardown]     Restore Env and Capture Logs    ${Disable_LTE5603}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Restore Env and Capture Logs
    [Arguments]    ${PARAM}
    Online parameter change    ${PARAM}
    Common Test Teardown And Stop Capture Logs

Perform Steps After Onair
    sleep    90s    #wait for X2 available
    @{lnadj_1}    Create List    LNADJ:cPlaneIpAddr=10.0.1.31    LNADJ:x2LinkStatus=available
    Object Should Exist    ${lnadj_1}

Start TCE And Start To Capture Logs
    Common Test Setup And Start To Capture Logs
    Start TCE    ${TCE_PORT}

Stop TCE And Stop Capture Logs
    Stop TCE    ${TCE_PORT}
    Common Test Teardown And Stop Capture Logs

Online parameter change
    [Arguments]    ${PARAM}
    Delta Commission Parameters    ${PARAM}
    Cells Should Be OnAir

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 5, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preemption: off, vulnerability: off, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_4:
    ...     - {qci: 5, default: on, pdn: 1}
    ...     - {qci: 4, gbr_ul: 32, gbr_dl: 320, mbr_ul: 32, mbr_dl: 320, preprovisioned: on, filter: 1, precedence: 4, pdn: 1}
    ...     - {qci: 8, preprovisioned: on, filter: 1, precedence: 8, pdn: 1}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_5:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/3    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/4    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/5    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/6    bearer: bearer_set_4
    Update Yaml    UEs/UE_sets/7    bearer: bearer_set_5
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.31
    ...      x2: 10.0.1.31
    ...      cells:
    ...        - {'id': 21, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '7:0', eci: '0x0000215', earfcn: '38000:38000', bw: 20}
    ...        - {'id': 22, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '7:1', eci: '0x0000216', earfcn: '38100:38100', bw: 20}
    ...        - {'id': 23, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '7:2', eci: '0x0000217', earfcn: '38000:38000', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.32
    ...      x2_peers: none
    ...      cells:
    ...        - {'id': 31, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '10:1', eci: '0x000031F', earfcn: '38000:38000', bw: 20}

UE Attach with QCIx SBHO eA5
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${measObjectToAddModList}    catenate
    ...    measObjectToAddModList contains (measObjectId eq 2 and carrierFreq eq 1600, measObjectId eq 3 and carrierFreq eq 38000)
    ${reportConfigToAddModList}    catenate
    ...    reportConfigToAddModList contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97) and
    ...    a5-Threshold2 contains (threshold-RSRP eq 0)))
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 3 and measObjectId eq 2 and reportConfigId eq 4, measId eq 4 and
    ...    measObjectId eq 3 and reportConfigId eq 4)
    ${a5_activate_flow}    catenate
    ...    (${measObjectToAddModList}) and (${reportConfigToAddModList}) and (${measIdToAddModList}) and
    ...    (s-Measure eq 0) and (measGapConfig contains (gapOffset is present))
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${a5_activate_flow})
    ...    alias=a5_activate_flow  overall_timeout=4
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Occurred As Expected    alias=a5_activate_flow

UE Attach with QCIx SBHO eA5 without SPID SBHO A5
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${measObjectToAddModList}    catenate
    ...    measObjectToAddModList contains (measObjectId eq 2 and carrierFreq eq 1600, measObjectId eq 3 and carrierFreq eq 38000)
    ${reportConfigToAddModList}    catenate
    ...    reportConfigToAddModList contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97) and
    ...    a5-Threshold2 contains (threshold-RSRP eq 0)))
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 3 and measObjectId eq 2 and reportConfigId eq 4, measId eq 4 and
    ...    measObjectId eq 3 and reportConfigId eq 4)
    ${a5_activate_flow}    catenate
    ...    (${measObjectToAddModList}) and (${reportConfigToAddModList}) and (${measIdToAddModList}) and
    ...    (s-Measure eq 0) and (measGapConfig contains (gapOffset is present))
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${a5_activate_flow})
    ...    alias=a5_activate_flow  overall_timeout=4
    ${no_SPID_A5}    catenate
    ...    measObjectToAddModList contains (carrierFreq eq 38100)
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_SPID_A5})
    ...    alias=attach_no_SPID_A5  overall_timeout=4
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Occurred As Expected    alias=a5_activate_flow
    Flow Not Occurred For Message    alias=attach_no_SPID_A5

UE Attach with SPID SBHO A5
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${measObjectToAddModList}    catenate
    ...    measObjectToAddModList contains (measObjectId eq 2 and carrierFreq eq 38100)
    ${reportConfigToAddModList}    catenate
    ...    reportConfigToAddModList contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97) and
    ...    a5-Threshold2 contains (threshold-RSRP eq 0)))
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 3 and measObjectId eq 2 and reportConfigId eq 4)
    ${SPID_a5_activate_flow}    catenate
    ...    (${measObjectToAddModList}) and (${reportConfigToAddModList}) and (${measIdToAddModList}) and
    ...    (s-Measure eq 0) and (measGapConfig contains (gapOffset is present))
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${SPID_a5_activate_flow})
    ...    alias=attach_SPID_a5_flow  overall_timeout=2
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Occurred As Expected    alias=attach_SPID_a5_flow

Trigger UE Reestablish
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${no_a5_flow}    catenate
    ...    measIdToAddModList contains (measObjectId eq 2 or measObjectId eq 3 or measObjectId eq 4)
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_a5_flow})
    ...    alias=attach_no_a5_flow  overall_timeout=10
    Execute Uex Command    ue_rrc_reestablish id=${ue_id} enb=1 cell=${cell_id} cause=otherFailure
    Flow Not Occurred For Message    alias=attach_no_a5_flow

Add QCIx bearer to deactivate SPID HO A5
    [Arguments]    ${ue_id}=1    ${qci}=4
    ${measObjectToAddModList}    catenate
    ...    measObjectToAddModList contains (measObjectId eq 3 and carrierFreq eq 1600, measObjectId eq 4 and carrierFreq eq 38000)
    ${measIdToRemoveList}    catenate
    ...    measIdToRemoveList contains (3)
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 3 and measObjectId eq 3 and reportConfigId eq 4, measId eq 4 and
    ...    measObjectId eq 4 and reportConfigId eq 4)
    ${Expect_Message_Flow}    catenate
    ...    (${measObjectToAddModList}) and (${measIdToRemoveList}) and (${measIdToAddModList})
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${Expect_Message_Flow})
    ...    alias=QCIx_a5_activate_flow  overall_timeout=4
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci} mbr_ul=32 mbr_dl=320 gbr_ul=32 gbr_dl=320
    Flow Occurred As Expected    alias=QCIx_a5_activate_flow

Trigger inter-eNB X2 QCIx SBHO
    [Arguments]    ${ue_id}=1    ${pci}=21    ${earfcn}=38000
    Expect Message Flow
    ...    ENB_1:X2AP_HandoverRequest (Cause contains (radioNetwork eq "resource-optimisation-handover"))
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    ENB_1:X2AP_UEContextRelease
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 21))
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=inter_eNB_QCIx_SBHO  overall_timeout=10
    Execute Uex Command
    ...    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${pci} nrsrp=65 nrsrq=16 earfcn=${earfcn}
    Flow Occurred As Expected    alias=inter_eNB_QCIx_SBHO

Trigger intra-eNB QCIx SBHO
    [Arguments]    ${ue_id}=1    ${pci}=3    ${earfcn}=1600
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 3))
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (s-Measure eq 75)
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=intra_eNB_QCIx_SBHO  overall_timeout=10
    Execute Uex Command
    ...    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${pci} nrsrp=70 nrsrq=16 earfcn=${earfcn}
    Flow Occurred As Expected    alias=intra_eNB_QCIx_SBHO

Trigger inter-eNB S1 QCIx SBHO
    [Arguments]    ${ue_id}=1    ${pci}=31    ${earfcn}=38000
    Expect Message Flow
    ...    MME_1:S1AP_HandoverRequired (Cause contains (radioNetwork eq "resource-optimisation-handover"))
    ...    MME_1:S1AP_HandoverCommand
    ...    MME_1:S1AP_UEContextReleaseCommand (Cause contains (radioNetwork eq "successful-handover"))
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 31))
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=inter_eNB_QCIx_SBHO  overall_timeout=10
    Execute Uex Command
    ...    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${pci} nrsrp=65 nrsrq=16 earfcn=${earfcn}
    Flow Occurred As Expected    alias=inter_eNB_QCIx_SBHO

Trigger inter-eNB HO From sim-eNB2 to eNB1 Cell-1
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    ENB_1:X2AP_HandoverRequest
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    ENB_1:X2AP_UEContextRelease
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 1))
    ...    alias=inter_eNB_HO  overall_timeout=10
    ${no_A4_A5_flow}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains
    ...    (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))) or
    ...    (eventA4 contains (a4-Threshold contains (threshold-RSRP eq 0))))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_A4_A5_flow})
    ...    alias=no_A4_A5_flow  overall_timeout=10
    Execute Uex Command    ue_ho id=${ue_id} cell=1
    Flow Occurred As Expected    alias=inter_eNB_HO
    Flow Not Occurred For Message    alias=no_A4_A5_flow

UE Attach to trigger Cell into LB
    [Arguments]    ${ue_id}=1
    UE Attach with QCIx SBHO eA5    ${ue_id}
    UE start traffic to trigger Load    ${ue_id}

UE start traffic to trigger Load
    [Arguments]    ${ue_id}=1
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl_and_ul protocol=udp Mbps_dl=150 Mbps_ul=20 qci=8
    Sleep    5s    #wait for eNB load to be High
    Execute Uex Command    ue_stats id=${ue_id} type=dl_mac scell=0 unit=Mbps

UE Attach with QCIx SBHO eA5 without LB HO A4
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${reportConfigToAddModList}    catenate
    ...    reportConfigToAddModList contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97) and
    ...    a5-Threshold2 contains (threshold-RSRP eq 0)))
    ${a5_activate_flow}    catenate
    ...    (${reportConfigToAddModList}) and (s-Measure eq 0) and (measGapConfig contains (gapOffset is present))
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${a5_activate_flow})
    ...    alias=a5_activate_flow  overall_timeout=10
    ${no_a4_flow}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA4 contains (a4-Threshold contains (threshold-RSRP eq 0))))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_a4_flow})
    ...    alias=no_a4_flow  overall_timeout=10
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Occurred As Expected    alias=a5_activate_flow
    Flow Not Occurred For Message    alias=no_a4_flow

UE Attach with LB HO A4
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${measObjectToAddModList}    catenate
    ...    measObjectToAddModList contains (measObjectId eq 2 and carrierFreq eq 1600)
    ${reportConfigToAddModList}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA4 contains (a4-Threshold contains (threshold-RSRP eq 0))))
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 31 and measObjectId eq 2 and reportConfigId eq 4)
    ${a4_activate_flow}    catenate
    ...    (${measObjectToAddModList}) and (${reportConfigToAddModList}) and (${measIdToAddModList})
    ...    and (s-Measure eq 0) and (measGapConfig contains (gapOffset is present))
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${a4_activate_flow})
    ...    alias=a4_activate_flow  overall_timeout=10
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Occurred As Expected    alias=a4_activate_flow

Add QCIx bearer to deactivate LB HO A4
    [Arguments]    ${ue_id}=1    ${qci}=4
    ${measObjectToAddModList}    catenate
    ...    measObjectToAddModList contains (measObjectId eq 3 and carrierFreq eq 38000)
    ${reportConfigToAddModList}    catenate
    ...    reportConfigToAddModList contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97) and
    ...    a5-Threshold2 contains (threshold-RSRP eq 0)))
    ${measIdToRemoveList}    catenate
    ...    measIdToRemoveList contains (31)
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 3 and measObjectId eq 2 and reportConfigId eq 5, measId eq 4 and
    ...    measObjectId eq 3 and reportConfigId eq 5)
    ${Expect_Message_Flow}    catenate
    ...    (${measObjectToAddModList}) and (${reportConfigToAddModList}) and (${measIdToRemoveList}) and (${measIdToAddModList})
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${Expect_Message_Flow})
    ...    alias=QCIx_a5_activate_flow  overall_timeout=4
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci} mbr_ul=32 mbr_dl=320 gbr_ul=32 gbr_dl=320
    Flow Occurred As Expected    alias=QCIx_a5_activate_flow

Release QCIx Bearer to Retry LB HO A4
    [Arguments]    ${ue_id}=1    ${qci}=4
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 31 and measObjectId eq 2 and reportConfigId eq 4)
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${measIdToAddModList})
    ...    alias=a4_activate_flow  overall_timeout=${${iFLBRetryTimer}+3}
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=a4_activate_flow

Add QCIx bearer to deactivate LB HO A4 again
    [Arguments]    ${ue_id}=1    ${qci}=4
    ${measIdToRemoveList}    catenate
    ...    measIdToRemoveList contains (31)
    ${measIdToAddModList}    catenate
    ...    measIdToAddModList contains (measId eq 3 and measObjectId eq 2 and reportConfigId eq 5, measId eq 4 and
    ...    measObjectId eq 3 and reportConfigId eq 5)
    ${Expect_Message_Flow}    catenate
    ...    (${measIdToRemoveList}) and (${measIdToAddModList})
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${Expect_Message_Flow})
    ...    alias=QCIx_a5_activate_flow  overall_timeout=4
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci} mbr_ul=32 mbr_dl=320 gbr_ul=32 gbr_dl=320
    Flow Occurred As Expected    alias=QCIx_a5_activate_flow

Trigger inter-eNB X2 QCIx SBHO failed and reestablishment to source cell_MRO_Early_Type1_HO
    [Arguments]    ${ue_id}=1    ${pci}=21    ${earfcn}=38000
    Expect Message Flow
    ...    ENB_1:X2AP_HandoverRequest (Cause contains (radioNetwork eq "resource-optimisation-handover"))
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    ENB_1:X2AP_HandoverCancel
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 21))
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReestablishmentRequest (physCellId eq 1 and reestablishmentCause eq "handoverFailure")
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReestablishmentComplete
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (s-Measure eq 75)
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=inter_eNB_QCIx_SBHO_Failed  overall_timeout=10
    Execute Uex Command
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=targetPhysCellId with_value=21 action=reestablish cause=handoverFailure cell=1 nth=1
    Execute Uex Command
    ...    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${pci} nrsrp=65 nrsrq=16 earfcn=${earfcn}
    Flow Occurred As Expected    alias=inter_eNB_QCIx_SBHO_Failed

Trigger intra-eNB QCIx SBHO failed and reestablishment to target cell_MRO_Late_HO
    [Arguments]    ${ue_id}=1    ${pci}=3    ${earfcn}=1600
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 3))
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReestablishmentRequest (physCellId eq 1 and reestablishmentCause eq "otherFailure")
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReestablishmentComplete
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (s-Measure eq 75)
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=intra_eNB_QCIx_SBHO  overall_timeout=10
    Execute Uex Command
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=targetPhysCellId with_value=3 action=reestablish cause=otherFailure cell=3 nth=1
    Execute Uex Command
    ...    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${pci} nrsrp=70 nrsrq=16 earfcn=${earfcn}
    Flow Occurred As Expected    alias=intra_eNB_QCIx_SBHO

Trigger intra-eNB QCIx SBHO then reestablishment to source cell_MRO_Early_Type2_HO
    [Arguments]    ${ue_id}=1
    Trigger intra-eNB QCIx SBHO    ${ue_id}
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReestablishmentRequest
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReestablishmentComplete
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (measObjectId eq 1))
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=rrc_reestablish  overall_timeout=10
    Execute Uex Command    ue_rrc_reestablish id=${ue_id} cause=otherFailure enb=1 cell=1
    Flow Occurred As Expected    alias=rrc_reestablish

Trigger HO back to Cell-1 before tPingPong
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 1))
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=intra_eNB_QCIx_SBHO  overall_timeout=10
    Execute Uex Command    ue_ho id=${ue_id} enb=1 cell=1
    Flow Occurred As Expected    alias=intra_eNB_QCIx_SBHO


UE Attach to eNB1 Cell1 with QCIx_SBHO eA5 and wo ENDC HO A5
    [Arguments]    ${ue_eutra_capabilities}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}    ${ue_id}=1    ${cell_id}=1    ${earfcn}=1600
    ...    ${reportConfigId}=4
    ${no_ENDC_a5_flow}    catenate
    ...    measObjectToAddModList contains (measObjectEUTRA contains (carrierFreq eq 38000)) and
    ...    reportConfigToAddModList contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97)))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_ENDC_a5_flow})
    ...    alias=no_ENDC_a5_flow  overall_timeout=5
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration as a5_active
    ...    alias=attach_a5_flow    overall_timeout=4
    ${attach_cmd}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities} ue_nr_capabilities=${ue_nr_capabilities} cell=${cell_id}
    Execute Uex Command    ${attach_cmd}
    Flow Occurred As Expected    alias=attach_a5_flow
    verify that message fulfills query
    ...  (
    ...    rrcConnectionReconfiguration  contains (
    ...        measObjectToAddModList  contains (measObjectEUTRA contains (carrierFreq eq ${earfcn})) and
    ...        reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97)))) and
    ...        measIdToAddModList contains ((measId eq 3) and (measObjectId eq 2) and (reportConfigId eq ${reportConfigId}))
    ...        )
    ...  )
    ...  message_alias=a5_active
    ...  flow_alias=attach_a5_flow
    Flow Not Occurred For Message    alias=no_ENDC_a5_flow

UE handover to cell3 and handover back
    [Arguments]    ${ue_id}=1    ${pci}=3     ${pci_1}=1    ${earfcn}=1600
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 3))
    ...    alias=ho_flow  overall_timeout=5
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${pci} nrsrp=43 nrsrq=16 earfcn=${earfcn}
    Flow Occurred As Expected    alias=ho_flow

    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    alias=trigger_a3  overall_timeout=5
    ${no_a5_query}    catenate
    ...    reportConfigToAddModList contains (reportConfigEUTRA contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_a5_query})
    ...    alias=ho_no_a5_flow  overall_timeout=5
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34
	Flow Occurred As Expected    alias=trigger_a3
	Flow Not Occurred For Message    alias=ho_no_a5_flow

	Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 1))
    ...    alias=ho_back_flow  overall_timeout=5
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A3 phycell_id=${pci_1} nrsrp=90 nrsrq=20 earfcn=1400
    Flow Occurred As Expected    alias=ho_back_flow

UE Attach to eNB1 Cell1 with ENDCHO eA5
    [Arguments]    ${ue_eutra_capabilities}    ${ue_MRDC_capabilities}    ${ue_nr_capabilities}    ${ue_id}=1    ${cell_id}=1    ${earfcn}=38000
    ...    ${reportConfigId}=4
    ${no_QCIx_a5_flow}    catenate
    ...    measObjectToAddModList contains (measObjectEUTRA contains (carrierFreq eq 1600)) and
    ...    reportConfigToAddModList contains (eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97)))
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${no_QCIx_a5_flow})
    ...    alias=no_QCIx_a5_flow  overall_timeout=4
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration as a5_active
    ...    alias=attach_ENDC_a5_flow    overall_timeout=4
    ${attach_cmd}    catenate    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities} ue_nr_capabilities=${ue_nr_capabilities} cell=${cell_id}
    Execute Uex Command    ${attach_cmd}
    Flow Occurred As Expected    alias=attach_ENDC_a5_flow
    verify that message has fields
    ...    measObjectToAddModList..measObjectId eq 2
    ...    measObjectToAddModList..measObjectEUTRA..carrierFreq eq ${earfcn}
    ...    reportConfigToAddModList..reportConfigEUTRA..triggerType..event..eventId..eventA5..a5-Threshold1..threshold-RSRP eq 97
    ...    measIdToAddModList..measId eq 3
    ...    measIdToAddModList..measObjectId eq 2
    ...    measIdToAddModList..reportConfigId eq ${reportConfigId}
    ...    message_alias=a5_active
    ...    flow_alias=attach_ENDC_a5_flow
    Flow Not Occurred For Message    alias=no_QCIx_a5_flow


Add one NON_GBR QCIx bearer with QCIx_SBHO eA5 and deactive ENDC a5
    [Arguments]    ${ue_id}=1    ${qci}=2        ${earfcn}=1600    ${reportConfigId}=4
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration as a5_active
    ...    alias=NBR_a5_flow    overall_timeout=2
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=NBR_a5_flow
    verify that message fulfills query
    ...  (
    ...    rrcConnectionReconfiguration  contains (
    ...        measObjectToAddModList  contains (measObjectEUTRA contains (carrierFreq eq ${earfcn}))   and
    ...        measIdToRemoveList contains (3)    and
    ...        measIdToAddModList contains ((measId eq 3) and (measObjectId eq 3) and (reportConfigId eq ${reportConfigId}))
    ...        )
    ...  )
    ...  message_alias=a5_active
    ...  flow_alias=NBR_a5_flow

Relese QCIx bearer bearer
    [Arguments]    ${ue_id}=1    ${qci}=8    ${reportConfigId}=4
    ${repeat_ENDC_a5_flow}    catenate
    ...    measIdToAddModList contains ((measId eq 3) and (measObjectId eq 2) and (reportConfigId eq ${reportConfigId}))
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${repeat_ENDC_a5_flow})
    ...    alias=repeat_ENDC_a5_flow  overall_timeout=15
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=repeat_ENDC_a5_flow
