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
...    @{PARAMS_FOR_LTE4_MOCN}
...    @{PARAMS_FOR_EMERGENCY}
...    @{PARAMS_FOR_SECURITY}
...    LNCEL-1:tac=124
...    LNCEL-2:tac=124
...    LNCEL-3:tac=124
...    LNBTS:mcc=262
...    LNBTS:mnc=3
...    LNBTS:mncLength=2
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
@{PARAMS_FOR_EMERGENCY}
...    LNBTS/LNBTS_FDD-0:actIMSEmerSessR9=true
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemCap=true|emerSessMcc=262
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemVul=false|emerSessMcc=262
...    LNBTS:imsEmerPlmnConfig:emerSessArpPrioLev=1|emerSessMcc=262
...    LNBTS:imsEmerPlmnConfig:emerSessLimServ=false|emerSessMcc=262
...    LNBTS:imsEmerPlmnConfig:emerSessMnc=3|emerSessMcc=262
...    LNBTS:imsEmerPlmnConfig:emerSessMncLen=2|emerSessMcc=262
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemCap=true|emerSessMcc=263
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemVul=false|emerSessMcc=263
...    LNBTS:imsEmerPlmnConfig:emerSessArpPrioLev=1|emerSessMcc=263
...    LNBTS:imsEmerPlmnConfig:emerSessLimServ=false|emerSessMcc=263
...    LNBTS:imsEmerPlmnConfig:emerSessMnc=3|emerSessMcc=263
...    LNBTS:imsEmerPlmnConfig:emerSessMncLen=2|emerSessMcc=263
@{PARAMS_FOR_SECURITY}
...    LNBTS:cipherPrefL:eea0=1
...    LNBTS:cipherPrefL:eea1=1
...    LNBTS:cipherPrefL:eea2=9
...    LNBTS:cipherPrefL:eea3=0
...    LNBTS:integrityPrefL:eia0=1
...    LNBTS:integrityPrefL:eia1=1
...    LNBTS:integrityPrefL:eia2=9
...    LNBTS:integrityPrefL:eia3=0
@{pm_counters}
...    LNCEL-1:M8006C0=3
...    LNCEL-1:M8006C6=0
...    LNCEL-1:M8006C7=0
...    LNCEL-1:M8006C8=0
...    LNCEL-1:M8006C9=0
...    LNCEL-1:M8006C89=0
...    LNCEL-1:M8006C98=0
...    LNCEL-1:M8006C107=0
...    LNCEL-1:M8006C116=0
...    LNCEL-1:M8007C0=3
...    LNCEL-1:M8007C1=3
...    LNCEL-1:M8007C2=0
...    LNCEL-1:M8007C4=0
...    LNCEL-1:M8007C7=1
...    LNCEL-1:M8007C8=1
...    LNCEL-1:M8007C9=0
...    LNCEL-1:M8007C10=1
...    LNCEL-1:M8007C11=1
...    LNCEL-1:M8007C12=0
...    LNCEL-1:M8009C0=0
...    LNCEL-1:M8009C1=3
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
...    LNCEL-1:M8014C14=3
...    LNCEL-1:M8014C15=0
...    LNCEL-1:M8014C16=1
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
...    LNCEL-1:M8014C22=3
...    LNCEL-1:M8014C23=1
...    LNCEL-1:M8014C24=1
...    LNCEL-1:M8014C25=0
...    LNCEL-1:M8014C26=0
...    LNCEL-1:M8014C27=0
...    LNCEL-1:M8021C6=3
...    LNCEL-1:M8021C9=2
...    LNCEL-1:M8021C12=1
...    LNCEL-1:M8021C15=1
...    LNCEL-1/MCC-262/MNC-03/ECI-258/MCC-262/MNC-03:M8015C0=0
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
...    LNCEL-1/MCC-262/MNC-03/PMQAP-9:M8048C9=0
...    LNCEL-1/MCC-262/MNC-03/PMQAP-9:M8048C10=0

*** Test Cases ***
LTE797_023_05_PMHO Inter PLMN Emergency Call S1 IFHO With Multi Target Cells
    [Documentation]
    ...    [4][2.0] C-Pln_PMHO Successful inter eNB HO in different target cells
    ...    RR S1 InterFreq Inter PLMN HO - Emergency call
    ...    [tc_set] \ LTE797_023 \ LTE572_34_6
    ...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:addEmergencySessions=0
    [Tags]
    UE1 Attach To Enb1 Cell1 And Add Bearers
    Attempt Inter Enb Handover To Three Target Cells
    Detach UE
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
    ...      plmn: '263:03'
    ...      s1: 10.0.1.31
    ...      s1u: 10.0.1.31
    ...      x2: 10.0.1.31
    ...      x2_peers: 1
    ...      cells:
    ...      - {id: 21, technology: lte, duplex_mode: FDD, tac: 124, pci: '17:0', eci: '0x0000201', earfcn: '1600:19600', bw: 20, status: enabled}
    ...      - {id: 22, technology: lte, duplex_mode: FDD, tac: 124, pci: '17:1', eci: '0x0000202', earfcn: '1600:19600', bw: 20, status: enabled}
    ...      - {id: 23, technology: lte, duplex_mode: FDD, tac: 124, pci: '17:2', eci: '0x0000203', earfcn: '1600:19600', bw: 20, status: enabled}
    Add Yaml    EPC/PGW
    ...    - id: 3
    ...    type: 'simulated'
    ...    apn: 'emergency.nsn.com'
    ...    emergency: 'on'
    ${pdn3_qci1}=    Catenate
    ...    - {qci: 1, default: off, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, 
    ...    filter: 1, precedence: 1, priority: 1, pdn: 3}
    Add Yaml    UEs/bearer_sets/bearer_set_2
    ...    - {qci: 8, default: on, trf_type: external, pdn: 1}
    ...    - {qci: 1, default: off, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...    - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...    - {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1}
    ...    - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...    - {qci: 5, pdn: 1}
    ...    - {qci: 6, pdn: 1}
    ...    - {qci: 7, pdn: 1}
    ...    - {qci: 9, pdn: 1}
    ...    - {qci: 8, default: on, trf_type: external, pdn: 2}
    ...    - {qci: 6, pdn: 2}
    ...    - {qci: 7, pdn: 2}
    ...    - {qci: 9, pdn: 2}
    ...    - {qci: 5, default: on, trf_type: internal, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, priority: 1, pdn: 3}
    ...    ${pdn3_qci1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2
    Add Yaml    EPC/MME_POOL_AREA
    ...    - id: 2
    ...      plmn: '263:03'
    ...      mmegi: 2
    ...      tac_list: 33,124
    Update Yaml    EPC/MME/1    pool: ['1:1', '2:1']

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
    ${pdn3_qci5}=    Catenate
    ...    S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 6 and qCI eq 5)))
    ${pdn3_qci1}=    Catenate
    ...    S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (E-RABToBeSetupItemBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 1)))
    Expect Message Flow
    ...    MME_1:${pdn3_qci5}
    ...    MME_1:${pdn3_qci1}
    ...    alias=UE1_Add_QCI1   overall_timeout=20
    Execute Uex Command    ue_param id=1 ue_eutra_capabilities=859FF0300308040E1F8BFC3E17F87E2FF0FC5FDFF367A822040088239920
    Execute Uex Command    ue_attach id=1 enb=1 cell=1
    Flow Occurred As Expected    alias=UE1_Attach
    Execute Uex Command    trf_data_start ue=1 dir=dl protocol=udp Mbps=1 qci=8 trf_id=1
    Sleep    3s
    Execute Uex Command    ue_measurement_send id=1 event=A2 srsrp=65 srsrq=12 meas_id_blacklist=4 amount=1
    Flow Occurred As Expected    alias=UE1_ReportA2
    Execute Uex Command    ue_pdn_connect id=1 apn=emergency.nsn.com request_type=emergency
    Flow Occurred As Expected    alias=UE1_Add_QCI1

Attempt Inter Enb Handover To Three Target Cells
    ${pci53_ho_fail}=    Catenate
    ...    S1AP_HandoverRequired (Cause contains (radioNetwork eq "handover-desirable-for-radio-reason") 
    ...    and targetCell-ID contains (cell-ID eq "0b0000000000000000001000000011"))
    Expect Message Flow
    ...    MME_1:${pci53_ho_fail}
    ...    MME_1:S1AP_HandoverPreparationFailure (Cause contains (radioNetwork eq "no-radio-resources-available-in-target-cell"))
    ...    alias=PCI53_HO_Fail   overall_timeout=20
    ${pci52_ho_fail}=    Catenate
    ...    S1AP_HandoverRequired (Cause contains (radioNetwork eq "handover-desirable-for-radio-reason") 
    ...    and targetCell-ID contains (cell-ID eq "0b0000000000000000001000000010"))
    Expect Message Flow
    ...    MME_1:${pci52_ho_fail}
    ...    MME_1:S1AP_HandoverPreparationFailure (Cause contains (radioNetwork eq "unknown-targetID"))
    ...    alias=PCI52_HO_Fail   overall_timeout=20
    ${pci51_ho_success}=    Catenate
    ...    S1AP_HandoverRequired (Cause contains (radioNetwork eq "handover-desirable-for-radio-reason") 
    ...    and targetCell-ID contains (cell-ID eq "0b0000000000000000001000000001"))
    Expect Message Flow
    ...    MME_1:${pci51_ho_success}
    ...    MME_1:S1AP_HandoverCommand (E-RABSubjecttoDataForwardingList contains ((e-RAB-ID eq 5), (e-RAB-ID eq 6)))
    ...    MME_1:S1AP_UEContextReleaseCommand (Cause contains (radioNetwork eq "successful-handover"))
    ...    UE_1:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 51))
    ...    alias=PCI51_HO_Success   overall_timeout=60
    Execute Egate Command    ue_mme_param id=1 s1_ho_preparation_failure=RN_no_radio_resources_available_in_target_cell
    Sleep    3s
    Execute Uex Command    ue_measurement_send id=1 event=A3 phycell_id=53 srsrp=65 srsrq=15 nrsrp=77 nrsrq=20 meas_id_blacklist=1,16,18 amount=1
    Flow Occurred As Expected    alias=PCI53_HO_Fail
    Execute Egate Command    ue_mme_param id=1 s1_ho_preparation_failure=RN_unknown_targetID
    Sleep    3s
    Execute Uex Command    ue_measurement_send id=1 event=A3 phycell_id=52 srsrp=65 srsrq=15 nrsrp=76 nrsrq=20 meas_id_blacklist=1,16,18 amount=1
    Flow Occurred As Expected    alias=PCI52_HO_Fail
    Execute Egate Command    ue_mme_param id=1 s1_ho_preparation_failure=off
    Sleep    3s
    Execute Uex Command    ue_measurement_send id=1 event=A3 phycell_id=51 srsrp=65 srsrq=15 nrsrp=75 nrsrq=20 meas_id_blacklist=1,16,18 amount=1
    Flow Occurred As Expected    alias=PCI51_HO_Success
    Sleep    20s

Detach UE
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionRelease
    ...    alias=UE1_Detach   overall_timeout=20
    Execute Uex Command    trf_data_stop ue=1
    Execute Egate Command    ue_disp id=1
    Execute Uex Command    ue_detach id=1
    Flow Occurred As Expected    alias=UE1_Detach


