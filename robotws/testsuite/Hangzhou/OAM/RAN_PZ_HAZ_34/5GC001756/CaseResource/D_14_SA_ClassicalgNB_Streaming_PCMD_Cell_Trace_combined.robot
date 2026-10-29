*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Keyword ***
D_14_SA_ClassicalgNB_Streaming_PCMD_Cell_Trace_combined
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    ${flag}   Set Variable   ${False}
    FOR   ${crnti}   IN   @{ALL_PCMD_MSG.keys()}
        ${flag}   Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_PCMD_MSG['${crnti}']}   ulSchedulingRecord
        Exit For Loop If   ${flag}
    END
    run keyword if  not ${flag}   Fail   Message Not Found!

Case Setup: D_14
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: D_14
    Run Keyword And Ignore Error   Check Extra Reset From Blackbox

Case Teardown: D_14
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: D_14
    Check Extra Reset From Blackbox on Teardown   Reset_before=${RESET_REASON}
    CI_interface.Common Case Teardown
    [Teardown]    Setup Count Calculation 1756
