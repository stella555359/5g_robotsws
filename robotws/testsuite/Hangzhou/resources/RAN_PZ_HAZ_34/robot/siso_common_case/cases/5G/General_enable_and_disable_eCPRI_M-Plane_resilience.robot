*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
General_enable_and_disable_eCPRI_M-Plane_resilience
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] When the parameter is set to 0 (false), eCPRI M-Plane resilience feature is not enabled
    ...    and related configuration is not taken into use.When the parameter is set to 1 (true), eCPRI M-Plane
    ...    resilience feature is enabled and related configuration is taken into use.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 25.07.2019 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate eCPRI M-Plane Resilience    abbr=actEcpriMPlaneResilience    new_value=false
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    ${ru_ip_addr}    wait until keyword succeeds    5min    10s   Get RU IP Address    ru_index=${ru_index}
    Should Contain    ${ru_ip_addr}    172.
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate eCPRI M-Plane Resilience    abbr=actEcpriMPlaneResilience    new_value=true
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    ${ru_ip_addr2}    wait until keyword succeeds    5min    10s   Get RU IP Address    ru_index=${ru_index}
    Should be equal    ${ru_ip_addr2}    15.1.1.1
    [Teardown]    Run keywords    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND   Selenium Logout And Close Browser
