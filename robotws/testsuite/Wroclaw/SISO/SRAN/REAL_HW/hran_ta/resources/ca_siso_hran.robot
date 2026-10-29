*** Settings ***
Documentation
...  general resources

Library             taf.sbts.oam.coam.admin  WITH NAME  admin

Library             hran_bsc
Resource            ca_siso_general.robot



*** Keywords ***
#SiSo Check Active Alarms
#    [Documentation]
#    ...  Original KW -> Admin Check Active Alarms
#    ...  Original resource -> hran_admin.robot
#    ...
#    ...  ***NOTE*** Temporarly 'collect_snapshot' is inactive. KW 'SiSo Check Active Alarms' is going to be replaced
#    ...
#    ...  Alarms checking based on Admin. Fails if any expected alarm is missing or any critical alarm occurred.
#    ...  If collect_snapshot is set to True, snapshot is collected when active alarms are detected.
#    ...  If ${print_alarms} is set to True, KW will print lists of alarms with level:
#    ...  - ERROR - missed expected or found unexpected criticals
#    ...  - INFO - found expected and ignored
#    ...  - WARN - all other
#    ...
#    ...  | Parameter            | Man.  | Default | Description |
#    ...  | alias                | No    | default | alias of ute_admin instance |
#    ...  | expected_patterns    | No    | empty   | List of expected alarms regex patterns, one for each expected alarm |
#    ...  | ignored_patterns     | No    | empty   | List of ignored alarms regex patterns, will be used multiply  |
#    ...  | critical_patterns    | No    | empty   | List of critical alarms regex patterns, will be used multiply  |
#    ...  | timeout              | No    | 90      | Timeout in seconds to wait for getting alarms from Admin |
#    ...  | print_alarms         | No    | true    | Boolean to decide whether output lists should be printed with proper level |
#    ...  | collect_snapshot     | No    | False   | collect snapshot if active alarms exist |
#    ...
#    ...  Each key from alarm dictionary can be used for comparison, but only the following are printed:
#    ...  faultName, faultId, severity, notifier (can be re-defined using &{SIMPLIFIED_ALARM})
#    ...
#    ...  1.  Example of KW used without any defined list - will always pass and print WARN if any alarm is found:
#    ...  Admin Check Active Alarms
#    ...
#    ...  2. Example of KW used with one expected alarm definition - will fail if this alarm does not occur,
#    ...  any other will be printed with WARN level:
#    ...  ${EXPECTED_ALARM1}=     Create Dictionary  faultId=49  notifier=/MRBTS-1/RAT-1/LTS-1/LNBTS_L-1/LNCEL_L-10660
#    ...  ${EXPECTED}=            Create List  ${EXPECTED_ALARM1}
#    ...  Admin Check Active Alarms  expected_patterns=${EXPECTED}
#    ...
#    ...  3. Example of KW used with one expected and one critical alarm definition - will fail if expected alarm does not occur,
#    ...  or any other alarm with faultID=49 occur, any other will be printed with WARN level:
#    ...  ${EXPECTED_ALARM1}=     Create Dictionary  faultId=49  notifier=/MRBTS-1/RAT-1/LTS-1/LNBTS_L-1/LNCEL_L-10660
#    ...  ${EXPECTED}=            Create List  ${EXPECTED_ALARM1}
#    ...  ${CRITICAL_ALARM1}=     Create Dictionary  faultId=49
#    ...  ${CRITICAL}=            Create List  ${CRITICAL_ALARM1}
#    ...  Admin Check Active Alarms  expected_patterns=${EXPECTED}  critical_patterns=${CRITICAL}
#
#    [Arguments]  ${alias}=default  ${expected_patterns}=@{EMPTY}  ${ignored_patterns}=@{EMPTY}
#    ...  ${critical_patterns}=@{EMPTY}  ${timeout}=90  ${print_alarms}=${TRUE}  ${collect_snapshot}=${FALSE}
#
#    ${globally_ignored_alarms}  Get Variable Value  ${GLOBALLY_IGNORED_ALARMS}  @{EMPTY}
#    Append To List  ${ignored_patterns}  @{globally_ignored_alarms}
#
#    ${active_alarms}  ute_admin.Get Active Alarms  timeout=${timeout}  alias=${alias}
#
#    Run Keyword If  not ${active_alarms}  Log To Console  No active alarms have been found.
#    ${found expected alarms}  ${not found expected alarms patterns}  ${found critical alarms}  ${found ignored alarms}
#    ...  ${found not classified alarms}  hran_alarms_analysis.Get Filtered Alarms  ${active_alarms}
#    ...  ${expected_patterns}  ${ignored_patterns}  ${critical_patterns}  ${SIMPLIFIED_ALARM}
#
#    Run Keyword If  ${print_alarms}  hran_alarms_analysis.Print Alarms  ${found expected alarms}
#    ...  ${not found expected alarms patterns}  ${found critical alarms}  ${found ignored alarms}
#    ...  ${found not classified alarms}  simplified_dictionary=${SIMPLIFIED_ALARM}
#
#    Run Keyword If  ${not found expected alarms patterns} or ${found critical alarms}  Fail  Alarm verification failed
#
#    [Return]  ${found not classified alarms}

SiSo Get bts_id and perform commissioning
    [Documentation]
    ...     Original KW -> Admin Get bts_id and perform commissioning
    ...     Original resource -> hran_admin.robot
    ...
    ...  Helper keyword for commissioning via ADMIN. KW gets btsId from ADMIN and passes
    ...  it into original ute-admin.Perform Commissioning KW.
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                      | Man. | Default | Description                                                                          |
    ...  | commissioning_path             | Yes  | empty   | Path to commissioning .xml file                                                      |
    ...  | skip_parameter_relation_errors | No   | true    | Boolean value: should parameter relation errors be skipped                           |
    ...  | timeout                        | No   | 600     | Timeout for commissioning procedure (scf load, reset trigger, wait for reconnection) |

    [Arguments]  ${commissioning_path}  ${skip_parameter_relation_errors}=${TRUE}  ${timeout}=600
    ${bts_id}=   SiSo Get BTS ID
    Log  Parameter bts_id: ${bts_id}                console=True
    Log  Commissioning via ADMIN will be performed  console=True
    admin.Perform Commissioning   ${bts_id}  ${commissioning_path}  skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                     timeout=${timeout}

SiSo Get BTS ID
    [Documentation]
    ...     Original KW -> Admin Get BTS ID
    ...     Original resource -> hran_admin.robot
    ...
    ...    Gets BTS ID
    ...    *AUTHOR*
    ...    alona.kulieshova@nokia.com
    ${bts_obj} =  admin.Get parameters for all  BTS
    ${bts_id} =  Convert To String  ${bts_obj[0].btsId}
    [Return]  ${bts_id}


SiSo Get IDs for all LTE cells
    [Documentation]
    ...     Original KW -> Admin Get IDs for all LTE cells
    ...     Original resource -> hran_admin.robot
    ...
    ...  Get ids for all lte cells
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.coml
    ...  | **Released with version:** 54.0
    ...
    ${lncel}=       admin.Get parameters for all  LNCEL
    ${cell_ids}=    Evaluate  [cell['id'] for cell in ${lncel} if 'IoT' not in cell['technology'] ]
    [Return]  ${cell_ids}


SiSo Get IDs for standalone IoT cells
    [Documentation]
    ...     Original KW -> Admin Get IDs for standalone IoT cells
    ...     Original resource -> hran_admin.robot
    ...  Get ids for all standalone iot cells
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** 56.0
    ...
    ${lncel}=           admin.Get parameters for all  LNCEL
    ${iot_standalone}=  Evaluate  [cell['id'] for cell in ${lncel} if 'IoT' in cell['technology'] ]
    [Return]  ${iot_standalone}

SiSo Get LTE CELL Ids list
    [Documentation]
    ...     Original KW -> Admin Get LTE CELL Ids list
    ...     Original resource -> hran_admin.robot
    ...  Helper keyword providing LTE cells Ids for FDD+TDD and IOT (inband, guardband and standalone) technologies .
    ...  KW is returning two lists for FDD+TDD and IOT cells Ids
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter             | Description               |
    ...  | LTE_CELL_IDS_LIST     | List of FDD+TDD cells Ids |
    ...  | LTE_IOT_CELL_IDS_LIST | List of IOT cells Ids     |

    [Arguments]  ${alias}=default
    ${CELL_ID_LIST}=  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}  alias=${alias}
    Sort List  ${CELL_ID_LIST}
    ${LTE_CELL_IDS_LIST}=  Create List
    ${LTE_IOT_CELL_IDS_LIST}=  Create List
    FOR  ${item}  IN  @{CELL_ID_LIST}
        ${CELL_PARAM_LIST}=  admin.Get Parameters For  LNCEL  ${item}  alias=${alias}
        ${CELL_technology_found}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_PARAM_LIST['technology']}
        ${CELL_cellTechnology_found}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_PARAM_LIST['nbIoTCell']['cellTechnology']}
        ${CELL_nbIoTMode_found}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_PARAM_LIST['nbIoTMode']}
        Run Keyword If  ${CELL_technology_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['technology']}'=='FDD' or '${CELL_PARAM_LIST['technology']}'=='TDD'
        ...  Append To List  ${LTE_CELL_IDS_LIST}  ${CELL_PARAM_LIST['id']}
        Run Keyword If  ${CELL_cellTechnology_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['nbIoTCell']['cellTechnology']}'=='NB-IoT-FDD'
        ...  Append To List  ${LTE_IOT_CELL_IDS_LIST}  ${CELL_PARAM_LIST['nbIoTCell']['distName']}
        Run Keyword If  ${CELL_technology_found} and ${CELL_nbIoTMode_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['technology']}'=='NB-IoT-FDD' and '${CELL_PARAM_LIST['nbIoTMode']}'=='standalone'
        ...  Append To List  ${LTE_IOT_CELL_IDS_LIST}  ${CELL_PARAM_LIST['id']}
    END
    Sort List  ${LTE_CELL_IDS_LIST}
    Sort List  ${LTE_IOT_CELL_IDS_LIST}

    [Return]  ${LTE_CELL_IDS_LIST}  ${LTE_IOT_CELL_IDS_LIST}

SiSo Get LTE CELL IOT mapping list
    [Documentation]
    ...     Original KW -> Admin Get LTE CELL IOT mapping list
    ...     Original resource -> hran_admin.robot
    ...  Helper keyword providing LTE cells information related to IOT mapping
    ...  KW is returning a dictionary described as beneath:
    ...  - key: LTE cell DN
    ...  - value: LTE IOT cell DN (if IOT activated) or None (if IOT not activated)
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description           |
    ...  | LTE_cell_IOT_mapping_dict | Dictionary of LTE cells mapping IOT feature |

    [Arguments]  ${alias}=default
    ${LTE_cell_ids}  ${LTE_IOT_cell_ids}=  SiSo Get LTE CELL Ids list  ${alias}
    Sort List  ${LTE_cell_ids}
    ${LTE_cell_IOT_mapping_dict}=  Create Dictionary
    FOR  ${item}  IN  @{LTE_cell_ids}
        ${cell_param_list}=  admin.Get Parameters For  LNCEL  ${item}  alias=${alias}
        ${key_exist}=  Run keyword and return status  Get From Dictionary  ${cell_param_list}  nbIoTMode
        ${value}=  Set Variable If
        ...  '${key_exist}' == 'False'  None
        ...  '${cell_param_list['nbIoTMode']}' == 'disabled'  None
        ...  '${cell_param_list['nbIoTMode']}' != 'disabled'  ${CELL_PARAM_LIST['nbIoTCell']['distName']}
        Set To Dictionary  ${LTE_cell_IOT_mapping_dict}  ${item}  ${value}
    END
    [Return]  ${LTE_cell_IOT_mapping_dict}

SiSo Get MPLANE IP
    [Documentation]
    ...     Original KW -> Admin Get MPLANE IP
    ...     Original resource -> hran_admin.robot
    ...    Get MPLANE IP
    ...
    ...    *AUTHOR*
    ...    andrzej.cichon@nokia.com
    ...
    ...    The parameter is called `btsMplane` in SBTS17A, and `btsMplaneIp4V` in SBTS18A (TAT-12793)
    ...
    ${bts_obj}=    admin.Get parameters for all    BTS
    ${bts_obj}=    Get From List    ${bts_obj}    0

    ${expected_keys}=    Create List    btsMplane    btsMplaneIp4V
    ${btsMplane_key}=    Evaluate    [key for key in ${bts_obj} if key in ${expected_keys}][0]

    ${mplane_ip}=    Get From Dictionary    ${bts_obj}    ${btsMplane_key}
    ${mplane_ip}=    Convert To String    ${mplane_ip}
    [Return]    ${mplane_ip}

SiSo Check mplane connection
    [Documentation]
    ...     Original KW -> Admin Check mplane connection
    ...     Original resource -> hran_admin.robot
    ...  Check mplane connection on admin
	...
	...  | **Author:** jaroslaw.piszczala@nokia.com
	...  | **Maintainer:** jaroslaw.piszczala@nokia.com
	...  | **Released with version:** 45.0
    ...
	...  **Input Parameters:**
	...
	...  +----------------+------+------------------+------------------------------------------------------------------+
	...  | Parameter name | Man. | Default          | Description                                                      |
	...  +================+======+==================+==================================================================+
	...  | bts_host       | no   | ${MPLANE_IP}     | BTS ip to connect, in default MPLANE_IP from node configuration  |
	...  +----------------+------+------------------+------------------------------------------------------------------+
	...  | bts_port       | no   | 443              | BTS port to connect                                              |
	...  +----------------+------+------------------+------------------------------------------------------------------+
	...  | use_ssl        | no   | TRUE             | SSL flag                                                         |
	...  +----------------+------+------------------+------------------------------------------------------------------+
	...  | timeout        | no   | 1 min            | Timeout for connection to admin                                  |
	...  +----------------+------+------------------+------------------------------------------------------------------+
	...  | alias          | no   | mplane           | Connection alias                                                 |
	...  +----------------+------+------------------+------------------------------------------------------------------+
	...
    [Arguments]  ${bts_host}=${MPLANE_IP}  ${bts_port}=443  ${use_ssl}=TRUE  ${timeout}=1 min  ${alias}=mplane
    Log  Check mplane connection on Admin  console=${TRUE}
    Log  Trying to connect to admin (max ${timeout})   level=INFO  console=${TRUE}
    ${admin_taf_started}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${timeout}  15 sec
    ...  admin.Setup Admin  admin_api_log_dir=${BTS Files}/coam_admin  bts_host=${bts_host}  bts_port=${bts_port}  use_ssl=${use_ssl}  name=${alias}
    Return From Keyword If  '${admin_taf_started}'=='False'  ${False}
    Log  Connection to admin via TAF with mplane (${bts_host}) successfully established!  level=INFO  console=${TRUE}

    ${BTS_statecheck_status}  ${BTS_state}  Run keyword and ignore error  admin.Get mrbts state  alias=${alias}
    Return from keyword if  '${BTS_statecheck_status}'=='PASS'  ${True}
    [Return]  ${False}
    [Teardown]  admin.Teardown Admin  connection=${alias}

SiSo Admin and Infomodel connections reset
    [Documentation]
    ...     Original KW -> Admin and Infomodel connections reset
    ...     Original resource -> hran_admin.robot
    ...  Helper KW for Admin and Infomodel connections reset based on following triggers:
    ...  - SOAMIF change
    ...  - Admin issues
    ...  - on demand
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man.  | Default | Description                                                         |
    ...  | reset_req | No    | False   | reset request for Admin and Infomodel connections, by default False |
    ...  | alias     | No    | default | alias of admin instance                                             |

    [Arguments]  ${reset_req}=${False}  ${alias}=default

    ${soamif_exception}=  Set Variable  Invalid soamIf version

    ${verdict}  ${result}=  Run Keyword And Ignore Error  admin.Get Mrbts State  timeout=60  alias=${alias}
    Run Keyword If  '${verdict}' == 'PASS' and '${reset_req}' == '${False}'  Run Keywords
    ...  Log  No need for Admin and Infomodel connections reset.  console=True
    ...  AND  Return From Keyword

    ${filepath}=  Set Variable If  '${alias}' == 'default'  ${BTSFiles}  ${BTSFiles}/${alias}
    ${soamif_change_check}=  Run Keyword And Return Status  Should Contain  ${result}  ${soamif_exception}
    Run Keyword If  ${reset_req}  Run Keywords
    ...  Log  Admin and Infomodel connections are being reset on demand  console=True
    ...  AND  admin.Reset Admin  connection=${alias}
    ...  AND  Sleep  3s
    ...  AND  Reset Infomodel  filename=${filepath}/InfoModel_untilReset.ims2  alias=${alias}
    ...  ELSE IF  ${soamif_change_check}  Run Keywords
    ...  Log  Admin and Infomodel connections are being reset due to Admin soamif change detected: ${result}  console=True
    ...  AND  admin.Reset Admin  connection=${alias}
    ...  AND  Sleep  3s
    ...  AND  Reset Infomodel  filename=${filepath}/InfoModel_untilReset.ims2  alias=${alias}
    ...  ELSE IF  '${verdict}' != 'PASS'  Run Keywords
    ...  Log  Admin and Infomodel connections are being reset due to Admin error: ${result}  console=True
    ...  AND  admin.Reset Admin  connection=${alias}
    ...  AND  Sleep  3s
    ...  AND  Reset Infomodel  filename=${filepath}/InfoModel_untilReset.ims2  alias=${alias}

    ${status}=  Run Keyword And Return Status  Get Mrbts State  timeout=60  alias=${alias}
    Run Keyword If  ${status}  Log  Admin and Infomodel connections are up after reset  console=True
    ...  ELSE  Fail  Admin and Infomodel connections are failed after reset

SiSo Admin Check Cells Number

    [Documentation]    Check if number cells detected by admin is as expected
    ...     Original KW -> Admin Check Cells Number
    ...     Original resource -> hran_admin.robot
    ...  *AUTHOR*
    ...  michal.kwasniewicz@nokia.com
    ...
    ...  | Parameter              | Mandatory     | Description                           |
    ...  | technology             | Yes           | Cell ID e.g: LNCEL, GNCEL or WNCEL    |
    ...  | expectted_cells_number | Yes           | Expected cells number                 |

    [Arguments]    ${technology}    ${expected_cells_number}
    Run keyword if  ${expected_cells_number}==-1  Run keywords
    ...  Log  ${technology} will be ignored for active software  console=${True}
    ...  AND  Return from keyword  ${True}
    ${id_list}=    Get Ids For All    ${technology}    search_for_iot_cells=${True}
    ${admin_cells_num}=    Evaluate    len(${id_list})
    Should Be Equal As Integers    ${expected_cells_number}    ${admin_cells_num}
    ...    Admin see different cells number than expected! Expected: ${expected_cells_number} is not equal admin cells num: ${admin_cells_num}.


SiSo Check IM log if BTS reset was triggered
    [Documentation]
    ...     Original KW -> Infomodel Check IM log if BTS reset was triggered
    ...     Original resource -> hran_infomodel.robot
    ...
    ...  KW for checking IM log for reset event occurence. It saves IM log for further processing under given path and
    ...  then validates it in context of reset. Returns true or false.
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com
    ...
    ...  | Parameter        | Man. | Description                                    |
    ...  | path_for_im_log  | Yes  | Absolute path under which IM log will be saved |
    ...
    ...  *RETURN*
    ...  | ${was_reset_present} | SiSo Check IM log if BTS reset was triggered | ${BTS Files}/IM/InfoModel_log_for_reset_check.ims2 |

    [Arguments]  ${path_for_im_log}
    Save infomodel log  ${path_for_im_log}  timeout=120
    Initialize ims2 validator  ${path_for_im_log}
    Add expected ims2 event  reset
    ${was_triggered}=  Run keyword and return status  Validate ims2
    [Return]  ${was_triggered}


SiSo Get Objects Parameter
  [Arguments]  ${objects_dist_name}  ${parameter}  ${allow_negative_result}=False
  [Documentation]
  ...     Original KW -> Infomodel Get Objects Parameter
  ...     Original resource -> hran_infomodel.robot
  ...
  ...  KW for obtaining list of values of one specified parameter for all InfoModel objects matching 'objects_dist_name'
  ...
  ...  *Author*: Tomasz Filipek
  ...
  ...  | Parameter             | Man. | Description |
  ...  | objects_dist_name     | Yes  | Objects dist_name complies with query_infomodel syntax |
  ...  | parameter             | Yes  | Parameters name |
  ...  | allow_negative_result | No   | Allow False to be returned instead of InfoModelQueryTimeoutException |
  ...
  ...  *RETURN*
  ...  | Parameter        | Description              |
  ...  | parameter_values | List of parameter values |
  ...
  ...  *EXAMPLE*
  ...  | ${parameter_values}= | SiSo Get Objects Parameter | //EQM_L-1//SMOD_L-* | serialNumber

  ${objects}=  Query Infomodel  get list ${objects_dist_name}  allow_negative_result=${allow_negative_result}
  ${parameter_values}=  Create List
  FOR  ${object}  IN  @{objects}
      Append To List  ${parameter_values}  ${object['${parameter}']}
  END
  [Return]  ${parameter_values}

SiSo Get bcfId
    [Tags]  Helper
    [Documentation]
    ...     Original KW -> Infomodel Get bcfId
    ...     Original resource -> hran_infomodel.robot
    ...  Returns bcfId value
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ...
    ...  *RETURN*
    ...  |  Parameters  |  Description  |
    ...  |  bcf         |  bcfID        |
    ...
    ...  *EXAMPLE*
    ...  | ${bcfid} =  | Infomodel Get bcfId  |
    ${bcf}=  Query infomodel  get object //GTS-*/BCF_L-*
    [Return]  ${bcf.bcfId}

#SiSo Log all Tx Power
#  [Documentation]
#  ...     Original KW -> Log all Tx Power
#  ...     Original resource -> hran_infomodel.robot
#  ...  Log TX Power for all radio modules
#  ...
#  ...  *Author*: Jaroslaw Piszczala
#  [Arguments]  ${print_to_report}=${True}
#    ${radio_distname_list}=  Query Infomodel  get list //RUNTIME_VIEW-*//RMOD_R-*
#    FOR  ${radio_distname}  IN  @{radio_distname_list}
#        ${ref_radio_object}=  Query Infomodel  get object ${radio_distname.dist_name}/REF-*
#        ${im_radio_object}=    Query Infomodel  get object ${ref_radio_object.distName}
#        Log  ${\n}TX-Power for ${im_radio_object.serialNumber}  console=${True}
#        ${im_module_object}=  Query Infomodel  get object ${im_radio_object.masterAgentDN}
#        ${module_address}  Set Variable If
#        ...  '${im_module_object.ipAddress}'=='192.168.255.7' and '474767A' in '${im_module_object.productCode}'
#        ...  fct-4a  ${im_module_object.ipAddress}
#        ${tx_power_dict}=  Get Tx Power  ${im_radio_object.ipAddress}  ${module_address}  ${im_radio_object.productName}
#        ...  print_to_report=${print_to_report}
#    END

_SiSo Get SW Version For SMOD
    [Arguments]    ${module}=MSM    ${im_param}=activeSoftwareVersion  ${alias}=default
    [Documentation]
    ...     Original KW -> _Get SW Version For SMOD
    ...     Original resource -> hran_infomodel.robot
    ${working_modes}=    Create Dictionary    MSM=Active    ESM=Idle    all=Active

    ${mode}=    Get From Dictionary    ${working_modes}    ${module}

    ${swm_objs}=    Query Infomodel    get list //RAT-1/SWM-* is [workingMode=${mode}]    allow_negative_result=${True}  alias=${alias}
    Return From Keyword If    not ${swm_objs}    ${EMPTY}

    ${sw_versions}=    Create List

    FOR    ${swm_obj}    IN    @{swm_objs}
        ${bts_l_dn}=    Set Variable    ${swm_obj.hardwareViewDNs[0]}
        ${bts_conf_obj}=    Query Infomodel    get object ${bts_l_dn}/BTS_CONF-1  alias=${alias}
        ${sw_version}=    Get From Dictionary    ${bts_conf_obj}    ${im_param}
        Append To List    ${sw_versions}    ${sw_version}
    END
    Return From Keyword If    '${module}'=='all'    ${sw_versions}  # return the whole list
    [Return]    ${sw_versions[0]}

SiSo Get Active SW Version
  [Arguments]    ${module}=MSM  ${im_param}=activeSoftwareVersion  ${alias}=default
  [Documentation]
  ...     Original KW -> Infomodel Get Active SW Version
  ...     Original resource -> hran_infomodel.robot
  ...  Return active software version for selected SMOD.
  ...
  ...  Mind that if there are two SMODs connected to a not commissioned BTS, KW will return:
  ...  - a list of SW versions for both SMODs if `module` is set to `MSM` or `all`
  ...  - an empty list if `module` is set to `ESM`
  ...  This results from both SMODs being marked in Infomodel as Active (i.e. master system module).
  ...
  ...  *PARAMETERS*
  ...   | =Parameter=       | =Man.= | =Description=                                                           | =Default=              |
  ...   | `module`          | no     | Determines from which SMOD the SW Version is obtained (MSM, ESM, all).  | MSM                    |
  ...   | 'im_param'        | no     | Determines which parameter should be taken to read active sw version    | activeSoftwareVersion  |
  ...   | `alias`           | no     | Determines alias in connection to infomodel                             | default                |
  ...
  ...  *RETURN VALUE*
  ...  - Active SW version
  ...
  ...    *AUTHOR*
  ...    andrzej.cichon@nokia.com
  ${sw_version}=    _SiSo Get SW Version For SMOD    module=${module}    im_param=${im_param}  alias=${alias}
  [Return]    ${sw_version}

SiSo Get Passive SW Version
  [Arguments]    ${module}=MSM  ${im_param}=passiveSoftwareVersion  ${alias}=default
  [Documentation]
  ...     Original KW -> Infomodel Get Passive SW Version
  ...     Original resource -> hran_infomodel.robot
  ...  Return passive software version
  ...  For more details, see documentation for `Infomodel Get Active SW Version`.
  ...
  ...  *PARAMETERS*
  ...   | =Parameter=       | =Man.= | =Description=                                                            | =Default=               |
  ...   | `module`          | no     | Determines from which SMOD the SW Version is obtained (MSM, ESM, all).   | MSM                     |
  ...   | 'im_param'        | no     | Determines which parameter should be taken to read passive sw version    | passiveSoftwareVersion  |
  ...   | `alias`           | no     | Determines alias in connection to infomodel                              | default                 |
  ...
  ...  *RETURN VALUE*
  ...  - Passive SW version
  ...
  ...    *AUTHOR*
  ...    andrzej.cichon@nokia.com
  ${sw_version}=    _SiSo Get SW Version For SMOD    module=${module}    im_param=${im_param}  alias=${alias}
  [Return]    ${sw_version}

Siso Check SW version
    [Documentation]
    ...     Original KW -> Check SW version
    ...     Original resource -> hran_infomodel.robot
    [Arguments]    ${step_number}  ${Pass If SW exists}=${False}  ${module}=MSM
    ...            ${im_param_active}=activeBuildDescriptorId  ${im_param_passive}=passiveBuildDescriptorId  ${alias}=default
    ${Active SW}   SiSo Get Active SW Version    module=${module}  im_param=${im_param_active}  alias=${alias}
    ${Passive SW}  SiSo Get Passive SW Version    module=${module}  im_param=${im_param_passive}  alias=${alias}
    Log  Active software package is: ${Active SW}  console=True
    Log  Passive software package is: ${Passive SW}  console=True
    ${SW Release Name}  hran_file_operations.Get TargetBD Node Attribute Value  softwareReleaseVersion  ${Target SW path}
    Run Keyword If  '${Passive SW}'==''  Log  Passive sw version was not readable  console=${TRUE}
    Run Keyword If  '${step_number}'=='2'  Run keywords
    ...  Set tags  SW_BEFORE_UPDATE_active-${Active SW}  SW_BEFORE_UPDATE_passive-${Passive SW}
    ...  AND  SiSo Check if SW already exists on BTS  ${SW Release Name}  ${Active SW}  ${Passive SW}  ${Pass If SW exists}
    Run Keyword If  '${step_number}'!='2'  Run keywords
    ...  Set tags  SW_AFTER_UPDATE_active-${Active SW}
    ...  AND  Set tags  SW_AFTER_UPDATE_passive-${Passive SW}
    ...  AND  Set test variable  ${TARGET_SW}  ${Active SW}
    ...  AND  Should Match Regexp  ${SW Release Name}  (?i).*${Active SW}(?!T[12]).*
    Run keyword if  '${Active SW}'=='?'  Run Keyword And Continue On Failure  Fail  Active sw version fetched from infomodel equals "?"

SiSo Get SW Versions
    [Arguments]    ${log_to_console}=${True}  ${module}=MSM  ${alias}=default
    [Documentation]
    ...     Original KW -> Infomodel Get SW Versions
    ...     Original resource -> hran_infomodel.robot
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    ...
  ...  *PARAMETERS*
  ...   | =Parameter=       | =Man.= | =Description=                                                                  | =Default= |
  ...   | `log_to_console`  | no     | Determines if log active and passive sw version to console is expected or not  | TRUE       |
  ...   | `module`          | no     | Determines from which SMOD the SW Version is obtained (MSM, ESM, all).         | MSM       |
  ...   | `alias`           | no     | Determines alias in connection to infomodel                                    | default   |

    ...  *RETURN VALUE*
    ...  :return:           list with active and passive SW
    ...
    ${activeSoftwareVersion}=   SiSo Get Active SW Version  ${module}  alias=${alias}
    ${passiveSoftwareVersion}=  SiSo Get Passive SW Version  ${module}  alias=${alias}
    Log  active SW: ${activeSoftwareVersion}  console=${log_to_console}
    Log  passive SW: ${passiveSoftwareVersion}  console=${log_to_console}
    [Return]  ${activeSoftwareVersion}  ${passiveSoftwareVersion}

SiSo get all DSPs dist names for given RAT
    [Documentation]
    ...     Original KW -> Infomodel get all DSPs dist names for given RAT
    ...     Original resource -> hran_infomodel.robot
    ...  KW for obtaining sorted list of DSPs distNames from IM
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com

    [Arguments]  ${rat}
    ${dsps_dist_names}=  Create list
    ${sw_entities_objects}=  Query Infomodel  get list //DSP_L-*/SOFTWARE_ENTITY-* is [rat="${rat}"]
    FOR  ${sw_entity}  IN  @{sw_entities_objects}
        Append to list  ${dsps_dist_names}  ${sw_entity['deviceDN']}
    END
    Sort list  ${dsps_dist_names}
    [Return]  ${dsps_dist_names}

SiSo check if DSPs were restarted according to ims file
    [Documentation]
    ...     Original KW -> Infomodel check if DSPs were restarted according to ims file
    ...     Original resource -> hran_infomodel.robot
    ...  KW checks given ims2 file (first argument) looking for DSPs restart event. All DSPs from given list (second
    ...  argument) are checked. User can use 'Save Infomodel Log' KW to obtain ims2 file and 'Infomodel get all DSPs dist names for given RAT'
    ...  to get DSPs list
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com
    ...
    ...  | Parameter      | Man. | Description                             |
    ...  | im_log_path    | Yes  | Path for Infomodel ims2 file            |
    ...  | dsp_dist_names | Yes  | List of DSPs dist names fetched from IM |

    [Arguments]  ${im_log_path}  ${dsp_dist_names}
    FOR  ${dsp_dist_name}  IN  @{dsp_dist_names}
        Initialize ims2 validator  ${im_log_path}
        Add expected ims2 event  change ${dsp_dist_name} [stateInfo.proceduralState: RoutingLoaded -> Resetting]
        Validate ims2
        Log  ${dsp_dist_name} was restarted  console=True
    END

SiSo check if cells in RAT were operational according to IM log
    [Documentation]
    ...     Original KW -> Infomodel check if cells in RAT were operational according to IM log
    ...     Original resource -> hran_infomodel.robot
    ...  Helper KW for checking if cells of given RAT remain operational according to IM log
    ...  AvailabilityStatus and operationalState from objects //CELL_M-* are checked.
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com

    [Arguments]  ${rat}  ${im_log_path}
    ${cells_objects}=  Query infomodel  get list ${dist_${rat}_cell}  allow_negative_result=True
    Log  Check ${rat} cells  console=True
    FOR  ${cell_object}  IN  @{cells_objects}
        Initialize ims2 validator  ${im_log_path}
        Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.availabilityStatus]
        Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.operationalState]
        Run keyword and expect error  InfoModelIms2ValidationException:*  Validate ims2
        Log  ${cell_object.dist_name} availabilityStatus and operationalState remained unchanged  console=True
    END
    Log  All ${rat} cells were operational according to IM log  console=True

SiSo Find path to SW package
  [Documentation]
  ...     Original KW -> Find path to SW package
  ...     Original resource -> hran_general.robot
    ${Target SW path}  SiSo Get SW file for SWDL  ${Target SW dir}  ${Target SW name}
    Run Keyword If  '${Target SW path}'== ${None}   Fail   msg=
    Set test variable  ${Target SW path}
    Log  Chosen software package is: ${Target SW path}  console=${True}

SiSo Get SW file for SWDL
    [Documentation]
    ...     Original KW -> Get SW file for SWDL
    ...     Original resource -> hran_general.robot
    ...  Verify given directory and return a path to the SW file (with given name or the newest in directory)
    ...
    ...	 *AUTHOR* tomasz.1.filipek@nokia.com
    [Arguments]  ${SW dir}  ${SW name}
    OperatingSystem.Directory should exist  ${SW dir}
    OperatingSystem.Directory should not be empty  ${SW dir}
    Run keyword and return if  '${SW name}'=='None'  hran_file_operations.get newest file from directory  ${SW dir}  *.zip
    ${SW path}=  Join Path 	${SW dir}  ${SW name}.zip
    OperatingSystem.File should exist  ${SW path}
    [Return]  ${SW path}

SiSo Check if SW already exists on BTS
    [Documentation]
    ...     Original KW -> Check if SW already exists on BTS
    ...     Original resource -> hran_general.robot
    ...  pass_if_exists=False or omitted: Fail if given SW already exists on BTS (active)
    ...  pass_if_exists=True: Immediately ends the test as passed if given SW already exists on BTS (active)
    ...
    ...  *AUTHOR* tomasz.1.filipek@nokia.com
    [Arguments]  ${target SW}  ${active SW}  ${passive SW}  ${pass_if_exists}=${False}
    ${target is passive}=  run keyword and return status  Should Match Regexp  ${target SW}  (?i).*${passive SW}(?!T[12]).*
    run keyword if  ${target is passive}  log  Target SW is the same as the passive
    ${target is active}=  run keyword and return status  Should Match Regexp  ${target SW}  (?i).*${active SW}(?!T[12]).*
    run keyword if  ${target is active} and ${pass_if_exists}  pass execution  Target SW is the same as the active
    run keyword if  ${target is active}  fail  Target SW is the same as the active

SiSo Log Step Header
    [Documentation]
    ...     Original KW -> Log Step Header
    ...     Original resource -> ca_swm_general.robot
    [Arguments]  ${message}
    Log  ${\n}==========================================================================================  console=${TRUE}
    Log  ${message}  console=${TRUE}
    Log  ==========================================================================================  console=${TRUE}

#SiSo Execute command on SM via SSH
#    [Documentation]
#    ...     Original KW -> Execute command on SM via SSH
#    ...     Original resource -> hran_general.robot
#    ...  Keyword opens connection to host machine via SSH. execute the given command and checks its return code. Command
#    ...  can be executed from localhost and from remote host.
#    ...
#    ...  *AUTHOR* patryk.furman@nokia.com
#    ...
#    ...  | Parameter            | Man. | Description                                            |
#    ...  | ip_address           | Yes  | IP address of host on which command should be executed |
#    ...  | command              | Yes  | Command to execute                                     |
#    ...  | remote_host          | No   | Remote host IP address (None as default)               |
#    ...  | remote_host_username | No   | Remote host username (None as default)                 |
#    ...  | remote_host_password | No   | Remote host password  (None as default)                |
#    ...
#    ...  *RETURN*
#    ...  | Parameters | Description    |
#    ...  | output     | Command output |
#    ...
#    ...  *EXAMPLE*
#    ...  | Execute command on SM via SSH | 192.168.255.1 | rm -rf /flash/config/PersDataFiles/SCFC_* |
#    ...
#    ...  | ${output}= | Execute command on SM via SSH | 192.168.255.5 | ls -la / | 10.42.35.166 | ute | ute |
#
#    [Arguments]  ${ip_address}  ${command}  ${remote_host}=${EMPTY}  ${remote_host_username}=${EMPTY}  ${remote_host_password}=${EMPTY}
#    hran_ssh.Set Connection Parameters  ${ip_address}  via_ip=${remote_host}  via_user=${remote_host_username}  via_password=${remote_host_password}
#    ${output}  ${rc}=  hran_ssh.Run Command  ${command}
#    Should Be Equal  ${rc}  ${0}  msg=${command} operation RC is not equal 0
#    [Return]  ${output}

#Siso Admin Check SBTS cells, modules and alarms
#    [Documentation]
#	...    Original KW -> Admin Check SBTS cells, modules and alarms
#    ...    Original resource -> hran_admin.robot
#    ...    Wrapper for methods used for system modules, radio modules, cells and alarms checking.
#    ...
#    ...    | **Author:** tomasz.1.filipek@nokia.com
#	...    | **Maintainer:** tomasz.1.filipek@nokia.com
#	...    | **Released with version:** 47.0
#	...
#	...    | **Full description:**
#	...    | Verification is done via ADMIN interface. Additionally modules SNs and amount of cells and HW is compared
#	...    | with SCF. User can pass alarm patterns which should be treat as critical or ignored. For patterns
#	...    | documentation, please refer to Admin Check Active Alarms KW
#	...
#	...    **Input Parameters:**
#	...
#	...    +--------------------+------+------------+----------------------------------------------------------------------------+
#    ...    | Parameter name     | Man. | Default    | Description                                                                |
#    ...    +====================+======+============+============================================================================+
#    ...    | critical_patterns  | No   | @{EMPTY}   | Patterns of critical alarms which, if found, should fail the KW            |
#    ...    +--------------------+------+------------+----------------------------------------------------------------------------+
#    ...    | ignored_patterns   | No   | @{EMPTY}   | Patterns of ignored alarms which, if found, should not be taken into count |
#    ...    +--------------------+------+------------+----------------------------------------------------------------------------+
#    ...
#    ...    **Example of simple usage:**
#    ...
#    ...    .. code-block:: robotframework
#    ...
#    ...    ${IGNORED_ALARM}=     Create Dictionary  faultId=49  notifier=/MRBTS-1/RAT-1/LTS-1/LNBTS_L-1/LNCEL_L-10660
#    ...    ${IGNORED}=           Create List  ${IGNORED_ALARM}
#    ...    ${CRITICAL_ALARM}=    Create Dictionary  faultId=21
#    ...    ${CRITICAL}=          Create List  ${CRITICAL_ALARM}
#    ...    Admin Check SBTS cells, modules and alarms  critical_patterns=${CRITICAL}  ignored_patterns=${IGNORED}
#
#    [Arguments]  ${critical_patterns}=@{EMPTY}  ${ignored_patterns}=@{EMPTY}
#    ${system_modules_working}=  Verify system modules states
#    ${radio_modules_working}=  Verify radio modules states
#    ${cells_GSM_onair}=  Verify GSM cells states
#    ${cells_WCDMA_onair}=  Verify WCDMA cells states
#    ${cells_LTE_onair}=  Verify LTE cells states
#	 ${cells_NR_onair}=  Verify NR cells states
#    ${alarms_status}  ${alarms_msg}=  Run Keyword And Ignore Error  SiSo Check Active Alarms  critical_patterns=${critical_patterns}
#    ...  ignored_patterns=${ignored_patterns}
#    [Teardown]  Run Keyword If  not ${system_modules_working} and not ${radio_modules_working} and not ${cells_GSM_onair} and
# not ${cells_WCDMA_onair} and not ${cells_LTE_onair} and not ${cells_NR_onair} and not '${alarms_status}'!='FAIL'
#    ...  Fail  At least one module or cell indicates a faulty state or some critical alarms detected!

Siso Reset admin and infomodel connection if broken TAF
    [Documentation]
	...  Original KW -> Reset admin and infomodel connection if broken TAF
    ...  Original resource -> hran_admin.robot
	...  Check if Admin operations are possible. If not, reset admin and infomodel connections.
    ...  If allowed, and reset cause is other than soamif version change, will set TC restriction.
    ...  *AUTHOR*
    ...  agata.maslowska@nokia.com
    ...
    ...  *MAINTAINER*
    ...  daniel.bartkowiak@nokia.com
    [Arguments]  ${allowed_to_set_restriction}=${True}  ${alias}=default

    ${soamif exception}  set variable  Invalid soamIf version

    ${BTS_statecheck_status}  ${BTS_state}  Run keyword and ignore error  admin.Get Mrbts State  connection=${alias}
    Run keyword if  '${BTS_statecheck_status}'=='PASS'  return from keyword  ${True}

    ${soamif change check}  Run keyword and return status  Should contain  ${BTS_state}  ${soamif exception}
    Run keyword if  ${soamif change check}  Log  Soamif change detected. Will reset admin and infomodel connection.  console=True
    ${should set restriction}  Evaluate  (${allowed_to_set_restriction}==${True}) and (${soamif change check}==${False})
    Run keyword if  ${should set restriction}  Log  Admin reset required, no soamif change detected  console=${TRUE}

    ${admin_reset_status}  Run keyword and return status  admin.reset admin  connection=${alias}
    Log  Admin reset status: ${admin_reset_status}  console=True
    ${infomodel_reset_status}  Run keyword and return status  ute_admin_infomodel.reset infomodel
    ...  filename=${BTS Files}/IM/InfoModel_untilReset.ims2
    Log  Infomodel reset status: ${infomodel_reset_status}  console=True
    ${BTS_statecheck_status_after_reset}  ${BTS_state_after_reset}  Run keyword and ignore error  admin.Get mrbts state  connection=${alias}
    ${resets_status}  Evaluate
    ...  (${admin_reset_status}==${True}) and (${infomodel_reset_status}==${True}) and ('${BTS_statecheck_status_after_reset}'=='PASS')
    [Return]  ${resets_status}

Siso Verify parameters values in SCF object
    [Documentation]
    ...  Original KW -> Verify parameters values in SCF object
    ...  Original resource -> CM_delta_json_recommissioning.robot
    ...  KW for simple check if parameter from given BTS SCF has proper value in text field.
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com
    ...  reused by krzysztof.1.kowalski@nokia.com
    [Arguments]  ${scf_xml}  ${object_dist_name}  ${object_parameters}
    FOR  ${parameter}  IN  @{object_parameters}
        Log  Checking ${parameter['parameterName']} parameter value in SCF  console=True
        XML.Element Text Should Be  ${scf_xml}  ${parameter['value']}
        ...  //*[@distName="${object_dist_name}"]/child::*[@name="${parameter['parameterName']}"]
        ...  message=Value inside SCF is not equal value from delta JSON
        Log  Parameter ${parameter['parameterName']}=${parameter['value']}
    END

SiSo Close all BSC sessions
    [Documentation]
    ...  Original KW -> Close all BSC sessions
    ...  Original resource -> hran_general.robot
    ...  Close all connections to BSC and clear connection cache
    ...
    ...  | **Author:** patryk.furman@nokia.com
    ...  | **Maintainer:** patryk.furman@nokia.com

    hran_bsc.Close All Connections
    Log  All sessions to BSC closed  console=${TRUE}

SiSo Open BSC Session
    [Documentation]
    ...  Original KW -> Open session to BSC
    ...  Original resource -> hran_general.robot
    ...  Close all connections to BSC and clear connection cache
    ...
    ...  | **Author:** patryk.furman@nokia.com
    ...  | **Maintainer:** patryk.furman@nokia.com

    hran_bsc.Bsc Ssh Connection    host=${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}
    hran_bsc.Set Timeout  240s
	Log  SSH session to ${BSC['ip']} started  console=${TRUE}


SiSo Get Cells Deployed On Module
    [Tags]  Helper
    [Documentation]
    ...  Original KW -> Infomodel Get Cells Deployed On Module
    ...  Original resource -> hran_infomodel.robot
    ...  Returns list of cells' InfomodelObjects deployed on specific module.
    ...
    ...  This keyword selects all cells which match the module's dist_name pattern in their devicesDNInPath.
    ...
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description             |
    ...  |  module      | Yes  |  module infomodelObject  |
    ...
    ...  *RETURN*
    ...  |  Parameters  |  Description               |
    ...  |  cells       |  List of InfomodelObjects  |
    ...
    ...  *EXAMPLE*
    ...  |  ${rmod} =            |  Infomodel Get RMOD By Serial Number     |  ABCD123456  |
    ...  |  ${cells_on_rmod} =   |  SiSo Get Cells Deployed On Module  |  ${rmod}  |
    ...  |  ${bbmod} =           |  Query Infmodel  |  get object //BBMOD_L-1  |
    ...  |  ${cells_on_bbmod} =  |  SiSo Get Cells Deployed On Module  |  ${bbmod}  |
    [Arguments]  ${module}
    ${cells_on_mod} =  Create List  @{EMPTY}
    ${cells} =  Query Infomodel  get list //CELL_M-*
    ${re} =  Set Variable  regex"${module.dist_name}/.*"
    FOR  ${cell}  IN  @{cells}
        ${contains} =  Query Infomodel  ${cell.dist_name}//PATH-* is [devicesDNInPath[?]=${re}]  allow_negative_result=True  timeout=0.1s
        ${contains} =  Convert To Boolean  ${contains}
        Run Keyword If  ${contains}  Append To List  ${cells_on_mod}  ${cell}
    END
    [Return]  ${cells_on_mod}

SiSo Cell Has At Least One Operational RXTX Pair
    [Tags]  Checker
    [Documentation]
    ...  Original KW -> Infomodel Cell Has At Least One Operational RXTX Pair
    ...  Original resource -> hran_infomodel.robot
    ...  Returns True if cell has at least one pair of RX and TX with operationalState Enabled,
    ...  False otherwise.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...
    ...  *RETURN*
    ...  |  Parameters     |  Description                             |
    ...  |  has_rxtx_pair  |  True if cell has operational RXTX pair  |
    ...
    ...  *EXAMPLE*
    ...  | ${cell} =           | Query Infomodel  get object //CELL_M-1 |
    ...  | ${has_rxtx_pair} =  | SiSo Cell Has At Least One Operational RXTX Pair  |  ${cell}
    [Arguments]  ${cell}
    ${has_rx} =  Set Variable  ${cell.dist_name}//CHANNEL_M-* is [stateInfo.operationalState=Enabled, direction=RX]
    ${has_tx} =  Set Variable  ${cell.dist_name}//CHANNEL_M-* is [stateInfo.operationalState=Enabled, direction=TX]
    ${queries} =  Create Dictionary  has_rx=${has_rx}   has_tx=${has_tx}
    ${status} =  Run Keyword And Return Status  Query Infomodel Sequence  &{queries}
    ${has_rxtx_pair} =  Convert To Boolean  ${status}
    [Return]  ${has_rxtx_pair}

SiSo Cell Should Be Degraded
    [Tags]  Assert
    [Documentation]
    ...  Original KW -> Infomodel Cell Should Be Degraded
    ...  Original resource -> hran_infomodel.robot
    ...  Verifies that status of given cell is degraded.
    ...
    ...  In case of failure logs message with specified level. Default WARN.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...  |  level       | No   |  failure log level     |
    ...
    ...  *EXAMPLE*
    ...  | ${cell} =  |  Query Infomodel  |  get object //CELL_M-1  |
    ...  | SiSo Cell Should Be Degraded  |  ${cell}            |
    [Arguments]  ${cell}  ${level}=WARN
    ${state} =  Create Dictionary  availabilityStatus=Degraded  operationalState=Enabled
    SiSo Cell Should Be  ${cell.dist_name}  ${state}  ${level}

SiSo Cell Should Be
    [Documentation]
    ...  Original KW -> _Infomodel Cell Should Be
    ...  Original resource -> hran_infomodel.robot
    [Arguments]  ${cell_dn}  ${expected}  ${level}
    ${cell} =  Query Infomodel  get object ${cell_dn}
    ${current} =    Create Dictionary  availabilityStatus=${cell.stateInfo.availabilityStatus}
                                  ...  operationalState=${cell.stateInfo.operationalState}
    ${availability_status}=  Run keyword and return status  Should match regexp  ${current['availabilityStatus']}  ^${expected['availabilityStatus']}$
    ${operational_state}=  Run keyword and return status  Should match regexp  ${current['operationalState']}  ^${expected['operationalState']}$
    ${as_expected} =  Evaluate  ${availability_status} and ${operational_state}
    ${err_msg} =  Set Variable  Cell Status Wrong. ${cell.dist_name}. Current: ${current}
    Run Keyword If  ${as_expected}  Log  [${SPACE * 2}OK${SPACE * 2}] Cell Status Correct. ${cell.dist_name}. Current: ${current}  console=yes
         ...  ELSE IF  '${level}'=='ERROR'  Fail  ${msg}
         ...  ELSE  Log  ${msg}  console=yes

SiSo Cell Should Be Failed
    [Tags]  Assert
    [Documentation]
    ...  Original KW -> Infomodel Cell Should Be Failed
    ...  Original resource -> hran_infomodel.robot
    ...  Verifies that status of given cell is failed.
    ...
    ...  In case of failure logs message with specified level. Default WARN.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...  |  level       | No   |  failure log level     |
    ...
    ...  *EXAMPLE*
    ...  | ${cell} =  |  Query Infomodel    |  get object //CELL_M-1  |
    ...  | SiSo Cell Should Be Failed  |  ${cell}                |
    [Arguments]  ${cell}  ${level}=WARN
    ${state} =  Create Dictionary  availabilityStatus=Failed  operationalState=Disabled
    SiSo Cell Should Be  ${cell.dist_name}  ${state}  ${level}

SiSo Cell Should Be Online
    [Tags]  Assert
    [Documentation]
    ...  Original KW -> Infomodel Cell Should Be Online
    ...  Original resource -> hran_infomodel.robot
    ...  Verifies that status of given cell is online.
    ...
    ...  In case of failure logs message with specified level. Default WARN.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description           |
    ...  |  cell        | Yes  |  cell InfomodelObject  |
    ...  |  level       | No   |  failure log level     |
    ...
    ...  *EXAMPLE*
    ...  | ${cell} =  |  Query Infomodel  |  get object //CELL_M-1  |
    ...  | SiSo Cell Should Be Online  |  ${cell}              |
    [Arguments]  ${cell}  ${level}=WARN
    ${state} =  Create Dictionary  availabilityStatus=Online  operationalState=Enabled
    SiSo Cell Should Be  ${cell.dist_name}  ${state}  ${level}

SiSo Get All Radio Modules Serial Numbers
    [Documentation]
    ...  Original KW -> Infomodel Get All Radio Modules Serial Numbers
    ...  Original resource -> hran_infomodel.robot
    ...  *RETURN VALUE*:
    ...  List of BTS RMODs serial numbers
    ...
    ...  *Author*: Patryk Furman

    ${rmods}=  SiSo Get Objects Parameter  ${dist_radio}  serialNumber
    [Return]  ${rmods}

SiSo Get LTE CELL-RM mapping list
    [Documentation]
    ...  Original KW -> Admin Get LTE CELL-RM mapping list
    ...  Original resource -> hran_admin.robot
    ...  Keyword providing LTE CELL-RM mapping information.
    ...  It outputs list which consist of [CELL_DN, CELL_dlMimoMode, CELL_syncSigTxMod, CELL_actOtdoa, CELL_actPrsTxDiv, [RM_DN]]
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter        | Description                 |
    ...  | LTE_CELL_RM_list | List of LTE_CELL_RM details |
    ...
    ...  *EXAMPLE*
    ...  | ${LTE_CELL_RM_list}= | Admin Get LTE CELL-RM mapping list | Master |

    [Arguments]  ${alias}=default
    ${LTE_LNBTS_parameters_list}=  SiSo Get LTE txPathFailureMode  alias=${alias}
    ${LTE_CELL_parameters_list}=  SiSo Get LTE CELL parameters list  alias=${alias}
    ${LTE_CELL_RM_list}=  Create List
    FOR  ${item}  IN  @{LTE_CELL_parameters_list}
            ${RM_list}=  Siso Admin Get LTE RM mapped list  ${item[0]}  ${alias}
        @{temp}=  Create List  ${item[0]}  ${item[2]}  ${item[3]}  ${item[4]}  ${item[5]}  ${RM_list}
        Append To List  ${LTE_CELL_RM_list}  ${temp}
    END
    Sort List  ${LTE_CELL_RM_list}
    [Return]  ${LTE_CELL_RM_list}

SiSo Get LTE CELL parameters list
    [Documentation]
    ...  Original KW -> Admin Get LTE CELL parameters list
    ...  Original resource -> hran_admin.robot
    [Arguments]  ${alias}
    ${LTE_ALL_CELLS_list}=  admin.Get Cell List  alias=${alias}
    Set Test Variable  ${LTE_ALL_CELLS_list}
    ${LTE_CELL_parameters_list}=  Create List
    FOR  ${item}  IN  @{LTE_ALL_CELLS_list['cells']['lte']}
        ${CONF_REF_obj}=  Query Infomodel  get object ${item['id']['internal']}/CONF_REF-1  alias=${alias}
        ${LNCEL_A_param}=  Query Infomodel  query=get object ${CONF_REF_obj.distName}  alias=${alias}
        Continue For Loop If  '${LNCEL_A_param['cellTechnology']}' not in ['FDD','TDD']
        ${LNCEL_TECHNO_A_param}=  Query Infomodel  query=get object ${CONF_REF_obj.distName}/LNCEL_${LNCEL_A_param['cellTechnology']}_A-0
        ...  alias=${alias}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${item['globalCellId']}
        ...  ${item['downlinkMimoMode']}
        ...  ${LNCEL_TECHNO_A_param['syncSigTxMode']}
        ...  ${LNCEL_A_param['actOtdoa']}
        ...  ${LNCEL_A_param['actPrsTxDiv']}
        Append To List  ${LTE_CELL_parameters_list}  ${temp}
    END
    Sort List  ${LTE_CELL_parameters_list}
    [Return]  ${LTE_CELL_parameters_list}

SiSo Get LTE txPathFailureMode
    [Documentation]
    ...  Original KW -> Infomodel Get LTE txPathFailureMode
    ...  Original resource -> hran_infomodel.robot
    ...  Keyword providing LTE txPathFailureMode value from IM.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                           |
    ...  | alias     | No   | alias of ute_admin_infomodel instance |
    ...
    ...  *RETURN*
    ...  | Parameter         | Description                                                         |
    ...  | txPathFailureMode | parameter value |
    ...
    [Arguments]  ${alias}=default
    ${status}  ${LNBTS_A_object_found}=  Run Keyword and Ignore Error  Query Infomodel  query=get list //LNBTS_A-*  alias=${alias}
    Run Keyword If  '${status}'=='PASS'  Set Test Variable  ${txPathFailureMode}  ${LNBTS_A_object_found[0].txPathFailureMode}
    ...  ELSE  Set Test Variable  ${txPathFailureMode}  ''

Siso Admin Get LTE RM mapped list
    [Documentation]
    ...  Original KW -> Admin Get LTE RM mapped list
    ...  Original resource -> hran_infomodel.robot
    [Arguments]  ${CELL_DN}  ${alias}
    ${LTE_RM_CELL_list}=  Siso Admin Get LTE RM-CELL mapping list  alias=${alias}
    ${LTE_RM_mapped_list}=  Create List
    FOR  ${item}  IN  @{LTE_RM_CELL_list}
        ${map}=  Run Keyword And Return Status  List Should Contain Value  ${item[1]}  ${CELL_DN}
        Run Keyword If  '${map}' == 'True'  Append To List  ${LTE_RM_mapped_list}  ${item[0]}
    END
    Sort List  ${LTE_RM_mapped_list}
    ${RM_TxRx_mapped_list}=  Create List
    FOR  ${item}  IN  @{LTE_RM_mapped_list}
        ${RM_TxRx_list}=  Siso Get RM TxRx List  ${CELL_DN}  ${item}
        Append To List  ${RM_TxRx_mapped_list}  ${RM_TxRx_list}
    END
    [Return]  ${RM_TxRx_mapped_list}

Siso Get RM TxRx List
    [Documentation]
    ...  Original KW -> Get RM TxRx List
    ...  Original resource -> hran_infomodel.robot
    [Arguments]  ${Cell_DN}  ${RM_DN}
    FOR  ${item}  IN  @{LTE_ALL_CELLS_list['cells']['lte']}
        ${RM_TxRx_list}=  Run Keyword If  '${item['id']['internal']}' == '${Cell_DN}'
        ...  Siso Get RM TxRx Info  ${item['carrierList']}  ${item['globalCellId']}  ${RM_DN}
        Exit For Loop If  '${item['id']['internal']}' == '${Cell_DN}'
    END
    [Return]  ${RM_TxRx_list}

Siso Get RM TxRx Info
    [Documentation]
    ...  Original KW -> Get RM TxRx Info
    ...  Original resource -> hran_infomodel.robot
    [Arguments]  ${carrierList}  ${globalCellId}  ${RM_DN}
    ${RM_TxRx_list}=  Create List
    ${TxRx_list}=  Create List
    FOR  ${item}  IN  @{carrierList}
        ${cell_id}=  Get Regexp Matches  ${item['id']['configuration']}  LNCEL-\\d+
        ${cell_globalCellId}=  Should Match Regexp  ${cell_id[0]}  \\d+
        ${rm_id}=  Fetch From Left  ${item['antennaLineId']['internal']}  /ANTL_R
        Run Keyword If  '${cell_globalCellId}' == '${globalCellId}' and '${rm_id}' == '${RM_DN}'
        ...  Append To List  ${TxRx_list}  ${item['direction']}
    END
    Append To List  ${RM_TxRx_list}  ${RM_DN}  ${TxRx_list}
    [Return]  ${RM_TxRx_list}

Siso Admin Get LTE RM-CELL mapping list
    [Documentation]
    ...  Original KW -> Admin Get LTE RM-CELL mapping list
    ...  Original resource -> hran_infomodel.robot
    ...
    ...  Keyword providing LTE RM-CELL mapping information.
    ...  It outputs list which consist of [RM_DN, [CELL_DN]] where [CELL_DN] list content is described as below:
    ...  - if ${IOT_CELL_add}=False -> [CELL_DN] contains only LTE HOST Cell(s)
    ...  - if ${IOT_CELL_add}=True -> [CELL_DN] contains LTE HOST and IOT Cell(s)
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter    | Man. | Default | Description                                                  |
    ...  | alias        | No   | default | alias of admin instance                                      |
    ...  | IOT_CELL_add | No   | False   | Flag to add LTE IOT Cell(s) to LTE Cell(s) list mapped on RM |
    ...
    ...  *RETURN*
    ...  | Parameter        | Description                 |
    ...  | LTE_RM_CELL_list | List of LTE-RM-CELL details |
    ...
    ...  *EXAMPLE*
    ...  | ${LTE_RM_CELL_list}= | Siso Admin Get LTE RM-CELL mapping list | Master |

    [Arguments]  ${alias}=default  ${IOT_CELL_add}=False
    ${RMOD_ID_LIST}=  Get Ids For All  RMOD  alias=${alias}
    Sort List  ${RMOD_ID_LIST}
    ${LTE_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{RMOD_ID_LIST}
        ${CELL_ID_LIST}=  Get Cell Mapping By Module Id  ${item}  alias=${alias}
        ${LTE_HOST_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}=  Siso Admin Get LTE HOST and IOT Cell(s) Id list  CELL_list=${CELL_ID_LIST}  alias=${alias}
        @{temp}=  Run Keyword If  not ${IOT_CELL_add}  Create List  ${item}  ${LTE_HOST_CELL_ID_LIST}
        ...  ELSE  Create List  ${item}  ${CELL_ID_LIST}
        Append To List  ${LTE_RM_CELL_list}  ${temp}
    END
    Sort List  ${LTE_RM_CELL_list}
    [Return]  ${LTE_RM_CELL_list}

Siso Admin Get LTE HOST and IOT Cell(s) Id list
    [Documentation]
    ...  Original KW -> Admin Get LTE HOST and IOT Cell(s) Id list
    ...  Original resource -> hran_infomodel.robot
    ...
    ...  Keyword providing LTE HOST and IOT Cell(s) list from a LTE cell(s) list.
    ...  It outputs two lists for LTE HOST and IOT Cell(s)
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man.  | Default | Description             |
    ...  | CELL_list | Yes   |         | Cell(s) list            |
    ...  | alias     | No    | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter             | Description                 |
    ...  | LTE_HOST_CELL_ID_LIST | List of LTE HOST Cell(s) Id |
    ...  | LTE_IOT_CELL_ID_LIST  | List of LTE IOT Cell(s) Id  |
    ...
    ...  *EXAMPLE*
    ...  | ${LTE_HOST_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}= | Siso Admin Get LTE HOST and IOT Cell(s) Id list | ${CELL_list}  Master |

    [Arguments]  ${CELL_list}  ${alias}=default
    ${LTE_HOST_CELL_ID_LIST}=  Create List
    ${LTE_IOT_CELL_ID_LIST}=  Create List
    FOR  ${item}  IN  @{CELL_list}
        ${CELL_PARAM_LIST}=  Get Parameters For  LNCEL  ${item}  alias=${alias}
        ${CELL_technology_found}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_PARAM_LIST['technology']}
        ${CELL_cellTechnology_found}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_PARAM_LIST['nbIoTCell']['cellTechnology']}
        ${CELL_nbIoTMode_found}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_PARAM_LIST['nbIoTMode']}
        Run Keyword If  ${CELL_technology_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['technology']}'=='FDD' or '${CELL_PARAM_LIST['technology']}'=='TDD'
        ...  Append To List  ${LTE_HOST_CELL_ID_LIST}  ${CELL_PARAM_LIST['id']}
        Run Keyword If  ${CELL_cellTechnology_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['nbIoTCell']['cellTechnology']}'=='NB-IoT-FDD'
        ...  Append To List  ${LTE_IOT_CELL_ID_LIST}  ${CELL_PARAM_LIST['nbIoTCell']['distName']}
        Run Keyword If  ${CELL_technology_found} and ${CELL_nbIoTMode_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['technology']}'=='NB-IoT-FDD' and '${CELL_PARAM_LIST['nbIoTMode']}'=='standalone'
        ...  Append To List  ${LTE_IOT_CELL_ID_LIST}  ${CELL_PARAM_LIST['id']}
    END
    Sort List  ${LTE_HOST_CELL_ID_LIST}
    Sort List  ${LTE_IOT_CELL_ID_LIST}
    [Return]  ${LTE_HOST_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}
