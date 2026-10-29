*** Settings ***
Documentation
  ...  AUTHOR-kamil.adamowski@nokia.com  MAINTAINER-kamil.adamowski@nokia.com
  ...
  ...  https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-26184
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  Purpose of this test case is to verify enabling energy optimized mode for Pandion RRH via WebEM
  ...  according to CB014375 feature. (Radio Power consumption reduction target up to 10% with this feature.
  ...  Currently the PAR Peak to Average Ratio is defined as 7.4dB or 7.6dB.
  ...  PAR Peak to Average Ratio after activating this feature will be 6.8 dB.
  ...  Feature is independent of the pMAX configuration.
  ...  No target requirements for throughput degradation in this feature
  ...  as changing PAR can have impact to throughput degradation
  ...  and based on the feedback from RF A&S either PAR lowered, and power consumption improved,
  ...  or higher PAR and better EVM & Throughput.
  ...  Target BTS: Classical SBTS, Could RAN (5G only)
  ...
  ...  Feature is limited to AHPMDG & AHEGHA unit,CPRI only

  ...  Step 1: Preconditions
  ...  Checking if the given radio is visible
  ...  Verifying information of the radio
  ...  Checking if the given cell is visible
  ...
  ...  Step 2: L3 call
  ...  SiSo L3 call to check if data transfer is possible and measured
  ...
  ...  Step 3: Check power consumption on the radio
  ...  Get Real-Time Measurement Power consumption of the radio
  ...
  ...  Step 4 Enable Energy_Optimized_mode
  ...  Checking if all cells are onAir after enable feature
  ...
  ...  Step 5: L3_call_with feature
  ...  SiSo L3 call to check if data transfer is possible and measured
  ...
  ...  Step 6: Check Energy_Optimized_mode
  ...  Get Real-Time Measurement Power consumption of the radio
  ...  Compare power consumption with and without feature
  ...
  ...  Step 7: Disable Energy_Optimized_mode
  ...  Recommissioning to disable feature
  ...  Checking if all cells are onAir.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 04.09.2025 - Initial creation
  ...  - 25.09.2025 - Send to check


Resource  ./../../Resources/Setup/setup_and_teardown.robot


*** Variables ***
${RMOD_SN}                    # Serial number of the radio
${SELECTED_CELLS}  None       # nrCellIdentity, eutranCellId, cellId or gsmSectorID for L3 Call, will be modified to distname in preconditions
${CELLS_YAML_PATH}            #Path to the file with information about cells
${CHECK_POWER_EE}  False      #Parameter to enable checking power consumption with/without enabled feature

*** Keywords ***
TC__PM_Energy_Optimized_mode_for_Pandion_RRH
    Set Tags  AUTHOR-kamil.adamowski@nokia.com  MAINTAINER-kamil.adamowski@nokia.com
    Common Test Setup
    ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
    Logging With Timestamp
    ...  message=Test for feature CB014375 will be executed
    ...  style=ONGOING
    Step 1 Precondition For CB014375  ${bts_id}
    Step 2 L3_call Without Feature  ${bts_id}
    Step 3 Check Power Consumption On The Radio  ${bts_id}
    Step 4 Enable Energy Optimized Mode   ${bts_id}
    Step 5 L3_call With Feature
    Step 6 Check Power Consumption With Energy Optimized  ${bts_id}
    Step 7 Disable Energy Optimized Mode  ${bts_id}
    [Teardown]  Common Test Teardown

Step 1 Precondition For CB014375
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1: Precondition For feature CB014375
    ...  style=STEP
    ...  frame=${TRUE}

    IF  '${RMOD_SN}'=='${EMPTY}'
      Logging With Timestamp
      ...  message=Variable RMOD_SN cannot be empty !
      ...  style=ERROR
      Fail  Variable RMOD_SN cannot be empty !
    END

    ${rmods_info}  admin.Get Frm  timeout=60  connection=${bts_id}
    FOR  ${rmod}  IN  @{rmods_info}
      Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SN}'
      IF  '${rmod['productName']}'=='AHPMDG' or '${rmod['productName']}'=='AHEGHA'
        Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['internal']}
        Set Test Variable  ${RMOD_CONFIG_DISTNAME}  ${rmod['id']['configuration']}
        ${runtime_id}  Evaluate  '${rmod['id']['internal']}'.split("/")[-1]
        Set Test Variable  ${RMOD_RUNTIME_ID}  ${runtime_id}
      END
    END

    IF  '${RMOD_DISTNAME_ID}'=='${NONE}'
      Logging With Timestamp
      ...  message=Serial Number of the radio AHPMDG/AHEGHA not found in HW Configuration ! Test set to Fail !
      ...  style=ERROR
      Fail  Serial Number of the radio AHPMDG/AHEGHA ${RMOD_SN} not found in HW Configuration ! Test set to Fail !
    ELSE
      Logging With Timestamp
      ...  message=RMOD AHPMDG/AHEGHA with SN ${RMOD_SN} found in configuration!
      ...  style=DONE
    END

    Logging With Timestamp
    ...  message=Checking cells status...
    ...  style=ONGOING

    ${status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${status}'=='False'
      Logging With Timestamp
      ...  message=Cells are not onAir! Set test failed !
      ...  style=ERROR
      Fail  Cells are not onAir! Set test failed!
    ELSE
      Logging With Timestamp
      ...  message=All cells are onAir !
      ...  style=DONE
    END

    Logging With Timestamp
    ...  message=Checking Max Energy Efficiency status on the radio...
    ...  style=ONGOING

    ${reference_parameter}  admin.Get Parameters  ${RMOD_DISTNAME_ID}  parConfigurationModeState  connection=${bts_id}
    Set Test Variable  ${reference_parameter}

    IF  '${reference_parameter['parConfigurationModeState']}'=='Enabled'
      Logging With Timestamp
      ...  message=actParConfigurationMode is set to MaxEnergyEfficiency, setting to StandardMode before TC run !
      ...  style=ERROR
      Logging With Timestamp
      ...  message=Blocking radio to activate feature, please wait!
      ...  style=ONGOING
      Wait Until Keyword Succeeds  600 sec  20 sec  admin.Lock  dist_name=${RMOD_CONFIG_DISTNAME}  timeout=300  connection=${bts_id}
      Logging With Timestamp
      ...  message=Radio blocked!
      ...  style=DONE

      Logging With Timestamp
      ...  message=Recommissioning of the parameter actParConfigurationMode
      ...  style=ONGOING
      Wait Until Keyword Succeeds  600 sec  20 sec  admin.Perform Parameter Recommissioning
      ...  dist_name=${RMOD_CONFIG_DISTNAME}
      ...  parameter=actParConfigurationMode
      ...  operation=update
      ...  value=StandardMode
      ...  connection=${bts_id}

      Logging With Timestamp
      ...  message=Unblocking radio to activate feature, please wait!
      ...  style=ONGOING
      Wait Until Keyword Succeeds  600 sec  20 sec  admin.Unlock  dist_name=${RMOD_CONFIG_DISTNAME}  timeout=300  connection=${bts_id}
      Logging With Timestamp
      ...  message=Radio unblocked
      ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=actParConfigurationMode is set to StandardMode, no need to change !
        ...  style=DONE
    END

Step 2 L3_call Without Feature
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2: SiSo L3 call to check if data transfer is possible and measured.
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Get cell(s) info for L3 call procedure
    SiSo Convert Id to Runtime Distname  connection=${bts_id}
    Set Test Variable  ${LOGS_DIR}  ${CFG.test_logs_path}/TestFiles
    SiSo L3 Call

Step 3 Check Power Consumption On The Radio
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 3: Check power consumption on the radio without feature
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Get Real-Time Measurement Power consumption of the radio
    ...  style=ONGOING

    ${rmods_measurements_without}  admin.get_measurements  measurement_type=realTime  connection=${bts_id}

    FOR  ${rmod_real_time}  IN  @{rmods_measurements_without}
      ${rmod_id}  Evaluate  list(${rmod_real_time})[0].split("/")[-1]
      IF  '${rmod_id}' == '${RMOD_RUNTIME_ID}'
        ${key}  Evaluate  list(${rmod_real_time})[0]
        ${RMOD_POWER_WITHOUT}  Evaluate  ${rmod_real_time}[${key}][power]
        Set Test Variable  ${RMOD_POWER_WITHOUT}
      END
    END

    Logging With Timestamp
    ...  message=Power consumption of the radio is ${RMOD_POWER_WITHOUT}
    ...  style=DONE

Step 4 Enable Energy Optimized Mode
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 4: Enable Energy Optimized Mode
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Blocking radio to activate feature, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  600 sec  20 sec  admin.Lock  dist_name=${RMOD_CONFIG_DISTNAME}  timeout=300  connection=${bts_id}
    Logging With Timestamp
    ...  message=Radio blocked!
    ...  style=DONE

    Logging With Timestamp
    ...  message=Perform recommissioning, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  600 sec  20 sec  admin.Perform Parameter Recommissioning
    ...  dist_name=${RMOD_CONFIG_DISTNAME}
    ...  parameter=actParConfigurationMode
    ...  operation=update
    ...  value=MaxEnergyEfficiency
    ...  connection=${bts_id}
    Logging With Timestamp
    ...  message=Perform recommissioning done, set: actParConfigurationMode -> MaxEnergyEfficiency
    ...  style=DONE

    Logging With Timestamp
    ...  message=Unblocking radio to activate feature, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  600 sec  20 sec  admin.Unlock  dist_name=${RMOD_CONFIG_DISTNAME}  timeout=300  connection=${bts_id}
    Logging With Timestamp
    ...  message=Radio unblocked
    ...  style=DONE

    Logging With Timestamp
    ...  message=Sleep to enabling cells after unblock and checking cells status...
    ...  style=ONGOING

    Sleep  120s

    Logging With Timestamp
    ...  message=Checking cells status...
    ...  style=ONGOING

    ${status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${status}'=='False'
      Logging With Timestamp
      ...  message=Cells are not onAir! Set test failed !
      ...  style=ERROR
      Wait Until Keyword Succeeds  600 sec  20 sec  admin.Perform Parameter Recommissioning
      ...  dist_name=${RMOD_CONFIG_DISTNAME}
      ...  parameter=actParConfigurationMode
      ...  operation=update
      ...  value=StandardMode
      ...  connection=${bts_id}
      Fail  Cells are not onAir! Set test failed!
    ELSE
      Logging With Timestamp
      ...  message=All cells are onAir !
      ...  style=DONE
    END

Step 5 L3_call With Feature
    Logging With Timestamp
    ...  message=Step 5: SiSo L3 call to check if data transfer is possible and measured.
    ...  style=STEP
    ...  frame=${TRUE}

    SiSo L3 Call

    Logging With Timestamp
    ...  message=Changed PAR can have impact to throughput degradation!
    ...  style=DONE
    ...  frame=${TRUE}

Step 6 Check Power Consumption With Energy Optimized
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 6: Check Power Consumption With Energy Optimized enabling
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Radio Power consumption reduction target up to 10% with this feature
    ...  style=DONE
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Get Real-Time Measurement Power consumption of the radio
    ...  style=ONGOING

    ${rmods_measurements_with}  admin.get_measurements  measurement_type=realTime  connection=${bts_id}
    FOR  ${rmod_real_time}  IN  @{rmods_measurements_with}
      ${rmod_id}  Evaluate  list(${rmod_real_time})[0].split("/")[-1]
      IF  '${rmod_id}' == '${RMOD_RUNTIME_ID}'
        ${key}  Evaluate  list(${rmod_real_time})[0]
        ${RMOD_POWER_WITH}  Evaluate  ${rmod_real_time}[${key}][power]
        Set Test Variable  ${RMOD_POWER_WITH}
      END
    END

    Logging With Timestamp
    ...  message=Power consumption of the radio with feature is ${RMOD_POWER_WITH} watts
    ...  style=DONE
    Logging With Timestamp
    ...  message=Power consumption of the radio without feature is ${RMOD_POWER_WITHOUT} watts
    ...  style=DONE

    IF  '${CHECK_POWER_EE}'=='True' and ${RMOD_POWER_WITH}>=${RMOD_POWER_WITHOUT}
      Logging With Timestamp
      ...  message=Power consumption with feature is bigger or the same.
      ...  style=ERROR
      Wait Until Keyword Succeeds  600 sec  20 sec  admin.Perform Parameter Recommissioning
      ...  dist_name=${RMOD_CONFIG_DISTNAME}
      ...  parameter=actParConfigurationMode
      ...  operation=update
      ...  value=StandardMode
      ...  connection=${bts_id}
      Fail  Power consumption with feature is bigger or the same.
    END

Step 7 Disable Energy Optimized Mode
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 7: Disable Energy Optimized Mode
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Blocking radio to deactivate feature, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  600 sec  20 sec  admin.Lock  dist_name=${RMOD_CONFIG_DISTNAME}  timeout=300  connection=${bts_id}
    Logging With Timestamp
    ...  message=Radio blocked!
    ...  style=DONE

    Logging With Timestamp
    ...  message=Perform recommissioning, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  600 sec  20 sec  admin.Perform Parameter Recommissioning
    ...  dist_name=${RMOD_CONFIG_DISTNAME}
    ...  parameter=actParConfigurationMode
    ...  operation=update
    ...  value=StandardMode
    ...  connection=${bts_id}
    Logging With Timestamp
    ...  message=Perform recommissioning done, set: actParConfigurationMode -> StandardMode
    ...  style=DONE

    Logging With Timestamp
    ...  message=Unblocking radio to deactivate feature, please wait!
    ...  style=ONGOING
    Wait Until Keyword Succeeds  600 sec  20 sec  admin.Unlock  dist_name=${RMOD_CONFIG_DISTNAME}  timeout=300  connection=${bts_id}
    Logging With Timestamp
    ...  message=Radio unblocked
    ...  style=DONE

    Logging With Timestamp
    ...  message=Sleep to enabling cells after unblock and checking cells status...
    ...  style=ONGOING

    Sleep  120s

    Logging With Timestamp
    ...  message=Checking cells status...
    ...  style=ONGOING

    ${status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${status}'=='False'
      Logging With Timestamp
      ...  message=Cells are not onAir! Set test failed !
      ...  style=ERROR
      Fail  Cells are not onAir! Set test failed!
    ELSE
      Logging With Timestamp
      ...  message=All cells are onAir !
      ...  style=DONE
    END