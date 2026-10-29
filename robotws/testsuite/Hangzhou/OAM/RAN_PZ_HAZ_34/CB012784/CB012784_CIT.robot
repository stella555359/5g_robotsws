*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource    ./Resource/Common.robot
Variables   ./Config/formula_cit.py

Suite Setup         CB012784 Common Suite Setup
Suite Teardown      CB012784 Common Suite Teardown


*** Test Cases ***
CB012784_KPI_triggered_alarm_and_log_collection_enhancements
    [Setup]   CB012784 Common Case Setup

    FOR   ${trigger_formula_parameter}   IN   @{ALL_TRIGGERINGFORMULA_PARAMETER_LIST}
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
