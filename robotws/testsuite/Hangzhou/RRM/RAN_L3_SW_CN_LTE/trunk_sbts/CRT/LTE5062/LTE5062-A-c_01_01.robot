*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Stop TCE and Common Suite Teardown
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS    release-TL19
...               DevHZ5_SG5    owner-jiangping.cao
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS-1:actMDTCellTrace=true
...    LNBTS-1:actCellTrace=true
...    LNBTS-1:actInterFreqMDTCellTrace=true
...    @{CTRLTS}
...    @{LTRACE}
...    LNBTS/CTRLTS-1/MTRACE-1:jobType=ImmediateMDTAndTrace
...    LNBTS/CTRLTS-1/MTRACE-1:cellMaxActiveUEsTraced=5
...    LNBTS/CTRLTS-1/MTRACE-1:iFMDTList:measBW=mbw50|iFFreqEARFCN=38050
...    LNBTS/CTRLTS-1/MTRACE-1:iFMDTList:measBW=mbw50|iFFreqEARFCN=38100
...    LNBTS/CTRLTS-1/MTRACE-1:iFMDTList:measBW=mbw50|iFFreqEARFCN=38150
...    LNBTS/CTRLTS-1/MTRACE-1:iFMDTList:measBW=mbw50|iFFreqEARFCN=38200
...    LNBTS/CTRLTS-1/MTRACE-1:tceIpAddress=10.0.1.1
...    LNBTS/CTRLTS-1/MTRACE-1:tceCellTracePortNum=49150
...    LNBTS/CTRLTS-1/MTRACE-1:lcrId=1
...    @{immedMDTControl}
...    @{periodicUeMeas}
...    @{X2LINK}
@{immedMDTControl}
...    MTRACE-1:immedMDTControl:cellMaxActiveMDTUEsTraced=1
...    MTRACE-1:immedMDTControl:iFMDTPercentage=1
...    MTRACE-1:immedMDTControl:immedMDTForceUEConsent=true
...    MTRACE-1:immedMDTControl:immedMDTAnonymization=IMEI-TAC
...    MTRACE-1:immedMDTControl:immedMDTObtainLocation=false
...    MTRACE-1:immedMDTControl:immedMDTSelectOnlyGNSSUes=false
...    MTRACE-1:immedMDTControl:immedMDTPosMethod=GNSS
...    MTRACE-1:immedMDTControl:cellMaxActiveMDTUEsTraced=5
...    MTRACE-1:immedMDTControl:maxMDTFreqLayers=3
@{CTRLTS}
...    LNBTS-1/CTRLTS-1:extTraceReporting:extCellTraceRep=true
...    LNBTS-1/CTRLTS-1:extTraceReporting:extUeTraceRep=true
...    LNBTS-1/CTRLTS-1:traceRepMode:cellTraceRepMode=Online
...    LNBTS-1/CTRLTS-1:traceRepMode:ueTraceRepMode=Online
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedPortNum=49150
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEId=3
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEIP=192.168.255.129
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEmcc=262
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEmnc=3
...    LNBTS-1/CTRLTS-1:tceIdLogMdtIpMap:loggedTCEmncLen=2
...    LNBTS-1/CTRLTS-1:vendorSpecTracing:taTracing=false
...    LNBTS-1/CTRLTS-1:maxUeTraceSessions=60
...    LNBTS-1/CTRLTS-1:netActIpAddr=0.0.0.0
...    LNBTS-1/CTRLTS-1:omsTracePortNum=49392
...    LNBTS-1/CTRLTS-1:subscriberMDTObtainLocation=false
...    LNBTS-1/CTRLTS-1:tceTracePortNum=49150
@{LTRACE}
...    LTRACE-1:enableLoggedMdtTRSStartStopInd=true
...    LTRACE-1:loggedCellConf:lcrId=1
...    LTRACE-1:loggedCellConf:mode=configureAndRetrieveDataFromUEs
...    LTRACE-1:loggedMDTConf:anonymizationMDTdata=No identity
...    LTRACE-1:loggedMDTConf:forceUEconsent=true
...    LTRACE-1:loggedMDTConf:loggedTCEId=2
...    LTRACE-1:loggedMDTConf:loggingDuration=10
...    LTRACE-1:loggedMDTConf:loggingInterval=20480
...    LTRACE-1:loggedMDTConf:selectOnlyStandaloneGNSSUes=true
...    LTRACE-1:plmnPerTAlist:mdtperTAmcc=3
...    LTRACE-1:plmnPerTAlist:mdtperTAmnc=99
...    LTRACE-1:plmnPerTAlist:mdtPerTAmncLen=3
...    LTRACE-1:traceReference:traceId=3
...    LTRACE-1:traceReference:traceReferenceMcc=262
...    LTRACE-1:traceReference:traceReferenceMnc=3
...    LTRACE-1:traceReference:traceReferenceMncLen=2
@{periodicUeMeas}
...    MTRACE-1:periodicUeMeas:reportAmount=${MDT_RSC_reportAmount}
...    MTRACE-1:periodicUeMeas:reportInterval=${MDT_RSC_reportInterval}ms
${MDT_RSC_reportAmount}    4
${MDT_RSC_reportInterval}    5120
@{X2LINK}
...    LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNADJ-1:cPlaneIpAddr=10.0.1.32
...    MODPR-0:autoAdapt=true
${MEASID_IF_RSC_SECOND}    15
${V_1}
...    SEPARATOR=
...    D59FF420346504070380FFFFFFFFFC0000802000000098A006A28403A0000303A0000207A00000680003D00000340081E800009A001ABE4000
...    028801090002A800101100EE80
${V_2}
...    SEPARATOR=
...    D59FF420346504070380FFFFFFFFFC0000802000000098A006A28403A0000303A0000207A00000680003D00000340081E800009A001ABE4000
...    028801090002A800101100EE80
${V_3}
...    SEPARATOR=
...    D59FF420346504070380FFFFFFFFFC0000802000000098A006A28403A0000303A0000207A00000680003D00000340081E800009A001ABE4000
...    028801090002A800101100EE80
${V_4}
...    SEPARATOR=
...    D59FF420346504070380FFFFFFFFFC0000802000000098A006A28403A0000303A0000207A00000680003D00000340081E800009A001ABE4000
...    028801090002A800101100EE80
${TCE_PORT}       49150


*** Test Cases ***
LTE5062-A-c_01_01 Select inter-freq Layer for MDT include RRC Connection setup and handover and re-establishment enter the cell
    [Documentation]    case name was:[LTE5062-A-c_01_01 Select inter-freq Layer for MDT include RRC Connection setup and handover and
    ...    re-establishment enter the cell when Job type set ImmediateMDTAndTrace] checkpoints:
    ...    1.UEs measure intra-freq and one inter-freq layer from in iFMDTList : The inter-frequency selection is based on iFMDTList.
    ...      UE1 measures intra-freq and the freq layers from first entry in iFMDTList.
    ...      UE2 measures intra-freq and the freq layers from second entry in iFMDTList.
    ...      UE3 measures intra-freq and the freq layers from first entry in iFMDTList
    ...    2.Handover will trigger MDT
    ...    3.Handover failure then reestablish to the target cell will trigger MDT
    [Tags]    RAN_4G    RAN_4G_TDD    CDRT
    Start TCE and Wait
    Attach UE1-2 on eNB1 Cell1
    Attach UE3-4 on eNB1 Cell2
    UE3 handover from eNB1 Cell2 to eNB1 Cell1
    Trigger the UE4 reestablish to source eNB due HO handover from eNB1 cell1 to eNB2 cell1 Failure

*** Keyword ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=100
    Create UE Alias for multi UEs
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts

Create UE Alias for multi UEs
    FOR    ${ue_id}    IN RANGE    1    51
       Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END

Modify Yaml
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1: 10.0.1.32
    ...    x2: 10.0.1.32
    ...    cells:
    ...       - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1400:19400', bw: 20}
    ...       - {id: 22, technology: lte, tac: 33, pci: '3:1', earfcn: '1400:19400', bw: 20}
    ...       - {id: 23, technology: lte, tac: 33, pci: '3:2', earfcn: '1400:19400', bw: 20}

Start TCE and Wait
    Start TCE    ${tceport}
    Sleep    120    #wait PCMD trace session to establish

Attach UE1-2 on eNB1 Cell1
    ${UE1_attach_info}         catenate
    ...    measObjectToAddModList contains (
    ...    (measObjectId eq 1) and (measObjectEUTRA contains (carrierFreq eq 38000)),
    ...    (measObjectId eq 2) and (measObjectEUTRA contains (carrierFreq eq 38050)),
    ...    (measObjectId eq 3) and (measObjectEUTRA contains (carrierFreq eq 38100))
    ...    )  and
    ...    reportConfigToAddModList contains (
    ...    triggerType contains (purpose eq 'reportStrongestCells') and
    ...    (reportInterval eq 'ms5120') and
    ...    (reportAmount eq 'r4')
    ...    ) and
    ...    measIdToAddModList  contains  (
    ...    measId eq 9,
    ...    measId eq 14,
    ...    measId eq 15
    ...    )
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${UE1_attach_info})
    ...    UE_1:RRC_MeasurementReport (measId eq 9)
    ...    UE_1:RRC_MeasurementReport (measId eq 14)
    ...    UE_1:RRC_MeasurementReport (measId eq 15)
    ...    alias=UE1_attach_flow    overall_timeout=20
    set RSC auto report    ue_id=1
    Execute Uex Command    ue_attach id=1 ue_eutra_capabilities=${V_1} cell=1
    Flow Occurred As Expected    alias=UE1_attach_flow
    ${UE2_attach_info}         catenate
    ...    measObjectToAddModList contains (
    ...    (measObjectId eq 1) and (measObjectEUTRA contains (carrierFreq eq 38000)),
    ...    (measObjectId eq 2) and (measObjectEUTRA contains (carrierFreq eq 38150)),
    ...    (measObjectId eq 3) and (measObjectEUTRA contains (carrierFreq eq 38200))
    ...    )  and
    ...    reportConfigToAddModList contains (
    ...    triggerType contains (purpose eq 'reportStrongestCells') and
    ...    (reportInterval eq 'ms5120') and
    ...    (reportAmount eq 'r4')
    ...    )  and
    ...    measIdToAddModList  contains (
    ...    measId eq 9,
    ...    measId eq 14,
    ...    measId eq 15
    ...    )
    Expect Message Flow
    ...    UE_2:RRC_RRCConnectionReconfiguration (${UE2_attach_info})
    ...    UE_2:RRC_MeasurementReport (measId eq 9)
    ...    UE_2:RRC_MeasurementReport (measId eq 14)
    ...    UE_2:RRC_MeasurementReport (measId eq 15)
    ...    alias=UE2_attach_flow    overall_timeout=20
    set RSC auto report    ue_id=2
    Execute Uex Command    ue_attach id=2 ue_eutra_capabilities=${V_2} cell=1
    Flow Occurred As Expected    alias=UE2_attach_flow

Set RSC auto report
    [Arguments]    ${ue_id}=1    ${nrsrp}=56    ${nrsrq}=34    ${pci}=3
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send
    ...    phycell_id=${pci} narfcn=38000 nrsrp=${nrsrp} nrsrq=${nrsrq} srsrp=0 srsrq=0 nsinr=31 strongest=true     #strongest=eutra
    Run Uex Command    ${cmd}

Attach UE3-4 on eNB1 Cell2
    Execute Uex Command    ue_attach id=3 ue_eutra_capabilities=${V_3} cell=2
    Execute Uex Command    ue_attach id=4 ue_eutra_capabilities=${V_4} cell=2


UE3 handover from eNB1 Cell2 to eNB1 Cell1
    ${UE3_ho_info}         catenate
    ...    measObjectToAddModList contains (
    ...    (measObjectEUTRA contains (carrierFreq eq 38050)),
    ...    (measObjectEUTRA contains (carrierFreq eq 38100))
    ...    )  and
    ...    reportConfigToAddModList contains (
    ...    triggerType contains (purpose eq 'reportStrongestCells') and
    ...    (reportInterval eq 'ms5120') and
    ...    (reportAmount eq 'r4')
    ...    ) and
    ...    measIdToAddModList  contains  (
    ...    measId eq 9,
    ...    measId eq 14,
    ...    measId eq 15
    ...    )
    Expect Message Flow
    ...    UE_3:RRC_RRCConnectionReconfiguration
    ...    UE_3:RRC_RRCConnectionReconfiguration
    ...    UE_3:RRC_RRCConnectionReconfiguration (${UE3_ho_info})
    ...    UE_3:RRC_MeasurementReport (measId eq 9)
    ...    UE_3:RRC_MeasurementReport (measId eq 14)
    ...    UE_3:RRC_MeasurementReport (measId eq 15)
    ...    alias=UE3_HO_flow    overall_timeout=20
    set RSC auto report    ue_id=3
    Execute Uex Command    ue_ho id=3 enb=1 cell=1
    Flow Occurred As Expected    alias=UE3_HO_flow

Trigger the UE4 reestablish to source eNB due HO handover from eNB1 cell1 to eNB2 cell1 Failure
    ${UE4_RCR_info}         catenate
    ...    measObjectToAddModList contains (
    ...    (measObjectEUTRA contains (carrierFreq eq 38150)),
    ...    (measObjectEUTRA contains (carrierFreq eq 38200))
    ...    )  and
    ...    reportConfigToAddModList contains (
    ...    triggerType contains (purpose eq 'reportStrongestCells') and
    ...    (reportInterval eq 'ms5120') and
    ...    (reportAmount eq 'r4')
    ...    )  and
    ...    measIdToAddModList  contains (
    ...    measId eq 9,
    ...    measId eq 14,
    ...    measId eq 15
    ...    )
    Expect Message Flow
    ...    UE_4:RRC_RRCConnectionReconfiguration
    ...    UE_4:RRC_RRCConnectionReconfiguration
    ...    UE_4:RRC_RRCConnectionReconfiguration (${UE4_RCR_info})
    ...    UE_4:RRC_MeasurementReport (measId eq 9)
    ...    UE_4:RRC_MeasurementReport (measId eq 14)
    ...    UE_4:RRC_MeasurementReport (measId eq 15)
    ...    alias=UE4_RCR_flow    overall_timeout=20
    set RSC auto report    ue_id=4

    Execute Uex Command
    ...    ue_rrc_reconf_param id=4 if_contains=targetPhysCellId with_value=1 action=reestablish cause=otherFailure cell=1 nth=1
#     Execute Uex Command    ue_measurement_send id=4 event=A2 srsrp=50
     Execute Uex Command    ue_measurement_send id=4 event=A3 phycell_id=1 nrsrp=90 nrsrq=34 srsrp=60
#    Execute Uex Command    ue_ho id=4 enb=1 cell=1
    Flow Occurred As Expected    alias=UE4_RCR_flow


Stop TCE and Common Suite Teardown
    Stop TCE
    Common Suite Teardown And Restore BTS Configuration Parameters
