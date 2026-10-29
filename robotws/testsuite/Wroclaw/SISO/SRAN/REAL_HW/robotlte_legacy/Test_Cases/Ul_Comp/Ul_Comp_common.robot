*** Settings ***
Documentation   Common keywords for ul comp testing.
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak


Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     XML    use_lxml=${TRUE}
Resource    ../../../Resources/SiSo_L3_call.robot

*** Variables ***
${IGNORE_ERRORS}    ${FALSE}
${RECOMMISSIONING_TIMEOUT}     600
&{EUTRAN_DISTNAME_CELLS_DICT}
&{CELLID_TO_EUTRAN_CELLS_DICT}
${IS_ULCOMP_ACTIVE}    ${True}

*** Keywords ***
Precondition UlComp
    [Arguments]  ${node}
    Log  === Precondition ===  console=${TRUE}
    Set Test Variable  ${ADD_REMOVE_TEST}  False
    Get Current SCF File  ${cfg.test_logs_path}  SCF_precondition.xml  connection=${node}
    ${SCF_XML}=  Parse xml  ${cfg.test_logs_path}/SCF_precondition.xml
    ${current_scf_file_path}=  Get Current Scf File  local_dir_path=${cfg.test_logs_path}  file_name=SCF_START.xml  connection=${node}
    Load Scf  file_path=${current_scf_file_path}
    ${is_basic}=  Is Object In Scf  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMPBASICCONF-0
    ${ul_comp_type}=  Get Value From Scf  dist_name=MRBTS-${node}/LNBTS-${node}  p_name=actCoMp
    Run Keyword If    ${IS_ULCOMP_ACTIVE}==${True} and '${ul_comp_type}'=='disabled'
    ...  Fail    msg=Ul Comp is not activated. Check actComp parameter in configuration!
    ${cell_list}=  Get Cell List  connection=${node}
    ${lte_variant_status}=  Set Variable  ${cfg["NODES"]["${node}"]["scf_lte_variant"]}
    ${earfcnUplink_list}=  Run Keyword If  '${lte_variant_status}' == 'fdd'  Create List
    ${ulChBw_list}=  Run Keyword If  '${lte_variant_status}' == 'fdd'  Create List
    ${earfcnUpDownlink_list}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  Create List
    ${ChBw_list}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  Create List
    ${subframe_conf_list}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  Create List
    ${special_subframe_conf_list}  Run Keyword If  '${lte_variant_status}' == 'tdd'  Create List
    Prepare Cell Distname List For Call  ${node}
    Log  ${EUTRAN_DISTNAME_CELLS_DICT}
    Run Keyword If  '${ul_comp_type}'=='measBasedCoMp' or '${ul_comp_type}'=='fixedULCoMp'
    ...  Check Cells For Already Configured Ul Comp  is_basic=${is_basic}  ul_comp_type=${ul_comp_type}  node=${node}

Check Cells For Already Configured Ul Comp
    [Arguments]  ${is_basic}  ${ul_comp_type}  ${node}
    Set Test Variable  ${ADD_REMOVE_TEST}  True
    ${ul_comp_distnames}=  Check UlComp Distnames  is_basic=${is_basic}  ul_comp_type=${ul_comp_type}
    ${mhm_list}=  Create List
    FOR  ${item}  IN  @{ul_comp_distnames}
        ${cells}=  Run Keyword If  ${is_basic}==True or '${ul_comp_type}'=='measBasedCoMp'
        ...  Get All Values From Scf By Pattern  dist_name=${item}  p_name=lnCelId
    ...  ELSE IF  '${ul_comp_type}'=='fixedULCoMp'   Get All Values From Scf By Pattern  dist_name=${item}
    ...  ELSE  Fail  Check if UlCoMP is configured on the line!
        ${cells}=  Get All Values From Scf By Pattern  dist_name=${item}
        Cell List Unzip and Pack To List  ${cells}  ${mhm_list}
        Log to console  Checking Cell Parameters started for ${item}  console=True
        Check Cells Parameters For Ul Comp Pool Cells
        ...  node=${node}  same_dist_cell_list=${mhm_list}  is_basic=${is_basic}  ul_comp_type=${ul_comp_type}
        Log to console  Parameters OK for cells in distname ${item}  console=True
    END

Check Cells Parameters For Ul Comp Pool Cells
    [Arguments]  ${node}  ${same_dist_cell_list}  ${is_basic}  ${ul_comp_type}
    ${lte_variant_status}=  Set Variable  ${cfg["NODES"]["${node}"]["scf_lte_variant"]}
    ${earfcnUplink_list}=  Run Keyword If  '${lte_variant_status}' == 'fdd'  Create List
    ${ulChBw_list}=  Run Keyword If  '${lte_variant_status}' == 'fdd'  Create List
    ${earfcnUpDownlink_list}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  Create List
    ${ChBw_list}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  Create List
    ${subframe_conf_list}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  Create List
    ${special_subframe_conf_list}  Run Keyword If  '${lte_variant_status}' == 'tdd'  Create List
    FOR  ${cell_runtime}  IN  @{UL_COMP_LIST}
        ${cell_info}=  Get Cell Specific Info  cell_id=${cell_runtime}  timeout=10  connection=${node}  detailed_output=False
        Log  ${cell_info['globalCellId']}
        @{cell_List}=  split string  ${cell_runtime}  -
        Log  ${cell_List}[-1]
        Continue For Loop If   "${cell_List}[-1]" not in "${same_dist_cell_list}"
        Remove Values From List  ${same_dist_cell_list}  ${cell_list}[-1]
        Run Keyword If  '${lte_variant_status}' == 'fdd'  Run Keywords
        ...  Append To List  ${earfcnUplink_list}  ${cell_info["earfcnUplink"]}
        ...  AND  Append To List  ${ulChBw_list}  ${cell_info["uplinkChannelBandwidth"]}
        ${subframe}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  SCFC Get Attribute Value For LncelId
          ...  ${SCF_XML}  ${cell_list}[-1]  tddFrameConf
        ${special_subframe}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  SCFC Get Attribute Value For LncelId
          ...  ${SCF_XML}  ${cell_list}[-1]  tddSpecSubfConf
        Run Keyword If  '${lte_variant_status}' == 'tdd'  Run Keywords
        ...  Append To List  ${earflcnUpDownlink_list}  ${cell_info["earfcn"]}
        ...  AND  Append To List  ${ChBw_list}  ${cell_info["ChannelBandwidth"]}
        ...  AND  Append To List  ${subframe_conf_list}  ${subframe}
        ...  AND  Append To List  ${special_subframe_conf_list}  ${special_subframe}
    END
    ${earfcnUplink_set}=  Run Keyword If  '${lte_variant_status}' == 'fdd'  Evaluate  set(${earfcnUplink_list})
    ${ulChBw_set}=  Run Keyword If  '${lte_variant_status}' == 'fdd'  Evaluate  set(${ulChBw_list})
    ${ChBw_set}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  Evaluate  set(${ChBw_list})
    ${earfcnUpDownlink_set}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  Evaluate  set(${earfcnUpDownlink_list})
    ${subframe_conf_set}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  Evaluate  set(${subframe_conf_list})
    ${special_subframe_conf_set}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  Evaluate  set(${special_subframe_conf_list})
    Run Keyword If  '${lte_variant_status}' == 'fdd' and '${is_basic}'=='False' and '${ul_comp_type}'=='measBasedCoMp'   Run Keywords
    ...  Length Should Be	${earfcnUplink_set}  2  msg='EARFCN values are not the same'
    ...  AND  Length Should Be  ${ulChBw_set}  1  msg='Channel BW are not the same'
    Run Keyword If  '${lte_variant_status}' == 'fdd' and '${is_basic}'=='False' and '${ul_comp_type}'=='fixedULCoMp'   Run Keywords
    ...  Length Should Be	${earfcnUplink_set}  1  msg='EARFCN values are not the same'
    ...  AND  Length Should Be  ${ulChBw_set}  1  msg='Channel BW are not the same'
    Run Keyword If  '${lte_variant_status}' == 'fdd' and '${is_basic}'=='True'   Run Keywords
    ...  Length Should Be	${earfcnUplink_set}  1  msg='EARFCN values are not the same'
    ...  AND  Length Should Be  ${ulChBw_set}  1  msg='Channel BW are not the same'
    Run Keyword If  '${lte_variant_status}' == 'tdd'  Run Keywords
    ...  Length Should Be	${ChBw_set}  1  msg='EARFCN values are not the same'
    ...  AND  Length Should Be  ${earfcnUpDownlink_set}  1  msg='Channel BW are not the same'
    ...  AND  Length Should Be	${subframe_conf_set}  1  msg='TDD subframe configuration are not the same'
    ...  AND  Length Should Be  ${special_subframe_conf_set}  1  msg='TDD special subframe configuration are not the same'
    ${earfcnUplink_list}=  Run Keyword If  '${lte_variant_status}' == 'fdd'  Create List
    ${ulChBw_list}=  Run Keyword If  '${lte_variant_status}' == 'fdd'  Create List
    ${earfcnUpDownlink_list}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  Create List
    ${ChBw_list}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  Create List
    ${subframe_conf_list}=  Run Keyword If  '${lte_variant_status}' == 'tdd'  Create List
    ${special_subframe_conf_list}  Run Keyword If  '${lte_variant_status}' == 'tdd'  Create List
    Log  ${cfg}  console=False

Prepare Cell Distname List For Call
    [Arguments]    ${node}
    ${empty_list}=  Run Keyword And Return Status  Should Be Empty  ${UL_COMP_LIST}
    Run Keyword If  ${empty_list}  Fail  'SELECTED_CELL' => ${id} not found or disabled in admin
    Import Variables  ${CELLS_YAML_PATH}
    ${selected_ul_comp_cells}=  Create list
    FOR    ${id}   IN    @{UL_COMP_LIST}
      ${dist}=  _SiSo Match Cell To RAT On Every Node  rat=any  id=${id}  connection=any
      ${cell_missing}=  Run Keyword And Return Status  Should Be Empty  ${dist}
      Run Keyword If  ${cell_missing}  Fail  SELECTED_CELL => ${id} not found.
      Append To List  ${selected_ul_comp_cells}  ${dist}
      ${cell_specific_info}=  Get Cell Specific Info  cell_id=${dist}  connection=${node}
      Set To Dictionary  ${EUTRAN_DISTNAME_CELLS_DICT}  '${cell_specific_info['globalCellId']}'  ${dist}
      Set To Dictionary  ${CELLID_TO_EUTRAN_CELLS_DICT}  '${cell_specific_info['globalCellId']}'  ${id}
    END
    Set Test Variable  @{UL_COMP_LIST}  @{selected_ul_comp_cells}

Check Remaining Cells in Pool And Set Them For L3Call
    [Arguments]  ${node}  ${is_basic}
    ${current_scf_file_path}=  Get Current Scf File  local_dir_path=${cfg.test_logs_path}  file_name=Remaining_Cells.xml  connection=${node}
    Load Scf  file_path=${current_scf_file_path}
    ${remaining_cells_list}=  Create List
    ${is_basic}=  Is Object In Scf  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMPBASICCONF-0
    ${ul_comp_type}=  Get Value From Scf  dist_name=MRBTS-${node}/LNBTS-${node}  p_name=actCoMp
    ${ul_comp_distnames}=  Check UlComp Distnames  is_basic=${is_basic}  ul_comp_type=${ul_comp_type}
    FOR  ${item}  IN  @{ul_comp_distnames}
         ${cells}=  Run Keyword If  ${is_basic}==True or '${ul_comp_type}'=='measBasedCoMp'  Get All Values From Scf By Pattern
           ...  dist_name=${item}  p_name=lnCelId
    ...  ELSE IF  '${ul_comp_type}'=='fixedULCoMp'   Get All Values From Scf By Pattern  dist_name=${item}
    ...  ELSE  Fail  Check if UlCoMP is configured on the line!
        Run Keyword If   '${ul_comp_type}'=='fixedULCoMp'  Remove From List  ${cells}  -1
        Cell List Unzip and Pack To List  ${cells}  ${remaining_cells_list}
    END
    Log  Cells ${remaining_cells_list} will be called.
    ${remaining_cells_distname_list}=  Create List
    ${all_cells_info}=  Get Cells Info  cell_type=lte  connection=${node}
    ${dict_keys}=  Get Dictionary Keys  ${EUTRAN_DISTNAME_CELLS_DICT}  ${remaining_cells_list}[0]
    FOR    ${id}   IN    @{remaining_cells_list}
      ${cell_id}=  Get From Dictionary	${CELLID_TO_EUTRAN_CELLS_DICT}  '${id}'
      ${dist}=  _SiSo Match Cell To RAT On Every Node  rat=any  id=${cell_id}  connection=any
      ${cell_missing}=  Run Keyword And Return Status  Should Be Empty  ${dist}
      Run Keyword If  ${cell_missing}  Fail  SELECTED_CELL => ${cell_id} not found.
      Append To List  ${remaining_cells_distname_list}  ${dist}
    END
    Set Test Variable  ${SELECTED_CELLS}  ${remaining_cells_distname_list}

Change EutranCellId To Distnames
    [Arguments]  ${eutrancellid_list}
    FOR  ${cell_id}  IN  @{eutrancellid_list}
        Log to console  ${cell_id}  console=True
    END

Check UlComp Distnames
    [Arguments]  ${is_basic}  ${ul_comp_type}
    ${ul_comp_distnames}=  Run Keyword If   '${is_basic}'=='True'   Get all dist names of specific class  mo_class=NOKLTE:ULCOMPBASICCONF  #BASIC
    ...  ELSE IF  '${ul_comp_type}'=='fixedULCoMp'  Get All Dist Names Of Specific Class  mo_class=NOKLTE:ULCOMP
    ...  ELSE IF  '${ul_comp_type}'=='measBasedCoMp'  Get All Dist Names Of Specific Class  mo_class=NOKLTE:COMPCONF
    ...  ELSE  Fail  Check if UlCoMP is configured on the line!
    [Return]    ${ul_comp_distnames}

Cell List Unzip And Pack To List
    [Arguments]  ${cell_list_to_unzip}  ${target_list}
    FOR  ${item}  IN  @{cell_list_to_unzip}
        Append To List  ${target_list}  ${item}
    END

Postcondition UlComp
    Log  === Postcondition ===  console=${TRUE}
    Force Recommissioning With Current Branch On Every Node
    Logging Multinode Stop  ${cfg.test_logs_path}  status=PASS

Validate Delta Against SCF
    [Documentation]
    ...  KW Validates Delta against SCF file depending on ${mode}
    ...  ${mode} accepts 'excluded' or 'included' in case of Delta file
    [Arguments]  ${mode}  ${is_basic}=False
    [Timeout]  15 min
    Log  Validate Delta Against SCF  console=${TRUE}
    ${mode_backup_variable}=  Set Variable  ${mode}
    ${Deleted_json_file_data}=  Set Variable  ${DELTA_JSON_FILE}
    Log  ${DELTA_JSON_FILE}
    FOR  ${scf_object}  IN  @{DELTA_JSON_FILE}
        Run Keyword If  '${scf_object['operation']}' == 'update' and '${mode}' == 'excluded' and '${ADD_REMOVE_TEST}' == 'True'
        ...  Check Removed Cell From UlComp  is_basic=${is_basic}
        ${mode}=  Run Keyword If  '${scf_object['operation']}' == 'update' and '${mode}' == 'excluded' and '${ADD_REMOVE_TEST}' == 'True'
        ...  Set Variable  included
        ...  ELSE  Set Variable  ${mode_backup_variable}
    END
    FOR  ${scf_object}  IN  @{DELTA_JSON_FILE}
        Log  Checking delta object with distName ${scf_object['distName']}  console=True
        Log  ${scf_object}
        Verify parameters values in SCF object  ${scf_object['distName']}  ${scf_object['parameters']}  ${mode}  ${is_basic}
    END
    Run Keyword If  "${mode}"=="excluded"  Log  All parameters in delta JSON have different values than parameters in SCF  console=${TRUE}
    Run Keyword If  "${mode}"=="included"  Log  All parameters in delta JSON have the same values than parameters in SCF  console=${TRUE}

Verify parameters values in SCF object
    [Documentation]
    ...  KW for simple  check if parameter from given delta object has expected value in SCF text field.
    ...  KW supports parameter as list

    [Arguments]  ${object_dist_name}  ${object_parameters}  ${mode}  ${is_basic}
    FOR  ${parameter}  IN  @{object_parameters}
        Log  ${parameter}
        Log  Checking ${parameter['parameterName']} parameter value in SCF  console=True
        ${is_list}=  Run Keyword And Return Status  Get From List  ${parameter['value']}  0
        Run Keyword If  ${is_list}
        ...  Check List Element  ${object_dist_name}  ${parameter}  ${mode}  ${is_basic}
        ...  ELSE
        ...  Check Single Element  ${object_dist_name}  ${parameter}  ${mode}
    END

Check List Element
    [Arguments]  ${object_dist_name}  ${parameter}  ${mode}  ${is_basic}
	${var_type}=  Evaluate  type(${parameter['value'][0]}).__name__
    Run Keyword If  "${var_type}"!="dict"  Check Simple List Element  ${object_dist_name}  ${parameter}  ${mode}
	...  ELSE  Check List Of Dict Element  ${object_dist_name}  ${parameter}  ${mode}  ${is_basic}


Check List Of Dict Element
    [Arguments]  ${object_dist_name}  ${parameter}  ${mode}  ${is_basic}
	FOR  ${list_element}  IN  @{parameter['value']}
	    Check Each Value For List Of Dict Element  ${list_element}  ${object_dist_name}  ${parameter}  ${mode}  ${is_basic}
    END
Check Each Value For List Of Dict Element
    [Arguments]  ${list_element}  ${object_dist_name}  ${parameter}  ${mode}  ${is_basic}
    FOR  ${value}  IN  @{list_element}
        ${value}=  Get From Dictionary  ${list_element}  ${value}
        ${status}=  Run Keyword And Return Status  Element Text Should Be  ${SCF_XML}  ${value}
        ...  //*[@distName="${object_dist_name}"]/child::*[@name="${parameter['parameterName']}"]/child::*/child::*[@name="${list_element}"]
        ${status}=  Run Keyword If  ${status}==${False} and "${mode}"=="included" and "${is_basic}"=="True"
        ...  Check UlComp Basic Cell List Included  ${SCF_XML}  ${parameter}  ${object_dist_name}
        ...  ELSE  Check UlComp Flexible Cell List Included  ${SCF_XML}  ${parameter}  ${object_dist_name}
        Run Keyword If  "${mode}"=="excluded" and ${status}  Fail  ${parameter['parameterName']} is included in SCF
        Run Keyword If  "${mode}"=="included" and (not ${status})  Fail  ${parameter['parameterName']} is excluded from SCF
    END

Check List Of Dict Element With List
    [Arguments]  ${object_dist_name}  ${parameter}  ${mode}  ${is_basic}  ${list_element}
    FOR  ${element}  IN   @{list_element}
        ${value}=  Get From Dictionary  ${parameter['value'][${index}]}  ${list_element}
        ${status}=  Run Keyword And Return Status  Element Text Should Be  ${SCF_XML}  ${value}
        ...  //*[@distName="${object_dist_name}"]/child::*[@name="${parameter['parameterName']}"]/child::*/child::*[@name="${list_element}"]
        ${status}=  Run Keyword If  ${status}==${False} and "${mode}"=="included" and "${is_basic}"=="True"
        ...  Check UlComp Basic Cell List Included  ${SCF_XML}  ${parameter}  ${object_dist_name}
        ...  ELSE  Check UlComp Flexible Cell List Included  ${SCF_XML}  ${parameter}  ${object_dist_name}
        Run Keyword If  "${mode}"=="excluded" and ${status}  Fail  ${parameter['parameterName']} is included in SCF
        Run Keyword If  "${mode}"=="included" and (not ${status})  Fail  ${parameter['parameterName']} is excluded from SCF
    END
Check UlComp Basic Cell List Included
    [Arguments]  ${scf_xml}  ${parameter}  ${object_dist_name}
    Log  ${parameter['value']}
    ${status_list}=  Create List
    ${index} =  Set Variable  -1
    FOR  ${item}  IN  @{parameter['value']}
        ${index} =  Evaluate  ${index} + 1
        Log  ${item['lnCelId']}
        ${status}=  XML.Evaluate Xpath  ${SCF_XML}
        ...  boolean(//*[@distName="${object_dist_name}"]/*[@name="cellList"]//p[contains(.,'${item['lnCelId']}')])
        Append To List  ${status_list}  ${status}
    END
    ${status_list_set}=  Evaluate  set(${status_list})
    ${status_list_set_length}=  Get Length	${status_list_set}
    ${status}=  Run Keyword If  ${status_list_set_length}==1  Set Variable  ${status_list[0]}
    ${status}=  Run Keyword If  ${status}!=${True}  Set Variable  ${False}  ELSE  Set Variable  ${True}
    [Return]  ${status}

Check UlComp Flexible Cell List Included
    [Arguments]  ${scf_xml}  ${parameter}  ${object_dist_name}
    Log  ${parameter['value']}
    ${status_list}=  Create List
    ${index} =  Set Variable  -1
    FOR  ${item}  IN  @{parameter['value']}
        ${index} =  Evaluate  ${index} + 1
        Log  ${item['lnCelId']}
        ${status}=  XML.Evaluate Xpath  ${SCF_XML}
#        ...  boolean(//*[@distName="${object_dist_name}"]/child::*[@name="${parameter['parameterName']}"]//p[contains(., "${parameter['value']}")])
        ...  boolean(//*[@distName="${object_dist_name}"]/*[@name="measBasedCellConf"]//p[contains(.,'${item['lnCelId']}')])
        Append To List  ${status_list}  ${status}
    END
    ${status_list_set}=  Evaluate  set(${status_list})
    ${status_list_set_length}=  Get Length	${status_list_set}
    ${status}=  Run Keyword If  ${status_list_set_length}==1  Set Variable  ${status_list[0]}
    ${status}=  Run Keyword If  ${status}!=${True}  Set Variable  ${False}  ELSE  Set Variable  ${True}
    [Return]  ${status}

Check Simple List Element
    [Arguments]  ${object_dist_name}  ${parameter}  ${mode}
	FOR  ${list_element}  IN  @{parameter['value']}
        ${status}=  XML.Evaluate Xpath  ${SCF_XML}
        ...  boolean(//*[@distName="${object_dist_name}"]/child::*[@name="${parameter['parameterName']}"]/p[contains(text(), "${list_element}")])
        Run Keyword If  "${mode}"=="excluded" and ${status}  Fail  ${parameter['parameterName']} is included in SCF
        Run Keyword If  "${mode}"=="included" and (not ${status})  Fail  ${parameter['parameterName']} is excluded from SCF
    END

Check Single Element
    [Arguments]  ${object_dist_name}  ${parameter}  ${mode}
    ${status}=  Run Keyword And Return Status  Element Text Should Be
    ...  ${SCF_XML}  ${parameter['value']}  //*[@distName="${object_dist_name}"]/child::*[@name="${parameter['parameterName']}"]
    Run Keyword If  "${mode}"=="excluded" and ${status}  Fail  ${parameter['parameterName']} is included in SCF
    Run Keyword If  "${mode}"=="included" and (not ${status})  Fail  ${parameter['parameterName']} is excluded from SCF

Delta Commissioning Define JSON Path
    [Arguments]  ${delta_file_name}
    ${testsuite_name}=  Fetch From Right
    ...  string=${SUITE_SOURCE}
    ...  marker=/
    ${delta_scf_file}=  Replace String Using Regexp
    ...  string=${SUITE_SOURCE}
    ...  pattern=${testsuite_name}
    ...  replace_with=delta_${BTS_ID}_${delta_file_name}.json
    ${file_status}=  OperatingSystem.File Should Exist
    ...  path=${delta_scf_file}
    ...  msg=${False}
    [Teardown]  Run Keyword If  '${file_status}'=='${False}'  Fail
    [Return]  ${delta_scf_file}

Perform Delta Commissioning
    ${active_file_release}=  Set Variable If  ${cfg.NODES['${BTS_ID}'].trunk_status}  SBTS00  ${cfg.NODES['${BTS_ID}']['active_release']}
    Log  \nBTS Delta commissioning procedure on bts_id node=${BTS_ID} started  console=${TRUE}
    Log  \nSource File = ${DELTA_JSON_FILE}.\nProcedure Parameters: Ignore Errors = ${ignore_errors}.  console=${TRUE}
    Run Keyword And Ignore Error  Wait Sw Update Possible
    ...  bts_ready=True
    ...  readiness_timeout=900
    ...  timeout=1000
    ...  connection=${BTS_ID}
    ${result}  Run Keyword And Continue On Failure  Perform Delta Recommissioning
    ...  delta_file=${DELTA_FOR_RECOMM}
    ...  skip_parameter_relation_errors=${IGNORE_ERRORS}
    ...  should_activate=True
    ...  timeout=${RECOMMISSIONING_TIMEOUT}
    ...  connection=${BTS_ID}
    ${status}  ${response}=  Run Keyword And Ignore Error
    ...  Set Variable  ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}
    Run Keyword If  '${response}' != 'Success'  Log  Recommissioning failed due to  ${response}
    Should Be True  '${response}' == 'Success'
    Log  \nBTS template commissioning procedure on bts_id node=${BTS_ID} finished.  console=${TRUE}
    [Return]  ${status}  ${result}

Check Removed Cell From UlComp
    [Arguments]  ${is_basic}
    [Documentation]
    ...  KW that modifies Delta file which will be checked for Remove mode, when the operation in delta json is "update".
    Log  ${DELETED_LIST['lnCelId']}
    ${cell_removed}=  Set Variable  False
    ${SCF_TO_CHECK_REMOVE}=  Parse xml  ${cfg.test_logs_path}/SCF_START.xml

    ${data_in_comp_conf}=    Run Keyword If  '${is_basic}'=='True'  Get Elements
      ...  ${SCF_TO_CHECK_REMOVE}  (.//managedObject[@class='NOKLTE:ULCOMPBASICCONF']/*[@name='cellList'])[1]/item/p[@name='lnCelId']/text()
    ...    ELSE    Get Elements Texts  ${SCF_TO_CHECK_REMOVE}  .//managedObject[@class='NOKLTE:COMPCONF']/*[@name='measBasedCellConf']/item
    Log  ${data_in_comp_conf}
    ${split_data}=  Create List
    FOR  ${data}  IN  @{data_in_comp_conf}
        ${split_data}=  Split String  ${data}
        ${cell_removed_final}=  Iterating Through Data In Comp Conf  ${split_data}  ${cell_removed}
        ${cell_removed}  Set Variable  ${cell_removed_final}
    END
    Run Keyword If  '${cell_removed_final}' == 'False'  Fail  Cell ${DELETED_LIST['lnCelId']} was not removed from UlCoMP pool.
    Run Keyword If  '${cell_removed_final}' == 'True'
    ...  Log to console  Cell ${DELETED_LIST['lnCelId']} was successfully removed from UlCoMP pool.  console=True
