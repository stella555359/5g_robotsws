*** Settings ***
Documentation
...    author: Jiang Wenwen
...    contact: wenwen.jiang@nokia-sbell.com
...    squad group: MMW_02
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bip_log.robot
Library    taf.sbts.oam.coam.admin    WITH NAME    sbts


*** Variables ***


*** Keywords ***
Start Downlink lowload test
    [Documentation]  Author: cheng meiya
    ...              Description: Start Downlink low load test
    Connect to gnb coam via ssl
    coam.change_bts_rad_parameters     component=69   type=Dynamic changes	params=39:1    connection=GNB_OAM
    sleep    30s
    coam.start_5g_downlink_test
	...                            dist_name=${nrcell_r}
	...                            test_model=${test_model}   
    ...                       beam_pattern_id=${Beam_ID}
	...                         power_backoff=${power_backoff}
	...                          polarization=${polarizationR2}
	...                              ru_mode=${ru_mode}
	...                                p_max=${p_max}
	...                           mimo_rank=${mimo_rank2}
	...                        phys_cell_id=${phys_cell_id}
	...                 i2_codebook_4_antports=${i2_codebook_4_antports}
	...                 i11_codebook_4_antports=${i11_codebook_4_antports}
	...                i13_codebook_4_antports=${i13_codebook_4_antports}
	...                codebook_2_antports=${codebook_2_antports}
	...                           load_type=${load_type}
	...                      load_level_flat=${load_level_flatlow}
	...           num_of_ssb_beam_pattern_id=${num_of_ssb_beam_pattern_id} 
	...                  ssb_beam_pattern_id=${ssb_beam_pattern_id}
	...                           connection=${alias}
	sleep    30s
	Run Keyword And Ignore Error    COAM Teardown gnb connections
	
Get and check field values1
    [Arguments]    ${filtered_packets}
	${list0}    get_field_value_by_name    field_name=${num_symbol}
    ...    attribute_name=value    pcap_parser="Parser"
	FOR    ${value}    IN    @{list0}
		Should Be Equal As Integers    ${value}    02    base=16
		sleep    2s
    END
    ${list1}    get_field_value_by_name    field_name=${start_symbol}
    ...    attribute_name=value    pcap_parser="Parser"
	FOR    ${value}    IN    @{list1}
		Should Be Equal As Integers    ${value}    00    base=16
		sleep    2s
    END
	${list2}    get_field_value_by_name    field_name=${start_cce}
    ...    attribute_name=value    pcap_parser="Parser"
	FOR    ${value}    IN    @{list2}
		Should Be Equal As Integers    ${value}    00    base=16
		sleep    2s
    END  


Get and check field values common
    [Arguments]    ${filtered_packets}
	${list0}    get_field_value_by_name    field_name=${num_symbol}
    ...    attribute_name=value    pcap_parser="Parser"
	${value}     set variable   ${list0}[0]
    Should Be Equal As Integers    ${value}    02
    ${list1}    get_field_value_by_name    field_name=${start_symbol}
    ...    attribute_name=value    pcap_parser="Parser"
	${value}    set variable     ${list1}[0]
	Should Be Equal As Integers    ${value}    00	
	${list2}    get_field_value_by_name    field_name=${start_cce}
    ...    attribute_name=value    pcap_parser="Parser"
	${value}     set variable      ${list2}[0]
	Should Be Equal As Integers    ${value}    00

Start Downlink load test
    [Documentation]  Author: cheng meiya
    ...              Description: Start Downlink fullload test
	[Arguments]    ${polarization}=${polarization}    ${load_level_flat}=${load_level_flat}    ${mimo_rank}=${mimo_rank} 
    Connect to gnb coam via ssl
    coam.change_bts_rad_parameters     component=69   type=Dynamic changes	params=39:1    connection=GNB_OAM
    sleep    30s
	coam.start_5g_downlink_test
	...                            dist_name=${nrcell_r}
	...                            test_model=${test_model}   
    ...                       beam_pattern_id=${Beam_ID}
	...                         power_backoff=${power_backoff}
	...                          polarization=${polarization}
	...                              ru_mode=${ru_mode}
	...                                p_max=${p_max}
	...                           mimo_rank=${mimo_rank}
	...                        phys_cell_id=${phys_cell_id}
	...                 i2_codebook_4_antports=${i2_codebook_4_antports}
	...                 i11_codebook_4_antports=${i11_codebook_4_antports}
	...                i13_codebook_4_antports=${i13_codebook_4_antports}
	...                codebook_2_antports=${codebook_2_antports}
	...                           load_type=${load_type}
	...                      load_level_flat=${load_level_flat}
	...                           connection=${alias}
	sleep    40s
	Run Keyword And Ignore Error    COAM Teardown gnb connections
	
Step1 Change BTS R&D Parameter
    Connect to gnb coam via ssl
    coam.change_bts_rad_parameters     component=69   type=Dynamic changes	params=39:1    connection=GNB_OAM
    sleep    30s
	#Start Downlink fullload test
    #COAM Teardown gnb connections
	
Get and check RANK2 values
    [Arguments]    ${filtered_packets}
	${list0}    get_field_value_by_name    field_name=${rank_value}
    ...    attribute_name=value    pcap_parser="Parser"
	FOR    ${value}    IN    @{list0}
		Should Be Equal As Integers    ${value}    02    base=16
    END

Get and check RANK values
    [Arguments]    ${filtered_packets}
	${list0}    get_field_value_by_name    field_name=${rank_value}
    ...    attribute_name=value    pcap_parser="Parser"
	FOR    ${value}    IN    @{list0}
		Should Be Equal As Integers    ${value}    01    base=16
    END
	
Stop downlink Performance test
    [Documentation]  Author: cheng meiya
    ...              Description: Stop downlink Performance test
	Connect to gnb coam via ssl
    coam.stop_5g_downlink_test    dist_name=${nrcell_r}    connection=GNB_OAM
    Run Keyword And Ignore Error    COAM Teardown gnb connections
	
Get dldatalogs from bip common
    [Arguments]    ${bip_file}    ${filter}
	${Parser}    cap.setup    infile=${bip_file}    display_filter=${filter}
	...    tshark_path=${tshark_path}    alias="Parser"
    [Return]    ${Parser}



	
Test Suite Setup
    [Documentation]  Author: Wenwen Jiang
    ...              Description: test suite setup
	robot_common_operations.Common Suite Setup
    CI_interface.Common Suite Setup
    API login
    Check BTS OnAir
    ${nrcell}    SBTS Get Managed Objects    class_name=NRCELL_R
    Set Suite Variable   ${nrcell_r}   ${nrcell[0]['distName']}
    Get cells info
    sbts.reset_to_test_dedicated    connection=${alias}
    Sleep     5m
    [Teardown]    API Logout

Test Suite Teardown
    [Documentation]  Author: Wenwen Jiang
    ...              Description: test suite teardown
    Restore TL
    Sleep    7s
	robot_common_operations.Common Suite Teardown
    [Teardown]    Run Keyword And Ignore Error    API Logout

Case Teardown
    [Documentation]  Author: Wenwen Jiang
    ...              Description: stop performance test
    Stop Performance test
    API Logout
    Sleep    30s
    CI_interface.Common Case Teardown
	robot_common_operations.Common Case Teardown

API login
    sbts.connect_to
    ...   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...   admin_api_log_dir=${log_dir}
    ...   name=${alias}

Get cells info
    [Documentation]  Author: Wenwen Jiang
    ...              Description: get nrarfcn and physical cell id
    ${cell_info}    sbts.get_cell_specific_info    cell_id=${nrcell_r}    connection=${alias}    timeout=${60}
    Set Suite Variable     ${nrarfcn}    ${cell_info['nrarfcn']}
    Set Suite Variable     ${Physical_Cell_ID}    ${cell_info['physicalCellId']}

Start uplink Pucch test
    [Documentation]  Author: Wenwen Jiang
    ...              Description: start pucch performance test
    sbts.start_5g_uplink_ccm_test_pucch
    ...                 dist_name=${nrcell_r}
    ...                                          nrarfcn_dl=${nrarfcn}
	...                                          nrarfcn_ul=${nrarfcn}
    ...                                          interval=${reporting_time_interval}
    ...                                          receiving_slot=${reception_slot}
    ...                                          expectation_slot=${exception_slot}
    ...                                          ru_mode=${ru_mode}
    ...                                          pucch_format=${pucch_format}
    ...                                          num_pucch_symbol=${number_of_pucch_symbol}
    ...                                          beam_pattern_id=${Beam_ID_pucch}
    ...                                          phys_cell_id=${Physical_Cell_ID}
    ...                                          prb_offset=${prb_offset}
    ...                                          largest_prb_index=${largest_prb_index}
    ...                                          pucch_payload_content=${pucch_payload_content}
    ...                                          format3_additional_dmrs=Disabled
    ...                                          num_pucch_symbol=${numPucchSymbol}
    ...                                          num_payload_bit=${num_payload_bit}
    ...                                          connection=${alias}
	...                                          digital_output_enable=False
	...                                          act_high_speed_cell=False
    sleep    30s

Watch pucch test result
    [Documentation]  Author: Wenwen Jiang
    ...              Description: check pucch performance test result
    ${result}    sbts.watch_5g_uplink_ccm_test_results
     ...                nr_cell_rdn=${nrcell_r}
     ...                connection=${alias}
     ${missedCounter}    Get From Dictionary    ${result}        missedCounter
     ${missedCounter1}     Convert To String    ${missedCounter}
     set suite variable    ${missedCounter1}
     ${idlePeriodCounter}    Get From Dictionary    ${result}        idlePeriodCounter
     ${idlePeriodCounter1}     Convert To String    ${idlePeriodCounter}
     set suite variable    ${idlePeriodCounter1}

Stop Performance test
    [Documentation]  Author: Wenwen Jiang
    ...              Description: stop pucch performance test
    sbts.Stop 5g Uplink Ccm Test
     ...                dist_name=${nrcell_r}
     ...                connection=${alias}
     
Verify result for pucch
    [Documentation]  Author: Wenwen Jiang
    ...              Description: verify pucch result
#    Should Be Equal    ${missedCounter1}    800
    Should Be Equal    ${idlePeriodCounter1}    800

Start uplink Prach test
    [Documentation]  Author: Wenwen Jiang
    ...              Description: start prach performance test
    sbts.start_5g_uplink_ccm_test_prach
    ...                 dist_name=${nrcell_r}
    ...                                          nrarfcn_ul=${nrarfcn}
	...                                          nrarfcn_dl=${nrarfcn}
    ...                                          interval=${reporting_time_interval}
    ...                                          receiving_slot=${reception_slot}
    ...                                          expectation_slot=${exception_slot}
    ...                                          ru_mode=${ru_mode}
    ...                                          prach_configuration_index=${prach_configuration_index}
    ...                                          prach_root_sequence_index=${prach_root_sequence_index}
    ...                                          delay_pattern_single_step_duration=${delay_pattern_duration}
    ...                                          beam_pattern_id=${Beam_ID_prach}
    ...                                          phys_cell_id=${Physical_Cell_ID}
    ...                                          zero_correlation_zone_config=${zero_correlation_zone_config}
    ...                                          constant_offset=${constant_offset}
    ...                                          pfa_target_prach_id=${pfa_target_prach_id}
    ...                                          preamble_index=${preamble_index}
    ...                                          accepted_timing_error=${accepted_timing_error}
    ...                                          prach_sequence_type=${prach_seq_type}
    ...                                          connection=${alias}
	...                                          digital_output_enable=False
	...                                          act_high_speed_cell=False
    sleep    30s

Watch prach test result
    [Documentation]  Author: Wenwen Jiang
    ...              Description: watch prach performance test result
    ${result}    sbts.watch_5g_uplink_ccm_test_results
     ...                nr_cell_rdn=${nrcell_r}
     ...                connection=${alias}
     ${missedCounter}    Get From Dictionary    ${result}        missedCounter
     ${missedCounter2}     Convert To String    ${missedCounter}
     set suite variable    ${missedCounter2}
     ${idlePeriodCounter}    Get From Dictionary    ${result}        idlePeriodCounter
     ${idlePeriodCounter2}     Convert To String    ${idlePeriodCounter}
     set suite variable    ${idlePeriodCounter2}
     

Verify result for prach
    [Documentation]  Author: Wenwen Jiang
    ...              Description: verify prach performance test result
    Should Be Equal    ${missedCounter2}    800
    Should Be Equal    ${idlePeriodCounter2}    800

Restore TL
    [Documentation]  Author: Wenwen Jiang
    ...              Description: restore TL
    API login
    sbts.reset_site    connection=${alias}
    Wait Until Keyword Succeeds    10min    20s    API login
    Wait Until Keyword Succeeds   18min   30s   Check BTS OnAir


API Logout
    sbts.teardown      connection=${alias}

Check BTS OnAir
    [Documentation]  Author: Wenwen Jiang
    ...              Description: check if BTS onair
    ${bts_info}   sbts.get_bts_info   connection=${alias}   timeout=10
    ${status}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['status']['proceduralState']}
    ...   ELSE   Set Variable   ${bts_info['status']['proceduralState']}
    Should Contain   ${status}   OnAir
    
SBTS Get Managed Objects
    [Documentation]  Author: Wenwen Jiang
    ...              Description: get gnb info 
    [Arguments]   ${class_name}=NRCELL_R   ${connection}=${alias}
    ${managed_objects}   sbts.get_managed_objects   class_name=${class_name}   connection=${connection}   timeout=${300}
    [Return]   ${managed_objects}
    
Start pusch performance test
    [Documentation]  Author: cheng meiya
    ...              Description: Start pusch performance test
    sbts.start_5g_uplink_ccm_test_pusch
    ...                            dist_name=${nrcell_r}
    ...                            frc_index=${FRC_index}    
    ...                             interval=${reporting_time_interval}
    ...                     digital_out_rate=${digital_output_rate}
    ...                     digital_out_type=${Digital_out_type}
    ...                      beam_pattern_id=${Beam_ID}
    ...                              ru_mode=${ru_mode}
    ...                         phys_cell_id=${Physical_Cell_ID}
    ...                          bb_selector=${BB_selector}
    ...                           prb_offset=${PRB_offset}
    ...                              nrarfcn_ul=${nrarfcn}
    ...                      ul_dmrs_mapping_type=${ul_dmrs_mapping_type}
    ...                    is_ptrs_fr2_enabled=false
    ...                           connection=${alias}
	...                          digital_output_enable=True
	...                          nrarfcn_dl=${nrarfcn}
	...                                          act_high_speed_cell=false
    sleep    30s
     
check pusch test result
    [Documentation]  Author: cheng meiya
    ...              Description: check pusch test result
    ${result}    sbts.watch_5g_uplink_ccm_test_results
    ...                nr_cell_rdn=${nrcell_r}
    ...                connection=${alias}
    ${missedCounter1}=    Get From Dictionary    ${result}        missedCounter1
    ${missedCounter1}     Convert To String    ${missedCounter1}
    set suite variable    ${missedCounter1}
    ${numberOfUnreceivedBits}=    Get From Dictionary    ${result}        numberOfUnreceivedBits
    ${numberOfUnreceivedBits}     Convert To String    ${numberOfUnreceivedBits}
    set suite variable    ${numberOfUnreceivedBits}

Verify result for pusch
    [Documentation]  Author: cheng meiya
    ...              Description: Verify result for pusch
    Should Be Equal    ${missedCounter1}    0
    Should Not Be Equal    ${numberOfUnreceivedBits}    0
