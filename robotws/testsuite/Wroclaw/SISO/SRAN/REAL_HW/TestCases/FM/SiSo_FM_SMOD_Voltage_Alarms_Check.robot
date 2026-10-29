*** Settings ***
Documentation
  ...  AUTHOR-malgorzata.piecyk-celuch@nokia.com  MAINTAINER-malgorzata.piecyk-celuch@nokia.com
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  Step 1: Preconditions For Voltage Alarms Check
  ...  Collect and set up SMOD configurations.
  ...  Collect a snapshot and download the blackbox file, as a reference.
  ...  Perform delta recommissioning for voltage thresholds.
  ...  Verify that all cells are on air after recommissioning.
  ...
  ...  Step 2: Set Output Voltage For Alarm 6908 - Voltage Too Low
  ...  Check the correctness of the alarm 6908 when the voltage is too low for low nominal threshold.
  ...  Verify the alarm is raised correctly on the correct SMOD.
  ...  Clear alarm and check if all cells are on air.
  ...  Check the correctness of the alarm 6908 when the voltage is too low for low extend threshold.
  ...  Verify the alarm is raised correctly on the correct SMOD.
  ...  Clear alarm and check if all cells are on air.
  ...  If there is a dual SMOD configuration, repeat the checks for the second SMOD.
  ...
  ...  Step 3: Set Output Voltage For Alarm 6907 - Voltage Too High
  ...  Check the correctness of the alarm 6907 when the voltage is too high for high nominal threshold.
  ...  Verify the alarm is raised correctly on the correct SMOD.
  ...  Clear alarm and check if all cells are on air.
  ...  Check the correctness of the alarm 6907 when the voltage is too low for high extend threshold.
  ...  Verify the alarm is raised correctly on the correct SMOD.
  ...  Clear alarm and check if all cells are on air.
  ...  If there is a dual SMOD configuration, repeat the checks for the second SMOD.
  ...
  ...  Step 4: Verify Blackbox File
  ...  Collect a new snapshot and download the blackbox file to compare with a reference one.
  ...  Verify that the dates in the blackbox file match.
  ...  Check if the flags increment properly in proper ranges.
  ...  Verify that the voltage in the blackbox file is consistent with the SCF.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 07.03.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../Resources/Robot/TDK_Lambda_Controller.robot
Resource  ./../../../resources/common_kw.robot
Library  ./../../Resources/Python/blackbox_helpers.py
Library    SSHLibrary
Library    OperatingSystem

*** Variables ***
${SMOD_SN}                             # SMOD serial number
${VOLT_HIGH_EXTEND_THRESHOLD}   59     # Range is 57.5-60.0, step 0.5
${VOLT_HIGH_NOMINAL_THRESHOLD}  56     # Range is 48.5-57.0, step 0.5
${VOLT_LOW_EXTEND_THRESHOLD}   37      # Range is 36.0-40.0, step 0.5
${VOLT_LOW_NOMINAL_THRESHOLD}  42      # Range is 40.5-47.5, step 0.5
${TOO_HIGH_EXTEND_VOLT}   60           # Value must be higher than ${VOLT_HIGH_EXTEND_THRESHOLD}
${TOO_HIGH_NOMINAL_VOLT}   57          # Value must be higher than ${VOLT_HIGH_NOMINAL_THRESHOLD}
${TOO_LOW_NOMINAL_VOLT}   41           # Value must be lower than ${VOLT_LOW_NOMINAL_THRESHOLD}
${TOO_LOW_EXTEND_VOLT}   36            # Value must be lower than ${VOLT_LOW_EXTEND_THRESHOLD}
${NOMINAL_VOLT}   48                   # Nominal voltage value
${LAMBDA_IP_1}                         # IP of the first TDK Lambda Controller
${SMOD_CONFIGURATION_1}                # SMOD configuration eg. SMOD-1
${LAMBDA_PORT_1}                       # Telnet port of the first TDK Lambda Controller
${LAMBDA_IP_2}                         # IP of the second TDK Lambda Controller (if exists)
${SMOD_CONFIGURATION_2}                # SMOD configuration eg. SMOD-2  (if exists)
${LAMBDA_PORT_2}                       # Telnet port of the second TDK Lambda Controller (if exists)
${node}  default

*** Keywords ***
TC__SiSo_FM_SMOD_Voltage_Alarms_Check
  Set Tags  AUTHOR-malgorzata.piecyk-celuch@nokia.com  MAINTAINER-malgorzata.piecyk-celuch@nokia.com
  Common Test Setup
  ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
  Step 1: Preconditions For Voltage Alarms Check  ${bts_id}
  Step 2: Set Output Voltage For Alarm 6908 - Voltage Too Low  ${bts_id}
  Step 3: Set Output Voltage For Alarm 6907 - Voltage Too High  ${bts_id}
  Step 4: Verify Blackbox File  ${bts_id}
  [Teardown]  Run Keywords
  ...  Set Power Voltage On Lambda  ${NOMINAL_VOLT}
  ...  AND  Telnet.Close All Connections
  ...  AND  Common Test Teardown

Step 1: Preconditions For Voltage Alarms Check
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1: Preconditions For SMOD Voltage Parameters
    ...  style=STEP
    ...  frame=${TRUE}

    ${smods_sn}  Split String  ${SMOD_SN}  ,
    ${smods_info_list}  Create List
    FOR  ${test_smod}  IN  @{smods_sn}
        ${smod_config_id}  Get SMOD Configuration Dist  ${test_smod}  ${bts_id}
        Append To List  ${smods_info_list}  ${smod_config_id}
    END
    Set Test Variable  ${SMODS_INFO_LIST}

    IF   '${CFG.NODES['${bts_id}']['dualcore']}' == 'True'
        Set Test Variable  ${FULLRACK}  ${TRUE}
    ELSE
        Set Test Variable  ${FULLRACK}  ${FALSE}
    END

    Set Test Variable  ${BBOX_PATH}  /ffs/run/logs/lifetimedata
    ${blackbox_all_files_list}  Create List
    Set Test Variable  ${BLACKBOX_ALL_FILES_LIST}
    ${blackbox_files_sm1_list}  Create List
    Set Test Variable  ${BLACKBOX_FILES_SM1_LIST}
    ${blackbox_files_sm2_list}  Create List
    Set Test Variable  ${BLACKBOX_FILES_SM2_LIST}

    Logging With Timestamp  message=Collecting HealthCheck Snapshot for blackbox file update !\n
    admin.Collect Snapshot  ${TEST_LOGS_PATH}/TestFiles/snapshot.zip  coverage=HealthCheck  connection=${bts_id}

    IF  '${FULLRACK}'=='False'
        ssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu
        ssh.Download File  ${BBOX_PATH}/blackbox_input_power_data.txt  ${TEST_LOGS_PATH}/TestFiles/blackbox_input_power_data.txt
        OperatingSystem.Move File  ${TEST_LOGS_PATH}/TestFiles/blackbox_input_power_data.txt
        ...  ${TEST_LOGS_PATH}/TestFiles/ref_blackbox_input_power_data_sm1.txt
        ${ref_file_sm1}  Set Variable  ${TEST_LOGS_PATH}/TestFiles/ref_blackbox_input_power_data_sm1.txt
        Set Test Variable  ${REF_FILE_SM1}  ${ref_file_sm1}
        Append To List  ${BLACKBOX_FILES_SM1_LIST}  ${ref_file_sm1}
        ssh.Disconnect
    ELSE
        ssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu  alias=primary
        ssh.Download File  ${BBOX_PATH}/blackbox_input_power_data.txt  ${TEST_LOGS_PATH}/TestFiles/blackbox_input_power_data.txt
        ...  connection=primary
        OperatingSystem.Move File  ${TEST_LOGS_PATH}/TestFiles/blackbox_input_power_data.txt
        ...  ${TEST_LOGS_PATH}/TestFiles/ref_blackbox_input_power_data_sm1.txt
        ${ref_file_sm1}  Set Variable  ${TEST_LOGS_PATH}/TestFiles/ref_blackbox_input_power_data_sm1.txt
        Set Test Variable  ${REF_FILE_SM1}  ${ref_file_sm1}
        Append To List  ${BLACKBOX_FILES_SM1_LIST}  ${ref_file_sm1}
        Append To List  ${BLACKBOX_ALL_FILES_LIST}  ${blackbox_files_sm1_list}
        ssh.connect to  fct-4a  username=toor4nsn  password=oZPS0POrRieRtu  proxy=primary  alias=secondary
        ssh.Download File  ${BBOX_PATH}/blackbox_input_power_data.txt  ${TEST_LOGS_PATH}/TestFiles/blackbox_input_power_data.txt
        ...  connection=secondary
        OperatingSystem.Move File  ${TEST_LOGS_PATH}/TestFiles/blackbox_input_power_data.txt
        ...  ${TEST_LOGS_PATH}/TestFiles/ref_blackbox_input_power_data_sm2.txt
        ${ref_file_sm2}  Set Variable  ${TEST_LOGS_PATH}/TestFiles/ref_blackbox_input_power_data_sm2.txt
        Set Test Variable  ${REF_FILE_SM2}  ${ref_file_sm2}
        Append To List  ${BLACKBOX_FILES_SM2_LIST}  ${ref_file_sm2}
#        Append To List  ${BLACKBOX_FILES_LIST}  ${blackbox_files_sm2_list}
        ssh.Disconnect  connection=secondary
        ssh.Disconnect  connection=primary
    END

    Logging With Timestamp  message=Delta recommissioning, please wait!
    ...  style=ONGOING
    ${high_nominal_th}  Evaluate  int(${VOLT_HIGH_NOMINAL_THRESHOLD})*10
    ${high_extend_th}  Evaluate  int(${VOLT_HIGH_EXTEND_THRESHOLD})*10
    ${low_nominal_th}  Evaluate  int(${VOLT_LOW_NOMINAL_THRESHOLD})*10
    ${low_extend_th}  Evaluate  int(${VOLT_LOW_EXTEND_THRESHOLD})*10

    FOR  ${smod}  IN  @{SMODS_INFO_LIST}
      Perform Delta Recommissioning for Voltage Thresholds  ${smod_config_id}  high_nominal_th=${high_nominal_th}
      ...  low_nominal_th=${low_nominal_th}  high_extend_th=${high_extend_th}  low_extend_th=${low_extend_th}  bts_id=${bts_id}
    END

    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${onair_status}'=='False'
        Logging With Timestamp  message=Cells are not onAir after recommissioning! Test failed !
        ...  style=ERROR
        Fail  Cells are not onAir after recommissioning!
    ELSE
        Logging With Timestamp  message=All cells are onAir !\n
    END

    Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=6907  connection=${bts_id}
    Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=6908  connection=${bts_id}


Step 2: Set Output Voltage For Alarm 6908 - Voltage Too Low
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2: Set Output Voltage For Alarm 6908 - Voltage Too Low
    ...  style=STEP
    ...  frame=${TRUE}

    Setup TDK Lambda Controller  ip_address=${LAMBDA_IP_1}  port=${LAMBDA_PORT_1}
    Check The Correctness Of Alarm When The Voltage Change  bts_id=${bts_id}  out_of_volt_threshold=${TOO_LOW_NOMINAL_VOLT}  alarm_id=6908
    ...  SMOD_CONFIGURATION=${SMOD_CONFIGURATION_1}  volt_threshold=${VOLT_LOW_NOMINAL_THRESHOLD}
    Check The Correctness Of Alarm When The Voltage Change  bts_id=${bts_id}  out_of_volt_threshold=${TOO_LOW_EXTEND_VOLT}  alarm_id=6908
    ...  SMOD_CONFIGURATION=${SMOD_CONFIGURATION_1}  volt_threshold=${VOLT_LOW_EXTEND_THRESHOLD}

    IF  '${FULLRACK}'=='${TRUE}'
        Telnet.Close All Connections
        Logging With Timestamp  message=Due to dual SMOD configuration, the second SMOD will be tested
        Setup TDK Lambda Controller  ip_address=${LAMBDA_IP_2}  port=${LAMBDA_PORT_2}
        Set Voltage  ${NOMINAL_VOLT}
        Sleep  3 m
        Check The Correctness Of Alarm When The Voltage Change  bts_id=${bts_id}  out_of_volt_threshold=${TOO_LOW_NOMINAL_VOLT}  alarm_id=6908
        ...  SMOD_CONFIGURATION=${SMOD_CONFIGURATION_2}  volt_threshold=${VOLT_LOW_NOMINAL_THRESHOLD}
        Check The Correctness Of Alarm When The Voltage Change  bts_id=${bts_id}  out_of_volt_threshold=${TOO_LOW_EXTEND_VOLT}  alarm_id=6908
        ...  SMOD_CONFIGURATION=${SMOD_CONFIGURATION_2}  volt_threshold=${VOLT_LOW_EXTEND_THRESHOLD}
        Telnet.Close All Connections
    END


Step 3: Set Output Voltage For Alarm 6907 - Voltage Too High
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 3: Set Parameters For Alarm 6907 - Voltage Too High
    ...  style=STEP
    ...  frame=${TRUE}

    IF  '${FULLRACK}'=='${TRUE}'
        Setup TDK Lambda Controller  ip_address=${LAMBDA_IP_1}  port=${LAMBDA_PORT_1}
    END
    Check The Correctness Of Alarm When The Voltage Change  bts_id=${bts_id}  out_of_volt_threshold=${TOO_HIGH_NOMINAL_VOLT}  alarm_id=6907
    ...  SMOD_CONFIGURATION=${SMOD_CONFIGURATION_1}  volt_threshold=${VOLT_HIGH_NOMINAL_THRESHOLD}
    Check The Correctness Of Alarm When The Voltage Change  bts_id=${bts_id}  out_of_volt_threshold=${TOO_HIGH_EXTEND_VOLT}  alarm_id=6907
    ...  SMOD_CONFIGURATION=${SMOD_CONFIGURATION_1}  volt_threshold=${VOLT_HIGH_EXTEND_THRESHOLD}

    IF  '${FULLRACK}'=='${TRUE}'
        Telnet.Close All Connections
        Logging With Timestamp  message=Due to dual SMOD configuration, the second SMOD will be tested
        Setup TDK Lambda Controller  ip_address=${LAMBDA_IP_2}  port=${LAMBDA_PORT_2}
        Check The Correctness Of Alarm When The Voltage Change  bts_id=${bts_id}  out_of_volt_threshold=${TOO_HIGH_NOMINAL_VOLT}  alarm_id=6907
        ...  SMOD_CONFIGURATION=${SMOD_CONFIGURATION_2}  volt_threshold=${VOLT_HIGH_NOMINAL_THRESHOLD}
        Check The Correctness Of Alarm When The Voltage Change  bts_id=${bts_id}  out_of_volt_threshold=${TOO_HIGH_EXTEND_VOLT}  alarm_id=6907
        ...  SMOD_CONFIGURATION=${SMOD_CONFIGURATION_2}  volt_threshold=${VOLT_HIGH_EXTEND_THRESHOLD}
    END


Step 4: Verify Blackbox File
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 4: Verify Blackbox File
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=Collecting HealthCheck Snapshot for blackbox file update !\n
    admin.Collect Snapshot  ${TEST_LOGS_PATH}/TestFiles/snapshot_new.zip  coverage=HealthCheck  connection=${bts_id}

    IF  '${FULLRACK}'=='False'
        ssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu
        ssh.Download File  ${BBOX_PATH}/blackbox_input_power_data.txt  ${TEST_LOGS_PATH}/TestFiles/blackbox_input_power_data.txt
        OperatingSystem.Move File  ${TEST_LOGS_PATH}/TestFiles/blackbox_input_power_data.txt
        ...  ${TEST_LOGS_PATH}/TestFiles/new_blackbox_input_power_data_sm1.txt
        ${new_file_sm1}  Set Variable  ${TEST_LOGS_PATH}/TestFiles/new_blackbox_input_power_data_sm1.txt
        Append To List  ${BLACKBOX_FILES_SM1_LIST}  ${new_file_sm1}
        Append To List  ${BLACKBOX_ALL_FILES_LIST}  ${BLACKBOX_FILES_SM1_LIST}
        ssh.Disconnect
    ELSE
        ssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu  alias=primary
        ssh.Download File  ${BBOX_PATH}/blackbox_input_power_data.txt  ${TEST_LOGS_PATH}/TestFiles/blackbox_input_power_data.txt
        ...  connection=primary
        OperatingSystem.Move File  ${TEST_LOGS_PATH}/TestFiles/blackbox_input_power_data.txt
        ...  ${TEST_LOGS_PATH}/TestFiles/new_blackbox_input_power_data_sm1.txt
        ${new_file_sm1}  Set Variable  ${TEST_LOGS_PATH}/TestFiles/new_blackbox_input_power_data_sm1.txt
        Append To List  ${BLACKBOX_FILES_SM1_LIST}  ${new_file_sm1}
        Append To List  ${BLACKBOX_ALL_FILES_LIST}  ${BLACKBOX_FILES_SM1_LIST}
        ssh.connect to  fct-4a  username=toor4nsn  password=oZPS0POrRieRtu  proxy=primary  alias=secondary
        ssh.Download File  ${BBOX_PATH}/blackbox_input_power_data.txt  ${TEST_LOGS_PATH}/TestFiles/blackbox_input_power_data.txt
        ...  connection=secondary
        OperatingSystem.Move File  ${TEST_LOGS_PATH}/TestFiles/blackbox_input_power_data.txt
        ...  ${TEST_LOGS_PATH}/TestFiles/new_blackbox_input_power_data_sm2.txt
        ${new_file_sm2}  Set Variable  ${TEST_LOGS_PATH}/TestFiles/new_blackbox_input_power_data_sm2.txt
        Append To List  ${BLACKBOX_FILES_SM2_LIST}  ${new_file_sm2}
        Append To List  ${BLACKBOX_ALL_FILES_LIST}  ${BLACKBOX_FILES_SM2_LIST}
        ssh.Disconnect  connection=secondary
        ssh.Disconnect  connection=primary
    END

    Log List  ${BLACKBOX_ALL_FILES_LIST}

      Logging With Timestamp  message=Checking blackbox file for SMOD: SMOD-1
      Compare Blackbox Files    ${REF_FILE_SM1}  ${new_file_sm1}
      IF  '${FULLRACK}'=='True'
        Logging With Timestamp  message=Due to dual SMOD configuration, the second SMOD bbox will be tested
        Compare Blackbox Files    ${REF_FILE_SM2}  ${new_file_sm2}
      END


Compare Blackbox Files
    [Arguments]  ${blackbox_path_ref}  ${blackbox_path_new}
    Logging With Timestamp  message=Check the dates match in blackbox file
    ${verify_blackbox}  Extract New Rows  ${blackbox_path_ref}  ${blackbox_path_new}  spliter=DATE | THRESHOLDS
    Log  ${verify_blackbox}
    ${bbox_date_match}  ${message}  Verify Dates In File  ${verify_blackbox}
    IF  ${bbox_date_match}==False
        Logging With Timestamp  message=\nThe dates in blackbox file does not match today's date: ${message}
        ...  style=ERROR
        Fail  Dates in blackbox file are incorrect: ${message}
    ELSE
        Logging With Timestamp  message=\nThe dates in blackbox file match today's date: ${message}
        ...  style=PASS
    END

    Logging With Timestamp  message=Check if flags increment properly
    ${flags_correctness}  ${message}  Check Flags Incrementation  ${verify_blackbox}  ${TOO_HIGH_EXTEND_VOLT}  ${TOO_HIGH_NOMINAL_VOLT}
    ...  ${TOO_LOW_NOMINAL_VOLT}  ${TOO_LOW_EXTEND_VOLT}
    IF  ${flags_correctness}==False
        Logging With Timestamp  message=\nFlags in blackbox file are not increment properly: ${message}
        ...  style=ERROR
        Fail  Flags in blackbox file are incorrect: ${message}
    ELSE
        Logging With Timestamp  message=\nFlags in blackbox file increment properly: ${message}
        ...  style=PASS
    END
    Logging With Timestamp  message=\nCheck the voltage in the blackbox is equal to the voltage in the SCF
    ${consistent_voltage}  ${message}  Verify Voltage In Blackbox File  ${blackbox_path_new}  ${VOLT_LOW_EXTEND_THRESHOLD}
    ...  ${VOLT_LOW_NOMINAL_THRESHOLD}  ${VOLT_HIGH_NOMINAL_THRESHOLD}  ${VOLT_HIGH_EXTEND_THRESHOLD}
    IF  ${consistent_voltage}==False
        Logging With Timestamp  message=\nVoltage in blackbox is incorrect: ${message}
        ...  style=ERROR
        Fail  Values in blackbox file are incorrect: ${message}
    ELSE
        Logging With Timestamp  message=\nVoltage in blackbox is correct: ${message}
        ...  style=PASS
    END


Perform Delta Recommissioning For Voltage Thresholds
    [Arguments]  ${smod_config_id}  ${high_nominal_th}  ${high_extend_th}  ${low_nominal_th}  ${low_extend_th}  ${bts_id}

    admin.Create Delta
    admin.Append Parameter Update To Delta  ${smod_config_id}  alVoltHighNominalThreshold  ${high_nominal_th}
    admin.Append Parameter Update To Delta  ${smod_config_id}  alVoltHighExtendThreshold  ${high_extend_th}
    admin.Append Parameter Update To Delta  ${smod_config_id}  alVoltLowNominalThreshold  ${low_nominal_th}
    admin.Append Parameter Update To Delta  ${smod_config_id}  alVoltLowExtendThreshold  ${low_extend_th}

    ${delta}  admin.Get Delta
    admin.Perform Delta Recommissioning  ${delta}  skip_parameter_relation_errors=True  connection=${bts_id}
    admin.Remove Delta

    Logging With Timestamp  message=Delta recommissioning done
    ...  style=PASS

Check The Correctness Of Alarm When The Voltage Change
    [Arguments]  ${bts_id}  ${out_of_volt_threshold}  ${alarm_id}  ${SMOD_CONFIGURATION}  ${volt_threshold}

    Set Voltage  ${out_of_volt_threshold}
    Logging With Timestamp  message=Waiting for raise of FaultID ${alarm_id}!
    ...  style=ONGOING
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=${alarm_id}  timeout=300  connection=${bts_id}
    IF  '${alarm_status}'=='True'
        Logging With Timestamp  message=FaultID ${alarm_id} RAISED !
        ${alarm_position}  ${additional_voltage_info}  Get Alarm Position And Additional Voltage Info  alarm_id=${alarm_id}  bts_id=${bts_id}
        ${check_smod_config}  Run Keyword And Return Status  Should Be Equal  ${alarm_position}  ${SMOD_CONFIGURATION}
        IF  '${check_smod_config}'=='False'
            Logging With Timestamp  message=Fault ${alarm_id} raised on wrong SMOD ! Voltage restoring to ${NOMINAL_VOLT} Volt !
            ...  style=ERROR
            Set Power Voltage On Lambda  ${NOMINAL_VOLT}
            Fail  Fault ${alarm_id} raised on wrong SMOD !
        END
        ${consistent_voltage}  Run Keyword And Return Status  Should Contain  ${additional_voltage_info}  ${volt_threshold}
        IF  '${consistent_voltage}'=='False'
            Logging With Timestamp  message=Additional voltage information does not match to set voltage on Lambda !
            ...  style=ERROR
            Set Power Voltage On Lambda  ${NOMINAL_VOLT}
            Fail  Fault ${alarm_id} raised on wrong SMOD !
        END
    ELSE
        Logging With Timestamp
        ...  message=Fault ${alarm_id} NOT raised ! Voltage restoring to ${NOMINAL_VOLT} Volt !
        Set Power Voltage On Lambda  ${NOMINAL_VOLT}
        Fail  Fault ${alarm_id} NOT raised !
    END

    Set Voltage  ${NOMINAL_VOLT}
    Logging With Timestamp  message=Waiting for clear of FaultID ${alarm_id}!
    ...  style=ONGOING
    Check Inactive Alarms  alarm_id=${alarm_id}  bts_id=${bts_id}

    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${onair_status}'=='False'
        Logging With Timestamp  message=Cells are not onAir after recommissioning! Test failed !
        ...  style=ERROR
        Fail  Cells are not onAir after recommissioning!
    ELSE
        Logging With Timestamp  message=All cells are onAir !\n
    END

Check Inactive Alarms
    [Arguments]  ${alarm_id}  ${bts_id}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=${alarm_id}  timeout=330  connection=${bts_id}
    IF  '${alarm_status}'=='True'
        Logging With Timestamp  message=FaultID ${alarm_id} is not visible !\n
    ELSE
        Logging With Timestamp
        ...  message=Fault ${alarm_id} is still visible, but it should not be ! Voltage restoring to ${NOMINAL_VOLT} Volt !
        ...  style=ERROR
        Set Power Voltage On Lambda  ${NOMINAL_VOLT}
        Fail  Fault ${alarm_id} raised, but it should not be !
    END

Set Voltage
    [Arguments]  ${out_of_volt_threshold}
    Set Power Voltage On Lambda  ${out_of_volt_threshold}
    ${voltage}  Get Power Voltage From Lambda
    Logging With Timestamp  message=Actual voltage for SMOD: ${voltage}V

Get SMOD Configuration Dist
    [Arguments]  ${smod_sn}  ${bts_id}
    ${smods_info}  admin.Get FSM Info  60  connection=${bts_id}
    FOR  ${smod}  IN  @{smods_info}
        Continue For Loop If  '${smod['serialNumber']}'!='${SMOD_SN}'
        ${smod_config_id}  Set Variable  ${smod['id']['configuration']}
    END
    [Return]  ${smod_config_id}

Get Alarm Position And Additional Voltage Info
    [Arguments]  ${alarm_id}  ${bts_id}
    ${alarm_info}  admin.Assert Alarm Active  faultId=${alarm_id}  timeout=300  connection=${bts_id}
    FOR  ${alarm}  IN  @{alarm_info}
        ${faultId}  Get From Dictionary  ${alarm}  faultId
        Continue For Loop If  '${faultId}'!='${alarm_id}'
        ${alarm_position}  Set Variable  ${alarm['alarmingObjectIds'][0]['configuration']}
        ${alarm_position}  Evaluate  "${alarm_position}".split("/")[-1]
        ${additional_voltage_info}  Set Variable  ${alarm['alarmText']['alarmAdditionalInfo']['supplAlarmInfo']}
        Logging With Timestamp  message=Fault ${alarm_id} raised on SMOD: ${alarm_position} !\n
    END
    [Return]  ${alarm_position}  ${additional_voltage_info}
