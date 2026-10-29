*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               owner-yu.1.zhou    owner-eric.jiang    team-DEVHZ5_SG3    release-xL19
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_FEATURE_FLAG}
...    @{PARAMS_FOR_RESOURCE_LIMIT}
...    @{PARAMS_FOR_CATM}
...    @{PARAMS_FOR_CATM_CEModeB}
@{PARAMS_FOR_FEATURE_FLAG}
...    LNBTS:actEnhAcAndGbrServices=true
...    LNBTS:actMultBearers=true
...    LNBTS:actMultGbrBearers=true
...    LNBTS/LNBTS_FDD-0:actConvVoice=true
...    LNBTS/LNBTS_FDD-0:actIMSEmerSessR9=true
...    LNBTS:qciTab5:schedulType=SIGNALLING
...    LNBTS:qciTab5:lcgid=0
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemCap=true
...    LNBTS:imsEmerPlmnConfig:emerSessArpPreemVul=false
...    LNBTS:imsEmerPlmnConfig:emerSessArpPrioLev=1
@{PARAMS_FOR_RESOURCE_LIMIT}
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=0
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=4
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=4
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe3c=0
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUeDc=0
...    LNCEL-1/LNCEL_FDD-0:addNumDrbRadioReasHo=0
...    LNCEL-1/LNCEL_FDD-0:addNumDrbTimeCriticalHo=0
...    LNCEL-1/LNCEL_FDD-0:addNumQci1DrbRadioReasHo=0
...    LNCEL-1/LNCEL_FDD-0:addNumQci1DrbTimeCriticalHo=0
@{PARAMS_FOR_CATM}
...    LNCEL-1/LNCEL_FDD-0:actCatM=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNCEL_FDD-0:catMProfId=1
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNBTS/CATMPR-1:siWindowLenCatM=40ms
...    LNCEL-1/CATMCEL-0:actEDrxIdleCatM=false
...    LNCEL-1/SIB-0:siWindowLen=40ms
...    LNBTS/CATMPR-1:inactivityTimerCatM=5
@{PARAMS_FOR_CATM_CEModeB}
...    LNBTS/LNMCE-0/MBSFNSYNCAREA_FDD-0:mbsfnChBw=10 MHz
...    LNCEL-1/CATMCEL-0:numCELevelCatM=2
...    LNCEL-1/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-1/CATMCEL-0:prachRsrpThrCatM=-137
...    LNCEL-1/CATMCEL-0:prachRsrpThr2CatM=-139
...    LNCEL-1/CATMCEL-0:qRxLevMinCe1CatM=-140
...    LNCEL-1/CATMCEL-0:prachRsrpThr1CatM=-138
...    LNBTS/LNCEL-1:dlsDciCch=DCI format 1A
...    LNBTS/CATMBPR-0:defaultPagCeModeBCatM=n16
@{PARAMS_FOR_RESOURCE_DEFAULT}
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL-1/LNCEL_FDD-0:maxNumActDrb=240
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=240
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe=50
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe3c=20
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUeDc=50
...    LNCEL-1/LNCEL_FDD-0:addNumDrbTimeCriticalHo=60
...    LNCEL-1/LNCEL_FDD-0:addNumQci1DrbRadioReasHo=15
...    LNCEL-1/LNCEL_FDD-0:addNumQci1DrbTimeCriticalHo=20
@{PARAMS_A_d5_ET_01_01}
...    LNBTS/PMRNL-1:mtUEQuantity=15min
...    @{PARAMS_FOR_RESOURCE_DEFAULT}
${UE_EUTRA_CAPABILITIES_NORMAL}    CD9FF459B2E750081810381FFFFFFFFF2862000608020A5408008A80182CFFFFFFFF8053FFFFFFFF    # add FDD band3
${UE_EUTRA_CAPABILITIES_CAT21_FDD}
...    SEPARATOR=
...    D180001A410000FE0D189E00218712154AC868018210C00C2084304218210C0080F8A8C08603A4001041E900041690820748002485D200082D
...    2105A42083D200092D2104169093D2000820748002686000000000000003FF2000017EB00200408F1979A0401481E680BF062001CE5040E720
...    4082073902040059CE70001002292801840001010000550E00
${ERAB_REL_ENB_RNL_PREEM}    M8006C341
${ERAB_REL_ENB_RNL_PREEM_QCI1}    M8006C342
${ERAB_REL_ENB_RNL_PREEM_QCI2}    M8006C343
${ERAB_REL_ENB_RNL_RRNA}    M8006C260
${ERAB_REL_ENB_RNL_RRNA_QCI1}    M8006C272
${ERAB_REL_ENB_RNL_RRNA_QCI2}    M8006C290
${ACTIVE_UE_DL_CAT_21_AVG}    M8051C180
${ACTIVE_UE_DL_CAT_20_AVG}    M8051C179
${ACTIVE_UE_DL_CAT_19_AVG}    M8051C137
${ACTIVE_UE_DL_CAT_18_AVG}    M8051C136
${ACTIVE_UE_DL_CAT_17_AVG}    M8051C135
${ACTIVE_UE_DL_CAT_16_AVG}    M8051C9
${ACTIVE_UE_DL_CAT_15_AVG}    M8051C8
${ACTIVE_UE_DL_CAT_14_AVG}    M8051C7
${ACTIVE_UE_DL_CAT_13_AVG}    M8051C6
${ACTIVE_UE_DL_CAT_12_AVG}    M8051C5
${ACTIVE_UE_DL_CAT_11_AVG}    M8051C4
${ACTIVE_UE_DL_CAT_10_AVG}    M8051C3
${ACTIVE_UE_UL_CAT_18_AVG}    M8051C155
@{PM_COUNTERS_FOR_01_04}
...    LNCEL-1:${ERAB_REL_ENB_RNL_PREEM}=3
...    LNCEL-1:${ERAB_REL_ENB_RNL_PREEM_QCI1}=0
...    LNCEL-1:${ERAB_REL_ENB_RNL_PREEM_QCI2}=0
...    LNCEL-1:${ERAB_REL_ENB_RNL_RRNA}=0
...    LNCEL-1:${ERAB_REL_ENB_RNL_RRNA_QCI1}=0
...    LNCEL-1:${ERAB_REL_ENB_RNL_RRNA_QCI2}=0
@{PM_COUNTERS_FOR_d5_01_01_BEFORE}
...  last LNCEL-1:${ACTIVE_UE_DL_CAT_21_AVG}=30
...    LNCEL-1:${ACTIVE_UE_DL_CAT_20_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_19_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_18_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_17_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_16_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_15_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_14_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_13_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_12_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_11_AVG}=0
...    LNCEL-1:${ACTIVE_UE_DL_CAT_10_AVG}=0
...  last LNCEL-1:${ACTIVE_UE_UL_CAT_18_AVG}=30
@{PM_COUNTERS_FOR_d5_01_01_AFTER}
...  last LNCEL-1:${ACTIVE_UE_DL_CAT_21_AVG}=0
...  last LNCEL-1:${ACTIVE_UE_UL_CAT_18_AVG}=0
${Timer_waste_rtpm_produce}    120

*** Test Cases ***
LTE4769_A_d1_ET_01_04_eNB initiated E_RAB releases due to pre_emption_during X2 Handover
    [Tags]
    Start Rtpm Counter
    Ue6 attach to enb1 cell1 trigger ICS with list of EPS Bearers
    Ue7 attach to enb1 cell1 trigger ICS with list of EPS Bearers
    Do data transfer in QCI 6_8_9 for ue6 ue7
    Ue8 attach to enb2 cell1 trigger ICS with list of EPS Bearers  
    Ue8 trigger X2 handover from enb2 cell1 to enb1 cell1
    Stop data transfer for ue6 ue7
    Detach UEs
    Check Rtpm Counters    ${PM_COUNTERS_FOR_01_04}

LTE4769_A_d5_ET_01_01_Counter_DL Category 21_FDD
    [Tags]
    Delta Commission Parameters    ${PARAMS_A_d5_ET_01_01}
    UEs Attach To eNB1    ue_id_start=31    ue_id_stop=60    ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CAT21_FDD}
    Do Data Transfer To Make Sure UEs Active    ue_id_start=31    ue_id_stop=60
    Wait Time To Make Rtmp In Next Loop
    Start Rtpm Counter    tag=1st
    Check Rtpm Counters    ${PM_COUNTERS_FOR_d5_01_01_BEFORE}    tag=1st
    Release All Ues
    Wait Time To Make Rtmp In Next Loop
    Start Rtpm Counter    tag=2nd
    Check Rtpm Counters    ${PM_COUNTERS_FOR_d5_01_01_AFTER}    tag=2nd

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=60    id_type=cus
    Create Enb Alias    alias=ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    alias=ENB_2    enb_id=2    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.31
    ...      cells:
    ...      - {id: 21, technology: lte, duplex_mode: FDD, tac: 33, pci: '3:0', eci: '0x0000215', earfcn: '1400:19400', bw: 20}
    Add Yaml    UEs/bearer_sets/bearer_set_2
    ...    - {qci: 8, default: on, pdn: 1, trf_type: external, priority: 8, preemption: 1, vulnerability: 1}
    ...    - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...    - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...    - {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1}
    ...    - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...    - {qci: 5, pdn: 1}
    ...    - {qci: 6, pdn: 1}
    ...    - {qci: 7, pdn: 1}
    ...    - {qci: 9, pdn: 1}
    ...    - {qci: 8, default: on, pdn: 2, trf_type: external}
    ...    - {qci: 6, pdn: 2}
    ...    - {qci: 7, pdn: 2}
    ...    - {qci: 9, pdn: 2}
    Add Yaml    UEs/bearer_sets/bearer_set_3
    ...    - {qci: 8, default: on, pdn: 1, trf_type: external, priority: 8, preemption: 0, vulnerability: 0}
    ...    - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...    - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...    - {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1}
    ...    - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...    - {qci: 5, pdn: 1}
    ...    - {qci: 6, pdn: 1, preprovisioned: on, filter: 6, precedence: 6, priority: 6, preemption: 1, vulnerability: 1}
    ...    - {qci: 7, pdn: 1}
    ...    - {qci: 9, pdn: 1, preprovisioned: on, filter: 9, precedence: 9, priority: 9, preemption: 1, vulnerability: 1}
    ...    - {qci: 8, default: on, pdn: 2, trf_type: external}
    ...    - {qci: 6, pdn: 2}
    ...    - {qci: 7, pdn: 2}
    ...    - {qci: 9, pdn: 2}
    ${qci1}=    catenate
    ...    {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, preprovisioned: on, filter: 1, precedence: 1,  priority: 2, 
    ...    preemption: 1, vulnerability: 1}
    ${qci3}=    catenate
    ...    {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1, preprovisioned: on, filter: 3, precedence: 3, priority: 3, 
    ...    preemption: 1, vulnerability: 1}    
    Add Yaml    UEs/bearer_sets/bearer_set_4
    ...    - {qci: 8, default: on, pdn: 1, trf_type: external, priority: 1, preemption: 1, vulnerability: 1}
    ...    - ${qci1}
    ...    - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...    - ${qci3}
    ...    - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...    - {qci: 5, pdn: 1}
    ...    - {qci: 6, pdn: 1, priority: 6, preemption: 1, vulnerability: 1}
    ...    - {qci: 7, pdn: 1}
    ...    - {qci: 9, pdn: 1, priority: 9, preemption: 1, vulnerability: 1}
    ...    - {qci: 8, default: on, pdn: 2, trf_type: external}
    ...    - {qci: 6, pdn: 2}
    ...    - {qci: 7, pdn: 2}
    ...    - {qci: 9, pdn: 2}
    Update Yaml    UEs/UE_sets/6    bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/7    bearer: bearer_set_3
    Update Yaml    UEs/UE_sets/8    bearer: bearer_set_4

Ue6 attach to enb1 cell1 trigger ICS with list of EPS Bearers
    ${message}=    catenate
    ...    S1AP_InitialContextSetupRequest (
    ...    (UERadioCapability is not present) and
    ...    (E-RABToBeSetupListCtxtSUReq contains (((e-RAB-ID eq 5) and (qCI eq 8)))))
    Expect Message Flow
    ...    MME_1:${message}
    ...    UE_GROUP_6:RRC_UECapabilityEnquiry
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    alias=UE6_Attach_Flow    overall_timeout=20 
    Execute Egate Command    ue_change_location id=6 cell=1
    Execute Uex Command    ue_attach id=6 cell=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_NORMAL}
    Flow Occurred As Expected    alias=UE6_Attach_Flow 

Ue7 attach to enb1 cell1 trigger ICS with list of EPS Bearers
    ${message}=    catenate
    ...    S1AP_InitialContextSetupRequest (
    ...    (UERadioCapability is not present) and
    ...    (E-RABToBeSetupListCtxtSUReq contains ((
    ...    (e-RAB-ID eq 5) and (qCI eq 8)),((e-RAB-ID eq 6) and (qCI eq 6)),((e-RAB-ID eq 7) and (qCI eq 9))
    ...    )))
    Expect Message Flow
    ...    MME_1:${message}
    ...    UE_GROUP_7:RRC_UECapabilityEnquiry
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    alias=UE7_Attach_Flow    overall_timeout=20
    Execute Egate Command    ue_change_location id=7 cell=1
    Execute Uex Command    ue_attach id=7 cell=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_NORMAL}
    Flow Occurred As Expected    alias=UE7_Attach_Flow

Do data transfer in QCI 6_8_9 for ue6 ue7
    Execute Uex Command    trf_data_start ue=6 qci=8 dir=dl kbps=90 protocol=udp
    Execute Uex Command    trf_data_start ue=7 qci=8 dir=dl kbps=90 protocol=udp
    Execute Uex Command    trf_data_start ue=7 qci=6 dir=dl kbps=90 protocol=udp
    Execute Uex Command    trf_data_start ue=7 qci=9 dir=dl kbps=90 protocol=udp

Ue8 attach to enb2 cell1 trigger ICS with list of EPS Bearers
    ${message}=    catenate
    ...    S1AP_InitialContextSetupRequest (
    ...    (UERadioCapability is not present) and
    ...    (E-RABToBeSetupListCtxtSUReq contains ((
    ...    (e-RAB-ID eq 5) and (qCI eq 8)),((e-RAB-ID eq 6) and (qCI eq 1)),((e-RAB-ID eq 7) and (qCI eq 3))
    ...    )))
    Expect Message Flow
    ...    MME_1:${message}
    ...    UE_GROUP_8:RRC_UECapabilityEnquiry
    ...    MME_1:S1AP_UECapabilityInfoIndication
    ...    alias=UE8_Attach_Flow    overall_timeout=20
    Execute Egate Command    ue_timer T300=2000
    Execute Uex Command    ue_attach id=8 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_NORMAL} enb=2 cell=21
    Flow Occurred As Expected    alias=UE8_Attach_Flow

Ue8 trigger X2 handover from enb2 cell1 to enb1 cell1
    ${enb2_ho_request}=    catenate
    ...    X2AP_HandoverRequest (Cause contains (radioNetwork eq "handover-desirable-for-radio-reasons") and
    ...    e-RABs-ToBeSetup-List contains (e-RAB-ID eq 5 and qCI eq 8 and priorityLevel eq "highest" and 
    ...    pre-emptionCapability eq "may-trigger-pre-emption" and pre-emptionVulnerability eq "pre-emptable", 
    ...    e-RAB-ID eq 6 and qCI eq 1 and priorityLevel eq 2 and pre-emptionCapability eq "may-trigger-pre-emption" and 
    ...    pre-emptionVulnerability eq "pre-emptable", 
    ...    e-RAB-ID eq 7 and qCI eq 3 and priorityLevel eq 3 and pre-emptionCapability eq "may-trigger-pre-emption" and 
    ...    pre-emptionVulnerability eq "pre-emptable"))
    ${UE6_Context_Release_Request}=     catenate
    ...    S1AP_UEContextReleaseRequest (Cause contains (radioNetwork eq "release-due-to-pre-emption"))
    ${UE7_E-RAB_Release_Request}=     catenate
    ...    S1AP_E-RABReleaseIndication (E-RABList contains (
    ...    e-RAB-ID eq 7 and cause contains (radioNetwork eq "release-due-to-pre-emption"),
    ...    e-RAB-ID eq 6 and cause contains (radioNetwork eq "release-due-to-pre-emption")
    ...    ))
    Expect Message Flow
    ...    ENB_2:${enb2_ho_request}
    ...    UE_GROUP_8:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 1))
    ...    MME_1:${UE6_Context_Release_Request}
    ...    MME_1:${UE7_E-RAB_Release_Request}
    ...    alias=ho_flow  overall_timeout=30
    Execute Egate Command    enb_param id=2 ho_source=x2
    Execute Uex Command    ue_ho id=8 enb=1 cell=1
    Flow Occurred As Expected    alias=ho_flow

Stop data transfer for ue6 ue7
    Execute Uex Command    trf_data_stop ue=6 qci=8
    Execute Uex Command    trf_data_stop ue=7 qci=8

Detach UEs
    Expect Message Flow
    ...    UE_GROUP_7:RRC_RRCConnectionRelease
    ...    UE_GROUP_8:RRC_RRCConnectionRelease
    ...    alias=Detach_UEs_Flow    overall_timeout=5
    Execute Uex Command    ue_detach id=7
    Execute Uex Command    ue_detach id=8
    Flow Occurred As Expected    alias=Detach_UEs_Flow
    
UEs Attach To eNB1
    [Arguments]    ${ue_id_start}    ${ue_id_stop}    ${ue_eutra_capabilities}
    Expect Message Flow
    ...    UE_GROUP_31:RRC_UECapabilityEnquiry
    ...    UE_GROUP_32:RRC_UECapabilityEnquiry
    ...    UE_GROUP_33:RRC_UECapabilityEnquiry
    ...    UE_GROUP_34:RRC_UECapabilityEnquiry
    ...    UE_GROUP_35:RRC_UECapabilityEnquiry
    ...    UE_GROUP_36:RRC_UECapabilityEnquiry
    ...    UE_GROUP_37:RRC_UECapabilityEnquiry
    ...    UE_GROUP_38:RRC_UECapabilityEnquiry
    ...    UE_GROUP_39:RRC_UECapabilityEnquiry
    ...    UE_GROUP_40:RRC_UECapabilityEnquiry
    ...    UE_GROUP_41:RRC_UECapabilityEnquiry
    ...    UE_GROUP_42:RRC_UECapabilityEnquiry
    ...    UE_GROUP_43:RRC_UECapabilityEnquiry
    ...    UE_GROUP_44:RRC_UECapabilityEnquiry
    ...    UE_GROUP_45:RRC_UECapabilityEnquiry
    ...    UE_GROUP_46:RRC_UECapabilityEnquiry
    ...    UE_GROUP_47:RRC_UECapabilityEnquiry
    ...    UE_GROUP_48:RRC_UECapabilityEnquiry
    ...    UE_GROUP_49:RRC_UECapabilityEnquiry
    ...    UE_GROUP_50:RRC_UECapabilityEnquiry
    ...    UE_GROUP_51:RRC_UECapabilityEnquiry
    ...    UE_GROUP_52:RRC_UECapabilityEnquiry
    ...    UE_GROUP_53:RRC_UECapabilityEnquiry
    ...    UE_GROUP_54:RRC_UECapabilityEnquiry
    ...    UE_GROUP_55:RRC_UECapabilityEnquiry
    ...    UE_GROUP_56:RRC_UECapabilityEnquiry
    ...    UE_GROUP_57:RRC_UECapabilityEnquiry
    ...    UE_GROUP_58:RRC_UECapabilityEnquiry
    ...    UE_GROUP_59:RRC_UECapabilityEnquiry
    ...    UE_GROUP_60:RRC_UECapabilityEnquiry
    ...    alias=UEs_Attach_Flow    overall_timeout=60
    Execute Egate Command    ue_param id=${ue_id_start}-${${ue_id_stop}+1} csfb_rat=utran_geran voice_domain_preference=lte_preferred
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${${ue_id_stop}+1}
       Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} enb=1 cell=1
    END
    Flow Occurred As Expected    alias=UEs_Attach_Flow
    
Do Data Transfer To Make Sure UEs Active
    [Arguments]    ${ue_id_start}    ${ue_id_stop}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${${ue_id_stop}+1}
        Execute Uex Command    trf_data_start ue=${ue_id} trf_id=1 dir=dl kbps=30 protocol=udp
    END

Wait Time To Make Rtmp In Next Loop
    Sleep    ${Timer_waste_rtpm_produce}