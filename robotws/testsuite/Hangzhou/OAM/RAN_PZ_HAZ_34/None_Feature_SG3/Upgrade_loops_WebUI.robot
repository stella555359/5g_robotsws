*** Settings ***
Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup    AND
...            cOAM Common Suite Setup
##Suite Teardown     Run Keywords    robot_common_operations.Common Suite Teardown    AND
##...            step7:logout webui     AND    CI_interface.Common Case Teardown
##Test Teardown   Run Keywords    robot_common_operations.Common Case Teardown     AND
##...         Common Case Teardown    is_save_snapshot=True
Test Setup     test_case_setup    allowed_faults_ids=4589
Test Teardown    robot_common_operations.Common Case Teardown
Resource          ../common/coam_resource.robot
Resource          Resource/common_KW.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.sbts.oam.coam.admin   WITH NAME   coam

Documentation
...    author: jack.zeng
...    contact: jack.zeng@nokia-sbell.com
...    squad group: SG_03
...    Feature Upgrade loops - WebUI  UUF4ALL


*** Test Cases ***
[1.0] E2E_gNB_SW_Upgrade_loops_with_WebUI
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    this case is to verify gNB can download and Rollback a new version SW build package successfully
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    [Tags]    OWNER_jack.zeng@nokia-sbell.com   CRT_23R2    CRT_TRUNK    CRT_23R3   CRT_22R3   CRT_22R4   SBTS00
    Set Test Variable    ${test_round}    1
    FOR    ${count}    IN RANGE    ${test_round}
        Run Keyword And Continue On Failure    SWM supports provision SW build package via WebUI
        sleep    50s
        Run Keyword And Continue On Failure    Classical gNB Software Rollback successfully via WebUI
    END

E2E_gNB_SW_Upgrade_loops_with_WebUI_TL357
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    this case is to verify gNB can download and Rollback a new version SW build package successfully
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    [Tags]    OWNER_jack.zeng@nokia-sbell.com   CRT_23R2    CRT_TRUNK    CRT_23R3   CRT_22R3   CRT_22R4   SBTS00
    Set Test Variable    ${test_round}    1
    FOR    ${count}    IN RANGE    ${test_round}
        Run Keyword And Continue On Failure    SWM supports provision SW build package via WebUI
        sleep    50s
        Run Keyword And Continue On Failure    Classical gNB Software Rollback successfully via WebUI
    END
