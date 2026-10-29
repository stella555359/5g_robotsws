*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO

Resource         CB013233_Resource.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     Suite setup from scratch
...                 AND     Configure UTE ETH3 IPs
...                 AND     Perform SCF Delta Commissioning with ${drx_delta_file_name}
...                 AND     Start Log   btslog
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep   2s

Suite Teardown      Run keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Log   btslog    snapshot    sosreport

Documentation
...
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     The user scenario targets the DRX configuration for SA UE when it
...                               performs RRCResume procedure.
...                               RRCResume msg contains DRX config filled with values from selected DRX profile.
...                               There is no dedicated RRCReconfiguration to setup DRX after RRCResume
...
...
...             TEST SET NAME:    CB013233
...             TESTING SPLIT:    Refer CB013233 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB013233 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_26398



*** Variables ***
${wts_cfg_file}     basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts

${rad_params}=     0x890091=1

${sa_ue_id1}      ${51}
${sa_ue_id2}      ${52}
${sa_ue_id3}      ${53}
${sa_ue_id4}      ${54}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1

${TEST_NAME}     TC1
${CELL_ID}    3

${drx_delta_file_name}=             Enable_DRX_via_parameter.json
${delta_file_name}=             Enable_CB013233_RRC_Inactive.json
${drb_inactivity_timer}=    60
${srb_inactivity_timer}=    60
${delta}=   30

*** Test Cases ***
CB013233-A#IWK101_1_Successful_early_DRX_setup_for_UE_in_SA_mode_during_RRC_Inactive_to_RRC_Connected_transition_FDD
    [Tags]     QC_xxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with ${delta_file_name}
    X2AP Link Should be UP
    Wait until the next Measurement Period starts
#Step 1: Attach UE and check for Early DRX steup in UE contextsetup and start Data traffic
    log to console   "SA UE attach "
    Start Log    cprt
    Set AMF core network assistance info   ue_id=${sa_ue_id1}
    ${sa_ue_id1_rnti}=  UE Register should be Successful And Fetch RNTI    ${sa_ue_id1}
    sleep     2s
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    Verify DRXcycle in F1AP_UEContextSetupRequest   ${path1}[cprt]/NODECPRT_GNB.pcap   ${sa_ue_id1_rnti}
    ${ue_id1_gnb_cu_id}=    Get gnb CU UEID from CRNTI   ${path1}[cprt]/NODECPRT_GNB.pcap   ${sa_ue_id1_rnti}
    Trigger DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=150   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Trigger UL Traffic SA   ue_id=${sa_ue_id1}    ul_rate=150   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    sleep   10s
    Validate DL Traffic For SA   ue_id=${sa_ue_id1}    dl_rate=150   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${sa_ue_id1}    ul_rate=150   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    sleep   10s
#Step2: Stop data traffic and check for UE moves to Inactive state
    Start Log    cprt
    ${inactive_time_start}=    Stop data and get timestamp for UE    ue_id=${sa_ue_id1}
    Sleep till inactivity timer expiry
    ${inactive_time_stop}=     Check UE RRC State Inactive and get Timestamp   ue_id=${sa_ue_id1}
    Verify UE stats   ue_id=${sa_ue_id1}   state=UE_INACTIVE
    ${path2}    Stop Log    cprt   test_scenario=rrcinactive
#Step3: Start DL data for paging and RRC Resume. Check DRX is configured as part of RRCresume in UE contextsetup request
    Start Log    cprt
    Trigger RRC Resume for RANPaging with DL Data   ue_id=${sa_ue_id1}
    ${path3}    Stop Log    cprt   test_scenario=rrcresume
    Verify DRXcycle in F1AP_UEContextSetupRequest with gnb_cu_ueid   ${path3}[cprt]/NODECPRT_GNB.pcap   ${ue_id1_gnb_cu_id}
    Run Keyword and Continue on Failure     Link SCOUT SCF to Configuration ID for Reporting
    Validate DL Traffic For SA   ue_id=${sa_ue_id1}    dl_rate=150   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
#Step4: Verify counters for RRC Inactive and DRX
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File Classical   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55124C00010  1  NRRCC_RRC_RESUME_SUCC
    ...  M55124C00007  1  NRRCC_RRC_RESUME_REQUEST1
    ...  M55308C11001  >1000   SLOTS_UE_DRX_ACTIVE
    ...  M55308C11002  >1000   SLOTS_UE_DRX_SLEEP
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
    UE Deregister should be Successful    ${sa_ue_id1}

*** Keywords ***
Verify DRXcycle in F1AP_UEContextSetupRequest with gnb_cu_ueid
    [Arguments]   ${drx_cprt_pcap}   ${gnb_cu_ueid}
    [Documentation]      This KW Verifies the DRXCycle IE In F1AP_UEContextSetupRequest message
    log to console       Checking DRXCycle IE In F1AP_UEContextSetupRequest for RNTI ${gnb_cu_ueid}
    ${pdmlFile} =    Get filtered PDML file from pcap     ${drx_cprt_pcap}
    ...   (itf_cp_cpue_cprt_SCpUeCpRtSyscomCommunicationEnvelope.cuUeId_item == ${gnb_cu_ueid}) && (f1ap.procedureCode == 5)
    analyzer.check_field            pdmlFile=${pdmlFile}
    ...                             packetName=itf_cp_cpue_cprt_cprt_receivefromcpue
    ...                             fieldName=f1ap.longDRXCycleLength
    ...                             kind=showname
    ...                             value=longDRXCycleLength: ms10 (0)


Set AMF core network assistance info
    [Arguments]   ${ue_id}
    wtsrunner.amf_ue_ics_param       id=1         ue=${ue_id}
    ...     trace_activation=on    trace_plmn=311:489     trace_ref_id=1     trace_rec_session_ref_id=1
    ...     trace_depth=minimum     ifaces_to_trace=NG-C     tce_ip=10.0.1.1
    ...     core_network_assistance_info=on     ue_identity_index_value=1     ue_specific_drx=64
    ...     periodic_registration_update_timer=1:1min       plmn_id=311:489     tac_id=200

Trigger RRC Resume for RANPaging with DL Data
    [Arguments]   ${ue_id}
    Log to console   "Trigger DL data for RRC Resume"
    sleep   10s
    wtsrunner.trf_data_start    ue=${ue_id}   pdu=${Pdu_session_ID}   qfi=${QFI_ID}    trf_id=1  dir=dl   mbps=150
    ${output}   wtsrunner.read_wtsemu_output_until_re     expected=Started Downlink Internal traffic Receiver   timeout=10
    ${output1}         Get Lines Matching Regexp    ${output}    drx-onDurationTimer    partial_match=${TRUE}
    should contain   ${output1}   ms10
    ${output1}         Get Lines Matching Regexp    ${output}    drx-InactivityTimer    partial_match=${TRUE}
    should contain   ${output1}   ms80
    ${output1}         Get Lines Matching Regexp    ${output}    drx-RetransmissionTimerDL    partial_match=${TRUE}
    should contain   ${output1}   sl0
    ${output1}         Get Lines Matching Regexp    ${output}    drx-RetransmissionTimerUL    partial_match=${TRUE}
    should contain   ${output1}   sl0
    ${output1}         Get Lines Matching Regexp    ${output}    drx-LongCycleStartOffset     partial_match=${TRUE}
    should contain   ${output1}   ms160
    ${output1}         Get Lines Matching Regexp    ${output}    drx-SlotOffset    partial_match=${TRUE}
    should contain   ${output1}   0
    should contain   ${output}   rrcResumeComplete
    should not contain   ${output}   rrcReconfiguration


Sleep till inactivity timer expiry
    Log to Console          Wait ${drb_inactivity_timer}s for UE to move inactive state
    sleep   ${drb_inactivity_timer}s
    sleep   ${delta}s       #add extra delta


Stop data and get timestamp for UE
    [Arguments]   ${ue_id}
    wtsrunner.trf_data_stop     ue=${ue_id}  pdu=${Pdu_session_ID}   qfi=${QFI_ID}   trf_id=1  dir=bi
    ${output}   wtsrunner.read_wtsemu_output_until_re     expected=Stopped*    timeout=10
    ${time}         Get Lines Matching Regexp    ${output}     UPF-1: Stop       partial_match=${TRUE}
    ${time}    Split String      ${time}      ${SPACE}
    [Return]      ${time}


Verify UE stats
    [Arguments]   ${ue_id}   ${state}
    Log to console   "chekcing UE stats"
    wtsrunner.ue_disp    id=${ue_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re     expected=Security    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    state   partial_match=${TRUE}
    Should Contain    ${output}   ${state}
    Log to Console    UE: ${ue_id} moved to ${state} state

Check UE RRC State Inactive and get Timestamp
    [Arguments]    ${ue_id}
    Log to console    "waiting for rrcRelease with suspendConfig for UE to move to inactive state"
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Is INACTIVE    timeout=100
    Log to console   ${output}
    ${output1}         Get Lines Matching Regexp    ${output}    UE${ue_id}: Is INACTIVE    partial_match=${TRUE}
    Log to console   ${output1}
    ${time}    Split String      ${output1}      ${SPACE}
    Log to console   ${time}
    [Return]    ${time}
