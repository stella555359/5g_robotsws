*** Settings ***
Documentation
...  TC for performing WCDMA RAT reset from ADMIN API.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_siso_hran.robot
Resource    ../../../../resources/ca_4G_RRM_carrier_aggregation.robot

*** Variables ***
${WCDMA_RAT_RESET_TIMEOUT}=  180  # Timeout (in seconds) for ADMIN API WCDMA RAT reset. Timeout is applied for ADMIN procedure launched in step 2.
                                  # Procedure starts with ADMIN trigger and ends when WCDMA RAT reset is completed


*** Keywords ***
TC__STATE__WCDMA_RAT_reset_from_ADMIN
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7656
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC for WCDMA RAT reset from ADMIN API. At first WCDMA RAT reset is performed (whole operation from sending trigger
    ...  request to WCDMA reaching OnAir again). Then InfoModel log gathered from RAT reset is saved and then checked in order
    ...  to find all DSPs and cells states changes.
    ...
    ...  | *Parameters*             | *Example*  |
    ...  | WCDMA_RAT_RESET_TIMEOUT  |  180       |
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
    ...  - 30.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21764 - [CNI-61110] STATE TCs alignment
    ...  - 01-09-2022 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-12197 - migration hran_ta to robotws
    ...  - 10.11.2022 - Removing library hran_ims
    ...  - 15.12.2022 - Removing DSP_L check
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-7656_01.png#


    Set Tags    CA-SWM    OWNER-grzegorz.gulaj@nokia.com    AUTHOR-patryk.furman@nokia.com
    ...    MAINTAINER-daniel.bartkowiak@nokia.com    GROUP_IN_CHARGE-WRO_8_Vrf    PHASE-CR    SW-SBTS17
    ...    CABLING-SBTS_03_UEManager    FEATURE-RP001498_RP000923    FEATURE-RP001621_RP000923
    ...    FEATURE-RP001486_RP000923    FEATURE-RP0001145_RP000923

    Preconditions
    Step 1: Perform WCDMA RAT reset
    Step 2: Save Infomodel log for TC checks
    Step 3: Check if WCDMA cells were degraded
    Step 4: Check if cells on other RATs were operational
    Step 5: Check if WCDMA cells are operational

Preconditions
    ${IMPACTED_CELLS}  ${NOT_IMPACTED_CELLS}=  Get Cells From Selected RATs  WN
	Set Test Variable  ${IMPACTED_CELLS}
    Set Test Variable  ${NOT_IMPACTED_CELLS}

Step 1: Perform WCDMA RAT reset
    [Timeout]  30 min
    Log  Step 1: Perform WCDMA RAT reset  console=True
    admin.Rat Reset  rat_type=WCDMA  timeout=${WCDMA_RAT_RESET_TIMEOUT}  connection=default
    Log  WCDMA RAT reset has been performed via ADMIN API  console=True

Step 2: Save Infomodel log for TC checks
    [Timeout]  30 min
    Log  Step 2: Save Infomodel log for TC checks  console=True
    Sleep  120s  Wait for DSPs states save inside IM
    admin.Collect Infomodel Log From Current Session  ${BTS Files}/IM/InfoModel_log_after_WCDMA_RAT_reset.ims2  connection=default
    Set test variable  ${IM_LOG_PATH}  ${BTS Files}/IM/InfoModel_log_after_WCDMA_RAT_reset.ims2
    Log  Infomodel log saved under ${IM_LOG_PATH}  console=True

Step 3: Check if WCDMA cells were degraded
    [Timeout]  30 min
    Log  Step 3: Check if WCDMA cells were degraded  console=True
    FOR  ${cell_object}  IN  @{IMPACTED_CELLS}
	    Find Parameter Change  ${IM_LOG_PATH}  ${cell_object}  availabilityStatus  Regex"(?i)off.*line"
        Log  ${cell_object} changed to offline  console=${TRUE}
    END
    Log  All WCDMA cells were degraded during WCDMA RAT reset  console=True

Step 4: Check if cells on other RATs were operational
    [Timeout]  30 min
    Log  Step 4: Check if cells on other RATs were operational  console=True
    FOR  ${cell_object}  IN  @{NOT_IMPACTED_CELLS}
	  Run Keyword And Expect Error  No change found in*  Find Parameter Change  ${IM_LOG_PATH}  ${cell_object}  availabilityStatus
	  Log  ${cell_object} remained unchanged  console=${TRUE}
	END

Step 5: Check if WCDMA cells are operational
    [Timeout]  30 min
    Log  Step 5: Check if WCDMA cells are operational  console=True
	Siso Admin Check SBTS states and alarms

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
