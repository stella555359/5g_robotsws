*** Settings ***
Documentation
    ...  Test case triggers RF Module spontaneous reset fand verifies SBTS behavior in this scenario.

Library  SSHLibrary
Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${TESTED_RMOD_SN}  ${EMPTY}  # Provide RMOD SN to be tested e.g. L1140706999


*** Keywords ***
TC__FM__FR_spontaneous_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-6153
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.06.2017 - Test created
    ...  - 06.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7743 - AirScale support added.
    ...  - 12.01.2017 - https://jira3.int.net.nokia.com/browse/TAT-8759
    ...       https://jira3.int.net.nokia.com/browse/TAT-8759
    ...  - 10.06.2018 - https://jira3.int.net.nokia.com/browse/TAT-10349 - fault 10 in step 4 is optional now due to
    ...                                                          incread filtering time, Step 1 modified. Modified Step 7
    ...                                                          Removed Step 5 (cell verificion during RMOD reset).
    ...  - 26.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14430 - Support for 4+3 configs
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 19.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-16618 - Add fault 4387 to Allowed historical allarms due to DSS config
    ...  - 22.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18854 - Modify Get SM Variant function name in FM test cases
    ...  - 19.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19746 - Move keywords to resource file
    ...  - 05.04.2020 - https://jira3.ext.net.nokia.com/browse/TAT-21132 - Remove import for ta_real_radio library
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 08.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29531 - Test fails when connecting to SMOD ip
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-rafal.ozga@nokia.com  MAINTAINER-bogdan.boldurean@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534  FEATURE-RP001145_RP000920  FEATURE-RP001486_RP000920

    Step 1: Get RMOD Object
    Step 2: Get Cell Mapping
    Step 3: Get SM Release, Check If Tested RMOD Is Gaia
    Step 4: RMOD Reset
    Step 5: RMOD Verification After Reset
    Step 6: Verify Present And Historical Alarms
    Step 7: Cells Verification After RMOD Is Back Online


Step 1: Get RMOD Object
    [Documentation]  Step checks if user enered target SN if not first RMOD SN is taken.

    ${is_rmod_defined}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${TESTED_RMOD_SN}
    ${tested_rmod}  Run Keyword If  ${is_rmod_defined}
    ...  Get Chosen RMOD Object
    ...  ELSE
    ...  Get Default RMOD Object
    Set Test Variable  ${TESTED_RMOD}


Get Default RMOD Object
    [Documentation]  This KW was created to randomly choose tested RM. 5.1 radio modules are filtered out as the is no testing method

    Log  SN is not provided tested RM will be randomly choosen  console=TRUE
    ${filtered_rmo_ds}  Create List
    ${rmod_r}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmod_r}
        Run Keyword If  '${rmod.l3Protocol}' != 'CPRI_RP1'
        ...  Append To List  ${filtered_rmo_ds}  ${rmod}
    END

    ${lenght}  Get Length  ${filtered_rmo_ds}
    Log  There are ${lenght} suitable RMs. One of them will be randomly choosen  console=TRUE

    ${selected_position_of_r_min_array}  Evaluate  random.randint(0,${lenght}-1)  random
    ${selected_rmod}  Get From List  ${filtered_rmo_ds}  ${selected_position_of_r_min_array}

    Log  Selected RMOD: ${selected_rmod.productName} with SN: ${selected_rmod.serialNumber}  console=true

    Set Test Variable  ${TESTED_RMOD_SN}  ${selected_rmod.serialNumber}

    ${rmod_r}  Get Infomodel Object  //RMOD_R-* is [serialNumber=${selected_rmod.serialNumber}]
    ${rmod_ref}  Query Infomodel  get object ${rmod_r.dist_name}/REF-*
    ${rmod}  Query Infomodel  get object ${rmod_ref.distName}

    [Return]  ${rmod}


Get Chosen RMOD Object
    ${rmod_r}  Get Infomodel Object  //RMOD_R-* is [serialNumber=${TESTED_RMOD_SN}]
    ${rmod_ref}  Query Infomodel  get object ${rmod_r.dist_name}/REF-*
    ${rmod}  Query Infomodel  get object ${rmod_ref.distName}

    [Return]  ${rmod}


Step 2: Get Cell Mapping
    ${all_cells}  Infomodel Get Cells Deployed On Bts
    ${affected_cells}  Infomodel Get Cells Deployed On RMOD  ${TESTED_RMOD}
    ${not_affected_cells}  Copy List  ${all_cells}
    Remove Values From List  ${not_affected_cells}  @{affected_cells}
    ${affected_cells_dns}  Evaluate  [cell['dist_name'] for cell in ${affected_cells}]
    Log  Affected cells:${affected_cells_dns}  console=true
    ${not_affected_cells_dns}  Evaluate  [cell['dist_name'] for cell in ${not_affected_cells}]
    Log  Not affected cells: ${not_affected_cells_dns}  console=true
    Set Test Variable  ${AFFECTED_CELLS}
    Set Test Variable  ${NOT_AFFECTED_CELLS}


Step 3: Get SM Release, Check If Tested RMOD Is Gaia
    ${sm_varian}  Get SM Variant For RMOD  ${TESTED_RMOD}
    Set Test Variable  ${SM_VARIAN}

    Log  RM at the beggining is connected to: ${SM_VARIAN}  console=TRUE

    Run Keyword If  '${SM_VARIAN}'=='AirScale'
    ...  Run Keyword
    ...  Check If RMOD Connected To AirScale Is Gaia
    Run Keyword If  '${SM_VARIAN}'=='FSMr3'
    ...  Run Keyword
    ...  Check If RMOD Connected To FSMr3 Is Gaia


Check If RMOD Connected To AirScale Is Gaia
    [Documentation]  Kw cheks if tested RMOD is gaia or not

    Get And Save SM Position  ${TESTED_RMOD}
    Set RMOD Conneciton Param Based On SMOD Role
    ${stdout}  ${rc}  Execute Command On RMOD Conencted To AirScale
    Run Keyword If  ${rc}
    ...  Fail  The command failed to execute
    ${is_gaia}  Run Keyword And Return Status
    ...  Should Contain  ${stdout}  gaia
    Set Test Variable  ${IS_GAIA}


Check If RMOD Connected To FSMr3 Is Gaia
    [Documentation]  Kw cheks if tested RMOD is gaia or not

    Set RMOD Conneciton Param Based On SMOD Role
    ${stdout}  ${rc}  Execute Command On RMOD Connected To FSMr3
    Run Keyword If  ${rc}
    ...  Fail  The command failed to execute
    ${is_gaia}  Run Keyword And Return Status
    ...  Should Contain  ${stdout}  gaia
    Set Test Variable  ${IS_GAIA}


Set RMOD Conneciton Param Based On SMOD Role
    ${smod_module_role}  Check If RMOD Is Connected To ESM Or MSM
    Connect To SMOD  ${smod_module_role}


Check If RMOD Is Connected To ESM Or MSM
    ${smod}  Query Infomodel  get object ${TESTED_RMOD.masterAgentDN}
    Run Keyword If  '${smod.ipAddress}'== '192.168.255.129'
    ...  Return From Keyword  192.168.255.129
    ...  ELSE
    ...  Return From Keyword  192.168.255.119


Get And Save SM Position
    [Documentation]  KW returns SMOD Position in integer 1 or 2 for AriScale
    [Arguments]  ${rmod}

    ${smod}  Query Infomodel  get object ${rmod.masterAgentDN}
    Log  Current SMOD to which tested radio module is connected has nodeId: ${smod.nodeIdMaster}  console=TRUE
    ${smod_position}  Run Keyword And Return Status
    ...  Should Contain  '${smod.nodeIdMaster}'  4113

    ${smod_position_integer}  Set Variable If  ${smod_position}==${TRUE}  1  ${smod_position}==${FALSE}  2
    Set Test Variable  ${SMOD_POSITION_INTEGER}


Execute Command On RMOD Conencted To AirScale
    [Documentation]  KW executs command on RMOD conencted to ABIA BBU
    ...  Argument:
    ...  ${RMOD_command}  - command to be executed on RMOD
    ...  Retuns:
    ...  ${stdout} - command output
    ...  ${rc} - ssh connection return code, 0 for succeessful command execution, 1 for fail
    [Arguments]  ${rmod_command}=${EMPTY}  ${telnet_connection_port}=2323

    ${lxc_attach_command}  Catenate  SEPARATOR=  lxc-attach -n 0x${SMOD_POSITION_INTEGER}018 -- bash -c '{ echo ${rmod_command}; sleep 1; } |
    ...  telnet ${TESTED_RMOD.ipAddress} ${telnet_connection_port}'
    ${stdout}  ssh.Execute  ${lxc_attach_command}
    ${rc}  ssh.Get Exit Status

    [Return]  ${stdout}  ${rc}


Execute Command On RMOD Connected To FSMr3
    [Documentation]     KW executs command on RMOD conencted to FSMr3 directly or via BBU
    ...   Argument:
    ...   ${RMOD_command}  - command to be executed on RMOD
    ...   Retuns:
    ...   ${stdout} - command output
    ...   ${rc} - ssh connection return code, 0 for succeessful command execution, 1 for fail
    [Arguments]  ${rmod_command}=${EMPTY}  ${telnet_connection_port}=2323

    ${ssh_command}  Set Variable  { echo ${rmod_command}; sleep 1; } | telnet ${TESTED_RMOD.ipAddress} ${telnet_connection_port}
    ${stdout}  ssh.Execute  ${ssh_command}
    ${rc}  ssh.Get Exit Status

    [Return]  ${stdout}  ${rc}


Step 4: RMOD Reset
    Run Keyword If  ${IS_GAIA}
    ...  Reset Gaia
    ...  ELSE
    ...  Reset Vegas
    ${rmod_connection}  Check If RMOD Is Connected To ESM Or MSM
    Wait Until Keyword Succeeds  60s  5s
    ...  Ping Rmod  ${rmod_connection}  expected_rc=1


Verify If RMOD Is Online
    [Documentation]  Check if tested RMOD is working

    ${rmod_runtime_dn}  Get Dist Name For Tested RMOD
    ${rf_state}  Run Keyword And Return Status
    ...  Assert  RMOD  ${rmod_runtime_dn}  operationalState=${ENABLED}  timeout=90

    [Return]  ${rf_state}


Get Dist Name For Tested RMOD
    [Documentation]  KW returns DN for tested RMOD

    ${tmp_list}  Get Parameters For All  RMOD
    FOR  ${object}  IN  @{tmp_list}
        Return From Keyword If  '${object.serialNumber}'=='${TESTED_RMOD.serialNumber}'  ${object.id}
    END


Reset Gaia
    [Documentation]  If tested RMOD is gaia KW triggers RMOD reset depends on used HW release

    Run Keyword IF  '${SM_VARIAN}'=='AirScale'
    ...  Run Keywords
    ...  Execute Command On RMOD Conencted To AirScale  FRMon action load agent McuAccess Generic _McuAccess  200
    ...  AND
    ...  Execute Command On RMOD Conencted To AirScale  FRMon/Generic/_McuAccess action init McuAccess  200
    ...  AND
    ...  Execute Command On RMOD Conencted To AirScale  FRMon/Generic/_McuAccess action reset SW BIST  200
    ...  AND
    ...  Sleep  10s
    Run KeyWord If  '${SM_VARIAN}'=='FSMr3'
    ...  Run Keywords
    ...  Execute Command On RMOD Connected To FSMr3  FRMon action load agent McuAccess Generic _McuAccess  200
    ...  AND
    ...  Execute Command On RMOD Connected To FSMr3  FRMon/Generic/_McuAccess action init McuAccess  200
    ...  AND
    ...  Execute Command On RMOD Connected To FSMr3  FRMon/Generic/_McuAccess action reset SW BIST  200


Reset Vegas
    [Documentation]  KW triggers RMOD reset depends on used SMOD HW release only for non gaia radio modules

    Run Keyword IF  '${SM_VARIAN}'=='AirScale'
    ...  Execute Command On RMOD Conencted To AirScale  Mcu -r 1 6
    Run Keyword IF  '${SM_VARIAN}'=='FSMr3'
    ...  Execute Command On RMOD Connected To FSMr3  Mcu -r 1 6


Step 5: RMOD Verification After Reset
    Wait Until Keyword Succeeds  180s  5s
    ...  Ping Rmod After Recovery  expected_rc=0


Ping Rmod
    [Arguments]  ${rdmod_smod_ip}  ${expected_rc}=0

    ${command}  Make Command  ping -c1 ${TESTED_RMOD.ipAddress}

    Connect To SMOD  ${rdmod_smod_ip}
    ssh.Execute  ${command}
    ${expected_rc}  Convert To Integer  ${expected_rc}
    ssh.Assert Exit Status  ${expected_rc}


Make Command
    [Arguments]  ${command}

    ${is_air_scale}  Run Keyword And Return Status
    ...  Should Contain  ${SM_VARIAN}  AirScale
    Return From Keyword If  ${is_air_scale}  lxc-attach -n 0x${SMOD_POSITION_INTEGER}018 -- ${command}

    [Return]  ${command}


Ping Rmod After Recovery
    [Documentation]  This KW was created to check if ping to affected RMOD is restored. It's taken into consideration that under
    ...  correspondent RMOD_L connected with two links object masterAgentDN can be changed.
    [Arguments]  ${expected_rc}=0

    ${rmod_r}  Get Infomodel Object  //RMOD_R-* is [serialNumber=${TESTED_RMOD_SN}]
    ${rmod_ref}  Query Infomodel  get object ${rmod_r.dist_name}/REF-*
    ${rmod}  Query Infomodel  get object ${rmod_ref.distName}
    Set Test Variable  ${TESTED_RMOD}  ${rmod}

    Set RMOD Conneciton Param Based On SMOD Role
    ${sm_varian}  Get SM Variant For RMOD  ${TESTED_RMOD}
    Set Test Variable  ${SM_VARIAN}
    Run Keyword If  '${SM_VARIAN}'=='AirScale'
    ...  Run Keyword
    ...  Get And Save SM Position  ${rmod}
    Log  System module variant after recovery is: ${SM_VARIAN}  console=TRUE

    ${command}  Make Command  ping -c1 ${rmod.ipAddress}
    ssh.Execute  ${command}
    ${expected_rc}  Convert To Integer  ${expected_rc}
    ssh.Assert Exit Status  ${expected_rc}


Step 6: Verify Present And Historical Alarms
    Add Allowed Alarm  faultId=10, severity=Critical
    Add Allowed Alarm  faultId=10, severity=Major
    Add Allowed Alarm  faultId=4003
    Add Allowed Alarm  severity=Major
    Add Allowed Alarm  faultId=4387, severity=Minor
    ${present_alarm_verification}  Run Keyword And Return Status
    ...  Admin Check Active Alarms TAF
    ${historical_alarm_verificaiton}  Run Keyword And Return Status
    ...  Assert No Unexpected Historical Alarms
    Run Keyword If  ${present_alarm_verification} == ${FALSE}
    ...  Fail  Unexpected alarm is active
    Run Keyword If  ${historical_alarm_verificaiton} == ${FALSE}
    ...  Fail  Unexpected historical alarm occured during RMOD reset.


Step 7: Cells Verification After RMOD Is Back Online
    Wait Until Keyword Succeeds  180s  5s
    ...  Determine If Cells Have Proper State


Determine If Cells Have Proper State
    Assert Every  LNCEL  operationalState=${ENABLED}
    Assert Every  WNCEL  operationalState=${ENABLED}
    Assert Every  GNCEL  operationalState=${ENABLED}


TC Setup
    Common Test Setup  tc_name=FM__FR_spontaneous_reset


TC Teardown
    Common Test Teardown
