*** Settings ***
Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown
Resource    resources/common_7608.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library    taf.collectors.core    WITH NAME    core
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    OperatingSystem

Documentation
...    author: yu.2.zhang
...    squad group: SG_07
...    feature : 5GC007608
...    contact: yu.2.zhang@nokia-sbell.com

*** Variables ***
${interface}    nac_eth2
${display_filter}    _5g_l1_ul_l2_ps_uldata_prachreceivereq_t
${uciBits_field_name0}    _3gpp.sfn
${uciBits_field_name1}     _3gpp.slot
${175}    9    19    29    39    49    59    69    79
${177}    2    19    39    59    79
${178}    9    19    29    39    49    59    69    79
${182}    9    19    29    39    49    59    69    79
${185}    39    79
${187}    49    59    69    79
${196}    9    19    29    39    49    59    69    79
${175_mod}    81
${177_mod}    81
${178_mod}    41
${182_mod}    21
${185_mod}    10
${187_mod}    10
${196_mod}    10
${logs_path}     /home/ute/zy2
${bip_log_path}    /home/ute/zy2/l1l2bip/
             
@{NR_PHY_CELL_IDS}    93

*** Test Cases ***
[1]5GC001300_AC_59_Call setup with frame structure 1127 prach config index 175
    [Tags]    CRT
    [Documentation]
    ...   author: yu.2.zhang@nokia-sbell.com
    ...   squad group: SG_07
    ...   Feature 5GC007608
    [Setup]    robot_common_operations.Common Case Setup
    Get Cell ID
    Modify prachConfigIndex for 175
    Get UE Type
    L3 call ULDL and check bip
    [Teardown]    Case Teardown

*** Keywords ***
Modify prachConfigIndex for 175
    Selenium Login And Disable Screen Lock    download_dir=${None}
    selenium_coam.set_parameter_value    dist_name=MRBTS-334/NRBTS-1/NRCELL-1
    ...    filter_param=PRACH configuration index     new_value=175
    Validate Plan
    Activate Plan
    wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI
    [Teardown]    Selenium Logout And Close Browser

L3 call ULDL and check bip
    [Arguments]    ${ue_index}=0    ${power_reset}=False
    ...    ${dl_tp}=1000MKbits/sec     ${apn_address}=dxdata1    ${duration}=900
    ...    ${ul_tp}=100MKbits/sec    ${ul_target}=50    ${dl_target}=60
    ...    ${avg_percent}=0.1    ${min_percent}=0.1    ${iperf_type}=via_command
    Get Ue Type    ue_index=${ue_index}
    Prepare UE 7608    ue_index=${ue_index}    power_reset=${power_reset}
    UE Attach 7608    ue_index=${ue_index}    power_reset=${power_reset}
    Start DL Traffic 7608    ue_index=${ue_index}    dl_tp=${dl_tp}
    ...    apn_address=${apn_address}    duration=${duration}
    Start UL Traffic 7608    ue_index=${ue_index}    ul_tp=${ul_tp}    apn_address=${apn_address}
    ...    duration=${duration}    iperf_type=${iperf_type}    
    Log to console    'start to bip'
	Run Keyword And Ignore Error    Delete log        log_file=${bip_log_path}${/}*
	Collect Bip Log    ${logs_path}
    Log to console    'start fiter bip'
	${filter_result}    Get ucibits from bip    bip_file=${bip_log_path}/${bip_log_path1}
    Get and check field values    mod=${175_mod}    list_num=${175}
	
    [Teardown]    Run Keyword And Ignore Error    Stop L3Call    ue_index=${ue_index}
    ...    apn_address=${apn_address}    power_reset=${power_reset}


Get ucibits from bip
    [Arguments]    ${bip_file}
    ${Parser}    cap.setup    infile=${bip_file}    display_filter=${display_filter}
    ...    tshark_path=${tshark_path}    alias="Parser"
    [Return]    ${Parser}

Get and check field values
    [Arguments]    ${mod}    ${list_num}
    ${list0}    get_field_value_by_name    field_name=${uciBits_field_name0}
    ...    attribute_name=value    pcap_parser="Parser"
    log    ${mod[0]}
    log    ${mod[1]}
    ${num}    Convert To Integer    ${mod[0]}
    ${num1}    Convert To Integer    ${mod[1]}
    log    ${num}
    log    ${num1}
    FOR    ${value}    IN    @{list0}
        ${tmp}    Convert To Integer    ${value}    16
            ${A}    SFN_num    ${tmp}    ${num}
        ${B}    SFN_X    ${tmp}    ${num}
        Exit For Loop If    ${B}==${num1}
    END
    ${s}=    Get Index From List    ${list0}    ${value}
    log    ${s}
    ${x}=    Convert To Integer    ${s}
    ${list1}    get_field_value_by_name    field_name=${uciBits_field_name1}
    ...    attribute_name=value    pcap_parser="Parser"
    ${slot}=    Convert To Integer    ${list1[${x}]}
    ${result2}    check_list    ${slot}    ${list_num}
    Log to console    ${result2}
    Should be True    ${result2}

Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

Collect Bip Log
    [Arguments]       ${logs_path}
    Start to collect bip log new    ${nr_phy_cell_ids}
	Sleep  3  reason=Wait for log collection
    Stop to collect bip log new     target_dir=${logs_path}
	${bip_log_path1}     Get BIP Filelist    log_path=${bip_log_path}
    set suite variable    ${bip_log_path1}
    
Get BIP Filelist
    [Arguments]    ${log_path}   ${connection}=UTE_CON      ${bip_prefix1}=BTS334_2011_mirroring_L2L1_   ${mergecap_wait}=120s
    csn.connect to
    ...               hostname=${tl.test_pc.default_ssh_connection_details.addr}
	#...               hostname=10.101.60.61
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=UTE_CON
    @{list_log_names}     ssh_common_commands.get_file_names_under_directory    directory=${log_path}    connection=${connection}
    ...    file_indicator=${bip_prefix1}*
	Run Keyword And Ignore Error    Log to console   ${list_log_names}[0]
    [Return]    ${list_log_names}[0]
	
Start to collect bip log new
    [Arguments]    ${nr_phy_cell_ids}   ${host}=10.108.135.76   ${username}=Nemuadmin  ${password}=nemuuser  ${port}=443
    ${webservice}=  Create Dictionary
    ...  host=${host}
    ...  user=${username}
    ...  password=${password}
    ...  port=${port}
    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=l1l2bip
    ...  webservice=${webservice}
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    ...  timeout=1500
    core.setup_collectors    names=l1l2bip
    core.start_collectors    names=l1l2bip
    core.Set Suite Alias     l1l2bip

Stop to collect bip log new
    [Arguments]    ${target_dir}
    core.stop_collectors    names=l1l2bip
    core.collect_collectors    names=l1l2bip       target_dir=${target_dir}
    core.teardown_collectors    names=l1l2bip

Delete log
    [Documentation]    Author: Deng xueqin
    ...                Description: Delete the download log
    [Arguments]    ${log_file}
    Run Keyword And Ignore Error    run    command=rm -rf ${log_file}
