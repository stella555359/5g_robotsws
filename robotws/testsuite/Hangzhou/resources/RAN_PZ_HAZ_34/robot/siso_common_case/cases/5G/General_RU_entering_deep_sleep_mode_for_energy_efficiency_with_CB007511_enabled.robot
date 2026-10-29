*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/energy_efficiency.robot


*** Keywords ***
General_RU_entering_deep_sleep_mode_for_energy_efficiency_with_CB007511_enabled
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify energy efficiency power saving value
    ...    when RU is entering deep sleep mode
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.12.2023 - - Created
    ...    - 11.03.2024 - - update ticket:https://jiradc.ext.net.nokia.com/browse/LEOPARD-1863?filter=-1
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]   ${connection}=GNB_OAM   ${NRPGRP_index}=1
    Selenium Login And Disable Screen Lock
    log to console  \nDisable affected factors 5GC000430 and CB007511
    ${ru_info_list}    Get All RUs Status Info    connection=${connection}
    FOR  ${ru}  IN  @{ru_info_list}
        ${RMOD_index}   Set Variable    ${ru["ru_index"]}
        NR Feature CB007511 OFF and Check  NRPGRP_index=${NRPGRP_index}  RMOD_index=${RMOD_index}
        # NR Feature 5GC000430 can not be configured, actMicroDTXAdvanced&actMicroDTX are invisible
        # NR Feature 5GC000430 Set and Check  NRPGRP_index=${NRPGRP_index}  RMOD_index=${RMOD_index}
        NR Feature 5GC000431 ON and Check  NRPGRP_index=${NRPGRP_index}
        NR Feature CB007511 ON and Check  RMOD_index=${RMOD_index}
    END
    log to console  \n Set LbpsPeriodList  effective time with CB007511
    ${lbps_period_list}   Update Parameter LbpsPeriodList With Current Time     lbpsDuration=60
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${lbps_period_list}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    log to console  \n get the radio power value before Enable 5GC000431
    ${power_measurement_1}   Get the real time power value  object_names=RMOD    interval=15min   sample_size=${5}
    log to console  \n Wait about 300s  cell1 into disable
    Wait until keyword succeeds    7min    30s    Cell Status Info Should Be Energy Saving State    cell_index=1
    log to console  \n Wait other cells into disable
    ${cell_info_list}    Get All Cells Status Info    cell_type=nr    connection=${connection}
    ${cell_info_list}=    Evaluate    sorted($cell_info_list, key=lambda x: x['cell_index'])
    Builtin.Log    ${cell_info_list}
    FOR  ${cell}  IN  @{cell_info_list}
        Run Keyword If    ${cell["cell_index"]}==${1}     Continue For Loop
        # other cells will enter energy saving state nearly when multiple radio environment
        Run Keyword And Ignore Error    Cell Status Info Should Be Not Energy Saving State    cell_index=${cell["cell_index"]}
        Wait until keyword succeeds    7min    30s    Cell Status Info Should Be Energy Saving State    cell_index=${cell["cell_index"]}
    END
    log to console  \n get the radio power value before Enable 5GC007511 and after Enable 5GC000431
    ${power_measurement_2}   Get the real time power value  object_names=RMOD    interval=15min   sample_size=${5}
    log to console  \n Wait about 10min RU into sleep after all cell disable
    Wait until keyword succeeds    10min    30s    RU Status Info Should Be Sleep
    log to console  \n get the radio power value after RADIO into sleep
    ${power_measurement_3}   Get the real time power value  object_names=RMOD    interval=15min   sample_size=${5}
    ${p_value}    Evaluate    "%.2f" % ((${power_measurement_1}-${power_measurement_3})/${power_measurement_1})
    ${per_value}    Evaluate    ${p_value}*100
    log to console   \n Deep Sleep Power Saving Percent with idle load:${per_value}%
    should be true      0.3 <= ${p_value}
    should be true      ${power_measurement_2} > ${power_measurement_3}   msg=Deep Sleep Power Saving No Make Effect!
