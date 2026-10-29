*** Settings ***
Documentation     author: Chandana
...               contact: chandana.m_s@nokia.com
Library    OperatingSystem
Library    DateTime
Library    String
Library    Collections
Library    ute_wtssim
Library    taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library    ../../../Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Library    ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store


Resource   ../../../Resources/robot/gnb.robot
Resource   ../../../Resources/robot/ute_setup.robot
Resource   ../../../Resources/robot/wts.robot
Resource   ../../../Resources/robot/log.robot
Resource   ../../../Resources/robot/tshark.robot
Resource   ../../../Resources/Variables/Common_Variables.robot
Resource   ../../../Resources/robot/suite_common_keywords.robot

Suite Setup      ReachOnAir
Suite Teardown   Suite Teardown
Test Setup       Test Setup
Test Teardown    TestTeardown

*** Variables ***
${WTS_CFG_PATH}                            ${CURDIR}/cfg
${MULTI_BEARER_ID}                         2,8
${NON_DEFAULT_BEARER_ID}                   8
${DefaultPeriodicalDataUsageReportTime}    60s
${expected_number_of_packets}              2
${expected_RAB_ID_or_dRB_ID}               5,6\n5,6
${expected_UE_X2AP_ID}                     1\n1
${x2ap_secondary_data_report_filter}         x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 38
${e1ap_data_usage_report_filter}             e1ap.procedureCode==15
${RLF_reason}                              rlc_max_num_retx
${pcap_filter}                             x2ap || e1ap || f1ap
${message_sequence}                        SEPARATOR=${EMPTY}
...                                        SgNBReleaseRequired.*
...                                        SgNBReleaseConfirm.*
...                                        BearerContextModificationRequest.*
...                                        BearerContextModificationResponse.*
...                                        SNStatusTransfer.*
...                                        UEContextRelease.*
...                                        UEContextReleaseCommand.*
...                                        UEContextReleaseComplete

&{param_dict}             actSecDataUsageRep=true    periodicalDataUsageReportTimer=60    actMultiDrbNSA=true

*** Test Cases ***
Verify_Secondary_RAT_Data_Usage_Report_Periodical_with_MultiDRB
    [Tags]    CRT
    Attach default UE, add non default bearer and start UL and DL data on both bearers
    Wait for one interval of Perdiodic Data usage report timer
    Disable periodicalDataUsageReportTimer
    Wait for one interval of Perdiodic Data usage report timer
    Verify x2ap and e1ap messages in pcap

Verify Radio Link Failure triggers secondary RAT data usage report
    [Tags]    CRT
    Disable actSecDataUsageRep for RLF trigger
    Wait for gNB To Be Ready
    Attach default UE, start UL and DL data and perform SGNB addition
    Trigger Radio Link Failure with reason rlc_max_num_retx
    Wait for one interval of Perdiodic Data usage report timer
    There should be sgnb release and no Secondary RAT data report in the pcap messages

*** Keywords ***
ReachOnAir
    Suite Common Keywords
    Get original params from gnB
    Enable Secondary RAT Feature
    Wait for gNB To Be Ready

Enable Secondary RAT Feature
    admin.Create Delta   delta_id=sec_rat
    admin.Append Parameter Update To Delta   delta_id=sec_rat   dist_name=${NRBTS_DISTNAME}
    ...                                parameter=actSecDataUsageRep   value=true
    admin.Append Parameter Update To Delta   delta_id=sec_rat   dist_name=${NRBTS_DISTNAME}
    ...                                parameter=periodicalDataUsageReportTimer   value=60
    admin.Append Parameter Update To Delta   delta_id=sec_rat   dist_name=${NRBTS_DISTNAME}
    ...                                parameter=actMultiDrbNSA   value=true
    ${sec_rat_delta}=   admin.Get Delta   delta_id=sec_rat
    Recommission GNB With Delta    ${sec_rat_delta}

Disable periodicalDataUsageReportTimer
    admin.Create Delta   delta_id=data_usage_report_timer
    admin.Append Parameter Update To Delta   delta_id=data_usage_report_timer   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ...                                parameter=periodicalDataUsageReportTimer    value=0
    ${data_usage_report_timer_delta}=   admin.Get Delta   delta_id=data_usage_report_timer
    Recommission GNB With Delta    ${data_usage_report_timer_delta}


Disable actSecDataUsageRep for RLF trigger
    Delete Delta If Alread Present    name=sec_rat
    admin.Create Delta   delta_id=sec_rat
    admin.Append Parameter Update To Delta   delta_id=sec_rat   dist_name=${NRBTS_DISTNAME}
    ...                                parameter=actSecDataUsageRep   value=false
    admin.Append Parameter Update To Delta   delta_id=sec_rat   dist_name=${NRBTS_DISTNAME}
    ...                                parameter=periodicalDataUsageReportTimer   value=60
    ${sec_rat_delta}=   admin.Get Delta   delta_id=sec_rat
    Recommission GNB With Delta    ${sec_rat_delta}

Test Setup
    Create Test Case Folder
    Prepare Environment Based On Run Type     cfg_type=custom
    Start WTS And Extablish X2 Link

Attach default UE, add non default bearer and start UL and DL data on both bearers
    UE Attach   ue_id=${UE_ID}   profile_id=${PROFILE_ID}
    Start pcap collection in gNB
    Add Bearer   ue_id=${UE_ID}   bearer_id=${NON_DEFAULT_BEARER_ID}   filter=7   precedence=18
    SGNB Addition For Bearer   ue_id=${UE_ID}   target_gnb=${GNB_ID}
    ...      target_cells=${CELL_ID}   bearer=${MULTI_BEARER_ID}
    Start Uplink Data Transfer   bearer=${MULTI_BEARER_ID}   ue_id=${UE_ID}
    Start Downlink Data Transfer   bearer=${MULTI_BEARER_ID}   ue_id=${UE_ID}

Wait for one interval of Perdiodic Data usage report timer
    Sleep    ${DefaultPeriodicalDataUsageReportTime}

Get original params from gnB
    ${scf_path}    Download SCF file
    ${sec_rat_report_params}    scf_helper.get_feature_paramters_from_scf    ${scf_path}     ${param_dict}     ${NRBTS_DISTNAME}
    Set Suite Variable    ${sec_rat_report_params}
    Set Suite Variable    ${scf_path}

TestTeardown
    ${gnb_pcap_collected}    log_store.get_is_gnb_pcap_collected
    run keyword if    "${gnb_pcap_collected}" == "False"    Stop pcap collection in gNB
    UE Detach    ${UE_ID}
    WTS Teardown Keywords

Verify x2ap and e1ap messages in pcap
    Stop pcap collection in gNB
    ${pcap_file}    log_store.get_gnb_pcap
    Two reports of secondary data usage report only should be present in pcap    ${pcap_file}
    UE ID and dRBs should match in x2ap messages    ${pcap_file}
    Two reports of e1ap data usage report only should be present in pcap    ${pcap_file}
    dRBs should match in e1ap messages    ${pcap_file}

Two reports of secondary data usage report only should be present in pcap
    [Arguments]    ${pcap_file}
    Count of Messages Matching Filter Should be Equal    ${pcap_file}
    ...    ${x2ap_secondary_data_report_filter}    msg_names=SecondaryRATDataUsageReport
    ...    expected_count_of_messages=${expected_number_of_packets}

UE ID and dRBs should match in x2ap messages
    [Arguments]    ${pcap_file}
    ${RAB_ID_from_pcap}    Get Fields from Pcap    ${pcap_file}    ${x2ap_secondary_data_report_filter}
    ...    x2ap.e_RAB_ID
    Should be equal as strings    ${RAB_ID_from_pcap}    ${expected_RAB_ID_or_dRB_ID}
    ${UE_ID_from_pcap}    Get Fields from Pcap    ${pcap_file}    ${x2ap_secondary_data_report_filter}
    ...    x2ap.UE_X2AP_ID
    Should be equal as strings    ${UE_ID_from_pcap}    ${expected_UE_X2AP_ID}

Two reports of e1ap data usage report only should be present in pcap
    [Arguments]    ${pcap_file}
    Count of Messages Matching Filter Should be Equal    ${pcap_file}
    ...    ${e1ap_dataUsageReport_filter}    msg_names=DataUsageReport
    ...    expected_count_of_messages=${expected_number_of_packets}

dRBs should match in e1ap messages
    [Arguments]    ${pcap_file}
    ${DRB_ID_from_packets}    Get Fields from Pcap    ${pcap_file}    ${e1ap_dataUsageReport_filter}
    ...    e1ap.dRB_ID
    Should be equal as strings   ${DRB_ID_from_packets}    ${expected_RAB_ID_or_dRB_ID}

Suite Teardown
    Common Suite Teardown Keywords
    Revert feature parameters to original value

Revert feature parameters to original value
    Delete Delta If Alread Present    name=sec_rat
    admin.Create Delta   delta_id=sec_rat
    ${sec_data_usgae_rep_default_value}    Get From Dictionary    ${sec_rat_report_params}
    ...     actSecDataUsageRep
    ${multi_drb_default_value}    Get From Dictionary    ${sec_rat_report_params}
    ...     actMultiDrbNSA
    ${periodic_dataUsage_timer_default_value}    Get From Dictionary    ${sec_rat_report_params}
    ...     periodicalDataUsageReportTimer
    admin.Append Parameter Update To Delta   delta_id=sec_rat   dist_name=${NRBTS_DISTNAME}
    ...                                parameter=actSecDataUsageRep   value=${sec_data_usgae_rep_default_value}
    admin.Append Parameter Update To Delta   delta_id=sec_rat   dist_name=${NRBTS_DISTNAME}
    ...                                parameter=periodicalDataUsageReportTimer   value=${periodic_dataUsage_timer_default_value}
    admin.Append Parameter Update To Delta   delta_id=sec_rat   dist_name=${NRBTS_DISTNAME}
    ...                                parameter=actMultiDrbNSA   value=${multi_drb_default_value}
    ${sec_rat_delta}=   admin.Get Delta   delta_id=sec_rat
    Recommission GNB With Delta    ${sec_rat_delta}

Wait for data to run on MCG
    Sleep   30s

Wait for data to run on SCG
    Sleep    30s

Attach default UE, start UL and DL data and perform SGNB addition
    UE Attach   ue_id=${UE_ID}   profile_id=${PROFILE_ID}
    Start pcap collection in gNB
    Start Downlink Data Transfer   bearer=${BEARER_ID}  ue_id=${UE_ID}
    Start Uplink Data Transfer   bearer=${MULTI_BEARER_ID}   ue_id=${UE_ID}
    Wait for data to run on MCG
    SGNB Addition For Bearer   ue_id=${UE_ID}   target_gnb=${GNB_ID}
    ...      target_cells=${CELL_ID}   bearer=${BEARER_ID}
    Wait for data to run on SCG

Trigger Radio Link Failure with reason rlc_max_num_retx
    Trigger Radio Link Failure    ue_id=${UE_ID}    failure_reason=${RLF_reason}
    ...    target=gnb    pass_regexp=ScgFailureInformationNR_r15
    log to console    triggered RLF
    Sleep    5s    #waiting for sometime after RLF trigger

There should be sgnb release and no Secondary RAT data report in the pcap messages
    Stop pcap collection in gNB
    ${pcap_file}    log_store.get_gnb_pcap
    ${pdml_file}    Convert PCAP file to PDML    file_path_pattern=${pcap_file}
    ...    command_template={tshark_path} -Y "x2ap || e1ap || f1ap" -r {input_file} -X lua_script:{luashark_path} -T pdml > {output_file}
    @{field_list}    Create List    x2ap.SgNBReleaseRequired_element    x2ap.SgNBReleaseConfirm_element
    ...    e1ap.BearerContextModificationRequest_element    e1ap.BearerContextModificationResponse_element
    ...    x2ap.SNStatusTransfer_element    x2ap.UEContextRelease_element    f1ap.UEContextReleaseCommand_element
    ...    f1ap.UEContextReleaseComplete_element
    taf_pdml_analyser.check_msc    file_name=${pdml_file}    field_name_list=${field_list}    message_sequence=${message_sequence}
    Secondary RAT data usage reports Should not be present in the capture    ${pdml_file}

Secondary RAT data usage reports Should not be present in the capture
    [Arguments]   ${pdml_file}
    @{release_message_list}    taf_pdml_analyser.get_pdml_entries    ${pdml_file}    field_name=x2ap.SecondaryRATDataUsageReport_element
    ...     attrib_name=showname    attrib_value=SecondaryRATDataUsageReport
    ${length}    Get Length    ${release_message_list}
    Should be Equal as Integers    ${length}    0
