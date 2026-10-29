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
    ${nom_sftp_information}  Create Dictionary
    ...    pm_sftp_ip=${active_nom["pm_sftp_ip"]}
    ...    pm_sftp_username=${active_nom["pm_sftp_username"]}
    ...    pm_sftp_password=${active_nom["pm_sftp_password"]}
    ...    pm_sftp_root_path=${active_nom["pm_sftp_root_path"]}
    ...    pm_sftp_root_path_rest=${active_nom["pm_sftp_root_path_rest"]}

    Should Not Be Empty   ${nom_sftp_information}

    [Return]    ${nom_sftp_information}


_Get NOM SFTP Information According To init.py
    [Documentation]   _Get NOM SFTP Information According To init.py
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
    ...   | ${vdu_integrate_to_nom_certificate_file}  | _Get NOM SFTP Information According To init.py |
    ...
    ${nom_label}   _Get NOM Label Name According To init.py
    ${nom}   _Get NOM Server Information By Label    label=${nom_label}
    ${nom_sftp_information}  Create Dictionary
    ...    pm_sftp_ip=${nom["pm_sftp_ip"]}
    ...    pm_sftp_username=${nom["pm_sftp_username"]}
    ...    pm_sftp_password=${nom["pm_sftp_password"]}
    ...    pm_sftp_root_path=${nom["pm_sftp_root_path"]}
    ...    pm_sftp_root_path_rest=${nom["pm_sftp_root_path_rest"]}

    [Return]    ${nom_sftp_information}
