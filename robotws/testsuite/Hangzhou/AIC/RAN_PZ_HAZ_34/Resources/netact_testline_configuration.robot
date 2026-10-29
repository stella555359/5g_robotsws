*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   netact_testline_configuration.robot



*** Variables ***



*** Keywords ***
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



_Get Netact Certificate Id Name
    ${netact_conf}   Get Netact Config From Test Line
    ${ca_id}   Set Variable   ${netact_conf["ca_id"]}
    [Return]    ${ca_id}