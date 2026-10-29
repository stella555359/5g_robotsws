*** Settings ***
Documentation
...   Test suite for regression testing of feature CB012530
...   author: Mateusz Bugaj, Piotr Siedlak, Przemyslaw Glod
...   contact: mateusz.bugaj@nokia.com, piotr.siedlak@nokia.com, przemyslaw.glod@nokia.com

Resource     taf/rfrl/bts/robot/gnb.robot
Resource     ./resources/common_keywords.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/common_variables.py

Suite Setup        Prepare test line
Suite Teardown     Test line teardown

*** Variables ***
${sector}                       ${4}
${output_port}                  ${1}
${output_port_to_break}         ${2}

*** Test Cases ***
CB012530_Verify_the_enriched_Fault_10_Information_after_RU_reset_per_user_request
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Ru_reset_user]
    Reset RU And Modify Switch Link     sector=${sector}       output_port_to_break=${output_port_to_break}
    ...                                 output_port=${output_port}       alarms_to_verify=${RU_Reset_User}
    Perform Asir Recommisiong With Modify Switch Link       sector=${sector}
    ...                                                     output_port_to_break=${output_port_to_break}
    ...                                                     output_port=${output_port}
    ...                                                     alarms_to_verify=${Asir_Commisioning}
    Perform SW update With Modify Switch Link       sector=${sector}      output_port_to_break=${output_port_to_break}
    ...                                             output_port=${output_port}      alarms_to_verify=${Software_update}
    [Teardown]    Actions after test
