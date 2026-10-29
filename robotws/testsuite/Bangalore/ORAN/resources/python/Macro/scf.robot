*** Settings ***
Documentation       generic SCF related keywords
Resource            ./resources.txt
Library             Python/coam_parameter.py

*** Variables ***
@{BTS_PROCEDURAL_STATES}             Configured    OnAir    IntegratedToRan

*** Keywords ***
Get Parameter Values
    [Arguments]         ${parameters}     ${check_value}=${False}     ${config_type}=configuration    ${alias}=cOAM
    [Documentation]     Gets values from current xml file,
    ...                 config_type: configuration, configurationAndRuntimeObjects or runtimeObjects
    ...                 parameters: list of dicts, examples are mentioend below.
    ...                 parameters = [ {'dist_name': None, 'parameter':'btsName', 'value':'Automation_Testing'},
    ...                 {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCgiPlmnId',
    ...                 'value':[{'mcc':'262','mnc':'3', "mncLength":'2'}]},
    ...                 {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCellId', 'value':'32765'},
    ...                 {'dist_name': 'NRBTS-1/NRDU-1', 'parameter':'refNrCellGroup', 'value':['0']},
    ...                 {'dist_name': 'MNL-1/MNLENT-2/SYNC-1/CLOCK-1/TOP-1/TOPP-1', 'parameter':'topMasterList',
    ...                 value':[{'masterIpAddr':None}], p_index=1}]
    ...                 check_value= ${True}: verify parameter values if not ${False}:
    ...                 alias:   AdminConnection object or if used, string name alias
    ...                 return:  list of dicts with current values
    ...  author:        venkata.rajesh@nokia.com
    ...  modified by:   <22-MAY-2019>, <verajesh>, <e.g. PR-Number, feature number>
    ${param_values}=     coam_parameter.get_list_values_from_scf_file       local_dir_path=${None}
    ...                  parameters=${parameters}    check_value=${check_value}       connection=${alias}
    ...                  config_type=${config_type}
    [Return]             ${param_values}

Get Single Parameter Value
    [Arguments]   ${parameter}=${None}   ${list_name}=${None}   ${dist_name}=${None}   ${p_index}=${0}  ${alias}=cOAM
    ...           ${config_type}=configuration
    [Documentation]      Gets value from current xml file,
    ...     config_type: configuration, configurationAndRuntimeObjects or runtimeObjects
    ...     parameter:   name of parameter, if list not having parameter , mandatory to pass list_name.Ex: nrCellList
    ...     list_name:   list name
    ...     dist_name:   Dist Name, default None indicates root Dist name Ex: MRBTS-1
    ...     p_index:     optional parameter, should be castable to int. Should be used if more than one match expected.
    ...     alias:       AdminConnection object or if used, string name alias
    ...     return:      parameter value
    ...  author:         venkata.rajesh@nokia.com
    ...  modified by:    <22-MAY-2019>, <verajesh>, <e.g. PR-Number, feature number>
    ${param_value}=     coam_parameter.get_single_value_from_scf_file       local_dir_path=${None}   p_index=${p_index}
    ...                 parameter=${parameter}   list_name=${list_name}   dist_name=${dist_name}     connection=${alias}
    ...                 config_type=${config_type}
    [Return]            ${param_value}

Update SCF Parameter
    [Arguments]         ${value}    ${parameter}=${None}   ${list_name}=${None}   ${dist_name}=${None}
    ...                 ${alias}=cOAM       ${timeout}=60
    [Documentation]     Update single SCF parameter
    ...    value:       str or list, value of parameter or list parameter
    ...   parameter:    Name of parameter, either parameter or list_name should be set.
    ...   list_name:    list name
    ...   dist_name:    Dist Name, default None indicates root Dist name Ex: MRBTS-1
    ...   timeout:      Time to wait for positive procedure result
    ...   alias:        AdminConnection object or if used, string name alias
    ...   return:       raise exception if recommission failed, PASS - online parameter update
    ...                 RESET_PASS - parameter update is successful and BTS is going to trigger reset & reverse delta JSON path.
    ...  author:        venkata.rajesh@nokia.com
    ...  modified by:   <22-MAY-2019>, <verajesh>, <e.g. PR-Number, feature number>
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     gnb.Verify BTS Procedural State   alias=${alias}
    ...                 proceduralStates=${BTS_PROCEDURAL_STATES}
    ${update_results}=  coam_parameter.perform_single_parameter_update       value=${value}
    ...                 parameter=${parameter}   list_name=${list_name}   dist_name=${dist_name}
    ...                 timeout=${timeout}     connection=${alias}
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     gnb.Verify BTS Procedural State   alias=${alias}
    ...                 proceduralStates=${BTS_PROCEDURAL_STATES}
    Get Parameter Values     parameters=${update_results['parameters']}     check_value=${True}
    ...                 alias=${alias}
    [Return]    ${update_results['update_status']}    ${update_results['reverse']}

Perform Object Recommission for parameter
    [Arguments]         ${parameter}   ${value}    ${dist_name}=${None}  ${operation}=update
    ...                 ${alias}=cOAM       ${timeout}=60
    [Documentation]    Perform object recommissioning, create, update and delete operation can be used.
    ...   :return: raise exception if recommission failed, PASS - online parameter update
    ...              RESET_PASS - parameter update is successful and BTS is going to trigger reset
    ...   :param operation: create, update or delete
    ...   :param value: Parameter value 10.0.1.99 or ['1','2'] or [{'param1': 'value1', 'param2':'value2'}]
    ...   :param parameter: Parameter name it can be list name also
    ...   :param dist_name: Object distName
    ...   :param skip_parameter_relation_errors: kip parameter relation errors
    ...   :param should_activate: Should automatically activate plan
    ...   :param timeout: Time to wait for positive procedure result
    ...   :param connection: AdminConnection object or if used, string name alias
    ...  author:        venkata.rajesh@nokia.com
    ...  modified by:   <22-MAY-2019>, <verajesh>, <e.g. PR-Number, feature number>
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     gnb.Verify BTS Procedural State   alias=${alias}
    ...                 proceduralStates=${BTS_PROCEDURAL_STATES}
    ${commission_status}=   coam_parameter.perform_object_parameter_recommission     parameter=${parameter}   value=${value}
    ...   dist_name=${dist_name}    operation=${operation}   connection=${alias}    timeout=${timeout}
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     gnb.Verify BTS Procedural State   alias=${alias}
    ...                 proceduralStates=${BTS_PROCEDURAL_STATES}
    [Return]                 ${commission_status}

Update List Of SCF Parameters
    [Arguments]         ${parameters}=${None}       ${timeout}=60     ${alias}=cOAM    ${required_reverse_delta}=${True}
    [Documentation]     Update list of  SCF parameters
    ...   parameters:   List of dicts.
    ...   parameter = [ {'dist_name': None, 'parameter':'btsName', 'value':'Automation_Testing'},
    ...                 {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCgiPlmnId',
    ...                 'value':[{'mcc':'262','mnc':'3', "mncLength":'2'}]},
    ...                 {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCellId', 'value':'32765'},
    ...                 {'dist_name': 'NRBTS-1/NRDU-1', 'parameter':'refNrCellGroup', 'value':['0']}
    ...               ]
    ...   timeout:      Time to wait for positive procedure result
    ...   alias:        AdminConnection object or if used, string name alias
    ...   required_reverse_delta:  Reverse Delta file is required or not, default True
    ...   return:       raise exception if recommission failed, PASS - online parameter update
    ...   RESET_PASS -  parameter update is successful and BTS is going to trigger reset & reverse delta JSON path.
    ...  author:        venkata.rajesh@nokia.com
    ...  modified by:   <22-MAY-2019>, <verajesh>, <e.g. PR-Number, feature number>
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     gnb.Verify BTS Procedural State   alias=${alias}
    ...                 proceduralStates=${BTS_PROCEDURAL_STATES}
    ${delta_file}=      coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${alias}
    ...    required_reverse_delta=${required_reverse_delta}
    ${update_status}=   coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}
    ...                 timeout=${timeout}     connection=${alias}
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     gnb.Verify BTS Procedural State   alias=${alias}
    ...                 proceduralStates=${BTS_PROCEDURAL_STATES}
    Get Parameter Values     parameters=${parameters}     check_value=${True}     alias=${alias}
    [Return]                 ${update_status}             ${delta_file['reverse']}

Add List of SCF objects
    [Arguments]   ${parameters}=${None}       ${timeout}=60       ${alias}=cOAM
    [Documentation]     Create list of  SCF objects
    ...  parameters:    List of dicts.which should contains required list of parameters to create a objects
    ...  parameter = [
    ...                     {'dist_name': 'TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-100', 'parameter':'vlanId',
    ...                     'value':'601'},
    ...                     {'dist_name': 'TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-200', 'parameter':'vlanId',
    ...                     'value':'701'},
    ...              ]
    ...  timeout:      Time to wait for positive procedure result
    ...  alias:        AdminConnection object or if used, string name alias
    ...  return:       raise exception if recommission failed, PASS - online parameter update
    ...  RESET_PASS -  parameter update is successful and BTS is going to trigger reset & reverse delta JSON path.
    ...  author:       venkata.rajesh@nokia.com
    ...  modified by:  <22-MAY-2019>, <verajesh>, <e.g. PR-Number, feature number>
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     gnb.Verify BTS Procedural State   alias=${alias}
    ...                proceduralStates=${BTS_PROCEDURAL_STATES}
    ${delta_file}=     coam_parameter.create_objects_delta  parameters=${parameters}  connection=${alias}
    ${commission_status}=   coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}
    ...                timeout=${timeout}     connection=${alias}
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     gnb.Verify BTS Procedural State   alias=${alias}
    ...                proceduralStates=${BTS_PROCEDURAL_STATES}
    Get Parameter Values     parameters=${parameters}     check_value=${True}     alias=${alias}
    [Return]                 ${commission_status}         ${delta_file['reverse']}

Delete List of SCF objects
    [Arguments]         ${parameters}=${None}       ${timeout}=60    ${alias}=cOAM
    [Documentation]     Delete list of  SCF objects
    ...  parameters:    List of dicts.
    ...  parameter = [
    ...                     {'dist_name': 'TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-100', 'parameter':'vlanId',
    ...                     'value':'601'},
    ...                     {'dist_name': 'TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-200', 'parameter':'vlanId',
    ...                     'value':'701'},
    ...              ]
    ...  alias:        AdminConnection object or if used, string name alias
    ...  timeout:      Time to wait for positive procedure result
    ...  return:       raise exception if recommission failed, PASS - online parameter update
    ...  RESET_PASS -  parameter update is successful and BTS is going to trigger reset
    ...  author:       venkata.rajesh@nokia.com
    ...  modified by:  <22-MAY-2019>, <verajesh>, <e.g. PR-Number, feature number>
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     gnb.Verify BTS Procedural State   alias=${alias}
    ...                proceduralStates=${BTS_PROCEDURAL_STATES}
    ${delta_file}=     coam_parameter.create_delete_objects_delta  parameters=${parameters}  connection=${alias}
    ${commission_status}=   coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}
    ...                timeout=${timeout}     connection=${alias}
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     gnb.Verify BTS Procedural State   alias=${alias}
    ...                proceduralStates=${BTS_PROCEDURAL_STATES}
    [Return]           ${commission_status}

Delta SCF Commissioning
    [Arguments]      ${delta_scf_path}=${None}      ${delta_operation}=update    ${timeout}=60      ${alias}=cOAM
    [Documentation]  This keyword is used to Perform Delta SCF xml recommission.
    ...              and reverse delta JSON path(not available for delete delta operation, it will return None).
    ...              delta_scf_path:  Delta SCF xml file path
    ...              delta_operation:  Delta SCF xml operation, options: update, create, delete
    ...              timeout: Time to wait for positive procedure result
    ...              return:  raise exception if recommission failed, PASS - online parameter update
    ...              RESET_PASS - parameter update is successful and BTS is going to trigger reset
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     gnb.Verify BTS Procedural State   alias=${alias}
    ...                 proceduralStates=${BTS_PROCEDURAL_STATES}
    ${convert_status}=  coam_parameter.convert_delta_scf_xml         delta_xml_path=${delta_scf_path}
    ...                 delta_operation=${delta_operation}           connection=${alias}
    ${update_status}=   coam_parameter.perform_scf_delta_commission  delta_file=${convert_status['updated']}
    ...                 timeout=${timeout}     connection=${alias}
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     gnb.Verify BTS Procedural State   alias=${alias}
    ...                 proceduralStates=${BTS_PROCEDURAL_STATES}
    Get Parameter Values    parameters=${convert_status['parameters']}   check_value=${True}    alias=${alias}
    [Return]                ${update_status}     ${convert_status['reverse']}
    
    