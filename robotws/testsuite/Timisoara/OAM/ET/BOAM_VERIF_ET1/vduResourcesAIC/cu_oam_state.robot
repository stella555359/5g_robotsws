*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_oam_state.robot




*** Variables ***



*** Keywords ***
CU Restart All VMs
    [Arguments]  ${gnb_index}=0
    [Teardown]    run keyword and ignore error  cu rest logout
    [Documentation]    CU Restart All VMs
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | CU Restart All VMs |
    ...
    ${r}  ${out}   run keyword and ignore error   CU Restart All VMs By SSH  gnb_index=${gnb_index}
    return from keyword if   "${r}"=="PASS"

    sleep  10
    cu rest login
    Reset CU By REST


CU Oam Service Should Be Ready
    [Arguments]  ${gnb_index}=0
    [Documentation]   CU Oam Service Should Be Ready
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | CU Oam Service Should Be Ready |
    ...
    CU Rest Login   gnb_index=${gnb_index}


CU Oam Service Should Not Be Ready
    [Arguments]  ${gnb_index}=0
    [Documentation]   CU Oam Service Should Be Ready
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | CU Oam Service Should Not Be Ready |
    ...
    ${r}   ${out}   Run Keyword And Ignore Error  CU Rest Login   gnb_index=${gnb_index}
    Should Be True   "${r}"=="FAIL"


Reset CU By REST
    [Arguments]  ${need_check_on_air}=${False}   ${alias}=${None}
    [Documentation]   Reset CU By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  2.1.2021, chris.l.cao@nokia-sbell.com, initialization
    ...  14.1.2022, chris.l.cao@nokia-sbell.com, add alias parameter
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | need_check_on_air    | No | need_check_on_air, default is ${False} |
    ...   | alias               | No | alias, default is ${None} |
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | CU rest login |
    ...  | Reset CU By REST |
    ...  | Reset CU By REST | need_check_on_air=${True} |
    ...  | Reset CU By REST | need_check_on_air=${True} | alias=myalias |
    ...
    log to console  Reset CU By REST...
    ${out}  cu.reset_cu  connection=${alias}
    ${error_msg}   set variable  ${out["error_message"]}
    Should Be True   """${error_msg}"""=="""${None}"""

    Run Keyword If    ${need_check_on_air}   Log To Console   Wait CU OAM down->up->on-air ...
    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  600   20s   CU Oam Service Should Not Be Ready
    Run Keyword If    ${need_check_on_air}   Log To Console   OAM is down.
    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  500   20s   CU Oam Service Should Be Ready
    Run Keyword If    ${need_check_on_air}   Log To Console   OAM is up.
    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  800s  30s   OAM Precondition Cell Should Be Onair
    Run Keyword If    ${need_check_on_air}   Log To Console   OAM is on-air.


Reset CU By Restarting Oamagent Container
    [Arguments]     ${wait_on_air}=${False}   ${wait_time}=1100  ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection    alias=${alias}
    [Documentation]   Reset CU By Restarting Oamagent Container
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | wait_on_air | No | wait_on_air, default is ${False} |
    ...   | wait_time | No | wait_time, default is 1100 seconds |
    ...   | gnb_index | No | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | CU rest login |
    ...  | Reset CU By Restarting Oamagent Container |
    ...  | Reset CU By Restarting Oamagent Container | wait_on_air=${True} |
    ...
    log to console  Reset CU By Restarting Oamagent Container ...
    CU Restart Container  pod_abbr=oamext  ctr_abbr=oamagent  gnb_index=${gnb_index}
    Sleep   120

    Run Keyword If    ${wait_on_air}   Log To Console   Wait on-air ...
    Run Keyword If    ${wait_on_air}   Wait Until Keyword Succeeds  ${wait_time}  30s   OAM Precondition Cell Should Be Onair
    Run Keyword If    ${wait_on_air}   Log To Console   OAM is on-air.

    ${container_id}   Get CU Container ID   pod_abbr=oamext   ctr_abbr=oamagent  gnb_index=${gnb_index}

