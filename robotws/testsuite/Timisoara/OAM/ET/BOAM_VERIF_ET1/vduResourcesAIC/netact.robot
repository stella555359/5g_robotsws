*** Settings ***
Documentation
...  author: luofei.tu@nokia-sbell.com
...   contact: luofei.tu@nokia-sbell.com
...   Description:This robot is mainly for putting the CB007467 common keywords

#Resource        aic_common_resources.robot





#*** Variables ***



*** Keywords ***
Get Mrbts Name via NE Type
    [Arguments]  ${NE_type}=vCU  ${gnb_index}=0   ${vdu_index}=0  ${fhgw_index}=0
    [Documentation]   Set netact from testline config file, please config instance id and fhgw id in your __init__ file
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   22.11.2021,chris.l.cao@nokia-sbell.com, change to get fhgw_id from fhgw_user_config_0.yaml,because this yaml file exists in every testline
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | NE_type  | Yes |   default is vCU , all value are vCU,vDU,FHGW|
    ...    | gnb_index  | No | default 0 |
    ...    | vdu_index  | No | default 0 |
    ...    | fhgw_index  | No | default 0 |
    ...
    ...    *RETURN VALUE*
    ...    mrbts_name     eg: MRBTS-1234   FHGW-5678
    ...
    ...    Example
    ...    | ${mrbts_name}= | Get Mrbts Name via NE Type |
    ...
#    ${mrbts_name}    run keyword if  "${NE_type}"=="vCU"      set variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}
#    ...   ELSE IF  "${NE_type}"=="vDU"   set variable   MRBTS-${tl.gnbs[${gnb_index}].dus[${vdu_index}].instance_id}
#    ...   ELSE   "${NE_type}"=="FHGW"   set variable   FHGW-${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgw[${fhgw_index}].fhgw_id}

    ${NE_type}  Set Variable   ${NE_type.upper()}
    ${NE_type}  Set Variable If   "${NE_type}"=="CU"    VCU    ${NE_type}

    ${fhgw_config}  Run Keyword If  "${NE_type}"=="FHGW"
       ...   Get FHGW Config   gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${fhgw_id}     Set Variable If   "${NE_type}"=="FHGW"   ${fhgw_config["FHGW"]["fhgwId"]}

    ${mrbts_name}    run keyword if  "${NE_type}"=="VCU"      set variable    MRBTS-${tl.gnbs[${gnb_index}].instance_id}
    ...   ELSE IF  "${NE_type}"=="VDU"   set variable   MRBTS-${tl.gnbs[${gnb_index}].dus[${vdu_index}].instance_id}
    ...   ELSE IF  "${NE_type}"=="FHGW"   set variable   FHGW-${fhgw_id}
    ...   ELSE     Fail    Unknown NE_type:${NE_type}!
    [Return]   ${mrbts_name}

Set netact from testline config file
    [Arguments]   ${netact_index}=clab3766
    [Documentation]   Set netact from testline config file, please config netact info in your __init__ file
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | netact_index | No | netact id  default is clab3766|
    ...
    ...    *RETURN VALUE*
    ...     ${netact}
    ...
    ...    Example
    ...    | ${netact} | Set netact from testline config file |
    ${netact_idinfo}   set variable   ${tl.nms.addr}
    ${netact}   set variable   ${netact_idinfo}[${netact_index}]
    Set Suite Variable   ${netact}


ssh to netact node
     [Arguments]   ${alias}=default  ${netact_index}=clab3766   # ${service_name}=cmwas
    [Documentation]   Create an instance of SshNode class, establishes temporary ssh connection as first verification
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    modified by:        <13-Oct-2020>, <huilxu>, <Initial creation>
    ...    23.9.2021, honyuan.sun@nokia-sbell.com, add to support netact redundancy
    ...    23.10.2021,chris.l.cao@nokia-sbell.com, remove global variable NETACT_CONFIG_SOURCE
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | service_name  | No | default is cmwas,Supported services:‘cmwas’,‘fmwas’,‘itsmwas’,‘nwi3’,‘cls-services’,
    ...                         ‘cls-db’ |
    ...    | alias        | No | Netact instance name. Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    alias
    ...
    ...    Example
    ...    | ${alias} | ssh to netact node |
    #${NETACT_CONFIG_SOURCE}  Get netact Config Type From TestLine
    # set test variable   ${NETACT_CONFIG_SOURCE}
    ${netact_config_source}  Get netact Config Type From TestLine
    ${client_id}   Run Keyword If   "${netact_config_source}"=="netact_config_source_from_init_py"
    ...   _ssh to netact node Info From init.py   netact_index=${netact_index}
    ...   ELSE   _ssh to netact node Info From global_variable.py
    [Return]  ${alias}


_ssh to netact node Info From init.py
    [Arguments]    ${service_name}=cmwas  ${netact_index}=clab3766   #${alias}=default
    [Documentation]    _netact ssh With netact Info From init.py
    ...    *AUTHOR* hongyuan.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | netact_index | yes | netact index for select netact info |
    ...
    ...    *RETURN VALUE*
    ...    Client id
    ...    Example
    ...    |  ${client_id}  |  _ssh to netact node Info From init.py  |

    ${client_id}=  get unique id
    Set netact from testline config file   netact_index=${netact_index}
    taf_netact.add_node
    ...   service_name=${service_name}
    ...   hostname=${netact["node_ip"]}
    ...   username=${netact["user"]}
    ...   password=${netact["password"]}
    ...   alias=default
    [Return]   ${client_id}


_ssh to netact node Info From global_variable.py
    [Documentation]    _netact ssh With netact Info From global_variable.py
    ...    *AUTHOR* hongyuan.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	  None
    ...
    ...    *RETURN VALUE*
    ...    Client id
    ...    Example
    ...    | ${client_id}  |  _ssh to netact node Info From global_variable.py   |

    ${TARGET_NETACT_INDEX}  ${TARGET_NETACT_INFO}  Get Target netact server
    ${client_id}   _ssh to netact Via Target Netact Info    ${TARGET_NETACT_INFO}
    [Return]   ${client_id}

Get Target Netact Server
    [Documentation]   Get the Target netact server.
    ...               Get the Target netact ip username password and link info
    ...    *AUTHOR* hongyuan.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    netact server info
    ...    Example
    ...    |  |    |
    ${r}  ${dummy}   run keyword and ignore error   set variable   ${TARGET_NETACT_INDEX}
    return from keyword if  "${r}"=="PASS"    ${TARGET_NETACT_INDEX}    ${TARGET_NETACT_INFO}

    ${TARGET_NETACT_INDEX}    ${TARGET_NETACT_INFO}    _Get Target netact Server Index
    set test variable   ${TARGET_NETACT_INDEX}
    set test variable   ${TARGET_NETACT_INFO}
    [Return]    ${TARGET_NETACT_INDEX}     ${TARGET_NETACT_INFO}

_ssh to netact Via Target Netact Info
    [Arguments]  ${netact_info}   ${service_name}=cmwas   ${alias}=default
    [Documentation]   ssh to netact Via Target Netact Info
    ...    *AUTHOR* hongyuan.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | netact_info  | Yes | from global_variables.py |
    ...    | service_name | Yes | Supported services: ‘cmwas’,‘fmwas’,‘itsmwas’,‘nwi3’,‘cls-services’,‘cls-db’|
    ...    | alias        | Yes | Netact instance name. Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    netact server info
    ...    Example
    ...    |  |    |
    ${client_id}=  get unique id
    ${hostname}   Set Variable  ${netact_info["node_ip"]}
    ${username}    Set Variable  ${netact_info["user"]}
    ${password}   Set Variable  ${netact_info["password"]}

    taf_netact.delete_node
    ...   service_name=${service_name}
    ...   alias=${alias}

    taf_netact.add_node
    ...   service_name=${service_name}
    ...   hostname=${hostname}
    ...   username=${username}
    ...   password=${password}
    ...   alias=default
    [Return]   ${client_id}

disconnect to netact node
    [Arguments]    ${service_name}=cmwas   ${alias}=default
    [Documentation]   delete an instance of SshNode class, disconnect temporary ssh connection as first verification
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | service_name  |Yes | Supported services: ‘cmwas’,‘fmwas’,‘itsmwas’,‘nwi3’,‘cls-services’,‘cls-db’|
    ...    | alias        | Yes | Netact instance name. Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...
    ...
    ...    Example
    ...    |  ${alias}| ssh to netact node |
    ...    | disconnect to netact node | alias=${alias} |
    taf_netact.delete_node
    ...   service_name=${service_name}
    ...   alias=${alias}

login netact via web url
     [Arguments]     ${alias}=default
    [Documentation]   Add Netact web user interface data.
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias   | No | Netact instance name. Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    alias
    ...
    ...    Example
    ...    | login netact via web url |
    taf_netact.add_web_url
    ...   web_url=${netact['url']}
    ...   username=${netact['url_user']}
    ...   password=${netact['url_password']}
    ...   alias=default
    [Return]  ${alias}

============= CM Editor Start ============
Delete Plan Configuration
    [Arguments]     ${plan}
    [Documentation]   Delete Plan Configuration
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...   | plan (Plan)  | Yes | Object returned by create_plan_configuration or get_plan_configuration.
    ...
    ...    *RETURN VALUE*
    ...
    ...
    ...    Example
    ...    | Delete Plan Configuration |
    taf_netact.delete_plan_configuration   name=${plan}

Edit Plan Configuration
    [Arguments]     ${alias}=default
    [Documentation]   Edit Plan Configuration
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...   | alias | No | Netact instance name. Default value is ‘default’.
    ...
    ...    *RETURN VALUE*
    ...    alias
    ...
    ...    Example
    ...    | Edit Plan Configuration |
    ${actual}   taf_netact.edit_plan_configuration   alias=${alias}


Get Actual Plan
    [Arguments]     ${alias}=default
    [Documentation]   Get Actual Plan
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias          | No | Netact instance name. Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    Actual Plan
    ...
    ...    Example
    ...    | Get Actual Plan |
    ${alias}    login netact via web url
    ${actual}    taf_netact.get_actual_configuration   alias=${alias}
    [Return]   ${actual}

Get Plan Configuration
    [Arguments]   ${alias}=default
    [Documentation]   Get all mrbts Plan Configuration from netact
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias          | No | Netact instance name. Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    alias
    ...
    ...    Example
    ...    | Get Actual Plan |
    ${alias}    login netact via web url
    ${plan}    taf_netact.get_plan_configuration   alias=${alias}
    [Return]   ${plan}

============= CM Editor END ============

============= CM Operations Manager Start ============

Upload MRBTS Config To Netact
    [Arguments]  ${mrbts_name}   ${parameters}=None  ${verbose}=True  ${schedule}=None  ${ignore_errors}=False
    ...    ${timeout}=7200  ${alias}=None
    [Documentation]   Upload Configuration
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | parameters (dict) | No | Parameters not parameterized at the level of method but allowed by CLI,
    ...                       e.g.: {’-lteHwContentInUse’: True, ‘-sranBtsHwContentInUse’: True}
    ...    | verbose (bool)  | No | If True, returns more detailed output from executed operation.
    ...    | schedule (string) | No | prepare_schedule method should be used to obtain correct value.
    ...    | ignore_errors (bool) | No |  If True, shows warnings instead of raising errors when operation fails.
    ...    | timeout ((int|string)) | No |  Timeout for executing operation.
    ...    | alias  | No | Netact instance name. Default value is ‘default’.
    ...
    ...    *RETURN VALUE*
    ...    Operation output.
    ...
    ...    Example
    ...    | Upload Alarms IN Netact |
    ${alias}   ssh to netact node
    ${out_put}    taf_netact.upload_configuration
    ...  dist_names=PLMN-PLMN/${mrbts_name}
    ...  parameters=${parameters}
    ...  verbose=${verbose}
    ...  schedule=${schedule}
    ...  ignore_errors=${ignore_errors}
    ...  timeout=${timeout}
    ...  alias=${alias}
    [Return]   ${out_put}
    [Teardown]  disconnect to netact node  alias=${alias}

Get VCU Scf File From Test Line And Convert With PLMN
    [Arguments]  ${gnb_index}=0   ${file_name}=CU_SCF_0.250.xml   ${new_file_name}=CU_SCF.xml
    [Documentation]  Get VCU scf File From Test Line And Convert With PLMN-PLMN prefix in MRBTS MO
    ...  author: luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | file_name | no | scf in DEP_SCF_FILES/CU_0, default is 0 |
    ...	   | new_file_name | no | new scf file name |
    ...
    ...    *RETURN VALUE*
    ...    SCF file name
    ...
    ...    Example
    ...    | ${vcu_scf} | Get VCU Scf File From Test Line And Convert With PLMN |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.default_cfg_dir}
    ${vcu_scf_file}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/${file_name}
    ${vcu_scf_file_path}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/
    OperatingSystem.File Should Exist   ${vcu_scf_file}
    modify_scf_for_netact  ${vcu_scf_file}   ${new_file_name}
    [Return]   ${vcu_scf_file_path}   ${new_file_name}


Import Configuration To Netact
    [Arguments]   ${file_name}  ${local_dir}=None  ${remote_file_path}=None  ${operation_type}=plan
    ...    ${file_format}=RAML2   ${plan_name}=None  ${ui_values}=None  ${parameters}=None  ${verbose}=True
    ...    ${schedule}=None  ${ignore_errors}=False  ${timeout}=7200  ${alias}=None
    [Documentation]   Import Configuration To Netact
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | file_name  | Yes |Specifies the file name. This parameter (together with local_dir) or remote_file_path |
    ...                        must be specified. If both are provided then the remote_file_path parameter is used.  |
    ...          If local_dir is not provided then given file_name must exist on  Netact under default import directory|
    ...
    ...    | local_dir | No | If set then given file_name is copied from it to Netact default import directory |
    ...    | remote_file_path | No | Specifies the full file path for the import operation that must exist on NetAct
    ...       This parameter or the file_name parameter (together with local_dir) must be specified.
    ...       If both are specified then the remote_file_path is used  |
    ...    | operation_type  | No |Specifies the type of import operation (plan/template/site/siteTemplate)|
    ...    | file_format  | No | Specifies a file format (RAML2/CSV/XLSX) |
    ...    | plan_name (string) | No | Specifies a plan name |
    ...    | ui_values (bool) | No |Specifies if the file should be imported with UI parameters’ values
    ...                             Default value is Internal values |
    ...    | parameters (dict) |  Parameters not parameterized at the level of method but allowed by CLI, e.g.: {
    ...                         ’-useObjectOperationDefinedInImportFile’: True, ‘-mergeImport’: True }
    ...    | verbose (bool) | No |If True, returns more detailed output from executed operation |
    ...    | schedule (string) | No | prepare_schedule method should be used to obtain correct value |
    ...    | ignore_errors (bool) | No | If True, shows warnings instead of raising errors when operation fails.
    ...    | timeout ((int|string)) | No | Timeout for executing operation |
    ...    | alias (string) | No| Netact instance name. Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    Operation output.
    ...
    ...    Example
    ...    | ${out_put} |Import Configuration To Netact |
    ${alias}   ssh to netact node
    ${del_out_put}   run keyword and ignore error  taf_netact.delete_plan   plan_name=${plan_name}
    ${out_put}    taf_netact.import_configuration
    ...  file_name=${file_name}
    ...  local_dir=${local_dir}
    ...  remote_file_path=${remote_file_path}
    ...  operation_type=${operation_type}
    ...  file_format=${file_format}
    ...  plan_name=${plan_name}
    ...  ui_values=${ui_values}
    ...  parameters=${parameters}
    ...  verbose=${verbose}
    ...  schedule=${schedule}
    ...  ignore_errors=${ignore_errors}
    ...  timeout=${timeout}
    ...  alias=${alias}
    [Return]   ${out_put}
    [Teardown]   disconnect to netact node  alias=${alias}

Provision Plan IN Netact
    [Arguments]   ${mrbts_name}  ${plan_name}=defualt   ${backup_plan_name}=default  ${create_backup_plan}=False
    ...     ${provisioning_operation}=activate   ${parameters}=None  ${verbose}=True  ${schedule}=None
    ...     ${ignore_errors}=False   ${timeout}=7200  ${alias}=None
    [Documentation]  Provision Plan
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | mrbts_name (string) | No | eg: MRBTS-1 |
    ...    | plan_name (string) | No | Specifies a plan name |
    ...    | backup_plan_name (string) | Specifies a backup plan name |
    ...    | create_backup_plan (bool) | Specifies whether a backup plan is created or not |
    ...    | provisioning_operation (string) | Specifies a provisioning operation (activate/preactivate) |
    ...    | parameters (dict) –Parameters not parameterized at the level of method but allowed by CLI,
    ...         e.g.: {’-lteHwContentInUse’: True, ‘-sranBtsHwContentInUse’: True}  |
    ...    | verbose (bool) | If True, returns more detailed output from executed operation |
    ...    | schedule (string) | prepare_schedule method should be used to obtain correct value |
    ...    | ignore_errors (bool) | If True, shows warnings instead of raising errors when operation fails |
    ...    | timeout ((int|string)) | Timeout for executing operation |
    ...    | alias (string) | Netact instance name. Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    Operation output.
    ...
    ...    Example
    ...    | ${out_put}| Upload Alarms IN Netact |
    ${alias}   ssh to netact node
    ${out_put}    taf_netact.provision_plan
    ...  plan_name=${plan_name}
    ...  dist_names=PLMN-PLMN/${mrbts_name}
    ...  backup_plan_name=${backup_plan_name}
    ...  create_backup_plan=${create_backup_plan}
    ...  provisioning_operation=${provisioning_operation}
    ...  parameters=${parameters}
    ...  verbose=${verbose}
    ...  schedule=${schedule}
    ...  ignore_errors=${ignore_errors}
    ...  timeout=${timeout}
    ...  alias=${alias}
    [Return]   ${out_put}
    [Teardown]  disconnect to netact node  alias=${alias}

============= CM Operations Manager End ============

============= Monitor FM Start ============


Upload Alarms IN Netact
    [Arguments]   ${mrbts_name}
    [Documentation]   Upload Alarms IN Netact
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    | mrbts_name (string) | No | eg: MRBTS-1 |
    ...
    ...    *RETURN VALUE*
    ...    ${out_put}
    ...
    ...    Example
    ...    | Upload Alarms IN Netact |
    ${alias}   ssh to netact node   service_name=fmwas
    ${out_put}    taf_netact.upload_alarms
    ...  dist_name=PLMN-PLMN/${mrbts_name}
    ...  alias=${alias}
    [Return]   ${out_put}


Get All Alarms From Netact
    [Arguments]   ${mrbts_name}
    [Documentation]   Get All Alarms From Netact
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    | mrbts_name (string) | No | eg: MRBTS-1 |
    ...
    ...    *RETURN VALUE*
    ...    alarm list
    ...
    ...    Example
    ...    | Get All_Alarms|
    ${alias}  login netact via web url
    ${alarm_list}    taf_netact.get_alarms
    ...  dist_name=PLMN-PLMN/${mrbts_name}
    ...  alias=${alias}
    [Return]  ${alarm_list}


============= Monitor FM End ============

============= NE Integration Wizard Start ============


Integrate To NetAct
    [Arguments]  ${mrbts_name}  ${release}  ${ne_type}   ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0  ${alias}=default
    ...   ${ip_version}=IPv4   ${security_mode}=No TLS
    [Documentation]   Integrate MRBTS With NetAct
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | mrbts_name (string) | No | eg: MRBTS-1 |
    ...    | release (string) | SW release, e.g., SBTS18 or SBTS20C (case insensitive) |
    ...    | NE_type  | Yes |   default is vCU , all value are vCU,vDU,FHGW|
    ...    | gnb_index  | No | default 0 |
    ...    | vdu_index  | No | default 0 |
    ...    | fhgw_index  | No | default 0 |
    ...    | ip_version (string) | No | IP protocol version network element uses: ‘IPv4’ or ‘IPv6’ (case insensitive) |
    ...    | security_mode (string) | No | TLS (Transport Layer Security) supported: ‘TLS’ or ‘no TLS’ (case insensitive)|
    ...    | alias (string) | No |Netact instance name. Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    alias  integration_logs
    ...
    ...    Example
    ...    | Integrate To NetAct |
    ${alias}  ${logs}   run keyword if   "${ne_type}"=="vCU"  _vCU MRBTS Integrate To NetAct  mrbts_name=${mrbts_name}
    ...   release=${release}    gnb_index=${gnb_index}   alias=${alias}   ip_version=${ip_version}   security_mode=${security_mode}
    ...   ELSE IF   "${ne_type}"=="vDU"  _vDU MRBTS Integrate To NetAct   mrbts_name=${mrbts_name}   release=${release}
    ...   gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}   ip_version=${ip_version}   security_mode=${security_mode}
    ...   ELSE IF   "${ne_type}"=="FHGW"  _FHGW Integrate To NetAct   mrbts_name=${mrbts_name}   release=${release}
    ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ...   alias=${alias}   ip_version=${ip_version}   security_mode=${security_mode}


Integrate NE To Netact
   [Arguments]   ${ne_type}=vCU   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0  ${alias}=default   ${security_mode}=No TLS
   ...   ${netact_index}=clab3766
   [Documentation]    Integrate ne to Netact by ne type, ne index and which nom will be integrated to.
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...     modified by:        <11-03-2021>, <hongysun>, <modify>
    ...    | Input Parameters | Man. | Description |
    ...    |  ne_type  |  No  |  Which type of ne will be integrated, can be cu/vdu/fhgw, cu in default   |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...    | alias (string) | No | Netact instance name. Default value is ‘default’ |
    ...    | security_mode | No | 'TLS' or 'no TLS', default value is 'no TLS' |
    ...    |       TLS: Transport Layer Security supported, 'no TLS': not support TLS, this parameter is case insensitive. |
    ...    | security_mode | yes | netact id about Integrate NE To Netact info |
    ...
    ...    *RETURN VALUE*
    ...    mrbts_name  logs
    ...
    ...    Example
    ...    | ${mrbts_name_vcu} | ${logs} | Integrate NE To Netact |  ne_type=vCU  |
    ...    | ${mrbts_name_vdu} | ${logs} | Integrate NE To Netact |  ne_type=vDU  | security_mode=TLS |
    ...    | ${mrbts_name_fhgw} | ${logs} | Integrate NE To Netact | ne_type=fhgw  |
    ...    | Deintegrate From NetAct  | mrbts_name=${mrbts_name_vcu} |
    ...    | Deintegrate From NetAct  | mrbts_name=${mrbts_name_vdu} |
    ...    | Deintegrate From NetAct  | mrbts_name=${mrbts_name_fghw} |
    ...
    ...    Integration VDU to Netact and provision delta plan
    ...    | ${mrbts_name_vdu} | ${logs} | Integrate NE To Netact |  ne_type=vDU |
    ...    | Login Netact Via Web Url |
    ...    | ${status} |  Provision Delta Plan via Netact | dalta_plan_path=/tmp/myscf.xml |
    ...    | Deintegrate From NetAct  | mrbts_name=${mrbts_name_vdu} |
    ...

    ${mrbts_name}    Get Mrbts Name via NE Type  NE_type=${ne_type}    gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${ne_type}  Set Variable   ${ne_type.upper()}
    ${ne_type}  Set Variable If   "${ne_type}"=="CU"    VCU    ${ne_type}

    ${ip_v6}   Check if OAM is IPv6    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${ip_version}   set variable if   "${ip_v6}"=="True"   IPv6   IPv4
    ${release}  Set Variable If  "${ne_type}"=="VCU"   5G22R1CU
    ...  "${ne_type}"=="VDU"   5G22R1VDU
    ...  "${ne_type}"=="FHGW"   FHGW22R1   UNKNOWN_NE_TYPE
    Run Keyword If   "${release}"=="UNKNOWN_NE_TYPE"   Fail   Unknown NE type!

    ${logs}   run keyword if   "${ne_type}"=="VCU"  _vCU MRBTS Integrate To NetAct  mrbts_name=${mrbts_name}
    ...   release=${release}    gnb_index=${gnb_index}   alias=${alias}   ip_version=${ip_version}   security_mode=${security_mode}
    ...   netact_index=${netact_index}
    ...   ELSE IF   "${ne_type}"=="VDU"  _vDU MRBTS Integrate To NetAct   mrbts_name=${mrbts_name}   release=${release}
    ...   gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    ...   ip_version=${ip_version}   security_mode=${security_mode}  netact_index=${netact_index}
    ...   ELSE IF   "${ne_type}"=="FHGW"  _FHGW Integrate To NetAct   mrbts_name=${mrbts_name}   release=${release}
    ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ...   alias=${alias}   ip_version=${ip_version}   security_mode=${security_mode}  netact_index=${netact_index}
    [Return]   ${mrbts_name}   ${logs}


_vCU MRBTS Integrate To NetAct
    [Arguments]  ${mrbts_name}  ${release}   ${gnb_index}=0   ${alias}=default   ${ip_version}=IPv4  ${security_mode}=No TLS
    ...  ${netact_index}=clab3766
    [Documentation]   Integrate vCU MRBTS With NetAct
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    modified by:        <13-Oct-2020>, <huilxu>, <Initial creation>
    ...    23.9.2021, honyuan.sun@nokia-sbell.com, add to support netact redundancy
    ...    23.10.2021,chris.l.cao@nokia-sbell.com, remove global variable NETACT_CONFIG_SOURCE, and support netact redundancy
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | mrbts_name (string) | No | eg: MRBTS-1 |
    ...    | release (string) | SW release, e.g., SBTS18 or SBTS20C (case insensitive) |
    ...    | gnb_index  | No | default 0 |
    ...    | ip_version (string) | No | IP protocol version network element uses: ‘IPv4’ or ‘IPv6’ (case insensitive) |
    ...    | security_mode (string) | No | TLS (Transport Layer Security) supported: ‘TLS’ or ‘no TLS’ (case insensitive)|
    ...    | alias (string) | No |Netact instance name. Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    alias  integration_logs
    ...
    ...    Example
    ...    | Integrate To NetAct |
    ${alias}   ssh to netact node   netact_index=${netact_index}
    ${netact_config_source}  Get netact Config Type From TestLine

    Run Keyword If  "${netact_config_source}"=="netact_config_source_from_global_variable_py"   Get Target Netact Server
    ${mr_info}  Set Variable If  "${netact_config_source}"=="netact_config_source_from_global_variable_py"
          ...   ${TARGET_NETACT_INFO["mr"]["vcu_mrc"]}

    ${mr}  set variable if  "${netact_config_source}"=="netact_config_source_from_init_py"
           ...   ${netact["mr"]}      ${mr_info}${tl.gnbs[${gnb_index}].instance_id}

    ${integration_logs}    taf_netact.integrate_mrbts_with_netact
    ...  release=${release}
    ...  mr=${mr}
    ...  mrbts_address=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...  dist_name=PLMN-PLMN/${mrbts_name}
    ...  presentation_name=null
    ...  http_port=8080
    ...  https_port=8443
    ...  ip_version=${ip_version}
    ...  security_mode=${security_mode}
    ...  mrbts_em_address=None
    ...  alias=${alias}
    [Return]  ${alias}  ${integration_logs}
    [Teardown]   disconnect to netact node  alias=${alias}


_vDU MRBTS Integrate To NetAct
    [Arguments]  ${mrbts_name}  ${release}   ${gnb_index}=0  ${vdu_index}=0  ${alias}=default   ${ip_version}=IPv4
    ...  ${security_mode}=No TLS  ${netact_index}=clab3766
    [Documentation]   Integrate MRBTS With NetAct
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    modified by:        <13-Oct-2020>, <huilxu>, <Initial creation>
    ...    23.9.2021, honyuan.sun@nokia-sbell.com, add to support netact redundancy
    ...    23.10.2021,chris.l.cao@nokia-sbell.com, remove global variable NETACT_CONFIG_SOURCE, and support netact redundancy
    ...
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    | mrbts_name (string) | No | eg: MRBTS-1 |
    ...    | release (string) | SW release, e.g., SBTS18 or SBTS20C (case insensitive) |
    ...    | gnb_index  | No | default 0 |
    ...    | vdu_index  | No | default 0 |
    ...    | ip_version (string) | No | IP protocol version network element uses: ‘IPv4’ or ‘IPv6’ (case insensitive) |
    ...    | security_mode (string) | No | TLS (Transport Layer Security) supported: ‘TLS’ or ‘no TLS’ (case insensitive)|
    ...    | alias (string) | No |Netact instance name. Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    alias  integration_logs
    ...
    ...    Example
    ...    | Integrate To NetAct |
    ${alias}   ssh to netact node  netact_index=${netact_index}
    ${netact_config_source}  Get netact Config Type From TestLine

    Run Keyword If  "${netact_config_source}"=="netact_config_source_from_global_variable_py"   Get Target Netact Server
    ${mr_info}  Set Variable If  "${netact_config_source}"=="netact_config_source_from_global_variable_py"
          ...   ${TARGET_NETACT_INFO["mr"]["vdu_mrc"]}

    ${mr}  set variable if  "${netact_config_source}"=="netact_config_source_from_init_py"
           ...   ${netact["mr"]}      ${mr_info}${tl.gnbs[${gnb_index}].dus[${vdu_index}].instance_id}

#    ${mr}  set variable if  "${netact_config_source}"=="netact_config_source_from_init_py"
#    ...  ${netact["mr"]}  ${TARGET_NETACT_INFO["mr"]}
    ${integration_logs}    taf_netact.integrate_mrbts_with_netact
    ...  release=${release}
    ...  mr=${mr}
    ...  mrbts_address=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...  dist_name=PLMN-PLMN/${mrbts_name}
    ...  presentation_name=null
    ...  http_port=8080
    ...  https_port=8443
    ...  ip_version=${ip_version}
    ...  security_mode=${security_mode}
    ...  mrbts_em_address=None
    ...  alias=${alias}
    [Return]  ${alias}  ${integration_logs}
    [Teardown]   disconnect to netact node  alias=${alias}


_FHGW Integrate To NetAct
    [Arguments]  ${mrbts_name}  ${release}   ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0   ${alias}=default
    ...   ${ip_version}=IPv4  ${security_mode}=No TLS  ${netact_index}=clab3766
    [Documentation]   Integrate MRBTS With NetAct
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    modified by:        <13-Oct-2020>, <huilxu>, <Initial creation>
    ...    23.9.2021, honyuan.sun@nokia-sbell.com, add to support netact redundancy
    ...    23.10.2021,chris.l.cao@nokia-sbell.com, remove global variable NETACT_CONFIG_SOURCE, and support netact redundancy
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | mrbts_name (string) | No | eg: MRBTS-1 |
    ...    | release (string) | SW release, e.g., SBTS18 or SBTS20C (case insensitive) |
    ...    | NE_type  | Yes |   default is vCU , all value are vCU,vDU,FHGW|
    ...    | gnb_index  | No | default 0 |
    ...    | vdu_index  | No | default 0 |
    ...    | fhgw_index  | No | default 0 |
    ...    | ip_version (string) | No | IP protocol version network element uses: ‘IPv4’ or ‘IPv6’ (case insensitive) |
    ...    | security_mode (string) | No | TLS (Transport Layer Security) supported: ‘TLS’ or ‘no TLS’ (case insensitive)|
    ...    | alias (string) | No |Netact instance name. Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    alias  integration_logs
    ...
    ...    Example
    ...    | Integrate To NetAct |
    ${netact_config_source}  Get netact Config Type From TestLine

    ${fhgw_config}   Get FHGW Config   gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${fhgw_id}     Set Variable    ${fhgw_config["FHGW"]["fhgwId"]}

    Run Keyword If  "${netact_config_source}"=="netact_config_source_from_global_variable_py"   Get Target Netact Server
    ${mr_info}  Set Variable If  "${netact_config_source}"=="netact_config_source_from_global_variable_py"
          ...   ${TARGET_NETACT_INFO["mr"]["vcu_mrc"]}

    ${mr}  set variable if  "${netact_config_source}"=="netact_config_source_from_init_py"
           ...   ${netact["mr"]}      ${mr_info}${fhgw_id}

    ${dictionary_content}   yaml_file_to_dictionary    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].user_config_path}
    ${fhge_ip}    run keyword if   "${ip_version}"=="IPv4"
    ...  set variable   ${dictionary_content}[NETWORKING][EXTERNAL_NET][NET_DOMAINS][NET_MANAGEMENT][OAM][IPADDRESSV4][ipAddress]
    ...  ELSE IF  "${ip_version}"=="IPv6"
    ...  set variable   ${dictionary_content}[NETWORKING][EXTERNAL_NET][NET_DOMAINS][NET_MANAGEMENT][OAM][IPADDRESSV6][ipAddress]
    ${alias}   ssh to netact node  netact_index=${netact_index}
    ${mr}  set variable if  "${netact_config_source}"=="netact_config_source_from_init_py"
    ...  ${netact["mr"]}  ${TARGET_NETACT_INFO["mr"]}
    ${integration_logs}    taf_netact.integrate_mrbts_with_netact
    ...  release=${release}
    ...  mr=${mr}
    ...  mrbts_address=${fhge_ip}
    ...  dist_name=PLMN-PLMN/${mrbts_name}
    ...  presentation_name=null
    ...  http_port=8080
    ...  https_port=8443
    ...  ip_version=${ip_version}
    ...  security_mode=${security_mode}
    ...  mrbts_em_address=None
    ...  alias=${alias}
    [Return]  ${alias}  ${integration_logs}
    [Teardown]   disconnect to netact node  alias=${alias}

Deintegrate From NetAct
    [Arguments]   ${mrbts_name}
    [Documentation]   Deintegrate MRBTS From NetAct
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    | mrbts_name (string) | No | eg: MRBTS-1 |
    ...
    ...    *RETURN VALUE*
    ...    deintegration_logs
    ...
    ...    Example
    ...    | Deintegrate From NetAct |
    ${alias}   ssh to netact node
    ${deintegration_logs}    taf_netact.deintegrate_mrbts_from_netact
    ...  dist_name=PLMN-PLMN/${mrbts_name}
    ...  alias=${alias}
    [Return]   ${deintegration_logs}
    [Teardown]   disconnect to netact node  alias=${alias}

============= NE Integration Wizard End ============

============= taf.ul.oam.netact.cm start ============

Modify Parameter Via NetAct
    [Arguments]   ${para_list}  ${plan_name}=delta
    [Documentation]   To run the command log in to a virtual machine, where the was -<nodename> service is running
    ...    For more information, see locating the right virtual machine for a service administrating NetAct Virtual Infrastructure
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    | para_list (List(dic)) | Yes | eg: like below example |
    ...    | plan_name (string) | No | default is delta|
    ...
    ...    *RETURN VALUE*
    ...    provision status output
    ...
    ...    Example
    ...   | &{gNbCuName}    dist_name=MRBTS-${tl.gnbs[0].instance_id}    p_name=btsName  value=haha
    ...   | @{NRBTS_Para_list}   ${gNbCuName}
    ...   | Set netact from testline config file |
    ...   | Modify Parameter Via NetAct |
    ${dalta_plan_path}   get delta plan
    ${file_path}   ${filename}  split_path   ${dalta_plan_path}
    FOR    ${para}    IN    @{para_list}
        ${tmp_list}   get specified mo attributes   ${para}[dist_name]
        scf.load_scf   ${dalta_plan_path}
        scf.add_object_to_scf   class_name=${tmp_list[0]}   dist_name=${tmp_list[1]}    version=${tmp_list[2]}
        scf.add_element_to_scf  dist_name=${tmp_list[1]}   p_name=${para}[p_name]   value=${para}[value]
        scf.save_scf     ${dalta_plan_path}
    END
    modify_scf_for_netact   ${dalta_plan_path}   newscf.xml
    ${conn}   connect to netact node via netact_cm
    ${remove_status}  run keyword and ignore error  remove plan via netact_cm   plan_name=${plan_name}
    ${import_status}  import plan via netact_cm   path_to_file=/tmp/newscf.xml     planname=${plan_name}
    ${pro_status}   provision plan via netact_cm    plan_name=${plan_name}    create_backup=False
    [Return]    ${pro_status}
    [Teardown]  disconnect to netact node via netact_cm

get specified mo attributes
    [Arguments]     ${dn_name}
    ${current_plan_path}   CU Backup SCF
    scf.load_scf   ${current_plan_path}
    ${class_name}    scf.get_mo_attribute     dist_name=${dn_name}  attribute=class
    ${dist_name}    scf.get_mo_attribute     dist_name=${dn_name}    attribute=distName
    ${version}    scf.get_mo_attribute     dist_name=${dn_name}    attribute=version
    ${mo_att_list}    Create List   ${class_name}   ${dist_name}   ${version}
    scf.save_scf    ${current_plan_path}
    [Return]   ${mo_att_list}

get delta plan
    [Arguments]   ${gnb_index}=0
    ${current_plan_path}   CU Backup SCF
    scf.load_scf   ${current_plan_path}
    scf.remove_mo_with_descendant_mos    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}
    scf.save_scf   /tmp/tmp.xml
    ${tmp_path}   set variable   /tmp/tmp.xml
    [Return]   ${tmp_path}

connect to netact node via netact_cm
     [Arguments]
    [Documentation]   To run the command log in to a virtual machine, where the was -<nodename> service is running
    ...    For more information, see locating the right virtual machine for a service administrating NetAct Virtual Infrastructure
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...   ssh session
    ...
    ...    Example
    ...     | Set netact from testline config file |
    ...    | connect to netact node via netact_cm |
    ${conn}   netact_cm.connect_to
    ...   hostname=${netact['node_ip']}
    ...   username=${netact['user']}
    ...   password=${netact['password']}
    [Return]  ${conn}

disconnect to netact node via netact_cm
    [Arguments]
    [Documentation]  Close current connection.
    ...
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | connect to netact node via netact_cm |
    ...    | disconnect to netact node via netact_cm |
    netact_cm.disconnect


get export plan via netact_cm
     [Arguments]    ${dist_name}     ${ui_values}=True
    [Documentation]   Export Actual Configuration in NetAct for specified MO and save configuration on local machine
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | dist_name (str) – MO distinguish name e.g MRBTS-329, MRBTS-345/NRBTS-5
    ...    | ui_values (bool) – specifies if the file using UI values with parameters is imported or exported. true(default)
    ...
    ...    *RETURN VALUE*
    ...    path to exported file on local machine : /tmp/NetactCM/NetactMRBTS-5214_exported_file.xml
    ...
    ...    Example
    ...     | Set netact from testline config file |
    ...     | connect to netact node via netact_cm |
    ...     | get export plan via netact_cm |
    ...     | disconnect to netact node via netact_cm |
    netact_cm.export_plan
    ...   dist_name=${dist_name}
    ...   ui_values=${ui_values}
    @{dist_name_list}    Split String   ${dist_name}   /
    ${scf_path}  set variable   /tmp/NetactCM/Netact${dist_name_list[0]}_exported_file.xml
    [Return]  ${scf_path}


import plan via netact_cm
     [Arguments]    ${path_to_file}     ${planname}   ${ui_values}=True   ${objectoperationdefinedinimport}=False
    [Documentation]   import plan given as path_to_file as NetAct plan name, plan is stored to NetAct import directory.
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    | path_to_file (str) | Yes | path to plan file |
    ...    | planname (str)  | Yes | specifies a name of plan
    ...    | ui_values (str) | specifies if the file using UI values with parameters is imported or exported. false (default)
    ...    | objectoperationdefinedinimport (str) | if true and operation is missing from import file, object is not
    ...      imported. If false, object operation is set based on object existence in NetAct database. default value : false
    ...
    ...    *RETURN VALUE*
    ...    	state of operation
    ...
    ...    Example
    ...     | Set netact from testline config file |
    ...     | connect to netact node via netact_cm |
    ...     |  ${status} |  import plan via netact_cm |
    ...     | disconnect to netact node via netact_cm |
    ${status}    netact_cm.import_plan
    ...   path_to_file=${path_to_file}
    ...   planname=${planname}
    ...   ui_values=${ui_values}
    ...   objectoperationdefinedinimport=${objectoperationdefinedinimport}
    [Return]  ${status}


provision plan via netact_cm
     [Arguments]    ${plan_name}   ${provisioning_operation}=activate  ${create_backup}=True
    [Documentation]   provision plan to the network.
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...     dist_name (str) – MO distinguish name e.g MRBTS-329, MRBTS-345/NRBTS-5
    ...    ui_values (bool) – specifies if the file using UI values with parameters is imported or exported. true(default)
    ...    *RETURN VALUE*
    ...    state of provision operation
    ...
    ...    Example
    ...     | Set netact from testline config file |
    ...     | connect to netact node via netact_cm |
    ...     |  ${status} |  provision plan via netact_cm |
    ...     | disconnect to netact node via netact_cm |
    ${status}    netact_cm.provision
    ...   plan_name=${plan_name}
    ...   provisioning_operation=${provisioning_operation}
    ...   create_backup=${create_backup}
    [Return]  ${status}

remove plan via netact_cm
     [Arguments]    ${plan_name}
    [Documentation]   delete plan from Configurator Database.
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | plan_name (str) |Yes | specifies a plan name |
    ...
    ...    *RETURN VALUE*
    ...    	state of operation
    ...
    ...    Example
    ...     | Set netact from testline config file |
    ...     | connect to netact node via netact_cm |
    ...     | get export plan via netact_cm |
    ${status}   netact_cm.remove_plan
    ...   plan_name=${plan_name}
    [Return]  ${status}


upload plan via netact_cm
     [Arguments]    ${bts_dist_name}     ${backup}=False
    [Documentation]     Export Actual Configuration in NetAct for specified MO and save configuration on local machine
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    | bts_dist_name (str) | Yes | MRBTS ID e.g MRBTS-329 |
    ...    | backup (bool) | backup existing configuration file in NetAct False (by default) |
    ...
    ...    *RETURN VALUE*
    ...    	state of upload operation
    ...
    ...    Example
    ...     | Set netact from testline config file |
    ...     | connect to netact node via netact_cm |
    ...     | upload plan via netact_cm |
    ${status}    netact_cm.upload_plan
    ...   bts_dist_name=${bts_dist_name}
    ...   backup=${backup}
    [Return]  ${status}

validate plan via netact_cm
     [Arguments]    ${dist_name}     ${plan_name}
    [Documentation]   validate the plan in Netact.
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    | dist_name (str) | Yes | MRBTS_ID e.g MRBTS-329
    ...    | plan_name (str) | Yes | specifies a plan name
    ...
    ...    *RETURN VALUE*
    ...    	state of validation operation
    ...
    ...    Example
    ...     | Set netact from testline config file |
    ...     | connect to netact node via netact_cm |
    ...     | validate plan via netact_cm |
    ${status}   netact_cm.export_plan
    ...   dist_name=${dist_name}
    ...   plan_name=${plan_name}
    [Return]  ${status}

Import And Provision Delta Plan via Netact
    [Arguments]    ${dalta_plan_path}   ${new_delta_file_name}=newscf.xml    ${plan_name}=delta
    [Tags]  NETACT_CM
    [Documentation]  import and provision delta plan to the network.
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | dalta_plan_path  | Yes |  full path of the plan file
    ...
    ...    *RETURN VALUE*
    ...    state of provision operation
    ...
    ...    Example
    ...    | ${mrbts_name_vdu} | ${logs} | Integrate NE To Netact |  ne_type=vDU |
    ...    | Login Netact Via Web Url |
    ...    | ${status} |  Provision Delta Plan via Netact | dalta_plan_path=/tmp/myscf.xml |
    ...    | Deintegrate From NetAct  | mrbts_name=${mrbts_name_vdu} |
    ...

    modify_scf_for_netact   ${dalta_plan_path}   ${new_delta_file_name}
    ${conn}   connect to netact node via netact_cm
    ${file_path}    ${file_name}    Split Path    ${dalta_plan_path}
    ${remove_status}  run keyword and ignore error  remove plan via netact_cm   plan_name=${plan_name}
    ${import_status}  import plan via netact_cm   path_to_file=${file_path}/${new_delta_file_name}     planname=${plan_name}
    ${pro_status}   provision plan via netact_cm    plan_name=${plan_name}    create_backup=False
    [Return]    ${pro_status}
    [Teardown]  disconnect to netact node via netact_cm
============= taf.ul.oam.netact.cm end ============