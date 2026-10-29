*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   kw_to_be_optimized.robot

Library           ./py_tool/kw_to_be_optimized_py.py
Library           ./py_tool/global_variables.py
Library           OperatingSystem
Library           taf.hw.fhgw.cli                       WITH NAME    issh

*** Variables ***

*** Keywords ***
Get FHGW Config
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Documentation]  Get FHGW Config
    ...  author: chris.l.cao@nokia-sbell.com
    ...    modified by:     <09-24-2021>, <hongysun>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...	   | fhgw_index | no | fhgw_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of FHGW config defined in __init__.py
    ...
    ...    Example
    ...    | ${fhgw_config}     | Get FHGW Config |
    ...    | ${fhgw_config}     | Get FHGW Config | vdu_index=1 |
    ...
    ${result}   ${rtn}     Run Keyword And Ignore Error
    ...   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].user_config}
    Should Be True  "${result}"=="PASS"    Please give FHGW config in __init__.py for vdu_index=${vdu_index},fhgw_index:${fhgw_index}

    ${result_extra_username}   ${extra_username}    Run Keyword And Ignore Error
    ...   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].ssh_username}

    ${result_extra_password}   ${extra_password}    Run Keyword And Ignore Error
    ...   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].ssh_password}

    ${rtn_tmp}   run keyword if   "${result_extra_username}"=="PASS"
    ...   Set To Dictionary  ${rtn["USERS"]}  admin_user_name=${extra_username}  admin_user_password_plain=${extra_password}

    ${rtn}   run keyword if   "${result_extra_username}"=="PASS"  Set To Dictionary  ${rtn}  USERS=${rtn_tmp}
    ...   ELSE  set variable  ${rtn}

    [Return]   ${rtn}


Get Netact Config From Test Line
    [Documentation]   Get Netact Config From Test Line
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   24.11.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...  Netact config
    ...
    ...    Example
    ...   | ${netact_config}  | Get Netact Config From Test Line |
    ...
    ${netact_config_source}  Get Netact Config Type From TestLine


    ${netact_config}   Run Keyword If   "${netact_config_source}"=="netact_config_source_from_init_py"   _Get Netact Config From Test Line Init.py
    Return From Keyword If   "${netact_config_source}"=="netact_config_source_from_init_py"    ${netact_config}

    ${active_netact_index}   ${active_netact}   Get Target Netact Server
    ${netact_config}  Set Variable   ${active_netact}

    [Return]    ${netact_config}


_Get Netact Config From Test Line Init.py
    [Documentation]  _Get Netact Config From Test Line Init.py
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...     netact information, type is dictionary
    ...
    ...    Example
    ...    | ${netact} | _Get Netact Config From Test Line Init.py |
    ...
    ${empty_dict}   Create Dictionary
    ${r}   ${netact_info}   Run Keyword And Ignore Error    set variable   ${tl.nms.addr}
    Return From Keyword If   "${r}"=="FAIL"                 ${empty_dict}

    ${r}  ${content_type}   Run Keyword And Ignore Error  Evaluate   isinstance(${netact_info}, dict)
    Return From Keyword If   "${r}"=="FAIL"                 ${empty_dict}
    Return From Keyword If   "${content_type}"!="${True}"    ${empty_dict}

    ${netact_info_len}  Get Length   ${netact_info}
    Return From Keyword If   ${netact_info_len}==0    ${empty_dict}

    ${keys}  Evaluate   list(${netact_info})
    ${netact}  Get From Dictionary    ${netact_info}   ${keys[0]}

    [Return]  ${netact}


Get netact Config Type From TestLine
    [Documentation]  Get netact Config Type From TestLine
    ...    *AUTHOR* hongyuan.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	  None
    ...
    ...    *RETURN VALUE*
    ...   1-Use netact config in __init__.py, 0-Use netact config in global_variable.py.
    ...   If this key is not given, default value is 1
    ...  "netact_config_source_from_init_py": "0",
    ...   return 'netact_config_source_from_init_py' if netact configuration is defined in __init__.py
    ...   else 'netact_config_source_from_global_variable_py' (it means netact configuration is defined in global_variables.py)
    ...
    ...    Example
    ...    | ${netact_config_source} | Get netact Config Type From TestLine |
    ...
    ${misc_config}   Get Misc Config From TestLine_netact
    Return From Keyword If   ${misc_config.__len__()==0}    netact_config_source_from_init_py

    ${result}  ${netact_config_source_from_init_py}    Run Keyword And Ignore Error
    ...   Set Variable  ${misc_config["netact_config_source_from_init_py"]}

    Return From Keyword If   "${result}"=="FAIL"    netact_config_source_from_init_py

    Run Keyword If   "${netact_config_source_from_init_py}"!="0" and "${netact_config_source_from_init_py}"!="1"
       ...   Fail
       ...   netact_config_source_from_init_py value should be 0 or 1, but your given value is ${netact_config_source_from_init_py}

    ${rtn}   Set Variable If   "${netact_config_source_from_init_py}"=="1"
     ...   netact_config_source_from_init_py   netact_config_source_from_global_variable_py
    [Return]  ${rtn}


Get Misc Config From TestLine_netact
    [Documentation]  Get Misc Config From TestLine_netact
    ...  author: hongyuan.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	  None
    ...
    ...    *RETURN VALUE*
    ...   return misc configuration defined in __init__.py
    ...
    ...    Example
    ...    | ${misc_config} | Get Misc Config From TestLine_netact |
    ...

    ${empty_dict}   create dictionary
    ${result}   ${config}   Run Keyword And Ignore Error    Set Variable  ${tl._misc}
    ${misc_config}  set variable if  """${result}"""=="""FAIL"""   ${empty_dict}    ${config}
    [Return]   ${misc_config}


_Get Netact Certificate File Name
    ${netact_conf}   Get Netact Config From Test Line
    ${ca_cert}   Set Variable   ${netact_conf["ca_file"]}
    #${NETACT_CA_cert}=   set variable  ${CURDIR}/nom/clab3766ca.pem
    ${NETACT_CA_cert}   OperatingSystem.Join Path   ${CURDIR}   ${ca_cert}
    [Return]    ${NETACT_CA_cert}


Get Full TestLine Name From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get Full TestLine Name From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   test line name, e.g, /home/ute/config/7_5_UTEAIC5G001T201
    ...
    ...    Example
    ...    | ${full_testline_name} |  Get Full TestLine Name From TestLine |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    [Return]  ${cfg_dir}


Set Agent Flag By TA Utility
    [Arguments]  ${agent_flag_file}
    [Documentation]   Set Agent Flag
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | Set Agent Flag |
    ...
    #${agent_flag_file}   OperatingSystem.Join Path   ${OUTPUT_DIR}   agent_flag.txt

    ${redeploy_flag}    Need Redeploy VDU
    ${redeploy_value}   Set Variable If   "${redeploy_flag}"=="${True}"   1   0
    log to console    redeploy_value:${redeploy_value}

    kw_to_be_optimized._Set Agent Flag With Content   agent_flag_file=${agent_flag_file}   redeploy=${redeploy_value}


_Set Agent Flag With Content
    [Arguments]  ${agent_flag_file}   ${redeploy}
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Set Agent Flag
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | Set Agent Flag |
    ...
    log to console  _Set Agent Flag With Content
    ${alias}   get unique id
    connect to ute locally  alias=${alias}

    ${found}   issh.is_file   ${agent_flag_file}   alias=${alias}
    should be true  ${found}

    #display old value
    ${out}  issh.Execute   command=cat ${agent_flag_file}   alias=${alias}

    #change file content
    ${out}  issh.Execute   command=echo redeploy=${redeploy} > ${agent_flag_file}    alias=${alias}

    #display new value
    ${out}  issh.Execute   command=cat ${agent_flag_file}   alias=${alias}


#Connect To UTE Locally
#    [Arguments]    ${username}=${UTE_SSH_USER_NAME}   ${password}=${UTE_SSH_PASSWORD}   ${alias}=default
#    [Documentation]   Connect To UTE Locally
#    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...    |  Input Parameters | Man. | Description |
#    ...    | username  |  no | username, default value is ${UTE_SSH_USER_NAME} |
#    ...    | password  |  no | password, default value is ${UTE_SSH_PASSWORD} |
#    ...    | alias     |  no | aliase name, default value is default |
#    ...
#    ...    *RETURN VALUE*
#    ...    None
#    ...
#    ...    Example
#    ...    | Connect To UTE Locally     |
#    ...    | ${out}                     | issh.Execute | command=ls -l |
#    ...    | disconnect interactive connection |
#    ...
#    Connect To UTE    hostname=127.0.0.1   username=${username}   password=${password}  alias=${alias}


#Connect To LTE
#    [Arguments]  ${alias}=default
#    [Documentation]    Connect To LTE
#    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...    |  Input Parameters | Man. | Description |
#    ...    | alias  |  no | aliase name, default value is default |
#    ...
#    ...    *RETURN VALUE*
#    ...    connection instance
#    ...
#    ...    Example
#    ...    | Connect To LTE          |
#    ...    | ${out} | issh.Execute | command=ls -l |
#    ...    | disconnect interactive connection     |
#    ...
#    ${lte_ssh_info}   Set Variable  ${tl.enbs[0].airscale.common_units[0].lmp_connection}
#    ${lte_oam_ip}   Set Variable  ${tl.enbs[0].oam_ip}
#    issh.Connect_To   ip=${lte_oam_ip}
#      ...   username=${lte_ssh_info.username}
#      ...   password=${lte_ssh_info.password}
#      ...   prompt=root@fct-\\S+:\\S+\\s+>
#      ...   alias=${alias}
#      ...   width=200


#Get vDU Namespace From TestLine
#    [Arguments]  ${vdu_index}=${0}   ${gnb_index}=${0}
#    [Documentation]  get vdu namespace from testline init config file
#    ...  return the value correct get from TL
#    ...  author: jianlin.zhang@nokia-sbell.com
#    ...    | Input Parameters | Man. | Description |
#    ...	   | vdu index | Yes. | the vdu index config on TL |
#    ...    *RETURN VALUE*
#    ...    namespace
#    ${vdu_namespace}=   set variable  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
#    [Return]   ${vdu_namespace}
