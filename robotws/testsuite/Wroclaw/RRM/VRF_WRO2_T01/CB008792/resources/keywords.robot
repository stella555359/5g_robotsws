*** Settings ***
Documentation
...               Editor: Wiktor Jarosiński
...               Contact Person: Paweł Wiśniewski
...               Edit Reason: RobotFramework5.0 Migration
Library           testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008792/resources/CB008792.py
Library           testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py
Library           testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py
Library           testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_cplane.py
Library           testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/qxdm/UELogAnalyzer.py    WITH NAME    uea
Library           pcap_cplane.pdml            WITH NAME   pdmlp
Library           taf.converters.pcaptopdml   WITH NAME   pcaptopdml
Library           String
Library           ute_syslog
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/qxdm/qxdm_auto.robot
Variables         structures.yaml
Library           taf.sbts.oam.coam.admin  WITH NAME    coam
Library           testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common.py

*** Variables ***
${MRBTS_5G_ID}        ${tl.gnbs[0].instance_id}
${MRBTS_5G}           MRBTS-${MRBTS_5G_ID}
${SCF_8792}           ${EXECDIR}/testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008792/resources/SCFs/${MRBTS_5G_ID}
${GNB_ALIAS}          gNB
${ENB_ALIAS}          eNB
${UE_ALIAS}           UE_1
${LOG_NAME}           8792_inner_syslog.log

*** Keywords ***
# TODO: COMMISSIONING KWs
Perform commissioning with 8792 SCF
    Log to console  Performing commissioning with 8792 SCF
    ${should_upload_higher_scf_version}    check_release_is_higher_than    SBTS23R4
    Run keyword if  ${should_upload_higher_scf_version}
    ...             coam.perform commissioning   bts_id=${MRBTS_5G_ID}
    ...                                          scf_file=${SCF_8792}/${MRBTS_5G_ID}.xml
    ...                                          skip_parameter_relation_errors=${True}
    ...                                          should_activate=${True}
    ...                                          timeout=600
    ...                                          connection=${GNB_ALIAS}
    ...             ELSE    coam.perform commissioning   bts_id=${MRBTS_5G_ID}
    ...                                                  scf_file=${SCF_8792}/${MRBTS_5G_ID}_BRANCH.xml
    ...                                                  skip_parameter_relation_errors=${True}
    ...                                                  should_activate=${True}
    ...                                                  timeout=600
    ...                                                  connection=${GNB_ALIAS}

    Wait until keyword succeeds  10min   1min   Verify all cells are onair with admin

Perform commissioning 8792B_23
    [Arguments]         ${actDlPtrs}=false
    ...                 ${dlDMRSAdditionalPosition}=Two additional DMRS
    ...                 ${dlPtrsFreqDensityThresNrb0}=279
    ...                 ${dlPtrsFreqDensityThresNrb1}=24
    ...                 ${actUlPtrs}=false
    ...                 ${ulDMRSAdditionalPosition}=Two additional DMRS
    ...                 ${ulPtrsFreqDensityThresNrb0}=279
    ...                 ${ulPtrsFreqDensityThresNrb1}=274
    ...                 ${actHighSpeedCell}=true
    ...                 ${actUlDftSOfdm}=false
    Log to console   Setting commissioning 8792B_23
    ${cells_info}    coam.get cells info  nr  60  ${GNB_ALIAS}
    ${object_path}   Set Variable  ${cells_info[0]['id']['configuration']}
    &{dlPtrs_dict}    Create dictionary   actDlPtrs  ${actDlPtrs}
    ...                                   dlPtrsFreqDensityThresNrb0  ${dlPtrsFreqDensityThresNrb0}
    ...                                   dlPtrsFreqDensityThresNrb1  ${dlPtrsFreqDensityThresNrb1}
    &{ulPtrs_dict}    Create dictionary   actUlPtrs  ${actUlPtrs}
    ...                                   ulPtrsFreqDensityThresNrb0  ${ulPtrsFreqDensityThresNrb0}
    ...                                   ulPtrsFreqDensityThresNrb1  ${ulPtrsFreqDensityThresNrb1}
    Initialise delta store
    Add list parameters to delta    ${object_path}    dlPtrs    &{dlPtrs_dict}
    Add list parameters to delta    ${object_path}    ulPtrs    &{ulPtrs_dict}
    Add param to delta  ${object_path}  dlDMRSAdditionalPosition  ${dlDMRSAdditionalPosition}
    Add param to delta  ${object_path}  ulDMRSAdditionalPosition  ${ulDMRSAdditionalPosition}
    Add param to delta  ${object_path}  actHighSpeedCell  ${actHighSpeedCell}
    Add param to delta  ${object_path}  actUlDftSOfdm  ${actUlDftSOfdm}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Wait until keyword succeeds   10min   1min   Verify all cells are onair with admin

Perform commissioning 8792B_27
    [Arguments]         ${frameStructureType}=tdLte
    ...                 ${guardPeriodLength}=4Symbols
    ...                 ${lteToNrFrameShift}=0ms
    ...                 ${tdLteUlDlConfig}=tdLteConfig2
    ...                 ${ulDlDataSlotRatio}=2/8
    ...                 ${prachConfigurationIndex}=97
    ...                 ${actUlPtrs}=true
    ...                 ${ulPtrsFreqDensityThresNrb0}=1
    ...                 ${ulPtrsFreqDensityThresNrb1}=24
    ...                 ${nrCellType}=4DL4UL
    ...                 ${pucchModeSelect}=longPucch
    ...                 ${actHighSpeedCell}=true
    ...                 ${ulDMRSAdditionalPosition}=Automatic
    ...                 ${puschMappingType}=TypeA
    ...                 ${dmrsTypeAPosition}=pos2
    ...                 ${actUlDataDmrsFdm}=true
    ...                 ${actUlDftSOfdm}=true
    ...                 ${actUl256Qam}=true
    ...                 ${actLongPucchPhase2}=true
    Log to console   Setting commissioning 8792B_27
    ${cells_info}    coam.get cells info  nr  60  ${GNB_ALIAS}
    ${object_path}   Set Variable  ${cells_info[0]['id']['configuration']}
    &{frame_structure_dict}  Create dictionary  frameStructureType           ${frameStructureType}
    ...                                         guardPeriodLength            ${guardPeriodLength}
    ...                                         lteToNrFrameShift            ${lteToNrFrameShift}
    ...                                         tdLteUlDlConfig              ${tdLteUlDlConfig}
    ...                                         ulDlDataSlotRatio            ${ulDlDataSlotRatio}
    &{ulPtrs_dict}           Create dictionary  actUlPtrs                    ${actUlPtrs}
    ...                                         ulPtrsFreqDensityThresNrb0   ${ulPtrsFreqDensityThresNrb0}
    ...                                         ulPtrsFreqDensityThresNrb1   ${ulPtrsFreqDensityThresNrb1}
    &{ulDataDmrsFdm_dict}    Create dictionary  actUlDataDmrsFdm             ${actUlDataDmrsFdm}
    ...                                         ulDataDmrsFdmThres64QamMcs   5
    ...                                         ulDataDmrsFdmThres256QamMcs  5
    Initialise delta store
    Add list parameters to delta  ${object_path}  tddFrameStructure  &{frame_structure_dict}
    Add list parameters to delta  ${object_path}  ulPtrs             &{ulPtrs_dict}
    Add list parameters to delta  ${object_path}  ulDataDmrsFdm      &{ulDataDmrsFdm_dict}
    Add param to delta  ${object_path}  nrCellType                ${nrCellType}
    Add param to delta  ${object_path}  pucchModeSelect           ${pucchModeSelect}
    Add param to delta  ${object_path}  actHighSpeedCell          ${actHighSpeedCell}
    Add param to delta  ${object_path}  ulDMRSAdditionalPosition  ${ulDMRSAdditionalPosition}
    Add param to delta  ${object_path}  puschMappingType          ${puschMappingType}
    Add param to delta  ${object_path}  dmrsTypeAPosition         ${dmrsTypeAPosition}
    Add param to delta  ${object_path}  actUlDftSOfdm             ${actUlDftSOfdm}
    Add param to delta  ${object_path}  actUl256Qam               ${actUl256Qam}
    Add param to delta  ${object_path}  actLongPucchPhase2        ${actLongPucchPhase2}
    Add param to delta  ${object_path}  prachConfigurationIndex   ${prachConfigurationIndex}
    ${object}  Set Variable  ${MRBTS_5G}/NRBTS-${MRBTS_5G_ID}/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1
    Add list of dictionaries to delta  ${object}  searchSpaceCommon
    ...                  ${B27_common1_struct_1}  ${B27_common1_struct_2}  ${B27_common1_struct_3}
    ${object}  Set Variable  ${MRBTS_5G}/NRBTS-${MRBTS_5G_ID}/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1
    Add list of dictionaries to delta  ${object}  searchSpaceCommon
    ...                  ${B27_common2_struct_1}  ${B27_common2_struct_2}  ${B27_common2_struct_3}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Wait until keyword succeeds   10min   1min   Verify all cells are onair with admin

Perform commissioning 8792D
    [Arguments]
    ...                 ${nrCellType}=4DL4UL
    ...                 ${actDlPtrs}=false
    ...                 ${pucchModeSelect}=longPucch
    ...                 ${actHighSpeedCell}=true
    ...                 ${dlDMRSAdditionalPosition}=Two additional DMRS
    ...                 ${ulDMRSAdditionalPosition}=Two additional DMRS
    ...                 ${msg1FrequencyStart}=27
    ...                 ${reqMinNumPuschPrb}=219
    ...                 ${f3MaxCodeRate}=zeroDot08
    ...                 ${actDlDataDmrsFdm}=true
    ...                 ${actDl256Qam}=true
    ...                 ${actpdschrmcsirsfortracking}=true
    ...                 ${actpdschatssbslots}=true
    ...                 ${rbAllocation}=52RB
    ...                 ${csirsTrackingPeriod}=20ms
    ...                 ${actDynPdcchTd}=true
    ...                 ${puschMappingType}=TypeA
    ...                 ${actPucchAdditionalDmrs}=false
    ...                 ${lteToNrTimeOffset}=-70
    ...                 ${prachConfigurationIndex}=98
    ...                 ${frameStructureType}=semiStatic   #Frame structure
    ...                 ${guardPeriodLength}=2Symbols      #Frame structure
    ...                 ${ulDlDataSlotRatio}=1/4           #Frame structure
    ...                 ${initialBWPMode}=widerInitBWP     #pdcchAutoConfig
    ...                 ${cellCoverageLevel}=normal        #pdcchAutoConfig
    Log to console   Setting commissioning 8792D
    ${cells_info}    coam.get cells info  nr  60  ${GNB_ALIAS}
    ${object_path}   Set Variable  ${cells_info[0]['id']['configuration']}
    &{frame_structure_dict}   Create dictionary  frameStructureType           ${frameStructureType}
    ...                                          guardPeriodLength            ${guardPeriodLength}
    ...                                          ulDlDataSlotRatio            ${ulDlDataSlotRatio}
    &{dlPtrs_dict}            Create dictionary  actDlPtrs                    ${actDlPtrs}
    ...                                          dlPtrsFreqDensityThresNrb0   274
    ...                                          dlPtrsFreqDensityThresNrb1   274
    &{pdcchAutoConfig_dict}   Create dictionary  initialBWPMode               ${initialBWPMode}
    ...                                          cellCoverageLevel            ${cellCoverageLevel}
    &{dynPdcchTdMgt_dict}     Create dictionary  actDynPdcchTd                ${actDynPdcchTd}
    ...                                          pdcchBlockingThreshold       30
    ...                                          pdcchFreeThreshold           30
    &{csirsForTracking_dict}  Create dictionary  csirsTrackingPeriod          ${csirsTrackingPeriod}
    ...                                          firstRE                      0
    ...                                          rbAllocation                 ${rbAllocation}
    ...                                          startRB                      0
    &{dlDataDmrsFdm_dict}     Create dictionary  actDlDataDmrsFdm             ${actDlDataDmrsFdm}
    ...                                          dlDataDmrsFdmThres64QamMcs   5
    ...                                          dlDataDmrsFdmThres256QamMcs  5
    Initialise delta store
    Add list parameters to delta  ${object_path}  tddFrameStructure  &{frame_structure_dict}
    Add list parameters to delta  ${object_path}  dlPtrs             &{dlPtrs_dict}
    Add list parameters to delta  ${object_path}  pdcchAutoConfig    &{pdcchAutoConfig_dict}
    Add list parameters to delta  ${object_path}  dynPdcchTdMgt      &{dynPdcchTdMgt_dict}
    Add list parameters to delta  ${object_path}  csirsForTracking   &{csirsForTracking_dict}
    Add list parameters to delta  ${object_path}  dlDataDmrsFdm      &{dlDataDmrsFdm_dict}
    Add param to delta  ${object_path}  nrCellType                   ${nrCellType}
    Add param to delta  ${object_path}  pucchModeSelect              ${pucchModeSelect}
    Add param to delta  ${object_path}  actHighSpeedCell             ${actHighSpeedCell}
    Add param to delta  ${object_path}  dlDMRSAdditionalPosition     ${dlDMRSAdditionalPosition}
    Add param to delta  ${object_path}  ulDMRSAdditionalPosition     ${ulDMRSAdditionalPosition}
    Add param to delta  ${object_path}  msg1FrequencyStart           ${msg1FrequencyStart}
    Add param to delta  ${object_path}  reqMinNumPuschPrb            ${reqMinNumPuschPrb}
    Add param to delta  ${object_path}  pucchF3MaxCodeRate           ${f3MaxCodeRate}
    Add param to delta  ${object_path}  actDl256Qam                  ${actDl256Qam}
    Add param to delta  ${object_path}  actPdschRmCsirsForTracking   ${actpdschrmcsirsfortracking}
    Add param to delta  ${object_path}  actPdschAtSsbSlots           ${actpdschatssbslots}
    Add param to delta  ${object_path}  puschMappingType             ${puschMappingType}
    Add param to delta  ${object_path}  actPucchAdditionalDmrs       ${actPucchAdditionalDmrs}
    Add param to delta  ${object_path}  lteToNrTimeOffset            ${lteToNrTimeOffset}
    Add param to delta  ${object_path}  prachConfigurationIndex      ${prachConfigurationIndex}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Wait until keyword succeeds   10min   1min   Verify all cells are onair with admin

Perform commissioning 8792ACDW
    [Arguments]
    ...                 ${nrCellType}=4DL4UL
    ...                 ${actDlPtrs}=false
    ...                 ${pucchModeSelect}=longPucch
    ...                 ${actHighSpeedCell}=false
    ...                 ${dlDMRSAdditionalPosition}=One additional DMRS
    ...                 ${ulDMRSAdditionalPosition}=One additional DMRS
    ...                 ${ssPbchBlockPower}=3
    ...                 ${dlQam256PowerBackoffSub6}=30
    ...                 ${msg1FrequencyStart}=19
    ...                 ${reqMinNumPuschPrb}=235
    ...                 ${pucchF3MaxCodeRate}=zeroDot08
    ...                 ${actDlDataDmrsFdm}=true
    ...                 ${actDl256Qam}=true
    ...                 ${actpdschrmcsirsfortracking}=true
    ...                 ${actpdschatssbslots}=true
    ...                 ${rbAllocation}=52RB
    ...                 ${csirsTrackingPeriod}=20ms
#   ...                 ${actDynPdcchTd}=true
    ...                 ${puschMappingType}=TypeA
    ...                 ${actPucchAdditionalDmrs}=false
    ...                 ${initialBWPMode}=widerInitBWP          #pdcchAutoConfig
    ...                 ${cellCoverageLevel}=normal             #pdcchAutoConfig
    Log to console   Setting commissioning 8792D
    ${cells_info}    coam.get cells info  nr  60  ${GNB_ALIAS}
    ${object_path}   Set Variable  ${cells_info[0]['id']['configuration']}
    &{dlPtrs_dict}            Create dictionary  actDlPtrs                    ${actDlPtrs}
    ...                                          dlPtrsFreqDensityThresNrb0   274
    ...                                          dlPtrsFreqDensityThresNrb1   274
    &{pdcchAutoConfig_dict}   Create dictionary  initialBWPMode               ${initialBWPMode}
    ...                                          cellCoverageLevel            ${cellCoverageLevel}
    &{csirsForTracking_dict}  Create dictionary  csirsTrackingPeriod          ${csirsTrackingPeriod}
    ...                                          firstRE                      0
    ...                                          rbAllocation                 ${rbAllocation}
    ...                                          startRB                      0
    &{dlDataDmrsFdm_dict}     Create dictionary  actDlDataDmrsFdm             ${actDlDataDmrsFdm}
    ...                                          dlDataDmrsFdmThres64QamMcs   5
    ...                                          dlDataDmrsFdmThres256QamMcs  5
    Initialise delta store
    Add list parameters to delta  ${object_path}  dlPtrs             &{dlPtrs_dict}
    Add list parameters to delta  ${object_path}  pdcchAutoConfig    &{pdcchAutoConfig_dict}
    Add list parameters to delta  ${object_path}  csirsForTracking   &{csirsForTracking_dict}
    Add list parameters to delta  ${object_path}  dlDataDmrsFdm      &{dlDataDmrsFdm_dict}
    Add param to delta  ${object_path}  nrCellType                   ${nrCellType}
    Add param to delta  ${object_path}  ssPbchBlockPower             ${ssPbchBlockPower}
    Add param to delta  ${object_path}  dlQam256PowerBackoffSub6     ${dlQam256PowerBackoffSub6}
    Add param to delta  ${object_path}  pucchModeSelect              ${pucchModeSelect}
    Add param to delta  ${object_path}  actHighSpeedCell             ${actHighSpeedCell}
    Add param to delta  ${object_path}  dlDMRSAdditionalPosition     ${dlDMRSAdditionalPosition}
    Add param to delta  ${object_path}  ulDMRSAdditionalPosition     ${ulDMRSAdditionalPosition}
    Add param to delta  ${object_path}  msg1FrequencyStart           ${msg1FrequencyStart}
    Add param to delta  ${object_path}  reqMinNumPuschPrb            ${reqMinNumPuschPrb}
    Add param to delta  ${object_path}  pucchF3MaxCodeRate           ${pucchF3MaxCodeRate}
    Add param to delta  ${object_path}  actDl256Qam                  ${actDl256Qam}
    Add param to delta  ${object_path}  actPdschRmCsirsForTracking   ${actpdschrmcsirsfortracking}
    Add param to delta  ${object_path}  actPdschAtSsbSlots           ${actpdschatssbslots}
    Add param to delta  ${object_path}  puschMappingType             ${puschMappingType}
    Add param to delta  ${object_path}  actPucchAdditionalDmrs       ${actPucchAdditionalDmrs}

    Connect with runtime release  alias=cOAM
    ${release}  coam.Get sw release name    connection=cOAM
    Run keyword if  '${release}'!='SBTS23R4'
    ...             Add dynPdcchTdMgt parameter    ${object_path}

    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Wait until keyword succeeds   10min   1min   Verify all cells are onair with admin

Add dynPdcchTdMgt parameter
    [Arguments]
    ...    ${object_path}
    ...    ${actDynPdcchTd}=true

    &{dynPdcchTdMgt_dict}     Create dictionary  actDynPdcchTd                ${actDynPdcchTd}
    ...                                          pdcchBlockingThreshold       30
    ...                                          pdcchFreeThreshold           30

    Add list parameters to delta  ${object_path}  dynPdcchTdMgt      &{dynPdcchTdMgt_dict}

Set ulDMRSAdditionalPosition
    [Arguments]      ${ulDMRS}  ${dlDMRS}  ${actHighSpeedCell}
    Log to console   Setting DMRSAdditionalPosition to ${ulDMRS}
    ${cells_info}    coam.get cells info  nr  60  ${GNB_ALIAS}
    ${object_path}   Set Variable  ${cells_info[0]['id']['configuration']}
    Initialise delta store
    Add param to delta  ${object_path}  ulDMRSAdditionalPosition  ${ulDMRS}
    Add param to delta  ${object_path}  dlDMRSAdditionalPosition  ${dlDMRS}
    Add param to delta  ${object_path}  actHighSpeedCell  ${actHighSpeedCell}
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
    Wait until keyword succeeds   10min   1min   Verify all cells are onair with admin

actUlPtrs & ulDMRSAdditionalPosition change
    [Arguments]         ${actUlPtrs}=false
    ...                 ${ulPtrsFreqDensityThresNrb0}=279
    ...                 ${ulPtrsFreqDensityThresNrb1}=274
    ...                 ${ulDMRSAdditionalPosition}=Two additional DMRS
    Log to console   Setting actUlPtrs & ulDMRSAdditionalPosition
    ${cells_info}    coam.get cells info  nr  60  ${GNB_ALIAS}
    ${object_path}   Set Variable  ${cells_info[0]['id']['configuration']}
    &{ulPtrs_dict}    Create dictionary   actUlPtrs                   ${actUlPtrs}
    ...                                   ulPtrsFreqDensityThresNrb0  ${ulPtrsFreqDensityThresNrb0}
    ...                                   ulPtrsFreqDensityThresNrb1  ${ulPtrsFreqDensityThresNrb1}
    Initialise delta store
    Add list parameters to delta   ${object_path}  ulPtrs  &{ulPtrs_dict}
    Add param to delta             ${object_path}  ulDMRSAdditionalPosition  ${ulDMRSAdditionalPosition}
    ${delta}                  Collect delta store
    Recommission with delta from admin   ${delta}
    Wait until keyword succeeds   10min   1min   Verify all cells are onair with admin

actHighSpeedCell & ulDMRSAdditionalPosition change
    [Arguments]         ${actHighSpeedCell}=true
    ...                 ${ulDMRSAdditionalPosition}=Automatic
    ...                 ${dlDMRSAdditionalPosition}=Automatic
    Log to console   Setting actHighSpeedCell & ulDMRSAdditionalPosition
    ${cells_info}    coam.get cells info  nr  60  ${GNB_ALIAS}
    ${object_path}   Set Variable  ${cells_info[0]['id']['configuration']}
    Initialise delta store
    Add param to delta             ${object_path}  actHighSpeedCell  ${actHighSpeedCell}
    Add param to delta             ${object_path}  ulDMRSAdditionalPosition  ${ulDMRSAdditionalPosition}
    Add param to delta             ${object_path}  dlDMRSAdditionalPosition  ${dlDMRSAdditionalPosition}
    ${delta}                  Collect delta store
    Recommission with delta from admin   ${delta}
    Wait until keyword succeeds   10min   1min   Verify all cells are onair with admin

actHighSpeedCell & actUlPtrs & ulDMRSAdditionalPosition change
    [Arguments]         ${actUlPtrs}=true
    ...                 ${ulPtrsFreqDensityThresNrb0}=1
    ...                 ${ulPtrsFreqDensityThresNrb1}=24
    ...                 ${actHighSpeedCell}=true
    ...                 ${ulDMRSAdditionalPosition}=Automatic
    ...                 ${dlDMRSAdditionalPosition}=Automatic
    Log to console   Setting actUlPtrs & actHighSpeedCell & ulDMRSAdditionalPosition
    ${cells_info}    coam.get cells info  nr  60  ${GNB_ALIAS}
    ${object_path}   Set Variable  ${cells_info[0]['id']['configuration']}
    &{ulPtrs_dict}    Create dictionary   actUlPtrs                   ${actUlPtrs}
    ...                                   ulPtrsFreqDensityThresNrb0  ${ulPtrsFreqDensityThresNrb0}
    ...                                   ulPtrsFreqDensityThresNrb1  ${ulPtrsFreqDensityThresNrb1}
    Initialise delta store
    Add list parameters to delta   ${object_path}  ulPtrs  &{ulPtrs_dict}
    Add param to delta             ${object_path}  ulDMRSAdditionalPosition  ${ulDMRSAdditionalPosition}
    Add param to delta             ${object_path}  dlDMRSAdditionalPosition  ${dlDMRSAdditionalPosition}
    Add param to delta             ${object_path}  actHighSpeedCell          ${actHighSpeedCell}
    ${delta}                  Collect delta store
    Recommission with delta from admin   ${delta}
    Wait until keyword succeeds   10min   1min   Verify all cells are onair with admin

change actPucchAdditionalDmrs
    [Arguments]         ${actPucchAdditionalDmrs}=true
    Log to console   Setting actPucchAdditionalDmrs
    ${cells_info}    coam.get cells info  nr  60  ${GNB_ALIAS}
    ${object_path}   Set Variable  ${cells_info[0]['id']['configuration']}
    Initialise delta store
    Add param to delta             ${object_path}  actPucchAdditionalDmrs  ${actPucchAdditionalDmrs}
    ${delta}                  Collect delta store
    Recommission with delta from admin   ${delta}
    Wait until keyword succeeds   10min   1min   Verify all cells are onair with admin

# TODO: TPUT KWs
Check UL Tput Values
    [Arguments]     ${max_tputs}
    log to console  Check UL tputs absolute values for TC-A
    Should be true  int(${max_tputs[0]}) > ${0.98}*${UL_THRESHOLDS[0]}  msg=Tput is too small
    Should be true  int(${max_tputs[1]}) > ${0.98}*${UL_THRESHOLDS[1]}  msg=Tput is too small
    log to console  Check Tputs relational values
    Should be true  int(${max_tputs[0]}) >= int(${max_tputs[1]})  msg=Tput didn't drop with HighSpeedCell config

Check DL Tput Values
    [Arguments]    ${max_tputs}
    log to console  Check DL tputs absolute values for TC-C
    Should be true  int(${max_tputs[0]}) > ${0.98}*${DL_THRESHOLDS[0]}  msg=Tput is too small
    Should be true  int(${max_tputs[1]}) > ${0.98}*${DL_THRESHOLDS[1]}  msg=Tput is too small
    log to console  Check Tputs relational values
    Should be true  int(${max_tputs[0]}) >= int(${max_tputs[1]})  msg=Tput didn't drop with HighSpeedCell config

Compare tputs
    [Arguments]    ${max_tputs}
    log to console  Compare tputs from TC B27
    Should be true  int(${max_tputs[0]}) > int(${max_tputs[2]})          msg=First call tput isn't higher then trird one
    Should be true  int(${max_tputs[0]}) > ${0.95}*int(${max_tputs[1]})  msg=First call tput isn't similar to second one
    Should be true  int(${max_tputs[0]}) < ${1.05}*int(${max_tputs[1]})  msg=First call tput isn't similar to second one

ACDW check DL Tput Value
    [Arguments]     ${max_tputs}  ${tput_flag}
    log to console  Check DL tputs absolute values for ACDW TC
    Should be true  int(${max_tputs[0]}) > ${0.98}*${DL_THRESHOLDS[${tput_flag}-1]}  msg=Tput is too small

ACDW check UL Tput Value
    [Arguments]     ${max_tputs}  ${tput_flag}
    log to console  Check UL tputs absolute values for ACDW TC
    Should be true  int(${max_tputs[1]}) > ${0.98}*${UL_THRESHOLDS[${tput_flag}-1]}  msg=Tput is too small

QXDM tput check SA
    Run QXDM logs   60
    Parse HDF to TXT
    Copy logs from UEPC to VM
    uea.parse_tput_logs            path=${EXECDIR}/ue_logs.txt
    ${real_5g_dl}   uea.get_value  5g_dl  AvgPHY  max
    ${real_5g_dl}   Evaluate       int(${real_5g_dl})/${1000}
    ${real_5g_ul}   uea.get_value  5g_ul  AvgPHY  max
    ${real_5g_ul}   Evaluate       int(${real_5g_ul})/${1000}
    log to console  ${real_5g_dl}
    log to console  ${real_5g_ul}
    [Return]        ${real_5g_dl}  ${real_5g_ul}

QXDM tput check NSA
    Run QXDM logs   60
    Parse HDF to TXT
    Copy logs from UEPC to VM
    uea.parse_tput_logs            path=${EXECDIR}/ue_logs.txt
    ${real_5g_dl}   uea.get_value  5g_dl  AvgPHY  max
    ${real_5g_dl}   Evaluate       int(${real_5g_dl})/${1000}
    ${real_4g_dl}   uea.get_value  lte_dl  AvgPHY  max
    ${real_4g_dl}   Evaluate       int(${real_4g_dl})/${1000}
    ${real_dl}      Set Variable   ${real_5g_dl}+${real_4g_dl}
    ${real_5g_ul}   uea.get_value  5g_ul  AvgPHY  max
    ${real_5g_ul}   Evaluate       int(${real_5g_ul})/${1000}
    ${real_4g_ul}   uea.get_value  lte_ul  AvgPHY  max
    ${real_4g_ul}   Evaluate       int(${real_4g_ul})/${1000}
    ${real_ul}      Set Variable   ${real_5g_ul}+${real_4g_ul}
    log to console  ${real_dl}
    log to console  ${real_ul}
    [Return]        ${real_dl}  ${real_ul}

B27 compare tputs
    [Arguments]    ${tput_1}  ${tput_2}  ${tput_3}
    log to console  Compare tputs from TC B27
    Should be true  int(${tput_1}) > int(${tput_3})          msg=First call tput isn't higher then trird one
    Should be true  int(${tput_1}) > ${0.95}*int(${tput_2})  msg=First call tput isn't similar to second one
    Should be true  int(${tput_1}) < ${1.05}*int(${tput_2})  msg=First call tput isn't similar to second one

# TODO: Verify logs KWs
Verify cplane logs for one dmrs
    [Arguments]                     ${pcap_file_path}=/tmp/master/master.pcap  ${pos}=pos1
    log to console                  Convert pcap to pdml
    Run Keyword And Ignore error    Convert pcap to pdml      ${pcap_file_path}
    ${pdml_file_path}               pdml_path_from_pcap_path  ${pcap_file_path}
    log to console                  Verifying msg: dmrs-AdditionalPosition
    ${package_name_list}            Create list  nr-rrc.dmrs_AdditionalPosition
    &{dmrsAdditionalPosition_dict}  pdml_file_to_dict  ${pdml_file_path}  ${package_name_list}
    Should Not be Empty             ${dmrsAdditionalPosition_dict}
    FOR  ${key}  IN  @{dmrsAdditionalPosition_dict}
        ${dmrs_format}  get from dictionary  ${dmrsAdditionalPosition_dict[${key}]}  dmrs-AdditionalPosition:
        Should be True  '${dmrs_format}'=='${pos}'
    END
    [Teardown]          Run Keywords
    ...                 OperatingSystem.Copy file    ${pcap_file_path}  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/  AND
    ...                 OperatingSystem.Copy file    ${pdml_file_path}  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/

Verify cplane logs for two dmrs
    [Arguments]                     ${pcap_file_path}=/tmp/master/master.pcap
    log to console                  Convert pcap to pdml
    Run Keyword And Ignore error    Convert pcap to pdml      ${pcap_file_path}
    ${pdml_file_path}               pdml_path_from_pcap_path  ${pcap_file_path}
    log to console                  Verifying msg: dmrs-AdditionalPosition
    ${dmrs_info}                    Run  grep -o -P '(?<=dmrs-AdditionalPosition).{15}' ${pdml_file_path}
    @{dmrs_list}                    Split string  ${dmrs_info}  \n
    FOR  ${dmrs}  IN  @{dmrs_list}
         Should be True  '${dmrs}'==' is NOT present'
    END
    [Teardown]          Run Keywords
    ...                 OperatingSystem.Copy file    ${pcap_file_path}  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/  AND
    ...                 OperatingSystem.Copy file    ${pdml_file_path}  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/

Verify cplane logs for no actUlPtrs
    [Arguments]                     ${pcap_file_path}=/tmp/master/master.pcap
    log to console                  Convert pcap to pdml
    Run Keyword And Ignore error    Convert pcap to pdml      ${pcap_file_path}
    ${pdml_file_path}               pdml_path_from_pcap_path  ${pcap_file_path}
    log to console                  Verifying msg: phaseTrackingRS
    ${ptrs_info}                    Run  grep -o -P '(?<=phaseTrackingRS).{15}' ${pdml_file_path}
    @{ptrs_list}                    Split string  ${ptrs_info}  \n
    FOR  ${ptrs}  IN  @{ptrs_list}
         Should be True  '${ptrs}'==' is NOT present'
    END
    [Teardown]          Run Keywords
    ...                 OperatingSystem.Copy file    ${pcap_file_path}  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/  AND
    ...                 OperatingSystem.Copy file    ${pdml_file_path}  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/

Verify cplane logs for actUlPtrs
    [Arguments]                     ${pcap_file_path}=/tmp/master/master.pcap
    log to console                  Convert pcap to pdml
    Run Keyword And Ignore error    Convert pcap to pdml      ${pcap_file_path}
    ${pdml_file_path}               pdml_path_from_pcap_path  ${pcap_file_path}
    log to console                  Verifying msg: phaseTrackingRS
    ${item0_list}            Create list  itf_l2_ps_user_UserModifyReq.frequencyDensity_item_0.ptrsPrb
    ${item1_list}            Create list  itf_l2_ps_user_UserModifyReq.frequencyDensity_item_1.ptrsPrb
    &{frequencyDensity_item_0}         pdml_file_to_dict  ${pdml_file_path}  ${item0_list}
    &{frequencyDensity_item_1}         pdml_file_to_dict  ${pdml_file_path}  ${item1_list}
    Should Not be Empty             ${frequencyDensity_item_0}
    Should Not be Empty             ${frequencyDensity_item_1}
    FOR  ${key}  IN  @{frequencyDensity_item_0}
        ${phaseTrackingRS}  get from dictionary  ${frequencyDensity_item_0[${key}]}  ptrsPrb
        Should be True  '${phaseTrackingRS}'=='0x0004'
    END
    FOR  ${key}  IN  @{frequencyDensity_item_1}
        ${phaseTrackingRS}  get from dictionary  ${frequencyDensity_item_1[${key}]}  ptrsPrb
        Should be True  '${phaseTrackingRS}'=='0x0018'
    END
    [Teardown]          Run Keywords
    ...                 OperatingSystem.Copy file    ${pcap_file_path}  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/  AND
    ...                 OperatingSystem.Copy file    ${pdml_file_path}  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/

Verify PtrsTimeDensity
    [Arguments]  ${pdml_file_path}  ${PtrsTimeDensity}
    log to console             Checking ulPtrsTimeDensity
    ${package_name_list}       Create list  ulPtrsTimeDensity
    &{ulPtrsTimeDensity_dict}  pdml_file_to_dict  ${pdml_file_path}  ${package_name_list}
    Should Not be Empty        ${ulPtrsTimeDensity_dict}
    FOR  ${key}  IN  @{ulPtrsTimeDensity_dict}
      ${ulPtrsTimeDensity}  get from dictionary  ${ulPtrsTimeDensity_dict[${key}]}  ulPtrsTimeDensity
      Should be True  '${ulPtrsTimeDensity}'=='${PtrsTimeDensity}'
    END

Verify PtrsFrequencyDencity
    [Arguments]  ${pdml_file_path}  ${PtrsFrequencyDencity}
    log to console                  Checking ulPtrsFrequencyDensity
    ${package_name_list}            Create list  ulPtrsFrequencyDensity
    &{ulPtrsFrequencyDensity_dict}  pdml_file_to_dict  ${pdml_file_path}  ${package_name_list}
    Should Not be Empty             ${ulPtrsFrequencyDensity_dict}
    FOR  ${key}  IN  @{ulPtrsFrequencyDensity_dict}
      ${ulPtrsFrequencyDensity}  get from dictionary  ${ulPtrsFrequencyDensity_dict[${key}]}  ulPtrsFrequencyDensity
      Should be True  '${ulPtrsFrequencyDensity}'=='${PtrsFrequencyDencity}'
    END

Verify PuschPrb
    [Arguments]  ${pdml_file_path}  ${Prb}
    log to console        Checking PuschPrb
    ${package_name_list}  Create list  UlData_puschReceiveReqGrant_t.numOfPrb  #UlData_PuschReceiveReq.grants_item_0.numOfPrb
    &{PuschPrb_dict}      pdml_file_to_dict  ${pdml_file_path}  ${package_name_list}
    Should Not be Empty   ${PuschPrb_dict}
    ${numOfPrb_list}      Create List
    FOR  ${key}  IN  @{PuschPrb_dict}
      ${PuschPrb}  get from dictionary  ${PuschPrb_dict[${key}]}  numOfPrb
      Append to List  ${numOfPrb_list}  ${PuschPrb}
    END
    ${max_prb}      prb_check  ${Prb}  ${numOfPrb_list}
    Should be True  ${max_prb}

Verify bip logs for 8792B
    [Arguments]                   ${pcap_file_path}  ${PtrsTimeDensity}  ${PtrsFrequencyDencity}  ${Prb}
    log to console                Convert pcap to pdml
    Run Keyword And Ignore error  Convert pcap to pdml      ${pcap_file_path}
    ${pdml_file_path}             pdml_path_from_pcap_path  ${pcap_file_path}
    Verify PtrsTimeDensity        ${pdml_file_path}         ${PtrsTimeDensity}
    Verify PtrsFrequencyDencity   ${pdml_file_path}         ${PtrsFrequencyDencity}
    Run keyword if                ${Prb}==235
    ...                           Verify PuschPrb  ${pdml_file_path}  ${Prb}
    [Teardown]          Run Keywords
    ...                 OperatingSystem.Copy file    ${pcap_file_path}  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/  AND
    ...                 OperatingSystem.Copy file    ${pdml_file_path}  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/

Verify cplane logs for actPucchAdditionalDmrs=false
    [Arguments]                     ${pcap_file_path}=/tmp/master/master.pcap
    log to console                  Convert pcap to pdml
    Run Keyword And Ignore error    Convert pcap to pdml      ${pcap_file_path}
    ${pdml_file_path}               pdml_path_from_pcap_path  ${pcap_file_path}
    log to console                  Verifying msg: additionalDMRS
    ${additionalDMRS}               Run  grep -o -P '(?<=additionalDMRS ).{14}' ${pdml_file_path}
    @{additionalDMRS_list}          Split string  ${additionalDMRS}  \n
    FOR  ${additionalDMRS}  IN  @{additionalDMRS_list}
         Should be True  '${additionalDMRS}'=='is NOT present'
    END
    [Teardown]          Run Keywords
    ...                 OperatingSystem.Copy file    ${pcap_file_path}  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/  AND
    ...                 OperatingSystem.Copy file    ${pdml_file_path}  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/

Verify cplane logs for actPucchAdditionalDmrs=true
    [Arguments]                     ${pcap_file_path}=/tmp/master/master.pcap
    log to console                  Convert pcap to pdml
    Run Keyword And Ignore error    Convert pcap to pdml      ${pcap_file_path}
    ${pdml_file_path}               pdml_path_from_pcap_path  ${pcap_file_path}
    ${package_name_list}            Create list  nr-rrc.additionalDMRS
    &{additionalDMRS_dict}          pdml_file_to_dict  ${pdml_file_path}  ${package_name_list}
    Should Not be Empty             ${additionalDMRS_dict}
    log to console                  Verifying msg: additionalDMRS
    ${dmrs_flag}                    check_dmrs  ${additionalDMRS_dict}
    Should be True                  ${dmrs_flag}
    [Teardown]          Run Keywords
    ...                 OperatingSystem.Copy file    ${pcap_file_path}  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/  AND
    ...                 OperatingSystem.Copy file    ${pdml_file_path}  ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/

# TODO: KWs for subitem B and ACDW
B23 Part A
    [Arguments]  ${UE_alias}  ${capabilities}  ${cells_to_mirror}
    Log to console        >> Part A with SA UE: actUlPtrs=false, ulDMRS=2 <<
    Log to console        Capabilities:${capabilities}
    Detach UEs from cell  ${UE_alias}
    Start tcpdump on gnb ASIK master
    sleep  5s
    Attach UEs to cell    ${UE_alias}
    Start UL for UEs      ${UE_alias}  ${UL_DURATION_B1}  ${UL_THROUGHPUT_1}  udp
    sleep  15s
    ${cplane_path}  Stop pcap collection in gNB ASIK master
#    Start L1L2 logs gathering  time=5  bb_slot_1=false  bb_slot_2=false  bb_slot_3=true  filter=${ABIO_FILTER}
#    ${bip_path}     Stop L1L2 logs gathering and download pcap
    Start capturing interface mirroring logs  ${cells_to_mirror}
#    ${bip_path}  Collect interface mirroring logs
    Verify cplane logs for no actUlPtrs  pcap_file_path=${cplane_path}
    Await datatransfers finish
    Detach UEs from cell  ${UE_alias}

B23 Part B
    [Arguments]  ${UE_alias}  ${capabilities}  ${UL_THROUGHPUT}  ${density}  ${freq}  ${prbs}  ${cells_to_mirror}
    Detach UEs from cell  ${UE_alias}
    Log to console        Capabilities:${capabilities}
    Start tcpdump on gnb ASIK master
    sleep  5s
    Attach UEs to cell    ${UE_alias}
    Start UL for UEs      ${UE_alias}  ${UL_DURATION_B1}  ${UL_THROUGHPUT}  udp
    sleep  15s
    ${cplane_path}  Stop pcap collection in gNB ASIK master
#    Start L1L2 logs gathering  time=5  bb_slot_1=false  bb_slot_2=false  bb_slot_3=true  filter=${ABIO_FILTER}
#    ${bip_path}     Stop L1L2 logs gathering and download pcap
    Start capturing interface mirroring logs  ${cells_to_mirror}
    ${bip_path}  Collect interface mirroring logs
    Verify cplane logs for actUlPtrs  pcap_file_path=${cplane_path}
    Verify bip logs for 8792B  ${bip_path}  ${density}  ${freq}  ${prbs}
    Await datatransfers finish
    Detach UEs from cell  ${UE_alias}

Perform B27 test
    [Arguments]  ${UE_alias}  ${capabilities}  ${cells_to_mirror}
    Get UEs                 ${UE_alias}  ${capabilities}
    Detach UEs from cell    ${UE_alias}
    Start syslog capture    log_name=${LOG_NAME}  alias=8792_b27
    Attach UEs to cell      ${UE_alias}
    Start UL for UEs        ${UE_alias}  ${UL_DURATION_B2}  ${UL_THROUGHPUT_1}  tcp
    sleep  20s
#    Start L1L2 logs gathering  time=5  bb_slot_1=false  bb_slot_2=false  bb_slot_3=true  filter=${ABIO_FILTER}
#    ${bip_path}   Stop L1L2 logs gathering and download pcap
    Start capturing interface mirroring logs  ${cells_to_mirror}
    ${bip_path}  Collect interface mirroring logs
#    ${dl}  ${ul}  QXDM tput check SA
    sleep  60s
    Stop syslog capture  alias=8792_b27
    ${dl}  ${ul}    Get max DLUL from syslog  path_to_syslog=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/${LOG_NAME}
    Log to console      dl:${dl}
    Run  rm ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/${LOG_NAME}
#    Delete UE logs from UEPC
#    Delete UE logs from VM
#    Await datatransfers finish
    Detach UEs from cell   ${UE_alias}
    Stop using UEs         ${UE_alias}
    [Return]  ${bip_path}  ${ul}

ACDW call test
    [Arguments]  ${UE_alias}  ${run}  ${cells_to_mirror}
    Get UEs               ${UE_alias}  ${SA_CAPA}
    Detach UEs from cell  ${UE_alias}
    Start tcpdump on gnb ASIK master
    sleep  5s
    Start syslog capture  log_name=${LOG_NAME}  alias=8792_acdw_1
    Attach UEs to cell    ${UE_alias}
    Start DL for UEs      ${UE_alias}  ${DL_DURATION_ACDW}  ${DL_THROUGHPUT}  tcp
#    ${dl}  ${ul}  QXDM tput check SA
    sleep  20s
    Stop syslog capture  alias=8792_acdw_1
    ${dl}  ${ul}    Get max DLUL from syslog  path_to_syslog=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/${LOG_NAME}
    Should be true        int(${dl}) > ${MARGIN}*${DL_THRESHOLDS_ACDW[${run}-${1}]}  msg=Tput is too small
    Run  rm ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/${LOG_NAME}
#    Delete UE logs from UEPC
#    Delete UE logs from VM
    Start syslog capture  log_name=${LOG_NAME}  alias=8792_acdw_2
    Start UL for UEs      ${UE_alias}  ${UL_DURATION_ACDW}  ${UL_THROUGHPUT}  tcp
#    ${dl}  ${ul}  QXDM tput check SA
    sleep  20s
    Stop syslog capture  alias=8792_acdw_2
    ${dl}  ${ul}    Get max DLUL from syslog  path_to_syslog=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/${LOG_NAME}
    Should be true        int(${dl}) > ${MARGIN}*${DL_THRESHOLDS_ACDW[${run}-${1}]}  msg=Tput is too small
    Should be true        int(${ul}) > ${MARGIN}*${UL_THRESHOLDS_SA_ACDW[${run}-${1}]}  msg=Tput is too small
    Run  rm ${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/${LOG_NAME}
#    Delete UE logs from UEPC
#    Delete UE logs from VM
#    Start L1L2 logs gathering  time=10  bb_slot_1=false  bb_slot_2=false  bb_slot_3=true  filter=${ABIO_FILTER}
#    ${bip_path}     Stop L1L2 logs gathering and download pcap  remote_path=${EXECDIR}/8792_bip${run}.pcap
    Start capturing interface mirroring logs  ${cells_to_mirror}
#    ${bip_path}  Collect interface mirroring logs  output_file_name=8792_bip${run}.pcap
    ${cplane_path}  Stop pcap collection in gNB ASIK master
    Run  cp ${cplane_path} ${EXECDIR}/8792_cplane${run}.pcap
    ${cplane_path}  Set Variable  ${EXECDIR}/8792_cplane${run}.pcap
    Await datatransfers finish
    Detach UEs from cell      ${UE_alias}
    Stop using UEs            ${UE_alias}
    Delete pyro_server UEPC
    [Return]  ${cplane_path}
