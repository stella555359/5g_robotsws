*** Settings ***
Documentation
...  author: luofei.tu@nokia-sbell.com
...   contact: luofei.tu@nokia-sbell.com
...   Description:This robot is mainly for putting the CB007467 common keywords



*** Variables ***



*** Keywords ***
Get Mrbts Name via NE Type
    [Arguments]  ${NE_type}=vCU  ${gnb_index}=0   ${vdu_index}=0  ${fhgw_index}=0
    [Documentation]   Get Mrbts Name via NE Type, please config instance id and fhgw id in your __init__ file
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   22.11.2021,chris.l.cao@nokia-sbell.com, change to get fhgw_id from fhgw_user_config_0.yaml,because this yaml file exists in every testline
    ...   20.1.2022,chris.l.cao@nokia-sbell.com, change method of getting vdu mrbts id from ${tl.xxx} to VDU SCF file
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
    ...    | ${mrbts_name} | Get Mrbts Name via NE Type | NE_type=vCU |
    ...    | ${mrbts_name} | Get Mrbts Name via NE Type | NE_type=VDU |
    ...    | ${mrbts_name} | Get Mrbts Name via NE Type | NE_type=FHGW |
    ...
    ${NE_type}  Get Upper Case Ne Name  ne_type=${NE_type}

    ${fhgw_config}  Run Keyword If  "${NE_type}"=="FHGW"
       ...   Get FHGW Config   gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${fhgw_id}     Set Variable If   "${NE_type}"=="FHGW"   ${fhgw_config["FHGW"]["fhgwId"]}

    ${mrbts_id_vdu}  Run Keyword If   "${NE_type}"=="VDU"   Get MRBTS Id From vDU SCF

    ${mrbts_name}    run keyword if  "${NE_type}"=="VCU"   set variable   MRBTS-${tl.gnbs[${gnb_index}].instance_id}
    ...   ELSE IF  "${NE_type}"=="VDU"   set variable    MRBTS-${mrbts_id_vdu}
    ...   ELSE IF  "${NE_type}"=="FHGW"   set variable   FHGW-${fhgw_id}
    ...   ELSE     Fail    Unknown NE_type:${NE_type}!
    [Return]   ${mrbts_name}


Set netact from testline config file
#    [Arguments]   ${netact_index}=clab3766
    [Arguments]   ${netact_index}=${EMPTY}
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
#    ${netact_info_from}   Get netact Config Type From TestLine
#    ${NETACT}   Run Keyword If   '${netact_info_from}'=='netact_config_source_from_global_variable_py'
#    ...  _Get netact info from global variables py   ${netact_index}
#    ...  ELSE   _Get netact info from init py   ${netact_index}
#    Set Suite Variable   ${netact}
    Return From Keyword If  "${netact_index}"=="${EMPTY}"

    ${netact_info_from}   Get netact Config Type From TestLine
    ${TARGET_NETACT_INFO}   Run Keyword If   '${netact_info_from}'=='netact_config_source_from_global_variable_py'
    ...  _Get netact info from global variables py   ${netact_index}
    ...  ELSE   _Get netact info from init py   ${netact_index}
    Set Test Variable   ${TARGET_NETACT_INFO}

    #${TARGET_NETACT_INDEX} will never be used, marked by chris.l.cao@nokia-sbell.com
    ${TARGET_NETACT_INDEX}   Set Variable   -1
    Set Test Variable   ${TARGET_NETACT_INDEX}


_Get netact info from init py
    [Arguments]     ${netact_index}
    ${netact_idinfo}   set variable   ${tl.nms.addr}
    ${actual_netact}   set variable   ${netact_idinfo}[${netact_index}]
    [Return]   ${actual_netact}


_Get netact info from global variables py
    [Arguments]   ${netact_index}
    ${all_netact_info}   get_all_netact_server
    FOR   ${netact_info}  IN   @{all_netact_info}
          Exit For Loop If   '${netact_info}[netact_id]'=='${netact_index}'
    END
    [Return]   ${netact_info}


ssh to netact node
    [Arguments]    ${service_name}=cmwas   ${alias}=default  ${netact_index}=${EMPTY}
    [Documentation]   Create an instance of SshNode class, establishes temporary ssh connection as first verification
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    modified by:        <13-Oct-2020>, <huilxu>, <Initial creation>
    ...    23.9.2021, hongyuan.sun@nokia-sbell.com, add to support netact redundancy
    ...    23.10.2021,chris.l.cao@nokia-sbell.com, remove global variable NETACT_CONFIG_SOURCE
    ...    18.1.2022, hongyuan.sun@nokia-sbell.com, modify some parameter
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | service_name  | No | default is cmwas,Supported services:‘cmwas’,‘fmwas’,‘itsmwas’,‘nwi3’,‘cls-services’,
    ...                         ‘cls-db’ |
    ...    | alias        | No | Netact instance name. Default value is ‘default’ |
    ...    | netact_index | No | select netact info in init.py |
    ...
    ...    *RETURN VALUE*
    ...    ssh to netact node alias
    ...
    ...    Example
    ...    | ${alias} | ssh to netact node |

    ${netact_config_source}  Get netact Config Type From TestLine
    ${alias}   Run Keyword If   "${netact_config_source}"=="netact_config_source_from_init_py"
    ...   _ssh to netact node Info From init.py    service_name=${service_name}   alias=${alias}
    ...   ELSE   _ssh to netact node Info From global_variable.py   service_name=${service_name}   alias=${alias}

    [Return]  ${alias}


_ssh to netact node Info From init.py
#    [Arguments]    ${service_name}=cmwas   ${alias}=default  ${netact_index}=clab3766
    [Arguments]    ${service_name}=cmwas   ${alias}=default  ${netact_index}=${EMPTY}
    [Documentation]    _ssh to netact node Info From init.py
    ...    *AUTHOR* hongyuan.sun@nokia-sbell.com
    ...    history change:
    ...   2.2.2023,chris.l.cao@nokia-sbell.com, change ${netact} to ${TARGET_NETACT_INFO}
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | netact_index | yes | netact index for select netact info |
    ...
    ...    *RETURN VALUE*
    ...    Client id
    ...
    ...    Example
    ...    |  ${alias}  |  _ssh to netact node Info From init.py  |

#    Set netact from testline config file   netact_index=${netact_index}
    taf_netact.add_node
    ...   service_name=${service_name}
    ...   hostname=${TARGET_NETACT_INFO["node_ip"]}
    ...   username=${TARGET_NETACT_INFO["user"]}
    ...   password=${TARGET_NETACT_INFO["password"]}
    ...   alias=${alias}
    [Return]   ${alias}


_ssh to netact node Info From global_variable.py
    [Arguments]    ${service_name}=cmwas   ${alias}=default
    [Documentation]    _netact ssh With netact Info From global_variable.py
    ...    *AUTHOR* hongyuan.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	  None
    ...
    ...    *RETURN VALUE*
    ...    Client id
    ...    Example
    ...    | ${alias}  |  _ssh to netact node Info From global_variable.py   |

    ${TARGET_NETACT_INDEX}  ${TARGET_NETACT_INFO}  Get Target netact server  service_name=${service_name}  alias=${alias}
    ${alias}   _ssh to netact Via Target Netact Info    netact_info=${TARGET_NETACT_INFO}   service_name=${service_name}
    ...  alias=${alias}
    [Return]   ${alias}

Get Target Netact Server
    [Arguments]   ${service_name}=cmwas   ${alias}=default
    [Documentation]   Get the Target netact server.
    ...               Get the Target netact ip username password and link info
    ...    *AUTHOR* hongyuan.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    netact server info
    ...    Example
    ...    |  |    |
#    ${r}  ${dummy}   run keyword and ignore error   set variable   ${TARGET_NETACT_INDEX}
    ${r}  ${dummy}   run keyword and ignore error   set variable   ${TARGET_NETACT_INFO}
    return from keyword if  "${r}"=="PASS"    ${TARGET_NETACT_INDEX}    ${TARGET_NETACT_INFO}

    ${TARGET_NETACT_INDEX}    ${TARGET_NETACT_INFO}    _Get Target netact Server Index   service_name=${service_name}  alias=${alias}
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
    ...    ssh to netact alias
    ...    Example
    ...    |  |    |
    ${hostname}   Set Variable  ${netact_info["node_ip"]}
    ${username}    Set Variable  ${netact_info["user"]}
    ${password}   Set Variable  ${netact_info["password"]}

    Run Keyword And Ignore Error   taf_netact.delete_node
    ...   service_name=${service_name}
    ...   alias=${alias}

    Sleep  3

    Wait Until Keyword Succeeds  3x  5   taf_netact.add_node
    ...   service_name=${service_name}
    ...   hostname=${hostname}
    ...   username=${username}
    ...   password=${password}
    ...   alias=${alias}
    [Return]   ${alias}

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

Login Netact Via Web Url
     [Arguments]     ${alias}=default
    [Documentation]   Add Netact web user interface data.
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...     modified by:
    ...    history change: <date>,<who>,<what and how>
    ...   2.2.2023,chris.l.cao@nokia-sbell.com, change ${netact} to ${TARGET_NETACT_INFO}

    ...    |  Input Parameters | Man. | Description |
    ...    | alias   | No | Netact instance name. Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    alias
    ...
    ...    Example
    ...    | login netact via web url |

    taf_netact.add_web_url
    ...   web_url=${TARGET_NETACT_INFO['url']}
    ...   username=${TARGET_NETACT_INFO['url_user']}
    ...   password=${TARGET_NETACT_INFO['url_password']}
    ...   alias=default
    [Return]  ${alias}


============= CM Editor Start ============
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


Get Actual Configuration MO Data From NetAct
    [Arguments]    ${mo_id}   ${alias}=default
    [Documentation]   Get Actual Configuration MO Data From NetAct
    ...    *AUTHOR* hongyuan.sun@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | mo_id (string) | Yes | eg: PLMN-PLMN/MRBTS-11111/EQM_R-1 |
    ...    | alias (string) | No  | Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    MO Data include meta_class, meta_version and parameters
    ...
    ...    Example
    ...    | ${alias}  | login netact via web url | alias=default |
    ...    | ${meta_class} | ${meta_version} | ${parameters} | Get Actual Configuration MO Data From NetAct |
    ...    mo_id=PLMN-PLMN/MRBTS-11111/EQM_R-1 | alias=${alias} |

    ${actual_conf}    taf_netact.get_actual_configuration   alias=${alias}
    ${managed_object}    taf_netact.get_managed_object    configuration=${actual_conf}
    ...                                        mo_id=${mo_id}
    ...                                        alias=${alias}
    [Return]    ${managed_object.meta_class}     ${managed_object.meta_version}    ${managed_object.parameters}

============= CM Operations Manager End ============

============= Monitor FM Start ============


============= Monitor FM End ============

============= NE Integration Wizard Start ============


Integrate NE To Netact
   [Arguments]   ${ne_type}=vCU   ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0  ${alias}=default   ${security_mode}=No TLS
   ...   ${netact_index}=${EMPTY}  ${mo_release}=${EMPTY}
   [Documentation]    Integrate ne to Netact by ne type, ne index and which nom will be integrated to.
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...     modified by:        <11-03-2021>, <hongysun>, <modify>
    ...    history change: <date>,<who>,<what and how>
    ...   22.1.2022,chris.l.cao@nokia-sbell.com, use 'Get Upper Case Ne Name' to convert any ne_type to upper case.
    ...   3.2.2023,chris.l.cao@nokia-sbell.com, add samples after implement auto-select and non-auto-select netact server
    ...   18.6.2023,chris.l.cao@nokia-sbell.com, add 'NMS Port Should Listen In NE Side'
    ...
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
    ...   | Integrate NE To Netact  | ne_type=vDU |
    ...   | Deintegrate From NetAct | ne_type=vDU |
    ...   | Integrate NE To Netact  | ne_type=vCU | security_mode=TLS |
    ...   | Deintegrate From NetAct | ne_type=vCU |
    ...   | Integrate NE To Netact  | ne_type=fhgw |
    ...   | Deintegrate From NetAct | ne_type=fhgw |
    ...
    ...    Integration VDU to Netact and provision delta plan
    ...    | Integrate NE To Netact |  ne_type=vDU |
    ...    | Login Netact Via Web Url |
    ...    | ${status} |  Provision Delta Plan via Netact | dalta_plan_path=/tmp/myscf.xml |
    ...    | Deintegrate From NetAct  | ne_type=vDU |
    ...
    ...    | ${mrbts_name_vcu} | ${logs} | Integrate NE To Netact |  ne_type=vCU  |
    ...    | ${mrbts_name_vdu} | ${logs} | Integrate NE To Netact |  ne_type=vDU  | security_mode=TLS |
    ...    | ${mrbts_name_fhgw} | ${logs} | Integrate NE To Netact | ne_type=fhgw  |
    ...    | Deintegrate From NetAct  | mrbts_name=${mrbts_name_vcu} |
    ...    | Deintegrate From NetAct  | mrbts_name=${mrbts_name_vdu} |
    ...    | Deintegrate From NetAct  | mrbts_name=${mrbts_name_fghw} |
    ...
    ...    Example for auto-select avaliable Netact server:
    ...    | Integrate NE To Netact   ne_type=vDU
    ...    | ${mrbts_id}             | Get MRBTS Id From vDU SCF |
    ...    | ${bts_name_change_dict} | create dictionary | dist_name=MRBTS-${mrbts_id} | p_name=btsName | value=mybtsname |
    ...    | ${para_list}            | create list |  ${bts_name_change_dict} |
    ...    | Modify Parameter Via NetAct | para_list=${para_list}  | ne_type=VDU |
    ...    | Deintegrate From NetAct     | ne_type=vDU |
    ...
    ...    Example for giving a Netact server named clab33:
    ...    | Set Netact From Testline Config File | clab33 |
    ...    | Integrate NE To Netact  | ne_type=vDU |
    ...    | ${mrbts_id}             | Get MRBTS Id From vDU SCF |
    ...    | ${bts_name_change_dict} | create dictionary | dist_name=MRBTS-${mrbts_id} | p_name=btsName | value=mybtsname |
    ...    | ${para_list}            | create list |  ${bts_name_change_dict} |
    ...    | Modify Parameter Via NetAct | para_list=${para_list}  | ne_type=VDU |
    ...    | Deintegrate From NetAct     | ne_type=vDU |
    ...
    vCU vDU FHGW ID Should Be Unified For NMS Integration
    ${mrbts_name}    Get Mrbts Name via NE Type  NE_type=${ne_type}    gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${ne_type}  Get Upper Case Ne Name  ne_type=${ne_type}

    NMS Port Should Listen In NE Side  ne_type=${ne_type}   security_mode=${security_mode}
       ...   gnb_index=${gnb_index}    vdu_index=${vdu_index}   fhgw_index=${fhgw_index}

    ${ip_v6}   Check if OAM is IPv6    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${ip_version}   set variable if   "${ip_v6}"=="True"   IPv6   IPv4

#    ${release}   Get NE Release Version For Netact    ne_type=${ne_type}  gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${release}  Run Keyword If  "${ne_type}"=="VCU" or "${ne_type}"=="VDU"   Get Netact MO Release   ne_type=${ne_type}
    ...  ELSE IF  "${ne_type}"=="FHGW"   Set Variable  FHGW23R2
    ...  ELSE   Set Variable   UNKNOWN_NE_TYPE

    ${release}  Set Variable If  "${mo_release}"=="${EMPTY}"  ${release}
    ...   ${mo_release}
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


Get Netact MO Release
    [Arguments]  ${ne_type}
    [Documentation]  Get Netact MO Release VDU
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ne_type | Yes | VCU or VDU |
    ...
    ...    *RETURN VALUE*
    ...    package_prefix
    ...
    ...    Example
    ...    | ${netact_mo_release} | Get Netact MO Release VDU | ne_type=VDU |
    ...    | ${netact_mo_release} | Get Netact MO Release VDU | ne_type=VCU |
    ...
    ${build_number}   Run Keyword If  "${ne_type}"=="VDU"   Get Running Build Number
    ...   ELSE   Get Running vCU Build Number

	${stream}   Evaluate  ".".join("${build_number}".split(".")[:2])
	${r}   ${mo_release}    Run Keyword And Ignore Error  set variable   ${NETACT_MO_RELEASE}[${stream}]
	Return From Keyword If   "${r}"=="PASS"   ${mo_release}
	${mo_release}  Set Variable If  "${ne_type}"=="VDU"   ${NETACT_MO_RELEASE["0.300"]}    ${NETACT_MO_RELEASE["0.250"]}
	[Return]  ${mo_release}


_vCU MRBTS Integrate To NetAct
    [Arguments]  ${mrbts_name}  ${release}   ${gnb_index}=0   ${alias}=default   ${ip_version}=IPv4  ${security_mode}=No TLS
    ...  ${netact_index}=${EMPTY}
    [Teardown]   Disconnect To Netact Node  alias=${alias}
    [Documentation]   Integrate vCU MRBTS With NetAct
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    modified by:        <13-Oct-2020>, <huilxu>, <Initial creation>
    ...    23.9.2021, honyuan.sun@nokia-sbell.com, add to support netact redundancy
    ...    23.10.2021,chris.l.cao@nokia-sbell.com, remove global variable NETACT_CONFIG_SOURCE, and support netact redundancy
    ...    3.2.2023,chris.l.cao@nokia-sbell.com, remove parameter netact_index to unify netact server auto-selection and using specific one
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
#    ${alias}   ssh to netact node   netact_index=${netact_index}
    ${alias}   ssh to netact node
    ${netact_config_source}  Get netact Config Type From TestLine

    Run Keyword If  "${netact_config_source}"=="netact_config_source_from_global_variable_py"   Get Target Netact Server
    ${mr_info}  Set Variable If  "${netact_config_source}"=="netact_config_source_from_global_variable_py"
          ...   ${TARGET_NETACT_INFO["mr"]["vcu_mrc"]}

#    ${mr}  set variable if  "${netact_config_source}"=="netact_config_source_from_init_py"
#           ...   ${netact["mr"]}      ${mr_info}${tl.gnbs[${gnb_index}].instance_id}
    ${mr}  set variable if  "${netact_config_source}"=="netact_config_source_from_init_py"
           ...   ${TARGET_NETACT_INFO["mr"]}      ${mr_info}${tl.gnbs[${gnb_index}].instance_id}

    ${integration_logs}    taf_netact.integrate_mrbts_with_netact
    ...  release=${release}
    ...  mr=${mr}
    ...  mrbts_address=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...  dist_name=PLMN-PLMN/${mrbts_name}
    ...  http_port=8080
    ...  https_port=8443
    ...  ip_version=${ip_version}
    ...  security_mode=${security_mode}
    ...  mrbts_em_address=${None}
    ...  alias=${alias}
    Sleep  10
    [Return]  ${alias}  ${integration_logs}


_vDU MRBTS Integrate To NetAct
    [Arguments]  ${mrbts_name}  ${release}   ${gnb_index}=0  ${vdu_index}=0  ${alias}=default   ${ip_version}=IPv4
    ...  ${security_mode}=No TLS  ${netact_index}=${EMPTY}
    [Teardown]   Disconnect To Netact Node  alias=${alias}
    [Documentation]   Integrate MRBTS With NetAct
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    modified by:        <13-Oct-2020>, <huilxu>, <Initial creation>
    ...    23.9.2021, honyuan.sun@nokia-sbell.com, add to support netact redundancy
    ...    23.10.2021,chris.l.cao@nokia-sbell.com, remove global variable NETACT_CONFIG_SOURCE, and support netact redundancy
    ...    3.2.2023,chris.l.cao@nokia-sbell.com, remove parameter netact_index to unify netact server auto-selection and using specific one
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
    ${alias}   ssh to netact node
    ${netact_config_source}  Get netact Config Type From TestLine

    Run Keyword If  "${netact_config_source}"=="netact_config_source_from_global_variable_py"   Get Target Netact Server
    ${mr_info}  Set Variable If  "${netact_config_source}"=="netact_config_source_from_global_variable_py"
          ...   ${TARGET_NETACT_INFO["mr"]["vdu_mrc"]}

    ${mrbts_id_vdu}   Set Variable   ${mrbts_name.split("-")[1]}
    ${mr}  set variable if  "${netact_config_source}"=="netact_config_source_from_init_py"
           ...   ${TARGET_NETACT_INFO["mr"]}      ${mr_info}${mrbts_id_vdu}

    ${integration_logs}    taf_netact.integrate_mrbts_with_netact
    ...  release=${release}
    ...  mr=${mr}
    ...  mrbts_address=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...  dist_name=PLMN-PLMN/${mrbts_name}
    ...  http_port=8080
    ...  https_port=8443
    ...  ip_version=${ip_version}
    ...  security_mode=${security_mode}
    ...  mrbts_em_address=None
    ...  alias=${alias}

    Sleep  10
    [Return]  ${alias}  ${integration_logs}


_FHGW Integrate To NetAct
    [Arguments]  ${mrbts_name}  ${release}   ${gnb_index}=0  ${vdu_index}=0  ${fhgw_index}=0   ${alias}=default
    ...   ${ip_version}=IPv4  ${security_mode}=No TLS  ${netact_index}=${EMPTY}
    [Documentation]   Integrate MRBTS With NetAct
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    modified by:        <13-Oct-2020>, <huilxu>, <Initial creation>
    ...    23.9.2021, honyuan.sun@nokia-sbell.com, add to support netact redundancy
    ...    23.10.2021,chris.l.cao@nokia-sbell.com, remove global variable NETACT_CONFIG_SOURCE, and support netact redundancy
   ...    3.2.2023,chris.l.cao@nokia-sbell.com, remove parameter netact_index to unify netact server auto-selection and using specific one
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
    ${netact_config_source}  Get netact Config Type From TestLine

    ${fhgw_config}   Get FHGW Config   gnb_index=${gnb_index}  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${fhgw_id}     Set Variable    ${fhgw_config["FHGW"]["fhgwId"]}

    Run Keyword If  "${netact_config_source}"=="netact_config_source_from_global_variable_py"   Get Target Netact Server
    ${mr_info}  Set Variable If  "${netact_config_source}"=="netact_config_source_from_global_variable_py"
          ...   ${TARGET_NETACT_INFO["mr"]["fhgw_mrc"]}

    ${dictionary_content}   yaml_file_to_dictionary    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].user_config_path}
    ${fhge_ip}    run keyword if   "${ip_version}"=="IPv4"
    ...  set variable   ${dictionary_content}[NETWORKING][EXTERNAL_NET][NET_DOMAINS][NET_MANAGEMENT][OAM][IPADDRESSV4][ipAddress]
    ...  ELSE IF  "${ip_version}"=="IPv6"
    ...  set variable   ${dictionary_content}[NETWORKING][EXTERNAL_NET][NET_DOMAINS][NET_MANAGEMENT][OAM][IPADDRESSV6][ipAddress]

    ${alias}   ssh to netact node

    ${mr}  set variable if  "${netact_config_source}"=="netact_config_source_from_init_py"
           ...   ${TARGET_NETACT_INFO["mr"]}      ${mr_info}${fhgw_id}

    ${integration_logs}    taf_netact.integrate_fhgw_with_netact
    ...  release=${release}
    ...  mr=${mr}
    ...  fhgw_address=${fhge_ip}
    ...  dist_name=PLMN-PLMN/${mrbts_name}
    ...  presentation_name=null
    ...  http_port=8080
    ...  https_port=8443
    ...  ip_version=${ip_version}
    ...  security_mode=${security_mode}
    ...  alias=${alias}
    [Return]  ${alias}  ${integration_logs}
    [Teardown]   disconnect to netact node  alias=${alias}


Deintegrate From NetAct
    [Arguments]   ${mrbts_name}=${EMPTY}  ${ne_type}=${EMPTY}  ${gnb_index}=0   ${vdu_index}=0    ${fhgw_index}=0
    [Teardown]   Disconnect To Netact Node  alias=${alias}
    [Documentation]   Deintegrate MRBTS From NetAct
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   27.9.2021,luofei.tuo@nokia-sbell.com, initializion
    ...   17.12.2021,chris.l.cao@nokia-sbell.com, add parameter ne_type
    ...   20.1.2022,chris.l.cao@nokia-sbell.com, add 'sleep  10' to solve integration unstable problem
    ...   3.3.2023,chris.l.cao@nokia-sbell.com, add taf_netact.Clean All
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    |  mrbts_name  |  No  |  mrbts_name  |
    ...    |  ne_type  |  No  |  Which type of ne will be integrated, can be cu/vdu/fhgw, vcu in default   |
    ...    |  gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    |  vdu_index  |  No  |  vdu index under specified cu   |
    ...    |  fhgw_index  |  No  |  fhgw index under specified vdu   |
    ...
    ...    *RETURN VALUE*
    ...    deintegration_logs
    ...
    ...    Example
    ...   | Integrate NE To Netact  | ne_type=vDU |
    ...   | Deintegrate From NetAct | ne_type=vDU |
    ...
    ${mrbts_name}  Run Keyword If  "${ne_type}"!="${EMPTY}"
      ...   Get Mrbts Name via NE Type   NE_type=${ne_type}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
      ...   ELSE  Set Variable   ${mrbts_name}

    ${alias}   ssh to netact node
    ${deintegration_logs}    taf_netact.deintegrate_mrbts_from_netact
    ...  dist_name=PLMN-PLMN/${mrbts_name}
    ...  alias=${alias}

    Sleep  2
    Run Keyword And Ignore Error  taf_netact.Clean All

    sleep  5
    [Return]   ${deintegration_logs}


_Get vDU/vCU Release Version For Netact
    [Arguments]  ${ne_type}   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get vDU/vCU Release Version Via Rest for Netact Integration
   ...    *Author:* lingting.sun@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | waht or how |
    ...    | 2022-5-25 | lingtsun | init create |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | int, gnb index. |
    ...    | vdu_index | No | int, vdu index. |
    ...    *Example*
    ...    | Get vDU/vCU Release Version For Netact | vDU | gnb_index=0 | vdu_index=0 |
    ...    | Get vDU/vCU Release Version For Netact | vCU | gnb_index=0 |
    ...    *Return*
    ...    - string, vdu/vcu release for netact, such as 22R3VDU or 22R4VCU
    ${state_data}=    run keyword if  "${ne_type}" == "VDU"
    ...   _Get VdU State Data  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ...   ELSE IF  "${ne_type}" == "VCU"    _Get vCU State Data   gnb_index=${gnb_index}
    ${ne_type_tmp}   Set Variable If   "${ne_type}"=="VDU"  vDU   vCU
    ${pattern}   Catenate   SEPARATOR=   ${ne_type_tmp}   [A-Za-z0-9]+
    ${vdu_release_info}=    Get Regexp Matches   ${state_data["software_version"]}   ${pattern}
    Should Not Be Empty    ${vdu_release_info}   msg=Failed to match the release version via regexp: ${pattern}
    ${vdu_release_for_netact}   strip string   string=${vdu_release_info[0]}   mode=left   characters=${ne_type_tmp}CNF
    ${ne_type}  Set Variable  ${ne_type.upper()}
    [return]   ${vdu_release_for_netact}${ne_type}


============= NE Integration Wizard End ============

============= taf.ul.oam.netact.cm start ============


_Generate Plan With Modify Parameter
    [Arguments]    ${para_list}    ${dalta_plan_path}    ${ne_type}
    FOR    ${para}    IN    @{para_list}
        ${tmp_list}   get specified mo attributes   ${para}[dist_name]    ne_type=${ne_type}
        scf.load_scf   ${dalta_plan_path}
        ${r}   ${operation}   Run Keyword And Ignore Error  Get From Dictionary   ${para}   operation
        ${operation}   Set Variable If   '${r}'=='FAIL'  update   ${operation}
        scf.add_object_to_scf   class_name=${tmp_list[0]}   dist_name=${tmp_list[1]}    version=${tmp_list[2]}   operation=${operation}
        scf.add_element_to_scf  dist_name=${tmp_list[1]}   p_name=${para}[p_name]   value=${para}[value]
        scf.save_scf     ${dalta_plan_path}
    END


_Generate Plan With Add Parameter
    [Arguments]    ${para_list}    ${dalta_plan_path}    ${ne_type}
    ${current_plan_path}    Run Keyword If   '${ne_type}'=='vcu'  CU Backup SCF
    ...   ELSE IF   '${ne_type}'=='vdu'   Get VDU SCF From Current Plan
    ...   ELSE   Fail    ne_type error,must be cu or vdu
    generate_plan_when_add_mo   ${para_list}   ${dalta_plan_path}   ${current_plan_path}


Modify Parameter Via NetAct
    [Arguments]   ${para_list}  ${plan_name}=${EMPTY}    ${ne_type}=cu
    [Teardown]  Disconnect To Netact Node Via Netact_cm
    [Documentation]   To run the command log in to a virtual machine, where the was -<nodename> service is running
    ...    For more information, see locating the right virtual machine for a service administrating NetAct Virtual Infrastructure
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   15.1.2022, rui.3.li@nokia-sbell.com, support cu
    ...   20.1.2022,chris.l.cao@nokia-sbell.com, use `Get A File` to get new delta plan file
    ...   4.11.2022,chris.l.cao@nokia-sbell.com, change netact plan name to MRBTS-xxxx-netact_delta_plan_xxxxxxx
    ...   3.2.2023,chris.l.cao@nokia-sbell.com, add script samples after implementation of auto-select and non-auto-select netact server
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | para_list | Yes | eg: like below example |
    ...    | plan_name | No | default is ${EMPTY}, if ${EMPYT}, plan_name will be generated automatically |
    ...    | ne_type   | No | default is cu, only support cu and vdu, will error with another value |
    ...
    ...    *RETURN VALUE*
    ...    provision status output
    ...
    ...    Example for auto-select avaliable Netact server:
    ...    | Integrate NE To Netact   ne_type=vDU
    ...    | ${mrbts_id}             | Get MRBTS Id From vDU SCF |
    ...    | ${bts_name_change_dict} | create dictionary | dist_name=MRBTS-${mrbts_id} | p_name=btsName | value=mybtsname |
    ...    | ${para_list}            | create list |  ${bts_name_change_dict} |
    ...    | Modify Parameter Via NetAct | para_list=${para_list}  | ne_type=VDU |
    ...    | Deintegrate From NetAct     | ne_type=vDU |
    ...
    ...    Example for giving a Netact server named clab33:
    ...    | Set Netact From Testline Config File | clab33 |
    ...    | Integrate NE To Netact  | ne_type=vDU |
    ...    | ${mrbts_id}             | Get MRBTS Id From vDU SCF |
    ...    | ${bts_name_change_dict} | create dictionary | dist_name=MRBTS-${mrbts_id} | p_name=btsName | value=mybtsname |
    ...    | ${para_list}            | create list |  ${bts_name_change_dict} |
    ...    | Modify Parameter Via NetAct | para_list=${para_list}  | ne_type=VDU |
    ...    | Deintegrate From NetAct     | ne_type=vDU |
    ...
    ${mrbts_name}   Get Mrbts Name via NE Type   NE_type=${ne_type}
    ${plan_name}  Run Keyword If   "${plan_name}"=="${EMPTY}"
      ...   Get Unique Id   prefix=${mrbts_name}_dp   precise=FORMAT_DATETIME
    ...   ELSE   Set Variable   ${plan_name}

    ${dalta_plan_path}   Get An Empty Delta Plan    ne_type=${ne_type}

    # ${file_path}   ${filename}  split_path   ${dalta_plan_path}
    log to console   ${plan_name}
    ${r}   ${info}   Run Keyword And Ignore Error   _Generate Plan With Modify Parameter   ${para_list}
    ...   ${dalta_plan_path}    ${ne_type}

    Run Keyword If   '${r}'=='FAIL'  _Generate Plan With Add Parameter   ${para_list}   ${dalta_plan_path}
    ...   ${ne_type}

    ${tmp_id}  Get Unique Id    prefix=new_delta_plan   precise=FORMAT_DATETIME  suffix=.xml
    ${new_scf_file}   Get A File   new_delta_plan  ${tmp_id}

    modify_scf_for_netact   file=${dalta_plan_path}   new_file_name=${new_scf_file}

    ${conn}   Connect To Netact Node Via Netact_cm
    ${remove_status}  Run Keyword And Ignore Error  remove plan via netact_cm   plan_name=${plan_name}
    ${import_status}  Import Plan Via Netact_cm   path_to_file=${new_scf_file}     planname=${plan_name}

    ${pro_status}   Provision Plan Via Netact_cm    plan_name=${plan_name}    create_backup=False
    [Return]    ${pro_status}


Get Parameter Value Via Netact
    [Arguments]    ${dist_name}   ${parameter_name}   ${list_name}=${EMPTY}
    [Documentation]    Get Parameter Value Via Netact
    ...  author:             chris.l.cao@nokia-sbell.com
    ...  modified by:        <13-2-2023>, <chricao>, <initial created>
    ...
    ...  | Input Parameters | Man. | Description |
    ...  | dist_name  |  yes  | dist_name, e.g, MRBTS-1234  |
    ...  | parameter_name | yes | parameter_name, e.g, btsName  |
    ...  | list_name  |  no  | list_name, default is ${EMPTY}  |
    ...
    ...  *RETURN VALUE*
    ...   value of parameter
    ...
    ...  Example
    ...  | Integrate NE To Netact  | ne_type=vDU  |
    ...  | ${mrbts_id} | Get MRBTS Id From vDU SCF |
    ...  | ${value} | Get Parameter Value Via Netact | dist_name=MRBTS-${mrbts_id} | parameter_name=btsName |
    ...  | ${distname}  | Set Variable | MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1 |
    ...  | ${value} | Get Parameter Value Via Netact | dist_name=${distname} | parameter_name=administrativeState |
    ...  | ${distname}  | Set Variable | MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1 |
    ...  | ${value} | Get Parameter Value Via Netact | dist_name=${distname} | list_name=topMasterList | parameter_name=phaseErrorComp |
    ...  | Deintegrate From NetAct  |  ne_type=vDU |
    ...
    ...  For vcu,
    ...  | Integrate NE To Netact  | ne_type=vCU  |
    ...  | ${mrbts_id} | Get MRBTS Id From vCU SCF |
    ...  | ${value}  | Get Parameter Value Via Netact | dist_name=MRBTS-${mrbts_id} | parameter_name=btsName |
    ...  | ${vcu_conf} | Get VCU Conf From SCF |
    ...  | ${distname}  | Set Variable | MRBTS-${vcu_conf["mrbts_id"]}/NRBTS-${vcu_conf["nrbts_id"]}/NRCELL-1 |
    ...  | ${value}  Get Parameter Value Via Netact | dist_name=${dist_name} | parameter_name=administrativeState |
    ...  | Deintegrate From NetAct |  ne_type=vCU |
    ...
    ${mrbts_name}  Set Variable  ${distname.split("/")[0]}

    Connect To Netact Node Via Netact_cm
    ${scf_path}    Get Export Plan Via Netact_cm    ${mrbts_name}
    ${unique_file_name}  Get Unique Id  precise=FORMAT_DATETIME  suffix=.xml
    ${new_file_name}  Get A File   Get_Parameter_Value_Via_Netact   ${unique_file_name}
    recover_scf   file=${scf_path}  new_file_name=${new_file_name}
    Disconnect To Netact Node Via Netact_cm

    scf.Load_Scf  file_path=${new_file_name}

    ${value}   Run Keyword If   "${list_name}"!="${EMPTY}"
    ...    scf.Get_Value_From_Scf    dist_name=${distname}   list_name=${list_name}   p_name=${parameter_name}
    ...   ELSE   scf.Get_Value_From_Scf    dist_name=${distname}     p_name=${parameter_name}
    [Return]  ${value}


Get Upper Case Ne Name
    [Arguments]  ${ne_type}
    ${ne_type}  Set Variable   ${ne_type.upper()}
    ${ne_type}  Set Variable If   "${ne_type}"=="CU"    VCU    ${ne_type}
    [Return]  ${ne_type}


Get Specified Mo Attributes
    [Arguments]     ${dn_name}     ${ne_type}=cu
    [Documentation]   Get Specified Mo Attributes
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   10.1.2022, rui.3.li@nokia-sbell.com, support cu
    ...   20.1.2022,chris.l.cao@nokia-sbell.com, use 'Get Upper Case Ne Name' to convert ne_type to upper case ne_type
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | dn_name | Yes | dn_name, like below example |
    ...    | ne_type   | No | default is cu, only support cu and vdu, will error with another value |
    ...
    ...    *RETURN VALUE*
    ...    list, member is class_name, dist_name, version
    ...
    ...    Example
    ...   | ${mo_att_list} |  get specified mo attributes | MRBTS-123 |  ne_type=VCU |
    ...
    ${ne_type}  Get Upper Case Ne Name  ne_type=${ne_type}

    ${current_plan_path}    Run Keyword If   '${ne_type}'=='VCU'  CU Backup SCF
    ...   ELSE IF   '${ne_type}'=='VDU'   Get VDU SCF From Current Plan
    ...   ELSE   Fail    ne_type error,must be cu or vdu
    scf.load_scf   ${current_plan_path}
    ${class_name}    scf.get_mo_attribute     dist_name=${dn_name}  attribute=class
    ${dist_name}    scf.get_mo_attribute     dist_name=${dn_name}    attribute=distName
    ${version}    scf.get_mo_attribute     dist_name=${dn_name}    attribute=version
    ${mo_att_list}    Create List   ${class_name}   ${dist_name}   ${version}
    scf.save_scf    ${current_plan_path}
    [Return]   ${mo_att_list}


Get An Empty Delta Plan
    [Arguments]   ${gnb_index}=0   ${ne_type}=cu    ${vdu_index}=0
    [Documentation]   Get Specified Mo Attributes
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   10.1.2022, rui.3.li@nokia-sbell.com, support cu
    ...   20.1.2022,chris.l.cao@nokia-sbell.com, use 'Get Upper Case Ne Name' to convert ne_type to upper case ne_type
    ...   4.11.2022,chris.l.cao@nokia-sbell.com, rename KW name to 'Get An Empty Delta Plan',
    ...                                          use 'Get Mrbts Name via NE Type' to get mrbts_name.
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | ne_type   | No | default is cu, only support cu and vdu, will error with another value |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    delta plan file name, which is without MO content.
    ...
    ...    Example
    ...   |  ${dalta_plan_path} | Get An Empty Delta Plan  | ne_type=VCU |
    ...
    ${ne_type}  Get Upper Case Ne Name  ne_type=${ne_type}

    ${current_plan_path}    Run Keyword If   '${ne_type}'=='VCU'  CU Backup SCF   gnb_index=${gnb_index}
    ...   ELSE IF   '${ne_type}'=='VDU'   Get VDU SCF From Current Plan    ${gnb_index}   ${vdu_index}
    ...   ELSE   Fail    ne_type error,must be cu or vdu
    scf.load_scf   ${current_plan_path}

    ${mrbts_name}   Get Mrbts Name via NE Type   NE_type=${ne_type}
#    scf.remove_mo_with_descendant_mos    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}
    ${mrbts_name}   Get Mrbts Name via NE Type   NE_type=${ne_type}
    scf.remove_mo_with_descendant_mos    dist_name=${mrbts_name}
    ${tmp_id}   Get Unique ID    prefix=${mrbts_name}_delta_plan_empty_   precise=FORMAT_DATETIME   suffix=.xml
    ${tmp_path}  Get A File   Get_An_Empty_Delta_Plan  ${tmp_id}
    scf.save_scf   ${tmp_path}
    [Return]   ${tmp_path}


connect to netact node via netact_cm
    [Documentation]   To run the command log in to a virtual machine, where the was -<nodename> service is running
    ...    For more information, see locating the right virtual machine for a service administrating NetAct Virtual Infrastructure
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    modified by:        <13-Oct-2020>, <huilxu>, <Initial creation>
    ...    3.2.2023,chris.l.cao@nokia-sbell.com, change to TARGET_NETACT_INFO to unify netact server auto-selection and using specific one
    ...
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    ssh session
    ...
    ...    Example
    ...    | connect to netact node via netact_cm |
#    ${conn}   netact_cm.connect_to
#    ...   hostname=${netact['node_ip']}
#    ...   username=${netact['user']}
#    ...   password=${netact['password']}
    ${conn}   netact_cm.connect_to
    ...   hostname=${TARGET_NETACT_INFO['node_ip']}
    ...   username=${TARGET_NETACT_INFO['user']}
    ...   password=${TARGET_NETACT_INFO['password']}
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
    ...     | connect to netact node via netact_cm |
    ...     | get export plan via netact_cm |
    ${status}   netact_cm.remove_plan
    ...   plan_name=${plan_name}
    [Return]  ${status}


Import And Provision Delta Plan via Netact
    [Arguments]    ${dalta_plan_path}    ${plan_name}=delta
    [Tags]  NETACT_CM
    [Documentation]  import and provision delta plan to the network.
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   20.1.2022,chris.l.cao@nokia-sbell.com, delete parameter new_delta_file_name
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | dalta_plan_path  | Yes |  full path of the plan file |
    ...    | plan_name  | no |  plan_name |
    ...
    ...    *RETURN VALUE*
    ...    state of provision operation
    ...
    ...    Example
    ...    | Integrate NE To Netact |  ne_type=vDU |
    ...    | Login Netact Via Web Url |
    ...    | ${status} |  Provision Delta Plan via Netact | dalta_plan_path=/tmp/myscf.xml |
    ...    | Deintegrate From NetAct  |  ne_type=vDU  |
    ...

#    modify_scf_for_netact   ${dalta_plan_path}   ${new_delta_file_name}
    ${tmp_id}  Get Unique Id    prefix=new_delta_plan   precise=FORMAT_DATETIME  suffix=.xml
    ${new_delta_file_name}   Get A File   new_delta_plan  ${tmp_id}
    modify_scf_for_netact   file=${dalta_plan_path}   new_file_name=${new_delta_file_name}

    ${conn}   connect to netact node via netact_cm
    ${file_path}    ${file_name}    Split Path    ${dalta_plan_path}
    ${remove_status}  run keyword and ignore error  remove plan via netact_cm   plan_name=${plan_name}
#    ${import_status}  import plan via netact_cm   path_to_file=${file_path}/${new_delta_file_name}     planname=${plan_name}
    ${import_status}  import plan via netact_cm   path_to_file=${new_delta_file_name}     planname=${plan_name}
    ${pro_status}   provision plan via netact_cm    plan_name=${plan_name}    create_backup=False
    [Return]    ${pro_status}
    [Teardown]  disconnect to netact node via netact_cm


============= taf.ul.oam.netact.cm end ============
Connect to Netact via Issh
    [Documentation]    Connect to Netact via Issh
    ...    *Author:*  rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | how or what |
    ...    | 2022-3-4 | r3li | init create |
    ...    *Example*
    ...    | ${alias} | Connect to Netact via Issh |
    ...    *Return*
    ...    - string, connect alias
    ${netact_index}     ${netact_info}    Get Target Netact Server
    ${user}   set variable    ${netact_info}[user]
    ${alias}    get unique id
    issh.connect to  ip=${netact_info}[node_ip]    username=${user}   password=${netact_info}[password]
       ...   prompt=${user}@.*\\$   alias=${alias}   width=500
    [Return]   ${alias}


Check Whether NIDD Mismatch Between NetAct And vDU
    [Arguments]    ${vdu_index}=0   ${gnb_index}=0
    [Documentation]    Check Whether NIDD Mismatch Between NetAct And vDU
    ...   If cover return match, if not return dismatch
    ...   *Author* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what and how |
    ...   | 2022-3-4 | r3li | init create |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | vdu_index | NO | int, vdu index default is 0 |
    ...   | gnb_index | NO | int, gnb index default is 0 |
    ...   *Example*
    ...   | dismatch | Check Whether NIDD Mismatch Between NetAct And vDU | 0 | 0 |
    ...   *Return*
    ...   - dismatch or match
    vDU Rest Login   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    ${vdu_conf}    Get VDU Conf From SCF    scf_path=${scf_file_with_fullpath}
    ${result}   Check NIDD in Netact    ${vdu_conf}
    [Return]   ${result}
    [Teardown]   vDU Rest Logout


_Get Cover Result
    [Arguments]    ${alias}    ${compare_value}    ${sub_file_name}
    ${ls_command}    set variable   ls /etc/opt/oss/global/rac/conf/metadata
    ${out}    issh.execute   ${ls_command}/${sub_file_name} | grep ${compare_value}   alias=${alias}   check_result=${False}
    ${match}    Get Regexp Matches    ${out}    ${compare_value}
    ${flag}   Set Variable If    ${match.__len__()}>=${1}    ${1}   ${0}
    [Return]   ${flag}


Check NIDD in Netact
    [Arguments]    ${scf_conf}
    ${alias}   connect to netact via issh

#    Check TNL
    ${tnl_version}   Set Variable   ${scf_conf}[tnl_version]
    ${flag_1}    _Get Cover Result    ${alias}    ${tnl_version}    cmdsrt
#    Check NRBTS
    ${nrbts_version}   Set Variable    ${scf_conf}[nrbts_version]
    ${flag_2}   _Get Cover Result    ${alias}    ${nrbts_version}   cmdnr
#    Check NML
    ${mnl_version}   Set Variable  ${scf_conf}[mnl_version]
    ${flag_3}   _Get Cover Result    ${alias}    ${mnl_version}   cmdsrm

    ${flag}    Evaluate    int(${flag_1})+int(${flag_2})+int(${flag_3})
    ${result}   Set Variable If    '${flag}'=='${3}'    match   dismatch
    [Return]   ${result}
    [Teardown]   issh.disconnect   ${alias}


Lock OR Unlock RU For VDU Via Netact
    [Arguments]   ${ru_id}=1   ${operation}=lock  ${gnb_index}=0   ${vdu_index}=0   ${netact_index}=${None}
    [Documentation]    Lock OR Unlock RU For VDU Via Netact
    ...   *Author* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what and how |
    ...   | 2022-12-6 | r3li | init create |
    ...   | 2023-5-17 | r3li | update keyword support multiple ru id |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | ru_id | Yes | support int or list, ru id number, like 1 or [1, 2] default id is 1 |
    ...   | operation | No | only support lock or unlock, default is lock |
    ...   | vdu_index | NO | int, vdu index default is 0 |
    ...   | gnb_index | NO | int, gnb index default is 0 |
    ...   | netact_index | NO | str, netact index, default is None means select avaliable netact. |
    ...   *Example*
    ...   | Set netact from testline config file |
    ...   | Lock OR Unlock RU For VDU Via Netact | 1 | lock | 0 | 0 |
    ...   *Example For Multiple Ru*
    ...   | Set netact from testline config file | clab33 |
    ...   | ${ru_id_list} | Create List | 1 | 2 |
    ...   | Lock OR Unlock RU For VDU Via Netact | ${ru_id_list} | lock | 0 | 0 | clab33 |
    ...   *Return*
    ...   - None
    ${ru_list}   convert_list   ${ru_id}
    ${lock_status}   Run Keyword If   '${operation}'=='lock'   Set Variable   0
    ...   ELSE IF   '${operation}'=='unlock'   Set Variable   2
    ...   ELSE   operation ${operation} not support.
    ${mrbts_id}   Get MRBTS Id From vDU SCF   ${vdu_index}   ${gnb_index}
    ${para_list}   Create List
    FOR   ${ru_id}   IN   @{ru_list}
       ${parameter_dict}   Create Dictionary    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-${ru_id}
    ...  p_name=administrativeState   value=${lock_status}   operation=update
       Append To List   ${para_list}   ${parameter_dict}
    END
    Modify Parameter From NetAct  para_list=${para_list}   netact_index=${netact_index}


Lock OR Unlock RU For VCU Via Netact
    [Arguments]   ${ru_id}=1   ${operation}=lock  ${gnb_index}=0
    [Documentation]    Lock OR Unlock RU For VCU Via Netact
    ...   *Author* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what and how |
    ...   | 2022-12-6 | r3li | init create |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | ru_id | Yes | Cell id number, like 1,2,3, default id is 1 |
    ...   | operation | No | only support lock or unlock, default is lock |
    ...   | gnb_index | NO | int, gnb index default is 0 |
    ...
    ...   *Example*
    ...   | Lock OR Unlock RU For VCU Via Netact | 1 | lock | 0 |
    ...   *Return*
    ...   - None
    ${lock_status}   Run Keyword If   '${operation}'=='lock'   Set Variable   Locked
    ...   ELSE IF   '${operation}'=='unlock'   Set Variable   Unlocked
    ...   ELSE   operation ${operation} not support.
    ${mrbts_id}   Get MRBTS Id From vCU SCF   ${gnb_index}

    ${parameter_dict}   Create Dictionary    dist_name=MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-${ru_id}
    ...  p_name=administrativeState   value=${lock_status}
    ${para_list}   Create List    ${parameter_dict}
    Modify Parameter Via NetAct  para_list=${para_list}   ne_type=vcu


Reset VDU via Netact After VDU Integrated
    [Arguments]   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]    Reset VDU via Netact After VDU Integrated
    ...   *Author* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what and how |
    ...   | 2022-12-6 | r3li | init create |
    ...   | 2023.2.3 | chris.l.cao@nokia-sbell.com | add script samples after implementation of auto-select and non-auto-select netact server |
    ...
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | gnb_index | NO | int, gnb index default is 0 |
    ...   | vdu_index | NO | int, vdu index default is 0 |
    ...
    ...   *Example*
    ...    Example for auto-select avaliable Netact server:
    ...    | Integrate NE To Netact |  ne_type=vDU
    ...    | Reset VDU via Netact After VDU Integrated |
    ...    | Deintegrate From NetAct |  | ne_type=vDU |
    ...
    ...    Example for giving a Netact server named clab33:
    ...    | Set Netact From Testline Config File | clab33 |
    ...    | Integrate NE To Netact | ne_type=vDU
    ...    | Reset VDU via Netact After VDU Integrated |
    ...    | Deintegrate From NetAct | ne_type=vDU |
    ...
    ...   *Return*
    ...   - None
    ...
    ${mrbts_id}   Get MRBTS Id From vDU SCF   ${vdu_index}   ${gnb_index}
    ${dist_name_pre}   Set variable   MRBTS-${mrbts_id}/MNL-1/CMD-1/
    FOR  ${i}  IN RANGE   ${10}
       ${index}    Evaluate   ${i}+${1}
       ${dist_name}   Set Variable    MRBTS-${mrbts_id}/MNL-1/CMD-1/SWRESETREQ-${index}
       ${r}   ${tmp_list}   Run Keyword And Ignore Error   get specified mo attributes   ${dist_name}    ne_type=vdu
       Exit For Loop If   '${r}'=='FAIL'
    END

    ${parameter_dict}   Create Dictionary    dist_name=${dist_name}
    ...  p_name=swResetLevel   value=btsReset    class=SWRESETREQ
    ${para_list}   Create List    ${parameter_dict}
    Modify Parameter Via NetAct  para_list=${para_list}   ne_type=vdu
    [Teardown]   Run Keyword And Ignore Error   _Delete MO After Reset Success   ${dist_name}   vdu


Reset VCU via Netact After VCU Integrated
    [Arguments]    ${gnb_index}=0
    [Documentation]   Reset VCU via Netact After VCU Integrated
    ...   *Author* chris.l.cao@nokia-sbell.com
    ...
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | gnb_index | NO | int, gnb index default is 0 |
    ...
    ...   *Example*
    ...    Example for auto-select avaliable Netact server:
    ...    | Integrate NE To Netact |  ne_type=vCU |
    ...    | Reset VCU via Netact After VCU Integrated |
    ...    | Deintegrate From NetAct |  | ne_type=vCU |
    ...
    ...   *Return*
    ...   - None
    ...
    ${mrbts_id}   Get MRBTS Id From vCU SCF   ${gnb_index}
    ${dist_name_pre}   Set variable   MRBTS-${mrbts_id}/MNL-1/CMD-1/
    FOR  ${i}  IN RANGE   ${10}
       ${index}    Evaluate   ${i}+${1}
       ${dist_name}   Set Variable    MRBTS-${mrbts_id}/MNL-1/CMD-1/SWRESETREQ-${index}
       ${r}   ${tmp_list}   Run Keyword And Ignore Error   get specified mo attributes   ${dist_name}    ne_type=vcu
       Exit For Loop If   '${r}'=='FAIL'
    END

    ${parameter_dict}   Create Dictionary    dist_name=${dist_name}
    ...  p_name=swResetLevel   value=btsReset   class=SWRESETREQ
    ${para_list}   Create List    ${parameter_dict}
    Modify Parameter Via NetAct  para_list=${para_list}   ne_type=vcu

    [Teardown]   Run Keyword And Ignore Error   _Delete MO After Reset Success   dist_name=${dist_name}   ne_type=vcu


_Delete MO After Reset Success
   [Arguments]    ${dist_name}   ${ne_type}=vcu
   ${parameter_dict_del}    Create Dictionary    dist_name=${dist_name}   operation=delete    class=SWRESETREQ
   ${para_list}   Create List    ${parameter_dict_del}
   ${operation_status}    Modify Parameter Via NetAct  para_list=${para_list}   ne_type=${ne_type}


Import Package To Netact
    [Arguments]    ${file_path}    ${sw_version}   ${mo_type}=MRBTS
    [Documentation]    Import Package To Netact
    ...   *Author* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what and how |
    ...   | 2023-2-2 | r3li | init create |
    ...
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | file_path | Yes | string, absolute path of file |
    ...   | sw_version | Yes | string, software version, like:vDUCNF00_0.300.10809 |
    ...   | mo_type | No | mo type, default is MRBTS |
    ...
    ...   *Return*
    ...   - None
    ...
    ...   *Example*
    ...   | Import Package To Netact | /home/ute/vDUCNF00_0.300.10809_pdl_validation_service_plugin.zip | vDUCNF00_0.300.10809 |
    ...
    ${alias}   ssh to netact node
    # it return "Error SWMT1100: Failed to load trust store from
    # path [ /var/opt/oss/global/swm/swm_keystore/swm_SWIP_truststore.jks ] to trust store instance: No such file."
    taf_netact.import_build
    ...   build_or_file_path=${file_path}
    ...   mo_type=${mo_type}
    ...   version_id=${sw_version}
    ...   alias=${alias}
    ${out_put}   taf_netact.is_imported   version_id=${sw_version}   mo_type=${mo_type}   alias=${alias}
    Should Be True    ${out_put}
    [Teardown]   Disconnect To Netact Node  alias=${alias}


Delete Package on Netact
    [Arguments]   ${soft_version_ids}   ${mo_type}=MRBTS
    [Documentation]    Delete Package on Netact
    ...   *Author* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what and how |
    ...   | 2023-2-2 | r3li | init create |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | soft_version_ids | Yes | string or list, software version, like:vDUCNF00_0.300.10809 |
    ...   | mo_type | No | mo type, default is MRBTS |
    ...   *Example*
    ...   | Delete Package on Netact | vDUCNF00_0.300.10809 |
    ...   *Return*
    ...   - None
    ${version_ids}   convert_list   ${soft_version_ids}
    ${alias}   ssh to netact node
    taf_netact.delete_build
    ...   version_ids=${soft_version_ids}
    ...   mo_type=${mo_type}
    ...   alias=${alias}
    [Teardown]   disconnect to netact node  alias=${alias}


Lock OR Unlock Cell For VDU Via Netact
    [Arguments]   ${cell_id}=1   ${operation}=lock  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]    Lock OR Unlock Cell For VDU Via Netact
    ...   *Author* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what and how |
    ...   | 2023-3-13 | r3li | init create |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | cell_id | Yes | Cell id number, like 1,2,3, default id is 1 |
    ...   | operation | No | only support lock or unlock, default is lock |
    ...   | vdu_index | NO | int, vdu index default is 0 |
    ...   | gnb_index | NO | int, gnb index default is 0 |
    ...   *Example*
    ...   | Set netact from testline config file |
    ...   | Lock OR Unlock Cell For VDU Via Netact | 1 | lock | 0 | 0 |
    ...   *Return*
    ...   - None
    ${lock_status}   Run Keyword If   '${operation}'=='lock'   Set Variable   Locked
    ...   ELSE IF   '${operation}'=='unlock'   Set Variable   Unlocked
    ...   ELSE   operation ${operation} not support.

    ${mrbts_id}   Get MRBTS Id From vDU SCF   ${vdu_index}   ${gnb_index}
    ${vdu_conf}   Get VDU Conf From SCF    vdu_index=${vdu_index}   gnb_index=${gnb_index}

    ${parameter_dict}   Create Dictionary    dist_name=MRBTS-${mrbts_id}/NRBTS-${vdu_conf["nrbts_id"]}/NRCELL-${cell_id}
    ...  p_name=administrativeState   value=${lock_status}
    ${para_list}   Create List    ${parameter_dict}
    Modify Parameter Via NetAct  para_list=${para_list}   ne_type=vdu


Lock OR Unlock Cell For VCU Via Netact
    [Arguments]   ${cell_id}=1   ${operation}=lock  ${gnb_index}=0   ${netact_index}=${None}
    [Documentation]    Lock OR Unlock Cell For VCU Via Netact
    ...   *Author* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what and how |
    ...   | 2023-3-13 | r3li | init create |
    ...   | 2023-5-17 | r3li | update keyword support multiple cell id |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | cell_id | Yes | Cell id number, like 1,2,3, default is 1 |
    ...   | operation | No | only support lock or unlock, default is lock |
    ...   | gnb_index | NO | int, gnb index default is 0 |
    ...   | netact_index | NO | str, netact index, default is None means select avaliable netact. |
    ...   *Example*
    ...   | Set netact from testline config file |
    ...   | Lock OR Unlock Cell For VCU Via Netact | 1 | lock | 0 | clab1016 |
    ...   *Example for giving a Netact server named clab1016*
    ...    | Set Netact From Testline Config File | clab1016 |
    ...    | Integrate NE To Netact | ne_type=vDU |
    ...    | ${cell_ids} | Create List | 1 | 2 |
    ...    | Lock OR Unlock Cell For VCU Via Netact | cell_id=${cell_ids} | gnb_index=0 | vdu_index=0 | netact_index=clab33 |
    ...    | Deintegrate From NetAct | ne_type=vDU |

    ...   *Return*
    ...   - None
    ${cell_id_list}   convert_list   ${cell_id}
    ${lock_status}   Run Keyword If   '${operation}'=='lock'   Set Variable   0
    ...   ELSE IF   '${operation}'=='unlock'   Set Variable   2
    ...   ELSE   operation ${operation} not support.
    ${mrbts_id}   Get MRBTS Id From vCU SCF   ${gnb_index}
    ${vcu_conf}   Get VCU Conf From SCF    gnb_index=${gnb_index}
    ${para_list}   Create List
    FOR   ${cell_id}   IN   @{cell_id_list}
       ${parameter_dict}   Create Dictionary    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${vcu_conf["nrbts_id"]}/NRCELL-${cell_id}
    ...  p_name=administrativeState   value=${lock_status}   operation=update
       Append To List    ${para_list}    ${parameter_dict}
    END
    Modify Parameter From NetAct  para_list=${para_list}    netact_index=${netact_index}

Get All Cleared Alarms From Netact
    [Arguments]   ${mrbts_name}   ${time_from}   ${time_to}
    [Documentation]   Get All Alarms From Netact
    ...    *AUTHOR* tingting.xiao@nokia-sbell.com
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
    ${alarm_list}    taf_netact.get_cleared_alarms
    ...  dist_name=PLMN-PLMN/${mrbts_name}
    ...  time_from=${time_from}
    ...  time_to=${time_to}
    ...  alias=${alias}
    [Return]  ${alarm_list}


Reset RU Via Netact After VDU Integrated
    [Arguments]   ${ru_id_list}=1   ${vdu_index}=0   ${gnb_index}=0   ${netact_index}=${None}
    [Documentation]    Reset RU Via Netact After VDU Integrated
    ...   *Author* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what and how |
    ...   | 2023-5-17 | r3li | init create |
    ...
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | ru_id_list | NO | int or list, default value is 1 |
    ...   | gnb_index | NO | int, gnb index default is 0 |
    ...   | vdu_index | NO | int, vdu index default is 0 |
    ...   | netact_index | NO | str, netact index, default is None means select avaliable netact. |
    ...
    ...   *Example*
    ...    Example for auto-select avaliable Netact server:
    ...    | Integrate NE To Netact | ne_type=vDU |
    ...    | Reset RU Via Netact After VDU Integrated | 1 | 0 | 0 | None |
    ...    | Deintegrate From NetAct | ne_type=vDU |
    ...
    ...    Example for giving a Netact server named clab33:
    ...    | Set Netact From Testline Config File | clab33 |
    ...    | Integrate NE To Netact | ne_type=vDU |
    ...    | ${ru_id_list} | Create List | 1 | 2 |
    ...    | Reset RU Via Netact After VDU Integrated | ru_id_list=${ru_id_list} | gnb_index=0 | vdu_index=0 | netact_index=clab33 |
    ...    | Deintegrate From NetAct | ne_type=vDU |
    ...
    ...   *Return*
    ...   - None
    ...
    ${ru_id_list}   convert_list   ${ru_id_list}
    ${ru_number}   Get Length    ${ru_id_list}
    ${mrbts_id}   Get MRBTS Id From vDU SCF   ${vdu_index}   ${gnb_index}
    ${dist_name_pre}   Set variable   MRBTS-${mrbts_id}/MNL-1/CMD-1/
    ${HWRESETREQ_dist_name_list}    Create List
    FOR  ${i}  IN RANGE   ${10}
       ${index}    Evaluate   ${i}+${1}
       ${dist_name}   Set Variable    MRBTS-${mrbts_id}/MNL-1/CMD-1/HWRESETREQ-${index}
       ${r}   ${tmp_list}   Run Keyword And Ignore Error   get specified mo attributes   ${dist_name}    ne_type=vdu
       Run Keyword If   '${r}'=='FAIL'   Append To List   ${HWRESETREQ_dist_name_list}   PLMN-PLMN/${dist_name}
       ${dist_name_length}    Get Length   ${HWRESETREQ_dist_name_list}
       Exit For Loop If    ${dist_name_length}==${ru_number}
    END

    ${para_list}   Create List

    FOR   ${i}   IN RANGE   ${ru_number}
        ${ru_id}    Set Variable   ${ru_id_list}[${i}]
        ${dist_name}   Set Variable   ${HWRESETREQ_dist_name_list}[${i}]
        ${parameter_dict}   Create Dictionary    dist_name=${dist_name}
    ...  p_name=targetHwResetUDN   value=MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-${ru_id}    class=HWRESETREQ    operation=create
        Append To List   ${para_list}    ${parameter_dict}
    END
    Modify Parameter From NetAct  para_list=${para_list}    netact_index=${netact_index}
    [Teardown]   Run Keyword And Ignore Error   _Delete MO After Reset RU Success   ${HWRESETREQ_dist_name_list}
    ...   netact_index=${netact_index}


_Delete MO After Reset RU Success
    [Arguments]   ${HWRESETREQ_dist_name_list}   ${netact_index}=${None}
    ${para_list}   Create List
    FOR   ${HWRESETREQ_dist_name}   IN   @{HWRESETREQ_dist_name_list}
      ${parameter_dict}   Create Dictionary   dist_name=${HWRESETREQ_dist_name}   operation=delete
      Append To List   ${para_list}   ${parameter_dict}
    END
   Modify Parameter From NetAct  para_list=${para_list}    netact_index=${netact_index}


NMS Port Should Listen In NE Side
    [Arguments]   ${ne_type}=vdu  ${security_mode}=No TLS   ${gnb_index}=0   ${vdu_index}=0  ${fhgw_index}=0
    [Documentation]    Firewall Between NOM and NE Should Be Good
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   21.6.2023,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ne_type  |  No  |  Which type of ne will be integrated, can be cu/vcu/vdu/fhgw, vdu in default   |
    ...    | security_mode | no | security_mode, 'No TLS' or TLS, default is 'No TLS'  |
    ...    | gnb_index  |  No  |  cu index, should be 0, 1...  |
    ...    | vdu_index  |  No  |  vdu index under specified cu   |
    ...    | fhgw_index |  No  |  fhgw index under specified vdu   |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...   | NMS Port Should Listen In NE | ne_type=vdu  | security_mode=No TLS |
    ...   | NMS Port Should Listen In NE | ne_type=vdu  | security_mode=TLS |
    ...   | NMS Port Should Listen In NE | ne_type=vcu  | security_mode=No TLS |
    ...   | NMS Port Should Listen In NE | ne_type=vcu  | security_mode=TLS |
    ...
    ${port_list}  Run Keyword If   "${security_mode}"=="No TLS"   Create List  8080
       ...   ELSE   Create List  8443
    ${target_ip}   Run Keyword If   "${ne_type}"=="VDU"
    ...   Port Should Listen In VDU Container  port_list=${port_list}  ctr_abbr=oamagent   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ...    ELSE IF   "${ne_type}"=="VCU"
    ...   Port Should Listen In VCU Container  port_list=${port_list}  ctr_abbr=oamagent   gnb_index=${gnb_index}
#    ...    ELSE IF   "${ne_type}"=="fhgw"
#    ...   Confirm Ports Are Listening In FHGW   gnb_index=${gnb_index}    vdu_index=${vdu_index}   fhgw_index=${fhgw_index}
#    ...    ELSE   Fail  Unknown ne_type:${ne_type}!
