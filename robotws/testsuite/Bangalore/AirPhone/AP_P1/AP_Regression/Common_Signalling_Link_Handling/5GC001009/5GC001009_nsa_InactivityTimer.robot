*** Settings ***
Documentation     author: Chandana
...               contact: chandana.m_s@nokia.com
Suite Setup       ReachOnAir
Suite Teardown    Suite teardown
Test Setup        Test Setup
Test Teardown     Test Teardown
Library           Collections
Library           ute_wtssim
Library           taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library           ../../../Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Library           ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store
Library           ../../../Resources/Python/pdml_analyser.py
Resource          ../../../Resources/Variables/Common_Variables.robot
Resource          ../../../Resources/robot/gnb.robot
Resource          ../../../Resources/robot/ute_setup.robot
Resource          ../../../Resources/robot/wts.robot
Resource          ../../../Resources/robot/log.robot
Resource          ../../../Resources/robot/suite_common_keywords.robot

*** Variables ***
${WTS_CFG_PATH}    ${CURDIR}/cfg
${BTS_ID}         1
${nsa_inactivity_timer}    30
${timer_less_than_inactivity_1}    5
${timer_less_than_inactivity_2}    15
${UE_ID2}    2
${tolerance}    5
&{nsa_inactivity_params}    nsaInactivityTimer=${nsa_inactivity_timer}    actInactDetNSAUe=true

*** Test Cases ***
Verify UE context released with Inactivity Detection due to DL data stopped
    [Tags]    CIT
    Attach Default UE and perform DL Data
    Wait for NSA inactivity timer to expire
    Store PCAP File And Convert to PDML
    Verify Message sequence for SGNB release    pdml_file=${pdml_file}

Verify UE context released with Inactivity Detection due to UL data stopped
    [Tags]    CIT
    Attach Default UE and perform UL Data
    Wait for NSA inactivity timer to expire
    Store PCAP File And Convert to PDML
    Verify Message sequence for SGNB release    pdml_file=${pdml_file}

Verify no sgnb release happend when data stops and resumes before nsaInactiviryTimer expiry
    [Tags]    CRT
    Attach Default UE and Start UL and DL data
    Wait for less than Inactivity timer    ${timer_less_than_inactivity_1}
    Stop All Data Transfer    ${UE_ID}    ${BEARER_ID}
    Wait for less than Inactivity timer    ${timer_less_than_inactivity_2}
    Verify UE is not released by performing UL and DL data
    Store PCAP File And Convert to PDML
    Verify Message sequence for no SGNB release    pdml_file=${pdml_file}

Verify sgnb release happens after nsaInactiviryTimer expiry
    [Tags]    CIT
    UE Attach    ue_id=${UE_ID}    profile_id=${PROFILE_ID}
    SGNB Addition For Bearer    ue_id=${UE_ID}    target_gnb=${GNB_ID}    target_cells=${CELL_ID}    bearer=${BEARER_ID}
    Wait for NSA inactivity timer to expire
    Store PCAP File And Convert to PDML
    Verify Inactivity Timing From Pcap    ${gnb_pcap_file}    UE_ID=${UE_ID}
    Verify Message sequence for SGNB release    pdml_file=${pdml_file}

Verify InactivityDetection due to ULdata stopped for Multiple UEs
    [Tags]    CRT
    Attach Two UEs
    Wait for NSA inactivity timer to expire
    Store PCAP File And Convert to PDML
    Verify Inactivity Timing From Pcap    ${gnb_pcap_file}    UE_ID=${UE_ID}
    Verify Inactivity Timing From Pcap    ${gnb_pcap_file}    UE_ID=${UE_ID2}
    Detach the UE    UE_ID=${UE_ID2}

*** Keywords ***
ReachOnAir
    Suite Common Keywords   feature_folder=5GC001009
    Get original params from gnB
    Wait for gNB To Be Ready
    Prepare Environment Based On Run Type     cfg_type=custom
    Enable nsaInactivityTimer parameter

Enable nsaInactivityTimer parameter
    Set NSA Inactivity Timer and Flag    ${nsa_inactivity_timer}    true

Test Teardown
    UE Detach    ${UE_ID}
    Common Test Teardown

Test Setup
    Create Test Case Folder
    Start and configure WTS
    Ensure Egate state
    Wait for gNB To Be Ready
    Establish X2 link And Wait For Cell Setup
    Start pcap collection in gNB and WTS

Disable nsaInactivityTimer parameter
    ${nsa_inactivity_timer_from_scf}    Get From Dictionary    ${nsa_params}    nsaInactivityTimer
    ${inactivity_detection_flag_from_scf}    Get From Dictionary    ${nsa_params}    actInactDetNSAUe
    Set NSA Inactivity Timer and Flag    ${nsa_inactivity_timer_from_scf}     ${inactivity_detection_flag_from_scf}

Get original params from gnB
    ${scf_path}    Download SCF file
    ${nsa_params}    scf_helper.get_feature_paramters_from_scf    ${scf_path}     ${nsa_inactivity_params}     ${NRBTS_DISTNAME}
    Set Suite Variable    ${nsa_params}
    Set Suite Variable    ${scf_path}

Suite teardown
    Common Suite Teardown Keywords
    Disable nsaInactivityTimer parameter

Verify Message sequence for SGNB release
    [Arguments]   ${pdml_file}
    ${message_sequence}=    Catenate    SgNBAdditionRequest    SgNBAdditionRequestAcknowledge    SgNBReconfigurationComplete
    ...    SNStatusTransfer    SgNBReleaseRequired    SgNBReleaseConfirm    SNStatusTransfer
    ...    UEContextRelease
    Verify Message Sequence In PDML File    pdml_file=${pdml_file}    messages=${message_sequence}

Verify Message sequence for no SGNB release
    [Arguments]   ${pdml_file}
    ${message_sequence}=    Catenate    SgNBAdditionRequest    SgNBAdditionRequestAcknowledge    SgNBReconfigurationComplete
    ...    SNStatusTransfer
    Verify Message Sequence In PDML File    pdml_file=${pdml_file}    messages=${message_sequence}
    SgNB Release Should not be present in the capture   ${pdml_file}

SgNB Release Should not be present in the capture
    [Arguments]   ${pdml_file}
    @{release_message_list}    taf_pdml_analyser.get_pdml_entries    ${pdml_file}    field_name=x2ap.SgNBReleaseConfirm_element
    ...     attrib_name=showname    attrib_value=SgNBReleaseConfirm
    ${length}    Get Length    ${release_message_list}
    Should be Equal as Integers    ${length}    0

Attach Default UE and perform DL Data
    UE Attach    ue_id=${UE_ID}    profile_id=${PROFILE_ID}
    SGNB Addition For Bearer    ue_id=${UE_ID}    target_gnb=${GNB_ID}    target_cells=${CELL_ID}    bearer=${BEARER_ID}
    Start Downlink Data Transfer and verify throughput    bearer=${BEARER_ID}    ue_id=${UE_ID}
    Stop DL data transfer    ${UE_ID}    ${BEARER_ID}

Attach Default UE and perform UL Data
    UE Attach    ue_id=${UE_ID}    profile_id=${PROFILE_ID}
    SGNB Addition For Bearer    ue_id=${UE_ID}    target_gnb=${GNB_ID}    target_cells=${CELL_ID}    bearer=${BEARER_ID}
    Start Uplink Data Transfer and verify throughput    bearer=${BEARER_ID}    ue_id=${UE_ID}
    Stop UL data transfer    ${UE_ID}    ${BEARER_ID}

Wait for NSA inactivity timer to expire
    [Arguments]    ${configured_nsa_inactivity_timer}=${nsa_inactivity_timer}    ${offset}=10
    ${wait_time}    Evaluate    ${configured_nsa_inactivity_timer} + ${offset}
    Sleep    ${wait_time}s

Attach Default UE and Start UL and DL data
    UE Attach    ue_id=${UE_ID}    profile_id=${PROFILE_ID}
    SGNB Addition For Bearer    ue_id=${UE_ID}    target_gnb=${GNB_ID}    target_cells=${CELL_ID}    bearer=${BEARER_ID}
    Start Data Transfer And Verify Throughput    bearer=${BEARER_ID}    ue_id=${UE_ID}

Wait for less than Inactivity timer
    [Arguments]    ${wait_time}
    Sleep    ${wait_time}s

Verify UE is not released by performing UL and DL data
    Start Data Transfer And Verify Throughput    bearer=${BEARER_ID}    ue_id=${UE_ID}

Set NSA Inactivity Timer and Flag
    [Arguments]    ${nsa_inactivity_timer}    ${inactivity_detection_flag}
    Log    ${inactivity_detection_flag}
    Delete Delta If Alread Present    name=nsaIT
    admin.Create Delta    delta_id=nsaIT
    admin.Append Parameter Update To Delta    delta_id=nsaIT    dist_name=${NRBTS_DISTNAME}
    ...    parameter=nsaInactivityTimer    value=${nsa_inactivity_timer}
    admin.Append Parameter Update To Delta    delta_id=nsaIT    dist_name=${NRBTS_DISTNAME}
    ...    parameter=actInactDetNSAUe    value=true
    ${nsaIT_delta}=    admin.Get Delta    delta_id=nsaIT
    Recommission GNB With Delta    ${nsaIT_delta}

Attach Two UEs
    UE Attach    ue_id=${UE_ID}    profile_id=${PROFILE_ID}
    UE Attach    ue_id=${UE_ID2}    profile_id=${PROFILE_ID}
    SGNB Addition For Bearer    ue_id=${UE_ID}    target_gnb=${GNB_ID}    target_cells=${CELL_ID}    bearer=${BEARER_ID}
    SGNB Addition For Bearer    ue_id=${UE_ID2}    target_gnb=${GNB_ID}    target_cells=${CELL_ID}    bearer=${BEARER_ID}

Verify Inactivity Timing From Pcap
    [Arguments]    ${gnb_pcap_file}    ${UE_ID}
    ${rrc_configtime}=    Run
    ...    tshark -Y "(x2ap.procedureCode==28)&&(x2ap.UE_X2AP_ID==${UE_ID})" -T fields -e frame.time_epoch -r ${gnb_pcap_file}
    ${sgnb_release_time}=    Run
    ...    tshark -Y "((x2ap.X2AP_PDU==0)&&(x2ap.procedureCode==32))&&(x2ap.UE_X2AP_ID==${UE_ID})" -T fields -e frame.time_epoch -r ${gnb_pcap_file}
    ${actual_delay}    Evaluate   ${sgnb_release_time}-${rrc_configtime}
    ${expected_delay_with_tolerance}    Evaluate    ${nsa_inactivity_timer}+${tolerance}
    ${is_inactivity_timer_in_range}     Evaluate    ${nsa_inactivity_timer} <= ${actual_delay} <= ${expected_delay_with_tolerance}
    Should Be Equal As Strings    ${is_inactivity_timer_in_range}    True    msg =Actual Inactivity Timer : ${actual_delay}
    ...    is not equal or closer enough to configured value: ${nsa_inactivity_timer}
    [Return]    ${gnb_pcap_file}

Detach the UE
    [Arguments]    ${UE_ID}
    UE Detach    ${UE_ID}

Store PCAP File And Convert to PDML
    ${pdml_file}    Stop PCAP And Convert X2AP to PDML
    ${gnb_pcap_file}    log_store.get_gnb_pcap
    set test variable    ${pdml_file}
    set test variable    ${gnb_pcap_file}
