*** Settings ***
Documentation
...    author: Bartosz Odziomek
...    contact: bartosz.odziomek@nokia.com

Resource      resources/CB009055_CB009472_keywords.robot

Suite Setup         Suite Setup
Suite Teardown      Suite Teardown
Test Setup          Test Setup
Test Teardown       Test Teardown

Force Tags          RF50

*** Test Cases ***
[1][1.0] CB009472_5G_TC11_L3call_tput_NRTDD_eCPRI_100MHz_LTETDD_CPRI_20MHZ_after_reset_shared_ASiR-HUB
#    Reset ASIRMOD
    asir.reset_hub
    asir.wait_for_asir_to_be_onair
    Wait Until Keyword Succeeds  5x  60s  asir.verify_status_of_asir_cells    expected_asir_cell_status=operational
    Log To Console  ===========rest hub done============
    Log To Console  ============make l3call============
    Make L3call

[1][1.0] CB009472_5G_TC04_L3call_tput_NRTDD_100MHz_eCPRI_CPRI
    [Setup]    Log to console   CB009472_5G_TC04_L3call_tput_NRTDD_100MHz_eCPRI_CPRI Setup
    Should Be Equal As Strings  ${PREV_TEST_STATUS}  PASS
    [Teardown]    Log to console    CB009472_5G_TC04_L3call_tput_NRTDD_100MHz_eCPRI_CPRI Teardown

[1][1.0] CB009055-SR_TC02_eCPRI_UE_call_timing_offset_parameters_SISO_CB006774
    [Tags]  9055
    Log To Console  ============activate feature start============
    Perform Delta Commissioning On gNB    delta=${delta_9055}
    Log To Console  =====End: activate feature Done===
    Wait Until Keyword Succeeds  5x  60s  asir.verify_status_of_asir_cells    expected_asir_cell_status=operational
    Make L3call
