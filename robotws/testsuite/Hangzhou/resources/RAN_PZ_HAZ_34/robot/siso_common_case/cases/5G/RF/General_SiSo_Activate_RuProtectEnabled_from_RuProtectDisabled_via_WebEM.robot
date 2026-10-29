*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot


*** Variables ***

*** Keywords ***
General_SiSo_Activate_RuProtectEnabled_from_RuProtectDisabled_via_WebEM
    [Documentation]
        ...    *****************
        ...    - [TEST PURPOSE]Verify the support RU  behaviors with activate RuProtectEnabled via WebEM
        ...    ******************
        ...    History of changes
        ...    ******************
        ...    - 15.11.2023 - - Created
        ...    *******************
        ...    tingting.zhong@nokia-sbell.com
    selenium login and disable screen lock
    Disable actEcpriRuMPlaneSecurity
    Check RU connective and IPSec tunnel disable
    Enable actEcpriRuMPlaneSecurity
    Check RU connective and IPSec tunnel
    Disable actEcpriRuMPlaneSecurity
    [Teardown]   Selenium Logout And Close Browser

Disable actEcpriRuMPlaneSecurity
    log to console    Disable actEcpriRuMPlaneSecurity
    run keyword and ignore error    selenium_coam.delete_parameter    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
        ...    filter_param=Plain text connection allowed    abbr=plainTextConnectionAllowed
    run keyword and ignore error    Validate and activate and check activate plan status
    ${modify_params}    create list
    ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    filter_param=Activate eCPRI RU M-Plane security    p_name=actEcpriRuMPlaneSecurity  value=RuProtectDisabled
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    sleep    5min
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    sleep    30s

Enable actEcpriRuMPlaneSecurity
    log to console     Enable actEcpriRuMPlaneSecurity
    ${modify_params}    create list
    ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    filter_param=Activate eCPRI RU M-Plane security    p_name=actEcpriRuMPlaneSecurity    value=RuProtectEnabled
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    sleep    5min
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    sleep    30s

Check RU connective and IPSec tunnel
    [Arguments]   ${ru_index}=1   ${asik_alias}=ASIK Master
    log to console    Check RU connective and IPSec tunnel
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
    csn.send command    command=sudo su -c 'swanctl --list-sas'    connection=RU_${ru_index}    timeout=300
    sleep    3s
    ${result}=    csn.read output    connection=RU_${ru_index}
    should match regexp    ${result}    local.*udp.
    should match regexp    ${result}    remote.*udp.
    should match regexp    ${result}    local.*tcp.
    should match regexp    ${result}    remote.*tcp.
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=${asik_alias}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.disconnect    connection=RU_${ru_index}
    ...    AND    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}

Check RU connective and IPSec tunnel disable
    [Arguments]   ${ru_index}=1   ${asik_alias}=ASIK Master
    log to console    Check RU connective and IPSec tunnel disable
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
    csn.send command    command=sudo su -c 'swanctl --list-sas'    connection=RU_${ru_index}    timeout=300
    sleep    3s
    ${result}=    csn.read output    connection=RU_${ru_index}
     should not contain    ${result}    udp
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=${asik_alias}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.disconnect    connection=RU_${ru_index}
    ...    AND    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}
