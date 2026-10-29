*** Settings ***
Documentation
...   author: Piotr Frydrych
...   maintainer: Piotr Frydrych
...   contact: piotr.frydrych@nokia.com
...   Description: Test Cases for CB012346 feature


Resource    ./resources/CB012346_keywords.robot

Force Tags    CA_VRF_KRK    RF50

Suite Setup          Suite Setup    is_asir=${True}
Suite Teardown       Common Suite Teardown
Test Setup           Common Preconditions
Test Teardown        Common Postconditions

*** Test Cases ***
CB012346_TC46_LTE_RRM_Basic_User_Scenario
    [Teardown]    Test Teardown with 2 cells disabled
    ...    cell1_id=2
    ...    cell2_id=5
    Perform Delta Commissioning On gNB    delta=${strict_mode_enabled}
    Wait until keyword succeeds    60 sec    15 sec    gnbcell.Wait For All Cells To Be Onair    timeout=600
    Perform Delta Commissioning On gNB    delta=${bbModGroupTarget_changed}

CB012346_TC47_LTE_RRM_Alternate_User_Scenario
    [Setup]   Test Setup with 2 cells disabled
    ...    cell1_id=2
    ...    cell2_id=5
    Perform Delta Commissioning On gNB    delta=${override_mode_enabled}
    Wait until keyword succeeds    60 sec    15 sec    gnbcell.Wait For All Cells To Be Onair    timeout=600
