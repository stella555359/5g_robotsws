*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
Cloud_Manual_SiSo_SM_RF_Module_lock_unlock
    [Arguments]   ${vdu_index}=0   ${gnb_index}=0   ${with_call}=${True}   ${suite_name}=default   ${test_name}=default    ${duration}=${60}
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to verify RU lock/unlock and l3call after revovery.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Get All Rmods Ids list.
    ...        2. Lock all radios and check status.
    ...        3. unlock all radios and check status.
    ...        4. Verify the RU recovery and Site onair and Make L3call success.
    ...    - [EXPECTED RESULTS] RU and all cells recovery and Make L3call success.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The gNB index. Default value is 0. |
    ...    | with_call | No | Flag for l3call. Default value is True. |
    ...    | suite_name | No | The suite name used for customed peak rate. Default value is default. |
    ...    | test_name | No | The test name used for customed peak rate. Default value is default. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    * Owner: aaron.deng@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T05
    ...    *******************
    log to console   \nget ru list on vDU_${vdu_index}...
    ${rmods_ids}=    Get RMOD ID List By RESTAPI
    log to console   \nlock all rus...${rmods_ids}
    Cloud Lock RUs On Specific vDU    rmod_id_list=${rmods_ids}    vdu_index=${vdu_index}
    FOR   ${rmod_id}    IN    @{rmods_ids}
        wait until keyword succeeds    5min    30s    RU Status Should Be Locked    ru_id=${rmod_id}
        ...    vdu_index=${vdu_index}
    END
    log to console   \nunlock all rus...${rmods_ids}
    Cloud Unlock RUs On Specific vDU    rmod_id_list=${rmods_ids}    vdu_index=${vdu_index}
    FOR   ${rmod_id}    IN    @{rmods_ids}
        wait until keyword succeeds    5min    30s   RU Status Should Be Unlocked    ru_id=${rmod_id}
        ...    vdu_index=${vdu_index}
    END
    log to console    \ncheck cell status should be on air on vDU_${vdu_index}...
    wait until keyword succeeds     10min    30s    All Cells Should Be Onair For One Specific vDU
    ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}

    Run Keyword If  ${with_call}  log to console  \ncheck L3call...
    ${cell_index_list}   vDU Get Cell List From Webem
    Run Keyword If  ${with_call}    Cloud UE L3 Call And Throughput    cell_list=${cell_index_list}
    ...    test_name=${test_name}    suite_name=${suite_name}   duration=${duration}
