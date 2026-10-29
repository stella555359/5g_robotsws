*** Settings ***
Documentation   common keywords EDA 50890
...             AUTHOR (I&V):   nathalie.caudy@nokia.com
...             creation : 07/07/2022

Library           String
Library           taf.config.scf             WITH NAME    scf

Library           ../../../resources/scf_parameters.py
Library           ../python/coam_parameter.py

Resource          ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource          ../../../resources/sg_radio_perf/robot/Commissioning.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_UE.robot

*** Variables ***
${TIMEOUT_MAKE_SNAPSHOT}=    900
${MAX_WAIT_TIME_COAM_CONFIGURED}     15 min
@{BTS_PROCEDURAL_STATES}           Configured    OnAir   IntegratedToRan


*** Keywords ***

Check gNB and Get reportingIntervalPm Value
    Keywords_gNB.Check gNB State      gNB=0
    ${MeasPeriod}=         Get_Value_reportingIntervalPm       scf_file=${ORIG_SCF[0]}
    log               Reporting Interval=${MeasPeriod}   console=${DEBUG_MODE_CONSOLE}
    set suite variable       ${MeasPeriod}

Update parameter values with delta commissioning for EDA
    [Arguments]     ${gnb_id}=${0}
    ${_gNB}     set variable     ${gnb_id}
    Log         _gNB=${_gNB}      console=${DEBUG_MODE_CONSOLE}
    ${d_actFdmEnhancedScheduling}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}
    ...    parameter    actFdmEnhancedScheduling
    ...    value        true
    ${d_actSpatialStreamPooling}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}
    ...    parameter    actSpatialStreamPooling
    ...    value        false
	
    ${param_list}       Create List
    ...     ${d_actFdmEnhancedScheduling}
    ...     ${d_actSpatialStreamPooling}

    keywords_EDA50890_common.Do json delta commissioning coam
    ...     param_list=${param_list}
    ...     gNB=${gnb_id}
    ...     check_gnb=${True}


Do json delta commissioning coam
    [Documentation]      delta commissioning coam
    ...     :param ${param_list}: list of dictionaries containing parameters and values, which are updated
    ...     :param ${check_gnb}
    ...     :param ${gnb}
    [Arguments]     ${param_list}    ${gNB}=0     ${check_gnb}=${True}
    Keywords_gNB.Create cOAM Session with alias    gnb_id=${gNB}      alias=gnb
    Log      \ndelta commissioning started        console=${DEBUG_MODE_CONSOLE}
    ${update_status}   ${delta_store_file}    Update List of SCF parameters
    ...     parameters=${param_list}
    ...     timeout=600
    ...     alias=gnb
    Log      \ndelta commissioning finished       console=${DEBUG_MODE_CONSOLE}
    run keyword if   ${check_gnb} and '${gnb}'=='0'
    ...        keywords_EDA50890_common.Wait GNB0 To Be Onair State And Cells Enabled
    [Teardown]      Keywords_gNB.Teardown cOAM Session with alias     alias=gnb


Wait GNB0 To Be Onair State And Cells Enabled
    [Documentation]     on classical gnb check and wait, that all created cells are enabled
    Keywords_gNB.Create cOAM Session with alias    gnb_id=0      alias=gnb
    ${scf_content}     admin.get_current_scf_content    connection=gnb    timeout=${30}
    ${list_cells}      string.Get Regexp Matches    ${scf_content}    class="com.nokia.srbts.nrbts:NRCELL"
    ${num_of_cells}    collections.Count Values In List  ${list_cells}   class="com.nokia.srbts.nrbts:NRCELL"
    Wait until keyword succeeds     1200 sec      20 sec
    ...     Compare number of enabled cells with number of cells with coam     ${num_of_cells}
    [Teardown]   Keywords_gNB.Teardown cOAM Session with alias     alias=gnb


Compare number of enabled cells with number of cells with coam
    [Documentation]    [PRIVATE]   on classical gnb verify if all created cells are enabled
    ...     :Autor: Sylvia Schneider
    ...     :param ${num_of_cells}: number of created cells
    [Arguments]     ${num_of_cells}
    BuiltIn.Log To Console     .   no_newline=true
    @{cell_status}=     admin.get_cells_info     connection=gnb
    ${num_of_enabled_cells}    set variable   ${0}
    FOR    ${index}    IN RANGE    ${num_of_cells}
        &{temp}    set variable  ${cell_status}[${index}]
        &{temp1}    get from dictionary    ${temp}    status
        Dictionary should contain item    ${temp1}    operationalState      Enabled
        ${num_of_enabled_cells}    Evaluate             ${num_of_enabled_cells}+1
    END
    Should Be True   '${num_of_cells}'=='${num_of_enabled_cells}'    msg=${num_of_enabled_cells} Cell(s) of ${num_of_cells} Enabled


Perform PreCommissioning For EDA
    [Arguments]    ${gNB_id}=${0}
    Update parameter values with delta commissioning for EDA    gnb_id=${gNB_id}

Get SCF Values from current xml file
    [Arguments]  ${parameters}     ${check_value}=${False}     ${config_type}=configuration    ${alias}=cOAM
    [Documentation]     Gets values from current xml file,
    ...     config_type: configuration, configurationAndRuntimeObjects or runtimeObjects
    ...     parameters: list of dicts, examples are mentioend below.
    ...       parameters = [ {'dist_name': None, 'parameter':'btsName', 'value':'Automation_Testing'},
    ...                     {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCgiPlmnId',
    ...                     'value':[{'mcc':'262','mnc':'3', "mncLength":'2'}]},
    ...                     {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCellId', 'value':'32765'},
    ...                     {'dist_name': 'NRBTS-1/NRDU-1', 'parameter':'refNrCellGroup', 'value':['0']},
    ...                     {'dist_name': 'MNL-1/MNLENT-2/SYNC-1/CLOCK-1/TOP-1/TOPP-1', 'parameter':'topMasterList',
    ...                     value':[{'masterIpAddr':None}], p_index=1}
    ...                    ]
    ...     check_value= ${True}: verify parameter values if not ${False}:
    ...     alias:   AdminConnection object or if used, string name alias
    ...     return:  list of dicts with current values
    ...  author:        venkata.rajesh@nokia.com
    ...  modified by:   <22-MAY-2019>, <verajesh>, <e.g. PR-Number, feature number>
    ${param_values}=     coam_parameter.get_list_values_from_scf_file       local_dir_path=${None}
    ...       parameters=${parameters}    check_value=${check_value}       connection=${alias}  config_type=${config_type}
    [Return]   ${param_values}

Update List of SCF parameters
    [Arguments]   ${parameters}=${None}       ${timeout}=60     ${alias}=cOAM
    [Documentation]     Update list of  SCF parameters
    ...   parameters: List of dicts.
    ...    examples are below.
    ...       parameter = [ {'dist_name': None, 'parameter':'btsName', 'value':'Automation_Testing'},
    ...                     {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCgiPlmnId',
    ...                     'value':[{'mcc':'262','mnc':'3', "mncLength":'2'}]},
    ...                     {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCellId', 'value':'32765'},
    ...                     {'dist_name': 'NRBTS-1/NRDU-1', 'parameter':'refNrCellGroup', 'value':['0']}
    ...                    ]
    ...   timeout: Time to wait for positive procedure result
    ...   alias:   AdminConnection object or if used, string name alias
    ...   return:  raise exception if recommission failed, PASS - online parameter update
    ...            RESET_PASS - parameter update is successful and BTS is going to trigger reset
    ...    and reverse delta JSON path.
    ...  author:        venkata.rajesh@nokia.com
    ...  modified by:   <22-MAY-2019>, <verajesh>, <e.g. PR-Number, feature number>
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     Verify BTS Procedural State   alias=${alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${alias}
    ${update_status}=   coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}
    ...    timeout=${timeout}     connection=${alias}
    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s     Verify BTS Procedural State   alias=${alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}
    Get SCF Values from current xml file     parameters=${parameters}     check_value=${True}     alias=${alias}
    [Return]   ${update_status}       ${delta_file['reverse']}

Verify BTS Procedural State
    [Arguments]    ${alias}=cOAM    ${proceduralStates}=Configured    ${timeout}=30
    [Documentation]  Verify BTS Procedural State and blocking State
    ...     alias:   AdminConnection object or if used, string name alias
    ...     timeout: Time to wait for positive procedure result
    ...     proceduralStates: (string or list) BTS procedural States, opetions=Configured or OnAir or Commissioned
    ${bts_status}=    admin.get_bts_statuses    timeout=${timeout}    connection=${alias}
    List Should Contain Value    ${proceduralStates}    ${bts_status['proceduralState']}
    should be equal    ${bts_status['blockingState']}       Unblocked            ignore_case=true

