*** Settings ***
Documentation     author: meiya.cheng
...               contact: meiya.cheng@nokia-sbell.com
...               squad group: SG_07

Force Tags        SBTS22R1
...    PY36
Library         OperatingSystem
Library         Process
Library         Collections
Library         String
Library         DateTime

Library    taf.collectors.core    WITH NAME    core
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
#Library    testsuite/Hangzhou/AIC/RAN_PZ_HAZ_1/Resources/python/basic.py    
Library    OperatingSystem
Resource     ../../../resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource      ./resources/common_1732.robot

Resource        ./resources/common_7608.robot
Resource        ../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource        ../../../resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource        ../../../resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

*** Variables ***
${du_scf_name}    /home/ute/CB007608/2CC_TL334_1937_2015.xml
${tshark_path}    /usr/bin/tshark

${dlmrs_filter}    DlData_PdschGrant.dlDmrsAddPos
${dlmrs_name0}     DlData_PdschGrant.dlDmrsAddPos
${dlmrs_name1}    DlData_PdschGrant.dlDmrsTypeAPos
${ultp}     0
${dltp}     0
${ultp2}     0
${dltp2}     0
${host_addr}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${ue_index}     0
${power_reset}      False
${logs_path}    /home/ute/cmylog
${bip_log_path}    /home/ute/cmylog/l1l2bip/
@{NR_PHY_CELL_IDS}    93
${CU_username}     toor4nsn
${CU_password}    oZPS0POrRieRtu
${file_path}     /home/ute/CB007608/
${DU_PATH}       /usr/bin/

*** Test Cases ***
#[1]5GC002015_CD_11_5GC002015_CD_TC_11_2CC_eCpri_DL_Traffic_2_2_Mimo_dmrsTypeAPositionPos2_PtrsOn
[1][1.0] 5GC002015_CD_Testcase_11_2CC_eCpri_DL_Traffic_2_2_Mimo_dmrsTypeAPositionPos2_PtrsOn
    [Documentation]  The purpose of this test case is to verify that there's an increase in DL throughput
    ...              at higher MCS when PDSCH_DMRS_FDM
    [Tags]          SBTS22R1
    #[Setup]    SISO Coam Test Setup   
	Cases common Setup
    
	Commissioning 2CC scf
    Log to console    'actDlDataDmrsFdm true'
    Du login page via webUI
    Get Filter actDlDataDmrsFdm
    Run Keyword If    '${actDlDataDmrsFdm_value}'!='true'
    ...    Restore actDlDataDmrsFdm in webui
	Get Filter actDlDataDmrsFdm_2
	Run Keyword If    '${actDlDataDmrsFdm_value2}'!='true'
    ...    Restore actDlDataDmrsFdm in webui
    DU COAM selenium logout
	
	Get Ue Type    ue_index=${ue_index}
    Prepare UE 7608    ue_index=${ue_index}    power_reset=${power_reset}
	
	L3 call ULDL and check throughput
    Set Test Variable    ${all_tp}    ${all_tp}	
    Log to console    ${all_tp}[1][0][peak]
    Set Suite Variable    ${aa}    ${${all_tp}[1][0][peak]}
    
	sleep    18s
	Log to console    'start to change config'
    Du login page via webUI
    Modify actDlDataDmrsFdm to false in webui
    Run Keyword And Ignore Error    DU COAM selenium logout
	#Connect to gnb coam via ssl
   # Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
   # Run Keyword And Ignore Error    COAM Teardown gnb connections
    L3 call ULDL and check throughput
    Set Test Variable    ${all_tp}    ${all_tp}
    Log to console    ${all_tp}[1][0][peak]
    Set Suite Variable    ${bb}    ${${all_tp}[1][0][peak]}
    should be true    ${aa}>${bb}
    [Teardown]    run keywords    selenium logout and close browser


*** Keywords ***
	
L3 call ULDL and check throughput
    [Arguments]    ${ue_index}=0    ${power_reset}=False
    ...    ${dl_tp}=1000MKbits/sec     ${apn_address}=dxdata1    ${duration}=300
    ...    ${ul_tp}=100MKbits/sec    ${ul_target}=0    ${dl_target}=0
    ...    ${avg_percent}=0.01    ${min_percent}=0.1    ${iperf_type}=via_command

    UE Attach 7608    ue_index=${ue_index}    power_reset=${power_reset}
    Log to console    'start traffic'
    Start DL Traffic 7608    ue_index=${ue_index}    dl_tp=${dl_tp}
    ...    apn_address=${apn_address}    duration=${duration}
	Log to console    'start to bip'
	Collect Bip Log    ${logs_path}
    Start UL Traffic 7608    ue_index=${ue_index}    ul_tp=${ul_tp}    apn_address=${apn_address}
    ...    duration=${duration}    iperf_type=${iperf_type}    
    Check Tput 7608    ul_target=${ul_target}    dl_target=${dl_target}
    ...    avg_percent=${avg_percent}    min_percent=${min_percent}
   
	Log to console    'start fiter bip'
	${filter_result}    Get dlmrs from bip    bip_file=${bip_log_path}/${bip_log_path1}
    Get and check field values    filtered_packets=${filter_result}
	Run Keyword And Ignore Error    Delete log        log_file=${bip_log_path}${/}*
    [Teardown]    Run Keyword And Ignore Error    Stop L3Call    ue_index=${ue_index}
    ...    apn_address=${apn_address}    power_reset=${power_reset}


	
Collect Bip Log
    [Arguments]       ${logs_path}
    Start to collect bip log new    ${nr_phy_cell_ids}
	Log to console    'catch logs'
	Sleep  30  reason=Wait for log collection
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

Commissioning 2CC scf
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${du_scf_name}
    ...                              timeout=${600}    is_pdl_checking_needed=${False}
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
    Run Keyword And Ignore Error    COAM Teardown gnb connections
	
Get dlmrs from bip
    [Arguments]    ${bip_file}
    ${Parser}    cap.setup    infile=${bip_file}    display_filter=${dlmrs_filter}       
    ...    tshark_path=${tshark_path}    alias="Parser"
    [Return]    ${Parser}
 

Get and check field values
    [Arguments]    ${filtered_packets}
    ${dlmrsvalue_0}    get_field_value_by_name    field_name=${dlmrs_name0}    attribute_name=value    pcap_parser="Parser"
	sleep  3 sec
    Should Be Equal    ${dlmrsvalue_0[1]}    01
    ${dlmrsvalue_1}    get_field_value_by_name    field_name=${dlmrs_name1}    attribute_name=value    pcap_parser="Parser"
	sleep  3 sec
    Should Be Equal    ${dlmrsvalue_1[1]}    02
 
Get Filter actDlDataDmrsFdm
    [Documentation]  Author: meiya.cheng
    ...              Description: get actDlDataDmrsFdm value
    ${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    ${actDlDataDmrsFdm_value}    selenium_coam.get_parameter_value
    ...   dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
    ...   abbr=actDlDataDmrsFdm
    ...   filter_param=Activate downlink data and DMRS FDM
    set suite variable    ${actDlDataDmrsFdm_value}

Get Filter actDlDataDmrsFdm_2
    [Documentation]  Author: meiya.cheng
    ...              Description: get actDlDataDmrsFdm value
    ${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    ${actDlDataDmrsFdm_value2}    selenium_coam.get_parameter_value
    ...   dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-2
    ...   abbr=actDlDataDmrsFdm
    ...   filter_param=Activate downlink data and DMRS FDM
    set suite variable    ${actDlDataDmrsFdm_value2}
 
Restore actDlDataDmrsFdm in webui
    [Documentation]  Author:meiya.cheng
    ...              Description: restore actDlDataDmrsFdm value
    ${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
    ...    abbr=actDlDataDmrsFdm
    ...    new_value=true
    ...    filter_param=Activate downlink data and DMRS FDM
    sleep    1s
	selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-2
    ...    abbr=actDlDataDmrsFdm
    ...    new_value=true
    ...    filter_param=Activate downlink data and DMRS FDM
    sleep    1s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
	sleep    18s

Modify actDlDataDmrsFdm to false in webui
    [Documentation]  Author: meiya.cheng
    ...              Description: modify actDlDataDmrsFdm value
    ${MRBTS_ID}=    Get MRBTS Id in COAM WebEM
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-1
    ...    abbr=actDlDataDmrsFdm
    ...    new_value=false
    ...    filter_param=Activate downlink data and DMRS FDM
    sleep    1s
    selenium_coam.set_parameter_value
    ...    dist_name=${MRBTS_ID}/NRBTS-1/NRCELL-2
    ...    abbr=actDlDataDmrsFdm
    ...    new_value=false
    ...    filter_param=Activate downlink data and DMRS FDM
    sleep    2s
    selenium_coam.validate_plan
    sleep    8s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    18s

Mcshark preparation for bip analysis CB007608_2015
    Get current sw build version
    ${wget_cmd}=    Set Variable
    ...    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_build_version}/
    Run    cd ${logs_path};${wget_cmd}
    ${MCShark}=    Run    ls ${logs_path}/artifactory/mcshark-local/${sw_build_version}/mcshark-3.6-*buster.so
    Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan/mcshark-*buster.so
    Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.6/epan/

Get current sw build version
    coam.connect to    bts_host=${host_addr}
    ${sw_info}=      coam.get_sw_version     connection=default
    ${sw_list}=    Split String    string=${sw_info}    separator=_
    ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==9999
    ${sw_build_version}=    Run Keyword If    '${status}'=='True'
    ...    set variable    SBTS00_${sw_list[1]}_${sw_list[2]}_${sw_list[3]}_${sw_list[4]}
    ...    ELSE    set variable    ${sw_info}
    Set Suite Variable    ${sw_build_version}
    [Teardown]    coam.teardown    connection=default
 
Cases common Setup
    [Documentation]    Author: meiya.cheng
    ...                Description: case common setup
    #robot_common_operations.Common Case Setup
    Create Directory    log_path=${logs_path}
    sleep    1s
    #Mcshark preparation for bip analysis CB007608_2015
	#prepare mirror script for BIP collection
	Run Keyword And Ignore Error    Delete log        log_file=${bip_log_path}${/}*
 
Cases Common teardown
    [Documentation]    Author: meiya.cheng
    ...                Description: case common teardown
    #robot_common_operations.Common Case Teardown
    sleep    1s
	Run Keyword And Ignore Error    Csn.Disconnect    connection=ASIK Master

prepare mirror script for BIP collection
    ${scp_command}=    Set Variable    sshpass -p ${CU_password} scp ${file_path}/lfs-nw_switch-mirror-tool.sh ${CU_username}@${host_addr}:${DU_PATH}
    Run    ${scp_command}
    Connect to ASIL
    ${status}=    csn.Execute    command=chmod 777 /usr/bin/lfs-nw_switch-mirror-tool.sh   connection=ASIL
    Run Keyword And Ignore Error    csn.Disconnect    connection=ASIL

Connect to ASIL
    [Arguments]    ${connection}=ASIL     
    csn.connect to
    ...               hostname=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...               username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...               password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...               alias=ASIL
