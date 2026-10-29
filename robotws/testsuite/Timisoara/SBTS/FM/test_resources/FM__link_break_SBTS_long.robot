*** Settings ***
Documentation
    ...  This test case was created to imitate whole link break scenario.
    ...  Test will be done by deleting VLANs via CLI on physical switch.
    ...  Switch IP and other parameters are being loaded from robot file.
    ...  Scenario is fitted to commissioned technologies (eg. GSM alarms won't be checked if configuration is LTE-WCDMA only).
    ...  In robot file variables should be added as global parameters (for example):
    ...  @{GSMVlan}            ${261}  ${262}
    ...  ${WCDMAVlan}          ${464}
    ...  ${LTEVlan}            ${461}
    ...  ${Switch_IP}          10.255.6.18
    ...  ${Switch_type}        Nokia_Nuage
    ...  ${INTERFACE_TYPE}     GigabitEthernet
    ...  ${INTERFACE_ID}       5
    ...  ${Switch_USER}        AutoUser
    ...  ${Switch_PASSWORD}    AutoPass123$

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  900
${ALARM_RECOVERY_TIMEOUT}  180
${RECOVERY_TIMEOUT}  600


*** Keywords ***
TC__FM__link_break_SBTS_long
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-7555
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  01.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7555 - Initial TAT creation
    ...  23.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-9832 - Get all [TECHNOLOGY] Tx Power from all RMs needs to be adjusted to work
    ...  with 3+3
    ...  11.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15037 - Replacement of depracated KW "check_if_target_is_available"
    ...  14.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15267 - Removed additional space
    ...  18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  13.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-17047 - Change GSM cell states and alarm severity
    ...  04.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17385  -  Nokia 7210 Switch commands syntax addition
    ...  14.09.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20163 - Include custom restore link connection as failling action in all checks
    ...  throughout the test based on switch type in cofiguration
    ...  20.01.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20724 - Change switch_type name in link breaks scenariors
    ...  03.02.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20823 - Restore link method is incorrect for SBTS link break if testcase is failed
    ...  19.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21210 - New KW for checking 5G cells and another KW for checking 2G,3G,4G cells
    ...  10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  08.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23344 - Remove usage state from check all cell
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26773 - Add new steps to FM__link_break_SBTS_long
    ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  20.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27772 - Add option to skip steps if NR is not configured
    ...  04.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29195 - Add multiple alarms verification
    ...  19.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30445 - Skip RNC verification if it is not commissioned
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-rafal.ozga@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534  FEATURE-RP001145_RP000920  FEATURE-RP001486_RP000920

    Step1: Check All Required States
    Step2: Perform Long Link Break
    Step3: Check Alarms Presence And All States After Link Break
    Step4: Restore Link Connection
    Step5: Check Links State After Links Were Restored And All Cells State


Step1: Check All Required States
    [Documentation]  In this step user input and specific states of links will be checked.

    Log  \nStep1: Check all required states.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}
    Check SA and NSA Or SA+NSA Cells
    Set NTP Ip Adresses
    IF  ${SCF_COUNT_WCDMA}  Set RNC BTS IDs
    IF  ${SCF_COUNT_GSM}  Set BSC BTS IDs
    Change FMCADM parameter  actAlarmOfRatOutage  true
    ${all_rmods_power_before_link_break}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}
    ${all_rmods_power_after_link_break}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}
    ${all_rmods_lte_power_after_link_break}  Create List
    Set Test Variable  ${ALL_RMODS_LTE_POWER_AFTER_LINK_BREAK}
    Check Commissioned Technologies  none
    Check Links Status  Available
    IF  ${SCF_COUNT_NR}  Set variables for x2LinkLock
    ${gncel_ids}  Get Ids For All  GNCEL
    Set Test Variable  ${GNCEL_IDS}


Step2: Perform Long Link Break
    [Documentation]  In this step link break will be performed.

    Log  \nStep2: Perform long link break.  console=true
    Get Used VLANs
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}
    IF  '${SWITCH_TYPE}'=='Nokia_7210' or '${SWITCH_TYPE}'=='Nokia_Nuage'
        Wait Until Keyword Succeeds  5min  1min  Connect To Nokia Serving Switch And Perform Action On Port  ${SWITCH_IP}
        ...                                                                                                  ${SWITCH_USER}
        ...                                                                                                  ${SWITCH_PASSWORD}
        ...                                                                                                  ${INTERFACE_ID}
        ...                                                                                                  shutdown
    ELSE
        Fail  msg=Serving switch is not supported, test will be set as failed.
    END

    ssh.Connect To  ${OAM_BTS_IP}  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}  alias=pc_connection
    ssh.Execute  iptables -I OUTPUT -p sctp --sport 36422 -j DROP  connection=pc_connection
    ssh.Execute  iptables -A OUTPUT -p sctp --dport 38472 -j DROP  connection=pc_connection
    ssh.Execute  ip6tables -A OUTPUT -p sctp --dport 38472 -j DROP  connection=pc_connection
    ssh.Disconnect  connection=pc_connection


Step3: Check Alarms Presence And All States After Link Break
    [Documentation]  In this step alarms presence and states will be check after succesfull link break.

    Log  \nStep3: Check alarms presence and all states after link break.  console=true
    Verify Alarms Presence In WebEM
    Log  LTE TX Power will be printed to check if LTE cells are gracefully shutdown.  console=true
    Get All LTE Tx Power From All RMs  ${ALL_RMODS_LTE_POWER_AFTER_LINK_BREAK}
    ${link_status}  Run Keyword And Return Status  Check Links Status  Unavailable
    IF  ${link_status}
        Log  All link statuses are set correctly after link break. [OK]  console=true
    ELSE
        Fail  Links state are wrong after link break. Link will be restored.
    END
    Check That All Cells Are Disabled  720s


Step4: Restore Link Connection
    [Documentation]  In this step link will be restored.

    Log  \nStep4: Restore link connection.  console=true
    IF  '${SWITCH_TYPE}'=='Nokia_7210' or '${SWITCH_TYPE}'=='Nokia_Nuage'
        Wait Until Keyword Succeeds  5min  1min  Connect To Nokia Serving Switch And Perform Action On Port  ${SWITCH_IP}
        ...                                                                                                  ${SWITCH_USER}
        ...                                                                                                  ${SWITCH_PASSWORD}
        ...                                                                                                  ${INTERFACE_ID}
        ...                                                                                                  no shutdown
    ELSE
        Fail  msg=Serving switch is not supported, test will be set as failed.
    END

    ssh.Connect To  ${OAM_BTS_IP}  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}  alias=pc_connection
    ssh.Execute  iptables -D OUTPUT -p sctp --sport 36422 -j DROP   connection=pc_connection
    ssh.Execute  iptables -t filter -F OUTPUT  connection=pc_connection
    ssh.Execute  ip6tables -t filter -F OUTPUT  connection=pc_connection
    ssh.Disconnect  connection=pc_connection


Step5: Check Links State After Links Were Restored And All Cells State
    [Documentation]  In this step links state and cells state will be checked after link has been restored.

    Log  \nStep5: Check links state after links were restored and all cells state.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells
    Check Links Status  Available
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}
    Compare TXs  ${ALL_RMODS_POWER_AFTER_LINK_BREAK}  ${ALL_RMODS_POWER_BEFORE_LINK_BREAK}
    Admin Check Active Alarms TAF
    Check That Alarms From Netact Are Cleared
    Perform Site Reset


Set Variables For x2LinkLock
    ${sctpWaitTimeInitSeqRetryX2_ini}  Get sctpWaitTimeInitSeqRetryX2 Value  sctpWaitTimeInitSeqRetryX2
    Set Test Variable  ${sctpWaitTimeInitSeqRetryX2_ini}
    ${nrbts_id}  Get Id For Current  NRBTS
    ${nrbts_id}  Fetch From Right  ${nrbts_id}  -
    Set Test Variable  ${NRBTS_ID}
    ${LTEENB_INDEX_LIST}  Create List
    ${lteenb_object}  coam.Get Managed Objects  LTEENB_A  timeout=30
    FOR  ${element}  IN  @{lteenb_object}
         ${index}  Fetch From Right  ${element}[distName]  LTEENB_A-
         Append To List  ${LTEENB_INDEX_LIST}  ${index}
    END
    Set Test Variable  ${LTEENB_INDEX_LIST}


Verify Alarms Presence In WebEM
    IF  (${SA_EXISTS} and ${NSA_EXISTS}) or ${SA_NSA_EXISTS}
        FOR  ${lteenb}  IN  @{LTEENB_INDEX_LIST}
             ${fid_7308_params}  Get String With Alarm Parameters  ${FAULT_7308}
             ${fid_7308_params}  Catenate  SEPARATOR=,${SPACE}  ${fid_7308_params}
             ...                                                alarmingResource="MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/LTEENB-${lteenb}"
             Assert Alarm Active  parameters=${fid_7308_params}  timeout=${ALARM_TIMEOUT}
             Log  Fault ${FAULT_7308} is active in WebEM.  console=true
        END

        ${fid_7107_params}  Get String With Alarm Parameters  ${FAULT_7107_MAJOR}
        Assert Alarm Active  parameters=${fid_7107_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_7107_MAJOR} is active in WebEM.  console=true

        ${fid_7304_params}  Get String With Alarm Parameters  ${FAULT_7304}
        Assert Alarm Active  parameters=${fid_7304_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_7304} is active in WebEM.  console=true

        ${fid_7504_params}  Get String With Alarm Parameters  ${FAULT_7504}
        Assert Alarm Active  parameters=${fid_7504_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_7504} is active in WebEM.  console=true

        ${fid_7303_params}  Get String With Alarm Parameters  ${FAULT_7303}
        Assert Alarm Active  parameters=${fid_7303_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_7303} is active in WebEM.  console=true

        ${fid_7505_params}  Get String With Alarm Parameters  ${FAULT_7505_ALARM_7107}
        Assert Alarm Active  parameters=${fid_7505_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_7505_ALARM_7107} is active in WebEM.  console=true

        ${fid_7305_params}  Get String With Alarm Parameters  ${FAULT_7305}
        Assert Alarm Active  parameters=${fid_7305_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_7305} is active in WebEM.  console=true

    ELSE IF  ${NSA_EXISTS}
        FOR  ${lteenb}  IN  @{LTEENB_INDEX_LIST}
             ${fid_7308_params}  Get String With Alarm Parameters  ${FAULT_7308}
             ${fid_7308_params}  Catenate  SEPARATOR=,${SPACE}  ${fid_7308_params}
             ...                                                alarmingResource="MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/LTEENB-${lteenb}"
             Assert Alarm Active  parameters=${fid_7308_params}  timeout=${ALARM_TIMEOUT}
             Log  Fault ${FAULT_7308} is active in WebEM.  console=true
        END

        ${fid_7107_params}  Get String With Alarm Parameters  ${FAULT_7107_MAJOR}
        Assert Alarm Active  parameters=${fid_7107_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_7107_MAJOR} is active in WebEM.  console=true
    END

    IF  ${SCF_COUNT_GSM}
        ${fid_2412_params}  Get String With Alarm Parameters  ${FAULT_2412_MINOR}
        Assert Alarm Active  parameters=${fid_2412_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_2412_MINOR} is active in WebEM.  console=true

        FOR  ${gncel}  IN  @{GNCEL_IDS}
             ${fid_2401_params}  Get String With Alarm Parameters  ${FAULT_2401}
             ${fid_2401_params}  Catenate  SEPARATOR=,${SPACE}  ${fid_2401_params}  alarmingResource="${gncel}"
             Assert Alarm Active  parameters=${fid_2401_params}  timeout=${ALARM_TIMEOUT}
             Log  Fault ${FAULT_2401} is active in WebEM.  console=true
        END
    END

    IF  ${SCF_COUNT_WCDMA}
        ${fid_17_params}  Get String With Alarm Parameters  ${FAULT_17}
        Assert Alarm Active  parameters=${fid_17_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_17} is active in WebEM.  console=true
    END

    IF  ${SCF_COUNT_LTE}
        ${fid_6150_params}  Get String With Alarm Parameters  ${FAULT_6150}
        Run keyword and ignore error  Assert Alarm Active  parameters=${fid_6150_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_6150} is active in WebEM.  console=true

        ${fid_4530_params}  Get String With Alarm Parameters  ${FAULT_4530}
        Assert Alarm Active  parameters=${fid_4530_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_4530} is active in WebEM.  console=true

        ${fid_6202_params}  Get String With Alarm Parameters  ${FAULT_6202_CRITICAL}
        Assert Alarm Active  parameters=${fid_6202_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_6202_Critical} is active in WebEM.  console=true

        ${fid_6327_params}  Get String With Alarm Parameters  ${FAULT_6327}
        Assert Alarm Active  parameters=${fid_6327_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_6327} is active in WebEM.  console=true
    END

    IF  ${SCF_COUNT_NR}
        ${fid_4452_params}  Get String With Alarm Parameters  ${FAULT_4452}
        Assert Alarm Active  parameters=${fid_4452_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_4452} is active in WebEM.  console=true
    END

    ${fid_4298_params}  Get String With Alarm Parameters  ${FAULT_4298}
    Assert Alarm Active  parameters=${fid_4298_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4298} is active in WebEM.  console=true

    FOR  ${ntp_ip}  IN  @{NTP_SERVERS_IPS}
         ${fid_4297_params}  Get String With Alarm Parameters  ${FAULT_4297}
         ${fid_4297_params}  Catenate  SEPARATOR=,${SPACE}  ${fid_4297_params}  faultName="NTP Server ${ntp_ip} unavailable"
         Assert Alarm Active  parameters=${fid_4297_params}  timeout=${ALARM_TIMEOUT}
         Log  Fault ${FAULT_4297} is active in WebEM for NTP server with ip: ${ntp_ip}.  console=true
    END

    ${fid_4405_params}  Get String With Alarm Parameters  ${FAULT_4405}
    Assert Alarm Active  parameters=${fid_4405_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4405} is active in WebEM.  console=true

    ${fid_6280_params}  Get String With Alarm Parameters  ${FAULT_6280}
    Assert Alarm Active  parameters=${fid_6280_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_6280} is active in WebEM.  console=true

    ${failed_cell_status}  Run Keyword And Return Status  Check That At Least One Cell Is Failed
    IF  ${failed_cell_status}
        ${fid_4753_params}  Get String With Alarm Parameters  ${FAULT_4753}
        Assert Alarm Active  parameters=${fid_4753_params}  timeout=${ALARM_TIMEOUT}
        Log  Fault ${FAULT_4753} is active in WebEM.  console=true
    END

    ${ecpri_rmods}  ${ecpri_rmods_r}  Get ECPRI RMODS ids
    ${ecpri_status}  Run Keyword And Return Status  Should Not Be Empty  ${ecpri_rmods}
    IF  ${ecpri_status}
        FOR  ${rmod}  IN  @{ecpri_rmods}
             ${fid_16_params}  Get String With Alarm Parameters  ${FAULT_16}
             ${fid_16_params}  Catenate  SEPARATOR=,${SPACE}  ${fid_16_params}  configObjectName="[${BTS_ID}] MRBTS-${BTS_ID}/${rmod}"
             Assert Alarm Active  parameters=${fid_16_params}  timeout=60
             Log  Fault ${FAULT_16} is active in WebEM.  console=true

             ${fid_4298_params}  Get String With Alarm Parameters  ${FAULT_4298}
             ${fid_4298_params}  Catenate  SEPARATOR=,${SPACE}  ${fid_4298_params}  configObjectName="[${BTS_ID}] MRBTS-${BTS_ID}/${rmod}"
             Assert Alarm Active  parameters=${fid_4298_params}  timeout=60
             Log  Fault ${FAULT_4298} is active in WebEM.  console=true
        END
    END
    Set Test Variable  ${FAILED_CELL_STATUS}


Check That Alarms From Netact Are Cleared
    IF  (${SA_EXISTS} and ${NSA_EXISTS}) or ${SA_NSA_EXISTS}
        FOR  ${lteenb}  IN  @{LTEENB_INDEX_LIST}
             Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
             ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms
             ...  &{FAULT_7308}
             ...  object_id=PLMN-PLMN/MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/LTEENB-${lteenb}
             ...  time_from=${START_TIME}
             Log  Fault ${FAULT_7308} reported & cleared from Netact.  console=true
        END

        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_7107_MAJOR}  time_from=${START_TIME}
        Log  Fault ${FAULT_7107_MAJOR} reported & cleared from Netact.  console=true

        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_7304}  time_from=${START_TIME}
        Log  Fault ${FAULT_7304} reported & cleared from Netact.  console=true

        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_7504}  time_from=${START_TIME}
        Log  Fault ${FAULT_7504} reported & cleared from Netact.  console=true

        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_7303}  time_from=${START_TIME}
        Log  Fault ${FAULT_7303} reported & cleared from Netact.  console=true

        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_7505_ALARM_7107}
        ...                                                                               alarm_name=BASE STATION CONNECTIVITY PROBLEM
        ...                                                                               time_from=${START_TIME}
        Log  Fault ${FAULT_7505_ALARM_7107} reported & cleared from Netact.  console=true

        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_7305}  time_from=${START_TIME}
        Log  Fault ${FAULT_7305} reported & cleared from Netact.  console=true
    ELSE IF  ${NSA_EXISTS}
        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_7308}  time_from=${START_TIME}
        Log  Fault ${FAULT_7308} reported & cleared from Netact.  console=true

        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_7107_MAJOR}  time_from=${START_TIME}
        Log  Fault ${FAULT_7107_MAJOR} reported & cleared from Netact.  console=true
    END

    IF  ${SCF_COUNT_GSM}
        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2412_MINOR}
        ...                                                                               dist_name=PLMN-PLMN/BSC-${BSC_ID}/BCF-${BCF_ID}
        ...                                                                               time_from=${START_TIME}
        Log  Fault ${FAULT_2412_MINOR} reported & cleared from Netact.  console=true

        FOR  ${gsm_bts_id}  IN  @{BTS_IDS_LIST}
             Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
             ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms
             ...  &{FAULT_2401}
             ...  dist_name=PLMN-PLMN/BSC-${BSC_ID}/BCF-${BCF_ID}/BTS-${gsm_bts_id}
             ...  time_from=${START_TIME}
             Log  Fault ${FAULT_2401} reported & cleared from Netact on /BSC-${BSC_ID}/BCF-${BCF_ID}/BTS-${gsm_bts_id}.  console=true
        END
    END

    IF  ${SCF_COUNT_WCDMA}
        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_17}
        ...                                                                               dist_name=PLMN-PLMN/RNC-${RNC_ID}/WBTS-${WBTS_ID}
        ...                                                                               time_from=${START_TIME}
        Log  Fault ${FAULT_17} reported & cleared from Netact.  console=true
    END

    IF  ${SCF_COUNT_LTE}
        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_6150}  time_from=${START_TIME}
        Log  Fault ${FAULT_6150} reported & cleared from Netact.  console=true

        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4530}  time_from=${START_TIME}
        Log  Fault ${FAULT_4530} reported & cleared from Netact.  console=true

        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_6202_CRITICAL}  time_from=${START_TIME}
        Log  Fault ${FAULT_6202_Critical} reported & cleared from Netact.  console=true

        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_6327}  time_from=${START_TIME}
        Log  Fault ${FAULT_6327} reported & cleared from Netact.  console=true
    END

    IF  ${SCF_COUNT_NR}
        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4452}  time_from=${START_TIME}
        Log  Fault ${FAULT_4452} reported & cleared from Netact.  console=true
    END

    Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4298}  time_from=${START_TIME}
    Log  Fault ${FAULT_4298} reported & cleared from Netact.  console=true

    FOR  ${ntp_ip}  IN  @{NTP_SERVERS_IPS}
         Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
         ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4297}
         ...                                                                               fault_name=NTP Server ${ntp_ip} unavailable
         ...                                                                               time_from=${START_TIME}
         Log  Fault ${FAULT_4297} reported & cleared from Netact.  console=true
    END

    Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4405}  time_from=${START_TIME}
    Log  Fault ${FAULT_4405} reported & cleared from Netact.  console=true

    Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_6280}  time_from=${START_TIME}
    Log  Fault ${FAULT_6280} reported & cleared from Netact.  console=true

    IF  ${FAILED_CELL_STATUS}
        Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4753}  time_from=${START_TIME}
        Log  Fault ${FAULT_4753} reported & cleared from Netact.  console=true
    END

    ${ecpri_rmods}  ${ecpri_rmods_r}  Get ECPRI RMODS ids
    ${ecpri_status}  Run Keyword And Return Status  Should Not Be Empty  ${ecpri_rmods_r}
    IF  ${ecpri_status}
        FOR  ${rmod}  IN  @{ecpri_rmods_r}
             Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
             ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_16}
             ...                                                                               alarm_name=BASE STATION SERVICE PROBLEM
             ...                                                                               object_id=PLMN-PLMN/MRBTS-${BTS_ID}/${rmod}
             ...                                                                               time_from=${START_TIME}
             Log  Fault ${FAULT_16} reported & cleared from Netact.  console=true

             Wait Until Keyword Succeeds  ${ALARM_RECOVERY_TIMEOUT}  10s
             ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4298}
             ...                                                                               object_id=PLMN-PLMN/MRBTS-${BTS_ID}/${rmod}
             ...                                                                               time_from=${START_TIME}
             Log  Fault ${FAULT_4298} reported & cleared from Netact.  console=true
        END
    END

    Log  All alarms are reported & cleared from Netact.  console=true


Check SA and NSA Or SA+NSA Cells
    Set Test Variable  ${SA_EXISTS}  ${NONE}
    Set Test Variable  ${NSA_EXISTS}  ${NONE}
    Set Test Variable  ${SA_NSA_EXISTS}  ${NONE}
    ${all_cells}  Get Cells Info
    FOR  ${cell}  IN  @{all_cells}
         ${sa_status}  Run Keyword And Return Status  Should Be Equal As Strings    ${cell}[cellDepType]    SA
         IF  ${sa_status}  Set Test Variable  ${SA_EXISTS}  ${TRUE}
         ${nsa_status}  Run Keyword And Return Status  Should Be Equal As Strings    ${cell}[cellDepType]    NSA
         IF  ${nsa_status}  Set Test Variable  ${NSA_EXISTS}  ${TRUE}
         ${sa_nsa_status}  Run Keyword And Return Status  Should Be Equal As Strings    ${cell}[cellDepType]    SA+NSA
         IF  ${sa_nsa_status}  Set Test Variable  ${SA_NSA_EXISTS}  ${TRUE}
    END


Set NTP Ip Adresses
    ${ntp_servers_ips}  Create List
    ${ntp_servers}  coam.Get Managed Objects  NTP_R
    FOR  ${server}  IN  @{ntp_servers}
         ${parameters}  Get From Dictionary  ${server}  parameters
         ${ntp_server_status_list}  Get From Dictionary  ${parameters}  ntpServerStatusList
         FOR  ${item}  IN  @{ntp_server_status_list}
             Append To List  ${ntp_servers_ips}  ${item}[ntpServerIpAddr]
         END
    END
    Should Not Be Empty  ${ntp_servers_ips}  msg=No NTP server IP address found in Infomodel.
    Set Test Variable  ${NTP_SERVERS_IPS}


Set RNC BTS IDs
    ${rnc_obj}  coam.Get Managed Objects  RNC
    ${rnc_id}  Fetch From Right  ${rnc_obj}[0][distName]  RNC-
    Set Test Variable  ${RNC_ID}
    ${wbts_obj}  coam.Get Managed Objects  WBTS
    ${wbts_id}  Fetch From Right  ${wbts_obj}[0][distName]  WBTS-
    Set Test Variable  ${WBTS_ID}


Set BSC BTS IDs
    ${bsc_obj}  coam.Get Managed Objects  BSC
    ${bsc_id}  Fetch From Right  ${bsc_obj}[0][distName]  BSC-
    Set Test Variable  ${BSC_ID}
    ${bcf_obj}  coam.Get Managed Objects  BCF
    ${bcf_id}  Fetch From Right  ${bcf_obj}[0][distName]  BCF-
    Set Test Variable  ${BCF_ID}

    ${bts_ids_list}  Create List
    ${bts_objs_list}  coam.Get Managed Objects  BTS
    FOR  ${item}  IN  @{bts_objs_list}
         ${gsm_bts_id}  Fetch From Right  ${item}[distName]  BTS-
         Append To List  ${bts_ids_list}  ${gsm_bts_id}
    END
    Set Test Variable  ${BTS_IDS_LIST}


Check That All Cells Are Disabled
    [Arguments]  ${TIMEOUT}

    IF  ${SCF_COUNT_WCDMA}  coam.Assert Every  WNCEL  operationalState=${DISABLED}  timeout=${TIMEOUT}
    IF  ${SCF_COUNT_LTE}  coam.Assert Every  LNCEL  operationalState=${DISABLED}  timeout=${TIMEOUT}
    IF  ${SCF_COUNT_GSM}  coam.Assert Every  GNCEL  operationalState=${DISABLED}  timeout=${TIMEOUT}
    IF  ${SCF_COUNT_NR}  coam.Assert Every  NRCEL  operationalState=${DISABLED}  timeout=${TIMEOUT}


Check That At Least One Cell Is Failed
    ${all_cells}  Get Cell List
    IF  ${SCF_COUNT_GSM}
        FOR  ${cell}  IN  @{all_cells}[cells][gsm]
             ${failed_cell_status}  Run Keyword And Return Status  Should Contain  ${FAILED}  ${cell}[status][availabilityStatus]
             IF  ${failed_cell_status}  RETURN
        END
    END
    IF  ${SCF_COUNT_WCDMA}
        FOR  ${cell}  IN  @{all_cells}[cells][wcdma]
             ${failed_cell_status}  Run Keyword And Return Status  Should Contain  ${FAILED}  ${cell}[status][availabilityStatus]
             IF  ${failed_cell_status}  RETURN
        END
    END
    IF  ${SCF_COUNT_LTE}
        FOR  ${cell}  IN  @{all_cells}[cells][lte]
             ${failed_cell_status}  Run Keyword And Return Status  Should Contain  ${FAILED}  ${cell}[status][availabilityStatus]
             IF  ${failed_cell_status}  RETURN
        END
    END
    IF  ${SCF_COUNT_NR}
        FOR  ${cell}  IN  @{all_cells}[cells][nr]
             ${failed_cell_status}  Run Keyword And Return Status  Should Contain  ${FAILED}  ${cell}[status][availabilityStatus]
             IF  ${failed_cell_status}  RETURN
        END
    END
    Fail  No cell has availability status failed.


Get ECPRI RMODS ids
    ${rmods}  Get Parameters For All  RMOD
    ${ecpri_rmods}  Create List
    ${ecpri_rmods_r}  Create List
    FOR  ${rmod}  IN  @{rmods}
        Continue For Loop If  'ECPRI' not in '${rmod}[l3Protocol]'
        ${rmod_r_id}  Get Regexp Matches  ${rmod}[id]  EQM_R-.*/APEQM_R-.*/RMOD_R-.*
        ${rmod_id}  Remove String Using Regexp  ${rmod_r_id}[0]  _R
        Append To List  ${ecpri_rmods}  ${rmod_id}
        Append To List  ${ecpri_rmods_r}  ${rmod_r_id}[0]
    END

    RETURN  ${ecpri_rmods}  ${ecpri_rmods_r}


Perform Recovery Action
    IF  '${SWITCH_TYPE}'=='Nokia_7210' or '${SWITCH_TYPE}'=='Nokia_Nuage'
        Wait Until Keyword Succeeds  5min  1min  Connect To Nokia Serving Switch And Perform Action On Port  ${SWITCH_IP}
        ...                                                                                                  ${SWITCH_USER}
        ...                                                                                                  ${SWITCH_PASSWORD}
        ...                                                                                                  ${INTERFACE_ID}
        ...                                                                                                  no shutdown
    ELSE
        Fail  msg=Serving switch is not supported, test will be set as failed.
    END

    ssh.Connect To  ${OAM_BTS_IP}  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}  alias=pc_connection
    ssh.Execute  iptables -D OUTPUT -p sctp --sport 36422 -j DROP   connection=pc_connection
    ssh.Execute  iptables -t filter -F OUTPUT  connection=pc_connection
    ssh.Execute  ip6tables -t filter -F OUTPUT  connection=pc_connection
    ssh.Disconnect  connection=pc_connection
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells
    Perform Site Reset


TC Setup
    Common Test Setup  tc_name=FM__link_break_SBTS_long
    Setup Netact


TC Teardown
    Run Keyword If Test Failed  Perform Recovery Action
    Change FMCADM parameter  actAlarmOfRatOutage  false
    Teardown Netact
    Common Test Teardown
