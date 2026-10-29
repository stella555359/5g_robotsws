*** Keywords ***
Perform Full Commission And Reach Onair With Log
    [Arguments]     ${scfc}      ${wts_config}    ${wait_onair_timeout}=1500    ${reset_after_commission}=${False}
    ...             ${wait_bts_timeout}=600    ${wait_rru_timeout}=600    ${L1b}=False
    [Documentation]    This keyword will use ${scfc} to do full commission, and use ${wts_config} to start wts process and check onair
    ...    | Input Parameters | Man. | Description |
    ...    | scfc | Yes | SCF file path. |
    ...    | wts_config | Yes | WTS config file |
    ...    | wait_onair_timeout | No | timeout to check onair. Default is 1500 |
    ...    | reset_after_commission | No | Will reset bts after commission.Default is False |
    ...    Examples:
    ...    | Perform Full Commission And Reach Onair | scfc.xml |  wts_config.xml |
    Log to console    Perform Full Commissioning And Reach Onair start.
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc}    ${test_log_directory()}/full_commission/
    Perform Full Commission     ${new_scfc}
    Run Keyword If    '${reset_after_commission}'=='True'     Reset Testline
    FOR    ${loop}    IN RANGE    2
        ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
        Run Keyword If    '${bts_status}' == 'False' and ${loop} < 1    Reset Testline
        Continue For Loop If    '${bts_status}' == 'False' and ${loop} < 1
        Run Keyword If    '${bts_status}' == 'False' and ${loop} >= 1    Fail
        ${remote info}     Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
        run keyword and ignore error    Start Tcpdump    cellSetup${loop}    -i any    ${remote info}
        ${rru_status}=    Run Keyword And Return Status    Wait Until RRU Configured    ${wait_rru_timeout}
        Run Keyword If    '${rru_status}' == 'False' and ${loop} < 1    Reset Testline
        Continue For Loop If    '${rru_status}' == 'False' and ${loop} < 1
        Run Keyword If    '${rru_status}' == 'False' and ${loop} >= 1    Fail
        Run Keyword If    '${L1b}' == 'True'
         ...    Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
        ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${wts_config}
         ...    timeout=${wait_onair_timeout}
        Run Keyword If    '${onair_status}' == 'True'    Stop Tcpdump       cellSetup${loop}     ${test_log_directory()}
        OperatingSystem.Run    mv ${test_log_directory()}/cellSetup*.pcap ${test_log_directory()}/cellSetup0.pcap
        Return From Keyword If    '${onair_status}' == 'True'
        Run Keyword If    '${onair_status}' == 'False' and ${loop} < 1    Reset Testline
        Run Keyword If    '${onair_status}' == 'False' and ${loop} >= 1    Fail
    END

download PM counter file
    [Arguments]    ${log_dir}
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    ${remaining_time}     evaluate    ${remaining_time}+120
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${log_dir}${/}
    [Return]    ${PM_counter_file}
