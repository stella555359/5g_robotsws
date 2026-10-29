# *** Settings ***
# Documentation
# ...    author: meiya.cheng
# ...    contact: meiya.cheng@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_2_SG
# ...    feature : siso performance test
# Suite Setup       Test Suite Setup 
# Suite Teardown    Test Suite Teardown
# Force Tags        STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEUD_AEUB_ENB    SBTS00
# ...               RAN_5G    RAN_5G_TDD    PY39
# 
# #Suite Setup       SISO Coam Suite Setup
# #Suite Teardown    SISO Coam Suite Teardown
# 
# Library    OperatingSystem
# Library    taf.collectors.core    WITH NAME    core
# Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands
# Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
# Library    taf.collectors.tcpdump    WITH NAME    tcpdump
# Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/SiSo_Performance/Resources/common_keywords.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    ${base_path}/5G_Setup_And_Teardown.robot
# Resource    ${base_path}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# 
# *** Variables ***
# ${base_path}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G
# #${nrcell_r}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1
# ${host_addr}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${polarization0}     P_plus45_or_0
# ${load_level_flat0}    full
# ${polarization3}     P_both
# ${mimo_rank2}    2
# ${load_level_flat3}    medium
# ${polarizationR2}     P_both
# ${load_level_flatlow}    low
# ${num_of_ssb_beam_pattern_id}     ssb_32
# @{ssb_beam_pattern_id}      8     9    10    11    12    13    14    15    16    17    18
# ...                               19    20    21    22    23    24    25    26    27    
# ...                               28    29    30    31    32    33    34    35    36    37    38    39
# 
# ${test_model}    TM1_1_ETSI
# ${ru_mode}    NR_Only
# @{Beam_ID}          9
# ${power_backoff}    0
# ${polarization}     P_minus45_or_90
# ${p_max}     17
# ${mimo_rank}    1
# ${i2_codebook_4_antports}    0
# ${codebook_2_antports}    0
# ${i11_codebook_4_antports}    0
# ${i13_codebook_4_antports}    0
# ${phys_cell_id}    50
# ${load_type}    flatLoad
# ${load_level_flat}    busy
# ${timeout}    5
# ${DU_addr}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# ${WEBUI_USER}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBUI_PASSWORD}       ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${alias}             GNB_OAM
# ${log_dir}              /home/ute/temp
# ${tshark_path}    /usr/bin/tshark
# ${display_filter1} 	 dldata_pdcchsendreq
# ${num_symbol}     DlData_DciInfo.numOfSymbols
# ${start_symbol}    DlData_DciInfo.startSymbolNumber     
# ${start_cce}    DlData_DciInfo.startCce
# ${filter_rnti7}    ((dldata_pdschsendreq) && (3gpp.slot == 7)) 
# ${filter_rnti3}    ((dldata_pdschsendreq) && (3gpp.slot == 3))
# ${filter_rnti0}    ((dldata_pdschsendreq) && (3gpp.slot == 0))
# ${filter_startprb}     DlData_PdschGrant.startPrb
# ${filter_numprb}     DlData_PdschGrant.numOfPrb
# ${symbol}     DlData_PdschGrant.numOfPdschSymbols
# ${rank_value}     DlData_DciInfo.numOfLayers
# ${filter_rnti2}    ((dldata_pdschsendreq) && (3gpp.slot == 2))
# ${filter_slot0}    (dldata_ssblocksendreq) && (3gpp.slot == 0)
# ${filter_pattern0}     DlData_SsBlockSendReq_t.patternId_item
# ${filter_slot1}    (dldata_ssblocksendreq) && (3gpp.slot == 1)
# ${filter_slot2}    (dldata_ssblocksendreq) && (3gpp.slot == 2)
# ${filter_slot13}    (dldata_ssblocksendreq) && (3gpp.slot == 13)
# @{num_list}     1300    0100    2a00    0100    
# @{num_list2}     1300    0100
# @{num_list3}     2000    0200    2b00    0200
# @{num_list4}     2000    0200    1400    0200
# @{num_list5}     2000    0200
# @{num_list6}     0300    0000
# @{num_list7}     0300    3f00
# #${logs_path}    /home/ute/cmylog
# #${bip_log_path}    /home/ute/cmylog/l1l2bip/
# ${logs_path}    /home/ute/temp
# ${bip_log_path}    /home/ute/temp/l1l2bip/
# @{NR_PHY_CELL_IDS}    94
# ${if_commissioning}    false
# 
# *** Test Cases *** 
# [1][1.0] General_SiSo_Auto_DL_Test_Model_Verification
#     [Documentation]  The purpose of this Test Case is to automatically enter test mode and execute test models.
# 	[Tags]    CRT_UTE
# 	[Setup]    Cases common Setup
#     
#     Test Setup 
#     Log to console    '-----full-----'
#     Start Downlink load test    polarization=${polarization0}    load_level_flat=${load_level_flat0}    mimo_rank=${mimo_rank}
# 	Run Keyword And Ignore Error    Delete log        log_file=${bip_log_path}${/}*
# 	Collect Bip Log    ${logs_path}
# 	Log to console    '--check full log--'
#     ${filter_result}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${display_filter1}
#     Get and check field values common    filtered_packets=${filter_result}
# 	Log to console    'end 1'
#     ${filter_result2}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_rnti0}
#     Sleep    3s
#     fullGet and check field values_2    filtered_packets=${filter_result2} 
#     Log to console    'end 2'
# 	Sleep    3s	
#     ${filter_result2}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_rnti7}
#     fullGet and check field values_3    filtered_packets=${filter_result2}
# 	Log to console    'end 3'
#     Run Keyword And Ignore Error    Stop downlink Performance test
# 	Run Keyword And Ignore Error    Delete log        log_file=${bip_log_path}${/}*
# 
#     Log to console    '-----busy-----'
#     Start Downlink load test    polarization=${polarization}    load_level_flat=${load_level_flat}    mimo_rank=${mimo_rank} 
# 	Collect Bip Log    ${logs_path}
#     ${filter_result}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${display_filter1}
#     Get and check field values common    filtered_packets=${filter_result}
#     ${filter_result00}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_rnti0}
#     Run Keyword And Ignore Error    Get and check field values_2    filtered_packets=${filter_result00}  
#     ${filter_result3}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_rnti3}
#     Run Keyword And Ignore Error    Get and check field values_3    filtered_packets=${filter_result3}
#     ${filter_result7}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_rnti7}
#     Get and check field values_7    filtered_packets=${filter_result7}
#     Run Keyword And Ignore Error    Stop downlink Performance test 
# 	Run Keyword And Ignore Error    Delete log        log_file=${bip_log_path}${/}*
#     Log to console    '-----busylog check end-----'	
# 	
#     Log to console    '-----medium_rank1-----'
#     Start Downlink load test    polarization=${polarizationR2}    load_level_flat=${load_level_flat3}    mimo_rank=${mimo_rank} 
# 	Collect Bip Log    ${logs_path}
#     ${filter_result}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${display_filter1}
#     Get and check field values common    filtered_packets=${filter_result}
#     Get and check RANK values    filtered_packets=${filter_result}
#     ${filter_result2}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_rnti0}
#     rank1Get and check field values_2    filtered_packets=${filter_result2}  
#     ${filter_resultslot2}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_rnti2}
#     rank1Get and check field values_slot2    filtered_packets=${filter_resultslot2}
#     ${filter_result3}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_rnti3}
#     rank1Get and check field values_3    filtered_packets=${filter_result3}
#     ${filter_result7}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_rnti7}
#     rank1Get and check field values_7    filtered_packets=${filter_result7}
#     Run Keyword And Ignore Error    Stop downlink Performance test 
# 	Run Keyword And Ignore Error    Delete log        log_file=${bip_log_path}${/}*
# 
#     Log to console    '-----medium_rank2-----'
#     Start Downlink load test    polarization=${polarizationR2}    load_level_flat=${load_level_flat3}    mimo_rank=${mimo_rank2} 
# 	Collect Bip Log    ${logs_path}	
#     ${filter_result}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${display_filter1}
#     Get and check field values common    filtered_packets=${filter_result}
#     Get and check RANK2 values    filtered_packets=${filter_result}
#     ${filter_result2}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_rnti0}
#     rank2Get and check field values_2    filtered_packets=${filter_result2}  
#     ${filter_resultslot2}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_rnti2}
#     rank2Get and check field values_slot2    filtered_packets=${filter_resultslot2}
#     ${filter_result3}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_rnti3}
#     rank2Get and check field values_3    filtered_packets=${filter_result3}
#     ${filter_result7}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_rnti7}
#     rank2Get and check field values_7    filtered_packets=${filter_result7}
#     Run Keyword And Ignore Error    Stop downlink Performance test 
# 	Run Keyword And Ignore Error    Delete log        log_file=${bip_log_path}${/}*
# 	
#     Log to console    '-----low-----'
#     Start Downlink lowload test
# 	Collect Bip Log    ${logs_path}
#     ${filter_result0}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_slot0}
#     Get and check slottypereq_0    filtered_packets=${filter_result0}  
#     ${filter_result1}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_slot1}
#     Get and check slottypereq_1    filtered_packets=${filter_result1}  
#     ${filter_result2}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_slot2}
#     Get and check slottypereq_2    filtered_packets=${filter_result2}  
#     ${filter_result13}    Get dldatalogs from bip common    bip_file=${bip_log_path}/${bip_log_path1}    filter=${filter_slot13}
#     Get and check slottypereq_13    filtered_packets=${filter_result13}  
#     Run Keyword And Ignore Error    Stop downlink Performance test 
#     Run Keyword And Ignore Error    reboot to restore TL
# 	Run Keyword And Ignore Error    Delete log        log_file=${bip_log_path}${/}*
#     [Teardown]     robot_common_operations.Common Case Teardown
# 	
# *** Keywords ***
# Cases common Setup
#     [Documentation]    Author: meiya.cheng
#     ...                Description: case common setup
#     robot_common_operations.Common Case Setup
# 	Create Directory    log_path=${log_dir}
#     sleep    1s
#  
# Collect Bip Log
#     [Arguments]       ${logs_path}
#     Start to collect bip log new    ${nr_phy_cell_ids}
# 	Log to console    'catch logs'
# 	#Sleep  1  reason=Wait for log collection
#     Stop to collect bip log new     target_dir=${logs_path}
# 	${bip_log_path1}     Get BIP Filelist    log_path=${bip_log_path}
#     set suite variable    ${bip_log_path1}
#     
# Get BIP Filelist
#     #[Arguments]    ${log_path}   ${connection}=UTE_CON      ${bip_prefix1}=BTS334_2011_mirroring_L2L1   ${mergecap_wait}=120s
# 	[Arguments]    ${log_path}   ${connection}=UTE_CON      ${bip_prefix1}=BTS151_1011_mirroring_L2L1_   ${mergecap_wait}=120s
#     csn.connect to
#     ...               hostname=${tl.test_pc.default_ssh_connection_details.addr}
#     ...               username=${tl.test_pc.default_ssh_connection_details.username}
#     ...               password=${tl.test_pc.default_ssh_connection_details.password}
#     ...               alias=UTE_CON
#     @{list_log_names}     ssh_common_commands.get_file_names_under_directory    directory=${log_path}    connection=${connection}
#     ...    file_indicator=${bip_prefix1}*
# 	Run Keyword And Ignore Error    Log to console   @{list_log_names}[0]	
#     [Return]    @{list_log_names}[0]
# 	[Teardown]    csn.Disconnect	connection=${connection}
# 	
# 	
# 	
# Start to collect bip log new
#     #[Arguments]    ${nr_phy_cell_ids}   ${host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr} 
#     [Arguments]    ${nr_phy_cell_ids}   ${host}=${tl.gnbs[0].cu.oam_http_connection_details.addr}
#     ...             ${username}=Nemuadmin  ${password}=nemuuser  ${port}=443
#     ${webservice}=  Create Dictionary
#     ...  host=${host}
#     ...  user=${username}
#     ...  password=${password}
#     ...  port=${port}
#     l1l2bip.create_interface_mirroring_l1l2bip_collector
#     ...  name=l1l2bip
#     ...  webservice=${webservice}
#     ...  nr_phy_cell_ids=${nr_phy_cell_ids}
#     ...  timeout=150
#     core.setup_collectors    names=l1l2bip
#     core.start_collectors    names=l1l2bip
#     core.Set Suite Alias     l1l2bip
# 
# Stop to collect bip log new
#     [Arguments]    ${target_dir}
#     core.stop_collectors    names=l1l2bip
#     core.collect_collectors    names=l1l2bip       target_dir=${target_dir}
#     core.teardown_collectors    names=l1l2bip
# 		
# reboot to restore TL
#     Connect to gnb coam via ssl    
#     coam.reset_site    timeout=20min    connection=GNB_OAM    
#     Wait Until Keyword Succeeds    10min    20s    COAM Check GNB cell on air
#     Run Keyword And Ignore Error    COAM Teardown gnb connections
# 	
# Test Setup
#     Connect to gnb coam via ssl    
#     ${nrcell}    SBTS Get Managed Objects    class_name=NRCELL_R
#     Set Suite Variable   ${nrcell_r}   ${nrcell[0]['distName']}
#     Get cells info
#     sbts.reset_to_test_dedicated    connection=${alias}
#     Sleep     5m
#     [Teardown]     Run Keyword And Ignore Error    COAM Teardown gnb connections
# 	
# Get and check slottypereq_13
#     [Arguments]    ${filtered_packets}
#     ${list_pattern0}    get_field_value_by_name    field_name=${filter_pattern0} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${value0}    set variable    @{list_pattern0}[0]
#     should be equal as strings    ${value0}    2400
#     ${value1}    set variable    @{list_pattern0}[1]
#     should be equal as strings    ${value1}    2500
#     ${value2}    set variable    @{list_pattern0}[2]
#     should be equal as strings    ${value2}    2600
#     ${value3}    set variable    @{list_pattern0}[3]
#     should be equal as strings    ${value3}    2700
#     ${value4}    set variable    @{list_pattern0}[4]
#     should be equal as strings    ${value4}    2400
#     ${value5}    set variable    @{list_pattern0}[05]
#     should be equal as strings    ${value5}    2500
# 	
# Get and check slottypereq_0
#     [Arguments]    ${filtered_packets}
#     ${list_pattern0}    get_field_value_by_name    field_name=${filter_pattern0} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${value0}    set variable    @{list_pattern0}[0]
#     should be equal as strings    ${value0}    0800
#     ${value1}    set variable    @{list_pattern0}[1]
#     should be equal as strings    ${value1}    0900
#     ${value2}    set variable    @{list_pattern0}[2]
#     should be equal as strings    ${value2}    0a00
#     ${value3}    set variable    @{list_pattern0}[3]
#     should be equal as strings    ${value3}    0b00
#     ${value4}    set variable    @{list_pattern0}[4]
#     should be equal as strings    ${value4}    0800
#     ${value5}    set variable    @{list_pattern0}[05]
#     should be equal as strings    ${value5}    0900
# 	
# Get and check slottypereq_1
#     [Arguments]    ${filtered_packets}
#     ${list_pattern0}    get_field_value_by_name    field_name=${filter_pattern0} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${value0}    set variable    @{list_pattern0}[0]
#     should be equal as strings    ${value0}    0c00
#     ${value1}    set variable    @{list_pattern0}[1]
#     should be equal as strings    ${value1}    0d00
#     ${value2}    set variable    @{list_pattern0}[2]
#     should be equal as strings    ${value2}    0e00
#     ${value3}    set variable    @{list_pattern0}[3]
#     should be equal as strings    ${value3}    0f00
#     ${value4}    set variable    @{list_pattern0}[4]
#     should be equal as strings    ${value4}    0c00
#     ${value5}    set variable    @{list_pattern0}[05]
#     should be equal as strings    ${value5}    0d00
# 
# Get and check slottypereq_2
#     [Arguments]    ${filtered_packets}
#     ${list_pattern0}    get_field_value_by_name    field_name=${filter_pattern0} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${value0}    set variable    @{list_pattern0}[0]
#     should be equal as strings    ${value0}    1000
#     ${value1}    set variable    @{list_pattern0}[1]
#     should be equal as strings    ${value1}    1100
#     ${value2}    set variable    @{list_pattern0}[2]
#     should be equal as strings    ${value2}    1200
#     ${value3}    set variable    @{list_pattern0}[3]
#     should be equal as strings    ${value3}    1300
#     ${value4}    set variable    @{list_pattern0}[4]
#     should be equal as strings    ${value4}    1000
#     ${value5}    set variable    @{list_pattern0}[05]
#     should be equal as strings    ${value5}    1100
# 	
# rank2Get and check field values_2
#     [Arguments]    ${filtered_packets}
#     ${list_symbol0}    get_field_value_by_name    field_name=${symbol}
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstsym}    set variable    @{list_symbol0}[0]
#     should be equal as strings    ${lstsym}    0e
#     ${lstsym1}    set variable    @{list_symbol0}[1]
#     Should Be Equal as strings    ${lstsym1}    0c
#     ${list_prb0}    get_field_value_by_name    field_name=${filter_startprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstprb0}    set variable    @{list_prb0}[0]
#     Should Be Equal As Integers    ${lstprb0}    0300
#     ${lstprb1}    set variable    @{list_prb0}[1]
#     Should Be Equal As Integers    ${lstprb1}    0000
#     ${list_num0}    get_field_value_by_name    field_name=${filter_numprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstnum}    set variable    @{list_num0}[0]
# 	should be true    '${lstnum}' in ${num_list}
#     #should be equal as strings    ${lstnum}    2a00
#     ${lstnum1}    set variable    @{list_num0}[1]
#     #Should Be Equal As Integers    ${lstnum1}    0100
# 	should be true    '${lstnum1}' in ${num_list}
#     ${lstnum2}    set variable    @{list_num0}[2]
# 	should be true    '${lstnum2}' in ${num_list}
#     #should be equal as strings    ${lstnum}    1300
#     ${lstnum3}    set variable    @{list_num0}[3]
#     #Should Be Equal As Integers    ${lstnum1}    0100
# 	should be true    '${lstnum3}' in ${num_list}
# 
# rank2Get and check field values_slot2
#     [Arguments]    ${filtered_packets}
#     ${list_symbol0}    get_field_value_by_name    field_name=${symbol}
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstsym}    set variable    @{list_symbol0}[0]
#     should be equal as strings    ${lstsym}    0e
#     ${lstsym1}    set variable    @{list_symbol0}[1]
#     Should Be Equal as strings    ${lstsym1}    0c
#     ${list_prb0}    get_field_value_by_name    field_name=${filter_startprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstprb0}    set variable    @{list_prb0}[0]
#     Should Be Equal As Integers    ${lstprb0}    0300
#     ${lstprb1}    set variable    @{list_prb0}[1]
#     Should Be Equal As Integers    ${lstprb1}    0000
#     ${list_num0}    get_field_value_by_name    field_name=${filter_numprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstnum}    set variable    @{list_num0}[0]
# 	should be true    '${lstnum}' in ${num_list}
#     #should be equal as strings    ${lstnum}    2a00
#     ${lstnum1}    set variable    @{list_num0}[1]
#     #Should Be Equal As Integers    ${lstnum1}    0100
# 	should be true    '${lstnum1}' in ${num_list}
#     ${lstnum2}    set variable    @{list_num0}[2]
#     #Should Be Equal As Integers    ${lstnum1}    1300
# 	should be true    '${lstnum2}' in ${num_list}
#     ${lstnum3}    set variable    @{list_num0}[3]
#     #Should Be Equal As Integers    ${lstnum1}    0100
# 	should be true    '${lstnum3}' in ${num_list}
# 	
# rank2Get and check field values_3
#     [Arguments]    ${filtered_packets}
#     ${list_symbol0}    get_field_value_by_name    field_name=${symbol}
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstsym}    set variable    @{list_symbol0}[0]
#     should be equal as strings    ${lstsym}    0e
#     ${lstsym1}    set variable    @{list_symbol0}[1]
#     Should Be Equal as strings    ${lstsym1}    0c
#     ${list_prb0}    get_field_value_by_name    field_name=${filter_startprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstprb0}    set variable    @{list_prb0}[0]
#     Should Be Equal As Integers    ${lstprb0}    0300
#     ${lstprb1}    set variable    @{list_prb0}[1]
#     Should Be Equal As Integers    ${lstprb1}    0000
#     ${list_num0}    get_field_value_by_name    field_name=${filter_numprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstnum}    set variable    @{list_num0}[0]
#     should be equal as strings    ${lstnum}    1300
#     ${lstnum1}    set variable    @{list_num0}[1]
#     Should Be Equal As Integers    ${lstnum1}    0100
#     ${lstnum1}    set variable    @{list_num0}[2]
#     Should Be Equal As Integers    ${lstnum1}    1300
#     ${lstnum1}    set variable    @{list_num0}[3]
#     Should Be Equal As Integers    ${lstnum1}    0100
# 	
# rank2Get and check field values_7
#     [Arguments]    ${filtered_packets}
#     ${list_symbol0}    get_field_value_by_name    field_name=${symbol}
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstsym}    set variable    @{list_symbol0}[0]
#     should be equal as strings    ${lstsym}    06
#     ${lstsym1}    set variable    @{list_symbol0}[1]
#     Should Be Equal as strings    ${lstsym1}    04
#     ${list_prb0}    get_field_value_by_name    field_name=${filter_startprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstprb0}    set variable    @{list_prb0}[0]
#     Should Be Equal As Integers    ${lstprb0}    0300
#     ${lstprb1}    set variable    @{list_prb0}[1]
#     Should Be Equal As Integers    ${lstprb1}    0000
#     ${list_num0}    get_field_value_by_name    field_name=${filter_numprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstnum}    set variable    @{list_num0}[0]
#     should be equal as strings    ${lstnum}    1300
#     ${lstnum1}    set variable    @{list_num0}[1]
#     Should Be Equal As Integers    ${lstnum1}    0100
# 	
# rank1Get and check field values_2
#     [Arguments]    ${filtered_packets}
# 	${list_symbol0}    get_field_value_by_name    field_name=${symbol}
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstsym}    set variable    @{list_symbol0}[0]
#     should be equal as strings    ${lstsym}    0e
# 	${lstsym1}    set variable    @{list_symbol0}[1]
#     Should Be Equal as strings    ${lstsym1}    0c
# 	${list_prb0}    get_field_value_by_name    field_name=${filter_startprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstprb0}    set variable    @{list_prb0}[0]
# 	Should Be Equal As Integers    ${lstprb0}    0300
# 	${lstprb1}    set variable    @{list_prb0}[1]
# 	Should Be Equal As Integers    ${lstprb1}    0000
# 	${list_num0}    get_field_value_by_name    field_name=${filter_numprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstnum}    set variable    @{list_num0}[0]
# 	should be true    '${lstnum}' in ${num_list}
#     #should be equal as strings    ${lstnum}    2a00
# 	${lstnum1}    set variable    @{list_num0}[1]
# 	should be true    '${lstnum1}' in ${num_list}
#     #Should Be Equal As Integers    ${lstnum1}    0100
# 	${lstnum2}    set variable    @{list_num0}[2]
# 	should be true    '${lstnum2}' in ${num_list}
#     #should be equal as strings    ${lstnum}    1300
# 	${lstnum3}    set variable    @{list_num0}[3]
# 	should be true    '${lstnum3}' in ${num_list}
#     #Should Be Equal As Integers    ${lstnum1}    0100
#     
# 
# 
# rank1Get and check field values_slot2
#     [Arguments]    ${filtered_packets}
# 	${list_symbol0}    get_field_value_by_name    field_name=${symbol}
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstsym}    set variable    @{list_symbol0}[0]
#     should be equal as strings    ${lstsym}    0e
# 	${lstsym1}    set variable    @{list_symbol0}[1]
#     Should Be Equal as strings    ${lstsym1}    0c
# 	${list_prb0}    get_field_value_by_name    field_name=${filter_startprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstprb0}    set variable    @{list_prb0}[0]
# 	Should Be Equal As Integers    ${lstprb0}    0300
# 	${lstprb1}    set variable    @{list_prb0}[1]
# 	Should Be Equal As Integers    ${lstprb1}    0000
# 	${list_num0}    get_field_value_by_name    field_name=${filter_numprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstnum}    set variable    @{list_num0}[0]
# 	should be true    '${lstnum}' in ${num_list}
# 	${lstnum1}    set variable    @{list_num0}[1]
# 	should be true    '${lstnum1}' in ${num_list}
# 	${lstnum2}    set variable    @{list_num0}[2]
# 	should be true    '${lstnum2}' in ${num_list}
# 	${lstnum3}    set variable    @{list_num0}[3]
# 	should be true    '${lstnum3}' in ${num_list}
# 
# rank1Get and check field values_3
#     [Arguments]    ${filtered_packets}
# 	${list_symbol0}    get_field_value_by_name    field_name=${symbol}
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstsym}    set variable    @{list_symbol0}[0]
#     should be equal as strings    ${lstsym}    0e
# 	${lstsym1}    set variable    @{list_symbol0}[1]
#     Should Be Equal as strings    ${lstsym1}    0c
# 	${list_prb0}    get_field_value_by_name    field_name=${filter_startprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstprb0}    set variable    @{list_prb0}[0]
# 	Should Be Equal As Integers    ${lstprb0}    0300
# 	${lstprb1}    set variable    @{list_prb0}[1]
# 	Should Be Equal As Integers    ${lstprb1}    0000
# 	${list_num0}    get_field_value_by_name    field_name=${filter_numprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstnum}    set variable    @{list_num0}[0]
# 	should be true    '${lstnum}' in ${num_list2}
#     #should be equal as strings    ${lstnum}    1300
# 	${lstnum1}    set variable    @{list_num0}[1]
#     #Should Be Equal As Integers    ${lstnum1}    0100
# 	should be true    '${lstnum1}' in ${num_list2}
# 	${lstnum2}    set variable    @{list_num0}[2]
# 	should be true    '${lstnum2}' in ${num_list2}
#     #Should Be Equal As Integers    ${lstnum1}    1300
# 	${lstnum3}    set variable    @{list_num0}[3]
# 	should be true    '${lstnum3}' in ${num_list2}
#     #Should Be Equal As Integers    ${lstnum1}    0100
# 	
# rank1Get and check field values_7
#     [Arguments]    ${filtered_packets}
# 	${list_symbol0}    get_field_value_by_name    field_name=${symbol}
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstsym}    set variable    @{list_symbol0}[0]
#     should be equal as strings    ${lstsym}    06
# 	${lstsym1}    set variable    @{list_symbol0}[1]
#     Should Be Equal as strings    ${lstsym1}    04
# 	${list_prb0}    get_field_value_by_name    field_name=${filter_startprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstprb0}    set variable    @{list_prb0}[0]
# 	Should Be Equal As Integers    ${lstprb0}    0300
# 	${lstprb1}    set variable    @{list_prb0}[1]
# 	Should Be Equal As Integers    ${lstprb1}    0000
# 	${list_num0}    get_field_value_by_name    field_name=${filter_numprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstnum}    set variable    @{list_num0}[0]
#     #should be equal as strings    ${lstnum}    1300
# 	should be true    '${lstnum}' in ${num_list2}
# 	${lstnum1}    set variable    @{list_num0}[1]
#     #Should Be Equal As Integers    ${lstnum1}    0100
# 	should be true    '${lstnum1}' in ${num_list2}
# 
# Get and check field values_2
#     [Arguments]    ${filtered_packets}
# 	${list_symbol0}    get_field_value_by_name    field_name=${symbol}
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstsym}    set variable    @{list_symbol0}[0]
#     should be equal as strings    ${lstsym}    0e
# 	${lstsym1}    set variable    @{list_symbol0}[1]
#     Should Be Equal as strings    ${lstsym1}    0c
# 	${list_prb0}    get_field_value_by_name    field_name=${filter_startprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstprb0}    set variable    @{list_prb0}[0]
# 	Should Be Equal As Integers    ${lstprb0}    0300
# 	${lstprb1}    set variable    @{list_prb0}[1]
# 	Should Be Equal As Integers    ${lstprb1}    0000
# 	${list_num0}    get_field_value_by_name    field_name=${filter_numprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
# 	${lstnum}    set variable    @{list_num0}[0]
#     #should be equal as strings    ${lstnum}    2000
# 	should be true    '${lstnum}' in ${num_list3}
# 	${lstnum1}    set variable    @{list_num0}[1]
#     #Should Be Equal As Integers    ${lstnum1}    0200
# 	should be true    '${lstnum1}' in ${num_list3}
# 	${lstnum2}    set variable    @{list_num0}[2]
#     #should be equal as strings    ${lstnum}    2b00
# 	should be true    '${lstnum2}' in ${num_list3}
# 	${lstnum3}    set variable    @{list_num0}[3]
#     #Should Be Equal As Integers    ${lstnum1}    0200
#     should be true    '${lstnum3}' in ${num_list3}
#    
# 
# Get and check field values_3
#     [Arguments]    ${filtered_packets}
#     ${list_symbol0}    get_field_value_by_name    field_name=${symbol}
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstsym}    set variable    @{list_symbol0}[0]
#     should be equal as strings    ${lstsym}    0e
#     ${lstsym1}    set variable    @{list_symbol0}[1]
#     Should Be Equal as strings    ${lstsym1}    0c
#     ${list_prb0}    get_field_value_by_name    field_name=${filter_startprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstprb0}    set variable    @{list_prb0}[0]
#     Should Be Equal As Integers    ${lstprb0}    0300
#     ${lstprb1}    set variable    @{list_prb0}[1]
#     Should Be Equal As Integers    ${lstprb1}    0000
#     ${list_num0}    get_field_value_by_name    field_name=${filter_numprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstnum}    set variable    @{list_num0}[0]
#     #should be equal as strings    ${lstnum}    2000
# 	should be true    '${lstnum}' in ${num_list4}
#     ${lstnum1}    set variable    @{list_num0}[1]
#     #Should Be Equal As Integers    ${lstnum1}    0200
# 	should be true    '${lstnum1}' in ${num_list4}
#     ${lstnum2}    set variable    @{list_num0}[2]
#     #Should Be Equal As Integers    ${lstnum1}    1400
# 	should be true    '${lstnum2}' in ${num_list4}
#     ${lstnum3}    set variable    @{list_num0}[3]
#     #Should Be Equal As Integers    ${lstnum1}    0200
# 	should be true    '${lstnum3}' in ${num_list4}
# 	
# Get and check field values_7
#     [Arguments]    ${filtered_packets}
#     ${list_symbol0}    get_field_value_by_name    field_name=${symbol}
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstsym}    set variable    @{list_symbol0}[0]
#     should be equal as strings    ${lstsym}    06
#     ${lstsym1}    set variable    @{list_symbol0}[1]
#     Should Be Equal as strings    ${lstsym1}    04
#     ${list_prb0}    get_field_value_by_name    field_name=${filter_startprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstprb0}    set variable    @{list_prb0}[0]
#     #Should Be Equal As Integers    ${lstprb0}    0300
# 	should be true    '${lstprb0}' in ${num_list6}
#     ${lstprb1}    set variable    @{list_prb0}[1]
#     #Should Be Equal As Integers    ${lstprb1}    0000
# 	should be true    '${lstprb1}' in ${num_list6}
#     ${list_num0}    get_field_value_by_name    field_name=${filter_numprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstnum}    set variable    @{list_num0}[0]
# 	should be true    '${lstnum}' in ${num_list5}
#     #should be equal as strings    ${lstnum}    2000
#     ${lstnum1}    set variable    @{list_num0}[1]
#     #Should Be Equal As Integers    ${lstnum1}    0200
#     should be true    '${lstnum1}' in ${num_list5}
# 
# fullGet and check field values_3
#     [Arguments]    ${filtered_packets}
#     ${list_prb0}    get_field_value_by_name    field_name=${filter_startprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstprb0}    set variable    @{list_prb0}[0]
#     #Should Be Equal As Integers    ${lstprb0}    0300
# 	should be true    '${lstprb0}' in ${num_list6}
#     ${lstprb1}    set variable    @{list_prb0}[1]
#     #Should Be Equal As Integers    ${lstprb1}    0000
# 	should be true    '${lstprb1}' in ${num_list6}
#     ${list_num0}    get_field_value_by_name    field_name=${filter_numprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstnum}    set variable    @{list_num0}[0]
#     should be equal as strings    ${lstnum}    3f00
#     ${lstnum1}    set variable    @{list_num0}[1]
#     Should Be Equal As Integers    ${lstnum1}    0300
#     ${list_symbol0}    get_field_value_by_name    field_name=${symbol}
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstsym}    set variable    @{list_symbol0}[0]
#     should be equal as strings    ${lstsym}    06
#     ${lstsym1}    set variable    @{list_symbol0}[1]
#     Should Be Equal as strings    ${lstsym1}    04
# 	
# fullGet and check field values_2
#     [Arguments]    ${filtered_packets}
#     ${list_prb0}    get_field_value_by_name    field_name=${filter_startprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstprb0}    set variable    @{list_prb0}[0]
#     #Should Be Equal As Integers    ${lstprb0}    0300
# 	should be true    '${lstprb0}' in ${num_list6}
#     ${lstprb1}    set variable    @{list_prb0}[1]
#     #Should Be Equal As Integers    ${lstprb1}    0000
# 	should be true    '${lstprb1}' in ${num_list6}
#     ${list_num0}    get_field_value_by_name    field_name=${filter_numprb} 
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstnum}    set variable    @{list_num0}[0]
#     #should be equal as strings    ${lstnum}    3f00
# 	should be true    '${lstnum}' in ${num_list7}
#     ${lstnum1}    set variable    @{list_num0}[1]
#     #Should Be Equal As Integers    ${lstnum1}    0300
# 	should be true    '${lstnum1}' in ${num_list7}
#     ${list_symbol0}    get_field_value_by_name    field_name=${symbol}
#     ...    attribute_name=value    pcap_parser="Parser"
#     ${lstsym}    set variable    @{list_symbol0}[0]
#     should be equal as strings    ${lstsym}    0e
#     ${lstsym1}    set variable    @{list_symbol0}[1]
#     Should Be Equal as strings    ${lstsym1}    0c
# 
# Delete log
#     [Documentation]    Author: Deng xueqin
#     ...                Description: Delete the download log
#     [Arguments]    ${log_file}
#     Run Keyword And Ignore Error    run    command=rm -rf ${log_file}
# 
