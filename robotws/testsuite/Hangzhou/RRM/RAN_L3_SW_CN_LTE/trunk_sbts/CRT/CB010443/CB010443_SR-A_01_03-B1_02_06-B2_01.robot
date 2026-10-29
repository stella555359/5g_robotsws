*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_R4LAPO_CUS
...               release-SBTS23R4    team-CN3ET    owner-zijing.wu
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${NRARFCN657700}    656736
${TCE_PORT}       49150
${TEnbcRadParamGuardTimerNrActMinCovertToSec}    0x110053
${WRITE_PM_COUNTERS_EVERY_MINUTE}    0x340000
@{PARAMS_IN_SWCONFIG}
...    ${TEnbcRadParamGuardTimerNrActMinCovertToSec}=1
...    ${WRITE_PM_COUNTERS_EVERY_MINUTE}=15

@{PARAMS_IN_SCF}
...    LNBTS:actUeCapEndcHo=true
...    LNBTS:actLteNrDualConnectivity=true
#4193 switch,B1 measurement,trigger blind when disable it
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS:actIfHo=enabled
...    LNBTS:actSelMobPrf=false
...    LNBTS/MODPR-0:autoAdapt=false
...    LNBTS:actMultBearers=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-2/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-3/LNCEL_FDD-0:maxNumQci1Drb=100
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-2/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-3/LNCEL_FDD-0:maxNumActDrb=265
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=5920
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=5920
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1700
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19700
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-1:threshold1=75
...    LNCEL-2:threshold1=76
...    LNCEL-3:threshold1=77
...    LNCEL:loadSettings:cellCapClass=100
...    @{LTE5150_param}
...    @{ENDC_Setup}
...    @{Config_for_CAIMLBP}
...    @{LTE4088}
...    @{LNADJGNB}
...    LNBTS:blockEndcHoRetryAtHoFromTrg=MR-DC based HO
...    @{enable10443}
...    @{CB008745}

@{ENDC_Setup}
...    LNBTS:tLteNrDualConnectPrep=2000
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=100sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=86
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrq=-20
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN657700}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=77
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    delete:LNCEL-2:defaultLnRelGnbCellId
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    delete:LNCEL-3:defaultLnRelGnbCellId
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    delete:LNCEL-1/LNRELGNBCELL-0
...    delete:LNCEL-2/LNRELGNBCELL-0
...    delete:LNCEL-3/LNRELGNBCELL-0

@{LTE5150_param}
...    LNBTS:actEndcHo=enabled
...    LNBTS/MODPR:freqLayEndcHoList:freqLayer=5920
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-2/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-2/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNBTS/MODPR-0:freqLayEndcHoList:freqLayer=5920
...    LNBTS/MOPR-1:freqLayEndcHoList:freqLayer=5920
...    LNCEL-1:moPrMappingList:moPrId=1|spid=1
...    LNCEL-2:moPrMappingList:moPrId=1|spid=1

@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:actEndcSpidFwd=true
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=FR1
...    LNBTS:actTransmittedBelowGap=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS-1:qciTab8:nrPdcpProfIdx=1001
...    LNBTS-1:qciTab8:lteNrDualConnectSupport=EN-DC
...    LNBTS-1:pdcpProf1001:pdcpProfileId=1001
...    LNBTS-1:pdcpProf1001:snSizeDl=18bit
...    LNBTS-1:pdcpProf1001:snSizeUl=18bit
...    LNBTS-1:pdcpProf1001:statusRepReq=0
...    LNBTS-1:pdcpProf1001:tDiscard=300ms

@{LNADJGNB}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNBTS/LNADJGNB-1:x2ToGnbLinkStatus=available

${ue_eutra_capabilities}
...    SEPARATOR=
...    DD9FF430830008081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C1082080304
...    218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B082008284105182083841004142082061040
...    105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B
...    82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71E0002040
...    6080C0E162636383A83F7FC4B5A68190BFCD08750003006D9200004000020973C0600002404061304D0A1E01BFE00000500000030800440002

#modify supportedBandCombinationList from NR258 to NR77
${ue_MRDC_capabilities}
...    SEPARATOR=
...    C10060B71B02004040C18038980000000FD00000000081B8981002060E2680000103F400000000206E360400818103071340000101FA000000
...    0010370B0200E8080000303F400000000206E26040081838040000100FD0000000008100800803004809B00080418000402000100800040202
...    0040088000201000080404008011800040200010080004020200400840002010100200440001008000402020040080

#modify supportbandlist from 258 to 77
${ue_nr_capabilities}
...    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000609B00839F21078004120188004502C28D010CA1A044083A0C30260220B6480A01000C039
...    F2107800412070701101E407800013000009B89BC09024000000120000040900000400A00C0300C0300D802802010040118028030100401004
...    600A0040401180280001180280100C03600A0000360272A6F286F2A2B708DD200808000020C300200002830C00800011041082000064104208
...    000210410809A55334A262B9515DA8AEC4

@{Config_for_CAIMLBP}
...    LNBTS/CAGENB-0/CAIMLBP-2:pcellConfig:earfcnDL=1700
...    LNBTS/CAGENB-0/CAIMLBP-2/IMLBNR-0:nrcellConfigL:b1NrRequired=true
...    LNBTS/CAGENB-0/CAIMLBP-2/IMLBNR-0:nrcellConfigL:band=77

${MonWinForCellSOn}    60
${MonWinForCellSOff}    600
${MonWinForRtxSOn}    100
${MonWinForRtxSOff}    100
@{CB008745}
...    LNBTS:actLbpsCtrlLogicEnh=true
...    PSGRP-1:lbpsLoadCalcMethod=Max(G, W, P)
...    PSGRP-1:lbpsMonWinForCellSOn=${MonWinForCellSOn}
...    PSGRP-1:lbpsMonWinForCellSOff=${MonWinForCellSOff}
...    PSGRP-1:lbpsMonWinForRtxSOn=${MonWinForRtxSOn}
...    PSGRP-1:lbpsMonWinForRtxSOff=${MonWinForRtxSOff}
...    PSGRP-1:lbpsSOnTrRule=MinValueMethod
...    PSGRP-1:lbpsSOffTrRule=MaxValueMethod

${RetryTimer}      1
@{enable10443}
...    LNBTS:actLBPowerSaving=true
...    LNBTS:actLBRTXPowerSaving=false
...    LNBTS:actCoordinated4g5gPowerSaving=cellDeactAndReact
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=1|lnCelId=1
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Sun
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Sun
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Sun
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Sun
...    PSGRP-1:lbpsLastCellSOEnabled=false
...    PSGRP-1:lbpsLastCellMinLoad=0
...    PSGRP-1:lbpsLastCellRTXMinLoad=0
...    PSGRP-1:lbpsMinLoad=0
...    PSGRP-1:lbpsRTXMinLoad=0
...    PSGRP-1:lbpsMaxLoad=1
...    PSGRP-1:lbpsRTXMaxLoad=1
...    PSGRP-1:lbpsCellListNrAct:nrCellId=115969
...    PSGRP-1:lbpsCellListNrAct:mcc=262
...    PSGRP-1:lbpsCellListNrAct:mnc=3
...    PSGRP-1:lbpsMaxLoadNrAct=1
...    PSGRP-1:lbpsMonWinNrAct=1
...    LNBTS:tWaitNrAct=10000
...    PSGRP-1:lbpsGuardTimerNrAct=10
...    PSGRP-1:lbpsRetryTimerNrAct=${RetryTimer}
...    PSGRP-1:lbpsMinNumEndcCapUeNrAct=3
...    LNBTS/SCTP-1:sctpWaitTimeInitSeqRetryX2=240
...    LNBTS/PMRNL-1:mtX2gNBperPsgrp=15min

@{A01_Counters}
...    ${ENDC_CELL_ACT_REQ_PSGRP}=1
...    ${ENDC_CELL_ACT_ACC_PSGRP}=1
...    ${ENDC_CELL_ACT_REJ_PSGRP}=0
@{B106_Counters}
...    ${ENDC_CELL_ACT_REQ_PSGRP}=4
...    ${ENDC_CELL_ACT_ACC_PSGRP}=1
...    ${ENDC_CELL_ACT_REJ_PSGRP}=0
@{B201_Counters}
...    ${ENDC_CELL_ACT_REQ_PSGRP}=2
...    ${ENDC_CELL_ACT_ACC_PSGRP}=1
...    ${ENDC_CELL_ACT_REJ_PSGRP}=1
${ENDC_CELL_ACT_REQ_PSGRP}    M8095C0
${ENDC_CELL_ACT_ACC_PSGRP}    M8095C1
${ENDC_CELL_ACT_REJ_PSGRP}    M8095C2

@{notConcernENDCUE}
...    PSGRP-1:lbpsMinNumEndcCapUeNrAct=0

@{case_B1_02}
...    @{notConcernENDCUE}
...    LNCEL-2/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-2:nrCellId=115972
...    LNCEL-2/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    PSGRP-2:lbpsCellList:lbpsCellSOOrder=1|lnCelId=2
...    PSGRP-2:lbpsLastCellSOEnabled=false
...    PSGRP-2:lbpsLastCellMinLoad=0
...    PSGRP-2:lbpsLastCellRTXMinLoad=0
...    PSGRP-2:lbpsMinLoad=0
...    PSGRP-2:lbpsRTXMinLoad=0
...    PSGRP-2:lbpsMaxLoad=1
...    PSGRP-2:lbpsRTXMaxLoad=1
...    PSGRP-2:lbpsCellListNrAct:nrCellId=115972
...    PSGRP-2:lbpsCellListNrAct:mcc=262
...    PSGRP-2:lbpsCellListNrAct:mnc=3
...    PSGRP-2:lbpsMaxLoadNrAct=1
...    PSGRP-2:lbpsMonWinNrAct=1
...    PSGRP-2:lbpsGuardTimerNrAct=10
...    PSGRP-2:lbpsRetryTimerNrAct=${RetryTimer}
...    PSGRP-2:lbpsMinNumEndcCapUeNrAct=0
...    PSGRP-2:lbpsLoadCalcMethod=Max(G, W, P)
...    PSGRP-2:lbpsMonWinForCellSOn=${MonWinForCellSOn}
...    PSGRP-2:lbpsMonWinForCellSOff=${MonWinForCellSOff}
...    PSGRP-2:lbpsMonWinForRtxSOn=${MonWinForRtxSOn}
...    PSGRP-2:lbpsMonWinForRtxSOff=${MonWinForRtxSOff}
...    PSGRP-2:lbpsSOnTrRule=MinValueMethod
...    PSGRP-2:lbpsSOffTrRule=MaxValueMethod

@{trace_Setup}
...    @{notConcernENDCUE}
...    LNBTS-1:actCellTrace=true
...    LNBTS/CTRLTS-1:extTraceReporting:extCellTraceRep=true
...    LNBTS/CTRLTS-1/MTRACE-1:jobType=TraceOnly
...    LNBTS/CTRLTS-1/MTRACE-1:tceIpAddress=10.0.1.1
...    LNBTS/CTRLTS-1/MTRACE-1:tceCellTracePortNum=49150
...    delete:MTRACE-1:lcrId
...    LNBTS/CTRLTS-1/MTRACE-1:traceRrcSetting=None
...    LNBTS/CTRLTS-1/MTRACE-1:traceS1Setting=None
...    LNBTS/CTRLTS-1/MTRACE-1:traceX2Setting=Specific
...    LNBTS/CTRLTS-1/MTRACE-1:traceX2MsgCategory=nonUEspecific
...    LNBTS/CTRLTS-1/MTRACE-1:traceX2NonUeSpecMsgList=8231,8487,8743
...    LNBTS/CTRLTS-1/MTRACE-1:actUeThroughputMR=false
...    LNBTS/CTRLTS-1/MTRACE-1:interfaceSelection=NSETAP
...    LNBTS/CTRLTS-1/MTRACE-1:cellVendorSpecTracing:cellTaTracing=false

*** Test Cases ***
CB010443-A-B1_ET_01_01_upon load trigger eNB successfully completes EN-DC Cell Activation procedure for coordinated NR cell
    [Tags]
    Clear Counter files
    Notify enb that nrcell is deactived
    Attach two UEs and start traffic for UE1 to make pgload larger than lbpsMaxLoadNrAct
    Attach the third UE and trigger cell activation
    Check Counters    ${A01_Counters}

CB010443-A-B1_ET_01_03_eNB block the LNRELGNBCELL if receive EN-DC Cell Activation Response with mismatch cell id
    [Tags]
    Notify enb that nrcell is deactived and attach one UE
    Set different nrci of the response five times in sequence
    Receive responses with different mismatch cellid and eNB block LNRELGNBCELL everytime
    eNB should not restart activation procedure when LNRELGNBCELL is blocked
    Restart activation procedure and receive normal response and check status

CB010443-B-B1_ET_01_06_eNB will silently ignores the response or failure or error indication message after supervision timer expired
    [Tags]
    Clear Counter files
    Online parameter change    ${notConcernENDCUE}
    Deactive nrcell and attach UE to cell1 and start traffic
    eNB will silently ignores the response message after supervision timer expired
    eNB will silently ignores the failure message after supervision timer expired
    eNB will silently ignores the error indication message after supervision timer expired and fault6330 should not exist
    eNB will restart and complete procedure
    Check Counters    ${B106_Counters}

CB010443-B-B1_ET_01_02_eNB terminates all ongoing NR cell activation procedures towards SgNB when Receive ERROR INDICATION
    [Documentation]    CB010443-B-B1_ET_01_02_eNB terminates all ongoing NR cell activation procedures towards SgNB when
    ...    Receive ERROR INDICATION with Procedure Code = id-endcCellActivation
    [Tags]
    Online parameter change    ${case_B1_02}
    Set responses of two PSGRPs
    Attach UE1 to cell1 and attach UE2 to cell2 and start traffic and eNB should not start activation
    eNB starts activation procedure then receives ErrorIndication and block LNADJGNB
    eNB should not restart activation procedure when LNADJGNB is blocked and fault 6330 should be raised
    Clear block then eNB restart and complete procedure and fault 6330 should be cleared

CB010443-B-B2_ET_01_01_newly added Messages are included in Interface trace content
    [Tags]
    Online parameter change    ${trace_Setup}
    Start TCE    ${TCE_PORT}
    Clear Counter files
    Complete EN-DC cell activation procedure and check three new messages are included in Interface trace content
    Check Counters    ${B201_Counters}
    Stop TCE    ${TCE_PORT}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts

Modify Yaml
    Update Yaml    UEs/UE_sets/1    capability: ${ue_eutra_capabilities}    capability_nr: ${ue_nr_capabilities}
    ...    capability_mrdc: ${ue_MRDC_capabilities}
    Update Yaml    BASE_STATIONS/1/cus_config/1    energy_saving_feature: on

    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1400:19400', bw: 20}
    ...        - {id: 22, technology: lte, tac: 33, pci: '3:1', earfcn: '5920:23920', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '3:2', earfcn: '8770:26770', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...    gnb_id: '0x00007'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.11
    ...    x2_peers: none
    ...    cells:
    ...    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '657700:657700',
    ...    tdd_cell: yes, suggested_band: 77, gscn: 8090}
    ...    - {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x0000504', nr_arfcn: '657700:657700',
    ...    tdd_cell: yes, suggested_band: 77, gscn: 8090}
    ...    - {id: 73, technology: nr , tac: 33, pci: '1:0', nrci: '0x0000507', nr_arfcn: '657700:657700',
    ...    tdd_cell: yes, suggested_band: 77, gscn: 8090}


Online parameter change
    [Arguments]    ${PARAM}
    Delta Commission Parameters    ${PARAM}
    Cells Should Be OnAir

Check currently time and modify parameters under lbpsPeriodList
    [Arguments]    ${Duration}=60
    ${date}    execute command on enb     date
    ${day_of_week}    set variable    ${date.split()[0]}
    ${hour}    set variable    ${date.split()[3].split(":")[0]}
    ${minute}    set variable    ${date.split()[3].split(":")[1]}
    @{Online_Param}    create list
    ...    PSGRP-1:lbpsPeriodList:lbpsDuration=${Duration}|lbpsDayOfWeek=${day_of_week}
    ...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=${hour}|lbpsDayOfWeek=${day_of_week}
    ...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=${minute}|lbpsDayOfWeek=${day_of_week}
    ...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=${day_of_week}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Notify enb that nrcell is deactived
    Check currently time and modify parameters under lbpsPeriodList
    Execute Egate Command    endc_conf_update id=3 target=1 served_nr_cells_to_modify=71:0
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
    Object Should Exist    ${LNRELGNBCELL-judge}

Attach two UEs and start traffic for UE1 to make pgload larger than lbpsMaxLoadNrAct
    ${attachUE1}    catenate    ue_attach id=1 enb=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities}    ue_nr_capabilities=${ue_nr_capabilities}
    Execute Uex Command    ${attachUE1}
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
    Object Should Exist    ${LNRELGNBCELL-judge}
    Execute Uex Command    trf_data_start ue=1 dir=dl protocol=udp Mbps=150 trf_id=1 stats=true
    ${attachUE2}    catenate    ue_attach id=2 enb=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities}    ue_nr_capabilities=${ue_nr_capabilities}
    Execute Uex Command    ${attachUE2}

Set expected message flow
    ${request_query}    catenate
    ...    ServedNRCellsToActivate contains ( nRcellIdentifier eq '0b000000000000000000011100010100000001' )
    ...    and ActivationID eq 0
    ${response_query}    catenate
    ...    ActivatedNRCellList contains ( nRcellIdentifier eq '0b000000000000000000011100010100000001' )
    ...    and ActivationID eq 0
    Expect Message Flow
    ...    ENB_1:X2AP_ENDCCellActivationRequest (${request_query})
    ...    ENB_1:X2AP_ENDCCellActivationResponse (${response_query})
    ...    alias=cellactivate    overall_timeout=${${RetryTimer}*60+10}

Attach the third UE and trigger cell activation
    Set expected message flow
    ${attachUE3}    catenate    ue_attach id=3 enb=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities}    ue_nr_capabilities=${ue_nr_capabilities}
    Execute Uex Command    ${attachUE3}
    Flow Occurred As Expected    alias=cellactivate
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=false    LNCEL-1/LNRELGNBCELL-1:nrStatus=available
    Object Should Exist    ${LNRELGNBCELL-judge}

Set different nrci of the response five times in sequence
    Execute Egate Command    gnb_set_endc_cell_activation_resp id=3 enb=1 result=success nrci=001:03|1281
    Execute Egate Command    gnb_set_endc_cell_activation_resp id=3 enb=1 result=success nrci=262:00|1281
    Execute Egate Command    gnb_set_endc_cell_activation_resp id=3 enb=1 result=success nrci=262:03|3329
    Execute Egate Command    gnb_set_endc_cell_activation_resp id=3 enb=1 result=success nrci=262:003|1281
    Execute Egate Command    gnb_set_endc_cell_activation_resp id=3 enb=1 result=success nrci=262:03|1281

Notify enb that nrcell is deactived and attach one UE
    Online parameter change    ${notConcernENDCUE}
    Execute Egate Command    endc_conf_update id=3 target=1 served_nr_cells_to_modify=71:0
    ${attachUE1}    catenate    ue_attach id=1 enb=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities}    ue_nr_capabilities=${ue_nr_capabilities}
    Execute Uex Command    ${attachUE1}
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
    ...    LNBTS-1/LNADJGNB-1:lbpsblockedNrAct=false    LNCEL-1/LNRELGNBCELL-1:lbpsblockedNrAct=false
    Object Should Exist    ${LNRELGNBCELL-judge}

Start traffic and receive response with mismatch cellid and check LNRELGNBCELL is blocked
    Execute Uex Command    trf_data_start ue=1 dir=dl protocol=udp Mbps=150 trf_id=1 stats=true
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
    ...    LNBTS-1/LNADJGNB-1:lbpsblockedNrAct=false    LNCEL-1/LNRELGNBCELL-1:lbpsblockedNrAct=true
    Object Should Exist    ${LNRELGNBCELL-judge}

Receive response with mismatch cell id and check LNRELGNBCELL is blocked
    Execute Egate Command    endc_conf_update id=3 target=1 served_nr_cells_to_modify=71:0
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
    ...    LNBTS-1/LNADJGNB-1:lbpsblockedNrAct=false    LNCEL-1/LNRELGNBCELL-1:lbpsblockedNrAct=false
    Object Should Exist    ${LNRELGNBCELL-judge}
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
    ...    LNBTS-1/LNADJGNB-1:lbpsblockedNrAct=false    LNCEL-1/LNRELGNBCELL-1:lbpsblockedNrAct=true
    Object Should Exist    ${LNRELGNBCELL-judge}

Receive responses with different mismatch cellid and eNB block LNRELGNBCELL everytime
    Start traffic and receive response with mismatch cellid and check LNRELGNBCELL is blocked
    Receive response with mismatch cell id and check LNRELGNBCELL is blocked
    Receive response with mismatch cell id and check LNRELGNBCELL is blocked
    Receive response with mismatch cell id and check LNRELGNBCELL is blocked

eNB should not restart activation procedure when LNRELGNBCELL is blocked
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_ENDCCellActivationRequest
    ...    alias=NORequest    overall_timeout=${${RetryTimer}*60}
    Flow Not Occurred For Message    alias=NORequest
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
    ...    LNBTS-1/LNADJGNB-1:lbpsblockedNrAct=false    LNCEL-1/LNRELGNBCELL-1:lbpsblockedNrAct=true
    Object Should Exist    ${LNRELGNBCELL-judge}

Restart activation procedure and receive normal response and check status
    Execute Egate Command    endc_conf_update id=3 target=1 served_nr_cells_to_modify=71:0
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=false    LNCEL-1/LNRELGNBCELL-1:nrStatus=available
    ...    LNBTS-1/LNADJGNB-1:lbpsblockedNrAct=false    LNCEL-1/LNRELGNBCELL-1:lbpsblockedNrAct=false
    Object Should Exist    ${LNRELGNBCELL-judge}

Set responses of two PSGRPs
    ${setResp}    catenate    gnb_set_endc_cell_activation_resp id=3 enb=1 result=error_indication
    ...    x2_error_indication_cause=RN_cell_not_available delay=5000
    Execute Egate Command    ${setResp}
    Execute Egate Command    gnb_set_endc_cell_activation_resp id=3 enb=1 result=success delay=7000

Attach UE1 to cell1 and attach UE2 to cell2 and start traffic and eNB should not start activation
    ${attachUE1}    catenate    ue_attach id=1 enb=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities}    ue_nr_capabilities=${ue_nr_capabilities}
    Execute Uex Command    ${attachUE1}
    ${attachUE2}    catenate    ue_attach id=2 enb=1 cell=2 ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities}    ue_nr_capabilities=${ue_nr_capabilities}
    Execute Uex Command    ${attachUE2}
    sleep    5    #wait UEs normal
    Execute Uex Command    trf_data_start ue=1 dir=dl protocol=udp Mbps=150 trf_id=1 stats=true
    Execute Uex Command    trf_data_start ue=2 dir=dl protocol=udp Mbps=150 trf_id=1 stats=true
    Check that enb does not send request

Check that enb does not send request
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_ENDCCellActivationRequest
    ...    alias=NORequest    overall_timeout=${${RetryTimer}*60}
    Flow Not Occurred For Message    alias=NORequest

eNB starts activation procedure then receives ErrorIndication and block LNADJGNB
    Set expected error message flow
    Execute Egate Command    endc_conf_update id=3 target=1 served_nr_cells_to_modify=71:0,72:0
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
    ...    LNCEL-2/LNRELGNBCELL-2:pwSavingDeactInd=true    LNCEL-2/LNRELGNBCELL-2:nrStatus=unavailable
    ...    LNBTS-1/LNADJGNB-1:lbpsblockedNrAct=true    LNCEL-1/LNRELGNBCELL-1:lbpsblockedNrAct=false
    ...    LNCEL-2/LNRELGNBCELL-2:lbpsblockedNrAct=false
    Object Should Exist    ${LNRELGNBCELL-judge}
    Flow Occurred As Expected    alias=error

Set expected error message flow
    ${error_query}    catenate
    ...    Cause contains ( radioNetwork eq 'cell-not-available' )
    ...    and CriticalityDiagnostics contains ( procedureCode eq 39 )
    Expect Message Flow
    ...    ENB_1:X2AP_ENDCCellActivationRequest (nRcellIdentifier eq '0b000000000000000000011100010100000001')
    ...    ENB_1:X2AP_ErrorIndication (${error_query})
    ...    alias=error    overall_timeout=${${RetryTimer}*60+20}

eNB should not restart activation procedure when LNADJGNB is blocked and fault 6330 should be raised
    Expect Message Will Not Occur
    ...    ENB_1:X2AP_ENDCCellActivationRequest
    ...    alias=NORequest    overall_timeout=${${RetryTimer}*60}
    Flow Not Occurred For Message    alias=NORequest
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
    ...    LNCEL-2/LNRELGNBCELL-2:pwSavingDeactInd=true    LNCEL-2/LNRELGNBCELL-2:nrStatus=unavailable
    ...    LNBTS-1/LNADJGNB-1:lbpsblockedNrAct=true    LNCEL-1/LNRELGNBCELL-1:lbpsblockedNrAct=false
    ...    LNCEL-2/LNRELGNBCELL-2:lbpsblockedNrAct=false
    Object Should Exist    ${LNRELGNBCELL-judge}
    Check fault 6330 should be raised

Check fault 6330 should be raised
    ${fault6330}    create list    Severity=minor    fault_id=6330    fault_name=EN-DC Cell Activation Procedure not supported by target en-gNB
    ...    alarm_id=7115    alarm_name=BASE STATION INFORMATION
    FM Fault Should Be Raised    ${fault6330}

Clear block then eNB restart and complete procedure and fault 6330 should be cleared
    Set expected response message flow of PSGRP-1
    Set expected response message flow of PSGRP-2
    Execute Egate Command    endc_conf_update id=3 target=1 served_nr_cells_to_modify=71:0,72:0
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=false    LNCEL-1/LNRELGNBCELL-1:nrStatus=available
    ...    LNCEL-2/LNRELGNBCELL-2:pwSavingDeactInd=false    LNCEL-2/LNRELGNBCELL-2:nrStatus=available
    ...    LNBTS-1/LNADJGNB-1:lbpsblockedNrAct=false    LNCEL-1/LNRELGNBCELL-1:lbpsblockedNrAct=false
    ...    LNCEL-2/LNRELGNBCELL-2:lbpsblockedNrAct=false
    Object Should Exist    ${LNRELGNBCELL-judge}
    Flow Occurred As Expected    alias=cellactivate_1
    Flow Occurred As Expected    alias=cellactivate_2
    FM Fault Should Be Cleared    fault_id=6330

Set expected response message flow of PSGRP-1
    ${request_query1}    catenate
    ...    ServedNRCellsToActivate contains ( nRcellIdentifier eq '0b000000000000000000011100010100000001' )
    ${response_query1}    catenate
    ...    ActivatedNRCellList contains ( nRcellIdentifier eq '0b000000000000000000011100010100000001' )
    Expect Message Flow
    ...    ENB_1:X2AP_ENDCCellActivationRequest (${request_query1})
    ...    ENB_1:X2AP_ENDCCellActivationResponse (${response_query1})
    ...    alias=cellactivate_1    overall_timeout=${${RetryTimer}*60+20}

Set expected response message flow of PSGRP-2
    ${request_query2}    catenate
    ...    ServedNRCellsToActivate contains ( nRcellIdentifier eq '0b000000000000000000011100010100000100' )
    ${response_query2}    catenate
    ...    ActivatedNRCellList contains ( nRcellIdentifier eq '0b000000000000000000011100010100000100' )
    Expect Message Flow
    ...    ENB_1:X2AP_ENDCCellActivationRequest (${request_query2})
    ...    ENB_1:X2AP_ENDCCellActivationResponse (${response_query2})
    ...    alias=cellactivate_2    overall_timeout=${${RetryTimer}*60+20}


Deactive nrcell and attach UE to cell1 and start traffic
    Execute Egate Command    endc_conf_update id=3 target=1 served_nr_cells_to_modify=71:0
    ${attachUE1}    catenate    ue_attach id=1 enb=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_MRDC_capabilities}    ue_nr_capabilities=${ue_nr_capabilities}
    Execute Uex Command    ${attachUE1}
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
    Object Should Exist    ${LNRELGNBCELL-judge}
    Execute Uex Command    trf_data_start ue=1 dir=dl protocol=udp Mbps=150 trf_id=1 stats=true

eNB will silently ignores the response message after supervision timer expired
    Execute Egate Command    gnb_set_endc_cell_activation_resp id=3 enb=1 result=success delay=11000
    Expect Message Flow
    ...    ENB_1:X2AP_ENDCCellActivationRequest
    ...    ENB_1:X2AP_ENDCCellActivationResponse
    ...    alias=ignoreresponse    overall_timeout=${${RetryTimer}*60+20}
    Flow Occurred As Expected    alias=ignoreresponse
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
    ...    LNBTS-1/LNADJGNB-1:lbpsblockedNrAct=false    LNCEL-1/LNRELGNBCELL-1:lbpsblockedNrAct=false
    Object Should Exist    ${LNRELGNBCELL-judge}

eNB will silently ignores the failure message after supervision timer expired
    Execute Egate Command    gnb_set_endc_cell_activation_resp id=3 enb=1 result=failure x2_cause_rnl=target_not_allowed delay=11000
    Expect Message Flow
    ...    ENB_1:X2AP_ENDCCellActivationRequest
    ...    ENB_1:X2AP_ENDCCellActivationFailure
    ...    alias=ignorefail    overall_timeout=${${RetryTimer}*60}
    Flow Occurred As Expected    alias=ignorefail
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
    ...    LNBTS-1/LNADJGNB-1:lbpsblockedNrAct=false    LNCEL-1/LNRELGNBCELL-1:lbpsblockedNrAct=false
    Object Should Exist    ${LNRELGNBCELL-judge}

eNB will silently ignores the error indication message after supervision timer expired and fault6330 should not exist
    ${setresp}    catenate    gnb_set_endc_cell_activation_resp id=3 enb=1 result=error_indication
    ...    x2_error_indication_cause=RN_unknown_MME_Code delay=11000
    Execute Egate Command    ${setresp}
    Expect Message Flow
    ...    ENB_1:X2AP_ENDCCellActivationRequest
    ...    ENB_1:X2AP_ErrorIndication (CriticalityDiagnostics contains ( procedureCode eq 39 ))
    ...    alias=ignoreerr    overall_timeout=${${RetryTimer}*60}
    Flow Occurred As Expected    alias=ignoreerr
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=true    LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable
    ...    LNBTS-1/LNADJGNB-1:lbpsblockedNrAct=false    LNCEL-1/LNRELGNBCELL-1:lbpsblockedNrAct=false
    Object Should Exist    ${LNRELGNBCELL-judge}
    Check fault6330 not exist

Check fault6330 not exist
    ${fault6330}    create list    Severity=minor    fault_id=6330    fault_name=EN-DC Cell Activation Procedure not supported by target en-gNB
    ...    alarm_id=7115    alarm_name=BASE STATION INFORMATION
    FM Fault Should Not Exist    ${fault6330}

eNB will restart and complete procedure
    Expect Message Flow
    ...    ENB_1:X2AP_ENDCCellActivationRequest
    ...    ENB_1:X2AP_ENDCCellActivationResponse
    ...    alias=response    overall_timeout=${${RetryTimer}*60}
    Flow Occurred As Expected    alias=response
    @{LNRELGNBCELL-judge}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=false    LNCEL-1/LNRELGNBCELL-1:nrStatus=available
    ...    LNBTS-1/LNADJGNB-1:lbpsblockedNrAct=false    LNCEL-1/LNRELGNBCELL-1:lbpsblockedNrAct=false
    Object Should Exist    ${LNRELGNBCELL-judge}

Complete EN-DC cell activation procedure and check three new messages are included in Interface trace content
    Execute Egate Command    gnb_set_endc_cell_activation_resp id=3 enb=1 result=failure x2_cause_rnl=target_not_allowed
    Deactive nrcell and attach UE to cell1 and start traffic
    @{LNRELGNBCELL-judge-2}    Create List    LNCEL-1/LNRELGNBCELL-1:pwSavingDeactInd=false    LNCEL-1/LNRELGNBCELL-1:nrStatus=available
    ...    LNBTS-1/LNADJGNB-1:lbpsblockedNrAct=false    LNCEL-1/LNRELGNBCELL-1:lbpsblockedNrAct=false
    Object Should Exist    ${LNRELGNBCELL-judge-2}    timeout=${${RetryTimer}*2*60+30}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB010443-B2_01${/}a2a.ini    wait_string=UEContextReleaseComplete::2
