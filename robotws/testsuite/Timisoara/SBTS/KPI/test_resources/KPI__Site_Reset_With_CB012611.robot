*** Settings ***
Documentation
...  One Loki from ABIO or ABIN will be chosen by user through ${LOKI_L_DN} test variable.
...  Fault 252 'Baseband Module Hardware Failure' is sent on Loki through specific ssh command. Cablinks and RMODs with
...  synchronization cablinks mapped on Loki will be disabled. Cells from Loki and RMODs synchronized on Loki and other
...  RMODs (if it's the case with RMODs in chain) will be failed.
...  If there are cells mapped on Loki, 252 severity should be Critical. Severity is Minor otherwise.
...  Fault 10 'No connection to unit' is raised on RMODs synchronized on Loki.
...  In case of RMODs mapped on other SoC, but with some cells mapped on failed Loki, for the other cells from these
...  RMODs major faults 6134 'EN DSS De-activated on partner side' and 6129 'No DSS Partner Cell' are raised.
...
...  Site reset is performed. Fault 252 severity will ve Minor after site reset.
...  Fault 1868 'BTS configuration error (not enough HW for LCR)' is raised on each impacted cell.
...  Fault 10 is raised on RMODs synchronized on Loki.
...  Major fault 6129 'No DSS Partner Cell' is raised in case of the particularity mentioned above.
...  TC calculates kpis 1a and 1b based on unaffected cells.
...
...  Fault 252 is cleared by performing site reset after sending ssh command on primary or secondary core.
...  After second site reset, SBTS must be fully operational.

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  1200  # Time in seconds for SBTS to reach on air state
${LOKI_L_DN}  ${EMPTY}  # Mandatory. SOC logical dist name


*** Keywords ***
TC__KPI__Site_Reset_With_CB012611
    [Documentation]
    ...  [CASE LINK]: https://jiradc.int.net.nokia.com/browse/TAT-28245
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  17.10.2024 - https://jiradc.int.net.nokia.com/browse/TAT-28245 - Initial TAT creation
    ...  19.11.2024 - https://jiradc.int.net.nokia.com/browse/TAT-28419 - Fix bbmod position
    ...  12.12.2024 - https://jiradc.int.net.nokia.com/browse/TAT-28522 - Change alarm details for fids 6129 and 6134
    ...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30323 - Drop ute_admin_infomodel usage from KPI test cases

    Set Tags  CA-KPI  OWNER-iulian_catalin.lazar@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-CB012611

    Step0: TC Variables
    Step1: Trigger Fault 252 On Random Loki And Wait For Fid To Be Active
    Step2: Check Affected Units And Other Active Faults
    Step3: Perform Site Reset
    Step4: Check Active Faults After Site Reset
    Step5: Calculate KPI 1 For Unaffected Cells
    Step6: Clear Fault 252 And Perform Site Reset
    Step7: Check SBTS To Be Fully On Air


Step0: TC Variables
    IF  '${LOKI_L_DN}'=='${EMPTY}'  Fail  Please provide logical dist name for Loki.

    Setup Admin  bts_host=${OAM_BTS_IP}  update_interval=500  name=collect_infomodel_log
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
    ${additional_affected_cells_on_the_other_loki}  Get Additional Affected Cells On RMODs And Other Loki  ${bbmod_l_dn}  ${bbmod_r_dn}
    ...  ${bbmod_product_name}  ${affected_cells_distnames}  ${additional_affected_cells_on_loki}

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
    Set Test Variable  ${ADDITIONAL_AFFECTED_CELLS_ON_THE_OTHER_LOKI}
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
    coam.Reset Site  timeout=600  connection=collect_infomodel_log


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

    Collect Infomodel Log From Current Session  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2  connection=collect_infomodel_log
    Teardown Admin  connection=collect_infomodel_log
    ${cells_distnames}  Combine Lists  ${UNAFFECTED_CELLS_DISTNAMES}  ${ADDITIONAL_AFFECTED_CELLS_ON_LOKI}
    ${kpi1a}  Calculate Kpi1a  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2  cell_dist_names=${UNAFFECTED_CELLS_DISTNAMES}
    Log Delta In Seconds  ${kpi1a}[kpi1a][-1][delta]  kpi1a
    Save Delta Results  kpi1a
    ${kpi1b}  Calculate Kpi1b  ${BTS_FILES}/IM/InfoModel_log_from_current_session.ims2  cell_dist_names=${UNAFFECTED_CELLS_DISTNAMES}
    Log Delta In Seconds  ${kpi1b}[kpi1b][-1][delta]  kpi1b
    Save Delta Results  kpi1b


Step6: Clear Fault 252 And Perform Site Reset
    Log  \nStep6: Clear Fault 252 And Perform Site Reset  console=true
    Send Or Clear FID 252  action=clear
    Sleep  10s  Time for clearing fid 252 command to be completely executed.

    FOR  ${cell_dn}  IN  @{ADDITIONAL_AFFECTED_CELLS_ON_LOKI}
        ${cell_class_name}  Get Regexp Matches  ${cell_dn}  [A-Z]{2}CEL
        Run Keyword And Ignore Error
        ...  Assert No  ${cell_class_name}[0]  id=${cell_dn}  availabilityStatus=regex"Degraded|degraded|Failed|failed"
        ...  timeout=300
    END

    ${fid_7513_parameters}  Get String With Alarm Parameters  ${FAULT_7513}
    FOR  ${cell_dn}  IN  @{ADDITIONAL_AFFECTED_CELLS_ON_THE_OTHER_LOKI}
        ${cell_dn_shortened}  Replace String Using Regexp  ${cell_dn}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
        ${cell_dn_shortened}  Remove String  ${cell_dn_shortened}  _R
        ${fid_7513_parameters_with_obj}  Catenate  ${fid_7513_parameters},  configObjectName="[${BTS_NAME}] ${cell_dn_shortened}"
        ${7513_is_active}  Run Keyword And Return Status  Assert Alarm Active  ${fid_7513_parameters_with_obj}  timeout=180
        IF  not ${7513_is_active}  BREAK
        Log  Fault 6129 '${FAULT_7513}[fault_name]' is active in WebEM on ${cell_dn_shortened}.  console=true
    END

    coam.Reset Site  timeout=600


Step7: Check SBTS To Be Fully On Air
    Log  \nStep7: Check SBTS To Be Fully On Air  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  30  Admin Check All Required State
    Log  SBTS is on air.  console=true


Get Additional Affected Cells On RMODs And Other Loki
    [Arguments]  ${bbmod_l_dn}  ${bbmod_r_dn}  ${bbmod_product_name}  ${affected_cells_distnames}  ${additional_affected_cells_on_loki}

    ${cells_on_the_other_loki_and_rmods}  Create List
    ${soc_list}  coam.Get Managed Objects  SOC_L
    ${loki_list_on_bbmod}  Create List
    FOR  ${soc}  IN  @{soc_list}
        ${status}  Run Keyword And Return Status  Should Contain  ${soc}[distName]  ${bbmod_l_dn}
        IF  ${status}  Append To List  ${loki_list_on_bbmod}  ${soc}
    END
    ${the_other_loki}  Set Variable  ${loki_list_on_bbmod}
    FOR  ${soc_parameters}  IN  @{loki_list_on_bbmod}
        IF  'POWER_GROUP_L-1/SOC_L-1' in '${soc_parameters}[distName]' or '${LOKI_L_DN}'=='${soc_parameters}[distName]'
            Remove Values From List  ${the_other_loki}  ${soc_parameters}
        END
    END
    ${length}  Get Length  ${the_other_loki}
    IF  ${length}==0  RETURN  ${cells_on_the_other_loki_and_rmods}

    ${cells_on_the_other_loki_and_rmods}  Get Cells Mapped On SoC And RMODs  ${bbmod_r_dn}  ${bbmod_product_name}  ${the_other_loki}[0][distName]
    Remove Values From List  ${cells_on_the_other_loki_and_rmods}  @{affected_cells_distnames}
    Remove Values From List  ${cells_on_the_other_loki_and_rmods}  @{additional_affected_cells_on_loki}

    RETURN  ${cells_on_the_other_loki_and_rmods}


Send Or Clear FID 252
    [Arguments]  ${action}

    ${stored_role}  Get StoredRole From MODULE_L  ${LOKI_L_DN}
    Open Connection To Primary Core
    IF  '${stored_role}'=='Idle'  Open Connection To Secondary Core

    ${power_group}  Get Regexp Matches  ${LOKI_L_DN}  POWER_GROUP_L-\\d
    ${power_group_id}  Fetch From Right  ${power_group}[0]  -
    ${bbmod_vertical_position}  Get Module Vertical Position  ${BBMOD_R_DN}
    IF  '${action}'=='clear'
        SSHLibrary.Execute Command  bmutool -s ${bbmod_vertical_position} -r 0x1F 1
        RETURN
    END

    ${address}  Set Variable If  '${power_group_id}'=='1'  0x10  0x11
    SSHLibrary.Execute Command  bmutool -s ${bbmod_vertical_position} -r ${address} 0xA0

    [Teardown]  SSHLibrary.Close Connection


TC Setup
    Set Log Level  INFO
    Common Test Setup  infomodel_launch=${FALSE}  tc_name=KPI__Site_Reset_With_CB012611


TC Teardown
    Common Test Teardown
    Set Log Level  TRACE