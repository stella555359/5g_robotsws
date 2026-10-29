*** Settings ***
Documentation
...            author:       Marcin Duplaga, marcin.duplaga@nokia.com,
...                          Mateusz Zachwieja mateusz.zachwieja@nokia.com,
...                          Kamil Deregowski kamil.deregowski@nokia.com
...            maintainer:   Marcin Duplaga, marcin.duplaga@nokia.com

Resource     ./../../../resources/KRK/krk3_common/main_cls.robot
Resource    variables.robot

*** Variables ***
&{DEL_NRMTRACECU_CONFIG}            delta=${CURDIR}/delta_configs/common/delta_del_NRMTRACECU.json

*** Keywords ***
Test Case Setup 8176
    Run keywords
    ...               Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=yes
    ...    AND        Change UE Location  ue_id=2  node_id=2  cell_id=1
    ...    AND        Change UE Location  ue_id=3  node_id=2  cell_id=1
    ...    AND        Change UE Location  ue_id=4  node_id=2  cell_id=1
    ...    AND        Change UE Location  ue_id=5  node_id=2  cell_id=1
    ...    AND        Handle Delta Commisioning

Add UEs with location support to cfg file
    [Arguments]    ${wts_delta}    ${wts_out}    ${wts_in}=/opt/wts/latest/basic_setup.cfg
    File Should Exist    ${wts_in}
    File Should Exist    ${wts_delta}
    ${delta_content}    Get File    ${wts_delta}
    @{lines}    Split To Lines    ${delta_content}
    wtscfg.load_wts_cfg    ${wts_in}
    ${previous_line}    Set Variable    ue_param id=180
    FOR    ${line}    IN    @{lines}
      wtscfg.insert    ${line}    after    ${previous_line}
      ${previous_line}    Set Variable    ${line}
    END
    Create File    ${wts_out}    ${Empty}
    wtscfg.save_wts_cfg    ${wts_out}

Remove Existing Xn Link If Exists
    ${local_skip}    Get Variable Value    ${skip}
    ${skip_config}    Set Variable If    'config' in '${local_skip}'    ${True}    ${False}
    Run Keyword If    ${skip_config}    Return From Keyword
    Log to Console    Removing existing Xn Link if exists
    ${connection}    coam_admin.setup_admin
    ${status}    ${msg}    Run Keyword And Ignore Error    coam_admin.perform_object_recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1/XNLINK-1    parameter=@{Empty}    operation=delete    connection=${connection}
    coam_admin.teardown_admin    connection=${connection}
    ${not_exist}    Run Keyword And Return Status    Should Contain    ${msg}    object not exist
    Run Keyword Unless    ${not_exist} or '${status}' == 'PASS'    Fail    ${msg}

Recreate Objects via Delta Commissioning
    [Arguments]    ${delta_file}
    Upload Configs    config=${DEL_NRMTRACECU_CONFIG}
    Upload Configs    config=${delta_file}

Handle Delta Commisioning
    ${test_id}    Get Regexp Matches  ${TEST_NAME}  [A-D]_[0-9]{1}[0]{0,}
    Log To Console  Handling Delta Commisioning for test: ${test_id}
    Log To Console  File used: ${DELTA_CONFIG_${test_id}[0]}
    Recreate Objects via Delta Commissioning  delta_file=${DELTA_CONFIG_${test_id}[0]}

Get MDT PCMD Records and Cell Traces from PCAP
    [Arguments]    ${pcap_filepath}=${dcap_files}[ipCapture][0]    ${filter}=nsetapx    ${log_suffix}=${EMPTY}
    ...    ${should_MDT_PCMD_be_present}=${True}    ${should_MDT_cellTrace_be_present}=${True}
    ${PCMD_records}    Run Keyword If    ${should_MDT_PCMD_be_present} == ${True}
    ...            Get PCMD Records from PCAP
    ...            pcap_filepath=${pcap_filepath}
    ...            filter=${filter}
    ...            pattern=nsetapx.ueMeasRecord_tree
    ...            save_to_file=${TEST_log_dir}/MDT/PCMD_records_${log_suffix}.json
    ...    ELSE    Run Keyword And Expect Error     REGEXP: No PCMD records present
    ...            Get PCMD Records from PCAP
    ...            pcap_filepath=${pcap_filepath}
    ...            filter=${filter}
    ...            pattern=nsetapx.ueMeasRecord_tree
    ...            save_to_file=${TEST_log_dir}/MDT/PCMD_records_${log_suffix}.json
    ${cell_traces}     Run Keyword If    ${should_MDT_cellTrace_be_present} == ${True}
    ...            Get Cell Traces from PCAP
    ...            pcap_filepath=${pcap_filepath}
    ...            filter=${filter}
    ...            pattern=nr-rrc.measurementReport_element
    ...            save_to_file=${TEST_log_dir}/MDT/Cell_traces_${log_suffix}.json
    ...    ELSE    Run Keyword And Expect Error     REGEXP: No Cell Traces present
    ...            Get Cell Traces from PCAP
    ...            pcap_filepath=${pcap_filepath}
    ...            filter=${filter}
    ...            pattern=nr-rrc.measurementReport_element
    ...            save_to_file=${TEST_log_dir}/MDT/Cell_traces_${log_suffix}.json
    &{MDT_traces}    Create Dictionary
    Set To Dictionary    ${MDT_traces}    PCMD=${PCMD_records}
    Set To Dictionary    ${MDT_traces}    cellTrace=${cell_traces}
    [Return]    ${MDT_traces}

Verify Sequence of cellActiveMDTUETraced
    [Arguments]    ${syslog_filepath}=${dcap_files}[syslog]    ${expected_seq}=None
    ${pattern}   Set Variable    (de)?allocated .* current list size .*
    ${output}    Should Match Regexp in Files    ${pattern}    @{syslog_filepath}
    ${received_seq}    Get Regexp Matches    ${output}    ${pattern}
    Run Keyword And Ignore Error    Lists Should Be Equal    ${expected_seq}    ${received_seq}
    List Should Contain Sub List    ${received_seq}    ${expected_seq}

Verify There Is No Sequence of cellActiveMDTUETraced
    [Arguments]    ${syslog_filepath}=${dcap_files}[syslog]
    ${pattern}   Set Variable    (de)?allocated .* current list size .*
    Run Keyword And Expect Error    REGEXP: Could not find regexp
    ...    Should Match Regexp in Files    ${pattern}    @{syslog_filepath}

Send NR Measurement
    [Arguments]    ${ue_id}=1    ${event}=A3
    ${meas_id}    Get Next Meas ID From Egate    ue_id=${ue_id}    event=${event}
    ${cmd}    Catenate  ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event}
    ...    srsrp_nr=50 srsrq_nr=50 phycell_id=50 nrsrp_nr=51 nrsrq_nr=51
    Execute Egate Command    cmd=${cmd}

Send NR Measurement With LocationInfo
    [Arguments]    ${ue_id}=1    ${event}=A3
    ${meas_id}    Get Next Meas ID From Egate    ue_id=${ue_id}    event=${event}
    ${cmd}    Catenate  ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event}
    ...    srsrp_nr=50 srsrq_nr=50 phycell_id=50 nrsrp_nr=51 nrsrq_nr=51 gnss_TOD_msec_r16=123456789A123456789A
    Execute Egate Command    cmd=${cmd}

Start Subscriber Trace
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1    ${tce_ip}=10.0.1.1
    ${cmd}    Catenate  ue_ng_trace_start id=${ue_id} tce_ip=${tce_ip} trace_depth=minimum
    ...    ifaces_to_trace=Uu,NG-C,Xn-C trace_plmn=311:489 trace_rec_session_ref_id=${trace_session_id} trace_ref_id=${trace_session_id}
    Execute Egate Command    cmd=${cmd}
    Log To Console  Subsriber Trace Started

Stop Subscriber Trace
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1
    ${cmd}    Set Variable
    ...   ue_ng_trace_stop id=${ue_id} trace_plmn=311:489 trace_rec_session_ref_id=${trace_session_id} trace_ref_id=${trace_session_id}
    Execute Egate Command    cmd=${cmd}

Get CRNTI of UE
    [Arguments]  ${ue_id}
    ${egate_output}    Execute Egate Command And Wait For Data
    ...    cmd=ue_disp id=${ue_id}
    ...    pass_regexp=C-RNTI
    ${CRNTI_line}    Get Regexp Matches    ${egate_output}    C-RNTI .* [0-9]+
    ${Actual_CRNTI}    Get Regexp Matches  ${CRNTI_line}[0]   [0-9]+
    [Return]    ${Actual_CRNTI}[0]

Get CRNTI of Last Attached NSA UE
    ${cmd}    Set Variable
    ...    grep -wo "newUE-Identity .*" ${TEST_log_dir}/Egate/egate_console.log | grep -Eo '[[:digit:]]+'
    ${crnti_list}    Run And Return Rc And Output    ${cmd}
    ${crnti_list}    Split String    ${crnti_list}[-1]    \n
    [Return]     ${crnti_list[-1]}

Prepare Sequence List Of 4 Dictionaries From ${dict}
    ${dict1}    Create Dictionary    &{dict}
    ${dict2}    Create Dictionary    &{dict}
    ${dict3}    Create Dictionary    &{dict}
    ${dict4}    Create Dictionary    &{dict}
    ${Dict_Seq}    Create List    ${dict1}    ${dict2}    ${dict3}    ${dict4}
    [Return]    ${Dict_Seq}
