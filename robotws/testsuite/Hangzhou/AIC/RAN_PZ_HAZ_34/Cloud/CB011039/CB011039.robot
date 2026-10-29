*** Settings ***
Force Tags    PY36
Documentation
...    Author:zhao nana
...    Contact:nana.zhao@nokia-sbell.com
...    Group: VRF_HAZ3_T02
...    Feature: CB011039

#Suite Setup         Setup Suite For Cloud

#Test Setup          Setup Test For Cloud
#Test Teardown       Teardown Test For Cloud
#Suite Teardown      Teardown Suite For Cloud
Resource          Resource/CB011039_common_keyword.robot


*** Variables ***
${ns}    cran179
${ru_index}    1

*** Test Cases ***
[1]Manual_SiSo_FM_Fail_safe_mode_fault_activation
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=2934
    Enter fail safe mode
    log to console    fail safe mode 2934 OK
    [Teardown]    run keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown
[1]Manual_SiSo_SM_Radio_unit_remote_reset_during_fail_safe_mode
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=2934
    Should Be Equal As Strings    ${FIRST_CASE_RESULT}    True

    reset_ru    ru_index=${ru_index}
    sleep    120s
    Wait until keyword succeeds    10min    30s     SG08_keywords_cloud.Expect Fault Should Present On vDU   fault_id=2934    severity=critical
    Verify Rmod Status in fail safe mode for vDU    ru_index=${ru_index}

    [Teardown]    run keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown

[1]Manual_SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=2934
	Should Be Equal As Strings    ${FIRST_CASE_RESULT}    True
#    #extract zip file    ${snapshot_path}/RU_logs/*.zip    ${snapshot_path}/RU_logs
#
#    #Cloud Collect single RU log and Download    ru_index=${ru_index}    ns=${ns}
    Verify Rmod Status in fail safe mode for vDU    ru_index=${ru_index}
    Cloud Check single RU log in Snapshot    ru_index=${ru_index}    ns=${ns}

    [Teardown]    Case_Teardown    ru_index=${ru_index}
