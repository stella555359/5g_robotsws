*** Settings ***
Documentation
    ...  This TC changes the value of the actDistributedSite parameter from false to true or vice versa
    ...  which determines the autonomous reset of SBTS.
    ...  TC are waiting for all cells to be onAir.
    ...  In the end kpi12a and kpi12b are calculated.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  600
${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}  ${False}


*** Keywords ***
TC__KPI__BTS_autonomous_reset_after_plan_activation
    [Documentation]
    ...  [CASE LINK]: https://jiradc.int.net.nokia.com/browse/TAT-23631
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  02.09.2022 - https://jiradc.int.net.nokia.com/browse/TAT-23631 - Initial creation
    ...  10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24073 - Log delta to console
    ...  11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24107 - Save delta in json file after every TC
    ...  18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  16.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24317 - Refactor KPI TCs and resources to use KWs from ca_SBTS_general
    ...  22.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24321 - Changing the value of the actDistributedSite parameter
    ...  23.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24560 - Change BTS_L id to work on both left and right sides for
    ...           FEATCADM object
    ...  20.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24996 - Refactor lines to be less than 150 characters
    ...  13.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25539 - Add option for activating graceful cell shutdown before reset
    ...  20.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30062 - Add kpi12a and kpi12b
    ...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30323 - Drop ute_admin_infomodel usage from KPI test cases

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Change ActDistributedSite Value To Trigger Autonomous Reset
    Step2: Check SBTS Status To Be OnAir


Step1: Change ActDistributedSite Value To Trigger Autonomous Reset
    Log  \nStep1: Change actDistributedSite value to trigger autonomous reset  console=true
    IF  ${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}
        Activate Or Deactivate Graceful Cell Shutdown  enableGrflShdn_new_value=Enabled  actGrflShdn_new_value=true
    ELSE
        Activate Or Deactivate Graceful Cell Shutdown  enableGrflShdn_new_value=Disabled  actGrflShdn_new_value=false
    END
    Change Parameter ActDistributedSite Value  FEATCADM-1  FEATCADM_A-1


Step2: Check SBTS Status To Be OnAir
    Log  \nStep2: Check SBTS status to be onAir  console=true
    ${bts_on_air_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  30  Admin Check All Required State
    IF  ${bts_on_air_status}
        Log  SBTS is onAir after site reset. [OK]  console=true
    ELSE
        Set Test Failed  SBTS is not onAir after site reset. [NOK]
    END


Change Parameter ActDistributedSite Value
    [Arguments]  ${parameter_object}  ${parameter_object_a}

    ${dist_name_bts_id}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/${parameter_object}
    ${get_parameter_value}  Get ActDistributedSite Value From FEATCADM Object  actDistributedSite  ${parameter_object_a}
    IF  '${get_parameter_value}'=='false'
        Perform Parameter Recommissioning  ${dist_name_bts_id}  actDistributedSite  update  true  skip_parameter_relation_errors=${True}  timeout=300
        Log  actDistributedSite will be changed to true  console=true
    ELSE IF  '${get_parameter_value}'=='true'
        Perform Parameter Recommissioning  ${dist_name_bts_id}  actDistributedSite  update  false  skip_parameter_relation_errors=${True}  timeout=300
        Log  actDistributedSite will be changed to false  console=true
    ELSE
        Set Test Failed  Parameter actDistributedSite has not changed
    END


Get ActDistributedSite Value From FEATCADM Object
    [Arguments]  ${im_parameter}  ${parameter_object_a}

    ${parameter_name}  Convert To String  ${im_parameter}
    ${parameter_object_a}  Fetch From Left  ${parameter_object_a}  -
    ${parameter_object}  coam.Get Managed Objects  ${parameter_object_a}
    ${parameter_object_value_string}  Convert To String  ${parameter_object}[0][parameters][${parameter_name}]
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}

    [Return]  ${parameter_object_lower}


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}


TC Teardown
    IF  ${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}
        Activate Or Deactivate Graceful Cell Shutdown  enableGrflShdn_new_value=Disabled  actGrflShdn_new_value=false
    END
    Common Test Teardown
    ${kpis_to_be_calculated}  Create List  kpi12a  kpi12b
    ${kpi12}  Calculate Kpis  ${kpis_to_be_calculated}  ${BTS_FILES}/IM/InfoModel_log.ims2
    FOR  ${kpi}  IN  @{kpis_to_be_calculated}
        Log Delta In Seconds  ${kpi12}[${kpi}][-1][delta]  ${kpi}
        Save Delta Results  ${kpi}
    END
    Set Log Level  TRACE
