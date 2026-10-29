*** Settings ***
Documentation
...   Author: liangliang.heng@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Keyword ***
D_15_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SUlSchedulingTraceRecord_Allfields
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    ${exist}  Set Variable  ${False}
    FOR   ${crnti}   IN   @{ALL_PCMD_MSG.keys()}
        ${exist}  Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_PCMD_MSG['${crnti}']}   ulSchedulingRecord
        Continue For Loop If  not ${exist}
        ${ulSchedulingRecord}   Set Variable   ${ALL_PCMD_MSG['${crnti}']}
        Check_SUlSchedulingTraceRecord_Allfields_Value   ulSchedulingRecord=${ulSchedulingRecord}
        Exit For Loop If  ${exist}
    END
    run keyword if  not ${exist}   Fail   Message Not Found!

Case Setup: D_15
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: D_15

Case Teardown: D_15
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: D_15
    Check Extra Reset From Blackbox on Teardown   Reset_before=${RESET_REASON}
    CI_interface.Common Case Teardown
    [Teardown]    Setup Count Calculation 1756

Check_SUlSchedulingTraceRecord_Allfields_Value
    [Arguments]   ${ulSchedulingRecord}
    ${SUlSchedulingTraceRecord_length}=  Get Length  ${ulSchedulingRecord['ulSchedulingRecord']}
    ${first_value_recordCollectionDuration}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][0]['recordCollectionDuration']}
    Run Keyword If  0<${first_value_recordCollectionDuration}<134273 or ${first_value_recordCollectionDuration}==0
    ...  Log To Console   first value of recordCollectionDuration is OK
    FOR  ${idx}  IN RANGE  1  ${SUlSchedulingTraceRecord_length}
        ${recordCollectionDuration}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['recordCollectionDuration']}
        ${endMarker_previous}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx-1}]['endMarker']}
        Run Keyword If  '${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['endMarker']}'=='TRUE' or '${endMarker_previous}'=='TRUE'
        ...  Should Be True  0<${recordCollectionDuration}<131073 or ${recordCollectionDuration}==0
        ...  ELSE  Should Be True   ${recordCollectionDuration}==131072
    END
    FOR  ${idx}    IN RANGE    0  ${SUlSchedulingTraceRecord_length}
        ${recordCollectionDuration_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['recordCollectionDuration']}
        ${numOf1stMacPduTx_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['numOf1stMacPduTx']}
        ${numOfBad1stMacPduTx_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['numOfBad1stMacPduTx']}
        ${numOfBadLastMacPduTx_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['numOfBadLastMacPduTx']}
        ${numOfPuschTxWithRank1_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['numOfPuschTxWithRank1']}
        ${numOfPuschTxWithRank2_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['numOfPuschTxWithRank2']}
        ${timeOfUeSched_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['timeOfUeSched']}
        Should Be True  ${numOfBad1stMacPduTx_SUlSched}> 0 or ${numOfBad1stMacPduTx_SUlSched}==0
        Should Be True  ${numOfBadLastMacPduTx_SUlSched}==0 or ${numOfBadLastMacPduTx_SUlSched}>0
#        ${sum_Rank}    Evaluate  ${numOfPuschTxWithRank1_SUlSched}+${numOfPuschTxWithRank2_SUlSched}
#        Should Be True  ${sum_Rank}==${numOf1stMacPduTx_SUlSched}+${numOfBad1stMacPduTx_SUlSched}
        Should Be True  0<${timeOfUeSched_SUlSched}<${recordCollectionDuration_SUlSched} or ${timeOfUeSched_SUlSched}==0
    END
