*** Settings ***
Documentation
...  One Loki from ABIO or ABIN will be chosen by user through ${LOKI_L_DN} test variable.
...  Fault 252 'Baseband Module Hardware Failure' is sent on Loki through specific ssh command. Cablinks and RMODs with
...  synchronization cablinks mapped on Loki will be disabled. Cells from Loki and RMODs synchronized on Loki and other
...  RMODs (if it's the case with RMODs in chain) will be failed.
...  If there are cells mapped on Loki, 252 severity should be Critical. Severity is Minor otherwise.
...  Fault 10 'No connection to unit' is raised on RMODs synchronized on Loki.
...  In case of RMODs mapped on other SoC, but with some cells mapped on failed Loki, for the other cells from these
...  RMODs minor faults 6134 'EN DSS De-activated on partner side' and 6129 'No DSS Partner Cell' are raised.
...
...  Site reset is performed. Fault 252 severity will ve Minor after site reset.
...  Fault 1868 'BTS configuration error (not enough HW for LCR)' is raised on each impacted cell.
...  Fault 10 is raised on RMODs synchronized on Loki.
...  Minor fault 6129 'No DSS Partner Cell' is raised in case of the particularity mentioned above.
...  TC calculates kpis 1a and 1b based on unaffected cells.
...
...  Fault 252 is cleared by performing site power reset.
...  TC is waiting until SBTS is fully operational.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  1200  # Time in seconds for SBTS to reach on air state
${LOKI_L_DN}  ${EMPTY}  # Mandatory. SOC logical dist name


*** Keywords ***
TC__KPI__Site_Reset_With_CB012611_Split_G
    [Documentation]
    ...  [CASE LINK]: https://jiradc.int.net.nokia.com/browse/TAT-28526
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 12.12.2024 - https://jiradc.int.net.nokia.com/browse/TAT-28526 - Initial TAT creation

    Set Tags  CA-KPI  OWNER-iulian_catalin.lazar@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-CB012611

    Step0: TC Variables
    Step1: Trigger Fault 252 On Random Loki And Wait For Fid To Be Active
    Step2: Check Affected Units And Other Active Faults
    Step3: Perform Site Reset
    Step4: Check Active Faults After Site Reset
    Step5: Calculate KPI 1 For Unaffected Cells
    Step6: Clear Fault 252
    Step7: Check SBTS To Be Fully On Air


Step0: TC Variables
    IF  '${LOKI_L_DN}'=='${EMPTY}'  Fail  Please provide logical dist name for Loki.

    ${bbmod_l_dn}  Fetch From Left  ${LOKI_L_DN}  /BBU_L
    ${bbmod_r_dn}  Get Runtime Object Dist_name From Logical Object Dist_name  ${bbmod_l_dn}
    ${bbmod_l_parameters}  Get Parameters For  BBMOD  ${bbmod_l_dn}
    ${bbmod_product_name}  Fetch From Left  ${bbmod_l_parameters}[productName]  ${SPACE}

    ${synchro_rmods_on_loki_distnames}  ${cablinks_on_loki_distnames}
    ...  Get RMODs And Cablinks From Soc  ${bbmod_r_dn}  ${bbmod_product_name}  ${LOKI_L_DN}

    ${cells_on_loki_distnames}  Get Cell Mapping By Module Id  ${LOKI_L_DN}
    ${affected_cells_distnames}  Get Cells On RMODs  ${synchro_rmods_on_loki_distnames}
    Append To List  ${affected_cells_distnames}  @{cells_on_loki_distnames}
    ${affected_cells_distnames}  Remove Duplicates  ${affected_cells_distnames}
    ${additional_affected_cells_on_loki}  Get Additional Affected Cells Mapped On Loki  ${cells_on_loki_distnames}
    ...  ${synchro_rmods_on_loki_distnames}

    ${unaffected_cells_distnames}  Get All Cells On Bts
    Remove Values From List  ${unaffected_cells_distnames}  @{affected_cells_distnames}
    Remove Values From List  ${unaffected_cells_distnames}  @{additional_affected_cells_on_loki}

    ${bbmod_r_id}  Fetch From Right  ${bbmod_r_dn}  /
    Log  \nLoki SoC ${LOKI_L_DN} from ${bbmod_r_id} is chosen.  console=true

    ${bts_name}  Get Bts Name
    Set Test Variable  ${BTS_NAME}
    Set Test Variable  ${BBMOD_R_DN}
    Set Test Variable  ${CELLS_ON_LOKI_DISTNAMES}
    Set Test Variable  ${SYNCHRO_RMODS_ON_LOKI_DISTNAMES}
    Set Test Variable  ${CABLINKS_ON_LOKI_DISTNAMES}
    Set Test Variable  ${AFFECTED_CELLS_DISTNAMES}
    Set Test Variable  ${ADDITIONAL_AFFECTED_CELLS_ON_LOKI}
    Set Test Variable  ${UNAFFECTED_CELLS_DISTNAMES}


Step1: Trigger Fault 252 On Random Loki And Wait For Fid To Be Active
    Log  \nStep1: Trigger Fault 252 On Random Loki And Wait For Fid To Be Active  console=true
    Send Or Clear FID 252  action=send

    ${length}  Get Length  ${CELLS_ON_LOKI_DISTNAMES}
    ${fault_252}  Set Variable If  ${length}==0  ${FAULT_252_MINOR}  ${FAULT_252_CRITICAL}

    ${bbmod_dn_shortened}  Replace String Using Regexp  ${BBMOD_R_DN}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    ${fault_252_parameters}  Get String With Alarm Parameters  ${fault_252}
    ${fault_252_parameters}  Catenate  ${fault_252_parameters},  notifier="[${BTS_NAME}] ${bbmod_dn_shortened}"
    Assert Alarm Active  ${fault_252_parameters}  timeout=180
    Log  Fault 252 '${fault_252}[fault_name]' with ${fault_252}[severity] severity is active in WebEM.  console=true


Step2: Check Affected Units And Other Active Faults
    Log  \nStep2: Check Affected Units And Other Active Faults  console=true
    ${bbmod_operational_state}  Set Variable  regex"Disabled|disabled|Enabled|enabled"
    ${bbmod_availability_status}  Set Variable  regex"Failed|failed|Degraded|degraded"
    Assert  BBMOD  ${BBMOD_R_DN}  operationalState=${bbmod_operational_state}, availabilityStatus=${bbmod_availability_status}  timeout=60
    Log  ${BBMOD_R_DN} is affected.  console=true

    FOR  ${cablink_dn}  IN  @{CABLINKS_ON_LOKI_DISTNAMES}
        Assert  CABLINK  ${cablink_dn}  operationalState=${DISABLED}, availabilityStatus=${NOT_INSTALLED}  timeout=120
    END

    ${fid_6134_parameters}  Get String With Alarm Parameters  ${FAULT_6134}
    FOR  ${cell_dn}  IN  @{ADDITIONAL_AFFECTED_CELLS_ON_LOKI}
        ${cell_dn_shortened}  Replace String Using Regexp  ${cell_dn}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
        ${cell_dn_shortened}  Remove String  ${cell_dn_shortened}  _R
        ${fid_6134_parameters_with_obj}  Catenate  ${fid_6134_parameters},  configObjectName="[${BTS_NAME}] ${cell_dn_shortened}"
        Assert Alarm Active  ${fid_6134_parameters_with_obj}  timeout=120
        Log  Fault 6134 '${FAULT_6134}[fault_name]' is active in WebEM on ${cell_dn_shortened}.  console=true
    END

    ${fid_10_parameters}  Get String With Alarm Parameters  ${FAULT_10_Critical}
    FOR  ${rmod_dn}  IN  @{SYNCHRO_RMODS_ON_LOKI_DISTNAMES}
        ${rmod_dn_shortened}  Replace String Using Regexp  ${rmod_dn}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
        Assert  RMOD  ${rmod_dn}  operationalState=${DISABLED}, availabilityStatus=${NOT_INSTALLED}  timeout=120
        ${fid_10_parameters_with_obj}  Catenate  ${fid_10_parameters},  notifier="[${BTS_NAME}] ${rmod_dn_shortened}"
        Assert Alarm Active  ${fid_10_parameters_with_obj}  timeout=1000
        Log  Fault 10 is active in WebEM on ${rmod_dn_shortened}.  console=true
    END

    ${fid_6129_parameters}  Get String With Alarm Parameters  ${FAULT_6129}
    FOR  ${cell_dn}  IN  @{ADDITIONAL_AFFECTED_CELLS_ON_LOKI}
        ${cell_dn_shortened}  Replace String Using Regexp  ${cell_dn}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
        ${cell_dn_shortened}  Remove String  ${cell_dn_shortened}  _R
        ${fid_6129_parameters_with_obj}  Catenate  ${fid_6129_parameters},  configObjectName="[${BTS_NAME}] ${cell_dn_shortened}"
        Assert Alarm Active  ${fid_6129_parameters_with_obj}  timeout=300
        Log  Fault 6129 '${FAULT_6129}[fault_name]' is active in WebEM on ${cell_dn_shortened}.  console=true
    END

    Check Parameters Status For Cells  ${AFFECTED_CELLS_DISTNAMES}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Check Parameters Status For Cells  ${ADDITIONAL_AFFECTED_CELLS_ON_LOKI}  operationalState=${ENABLED}
    Check Parameters Status For Cells  ${UNAFFECTED_CELLS_DISTNAMES}  operationalState=${ENABLED}


Step3: Perform Site Reset
    Log  \nStep3: Perform Site Reset  console=true
    coam.Reset Site  timeout=600


Step4: Check Active Faults After Site Reset
    Log  \nStep4: Check Active Faults After Site Reset  console=true
    ${bbmod_dn_shortened}  Replace String Using Regexp  ${BBMOD_R_DN}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    ${fault_252_parameters}  Get String With Alarm Parameters  ${FAULT_252_MINOR}
    ${fault_252_parameters}  Catenate  ${fault_252_parameters},  notifier="[${BTS_NAME}] ${bbmod_dn_shortened}"
    Assert Alarm Active  ${fault_252_parameters}  timeout=300
    Log  Fault 252 '${FAULT_252_MINOR}[fault_name]' with ${FAULT_252_MINOR}[severity] severity is active in WebEM.  console=true

    ${fid_1868_parameters}  Get String With Alarm Parameters  ${FAULT_1868_CRITICAL}
    FOR  ${cell_dn}  IN  @{AFFECTED_CELLS_DISTNAMES}
        ${cell_dn_shortened}  Replace String Using Regexp  ${cell_dn}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
        ${cell_dn_shortened}  Remove String  ${cell_dn_shortened}  _R
        ${fid_1868_parameters_with_obj}  Catenate  ${fid_1868_parameters},  configObjectName="[${BTS_NAME}] ${cell_dn_shortened}"
        Assert Alarm Active  ${fid_1868_parameters_with_obj}  timeout=180
        Log  Fault 1868 '${FAULT_1868_CRITICAL}[fault_name]' is active in WebEM on ${cell_dn_shortened}.  console=true
    END

    ${fid_6129_parameters}  Get String With Alarm Parameters  ${FAULT_6129}
    FOR  ${cell_dn}  IN  @{ADDITIONAL_AFFECTED_CELLS_ON_LOKI}
        ${cell_dn_shortened}  Replace String Using Regexp  ${cell_dn}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
        ${cell_dn_shortened}  Remove String  ${cell_dn_shortened}  _R
        ${fid_6129_parameters_with_obj}  Catenate  ${fid_6129_parameters},  configObjectName="[${BTS_NAME}] ${cell_dn_shortened}"
        Assert Alarm Active  ${fid_6129_parameters_with_obj}  timeout=900
        Log  Fault 6129 '${FAULT_6129}[fault_name]' is active in WebEM on ${cell_dn_shortened}.  console=true
    END

    ${fid_10_parameters}  Get String With Alarm Parameters  ${FAULT_10_Critical}
    FOR  ${rmod_dn}  IN  @{SYNCHRO_RMODS_ON_LOKI_DISTNAMES}
        ${rmod_dn_shortened}  Replace String Using Regexp  ${rmod_dn}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
        Assert  RMOD  ${rmod_dn}  operationalState=${DISABLED}, availabilityStatus=${NOT_INSTALLED}  timeout=120
        ${fid_10_parameters_with_obj}  Catenate  ${fid_10_parameters},  notifier="[${BTS_NAME}] ${rmod_dn_shortened}"
        Assert Alarm Active  ${fid_10_parameters_with_obj}  timeout=1000
        Log  Fault 10 is active in WebEM on ${rmod_dn_shortened}.  console=true
    END

    Check Parameters Status For Cells  ${AFFECTED_CELLS_DISTNAMES}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Check Parameters Status For Cells  ${ADDITIONAL_AFFECTED_CELLS_ON_LOKI}  operationalState=${ENABLED}
    Check Parameters Status For Cells  ${UNAFFECTED_CELLS_DISTNAMES}  operationalState=${ENABLED}


Step5: Calculate KPI 1 For Unaffected Cells
    Log  \nStep5: Calculate KPI 1 For Unaffected Cells\n  console=true

    Collect Infomodel Log From Current Session  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2
    ${cells_distnames}  Combine Lists  ${UNAFFECTED_CELLS_DISTNAMES}  ${ADDITIONAL_AFFECTED_CELLS_ON_LOKI}
    ${kpi1a}  Calculate Kpi1a  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2  cell_dist_names=${UNAFFECTED_CELLS_DISTNAMES}
    Log Delta In Seconds  ${kpi1a}[kpi1a][-1][delta]  kpi1a
    Save Delta Results  kpi1a
    ${kpi1b}  Calculate Kpi1b  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2  cell_dist_names=${UNAFFECTED_CELLS_DISTNAMES}
    Log Delta In Seconds  ${kpi1b}[kpi1b][-1][delta]  kpi1b
    Save Delta Results  kpi1b


Step6: Clear Fault 252
    Log  \nStep6: Clear Fault 252  console=true
    Send Or Clear FID 252  action=clear


Step7: Check SBTS To Be Fully On Air
    Log  \nStep7: Check SBTS To Be Fully On Air  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  30  Admin Check All Required State
    Log  SBTS is on air.  console=true


Send Or Clear FID 252
    [Arguments]  ${action}

    IF  '${action}'=='clear'
        coam.Power Reset  timeout=600
        RETURN
    END

    ${stored_role}  Get StoredRole From MODULE_L  ${LOKI_L_DN}
    Open Connection To Primary Core
    IF  '${stored_role}'=='Idle'  Open Connection To Secondary Core

    ${bbmod_vertical_position}  Get Module Vertical Position  ${BBMOD_R_DN}
    Open Connection To Soc  ${bbmod_vertical_position}  0
    SSHLibrary.Write  ls -l /sys/kernel/debug | grep oip
    ${output}  SSHLibrary.Read Until Prompt
    ${oip_directory}  Get regexp matches  ${output}  oip-\\d-\\d*

    SSHLibrary.Write  echo 0x17 > /sys/kernel/debug/${oip_directory}[0]/addr
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  cd /sys/kernel/debug/oip-2-0054; echo 4 > /sys/kernel/debug/${oip_directory}[0]/data
    SSHLibrary.Read Until Prompt

    [Teardown]  Run Keyword And Ignore Error  SSHLibrary.Close Connection


TC Setup
    Set Log Level  INFO
    Common Test Setup  infomodel_launch=${FALSE}  tc_name=KPI__Site_Reset_With_CB012611_Split_G


TC Teardown
    Common Test Teardown
    Set Log Level  TRACE