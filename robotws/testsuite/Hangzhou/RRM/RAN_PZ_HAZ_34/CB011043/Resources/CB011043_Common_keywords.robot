*** Settings ***
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    String
Library    taf.transport.ssh    WITH NAME    ssh
Library     XML
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/parse_soap.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/py_script.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ru_soap_log.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB011043/Resources/CB011043_variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/RUfile_opearte_common_keyword.robot

Documentation
...   author: Yu lu
...   contact: lu.1.yu@nokia-sbell.com
...   squad group: SG_02

*** Variables ***
${vm_tmp_log_dir}    /tmp

${swconfig_file}        /rom/swconfig_local.txt

${apn1}    ${tl.core.pdns[0].apn}

*** Keywords ***
CB011043 Case Setup
    robot_common_operations.Common Case Setup    allowed_faults_ids=61631,16,4298
    COAM Create log directory for 11043
    COAM Wait for gnb ready and cell setup and sync status
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    ${exist_fault}    COAM Get active alarms
    Set test variable    ${exist_fault}
    COAM Wait for gnb ready and cell setup    timeout=20 min
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}
    COAM Navigate to login page via webUI    download_dir=${vm_tmp_log_dir}
    ${backup_scf_file}    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    COAM selenium close browser
    Set Test Variable    ${backup_scf_file}
    Add RU file on RU    file_path=${swconfig_file}   file_content=${SWCONFIG_CONTENT}
    Connect to Common Unit Master
    Connect to gnb coam via ssl
    ${ru_info}   COAM get ru detial info by ru index  ru_index=${1}
    ${ru_type}   set variable  ${ru_info}[productName]
    run keyword if     '${ru_type}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}

COAM Create log directory for 11043
    COAM Create log directory
    Set suite variable    ${tmp_log_dir}    ${LOG_PATH}

COAM Wait for gnb ready and cell setup and sync status
    COAM Wait for gnb ready and cell setup
    Wait until keyword succeeds    10min    20 sec    COAM Check GNB Sync status

COAM Check GNB Sync status
    [Arguments]    ${connection}=GNB_OAM
    Log to console    Check GNB Sync status
    ${sync_info}    coam.get_bts_sync_source_status    connection=${connection}
    @{sync_status_info}    Set variable    ${sync_info['syncSourceInfo']}
    &{sync_status}    Set variable    ${sync_status_info[0]}
    Run keyword and continue on failure    Should be equal as strings    ${sync_info['syncMode']}    PhaseSync
    ...                                    msg=Current synchronization mode is not PhaseSync mode    ignore_case=${True}
    Run keyword and continue on failure    Should be equal as strings    ${sync_status['status']['availability']}    Available
    ...                                    msg=Current synchronization status is not available    ignore_case=${True}
    Run keyword and continue on failure    Should contain any    ${sync_info['tuningMode']}    Normal tuning    Normal
    ...                                    msg=Current synchronization tuning mode is abnormal    ignore_case=${True}

Check for unexpected alarms
    Connect to gnb coam via ssl
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=GNB_OAM

CB011043 Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    SG2_Common_setup_teardown.COAM commission scf and wait cell setup    scf_file_path=${backup_scf_file}
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    ssh.Disconnect    connection=ASIK Master
    CI_interface.Common Case Teardown

get software version for 11043
    COAM Navigate to login page via webUI
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    COAM selenium logout
    ${stream}    String.Get Substring    ${current_version['Active']}    0    8
    [Return]     ${stream}

Load Case SCF and Commission SCF for 11043
    [Arguments]    ${scf_file}
    Selenium Login And Disable Screen Lock
    log to console  ${CURDIR}
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -56
    log to console    ${SCF_PATH}
    COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min

Start DLUL traffic and Caculate Tput and catch IQ data
    [Arguments]     ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}     ${Expected_Throughput_UL}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
#    power_ue.Prepare UE     ue_type=${ue_type}    ui_version=default
#    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    power_ue.Prepare UE     ue_type=${ue_type}    ui_version=${tl.ues[${0}].capabilities[${1}]}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}    cap_index=${2}
    Run keyword and ignore error    power_ue.Verify attach     ue_type=${ue_type}     4G_check=False     5Grach_ed=${5Grach_ed}
#    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}     duration=2000    ue_mode=NSA
#    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}     duration=2000    ue_mode=NSA
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}     duration=3600    ue_mode=SA
    ...                        apn_address=${apn1}
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}     duration=3600    ue_mode=SA
    ...                        apn_address=${apn1}    cap_index=${2}
    Catch IQ data from webUI
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=8m
    ${list_of_cell_ids}    Create list    160481
    run keyword and continue on failure    power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${Expected_Throughput_UL}
    run keyword and continue on failure    power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${list_of_cell_ids}    log=${tput_log}
    ...                     target_throughput=${Expected_Throughput_DL}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul

Catch IQ data from webUI
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    Run    rm -rf ${TS_CASE_LOG_PATH}/L1IQData_MRBTS*
    log to console   \n begin to config IQ capture...
    run keyword and continue on failure    IQ capture config
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    selenium_coam.save_screenshot   filename=Screen_${curr_data}.png    screenshot_dir=${TS_CASE_LOG_PATH}
    sleep    10s
    log to console   \n begin to Save IQ capture data...
    run keyword and continue on failure    Save IQ capture data
    ${curr_data_save}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    selenium_coam.save_screenshot   filename=Screen_${curr_data_save}.png    screenshot_dir=${TS_CASE_LOG_PATH}
    COAM selenium logout

IQ capture config
     @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${subcell_index}    Set Variable If
    ...     '${stream}'=='SBTS25R2'        [BBMOD_R-1(ABIO)] [PCI: 444][7-2a]NRCELL-1: Subcell 0
    ...     [BBMOD_R-1(ABIO)] [PCI: 444]NRCELL-1: Subcell 0
    ${subcell_index_list}=    Create List    ${subcell_index}
    #${dl_subcell_index_list}=    Create List    [BBMOD_R-1(ABIO)] [PCI: 444][7-2a]NRCELL-1: Subcell 0
    run keyword if     '${stream}'=='SBTS25R2'    selenium_coam.configure_iq_capture
    ...                                           ul_subcell_index_list=${subcell_index_list}
    ...                                           dl_subcell_index_list=${subcell_index_list}
    ...                                           enable_capture_on_event=${True}
    ...       ELSE                                selenium_coam.configure_iq_capture
    ...                                           ul_subcell_index_list=${subcell_index_list}
    ...                                           dl_subcell_index_list=${subcell_index_list}
    ...                                           enable_capture_on=Event

Save IQ capture data
    selenium_coam.save_iq_capture
    ...    sfn_value=${65535}
    ...    slot_value=${0}
    ...    capture_mode=Schedule synchronous stop of ongoing continuous capture
    sleep    360s

Catch and check CPRT log
    ${ci_var_dict}    CI_commssion._Set Variables For Test
    run keyword if     '${ci_var_dict}[stream]'=='SBTS23R4'    Catch and check CPRT log for 23R4
    ...     ELSE     Catch and check CPRT log for Other

Catch and check CPRT log for Other
    ${xz_file}    Download File From ASIB for 11043   log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
	Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
	Run    ${unxz_command}
	Check item on crpt file for 11043    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=1    check_item=actEcpriExtType12: (\\d)
	Check item on crpt file for 11043    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=[Ul] = 1    check_item=Fragmentation enabled (.*)
	Check item on crpt file for 11043    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=[Dl] = 1    check_item=Fragmentation enabled (.*)

Catch and check CPRT log for 23R4
    ${xz_file}    Download File From ASIB for 11043   log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
	Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
	Run    ${unxz_command}
	Check item on crpt file for 11043    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=true    check_item="ruSupportsExtType12":(\\w{4,10})
	Check item on crpt file for 11043    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=[Ul] = 1    check_item=Fragmentation enabled (.*)
	Check item on crpt file for 11043    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	...    check_value=[Dl] = 1    check_item=Fragmentation enabled (.*)

Download File From ASIB for 11043
    [Arguments]   ${log_prefix}    ${path}    ${log_path}=${TS_CASE_LOG_PATH}    ${connection}=ASIK Master
    Connect to Common Unit Master
	@{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
    ...    file_indicator=${log_prefix}*
    should not be empty  ${list_log_names}    msg=No file found with log prefix ${log_prefix} under asik tmp folde
    @{list_log_path_local}    Create list
    FOR  ${log_name}  IN  @{list_log_names}
        Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
        ...   remote_path=${path}/${log_name}
        ...   local_path=${log_path}/${log_name}
        ...   connection=${connection}
        Append to list    ${list_log_path_local}    ${log_path}/${log_name}
    END
    [Return]    ${list_log_path_local}

Check item on crpt file for 11043
    [Arguments]    ${check_value}    ${check_item}    ${file_path}=${TS_CASE_LOG_PATH}/startup_cp_rt.log
	${output}    get_value_from_log_file    file_path=${file_path}    check_item=${check_item}
	Should Contain    ${output}    ${check_value}

Catch and check soap log
    [Arguments]  ${ru_index}=${1}
    Connect to gnb coam via ssl
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU
    ${PC_soap_path}    Download soap msg from RU
    Check soap log    PC_soap_path=${PC_soap_path}
    [Teardown]  run keywords  csn.disconnect   connection=RU    AND
    ...    csn.Disconnect   connection=ASIK Master

Check soap log
    [Arguments]   ${PC_soap_path}=${PC_soap_path}
    log to console  \n***check soap message ***
    Check soap log for grop1     PC_soap_path=${PC_soap_path}
    Check soap log for grop0     PC_soap_path=${PC_soap_path}

Check soap log for grop1
    [Arguments]   ${PC_soap_path}=${PC_soap_path}
    ${dl_persymbol}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=endpointCapacitySharingGroup0
    ...     parameter_name=maxUplaneSectionHeadersPerSymbol
    Should Be Equal    ${dl_persymbol}    18
    ${dl_perslot}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=endpointCapacitySharingGroup0
    ...     parameter_name=maxUplaneSectionHeadersPerSlot
    Should Be Equal    ${dl_perslot}    252
    ${upf_request}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelRxEndpoint0
    ...     parameter_name=userPlaneFragmentationRequested
    Should Be Equal    ${upf_request}    TRUE
    ${localaddr_RX0}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelRxEndpoint0
    ...     parameter_name=localAddress
    Should Be Equal    ${localaddr_RX0}    0
    ${groupnum_RX0}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelRxEndpoint0
    ...     parameter_name=capacitySharingGroups
    ${array_RX0}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelRxEndpoint0
    ...     parameter_name=rxArray
    Should Be Equal    ${array_RX0}    rxArray1
    ${upf_request}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelRxEndpoint1
    ...     parameter_name=userPlaneFragmentationRequested
    Should Be Equal    ${upf_request}    TRUE
    ${localaddr_RX1}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelRxEndpoint1
    ...     parameter_name=localAddress
    Should Be Equal    ${localaddr_RX1}    128
    ${groupnum_RX1}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelRxEndpoint1
    ...     parameter_name=capacitySharingGroups
    Should Be Equal    ${groupnum_RX0}    endpointCapacitySharingGroup1
    ${array_RX1}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelRxEndpoint1
    ...     parameter_name=rxArray
    Should Be Equal    ${array_RX1}    rxArray2

Check soap log for grop0
    [Arguments]   ${PC_soap_path}=${PC_soap_path}
    ${dl_persymbol}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=endpointCapacitySharingGroup1
    ...     parameter_name=maxUplaneSectionHeadersPerSymbol
    Should Be Equal    ${dl_persymbol}    26
    ${dl_perslot}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=endpointCapacitySharingGroup1
    ...     parameter_name=maxUplaneSectionHeadersPerSlot
    Should Be Equal    ${dl_perslot}    78
    ${upf_request}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint0
    ...     parameter_name=userPlaneFragmentationRequested
    Should Be Equal    ${upf_request}    TRUE
    ${localaddr_TX0}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint0
    ...     parameter_name=localAddress
    Should Be Equal    ${localaddr_TX0}    0
    ${groupnum_TX0}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint0
    ...     parameter_name=capacitySharingGroups
    ${array_TX0}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint0
    ...     parameter_name=txArray
    Should Be Equal    ${array_TX0}    txArray1
    ${upf_request}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint1
    ...     parameter_name=userPlaneFragmentationRequested
    Should Be Equal    ${upf_request}    TRUE
    ${localaddr_TX1}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint1
    ...     parameter_name=localAddress
    Should Be Equal    ${localaddr_TX1}    129
    ${groupnum_TX1}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint1
    ...     parameter_name=capacitySharingGroups
    Should Be Equal    ${groupnum_TX1}    endpointCapacitySharingGroup0
    ${array_TX1}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint1
    ...     parameter_name=txArray
    Should Be Equal    ${array_TX1}    txArray2
    ${upf_request}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint2
    ...     parameter_name=userPlaneFragmentationRequested
    Should Be Equal    ${upf_request}    TRUE
    ${localaddr_TX2}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint2
    ...     parameter_name=localAddress
    Should Be Equal    ${localaddr_TX2}    1
    ${groupnum_TX2}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint2
    ...     parameter_name=capacitySharingGroups
    ${array_TX2}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint2
    ...     parameter_name=txArray
    Should Be Equal    ${array_TX2}    txArray1
    ${upf_request}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint3
    ...     parameter_name=userPlaneFragmentationRequested
    Should Be Equal    ${upf_request}    TRUE
    ${localaddr_TX3}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint3
    ...     parameter_name=localAddress
    Should Be Equal    ${localaddr_TX3}    128
    ${groupnum_TX3}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint3
    ...     parameter_name=capacitySharingGroups
    Should Be Equal    ${groupnum_TX3}    endpointCapacitySharingGroup0
    ${array_TX3}    soap.get_soap_msg_par_value_change_ind    log_path=${PC_soap_path}    distName_value=lowLevelTxEndpoint3
    ...     parameter_name=txArray
    Should Be Equal    ${array_TX3}    txArray2
