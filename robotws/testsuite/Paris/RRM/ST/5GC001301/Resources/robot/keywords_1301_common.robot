*** Settings ***
Documentation   common keywords for 1301 feature tests
...             AUTHOR (I&V):   Anne Dutheillet        anne.dutheillet@nokia.com
...             Update : 03/02/2022

Library           String
Library           taf.config.scf             WITH NAME    scf

Library           ../../../resources/scf_parameters.py
Library           ../python/coam_parameter.py

Resource          ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource          ../../../resources/sg_radio_perf/robot/Commissioning.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_UE.robot
Resource          ../../../resources/sg_radio_perf/robot/convert_pcap.robot
Resource          ../../../resources/sg_radio_perf/BIP/capture.robot


*** Variables ***
${TIMEOUT_MAKE_SNAPSHOT}=    900
${MAX_WAIT_TIME_COAM_CONFIGURED}     15 min
@{BTS_PROCEDURAL_STATES}           Configured    OnAir   IntegratedToRan


*** Keywords ***
Make Call and ULDL Traffic and Collect Pm files in TestsuiteDir
    [Arguments]     ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE

    ${ue_type_model}=      Keywords_UE.Setup UE      ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=30
    ...        gnb=${gNB}

    Log      Attach UE   console=${DEBUG_MODE_CONSOLE}
    Keywords_UE.Attach UE known Type          ue_type_model=${ue_type_model}     ue_index=${ue_index}
    Sleep          3s

    ${ip_ue}=     run keyword if   '${ue_type_model}'=='QCT' and '${IPERF_VERSION_PREFERENCE}'=='3'
    ...                                                      ue_addr.Get UE IP address
    ...                                                            ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    ...       ELSE        set variable    None
    Log           UE ip = ${ip_ue}       console=${DEBUG_MODE_CONSOLE}


    log          Traffic_duration_s=${duration_s}    console=${DEBUG_MODE_CONSOLE}

    Keywords_UE.Start Process Traffic Simultaneous ULDL UE known Type
    ...      distantip=${ip_ue}
    ...      duration=${duration_s}
    ...      tput_ul=${ul_throughput}
    ...      tput_dl=${dl_throughput}
    ...      ue_type_model=${ue_type_model}
    ...      ueid=${ue_index}

    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=30
    ...        gnb=${gNB}


    ${res}=      Collect PM Files And Get Last Period Filename
    ...          oam_type=coam
    ...          name=gnb_pmcounters
    ...          scope=testsuite

    Log       last period pm file==${res}   console=${DEBUG_MODE_CONSOLE}
    ${res_path}=    set variable    ${OUTPUTDIR}/${SUITENAME}/gnb_pmcounters
    Set Suite Variable      ${PM_PATH}              ${res_path}
    Set Suite Variable      ${PM_FILENAME}          ${res}

    Keywords_UE.Stop Traffic Simultaneous ULDL UE known Type
    ...                  ue_type_model=${ue_type_model}     ueid=${ue_index}


Check gNB and Get reportingIntervalPm Value
    Keywords_gNB.Check gNB State      gNB=0
    ${MeasPeriod}=         Get_Value_reportingIntervalPm       scf_file=${ORIG_SCF[0]}
    log               Reporting Interval=${MeasPeriod}   console=${DEBUG_MODE_CONSOLE}
    set suite variable       ${MeasPeriod}

Update parameter values with delta commissioning for 1301_AA_3
    [Arguments]     ${gnb_id}=${0}
    ${_gNB}     set variable     ${gnb_id}
    Log         _gNB=${_gNB}      console=${DEBUG_MODE_CONSOLE}
    ${d_prachConfigurationIndex}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    prachConfigurationIndex
    ...    value        190
    ${param_list}       Create List
    ...     ${d_prachConfigurationIndex}

    Do json delta commissioning coam
    ...     param_list=${param_list}
    ...     gNB=${gnb_id}
    ...     check_gnb=${False}


Do json delta commissioning coam
    [Documentation]      delta commissioning coam
    ...     :param ${param_list}: list of dictionaries containing parameters and values, which are updated
    ...     :param ${check_gnb}
    ...     :param ${gnb}
    [Arguments]     ${param_list}    ${gNB}=0     ${check_gnb}=${True}
    Keywords_gNB.Create cOAM Session with alias    gnb_id=${gNB}      alias=gnb
    ${update_status}   ${delta_store_file}    Update List of SCF parameters
    ...     parameters=${param_list}
    ...     timeout=600
    ...     alias=gnb
    Log      \ndelta commissioning finished       console=${DEBUG_MODE_CONSOLE}
    #run keyword if    '${gnb}'=='0'     keywordbook-480.synchronize gnb radio
    run keyword if   ${check_gnb} and '${gnb}'=='0'
    ...        keywords_1301_common.Wait GNB0 To Be Onair State And Cells Enabled
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


Perform PreCommissioning For 1301_AA_3
    [Arguments]    ${gNB_id}=${0}
    Update parameter values with delta commissioning for 1301_AA_3    gnb_id=${gNB_id}
    Keywords_gNB.Create cOAM Session with alias    gnb_id=${gNB_id}      alias=coam_admin
    admin.get_current_scf_file     ${OUTPUTDIR}     scf_commissioning_for_1301_AA_3.xml    connection=coam_admin
    ${my_scf}     set variable     ${OUTPUTDIR}/scf_commissioning_for_1301_AA_3.xml
    Add tddFrameStructure 1208 to local scf     local_scf_path=${my_scf}
    Commissioning.Do Commissioning     ${my_scf}     gNB=${gNB_id}
    [Teardown]    Keywords_gNB.Teardown cOAM Session with alias     alias=coam_admin


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

Add tddFrameStructure 1208 to local scf
    [Arguments]       ${local_scf_path}
    scf.Load scf            ${local_scf_path}
    ${_gNB}     set variable   ${0}
    ${tddFrameStructure_exists}=    scf.is_list_in_object
    ...       dist_name=MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...       list_name=tddFrameStructure
    Run keyword if    ${tddFrameStructure_exists}          scf.remove_list_from_scf
    ...       dist_name=MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...       list_name=tddFrameStructure
    ${tddFrameStructure_Dic}    Create Dictionary
    ...      frameStructureType=semiStatic
    ...      guardPeriodLength=2Symbols
    ...      tdLteUlDlConfig=tdLteConfig2
    ...      ulDlDataSlotRatio=1/4
    scf.add_list_to_scf     dist_name=MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...                     list_name=tddFrameStructure
    scf.add item to list    dist_name=MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...                     list_name=tddFrameStructure
    ...                     elements=${tddframeStructure_Dic}
    scf.Save scf        ${local_scf_path}
    Log      tddFrameStructure added to ${local_scf_path}       console=${DEBUG_MODE_CONSOLE}

Verify BTS Procedural State
    [Arguments]    ${alias}=cOAM    ${proceduralStates}=Configured    ${timeout}=30
    [Documentation]  Verify BTS Procedural State and blocking State
    ...     alias:   AdminConnection object or if used, string name alias
    ...     timeout: Time to wait for positive procedure result
    ...     proceduralStates: (string or list) BTS procedural States, opetions=Configured or OnAir or Commissioned
    ${bts_status}=    admin.get_bts_statuses    timeout=${timeout}    connection=${alias}
    List Should Contain Value    ${proceduralStates}    ${bts_status['proceduralState']}
    should be equal    ${bts_status['blockingState']}       Unblocked            ignore_case=true

