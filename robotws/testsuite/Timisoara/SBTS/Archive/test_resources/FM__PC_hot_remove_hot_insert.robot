*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot
Library    ute_async

*** Variables ***


*** Keywords ***
TC__FM__PC_hot_remove_hot_insert
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-14035
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case will verify the SBTS functionality after a hot remove / hot insert of the Primary Core.
    ...  The hot remove / hot insert can be simulated with power off-on triggered on Primary Core.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 26.08.2019 - https://jira3.ext.net.nokia.com/browse/TAT-14035 - Initial creation
    ...  - 04.12.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20343 - RP002956 SBTS Operability support for 5G
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  *******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-piotr.szlegel@nokia.com
    ...    MAINTAINER-laura.craciunel@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS17A
    ...    FEATURE-RP001498    FEATURE-RP001621

    step0: Check All Required States
    step1: Power Off Primary Core
    step2: Power On Primary Core
    step3: Check states after site is up


step0: Check All Required States
    [Documentation]  In this step specific states will be checked.

    Log  step0: Check All Required States   console=${TRUE}

    Check if configuration is dual core
    Get primary core serial number
    Checking Hwapi_Domain If Dual Core
    Checking the value of reset counter


Checking Hwapi_Domain If Dual Core
    ${hwapi_domain}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-* is [storedRole=Active]
    Run Keyword if  '${hwapi_domain.hwapiDomainId}' == '1'  run keyword
    ...   BTS_L and receiver value for hwapiDomain1
    ...   ELSE
    ...   BTS_L and receiver value for hwapiDomain2

BTS_L and receiver value for hwapiDomain1
    ${VAR_BTS_L}=  Set Variable  BTS_L-1
    Set Test Variable  ${VAR_BTS_L}

BTS_L and receiver value for hwapiDomain2
    ${VAR_BTS_L}=  Set Variable  BTS_L-4
    Set Test Variable  ${VAR_BTS_L}

Checking the value of reset counter
    ${smod_object}=  Query Infomodel  get object /MRBTS-1/RAT-1/${VAR_BTS_L}/EQM_L-1/CABINET_L-1/SMOD_L-1
    ${reset_counter}=  Set Variable  ${smod_object.restartCounter}
    Log  Current value of reset counter: ${reset_counter}  console=${TRUE}
    Run Keyword if  '${reset_counter}' != '0'  Run Keywords
    ...    Log   Site reset will be performed to clear all counters   console=${TRUE}
    ...    AND   coam.Reset Site
    ...    AND   Wait Until Keyword Succeeds  600  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}

Check if configuration is dual core
    [Documentation]  This KW is created to check if config consist of two system modules

    ${bts_l}=  query infomodel  get list //BTS_L-*
    ${bts_l_lenght}=  get length  ${bts_l}

    run keyword if  ${bts_l_lenght} < 2
    ...  Fail  msg=Tested configuration is not dual core, test will be set as fail [NOK]
    ...  ELSE
    ...  Log  Tested configuration is dual core, test will contine [OK]  console=${TRUE}

Get primary core serial number
    [Documentation]  This KW is created to get primary core serial number

    ${bts_l}=  query infomodel  get list //BTS_L-* is [storedRole=Active]
    ${element}=  get from list  ${bts_l}  0
    ${primary_core_dist_name}=  convert to string  ${element["dist_name"]}/EQM_L-1/CABINET_L-1/SMOD_L-1
    ${primary_core_object}=  Query Infomodel  get object ${primary_core_dist_name}
    Set test variable  ${PRIMARY_CORE_SERIAL_NUMBER}  ${primary_core_object.serialNumber}
    Log   Primary Core Serial Number is: ${PRIMARY_CORE_SERIAL_NUMBER}  console=${TRUE}

step1: Power Off Primary Core
    [Documentation]  Turn off Primary Core and ping Secondary core to check when it will reset it self.

    Log   step1: Power Off Primary Core    console=${TRUE}
    Set Test Variable  ${SMOD_IF}  SMOD_${PRIMARY_CORE_SERIAL_NUMBER}
    Pdu BTS Interface Off  ${SMOD_IF}
    ${ping_loss_status}=  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=192.168.255.119
    ...                                       timeout=300
    ...                                       remote_host=${PC_IP2}
    Run Keyword If  ${ping_loss_status}==${FALSE}  Fail  Ping is not lost  console=${TRUE}
    ...   ELSE  log  Ping to secondary core is lost   console=${TRUE}

step2: Power On Primary Core
    [Documentation]  Turn on Primary Core while ping on secondary core is back.

    Log   Step2: Power On Primary Core  console=${TRUE}
    Log   Wait for Secondary Core to be reachable and turn on Primary Core    console=${TRUE}
    ${ping_up_status}=  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=192.168.255.119   timeout=300  remote_host=${PC_IP2}
    Run Keyword If  ${ping_up_status}==${FALSE}  Fail  Ping on Secondary Core is not back
    ...  ELSE  Run keywords  Log  Secondary Core is back online, perform Primary core power ON  console=${TRUE}   AND
    ...  Pdu BTS Interface On  ${SMOD_IF}

step3: Check states after site is up
    [Documentation]  Check of states on RMODs and Cells

    Log  step3: Check states after site is up  console=${TRUE}

    ${secondary_core_status}=  Check if target is stable  192.168.255.119  30  30  120  remote_host=${PC_IP2}
    ${ping_primary_core}=  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=192.168.255.129   timeout=300
    Run Keyword If  ${ping_primary_core}==${FALSE}  Set Test Failed  Ping has not been regained within timeout
    ...   ELSE   log   Primary Core is reachable   console=${TRUE}

    Run keyword if  ${secondary_core_status}
    ...  Log   Ping on secondary core was not lost  console=${TRUE}
    ...  ELSE
    ...  Fail  msg=Ping to secondary core was lost after reset test will be set as failed

    ${rmods}=  run keyword and return status  Wait Until Keyword Succeeds  600s  10s  Assert Every  RMOD  operationalState=${Enabled_}  timeout=60
    Run Keyword If  ${rmods}
    ...  Log  All rmods are operationalState=enabled - recovery succedeed [OK]  console=${TRUE}
    ...  ELSE
    ...  Set Test Failed  message=Some rmods statuses are wrong - recovery filed [NOK]
    ${cells}=  run keyword and return status  Wait Until Keyword Succeeds  300s  10s  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Run Keyword If  ${cells}
    ...  Log  All cells are in working state. [OK]  console=${TRUE}
    ...  ELSE
    ...  Set Test Failed  message=Some cells are NOT in working state - recovery filed [NOK]

    Admin Check Active Alarms TAF

    ${FAULT_ID}=  Set Variable  4352
    Log   RawAlarmHistory Verification    console=${TRUE}
    ${alarm_in_inactives}=  hran_file_operations.Rah Check Alarm By Id  ${FAULT_ID}  is_active=False
    ${alarm_in_actives}=  hran_file_operations.Rah Check Alarm By Id  ${FAULT_ID}  is_active=True
    Run Keyword If  ${alarm_in_inactives}  Log   Fault ${FAULT_ID} reported in RawAlarmHistory  console=${TRUE}
    ...  ELSE IF  ${alarm_in_actives}  Set Test Restriction   Fault ${FAULT_ID} not cancelled in RawAlarmHistory
    ...  ELSE  Set Test Failed  Fault ${FAULT_ID} not reported in RawAlarmHistory

TC Setup
    Common test setup

TC Teardown
    Run Keyword If Test Failed  Pdu BTS Interface On  ${SMOD_IF}
    Common Test Teardown

