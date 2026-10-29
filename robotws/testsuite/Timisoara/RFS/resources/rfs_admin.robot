*** Settings ***
Documentation    Keywords using taf admin library
...              Resource used by RF Sharing Vrf tribe
...              Author: Dinu Olariu
...              Contact: dinu.olariu@nokia.com

Library    Collections
Library    OperatingSystem
Library    python_resources/alarms_analysis.py
Library    String
Library    taf.sbts.oam.coam.admin  WITH NAME  coam

*** Keywords ***

Admin Get BTS siteName information
    [Documentation]
    ...  Helper keyword providing BTS siteName info.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description       |
    ...  | BTS_SiteName         | BTS siteName info |

    [Arguments]  ${alias}=default
    ${BTS_PARAM_LIST}=  Get Parameters For All  BTS  alias=${alias}
    ${BTS_SiteName}=  Create List
    FOR  ${item}  IN  @{BTS_PARAM_LIST}
        ${BTS_SiteName}=  Get Variable Value  ${item.btsName}  UNKNOWN
    END
    Set Tags  Site name - ${alias} = ${BTS_SiteName}
    Log  Site name - ${alias} = ${BTS_SiteName}  level=INFO  console=${TRUE}
    [Return]  ${BTS_SiteName}

Admin Get BTS state info
    [Documentation]
    ...  Helper keyword providing BTS states info.
    ...  KW is returning a list of BTS states info as below:
    ...  - distName, proceduralState, blockingState
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description        |
    ...  | BTS_STATE_LIST       | List of BTS states |

    [Arguments]  ${alias}=default
    ${BTS_PARAM_LIST}=  Get Parameters For All  BTS  alias=${alias}
    ${BTS_STATE_LIST}=  Create List
    FOR  ${item}  IN  @{BTS_PARAM_LIST}
        Append To List  ${BTS_STATE_LIST}  ${item.id}  ${item.proceduralState}  ${item.blockingState}
    END
    [Return]  ${BTS_STATE_LIST}

Admin Get RMOD state info
    [Documentation]
    ...  Helper keyword providing NR and LTE radio modules states info based on InfoModel class name.
    ...  KW is returning a list of lists with RMOD states info as below:
    ...  - name, distName, productName, operationalState, administrativeState, availabilityStatus, blockingState, usageState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter        | Description                    |
    ...  | RMOD_STATE_LIST  | List of lists with RMOD states |

    [Arguments]  ${alias}=default
    ${RMOD_ID_LIST}=  Get Ids For All  RMOD  alias=${alias}
    Sort List  ${RMOD_ID_LIST}
    ${RMOD_STATE_LIST}=  Create List
    FOR  ${item}  IN  @{RMOD_ID_LIST}
        ${RMOD_PARAM_LIST}=  Get Parameters For  RMOD  ${item}  alias=${alias}
        ${RMOD_label}=  Fetch From Right  ${RMOD_PARAM_LIST['id']}  /
        ${availabilityStatus_status}=  Run Keyword and Return Status  Variable Should Exist  ${RMOD_PARAM_LIST['availabilityStatus']}
        ${availabilityStatus}=  Set Variable If  ${availabilityStatus_status}
        ...  ${States_Dictionary_Get['${RMOD_PARAM_LIST['availabilityStatus']}']}   ${States_Dictionary_Get['None']}
        ${blockingState_status}=  Run Keyword and Return Status  Variable Should Exist  ${RMOD_PARAM_LIST['blockingState']}
        ${blockingState}=  Set Variable If  ${blockingState_status}
        ...  ${States_Dictionary_Get['${RMOD_PARAM_LIST['blockingState']}']}   ${States_Dictionary_Get['Unblocked']}
        ${usageState_status}  ${content}=  Run Keyword and Ignore Error  Dictionary Should Contain Key  ${RMOD_PARAM_LIST}  usageState
        ${usageStateStatusVar}=  Set Variable If  '${usageState_status}' == 'PASS'
        ...  ${States_Dictionary_Get['${RMOD_PARAM_LIST['usageState']}']}  ${States_Dictionary_Get['None']}
        @{temp}=  Create List
        ...  ${RMOD_label}
        ...  ${RMOD_PARAM_LIST['id']}
        ...  ${RMOD_PARAM_LIST['productName']}
        ...  ${States_Dictionary_Get['${RMOD_PARAM_LIST['operationalState']}']}
        ...  ${States_Dictionary_Get['${RMOD_PARAM_LIST['administrativeState']}']}
        ...  ${availabilityStatus}
        ...  ${blockingState}
        ...  ${usageStateStatusVar}
        Append To List  ${RMOD_STATE_LIST}  ${temp}
    END
    Sort List  ${RMOD_STATE_LIST}
    [Return]  ${RMOD_STATE_LIST}

Admin Get LTE CELL state info
    [Documentation]
    ...  Helper keyword providing LTE cells states info.
    ...  KW is returning a list of lists with CELL states info as below:
    ...  - name, distName, operationalState, administrativeState, availabilityStatus, blockingState, proceduralState. usageState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                    |
    ...  | LTE_CELL_STATE_LIST  | List of lists with CELL states |

    [Arguments]  ${alias}=default
    ${CELL_ID_LIST}  ${EMPTY}=  Admin Get LTE CELL Ids list  alias=${alias}
    ${LTE_CELL_STATE_LIST}=  Create List
    FOR  ${item}  IN  @{CELL_ID_LIST}
        ${CELL_PARAM_LIST}=  Get Parameters For  LNCEL  ${item}  alias=${alias}
        ${CELL_label}=  Fetch From Right  ${CELL_PARAM_LIST['id']}  /
        ${availabilityStatus_status}=  Run Keyword and Return Status  Variable Should Exist  ${CELL_PARAM_LIST['availabilityStatus']}
        ${availabilityStatus}=  Set Variable If  ${availabilityStatus_status}
        ...  ${States_Dictionary_Get['${CELL_PARAM_LIST['availabilityStatus']}']}   ${States_Dictionary_Get['None']}
        ${usageState_status}  ${content}=  Run Keyword and Ignore Error  Dictionary Should Contain Key  ${CELL_PARAM_LIST}  usageState
        ${usageStateStatusVar}=  Set Variable If  '${usageState_status}' == 'PASS'
        ...  ${States_Dictionary_Get['${CELL_PARAM_LIST['usageState']}']}  ${States_Dictionary_Get['None']}
        @{temp}=  Create List
        ...  ${CELL_label}
        ...  ${CELL_PARAM_LIST['id']}
        ...  ${States_Dictionary_Get['${CELL_PARAM_LIST['operationalState']}']}
        ...  ${States_Dictionary_Get['${CELL_PARAM_LIST['administrativeState']}']}
        ...  ${availabilityStatus}
        ...  ${States_Dictionary_Get['${CELL_PARAM_LIST['blockingState']}']}
        ...  ${States_Dictionary_Get['${CELL_PARAM_LIST['proceduralState']}']}
        ...  ${usageStateStatusVar}
        Append To List  ${LTE_CELL_STATE_LIST}  ${temp}
    END
    Sort List  ${LTE_CELL_STATE_LIST}
    [Return]  ${LTE_CELL_STATE_LIST}

Get And Set OAM IP Address
    [Arguments]  ${alias}

    ${oam_ip_address}=  Get Variable Value  ${${alias.upper()}}[${alias.upper()}_OAM_IP_ADDRESS]  ${Empty}
    Run Keyword If  '${oam_ip_address}'  Run Keywords
    ...  Log  OAM IP for ${alias} is set in init to '${${alias.upper()}}[${alias.upper()}_OAM_IP_ADDRESS]'  level=DEBUG
    ...  AND  Return From Keyword

    ${admin_oam_ip_address}=  Admin Get BTS M-plane IP address  alias=${alias}
    Run Keyword If  '${admin_oam_ip_address}'  Run Keywords
    ...  Set To Dictionary  ${${alias.upper()}}  ${alias.upper()}_OAM_IP_ADDRESS  ${admin_oam_ip_address}
    ...  AND  Log  OAM IP for ${alias} was read from admin and set to '${${alias.upper()}}[${alias.upper()}_OAM_IP_ADDRESS]'  level=DEBUG
    ...  AND  Return From Keyword

    Log  OAM IP for ${alias} not configured in init, nor able to be read from BTS  console=True

Admin Check BTS Procedural and Blocking states
    [Documentation]
    ...  Helper keyword checking BTS proceduralState and blockingState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Man. | Default   | Description                                             |
    ...  | exp pro state | No   | OnAir     | expected proceduralState                                |
    ...  | exp blk state | No   | Unblocked | expected blockingState                                  |
    ...  | timeout       | No   | 90        | time (in seconds) to wait for positive procedure result |
    ...  | alias         | No   | default   | alias of admin instance                                 |
    ...

    [Arguments]  ${exp_pro_state}=${OnAir_}  ${exp_blk_state}=${Unblocked_}  ${timeout}=90  ${alias}=default
    Get Current Time  before_get_id
    ${remote_host}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${timeout}
    ...  remote_host=${remote_host}
    Get Current Time  before_bts_check
    ${elapsed_time}=  DateTime.Subtract Date From Date  ${time_before_bts_check}  ${time_before_get_id}  number
    ${remaining_time}=  BuiltIn.Evaluate  ${timeout} - ${elapsed_time}
    Assert Every  class_name=BTS  parameters=proceduralState=${exp_pro_state}, blockingState=${exp_blk_state}  timeout=${remaining_time}
    ...  connection=${alias}

Admin Check if BTS is unblocked
    [Documentation]
    ...  Helper keyword checking BTS blocking state info. If needed perform unblock BTS.
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man.  | Default | Description             |
    ...  | alias     | No    | default | alias of admin instance |
    ...
    [Arguments]  ${alias}=default
    ${LTE_BTS_STATE_LIST}=  Admin Get BTS state info  ${alias}
    Run Keyword If  '${LTE_BTS_STATE_LIST[2]}' in '${Blocked_}'  Run Keywords
    ...  coam.Unblock  timeout=600  alias=${alias}
    ...  AND  Log  BTS unblock indicated  console=True

Admin Check if all cells are unblocked
    [Documentation]
    ...  Helper keyword checking CELL blocking state info. If needed perform unblock CELL.
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    [Arguments]  ${alias}=default
    ${LTE_CELL_STATE_LIST}=  Admin Get LTE CELL state info  ${alias}
    FOR  ${item}  IN  @{LTE_CELL_STATE_LIST}
        Run Keyword If  '${item[5]}' in '${Blocked_}'  Run Keywords
        ...  coam.Unblock Cell  dist_name=${item[1]}  connection=${alias}
        ...  AND  Sleep  30s  Wait for Cell ${item[0]} establish
        ...  AND  Log  Cell ${item[0]} unblock indicated  console=True
    END

Admin Collect scf.xml with timestamp TAF
    [Documentation]
    ...  KW for collecting scf.xml from BTS to destination directory based on TAF library. Scf.xml gets name in form 'scf_time'
    ...  where time is the current time.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter                       | Man. | Description                                                                                      |
    ...  | alias                           | No   | alias of admin instance                                                                          |
    ...  | folder_path                     | No   | folder path for SCF file collection                                                              |
    ...  | export_type                     | No   | configuration, configurationAndRuntimeObjects or runtimeObjects. None means default Admin API    |
    ...  |                                          behavior. By default is None                                                                     |
    ...  | with_auto_configured_parameters | No   | Save also auto-configured parameters (CB013031). Possible values: ${TRUE} or ${FALSE}.           |
    ...  |                                         Default is ${TRUE}. If exportType is runtimeObjects, this parameter will be ignored               |
    ...
    ...  *RETURN*
    ...  | Parameter | Description                    |
    ...  | scf_path  | full path to collected scf.xml |
    ...
    [Arguments]  ${alias}=default  ${folder_path}=/home/ute/btsauto/logs  ${export_type}=${NONE}  ${file_name}=scf
    ...  ${with_auto_configured_parameters}=${TRUE}

    ${time}=  Get Time
    Set Test Variable  ${scf_path}  ${folder_path}/${file_name}_${time}.xml
    Get Current Scf File  local_dir_path=${folder_path}  file_name=${file_name}_${time}.xml  timeout=60  connection=${alias}
    ...  export_type=${export_type}  with_auto_configured_parameters=${with_auto_configured_parameters}

    [Return]  ${scf_path}

Admin Collect PM Files
    [Documentation]
    ...  Procedure for PM collection as below:
    ...  - create ${folder_path} if it doesn't exist
    ...  - collect PM archive from BTS to VM
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    | Parameter       | Man. | Default                     | Description                   |
    ...    | alias           | no   | default                     | alias of admin instance       |
    ...    | folder_path     | no   | ${Test Results Dir}/PMFiles | folder path for PM collection |
    ...    | PM_archive_name | no   | PM_LTE.zip                  | PM archive name               |

    [Timeout]  10 min
    [Arguments]  ${alias}=default  ${folder_path}=${Test Results Dir}/PMFiles  ${PM_archive}=PM_LTE.zip

    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${folder_path}
    Run Keyword If  not ${status}  Create Directory  ${folder_path}

    Set Test Variable  ${${alias}_PM_ARCHIVE}  ${PM_archive}
    ${status}=  Run Keyword And Return Status  Collect Pm Files  target_file_name=${folder_path}/${${alias}_PM_ARCHIVE}  alias=${alias}
    Run Keyword If  not ${status}  Run Keywords
    ...  Set Test Variable  ${PM_collect}  ${False}
    ...  AND  Log  ${alias} PM archive collection failed!  level=WARN

    Run Keyword If  ${PM_collect}  Check PM archive transfer  ${alias}  ${folder_path}/${${alias}_PM_ARCHIVE}

Admin Validate SCF TAF
    [Documentation]
    ...  KW for SCF validation. SCF can be provided as input argument:
    ...  - if valued with absolute file path of stored SCF
    ...  - if empty, current SCF will be collected and validated.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter                       | Man. | Description                                                                                      |
    ...  | scf_path_file                   | No   | SCF file path                                                                                    |
    ...  | skip_param_rel_err              | No   | skip parameter relation errors                                                                   |
    ...  | alias                           | No   | alias of admin instance                                                                          |
    ...  | export_type                     | No   | configuration, configurationAndRuntimeObjects or runtimeObjects                                  |
    ...  | timeout                         | No   | time to wait for positive procedure result                                                       |
    ...  | with_auto_configured_parameters | No   | Save also auto-configured parameters (CB013031). Possible values: ${TRUE} or ${FALSE}.           |
    ...  |                                         Default is ${TRUE}. If exportType is runtimeObjects, this parameter will be ignored               |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                        |
    ...  | definition_errors_file | Path to definition_errors_file.txt |
    ...  | relation_errors_file   | Path to relation_errors_file.txt   |
    ...  | hardware_errors_file   | Path to hardware_errors_file.txt   |
    ...
    [Arguments]  ${scf_path_file}=${EMPTY}  ${skip_param_rel_err}=${TRUE}  ${alias}=default  ${export_type}=configuration  ${timeout}=180
    ...  ${with_auto_configured_parameters}=${TRUE}

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${scf_file_name}=  Set Variable  SCF_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.xml
    ${scf_path_file}=  Run Keyword If  '${scf_path_file}' == '${EMPTY}'
    ...  Set Variable  ${Test Results Dir}/SCF_Validation/${scf_file_name}
    ...  ELSE  Set Variable  ${scf_path_file}

    ${scf_path_folder}  ${scf_name}=  Split Path  ${scf_path_file}

    Run Keyword If  '${scf_path_file}' != '${EMPTY}'
    ...  Get Current Scf File  local_dir_path=${scf_path_folder}  file_name=${scf_file_name}  timeout=60  connection=${alias}
    ...  export_type=${export_type}  with_auto_configured_parameters=${with_auto_configured_parameters}

    Log  ${\n}=============  console=True
    Log  Validate SCF: ${scf_path_file}  console=True
    FOR  ${cycle}  IN RANGE  1  4
        Log  ${\n}=====================  console=True
        Log  SCF Validation cycle: ${cycle}  console=True
        ${errors_dict}  Validate Scf Online  scf_file=${scf_path_file}  skip_parameter_relation_errors=${skip_param_rel_err}  timeout=${timeout}
        ...  alias=${alias}
        Log  ${\n}====================================  console=True
        Log  SCF Validation for Definition Errors  console=True
        ${definitionErrorsSize}=  Run Keyword If  '${errors_dict["requestMessage"]["niddValidationResult"]["logs"]["definitionErrors"]}'=='None'
        ...  Set Variable  0
        ...  ELSE  Get Length  ${errors_dict["requestMessage"]["niddValidationResult"]["logs"]["definitionErrors"]}
        ${def_err_evaluated}  Evaluate  str(${errors_dict["requestMessage"]["niddValidationResult"]})
        ${definition_errors_file}  Set Variable  ${Test Results Dir}/SCF_Validation/Definition_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
        Append To File  ${definition_errors_file}  ${def_err_evaluated}
        Run Keyword If  "${errors_dict["requestMessage"]["niddValidationResult"]["status"]}"=="OK"  Run Keywords
        ...  Log  Definition Errors Count: ${definitionErrorsSize}  level=INFO  console=True
        ...  AND  Log  Definition Errors Verdict: NIDD validation succeeded.  level=INFO  console=True
        ...  ELSE  Run Keywords
        ...  Log  Definition Errors Count: ${definitionErrorsSize}  level=INFO  console=True
        ...  AND  Log  Definition Errors Verdict: Parameter validation errors: ${definitionErrorsSize}, please check ${definition_errors_file}!
        ...  level=WARN

        Log  ${\n}==================================  console=True
        Log  SCF Validation for Relation Errors  console=True
        ${relationErrorsSize}=  Get Length  ${errors_dict["requestMessage"]["pdlValidationResult"]["logs"]["relationErrors"]}
        ${rel_err_evaluated}  Evaluate  str(${errors_dict["requestMessage"]["pdlValidationResult"]["logs"]["relationErrors"]})
        ${relation_errors_file}  Set Variable  ${Test Results Dir}/SCF_Validation/Relation_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
        Append To File  ${relation_errors_file}  ${rel_err_evaluated}
        Run Keyword If  "${errors_dict["requestMessage"]["pdlValidationResult"]["status"]}"!="OK" and ${relationErrorsSize}!=0  Run Keywords
        ...  Log  Relation Errors Count: ${relationErrorsSize}  level=INFO  console=True
        ...  AND  Log  Relation Errors Verdict: Parameter validation errors present, please check ${relation_errors_file}  level=WARN
        ...  ELSE  Run Keywords
        ...  Log  Relation Errors Count: ${relationErrorsSize}  level=INFO  console=True
        ...  AND  Log  Relation Errors Verdict: Parameter relation validation succeeded.  level=INFO  console=True

        Log  ${\n}==================================  console=True
        Log  SCF Validation for Hardware Errors  console=True
        ${hardwareErrorsSize}=  Get Length  ${errors_dict["requestMessage"]["pdlValidationResult"]["logs"]["hardwareErrors"]}
        ${hard_err_evaluated}  Evaluate  str(${errors_dict["requestMessage"]["pdlValidationResult"]["logs"]["hardwareErrors"]})
        ${hardware_errors_file}  Set Variable  ${Test Results Dir}/SCF_Validation/Hardware_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
        Append To File  ${hardware_errors_file}  ${hard_err_evaluated}
        Run Keyword If  "${errors_dict["requestMessage"]["pdlValidationResult"]["status"]}"!="OK" and ${hardwareErrorsSize}!=0  Run Keywords
        ...  Log  Hardware Errors Count: ${hardwareErrorsSize}  level=INFO  console=True
        ...  AND  Log  Hardware Errors Verdict: Parameter validation errors present, please check ${relation_errors_file}  level=WARN
        ...  ELSE  Run Keywords
        ...  Log  Hardware Errors Count: ${hardwareErrorsSize}  level=INFO  console=True
        ...  AND  Log  Hardware Errors Verdict: Hardware relation validation succeeded.  level=INFO  console=True
        Run Keyword If  ${definitionErrorsSize} == 0 and ${relationErrorsSize} == 0 and ${hardwareErrorsSize} == 0
        ...  Return From Keyword  ${definition_errors_file}  ${relation_errors_file}  ${hardware_errors_file}
     END

    [Return]  ${definition_errors_file}  ${relation_errors_file}  ${hardware_errors_file}

Admin Validate SCF With Detected Hardware
    [Documentation]
    ...  KW for SCF validation with Detected Hardware. SCF can be provided as input argument:
    ...  - if valued with absolute file path of stored SCF
    ...  - if empty, current SCF will be collected and validated.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter                       | Man. | Description                                                                                      |
    ...  | scf_path_file                   | No   | SCF file  path                                                                                   |
    ...  | skip_param_rel_err              | No   | skip parameter relation errors                                                                   |
    ...  | alias                           | No   | alias of admin instance                                                                          |
    ...  | export_type                     | No   | configuration, configurationAndRuntimeObjects or runtimeObjects                                  |
    ...  | timeout                         | No   | time to wait for positive procedure result                                                       |
    ...  | with_auto_configured_parameters | No   | Save also auto-configured parameters (CB013031). Possible values: ${TRUE} or ${FALSE}.           |
    ...  |                                          Default is ${TRUE}. If exportType is runtimeObjects, this parameter will be ignored              |
    ...
    ...  *RETURN*
    ...  | Parameter                     | Description                               |
    ...  | detected_hardware_errors_file | Path to detected_hardware_errors_file.txt |
    ...
    [Arguments]  ${scf_path_file}=${EMPTY}  ${skip_param_rel_err}=${TRUE}  ${alias}=default  ${export_type}=configuration  ${timeout}=180
    ...  ${with_auto_configured_parameters}=${TRUE}

    ${KW_err}=  Set Variable  No support for "validateScf"

    ${verdict}  ${result}=  Run Keyword And Ignore Error
    ...  Validate Scf Online  scf_file=${scf_path_file}  validation_type=DETECTED_HW  skip_parameter_relation_errors=${skip_param_rel_err}
    ...  timeout=${timeout}  alias=${alias}

    ${KW_exception}  Run Keyword And Return Status  Should contain  ${result}  ${KW_err}
    Run Keyword If  ${KW_exception}  Run Keywords
    ...  Log  Validate SCF With Detected Hardware not available in Admin CLI!  level=WARN
    ...  AND  Return From Keyword

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${scf_file_name}=  Set Variable  SCF_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.xml
    ${scf_path_file}=  Run Keyword If  '${scf_path_file}' == '${EMPTY}'
    ...  Set Variable  ${Test Results Dir}/SCF_Validation/${scf_file_name}
    ...  ELSE
    ...  Set Variable  ${scf_path_file}

    ${scf_path_folder}  ${scf_name}=  Split Path  ${scf_path_file}

    Run Keyword If  '${scf_path_file}' != '${EMPTY}'
    ...  Get Current Scf File  local_dir_path=${scf_path_folder}  file_name=${scf_file_name}  timeout=60  connection=${alias}
    ...  export_type=${export_type}  with_auto_configured_parameters=${with_auto_configured_parameters}

    Log  ${\n}=============  console=True
    Log  Validate SCF: ${scf_path_file}  console=True
    FOR  ${cycle}  IN RANGE  1  4
        Log  ${\n}=====================  console=True
        Log  SCF Validation cycle: ${cycle}  console=True
        ${errors_dict}  Validate Scf Online  scf_file=${scf_path_file}  validation_type=DETECTED_HW
        ...  skip_parameter_relation_errors=${skip_param_rel_err}  timeout=${timeout}  alias=${alias}
        Log  ${\n}=====================================  console=True
        Log  SCF Validation with Detected Hardware  console=True
        ${detectedhardwareErrorsSize}=  Get Length  ${errors_dict["requestMessage"]["detectedHwValidationResult"]["logs"]}
        ${detectedhardware_err_evaluated}  Evaluate  str(${errors_dict["requestMessage"]["detectedHwValidationResult"]})
        ${detectedhardware_errors_file}  Set Variable
        ...  ${Test Results Dir}/SCF_Validation/Detected_Hardware_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
        Append To File  ${detectedhardware_errors_file}  ${detectedhardware_err_evaluated}
        Run Keyword If  "${errors_dict["requestMessage"]["detectedHwValidationResult"]["status"]}"!="OK" and ${detectedhardwareErrorsSize}!=0
        ...  Run Keywords
        ...  Log  Detected Hardware Errors Count: ${hardwareErrorsSize}  level=INFO  console=True
        ...  AND  Log  Detected Hardware Errors Verdict: Parameter validation errors present, please check ${detectedhardware_errors_file}
        ...  level=WARN
        ...  ELSE  Run Keywords
        ...  Log  Detected Hardware Errors Count: ${detectedhardwareErrorsSize}  level=INFO  console=True
        ...  AND  Log  Detected Hardware Errors Verdict: Hardware relation validation succeeded. There are no detected hardware errors.  level=INFO
        ...  console=True
        Run Keyword If  ${detectedhardwareErrorsSize} == 0
        ...  Return From Keyword  ${detectedhardwareErrorsSize}
    END
    [Return]  ${detectedhardwareErrorsSize}

Admin Get CELL Ids list
    [Documentation]
    ...  Helper keyword providing NR or LTE cells Ids for FDD+TDD and IOT (inband, guardband and standalone) technologies .
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
    ...  | Parameter         | Description               |
    ...  | CELL_IDS_LIST     | List of FDD+TDD cells Ids |
    ...  | IOT_CELL_IDS_LIST | List of IOT cells Ids     |

    [Arguments]  ${alias}
    ${alias_upper}=  Convert to Uppercase  ${alias}
    ${CELL_className}=  Run Keyword If  '${${alias_upper}}[${alias_upper}_TECH']'=='LTE'  Set Variable  LNCEL
    ...  ELSE IF  '${${alias_upper}}[${alias_upper}_TECH']'=='NR'  Set Variable  NRCEL
    ${CELL_ID_LIST}=  Get Ids For All  ${CELL_className}  alias=${alias}
    Sort List  ${CELL_ID_LIST}
    ${CELL_IDS_LIST}=  Create List
    ${IOT_CELL_IDS_LIST}=  Create List
    FOR  ${item}  IN  @{CELL_ID_LIST}
        ${CELL_PARAM_LIST}=  Get Parameters For  ${CELL_className}  ${item}  alias=${alias}
        ${CELL_technology_found}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_PARAM_LIST['technology']}
        ${CELL_cellTechnology_found}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_PARAM_LIST['nbIoTCell']['cellTechnology']}
        ${CELL_nbIoTMode_found}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_PARAM_LIST['nbIoTMode']}
        Run Keyword If  ${CELL_technology_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['technology']}'=='FDD' or '${CELL_PARAM_LIST['technology']}'=='TDD'
        ...  Append To List  ${CELL_IDS_LIST}  ${CELL_PARAM_LIST['id']}
        Run Keyword If  ${CELL_cellTechnology_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['nbIoTCell']['cellTechnology']}'=='NB-IoT-FDD'
        ...  Append To List  ${IOT_CELL_IDS_LIST}  ${CELL_PARAM_LIST['nbIoTCell']['distName']}
        Run Keyword If  ${CELL_technology_found} and ${CELL_nbIoTMode_found}
        ...  Run Keyword If  '${CELL_PARAM_LIST['technology']}'=='NB-IoT-FDD' and '${CELL_PARAM_LIST['nbIoTMode']}'=='standalone'
        ...  Append To List  ${IOT_CELL_IDS_LIST}  ${CELL_PARAM_LIST['id']}
    END
    Sort List  ${CELL_IDS_LIST}
    Sort List  ${IOT_CELL_IDS_LIST}

    [Return]  ${CELL_IDS_LIST}  ${IOT_CELL_IDS_LIST}

Admin reset and Infomodel reconnect sessions
    [Documentation]
    ...  Helper KW for Admin reset and Infomodel reconnect sessions based on following triggers:
    ...  - SOAMIF change
    ...  - Admin issues
    ...  - on demand
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man.  | Default | Description                                                             |
    ...  | reset_req         | Yes   |         | request for Admin reset and Infomodel reconnect sessions: True or False |
    ...  | alias             | Yes   |         | alias of admin/admin_infomodel instance: Master or Slave                |
    ...  | infomodel_reset   | Yes   |  True   | Possible values: True, False. If False - only ADMIN reset is performed  |

    [Arguments]  ${reset_req}  ${alias}  ${infomodel_reset}=True

    ${soamif_exception}=  Set Variable  Invalid soamIf version

    ${verdict}  ${result}=  Run Keyword And Ignore Error  Get Mrbts State  timeout=60  alias=${alias}
    Run Keyword If  '${verdict}' == 'PASS' and '${reset_req}' == '${False}'  Run Keywords
    ...  Log  No need for Admin reset and Infomodel reconnect sessions.  console=True
    ...  AND  Return From Keyword

    ${filepath}=  Set Variable  ${BTSFiles}/${alias}
    ${soamif_change_check}=  Run Keyword And Return Status  Should Contain  ${result}  ${soamif_exception}

    ${reset_reason}=  Set Variable If  ${reset_req}  on demand
    ...  ${soamif_change_check}  due to Admin soamif change detected: ${result}
    ...  '${verdict}' != 'PASS  due to Admin error: ${result}

    Log  Admin reset is being performed ${reset_reason}  console=True
    Reset Admin  alias=${alias}
    Sleep  3s

    Run Keyword If  '${infomodel_reset}'=='True'  Run Keywords
    ...  Log  Infomodel reconnect session is being performed ${reset_reason}  console=True
    ...  AND  Infomodel reconnect session  alias=${alias}  connection_type=${connection_type_${alias}}
    ...  AND  Sleep  3s

    ${status}=  Run Keyword And Return Status  Get Mrbts State  timeout=60  alias=${alias}

    ${action}=  Set Variable If  '${infomodel_reset}'=='True'  Admin reset and Infomodel reconnect sessions
    ...  '${infomodel_reset}'=='False'  Admin reset

    Run Keyword If  ${status}
    ...  Log  Admin and Infomodel connections up after ${action}  console=True
    ...  ELSE  Run Keywords
    ...  Log  Admin and/or Infomodel connections are failed after ${action}  level=ERROR
    ...  AND  Fail  Admin and/or Infomodel connections are failed after ${action}

Admin Get Shared And Dedicated RM List for Master and Slave
    [Documentation]
    ...  Generic keyword providing shared and dedicated radio modules via Admin for Master-Slave configurations
    ...  KW will return 4 lists: Master_Shared_RMOD_list, Slave_Shared_RMOD_list, Master_dedicated_RMOD_list, Slave_dedicated_RMOD_list
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter             | Man.  | Default | Description                    |
    ...  | alias_master          | Yes   | Master  | alias of master admin instance |
    ...  | alias_slave           | Yes   | Slave   | alias of slave admin instance  |
    ...
    ...  *RETURN*
    ...  | Parameter                  | Description                   |
    ...  | Master_Shared_RMOD_list    | List of Master shared RMOD    |
    ...  | Slave_Shared_RMOD_list     | List of Slave shared RMOD     |
    ...  | Master_dedicated_RMOD_list | List of Master dedicated RMOD |
    ...  | Slave_dedicated_RMOD_list  | List of Slave dedicated RMOD  |

    [Arguments]  ${alias_master}=Master  ${alias_slave}=Slave

    ${Master_RMOD_id_list}=  Get Ids For All  RMOD  alias=${alias_master}
    Sort List  ${Master_RMOD_id_list}
    ${Slave_RMOD_id_list}=  Get Ids For All  RMOD  alias=${alias_slave}
    Sort List  ${Slave_RMOD_id_list}

    Get RMOD SN List  ${alias_master}
    Get RMOD SN List  ${alias_slave}

    ${Master_SN_RMOD_id_mapping}=  Create Dictionary
    ${Slave_SN_RMOD_id_mapping}=  Create Dictionary
    ${Shared_RMOD_SN_List}=  Create List  @{EMPTY}
    ${Master_Dedicated_RMOD_SN_List}=  Create List  @{EMPTY}
    ${Slave_Dedicated_RMOD_SN_List}=  Create List  @{EMPTY}
    ${Master_shared_RMOD_list}=  Create List  @{EMPTY}
    ${Slave_shared_RMOD_list}=  Create List  @{EMPTY}
    ${Master_dedicated_RMOD_list}=  Create List  @{EMPTY}
    ${Slave_dedicated_RMOD_list}=  Create List  @{EMPTY}

    FOR  ${SN_item}  IN  @{MASTER_RMOD_SN_list}
        Set To Dictionary  ${Master_SN_RMOD_id_mapping}  ${SN_item[0]}  ${SN_item[1]}
    END

    FOR  ${SN_item}  IN  @{SLAVE_RMOD_SN_list}
        Set To Dictionary  ${Slave_SN_RMOD_id_mapping}  ${SN_item[0]}  ${SN_item[1]}
    END

    ${dictionary_keys}=  Get Dictionary Keys  ${Slave_SN_RMOD_id_mapping}
    FOR  ${SN_item}  IN  @{MASTER_RMOD_SN_list}
        Run Keyword If  '${SN_item[0]}' in @{dictionary_keys}  Append To List  ${Shared_RMOD_SN_List}  ${SN_item[0]}
        ...  ELSE  Append To List  ${Master_Dedicated_RMOD_SN_List}  ${SN_item[0]}
    END

    FOR  ${SN_item}  IN  @{SLAVE_RMOD_SN_list}
        Run Keyword If  '${SN_item[0]}' not in ${Shared_RMOD_SN_List}  Append To List  ${Slave_Dedicated_RMOD_SN_List}  ${SN_item[0]}
    END

    FOR  ${SN_item}  IN  @{Shared_RMOD_SN_List}
        ${value}=  Get From Dictionary  ${Master_SN_RMOD_id_mapping}  ${SN_item}
        Append To List  ${Master_shared_RMOD_list}  ${value}
        ${value}=  Get From Dictionary  ${Slave_SN_RMOD_id_mapping}  ${SN_item}
        Append To List  ${Slave_shared_RMOD_list}  ${value}
    END

    FOR  ${SN_item}  IN  @{Master_Dedicated_RMOD_SN_List}
        ${value}=  Get From Dictionary  ${Master_SN_RMOD_id_mapping}  ${SN_item}
        Append To List  ${Master_dedicated_RMOD_list}  ${value}
    END

    FOR  ${SN_item}  IN  @{Slave_Dedicated_RMOD_SN_List}
        ${value}=  Get From Dictionary  ${Slave_SN_RMOD_id_mapping}  ${SN_item}
        Append To List  ${Slave_dedicated_RMOD_list}  ${value}
    END

    Set Test Variable  ${Master_SN_RMOD_id_mapping}
    Set Test Variable  ${Slave_SN_RMOD_id_mapping}

    [Return]  ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}

Get RMOD SN List
    [Arguments]  ${alias}
    ${alias_connection}=  Convert to Uppercase  ${alias}
    ${RMOD_SN_list}=  Create List  @{EMPTY}
    ${RMOD_param}=  Get Parameters For All  RMOD  alias=${alias}
    FOR  ${item}  IN  @{RMOD_param}
        ${Rmod_label}=  Fetch From Right  ${item.id}  /
        @{temp}=  Create List  ${item.serialNumber}  ${item.id}
        Append To List  ${RMOD_SN_list}  ${temp}
    END
    Sort List  ${RMOD_SN_list}
    Set Test Variable  ${${alias_connection}_RMOD_SN_list}  ${RMOD_SN_list}

Admin Check BTS RAT Procedural State
    [Documentation]
    ...  Helper keyword checking BTS each RAT Procedural State based on cells state: at least one cell should be with
    ...  operationalState=Enabled, availabilityStatus=Online
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | Yes  |         | alias of admin instance |
    ...  | timeout   | No   | 90 sec  | timeout                 |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description |
    ...  | Passed or Failed     | Fails if the given condition is not true |

    [Arguments]  ${alias}  ${timeout}=90
    ${NR_cells_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${NR_cells_operational}=  Run Keyword If  ${NR_cells_list}  Run Keyword And Return Status
    ...  Assert Any  class_name=NRCEL  parameters=operationalState=${Enabled_}  timeout=${timeout}  connection=${alias}

    ${LTE_cells_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${LTE_cells_operational}=  Run Keyword If  ${LTE_cells_list}  Run Keyword And Return Status
    ...  Assert Any  class_name=LNCEL  parameters=operationalState=${Enabled_}  timeout=${timeout}  connection=${alias}

    ${WCDMA_cells_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${WCDMA_cells_operational}=  Run Keyword If  ${WCDMA_cells_list}  Run Keyword And Return Status
    ...  Assert Any  class_name=WNCEL  parameters=operationalState=${Enabled_}  timeout=${timeout}  connection=${alias}

    ${GSM_cells_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${GSM_cells_operational}=  Run Keyword If  ${GSM_cells_list}  Run Keyword And Return Status
    ...  Assert Any  class_name=GNCEL  parameters=operationalState=${Enabled_}  timeout=${timeout}  connection=${alias}

    Run Keyword If  ${NR_cells_list}  Run Keyword If  ${NR_cells_operational}
    ...  Log  NR RAT - ProceduralState: OnAir  level=INFO  console=True
    Run Keyword If  ${NR_cells_list}  Run Keyword If  not ${NR_cells_operational}  Run Keywords
    ...  Log  NR RAT - ProceduralState: not OnAir!  level=ERROR
    ...  AND  Fail  NR RAT - ProceduralState: not OnAir!

    Run Keyword If  ${LTE_cells_list}  Run Keyword If  ${LTE_cells_operational}
    ...  Log  LTE RAT - ProceduralState: OnAir  level=INFO  console=True
    Run Keyword If  ${LTE_cells_list}  Run Keyword If  not ${LTE_cells_operational}  Run Keywords
    ...  Log  LTE RAT - ProceduralState: not OnAir!  level=ERROR
    ...  AND  Fail  LTE RAT - ProceduralState: not OnAir!

    Run Keyword If  ${WCDMA_cells_list}  Run Keyword If  ${WCDMA_cells_operational}
    ...  Log  WCDMA RAT - ProceduralState: OnAir  level=INFO  console=True
    Run Keyword If  ${WCDMA_cells_list}  Run Keyword If  not ${WCDMA_cells_operational}  Run Keywords
    ...  Log  WCDMA RAT - ProceduralState: not OnAir!  level=ERROR
    ...  AND  Fail  WCDMA RAT - ProceduralState: not OnAir!

    Run Keyword If  ${GSM_cells_list}  Run Keyword If  ${GSM_cells_operational}
    ...  Log  GSM RAT - ProceduralState: OnAir  level=INFO  console=True
    Run Keyword If  ${GSM_cells_list}  Run Keyword If  not ${GSM_cells_operational}  Run Keywords
    ...  Log  GSM RAT - ProceduralState: not OnAir!  level=ERROR
    ...  AND  Fail  GSM RAT - ProceduralState: not OnAir!

Admin Check if BTS cells are unblocked
    [Documentation]
    ...  Helper keyword checking BTS configured cell(s) blockingState info. If needed perform unblock BTS cell(s).
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    [Arguments]  ${alias}=default
    ${BTS_NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    FOR  ${item}  IN  @{BTS_NR_CELL_list}
        ${status}=  Run Keyword And Return Status
        ...  Assert  class_name=NRCEL  id=${item}  parameters=blockingState=${Blocked_}  timeout=5  connection=${alias}
        Run Keyword If  ${status}  Run Keywords
        ...  coam.Unblock Cell  dist_name=${item}  connection=${alias}
        ...  AND  Sleep  30s  Wait for Cell ${item} recovery
        ...  AND  Log  Cell ${item} unblock recovery indicated  console=True
    END
    ${BTS_LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    FOR  ${item}  IN  @{BTS_LTE_CELL_list}
        ${status}=  Run Keyword And Return Status
        ...  Assert  class_name=LNCEL  id=${item}  parameters=blockingState=${Blocked_}  timeout=5  connection=${alias}
        Run Keyword If  ${status}  Run Keywords
        ...  coam.Unblock Cell  dist_name=${item}  connection=${alias}
        ...  AND  Sleep  30s  Wait for Cell ${item} recovery
        ...  AND  Log  Cell ${item} unblock recovery indicated  console=True
    END
    ${BTS_WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    FOR  ${item}  IN  @{BTS_WCDMA_CELL_list}
        ${status}=  Run Keyword And Return Status
        ...  Assert  class_name=WNCEL  id=${item}  parameters=blockingState=${Blocked_}  timeout=5  connection=${alias}
        Run Keyword If  ${status}  Run Keywords
        ...  coam.Unblock Cell  dist_name=${item}  connection=${alias}
        ...  AND  Sleep  30s  Wait for Cell ${item} recovery
        ...  AND  Log  Cell ${item} unblock recovery indicated  console=True
    END
    ${BTS_GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    FOR  ${item}  IN  @{BTS_GSM_CELL_list}
        ${status}=  Run Keyword And Return Status
        ...  Assert  class_name=GNCEL  id=${item}  parameters=blockingState=${Blocked_}  timeout=5  connection=${alias}
        Run Keyword If  ${status}  Run Keywords
        ...  coam.Unblock Cell  dist_name=${item}  connection=${alias}
        ...  AND  Sleep  30s  Wait for Cell ${item} recovery
        ...  AND  Log  Cell ${item} unblock recovery indicated  console=True
    END

Admin Check if NR cells are unblocked
    [Documentation]
    ...  Helper keyword checking CELL blocking state info. If needed perform unblock CELL.
    ...
    ...  *AUTHOR*
    ...  horea.olar@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    [Arguments]  ${alias}=default
    ${BTS_NR_CELL_list}=  Get Ids For All  NRCEL  alias=${alias}
    FOR  ${item}  IN  @{BTS_NR_CELL_list}
        ${status}=  Run Keyword And Return Status  Assert  NRCEL  ${item}  blockingState=${Blocked_}  timeout=3  alias=${alias}
        Run Keyword If  ${status}  Run Keywords
        ...  coam.Unblock Cell  dist_name=${item}  connection=${alias}
        ...  AND  Sleep  30s  Wait for Cell ${item} establish
        ...  AND  Log  Cell ${item} unblock indicated  console=True
    END

Admin Check if SBTS TRX are unblocked
    [Documentation]
    ...  Helper keyword checking SBTS GSM TRXs blocking state info. If needed perform unblock SBTS GSM TRX.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    [Arguments]  ${alias}=default
    ${SBTS_GSM_CELL_list}=  Get Ids For All  GNCEL  alias=${alias}
    FOR  ${item}  IN  @{SBTS_GSM_CELL_list}
        ${TRX_list}=  Query Infomodel  get list ${item}/CARRIERGROUPC_R-*  alias=${alias}
        Unblock SBTS GSM TRXs  ${TRX_list}  ${alias}
    END

Unblock SBTS GSM TRXs
    [Arguments]  ${TRX_list}  ${alias}=default
    FOR  ${item}  IN  @{TRX_list}
        ${Obj_info}=  Query infomodel  query=get object ${item['dist_name']}  alias=${alias}
        ${Obj_stateInfo}=  Run Keyword And Return Status  Variable Should Exist  ${Obj_info['stateInfo']}
        Run Keyword If  ${Obj_stateInfo}  Run Keyword If  '${Obj_info['stateInfo']['blockingState']}' in '${Blocked_}'  Run Keywords
        ...  coam.Unblock GSMTRX  dist_name=${item['dist_name']}  timeout=180  connection=${alias}
        ...  AND  Log  SBTS GSM ${item} unblock indicated  console=True
        Run Keyword If  not ${Obj_stateInfo}  Run Keyword If  '${Obj_info['blockingState']}' in '${Blocked_}'  Run Keywords
        ...  coam.Unblock GSMTRX  dist_name=${item['dist_name']}  timeout=180  connection=${alias}
        ...  AND  Log  SBTS GSM ${item} unblock indicated  console=True
    END

Admin Get Reset info based on BTS SW Precheck
    [Documentation]
    ...  Helper keyword providing info related to BTS reset behavior. KW is returning BTS reset number info.
    ...  If SW Precheck doesn't provide resetCoverage info, set by default reset number 1 (keep legacy behavior)
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter  | Man. | Default | Description             |
    ...  | SW_package | Yes  |         | SW package name         |
    ...  | alias      | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter       | Description                                           |
    ...  | ${reset_number} | BTS reset number expected after SWDL using SW_package |

    [Arguments]  ${SW_package}  ${timeout}=120  ${alias}=default
    ${reset_number}=  Set Variable  0
    ${output_dict}=  Software Precheck Local  sw_package=${SW_package}  precheck_type=RebootCheck  timeout=${timeout}  alias=${alias}
    ${resetCoverage_found}=  Run Keyword And Return Status
    ...  Variable Should Exist  ${output_dict['reportResult']['resetCoverageReport'][0]['resetCoverage']}
    Set Test Variable  ${resetCoverage_found}
    Return From Keyword If  not ${resetCoverage_found}  1
    ${reset_info}=  Set Variable  ${output_dict['reportResult']['resetCoverageReport'][0]['resetCoverage']}
    Return From Keyword If  len(${reset_info}) == 0  ${reset_number}
    ${reset_number}=  Run Keyword If  len(${reset_info}) != 0 and '${reset_info[0]}' == 'Site'  Evaluate  ${reset_number} + 1
    [Return]  ${reset_number}

Admin Get RMOD L3 Protocol Info
    [Documentation]
    ...  Helper keyword providing RMOD L3 protocol info.
    ...  KW is returning a dictionary with:
    ...  - key: RMOD distName
    ...   -value: l3Protocol
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                      |
    ...  | RMOD_L3Protocol_dict | RMOD L3 protocol dictionary info |

    [Arguments]  ${alias}=default
    ${RMOD_id_list}=  Get Ids For All  RMOD  alias=${alias}
    Sort List  ${RMOD_id_list}
    ${RMOD_L3Protocol_dict}=  Create Dictionary
    FOR  ${item}  IN  @{RMOD_id_list}
        ${RMOD_param_list}=  Get Parameters For  RMOD  ${item}  alias=${alias}
        Set To Dictionary  ${RMOD_L3Protocol_dict}  ${RMOD_param_list['id']}  ${RMOD_param_list['l3Protocol']}
    END
    [Return]  ${RMOD_L3Protocol_dict}

Admin Get NR CELL list with cell info
    [Documentation]
    ...  Keyword providing BTS NR CELL information specified by ${cell_list} argument as described below:
    ...   - if ${cell_list} is empty, all BTS NR CELL information will be provided (by default behavior)
    ...   - if ${cell_list} is not empty, only specified BTS NR CELL list information will be provided
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default  | Description             |
    ...  | cell_list | No   | @{EMPTY} | cell list ids           |
    ...  | alias     | No   | default  | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter    | Description              |
    ...  | NR_CELL_info | List of NR cells details |
    ...
    ...  *EXAMPLE*
    ...  | ${NR_CELL_info}= | Admin Get NR CELL list with cell info | alias=Master |

    [Arguments]  ${cell_list}=@{EMPTY}  ${alias}=default
    ${NR_CELL_parameters_list}=  Admin Get NR CELL list with cell parameters info  cell_list=${cell_list}  alias=${alias}
    ${NR_CELL_info}=  Create List
    FOR  ${item}  IN  @{NR_CELL_parameters_list}
        ${channel_group_id_list}=  rfs_general.Get List of Configured Channel Groups  carrierList=${item[4]}
        ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}  ${TX_Dependency}
        ...  ${RX_Dependency}  ${CELL_TX_RX_dictionary}=  rfs_general.Get Cell TX RX channelGroup and state info  ${channel_group_id_list}
        ...  carrierList=${item[4]}  alias=${alias}
        @{temp}=  Create List  ${item[0]}  ${item[1]}  ${item[2]}  ${item[3]}  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}
        ...  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}  ${TX_Dependency}  ${RX_Dependency}  ${CELL_TX_RX_dictionary}
        Append To List  ${NR_CELL_info}  ${temp}
    END
    Sort List  ${NR_CELL_info}
    [Return]  ${NR_CELL_info}

Admin Get LTE CELL list with cell info
    [Documentation]
    ...  Keyword providing BTS LTE CELL information specified by ${cell_list} argument as described below:
    ...   - if ${cell_list} is empty, all BTS LTE CELL information will be provided (by default behavior)
    ...   - if ${cell_list} is not empty, only specified BTS LTE CELL list information will be provided
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | cell_list | No   | @{EMPTY} | cell list ids          |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter    | Description                |
    ...  | LTE_CELL_info | List of LTE cells details |
    ...
    ...  *EXAMPLE*
    ...  | ${LTE_CELL_info}= | Admin Get LTE CELL list with cell info | alias=Master |

    [Arguments]  ${cell_list}=@{EMPTY}  ${alias}=default
    ${LTE_CELL_parameters_list}=  Admin Get LTE CELL list with cell parameters info  cell_list=${cell_list}  alias=${alias}
    ${LTE_CELL_info}=  Create List
    FOR  ${item}  IN  @{LTE_CELL_parameters_list}
        ${channel_group_id_list}=  rfs_general.Get List of Configured Channel Groups  carrierList=${item[6]}
        ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}  ${TX_Dependency}
        ...  ${RX_Dependency}  ${CELL_TX_RX_dictionary}=  rfs_general.Get Cell TX RX channelGroup and state info  ${channel_group_id_list}
        ...  carrierList=${item[6]}  alias=${alias}
        @{temp}=  Create List  ${item[0]}  ${item[1]}  ${item[2]}  ${item[3]}  ${item[4]}  ${item[5]}  ${TX_Total}  ${RX_Total}  ${TX_Online}
        ...  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}  ${TX_Dependency}  ${RX_Dependency}  ${CELL_TX_RX_dictionary}
        Append To List  ${LTE_CELL_info}  ${temp}
    END
    Sort List  ${LTE_CELL_info}
    [Return]  ${LTE_CELL_info}

Admin Get NR CELL list with cell parameters info
    [Arguments]  ${cell_list}=@{EMPTY}  ${alias}=default
    ${cell_list_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${cell_list}
    ${NR_cells_info_list}=  Get Cell List  alias=${alias}
    ${NR_CELL_param_list}=  Create List
    FOR  ${item}  IN  @{NR_cells_info_list['cells']['nr']}
        ${cond}=  Create Long String  ('${cell_list_isEmpty}' == 'False' and '${item['id']['internal']}' not in ${cell_list}) or
        ...  ('${item['technology']}' not in ['FDD','TDD'])
        Continue For Loop If  ${cond}
        ${actSuperCell}  ${actBeamforming}  ${numOfSubSectors}=  rfs_scf.Get Cell Parameters from SCF  actSuperCell  actBeamforming  numOfSubSectors
        ...  cell_dist_name=${item['id']['configuration']}  alias=${alias}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${actSuperCell}
        ...  ${actBeamforming}
        ...  ${numOfSubSectors}
        ...  ${item['carrierList']}
        Append To List  ${NR_CELL_param_list}  ${temp}
    END
    Sort List  ${NR_CELL_param_list}
    [Return]  ${NR_CELL_param_list}

Admin Get LTE CELL list with cell parameters info
    [Arguments]  ${cell_list}=@{EMPTY}  ${alias}=default
    ${cell_list_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${cell_list}
    ${LTE_cells_info_list}=  coam.Get Cell List  alias=${alias}
    ${LTE_CELL_param_list}=  Create List
    FOR  ${item}  IN  @{LTE_cells_info_list['cells']['lte']}
        ${cond}=  Create Long String  ('${cell_list_isEmpty}' == 'False' and '${item['id']['internal']}' not in ${cell_list}) or
        ...  ('${item['technology']}' not in ['FDD','TDD'])
        Continue For Loop If  ${cond}
        ${cell_technology_distName}=  Get cell technology distName info  ${item['id']['configuration']}  ${item['technology']}  ${alias}
        ${actSuperCell}  ${dlMimoMode}  ${syncSigTxMode}=  rfs_scf.Get Cell Parameters from SCF  actSuperCell  dlMimoMode  syncSigTxMode
        ...  cell_dist_name=${cell_technology_distName}  alias=${alias}
        ${actOtdoa}  ${actPrsTxDiv}=  rfs_scf.Get Cell Parameters from SCF  actOtdoa  actPrsTxDiv  cell_dist_name=${item['id']['configuration']}
        ...  alias=${alias}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${actSuperCell}
        ...  ${dlMimoMode}
        ...  ${syncSigTxMode}
        ...  ${actOtdoa}
        ...  ${actPrsTxDiv}
        ...  ${item['carrierList']}
        Append To List  ${LTE_CELL_param_list}  ${temp}
    END
    Sort List  ${LTE_CELL_param_list}
    [Return]  ${LTE_CELL_param_list}

Admin Get FHS Ids
    [Documentation]
    ...  Keyword providing FHS Ids from Admin.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter   | Description  |
    ...  | FHS_id_list | FHS Ids list |
    ...
    [Arguments]  ${alias}=default
    ${FHS_id_list}=  Create List
    ${FHS_info_list}=  Get Fhs List  connection=${alias}
    FOR  ${item}  IN  @{FHS_info_list}
        Append To List  ${FHS_id_list}  ${item['id']['internal']}
    END
    Sort List  ${FHS_id_list}
    [Return]  ${FHS_id_list}

Admin Check FHS state
    [Documentation]
    ...  Keyword checking FHS states from Admin.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter               | Man. | Default | Description                      |
    ...  | FHS_id                  | Yes  |         | FHS Id to be checked             |
    ...  | exp_operationalState    | Yes  |         | expected FHS operationalState    |
    ...  | exp_availabilityStatus  | Yes  |         | expected FHS availabilityStatus  |
    ...  | exp_administrativeState | Yes  |         | expected FHS administrativeState |
    ...  | alias                   | Yes  |         | alias of admin instance          |
    ...
    ...  *RETURN*
    ...  KW is passed if expected states are correlated with FHS states, otherwise failed

    [Arguments]  ${FHS_id}  ${exp_operationalState}  ${exp_availabilityStatus}  ${exp_administrativeState}  ${alias}
    ${FHS_info}=  Get Fhs By Id  dist_name=${FHS_id}  connection=${alias}
    ${availabilityStatus_status}=  Run Keyword and Return Status  Variable Should Exist  ${FHS_info['stateInfo']['availabilityStatus']}
    ${condition}=  Run Keyword If  ${availabilityStatus_status}
    ...  Create Long String  '${FHS_info['stateInfo']['operationalState']}' in '${exp_operationalState}' and
    ...  '${FHS_info['stateInfo']['availabilityStatus']}' in '${exp_availabilityStatus}' and
    ...  '${FHS_info['stateInfo']['administrativeState']}' in '${exp_administrativeState}'
    ...  ELSE
    ...  Create Long String  '${FHS_info['stateInfo']['operationalState']}' in '${exp_operationalState}' and
    ...  '${FHS_info['stateInfo']['administrativeState']}' in '${exp_administrativeState}'
    Should Be True  ${condition}

Admin Get WCDMA CELL list with cell info
    [Documentation]
    ...  Keyword providing BTS WCDMA CELL information specified by ${cell_list} argument as described below:
    ...   - if ${cell_list} is empty, all BTS WCDMA CELL information will be provided (by default behavior)
    ...   - if ${cell_list} is not empty, only specified BTS WCDMA CELL list information will be provided
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default  | Description             |
    ...  | cell_list | No   | @{EMPTY} | cell list ids           |
    ...  | alias     | No   | default  | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter       | Description                 |
    ...  | WCDMA_CELL_info | List of WCDMA cells details |
    ...
    ...  *EXAMPLE*
    ...  | ${WCDMA_CELL_info}= | Admin Get WCDMA CELL list with cell info | alias=Slave |

    [Arguments]  ${cell_list}=@{EMPTY}  ${alias}=default
    ${WCDMA_CELL_parameters_list}=  Admin Get WCDMA CELL list with cell parameters info  cell_list=${cell_list}  alias=${alias}
    ${WCDMA_CELL_info}=  Create List
    FOR  ${item}  IN  @{WCDMA_CELL_parameters_list}
        ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}  ${TX_Dependency}
        ...  ${RX_Dependency}  ${CELL_TX_RX_state}=  Get Cell TX RX state info  carrierList=${item[1]}  alias=${alias}
        @{temp}=  Create List  ${item[0]}  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}
        ...  ${RX_Degraded}  ${TX_Dependency}  ${RX_Dependency}  ${CELL_TX_RX_state}
        Append To List  ${WCDMA_CELL_info}  ${temp}
    END
    Sort List  ${WCDMA_CELL_info}
    [Return]  ${WCDMA_CELL_info}

Admin Get WCDMA CELL list with cell parameters info
    [Arguments]  ${cell_list}=@{EMPTY}  ${alias}=default
    ${cell_list_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${cell_list}
    ${WCDMA_cells_info_list}=  coam.Get Cell List  alias=${alias}
    Set Test Variable  ${WCDMA_cells_info_list}
    ${WCDMA_CELL_param_list}=  Create List
    FOR  ${item}  IN  @{WCDMA_cells_info_list['cells']['wcdma']}
        Continue For Loop If  '${cell_list_isEmpty}' == 'False' and '${item['id']['internal']}' not in ${cell_list}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${item['carrierList']}
        Append To List  ${WCDMA_CELL_param_list}  ${temp}
    END
    Sort List  ${WCDMA_CELL_param_list}
    [Return]  ${WCDMA_CELL_param_list}

Admin Get BTS Synchronization Information
    [Documentation]
    ...  Keyword providing BTS Synchronization Information.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | Yes  |         | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter     | Description         |
    ...  | syncMode      | syncMode value      |
    ...  | syncInputType | syncInputType value |
    ...  | tuningMode    | tuningMode value    |
    ...
    ...  *EXAMPLE*
    ...  | Admin Get BTS Synchronization Information | Slave |

    [Arguments]  ${alias}
    ${output_dict}=  Get Synchronization Information  connection=${alias}  detailed_output=True
    ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${output_dict['requestMessage']}  syncMode
    ${syncMode}=  Set Variable If  ${status}  ${output_dict['requestMessage']['syncMode']}  None
    ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${output_dict['requestMessage']['syncSourceInfo'][0]}  syncInputType
    ${syncInputType}=  Set Variable If  ${status}  ${output_dict['requestMessage']['syncSourceInfo'][0]['syncInputType']}  None
    ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${output_dict['requestMessage']}  tuningMode
    ${tuningMode}=  Set Variable If  ${status}  ${output_dict['requestMessage']['tuningMode']}  None
    ${SMOD_id_list}=  Get Ids For All  class_name=SMOD  connection=${alias}
    FOR  ${SMOD_id}  IN  @{SMOD_id_list}
        ${SMOD_info}=  coam.Get Parameters  dist_name=${SMOD_id}  connection=${alias}
        Exit For Loop If  '${SMOD_info['activeRole']}' in ['Primary', 'None']
    END
    ${SMOD_serialNumber}=  Set Variable  ${SMOD_info['serialNumber']}
    ${SMOD_configDN}=  Set Variable  ${SMOD_info['configDN']}
    ${SMOD_info}=  Get Managed Objects  class_name=SMOD  connection=${alias}
    FOR  ${item}  IN  @{SMOD_info}
        Exit For Loop If  '${item['parameters']['serialNumber']}' == '${SMOD_serialNumber}'
    END
    ${SMOD_distName}=  Set Variable  ${item['distName']}
    ${CLOCK_info}=  Get Managed Objects  class_name=CLOCK  connection=${alias}
    FOR  ${item}  IN  @{CLOCK_info}
        ${status}=  Run Keyword And Return Status  Should Contain  ${item['distName']}  ${SMOD_distName}
        Exit For Loop If  '${status}' == 'True'
    END
    ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${item['parameters']}  syncHubRole
    ${syncHubRole}=  Set Variable If  ${status}  ${item['parameters']['syncHubRole']}  None
    ${CLOCK_A_info}=  Get Managed Objects  class_name=CLOCK_A  connection=${alias}
    FOR  ${item}  IN  @{CLOCK_A_info}
        Exit For Loop If  '${item['parameters']['sModDN']}' == '${SMOD_configDN}'
    END
    ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${item['parameters']}  syncMaster
    ${syncMaster}=  Set Variable If  ${status}  ${item['parameters']['syncMaster']}  None
    ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${item['parameters']}  holdOverModeUsed
    ${holdOverModeUsed}=  Set Variable If  ${status}  ${item['parameters']['holdOverModeUsed']}  None

    [Return]  ${syncMode}  ${syncInputType}  ${tuningMode}  ${syncHubRole}  ${syncMaster}  ${holdOverModeUsed}

Admin Check If BTS Objects Are Unlocked
    [Documentation]
    ...  Helper keyword used to recover BTS objects state.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter       | Man. | Default | Description                                |
    ...  | class_name      | Yes  |         | class_name label                           |
    ...  | timeout         | Yes  |         | time to wait for positive procedure result |
    ...  | recover_timeout | Yes  |         | time to wait for recovery BTS object       |
    ...  | connection      | Yes  |         | alias of admin instance                    |
    ...
    [Arguments]  ${class_name}  ${timeout}  ${recover_timeout}  ${connection}
    ${Obj_list}=  Get Ids For All  class_name=${class_name}  timeout=10  connection=${connection}
    Sort List  ${Obj_list}
    FOR  ${item}  IN  @{Obj_list}
        ${status}=  Run Keyword And Return Status
        ...  Assert  class_name=${class_name}  id=${item}  parameters=administrativeState=${Locked_}  timeout=5  connection=${connection}
        Run Keyword If  ${status}  Run Keywords
        ...  coam.Unlock  dist_name=${item}  timeout=${timeout}  connection=${connection}
        ...  AND  Sleep  ${recover_timeout}s  Wait for ${class_name} ${item} recovery
        ...  AND  Log  ${class_name} ${item} unlock recovery indicated  console=True
    END

Admin Get shared and dedicated module list for Master and Slave
    [Documentation]
    ...  Helper KW providing shared and dedicated module (RMOD or FHS) list from Master-Slave configurations
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter    | Man. | Default | Description                    |
    ...  | module_type  | Yes  |         | RMOD or FHS                    |
    ...  | alias_master | No   | Master  | alias of master admin instance |
    ...  | alias_slave  | No   | Slave   | alias of slave admin instance  |
    ...
    ...  *RETURN*
    ...  | Parameter                            | Description                     |
    ...  | Master_shared_module_list    | List of Master shared ${module_type}    |
    ...  | Slave_shared_module_list     | List of Slave shared ${module_type}     |
    ...  | Master_dedicated_module_list | List of Master dedicated ${module_type} |
    ...  | Slave_dedicated_module_list  | List of Slave dedicated ${module_type}  |

    [Arguments]  ${module_type}  ${alias_master}=Master  ${alias_slave}=Slave

    ${Master_RMOD_list}=  Get Ids For All  class_name=RMOD  connection=${alias_master}
    ${Slave_RMOD_list}=  Get Ids For All  class_name=RMOD  connection=${alias_slave}
    ${Master_FHS_list}=  Admin Get FHS Ids  alias=${alias_master}
    ${Slave_FHS_list}=  Admin Get FHS Ids  alias=${alias_slave}
    ${Master_module_list}=  Set Variable If  '${module_type}' == 'RMOD'  ${Master_RMOD_list}  '${module_type}' == 'FHS'  ${Master_FHS_list}
    ${Slave_module_list}=  Set Variable If  '${module_type}' == 'RMOD'  ${Slave_RMOD_list}  '${module_type}' == 'FHS'  ${Slave_FHS_list}
    Sort List  ${Master_module_list}
    Sort List  ${Slave_module_list}
    Set Test Variable  ${Master_module_list}
    Set Test Variable  ${Slave_module_list}

    Run Keyword If  '${module_type}' == 'RMOD'  Run Keywords
    ...  Get RMOD ID SN dict  ${alias_master}
    ...  AND  Get RMOD ID SN dict  ${alias_slave}
    ...  ELSE IF  '${module_type}' == 'FHS'  Run Keywords
    ...  Get FHS ID SN dict  ${alias_master}
    ...  AND  Get FHS ID SN dict  ${alias_slave}

    ${Master_shared_module_list}=  Create List  @{EMPTY}
    ${Slave_shared_module_list}=  Create List  @{EMPTY}
    ${Master_dedicated_module_list}=  Create List  @{EMPTY}
    ${Slave_dedicated_module_list}=  Create List  @{EMPTY}

    ${Master_shared_module_SN_list}=  Create List  @{EMPTY}
    ${Slave_shared_module_SN_list}=  Create List  @{EMPTY}
    ${Master_dedicated_module_SN_list}=  Create List  @{EMPTY}
    ${Slave_dedicated_module_SN_list}=  Create List  @{EMPTY}

    ${dictionary_keys_slave}=  Get Dictionary Keys  ${${alias_slave}_module_SN_ID_dict}
    ${dictionary_keys_master}=  Get Dictionary Keys  ${${alias_master}_module_SN_ID_dict}
    FOR  ${item}  IN  @{dictionary_keys_master}
        Run Keyword If  '${item}' in @{dictionary_keys_slave}
        ...  Append To List  ${Master_shared_module_SN_list}  ${item}
        ...  ELSE
        ...  Append To List  ${Master_dedicated_module_SN_list}  ${item}
    END
    FOR  ${item}  IN  @{dictionary_keys_slave}
        Run Keyword If  '${item}' in @{dictionary_keys_master}
        ...  Append To List  ${Slave_shared_module_SN_list}  ${item}
        ...  ELSE
        ...  Append To List  ${Slave_dedicated_module_SN_list}  ${item}
    END
    Sort List  ${Master_shared_module_SN_list}
    Sort List  ${Slave_shared_module_SN_list}
    Sort List  ${Master_dedicated_module_SN_list}
    Sort List  ${Slave_dedicated_module_SN_list}
    Lists Should Be Equal  ${Master_shared_module_SN_list}  ${Slave_shared_module_SN_list}
    ${shared_module_SN_list}=  Set Variable  ${Master_shared_module_SN_list}

    FOR  ${item}  IN  @{shared_module_SN_list}
        ${module_ID}=  Get From Dictionary  ${${alias_master}_module_SN_ID_dict}  ${item}
        Append To List  ${Master_shared_module_list}  ${module_ID}
        ${module_ID}=  Get From Dictionary  ${${alias_slave}_module_SN_ID_dict}  ${item}
        Append To List  ${Slave_shared_module_list}  ${module_ID}
    END

    FOR  ${item}  IN  @{Master_dedicated_module_SN_list}
        ${module_ID}=  Get From Dictionary  ${${alias_master}_module_SN_ID_dict}  ${item}
        Append To List  ${Master_dedicated_module_list}  ${module_ID}
    END

    FOR  ${item}  IN  @{Slave_dedicated_module_SN_list}
        ${module_ID}=  Get From Dictionary  ${${alias_slave}_module_SN_ID_dict}  ${item}
        Append To List  ${Slave_dedicated_module_list}  ${module_ID}
    END

    [Return]  ${Master_shared_module_list}  ${Slave_shared_module_list}  ${Master_dedicated_module_list}  ${Slave_dedicated_module_list}

Get RMOD ID SN dict
    [Arguments]  ${alias}
    ${module_SN_ID_dict}=  Create Dictionary
    ${module_ID_SN_dict}=  Create Dictionary
    FOR  ${item}  IN  @{${alias}_module_list}
        ${module_param}=  Get Parameters For  class_name=RMOD  id_num=${item}  connection=${alias}
        Set To Dictionary  ${module_SN_ID_dict}  ${module_param['serialNumber']}  ${module_param['id']}
        Set To Dictionary  ${module_ID_SN_dict}  ${module_param['id']}  ${module_param['serialNumber']}
    END
    Set Test Variable  ${${alias}_module_SN_ID_dict}  ${module_SN_ID_dict}
    Set Test Variable  ${${alias}_module_ID_SN_dict}  ${module_ID_SN_dict}

Get FHS ID SN dict
    [Arguments]  ${alias}
    ${FHS_info_list}=  Get Fhs List  connection=${alias}
    ${module_SN_ID_dict}=  Create Dictionary
    ${module_ID_SN_dict}=  Create Dictionary
    FOR  ${item}  IN  @{FHS_info_list}
        Set To Dictionary  ${module_SN_ID_dict}  ${item['serialNumber']}  ${item['id']['internal']}
        Set To Dictionary  ${module_ID_SN_dict}  ${item['id']['internal']}  ${item['serialNumber']}
    END
    Set Test Variable  ${${alias}_module_SN_ID_dict}  ${module_SN_ID_dict}
    Set Test Variable  ${${alias}_module_ID_SN_dict}  ${module_ID_SN_dict}

Get BBMOD ID SN dict
    [Arguments]  ${alias}
    ${BBMOD_SN_ID_dict}=  Create Dictionary
    ${BBMOD_ID_SN_dict}=  Create Dictionary
    ${BBMOD_list}=  Get Ids For All  class_name=BBMOD  connection=${alias}
    Sort List  ${BBMOD_list}
    FOR  ${item}  IN  @{BBMOD_list}
        ${BBMOD_param}=  Get Parameters For  class_name=BBMOD  id_num=${item}  connection=${alias}
        Set To Dictionary  ${BBMOD_SN_ID_dict}  ${BBMOD_param['serialNumber']}  ${BBMOD_param['id']}
        Set To Dictionary  ${BBMOD_ID_SN_dict}  ${BBMOD_param['id']}  ${BBMOD_param['serialNumber']}
    END
    Set Test Variable  ${${alias}_BBMOD_SN_ID_dict}  ${BBMOD_SN_ID_dict}
    Set Test Variable  ${${alias}_BBMOD_ID_SN_dict}  ${BBMOD_ID_SN_dict}

Get SMOD ID SN dict
    [Arguments]  ${alias}
    ${SMOD_SN_ID_dict}=  Create Dictionary
    ${SMOD_ID_SN_dict}=  Create Dictionary
    ${SMOD_list}=  coam.Get Ids For All  class_name=SMOD  connection=${alias}
    Sort List  ${SMOD_list}
    FOR  ${item}  IN  @{SMOD_list}
        ${SMOD_param}=  coam.Get Parameters For  class_name=SMOD  id_num=${item}  connection=${alias}
        Set To Dictionary  ${SMOD _SN_ID_dict}  ${SMOD_param['serialNumber']}  ${SMOD_param['id']}
        Set To Dictionary  ${SMOD_ID_SN_dict}  ${SMOD_param['id']}  ${SMOD_param['serialNumber']}
    END
    Set Test Variable  ${${alias}_SMOD_SN_ID_dict}  ${SMOD_SN_ID_dict}
    Set Test Variable  ${${alias}_SMOD_ID_SN_dict}  ${SMOD_ID_SN_dict}

Admin Perform LANE Operation
    [Documentation]
    ...  Helper keyword used to lock or unlock LANE object.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description                                |
    ...  | LANE_Id   | Yes  |         | LANE Id to be locked or unlocked           |
    ...  | operation | Yes  |         | Lock or Unlock operation                   |
    ...  | alias     | Yes  |         | alias of admin instance                    |
    ...  | timeout   | No   | 60      | time to wait for positive procedure result |
    ...
    [Arguments]  ${LANE_Id_list}  ${operation}  ${alias}  ${timeout}=60
    ${LANE_exp_operationalState}=  Set Variable If  '${operation}' == 'Lock'  ${Disabled_}  '${operation}' == 'Unlock'  ${Enabled_}
    Run Keyword If  '${operation}' == 'Lock'
    ...  Lock  dist_name=${LANE_Id_list}  timeout=${timeout}  connection=${alias}
    ...  ELSE IF  '${operation}' == 'Unlock'
    ...  Unlock  dist_name=${LANE_Id_list}  timeout=${timeout}  connection=${alias}
    Sleep  5s
    FOR  ${LANE_Id}  IN  @{LANE_Id_list}
        ${LANE_operationalState}=  Admin Get LANE Operational State  LANE_Id=${LANE_Id}  connection=${alias}
        ${LANE_operationalState}=  Strip String  ${LANE_operationalState}  characters='
        Run Keyword If  '${LANE_operationalState}' in '${LANE_exp_operationalState}'
        ...  Log  LANE Id ${LANE_Id} operationalState: ${LANE_operationalState}  console=True
        ...  ELSE  Run Keywords
        ...  Log  LANE Id ${LANE_Id} operationalState: ${LANE_operationalState}  console=True
        ...  AND  Fail  Improper LANE operationalState!
    END

Admin Check If LANE Objects Are Unlocked
    [Documentation]
    ...  Helper keyword used to recover LANE objects state.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter       | Man. | Default | Description                                |
    ...  | LANE_Id         | Yes  |         | LANE distinguished name                    |
    ...  | timeout         | Yes  |         | time to wait for positive procedure result |
    ...  | recover_timeout | Yes  |         | time to wait for recovery BTS object       |
    ...  | alias           | Yes  |         | alias of admin instance                    |
    ...
    [Arguments]  ${LANE_Id}  ${timeout}  ${recover_timeout}  ${alias}
    ${LANE_operationalState}=  Admin Get LANE Operational State  LANE_Id=${LANE_Id}  connection=${alias}
    ${LANE_operationalState}=  Strip String  ${LANE_operationalState}  characters='
    Return From Keyword If  '${LANE_operationalState}' in '${Enabled_}'
    coam.Unlock  dist_name=${LANE_Id}  timeout=${timeout}  connection=${alias}
    Sleep  ${recover_timeout}s  Wait for ${LANE_Id} recovery
    Log  ${LANE_Id} unlock recovery indicated  console=True

Admin Check all BTS cells expected states
    [Documentation]
    ...  Helper keyword checking all BTS cell(s) expected states.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter      | Man. | Default | Description                              |
    ...  | expected_state | Yes  |         | expected states                          |
    ...  | alias          | Yes  |         | alias of admin instance                  |
    ...  | timeout        | No   | 600     | timeout in seconds for positive response |
    ...
    [Arguments]  ${expected_state}  ${alias}  ${timeout}=600
    ${BTS_NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    Run Keyword If  ${BTS_NR_CELL_list}
    ...  Assert Every  class_name=NRCEL  parameters=${expected_state}  timeout=${timeout}  connection=${alias}
    ${BTS_LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    Run Keyword If  ${BTS_LTE_CELL_list}
    ...  Assert Every  class_name=LNCEL  parameters=${expected_state}  timeout=${timeout}  connection=${alias}
    ${BTS_WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    Run Keyword If  ${BTS_WCDMA_CELL_list}
    ...  Assert Every  class_name=WNCEL  parameters=${expected_state}  timeout=${timeout}  connection=${alias}
    ${BTS_GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Run Keyword If  ${BTS_GSM_CELL_list}
    ...  Assert Every  class_name=GNCEL  parameters=${expected_state}  timeout=${timeout}  connection=${alias}

Admin Get GSM CELL list with cell info
    [Documentation]
    ...  Keyword providing BTS GSM CELL information specified by ${cell_list} argument as described below:
    ...   - if ${cell_list} is empty, all BTS GSM CELL information will be provided (by default behavior)
    ...   - if ${cell_list} is not empty, only specified BTS GSM CELL list information will be provided
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default  | Description             |
    ...  | cell_list | No   | @{EMPTY} | cell list ids           |
    ...  | alias     | No   | default  | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter     | Description               |
    ...  | GSM_CELL_info | List of GSM cells details |
    ...
    ...  *EXAMPLE*
    ...  | ${GSM_CELL_info}= | Admin Get GSM CELL list with cell info | alias=Slave |

    [Arguments]  ${cell_list}=@{EMPTY}  ${alias}=default
    ${GSM_CELL_parameters_list}=  Admin Get GSM CELL list with cell parameters info  cell_list=${cell_list}  alias=${alias}
    ${GSM_CELL_info}=  Create List
    FOR  ${item}  IN  @{GSM_CELL_parameters_list}
        ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}  ${TX_Dependency}
        ...  ${RX_Dependency}  ${CELL_TX_RX_state}=  Get Cell TX RX state info  carrierList=${item[1]}  alias=${alias}
        @{temp}=  Create List  ${item[0]}  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}
        ...  ${RX_Degraded}  ${TX_Dependency}  ${RX_Dependency}  ${CELL_TX_RX_state}
        Append To List  ${GSM_CELL_info}  ${temp}
    END
    Sort List  ${GSM_CELL_info}
    [Return]  ${GSM_CELL_info}

Admin Get GSM CELL list with cell parameters info
    [Arguments]  ${cell_list}=@{EMPTY}  ${alias}=default
    ${cell_list_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${cell_list}
    ${GSM_cells_info_list}=  coam.Get Cell List  alias=${alias}
    Set Test Variable  ${GSM_cells_info_list}
    ${GSM_CELL_param_list}=  Create List
    FOR  ${item}  IN  @{GSM_cells_info_list['cells']['gsm']}
        Continue For Loop If  '${cell_list_isEmpty}' == 'False' and '${item['id']['internal']}' not in ${cell_list}
        @{temp}=  Create List
        ...  ${item['id']['internal']}
        ...  ${item['carrierList']}
        Append To List  ${GSM_CELL_param_list}  ${temp}
    END
    Sort List  ${GSM_CELL_param_list}
    [Return]  ${GSM_CELL_param_list}

Admin Get all RMODs with linkModeSynchronization set on BBMOD
    [Arguments]  ${bbmod_id}  ${alias}=default
    ${rmods_lms_list}=  Create List  @{EMPTY}
    ${all_cablink_list}=  Get Parameters For All  CABLINK  alias=${alias}
    ${all_rmods_list}=  Get Ids For All  RMOD  alias=${alias}
    FOR  ${item}  IN  @{all_cablink_list}
        ${e1}=  Set Variable  ${item.firstEndpointDN}
        ${e2}=  Set Variable  ${item.secondEndpointDN}
        ${cablink_obj}=  Get_Infomodel_Object  dist_name=${item.id}  alias=${alias}
        Run Keyword If  '${e1}'=='${bbmod_id}' and '${e2}' in ${all_rmods_list} and '${cablink_obj.linkModeSynchronization}' == 'True'
        ...  Append To List  ${rmods_lms_list}  ${e2}
        Run Keyword If  '${e2}'=='${bbmod_id}' and '${e1}' in ${all_rmods_list} and '${cablink_obj.linkModeSynchronization}' == 'True'
        ...  Append To List  ${rmods_lms_list}  ${e1}
    END
    [Return]  ${rmods_lms_list}

Admin Check BTS RAT cells expected states
    [Documentation]
    ...  Helper keyword checking BTS RAT cells expected states.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter      | Man. | Default | Description                              |
    ...  | expected_state | Yes  |         | expected states                          |
    ...  | alias          | Yes  |         | alias of admin instance                  |
    ...  | timeout        | Yes  |         | timeout in seconds for positive response |
    ...
    [Arguments]  ${expected_state}  ${alias}  ${timeout}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
    Check all RAT cells are up  NRCEL  ${expected_state}  ${alias}  ${timeout}
    Check all RAT cells are up  LNCEL  ${expected_state}  ${alias}  ${remained_time}
    Check all RAT cells are up  WNCEL  ${expected_state}  ${alias}  ${remained_time}
    Check all RAT cells are up  GNCEL  ${expected_state}  ${alias}  ${remained_time}

Check all RAT cells are up
    [Arguments]  ${class_name}  ${expected_state}  ${alias}  ${timeout}
    Get Current Time  initial
    ${CELL_list}=  Get Ids For All  class_name=${class_name}  connection=${alias}
    Run Keyword If  ${CELL_list}  Assert Every  class_name=${class_name}  parameters=${expected_state}  timeout=${timeout}  connection=${alias}
    Get Current Time  final
    ${rat_cells_up_elapsed_time}=  DateTime.Subtract Date from Date  ${time_final}  ${time_initial}  number
    ${remained_time}=  BuiltIn.Evaluate  ${timeout} - ${rat_cells_up_elapsed_time}
    Set Test Variable  ${remained_time}

Admin Perform BTS SCF Parameter Recommissioning
    [Documentation]
    ...  Perform BTS SCF Parameter Recommissioning
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter           | Man. | Description             |
    ...  | BTS_scf_class       | Yes  | BTS SCF class           |
    ...  | BTS_scf_param_name  | Yes  | BTS SCF parameter name  |
    ...  | BTS_scf_param_value | Yes  | BTS SCF parameter value |
    ...  | BTS_scf_operation   | Yes  | BTS SCF operation       |
    ...  | alias               | Yes  | alias of admin instance |
    ...
    [Arguments]  ${BTS_scf_class}  ${BTS_scf_param_name}  ${BTS_scf_param_value}  ${BTS_scf_operation}  ${alias}
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    ${MO_items}=  Get Element Attributes  ${BTS_scf_xml}  .//*managedObject[@class="com.nokia.srbts.mnl:${BTS_scf_class}"]
    ${BTS_scf_distName}=  Set Variable  ${MO_items['distName']}
    coam.Perform Parameter Recommissioning  dist_name=${BTS_scf_distName}  parameter=${BTS_scf_param_name}  operation=${BTS_scf_operation}
    ...  value=${BTS_scf_param_value}  skip_parameter_relation_errors=True  should_activate=True  connection=${alias}
    Sleep  3s
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_scf_param_commissioned}=  Get BTS SCF parameter info  ${BTS_scf}  ${BTS_scf_class}  ${BTS_scf_param_name}
    ${condition_param}=  Create Long String  ('${BTS_scf_operation}' == 'update' and '${BTS_scf_param_commissioned}' == '${BTS_scf_param_value}')
    ...  or ('${BTS_scf_operation}' == 'delete' and '${BTS_scf_param_commissioned}' == '${None}')
    Run Keyword If  ${condition_param}
    ...  Log  Parameter ${BTS_scf_param_name} = ${BTS_scf_param_commissioned}, successfully commissioned!  console=True
    ...  ELSE   Run Keywords
    ...  Log  Parameter ${BTS_scf_param_name} = ${BTS_scf_param_commissioned}, not properly commissioned!  level=ERROR
    ...  AND  Fail  Parameter ${BTS_scf_param_name} = ${BTS_scf_param_commissioned}, not properly commissioned!

Admin Perform BTS SCF Parameter Recommissioning for specific DN
    [Documentation]
    ...  Perform BTS SCF Parameter Recommissioning for specific DN
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter           | Man. | Description             |
    ...  | BTS_scf_distName    | Yes  | BTS SCF distName        |
    ...  | BTS_scf_param_name  | Yes  | BTS SCF parameter name  |
    ...  | BTS_scf_param_value | Yes  | BTS SCF parameter value |
    ...  | BTS_scf_operation   | Yes  | BTS SCF operation       |
    ...  | alias               | Yes  | alias of admin instance |
    ...
    [Arguments]  ${BTS_scf_distName}  ${BTS_scf_param_name}  ${BTS_scf_param_value}  ${BTS_scf_operation}  ${alias}
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    coam.Perform Parameter Recommissioning  dist_name=${BTS_scf_distName}  parameter=${BTS_scf_param_name}  operation=${BTS_scf_operation}
    ...  value=${BTS_scf_param_value}  skip_parameter_relation_errors=True  should_activate=True  connection=${alias}
    Sleep  3s
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_scf_param_commissioned}=  Get BTS SCF parameter info for specific DN  ${BTS_scf}  ${BTS_scf_distName}  ${BTS_scf_param_name}
    ${condition_param}=  Create Long String  ('${BTS_scf_operation}' == 'update' and '${BTS_scf_param_commissioned}' == '${BTS_scf_param_value}')
    ...  or ('${BTS_scf_operation}' == 'delete' and '${BTS_scf_param_commissioned}' == '${None}')
    Run Keyword If  ${condition_param}
    ...  Log  Parameter ${BTS_scf_param_name} successfully commissioned!  console=True
    ...  ELSE   Run Keywords
    ...  Log  Parameter ${BTS_scf_param_name} not properly commissioned!  level=ERROR
    ...  AND  Fail  Parameter ${BTS_scf_param_name} not properly commissioned!

Admin Get CABLINK info dict
    [Documentation]
    ...  Keyword providing CABLINK information.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | Yes  |         | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter                        | Description                                 |
    ...  | CABLINK_id_firstEndPointId_dict  | Dict of CABLINK id firstEndPointId details  |
    ...  | CABLINK_id_secondEndPointId_dict | Dict of CABLINK id secondEndPointId details |
    ...  | CABLINK_id_configuration_dict    | Dict of CABLINK id configuration details    |
    ...  | CABLINK_id_data_dict             | Dict of CABLINK id data details             |
    ...  | CABLINK_id_dc_dict               | Dict of CABLINK id dc details               |
    ...  | CABLINK_id_synchronization_dict  | Dict of CABLINK id synchronization details  |
    ...  | CABLINK_id_operationalState_dict | Dict of CABLINK id operationalState details |
    ...
    [Arguments]  ${alias}
    ${BTS_info}=  Get BTS Info  connection=${alias}
    ${CABLINK_id_firstEndPointId_dict}=  Create Dictionary
    ${CABLINK_id_secondEndPointId_dict}=  Create Dictionary
    ${CABLINK_id_configuration_dict}=  Create Dictionary
    ${CABLINK_id_data_dict}=  Create Dictionary
    ${CABLINK_id_dc_dict}=  Create Dictionary
    ${CABLINK_id_synchronization_dict}=  Create Dictionary
    ${CABLINK_id_operationalState_dict}=  Create Dictionary
    FOR  ${item}  IN  @{BTS_info['cables']}
        Set To Dictionary  ${CABLINK_id_firstEndPointId_dict}  ${item['id']['internal']}  ${item['firstEndPointId']['internal']}
        Set To Dictionary  ${CABLINK_id_secondEndPointId_dict}  ${item['id']['internal']}  ${item['secondEndPointId']['internal']}
        Set To Dictionary  ${CABLINK_id_configuration_dict}  ${item['id']['internal']}  ${item['linkMode']['configuration']}
        Set To Dictionary  ${CABLINK_id_data_dict}  ${item['id']['internal']}  ${item['linkMode']['data']}
        Set To Dictionary  ${CABLINK_id_dc_dict}  ${item['id']['internal']}  ${item['linkMode']['dc']}
        Set To Dictionary  ${CABLINK_id_synchronization_dict}  ${item['id']['internal']}  ${item['linkMode']['synchronization']}
        Set To Dictionary  ${CABLINK_id_operationalState_dict}  ${item['id']['internal']}  ${item['status']['operationalState']}
    END
    [Return]  ${CABLINK_id_firstEndPointId_dict}  ${CABLINK_id_secondEndPointId_dict}  ${CABLINK_id_configuration_dict}  ${CABLINK_id_data_dict}
    ...  ${CABLINK_id_dc_dict}  ${CABLINK_id_synchronization_dict}  ${CABLINK_id_operationalState_dict}

Admin Get BTS M-plane IP address
    [Documentation]
    ...  Helper keyword providing BTS M-plane IP address.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | Yes  |         | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter     | Description            |
    ...  | BTS_Mplane_ip | BTS M-plane IP address |

    [Arguments]  ${alias}
    ${BTS_param_list}=  Get Parameters For All  class_name=BTS  connection=${alias}
    ${BTS_param}=  Get From List  ${BTS_param_list}  0
    ${BTS_Mplane_ip}=  Get From Dictionary  ${BTS_param}  btsMplaneIp4V

    [Return]  ${BTS_Mplane_ip}

Admin Get RM sn bts-alias info dict
    [Documentation]
    ...  Helper KW providing RM info related to shared and dedicated configuration as dictionary:
    ...  - key: RM sn (radio module serial number)
    ...  - value: bts-alias list (alias list related to bts)
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                  |
    ...  | RM_sn_bts-alias_dict | Dict of RM sn bts-alias info |
    ...  | shared_RM_sn_list    | List of shared RM sn info    |
    ...  | dedicated_RM_sn_list | List of dedicated RM sn info |

    ${RM_all_sn_list}=  Create List
    FOR  ${alias}  IN  @{alias_list}
        ${RM_sn_id_dict}  ${RM_id_sn_dict}=  Get RM id sn info dict  ${alias}
        ${RM_sn_list}=  Get Dictionary Keys  ${RM_sn_id_dict}  False
        Append To List  ${RM_all_sn_list}  @{RM_sn_list}
        Set Test Variable  ${${alias}_RM_sn_id_dict}  ${RM_sn_id_dict}
        Set Test Variable  ${${alias}_RM_id_sn_dict}  ${RM_id_sn_dict}
    END
    ${RM_all_sn_list}=  Remove Duplicates  ${RM_all_sn_list}

    ${RM_sn_bts-alias_dict}=  Create Dictionary
    ${shared_RM_sn_list}=  Create List
    ${dedicated_RM_sn_list}=  Create List
    Set Test Variable  ${RM_sn_bts-alias_dict}
    FOR  ${RM_sn}  IN  @{RM_all_sn_list}
        ${RM_bts-alias_list}=  Get RM bts-alias info list  ${RM_sn}
        Set To Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}  ${RM_bts-alias_list}
        ${RM_bts-alias_count}=  Get Length  ${RM_bts-alias_list}
        Run Keyword If  ${RM_bts-alias_count} == 1
        ...  Append To List  ${dedicated_RM_sn_list}  ${RM_sn}
        ...  ELSE IF  ${RM_bts-alias_count} > 1
        ...  Append To List  ${shared_RM_sn_list}  ${RM_sn}
    END

    [Return]  ${RM_sn_bts-alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}

Get RM id sn info dict
    [Arguments]  ${alias}
    ${RM_sn_id_dict}=  Create Dictionary
    ${RM_id_sn_dict}=  Create Dictionary
    ${RM_id_list}=  Get Ids For All  class_name=RMOD  connection=${alias}
    FOR  ${item}  IN  @{RM_id_list}
        ${RM_param}=  Get Parameters For  class_name=RMOD  id_num=${item}  connection=${alias}
        Set To Dictionary  ${RM_sn_id_dict}  ${RM_param['serialNumber']}  ${RM_param['id']}
        Set To Dictionary  ${RM_id_sn_dict}  ${RM_param['id']}  ${RM_param['serialNumber']}
    END

    [Return]  ${RM_sn_id_dict}  ${RM_id_sn_dict}

Get RM bts-alias info list
    [Arguments]  ${RM_sn}
    ${RM_bts-alias_list}=  Create List
    FOR  ${alias}  IN  @{alias_list}
        ${RM_sn_list}=  Get Dictionary Keys  ${${alias}_RM_sn_id_dict}  False
        Run Keyword If  '${RM_sn}' in ${RM_sn_list}
        ...  Append To List  ${RM_bts-alias_list}  ${alias}
    END

    [Return]  ${RM_bts-alias_list}

Admin Collect IMS file with timestamp
    [Documentation]
    ...  KW for collecting IMS file from BTS to destination folder.
    ...  IMS file gets name in form IMS_<time>.ims2, where time is the current time in format %Y-%m-%d__%H-%M-%S
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter   | Man. | Description                                |
    ...  | folder_path | Yes  | Folder path for IMS file collection        |
    ...  | timeout     | No   | Time to wait for positive procedure result |
    ...  | alias       | No   | Alias of admin instance                    |
    ...
    ...  *RETURN*
    ...  | Parameter     | Description             |
    ...  | ims_file_path | IMS file path full name |
    ...
    [Arguments]  ${folder_path}  ${timeout}=180  ${alias}=default

    ${folder_status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${folder_path}
    Run Keyword If  not ${folder_status}  Create Directory  ${folder_path}

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${ims_file_name}=  Set Variable  IMS_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.ims2
    ${ims_file_path}=  Set Variable  ${folder_path}/${ims_file_name}

    Collect Infomodel Log From Current Session  target_file_name=${ims_file_path}  timeout=${timeout}  connection=${alias}

    ${file_status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${ims_file_path}
    Run Keyword If  ${file_status}
    ...  Log  BTS ${alias} IMS file available at ${ims_file_path}  level=INFO  console=True
    ...  ELSE  Run Keywords
    ...  Log  BTS ${alias} IMS file not available at ${ims_file_path}  level=ERROR
    ...  AND  Fail  BTS ${alias} IMS file not available at ${ims_file_path}

    [Return]  ${ims_file_path}

Get Admin Parameter
    [Arguments]  ${dist_name}  ${parameter}  ${alias}
    ${parameters}=  coam.Get Parameters  dist_name=${dist_name}  connection=${alias}
    [Return]  ${parameters}[${parameter}]

Check if RAT is unblocked
    [Documentation]
    ...  Helper keyword checking BTS blocking state info. If needed perform unblock BTS.
    ...
    ...  *AUTHOR*
    ...  horea.olar@nokia.com / ana.tugui@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man.  | Default  | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    [Arguments]  ${alias}=default

    ${RAT_list}=  Create List
    ${BTS_NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    Run Keyword If  ${BTS_NR_CELL_list}  Append To List  ${RAT_list}  NR
    ${BTS_LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    Run Keyword If  ${BTS_LTE_CELL_list}  Append To List  ${RAT_list}  LTE
    ${BTS_WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    Run Keyword If  ${BTS_WCDMA_CELL_list}  Append To List  ${RAT_list}  WCDMA
    ${BTS_GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Run Keyword If  ${BTS_GSM_CELL_list}  Append To List  ${RAT_list}  GSM

    FOR  ${item}  IN  @{RAT_list}
        ${RAT_class_name}=  Set Variable If  '${item}'=='NR'  NRBTS  '${item}'=='LTE'  LNBTS  '${item}'=='WCDMA'  WNBTS  '${item}'=='GSM'  GNBTS
        ${RAT_Id}=  Get Id For Current  class_name=${RAT_class_name}  connection=${alias}
        ${RAT_Id}=  Set Variable If  '${item}' in ['NR','LTE','WCDMA']  ${RAT_Id}  ${RAT_Id}/GNBCF_R-1
        ${status}=  Get Admin Parameter  dist_name=${RAT_Id}  parameter=blockingState  alias=${alias}
        Run Keyword If  '${status}' in '${Blocked_}'  Run Keywords
        ...  coam.Unblock Rat  rat=${item}  timeout=180  connection=${alias}
        ...  AND  Sleep  60s  Wait for ${item} RAT recovery
        ...  AND  Log  ${item} RAT unblock recovery indicated  console=True
    END

Check cells availability status online
    [Documentation]
    ...  Keyword checking availability status of cells to be online.
    ...
    [Arguments]  ${alias}  ${timeout}
    ${CELL_status_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}
    ${BTS_NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    Run Keyword If  ${BTS_NR_CELL_list}  Run Keywords
    ...  Assert Every  NRCEL  operationalState=${Enabled_}  timeout=${timeout}  connection=${alias}
    ...  AND  Assert No  NRCEL  ${CELL_status_degraded_check}  ${timeout}  ${alias}
    ${BTS_LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    Run Keyword If  ${BTS_LTE_CELL_list}  Run Keywords
    ...  Assert Every  LNCEL  operationalState=${Enabled_}  timeout=${timeout}  connection=${alias}
    ...  AND  Assert No  LNCEL  ${CELL_status_degraded_check}  ${timeout}  ${alias}
    ...  AND  Check LTE CELL IOT availability status online  ${alias}  ${timeout}
    ${BTS_WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    Run Keyword If  ${BTS_WCDMA_CELL_list}  Run Keywords
    ...  Assert Every  WNCEL  operationalState=${Enabled_}  timeout=${timeout}  connection=${alias}
    ...  AND  Assert No  WNCEL  ${CELL_status_degraded_check}  ${timeout}  ${alias}
    ${BTS_GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Run Keyword If  ${BTS_GSM_CELL_list}  Run Keywords
    ...  Assert Every  GNCEL  operationalState=${Enabled_}  timeout=${timeout}  connection=${alias}
    ...  AND  Assert No  GNCEL  ${CELL_status_degraded_check}  ${timeout}  ${alias}

Check LTE CELL IOT availability status online
    [Documentation]
    ...  Keyword checking availability status of LTE IOT cells to be online.
    ...
    [Arguments]  ${alias}  ${timeout}

    ${CELL_status_enabled_IOT_check}=  Set Variable  nbIoTCell.stateInfo.operationalState=${Enabled_}
    ${LTE_CELL_IOT_dict}=  Admin Get LTE CELL IOT mapping list  ${alias}
    ${LTE_HOST_CELL_list}=  Get Dictionary Keys  ${LTE_CELL_IOT_dict}
    ${LTE_IOT_CELL_list}=  Get Dictionary Values  ${LTE_CELL_IOT_dict}

    FOR  ${host_cell_id}  ${iot_cell_id}  IN ZIP  ${LTE_HOST_CELL_list}  ${LTE_IOT_CELL_list}
        Run Keyword If  '${iot_cell_id}' != 'None'
        ...  Assert  class_name=LNCEL  id=${host_cell_id}  parameters=${CELL_status_enabled_IOT_check}  timeout=${timeout}  connection=${alias}
    END

Admin Check FHS list state
    [Documentation]
    ...  Wrapper Keyword over Admin Check FHS state from Admin.
    ...
    ...  *AUTHOR*
    ...  adelina.branc@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                     | Man. | Default | Description                               |
    ...  | FHS_list                      | Yes  |         | list of FHS Ids to be checked             |
    ...  | exp_operationalState_check    | Yes  |         | expected FHS operationalState as regex    |
    ...  | exp_operationalState          | Yes  |         | expected FHS operationalState             |
    ...  | exp_availabilityStatus_check  | Yes  |         | expected FHS availabilityStatus as regex  |
    ...  | exp_availabilityStatus        | Yes  |         | expected FHS availabilityStatus           |
    ...  | exp_administrativeState_check | Yes  |         | expected FHS administrativeState as regex |
    ...  | exp_administrativeState       | Yes  |         | expected FHS administrativeState          |
    ...  | alias                         | No   | default | alias of ute_admin_infomodel instance     |
    ...
    ...  *RETURN*
    ...  KW is passed if expected states are correlated with FHS states, otherwise failed

    [Arguments]  ${FHS_list}  ${exp_operationalState_check}  ${exp_operationalState}  ${exp_availabilityStatus_check}  ${exp_availabilityStatus}
    ...  ${exp_administrativeState_check}  ${exp_administrativeState}  ${alias}=default
    FOR  ${item}  IN  @{FHS_list}
        Log Long String  Check FHS ${item} status for ${alias}:\n operationalState=${exp_operationalState},
        ...  administrativeState=${exp_administrativeState}, availabilityStatus=${exp_availabilityStatus}   console=True
        Admin Check FHS state  ${item}  ${exp_operationalState_check}  ${exp_availabilityStatus_check}  ${exp_administrativeState_check}  ${alias}
    END

Get excepted and not excepted RMOD lists
    [Documentation]
    ...  Get excepted and not excepted RMOD lists
    ...
    ...  *INPUT*
    ...  | Parameter              | Mandatory | Description                                                      |
    ...  | RMOD_list              | Yes       | List of RMODs to be separated in excepted and not excepted lists |
    ...  | RMOD_exceptions        | Yes       | List of RMOD types that are excepted                             |
    ...  | alias                  | Yes        | Remote host IP if ping should be proceeded from it              |

    [Arguments]  ${RMOD_list}  ${RMOD_exceptions}  ${alias}
    ${not_excepted_RMOD_list}=  Create List
    ${excepted_RMOD_list}=  Create List
    FOR  ${item}  IN  @{RMOD_list}
        ${RMOD_parameters}=  Get Parameters For  class_name=RMOD  id_num=${item}  connection=${alias}
        ${RMOD_productName}=  Set Variable  ${RMOD_parameters.productName}
        Run Keyword If  '${RMOD_productName}' in @{RMOD_exceptions}  Append To List  ${excepted_RMOD_list}  ${item}
        ...  ELSE  Append To List  ${not_excepted_RMOD_list}  ${item}
    END

    [Return]  ${not_excepted_RMOD_list}  ${excepted_RMOD_list}

Admin Synchronizing Active and Passive SW version
    [Documentation]
    ...  Helper keyword used to synchronize Active and Passive partition SW
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                                                     |
    ...  | alias             | No   | admin instance alias                                                            |
    ...  | copy_to_passive   | No   | Flag for copy to passive.                                                       |
    ...                             | Possible values: 0 - SW and config without health check (deafault);             |
    ...                             | 1 - SW and config with health check                                             |
    ...  | timeout           | No   | time (in seconds) to wait for positive procedure result. Default value: 300     |
    ...
    [Arguments]  ${alias}=default  ${copy_to_passive}=0  ${timeout}=300
    coam.Passive Synchronize  copy_to_passive=${copy_to_passive}  connection=${alias}  timeout=${timeout}
    ${BTS_SW_Info}=  coam.Get Software Info  connection=${alias}
    ${Active_SW}=  Collections.Get From Dictionary  ${BTS_SW_Info}   Active SW version
    ${Passive_SW}=  Collections.Get From Dictionary  ${BTS_SW_Info}   Passive SW version
    ${status}=  Run Keyword and Return Status  Should Be Equal  ${Active_SW}  ${Passive_SW}
    Run Keyword If  ${status}  Log  Synchronizing Active and Passive SW version succeded!  console=True
    ...  ELSE  Fail  Synchronizing Active and Passive SW version did not succeed!

Admin Get shared and dedicated module info for BTS
    [Documentation]
    ...  Helper KW providing shared and dedicated module (RMOD or FHS) info dict for BTS
    ...
    ...  *AUTHOR*
    ...  andreea.szentannai@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter    | Man. | Default | Description                    |
    ...  | module_type  | Yes  |         | RMOD or FHS                    |
    ...  | alias        | Yes  |         | alias of admin instance        |
    ...
    ...  *RETURN*
    ...  | Parameter                        | Description                                                                             |
    ...  | module_alias_dict                | Dict with ${module_type} sn as key and list of BTS connected to ${module_type} as value |
    ...  | BTS_shared_module_id_sn_dict     | Dict with shared ${module_type} id as key and shared ${module_type} sn as value         |
    ...  | BTS_dedicated_module_id_sn_dict  | Dict with dedicated ${module_type} id as key and dedicated ${module_type} sn as value   |
    ...  | BTS_shared_module_sn_id_dict     | Dict with shared ${module_type} sn as key and shared ${module_type} id as value         |
    ...  | BTS_dedicated_module_sn_id_dict  | Dict with dedicated ${module_type} sn as key and dedicated ${module_type} id as value   |

    [Arguments]  ${module_type}  ${alias}

    ${BTS_shared_module_id_sn_dict}=  Create Dictionary
    ${BTS_dedicated_module_id_sn_dict}=  Create Dictionary
    ${BTS_shared_module_sn_id_dict}=  Create Dictionary
    ${BTS_dedicated_module_sn_id_dict}=  Create Dictionary
    ${module_alias_dict}=  Create Dictionary

    FOR  ${item}  IN  @{alias_list}
        Continue For Loop If  '${${item.upper()}}[${item.upper()}_TECH]' == 'CBTS'
        ${BTS_RMOD_list}=  Get Ids For All  class_name=RMOD  connection=${item}
        ${BTS_FHS_list}=  Admin Get FHS Ids  alias=${item}
        ${BTS_module_list}=  Set Variable If  '${module_type}' == 'RMOD'  ${BTS_RMOD_list}  '${module_type}' == 'FHS'  ${BTS_FHS_list}
        Sort List  ${BTS_module_list}
        Set Test Variable  ${${item}_module_list}  ${BTS_module_list}

        Run Keyword If  '${module_type}' == 'RMOD'
        ...  Get RMOD ID SN dict  ${item}
        ...  ELSE IF  '${module_type}' == 'FHS'
        ...  Get FHS ID SN dict  ${item}

        ${BTS_module_SN_list}=  Get Dictionary Keys  ${${item}_module_SN_ID_dict}
        Set Test Variable  ${${item}_module_SN_list}  ${BTS_module_SN_list}
    END

    FOR  ${module_sn}  IN  @{${alias}_module_SN_list}
        ${module_id}=  Get From Dictionary  ${${alias}_module_SN_ID_dict}  ${module_sn}
        ${module_alias_list}=  Get module alias list  ${module_sn}
        Set To Dictionary  ${module_alias_dict}  ${module_sn}  ${module_alias_list}
        ${module_alias_count}=  Get Length  ${module_alias_list}
        Run Keyword If  ${module_alias_count} == 1  Run Keywords
        ...  Set To Dictionary  ${BTS_dedicated_module_id_sn_dict}  ${module_id}  ${module_sn}
        ...  AND  Set To Dictionary  ${BTS_dedicated_module_sn_id_dict}  ${module_sn}  ${module_id}
        ...  ELSE IF  ${module_alias_count} > 1  Run Keywords
        ...  Set To Dictionary  ${BTS_shared_module_id_sn_dict}  ${module_id}  ${module_sn}
        ...  AND  Set To Dictionary  ${BTS_shared_module_sn_id_dict}  ${module_sn}  ${module_id}
    END

    [Return]  ${module_alias_dict}   ${BTS_shared_module_id_sn_dict}  ${BTS_dedicated_module_id_sn_dict}  ${BTS_shared_module_sn_id_dict}
    ...  ${BTS_dedicated_module_sn_id_dict}

Get module alias list
    [Arguments]  ${module_sn}
    ${module_alias_list}=  Create List
    FOR  ${alias}  IN  @{alias_list}
        Run Keyword If  '${module_sn}' in ${${alias}_module_SN_list}
        ...  Append To List  ${module_alias_list}  ${alias}
    END
    [Return]  ${module_alias_list}

Get and Check ALD state info
    [Documentation]
    ...  Keyword to check ALD state info
    ...
    ...  *AUTHOR* anca.tatar@nokia.com
    ...
    ...  | Parameter                | Man.|  Description                                                                                     |
    ...  | alias                    | Yes | alias of admin instance                                                                          |
    ...  | RMOD_list                | No  | List of RMOD IDs on which ALD state check should be performed; one RMOD will also work;          |
    ...  |                          |     | If left ${EMPTY}, check will be performed on all configured RMODs                                |
    ...  | ALD_expected_state_check | No  | ALD operational status that needs to be checked; If left ${EMPTY}, Enabled state will be checked |
    ...  | ALD_expected_state       | No  | ALD operational status that needs to be printed; If left ${EMPTY}, Enabled state will be checked |
    ...  | timeout                  | No  | Time to wait for ALD to reach desired state                                                      |

    [Arguments]  ${alias}  ${RMOD_list}=@{EMPTY}  ${ALD_expected_state_check}=${EMPTY}  ${ALD_expected_state}=${EMPTY}  ${timeout}=5

    ${ALD_expected_state_check}=  Set Variable If  '${ALD_expected_state_check}' == '${EMPTY}'
    ...  operationalState=${Enabled_}, administrativeState=${Unlocked_}  ${ALD_expected_state_check}
    ${ALD_expected_state}=  Set Variable If  '${ALD_expected_state}' == '${EMPTY}'
    ...  operationalState=Enabled, administrativeState=Unlocked  ${ALD_expected_state}

    ${RMOD_list_is_Empty}=  Run Keyword And Return Status  Should Be Empty  ${RMOD_list}
    Run Keyword If  not ${RMOD_list_is_Empty}  Run Keywords
    ...  Get and Check ALD state info for specific RMOD list  ${alias}  ${RMOD_list}  ${ALD_expected_state_check}  ${ALD_expected_state}  ${timeout}
    ...  AND  Return From Keyword

    ${ALD_list}=  coam.Get Ids For All  class_name=ALD  connection=${alias}
    Return From Keyword If  not ${ALD_list}

    Log  Check BTS ${alias} ALD state info:  console=True
    Assert Every  class_name=ALD  parameters=${ALD_expected_state_check}  timeout=${timeout}  connection=${alias}
    Log  All BTS ${alias} ALD status:\n - ${ALD_expected_state}  console=True

Get and Check ALD state info for specific RMOD list
    [Arguments]  ${alias}  ${RMOD_list}  ${ALD_expected_state_check}  ${ALD_expected_state}  ${timeout}

    ${is_string}=  Evaluate  isinstance($RMOD_list, str)
    ${RMOD_list}=  Run Keyword If  ${is_string}  Create List  ${RMOD_list}
    ...  ELSE  Set Variable  ${RMOD_list}

    FOR  ${RMOD_id}  IN  @{RMOD_list}
        ${RMOD_param}=  Get Parameters For  class_name=RMOD  id_num=${RMOD_id}  alias=${alias}
        ${ALD_list}=  Get ALD list mapped on RMOD  ${alias}  ${RMOD_id}  ${RMOD_param['connectorLabels']}
        Run Keyword If  ${ALD_list}  Check ALD state info  ${alias}  ${ALD_list}  ${ALD_expected_state_check}  ${ALD_expected_state}  ${timeout}
    END

Get ALD list mapped on RMOD
    [Arguments]  ${alias}  ${RMOD_id}  ${RMOD_connector_labels}

    ${ALD_list}=  Create List
    FOR  ${connector_label}  IN  @{RMOD_connector_labels}
        ${status}=  Run Keyword And Return Status  coam.Get ALD Id by Module Connector  module_id=${RMOD_id}  connector_label=${connector_label}
        ...  connection=${alias}
        Continue For Loop If  not ${status}
        ${ALD_info}=  coam.Get ALD Id by Module Connector  module_id=${RMOD_id}  connector_label=${connector_label}  connection=${alias}
        Append To List  ${ALD_list}  ${ALD_info['id']['internal']}
    END

    [Return]  ${ALD_list}

Check ALD state info
    [Arguments]  ${alias}  ${ALD_list}  ${ALD_expected_state_check}  ${ALD_expected_state}  ${timeout}

    FOR  ${ALD_id}  IN  @{ALD_list}
        Assert  class_name=ALD  id=${ALD_id}  parameters=${ALD_expected_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} ALD ${ALD_id} status:\n - ${ALD_expected_state}  console=True
    END

Admin Get FHS sn bts-alias info dict
    [Documentation]
    ...  Helper KW providing FHS info related to shared and dedicated configuration as dictionary:
    ...  - key: FHS sn (fronthaul switch serial number)
    ...  - value: bts-alias list (alias list related to bts)
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter             | Description                   |
    ...  | FHS_sn_bts-alias_dict | Dict of FHS sn bts-alias info |
    ...  | shared_FHS_sn_list    | List of shared FHS sn info    |
    ...  | dedicated_FHS_sn_list | List of dedicated FHS sn info |

    ${FHS_all_sn_list}=  Create List
    FOR  ${alias}  IN  @{alias_list}
        ${FHS_sn_id_dict}  ${FHS_id_sn_dict}=  Get FHS id sn info dict  ${alias}
        ${FHS_sn_list}=  Get Dictionary Keys  ${FHS_sn_id_dict}  False
        Append To List  ${FHS_all_sn_list}  @{FHS_sn_list}
        Set Test Variable  ${${alias}_FHS_sn_id_dict}  ${FHS_sn_id_dict}
        Set Test Variable  ${${alias}_FHS_id_sn_dict}  ${FHS_id_sn_dict}
    END
    ${FHS_all_sn_list}=  Remove Duplicates  ${FHS_all_sn_list}

    ${FHS_sn_bts-alias_dict}=  Create Dictionary
    ${shared_FHS_sn_list}=  Create List
    ${dedicated_FHS_sn_list}=  Create List
    Set Test Variable  ${FHS_sn_bts-alias_dict}
    FOR  ${FHS_sn}  IN  @{FHS_all_sn_list}
        ${FHS_bts-alias_list}=  Get FHS bts-alias info list  ${FHS_sn}
        Set To Dictionary  ${FHS_sn_bts-alias_dict}  ${FHS_sn}  ${FHS_bts-alias_list}
        ${FHS_bts-alias_count}=  Get Length  ${FHS_bts-alias_list}
        Run Keyword If  ${FHS_bts-alias_count} == 1
        ...  Append To List  ${dedicated_FHS_sn_list}  ${FHS_sn}
        ...  ELSE IF  ${FHS_bts-alias_count} > 1
        ...  Append To List  ${shared_FHS_sn_list}  ${FHS_sn}
    END

    [Return]  ${FHS_sn_bts-alias_dict}  ${shared_FHS_sn_list}  ${dedicated_FHS_sn_list}

Get FHS id sn info dict
    [Arguments]  ${alias}
    ${FHS_sn_id_dict}=  Create Dictionary
    ${FHS_id_sn_dict}=  Create Dictionary
    ${FHS_info_list}=  Get Fhs List  connection=${alias}
    FOR  ${item}  IN  @{FHS_info_list}
        Set To Dictionary  ${FHS_sn_id_dict}  ${item['serialNumber']}  ${item['id']['internal']}
        Set To Dictionary  ${FHS_id_sn_dict}  ${item['id']['internal']}  ${item['serialNumber']}
    END

    [Return]  ${FHS_sn_id_dict}  ${FHS_id_sn_dict}

Get FHS bts-alias info list
    [Arguments]  ${FHS_sn}
    ${FHS_bts-alias_list}=  Create List
    FOR  ${alias}  IN  @{alias_list}
        ${FHS_sn_list}=  Get Dictionary Keys  ${${alias}_FHS_sn_id_dict}  False
        Run Keyword If  '${FHS_sn}' in ${FHS_sn_list}
        ...  Append To List  ${FHS_bts-alias_list}  ${alias}
    END

    [Return]  ${FHS_bts-alias_list}

Admin Get BTS SW Version
    [Documentation]
    ...  Helper keyword providing NR or LTE SW versions. KW is returning a list of SW versions on active and passive partitions.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter                                     | Description                                          |
    ...  | ${${alias} active SW}  ${${alias} passive SW} | List of SW versions on active and passive partitions |

    [Arguments]  ${alias}=default

    ${BTS_SW_Info}=   coam.Get software info  alias=${alias}
    ${Active_SW}=  Get from dictionary  ${BTS_SW_Info}  Active SW version
    ${Passive_SW}=  Get from dictionary  ${BTS_SW_Info}  Passive SW version
    ${Planned_SW}=  Get from dictionary  ${BTS_SW_Info}  Planned SW version
    Set test variable  ${${alias} active SW}  ${Active_SW}
    Set test variable  ${${alias} passive SW}  ${Passive_SW}
    Set test variable  ${${alias} planned SW}  ${Planned_SW}
    Log To Console  ${alias} active SW: ${${alias} active SW}
    Log To Console  ${alias} passive SW: ${${alias} passive SW}
    [Return]  ${${alias} active SW}  ${${alias} passive SW}

Admin Get LTE RM-CELL mapping list
    [Documentation]
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
    ...  | ${LTE_RM_CELL_list}= | Admin Get LTE RM-CELL mapping list | Master |

    [Arguments]  ${alias}=default  ${IOT_CELL_add}=False
    ${RMOD_ID_LIST}=  coam.Get Ids For All  RMOD  alias=${alias}
    Sort List  ${RMOD_ID_LIST}
    ${LTE_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{RMOD_ID_LIST}
        ${CELL_ID_LIST}=  coam.Get Cell Mapping By Module Id  ${item}  alias=${alias}
        ${LTE_HOST_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}  ${LTE_IOT_SA_CELL_ID_LIST}=
        ...  Admin Get LTE HOST and IOT Cell(s) Id list  CELL_list=${CELL_ID_LIST}  alias=${alias}
        @{temp}=  Run Keyword If  not ${IOT_CELL_add}  Create List  ${item}  ${LTE_HOST_CELL_ID_LIST}
        ...  ELSE  Create List  ${item}  ${CELL_ID_LIST}
        Append To List  ${LTE_RM_CELL_list}  ${temp}
    END
    Sort List  ${LTE_RM_CELL_list}
    [Return]  ${LTE_RM_CELL_list}

Admin Get LTE HOST and IOT Cell(s) Id list
    [Documentation]
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
    ...  | Parameter               | Description                            |
    ...  | LTE_HOST_CELL_ID_LIST   | List of LTE HOST Cell(s) Id            |
    ...  | LTE_IOT_CELL_ID_LIST    | List of LTE IOT Cell(s) Id             |
    ...  | LTE_IOT_SA_CELL_ID_LIST | List of LTE IOT Standalone Cell(s) Id  |
    ...
    ...  *EXAMPLE*
    ...  | ${LTE_HOST_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}  ${LTE_IOT_SA_CELL_ID_LIST}= | Admin Get LTE HOST and IOT Cell(s) Id list |
    ...  ${CELL_list}  Master |

    [Arguments]  ${CELL_list}  ${alias}=default
    ${LTE_HOST_CELL_ID_LIST}=  Create List
    ${LTE_IOT_CELL_ID_LIST}=  Create List
    ${LTE_IOT_SA_CELL_ID_LIST}=  Create List
    FOR  ${item}  IN  @{CELL_list}
        ${CELL_PARAM_LIST}=  coam.Get Parameters For  LNCEL  ${item}  alias=${alias}
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
        ...  Append To List  ${LTE_IOT_SA_CELL_ID_LIST}  ${CELL_PARAM_LIST['id']}
    END
    Sort List  ${LTE_HOST_CELL_ID_LIST}
    Sort List  ${LTE_IOT_CELL_ID_LIST}
    Sort List  ${LTE_IOT_SA_CELL_ID_LIST}
    [Return]  ${LTE_HOST_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}  ${LTE_IOT_SA_CELL_ID_LIST}

Admin Get LTE CELL-RM mapping list
    [Documentation]
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
    Infomodel Get LTE txPathFailureMode  alias=${alias}
    ${LTE_CELL_parameters_list}  ${LTE_ALL_CELLS_list}=  Admin Get LTE CELL parameters list  alias=${alias}
    ${LTE_CELL_RM_list}=  Create List
    FOR  ${item}  IN  @{LTE_CELL_parameters_list}
        ${RM_list}=  Admin Get LTE RM mapped list  ${LTE_ALL_CELLS_list}  ${item[0]}  ${alias}
        @{temp}=  Create List  ${item[0]}  ${item[2]}  ${item[3]}  ${item[4]}  ${item[5]}  ${RM_list}
        Append To List  ${LTE_CELL_RM_list}  ${temp}
    END
    Sort List  ${LTE_CELL_RM_list}
    [Return]  ${LTE_CELL_RM_list}

Infomodel Get LTE txPathFailureMode
    [Documentation]
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
    ${status}  ${LNBTS_A_object_found}=  Run Keyword and Ignore Error
    ...  ute_admin_infomodel.Query Infomodel  query=get list //LNBTS_A-*  alias=${alias}
    Run Keyword If  '${status}'=='PASS'  Set Test Variable  ${txPathFailureMode}  ${LNBTS_A_object_found[0].txPathFailureMode}
    ...  ELSE  Set Test Variable  ${txPathFailureMode}  ''

Admin Get LTE CELL parameters list
    [Documentation]
    ...  Helper KW providing list of LTE cells parameters from WebEM
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                   |
    ...  | alias     | Yes  | Alias used via taf.sbs.oam.coam.admin library |
	...
	...  *RETURN*
	...  | Parameter                 | Description                          |
    ...  | LTE_CELL_parameters_list  | list of all parameters for LTE cells |

    [Arguments]  ${alias}
    ${LTE_ALL_CELLS_list}=  coam.Get Cell List  alias=${alias}
    ${LTE_CELL_parameters_list}=  Create List
    FOR  ${item}  IN  @{LTE_ALL_CELLS_list['cells']['lte']}
        ${CONF_REF_obj}=  ute_admin_infomodel.Query Infomodel  get object ${item['id']['internal']}/CONF_REF-1  alias=${alias}
        ${LNCEL_A_param}=  ute_admin_infomodel.Query Infomodel  query=get object ${CONF_REF_obj.distName}  alias=${alias}
        Continue For Loop If  '${LNCEL_A_param['cellTechnology']}' not in ['FDD','TDD']
        ${LNCEL_TECHNO_A_param}=  ute_admin_infomodel.Query Infomodel
        ...  query=get object ${CONF_REF_obj.distName}/LNCEL_${LNCEL_A_param['cellTechnology']}_A-0
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
    [Return]  ${LTE_CELL_parameters_list}  ${LTE_ALL_CELLS_list}

Admin Get LTE RM mapped list
    [Documentation]
    ...  Helper KW providing list of RMs mapped on LTE BTS
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                   |
    ...  | CELL_DN   | Yes  | LTE cell distname                             |
    ...  | alias     | Yes  | Alias used via taf.sbs.oam.coam.admin library |
	...
	...  *RETURN*
	...  | Parameter            | Description                          |
    ...  | RM_TxRx_mapped_list  | TxRx of RM mapped on LTE BTS         |

    [Arguments]  ${LTE_ALL_CELLS_list}  ${CELL_DN}  ${alias}
    ${LTE_RM_CELL_list}=  Admin Get LTE RM-CELL mapping list  alias=${alias}
    ${LTE_RM_mapped_list}=  Create List
    FOR  ${item}  IN  @{LTE_RM_CELL_list}
        ${map}=  Run Keyword And Return Status  List Should Contain Value  ${item[1]}  ${CELL_DN}
        Run Keyword If  '${map}' == 'True'  Append To List  ${LTE_RM_mapped_list}  ${item[0]}
    END
    Sort List  ${LTE_RM_mapped_list}
    ${RM_TxRx_mapped_list}=  Create List
    FOR  ${item}  IN  @{LTE_RM_mapped_list}
        ${RM_TxRx_list}=  Get RM TxRx List  ${LTE_ALL_CELLS_list}  ${CELL_DN}  ${item}
        Append To List  ${RM_TxRx_mapped_list}  ${RM_TxRx_list}
    END
    [Return]  ${RM_TxRx_mapped_list}

Get RM TxRx List
    [Documentation]
    ...  Helper KW providing list of all LTE cell's TX RX from RM
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description            |
    ...  | CELL_DN   | Yes  | LTE cell distname      |
    ...  | RM_DN     | Yes  | RM distname            |
	...
	...  *RETURN*
	...  | Parameter     | Description  |
    ...  | RM_TxRx_list  | TxRx of RM   |

    [Arguments]  ${LTE_ALL_CELLS_list}  ${Cell_DN}  ${RM_DN}
    FOR  ${item}  IN  @{LTE_ALL_CELLS_list['cells']['lte']}
        ${RM_TxRx_list}=  Run Keyword If  '${item['id']['internal']}' == '${Cell_DN}'
        ...  Get RM TxRx Info  ${item['carrierList']}  ${item['globalCellId']}  ${RM_DN}
        Exit For Loop If  '${item['id']['internal']}' == '${Cell_DN}'
    END
    [Return]  ${RM_TxRx_list}

Get RM TxRx Info
    [Documentation]
    ...  Helper KW providing TX RX info of one LTE cells mapped on RM
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description            |
    ...  | carrierList  | Yes  | carrierList of cell |
    ...  | globalCellId | Yes  | LTE cell cell id    |
    ...  | RM_DN        | Yes  | RM distname         |
	...
	...  *RETURN*
	...  | Parameter     | Description  |
    ...  | RM_TxRx_list  | TxRx of RM   |

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

Admin Get LTE CELL Ids list
    [Documentation]
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
    ${CELL_ID_LIST}=  coam.Get Ids For All  LNCEL  alias=${alias}
    Sort List  ${CELL_ID_LIST}
    ${LTE_CELL_IDS_LIST}=  Create List
    ${LTE_IOT_CELL_IDS_LIST}=  Create List
    FOR  ${item}  IN  @{CELL_ID_LIST}
        ${CELL_PARAM_LIST}=  coam.Get Parameters For  LNCEL  ${item}  alias=${alias}
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

Admin Get LTE CELL IOT mapping list
    [Documentation]
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
    ${LTE_cell_ids}  ${LTE_IOT_cell_ids}=  Admin Get LTE CELL Ids list  ${alias}
    Sort List  ${LTE_cell_ids}
    ${LTE_cell_IOT_mapping_dict}=  Create Dictionary
    FOR  ${item}  IN  @{LTE_cell_ids}
        ${cell_param_list}=  coam.Get Parameters For  LNCEL  ${item}  alias=${alias}
        ${key_exist}=  Run keyword and return status  Get From Dictionary  ${cell_param_list}  nbIoTMode
        ${value}=  Set Variable If
        ...  '${key_exist}' == 'False'  None
        ...  '${cell_param_list['nbIoTMode']}' == 'disabled'  None
        ...  '${cell_param_list['nbIoTMode']}' != 'disabled'  ${CELL_PARAM_LIST['nbIoTCell']['distName']}
        Set To Dictionary  ${LTE_cell_IOT_mapping_dict}  ${item}  ${value}
    END
    [Return]  ${LTE_cell_IOT_mapping_dict}

Get Cell TX RX state info
    [Documentation]
    ...  Helper KW providing list of TX/RXs on each channel, separated by state
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter      | Man. | Description                                    |
    ...  | carrierList    | Yes  | list of cariers to be parsed                   |
    ...  | alias          | Yes  | Alias used via taf.sbts.oam.coam.admin library |
	...
	...  *RETURN*
    ...  | Number of TX/RXs on each channel and states |

    [Arguments]  ${carrierList}  ${alias}=default
    ${CELL_TX_RX_state}=  Create List
    Set Test Variable  ${TX_Total}  0
    Set Test Variable  ${RX_Total}  0
    Set Test Variable  ${TX_Online}  0
    Set Test Variable  ${RX_Online}  0
    Set Test Variable  ${TX_Failed}  0
    Set Test Variable  ${RX_Failed}  0
    Set Test Variable  ${TX_Degraded}  0
    Set Test Variable  ${RX_Degraded}  0
    Set Test Variable  ${TX_Dependency}  0
    Set Test Variable  ${RX_Dependency}  0
    FOR  ${item}  IN  @{carrierList}
        ${CHANNEL_M_param}=  coam.Get Parameters  dist_name=${item['id']['internal']}  connection=${alias}
        ${TX_Total}=  Evaluate Value  ${TX_Total}  ${CHANNEL_M_param['direction']}  TX
        ${RX_Total}=  Evaluate Value  ${RX_Total}  ${CHANNEL_M_param['direction']}  RX
        ${TX_Online}=  Evaluate Value  ${TX_Online}  ${CHANNEL_M_param['direction']}  TX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Online
        ${RX_Online}=  Evaluate Value  ${RX_Online}  ${CHANNEL_M_param['direction']}  RX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Online
        ${TX_Failed}=  Evaluate Value  ${TX_Failed}  ${CHANNEL_M_param['direction']}  TX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Failed
        ${RX_Failed}=  Evaluate Value  ${RX_Failed}  ${CHANNEL_M_param['direction']}  RX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Failed
        ${TX_Degraded}=  Evaluate Value  ${TX_Degraded}  ${CHANNEL_M_param['direction']}  TX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Degraded
        ${RX_Degraded}=  Evaluate Value  ${RX_Degraded}  ${CHANNEL_M_param['direction']}  RX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Degraded
        ${TX_Dependency}=  Evaluate Value  ${TX_Dependency}  ${CHANNEL_M_param['direction']}  TX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Dependency
        ${RX_Dependency}=  Evaluate Value  ${RX_Dependency}  ${CHANNEL_M_param['direction']}  RX
        ...  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}  Dependency
        @{temp}=  Create List  ${CHANNEL_M_param['direction']}  ${CHANNEL_M_param['stateInfo']['availabilityStatus']}
        Append To List  ${CELL_TX_RX_state}  ${temp}
    END
    Sort List  ${CELL_TX_RX_state}
    [Return]  ${TX_Total}  ${RX_Total}  ${TX_Online}  ${RX_Online}  ${TX_Failed}  ${RX_Failed}  ${TX_Degraded}  ${RX_Degraded}  ${TX_Dependency}
    ...  ${RX_Dependency}  ${CELL_TX_RX_state}

Evaluate Value
    [Documentation]
    ...  Helper KW providing counting specifc parameter appearance based on multiple conditions
    ...
    ...  *AUTHOR*
    ...  adelina.branc@nokia.com
    ...
    ...  | Parameter          | Man. | Description                                 |
    ...  | param_to_evaluate  | Yes  | parameter to be evaluated                   |
    ...  | exp_value1         | Yes  | first expected value from first condition   |
    ...  | value_to_check1    | Yes  | first checked value from first condition    |
    ...  | exp_value2         | No   | second expected value from second condition |
    ...  | value_to_check12   | No   | second checked value from second conditio   |
	...
	...  *RETURN*
    ...  | Total parameter appearances |

    [Arguments]  ${param_to_evaluate}  ${exp_value1}  ${value_to_check1}  ${exp_value2}=${False}  ${value_to_check2}=${False}
    ${value}=  Run Keyword If  '${value_to_check1}' == '${exp_value1}' and '${value_to_check2}' == '${exp_value2}'
    ...        Evaluate  ${param_to_evaluate} + 1
    ...        ELSE
    ...        Evaluate  ${param_to_evaluate} + 0
    [Return]  ${value}

Admin Get RMOD sn id pn interface info
    [Documentation]
    ...  Get BTS radio modules serial number, id and interface protocol info
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description             |
    ...  | alias     | No   | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter                  | Description                                                            |
    ...  | BTS_RMOD_sn_id_dict        | Dict containing structure: {'RMOD_serial_number': 'RMOD_id'}           |
    ...  | BTS_RMOD_id_sn_dict        | Dict containing structure: {'RMOD_id': 'RMOD_serial_number'}           |
    ...  | BTS_RMOD_sn_pn_dict        | Dict containing structure: {'RMOD_serial_number': 'RMOD_product_name'} |
    ...  | BTS_RMOD_sn_interface_dict | Dict containing structure: {'RMOD_serial_number': 'RMOD_interface'}    |
    ...
    [Arguments]  ${alias}

    ${BTS_RMOD_sn_id_dict}=  Create Dictionary
    ${BTS_RMOD_id_sn_dict}=  Create Dictionary
    ${BTS_RMOD_sn_pn_dict}=  Create Dictionary
    ${BTS_RMOD_sn_interface_dict}=  Create Dictionary

    ${BTS_RMOD_info}=  Get Parameters For All  class_name=RMOD  connection=${alias}

    FOR  ${rmod_info}  IN  @{BTS_RMOD_info}

        ${BTS_RMOD_sn}=  Get From Dictionary  ${rmod_info}  serialNumber
        ${BTS_RMOD_id}=  Get From Dictionary  ${rmod_info}  id
        ${BTS_RMOD_pn}=  Get From Dictionary  ${rmod_info}  productName
        ${BTS_RMOD_interface}=  Get From Dictionary  ${rmod_info}  l3Protocol

        Set To Dictionary  ${BTS_RMOD_sn_id_dict}  ${BTS_RMOD_sn}  ${BTS_RMOD_id}
        Set To Dictionary  ${BTS_RMOD_id_sn_dict}  ${BTS_RMOD_id}  ${BTS_RMOD_sn}
        Set To Dictionary  ${BTS_RMOD_sn_pn_dict}  ${BTS_RMOD_sn}  ${BTS_RMOD_pn}
        Set To Dictionary  ${BTS_RMOD_sn_interface_dict}  ${BTS_RMOD_sn}  ${BTS_RMOD_interface}

    END

    [Return]  ${BTS_RMOD_sn_id_dict}  ${BTS_RMOD_id_sn_dict}  ${BTS_RMOD_sn_pn_dict}  ${BTS_RMOD_sn_interface_dict}

Admin Get RMOD sn config info
    [Documentation]
    ...  KW used to get RMOD sn config info

    [Arguments]  ${alias}

    ${BTS_RMOD_sn_config_dn_dict}=  Create Dictionary
    ${BTS_RMOD_config_dn_sn_dict}=  Create Dictionary


    ${BTS_info}=  Get Bts Info  connection=${alias}

    FOR  ${item}  IN  @{BTS_info['radioModules']['rmod']}

        ${rmod_info}=  Get From Dictionary  ${item}  id
        ${BTS_RMOD_config_dn}=  Get From Dictionary  ${rmod_info}  configuration
        ${BTS_RMOD_sn}=  Get From Dictionary  ${item}  serialNumber

        Set To Dictionary  ${BTS_RMOD_sn_config_dn_dict}  ${BTS_RMOD_sn}  ${BTS_RMOD_config_dn}
        Set To Dictionary  ${BTS_RMOD_config_dn_sn_dict}  ${BTS_RMOD_config_dn}  ${BTS_RMOD_sn}

    END
    [Return]  ${BTS_RMOD_sn_config_dn_dict}  ${BTS_RMOD_config_dn_sn_dict}

Admin Get FHS sn config info
    [Documentation]
    ...  KW used to get FHS sn config info

    [Arguments]  ${alias}

    ${BTS_FHS_sn_config_dn_dict}=  Create Dictionary
    ${BTS_FHS_config_dn_sn_dict}=  Create Dictionary


    ${BTS_info}=  Get Bts Info  connection=${alias}

    FOR  ${item}  IN  @{BTS_info['fhs']}

        ${fhs_info}=  Get From Dictionary  ${item}  id
        ${BTS_FHS_config_dn}=  Get From Dictionary  ${fhs_info}  configuration
        ${BTS_FHS_sn}=  Get From Dictionary  ${item}  serialNumber

        Set To Dictionary  ${BTS_FHS_sn_config_dn_dict}  ${BTS_FHS_sn}  ${BTS_FHS_config_dn}
        Set To Dictionary  ${BTS_FHS_config_dn_sn_dict}  ${BTS_FHS_config_dn}  ${BTS_FHS_sn}

    END
    [Return]  ${BTS_FHS_sn_config_dn_dict}  ${BTS_FHS_config_dn_sn_dict}

Admin Get REF Object
    [Documentation]
    ...  Helper keyword providing Object referred by REF parameter inside an Object.
    ...
    ...  *INPUT*
    ...  | Parameter  | Man. | Default | Description                                    |
    ...  | object_dn  | Yes  |         | DN of Initial Object , which contains REF      |
    ...  | connection | Yes  |         | connection (alias) of admin instance           |
    ...
    ...  *RETURN*
    ...  | Parameter                | Description                                        |
    ...  | Referenced_Object_dn     | DN of Object referred by REF inside initial Object |

    [Arguments]  ${object_dn}  ${connection}

    ${Found_Object}=  Set Variable  ${None}
    ${Referenced_Object_dn}=  Set Variable  ${None}
    ${REF_obj_list} =  coam.Get Managed Objects  REF  connection=${connection}

    FOR  ${item}  IN  @{REF_obj_list}
            ${Found_Object}=  Set Variable If  '${object_dn}/REF' in '${item['distName']}'  ${item}  ${None}
            Exit For Loop If  ${Found_Object}
    END
    ${Referenced_Object_dn}=  Set Variable If  ${Found_Object}
    ...  ${Found_Object['parameters']['distName']}  ${None}

    [Return]  ${Referenced_Object_dn}

Admin Get LANE Operational State
    [Documentation]
    ...  Helper keyword providing LANE Operational State.
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | LANE_Id   | Yes  |         | LANE Id to be checked   |
    ...  | alias     | Yes  |         | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter                | Description               |
    ...  | LANE_operationalState    | LANE Id operational state |

    [Arguments]  ${LANE_Id}  ${connection}
    ${LANE_R_all} =  coam.Get Managed Objects  class_name=LANE_R  connection=${connection}
    FOR  ${LANE}  IN  @{LANE_R_all}
        ${LANE_R_object}=  Set Variable If  '${LANE['distName']}' == '${LANE_Id}'  ${LANE}  ${None}
        Exit For Loop If  ${LANE_R_object}
    END
    ${LANE_operationalState}=  Set Variable If  ${LANE_R_object}
    ...  ${LANE_R_object['parameters']['operationalState']}  ${None}

    [Return]  ${LANE_operationalState}

Check classical BTS cells operational status enabled
    [Documentation]
    ...  Keyword checking classical BTS cells operational status is enabled
    ...
    [Arguments]  ${alias}  ${timeout}

    Get Current Time  initial
    ${BTS_NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${remained_timeout}=  Get elapsed time  ${time_initial}  ${timeout}
    Run Keyword If  ${BTS_NR_CELL_list}
    ...  Assert Every  NRCEL  operationalState=${Enabled_}  timeout=${remained_timeout}  connection=${alias}

    Get Current Time  initial
    ${BTS_LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${remained_timeout}=  Get elapsed time  ${time_initial}  ${timeout}
    Run Keyword If  ${BTS_LTE_CELL_list}
    ...  Assert Every  LNCEL  operationalState=${Enabled_}  timeout=${remained_timeout}  connection=${alias}

    Get Current Time  initial
    ${BTS_WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${remained_timeout}=  Get elapsed time  ${time_initial}  ${timeout}
    Run Keyword If  ${BTS_WCDMA_CELL_list}
    ...  Assert Every  WNCEL  operationalState=${Enabled_}  timeout=${remained_timeout}  connection=${alias}

    Get Current Time  initial
    ${BTS_GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${remained_timeout}=  Get elapsed time  ${time_initial}  ${timeout}
    Run Keyword If  ${BTS_GSM_CELL_list}
    ...  Assert Every  GNCEL  operationalState=${Enabled_}  timeout=${remained_timeout}  connection=${alias}

Get linkModeSynchronization and linkModeConfiguration info dict
    [Documentation]
    ...  Keyword takes as input the 2 modules Serial Numbers and generates returns dictionary variables regarding
    ...  linkModeSynchronization status, linkModeConfiguration status and connector labels mapping for all the CABLINK
    ...  connecting the two modules
    ...
    ...  *INPUT*
    ...  | Parameter                  | Man. | Default | Description                                            |
    ...  | firstModuleSN              | Yes  |         | Serial Number of first module                          |
    ...  | secondModuleSN             | Yes  |         | Serial Number of second module                         |
    ...  | alias                      | No   |         | alias of admin instance                                |
    ...
    ...  *RETURN*
    ...  | Parameter                                                | Description                                                              |
    ...  | firstModule_connectorLabel_linkModeSynchronization_dict  | Dictionary containing first module linkModeSynchronization info          |
    ...  | secondModule_connectorLabel_linkModeSynchronization_dict | Dictionary containing second module linkModeSynchronization info         |
    ...  | firstModule_connectorLabel_linkModeConfiguration_dict    | Dictionary containing first module linkModeConfiguration info            |
    ...  | secondModule_connectorLabel_linkModeConfiguration_dict   | Dictionary containing second module linkModeConfiguration info           |
    ...  | firstModule_secondModule_connectorLabel                  | Dictionary containing firstModule - secondModule connectorLabels mapping |
    ...  | secondModule_firstModule_connectorLabel                  | Dictionary containing secondModule - firstModule connectorLabels mapping |

    [Arguments]  ${firstModuleSN}  ${secondModuleSN}  ${alias}=default

    ${firstModule_connectorLabel_linkModeSynchronization_dict}=  Create Dictionary
    ${secondModule_connectorLabel_linkModeSynchronization_dict}=  Create Dictionary
    ${firstModule_connectorLabel_linkModeConfiguration_dict}=  Create Dictionary
    ${secondModule_connectorLabel_linkModeConfiguration_dict}=  Create Dictionary
    ${firstModule_secondModule_connectorLabel}=  Create Dictionary
    ${secondModule_firstModule_connectorLabel}=  Create Dictionary
    ${SN_ID_Mapping_Dict}=  Get All Modules SN ID mapping  alias=${alias}
    ${firstModule_id}=  Get From Dictionary  ${SN_ID_Mapping_Dict}  ${firstModuleSN}
    ${secondModule_id}=  Get From Dictionary  ${SN_ID_Mapping_Dict}  ${secondModuleSN}

    ${CABLINK_id_firstEndPointId_dict}  ${CABLINK_id_secondEndPointId_dict}  ${CABLINK_id_configuration_dict}  ${CABLINK_id_data_dict}
    ...  ${CABLINK_id_dc_dict}  ${CABLINK_id_synchronization_dict}  ${CABLINK_id_operationalState_dict}=  Admin Get CABLINK info dict  ${alias}

    FOR  ${CABLINK_id}  IN  @{CABLINK_id_firstEndPointId_dict}
        ${linkModeConfiguration}=  Get From Dictionary  ${CABLINK_id_configuration_dict}  ${CABLINK_id}
        ${linkModeSynchronization}=  Get From Dictionary  ${CABLINK_id_synchronization_dict}  ${CABLINK_id}
        ${firstEndPointId}=  Get From Dictionary  ${CABLINK_id_firstEndPointId_dict}  ${CABLINK_id}
        ${secondEndPointId}=  Get From Dictionary  ${CABLINK_id_secondEndPointId_dict}  ${CABLINK_id}
        ${CABLINK_stateInfo}=  Get From Dictionary  ${CABLINK_id_operationalState_dict}  ${CABLINK_id}
        ${firstEndPoint_id_regex}=  Regexp Escape  ${firstModule_id}
        ${firstEndPointId_condition}=  Run Keyword And Return Status  Should Match Regexp  ${firstEndPointId}
        ...  ${firstEndPoint_id_regex}$|${firstEndPoint_id_regex}\/
        ${secondEndPoint_id_regex}=  Regexp Escape  ${secondModule_id}
        ${secondEndPointId_condition}=  Run Keyword And Return Status  Should Match Regexp  ${secondEndPointId}
        ...  ${secondEndPoint_id_regex}$|${secondEndPoint_id_regex}\/
        Continue For Loop If  not ${firstEndPointId_condition} or not ${secondEndPointId_condition}
        Run Keyword If  '${CABLINK_stateInfo}' not in '${Enabled_}'  Continue For Loop
        ${CBLINK_obj}=  Admin Get REF Object  object_dn=${CABLINK_id}  connection=${alias}
        ${CBLINK_parameters}=  coam.Get Parameters  ${CBLINK_obj}  connection=${alias}
        ${sourceDistName}=  coam.Get Parameters  ${CBLINK_parameters['sourceDistName']}  connection=${alias}
        ${destinationDistName}=  coam.Get Parameters  ${CBLINK_parameters['destinationDistName']}  connection=${alias}
        ${connectorLabel_source}=  Set Variable  ${sourceDistName['connectorLabel']}
        ${connectorLabel_destination}=  Set Variable  ${destinationDistName['connectorLabel']}
        Set To Dictionary  ${firstModule_connectorLabel_linkModeSynchronization_dict}
        ...  ${connectorLabel_destination}  ${linkModeSynchronization}
        Set To Dictionary  ${secondModule_connectorLabel_linkModeSynchronization_dict}
        ...  ${connectorLabel_source}  ${linkModeSynchronization}
        Set To Dictionary  ${firstModule_connectorLabel_linkModeConfiguration_dict}
        ...  ${connectorLabel_destination}  ${linkModeConfiguration}
        Set To Dictionary  ${secondModule_connectorLabel_linkModeConfiguration_dict}
        ...  ${connectorLabel_source}  ${linkModeConfiguration}
        Set To Dictionary  ${firstModule_secondModule_connectorLabel}
        ...  ${connectorLabel_destination}  ${connectorLabel_source}
        Set To Dictionary  ${secondModule_firstModule_connectorLabel}
        ...  ${connectorLabel_source}  ${connectorLabel_destination}
    END

    [Return]  ${firstModule_connectorLabel_linkModeSynchronization_dict}  ${secondModule_connectorLabel_linkModeSynchronization_dict}
    ...  ${firstModule_connectorLabel_linkModeConfiguration_dict}  ${secondModule_connectorLabel_linkModeConfiguration_dict}
    ...  ${firstModule_secondModule_connectorLabel}  ${secondModule_firstModule_connectorLabel}

Get All Modules SN ID mapping
    [Arguments]  ${alias}=default
    ${module_types}=  Create List    SMOD  BBMOD  FHS  RMOD
    ${all_module_ids}=  Create List
    ${SN_ID_Mapping_Dict}=  Create Dictionary
    FOR  ${module_type}  IN  @{module_types}
        ${status}  ${current_ids}=  Run Keyword And Ignore Error  Get Ids For All  class_name=${module_type}  connection=${alias}
        Run Keyword If  '${status}'=='PASS'
        ...  Append To List  ${all_module_ids}  @{current_ids}
    END
    FOR  ${id}  IN  @{all_module_ids}
        ${params}=  coam.Get Parameters  dist_name=${id}  connection=${alias}
        Set To Dictionary  ${SN_ID_Mapping_Dict}  ${params["serialNumber"]}=${id}
    END
    [Return]  ${SN_ID_Mapping_Dict}

Get PM Counter Value from Admin
    [Documentation]
    ...  Keyword takes as input argument the counter ID to be checked on a specific BTS at a specific event time.
    ...  Keyword returns the value of the counter, in case found and in case not found, it will fail
    ...
    ...  *INPUT*
    ...  | Parameter                  | Man. | Default | Description                                                                      |
    ...  | counter_path               | Yes  |         | Path of object inside BTS Counter structure, on which counter should be checked  |
    ...  | counter_id                 | Yes  |         | ID Of counter to be checked. Example: M40015C10                                  |
    ...  | event_time                 | Yes  |         | Epoch time of the event whose counter must be checked                            |
    ...  | PM_duration                | Yes  |         | PM Duration in seconds                                                           |
    ...  | alias                      | No   |         | alias of admin instance                                                          |
    ...
    ...  *RETURN*
    ...  | Parameter                                                | Description                                                              |
    ...  | counter_value                                            | Value of the counter. If value not found, keyword will fail              |

    [Arguments]  ${counter_path}  ${counter_id}  ${event_time}  ${PM_duration}  ${alias}=default

    Log  Checking counter ${counter_id} values for dn ${counter_path} on BTS ${alias}  console=True
    ${dn_elements}=  Split String  ${counter_path}  separator=/
    ${counters_dict}=  coam.Get PM Counters  counter_ids=${counter_id}  timeout=240  connection=${alias}
    ${elements_dict}=  Get From Dictionary  ${counters_dict}  BTS

    FOR  ${element}  IN  @{dn_elements}
        ${elements_dict}=  Get From Dictionary  ${elements_dict}  ${element}
    END

    ${PM_dict}=  Get From Dictionary  ${elements_dict}  ${counter_id}

    FOR  ${PM_start}  IN  @{PM_dict}
        ${counter_value}=  Get From Dictionary  ${PM_dict}  ${PM_start}
        ${PM_start_int}=  Convert To Integer  ${PM_start}
        ${PM_end_int}=  Evaluate  ${PM_start_int}+${PM_duration}
        Run Keyword If  (${event_time} >= ${PM_start_int}) and (${event_time} <= ${PM_end_int})  Run Keywords
        ...  Log  PM start:${PM_start_int}-end:${PM_end_int} counter ${counter_id} value found: ${counter_value}  console=True
        ...  AND  Return From Keyword  ${counter_value}
    END

    Fail  Could not extract desired PM counter value!

Get Cumulative PM Counter Value from Admin
    [Documentation]
    ...  Keyword takes as input argument the counter ID to be checked on a specific BTS in a specific event time interval.
    ...  Keyword returns the cumulative value of the counter, in case found and in case not found, it will fail
    ...
    ...  *INPUT*
    ...  | Parameter                  | Man. | Default | Description                                                                      |
    ...  | counter_path               | Yes  |         | Path of object inside BTS Counter structure, on which counter should be checked  |
    ...  | counter_id                 | Yes  |         | ID Of counter to be checked. Example: M40015C10                                  |
    ...  | event_time_start           | Yes  |         | Epoch time of the event start                                                    |
    ...  | event_time_end             | Yes  |         | Epoch time of the event end                                                      |
    ...  | PM_duration                | Yes  |         | PM Duration in seconds                                                           |
    ...  | alias                      | No   |         | alias of admin instance                                                          |
    ...
    ...  *RETURN*
    ...  | Parameter                                                | Description                                                              |
    ...  | counter_value                                            | Value of the counter. If value not found, keyword will fail              |

    [Arguments]  ${counter_path}  ${counter_id}  ${event_time_start}  ${event_time_end}  ${PM_duration}  ${alias}=default

    Log  Checking counter ${counter_id} values for dn ${counter_path} on BTS ${alias}  console=True
    ${dn_elements}=  Split String  ${counter_path}  separator=/
    FOR  ${try}  IN RANGE  1  5
        Sleep  10s
        ${status}  ${counters_dict}=  Run Keyword And Ignore Error  coam.Get PM Counters  counter_ids=${counter_id}  timeout=240  connection=${alias}
        Exit For Loop If  '${status}' == 'PASS'
    END
    Run Keyword If  '${status}' == 'FAIL'  Fail  Could not extract counter value for ${counter_id}!
    ${elements_dict}=  Get From Dictionary  ${counters_dict}  BTS
    ${counter_found}=  Set Variable  ${False}
    ${counter_cumulative_value}=  Set Variable  0

    FOR  ${element}  IN  @{dn_elements}
        ${elements_dict}=  Get From Dictionary  ${elements_dict}  ${element}
    END

    ${PM_dict}=  Get From Dictionary  ${elements_dict}  ${counter_id}

    FOR  ${PM_start}  IN  @{PM_dict}
        ${PM_start_int}=  Convert To Integer  ${PM_start}
        ${PM_end_int}=  Evaluate  ${PM_start_int}+${PM_duration}
        Continue For Loop If  (${PM_start_int} > ${event_time_end}) or (${PM_end_int} < ${event_time_start})
        ${counter_found}=  Set Variable  ${True}
        ${counter_value}=  Get From Dictionary  ${PM_dict}  ${PM_start}
        ${counter_value_int}=  Convert To Integer  ${counter_value}
        ${counter_cumulative_value}=  Evaluate  ${counter_cumulative_value}+${counter_value_int}
    END

    Run Keyword If  not ${counter_found}  Fail  Could not extract desired PM counter value!
    [Return]  ${counter_cumulative_value}

RFS Site Reset
    [Arguments]  ${wait_for_reconnection}=${False}  ${connection}=default  ${graceful_cell_shutdown}=True  ${reset_without_ru}=${None}

    ${graceful_cell_shutdown}=  Set Variable If
    ...  '${${connection.upper()}}[${connection.upper()}_MODULE_TYPE]' == 'FSMF'  ${None}  ${graceful_cell_shutdown}
    ${reset_without_ru}=  Set Variable If
    ...  '${${connection.upper()}}[${connection.upper()}_MODULE_TYPE]' == 'FSMF'  ${None}  ${reset_without_ru}

    coam.Reset Site  wait_for_reconnection=${wait_for_reconnection}  connection=${connection}  graceful_cell_shutdown=${graceful_cell_shutdown}
    ...  reset_without_ru=${reset_without_ru}

RFS RAT Reset
    [Arguments]  ${rat_type}  ${reset_type}=Soft  ${timeout}=60  ${connection}=default  ${alias}=default  ${graceful_cell_shutdown}=True

    ${graceful_cell_shutdown}=  Set Variable If
    ...  '${${alias.upper()}}[${alias.upper()}_MODULE_TYPE]' == 'FSMF'  ${None}  ${graceful_cell_shutdown}

    ${reset_info}=  Run Keyword In Background  Rat Reset  rat_type=${rat_type}  timeout=${timeout}  connection=${connection}
    ...  graceful_cell_shutdown=${graceful_cell_shutdown}  reset_type=${reset_type}

    [Return]  ${reset_info}

RFS RM Reset
    [Arguments]  ${dist_name}  ${reset_type}=Hard  ${timeout}=60  ${connection}=default  ${alias}=default  ${graceful_cell_shutdown}=True

    ${graceful_cell_shutdown}=  Set Variable If
    ...  '${${alias.upper()}}[${alias.upper()}_MODULE_TYPE]' == 'FSMF'  ${None}  ${graceful_cell_shutdown}

    ${reset_info}=  Run Keyword In Background  Reset Unit  dist_name=${dist_name}  reset_type=${reset_type}  timeout=${timeout}
    ...  connection=${connection}  graceful_cell_shutdown=${graceful_cell_shutdown}

    [Return]  ${reset_info}

Admin Check BTS HW product name info
    [Arguments]  ${class_name}  ${product_name}  ${alias}

    ${MOD_id_list}=  coam.Get Ids For All  class_name=${class_name}  connection=${alias}
    Sort List  ${MOD_id_list}

    FOR  ${item}  IN  @{MOD_id_list}

        ${MOD_param}=  coam.Get Parameters For  class_name=${class_name}  id_num=${item}  connection=${alias}
        ${HW_product_name}=  Get From Dictionary  ${MOD_param}  productName
        ${HW_status}=  Run Keyword And Return Status  Should Contain  ${HW_product_name}  ${product_name}

    END

    [Return]  ${HW_status}

Admin Check if BTS cells are unlocked
    [Documentation]
    ...  Helper keyword checking BTS configured cell(s) administrativeState info. If needed perform unlock BTS cell(s).
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    [Arguments]  ${alias}=default

    ${BTS_NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    FOR  ${item}  IN  @{BTS_NR_CELL_list}
        ${status}=  Run Keyword And Return Status
        ...  Assert  class_name=NRCEL  id=${item}  parameters=administrativeState=${Locked_}  timeout=5  connection=${alias}
        Run Keyword If  ${status}  Run Keywords
        ...  coam.Unlock  dist_name=${item}  connection=${alias}
        ...  AND  Sleep  30s  Wait for Cell ${item} recovery
        ...  AND  Log  Cell ${item} unlock recovery indicated  console=True
    END

    ${BTS_LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${BTS_LTE_HOST_CELL_id_list}  ${BTS_LTE_IOT_CELL_id_list}  ${BTS_LTE_IOT_SA_CELL__id_list}=
    ...  Admin Get LTE HOST and IOT Cell(s) Id list  CELL_list=${BTS_LTE_CELL_list}  alias=${alias}
    ${BTS_LTE_CELL_list}=  Combine Lists  ${BTS_LTE_HOST_CELL_id_list}  ${BTS_LTE_IOT_SA_CELL_id_list}
    FOR  ${item}  IN  @{BTS_LTE_CELL_list}
        ${status}=  Run Keyword And Return Status
        ...  Assert  class_name=LNCEL  id=${item}  parameters=administrativeState=${Locked_}  timeout=5  connection=${alias}
        Run Keyword If  ${status}  Run Keywords
        ...  coam.Unlock  dist_name=${item}  connection=${alias}
        ...  AND  Sleep  30s  Wait for Cell ${item} recovery
        ...  AND  Log  Cell ${item} unlock recovery indicated  console=True
    END

Admin Get FHS sn id pn info
    [Documentation]
    ...  Get BTS radio modules serial number, id and interface protocol info
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description             |
    ...  | alias     | No   | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description                                                          |
    ...  | BTS_FHS_sn_id_dict        | Dict containing structure: {'FHS_serial_number': 'FHS_id'}           |
    ...  | BTS_FHS_id_sn_dict        | Dict containing structure: {'FHS_id': 'FHS_serial_number'}           |
    ...  | BTS_FHS_sn_pn_dict        | Dict containing structure: {'FHS_serial_number': 'FHS_product_name'} |
    ...
    [Arguments]  ${alias}

    ${BTS_FHS_sn_id_dict}=  Create Dictionary
    ${BTS_FHS_id_sn_dict}=  Create Dictionary
    ${BTS_FHS_sn_pn_dict}=  Create Dictionary

    Return From Keyword If  '${${alias.upper()}}[${alias.upper()}_MODULE_TYPE]' == 'FSMF'

    ${BTS_FHS_info}=  Get Parameters For All  class_name=FHS  connection=${alias}

    FOR  ${FHS_info}  IN  @{BTS_FHS_info}

        ${BTS_FHS_sn}=  Get From Dictionary  ${FHS_info}  serialNumber
        ${BTS_FHS_id}=  Get From Dictionary  ${FHS_info}  id
        ${BTS_FHS_pn}=  Get From Dictionary  ${FHS_info}  productName

        Set To Dictionary  ${BTS_FHS_sn_id_dict}  ${BTS_FHS_sn}  ${BTS_FHS_id}
        Set To Dictionary  ${BTS_FHS_id_sn_dict}  ${BTS_FHS_id}  ${BTS_FHS_sn}
        Set To Dictionary  ${BTS_FHS_sn_pn_dict}  ${BTS_FHS_sn}  ${BTS_FHS_pn}

    END

    [Return]  ${BTS_FHS_sn_id_dict}  ${BTS_FHS_id_sn_dict}  ${BTS_FHS_sn_pn_dict}

Perform Administrative State Recommissioning
    [Documentation]
    ...  Perform Administrative State Change via Parameter Recommissioning
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter               | Man. | Description                                              |
    ...  | obj_scf_dn              | No   | SCF dn of object to be commissioned                      |
    ...  | administrativeState     | No   | value to be commissioned: e.g. Locked, Unlocked          |
    ...  | alias                   | No   | alias of admin instance                                  |
    ...  | timeout                 | No   | timeout to wait for positive procedure result            |
    ...
    [Arguments]  ${obj_scf_dn}  ${administrativeState}  ${alias}  ${timeout}

    Log  Performing Parameter Recommissioning on BTS ${alias} - ${obj_scf_dn} - administrativeState=${administrativeState}  console=True

    ${resp}=  coam.Perform Parameter Recommissioning  dist_name=${obj_scf_dn}  parameter=administrativeState  operation=update
    ...  value=${administrativeState}  skip_parameter_relation_errors=False  should_activate=True  timeout=${timeout}  alias=${alias}

    ${nidd_validation_status}=  Set Variable  ${resp["validationResult"]["niddValidationResult"]["status"]}
    ${pdl_validation_status}=  Set Variable  ${resp["validationResult"]["pdlValidationResult"]["status"]}
    ${definitionErrors}=  Set Variable  ${resp["validationResult"]["niddValidationResult"]["logs"]["definitionErrors"]}
    ${relationErrors}=  Set Variable  ${resp["validationResult"]["pdlValidationResult"]["logs"]["relationErrors"]}
    ${hardwareErrors}=  Set Variable  ${resp["validationResult"]["pdlValidationResult"]["logs"]["hardwareErrors"]}
    ${activation_result}=  Set Variable  ${resp["commissioningResult"]["activationResult"]["resultNode"]["parameters"]["result"]}

    Run Keyword If  ${relationErrors}  Fail  Parameter Recommissioning NIDD failed! Relation errors: ${relationErrors}
    Run Keyword If  ${hardwareErrors}  Fail  Parameter Recommissioning failed! Hardware errors: ${hardwareErrors}
    Run Keyword If  "${definitionErrors}"!="None"  Fail  Parameter Recommissioning failed! Definition errors: ${definitionErrors}
    Run Keyword If  "${nidd_validation_status}"!="OK"  Fail  Parameter Recommissioning NIDD Validation failed!
    Run Keyword If  "${pdl_validation_status}"!="OK"  Fail  Parameter Recommissioning PDL Validation failed!
    Run Keyword If  "${activation_result}"!="Success"  Fail  Parameter Recommissioning Activation failed!

    Log  Parameter Recommissioning succesfully performed!  console=True

Admin Check if BTS LANEs are unlocked
    [Arguments]  ${alias}

    ${LANE_Id_list}=  Create List
    ${LANE_info}=  coam.Get Managed Objects  class_name=LANE_R  connection=${alias}

    FOR  ${item}  IN  @{LANE_info}

        ${SMOD_R_LANE_id_check}=  Run Keyword And Return Status  Should Contain  ${item['distName']}  SMOD_R
        ${BBMOD_R_LANE_id_check}=  Run Keyword And Return Status  Should Contain  ${item['distName']}  BBMOD_R
        Continue For Loop If  '${SMOD_R_LANE_id_check}' == 'False' and '${BBMOD_R_LANE_id_check}' == 'False'

        ${LANE_status_check}=  Run Keyword And Return Status  Should Contain  ${item['parameters']['operationalState']}  enabled
        Continue For Loop If  ${LANE_status_check}

        Append to list  ${LANE_Id_list}  ${item['distName']}

    END

    ${LANE_count}=  Get Length  ${LANE_Id_list}
    Return From Keyword If  ${LANE_count} == 0

    Log  Recover LANE on BTS ${alias}:  console=True
    coam.Unlock  dist_name=${LANE_Id_list}  timeout=60  connection=${alias}
    Sleep  30s  Wait for LANE recovery
    Log  BTS ${alias} LANE unlock recovery indicated  console=True