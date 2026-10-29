*** Settings ***
Documentation  Maintainers: marta.bak@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot
#Resource    ../../robotlte_legacy/SiSo_L3_Call.robot

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=             Failed    # possible settings: Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=             True      # to disable hardware reconfiguration set value False
${CELLS_YAML_PATH}=                            /home/ute/testline_configuration/10_16_UTESRANSISO095/ue_config.yaml

@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}=
...                             faultId=1300, severity=Minor

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}   common=@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}

*** Test Cases ***
[FXJB][1.0] Automated_SiSo_PM_NR_Slim_Carrier_With_Dedicated_Filters
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO095_NRslim_CB010817
    ...  AND  Set Test Variable    @{SELECTED_CELLS}    20
    ...  AND  Set Test Variable    ${slimRfFilterDL}    7.2
    ...  AND  Set Test Variable    ${slimRfFilterUL}    7.2
    ...  AND  Set Test Variable    ${ChBw}     10.0
    Execute Test In Loop  Slim Carrier L3 NR
    [Teardown]  Configuration Postcondition
