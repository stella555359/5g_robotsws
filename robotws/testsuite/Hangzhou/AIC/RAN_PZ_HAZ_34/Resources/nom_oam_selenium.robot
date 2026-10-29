*** Settings ***
Documentation
...


*** Variables ***


*** Keywords ***
NOM WebEM Login
    [Arguments]   ${https_proxy}=http://10.144.1.10:8080    ${NOM_label}=${None}
    [Documentation]    NOM login via webui
    ...                login url is defined in variables.robot as NOM_1_WEBUI_LINK
    ...  *Author* hongping.rao@nokia-sbell.com
    ...  *History Change*:
    ...   | date | who | what and how |
    ...   | 31.7.2020 | hongping.rao@nokia-sbell.com | initialization |
    ...   | 24.5.2021 | j9liu@nokia-sbell.com | chose the work NOM login |
    ...   | 26.10.2021 | chris.l.cao@nokia-sbell.com | add ${NOM_WEBEM_LOGIN_INSTANCE_ID} to speed case running time |
    ...   | 29.4.2022 | rui.3.li@nokia-sbell.com | login with appointed NOM, including NOM4,NOM10,NOM13,default NOM13 |
    ...   | 14.7.2022 | chris.l.cao@nokia-sbell.com | add 3 times retry mechanism |
    ...
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | https_proxy | No | https proxy, default is http://10.144.1.10:8080
    ...   | NOM_label | No | nom label, default is None |
    ...   *RETURN VALUE*
    ...   None
    ...   *Example*
    ...   | NOM WebEM Login | http://10.144.1.10:8080 | NOM13 |
    Wait Until Keyword Succeeds   3x   5s     NOM WebEM Login Once   https_proxy=${https_proxy}   NOM_label=${NOM_label}


NOM WebEM Login Once
    [Arguments]   ${https_proxy}=http://10.144.1.10:8080    ${NOM_label}=${None}
    [Documentation]    NOM login via webui
    ...                login url is defined in variables.robot as NOM_1_WEBUI_LINK
    ...  *Author* hongping.rao@nokia-sbell.com
    ...  *History Change*:
    ...   | date | who | what and how |
    ...   | 31.7.2020 | hongping.rao@nokia-sbell.com | initialization |
    ...   | 24.5.2021 | j9liu@nokia-sbell.com | chose the work NOM login |
    ...   | 26.10.2021 | chris.l.cao@nokia-sbell.com | add ${NOM_WEBEM_LOGIN_INSTANCE_ID} to speed case running time |
    ...   | 29.4.2022 | rui.3.li@nokia-sbell.com | login with appointed NOM, including NOM4,NOM10,NOM13,default NOM13 |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | https_proxy | No | https proxy, default is http://10.144.1.10:8080
    ...   | NOM_label | No | nom label, default is None |
    ...   *RETURN VALUE*
    ...   None
    ...   *Example*
    ...   | NOM WebEM Login | http://10.144.1.10:8080 | NOM13 |
    ${nom_info}    Run Keyword If   '${nom_label}'=='${None}'   Get Target NOM server
    ...   ELSE   Get Appointed Nom Info By Label    ${nom_label}

    ${nom_info}    Set Variable If    '${nom_label}'=='${None}'    ${nom_info}[1]    ${nom_info}

    ${username}   Set Variable  ${nom_info["main_info"].https_main_info.username}
    ${password}    Set Variable  ${nom_info["main_info"].https_main_info.password}
    ${url}   Set Variable  ${nom_info["main_info"].https_main_info.addr}
    nom_selenium.Login    url=${url}    username=${username}     password=${password}
    Set Test Variable   ${NOM_WEBEM_LOGIN_INSTANCE_ID}    NOM WebEM Login is Called.


NOM WebEM Logout
    [Documentation]    NOM WebEM Logout
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  history change: <date>,<who>,<what and how>
    ...   26.10.2021,chris.l.cao@nokia-sbell.com, add ${NOM_WEBEM_LOGIN_INSTANCE_ID} to speed case running time
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | NOM WebEM Logout |
    ...
    Wait Until Keyword Succeeds   3x   5s   NOM WebEM Logout Once


NOM WebEM Logout Once
    [Documentation]    NOM WebEM Logout Once
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  history change: <date>,<who>,<what and how>
    ...   26.10.2021,chris.l.cao@nokia-sbell.com, add ${NOM_WEBEM_LOGIN_INSTANCE_ID} to speed case running time
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | NOM WebEM Logout |
    ...
    ${r}   Run Keyword And Return Status   Variable Should Exist   ${NOM_WEBEM_LOGIN_INSTANCE_ID}
    Return From Keyword If  "${r}"=="${False}"
    Return From Keyword If  "${NOM_WEBEM_LOGIN_INSTANCE_ID}"=="${None}"

    nom_selenium.logout

    Set Test Variable   ${NOM_WEBEM_LOGIN_INSTANCE_ID}    ${None}
