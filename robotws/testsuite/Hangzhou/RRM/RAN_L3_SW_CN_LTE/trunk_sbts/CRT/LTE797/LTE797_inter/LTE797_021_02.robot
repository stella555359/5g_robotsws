*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_R4LAPO_CUS    CRT
...               DevHZ5_SG4    release-xL18    owner-eric.jiang
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_EARFCN}
...    @{PARAMS_FOR_LNREL}
...    @{PARAMS_FOR_PMQAP}
...    @{PARAMS_FOR_HOIF}
...    @{PARAMS_FOR_A3A5}
...    LNCEL-1:tac=124
...    LNCEL-2:tac=124
...    LNCEL-3:tac=124
...    LNBTS:actEnhAcAndGbrServices=false
...    LNBTS:actFlexQCIARPPMProfiles=true
...    LNBTS:actMultBearers=true
...    LNBTS:actMultGbrBearers=false
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNCEL-1:actNbrForNonGbrBearers=false
...    LNCEL-2:actNbrForNonGbrBearers=false
...    LNCEL-3:actNbrForNonGbrBearers=false
@{PARAMS_FOR_EARFCN}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19600
@{PARAMS_FOR_LNREL}
...    LNCEL-1/LNREL-51:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-51:ecgiLcrId=1
...    LNCEL-1/LNREL-51:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-51:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-51:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-51:removeAllowed=false
...    LNCEL-1/LNREL-51:amleAllowed=false
...    LNCEL-1/LNREL-51:cellIndOffNeigh=0dB
...    LNCEL-1/LNREL-51:handoverAllowed=allowed
...    LNCEL-1/LNREL-51:nrControl=automatic
...    LNCEL-1/LNREL-52:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-52:ecgiLcrId=2
...    LNCEL-1/LNREL-52:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-52:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-52:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-52:removeAllowed=false
...    LNCEL-1/LNREL-52:amleAllowed=false
...    LNCEL-1/LNREL-52:cellIndOffNeigh=0dB
...    LNCEL-1/LNREL-52:handoverAllowed=allowed
...    LNCEL-1/LNREL-52:nrControl=automatic
@{PARAMS_FOR_PMQAP}
...    LNBTS/PMRNL-1/PMQAP-1:cfgQCIRange=1
...    LNBTS/PMRNL-1/PMQAP-1:cfgPRI=20
...    LNBTS/PMRNL-1/PMQAP-5:cfgQCIRange=5
...    LNBTS/PMRNL-1/PMQAP-5:cfgPRI=20
...    LNBTS/PMRNL-1/PMQAP-9:cfgQCIRange=9
...    LNBTS/PMRNL-1/PMQAP-9:cfgPRI=20
...    LNBTS:actRtPerfMonitoring=All_PM_Counters
...    MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=15min
...    LNBTS/PMRNL-1:mtERABPMQAPProfile=15min
...    LNBTS/PMRNL-1:mtDataVolThrPMQAPProfile=15min
...    LNBTS/PMRNL-1:mtActUsersLatencyPMQAPProfile=15min
...    LNBTS/PMRNL-1:mtRLFPMQAPProfile=15min
...    delete:LNBTS/PMRNL-1/PMQAP-1:cfgARPRange
...    delete:LNBTS/PMRNL-1/PMQAP-1:cfgUECategory
...    delete:LNBTS/PMRNL-1/PMQAP-1:pLMNID
...    LNBTS/PMRNL-1/PMQAP-5:cfgARPRange=${EMPTY}
...    LNBTS/PMRNL-1/PMQAP-5:cfgUECategory=${EMPTY}
...    LNBTS/PMRNL-1/PMQAP-5:pLMNID=${EMPTY}
...    LNBTS/PMRNL-1/PMQAP-9:cfgARPRange=${EMPTY}
...    LNBTS/PMRNL-1/PMQAP-9:cfgUECategory=${EMPTY}
...    LNBTS/PMRNL-1/PMQAP-9:pLMNID=${EMPTY}
...    LNBTS:actQCIPLMNIDProfiles=false
@{PARAMS_FOR_HOIF}
...    LNBTS:actIfHo=enabled
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1600
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=300
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=2350
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=4
...    LNCEL-1/LNHOIF-2:a3OffsetRsrpInterFreq=4
...    LNCEL-1/LNHOIF-3:a3OffsetRsrpInterFreq=4
...    LNCEL-1/LNHOIF-1:hysA3OffsetRsrpInterFreq=0
...    LNCEL-1/LNHOIF-2:hysA3OffsetRsrpInterFreq=0
...    LNCEL-1/LNHOIF-3:hysA3OffsetRsrpInterFreq=0
...    LNBTS/MODPR-0:autoAdaptIMLB=false
...    LNBTS/MODPR-0:autoAdapt=true
...    LNCEL-1:threshold2InterFreq=70
...    LNCEL-1:hysThreshold2InterFreq=0
...    LNCEL-1:threshold2InterFreqQci1=70
...    LNCEL-1:threshold2a=80
...    LNCEL-1:hysThreshold2a=0
...    LNCEL-1:threshold2aQci1=80
...    LNCEL-1:threshold1=90
@{PARAMS_FOR_A3A5}
...    LNCEL-1:enableBetterCellHo=true
...    LNCEL-1:a3Offset=4
...    LNCEL-1:hysA3Offset=0
...    LNCEL-1:a3TimeToTrigger=480ms
...    LNCEL-1:a3ReportInterval=240ms
...    LNCEL-1:enableCovHo=true
...    LNCEL-1:threshold3=42
...    LNCEL-1:threshold3a=45
...    LNCEL-1:hysThreshold3=0
...    LNCEL-1:a5TimeToTrigger=480ms
...    LNCEL-1:a5ReportInterval=240ms
@{pm_counters}
...    LNCEL-1:M8009C0=0
...    LNCEL-1:M8009C1=20
...    LNCEL-1:M8009C2=0
...    LNCEL-1:M8009C3=0
...    LNCEL-1:M8009C5=0
...    LNCEL-1:M8009C6=0
...    LNCEL-1:M8009C7=0
...    LNCEL-1:M8009C8=0
...    LNCEL-1:M8014C0=20
...    LNCEL-1:M8014C2=0
...    LNCEL-1:M8014C3=10
...    LNCEL-1:M8014C5=10
...    LNCEL-1:M8014C6=0
...    LNCEL-1:M8014C7=0
...    LNCEL-1:M8014C8=0
...    LNCEL-1:M8021C0=0
...    LNCEL-1:M8021C1=0
...    LNCEL-1:M8021C2=0
...    LNCEL-1:M8021C3=0
...    LNCEL-1:M8021C4=0
...    LNCEL-1:M8021C5=0
...    LNCEL-1:M8021C39=0
...    LNCEL-1:M8021C40=0
...    LNCEL-1:M8014C25=20
...    LNCEL-1:M8014C26=0
...    LNCEL-1:M8014C27=0
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-262/MNC-03:M8015C0=0
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-262/MNC-03:M8015C1=0
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-262/MNC-03:M8015C2=0
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-262/MNC-03:M8015C5=0
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-262/MNC-03:M8015C6=0
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-262/MNC-03:M8015C7=10
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-262/MNC-03:M8015C8=0
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-262/MNC-03:M8015C9=0
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-262/MNC-03:M8015C10=0
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-262/MNC-03:M8015C0=0
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-262/MNC-03:M8015C1=0
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-262/MNC-03:M8015C2=0
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-262/MNC-03:M8015C5=10
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-262/MNC-03:M8015C6=0
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-262/MNC-03:M8015C7=0
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-262/MNC-03:M8015C8=0
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-262/MNC-03:M8015C9=0
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-262/MNC-03:M8015C10=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C9=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C10=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-5:M8048C9=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-5:M8048C10=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-9:M8048C9=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-9:M8048C10=0

*** Test Cases ***
LTE797_021_02_A3 Intra_HO Preparation Failure Due To UE Amount Limit
    [Documentation]    [1][2.0] C-Pln_PMHO Inter eNB HO with failed preparation phase
    ...    A3 handover preparation failed due to max. number of UE threshold exceeded
    [Tags]
    UE2 Attach To Enb2 Cell1 And Add Bearers
    UE1 Attach To Enb1 Cell1 And Add Bearers
    Set X2 Force Reject Ho Req With Cause    failcause=RN_no_radio_resources_available_in_target_cell
    UE1 Attempt Inter Enb Handover To Enb2 Cell1
    Set X2 Force Reject Ho Req With Cause    failcause=RN_cell_not_available
    UE1 Attempt Inter Enb Handover To Enb2 Cell2
    Detach UE1
    Detach UE2
    Check Counters    ${pm_counters}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=2
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    alias=ENB_2    enb_id=2    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on

Modify Yaml
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.31
    ...      s1u: 10.0.1.31
    ...      x2: 10.0.1.31
    ...      x2_peers: 1
    ...      cells:
    ...      - {id: 21, technology: lte, duplex_mode: FDD, tac: 124, pci: '17:0', eci: '0x0000201', earfcn: '1400:19400', bw: 20, status: enabled}
    ...      - {id: 22, technology: lte, duplex_mode: FDD, tac: 124, pci: '17:1', eci: '0x0000202', earfcn: '1400:19400', bw: 20, status: enabled}

UE2 Attach To Enb2 Cell1 And Add Bearers
    Expect Message Flow
    ...    UE_2:RRC_RRCConnectionRequest (rrcConnectionRequest contains (establishmentCause eq "mo-Signalling"))
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupItemCtxtSUReq contains (e-RAB-ID eq 5 and qCI eq 8))
    ...    alias=UE2_Attach   overall_timeout=20
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 1))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 5))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 8 and qCI eq 9))
    ...    alias=UE2_AddBearers   overall_timeout=20
    Execute Uex Command    ue_param id=2 ue_eutra_capabilities=859FF0300308040E1F8BFC3E17F87E2FF0FC5FDFF367A822040088239920
    Execute Uex Command    ue_attach id=2 enb=2 cell=1
    Flow Occurred As Expected    alias=UE2_Attach
    Execute Uex Command    trf_data_start ue=2 dir=dl protocol=udp Mbps=1 qci=8 trf_id=1
    Sleep    3s
    Execute Uex Command    bearer_add ue=2 qci=1 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31
    Execute Uex Command    bearer_add ue=2 qci=5
    Execute Uex Command    bearer_add ue=2 qci=9
    Flow Occurred As Expected    alias=UE2_AddBearers

UE1 Attach To Enb1 Cell1 And Add Bearers
    ${meas_config}=    Catenate
    ...    RRC_RRCConnectionReconfiguration (
    ...        measConfig contains (
    ...            measObjectToAddModList contains (measObjectId eq 1 and carrierFreq eq 1400)
    ...        ) and 
    ...        reportConfigToAddModList contains (
    ...            (reportConfigId eq 1 and eventA3 contains (reportOnLeave eq "FALSE")), 
    ...            (reportConfigId eq 4 and eventA2 contains (a2-Threshold contains (threshold-RSRP eq 70)))
    ...        ) and 
    ...        measIdToAddModList contains (
    ...            (measId eq 1 and measObjectId eq 1 and reportConfigId eq 1),
    ...            (measId eq 7 and measObjectId eq 1 and reportConfigId eq 4)
    ...        )
    ...    )
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionRequest (rrcConnectionRequest contains (establishmentCause eq "mo-Signalling"))
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupItemCtxtSUReq contains (e-RAB-ID eq 5 and qCI eq 8))
    ...    UE_1:${meas_config}
    ...    alias=UE1_Attach   overall_timeout=20    # meas_config message print delay
    ${message}=    Catenate
    ...    RRC_RRCConnectionReconfiguration (
    ...        measConfig contains (
    ...            measObjectToAddModList contains (
    ...                (measObjectId eq 2 and carrierFreq eq 1600),
    ...                (measObjectId eq 3 and carrierFreq eq 300)
    ...            ) and
    ...            reportConfigToAddModList contains (
    ...                (reportConfigId eq 6 and eventA3 contains (reportOnLeave eq "FALSE")),
    ...                (reportConfigId eq 7 and eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 24) and a5-Threshold2
    ...                                                           contains (threshold-RSRP eq 26))),
    ...                (reportConfigId eq 8 and eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 24) and a5-Threshold2
    ...                                                           contains (threshold-RSRP eq 26)))
    ...            )
    ...        )
    ...    )
    Expect Message Flow
    ...    UE_1:${message}
    ...    alias=UE1_ReportA2   overall_timeout=20
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 1))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 5))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 8 and qCI eq 9))
    ...    alias=UE1_AddBearers   overall_timeout=20
    Execute Uex Command    ue_param id=1 ue_eutra_capabilities=859FF0300308040E1F8BFC3E17F87E2FF0FC5FDFF367A822040088239920
    Execute Uex Command    ue_attach id=1 enb=1 cell=1
    Flow Occurred As Expected    alias=UE1_Attach
    Execute Uex Command    trf_data_start ue=1 dir=dl protocol=udp Mbps=1 qci=8 trf_id=1
    Sleep    3s
    Execute Uex Command    ue_measurement_send id=1 event=A2 srsrp=65 srsrq=12 meas_id_blacklist=4 amount=1
    Flow Occurred As Expected    alias=UE1_ReportA2
    Execute Uex Command    bearer_add ue=1 qci=1 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31
    Execute Uex Command    bearer_add ue=1 qci=5
    Execute Uex Command    bearer_add ue=1 qci=9
    Flow Occurred As Expected    alias=UE1_AddBearers

Set X2 Force Reject Ho Req With Cause
    [Arguments]    ${failcause}
    Execute Egate Command    enb_param id=2 x2_force_reject_ho_req_with_cause=${failcause}
    Sleep    3s

UE1 Attempt Inter Enb Handover To Enb2 Cell1
    Expect Message Flow
    ...    ENB_1:X2AP_HandoverRequest (Cause contains (radioNetwork eq "handover-desirable-for-radio-reasons"))
    ...    ENB_2:X2AP_HandoverPreparationFailure (Cause contains (radioNetwork eq "no-radio-resources-available-in-target-cell"))
    ...    alias=UE1_HO   overall_timeout=20
    FOR    ${index}    IN RANGE    0    10
        Execute Uex Command    ue_measurement_send id=1 event=A3 phycell_id=51 srsrp=65 srsrq=20 nrsrp=77 nrsrq=30 meas_id_blacklist=14,16 amount=1
        Flow Occurred As Expected    alias=UE1_HO
        Sleep    2s
    END

UE1 Attempt Inter Enb Handover To Enb2 Cell2
    Expect Message Flow
    ...    ENB_1:X2AP_HandoverRequest (Cause contains (radioNetwork eq "handover-desirable-for-radio-reasons"))
    ...    ENB_2:X2AP_HandoverPreparationFailure (Cause contains (radioNetwork eq "cell-not-available"))
    ...    alias=UE1_HO   overall_timeout=20
    FOR    ${index}    IN RANGE    0    10
        Execute Uex Command    ue_measurement_send id=1 event=A3 phycell_id=52 srsrp=65 srsrq=20 nrsrp=74 nrsrq=30 meas_id_blacklist=14,16 amount=1
        Sleep    2s
        Flow Occurred As Expected    alias=UE1_HO
    END

Detach UE1
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionRelease
    ...    alias=UE1_detach   overall_timeout=20
    Execute Uex Command    trf_data_stop ue=1
    Execute Egate Command    ue_disp id=1
    Execute Uex Command    ue_detach id=1
    sleep    5s
    Flow Occurred As Expected    alias=UE1_detach

Detach UE2
    Expect Message Flow
    ...    UE_2:RRC_RRCConnectionReconfiguration (radioResourceConfigDedicated contains (drb-ToReleaseList contains (2)))
    ...    UE_2:RRC_RRCConnectionReconfiguration (radioResourceConfigDedicated contains (drb-ToReleaseList contains (3)))
    ...    UE_2:RRC_RRCConnectionReconfiguration (radioResourceConfigDedicated contains (drb-ToReleaseList contains (4)))
    ...    UE_2:RRC_RRCConnectionRelease
    ...    alias=UE2_detach   overall_timeout=20
    Execute Uex Command    bearer_del ue=2 qci=1
    Execute Uex Command    bearer_del ue=2 qci=5
    Execute Uex Command    bearer_del ue=2 qci=9
    Execute Uex Command    trf_data_stop ue=2
    Execute Uex Command    ue_detach id=2 wait_for_rrc_conn_release=true
    Flow Occurred As Expected    alias=UE2_detach
