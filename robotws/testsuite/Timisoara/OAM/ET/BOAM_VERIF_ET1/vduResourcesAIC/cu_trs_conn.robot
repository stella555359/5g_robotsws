*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_trs_conn.robot
...   cu connection related KW.




*** Variables ***



*** Keywords ***
Get Sudo For VCU K8s Admin Command
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get Sudo For VCU K8s Admin Command
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...   if admin account is cbis-admin, return sudo, otherwise return ${EMPTY}
    ...
    ...    Example
    ...    | ${sudo} | Get Sudo For VCU K8s Admin Command |
    ...
    ${vcu_k8s_master_ssh_connection_info}   Get VCU K8s Admin SSH Connection Info   gnb_index=${gnb_index}
    ${sudo}   set variable if   "${vcu_k8s_master_ssh_connection_info["username"]}"=="cbis-admin"   sudo   ${EMPTY}
    [Return]   ${sudo}


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
