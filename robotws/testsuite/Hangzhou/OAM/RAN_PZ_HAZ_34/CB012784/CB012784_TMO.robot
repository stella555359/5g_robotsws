*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource    ./Resource/Common.robot
Variables   ./Config/formula_tmo.py
Variables   ./Config/formula_error.py

Suite Setup         CB012784 Common Suite Setup
Suite Teardown      CB012784 Common Suite Teardown


*** Test Cases ***
CB012784_Classical_KPI_triggering_faults_TMOUS_SMOD
    [Setup]   CB012784 Common Case Setup

    FOR   ${trigger_formula_parameter}   IN   @{ALL_TRIGGERINGFORMULA_PARAMETER_LIST_SMOD}
        Log To Console   ${trigger_formula_parameter}

        ${fault_list}   Get Variable Value   ${trigger_formula_parameter["fault_list"]}
        ${counter_ids}   Get Variable Value   ${trigger_formula_parameter["counter_ids"]}
        ${triggering_formula}   Get Variable Value   ${trigger_formula_parameter["triggering_formula"]}

        ${counter_report}   COAM Check Specific PM Counter List   counter_ids=${counter_ids}
        Continue For Loop If   not ${counter_report}

        COAM Update Trigger Formula Parameters   triggering_formula=${triggering_formula}
        COAM Enable KPI Trigger Flag
        Sleep   1m

        Wait Until Keyword Succeeds   5m   1m   COAM Check Fault List   fault_list=${fault_list}

        COAM Remove Trigger Formula Parameters
        Sleep   10s
        COAM Check Fault List Clear   fault_list=${fault_list}

    END

    [Teardown]   CB012784 Common Case Teardown


CB012784_Classical_KPI_triggering_faults_TMOUS_RMOD
    [Setup]   CB012784 Common Case Setup

    FOR   ${trigger_formula_parameter}   IN   @{ALL_TRIGGERINGFORMULA_PARAMETER_LIST_RMOD}
        Log To Console   ${trigger_formula_parameter}

        ${fault_list}   Get Variable Value   ${trigger_formula_parameter["fault_list"]}
        ${counter_ids}   Get Variable Value   ${trigger_formula_parameter["counter_ids"]}
        ${triggering_formula}   Get Variable Value   ${trigger_formula_parameter["triggering_formula"]}

        ${counter_report}   COAM Check Specific PM Counter List   counter_ids=${counter_ids}
        Continue For Loop If   not ${counter_report}

        COAM Update Trigger Formula Parameters   triggering_formula=${triggering_formula}
        COAM Enable KPI Trigger Flag
        Sleep   1m

        Wait Until Keyword Succeeds   5m   1m   COAM Check Fault List   fault_list=${fault_list}

        COAM Remove Trigger Formula Parameters
        Sleep   10s
        COAM Check Fault List Clear   fault_list=${fault_list}

    END

    [Teardown]   CB012784 Common Case Teardown


CB012784_Classical_KPI_triggering_faults_TMOUS_Formula_Evaluation_Error
    [Setup]   CB012784 Common Case Setup

    ${status}   ${info}   Run Keyword And Ignore Error
    ...   COAM Update Trigger Formula Parameters   triggering_formula=${ALL_ERROR_TRIGGERING_FORMULA_PARAMETER}
    Log To Console   ${status}
    Log To Console   ${info}

    ${obsolete}   ${result}   Split String   ${info}   Status reached:
    FOR   ${trigger_formula}   IN   @{ALL_ERROR_TRIGGERINGFORMULA_LIST}
        Should Contain   ${result}   ${trigger_formula}
    END

    [Teardown]   CB012784 Common Case Teardown
