*** Settings ***
Documentation
    ...  TC for LTE RAT reset from ADMIN API. At first LTE RAT reset is performed (whole operation from sending trigger
    ...  request to LTE reaching OnAir again). Then InfoModel log gathered from RAT reset is saved and then checked in order
    ...  to find all LTE DSPs and cells states changes.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${LTE_RAT_RESET_TIMEOUT}  180  # Timeout (in seconds) for ADMIN API LTE RAT reset.


*** Keywords ***
TC__STATE__LTE_RAT_reset_from_ADMIN
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7655
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 06.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7655 - Test creation
    ...  - 09.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-10030 - KPI - first LTE cell up after LTE reset request
    ...  - 3.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18397 - Adding new keyword to TC
    ...  - 28.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19473 - DSP state validation change
    ...  - 13.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21188 - Align "FOR loop" to python3 migration
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-7655_01.png#

    Set Tags  CA-SWM  OWNER-grzegorz.gulaj@nokia.com  AUTHOR-patryk.furman@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com  GROUP_IN_CHARGE-TIM_2_Vrf
    ...  PHASE-CR  SW-SBTS17  CABLING-SBTS_03_UEManager  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923  FEATURE-RP001486_RP000923
    ...  FEATURE-RP0001145_RP000923  FEATURE-RP001658_LTE3625  FEATURE-RP002081_LTE3145  FEATURE-RP002081_LTE3623

    Step 1: Get All LTE DSPs Dist Names
    Step 2: Perform LTE RAT Reset
    Step 3: Save Infomodel Log For TC Checks
    Step 4: Check If LTE DSPs Were Restarted
    Step 5: Check If LTE Cells Were Degraded
    Step 6: Check If Cells On Other RATs Were Operational
    Step 7: Check If LTE Cells Are Operational


Step 1: Get All LTE DSPs Dist Names
    [Timeout]  15 min

    Log  Step 1: Get all LTE DSPs dist names  console=True
    ${dsps_dist_names}  Infomodel Get All DSPs Dist Names For Given RAT  LTE
    Log  LTE DSPs list: ${dsps_dist_names}  console=True
    Set Test Variable  ${DSPS_DIST_NAMES}  ${dsps_dist_names}


Step 2: Perform LTE RAT Reset
    [Timeout]  15 min

    Log  Step 2: Perform LTE RAT reset  console=True
    Reset Rat  LTE  timeout=${LTE_RAT_RESET_TIMEOUT}
    Log  LTE RAT reset has been performed via ADMIN API  console=True


Step 3: Save Infomodel Log For TC Checks
    [Timeout]  15 min

    Log  Step 3: Save Infomodel log for TC checks  console=True
    Sleep  120s  Wait for DSPs states save inside IM
    Save Infomodel Log  ${BTS_FILES}/IM/InfoModel_log_after_LTE_RAT_reset.ims2
    Set Test Variable  ${IM_LOG_PATH}  ${BTS_FILES}/IM/InfoModel_log_after_LTE_RAT_reset.ims2
    Log  Infomodel log saved under ${IM_LOG_PATH}  console=True


Step 4: Check If LTE DSPs Were Restarted
    [Timeout]  15 min

    Log  Step 4: Check if LTE DSPs were restarted  console=True
    Infomodel Check If DSPs Were Restarted  ${IM_LOG_PATH}  ${DSPS_DIST_NAMES}
    Log  All DSPs were restarted during LTE RAT reset  console=True


Step 5: Check If LTE Cells Were Degraded
    [Timeout]  15 min

    Log  Step 5: Check if LTE cells were degraded  console=True
    ${lte_cells_objects}  Query Infomodel  get list ${DIST_LTE_CELL}
    FOR  ${cell_object}  IN  @{lte_cells_objects}
        Initialize Ims2 Validator  ${IM_LOG_PATH}
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.operationalState: ${ENABLED} -> ${DISABLED}]
        Validate Ims2
        Log  ${cell_object.dist_name} states changed: operationalState: Enabled -> Disabled  console=True
        Initialize Ims2 Validator  ${IM_LOG_PATH}
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.administrativeState]
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.blockingState]
        Run Keyword And Expect Error  InfoModelIms2ValidationException:*
        ...  Validate Ims2
        Log  ${cell_object.dist_name} administrativeState and blockingState remained unchanged  console=True
    END
    Log  All LTE cells were degraded during LTE RAT reset  console=True


Step 6: Check If Cells On Other RATs Were Operational
    [Timeout]  15 min

    Log  Step 6: Check if cells on other RATs were operational  console=True
    Infomodel Check If Cells In RAT Were Operational According To IM Log  WCDMA  ${IM_LOG_PATH}
    Infomodel Check If Cells In RAT Were Operational According To IM Log  GSM  ${IM_LOG_PATH}


Step 7: Check If LTE Cells Are Operational
    [Timeout]  15 min

    Log  Step 7: Check if LTE cells are operational  console=True
    ${are_lncels_online}  Verify LTE Cells States
    Should Be True  ${are_lncels_online}  Not all LTE cells are online after LTE RAT reset


Infomodel Check If DSPs Were Restarted
    [Arguments]  ${im_log_path}  ${dsp_dist_names}

    FOR  ${dsp_dist_name}  IN  @{dsp_dist_names}
        Initialize Ims2 Validator  ${im_log_path}
        Add Expected Ims2 Event  change ${dsp_dist_name} [stateInfo.proceduralState: * -> Resetting] times=1
        Validate Ims2
        Log  ${dsp_dist_name} was restarted  console=True
    END


TC Setup
    Common Test Setup  tc_name=STATE__LTE_RAT_reset_from_ADMIN


TC Teardown
    Common Test Teardown
