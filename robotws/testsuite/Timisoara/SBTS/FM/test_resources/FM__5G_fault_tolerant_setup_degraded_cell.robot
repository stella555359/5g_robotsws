*** Settings ***
Documentation
    ...  This test is created to test FRGY RMOD.
    ...  First, connection to primary core is opened, and RMOD information is gathered.
    ...  Fault is sent on RMOD and 1837 alarm is raised; also 4G cells must be disabled and 5G cells degraded.
    ...  From 23R2 onwards, fault 4003 is also raised.
    ...  Second, 5G cells mapped on RMOD are locked, and fault 1868 is raised with supplementary alarm info.
    ...  Last, fault is canceled, 5G cells are unlocked, and all alarms are cleared, also SBTS goes on air.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  900  # [in seconds] Timeout for SBTS to start after site reset
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarms to appear or disappear.
${RMOD_TYPE}  FRGY  # RMOD type that must pe tested.


*** Keywords ***
FM__5G_fault_tolerant_setup_degraded_cell
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24997
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  21.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24997 - Initial TAT creation
    ...  03.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25156 - Resources and kw name fixed
    ...  21.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26599 - Change fault name
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27703 - Tests fail due multiple keywords with the same name
    ...  23.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28106 - Skip alarm check for SBTS24R3
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  22.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29213 - Replace RMOD info search from /rom/config/FRIps.txt
    ...  ******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS23

    Step0: Testcase Preconditions
    Step1: Connect To RMOD And Send Fault
    Step2: Check Cells And Alarms Status
    Step3: Lock 5G Cell And Check Cells And Alarms Status
    Step4: Clear Fault From RMOD
    Step5: Unlock 5G Cell


Step0: Testcase Preconditions
    Log  \nStep0: Testcase preconditions  console=true
    ${rmod_ip}  ${rmod_serial_number}  Get RMOD Ip And Serial Number  ${RMOD_TYPE}
    ${rmod_dn}  Get Module Dist Name By Serial Number And Class  ${rmod_serial_number}  RMOD
    ${rmod_cells}  Get Cell Mapping By Module Id  ${rmod_dn}
    ${lte_cells}  ${nr_cells}  Get Lte And Nr Cells Lists Mapped On Rmod  ${rmod_cells}
    ${software}  Get Software Info
    ${active_sw}  Get From Dictionary  ${software}  Active SW version
    ${active_sw}  Fetch From Left  ${active_sw}  _
    Set Test Variable  ${RMOD_IP}  ${rmod_ip}
    Set Test Variable  ${RMOD_SN}  ${rmod_serial_number}
    Set Test Variable  ${NR_CELLS}  ${nr_cells}
    Set Test Variable  ${LTE_CELLS}  ${lte_cells}
    Set Test Variable  ${ACTIVE_SW}


Step1: Connect To RMOD And Send Fault
    Log  \nStep1: Connect to RMOD and send fault  console=true
    Connect To RMOD Through Lxc-attach And Telnet  ${RMOD_IP}
    SSHLibrary.Write  sendFault 1177 1 0 0 0 0 0
    Log  Fault sent.  console=true
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections


Step2: Check Cells And Alarms Status
    Log  \nStep2: Check cells and alarms status.  console=true
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_1837}
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Log  Alarm ${alarm_parameters} active in WebEM.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_1837}  additional_fault_id=${FAULT_1837}[fault_id]
    Log  Alarm ${alarm_parameters} active in Netact.  console=true
    Run Keyword If  '${ACTIVE_SW}' > 'SBTS23R1' and '${ACTIVE_SW}' != 'SBTS24R3'
    ...  Check Additional Fault
    Check Parameters Status For Cells  ${LTE_CELLS}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Log  LTE cells are in expected state: disabled & failed.  console=true
    Check Parameters Status For Cells  ${NR_CELLS}  operationalState=${ENABLED}, availabilityStatus=${DEGRADED}
    Log  NR cells are in expected state: enabled & degraded.  console=true


Step3: Lock 5G Cell And Check Cells And Alarms Status
    Log  \nStep3: Lock 5G cell and check cells and alarms status.  console=true
    Lock Or Unlock 5G Cells  Locked
    Check Parameters Status For Cells  ${NR_CELLS}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Log  NR cells are in expected state: disabled & failed.  console=true

    ${suppl_info}  Set Variable  Cell Failed due to Degraded Cell Setup
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_1868}
    ${alarm_parameters}  Catenate  ${alarm_parameters},  supplAlarmInfo="${suppl_info}"
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Log  Alarm ${alarm_parameters} is active in WebEM.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_1868}  additional_fault_id=${FAULT_1868}[fault_id]
    ...  suppl_info=Cell Failed due to Degraded Cell Setup
    Log  Alarm ${alarm_parameters} is active in Netact.  console=true


Step4: Clear Fault From RMOD
    Log  \nStep4: Clear fault from RMOD.  console=true
    Clear Fault On RMOD
    Check Parameters Status For Cells  ${LTE_CELLS}  operationalState=${ENABLED}
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4003}
    Run Keyword If  '${ACTIVE_SW}' > 'SBTS23R1'
    ...  Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_1868}
    Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_1837}
    Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}


Step5: Unlock 5G Cell
    Log  Step5: Unlock 5G cell  console=true
    Lock Or Unlock 5G Cells  Unlocked
    Check Parameters Status For Cells  ${NR_CELLS}  operationalState=${ENABLED}
    Check If Alarms From WebEM And NetAct Are The Same


Get RMOD Ip And Serial Number
    [Arguments]  ${rmod_type}

    ${rmods_parameters}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods_parameters}
        IF  '${rmod}[productName]'=='${rmod_type}'
            ${rmod_ip}  Set Variable  ${rmod}[ipAddress]
            ${rmod_serial_number}  Set Variable  ${rmod}[serialNumber]
            BREAK
        ELSE
            CONTINUE
        END
    END
    Should Not Be Empty  ${rmod_ip}  RMOD ip not set correctly - there is no ${rmod_type} RMODs on SBTS. [NOK]
    Log  ${rmod_type} serial number and ip are chosen.  console=true

    RETURN  ${rmod_ip}  ${rmod_serial_number}


Get Lte And Nr Cells Lists Mapped On Rmod
    [Arguments]  ${cells_list}

    ${lte_cells}  Create List
    ${nr_cells}  Create List
    FOR  ${cell}  IN  @{cells_list}
        ${status_lte}  Run Keyword And Return Status
        ...  Should Contain  ${cell}  LNCEL
        ${status_nr}  Run Keyword And Return Status
        ...  Should Contain  ${cell}  NRCEL
        Run Keyword If  ${status_lte}
        ...  Append To List  ${lte_cells}  ${cell}
        ...  ELSE IF  ${status_nr}
        ...  Append To List  ${nr_cells}  ${cell}
    END

    [Return]  ${lte_cells}  ${nr_cells}


Connect To RMOD Through Lxc-attach And Telnet
    [Arguments]  ${rmod_ip}

    Open Connection To Primary Core
    SSHLibrary.Set Client Configuration  prompt=>
    SSHLibrary.Write  lxc-attach -n 0x1018
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  telnet ${rmod_ip} 2323
    SSHLibrary.Read Until Prompt
    Log  RMOD telnet connection opened.  console=true


Clear Fault On RMOD
    Connect To RMOD Through Lxc-attach And Telnet  ${RMOD_IP}
    SSHLibrary.Write  sendFault 1177 1 0 1 0 0 0
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  sendFault 1177 1 0 1 0 0 0
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections
    Log  Fault was canceled. console=true


Check Additional Fault
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4003}
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Log  Alarm ${alarm_parameters} active in WebEM.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4003}  additional_fault_id=${FAULT_4003}[fault_id]
    Log  Alarm ${alarm_parameters} active in Netact.  console=true


Lock Or Unlock 5G Cells
    [Arguments]  ${operation}

    FOR  ${cell}  IN  @{NR_CELLS}
        ${cell_id}  Fetch From Right  ${cell}  -
        Perform Delta Recommissioning For Nr Cell  ${operation}  ${cell_id}
    END


Perform Delta Recommissioning For Nr Cell
    [Arguments]  ${cell_operation}  ${cell_id}

    ${bts_id}  Admin Get BTS ID
    ${nrbts_id}  Admin Get NRBTS ID
    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${bts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}  update  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${bts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}  administrativeState  ${cell_operation}  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    Remove Delta  ${delta_id}


Perform Recovery Action
    ${status_lte_cells}  Run Keyword And Return Status
    ...  Check Parameters Status For Cells  ${LTE_CELLS}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Run Keyword If  ${status_lte_cells}
    ...  Clear Fault On RMOD
    ${status_nr_cells}  Run Keyword And Return Status
    ...  Check Parameters Status For Cells  ${NR_CELLS}  administrativeState=${LOCKED}
    Run Keyword If  ${status_nr_cells}
    ...  Lock Or Unlock 5G Cells  Unlocked


Check FRI flooding in syslog
    [Documentation]  KW will be used in test teardown after syslog collection is done.
    ...  Check if "[objecthelper::getIMDistNameFromCMConfDN] use Logical object:" is still visible in syslog.

    Log  Check FRI flooding in syslog.  console=true
    Unarchive Syslogs From UDPLogs Directory
    ${syslog_message}  Set Variable  [objecthelper::getIMDistNameFromCMConfDN] use Logical object:
    ${syslog_files}  OperatingSystem.List Directory  ${UDP_LOGS}/Unarchived
    FOR  ${file}  IN  @{syslog_files}
        ${syslog_found_message}  Grep File  ${UDP_LOGS}/Unarchived/${file}  ${syslog_message}
        Should Be Empty  ${syslog_found_message}  [NOK] Syslog found: ${syslog_message}
    END

    [Teardown]  Delete Unarchived Syslogs From UDPLogs Directory


TC Setup
    Common Test Setup  tc_name=FM__5G_fault_tolerant_setup_degraded_cell
    Setup Netact


TC Teardown
    Run Keyword If Test Failed
    ...  FM__5G_fault_tolerant_setup_degraded_cell.Perform Recovery Action
    Teardown Netact
    Common Test Teardown
    Check FRI flooding in syslog
