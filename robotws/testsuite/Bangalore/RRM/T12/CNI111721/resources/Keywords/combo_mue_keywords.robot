*** Settings ***
Documentation     This contains common keywords for 4G5G combo Multi UE L3 Calls.
...               :author AP UTE team
Library     taf.collectors.pmcounters    WITH NAME   gnb_pmcounters
Library     taf.analyzer.pmcounter    WITH NAME    pm_analyser
Library     taf.converters.pcaptopdml    WITH NAME    pcaptopdml
Library     taf.analyzer.pdml    WITH NAME    pdml_ana


*** Keywords ***
SA Register for MultiUE
    [Arguments]    ${lua_file}=${multi_ue_script_SA}     ${lua_method}=start_multiue_call_with_networkslice_sixoperator
    ...    ${ue_register_mue_value}=${ue_register_mue_value}    ${lua_method_stop_string}=${ue_register_stop_string}
    [Documentation]    This keyword is used at UE Register for MultiUE and checks the completion message in output file.
    ...                Modified Date: 27-Oct-2021
    ...                Last Modified by: praveen.t_k@nokia.com
    Log To Console    Starting SA UEs Registare...
    wtsrunner.script    file=${lua_file}    entry=${lua_method}(${ue_register_mue_value})
    Check Pattern in Egate Console Log    ${lua_method_stop_string}
    FOR   ${ueid}   IN   @{sa_ueids}
       ${validation_string}=    Catenate    UE${ueid}:     ${ue_registeration_completion}
       ${output}    Read WTS Output Until Pattern Matches    ${validation_string}    ${Timeout_SA}
       Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
       ${validation_string}=    Catenate     UE${ueid}:    ${ue_context_setup_pattern}
       Read WTS Output For Pattern And Print matching Lines    ${validation_string}    ${Timeout_SA}
    END
    sleep    5s

Stop And Validate SA Traffic For MultiUE
    [Arguments]    ${lua_file}=${multi_ue_script_SA}    ${ul_traffic_range}=${sa_ul_traffic_range}
    ...   ${dl_traffic_range}=${sa_dl_traffic_range}    ${dl_rate}=2    ${ul_rate}=2
    ${average_rate_list}=    Create List
    ${data_loss_list}=    Create List
    FOR   ${sa_ueid}   IN   @{sa_ueids}
        Run Keyword And Ignore Error    Calculate SA Throughput for MultiUE    ${sa_ueid}
        ${trf_throughput_status}    Run Keyword And Ignore Error    Validate Traffic Throughput Average Rate for SA    ${dl_rate}
        ...   ${ul_rate}   ${sa_ueid}
        Append To List    ${average_rate_list}    ${trf_throughput_status[0]}
        Stop Traffic For SA MultiUE    ${sa_ueid}
        ${trf_dataloss_status}    Run Keyword And Ignore Error    Validate Traffic Data Loss For SA    ${dl_rate}    ${ul_rate}   ${sa_ueid}
        Append To List    ${data_loss_list}    ${trf_dataloss_status[0]}
        ${status}    Run Keyword And Ignore Error    Should Be True
        ...   '${trf_throughput_status[0]}' == 'PASS' and '${trf_dataloss_status[0]}' == 'PASS'   msg=Traffic failed, see error above!
        ${status}=${None}
    END
    List Should Not Contain Value    ${average_rate_list}    FAIL    msg=Traffic failed in Throughput Average Rate
    List Should Not Contain Value    ${data_loss_list}    FAIL    msg=Traffic failed in Traffic Data Loss
    ${lua_file}=${ul_traffic_range}=${dl_traffic_range}=${None}

Calculate SA Throughput for MultiUE
    [Arguments]    ${UE_ID}=${UE_ID}
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=1   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=10
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_dl}    Bytes received +(\\d+)    1
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
    ${coll_time}    Get Regexp Matches    ${bearer_stat_dl}    Collection time for receiver stats +(\\d+)    1
    ${coll_time_int}    Convert To Integer   ${coll_time[0]}
    ${ue_data_rate}    python_keywords.cal_data_rate
    ...    ${bytes_rec_int}    ${coll_time_int}
    Append To List    ${dl_data_rates}    ${ue_data_rate}
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=1   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=10
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_ul}    Bytes received +(\\d+)    1
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
    ${coll_time}    Get Regexp Matches    ${bearer_stat_ul}    Collection time for receiver stats +(\\d+)    1
    ${coll_time_int}    Convert To Integer   ${coll_time[0]}
    ${ue_data_rate}    python_keywords.cal_data_rate
    ...    ${bytes_rec_int}    ${coll_time_int}
    Append To List    ${ul_data_rates}    ${ue_data_rate}

Validate DL and UL Cumulative Data Rates for MultiUE
    ${dl_data_rate}    Set Variable    0
    ${ul_data_rate}    Set Variable    0
    FOR   ${dl_val}    ${ul_val}   IN ZIP   ${dl_data_rates}    ${ul_data_rates}
            ${dl_data_rate}    Evaluate    float(${dl_data_rate}+${dl_val})
            ${ul_data_rate}    Evaluate    float(${ul_data_rate}+${ul_val})
    END
    ${num_of_dl_ues}=    Evaluate    len(${dl_data_rates})
    ${num_of_ul_ues}=    Evaluate    len(${ul_data_rates})
    Log    "DL rates: ${dl_data_rates}..and UL rates: ${ul_data_rates}..and DL and UL UEs:${num_of_dl_ues} and ${num_of_ul_ues}"
    Should Be True    ${dl_data_rate}>=90 and ${ul_data_rate}>=60
    ...    msg=Traffic failed due to less throughput
    List Should Not Contain Value    ${dl_data_rates}    0.0    msg='DL rate is 0 for one or more UEs.'
    List Should Not Contain Value    ${ul_data_rates}    0.0    msg='UL rate is 0 for one or more UEs.'

Validate SA LTE and NSA Data rates Before HO
    Log to console    Checking Data rates for all UEs before HO...
    Validate SA NSA and LTE Throughput
    Reset UL and DL Data Rates

Reset UL and DL Data Rates
    @{dl_data_rates}=    Create List
    @{ul_data_rates}=    Create List
    Set Suite Variable    @{dl_data_rates}
    Set Suite Variable    @{ul_data_rates}

Bringup Setup After Commissioning
    [Arguments]    ${proto}
    Perform SCF Commissioning    proto=${proto}
    Modify UTE SCTP Timeout
    Run Keyword If    '${proto}'!= 'GTPU'    Start WTS For Combo    proto=${proto}

Coam Site Should be Ready
    [Documentation]     This keyword checks whether TL is in Configured state and BTS sw is populated.
    Wait Coam Site to be Ready
    Should Contain    ${stream_nr}    SBTS

Power Reset From PDU
    ${rc}       ${output}=          Run and Return RC and Output     grep pdu_ports ${init_file}
    @{lines}=    Split String  ${output}    \n
    Length Should Be    ${lines}   4   Not able to find PDU ports from '${init_file}'

    ${rc}   ${output}=      Run and Return RC and Output     grep port_numbers ${init_file}
    ${rc}=${None}
    ${matched_value}=    Get Regexp Matches    ${output}    \\d{1,3}.\\d{1,3}.\\d{1,3}.\\d{1,3}
    Set Suite Variable    ${pdu_ip}    ${matched_value}
    FOR    ${line}    IN    @{lines}
        ${pdu_port}=    Get Substring   ${line}    -3   -2
        Reset port on PDU    ${pdu_ip}[0]    ${pdu_port}
    END

Reset port on PDU
    [Arguments]         ${PDU_IP}    ${PDU_PORT}    ${alias}=atenpdu    ${model}=RRB
    Log To Console      \n Reset ongoing for PDU ${PDU_IP}, port ${PDU_PORT}
    pdu.setup_pdu       host=${PDU_IP}
    ...                 model=${model}
    ...                 alias=${alias}
    pdu.power_off       port=${PDU_PORT}
    ...                 pdu_device=${alias}
    sleep               10s
    pdu.power_on        port=${PDU_PORT}
    ...                 pdu_device=${alias}
    Sleep               10s

Start WTS For Combo
    [Arguments]    ${proto}=${proto}
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS
    Stop Edaemon Egate
    Log to Console                 Starting WTS...
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    ...                                   nostats=True
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    Copy Lua File to WTS_DIR    ${proto}
    ${cfg_filename}  set variable   ${WTS_DIR}/${SUITE_WTS_CFG}
    wtsrunner.configure                      file=${cfg_filename}
    Check Simmode Status
    Wait Until Keyword Succeeds    2 min    30 sec    Verify if sim state is active

Check Simmode Status
    [Documentation]    This keyword checks if SimMode is ready in egate_console.log file
    ...                Modified Date: 15-Dec-2021
    ...                Last Modified by: anil.1.pachauri@nokia.com
    ${validation_string}=    Set Variable    SimMode is ready now
    ${status}    Run Keyword And Return Status    wtsrunner.read_wtsemu_output_until_re
    ...          expected=${validation_string}     timeout=240
    Run Keyword If    '${status}' == 'False'
    ...    Verify Pattern in Egate Console Log    ${validation_string}

Verify Pattern in Egate Console Log
    [Arguments]    ${pattern}    ${file}=${run_script_log_set}
    [Documentation]    This keyword checks if the ${pattern} is present in the egate_console.log file for the SA variant
    ...                Modified Date: 15-Dec-2021
    ...                Last Modified by: anil.1.pachauri@nokia.com
    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search pattern should Exists In EGATE
    ...                            ${WTS_DIR}/egate_console.log     ${pattern}

Modify Vlan
    [Arguments]    ${input_scf}=${input_scf}    ${output_scf}=${output_scf}    ${dist}=${dist}    ${ID}=${ID}
    ...    ${testline_resuls_path}=${testline_resuls_path}
    ${hostname}=    Get Hostname Details
    ${init_file}=    Catenate    ${testline_resuls_path}/${hostname}/__init__.py
    ${command}    Catenate    sed -nr 's/^.*vlan_id=//p' ${init_file} | cut -d')' -f1 | head -n 1
    ${vlan_id}    Run    ${command}
    scf.load_scf    ${input_scf}
    Run Keyword    scf.modify_scf_element    value=${vlan_id}    dist_name=${dist}    p_name=${ID}
    scf.save_scf    ${output_scf}

Copy Egate Console Log File
    [Arguments]    ${proto}=${proto}
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    sleep    2s
    Run Keyword And Ignore Error    Copy File    ${WTS_DIR}/egate_console.log
    ...    ${EXECDIR}/logs/egate_console_${proto}.log

Attach NSA Split Traffic
    Attach and Start NSA UL Traffic
    sleep    900s
    Wait Until Keyword Succeeds    15 min    1 min    Collect PM Counters and validate