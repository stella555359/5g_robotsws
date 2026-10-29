*** Settings ***
Documentation        common keywords for 706
...                  Author:     Anne Dutheillet    anne.dutheillet_lamonthe@nokia.com
...                 Last update : 19.07.2022


Library           taf.config.scf             WITH NAME    scf
Library           ../../../resources/scf_parameters.py
Library           ../../../resources/pm_analyze.py        WITH NAME      pm_analyze
Library           ../python/coam_parameter.py

Resource          ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource          ../../../resources/sg_radio_perf/robot/preconditions.robot
Resource          ../../../resources/sg_radio_perf/robot/Commissioning.robot


*** Variables ***
${TIMEOUT_MAKE_SNAPSHOT}=    900
${MAX_WAIT_TIME_COAM_CONFIGURED}     15 min
@{BTS_PROCEDURAL_STATES}           Configured    OnAir   IntegratedToRan


*** Keywords ***

# Common preconditions definition
# ===============================

TestSuite_6662_Preconditions
	# this is mandatory : retrieve testsuite variables for gNB  !!!!
    preconditions.Setup Testline Suite Variables
	# this is optional : allow to archive ori SCF and/or swconfig, for ALL gnb (or you can select the gnb id/index)
	Run Keyword if      ${source_gnb}==${target_gnb}       preconditions.TestSuite Basic PreConditions
	...                                            archive_gnb_config=${True}   archive_type=all   gnb=${source_gnb}
	Run Keyword if  ${source_gnb}!=${target_gnb}       preconditions.TestSuite Basic PreConditions
	...                                            archive_gnb_config=${True}   archive_type=all   gnb=all
    # this is optional :check gNB, get meas period
    Keywords_gNB.Check gNB State      gNB=${source_gnb}
    Run Keyword If  ${target_gnb} != ${source_gnb}      Keywords_gNB.Check gNB State      gNB=${target_gnb}
    ${MeasPeriod}=         Get_Value_reportingIntervalPm       scf_file=${ORIG_SCF[${source_gnb}]}
    log               Reporting Interval=${MeasPeriod}   console=${DEBUG_MODE_CONSOLE}
    set suite variable       ${MeasPeriod}
    Set Attenuation Channels    ${attenuator_ports_list}        ${attenuator_ports_default}


Perform PreCommissioning For 6662_1_2
    [Arguments]    ${gNB_id}=${0}   ${cell}=${1}

    #bypass robocop
    ${cell}    set variable    ${cell}
    Update parameter values with delta commissioning restf0 for cell1   gnb_id=${gNB_id}
    Update parameter values with delta commissioning restf0 for cell2   gnb_id=${gNB_id}
    Keywords_gNB.Create cOAM Session with alias    gnb_id=${gNB_id}      alias=coam_admin
    admin.get_current_scf_file     ${OUTPUTDIR}     scf_commissioning_for_6662.xml    connection=coam_admin
    ${my_scf}     set variable     ${OUTPUTDIR}/scf_commissioning_for_6662.xml
    Add tddFrameStructure 1070 to cell1 local scf     local_scf_path=${my_scf}
    Add tddFrameStructure 1070 to cell2 local scf     local_scf_path=${my_scf}
    Commissioning.Do Commissioning     ${my_scf}     gNB=${gNB_id}
    [Teardown]    Keywords_gNB.Teardown cOAM Session with alias     alias=coam_admin


Perform PreCommissioning For 6662_3
    [Arguments]    ${gNB_id}=${0}   ${cell}=${1}

    #bypass robocop
    ${cell}    set variable    ${cell}
    Update parameter values with delta commissioning unrestf0 for cell1   gnb_id=${gNB_id}
    Update parameter values with delta commissioning restf0 for cell2   gnb_id=${gNB_id}
    Keywords_gNB.Create cOAM Session with alias    gnb_id=${gNB_id}      alias=coam_admin
    admin.get_current_scf_file     ${OUTPUTDIR}     scf_commissioning_for_6662.xml    connection=coam_admin
    ${my_scf}     set variable     ${OUTPUTDIR}/scf_commissioning_for_6662.xml
    Add tddFrameStructure 1070 to cell1 local scf     local_scf_path=${my_scf}
    Add tddFrameStructure 1070 to cell2 local scf     local_scf_path=${my_scf}
    Commissioning.Do Commissioning     ${my_scf}     gNB=${gNB_id}
    [Teardown]    Keywords_gNB.Teardown cOAM Session with alias     alias=coam_admin


Perform PreCommissioning For 6662_4
    [Arguments]    ${gNB_id}=${0}   ${cell}=${1}

    #bypass robocop
    ${cell}    set variable    ${cell}
    Update parameter values with delta commissioning unrestf0 for cell1   gnb_id=${gNB_id}
    Update parameter values with delta commissioning restf0 for cell3   gnb_id=${gNB_id}
    Keywords_gNB.Create cOAM Session with alias    gnb_id=${gNB_id}      alias=coam_admin
    admin.get_current_scf_file     ${OUTPUTDIR}     scf_commissioning_for_6662.xml    connection=coam_admin
    ${my_scf}     set variable     ${OUTPUTDIR}/scf_commissioning_for_6662.xml
    Add tddFrameStructure 1070 to cell1 local scf     local_scf_path=${my_scf}
    Commissioning.Do Commissioning     ${my_scf}     gNB=${gNB_id}
    [Teardown]    Keywords_gNB.Teardown cOAM Session with alias     alias=coam_admin


Perform PreCommissioning For 6662_5
    [Arguments]    ${gNB_id}=${0}   ${cell}=${1}

    #bypass robocop
    ${cell}    set variable    ${cell}
    Update parameter values with delta commissioning unrestf0 for cell1   gnb_id=${gNB_id}
    Update parameter values with delta commissioning restf1 for cell3   gnb_id=${gNB_id}
    Keywords_gNB.Create cOAM Session with alias    gnb_id=${gNB_id}      alias=coam_admin
    admin.get_current_scf_file     ${OUTPUTDIR}     scf_commissioning_for_6662.xml    connection=coam_admin
    ${my_scf}     set variable     ${OUTPUTDIR}/scf_commissioning_for_6662.xml
    Add tddFrameStructure 1070 to cell1 local scf     local_scf_path=${my_scf}
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


Check gNB and Get reportingIntervalPm Value
    # old name : TestSuite_706_B31_B40_J242_J243_J246_J247_Preconditions
    Keywords_gNB.Check gNB State      gNB=0
    ${MeasPeriod}=         Get_Value_reportingIntervalPm       scf_file=${ORIG_SCF[0]}
    log               Reporting Interval=${MeasPeriod}   console=${DEBUG_MODE_CONSOLE}
    set suite variable       ${MeasPeriod}

# Commissioning
# =============

Update parameter values with delta commissioning restf0 for cell1
    [Arguments]     ${gnb_id}=${0}
    ${_gNB}     set variable     ${gnb_id}
    Log         _gNB=${_gNB}      console=${DEBUG_MODE_CONSOLE}
    ${d_prachConfigurationIndex}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    prachConfigurationIndex
    ...    value        2
    ${d_prachSequenceType}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    prachSequenceType
    ...    value        RestrictedTypeA
    ${d_prachRootSequenceIndex}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    prachRootSequenceIndex
    ...    value        384
    ${d_zeroCorrelation}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    zeroCorrelationZoneConfig
    ...    value        0
    ${param_list}       Create List
    ...     ${d_prachConfigurationIndex}
    ...     ${d_prachSequenceType}
    ...     ${d_prachRootSequenceIndex}
    ...     ${d_zeroCorrelation}

    Do json delta commissioning coam
    ...     param_list=${param_list}
    ...     gNB=${gnb_id}
    ...     check_gnb=${False}


Update parameter values with delta commissioning restf0 for cell2
    [Arguments]     ${gnb_id}=${0}
    ${_gNB}     set variable     ${gnb_id}
    Log         _gNB=${_gNB}      console=${DEBUG_MODE_CONSOLE}
    ${d_prachConfigurationIndex}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-2
    ...    parameter    prachConfigurationIndex
    ...    value        2
    ${d_prachSequenceType}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-2
    ...    parameter    prachSequenceType
    ...    value        RestrictedTypeA
    ${d_prachRootSequenceIndex}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-2
    ...    parameter    prachRootSequenceIndex
    ...    value        384
    ${d_zeroCorrelation}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-2
    ...    parameter    zeroCorrelationZoneConfig
    ...    value        0
    ${param_list}       Create List
    ...     ${d_prachConfigurationIndex}
    ...     ${d_prachSequenceType}
    ...     ${d_prachRootSequenceIndex}
    ...     ${d_zeroCorrelation}

    Do json delta commissioning coam
    ...     param_list=${param_list}
    ...     gNB=${gnb_id}
    ...     check_gnb=${False}

Update parameter values with delta commissioning restf0 for cell3
    [Arguments]     ${gnb_id}=${0}
    ${_gNB}     set variable     ${gnb_id}
    Log         _gNB=${_gNB}      console=${DEBUG_MODE_CONSOLE}
    ${d_prachConfigurationIndex}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-3
    ...    parameter    prachConfigurationIndex
    ...    value        12
    ${d_prachSequenceType}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-3
    ...    parameter    prachSequenceType
    ...    value        RestrictedTypeA
    ${d_prachRootSequenceIndex}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-3
    ...    parameter    prachRootSequenceIndex
    ...    value        384
    ${d_zeroCorrelation}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-3
    ...    parameter    zeroCorrelationZoneConfig
    ...    value        13
    ${param_list}       Create List
    ...     ${d_prachConfigurationIndex}
    ...     ${d_prachSequenceType}
    ...     ${d_prachRootSequenceIndex}
    ...     ${d_zeroCorrelation}

    Do json delta commissioning coam
    ...     param_list=${param_list}
    ...     gNB=${gnb_id}
    ...     check_gnb=${False}


Update parameter values with delta commissioning unrestf0 for cell1
    [Arguments]     ${gnb_id}=${0}
    ${_gNB}     set variable     ${gnb_id}
    Log         _gNB=${_gNB}      console=${DEBUG_MODE_CONSOLE}
    ${d_prachConfigurationIndex}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    prachConfigurationIndex
    ...    value        2
    ${d_prachSequenceType}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    prachSequenceType
    ...    value        Unrestricted
    ${d_prachRootSequenceIndex}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    prachRootSequenceIndex
    ...    value        0
    ${d_zeroCorrelation}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    zeroCorrelationZoneConfig
    ...    value        13
    ${param_list}       Create List
    ...     ${d_prachConfigurationIndex}
    ...     ${d_prachSequenceType}
    ...     ${d_prachRootSequenceIndex}
    ...     ${d_zeroCorrelation}

    Do json delta commissioning coam
    ...     param_list=${param_list}
    ...     gNB=${gnb_id}
    ...     check_gnb=${False}


Update parameter values with delta commissioning restf1 for cell3
    [Arguments]     ${gnb_id}=${0}
    ${_gNB}     set variable     ${gnb_id}
    Log         _gNB=${_gNB}      console=${DEBUG_MODE_CONSOLE}
    ${d_prachConfigurationIndex}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-3
    ...    parameter    prachConfigurationIndex
    ...    value        36
    ${d_prachSequenceType}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-3
    ...    parameter    prachSequenceType
    ...    value        RestrictedTypeA
    ${d_prachRootSequenceIndex}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-3
    ...    parameter    prachRootSequenceIndex
    ...    value        0
    ${d_zeroCorrelation}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-3
    ...    parameter    zeroCorrelationZoneConfig
    ...    value        13
    ${param_list}       Create List
    ...     ${d_prachConfigurationIndex}
    ...     ${d_prachSequenceType}
    ...     ${d_prachRootSequenceIndex}
    ...     ${d_zeroCorrelation}

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
    run keyword if   ${check_gnb} and '${gnb}'=='0'
    ...        keywords_6662_common.Wait GNB0 To Be Onair State And Cells Enabled
    [Teardown]      Keywords_gNB.Teardown cOAM Session with alias     alias=gnb

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


Add tddFrameStructure 1070 to cell1 local scf
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
    ...      ulDlDataSlotRatio=3/7
    scf.add_list_to_scf     dist_name=MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...                     list_name=tddFrameStructure
    scf.add item to list    dist_name=MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...                     list_name=tddFrameStructure
    ...                     elements=${tddframeStructure_Dic}
    scf.Save scf        ${local_scf_path}
    Log      tddFrameStructure added to cell1 ${local_scf_path}       console=${DEBUG_MODE_CONSOLE}

Add tddFrameStructure 1070 to cell2 local scf
    [Arguments]       ${local_scf_path}
    scf.Load scf            ${local_scf_path}
    ${_gNB}     set variable   ${0}
    ${tddFrameStructure_exists}=    scf.is_list_in_object
    ...       dist_name=MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-2
    ...       list_name=tddFrameStructure
    Run keyword if    ${tddFrameStructure_exists}          scf.remove_list_from_scf
    ...       dist_name=MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-2
    ...       list_name=tddFrameStructure
    ${tddFrameStructure_Dic}    Create Dictionary
    ...      frameStructureType=semiStatic
    ...      guardPeriodLength=2Symbols
    ...      tdLteUlDlConfig=tdLteConfig2
    ...      ulDlDataSlotRatio=3/7
    scf.add_list_to_scf     dist_name=MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-2
    ...                     list_name=tddFrameStructure
    scf.add item to list    dist_name=MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-2
    ...                     list_name=tddFrameStructure
    ...                     elements=${tddframeStructure_Dic}
    scf.Save scf        ${local_scf_path}
    Log      tddFrameStructure added to cell2 ${local_scf_path}       console=${DEBUG_MODE_CONSOLE}

Recommission a3MeasRSRP a5MeasNone cell1 cell2
    [Arguments]          ${gNB}=0     ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1/NRHOIF-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=a5MeasEnabled
    ...      operation=update
    ...      value=none
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-2/NRHOIF-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=a5MeasEnabled
    ...      operation=update
    ...      value=none
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

	${name}=      set variable       MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1/NRHOIF-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=a3MeasEnabled
    ...      operation=update
    ...      value=rsrp
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

	${name}=      set variable       MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-2/NRHOIF-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=a3MeasEnabled
    ...      operation=update
    ...      value=rsrp
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s


Recommission a3MeasNone a5MeasRSRP cell1 cell2
    [Arguments]              ${gNB}=0     ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1/NRHOIF-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=a5MeasEnabled
    ...      operation=update
    ...      value=rsrp
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-2/NRHOIF-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=a5MeasEnabled
    ...      operation=update
    ...      value=rsrp
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

	${name}=      set variable       MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1/NRHOIF-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=a3MeasEnabled
    ...      operation=update
    ...      value=none
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

	${name}=      set variable       MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-2/NRHOIF-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=a3MeasEnabled
    ...      operation=update
    ...      value=none
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s


Recommission 4x4_MIMO
    [Arguments]              ${gNB}=0     ${cell_index}=1    ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_index}
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=dlMimoMode
    ...      operation=update
    ...      value=4x4 or 4x2 Open Loop Spatial Multiplexing
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

    ${name}=      set variable       MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_index}
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=actBeamforming
    ...      operation=update
    ...      value=true
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

    ${name}=      set variable       MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_index}
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=nrCellType
    ...      operation=update
    ...      value=4DL2UL
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s


Recommission 2x2 MIMO
    [Arguments]         ${gNB}=0     ${cell_index}=1  ${connection}=coam_admin

     ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_index}
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=dlMimoMode
    ...      operation=update
    ...      value=2x2 Open Loop Spatial Multiplexing
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

    ${name}=      set variable       MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_index}
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=actBeamforming
    ...      operation=update
    ...      value=false
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

    ${name}=      set variable       MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell_index}
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=nrCellType
    ...      operation=update
    ...      value=2DL2UL
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s


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


# Checks counters value
# =====================

Check Cell Counter
    [Documentation]    The purpose of this keyword is to check one PM counter reported by cell
    [Arguments]        ${pid}  ${name}  ${condition}  ${gnb}  ${cell}  ${type}  ${period_id}=1

    ${pi_value}=     pm_analyze.get_pi_value_for_one_cell_from_file
    ...              pi_dir=${PM_PATH_P${period_id}_GNB${gnb}}
    ...              pi_name=${pid}
    ...              file_name=${PM_FILENAME_P${period_id}_GNB${gnb}}
    ...              cell=${cell}
    should be true    ${pi_value}${condition}   msg=${pi_value}${condition} is false for ${name} on ${type} cell${cell}

Check Sum Cell counter
    [Documentation]    The purpose of this keyword is to check the sum of some cell counters
	...                with same pid except the two last digits that are contiguous in a range
    [Arguments]        ${pid_root}  ${begin}   ${end}   ${name}  ${condition}  ${gnb}  ${cell}  ${type}  ${period_id}=1

    ${sum}            Evaluate    0
	:FOR    ${i}      IN RANGE    ${begin}   ${end}
    \   ${j}          Evaluate    '00${i}'[-2:]
	\   ${pi_value}=    pm_analyze.get_pi_value_for_one_cell_from_file
	\   ...             pi_dir=${PM_PATH_P${period_id}_GNB${gnb}}
	\   ...             pi_name=${pid_root}${j}
	\   ...             file_name=${PM_FILENAME_P${period_id}_GNB${gnb}}
	\   ...             cell=${cell}
	\   ${sum}        Evaluate             ${sum} + ${pi_value}
    should be true     ${sum}${condition}       msg=${sum}${condition} is false for ${name} on ${type} cell${cell}

Check Counter
    [Documentation]    The purpose of this keyword is to check one PM counter
    [Arguments]        ${pid}  ${name}  ${condition}  ${gnb}  ${period_id}=1

    ${pi_value}=     pm_analyze.get_pi_value_from_file
    ...              pi_dir=${PM_PATH_P${period_id}_GNB${gnb}}
    ...              pi_name=${pid}
    ...              file_name=${PM_FILENAME_P${period_id}_GNB${gnb}}
    should be true     ${pi_value}${condition}       msg=${pi_value}${condition} is false for ${name} on gNB${gnb}

Check HO Decision A3
    [Documentation]    The purpose of this keyword is to check that event A3 is reported:
    ...                TOT_INTER_FREQ_HO_DECISION_A3 value should be equal to 1 on source cell.
    Check Cell Counter   pid=M55147C00024   name=TOT_INTER_FREQ_HO_DECISION_A3
    ...                  condition===1   gnb=${source_gnb}   cell=${source_cell}   type=source

Check HO Decision A5
    [Documentation]    The purpose of this keyword is to check that event A5 is reported:
    ...                TOT_INTER_FREQ_HO_DECISION_A5 value should be equal to 1 on source cell.
    Check Cell Counter   pid=M55147C00025   name=TOT_INTER_FREQ_HO_DECISION_A5
    ...                  condition===1   gnb=${source_gnb}   cell=${source_cell}   type=source

Check HO IntraDU success
    [Documentation]    The purpose of this keyword is to check that the HO Intra-DU is successfull:
    ...                SUCC_IF_INTRA_DU_HO_SA_PLMN value should be equal to 1 on source cell.
    Check Cell Counter   pid=M55145C00322   name=SUCC_IF_INTRA_DU_HO_SA_PLMN
    ...                  condition===1   gnb=${source_gnb}   cell=${source_cell}   type=source

Check HO IntergNB success
    [Documentation]    The purpose of this keyword is to check that the HO Inter-gNB is successfull:
    ...                SUCC_IC_INTER_GNB_HO_SA_PLMN value should be equal to 1 on target cell.
    Check Cell Counter   pid=M55145C00362   name=SUCC_IC_INTER_GNB_HO_SA_PLMN
    ...                  condition===1   gnb=${target_gnb}   cell=${target_cell}   type=target

Check no unexpected RRC message
    [Documentation]    The purpose of this keyword is to check that we did not receive unexpected RRC messages:
    ...                NRRCC_RRC_RELEASE_SENT value should be equal to 0 on target cell.
    ...                RRC_REESTAB_RECONF_FAILURE, RRC_REESTAB_HO_FAILURE and RRC_REESTAB_OTHER_FAILURE values
    ...                should be equal to 0 on target cell.
    Check Cell Counter   pid=M55124C00001   name=NRRCC_RRC_RELEASE_SENT
    ...                  condition===0   gnb=${target_gnb}   cell=${target_cell}   type=target
    Check Cell Counter   pid=M55124C00503   name=RRC_REESTAB_RECONF_FAILURE
    ...                  condition===0   gnb=${target_gnb}   cell=${target_cell}   type=target
    Check Cell Counter   pid=M55124C00504   name=RRC_REESTAB_HO_FAILURE
    ...                  condition===0   gnb=${target_gnb}   cell=${target_cell}   type=target
    Check Cell Counter   pid=M55124C00505   name=RRC_REESTAB_OTHER_FAILURE
    ...                  condition===0   gnb=${target_gnb}   cell=${target_cell}   type=target

Check external call flow
    [Documentation]    The purpose of this keyword is to check that the external call flow through NG and XN counters:
    ...                NG_PATH_SWITCH_ACK_RECEIVED value should be equal to 1 on target gNB.
    ...                XN_HO_REQ__RECEIVED value should be equal to 1 on target gNB
    ...                XN_HO_REQ_ACK_RECEIVED value should be equal to 1 on source gNB.
    Check Cell Counter   pid=M55125C01501   name=NG_PATH_SWITCH_ACK_RECEIVED
    ...                  condition===1   gnb=${target_gnb}   cell=${target_cell}   type=target
    Check Cell Counter   pid=M55143C00005   name=XN_HO_REQ__RECEIVED
    ...                  condition===1   gnb=${target_gnb}   cell=${target_cell}   type=target
    Check Cell Counter   pid=M55143C00001   name=XN_HO_REQ_ACK_RECEIVED
    ...                  condition===1   gnb=${source_gnb}   cell=${source_cell}   type=source


Check contention based HO
    [Documentation]    The purpose of this keyword is to check that the contention based HO is sucessful:
    ...                RA_COMP_CONT_A_PRMBL value should be equal to 1 on target cell.
    Check Cell Counter   pid=M55306C03001   name=RA_COMP_CONT_A_PRMBL
    ...                  condition=>=1   gnb=${target_gnb}   cell=${target_cell}   type=target

Check contention free HO
    [Documentation]    The purpose of this keyword is to check that the contention free HO is sucessful:
    ...                RA_COMP_DED_PRMBL value should be equal to 1 on target cell.
    Check Cell Counter   pid=M55306C05001   name=RA_COMP_DED_PRMBL
    ...                  condition=>=1   gnb=${target_gnb}   cell=${target_cell}   type=target


Check DL traffic
    [Documentation]   The purpose of keyword is to check that there is no downlink traffic disturbance after the HO:
    ...                DATA_SLOT_PDSCH value should be  greater than X on the target cell.
    ...                For example, for traffic during 30s:
    ...                  X = 30000ms x 123 SLOT_PDSCH / 80ms = 46125 SLOT_PDSCH.
    ...                  123 SLOT_PDSCH is computed according to our SCF configuration:
    ...                         - ulDlDataSlotRatio = 1/4
    ...                         - prachConfigurationIndex = 98
    ...                         - numberOfTransmittedSsBlocks = 1 beam
    ...                         - csirsTrackingPeriod = 80 ms
    Check Cell Counter   pid=M55308C00005   name=DATA_SLOT_PDSCH
    ...                  condition=>=46125   gnb=${target_gnb}   cell=${target_cell}   type=target

Check UL traffic
    [Documentation]    The purpose of keyword is to check that there is no uplink traffic disturbance after the HO:
    ...                DATA_SLOT_PUSCH value should be  greater than X on the target cell.
    ...                For example, for traffic during 30s:
    ...                  X = 30000ms x 28 SLOT_PUSCH / 80ms = 10500 SLOT_PUSCH.
    ...                  28 SLOT_PDSCH is computed according to our SCF configuration:
    ...                         - ulDlDataSlotRatio = 1/4
    ...                         - prachConfigurationIndex = 98
    ...                         - numberOfTransmittedSsBlocks = 1 beam
    ...                         - csirsTrackingPeriod = 80 ms
    Check Cell Counter   pid=M55308C00006   name=DATA_SLOT_PUSCH
    ...                  condition=>=10500   gnb=${target_gnb}   cell=${target_cell}    type=target

Check MIMOXx4 to MIMO2x2
    [Documentation]    The purpose of keyword is to check that MIMO2x2 is well setup after a HO from a cell with MIMO4x4
    ...      The sum of PDSCH_4TX_RI[_01_to_04] value should be greater than X on source cell but equal to 0 on target.
    ...      The sum of PDSCH_2TX_RI[_01_to_02] value should be greater than X on target cell but equal to 0 on source.
    ...      where X is the same as defined in "Check DL traffic" (we assume one grant per PDSCH data slot)
	Check Sum Cell counter	pid_root=M55301C100  begin=1  end=5  name=PDSCH_4TX_RI[_01_to_04]
    ...                condition=>=46125   gnb=${source_gnb}   cell=${source_cell}    type=source
	Check Sum Cell counter	pid_root=M55301C100  begin=1  end=5  name=PDSCH_4TX_RI[_01_to_04]
    ...                condition===0   gnb=${target_gnb}   cell=${target_cell}    type=target
	Check Sum Cell counter	pid_root=M55301C090  begin=1  end=3  name=PDSCH_2TX_RI[_01_to_02]
    ...                condition===0   gnb=${source_gnb}   cell=${source_cell}    type=source
	Check Sum Cell counter	pid_root=M55301C090  begin=1  end=3  name=PDSCH_2TX_RI[_01_to_02]
    ...                condition=>=46125   gnb=${target_gnb}   cell=${target_cell}    type=target

Check CDRX active
    [Documentation]    The purpose of this keyword is to check that the CDRX is active when there is no traffic:
    ...                SLOTS_UE_DRX_ACTIVE value should be greater than 0 on target cell.
    #...                SLOTS_UE_DRX_SLEEP value should be greater than 0 on target cell.
    #...                NRRCC_RRC_RECONF_SENT value should be equal to 1 on target cell

    #pm_analyze.print_from_file  ${pid}
    #...             ${PM_PATH_P${period_id}_GNB${gnb}}
    #...             ${PM_FILENAME_P${period_id}_GNB${gnb}}
    #...             ${cell}

    Check Cell Counter   pid=M55308C11001   name=SLOTS_UE_DRX_ACTIVE
    ...                  condition=>0   gnb=${target_gnb}   cell=${target_cell}    type=target   period_id=2
    #Check Cell Counter   pid=M55308C11002   name=SLOTS_UE_DRX_SLEEP
    #...                  condition=>0   gnb=${target_gnb}   cell=${target_cell}    type=target   period_id=2
    Check Cell Counter   pid=M55124C03001  name=NRRCC_RRC_RECONF_SENT
    ...                  condition===1   gnb=${target_gnb}   cell=${target_cell}    type=target   period_id=1

Check CDRX not active
    [Documentation]    The purpose of this keyword is to check that the CDRX is not active when there is no traffic:
    ...                SLOTS_UE_DRX_ACTIVE value should be equal to 0 on target cell.
    #...                SLOTS_UE_DRX_SLEEP value should be equal to 0 on target cell.
    #...                NRRCC_RRC_RECONF_SENT value should be equal to 0 on target cell
    Check Cell Counter   pid=M55308C11001   name=SLOTS_UE_DRX_ACTIVE
    ...                  condition===0   gnb=${target_gnb}   cell=${target_cell}    type=target   period_id=2
    #Check Cell Counter   pid=M55308C11002   name=SLOTS_UE_DRX_SLEEP
    #...                  condition===0   gnb=${target_gnb}   cell=${target_cell}    type=target   period_id=2
    Check Cell Counter   pid=M55124C03001  name=NRRCC_RRC_RECONF_SENT
    ...                  condition===0   gnb=${target_gnb}   cell=${target_cell}    type=target   period_id=1

# Checks configuration parameters
# ===============================

Check cell config
    [Documentation]    The purpose of this keyword is to check a parameter configuration on one cell:
    [Arguments]        ${parameter}    ${gnb}    ${cell}    ${value}
    scf.load_scf       ${ORIG_SCF[${gnb}]}
    ${scf_value}       scf.get_value_from_scf      p_name=${parameter}
    ...                dist_name=MRBTS-${mrbts_nb[${gnb}]}/NRBTS-${nrbts_nb[${gnb}]}/NRCELL-${cell}
    Should Be Equal As Strings    ${scf_value}     ${value}              ignore_case=True
	 ...    msg=Parameter ${parameter} has not the expected value on cell ${cell} (${scf_value} instead of ${value})

Check cell config not equal
    [Documentation]    The purpose of this keyword is to check a parameter configuration on one cell:
    [Arguments]        ${parameter}    ${gnb}    ${cell}    ${value}
    scf.load_scf       ${ORIG_SCF[${gnb}]}
    ${scf_value}       scf.get_value_from_scf      p_name=${parameter}
    ...                dist_name=MRBTS-${mrbts_nb[${gnb}]}/NRBTS-${nrbts_nb[${gnb}]}/NRCELL-${cell}
    Should Not Be Equal As Strings    ${scf_value}     ${value}              ignore_case=True
	 ...                msg=The parameter ${parameter} has the value ${value} on cell ${cell}

Check source and target cells config
    [Documentation]    Purpose of this keyword is to check a parameter configuration on both source and target cell:
    [Arguments]        ${parameter}    ${source_value}    ${target_value}
    scf.load_scf       ${ORIG_SCF[${source_gnb}]}
    ${scf_value}       scf.get_value_from_scf      p_name=${parameter}
    ...              dist_name=MRBTS-${mrbts_nb[${source_gnb}]}/NRBTS-${nrbts_nb[${source_gnb}]}/NRCELL-${source_cell}
    Should Be Equal As Strings    ${scf_value}     ${source_value}              ignore_case=True
	...      msg=Param ${parameter} has not expected value on source cell (${scf_value} instead of ${source_value})
    Run Keyword if     ${source_gnb}!=${target_gnb}	 scf.load_scf       ${ORIG_SCF[${target_gnb}]}
    ${scf_value}       scf.get_value_from_scf      p_name=${parameter}
    ...              dist_name=MRBTS-${mrbts_nb[${target_gnb}]}/NRBTS-${nrbts_nb[${target_gnb}]}/NRCELL-${target_cell}
    Should Be Equal As Strings    ${scf_value}     ${target_value}              ignore_case=True
	...      msg=Param ${parameter} has not expected value on target cell (${scf_value} instead of ${target_value})

Check cell group config
    [Documentation]    The purpose of this keyword is to check a parameter configuration on the cell group:
    [Arguments]        ${parameter}    ${gnb}    ${cell_group}    ${value}
    scf.load_scf       ${ORIG_SCF[${gnb}]}
    ${scf_value}       scf.get_value_from_scf      p_name=${parameter}
    ...                dist_name=MRBTS-${mrbts_nb[${gnb}]}/NRBTS-${nrbts_nb[${gnb}]}/NRCELLGRP-${cell_group}
    Should Be Equal As Strings    ${scf_value}     ${value}              ignore_case=True
	 ...    msg=Param ${parameter} has not expectedValue on cell group ${cell_group} (${scf_value} instead of ${value})

Check source and target cells have same config
    [Documentation]    Purpose is to check that a parameter has the same configuration on source and target cell:
    [Arguments]        ${parameter}
    scf.load_scf       ${ORIG_SCF[${source_gnb}]}
    ${src_scf_value}   scf.get_value_from_scf      p_name=${parameter}
    ...              dist_name=MRBTS-${mrbts_nb[${source_gnb}]}/NRBTS-${nrbts_nb[${source_gnb}]}/NRCELL-${source_cell}
    Run Keyword if     ${source_gnb}!=${target_gnb}	 scf.load_scf       ${ORIG_SCF[${target_gnb}]}
    ${tgt_scf_value}   scf.get_value_from_scf      p_name=${parameter}
    ...              dist_name=MRBTS-${mrbts_nb[${target_gnb}]}/NRBTS-${nrbts_nb[${target_gnb}]}/NRCELL-${target_cell}
    Should Be Equal As Strings    ${src_scf_value}     ${tgt_scf_value}          ignore_case=True
	...   msg=Param ${parameter} not same value on source cell (${src_scf_value}) and target cell (${tgt_scf_value})

Check two parameters of one cell are different and return the value of first parameter
    [Documentation]    The purpose of this keyword is to compare two parameters configuration on the same cell:
    [Arguments]        ${list1}    ${parameter1}    ${list2}      ${parameter2}    ${gnb}    ${cell}
    scf.load_scf       ${ORIG_SCF[${gnb}]}
    ${param1}          scf.get_value_from_scf      p_name=${parameter1}
    ...                dist_name=MRBTS-${mrbts_nb[${gnb}]}/NRBTS-${nrbts_nb[${gnb}]}/NRCELL-${cell}
    ...                list_name=${list1}
    ${param2}          scf.get_value_from_scf      p_name=${parameter2}
    ...                dist_name=MRBTS-${mrbts_nb[${gnb}]}/NRBTS-${nrbts_nb[${gnb}]}/NRCELL-${cell}
    ...                list_name=${list2}
    Should Not Be Equal As Strings     ${param1}     ${param2}              ignore_case=True
	...         msg=Parameters ${param1} and ${param2} have the same value on cell ${cell}. Test is not significant
	[Return]           ${param1}


Check Config CDRX Source and Target
    [Documentation]    The purpose of this keyword is to check the DRX configuration on both source and target cell:
    ...                actCDrx value should be equal to true or false.
    [Arguments]        ${source_cdrx}    ${target_cdrx}
	Check source and target cells config   parameter=actCDrx   source_value=${source_cdrx}  target_value=${target_cdrx}
	run keyword if     ${source_cdrx}==True      Check cell group config     parameter=actProactUlScheduling
	...                                      gnb=${source_gnb}     cell_group=${source_cell_group}   value=False
	run keyword if     ${target_cdrx}==True     Check cell group config      parameter=actProactUlScheduling
	...                                      gnb=${target_gnb}     cell_group=${target_cell_group}   value=False

Check Config Proactive UL scheduling Source and Target
    [Documentation]    Check the Proactive UL scheduling  configuration on both source and target cell:
    ...                actProactUlScheduling value should be equal to true or false.
    [Arguments]        ${source_cdrx}    ${target_cdrx}
	Check source and target cells config		parameter=actProactUlScheduling
	...                source_value=${source_cdrx}       target_value=${target_cdrx}

Check Config Techno Source and Target
    [Documentation]    Check the technology (TDD or FDD) configuration on both source and target cell:
    ...                cellTechnology value should be equal to FDD or TDD
    [Arguments]        ${source_tech}    ${target_tech}
	Check source and target cells config		parameter=cellTechnology
    ...                source_value=${source_tech}      target_value=${target_tech}

Check Same Config Techno Source and Target
    [Documentation]    Check the technology configuration (TDD or FDD) is the same on source and target cell:
    ...                cellTechnology value shall have the same value
	Check source and target cells have same config 		parameter=cellTechnology

Check Config Bandwidth Source and Target
    [Documentation]    Check the TDD channel bandwidth configuration on both source and target cell:
    ...                chBw value should be equal to 20MHz, 40MHz, 50MHz, 60MHz, 80MHz or 100MHz
    [Arguments]        ${source_bw}    ${target_bw}
	Check source and target cells config     parameter=chBw    source_value=${source_bw}   target_value=${target_bw}

Check Config Band Source and Target
    [Documentation]    The purpose of this keyword is to check the band configuration on both source and target cell:
    ...                freqBandIndicatorNR value should be equal to 78, 71 or 41
    [Arguments]        ${source_band}    ${target_band}
	Check source and target cells config    parameter=freqBandIndicatorNR
	...                source_value=${source_band}   target_value=${target_band}

Check Same Config Band Source and Target
    [Documentation]    Check the band configuration is the same on source and target cell:
    ...                freqBandIndicatorNR value shall have the same value
	Check source and target cells have same config 		parameter=freqBandIndicatorNR

Check Config Contention Target
    [Documentation]    Check the contention based or free configuration on target cell:
    ...                cbraPreamblesPerSsb value should be equal to n64 (contention based) or n32 (contention free)
    [Arguments]        ${target_cont}
    scf.load_scf       ${ORIG_SCF[${target_gnb}]}
    ${scf_value}       scf.get_value_from_scf      p_name=cbraPreamblesPerSsb
    ...             dist_name=MRBTS-${mrbts_nb[${target_gnb}]}/NRBTS-${nrbts_nb[${target_gnb}]}/NRCELL-${target_cell}
    Should Be Equal As Strings    ${scf_value}     ${target_cont}              ignore_case=True
	...   msg=Param cbraPreamblesPerSsb has not expected value on target cell (${scf_value} instead of ${target_cont})

Check HO algorithm
    [Documentation]    The purpose of this keyword is to check the HO algorithm (A3/A5) configuration on source cell:
    ...                for A3 algorithm, a3MeasEnabled value should be different of none
    ...                for A5 algorithm, a5MeasEnabled value should be different of none
    [Arguments]        ${source_ho_algo}
	Should Contain   <A3><A5>    <${source_ho_algo}>   msg=Scenario error: source_ho_algo should be equal to A3 or A5
    scf.load_scf       ${ORIG_SCF[${source_gnb}]}
    ${a3_value}        scf.get_value_from_scf      p_name=a3MeasEnabled
    ...    dist_name=MRBTS-${mrbts_nb[${source_gnb}]}/NRBTS-${nrbts_nb[${source_gnb}]}/NRCELL-${source_cell}/NRHOIF-${nrhoif_id}
    ${a5_value}        scf.get_value_from_scf      p_name=a5MeasEnabled
    ...    dist_name=MRBTS-${mrbts_nb[${source_gnb}]}/NRBTS-${nrbts_nb[${source_gnb}]}/NRCELL-${source_cell}/NRHOIF-${nrhoif_id}
    Run Keyword if     '${source_ho_algo}'=='A5'
	...        Should Be True  '${a5_value}'!='none'  msg=A5 config not correct: a5MeasEnabled is equal to ${a5_value}
    Run Keyword if     '${source_ho_algo}'=='A3'
	...        Should Be True  '${a3_value}'!='none'  msg=A3 config not correct: a3MeasEnabled is equal to ${a3_value}

Check Config MIMO Source and Target
    [Documentation]    The purpose of this keyword is to check the MIMO configuration on both source and target cell:
    ...                nrCellType value should be equal to 2DL2UL or 4DL2UL.
    [Arguments]        ${source_mimo}    ${target_mimo}
	Should Contain	   <2DL2UL><4DL2UL>		<${source_mimo}>
	...          msg=Scenario error: source_mimo should be equal to 2DL2UL or 4DL2UL
	Should Contain	   <2DL2UL><4DL2UL>		<${target_mimo}>
	...          msg=Scenario error: target_mimo should be equal to 2DL2UL or 4DL2UL
	Check source and target cells config
	...          parameter=nrCellType   source_value=${source_mimo}   target_value=${target_mimo}

Verify BTS Procedural State
    [Arguments]    ${alias}=cOAM    ${proceduralStates}=Configured    ${timeout}=30
    [Documentation]  Verify BTS Procedural State and blocking State
    ...     alias:   AdminConnection object or if used, string name alias
    ...     timeout: Time to wait for positive procedure result
    ...     proceduralStates: (string or list) BTS procedural States, opetions=Configured or OnAir or Commissioned
    ${bts_status}=    admin.get_bts_statuses    timeout=${timeout}    connection=${alias}
    List Should Contain Value    ${proceduralStates}    ${bts_status['proceduralState']}
    should be equal    ${bts_status['blockingState']}       Unblocked            ignore_case=true
