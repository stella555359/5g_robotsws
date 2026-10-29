*** Settings ***
Library    OperatingSystem
Library    Collections
Library    Process
Library    String
Library    DateTime
Library    Telnet    prompt=>    WITH NAME    generator
Library    taf.sbts.oam.coam.admin.interface    WITH NAME    coamInterface
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh  WITH NAME  ssh
Library    ./bip_logs_parserFR1.py    WITH NAME    parser
Library    taf.ue    WITH NAME    ue

Resource    taf/rfrl/ue/robot/REAL_UE.robot

*** Keywords ***
Start Generating Max Tput
    [Arguments]    ${direction}    ${duration}    ${tput}    ${bts_connection}    ${cell_dist_name}
    ...    ${feature}=${None}    ${protocol}=tcp    ${deviation}=25%    ${parallel_streams}=2    ${size_packet}=1400B
    ...    ${buffer_client}=${None}    ${buffer_server}=${None}    ${interval}=1    ${qci}=${None}
    ...    ${linux_congestion}=reno    ${alias}=UE    ${bts_type}=GNB    ${clear_source_dir}=${False}
    Perform Attach and Verify UE Properly Attached
    ...    alias=${alias}
    ...    bts_type=${bts_type}
    ...    clear_source_dir=${clear_source_dir}
    ${direction_upper}    Convert To Upper Case    ${direction}
    Start Data Transfer on Real UE
    ...    dt_name=DT_${direction_upper}
    ...    ue_alias=${alias}
    ...    direction=${direction}
    ...    protocol=${protocol}
    ...    duration=${duration}
    ...    tput=${tput}
    ...    parallel_streams=${parallel_streams}
    ...    size_packet=${size_packet}
    ...    buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    ...    interval=${interval}
    ...    qci=${qci}
    ...    linux_congestion=${linux_congestion}
    Wait for truput stabilization
    ue.Check Data Transfer is Alive    dt_name=DT_${direction_upper}
    Run Keyword If    ${COLLECT_LOGS_DURING_DATA_TRANSFER}    Collect logs during data transfer    direction=${direction_upper}
    coam.Unblock Cell    dist_name=${cell_dist_name}

Await Tput Finish And Detach UE
    [Arguments]
    ...    ${direction}
    ...    ${tput}
    ...    ${deviation}
    ${direction_upper}    Convert To Upper Case    ${direction}
    ue.Await Data Transfer Finish    dt_name=DT_${direction_upper}
    Run Keyword And Ignore Error    ue.Verify Average Throughput With Deviation
    ...    dt_name=DT_${direction_upper}    tput=${tput}
    ...    deviation=${deviation}
    ue.Detach Ue    UE

Perform BTS And ASiR Commissioning
    [Arguments]
    ...    ${bts_scf_file}
    ...    ${ASiR_scf_file}
    Perform Bts Full Commissioning
    ...    scf_file=${bts_scf_file}
    ...    timeout=${600}
    Wait Until Keyword Succeeds    30s    400s    Verify Setup Of All Cells
    AsirOperations.perform_asir_commissioning    scf_path=${ASiR_scf_file}
    Wait Until Keyword Succeeds    30s    400s    Verify Setup Of All Cells

Perform Delta Recommissioning And Log Output
    [Arguments]
    ...    ${bts_connection}
    ...    ${delta_file}
    ${recommissioning_output}=    coam.Perform delta recommissioning
    ...    delta_file=${delta_file}
    ...    connection=${bts_connection}
    Log    ${recommissioning_output}    console=${TRUE}

Download And Find Required Pm Counters
    [Arguments]
    ...    ${time_stamp}
    ...    ${bts_connection}
    ...    ${out_dir_path}
    ${counters_ids}=    tools.generate_names_of_counters
    ${cell_list}    gnbcell.Get All Cells Id
    ${current_date}=    Get Current Date
    Log    [${current_date}]Collecting PM Counters...    console=${TRUE}
    ${counter_dict_list}=    coam.get_pm_counters
    ...    counter_ids=${counters_ids}
    ...    timeout=120
    ...    connection=${bts_connection}
    ${required_counters}=    tools.find_pm_counters_by_time_stamp
    ...    ${time_stamp}
    ...    ${counter_dict_list}
    ...    ${cell_list}
    ...    ${out_dir_path}
    ...    ${counters_ids}
    [Return]    ${required_counters}

Collect BIPlog and Download Pm Counters For Different Generator Setups
    [Arguments]
    ...    ${bts_connection}
    ...    ${frequency_val}
    ...    ${amplitude_val}
    ...    ${bandwidth_val}
    ...    ${TC_out_dir}
    ...    ${actNrUlRipMeasurement}
    ...    ${pucchModeSelect}
    ...    ${msg1FrequencyStart}
    ...    ${transmission_technology}
    ...    ${snap_file_name}
    coam.perform_parameter_recommissioning
    ...    dist_name=MRBTS-75086/NRBTS-75086
    ...    parameter=actNrUlRipMeasurement
    ...    operation=update
    ...    value=${actNrUlRipMeasurement}
    tools.set_generator
    ...    generator_ip=${generator_ip_addres}
    ...    frequency_val=${frequency_val}
    ...    amplitude_val=${amplitude_val}
    ...    bandwidth_val=${bandwidth_val}
    ${WEB_time_stamp}=    tools.Schedule Delay    delay=40
    ${gnb_logs_zip_name}=    Run Bip Log Collecting    370    ${TC_out_dir}
    ${required_counters}=    Download And Find Required Pm Counters
    ...    ${WEB_time_stamp}
    ...    ${bts_connection}
    ...    ${TC_out_dir}
    coam.get_snapshot    target_file_name=${TC_out_dir}/${snap_file_name}    connection=${bts_connection}
    Convert Pcap To SCVs
    ...    ${TC_out_dir}
    ...    ${gnb_logs_zip_name}
    ...    ${transmission_technology}   #10 FDD, 20 TDD
    ${rach_avg}=    tools.check_if_rach_should_be_counted
    ...    ${actNrUlRipMeasurement}
    tools.split_csv_by_subcellid    path_to_dir=${TC_out_dir}/${gnb_logs_zip_name}
    @{seconds_to_subtract}=    Create List    0s    1s    2s    4s    6s    8s
    FOR    ${seconds}    IN    @{seconds_to_subtract}
        ${bip_logs_counters_86}=    Parse Bip Logss
        ...    ${TC_out_dir}
        ...    ${gnb_logs_zip_name}
        ...    ${pucchModeSelect}
        ...    ${WEB_time_stamp}
        ...    ${transmission_technology}
        ...    ${msg1FrequencyStart}
        ...    ${rach_avg}
        ...    cell86
        ...    ${seconds}
        ${bip_logs_counters_186}=    Parse Bip Logss
        ...    ${TC_out_dir}
        ...    ${gnb_logs_zip_name}
        ...    ${pucchModeSelect}
        ...    ${WEB_time_stamp}
        ...    ${transmission_technology}
        ...    ${msg1FrequencyStart}
        ...    ${rach_avg}
        ...    cell186
        ...    ${seconds}
        ${is_compatible_86}=    tools.compare_counters_and_bip_logs_result
        ...    ${required_counters}
        ...    ${bip_logs_counters_86}
        ...    ${TC_out_dir}
        ...    ${WEB_time_stamp}
        ...    86
        ...    ${seconds}
        ${is_compatible_186}=    tools.compare_counters_and_bip_logs_result
        ...    ${required_counters}
        ...    ${bip_logs_counters_186}
        ...    ${TC_out_dir}
        ...    ${WEB_time_stamp}
        ...    186
        ...    ${seconds}
        Exit For Loop If    ${is_compatible_86} == ${is_compatible_186} == ${True}
    END
    Should Be True    ${is_compatible_86}
    Should Be True    ${is_compatible_186}

Run Bip Log Collecting
    [Arguments]
    ...    ${duration}
    ...    ${TC_out_dir}
    ${current_date}=    Get Current Date
    ${gnb_logs_cmd}=    Set Variable
    ...    ${gnb_logs_dir}/gnb_logs/gnb_logs ${bts_mplane_addres} -b ${duration} -N ${TC_out_dir}
    Log    [${current_date}]Collecting BIP Log...    console=${TRUE}
    ${rc}    ${output}=    Run and Return RC and Output    ${gnb_logs_cmd}
    Log    Bip Log rc: ${rc}    console=${TRUE}
    Log    Bip Log output: ${output}    console=${TRUE}
    Should Be Equal As Integers    ${rc}    0
    ${zip_name}=    tools.get_gnb_logs_zip_name    ${output}
    [Return]    ${zip_name}

Run Bip Log Collecting End Dont Wait For Output
    [Arguments]
    ...    ${duration}
    ...    ${alias}
    ...    ${TC_out_dir}
    ${current_date}=    Get Current Date
    Log    [${current_date}]Collecting BIP Log...    console=${TRUE}
    Start Process    ${gnb_logs_dir}/gnb_logs/gnb_logs    ${bts_mplane_addres}    -b    ${duration}    -N
    ...    ${TC_out_dir}
    ...    alias=${alias}

Wait For Bip Log End Check Output
    [Arguments]    ${alias}
    ${result}=    Wait For Process
    ...    handle=${alias}
    ...    timeout=720s
    ...    on_timeout=terminate
    Log    ${result.stderr}    console=${TRUE}
    Log    ${result.stdout}    console=${TRUE}
    Should Not Contain    ${result.stdout}    FAIL
    ${gnb_logs_zip_name}=    tools.get_gnb_logs_zip_name    ${result.stdout}
    [Return]    ${gnb_logs_zip_name}

Convert Pcap To SCVs
    [Arguments]
    ...    ${TC_out_dir}
    ...    ${gnb_logs_zip_name}
    ...    ${transmission_technology}
    ${current_date}=    Get Current Date
    Log    [${current_date}]Converting pcap to one csv...    console=${TRUE}
    tools.convert_gnb_logs_to_excel    ${TC_out_dir}/${gnb_logs_zip_name}.zip    ${transmission_technology}

Parse Bip Logss
    [Arguments]
    ...    ${TC_out_dir}
    ...    ${gnb_logs_zip_name}
    ...    ${puch_mode}
    ...    ${WEB_time_stamp}
    ...    ${transmission_technology}
    ...    ${msg1FrequencyStart}
    ...    ${rach_avg}
    ...    ${subcellid}
    ...    ${seconds_to_subtract}
    ${WEB_time_stamp_start}=    Subtract Time From Date
    ...    ${WEB_time_stamp}
    ...    ${seconds_to_subtract}
    ...    exclude_millis=yes
    ${WEB_time_stamp_end}=    Add Time To Date
    ...    ${WEB_time_stamp_start}
    ...    5min
    ...    exclude_millis=yes
    ${bip_logs_counters}=    parser.Parse Bip Logs
    ...    path_to_dir=${TC_out_dir}/${gnb_logs_zip_name}
    ...    puch_mode=${puch_mode}
    ...    start_time=${WEB_time_stamp_start}
    ...    end_time=${WEB_time_stamp_end}
    ...    transmission_technology=${transmission_technology}
    ...    msg1FrequencyStart=${msg1FrequencyStart}
    ...    rach_avg=${rach_avg}
    ...    result_dir=${TC_out_dir}
    ...    subcellid=${subcellid}
    [Return]    ${bip_logs_counters}

Install Pandas With Pip
    ${result}=    Run Process    pip install pandas    shell=True    stdout=${logs_out_dir}/pip_install_result.txt
    Log    ${result}

Clone Gnblogs Tool
    Run Process    mkdir /home/ute/gnb_logs    shell=True
    Run Process    git clone https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool.git ${gnb_logs_dir}
    ...    shell=True
    ...    stdout=${logs_out_dir}/gnblogs_install_result.txt
    Run Process    unzip    ${gnb_logs_dir}/gnb_logs.zip
    ...    shell=True
    Run Process    chmod 774 ${gnb_logs_dir}/gnb_logs/gnb_logs
    ...    shell=True
    Run Process    cp ${CURDIR}/config.ini ${gnb_logs_dir}/gnb_logs
    ...    shell=True

Custom Suite Setup
    Variable Should Exist    ${ENB_BRANCH}
    ${SCF_gNB_FDD_TDD}=    Set Variable    ${CURDIR}/SCFs/${ENB_BRANCH}/FDD_TDD_scf_MRBTS_086_CPRI_FR1.xml
    ${SCF_ASiR_FDD_TDD}=    Set Variable    ${CURDIR}/SCFs/${ENB_BRANCH}/FDD_TDD_scf_asir_MRBTS_086_CPRI_FR1.xml
    Perform BTS And ASiR Commissioning
    ...    ${SCF_gNB_FDD_TDD}
    ...    ${SCF_ASiR_FDD_TDD}
    Install Pandas With Pip
    Clone Gnblogs Tool

Custom Test Teardown
    [Arguments]    ${bts_connection}
    tools.turn_off_generator    generator_ip=${generator_ip_addres}
    Run Keyword And Ignore Error    ue.Detach Ue    UE
    coam.perform_parameter_recommissioning    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-86
    ...                                       parameter=adjustPrachThresholdOffset
    ...                                       operation=update
    ...                                       value=0
    coam.perform_parameter_recommissioning    dist_name=MRBTS-75086/NRBTS-75086/NRCELL-186
    ...                                       parameter=adjustPrachThresholdOffset
    ...                                       operation=update
    ...                                       value=0
    coam.Teardown    connection=${bts_connection}