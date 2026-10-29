*** Settings ***
Documentation
...   author: Piotr Frydrych
...   maintainer: Piotr Frydrych
...   contact: piotr.frydrych@nokia.com
...   Description: Keywords for CB012346 feature


Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        testsuite/Krakow/resources/RAN_PZ_KRK8/keywords.robot
Resource        taf/rfrl/bts/robot/common/gnb_scf.robot
Resource        taf/rfrl/bts/robot/common/gnb_cell.robot
Library         taf.rfrl.procedures.resources.python.setups_and_teardowns_keywords  WITH NAME    setups_and_teardowns_keywords
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables       testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB012346/resources/parameters.py


*** Variables ***
${BTS_config}
@{CUSTOM_ALLOWED_ALARMS}        Diagnostic Files collected
...                             BTS configuration error (not enough HW for LCR)
...                             Service account root access is enabled
...                             Ethernet port security is disabled
...                             SSH enabled
...                             LMP access via port 443
${validation_error}             portsMappingToPort


*** Keywords ***
Suite Setup
    [Arguments]    ${is_asir}=${False}
    Log to console      \n-- Full Commissioning Started --\n
    Perform Full Commissioning and Wait for onAir
    ...    prefix_tag=${BTS_config}
    ...    update_timeout=1200
    ...    asir_hub=${is_asir}
    Wait until keyword succeeds      900 sec    15 sec     gnbcell.Verify All Cells Are Onair
    Log to console      \n-- Preparing Testline --\n
    Common Suite Setup
    Log To Console   \n-- Suite Setup DONE --\n

Test Setup with cells disabled
    Verify All Cell Status    cell_status=Disabled
    Log to console      \n-- Cells disabled as expected. Test Setup completed --\n

Test Setup with 2 cells disabled
    [Arguments]    ${cell1_id}    ${cell2_id}
    Wait until keyword succeeds    30 sec    10 sec
    ...    verify_cell_statuses    cell_id=${cell1_id}    availability_status=failed
    Wait until keyword succeeds    30 sec    10 sec
    ...    verify_cell_statuses    cell_id=${cell2_id}    availability_status=failed
    Log to console      \n-- 2 cells disabled as expected. Test Setup completed --\n

Test Teardown with cells disabled
    Verify All Cell Status    cell_status=Disabled
    Log to console      \n-- Cells disabled as expected. Test Teardown completed --\n
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Metadata to Report for All BTSs

Test Teardown with 2 cells disabled
    [Arguments]    ${cell1_id}    ${cell2_id}
    Wait until keyword succeeds    30 sec    10 sec
    ...    verify_cell_statuses    cell_id=${cell1_id}    availability_status=failed
    Wait until keyword succeeds    30 sec    10 sec
    ...    verify_cell_statuses    cell_id=${cell2_id}    availability_status=failed
    Log to console      \n-- 2 cells disabled as expected. Test Teardown completed --\n
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Metadata to Report for All BTSs

Perform Delta Commissioning And Expect Validation Error
    [Arguments]    ${delta}
    ${error}=    run keyword and expect error    *     Perform Delta Commissioning On gNB
    ...                                                 delta=${delta}
    should contain    ${error}      ${validation_error}
    Log to console      \n-- Validation error found as expected --\n

Perform Delta Commissioning With Validation Error
    [Arguments]    ${delta}
    Perform Delta Commissioning On gNB    delta=${delta}    skip_parameter_relation_errors=${true}
    Log to console      \n-- Delta Commissioning with expected validation error completed --\n
