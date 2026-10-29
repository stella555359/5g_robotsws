*** Settings ***
Documentation    Test suite for RMOD cells bandwidth configuration with specific test plans
Library    Collections
Library    String
Library    OperatingSystem
Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning          WITH NAME   gnb_scf

*** Variables ***
${RMOD7}                       RMOD-7
${RMOD8}                       RMOD-8
${RMOD9}                       RMOD-9
@{cell_ids}                    1    2    3    4    5    6    7    8    9    10    11    12
${init_cells_count}
${vm_delay}                    ${60}    # delay in seconds
# Test Plan Templates
${TEST_PLAN_16DL8UL_100Mhz_1}  Step1_AEHC-Cell7-Rmod1-16DL8UL-100Mhz_plan.json
${TEST_PLAN_16DL8UL_100Mhz}    Step2_AEHC-Cell8-Rmod2-16DL8UL-100Mhz_plan.json
${TEST_PLAN_8DL8UL_100Mhz}     Step3_AEHC-Cell9-Rmod3-8DL8UL-100Mhz_plan.json
${TEST_PLAN_16DL4UL_90Mhz}     Step4_AEHC-Cell10-Rmod1_16DL4UL-90Mhz_plan.json
${TEST_PLAN_8DL4UL_90Mhz}      Step5_AEHC-Cell11-Rmod1_8DL4UL-90Mhz_plan.json
${TEST_PLAN_4DL4UL_90Mhz}      Step6_AEHC-Cell12-Rmod3-4DL4UL-90Mhz_plan.json

*** Keywords ***
Step 1: Configure First Cell on RMOD-7
    [Documentation]    Configure first cell with 16DL8UL, 100MHz on RMOD-7
    # The feature is activated by default starting from load:
    ${Step}    Set Variable    1
    Add New Cell Configuration and Verify    ${Step}    ${RMOD7}    16    8    100    7    ${TEST_PLAN_16DL8UL_100Mhz_1}

Step 2: Add Second Cell on RMOD-8
    [Documentation]    Add cell with 16DL8UL, 100MHz on RMOD-8
    ${Step}    Set Variable    2
    Add New Cell Configuration and Verify    ${Step}    ${RMOD8}    16    8    100    8    ${TEST_PLAN_16DL8UL_100Mhz}

Step 3: Add Third Cell on RMOD-9
    [Documentation]    Add cell with 8DL8UL, 100MHz on RMOD-9
    ${Step}    Set Variable    3
    Add New Cell Configuration and Verify    ${Step}    ${RMOD9}    8    8    100    9    ${TEST_PLAN_8DL8UL_100Mhz}

Step 4: Add Fourth Cell on RMOD-7
    [Documentation]    Add cell with 16DL4UL, 90MHz on RMOD-7
    ${Step}    Set Variable    4
    Add New Cell Configuration and Verify    ${Step}    ${RMOD7}    16    4    90    10    ${TEST_PLAN_16DL4UL_90Mhz}

Step 5: Add Fifth Cell on RMOD-8
    [Documentation]    Add cell with 8DL4UL, 90MHz on RMOD-8
    ${Step}    Set Variable    5
    Add New Cell Configuration and Verify    ${Step}    ${RMOD8}    8    4    90    11    ${TEST_PLAN_8DL4UL_90Mhz}

Step 6: Add Sixth Cell on RMOD-9
    [Documentation]    Add cell with 4DL4UL, 90MHz on RMOD-9
    ${Step}    Set Variable    6
    Add New Cell Configuration and Verify    ${Step}    ${RMOD9}    4    4    90    12    ${TEST_PLAN_4DL4UL_90Mhz}

Add New Cell Configuration and Verify
    [Arguments]    ${Step}    ${rmod}    ${dl}    ${ul}    ${bandwidth}    ${cell_id}    ${test_plan}
    [Documentation]    Creates cell configuration with specified parameters and test plan
    ${start_point_timestamp}=    utilities.Get Local Timestamp
    ${bts_start_point_timestamp}=    bts_utilities.get_bts_utc_current_time
    Run Keyword And Continue On Failure  gnb_log.Start Collecting gNB Btslog
    ${test_plan}=    Set Variable    ${CURDIR}/../config/${SBTS_BRANCH}/${test_plan}
    Add Cell Configuration    ${rmod}    ${dl}    ${ul}    ${bandwidth}    ${cell_id}    ${test_plan}
    BuiltIn.sleep    90 sec
    Run Keyword And Continue on Failure   Wait Until Keyword Succeeds  5 min  5 sec  gnbcell.Verify All Cells Are Onair
    ${local_dir}=    Set Variable    ${res_path}/Step${Step}
    ${path_to_current_scf}    Save Current SCF Plan    ${local_dir}    ${test_plan}
    ${result}    ${syslog_file_path}    Run Keyword And Ignore Error  gnb_log.Stop Collecting gNB Btslog  log_dir=${local_dir}
    set suite variable    ${syslog_file_path}    ${syslog_file_path}
    Run Keyword And Ignore Error  Collect IMS File  ${local_dir}/IMS2/
    ${cells_count}    Evaluate    ${init_cells_count} + ${Step}
    Verify Total Cell Count    ${cells_count}
    Log    Verifying test plan application for step ${Step}
    Verify Test Plan Application Scenario    ${cell_id}    ${bts_start_point_timestamp}

Add Cell Configuration
    [Arguments]    ${rmod}    ${dl}    ${ul}    ${bandwidth}    ${cell_id}    ${test_plan}
    [Documentation]    Creates cell configuration with specified parameters and test plan
    Log    Creating cell ${cell_id} on ${rmod} with ${dl}DL${ul}UL, ${bandwidth}MHz using test plan ${test_plan}
    # Add actual configuration commands here
    Run Keyword and Ignore Error    Apply Test Plan    ${cell_id}    ${test_plan}    skip_parameter_relation_errors=${True}

Apply Test Plan
    [Arguments]    ${cell_id}    ${test_plan}    ${skip_parameter_relation_errors}=${False}
    [Documentation]    Applies specific test plan to the cell
    Log    Applying test plan ${test_plan} to cell ${cell_id}
    gnb_scf.perform_bts_delta_json_commissioning    delta_file=${test_plan}    bts_id=0
    ...     du_id=0     skip_parameter_relation_errors=${skip_parameter_relation_errors}    should_activate=${true}    timeout=${60}

Verify Test Plan Application Scenario
    [Arguments]   ${cells_id}    ${start_point_timestamp}
    [Documentation]    Verifies that test plan was properly applied
    ${nrcells_json_path}=     ims_analyzer.Save NRCElls Infos    ${ims_file_path}
    # check that the previews cells scenario from active to initialized to active
    ${cells_count}    Evaluate    ${cells_id}
    ${prv_cells_count}    Evaluate    ${cells_count} - 1
    ${prev_cells_count_passed}    ${result}    ims_analyzer.check_nrcell_scenario    ${nrcells_json_path}
    ...    ${cell_ids[:${prv_cells_count}]}
    ...    expected_scenario_name=active_to_initialized_to_active
    ...    start_point_timestamp=${start_point_timestamp}
    ...   end_point_timestamp=${None}
    ...   delay=${vm_delay}
    Log    nrcell check cells status scenario for ${cell_ids[:${prv_cells_count}]}::: ${result}
    # check that the new cells scenario from not initialized to active
    ${new_cells_count_passed}    ${result}    ims_analyzer.check_nrcell_scenario    ${nrcells_json_path}
    ...    ${cell_ids[${prv_cells_count}:${cells_count}]}
    ...    expected_scenario_name=not_initialized_to_active
    ...    start_point_timestamp=${start_point_timestamp}
    ...   end_point_timestamp=${None}
    ...   delay=${vm_delay}
    Log    nrcell check cells status scenario for ${cell_ids[${prv_cells_count}:${cells_count}]}::: ${result}
    ${alarms_json_path}=     ims_analyzer.Save Alarm Infos    ${ims_file_path}
    ${alarms_check_passed}    ${result}    ims_analyzer.Check Raized Alarm    ${alarms_json_path}
    ...    expected_alarms=@{empty}
    ...    alarm_to_ignor=@{empty}
    ...    start_point_timestamp=${start_point_timestamp}
    ...    end_point_timestamp=${None}
    Log    not expected alarms ::: ${result}
    # Should Be True    ${prev_cells_count_passed} and ${new_cells_count_passed}

Initialize Configuration For test
    [Documentation]    Activates the configuration and triggers DU/gNB restart
    ...    The faeture is activated by default starting from load
    ...    Insteed of the keyword will trigger only DU/gNB restart
    [Arguments]    ${test_plan}
    Log    Feature is Activated by default ! triggering DU/gNB restart
    ${test_plan}=    Set Variable    ${CURDIR}/../config/${SBTS_BRANCH}/${test_plan}
    run keyword and ignore error    gnb_scf.perform_bts_delta_json_commissioning
    ...     delta_file=${test_plan}
    ...     bts_id=0    du_id=0     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${180}
    Run Keyword And Continue on Failure   Wait Until Keyword Succeeds  12 min  5 sec  gnbcell.Verify All Cells Are Onair

Reset Configuration for Test
    [Documentation]    Reset test configuration DU/gNB restart
    ...    The faeture is activated by default
    Log    Feature is Activated by default ! triggering DU/gNB restart
    run keyword and ignore error    gnb_scf.perform_bts_full_commissioning
    ...     scf_file=${PATH_Storage}/initial_conf_scf.xml
    ...     bts_id=0    du_id=0     skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${300}
    ...    validate_scf=${True}
    Run Keyword And Continue on Failure   Wait Until Keyword Succeeds  12 min  5 sec  gnbcell.Verify All Cells Are Onair

Verify CB013288 Activation
    [Documentation]    Verifies that CB013288 is activated
    Log    The feature CB013288 is activated by default.
    # Get the parameter value from SCF
    ${feature_status}=    scf_utilities.Get SCF Parameter Value    NRBTS.actBbPoolTddFr1
    ${prb_pooling_extension}=    scf_utilities.Get SCF Parameter Value    NRBTS.actBbPoolExtensionTddFr1
    ${prb_pooling_Enh}=    scf_utilities.Get SCF Parameter Value    NRBTS.actBbPoolTddFr1Enh
    ${prb_large_pooling_Fr1}=    scf_utilities.Get SCF Parameter Value    NRBTS.actLargeBbPoolTddFr1

    # Verify the parameter value is correct
    Should Be Equal    ${feature_status}    true
    Should Be Equal    ${prb_pooling_extension}    true
    Should Be Equal    ${prb_pooling_Enh}    true
    Should Be Equal    ${prb_large_pooling_Fr1}    true

    # Log the result
    Log    Feature CB013288 activation status: ${feature_status}


Verify Total Cell Count
    [Arguments]    ${expected_count}
    [Documentation]    Verifies the total number of configured cells
    ...    it sould be equal to the expected count
    Log    Verifying total cell count is ${expected_count}
    ${bts_info}    gnbbbu.get_bts_info
    ${online_nrcells_count}    Get Online NRCELL Count    ${bts_info}
    ${configured_nrcell_count}    Get Configured NRCELL Count    ${bts_info}
    Should Be Equal As Numbers    ${online_nrcells_count}    ${configured_nrcell_count}
    Should Be Equal As Numbers    ${online_nrcells_count}    ${expected_count}

Verify PoolInfo
    [Arguments]    ${syslog_file_path}    ${patterns_lis}    ${expected_colums}
    [Documentation]    Verifies the pool info
    Log    Verifying pool info
    ${output_file}=    files_operations.extract_poolid_data_to_csv    ${syslog_file_path}    grep_patterns=${patterns_lis}
    ${pool_info}=      files_operations.get_unique_counts    ${output_file}    ${expected_colums}
    Log    pool info : ${pool_info}
    Should Be Equal As Integers    ${pool_info}[poolId]    1

Step 1: Delete Cell 12 from RMOD-9
    [Documentation]    Delete Cell 12 from RMOD-9
    ${Step}    Set Variable    1
    Remove Cell Configuration and Verify    ${Step}    ${RMOD9}    12    Step6_AEHC-Cell12-Rmod3-4DL4UL-90Mhz_reverse_plan.json

Step 2: Delete Cell 11 from RMOD-8
    [Documentation]    Delete Cell 11 from RMOD-8
    ${Step}    Set Variable    2
    Remove Cell Configuration and Verify    ${Step}    ${RMOD8}    11    Step5_AEHC-Cell11-Rmod1_8DL4UL-90Mhz_reverse_plan.json

Step 3: Delete Cell 10 from RMOD-7
    [Documentation]    Delete Cell 10 from RMOD-7
    ${Step}    Set Variable    3
    Remove Cell Configuration and Verify    ${Step}    ${RMOD7}    10    Step4_AEHC-Cell10-Rmod1_16DL4UL-90Mhz_reverse_plan.json

Step 4: Delete Cell 9 from RMOD-9
    [Documentation]    Delete Cell 9 from RMOD-9
    ${Step}    Set Variable    4
    Remove Cell Configuration and Verify    ${Step}    ${RMOD9}    9    Step3_AEHC-Cell9-Rmod3-8DL8UL-100Mhz_reverse_plan.json

Step 5: Delete Cell 8 from RMOD-8
    [Documentation]    Delete Cell 8 from RMOD-8
    ${Step}    Set Variable    5
    Remove Cell Configuration and Verify    ${Step}    ${RMOD8}    8    Step2_AEHC-Cell8-Rmod2-16DL8UL-100Mhz_reverse_plan.json

Remove Cell Configuration and Verify
    [Arguments]    ${Step}    ${rmod}    ${cell_id}    ${reverse_plan}
    [Documentation]    Delete cell from test plan and verify the application
    ${start_point_timestamp}=    utilities.Get Local Timestamp
    ${bts_start_point_timestamp}=    bts_utilities.get_bts_utc_current_time
    Run Keyword And Continue On Failure  gnb_log.Start Collecting gNB Btslog
    ${reverse_plan}=    Set Variable    ${CURDIR}/../config/${SBTS_BRANCH}/${reverse_plan}
    Delete Cell Configuration    ${rmod}    ${cell_id}    ${reverse_plan}
    BuiltIn.sleep    90 sec
    Run Keyword And Continue on Failure   Wait Until Keyword Succeeds  5 min  5 sec  gnbcell.Verify All Cells Are Onair
    ${local_dir}=    Set Variable    ${res_path}/DeleteStep${Step}
    ${path_to_current_scf}    Save Current SCF Plan    ${local_dir}    ${reverse_plan}
    ${result}    ${syslog_file_path}    Run Keyword And Ignore Error  gnb_log.Stop Collecting gNB Btslog  log_dir=${local_dir}
    set suite variable    ${syslog_file_path}    ${syslog_file_path}
    Run Keyword And Ignore Error  Collect IMS File  ${local_dir}/IMS2/
    ${cells_count}    Evaluate    ${init_cells_count} - ${Step}
    Verify Total Cell Count    ${cells_count}
    Log    Vérification de l'application du plan de suppression pour l'étape ${Step}
    Verify Test Plan Application Scenario    ${cell_id}    ${bts_start_point_timestamp}

Delete Cell Configuration
    [Arguments]    ${rmod}    ${cell_id}    ${reverse_plan}
    [Documentation]    Delete Cell Configuration
    Log    Suppression de la cellule ${cell_id} sur ${rmod} en utilisant le plan ${reverse_plan}
    Run Keyword and Ignore Error    Apply Test Plan    ${cell_id}    ${reverse_plan}    skip_parameter_relation_errors=${True}

CB013288-B Test Suite Setup
    [Documentation]   Prepare TL for CB013288-B test
    ...    - Turn all DUs, RUs, TestLine, PDU Power Position to on
    ...    - Backup TL configurations
    ...    - Validate Initial SCF
    ...    - Activate Energy Efficiency Monitoring
    ...    - Backup SBTS Configuration
    ...    - Validate current test SCF
    ...    - Collect Active Alarms and check for warnings
    ...    - Install Wireshark Plugin if necessary
    ...    - Install 5G TTI trace tools
    # Turn all DUs RUs TestLine PDU Power Position To   on
    Test Suite Preparation
    Activating Energy Effecency Monitoring
    Validate SCF Plan    ${PATH_Storage}/initial_conf_scf.xml


CB013288-B Test Suite Teardown
    [Documentation]    This keyword is for CB013288 test suite teardown
    # Run Keyword And Ignore Error    Deactivate Feature CB013288-B
    Reset Configuration for Test
    Test Suite Teardown
²