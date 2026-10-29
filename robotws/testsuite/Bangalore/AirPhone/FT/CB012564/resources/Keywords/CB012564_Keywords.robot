*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : Contains Keyword needed for CB012564
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,20.04.2025,vadivelan.manickavasagam@nokia.com

Resource    ../../../resources/Keywords/general_common_keywords.robot

*** Keywords ***
CB012564 Suite Setup
#     Clean up Preparation before TC
#     Add Rad Param Or Modify GNB swconfig     0x58057a=4     0x58057f=72     0x580582 = 3     0x58057b = 8      0x8000A6 = 0
#     Add Rad Param Or Modify AP swconfig      0x10043=51011     0x10040=1
     Sleep     5
#     Start Logs      ${L_AP_GNB_SYS}

CB012564 Suite Teardown
     Log to console      "suite teardown - stopping and collecting sos report with BIP "
     Sleep     10
#     Stop Logs     ${L_AP_GNB_SYS}
##     Cleanup Process After TC
     Sleep      5
#     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
#     Execute Egate Command     cmd=ue_disp id=1
#     Execute Egate Command     cmd=ue_disp id=1
#     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
#     Stop and collect SOS       ${sos_script_path}    ${Log_Path}
#     Execute Egate Command     cmd=${CM_SET_LOG_FLUSH}
#     Collect Cfg and Egate Logs
#     Cleanup Process After TC

CB012564 SA Call UE1
     Exe egate cmd      cmd=${CM_UE1_DTYPE_INTERNAL}
     Exe egate cmd      cmd=${CM_UE_1_REGISTER}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_REG}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_PDU_SESSION}
     Sleep      5
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_PDU_SESSION}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
     Exe egate cmd      cmd=${CM_UE_1_UL_DATA}

CB012564 SA Deregister UE1
     Exe egate cmd      cmd=${CM_UE_1_DEREG}
     Validate     log=${L_EGATE_CONSOLE}      element=${VAL_UE1_DEREG_REL}
     ...     value=none      logfile_with_path=${DEF_EGATE_CONSOLE_LOG}
Activate RI
    Execute Egate Command
    ...    cmd=${CM_RI_PROFILE_7}
    Sleep   5s
    Execute Egate Command
    ...    cmd=${CM_RI_PROFILE_7_ACTIVATE}

Generate RI For 1116 FS
    Execute Egate Command
    ...    cmd=${CM_RI_PROFILE_7_SEMISTATIC}
    Sleep   5s
    Execute Egate Command
    ...    cmd=${CM_RI_PROFILE_7_ACTIVATE}

Activate RIMRS FW1 9823-E
    ${CM_RIM_RS_PROFILE_97}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=${CM_RIM_RS_PROFILE_ID_97} config_mode=${CM_RIM_RS_CFG_MODE_STAND_ALONE}
    ...     \ aggressor_cell=${CM_AGGRESSOR_CELL_1} victim_cell=${CM_VICTIM_CELL_1} rsSetId=${CM_RS_SET_ID_11144}
    ...     \ numRsSetId=${CM_NUM_RS_SET_ID_16} rimRsType=${CM_RIM_RS_TYPE_TYPE1_TYPE2}
    ...     \ propagation_delay=${CM_PROPAGATION_DELAY_16} rsType1NScId=${CM_RIM_RS_TYPE1_NSCID_1TO8}
    ...     \ rsType2NScId=${CM_RIM_RS_TYPE2_NSCID_11TO18} rsPattern1Period=${CM_RIM_RS_PATTERN1_PERIOD_50}
    ...     \ rsPattern2Period=${CM_RIM_RS_PATTERN2_PERIOD_25} factorRsSequence=${CM_RIM_RS_FACTOR_RS_SEQ_RS1}
    ...     \ factorRsSequenceRS2=${CM_RIM_RS_FACTOR_RS_SEQ_RS2} offsetRsSequence=${CM_RIM_RS_OFFSET_SEQ_RS1}
    ...     \ offsetRsSequenceRS2=${CM_RIM_RS_OFFSET_SEQ_RS2} repetitionRsType1=${CM_RIM_RS_REPETITION_RS_TYPE1_2}
    ...     \ repetitionRsType2=${CM_RIM_RS_REPETITION_RS_TYPE2_4} rim_framework=${CM_RIM_RS_FW1}
    ...     \ numRbForRs=${CM_RIM_RS_NUM_RB_FOR_RS_96} numRsType2SetId=${CM_RIM_RS_NUM_RS_TYPE1_SETID_65536}
    ...     \ numRsType1SetId=${CM_RIM_RS_NUM_RS_TYPE2_SETID_65536} globalF0ForRs=${CM_RIM_RS_GLOBAL_F0_FOR_RS}
    ...     \ startFreqOffsetForRs=${CM_RIM_RS_START_F_O_2_100}
    Execute Egate Command     cmd=${CM_RIM_RS_PROFILE_97}
    Sleep    5s
    Execute Egate Command
    ...    cmd=${CM_RIM_RS_PROFILE_97_ACTIVATE}

Deactivate RI
    Execute Egate Command
    ...    cmd=${CM_DEACTIVATE_RI_PROFILE_97}
    Sleep    10s

Deactivate RIMRS FW1
    Execute Egate Command
    ...    cmd=${CM_DEACTIVATE_RIM_RS_PROFILE_97}

Get 7527 alarm setid
    ${list_alarm}    Get Coam Active Alarms
    Log to console     ${list_alarm}
    FOR    ${alarm}    IN    @{list_alarm}
        Log to console    ${alarm}
        ${fault_id}=    Set Variable    ${alarm['faultId']}
        ${suppl_alarm_info}=    Set Variable    ${alarm['alarmText']['alarmAdditionalInfo']['supplAlarmInfo']}
        Log to console    ${suppl_alarm_info}
        ${alarm_text}=    Set Variable If    '${fault_id}' == '7527'    ${suppl_alarm_info}
        Log to console     ${alarm_text}
        Exit For Loop IF     '${fault_id}' == '7527'
    END
    [Return]    ${alarm_text}

Get 7527 alarm setid with cell info
    [Arguments]   ${cell_info}="NOTASSIGNED"
    ${list_alarm}    Get Coam Active Alarms
    Log to console     ${list_alarm}
    FOR    ${alarm}    IN    @{list_alarm}
        Log to console    ${alarm}
        ${fault_id}=    Set Variable    ${alarm['faultId']}
        ${suppl_alarm_info}=    Set Variable    ${alarm['alarmText']['alarmAdditionalInfo']['supplAlarmInfo']}
        Log to console    ${suppl_alarm_info}
        ${alarm_text}     Set Variable     "None None None"

        If     ${fault_id}' == '7107'
              If     '${alarm_cell}'     ==     'NR:1'
                     ${alarm_text}=    Set Variable If    '${fault_id}' == '7527'    ${suppl_alarm_info}
                     Log to console     ${alarm_text}
                     Exit For Loop IF     '${fault_id}' == '7107'
        ELSE
             Continue For Loop
        END
    END
    [Return]    ${alarm_text}
    Log to console ${cell_info}

Check RsSetId in Alarm Text
    [Arguments]    ${alarm_text}
    Set Test Variable     ${detected}      0
    ${all_found}=    Set Variable    True
    FOR    ${value}    IN    @{CM_LST_RIM_RS_SET_ID}
        ${value_str}=    Convert To String    ${value}
        ${is_present}=    Run Keyword And Return Status    Should Contain    ${alarm_text}    ${value_str}
        IF   ${is_present} == True
            ${detected}=     Evaluate    ${detected}+1
            Log to console     ${value_str} found in alarm text
        ELSE IF   ${is_present} == False
            Log    ❌ Missing value: ${value}
            ${all_found}=    Set Variable    False
#            Exit For Loop
        END
    END
    ${all_found}      Run Keyword If    '${detected}' == '6'    Return From Keyword    True
    ...    ELSE    Return From Keyword    False
#    ${all_found}    Should Be Equal As Integers      ${detected}    6
    [Return]    ${all_found}
