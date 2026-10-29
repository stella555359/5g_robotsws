*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-zhuo.lena
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008225    release-SBTS23R4
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{encrypt_algo}
...    @{PARAMS_FOR_IdleMMSteering}
...    @{8225_related}
...    @{UAI}

@{encrypt_algo}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0

@{UAI}
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:timerReleasePreferenceProhibit=s3
...    NRBTS:outOfConnectedPreference=inactive

@{PARAMS_FOR_IdleMMSteering}
...    NRBTS:actIdleMMSteering=true
...    NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL:cellReselectionPriority=5
...    NRCELL:cellReselectionSubPriority=oDot4
...    NRCELL:idleMMServCelResWeight=55
...    NRCELL:idleMMSteeringPercentageOfUes=100
...    NRCELL:idleMMSteeringWRREnabled=true
...    NRCELL:t320=min5
...    MRBTS-1/MNL-1/MNLENT-1/PMCADM-1:reportingIntervalPm=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRRCC=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=disabled
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRBTS-1/NRCELL:idleMMSteeringAlgo=CA aware
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:cellReselectionPriority=7
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:cellReselectionSubPriority=oDot2
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:dlCarrierFreq=368400
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:freqBandIndicatorNR=3
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:idleMMNrCelResWeight=61
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:ssbScs=15KHz
...    MRBTS-1/NRBTS-1/NRCAIMP-1:pCellConfig:nrarfcnDl=368400
...    MRBTS-1/NRBTS-1/NRCAIMP-1/NRCAIMS-1:sCellConfig:nrarfcnDl=153400

@{8225_related}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:drbRrcInactInactivityTimerSA=20
...    NRBTS:drbInactivityTimerSA=60
...    NRBTS:srbInactivityTimerSA=60
...    NRBTS:maxUeRrcInactTime=2
...    NRBTS:rrcInactIMMSteeringEnabled=true
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

@{OnlineParam_for_H009}
...    NRCELL:idleMMSteeringAlgo=non CA aware

@{OnlineParam_for_cellReselection}
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:cellReselectionPriority=4
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:cellReselectionSubPriority=oDot2
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:dlCarrierFreq=643392
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:idleMMNrCelResWeight=51
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:ssbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:qOffsetFreq=-20dB
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:qRxLevMin=-60
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:threshXHighP=30
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:threshXHighQ=2
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:threshXLowP=22
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:threshXLowQ=0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:tReselectionNr=1

${UE_Capa_Support_CAaware}    SEPARATOR=
...    E1A00000074E5A031E000384A0003C1260C80008785800C40340260300C07010A8D851AC10143404B2CA261E003D6C10101070EF1C39061C00103278FAB80027
...    800E0009E00151B133582028680965944C3C007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB28987800F5B0404041C3BC
...    70E418700040C9E3EAE0009E00380027800546C4ED6080A1A025965130F001EB608080838778E1C830E0008193C7D5400001400000A8D805AC10143400000060
...    07800F5B00000000000000000000000000000D55554D5555404F0F1340038500000002C040BC3C02000E0D8000010B0102006026C00219000078081448014080
...    0FFFFFFF86C0038003C1C1401C0C026007000683E008000000000000000200F2A6B0300020800004B2CA82000020000000E95555030068007000B00008404008
...    010100200420200801008020043562600020406080A0C0E10162022242632424A4C4E50940A510000210

@{INACTIVE_check_H006}
...    freqPriorityListNR
...    cellReselectionPriority 7
...    cellReselectionPriority 4
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    NR_RRC_INACTIVE

@{INACTIVE_check_H009}
...    freqPriorityListNR
...    carrierFreq 368400
...    carrierFreq 636576
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    NR_RRC_INACTIVE

@{INACTIVE_check_H009_online_change}
...    freqPriorityListNR
...    carrierFreq 368400
...    carrierFreq 636576
...    carrierFreq 643392
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    NR_RRC_INACTIVE

@{releasePreference_check}
...     QoS Routing Table
...     releasePreference-r16 supported

@{PM_Counters_Check_H006}
...    NRCELL-1:${NRRCC_RRC_RELEASE_IMM_NR}=1
...    NRCELL-1:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=1

@{PM_Counters_Check_H009}
...    NRCELL-1:${NRRCC_RRC_RELEASE_IMM_NR}=1
...    NRCELL-2:${NRRCC_RRC_RELEASE_IMM_NR}=1
...    NRCELL-1:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=1
...    NRCELL-2:${NRRCC_RRC_RESUME_REQUEST1}=1
...    NRCELL-2:${NRRCC_RRC_RESUME_REQUEST1_RNAU}=1
...    NRCELL-2:${NRRCC_RRC_REL_WITH_SUSP_RNAU}=1

${NRRCC_RRC_REL_WITH_SUSP_NRNAU}    M55124C00006    #This counter provides the total number of RRC releases with suspendConfig IE sent
#from the gNB-CU. 3612606470
${NRRCC_RRC_RELEASE_IMM_NR}    M55124C05501    #TThe number of times that Idle Mode Mobility steering algorithm has selected NR carrier
#frequency as primary target. 3612611965
${NRRCC_RRC_RESUME_REQUEST1}    M55124C00007    #This counter provides the total number of RRCResumeRequests1 received at the gNB-CU. 3612606471
${NRRCC_RRC_RESUME_REQUEST1_RNAU}    M55124C00011    #This counter provides the total number of RRCResumeRequest1 received at the gNB-CU for
#RNA update. 3612606475
${NRRCC_RRC_REL_WITH_SUSP_RNAU}    M55124C00012    #This counter provides the total number of RRC releases with suspendConfig IE sent from the
#gNB-CU in response to an RRC resume request for an RNA update. 3612606476

*** Test Cases ***

CB008225-ET-H006_Successful_transition_of_UE_in_RRC_CONNECTED_to_RRC_INACTIVE_Suspend_UEAssisInfo_outOfConnected_BTS_With_Non_RANSharing_CA_aware
    [Documentation]
    ...    1. The purpose of this test case is to check gNB behavior for UE in RRC_CONNECTED state that is successfully transitioned
    ...    to RRC_INACTIVE state including CA/non CA aware idle mode mobility steering based on the UE inactivity. Successful suspend procedure.
    ...    2. Configuration:
    ...    GNB cell1:
    ...    IdleMMSteering enable with CA aware Algo, Pcell configure as n3, scell configure as n28.
    ...    actRrcInactState enabled.
    ...    3. Test Case Steps:
    ...    a.Set UE1 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request.
    ...    trigger UE1 attach to Gnb cell1 with PDU 1.
    ...    b.Start UL traffic.
    ...    c.Tigger RRC: UEAssistanceInformation with ReleasePreference-r16=outOfConnected.
    ...    4. Expect result:
    ...    a.UE1 attach to cell1 successfully.
    ...    b.UL traffic start successfully, no loss.
    ...    c.UE turns to inactive state.
    ...    5. CheckPoints:
    ...    a.Check RRC release message contains SuspendConfig IE.
    ...    b.Check RRC release message contains cellReselectionPriorities IE.
    ...    c.Check UE turns to RRC inactive state.
    ...    d.Check counter.
    [Tags]    QC_302784    owner-lena.zhuo    H006
    Clear Counter Files    wait=${False}
    Update UE capa    ue_id=1    SA_Capa_perUE_Full=${UE_Capa_Support_CAaware}
    ICS With PDU    ue_id=1    cell_id=1
    Send UAI to GNB    ue_id=1    state=outOfConnected    pass_regexp=${INACTIVE_check_H006}
    check counters    pm_counters_expression=${PM_Counters_Check_H006}
    Release Ues    ue_id=1

CB008225-ET-H009_Successful_transition_of_UE_in_RRC_CONNECTED_to_RRC_INACTIVE_Suspend_RNA_Update_BTS_With_Non_RANSharing_Non_CA_aware
    [Documentation]
    ...    1. The purpose of this test case is to check gNB behavior for UE in RRC_CONNECTED state that is successfully transitioned
    ...    to RRC_INACTIVE state including CA/non CA aware idle mode mobility steering based on the UE inactivity. Successful suspend procedure.
    ...    2. Configuration:
    ...    GNB cell1:
    ...    IdleMMSteering enable with non CA aware Algo.
    ...    actRrcInactState enabled.
    ...    3. Test Case Steps:
    ...    a.Set UE2 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request.
    ...    trigger UE2 attach to Gnb cell-1 with PDU 1.
    ...    b.Start UL traffic.
    ...    c.Tigger RRC: UEAssistanceInformation with ReleasePreference-r16=outOfConnected.
    ...    d.Add new cell reselection candidate.
    ...    e.Trigger UE2 send RRCResumeRequest1 to cell-2 with rna_Update.
    ...    f.Deregister UE.
    ...    4. CheckPoints:
    ...    a.Check RRC release message contains SuspendConfig IE.
    ...    b.Check RRC release message contains cellReselectionPriorities IE.
    ...    c.Check RRC release message contains SuspendConfig IE after RNA update.
    ...    d.Check RRC release message contains updated cellReselectionPriorities IE.
    ...    e.Check counter.
    [Tags]    QC_305477    owner-lena.zhuo    H009
    OnlineParamChange    ${OnlineParam_for_H009}
    Clear Counter Files
    Update UE capa    ue_id=2    SA_Capa_perUE_Full=${UE_Capa_Support_CAaware}
    ICS With PDU    ue_id=2    cell_id=1
    UE Inactive
    check counters    pm_counters_expression=@{PM_Counters_Check_H009}
    Release Ues    ue_id=2

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=2

Send UAI to GNB
    [Arguments]    ${ue_id}=1    ${state}=inactive    ${pass_regexp}=${INACTIVE_check_H006}
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=${state}    pass_regexp=${pass_regexp}

Run UL Traffic
    [Arguments]    ${ue_id}=1    ${Tput_ul}=4000000
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 bps=${Tput_ul} dir=ul
    ...    pass_regexp=Started Uplink Internal traffic

ICS With PDU
    [Arguments]    ${ue_id}    ${cell_id}
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ${cmd}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    ${releasePreference_check}
    Run UL Traffic    ue_id=${ue_id}    Tput_ul=6000000

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair

UE Inactive
    [Arguments]    ${ue_id}=2
    Send UAI to GNB    ue_id=${ue_id}    state=outOfConnected    pass_regexp=${INACTIVE_check_H009}
    OnlineParamChange    ${OnlineParam_for_cellReselection}
    Execute Egate Command    ue_disp
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=2 cause=rna_Update
    Execute Egate Command    ue_nr_rrc_resume id=${ue_id}    pass_regexp=${INACTIVE_check_H009_online_change}
    Execute Egate Command    ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=2 cause=emergency
