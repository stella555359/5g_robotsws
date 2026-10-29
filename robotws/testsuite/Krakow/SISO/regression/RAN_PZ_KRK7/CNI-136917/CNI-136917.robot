*** Settings ***
Documentation
...    Test suite for regression testing for CNI-136917
...    authors: Jakub Bialon
...    group: RAN_PZ_KRK_SG_7
...    contact: jakub.bialon@nokia.com

Resource    resources/keywords.robot

Suite Setup    Common Suite Setup With OnAir Test Line Preparation
Suite Teardown    Common Suite Teardown
Test Setup    Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms

*** Test Cases ***
CNI-136917_07_ Fault_4741_Suppression_by_Fault_2929_2930
    ${fault_4741}=    Create Dictionary    alarm_id=7115
    ...                                    fault_id=4741
    ...                                    fault_name=Unstable eCPRI Link Detected
    ...                                    severity=Minor
    ${fault_16}=    Create Dictionary    alarm_id=7116
    ...                                  fault_id=16
    ...                                  fault_name=Unit synchronization failed
    ...                                  severity=Critical
    ${fault_1815}=    Create Dictionary    alarm_id=7116
    ...                                    fault_id=1815
    ...                                    fault_name=Not able to synchronize baseband bus
    ...                                    severity=Major
    ${fault_10}=    Create Dictionary    alarm_id=7116
    ...                                  fault_id=10
    ...                                  fault_name=No connection to unit
    ...                                  severity=Critical

    ${expected_alarms}=    Create List    ${fault_16}     ${fault_1815}   ${fault_10}
    gnbalarm.Allow Alarm    alarm=${expected_alarms}
    keywords.Lock Unlock SFP    SFP_id=1
    gnbbbu.Wait For Site To Be Onair
    gnbalarm.Disallow Alarm    alarm=${expected_alarms}
    ${expected_alarms}=    Create List    ${fault_4741}     ${fault_16}     ${fault_1815}
    gnbalarm.Allow Alarm    alarm=${expected_alarms}
    tools.Link Brake While
    Sleep    360s    Waiting For fid 4741
    tools.Verify Alarm Is Active In Raw Alarms History File     fault_id=4741
    tools.Trigger Fids 2929 And 2930    container=0x2018
    ...                                 ru_sn=1M203309949
    ...                                 ru_user=serviceuser
    ...                                 ru_pass=wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=
    Sleep    70s    Waiting For fids 2929 and 2930
    tools.Verify Alarm Is Active In Raw Alarms History File     fault_id=2929
    tools.Verify Alarm Is Active In Raw Alarms History File     fault_id=2930
    gnbalarm.Disallow Alarm    alarm=${expected_alarms}
    tools.Verify Alarm Is Not Active Raw Alarms History File    fault_id=4741
    tools.Disable Fids 2929 And 2930    container=0x2018
    ...                                 ru_sn=1M203309949
    ...                                 ru_user=serviceuser
    ...                                 ru_pass=wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=
