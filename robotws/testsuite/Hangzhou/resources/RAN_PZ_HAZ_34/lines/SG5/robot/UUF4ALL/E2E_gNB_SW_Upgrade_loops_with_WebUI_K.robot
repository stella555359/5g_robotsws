*** Settings ***
Suite Setup        cOAM Common Suite Setup
Suite Teardown     cOAM Common Suite Teardown
Test Setup         robot_common_operations.Common Case Setup
Test Teardown      Run Keywords   robot_common_operations.Common Case Teardown   Logout webui   CI_interface.Common Case Teardown
Test Timeout      180 minutes

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          Resource/SW_Upgrade_WebUI_common_KW.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.sbts.oam.coam.admin   WITH NAME   coam

Documentation
...    author: annie.hu
...    contact: annie.hu@nokia-sbell.com
...    squad group: SG_05
...    Feature Upgrade loops - WebUI  UUF4ALL


Force Tags      E2E_KDDI    SG_05

*** Variables ***


*** Test Cases ***
[1]E2E_gNB_SW_Upgrade_loops_with_WebUI
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    this case is to verify gNB can download and Rollback a new version SW build package successfully
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    [Tags]    OWNER_annie.hu@nokia-sbell.com   CRT_22R1    CRT_22R3
    Set Test Variable    ${test_round}    1
    FOR    ${count}    IN RANGE    ${test_round}
        Run Keyword And Continue On Failure    SWM supports provision SW build package via WebUI
        sleep    50s
        Run Keyword And Continue On Failure    Classical gNB Software Rollback successfully via WebUI
    END
#    Run Keyword And Continue On Failure    SWM supports provision SW build package via WebUI

*** Keywords ***



