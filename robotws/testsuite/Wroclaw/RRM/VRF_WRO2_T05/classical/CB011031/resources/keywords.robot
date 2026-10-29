*** Settings ***
Documentation    Suite description
Library         ./CB011031.py
Library         taf.rfrl.procedures.resources.python.sw_update.SW_update
Library         ta5g_pm_counters
Library         ta5g_tshark
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource        taf/rfrl/common_resources/robot/libraries_instances.robot


*** Keywords ***
Check_f1_ng_paging
    [Arguments]  ${dir}=${OUTPUT DIR}/SCTP_${TEST_NAME}.pcap
    ${msgs}    generated_pcap_data_for_paging   ${dir}
    should be true    ${msgs}

Start Tshark SCTP
    setup_tshark_with_nokia_f1ap_plugin
    start_tcpdump_on_remote_interface    alias=tcpdump

Stop Tshark and download logs SCTP
    stop_tcpdump_on_remote_interface

Read counters value 11031
    ${counters_values}=   Create List
    Collect Counters   n_last=8
    @{counters}   Create list  M55351C01001  M55351C01002  M55308C33000  M55308C33001  M55351C00001
    FOR    ${counter}    IN      @{counters}
       ${value}    Get sum of n last counter values   8  ${counter}
       Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Read counters value eventA3
    ${counters_values}=   Create List
    Collect Counters   n_last=8
    @{counters}   Create list  M55147C00024
    FOR    ${counter}    IN      @{counters}
       ${value}    Get sum of n last counter values   8  ${counter}
       Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Read counters value eventA5
    ${counters_values}=   Create List
    Collect Counters   n_last=8
    @{counters}   Create list  M55147C00025
    FOR    ${counter}    IN      @{counters}
       ${value}    Get sum of n last counter values   8  ${counter}
       Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify PM Counters 11031
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55308C33000    >0    ACC_UE_MICRO_DTX_OPTIMIZED
    ...    M55308C33001    >0    ACC_UE_MICRO_DTX_NO_BUNDLIN
    ...    M55351C01002    >0    AVG_UE_CONFIG_2BWP
    ...    M55351C01001    >0    MAX_UE_CONFIG_2BWP
    ...    M55351C00001    >0    MAX_UE_ACTIVE_PWR_SAVING_BWP
    ...    local_moid=PLMN-PLMN/MRBTS-51001/NRBTS-51001/NRCELL-1
    ...    file_path=${pm_counter_file}

Verify PM Counters eventA3
    log to console              Waiting for BTS Counters update 300s
    sleep   300s
    ${counters}                 Read counters value eventA3
    Log to console  ${counters}
    ${eventA5}           get_counter_value_from_single_cell   ${counters}  1    M55147C00024
    Should Be True      ${eventA5}>=1

Verify PM Counters eventA5
    log to console              Waiting for BTS Counters update 300s
    sleep   300s
    ${counters}                 Read counters value eventA5
    Log to console  ${counters}
    ${eventA5}           get_counter_value_from_single_cell   ${counters}  1    M55147C00025
    Should Be True      ${eventA5}>=1

Check bwpId powersaving
    ${output}=  check_bwpId_powersaving_tti
    Should Be True  ${output}


Set suite variables
    ${sw_release}    get stream name
    Set suite variable    ${sw_release}

Reset RMOD In Case Of Software Downgrade
    @{active_passive_sw}=    get_active_and_passive_sw_version
    ${active_sw}=    Get from list    ${active_passive_sw}    0
    ${passive_sw}=    Get from list    ${active_passive_sw}    1
    Log to console    Active SW: ${active_sw}, Passive SW: ${passive_sw}
    IF    '${passive_sw}' > '${active_sw}'
        ADMIN CLI connection
        @{alarm_list}=    Check unwanted alarms
        ${is_7116_active}=  run keyword and return status    Check if alarm exist    ${alarm_list}    2934
        IF    ${is_7116_active}
            Check PDU model and set RU power reset
        ELSE
            Log to console    Alarm 7116 not detected.
        END
    ELSE
        Log to console    RMOD reset not necessary.
    END
