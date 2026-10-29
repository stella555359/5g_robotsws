*** Settings ***
Documentation
    ...  This test is created to power off and on RMOD with serial number provided by user (RMOD_SN)
    ...  that has 4G and 5G cells deployed on it.
    ...  RMOD is turned off.
    ...  Fault 10 'No connection to unit' must be visible on RMOD. Cells deployed on RMOD can be
    ...  degraded or failed depending on their mapping. If one cell is also mapped on other RMOD,
    ...  its state is degraded. It is failed otherwise.
    ...  Severity for fault 10 is Critical if there is one cell failed. If not, severity is Major.
    ...  If LTE or NR cells are degraded, then fault 4003 'Transmission path failure' is active on them.
    ...  RMOD is turned on.
    ...  If RMOD has CPRI or eCPRI protocol, then fault 4589 'Unit power reset' is visible on it.
    ...  In the end, TC is waiting for SBTS to reach on air state.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_SN}  ${EMPTY}  # Mandatory, RMOD with 4G and 5G which needs to be powered off
${FAULT_10_TIMEOUT}  120  # [in seconds] Timeout for fault 10 to be visible
${FAULT_4589_TIMEOUT}  180  # [in seconds] Timeout for fault 10 to be visible
${RECOVERY_TIMEOUT}  600  # [in seconds] Timeout for SBTS to get on air state


*** Keywords ***
FM__LTE_NR_cells_degraded_when_1_RU_power_off
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26710
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  15.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26710 - Initial TAT creation
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27703 - Tests fail due multiple keywords with the same name
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  25.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29608 - Enhancement of test cases supplAlarmInfo for CB007184
    ...  05.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30148 - Test fails at checking supplAlarmInfo
    ...  02.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30000 - Move keywords to resource
    ...  12.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30502 - Skip cell verification if energySavingState is energySaving
    ...  ******************

    Set Tags  CA-FM  OWNER-radu.steici@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS24  FEATURE- CB007184

    Step0: Set Testcase Variables
    Step1: Power Off RMOD And Check Fault 10
    Step2: Check Cells And Fault 4003
    Step3: Power On RMOD And Check 4589 Fault
    Step4: Check SBTS To Be On Air


Step0: Set Testcase Variables
    Log  \nStep0: Set testcase variables  console=true
    IF  '${RMOD_SN}'=='${EMPTY}'  Fail  RMOD serial number must be provided through RMOD_SN variable.
    ${rmod_dn}  Get Module Dist Name By Serial Number And Class  ${RMOD_SN}  RMOD
    Check If LTE And NR Are Deployed On RMOD  ${rmod_dn}
    ${rmod_cells}  Get Cell Mapping By Module Id  ${rmod_dn}
    ${degraded_cells}  ${failed_cells}  ${cells_with_4003}  Get Impacted Cells Expected States  ${rmod_cells}  ${rmod_dn}
    ${lte_splitted_cells}  Create List
    FOR  ${cell_dn}  IN  @{degraded_cells}
        IF  'LNCEL' in '${cell_dn}'  Append To List  ${lte_splitted_cells}  ${cell_dn}
    END
    Set SyncSigTxMode Parameter For LTE  ${lte_splitted_cells}
    ${not_impacted_cells}  Get All Cells On Bts
    Remove Values From List  ${not_impacted_cells}  @{rmod_cells}
    ${fault_10_severity}  Get Fault 10 Severity  ${failed_cells}
    ${bts_id}  Admin Get BTS ID
    ${bts_name}  Get Bts Name
    Set Test Variable  ${RMOD_DN}
    Set Test Variable  ${DEGRADED_CELLS}
    Set Test Variable  ${FAILED_CELLS}
    Set Test Variable  ${CELLS_WITH_4003}
    Set Test Variable  ${NOT_IMPACTED_CELLS}
    Set Test Variable  ${FAULT_10_SEVERITY}
    Set Test Variable  ${BTS_ID}
    Set Test Variable  ${BTS_NAME}


Step1: Power Off RMOD And Check Fault 10
    Log  \nStep1: Power off RMOD and check fault 10.  console=true
    Pdu BTS Interface Off  RMOD_${RMOD_SN}
    Log  RMOD_${RMOD_SN} powered off.   console=true
    ${rmod_id}  Replace String Using Regexp  ${RMOD_DN}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    ${fault_10}  Set Variable If  '${FAULT_10_SEVERITY}'=='Critical'  ${FAULT_10_CRITICAL}  ${FAULT_10_MAJOR}
    ${fault_10_params}  Get String With Alarm Parameters  ${fault_10}
    ${fault_10_params}  Catenate  ${fault_10_params},  notifier="[${BTS_NAME}] ${rmod_id}"
    Assert Alarm Active  parameters=${fault_10_params}  timeout=${FAULT_10_TIMEOUT}
    Log  Fault active in WebEM : ${fault_10_params}.  console=true
    Wait Until Keyword Succeeds  60  10s
    ...  Check Additional Information For Given Alarm And Fault  &{fault_10}  object_id=${rmod_id}  additional_fault_id=${fault_10}[fault_id]
    Assert  RMOD  ${RMOD_DN}  operationalState=${DISABLED}, availabilityStatus=${NOT_INSTALLED}
    Log  Fault active in Netact : ${fault_10_params}.  console=true


Step2: Check Cells And Fault 4003
    Log  \nStep2: Check cells and fault 4003.  console=true
    ${count_degraded}  Get Length  ${DEGRADED_CELLS}
    ${count_failed}  Get Length  ${FAILED_CELLS}
    IF  ${count_degraded}
        Check Parameters Status For Cells  ${DEGRADED_CELLS}  operationalState=${ENABLED}, availabilityStatus=${DEGRADED}
        Log  Affected cells reached state operationalState=${ENABLED}, availabilityStatus=${DEGRADED} :\n${DEGRADED_CELLS}  console=true
    END
    IF  ${count_failed}
        Check Parameters Status For Cells  ${FAILED_CELLS}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
        Log  Affected cells reached state operationalState=${DISABLED}, availabilityStatus=${FAILED} :\n${FAILED_CELLS}  console=true
    END
    Check Fault 4003  ${CELLS_WITH_4003}
    FOR  ${cell_dn}  IN  @{NOT_IMPACTED_CELLS}
        ${class_name}  Get Regexp Matches  ${cell_dn}  [A-Z]{2}CEL
        ${status}  Run Keyword And Return Status  Should Match Regexp  ${cell_dn}  .*(LN|NR)CEL.*
        IF  ${status}
            ${cell_parameters}  coam.Get Parameters  ${cell_dn}
            IF  '${cell_parameters}[energySavingState]'=='energySaving' or '${cell_parameters}[energySavingState]'=='reducedEnergySaving'  CONTINUE
        END
        Assert  ${class_name}[0]  ${cell_dn}  operationalState=${ENABLED}
        ${is_degraded}  Run Keyword And Return Status  Assert  ${class_name}[0]  ${cell_dn}  availabilityStatus=${DEGRADED}  timeout=2
        IF  ${is_degraded}  Fail  ${cell_dn} is degraded after RMOD power off. [NOK]
    END


Step3: Power On RMOD And Check 4589 Fault
    Log  \nStep3: Power on RMOD and check 4589 fault.  console=true
    Log  Turning on RMOD.  console=true
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    Pdu BTS Interface On  RMOD_${RMOD_SN}
    Log  RMOD_${RMOD_SN} powered on.   console=true
    ${rmod_params}  coam.Get Parameters  ${RMOD_DN}
    IF  'CPRI' in '${rmod_params}[l3Protocol]' or 'ECPRI' in '${rmod_params}[l3Protocol]'  Check Fault 4589  ${time_from}


Step4: Check SBTS To Be On Air
    Log  \nStep4: Check SBTS to be on air.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  30s  Admin Check All Required State


Check If LTE And NR Are Deployed On RMOD
    [Arguments]  ${rmod_dn}

    ${rmod_params}  coam.Get Parameters  ${rmod_dn}
    Should Not Be Empty  ${rmod_params}[activeLteCellsList]  LTE is not deployed on provided RMOD. Please set another serial number.
    Should Not Be Empty  ${rmod_params}[activeNrCellsList]  NR is not deployed on provided RMOD. Please set another serial number.


Get Impacted Cells Expected States
    [Arguments]  ${cells_runtime_dn}  ${rmod_dn}

    ${degraded_cells}  Create List
    ${failed_cells}  Create List
    ${cells_with_4003}  Create List
    ${bts_info}  coam.Get Bts Info
    FOR  ${cell_dn}  IN  @{cells_runtime_dn}
        IF  'GNCEL' in '${cell_dn}'
            Append To List  ${failed_cells}  ${cell_dn}
            CONTINUE
        END
        ${current_cell_rat}  Set Variable If  'WNCEL' in '${cell_dn}'  wcdma  'LNCEL' in '${cell_dn}'  lte  'NRCEL' in '${cell_dn}'  nr
        ${channel_directions_on_other_rmod}  Get Cell Channels Direction To Other Rmods  ${bts_info}[cells][${current_cell_rat}]  ${cell_dn}
        ...  ${rmod_dn}
        IF  'TX' in ${channel_directions_on_other_rmod} and 'RX' in ${channel_directions_on_other_rmod}
            Append To List  ${degraded_cells}  ${cell_dn}
        ELSE
            Append To List  ${failed_cells}  ${cell_dn}
        END
        IF  'WNCEL' in '${cell_dn}'  CONTINUE
        IF  '${cell_dn}' in ${degraded_cells}  Append To List  ${cells_with_4003}  ${cell_dn}
    END

    RETURN  ${degraded_cells}  ${failed_cells}  ${cells_with_4003}


Get Cell Channels Direction To Other Rmods
    [Arguments]  ${bts_info_cells}  ${cell_dn}  ${rmod_dn}

    FOR  ${cell_info}  IN  @{bts_info_cells}
        IF  '${cell_dn}'=='${cell_info}[id][internal]'  BREAK
    END
    ${carrier_list}  Set Variable  ${cell_info}[carrierList]
    ${channel_directions_on_other_rmod}  Create List
    FOR  ${carrier}  IN  @{carrier_list}
        IF  '${rmod_dn}' not in '${carrier}[antennaLineId][internal]'  Append To List  ${channel_directions_on_other_rmod}  ${carrier}[direction]
    END

    RETURN  ${channel_directions_on_other_rmod}


Get Fault 10 Severity
    [Arguments]  ${failed_cells}

    ${no_failed_cells}  Run Keyword And Return Status
    ...  Should Be Empty  ${failed_cells}
    ${severity}  Set Variable If  ${no_failed_cells}  Major  Critical

    RETURN  ${severity}


Check Fault 4589
    [Arguments]  ${time_from}

    ${rmod_id}  Replace String Using Regexp  ${RMOD_DN}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    ${fault_4589_params}  Get String With Alarm Parameters  ${FAULT_4589_UNIT_POWER_RST}
    ${fault_4589_params}  Catenate  ${fault_4589_params},  notifier="[${BTS_NAME}] ${rmod_id}"
    Assert Alarm Active  parameters=${fault_4589_params}  timeout=${FAULT_4589_TIMEOUT}
    Wait Until Keyword Succeeds  ${FAULT_4589_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4589_UNIT_POWER_RST}
    ...  object_id=${rmod_id}  time_from=${time_from}  additional_fault_id=${FAULT_4589_UNIT_POWER_RST}[fault_id]
    Check Fault Signature If Fault 4589 Was Raised At Power Off/On For Radio Module


Perform Recovery Action
    ${rmod_status}  Run Keyword And Return Status
    ...  Assert  RMOD  ${RMOD_DN}  operationalState=${DISABLED}
    IF  ${rmod_status}  Pdu BTS Interface On  RMOD_${RMOD_SN}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State


TC Setup
    Common Test Setup  tc_name=FM__LTE_NR_cells_degraded_when_1_RU_power_off
    Setup Netact


TC Teardown
    Run Keyword If Test Failed
    ...  FM__LTE_NR_cells_degraded_when_1_RU_power_off.Perform Recovery Action
    Teardown Netact
    Common Test Teardown
