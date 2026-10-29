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
...    squad group: PZ3_SG2
...    feature : 5GC007608
...    contact: yu.2.zhang@nokia-sbell.com

*** Variables ***
${local_path}       /home/ute
${logs_path}     /home/ute/zy2
${bip_log_path}    /home/ute/zy2/l1l2bip/
@{NR_PHY_CELL_IDS}    93
${ultp}    4
${dltp}    4
${interface}    nac_eth2
${display_filter}    DlData_SsBlockSendReq_t.patternId_item
${uciBits_field_name0}    _3gpp.sfn
${uciBits_field_name1}    _3gpp.slot
${uciBits_field_name2}    DlData_SsBlockSendReq_t.patternId_item
${uciBits_field_name3}    DlData_SsBlockSendReq_t.patternId_item

@{beamSet32A_pattenId}    280029002a002b00
    ...                   2c002d002e002f00
    ...                   3000310032000b00
    ...                   0c000d000e000f00
    ...                   1000110012001300
    ...                   14001a001b001c00
    ...                   1d001e001f002000
    ...                   2100220023002400

@{beamSetAbfFR2_8_8_8_8_1P_pattenId}    8d008e008f009000
    ...                                 9100920093009400
    ...                                 9500960097009800
    ...                                 99009a009b009c00
    ...                                 9d009e009f00a000
    ...                                 a100a200a300a400
    ...                                 b500b600b700b800
    ...                                 b900ba00bb00bc00

*** Test Cases ***
[1]5GC000918_A_23_Call setup UL_DL traffic with beamset 32B_with_LA
    [Tags]    CRT
    [Documentation]
    ...    author: yu.2.zhang@nokia-sbell.com
    ...    squad group: SG_07
    ...    Feature 5GC007608
    ...    This case is to test cell setup successfully in beamSetAbf_32B
    [Setup]    robot_common_operations.Common Case Setup
    Modify Basic Beam Set32B
    #${bip_log_path_1}    TL334 Capture BIP log and download    interface=${interface}
	Collect Bip Log    ${logs_path}
    sleep  10 sec
    Get ucibits from bip    bip_file=${bip_log_path}/${bip_log_path1}
    Get and check field values    ${beamSet32A_pattenId}
    Make L3Call and Check TP
    [Teardown]    Case Teardown

*** Keywords ***
Modify Basic Beam Set32B
    Selenium Login And Disable Screen Lock    download_dir=${None}
    selenium_coam.set_parameter_value    dist_name=MRBTS-334/NRBTS-1/NRCELL-1
    ...    filter_param=Basic Beam Set     new_value=beamSetAbf_32B
    selenium_coam.set_parameter_value    dist_name=MRBTS-334/NRBTS-1/NRCELL-1
    ...    filter_param=Left Cell Edge Angle    new_value=40
    selenium_coam.set_parameter_value    dist_name=MRBTS-334/NRBTS-1/NRCELL-1
    ...    filter_param=Right Cell Edge Angle    new_value=40
    selenium_coam.set_parameter_value    dist_name=MRBTS-334/NRBTS-1/NRCELL-1
    ...    filter_param=Upper Cell Edge Angle    new_value=72
    selenium_coam.set_parameter_value    dist_name=MRBTS-334/NRBTS-1/NRCELL-1
    ...    filter_param=Lower Cell Edge Angle    new_value=108
    Validate Plan
    Activate Plan
    wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI
    [Teardown]    Selenium Logout And Close Browser

Get and check field values
    [Arguments]    ${beamset_id}
    ${list0}    get_element_value    element_expression=DlData_SsBlockSendReq_t.patternId_item
    ...    element_idx=0    pcap_parser="Parser"
    ${list1}    get_element_value    element_expression=DlData_SsBlockSendReq_t.patternId_item
    ...    element_idx=1    pcap_parser="Parser"
    ${list2}    get_element_value    element_expression=DlData_SsBlockSendReq_t.patternId_item
    ...    element_idx=2    pcap_parser="Parser"
    ${list3}    get_element_value    element_expression=DlData_SsBlockSendReq_t.patternId_item
    ...    element_idx=3    pcap_parser="Parser"
    ${result}    check_patternId    ${beamset_id}    ${list0}    ${list1}    ${list2}    ${list3}
    Log to console    ${result}
    Should be True    ${result}

Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
	Run Keyword And Ignore Error    Delete log        log_file=${bip_log_path}${/}*

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
