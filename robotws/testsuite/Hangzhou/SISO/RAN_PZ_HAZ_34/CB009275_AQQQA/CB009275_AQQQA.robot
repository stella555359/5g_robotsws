*** Settings ***
Suite Setup          Suite Case Setup
Suite Teardown       Suite Case Teardown


Resource     Resources/CB009275_keyword.robot
Resource     Resources/CB009275_common_keyword.robot


Documentation
...    Author:Yang Liqin
...    contact:liqin.yang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB009275

Force Tags    SBTS00
...   PY36


*** Test Cases ***
#[1]07_CB009275_Feature_Disable_with_Fault_1934_actived
#  [Setup]     Test Case Setup    07_CB009275_Feature_Disable_with_Fault_1934_actived
#  [Teardown]  Test Case Teardown
#  Log To Console  CB009275 Feature Disable with Fault 1934 actived
#  CB009275 Feature Disable with Fault 1934 actived

#[1]10_CB009275_Feature_Disable_with_Fault_1933_not_raised_due_radio_temperature_not_reach_threshold
#  [Setup]  Test Case Setup  10_CB009275_Feature_Disable_with_Fault_1933_not_raised_due_radio_temperature_not_reach_threshold
#  [Teardown]  Test Case Teardown
#  [Tags]  test2
#  Log To Console  CB009275 Feature Disable with Fault 1933 not raised due radio temperature not reach_threshold
#  Feature Disable with Fault 1933 not raised due radio temperature not reach threshold

#[1]08_CB009275_Feature_Enable_with_Fault_1933_not_raised_due_radio_temperature_not_reach_threshold
#  [Setup]  Test Case Setup  08_CB009275_Feature_Enable_with_Fault_1933_not_raised_due_radio_temperature_not_reach_threshold
#  [Teardown]  Test Case Teardown
#  [Tags]  test2
#  Log To Console  Feature Enable with Fault 1933 not raised due radio temperature not reach threshold
#  Feature Enable with Fault 1933 not raised due radio temperature not reach threshold

[1]03_CB009275_Feature_Enable_with_Fault_1933_actived
  [Setup]     Test Case Setup  03_CB009275_Feature_Enable_with_Fault_1933_actived
  [Teardown]  Test Case Teardown
  [Tags]  test2
  Log To Console  Feature_Enable_with_Fault_1933_actived
  Feature Enable with Fault 1933 actived

  Make one call and detach


[1]02_CB009275_Feature_Enable_with_Fault_1932_actived
    [Tags]
    [Setup]   robot_common_operations.Common Case Setup
    ...    allowed_faults_ids=10,4590,1932,1933,1934
    Modify_actRadioFanFailureEarlyNotif_Paramater   value=false
    9275_test_trigger_1932
    wait until keyword succeeds    3x    2min   Check 1932 Alarm on RMOD

    Modify_actRadioFanFailureEarlyNotif_Paramater   value=true
    wait until keyword succeeds    3x    2min   Check 1932 Alarm on FAN_R

    ${fan_list}  Create List  0  1
    Wait Until Keyword Succeeds    3min    30s  COAM Check fan status
    ...  fans_list=${fan_list}  fan_availabilityStatus=failed  fan_operationalState=disabled


    [Teardown]  Run Keywords   Recovery Fan1 and Fan2 and clear Alarm 1932
    ...   AND  robot_common_operations.Common Case Teardown


[1]05_CB009275_Feature_Disable_with_Fault_1932_actived
    [Tags]   test
    [Setup]   robot_common_operations.Common Case Setup
	...    allowed_faults_ids=10,4590,1932,1933,1934
    Modify_actRadioFanFailureEarlyNotif_Paramater   value=true
    9275_test_trigger_1932
    wait until keyword succeeds    3x    2min   Check 1932 Alarm on FAN_R

    ${fan_list}  Create List  0  1
    Wait Until Keyword Succeeds    3min    30s  COAM Check fan status
    ...  fans_list=${fan_list}  fan_availabilityStatus=failed  fan_operationalState=disabled


    Modify_actRadioFanFailureEarlyNotif_Paramater   value=false
    wait until keyword succeeds    3x    2min   Check 1932 Alarm on RMOD

    [Teardown]  Run Keywords  Recovery Fan1 and Fan2 and clear Alarm 1932
    ...   AND   Make one call and detach
    ...   AND   robot_common_operations.Common Case Teardown


[1]09_CB009275_Feature_Enable_with_Fault_1934_not_raised_due_radio_temperature_not_reach_threshold
  [Setup]     Test Case Setup  Feature_Enable_with_Fault_1934_not_raised_due_radio_temperature_not_reach_threshold
  [Teardown]  Test Case Teardown
  [Tags]  test1
  Log To Console  Feature_Enable_with_Fault_1934_not_raised_due_radio_temperature_not_reach_threshold
  Feature Enable with Fault 1934 not raised due radio temperature not reach threshold

#[1]11_CB009275_Feature_Disable_with_Fault_1934_not_raised_due_radio_temperature_not_reach_threshold
#  [Setup]     Test Case Setup  Feature_Disable_with_Fault_1934_not_raised_due_radio_temperature_not_reach_threshold
#  [Teardown]  Test Case Teardown
#  [Tags]  test1
#  Log To Console  Feature_Disable_with_Fault_1934_not_raised_due_radio_temperature_not_reach_threshold
#  Feature Disable with Fault 1934 not raised due radio temperature not reach threshold
#
#  Make one call and detach




