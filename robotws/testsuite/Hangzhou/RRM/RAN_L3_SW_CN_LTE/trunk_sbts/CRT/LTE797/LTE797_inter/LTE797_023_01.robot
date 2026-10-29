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
...    @{PARAMS_FOR_LTE4_MOCN}
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
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19400
@{PARAMS_FOR_LNREL}
...    LNCEL-1/LNREL-51:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-51:ecgiLcrId=1
...    LNCEL-1/LNREL-51:ecgiPlmnId:mcc=263
...    LNCEL-1/LNREL-51:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-51:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-51:removeAllowed=false
...    LNCEL-1/LNREL-51:amleAllowed=false
...    LNCEL-1/LNREL-51:cellIndOffNeigh=0dB
...    LNCEL-1/LNREL-51:handoverAllowed=onlyS1
...    LNCEL-1/LNREL-51:nrControl=automatic
...    LNCEL-1/LNREL-52:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-52:ecgiLcrId=2
...    LNCEL-1/LNREL-52:ecgiPlmnId:mcc=263
...    LNCEL-1/LNREL-52:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-52:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-52:removeAllowed=false
...    LNCEL-1/LNREL-52:amleAllowed=false
...    LNCEL-1/LNREL-52:cellIndOffNeigh=0dB
...    LNCEL-1/LNREL-52:handoverAllowed=onlyS1
...    LNCEL-1/LNREL-52:nrControl=automatic
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNREL-1:amleAllowed=false
...    LNCEL-1/LNREL-1:cellIndOffNeigh=0dB
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNREL-1:nrControl=automatic
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=3
...    LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-1/LNREL-2:amleAllowed=false
...    LNCEL-1/LNREL-2:cellIndOffNeigh=0dB
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:nrControl=automatic
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
@{PARAMS_FOR_LTE4_MOCN}
...    LNBTS:actS1Flex=enabled
...    LNBTS:mcc=262
...    LNBTS:mnc=3
...    LNBTS:mncLength=2
@{pm_counters}
...    LNCEL-1:M8006C0=4
...    LNCEL-1:M8006C1=4
...    LNCEL-1:M8006C6=0
...    LNCEL-1:M8006C7=0
...    LNCEL-1:M8006C8=0
...    LNCEL-1:M8006C9=0
...    LNCEL-1:M8006C89=0
...    LNCEL-1:M8006C98=0
...    LNCEL-1:M8006C107=0
...    LNCEL-1:M8006C116=0
...    LNCEL-1:M8007C0=4
...    LNCEL-1:M8007C1=4
...    LNCEL-1:M8007C2=0
...    LNCEL-1:M8007C4=0
...    LNCEL-1:M8007C7=1
...    LNCEL-1:M8007C8=1
...    LNCEL-1:M8007C9=0
...    LNCEL-1:M8007C10=1
...    LNCEL-1:M8007C11=1
...    LNCEL-1:M8007C12=0
...    LNCEL-1:M8009C0=1
...    LNCEL-1:M8009C1=2
...    LNCEL-1:M8009C2=0
...    LNCEL-1:M8009C3=0
...    LNCEL-1:M8009C5=0
...    LNCEL-1:M8009C6=0
...    LNCEL-1:M8009C7=0
...    LNCEL-1:M8009C8=0
...    LNCEL-1:M8014C0=0
...    LNCEL-1:M8014C2=0
...    LNCEL-1:M8014C3=0
...    LNCEL-1:M8014C5=0
...    LNCEL-1:M8014C6=0
...    LNCEL-1:M8014C7=0
...    LNCEL-1:M8014C8=0
...    LNCEL-1:M8014C14=2
...    LNCEL-1:M8014C15=0
...    LNCEL-1:M8014C16=0
...    LNCEL-1:M8014C17=1
...    LNCEL-1:M8014C18=1
...    LNCEL-1:M8014C19=1
...    LNCEL-1:M8014C20=0
...    LNCEL-1:M8021C0=1
...    LNCEL-1:M8021C1=1
...    LNCEL-1:M8021C2=1
...    LNCEL-1:M8021C3=1
...    LNCEL-1:M8021C4=0
...    LNCEL-1:M8021C5=0
...    LNCEL-1:M8021C37=1
...    LNCEL-1:M8021C38=1
...    LNCEL-1:M8021C39=1
...    LNCEL-1:M8021C40=1
...    LNCEL-1:M8014C22=2
...    LNCEL-1:M8014C23=1
...    LNCEL-1:M8014C24=1
...    LNCEL-1:M8014C25=0
...    LNCEL-1:M8014C26=0
...    LNCEL-1:M8014C27=0
...    LNCEL-1/MCC-262/MNC-03/ECI-258/MCC-262/MNC-03:M8015C0=0
...    LNCEL-1/MCC-262/MNC-03/ECI-258/MCC-262/MNC-03:M8015C1=0
...    LNCEL-1/MCC-262/MNC-03/ECI-258/MCC-262/MNC-03:M8015C2=0
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-263/MNC-03:M8015C5=0
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-263/MNC-03:M8015C6=0
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-263/MNC-03:M8015C7=0
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-263/MNC-03:M8015C8=1
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-263/MNC-03:M8015C9=1
...    LNCEL-1/MCC-262/MNC-03/ECI-513/MCC-263/MNC-03:M8015C10=0
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-263/MNC-03:M8015C5=1
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-263/MNC-03:M8015C6=0
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-263/MNC-03:M8015C7=0
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-263/MNC-03:M8015C8=0
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-263/MNC-03:M8015C9=0
...    LNCEL-1/MCC-262/MNC-03/ECI-514/MCC-263/MNC-03:M8015C10=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C9=1
...    LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C10=1
...    LNCEL-1/MCC-262/MNC-03/PMQAP-5:M8048C9=1
...    LNCEL-1/MCC-262/MNC-03/PMQAP-5:M8048C10=1
...    LNCEL-1/MCC-262/MNC-03/PMQAP-9:M8048C9=1
...    LNCEL-1/MCC-262/MNC-03/PMQAP-9:M8048C10=1

*** Test Cases ***
LTE797_023_01_PMHO Inter PLMN S1 IFHO Multi Target Cells
    [Documentation]
    ...    [1][2.0] C-Pln_PMHO Successful inter eNB HO in different target cells
    ...    RR S1 InterFreq Inter PLMN HO
    ...    TG_LNCEL3:ho_restriction_list ta_plmn=333:09
    ...    TG_LNCEL-2/SIB-0:cellBarred=barred
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    Enable Handover Restriction
    UE1 Attach To Enb1 Cell1 And Add Bearers
    Attempt Inter Enb Handover To Three Target Cells
    Detach UE1
    Check Counters    ${pm_counters}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=2
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    alias=ENB_2    enb_id=2    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      enb_id_macro: 0x00002
    ...      plmn: '263:03'
    ...      s1: 10.0.1.31
    ...      s1u: 10.0.1.31
    ...      x2: 10.0.1.31
    ...      x2_peers: 1
    ...      cells:
    ...        - {id: 21, technology: lte, duplex_mode: FDD, tac: 124, pci: '17:0', eci: '0x0000201', earfcn: '1600:19600', bw: 20, status: enabled}
    ...        - {id: 22, technology: lte, duplex_mode: FDD, tac: 124, pci: '17:1', eci: '0x0000202', earfcn: '1600:19600', bw: 20, status: enabled}
    ...        - {id: 23, technology: lte, duplex_mode: FDD, tac: 125, pci: '17:2', eci: '0x0000203', earfcn: '1600:19600', bw: 20, status: enabled}
    Update Yaml    EPC/MME_POOL_AREA/1    tac_list: 33,124,125
    Add Yaml    EPC/MME_POOL_AREA
    ...    - id: 2
    ...      plmn: '263:03'
    ...      mmegi: 2
    ...      tac_list: 33,124,125
    Update Yaml    EPC/MME/1    pool: ['1:1', '2:1']

Enable Handover Restriction
    Execute Egate Command    mme_ho_restriction_list id=2 equiv_plmn=263:03 ta_plmn=263:03 tacs=125 restrict_nr_access=on
    Execute Egate Command    ue_mme_param id=1 ho_restrictions=lte ho_restriction_list_id=2

UE1 Attach To Enb1 Cell1 And Add Bearers
    ${attach_meas_config}=    Catenate
    ...    RRC_RRCConnectionReconfiguration (
    ...    measConfig contains (measObjectToAddModList contains (measObjectId eq 1 and carrierFreq eq 1400))
    ...    and reportConfigToAddModList contains (reportConfigId eq 4 and eventA2 contains (a2-Threshold contains (threshold-RSRP eq 70)))
    ...    and measIdToAddModList contains (measId eq 7 and measObjectId eq 1 and reportConfigId eq 4))
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionRequest (rrcConnectionRequest contains (establishmentCause eq "mo-Signalling"))
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (e-RAB-ID eq 5 and qCI eq 8))
    ...    UE_1:${attach_meas_config}
    ...    alias=UE1_Attach   overall_timeout=20
    ${reportA2_meas_config}=    Catenate
    ...    RRC_RRCConnectionReconfiguration (
    ...    measConfig contains (measObjectToAddModList contains (measObjectId eq 2 and carrierFreq eq 1600))
    ...    and reportConfigToAddModList contains (reportConfigId eq 6 and eventA3 contains (reportOnLeave eq "FALSE"))
    ...    and measIdToAddModList contains (measId eq 14 and measObjectId eq 2 and reportConfigId eq 6))
    Expect Message Flow
    ...    UE_1:${reportA2_meas_config}
    ...    alias=UE1_ReportA2   overall_timeout=20
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 1)))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 5)))
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 8 and qCI eq 9)))
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
    Sleep    3s
    Flow Occurred As Expected    alias=UE1_AddBearers

Attempt Inter Enb Handover To Three Target Cells
    [Documentation]
    ...    inter-frq A3,targetcell3 is in hoRestrictionList, HO fails
    ...    inter-frq A3,targetcell2 cellBarred=barred, HO fails
    ...    handover-desirable-for-radio-reason = 16
    ...    cell-not-available = 10
    ...    successful-handover = 2
    ${pci52_ho_fail}=    Catenate
    ...    S1AP_HandoverRequired (Cause contains (radioNetwork eq "handover-desirable-for-radio-reason")
    ...    and targetCell-ID contains (cell-ID eq "0b0000000000000000001000000010")) 
    Expect Message Flow
    ...    MME_1:${pci52_ho_fail}
    ...    MME_1:S1AP_HandoverPreparationFailure (Cause contains (radioNetwork eq "cell-not-available"))
    ...    alias=PCI52_HO_Fail   overall_timeout=20
    ${pci51_ho_success}=    Catenate
    ...    S1AP_HandoverRequired (Cause contains (radioNetwork eq "handover-desirable-for-radio-reason")
    ...    and targetCell-ID contains (cell-ID eq "0b0000000000000000001000000001"))
    Expect Message Flow
    ...    MME_1:${pci51_ho_success}
    ...    MME_1:S1AP_UEContextReleaseCommand (Cause contains (radioNetwork eq "successful-handover"))
    ...    alias=PCI51_HO_Success   overall_timeout=20
    Execute Uex Command    ue_measurement_send id=1 event=A3 phycell_id=53 srsrp=65 srsrq=12 nrsrp=77 nrsrq=30 meas_id_blacklist=1,16,18 amount=1
    Execute Egate Command    ue_mme_param id=1 s1_ho_preparation_failure=RN_cell_not_available
    Sleep    3s
    Execute Uex Command    ue_measurement_send id=1 event=A3 phycell_id=52 srsrp=65 srsrq=12 nrsrp=76 nrsrq=30 meas_id_blacklist=1,16,18 amount=1
    Flow Occurred As Expected    alias=PCI52_HO_Fail
    Execute Egate Command    ue_mme_param id=1 s1_ho_preparation_failure=off
    Sleep    3s
    Execute Uex Command    ue_measurement_send id=1 event=A3 phycell_id=51 srsrp=65 srsrq=12 nrsrp=76 nrsrq=30 meas_id_blacklist=1,16,18 amount=1
    Flow Occurred As Expected    alias=PCI51_HO_Success

Detach UE1
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionRelease
    ...    alias=UE1_Detach   overall_timeout=20
    Execute Uex Command    trf_data_stop ue=1
    Execute Egate Command    ue_disp id=1
    Execute Uex Command    ue_detach id=1
    Flow Occurred As Expected    alias=UE1_Detach

