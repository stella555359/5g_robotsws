*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               team-SG4    release-FL17    owner-wen.y.xu
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${DEBUG}  ${True}
${SNAPSHOT_FLAG}   pass:False,fail:False
${BTSLOG_FLAG}  ${True}
${WIRESHARK_FLAG}  ${False}
${NSETAP_PLUGIN_VERSION}  ${EMPTY}  # for exampe: 1.7.2
${TTITRACE_FLAG}  ${False}
${EMIL_FLAG}  ${True}
${IM_FLAG}  ${True}
${ONLY_REPORT_REP}  ${False}
${UTE_WIRESHARK_FLAG}  ${False}
${UTE_CPU_MEM_FLAG}  ${False}
${SOS_REPORT_FLAG}  pass:False,fail:False
${SOS_REPORT_STARTUP_1_FLAG}   pass:False,fail:False
${IPHY_UDPLOG_FLAG}    ${False}
${IPHY_EXTRA_FLAG}    ${False}

@{PARAMS_IN_VENDOR}
...    LNBTS:reportTimerEndcA5=5000ms

${TCE_PORT}       49150

${ue_nr_capabilities}    0000000001010000000060100581007018000000
${ue_eutra_nr_capabilities}  0108040160401C06000000000400020101002004
${ue_eutra_capabilities}  SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000
...    E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFB
...    FFEC800801C364000000017BA000000080952A0E2740400000820001080002180004400008A000118000238000480000920001280002580004
...    C00009A000140000288000520000A60001500002A8000560000AE0001600002C80005A0000B60001740002F00006D0000FE003A7400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000000
...    01D00000000E800000007400000003A0000000141000000F3A0000000000000000000000000000000000000000000000000000000000020238
...    8425300C39FFFFFFFFFFFFFFF42A0006008A5C000080000412C2800033C000001800000080

${UE_UTRA_Capabilities}
...    SEPARATOR=
...    40000AC0CAAB541A955AA22920C102000600054184031EFA8063DC073CA1C410143AE86400E80DC152980000B492DE91346CD42C0448F872E6
...    CFAD80891F0E5CD9E8580891F0E5CD9FE0
${TC02_More_Than_InactivityTimer}    15s
${TC05_UE_eUTRA_Capabilities}    CD9FF449B2E75008081C0FFFFFFFFF9C3100030401052A00000002803059FFFFFFFF00A7FFFFFFFE
${TC11_UE_eUTRA_Capabilities}    C58000308403080E1F87F0FC3F87E1FC3F0FFFFFFFFFC184018080308000

@{PARAMS_IN_SCF}
...    @{CTRLTS-1}
...    @{LANDJ-255}
...    @{LNCEL-1}
...    @{LNCEL-2}
...    @{LNCEL-3}
...    @{LNBTS-1}
...    @{SYNC-1}
...    @{enable_PCMD_REPORT}
...    @{TC03_enable_pcmd_cell3}

@{CTRLTS-1}
...    CTRLTS-1:tceTracePortNum=49150
...    CTRLTS-1:maxUeTraceSessions=60
...    CTRLTS-1:subscriberMDTObtainLocation=false
...    CTRLTS-1:netActIpAddr=1.1.1.1
...    CTRLTS-1:omsTracePortNum=49392
...    CTRLTS-1:extTraceReporting:extCellTraceRep=true
...    CTRLTS-1:extTraceReporting:extUeTraceRep=false
...    CTRLTS-1:traceRepMode:cellTraceRepMode=Offline
...    CTRLTS-1:traceRepMode:ueTraceRepMode=Online
...    CTRLTS-1:vendorSpecTracing:taTracing=false
...    CTRLTS-1/MTRACE-0:tceCellTracePortNum=49150
...    CTRLTS-1/MTRACE-0:actPCMDReporting=true
...    CTRLTS-1/MTRACE-0:actUeThroughputMR=false
...    CTRLTS-1/MTRACE-0:cellMaxActiveUEsTraced=10000
...    CTRLTS-1/MTRACE-0:cellTrcMode=true
...    CTRLTS-1/MTRACE-0:forceUeIdsRepetition=false
...    CTRLTS-1/MTRACE-0:interfaceSelection=NSETAP
...    CTRLTS-1/MTRACE-0:jobType=TraceOnly
...    CTRLTS-1/MTRACE-0:lcrId=1
...    CTRLTS-1/MTRACE-0:maxBufferingTime=2000
...    CTRLTS-1/MTRACE-0:tceIpAddress=10.0.1.1
...    CTRLTS-1/MTRACE-0:traceS1Setting=None
...    CTRLTS-1/MTRACE-0:traceX2Setting=None
...    CTRLTS-1/MTRACE-0:cellVendorSpecTracing:cellTaTracing=false
...    CTRLTS-1/MTRACE-0:eutranTraceId:eutranTraceIdMcc=262
...    CTRLTS-1/MTRACE-0:eutranTraceId:eutranTraceIdMnc=3
...    CTRLTS-1/MTRACE-0:eutranTraceId:eutranTraceIdMncLen=2
...    CTRLTS-1/MTRACE-0:eutranTraceId:traceId=0
...    CTRLTS-1/MTRACE-0:eutranTraceId:trcRecSessionRef=0
...    CTRLTS-1/MTRACE-2:tceCellTracePortNum=49150
...    CTRLTS-1/MTRACE-2:actPCMDReporting=false
...    CTRLTS-1/MTRACE-2:actUeThroughputMR=false
...    CTRLTS-1/MTRACE-2:cellMaxActiveUEsTraced=100000
...    CTRLTS-1/MTRACE-2:cellTrcMode=true
...    CTRLTS-1/MTRACE-2:forceUeIdsRepetition=false
...    CTRLTS-1/MTRACE-2:interfaceSelection=NSNTI
...    CTRLTS-1/MTRACE-2:jobType=TraceOnly
...    CTRLTS-1/MTRACE-2:maxBufferingTime=2000
...    CTRLTS-1/MTRACE-2:tceIpAddress=10.0.1.1
...    CTRLTS-1/MTRACE-2:traceRrcSetting=All
...    CTRLTS-1/MTRACE-2:traceS1Setting=All
...    CTRLTS-1/MTRACE-2:traceX2Setting=All
...    CTRLTS-1/MTRACE-2:lcrId=1
...    CTRLTS-1/MTRACE-2:cellVendorSpecTracing:cellTaTracing=false
...    CTRLTS-1/MTRACE-2:eutranTraceId:eutranTraceIdMcc=262
...    CTRLTS-1/MTRACE-2:eutranTraceId:eutranTraceIdMnc=3
...    CTRLTS-1/MTRACE-2:eutranTraceId:eutranTraceIdMncLen=2
...    CTRLTS-1/MTRACE-2:eutranTraceId:traceId=2
...    CTRLTS-1/MTRACE-2:eutranTraceId:trcRecSessionRef=2

@{LANDJ-255}
...    LNADJ-255:adjEnbId=30
...    LNADJ-255:cPlaneIpAddr=10.0.1.31
...    LNADJ-255:cPlaneIpAddrCtrl=oamControlled
...    LNADJ-255:rlfBasedRCRsupported=false
...    LNADJ-255:plmnId:mcc=262
...    LNADJ-255:plmnId:mnc=3
...    LNADJ-255:plmnId:mncLength=2

@{LNCEL-1}
...    LNCEL-1:hysThreshold2InterFreq=0
...    LNCEL-1:threshold2a=70
...    LNCEL-1:inactivityTimer=300
...    LNCEL-1/SIB-0:t300=2000ms
...    LNCEL-1/SIB-0:t301=2000ms
...    LNCEL-1/LNREL-0:amleAllowed=false
...    LNCEL-1/LNREL-0:cellIndOffNeigh=0dB
...    LNCEL-1/LNREL-0:handoverAllowed=allowed
...    LNCEL-1/LNREL-0:ecgiLcrId=1
...    LNCEL-1/LNREL-0:ecgiAdjEnbId=30
...    LNCEL-1/LNREL-0:nrControl=automatic
...    LNCEL-1/LNREL-0:removeAllowed=true
...    LNCEL-1/LNREL-0:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-0:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-0:ecgiPlmnId:mncLength=2
...    LNCEL-1:phyCellId=1
...    LNCEL-1:tac=33

@{LNCEL-2}
...    LNCEL-2:hysThreshold2InterFreq=0
...    LNCEL-2:inactivityTimer=300
...    LNCEL-2:phyCellId=2
...    LNCEL-2:tac=33

@{LNCEL-3}
...    LNCEL-3:hysThreshold2InterFreq=0
...    LNCEL-3:inactivityTimer=300
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-3/LNHOIF-1:a5ReportIntervalInterFreq=240ms
...    LNCEL-3/LNHOIF-1:a5TimeToTriggerInterFreq=256ms
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-3/LNHOIF-1:offsetFreqInter=0dB
...    LNCEL-3/LNHOIF-1:measurementBandwidth=mbw15
...    LNCEL-3/LNHOIF-1:measQuantInterFreq=rsrp
...    LNCEL-3/LNHOIF-1:interPresAntP=false
...    LNCEL-3/LNHOIF-1:hysThreshold3InterFreq=0
...    LNCEL-3/LNHOIF-1:threshold3InterFreq=24
...    LNCEL-3/LNHOIF-1:threshold3aInterFreq=26
...    LNCEL-3/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL-3/LNHOIF-1:a3OffsetRsrpInterFreqQci1=2
...    LNCEL-3/LNHOIF-1:a3ReportIntervalRsrpInterFreq=240ms
...    LNCEL-3/LNHOIF-1:a3TimeToTriggerRsrpInterFreq=320ms
...    LNCEL-3/LNHOIF-1:thresholdRsrpIFLBFilter=-98
...    LNCEL-3/LNHOIF-1:thresholdRsrqIFLBFilter=-120
...    LNCEL-3/LNHOIF-1:thresholdRsrpIFSBFilter=-98
...    LNCEL-3/LNHOIF-1:thresholdRsrqIFSBFilter=-120
...    LNCEL-3/LNHOIF-1:iFGroupPrio=12
...    LNCEL-3/LNHOIF-1:hysA3OffsetRsrpInterFreq=0
...    LNCEL-3/LNHOIF-1:threshold3InterFreqQci1=20
...    LNCEL-3/LNHOIF-1:threshold3aInterFreqQci1=30
...    LNCEL-3/LNREL-1:amleAllowed=false
...    LNCEL-3/LNREL-1:cellIndOffNeigh=0dB
...    LNCEL-3/LNREL-1:handoverAllowed=onlyS1
...    LNCEL-3/LNREL-1:ecgiLcrId=1
...    LNCEL-3/LNREL-1:ecgiAdjEnbId=30
...    LNCEL-3/LNREL-1:nrControl=automatic
...    LNCEL-3/LNREL-1:removeAllowed=true
...    LNCEL-3/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-3/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-3/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-3:phyCellId=3
...    LNCEL-3:tac=33

@{LNBTS-1}
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1:tS1RelPrepG=5000
...    LNBTS-1:tS1RelPrepU=5000
...    LNBTS-1:tS1RelPrepL=10000
...    LNBTS-1:tX2RelocPrep=10000
...    LNBTS-1:actRedirect=disabled
...    LNBTS-1:actCSFBRedir=Disabled
...    LNBTS-1:actLTES1Ho=true
...    LNBTS-1:actNonGbrServiceDiff=true

@{SYNC-1}
...    SYNC-1:btsSyncMode=PhaseSync
...    SYNC-1/CLOCK-1:syncInputList:syncInputPrio=1
...    SYNC-1/CLOCK-1:syncInputList:syncInputType=1pps/ToD from external GNSS receiver
...    SYNC-1/CLOCK-1/GNSSE-1:actGnssOutputLnaPowerSupply=false
...    SYNC-1/CLOCK-1/GNSSE-1:gnssReceiverHoldoverMode=false
...    SYNC-1/CLOCK-1/GNSSE-1:locationMode=automatic
...    SYNC-1/CLOCK-1/GNSSE-1:gnssCableLength=30m

@{enable_PCMD_REPORT}
...    LNBTS-1:actPCMDReport=true
...    LNBTS-1:actCellTrace=true
       
@{disable_PCMD_REPORT}
...    LNBTS-1:actPCMDReport=false
...    LNBTS-1:actCellTrace=false

@{TC02_inactivityTimer}
...    LNCEL-1:inactivityTimer=10

@{TC02_inactivityTimer_back}
...    LNCEL-1:inactivityTimer=300

@{TC03_enable_pcmd_cell3}
...    CTRLTS-1/MTRACE-1:tceCellTracePortNum=49150
...    CTRLTS-1/MTRACE-1:actPCMDReporting=true
...    CTRLTS-1/MTRACE-1:actUeThroughputMR=false
...    CTRLTS-1/MTRACE-1:cellMaxActiveUEsTraced=10000
...    CTRLTS-1/MTRACE-1:cellTrcMode=true
...    CTRLTS-1/MTRACE-1:forceUeIdsRepetition=false
...    CTRLTS-1/MTRACE-1:interfaceSelection=NSETAP
...    CTRLTS-1/MTRACE-1:jobType=TraceOnly
...    CTRLTS-1/MTRACE-1:lcrId=3
...    CTRLTS-1/MTRACE-1:maxBufferingTime=2000
...    CTRLTS-1/MTRACE-1:tceIpAddress=10.0.1.1
...    CTRLTS-1/MTRACE-1:traceRrcSetting=None
...    CTRLTS-1/MTRACE-1:traceS1Setting=None
...    CTRLTS-1/MTRACE-1:traceX2Setting=None
...    CTRLTS-1/MTRACE-1:cellVendorSpecTracing:cellTaTracing=false
...    CTRLTS-1/MTRACE-1:eutranTraceId:eutranTraceIdMcc=262
...    CTRLTS-1/MTRACE-1:eutranTraceId:eutranTraceIdMnc=3
...    CTRLTS-1/MTRACE-1:eutranTraceId:eutranTraceIdMncLen=2
...    CTRLTS-1/MTRACE-1:eutranTraceId:traceId=1
...    CTRLTS-1/MTRACE-1:eutranTraceId:trcRecSessionRef=1
...    CTRLTS-1/MTRACE-3:tceCellTracePortNum=49150
...    CTRLTS-1/MTRACE-3:actPCMDReporting=false
...    CTRLTS-1/MTRACE-3:actUeThroughputMR=false
...    CTRLTS-1/MTRACE-3:cellMaxActiveUEsTraced=100000
...    CTRLTS-1/MTRACE-3:cellTrcMode=true
...    CTRLTS-1/MTRACE-3:forceUeIdsRepetition=false
...    CTRLTS-1/MTRACE-3:interfaceSelection=NSNTI
...    CTRLTS-1/MTRACE-3:jobType=TraceOnly
...    CTRLTS-1/MTRACE-3:maxBufferingTime=2000
...    CTRLTS-1/MTRACE-3:tceIpAddress=10.0.1.1
...    CTRLTS-1/MTRACE-3:traceRrcSetting=All
...    CTRLTS-1/MTRACE-3:traceS1Setting=All
...    CTRLTS-1/MTRACE-3:traceX2Setting=All
...    CTRLTS-1/MTRACE-3:lcrId=3
...    CTRLTS-1/MTRACE-3:cellVendorSpecTracing:cellTaTracing=false
...    CTRLTS-1/MTRACE-3:eutranTraceId:eutranTraceIdMcc=262
...    CTRLTS-1/MTRACE-3:eutranTraceId:eutranTraceIdMnc=3
...    CTRLTS-1/MTRACE-3:eutranTraceId:eutranTraceIdMncLen=2
...    CTRLTS-1/MTRACE-3:eutranTraceId:traceId=3
...    CTRLTS-1/MTRACE-3:eutranTraceId:trcRecSessionRef=3

@{TC08_ChangesCommissioning_psho_wcdma}
...    LNBTS-1:actHOtoWcdma=true
...    LNBTS-1:tS1RelPrepU=5000
...    LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=All
...    LNCEL-1:a2TimeToTriggerActWcdmaMeas=320ms
...    LNCEL-1:threshold2Wcdma=67
...    LNCEL-1/LNHOW-1:reportIntervalUtra=480ms
...    LNCEL-1/LNHOW-1:maxNumCsfbTargets=16
...    LNCEL-1/LNHOW-1:hysB1ThresholdCSFBUtra=0
...    LNCEL-1/LNHOW-1:hysB2ThresholdUtra=4
...    LNCEL-1/LNHOW-1:b2Threshold1Utra=23
...    LNCEL-1/LNHOW-1:b2TimeToTriggerUtraMeas=320ms
...    LNCEL-1/LNHOW-1:b1TimeToTriggerCSFBUtraMeas=256ms
...    LNCEL-1/LNHOW-1:utraCarrierFreq=10663  #10600 
...    LNCEL-1/LNHOW-1:offsetFreqUtra=0
...    LNCEL-1/LNHOW-1:thresholdEcn0UtranLbFilter=19
...    LNCEL-1/LNHOW-1:thresholdRscpUtranLbFilter=10
...    LNCEL-1/LNHOW-1:b1ThresholdCSFBUtraEcn0=12
...    LNCEL-1/LNHOW-1:b1ThresholdCSFBUtraRscp=5
...    LNCEL-1/LNHOW-1:b2Threshold2UtraEcn0=19
...    LNCEL-1/LNHOW-1:b2Threshold2UtraRscp=10
...    LNCEL-1/LNRELW-1:csfbPsHoAllowed=forbidden
...    LNCEL-1/LNRELW-1:utranLbAllowed=false
...    LNCEL-1/LNRELW-1:nrControl=automatic
...    LNCEL-1/LNRELW-1:psHoAllowed=allowed
...    LNCEL-1/LNRELW-1:redirWithSysInfoAllowed=forbidden
...    LNCEL-1/LNRELW-1:removeAllowed=false
...    LNCEL-1/LNRELW-1:srvccAllowed=forbidden
...    LNCEL-1/LNRELW-1:uTargetCid=2       # 57327
...    LNCEL-1/LNRELW-1:uTargetRncId=12    # 504
...    LNCEL-1/LNRELW-1:plmnId:mcc=262
...    LNCEL-1/LNRELW-1:plmnId:mnc=3
...    LNCEL-1/LNRELW-1:plmnId:mncLength=2
...    LNBTS-1/LNADJW-1:uTargetScFdd=22    # 282
...    LNBTS-1/LNADJW-1:uTargetCid=2       # 57327
...    LNBTS-1/LNADJW-1:uTargetFreq=10663  #10600  
...    LNBTS-1/LNADJW-1:uTargetLac=124     # 34952
...    LNBTS-1/LNADJW-1:uTargetRncId=12    # 504
...    LNBTS-1/LNADJW-1:uTargetRac=111     # 242
...    LNBTS-1/LNADJW-1:srvccHoInd=PSandCS
...    LNBTS-1/LNADJW-1:primaryPlmnId:mcc=262
...    LNBTS-1/LNADJW-1:primaryPlmnId:mnc=3
...    LNBTS-1/LNADJW-1:primaryPlmnId:mncLength=2

@{TC08_ChangesCommissioning_psho_wcdma_back}
...    LNBTS-1:actHOtoWcdma=false
...    LNBTS-1:tS1RelPrepU=500
...    LNBTS-1/LNBTS_FDD-0:preventPsHOtoWcdma=${empty}
...    LNCEL-1:a2TimeToTriggerActWcdmaMeas=${empty}
...    delete:LNADJW-1
...    delete:LNHOW-1
...    delete:LNRELW-1

*** Test Cases ***
CPLN_LTE3333_02_Attach_Release_by_eNB_due_to_inactivity_timer
    [Tags]    QC_341929
    [Setup]    Start TCE And Start To Capture Logs
    Delta Commission Parameters    ${TC02_inactivityTimer}
    UE attach to eNB1    ue_id=2
    sleep    ${TC02_More_Than_InactivityTimer}
    Delta Commission Parameters    ${TC02_inactivityTimer_back}
    Check WireShark Log    ${CURDIR}/a2a/a2a_02.ini    wait_string=UEContextReleaseComplete::3
    [Teardown]    Stop TCE And Stop Capture Logs

CPLN_LTE3333_08_PSHO_to_WCDMA
    [Tags]    QC_341916
    [Setup]    Start TCE And Start To Capture Logs
    Delta Commission Parameters    ${TC08_ChangesCommissioning_psho_wcdma}
    Cells Should Be OnAir
    UE attach to eNB1    ue_id=8
    Trigger PS HO To WCDMA
    Delta Commission Parameters    ${TC08_ChangesCommissioning_psho_wcdma_back}
    Check WireShark Log    ${CURDIR}/a2a/a2a_08.ini    wait_string=UEContextReleaseComplete::3
    [Teardown]    Stop TCE And Stop Capture Logs

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Set ue parameters before ENDC setup
    Create Alias

Set ue parameters before ENDC setup
    execute uex command    ue_param id=1-13 dual_conn=eutra_nr pdcp_sn_extension=18bit
    execute uex command    ue_param id=1-13 nr_supported_bands=7
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    execute egate command    enb_timer T_DC_Overall=5000ms

Create Alias
    FOR    ${ue_id}    IN RANGE    1    9
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
	Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=9    id_type=cus
    Create Enb Alias    alias=Rel_ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    alias=Sim_ENB_2    enb_id=2    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml      EPC/RNC
    ...    - id: 12
    ...    host_enb: 2
    ...    rnc_id: 12
    ...    lac: 124
    ...    plmn: '262:03'
	Update Yaml    EPC/MME_POOL_AREA/1    tac_list: 33,124

    ${rnc_CELL1}    catenate    - {id: 21, technology: utran, rnc: 12, tac: 33, uarfcn: '10663:9713', pci: '7:1', type: FDD,
    ...    shared_plmn_utran: '262:03', cell_identity_utran: 1, rac: 111, earfcn: '1400:19400', eci: '0x0000215', pci_utran: 22}
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...    type: 'simulated'
    ...    plmn: '262:03'
    ...    s1: '10.0.1.31'
    ...    enb_id: '0x00002'
    ...    cells:
    ...       ${rnc_CELL1}
	
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 1, pdn: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31}
    FOR    ${ue_id}     IN RANGE    1    9
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END

Set loadBasedBlockThreshold of ENDC
    [Arguments]    ${parameters}
    Delta Commission Parameters    ${parameters}
    cells should be onair

Start TCE And Start To Capture Logs
    Common Test Setup And Start To Capture Logs
    Start TCE    ${TCE_PORT}

Stop TCE And Stop Capture Logs
    Stop TCE    ${TCE_PORT}
    Common Test Teardown And Stop Capture Logs

Stop TCE And Unlock X2 Link And Stop Capture Logs
    Stop TCE    ${TCE_PORT}
    Unlock X2 Link From eNB30 To eNB1
    Common Test Teardown And Stop Capture Logs

UE attach to eNB1
    [Arguments]    ${ue_id}=2    ${enb_id}=1    ${cell_id}=1
    ${V_1}  catenate
    ...    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} ue_utra_capabilities=${UE_UTRA_Capabilities} enb=${enb_id} cell=${cell_id}
    Execute Uex Command    ${V_1}

Intra LTE HO From eNB1 To eNB30
    [Arguments]    ${ue_id}=${UE1}    ${expect_value}=${EMPTY}
    Execute Uex Command    ue_ho id=${ue_id} enb=30 cell=1 ho_mode=INTRA_LTE    ${expect_value}

Trigger Blind Redirect
    [Arguments]    ${ue_id}=${UE1}    ${meas_id}=${EMPTY}    ${expect_value}=${EMPTY}
    Execute Uex Command    ue_measurement_send id=${ue_id} meas_id=${meas_id} srsrp=20 srsrq=5    ${expect_value}

Trigger Measurement-based Redirect
    Execute Uex Command    ue_measurement_send id=6 meas_id=6 srsrp=30 srsrq=10
    Execute Uex Command  ue_measurement_send id=6 meas_id=16 srsrp=30 srsrq=10 phycell_id=282 nrscp=55
    ...  Unexpected non-CSFB interRAT RRC connection release

Trigger SRVCC To 1xRTT
    Execute Uex Command    bearer_add ue=11 id=3 filter=2 precedence=2    #PGW-initiated Bearer Creation
    Execute Uex Command    bearer_add ue=11 id=2 filter=3 precedence=3    #PGW-initiated Bearer Creation
    Execute Uex Command  srvcc_ue id=11 type=cdma2000 phycellid=1 arfcn=1 srsrp=10 pilot_strength=6 pilot_phase=3333
    ...  UE IS SUSPENDED

#Trigger PSHO To WCDMA
#    [Arguments]    ${ue_id}=8
    #Execute Uex Command    ue_ho id=8 rsrp=15:15 rscp=85:85 cell=1 rnc=12 ho_mode=TO_UTRAN    #== Simulated LTE->UTRAN HO
	Execute Uex Command    ue_ho id=${ue_id} enb=1 cell=1

#Trigger UE PS HO to UTRAN
Trigger Real-LTE eNb1 Cell1 Packet Switch HandOver To UTRAN Sim-WCDMA
Trigger PS HO To WCDMA
    [Arguments]    ${ue_id}=8
    ${release_info}         catenate
    ...    SecondaryRATUsageReportList contains (
    ...    SecondaryRATUsageReport-Item contains (
    ...    (e-RAB-ID eq 5)
    ...    )
    ...    )
    ${S1AP_release_info}         catenate
    ...    SecondaryRATDataUsageReportList contains (
    ...    SecondaryRATDataUsageReportItem contains (
    ...    (e-RAB-ID eq 5)
    ...    )
    ...    )
   Expect Message Flow
    ...    MME_1:S1AP_HandoverRequired (value contains (HandoverType eq "ltetoutran"))
    ...    MME_1:S1AP_HandoverRequest (value contains (HandoverType eq "ltetoutran"))
    ...    MME_1:S1AP_HandoverRequestAcknowledge
    ...    MME_1:S1AP_HandoverCommand (value contains (HandoverType eq "ltetoutran"))
    ...    Rel_ENB_1:X2AP_SgNBReleaseRequest (value contains (Cause contains (radioNetwork eq "mCG-Mobility")))
    ...    UE_GROUP_${ue_id}:RRC_MobilityFromEUTRACommand (handover contains (targetRAT-Type eq "utra"))
    ...    Rel_ENB_1:X2AP_SgNBReleaseRequestAcknowledge
    ...    Rel_ENB_1:X2AP_SecondaryRATDataUsageReport (${release_info})
    ...    MME_1:S1AP_SecondaryRATDataUsageReport (${S1AP_release_info})
    ...    Rel_ENB_1:X2AP_UEContextRelease
    ...    MME_1:S1AP_UEContextReleaseCommand (value contains (Cause contains (radioNetwork eq "successful-handover")))
    ...    MME_1:S1AP_UEContextReleaseComplete
    ...    alias=PSHO_UTRAN_flow    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=0 srsrq=34
    Execute Uex Command    ue_measurement_send id=${ue_id} event=B2_UTRA srsrp=15 srsrq=15 phycell_id=22 necn0=10 nrscp=85 arfcn=10663
    #Flow Occurred As Expected    alias=PSHO_UTRAN_flow

Lock X2 Link From eNB30 To eNB1
    Execute Uex Command    link_lock link=x2 at=enb:30 to=enb:1    #is locked

Unlock X2 Link From eNB30 To eNB1
    Execute Uex Command    link_unlock link=x2 at=enb:30 to=enb:1    #is unlocked
