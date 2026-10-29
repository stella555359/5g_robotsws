*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot

*** Keywords ***
Cloud_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to verification of RU log files which collected
    ...    from RMOD directly are align with RU fies in vDU snapshot.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Connect to vDU and collect snapshot.
    ...        2. Connect to RU and collect RU logs via command.
    ...        3. Compare the RU file list after unzipped.
    ...    - [EXPECTED RESULTS] the RU files shall be matched in RU logs and vDU snapshot.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | No arguments| NA | Check all RUs by default.|

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    * Owner: aaron.deng@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T05
    ...    *******************
    ${rmods_ids}=    Get RMOD ID List By RESTAPI
    log to console   \nget ru list...${rmods_ids}
    FOR  ${ru_index}  IN  @{rmods_ids}
        log to console    \n**** start to check RU_${ru_index} ****
        Cloud Check RU log in Snapshot    ru_index=${ru_index}
    END
