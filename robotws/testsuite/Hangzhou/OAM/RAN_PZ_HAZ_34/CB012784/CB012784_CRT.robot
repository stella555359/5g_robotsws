*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource    ./Resource/Common.robot
Variables   ./Config/formula_crt.py
Variables   ./Config/formula_error.py

Suite Setup         CB012784 Common Suite Setup
Suite Teardown      CB012784 Common Suite Teardown


*** Test Cases ***
CB012784_Classical_KPI_triggering_faults_Formula_Evaluation_Error
    [Setup]   CB012784 Common Case Setup

    COAM Enable KPI Trigger Flag

    ${status}   ${info}   Run Keyword And Ignore Error
    ...   COAM Update Trigger Formula Parameters   triggering_formula=${ALL_ERROR_TRIGGERING_FORMULA_PARAMETER}
    Log To Console   ${status}
    Log To Console   ${info}

    ${obsolete}   ${result}   Split String   ${info}   Status reached:
    FOR   ${trigger_formula}   IN   @{ALL_ERROR_TRIGGERINGFORMULA_LIST}
        Should Contain   ${result}   ${trigger_formula}
    END

    [Teardown]   CB012784 Common Case Teardown


CB012784_Classical_disable_actKpiAlarms
    [Setup]   CB012784 Common Case Setup

    ${index}   Set Variable   ${0}

    ${trigger_formula_parameter}   Get Variable Value   ${ALL_TRIGGERINGFORMULA_PARAMETER_LIST[${index}]}

    Log To Console   ${trigger_formula_parameter}

    ${fault_list}   Get Variable Value   ${trigger_formula_parameter["fault_list"]}
    # ${counter_ids}   Get Variable Value   ${trigger_formula_parameter["counter_ids"]}
    ${triggering_formula}   Get Variable Value   ${trigger_formula_parameter["triggering_formula"]}


    COAM Update Trigger Formula Parameters   triggering_formula=${triggering_formula}
    COAM Disable KPI Trigger Flag
    Sleep   1m

    COAM Check Fault List Clear   fault_list=${fault_list}

    [Teardown]   CB012784 Common Case Teardown


CB012784_Classical_KPI_triggering_faults_SBTS_SM_Energy_Monitoring
    [Setup]   CB012784 Common Case Setup

    ${index}   Set Variable   ${0}

    ${trigger_formula_parameter}   Get Variable Value   ${ALL_TRIGGERINGFORMULA_PARAMETER_LIST[${index}]}

    Log To Console   ${trigger_formula_parameter}

    ${fault_list}   Get Variable Value   ${trigger_formula_parameter["fault_list"]}
    ${counter_ids}   Get Variable Value   ${trigger_formula_parameter["counter_ids"]}
    ${triggering_formula}   Get Variable Value   ${trigger_formula_parameter["triggering_formula"]}

    ${counter_report}   COAM Check Specific PM Counter List   counter_ids=${counter_ids}
    Pass Execution If   not ${counter_report}   Specific PM Counter Not Report, Skip Trigger KPI Alarm.

    COAM Update Trigger Formula Parameters   triggering_formula=${triggering_formula}
    COAM Enable KPI Trigger Flag
    Sleep   1m

    Wait Until Keyword Succeeds   5m   1m   COAM Check Fault List   fault_list=${fault_list}

    COAM Remove Trigger Formula Parameters
    Sleep   10s
    COAM Check Fault List Clear   fault_list=${fault_list}

    [Teardown]   CB012784 Common Case Teardown


CB012784_Classical_KPI_triggering_faults_SBTS_SMOD_TEMPERATURE
    [Setup]   CB012784 Common Case Setup

    ${index}   Set Variable   ${1}

    ${trigger_formula_parameter}   Get Variable Value   ${ALL_TRIGGERINGFORMULA_PARAMETER_LIST[${index}]}

    Log To Console   ${trigger_formula_parameter}

    ${fault_list}   Get Variable Value   ${trigger_formula_parameter["fault_list"]}
    ${counter_ids}   Get Variable Value   ${trigger_formula_parameter["counter_ids"]}
    ${triggering_formula}   Get Variable Value   ${trigger_formula_parameter["triggering_formula"]}

    ${counter_report}   COAM Check Specific PM Counter List   counter_ids=${counter_ids}
    Pass Execution If   not ${counter_report}   Specific PM Counter Not Report, Skip Trigger KPI Alarm.

    COAM Update Trigger Formula Parameters   triggering_formula=${triggering_formula}
    COAM Enable KPI Trigger Flag
    Sleep   1m

    Wait Until Keyword Succeeds   5m   1m   COAM Check Fault List   fault_list=${fault_list}

    COAM Remove Trigger Formula Parameters
    Sleep   10s
    COAM Check Fault List Clear   fault_list=${fault_list}

    [Teardown]   CB012784 Common Case Teardown


CB012784_Classical_KPI_triggering_faults_SMOD_SFP_LANE
    [Setup]   CB012784 Common Case Setup

    ${index}   Set Variable   ${2}

    ${trigger_formula_parameter}   Get Variable Value   ${ALL_TRIGGERINGFORMULA_PARAMETER_LIST[${index}]}

    Log To Console   ${trigger_formula_parameter}

    ${fault_list}   Get Variable Value   ${trigger_formula_parameter["fault_list"]}
    ${counter_ids}   Get Variable Value   ${trigger_formula_parameter["counter_ids"]}
    ${triggering_formula}   Get Variable Value   ${trigger_formula_parameter["triggering_formula"]}

    ${counter_report}   COAM Check Specific PM Counter List   counter_ids=${counter_ids}
    Pass Execution If   not ${counter_report}   Specific PM Counter Not Report, Skip Trigger KPI Alarm.

    COAM Update Trigger Formula Parameters   triggering_formula=${triggering_formula}
    COAM Enable KPI Trigger Flag
    Sleep   1m

    Wait Until Keyword Succeeds   5m   1m   COAM Check Fault List   fault_list=${fault_list}

    COAM Remove Trigger Formula Parameters
    Sleep   10s
    COAM Check Fault List Clear   fault_list=${fault_list}

    [Teardown]   CB012784 Common Case Teardown


CB012784_Classical_KPI_triggering_faults_SMOD_SFP
    [Setup]   CB012784 Common Case Setup

    ${index}   Set Variable   ${3}

    ${trigger_formula_parameter}   Get Variable Value   ${ALL_TRIGGERINGFORMULA_PARAMETER_LIST[${index}]}

    Log To Console   ${trigger_formula_parameter}

    ${fault_list}   Get Variable Value   ${trigger_formula_parameter["fault_list"]}
    ${counter_ids}   Get Variable Value   ${trigger_formula_parameter["counter_ids"]}
    ${triggering_formula}   Get Variable Value   ${trigger_formula_parameter["triggering_formula"]}

    ${counter_report}   COAM Check Specific PM Counter List   counter_ids=${counter_ids}
    Pass Execution If   not ${counter_report}   Specific PM Counter Not Report, Skip Trigger KPI Alarm.

    COAM Update Trigger Formula Parameters   triggering_formula=${triggering_formula}
    COAM Enable KPI Trigger Flag
    Sleep   1m

    Wait Until Keyword Succeeds   5m   1m   COAM Check Fault List   fault_list=${fault_list}

    COAM Remove Trigger Formula Parameters
    Sleep   10s
    COAM Check Fault List Clear   fault_list=${fault_list}

    [Teardown]   CB012784 Common Case Teardown


CB012784_Classical_KPI_triggering_faults_RMOD_SFP
    [Setup]   CB012784 Common Case Setup

    ${index}   Set Variable   ${4}

    ${trigger_formula_parameter}   Get Variable Value   ${ALL_TRIGGERINGFORMULA_PARAMETER_LIST[${index}]}

    Log To Console   ${trigger_formula_parameter}

    ${fault_list}   Get Variable Value   ${trigger_formula_parameter["fault_list"]}
    ${counter_ids}   Get Variable Value   ${trigger_formula_parameter["counter_ids"]}
    ${triggering_formula}   Get Variable Value   ${trigger_formula_parameter["triggering_formula"]}

    ${counter_report}   COAM Check Specific PM Counter List   counter_ids=${counter_ids}
    Pass Execution If   not ${counter_report}   Specific PM Counter Not Report, Skip Trigger KPI Alarm.

    COAM Update Trigger Formula Parameters   triggering_formula=${triggering_formula}
    COAM Enable KPI Trigger Flag
    Sleep   1m

    Wait Until Keyword Succeeds   5m   1m   COAM Check Fault List   fault_list=${fault_list}

    COAM Remove Trigger Formula Parameters
    Sleep   10s
    COAM Check Fault List Clear   fault_list=${fault_list}

    [Teardown]   CB012784 Common Case Teardown


CB012784_Classical_KPI_triggering_faults_RMOD
    [Setup]   CB012784 Common Case Setup

    ${index}   Set Variable   ${5}

    ${trigger_formula_parameter}   Get Variable Value   ${ALL_TRIGGERINGFORMULA_PARAMETER_LIST[${index}]}

    Log To Console   ${trigger_formula_parameter}

    ${fault_list}   Get Variable Value   ${trigger_formula_parameter["fault_list"]}
    ${counter_ids}   Get Variable Value   ${trigger_formula_parameter["counter_ids"]}
    ${triggering_formula}   Get Variable Value   ${trigger_formula_parameter["triggering_formula"]}

    ${counter_report}   COAM Check Specific PM Counter List   counter_ids=${counter_ids}
    Pass Execution If   not ${counter_report}   Specific PM Counter Not Report, Skip Trigger KPI Alarm.

    COAM Update Trigger Formula Parameters   triggering_formula=${triggering_formula}
    COAM Enable KPI Trigger Flag
    Sleep   1m

    Wait Until Keyword Succeeds   5m   1m   COAM Check Fault List   fault_list=${fault_list}

    COAM Remove Trigger Formula Parameters
    Sleep   10s
    COAM Check Fault List Clear   fault_list=${fault_list}

    [Teardown]   CB012784 Common Case Teardown


CB012784_Classical_KPI_triggering_faults_RMOD_SFP_LANE
    [Setup]   CB012784 Common Case Setup

    ${index}   Set Variable   ${6}

    ${trigger_formula_parameter}   Get Variable Value   ${ALL_TRIGGERINGFORMULA_PARAMETER_LIST[${index}]}

    Log To Console   ${trigger_formula_parameter}

    ${fault_list}   Get Variable Value   ${trigger_formula_parameter["fault_list"]}
    ${counter_ids}   Get Variable Value   ${trigger_formula_parameter["counter_ids"]}
    ${triggering_formula}   Get Variable Value   ${trigger_formula_parameter["triggering_formula"]}

    ${counter_report}   COAM Check Specific PM Counter List   counter_ids=${counter_ids}
    Pass Execution If   not ${counter_report}   Specific PM Counter Not Report, Skip Trigger KPI Alarm.

    COAM Update Trigger Formula Parameters   triggering_formula=${triggering_formula}
    COAM Enable KPI Trigger Flag
    Sleep   1m

    Wait Until Keyword Succeeds   5m   1m   COAM Check Fault List   fault_list=${fault_list}

    COAM Remove Trigger Formula Parameters
    Sleep   10s
    COAM Check Fault List Clear   fault_list=${fault_list}

    [Teardown]   CB012784 Common Case Teardown


CB012784_Classical_KPI_triggering_faults_RMOD_FAN
    [Setup]   CB012784 Common Case Setup

    ${index}   Set Variable   ${7}

    ${trigger_formula_parameter}   Get Variable Value   ${ALL_TRIGGERINGFORMULA_PARAMETER_LIST[${index}]}

    Log To Console   ${trigger_formula_parameter}

    ${fault_list}   Get Variable Value   ${trigger_formula_parameter["fault_list"]}
    ${counter_ids}   Get Variable Value   ${trigger_formula_parameter["counter_ids"]}
    ${triggering_formula}   Get Variable Value   ${trigger_formula_parameter["triggering_formula"]}

    ${counter_report}   COAM Check Specific PM Counter List   counter_ids=${counter_ids}
    Pass Execution If   not ${counter_report}   Specific PM Counter Not Report, Skip Trigger KPI Alarm.

    COAM Update Trigger Formula Parameters   triggering_formula=${triggering_formula}
    COAM Enable KPI Trigger Flag
    Sleep   1m

    Wait Until Keyword Succeeds   5m   1m   COAM Check Fault List   fault_list=${fault_list}

    COAM Remove Trigger Formula Parameters
    Sleep   10s
    COAM Check Fault List Clear   fault_list=${fault_list}

    [Teardown]   CB012784 Common Case Teardown

