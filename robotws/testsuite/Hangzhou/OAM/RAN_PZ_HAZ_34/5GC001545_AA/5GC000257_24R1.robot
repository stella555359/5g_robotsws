*** Settings ***
Documentation
...   author: Jiang Johnny
...   contact: johnny.1.jiang@nokia-sbell.com
Resource   Resource${/}NetAct.robot
Resource   Resource${/}common_license.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Force Tags    SG_07   CA_5G_OAM    CRT_UTE   master_classicalbts_all   5G_RAN
...    PY36
...   5G_RAN_TDD   CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABILB1_AEQV_ENB   STATE_SW_UPLOADED
...   AUTHOR_johnny.1.jiang@nokia-sbell.com   RAN_5G   RAN_5G_TDD   SBTS00

#Suite Setup   Run Keywords   common_license.Common Setup
#...   AND    COAM Check Units Status Normal   fbb-1   fsm-1
#Suite Teardown   common_license.Common Teardown   restore=${true}

*** Variables ***
${plan_copy_from}=  CURRENT_BTS_CONF-1
${NRcelltype}=    NR Cell type
${typevalue}=    nrCellType
${Basic_Beam_Set}=   Basic Beam Set
${numberOfTransmittedSsBlocks}=   	Number of transmitted Synchronization Signal Blocks
${lteToNrFrameShift}=    LTE to NR frame shift
${prachConfigurationIndex}=    PRACH configuration index
${output power_ban}=   Maximum output power
${power_value}=    26
${power_value2}=    35
${WEB_DOWNLOAD_DIR}   ${OUTPUT_DIR}
${channel_band}=   Channel bandwidth
${band_width}=    60MHz
${band_width2}=    40Mhz

*** Test Cases ***
[1][1.0] 5GC000257_License_computation_cmwave RF_bandwidth reduce for classical BTS
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    ******************
    ...    History of changes
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    [Tags]    AUTHOR_fred.li@nokia-sbell.com
    [Timeout]   2 hour
    [Setup]
#    wait until keyword succeeds   3x   10s  Get Original Capacity
#    set parameters bandwidth    bandwidth=60MHz
#    Check SWEM Report bandwidth    chbw=${band_width}
#    set parameters bandwidth    bandwidth=40MHz
#    Check SWEM Report bandwidth    chbw=${band_width2}
#    wait until keyword succeeds     3x     1min
#    ...   Download SWEM Report as CSV    report_type=aggregated    report_title=SWEM for SRAN CM
#    ${value2}   Get Licensed Capacity Via CSV   sales_item=SR000024
#    ${value2}   Convert To Number   ${value2}
#    ${value2}   Convert To Integer   ${value2}
#    should be equal   ${value2}   ${bandwidth_ori}
    Log To Console    Pass Execution
    [Teardown]    CI_interface.Common Case Teardown

[1][1.0] 5GC000257_License_computation_cmwave RF_bandwidth usage for classical BTS
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    ******************
    ...    History of changes
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    [Tags]    AUTHOR_fred.li@nokia-sbell.com
    [Setup]
    [Timeout]   2 hour
#    set parameters bandwidth    bandwidth=60MHz
#    Check SWEM Report bandwidth    chbw=${band_width}
#    set parameters bandwidth    bandwidth=40MHz
#    Check SWEM Report bandwidth    chbw=${band_width2}
    Log To Console    Pass Execution
    [Teardown]   CI_interface.Common Case Teardown

[1][1.0] 5GC000257_License_computation_cmwave RF_Beam activation reduce for classical BTS
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    ******************
    ...    History of changes
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    [Tags]    AUTHOR_fred.li@nokia-sbell.com
    [Timeout]   2 hour
    [Setup]
#    Modify_beam_Parameters_all_cell   celltype=8DL4UL
#    Check SWEM Report beam   cell_numbers=${cell_numbers}     beam_license=2
#    Modify_beam_Parameters_all_cell   celltype=4DL4UL
#    Check SWEM Report beam   cell_numbers=${cell_numbers}      beam_license=1
#    wait until keyword succeeds     3x     1min
#    ...   Download SWEM Report as CSV    report_type=aggregated    report_title=SWEM for SRAN CM
#    ${value2}   Get Licensed Capacity Via CSV   sales_item=SR000025
#    ${value2}   Convert To Number   ${value2}
#    ${value2}   Convert To Integer   ${value2}
#    ${beam_capacity}    evaluate   2*${cell_numbers}
#    should be equal   ${value2}    ${beam_capacity}
    Log To Console    Pass Execution
    [Teardown]   CI_interface.Common Case Teardown

[1][1.0] 5GC000257_License_computation_cmwave RF_Beam activation usage for classical BTS
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    ******************
    ...    History of changes
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    [Tags]    AUTHOR_fred.li@nokia-sbell.com
    [Timeout]   2 hour
    [Setup]
#    Modify_beam_Parameters_all_cell   celltype=8DL4UL
#    Check SWEM Report beam   cell_numbers=${cell_numbers}    beam_license=2
#    Modify_beam_Parameters_all_cell   celltype=4DL4UL
#    Check SWEM Report beam   cell_numbers=${cell_numbers}    beam_license=1
    Log To Console    Pass Execution
    [Teardown]   CI_interface.Common Case Teardown

[1]5GC000257_License_computation_cmwave RF_TRP reduce for classical BTS
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    ******************
    ...    History of changes
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    [Tags]    AUTHOR_fred.li@nokia-sbell.com
    [Timeout]   2 hour
    [Setup]
#    Restore gNB SCF
#    run keyword and ignore error    selenium_coam.close_start_up_view_window
#    :FOR   ${index}    IN RANGE    ${cell_numbers}
#    \   set parameters power   index=${index+1}
#    Check SWEM Report power  cell_numbers=${cell_numbers}    trp_license=2
#    :FOR   ${index}    IN RANGE    ${cell_numbers}
#    \   modify The Power   index=${index+1}
#    Check SWEM Report power  cell_numbers=${cell_numbers}    trp_license=1
#    wait until keyword succeeds     3x     1min
#    ...   Download SWEM Report as CSV    report_type=aggregated    report_title=SWEM for SRAN CM
#    ${value2}   Get Licensed Capacity Via CSV   sales_item=SR000026
#    ${value2}   Convert To Number   ${value2}
#    ${value2}   Convert To Integer   ${value2}
#    ${trp_license}    evaluate    2*${cell_numbers}
#    should be equal   ${value2}    ${trp_license}
    Log To Console    Pass Execution
    [Teardown]   CI_interface.Common Case Teardown

[1][1.0] 5GC000257_License_computation__TRP usage_sharing with enb
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    ******************
    ...    History of changes
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    [Tags]    AUTHOR_fred.li@nokia-sbell.com
    [Timeout]   2 hour
    [Setup]
#    UTE Preparation
#    run keyword and ignore error    selenium_coam.close_start_up_view_window
#    :FOR   ${index}    IN RANGE    ${cell_numbers}
#    \   set parameters power   index=${index+1}
#    Check SWEM Report power  cell_numbers=${cell_numbers}    trp_license=2
#    :FOR   ${index}    IN RANGE    ${cell_numbers}
#    \   modify The Power   index=${index+1}
#    Check SWEM Report power  cell_numbers=${cell_numbers}    trp_license=1
    Log To Console    Pass Execution
    [Teardown]   CI_interface.Common Case Teardown

*** Keywords ***
Step4: Check SWEM Report ${scc_num} ${scc_num_capacity}
#     sleep  10m
     wait until keyword succeeds     3x     1min
     ...   Download SWEM Report as CSV    report_type=detailed
     ${gold_value}   Get Licensed Capacity Via CSV     sales_item=5G000004    report_type=detailed
     ${silver_value}   Get Licensed Capacity Via CSV   sales_item=5G000003   report_type=detailed
     ${bronze_value}   Get Licensed Capacity Via CSV   sales_item=5G000002   report_type=detailed
     ${gold_value}   Convert To Number   ${gold_value}
     ${silver_value}   Convert To Number   ${silver_value}
     ${bronze_value}   Convert To Number   ${bronze_value}
     ${gold_value}   Convert To Integer   ${gold_value}
     ${silver_value}   Convert To Integer   ${silver_value}
     ${bronze_value}   Convert To Integer   ${bronze_value}
     should be equal   ${gold_value}   ${scc_num}
     should be equal   ${silver_value}   ${scc_num}
     should be equal   ${bronze_value}   ${scc_num}
     wait until keyword succeeds     3x     1min
     ...   Download SWEM Report as CSV
     ${gold_capacity}   Get Licensed Capacity Via CSV     sales_item=5G000004
     ${silver_capacity}   Get Licensed Capacity Via CSV   sales_item=5G000003
     ${bronze_capacity}   Get Licensed Capacity Via CSV   sales_item=5G000002
     ${gold_value}   Convert To Number   ${gold_value}
     ${silver_value}   Convert To Number   ${silver_value}
     ${bronze_value}   Convert To Number   ${bronze_value}
     ${gold_capacity}   Convert To Integer   ${gold_capacity}
     ${silver_capacity}   Convert To Integer   ${silver_capacity}
     ${bronze_capacity}   Convert To Integer   ${bronze_capacity}
     should be equal   ${gold_capacity}   ${scc_num_capacity}
     should be equal   ${silver_capacity}   ${scc_num_capacity}
     should be equal   ${bronze_capacity}   ${scc_num_capacity}

Step1: Check The Gold Failed FAF PDL Rule
     wait until keyword succeeds  3 times   5s   selenium_coam.set_parameter_value   MRBTS-${BTS_ID}/${dist_name}    ${dist_name_gold}      true
     wait until keyword succeeds  3 times   5s   selenium_coam.set_parameter_value   MRBTS-${BTS_ID}/${dist_name}    ${dist_name_silver}    false
     wait until keyword succeeds  3 times   5s   selenium_coam.set_parameter_value   MRBTS-${BTS_ID}/${dist_name}    ${dist_name_bronze}    true
     selenium_coam.validate_plan    timeout=40
     ${PDL_Return}   selenium_coam.get_relation_errors
     FOR   ${error}   IN   @{PDL_Return["MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}"]}
         ${match}   run keyword and return status  Should Match Regexp    ${error}
         ...    actGeneralConnectivityGold.*true.*actGeneralConnectivitySilver.*false.*true
         exit for loop if   ${match}
     END
     should be true   ${match}
     run keyword and ignore error    wait until keyword succeeds  3 times   5s   selenium_coam.undo_changes

Step2: Check The Silver Failed FAF PDL Rule
     wait until keyword succeeds  3 times   5s   selenium_coam.set_parameter_value   MRBTS-${BTS_ID}/${dist_name}    ${dist_name_gold}      false
     wait until keyword succeeds  3 times   5s   selenium_coam.set_parameter_value   MRBTS-${BTS_ID}/${dist_name}    ${dist_name_silver}    true
     wait until keyword succeeds  3 times   5s   selenium_coam.set_parameter_value   MRBTS-${BTS_ID}/${dist_name}    ${dist_name_bronze}    false
     selenium_coam.validate_plan    timeout=40
     ${PDL_Return}   selenium_coam.get_relation_errors
     FOR   ${error}   IN   @{PDL_Return["MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}"]}
         ${match}   run keyword and return status  Should Match Regexp    ${error}
         ...    actGeneralConnectivitySilver.*true.*actGeneralConnectivityBronze.*false.*true
         exit for loop if   ${match}
     END
     should be true   ${match}
     run keyword and ignore error    wait until keyword succeeds  3 times   5s   selenium_coam.undo_changes

Step3: Check The Correct FAF PDL Rule
    FOR   ${param}   IN   @{uclap_flag_fit_list}
        wait until keyword succeeds  3 times   5s   selenium_coam.set_parameter_value
        ...   MRBTS-${BTS_ID}/${dist_name}    ${dist_name_gold}   ${param[0]}
        wait until keyword succeeds  3 times   5s   selenium_coam.set_parameter_value
        ...   MRBTS-${BTS_ID}/${dist_name}    ${dist_name_silver}   ${param[1]}
        wait until keyword succeeds  3 times   5s   selenium_coam.set_parameter_value
        ...   MRBTS-${BTS_ID}/${dist_name}    ${dist_name_bronze}   ${param[2]}
        selenium_coam.validate_plan    timeout=40
        ${PDL_Result}   selenium_coam.get_relation_errors
#        run keyword and continue on failure  should be empty  ${PDL_Result}
        run keyword and ignore error    wait until keyword succeeds  3 times   5s   selenium_coam.undo_changes
    END

Step1: Check The Silver FAF PDL Rule
     ${uclap_def}   Set Variable   ${feature_flag_def["silver"]}
     FOR   ${feature}   IN   @{uclap_def.keys()}
        run keyword and continue on failure   Common Check PDL Rule   feature=${feature}   uclap_def=${uclap_def}   flag_value=silver
     END
#     \    wait until keyword succeeds  3 times   5s   selenium_coam.set_parameter_value
#         ...    ${uclap_def['${feature}']['dist_name']}   ${uclap_def['${feature}']['para_name']}   ${uclap_def['${feature}']['open'][0]}
#     \    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_bronze}   new_value=true
#     \    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_silver}   new_value=false
#     \    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_gold}   new_value=false
#     \    Silver PDL Validate Return Error Check   ${feature}   ${uclap_def}

Step2: Check The Bronze FAF PDL Rule
     ${uclap_def}   Set Variable   ${feature_flag_def["bronze"]}
     FOR   ${feature}   IN   @{uclap_def.keys()}
        run keyword and continue on failure   Common Check PDL Rule   feature=${feature}   uclap_def=${uclap_def}
     END
#     \    wait until keyword succeeds  3 times   5s   selenium_coam.set_parameter_value
#         ...    ${uclap_def['${feature}']['dist_name']}   ${uclap_def['${feature}']['para_name']}   ${uclap_def['${feature}']['open'][0]}
#     \    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_bronze}   new_value=false
#     \    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_silver}   new_value=false
#     \    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_gold}   new_value=false
#     \    Bronze PDL Validate Return Error Check   ${feature}   ${uclap_def}

Step3: Check The Bronze FAF PDL Rule With Text
     ${uclap_def}   Set Variable   ${feature_flag_def["bronze_txt"]}
     FOR   ${feature}   IN   @{uclap_def.keys()}
        run keyword and continue on failure   Common Check PDL Rule   feature=${feature}   uclap_def=${uclap_def}
     END
#     \    wait until keyword succeeds  3 times   5s   selenium_coam.set_parameter_value
#         ...    ${uclap_def['${feature}']['dist_name']}   ${uclap_def['${feature}']['para_name']}   ${uclap_def['${feature}']['open'][0]}
#     \    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_bronze}   new_value=false
#     \    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_silver}   new_value=false
#     \    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_gold}   new_value=false
#     \    Bronze PDL Validate Return Error Check   ${feature}   ${uclap_def}

Step4: Check The Bronze FAF PDL Rule With MO
     #run keyword and continue on failure   l2QoSEnabled_Validate
     run keyword and continue on failure   NRDU_Validate
#     run keyword and continue on failure   TOP_Validate
#     run keyword and continue on failure   IpSecEnabled_Validate

Step5: Check The Gold FAF PDL Rule
     ${uclap_def}   Set Variable   ${feature_flag_def["gold"]}
     FOR   ${feature}   IN   @{uclap_def.keys()}
        run keyword and continue on failure   Common Check PDL Rule   feature=${feature}   uclap_def=${uclap_def}  flag_value=gold
     END

Common Check PDL Rule
     [Arguments]   ${feature}   ${uclap_def}   ${flag_value}=bronze
     wait until keyword succeeds  3 times   5s   selenium_coam.set_parameter_value    dist_name=${uclap_def['${feature}']['dist_name']}
     ...   filter_param=${uclap_def['${feature}']['para_name']}   new_value=${uclap_def['${feature}']['open'][0]}
     Run Keyword If   '${flag_value}'=='bronze'    selenium_coam.set_parameter_value
     ...  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_bronze}   new_value=false
     ...  ELSE  selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_bronze}   new_value=true
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_silver}   new_value=false
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_gold}   new_value=false
     Run Keyword If   '${flag_value}'=='bronze'   Bronze PDL Validate Return Error Check   feature=${feature}   uclap_def=${uclap_def}
     Run Keyword If   '${flag_value}'=='silver'   Silver PDL Validate Return Error Check   feature=${feature}   uclap_def=${uclap_def}
     Run Keyword If   '${flag_value}'=='gold'   Gold PDL Validate Return Error Check   feature=${feature}   uclap_def=${uclap_def}

Gold PDL Validate Return Error Check
    [Arguments]   ${feature}   ${uclap_def}
     selenium_coam.validate_plan    timeout=40
     ${PDL_Return}   selenium_coam.get_relation_errors
     FOR   ${error}   IN   @{PDL_Return["MRBTS-${BTS_ID}/${uclap_def['${feature}']['object_name']}"]}
         ${match}   run keyword and return status  Should Match Regexp    ${error}
         ...    actGeneralConnectivityGold.*false.*true
         exit for loop if   ${match}
     END
     run keyword and continue on failure  should be true   ${match}
     wait until keyword succeeds  3 times   5s   selenium_coam.undo_changes

Silver PDL Validate Return Error Check
    [Arguments]   ${feature}   ${uclap_def}
     selenium_coam.validate_plan    timeout=40
     ${PDL_Return}   selenium_coam.get_relation_errors
     FOR   ${error}   IN   @{PDL_Return["MRBTS-${BTS_ID}/${uclap_def['${feature}']['object_name']}"]}
         ${match}   run keyword and return status  Should Match Regexp    ${error}
         ...    actGeneralConnectivitySilver.*false.*true
         exit for loop if   ${match}
     END
     run keyword and continue on failure  should be true   ${match}
     run keyword and ignore error    wait until keyword succeeds  3 times   5s   selenium_coam.undo_changes

Bronze PDL Validate Return Error Check
    [Arguments]   ${feature}   ${uclap_def}
     selenium_coam.validate_plan    timeout=40
     ${PDL_Return}   selenium_coam.get_relation_errors
     FOR   ${error}   IN   @{PDL_Return["MRBTS-${BTS_ID}/${uclap_def['${feature}']['object_name']}"]}
         ${match}   run keyword and return status  Should Match Regexp    ${error}
         ...    actGeneralConnectivityBronze.*true
         exit for loop if   ${match}
     END
     run keyword and continue on failure  should be true   ${match}
     run keyword and ignore error    wait until keyword succeeds  3 times   5s   selenium_coam.undo_changes

l2QoSEnabled_Validate
     ${uclap_def}   Set Variable   ${feature_flag_def["bronze_mo"]}
     ${feature}   Set Variable  l2QoSEnabled
     &{param_list_1}   create dictionary    l2SwiId=1
     &{param_list_2}   create dictionary    Layer 2 QoS Enabled=true
     selenium_coam.add_object  Ethernet Services instance identifier   ETHSVC   L2SWI   ${param_list_1}   Save
     selenium_coam.add_element   MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1   Layer 2 QoS Enabled   ${param_list_2}
     wait until keyword succeeds  3 times   5s   selenium_coam.set_parameter_value  ${dist_name_bronze}   ${bronze}   false
     Bronze PDL Validate Return Error Check   feature=${feature}   uclap_def=${uclap_def}

NRDU_Validate
     ${uclap_def}   Set Variable   ${feature_flag_def["bronze_mo"]}
     ${feature}   Set Variable  actPCMDReporting
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}    filter_param=Activate PCMD report    new_value=true
     selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1   object_class_name=NRCTRLTSDU
     ...    plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1/NRCTRLTSDU-1   object_class_name=NRMTRACEDU
     ...    plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     ${release_info}   Get gnb release
     Run Keyword If   '${release_info}' == '5G20A'
     ...    selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
     ...    filter_param=New Radio Trace collector entity distinguished name     new_value=1
     ...    ELSE   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
     ...    filter_param=New Radio Trace Collector Entity identifier     new_value=1
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
     ...    filter_param=Activate PCMD reporting    new_value=true
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_bronze}   new_value=false
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_silver}   new_value=false
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_gold}   new_value=false
     Bronze PDL Validate Return Error Check   feature=${feature}   uclap_def=${uclap_def}

TOP_Validate
     ${uclap_def}   Set Variable   ${feature_flag_def["bronze_mo"]}
     ${feature}   Set Variable  TOPP
     selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1   object_class_name=TOP
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1   filter_param=ToP domain number   new_value=1
     selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1   object_class_name=TOPP
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
#     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1  filter_param=Top Master identifier
#     ...   new_value=1
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_bronze}   new_value=false
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_silver}   new_value=false
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_gold}   new_value=false
     Bronze PDL Validate Return Error Check   feature=${feature}   uclap_def=${uclap_def}

IpSecEnabled_Validate
     ${uclap_def}   Set Variable   ${feature_flag_def["bronze_mo"]}
     ${feature}   Set Variable  ipSecEnabled
     ${local_ip}=   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}    filter_param=Primary IPv4 address reference
     selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1   object_class_name=IPAPP
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPAPP-1   object_class_name=IPSECC
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1     filter_param=IPsec enabling switch
     ...   new_value=true
     selenium_coam.add_object  object_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1      object_class_name=IKEP
     ...   plan_to_copy_from=${plan_copy_from}   is_load_default_values=${false}
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IKEP-1
     ...   filter_param=Local IPsec tunnel endpoint IP address    new_value=${local_ip}
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IKEP-1
     ...   filter_param=Remote IPsec tunnel endpoint IP address or FQDN   new_value=10.10.10.10
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_bronze}   new_value=false
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_silver}   new_value=false
     selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS_ID}/${dist_name}   filter_param=${dist_name_gold}   new_value=false
     Bronze PDL Validate Return Error Check   feature=${feature}   uclap_def=${uclap_def}

set parameters bandwidth
    [Arguments]    ${bandwidth}=60MHz
    ${return_celltype}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...   filter_param=${NRcelltype}
    FOR   ${index}    IN RANGE    ${cell_numbers}
         Run Keyword If   '${return_celltype}'!='8DL4UL'  selenium_coam.set_parameter_value
         ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index+1}    filter_param=${NRcelltype}   new_value=8DL4UL
         ${return_bandwidth}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index+1}
          ...   filter_param=${channel_band}
         Run Keyword If   '${return_bandwidth}'!='${bandwidth}'
         ...   Modify Bandwidth Parameters   band_width=${bandwidth}  index=${index+1}
    END
    ${flag}   run keyword if   '${return_celltype}'=='8DL4UL' and '${return_bandwidth}'=='${bandwidth}'   set variable   false
    ...   ELSE   set variable   true
    run keyword if   '${flag}'=='true'   selenium_coam.validate_plan
    sleep    5s
    run keyword if   '${flag}'=='true'    selenium_coam.activate_plan   activate_plan_despite_errors=${True}
    sleep    4min
    Run Keyword And Ignore Error   selenium_coam.logout
    Wait Until Keyword Succeeds   15min   3min   Check gnb Detect   gnb_addr=${asik_addr}
    Wait Until Keyword Succeeds   5 min   1 min  COAM WEBUI Login
    ...   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    selenium_coam.disable_screen_lock
    ${start_view}   selenium_coam.start_up_view_window_exists
    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
    ${return_bandwith}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...   filter_param=${channel_band}
    Should Be Equal   ${return_bandwith}   ${bandwidth}

Check SWEM Report bandwidth
     [Arguments]    ${chbw}=${band_width}
     wait until keyword succeeds     3x     1min
     ...   Download SWEM Report as CSV    report_type=detailed  report_title=SWEM for SRAN CM
     ${value}   Get Licensed Capacity Via CSV   sales_item=SR000024   report_type=detailed
     ${value}   Convert To Number   ${value}
     ${value}   Convert To Integer   ${value}
     COAM Login
     ${bts_info}   coam.get_bts_info   connection=COAM   timeout=10
     ${cell_list}   Run Keyword If   'requestMessage' in @{bts_info}
     ...   Set Variable   ${bts_info['requestMessage']['cells']['nr']}
     ...   ELSE   Set Variable   ${bts_info['cells']['nr']}
     ${cell_numbers}    get length    ${cell_list}
     ${expect_value}    set variable   ${${chbw.split('M')[0]}/20}
     ${expect_value}   Convert To Number   ${expect_value}
     ${expect_value}    convert to integer    ${expect_value}
#     ${expect_value}    convert to string     ${expect_value}
     ${expect_value}=    Evaluate    ${cell_numbers}*${expect_value}
     should be equal   ${value}   ${expect_value}
     COAM Logout

modify The Bandwith
    ${return_bandwidth}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...   filter_param=${channel_band}
    Run Keyword If   '${return_bandwidth}'!='${band_width2}'   Modify Bandwidth Parameters   band_width=40MHz   index=1
    ${flag}   run keyword if   '${return_bandwidth}'=='40MHz'   set variable   false
    ...   ELSE   set variable   true
    run keyword if   '${flag}'=='true'   selenium_coam.validate_plan
    sleep    5s
    run keyword if   '${flag}'=='true'    selenium_coam.activate_plan   activate_plan_despite_errors=${True}
    sleep    4min
    Run Keyword And Ignore Error   selenium_coam.logout
    Wait Until Keyword Succeeds   15min   3min   Check gnb Detect   gnb_addr=${asik_addr}
    Wait Until Keyword Succeeds   5 min   1 min  COAM WEBUI Login
    ...   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    selenium_coam.disable_screen_lock
    ${start_view}   selenium_coam.start_up_view_window_exists
    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
    ${return_bandwith}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...   filter_param=${channel_band}
    Should Be Equal   ${return_bandwith}   40MHz

set parameters beam
    [Arguments]   ${index}
#    Run Keyword If   '${return_celltype}'!='8DL4UL'  selenium_coam.set_parameter_value
#    ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}   filter_param=${NRcelltype}   new_value=8DL4UL
#    ${return_beam_set}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
#    ...   filter_param=${Basic_Beam_Set}
     _Modify_beam_Parameters_all_cell
    ${flag}   run keyword if   '${return_celltype}'=='8DL4UL' and '${return_beam_set}'=='beamSet_8'   set variable
    ...   false   ELSE   set variable   true
    run keyword if   '${flag}'=='true'   selenium_coam.validate_plan
    sleep    5s
    run keyword if   '${flag}'=='true'    selenium_coam.activate_plan   activate_plan_despite_errors=${True}
    sleep    4min
    Run Keyword And Ignore Error   selenium_coam.logout
    Wait Until Keyword Succeeds   15min   3min   Check gnb Detect   gnb_addr=${asik_addr}
    Wait Until Keyword Succeeds   5 min   1 min  COAM WEBUI Login
    ...   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    selenium_coam.disable_screen_lock
    ${start_view}   selenium_coam.start_up_view_window_exists
    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
    ${return_beamvalue}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELLGRP-${index-1}
    ...   filter_param=${numberOfTransmittedSsBlocks}
    Should Be Equal   ${return_beamvalue}   8 beams

Check SWEM Report beam
    [Arguments]   ${cell_numbers}    ${beam_license}=2
    wait until keyword succeeds     3x     1min
    ...   Download SWEM Report as CSV    report_type=detailed    report_title=SWEM for SRAN CM
    ${value}   Get Licensed Capacity Via CSV   sales_item=SR000025   report_type=detailed
    ${value}   Convert To Number     ${value}
    ${value}   Convert To Integer   ${value}
    ${expect_value}=    Evaluate    ${cell_numbers}*${beam_license}
    should be equal   ${value}   ${expect_value}

modify The Beam
    [Arguments]   ${index}
    ${return_beam_set}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
    ...   filter_param=${Basic_Beam_Set}
    Run Keyword If   '${return_beam_set}'!='beamSet_4'   Modify beam Parameters   beam_value=4   index=${index}
    ${flag}   run keyword if   '${return_beam_set}'=='beamSet_4'   set variable   false
    ...   ELSE   set variable   true
    run keyword if   '${flag}'=='true'   selenium_coam.validate_plan
    sleep    5s
    run keyword if   '${flag}'=='true'    selenium_coam.activate_plan   activate_plan_despite_errors=${True}
    sleep    4min
    Run Keyword And Ignore Error   selenium_coam.logout
    Wait Until Keyword Succeeds   15min   3min   Check gnb Detect   gnb_addr=${asik_addr}
    Wait Until Keyword Succeeds   5 min   1 min  COAM WEBUI Login
    ...   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    selenium_coam.disable_screen_lock
    ${start_view}   selenium_coam.start_up_view_window_exists
    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
    ${return_beamvalue}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELLGRP-${index-1}
    ...   filter_param=${numberOfTransmittedSsBlocks}
    Should Be Equal   ${return_beamvalue}   4 beams

set parameters power
    [Arguments]   ${index}
    ${return_celltype}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
    ...   filter_param=${NRcelltype}
    Run Keyword If   '${return_celltype}'!='8DL4UL'  selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}   filter_param=${NRcelltype}   new_value=8DL4UL
    ${return_power}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
    ...   filter_param=${output power_ban}
    Run Keyword If   '${return_power}'!='35 (dBm)'   Modify power Parameters   pmax_value=${power_value2}   index=${index}
    ${flag}   run keyword if   '${return_celltype}'=='8DL4UL' and '${return_power}'=='35 (dBm)'   set variable   false
    ...   ELSE   set variable   true
    run keyword if   '${flag}'=='true'   selenium_coam.validate_plan
    sleep    5s
    run keyword if   '${flag}'=='true'    selenium_coam.activate_plan   activate_plan_despite_errors=${True}
    sleep    4min
    Run Keyword And Ignore Error   selenium_coam.logout
    Wait Until Keyword Succeeds   15min   3min   Check gnb Detect   gnb_addr=${asik_addr}
    Wait Until Keyword Succeeds   5 min   1 min  COAM WEBUI Login
    ...   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    selenium_coam.disable_screen_lock
    run keyword and ignore error
    ...   Wait Until Keyword Succeeds   3 min   1 min   selenium_coam.close_start_up_view_window
    ${return_power}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
    ...   filter_param=${output power_ban}
    ${match}   run keyword and return status  Should Match Regexp    ${return_power.split(' ')[0]}   .*35.*
    should be true   ${match}

Check SWEM Report power
    [Arguments]   ${cell_numbers}     ${trp_license}=2
    wait until keyword succeeds     3x     1min
    ...    Download SWEM Report as CSV    report_type=detailed    report_title=SWEM for SRAN CM
    ${value}   Get Licensed Capacity Via CSV   sales_item=SR000026   report_type=detailed
    ${value}   Convert To Number    ${value}
    ${value}   Convert To Integer   ${value}
    ${expect_value}=    Evaluate    ${cell_numbers}*${trp_license}
    should be equal   ${value}   ${expect_value}

modify The Power
    [Arguments]   ${index}
    ${return_power}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
    ...   filter_param=${output power_ban}
    Run Keyword If   '${return_power}'!='26 (dBm)'   Modify power Parameters   pmax_value=${power_value}   index=${index}
    ${flag}   run keyword if   '${return_power}'=='26 (dBm)'   set variable   false
    ...   ELSE   set variable   true
    run keyword if   '${flag}'=='true'   selenium_coam.validate_plan
    sleep    5s
    run keyword if   '${flag}'=='true'    selenium_coam.activate_plan   activate_plan_despite_errors=${True}
    sleep    4min
    Run Keyword And Ignore Error   selenium_coam.logout
    Wait Until Keyword Succeeds   15min   3min   Check gnb Detect   gnb_addr=${asik_addr}
    Wait Until Keyword Succeeds   5 min   1 min  COAM WEBUI Login
    ...   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    selenium_coam.disable_screen_lock
    ${start_view}   selenium_coam.start_up_view_window_exists
    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
    ${return_power}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${index}
    ...   filter_param=${output power_ban}
    ${match}   run keyword and return status  Should Match Regexp    ${return_power.split(' ')[0]}   .*26.*
    should be true   ${match}
