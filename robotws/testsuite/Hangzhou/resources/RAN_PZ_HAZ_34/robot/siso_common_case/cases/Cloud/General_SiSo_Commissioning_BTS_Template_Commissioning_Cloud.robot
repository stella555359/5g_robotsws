*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
    
*** Keywords ***
General_SiSo_Commissioning_BTS_Template_Commissioning
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check if not commissioned gNB can be correctly configured using
    ...    BTS Template, verify Managed Object Class in WebUI and update parameters via WebUI
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Commission on vCU.
    ...        2. Commission on vDU.
    ...        3. Check cell on air on vCU and vDU
    ...    - [EXPECTED RESULTS] the BTS commissioning successfully.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The gNB index. Default value is 0. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 05.15.2024  - Created
    ...    *******************
    ...    * Owner_jiayi.tang@nokia-sbell.com
    ...    * Group: VRF_HAZ3_T02
    ...    *******************

    [Arguments]    ${cu_scf_path}    ${vdu_scf_path}
    log to console  Full Commission SCF On vCU and vDU
    Cloud Full Commission    cu_scf_path=${cu_scf_path}    vdu_scf_path=${vdu_scf_path}
