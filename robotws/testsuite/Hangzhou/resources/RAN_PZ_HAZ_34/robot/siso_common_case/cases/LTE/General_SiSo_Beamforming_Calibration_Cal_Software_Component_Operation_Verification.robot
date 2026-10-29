*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot
*** Variables ***

*** Keywords ***
General_SiSo_Beamforming_calibration_Cal_Software_Component_Operation_Verification
      [Documentation]
      ...    *****************
      ...    [TEST PURPOSE] Purpose of this case is to check if calibration of beamforming can be activated
      ...    ******************
      ...    History of changes
      ...    ******************
      ...    - 07.04.2022 - - Created
      ...    *******************
      ...    shufei.chen@nokia-sbell.com
      [Arguments]  ${check_time}=15    ${interval}=5
      ru_operation.Perform BTS Site Reset LTE
      Wait Until Keyword Succeeds    20min     30s     verify all cells should be onair
      log to console    sleep ${check_time}min to get beamforming calibration
      sleep  ${check_time}min
      ${check_time}    convert to number    ${check_time}
      ${interval}    convert to number    ${interval}
      ${count}    evaluate    ${check_time}/${interval}
      ${ru_index_list}    get all ru index
      FOR    ${ru_index}    IN    @{ru_index_list}
          ${tx_num}    ${rx_num}    ${time}    Get RU Beamforming Count Enhance LTE   ru_index=${ru_index}
          ...    get_count=${True}    check_time=${check_time}
      END

