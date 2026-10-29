*** Settings ***
Documentation     author: Bijiajian
...               contact: Jiajian.bi@nokia-sbell.com
...               squad group: SG_02
Suite Setup       Common Suite Setup for COAM
Suite Teardown    Common Suite Teardown
Force Tags        5G_RRM    QCD_MN_RAN    QCP_RAN_ST
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/Resource_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          Resources/1347_common_keyword.robot
Variables         Resources/2537_variables.py
Resource          Resources/common_keyword_RRM_SG2.robot

*** Variables ***
${tmp_swconfig_dir}    /home/ute/Downloads/SCF/swconfig.txt
${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs

${scf_path}    /home/ute/Downloads/SCF

${tshark_path}    /usr/bin/tshark

@{check_print}    ERR/

*** Test Cases ***
[1]CB008322_D_21_Verify_2UEs_Comb4_UL_DL_BF_100M_2T4R_100M_32TRX
    [Tags]    CRT
    [Setup]    Case Setup
    Recover swconfig file
    AlarmWatchdog.add_allow_alarms    fault_id=61631
    AlarmWatchdog.add_allow_alarms    fault_id=16
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/CB008322.xml
    Download and Get item from xzfile
    Reboot cpe for test    ue_index=${1}
    Sleep    5min
    Single UE Attach And Send Traffic
    Check BIP Log
    [Teardown]    Case Teardown

[1]CB008322_G_08_Verify_enhancement_small_PRB_scheduling_32TRX
    [Tags]    CRT
    [Setup]    Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=16
    AlarmWatchdog.add_allow_alarms    fault_id=61631
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/CB008322.xml
    [Teardown]    Case Teardown

[1]CB008322_E_5_Verify_2UEs_IWK_cDRX_CLPC_100M_16_PRBs_32TRX
    [Tags]    CRT
    [Setup]    Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=16
    AlarmWatchdog.add_allow_alarms    fault_id=61631
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/CB008322.xml
    Reboot cpe for test    ue_index=${1}
    Reboot cpe for test    ue_index=${2}
    Sleep    5min
    Double UE Attach And Send Traffic
    Check BIP Log
    [Teardown]    Case Teardown

[1]CB008322_B_10_Verify_SingleUE_SRS_Periodicity_80_Subbandsize_8_Closedloop_2T4R_100M_32TRX_ConcurrentMode
    [Tags]    CRT
    [Setup]    Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=16
    AlarmWatchdog.add_allow_alarms    fault_id=61631
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/CB008322.xml
    [Teardown]    Case Teardown

*** Keywords ***
Common Suite Setup for COAM
    Connect to gnb coam via ssl
    robot_common_operations.Common Suite Setup
    check pdl after sw update    download_dir=/home/ute/Downloads

Common Suite Teardown
    robot_common_operations.Common Suite Teardown

Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    robot_common_operations.Common Case Setup
    Set Test Variable     ${version}     ${result}[0]

Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run keyword and ignore error    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

Download file From ASIK To TestPC
    [Arguments]   ${log_prefix}    ${path}    ${log_path}=${TS_CASE_LOG_PATH}   ${connection}=ASIK Master
    @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
    ...    file_indicator=${log_prefix}*
    should not be empty  ${list_log_names}    msg=No file found with log prefix ${log_prefix} under asik tmp folder
    @{list_log_path_local}    Create list
    FOR  ${log_name}  IN  @{list_log_names}
        Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
        ...   remote_path=${path}/${log_name}
        ...   local_path=${log_path}/${log_name}
        ...   connection=${connection}
        Append to list    ${list_log_path_local}    ${log_path}/${log_name}
    END
    [Return]    ${list_log_path_local}[0]

Download and Get item from xzfile
    Connect to Common Unit Master
    ${xz_file}    Download file From ASIK To TestPC    log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
    should not be empty    ${xz_file}
    Run    unxz -f ${xz_file}
    ${b}    ${d}    ${f}    ${h}    ${n}    ${p}    get_item_from_xzfile_8322    file_path=${TS_CASE_LOG_PATH}/startup_cp_rt.log
    Should Contain    ${b}    true
    Should Contain    ${d}    true
	Should Contain    ${f}    16
	Should Contain    ${h}    150
	Should Contain    ${n}    COMB_4
	#Should Contain    ${p}    2100

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Single UE Attach And Send Traffic
    [Arguments]    ${ul_tp}=150M    ${dl_tp}=1500M    ${duration}=600
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[2]
    log to console    \n***Prepare UE_1***
	${ue_type}    translate_power_ue_type_from_testline    ue_index=${1}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${1}     log_type=Iperf
	log to console    \n***begin to traffic***
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${duration}    ue_index=${1}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${duration}    ue_index=${1}
    ...    process_num=5
    Common Capture BIP log and download    duration=1s
    #&{tti_log_path}    Capture TTI log
    Run keyword and ignore error    Check DL UL Throughput On Site    cells=${cell1}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${1}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${1}

Double UE Attach And Send Traffic
    [Arguments]    ${ul_tp}=150M    ${dl_tp}=1500M    ${duration}=600
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[2]
    log to console    \n***Prepare UE_1***
	${ue_type}    translate_power_ue_type_from_testline    ue_index=${1}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${1}     log_type=Iperf
	log to console    \n***begin to traffic***
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${duration}    ue_index=${1}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${duration}    ue_index=${1}
    ...    process_num=5
    log to console    \n***Prepare UE_2***
	${ue_type}    translate_power_ue_type_from_testline    ue_index=${2}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${2}     log_type=Iperf
	log to console    \n***begin to traffic***
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${duration}    ue_index=${2}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${duration}    ue_index=${2}
    Common Capture BIP log and download    duration=1s
    #&{tti_log_path}    Capture TTI log
    Run keyword and ignore error    Check DL UL Throughput On Site    cells=${cell1}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${1}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${1}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${2}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${2}

Check DL UL Throughput On Site
    [Arguments]    ${cells}
    ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
    power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cells}    target_throughput=1000
    #power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cells}    target_throughput=100

Load BIP Log
    [Arguments]    ${bip_file}=${bip_log_path}     ${alias}=CB8322
    ${packets}    pcap.load_pcap_file   pcap_file=${bip_file}
	...                                 tshark_path=${tshark_path}
    ...                                 command_template={tshark_path} -r ${bip_file} -Y 'uldata_srsreceiverespbwvps' -T pdml
    ...                                 alias=${alias}
    [Return]   ${packets}

Check BIP Log
    Load BIP Log
    ${value1}    Get value from Bip Log    field_name=UlData_srsBwvReport_t.result    pcap_parser=CB8322
	${value2}    Get value from Bip Log    field_name=UlData_srsBwvReport_t.numBwvPerSubband    pcap_parser=CB8322
	${value3}    Get value from Bip Log    field_name=UlData_srsBwvReport_t.startPatternId    pcap_parser=CB8322
	${value4}    Get value from Bip Log    field_name=UlData_srsBwvReport_t.correlation_item    pcap_parser=CB8322
	${lenth}    get length    ${value1}
    FOR  ${len}  IN RANGE  ${lenth}
        should be true    ${value1}[${len}] == 0
		should be true    ${value2}[${len}] == 4
		should be true    ${value3}[${len}] > 2000
		should be true    ${value4}[${len}] > 0.9
    END
