*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB013048
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Resource    resources/CB013048_resources.robot
Variables   resources/parameter_list.py

Suite Setup       Custom suite setup
Suite Teardown    Common suite teardown
Test Setup        CB013048 Test setup
Test Teardown     CB013048 Test teardown

*** Variables ***
${SW_DOWNLOAD_PATH}    /home/ute/.ute-ca/cache/bts

*** Test Cases ***
[1][1.0] CB013048_fault_triggering_for_MCC_MNC_marking
    Set MCC to 001 to trigger antithieft alarm
    Set MCC to 404 to clear antithieft alarm

*** Keywords ***
Set MCC to 001 to trigger antithieft alarm
    Log to console    Delta commisioning MCC 001 to trigger alarm
    ${delta_status}    Set MCC parameter by delta commissioning    delta=${delta_mcc_001}
    gnb_alarm.Allow alarm    Suspicious unit detection
    Run keyword if    ${delta_status}==${False}
    ...               Fail
    ...               Delta commissioning to MCC 001 failed
    Wait until keyword succeeds    360 sec
    ...                            10 sec
    ...                            Verify alarm 'Suspicious unit detection' is active on gNB
    Verify all cells are disabled
    Verify antithieft marked MCC

Set MCC to 404 to clear antithieft alarm
    Log to console    Delta commissioning MCC 404 to clear alarm
    ${delta_status}    Set MCC parameter by delta commissioning    delta=${delta_mcc_404}
    Run keyword if    ${delta_status}==${False}
    ...               Fail
    ...               Delta commissioning to MCC 404 failed
    Wait until keyword succeeds    360 sec
    ...                            10 sec
    ...                            gnbcell.Verify All Cells are OnAir
    gnb_alarm.Disallow alarm    Suspicious unit detection
    Verify alarm 'Suspicious unit detection' is not active on gNB
    Verify antithieft marked MCC

CB013048 Test setup
    Common preconditions with watching alarms    verify_mandatory_scf_params=${False}
    Verify alarm 'Suspicious unit detection' is not active on gNB

CB013048 Test teardown
    gnbbbu.Disconnect
    Common postconditions with watching alarms
    [Teardown]    Perform full commissioning on gNB
    ...           scf_file=testsuite/Krakow/SISO/regression/RAN_PZ_KRK2/CB013048/resources/scf/SCF_MCC_001.xml

Verify alarm 'Suspicious unit detection' is not active on gNB
    Verify alarm is not active on gNB    fault_name=Suspicious unit detection
    ...                                  fault_id=4795
    ...                                  alarm_id=7116
    ...                                  severity=Critical

Verify antithieft marked MCC
    Verify gNB configuration parameters have expected values    param_dict=${rmod_mcc}
