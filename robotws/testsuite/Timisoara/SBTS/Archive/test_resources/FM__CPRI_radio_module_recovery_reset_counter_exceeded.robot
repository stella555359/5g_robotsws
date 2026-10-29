*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${STARTUP_TIMEOUT}              600
${RECOVERY_TIMEOUT}             300                                                 # Timeout for SBTS to recover after radio recovery reset
${ALARM_TIMEOUT}                600                                                 # Timeout for WebEm and NetAct alarms
${EXPECTED_FAULT_ID}            1907                                                # Expected fault id that will be checked by test
${EXPECTED_FAULT_NAME}          TX out of order                                     # Expected fault name that will be checked by test
${EXPECTED_ALARM_ID}            7116                                                # Expected alarm id that will be checked by test
${EXPECTED_ALARM_NAME}          BASE STATION SERVICE PROBLEM                        # Expected alarm name that will be checked by test
${SEVERITY}                     Critical                                            # Expected severity that will be checked by test
${EXPECTED_FAULT_NAME_SECOND}   Radio autonomous reset as recovery action           # Expected second fault name that will be checked by test
${EXPECTED_ALARM_ID_SECOND}     7101                                                # Expected second alarm id that will be checked by test
${EXPECTED_ALARM_NAME_SECOND}   BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION     # Expected second alarm name that will be checked by test
${SEVERITY_SECOND}              Warning                                             # Expected second severity that will be checked by test

*** Keywords ***
FM__CPRI_radio_module_recovery_reset_counter_exceeded
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22426
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test is created to perform failure on CPRI RMODs processing 5G cells
    ...  Site reset is performed to clear all counters
    ...  One RMOD is taken randomly, it must process 5G cells and l3Protocol must be CPRI
    ...  The fault is triggered by editing multiple threshold values(under dpdMseCalcParams field) in a file called "dpdnahka_dlpath1.json"
    ...  Sed and reboot commands are used to edit the file and activate the fault
    ...  After the fault triggering, RMOD reboots four times and two alarms are reported in WebEm and NetAct
    ...  Alarm "Radio autonomous reset" appears only the first three times and alarm "Tx out of order" is reported every time
    ...  After de fourth reboot cells remain failed
    ...  Finally, changes made on "dpdnahka_dlpath1.json" file are deleted and RMOD reaches on air state
    ...  History of changes
    ...  ******************
    ...  22.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-22429 - Initial TAT creation
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  ******************

    Set Tags        CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-anna.benzar@nokia.com
    ...             MAINTAINER-anna.benzar@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT  SW-SBTS22

    Step0: Perform site reset and get RMOD info
    Step1: Trigger fault on CPRI RMOD
    Step2: Delete fault and reboot rmod

Step0: Perform site reset and get RMOD info
    Log  \nStep 0: Performing site reset and getting RMOD info.  console=true
    coam.Reset site  ${STARTUP_TIMEOUT}
    ${status}  Run keyword and return status  Wait until keyword succeeds  ${STARTUP_TIMEOUT}  20  Check modules, cells and alarms
    Run keyword if  ${status}
    ...  Log  Site reached on air state after performing site reset.  console=true
    ...  ELSE
    ...  Fail  Site didn't manage to reach on air state.
    ${rmod_r_dn_list}  Get ids for all  RMOD
    Set RMOD ip and dist name   ${rmod_r_dn_list}

Step1: Trigger fault on CPRI RMOD
    Log  \nStep 1: Triggering fault on CPRI RMOD.  console=true
    Connect to RMOD
    Send fault on RMOD
    FOR  ${it}  IN RANGE  4
        Verify TX out of order alarm in Webem and NetAct
        Run keyword if  ${it} != 3
        ...  Verify Radio autonomous reset alarm in Webem and NetAct
    END
    Log  Waiting for 5 minutes to verify RMOD and cells state after 4th fault trigger.  console=true
    Sleep  300
    Verify cells and RMOD state  ${Disabled_}  ${Degraded_}

Step2: Delete fault and reboot rmod
    Log  \nStep 2: Deleting fault and rebooting RMOD.  console=true
    Connect to RMOD
    SSHLibrary.write  rm -r /mnt/runtime/configs/*
    SSHLibrary.read until prompt
    SSHLibrary.Write  reboot
    SSHLibrary.close connection
    ${status}  Run keyword and return status  Wait until keyword succeeds  ${RECOVERY_TIMEOUT}  20  Check modules, cells and alarms
    Run keyword if  ${status}
    ...  Log  All services reached on air state.  console=true
    ...  ELSE
    ...  Fail  Site didn't manage to reach on air state.

Check modules, cells and alarms
    ${list_modules}  Create List  SMOD  BBMOD  RMOD
    FOR  ${it}  IN  @{list_modules}
        Assert every  ${it}  operationalState=${Enabled_}
    END
    Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Admin Check Active Alarms TAF

Set RMOD ip and dist name
    [Arguments]  ${rmod_r_dn_list}
    FOR  ${dist_name}  IN  @{rmod_r_dn_list}
        ${active_nr_cells_list}  coam.Get parameters  ${dist_name}  activeNrCellsList
        ${status_nr_cells_list}  Run keyword and return status  Should not be empty  ${active_nr_cells_list}[activeNrCellsList]
        ${parameters}  Get parameters for   RMOD  ${dist_name}
        ${status_l3Protocol}  Run keyword and return status  Should match regexp  ${parameters}[l3Protocol]  ^CPRI_[A-Za-z0-9]+
        Run keyword if  ${status_nr_cells_list} and ${status_l3Protocol}
        ...  Run keywords  Set test variable  ${RMOD_IP}  ${parameters}[ipAddress]  AND  Set test variable  ${RMOD_DN}  ${dist_name}
        ...  AND  Exit for loop
    END
    ${status_rmod_ip}  Run keyword and return status  Should not be empty  ${RMOD_IP}
    ${status_rmod_dn}  Run keyword and return status  Should not be empty  ${RMOD_DN}
    Run keyword unless  ${status_rmod_ip} or ${status_rmod_dn}
    ...  Fail  There are no RMODs with CPRI protocol.

Connect to RMOD
    Log  Opening connection to master and then to rmod.  console=true
    SSHLibrary.open connection  192.168.255.129
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]
    ${cablink_r_list}  Query infomodel  get list //CABLINK_R-* is [secondEndpointDN=${RMOD_DN}]
    FOR  ${it}  IN  @{cablink_r_list}
        ${bbmod_r_dn}  Set variable if  '${it}[linkModeSynchronization]' == 'True'  ${it}[firstEndpointDN]  ${FALSE}
        Exit for loop if  '${bbmod_r_dn}' != '${FALSE}'
    END
    ${bbmod_r_ref}  Query infomodel  get object ${bbmod_r_dn}/REF-1
    ${bbmod_l}  Query infomodel  get object ${bbmod_r_ref}[distName]
    ${bts_dn}  Fetch from left  ${bbmod_l}[dist_name]  /EQM_L
    ${bts_object}  Query infomodel  get object ${bts_dn}
    ${side}  Set variable  ${bts_object}[hwapiDomainId]
    ${status_active/single}  Run keyword and return status  Should contain  "Active|Single"  ${bts_object}[storedRole]
    Run keyword if  ${status_active/single}
    ...  Open connection to RMOD  ${side}
    ...  ELSE
    ...  Connect to RMOD through slave  ${side}

Open connection to RMOD
    [Arguments]  ${side}
    ${status_rmod}  Run keyword and return status  SSHLibrary.write  lxc-attach -n 0x${side}018 ssh root@${RMOD_IP}
    Run keyword if  ${status_rmod}
    ...  Log  Connection to RMOD succesful.  console=true
    ...  ELSE
    ...  Fail  Cannot Connect to RMOD through slave.
    SSHLibrary.set client configuration  prompt=(yes/no/[fingerprint])?
    ${status_prompt}  Run keyword and return status  SSHLibrary.read until prompt
    SSHLibrary.set client configuration  prompt=:~#
    Run keyword if  ${status_prompt}
    ...  Run keywords  SSHLibrary.write  yes  AND  SSHLibrary.read until prompt

Connect to RMOD through slave
    [Arguments]  ${side}
    SSHLibrary.set client configuration  prompt=(yes/no/[fingerprint])?
    SSHLibrary.write  ssh ${SMOD1}[USERNAME]@fct-4a
    ${status_question}  Run keyword and return status  SSHLibrary.read until prompt
    Run keyword if  ${status_question}
    ...  Run keywords  SSHLibrary.write  yes
    ...  AND  SSHLibrary.set client configuration  prompt=Password:
    ...  AND  SSHLibrary.read until prompt
    SSHLibrary.write  ${SMOD1}[PASSWORD]
    SSHLibrary.set client configuration  prompt=>
    SSHLibrary.read until prompt
    Open connection to RMOD  ${side}

Send fault on RMOD
    Log  Sending fault on rmod and closing connection.  console=true
    SSHLibrary.Write  echo $'/ action create ConfigAccess /ca /module' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until prompt
    SSHLibrary.Write  echo $'/ca action fetch DECODED "dpdnahka_dlpath1.bin" "/ram/dpdnahka_dlpath1.json"' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until prompt
    SSHLibrary.set client configuration  prompt=#
    SSHLibrary.write  cd /ram
    SSHLibrary.read until prompt
    ${command}=  Catenate  SEPARATOR=  sed -i -E ':a;N;$!ba;s/"dpdMseCalcParams":${SPACE}\\{\\s*\\n\\s*"threshold":${SPACE}0.1,/
    ...  "dpdMseCalcParams":${SPACE}\\{\\n\t"threshold":${SPACE}0.00000001,/g' dpdnahka_dlpath1.json
    SSHLibrary.Write  ${command}
    SSHLibrary.read until prompt
    SSHLibrary.Write  echo '/ca action store PERMANENT DECODED "dpdnahka_dlpath1.bin" "/ram/dpdnahka_dlpath1.json"' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.read until prompt
    SSHLibrary.Write  reboot
    SSHLibrary.close connection

Verify TX out of order alarm in Webem and NetAct
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set test variable  ${START_TIME}  ${start_time}
    ${parameters}  Catenate  SEPARATOR=${SPACE}  faultId=${EXPECTED_FAULT_ID},
    ...                                          faultName="${EXPECTED_FAULT_NAME}",
    ...                                          alarmId=${EXPECTED_ALARM_ID},
    ...                                          alarmName="${EXPECTED_ALARM_NAME}",
    ...                                          severity=${SEVERITY}
    ${alarm_webem}  Run keyword and return status  Assert Alarm Active
    ...  parameters=${parameters}
    ...  timeout=${ALARM_TIMEOUT}
    Run keyword if  ${alarm_webem}
    ...  Log  Alarm ${EXPECTED_ALARM_ID} ${EXPECTED_ALARM_NAME} - fault ${EXPECTED_FAULT_ID} ${EXPECTED_FAULT_NAME} reported in WebEm.  console=true
    ...  ELSE
    ...  Fail  Alarm ${EXPECTED_ALARM_ID} ${EXPECTED_ALARM_NAME} - fault ${EXPECTED_FAULT_ID} ${EXPECTED_FAULT_NAME} not reported in WebEm [NOK]
    ${alarm_netact}  Run keyword and return status  Wait until keyword succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check additional information for given alarm and fault  ${EXPECTED_FAULT_ID}
    ...                                                          ${EXPECTED_FAULT_NAME}
    ...                                                          ${EXPECTED_ALARM_ID}
    ...                                                          ${EXPECTED_ALARM_NAME}
    ...                                                          ${SEVERITY}
    Run keyword if  ${alarm_netact}
    ...  Log  Alarm ${EXPECTED_ALARM_ID} ${EXPECTED_ALARM_NAME} - fault ${EXPECTED_FAULT_ID} ${EXPECTED_FAULT_NAME} reported in NetAct.  console=true
    ...  ELSE
    ...  Fail  Alarm ${EXPECTED_ALARM_ID} ${EXPECTED_ALARM_NAME} - fault ${EXPECTED_FAULT_ID} ${EXPECTED_FAULT_NAME} not reported in NetAct [NOK]

Verify Radio autonomous reset alarm in Webem and NetAct
    ${parameters}  Catenate  SEPARATOR=${SPACE}  faultId=${EXPECTED_FAULT_ID},
    ...                                          faultName="${EXPECTED_FAULT_NAME_SECOND}",
    ...                                          alarmId=${EXPECTED_ALARM_ID_SECOND},
    ...                                          alarmName="${EXPECTED_ALARM_NAME_SECOND}",
    ...                                          severity=${SEVERITY_SECOND}

    ${alarm_webem_second}  Run keyword and return status  Assert Alarm Active
    ...  parameters=${parameters}
    ...  timeout=${ALARM_TIMEOUT}
    Run keyword if  ${alarm_webem_second}
    ...  Log  Alarm ${EXPECTED_ALARM_ID_SECOND} - fault ${EXPECTED_FAULT_ID} ${EXPECTED_FAULT_NAME_SECOND} reported in Webem.  console=true
    ...  ELSE
    ...  Fail  Alarm ${EXPECTED_ALARM_ID_SECOND} - fault ${EXPECTED_FAULT_ID} ${EXPECTED_FAULT_NAME_SECOND} not reported in WebEm - [NOK]
    ${alarm_netact_second}  Run keyword and return status  Wait until keyword succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check additional information for given alarm and fault in NA cleared alarms  ${EXPECTED_FAULT_ID}
    ...                                                                               ${EXPECTED_FAULT_NAME_SECOND}
    ...                                                                               ${EXPECTED_ALARM_ID_SECOND}
    ...                                                                               ${EXPECTED_ALARM_NAME_SECOND}
    ...                                                                               ${SEVERITY_SECOND}
    ...                                                                               ${START_TIME}
    Run keyword if  ${alarm_netact_second}
    ...  Log  Alarm ${EXPECTED_ALARM_ID_SECOND} fault ${EXPECTED_FAULT_ID} ${EXPECTED_FAULT_NAME_SECOND} reported & cleared from NetAct.  console=true
    ...  ELSE
    ...  Fail  Alarm ${EXPECTED_ALARM_ID_SECOND} fault ${EXPECTED_FAULT_ID} ${EXPECTED_FAULT_NAME_SECOND} not reported in NetAct [NOK]

Verify cells and RMOD state
    [Arguments]  ${opState}  ${avStatus}
    ${rmod_state}  Run keyword and return status  Assert  RMOD  ${RMOD_DN}  availabilityStatus=${avStatus}
    Run keyword unless  ${rmod_state}
    ...  Fail  RMOD state: ${avStatus}.
    ${cells_on_rmod}  Get cell mapping by module id  ${RMOD_ DN}
    FOR  ${it}  IN  @{cells_on_rmod}
        ${cell_info}  Get cell specific info  ${it}
        ${cell_opState}  Run keyword and return status  Should contain  ${opState}  ${cell_info}[status][operationalState]
        Run keyword unless  ${cell_opState}
        ...  Fail  Cells state: ${opState}.
    END

TC Setup
    Common Test Setup
    Setup NetAct

TC Teardown
    Run keyword if test failed  Step2: Delete fault and reboot rmod
    Teardown NetAct
    Common Test Teardown
