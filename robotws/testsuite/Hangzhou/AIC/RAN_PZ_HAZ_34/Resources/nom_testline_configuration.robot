*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   nom_testline_configuration.robot



*** Variables ***



*** Keywords ***
Get Nom Certificate File Name
    [Tags]   NOM_CONFIG
    [Documentation]   Get Nom Certificate File Name
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   30.10.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   certificate file name of Target NOM server
    ...
    ...    Example
    ...   | ${nom_ca_file_name}  | Get Nom Certificate File Name |
    ...
    ${NOM_config_source}  Get NOM Config Type From TestLine
    ${nom_CA_cert_for_init_py}   Run Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"
    ...   _Get NOM Certificate File Name According To init.py
    Return From Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"    ${nom_CA_cert_for_init_py}

    ${active_nom_index}  ${active_nom}   Get Target NOM server
    ${ca_file}   Set Variable    ${active_nom["ca_file"]}
    Should Not Be Empty   ${ca_file}

    #${nom_CA_cert}   set variable  ${CURDIR}/nom/srncnms04_ca
    ${nom_CA_cert}  OperatingSystem.Join Path   ${CURDIR}    ${ca_file}
    OperatingSystem.File Should Exist   ${nom_CA_cert}
    [Return]    ${nom_CA_cert}


_Get NOM Certificate File Name According To init.py
    [Documentation]   _Get NOM Certificate File Name According To init.py
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   31.10.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   certificate file name of according to NOM definition in init.py
    ...
    ...    Example
    ...   | ${nom_CA_cert_for_init_py}  | Get NOM Certificate File Name According To init.py |
    ...
    ${nom_label}   _Get NOM Label Name According To init.py
    ${nom}   _Get NOM Server Information By Label    label=${nom_label}
    ${nom_cert_file_name}   Set Variable       ${nom["ca_file"]}
    Should Not Be Empty   ${nom_cert_file_name}
    ${nom_cert_file_name}  OperatingSystem.Join Path   ${CURDIR}    ${nom_cert_file_name}
    OperatingSystem.File Should Exist   ${nom_cert_file_name}
    [Return]    ${nom_cert_file_name}


_Get NOM Label Name According To init.py
    [Documentation]   _Get NOM Label Name According To init.py
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   31.10.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   nom label name
    ...
    ...    Example
    ...   | ${label}  | _Get NOM Label Name According To init.py |
    ...
    #in future, we can return real label according to NOM definition in __init__.py
    # Note: there may be no NOM configured in init.py, because we can configure NOM or Netact in init.py and only one of them is avaliable
    # Now, return NOM4 directly

    ${nom_lable}   Set Variable   NOM4
    [Return]  ${nom_lable}


Get Nom CA SN
    [Tags]   NOM_CONFIG
    [Documentation]   Get Nom CA SN
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   30.10.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   CA SN of Target NOM server
    ...
    ...    Example
    ...   | ${nom_ca_sn}  | Get Nom CA SN |
    ...
    ${NOM_config_source}  Get NOM Config Type From TestLine
    #Run Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"   Should Not Be Empty   ${NOM_1_CA_SN}
    ${nom_CA_sn_for_init_py}   Run Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"
    ...   _Get NOM Certificate SN According To init.py
    Return From Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"    ${nom_CA_sn_for_init_py}

    ${active_nom_index}  ${active_nom}   Get Target NOM server
    ${ca_sn}   Set Variable    ${active_nom["ca_sn"]}
    Should Not Be Empty   ${ca_sn}
    [Return]    ${ca_sn}


_Get NOM Certificate SN According To init.py
    [Documentation]   _Get NOM Certificate SN According To init.py
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   31.10.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   certificate SN according to NOM definition in init.py
    ...
    ...    Example
    ...   | ${nom_CA_sn_for_init_py}  | _Get NOM Certificate SN According To init.py |
    ...
    ${nom_label}   _Get NOM Label Name According To init.py
    ${nom}   _Get NOM Server Information By Label    label=${nom_label}
    ${nom_cert_sn}   Set Variable       ${nom["ca_sn"]}
    [Return]    ${nom_cert_sn}


Get Nom CA ID
    [Tags]   NOM_CONFIG
    [Documentation]   Get Nom CA ID
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   30.10.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   CA SN of Target NOM server
    ...
    ...    Example
    ...   | ${nom_ca_id}  | Get Nom CA ID |
    ...
    ${NOM_config_source}  Get NOM Config Type From TestLine
    ${nom_CA_id_for_init_py}   Run Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"
    ...   _Get NOM Certificate ID According To init.py
    Return From Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"    ${nom_CA_id_for_init_py}

    ${active_nom_index}  ${active_nom}   Get Target NOM server
    ${ca_id}   Set Variable    ${active_nom["ca_id"]}
    Should Not Be Empty   ${ca_id}
    [Return]    ${ca_id}


_Get NOM Certificate ID According To init.py
    [Documentation]   _Get NOM Certificate ID According To init.py
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   31.10.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   certificate SN according to NOM definition in init.py
    ...
    ...    Example
    ...   | ${nom_CA_id_for_init_py}  | _Get NOM Certificate ID According To init.py |
    ...
    ${nom_label}   _Get NOM Label Name According To init.py
    ${nom}   _Get NOM Server Information By Label    label=${nom_label}
    ${nom_cert_id}   Set Variable       ${nom["ca_id"]}
    [Return]    ${nom_cert_id}


Get Vdu Integrate To Nom Certificate File
    [Tags]   NOM_CONFIG
    [Documentation]   Get Vdu Integrate To Nom Certificate File
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   30.10.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   vdu_integrate_to_nom_certificate_file
    ...
    ...    Example
    ...   | ${vdu_integrate_to_nom_certificate_file}  | Get Vdu Integrate To Nom Certificate File |
    ...
    ${NOM_config_source}  Get NOM Config Type From TestLine
    ${vdu_integrate_to_nom_certificate_file}   Run Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"
    ...   _Get Vdu Integrate To Nom Certificate File According To init.py
    Return From Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"    ${vdu_integrate_to_nom_certificate_file}

    ${active_nom_index}  ${active_nom}   Get Target NOM server
    ${vdu_integrate_to_nom_certificate_file}   Set Variable    ${active_nom["vdu_integrate_to_nom_certificate_file"]}
    Should Not Be Empty   ${vdu_integrate_to_nom_certificate_file}

    ${rtn}  OperatingSystem.Join Path   ${CURDIR}    ${vdu_integrate_to_nom_certificate_file}
    OperatingSystem.File Should Exist   ${rtn}

    [Return]    ${rtn}


_Get Vdu Integrate To Nom Certificate File According To init.py
    [Documentation]   _Get Vdu Integrate To Nom Certificate File According To init.py
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   31.10.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...  Vdu Integrate To Nom Certificate File according to NOM definition in init.py
    ...
    ...    Example
    ...   | ${vdu_integrate_to_nom_certificate_file}  | _Get Vdu Integrate To Nom Certificate File According To init.py |
    ...
    ${nom_label}   _Get NOM Label Name According To init.py
    ${nom}   _Get NOM Server Information By Label    label=${nom_label}
    ${vdu_integrate_to_nom_certificate_file}   Set Variable       ${nom["vdu_integrate_to_nom_certificate_file"]}
    ${rtn}  OperatingSystem.Join Path   ${CURDIR}    ${vdu_integrate_to_nom_certificate_file}
    OperatingSystem.File Should Exist   ${rtn}
    [Return]    ${rtn}


Get NOM SFTP Information
    [Tags]   NOM_CONFIG
    [Documentation]   Get NOM SFTP Information
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   1.11.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   NOM SFTP Information
    ...
    ...    Example
    ...   | ${nom_sftp_information}  | Get NOM SFTP Information |
    ...
    ${NOM_config_source}  Get NOM Config Type From TestLine
    ${nom_sftp_information}   Run Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"
    ...   _Get NOM SFTP Information According To init.py
    Return From Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"    ${nom_sftp_information}

    ${active_nom_index}  ${active_nom}   Get Target NOM server
    ${ssh_ip_mask_len}   Set Variable  ${active_nom["ssh_ip_mask_len"]}
    ${ssh_ip_mask_len}   Convert To String   ${ssh_ip_mask_len}

    ${ssh_key_file_relative_path}    Set Variable   ${active_nom["ssh_key_file"]}
    ${ssh_key_file_absolute_path}    OperatingSystem.Join Path   ${CURDIR}   ${ssh_key_file_relative_path}

    ${nom_sftp_information}  Create Dictionary
    ...    pm_sftp_ip=${active_nom["pm_sftp_ip"]}
    ...    pm_sftp_username=${active_nom["pm_sftp_username"]}
    ...    pm_sftp_password=${active_nom["pm_sftp_password"]}
    ...    pm_sftp_root_path=${active_nom["pm_sftp_root_path"]}
    ...    pm_sftp_root_path_rest=${active_nom["pm_sftp_root_path_rest"]}
    ...    ssh_ip=${active_nom["main_info"].ssh_connections_info[0].addr}
    ...    ssh_ip_mask_len=${ssh_ip_mask_len}
    ...    ssh_user=${active_nom["main_info"].ssh_connections_info[0].username}
    ...    ssh_key_file=${ssh_key_file_absolute_path}

    Should Not Be Empty   ${nom_sftp_information}

    [Return]    ${nom_sftp_information}


_Get NOM SFTP Information According To init.py
    [Documentation]   _Get NOM SFTP Information According To init.py
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   1.11.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...   25.4.2022, hongysun, add ssh_key_file, ssh_ip, ssh_user paramters
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   NOM SFTP Information
    ...
    ...    Example
    ...   | ${nom_sftp_information}  | _Get NOM SFTP Information According To init.py |
    ...
    ${nom_label}   _Get NOM Label Name According To init.py
    ${nom}   _Get NOM Server Information By Label    label=${nom_label}
    ${ssh_key_file_relative_path}    Set Variable   ${nom["ssh_key_file"]}
    ${ssh_key_file_absolute_path}    OperatingSystem.Join Path   ${CURDIR}   ${ssh_key_file_relative_path}
    ${nom_sftp_information}  Create Dictionary
    ...    pm_sftp_ip=${nom["pm_sftp_ip"]}
    ...    pm_sftp_username=${nom["pm_sftp_username"]}
    ...    pm_sftp_password=${nom["pm_sftp_password"]}
    ...    pm_sftp_root_path=${nom["pm_sftp_root_path"]}
    ...    pm_sftp_root_path_rest=${nom["pm_sftp_root_path_rest"]}
    ...    ssh_key_file=${ssh_key_file_absolute_path}
    ...    ssh_ip=${nom["ssh_ip"]}
    ...    ssh_user=${nom["ssh_user"]}

    [Return]    ${nom_sftp_information}


Get NOM Config Type From TestLine
    [Documentation]  Get NOM Config Type From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	  None
    ...
    ...    *RETURN VALUE*
    ...   1-Use NOM config in __init__.py, 0-Use NOM config in global_variable.py.
    ...   If this key is not given, default value is 1
    ...  "nom_config_source_from_init_py": "0",
    ...   return 'nom_config_source_from_init_py' if NOM configuration is defined in __init__.py
    ...   else 'nom_config_source_from_global_variable_py' (it means NOM configuration is defined in global_variables.py)
    ...
    ...    Example
    ...    | ${NOM_config_source} | Get NOM Config Type From TestLine |
    ...
    ${misc_config}   Get Misc Config From TestLine
    Return From Keyword If   ${misc_config.__len__()==0}    nom_config_source_from_init_py

    ${result}  ${nom_config_source_from_init_py}    Run Keyword And Ignore Error
    ...   Set Variable  ${misc_config["nom_config_source_from_init_py"]}

    Return From Keyword If   "${result}"=="FAIL"    nom_config_source_from_init_py

    Run Keyword If   "${nom_config_source_from_init_py}"!="0" and "${nom_config_source_from_init_py}"!="1"
       ...   Fail
       ...   nom_config_source_from_init_py value should be 0 or 1, but your given value is ${nom_config_source_from_init_py}

    ${rtn}   Set Variable If   "${nom_config_source_from_init_py}"=="1"
     ...   nom_config_source_from_init_py   nom_config_source_from_global_variable_py
    [Return]  ${rtn}


Get Misc Config From TestLine
    [Documentation]  Get Misc Config From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	  None
    ...
    ...    *RETURN VALUE*
    ...   return misc configuration defined in __init__.py
    ...
    ...    Example
    ...    | ${misc_config} | Get Misc Config From TestLine |
    ...

    ${empty_dict}   create dictionary
    ${result}   ${config}   Run Keyword And Ignore Error    Set Variable  ${tl._misc}
    ${misc_config}  set variable if  """${result}"""=="""FAIL"""   ${empty_dict}    ${config}
    [Return]   ${misc_config}


Get Appointed Nom Info By Label
    [Arguments]   ${label}
    [Documentation]   get appointed nom info by label
    ...   *Auther:* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what and how |
    ...   | 2022-02-07 | r3li | init |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | label | Yes | string, label name, such as NOM4,NOM10,NOM13 |
    ...   *Example*
    ...   | ${nom_info} | Get Appointed Nom Info By Label | NOM10 |
    ...   | _NOM Detect Rest Login | ${nom_info} |
    ${all_nom_list}      get_all_nom_server
    ${nom_count}    Get Length    ${all_nom_list}
    FOR   ${nom_index}  IN RANGE   ${nom_count}
        ${nom_info}  Set Variable   ${all_nom_list[${nom_index}]}
        Exit For Loop If   "${nom_info["label"]}"=="${label}"
    END
    [Return]   ${nom_info}



_Get NOM Server Information By Label
    [Arguments]  ${label}=NOM4
   [Documentation]   _Get NOM Server Information By Label
    ...  author:             chris.l.cao@nokia-sbell.com
    ...  modified by:        <21-Oct-2021>, <chricao>, <initial created>
    ...  modified by:        <25-Apri-2022>, <hongysun>, <add ssh_key_file paramter>
    ...    | Input Parameters | Man. | Description |
    ...    |  label  |  No  |  label, should be NOM4 or NOM10, default is NOM4.  |
    ...
    ...    *RETURN VALUE*
    ...    dictionary of NOM extra info
    ...
    ${all_nom_list}      get_all_nom_server
    ${nom_count}    Get Length    ${all_nom_list}
    ${rtn}   Create Dictionary
    FOR    ${nom_index}    IN RANGE    ${nom_count}
        ${nom}  Set Variable   ${all_nom_list[${nom_index}]}
        Continue For Loop If   "${nom["label"]}"!="${label}"
        Set To Dictionary   ${rtn}   label    ${label}
        Set To Dictionary   ${rtn}   ssh_ip   ${nom["main_info"].ssh_connections_info[0].addr}
        Set To Dictionary   ${rtn}   ssh_user   ${nom["main_info"].ssh_connections_info[0].username}
        Set To Dictionary   ${rtn}   integrate_link   ${nom["integrate_link"]}
        ${ssh_ip_mask_len}   Set Variable  ${nom["ssh_ip_mask_len"]}
        ${ssh_ip_mask_len}   Convert To String   ${ssh_ip_mask_len}
        Set To Dictionary   ${rtn}   ssh_ip_mask_len    ${ssh_ip_mask_len}
        Set To Dictionary   ${rtn}   webui_link   ${nom["main_info"].https_main_info.addr}
        Set To Dictionary   ${rtn}   webui_link_username   ${nom["main_info"].https_main_info.username}
        Set To Dictionary   ${rtn}   webui_link_password   ${nom["main_info"].https_main_info.password}
        Set To Dictionary   ${rtn}   version   ${nom["version"]}
        Set To Dictionary   ${rtn}   ca_file   ${nom["ca_file"]}
        Set To Dictionary   ${rtn}   vdu_integrate_to_nom_certificate_file   ${nom["vdu_integrate_to_nom_certificate_file"]}
        Set To Dictionary   ${rtn}   ca_sn   ${nom["ca_sn"]}
        Set To Dictionary   ${rtn}   ca_id   ${nom["ca_id"]}
        # ----------  NOM PM FILE SFTP server part -----------------
        Set To Dictionary   ${rtn}   pm_sftp_ip   ${nom["pm_sftp_ip"]}
        Set To Dictionary   ${rtn}   pm_sftp_username    ${nom["pm_sftp_username"]}
        Set To Dictionary   ${rtn}   pm_sftp_password   ${nom["pm_sftp_password"]}
        Set To Dictionary   ${rtn}   pm_sftp_root_path    ${nom["pm_sftp_root_path"]}
        Set To Dictionary   ${rtn}   pm_sftp_root_path_rest    ${nom["pm_sftp_root_path_rest"]}
        Set To Dictionary   ${rtn}   ssh_key_file   ${nom["ssh_key_file"]}
        log to console      _Get NOM Server Information By Label:NOM server: ${label} is found.
    END
    [Return]   ${rtn}


_Get Target NOM Server Index
    [Documentation]
    ...    will chose the useful NOM and return the nom id
    ...    *AUTHOR* jie.8.liu@nokia-sbell.com
    ...    modified by:        <13-Oct-2021>, <huilxu>, <NOM Detect Rest Login>
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    Index of desire target NOM server and target nom server

    ${nom_index}     ${nom_server}   Wait Until Keyword Succeeds  1x  1  _Get Target NOM Server Index Once
    [Return]    ${nom_index}     ${nom_server}


_Get Target NOM Server Index Once
    [Documentation]
    ...    will chose the useful NOM and return the nom id
    ...    *AUTHOR* jie.8.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   13.10.2021,huilxu@nokia-sbell.com, NOM Detect Rest Login
    ...   16.2.2022,chris.l.cao@nokia-sbell.com, skip the NOM whose configured_status is 'unavailable'
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    Index of desire target NOM server and target nom server
    ...
    ${all_nom_list}  get_all_nom_server
    ${nom_count}     Get Length    ${all_nom_list}
    ${status}  Set Variable   ${False}
    FOR    ${nom_index}    IN RANGE    ${nom_count}
        ${configured_status}  _Get NOM Configured Status   ${all_nom_list[${nom_index}]}
        Continue For Loop If    "${configured_status}"=="unavailable"
        ${status}     Run Keyword and Return Status    _NOM Detect Rest Login    ${all_nom_list[${nom_index}]}
        Exit For Loop If    "${status}"=="True"
    END
    Should Be True   "${status}"=="True"
    Log To Console   nom_index:${nom_index}
    Log To Console   Target Nom:${all_nom_list[${nom_index}]}
    [Return]    ${nom_index}     ${all_nom_list[${nom_index}]}


_Get NOM Configured Status
    [Arguments]  ${dict_nom}
    [Documentation]  _Get NOM Configured Status
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   16.2.2022,chris.l.cao@nokia-sbell.com, initialization
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | dict_nom    | Man. | nom configuration in global_variables.py |
    ...
    ...   *RETURN VALUE*
    ...    status configured in global_variables.py , e.g, available or unavailable
    ...
    ${configured_status}  Set Variable  ${dict_nom["configured_status"]}
    [Return]  ${configured_status}
