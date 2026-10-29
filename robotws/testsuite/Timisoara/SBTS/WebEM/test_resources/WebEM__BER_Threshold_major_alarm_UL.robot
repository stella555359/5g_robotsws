*** Settings ***
Documentation
    ...  Testcase verifies the functionality of BER major alarm thresholds on CPRI optical ports (Uplink).
    ...  BTS shall retrieve the BER (bit error rate) from all synchronized optical ports on all detected Nokia CPRI RM every 60 seconds
    ...  and calculate the number of bits received and the number of bit errors (LCV) on each optical port over the previous 60.
    ...  First step configures berMinorAlarmThreshold and berMajorAlarmThreshold values under APEQM.
    ...  Second step sets attenuation on each tested channel and verify fault 4476 major and fault 10 critical.
    ...  Test will connect to a variable optical attenuator between BBMOD Rx port and RMOD Tx port and gradually increase the attenuation on channels.
    ...  Test will start by setting initial attenuation to 10,6dB and wait 60 seconds. If no major alarm is generated in WebEM,
    ...  attenuation is gradually increase by 0,2dB and wait another 60 seconds until the faults are triggered.
    ...  To recover services attenuation will be set to 0dB on tested channels and perform site reset.


Library  Telnet  WITH NAME  telnet
Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  600  # Timeout for SBTS to recover
${INITIAL_ATTENUATION}  10.6  # Starting attenuation value for the test in dB
${MAXIMUM_ATTENUATION}  20  # Maximum attenuation value in dB to reach during the test
${ATTENUATION_STEP}  0.2  # Increment step for optical attenuation in dB
${BER_MINOR_THRESHOLD_VALUE}  -13  # Value for APEQM parameter berMinorAlarmThreshold
${BER_MAJOR_THRESHOLD_VALUE}  -12  # Value for APEQM parameter berMajorAlarmThreshold
${ATTENUATOR_IP}  10.255.1.189  # IP address of the optical attenuator
${ATTENUATOR_PORT}  4001  # Port for connecting to the optical attenuator
@{CHANNELS_LIST}  01  02  # List of attenuator channels to be tested


*** Keywords ***
TC__WebEM__BER_Threshold_major_alarm_UL
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-30476
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-30476 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS26

    Step0: Set Ber Threshold Parameters Values
    Step1: Set Attenuation On Channels And Verify Faults


Step0: Set Ber Threshold Parameters Values
    Log  \nStep0: Set BER threshold parameters values.  console=true

    ${apeqm_object}  coam.Get Managed Objects  APEQM_A
    ${initial_minor_threshold}  Convert To String  ${apeqm_object}[0][parameters][berMinorAlarmThreshold]
    ${initial_major_threshold}  Convert To String  ${apeqm_object}[0][parameters][berMajorAlarmThreshold]
    Set Test Variable  ${INITIAL_MINOR_THRESHOLD}
    Set Test Variable  ${INITIAL_MAJOR_THRESHOLD}
    Change Threshold Parameter Under APEQM  berMinorAlarmThreshold  ${BER_MINOR_THRESHOLD_VALUE}
    Change Threshold Parameter Under APEQM  berMajorAlarmThreshold  ${BER_MAJOR_THRESHOLD_VALUE}


Step1: Set Attenuation On Channels And Verify Faults
    Log  \nStep1: Set attenuation on channels and verify faults.  console=true

    FOR  ${channel}  IN  @{CHANNELS_LIST}
        Set Attenuation On Channel And Verify Faults  ${channel}  ${INITIAL_ATTENUATION}  ${MAXIMUM_ATTENUATION}  ${ATTENUATION_STEP}
    END


Change Threshold Parameter Under APEQM
    [Arguments]  ${parameter}  ${value}  ${skip_parameter_relation_errors}=${TRUE}  ${timeout}=120

    Log  APEQM Parameter ${parameter} will be changed to ${value}.  console=true
    ${apeqm_object}  coam.Get Managed Objects  APEQM_A
    ${actual_value}  Convert To String  ${apeqm_object}[0][parameters][${parameter}]
    IF  '${actual_value}'=='${value}'
        Log  Parameter already has the requested value. Parameter change will be skipped.  console=true
        RETURN
    END
    Log  Current parameter value ${actual_value}.  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1  parameter=${parameter}  operation=update  value=${value}
    ...  skip_parameter_relation_errors=${skip_parameter_relation_errors}  timeout=${timeout}
    Log  Parameter value changed to ${value}.  console=true


Set Attenuation On Channel And Verify Faults
    [Arguments]  ${channel}  ${ini_attenuation}  ${max_attenuation}  ${increase_step}

    Log  \nSetting attenuation on channel ${channel}.  console=true
    ${attenuation}  Convert To Number  ${ini_attenuation}  2
    ${max_attenuation}  Convert To Number  ${max_attenuation}  2
    ${increase_step}  Convert To Number  ${increase_step}  2
    WHILE  ${attenuation} <= ${max_attenuation}
        Set Attenuation On Channels  ${channel}  ${attenuation}
        ${fault_10_status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  90s  10s
        ...  Check If Given Fault Id And Severity Is In Active Alarms  ${FAULT_10_Critical}[fault_id]  ${FAULT_10_Critical}[severity]
        IF  not ${fault_10_status}
            Log  Fault not present at channel attenation ${attenuation} dB.  console=true
        ELSE
            Log  Fault ${FAULT_10_Critical} active in WebEM.  console=true
            BREAK
        END
        ${fault_4476_status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  60s  10s
        ...  Check If Given Fault Id And Severity Is In Active Alarms  ${FAULT_4476_Major_7116}[fault_id]  ${FAULT_4476_Major_7116}[severity]
        IF  not ${fault_4476_status}
            Log  Fault not present at channel attenation ${attenuation} dB.  console=true
        ELSE
            Log  Fault ${FAULT_4476_Major_7116} active in WebEM.  console=true
        END
        ${attenuation}  Evaluate  ${attenuation}+${increase_step}
        ${attenuation}  Convert To Number  ${attenuation}  2
    END
    IF  ${fault_4476_status} and ${fault_10_status}
        Log  Both faults presents [OK].  console=true
    ELSE
        Fail  Not both faults present at maximum attenuation.
    END
    Set Attenuation On Channels  ${channel}  0
    Go To Site View
    Reset SBTS From Admin
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check Modules And Cells


Set Attenuation On Channels
    [Arguments]  ${channel}  ${attenuation}

    telnet.Open Connection  host=${ATTENUATOR_IP}  port=${ATTENUATOR_PORT}
    IF  ${attenuation}==0
        telnet.Write Bare  <VOA_${channel}_ATT_00.00>\n
    ELSE IF  0<${attenuation}<10
        telnet.Write Bare  <VOA_${channel}_ATT_0${attenuation}0>\n
    ELSE
        telnet.Write Bare  <VOA_${channel}_ATT_${attenuation}0>\n
    END
    telnet.Read Until  >
    telnet.Write Bare  <VOA_${channel}_A_?>\n
    telnet.Read Until  >

    [Teardown]  telnet.Close Connection


Check If Given Fault Id And Severity Is In Active Alarms
    [Arguments]  ${given_fault_id}  ${given_severity}

    Wait Until Element Is Clicked  xpath=${ALARMS_BUTTON_SITE_VIEW}
    Sleep  10s  Time for alarms to appear on page.
    ${alarm_count}  Get Element Count  class:alarm-row
    FOR  ${id}  IN RANGE  1  ${alarm_count}+1
        ${fault_id_text}  Get Text  //*[contains(@alarm-type, 'current')]/ui-table/div/ng-transclude/table/tbody/tr[${id}]/td[5]
        ${current_fault_id}  Convert To Integer  ${fault_id_text}
        ${severity_raw}  SeleniumLibrary.Get Element Attribute  //table[@class='alarm-faults ng-scope']/tbody/tr[${id}]/td[1]/alarm-bell-icon/div
        ...  ui-tooltip
        ${current_severity}  Fetch From Left  ${severity_raw}  ${SPACE}
        IF  ${current_fault_id}==${given_fault_id} and '${current_severity}'=='${given_severity}'
            Log  Fault ${given_fault_id} with severity ${given_severity} is in active alarms.  console=true
            RETURN
        END
    END
    Fail  Fault ${given_fault_id} with severity ${given_severity} not active alarms.


Recovery Action
    FOR  ${channel}  IN  @{CHANNELS_LIST}
        Set Attenuation On Channels  ${channel}  0
    END
    Perform Site Reset


TC Setup
    Common Test Setup  tc_name=WebEM__BER_Threshold_major_alarm_UL
    WebEM Setup


TC Teardown
    Change Threshold Parameter Under APEQM  berMinorAlarmThreshold  ${INITIAL_MINOR_THRESHOLD}
    Change Threshold Parameter Under APEQM  berMajorAlarmThreshold  ${INITIAL_MAJOR_THRESHOLD}
    Run Keyword If Test Failed  Recovery Action
    WebEM Teardown
    Common Test Teardown
