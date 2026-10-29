*** Settings ***
Documentation   The purpose of this test case is to verify that removing and adding Ul CoMP pools does not have affect on TPut.
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak


#Resource    ../../../Resources/SiSo_L3_call.robot
Resource    ./Ul_Comp_common.robot

*** Variables ***
${COMP_NUMBER}=  1   #number of comp object which is going to be removed in the test - use the highest number possible
${CALL_IN_UL_COMP}  ${True}
${SINGLE_NODE}    ${False}    #set in robot suite to TRUE in order to test only 1 node on testline. Need to add additional
# variable  eg.  ${SINGLE_NODE_NUMBER}    1404
*** Keywords ***

Removing And Adding UL CoMP Pools
  [Documentation]
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  Removing And Adding UL CoMP Pools and Checking Call for each cell after each step.
  ...  There must be already created Ul CoMP on test line.
  ...  Already configured Ul Comp on the testline:
  ...  For Basic Ul CoMP at least 2 ULCOMPBASICCONF Objects in MRBTS-x/LNBTS-x/
  ...  For Fixed Ul CoMP at least 2 ULCOMP Objects in MRBTS-x/LNBTS-x/
  ...  For Flexible Ul CoMP at least 3 cells in MRBTS-x/LNBTS-x/COMPCONF
  ...
  ...  There must be at least 2 ULComp Pools.
  ...  *****************
  ...  History of change
  ...  *****************
  Common Test Setup
  Logging With Timestamp
  ...  message=Removing And Adding UL CoMP Pools
  ...  style=ONGOING
  Set Tags	CA-CM  AUTHOR-szymon.przybylak@nokia.com  MAINTAINER-szymon.przybylak@nokia.com
  ...		    GROUP_IN_CHARGE- MN RAN Pz 4 WRO 7  PHASE-CRT
  Removing And Adding UL CoMP Pools Steps
  [Teardown]  Run Keywords
  ...  Force Recommissioning With Current Branch On Every Node
  ...  AND  Common Test Teardown


Removing And Adding UL CoMP Pools Steps
    FOR  ${node}  IN  @{cfg.active_bts_list}
        Run Keyword If    ${SINGLE_NODE}    Continue For Loop If    '${node}'!='${SINGLE_NODE_NUMBER}'
        Precondition UlComp  node=${node}
    END
    FOR  ${node}  IN  @{cfg.active_bts_list}
        Run Keyword If    ${SINGLE_NODE}    Continue For Loop If    '${node}'!='${SINGLE_NODE_NUMBER}'
        Step 1: Call to all cells in Ul CoMP
        ${ul_comp_type}  ${is_basic}=  Step 2: Remove Ul Comp Pool  node=${node}
        Step 3: Call to remaining cells in pool  node=${node}  is_basic=${is_basic}
        Step 4: Add Ul Comp Pool  node=${node}  ul_comp_type=${ul_comp_type}  is_basic=${is_basic}
        Step 5: Call to all cells after added ul comp pool
    END

Step 1: Call to all cells in Ul CoMP
    Log To Console  ${\n}=== Step 1: Perform call  console=True
    Set Test Variable  ${ALL_SELECTED_CELLS}  ${UL_COMP_LIST}
    Set Test Variable  ${SELECTED_CELLS}  ${ALL_SELECTED_CELLS}
    Run Keyword If  ${CALL_IN_UL_COMP}  SiSo L3 Call
    ...  ELSE    Log To Console    Call skipped    console=True

Step 2: Remove Ul Comp Pool
    [Arguments]  ${node}
    Log To Console  === Step 2: Remove Ul Comp Pool  console=True
    Get Current SCF File  ${cfg.test_logs_path}  SCF_TO_COMPARE.xml  connection=${node}
    ${SCF_XML}=  Parse xml  ${cfg.test_logs_path}/SCF_TO_COMPARE.xml
    Set Test Variable  ${SCF_XML}
    Load Scf  file_path=${cfg.NODES['${node}']['scf_file_path']}
    ${is_basic}=  Is Object In Scf  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMPBASICCONF-0
    ${ul_comp_type}=  Get Value From Scf  dist_name=MRBTS-${node}/LNBTS-${node}  p_name=actCoMp
    Change Ul Comp Pool  mode=Remove  ul_comp_type=${ul_comp_type}  is_basic=${is_basic}  node=${node}
    [Return]  ${ul_comp_type}  ${is_basic}

Step 3: Call to remaining cells in pool
    [Arguments]  ${node}  ${is_basic}
    Log To Console  === Step 3: Call to remaining cells in pool  console=True
    Check Remaining Cells in Pool And Set Them For L3Call  node=${node}  is_basic=${is_basic}
    Run Keyword If  ${CALL_IN_UL_COMP}  SiSo L3 Call
    ...  ELSE    Log To Console    Call skipped    console=True

Step 4: Add Ul Comp Pool
    [Arguments]  ${node}  ${ul_comp_type}  ${is_basic}
    Log To Console  === Step 4: Add Ul Comp Pool  console=True
    Change Ul Comp Pool  mode=Add  ul_comp_type=${ul_comp_type}  is_basic=${is_basic}  node=${node}

Step 5: Call to all cells after added ul comp pool
    Log To Console  ==== Step 5: Call to all cells in ul comp pool  console=True
    Set Test Variable  ${SELECTED_CELLS}  ${ALL_SELECTED_CELLS}
    Run Keyword If  ${CALL_IN_UL_COMP}  SiSo L3 Call
    ...  ELSE    Log To Console    Call skipped    console=True

Change Ul Comp Pool
    [Arguments]  ${mode}  ${ul_comp_type}  ${is_basic}  ${node}
    Log to console  ${\n}${mode} Ul Comp Pool started  console=True

    Run Keyword If  '${mode}'=='Remove' and '${ul_comp_type}'=='fixedULCoMp' and '${is_basic}'=='False'
    ...  Remove Mo With Descendant Mos  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMP-${COMP_NUMBER}
    Run Keyword If  '${mode}'=='Remove' and '${ul_comp_type}'=='measBasedCoMp' and '${is_basic}'=='False'
    ...  Flexible Ul Comp Pool Removing  ${node}
    Run Keyword If  '${mode}'=='Remove' and '${is_basic}'=='True'
    ...  Remove Mo With Descendant Mos  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMPBASICCONF-${COMP_NUMBER}
    Run Keyword If  '${mode}'=='Remove'  Save Scf  file_path=${cfg.test_logs_path}/SCF_With_${mode}_Comp.xml
    Run Keyword If  '${mode}'=='Remove'  Calculate Delta Scf
    ...  target_scf_path=${cfg.test_logs_path}/SCF_With_${mode}_Comp.xml
    ...  actual_scf_path=${cfg.NODES['${node}']['scf_file_path']}
    ...  delta_scf_path=${cfg.test_logs_path}/delta_${mode}.json  oam_type=COAM
    Run Keyword If  '${mode}'=='Add'  Calculate Delta Scf
    ...  target_scf_path=${cfg.NODES['${node}']['scf_file_path']}
    ...  actual_scf_path=${cfg.test_logs_path}/SCF_With_Remove_Comp.xml
    ...  delta_scf_path=${cfg.test_logs_path}/delta_${mode}.json  oam_type=COAM

    ${json}=  OperatingSystem.Get File  ${cfg.test_logs_path}/delta_${mode}.json
    Set Test Variable  ${DELTA_FOR_RECOMM}  ${json}
    ${json}=  Evaluate  json.loads('''${json}''')  json
    Set Test Variable  ${DELTA_JSON_FILE}  ${json}
    Log To Console  ${\n}Delta Recommissioning started. Mode: ${mode}
    Perform Delta Recommissioning  delta_file=${cfg.test_logs_path}/delta_${mode}.json  connection=${node}
    Verify BTS State  ${node}  600
    Run Keyword If  '${mode}'=='Remove'  Validate Delta Against SCF  mode=excluded  is_basic=${is_basic}
    Run Keyword If  '${mode}'=='Add'  Validate Delta Against SCF  mode=included  is_basic=${is_basic}
    Log To Console  ${\n} Delta Recommissioning finished.

Flexible Ul Comp Pool Removing
    [Arguments]  ${node}
    ${compconf_atributes}=  Get Elements  ${SCF_XML}  .//managedObject[@class='NOKLTE:COMPCONF']/*[@name='measBasedCellConf']/item/p/@name
    ${compconf_atributes}=  Evaluate  set(${compconf_atributes})
    ${compconf_cells}=  Get Elements
    ...  ${SCF_XML}  .//managedObject[@class='NOKLTE:COMPCONF']/*[@name='measBasedCellConf']/item/p[@name='lnCelId']/text()
    ${compconf_parameters_list}=  Create List
    FOR  ${c}  IN  @{compconf_cells}
        ${value}=  Get Cell Atributes  ${c}  ${compconf_atributes}  ${SCF_XML}
        Append To List  ${compconf_parameters_list}  ${value}
    END
    ${DELETED_POOL_LIST}=  Get From List  ${compconf_parameters_list}  -1
    Log  ${DELETED_POOL_LIST}
    Set Test Variable  ${DELETED_LIST}  ${DELETED_POOL_LIST}
    ${remaining_pool_list}=  Create List
    FOR  ${item}  IN  ${compconf_parameters_list}
        Run Keyword IF  ${item} != ${DELETED_POOL_LIST}  Append To List  ${remaining_pool_list}  ${item}
    END
    Remove List From Scf  dist_name=MRBTS-${node}/LNBTS-${node}/COMPCONF-0  list_name=measBasedCellConf
    Remove From List  ${compconf_parameters_list}  -1
    Add List To Scf  dist_name=MRBTS-${node}/LNBTS-${node}/COMPCONF-0  list_name=measBasedCellConf
    ${values_dict}=  Create Dictionary
    FOR  ${value}  IN  @{compconf_parameters_list}
        Add Item To List  dist_name=MRBTS-${node}/LNBTS-${node}/COMPCONF-0  list_name=measBasedCellConf  elements=${value}
    END

Get Cell Atributes
    [Arguments]  ${cell_id}  ${atributes}  ${scf}
    ${dict}=  Create Dictionary
    FOR  ${a}  IN  @{atributes}
        ${value}=  Get Element
        ...  ${scf}  .//managedObject[@class='NOKLTE:COMPCONF']/*[@name='measBasedCellConf']/item/p[.="${cell_id}"]/../p[@name='${a}']/text()
        Set To Dictionary  ${dict}  ${a}  ${value}
    END
    [Return]  ${dict}

Validate Json
    [Arguments]  ${mode}
    ${json}=  OperatingSystem.Get File  ${cfg.test_logs_path}/delta_${mode}.json
    Set Test Variable  ${DELTA_FOR_RECOMM}  ${json}
    ${json}=  Evaluate  json.loads('''${json}''')  json
    Set Test Variable  ${DELTA_JSON_FILE}  ${json}

Validate Delta Against SCF file?
    [Documentation]
    ...  KW Validates Delta against SCF file depending on ${type}
    ...  ${mode} accepts 'excluded' or 'included' in case of Delta file
    [Arguments]  ${type}
    [Timeout]  15 min
    Log to console  Validate Delta Against SCF  console=${TRUE}
    FOR  ${scf_object}  IN  @{DELTA_JSON_FILE}
        Log  Checking delta object with distName ${scf_object['distName']}  console=True
        Verify parameters values in SCF object  ${scf_object['distName']}  ${scf_object['parameters']}  ${type}  ${is_basic}
    END
    Run Keyword If  "${type}"=="excluded"  Log  All parameters in delta JSON have different values than parameters in SCF  console=${TRUE}
    Run Keyword If  "${type}"=="included"  Log  All parameters in delta JSON have the same values as parameters in SCF  console=${TRUE}

Iterating Through Data In Comp Conf
    [Arguments]  ${split_data}  ${cell_removed}
    FOR  ${item}  IN  @{split_data}
         ${old_value_cell_removed}=  Check If Cell Was Removed  ${item}  ${cell_removed}
         ${cell_removed}  Set Variable  ${old_value_cell_removed}
    END
    [Return]  ${cell_removed}

Check If Cell Was Removed
    [Arguments]  ${item}  ${cell_removed}
    FOR  ${x}  IN  ${item}
        ${old_value}=  Set Variable  ${cell_removed}
        ${cell_removed}  Set Variable If  '${x}' == '${DELETED_LIST['lnCelId']}'  True  ${old_value}
        ${old_value}=  Set Variable  ${old_value}
    END
    [Return]  ${cell_removed}
