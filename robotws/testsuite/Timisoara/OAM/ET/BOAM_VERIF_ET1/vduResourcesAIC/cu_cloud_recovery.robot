*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_oam_state.robot




*** Variables ***



*** Keywords ***
CU Restart All VMs By SSH
    [Arguments]  ${gnb_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]    CU Restart Master VM
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
    ${alias}  Get Unique Id
    CU SSH To OAM   gnb_index=${gnb_index}    alias=${alias}
    ${out}   issh.Execute   command=dvmcli -r cluster   check_result=${False}   alias=${alias}


CU Get Master VM Index
    [Arguments]  ${gnb_index}=0   ${vm_type}=oam
    [Documentation]    CU Get Master VM Index
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...    | vm_type   | no | vm type, can be oam, cpif,cpcl,cpnb,cpnrt,cpue,db and upue, default is oam |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | ${master_vm_index} | CU Get Master VM Index| vm_type=oam |
    ...    | ${master_vm_index} | CU Get Master VM Index| gnb_index=0 | vm_type=cpif |
    ...
    ${vm_type}  Set Variable  ${vm_type.upper()}
    ${master_vm_index}   Set Variable  0
    [Return]  ${master_vm_index}
