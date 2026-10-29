*** Settings ***
Documentation     author: Chen Yin
...               contact: yin.1.chen@nokia-sbell.com
...               squad group: SG_02
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.collectors.snapshot     WITH NAME     snapshot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/1347_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Library           taf.ul.parser.pcap        WITH NAME    pcap
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/data_analysis.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${ignore_system_message}      dldata_pdcchsendreq&&3gpp.rnti!=65535

*** Keywords ***
Download and update BSR package
    [Arguments]    ${file_path}
    @{files}    List Files In Directory    ${file_path}
    ${list_length}      Get Length      ${files}
    ${random_number}=    Evaluate    random.randint(0, ${list_length}-1)    random
    Set Suite Variable      ${file_name}      ${files}[${random_number}]
    ${full_file_path}      Catenate      SEPARATOR=      ${file_path}      ${file_name}
    Set Suite Variable      ${full_file_path}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    selenium_coam.load_software_package_from_local_drive    file_path=${full_file_path}
    sleep    15s
    selenium_coam.software_update    is_activate=${True}
    sleep    15s
    [Teardown]    Run Keyword And Continue On Failure    COAM selenium close browser

Check installed BSR in beam set realization software
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
	selenium_coam.enable_virtual_display
    ${beam_set_realization_software}    selenium_coam.get_beam_set_realization_software_info    timeout=${120}
    ${actCustomBsr}    selenium_coam.get_parameter_value    dist_name=${MR_NR_BTS_NAME}
    ...    filter_param=Activate custom beam set realization    abbr=actCustomBsr    timeout=${120}
    ${BSR_Status}    set variable if
    ...          '${actCustomBsr}'=='false'    Not in use
    ...          '${actCustomBsr}'=='true'    In use
    ${BSR_Used_by}    set variable if
    ...          '${actCustomBsr}'=='false'    -
    ...          '${actCustomBsr}'=='true'      AEHC-2
    Should Be Equal    ${beam_set_realization_software[0]['Status']}    ${BSR_Status}
    Should Be Equal    ${beam_set_realization_software[0]['Used by']}    ${BSR_Used_by}
    Should Be Equal    ${beam_set_realization_software[0]['BSR package']}    ${beam_set_file_name}
    [Teardown]    Run Keyword and ignore error    Run keywords    COAM selenium close browser    AND    selenium_coam.disable_message_box

Get beam set realization file name
    [Arguments]    ${file_path}=${file_path}
    ${list}      split string      ${file_path}      /
    ${Beam_set_realization}      set variable      ${list}[-1]
    ${Beam_set_realization}      split string       ${Beam_set_realization}      .
    Set Global Variable      ${beam_set_file_name}      ${Beam_set_realization}[0]

Check installed BSR in configuration management Parameter
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${beamSetInstall}    selenium_coam.get_parameter_value    dist_name=${MR_NR_BTS_NAME}
    ...  filter_param=Beam set installed    node_index=${0}
    Should Be Equal    ${beamSetInstall}    ${beam_set_file_name}
    [Teardown]    Run Keyword And Continue On Failure    COAM selenium close browser

Check installed BSR in command
    Connect to Common Unit Master
    ${output}    csn.execute    command=ls -l /ffs/run/config/beamforming    connection=ASIK Master
    ${new_file_name}=      Catenate      SEPARATOR=      ${beam_set_file_name}      .
    should contain x times    ${output}    ${new_file_name}    6
    [Teardown]    Run Keyword And Continue On Failure    csn.disconnect    connection=ASIK Master

Activate 1866 in gNB
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    set to dictionary      ${Enable_feature_1866}[4]    new_value      ${beam_set_file_name}
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${Enable_feature_1866}    download_dir=${TS_CASE_LOG_PATH}

deActivate 1866 in gNB
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${Disable_feature_1866}    download_dir=${TS_CASE_LOG_PATH}

Start traffic and catpture bip
    [Arguments]       ${throutput}=150M           ${4G_check_needed}=False
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    Set test variable    ${ue_type}
    power_ue.Prepare UE      ue_type=${ue_type}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    Wait Until Keyword Succeeds    5 min    30 sec    power_ue.Verify attach
    ...    ue_type=${ue_type}      4G_check=${4G_check_needed}     5Grach_ed=${5Grach_ed}
    power_ue.Start traffic
    ...      ue_type=${ue_type}     direction=ul     throughput=${throutput}     duration=1200     iperf_port=${ul_port}
    power_ue.Start traffic
    ...      ue_type=${ue_type}     direction=dl     throughput=${throutput}     duration=1200     iperf_port=${ul_port}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${date}    Evaluate    datetime.datetime.now().strftime('%Y%m%d%H%M%S')    datetime
    Start Bip Log with Suitable Means      target_file_name=l1l2bip_log_${date}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul    iperf_port=${ul_port}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl    iperf_port=${dl_port}
    power_ue.UE Detach     ue_type=${ue_type}
    ${log_path_local}    Run Keyword And Ignore Error    Stop Bip Log with Suitable Means
    ...    target_file_name=l1l2bip_log_${date}
    [Return]    ${log_path_local}

Delete installed BSR in beam set realization software
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${beam_set_realization_software}    selenium_coam.get_beam_set_realization_software_info
    @{bsr_package_list}=    Create List    ${beam_set_file_name}
    selenium_coam.delete_beam_set_realization_software_item    bsr_package_list=@{bsr_package_list}
    sleep    15s
    [Teardown]    Run Keyword And Continue On Failure    COAM selenium close browser

Check deleted BSR not in beam set realization software
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${beam_set_realization_software}    selenium_coam.get_beam_set_realization_software_info
    ${length}=      Get Length      ${beam_set_realization_software}
    Run keyword IF      ${length}!=0
    ...      should not contain   ${beam_set_realization_software[0]['BSR package']}    ${beam_set_file_name}
    [Teardown]    Run Keyword And Continue On Failure    COAM selenium close browser

Check deleted BSR not in command
    Connect to Common Unit Master
    ${output}    csn.execute    command=ls -l /ffs/run/config/beamforming    connection=ASIK Master
    should not contain    ${output}    ${beam_set_file_name}
    [Teardown]    Run Keyword And Continue On Failure    csn.disconnect    connection=ASIK Master

Setup enviornment with relevant configuration
    [Arguments]   ${scf_path}
    ...    ${cur_relative_dir}=testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002015/Resources
    ...    ${scf_relative_dir}=commissionings/HGZ
    robot_common_operations.Common Suite Setup
    Connect to gnb coam via ssl
    ${exist_fault}    COAM Get active alarms
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    Commissioning with Template Commission      scf_file=${scf_base_path}/${testline_name}/${scf_path}
