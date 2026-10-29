*** Settings ***
Documentation
...    author: Agata Sidlo
...    contact: agata.sidlo@nokia.com

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/l3_call/call_manager.robot
Library     taf/rfrl/bts/devices/du/commissioning.py
Library     taf/rfrl/bts/devices/du/du_operations.py
Library     ./resources/common_keywords.py

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    resources/variables.py


Suite Setup         Common Suite Setup With Commissioning And Swconfig Flag    CB010971-D-B2
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions
Test Teardown       Common Postconditions

*** Variables ***
@{additional_allowed_alarms}
...    Serial console activated
...    Diagnostic Files collected

*** Test Cases ***
Ethernet mode reconfiguration during BTS runtime
    Verify Link Speed Value    value=eCpri10
    Perform Bts Delta Commissioning    delta=${delta_ecpri25}    adjust_dist_name=${bool_false}    timeout=${int_500}
    Activate Plan
    Log To Console    Link speed changed to ecpri25
    Wait For Site To Be Onair
    Verify Link Speed Value    value=eCpri25

    Perform Bts Delta Commissioning    delta=${delta_ecpri10}    adjust_dist_name=${bool_false}    timeout=${int_500}
    Activate Plan
    Log To Console    Link speed changed to ecpri10
    Wait For Site To Be Onair
    Verify Link Speed Value    value=eCpri10

*** Keywords ***
Common Suite Setup With Commissioning And Swconfig Flag
    [Arguments]    ${prefix_tag}
    Set Swconfig Flag And reset Bts
    Common Suite Setup With Commissioning    prefix_tag=${prefix_tag}
