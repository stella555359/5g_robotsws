*** Settings ***
Documentation
  ...  AUTHOR-kamil.adamowski@nokia.com  MAINTAINER-kamil.adamowski@nokia.com
  ...
  ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-37029
  ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-33601
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  Fault 1937 is generated when validated sensor temperature exceeds or is equal to the predefined value on the unit property file.
  ...  Files in FRMON are decoded to JSONS. (tempest_inst1_default.bin and tcs.bin)
  ...  Temperature of Unit defined in variables.py is read from RU runtime logs.
  ...  Offset is calculated based on Tdanger value in tcs.bin
  ...  Decoded JSON tempest_inst1_default.json is downloaded to SMOD and edited (tempOffset value).
  ...  Edited JSON tempest_inst1_default.json is sent to RMOD and coded to binary file.
  ...  Fault is trigger up to 60s, should be visible in fault_history_log.txt as EFaultId_FrDangerouslyOverheat (1168)
  ...  and in WebEM with Critical severity.
  ...
  ...  TC works with RU families: 5.1*, 6.2*, 8*
  ...
  ...  *RU must be added to dictionaries in radio_variables.py.
  ...
  ...  Step 1: Preconditions
  ...  Checking if the given radio is visible
  ...  Verifying information of the radio
  ...  Checking if the cells and power carriers are Enabled
  ...
  ...  Step 2: Generate FID1937
  ...  Waiting for the FID1937
  ...  Checking if the power carriers are Disabled.
  ...
  ...  Step 3: Recover FID1937
  ...  Waiting for clear of FaultID 1937
  ...  Checking if all cells are onAir.
  ...  Checking if the power carriers are Enabled
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 06.05.2025 - Initial creation
  ...  - 18.07.2025 - Added Sleep before KW "Get RMOD Carriers Power Count"
  ...  - 10.03.2026 - Added AXEGHA RU support - lack of check Power on Carriers


Resource  ./../../Resources/Setup/setup_and_teardown.robot


*** Variables ***
${RMOD_SN}

*** Keywords ***
TC__FM_Temperature_Fault_1937
    Set Tags  AUTHOR-kamil.adamowski@nokia.com  MAINTAINER-kamil.adamowski@nokia.com
    Common Test Setup
    ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
    Logging With Timestamp
    ...  message=FM_Temperature_Fault_1937.robot will be executed
    ...  style=ONGOING
    Step 1 Precondition For Temperature Fault  ${bts_id}
    Step 2 Generate FID 1937  ${bts_id}
    Step 3 Recover FID 1937  ${bts_id}
    [Teardown]  Common Test Teardown

Step 1 Precondition For Temperature Fault
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1: Precondition For Temperature Fault
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
        ${rmod_config_id}  Set Variable  ${rmod['id']['configuration']}
        Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['internal']}
        Set Test Variable  ${RMOD_PRODUCT_NAME}  ${rmod['productName']}
    END

    IF  '${RMOD_DISTNAME_ID}'=='${NONE}'
        Logging With Timestamp
        ...  message=Serial Number of the radio not found in HW Configuration ! Test set to Fail !
        ...  style=ERROR
        Fail  Serial Number ${RMOD_SN} not found in HW Configuration ! Test set to Fail !
    ELSE
        Logging With Timestamp
        ...  message=RMOD with SN ${RMOD_SN} found in configuration!
        ...  style=DONE
    END

    ${bts_params}  admin.Get parameters for all  BTS  connection=${bts_id}

    Logging With Timestamp
    ...  message=Checking cells status...
    ...  style=ONGOING

    ${status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}  timeout=20
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

    IF  '${RMOD_PRODUCT_NAME}'!='AXEGHA'
        Logging With Timestamp
        ...  message=Getting carriers power information...
        ...  style=ONGOING

        ${all_carr}  ${off_carr}  ${wo_carr}  Get RMOD Carriers Power Count  ${RMOD_SN}

        Set Test Variable  ${REF_ALL_CARRIERS_COUNT}  ${all_carr}
        Set Test Variable  ${REF_OFF_CARRIERS_COUNT}  ${off_carr}
        Set Test Variable  ${REF_WORKING_CARRIERS_COUNT}  ${wo_carr}
    END

Step 2 Generate FID 1937
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2: Generate FID 1937
    ...  style=STEP
    ...  frame=${TRUE}

    radio.Generate Fault  fault_id=1937  ru_serial_number=${RMOD_SN}  code_type=Temporary

    Logging With Timestamp
    ...  message=Waiting for raise of FaultID 1937 on WebEM !
    ...  style=ONGOING

    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=1937  timeout=300  severity=Critical  connection=${bts_id}
    IF  '${alarm_status}'=='True'
        Logging With Timestamp
        ...  message=FaultID 1937 RAISED !
        ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=Fault 1937 NOT raised !
        ...  style=ERROR
        radio.Recover Fault  fault_id=1937  ru_serial_number=${RMOD_SN}
        Fail  Fault 1937 NOT raised !
    END

#    Logging With Timestamp  message=Checking FID 1936 in fault_history_log.txt on the radio, please wait !
#
#    ${1167_active}  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File
#    ...  ru_serial_number=${RMOD_SN}
#    ...  fault_id=1167
#    ...  severity=minor
#
#    IF  '${1167_active}'=='True'
#        Logging With Timestamp  message=Found --> Active Minor EFaultId_TemperatureHigh (1167) in fault_history_log_for_fault_1167.txt !
#    ELSE
#        Logging With Timestamp  message=Fault EFaultId_TemperatureHigh (1167) not found, please check fault_history_log_for_fault_1167.txt !
#        radio.Recover Fault  fault_id=1937  ru_serial_number=${RMOD_SN}
#        Fail  Fault EFaultId_TemperatureHigh (1167) not found !
#    END

    Logging With Timestamp
    ...  message=Checking FID 1937 in fault_history_log.txt on the radio, please wait !
    ...  style=ONGOING

    ${1168_active}  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1168
    ...  severity=critical

    IF  '${1168_active}'=='True'
        Logging With Timestamp
        ...  message=Found --> Active Critical EFaultId_FrDangerouslyOverheat (1168) in fault_history_log_for_fault_1168.txt !
        ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=Fault EFaultId_FrDangerouslyOverheat (1168) not found, please check fault_history_log_for_fault_1168.txt !
        ...  style=ERROR
        radio.Recover Fault  fault_id=1937  ru_serial_number=${RMOD_SN}
        Fail  Fault EFaultId_FrDangerouslyOverheat (1168) not found !
    END

    IF  '${RMOD_PRODUCT_NAME}'!='AXEGHA'
        Logging With Timestamp
        ...  message=Getting carriers power information...
        ...  style=ONGOING
        Sleep  60s

        ${1937_all_carr}  ${1937_off_carr}  ${1937_wo_carr}  Get RMOD Carriers Power Count  ${RMOD_SN}
        ${off_carriers_status}  Run Keyword And Return Status
        ...  Should Be Equal As Integers  ${REF_ALL_CARRIERS_COUNT}  ${1937_off_carr}

        IF  '${off_carriers_status}'=='True'
            Logging With Timestamp
            ...  message=All carriers are OFF as expected !
            ...  style=DONE
        ELSE
            Logging With Timestamp
            ...  message=Not all carriers are OFF when FaultID 1937 !
            ...  style=ERROR
            radio.Recover Fault  fault_id=1937  ru_serial_number=${RMOD_SN}
            Fail  Not all carriers are OFF when FaultID 1937 !
        END
    END

    ${ru_dist_name}=  Get RU Node Data  ${RMOD_SN}
    Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1937  alarmingObjectIds[0].internal=${ru_dist_name}  connection=${bts_id}

Step 3 Recover FID 1937
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 3: Recover FID 1937
    ...  style=STEP
    ...  frame=${TRUE}

    radio.Recover Fault  fault_id=1937  ru_serial_number=${RMOD_SN}

    Logging With Timestamp
    ...  message=Waiting for clear of FaultID 1937 !
    ...  style=ONGOING
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=1937  timeout=300  connection=${bts_id}

    IF  '${alarm_status}'=='True'
        Logging With Timestamp
        ...  message=FaultID 1937 CLEARED !
        ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=Fault 1937 NOT cleared !
        ...  style=ERROR
        radio.Recover Fault  fault_id=1937  ru_serial_number=${RMOD_SN}
        Fail  Fault 1937 NOT cleared !
    END


    Logging With Timestamp
    ...  message=Sleep 120s to enabling cells after cleared the fault...
    ...  style=ONGOING

    Sleep  120s

    Logging With Timestamp
    ...  message=Checking cells status...
    ...  style=ONGOING

    ${status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}  timeout=20
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

#    ${1167_cleared}  Run Keyword And Return Status  radio.Assert Inactive Fault In Fault History Log File
#    ...  ru_serial_number=${RMOD_SN}
#    ...  fault_id=1167
#    ...  severity=minor
#
#    IF  '${1167_cleared}'=='True'
#        Logging With Timestamp
#        ...  message=Found --> Inactive Critical EFaultId_TemperatureHigh (1167) in fault_history_log_for_fault_1167.txt !
#    ELSE
#        Logging With Timestamp
#        ...  message=Inactive fault EFaultId_TemperatureHigh (1167) not found, please check fault_history_log_for_fault_1167.txt !
#        Fail  Inactive fault EFaultId_TemperatureHigh (1167) not found, please check fault_history_log_for_fault_1167.txt !
#    END
#
    ${1168_cleared}  Run Keyword And Return Status  radio.Assert Inactive Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1168
    ...  severity=critical

    IF  '${1168_cleared}'=='True'
        Logging With Timestamp
        ...  message=Found --> Inactive Critical EFaultId_FrDangerouslyOverheat (1168) in fault_history_log_for_fault_1168.txt !
        ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=Inactive fault EFaultId_FrDangerouslyOverheat (1168) not found, please check fault_history_log_for_fault_1168.txt !
        ...  style=ERROR
        Fail  Inactive fault EFaultId_FrDangerouslyOverheat (1168) not found, please check fault_history_log_for_fault_1168.txt !
    END

    IF  '${RMOD_PRODUCT_NAME}'!='AXEGHA'
        Logging With Timestamp
        ...  message=Getting carriers power information...
        ...  style=ONGOING
        Sleep  60s

        ${1937_all_carr}  ${1937_off_carr}  ${1937_wo_carr}  Get RMOD Carriers Power Count  ${RMOD_SN}
        ${carriers_status}  Run Keyword And Return Status
        ...  Should Be Equal As Integers  ${REF_WORKING_CARRIERS_COUNT}  ${1937_wo_carr}

        IF  '${carriers_status}'=='True'
            Logging With Timestamp
            ...  message=All carriers are recovered !
            ...  style=DONE
        ELSE
            Logging With Timestamp
            ...  message=NOT all carriers are recovered ! Set Test Fail !
            ...  style=ERROR
            Fail  NOT all carriers are recovered ! Set Test Fail !
        END
    END

Get RMOD Carriers Power Count
    [Arguments]  ${RMOD_SN}

    ${ref_carriers_dict}  radio.Get Carriers Power  ${RMOD_SN}  direction=Tx
    ${carriers_power_values}  Get Dictionary Values  ${ref_carriers_dict}
    ${power_values_list}  Get Power Values For RU  ${carriers_power_values}

    FOR  ${carrier}  ${power}  IN ZIP  ${ref_carriers_dict.keys()}  ${ref_carriers_dict.values()}
        Log to console  ${carrier} -> ${power}
    END

    ${all_carr_count}  Get Length  ${power_values_list}
    ${off_carr_count}  Get Match Count  ${power_values_list}  OFF
    ${WO_carr_count}  Evaluate  ${all_carr_count}-${off_carr_count}

    [Return]  ${all_carr_count}  ${off_carr_count}  ${WO_carr_count}

Get Power Values For RU
    [Arguments]  ${carriers_power_list}

    ${power_list}  Create List
    FOR  ${carriers}  IN  @{carriers_power_list}
        ${power}  Get Dictionary Values  ${carriers}
        Append To List  ${power_list}  ${power}
    END
    ${power_list}  Evaluate  [x for y in ${power_list} for x in y]

    [Return]  ${power_list}
