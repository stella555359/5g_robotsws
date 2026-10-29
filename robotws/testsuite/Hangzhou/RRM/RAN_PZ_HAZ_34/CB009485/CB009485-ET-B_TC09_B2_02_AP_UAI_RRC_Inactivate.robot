*** Settings ***
Documentation
...    author: Zhu Yuhua
...    contact: yuhua.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO
...            owner-yuhua.zhu   team-PZ3_7    release-SBTS26R1
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${BTS_NUMBER}     2
${SKIP_ON_AIR}    ${True}
${SYSCOM_FLAG}    ${True}
${SNAPSHOT_FLAG}    pass:True,fail:True
${AP_BIP_FLAG}    ${False}
${GNB_BIP_FLAG}    ${False}
${EMIL_FLAG}    ${False}
# don't change the following setting
${AUTO_ANALYSIS_FLAG}    ${False}
${TTITRACE_FLAG}    ${False}
${SOS_REPORT_FLAG}    pass:False,fail:False
${SOS_REPORT_STARTUP_1_FLAG}    pass:False,fail:False
@{PARAMS_IN_SWCONFIG}
...    0x1002A=1    #ERadCcs_AaTraceSwConfUsed
...    0x5A0609=1    #L2-HI rdDebugPcmdNrt
...    0x5A0610=1    #L2-HI rdDebugPcmdRt
...    0x5B0609=1    #L2-HI rdDebugPcmdNrt
...    0x5B0610=1    #L2-HI rdDebugPcmdRt
...    0x57000E=1    #enable L2-LO NRT PCMD debug logs
...    0x58057a=4    #L2-PS rdFeatureFlagBitmapLevel 4DEBUG
...    0x58057b=8    #L2-PSrdFeatureFlagBitmap0 8PF_METRIC
...    0x580582=3    #L2-PSrdFeatureFlagBitmap7 3RAT1_ALLOC
...    0x58057f=0x10000000     #L2-PSrdFeatureFlagBitmap4
@{PARAMS_IN_SWCONFIG_GNB2}
...    0x1002A=1    #ERadCcs_AaTraceSwConfUsed
...    0x5A0609=1    #L2-HI rdDebugPcmdNrt
...    0x5A0610=1    #L2-HI rdDebugPcmdRt
...    0x5B0609=1    #L2-HI rdDebugPcmdNrt
...    0x5B0610=1    #L2-HI rdDebugPcmdRt
...    0x57000E=1    #enable L2-LO NRT PCMD debug logs
...    0x58057a=4    #L2-PS rdFeatureFlagBitmapLevel 4DEBUG
...    0x58057b=8    #L2-PSrdFeatureFlagBitmap0 8PF_METRIC
...    0x580582=3    #L2-PSrdFeatureFlagBitmap7 3RAT1_ALLOC
...    0x58057f=0x10000000     #L2-PSrdFeatureFlagBitmap4

${TCE_IP}   10.0.1.1
${TCE_PORT_GNB1}  49100
${TCE_PORT_GNB2}  49151

@{online_modify_H001}
...    NRBTS:drbRrcInactInactivityTimerSA=30
...    NRBTS:srbInactivityTimerSA=20

@{online_recovery_H001}
...    NRBTS:drbRrcInactInactivityTimerSA=7200
...    NRBTS:srbInactivityTimerSA=600

@{online_modify_H003}
...    NRBTS:drbRrcInactInactivityTimerSA=30
...    NRBTS:srbInactivityTimerSA=20
...    NRCELL:idleMMSteeringAlgo=non CA aware
...    NRBTS/SNSSAI-1:drbRrcInactInactivityTimerSA=20
...    NRBTS/SNSSAI-2:drbRrcInactInactivityTimerSA=10
...    NRBTS:activityNotificationLevelSA=drb

@{online_recovery_H003}
...    NRBTS:drbRrcInactInactivityTimerSA=7200
...    NRBTS:srbInactivityTimerSA=600
...    NRCELL:idleMMSteeringAlgo=CA aware
...    delete:NRBTS/SNSSAI-1:drbRrcInactInactivityTimerSA
...    delete:NRBTS/SNSSAI-2:drbRrcInactInactivityTimerSA
...    delete:NRBTS:activityNotificationLevelSA

@{online_modify_H007}
...    MRBTS-1/NRBTS-1/NRCAIMP-1/NRCAIMS-1:sCellConfig:nrarfcnDl=636666
...    NRBTS:drbRrcInactInactivityTimerSA=30
...    NRBTS:srbInactivityTimerSA=20

@{online_recovery_H007}
...    MRBTS-1/NRBTS-1/NRCAIMP-1/NRCAIMS-1:sCellConfig:nrarfcnDl=658000
...    NRBTS:drbRrcInactInactivityTimerSA=7200
...    NRBTS:srbInactivityTimerSA=600

${ue_nr_Capa_support_IdleMMSteering}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A06
...    7D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D88DAC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473
...    E618F28581C0E1E13FFE00000FFF800000B80001C0000080083C3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E2080000
...    30B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000
...    E140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E
...    230000020B02B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0210740000003804808D00A20
...    26C04182002E8018A10851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F022408103639F0
...    22408103639F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF810206C73E0003220318C631
...    8C6318C6318C603D05C0078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C010
...    00008008000050040020080200800006004000038020010000000400004002000024010000060080000A0040000580200102409004000060
...    19CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA
...    48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A555
...    74AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142C02F012A05028140A05028140A05028140A05028140A050280038
...    4040300601002004202004010080600C20100200404030060100C018202018030080600C201002004040300601002004402018030080600C
...    020180304040080201002008002004008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C96A51000
...    0210

${ue_nr_Capa_support_CA_AWARE_IdleMMSteering}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D89981AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0E070F05C00FFC0070005F0005C0000E0541B02F582308682041E20D00656C98AB121CFB0
...    27C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4DD608C21A0810748340185B262A88873E238F11C7A06
...    7D813E31CF9863CA1607038782E007FE003801FF8002E0000702A0D88DAC1184341020F1068032B64C55890E7C471EC09F1891C790E7D473
...    E618F28581C0E1E13FFE00000FFF800000B80001C0000080083C3C4C000E058000010B0102A0F0A000388C0000042C0AC3C46000E2080000
...    30B02B0F0A00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000
...    E140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E
...    230000020B02B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0210740000003804808D00A20
...    26C04182002E8018A10851226C73E1C28913639F0E14489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F022408103639F0
...    22408103639F022408103639F022408103639F022408103639F022408103639F022408103639F0214081B1CF810206C73E0003220318C631
...    8C6318C6318C603D05C0078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C010
...    00008008000050040020080200800006004000038020010000000400004002000024010000060080000A0040000580200102409004000060
...    19CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA
...    48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A555
...    74AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142C02F012A05028140A05028140A05028140A05028140A050280038
...    4040300601002004202004010080600C20100200404030060100C018202018030080600C201002004040300601002004402018030080600C
...    020180304040080201002008002004008D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C96A51000
...    0210

${ue_eutra_nr_Capa_support_IdleMMSteering}    SEPARATOR=
...    110C080160023D0004100000C4000000000204E003580010200806004008180100200804

@{INACTIVE_check_H001}
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    NR_RRC_INACTIVE

@{INACTIVE_check_H003}
...    freqPriorityListEUTRA
...    carrierFreq 300
...    freqPriorityListNR
...    carrierFreq 636576
...    cellReselectionPriority 7
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    NR_RRC_INACTIVE

@{INACTIVE_check_H007}
...    freqPriorityListEUTRA
...    carrierFreq 300
...    freqPriorityListNR
...    carrierFreq 146800
...    cellReselectionPriority 7
...    carrierFreq 636576
...    SuspendConfig
...    fullI_RNTI
...    shortI_RNTI
...    ran-AreaCodeList
...    t380
...    NR_RRC_INACTIVE

@{releasePreference_check}
...     QoS Routing Table
...     releasePreference-r16 supported

@{HO_from_GNB_to_SIMGNB}
...    rrcReconfigurationComplete
...    Inter-eNB handover from EXT_ENB-2.1 to ENB-4.1 performed

@{HO_from_SIMGNB_to_GNB}
...    rrcReconfigurationComplete
...    Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed

@{PM_Counters_Check_H001}
...    NRCELL-1:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=1

@{PM_Counters_Check}
...    NRCELL-1:${NRRCC_RRC_RELEASE_IMM_NR}=1
...    NRCELL-1:${NRRCC_RRC_REL_WITH_SUSP_NRNAU}=1

${NRRCC_RRC_REL_WITH_SUSP_NRNAU}    M55124C00006
#Number of RRC Releases with suspension for non-RNA update resume cause
${NRRCC_RRC_RELEASE_IMM_NR}    M55124C05501
#Number of RRC RELEASE messages with dedicated cell reselection priorities and NR primary target

${BearerContextInactivityNotification}    e1ap.procedureCode == 13
${CUUEReleaseRecord_F}    nsetapx.CuVendorExtensionRecordDataType == 0

${CUUEReleaseRecord_RRCInactive}    nsetapx.reason == 4

*** Test Cases ***
CB009485_SR_B_TC09_B2_02_Verify gNB-CU UE Release Trace Record is reported for Successful transition of UE in RRC_CONNECTED state to RRC_INACTIVE
    [Documentation]
    ...    1. The purpose of this test case is to check the gNB behavior for UE in RRC_CONNECTED state that is successfully
    ...    transitioned to RRC_INACTIVE state including CA/non CA aware idle mode mobility steering based on the UE inactivity.
    ...    Successful suspend procedure.
    ...    2. Test Case Steps:
    ...    a.Set UE1 Core Network Assistance Information for RRC INACTIVE state in the Initial Context Setup Request.
    ...    trigger UE1 register to Cell1 with PDU 1 Slice 1 and start traffic.
    ...    b.Setup new PDU with slice2 on UE1 and start traffic.
    ...    c.stop traffic on both PDUs for UE1 and stop traffic.
    ...    d.Wait until all DRBs and SRBs timer expired.UE1 is released with RRC: RRCRelease include suspendConfig IE is built
    ...    but cellReselectionPriorities IE is not built due to UE CA combination is not match GNB's CA,and UE enquiry will not be
    ...    trigger for LTE band
    [Tags]    QC_302781    owner-jia.pan    H001
	log to console    Case1: H001 RRC Connect to Inative with RANSharing_CA_aware
    OnlineParamChange    ${online_modify_H001}
    Clear Counter Files    wait=${False}
	start to capture wireshark log    rrc_inactivity
    Sa Ue Attach
    add pdu new slice
    Stop traffic for H001
    check counters    pm_counters_expression=@{PM_Counters_Check_H001}
	${CUUEReleaseRecord}    create list    ueReleaseRecord/data-r1/trigger=gNB
	...                                       ueReleaseRecord/data-r1/reason=rrcInactive
	...                                       ueReleaseRecord/data-r1/rrcReleaseSendTime=[RE].*
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    rrc_inactivity    ${CUUEReleaseRecord_RRCInactive}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${CUUEReleaseRecord_RRCInactive}
    ...                       check_fields=${CUUEReleaseRecord}
	...                       packet_num=all
	Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off
    OnlineParamChange    ${online_recovery_H001}
	log to console    Case2: H007 RRC Connect to Inative with UAI and RANSharing_CA_aware
    OnlineParamChange    ${online_modify_H007}
    clear counter files    wait=${True}
	start to capture wireshark log    rrc_inactivity_UAI
    Sa Ue Attach for H007
    add pdu new slice    2
    Trigger UE1 send UEAssistanceInformation
    check counters    pm_counters_expression=@{PM_Counters_Check}
	${CUUEReleaseRecord}    create list    ueReleaseRecord/data-r1/trigger=gNB
	...                                       ueReleaseRecord/data-r1/reason=rrcInactive
	...                                       ueReleaseRecord/data-r1/rrcReleaseSendTime=[RE].*
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    rrc_inactivity_UAI    ${CUUEReleaseRecord_RRCInactive}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${CUUEReleaseRecord_RRCInactive}
    ...                       check_fields=${CUUEReleaseRecord}
	...                       packet_num=all
	Execute Egate Command    ue_deregister id=2 ue_deregister_type=switch_off
    OnlineParamChange    ${online_recovery_H007}
	log to console    Case3: H003 RRC Connect to Inative with UAI and RANSharing_Non_CA_aware
    OnlineParamChange    ${online_modify_H003}
    clear counter files    wait=${True}
	start to capture wireshark log    rrc_inactivity_RANSharing
    Sa Ue Attach for H003
    Inter GNB HO From Nrcell1 to gnb sim
    Inter GNB HO From gnb sim to Nrcell1
    add pdu new slice    3
    Stop traffic for H003
    check counters    pm_counters_expression=@{PM_Counters_Check}
	${CUUEReleaseRecord}    create list    ueReleaseRecord/data-r1/trigger=gNB
	...                                       ueReleaseRecord/data-r1/reason=rrcInactive
	...                                       ueReleaseRecord/data-r1/rrcReleaseSendTime=[RE].*
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    rrc_inactivity_RANSharing    ${CUUEReleaseRecord_RRCInactive}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${CUUEReleaseRecord_RRCInactive}
    ...                       check_fields=${CUUEReleaseRecord}
	...                       packet_num=all
    [Teardown]    H003_Teardown

*** Keywords ***
Perform Steps After Onair
    Start TCE    ${TCE_PORT}

H001_Teardown
    OnlineParamChange    ${online_recovery_H001}
    Common Test Teardown And Stop Capture Logs

H003_Teardown
    OnlineParamChange    ${online_recovery_H003}
    Common Test Teardown And Stop Capture Logs

H007_Teardown
    OnlineParamChange    ${online_recovery_H007}
    Common Test Teardown And Stop Capture Logs

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${SA_Capa_NR}=none    ${SA_Capa_EUTRAN}=none    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_NR} ue_eutra_nr_capabilities=${SA_Capa_EUTRAN}
    Execute Egate Command    ${cmd}

Core network assistance
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id}
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${cmd}
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id}
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=300
    Execute Egate Command    ${cmd}

Core network assistance for SimGNB
    [Arguments]    ${ue_id}=3
    ${cmd}    catenate    amf_ue_ctx_modify_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id}
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${cmd}
    ${cmd}    catenate    amf_ue_path_switch_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id}
    ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Execute Egate Command    ${cmd}

Sa Ue Attach
    [Arguments]    ${cell_id}=1    ${ue_id}=1
    Set sim gNB4 Parameter
    Update UE capa    ${ue_nr_Capa_support_IdleMMSteering}    ${ue_eutra_nr_Capa_support_IdleMMSteering}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Core network assistance    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

Sa Ue Attach for H003
    [Arguments]    ${cell_id}=1    ${ue_id}=3
    Set sim gNB4 Parameter
    Update UE capa    ${ue_nr_Capa_support_IdleMMSteering}    ${ue_eutra_nr_Capa_support_IdleMMSteering}    ${ue_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Core network assistance    ${ue_id}
    Core network assistance for SimGNB
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

Sa Ue Attach for H007
    [Arguments]    ${cell_id}=1
    Set sim gNB4 Parameter
    Update UE capa    ${ue_nr_Capa_support_CA_AWARE_IdleMMSteering}    ${ue_eutra_nr_Capa_support_IdleMMSteering}    2
    Execute Egate Command    ue_change_location id=2 enb=2 cell=${cell_id}
    Core network assistance    2
    Execute Egate Command    ue_register id=2    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=2 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=2 pdu=1 gw=1 nwslice=1    ${releasePreference_check}

Trigger UE1 send UEAssistanceInformation
    Execute Egate Command    ue_assistance_send_nr ue_id=2 PreferredRRCState=inactive    pass_regexp=${INACTIVE_check_H007}


Activation of Subscriber Trace From AP
    ${cmd}    Catenate    amf_ue_ics_param id=1 ue=1 object_id=1 location_reporting_reference_id=1 trace_activation=on
    ...    trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1 trace_depth=minimum
    ...    ifaces_to_trace=NG-C,Xn-C,Uu,E1,F1-C tce_ip=${tce_ip}
	Execute Egate Command    ${cmd}
	#Execute Egate Command    amf_ue_ics_param id=1 ue=1

Set sim gNB4 Parameter
    Execute Egate Command    sim_debug_log level=0
    Execute Egate Command    sim_debug_log level=4 mme=1
    Execute Egate Command    sim_debug_log level=0 uec=1
    Execute Egate Command    sim_debug_log level=0 enb=4
    Execute Egate Command    sim_trace enb=4 protocol=xn on
    Execute Egate Command    gnb_xn_setup_param id=4 reset
    Execute Egate Command    gnb_xn_link_up gnb=4 target=2    GNB-4: XnAP Link with GNB-2
    Execute Egate Command    gnb_xn_link_up gnb=4 target=2    GNB-4: XnAP Link with GNB-2
    Execute Egate Command    gnb_param id=4 xn_listening_socket=on send_xn_setup=true measEvent=A2 measEvent=A3 sa_ho=xn_based

add pdu new slice
    [Arguments]    ${ue_id}=1    ${gateway}=2    ${nwslice_id}=2    ${pdu_id}=2
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice_id} gw=${gateway}    QoS Routing Table
    Send Throuput    ${ue_id}
    Verify Throuput    ${ue_id}    5
    Send Throuput for PDU2    ${ue_id}
    Verify Throuput    ${ue_id}    10

Inter GNB HO From Nrcell1 to gnb sim
    ${measid}    get nr meas id for specific type and frequency    ue_id=3    carrierfreq=636576    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=3 meas_id=${measid} event=A2 srsrp_nr=25
    ...    pass_regexp=eventA3
    ${measid}    get nr meas id for specific type and frequency    ue_id=3    carrierfreq=513150    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=3 meas_id=${measid} event=A3 srsrp_nr=55 phycell_id=382 nrsrp_nr=80
    ...    pass_regexp=${HO_from_GNB_to_SIMGNB}

Inter GNB HO From gnb sim to Nrcell1
    ${measid}    get nr meas id for specific type and frequency    ue_id=3    carrierfreq=513150    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=3 meas_id=${measid} event=A2 srsrp_nr=2
    ...    pass_regexp=Reconfiguration procedure completed successfully
    ${measid}    get nr meas id for specific type and frequency    ue_id=3    carrierfreq=636576    event_type=A3
    Execute Egate Command    ue_measurement_send_nr id=3 meas_id=${measid} event=A3 srsrp_nr=55 phycell_id=50 nrsrp_nr=80
    ...    pass_regexp=${HO_from_SIMGNB_to_GNB}

Modify Cfg
    Update Cfg    set_amf_region id=1 tac_list=0,200,300 plmn=311:489,311:500
    Update Cfg    set_nwslice id=1 snssai=0x01:0xFFFFFF default=on ue=all amf_region_id=1 plmn_list=311:489,311:500
    Update Cfg    set_nwslice id=2 snssai=0x01:0xd143a5 ue=all amf_region_id=1 plmn_list=311:489,311:500
    ${set_gnb4}    catenate    set_gnb id=4 type=simulated plmn=311:489 xn=10.0.1.124 ng=10.0.1.125 gnb_id=0x24:22
    ...    daemon=10.0.2.1:22222 x2_peers=none nssai=0x1:0xFFFFFF amf=1
    Update Cfg    ${set_gnb4}
    Update Cfg    gnb_endc_param id=4 use_nr_ran_cont=true
    Update Cfg    gnb_endc_param id=4 scg_dl_dist_percent=0
    Update Cfg    gnb_endc_param id=4 enable_dud_poll_bit=0
    Update Cfg    gnb_param id=4 xn_listening_socket=on send_xn_setup=true
    ${set_gnb4_cell1}    catenate    set_cell id=1 gnb=4 pci=127:1 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999
    ...    nr_arfcn=513234:513234 gscn=6414 mandatory_for_activation=off
    Update Cfg    ${set_gnb4_cell1}

Send Throuput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

Send Throuput for PDU2
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=2 qfi=1 dir=ul mbps=10 trf_id=16    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic

Verify Throuput
    [Arguments]    ${ue_id}=1    ${ul}=5
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Stop traffic for H001
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2 qfi=1 dir=ul
    ...    pass_regexp=${INACTIVE_check_H001}    fail_regexp=cellReselectionPriority    timeout=31s

Stop traffic for H003
    [Arguments]    ${ue_id}=3
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=2 qfi=1 dir=ul
    ...    pass_regexp=${INACTIVE_check_H003}    timeout=21s
