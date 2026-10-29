*** Settings ***
Resource    taf/rfrl/cbts/robot/fhgw/fhgw_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
Cloud_Manual_SiSo_REC_FHS_Reset
    [Arguments]    ${vdu_index}=0   ${gnb_index}=0    ${fhgw_index}=0    ${max_reset_time}=600
    ...   ${with_call}=${True}    ${suite_name}=default   ${test_name}=default
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to verification FHGW reset and l3call successful.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Connect to fhgw and perform fhgw reset.
    ...        2. Check vDU and all cells status shall be on air after resetting.
    ...        3. check basic l3call after all cells on air.
    ...    - [EXPECTED RESULTS] vDU and all cells status are normal; l3call success.

    ...    - [NOTE] DC mode is not supported.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The gNB index. Default value is 0. |
    ...    | fhgw_index | No | The FHGW index. Default value is 0. |
    ...    | max_reset_time | No | The maximum recovery interval from fhgw reset, unit (s). Default value is 600. |
    ...    | with_call | No | Flag for l3call. Default value is True. |
    ...    | suite_name | No | The suite name used for customed peak rate. |
    ...    | test_name | No | The test name used for customed peak rate. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 17.06.2024 - - Created
    ...    *******************
    ...    * Owner: aaron.deng@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T05
    ...    *******************
    ${fhgw_number}    fhgw_log.Get FHGW Number    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    Should Be True    ${fhgw_number} > 0    msg=No FHGW found, plz double check your TL as it tests FHGW reset.
    Log To Console    \n FHGW-${fhgw_index} Reset
    ${re_fhgwreset}   Run Keyword And Return Status    FHGW_Reset_With_Duration_Check   vdu_index=${vdu_index}
    ...    gnb_index=${gnb_index}    fhgw_index=${fhgw_index}
    ${re_duration}    Run Keyword And Return Status    Should Be True    ${duration} <= ${max_reset_time}
    ${local_fhgw_snapshot_file}   Run Keyword If  '${re_fhgwreset}'=='False' or '${re_duration}'=='False'
    ...    Run Keyword And Ignore Error    fhgw_log.Collect FHGW Snapshot Via Cli

    ${cell_index_list}   vDU Get Cell List From Webem
    Run Keyword If  ${with_call}    Run Keywords    log to console  \ncheck L3call...
    ...    AND    Cloud UE L3 Call And Throughput    cell_list=${cell_index_list}    duration=${300}
    ...    test_name=${test_name}    suite_name=${suite_name}
