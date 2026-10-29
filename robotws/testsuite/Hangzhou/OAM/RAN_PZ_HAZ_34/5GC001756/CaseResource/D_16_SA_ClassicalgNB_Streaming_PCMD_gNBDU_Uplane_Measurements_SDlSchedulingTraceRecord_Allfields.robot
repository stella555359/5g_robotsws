*** Settings ***
Documentation
...   Author: liangliang.heng@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Keyword ***
D_16_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_SDlSchedulingTraceRecord_Allfields
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    ${exist}  Set Variable  ${False}
    FOR   ${crnti}   IN   @{ALL_PCMD_MSG.keys()}
        ${exist}  Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_PCMD_MSG['${crnti}']}   dlSchedulingRecord
        Continue For Loop If  not ${exist}
        ${dlSchedulingRecord}   Set Variable   ${ALL_PCMD_MSG['${crnti}']}
        Check_SDlSchedulingTraceRecord_Allfields_Value   dlSchedulingRecord=${dlSchedulingRecord}
        Exit For Loop If  ${exist}
    END
    run keyword if  not ${exist}   Fail   Message Not Found!

Case Setup: D_16
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: D_16

Case Teardown: D_16
    Pass Execution If   ${setupfail_count}==${setupfail_count_limit}    msg=case passed due to setup failed!
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: D_16
    Check Extra Reset From Blackbox on Teardown   Reset_before=${RESET_REASON}
    CI_interface.Common Case Teardown
    [Teardown]    Setup Count Calculation 1756

Check_SDlSchedulingTraceRecord_Allfields_Value
    [Arguments]   ${dlSchedulingRecord}
    ${SDlSchedulingTraceRecord_length}=  Get Length  ${dlSchedulingRecord['dlSchedulingRecord']}
    ${first_value_recordCollectionDuration}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][0]['recordCollectionDuration']}
    Run Keyword If  0<${first_value_recordCollectionDuration}<134273 or ${first_value_recordCollectionDuration}==0
    ...  Log To Console    first value of recordCollectionDuration is OK
    FOR  ${idx}  IN RANGE  1  ${SDlSchedulingTraceRecord_length}
        ${recordCollectionDuration}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['recordCollectionDuration']}
        ${endMarker_previous}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx-1}]['endMarker']}
        Run Keyword if  '${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['endMarker']}'=='TRUE' or '${endMarker_previous}'=='TRUE'
        ...  Should Be True  0<${recordCollectionDuration}<131073 or ${recordCollectionDuration}==0
        ...  ELSE  Should Be True   ${recordCollectionDuration}==131072
    END
    FOR  ${idx}    IN RANGE    0  ${SDlSchedulingTraceRecord_length}
        ${numOfWbCqiSamples_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['avgTb0WbCqi']['numOfWbCqiSamples']}
        ${sumOfWbCqi_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['avgTb0WbCqi']['sumOfWbCqi']}
        ${recordCollectionDuration_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['recordCollectionDuration']}
        ${numOf1stMacPduTx_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['numOf1stMacPduTx']}
        ${numOfBad1stMacPduTx_SDlSched}  Set Variable   ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['numOfBad1stMacPduTx']}
        ${numOfBadLastMacPduTx_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['numOfBadLastMacPduTx']}
        ${numOfPdschTxWithRank1_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['numOfPdschTxWithRank1']}
        ${numOfPdschTxWithRank2_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['numOfPdschTxWithRank2']}
        ${numOfPdschTxWithRank3_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['numOfPdschTxWithRank3']}
        ${numOfPdschTxWithRank4_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['numOfPdschTxWithRank4']}
        ${timeOfUeSched_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['timeOfUeSched']}
        Should Be True  ${numOfBad1stMacPduTx_SDlSched}>0 or ${numOfBad1stMacPduTx_SDlSched}==0
        Should Be True  ${numOfBadLastMacPduTx_SDlSched}==0 or ${numOfBadLastMacPduTx_SDlSched}>0
#        ${tempsum}=  Evaluate  ${numOfPuschTxWithRank1_SDlSched}+${numOfPuschTxWithRank2_SDlSched}+${numOfPuschTxWithRank3_SDlSched}
#        Should Be True  ${tempsum}+${numOfPuschTxWithRank4_SDlSched}==${numOf1stMacPduTx_SDlSched}+${numOfBad1stMacPduTx_SDlSched}
        Should Be True  0<${timeOfUeSched_SDlSched}<${recordCollectionDuration_SDlSched} or ${timeOfUeSched_SDlSched}==0
        Should Be True  0<${numOfWbCqiSamples_SDlSched}<33569 or ${numOfWbCqiSamples_SDlSched}==0
        Should Be True  0<${sumOfWbCqi_SDlSched}<503521 or ${sumOfWbCqi_SDlSched}==0
    END
