# # #*** Settings ***
# # #Documentation
# # #...    author: Bella Chen
# # #...    contact:bella.chen@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : CB007326_1796
# # #
# # #Force Tags    CA_5G_RRM
# # #...    PY36
# # #
# # #
# # #Suite Setup       Run Keywords
# # #...    Run Keyword And Ignore Error       Common Suite Setup for COAM    AND
# # #...    Prepare testline to cell onair for SA    localFilePath=${swconfig}    tl_scf_filename=${scf_enable1796}
# # #
# # #Suite Teardown      Run Keyword And Ignore Error     Common Suite Teardown for COAM
# # #
# # #Resource       ../CB007326_2060/Resources/CB007326_2060_coam_common_keywords.robot
# # #Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/asod.robot
# # #Library         ../CB007326_2060/Resources/Read_laIniDelta.py    WITH NAME    LAINI
# # #Library           ../CB007326_2060/Resources/TTI_Trace_ASOE.py    WITH NAME    ttiASOE
# # #Variables    ./Resources/variables_2060.py
# # #
# # #*** Variables ***
# # #
# # #${scf_enable1796}          7326_784_SCF.xml
# # #${swconfig}                 /opt/workspace/SCF/1796/swconfig/swconfig.txt
# # #${2060_B_nglog}           2060_B_wireshark_enable.pcap
# # #${Send_Tput_DL}              1200M
# # #${Expect_peak}      1200
# # #${att_good}    ${25}
# # #${att_good_388}    ${35}
# # #${att_bad}    ${127}
# # #${atten_ip}                  ${tl.attenuator[0].ip_addr}
# # #
# # #
# # #*** Test Cases ***
# # #[1]CB007326_5G_A_5GC001796_B_200_DL_LA_Check_NIDD_impact_on_Update_of_iniDeltaCqi_cmW
# # #    [Documentation]
# # #    ...    new improvement of 1796-B is not applied: update of iniDeltaCqi occurs when NIDD parameter is set to FALSE
# # #    ...    new improvement of 1796-B is applied and No update of iniDeltaCqi occurs for highest,
# # #    ...    lowest MCS and 1796-A case when NIDD parameter is set to TRUE (default value).
# # #    [Tags]      classical    CRT_TRUNK    CRT_22R2
# # #    [Timeout]    2 hour
# # #    [Setup]
# # #    Set automatic rotation on UEs
# # #    Modify the COAM parameter with admin API    parameters=${parameter_actEnhancedLinkAdaptation_true}
# # #    lock LTE
# # #    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
# # #    ...    Adjust the tl HBTE attenuation value    tl=${376}    value1=${att_good}    value2=${att_bad}
# # #    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[2]}'
# # #    ...    Adjust the tl HBTE attenuation value    tl=${388}    value1=${att_good}    value2=${att_bad}
# # #    ...    ELSE    Adjust the tl HBTE attenuation value    tl=${377}    value1=${att_good}    value2=${att_bad}
# # #    Set Suite Variable    ${ue_type}    xiaomi
# # #    Check UE device exist
# # #    Prepare env with UE
# # #    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'    Get all xiaomi11 pointer variable
# # #    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[2]}'    Get all xiaomi11 pointer variable tl388
# # #    ...    ELSE    Get all xiaomi11 pointer variable tl377
# # #    Test ON SA 388
# # #    Parse laIniDelta Event    target=SKIP
# # #    Tests Recover
# # #    lock LTE
# # #    ## actEnhancedLinkAdaptation set to FALSE,laIniDelta event should be update
# # #    Modify the COAM parameter with admin API    parameters=${parameter_actEnhancedLinkAdaptation_false}
# # #    COAM gNB Reset site
# # #    Test ON SA 388
# # #    Parse laIniDelta Event
# # #    [Teardown]    Run Keyword And Ignore Error     Tests Recover
# # #
# # #
# # #*** Keywords ***
# # #
# # #Test ON SA
# # #    Start TTI trace log capturing ASOE
# # #    Power UE Attach and Verify attach for askey     4g_check=False
# # #    Start DL date transfer on appserver    traffic=${Send_Tput_DL}
# # #    sleep    2s
# # #    Stop TTI trace log capturing ASOE
# # #    Download TTi Logs ASOE
# # #    Askey UE stop dl traffic on appserver and detach
# # #
# # #Test ON SA 388
# # #    Start TTI trace log capturing ASOE
# # #    Power UE Attach and Verify attach
# # #    Start DL date transfer    dl_throughput=${Send_Tput_DL}    ue_index=${0}
# # #    sleep    2s
# # #    Stop TTI trace log capturing ASOE
# # #    Download TTi Logs ASOE
# # #    Xioami UE stop dl traffic and detach
# # #
# # #Tests Recover
# # #    Run Keyword And Ignore Error    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}
# # #    ...    asik_password=${asik_password}
# # #    Run Keyword And Ignore Error    csn.send command    command=killall tcpdump     connection=gnb
# # #    Run Keyword And Ignore Error    Xioami UE stop dl traffic and detach
# # #    Run Keyword And Ignore Error    unlock LTE
# # #    Run Keyword And Ignore Error    disconect all connections
# # #    Run Keyword And Ignore Error    csn.disconnect    connection=ASOD
# # #
# # ##UE stop dl traffic and detach
# # ##    Xioami UE stop dl traffic and detach
# # #
# # ##TTI trace ASOE
# # #Start TTI trace log capturing ASOE
# # #    [Documentation]
# # #    ...    Description: 1. Clear the log folder /var/eventsTrace
# # #    ...    2. Start TTI trace process
# # #    Connect to ASOD
# # #    ttiASOE.prepare_for_tti_trace_log_capturing    connection=ASOD
# # #    ttiASOE.start_tti_trace    connection=ASOD
# # #
# # #Stop TTI trace log capturing ASOE
# # #    [Documentation]
# # #    ...    Description: Kill TTI trace process
# # #    Connect to ASOD
# # #    ttiASOE.stop_tti_trace    connection=ASOD
# # #
# # #Download TTi Logs ASOE
# # #    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc ASOE
# # #    ${dl_path}=    get_from_dictionary    ${dict_csv_file_path}    DL
# # #    ${ul_path}=    get_from_dictionary    ${dict_csv_file_path}    UL
# # #    Set Suite Variable    ${TTI_CVS_PATH_DL}    ${dl_path}
# # #    Set Suite Variable    ${TTI_CVS_PATH_UL}    ${ul_path}
# # #
# # #Convert TTI trace log and download combined csv logs to test pc ASOE
# # #    [Arguments]    ${local_path}=${epc_log_path}
# # #    [Documentation]
# # #    ...    Description:
# # #    ...    1. ${local_path} Refers to the test case log path in test pc
# # #    ...    2. Convert bin files to csv files
# # #    ...    3. Combine multiple CSV files to one csv file for UL and DL direction
# # #    ...    4. Will return the local file path as a dict with UL and DL csv file paths in test pc.
# # #    ...    Example output: {'UL':'XXXX', 'DL':'XXXX'}
# # #    Connect to ASOD
# # #    ${csv_path}    ttiASOE.convert_tti_trace_to_csv    connection=ASOD
# # #    ${csv_file_path_ul}    ttiASOE.combine_csv_files_to_one    csv_log_path=${csv_path}    direction=ul    connection=ASOD
# # #    ${csv_file_path_dl}    ttiASOE.combine_csv_files_to_one    csv_log_path=${csv_path}    direction=dl    connection=ASOD
# # #    ${remote_files}    Create list    ${csv_file_path_ul}    ${csv_file_path_dl}
# # #    csn.download file    remote_path=${remote_files}    local_path=${local_path}    connection=ASOD
# # #    csn.disconnect    connection=ASOD
# # #    @{csv_file_name_ul}    Split string    ${csv_file_path_ul}    /
# # #    @{csv_file_name_dl}    Split string    ${csv_file_path_dl}    /
# # #    &{local_csv_file_path}    create dictionary
# # #    Set to dictionary    ${local_csv_file_path}    UL    ${local_path}@{csv_file_name_ul}[-1]
# # #    Set to dictionary    ${local_csv_file_path}    DL    ${local_path}@{csv_file_name_dl}[-1]
# # #    [Return]    ${local_csv_file_path}
# # #
# # #Parse laIniDelta Event
# # #    [Arguments]         ${target}=UPDATE    ${tti_path}=${TTI_CVS_PATH_DL}    ${traffic_direction}=DL
# # #    # tti parse in B200 and B300
# # #    ${laIniDelta}=   run keyword if   '${traffic_direction}'=='DL'   LAINI.read_lainidelta    ${tti_path}
# # ##    ...                        ELSE       Read Lainidelta     ${tti_path}/combined_ul_trace.csv
# # #	log 		  laIniDelta=${laIniDelta}
# # #	log           even found=${laIniDelta['event']}
# # #	Should Match    ${laIniDelta['event']}    ${target}
