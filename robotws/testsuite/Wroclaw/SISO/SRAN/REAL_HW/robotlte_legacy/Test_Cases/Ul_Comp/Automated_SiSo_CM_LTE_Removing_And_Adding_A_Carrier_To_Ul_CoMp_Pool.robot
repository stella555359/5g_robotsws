*** Settings ***
Documentation   The purpose of this test case is to verify that removing and adding Ul CoMP carrier does not have affect on TPut.
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak



#Resource    ../../../Resources/SiSo_L3_call.robot
Resource    ./Ul_Comp_common.robot

*** Variables ***
${CARRIER_COMP_NUMBER}=  0   #number of comp object which is going to have cell removed
${CALL_IN_UL_COMP}  ${True}
${SINGLE_NODE}    ${False}    #set in robot suite to TRUE in order to test only 1 node on testline. Need to add additional
# variable  eg.  ${SINGLE_NODE_NUMBER}    1404
*** Keywords ***

Removing And Adding Carrier In UL CoMP Pools
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Removing And Adding Carrier to UL CoMP Pools and Checking Call for each cell after each step.
    ...  There must be already created Ul CoMP on test line.
    ...  Already configured Ul Comp on the testline with at least 3 cells:
    ...  For Basic Ul CoMP at least 1 ULCOMPBASICCONF Objects in MRBTS-x/LNBTS-x/
    ...  For Fixed Ul CoMP at least 2 ULCOMP Objects in MRBTS-x/LNBTS-x/
    ...  For Flexible Ul CoMP at least 3 cells in MRBTS-x/LNBTS-x/COMPCONF
    ...
    ...  There must be at least 2 ULComp Pools.
    ...  *****************
    ...  History of change
    ...  *****************
    ...
  Common Test Setup
  Logging With Timestamp
  ...  message=Removing And Adding Carrier In UL CoMP Pools
  ...  style=ONGOING
  Set Tags	CA-CM  AUTHOR-szymon.przybylak@nokia.com  MAINTAINER-szymon.przybylak@nokia.com
  ...		    GROUP_IN_CHARGE- MN RAN Pz 4 WRO 7  PHASE-CRT
  Removing And Adding Carrier In UL CoMP Steps
  [Teardown]  Run Keywords
  ...  Force Recommissioning With Current Branch On Every Node
  ...  AND  Common Test Teardown

Removing And Adding Carrier In UL CoMP Steps
    FOR  ${node}  IN  @{cfg.active_bts_list}
        Run Keyword If    ${SINGLE_NODE}    Continue For Loop If    '${node}'!='${SINGLE_NODE_NUMBER}'
        Precondition UlComp  node=${node}
#        Get Parameters  dist_name=dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMPBASICCONF-${CARRIER_COMP_NUMBER}  connection=${node}
    END
    FOR  ${node}  IN  @{cfg.active_bts_list}
        Run Keyword If    ${SINGLE_NODE}    Continue For Loop If    '${node}'!='${SINGLE_NODE_NUMBER}'
        Step 1: Call to all cells in Ul CoMP Before Carrier Is Removed
        ${ul_comp_type}  ${is_basic}=  Step 2: Remove Carrier In Ul Comp Pool  node=${node}
        Step 3: Call to remaining cells in pool without one carrier  node=${node}  is_basic=${is_basic}
        Step 4: Add Carrier In Ul Comp Pool  node=${node}  ul_comp_type=${ul_comp_type}  is_basic=${is_basic}
        Step 5: Call to All Cells in pool
    END

Step 1: Call to all cells in Ul CoMP Before Carrier Is Removed
    Log To Console  ${\n}=== Step 1: Perform call  console=True
    Set Test Variable  ${ALL_SELECTED_CELLS}  ${UL_COMP_LIST}
    Set Test Variable  ${SELECTED_CELLS}  ${ALL_SELECTED_CELLS}
    Run Keyword If  ${CALL_IN_UL_COMP}  SiSo L3 Call
    ...  ELSE    Log To Console    Call skipped    console=True

Step 2: Remove Carrier In Ul Comp Pool
    [Arguments]  ${node}
    Log To Console  === Step 2: Remove Carrier In Ul Comp Pool  console=True
    Get Current SCF File  ${cfg.test_logs_path}  SCF_TO_COMPARE.xml  connection=${node}
    ${SCF_XML}=  Parse xml  ${cfg.test_logs_path}/SCF_TO_COMPARE.xml
    Set Test Variable  ${SCF_XML}
    Load Scf  file_path=${cfg.NODES['${node}']['scf_file_path']}
    ${is_basic}=  Is Object In Scf  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMPBASICCONF-${CARRIER_COMP_NUMBER}
    ${ul_comp_type}=  Get Value From Scf  dist_name=MRBTS-${node}/LNBTS-${node}  p_name=actCoMp
    Change Carrier In Ul Comp Pool  mode=Remove  ul_comp_type=${ul_comp_type}  is_basic=${is_basic}  node=${node}
    [Return]  ${ul_comp_type}  ${is_basic}

Step 3: Call to remaining cells in pool without one carrier
    [Arguments]  ${node}  ${is_basic}
    Log To Console  === Step 3: Call to remaining cells in pool without one carrier  console=True
    Check Remaining Cells in Pool And Set Them For L3Call  node=${node}  is_basic=${is_basic}
    Run Keyword If  ${CALL_IN_UL_COMP}  SiSo L3 Call
    ...  ELSE    Log To Console    Call skipped    console=True

Step 4: Add Carrier In Ul Comp Pool
    [Arguments]  ${node}  ${ul_comp_type}  ${is_basic}
    Log To Console  === Step 4: Add Carrier In Ul Comp Pool  console=True
    Change Carrier In Ul Comp Pool  mode=Add  ul_comp_type=${ul_comp_type}  is_basic=${is_basic}  node=${node}

Step 5: Call to All Cells in pool
    Log To Console  ${\n}=== Step 5: Perform call  console=True
    Set Test Variable  ${ALL_SELECTED_CELLS}  ${UL_COMP_LIST}
    Set Test Variable  ${SELECTED_CELLS}  ${ALL_SELECTED_CELLS}
    Run Keyword If  ${CALL_IN_UL_COMP}  SiSo L3 Call
    ...  ELSE    Log To Console    Call skipped    console=True

Change Carrier In Ul Comp Pool
    [Arguments]  ${mode}  ${ul_comp_type}  ${is_basic}  ${node}
    Log to console  ${\n}${mode} Carrier In Ul Comp started  console=True

    Run Keyword If  '${mode}'=='Remove' and '${ul_comp_type}'=='fixedULCoMp' and '${is_basic}'=='False'
    ...  Remove Carrier From Fixed Ul Comp  mode=${mode}  node=${node}
    Run Keyword If  '${mode}'=='Remove' and '${ul_comp_type}'=='measBasedCoMp' and '${is_basic}'=='False'  Flexible Carrier Removing  ${node}
    Run Keyword If  '${mode}'=='Remove' and '${is_basic}'=='True'  Basic Carrier Removing  ${node}
    Run Keyword If  '${mode}'=='Remove'  Save Scf  file_path=${cfg.test_logs_path}/SCF_With_${mode}_Carrier.xml
    Run Keyword If  '${mode}'=='Remove'  Calculate Delta Scf
    ...  target_scf_path=${cfg.test_logs_path}/SCF_With_${mode}_Carrier.xml
    ...  actual_scf_path=${cfg.NODES['${node}']['scf_file_path']}
    ...  delta_scf_path=${cfg.test_logs_path}/delta_${mode}.json
    ...  oam_type=COAM
    Run Keyword If  '${mode}'=='Add'  Calculate Delta Scf
    ...  target_scf_path=${cfg.NODES['${node}']['scf_file_path']}
    ...  actual_scf_path=${cfg.test_logs_path}/SCF_With_Remove_Carrier.xml   delta_scf_path=${cfg.test_logs_path}/delta_${mode}.json  oam_type=COAM

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

Basic Carrier Removing
    [Arguments]  ${node}
    ${ulcompbasicconf_atributes}=  Get Elements  ${SCF_XML}  .//managedObject[@class='NOKLTE:ULCOMPBASICCONF']/*[@name='cellList']/item/p/@name
    ${ulcompbasicconf_atributes}=  Evaluate  set(${ulcompbasicconf_atributes})
    Log  ${ulcompbasicconf_atributes}
    ${ulcompbasicconf_cells_first_pool}=  Get Elements
    ...  ${SCF_XML}  (.//managedObject[@class='NOKLTE:ULCOMPBASICCONF']/*[@name='cellList'])[1]/item/p[@name='lnCelId']/text()
    ${ulcompbasicconf_parameters_list}=  Create List
    FOR  ${c}  IN  @{ulcompbasicconf_cells_first_pool}
        ${value}=  Get Cell Atributes In Basic Ul Comp  ${c}  ${ulcompbasicconf_atributes}  ${SCF_XML}
        Append To List  ${ulcompbasicconf_parameters_list}  ${value}
    END
    ${DELETED_POOL_LIST}=  Get From List  ${ulcompbasicconf_parameters_list}  -1
    Log  ${DELETED_POOL_LIST}
    Set Test Variable  ${DELETED_LIST}  ${DELETED_POOL_LIST}
    ${remaining_pool_list}=  Create List
    FOR  ${item}  IN  ${ulcompbasicconf_parameters_list}
        Run Keyword IF  ${item} != ${DELETED_POOL_LIST}  Append To List  ${remaining_pool_list}  ${item}
    END
    Remove List From Scf  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMPBASICCONF-0  list_name=cellList
    Remove From List  ${ulcompbasicconf_parameters_list}  -1
    Add List To Scf  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMPBASICCONF-0  list_name=cellList
    ${values_dict}=  Create Dictionary
    FOR  ${value}  IN  @{ulcompbasicconf_parameters_list}
        Add Item To List  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMPBASICCONF-0  list_name=cellList  elements=${value}
    END
Get Cell Atributes In Basic Ul Comp
    [Arguments]  ${cell_id}  ${atributes}  ${scf}
    ${dict}=  Create Dictionary
    FOR  ${a}  IN  @{atributes}
        ${value}=  Get Element
        ...  ${scf}  .//managedObject[@class='NOKLTE:ULCOMPBASICCONF']/*[@name='cellList']/item/p[.="${cell_id}"]/../p[@name='${a}']/text()
        Set To Dictionary  ${dict}  ${a}  ${value}
    END
    [Return]  ${dict}

Flexible Carrier Removing
    [Arguments]  ${node}
#    ${flexible_carrier_list}=  Get Elements  ${SCF_XML}  .//managedObject[@class='NOKLTE:COMPCONF'][1]/list[1]
#    ${data_from_ulcomp_list}  Create List
#    @{data_from_ulcomp_list}  Get All Values From Scf  dist_name=MRBTS-${node}/LNBTS-${node}/COMPCONF-0  list_name=measBasedCellConf

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

Remove Carrier From Fixed Ul Comp
    [Arguments]  ${mode}  ${node}
    ${carrier_list}=  Create List
    ${carrier_list}=  Get Elements  ${SCF_XML}  .//managedObject[@class='NOKLTE:ULCOMP'][1]/list[1]

#    ${data_from_ulcomp_list}  Create List
    @{data_from_ulcomp_list}  Get All Values From Scf  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMP-0  list_name=ulCoMpCellList
    Remove From List	 ${data_from_ulcomp_list}  -1
    Log  ${data_from_ulcomp_list}
    Remove List From Scf  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMP-0  list_name=ulCoMpCellList
    Add List To Scf  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMP-0  list_name=ulCoMpCellList
    Add Elements To List  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMP-0  list_name=ulCoMpCellList  elements=${data_from_ulcomp_list}
    Save Scf  file_path=${cfg.test_logs_path}/SCF_With_${mode}_Carrier.xml
    Run Keyword If  '${mode}'=='Remove'  Calculate Delta Scf
    ...  target_scf_path=${cfg.test_logs_path}/SCF_With_Remove_Carrier.xml
    ...  actual_scf_path=${cfg.NODES['${node}']['scf_file_path']}
    ...  delta_scf_path=${cfg.test_logs_path}/delta_${mode}.json  oam_type=COAM
    ${json}=  OperatingSystem.Get File  ${cfg.test_logs_path}/delta_${mode}.json
    Set Test Variable  ${DELTA_FOR_RECOMM}  ${json}
    ${json}=  Evaluate  json.loads('''${json}''')  json
    Set Test Variable  ${DELTA_JSON_FILE}  ${json}
    Log To Console  ${\n}Delta Recommissioning started. Mode: ${mode}
    Perform Delta Recommissioning  delta_file=${cfg.test_logs_path}/delta_${mode}.json  connection=${node}
    Verify BTS State  ${node}  600
#    ${ul_comp_type}=  Get Value From Scf  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMP-${CARRIER_COMP_NUMBER}  list_name=ulCoMpCellList
#     ${mhm}=  Get Value From Scf  dist_name=MRBTS-${node}/LNBTS-${node}/ULCOMPBASICCONF-0  p_name=cellList
#    Change Carrier In Ul Comp Pool  mode=Remove  ul_comp_type=${ul_comp_type}  is_basic=${is_basic}  node=${node}


