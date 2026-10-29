*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT_NOT    team-CN1ET    owner-zhuo.lena
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CB008225    release-SBTS23R4
...    STATE_CONFIGURED
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{HPA_related}
...    @{AC_related}
...    @{8225_related}

@{UAI}
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:timerReleasePreferenceProhibit=s3
...    NRBTS:outOfConnectedPreference=inactive

@{HPA_related}
...    NRCELL-1:actPriorityAccess=true
...    NRCELL-1:actEmergencyCall=true
...    NRBTS:applyPriorityAccess=HPA
...    NRBTS/NRPRIOACC_PROFILE-1:nrPlmnIdx=1
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMax=8
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMin=6
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMax=4
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMin=1
...    NRCELL-1:raPrioritizationForAI=MPS+MCS
...    NRCELL-1:powerRampingStepHighPriorityCbra=dB4
...    NRCELL-1:powerRampingStep=dB2
...    NRCELL-1:pagingPrioLevelPaMax=1
...    NRCELL-1:pagingPrioLevelPaMin=1
...    NRCELL-1:tPageCorrInt=3000
...    @{EC_related}

@{AC_related}
...    NRCELL-1:maxNumOfRrcSA=1
...    NRCELL-1:maxNumOfUsersPerNRCell=1
...    NRCELL-1:maxNumOfUsersPerCell=1
...    NRCELL-1:maxNumOfCaUsersNRCell=1
...    NRCELL-1:maxNumOfNrDcSnUsers=1
...    NRCELL-1:maxNumOfSCellAlloc=1
...    NRCELL-1:numOfRadioResReservForPa=3
...    NRCELL-1:numOfRadioResReservForEmergency=1
...    NRCELL-1:numOfRadioResReservForTempUse=10
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=1

@{EC_related}
...    NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRCELL-1:actVoNR=true
...    @{5QI1}

@{5QI1}
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:discardTimer=40ms
...    NRBTS/NRDRB-15:discardTimerUl=infinity
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-15:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulBSD=100ms
...    NRBTS/NRDRB_MAC-4:schedulPrio=5
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50

@{8225_related}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=7200
...    NRBTS:drbInactivityTimerSA=7200
...    NRBTS:srbInactivityTimerSA=600
...    NRBTS:maxUeRrcInactTime=1
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:t380=60min
...    NRBTS:actPaging=true
...    NRBTS:tRanPagingGuard=4
...    NRBTS:ranPagingCycle=v32
...    NRCELL:ranAC=0
...    NRBTS:activityNotificationLevelSA=ue
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRRCC=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrPaging=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrF1CD=5min
...    NRBTS:act3gppBL23R1=true
...    @{UAI}

@{AC_I001}
...    NRCELL-1:maxNumOfRrcSA=2
...    NRCELL-1:maxNumOfUsersPerNRCell=2
...    NRCELL-1:maxNumOfUsersPerCell=2
...    NRCELL-1:maxNumOfCaUsersNRCell=2
...    NRCELL-1:maxNumOfNrDcSnUsers=2
...    NRCELL-1:maxNumOfSCellAlloc=2
...    NRCELL-1:maxNumOfNonGBRBearersSA=10
...    NRBTS/NRDU-1:numOfDrbsReservForTempUse=120
...    NRCELL-2:numOfRadioResReservForTempUse=10

@{preemption_related}
...    NRBTS:actDrbPreemption=true
...    NRBTS:actUserPreemption=true
...    NRCELL:preferNsaPreemption=false
...    NRCELL:allowEmergencyReservForTempUse=false
...    NRCELL-2:emergencyCallRestrictions=${EMPTY}
...    NRBTS:maxNumOfPreemptions=20

@{MPS_and_InactivityTimer_paramters}
...    NRBTS:applyPriorityAccess=MPS
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:srbInactivityTimerSA=30

@{MPS_chechk}
...    NG RM Register
...    establishmentCause mps-PriorityAccess

@{recovery_I010}
...    NRBTS:applyPriorityAccess=HPA
...    NRBTS:drbRrcInactInactivityTimerSA=7200
...    NRBTS:srbInactivityTimerSA=600

@{delta_I006}
...    NRCELL-1:actPriorityAccess=false
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    NRCELL:preferNsaPreemption=false
...    NRCELL-1:actARPBasedAC=on
...    NRCELL-1:maxNumOfNonGBRBearersSA=2
...    NRBTS:maxNumOfPreemptions=20
...    NRCELL:allowEmergencyReservForTempUse=false
...    NRCELL:numOfRadioResReservForTempUse=10
...    NRBTS/NRDU-1:numOfDrbsReservForTempUse=0
...    NRCELL-1:maxNumOfRrcSA=2
...    NRCELL-1:maxNumOfUsersPerNRCell=2
...    NRCELL-1:maxNumOfUsersPerCell=2
...    NRCELL-1:maxNumOfCaUsersNRCell=2
...    NRCELL-1:maxNumOfNrDcSnUsers=2
...    NRCELL-1:maxNumOfSCellAlloc=2
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:srbInactivityTimerSA=20

@{recovery_I006}
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    NRCELL-1:maxNumOfNonGBRBearersSA=550
...    NRBTS/NRDU-1:numOfDrbsReservForTempUse=120
...    NRBTS:drbRrcInactInactivityTimerSA=7200
...    NRBTS:srbInactivityTimerSA=600

@{delta_I007}
...    NRCELL-1:actPriorityAccess=false
...    NRBTS:actDrbPreemption=true
...    NRBTS:actUserPreemption=true
...    NRCELL-1:maxNumOfNonGBRBearersSA=2
...    NRBTS:maxNumOfPreemptions=20
...    NRCELL:allowEmergencyReservForTempUse=false
...    NRCELL:preferNsaPreemption=false
...    NRCELL:numOfRadioResReservForTempUse=10
...    NRBTS/NRDU-1:numOfDrbsReservForTempUse=120
...    NRCELL-1:maxNumOfRrcSA=2
...    NRCELL-1:maxNumOfUsersPerNRCell=2
...    NRCELL-1:maxNumOfUsersPerCell=2
...    NRCELL-1:maxNumOfCaUsersNRCell=2
...    NRCELL-1:maxNumOfNrDcSnUsers=2
...    NRCELL-1:maxNumOfSCellAlloc=2
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:srbInactivityTimerSA=20

@{recovery_I007}
...    NRCELL-1:actPriorityAccess=true
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    NRCELL-1:maxNumOfNonGBRBearersSA=550
...    NRBTS:drbRrcInactInactivityTimerSA=7200
...    NRBTS:srbInactivityTimerSA=600

@{delta_I002}
...    NRCELL-1:actPriorityAccess=false
...    @{AC_related}

@{recovery_I002}
...    NRCELL-1:actPriorityAccess=true

@{delta_I005}
#...    NRBTS:actCuOvlProt=true
...    NRBTS:gnbOvlProtMode=classical
...    NRBTS:cuOvlHa:ovlSaRrcRej=enabled
...    NRBTS:applyPriorityAccess=none
...    NRCELL-1:numOfRadioResReservForEmergency=3
...    NRCELL-1:numOfRadioResReservForPa=0
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=3
...    delete:NRCELL-1:pagingPrioLevelPaMin
...    delete:NRCELL-1:pagingPrioLevelPaMax
...    NRCELL-1:maxNumOfRrcSA=5
...    NRCELL-1:maxNumOfUsersPerNRCell=5
...    NRCELL-1:maxNumOfUsersPerCell=5
...    NRCELL-1:maxNumOfCaUsersNRCell=5
...    NRCELL-1:maxNumOfNrDcSnUsers=5
...    NRCELL-1:maxNumOfSCellAlloc=5

@{online_modify_I005}
...    NRBTS:applyPriorityAccess=HPA+MPS
...    NRCELL-1:numOfRadioResReservForPa=5

@{recovery_I005}
#...    NRBTS:actCuOvlProt=false
...    NRBTS:gnbOvlProtMode=disabled
...    NRBTS:cuOvlHa:ovlSaRrcRej=disabled
...    NRBTS:applyPriorityAccess=HPA
...    NRCELL-1:numOfRadioResReservForEmergency=1
...    NRCELL-1:numOfRadioResReservForPa=3
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=1
...    NRCELL-1:pagingPrioLevelPaMin=1
...    NRCELL-1:pagingPrioLevelPaMax=1
...    NRCELL-1:maxNumOfRrcSA=1
...    NRCELL-1:maxNumOfUsersPerNRCell=1
...    NRCELL-1:maxNumOfUsersPerCell=1
...    NRCELL-1:maxNumOfCaUsersNRCell=1
...    NRCELL-1:maxNumOfNrDcSnUsers=1
...    NRCELL-1:maxNumOfSCellAlloc=1

@{delta_I008}
...    NRCELL-1:numOfRadioResReservForEmergency=1
...    NRCELL-1:maxNumOfRrcSA=1
...    NRCELL-1:maxNumOfUsersPerNRCell=1
...    NRCELL-1:maxNumOfUsersPerCell=1
...    NRCELL-1:maxNumOfCaUsersNRCell=1
...    NRCELL-1:maxNumOfNrDcSnUsers=1
...    NRCELL-1:maxNumOfSCellAlloc=1


@{delta_I001}
...    @{AC_I001}
...    @{preemption_related}
...    NRCELL-1:actPriorityAccess=false

@{recovery_I001}
...    NRBTS:actDrbPreemption=false
...    NRBTS:actUserPreemption=false
...    @{AC_related}
...    NRCELL-1:actPriorityAccess=true

${UE_Capa_Support_UAI_VONR}    SEPARATOR=
...    E1A00000074E5A031E000384A0003C1260C80008785800C40340260300C0700CA8D851AC10143404B2CA261E003D6C10101070EF1C39061C00103278FAB
...    80027800E0009E00151B133582028680965944C3C007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB28987800F5B0
...    404041C3BC70E418700040C9E3EAE0009E00380027800546C4ED6080A1A025965130F001EB608080838778E1C830E0008193C7D54000014000000420E26
...    8000000010134640000E010113D86C003000281C1401C0C026007000683E0000000000000E54D000100000965950034AAA868007000B00000004008011A
...    B130001020304050607080B101112131921252627284A44A9440000840


@{IDLE_check}
...    FIVE-GS-MM-REGISTERED
...    UE1: IS IDLE


@{MPS_qos_check}
...    Setup QosFlow with QFI:1 fiveQI:8
...    QoS Routing Table
...    releasePreference-r16 supported

@{INACTIVE_check}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    NR_RRC_INACTIVE

@{releasePreference_check}
...     QoS Routing Table
...     releasePreference-r16 supported

@{partial_admission}
...    QoS Routing Table
...    Setup QosFlow with QFI:1 5QI:8

@{fail_AC}
...    Setup QosFlow with QFI:2 5QI:6

@{I006_UE1_2DRB_check}
...    Setup QosFlow with QFI:1 5QI:8
...    Setup QosFlow with QFI:2 5QI:6
...    QoS Routing Table

@{resume_reject_check_I006_I007}
...    resumeCause mo-Signalling
...    UE1: RRC Reject was received

@{fallback_check_emergency}
...    resumeCause emergency
...    rrcSetup
...    rrcReconfigurationComplete

@{fallback_check_HPA}
...    resumeCause highPriorityAccess
...    rrcSetup
...    rrcReconfigurationComplete

@{fallback_check_mps}
...    resumeCause mps-PriorityAccess
...    rrcSetup
...    rrcReconfigurationComplete

@{RRC_Reject}
...    RRC Reject was received
...    UE1: Is INACTIVE

@{RRC_Reject_UE3}
...    RRC Reject was received
...    UE3: Is INACTIVE

@{resume_check}
...    resumeCause mt-Access
...    UE2: Received RRC Release
...    rrcResumeComplete


@{PM_Counters_Check_I010}
...    NRCELL-1:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=0

@{PM_Counters_Check_I006_I007}
...    NRCELL-2:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=1
...    NRCELL-1:${NRRCC_RRC_RESUME_REQUEST1}=1
...    NRCELL-1:${NRRCC_RRC_RESUME_SUCC}=0
...    NRCELL-1:${NRRCC_RRC_RESUME_REJECT}=1

@{PM_Counters_Check_I005}
...    NRCELL-1:${NRRCC_RRC_RESUME_REQUEST1}=4
...    NRCELL-1:${NRRCC_RRC_RESUME_SUCC}=0
...    NRCELL-1:${SA_RRC_RESUME_FAIL_OVLCP}=1
...    NRCELL-1:${NRRCC_RRC_RESUME_FALLBACK_ATT}=3
...    NRCELL-1:${NRRCC_RRC_RESUME_FALLBACK_SUCC}=3
...    NRCELL-1:${NRRCC_RRC_STPSUCC_MPS}=0
...    NRDU-1:${NRRCD_RRC_STPSUCC_MPS}=0

@{PM_Counters_Check_I003}
...    NRCELL-1:${NRRCC_RRC_STPSUCC_HPA}=0
...    NRDU-1:${NRRCD_RRC_STPSUCC_HPA}=0

@{PM_Counters_Check_I001}
...    NRCELL-1:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=1
...    NRCELL-1:${NRRCC_RRC_RESUME_REQUEST1}=1
...    NRCELL-1:${NRRCC_RRC_RESUME_SUCC}=1
...    NRCELL-1:${SA_UE_CTX_REL_PREEM}=1
...    NRCELL-1:${NG_FLOW_REL_GNB_PREEM}=1

${NRRCC_RRC_REL_WITH_SUSP_NRNAU}    M55124C00006    #This counter provides the total number of RRC releases with suspendConfig IE sent
#from the gNB-CU.
${NRRCC_RRC_RESUME_REQUEST1}    M55124C00007    #This counter provides the total number of RRCResumeRequests1 received at the gNB-CU.
${NRRCC_RRC_RESUME_SUCC}    M55124C00010    #This counter provides the total number of successful RRC Resume procedures from RRC_INACTIVE
#to RRC_CONNECTED state.
${NRRCC_RRC_RESUME_REJECT}    M55124C00009    #This counter provides the total number of unsuccessful RRC resume requests due to
#admission control failures.
${SA_RRC_RESUME_FAIL_OVLCP}    M55124C00015    #This counter provides the number of RRC Resume attempts in SA mode for any establishment
#cause except "emergency", "highPriorityAccess", "mps-PriorityAccess", or "mcs-PriorityAccess" that failed due to C-Plane overload.
${NRRCC_RRC_RESUME_FALLBACK_ATT}    M55124C00013    #This counter provides the total number of attempts when RRC connection resumes fallbacks to
#RRC setup procedure.
${NRRCC_RRC_RESUME_FALLBACK_SUCC}    M55124C00014    #This counter provides the total number of successful RRC setup procedures when RRC
#connection resumes fallbacks to RRC setup.
${NRRCC_RRC_STPSUCC_MPS}    M55124C09003    #The total number of RRC connection establishment completions for mps-PriorityAccess Calls.
${NRRCD_RRC_STPSUCC_MPS}    M55127C03003    #Number of RRC Setup Complete messages for Multimedia Priority Service received at gNB-DU
${NRRCC_RRC_STPSUCC_HPA}    M55124C09001    #The total number of RRC connection establishment completions for High Priority Access Calls.
${NRRCD_RRC_STPSUCC_HPA}    M55127C03001    #The total number of RRC connection establishment completions for High Priority Access Calls.
${SA_UE_CTX_REL_PREEM}    M55125C11501    #This counter describes the number of UE Context Releases for SA users due to preemption.
${NG_FLOW_REL_GNB_PREEM}    M55125C11504    #This counter describes the number of QosFlows that are released due to preemption reasons.

*** Test Cases ***
CB008225-ET-I001_Successful_transition_of_Suspended_UE_in_RRC_INACTIVE_to_RRC_CONNECTED_resume_of_SRBs_and_DRBs_With_UE_context_preemption
    [Documentation]
    ...    1. The purpose of this test case is to check gNB behavior for UE in RRC_INACTIVE state that is successfully transitioned to
    ...    RRC_CONNECTED state in case of UE context or DRB resource shortage and ARP-based preemption enabled. Successful Resume procedure.
    ...    2. Configuration:
    ...    GNB cell1:
    ...    actUserPreemption/actRrcInactState enabled.
    ...    maxNumOfRrcSA=2.
    ...    3. Test Case Steps:
    ...    a.Set UE1 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request.
    ...    trigger UE1 attach to Gnb cell1 as normal call with priority=2, PCI&PVI=true, then send UAI to trigger UE1 turn to RRC_inactive state.
    ...    b.UE2 attach to cell1 as normal call with priority=3, PVI=true, UE3 attach to cell1 as normal call with priority=4, PVI=false.
    ...    c.Tigger UE1 RRC resume with cause mt_Access.
    ...    4. Expect result:
    ...    a.UE1 attach to cell1 successfully, then turn to RRC_inactive state.
    ...    b.UE2 and UE3 attach successfully.
    ...    c.UE1 turns back to RRC_connected state, UE2 been preempted and released.
    ...    5. CheckPoints:
    ...    a.Check UE1 RRC release message contains SuspendConfig IE.
    ...    b.Check UE1 turns to RRC_connected with resume procedure.
    ...    c.Check UE2 released due to preempted.
    ...    d.Check counter.
    [Tags]    owner-lena.zhuo    I001    AP_REG
    OnlineParamChange    ${delta_I001}
    Clear Counter Files
    UE turn to inactive    ue_id=1    cell_id=1    priority=2
    multi UE attach
    RRC Resume    ue_id=1    cell_id=1    cause=mt_Access    pass_regexp=${resume_check}
    Release Ues    ue_id=3,1
    check counters    pm_counters_expression=${PM_Counters_Check_I001}
    OnlineParamChange    ${recovery_I001}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=2


Run UL Traffic
    [Arguments]    ${ue_id}=1    ${Tput_ul}=4000000
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 bps=${Tput_ul} dir=ul
    ...    pass_regexp=Started Uplink Internal traffic

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=4
    Update Cfg    set_qosflow id=5 5qi=6
    Update Cfg    set_qosflow id=6 5qi=7
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1

Run UL Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_ul}=4000000
    Run UL Traffic    ${ue_id}    ${Tput_ul}
    Verify Throughput UL TP    ${ue_id}    ${Tput_ul}

Verify Throughput UL TP
    [Arguments]    ${ue_id}=1    ${Tput_ul}=5    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    run keyword and ignore error    Should Be True    ${ul_throughput}>${Tput_ul}/1000*0.9


OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair


UAI to Inactive and check status should be IDLE
    [Arguments]    ${ue_id}=1    ${state}=inactive
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=${state}    pass_regexp=${IDLE_check}


UE turn to idle with MPS call
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${cmd}
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    UE setup with MPS call
    UAI to Inactive and check status should be IDLE


UE setup with MPS call
   [Arguments]    ${ue_id}=1     ${cause}=mps-PriorityAccess
    Execute Egate Command    qosflow_modify qos_flow=1 priority=3
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=${MPS_chechk}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${MPS_qos_check}
    Run UL Traffic And Verify Throughput    ue_id=${ue_id}    Tput_ul=60000

UE turn to inactive timer based
    [Arguments]    ${ue_id}    ${cell_id}    ${priority}
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ${cmd}
    ICS With Preemption    ue_id=${ue_id}    cell_id=${cell_id}    pvi=pre_emptable    priority=${priority}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul    pass_regexp=${INACTIVE_check}    timeout=21s

UE With 2DRBs turn to inactive
    [Arguments]    ${ue_id}    ${cell_id}
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ${cmd}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Attach UE with 2 DRBs    ${ue_id}
    Run UL Traffic And Verify Throughput    ue_id=${ue_id}    Tput_ul=60000
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul    pass_regexp=${INACTIVE_check}    timeout=21s

Attach UE with 2 DRBs
    [Arguments]    ${ue_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=1 priority=7 pvi=pre_emptable
    Execute Egate Command    qosflow_modify qos_flow=5 priority=5 pvi=pre_emptable
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=5
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${I006_UE1_2DRB_check}

ICS With 2DRBs
    [Arguments]    ${ue_id}    ${cell_id}    ${pvi}    ${priority}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=1 priority=${priority} pci=may_trigger_pre_emption pvi=${pvi}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${releasePreference_check}
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority} pvi=${pvi} default=on
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1    pass_regexp=QoS Routing Table
    Run UL Traffic And Verify Throughput    ue_id=${ue_id}    Tput_ul=60000

Attach UE3 With Partial Admission Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=1 priority=5 pvi=pre_emptable
    Execute Egate Command    qosflow_modify qos_flow=5 priority=7 pvi=pre_emptable
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=5
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${partial_admission}    fail_regexp=${fail_AC}

Attach UE2 with 1DRB and start traffic
    [Arguments]    ${ue_id}    ${cell_id}
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${releasePreference_check}
    Run UL Traffic And Verify Throughput    ue_id=${ue_id}    Tput_ul=60000

RRC Resume With Reject
    [Arguments]    ${ue_id}    ${cell_id}    ${cause}    ${pass_regexp}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}

ICS With Preemption
    [Arguments]    ${ue_id}    ${cell_id}    ${pvi}    ${priority}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=1 priority=${priority} pci=may_trigger_pre_emption pvi=${pvi}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-Signalling
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${releasePreference_check}
    Run UL Traffic And Verify Throughput    ue_id=${ue_id}    Tput_ul=60000

Attach UE2 and start traffic
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    ICS With 2DRBs    ue_id=2    cell_id=1    pvi=pre_emptable    priority=4

Attach UE3 With Preemption Successful
    Update UE capa    ue_id=3    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    ICS With Preemption    ue_id=3    cell_id=1    pvi=not_pre_emptable    priority=3
    Execute Egate Command    qosflow_modify qos_flow=2 priority=4 pvi=pre_emptable default=on
    Execute Egate Command    ue_pdu_session_setup ue=3 pdu=2 gw=3 nwslice=1    pass_regexp=QoS Routing Table
    Run UL Traffic And Verify Throughput    ue_id=3    Tput_ul=60000

Multi UE attach then suspend with UAI and Trigger Overload
    Set Ovlthreshold On All Bbmods    20
    Sa Ue Attach    1
    Sa Ue Attach    2
    Sa Ue Attach    3
    Sa Ue Attach    4
    UAI for I005
    Set Ovlthreshold On All Bbmods    0

UAI for I005
    UAI    1
    UAI    2
    UAI    3
    UAI    4

RRC Resume for I005 and I008
    [Arguments]    ${ue_id}    ${cell_id}    ${cause}    ${pass_regexp}    ${msg}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=${cause} msg=${msg}
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}    fail_regexp=Initial Context Setup Failure

Sa Ue Attach
    [Arguments]    ${ue_id}=1
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    Reset Config
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=1
    Core network assistance    ${ue_id}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-Signalling
    Execute Egate Command    qosflow_modify default=on qos_flow=1 priority=15
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

Reset Config
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    Execute Egate Command    ue_param reset

UAI
    [Arguments]    ${ue_id}=1    ${state}=inactive
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=${state}    pass_regexp=${INACTIVE_check}

Onlinechange then resume UE3 and Cancel Overload
    OnlineParamChange    ${online_modify_I005}
    RRC Resume for I005 and I008    ue_id=3    cell_id=1    cause=mps_PriorityAccess    pass_regexp=${fallback_check_mps}    msg=resume_request_1
    Set Ovlthreshold On All Bbmods    20

Cancel Overload And Common Test Teardown
    Common Test Teardown And Stop Capture Logs
    Set Ovlthreshold On All Bbmods    20

UE turn to inactive
    [Arguments]    ${ue_id}    ${cell_id}    ${priority}
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Update UE capa    ue_id=${ue_id}    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-Signalling
    Execute Egate Command    ${cmd}
    ICS With Preemption    ue_id=${ue_id}    cell_id=${cell_id}    pvi=pre_emptable    priority=${priority}
    UAI    ue_id=${ue_id}    state=inactive

multi UE attach with EC
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=2 ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    Update UE capa    ue_id=3    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    Execute Egate Command    ${cmd}
    ICS With Preemption    ue_id=2    cell_id=1    pvi=pre_emptable    priority=15
    ICS With EC    ue_id=3    cell_id=1

Core network assistance
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id}
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${cmd}

ICS With EC
    [Arguments]    ${ue_id}    ${cell_id}
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1 request_type=initial-emergency-request
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Execute Egate Command    qosflow_modify qos_flow=2 default=on priority=1
    Execute Egate Command    qosflow_modify qos_flow=3 priority=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=3
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ${cmd}    pass_regexp=${releasePreference_check}
    Run UL Traffic And Verify Throughput    ue_id=${ue_id}    Tput_ul=60000

multi UE attach exceed maxNum
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    Update UE capa    ue_id=3    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    ICS With Preemption    ue_id=2    cell_id=1    pvi=pre_emptable    priority=15
    ICS fail due to exceed maxNum    ue_id=3    cell_id=1

RRC Resume
    [Arguments]    ${ue_id}    ${cell_id}    ${cause}    ${pass_regexp}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=${cell_id} cause=${cause}
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}    fail_regexp=Initial Context Setup Failure
    Run UL Traffic And Verify Throughput    ue_id=${ue_id}    Tput_ul=60000

ICS fail due to exceed maxNum
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=rrcReject    fail_regexp=UE now in NG RM Register

multi UE attach
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    Update UE capa    ue_id=3    SA_Capa_perUE_Full=${UE_Capa_Support_UAI_VONR}
    ICS With Preemption    ue_id=2    cell_id=1    pvi=pre_emptable    priority=3
    ICS With Preemption    ue_id=3    cell_id=1    pvi=not_pre_emptable    priority=4

