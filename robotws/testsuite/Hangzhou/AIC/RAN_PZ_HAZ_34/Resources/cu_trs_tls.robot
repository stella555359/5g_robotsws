*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_trs_tls.robot



*** Variables ***



*** Keywords ***
Change oamTls Value On vCU
    [Arguments]   ${oamTls}=off
    [Documentation]   Change oamTls value On vCU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
	...   | oamTls |   Yes   | The target value of oamTls|
	...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | ${change_result} | Change oamTls Value On vCU  | forced |
    ...   | Log To Console | Do something here... |
    ...   | VCU Online Restore Parameters | ${change_result} |
    ...
    ...   | ${change_result} | Change oamTls Value On vCU  | off |
    ...   | Log To Console | Do something here... |
    ...   | VCU Online Restore Parameters | ${change_result} |
    ...
    ${vcu_conf}    Get VCU Conf From SCF
    ${para_list}   Create List      oamTls
    ${value_list}  Create List      ${oamTls}
    ${mo_list}     Create List      MRBTS-${vcu_conf["mrbts_id"]}/MNL-1/MNLENT-1/MPLANENW-1
    CU Rest Login
    ${ret}  VCU Online Change Parameters   para_list=${para_list}  value_list=${value_list}  mo_list=${mo_list}
    [Return]  ${ret}