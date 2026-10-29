*** Settings ***
Resource          ../../common_resources/ca_FM_general.robot
Library           ute_async

*** Variables ***
${RECOVERY_TIMEOUT}  360   # Timeout for SBTS to recover after RAT recovery reset
${STARTUP_TIMEOUT}   600   # Timeout for SBTS to recover after startup
${ALARM_TIMEOUT}     90    # Timeout for alarm reporting in WebEM

*** Keywords ***
TC__FM__RAT_reset_actForceAutoReset_false_faulty_cells
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-14585
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case was created to imitate WCDMA DSP crash RAT recovery reset scenario. Multiple rioboot commands will be used
    ...  with write option. Before crash file data.dat with value "OxFFFF" is created in /tmp. To perform DSP crash value 0x128FFFFF
    ...  needs to be put into created file inline with nodeID in hex format. Example rioboot -c write -a 0x128FFFFF -f /tmp/data.dat 0x1335.
    ...  All WCDMA cells should fail and RAT reset should occure.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 17.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-14585 - Initial TAT creation
    ...  - 07.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21139 - Modify faultId regex
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24051 - Optimization of KW usage for FM
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 12.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25140 - Test fail since test does not wait enough for fault to occur
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-bogdan.boldurean@nokia.com   MAINTAINER-bogdan.boldurean@nokia.com
    ...       GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP001534

    step1: Check All Required States
    step2: Trigged WCDMA DSP crash
    step3: Check recovery action result


step1: Check All Required States

    [Documentation]  In this step specific states will be checked.

    Log  \nStep1: Check All Required States.    console=${TRUE}

    Check if configuration is dual core

    Log  \n Check actForceAutoReset and change to false if needed  console=${TRUE}
    ${status}=   Run Keyword And Return Status   Change parameter actForce(Unit)AutoReset  false  actForceAutoReset
    ${parameter_after_change}=   Get actForce(Unit)AutoReset value from infomodel   actForceAutoReset
    Run Keyword if   ${status}
    ...   should be equal  ${parameter_after_change}  false

    ${fault_parameters}  Catenate  SEPARATOR=${SPACE}  faultId=regex"6707|6708|6709",
    ...                                                faultName="RAT autonomous reset as recovery action",
    ...                                                alarmId=7101
    Set test variable  ${FAULT_PARAMETERS}

Check if configuration is dual core
    [Documentation]  This KW is created to check if config consist of two system modules

    ${bts_l}=  Query Infomodel  get list //BTS_L-*
    ${bts_l_lenght}=  Get length  ${bts_l}
    run keyword if  ${bts_l_lenght} < 2
    ...  Fail  msg=Tested configuration is not dual core, test will be set as fail [NOK]
    ...  ELSE
    ...  Log  Tested configuration is dual core, test will contine [OK]  console=${TRUE}


step2: Trigged WCDMA DSP crash
    [Documentation]  In this step WCDMA DSP crash will be performed.

    Log  \nStep2: Trigger WCDMA DSP crash.    console=true

    Create data.dat and put 0xFFFF

    ${DSPs}  Choose DSP for crash test

    Send Fault  ${DSPs}

    ${WCDMA_cell_status}  Run keyword and return status  Assert Every  WNCEL  operationalState=${Disabled_}  timeout=60
    ${faultStatus}=  run keyword and return status  Assert Alarm Active  parameters=${FAULT_PARAMETERS}  timeout=${ALARM_TIMEOUT}

    Run Keyword if  ${faultStatus}
    ...  Log  Fault 6709 with alarm "7101 BASE STATION SERVICE PROBLEM", RAT autonomous reset as recovery action occured [OK]  console=true
    ...  ELSE
    ...  Set Test Failed  Fault 6709 with alarm "7101 BASE STATION SERVICE PROBLEM", RAT autonomous reset as recovery action didn't occur [NOK]

    Run Keyword if  ${WCDMA_cell_status}
    ...  Log  WCDMA cells were failed while fault 6709 occured. [OK]  console=true
    ...  ELSE
    ...  Set test failed  WCDMA cells were not failed while fault 6709 occured. [NOK]

Send Fault
    [Arguments]  ${dsp_list}
    FOR  ${element}  IN  @{dsp_list}
      ssh.Execute  rioboot -c write -a 0x128FFFFF -f /tmp/data.dat 0x${element}
    END

Get hardware type
    ${SM_varian}=  Get SM Variant
    Log  SM is connected to: ${SM_varian}  console=TRUE
    Run Keyword If  '${SM_varian}[0]'=='ASIA' and '${SM_varian}[1]'=='FSMF'
    ...  Return from keyword  A-F
    ...  ELSE IF  '${SM_varian}[0]'=='ASIA' and '${SM_varian}[1]'=='ASIA'
    ...  Return from keyword  A-A
    ...  ELSE IF  '${SM_varian}[0]'=='FSMF' and '${SM_varian}[1]'=='FSMF'
    ...  Return from keyword  F-F



Choose DSP for crash test
    [Documentation]  This KW is created to draw a desired DSP which will be crashed during TC

    ${hw_type}  Get hardware type

    ${wcdmaDSP_list}  Run keyword if  '${hw_type}' == 'A-A'
    ...  Get list of WCDMA DSP for A-A
    ...  ELSE
    ...  Get list of WCDMA DSP for A-F

    ${DSPs}  Run keyword if  '${hw_type}' == 'A-A'
    ...  Get DSP for A-A  ${wcdmaDSP_list}
    ...  ELSE
    ...  Get DSP for A-F  ${wcdmaDSP_list}

    [Return]  ${DSPs}


Select DSP
    [Documentation]  This KW is used for all HW types, and returns list of DSPs
    [Arguments]  ${wcdmaDSPs}  ${number_of_dsp}
    ${selected_DSP}  create list
    FOR  ${element}  IN RANGE  ${number_of_dsp}
      ${listLengt}=  get length  ${wcdmaDSPs}
      ${selectedPositionOfDSPinArray}=  evaluate  random.randint(1,${listLengt}-1)   random
      ${DSP_id}=  get from list  ${wcdmaDSPs}  ${selectedPositionOfDSPinArray}
      Log  Selected DSP: \n ${DSP_id}  console=true
      append to list  ${selected_DSP}  ${DSP_id}
      remove from list  ${wcdmaDSPs}  ${selectedPositionOfDSPinArray}
    END
    [Return]  ${selected_DSP}

Get DSP for A-F
    [Documentation]  This keyword should work also for F-F configurations
    ...  number_of_dsp is 3, the list should contain 3 DSPs due to higher probability to crash all cells.
    [Arguments]  ${wcdmaDSPs}
    ${selected_DSP}  Select DSP  ${wcdmaDSPs}  number_of_dsp=3
    ${selected_node}  Get nodeID  ${selected_DSP}
    [Return]   ${selected_node}

Get DSP for A-A
    [Arguments]  ${wcdmaDSPs}
    ${listLengt}=  get length  ${wcdmaDSPs}
    ${selected_DSP}  create list
    FOR  ${list}  IN  @{wcdmaDSPs}
      ${DSP}  Select DSP  ${list}  number_of_dsp=1
      Append to list  ${selected_DSP}  @{DSP}
    END
    Log  List is ${selected_DSP}  console=true
    ${selected_node}  Get nodeID  ${selected_DSP}
    [Return]   ${selected_node}

Get nodeID
    [Documentation]  This KW adds 1 to DSPs so the rioboot command work.
    [Arguments]  ${DSP_list}
    ${node_list}  create list
    FOR  ${dsp}  IN  @{DSP_list}
    ${key}=  Get Dictionary Keys  ${dsp}
    ${nodeId}=  evaluate  ${dsp["${key[0]}"]}+1
    Append to list  ${node_list}  ${nodeID}
    END
    [Return]  ${node_list}


Get list of WCDMA DSP for A-F
    [Documentation]
    ...  This KW is created to collect DSP for WCDMA for A-F configuration
    ...  This KW is used for F-F configurations due to similar DSP mapping.
    ...  *AUTHOR* bogdan.boldurean@nokia.com

    ${dspList}=  create list
    ${dsp_L_list}=  query infomodel  get list //DSP_L-1/SOFTWARE_ENTITY-* is [rat="WCDMA"]
    FOR  ${entity}  IN  @{dsp_L_list}
       ${dspDict}=  create dictionary
       ${dspObject}=  Query Infomodel  get object ${entity.deviceDN}
       ${nodeId}=  Convert To Hex  ${dspObject.nodeId}
       set to dictionary  ${dspDict}  ${entity.deviceDN}  ${nodeId}
       Append to list  ${dspList}  ${dspDict}
    END
    Should Not Be Empty  ${dspList}  msg=WCDMA is not on Secondary Core. Test will fail.
    [Return]  ${dspList}


Get list of WCDMA DSP for A-A
    [Documentation]
    ...  This KW is created to collect DSP for WCDMA in A-A configuration
    ...  *AUTHOR* bogdan.boldurean@nokia.com

    ${PC_dspList}=  create list
    ${SC_dspList}=  create list
    ${dsp_L_list}=  query infomodel  get list //DSP_L-1/SOFTWARE_ENTITY-* is [rat="WCDMA"]
    FOR  ${entity}  IN  @{dsp_L_list}
       ${dspDict}=  create dictionary
       ${dspObject}=  Query Infomodel  get object ${entity.deviceDN}
       ${nodeId}=  Convert To Hex  ${dspObject.nodeId}
       run keyword if  ${nodeid[0]} == 1
       ...  Run keywords  set to dictionary  ${dspDict}  ${entity.deviceDN}  ${nodeId}  AND  Append to list  ${PC_dspList}  ${dspDict}
       ...  ELSE IF  ${nodeid[0]} == 2
       ...  Run keywords  set to dictionary  ${dspDict}  ${entity.deviceDN}  ${nodeId}  AND  Append to list  ${SC_dspList}  ${dspDict}
    END

    ${AA_dspList}  create list
    Append to list  ${AA_dspList}  ${PC_dspList}  ${SC_dspList}

    [Return]  ${AA_dspList}



step3: Check recovery action result

    [Documentation]  This step check recovery action result.
    Log  step3:\n Verify SBTS after Recovery   console=${TRUE}

    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}

    Check links status  Available
    ${send_fault}=  run keyword and return status  Assert Alarm Inactive    parameters=${FAULT_PARAMETERS}  timeout=90
    Run Keyword if  ${send_fault}
    ...  Log  Fault 6709 for RAT reset cleared.[OK]  console=${TRUE}
    ...  ELSE
    ...  Set test failed  Fault 6709 is visible [NOK]

    Log   \n Site reset will be performed to reset SBTS counters.   console=${TRUE}
    coam.Reset site
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}


TC Setup
    Common test setup

TC Teardown
    Change parameter actForce(Unit)AutoReset  false  actForceAutoReset
    Common Test Teardown

