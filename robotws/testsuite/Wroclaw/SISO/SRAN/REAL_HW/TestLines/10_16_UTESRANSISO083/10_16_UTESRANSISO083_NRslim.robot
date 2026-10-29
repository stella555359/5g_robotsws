*** Settings ***
Documentation  Maintainers: rafal.rokitowski@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot
#Resource    ../../robotlte_legacy/SiSo_L3_Call.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=             Failed    # possible settings: Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=             True      # to disable hardware reconfiguration set value False
${CELLS_YAML_PATH}=                            /home/ute/testline_configuration/10_16_UTESRANSISO083/cells.yaml
${SKIP_TRUCK_ROLL}

*** Test Cases ***
[AHFII][1.0]Automated_SiSo_PM_NR_Slim_Carrier_With_Dedicated_Filters
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO083_NRslim_CB010817
    ...  AND  Set Test Variable    @{SELECTED_CELLS}    61
    ...  AND  Set Test Variable    ${slimRfFilterDL}    17.5
    ...  AND  Set Test Variable    ${slimRfFilterUL}    17.5
    ...  AND  Set Test Variable    ${ChBw}     20.0
    Execute Test In Loop  Slim Carrier L3 NR
    [Teardown]  Configuration Postcondition

[AHFIG][1.0]Automated_SiSo_PM_NR_Slim_Carrier_With_Dedicated_Filters
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO083_NRslim_CB010817
    ...  AND  Set Test Variable    @{SELECTED_CELLS}    62
    ...  AND  Set Test Variable    ${slimRfFilterDL}    7.5
    ...  AND  Set Test Variable    ${slimRfFilterUL}    7.5
    ...  AND  Set Test Variable    ${ChBw}     10.0
    Execute Test In Loop  Slim Carrier L3 NR
    [Teardown]  Configuration Postcondition
