*** Settings ***
Documentation
...  author: Chen Liang
...  contact: liang.6.chen@nokia-sbell.com

Resource   ./Resource/Common.robot
Resource   ../5GC001681_794/resources/emil/emil.robot

Force Tags   SG_07   CA_5G_OAM   CRT   master_classicalbts_all
...   5G_RAN_TDD   STATE_SW_UPLOADED
...    PY36

Test Timeout   1h

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown

Test Setup   Case Common Setup
Test Teardown   Case Common Teardown

*** Variables ***
${SA_INTER_gNB_HO_TARGET_FILE}   SA_INTER_gNB_HO_TARGET.pcap
${SA_INTER_gNB_HO_SOURCE_FILE}   SA_INTER_gNB_HO_SOURCE.pcap

${dcapuser_addr}   ${tl.gnbs[0].dcap.connection_details.addr}
${dcapuser_username}   ${tl.gnbs[0].dcap.connection_details.username}
${dcapuser_password}   ${tl.gnbs[0].dcap.connection_details.password}

&{bts_source}      alias=gnb_dcap    host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    username=Nemuadmin    password=nemuuser
    ...     port=443    bts_id=${tl.gnbs[0].global_bts_id}
&{bts_target}      alias=gnb_dcap    host=10.71.211.163    username=Nemuadmin    password=nemuuser
    ...     port=443    bts_id=10844

${SA_ue_index}    0
*** Test Cases ***
[1]CNI-99458_009_FR1_Classical_SA_PMI_event_via_Normal_setup_and_Inter_HO
    [Documentation]   case contain all 99458 cases
    run keyword and continue on failure    Check PMI ticket XnHOSource    ${output_txt_source_path}
    run keyword and continue on failure    Check PMI ticket XnHOTarget    ${output_txt_target_path}

*** Keywords ***
Common Suite Setup
    robot_common_operations.Common Suite Setup
    Run Keyword And Ignore Error   Check Extra Reset From Blackbox
    Common Setup 1756
    Get HO Suite Variables
#    Start BTS LOG Collection On Gnb And Rus
#    Remove And Add PCMD Object
    Run Keyword And Ignore Error   COAM Logout

    Run Keyword And Ignore Error   Initialize PA
    UE precondition   ue_index=${SA_ue_index}
    Attach and Retry if Failed    ue_index=${SA_ue_index}
    
    ${output_source}    Start DCAP log PMI   ${bts_source}
    ${output_target}    Start DCAP log PMI   ${bts_target}
    sleep   40s

#    Trigger SA INTER HO
    Run Keyword And Ignore Error   Trigger INTER gNB HO for PMI
    ...   ${SA_ue_index}    ${SA_INTER_gNB_HO_TARGET_FILE}   ${SA_INTER_gNB_HO_SOURCE_FILE}   SA
    
    ${downloaded_emil_file_path_source}   Stop DCAP log and convert to txt type    ${output_source}
    ${downloaded_emil_file_path_target}   Stop DCAP log and convert to txt type    ${output_target}

    ${output_txt_source_path}   Convert EMIL For PMI   ${downloaded_emil_file_path_source}
    Set Suite Variable   ${output_txt_source_path}
    sleep   60s
    ${output_txt_target_path}   Convert EMIL For PMI   ${downloaded_emil_file_path_target}
    Set Suite Variable   ${output_txt_target_path}

    Run Keyword And Ignore Error   Initialize PA

Common Suite Teardown
    Run Keyword And Ignore Error   Initialize PA
#    Create Directory   ${OUTPUT_DIR}/dir
#    Run Keyword If Any Tests Failed   Stop And Download And Remove BTS LOG Collection On Gnb And Rus   dir
#    Run Keyword If All Tests Passed   run keyword if   ${errandpcmd_status}   run keywords
#    ...   Stop And Download And Remove BTS LOG Collection On Gnb And Rus   dir
#    ...   AND   Fail
#    ...   ELSE   Stop And Remove BTS LOG Collection On Gnb And Rus
    Run Keyword And Ignore Error   Run Keyword If Any Tests Failed   Run keywords   Save gNB Snapshot   host=${LOCAL_SSH_ADDR}   alias=master
    ...   AND   Save gNB Snapshot   host=${PEER_SSH_ADDR}   alias=PEER
    Run Keyword And Ignore Error   Run Keyword If All Tests Passed   run keywords
    ...   RUN   rm -rf ${NSA_INTRA_gNB_HO_PATH}
    ...   AND   RUN   rm -rf ${SA_INTER_gNB_HO_TARGET_PATH}
    ...   AND   RUN   rm -rf ${TCPDUMP_PATH}
    Common Teardown 1756
    robot_common_operations.Common Suite Teardown

Convert EMIL For PMI
    [Arguments]   ${downloaded_emil_file_path}
    ${emil_log_file_list}    ${sherpa_log_file_list}    Exact Dcap log    downloaded_emil_file_path=${downloaded_emil_file_path}
    ${status}    ${nodeinfo}    run keyword and ignore error    Get GNB Node ID
    set suite variable   ${nodeinfo}
    Upload Emil script and logs on sherpa
    Mkdir for EMil script and logs on sherpa
    Convert emil log at sherpa PMI   log_path_list=${emil_log_file_list}    end_file=5gm
    [Return]    ${output_txt_path}

Start DCAP log PMI
    [Arguments]   ${bts}
    log to console    \n Start DCAP log
    DCAP.connect_to     host=${dcapuser_addr}    port=443     username=${dcapuser_username}
    ...     password=${dcapuser_password}     rd_version=dcapv3    secure=True
    ${gnb_custom_profile}=     Create List     cp_5g
    ${output}    DCAP.start_trace     bts=${bts}     gnb_custom_profile=${gnb_custom_profile}
    ...     wait_for_activation=${True}    control_plane_interface=${True}
    Log    ${output}[tracer_id]
    [Return]   ${output}

Stop DCAP log and convert to txt type
    [Arguments]   ${output}
    log to console    \n Stop DCAP log and convert to txt type
    ${profile_file}    set variable    SourceProfile_PMI_Ticket.ini
    ${stopstatus}    run keyword and return status    DCAP.stop_trace    trace_id=${output}[tracer_id]
    set suite variable    ${stopstatus}
    sleep    2m
    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${output}[tracer_id]
    ...    target_dir=${OUTPUT_DIR}
    [Return]   ${downloaded_emil_file_path}

Check PMI ticket XnHOSource
    [Arguments]   ${output}
    log to console    begin to check in emil HO source log
    ${pcmd_event}=    Grep File    ${output}   XnApSourceHo
    Run Keyword And Ignore Error   Should Contain    ${pcmd_event}      XnApSourceHo
    ${pcmd_event}=    Grep File    ${output}   PrimaryResult
    Run Keyword And Ignore Error   Should Contain    ${pcmd_event}      0x00
    ${pcmd_event}=    Grep File    ${output}   TargetCellId
    Run Keyword And Ignore Error   Should Contain    ${pcmd_event}      177668097
    ${pcmd_event}=    Grep File    ${output}   Trigger
    Run Keyword And Ignore Error   Should Contain    ${pcmd_event}      0x01

Check PMI ticket XnHOTarget
    [Arguments]   ${output}
    log to console    begin to check in emil HO target log
    ${pcmd_event}=    Grep File    ${output}   XnApTargetHo
    Run Keyword And Ignore Error   Should Contain    ${pcmd_event}      XnApTargetHo
    ${pcmd_event}=    Grep File    ${output}   PrimaryResult
    Run Keyword And Ignore Error   Should Contain    ${pcmd_event}      0x00
    ${pcmd_event}=    Grep File    ${output}   SourceCellId
    Run Keyword And Ignore Error   Should Contain    ${pcmd_event}      177651713

Case Common Setup
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000

Case Common Teardown
    robot_common_operations.Common Case Teardown
