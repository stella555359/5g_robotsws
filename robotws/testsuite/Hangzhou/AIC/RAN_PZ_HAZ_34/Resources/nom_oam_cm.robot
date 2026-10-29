*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   nom_oam_cm.robot



*** Variables ***



*** Keywords ***
Nom Rest Login
    [Arguments]   ${nom_label}=None
    [Documentation]    Nom Rest Login
    ...  author:             fen.huang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    10.10.2021, huilxu@nokia-sbell.com, add the config source
    ...    24.10.2021, chris.l.cao@nokia-sbell.com, add 'NOM Rest logout' before login
    ...    7.2.2022, rui.3.li@nokia-sbell.com, support login from global_variable.py with appointed nom
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    Client id
    ...
    ...    Example
    ...   | Integrate NE To NOM  |  ne_type=vdu |  integration_type=rest  |
    ...   | Nom Rest Login |
    ...   | ${btsName} | Get Parameter Value Via NOM For VDU | dist_name=MRBTS-1234 | parameter_name=btsName |
    ...   | Deintegrate NE From NOM  | ne_type=vdu | deintegration_type=rest |
    ...   | Nom Rest Logout  |
    ...

    ${client_id}  Wait Until Keyword Succeeds  2x  5   Nom Rest Login Once   ${nom_label}

    [Return]   ${client_id}


Nom Rest Login Once
    [Arguments]   ${nom_label}=None
    [Documentation]    Nom Rest Login Once
    ...  author:             fen.huang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    10.10.2021, huilxu@nokia-sbell.com, add the config source
    ...    24.10.2021, chris.l.cao@nokia-sbell.com, add 'NOM Rest logout' before login
    ...    7.2.2022, rui.3.li@nokia-sbell.com, support login from global_variable.py with appointed nom
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    Client id
    ...
    ...    Example
    ...   | Integrate NE To NOM  |  ne_type=vdu |  integration_type=rest  |
    ...   | Nom Rest Login |
    ...   | ${btsName} | Get Parameter Value Via NOM For VDU | dist_name=MRBTS-1234 | parameter_name=btsName |
    ...   | Deintegrate NE From NOM  | ne_type=vdu | deintegration_type=rest |
    ...   | Nom Rest Logout  |
    ...

    Run Keyword And Ignore Error   Nom Rest Logout

    ${NOM_config_source}  Get NOM Config Type From TestLine
    ${client_id}   Run Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"
     ...   _Nom Rest Login With Nom Info From init.py
    ...   ELSE   _Nom Rest Login With Nom Info From global_variable.py   ${nom_label}

    Set Test Variable   ${NOM_REST_LOGIN_CLIENT_ID}    ${client_id}

    [Return]   ${client_id}


Nom Rest Logout
    [Arguments]   ${client_id}=${None}   ${nom_label}=${None}
    [Documentation]    Logout Nom via rest api.
    ...  author:             fen.huang@nokia-sbell.com
    ...    04.2.2021, f2huang@nokia-sbell.com, initial
    ...    14.10.2021, huilxu@nokia-sbell.com, add the config source
    ...    24.10.2021, chris.l.cao@nokia-sbell.com, add ${NOM_REST_LOGIN_CLIENT_ID} to support no parameter while calling 'NOM Rest Logout'
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  client_id  |  No  |  client id returned by NOM Rest Login  |
    ...
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...   | Integrate NE To NOM  |  ne_type=vdu |  integration_type=rest  |
    ...   | Nom Rest Login |
    ...   | ${btsName} | Get Parameter Value Via NOM For VDU | dist_name=MRBTS-1234 | parameter_name=btsName |
    ...   | Deintegrate NE From NOM  | ne_type=vdu | deintegration_type=rest |
    ...   | Nom Rest Logout  |
    ...
    ${r}   Run Keyword And Return Status   Variable Should Exist   ${NOM_REST_LOGIN_CLIENT_ID}
    Return From Keyword If  "${r}"=="${False}"
    Return From Keyword If  "${NOM_REST_LOGIN_CLIENT_ID}"=="${None}"

    ${client_id}  Set Variable   ${NOM_REST_LOGIN_CLIENT_ID}

    ${NOM_config_source}  Get NOM Config Type From TestLine
    Run Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"
    ...   _Nom Rest Logout With Nom Info From init.py  ${client_id}
    ...   ELSE   _Nom Rest Logout With Nom Info From global_variable.py  ${client_id}   ${nom_label}

    Set Test Variable   ${NOM_REST_LOGIN_CLIENT_ID}    ${None}


_Nom Rest Logout With Nom Info From init.py
   [Arguments]   ${client_id}
   [Documentation]    _Nom Rest Logout With Nom Info From init.py
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <04-02-2021>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  client_id  |  Yes  |  client id returned by NOM Rest Login  |
    ...
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  Nom Rest Logout  |  client_id=aaa  |
   nom_rest.delete_the_client  client_id=${client_id}
   ...       username=${tl.nms.nom.https_main_info.username}
   ...       password=${tl.nms.nom.https_main_info.password}
   ...       apigw_uri=${tl.nms.nom.https_rest_info.addr}


_Nom Rest Logout With Nom Info From global_variable.py
   [Arguments]   ${client_id}   ${nom_label}=${None}
   [Documentation]    _Nom Rest Logout With Nom Info From global_variable.py
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <14-Oct-2021>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  client_id  |  Yes  |  client id returned by NOM Rest Login  |
    ...
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  Nom Rest Logout  |  client_id=aaa  |
    #_Nom Rest Logout Via Target Nom Info  ${client_id}  ${TARGET_NOM_INFO[${TARGET_NOM_INDEX}]}
    ${NOM_INFO}   Run Keyword If   '${nom_label}'=='${None}'   Get Target NOM server
    ...   ELSE   Get Appointed Nom Info By Label    ${nom_label}
    ${TARGET_NOM_INFO}    Run Keyword If    '${nom_label}'=='${None}'   Set Variable   ${NOM_INFO}[1]
    ...  ELSE   Set Variable    ${NOM_INFO}
    _Nom Rest Logout Via Target Nom Info  ${client_id}  ${TARGET_NOM_INFO}


_Nom Rest Logout Via Target Nom Info
    [Arguments]   ${client_id}  ${nom_info}
    [Documentation]    _Nom Rest Logout Via Target Nom Info
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <14-10-2021>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  client_id  |  Yes  |  client id returned by NOM Rest Login  |
    ...    |  nom_info  |  Yes  |  the nom info returned by Get Target NOM server  |
    ...    *RETURN VALUE*
    ...    Client id
    ...    Example
    ...    | ${TARGET_NOM_INDEX}  |  ${TARGET_NOM_INFO}  |  Get Target NOM server  |
    ...    | ${client_id}  |   _Nom Rest Login Via Target Nom Info  |  ${TARGET_NOM_INFO]}  |
    ...    | _Nom Rest Logout Via Target Nom Info  |   ${client_id}  |   ${TARGET_NOM_INFO}  |
    ${username}   Set Variable  ${nom_info["main_info"].https_main_info.username}
    ${password}    Set Variable  ${nom_info["main_info"].https_main_info.password}
    ${apigw_uri}   Set Variable  ${nom_info["main_info"].https_rest_info.addr}

    nom_rest.delete_the_client  client_id=${client_id}
    ...       username=${username}
    ...       password=${password}
    ...       apigw_uri=${apigw_uri}
    Sleep  6


_NOM Detect Rest Login
    [Arguments]  ${dict_nom}
    [Documentation]    _NOM Detect Rest Login
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <13-Oct-2020>, <huilxu>, <Initial creation>
    ...    13.10.2020,huilin.xu@nokia-sbell.com, Initialization
    ...    19.2.2022,chris.l.cao@nokia-sbell.com, skip logout when it fails to register_the_client
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  dict_nom   |  Yes  |  nom info returned by get_all_nom_server |
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  _NOM Detect Rest Login  |  ${dict_nom}  |
    ...
    Wait Until Keyword Succeeds  1x  5   _NOM Detect Rest Login Once  dict_nom=${dict_nom}


_NOM Detect Rest Login Once
    [Arguments]  ${dict_nom}
    [Teardown]   run keyword and ignore error  Run Keyword If  "${nom_login}"=="1"   _NOM Detect Rest Logout    ${dict_nom}    ${client_id}
    [Documentation]    _NOM Detect Rest Login
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <13-Oct-2020>, <huilxu>, <Initial creation>
    ...    13.10.2020,huilin.xu@nokia-sbell.com, Initialization
    ...    19.2.2022,chris.l.cao@nokia-sbell.com, skip logout when it fails to register_the_client
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  dict_nom   |  Yes  |  nom info returned by get_all_nom_server |
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  _NOM Detect Rest Login  |  ${dict_nom}  |
    ...
    ${nom_login}  Set Variable   0
    ${username}   Set Variable  ${dict_nom["main_info"].https_main_info.username}
    ${password}    Set Variable  ${dict_nom["main_info"].https_main_info.password}
    ${apigw_uri}   Set Variable  ${dict_nom["main_info"].https_rest_info.addr}

    ${client_id}=  get unique id

    ${client_secret}   nom_rest.register_the_client   client_id=${client_id}
    ...       username=${username}
    ...       password=${password}
    ...       apigw_uri=${apigw_uri}

    ${nom_login}  Set Variable   1

    ${user_mgmt_uri}   Set Variable  ${dict_nom["main_info"].https_user_mgmt_info.addr}
    ${apigw_uri}   Set Variable  ${dict_nom["main_info"].https_rest_info.addr.split("//")[-1]}
    ${nom_version}  Set Variable  ${dict_nom["version"]}

    nom_rest.connect_to  user_mgmt_uri=${user_mgmt_uri}
    ...    apigw_uri=${apigw_uri}
    ...    client_id=${client_id}
    ...    client_secret=${client_secret}
    ...    port=${443}
    ...    username=${username}
    ...    password=${password}
    ...    nom_version=${nom_version}
    ...    secure=${True}

    sleep   6


_NOM Detect Rest Logout
    [Arguments]     ${dict_nom}     ${client_id}
    [Documentation]    _NOM Detect Rest Logout
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <13-Oct-2020>, <huilxu>, <Initial creation>
    ...    23.10.2021,chris.l.cao@nokia-sbell.com, add change history, delete "https://" for apigw_uri
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  dict_nom   |  Yes  |  nom info defined in global_variables.py |
    ...    |  client_id  |  Yes  |  client id returned by register_the_client    |
    ...
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  _NOM Detect Rest Logout  |  ${dict_nom}  |  ${client_id} |
    ...
    ${username}   Set Variable  ${dict_nom["main_info"].https_main_info.username}
    ${password}    Set Variable  ${dict_nom["main_info"].https_main_info.password}
    #${apigw_uri}   Set Variable  ${dict_nom["main_info"].https_rest_info.addr}
    ${apigw_uri}   Set Variable  ${dict_nom["main_info"].https_rest_info.addr.split("//")[-1]}

    nom_rest.delete_the_client  client_id=${client_id}
    ...       username=${username}
    ...       password=${password}
    ...       apigw_uri=https://${apigw_uri}

    sleep  6


Get Target NOM server
    [Documentation]   Get the Target NOM server.
    ...               Get the Target NOM ip username password and link info
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <15-July-2021>, <j9liu>, <initial created>
    ...  modified by:        <14-Oct-2021>, <huilxu>, <modify>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    NOM server info
    ...    Example
    ...    |  |    |
    ${r}  ${value}   run keyword and ignore error   set variable   ${TARGET_NOM_INDEX}
#    return from keyword if  "${r}"=="PASS"    ${TARGET_NOM_INDEX}    ${TARGET_NOM_INFO}

    ${IsValid}   Set Variable If   "${r}"=="PASS"   ${value}   ${None}
    return from keyword if  "${IsValid}"!="${None}"    ${TARGET_NOM_INDEX}    ${TARGET_NOM_INFO}

    ${TARGET_NOM_INDEX}    ${TARGET_NOM_INFO}    _Get Target NOM Server Index
    set test variable   ${TARGET_NOM_INDEX}
    set test variable   ${TARGET_NOM_INFO}
    [Return]    ${TARGET_NOM_INDEX}     ${TARGET_NOM_INFO}


Get Parameter Value Via NOM For VDU
    [Arguments]    ${dist_name}   ${parameter_name}   ${list_name}=${EMPTY}    ${gnb_index}=0   ${vdu_index}=0
    [Tags]  NOM_CM
    [Documentation]    Get Parameter Value Via NOM For VDU
    ...  author:             chris.l.cao@nokia-sbell.com
    ...  modified by:        <23-Oct-2021>, <chricao>, <initial created>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | dist_name  |  yes  | dist_name, e.g, MRBTS-1234  |
    ...    | parameter_name | yes | parameter_name, e.g, btsName  |
    ...    | list_name  |  no  | list_name, default is ${EMPTY}  |
    ...    | gnb_index  | no | gnb_index, defaut is 0  |
    ...    | vdu_index  |  no  | vdu_index,default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    value of parameter
    ...
    ...    Example
    ...   | Integrate NE To NOM  |  ne_type=vdu |  integration_type=rest  |
    ...   | ${btsName} | Get Parameter Value Via NOM For VDU | dist_name=MRBTS-1234 | parameter_name=btsName |
    ...   | ${sw_version} | Get Parameter Value Via NOM For VDU | dist_name=MRBTS-1234/MNL-1/MNL_R-1 | parameter_name=activeSWReleaseVersion |
    ...   | Deintegrate NE From NOM  | ne_type=vdu | deintegration_type=rest |
    ...   | Nom Rest Logout  |
    ...
    ${exported_plan_file}      Get Export plan Via NOM For VDU   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    scf.Load_Scf  file_path=${exported_plan_file}

    ${value}   Run Keyword If   "${list_name}"!="${EMPTY}"
    ...    scf.Get_Value_From_Scf    dist_name=${distname}   list_name=${list_name}   p_name=${parameter_name}
    ...   ELSE   scf.Get_Value_From_Scf    dist_name=${distname}     p_name=${parameter_name}
    [Return]  ${value}



Rest Check Cell Status Should Be On Air Via NOM For vDU
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${nom_label}=None
    [Documentation]  Rest Check Cell Status Should Be On Air Via NOM For vDU
    ...  author:             jianlin.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | no | gnb_index, defaut is 0  |
    ...    | vdu_index  |  no  | vdu_index,default is 0 |
    ...    | nom_label  |  no  | nom_label,default is None|
    ...
    ...    Example
    ...   | ${status} | Rest Check Cell Status Should Be On Air Via NOM For vDU | nom_label=NOM10 |
    ...
    ${vdu_conf}   Get VDU Conf From SCF    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${mrbts_id}  Set Variable  ${vdu_conf["mrbts_id"]}
    ${nrbts_dist_name}  set variable   MRBTS-${mrbts_id}/NRBTS-${mrbts_id}
    ${nrcell_dist_name}   set variable   MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-1
    Nom Rest Login   ${nom_label}
    ${value_nrbts_administrativeState}  Get Parameter Value Via NOM For VDU  dist_name=${nrbts_dist_name}
    ...   parameter_name=operationalState
    ${value_nrcell_administrativeState}  Get Parameter Value Via NOM For VDU  dist_name=${nrcell_dist_name}
    ...   parameter_name=administrativeState
    ${value_nrcell_operationalState}  Get Parameter Value Via NOM For VDU  dist_name=${nrcell_dist_name}
    ...   parameter_name=operationalState
    Should be equal    ${value_nrbts_administrativeState}  onAir
    Should be equal    ${value_nrcell_administrativeState}  Unlocked
    Should be equal    ${value_nrcell_operationalState}  enabled
#    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    client_id=${client_id}   nom_label=${nom_label}
    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    nom_label=${nom_label}


Import Plan From NOM By REST API
    [Arguments]    ${plan_name}  ${plan_xml_file}  ${plan_type}=GENERAL  ${overwrite}=${True}  ${nom_label}=None
    [Documentation]  Import Plan From NOM By REST API, precondition is NE has been integrated to NOM
    ...  author:             mengli.yang@nokia-sbell.com
    ...  modified by:        <04-03-2021>, <mengyang>, <initial created>
	...  modified by: 		 <15-06-2021>, <Zhang,jianlin>, <update kw for new feature CB005703 used>
	...  modified by:    <08-02-2022>, <Zhang,jianlin>, <add nom_label argument due to "Nom Rest Login" kw change>
    ...    | Input Parameters | Man. | Description |
    ...    |  PLAN_NAME  |  Yes  |  plan name for import plan  |
    ...    | plan_xml_file| Yes | xml plan file path to be imported |
    ...    | plan_type |  No  |  plan type to be imported, default is GENERAL, if other type needed input it |
    ...    | overwrite | No | plan to be overwrite on the system, default bool true used |
    ...
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...   | Integrate NE To NOM  |  ne_type=vdu |  integration_type=rest  |
    ...   | Import Plan From NOM By REST API |  plan_name=my_plan_name  |  plan_xml_file=/tmp/myplanfile.xml |
    ...   | Download Plan From NOM | plan_name=my_plan_name |
    ...   | Validate Plan From NOM | plan_name=my_plan_name |
    ...   | Deintegrate NE From NOM  | ne_type=vdu | deintegration_type=rest |
    ...   | Nom Rest Logout  |
    ...
    log to console   Import Plan From NOM By REST API
#    Wait Until Keyword Succeeds  180  20   Nom Rest Login   ${nom_label}
    ${r}   Run Keyword And Return Status   Variable Should Exist   ${NOM_REST_LOGIN_CLIENT_ID}
    ${need_rest_login}   Set Variable If  "${r}"=="${False}"  1   "${NOM_REST_LOGIN_CLIENT_ID}"=="${None}"  1   0
    Run Keyword If   "${need_rest_login}"=="1"   Nom Rest Login   ${nom_label}

    nom_rest.import_plan  path_to_plan=${plan_xml_file}  name=${plan_name}   plan_type=${plan_type}  overwrite=${overwrite}
    sleep    15


Download Plan From NOM
    [Arguments]   ${plan_name}   ${wait}=10   ${timeout}=30
    [Documentation]  Download Plan From NOM, precondition is NE has been integrated to NOM
    ...  author:             chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  plan_name |  yes  |  plan name for import plan  |
    ...    |  wait      |  no  |  wait after validate, default is 5s |
    ...    |  timeout   |  no  | timeout, default is 30s  |
    ...
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...   | Integrate NE To NOM  |  ne_type=vdu |  integration_type=rest  |
    ...   | Import Plan From NOM By REST API |  plan_name=my_plan_name  |  plan_xml_file=/tmp/myplanfile.xml |
    ...   | Download Plan From NOM | plan_name=my_plan_name |
    ...   | Validate Plan From NOM | plan_name=my_plan_name |
    ...   | Deintegrate NE From NOM  | ne_type=vdu | deintegration_type=rest |
    ...   | Nom Rest Logout |
    ...
    nom_rest.download_plan    plan_name=${plan_name}   timeout=${timeout}
    sleep    ${wait}


Validate Plan From NOM
    [Arguments]   ${plan_name}   ${wait}=10   ${timeout}=30
    [Documentation]  Validate Plan From NOM, precondition is NE has been integrated to NOM
    ...  author:             chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  plan_name |  yes  |  plan name for import plan  |
    ...    |  wait      |  no  |  wait after validate, default is 5s |
    ...    |  timeout   |  no  | timeout, default is 30s  |
    ...
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...   | Integrate NE To NOM  |  ne_type=vdu |  integration_type=rest  |
    ...   | Import Plan From NOM By REST API |  plan_name=my_plan_name  |  plan_xml_file=/tmp/myplanfile.xml |
    ...   | Download Plan From NOM | plan_name=my_plan_name |
    ...   | Validate Plan From NOM | plan_name=my_plan_name |
    ...   | Deintegrate NE From NOM  | ne_type=vdu | deintegration_type=rest |
    ...   | Nom Rest Logout |
    ...
    nom_rest.validate_plan    plan_name=${plan_name}   timeout=${timeout}
    sleep    ${wait}


Provision Plan From NOM
    [Arguments]   ${plan_name}   ${wait}=10   ${timeout}=300
    [Documentation]  Provision Plan From NOM, precondition is NE has been integrated to NOM
    ...  author:             chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  plan_name |  yes  |  plan name for import plan  |
    ...    |  wait      |  no  |  wait after validate, default is 5s |
    ...    |  timeout   |  no  | timeout, default is 30s  |
    ...
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...   | Integrate NE To NOM  |  ne_type=vdu | integration_type=rest |
    ...   | Import Plan From NOM By REST API |  plan_name=my_plan_name  |  plan_xml_file=/tmp/myplanfile.xml |
    ...   | Provision Plan From NOM | plan_name=my_plan_name |
    ...   | Deintegrate NE From NOM  | ne_type=vdu | deintegration_type=rest |
    ...   | Nom Rest Logout |
    ...
    nom_rest.provision_plan    plan_name=${plan_name}   timeout=${timeout}
    sleep    ${wait}


Get Export plan Via NOM For VDU
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]    Get Export plan Via NOM For VDU
    ...  author:             chris.l.cao@nokia-sbell.com
    ...  modified by:        <23-Oct-2021>, <chricao>, <initial created>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | no | gnb_index, defaut is 0  |
    ...    | vdu_index  |  no  | vdu_index,default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   exported plan file name
    ...
    ...    Example
    ...   | Integrate NE To NOM  |  ne_type=vdu |  integration_type=rest  |
    ...   | ${file_name} | Get Export plan Via NOM For VDU |
    ...   | Deintegrate NE From NOM  | ne_type=vdu | deintegration_type=rest |
    ...   | Nom Rest Logout |
    ...
    ${vdu_conf}   Get VDU Conf From SCF    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${mrbts_id}  Set Variable  ${vdu_conf["mrbts_id"]}

    ${random_id}   Get Unique ID  precise=FORMAT_DATETIME
    ${plan_file}  Get A File   NOM_plan_file    exported_plan_${random_id}.xml
    ${scope}  Create List   MRBTS-${mrbts_id}

    ${export_plan}   nom_rest.export_plan   ${plan_file}   ${scope}
    [Return]  ${plan_file}

Generate NOM Delta Plan For Complex Parameters
    [Arguments]  ${ne_type}  ${plan_name}   ${mo_dict_list}  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Generate NOM Delta Plan For Complex Parameters
    ...  author:             chris.l.cao@nokia-sbell.com
    ...  modified by:
    ...    21.1.2022, chris.l.cao@nokia-sbell.com, add to support FHGW
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type      |  yes  |  ne_type, VCU or VDU or FHGW, it's case in-sensitive |
    ...    |  plan_name    |  yes  |  plan name for import plan  |
    ...    |  mo_dict_list |  yes  | mo_dict_list, type is list, list member type is dictionary, please see KW example |
    ...    |  gnb_index  |  no  | gnb_index, default is 0  |
    ...    |  vdu_index  |  no  | vdu_index, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...    plan file name where contains plan content
    ...
    ...    Example
    ...   For single MO + one parameter + VDU:
    ...  | ${mrbts_id} | Get MRBTS Id From vDU SCF |
    ...  | ${parameters} | Create Dictionary | pMax=470 |
    ...  | ${mo_dict}    | Create Dictionary | distname=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-1 | operation=update | parameters=${parameters} |
    ...  | ${mo_dict_list} | Create List | ${mo_dict} |
    ...  | ${plan_name}    | Get Unique Id | prefix=plan_${mrbts_id}_ | precise=FORMAT_DATETIME |
    ...  | ${plan_file}    | Generate NOM Delta Plan For Complex Parameters | ne_type=VDU | plan_name=${plan_name} | mo_dict_list=${mo_dict_list} |
    ...  | Integrate NE To NOM  |  ne_type=vdu |  integration_type=rest  |
    ...  | Import Plan From NOM By REST API | plan_name=${plan_name} |  plan_xml_file=${plan_file} |
    ...  | Download Plan From NOM | plan_name=${plan_name} |
    ...  | Validate Plan From NOM |  plan_name=${plan_name} |
    ...  | Deintegrate NE From NOM  | ne_type=vdu | deintegration_type=rest |
    ...  | Nom Rest Logout |
    ...  Or directly use 'Provision Plan From NOM' after 'Import Plan From NOM By REST API' to provision configuration.
    ...
    ...   For multiple MO + multiple parameters + VCU:
    ...  | ${mrbts_id} | Get MRBTS Id From vCU SCF |
    ...  | ${parameters1} | Create Dictionary | physCellId=580 |  nrarfcn=633000 |
    ...  | ${mo_dict1}  | Create Dictionary | distname=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-1 | operation=update | parameters=${parameters1} |
    ...  | ${parameters2}  | Create Dictionary  | btsName=new_bts_name |
    ...  | ${mo_dict2}     |  Create Dictionary | distname=MRBTS-${mrbts_id} | operation=update | parameters=${parameters2} |
    ...  | ${mo_dict_list} | Create List | ${mo_dict1} | ${mo_dict2}  |
    ...  | ${plan_name}    | Get Unique Id | prefix=plan_${mrbts_id}_ | precise=FORMAT_DATETIME |
    ...  | ${plan_file}    | Generate NOM Delta Plan For Complex Parameters | ne_type=VCU | plan_name=${plan_name} | mo_dict_list=${mo_dict_list} |
    ...  | Integrate NE To NOM  |  ne_type=vcu |  integration_type=rest  |
    ...  | Import Plan From NOM By REST API | plan_name=${plan_name} |  plan_xml_file=${plan_file} |
    ...  | Provision Plan From NOM          | plan_name=${plan_name} |
    ...  | Deintegrate NE From NOM  | ne_type=vcu | deintegration_type=rest |
    ...  | Nom Rest Logout |
    ...
    ...   For single MO + complex parameters + VDU:
    ...  | ${mrbts_id} | Get MRBTS Id From vDU SCF |
    ...  | ${parameters}  Create Dictionary | actAlarmsInTestDedicatedState=true | actCategoryAlarms=true | actForceAutoReset=false |
    ...  |    ... |   actForceUnitAutoReset=false  | actPipePowerDecreased1dBFaults=false |
    ...  |    ... |   alToggSuppList/0/alToggAmount=2 |
    ...  |    ... |   alToggSuppList/0/alToggClearenceTime=120 |
    ...  |    ... |   alToggSuppList/0/alToggConditonTime=100 |
    ...  |    ... |   alToggSuppList/0/faultName=FCT_4298_ToP reference missing |
    ...  |    ... |   alToggSuppList/0/inUse=true |
    ...  | ${mo_dict}    | Create Dictionary | distname=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1 | operation=update | parameters=${parameters} |
    ...  | ${mo_dict_list} | Create List | ${mo_dict} |
    ...  | ${plan_name}    | Get Unique Id | prefix=plan_${mrbts_id}_ | precise=FORMAT_DATETIME |
    ...  | ${plan_file}    | Generate NOM Delta Plan For Complex Parameters | ne_type=VDU | plan_name=${plan_name} | mo_dict_list=${mo_dict_list} |
    ...  | Integrate NE To NOM  |  ne_type=vdu |  integration_type=rest  |
    ...  | Import Plan From NOM By REST API | plan_name=${plan_name} |  plan_xml_file=${plan_file} |
    ...  | Download Plan From NOM | plan_name=${plan_name} |
    ...  | Validate Plan From NOM |  plan_name=${plan_name} |
    ...  | Deintegrate NE From NOM | ne_type=vdu | deintegration_type=rest |
    ...  | Nom Rest Logout |
    ...  Or directly use 'Provision Plan From NOM' after 'Import Plan From NOM By REST API' to provision configuration.
    ...
    ...   For multiple MO + multiple parameters + VCU:
    ...  It's similar as above.
    ...
    ...   For FHGW
    ...  | ${mrbts_id} | Get MRBTS Id From vDU SCF |
    ...  | ${parameters} | Create Dictionary | hwResetComment=ResetGNSSE | targetHwResetUDN=FHGW-${mrbts_id}/EQM-1/GNSSEMOD-1 |
    ...  | ${mo_dict}    | Create Dictionary | distname=FHGW-${mrbts_id}/MNL-1/CMD-1/HWRESETREQ-1 | operation=update | parameters=${parameters} |
    ...  | ${mo_dict_list} | Create List | ${mo_dict} |
    ...  | ${plan_name}    | Get Unique Id | prefix=plan_${mrbts_id}_ | precise=FORMAT_DATETIME |
    ...  | ${plan_file}    | Generate NOM Delta Plan For Complex Parameters | ne_type=FHGW | plan_name=${plan_name} | mo_dict_list=${mo_dict_list} |
    ...  | Integrate NE To NOM  |  ne_type=fhgw |  integration_type=rest  |
    ...  | Import Plan From NOM By REST API | plan_name=${plan_name} |  plan_xml_file=${plan_file} |
    ...  | Download Plan From NOM | plan_name=${plan_name} |
    ...  | Validate Plan From NOM |  plan_name=${plan_name} |
    ...  | Deintegrate NE From NOM  | ne_type=fhgw | deintegration_type=rest |
    ...  | Nom Rest Logout |
    ...
    ${type_string}  Evaluate   type(${mo_dict_list})
    Should Be True   "list" in """${type_string}"""   mo_dict_list should be a list and its member type is dictionary, please read KW example.
    ${mo_number}   Get Length   ${mo_dict_list}
    ${plan_content}   Run Keyword If  ${mo_number}>1  _Generate NOM Delta Plan For Complex Parameters For Multiple MO
                  ...   ne_type=${ne_type}  plan_name=${plan_name}
                  ...   mo_dict_list=${mo_dict_list}  gnb_index=${gnb_index}  vdu_index=${vdu_index}
       ...   ELSE
             ...      _Generate NOM Delta Plan For Complex Parameters For One MO    ne_type=${ne_type}  plan_name=${plan_name}
             ...      mo_dict=${mo_dict_list[0]}   gnb_index=${gnb_index}  vdu_index=${vdu_index}

    ${tmp_file_name}  Get Unique Id   prefix=NOM_plan_file_   precise=FORMAT_DATETIME   suffix=.xml
    ${plan_xml_file}   Get A File    NOM_plan_file   ${tmp_file_name}
    OperatingSystem.Create File   ${plan_xml_file}   ${plan_content}

    [Return]  ${plan_xml_file}


_Generate NOM Delta Plan For Complex Parameters For One MO
    [Arguments]  ${ne_type}  ${plan_name}   ${mo_dict}    ${gnb_index}=0   ${vdu_index}=0
    ${head}  _Generate NOM Provision Plan Head   plan_name=${plan_name}
    ${middle_part}  _Generate NOM Delta Plan For Complex Parameters For One MO Content   ne_type=${ne_type}   mo_dict=${mo_dict}
       ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${tail}  _Generate NOM Provision Plan Tail
    [Return]  ${head}${middle_part}${tail}


_Generate NOM Delta Plan For Complex Parameters For Multiple MO
    [Arguments]  ${ne_type}  ${plan_name}   ${mo_dict_list}    ${gnb_index}=0   ${vdu_index}=0
    ${head}  _Generate NOM Provision Plan Head   plan_name=${plan_name}
    ${middle_part}  _Generate NOM Delta Plan For Complex Parameters For Multiple MO Content   ne_type=${ne_type}   mo_dict_list=${mo_dict_list}
       ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${tail}  _Generate NOM Provision Plan Tail
    [Return]  ${head}${middle_part}${tail}


_Generate NOM Provision Plan Head
    [Arguments]  ${plan_name}
    ${line1}  set variable  <?xml version="1.0" encoding="UTF-8" standalone="yes"?><raml><cmData type="plan" scope="changes" name="${plan_name}">
    ${line1}  Set Variable  ${line1}<header>
    ${line2}   set variable   <log action="create" dateTime="2020-08-03T09:50:06Z" user="wsuser"/></header>

    [Return]   ${line1}${line2}


_Generate NOM Provision Plan Tail
    ${line1}  set variable  </cmData></raml>
    [Return]   ${line1}


_Generate NOM Delta Plan For Complex Parameters For One MO Content
    [Arguments]  ${ne_type}     ${mo_dict}   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  _Generate NOM Delta Plan For Complex Parameters For One MO Content
    ...  author:             chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type      |  yes  |  ne_type, vcu or vdu |
    ...    |  mo_dict     |  yes  |  mo_dict,  |
    ...    |  gnb_index  |  no  | gnb_index, default is 0  |
    ...    |  vdu_index  |  no  | vdu_index, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...
    ${distName}     Set Variable   ${mo_dict["distname"]}
    Should Not Be Empty   ${distName}

    ${r_class}   ${class}   Run Keyword And Ignore Error   Set Variable   ${mo_dict["class"]}
    ${class}   Set Variable If   "${r_class}"=="PASS"   ${class}   ${EMPTY}

    ${r_version}   ${version}   Run Keyword And Ignore Error   Set Variable   ${mo_dict["version"]}
    ${version}   Set Variable If   "${r_version}"=="PASS"   ${version}   ${EMPTY}

    ${r_operation}   ${operation}   Run Keyword And Ignore Error   Set Variable   ${mo_dict["operation"]}
    ${operation}   Set Variable If   "${r_operation}"=="PASS"   ${operation}   update
    Should Be True   "${operation}"=="update" or "${operation}"=="create" or "${operation}"=="delete"

    ${parameters}    Set Variable   ${mo_dict["parameters"]}

    ${ne_type}  Set Variable   ${ne_type.upper()}
    ${ne_type}  Set Variable If   "${ne_type}"=="CU"  VCU   ${ne_type}

    ${mo_attr_dict}  Run Keyword If  "${class}"=="${EMPTY}" or "${version}"=="${EMPTY}"
       ...   Get MO Attribute By NE Type   ne_type=${ne_type}  distname=${distname}   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${final_class}  Set Variable If  "${class}"=="${EMPTY}"   ${mo_attr_dict["class"]}   ${class}
    ${final_version}  Set Variable If  "${version}"=="${EMPTY}"   ${mo_attr_dict["version"]}   ${version}

    #managedObject start
    ${line_start}  Set Variable
        ...   <managedObject class="${final_class}" distName="${distname}" operation="${operation}" version="${final_version}">

    #parameters
    ${keys}   Get Dictionary Keys   ${parameters}
    ${rtn_simple_parameter_dict}   ${rtn_list_parameter_dict}    _Get Parameter Information For Complex Parameters    parameters=${parameters}

    ${parameters_part}   Set Variable   ${EMPTY}
    ${keys}   Get Dictionary Keys   ${rtn_simple_parameter_dict}
    FOR   ${key}  IN   @{keys}
       ${parameters_part}  Set Variable   ${parameters_part}<p name="${key}">${rtn_simple_parameter_dict["${key}"]}</p>
    END

    _Delete Empty List Part For List Parameter   dict_paramters=${rtn_list_parameter_dict}

    ${parameters_list_part}  _Generate MO Content For List Parameter    list_paramters=${rtn_list_parameter_dict}
    ${parameters_part}  Set Variable   ${parameters_part}${parameters_list_part}

    #managedObject end
    ${line_end}    Set Variable   </managedObject>

    [Return]  ${line_start}${parameters_part}${line_end}


_Delete Empty List Part For List Parameter
    [Arguments]  ${dict_paramters}
    Return From Keyword If   ${dict_paramters.__len__()}==0   ${EMPTY}

    ${keys}   Get Dictionary Keys   ${dict_paramters}
    FOR   ${key}  IN   @{keys}
       ${value}  Set Variable   ${dict_paramters["${key}"]}
       Collections.Remove Values From List   ${value}  ${None}
    END


_Generate MO Content For List Parameter
    [Arguments]  ${list_paramters}
    Return From Keyword If   ${list_paramters.__len__()==0}   ${EMPTY}

    ${rtn}   Set Variable   ${EMPTY}
    ${keys}   Get Dictionary Keys   ${list_paramters}
    FOR   ${key}  IN   @{keys}
       ${rtn}  Set Variable   ${rtn}<list name="${key}">
       ${current_items}  Set Variable   ${list_paramters["${key}"]}
       ${rtn}   _Get Full List Content   previous_content=${rtn}   current_items=${current_items}
       ${rtn}  Set Variable   ${rtn}</list>
    END
    [Return]  ${rtn}


_Get Full List Content
    [Arguments]  ${previous_content}   ${current_items}
    ${rtn}   Set Variable   ${EMPTY}
    FOR   ${item_dict}  IN  @{current_items}
       ${rtn}   Set Variable  ${rtn}<item>
       ${current_item_content}  _Get One Item Content   item_dict=${item_dict}
       ${rtn}   Set Variable  ${rtn}${current_item_content}</item>
    END
    [Return]  ${previous_content}${rtn}


_Get One Item Content
    [Arguments]  ${item_dict}
    ${keys}  Get Dictionary Keys   ${item_dict}
    ${rtn}   Set Variable   ${EMPTY}
    FOR  ${key}  IN  @{keys}
       ${rtn}  Set Variable   ${rtn}<p name="${key}">${item_dict["${key}"]}</p>
    END
    [Return]  ${rtn}


_Get Parameter Information For Complex Parameters
    [Arguments]  ${parameters}
    [Documentation]  _Get Parameter Information For Complex Parameters
    ...  author:             chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  parameters      |  yes  |  parameters |
    ...
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...
    ${keys}   Get Dictionary Keys   ${parameters}
    ${parameters_part}   Set Variable   ${EMPTY}

    ${rtn_simple_parameter_dict}   Create Dictionary
    ${rtn_list_parameter_dict}  Create Dictionary

    #maximizatin 10 items
    ${zero_list}   Create List   ${None}   ${None}   ${None}   ${None}   ${None}   ${None}   ${None}   ${None}   ${None}  ${None}

    FOR   ${key}  IN   @{keys}
       ${parameter_value}  Set Variable   ${parameters["${key}"]}
       #it's a simple parameter
       Run Keyword If   "/" not in """${key}"""   Set To Dictionary  ${rtn_simple_parameter_dict}   ${key}   ${parameter_value}
       Continue For Loop If   "/" not in """${key}"""
       #Begin to process list parameter
       Run Keyword If   ${key.startswith('/')}   Fail  Can't start with '/' for parameter name:${key} !
       ${parameter_name_list}   String.Split String   ${key}   /
       ${list_name}  Set Variable   ${parameter_name_list[0]}
       ${list_item_index}  Set Variable   ${parameter_name_list[1]}
       ${list_item_parameter_name}  Set Variable   ${parameter_name_list[2]}
       ${list_item_parameter_value}  Set Variable   ${parameter_value}
       ${rtn_list_parameter_dict_keys}   Get Dictionary Keys   ${rtn_list_parameter_dict}

       ${new_empty_list}  Run Keyword If   "${list_name}" not in ${rtn_list_parameter_dict_keys}   Collections.Copy List  ${zero_list}
       Run Keyword If   "${list_name}" not in ${rtn_list_parameter_dict_keys}
       ...   Set To Dictionary  ${rtn_list_parameter_dict}     ${list_name}    ${new_empty_list}
       ${current_parameter_items}   Collections.Get From Dictionary   ${rtn_list_parameter_dict}   ${list_name}

       ${item_j}  Get From List   ${current_parameter_items}   ${list_item_index}
       ${item_j_type}   Evaluate   type(${item_j})

       ${new_dict}   Run Keyword If   """dict""" not in """${item_j_type}"""   Create Dictionary   ${list_item_parameter_name}=${parameter_value}
       Run Keyword If   """dict""" not in """${item_j_type}"""
        ...   Collections.Set List Value   ${current_parameter_items}   ${list_item_index}  ${new_dict}

       #now ${item_j} is valid for both 1st time usage or non-1st time usage
       ${item_j}  Get From List   ${current_parameter_items}   ${list_item_index}

       #for 1st time parameter, we will set it two times, but there is no side-effect
       Set To Dictionary      ${item_j}   ${list_item_parameter_name}   ${parameter_value}
    END

    [Return]  ${rtn_simple_parameter_dict}   ${rtn_list_parameter_dict}


_Generate NOM Delta Plan For Complex Parameters For Multiple MO Content
    [Arguments]  ${ne_type}     ${mo_dict_list}   ${gnb_index}=0   ${vdu_index}=0
    ${multiple_mo_content}  Set Variable   ${EMPTY}
    FOR  ${mo_dict}  IN   @{mo_dict_list}
       ${one_mo_content}   _Generate NOM Delta Plan For Complex Parameters For One MO Content
       ...    ne_type=${ne_type}     mo_dict=${mo_dict}   gnb_index=${gnb_index}   vdu_index=${vdu_index}
       ${multiple_mo_content}   Set Variable   ${multiple_mo_content}${one_mo_content}
    END

    [Return]  ${multiple_mo_content}


Get MO Attribute By NE Type
    [Arguments]  ${ne_type}  ${distname}  ${gnb_index}=0  ${vdu_index}=0
    [Documentation]  Get MO Attribute By NE Type
    ...  author:             chris.l.cao@nokia-sbell.com
    ...  modified by:
    ...    21.1.2022, chris.l.cao@nokia-sbell.com, add FHGW
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type      |  yes  |  ne_type, vcu or vdu |
    ...    |  distname     |  yes  |  distname, e.g, MRBTS-123/NRBTS-123/NRCELL-1 |
    ...    |  gnb_index  |  no  | gnb_index, default is 0  |
    ...    |  vdu_index  |  no  | vdu_index, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...    dictionary of MO attribute, e.g,
    ...    {
    ...        'class': 'com.nokia.srbts.nrbts:NRCELL'
    ...        'version': 'NRBTSVDU22R2_2113_100'
    ...    }
    ...
    ...    Example
    ...  | ${mo_attr_dict}  Get MO Attribute By NE Type | ne_type=VCU |  distname=MRBTS-123/NRBTS-123/NRCELL-1 |
    ...  | ${mo_attr_dict}  Get MO Attribute By NE Type | ne_type=VDU |  distname=MRBTS-123/NRBTS-123/NRCELL-1 |
    ...
    ${ne_type}  Set Variable   ${ne_type.upper()}
    ${ne_type}  Set Variable If   "${ne_type}"=="CU"  VCU   ${ne_type}

    ${scf_path}   Run Keyword If  "${ne_type}"=="VCU"   Get VCU SCF From Current Plan   gnb_index=${gnb_index}
    ...   ELSE IF  "${ne_type}"=="VDU" or "${ne_type}"=="FHGW"  Get VDU SCF From Current Plan   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ...   ELSE   Fail   Does not support ne_type:${ne_type}!

    scf.Load_Scf  file_path=${scf_path}
    ${class}  scf.Get_Mo_Attribute   dist_name=${distname}  attribute=class
    ${version}  scf.Get_Mo_Attribute   dist_name=${distname}  attribute=version

    ${rtn}   Create Dictionary   class=${class}    version=${version}
    [Return]  ${rtn}


NOM Get Active Alarms Via Rest
   [Arguments]    ${integrated_id}
   [Documentation]    Logout NOM via rest api.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <04-02-2021>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  integrated_id  |  Yes  |  integrated id  |

    ...    *RETURN VALUE*
    ...    Alarms list
    ...    Example
    ...    |  NOM Get Active Alarms Via Rest  |  integrated_id= HQZ-VDU/MRBTS-5253  |
#    ${client_id}=  Nom Rest Login
    Nom Rest Login
    ${alarms_info}=  nom_rest.get_alarms_from_integrated_ne  integrated_id=${integrated_id}    only_active=${True}
#   ${all_alarms}  nom_rest.get_active_alarms
    [Return]   ${alarms_info["alarms"]}


_Nom Rest Login With Nom Info From init.py
    [Documentation]    _Nom Rest Login With Nom Info From init.py
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <01-02-2021>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	  None
    ...
    ...    *RETURN VALUE*
    ...    Client id
    ...    Example
    ...    |  ${client_id}  |  _Nom Rest Login With Nom Info From init.py  |

    ${client_id}=  get unique id
    ${client_secret}=  nom_rest.register_the_client   client_id=${client_id}
    ...       username=${tl.nms.nom.https_main_info.username}
    ...       password=${tl.nms.nom.https_main_info.password}
    ...       apigw_uri=${tl.nms.nom.https_rest_info.addr}
    nom_rest.connect_to  user_mgmt_uri=${tl.nms.nom.https_user_mgmt_info.addr}
    ...    apigw_uri=${tl.nms.nom.https_rest_info.addr.split("//")[-1]}
    ...    client_id=${client_id}
    ...    client_secret=${client_secret}
    ...    port=${443}
    ...    username=${tl.nms.nom.https_main_info.username}
    ...    password=${tl.nms.nom.https_main_info.password}
    ...    nom_version=${NOM_1_VERSION}
    ...    secure=${True}
    [Return]   ${client_id}


_Nom Rest Login With Nom Info From global_variable.py
    [Arguments]    ${nom_label}=${None}
    [Documentation]    _Nom Rest Login With Nom Info From global_variable.py
    ...  *author*:  huilin.xu@nokia-sbell.com
    ...  *modified by*
    ...  | date | who | what or how |
    ...  | 14-10-2021 | huilxu | initial created |
    ...  | 07-02-2022 | r3li | support login with appointed nom |
    ...  | 09-02-2022 | r3li | fix the error of TARGET_NOM_INFO not found when logout |
    ...  *Aruments Description*
    ...  | Input Parameters | Man. | Description |
    ...	 | nom_label | No | string, nom_label, such as NOM4,NOM10,default value is None will login with useful nom in global_variables.py |
    ...  *Example*
    ...  | ${client_id}  |  _Nom Rest Login With Nom Info From global_variable.py   |
    ...
    ...  *RETURN VALUE*
    ...  - Client id

    ${NOM_INFO}   Run Keyword If   '${nom_label}'=='${None}'   Get Target NOM server
    ...   ELSE   Get Appointed Nom Info By Label    ${nom_label}

    ${TARGET_NOM_INFO}    Run Keyword If    '${nom_label}'=='${None}'   Set Variable   ${NOM_INFO}[1]
    ...  ELSE   Set Variable    ${NOM_INFO}

    ${client_id}   _Nom Rest Login Via Target Nom Info    ${TARGET_NOM_INFO}
    set suite variable   ${TARGET_NOM_INFO}
    [Return]   ${client_id}


_Nom Rest Login Via Target Nom Info
    [Arguments]  ${nom_info}
    [Documentation]    _Nom Rest Login Via Target Nom Info
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <14-10-2021>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  nom_info  |  Yes  |  the nom info returned by Get Target NOM server  |
    ...    *RETURN VALUE*
    ...    Client id
    ...
    ...    Example
    ...    | ${nom_index}  |  ${target_nom}  |  Get Target NOM server  |
    ...    | ${client_id}  |   _Nom Rest Login Via Target Nom Info  |  ${target_nom}  |
    ...
    ${username}   Set Variable  ${nom_info["main_info"].https_main_info.username}
    ${password}    Set Variable  ${nom_info["main_info"].https_main_info.password}
    ${apigw_uri}   Set Variable  ${nom_info["main_info"].https_rest_info.addr}

    ${client_id}=  get unique id

    ${client_secret}   nom_rest.register_the_client   client_id=${client_id}
    ...       username=${username}
    ...       password=${password}
    ...       apigw_uri=${apigw_uri}

    ${user_mgmt_uri}   Set Variable  ${nom_info["main_info"].https_user_mgmt_info.addr}
    ${apigw_uri}   Set Variable  ${nom_info["main_info"].https_rest_info.addr.split("//")[-1]}
    ${nom_version}  Set Variable  ${nom_info["version"]}

    nom_rest.connect_to  user_mgmt_uri=${user_mgmt_uri}
    ...    apigw_uri=${apigw_uri}
    ...    client_id=${client_id}
    ...    client_secret=${client_secret}
    ...    port=${443}
    ...    username=${username}
    ...    password=${password}
    ...    nom_version=${nom_version}
    ...    secure=${True}

    sleep  12
    [Return]   ${client_id}



Import SW Package From NOM By REST API
    [Arguments]    ${package_file_path}   ${ne_type}=MRBTS   ${file_name}=None   ${sw_version}=None   ${nom_label}=None
    [Documentation]  Import SW Package From NOM By REST API
    ...  author:             jianlin.zhang@nokia-sbell.com
    ...  modified by:        <07-06-2021>, <jianlin>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  package_file_path  |  Yes  |  sw package file path for import  |
    ...    |  ne_type  |  Yes  |  [MRBTS, SMM. FHGW] on the list, default for vDU is MRBTS  |
    ...    |  file_name  |  No  |  5G_0.300.1000_pdl_validation_service_plugin.zip |
    ...    |  ne_sw_version  |  No  |  5G_0.300.1000  |
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  Import SW Package From NOM By REST API |
    ...     package_file_path=ute/home/xxx/5G_0.300.1000_pdl_validation_service_plugin.zip  |
    log to console   Import SW Package From NOM By REST API
    #${client_id}  Wait Until Keyword Succeeds  180  10   Nom Rest Login
    ${client_id}    Nom Rest Login   ${nom_label}
    ${neSwVersion}  Wait Until Keyword Succeeds  180  10  nom_rest.get_sw_package_list
    ${version_exist}=  set variable   ${False}
    FOR  ${item}  IN  @{neSwVersion}
        run keyword if  '${item['ne_sw_version']}' == '${sw_version}'  Set Test Variable  ${version_exist}  ${True}
    END
    Wait Until Keyword Succeeds  180  10   run keyword if  ${version_exist}==${False}
    ...  nom_rest.import_sw_package  file_path=${package_file_path}  ne_type=${ne_type}
    ...  ELSE   log to console  Currnet SW Package already exist on NOM.
    sleep    10
    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    client_id=${client_id}


Activate Autoconfiguration Plan From NOM By REST API For vDU
    [Arguments]     ${plan_name}   ${apply_templates}=${True}   ${validate}=${True}   ${overwrite}=${True}   ${timeout}=300
    ...    ${nom_label}=None
    [Documentation]  Activate Autoconfiguration Plan From NOM should be successfully
    ...  author:             jianlin.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  PLAN_NAME  |  Yes  |  plan name for import plan  |
    ...    | apply_templates |  Yes | If set to true, complement plan operation will be performed |
    ...    | validate | Yes | If set to true, offline plan validation will be performed |
    ...    | timeout | Yes | Time to wait for the response of the current operation |
    ...    | overwrite | NO | Users can optionally specify if already activated configuration should be overwritten.
    ...    If not provided, the operation will fail for already activated configurations |
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  Activate Autoconfiguration Plan From NOM By REST API For vDU |  plan_name=MRBTS_5326_xxx |
    ...       apply_templates={True}| validate={True} | overwrite={True} | timeout=10
    #${client_id}  Wait Until Keyword Succeeds  180  10    Nom Rest Login
    ${client_id}     Nom Rest Login   ${nom_label}
    ${operation_result}  nom_rest.activate_autoconfiguration   plan_name=${plan_name}
    ...  apply_templates=${apply_templates}   validate=${validate}   overwrite=${overwrite}   timeout=${timeout}
    FOR  ${item}  IN  @{operation_result}
        run keyword if  '${item['status']}' == 'finished'  log to console  Active Auto-configuration Plan Success!
    END
    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    client_id=${client_id}


NOM Configure Cmp Server
    [Arguments]   ${list_integrated_ids}   ${dict_cmp_attributes}  ${timeout}=240
    [Documentation]   NOM Configure Cmp Server
    ...  author:  chris.l.cao@nokia-sbell.com
    ...    14.2.2023, chris.l.cao@nokia-sbell.com, initialization to fix CRT error
    ...
    ...  | Input Parameters | Man. | Description |
    ...  | list_integrated_ids | yes | (list[str]), integrated network element identifiers for which user account password is to be changed |
    ...  | dict_cmp_attributes | yes | (dict[str, str]) – CMP server attributes which needs to be configured |
    ...  | timeout             | no  | (Union[int,str]) – timout value, default is 240 seconds |
    ...
    ...    *RETURN VALUE*
    ...   Return list[dict], every dict contains operation_id, status and timestamp attributes. Like,
    ...   [
    ...    {
    ...        'operation_id': 'e95f06a1a2a6418280ba05db1b16ba44',
    ...        'status': 'queuing',
    ...        'timestamp': '2020-12-15T14:06:26.833458Z'
    ...    }
    ...   ]
    ...
    ...    Example
    ...
    ${ret}  nom_rest.configure_cmp  integrated_ids=${list_integrated_ids}
     ...   cmp_attributes=${dict_cmp_attributes}  timeout=${timeout}
    [Return]  ${ret}
