*** Settings ***
Documentation
  ...  The purpose of this test case is to verify CB006017 feature, "Nokia Service account management on RU" focuses on synchronizing the service
  ...  account credentials and SSH configuration between system module and connected radio units
  ...  Author:        anna.maciejewska@nokia.com
  ...  Maintainer:    anna.maciejewska@nokia.com
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------------------+------+--------------------------------------------------------------------------------------------------+
  ...  | Parameter                   | Man. | Description                                                                                      |
  ...  +=============================+======+==================================================================================================+
  ...  | RMODS_SN_LIST               | No   | List of radio modules serial numbers on which test case will be executed                         |
  ...  |                             |      | E.g: BL2311H604M  1M250100005  please remember to have at least two spaces between serial numbers|
  ...  |                             |      | If user leave this empty, test case will be executed on all radio modules in configuration       |
  ...  +-----------------------------+------+--------------------------------------------------------------------------------------------------+
  ...  |CONFIGURATION_STARTUP_TIMEOUT| No   | startup timeout for configuration after site reset operation. Default 360 seconds                |
  ...  +-----------------------------+------+--------------------------------------------------------------------------------------------------+
  ...  |SSH_TIMER                    | No   | value for parameter 'sshSessionLoginDelayTimer', default 30               |
  ...  +-----------------------------+------+--------------------------------------------------------------------------------------------------+
  ...
  ...
  ...  The purpose of this test case is to verify CB006017 feature, "Nokia Service account management on RU" focuses on synchronizing the service
  ...  account credentials and SSH configuration between system module and connected radio units
  ...
  ...  To perform "Synchronize To Radio Modules' in Webem Security page all radio modules in configuration should support this feature.
  ...
  ...  STEPS:
  ...  Preconditions Nokia Service Account Management On RU
  ...  This step prepares needed variables and checks values of 'actSyncToRU' and 'sshSessionLoginDelayTimer'
  ...  Set them to default values 'actSyncToRU'=False and 'sshSessionLoginDelayTimer'=10 if needed.
  ...
  ...  Step1: Logging To Radio Module With Root Radio Module Credentials
  ...  Step2: Logging To Radio Module With Serivceuser Radio Module Credentials
  ...  Step3: Enable 'actSyncToRU' And Set 'sshSessionLoginDelayTimer' To 60s
  ...  Step4: Enable 'Synchronize To Radio Modules' Functionality
  ...  Step5: Logging To Radio Module With Serivceuser System Module Credentials
  ...  Step6: Verify The 'sshSessionLoginDelayTimer' On Radio Module
  ...  Step7: Perform Site Reset
  ...  Step8: Logging To Radio Module With Serivceuser System Module Credentials
  ...  Step9: Verify The 'sshSessionLoginDelayTimer' On Radio Module
  ...  Step10: Disable 'actSyncToRU'
  ...  Step11: Perform Site Reset
  ...  Step12: Logging To Radio Module With Serivceuser Radio Module Credentials
  ...  Step13: Check The 'sshSessionLoginDelayTimer' Is Restored To Default On Radio Module
  ...  Step14: Restore 'sshSessionLoginDelayTimer' To Its Default Value 10s
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  10.09.2025 - Initial creation - CASE: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-18542
  ...  17.09.2025 - SSH_TIMER added, one login session to rmod in step 6 and 13

Resource  ./../../Resources/Setup/setup_and_teardown.robot


*** Variables ***

@{RMODS_SN_LIST}                              #List of radio modules serial numbers on which test case will be executed
                                              # example: BL2311H604M  1M250100005  please remember to have at least two spaces between serial numbers
                                              # If user leave this empty, test case will be executed on all radio modules in configuration
${CONFIGURATION_STARTUP_TIMEOUT}    360       # startup timeout for configuration after site reset operation. Default 360 seconds.
${SSH_TIMER}    30                            # value for parameter 'sshSessionLoginDelayTimer', default 30
${OFFSET}    0

*** Keywords ***
TC__SEC_Nokia_Service_Account_Management_On_RU
    Set Tags    AUTHOR-anna.maciejewska@nokia.com  MAINTAINER-anna.maciejewska@nokia.com
    Common Test Setup
    Preconditions Nokia Service Account Management On RU
    Step1: Logging To Radio Module With Root Radio Module Credentials
    Step2: Logging To Radio Module With Serivceuser Radio Module Credentials
    Step3: Enable 'actSyncToRU' And Set 'sshSessionLoginDelayTimer'
    Step4: Enable 'Synchronize To Radio Modules' Functionality
    Step5: Logging To Radio Module With Serivceuser System Module Credentials
    Step6: Verify The 'sshSessionLoginDelayTimer' On Radio Module
    Step7: Perform Site Reset
    Step8: Logging To Radio Module With Serivceuser System Module Credentials
    Step9: Verify The 'sshSessionLoginDelayTimer' On Radio Module
    Step10: Disable 'actSyncToRU'
    Step11: Perform Site Reset
    Step12: Logging To Radio Module With Serivceuser Radio Module Credentials
    Step13: Check The 'sshSessionLoginDelayTimer' Is Restored To Default On Radio Module
    Step14: Restore 'sshSessionLoginDelayTimer' To Its Default Value 10s
    [Teardown]  Teardown Nokia Service Account Management On RU

Preconditions Nokia Service Account Management On RU
     Logging With Timestamp
     ...  message=Preconditions Nokia Service Account Management On RU
     ...  style=STEP
     ...  frame=${TRUE}
     ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
     Set Test Variable  ${BTS_ID}  ${bts_id}
     Set Test Variable  ${CONFIGURATION_STARTUP_TIMEOUT}  ${CONFIGURATION_STARTUP_TIMEOUT}
     ${rmods_sn_list_status}  Run Keyword And Return Status  Should Not Be Empty  ${RMODS_SN_LIST}
     IF  ${rmods_sn_list_status}
       Logging With Timestamp
       ...  message=User defined own list of radio modules on which Test Case will be performed @{RMODS_SN_LIST}
     ELSE
       ${rf_list}  Get Dictionary Keys  ${cfg.RF_INFO}
       Set Test Variable  ${RMODS_SN_LIST}  ${rf_list}
       Logging With Timestamp
       ...  message=User didin't define own list of radio modules on which Test Case will be performed.
       ...  message_2=Test Case will be executed on all radio modules in configuration ${RMODS_SN_LIST}
     END
     Check And Recommissioning Parameters If Needed  ${BTS_ID}


Step1: Logging To Radio Module With Root Radio Module Credentials
    Logging With Timestamp
    ...  message=Step1: Logging To Radio Module With Root Radio Module Credentials
    ...  style=STEP
    ...  frame=${TRUE}

    FOR  ${rmod_sn}  IN  @{RMODS_SN_LIST}
      ${root_password}  Evaluate  __import__('radio_variables').RMOD_PASSWORDS_ROOT['${CFG['RF_INFO']['${rmod_sn}']['scf_variant']}'][1]
      Logging With Timestamp
      ...  message=Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn} with 'root' radio module credentials.
      ${status}  Run Keyword And Return Status  radio.Open Connection To Radio Module
      ...  ru_serial_number=${rmod_sn}
      ...  username=root
      ...  password=${root_password}
      IF  ${status}
        radio.Close SSH Connection
        Logging With Timestamp
        ...  message=Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn} is possible, but it should not be.
        ...  style=ERROR
        Fail    Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn} is possible, but it should not be.
      ELSE
        Logging With Timestamp
        ...  message=Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn}
        ...  message_2=wasn't possible with 'root' credentials. It is correct behaviour.
      END
    END

Step${step_number}: Logging To Radio Module With Serivceuser Radio Module Credentials
    Logging With Timestamp
    ...  message=Step${step_number}: Logging To Radio Module With Serivceuser Radio Module Credentials
    ...  style=STEP
    ...  frame=${TRUE}

    FOR  ${rmod_sn}  IN  @{RMODS_SN_LIST}
      Logging With Timestamp
      ...  message=Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn} with 'Serivceuser' radio module credentials
      ${status}  Run Keyword And Return Status  Open Connection To Radio Module    ru_serial_number=${rmod_sn}
      IF  ${status}
        radio.Close SSH Connection
        Logging With Timestamp
        ...  message=Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn}
        ...  message_2=was possible with 'Serivceuser' radio module credentials. It is correct behaviour.
      ELSE
        Logging With Timestamp
        ...  message=Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn} wasn't possible, but it should be.
        ...  style=ERROR
        Fail  Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn} wasn't possible, but it should be.
      END
    END

Step3: Enable 'actSyncToRU' And Set 'sshSessionLoginDelayTimer'
    Logging With Timestamp
    ...  message=Step3: Enable 'actSyncToRU' and set 'sshSessionLoginDelayTimer'
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Setting 'actSyncToRU' to True
    ...  message_2=Setting 'sshSessionLoginDelayTimer' to ${SSH_TIMER}
   ${delta_id}  Set Variable  delta_parameters
    admin.Create Delta  delta_id=${delta_id}
    admin.Append Parameter Update To Delta
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...  parameter=actSyncToRU
    ...  value=true
    ...  delta_id=${delta_id}
    admin.Append Parameter Update To Delta
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...  parameter=sshSessionLoginDelayTimer
    ...  value=${SSH_TIMER}
    ...  delta_id=${delta_id}
    ${delta}  admin.Get Delta  delta_id=${delta_id}
    admin.Perform Delta Recommissioning  delta_file=${delta}
    ...  connection=${BTS_ID}
    admin.Remove Delta  delta_id=${delta_id}
    Logging With Timestamp
    ...  message=Delta commissioning with "sshSessionLoginDelayTimer" and "actSyncToRU" parameters finished.


    Logging With Timestamp
    ...  message=Checking if parameters 'actSyncToRU' and 'sshSessionLoginDelayTimer' were properly set.
    ${secadm_parameters}  admin.Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1  connection=${BTS_ID}
    IF  '${secadm_parameters[0]['parameters']['sshSessionLoginDelayTimer']}'!='${SSH_TIMER}'
      Logging With Timestamp
      ...  message='sshSessionLoginDelayTimer' value is ${secadm_parameters[0]['parameters']['sshSessionLoginDelayTimer']} instead of ${SSH_TIMER}
      ...  style=ERROR
      Fail  Current 'sshSessionLoginDelayTimer' value is  ${secadm_parameters[0]['parameters']['sshSessionLoginDelayTimer']} instead of ${SSH_TIMER}.
    ELSE
      Logging With Timestamp
      ...  message=Current sshSessionLoginDelayTimer was properly set to ${secadm_parameters[0]['parameters']['sshSessionLoginDelayTimer']}
    END
    IF  '${secadm_parameters[0]['parameters']['actSyncToRU']}'!='True'
      Logging With Timestamp
      ...  message=Current 'actSyncToRU' value is ${secadm_parameters[0]['parameters']['actSyncToRU']} instead of True
      ...  style=ERROR
      Fail  Current 'actSyncToRU' value is ${secadm_parameters[0]['parameters']['actSyncToRU']} instead of True
    ELSE
      Logging With Timestamp
      ...  message=Current 'actSyncToRU' was properly set to ${secadm_parameters[0]['parameters']['actSyncToRU']}
    END

Step4: Enable 'Synchronize To Radio Modules' Functionality
    Logging With Timestamp
    ...  message=Step4: Enable 'Synchronize To Radio Modules' Functionality
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Perform 'Synchronize To Radio Modules'
    admin.Sync To Radio Modules  detailed_output=True  connection=${BTS_ID}
    Logging With Timestamp
    ...  message='Synchronize To Radio Modules' was done properly.

Step${step_number}: Logging To Radio Module With Serivceuser System Module Credentials
    Logging With Timestamp
    ...  message=Step${step_number}: Logging To Radio Module With Serivceuser System Module Credentials
    ...  style=STEP
    ...  frame=${TRUE}

    FOR  ${rmod_sn}  IN  @{RMODS_SN_LIST}
      Logging With Timestamp
      ...  message=Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn} with 'Serivceuser' system module credentials
      ${status}  Run Keyword And Return Status  radio.Open Connection To Radio Module
      ...  ru_serial_number=${rmod_sn}
      ...  username=serviceuser
      ...  password=Pl(FzaYj5~c5;q
      IF  ${status}
        radio.Close SSH Connection
        Logging With Timestamp
        ...  message=Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn}
        ...  message_2=was possible with 'Serivceuser' system module credentials. It is correct behaviour.
      ELSE
        Logging With Timestamp
        ...  message=Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn} wasn't possible, but it should be.
        ...  style=ERROR
        Fail  Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn} wasn't possible, but it should be.
      END
    END

Step${step_number}: Verify The 'sshSessionLoginDelayTimer' On Radio Module
    Logging With Timestamp
    ...  message=Step${step_number}: Verify The 'sshSessionLoginDelayTimer' On Radio Module
    ...  style=STEP
    ...  frame=${TRUE}

    FOR  ${rmod_sn}  IN  @{RMODS_SN_LIST}
      ${rmod_name}  Set Variable  ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']}
      Logging With Timestamp
      ...  message=Logging to radio module ${rmod_name} ${rmod_sn} with 'Serivceuser' radio module credentials.
      ${status}  Run Keyword And Return Status  Open Connection To Radio Module  ru_serial_number=${rmod_sn}
      IF  ${status}
        radio.Close SSH Connection
        Logging With Timestamp
        ...  message=Logging to radio module ${rmod_name} ${rmod_sn}
        ...  message_2=was possible with 'Serivceuser' radio module credentials. It is not correct behaviour.
        ...  style=ERROR
        Fail  Logging to radio module ${rmod_name} ${rmod_sn} was possible with Serivceuser' radio module credentials. It is not correct.
      ELSE
        Logging With Timestamp
        ...  message=Logging to radio module ${rmod_name} ${rmod_sn} wasn't possible with radio module credentials. It is correct behaviour.
        ${output}  radio.Read Output
        IF  ${output}==None
          ${sleep_duration}  Evaluate  ${SSH_TIMER}-20+${OFFSET}
          Sleep   ${sleep_duration}s
          ${status1}  ${output1}  Run Keyword And Ignore Error  radio.Read Until Regexp  password  1
          ${output2}  radio.Read Output
          IF  '${status1}'=='PASS'
            radio.Send Command  Pl(FzaYj5~c5;q
            radio.Read Until Prompt  $|#  5
            Logging With Timestamp
            ...  message=Rmod connection was possible with smod serviceuser credentials after ${SSH_TIMER}s set by sshSessionLoginDelayTimer
            radio.Close Ssh Connection
          ELSE
            ${status2}  ${output3}  Run Keyword And Ignore Error  radio.Read Until Regexp  password  60
            radio.Close Ssh Connection
            Logging With Timestamp
            ...  message=Connection to rmod still wasn't possible after ${SSH_TIMER}s set by sshSessionLoginDelayTimer
            ...  message_2=Current output from radio module ${output2}
            ...  style=EROOR
            Fail  Connection to rmod still wasn't possible after ${SSH_TIMER}s set by sshSessionLoginDelayTimer
          END
        ELSE
          Logging With Timestamp
          ...  message=Login to rmod wasn't blocked for ${SSH_TIMER}s set by sshSessionLoginDelayTimer after improper login trial
          ...  message_2=Current output from radio module: ${output}
          ...  style=EROOR
          Fail  Connection to rmod wasn't blocked for ${SSH_TIMER}s set by sshSessionLoginDelayTimer
        END
      END
    END

Step${step_number}: Perform Site Reset
    Logging With Timestamp
    ...  message=Step${step_number}: Perform Site Reset
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Site Reset is ongoing.
    admin.Reset Site
    ...  connection=${BTS_ID}
    ...  wait_for_reconnection=True
    ...  detailed_output=True
    ...  graceful_cell_shutdown=True
    ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}

    CM BTS Admin Not Available
    ...  node=${BTS_ID}
    ...  timeout=120

    Logging With Timestamp
    ...  message=Site Reset is done. BTS states verification.

    STATE Verify BTS states
    ...  node_id=${BTS_ID}
    ...  expected_BTS_status=OnAir
    ...  HW_check=${TRUE}
    ...  cells_check=${TRUE}
    ...  scf_check=${FALSE}
    ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}


Step10: Disable 'actSyncToRU'
    Logging With Timestamp
    ...  message=Step10: Disable 'actSyncToRU'
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Setting 'actSyncToRU' to False
    admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...  parameter=actSyncToRU
    ...  operation=update
    ...  value=false
    ...  connection=${BTS_ID}

    Logging With Timestamp
    ...  message=Checking if parameter 'actSyncToRU' was properly set.
    ${secadm_parameters}=  admin.Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1  connection=${BTS_ID}
    IF  '${secadm_parameters[0]['parameters']['actSyncToRU']}'!='False'
       Logging With Timestamp
       ...  message=Current 'actSyncToRU' value is ${secadm_parameters[0]['parameters']['actSyncToRU']} instead of False
       ...  style=ERROR
       Fail  Current 'actSyncToRU' value is ${secadm_parameters[0]['parameters']['actSyncToRU']} instead of False
    ELSE
       Logging With Timestamp
       ...  message=Current 'actSyncToRU' was properly set to ${secadm_parameters[0]['parameters']['actSyncToRU']}
    END

Step13: Check The 'sshSessionLoginDelayTimer' Is Restored To Default On Radio Module
    Logging With Timestamp
    ...  message=Step13: Check The 'sshSessionLoginDelayTimer' Is Restored To Default On Radio Module
    ...  style=STEP
    ...  frame=${TRUE}

    FOR  ${rmod_sn}  IN  @{RMODS_SN_LIST}
      Logging With Timestamp
      ...  message=Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn}
      ...  message_2=with 'Serivceuser' system module credentials.
      ${status}  Run Keyword And Return Status
      ...  radio.Open Connection To Radio Module  ru_serial_number=${rmod_sn}  username=serviceuser  password=Pl(FzaYj5~c5;q
      IF  ${status}
        radio.Close SSH Connection
        Logging With Timestamp
        ...  message=Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn}
        ...  message_2=was possible with 'Serivceuser' system module credentials. It is not correct behaviour.
        ...  style=ERROR
        Fail  Logging to radio module  ${rmod_sn} was possible with 'Serivceuser' system module credentials. It is not correct behaviour.
      ELSE
        Logging With Timestamp
        ...  message=Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn}
        ...  message_2=wasn't possible with system module credentials. It is correct behaviour.
        ${rmod_password}  Evaluate  __import__('radio_variables').RMOD_PASSWORDS['${CFG['RF_INFO']['${rmod_sn}']['scf_variant']}'][1]
        radio.Send Command  ${rmod_password}
        ${status}  ${output}  Run Keyword And Ignore Error  radio.Read Until Prompt  $|#  2
        IF  '${status}'=='PASS'
          Logging With Timestamp
          ...  message=Rmod connection was possible with rmod serviceuser credentials on default sshSessionLoginDelayTimer
          radio.Close Ssh Connection
        ELSE
          Logging With Timestamp
          ...  message=Logging to radio module ${CFG['RF_INFO']['${rmod_sn}']['scf_variant']} ${rmod_sn}
          ...  message_2=wwasn't possible with rmod serviceuser credentials on default rmod sshSessionLoginDelayTimer. It is not correct behaviour.
          ...  style=ERROR
          Fail  Logging to radio module  ${rmod_sn} wwasn't possible with rmod serviceuser credentials on default rmod sshSessionLoginDelayTimer.
        END
      END
    END

Step14: Restore 'sshSessionLoginDelayTimer' To Its Default Value 10s
    Logging With Timestamp
    ...  message=Step14: Restore 'sshSessionLoginDelayTimer' To Its Default Value 10s
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Setting 'sshSessionLoginDelayTimer' to 10
    admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...  parameter=sshSessionLoginDelayTimer
    ...  operation=update
    ...  value=10
    ...  connection=${BTS_ID}

    Logging With Timestamp
    ...  message=Checking if parameter 'sshSessionLoginDelayTimer' was properly set.
    ${secadm_parameters}=  admin.Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1  connection=${BTS_ID}
    IF  '${secadm_parameters[0]['parameters']['sshSessionLoginDelayTimer']}'!='10'
      Logging With Timestamp
      ...  message=Current 'sshSessionLoginDelayTimer' value is  ${secadm_parameters[0]['parameters']['sshSessionLoginDelayTimer']} instead of 10.
      ...  style=ERROR
      Fail  Current 'sshSessionLoginDelayTimer' value is  ${secadm_parameters[0]['parameters']['sshSessionLoginDelayTimer']} instead of 10.
    ELSE
      Logging With Timestamp
      ...  message=Current sshSessionLoginDelayTimer was properly set to ${secadm_parameters[0]['parameters']['sshSessionLoginDelayTimer']}
    END


Check And Recommissioning Parameters If Needed
   [Arguments]  ${bts_id}
   [Documentation]
   ...    Description:
   ...    Keyword checks parameters sshSessionLoginDelayTimer and actSyncToRU. If they don't have default values, performs recommissiong to
   ...    sshSessionLoginDelayTimer=10 and actSyncToRU=False. After this operation site reset is executed.
   ...
   ...    Arguments:
   ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
   ...    | Argument           | Man.  | Description                                                                                   |
   ...    +====================+=======+===============================================================================================+
   ...    | bts_id             | Yes   | BTS ID number                                                                                 |
   ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
   ...
   ...    Author: anna.maciejewska@nokia.com
   ...    Maintainer: anna.maciejewska@nokia.com

    Logging With Timestamp
    ...  message=Check current values for 'sshSessionLoginDelayTimer' and 'actSyncToRU'
    ${secadm_parameters}=  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/SECADM-1  connection=${bts_id}
    IF  '${secadm_parameters[0]['parameters']['sshSessionLoginDelayTimer']}'!='10'
      Logging With Timestamp
      ...  message=Current value for 'sshSessionLoginDelayTimer' is ${secadm_parameters[0]['parameters']['sshSessionLoginDelayTimer']} instead of 10
      ...  message_2=Recommissioning 'sshSessionLoginDelayTimer' to 10
      admin.Perform Parameter Recommissioning
      ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SECADM-1
      ...  parameter=sshSessionLoginDelayTimer
      ...  operation=update
      ...  value=10
      ...  connection=${bts_id}
    ELSE
      Logging With Timestamp
      ...  message=Current value for 'sshSessionLoginDelayTimer' is ${secadm_parameters[0]['parameters']['sshSessionLoginDelayTimer']}
      ...  message_2=This is default value. Recommissioning not needed.
    END

    IF  '${secadm_parameters[0]['parameters']['actSyncToRU']}'!='False'
      Logging With Timestamp
      ...  message=Current value for 'actSyncToRU' is ${secadm_parameters[0]['parameters']['actSyncToRU']} instead of False
      ...  message_2=Recommissioning 'actSyncToRU' to False
      admin.Perform Parameter Recommissioning
      ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/SECADM-1
      ...  parameter=actSyncToRU
      ...  operation=update
      ...  value=false
      ...  connection=${bts_id}

      Logging With Timestamp
      ...  message=Site Reset is ongoing.
      admin.Reset Site
      ...  connection=${bts_id}
      ...  wait_for_reconnection=True
      ...  detailed_output=True
      ...  graceful_cell_shutdown=True
      ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}

      CM BTS Admin Not Available
      ...  node=${bts_id}
      ...  timeout=120

      Logging With Timestamp
      ...  message=Site Reset is done. BTS states verification.

      STATE Verify BTS states
      ...  node_id=${bts_id}
      ...  expected_BTS_status=OnAir
      ...  HW_check=${TRUE}
      ...  cells_check=${TRUE}
      ...  scf_check=${FALSE}
      ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}

    ELSE
      Logging With Timestamp
      ...  message=Current value for 'actSyncToRU' is ${secadm_parameters[0]['parameters']['actSyncToRU']}
      ...  message_2=This is default value. Recommissioning not needed.
    END


Teardown Nokia Service Account Management On RU
   Logging With Timestamp
   ...  message=TC TEARDOWN back to parameters default values
   ...  style=ONGOING
   Run Keyword And Ignore Error  Check And Recommissioning Parameters If Needed  ${BTS_ID}
   Common Test Teardown
