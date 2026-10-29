*** Settings ***
Documentation
    ...  TC for WCDMA RAT reset indicated via parameter change. Parameter change is performed via ADMIN parameter recommissioning
    ...  procedure. User needs to provide proper parameter which will indicate such situation. Default parameter is
    ...  "midIubDelayThreshold" with value "160". If the value inside SCF is the same as value in TC
    ...  it will fail because such scenario won't trigger RAT reset. Parameter is reverted at the end of TC to old value.
    ...  After reset WCDMA cells are checked in real time and then DSP restart and other RATs statuses are checked via Infomodel
    ...  log.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${PARAMETER_SCF_DIST_NAME}  ${None}  # Parameter dist_name path from SCFC
${PARAMETER_ABBREVIATION}  midIubDelayThreshold  # Parameter abbreviation from SCFC
${PARAMETER_VALUE}  160  # Parameter value
${SKIP_PARAM_RELATION_ERRORS}  ${TRUE}  # Should recommissioning be done forcefully with skipping param relation errors (True, False)
${RECOMMISSIONING_TIMEOUT}  300  # Timeout for recommissioning procedure [s]
${WCDMA_OPERATIONAL_TIMEOUT}  360  # Timeout until all WCDMA cells are operational [s]


*** Keywords ***
TC__STATE__WCDMA_RAT_reset__parameter_change__ADMIN
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7990
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7990 - Test creation
    ...  - 20.06.2018 - https://jira3.int.net.nokia.com/browse/TAT-10383 - Add value recovering
    ...  - 20.09.2018 - https://jira3.int.net.nokia.com/browse/TAT-11996 - WCDMA cells states verification moved accordingly to step 10 and step 15
    ...  - 20.09.2018 - https://jira3.int.net.nokia.com/browse/TAT-12103 - Change verification whether WCDMA cells were degraded after RAT reset
    ...  - 12.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16544 - PARAMETER_SCF_DIST_NAME name taken from live BTS status.
    ...  - 27.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-17261 - default PARAMETER_ABBREVIATION and PARAMETER_VALUE change.
    ...  - 01.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17736 - updated test documentation.
    ...  - 10.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19678 - common test teardown changing
    ...  - 13.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21188 - Align "FOR loop" to python3 migration
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-7990_01.png#

    Set Tags  CA-STATE  OWNER-grzegorz.gulaj@nokia.com  AUTHOR-patryk.furman@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CR  SW-SBTS17  CABLING-SBTS_03_UEManager  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923
    ...  FEATURE-RP001486_RP000923  FEATURE-RP0001145_RP000923

    Step 0: Set PARAMETER_SCF_DIST_NAME
    Step 1: Get All WCDMA DSPs Dist Names
    Step 2: Save BTS SCF Before Parameter Recommissioning
    Step 3: Check If Chosen Parameter Value Is Not Included Into SCF Before Parameter Recommissioning
    Step 4,11: SBTS Parameter Recommissioning Via ADMIN API  ${PARAMETER_SCF_DIST_NAME}  ${PARAMETER_ABBREVIATION}  update  ${PARAMETER_VALUE}
    ...  ${SKIP_PARAM_RELATION_ERRORS}  ${RECOMMISSIONING_TIMEOUT}
    Step 5: Save BTS SCF After Parameter Recommissioning
    Step 6: Check If Chosen Parameter Value Is Included Into SCF After Parameter Recommissioning
    Step 7,12: Save Infomodel Log For DSP And Other RATs Cells Check  InfoModel_log_after_WCDMA_RAT_reset_first
    Step 8: Check If WCDMA Cells Were Degraded After WCDMA RAT Reset
    Step 9: Check If WCDMA DSPs Were Restarted
    Step 10: Check Operational State All Cells On All RATs
    Step 4,11: SBTS Parameter Recommissioning Via ADMIN API  ${PARAMETER_SCF_DIST_NAME}  ${PARAMETER_ABBREVIATION}  update  ${OLD_PARAM_VALUE}
    ...  ${SKIP_PARAM_RELATION_ERRORS}  ${RECOMMISSIONING_TIMEOUT}
    Step 7,12: Save Infomodel Log For DSP And Other RATs Cells Check  InfoModel_log_after_WCDMA_RAT_reset_second
    Step 13: Check If WCDMA Cells Were Degraded After WCDMA RAT Reset
    Step 14: Check If WCDMA DSPs Were Restarted
    Step 15: Check Operational State All Cells On All RATs


Step 0: Set PARAMETER_SCF_DIST_NAME
    [Documentation]  Step will verify if test variable ${PARAMETER_SCF_DIST_NAME} is already set
    ...        if not then variable will be set to actual path to LNBTS/WNBTS

    ${bts_id}  Admin Get BTS ID
    ${mrbts_wnbts_path}  Set Variable  MRBTS-${bts_id}/WNBTS-1
    ${parameter_scf_dist_name}  Set Variable If  "${PARAMETER_SCF_DIST_NAME}"=="${None}"  ${mrbts_wnbts_path}  ${PARAMETER_SCF_DIST_NAME}
    Set Test Variable  ${PARAMETER_SCF_DIST_NAME}


Step 1: Get All WCDMA DSPs Dist Names
    [Timeout]  15 min

    Log  Step 1: Get all WCDMA DSPs dist names  console=True
    ${dsps_dist_names}  Infomodel Get All DSPs Dist Names For Given RAT  WCDMA
    Log  WCDMA DSPs list: ${dsps_dist_names}  console=True
    Set Test Variable  ${DSPS_DIST_NAMES}  ${dsps_dist_names}


Step ${index}: Save BTS SCF ${when} Parameter Recommissioning
    [Timeout]  15 min

    Log  Step ${index}: Save BTS SCF ${when} parameter recommissioning  console=True
    Collect SCF  ${TEST_FILES}/SCF_${when}_recommissioning.xml
    Log  SCF has been saved under ${TEST_FILES}/SCF_${when}_recommissioning.xml  console=True
    ${scf_xml}  Parse Xml  ${TEST_FILES}/SCF_${when}_recommissioning.xml
    Set Test Variable  ${SCF_XML}  ${scf_xml}


Step 3: Check If Chosen Parameter Value Is Not Included Into SCF Before Parameter Recommissioning
    [Timeout]  15 min

    Log  Step 3: Check if chosen parameter value is not included into SCF before parameter recommissioning  console=True
    ${old_parameter_xml}  Evaluate Xpath  ${SCF_XML}  .//*[@distName="${PARAMETER_SCF_DIST_NAME}"]/child::*[@name="${PARAMETER_ABBREVIATION}"]
    ${old_parameter_value}  Get Element Text  ${old_parameter_xml[0]}
    Should Not Be Equal  ${PARAMETER_VALUE}  ${old_parameter_value}  Parameter in SCF is the same as parameter in TC input.
    Set Test Variable  ${OLD_PARAM_VALUE}  ${old_parameter_value}
    Log
    ...  Parameter ${PARAMETER_ABBREVIATION} values are different in both sources ${PARAMETER_VALUE}!=${OLD_PARAM_VALUE}.Recommissioning will proceed
    ...  console=True


Step 4,11: SBTS Parameter Recommissioning Via ADMIN API
    [Arguments]  ${dist_name}  ${parameter}  ${operation}  ${value}  ${skip_parameter_relation_errors}  ${timeout}
    [Timeout]  15 min

    Log  Step 4,11: SBTS parameter recommissioning via ADMIN API  console=True
    Perform Parameter Recommissioning  dist_name=${dist_name}  parameter=${parameter}  operation=${operation}  value=${value}
    ...  skip_parameter_relation_errors=${skip_parameter_relation_errors}  timeout=${timeout}
    Log  Recommissioning of ${dist_name} parameter ${parameter} = ${value} done.  console=True
    Set Test Variable  ${WAS_RECOMMISSIONED}  ${TRUE}


Step 6: Check If Chosen Parameter Value Is Included Into SCF After Parameter Recommissioning
    [Timeout]  15 min

    Log  Step 6: Check if chosen parameter value is included into SCF after parameter recommissioning  console=True
    XML.Element Text Should Be  ${SCF_XML}  ${PARAMETER_VALUE}
    ...  .//*[@distName="${PARAMETER_SCF_DIST_NAME}"]/child::*[@name="${PARAMETER_ABBREVIATION}"]
    Log  Parameter ${PARAMETER_ABBREVIATION} value equals ${PARAMETER_VALUE}  console=True


Step 7,12: Save Infomodel Log For DSP And Other RATs Cells Check
    [Arguments]  ${im_log_name}
    [Timeout]  15 min

    Log  Step 7,12: Save Infomodel log for DSP and other RATs cells check  console=True
    Sleep  120s  Wait for DSPs states save inside IM
    Save Infomodel Log  ${BTS_FILES}/IM/${im_log_name}.ims2
    Set Test Variable  ${IM_LOG_PATH}  ${BTS_FILES}/IM/${im_log_name}.ims2
    Log  Infomodel log saved under ${IM_LOG_PATH}  console=True


Step ${index}: Check If WCDMA Cells Were Degraded After WCDMA RAT Reset
    [Timeout]  15 min

    Log  Step ${index}: Check if WCDMA cells were degraded after WCDMA RAT reset  console=True
    ${wcdma_cells_objects}  Query Infomodel  get list ${DIST_WCDMA_CELL}
    ${wcdma_cells_runtime_objects}  Query Infomodel  get list //WNBTS_R-*/WNCEL_R-*
    FOR  ${cell_object}  ${runtime_object}  IN ZIP  ${wcdma_cells_objects}  ${wcdma_cells_runtime_objects}
        Initialize Ims2 Validator  ${IM_LOG_PATH}
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.operationalState: ${ENABLED} -> ${DISABLED}]
        # Add expected ims2 event  change ${runtime_object.dist_name} [stateInfo.usageState: ${Active_} -> ${Idle_}]
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.availabilityStatus: ${ONLINE} -> ${OFFLINE}]
        Validate Ims2
        Log  ${cell_object.dist_name} states changed: operationalState: Enabled -> Disabled  console=True
        Log  ${runtime_object.dist_name} states changed: stateInfo.usageState: Online -> Offline  console=True
        Initialize Ims2 Validator  ${IM_LOG_PATH}
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.blockingState]
        Run Keyword And Expect Error  InfoModelIms2ValidationException:*
        ...  Validate Ims2
        Log  ${cell_object.dist_name} administrativeState and blockingState remained unchanged  console=True
    END
    Log  All WCDMA cells were degraded during WCDMA RAT reset  console=True


Step ${index}: Check If WCDMA DSPs Were Restarted
    [Timeout]  15 min

    Log  Step ${index}: Check if WCDMA DSPs were restarted  console=True
    Infomodel Check If DSPs Were Restarted According To Ims File  ${IM_LOG_PATH}  ${DSPS_DIST_NAMES}
    Log  All DSPs were restarted during WCDMA RAT reset  console=True


Step ${index}: Check Operational State All Cells On All RATs
    Log  Step ${index}: Check operational state all cells on all RATs  console=True
    Infomodel Check If Cells In RAT Were Operational According To IM Log  LTE  ${IM_LOG_PATH}
    Infomodel Check If Cells In RAT Were Operational According To IM Log  GSM  ${IM_LOG_PATH}
    Assert Every  WNCEL  usageState=${ACTIVE}, operationalState=${ENABLED}, blockingState=${UNBLOCKED}  timeout=${WCDMA_OPERATIONAL_TIMEOUT}s
    Log  All WCDMA cells are operational with states usageState=${ACTIVE}, operationalState=${ENABLED}, blockingState=${UNBLOCKED}  console=True


TC Setup
    Common Test Setup


TC Teardown
    Run Keyword If  ${WAS_RECOMMISSIONED}
    ...  Run Keyword And Ignore Error
    ...  Step 4,11: SBTS Parameter Recommissioning Via ADMIN API  ${PARAMETER_SCF_DIST_NAME}
    ...  ${PARAMETER_ABBREVIATION}
    ...  update
    ...  ${OLD_PARAM_VALUE}
    ...  ${SKIP_PARAM_RELATION_ERRORS}
    ...  ${RECOMMISSIONING_TIMEOUT}
    Common Test Teardown
