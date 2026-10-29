*** Settings ***

Documentation
...    Maintainer:    Author

Library    Collections
Library    Process
Library    String
Library    XML    use_lxml=true
Library    OperatingSystem

Resource    ./lg_hr_keywords_new.robot

Resource    ./lg_hr_switch.robot



*** Keywords ***
Info Model Get Physical Port List For FR Serial Number
    [Arguments]  ${fr_serial_number}   ${alias}=default
    ${path_rmod_under_test}=   Info Model Create Rmod Path For Fr Serial Number  ${fr_serial_number}   alias=${alias}
    ${cablink_list}=  Info Model Create Cablnk List For SourceDistName List  ${path_rmod_under_test}   alias=${alias}
    ${out_sm_port_list}=   Info Model Create SM Ports List For Cablnks    ${cablink_list}    alias=${alias}
    [Return]  ${out_sm_port_list}

Info Model Create Rmod Path For Fr Serial Number
    [Arguments]  ${fr_serial_number}    ${state_to_be_check}=Online    ${timeout}=10    ${alias}=default
    @{out_dist_name_list}=   Create List
    FOR  ${out_index}   IN   @{fr_serial_number}
        ${path_rmod_under_test}=   admin_im.Query Infomodel
        ...  query=get object //RMOD_L-* is [serialNumber="${out_index}",stateInfo.availabilityStatus="${state_to_be_check}"]
        ...  timeout=${timeout}   alias=${alias}
        Append To List   ${out_dist_name_list}   ${path_rmod_under_test.dist_name}
    END
    [Return]  ${out_dist_name_list}


Info Model Create Cablnk List For SourceDistName List
    [Arguments]  ${path_sourceDisName}  ${cablinkType}=regex"RP3_01Link|CPRILink"  ${cablink_working_state}=Online   ${timeout}=10   ${alias}=default
    ${count_path}=  Get Length  ${path_sourceDisName}
    @{cablink}=   Create List
    @{cablink_list}=  Create List
    @{note_path}=  Create List
    FOR  ${out_index}   IN RANGE   ${count_path}
        ${disc_name_path}=    Catenate  SEPARATOR=  @{path_sourceDisName}[${out_index}]  .*
            ${object_1}=  Set Variable  //CABLNK_L-* is [cablinkType=${cablinkType},stateInfo.availabilityStatus=${cablink_working_state}
            ${object_2}=  Set Variable  ,sourceDistName=regex"${disc_name_path}"]
            ${sum_object}=  Set Variable  ${object_1}${object_2}

        @{cablink}=  admin_im.Query Infomodel
    ...  query=get list ${sum_object}
    ...  timeout=${timeout}   alias=${alias}
        ${cablink_list}=   Add Dist_Name from Cablnk List   ${cablink}
        Append to list  ${note_path}    ${cablink_list}
    END
    ${out_cablnk_list}=  Combine Lists  @{note_path}
    [Return]  ${out_cablnk_list}


Add Dist_Name from Cablnk List
    [Arguments]  ${out_cablink}
    @{out_list}=  Create List
    FOR   ${out_index}  IN  @{out_cablink}
      Append To List    ${out_list}     ${out_index.dist_name}
    END
    [Return]  ${out_list}

Info Model Get Destination Physical Port For Cablnk Path Node
    [Arguments]  ${cablnk_path}    ${destinationPhysicalPortNo}=destinationPhysicalPortNo    ${timeout}=10    ${alias}=default
    ${sm_port}=  admin_im.Query Infomodel  query=get object ${cablnk_path}    timeout=${timeout}    alias=${alias}
    [Return]   ${sm_port.destinationPhysicalPortNo}

Info Model Create SM Ports List For Cablnks
    [Arguments]  ${cablnk_list}    ${timeout}=10    ${alias}=default
    @{out_sm_port_list}=   create list
    FOR  ${out_index}  IN   @{cablnk_list}
       ${physcial_port}=    Info Model Get Destination Physical Port For Cablnk Path Node    cablnk_path=${out_index}    alias=${alias}
       append to list     ${out_sm_port_list}    ${physcial_port}
    END
    [Return]  ${out_sm_port_list}

Info Model Cell Count in Specific State Should Be
    [Arguments]  ${state_1}  ${state_2}    ${expected_cell_count}    ${scfc_file_path}    ${fr_serial_number_list}    ${timeout}=5   ${alias}=default
    ${lcrId_list}=   SCFC Create LcrId List For FR Serial Numbers List    ${scfc_file_path}    ${fr_serial_number_list}
    @{out_working_cell_list}=  Create List
    FOR    ${cell}    IN    @{lcrId_list}
        ${state}  ${value} =   run keyword and ignore error  admin_im.Query Infomodel
        ...  query=//LNBTS_M-1/CELL_M-${cell} is [stateInfo.availabilityStatus=${state_1},stateInfo.operationalState=${state_2}]
        ...  timeout=${timeout}    alias=${alias}
        Run Keyword If   '${state}' == 'PASS'   Append To List    ${out_working_cell_list}     ${cell}
    END
    Log   Info Model Cell are in state ${state_1} and ${state_2}: ${out_working_cell_list}    console=yes
    ${working_cell_count}=    Get Length    ${out_working_cell_list}
    ${out_expected_cell_count}=  evaluate    ${OUT_CELL_COUNT_FOR_CONFIGURATION}-1
    Should Be Equal As Integers   ${out_expected_cell_count}    ${working_cell_count}
    [Return]   ${out_working_cell_list}

Info Model Cell Count in Specific State Should Be Full
    [Arguments]  ${state_1}  ${state_2}   ${expected_cell_count}    ${scfc_file_path}    ${fr_serial_number_list}    ${timeout}=5   ${alias}=default
    ${lcrId_list}=   SCFC Create LcrId List For FR Serial Numbers List    ${scfc_file_path}    ${fr_serial_number_list}
    @{out_working_cell_list}=  Create List
    FOR    ${cell}    IN    @{lcrId_list}
        ${state}  ${value} =   run keyword and ignore error  admin_im.query infomodel
        ...  query=//LNBTS_M-1/CELL_M-${cell} is [stateInfo.availabilityStatus=${state_1},stateInfo.operationalState=${state_2}]
        ...  timeout=${timeout}
        ...  alias=${alias}
        Run Keyword If   '${state}' == 'PASS'   Append To List    ${out_working_cell_list}     ${cell}
    END
    Log   Info Model Cell are in state ${state_1} and ${state_2}: ${out_working_cell_list}    console=yes
    ${working_cell_count}=    Get Length    ${out_working_cell_list}
    Should Be Equal As Integers   ${expected_cell_count}    ${working_cell_count}
    [Return]   ${out_working_cell_list}

#
Info Model Check Resoning Status Of Disabled Cell
  [Arguments]  ${reasoningStatus}  ${fault_count}=None  ${availabilityStatus}=Failed  ${operationalState}=Disabled  ${timeout}=10  ${alias}=default
   ${cell_list}=    admin_im.Query Infomodel
   ...  query=get list //CELL_M-* is [stateInfo.operationalState=Disabled,stateInfo.availabilityStatus=Failed]  timeout=${timeout}    alias=${alias}
   @{counter_list}=    Create List
   FOR    ${cell}    IN    @{cell_list}
       ${status}=    Run Keyword And Return Status  Should Be Equal As Strings    ${cell.stateInfo.reasoningStatus[0]}    ${reasoningStatus}
       Run Keyword If    ${status}==True    Append To List    ${counter_list}    1
   END
   ${counter_items}=    Get Length    ${counter_list}



Info Model Check Cablnk Reasoning State
   [Arguments]     ${cablnk_list}    ${state_to_be_checked}    ${alias}=default
   FOR    ${cablnk}    IN    @{cablnk_list}
     ${cablnk_object}=   admin_im.query infomodel  query=get object ${cablnk}    alias=${alias}
     ${reasoningStatus}=  set variable  ${cablnk_object.stateInfo.reasoningStatus[0]}
     should be equal as strings    ${reasoningStatus}   ${state_to_be_checked}
   END

Info Model Get Disabled Cablnk And Check Reasoning Status
   [Arguments]  ${state_to_be_checked}  ${source_dist_name}  ${timeout}=180   ${alias}=default
   ${object_1}=  Set Variable  //CABLNK_L-* is [sourceDistName=regex"${source_dist_name[0]}/CONNECTOR_L-\\d+",cablinkType=regex"RP3_01Link|CPRILink" ,
   ${object_2}=  Set Variable  linkMode.data=True,stateInfo.operationalState=Disabled,stateInfo.availabilityStatus=NotInstalled]
   ${sum_object}=  Set Variable  ${object_1}${object_2}
   @{cablnk_list}=   admin_im.query infomodel
    ...  query=get list ${sum_object}
    ...  timeout=${timeout}    alias=${alias}
   FOR    ${cablnk_object}    IN    @{cablnk_list}
     ${reasoningStatus}=  set variable  ${cablnk_object.stateInfo.reasoningStatus[0]}
     should be equal as strings    ${reasoningStatus}   ${state_to_be_checked}
   END
   [Return]   ${cablnk_list}

Info Model Check State Of RMOD_L-1
    [Arguments]  ${RMOD_name}=RMOD_L-1   ${proceduralState}=fromSCF  ${availabilityStatus}=NotInstalled  ${timeout}=10   ${alias}=default
    [Documentation]  This keyword check if RMOD_L-* is detected from SCFC file and grey out.
    admin_im.Query Infomodel  //${RMOD_name} is [stateInfo.proceduralState=${proceduralState},stateInfo.availabilityStatus=${availabilityStatus}]
    ...  timeout=${timeout}    alias=${alias}

Info Model Remove HWF
    ${hwf_object}=  admin_im.Query Infomodel    query=get object //HWF_L-1    timeout=10
    ${Request ID}=  Execute Infomodel Operation   ${hwf_object.dist_name}   removeAndStopCreation

Info Model Check Count Of Connected Links
  [Arguments]  ${source_dist_name_list}  ${count_of_connected_optical_fibers}  ${timeout}=180    ${alias}=default
  FOR  ${out_index}  IN  @{source_dist_name_list}
  ${object_1}=  Set Variable  //CABLNK_L-* is [sourceDistName=regex"${out_index}/CONNECTOR_L-\\d+",cablinkType=regex"RP3_01Link|CPRILink" ,
  ${object_2}=  Set Variable  linkMode.data=True,stateInfo.availabilityStatus=Online] = ${count_of_connected_optical_fibers}
  ${sum_object}=  Set Variable  ${object_1}${object_2}
  admin_im.Query Infomodel
  ...  query=count ${sum_object}
  ...  timeout=${timeout}    alias=${alias}
  END

Info Model Get Cablnk Path For Data And Config Link
    [Arguments]  ${source_dist_name_list}  ${timeout}=120    ${alias}=default
    @{out_cablnk_list}=   create list
    FOR  ${out_index}  IN   @{source_dist_name_list}
      ${object_1}=  Set Variable  //CABLNK_L-* is [sourceDistName=regex"${out_index}/CONNECTOR_L-\\d+",cablinkType=regex"RP3_01Link|CPRILink" ,
      ${object_2}=  Set Variable  linkMode.data=True,linkMode.configuration=True,linkMode.synchronization=True,stateInfo.availabilityStatus=Online]
      ${sum_object}=  Set Variable  ${object_1}${object_2}
      ${out_cablnk}=  admin_im.Query Infomodel  query=get object ${sum_object}
       ...  timeout=${timeout}    alias=${alias}
       Append To List    ${out_cablnk_list}    ${out_cablnk.dist_name}
    END
    [Return]  ${out_cablnk_list}

Info Model Check Led State For Optical Link
  [Arguments]   ${cablnk_destinationPhysicalPortNo}    ${led_state_to_be_check}   ${timeout}=10     ${alias}=default
  FOR    ${sm_port}    IN    @{cablnk_destinationPhysicalPortNo}
    ${destinationPhysicalPortNo}=    Evaluate  ${sm_port} + 1
    ${led_object}=  admin_im.Query Infomodel
    ...  query=get object //SMOD_L-1/LED_L-* is [ledLabel=FctOpt${destinationPhysicalPortNo},ledState=${led_state_to_be_check}]
    ...  timeout=${timeout}    alias=${alias}
    Log  Port ${led_object.ledLabel} on SM changed color to ${led_object.ledState}    console=yes
  END

Info Model Get Cablnk Path List For Connected Links
    [Arguments]  ${source_dist_name_list}  ${timeout}=10    ${alias}=default
    @{out_cablnk_list}=   create list
    ${out_cablnk_list}=  Set Variable    ${0}
    FOR  ${out_index}  IN   @{source_dist_name_list}
      ${object_1}=  Set Variable  //CABLNK_L-* is [sourceDistName=regex"${out_index}/CONNECTOR_L-\\d+",
      ${object_2}=  Set Variable  cablinkType=regex"RP3_01Link|CPRILink" ,linkMode.data=True,stateInfo.availabilityStatus=Online]
      ${sum_object}=  Set Variable  ${object_1}${object_2}
      ${out_cablnk}=  admin_im.Query Infomodel
     ...  query=get list ${sum_object}
     ...  timeout=${timeout}  alias=${alias}
        ${out_cablnk_list}=   Info Model Get Cablnk Dist Name For Cablnk List   ${out_cablnk}
    END
    [Return]   ${out_cablnk_list}

Info Model Get Cablnk Dist Name For Cablnk List
    [Arguments]  ${cablnk_list}
    @{out_cablnk_list}=   create list
    FOR  ${out_index}  IN  @{cablnk_list}
      Append To List    ${out_cablnk_list}    ${out_index.dist_name}
    END
    [Return]   ${out_cablnk_list}

Info Model Create Cablnk List For Data Links
    [Arguments]  ${source_dist_name_list}  ${timeout}=120  ${alias}=default
    @{out_cablnk_list}=   create list
    FOR  ${out_index}  IN   @{source_dist_name_list}
      ${object_1}=  Set Variable  //CABLNK_L-* is [sourceDistName=regex"${out_index}/CONNECTOR_L-\\d+",cablinkType=regex"RP3_01Link|CPRILink" ,
      ${object_2}=  Set Variable  linkMode.data=True,linkMode.configuration=False,linkMode.synchronization=False,stateInfo.availabilityStatus=Online]
      ${sum_object}=  Set Variable  ${object_1}${object_2}
      ${out_cablnk}=  admin_im.Query Infomodel
     ...  query=get list ${sum_object}
     ...  timeout=${timeout}    alias=${alias}
        ${out_cablnk_list}=   Info Model Get Cablnk Dist Name For Cablnk List   ${out_cablnk}
    END
    [Return]  ${out_cablnk_list}

Info Model Wait For Cell Count in Specific State
    [Arguments]       ${state_to_be_check}    ${state}    ${expected_cell_count}    ${timeout}=300    ${alias}=default
    [Documentation]   Keyword check specific state on cell for lcrid list.
    admin_im.Query Infomodel   query=count //LNBTS_M-1/CELL_M-* is [${state_to_be_check}=regex"${state}"] = ${expected_cell_count}
    ...               timeout=${timeout}    alias=${alias}

Info Model Wait For WCDMA Cell Count in Specific States
  [Arguments]  ${operationalState}    ${availabilityStatus}    ${proceduralState}    ${cell_count}    ${timeout}=300    ${alias}=default
  [Documentation]   Confirms expected count of //LNBTS_M-1/CELL_M-* IM node with expected attributes state.
  ${object_1}=  Set Variable  //WNBTS_M-1/CELL_M-* is [stateInfo.operationalState=${operationalState},
  ${object_2}=  Set Variable  stateInfo.availabilityStatus=${availabilityStatus},stateInfo.proceduralState=regex"${proceduralState}"] = ${cell_count}
  ${sum_object}=  Set Variable  ${object_1}${object_2}
  admin_im.Query Infomodel
  ...  query=count ${sum_object}
  ...  timeout=${timeout}    alias=${alias}

Info Model Wait For Cablnk States
  [Arguments]  ${cablnk_list}  ${operationalState}  ${availabilityStatus}  ${cablinkType}=regex"RP3_01Link|CPRILink"  ${timeout}=10  ${alias}=default
  FOR    ${cablnk}    IN    @{cablnk_list}
    ${object_1}=  Set Variable  get object ${cablnk} is [cablinkType=${cablinkType},stateInfo.operationalState=${operationalState},
    ${object_2}=  Set Variable  stateInfo.availabilityStatus=${availabilityStatus}]
    ${sum_object}=  Set Variable  ${object_1}${object_2}
    ${cablnk_object}=   admin_im.Query Infomodel
    ...  query=${sum_object}
    ...  timeout=${timeout}   alias=${alias}
  END

Info Model Wait For First Cablnk States
  [Arguments]  ${cablnk_list}  ${operationalState}  ${availabilityStatus}  ${cablinkType}=regex"RP3_01Link|CPRILink"  ${timeout}=10  ${alias}=default
  ${object_1}=  Set Variable  get object ${cablnk_list[0]} is [cablinkType=${cablinkType},stateInfo.operationalState=${operationalState},
  ${object_2}=  Set Variable  stateInfo.availabilityStatus=${availabilityStatus}]
  ${sum_object}=  Set Variable  ${object_1}${object_2}
  ${cablnk_object}=    admin_im.Query Infomodel
    ...  query=${sum_object}
    ...  timeout=${timeout}  alias=${alias}

Info Model Wait For Specific Cablnk State
    [Arguments]  ${cablnk_list}  ${state_to_be_check}  ${status}  ${timeout}=30  ${alias}=default
    FOR  ${cablnk}  IN  @{cablnk_list}
        admin_im.query infomodel    query=${cablnk} is [${state_to_be_check}=${status}]  timeout=${timeout}  alias=${alias}
    END

Info Model Wait For Specific RF States RU_L Object
  [Arguments]    ${fr_serial_number}  ${operational}  ${availability}  ${fr_ru_node}=RU_L-*    ${timeout}=10    ${alias}=default
  admin_im.Query Infomodel
  ...  //${fr_ru_node} is [serialNumber=${fr_serial_number},stateInfo.operationalState=${operational},stateInfo.availabilityStatus=${availability}]
  ...  timeout=${timeout}    alias=${alias}

Info Model Check RU_L Object Reasoning State
     [Arguments]   ${reasoningStatus}    ${fr_serial_number}    ${fr_ru_node}=RU_L-*    ${timeout}=10    ${alias}=default
     ${ru_object}=    admin_im.query infomodel  query=get object //${fr_ru_node} is [serialNumber=${fr_serial_number}]
     ...  timeout=${timeout}    alias=${alias}
     ${state}=  set variable  ${ru_object.stateInfo.reasoningStatus[0]}
     Should Be Equal As Strings    ${reasoningStatus}   ${state}

Info Model Check Leds On System Module For Cablnk List
    [Arguments]   ${cablnk_destinationPhysicalPortNo}    ${led_state_to_be_check}   ${timeout}=10     ${alias}=default
    FOR    ${sm_port}    IN    @{cablnk_destinationPhysicalPortNo}
        ${led_object}=  admin_im.Query Infomodel
        ...  query=get object //SMOD_L-1/LED_L-* is [ledLabel=FctOpt${sm_port},ledState=${led_state_to_be_check}]
        ...  timeout=${timeout}    alias=${alias}
        Log    SM port ${led_object.ledLabel} changed led color to ${led_object.ledState}    console=yes
    END

Info Model Wait For Cablnk Becomes Primary Link
  [Arguments]  ${timeout}=240   ${alias}=default
  ${object_1}=  Set Variable  //CABLNK_L-* is [cablinkType=regex"RP3_01Link|CPRILink" ,linkMode.data=True,linkMode.configuration=True,
  ${object_2}=  Set Variable  linkMode.synchronization=True,stateInfo.availabilityStatus=Online]
  ${sum_object}=  Set Variable  ${object_1}${object_2}
    admin_im.Query Infomodel  ${sum_object}
    ...  timeout=${timeout}    alias=${alias}

Info Model Check Rmod Count For FR Serial Number
  [Arguments]    ${fr_serial_number}    ${rmod_count}    ${timeout}=10    ${alias}=default
  admin_im.Query Infomodel
  ...  query=count //EQM_L-1/RMOD_L-* is [serialNumber=${fr_serial_number}]=${rmod_count}    timeout=${timeout}    alias=${alias}


#####################################################################################################################################################
############################################ TWO LINKS KEYWORDS #####################################################################################
Info Model Wait For Cell Count in Specific States
    [Arguments]    ${operationalState}    ${availabilityStatus}    ${proceduralState}    ${expected_cell_count}    ${timeout}=300    ${alias}=default
    [Documentation]   Confirms expected count of //LNBTS_M-1/CELL_M-* IM node with expected attributes state.
    ...     Maintainer:
    ${object_1}=  Set Variable  count //LNBTS_M-1/CELL_M-* is [stateInfo.operationalState=${operationalState},
    ${object_2}=  Set Variable  stateInfo.availabilityStatus=${availabilityStatus},
    ${object_3}=  Set Variable  stateInfo.proceduralState=regex"${proceduralState}"] = ${expected_cell_count}
    ${sum_object}=  Set Variable  ${object_1}${object_2}${object_3}
    admin_im.Query Infomodel
    ...  query=${sum_object}
    ...  timeout=${timeout}    alias=${alias}

Info Model Create LcrID List For Expected Cells States
    [Arguments]  ${state_to_be_check_1}    ${state_to_be_check_2}    ${scfc_file_path}    ${fr_serial_number_list}    ${timeout}=5   ${alias}=default
    ${lcrId_list}=   SCFC Create LcrId List For FR Serial Numbers List New    ${scfc_file_path}    ${fr_serial_number_list}
    @{out_cell_list}=  Create List
    FOR    ${cell}    IN    @{lcrId_list}
        ${state}  ${value} =   run keyword and ignore error  admin_im.query infomodel
        ...  query=//LNBTS_M-1/CELL_M-${cell} is [${state_to_be_check_1},${state_to_be_check_2}]   timeout=${timeout}    alias=${alias}
        Run Keyword If   '${state}'=='PASS'   Append To List    ${out_cell_list}     ${cell}
    END
    [Return]   ${out_cell_list}

Info Model LNBTS Should Be In Degraded State
    [Arguments]    ${state}    ${timeout}     ${alias}=default
    [Documentation]    Confirms if //MRBTS_M-${bts_l_id}/LNBTS_M-1                   IM node contains avaliability attribute with expected value.
    ...     Author:      tadeusz.brylkowski@nokia.com
    ...     Maintainer:
    ${out_degraded_state_list}=    Create List
    ${out_matched_node_list}=    admin_im.Query Infomodel    query=get list //MRBTS_M-1/LNBTS_M-1 is [stateInfo.availabilityStatus=${state}]
    ...                                        timeout=${timeout}    alias=${alias}
    FOR    ${out_matched_node}    IN    @{out_matched_node_list}
      Append To List    ${out_degraded_state_list}    ${out_matched_node.stateInfo.availabilityStatus}
    END
    Log  \nLNBTS is now in '${out_degraded_state_list[0]}' (${alias})    console=yesInfo Model LNBTS Should Be In Degraded State

Info Model Wait For Expected Connector Count
    [Arguments]  ${operationalState}=Enabled    ${availabilityStatus}=Online    ${connector_count}=2    ${syncMode}=Master
    ...     ${connectorLabel}=RF_EXT*    ${connectorType}=OPT_RP301_CPRI    ${alias}=default    ${timeout}=10
    [Documentation]    Wait for expected count of //SMOD_L-*/CONNECTOR_L-* IM node with expected attributes state.
    ...    Maintainer:
    ${object_1}=  Set Variable  query=count //SMOD_L-*/CONNECTOR_L-* is [connectorLabel=regex"${connectorLabel}", connectorType=${connectorType}
    ${object_2}=  Set Variable  , syncMode=${syncMode}, stateInfo.operationalState=${operationalState}
    ${object_3}=  Set Variable  , stateInfo.availabilityStatus=${availabilityStatus}] = ${connector_count}
    ${sum_object}=  Set Variable  ${object_1}${object_2}${object_3}
    admin_im.Query Infomodel    ${sum_object}  alias=${alias}  timeout=${timeout}

Info Model Wait For Cablnks Count With Expected States
  [Arguments]
  ...  ${source_dist_name_list}  ${expected_cablnk_count}  ${operationalState}=Enabled  ${availabilityStatus}=Online  ${alias}=default  ${timeout}=10
    [Documentation]    Wait for expected count of //CABLNK_L-* IM node with expected attributes state.
    ...    Author:       tadeusz.brylkowski@nokia.com
    ...    Maintainer:
    FOR  ${rmod_path}  IN  @{source_dist_name_list}
      ${object_1}=  Set Variable  //CABLNK_L-* is [sourceDistName=regex"${rmod_path}/CONNECTOR_L-\\d+", cablinkType=regex"RP3_01Link|CPRILink" ,
      ${object_2}=  Set Variable   linkMode.data=True,stateInfo.operationalState=${operationalState}
      ${object_3}=  Set Variable  , stateInfo.availabilityStatus=${availabilityStatus}] = ${expected_cablnk_count}
      ${sum_object}=  Set Variable  ${object_1}${object_2}${object_3}
        admin_im.Query Infomodel
        ...  query=count ${sum_object}
        ...  alias=${alias}   timeout=${timeout}
    END


Info Model Create Connector List With Expected States
  [Arguments]  ${operationalState}    ${availabilityStatus}    ${syncMode}=Master    ${connectorLabel}=RF_EXT*    ${connectorType}=OPT_RP301_CPRI
    ...  ${alias}=default    ${timeout}=10
  [Documentation]    Keyword create connector list with expected attributes state.
  ...    Author:       tadeusz.brylkowski@nokia.com
  ...    Maintainer:
  @{out_connector_list}=    Create List
  ${object_1}=  Set Variable  query=get list //SMOD_L-*/CONNECTOR_L-* is [connectorLabel=regex"${connectorLabel}", connectorType=${connectorType}
  ${object_2}=  Set Variable   , syncMode=${syncMode}, stateInfo.operationalState=${operationalState}
  ${object_3}=  Set Variable  , stateInfo.availabilityStatus=${availabilityStatus}]
  ${sum_object}=  Set Variable  ${object_1}${object_2}${object_3}
  ${connector_list}=    admin_im.query infomodel    ${sum_object}
  ...   alias=${alias}  timeout=${timeout}
	FOR  ${connector}  IN  @{connector_list}
	    Append To List   ${out_connector_list}    ${connector.dist_name}
  END
	[Return]  ${out_connector_list}

Info Model Create Cablnk List Based On Connectors List
	[Arguments]  ${connector_list}    ${alias}=default    ${timeout}=10
	[Documentation]    Keyword create list of cablnk dist_name based on connectors list.
    ...    Author:      tadeusz.brylkowski@nokia.com
    ...    Maintainer:
	@{out_cablnk_list}=    Create List
	FOR  ${connector}  IN  @{connector_list}
	    ${cablnk}=   admin_im.query infomodel    query=get object //CABLNK_L-* is [destinationDistName=${connector}]
	    ...  alias=${alias}    timeout=${timeout}
	    Append To List  ${out_cablnk_list}    ${cablnk.dist_name}
  END
	[Return]  ${out_cablnk_list}

Info Model Create PhysicalPortNo Based On Connectors List
	[Arguments]  ${connector_list}    ${alias}=default    ${timeout}=10
	[Documentation]    Create PhysicalPortNo list based on connectors list.
    ...    Author:      tadeusz.brylkowski@nokia.com
    ...    Maintainer:
	@{out_port_list}=    Create List
    FOR  ${connector}  IN  @{connector_list}
        ${item}=    admin_im.query infomodel    query=get object ${connector}    alias=${alias}    timeout=${timeout}
        Append To List    ${out_port_list}    ${item.physicalPortNo}
    END
    [Return]  ${out_port_list}

Info Model Create Cablnk List Detected From HWF
    [Arguments]     ${operationalState}=Disabled    ${availabilityStatus}=NotInstalled   ${cablinkType}=regex"RP3_01Link|CPRILink"
    ...  ${originatingStatus}=fromHWF    ${timeout}=10   ${alias}=default
    [Documentation]    Confirm if system module ports given by list ${port_number} have expected leds color.
    ...    Author:      tadeusz.brylkowski@nokia.com
    ...    Maintainer:
    @{out_cablink_list}=  Create List
    ${object_1}=  Set Variable  query=get list //CABLNK_L-* is [cablinkType=${cablinkType},stateInfo.availabilityStatus=${availabilityStatus},
    ${object_2}=  Set Variable  stateInfo.operationalState=${operationalState}]
    ${sum_object}=  Set Variable  ${object_1}${object_2}
    ${cablink_list}=    admin_im.query infomodel  ${sum_object}  timeout=${timeout}   alias=${alias}
    FOR   ${item}  IN  @{out_cablink_list}
        Append To List    ${out_cablink_list}    ${item.dist_name}
    END
    [Return]    ${out_cablink_list}

Info Model Check SM Ports Led Color
    [Arguments]    ${port_number}    ${led_state_to_be_check}    ${sw_rel_tested_trunk_tag}=${SW_REL_TESTED_TRUNK_TAG}
    ...             ${timeout}=10    ${alias}=default
    [Documentation]    Confirm if system module ports given by list ${port_number} have expected leds color.
    ...    Author:      tadeusz.brylkowski@nokia.com
    ...    Maintainer:
    ${led_im_path}=    Set Variable If    "${sw_rel_tested_trunk_tag}"=="FSM3"    //SMOD_L-1/LED_L-*    //LED_L-*
    FOR    ${number}    IN    @{port_number}
        ${led_object}=  admin_im.query infomodel
        ...  query=get object ${led_im_path} is [ledLabel=regex"FctOpt${number}|FspRfExt${number}",ledState=regex"${led_state_to_be_check}"]
        ...  timeout=${timeout}    alias=${alias}
        Log    SM port RFExt${number} changed led color to ${led_object.ledState}    console=yes
    END

Info Model Check RMOD_L Object Count For FR Serial Number
    [Arguments]    ${fr_serial_number}    ${rmod_count}    ${timeout}=10    ${alias}=default
    [Documentation]    Confirm RMOD_L object count with the same ${fr_serial_number}.
    ...    Author:      tadeusz.brylkowski@nokia.com
    ...    Maintainer:
    admin_im.query infomodel    query=count //EQM_L-1/RMOD_L-* is [serialNumber=${fr_serial_number}]=${rmod_count}
    ...  timeout=${timeout}    alias=${alias}

Info Model Check Connector State
    [Arguments]   ${connector}    ${state_to_be_check}    ${timeout}=10    ${alias}=default
    admin_im.query infomodel  /${connector} is [${state_to_be_check}]    timeout=${timeout}    alias=${alias}

Ims2 FR Removal Detection
    [Arguments]  ${fr_serial_number_list}   ${ims2_file_path}    ${alias}=default  ${times}=1
    FOR    ${out_fr_serial_number}    IN    @{fr_serial_number_list}
      ${out_fr_node}=    Get RMOD node from infomodel using ims2 file    ${out_fr_serial_number}    ${ims2_file_path}    alias=${alias}
      Initialize ims2 validator    ${ims2_file_path}    alias=${alias}
      Add expected ims2 event    change ${out_fr_node}/RU_L-1 [stateInfo.proceduralState:*->initializing] times=${times}    alias=${alias}
      Add expected ims2 event    change ${out_fr_node}/RU_L-1 [stateInfo.operationalState:Enabled->Disabled] times=1   alias=${alias}
      Add expected ims2 event    change ${out_fr_node}/RU_L-1 [stateInfo.availabilityStatus:*->NotInstalled] times=1    alias=${alias}
      Validate ims2    alias=${alias}
    END

Ims2 FR Autodetetion
    [Arguments]  ${fr_serial_number_list}    ${ims2_file_path}    ${alias}=default  ${times}=1   ${RMOD_id}=*
    FOR    ${out_fr_serial_number}    IN    @{fr_serial_number_list}
      ${out_fr_node}=    Get RMOD node from infomodel using ims2 file    ${out_fr_serial_number}    ${ims2_file_path}    alias=${alias}
      Initialize ims2 validator    ${ims2_file_path}    alias=${alias}
      Add expected ims2 event    change ${out_fr_node} [stateInfo.availabilityStatus:NotInstalled->Online] times=${times}    alias=${alias}
      Add expected ims2 event    change ${out_fr_node}/RU_L-* [stateInfo.availabilityStatus:*->Online] times=${times}    alias=${alias}
      Add expected ims2 event    change ${out_fr_node}/RU_L-* [stateInfo.operationalState:Disabled->Enabled] times=${times}    alias=${alias}
      Add expected ims2 event    change ${out_fr_node} [stateInfo.operationalState:Enabled->Disabled] times=${times}    alias=${alias}
      Add expected ims2 event    change ${out_fr_node}/RU_L-* [stateInfo.proceduralState:*->swCheckDone] times=${times}    alias=${alias}
      Add expected ims2 event    change ${out_fr_node} [stateInfo.proceduralState:*->ethernetEnabled] times=${times}    alias=${alias}
      Validate ims2    alias=${alias}
    END

Ims2 NotCommissind FR Detection And Remove
    [Arguments]  ${ims2_file_path}    ${fr_serial_number}   ${alias}=default  ${times}=1   ${RMOD_id}=*    ${APEQM_id}=*
    Initialize ims2 validator    ${ims2_file_path}    alias=${alias}
    Run Keyword And Ignore Error
    ...  Add expected ims2 event    update //EQM_R-1/APEQM_R-${APEQM_id}/RMOD_R-${RMOD_id} [serialNumber=${fr_serial_number}] times>=${times}
    Add expected ims2 event    remove //EQM_R-1/APEQM_R-${APEQM_id}/RMOD_R-${RMOD_id} [serialNumber=${fr_serial_number}] times=${times}
    Validate ims2    alias=${alias}

Ims2 FSM Should Be Rebooted
    [Arguments]    ${ims2_file_path}    ${alias}=default    ${times}=1
    [Documentation]    Verifies offline in the provided .ims2 file if FSM was rebooted.
    Initialize ims2 validator    ${ims2_file_path}    alias=${alias}
    Add expected ims2 event    reset times=${times}    alias=${alias}
    Validate ims2    alias=${alias}

Info Model Return Alarm Severity Based on FaultId And Reporting Resource
    [Arguments]    ${available_alarms}   ${fault_id}    ${act_category_alarms}=True    ${alias}=default    ${timeout}=10
    [Documentation]  Keyward requier alarm list created on keyword ' Info Model Alarms Get Active'.
    ...    Author:      tadeusz.brylkowski@nokia.com
    ...    Maintainer:
    @{out_alarm_severity}=    Create List
    FOR  ${alarm}  IN  @{available_alarms}
        Run Keyword If    '${act_category_alarms}'=='False'    Run Keyword If    '${alarm.alarmInformation.faultId}'=='${fault_id}'
        ...    Append To List    ${out_alarm_severity}   ${alarm.alarmInformation.alarmSeverity}
        Run Keyword if    '${act_category_alarms}'=='True'    Run Keyword If    '${alarm.faultId}'=='${fault_id}'
        ...    Append To List    ${out_alarm_severity}   ${alarm.alarmSeverity}
    END
    [Return]    ${out_alarm_severity[0]}

Infomodel Multiple Query
    [Arguments]  ${list_of_queries}  ${timeout}=10  ${alias}=default
    FOR   ${query}  IN  @{list_of_queries}
      ${query_formatted}=  Replace String Using Regexp  ${query}  query\\d*=  ${EMPTY}
      Run Keyword And Continue On Failure  admin_im.query infomodel  query=${query_formatted}  timeout=${timeout}  alias=${alias}
    END

Info Model Get HW Active SW
    [Arguments]  ${serial_number}  ${timeout}=0.1  ${alias}=default
    [Documentation]    Returns HW Active SW. Fails if verification cannot be performed.
    ...     Supported HW: RMOD, FHS
    ...     Maintainer:     Author
    ${hw_distname}=    Info Model Get HW Distname  ${serial_number}  timeout=${timeout}   alias=${alias}
    Run Keyword If  ${timeout}>0.1   admin_im.query infomodel
    ...  query=${hw_distname}//FILE_SYSTEM_L-1/BUILD_DATA_L-1 is [bldVersion=regex"^.{3,}$"]
    ...  timeout=${timeout}  alias=${alias}
    ${rf_under_test_active_sw}=  admin_im.Get Infomodel Object  ${hw_distname}//FILE_SYSTEM_L-1/BUILD_DATA_L-1
    ...  timeout=${timeout}  alias=${alias}
    ${rf_active_sw}=     Get From Dictionary   ${rf_under_test_active_sw}  bldVersion
    Should Not Be Equal  ${rf_active_sw}  ${EMPTY}
    [Return]  ${rf_active_sw}

Info Model Get HW Distname
    [Arguments]  ${serial_number}  ${timeout}=60   ${alias}=default
    ${hw_distname}=   Wait Until Keyword Succeeds  ${timeout}  5
    ...    Info Model Get HW Distname Now  ${serial_number}  alias=${alias}
    [Return]  ${hw_distname}

Info Model Get HW Distname Now
    [Arguments]  ${serial_number}  ${alias}=default
    [Documentation]    Returns distname of given HW serial number. Fails if HW cannot be found.
    ...     Supported HW: RMOD, FHS, SMOD
    ...     Author:         michal.szajkowski@nokia.com
    ...     Maintainer:     michal.szajkowski@nokia.com
    ${s_1}  ${hw_object_1}=    Run Keyword And Ignore Error
    ...    admin_im.query infomodel    query=get object //EQM_L-1/RMOD_L-* is [serialNumber=${serial_number}]
    ...                       timeout=0.1
    ...                       alias=${alias}
    ${s_2}  ${hw_object_2}=    Run Keyword And Ignore Error
    ...    admin_im.query infomodel    query=get object //EQM_L-1/FHS_L-* is [serialNumber=${serial_number}]
    ...                       timeout=0.1
    ...                       alias=${alias}
    ${s_3}  ${hw_object_3}=    Run Keyword And Ignore Error
    ...    admin_im.query infomodel    query=get object //EQM_L-1//SMOD_L-* is [serialNumber=${serial_number}]
    ...                       timeout=0.1
    ...                       alias=${alias}
    ${hw_object}=    Run Keyword If  "${s_1}"=="PASS"  Set Variable  ${hw_object_1}
    ...              ELSE IF         "${s_2}"=="PASS"  Set Variable  ${hw_object_2}
    ...              ELSE IF         "${s_3}"=="PASS"  Set Variable  ${hw_object_3}
    ...              ELSE             Fail    HW with given serial number not found!
    ${hw_distname}=  Set Variable    ${hw_object.dist_name}
    [Return]  ${hw_distname}

FR Chain Get Elements Before FR (Included) List
    [Arguments]    ${fr_serial_number_signle_chain_list}    ${fr_serial_number}
    ${out_fr_index_in_chain_list}=    Get Index From List    ${fr_serial_number_signle_chain_list}    ${fr_serial_number}
    ${out_fr_serial_number_list}=     Get Slice From List    ${fr_serial_number_signle_chain_list}    0    ${out_fr_index_in_chain_list+1}
    [Return]    ${out_fr_serial_number_list}

FR Chain Get Elements Before FR (Excluded) List
    [Arguments]    ${fr_serial_number_signle_chain_list}    ${fr_serial_number}
    ${out_fr_index_in_chain_list}=    Get Index From List    ${fr_serial_number_signle_chain_list}    ${fr_serial_number}
    ${out_fr_serial_number_list}=     Get Slice From List    ${fr_serial_number_signle_chain_list}    0    ${out_fr_index_in_chain_list}
    [Return]    ${out_fr_serial_number_list}

FR Chain Get Elements After FR (Included) List
    [Arguments]    ${fr_serial_number_signle_chain_list}    ${fr_serial_number}
    ${out_fr_index_in_chain_list}=  Get Index From List  ${fr_serial_number_signle_chain_list}  ${fr_serial_number}
    ${out_fr_serial_number_list}=  Get Slice From List  ${fr_serial_number_signle_chain_list}  ${out_fr_index_in_chain_list}
    [Return]    ${out_fr_serial_number_list}

FR Chain Get Elements After FR (Excluded) List
    [Arguments]    ${fr_serial_number_signle_chain_list}    ${fr_serial_number}
    ${out_fr_index_in_chain_list}=  Get Index From List  ${fr_serial_number_signle_chain_list}  ${fr_serial_number}
    ${out_fr_serial_number_list}=  Get Slice From List  ${fr_serial_number_signle_chain_list}  ${out_fr_index_in_chain_list+1}
    [Return]  ${out_fr_serial_number_list}

FR Get Front End Gain For FR AntId
  [Arguments]    ${fr_ip_addr}    ${fr_antl_id}  ${alias}=default
  [Documentation]  Keyword returns MHA signal power gain at given antenna ${fr_antl_id} of FR with IP ${fr_ip_addr}.
  ...              NOTE: Info Model session with correct alias must be started/opened before execution of this KW.
  ...              Author:     michal.szajkowski@nokia.com
  ...              Maintainer: author
  ${rx_feg_tmp}=    Set Variable    None
  ${ant_id}=        Should Match Regexp    ${fr_antl_id}    ANT(\\d+)
  ${rf_node}=       FR Get FSMR4 Active Node      ${fr_ip_addr}  alias=${alias}
  SSHLibrary.Open Connection    192.168.255.1    alias=FSM    prompt=REGEXP:(~ >|\\$|rtose@gaia>)  encoding=cp1252
  SSHLibrary.Login              toor4nsn    oZPS0POrRieRtu
  Run Keyword If                '${rf_node}'!='None'
  ...   SSHLibrary.Write        lxc-attach -n ${rf_node} -- telnet ${fr_ip_addr} 2323
  ...   ELSE
  ...   SSHLibrary.Write        telnet ${fr_ip_addr} 2323
  ${telnet_login}=    SSHLibrary.Read Until Prompt
  ${is_frm_3.1}=      Run Keyword And Ignore Error    Should Match Regexp    ${telnet_login}    rtose@gaia
  ${frm_3.1_cmd_arg1}=    Run Keyword If    '@{is_frm_3.1}[0]'=='PASS'    Evaluate    int(math.floor((@{ant_id}[1]+1)/2))    math
  ${frm_3.1_cmd_arg2}=    Run Keyword If    '@{is_frm_3.1}[0]'=='PASS'    Evaluate    int((@{ant_id}[1]+1)%2+1)
  Run Keyword If  '@{is_frm_3.1}[0]'=='PASS'    SSHLibrary.Write    frontEnd feGetLnaGain ${frm_3.1_cmd_arg1} ${frm_3.1_cmd_arg2}
  ...             ELSE                              SSHLibrary.Write    rx -stat
  ${rx_stat_cmd}=    SSHLibrary.Read Until Prompt
  SSHLibrary.Close Connection
  ${rx_id_feg_list}=  Run Keyword If  '@{is_frm_3.1}[0]'=='PASS'    Should Match Regexp    ${rx_stat_cmd}    gain:\\s*(\\d+)    ELSE
  ...     Get Regexp Matches
  ...  ${rx_stat_cmd}    (?si)RX(\\d+)\\s+Virtual\\s+Device\\s+status:\\s+HW\\s+State\\.+Running\\s+SW\\s+State\\.+Running.*?Front End Gain\\.+(\\S*)
  ...    1    2
  FOR    ${rx_id_feg}    IN     @{rx_id_feg_list}
      ${rx_feg_tmp}=    Set Variable If    '${rx_id_feg[0]}' == '@{ant_id}[1]'    ${rx_id_feg[1]}    None
      Exit For Loop If    '${rx_feg_tmp}' != 'None'
  END
  ${index}=           Run Keyword If     '@{is_frm_3.1}[0]'!='PASS'    Evaluate      @{ant_id}[1]-1
  ${rx_feg_count}=    Run Keyword If     '@{is_frm_3.1}[0]'!='PASS'    Get Length    ${rx_id_feg_list}
  ${rx_feg}=          Set Variable If    '@{is_frm_3.1}[0]'=='PASS'                 @{rx_id_feg_list}[1]
  ...                                    '@{ant_id}[1]' <= '${rx_feg_count}'    ${rx_id_feg_list[${index}][1]}    ${rx_feg_tmp}
  [Return]    ${rx_feg}

FR Get FSMR4 Active Node
    [Arguments]    ${fr_ip_addr}  ${alias}=default
    [Documentation]  Keyword returns the FSMR4 node from which radio modules are reachable.
    ...              NOTE: Info Model session with correct alias must be started/opened before execution of this KW.
    ...              Author:     michal.szajkowski@nokia.com
    ...              Maintainer: author
    ${out_enb_hw_type}=    Info Model Get BTS HW Variant   timeout=60  alias=${alias}
    Return From Keyword If        "ASI" not in "${out_enb_hw_type}"
    SSHLibrary.Open Connection    192.168.255.1    alias=FSM    prompt=:~ >
    SSHLibrary.Login              toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Start Command      lxc-ls --active
    ${out_nodes}=       SSHLibrary.Read Command Output
    ${out_nodes}=       String.Split To Lines    ${out_nodes}
    ${out_right_node}=  Create List
    FOR    ${out_node}    IN    @{out_nodes}
       SSHLibrary.Start Command  lxc-attach -n ${out_node} -- ping -W 1 -c 1 ${fr_ip_addr} &> /dev/null && echo ping ok || echo ping nok \n
       ${out_output}=         SSHLibrary.Read Command Output
       ${out_passed}=         Run Keyword And Return Status    Should Contain    ${out_output}    ping ok
       Continue For Loop If   not ${out_passed}
       ${out_right_node}=     Set Variable If    ${out_passed}    ${out_node}   ${out_right_node}
       Exit For Loop If  ${out_passed}
    END
    SSHLibrary.Close Connection
    [Return]   ${out_right_node}

FR Telnet Via FSM SSH Tunnel
    [Arguments]    ${fr_ip_addr}    ${fr_telnet_port}=2323    ${alias}=FSM_tunnel
    [Documentation]    Keyword establishes telnet session to the given radio module through pre-established SSH session to the system module.
    ...                Also sets proper shell prompt.
    ...    Author:      tomasz.blaszczyszyn@nokia.com
    ...    Maintainer:  artur.dobosz@nokia.com
    SSHLibrary.Switch Connection           ${alias}
    SSHLibrary.Write                       telnet ${fr_ip_addr}:${fr_telnet_port}
    ${out_telnet_login}=    SSHLibrary.Read Until Regexp    (\\$|rtose@gaia>)$
    ${out_telnet_prompt}=    Should Match Regexp    ${out_telnet_login}    \\$$|rtose@gaia>$
    SSHLibrary.Set Client Configuration    prompt=${out_telnet_prompt}
    [Return]    ${out_telnet_prompt}

FR Create And Get Logs File
    [Arguments]    ${fr_ip_addr}    ${logs_dir_path}    ${fsm_ip_addr}=192.168.255.129    ${fr_telnet_port}=2323    ${timeout}=120    ${alias}=FSM
    [Documentation]    Keyword connects to given Radio Module via telnet, creates logs .zip file and downloads it to local machine.
    ...                All operations are executed through SSH tunnel via System Module.
    ...    Author:      tomasz.blaszczyszyn@nokia.com
    ...    Maintainer:  artur.dobosz@nokia.com
    ${out_cmd}=    FR Execute Command     ${fr_ip_addr}    log -c full -z /ram/${fr_ip_addr}_rflogs.zip    ${fsm_ip_addr}
    ...                                   ${fr_telnet_port}    ${timeout}    alias=${alias}
    ${out_matches}=    Should Match Regexp    ${out_cmd}    AaSysComUserDeregister succeed!
    ${out_file_path}=    FR Get File    ${fr_ip_addr}    /ram/${fr_ip_addr}_rflogs.zip    ${logs_dir_path}
    ...                                 ${fsm_ip_addr}    ${fr_telnet_port}    ${alias}
    [Return]    ${out_file_path}
    [Teardown]    FR Execute Command    ${fr_ip_addr}    rm /ram/${fr_ip_addr}_rflogs.zip    ${fsm_ip_addr}    ${fr_telnet_port}    alias=${alias}

FR Invoke Fault Via Telnet Cmd
    [Arguments]    ${fsm_ip_addr}    ${fr_ip_addr}    ${fr_telnet_port}=2323    ${fault_id}=1163
    ...            ${source}=0    ${severity}=0    ${state}=0    ${device_type}=0    ${device_id}=0    ${alias}=FSM
    [Documentation]    Keyword connects to given Radio Module via telnet and execute sendFault command in order to invoke fault.
    ...                All operations are executed through SSH tunnel via System Module.
    ...    Author:      tomasz.blaszczyszyn@nokia.com
    ...    Maintainer:  artur.dobosz@nokia.com
    FR Execute Command     ${fr_ip_addr}    sendFault ${fault_id} ${source} ${severity} ${state} ${device_type} ${device_id}    ${fsm_ip_addr}
    ...                    ${fr_telnet_port}    alias=${alias}


FR Clear Fault Via Telnet Cmd
    [Arguments]    ${fsm_ip_addr}    ${fr_ip_addr}    ${fr_telnet_port}=2323    ${fault_id}=1163
    ...            ${source}=0    ${severity}=0    ${state}=1    ${device_type}=0    ${device_id}=0    ${alias}=FSM
    [Documentation]    Keyword connects to given Radio Module via telnet and execute sendFault command in order to clear fault.
    ...                All operations are executed through SSH tunnel via System Module.
    ...    Author:      tomasz.blaszczyszyn@nokia.com
    ...    Maintainer:  artur.dobosz@nokia.com
    FR Execute Command     ${fr_ip_addr}    sendFault ${fault_id} ${source} ${severity} ${state} ${device_type} ${device_id}    ${fsm_ip_addr}
    ...                    ${fr_telnet_port}    alias=${alias}

FR Execute Command
    [Arguments]    ${fr_ip_addr}    ${command}    ${fsm_ip_addr}=192.168.255.129    ${fr_telnet_port}=2323    ${timeout}=10    ${alias}=FSM
    [Documentation]    Keyword connects to given Radio Module via telnet, executes given command and returns its output.
    ...                All operations are executed through SSH tunnel via System Module.
    ...    Author:      artur.dobosz@nokia.com
    ...    Maintainer:  Author
    ${out_ssh_prompt}=    Get System Module Prompt    ${fsm_ip_addr}    ${alias}    close_connection=False
    SSHLibrary.Set Client Configuration    timeout=${timeout}    prompt=${out_ssh_prompt}
    FR Telnet Via FSM SSH Tunnel    ${fr_ip_addr}    ${fr_telnet_port}    ${alias}
    SSHLibrary.Write    ${command}
    ${out_cmd}=    SSHLibrary.Read Until Prompt
    SSHLibrary.Set Client Configuration   prompt=${out_ssh_prompt}
    SSHLibrary.Write    exit
    [Return]    ${out_cmd}
    [Teardown]    SSHLibrary.Close Connection

FR Flash Get Active Files Names
    [Arguments]    ${fr_ip_addr}    ${fsm_ip_addr}=192.168.255.129    ${fr_telnet_port}=2323    ${alias}=FSM
    [Documentation]    Keyword connects to given Radio Module via telnet, executes "flash -a" command and returns list of active files names.
    ...                All operations are executed through SSH tunnel via System Module.
    ...    Author:      artur.dobosz@nokia.com
    ...    Maintainer:  Author
    ${out_cmd}=    FR Execute Command    ${fr_ip_addr}    flash -a    ${fsm_ip_addr}    ${fr_telnet_port}    alias=${alias}
    ${out_matches}=    Should Match Regexp    ${out_cmd}
    ...     Real situation in flash \\(files which are really active\\) =\\r\\n\\r(.+?)\\s*\\r\\n\\r
    ${out_files_names_list}=    Split String     ${out_matches[1]}
    [Return]    ${out_files_names_list}

FR Flash Create And Get File
    [Arguments]    ${fr_ip_addr}    ${file_name}    ${logs_dir_path}    ${fsm_ip_addr}=192.168.255.129    ${fr_telnet_port}=2323    ${alias}=FSM
    [Documentation]    Keyword connects to given Radio Module via telnet, executes "flash -f ${file_name} ${file_name}_tmp" command
    ...                and downloads created file on local VM.
    ...                All operations are executed through SSH tunnel via System Module.
    ...    Author:      artur.dobosz@nokia.com
    ...    Maintainer:  Author
    ${out_cmd}=    FR Execute Command    ${fr_ip_addr}    flash -f ${file_name} ${file_name}_${fr_ip_addr}
    ...                                  ${fsm_ip_addr}    ${fr_telnet_port}    alias=${alias}
    ${out_matches}=    Should Match Regexp    ${out_cmd}    Status\\s*=\\s*StatusOk(?s)
    ${out_file_path}=    FR Get File    ${fr_ip_addr}    /ram/${file_name}_${fr_ip_addr}    ${logs_dir_path}
    ...                                 ${fsm_ip_addr}    ${fr_telnet_port}    ${alias}
    [Return]    ${out_file_path}
    [Teardown]    FR Execute Command    ${fr_ip_addr}    rm /ram/${file_name}_${fr_ip_addr}    ${fsm_ip_addr}    ${fr_telnet_port}    alias=${alias}

FR Flash Create File And Return Its Content
    [Arguments]    ${fr_ip_addr}    ${file_name}    ${logs_dir_path}    ${fsm_ip_addr}=192.168.255.129    ${fr_telnet_port}=2323    ${alias}=FSM
    [Documentation]    Keyword connects to given Radio Module via telnet, executes "flash -f ${file_name} ${file_name}_tmp" command
    ...                and downloads created file on local VM.
    ...                All operations are executed through SSH tunnel via System Module.
    ...    Author:      artur.dobosz@nokia.com
    ...    Maintainer:  Author
    ${out_cmd}=    FR Execute Command    ${fr_ip_addr}    flash -f ${file_name} ${file_name}_${fr_ip_addr}
    ...                                  ${fsm_ip_addr}    ${fr_telnet_port}    alias=${alias}
    ${out_matches}=    Should Match Regexp    ${out_cmd}    Status\\s*=\\s*StatusOk(?s)
    ${out_file_content}=    FR Execute Command    ${fr_ip_addr}    cat ${file_name}_${fr_ip_addr}
    ...                                  ${fsm_ip_addr}    ${fr_telnet_port}    alias=${alias}
    [Return]    ${out_file_content}
    [Teardown]    FR Execute Command    ${fr_ip_addr}    rm /ram/${file_name}_${fr_ip_addr}    ${fsm_ip_addr}    ${fr_telnet_port}    alias=${alias}

FR Get File
    [Arguments]    ${fr_ip_addr}    ${file_path}    ${logs_dir_path}    ${fsm_ip_addr}=192.168.255.129    ${fr_telnet_port}=2323    ${alias}=FSM
    [Documentation]    Keyword downloads given file from radio module on local VM.
    ...                All operations are executed from System Module.
    ...    Author:      artur.dobosz@nokia.com
    ...    Maintainer:  Author
    ${out_ssh_prompt}=    Get System Module Prompt    ${fsm_ip_addr}    ${alias}    close_connection=False
    SSHLibrary.Set Client Configuration    prompt=${out_ssh_prompt}
    ${out_file_name}=    Fetch From Right    /${file_path}    /
    SSHLibrary.Execute Command    ftpget ${fr_ip_addr} /tmp/${out_file_name} ${file_path}
    SSHLibrary.Get File           /tmp/${out_file_name}  ${logs_dir_path}
    SSHLibrary.Execute Command    rm /tmp/${out_file_name}
    [Return]    ${logs_dir_path}${out_file_name}
    [Teardown]    SSHLibrary.Close Connection

Info Model Get Rmod DistName For FR Serial Number
    [Arguments]    ${fr_serial_number}    ${timeout}=5    ${alias}=default
    [Documentation]    Returns dist_name for given FR serial number.
    ${out_dist_name}=    Info Model Get Rmod Attribute Value For FR Serial Number    ${fr_serial_number}    dist_name    ${timeout}    ${alias}
    [Return]    ${out_dist_name}

Info Model Get Rmod Attribute Value For FR Serial Number
    [Arguments]    ${fr_serial_number}    ${attribute_name}    ${timeout}=20    ${alias}=default
    [Documentation]    Returns value of given attribute name for given FR serial number e.g. l3Protocol or stateInfo.usageState
    ...     Author:         artur.dobosz@nokia.com
    ...     Maintainer:     Author
    ${out_matched_rmod}=    admin_im.query infomodel
    ...    query=get object //EQM_L-1/RMOD_L-* is [serialNumber=${fr_serial_number}, stateInfo.proceduralState=ethernetEnabled]
    ...    timeout=${timeout}
    ...    alias=${alias}
    [Return]    ${out_matched_rmod.${attribute_name}}

Info Model Wait For Alarm
  [Arguments]    ${fault_id}    ${fault_count}    ${timeout}    ${act_category_alarms}=False    ${bts_l_id}=*    ${alias}=default
  [Documentation]    Waits until specific number of instances of alarm defined by faultId is visible in Info Model
  ...    Author:      slawomir.jastrzebski@nokia.com
  ...    Maintainer:  slawomir.jastrzebski@nokia.com
  Run Keyword If    ${act_category_alarms}
  ...  admin_im.query infomodel  query=count //FRI-${bts_l_id}/ALARM-* is [faultId=regex"^${fault_id}(?:$|\\D)"] = ${fault_count}
  ...  timeout=${timeout}    alias=${alias}
  ...  ELSE
  ...  admin_im.query infomodel  query=count //LTS-${bts_l_id}//ALARM_L-* is [alarmInformation.faultId=regex"^${fault_id}(?:$|\\D)"] = ${fault_count}
  ...  timeout=${timeout}    alias=${alias}
  [Teardown]    Info Model Alarms Get Active    alias=${alias}    bts_l_id=${bts_l_id}

Info Model Alarms Get And Check
  [Arguments]    ${allowed}=${EMPTY}    ${mandatory}=${EMPTY}    ${alias}=default    ${bts_l_id}=*
  [Documentation]    Keyword gets and checks Info Model mandatory and allowed alarms.
  ...  Optional arguments:
  ...     allowed - list of allowed alarms defined by alarmDetail attribute (regex is supported).
  ...     mandatory - list of dictionaries with mandatory alarms defined by alarmDetail, faultId, alarmSeverity,
  ...                 distName or impactedCells (ratsImpact in case of SBTS SW), alarmCounter attributes.
  ...                 At least alarmDetail or faultId dictionary key and its value has to be defined (regex is supported in Value).
  ...
  ...  Example for SBTS SW:
  ...     @{allowed}=      (?i)vendor bts certificate
  ...     ...              Synchronization lost
  ...     ...              .*BTS booted at.+
  ...     @{mandatory}=  {'alarmDetail': 'Unit blocked', 'faultId': '48', 'alarmSeverity': 'Major', 'impactedCells': '.*/LNCEL(?:_[LR])?-1?:$|\\D).*'}
  ...     ...              {'alarmDetail': 'Unit blocked', 'faultId': '48', 'impactedCells': '.*/LNCEL(?:_[LR])?-2(?:$|\\D).*'}
  ...     ...              {'alarmDetail': 'Unit blocked', 'alarmSeverity': 'Major', 'impactedCells': '.*/LNCEL(?:_[LR])?-3(?:$|\\D).*'}
  ...     ...              {'alarmDetail': 'Unit blocked', 'alarmSeverity': 'Major', 'alarmCounter': '3'}
  ...     ...              {'faultId': '48', 'alarmSeverity': 'Major', 'impactedCells': '.*/LNCEL(?:_[LR])?-4(?:$|\\D).*'}
  ...     ...              {'alarmDetail': 'Transmission path failure', 'faultId': '4003', 'alarmingResourceDN': '.*/LNCEL(?:_[LR])?-1?:$|\\D).*'}
  ...     ...              {'alarmDetail': 'Transmission path failure', 'faultId': '4003', 'alarmingResource': '.*/LNCEL(?:_[LR])?-2?:$|\\D).*'}
  ...     ...              {'alarmDetail': 'Transmission path failure', 'faultId': '4003', 'alarmingResourceDN': '.*/LNCEL(?:_[LR])?-3?:$|\\D).*'}
  ...     ...              {'alarmDetail': 'Transmission path failure'}
  @{out_active_alamrs}=      Info Model Alarms Get Active    alias=${alias}    bts_l_id=${bts_l_id}
  Info Model Alarms Check    available=${out_active_alamrs}     allowed=${allowed}    mandatory=${mandatory}

Info Model Alarms Get Active
    [Arguments]    ${alias}=default     ${bts_l_id}=*    ${timeout}=2
    [Documentation]    Gets and returns list of active alarms from Info Model
    @{out_empty_list}=    Create List
    @{out_available_alarms_tmp1}=    Run Keyword And Ignore Error    admin_im.query infomodel    query=get list //LTS-${bts_l_id}//ALARM_L-*
    ...                                                                                 alias=${alias}    timeout=${timeout}
    @{out_available_alarms_tmp2}=    Run Keyword And Ignore Error    admin_im.query infomodel    query=get list //FRI-${bts_l_id}/ALARM-*
    ...                                                                                 alias=${alias}    timeout=${timeout}
    @{out_available_alarms}=        Set Variable If    '${out_available_alarms_tmp1}[0]'=='PASS'    ${out_available_alarms_tmp1}[1]
    ...                                                '${out_available_alarms_tmp2}[0]'=='PASS'    ${out_available_alarms_tmp2}[1]
    ...                                                 ${out_empty_list}
    LOG    ${out_available_alarms}
    [Return]    ${out_available_alarms}

Admin Alarms Get And Check
    [Arguments]    ${allowed}=${EMPTY}    ${mandatory}=${EMPTY}    ${alias}=default
    [Documentation]  Keyword gets and checks Admin mandatory and allowed alarms.
    ...  Optional arguments:
    ...     allowed - list of allowed alarms defined by faultName/alarmDetail attribute (regex is supported).
    ...     mandatory - list of dictionaries with mandatory alarms defined by faultName/alarmDetail, faultId, severity/alarmSeverity, impactedCells
    ...                 alarmingResource/alarmingResourceDN, alarmCounter or any other attribute matching to first level key name of active alarm.
    ...                 At least alarmDetail or faultId dictionary key and its value has to be defined (regex is supported in Value)
    ...  Example:
    ...     @{allowed}=      (?i)vendor bts certificate
    ...     ...              Synchronization lost
    ...     ...              .*BTS booted at.+
    ...     @{mandatory}=    {'faultName': 'Unit blocked', 'faultId': '48', 'severity': 'Major', 'impactedCells': '.*/LNCEL-(?:_[LR])?-1(?:$|\\D).*'}
    ...     ...              {'faultName': 'Unit blocked', 'faultId': '48', 'impactedCells': '.*/LNCEL-(?:_[LR])?-2(?:$|\\D).*'}
    ...     ...              {'alarmDetail': 'Unit blocked', 'alarmSeverity': 'Major', 'impactedCells': '.*/LNCEL(?:_[LR])?-3(?:$|\\D).*'}
    ...     ...              {'faultId': '48', 'alarmSeverity': 'Major', 'impactedCells': '.*/LNCEL(?:_[LR])?-4(?:$|\\D).*'}
    ...     ...              {'faultName': 'Transmission path failure', 'alarmCounter': 3}
    ...     Author:         artur.dobosz@nokia.com
    ...     Maintainer:     Author
    ${out_active_alarms_list}=    admin.Get Active Alarms   alias=${alias}
    Admin Alarms Check    available=${out_active_alarms_list}    allowed=${allowed}    mandatory=${mandatory}

Info Model LCELLs Count In Procedural State Should Be
    [Arguments]    ${cells_count}    ${state}    ${timeout}=5    ${alias}=default
    [Documentation]
    ...  Confirms if given count of ${INFO_MODEL_CELL_NODE_PATH}-* IM nodes contains stateInfo.proceduralState attribute with expected value
    ...     Author:         artur.dobosz@nokia.com
    ...     Maintainer:     Author
    admin_im.query infomodel
    ...  query=count ${INFO_MODEL_CELL_NODE_PATH}-* is [stateInfo.proceduralState=regex"(?i)${state}"]=${cells_count}
    ...  timeout=${timeout}
    ...  alias=${alias}

Info Model Get IP For FR Serial Number
    [Arguments]    ${fr_serial_number}    ${timeout}=5    ${alias}=default
    [Documentation]    Returns IP address of a FR with specified serial number.
    admin_im.query infomodel    query=//EQM_L-1/RMOD_L-* is [serialNumber=${fr_serial_number}, ipAddress=regex"^$|^(?!0\\.0\\.0\\.0$)"]
    ...                                      timeout=${timeout}
    ...                                      alias=${alias}
    ${matched_rmod}=    admin_im.query infomodel      query=get list //EQM_L-1/RMOD_L-* is [serialNumber=${fr_serial_number}]
    ...                                      timeout=${timeout}
    ...                                      alias=${alias}
    ${fr_ip_addr}=      Convert To String    ${matched_rmod[0]['ipAddress']}
    [Return]  ${fr_ip_addr}


Info Model Get RET Nodes List For FR Serial Number
    [Arguments]    ${fr_serial_number}    ${alias}=default
    [Documentation]  Returns list of RET node paths of Info Model //HWTOP_L-1/CABLNK_L-* objects matching RMOD given with serial number and its RETs.
    ...              Maintainer: Author
    ${out_rmod_node}=    Info Model Get Rmod DistName For FR Serial Number    ${fr_serial_number}    alias=${alias}
    ${out_ret_list}=     Create List
    ${out_verdict_1}   ${out_cablnk_node_set}=   Run Keyword And Ignore Error  Info Model Get Cablnk Nodes List Matching Criteria
    ...                                                                        source_dist_name=${out_rmod_node}
    ...                                                                        destination_dist_name=regex".+/RET_L-\\d+/CONNECTOR_L-\\d+"
    ...                                                                        alias=${alias}
    ${out_verdict_2}  ${out_loglink_node_set}=   Run Keyword And Ignore Error  admin_im.query infomodel
    ...   query=get list //HWTOP_L-1/LOGLINK_L-* is [firstEndpointDN=regex"${out_rmod_node}/CONNECTOR_L-\\d+",secondEndpointDN=regex".+/ALD_L-\\d+"]
    ...                                                                        timeout=3
    ...                                                                        alias=${alias}
    ${out_ald_node_set}=  Set Variable If  '${out_verdict_1}'=='PASS'  ${out_cablnk_node_set}   Create List
    ${out_ald_node_set}=  Set Variable If  '${out_verdict_2}'=='PASS'  ${out_loglink_node_set}  Create List
    @{out_ald_list}=    Run Keyword If    '${out_verdict_1}'=='PASS'
    ...                 Extract DestinationDistname List From Cablnk Node List  ${out_ald_node_set}
    ...                 ELSE IF  '${out_verdict_2}'=='PASS'
    ...                 Extract Given Key's Values From Dictionaries' List   secondEndpointDN      ${out_ald_node_set}
    ...                 ELSE     Create List
    @{out_ald_list}=    Run Keyword If    '${out_verdict_1}'=='PASS'
    ...                 Remove Last Node Address Elements From List Of Info Model Distnames  ${out_ald_list}
    ...                 ELSE  Set Variable  @{out_ald_list}
    FOR    ${out_ald_distname}    IN    @{out_ald_list}
       ${out_is_it_ret}=    Run Keyword And Return Status  admin_im.query infomodel  query=${out_ald_distname} is [deviceType=RET]
       ...  timeout=3  alias=${alias}
       Run Keyword If  '${out_is_it_ret}'=='True'  Append To List  ${out_ret_list}  ${out_ald_distname}
    END
    [Return]    ${out_ret_list}

Info Model MHAs From List Should Be Online And Operational
    [Arguments]    ${mha_serial_number_list}    ${timeout}=5    ${alias}=default
    [Documentation]    Keyword iterates through provided list of MHA serial numbers
    ...    and confirms values of attributes for the Info Model node corresponding to each of list's elements.
    FOR    ${out_mha_serial_number}    IN    @{mha_serial_number_list}
        ${out_mha_object}=     Info Model Get MHA Object Name        ${out_mha_serial_number}  alias=${alias}
        ${object_1}=  Set Variable  get list //EQM_L-1/${out_mha_object} is [serialNumber=${out_mha_serial_number}
        ${object_2}=  Set Variable  , stateInfo.availabilityStatus=Online, stateInfo.operationalState=Enabled]
        ${sum_object}=  Set Variable  ${object_1}${object_2}
        admin_im.query infomodel
        ...  query=${sum_object}
        ...  timeout=${timeout}    alias=${alias}
        LOG    + FR's MHA ${out_mha_serial_number} is in Online and Enabled state    console=yes
    END

Info Model Get MHA Object Name
    [Arguments]     ${mha_serial_number}    ${timeout}=5    ${alias}=default
    [Documentation]  Returns IM object name that contains MHA node list (example: MHA_L-* for FL16A, ALD_L-* for FL17SP)
    ...     Author:     michal.szajkowski@nokia.com
    ...     Maintainer: Author
    ${out_ald}=  Run Keyword And Return Status  admin_im.query infomodel    query=get list //EQM_L-1/ALD_L-* is [serialNumber=${mha_serial_number}]
    ...                                                   timeout=${timeout}    alias=${alias}
    ${out_mha}=  Run Keyword And Return Status  admin_im.query infomodel    query=get list //EQM_L-1/MHA_L-* is [serialNumber=${mha_serial_number}]
    ...                                                   timeout=${timeout}    alias=${alias}
    ${out_mha_object_name}=   Set Variable If  ${out_ald}   ALD_L-*
    ${out_mha_object_name}=   Set Variable If  ${out_mha}   MHA_L-*   ${out_mha_object_name}
    [Return]   ${out_mha_object_name}

Create LnaNumber List for MHA Serial Number
    [Arguments]    ${mha_nodes_list}    ${mha_serial_number}
    [Documentation]    Extracts lnaNumber attribute values for a list of InfoModel MHA node objects (dictionaries)
    ...                if they match given MHA serial number.
    ${out_lna_number_list}=    create list
    FOR    ${out_element}    IN    @{mha_nodes_list}
       run keyword if    '${mha_serial_number}'=='${out_element['serNum']}'    append to list    ${out_lna_number_list}    ${out_element['lnaNumber']}
    END
    [Return]    ${out_lna_number_list}

Info Model Get BTS HW Variant
  [Arguments]       ${timeout}    ${alias}=default
  [Documentation]   Returns BTS HW type, for example: "ASIA" or "ABIA" for Airscale and "FSMF" for rel. 3.
  ...     Author:         michal.szajkowski@nokia.com
  ...     Maintainer:     piotr.remlein@nokia.com
  ${bts_hw_parameters}=  admin_im.Get Infomodel Object  //RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-*
  ...  timeout=${timeout}  alias=${alias}
  ${bts_hw_productName}=  Get From Dictionary  ${bts_hw_parameters}  productName
  ${bts_hw_variant}=      Run Keyword IF  "ASIA" in "${bts_hw_productName}"  Set Variable   ASIA
  ...                      ELSE IF        "FSMF" in "${bts_hw_productName}"  Set Variable   FSMF
  ...                      ELSE IF        "ASIB" in "${bts_hw_productName}"  Set Variable   ASIB
  ...                      ELSE IF        "ASIL" in "${bts_hw_productName}"  Set Variable   ASIL
  ...                      ELSE                                              Set Variable    ${None}
  [Return]    ${bts_hw_variant}

Info Model Get Cablnk Nodes List Matching Criteria
  [Arguments]    ${source_dist}    ${destination_dist}=regex".+/(S|R|BB)MOD_L-\\d+/CONNECTOR_L-\\d+"    ${timeout}=5    ${alias}=default
  [Documentation]    Returns list of dictionaries of Info Model //HWTOP_L-1/CABLNK_L-* objects matching given attributes (regexps are accepted):
  ...                sourceDistName=${source_dist}/CONNECTOR_L-\\d+ and destinationDistName=${destination_dist}
  ...                ${destination_dist} has to include "CONNECTOR" regexp, but it is possible to pass there other, comma-separated attributes.
  ${out_matched_cablnks}=  admin_im.query infomodel
  ...  query=get list //HWTOP_L-1/CABLNK_L-* is [sourceDistName=regex"${source_dist}/CONNECTOR_L-\\d+",destinationDistName=${destination_dist}]
  ...                                       timeout=${timeout}
  ...                                       alias=${alias}
  [Return]    ${out_matched_cablnks}

Extract DestinationDistname List From Cablnk Node List
    [Arguments]    ${cablnk_node_set}
    [Documentation]    Retuns list of destinationDistName arguments for given list of Cablnk node objects (dictionaries).
    @{out_node_list}=    Create List
    FOR    ${out_cablnk_node}    IN    @{cablnk_node_set}
       ${out_dist_name}=          Set Variable               ${out_cablnk_node.destinationDistName}
       Append To List    ${out_node_list}    ${out_dist_name}
    END
    [Return]    ${out_node_list}

Extract Given Key's Values From Dictionaries' List
    [Arguments]    ${key}  ${dictioneries_list}
    [Documentation]    Returns a list of values under a given key ${key} from a list of dictionaries.
    ...                Author:     michal.szajkowski@nokia.com
    ...                Maintainer: Author
    @{out_list_of_key_values}=    Create List
    FOR    ${out_dictionary}    IN    @{dictioneries_list}
       ${out_value}=          Set Variable               ${out_dictionary.${key}}
       Append To List    ${out_list_of_key_values}    ${out_value}
    END
    [Return]    ${out_list_of_key_values}

Remove Last Node Address Elements From List Of Info Model Distnames
    [Arguments]    ${im_node_path_list}
    [Documentation]    Takes list of InfoModel node addresses (distnames) and removes last level of each element,
    ...                e.g.: /A-1/B-2/C-3 -> /A-1/B-2
    @{out_node_list}=    Create List
    FOR    ${out_node}    IN    @{im_node_path_list}
       ${out_node_trim}    ${last}=    Split String From Right    ${out_node}    /    1
       Append To List    ${out_node_list}    ${out_node_trim}
    END
    [Return]    ${out_node_list}

Info Model Get Rmod Id For FR Serial Number
    [Arguments]    ${fr_serial_number}    ${timeout}=5    ${alias}=default
    [Documentation]    Returns RMOD_L Id ("x" from "RMOD_L-x") of the first found //EQM_L-1/RMOD_L-* IM node that matches given serial number.
    ${out_rmod_dist_name}=    Info Model Get Rmod DistName For FR Serial Number    ${fr_serial_number}    timeout=${timeout}    alias=${alias}
    ${out_rmod_id}=           should match regexp    ${out_rmod_dist_name}    RMOD_L-(\\d+)
    [Return]    @{out_rmod_id}[1]

Info Model Create Mandatory Alarms List
    [Arguments]    ${lncel_id_list}    ${fault_scheme}   ${attribute_name}=impactedCells
    ...            ${act_category_alarms}=True
    [Documentation]    Maintainer: michal.szajkowski@nokia.com
    ...  Keyword creates list of mandatory alarms for defined lncelId list and fault scheme.
    ...  Arguments:
    ...     lncel_id_list - list of lncelIds
    ...     fault_scheme - dictionary with optional alarmDetail, faultId, alarmSeverity keys.
    ...                    At least one key/value pair other than distName or impactedCells key has to be defined
    ...                    (regex is supported in dictionary values)
    ...     attribute_name - name of attribute used for verification of impacted cells e.g. impactedCells (ratsImpact), alarmingResourceDN
    ...     act_category_alarms - value of parameter actCategoryAlarms in SCFC file.
    ...  Example:
    ...     @{lncel_id_list}=    1    2    3
    ...     ${fault_scheme}=     {'alarmDetail': 'Unit blocked'', 'faultId': '48', 'alarmSeverity': 'Major'}
    @{mandatory_alarms_list}=    Create List
    FOR    ${lncel_id}  IN  @{lncel_id_list}
        ${out_fault_scheme}=  Evaluate  ${fault_scheme}
        Run Keyword If  ${act_category_alarms}
        ...     Set To Dictionary    ${out_fault_scheme}    ${attribute_name}    .*/?LNCEL(?:_[LR])?-${lncel_id}(?:$|\\D).*
        ...               ELSE
        ...     Set To Dictionary    ${out_fault_scheme}    distName    .*/?LNCEL(?:_L)?-${lncel_id}(?:$|\\D).*
       Append To List       ${mandatory_alarms_list}    ${out_fault_scheme}
    END
    [Return]    ${mandatory_alarms_list}


Info Model Wait For Specific RF State RU_L Object
    [Arguments]    ${fr_serial_number}    ${fr_state_to_be_checked}    ${fr_ru_node}=RU_L-*    ${timeout}=360    ${alias}=default
    [Documentation]    author: sebastian.dziewiecki@nokia.com
    ...    Wait for specific rf ru state. Provide rf serial number, state to be checked and ru node (default value is RU_L-*).
    admin_im.query infomodel    //${fr_ru_node} is [serialNumber=${fr_serial_number}, ${fr_state_to_be_checked}]
    ...  timeout=${timeout}    alias=${alias}


Info Model Wait For Specific RF State RMOD_L Object
    [Arguments]    ${fr_serial_number}    ${fr_state_to_be_checked}    ${fr_rmod_node}=RMOD_L-*    ${timeout}=360    ${alias}=default
    [Documentation]    author: sebastian.dziewiecki@nokia.com
    ...    Wait for specific rf rmod state. Provide rf serial number, state to be checked and rmod node (default value is RMOD_L-*).
    admin_im.query infomodel    //${fr_rmod_node} is [serialNumber=${fr_serial_number}, ${fr_state_to_be_checked}]
    ...  timeout=${timeout}    alias=${alias}

Info Model Get LNCEL DistName For Given BtsId And LncelId
    [Arguments]    ${bts_id}    ${lncel_id}    ${timeout}=5    ${alias}=default
    [Documentation]    Returns dist_name of LNBTS for given btsid.
    ${out_lncel_dist_name}=    Info Model Get Attribute Value Of Given Query
    ...     query=//LNBTS_R-${bts_id}//LNCEL_R-${lncel_id}    attribute_name=dist_name    alias=${alias}
    [Return]    ${out_lncel_dist_name}

Info Model Get Attribute Value Of Given Query
    [Arguments]    ${query}    ${attribute_name}    ${timeout}=5    ${alias}=default
    [Documentation]    Returns attribute value of given attribute name and info model query.
    ...   param: Returns            - info model query e.g. //EQM_L-1/RMOD_L-* is [serialNumber=L1110210645]
    ...   param: attribute_name     - name of attribute e.g. dist_name
    ...   param: timeout            - timeout for matching query
    ...   param: alias              - alias for already established Info Model connection
    ...     Author:         artur.dobosz@nokia.com
    ...     Maintainer:     Author
    ${out_matched_node_list}=    admin_im.query infomodel      query=get list ${query}    timeout=${timeout}    alias=${alias}
    [Return]    ${out_matched_node_list[0].${attribute_name}}
