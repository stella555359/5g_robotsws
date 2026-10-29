*** Settings ***
Documentation
    ...  TC for WCDMA RAT reset from ADMIN API. At first WCDMA RAT reset is performed (whole operation from sending trigger
    ...  request to WCDMA reaching OnAir again). Then InfoModel log gathered from RAT reset is saved and then checked in order
    ...  to find all DSPs and cells states changes.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${WCDMA_RAT_RESET_TIMEOUT}  180  # Timeout (in seconds) for ADMIN API WCDMA RAT reset.


*** Keywords ***
TC__STATE__WCDMA_RAT_reset_from_ADMIN
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7656
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7656 - Test creation
    ...  - 09.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-10029 - KPI - first WCDMA cell up after WCDMA reset request
    ...  - 03.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18397 - Adding new keyword to TC
    ...  - 09.07.2020 - https://jira3.int.net.nokia.com/browse/TAT-19860 - Adding TL recovery action
    ...  - 03.08.2020 - https://jira3.int.net.nokia.com/browse/TAT-20007 - Deleted KPI reporting to WCTO database
    ...  - 07.12.2020 - https://jira3.int.net.nokia.com/browse/TAT-20628 - All steps timeouts increased to 30 min
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-7656_01.png#

    Set Tags  CA-SWM  OWNER-grzegorz.gulaj@nokia.com  AUTHOR-patryk.furman@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com  GROUP_IN_CHARGE-TIM_2_Vrf
    ...  PHASE-CR  SW-SBTS17  CABLING-SBTS_03_UEManager  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923  FEATURE-RP001486_RP000923
    ...  FEATURE-RP0001145_RP000923

    Step 1: Get All WCDMA DSPs Dist Names
    Step 2: Perform WCDMA RAT Reset
    Step 3: Save Infomodel Log For TC Checks
    Step 4: Check If WCDMA DSPs Were Restarted
    Step 5: Check If WCDMA Cells Were Degraded
    Step 6: Check If Cells On Other RATs Were Operational
    Step 7: Check If WCDMA Cells Are Operational


Step 1: Get All WCDMA DSPs Dist Names
    [Timeout]  30 min

    Log  Step 1: Get all WCDMA DSPs dist names  console=True
    ${dsps_dist_names}  Infomodel Get All DSPs Dist Names For Given RAT  WCDMA
    Log  WCDMA DSPs list: ${dsps_dist_names}  console=True
    Set Test Variable  ${DSPS_DIST_NAMES}  ${dsps_dist_names}


Step 2: Perform WCDMA RAT Reset
    [Timeout]  30 min

    Log  Step 2: Perform WCDMA RAT reset  console=True
    Reset Rat  WCDMA  timeout=${WCDMA_RAT_RESET_TIMEOUT}
    Log  WCDMA RAT reset has been performed via ADMIN API  console=True


Step 3: Save Infomodel Log For TC Checks
    [Timeout]  30 min

    Log  Step 3: Save Infomodel log for TC checks  console=True
    Sleep  120s  Wait for DSPs states save inside IM
    Save Infomodel Log  ${BTS_FILES}/IM/InfoModel_log_after_WCDMA_RAT_reset.ims2
    Set Test Variable  ${IM_LOG_PATH}  ${BTS_FILES}/IM/InfoModel_log_after_WCDMA_RAT_reset.ims2
    Log  Infomodel log saved under ${IM_LOG_PATH}  console=True


Step 4: Check If WCDMA DSPs Were Restarted
    [Timeout]  30 min

    Log  Step 4: Check if WCDMA DSPs were restarted  console=True
    Infomodel Check If DSPs Were Restarted According To Ims File  ${IM_LOG_PATH}  ${DSPS_DIST_NAMES}
    Log  All DSPs were restarted during WCDMA RAT reset  console=True


Step 5: Check If WCDMA Cells Were Degraded
    [Timeout]  30 min

    Log  Step 5: Check if WCDMA cells were degraded  console=True
    ${wcdma_cells_objects}  Query Infomodel  get list ${DIST_WCDMA_CELL}
    ${wcdma_cells_runtime_objects}  Query Infomodel  get list //WNBTS_R-*/WNCEL_R-*
    FOR  ${cell_object}  ${runtime_object}  IN ZIP  ${wcdma_cells_objects}  ${wcdma_cells_runtime_objects}
        Initialize Ims2 Validator  ${IM_LOG_PATH}
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.operationalState: ${ENABLED} -> ${DISABLED}]
        Validate Ims2
        Log  ${cell_object.dist_name} states changed: operationalState: Enabled -> Disabled  console=True
        Log  ${runtime_object.dist_name} states changed: stateInfo.usageState: Active -> Idle  console=True
        Initialize Ims2 Validator  ${IM_LOG_PATH}
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.blockingState]
        Run Keyword And Expect Error  InfoModelIms2ValidationException:*
        ...  Validate Ims2
        Log  ${cell_object.dist_name} administrativeState and blockingState remained unchanged  console=True
    END
    Log  All WCDMA cells were degraded during WCDMA RAT reset  console=True


Step 6: Check If Cells On Other RATs Were Operational
    [Timeout]  30 min

    Log  Step 6: Check if cells on other RATs were operational  console=True
    Infomodel Check If Cells In RAT Were Operational According To IM Log  LTE  ${IM_LOG_PATH}
    Infomodel Check If Cells In RAT Were Operational According To IM Log  GSM  ${IM_LOG_PATH}


Step 7: Check If WCDMA Cells Are Operational
    [Timeout]  30 min

    Log  Step 7: Check if WCDMA cells are operational  console=True
    ${are_wncels_online}  Verify WCDMA Cells States
    Should Be True  ${are_wncels_online}  Not all WCDMA cells are online after WCDMA RAT reset


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
    Recover Test Line By Power Reset
