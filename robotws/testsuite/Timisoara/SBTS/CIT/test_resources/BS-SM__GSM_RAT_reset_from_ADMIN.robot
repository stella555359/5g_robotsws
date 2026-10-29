*** Settings ***
Documentation
    ...  TC for GSM RAT reset from ADMIN API.GSM RAT reset is performed (whole operation from sending trigger
    ...  request to GSM reaching OnAir again)

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${GSM_RAT_RESET_TIMEOUT}  300  # Timeout (in seconds) for ADMIN API GSM RAT reset.


*** Keywords ***
TC__BS-SM__GSM_RAT_reset_from_ADMIN
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19472
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19472 - Test creation
    ...  - 07.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19444 - Added KPI console log
    ...  - 20.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22244 - Changes due to CNI-61110
    ...  - 21.12.2021 - Changes due to CNI-61110 and fix checking cells states
    ...  - 19.01.2022 - Refactoring to align with LTE and WCDMA rat reset scenario
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-19472.png

    Set Tags  CA-BS-SM  OWNER-robert.susz@nokia.com  AUTHOR-robert.susz@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com  GROUP_IN_CHARGE-WRO_8_Vrf
    ...  PHASE-CRT  CABLING-SBTS_03_UEManager  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923  FEATURE-RP001486_RP000923
    ...  FEATURE-RP0001145_RP000923

    Step 1: Get All GSM DSPs Dist Names
    Step 2: Perform GSM RAT Reset
    Step 3: Save Infomodel Log For TC Checks
    Step 4: Check If GSM DSPs Were Restarted
    Step 5: Check If GSM Cells Were Degraded
    Step 6: Check If Cells On Other RATs Were Operational
    Step 7: Check If GSM Cells Are Operational


Step 1: Get All GSM DSPs Dist Names
    [Timeout]  30 min

    Log  Step 1: Get all GSM DSPs dist names  console=True
    ${dsps_dist_names}  Infomodel Get All DSPs Dist Names For Given RAT  GSM
    Log  GSM DSPs list: ${dsps_dist_names}  console=True
    Set Test Variable  ${DSPS_DIST_NAMES}  ${dsps_dist_names}


Step 2: Perform GSM RAT Reset
    [Timeout]  30 min

    Log  Step 2: Perform GSM RAT reset  console=True
    Reset Rat  GSM  timeout=${GSM_RAT_RESET_TIMEOUT}
    Log  GSM RAT reset has been performed via ADMIN API  console=True


Step 3: Save Infomodel Log For TC Checks
    [Timeout]  30 min

    Log  Step 3: Save Infomodel log for TC checks  console=True
    Sleep  120s  Wait for DSPs states save inside IM
    Save Infomodel Log  ${BTS_FILES}/IM/InfoModel_log_after_GSM_RAT_reset.ims2
    Set Test Variable  ${IM_LOG_PATH}  ${BTS_FILES}/IM/InfoModel_log_after_GSM_RAT_reset.ims2
    Log  Infomodel log saved under ${IM_LOG_PATH}  console=True


Step 4: Check If GSM DSPs Were Restarted
    [Timeout]  30 min

    Log  Step 4: Check if GSM DSPs were restarted  console=True
    Infomodel Check If DSPs Were Restarted According To Ims File  ${IM_LOG_PATH}  ${DSPS_DIST_NAMES}
    Log  All DSPs were restarted during GSM RAT reset  console=True


Step 5: Check If GSM Cells Were Degraded
    [Timeout]  30 min

    Log  Step 5: Check if GSM cells were degraded  console=True
    ${gsm_cells_objects}  Query Infomodel  get list ${DIST_GSM_CELL}
    ${gsm_cells_runtime_objects}  Query Infomodel  get list //GNBTS_R-*//GNCEL_R-*
    FOR  ${cell_object}  ${runtime_object}  IN ZIP  ${gsm_cells_objects}  ${gsm_cells_runtime_objects}
        Initialize Ims2 Validator  ${IM_LOG_PATH}
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.availabilityStatus: regex"(?i)Online" -> regex"(?i)Offline"]
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.operationalState: regex"(?i)Enabled" -> regex"(?i)Disabled"]
        Validate Ims2
        Log  ${cell_object.dist_name} states changed: availabilityStatus: Online -> Offline, operationalState: Enabled -> Disabled  console=True
        Initialize Ims2 Validator  ${IM_LOG_PATH}
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.blockingState]
        Run Keyword And Expect Error  InfoModelIms2ValidationException:*
        ...  Validate Ims2
        Log  ${cell_object.dist_name} administrativeState and blockingState remained unchanged  console=True
    END
    Log  All GSM cells were degraded during GSM RAT reset  console=True


Step 6: Check If Cells On Other RATs Were Operational
    [Timeout]  30 min

    Log  Step 6: Check if cells on other RATs were operational  console=True
    Infomodel Check If Cells In RAT Were Operational According To IM Log  LTE  ${IM_LOG_PATH}
    Infomodel Check If Cells In RAT Were Operational According To IM Log  WCDMA  ${IM_LOG_PATH}
    Infomodel Check If Cells In RAT Were Operational According To IM Log  NR  ${IM_LOG_PATH}


Step 7: Check If GSM Cells Are Operational
    [Timeout]  30 min

    Log  Step 7: Check if GSM cells are operational  console=True
    ${are_wncels_online}  Run Keyword And Return Status
    ...  Run Keywords
    ...  Assert Every  GNCEL  ${STATES_ONAIR_LG}
    ...  AND
    ...  Assert No  GNCEL  ${DEGRADED_CELL_REGEX}
    Should Be True  ${are_wncels_online}  Not all GSM cells are online after GSM RAT reset


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
