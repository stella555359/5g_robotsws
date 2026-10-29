*** Settings ***
Documentation
...    Additional robot keywords for CB008021 FR2 part
...    authors: Lubomir Krzeminski
...    maintainer: Lubomir Krzeminski
...    group: RAN_PZ_KRK_SG_7
...    contact: lubomir.krzeminski@nokia.com

Library    Collections
Library    DateTime
Library    String
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.nms.netact
Library    taf.rfrl.ue.ute_ue_config.UteUeConfig


*** Keywords ***
Suite Precondition
    Add Node    cmwas    ${HOSTNAME}    ${USERNAME}    ${PASSWORD}    alias=${NETACT_NAME}
    ${web_url}=    Detect WEB URL    alias=${NETACT_NAME}
    Add WEB URL    ${web_url}    ${USERNAME}    ${PASSWORD}    alias=${NETACT_NAME}
    Create Directory    ${work_directory}

Suite Postcondition
    Delete Node    cmwas    alias=${NETACT_NAME}
    Clean All    alias=${NETACT_NAME}

Cleanup after TC
    ${cell_list}    gnbcell.Get All Cells Id
    FOR     ${cell}    IN    @{cell_list}
        coam.perform_parameter_recommissioning    dist_name=${cell_dist_name}${cell}
        ...                                       parameter=${adjustPrach_name}
        ...                                       value=0
        ...                                       operation=update
        ...                                       skip_parameter_relation_errors=${True}
    END
    Wait Until Keyword Succeeds    2min    5sec     gnbcell.Verify Setup Of All Cells

Prepare before TC
    ${bts_connection}    coam.connect_to
    ${cell_list}    gnbcell.Get All Cells Id
    coam.perform_parameter_recommissioning    dist_name=${miNrRip_dist}
    ...                                       parameter=miNrRip
    ...                                       value=5min
    ...                                       operation=update
    ...                                       skip_parameter_relation_errors=${True}
    coam.perform_parameter_recommissioning    dist_name=${actNrUlRip_dist}
    ...                                       parameter=actNrUlRipMeasurement
    ...                                       value=enabledWithoutPRACH_PUCCH_F1
    ...                                       operation=update
    ...                                       skip_parameter_relation_errors=${True}
    FOR     ${cell}    IN    @{cell_list}
        coam.perform_parameter_recommissioning    dist_name=${cell_dist_name}${cell}
        ...                                       parameter=pucchModeSelect
        ...                                       value=shortPucch
        ...                                       operation=update
        ...                                       skip_parameter_relation_errors=${True}
    END

Get UE Config
    &{abstract_lib_config}    Get ute UE Configuration Dict
    BuiltIn.Set Global Variable    ${ue_pc_ip}
    ...    ${abstract_lib_config.UE_POOLS.TafUeAndroidPool.inline_config.ANDROID_UE_1.CONSTRUCTOR_PARAMETERS.configuration.ue_pc_address}
    BuiltIn.Set Global Variable    ${ue_pc_user}
    ...    ${abstract_lib_config.UE_POOLS.TafUeAndroidPool.inline_config.ANDROID_UE_1.CONSTRUCTOR_PARAMETERS.configuration.login}
    BuiltIn.Set Global Variable    ${ue_pc_password}
    ...    ${abstract_lib_config.UE_POOLS.TafUeAndroidPool.inline_config.ANDROID_UE_1.CONSTRUCTOR_PARAMETERS.configuration.password}
    BuiltIn.Set Global Variable    ${real_ue_id}
    ...    ${abstract_lib_config.UE_POOLS.TafUeAndroidPool.inline_config.ANDROID_UE_1.CONSTRUCTOR_PARAMETERS.serial_number}
    BuiltIn.Set Global Variable    ${interference_ue_id}
    ...    ${abstract_lib_config.UE_POOLS.TafUeAndroidPool.inline_config.ANDROID_UE_2.CONSTRUCTOR_PARAMETERS.serial_number}

Collect BIP Log
    ssh.connect_to    hostname=${ue_pc_ip}    username=${ue_pc_user}    password=${ue_pc_password}    alias=PC-conn1
    ${ls_output_from_remote}=    ssh.Send Command
    ...                          command=./gnb_logs_2.31/gnb_logs_2.31/gnb_logs.exe ${mplane_ip} -b 420
    ...                          connection=PC-conn1
    Sleep    1s


Download BIP Log
    [Arguments]    ${connection}
    FOR    ${i}    IN RANGE    6
        ${find_BIP_log_cmd}=    BuiltIn.Set Variable
        ...                     find ./ -maxdepth 1 -type f -iname "BTS*_BIP.zip" -exec basename {} \\;
        ${output_from_remote}=    ssh.execute    command=${find_BIP_log_cmd}    connection=${connection}    timeout=15s
        ${length}    BuiltIn.Get Length    ${output_from_remote}
        Exit For Loop If    ${length} > 10
        Sleep    10s
    END
    ${output_from_remote}=    Remove String    ${output_from_remote}    \r\n
    Log    BIP log: ${output_from_remote}    console=${TRUE}
    ssh.Download File    remote_path=./${output_from_remote}
    ...                  local_path=${work_directory}${output_from_remote}
    ...                  connection=${connection}
    ssh.execute    command=rm ./${output_from_remote}    connection=${connection}    timeout=15s
    [Return]    ${work_directory}${output_from_remote}


Download Pm Counters
    [Arguments]    ${time_stamp}    ${bts_connection}
    ${counters}=    tools.generate_names_of_counters
    ${cell_list}    gnbcell.Get All Cells Id
    ${counter_dic_list}=    coam.get_pm_counters
    ...                     counter_ids=${counters}
    ...                     timeout=120
    ...                     connection=${bts_connection}
    ${file_name}=    tools.find_pm_counters_by_time_stamp    ${time_stamp}    ${counter_dic_list}    ${cell_list}
    [Return]    ${file_name}

Download and Process BIP Log
    [Arguments]    ${asfn_step}
    ...            ${WEB_time_stamp}
    ...            ${puch_mode}
    ...            ${tx_tech}
    ...            ${msg1_freq_start}
    ...            ${actNrUlRip}
    bipcollector.Download Bip Logs    download_dir=${work_directory}
    ${full_pcap_file}   Find Pcap File    path_to_work_dir=${work_directory}
    ${converted_path}=    tools.convert_gnb_logs_to_excel    ${full_pcap_file}   ${asfn_step}    ${4}
    ${WEB_time_stamp_start}=    Subtract Time From Date    ${WEB_time_stamp}    2s    exclude_millis=yes
    ${WEB_time_stamp_end}=    Add Time To Date    ${WEB_time_stamp_start}    5min    exclude_millis=yes
    ${rach_avg}=    tools.check_if_rach_should_be_counted    ${actNrUlRip}
    ${bip_final_path}=    tools.convert_bip_to_final_csv    path_to_dir=${converted_path}
    ...                                                     puch_mode=${puch_mode}
    ...                                                     start_time=${WEB_time_stamp_start}
    ...                                                     end_time=${WEB_time_stamp_end}
    ...                                                     transmission_technology=${tx_tech}
    ...                                                     msg1FrequencyStart=${msg1_freq_start}
    ...                                                     rach_avg=${rach_avg}
    ...                                                     result_dir=${work_directory}
    [Return]    ${bip_final_path}

Compare pm_counters with BIP_log
    [Arguments]     ${pm_counters_path}    ${bip_log_path}     ${threshold}
    ${avg_result}    ${max_result}    tools.compare_bip_log_and_pm_counters    bip_log_path=${bip_log_path}
    ...                                                                        pm_counters_path=${pm_counters_path}
    ...                                                                        threshold=${threshold}
    ...                                                                        counters_len=${66}
    Should Be Equal    ${avg_result}    ${0}    AVG counters are above threshold!
    Should Be Equal    ${max_result}    ${0}    MAX counters are above threshold!


Test DTX Teardown
    coam.Teardown    connection=${bts_connection}


Install pandas with pip
    ${result}=    Run Process    pip install pandas    shell=True    stdout=${work_directory}pip_install_result.txt
    Log    ${result}
