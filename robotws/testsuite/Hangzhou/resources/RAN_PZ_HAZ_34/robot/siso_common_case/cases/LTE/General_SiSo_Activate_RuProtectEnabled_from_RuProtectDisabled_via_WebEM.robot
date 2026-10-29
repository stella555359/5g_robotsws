*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/bpf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/siso_resource.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py

*** Variables ***

*** Keywords ***
General_SiSo_Activate_RuProtectEnabled_from_RuProtectDisabled_via_WebEM
    [Documentation]
        ...    *****************
        ...    - [TEST PURPOSE]Verify the support RU  behaviors with activate RuProtectEnabled via WebEM
        ...    ******************
        ...    History of changes
        ...    ******************
        ...    - 7.23.2022 - - Created
        ...    *******************
        ...    yue.2.liu@nokia-sbell.com
    Disable actEcpriRuMPlaneSecurity
    Check RU connective and IPSec tunnel disable
    Enable actEcpriRuMPlaneSecurity
    Check RU connective and IPSec tunnel
    Disable actEcpriRuMPlaneSecurity
    [Teardown]   Selenium Logout And Close Browser

Disable actEcpriRuMPlaneSecurity
    log to console    Disable actEcpriRuMPlaneSecurity
    Wait Until Keyword Succeeds    2min    30s    Selenium Login
    run keyword and ignore error    selenium_coam.delete_parameter    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
        ...    filter_param=Plain text connection allowed    abbr=plainTextConnectionAllowed
    run keyword and ignore error    Validate and activate and check activate plan status
    ${modify_params}    create list
    ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    filter_param=Activate eCPRI RU M-Plane security    p_name=actEcpriRuMPlaneSecurity  value=RuProtectDisabled
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem LTE    modify_params=${modify_params}
    sleep    5min
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    sleep    30s
    [Teardown]   Selenium Logout And Close Browser

Enable actEcpriRuMPlaneSecurity
    log to console     Enable actEcpriRuMPlaneSecurity
    Wait Until Keyword Succeeds    2min    30s    Selenium Login
    ${modify_params}    create list
    ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    filter_param=Activate eCPRI RU M-Plane security    p_name=actEcpriRuMPlaneSecurity    value=RuProtectEnabled
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem LTE    modify_params=${modify_params}
    sleep    5min
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    sleep    30s
    [Teardown]   Selenium Logout And Close Browser

Selenium Login
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box

Check RU connective and IPSec tunnel
    [Arguments]   ${ru_index}=1   ${asik_alias}=ASIK Master
    log to console    Check RU connective and IPSec tunnel
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=${asik_alias}
    Connect to RU With Allocated IP LTE    ru_username=${ru_username}    ru_password=${ru_password}     ru_index=${ru_index}
    ...    asik_alias=${asik_alias}    ru_alias=RU_${ru_index}
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
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=${asik_alias}
    Connect to RU With Allocated IP LTE    ru_username=${ru_username}    ru_password=${ru_password}     ru_index=${ru_index}
    ...    asik_alias=${asik_alias}    ru_alias=RU_${ru_index}
    csn.send command    command=sudo su -c 'swanctl --list-sas'    connection=RU_${ru_index}    timeout=300
    sleep    3s
    ${result}=    csn.read output    connection=RU_${ru_index}
     should not contain    ${result}    udp
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=${asik_alias}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.disconnect    connection=RU_${ru_index}
    ...    AND    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}
