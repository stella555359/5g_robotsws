*** Settings ***
Documentation
    ...  This TC calculates KPI15 based on delta plan activation.
    ...  If GLOBAL_CELL_ID is not provided, TC will choose one NR or LTE cell randomly.
    ...  One parameter of chosen cell must be updated. Plan activation should trigger cell locking.
    ...  actCceSplit and actCarelCounters parameters are selected for NR cells and LTE cells, respectively.
    ...  During plan activation, chosen cell is disabled.
    ...  After plan activation, SBTS should be onAir.
    ...  In the end, TC restores the default value for the updated parameter.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${CELL_TYPE}  ${EMPTY}  # Mandatory, it can be NRCEL or LNCEL
${GLOBAL_CELL_ID}  ${EMPTY}  # Global cell id, eg: 53285, 47180
# If empty, one random cell of CELL_TYPE will be chosen
${DELTA_ACTIVATION_TIMEOUT}  300  # Time for delta plan to be activated
${CELL_RECOVERY}  300  # Time for cell to reach on air state


*** Keywords ***
TC__KPI__Configuration_plan_activation_with_cell_locking
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26519
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  27.11.2023 - https://jira3.ext.net.nokia.com/browse/TAT-26519- TAT creation
    ...  23.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28130 - Add timeout for cell to reach on air state
    ...  01.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28157 - Fix recovery action
    ...  14.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28157 - Fix global cell id check
    ...  20.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28430 - Use ims from common test teardown to calculate kpis
    ...  03.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30071 - Update TC to report both KPIs: kpi15a and kpi15b
    ...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30323 - Drop ute_admin_infomodel usage from KPI test cases

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS24

    Step0: TC Preconditions
    Step1: Perform Delta Activation
    Step2: Check SBTS To Be OnAir


Step0: TC Preconditions
    IF  '${CELL_TYPE}' not in ['NRCEL', 'LNCEL']  Fail  Please provide the correct CELL TYPE (NRCEL or LNCEL).
    ${distnames}  Get Ids For All  ${CELL_TYPE}
    IF  '${GLOBAL_CELL_ID}'
        ${cell_dn}  Get Cell Distname With Specific Id  ${distnames}
    ELSE
        ${cell_dn}  Get Random Distname  ${distnames}
    END
    ${cell_dn_for_dela_plan}  Get Short Dn For Chosen Cell  ${cell_dn}
    ${parameter_name}  ${parameter_new_value}  Get Parameter Name And Value  ${cell_dn}

    Set Test Variable  ${CELL_DN_FOR_DELA_PLAN}
    Set Test Variable  ${PARAMETER_NAME}
    Set Test Variable  ${PARAMETER_NEW_VALUE}


Step1: Perform Delta Activation
    Log  \nStep1: Perform delta activation  console=true
    Perform Parameter Recommissioning  dist_name=${CELL_DN_FOR_DELA_PLAN}  parameter=${PARAMETER_NAME}  operation=update
    ...  value=${PARAMETER_NEW_VALUE}  skip_parameter_relation_errors=${TRUE}  timeout=${DELTA_ACTIVATION_TIMEOUT}


Step2: Check SBTS To Be OnAir
    Log  \nStep2: Check SBTS to be onAir  console=true
    Wait Until Keyword Succeeds  ${CELL_RECOVERY}  30  Admin Check All Required State


Get Cell Distname With Specific Id
    [Arguments]  ${distnames}

    FOR  ${cell_dn}  IN  @{distnames}
        ${cell_id}  Fetch From Right  ${cell_dn}  -
        IF  '${GLOBAL_CELL_ID}'=='${cell_id}'  RETURN  ${cell_dn}
    END
    Fail  Please provide a correct global ${CELL_TYPE} id.


Get Random Distname
    [Arguments]  ${distnames}

    ${cell_dn}  Evaluate  random.choice(${distnames})  random
    ${global_cell_id}  Fetch From Right  ${cell_dn}  -
    Set Test Variable  ${GLOBAL_CELL_ID}

    RETURN  ${cell_dn}


Get Short Dn For Chosen Cell
    [Arguments]  ${cell_dn}

    ${bts_id}  Admin Get BTS Id
    ${cell_short_dn}  Remove String Using Regexp  ${cell_dn}  .*VIEW-\\d/
    ${cell_short_dn}  Remove String  ${cell_short_dn}  _R
    ${cell_short_dn}  Replace String Using Regexp  ${cell_short_dn}  MRBTS-\\d  MRBTS-${bts_id}

    RETURN  ${cell_short_dn}


Get Parameter Name And Value
    [Arguments]  ${cell_dn}

    ${parameter_name}  Set Variable If  '${CELL_TYPE}'=='NRCEL'  actCceSplit  actCarelCounters
    ${conf_ref_1}  Get Parameters For  ${CELL_TYPE}  ${cell_dn}/CONF_REF-1
    ${cell_object_a}  coam.Get Parameters  ${conf_ref_1}[id]
    ${cell_object_a}  coam.Get Parameters  ${cell_object_a}[distName]
    ${current_value}  Set Variable  ${cell_object_a}[${parameter_name}]
    ${new_value}  Set Variable If  '${current_value}'=='False'  true  false

    RETURN  ${parameter_name}  ${new_value}


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}


TC Teardown
    IF  '${PARAMETER_NEW_VALUE}'!='false'
        Perform Parameter Recommissioning  dist_name=${CELL_DN_FOR_DELA_PLAN}
        ...  parameter=${PARAMETER_NAME}
        ...  operation=update
        ...  value=false
        ...  skip_parameter_relation_errors=${TRUE}
        ...  timeout=${DELTA_ACTIVATION_TIMEOUT}
        Wait Until Keyword Succeeds  ${CELL_RECOVERY}  30  Admin Check All Required State
    END
    Common Test Teardown

    ${kpi15a}  Calculate Kpi15a  ${BTS_FILES}/IM/InfoModel_log.ims2  ${GLOBAL_CELL_ID}
    Log Delta In Seconds  ${kpi15a}[kpi15a][-1][delta]  kpi15a
    Save Delta Results  kpi15a

    ${kpi15b}  Calculate Kpi15b  ${BTS_FILES}/IM/InfoModel_log.ims2  ${GLOBAL_CELL_ID}
    Log Delta In Seconds  ${kpi15b}[kpi15b][-1][delta]  kpi15b
    Save Delta Results  kpi15b
    Set Log Level  TRACE
