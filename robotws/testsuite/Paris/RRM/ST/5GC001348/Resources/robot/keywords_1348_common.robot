*** Settings ***
Documentation        common keywords for 1348
...                  Author:     Annie Wong         annie.wong@nokia.com
...                              Florence Thepot    florence.thepot@nokia.com
...                              Pape Diallo        pape.diallo@nokia.com
...                 Last update : 27.05.21  change ue ip retrieval for airmosaic ue
...                                         use new keywords from Keywords_UE.robot
...                               31/05.21  add J003 J004 and J005 code
...                               11/06/21  update tti containerization

Library          OperatingSystem
Library          Collections
Library          String

#deprecated: Library     taf.gnb.oam coam.admin      WITH NAME       admin
#(library : taf.sbts.oam.coam.admin  as  admin, import done in Commissioning.robot)

Library           taf.config.scf             WITH NAME    scf
Library           ../python/Parsing_L1L2_Traces_for_PUCCH_and_PUSCH_1348.py
Library           ../python/Count_AckNack.py
Library           ../../../resources/scf_parameters.py
Library           ../../../resources/pm_analyze.py        WITH NAME      pm_analyze
Library           ../../../resources/Tti_Trace.py
Library           ../python/coam_parameter.py

Resource          ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource          ../../../resources/sg_radio_perf/robot/Commissioning.robot
Resource          ../../../resources/sg_radio_perf/robot/Keywords_UE.robot
Resource          ../../../resources/sg_radio_perf/robot/convert_pcap.robot
Resource          ../../../resources/sg_radio_perf/BIP/capture.robot

#Resource          keywordbook-480.robot

*** Variables ***
${TIMEOUT_MAKE_SNAPSHOT}=    900
${MAX_WAIT_TIME_COAM_CONFIGURED}     15 min
@{BTS_PROCEDURAL_STATES}           Configured    OnAir   IntegratedToRan

*** Keywords ***
Check gNB and Get reportingIntervalPm Value
    [Arguments]           ${gNB}=0
    Keywords_gNB.Check gNB State      gNB=${gNB}
    ${MeasPeriod}=         Get_Value_reportingIntervalPm       scf_file=${ORIG_SCF[${gNB}]}
    log               Reporting Interval=${MeasPeriod}   console=${DEBUG_MODE_CONSOLE}
    set suite variable       ${MeasPeriod}


Get reportingIntervalPm Value
    [Arguments]           ${gNB}=0
    ${MeasPeriod}=         Get_Value_reportingIntervalPm       scf_file=${ORIG_SCF[${gNB}]}
    log               Reporting Interval=${MeasPeriod}   console=${DEBUG_MODE_CONSOLE}
    set suite variable       ${MeasPeriod}

Recommission actPrachMultiplexing CELL1
    [Arguments]            ${value}=true      ${gNB}=0     ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=actPrachMultiplexing
    ...      operation=update
    ...      value=${value}
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s


Recommission actFdmScheduling
    [Arguments]       ${value}=true      ${gNB}=0     ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=actFdmScheduling
    ...      operation=update
    ...      value=${value}
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s


Recommission prachConfigurationIndex98 CELL1
    [Arguments]          ${gNB}=0     ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=prachConfigurationIndex
    ...      operation=update
    ...      value=98
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s


Recommission prachConfigurationIndex93 CELL1
    [Arguments]          ${gNB}=0     ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=prachConfigurationIndex
    ...      operation=update
    ...      value=93
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

Recommission prachConfigurationIndex148 CELL1
    [Arguments]          ${gNB}=0     ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=prachConfigurationIndex
    ...      operation=update
    ...      value=148
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s


Recommission msg1FrequencyStart CELL1
    [Arguments]      ${value}=0     ${gNB}=0     ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=msg1FrequencyStart
    ...      operation=update
    ...      value=${value}
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s


Recommission actBeamforming CELL1
    [Arguments]     ${value}=true     ${gNB}=0     ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=actBeamforming
    ...      operation=update
    ...      value=${value}
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

Recommission basicBeamSet CELL1
    [Arguments]     ${value}=beamSet_1     ${gNB}=0     ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=basicBeamSet
    ...      operation=update
    ...      value=${value}
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

Recommission numberOfRxBeamforming CELL1
    [Documentation]    value: [2Rx,4Rx]
    [Arguments]        ${value}=2Rx     ${gNB}=0     ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=numberOfRxBeamforming
    ...      operation=update
    ...      value=${value}
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

Recommission actFdmEnhancedScheduling
    [Arguments]     ${value}=false      ${gNB}=0     ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=actFdmEnhancedScheduling
    ...      operation=update
    ...      value=${value}
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

Recommission pucchModeSelect CELL1
    [Documentation]    value: [shortpucch,longPucch]
    [Arguments]        ${value}=shortpucch     ${gNB}=0     ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=pucchModeSelect
    ...      operation=update
    ...      value=${value}
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

Recommission actPerCsiReportBundlingTddFr1 CELL1
    [Documentation]    value: [false,true]
    [Arguments]        ${value}=false     ${gNB}=0     ${connection}=coam_admin
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-1
    admin.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=actPerCsiReportBundlingTddFr1
    ...      operation=update
    ...      value=${value}
    ...      skip_parameter_relation_errors=True
    ...      should_activate=True
    ...      connection=${connection}
    sleep                 2s

# new commissioning code:
Perform PreCommissioning For J003
    [Arguments]     ${gnb_id}=${0}
    Update parameter values with delta commissioning coam for J003    gnb_id=${gnb_id}
    Add beamSet beamSet_2      gnb_id=${gnb_id}

Perform PreCommissioning For J004 and J005
    [Arguments]     ${gnb_id}=${0}
    Update parameter values with delta commissioning coam for J004 and J005    gnb_id=${gnb_id}
    Add beamSet beamSet_2      gnb_id=${gnb_id}

Add beamSet beamSet_2
    [Arguments]     ${gnb_id}=${0}
    Keywords_gNB.Create cOAM Session with alias    gnb_id=${gnb_id}      alias=coam_admin
    admin.get_current_scf_file    ${OUTPUTDIR}     scf_commissioning_before_updateBeamSet.xml    connection=coam_admin
    scf.Load scf                  ${OUTPUTDIR}/scf_commissioning_before_updateBeamSet.xml
    ${_gNB}     set variable   ${gnb_id}
    ${beamSet_exists}=    scf.is_list_in_object
    ...       dist_name=MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1      list_name=beamSet
    Run keyword if    ${beamSet_exists}          scf.remove_list_from_scf
    ...       dist_name=MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1      list_name=beamSet
    ${beamSet_Dic}    Create Dictionary
    ...      basicBeamSet=beamSet_2
    ...      leftEdgeAngle=${60}
    ...      lowerEdgeAngle=${120}
    ...      nrBtsBeamRefinementP2=false
    ...      rightEdgeAngle=${60}
     ...     upperEdgeAngle=${60}
    scf.add_list_to_scf     dist_name=MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1  list_name=beamSet
    scf.add item to list    dist_name=MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1  list_name=beamSet
    ...                      elements=${beamSet_Dic}
    scf.Save scf        ${OUTPUTDIR}/scf_commissioning_after_updateBeamSet.xml
    BuiltIn.Log To Console    \nBeamSet commissioning started
    Commissioning.Do Commissioning      ${OUTPUTDIR}/scf_commissioning_after_updateBeamSet.xml     gNB=${gnb_id}


Update parameter values with delta commissioning coam for J003
    [Arguments]     ${gnb_id}=${0}
    ${_gNB}     set variable     ${gnb_id}
    Log         _gNB=${_gNB}      console=${DEBUG_MODE_CONSOLE}
    ${d_actPrachMultiplexing_CELL1}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    actPrachMultiplexing
    ...    value        true
    ${d_actFdmScheduling}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}
    ...    parameter    actFdmScheduling
    ...    value        true
    ${d_prachConfigurationIndex_CELL1}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    prachConfigurationIndex
    ...    value        98
    ${d_msg1FrequencyStart_CELL1}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    msg1FrequencyStart
    ...    value        0
    ${d_actFdmEnhancedScheduling}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}
    ...    parameter    actFdmEnhancedScheduling
    ...    value        false
    ${d_actBeamforming_CELL1}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    actBeamforming
    ...    value        true
    ${d_numberOfRxBeamforming_CELL1}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    numberOfRxBeamforming
    ...    value        2Rx
    ${d_nrCellType_CELL1}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    nrCellType
    ...    value        4DL4UL
    ${d_numberOfTransmittedSsBlocks_CELLGRP0}    create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELLGRP-0
    ...    parameter    numberOfTransmittedSsBlocks
    ...    value        2 beams
    ${d_numberOfTransmittedSsBlocks_NRHOIF1}    create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1/NRHOIF-1
    ...    parameter    numberOfTransmittedSsBlocks
    ...    value        2 beams
    ${d_numberOfTransmittedSsBlocks_NRIAFIM1}    create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRSYSINFO_PROFILE-1/NRIAFIM-1
    ...    parameter    numberOfTransmittedSsBlocks
    ...    value        2 beams
    ${d_numberOfTransmittedSsBlocks_NRIRFIM1}    create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRSYSINFO_PROFILE-1/NRIRFIM-1
    ...    parameter    numberOfTransmittedSsBlocks
    ...    value        2 beams
    ${param_list}       Create List
    ...     ${d_actPrachMultiplexing_CELL1}
    ...     ${d_actFdmScheduling}
    ...     ${d_prachConfigurationIndex_CELL1}
    ...     ${d_msg1FrequencyStart_CELL1}
    ...     ${d_actFdmEnhancedScheduling}
    ...     ${d_actBeamforming_CELL1}
    ...     ${d_numberOfRxBeamforming_CELL1}
    ...     ${d_nrCellType_CELL1}
    ...     ${d_numberOfTransmittedSsBlocks_CELLGRP0}
    ...     ${d_numberOfTransmittedSsBlocks_NRHOIF1}
    ...     ${d_numberOfTransmittedSsBlocks_NRIAFIM1}
    ...     ${d_numberOfTransmittedSsBlocks_NRIRFIM1}
    keywords_1348_common.Do json delta commissioning coam      param_list=${param_list}   gNB=${gnb_id}


Update parameter values with delta commissioning coam for J004 and J005
    [Arguments]     ${gnb_id}=${0}
    ${_gNB}     set variable     ${gnb_id}
    Log         _gNB=${_gNB}      console=${DEBUG_MODE_CONSOLE}
    ${d_actPrachMultiplexing_CELL1}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    actPrachMultiplexing
    ...    value        true
    ${d_actFdmScheduling}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}
    ...    parameter    actFdmScheduling
    ...    value        true
    ${d_prachConfigurationIndex_CELL1}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    prachConfigurationIndex
    ...    value        93
    ${d_msg1FrequencyStart_CELL1}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    msg1FrequencyStart
    ...    value        0
    ${d_actFdmEnhancedScheduling}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}
    ...    parameter    actFdmEnhancedScheduling
    ...    value        false
    ${d_actBeamforming_CELL1}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    actBeamforming
    ...    value        true
    ${d_numberOfRxBeamforming_CELL1}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    numberOfRxBeamforming
    ...    value        2Rx
    ${d_nrCellType_CELL1}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    nrCellType
    ...    value        4DL4UL
    ${d_numberOfTransmittedSsBlocks_CELLGRP0}    create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELLGRP-0
    ...    parameter    numberOfTransmittedSsBlocks
    ...    value        2 beams
    ${d_numberOfTransmittedSsBlocks_NRHOIF1}    create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1/NRHOIF-1
    ...    parameter    numberOfTransmittedSsBlocks
    ...    value        2 beams
    ${d_numberOfTransmittedSsBlocks_NRIAFIM1}    create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRSYSINFO_PROFILE-1/NRIAFIM-1
    ...    parameter    numberOfTransmittedSsBlocks
    ...    value        2 beams
    ${d_numberOfTransmittedSsBlocks_NRIRFIM1}    create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRSYSINFO_PROFILE-1/NRIRFIM-1
    ...    parameter    numberOfTransmittedSsBlocks
    ...    value        2 beams
    ${param_list}       Create List
    ...     ${d_actPrachMultiplexing_CELL1}
    ...     ${d_actFdmScheduling}
    ...     ${d_prachConfigurationIndex_CELL1}
    ...     ${d_msg1FrequencyStart_CELL1}
    ...     ${d_actFdmEnhancedScheduling}
    ...     ${d_actBeamforming_CELL1}
    ...     ${d_numberOfRxBeamforming_CELL1}
    ...     ${d_nrCellType_CELL1}
    ...     ${d_numberOfTransmittedSsBlocks_CELLGRP0}
    ...     ${d_numberOfTransmittedSsBlocks_NRHOIF1}
    ...     ${d_numberOfTransmittedSsBlocks_NRIAFIM1}
    ...     ${d_numberOfTransmittedSsBlocks_NRIRFIM1}
    keywords_1348_common.Do json delta commissioning coam      param_list=${param_list}   gNB=${gnb_id}

Update parameter values with delta commissioning for 1348-14
    [Arguments]     ${gnb_id}=${0}
    ${_gNB}     set variable     ${gnb_id}
    Log         _gNB=${_gNB}      console=${DEBUG_MODE_CONSOLE}
    ${d_actPrachMultiplexing}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    actPrachMultiplexing
    ...    value        true
    ${d_actFdmScheduling}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}
    ...    parameter    actFdmScheduling
    ...    value        true
    ${d_actBeamforming}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    actBeamforming
    ...    value        false
    ${d_prachConfigurationIndex}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    prachConfigurationIndex
    ...    value        98
    ${d_msg1FrequencyStart}      create dictionary
    ...    dist_name    MRBTS-${MRBTS_NB[${_gNB}]}/NRBTS-${NRBTS_NB[${_gNB}]}/NRCELL-1
    ...    parameter    msg1FrequencyStart
    ...    value        0

    ${param_list}       Create List
    ...     ${d_actPrachMultiplexing}
    ...     ${d_actFdmScheduling}
    ...     ${d_actBeamforming}
    ...     ${d_prachConfigurationIndex}
    ...     ${d_msg1FrequencyStart}

    Do json delta commissioning coam
    ...     param_list=${param_list}
    ...     gNB=${gnb_id}
    ...     check_gnb=${False}

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


#Do json delta commissioning coam
#    [Documentation]      delta commissioning coam
#   ...     :param ${param_list}: list of dictionaries containing parameters and values, which are updated
#   [Arguments]     ${param_list}    ${gNB}=${0}
#   Keywords_gNB.Create cOAM Session with alias    gnb_id=${gNB}      alias=gnb
#   Log      \ndelta commissioning started        console=${DEBUG_MODE_CONSOLE}
#    ${update_status}    ${delta_store_file}    Update List of SCF parameters
#    ...    parameters=${param_list}    timeout=600    alias=gnb
#    Keywords_gNB.Teardown cOAM Session with alias     alias=gnb
#   Log      \ndelta commissioning finished       console=${DEBUG_MODE_CONSOLE}
    #the keyword is only defined for gNB0 ! (either comment the code?)
   # run keyword if    '${gnb}'=='0'     keywordbook-480.synchronize gnb radio
#    wait gNB to be onair state and cells enabled     gnb_id=${gNB}

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
    ...        keywords_1348_common.wait gNB to be onair state and cells enabled
    [Teardown]      Keywords_gNB.Teardown cOAM Session with alias     alias=gnb


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

wait gNB to be onair state and cells enabled
    [Documentation]     on classical gnb check and wait, that all created cells are enabled
    [Arguments]         ${gnb_id}=${0}
    Keywords_gNB.Create cOAM Session with alias    gnb_id=${gnb_id}      alias=gnb
    ${scf_content}     admin.get_current_scf_content    connection=gnb       timeout=${30}
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


1348 A14 A20 with call and UL traffic and Collect Pm in TestSuiteDir
    [Documentation]    The purpose of this keyword is :
    ...                 - reserve UE
    ...                 - attach UE
    ...                 - Start traffic UL
    ...                 - Wait at least 1 full meas period
    ...                 - detach UE
    ...                 - collect PM files at end of current meas period
    ...   Please take note that test suite variable ${PM_FILENAME} and ${PM_PATH} are set

    [Arguments]         ${tput_ul}=200M     ${duration}=3000
    ...                 ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE

    #Setup UE            ue_index=${ue_index}    ue_capabilities=${ue_capabilities}
    ${ue_model}=        Keywords_UE.Setup UE      ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    Log         Attach UE (2 tries)    console=${DEBUG_MODE_CONSOLE}
    #${passed}       Run Keyword and return status        Start UE attach     ue_index=${ue_index}
    #Run keyword unless      ${passed}      Start UE attach     ue_index=${ue_index}
    ${passed}       Run Keyword and return status      Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}
    Run keyword If     ${passed} == ${False}     Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}

    sleep   40s

    ${ip_ue}=     run keyword if   '${ue_model}'=='QCT'       ue_addr.Get UE IP address
    ...                                                            ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    Log        UE ip = ${ip_ue}      console=${DEBUG_MODE_CONSOLE}

    #Start Process TrafficUL    distantip=${ip_ue}   tput=${tput_ul}   duration=${duration}   ueid=${ue_index}
    Start Process TrafficUL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${duration}
    ...           tput=${tput_ul}
    ...           ue_type_model=${ue_model}
    ...           ueid=${ue_index}

    Sleep   10s

    # wait that period is finished to collect PM files
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=30
    ...        gnb=${gNB}

    Keywords_UE.Stop TrafficUL UE known Type      ue_type_model=${ue_model}     ueid=${ue_index}

    Log    Detach UE    console=${DEBUG_MODE_CONSOLE}
    #Release UE          ue_index=${ue_index}
    Keywords_UE.Release UE known Type     ue_type_model=${ue_model}     ue_index=${ue_index}

    Sleep   5s

    ${res_path}=   set variable     ${OUTPUTDIR}/${SUITENAME}/gnb${gNB}_pmcounters
    ${res_file}=    Collect PM Files And Get Last Period Filename
    ...          oam_type=coam
    ...          name=gnb${gNB}_pmcounters
    ...          scope=testsuite
    ...          gnb_id=${gNB}
    Log       last period pm file gNB${gNB}=${res_file}   console=${DEBUG_MODE_CONSOLE}
    Set Suite Variable      ${PM_PATH}         ${res_path}
    Set Suite Variable      ${PM_FILENAME}     ${res_file}


1348 A15 A16 with call and Collect Pm in TestSuiteDir
   [Documentation]    The purpose of this keyword is :
    ...                 - wait the begining of meas period
    ...                 - reserve UE
    ...                 - attach UE (2 tries)
    ...                 - wait of one meas period duration
    ...                 - detach UE
    ...                 - collect PM files at end of current meas period
    ...   Please take note that testsuite variable ${PM_FILENAME} and ${PM_PATH} are set

    [Arguments]     ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE

    # added additional_waiting_time_sec: pm files are created on gNB with 1min delay on our gNB
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=-10
    ...        gnb=${gNB}

    Log      UE Setup    console=${DEBUG_MODE_CONSOLE}
    #Setup UE      ue_index=${ue_index}      ue_capabilities=${ue_capabilities}
    ${ue_model}=        Keywords_UE.Setup UE      ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    Log         Attach UE (2 tries)    console=${DEBUG_MODE_CONSOLE}
    #${passed}       Run Keyword and return status        Start UE attach     ue_index=${ue_index}
    #Run keyword unless      ${passed}      Start UE attach     ue_index=${ue_index}
    ${passed}       Run Keyword and return status      Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}
    Run keyword If     ${passed} == ${False}     Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}

    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=30
    ...        gnb=${gNB}

    Log    Detach UE    console=${DEBUG_MODE_CONSOLE}
    Keywords_UE.Release UE known Type     ue_type_model=${ue_model}     ue_index=${ue_index}

    ${res_path}=   set variable     ${OUTPUTDIR}/${SUITENAME}/gnb${gNB}_pmcounters
    ${res_file}=    Collect PM Files And Get Last Period Filename
    ...          oam_type=coam
    ...          name=gnb${gNB}_pmcounters
    ...          scope=testsuite
    ...          gnb_id=${gNB}
    Log       last period pm file gNB${gNB}=${res_file}   console=${DEBUG_MODE_CONSOLE}
    Set Suite Variable      ${PM_PATH}         ${res_path}
    Set Suite Variable      ${PM_FILENAME}     ${res_file}


1348 A22 A23 call and traffic with L1L2
    [Documentation]    The purpose of this keyword is :
    ...                 - reserve UE
    ...                 - attach UE
    ...                 - start traffic UL or DL
    ...                 - capture L1L2 during 10s
    ...                 - detach UE
    ...                 - collect L1L2,
    ...                 - parse L1L2

    [Arguments]       ${tc_num}=22   ${traffic_direction}=DL    ${tput_dl}=600M    ${tput_ul}=100M    ${duration}=600
    ...               ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE

    #bypass robocop
    ${gNB}    set variable    ${gNB}

    ${ue_model}=        Keywords_UE.Setup UE      ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    Log         Attach UE (2 tries)    console=${DEBUG_MODE_CONSOLE}
    ${passed}       Run Keyword and return status      Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}
    Run keyword If     ${passed} == ${False}     Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}

    sleep   40s
    ${ip_ue}=     run keyword if   '${ue_model}'=='QCT'       ue_addr.Get UE IP address
    ...                                                            ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    Log         UE ip = ${ip_ue}  console=${DEBUG_MODE_CONSOLE}

    Run Keyword If     '${traffic_direction}'=='DL'
    ...     Start Process TrafficDL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${duration}
    ...           tput=${tput_dl}
    ...           ue_type_model=${ue_model}
    ...           ueid=${ue_index}
    Run Keyword If     '${traffic_direction}'=='UL'
    ...     Start Process TrafficUL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${duration}
    ...           tput=${tput_ul}
    ...           ue_type_model=${ue_model}
    ...           ueid=${ue_index}

    # After the cell is up, start L1L2 traces during 20 seconds
	Log    Start L1L2 capture   		console=${DEBUG_MODE_CONSOLE}
	capture.Start BIP Capture with gnbMirroring scripts Mirroring Mode local        cnx_alias=cnx_alias
	Log    Wait 10s   		console=${DEBUG_MODE_CONSOLE}
	sleep                   10s
	Log    Stop and collect L1L2 traces   		console=${DEBUG_MODE_CONSOLE}
	capture.Stop gnbMirroring And Get BIP log	   cnx_alias    ${OUTPUTDIR}    tcpdumpL2L1_filtering_off.pcap
    Sleep   5s

	Run Keyword If    '${traffic_direction}'=='DL'
	...       Keywords_UE.Stop TrafficDL UE known Type      ue_type_model=${ue_model}     ueid=${ue_index}
    Run Keyword If    '${traffic_direction}'=='UL'
    ...       Keywords_UE.Stop TrafficUL UE known Type      ue_type_model=${ue_model}     ueid=${ue_index}

    Log    Detach UE    console=${DEBUG_MODE_CONSOLE}
    Keywords_UE.Release UE known Type     ue_type_model=${ue_model}     ue_index=${ue_index}

    ${pcap_file_full_path}=    set variable    ${OUTPUT_DIR}/tcpdumpL2L1_filtering_off.pcap
    Log        file pcap=${pcap_file_full_path}    console=${DEBUG_MODE_CONSOLE}

    ${filtered_File}    convert_pcap.Filter PCAP with Tshark
    ...                    pcap_file_full_path=${pcap_file_full_path}
    ...                    filterName=uldata_pucchreceivereq
    ...                    filterExp=uldata_pucchreceivereq
    Log      filtered file=${filtered_File}        console=${DEBUG_MODE_CONSOLE}
    #result file has name : (uldata_pucchreceivereq)  => tcpdumpL2L1_filtering_off.<filterName>.pcap

    ${pdmlFile}         convert_pcap.Convert PCAP to PDML with Tshark   ${filtered_File}
    Log      pdmlFile=${pdmlFile}          console=${DEBUG_MODE_CONSOLE}

    Run Keyword If     '${tc_num}'=='22'
    ...     Parsing_L1L2_Traces_for_PUCCH_and_PUSCH_1348.check_slot_for_ulData_PUCCHreceiveReq_TC22     ${pdmlFile}
    Run Keyword If     '${tc_num}'=='23'
    ...     Parsing_L1L2_Traces_for_PUCCH_and_PUSCH_1348.check_slot_for_ulData_PUCCHreceiveReq_TC23     ${pdmlFile}



1348 A11 A13 call and traffic with L1L2 and TTI traces
    [Documentation]    The purpose of this keyword is :
    ...                 - reserve UE
    ...                 - attach UE
    ...                 - start traffic UL or DL
    ...                 - capture L1L2 during 10s
    ...                 - capture TTI traces 10s
    ...                 - detach UE
    ...                 - parse traces
    ...        10.06.2021 :
    ...           New argument ${tti_capacity_unit_cnx_option} : xeonA or xeonB
    [Arguments]      ${tc_num}=11    ${traffic_direction}=DL    ${tput_dl}=600M     ${tput_ul}=100M    ${duration}=600
    ...              ${gNB}=${0}     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE
    ...              ${tti_capacity_unit_cnx_option}=xeonB

    ${ue_model}=        Keywords_UE.Setup UE      ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    Log         Attach UE (2 tries)    console=${DEBUG_MODE_CONSOLE}
    ${passed}      Run Keyword and return status     Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}
    Run keyword if          ${passed} == ${False}            Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}

    sleep   40s
    ${ip_ue}=    run keyword if    '${ue_model}'=='QCT'    ue_addr.Get UE IP address
    ...                                                            ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    Log           UE ip = ${ip_ue}      console=${DEBUG_MODE_CONSOLE}

    Run Keyword If     '${traffic_direction}'=='DL'
    ...       Start Process TrafficDL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${duration}
    ...           tput=${tput_dl}
    ...           ue_type_model=${ue_model}
    ...           ueid=${ue_index}
    Run Keyword If     '${traffic_direction}'=='UL'
    ...       Start Process TrafficUL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${duration}
    ...           tput=${tput_ul}
    ...           ue_type_model=${ue_model}
    ...           ueid=${ue_index}

    # After the cell is up, start L1L2 traces during 20 seconds
	Log    Start L1L2 capture   		console=${DEBUG_MODE_CONSOLE}
	capture.Start BIP Capture with gnbMirroring scripts Mirroring Mode local       cnx_alias=cnx_alias
	sleep   6s
	Log    Stop and collect L1L2 traces   		console=${DEBUG_MODE_CONSOLE}
	capture.Stop gnbMirroring And Get BIP log	   cnx_alias    ${OUTPUTDIR}    tcpdumpL2L1_filtering_off.pcap
    Sleep   5s

    # After the cell is up, start TTI Traces
	Log     Start TTI Traces        console=${DEBUG_MODE_CONSOLE}

    # Open a connection to the ASIK master and the ABIL XEON-A / or XEON-B
    ${asik_cnx}         ssh.connect_to     ${GNB_AIRSCALE_IP[${gNB}]}
    ...                                    ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                                    ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...				    alias=asik_als     timeout=90.0
	#case 19B : need to connect to ${GNB_ABIL0_xeonA}=> ${GNB_ABIL0_xeonA[${gNB}]}
    #else     : need to connect to ${GNB_ABIL0_xeonB}=> ${GNB_ABIL0_xeonB[${gNB}]}
    ${_abil_ip}=   run keyword if   '${tti_capacity_unit_cnx_option}'=='xeonA'
    ...                                    set variable    ${GNB_ABIL0_xeonA[${gNB}]}
    ...                     ELSE           set variable    ${GNB_ABIL0_xeonB[${gNB}]}

    ${abil_cnx}    ssh.connect_to      ${_abil_ip}
    ...                                ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                                ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...                                proxy=asik_als    timeout=90.0

    Start tti traces     ${abil_cnx}
    sleep                   10s
    Stop tti traces      ${abil_cnx}

	Run Keyword If    '${traffic_direction}'=='DL'
	...     Keywords_UE.Stop TrafficDL UE known Type      ue_type_model=${ue_model}     ueid=${ue_index}
    Run Keyword If    '${traffic_direction}'=='UL'
    ...     Keywords_UE.Stop TrafficUL UE known Type      ue_type_model=${ue_model}     ueid=${ue_index}

    Log    Detach UE    console=${DEBUG_MODE_CONSOLE}
    Keywords_UE.Release UE known Type     ue_type_model=${ue_model}     ue_index=${ue_index}

    ${pcap_file_full_path}=    set variable    ${OUTPUT_DIR}/tcpdumpL2L1_filtering_off.pcap
    Log        file pcap=${pcap_file_full_path}    console=${DEBUG_MODE_CONSOLE}

    ${filtered_File}    convert_pcap.Filter PCAP with Tshark
    ...                    pcap_file_full_path=${pcap_file_full_path}
    ...                    filterName=uldata_pucchreceivereq
    ...                    filterExp=uldata_pucchreceivereq
    Log      filtered file=${filtered_File}        console=${DEBUG_MODE_CONSOLE}
    #result file has name : (uldata_pucchreceivereq)  => tcpdumpL2L1_filtering_off.<filterName>.pcap

    ${pdmlFile}         convert_pcap.Convert PCAP to PDML with Tshark   ${filtered_File}
    Log      pdmlFile=${pdmlFile}          console=${DEBUG_MODE_CONSOLE}

    Run Keyword If  '${tc_num}'=='11'
    ...     Parsing_L1L2_Traces_for_PUCCH_and_PUSCH_1348.check_slot_for_ulData_PUCCHreceiveReq_TC11        ${pdmlFile}
    Run Keyword If  '${tc_num}'=='13'
    ...     Parsing_L1L2_Traces_for_PUCCH_and_PUSCH_1348.check_slot_for_ulData_PUCCHreceiveReq_TC13        ${pdmlFile}

	${tti_file}      set variable    ${OUTPUT_DIR}/combined_dl_trace.csv
    log     Collect TTI Traces, TTI Traces file=${tti_file}       console=${DEBUG_MODE_CONSOLE}

	# create again cnx (defense)
    run keyword and ignore error    ssh.disconnect      connection=${asik_cnx}
    run keyword and ignore error    ssh.disconnect      connection=${abil_cnx}
    sleep   2s
    ${asik_cnx}   ssh.connect_to   ${GNB_AIRSCALE_IP[${gNB}]}
    ...                            ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                            ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...				               alias=asik_als
    ${abil_cnx}   ssh.connect_to   ${_abil_ip}  ${GNB_AIRSCALE_USERNAME[${gNB}]}  ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...                            proxy=asik_als
	Collect all tti traces    ${abil_cnx}    ${OUTPUTDIR}
	Sleep   5s
	log     Count Ack Nack        console=${DEBUG_MODE_CONSOLE}
    #Count_AckNack.count_ackNack      ${tti_file}
    Count_AckNack.count_ackNack_V3      ${tti_file}
    [Teardown]        run keywords          ssh.disconnect      connection=${asik_cnx}      AND
    ...                                     ssh.disconnect      connection=${abil_cnx}



1348 A11bis call and traffic collect PM files L1L2 and TTI traces
    [Documentation]    The purpose of this keyword is :
    ...                 - reserve UE
    ...                 - attach UE
    ...                 - start uldl traffic
    ...                 - wait new meas period
    ...                 - capture 10s L1L2 traces
    ...                 - collect 10s TTI traces + check AckNack
    ...                 - detach UE
    ...                 - parse L1L2
    ...                 - get PM files (pi values will be checked further)
    ...        10.06.2021 :
    ...           New argument ${tti_capacity_unit_cnx_option} : xeonA or xeonB
    [Arguments]         ${tput_dl}=600M     ${tput_ul}=200M     ${duration}=600
    ...                 ${gNB}=${0}    ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE
    ...                 ${tti_capacity_unit_cnx_option}=xeonB

    ${ue_model}=        Keywords_UE.Setup UE      ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    Log         Attach UE (2 tries)    console=${DEBUG_MODE_CONSOLE}
    ${passed}       Run Keyword and return status      Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}
    Run keyword If     ${passed} == ${False}     Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}

    sleep   40s
    ${ip_ue}=       run keyword if      '${ue_model}'=='QCT'       ue_addr.Get UE IP address
    ...                                                            ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    Log           UE ip = ${ip_ue}  console=${DEBUG_MODE_CONSOLE}

    Keywords_UE.Start Process Traffic Simultaneous ULDL UE known Type
    ...    distantip=${ip_ue}
    ...    duration=${duration}
    ...    tput_ul=${tput_ul}
    ...    tput_dl=${tput_dl}
    ...    ueid=${ue_index}
    ...    ue_type_model=${ue_model}

    # wait that period is finished to collect PM files
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=70
    ...        gnb=${gNB}

	Log    Start L1L2 traces For 10s       console=${DEBUG_MODE_CONSOLE}
	capture.Start BIP Capture with gnbMirroring scripts Mirroring Mode local        cnx_alias=cnx_alias
	sleep   10s
	capture.Stop gnbMirroring And Get BIP log	   cnx_alias    ${OUTPUTDIR}    tcpdumpL2L1_filtering_off.pcap
    Sleep    5s

	Log     Start TTI Traces for 10s            console=${DEBUG_MODE_CONSOLE}
    # Open a connection to the ASIK master and the ABIL XEON-A / or XEON-B
    ${asik_cnx}         ssh.connect_to     ${GNB_AIRSCALE_IP[${gNB}]}
    ...                                    ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                                    ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...				    alias=asik_als     timeout=90.0

    ${_abil_ip}=   run keyword if   '${tti_capacity_unit_cnx_option}'=='xeonA'
    ...                                    set variable    ${GNB_ABIL0_xeonA[${gNB}]}
    ...                     ELSE           set variable    ${GNB_ABIL0_xeonB[${gNB}]}

    ${abil_cnx}    ssh.connect_to      ${_abil_ip}
    ...                                ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                                ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...                                proxy=asik_als    timeout=90.0

    Start tti traces     ${abil_cnx}
    sleep                   10s
    Stop tti traces      ${abil_cnx}

	${tti_file}               set variable    ${OUTPUTDIR}/combined_dl_trace.csv
	log     Collect TTI Traces, TTI Traces file=${tti_file}       console=${DEBUG_MODE_CONSOLE}

	# create again cnx (defense)
    run keyword and ignore error    ssh.disconnect      connection=${asik_cnx}
    run keyword and ignore error    ssh.disconnect      connection=${abil_cnx}
    sleep   2s
    ${asik_cnx}   ssh.connect_to   ${GNB_AIRSCALE_IP[${gNB}]}
    ...                            ${GNB_AIRSCALE_USERNAME[${gNB}]}
    ...                            ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...				               alias=asik_als
    ${abil_cnx}   ssh.connect_to   ${_abil_ip}  ${GNB_AIRSCALE_USERNAME[${gNB}]}  ${GNB_AIRSCALE_PASSWORD[${gNB}]}
    ...                            proxy=asik_als

	Collect all tti traces    ${abil_cnx}    ${OUTPUTDIR}
	Sleep   5s

    log      Parse TTI Traces:         console=${DEBUG_MODE_CONSOLE}
    #Count_AckNack.count_ackNack       ${tti_file}
    Count_AckNack.count_ackNack_V3     ${tti_file}

    # wait that period is finished to collect PM files
    pm_collection.Wait For Next Measurement Period
    ...        meas_period_in_minute=${MeasPeriod}
    ...        additional_waiting_time_sec=70
    ...        gnb=${gNB}

    Keywords_UE.Stop Traffic Simultaneous ULDL UE known Type       ue_type_model=${ue_model}     ueid=${ue_index}

    Log    Detach UE    console=${DEBUG_MODE_CONSOLE}
    Keywords_UE.Release UE known Type     ue_type_model=${ue_model}     ue_index=${ue_index}

    Sleep   5s

    ${res_path}=    set variable     ${OUTPUTDIR}/${SUITENAME}/gnb${gNB}_pmcounters
    ${res_file}=    Collect PM Files And Get Last Period Filename
    ...          oam_type=coam
    ...          name=gnb${gNB}_pmcounters
    ...          scope=testsuite
    ...          gnb_id=${gNB}
    Log       last period pm file gNB${gNB}=${res_file}   console=${DEBUG_MODE_CONSOLE}
    Set Suite Variable      ${PM_PATH}         ${res_path}
    Set Suite Variable      ${PM_FILENAME}     ${res_file}

    Log       Convert pcap to pdml and Parse file:          console=${DEBUG_MODE_CONSOLE}
    ${pcap_file_full_path}=    set variable    ${OUTPUTDIR}/tcpdumpL2L1_filtering_off.pcap
    ${filtered_File}           convert_pcap.Filter PCAP with Tshark
    ...                             pcap_file_full_path=${pcap_file_full_path}
    ...                             filterName=uldata_puschreceivereq
    ...                             filterExp=uldata_puschreceivereq
    Log      filtered file=${filtered_File}        console=${DEBUG_MODE_CONSOLE}
    #result file has name : (uldata_puschreceivereq)  => tcpdumpL2L1_filtering_off.<filterName>.pcap
    ${pdmlFile}         convert_pcap.Convert PCAP to PDML with Tshark   ${filtered_File}
    Log      pdmlFile=${pdmlFile}          console=${DEBUG_MODE_CONSOLE}
    Parsing_L1L2_Traces_for_PUCCH_and_PUSCH_1348.check_slot_for_ulData_PUSCHreceiveReq_TC11bis   ${pdmlFile}
    [Teardown]        run keywords          ssh.disconnect      connection=${asik_cnx}      AND
    ...                                     ssh.disconnect      connection=${abil_cnx}


1348 J003 J004 J005 call and traffic and L1L2 traces
    [Documentation]    The purpose of this keyword is :
    ...                 - reserve UE
    ...                 - attach UE
    ...                 - start UL traffic
    ...                 - capture 6s L1L2 traces
    ...                 - detach UE
    ...                 - parse L1L2

    [Arguments]         ${tc_num}=003        ${tput_ul}=200M     ${duration}=3000
    ...                 ${gNB}=0     ${ue_index}=${0}    ${ue_capabilities}=REAL_ANDROID_UE

    #bypass robocop
    ${gNB}    set variable    ${gNB}

    ${ue_model}=        Keywords_UE.Setup UE      ue_index=${ue_index}    ue_capabilities=${ue_capabilities}

    Log         Attach UE (2 tries)    console=${DEBUG_MODE_CONSOLE}
    ${passed}       Run Keyword and return status      Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}
    Run keyword If     ${passed} == ${False}     Keywords_UE.Attach UE known Type
    ...                                    ue_type_model=${ue_model}  ue_index=${ue_index}

    sleep   40s
    ${ip_ue}=       run keyword if     '${ue_model}'=='QCT'     ue_addr.Get UE IP address
    ...                                                            ${ULserver_ip}
    ...                                                            ${ULserver_login}
    ...                                                            ${ULserver_pwd}
    Log           UE ip = ${ip_ue}  console=${DEBUG_MODE_CONSOLE}

    Start Process TrafficUL UE known Type
    ...           distantip=${ip_ue}
    ...           duration=${duration}
    ...           tput=${tput_ul}
    ...           ue_type_model=${ue_model}
    ...           ueid=${ue_index}

    Sleep   20s

	Log    Start L1L2 traces For 6s       console=${DEBUG_MODE_CONSOLE}
	capture.Start BIP Capture with gnbMirroring scripts Mirroring Mode local        cnx_alias=cnx_alias
	sleep   6s
	capture.Stop gnbMirroring And Get BIP log	   cnx_alias    ${OUTPUTDIR}    tcpdumpL2L1_filtering_off.pcap
    Sleep    5s

    Keywords_UE.Stop TrafficUL UE known Type       ue_type_model=${ue_model}     ueid=${ue_index}

    Log    Detach UE    console=${DEBUG_MODE_CONSOLE}
    Keywords_UE.Release UE known Type     ue_type_model=${ue_model}     ue_index=${ue_index}

    Sleep   5s

    Log       Convert pcap to pdml and Parse file:          console=${DEBUG_MODE_CONSOLE}
    ${pcap_file_full_path}=    set variable    ${OUTPUTDIR}/tcpdumpL2L1_filtering_off.pcap
    ${filtered_File}           convert_pcap.Filter PCAP with Tshark
    ...                             pcap_file_full_path=${pcap_file_full_path}
    ...                             filterName=uldata_puschreceivereq
    ...                             filterExp=uldata_puschreceivereq
    Log      filtered file=${filtered_File}        console=${DEBUG_MODE_CONSOLE}
    #result file has name : (uldata_puschreceivereq)  => tcpdumpL2L1_filtering_off.<filterName>.pcap
    ${pdmlFile}         convert_pcap.Convert PCAP to PDML with Tshark   ${filtered_File}
    Log      pdmlFile=${pdmlFile}          console=${DEBUG_MODE_CONSOLE}
    Run Keyword If  '${tc_num}'=='003'
    ...      check_slot_for_ulData_PUSCHreceiveReq_TCJ003_prachConfig_98_1Ue_2beams_2subcells      ${pdmlFile}
    Run Keyword If  '${tc_num}'=='004'
    ...      check_slot_for_ulData_PUSCHreceiveReq_TCJ005_TCJ004_prachConfig_93_1Ue_2beams_2subcells      ${pdmlFile}
    Run Keyword If  '${tc_num}'=='005'
    ...      check_slot_for_ulData_PUSCHreceiveReq_TCJ005_TCJ004_prachConfig_93_1Ue_2beams_2subcells      ${pdmlFile}


get btsNameScf from SCF
    [Arguments]    ${gNB}=0
    ${current_scf_fullname}    set Variable      ${ORIG_SCF[0]}
    ${dist_name}=    set variable    MRBTS-${MRBTS_NB[${gNB}]}
    scf.load_scf    ${current_scf_fullname}
    ${btsNameScf}    scf.get_value_from_scf   p_name=btsName    dist_name=${dist_name}
    set suite variable    ${btsNameScf}
