*** Settings ***
Documentation    Keywords for SCF processing
Library          Collections
Library          OperatingSystem
Library          String
Library          taf.config.scf  WITH NAME  scf

*** Keywords ***

Get Value From Scf Custom
    [Arguments]  ${dist_name}=${NONE}  ${p_name}=${NONE}  ${processing}=${True}

    ${parameters_to_title}=  Create List  actSharedRUIndControl  peerBtsActSharedRUIndControl  actSuperCell  actBeamforming
    ${parameters_to_lowercase}=  Create List  actTempRadioMaster

    ${scf_parameter}=  scf.Get Value From Scf  dist_name=${dist_name}  p_name=${p_name}

    ${param_in_title}=  Run Keyword And Return Status  List Should Contain Value  ${parameters_to_title}  ${p_name}
    ${param_in_lowercase}=  Run Keyword And Return Status  List Should Contain Value  ${parameters_to_lowercase}  ${p_name}

    Return From Keyword If  ${processing} == ${False}  ${scf_parameter}
    Return From Keyword If  ${param_in_title}  ${scf_parameter.title()}
    Return From Keyword If  ${param_in_lowercase}  ${scf_parameter.lower()}
    Return From Keyword  ${scf_parameter}

Check Parameter value from SCF
    [Arguments]  ${item_dist_name}=${EMPTY}  ${parameter_to_check}=${EMPTY}  ${scf_path}=${EMPTY}

    scf.Load Scf  ${scf_path}

    ${keyword_status}  ${parameter_value}=  Run Keyword and Ignore Error
    ...  Get Value From Scf Custom  dist_name=${item_dist_name}  p_name=${parameter_to_check}

    Run Keyword If  '${keyword_status}' == 'PASS'
    ...  Log  Parameter ${parameter_to_check} located under ${item_dist_name} has value ${parameter_value}.
    ...  ELSE  Run Keywords
    ...  Log  Parameter ${parameter_to_check} value could not be extracted!
    ...  AND  Return From Keyword

    [Return]  ${parameter_value}

Get Cell Parameters from SCF
    [Documentation]
    ...  Keyword providing Cell parameters values from SCF.
    ...
    ...  *AUTHOR*
    ...  anca.tatar@nokia.com
    ...
    ...  | Parameter        | Man. | Description                      |
    ...  | parameters_list  | Yes  | list of parameters to be checked |
    ...  | cell_dist_name   | Yes  | cell distname                    |
    ...  | scf_path         | No   | scf path                         |
    ...  | alias            | Yes  | admin instance alias             |
    ...
    ...  *RETURN*
    ...  List of parameters values

    [Arguments]  @{parameters_list}  ${cell_dist_name}  ${scf_path}=${EMPTY}  ${alias}=default

    ${scf_path}=  Set Variable If  '${scf_path}' == '${EMPTY}'  ${${alias.lower()}_scf_initial}  ${scf_path}
    OperatingSystem.File Should Exist  ${scf_path}

    ${parameters_values}=  Create List

    FOR  ${item}  IN  @{parameters_list}
        ${p_value_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${scf_path}  dist_name=${cell_dist_name}
        ...  p_name=${item}
        ${p_value}=  Get Variable Value  ${p_value_info_dict['${item}']}  ${Empty}
        Append To List  ${parameters_values}  ${p_value}
    END

    [Return]  ${parameters_values}

Check If Parameter Exists from SCF
    [Arguments]  ${item_dist_name}=${EMPTY}  ${parameter_to_check}=${EMPTY}  ${scf_path}=${EMPTY}  ${alias}=default

    ${scf_path}=  Set Variable If  '${scf_path}' == '${EMPTY}'  ${${alias.lower()}_scf_initial}  ${scf_path}
    OperatingSystem.File Should Exist  ${scf_path}

    scf.Load Scf  ${scf_path}

    ${parameter_to_check_status}=  scf.Is Element In Object  dist_name=${item_dist_name}  p_name=${parameter_to_check}

    [Return]  ${parameter_to_check_status}

Get All Dist Names By Pattern from SCF
    [Arguments]  ${pattern}=${EMPTY}  ${scf_path}=${EMPTY}  ${alias}=default  ${load_scf}=True

    ${scf_path}=  Set Variable If  '${scf_path}' == '${EMPTY}'  ${${alias.lower()}_scf_initial}  ${scf_path}
    OperatingSystem.File Should Exist  ${scf_path}

    Run Keyword If  ${load_scf}  scf.Load Scf  ${scf_path}

    ${SCF_dn}=  scf.Get All Dist Names By Pattern  pattern=${pattern}

    [Return]  ${SCF_dn}

Get All Dist Names Of Specific Class
    [Documentation]
    ...  Keyword providing list of distinguish name
    ...  based on managedObject Class from SCF
    ...
    ...  *AUTHOR*
    ...  ana.tugui@nokia.com
    ...
    ...  | Parameter        | Man. | Description                   |
    ...  | mo_class         | Yes  | managed object class          |
    ...  | scf_path         | No   | scf path                      |
    ...  | alias            | Yes  | admin instance alias          |
    ...  | load_scf         | No   | load SCF; default value: True |
    ...
    ...  *RETURN*
    ...  List of distinguish name
    [Arguments]  ${mo_class}=${EMPTY}  ${scf_path}=${EMPTY}  ${alias}=default  ${load_scf}=True

    ${scf_path}=  Set Variable If  '${scf_path}' == '${EMPTY}'  ${${alias.lower()}_scf_initial}  ${scf_path}
    OperatingSystem.File Should Exist  ${scf_path}

    Run Keyword If  ${load_scf}  scf.Load Scf  ${scf_path}

    ${SCF_dn}=  scf.Get All Dist Names Of Specific Class  mo_class=${mo_class}

    [Return]  ${SCF_dn}

SCF Get X2 Link Status
    [Arguments]  ${alias}

    ${eNodeBId_x2LinkStatus_dict}=  Create Dictionary
    ${LTEENB_list}  ${LTEENB_count}=  Get LTEENB list  ${alias}
    Get Current Scf File  local_dir_path=${BTSFiles}/SCF_temp  file_name=SCF_temp.xml  connection=${alias}
    ...  export_type=configurationAndRuntimeObjects  with_auto_configured_parameters=${TRUE}
    scf.Load Scf  ${BTSFiles}/SCF_temp/SCF_temp.xml
    FOR  ${item}  IN  @{LTEENB_list}
        ${eNodeBId}=  scf.Get Value From Scf  dist_name=${item}  p_name=eNodeBId
        ${x2LinkStatus}=  scf.Get Value From Scf  dist_name=${item}  p_name=x2LinkStatus
        Set To Dictionary  ${eNodeBId_x2LinkStatus_dict}  ${eNodeBId}  ${x2LinkStatus}
    END

    [Return]  ${eNodeBId_x2LinkStatus_dict}

Get Object Attributes Values From Scf
    [Documentation]
    ...  Keyword providing values of object ‘name’ attribute in <p> tag and/or <list> tag
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter  | Man. | Description                                                                             |
    ...  | scf_path   | Yes  | SCF path file name info                                                                 |
    ...  | dist_name  | No   | Object 'distName' attribute, by default None                                            |
    ...  | p_name     | No   | Object ‘name’ attribute in <p> tag, by default None                                     |
    ...  | list_name  | No   | Object ‘name’ attribute in <list> tag, by default None                                  |
    ...  | index      | No   | Should be used if more than one match expected. Indexing starts from 0, by default None |
    ...
    ...  *RETURN*
    ...  | Parameter           | Description                                                                                                     |
    ...  | p_name_info_dict    | Dictionary containing structure: {'p_name': '<value>'} if p_name is found, otherwise dictionary is empty        |
    ...  | list_name_info_dict | Dictionary containing structure: {'list_name': '<values>'} if list_name is found, otherwise dictionary is empty |
    ...
    [Arguments]  ${scf_path}  ${dist_name}=${NONE}  ${p_name}=${NONE}  ${list_name}=${NONE}  ${index}=${NONE}

    ${p_name_info_dict}=  Create Dictionary
    ${list_name_info_dict}=  Create Dictionary

    scf.Load Scf  ${scf_path}

    ${p_name_status}=  Run Keyword If  '${p_name}' != '${NONE}'
    ...  scf.Is Element In Object  dist_name=${dist_name}  p_name=${p_name}
    ...  ELSE
    ...  Set Variable  ${False}
    ${p_name_value}=  Run Keyword If  ${p_name_status}
    ...  scf.Get Value From Scf  dist_name=${dist_name}  p_name=${p_name}
    Run Keyword If  ${p_name_status}
    ...  Set To Dictionary  ${p_name_info_dict}  ${p_name}  ${p_name_value}

    ${list_name_status}=  Run Keyword If  '${list_name}' != '${NONE}'
    ...  scf.Is List In Object  dist_name=${dist_name}  list_name=${list_name}
    ...  ELSE
    ...  Set Variable  ${False}
    ${list_name_values}=  Run Keyword If  ${list_name_status} and '${index}' == '${NONE}'
    ...  scf.Get All Values From Scf  dist_name=${dist_name}  list_name=${list_name}
    ...  ELSE IF  ${list_name_status} and '${index}' != '${NONE}'
    ...  scf.Get Value From Scf  dist_name=${dist_name}  list_name=${list_name}  index=${index}
    Run Keyword If  ${list_name_status}
    ...  Set To Dictionary  ${list_name_info_dict}  ${list_name}  ${list_name_values}

    [Return]  ${p_name_info_dict}  ${list_name_info_dict}

Get object dist name for timeZone parameter recommissioning
    [Arguments]  ${alias}  ${scf_path}=${EMPTY}

    ${MNL_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/MNL-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${MNL_dn}=  Get From List  ${MNL_dn_list}  0
    ${check1}=  Check If Parameter Exists from SCF  item_dist_name=${MNL_dn}  parameter_to_check=timeZone  scf_path=${scf_path}  alias=${alias}
    Return From Keyword If  '${check1}' == 'True'  ${MNL_dn}

    ${TIME_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/TIME-[\\d]+$  scf_path=${scf_path}  alias=${alias}
    ${TIME_dn}=  Get From List  ${TIME_dn_list}  0
    ${check2}=  Check If Parameter Exists from SCF  item_dist_name=${TIME_dn}  parameter_to_check=timeZone  scf_path=${scf_path}  alias=${alias}
    Return From Keyword If  '${check2}' == 'True'  ${TIME_dn}

    Run Keywords
    ...  Log  No object dist name found for timeZone parameter recomissioning for BTS ${alias}!  level=ERROR
    ...  AND  Fail  No object dist name found for timeZone parameter recomissioning for BTS ${alias}!

Get Time Zone from SCF
    [Documentation]
    ...  Get Time Zone from SCF
    [Arguments]  ${scf_path}  ${alias}
    ${dst_name}=  Get object dist name for timeZone parameter recommissioning  alias=${alias}  scf_path=${scf_path}
    ${timeZone}=  Check Parameter value from SCF  item_dist_name=${dst_name}  parameter_to_check=timeZone  scf_path=${scf_path}
    [Return]  ${timeZone}

Delete Mo Attribute from SCF
    [Documentation]
    ...  Delete attribute parameter of managed object indicated by dist_name.
    ...
    ...  | Parameter | Man. | Description                              |
    ...  | dist_name | Yes  | distName of managed object to be updated |
    ...  | attribute | Yes  | attribute to be deleted                  |
    ...  | scf_path  | Yes  | scf path                                 |
    ...  | load_scf  | No   | load SCF; default value: True            |
    ...
    [Arguments]  ${dist_name}  ${attribute}  ${scf_path}  ${load_scf}=True

    OperatingSystem.File Should Exist  ${scf_path}
    Run Keyword If  ${load_scf}  scf.Load Scf  ${scf_path}
    scf.Delete Mo Attribute  dist_name=${dist_name}  attribute=${attribute}

Set Mo Attribute from SCF
    [Documentation]
    ...  Sets parameter ‘attribute’ of managed object indicated in ‘dist_name’ to ‘value’.
    ...
    ...  | Parameter | Man. | Description                                                                             |
    ...  | dist_name | Yes  | distName of managed object to be updated                                                |
    ...  | attribute | Yes  | attribute to be changed (or set if attribute doesn’t exist in indicated managed object) |
    ...  | value     | Yes  | new value of ‘attribute’                                                                |
    ...  | scf_path  | Yes  | scf path                                                                                |
    ...  | load_scf  | No   | load SCF; default value: True                                                           |
    ...
    [Arguments]  ${dist_name}  ${attribute}  ${value}  ${scf_path}  ${load_scf}=True

    OperatingSystem.File Should Exist  ${scf_path}
    Run Keyword If  ${load_scf}  scf.Load Scf  ${scf_path}
    scf.Set Mo Attribute  dist_name=${dist_name}  attribute=${attribute}  value=${value}

SCF Add Element to SCF
    [Documentation]
    ...  Adds element to object in loaded SCF. The object is mapped by the attribute distName.
    ...  The element is added at the end of list of objects children. Changes are saved only after save_scf keyword.
    ...
    ...  | Parameter | Man. | Description                      |
    ...  | dist_name | Yes  | distName of managed object       |
    ...  | p_name    | Yes  | name of attribute of new element |
    ...  | value     |Yes   | value of new element             |
    ...  | scf_path  | Yes  | scf path                         |
    ...  | load_scf  | No   | load SCF; default value: True    |
    ...
    [Arguments]  ${dist_name}  ${p_name}  ${value}  ${scf_path}  ${load_scf}=True

    OperatingSystem.File Should Exist  ${scf_path}
    Run Keyword If  ${load_scf}  scf.Load Scf  ${scf_path}
    scf.Add Element to SCF  dist_name=${dist_name}  p_name=${p_name}  value=${value}

SCF Remove Element from SCF
    [Documentation]
    ...  Removes element from loaded SCF. Attributes are mapped to SCF element’s attributes.
    ...  If p_name or index given it removes only single element.
    ...  If not the whole managedObject is removed. Changes are saved only after save_scf keyword.
    ...
    ...  | Parameter | Man. | Description                    |
    ...  | dist_name | Yes  | distName of managed object     |
    ...  | p_name    | Yes  | ‘name’ attribute in <p> tag    |
    ...  | scf_path  | Yes  | scf path                       |
    ...  | load_scf  | No   | load SCF; default value: True  |
    ...
    [Arguments]  ${dist_name}  ${p_name}  ${scf_path}  ${load_scf}=True

    OperatingSystem.File Should Exist  ${scf_path}
    Run Keyword If  ${load_scf}  scf.Load Scf  ${scf_path}
    scf.Remove Element from SCF  dist_name=${dist_name}  p_name=${p_name}

SCF Add Object to SCF
    [Documentation]
    ...  Adds whole managedObject to loaded SCF. All parameters are mandatory and are addded as attributes to the object.
    ...  Changes are saved only after save_scf keyword.
    ...
    ...  | Parameter  | Man. | Description                                               |
    ...  | class_name | Yes  | added as attribute ‘class’                                |
    ...  | dist_name  | Yes  | distName of managed object                                |
    ...  | version    | Yes  | added as attribute ‘version’                              |
    ...  | operation  | Yes  | added as attribute ‘operation’, default value is ‘create’ |
    ...  | scf_path  | Yes  | scf path                                                   |
    ...  | load_scf  | No   | load SCF; default value: True                              |
    ...
    [Arguments]  ${class_name}  ${dist_name}  ${version}  ${operation}  ${scf_path}  ${load_scf}=True

    OperatingSystem.File Should Exist  ${scf_path}
    Run Keyword If  ${load_scf}  scf.Load Scf  ${scf_path}
    scf.Add Object to SCF  class_name=${class_name}  dist_name=${dist_name}  version=${version}  operation=${operation}
