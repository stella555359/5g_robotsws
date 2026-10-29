*** Settings ***
Documentation
...   Keywords for regression testing of feature CB008376_C
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/procedures/resources/robot/Connections.robot
Resource     taf/rfrl/bts/robot/common/gnb_scf.robot
Resource     taf/rfrl/bts/robot/common/gnb_ru.robot
Resource     taf/rfrl/bts/robot/common/gnb_bbu.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Library      taf.rfrl.utilities.logger.custom_logger                        WITH NAME     logger
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms     WITH NAME     alarm
Library      ./resources.py                                                 WITH NAME     local_resources
Variables    ./common_variables.py

*** Variables ***
${tl_config}     /home/ute/auto/testline_configuration/`uname -n | sed -r 's/(.*)-[0-9]$/\1/' | tr "-" "_"`/__init__.py

*** Keywords ***
SISO lock unlock all cells
    local_resources.action_with_cells_using_delta     action=Lock
    BuiltIn.Sleep    5s
    local_resources.action_with_cells_using_delta     action=Unlock

Start Transfer On Real UE In Specific Direction
    [Arguments]     ${direction}    ${duration}    ${tput}    ${protocol}    ${deviation}    ${cell}
    ...             ${parallel_streams}=4    ${size_packet}=1320B   ${buffer_client}=${None}
    ...             ${buffer_server}=${None}    ${interval}=1    ${qci}=${None}    ${linux_congestion}=${None}
    ...             ${alias}=UE

    ${direction_upper}    Convert To Upper Case  ${direction}
    Start Data Transfer on Real UE   dt_name=DT_${cell}_${direction_upper}    ue_alias=${alias}    direction=${direction}
    ...     protocol=${protocol}    duration=${duration}   tput=${tput}     parallel_streams=${parallel_streams}
    ...     size_packet=${size_packet}      buffer_client=${buffer_server}  buffer_server=${buffer_server}
    ...     interval=${interval}      qci=${qci}    linux_congestion=${linux_congestion}

    Check Data Transfer is Alive     dt_name=DT_${cell}_${direction_upper}
    Await Data Transfer Finish       dt_name=DT_${cell}_${direction_upper}
    Verify Average Throughput With Deviation   dt_name=DT_${cell}_${direction_upper}   tput=${tput}   deviation=${deviation}

Call to selected cells
    [Arguments]     ${CellIDs}      ${duration}     ${tc_name}     ${prepareUE}=True     ${index_run}=1
    Run Keyword If      '${prepareUE}'=='True'      Prepare Ue for L3 Call
    ...                                                                     capabilities=${capabilities}
    ...                                                                     reboot_ue=False
    ...                                                                     timeout_reboot_ue=100
    FOR     ${Cell}      IN      @{CellIDs}
        logger.log_info_to_console    ***Call for Cell ${Cell}***    log_hierarchy=${2}
        ${dist_name}            Set Variable    ${QRXLEV_PARAMS}[dist_name]
        ${parameter}            Set Variable    ${QRXLEV_PARAMS}[parameter]
        ${qrxlevmin_max}        Set Variable    ${QRXLEV_PARAMS}[qrxlevmin_max]

        Perform Configuration Parameter Recommissioning On gNB        param_value=${qrxlevmin_max}
		...                                                           param_name=${parameter}     dist_name=${dist_name}

        Wait Until Keyword Succeeds     300 sec     10 sec      ue.Attach Ue    UE
        ${tput_dl}          Set Variable    ${TPUT_MATRIX}[${Cell}][tput_dl]
        ${tput_ul}          Set Variable    ${TPUT_MATRIX}[${Cell}][tput_ul]
        ${protocol}         Set Variable    ${TPUT_MATRIX}[${Cell}][protocol]
        ${deviation_dl}     Set Variable    ${TPUT_MATRIX}[${Cell}][deviation_dl]
        ${deviation_ul}     Set Variable    ${TPUT_MATRIX}[${Cell}][deviation_ul]
        BuiltIn.Sleep    5s
        Run Keyword And Continue On Failure        Start Transfer On Real UE In Specific Direction   direction=dl
        ...                                        duration=${duration}    tput=${tput_dl}
        ...                                        protocol=${protocol}     deviation=50%      cell=${Cell}
        Run Keyword And Continue On Failure        Start Transfer On Real UE In Specific Direction   direction=ul
        ...                                        duration=${duration}     tput=${tput_ul}
        ...                                        protocol=${protocol}     deviation=5%      cell=${Cell}
        BuiltIn.Sleep    5s
        ue.Detach Ue    UE
        ${qrxlevmin_min}        Set Variable    ${QRXLEV_PARAMS}[qrxlevmin_min]
        Perform Configuration Parameter Recommissioning On gNB        param_value=${qrxlevmin_min}
		...                                                           param_name=${parameter}     dist_name=${dist_name}
#        Run Keyword And Continue On Failure         local_resources.generate_tput_graph    tput_dl=${tput_dl}
#        ...                                         tput_ul=${tput_ul}          dt_name=DT_${Cell}_
#        ...                                         file_name=${tc_name}_${Cell}_run${index_run}
    END

SiSo RF module reset from GUI
    Reset All Radio Units on gNB     timeout=${240}
    BuiltIn.Sleep    60s
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells

Perform_recommissoning
    [Arguments]     ${all_parameters_to_change}
    ${path_to_scf}    Download gNB Configuration File
    logger.log_info_to_console    Saving actual SCFC    log_hierarchy=${2}
    FOR    ${rat}    IN    @{all_parameters_to_change}
        logger.log_info_to_console    Changing parameters in BTS for specific RAT: ${rat}    log_hierarchy=${2}
        Change Parameters In Commissioning    params_to_change=${all_parameters_to_change}[${rat}]
    END
    logger.log_info_to_console    Restore proper SCFC    log_hierarchy=${2}
    Perform Full Commissioning on gNB    scf_file=${path_to_scf}     timeout=${600}
    Wait Until Keyword Succeeds     600 sec     15 sec    Verify Setup Of All Cells

Change Parameters In Commissioning
    [Arguments]     ${params_to_change}
    FOR    ${param_to_change}    IN    @{params_to_change}
        ${param_name}           Set Variable    ${param_to_change}[param_name]
        ${dist_name}            Set Variable    ${param_to_change}[dist_name]
        ${correct_value}        Set Variable    ${param_to_change}[correct_value]
        ${incorrect_value}      Set Variable    ${param_to_change}[incorrect_value]
        ${mod_type}             Set Variable    ${param_to_change}[mod_type]
        ${fault_type}           Set Variable    ${param_to_change}[fault_type]
        ${dist_name}    local_resources.adjust_dist_name    dist_name=${dist_name}
        logger.log_info_to_console    msg=Modyfication type: ${mod_type}    log_hierarchy=${3}
        Change BTS parameter
            ...   dist_name=${dist_name}
            ...   param_name=${param_name}
            ...   correct_value=${correct_value}
            ...   incorrect_value=${incorrect_value}
            ...   fault_type=${fault_type}
    END

Change BTS parameter
    [Arguments]    ${dist_name}
             ...   ${param_name}
             ...   ${correct_value}
             ...   ${incorrect_value}
             ...   ${fault_type}

    logger.log_info_to_console    Changing ${param_name} in object ${dist_name} to correct value: ${correct_value}.
    ...                           log_hierarchy=${4}
    Perform Configuration Parameter Recommissioning On gNB
        ...    dist_name=${dist_name}
        ...    param_name=${param_name}
        ...    operation=update
        ...    param_value=${correct_value}
        ...    skip_parameter_relation_errors=True
        ...    should_activate=True
        ...    timeout=300

    Wait Until Keyword Succeeds     600 sec     15 sec    Verify Setup Of All Cells

    ${maxParallelXnSetup_to_verify}=    Create Dictionary
        ...    ${param_name}=${correct_value}
    ${param_to_verify}=    Create Dictionary
        ...    ${dist_name}=${maxParallelXnSetup_to_verify}
    Verify gNB Configuration Parameters Have Expected Values
        ...    param_dict=${param_to_verify}
    logger.log_info_to_console    Changing ${param_name} in object ${dist_name} to incorrect value: ${incorrect_value}
    ...                           log_hierarchy=${4}
    ${msg}=    Run Keyword And Expect Error    AdminApiProcedureFailureException*
        ...    Perform Configuration Parameter Recommissioning On gNB
            ...    dist_name=${dist_name}
            ...    param_name=${param_name}
            ...    operation=update
            ...    param_value=${incorrect_value}
            ...    skip_parameter_relation_errors=True
            ...    should_activate=True
            ...    timeout=120

    Should Contain    ${msg}    ${fault_type}

    Verify gNB Configuration Parameters Have Expected Values
        ...    param_dict=${param_to_verify}

Set additional alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    ${default_allowed_alarms}=     alarm.get_default_allowed_alarms
    Set Test Variable     ${allowed_alarms}     ${default_allowed_alarms}
    Run keyword if    "${alarms_for_test}!=${None}"    Set additional alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Actions after test
    Remove custom allowed alarms if defined
    [Teardown]    Common Postconditions With Watching Alarms

Turn test line on
    ${power_on_cmd}=     Set Variable     ecolab_cli power_on -c ${tl_config}
    ${output}=     Run     ${power_on_cmd}
    logger.log_info_to_console     ${output}

Turn test line off
    ${power_off_cmd}=     Set Variable     ecolab_cli power_off -c ${tl_config}
    ${output}=     Run     ${power_off_cmd}
    logger.log_info_to_console     ${output}
