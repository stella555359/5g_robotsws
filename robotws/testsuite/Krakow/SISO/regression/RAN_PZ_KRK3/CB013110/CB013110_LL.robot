*** Settings ***
Documentation
...   Test suite for executing cases for CB013110-LL.
...   author: Magda Chrostek
...   contact: magda.chrostek@nokia.com

Force Tags    STATE_SW_UPLOADED    CRT    SBTS00    SBTS26R1    SBTS25R3

Library       testsuite/Krakow/resources/random_oam_procedure_runner.py      WITH NAME      random
Library       taf/rfrl/csv4all/CSV4AllTestCases.py                                                WITH NAME      CSV4ALL
Library       taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations             WITH NAME      ASIR
Library       taf.rfrl.bts.commissioning                                           WITH NAME    commission
Library       testsuite/Krakow/SISO/regression/RAN_PZ_KRK3/CB013110/resources/helpers.py
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource      taf/rfrl/bts/robot/gnb.robot
Resource      testsuite/Krakow/SISO/regression/RAN_PZ_KRK3/CB013110/resources/resources.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables     testsuite/Krakow/SISO/regression/RAN_PZ_KRK3/CB013110/resources/variables.py


Suite Setup        Run Keywords
...                TL preparation
...                AND      Common Suite Setup
Suite Teardown      Suite Teardown And Ignore UTE CM Fails

Test Setup          Common Preconditions
Test Teardown       Common Postconditions And Ignore UTE CM Fails


*** Variables ***
${TOTAL_TIMEOUT}                    ${7200}
${EMAIL_NOTOFICATION_WHEN_FAIL}     ${False}
&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 custom_allowed_alarms=allowed_alarms
@{NODES}                            ${NODE1}
${OPERATIONS}      ['site_reset','reset_hub','reset_hub_via_asir_cli','reset_ant','cell_block_unblock','rat_reset']
${ITERATIONS_RESET}                 ${30}

*** Test Cases ***
[1][1.0] CB013110-F-Verification_of_fault_4526_severity_setting_case2
    ${nok_scf}     Set Variable   commissionings/Krakow/10_7_UTE4G10SK087/${release_name}/${release_name}_ASIR_NOK.xml
    ASIR.perform_asir_commissioning      ${nok_scf}    migrate_nidd=${False}
    Wait Until Keyword Succeeds   7min    1s     ASIR.verify_alarm_is_active     fault_id=4526
    ${ok_scf}     Set Variable   commissionings/Krakow/10_7_UTE4G10SK087/${release_name}/GNB0_ASIR_SCF.xml
    ASIR.perform_asir_commissioning    ${ok_scf}    migrate_nidd=${False}
    Wait Until Keyword Succeeds    7min    1s      ASIR.verify_alarm_is_not_active    fault_id=4526
    Wait to avoid timeout error
    Verify gNB is onAir

[1][1.0] CB013110-B-Reconfigure_sfn_group
    ${switch_to_5_pRRH}      Set Variable      commissionings/Krakow/10_7_UTE4G10SK087/${release_name}/${release_name}_5pRRH.xml
    ASIR.perform_asir_commissioning      ${switch_to_5_pRRH}    migrate_nidd=${False}
    ASIR.wait_for_asir_to_be_onair
    ${cell_changes_sbts}      Set Variable      commissionings/Krakow/10_7_UTE4G10SK087/${release_name}/${release_name}_GNB_Cells.xml
    ${cell_changes_asir}      Set Variable      commissionings/Krakow/10_7_UTE4G10SK087/${release_name}/${release_name}_ASIR_Cells.xml
    Perform Full Commissioning on gNB      ${cell_changes_sbts}
    Wait to avoid timeout error
    ASIR.perform_asir_commissioning     ${cell_changes_asir}     migrate_nidd=${False}
    ASIR.wait_for_asir_to_be_onair
    Wait to avoid timeout error
    Verify gNB is onAir

[1][1.0] CB013110-A-Random_oam_procedures
    [Timeout]    8h
    ${sbts_scf}      Set Variable      commissionings/Krakow/10_7_UTE4G10SK087/${release_name}/GNB0_SCF.xml
    Perform Full Commissioning on gNB      ${sbts_scf}
    ${ok_scf}     Set Variable   commissionings/Krakow/10_7_UTE4G10SK087/${release_name}/GNB0_ASIR_SCF.xml
    ASIR.perform_asir_commissioning    ${ok_scf}    migrate_nidd=${False}
    Wait to avoid timeout error
    Verify gNB is onAir
    random.run_random_oam_operations    operations=${OPERATIONS}    timeout=${TOTAL_TIMEOUT}    email_notification=${False}

[1][1.0] CB013110-B-UFF4ALL_resets
    [Timeout]    8h
    [Documentation]    Performs 30 site resets in a row and checks if executed with no additional faults.
    CSV4ALL.e2e_tl_site_reset_with_oam_kpi
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${ITERATIONS_RESET}
    ...                                     report=${False}

[1][1.0] General_SiSo_stability_with_L3Call
    FOR      ${i}      IN RANGE      1      20
    ${addr}      get_ip_address_from_ue      ${ue_addr}      ${ue_user}      ${ue_pass}
    run_tput      ${addr}
    Verify gNB is onAir
    END

*** Keywords ***
Suite Setup With OnAir Preparation And Ignore UTE CM Fails
    Run Keyword And Continue On Failure      Ignore fail with sHUB during preparation its expected that sHUB will fail

Suite Teardown And Ignore UTE CM Fails
    Run Keyword And Continue On Failure      Avoid fails with suite teardowns as keyword take suite setup status
    Log to console    Ignore fails triggered by SUITE_SETUP_STATUS variable which is set to FAIL as
    ...               sHUB is failing during preparation due to ASiR PoE Negotiation Failure (expected).

Avoid fails with suite teardowns as keyword take suite setup status
    ${result}      RUN KEYWORD WITH FATAL EXCEPTION HANDLING      Common Suite Teardown

Common Postconditions And Ignore UTE CM Fails
    Run Keyword And Continue On Failure      Avoid fails with test suite teardowns as keyword take suite setup status
    Log to console    Ignore fails triggered by SUITE_SETUP_STATUS variable which is set to FAIL as
    ...               sHUB is failing during preparation due to ASiR PoE Negotiation Failure (expected).

Avoid fails with test suite teardowns as keyword take suite setup status
    ${result}      RUN KEYWORD WITH FATAL EXCEPTION HANDLING      Common Postconditions

TL preparation
    Log to console       TL preparation starts
    power_on_all_hw_in_testline
    Wait to avoid timeout error
    ${release_name}      Get gNB Sw Release Name
    Set Suite Variable      ${release_name}
    commission.Upload swconfig on classical gnb      sw_config_path=testsuite/Krakow/SISO/regression/RAN_PZ_KRK3/CB013110/resources/asoh_swconfig.txt
    ${sbts_scf}      Set Variable      commissionings/Krakow/10_7_UTE4G10SK087/${release_name}/GNB0_SCF.xml
    Perform Full Commissioning on gNB      ${sbts_scf}
    Wait to avoid timeout error
    Download and update same SW version
    Wait to avoid timeout error
    ${ok_scf}     Set Variable   commissionings/Krakow/10_7_UTE4G10SK087/${release_name}/GNB0_ASIR_SCF.xml
    ASIR.perform_asir_commissioning    ${ok_scf}    migrate_nidd=${False}
    Wait to avoid timeout error
    Verify gNB is onAir
    Set Ue Variables
    Log to console    Ready to go.

Wait to avoid timeout error
    Sleep    10min     #for cells, to avoid timeout error

