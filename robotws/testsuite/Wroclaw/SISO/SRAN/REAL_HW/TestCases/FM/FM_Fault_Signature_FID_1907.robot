*** Settings ***
Documentation
...  Triggers given RU fault and checks if faultSignature part of alarm response contains correct values
...  Tested Radio should have NR cell commissioned with parameter targetTotalLoad for proper fault 1907 triggering.
...
...
...    Author:        daria.wronska@nokia.com
...    Maintainer:    daniel.bartkowiak@nokia.com

Resource    ./FM_Fault_Signature.resource

*** Variables ***
${RADIO_STARTUP_DELAY}     600         #Custom radio startup delay
${RECOVERY_SITE_RESET}     ${FALSE}    #Recovery site reset to clear radio counter and avoid improper fault generation in multiply iterations
                                       #To avoid impact for other Fault Signature TCs in same TS then set flag TRUE
&{4_4_NRCELL_ID_DICT}      &{EMPTY}    #Provide NR cell configuration id for recommissioning parameter targetTotalLoad on 4x4 cell
                                       #SCF on BTS should have already commissioned targetTotalLoad to any value, default 0
                                       #For example if NRCELL-13 is on tested Ru then set to dictionary L1181207093 = 13.
                                       #'4_4_NRCELL_ID' dictionary can contain several entries if multiple RU tested in one TS.

#@{CUSTOM_RADIO_UNIT_LIST}             - Custom radio list
#${FID_1907_TIMEOUT}                   - timeout for faultsignature threshold, default 1200s. Can be set by user if needed

*** Keywords ***
TC__FM_Fault_Signature_FID_1907
    [Documentation]    Triggers given RU fault and checks if faultSignature part of alarm response contains correct values
    ...  Fault 1907 is supported for radios 6.2 and higher. Method for Fault 1907 on RU 5.1 is obsolete.
    ...  NOTE. Parameter tagrgetTotalLoad=100 should be set on NR cell when radio 6.2 and above tested.
    ...    Author:        daria.wronska@nokia.com
    ...    Maintainer:    Daniel Bartkowiak
    Common Test Setup
    Logging With Timestamp
    ...  message=RF Fault Signature FID1907
    ...  style=STEP
    ...  frame=${TRUE}
    ${rf_list}=  Get Dictionary Keys   ${cfg.RF_INFO}
    ${RF_status}=  Run Keyword And Return Status  Should Not Be Empty  ${CUSTOM_RADIO_UNIT_LIST}
    ${rf_list}=  Set Variable If   ${RF_status}  ${CUSTOM_RADIO_UNIT_LIST}  ${rf_list}
    FOR  ${ru_sn}  IN  @{rf_list}
      Variable Should Exist  ${4_4_NRCELL_ID_DICT['${ru_sn}']}  msg=Provide NR cell configuration id for ${ru_sn} in variable 4_4_NRCELL_ID_DICT
      ${ru_bts_id}  ${ru_dist_name}=  SITE Get RU Node Data  ${ru_sn}
      Set Test Variable  ${RU_DIST_NAME}  ${ru_dist_name}
      Set Test Variable  ${RU_BTS_ID}  ${ru_bts_id}
      Get TargetTotalLoad Initial Value  bts_id=${RU_BTS_ID}  ru_sn=${ru_sn}
      ${recommissioning_status}=  Run Keyword And Return Status  Perform TargetTotalLoad Recommissioning
      ...  bts_id=${RU_BTS_ID}  value=100  ru_sn=${ru_sn}
      IF  not ${recommissioning_status}
        Logging With Timestamp
        ...  message=Parameter targetTotalLoad recommissioning failed.
        ...  style=ERROR
        Fail  Parameter targetTotalLoad recommissioning failed.
      END
      ${cell_r_dn}=  admin.Get Cell Id By Configuration Id
      ...  rat=NR
      ...  configuration_id=${4_4_NRCELL_ID_DICT['${ru_sn}']}
      ...  connection=${RU_BTS_ID}
      Set Test Variable  ${TESTED_CELL_R_DISTNAME}  ${cell_r_dn}
      Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=10, serialNo=${ru_sn}  connection=${ru_bts_id}
      Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=1815, serialNo=${ru_sn}  connection=${ru_bts_id}
      Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=1920, serialNo=${ru_sn}  connection=${ru_bts_id}
      Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=1907, serialNo=${ru_sn}  connection=${ru_bts_id}
      ${alarm_info}  ${fid1907_warning_timestamp}  ${critical_alarm_info}  ${fid1907_critical_timestamp}=  Generate Fault FID1907
      ...  ru_sn=${ru_sn}  ru_dist_name=${RU_DIST_NAME}  connection=${RU_BTS_ID}

      Run Keyword And Ignore Error  Perform TargetTotalLoad Recommissioning
      ...  bts_id=${RU_BTS_ID}
      ...  value=${INITIAL_PARAMETER}
      ...  ru_sn=${ru_sn}

      Logging With Timestamp
      ...  message=-----Checking fault signature data of Fault 1907-----

      FM Analyze Alarm List For Fault Signature
      ...  alarm_info=${alarm_info}
      ...  faultId=1907
      ...  fault_signature_scheme=${FID1907_FAULT_SIGNATURE_SCHEME}
      ...  alarm_details_scheme=${FID_1907_ALARM_INFO}
      ...  fault_signature_timestamp=${fid1907_warning_timestamp}
      ...  timestamp_timeout=${FID_1907_TIMEOUT}
      ...  ru_sn=${ru_sn}
      ...  forbidden_severities='Critical'
      ...  allowed_severities=${None}
      ...  connection=${RU_BTS_ID}

      FM Analyze Alarm List For Fault Signature
      ...  alarm_info=${critical_alarm_info}
      ...  faultId=1907
      ...  fault_signature_scheme=${CRITICAL_FAULT_SIGNATURE_SCHEME}
      ...  alarm_details_scheme=${FID_1907_ALARM_INFO}
      ...  fault_signature_timestamp=${fid1907_critical_timestamp}
      ...  timestamp_timeout=${FID_1907_TIMEOUT}
      ...  ru_sn=${ru_sn}
      ...  forbidden_severities=${None}
      ...  allowed_severities=Critical
      ...  connection=${RU_BTS_ID}
    END
    [Teardown]  Run Keywords
    ...  Run Keyword And Ignore Error  Perform TargetTotalLoad Recommissioning
    ...  bts_id=${RU_BTS_ID}
    ...  value=${INITIAL_PARAMETER}
    ...  ru_sn=${ru_sn}
    ...  AND  Run Keyword If  ${RECOVERY_SITE_RESET}
    ...  FM Recovery Site Reset For Fault Signature
    ...  bts=${RU_BTS_ID}
    ...  ru_dist_name=${RU_DIST_NAME}
    ...  timeout=${RADIO_STARTUP_DELAY}
    ...  AND  Common Test Teardown

Generate Fault FID1907
    [Arguments]  ${ru_sn}  ${ru_dist_name}  ${connection}
    [Documentation]
    ...  Triggers 1907 with severity Warning/Critical on tested radio. After that check if FID1907 is reported
    ...
    ...  |  **Author:**      daniel.bartkowiak@nokia.com
    ...  |  **Maintainer:**  daniel.bartkowiak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+--------------------------------------------------+
    ...  | Parameter    | Man. | Description                                      |
    ...  +==============+======+==================================================+
    ...  | ru_sn        | Yes  | serial number of radio unit under test           |
    ...  +--------------+------+--------------------------------------------------+
    ...  | ru_dist_name | Yes  | internal id of radio unit under test             |
    ...  +--------------+------+--------------------------------------------------+
    ...  | connection   | Yes  | alias for active ssh connection to SMOD          |
    ...  +--------------+------+--------------------------------------------------+
    ...
    ...  **Return parameters**
    ...
    ...  +-----------------------------+--------------------------------------------------+
    ...  | Parameter                   | Description                                      |
    ...  +=============================+==================================================+
    ...  | warning_alarm_info          | list containing active alarms info               |
    ...  +-----------------------------+--------------------------------------------------+
    ...  | fid1907_warning_timestamp   | timestam of the begining of the radio reset      |
    ...  +-----------------------------+--------------------------------------------------+
    ...  | critical_alarm_info         | list containing active alarms info               |
    ...  +-----------------------------+--------------------------------------------------+
    ...  | fid1907_critical_timestamp  | timestam of the begining of the radio reset      |
    ...  +-----------------------------+--------------------------------------------------+

    Logging With Timestamp
    ...  message=Generating fault 1907 Warning. Should appear three times.
    ${fid1907_warning_timestamp}=  Get Current Date  UTC

    FOR  ${index}  IN RANGE  1  4
      radio.Generate Fault  fault_id=1907  ru_serial_number=${ru_sn}
      Sleep  5  Timeout between fault generating actions
      admin.Reset Cell  cell_id=${TESTED_CELL_R_DISTNAME}  timeout=90  connection=${connection}
      ${warning}  Run Keyword And Return Status  admin.Assert Alarm Active
      ...  parameters=faultId=1907, severity=Warning
      ...  timeout=${RADIO_STARTUP_DELAY}
      ...  connection=${connection}
      Run Keyword If  '${warning}'=='True'
      ...  Logging With Timestamp
      ...  message=Fault 1907 with severity warning appeared ! Attempt ${index} succeeded
      ...  ELSE  Run Keyword And Continue On Failure
      ...  Fail  Fault 1907 with severity warning did not appear ! Try to set flag RECOVERY_SITE_RESET to TRUE
      admin.Assert Alarm Inactive
      ...  parameters=faultId=1907, severity=Warning
      ...  timeout=100
      ...  connection=${connection}
      STATE Verify States For One
      ...  class=NRCEL
      ...  object=${TESTED_CELL_R_DISTNAME}
      ...  node_id=${connection}
      ...  timeout=${RADIO_STARTUP_DELAY}
      Sleep  300  Delay between fault generating actions
    END

    ${warning_alarm_info}=  admin.Get Alarm History  timeout=60  detailed_output=False  connection=${connection}

    Logging With Timestamp
    ...  message=---Waiting for fault 1907 with severity critical---
    ${fid1907_critical_timestamp}=  Get Current Date  UTC
    radio.Generate Fault  fault_id=1907  ru_serial_number=${ru_sn}
    Sleep  5  Timeout between fault generating actions
    admin.Reset Cell  cell_id=${TESTED_CELL_R_DISTNAME}  timeout=90  connection=${connection}
    ${critical_alarm_info}  Run Keyword And Continue On Failure
    ...  admin.Assert Alarm Active  faultId=1907, severity=Critical
    ...  connection=${connection}  timeout=${RADIO_STARTUP_DELAY}
    Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1907, severity=Critical  connection=${connection}
    ${critical_alarm_status}  Run Keyword And Return Status
    ...  admin.Assert Alarm Active  faultId=1907, severity=Critical
    ...  timeout=30  connection=${connection}
    Run Keyword If  '${critical_alarm_status}'=='True'
    ...  Logging With Timestamp
    ...  message=Fault 1907 with severity critical appeared !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault 1907 with severity critical did not appear !

    [Return]  ${warning_alarm_info}  ${fid1907_warning_timestamp}  ${critical_alarm_info}  ${fid1907_critical_timestamp}
    [Teardown]  Recover Fault FID1907  ru_sn=${ru_sn}
    ...  ru_dist_name=${ru_dist_name}
    ...  connection=${connection}

Recover Fault FID1907
    [Arguments]  ${ru_sn}  ${ru_dist_name}  ${connection}
    [Documentation]
    ...  KW is recovering radio after fault detection.
    ...
    ...  |  **Author:**      dawid.bak@nokia.com
    ...  |  **Maintainer:**  dawid.bak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+--------------------------------------------------+
    ...  | Parameter    | Man. | Description                                      |
    ...  +==============+======+==================================================+
    ...  | ru_sn        | Yes  | serial number of radio unit under test           |
    ...  +--------------+------+--------------------------------------------------+
    ...  | ru_dist_name | Yes  | radio runtime distname                           |
    ...  +--------------+------+--------------------------------------------------+
    ...  | connection   | Yes  | aliast to BTS, BTS_ID                            |
    ...  +--------------+------+--------------------------------------------------+

    Logging With Timestamp
    ...  message=-----Recovering Fault 1907 on RMOD-----
    radio.Recover Fault  ru_serial_number=${ru_sn}  fault_id=1907
    Logging With Timestamp
    ...  message=Waiting for RMOD status disabled...
    Run Keyword And Ignore Error  admin.Assert  class_name=RMOD
    ...  id=${ru_dist_name}
    ...  operationalState=regex"(?i)disabled"
    ...  timeout=300
    ...  connection=${connection}
    Logging With Timestamp
    ...  message=Waiting for RMOD status enabled...
    Run Keyword And Ignore Error  admin.Assert  class_name=RMOD
    ...  id=${ru_dist_name}
    ...  operationalState=regex"(?i)enabled"
    ...  timeout=${RADIO_STARTUP_DELAY}
    ...  connection=${connection}
    Run Keyword And Ignore Error  STATE Verify Multi Node State  scf_check=${FALSE}  timeout=400

Perform TargetTotalLoad Recommissioning
  [Arguments]  ${bts_id}  ${value}  ${ru_sn}
  [Documentation]  KW for recommissioning parameter TargetTotalLoad. Parameter with valuue=100 allows proper 1907 fault activation.
  ...
  ...  **Input Parameters:**
  ...
  ...  +--------------+------+--------------------------------------------------+
  ...  | Parameter    | Man. | Description                                      |
  ...  +==============+======+==================================================+
  ...  | bts_id       | Yes  | ID of tested BTS                                 |
  ...  +--------------+------+--------------------------------------------------+
  ...  | value        | Yes  | parameter value to update                        |
  ...  +--------------+------+--------------------------------------------------+
  ...  | ru_sn        | Yes  | serial number of radio unit under test           |
  ...  +--------------+------+--------------------------------------------------+

  ${status}  ${msg}=  Run Keyword And Ignore Error  admin.Perform Parameter Recommissioning
  ...  dist_name=${CFG['NODES']['${bts_id}']['NRCEL']['${4_4_NRCELL_ID_DICT['${ru_sn}']}']['scf_dist_name']}
  ...  parameter=targetTotalLoad
  ...  operation=update
  ...  value=${value}
  ...  connection=${bts_id}
  IF  "${status}"=="PASS"  Logging With Timestamp
  ...  message=Parameter successfuly set targetTotalLoad=${value} on NRCELL-${4_4_NRCELL_ID_DICT['${ru_sn}']}
  ...  ELSE
  ...  Logging With Timestamp
  ...  message=Parameter targetTotalLoad=${value} recommissioning failed on NRCELL-${4_4_NRCELL_ID_DICT['${ru_sn}']}.
  ...  message_2=Recomissioning output: ${\n}${msg}

Get TargetTotalLoad Initial Value
    [Arguments]  ${bts_id}  ${ru_sn}
    [Documentation]  KW for saving parameter initial value
  ...
  ...  **Input Parameters:**
  ...
  ...  +--------------+------+--------------------------------------------------+
  ...  | Parameter    | Man. | Description                                      |
  ...  +==============+======+==================================================+
  ...  | bts_id       | Yes  | ID of tested BTS                                 |
  ...  +--------------+------+--------------------------------------------------+
  ...  | ru_sn        | Yes  | serial number of radio unit under test           |
  ...  +--------------+------+--------------------------------------------------+
    ${parameters}=  Create List  targetTotalLoad
    ${param_output}=  admin.Get Parameter By Distname
    ...  dist_name=${CFG['NODES']['${bts_id}']['NRCEL']['${4_4_NRCELL_ID_DICT['${ru_sn}']}']['scf_dist_name']}
    ...  parameter_list=${parameters}
    ...  connection=${bts_id}
    ${initial_status}=  Run Keyword And Return Status  Variable Should Exist  ${param_output[0]['parameters']['targetTotalLoad']}
    ${INITIAL_PARAMETER}=  Set Variable If  ${initial_status}  ${param_output[0]['parameters']['targetTotalLoad']}  0
    Set Test Variable  ${INITIAL_PARAMETER}


