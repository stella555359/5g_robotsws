*** Settings ***
Documentation
...   Test suite for regression testing of CB013890
...   author: Przemyslaw Herian
...   contact: przemyslaw.herian@nokia.com

Resource     ./resources/robot_keywords.robot

Suite Setup          Suite Setup
Test Setup           Common Preconditions
Test Teardown        Common Postconditions
Suite Teardown       Suite Teardown

*** Test Cases ***
[1]CB013890_31_NR_1CC_10MHz_with_different_pMax_normal_traffic
    Perform Delta Commissioning On gNB          ${delta_pmax_31}
    Log to console                              \n    -- Parameter desiredpmax has been changed to 31dBm
    Sleep                                       300s
    gnbcell.Wait For All Cells To Be Onair      timeout=600
    gnbalarm.Verify Allowed Alarms              allowed_alarms=${allowed_alarms}
    gnbru.Reset radio unit                      radio_type=rmod    radio_unit_id=2
    gnbru.Reset radio unit                      radio_type=rmod    radio_unit_id=3
    gnbcell.Wait For All Cells To Be Onair      timeout=600
    Perform Delta Commissioning On gNB          ${delta_pmax_37}
    Log to console                              \n    -- Parameter desiredpmax has been changed to 37dBm
    Sleep                                       300s
    gnbcell.Wait For All Cells To Be Onair      timeout=600
    gnbalarm.Verify Allowed Alarms              allowed_alarms=${allowed_alarms}
    gnbru.Reset radio unit                      radio_type=rmod    radio_unit_id=2
    gnbru.Reset radio unit                      radio_type=rmod    radio_unit_id=3
    gnbcell.Wait For All Cells To Be Onair      timeout=600

[1][1.0] General_SiSo_Auto_Random_OAM_operations
    [Timeout]    96h
    Run Random OAM Operations       operations=${OPERATIONS}
    ...                             timeout=${TOTAL_TIMEOUT}
    ...                             email_notification=${EMAIL_NOTIFICATION_WHEN_FAIL}
    ...                             operation_kwargs=${OPERATION_KWARGS}
    ...                             random_seed=${RANDOM_SEED}
    ...                             l3_call=${L3_CALL}
    ...                             l3_call_keywords=${L3_CALL_KEYWORDS}
