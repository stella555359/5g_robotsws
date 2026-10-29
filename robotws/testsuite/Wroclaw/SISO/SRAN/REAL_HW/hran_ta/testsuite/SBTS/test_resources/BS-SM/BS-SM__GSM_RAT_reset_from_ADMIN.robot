*** Settings ***
Documentation
...  TC for GSM RAT reset from ADMIN API

Library    ute_admin_infomodel
Library    hran_bsc
Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_siso_hran.robot
Resource    ../../../../resources/ca_4G_RRM_carrier_aggregation.robot

*** Variables ***
${GSM_RAT_RESET_TIMEOUT}=  300  # Timeout (in seconds) for ADMIN API GSM RAT reset. Timeout is applied for ADMIN procedure launched in step 2.
                                # Procedure starts with ADMIN trigger and ends when GSM RAT reset is completed

*** Keywords ***
TC__BS-SM__GSM_RAT_reset_from_ADMIN
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19472
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC for GSM RAT reset from ADMIN API.GSM RAT reset is performed (whole operation from sending trigger
    ...  request to GSM reaching OnAir again)
    ...
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19472 - Test creation
    ...  - 07.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19444 - Added KPI console log
    ...  - 20.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22244 - Changes due to CNI-61110
    ...  - 21.12.2021 - Changes due to CNI-61110 and fix checking cells states
    ...  - 19.01.2022 - Refactoring to align with LTE and WCDMA rat reset scenario
    ...  - 01.08.2022 - Workspace hran_ta migration to robotws
    ...  - 10.11.2022 - Removing library hran_ims
    ...  - 15.05.2023 - Replacing KWs to TAF library
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-19472.png


    Set Tags    CA-BS-SM    OWNER-robert.susz@nokia.com    AUTHOR-robert.susz@nokia.com
    ...    MAINTAINER-przemyslaw.kempa@nokia.com    GROUP_IN_CHARGE-WRO_8_Vrf    PHASE-CRT
    ...    CABLING-SBTS_03_UEManager    FEATURE-RP001498_RP000923    FEATURE-RP001621_RP000923
    ...    FEATURE-RP001486_RP000923    FEATURE-RP0001145_RP000923

    Step 1: Get all GSM DSPs dist names
    Step 2: Perform GSM RAT reset
    Step 3: Save Infomodel log for TC checks
    Step 4: Check if GSM DSPs were restarted
    Step 5: Check if GSM cells were degraded
    Step 6: Check if cells on other RATs were operational
    Step 7: Check if GSM cells are operational

Step 1: Get all GSM DSPs dist names
    [Timeout]  30 min
    Log  Step 1: Get all GSM DSPs dist names  console=True
    ${dsps_dist_names}=  SiSo get all DSPs dist names for given RAT  GSM
    Log  GSM DSPs list: ${dsps_dist_names}  console=True
    Set test variable  ${DSPS_DIST_NAMES}  ${dsps_dist_names}

Step 2: Perform GSM RAT reset
    [Timeout]  30 min
    Log  Step 2: Perform GSM RAT reset  console=True
    admin.Rat Reset  rat_type=GSM  timeout=${GSM_RAT_RESET_TIMEOUT}
    Log  GSM RAT reset has been performed via ADMIN API  console=True

Step 3: Save Infomodel log for TC checks
    [Timeout]  30 min
    Log  Step 3: Save Infomodel log for TC checks  console=True
    Sleep  120s  Wait for DSPs states save inside IM
    Save infomodel log  ${BTS Files}/IM/InfoModel_log_after_GSM_RAT_reset.ims2
    Set test variable  ${IM_LOG_PATH}  ${BTS Files}/IM/InfoModel_log_after_GSM_RAT_reset.ims2
    Log  Infomodel log saved under ${IM_LOG_PATH}  console=True

Step 4: Check if GSM DSPs were restarted
    [Timeout]  30 min
    Log  Step 4: Check if GSM DSPs were restarted  console=True
    SiSo check if DSPs were restarted according to ims file  ${IM_LOG_PATH}  ${DSPS_DIST_NAMES}
    Log  All DSPs were restarted during GSM RAT reset  console=True

Step 5: Check if GSM cells were degraded
    [Timeout]  30 min
    Log  Step 5: Check if GSM cells were degraded  console=True
    ${gsm_cells_objects}=          Query Infomodel  get list ${dist_GSM_cell}
    ${gsm_cells_runtime_objects}=  Query Infomodel  get list //GNBTS_R-*//GNCEL_R-*
    FOR  ${cell_object}  ${runtime_object}  IN ZIP  ${gsm_cells_objects}  ${gsm_cells_runtime_objects}
          Initialize ims2 validator  ${IM_LOG_PATH}
          Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.availabilityStatus: regex"(?i)Online" -> regex"(?i)Offline"]
          Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.operationalState: regex"(?i)Enabled" -> regex"(?i)Disabled"]
          Validate ims2
          Log  ${cell_object.dist_name} states changed: availabilityStatus: Online -> Offline, operationalState: Enabled -> Disabled  console=True
          Initialize ims2 validator  ${IM_LOG_PATH}
          Add expected ims2 event  change ${cell_object.dist_name} [stateInfo.blockingState]
          Run keyword and expect error  InfoModelIms2ValidationException:*  Validate ims2
          Log  ${cell_object.dist_name} administrativeState and blockingState remained unchanged  console=True
    END
    Log  All GSM cells were degraded during GSM RAT reset  console=True

Step 6: Check if cells on other RATs were operational
    [Timeout]  30 min
    Log  Step 6: Check if cells on other RATs were operational  console=True
    SiSo check if cells in RAT were operational according to IM log  LTE  ${IM_LOG_PATH}
    SiSo check if cells in RAT were operational according to IM log  WCDMA  ${IM_LOG_PATH}
    SiSo check if cells in RAT were operational according to IM log  NR  ${IM_LOG_PATH}

Step 7: Check if GSM cells are operational
    [Timeout]  30 min
    Log  Step 7: Check if GSM cells are operational  console=True
    ${are_wncels_online}=   Run Keyword And Return Status  Run Keywords  admin.Assert Every  GNCEL  ${STATES_ONAIR_LG}
    ...  AND  admin.Assert No  GNCEL  ${DEGRADED_CELL_REGEX}
    Should be true  ${are_wncels_online}  Not all GSM cells are online after GSM RAT reset

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
