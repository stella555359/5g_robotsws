*** Settings ***
Documentation
...   Common keywords for test suite for regression testing of feature CB012530
...   author: Mateusz Bugaj, Piotr Siedlak, Przemyslaw Glod
...   contact: mateusz.bugaj@nokia.com, piotr.siedlak@nokia.com, przemyslaw.glod@nokia.com

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library      BuiltIn
Library      ./resources.py                                                                   WITH NAME  local_resources
Library      taf.rfrl.bts.commissioning                                                       WITH NAME  bts_comm
Library      taf.rfrl.utilities.logger.custom_logger                                          WITH NAME  logger
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations                   WITH NAME  asir
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms                       WITH NAME  alarm
Library      testsuite.Krakow.resources.RAN_VRF_KRK5.python.bts_operations.bts_operations     WITH NAME  bts_oper

*** Keywords ***
Modify Opt Switch Link And Check Fault
    [Arguments]     ${sector}       ${output_port_to_break}     ${output_port}      ${alarms_to_verify}
    Modify Link    sector=${sector}       output_port=${output_port_to_break}
    BuiltIn.Sleep       20s
    Wait Until Keyword Succeeds     900 sec     30 sec      local_resources.Get All Active Alarms
    ...                                                     alarms_to_verify=${alarms_to_verify}
    Modify Link    sector=${sector}       output_port=${output_port}
    BuiltIn.Sleep       60s
    Wait Until Keyword Succeeds     900 sec     30 sec      Verify Alarm is not Active on gNB
    ...                             fault_name=${alarms_to_verify}[fault_name]
    Wait Until Keyword Succeeds     900 sec     30 sec          gnbcell.Verify All Cells Are Onair

Reset RU And Modify Switch Link
    [Arguments]     ${sector}       ${output_port_to_break}     ${output_port}      ${alarms_to_verify}
    Run Keyword And Expect Error        AdminApiProcedureTimeoutException*       Reset gNB Radio Unit
    ...                                 radio_type=asirmod    radio_unit_id=3        timeout=${60}
    Modify Link    sector=${sector}       output_port=${output_port_to_break}
    BuiltIn.Sleep       60s
    Wait Until Keyword Succeeds     900 sec     30 sec      local_resources.Get All Active Alarms
    ...                                                     alarms_to_verify=${alarms_to_verify}
    Modify Link    sector=${sector}       output_port=${output_port}
    BuiltIn.Sleep       60s
    Wait Until Keyword Succeeds     900 sec     30 sec      Verify Alarm is not Active on gNB
    ...                             fault_name=${alarms_to_verify}[fault_name]
    Wait Until Keyword Succeeds     900 sec     30 sec          gnbcell.Verify All Cells Are Onair

Perform Asir Recommisiong With Modify Switch Link
    [Arguments]     ${sector}       ${output_port_to_break}     ${output_port}      ${alarms_to_verify}
    ...             ${asir_scf_path}=${path_testline_configuration}/testline_configuration/7_7_T01SK003
    ${release_ver}=     local_resources.get_sw_version_release_name
    asir.perform_asir_commissioning     scf_path=${asir_scf_path}/${release_ver}/GNB0_ASIR_SCF.xml
    Wait Until Keyword Succeeds     900 sec     30 sec          asir.verify_status_of_all_hubmods
    ...                                                         expected_statuses=${statuses_after_asir_commisioning}
    Modify Link    sector=${sector}       output_port=${output_port_to_break}
    BuiltIn.Sleep       60s
    Wait Until Keyword Succeeds     900 sec     30 sec      local_resources.Get All Active Alarms
    ...                                                     alarms_to_verify=${alarms_to_verify}
    Modify Link    sector=${sector}       output_port=${output_port}
    BuiltIn.Sleep       60s
    Wait Until Keyword Succeeds     900 sec     30 sec      Verify Alarm is not Active on gNB
    ...                             fault_name=${alarms_to_verify}[fault_name]
    Wait Until Keyword Succeeds     900 sec     30 sec          gnbcell.Verify All Cells Are Onair

Perform SW update With Modify Switch Link
    [Arguments]     ${sector}       ${output_port_to_break}     ${output_port}      ${alarms_to_verify}
    Modify Link    sector=${sector}       output_port=${output_port_to_break}
    local_resources.get_sw_version_and_download_t1_build      remove_after_update=${False}
    Modify Link    sector=${sector}       output_port=${output_port}
    Wait Until Keyword Succeeds     1500 sec     30 sec     Verify Alarm is Active on gNB
    ...                                                     fault_name=Incompatible SW version detected
    local_resources.get_sw_version_and_download_t1_build      remove_after_update=${True}
    Modify Link    sector=${sector}       output_port=${output_port_to_break}
    Wait Until Keyword Succeeds     1500 sec     30 sec      local_resources.Get All Active Alarms
    ...                                                     alarms_to_verify=${alarms_to_verify}
    Modify Link    sector=${sector}       output_port=${output_port}
    Wait Until Keyword Succeeds     900 sec     30 sec          gnbcell.Verify All Cells Are Onair

Add custom alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${additional_allowed_alarms}    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions after test
    [Arguments]
    Remove custom allowed alarms if defined
    Rollback Bts
    Wait Until Keyword Succeeds     900 sec     30 sec          gnbcell.Verify All Cells Are Onair
    [Teardown]    Common Postconditions With Watching Alarms

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    Run keyword if    "${alarms_for_test}!=${None}"    Add custom alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Prepare test line
    [Arguments]    ${scf_path}=${path_testline_configuration}/testline_configuration/7_7_T01SK003
    logger.log_info_to_console     Performing full commisioning
    Modify all links    number_of_sectors=${4}      output_port=${1}
    ${release_ver}=     local_resources.get_sw_version_release_name
    bts_comm.perform_full_commissioning_on_classical_gnb     awaiting_time=${1200}     readiness_timeout=${1200}
    ...                                                      update_timeout=${1200}     build_directory=/home/ute
    ...                                                      scf_path=${scf_path}/${release_ver}/GNB0_SCF.xml
    asir.perform_asir_commissioning     scf_path=${scf_path}/${release_ver}/GNB0_ASIR_SCF.xml
    Wait Until Keyword Succeeds     900 sec     30 sec   gnbcell.Verify All Cells Are Onair
    Common Suite Setup     check_truck_roll=${True}

Test line teardown
    Common Suite Teardown
