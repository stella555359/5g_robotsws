*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   nom_oam_integration.robot



*** Variables ***



*** Keywords ***
_Generate NOM Integrate xml File With TLS
    [Arguments]   ${Plan_name}   ${mrbts_id}    ${oam_ip}  ${ne_id}   ${CACert}
    ${xml1}   set variable   <?xml version="1.0" encoding="UTF-8"?><raml xmlns="raml21.xsd" version="2.1">
    ${xml2}   set variable   <cmData type="plan" scope="all" name="${Plan_name}">
    ${xml3}   set variable   <managedObject class="com.nokia.nms.integration:NE3SINT" distName="${mrbts_id}/NE3SINT-PREDEFINED"
    ${xml4}   set variable   ${SPACE}operation="create" version="1.0"><p name="host">${oam_ip}</p><p name="port">8443</p>
    ${xml5}   set variable   <p name="neType">MRBTS</p><p name="neId">${ne_id}</p><p name="username">wsuser</p><p name="password">A0zY~rP#8Mx@</p>
    ${xml6}   set variable   <p name="sbiNetConnectedTo">sbi-default-ipv4</p><p name="timezone">Europe/Helsinki</p>
    ${xml7}   set variable   <p name="tlsHostNameCheck">False</p><p name="tlsCA"><![CDATA[${CACert}]]></p></managedObject></cmData></raml>
    ${xmlfile}   set variable   ${xml1}${xml2}${xml3}${xml4}${xml5}${xml6}${xml7}
    [Return]   ${xmlfile}


_Generate NOM Integrate xml File Without TLS
    [Arguments]   ${Plan_name}   ${mrbts_id}    ${oam_ip}  ${ne_id}
    ${xml1}   set variable   <?xml version="1.0" encoding="UTF-8"?><raml xmlns="raml21.xsd" version="2.1">
    ${xml2}   set variable   <cmData type="plan" scope="all" name="${Plan_name}">
    ${xml3}   set variable   <managedObject class="com.nokia.nms.integration:NE3SINT" distName="${mrbts_id}/NE3SINT-PREDEFINED"
    ${xml4}   set variable   ${SPACE}operation="create" version="1.0"><p name="host">${oam_ip}</p><p name="port">8080</p>
    ${xml5}   set variable   <p name="neType">MRBTS</p><p name="neId">${ne_id}</p><p name="username">wsuser</p><p name="password">A0zY~rP#8Mx@</p>
    ${xml6}   set variable   <p name="sbiNetConnectedTo">sbi-default-ipv4</p><p name="timezone">Europe/Helsinki</p>
    ${xml7}   set variable   </managedObject></cmData></raml>
    ${xmlfile}   set variable   ${xml1}${xml2}${xml3}${xml4}${xml5}${xml6}${xml7}
    [Return]   ${xmlfile}


Integrate NE To NOM
   [Arguments]   ${ne_type}=cu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0    ${password}=A0zY~rP#8Mx@
   ...    ${nom_integrate_link}=http://nei-bot-svc.neo.svc.cluster.local/api/  ${security_mode}=No TLS   ${integration_type}=cli
   [Tags]  NOM_CM
   [Documentation]    Integrate ne to nom by ne type, ne index and which nom will be integrated to.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <4-Jun-2020>, <f2huang>, <initial created>
    ...  modified by:        <16-Sep-2020>, <f2huang>, <Update it to generate config file automaticly>
    ...  modified by:        <14-Oct-2020>, <huilxu>, <add security_mode and integration_type>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  No  |  Which type of ne will be integrated, can be cu/vdu/fhgw, cu in default   |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...    | security_mode | No | 'TLS' or 'No TLS'. TLS: Transport Layer Security supported  |
    ...    | integration_type | No | the type of using Nom, can be cli/rest/selenium, cli in default  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Integrate NE To NOM  |  ne_type=vdu  |  security_mode=TLS  |  integration_type=rest  |
    ...   | ${btsName} | Get Parameter Value Via NOM For VDU | dist_name=MRBTS-1234 | parameter_name=btsName |
    ...    | Deintegrate NE From NOM |  ne_type=vdu |  deintegration_type=rest  |
    ...    | NOM Rest Logout |
    ...
    ...    | Integrate NE To NOM  |  ne_type=cu  |  security_mode=TLS  |  integration_type=rest  |
    ...    | Deintegrate NE From NOM |  ne_type=cu |  deintegration_type=rest  |
    ...    | NOM Rest Logout |
    ...
    ...
    Run Keyword If   "${integration_type}"=="cli"  Fail   Does not support integration with CLI!!!!

    Run Keyword If   "${integration_type}"=="rest"  _Integrate NE To NOM Via Rest
    ...  ne_type=${ne_type}   gnb_index=${gnb_index}   vdu_index=${vdu_index}    fhgw_index=${fhgw_index}
    ...  security_mode=${security_mode}
    ...  ELSE IF    "${integration_type}"=="selenium"  _Integrate NE To NOM Via selenium
    ...  ne_type=${ne_type}   gnb_index=${gnb_index}   vdu_index=${vdu_index}    fhgw_index=${fhgw_index}


#_Integrate NE To NOM Via Cli
#   [Arguments]   ${ne_type}=cu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0    ${password}=A0zY~rP#8Mx@
#   ...    ${nom_integrate_link}=http://nei-bot-svc.neo.svc.cluster.local/api/
#   [Documentation]    Integrate ne to nom by ne type, ne index and which nom will be integrated to.
#    ...  author:             fen.huang@nokia-sbell.com
#    ...  modified by:        <4-Jun-2020>, <f2huang>, <initial created>
#    ...  modified by:        <16-Sep-2020>, <f2huang>, <Update it to generate config file automaticly>
#    ...    | Input Parameters | Man. | Description |
#    ...    |  ne_type  |  No  |  Which type of ne will be integrated, can be cu/vdu/fhgw, cu in default   |
#    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
#    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
#    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
#    ...
#    ...    *RETURN VALUE*
#    ...    None
#    ...    Example
#    ...    |  Integrate NE To NOM  |  cu   |  1  |
#    ...    |  Integrate NE To NOM  |  vdu   |  0  |  0 |
#   ${path_of_config_file}   ${integrate_config_file_name}   ${deintegrate_config_file_name}=
#   ...    Upload Integration Config File To NOM    ${ne_type}   ${gnb_index}  ${vdu_index}   ${fhgw_index}  ${password}
#   ${file_name_obj}=     Split String    ${integrate_config_file_name}   .
#   ${file_prefix}=  set variable  ${file_name_obj[0]}
#   ${opt_1}=  set variable  auto-integrate?dryRun
#   ${opt_2}=  set variable  auto-integrate?verbose
#   ${opt_3}=  set variable  -H 'Content-type: application/json'
#   ${nom_link}=   set variable   ${nom_integrate_link}
#   ${cmd_1}=  set variable
#   ...    curl -s '${nom_link}${opt_1}' ${opt_3} -d @${integrate_config_file_name} |jq '.' > ${file_prefix}__output_ne_data.json
#   ${cmd_2}=  set variable
#   ...    curl -s '${nom_link}${opt_2}' ${opt_3} -d @${integrate_config_file_name} |jq '.' > ${file_prefix}__output_integrate_result.json
#   ${integrate_logs}=  Get A Directory  integrate_logs
#   ${connection}=  SSH To NOM
#   issh.execute   rm -rf ${integrate_logs}/${file_prefix}__output_ne_data.json  check_result=${False}   alias=${connection}
#   issh.execute   rm -rf ${integrate_logs}/${file_prefix}__output_integrate_result.json  check_result=${False}   alias=${connection}
#   issh.execute    cd ${path_of_config_file}   check_result=${False}   alias=${connection}
#   : FOR    ${inte_num}    IN RANGE    1      4
#   \  log to console   \n*** Start execute ${ne_type} integrate command : ${inte_num} execute***
#   \  log to console   ${cmd_1}
#   \  issh.execute     ${cmd_1}   check_result=${False}   alias=${connection}
#   \  log to console   ${cmd_2}
#   \  issh.set_timeout   300     alias=${connection}
#   \  issh.execute     ${cmd_2}   check_result=${False}   alias=${connection}
#   \  log to console    \n*** Download ${ne_type} integrate log to local***
#   \  issh.download_file    ${path_of_config_file}/${file_prefix}__output_ne_data.json    ${integrate_logs}/   alias=${connection}
#   \  issh.download_file    ${path_of_config_file}/${file_prefix}__output_integrate_result.json     ${integrate_logs}/   alias=${connection}
#   \  log to console   \n*** Check ${ne_type} integrate log***
#   \  ${res_inte}   Check NE Integrate Result   ${integrate_logs}/${file_prefix}__output_integrate_result.json
#   \  sleep  1s
#   \  Exit For Loop IF   ${res_inte}==1
#   \  Run Keyword And Ignore Error  Deintegrate NE From NOM  ${ne_type}
#   \  run keyword if  ${inte_num}==3  should be true  ${re_inte}=1
#   [Teardown]  Disconnect Interactive Connection  alias=${connection}


_Integrate NE To NOM Via Rest
   [Arguments]   ${ne_type}=vdu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0    ${security_mode}=No TLS
   [Documentation]    _Integrate NE To NOM Via Rest
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <14-Oct-2020>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  No  |  Which type of ne will be integrated, can be vcu/cu/vdu/fhgw, vdu in default |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...    | security_mode | No | 'TLS' or 'No TLS'. TLS: Transport Layer Security supported  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Integrate NE To NOM Via Rest  |  ne_type=vdu  |  security_mode=TLS  |
    ...
    ${ne_type}  Set Variable If  "${ne_type}"=="cu"    vcu  ${ne_type}
    NMS Port Should Listen In NE  ne_type=${ne_type}   security_mode=${security_mode}
       ...   gnb_index=${gnb_index}    vdu_index=${vdu_index}   fhgw_index=${fhgw_index}

#    Firewall Between NOM and NE Should Be Good   ne_type=${ne_type}   security_mode=${security_mode}
#       ...   gnb_index=${gnb_index}    vdu_index=${vdu_index}   fhgw_index=${fhgw_index}

    Run Keyword If  "${ne_type}"=="vcu"  _Integrate NE To NOM Via Rest For VCU
    ...  gnb_index=${gnb_index}   security_mode=${security_mode}
    ...  ELSE IF  "${ne_type}"=="vdu"  _Integrate NE To NOM Via Rest For VDU
    ...    gnb_index=${gnb_index}   vdu_index=${vdu_index}    security_mode=${security_mode}
    ...  ELSE IF  "${ne_type}"=="fhgw"  _Integrate NE To NOM Via Rest For FHGW
    ...    fhgw_index=${fhgw_index}


_Integrate NE To NOM Via Rest For VCU
   [Arguments]   ${gnb_index}=0   ${security_mode}=No TLS
   [Documentation]    _Integrate NE To NOM Via Rest For VCU
    ...    *Author*  chris.l.cao@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | what or how |
    ...    | 14-Oct-2020 | chricao | initial created |
    ...    | 2022-5-12 | r3li | add function |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    | security_mode | No | 'TLS' or 'No TLS'. TLS: Transport Layer Security supported  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    *Example*
    ...    | _Integrate NE To NOM Via Rest For VCU | gnb_index=0 | security_mode=TLS |
    ${r}   Run Keyword And Return Status   Variable Should Exist   ${NOM_REST_LOGIN_CLIENT_ID}
    ${need_rest_login}   Set Variable If  "${r}"=="${False}"  1   "${NOM_REST_LOGIN_CLIENT_ID}"=="${None}"  1   0
    Run Keyword If   "${need_rest_login}"=="1"   Nom Rest Login

    ${integrate_plan}  ${Plan_name}  Run Keyword If  "${security_mode}"=="No TLS"
    ...  Prepare VCU NOM Integrate Plan File Without TLS  gnb_index=${gnb_index}
    ...  ELSE IF  "${security_mode}"=="TLS"    Prepare VCU NOM Integrate Plan File With TLS  gnb_index=${gnb_index}
   nom_rest.import_plan  path_to_plan=${integrate_plan}  name=${Plan_name}   plan_type=INTEGRATION
   sleep  10
   nom_rest.integrate_ne  plan_name=${Plan_name}  timeout=300   reintegrate=${True}
   Sleep  10


_Integrate NE To NOM Via Rest For VDU
   [Arguments]   ${gnb_index}=0   ${vdu_index}=0  ${security_mode}=No TLS
   [Documentation]    _Integrate NE To NOM Via Rest For VDU
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <14-Oct-2020>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    | security_mode | No | 'TLS' or 'No TLS'. TLS: Transport Layer Security supported  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Integrate NE To NOM Via Rest For VDU  |  gnb_index=0  |  vdu_index=0  |  security_mode=TLS  |
    ...
    ${r}   Run Keyword And Return Status   Variable Should Exist   ${NOM_REST_LOGIN_CLIENT_ID}
    ${need_rest_login}   Set Variable If  "${r}"=="${False}"  1   "${NOM_REST_LOGIN_CLIENT_ID}"=="${None}"  1   0
    Run Keyword If   "${need_rest_login}"=="1"   Nom Rest Login

    ${integrate_plan}  ${Plan_name}  Run Keyword If  "${security_mode}"=="No TLS"
         ...  Prepare VDU NOM Integrate Plan File Without TLS  gnb_index=${gnb_index}  vdu_index=${vdu_index}
   ...  ELSE IF  "${security_mode}"=="TLS"
         ...  Prepare VDU NOM Integrate Plan File With TLS  gnb_index=${gnb_index}  vdu_index=${vdu_index}
   nom_rest.import_plan  path_to_plan=${integrate_plan}  name=${Plan_name}   plan_type=INTEGRATION
   sleep  10
   nom_rest.integrate_ne  plan_name=${Plan_name}  timeout=300   reintegrate=${True}
   Sleep  10


Prepare VDU NOM Integrate Plan File With TLS
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]    Prepare VDU NOM Integrate Plan File With TLS
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <15-Oct-2020>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    |  ${integrate_plan} the file path of Integrate XML Plan File for vDU TLS  |
    ...    |  ${Plan_name} the name of Integrate XML Plan File for vDU TLS  |
    ...    Example
    ...    |  ${integrate_plan} |  ${Plan_name}  |  Prepare VDU NOM Integrate Plan File With TLS  |
    ...
    ${timestamp}    Get Timestamp

    ${mrbts_id}   ${ne_id}  Get MRBTS_ID And NE_ID Via VDU SCF  gnb_index=${gnb_index}  vdu_index=${vdu_index}

    ${vdu_oam_http_connection_info}   Get vDU OAM Http Connection Info  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${vdu_oam_ip}   set variable  ${vdu_oam_http_connection_info["addr"]}

    #${ca_file}=   get file    ${CURDIR}/nom/ca1_cacert
    ${ca_file_name}    Get Vdu Integrate To Nom Certificate File
    ${ca_file}     get file   ${ca_file_name}

    ${Plan_name}   Set Variable    ${mrbts_id}-TLS-Integrate-${timestamp}

    ${plan_file}    _Generate NOM Integrate xml File With TLS    ${Plan_name}   ${mrbts_id}    ${vdu_oam_ip}   ${ne_id}   ${ca_file}

    ${integrate_plan}  Get A File  Integrate_Plan  ${Plan_name}.xml
    create file   ${integrate_plan}   ${plan_file}
    [Return]   ${integrate_plan}  ${Plan_name}


Prepare VDU NOM Integrate Plan File Without TLS
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]    Prepare VDU NOM Integrate Plan File Without TLS
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   18.10.2021,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   NOM integration plan file for no TLS:
    ...     ${integrate_plan} the file path of Integrate XML Plan File for vDU TLS
    ...     ${Plan_name} the name of Integrate XML Plan File for vDU TLS
    ...
    ...    Example
    ...    |  ${integrate_plan} |  ${Plan_name}  |  Prepare VDU NOM Integrate Plan File Without TLS |
    ...
    ${timestamp}    Get Timestamp

    ${mrbts_id}   ${ne_id}  Get MRBTS_ID And NE_ID Via VDU SCF  gnb_index=${gnb_index}  vdu_index=${vdu_index}

    ${vdu_oam_http_connection_info}   Get vDU OAM Http Connection Info  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${vdu_oam_ip}   set variable  ${vdu_oam_http_connection_info["addr"]}

    ${Plan_name}   Set Variable    ${mrbts_id}-No_TLS-Integrate-${timestamp}

    ${plan_file}   _Generate NOM Integrate xml File Without TLS    ${Plan_name}   ${mrbts_id}    ${vdu_oam_ip}   ${ne_id}

    ${integrate_plan}  Get A File  Integrate_Plan  ${Plan_name}.xml
    create file   ${integrate_plan}   ${plan_file}
    [Return]   ${integrate_plan}  ${Plan_name}


_Integrate NE To NOM Via Rest For FHGW
   [Arguments]  ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
   [Documentation]     _Integrate NE To NOM Via Rest For FHGW.
    ...  author:            jie.8.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Integrate NE To NOM Via Rest For FHGW  |  0 |
    #${client_id}   Wait Until Keyword Succeeds  3x  10   Nom Rest Login
    ${client_id}    Nom Rest Login
    ${integrate_plan}  ${Plan_name}    _Generate FHGW integrate plan  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    nom_rest.import_plan  path_to_plan=${integrate_plan}  name=${Plan_name}   plan_type=INTEGRATION
    sleep  6s
    nom_rest.integrate_ne  plan_name=${Plan_name}  timeout=300  reintegrate=False
    [Teardown]  run keyword and ignore error  NOM Rest Logout  ${client_id}



_Integrate NE To NOM Via Selenium
   [Arguments]   ${ne_type}=cu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0
   [Documentation]    _Integrate NE To NOM Via Selenium
    ...  author:            chris.l.cao@nokia-sbell.com
    ...  modified by:        <15-Oct-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  No  |  Which type of ne will be integrated, can be cu/vdu/fhgw, cu in default   |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Integrate NE To NOM  |  cu   |  1  |
    ...    |  Integrate NE To NOM  |  vdu   |  0  |  0 |
    Fail   It's not supported yet!




Deintegrate NE From NOM
   [Arguments]   ${ne_type}=cu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0
   ...    ${nom_integrate_link}=http://nei-bot-svc.neo.svc.cluster.local/api/    ${deintegration_type}=rest
   [Documentation]    Deintegrate ne from nom by ne type, ne index and which nom will be deintegrated from.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:   <20-Oct-2020>, <f2huang@nokia-sbell.com>, <initial created>
    ...  modified by:  <15-Oct-2021>, <huilxu@nokia-sbell.com>, <add deintegration_type>
    ...  modified by:  <27-Jul-2022>, <chris.l.cao@nokia-sbell.com>, change deintegration_type default value from cli to rest
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  Yes  |  Which type of ne will be deintegrated, can be cu/vdu/fhgw   |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...    | deintegration_type | No | the type of using Nom, can be cli/rest/selenium, cli in default  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Integrate NE To NOM  |  ne_type=vdu  |  security_mode=TLS  |  integration_type=rest  |
    ...   | ${btsName} | Get Parameter Value Via NOM For VDU | dist_name=MRBTS-1234 | parameter_name=btsName |
    ...    | Deintegrate NE From NOM |  ne_type=vdu |  deintegration_type=rest  |
    ...    | NOM Rest Logout |
    ...
    ...    | Integrate NE To NOM  |  ne_type=cu  |  security_mode=TLS  |  integration_type=rest  |
    ...    | Deintegrate NE From NOM |  ne_type=cu |  deintegration_type=rest  |
    ...    | NOM Rest Logout |
    ...
    Run Keyword If   "${deintegration_type}"=="cli"  Fail   Does not support deintegration_type with CLI!!!!

    Run Keyword If    "${deintegration_type}"=="rest"  _Deintegrate NE To NOM Via Rest
   ...  ne_type=${ne_type}   gnb_index=${gnb_index}   vdu_index=${vdu_index}    fhgw_index=${fhgw_index}


_Deintegrate NE To NOM Via Rest
   [Arguments]   ${ne_type}=vdu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0
   [Documentation]    _Deintegrate NE To NOM Via Rest
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <14-Oct-2020>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  No  |  Which type of ne will be integrated, can be cu/vdu/fhgw, vdu in default   |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Deintegrate NE To NOM Via Rest |  ne_type=vdu |
   Run Keyword If  "${ne_type}"=="cu"  _Deintegrate NE To NOM Via Rest For vCU
    ...  gnb_index=${gnb_index}
    ...  ELSE IF  "${ne_type}"=="vdu"  _Deintegrate NE To NOM Via Rest For vDU
    ...    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ...  ELSE IF  "${ne_type}"=="fhgw"  _Deintegrate NE To NOM Via Rest For FHGW
    ...    fhgw_index=${fhgw_index}


_Deintegrate NE To NOM Via Rest For vCU
    [Arguments]   ${gnb_index}=0    ${force_deintegration}=${True}
    [Documentation]    _Deintegrate NE To NOM Via Rest For vCU
    ...    *Author*  huilin.xu@nokia-sbell.com
    ...    *Change History*:
    ...    | date | who | what or how |
    ...    | 14-Oct-2020 | huilxu | initial created |
    ...    | 2022-5-12 | r3li | add function |
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | cu index, should be 0, 1... |
    ...    | force_deintegration | No | is force deintegration, default is True |
    ...    *RETURN VALUE*
    ...    None
    ...    *Example*
    ...    | _Deintegrate NE To NOM Via Rest For vCU |  gnb_index=0 |
    ${r}   Run Keyword And Return Status   Variable Should Exist   ${NOM_REST_LOGIN_CLIENT_ID}
    ${need_rest_login}   Set Variable If  "${r}"=="${False}"  1   "${NOM_REST_LOGIN_CLIENT_ID}"=="${None}"  1   0
    Run Keyword If   "${need_rest_login}"=="1"   Nom Rest Login
    ${Deintegrate_plan}  ${Deintegrate_Plan_name}  Prepare VCU Deintegrate Plan File
    nom_rest.import_plan  path_to_plan=${Deintegrate_plan}  name=${Deintegrate_Plan_name}   plan_type=DEINTEGRATION
    sleep  6
    nom_rest.deintegrate_ne  plan_name=${Deintegrate_Plan_name}  timeout=120   force_deintegration=${force_deintegration}
    sleep  10

_Deintegrate NE To NOM Via Rest For FHGW
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Documentation]    _Deintegrate NE To NOM Via Rest For FHGW
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <14-Oct-2020>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Deintegrate NE To NOM Via Rest For FHGW |  fhgw_index=0 |

    #${client_id}   Wait Until Keyword Succeeds  60  10   Nom Rest Login
    ${client_id}    Nom Rest Login
    ${Deintegrate_plan}  ${Deintegrate_Plan_name}  _Generate FHGW Deintegrate plan  gnb_index=${gnb_index}   fhgw_index=${fhgw_index}

    nom_rest.import_plan  path_to_plan=${Deintegrate_plan}  name=${Deintegrate_Plan_name}   plan_type=DEINTEGRATION
    sleep  5s
    nom_rest.deintegrate_ne  plan_name=${Deintegrate_Plan_name}  timeout=120
    sleep  10
    NOM Rest Logout   ${client_id}


_Deintegrate NE To NOM Via Rest For vDU
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${force_deintegration}=${True}
    ...  ${purge_data}=${True}
    [Documentation]    _Deintegrate NE To NOM Via Rest For vDU
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <14-Oct-2020>, <huilxu>, <initial created>
    ...    14.10.2020, huilin.xu@nokia-sbell.com, initialization
    ...    5.2.2022, chris.l.cao@nokia-sbell.com, add parameter force_deintegration, default is ${True}, to improve stability
    ...    8.19.2022  Shubin.ren@nokia-sbell.com, add parameter  purge_data, default is ${True}, to remove data on the NOM
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Deintegrate NE To NOM Via Rest For vDU  |
    ...    |  _Deintegrate NE To NOM Via Rest For vDU  |  gnb_index=0  |  vdu_index=0  |
    ...

    ${r}   Run Keyword And Return Status   Variable Should Exist   ${NOM_REST_LOGIN_CLIENT_ID}
    ${need_rest_login}   Set Variable If  "${r}"=="${False}"  1   "${NOM_REST_LOGIN_CLIENT_ID}"=="${None}"  1   0
    Run Keyword If   "${need_rest_login}"=="1"   Nom Rest Login

    ${Deintegrate_plan}  ${Deintegrate_Plan_name}  Prepare VDU Deintegrate Plan File  gnb_index=${gnb_index}   vdu_index=${vdu_index}

    nom_rest.import_plan  path_to_plan=${Deintegrate_plan}  name=${Deintegrate_Plan_name}   plan_type=DEINTEGRATION
    sleep  6
    nom_rest.deintegrate_ne  plan_name=${Deintegrate_Plan_name}  timeout=120   force_deintegration=${force_deintegration}
    ...  purge_data=${purge_data}
    sleep  10


Prepare VDU Deintegrate Plan File
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]    Prepare VDU Deintegrate Plan File
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <15-Oct-2020>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    |  ${Deintegrate_plan} the file path of Deintegrate XML Plan File for vDU  |
    ...    |  ${Deintegrate_Plan_name} the name of Deintegrate XML Plan File for vDU  |
    ...    Example
    ...    |  ${Deintegrate_plan} |  ${Deintegrate_Plan_name}  |   Prepare VDU Deintegrate Plan File  |
    ${timestamp}    Get Timestamp
    log to console    ${timestamp}

    ${MRBTS_ID}   ${NE_ID}  Get MRBTS_ID And NE_ID Via VDU SCF  gnb_index=${gnb_index}   vdu_index=${vdu_index}

    ${Deintegrate_Plan_name}   Set Variable    ${MRBTS_ID}-Deintegrate-${timestamp}

    ${xmlfile}  _Generate VDU Deintegrate xml File  ${MRBTS_ID}

    ${Deintegrate_plan}  Get A File  Deintegrate_Plan  ${Deintegrate_Plan_name}.xml
    create file   ${Deintegrate_plan}   ${xmlfile}
    [Return]   ${Deintegrate_plan}  ${Deintegrate_Plan_name}

_Generate VDU Deintegrate xml File
    [Arguments]   ${MRBTS_ID}
    [Documentation]    _Generate VDU Deintegrate xml File
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <15-Oct-2020>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  MRBTS_ID  |  Yes  |  MRBTS_ID like MRBTS_5230   |
    ...    *RETURN VALUE*
    ...    |  ${xmlfile} the file content of Deintegrate XML Plan  |
    ...    Example
    ...    |  ${xmlfile}  |  _Generate VDU Deintegrate xml File  |  ${MRBTS_ID}  |
    ${xml1}=    set variable    <?xml version="1.0" encoding="UTF-8"?><raml xmlns="raml21.xsd" version="2.1">
    ${xml2}=    set variable    <cmData type="plan" scope="all" name="${MRBTS_ID}-de-integration-plan">
    ${xml3}=    set variable    <managedObject class="com.nokia.nms.integration:NE3SINT" distName="${MRBTS_ID}/
    ${xml4}=    set variable    NE3SINT-PREDEFINED" operation="delete" version="1.0"/></cmData></raml>
    ${xmlfile}=    set variable    ${xml1}${xml2}${xml3}${xml4}
    [Return]  ${xmlfile}


_Generate FHGW integrate plan
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0
    [Documentation]    Generate integrate/deintegrate config for specified ne.
    ...  create by:        <8-Nove-2021>, jie.8.liu@nokia-sbell.com
    ${timestamp}    Get Timestamp
    ${fhgw_config}    Get FHGW Account Info   gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${fhgw_id}=    set variable   ${fhgw_config["fhgw_id"]}
    ${fhgw_root_password}=    set variable   ${fhgw_config["root_password_plain"]}
    ${fhgw_ssh_ip}=  Set Variable   ${fhgw_config["addr"]}
    ${Plan_name}   Set Variable    ${fhgw_id}-No_TLS-Integrate-${timestamp}
    ${plan_file}   _Generate FHGW Integrate to NOM xml File Without TLS
    ...   ${Plan_name}   ${fhgw_id}    ${fhgw_ssh_ip}   ${fhgw_id}  ${fhgw_root_password}
    ${integrate_plan}  Get A File  Integrate_Plan  ${Plan_name}.xml
    create file   ${integrate_plan}   ${plan_file}
    [Return]   ${integrate_plan}  ${Plan_name}


Generate FHGW Integrate to NOM xml File Without TLS
    [Arguments]   ${Plan_name}   ${mrbts_id}    ${oam_ip}  ${ne_id}  ${fhgw_password}=Fhgw@systeM!23   ${gnb_index}=0   ${vdu_index}=0
    ...    ${fhgw_index}=0
    [Documentation]    Generate integrate/deintegrate config for specified ne.
    ...   *Author*: jie.8.liu@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-8-1 | r3li | get fhgw password and username from testline. |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | Plan_name | Yes | plan name |
    ...   | mrbts_id | Yes | mrbts id |
    ...   | oam_ip | Yes | oam ip |
    ...   | ne_id | Yes | ne id |
    ...   | fhgw_password | No | fhgw password |
    ...   | gnb_index | No | gnb index |
    ...   | vdu_index | No | vdu index |
    ...   | fhgw_index | No | fhgw index |
    ...   *Return*
    ...   xml file
    ...   *Example*
    ...   | Generate FHGW Integrate to NOM xml File Without TLS | test_name | 12345 | 10.1.1.10 | 456 | Fhgw@systeM!23 |
    ${xml1}   set variable   <?xml version="1.0" encoding="UTF-8"?><raml xmlns="raml21.xsd" version="2.1">
    ${xml2}   set variable   <cmData type="plan" scope="all" name="${Plan_name}">
    ${xml3}   set variable   <managedObject class="com.nokia.nms.integration:NE3SINT" distName="FHGW-${mrbts_id}/NE3SINT-PREDEFINED"
    ${xml4}   set variable   ${SPACE}operation="create" version="1.0"><p name="host">${oam_ip}</p><p name="port">8080</p>

    ${result}    ${fhgw_count_info}     Run Keyword And Ignore Error    Get FHGW Account Info    gnb_index=${gnb_index}
    ...    vdu_index=${vdu_index}    fhgw_index=${fhgw_index}
    ${username}    Set Variable If     '${result}'=='FAIL'    root     ${fhgw_count_info}[admin_user_name]
    ${password}    Set Variable If     '${result}'=='FAIL'    Fhgw@systeM!23     ${fhgw_count_info}[admin_user_password_plain]

    ${xml5}   set variable   <p name="neType">FHGW</p><p name="neId">${ne_id}</p><p name="username">${username}</p><p name="password">${password}</p>
#    ${xml6}   set variable   <p name="password">${fhgw_password}</p>
    ${xml7}   set variable   <p name="sbiNetConnectedTo">sbi-default-ipv4</p><p name="timezone">Europe/Helsinki</p>
    ${xml8}   set variable   </managedObject></cmData></raml>
    ${xmlfile}   set variable   ${xml1}${xml2}${xml3}${xml4}${xml5}${xml7}${xml8}
    [Return]   ${xmlfile}



_Generate FHGW Deintegrate plan
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0
    [Documentation]    Generate integrate/deintegrate config for specified ne.
    ...  create by:        <8-Nove-2021>, jie.8.liu@nokia-sbell.com
    ${timestamp}    Get Timestamp
    ${fhgw_config}    Get FHGW Config   gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${fhgw_id}=    set variable   ${fhgw_config["FHGW"]["fhgwId"]}
    ${fhgw_root_password}=    set variable   ${fhgw_config["USERS"]["root_password_plain"]}
    ${fhgw_ssh_ip}=  Set Variable   ${fhgw_config["NETWORKING"]["EXTERNAL_NET"]["NET_DOMAINS"]["NET_MANAGEMENT"]["OAM"]["IPADDRESSV4"]["ipAddress"]}
    ${integrate_file_name}=  set variable      cu${gnb_index}_vdu${vdu_index}_fhgw${fhgw_index}.json
    ${deintegrate_file_name}=  set variable    cu${gnb_index}_vdu${vdu_index}_fhgw${fhgw_index}_deintegrate.json
    ${path_of_integrate_config_file}=   get a file    integrate_config   ${integrate_file_name}
    ${path_of_deintegrate_config_file}=   get a file    integrate_config   ${deintegrate_file_name}
    ${Plan_name}   Set Variable    ${fhgw_id}-No_TLS-deintegrate-${timestamp}
    ${plan_file}   _Generate FHGW De-integrate to NOM xml File Without TLS
    ...   ${Plan_name}   ${fhgw_id}    ${fhgw_ssh_ip}   ${fhgw_id}  ${fhgw_root_password}
    ${integrate_plan}  Get A File  Integrate_Plan  ${Plan_name}.xml
    create file   ${integrate_plan}   ${plan_file}
    [Return]   ${integrate_plan}  ${Plan_name}

_Generate FHGW De-integrate to NOM xml File Without TLS
    [Arguments]   ${Plan_name}   ${mrbts_id}    ${oam_ip}  ${ne_id}  ${fhgw_password}
    [Documentation]    Generate integrate/deintegrate config for specified ne.
    ...  create by:        <8-Nove-2021>, jie.8.liu@nokia-sbell.com
    ${xml1}   set variable   <?xml version="1.0" encoding="UTF-8"?><raml xmlns="raml21.xsd" version="2.1">
    ${xml2}   set variable   <cmData type="plan" scope="all" name="${Plan_name}">
    ${xml3}   set variable   <managedObject class="com.nokia.nms.integration:NE3SINT" distName="FHGW-${mrbts_id}/NE3SINT-PREDEFINED"
    ${xml4}   set variable   ${SPACE}operation="delete" version="1.0"/>
#    ${xml5}   set variable   </managedObject></cmData></raml>
    ${xml5}   set variable   </cmData></raml>
    ${xmlfile}   set variable   ${xml1}${xml2}${xml3}${xml4}${xml5}
    [Return]   ${xmlfile}



Generate NE Integrate Config File
    [Arguments]   ${ne_type}=cu  ${gnb_index}=0  ${vdu_index}=0    ${fhgw_index}=0   ${password}=A0zY~rP#8Mx@
    [Documentation]    Generate integrate/deintegrate config for specified ne.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Sep-2020>, <f2huang>, <Updated for automatic generate config file>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  No  |  Which type of ne will be integrated, can be cu/vdu/fhgw, cu in default   |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...    *RETURN VALUE*
    ...    ${path_of_integrate_config_file} and ${path_of_deintegrate_config_file}
    ...    Example
    ...    | Generate NE Integrate Config File |  cu    |  1 |
    ...    | Generate NE Integrate Config File |  vdu   |  0 |   1  |
    ...    | Generate NE Integrate Config File |  fhgw   |  0 |   0  |   0  |

    ${path_of_integrate_config_file}   ${path_of_deintegrate_config_file}=  run keyword if   "${ne_type}"=="cu"
    ...    _Generate CU Integrate Config File   ${gnb_index}
    ...   ELSE IF  "${ne_type}"=="vdu"     _Generate VDU Integrate Config File   ${gnb_index}  ${vdu_index}  ${password}
    ...   ELSE    _Generate FHGW Integrate Config File    ${gnb_index}   ${vdu_index}    ${fhgw_index}
    [Return]    ${path_of_integrate_config_file}   ${path_of_deintegrate_config_file}

_Generate CU Integrate Config File
    [Arguments]   ${gnb_index}=0
    ${integrate_file_name}=  set variable    cu${gnb_index}.json
    ${deintegrate_file_name}=  set variable    cu${gnb_index}_deintegrate.json
    ${path_of_integrate_config_file}=   get a file    integrate_config   ${integrate_file_name}
    ${path_of_deintegrate_config_file}=   get a file    integrate_config   ${deintegrate_file_name}
    ${NOM_config_source}  Get NOM Config Type From TestLine
    Run Keyword If   "${NOM_config_source}"=="nom_config_source_from_global_variable_py"
    ...  Get Target NOM server
    ${neo_endpoints_ip}   Set Variable If   "${NOM_config_source}"=="nom_config_source_from_global_variable_py"
    ...  ${TARGET_NOM_INFO["main_info"].neo_endpoints_ip}  ${tl.nms.nom.neo_endpoints_ip}
    generate_integrate_config_file    file_path=${path_of_integrate_config_file}
    ...        ne_type=cu
    ...        ne_id=${tl.gnbs[${gnb_index}].cu.instance_id}
    ...        host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...        port=8060
    ...        neo_endpoints_ip=${neo_endpoints_ip}
   Generate Deintegrate Config File    ${path_of_integrate_config_file}   ${path_of_deintegrate_config_file}
   [Return]   ${path_of_integrate_config_file}   ${path_of_deintegrate_config_file}

_Generate VDU Integrate Config File
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${password}=A0zY~rP#8Mx@
    ${integrate_file_name}=  set variable    cu${gnb_index}_vdu${vdu_index}.json
    ${deintegrate_file_name}=  set variable    cu${gnb_index}_vdu${vdu_index}_deintegrate.json
    ${path_of_integrate_config_file}=   get a file    integrate_config   ${integrate_file_name}
    ${path_of_deintegrate_config_file}=   get a file    integrate_config   ${deintegrate_file_name}
    ${NOM_config_source}  Get NOM Config Type From TestLine
    Run Keyword If   "${NOM_config_source}"=="nom_config_source_from_global_variable_py"
    ...  Get Target NOM server
    ${neo_endpoints_ip}   Set Variable If   "${NOM_config_source}"=="nom_config_source_from_global_variable_py"
    ...  ${TARGET_NOM_INFO["main_info"].neo_endpoints_ip}  ${tl.nms.nom.neo_endpoints_ip}
    generate_integrate_config_file    file_path=${path_of_integrate_config_file}
    ...        ne_type=vdu
    ...        ne_id=${tl.gnbs[${gnb_index}].dus[${vdu_index}].instance_id}
    ...        host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...        port=8080
    ...        neo_endpoints_ip=${neo_endpoints_ip}
    ...        username=wsuser
    ...        password=${password}
   Generate Deintegrate Config File    ${path_of_integrate_config_file}   ${path_of_deintegrate_config_file}
   [Return]   ${path_of_integrate_config_file}   ${path_of_deintegrate_config_file}

_Generate FHGW Integrate Config File
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0   ${fhgw_index}=0
    [Documentation]    Generate integrate/deintegrate config for specified ne.
    ...  modified by:        <29-Sep-2021>, zhong.1.chen@nokia-sbell.com
    ${fhgw_config}    Get FHGW Config   gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${fhgw_id}=    set variable   ${fhgw_config["FHGW"]["fhgwId"]}
    ${fhgw_root_password}=    set variable   ${fhgw_config["USERS"]["root_password_plain"]}
    ${fhgw_ssh_ip}=  Set Variable   ${fhgw_config["NETWORKING"]["EXTERNAL_NET"]["NET_DOMAINS"]["NET_MANAGEMENT"]["OAM"]["IPADDRESSV4"]["ipAddress"]}
    ${integrate_file_name}=  set variable      cu${gnb_index}_vdu${vdu_index}_fhgw${fhgw_index}.json
    ${deintegrate_file_name}=  set variable    cu${gnb_index}_vdu${vdu_index}_fhgw${fhgw_index}_deintegrate.json
    ${path_of_integrate_config_file}=   get a file    integrate_config   ${integrate_file_name}
    ${path_of_deintegrate_config_file}=   get a file    integrate_config   ${deintegrate_file_name}
    ${NOM_config_source}  Get NOM Config Type From TestLine
    Run Keyword If   "${NOM_config_source}"=="nom_config_source_from_global_variable_py"
    ...  Get Target NOM server
    ${neo_endpoints_ip}   Set Variable If   "${NOM_config_source}"=="nom_config_source_from_global_variable_py"
    ...  ${TARGET_NOM_INFO["main_info"].neo_endpoints_ip}  ${tl.nms.nom.neo_endpoints_ip}
    generate_integrate_config_file    file_path=${path_of_integrate_config_file}
    ...        ne_type=fhgw
    ...        ne_id=${fhgw_id}
    ...        host=${fhgw_ssh_ip}
    ...        port=8080
    ...        neo_endpoints_ip=${neo_endpoints_ip}
    ...        username=root
    ...        password=${fhgw_root_password}
   Generate Deintegrate Config File    ${path_of_integrate_config_file}   ${path_of_deintegrate_config_file}
   [Return]   ${path_of_integrate_config_file}   ${path_of_deintegrate_config_file}

Generate Deintegrate Config File
   [Arguments]   ${path_of_integrate_config_file}    ${path_of_deintegrate_config_file}
   [Documentation]    Generate deintegrate config according to integrate config file.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <16-Sep-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  path_of_integrate_config_file  |  Yes  |  Path of ne integrate config file  |
    ...    |  path_of_deintegrate_config_file  |  Yes  |  Where to save deintegrate config file  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Generate Deintegrate Config File |  /tmp/cu0.json   |   /tmp/cu0_deintegrate.json  |
   ${config_file_content}=   get file    ${path_of_integrate_config_file}
   ${config_file_content}=    json.loads     ${config_file_content}
   ${ne_id}=      set variable    ${config_file_content["neId"]}
   ${type}=      set variable    ${config_file_content["neType"]}
   ${integrated_id}=  set variable    ${config_file_content["integratedId"]}
   ${deintegate_config_file_content}=    set variable
   ...   {"neIntegrationData": {"integratedId": "${integrated_id}","neType": "${type}" } }
   ${deintegrate_file}=   create file   ${path_of_deintegrate_config_file}  ${deintegate_config_file_content}


Get Configuraion From Integration File
   [Arguments]   ${ne_type}=vdu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0
   [Documentation]    Get Config INFO From NOM Intergrate Json File.
    ...  You need to prepare a folder named integrate_config_file in the same path as the init.py
    ...  it contains integrate file like cu_1.json/vdu_1.json/fhgw_1.json
    ...  it supports multi cu/vdu/fhgw, like cu_2.json/vdu_2.json/fhgw_2.json
    ...  author:             ling.2.zhao@nokia-sbell.com
    ...  modified by:        <3-8-2020>, <lingzhao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  No  |  Which type of ne will be integrated, can be cu/vdu/fhgw, cu in default   |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...
    ...    *RETURN VALUE*
    ...    Config INFO in Intergrate File
    ...    Example
    ...    | Get Config INFO From NOM Integration File |  vdu   | 0   | 1   |

   ${path_of_integrate_config_file}  ${path_of_deintegrate_config_file}=    Generate NE Integrate Config File
    ...    ${ne_type}  ${gnb_index}  ${vdu_index}   ${fhgw_index}
   file should exist        ${path_of_integrate_config_file}
   ${config_file_content}=   get file    ${path_of_integrate_config_file}
   ${config_file_content}=    json.loads     ${config_file_content}
   [Return]    ${config_file_content}

Prepare VCU NOM Integrate Plan File With TLS
    [Arguments]   ${gnb_index}=0
    [Documentation]    Prepare VCU NOM Integrate Plan File With TLS
    ...    *Author*  rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | 2022-5-12 | r3li | new |
    ...    | Input Parameters | Man. | Description |
    ...    *Arguments Description*
    ...    | gnb_index | No | cu index, should be 0, 1... |
    ...    *RETURN VALUE*
    ...    |  ${integrate_plan} the file path of Integrate XML Plan File for vDU TLS  |
    ...    |  ${Plan_name} the name of Integrate XML Plan File for vDU TLS  |
    ...    *Example*
    ...    |  ${integrate_plan} |  ${Plan_name}  |  Prepare VDU NOM Integrate Plan File With TLS  |
    ...
    ${timestamp}    Get Timestamp
    ${ne_id}     Get MRBTS Id From vCU SCF    gnb_index=${gnb_index}
    ${mrbts_id}    Set Variable    MRBTS-${ne_id}
    ${vcu_oam_http_connection_info}   Get vCU OAM Http Connection Info  gnb_index=${gnb_index}
    ${vcu_oam_ip}   set variable  ${vcu_oam_http_connection_info["addr"]}
    ${ca_file_name}    Get Vdu Integrate To Nom Certificate File
    ${ca_file}     get file   ${ca_file_name}
    ${Plan_name}   Set Variable    ${mrbts_id}-TLS-Integrate-${timestamp}
    ${plan_file}    _Generate NOM Integrate xml File With TLS    ${Plan_name}   ${mrbts_id}    ${vcu_oam_ip}   ${ne_id}   ${ca_file}
    ${integrate_plan}  Get A File  Integrate_Plan  ${Plan_name}.xml
    create file   ${integrate_plan}   ${plan_file}
    [Return]   ${integrate_plan}  ${Plan_name}


Prepare VCU NOM Integrate Plan File Without TLS
    [Arguments]   ${gnb_index}=0
    [Documentation]    Prepare VCU NOM Integrate Plan File Without TLS
    ...    *Author*: chris.l.cao@nokia-sbell.com
    ...    *History Change*
    ...    | date | who | what and how |
    ...    | 18.10.2021 | r3li | new |
    ...    *Arguments Description*
    ...    | gnb_index | No | cu index, should be 0, 1... |
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...     NOM integration plan file for no TLS:
    ...     ${integrate_plan} the file path of Integrate XML Plan File for vDU TLS
    ...     ${Plan_name} the name of Integrate XML Plan File for vDU TLS
    ...    *Example*
    ...    |  ${integrate_plan} |  ${Plan_name}  |  Prepare VCU NOM Integrate Plan File Without TLS |
    ...
    ${timestamp}    Get Timestamp
    ${ne_id}     Get MRBTS Id From vCU SCF    gnb_index=${gnb_index}
    ${mrbts_id}    Set Variable    MRBTS-${ne_id}
    ${vcu_oam_http_connection_info}   Get vCU OAM Http Connection Info  gnb_index=${gnb_index}
    ${vcu_oam_ip}   set variable  ${vcu_oam_http_connection_info["addr"]}
    ${Plan_name}   Set Variable    ${mrbts_id}-No_TLS-Integrate-${timestamp}
    ${plan_file}   _Generate NOM Integrate xml File Without TLS    ${Plan_name}   ${mrbts_id}    ${vcu_oam_ip}   ${ne_id}
    ${integrate_plan}  Get A File  Integrate_Plan  ${Plan_name}.xml
    create file   ${integrate_plan}   ${plan_file}
    [Return]   ${integrate_plan}  ${Plan_name}


Prepare VCU Deintegrate Plan File
    [Arguments]     ${gnb_index}=0
    [Documentation]    Prepare VCU Deintegrate Plan File
    ...    *Author*: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | what or how |
    ...    | 2022-5-12 | r3li | initial created |
    ...    *Arguments Description* |
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | cu index, default is 0 |
    ...    *RETURN VALUE*
    ...    |  ${Deintegrate_plan} the file path of Deintegrate XML Plan File for vDU  |
    ...    |  ${Deintegrate_Plan_name} the name of Deintegrate XML Plan File for vDU  |
    ...    *Example*
    ...    |  ${Deintegrate_plan} |  ${Deintegrate_Plan_name}  |   Prepare VCU Deintegrate Plan File  |
    ${timestamp}    Get Timestamp
    log to console    ${timestamp}
    ${ne_id}     Get MRBTS Id From vCU SCF    gnb_index=${gnb_index}
    ${MRBTS_ID}    Set Variable    MRBTS-${ne_id}
    ${Deintegrate_Plan_name}   Set Variable    ${MRBTS_ID}-Deintegrate-${timestamp}
    ${xmlfile}  _Generate VDU Deintegrate xml File  ${MRBTS_ID}
    ${Deintegrate_plan}  Get A File  Deintegrate_Plan  ${Deintegrate_Plan_name}.xml
    create file   ${Deintegrate_plan}   ${xmlfile}
    [Return]   ${Deintegrate_plan}  ${Deintegrate_Plan_name}
