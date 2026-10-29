*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   kw_to_be_optimized.robot

Library           ./py_tool/kw_to_be_optimized_py.py
#Library           ./py_tool/global_variables.py
Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library           taf.config.scf                        WITH NAME    scf

*** Variables ***

*** Keywords ***

Get Interface Information For F1-Cplane For VCU
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get Interface Information For F1-Cplane For VCU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    Interface informatin, including ip, mask, broadcast,etc.
    ...
    ...   Example
    ...   | ${interface_information} | Get Interface Information For F1-Cplane For VCU |
    ...   | ${ip} | Set Variable | ${interface_information["ip"]} |
    ...   | ${mask} | Set Variable | ${interface_information["mask"]} |
    ...   | ${broadcast} | Set Variable | ${interface_information["broadcast"]} |
    ...
    ${f1_cplane_ip_info}   Get CU Specified Interface IP  interface_name=f1_interface   plane_type=c_plane_ip_address  gnb_index=${gnb_index}
    ${is_ipv6}   Check If VCU OAM Is IPv6  gnb_index=${gnb_index}
    ${f1_cplane_ip_info}  Evaluate   dict(${f1_cplane_ip_info[0]})
    ${f1_cplane_ip}  Set Variable If  "${is_ipv6}"=="${True}"        ${f1_cplane_ip_info["v6"]}   ${f1_cplane_ip_info["v4"]}

    ${conf_dict}      Get VCU One Click Config Dictionary From TestLine  gnb_index=${gnb_index}
    ${f1u_subnet}  Set Variable  ${conf_dict["vCU_network"]["f1u_subnet"]}

    ${mask}   Evaluate    str(IPy.IP("${f1u_subnet}").netmask())  modules=IPy
    ${broadcast}   Evaluate    str(IPy.IP("${f1u_subnet}").broadcast())  modules=IPy

    ${rtn}   Create Dictionary   ip=${f1_cplane_ip}    mask=${mask}   broadcast=${broadcast}

    [Return]  ${rtn}


Get Interface Information For FHM-plane
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Get Interface Information For FHM-Cplane
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    Interface informatin, including ip, mask, broadcast, vlan id, etc.
    ...
    ...   Example
    ...   | ${interface_information} | Get Interface Information For FHM-Cplane |
    ...   | ${ip} | Set Variable | ${interface_information["ip"]} |
    ...   | ${mask} | Set Variable | ${interface_information["mask"]} |
    ...   | ${broadcast} | Set Variable | ${interface_information["broadcast"]} |
    ...
    ${alias}   Get Unique ID
    Connect To VDU Container With Tenant Interactively   ctr_abbr=oamfh   alias=${alias}
    ${out}   issh.Execute   command=ifconfig fhmplane  check_result=${False}   alias=${alias}

    ${ip}  ${mask}   ${broadcast}  Parse Ipv4 Address From Ifconfig    content=${out}

    ${out}   issh.Execute   command=ip -d a show dev fhmplane|grep "802.1Q"  check_result=${False}   alias=${alias}
    ${out}   Strip Prompt   ${out}
    ${matches}   String.Get Regexp Matches    ${out}   .*802.1Q\\s+id\\s+(\\d+)\\s+.*   1
    ${vlan_id}   Set Variable  ${matches[0]}

    ${rtn}   Create Dictionary   ip=${ip}    mask=${mask}   broadcast=${broadcast}   vlan_id=${vlan_id}

    [Return]  ${rtn}


Get Running Build Number
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${with_prefix}=${False}   ${print_or_not}=${False}
    [Documentation]   Get Running Build Number
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   27.11.2021,chris.l.cao@nokia-sbell.com, remove NCIR platform to shorten dryrun time
    ...   3.8.2022,chris.l.cao@nokia-sbell.com, remove NCS platform to shorten dryrun time
    ...   19.1.2023,chris.l.cao@nokia-sbell.com, add parameter with_prefix and print_or_not
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...    | with_prefix    | No | with_prefix, if ${True} it has the prefix like vDUCNF00_, default is ${False} |
    ...    | print_or_not      | No | print_or_not, if ${True} it prints the buil number, default is ${False} |
    ...
    ...    *RETURN VALUE*
    ...    vdu running build number, e.g, 0.390.928
    ...
    ...    Example
    ...    |  ${build_number}  | Get Running Build Number |
    ...
    ${build_number}    _Get Running Build Number OCP   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    Return From Keyword If  "${with_prefix}"=="${False}"   ${build_number}

    ${build_prefix}   Get Package Prefix From Global Variables File   build_number=${build_number}
    Run Keyword If   "${print_or_not}"=="${True}"  Log To Console  VDU Full Build Name:${build_prefix}_${build_number}
    [Return]  ${build_prefix}_${build_number}


_Get Running Build Number OCP
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   _Get Running Build Number OCP
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change:
    ...  3.8.2022, chris.l.cao@nokia-sbell.com, add gnb_index parameter
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu running build number, e.g, 0.390.928
    ...
    ...    Example
    ...    |  ${build_number}  | _Get Running Build Number OCP |
    ...
    ${alias}  get unique id

    Connect To K8s Master With Tenant Interactively    gnb_index=${gnb_index}  vdu_index=${vdu_index}   alias=${alias}
    ${ns}   get vdu namespace from testline    gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${out}  issh.Execute   command=helm list -a -n ${ns}|grep aic-vdu-|grep -v aic-vdu-prerequisite|grep -v aic-vdu-cluster|awk '{print $9}'
    ...    alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${build_number}  set variable  ${out.split("-")[-1]}
    [Return]  ${build_number}


Get Running vCU Build Number
    [Arguments]   ${gnb_index}=0
    [Documentation]   Get Running Build Number
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    history change:
    ...  3.8.2022, chris.l.cao@nokia-sbell.com, remove 'Get vCU Platform Name' to shorten dryrun time
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    get running vCU build number, e.g, 0.250.928
    ...
    ...    Example
    ...    |  ${build_number}  | Get Running vCU Build Number |
    ...
    ${build_number}     _Get vCU Running Build Number NCS   gnb_index=${gnb_index}
    [Return]  ${build_number}


_Get vCU Running Build Number NCS
    [Arguments]   ${gnb_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Get vCU Running Build Number
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    get vCU running build number, e.g, 0.250.928
    ...
    ...    Example
    ...    |  ${build_number}  | Get vCU Running Build Number |
    ...
    ${alias}   Connect To CU K8S Master With Tenant     gnb_index=${gnb_index}
    ${ns}  Get CU Namespace From Testline   gnb_index=${gnb_index}
    ${out}  issh.Execute   command=helm list -a -n ${ns} |grep aic-vcu-cnf|awk '{print $9}'  check_result=${False}   alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${build_number}  set variable  ${out.split("-")[-1]}
    [Return]  ${build_number}


_Get VDU Rest Api Version
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0
    ${current_build_version}    Get Running Build Number   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${sw_steam}=    Evaluate    '.'.join(${current_build_version.split('.')[:2]})
    ${restapi_version}    Set Variable   ${VDU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING['${sw_steam}']}
    [Return]   ${restapi_version}


Online Enable actCli For CU
    [Documentation]   Enable actCli when it is false
    ...    *AUTHOR* lingting.sun@nokia-sbell.com
    ...    modified by:        <08-07-2020>, <lingtsun>, <Initial creation>
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Online Enable actCli For CU |
    ...
    ${gnb_id}    set variable    ${tl.gnbs[0].instance_id}
    ${MO}    set variable     MRBTS-${gnb_id}/MNL-1/MNLENT-1/FEATCADM-1
    &{para_actCli}    Create Dictionary    operation_type=replace   parameter_path=/actCli  value=true
    @{para_list}     Create List    ${para_actCli}
    ${actCli}=    CU Get Online Parameter Value     ${MO}    actCli
    CU Login
    run keyword if  """${actCli}"""=="""false"""
    ...    CU Online Change Single Mo Parameters via rest    para_list=${Para_list}  mo_dn=${MO}
    [Teardown]    CU Logout


CU Get Online Parameter Value
    [Arguments]   ${dn}    ${parameter_path}    ${gnb_index}=${0}   ${items_per_page}=${50}
    [Teardown]   CU Rest Logout   connection=${alias}
    [Documentation]    Get online parameter via rest api.
    ...  author:             fen.huang@nokia-sbell.com
    ...  Change History
    ...  7.17.2020   f2huang@nokia-sbell.com,  new version
    ...  6.12.2021   chris.l.cao@nokia-sbell.com,  make it work in real VCU
    ...  02.11.2022  huilin.xu@nokia-sbell.com,  add delay in CU rest login
    ...  07.1.2023   chris.l.cao@nokia-sbell.com, support multiple VCU
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  dn   | Yes |  Distname of parameter  |
    ...    |  parameter_path |  Yes  |  simple and simple list parameter given like btsName or nrCellList |
    ...                              |  complex parameter given the struncture like a2MeasRedirectSsbRsrp/0/a2ThresholdRedirectSsbRsrp |
    ...
    ...    *RETURN VALUE*
    ...    parameter value, if it's simple or complex parameter, returns string type
    ...    if it's a simple list type parameter, it will return a list.
    ...
    ...    Example
    ...    | CU Get Online Parameter Value  | dn=MRBTS-5248     |   parameter_path=btsName  |
    ...    | CU Get Online Parameter Value  | dn=MRBTS-5247/NRBTS-5247/NRCELLGRP-0 | parameter_path=nrCellList |
    ...    | CU Get Online Parameter Value  | dn=MRBTS-52/NRBTS-1/NRCELL-1 | parameter_path=a2MeasRedirectSsbRsrp/0/a2ThresholdRedirectSsbRsrp |
    ...
    ${alias}  CU Rest Login    gnb_index=${gnb_index}
    ${expected_dn}   set variable   ${dn.strip()}
    ${expected_para_name}    set variable   ${parameter_path.strip()}
    @{para_list}  Split String  ${expected_para_name}  /
    ${paras_info}  cu.search_parameters_of_current_plan   parameter_name=${para_list[-1]}  items_per_page=${items_per_page}  connection=${alias}
    ${value}=   get_online_parameter_value  ${paras_info}  ${expected_dn}  ${parameter_path}
    [Return]  ${value}



Online Enable actCli For vDU
    [Arguments]   ${gnb_index}=0    ${from_scf}=${False}
    [Documentation]   Enable actCli when it is false
    ...    *AUTHOR* lingting.sun@nokia-sbell.com
    ...    modified by:        <09-02-2020>, <lingtsun>, <Initial creation>
    ...    modifyed by:        <18-05-2023>, <rifeng>, <add if get mrbts id from scf>
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index   | no | the gnb index |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...    Example
    ...    | Online Enable actCli For vDU |
    ${quantity_of_vdu_for_specified_cu}=   Get vDU Number    gnb_index=${gnb_index}
    FOR   ${vdu_index}   IN RANGE   ${quantity_of_vdu_for_specified_cu}
         _Online Enable actCli For Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}    from_scf=${from_scf}
    END


_Online Enable actCli For Specific vDU
    [Arguments]       ${vdu_index}=0    ${gnb_index}=0    ${from_scf}=${False}
    [Documentation]   _Online Enable actCli For Specific vDU
    ...    *AUTHOR* unknown@nokia-sbell.com
    ...
    ...  Change History
    ...  2.12.2021   chris.l.cao@nokia-sbell.com, change to 'vDU Modify Parameters Online After Checking Without Wait VDU Up' to shorten dryrun time
    ...  5.16.2022   chris.l.cao@nokia-sbell.com, change to get MRBTS id from current plan, for some environments,
    ...                                           vcu mrbts id=10820, but vdu mrbts id=108201
    ...  8.23.2022   chris.l.cao@nokia-sbell.com, change mrbts_id source back to __init__.py,
    ...                                           because we can't download scf plan when actcli is false in recent software
    ...    modifyed by:        <18-05-2023>, <rifeng>, <add if get mrbts id from scf>
#    ${mrbts_id}  Get MRBTS Id From vDU SCF   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${mrbts_id}    run keyword if   "${from_scf}"!="False"    Get MRBTS Id From vDU SCF
    ...  ELSE    Get MRBTS Id From Testline   gnb_index=${gnb_index}    vdu_index=${vdu_index}

    ${MO}    set variable     MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    @{para_list}    Create list    actCli
    @{value_list}    Create list    true
    vDU Rest Login    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${actCli}=    Get VDU Parameter Value Online     ${MO}    actCli
    run keyword if  """${actCli}"""=="""false"""
    ...    vDU Modify Parameters Online After Checking Without Wait VDU Up   para_list=${para_list}    value_list=${value_list}    mo=${MO}
    ...    vdu_index=${vdu_index}


Get MRBTS Id From vDU SCF
    [Arguments]   ${vdu_index}=0    ${gnb_index}=0
    [Documentation]   Get MRBTS Id From vDU SCF
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    *Change History*
    ...    | date | who | how and what |
    ...    | 2022-3-3 | r3li | support muilt DU |
    ...    *RETURN VALUE*
    ...   mrbts id from vDU Scf
    ...
    ...    Example
    ...    | ${mrbts_id} | Get MRBTS Id From vDU SCF |
    ...
    vDU Rest Login   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    ${vdu_conf}    Get VDU Conf From SCF    scf_path=${scf_file_with_fullpath}
    ${mrbts_id}  set variable      ${vdu_conf["mrbts_id"]}
    [Return]   ${mrbts_id}


Get MRBTS Id From Testline
    [Arguments]     ${gnb_index}=0   ${vdu_index}=0   ${ne_type}=vdu
    [Documentation]   Get MRBTS Id From Testline
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | how and what |
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index   | no | the gnb index, default is 0 |
    ...    | vdu_index   | no | the vdu index, default is 0 |
    ...    | ne_type | no | ne type, only support vdu or vcu |

    ...    *RETURN VALUE*
    ...   mrbts id from init.py
    ...
    ...    Example
    ...    | ${mrbts_id} | Get MRBTS Id From Testline |
    ...
    ${mrbts_id}   set variable If  '${ne_type}'=='vdu'   ${tl.gnbs[${gnb_index}].dus[${vdu_index}].instance_id}
    ...  '${ne_type}'=='vcu'   ${tl.gnbs[${gnb_index}].instance_id}
    [Return]   ${mrbts_id}


Get VDU Conf From SCF
    [Arguments]  ${scf_path}=${EMPTY}   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]  Get VDU Conf From SCF file.
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  17.7.2020,chris.l.cao@nokia-sbell.com, Add support to automatically download scf file via REST if ${scf_path} is ${EMPTY}
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path  | no | abosolute path of scf file, if it's ${EMPTY} it will download scf from CURRENT plan, default is ${EMPTY} |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of configuration in SCF file.
    ...    example: {'mrbts_id': '1234', 'nrbts_id': '5678', 'nrdu_id': '1', 'tnl_oam': '3',
    ...    'tnl_version': 'TNLVDU20B_2006_001' }
    ...
    ...    Example
    ...    | ${vdu_conf} | Get VDU Conf From SCF | scf_path=/home/ute/a.scf |
    ...    | ${vdu_conf} | Get VDU Conf From SCF |
    ...
    ${scf_path}   run keyword if  "${scf_path}"=="${EMPTY}"  Get VDU SCF From Current Plan    gnb_index=${gnb_index}  vdu_index=${vdu_index}
       ...    ELSE    set variable  ${scf_path}

    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    ${tnl_oam}   Get vDU TNL ID   scf_path=${scf_path}  templateType=OAM
    ${tnl_version}   scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/TNLSVC-1   attribute=version
    ${nrbts_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRDU-${nrdu_id}   attribute=version
    ${mnl_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/MNL-1   attribute=version
    ${eqm_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/EQM-1  attribute=version
    ${conf}   create dictionary
    ...  mrbts_id=${mrbts_id}
    ...  nrbts_id=${nrbts_id}
    ...  nrdu_id=${nrdu_id}
    ...  tnl_oam=${tnl_oam}
    ...  tnl_version=${tnl_version}
    ...  nrbts_version=${nrbts_version}
    ...  mnl_version=${mnl_version}
    ...  eqm_version=${eqm_version}
    [Return]  ${conf}

Get vDU TNL ID
    [Arguments]  ${scf_path}  ${templateType}=OAM
    [Documentation]   Get vDU TNL ID
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file. |
    ...    | templateType | no | templateType, valid value is OAM, 5GUserPlane, default is OAM |
    ...
    ...    *RETURN VALUE*
    ...    TNL id of given templateType.
    ...
    ...    Example
    ...    |  ${tnl_id}  | Get vDU TNL ID | scf_path=/tmp/a.scf | templateType=OAM |
    ...    |  ${tnl_id}  | Get vDU TNL ID | scf_path=/tmp/a.scf | templateType=5GUserPlane |
    ...    |  ${tnl_id}  | Get vDU TNL ID | scf_path=/tmp/a.scf | templateType=5GControlPlane |
    ...
    ${distName}   Get MO distName    scf_path=${scf_path}  templateType=${templateType}

    scf.load_scf  file_path=${scf_path}
    ${tnlDN_val}   scf.get_all_values_from_scf   dist_name=${distName[0]}  p_name=tnlDN

    ${result}     Get Regexp Matches     ${tnlDN_val[0]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)   1
    ${tnl_id}  Set Variable If  ${result}   ${result[0]}
    should be true  ${tnl_id}>=1

    [Return]  ${tnl_id}


Get VDU SCF From Current Plan
    [Arguments]   ${gnb_index}=0    ${vdu_index}=0   ${include_runtime_data}=${False}
    [Documentation]  Get VDU SCF From Current Plan
    ...  author: chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  13.5.2023   chris.l.cao@nokia-sbell.com, add include_runtime_data
    ...  2.7.2023   chris.l.cao@nokia-sbell.com, support multiple VDU
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...    | include_runtime_data | no | include_runtime_data, default is ${False} |
    ...
    ...    *RETURN VALUE*
    ...    scf file full name
    ...
    ...    Example
    ...    | ${scf_file_with_fullpath} | Get VDU SCF From Current Plan |
    ...    | ${scf_file_with_fullpath} | Get VDU SCF From Current Plan | include_runtime_data=${True} |
    ...    | ${scf_file_with_fullpath} | Get VDU SCF From Current Plan | gnb_index=0 | vdu_index=0 |
    ...    | ${scf_file_with_fullpath} | Get VDU SCF From Current Plan | gnb_index=0 | vdu_index=1 |
    ...    | ${scf_file_with_fullpath} | Get VDU SCF From Current Plan | gnb_index=1 | vdu_index=0 |
    ...    | ${scf_file_with_fullpath} | Get VDU SCF From Current Plan | gnb_index=1 | vdu_index=1 |
    ...
    ${tmp_scf_path}=  Get A Directory  temp_scf
    ${file_name}   get unique id  prefix=scf_tmp_   suffix=.xml   precise=LOW
    ${alias}   VDU Rest Login    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${tmp_scf_full_path}  vdu.get_current_plan_file
      ...   local_dir_path=${tmp_scf_path}  filename=${file_name}  include_runtime_data=${include_runtime_data}   vdu_connection=${alias}
    [Return]  ${tmp_scf_full_path}


Get MO distName
    [Arguments]   @{para_list}
    [Documentation]  Get MO distName.  It supports multi-parameters filtering and distName filtering.
    ...    When using key=value format, the '=' means 'contain',  e.g, distName=TNL-4 means 'distName' contain 'TNL-4',
    ...    sgwIpAddress=10.68  means 'sgwIpAddress' contain '10.68'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...  Change History
    ...  27.9.2021   chris.l.cao@nokia-sbell.com,  add support to scf exported from Netact
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | para_list  | Yes | key=value pair, scf_path key should be included! please see samples |
    ...
    ...    *RETURN VALUE*
    ...    Return distName list that matched the parameters filter and distName filter. Return type is list.
    ...
    ...    Example
    ...    Get distName according to mixed filter
    ...    | ${scf_path} | set variable | /tmp/scf.xml |
    ...    | scf.load_scf | file_path=${scf_path}      |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | btsName         |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=btsName |
    ...
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | templateType=OAM |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=templateType |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=tnlDN |
    ...
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=IPNO |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=IPNO | icmpDscp |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=IPNO | icmpDscp=10 |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=MRBTS-1234/TNLSVC-1/TNL-1/IPNO | icmpDscp=10 |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=icmpDscp |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=ndMldDscp |
    ...
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=TNL-4 |  destIpAddr=10.68 |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | sgwIpAddress=10.68 | gtpuPathSupint |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | sgwIpAddress=10.68 | gtpuPathSupint=60 |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=GTPU | sgwIpAddress=10.68 | gtpuPathSupint |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=destIpAddr |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=sgwIpAddress |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=gtpuPathSupint |
    ...
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}
    #${key_value_dict_keys}   set variable  ${key_value_dict.keys()}
    ${key_value_dict_keys}   evaluate  list(${key_value_dict})

    Run Keyword If  "scf_path" not in "${key_value_dict_keys}"   Fail  Should give scf_path parameter value!!!
    ${scf_path}     Set Variable  ${key_value_dict["scf_path"]}
    Remove From Dictionary   ${key_value_dict}   scf_path

    Run Keyword If   """distName""" in """${non_key_value_pair_list}"""    Remove Values From List   ${non_key_value_pair_list}   distName

    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${xpath}   _Create Xpath    ${non_key_value_pair_list}   ${key_value_dict}

    ${raml_version}   _Get raml version   ${scf_path}
    ${distName_list}   Get_Multi_DistName_By_Xpath_Filter   ${scf_content}   ${xpath}  raml_version=${raml_version}

    [Return]  ${distName_list}


_Get raml version
    [Arguments]  ${scf_path}
    ${line}   OperatingSystem.Grep File   ${scf_path}   <raml*xmlns=*>
    ${matches}  String.Get Regexp Matches   ${line}   .*\\sxmlns="(\\S+)"[\\s>].*   1
    ${raml_version}   Set Variable   ${matches[0]}

    [Return]  ${raml_version}

_Parse Input Parameter According To Seperator
    [Arguments]   ${seperator}    @{para_list}
    [Documentation]    _Parse Input Parameter According To Seperator
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | seperator | yes | seperator, eg, '='  |
    ...    | para_list | yes | dictionary, like 'key=value' pair format  |
    ...    *RETURN VALUE*
    ...    dictionary of parameter
    ...
    ...  Example
    ...  | ${para_list} | _Parse Input Parameter According To Seperator | = | key1=value1 | key2=value2 | key3=value3 | ... |
    ...  | ${para_list} | _Parse Input Parameter According To Seperator | = | ntpServerList=10.56.126.22 | ntpAlarmingThreshold=500 |
    ...  | ${para_list} | _Parse Input Parameter According To Seperator | = | ntpServerList=10.56.126.22 | ntpAlarmingThreshold=5 | distName=TNL-3 |

    @{non_key_value_pair_list}    create list
    &{key_value_dict}    Create Dictionary

    ${len}    Get Length    ${para_list}
    Run Keyword If   ${len}==0   Fail    There is no input parameter while calling this keyword!

    FOR    ${item}    IN    @{para_list}
        ${out}    Split String    ${item}    ${seperator}    1
        ${len}   Get Length   ${out}
        ${first}    Set Variable    ${out[0]}
        ${second}    Set Variable If    ${len}==1    ${EMPTY}
        ...    ${len}>=2 and '${out[1]}'=='${EMPTY}'    ${EMPTY}
        ...    ${len}>=2 and '${out[1]}'!='${EMPTY}'    ${out[1]}
        Run Keyword If   '${second}'=='${EMPTY}'   Append To List   ${non_key_value_pair_list}   ${first}
        Continue For Loop If   '${second}'=='${EMPTY}'
        &{tempdict}    Create Dictionary    ${first}    ${second}
        &{key_value_dict}    Create Dictionary    &{key_value_dict}    &{tempdict}
    END

    [Return]   ${non_key_value_pair_list}   ${key_value_dict}


Port Should Listen In VDU Container
    [Arguments]   ${port_list}     ${ctr_abbr}    ${pod_abbr}=${EMPTY}   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Port Should Listen In VDU Container
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   28.4.2022,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...   | Input Parameters | Man. | Description |
    ...   | port_list  |  yes  |  port_list, please see example   |
    ...   | pod_abbr | No. | the pod name abbreviation, do not give the full pod name. such as oamcm |
    ...   | ctr_abbr | Yes. | the container name abbreviation. such as oamagent, oamcm |
    ...   | gnb_index | No. | the gnb index, default value is 0. |
    ...   | vdu_index | No. | the vdu index, default value is 0. |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | ${port_list} |  Create List |  8080 |
    ...    | Port Should Listen In VDU Container |  port_list=${port_list} |  ctr_abbr=oamagent |
    ...
    ${alias}  Get Unique Id
    Connect To VDU Container With Tenant Interactively  pod_abbr=${pod_abbr}  ctr_abbr=oamagent  alias=${alias}
    ...   gnb_index=${gnb_index}    vdu_index=${vdu_index}

    FOR  ${port}  IN  @{port_list}
        ${out}   issh.Execute   command=netstat -anp|grep ":${port}" |grep LISTEN  check_result=${False}  alias=${alias}
        Should Contain   ${out}   :${port}  Port ${port} is not listening in ${pod_abbr}:${ctr_abbr} !
    END


Port Should Listen In VCU Container
    [Arguments]   ${port_list}     ${ctr_abbr}    ${pod_abbr}=${EMPTY}   ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    [Documentation]   Port Should Listen In VCU Container
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   28.4.2022,chris.l.cao@nokia-sbell.com, initialization version
    ...
    ...   | Input Parameters | Man. | Description |
    ...   | port_list  |  yes  |  port_list, please see example   |
    ...   | pod_abbr | No. | the pod name abbreviation, do not give the full pod name. such as oamcm |
    ...   | ctr_abbr | Yes. | the container name abbreviation. such as oamagent, oamcm |
    ...   | gnb_index | No. | the gnb index, default value is 0. |
    ...   | vdu_index | No. | the vdu index, default value is 0. |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | ${port_list} |  Create List |  8080 |
    ...    | Port Should Listen In VCU Container |  port_list=${port_list} |  ctr_abbr=oamagent |
    ...
    ${alias}  Connect To VCU Container With Tenant Interactively  pod_abbr=${pod_abbr}  ctr_abbr=oamagent  gnb_index=${gnb_index}

    FOR  ${port}  IN  @{port_list}
        ${out}   issh.Execute   command=netstat -anp|grep ":${port}" |grep LISTEN  check_result=${False}  alias=${alias}
        Should Contain   ${out}   :${port}  Port ${port} is not listening in ${pod_abbr}:${ctr_abbr} !
    END
