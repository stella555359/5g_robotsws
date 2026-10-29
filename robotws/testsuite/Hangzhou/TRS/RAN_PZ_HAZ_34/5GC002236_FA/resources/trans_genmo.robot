*** Settings ***
Documentation
...   author: chris.l.cao@nokia-sbell.com
...   contact: chris.l.cao@nokia-sbell.com
...   common MO keyword

Resource    trans_comm.robot

*** Variables ***
#default Value Is Set In KW '_Set Default Parameter Value For Dictionary'
@{RESERVED_PARAMETER_NAME}    operation    distName_index   VM_name    ETHIF_index    MNLENT_index
...                          MNLENT_index


&{MO_PMTNL_DEBUG}    bridgePortStatisticsInterval=Bridge port statistics measurement interval

#&{MO_PMTNL}   bridgePortStatisticsInterval=Bridge port statistics measurement interval
#        ...   ethernetInterfaceStatisticsInterval=Ethernet interface statistics measurement interval
#        ...   ethernetLinkInterval=Ethernet link measurement interval
#        ...   firstLevelSchedulerStatisticsInterval=First level scheduler statistics measurement interval
#        ...   ipFilteringInterval=IP filtering measurement interval
#        ...   ipInterfaceStatisticsInterval=IP interface statistics measurement interval
#        ...   ipNodeStatisticsInterval-IP node measurement interval
#        ...   ipPerHopBehaviourStatisticsInterval=IP interface PHB statistics measurement interval
#        ...   ipSecSaStatisticsInterval=IPSec SA statistics measurement interval
#        ...   ipSecStatisticsInterval=IPSec statistics measurement interval
#        ...   ipV4AddressStatisticsInterval=IP V4 address statistics measurement interval
#        ...   ipV4InterfaceStatisticsInterval=IP V4 statistics measurement interval
#        ...   ipV4RxPerHopBehaviourStatisticsInterval=IP V4 Rx interface per hop behaviour statistics measurement interval
#        ...   ipV4TxPerHopBehaviourStatisticsInterval=IP V4 Tx interface per hop behaviour statistics measurement interval
#        ...   ipV6AddressStatisticsInterval=IP V6 address statistics measurement interval
#        ...   pV6InterfaceStatisticsInterval=IP V6 interface statistics measurement interval
#        ...   ipV6RxPerHopBehaviourStatisticsInterval=IP V6 Rx interface per hop behaviour statistics measurement interval
#        ...   ipV6TxPerHopBehaviourStatisticsInterval=IP V6 Tx interface per hop behaviour statistics measurement interval
#        ...   sctpStatisticsInterval=SCTP statistics measurement interval
#        ...   secondLevelSchedulerStatisticsInterval=Second level scheduler statistics measurement interval
#        ...   tcpUdpStatisticsInterval=TCP UDP statistics measurement interval
#        ...   vlanStatisticsInterval=VLAN interface statistics measurement interval

&{MO_PMTNL}   bridgePortStatisticsInterval=Bridge port statistics measurement interval
        ...   ethernetInterfaceStatisticsInterval=Ethernet interface statistics measurement interval
        ...   ethernetLinkInterval=Ethernet link measurement interval
        ...   firstLevelSchedulerStatisticsInterval=First level scheduler statistics measurement interval
        ...   ipFilteringInterval=IP filtering measurement interval
        ...   ipInterfaceStatisticsInterval=IP interface statistics measurement interval
        ...   ipNodeStatisticsInterval=IP node measurement interval
        ...   ipPerHopBehaviourStatisticsInterval=IP interface PHB statistics measurement interval
        ...   ipSecSaStatisticsInterval=IPSec SA statistics measurement interval
        ...   ipSecStatisticsInterval=IPSec statistics measurement interval
        ...   ipV4AddressStatisticsInterval=IP V4 address statistics measurement interval
        ...   ipV4RxPerHopBehaviourStatisticsInterval=IP V4 Rx interface per hop behaviour statistics measurement interval
        ...   ipV4TxPerHopBehaviourStatisticsInterval=IP V4 Tx interface per hop behaviour statistics measurement interval
        ...   ipV6AddressStatisticsInterval=IP V6 address statistics measurement interval
        ...   ipV6RxPerHopBehaviourStatisticsInterval=IP V6 Rx interface per hop behaviour statistics measurement interval
        ...   ipV6TxPerHopBehaviourStatisticsInterval=IP V6 Tx interface per hop behaviour statistics measurement interval
        ...   sctpStatisticsInterval=SCTP statistics measurement interval
        ...   secondLevelSchedulerStatisticsInterval=Second level scheduler statistics measurement interval
        ...   tcpUdpStatisticsInterval=TCP UDP statistics measurement interval
        ...   vlanStatisticsInterval=VLAN interface statistics measurement interval


&{MO_PMCADM}   reportingIntervalPm=Performance measurement data reporting interval
        ...    sdlPrimaryDestIp=SDL primary destination IP address
        ...    sdlMaxUploadFileNumber=SDL maximum upload file number



*** Keyword ***
Configure PMTNL MO
    [Arguments]    @{para_list}
    [Documentation]    Configure PMTNL MO
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | VM_name          |  yes |  VM_name, e.g, OAM, CES, CPIF,RAP, UES |
    ...    | interval       |  no |  disabled, 5min, 15min,etc. default is 5min  |
    ...    | ipV4AddressStatisticsInterval  |  no |  disabled, 15min,etc. default is 15min  |
    ...    | ipV6AddressStatisticsInterval  |  no |  disabled, 15min,etc. default is 15min  |
    ...    | activate_plan_despite_errors   | No | activate_plan_despite_errors, 'True' or 'False', the default is 'False' |
    ...    *RETURN VALUE*
    ...    Example
    ...    |  Configure PMTNL MO | VM_name=OAM | interval=5min  |
    ...    |  Configure PMTNL MO | VM_name=OAM | interval=5min  | operation=update | activate_plan_despite_errors=True |
    ...    |  Configure PMTNL MO | VM_name=OAM | interval=5min  | operation=update |  ipV4AddressStatisticsInterval=15min |
    ${para_dict_keys}   ${para_dict}    Create Dictionary From List Parameter    @{para_list}
    Should Be True   "distName_index" in ${para_dict_keys}
    Should Be True   "operation" in ${para_dict_keys}
    Should Be True   "VM_name" in ${para_dict_keys}

    ${distName_index}   Set Variable    ${para_dict["distName_index"]}
    ${interval}   Set Variable If  "interval" in ${para_dict_keys}    ${para_dict["interval"]}   5min
    ${ipV4AddressStatisticsInterval_interval}   Set Variable If  "ipV4AddressStatisticsInterval" in ${para_dict_keys}
    ...   ${para_dict["ipV4AddressStatisticsInterval"]}   15min
    ${ipV6AddressStatisticsInterval_interval}   Set Variable If  "ipV6AddressStatisticsInterval" in ${para_dict_keys}
    ...   ${para_dict["ipV6AddressStatisticsInterval"]}   15min
    ${activate_plan_despite_errors}   Set Variable If  "activate_plan_despite_errors" in ${para_dict_keys}
    ...   ${para_dict["activate_plan_despite_errors"]}   False

    ${TNL_number}   Get TNL Number   vm=${para_dict["VM_name"]}
    ${distname}     Set Variable     ${ROOT_CLASS_NAME}-${DU_BTS_ID}/TNLSVC-1/TNL-${TNL_number}/PMTNL-${distName_index}

    FOR  ${key}  IN  @{MO_PMTNL.keys()}
        #continue for loop if  '${key}'=='ipV4AddressStatisticsInterval' or '${key}'=='ipV6AddressStatisticsInterval'
        ${filter_param}   Set Variable  ${MO_PMTNL["${key}"]}
        Log To Console  filter_name:${filter_param}
        Log To Console  abbr:${key}
        ${real_interval}   Set Variable If  '${key}'=='ipV4AddressStatisticsInterval'    ${ipV4AddressStatisticsInterval_interval}
        ...   '${key}'=='ipV6AddressStatisticsInterval'    ${ipV6AddressStatisticsInterval_interval}
        ...   ${interval}
        run keyword and continue on failure    selenium_coam.Set_Parameter_Value    dist_name=${distname}   filter_param=${filter_param}
        ...    new_value=${real_interval}
        ...   timeout=90
    END

    Validate And Activate Plan   activate_plan_despite_errors=${activate_plan_despite_errors}


Configure PMCADM MO
    [Arguments]    @{para_list}
    [Documentation]   Configure PMCADM MO
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | VM_name          |  yes |  VM_name, e.g, OAM, CES, CPIF,RAP, UES |
    ...    | distName_index   |  no |  distName_index, default is 1 |
    ...    | reportingIntervalPm  |  no |  5min, 15min,etc.  |
    ...    | sdlPrimaryDestIp  |  no |  ip address  |
    ...    | sdlMaxUploadFileNumber  |  no |  sdlMaxUploadFileNumber  |
    ...    | activate_plan_despite_errors   | No | activate_plan_despite_errors, 'True' or 'False', the default is 'False' |
    ...    *RETURN VALUE*
    ...    Example
    ...    |  Configure PMCADM MO | VM_name=OAM | reportingIntervalPm=5min |
    ...    |  Configure PMCADM MO | VM_name=OAM | reportingIntervalPm=5min | sdlPrimaryDestIp=1.1.1.1 | activate_plan_despite_errors=True |
    ${para_dict_keys}   ${para_dict}    Create Dictionary From List Parameter    @{para_list}
    Should Be True   "distName_index" in ${para_dict_keys}
    Should Be True   "operation" in ${para_dict_keys}
    Should Be True   "VM_name" in ${para_dict_keys}

    ${distName_index}   Set Variable    ${para_dict["distName_index"]}
    ${activate_plan_despite_errors}   Set Variable If  "activate_plan_despite_errors" in ${para_dict_keys}
    ...   ${para_dict["activate_plan_despite_errors"]}   False

    ${distname}     Set Variable     ${ROOT_CLASS_NAME}-${DU_BTS_ID}/MNL-1/MNLENT-${DU_MNLENT}/PMCADM-${distName_index}

    ${need_changed_para}   Get Intersection List    list1=${MO_PMCADM}    list2=${para_dict.keys()}
    Should Not Be Empty   ${need_changed_para}

    FOR  ${key}  IN  @{need_changed_para}
        ${filter_param}   Set Variable  ${MO_PMCADM["${key}"]}
        Log To Console  filter_name:${filter_param}
        Log To Console  abbr:${key}
        ${new_value}   Set Variable  ${para_dict["${key}"]}
        selenium_coam.Set_Parameter_Value    dist_name=${distname}   filter_param=${filter_param}     new_value=${new_value}
        ...   timeout=90
    END

    Validate And Activate Plan   activate_plan_despite_errors=${activate_plan_despite_errors}


Validate And Activate Plan
    [Arguments]  ${activate_plan_despite_errors}=False
    ${validate_times}   Set Variable If  ${TRANS_DBG}==1   1x   2x
    Wait Until Keyword Succeeds    1x   5s   selenium_coam.Validate_Plan
    Sleep   2
    ${error}    selenium_coam.Get_Definition_Errors
    Should Be Empty    ${error}
    ${error}    selenium_coam.Get_Relation_Errors
    Should Be Empty    ${error}
    Sleep  1

    Wait Until Keyword Succeeds    ${validate_times}   1s   selenium_coam.Activate_Plan
    ...                                                     activate_plan_despite_errors=${activate_plan_despite_errors}



Create Dictionary From List Parameter
    [Arguments]    @{para}
    [Documentation]    return dictionary of parameter.
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | para | No | dictionary, like 'key=value' pair format  |
    ...    *RETURN VALUE*
    ...    dictionary of parameter
    ...    Example
    ...   | ${para_dict} |  Create Dictionary From List Parameter | key1=value1 | key2=value2 | key3=value3 | ... |
    ...   | ${para_dict} |  Create Dictionary From List Parameter | ntpServerList=10.56.126.22 | ntpAlarmingThreshold=500 | operation=update |

    @{rtndict_keys}    create list
    &{rtndict}    Create Dictionary

    ${len}    Get Length    ${para}
    ${para}  Run Keyword If   ${len}==0   Create List   operation=update
    ...  ELSE   set variable   ${para}

    _Check Parameter Is Valid For Creating Dictionary    @{para}
    FOR    ${item}    IN    @{para}
        Log    ${item}
        &{temp}    _Create Dictionary For Key And Val    ${item}
        &{rtndict}    Create Dictionary    &{rtndict}    &{temp}
    END
    ${temp_keys}   Set Variable   ${rtndict.keys()}

    FOR   ${reserved_para}   IN   @{RESERVED_PARAMETER_NAME}
        Run Keyword If  "${reserved_para}" not in """${temp_keys}"""   _Set Default Parameter Value For Dictionary
        ...   dict_name=${rtndict}   para_name=${reserved_para}
    END

    ${rtndict_keys}   Set Variable   ${rtndict.keys()}
    [Return]   ${rtndict_keys}   ${rtndict}


_Set Default Parameter Value For Dictionary
    [Arguments]   ${dict_name}   ${para_name}
    Run Keyword If  'operation'=='${para_name}'   Set To Dictionary   ${dict_name}   operation   update
    ...   ELSE IF   'VM_name'=='${para_name}'   set to dictionary   ${dict_name}   VM_name   OAM
    ...   ELSE      set to dictionary   ${dict_name}    ${para_name}    1


_Create Dictionary For Key And Val
    [Arguments]    ${key_and_val}
    ${first}    ${rest}    Split String    ${key_and_val}    =    1
    &{rtndict}    Create Dictionary    ${first}    ${rest}
    [Return]    &{rtndict}


_Check Parameter Is Valid For Creating Dictionary
    [Arguments]    @{para}
    FOR    ${item}    IN    @{para}
        ${first}    ${rest}    Split String    ${item}    =    1
        Should Not Be Empty    ${first}
        Should Not Be Empty    ${rest}
    END


Get MRBTS ID
    [Arguments]  ${scf_path}=${None}
    ${rtn}  Set Variable  ${EMPTY}
    ${scf_path}   Run Keyword If  '${scf_path}'=='${None}'   REST Get SCF File
      ...   ELSE   set variable  ${scf_path}

    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}    Get_Regexp_Matches    ${scf_content}   .*MRBTS"\\s+distName="MRBTS-(\\d+)"\\s+.*   1
    ${rtn}  Set Variable If  ${result}   ${result[0]}
    [Return]  ${rtn}


Get NRBTS ID
    [Arguments]  ${scf_path}=${None}
    ${rtn}  Set Variable  ${EMPTY}
    ${scf_path}   Run Keyword If  '${scf_path}'=='${None}'   REST Get SCF File
      ...   ELSE   set variable  ${scf_path}

    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}    Get_Regexp_Matches    ${scf_content}   .*NRBTS"\\s+distName="MRBTS-\\d+/NRBTS-(\\d+)"\\s+.*   1
    ${rtn}  Set Variable If  ${result}   ${result[0]}
    [Return]  ${rtn}


Get MRBTS Version
    [Arguments]  ${scf_path}=${None}
    ${rtn}  Set Variable  ${EMPTY}
    ${scf_path}   Run Keyword If  '${scf_path}'=='${None}'   REST Get SCF File
      ...   ELSE   set variable  ${scf_path}

    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}    Get_Regexp_Matches    ${scf_content}   .*MRBTS"\\s+distName="MRBTS-\\d+"\\s+version="(\\S+)"\\s+.*   1

    ${rtn}  Set Variable If  ${result}   ${result[0]}
    [Return]  ${rtn}


Get NRBTS Version
    [Arguments]  ${scf_path}=${None}
    ${rtn}  Set Variable  ${EMPTY}
    ${scf_path}   Run Keyword If  '${scf_path}'=='${None}'   REST Get SCF File
      ...   ELSE   set variable  ${scf_path}

    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}    Get_Regexp_Matches    ${scf_content}   .*NRBTS"\\s+distName="MRBTS-\\d+/NRBTS-\\d+"\\s+version="(\\S+)"\\s+.*   1
    ${rtn}  Set Variable If  ${result}   ${result[0]}
    [Return]  ${rtn}


Get EQM Version
    [Arguments]  ${scf_path}=${None}
    ${rtn}  Set Variable  ${EMPTY}
    ${scf_path}   Run Keyword If  '${scf_path}'=='${None}'   REST Get SCF File
      ...   ELSE   set variable  ${scf_path}

    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}    Get_Regexp_Matches    ${scf_content}   .*EQM"\\s+distName="MRBTS-\\d+/EQM-\\d+"\\s+version="(\\S+)"\\s+.*   1
    ${rtn}  Set Variable If  ${result}   ${result[0]}
    [Return]  ${rtn}


Get MNL Version
    [Arguments]  ${scf_path}=${None}
    ${rtn}  Set Variable  ${EMPTY}
    ${scf_path}   Run Keyword If  '${scf_path}'=='${None}'   REST Get SCF File
      ...   ELSE   set variable  ${scf_path}

    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}    Get_Regexp_Matches    ${scf_content}   .*MNL"\\s+distName="MRBTS-\\d+/MNL-\\d+"\\s+version="(\\S+)"\\s+.*   1
    ${rtn}  Set Variable If  ${result}   ${result[0]}
    [Return]  ${rtn}


Get TNL Version
    [Arguments]  ${scf_path}=${None}
    ${rtn}  Set Variable  ${EMPTY}
    ${scf_path}   Run Keyword If  '${scf_path}'=='${None}'   REST Get SCF File
      ...   ELSE   set variable  ${scf_path}

    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}    Get_Regexp_Matches    ${scf_content}   .*TNLSVC"\\s+distName="MRBTS-\\d+/TNLSVC-\\d+"\\s+version="(\\S+)"\\s+.*   1
    ${rtn}  Set Variable If  ${result}   ${result[0]}
    [Return]  ${rtn}


Get Intersection List
    [Arguments]    ${list1}    ${list2}
    ${set1}   Evaluate  set(${list1})
    ${set2}   Evaluate  set(${list2})
    ${list3}   Evaluate  list(${set1.intersection(${set2})})

    [Return]  ${list3}


REST Get SCF File
    [Arguments]  ${alias}=default
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU
    Rest Login DU
    ${scf_dir}   Get A Directory  scf
    ${scf_file}  Get A File   ${scf_dir}  tmpscf.xml
    Get_Current_Scf_File  local_dir_path=${scf_dir}    file_name=${scf_file}  connection=${alias}
    [Return]  ${scf_file}


_Parse Input Parameter According To Seperator
    [Arguments]    ${para_list}
    [Documentation]    _Parse Input Parameter According To Seperator
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | like 'key=value' pair format, or a single key like 'key'  |
    ...    *RETURN VALUE*
    ...   a list of single key, and a dictionary of parameter for 'key=value parameter
    ...    Example
    ...   | ${list1} | ${dict} | _Parse Input Parameter According To Seperator | key1=value1 | key2=value2 | key3=value3 | ... |
    ...   | ${list1} | ${dict} | _Parse Input Parameter According To Seperator | ntpServerList=10.56.126.22 | ntpAlarmingThreshold=500 |
    ...   | ${list1} | ${dict} | _Parse Input Parameter According To Seperator | ntpServerList=1.1.1.1 | key1=500 | distName=TNL-5 | key2 |
    @{non_key_value_pair_list}    create list
    &{key_value_dict}    Create Dictionary

    ${len}    Get Length    ${para_list}
    Return From Keyword If   ${len}==0      ${non_key_value_pair_list}   ${key_value_dict}

    ${seperator}   Set Variable  =
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


Get MO DistName
    [Arguments]   ${para_list}
    [Documentation]   Get MO distName.  It supports multi-parameters filtering and distName filtering.
    ...    When using key=value format, the '=' means 'contain',  e.g, distName=TNL-4 means 'distName' contain 'TNL-4',
    ...    sgwIpAddress=10.68  means 'sgwIpAddress' contain '10.68'
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list  | Yes |  please see samples |
    ...    *RETURN VALUE*
    ...    Return distName that matched the parameters filter.
    ...    Example
    ...    | ${para_list} | create list | targetDNType=RAP |
    ...    | ${para_list} | create list | btsProfile       |
    ...    | ${para_list} | create list | destIpAddr=10.68 | distName=TNL-4 |
    ...    | ${para_list} | create list | sgwIpAddress=10.68 | gtpuPathSupint |
    ...    | ${para_list} | create list | sgwIpAddress=10.68 | gtpuPathSupint=60 |
    ...    | ${para_list} | create list | gtpuPathSupint | sgwIpAddress=10.68 | distName=GTPU |
    ...    | ${para_list} | create list | gtpuPathSupint | sgwIpAddress=10.68 | distName=GTPU | scf_path=myscf_file |
    ...    | ${distName} |  Get MO distName | para_list=${para_list} |

    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator     para_list=${para_list}
    ${key_value_dict_keys}   Set Variable  ${key_value_dict.keys()}

    Run Keyword If   """distName""" in """${non_key_value_pair_list}"""    Remove Values From List   ${non_key_value_pair_list}   distName
    ${scf_path}  Run Keyword If  "scf_path" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["scf_path"]}
    ...   ELSE   set variable  ${DU_SCF_BACKUP_FILE}

    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${xpath1}   Create Xpath For PM    non_key_value_pair_list=${non_key_value_pair_list}   key_value_dict=${key_value_dict}
    ${distName}   Get_DistName_By_Xpath_Filter   scf_content=${scf_content}   xpath=${xpath1}

    [Return]  ${distName}



Get Multiple MO DistName
    [Arguments]   ${para_list}
    [Documentation]   Get MO distName.  It supports multi-parameters filtering and distName filtering.
    ...    When using key=value format, the '=' means 'contain',  e.g, distName=TNL-4 means 'distName' contain 'TNL-4',
    ...    sgwIpAddress=10.68  means 'sgwIpAddress' contain '10.68'
    ...    *AUTHOR* chris.l.cao@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list  | Yes |  please see samples |
    ...    *RETURN VALUE*
    ...    Return distName that matched the parameters filter.
    ...    Example
    ...    | ${para_list} | create list | targetDNType=RAP |
    ...    | ${para_list} | create list | btsProfile       |
    ...    | ${para_list} | create list | destIpAddr=10.68 | distName=TNL-4 |
    ...    | ${para_list} | create list | sgwIpAddress=10.68 | gtpuPathSupint |
    ...    | ${para_list} | create list | sgwIpAddress=10.68 | gtpuPathSupint=60 |
    ...    | ${para_list} | create list | gtpuPathSupint | sgwIpAddress=10.68 | distName=GTPU |
    ...    | ${para_list} | create list | gtpuPathSupint | sgwIpAddress=10.68 | distName=GTPU | scf_path=myscf_file |
    ...    | ${distName} |  Get MO distName | para_list=${para_list} |

    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator     para_list=${para_list}
    ${key_value_dict_keys}   Set Variable  ${key_value_dict.keys()}

    Run Keyword If   """distName""" in """${non_key_value_pair_list}"""    Remove Values From List   ${non_key_value_pair_list}   distName
    ${scf_path}  Run Keyword If  "scf_path" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["scf_path"]}
    ...   ELSE   set variable  ${DU_SCF_BACKUP_FILE}

    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${xpath1}   Create Xpath For PM    non_key_value_pair_list=${non_key_value_pair_list}   key_value_dict=${key_value_dict}
    ${distName}   Get_Multi_DistName_By_Xpath_Filter   scf_content=${scf_content}   xpath=${xpath1}

    [Return]  ${distName}


Create Xpath For PM
    [Arguments]    ${non_key_value_pair_list}   ${key_value_dict}
    ${tmp_non_key_value_pair_list}   Copy List   ${non_key_value_pair_list}
    ${tmp_key_value_dict}   Copy Dictionary   ${key_value_dict}
    ${len1}   Get Length  ${tmp_non_key_value_pair_list}
    ${len2}   Get Length  ${key_value_dict}
    Should Not Be True  ${len1}==0 and ${len2}==0

    ${contain_list}   Create List

    #handle Non_Key_Value_Pair_List
    Run Keyword If   ${len1}>=1   Create Xpath For PM Contain List   contain_list=${contain_list}    para_list=${tmp_non_key_value_pair_list}

    #handle Key_Value_Dict
    @{key_list}   set variable    ${tmp_key_value_dict.keys()}
    FOR    ${i}   IN     @{key_list}
        Continue For Loop If   '${i}'=='distName'
        ${key}  Set Variable   ${i}
        ${value}   Set Variable   ${key_value_dict["${i}"]}
        #append To List    ${contain_list}    descendant::ns:${tag_name}/@name="${key}" and descendant::ns:${tag_name}[contains(text(),"${value}")]
        Append To List  ${contain_list}  descendant::ns:*[local-name()='p' or local-name()='list'][@name="${key}" and contains(text(),"${value}")]
    END

    #handle 'distName' In Key_Value_Dict
    Run Keyword If    """distName""" in """${key_value_dict.keys()}"""
    ...      append to list    ${contain_list}   contains(@distName, "${key_value_dict["distName"]}")

    ${xpath}   Catenate   SEPARATOR=${SPACE}and${SPACE}      @{contain_list}
    ${xpath}   Set Variable   .//ns:managedObject[${xpath}]
    [Return]   ${xpath}



Create Xpath For PM Contain List
    [Arguments]     ${contain_list}    ${para_list}
    FOR   ${i}    IN    @{para_list}
         #append To List    ${contain_list}   descendant::ns:${tag_name}/@name="${i}"
         Append To List    ${contain_list}    descendant::ns:*[local-name()='p' or local-name()='list']/@name="${i}"
    END



Delete MO IPIF
    [Arguments]  ${distName_index}=2
    ${dist_name}    Set Variable  MRBTS-${DU_BTS_ID}/TNLSVC-1/TNL-${DU_TNL_OAM}/IPNO-1/IPIF-2
    ${para}  Create List  distName=${dist_name}    interfaceDN
    ${all_distName}     Get Multiple MO DistName   para_list=${para}
    ${len}  Get Length    ${all_distName}
    Return From Keyword If  ${len}==0
    Run Keyword If    ${len}>=2   Fail
    Delete One MO    ${dist_name}


Delete MO VLANIF
    [Arguments]  ${distName_index}=1
    ${dist_name}    Set Variable  MRBTS-${DU_BTS_ID}/TNLSVC-1/TNL-${DU_TNL_OAM}/ETHSVC-1/ETHIF-1/VLANIF-1
    ${para}  Create List  distName=${dist_name}
    ${all_distName}     Get Multiple MO DistName   para_list=${para}
    ${len}  Get Length    ${all_distName}
    Return From Keyword If  ${len}==0
    Run Keyword If    ${len}>=2   Fail
    Delete One MO    ${dist_name}


Delete One MO
    [Arguments]  ${dist_name}
    ${para_list}  Create List
    ${mo_dict}       coam.Perform_Object_Recommissioning    dist_name=${dist_name}
    ...                                         parameter=${para_list}
    ...                                         operation=delete
    ...                                         skip_parameter_relation_errors=${BOOLEAN_TRUE}
    ...                                         should_activate=${BOOLEAN_TRUE}
