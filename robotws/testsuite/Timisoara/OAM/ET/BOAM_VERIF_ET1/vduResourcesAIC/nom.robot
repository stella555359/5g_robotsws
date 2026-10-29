*** Settings ***
Documentation
...   author: Huang Fen
...   contact: fen.huang@nokia-sbell.com

#Resource          aic_common_resources.robot

Resource          variables.robot
Library           taf.nms.nom                           WITH NAME    nom_rest



#*** Variables ***


*** Keyword ***
SSH To NOM
    [Documentation]    Ssh to work nom edge node.
    ...                private rsa key should be prepare in test line config folder with file name id_rsa.
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <17-May-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    connection alias
    ...    Example
    ...    | SSH To NOM |    |

    log to console    Start ssh to nom
    ${result}  run keyword and return status  SSH To the Primary NOM
    ${alias} =   run keyword if  "${result}"=="True"   SSH To the Primary NOM
    ...  ELSE       SSH to Secondary NOM
    [Return]   ${alias}

SSH To the Primary NOM
    [Documentation]    Ssh to nom edge node.
    ...                private rsa key should be prepare in test line config folder with file name id_rsa.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <20-Oct-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    connection alias
    ...    Example
    ...    | SSH To NOM |    |
    log to console    ssh to nom
    ${alias}=  get unique id
    ${key_file}=   set variable  ${CURDIR}/nom/id_rsa
    File should exist    ${key_file}
    issh.Connect to    ip=${tl.nms.nom.ssh_connections_info[0].addr}
    ...                port=22
    ...                username=${tl.nms.nom.ssh_connections_info[0].username}
    ...                password=""
    ...                prompt=\\[cloud-user@\\S+.*\\]\\$|\\[root@\\S+.*\\]#
    ...                timeout=60
    ...                alias=${alias}
    ...                keyfile=${key_file}
    ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
    ${output}=  Convert to lowercase  ${output}
    should contain   ${output}   cnms   ssh to nom failed!
    [Return]   ${alias}

SSH To Secondary NOM
     [Documentation]    Ssh to backup NOM.
    ...                private rsa key should be prepare in test line config folder with file name id_rsa.
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <17-May-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    connection alias
    ...    Example
    ...    | SSH To NOM |    |
    log to console   Start ssh to backup NOM
    ${alias}=  get unique id
    ${key_file}=   set variable  ${CURDIR}/nom/id_rsa_nom10
    File should exist    ${key_file}
    issh.Connect to    ip=${NOM_10_SSH_IP}
    ...                port=22
    ...                username=${NOM_10_SSH_USERNAME}
    ...                password=""
    ...                prompt=\\[cloud-user@\\S+.*\\]\\$|\\[root@\\S+.*\\]#
    ...                timeout=60
    ...                alias=${alias}
    ...                keyfile=${key_file}
    ${output}=  issh.execute  hostname  check_result=${False}  alias=${alias}
    ${output}=  Convert to lowercase  ${output}
    should contain   ${output}   cnms   ssh to nom10 success!
    [Return]   ${alias}


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
    generate_integrate_config_file    file_path=${path_of_integrate_config_file}
    ...        ne_type=cu
    ...        ne_id=${tl.gnbs[${gnb_index}].cu.instance_id}
    ...        host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...        port=8060
    ...        neo_endpoints_ip=${tl.nms.nom.neo_endpoints_ip}
   Generate Deintegrate Config File    ${path_of_integrate_config_file}   ${path_of_deintegrate_config_file}
   [Return]   ${path_of_integrate_config_file}   ${path_of_deintegrate_config_file}

_Generate VDU Integrate Config File
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${password}=A0zY~rP#8Mx@
    ${integrate_file_name}=  set variable    cu${gnb_index}_vdu${vdu_index}.json
    ${deintegrate_file_name}=  set variable    cu${gnb_index}_vdu${vdu_index}_deintegrate.json
    ${path_of_integrate_config_file}=   get a file    integrate_config   ${integrate_file_name}
    ${path_of_deintegrate_config_file}=   get a file    integrate_config   ${deintegrate_file_name}
    generate_integrate_config_file    file_path=${path_of_integrate_config_file}
    ...        ne_type=vdu
    ...        ne_id=${tl.gnbs[${gnb_index}].dus[${vdu_index}].instance_id}
    ...        host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...        port=8080
    ...        neo_endpoints_ip=${tl.nms.nom.neo_endpoints_ip}
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
    generate_integrate_config_file    file_path=${path_of_integrate_config_file}
    ...        ne_type=fhgw
    ...        ne_id=${fhgw_id}
    ...        host=${fhgw_ssh_ip}
    ...        port=8080
    ...        neo_endpoints_ip=${tl.nms.nom.neo_endpoints_ip}
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

Upload Integration Config File To NOM
   [Arguments]   ${ne_type}=cu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0  ${password}=A0zY~rP#8Mx@
   [Documentation]    Generate integrate/deintegrate config file and upload config files to nom.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <3-Jun-2020>, <f2huang>, <initial created>
    ...  modified by:        <16-Sep-2020>, <f2huang>, <Updated for automatic generate config file>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  No  |  Which type of ne will be integrated, can be cu/vdu/fhgw, cu in default   |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...
    ...    *RETURN VALUE*
    ...    ${remote_path_of_config_dir}
    ...    ${remote_integrate_config_file_name}
    ...    ${remote_deintegrate_config_file_name}
    ...    Example
    ...    | Upload Integration Config File To NOM |  cu   |  1  |
   ${path_of_integrate_config_file}  ${path_of_deintegrate_config_file}=    Generate NE Integrate Config File
    ...    ${ne_type}  ${gnb_index}  ${vdu_index}   ${fhgw_index}  ${password}
   ${integrate_logs_path}=  Get A Directory  integrate_logs
   ${config_file_content}=   get file    ${path_of_integrate_config_file}
   ${config_file_content}=    json.loads     ${config_file_content}
   ${ne_id}=      set variable    ${config_file_content["neId"]}
   ${remote_path_of_config_dir}=    set variable   /home/cloud-user/ta_integrate
   ${remote_integrate_config_file_name}=   set variable   ${ne_type}${ne_id}_integrate_config.json
   ${remote_deintegrate_config_file_name}=   set variable   ${ne_type}${ne_id}_deintegrate_config.json
   ${connection}=   SSH To NOM
   issh.execute   mkdir -p ${remote_path_of_config_dir}   check_result=${False}   alias=${connection}
   ${config_file_path}  ${config_file_name}=  split path  ${path_of_integrate_config_file}
   issh.execute   rm -rf ${remote_path_of_config_dir}/${remote_integrate_config_file_name}  check_result=${False}   alias=${connection}
   issh.upload file   local_path=${path_of_integrate_config_file}
   ...                remote_path=${remote_path_of_config_dir}/${remote_integrate_config_file_name}
   ...                alias=${connection}
   issh.upload file   local_path=${path_of_deintegrate_config_file}
   ...                remote_path=${remote_path_of_config_dir}/${remote_deintegrate_config_file_name}
   ...                alias=${connection}
   ${output}=  issh.execute   ls ${remote_path_of_config_dir} --color=never  check_result=${False}  alias=${connection}
   should contain    ${output}   ${remote_integrate_config_file_name}   Upload integrate config file to nom failed!
   should contain    ${output}   ${remote_deintegrate_config_file_name}   Upload deintegrate config file to nom failed!
   [Return]    ${remote_path_of_config_dir}    ${remote_integrate_config_file_name}    ${remote_deintegrate_config_file_name}
   [Teardown]  Disconnect Interactive Connection   ${connection}

Integrate NE To NOM
   [Arguments]   ${ne_type}=cu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0    ${password}=A0zY~rP#8Mx@
   ...    ${nom_integrate_link}=http://nei-bot-svc.neo.svc.cluster.local/api/  ${security_mode}=No TLS   ${integration_type}=cli
   [Tags]  NOM_CM
   [Documentation]    Integrate ne to nom by ne type, ne index and which nom will be integrated to.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <4-Jun-2020>, <f2huang>, <initial created>
    ...  modified by:        <16-Sep-2020>, <f2huang>, <Update it to generate config file automaticly>
    ...  modified by:        <14-Oct-2020>, <huilxu>, <add security_mode and integration_type>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  No  |  Which type of ne will be integrated, can be cu/vdu/fhgw, cu in default   |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...    | security_mode | No | 'TLS' or 'No TLS'. TLS: Transport Layer Security supported  |
    ...    | integration_type | No | the type of using Nom, can be cli/rest/selenium, cli in default  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Integrate NE To NOM  |  cu   |  1  |
    ...    |  Integrate NE To NOM  |  vdu   |  0  |  0 |
    ...    |  Integrate NE To NOM  |  ne_type=vdu  |  security_mode=TLS  |  integration_type=rest  |
   Run Keyword If   "${integration_type}"=="cli"  _Integrate NE To NOM Via Cli
   ...  ne_type=${ne_type}   gnb_index=${gnb_index}   vdu_index=${vdu_index}    fhgw_index=${fhgw_index}    password=${password}
   ...  nom_integrate_link=${nom_integrate_link}
   ...  ELSE IF    "${integration_type}"=="rest"  _Integrate NE To NOM Via Rest
   ...  ne_type=${ne_type}   gnb_index=${gnb_index}   vdu_index=${vdu_index}    fhgw_index=${fhgw_index}
   ...  security_mode=${security_mode}
   ...  ELSE IF    "${integration_type}"=="selenium"  _Integrate NE To NOM Via selenium
   ...  ne_type=${ne_type}   gnb_index=${gnb_index}   vdu_index=${vdu_index}    fhgw_index=${fhgw_index}

_Integrate NE To NOM Via Cli
   [Arguments]   ${ne_type}=cu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0    ${password}=A0zY~rP#8Mx@
   ...    ${nom_integrate_link}=http://nei-bot-svc.neo.svc.cluster.local/api/
   [Documentation]    Integrate ne to nom by ne type, ne index and which nom will be integrated to.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <4-Jun-2020>, <f2huang>, <initial created>
    ...  modified by:        <16-Sep-2020>, <f2huang>, <Update it to generate config file automaticly>
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
   ${path_of_config_file}   ${integrate_config_file_name}   ${deintegrate_config_file_name}=
   ...    Upload Integration Config File To NOM    ${ne_type}   ${gnb_index}  ${vdu_index}   ${fhgw_index}  ${password}
   ${file_name_obj}=     Split String    ${integrate_config_file_name}   .
   ${file_prefix}=  set variable  ${file_name_obj[0]}
   ${opt_1}=  set variable  auto-integrate?dryRun
   ${opt_2}=  set variable  auto-integrate?verbose
   ${opt_3}=  set variable  -H 'Content-type: application/json'
   ${nom_link}=   set variable   ${nom_integrate_link}
   ${cmd_1}=  set variable
   ...    curl -s '${nom_link}${opt_1}' ${opt_3} -d @${integrate_config_file_name} |jq '.' > ${file_prefix}__output_ne_data.json
   ${cmd_2}=  set variable
   ...    curl -s '${nom_link}${opt_2}' ${opt_3} -d @${integrate_config_file_name} |jq '.' > ${file_prefix}__output_integrate_result.json
   ${integrate_logs}=  Get A Directory  integrate_logs
   ${connection}=  SSH To NOM
   issh.execute   rm -rf ${integrate_logs}/${file_prefix}__output_ne_data.json  check_result=${False}   alias=${connection}
   issh.execute   rm -rf ${integrate_logs}/${file_prefix}__output_integrate_result.json  check_result=${False}   alias=${connection}
   issh.execute    cd ${path_of_config_file}   check_result=${False}   alias=${connection}
   FOR    ${inte_num}    IN RANGE    1      4
     log to console   \n*** Start execute ${ne_type} integrate command : ${inte_num} execute***
     log to console   ${cmd_1}
     issh.execute     ${cmd_1}   check_result=${False}   alias=${connection}
     log to console   ${cmd_2}
     issh.set_timeout   300     alias=${connection}
     issh.execute     ${cmd_2}   check_result=${False}   alias=${connection}
     log to console    \n*** Download ${ne_type} integrate log to local***
     issh.download_file    ${path_of_config_file}/${file_prefix}__output_ne_data.json    ${integrate_logs}/   alias=${connection}
     issh.download_file    ${path_of_config_file}/${file_prefix}__output_integrate_result.json     ${integrate_logs}/   alias=${connection}
     log to console   \n*** Check ${ne_type} integrate log***
     ${res_inte}   Check NE Integrate Result   ${integrate_logs}/${file_prefix}__output_integrate_result.json
     sleep  1s
     Exit For Loop IF   ${res_inte}==1
     Run Keyword And Ignore Error  Deintegrate NE From NOM  ${ne_type}
     run keyword if  ${inte_num}==3  should be true  ${re_inte}=1
   END
   [Teardown]  Disconnect Interactive Connection  alias=${connection}


_Integrate NE To NOM Via Rest
   [Arguments]   ${ne_type}=vdu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0    ${security_mode}=No TLS
   [Documentation]    _Integrate NE To NOM Via Rest
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <14-Oct-2020>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  No  |  Which type of ne will be integrated, can be cu/vdu/fhgw, vdu in default   |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...    | security_mode | No | 'TLS' or 'No TLS'. TLS: Transport Layer Security supported  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Integrate NE To NOM Via Rest  |  ne_type=vdu  |  security_mode=TLS  |
    Run Keyword If  "${ne_type}"=="cu"  _Integrate NE To NOM Via Rest For VCU
    ...  gnb_index=${gnb_index}   security_mode=${security_mode}
    ...  ELSE IF  "${ne_type}"=="vdu"  _Integrate NE To NOM Via Rest For VDU
    ...    gnb_index=${gnb_index}   vdu_index=${vdu_index}    security_mode=${security_mode}
    ...  ELSE IF  "${ne_type}"=="fhgw"  _Integrate NE To NOM Via Rest For FHGW
    ...    fhgw_index=${fhgw_index}


_Integrate NE To NOM Via Rest For VCU
   #[Arguments]   ${gnb_index}=0   ${security_mode}=No TLS
   [Documentation]    _Integrate NE To NOM Via Rest For VCU
    ...  author:             chris.l.cao@nokia-sbell.com
    ...  modified by:        <14-Oct-2020>, <chricao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    | security_mode | No | 'TLS' or 'No TLS'. TLS: Transport Layer Security supported  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Integrate NE To NOM Via Rest For VCU  |  gnb_index=0  |  security_mode=TLS  |
    Fail  it's not supported for VCU integration REST


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
   ${client_id}   Wait Until Keyword Succeeds  60  10   Nom Rest Login
   ${integrate_plan}  ${Plan_name}  Run Keyword If  "${security_mode}"=="No TLS"
         ...  Prepare VDU NOM Integrate Plan File Without TLS  gnb_index=${gnb_index}  vdu_index=${vdu_index}
   ...  ELSE IF  "${security_mode}"=="TLS"
         ...  Prepare VDU NOM Integrate Plan File With TLS  gnb_index=${gnb_index}  vdu_index=${vdu_index}
   nom_rest.import_plan  path_to_plan=${integrate_plan}  name=${Plan_name}   plan_type=INTEGRATION
   sleep  2s
   nom_rest.integrate_ne  plan_name=${Plan_name}  timeout=300  reintegrate=False
   [Teardown]  run keyword and ignore error  NOM Rest Logout  ${client_id}


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


Get MRBTS_ID And NE_ID Via VDU SCF
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]    Get MRBTS_ID And NE_ID Via VDU SCF
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <15-Oct-2020>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   mrbts_id, the MRBTS ID like MRBTS_5230
    ...   ne_id, the NE ID like 5230
    ...
    ...    Example
    ...    |  ${mrbts_id}  |  ${ne_id}  |  Get MRBTS_ID And NE_ID Via VDU SCF  |
    ...
    vDU Rest Login  vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}  vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
   # scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${vdu_conf}  Get VDU Conf From SCF   scf_path=${scf_file_with_fullpath}
    ${mrbts_id}  Set Variable   MRBTS-${vdu_conf["mrbts_id"]}
    ${ne_id}   Set Variable   ${vdu_conf["mrbts_id"]}

    [Return]   ${mrbts_id}  ${ne_id}
    #[Teardown]  run keyword and ignore error  vDU Rest Logout  vdu_index=${vdu_index}


_Integrate NE To NOM Via Rest For FHGW
   [Arguments]  ${gnb_index}=0   ${vdu_index}=0   #${fhgw_index}=0
   [Documentation]     _Integrate NE To NOM Via Rest For FHGW.
    ...  author:            jie.8.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Integrate NE To NOM Via Rest For FHGW  |  0 |
    ${client_id}   Wait Until Keyword Succeeds  60  10   Nom Rest Login
    ${integrate_plan}  ${Plan_name}    _Generate FHGW integrate plan  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    nom_rest.import_plan  path_to_plan=${integrate_plan}  name=${Plan_name}   plan_type=INTEGRATION
    sleep  2s
    nom_rest.integrate_ne  plan_name=${Plan_name}  timeout=300  reintegrate=False
    [Teardown]  run keyword and ignore error  NOM Rest Logout  ${client_id}





_Integrate NE To NOM Via Selenium
   #[Arguments]   ${ne_type}=cu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0
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




Check NE Integrate Result
    [Arguments]       ${log_file}
    [Documentation]    Check ne integrate result from log.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <4-Jun-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  integrate_result_file  |  Yes  |  Output log of ne integration  |
    ...
    ...    *RETURN VALUE*
    ...    NA
    ...    Example
    ...    |  Check NE Integrate Result  |   /home/ute/cu3219_integrate_config__output_integrate_result.json   |
    ${integrate_result}=   get file     ${log_file}
    ${response}=    json.loads     ${integrate_result}
    ${respon_changed}  set variable  ${response["fullAnsibleLog"]["stats"]["localhost"]["changed"]}
    ${respon_failures}  set variable  ${response["fullAnsibleLog"]["stats"]["localhost"]["failures"]}
    ${res_inte}  run keyword if  '${respon_changed}' == '1' and '${respon_failures}' == '0'   set variable  1
    ...    ELSE   set variable  0
    [Return]  ${res_inte}

Deintegrate NE From NOM
   [Arguments]   ${ne_type}=cu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0
   ...    ${nom_integrate_link}=http://nei-bot-svc.neo.svc.cluster.local/api/    ${deintegration_type}=cli
   [Documentation]    Deintegrate ne from nom by ne type, ne index and which nom will be deintegrated from.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <20-Oct-2020>, <f2huang>, <initial created>
    ...  modified by:        <15-Oct-2021>, <huilxu>, <add deintegration_type>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  Yes  |  Which type of ne will be deintegrated, can be cu/vdu/fhgw   |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...    | deintegration_type | No | the type of using Nom, can be cli/rest/selenium, cli in default  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Deintegrate NE From NOM |  cu    |  1 |
    ...    | Deintegrate NE From NOM |  vdu   |  0 |   1  |
    ...    | Deintegrate NE From NOM |  fhgw   |  0 |   0  |   0  |
    ...    | Deintegrate NE From NOM |  ne_type=vdu |  deintegration_type=rest  |
    Run Keyword If   "${deintegration_type}"=="cli"  _Deintegrate NE To NOM Via Cli
   ...  ne_type=${ne_type}   gnb_index=${gnb_index}   vdu_index=${vdu_index}    fhgw_index=${fhgw_index}
   ...  nom_integrate_link=${nom_integrate_link}
   ...  ELSE IF    "${deintegration_type}"=="rest"  _Deintegrate NE To NOM Via Rest
   ...  ne_type=${ne_type}   gnb_index=${gnb_index}   vdu_index=${vdu_index}    fhgw_index=${fhgw_index}
   ...  ELSE IF    "${deintegration_type}"=="selenium"  _Deintegrate NE To NOM Via selenium
   ...  ne_type=${ne_type}   gnb_index=${gnb_index}   vdu_index=${vdu_index}    fhgw_index=${fhgw_index}



_Deintegrate NE To NOM Via Cli
   [Arguments]   ${ne_type}=cu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0
   ...    ${nom_integrate_link}=http://nei-bot-svc.neo.svc.cluster.local/api/
   [Documentation]    Deintegrate ne from nom by ne type, ne index and which nom will be deintegrated from.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <20-Oct-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  Yes  |  Which type of ne will be deintegrated, can be cu/vdu/fhgw   |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Deintegrate NE From NOM |  cu    |  1 |
    ...    | Deintegrate NE From NOM |  vdu   |  0 |   1  |
    ...    | Deintegrate NE From NOM |  fhgw   |  0 |   0  |   0  |
   ${path_of_config_file}   ${integrate_config_file_name}   ${deintegrate_config_file_name}=
   ...     Upload Integration Config File To NOM    ${ne_type}   ${gnb_index}  ${vdu_index}   ${fhgw_index}
   ${file_name_obj}=     Split String    ${deintegrate_config_file_name}   .
   ${file_prefix}=  set variable  ${file_name_obj[0]}
   ${opt_1}=  set variable    auto-deintegrate?verbose
   ${opt_2}=  set variable    -H 'Content-type: application/json'
   ${integrate_logs}=  Get A Directory  integrate_logs
   ${connection}=  SSH To NOM
   issh.execute    cd ${path_of_config_file}   check_result=${False}   alias=${connection}
   ${nom_link}=   set variable    ${nom_integrate_link}
   ${cmd}=  set variable
   ...   curl -s '${nom_link}${opt_1}' ${opt_2} -d @${deintegrate_config_file_name} |jq '.' > ${file_prefix}__output_deintegrate_result.json
   issh.execute   rm -rf ${integrate_logs}/${file_prefix}__output_deintegrate_result.json  check_result=${False}   alias=${connection}
   log to console   \n*** Start execute ${ne_type} deintegrate command ***
   log to console   ${cmd}
   issh.set_timeout   120    alias=${connection}
   issh.execute     ${cmd}   check_result=${False}   alias=${connection}
   log to console    \n*** Download ${ne_type} deintegrate log to local***
   issh.download_file  ${path_of_config_file}/${file_prefix}__output_deintegrate_result.json  ${integrate_logs}/  alias=${connection}
   log to console   \n*** Check ${ne_type} deintegrate log***
   Check NE Deintegrate Result   ${integrate_logs}/${file_prefix}__output_deintegrate_result.json
   [Teardown]   Disconnect Interactive Connection  alias=${connection}


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

_Deintegrate NE To NOM Via selenium
   #[Arguments]   ${ne_type}=vdu   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0
    [Documentation]    _Deintegrate NE To NOM Via selenium
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <16-Oct-2020>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  No  |  Which type of ne will be integrated, can be cu/vdu/fhgw, vdu in default   |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Deintegrate NE To NOM Via selenium |  gnb_index=0 |
    Fail   It's not supported yet!

_Deintegrate NE To NOM Via Rest For vCU
    #[Arguments]   ${gnb_index}=0
    [Documentation]    _Deintegrate NE To NOM Via Rest For vCU
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <14-Oct-2020>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Deintegrate NE To NOM Via Rest For vCU |  gnb_index=0 |
    Fail   It's not supported yet!

_Deintegrate NE To NOM Via Rest For FHGW
    [Arguments]    ${gnb_index}=0      ${fhgw_index}=0      #${vdu_index}=0
    [Documentation]    _Deintegrate NE To NOM Via Rest For FHGW
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <14-Oct-2020>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Deintegrate NE To NOM Via Rest For FHGW |  fhgw_index=0 |

    ${client_id}   Wait Until Keyword Succeeds  60  10   Nom Rest Login

    ${Deintegrate_plan}  ${Deintegrate_Plan_name}  _Generate FHGW Deintegrate plan  gnb_index=${gnb_index}   fhgw_index=${fhgw_index}

    nom_rest.import_plan  path_to_plan=${Deintegrate_plan}  name=${Deintegrate_Plan_name}   plan_type=DEINTEGRATION
    sleep  5s
    nom_rest.deintegrate_ne  plan_name=${Deintegrate_Plan_name}  timeout=120
    sleep  5s
    NOM Rest Logout   ${client_id}


_Deintegrate NE To NOM Via Rest For vDU
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]    _Deintegrate NE To NOM Via Rest For vDU
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <14-Oct-2020>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Deintegrate NE To NOM Via Rest For vDU  |
    ...    |  _Deintegrate NE To NOM Via Rest For vDU  |  gnb_index=0  |  vdu_index=0  |
    ...
    ${client_id}   Wait Until Keyword Succeeds  60  10   Nom Rest Login

    ${Deintegrate_plan}  ${Deintegrate_Plan_name}  Prepare VDU Deintegrate Plan File  gnb_index=${gnb_index}   vdu_index=${vdu_index}

    nom_rest.import_plan  path_to_plan=${Deintegrate_plan}  name=${Deintegrate_Plan_name}   plan_type=DEINTEGRATION
    sleep  5s
    nom_rest.deintegrate_ne  plan_name=${Deintegrate_Plan_name}  timeout=120
    sleep  5s
    NOM Rest Logout   ${client_id}


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
    ${fhgw_config}    Get FHGW Config   gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${fhgw_id}=    set variable   ${fhgw_config["FHGW"]["fhgwId"]}
    ${fhgw_root_password}=    set variable   ${fhgw_config["USERS"]["root_password_plain"]}
    ${fhgw_ssh_ip}=  Set Variable   ${fhgw_config["NETWORKING"]["EXTERNAL_NET"]["NET_DOMAINS"]["NET_MANAGEMENT"]["OAM"]["IPADDRESSV4"]["ipAddress"]}
    ${integrate_file_name}=  set variable      cu${gnb_index}_vdu${vdu_index}_fhgw${fhgw_index}.json
    ${deintegrate_file_name}=  set variable    cu${gnb_index}_vdu${vdu_index}_fhgw${fhgw_index}_deintegrate.json
    ${path_of_integrate_config_file}=   get a file    integrate_config   ${integrate_file_name}
    ${path_of_deintegrate_config_file}=   get a file    integrate_config   ${deintegrate_file_name}
    ${Plan_name}   Set Variable    ${fhgw_id}-No_TLS-Integrate-${timestamp}
    ${plan_file}   _Generate FHGW Integrate to NOM xml File Without TLS
    ...   ${Plan_name}   ${fhgw_id}    ${fhgw_ssh_ip}   ${fhgw_id}  ${fhgw_root_password}
    ${integrate_plan}  Get A File  Integrate_Plan  ${Plan_name}.xml
    create file   ${integrate_plan}   ${plan_file}
    [Return]   ${integrate_plan}  ${Plan_name}


Generate FHGW Integrate to NOM xml File Without TLS
    [Arguments]   ${Plan_name}   ${mrbts_id}    ${oam_ip}  ${ne_id}  #${fhgw_password}
    [Documentation]    Generate integrate/deintegrate config for specified ne.
    ...  create by:        <8-Nove-2021>, jie.8.liu@nokia-sbell.com
    ${xml1}   set variable   <?xml version="1.0" encoding="UTF-8"?><raml xmlns="raml21.xsd" version="2.1">
    ${xml2}   set variable   <cmData type="plan" scope="all" name="${Plan_name}">
    ${xml3}   set variable   <managedObject class="com.nokia.nms.integration:NE3SINT" distName="FHGW-${mrbts_id}/NE3SINT-PREDEFINED"
    ${xml4}   set variable   ${SPACE}operation="create" version="1.0"><p name="host">${oam_ip}</p><p name="port">8080</p>
    ${xml5}   set variable   <p name="neType">FHGW</p><p name="neId">${ne_id}</p><p name="username">root</p><p name="password">Fhgw@systeM!23</p>
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
    [Arguments]   ${Plan_name}   ${mrbts_id}    #${oam_ip}  ${ne_id}  ${fhgw_password}
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



Check NE Deintegrate Result
    [Arguments]      ${log_file}
    [Documentation]    Check ne deintegrate result from log.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <4-Jun-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  integrate_result_file  |  Yes  |  Output log of ne integration  |
    ...
    ...    *RETURN VALUE*
    ...    NA
    ...    Example
    ...    |  Check NE Integrate Result  |   /home/ute/cu3219_integrate_config__output_integrate_result.json   |
    ${integrate_result}=   get file     ${log_file}
    ${response}=    json.loads     ${integrate_result}
    run keyword and continue on failure   should be equal as integers
    ...    ${response["log"]["stats"]["localhost"]["changed"]}
    ...    0     changed value in integrate result log is not 1!
    run keyword and continue on failure   should be equal as integers
    ...    ${response["log"]["stats"]["localhost"]["failures"]}    0     failures in integrate result log is not 0 !

NOM WebEM Login
    [Arguments]   ${https_proxy}=http://10.144.1.10:8080
    [Documentation]    NOM login via webui
    ...                login url is defined in variables.robot as NOM_1_WEBUI_LINK
    ...  author:             hongping.rao@nokia-sbell.com
    ...  history change: <date>,<who>,<what and how>
    ...   31.7.2020,hongping.rao@nokia-sbell.com, initialization
    ...   24.5.2021,j9liu@nokia-sbell.com, chose the work NOM login
    ...   26.10.2021,chris.l.cao@nokia-sbell.com, add ${NOM_WEBEM_LOGIN_INSTANCE_ID} to speed case running time
    ...
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | NOM WebEM Login |
    ${result}  run keyword and return status    SSH To the Primary NOM
    run keyword if    "${result}"=="True"    nom_selenium.Login    ${NOM_1_WEBUI_LINK}    https_proxy=${https_proxy}
    ...    ELSE      nom_selenium.Login
    ...    ${NOM_10_WEBUI_LINK}   username=${USER_NAME_NOM10}   password=${PASSWORD_NOM10}

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
    ${r}   Run Keyword And Return Status   Variable Should Exist   ${NOM_WEBEM_LOGIN_INSTANCE_ID}
    Return From Keyword If  "${r}"=="${False}"
    Return From Keyword If  "${NOM_WEBEM_LOGIN_INSTANCE_ID}"=="${None}"

    nom_selenium.logout

    Set Test Variable   ${NOM_WEBEM_LOGIN_INSTANCE_ID}    ${None}


Get Config INFO From NOM Integration File
   [Arguments]   ${ne_type}=vdu   ${ne_index}=1   ${gnb_index}=0
   [Documentation]    Get Config INFO From NOM Intergrate Json File.
    ...  You need to prepare a folder named integrate_config_file in the same path as the init.py
    ...  it contains integrate file like cu_1.json/vdu_1.json/fhgw_1.json
    ...  it supports multi cu/vdu/fhgw, like cu_2.json/vdu_2.json/fhgw_2.json
    ...  author:             ling.2.zhao@nokia-sbell.com
    ...  modified by:        <3-8-2020>, <lingzhao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  Yes  |  Which integrate file will upload to nom, can be cu, vdu, fggw, cu in default  |
    ...    |  ne_index  |  Yes  |  Which ne for integration or deintegration, 1 in default    |
    ...    |  gnb_index  |  Yes  |  Which gnb for integration or deintegration, 0 in default    |
    ...
    ...    *RETURN VALUE*
    ...    Config INFO in Intergrate File
    ...    Example
    ...    | Get Config INFO From NOM Integration File |  vdu   | 1   | 0   |
   ${local_path_of_config_dir}=     set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}/integrate_config_file
   ${local_path_of_config_file}=    set variable    ${local_path_of_config_dir}/${ne_type}_${ne_index}.json
   file should exist        ${local_path_of_config_file}
   ${config_file_content}=   get file    ${local_path_of_config_file}
   ${config_file_content}=    json.loads     ${config_file_content}
   [Return]    ${config_file_content}

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


NOM Get Parameters List
    [Arguments]  ${distname}   ${parameterslist}
    [Documentation]    NOM get the given parameters' values
    ...  You can get several parameters' value in one time, those parameters can be under different distname
    ...  For example one is under HQZ-FHGW/FHGW-20/MNL-1/SYNC-1, one is under HQZ-FHGW/FHGW-20/EQM-1/RMOD-1
    ...  You can use HQZ-FHGW/FHGW-20 as input DN, and use KW create list to set parameterslist
    ...  author:             zhaori.deng@nokia-sbell.com
    ...  modified by:        <10-9-2020>, <zhadeng>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  distname  |  Yes  |  The certain DN or uplayer DN of the parameters  |
    ...    |  parameterslist  |  Yes  |  The list containing all the checked parameters    |
    ...    *RETURN VALUE*
    ...    Parameters'value list, list element is a dictionary with keys mo_id, parameter_name and parameter_value
    ...    Example
    ...    | NOM Get Parameters List |  HQZ-FHGW/FHGW-20/MNL-1/SYNC-1   | ['activeSyncMode', 'syncStatus'] |
    ${valuelist}=   nom_selenium.get parameters value   dn_name=${distname}   parameter_names_list=${parameterslist}
    [Return]    ${valuelist}

NOM Get Parameter Value
    [Arguments]  ${valuelist}   ${par_object}   ${parametername}
    [Documentation]    NOM get the certain parameter' value
    ...  The precondition is use KW "NOM Get Parameters List" to get the parameters' values list as input 'valuelist'
    ...  Use the exact distname of the given parametername to filter
    ...  It will return the give parameter's value if exist otherwise none
    ...  author:             zhaori.deng@nokia-sbell.com
    ...  modified by:        <10-9-2020>, <zhadeng>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  valuelist  |  Yes  |  The value list return by "NOM Get Parameters List"  |
    ...    |  par_object  |  Yes  | the exact distname of the given parametername    |
    ...    |  parametername  |  Yes  |  The parameter name you want to check   |
    ...    *RETURN VALUE*
    ...    The given parameter's value
    ...    Example
    ...    | NOM Get Parameter Value |   valuelist  |   HQZ-FHGW/FHGW-20/MNL-1/SYNC-1   | syncStatus |
    ${valuelist_length}=   get length   ${valuelist}
    ${par_value}=    set variable    ${None}
    ${parameter_index}=    set variable    ${None}
    FOR    ${i}    IN RANGE    0    ${valuelist_length}
       ${indexflag}=   Set Variable If   '${valuelist[${i}]['parameter_name']}' == '${parametername}'   ${True}   ${False}
       ${parameter_index}=   Set Variable If   '${indexflag}'=='${True}' and '${valuelist[${i}]['mo_id']}' == '${par_object}'   ${i}
       exit for loop if  '${valuelist[${i}]['parameter_name']}'=='${parametername}' and '${valuelist[${i}]['mo_id']}' == '${par_object}'
    END
    ${par_value}=  run keyword if  '${parameter_index}'!='None'  set variable  ${valuelist[${parameter_index}]['parameter_value']}
    [Return]    ${par_value}

Operate Plan From NOM
    [Arguments]     ${importplanname}   ${download_operation}=true  ${validation_operation}=true   ${active_operation}=true
    [Documentation]    Operate plan for NE from NOM
    ...  This KW is to operate plan on NOM SSH via command lines to simulate provision plan from NOM WebEM
    ...  It contains download validation activation actions for the given plan name
    ...  It can be used for vDU and FHGW or any other supported NE on CNMS
    ...  author:             jie.8.liu@nokia-sbell.com
    ...  modified by:        <10-9-2020>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  importplanname  |  Yes  |  The plan name on CNMS  |
    ...    |  download_operation  |  No  |  The download action default is true    |
    ...    |  validation_operation  |  No  |  The validation action default is true    |
    ...    |  active_operation  |  No  |  The activate action default is true    |
    ...    *RETURN VALUE*
    ...    NA
    ...    Example
    ...    | Operate Plan From NOM |  Operate plan for NE from NOM   | true | true | true |
    ${cmd1} =  set variable   curl -v http://operations-execution.neo.svc.cluster.local/api/operations/v1/startRoot
    ${cmd2} =  set variable   "Content-Type: application/json"
    ${cmd3} =  set variable   ' {"operationName":"ne3s-plan-provision", "userName": "user", "operationAttributes":
    ${cmd4} =  set variable   {"planName": "${importplanname}", "operations": {"download": ${download_operation},
    ${cmd5} =  set variable   "validation": ${validation_operation}, "activation": ${active_operation}}}}'
    ${cmd} =   set variable     ${cmd1} -H ${cmd2} -d ${cmd3} ${cmd4} ${cmd5}
    ${NOM_ALIAS}=  SSH To NOM
    issh.execute     ${cmd}   check_result=${False}   alias=${NOM_ALIAS}
    sleep  180s
    Disconnect Interactive Connection  alias=${NOM_ALIAS}


Connect To NOM Sftp Server
    [Documentation]    Connect To NOM Sftp Server
    ...  This keyword is used to get pm log file from nom sftp server.
    ...  author:            chris.l.cao@nokia-sbell.com
    ...  modified by:        <01-02-2021>, <horao>, <initial created>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None |
    ...
    ...    *RETURN VALUE*
    ...    alias to NOM sftp server connection
    ...
    ...    Example
    ...    | ${alias} | Connect To NOM Sftp Server |
    ...    | ${out} | issh.Execute | command=ls -l | alias=${alias} |
    ...    | ${out} | issh.Execute | command=get a.txt | alias=${alias} |
    ...    | disconnect interactive connection | alias=${alias} |
    ...
    ${alias}   get unique id
    Connect To UTE Locally  alias=${alias}
    ${old_prompt}   issh.get_prompt    alias=${alias}
    ${out}   issh.set_prompt   prompt_str=${old_prompt}|password:|sftp>     alias=${alias}

    ${nom_sftp_information}   Get NOM SFTP Information
    ${nom_sftp_user}   Set Variable   ${nom_sftp_information["pm_sftp_username"]}
    ${nom_sftp_password}   Set Variable   ${nom_sftp_information["pm_sftp_password"]}
    ${nom_sftp_server}   Set Variable   ${nom_sftp_information["pm_sftp_ip"]}

    ${output}=  issh.execute  sftp ${nom_sftp_user}@${nom_sftp_server}  check_result=${False}  alias=${alias}
    ${out}   run keyword if   """password:""" in """${output}"""  issh.execute  ${nom_sftp_password}  check_result=${False}  alias=${alias}
    ${out}   issh.set_prompt   prompt_str=${old_prompt}|sftp>     alias=${alias}

    [Return]  ${alias}


NOM Get Pm Files From Sftp Server
    [Arguments]  ${ne_id}   ${local_dir}=/tmp  ${ne_type}=VDU  ${date}=${None}
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    get pm file from nom sftp sever
    ...  This keyword is used to get pm file from nom sftp server.
    ...  author:             hongping.rao@nokia-sbell.com
    ...  modified by:        <01-02-2021>, <horao>, <initial created>
    ...    5.2.2020, chris.l.cao@nokia-sbell.com, change to use 'Connect To NOM Sftp Server', change bts_id to ne_id
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_id  |  Yes  |  ne_id to define which pm log files will be collected from server  |
    ...    |  local_dir  |  No  |  local directory to store log files, default is /tmp   |
    ...    |  ne_type  |  No  |  ne type, such as: VDU, FHGW, default is VDU |
    ...    |  date  |  No  |  get PM log file according to the log date, default is today |
    ...
    ...    *RETURN VALUE*
    ...    local pm file name list
    ...
    ...    Example
    ...    | ${pm_files_list} | NOM Get Pm Files From Sftp Server |  ne_id=5233 | local_dir=/tmp | ne_type=VDU |
    ...
    ${alias}   Connect To NOM Sftp Server
    ${str_nom_date}   Get Date Of NOM Server

    ${nom_sftp_information}   Get NOM SFTP Information
    ${nom_sftp_root_folder}   Set Variable   ${nom_sftp_information["pm_sftp_root_path"]}

    ${date}  set variable if   ${date}   ${date}  ${str_nom_date}
    ${remote_dir}  set variable  ${nom_sftp_root_folder}/${date}/${ne_type}${ne_id}
    ${out}  issh.execute   get ${remote_dir}/*.* ${local_dir}   check_result=${False}  alias=${alias}

    ${empty_list}  create list
    return from keyword if  "not found." in """${out}"""    ${empty_list}

    ${res}    list_files_in_directory    ${local_dir}
    [Return]    ${res}


NOM Get Pm Files From Sftp Server For Rest Integration
    [Arguments]  ${ne_id}   ${local_dir}=/tmp  ${ne_type}=VDU  ${date}=${None}
    [Tags]  NOM_PM
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]    get pm file from nom sftp sever
    ...  This keyword is used to get pm file from nom sftp server.
    ...  author:             hongping.rao@nokia-sbell.com
    ...  modified by:        <01-02-2021>, <horao>, <initial created>
    ...    1.11.2021, chris.l.cao@nokia-sbell.com, support REST integration
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_id  |  Yes  |  ne_id to define which pm log files will be collected from server  |
    ...    |  local_dir  |  No  |  local directory to store log files, default is /tmp   |
    ...    |  ne_type  |  No  |  ne type, such as: VDU, FHGW, default is VDU |
    ...    |  date  |  No  |  get PM log file according to the log date, default is today |
    ...
    ...    *RETURN VALUE*
    ...    local pm file name list
    ...
    ...    Example
    ...    | ${pm_files_list} | NOM Get Pm Files From Sftp Server |  ne_id=5233 | local_dir=/tmp | ne_type=VDU |
    ...
    ${alias}   Connect To NOM Sftp Server
    ${str_nom_date}   Get Date Of NOM Server

    ${date}  set variable if   ${date}   ${date}  ${str_nom_date}
    ${sub_folder}   Set Variable If   "${ne_type}"=="VDU"   MRBTS   "${ne_type}"=="VCU"   MRBTS  unknown
    Run Keyword If   "${sub_folder}"=="unknown"    Not support ${ne_type}!

    ${nom_sftp_information}   Get NOM SFTP Information
    ${nom_sftp_root_folder}   Set Variable   ${nom_sftp_information["pm_sftp_root_path_rest"]}

    #${remote_dir}  set variable  ${nom_sftp_root_folder}/${sub_folder}/${date}/${ne_id}
    ${remote_dir}  OperatingSystem.Join Path  ${nom_sftp_root_folder}  ${sub_folder}    ${date}   ${ne_id}

    ${out}  issh.execute   get ${remote_dir}/*.* ${local_dir}   check_result=${False}  alias=${alias}

    ${empty_list}  create list
    return from keyword if  "not found." in """${out}"""    ${empty_list}

    ${res}    list_files_in_directory    ${local_dir}
    [Return]    ${res}


Get Date Of NOM Server
    [Teardown]  run keyword and ignore error  disconnect interactive connection    alias=${alias}
    [Documentation]    Get Date Of NOM Server
    ...  This keyword is used to get pm log file from nom sftp server.
    ...  author:            chris.l.cao@nokia-sbell.com
    ...  modified by:        <01-02-2021>, <horao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | None |
    ...
    ...    *RETURN VALUE*
    ...    Date Of NOM Server
    ...
    ...    Example
    ...    | ${str_nom_date} | Get Date Of NOM Server |
    ...
    ${alias}   SSH To NOM
    ${date}   issh.Execute   date -I   check_result=${False}   alias=${alias}
    ${date_str}   Replace String   ${date}   -   ${EMPTY}   count=2
    ${date_str_new}   Get Substring   ${date_str}   1   9
    [Return]  ${date_str_new}

NOM Get Active Alarms Via Rest
   [Arguments]    ${integrated_id}
   [Tags]  NOM_FM
   [Documentation]    Logout NOM via rest api.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <04-02-2021>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  integrated_id  |  Yes  |  integrated id  |

    ...    *RETURN VALUE*
    ...    Alarms list
    ...    Example
    ...    |  NOM Get Active Alarms Via Rest  |  integrated_id= HQZ-VDU/MRBTS-5253  |
    ${client_id}=  Nom Rest Login
    ${alarms_info}=  nom_rest.get_alarms_from_integrated_ne  integrated_id=${integrated_id}    only_active=${True}
#   ${all_alarms}  nom_rest.get_active_alarms
    [Return]   ${alarms_info["alarms"]}
    [Teardown]  run keyword and ignore error    NOM Rest Logout    client_id=${client_id}

Nom Rest Login
    [Tags]  NOM_CM
    [Documentation]    Login NOM via rest api.
    ...  author:             fen.huang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    10.10.2021, huilxu@nokia-sbell.com, add the config source
    ...    24.10.2021, chris.l.cao@nokia-sbell.com, add 'NOM Rest logout' before login
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
    ...   | Nom Rest Logout  |
    ...   | Deintegrate NE From NOM  | ne_type=vdu | deintegration_type=rest |
    ...

    Run Keyword And Ignore Error   Nom Rest Logout

    ${NOM_config_source}  Get NOM Config Type From TestLine
    ${client_id}   Run Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"
     ...   _Nom Rest Login With Nom Info From init.py
    ...   ELSE   _Nom Rest Login With Nom Info From global_variable.py

    Set Test Variable   ${NOM_REST_LOGIN_CLIENT_ID}    ${client_id}

    [Return]   ${client_id}


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
    [Documentation]    _Nom Rest Login With Nom Info From global_variable.py
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <14-10-2021>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	  None
    ...
    ...    *RETURN VALUE*
    ...    Client id
    ...    Example
    ...    | ${client_id}  |  _Nom Rest Login With Nom Info From global_variable.py   |

    ${TARGET_NOM_INDEX}  ${TARGET_NOM_INFO}  Get Target NOM server
   # ${client_id}   _Nom Rest Login Via Target Nom Info    ${TARGET_NOM_INFO[${TARGET_NOM_INDEX}]}
    ${client_id}   _Nom Rest Login Via Target Nom Info    ${TARGET_NOM_INFO}
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
    [Return]   ${client_id}


NOM Rest Logout
    [Arguments]   ${client_id}=${None}
    [Documentation]    Logout NOM via rest api.
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
    ...   | Nom Rest Logout  |
    ...   | Deintegrate NE From NOM  | ne_type=vdu | deintegration_type=rest |
    ...
    ${r}   Run Keyword And Return Status   Variable Should Exist   ${NOM_REST_LOGIN_CLIENT_ID}
    Return From Keyword If  "${r}"=="${False}"
    Return From Keyword If  "${NOM_REST_LOGIN_CLIENT_ID}"=="${None}"

    ${client_id}  Set Variable   ${NOM_REST_LOGIN_CLIENT_ID}

    ${NOM_config_source}  Get NOM Config Type From TestLine
    Run Keyword If   "${NOM_config_source}"=="nom_config_source_from_init_py"
    ...   _Nom Rest Logout With Nom Info From init.py  ${client_id}
    ...   ELSE   _Nom Rest Logout With Nom Info From global_variable.py  ${client_id}

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
   [Arguments]   ${client_id}
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


Import Plan From NOM By REST API
    [Arguments]    ${plan_name}  ${plan_xml_file}  ${plan_type}=GENERAL  ${overwrite}=True
    [Documentation]  Import Plan From NOM By REST API.
    ...  author:             mengli.yang@nokia-sbell.com
    ...  modified by:        <04-03-2021>, <mengyang>, <initial created>
	...  modified by: 		 <15-06-2021>, <Zhang,jianlin>, <update kw for new feature CB005703 used>
    ...    | Input Parameters | Man. | Description |
    ...    |  PLAN_NAME  |  Yes  |  plan name for import plan  |
    ...    | plan_xml_file| Yes | xml plan file path to be imported |
    ...    | plan_type |  No  |  plan type to be imported, default is GENERAL, if other type needed input it |
    ...    | overwrite | No | plan to be overwrite on the system, default bool true used |

    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  Import Plan From NOM By REST API  |  plan_name=FHGW_${MRBTS_ID}  |
    log to console   Import plan from NOM
    ${client_id}  Wait Until Keyword Succeeds  180  10   Nom Rest Login
	nom_rest.import_plan  path_to_plan=${plan_xml_file}  name=${plan_name}
    ...  plan_type=${plan_type}  overwrite=${overwrite}
    sleep    10
    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    client_id=${client_id}

Import SW Package From NOM By REST API
    [Arguments]    ${package_file_path}   ${ne_type}=MRBTS      ${sw_version}=None      #${file_name}=None
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
    ${client_id}  Wait Until Keyword Succeeds  180  10   Nom Rest Login
    ${neSwVersion}  Wait Until Keyword Succeeds  180  10  nom_rest.get_sw_package_list
    ${version_exist}=  set variable   ${False}
    for  ${item}  IN  @{neSwVersion}
      run keyword if  '${item['ne_sw_version']}' == '${sw_version}'  Set Test Variable  ${version_exist}  ${True}
    END
    Wait Until Keyword Succeeds  180  10   run keyword if  ${version_exist}==${False}
    ...  nom_rest.import_sw_package  file_path=${package_file_path}  ne_type=${ne_type}
    ...  ELSE   log to console  Currnet SW Package already exist on NOM.
    sleep    10
    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    client_id=${client_id}

Download Plan From NOM By REST API For FHGW
    [Arguments]     ${plan_name}    ${journal_log_name}    ${plan_status}
    [Documentation]  Download plan from NOM by rest api for FHGW and check download plan should be successfully
    ...              and return the download plan KPI.
    ...  author:             mengli.yang@nokia-sbell.com
    ...  modified by:        <04-03-2021>, <mengyang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  PLAN_NAME  |  Yes  |  plan name for import plan  |

    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  Download Plan From NOM By REST API For FHGW |  plan_name=${plan_name}
    ...    | journal_log_name=journal_download /
    ...    |  plan_status=Download  |
    ${START_TIME_FHGW}    Get Start Time In FHGW
    ${client_id}    Nom Rest Login
    nom_rest.download_plan    plan_name=${plan_name}
    sleep    10
    wait until keyword succeeds   10min   15s
    ...   Check The Journal From FHGW Side With Download    journal_log_name=${journal_log_name}
    ...                                                     plan_status=${plan_status}
    ...                                                     start_time=${START_TIME_FHGW}
    ${END_TIME_FHGW}   Get End Time In FHGW
    [Return]    ${START_TIME_FHGW}    ${END_TIME_FHGW}
    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    client_id=${client_id}

Validate Plan From NOM By REST API For FHGW
    [Arguments]     ${plan_name}    ${journal_log_name}    ${plan_status}
    [Documentation]  Validate plan from NOM by rest api for FHGW and check Validate plan should be successfully
    ...              and return the Validate plan KPI.
    ...  author:             mengli.yang@nokia-sbell.com
    ...  modified by:        <04-03-2021>, <mengyang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  PLAN_NAME  |  Yes  |  plan name for import plan  |

    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  Validate Plan From NOM By REST API For FHGW |  plan_name=${plan_name}
    ...    | journal_log_name=journal_validation/
    ...    |  plan_status=Validation  |
    ${START_TIME_FHGW}    Get Start Time In FHGW
    ${client_id}    Nom Rest Login
    nom_rest.validate_plan    plan_name=${plan_name}
    sleep    10
    wait until keyword succeeds   10min   15s
    ...   Check The Journal From FHGW Side With Download    journal_log_name=${journal_log_name}
    ...                                                     plan_status=${plan_status}
    ...                                                     start_time=${START_TIME_FHGW}
    ${END_TIME_FHGW}   Get End Time In FHGW
    [Return]    ${START_TIME_FHGW}    ${END_TIME_FHGW}
    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    client_id=${client_id}

Activate Plan From NOM By REST API For FHGW
    [Arguments]     ${plan_name}    ${journal_log_name}    ${plan_status}
    [Documentation]  Activate plan from NOM by rest api for FHGW and check Activate plan should be successfully
    ...              and return the Activate plan KPI.
    ...  author:             mengli.yang@nokia-sbell.com
    ...  modified by:        <04-03-2021>, <mengyang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  PLAN_NAME  |  Yes  |  plan name for import plan  |

    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  Activate Plan From NOM By REST API For FHGW |  PLAN_NAME=${plan_name}
    ...    | journal_log_name=journal_Activation/
    ...    |  plan_status=Activation |
    ${START_TIME_FHGW}    Get Start Time In FHGW
    ${client_id}    Nom Rest Login
    nom_rest.activate_plan    plan_name=${plan_name}
    sleep    10
    wait until keyword succeeds   10min   15s
    ...   Check The Journal From FHGW Side With Download    journal_log_name=${journal_log_name}
    ...                                                     plan_status=${plan_status}
    ...                                                     start_time=${START_TIME_FHGW}
    ${END_TIME_FHGW}    Get End Time In FHGW
    [Return]    ${START_TIME_FHGW}    ${END_TIME_FHGW}
    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    client_id=${client_id}

Get Start Time In FHGW
    [Arguments]
    [Documentation]  Get Start Time In FHGW,and return the time
    ...  author:             mengli.yang@nokia-sbell.com
    ...  modified by:        <04-03-2021>, <mengyang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  fhgw_alias  |  Yes  | the alias of connect to fhgw|

    ...    *RETURN VALUE*
    ...    | ${START_TIME_FHGW} |
    ...    Example
    ...    |  Get Start Time In FHGW |
    ${fhgw_alias}=   get unique id
    Connect to FHGW   alias=${fhgw_alias}
    ${START_TIME_FHGW}    issh.Execute    command=date +"%Y-%m-%d %H:%M:%S"    alias=${fhgw_alias}
    log to console     ${START_TIME_FHGW}
    ${START_TIME_FHGW}=    Strip String     ${START_TIME_FHGW}
    ${START_TIME_FHGW}=    Split String     ${START_TIME_FHGW}
    Set Suite Variable    ${START_TIME_FHGW}
    log to console     ${START_TIME_FHGW}
    [Return]  ${START_TIME_FHGW}
    [Teardown]   Disconnect Interactive Connection  alias=${fhgw_alias}

Get End Time In FHGW
    [Arguments]
    [Documentation]  Get Start Time In FHGW,and return the time
    ...  author:             mengli.yang@nokia-sbell.com
    ...  modified by:        <04-03-2021>, <mengyang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  fhgw_alias  |  Yes  | the alias of connect to fhgw|

    ...    *RETURN VALUE*
    ...    | ${END_TIME_FHGW} |
    ...    Example
    ...    |  Get Start Time In FHGW |
    ${fhgw_alias}=   get unique id
    Connect to FHGW   alias=${fhgw_alias}
    ${END_TIME_FHGW}=    issh.Execute    command=date +"%Y-%m-%d %H:%M:%S"     alias=${fhgw_alias}
    ${END_TIME_FHGW}=    Strip String     ${END_TIME_FHGW}
    ${END_TIME_FHGW}=    Split String     ${END_TIME_FHGW}
    Set Test Variable    ${END_TIME_FHGW}
    log to console    ${END_TIME_FHGW}
    [Return]  ${END_TIME_FHGW}
    [Teardown]   Disconnect Interactive Connection  alias=${fhgw_alias}

Download Plan From NOM By REST API For vDU
    [Arguments]     ${sleep}    ${plan_name}=${plan_name}   ${vdu_index}=0    ${gnb_index}=0
    [Documentation]  Download plan from NOM by rest api for vDU and check download plan should be successfully
    ...              and return the download plan KPI.
    ...  author:             mengli.yang@nokia-sbell.com
    ...  modified by:        <04-03-2021>, <mengyang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  PLAN_NAME  |  Yes  |  plan name for import plan  |

    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    | Download Plan From NOM By REST API For vDU |  plan_name=${plan_name}  | sleep=60 |
    ${client_id}    Nom Rest Login
    ${download_start_time}=   Begin K8s Log
    nom_rest.download_plan    plan_name=${plan_name}
    sleep    ${sleep}
    ${Download_log_path}=  End K8s Log    handle=${download_start_time}
                         ...    pod_abbr=oam
                         ...    container=all
                         ...    gnb_index=${gnb_index}
                         ...    vdu_index=${vdu_index}
    set test variable     ${Download_log_path}
    [Return]    ${Download_log_path}
    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    client_id=${client_id}

Validate Plan From NOM By REST API For vDU
    [Arguments]     ${sleep}    ${plan_name}=${plan_name}    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]  Validate plan from NOM by rest api for vDU and check Validate plan should be successfully
    ...              and return the Validate plan KPI.
    ...  author:             mengli.yang@nokia-sbell.com
    ...  modified by:        <04-03-2021>, <mengyang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  PLAN_NAME  |  Yes  |  plan name for import plan  |

    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  Validate Plan From NOM By REST API For vDU |  plan_name=${plan_name}  | sleep=60 |
    ${client_id}    Nom Rest Login
    ${Validate_start_time}=   Begin K8s Log
    nom_rest.validate_plan    plan_name=${plan_name}
    sleep    ${sleep}
    ${Validate_log_path}=  End K8s Log    handle=${Validate_start_time}
                         ...    pod_abbr=oam
                         ...    container=all
                         ...    gnb_index=${gnb_index}
                         ...    vdu_index=${vdu_index}
    set test variable     ${Validate_log_path}
    [Return]    ${Validate_log_path}
    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    client_id=${client_id}

Activate Plan From NOM By REST API For vDU
    [Arguments]     ${sleep}    ${plan_name}    #${vdu_index}=0    ${gnb_index}=0
    [Documentation]  Activate plan from NOM by rest api for vDU and check Activate plan should be successfully
    ...              and return the Activate plan KPI.
    ...  author:             mengli.yang@nokia-sbell.com
    ...  modified by:        <04-03-2021>, <mengyang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  PLAN_NAME  |  Yes  |  plan name for import plan  |

    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  Activate Plan From NOM By REST API For vDU |  plan_name=${plan_name}  | sleep=60 |
    ${client_id}  Wait Until Keyword Succeeds  180  10    Nom Rest Login
    ${activate_start_time}=   Begin K8s Log
    nom_rest.activate_plan    plan_name=${plan_name}   timeout=120
    sleep    ${sleep}
    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    client_id=${client_id}


Activate Autoconfiguration Plan From NOM By REST API For vDU
    [Arguments]     ${plan_name}   ${apply_templates}=True   ${validate}=True   ${overwrite}=True   ${timeout}=300
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
    ...       apply_templates=True | validate=True | overwrite=True | timeout=10
    ${client_id}  Wait Until Keyword Succeeds  180  10    Nom Rest Login
    ${operation_result}  nom_rest.activate_autoconfiguration   plan_name=${plan_name}
    ...  apply_templates=${apply_templates}   validate=${validate}   overwrite=${overwrite}   timeout=${timeout}
    for  ${item}  IN  @{operation_result}
      run keyword if  '${item['status']}' == 'finished'  log to console  Active Auto-configuration Plan Success!
    END
    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    client_id=${client_id}


Cell Status Should Be On Air From NOM WebEM
    [Arguments]     ${MRBTS_ID}
    [Documentation]  Cell Status Should Be On Air From NOM WebEM
    ...  author:             jianlin.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  MRBTS_ID  |  Yes  |  MRBTS id for vDU configured |
    ...    Example
    ...    |  Cell Status Should Be On Air From NOM WebEM |  5326 |
    ${nrbts_distinguished_name}  set variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ${cell_distinguished_name}   set variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ${parameter_list}   create list    administrativeState  operationalState
    NOM WebEM Login
    ${para_value_nrbts}  NOM Get Parameters List  ${nrbts_distinguished_name}  ${parameter_list}
    ${para_value_list}  NOM Get Parameters List  ${cell_distinguished_name}   ${parameter_list}
    ${value_nrbts_operationalState}  NOM Get Parameter Value   ${para_value_nrbts}  ${nrbts_distinguished_name}  operationalState
    ${value_administrativeState}  NOM Get Parameter Value   ${para_value_list}  ${cell_distinguished_name}  administrativeState
    ${value_operationalState}  NOM Get Parameter Value   ${para_value_list}  ${cell_distinguished_name}  operationalState
    log to console    nrbts_operationalState=${value_nrbts_operationalState}  administrativeState=${value_administrativeState},
    ...  operationalState=${value_operationalState}
    Should be equal    ${value_nrbts_operationalState}  onAir
    Should be equal    ${value_administrativeState}  unlocked
    Should be equal    ${value_operationalState}  enabled


Check The Journal From FHGW Side With Download
    [Arguments]      ${journal_log_name}    ${plan_status}    ${start_time}
    [Documentation]  Check The Journal From FHGW Side With Download.
    ...  author:             mengli.yang@nokia-sbell.com
    ...  modified by:        <04-03-2021>, <mengyang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  PLAN_NAME  |  Yes  |  plan name for import plan  |

    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  Check The Journal From FHGW Side With Download |   journal_log_name=${journal_log_name}
    ...    | plan_status=${plan_status}/
    ${fhgw_alias}=   get unique id
    Connect to FHGW   alias=${fhgw_alias}
    ${END_TIME}=    issh.Execute    command=date +"%Y-%m-%d %H:%M:%S"     alias=${fhgw_alias}
    ${END_TIME}=    Strip String     ${END_TIME}
    ${END_TIME}=    Split String     ${END_TIME}
    set variable    ${END_TIME}
    ${cmd} =   set variable
    ...  journalctl --since="${start_time[0]} ${start_time[1]}" --until="${END_TIME[0]} ${END_TIME[1]}">/root/${journal_log_name}.log
    ${out}   issh.Execute  command= ${cmd}   alias=${fhgw_alias}
    ${remote_file}   set variable   /root/${journal_log_name}.log
    OperatingSystem.Run    command=sudo chmod 777 ${remote_file}
    ${result}     issh.Execute  command=cat ${journal_log_name}.log | grep ${plan_status} | grep success*
    ...                         alias=${fhgw_alias}
    should not be empty    ${result}


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
    ${r}  ${dummy}   run keyword and ignore error   set variable   ${TARGET_NOM_INDEX}
    return from keyword if  "${r}"=="PASS"    ${TARGET_NOM_INDEX}    ${TARGET_NOM_INFO}

    ${TARGET_NOM_INDEX}    ${TARGET_NOM_INFO}    _Get Target NOM Server Index
    set test variable   ${TARGET_NOM_INDEX}
    set test variable   ${TARGET_NOM_INFO}
    [Return]    ${TARGET_NOM_INDEX}     ${TARGET_NOM_INFO}


Get Export plan Via NOM For VDU
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Tags]  NOM_CM
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
    ...
    ${vdu_conf}   Get VDU Conf From SCF    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${mrbts_id}  Set Variable  ${vdu_conf["mrbts_id"]}

    ${random_id}   Get Unique ID  precise=FORMAT_DATETIME
    ${plan_file}  Get A File   NOM_plan_file    exported_plan_${random_id}.xml
    ${scope}  Create List   MRBTS-${mrbts_id}

    ${export_plan}   nom_rest.export_plan   ${plan_file}   ${scope}
    [Return]  ${plan_file}


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
    ...   | Nom Rest Login |
    ...   | ${btsName} | Get Parameter Value Via NOM For VDU | dist_name=MRBTS-1234 | parameter_name=btsName |
    ...   | ${sw_version} | Get Parameter Value Via NOM For VDU | dist_name=MRBTS-1234/MNL-1/MNL_R-1 | parameter_name=activeSWReleaseVersion |
    ...   |  Nom Rest Logout  |
    ...   | Deintegrate NE From NOM  | ne_type=vdu | deintegration_type=rest |
    ...
    ${exported_plan_file}      Get Export plan Via NOM For VDU   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    scf.Load_Scf  file_path=${exported_plan_file}

    ${value}   Run Keyword If   "${list_name}"!="${EMPTY}"
    ...    scf.Get_Value_From_Scf    dist_name=${distname}   list_name=${list_name}   p_name=${parameter_name}
    ...   ELSE   scf.Get_Value_From_Scf    dist_name=${distname}     p_name=${parameter_name}
    [Return]  ${value}

Import plan from NOM via Rest
    [Documentation]   import plan use rest
    ...   author:             jie.8.liu@nokia-sbell.com
    ...   write by:        <7-12-2021>, <j9liu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  |  Yes  |  plan name for import plan  |
    ...    |  fhgw_index  |  Yes  |  defaute 0 |
    ...    *RETURN VALUE*
    ...
    [Arguments]   ${gnb_index}=0   ${fhgw_index}=0
    log to console   Import plan from NOM
    ${Delta_plan_path}  ${Delta_Plan_name}  _Generate FHGW Delta PLan  gnb_index=${gnb_index}   fhgw_index=${fhgw_index}
    ${client_id}  Wait Until Keyword Succeeds  180  10   Nom Rest Login
	nom_rest.import_plan  path_to_plan=${Delta_plan_path}  name=${Delta_Plan_name}
    sleep    10
    [Return]    ${Delta_plan_path}    ${Delta_Plan_name}
    [Teardown]  Run Keyword And Ignore Error   NOM Rest Logout    client_id=${client_id}
