*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
*** Variables ***

*** Keywords ***
General_SiSo_U-plane_Fast_C-plane_counters
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to verify RAU/RU eCPRI U-plane & Fast-C-Plane message reception NetAct/NIDD PM counters
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.02.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${miNrEcpriUpFCp}=5min
    Modify miNrEcpriUpFCp Parameters via API  miNrEcpriUpFCp=${miNrEcpriUpFCp}
    sleep  ${miNrEcpriUpFCp}
    selenium login and disable screen lock
    Check M55318 Counter    change_interval=${miNrEcpriUpFCp}
    [Teardown]  run keywords  selenium logout and close browser    AND
    ...    Modify miNrEcpriUpFCp Parameters via API  miNrEcpriUpFCp=disabled
