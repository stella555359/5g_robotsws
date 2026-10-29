*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_trs_conn.robot
...   cu connection related KW.

Resource    aic_common_resources_new.robot

*** Keywords ***
Get VCU Sudo For Current User
    [Arguments]  ${alias}=default
    [Documentation]   Get VCU Sudo For Current User
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias | no | alias, default value is default  |
    ...
    ...    *RETURN VALUE*
    ...   if current login name is cbis-admin, return sudo. if current login name is root, return ${EMPTY}, otherwise return ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get VCU Sudo For Current User | alias=myalias |
    ...
    ${current_user_name}   Get Current User Name Interactively   alias=${alias}
    ${sudo}   set variable if   "${current_user_name}"=="cbis-admin"   sudo
        ...   "${current_user_name}"=="root"   ${EMPTY}
        ...   ${EMPTY}
    [Return]   ${sudo}


Get Current User Name Interactively
    [Arguments]  ${alias}=default
    [Documentation]  Get Current User Name Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    30.10.2024, iuliia.taupeka@nokia.com, KW moved from vdu_trs_conn.robot resource
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | alias       |  no | alias, defaut is default |
    ...
    ...    *RETURN VALUE*
    ...    current user name who logins K8S node
    ...
    ...    Example
    ...    | ${current_user_name} | Get Current User Name Interactively |
    ...
    ${out}   issh.Execute    command=ls -l /tmp  check_result=${False}  alias=${alias}
    ${out}   issh.Execute   command=whoami  check_result=${False}  alias=${alias}
    ${whoami_1}   Strip Prompt  ${out}
    ${whoami}    Split To Lines   ${whoami_1}
    Remove From List    ${whoami}   0
    [Return]   ${whoami}
