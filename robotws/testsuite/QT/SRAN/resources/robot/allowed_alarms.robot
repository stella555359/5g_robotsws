*** Settings ***
Documentation  Check alarms keywords

Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library      OperatingSystem
Library      ute_admin_infomodel
Library      ${CURDIR}/../python/alarms_keywords.py


*** Variables ***
@{CLASSICAL_ALLOWED_ACITVE_ALARMS}
...    4424    #SBTS adaptation notification
...    1898    #PPS reference missing
...    4297    #NTP Server unavailable
...    4420    #firmware upgrade ongoing
...    4592    #BTS Reset Cause
...    4654    #Ethernet port security is disabled
...    4655    #Service account root access is enabled
...    61524   #SSH enabled
...    61649   #LMP access via port 443
...    61652   #R&D Service Port enabled

@{CLASSICAL_ALLOWED_HISTORICAL_ALARMS}
...    4424    #SBTS adaptation notification
...    1898    #PPS reference missing
...    4297    #NTP Server unavailable
...    4298    #ToP reference missing
...    4420    #firmware upgrade ongoing
...    4592    #BTS Reset Cause
...    4654    #Ethernet port security is disabled
...    4655    #Service account root access is enabled
...    7300    #No X2 link available
...    7319    #No X2 link available for a specific LTEENB
...    61524   #SSH enabled
...    61649   #LMP access via port 443
...    61652   #R&D Service Port enabled
...    23      #SW incompatible

@{vCU_ALLOWED_ALARMS}
...    4592    #BTS Reset Cause
...    7303    #F1 SCTP endpoint in CU
...    8000    #Failure in connection between BTS and 3rd party tool

@{vCU_ALLOWED_HISTORICAL_ALARMS}
...    4592    #BTS Reset Cause
...    7303    #F1 SCTP endpoint in CU
...    7310    #E1 SCTP Endpoint Failure
...    7104    #Matching ServedCell not found over F1-C
...    7300    #No X2 link available
...    70164   #ETHERNET LINK FAILURE
...    61671   #ETHERNET LINK FAILURE
...    4350    #VNFC unavailable
...    8000    #Failure in connection between BTS and 3rd party tool

@{vDU_ALLOWED_ALARMS}
...    4523    #Troubleshooting data available on vDU

@{vDU_ALLOWED_HISTORICAL_ALARMS}
...    7504    #F1 SCTP endpoint in DU
...    7505    #F1 SCTP setup in DU
...    4523    #Troubleshooting data available on vDU
...    10
...    23
...    7500    #F1AP Setup fails upon non response from gNB-CU
...    4592    #BTS Reset Cause
...    70164   #ETHERNET LINK FAILURE
...    61671   #ETHERNET LINK FAILURE
...    4350    #VNFC unavailable
...    8101    #L1 IQ Data Suspicious Event - temporary allowed (PR843584)

&{vDU_ALLOWED_HISTORICAL_ALARMS_BY_TIME}
...    1806=35   #Fault ID 1806 should be cleared within 35 seconds
...    16=120    #Fault ID 16 should be cleared within 120 seconds
...    4405=780  #Fault ID 4450 should be cleared within 13 mins
...    4125=60   #Fault ID 4125 should be cleared within 1 minute
...    4675=180  #Fault ID 4675 should be cleared within 3 minutes

@{STOP_AND_FIX_ALARMS}
...    10      #No connection to unit

${not_allowed_list}     ${EMPTY}

@{allowed_4681}    2    4    31    38    42    40
&{4681_subid_desc}
...  1=Probable root cause: SW, the configuration file for active (or previously active) configuration is missing from active partition
...  2=Probable root cause: SW, the configuration file for previously active configuration is missing from passive partition
...  3=Probable root cause: SW, SWDLreport.txt is missing from the file system
...  4=Probable root cause: SW, netboot_only is set
...  5=Probable root cause: SW, FileDirectory.xml or file(s) referred in FileDirectory.xml are missing from the active partition
...  6=Probable root cause: SW, FileDirectory.xml or file(s) referred in FileDirectory.xml are missing from the passive partition
...  7=Probable root cause: SW, the configuration file is corrupted on active partition
...  8=Probable root cause: SW, the configuration file is corrupted on passive partition
...  9=Probable root cause: HW, the conditions for raising any of Fault6907-High PDU input voltage or Fault6908-Low PDU input voltage faults are met
...  10=Probable root cause: HW, the conditions for raising any of Fault2919, Fault2920, Fault4680 are met
...  11=System module RAM usage NOK. Instruction: Perform a BTS reset
...  12=System module CPU usage NOK
...  13=Available disk space for runtime procedure NOK. Instruction: Collect a BTS snapshot and require Nokia to check it
...  14=Mass storage disk health NOK. Instruction: Replace the broken HW unit in the system module
...  15=Boot flash health NOK. Instruction: Restart the alarming module until the alarming module is replaced or replace the alarming module
...  16=Probable root cause: SW, hash signature mismatch with Hash Container, or checksum mismatch with TargetBD, or p7 signature file is missing
...  17=Probable root cause: SW, at least one connected HW has an active software component version that is not compatible with active SW version
...  18=Probable root cause: HW, the conditions for raising 1936, 1937 and 1938 fault on Radio Module are not met
...  19=Probable root cause: HW, the conditions for raising 4077 or 2 fault on SMOD are met
...  20=System module ambient temperature supervision NOK. Instruction: Follow the fault description in Customer Documentation
...  21=Probable root cause: HW, the conditions for raising 4741 fault - Unstable eCPRI Link Detected are met
...  22=Probable root cause: HW, the conditions for raising 61009 Fronthaul loopback connectivity check failure are met
...  23=Ethernet backplane link NOK. Instruction: Reset the alarming HWs and replace alarming HWs if the first step can't recover the unit/board
...  24=Probable root cause: HW, the conditions for raising 815 Not able to synchronize baseband bus for backplane RP3 links are met
...  26=Probable root cause: HW, the conditions for raising 1934 or 1933 or 1935 on Radio Module are met
...  27=GNSS device NOK.Instruction: Check the active alarms related to faults 4011, 4122, 4123, 4124, 4125, 4210, 4126, 4272, 4420, and 4439
...  28=Fronthaul SFPs NOK. Instruction: Check the technical condition of the SFP optical part as the transmitter part can be damaged or dirty
...  29=Probable root cause: HW, the conditions for raising 4698, 4699, 4700, 4701 faults for Backhaul SFPs are met
...  31=Probable root cause: HW, there is at least one active critical alarm
...  32=Eye diagram NOK, please ensure that the module is properly connected
...  33=Secondary core connectivity NOK, detail instructions please refer to NIDD page
...  34=Uncorrectable ECC errors, Instruction: Replace HW
...  35=Probable root cause: HW, received POST status is FaultFatal/FaultMinor/PostAnalyzingMalfunction
...  36=QSPI flash health NOK. Instruction: Replace HW
...  37=System module FAN speed NOK. Instruction: Ensure the fan or airflow isn't blocked by any object and the fan connector is properly mounted
...  38=Active configuration file is missing from running SW, attempt a fix through commissioning
...  39=Configuration data valid check, attempt a fix through commissioning
...  40=Probable root cause: SW or HW, Some of the test fails. Instruction: Reload SW package, if it does not help replace radio.
...  41=Probable root cause: SW, level of memory usage is equal or higher than threshold (configurable). Instruction: Reset radio
...  42=Probable root cause: HW, temperature sensor fault (1940) is active, no actions are required. There are redundant sensors that can be used.
...  43=Probable root cause: HW, DDR memory test fails. Instruction: Replace HW

*** Keywords ***
Check Unexpected Active Alarms
    [Arguments]          ${host}=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}
    ...                  ${additonal_allowed_alarms}=${Empty}
    ...                  ${connection}=coam_admin    ${console}=${True}
    ...                  ${skip_coam_connection_setup}=${False}
    @{not_allowed_alarms_classical}    Create List
    Run Keyword If    '${additonal_allowed_alarms}'!='${Empty}'
    ...     Append To List    ${CLASSICAL_ALLOWED_ACITVE_ALARMS}    ${additonal_allowed_alarms}
    Run Keyword And Continue On Failure   Check GPS Receiver Alarm    skip_coam_connection_setup=${skip_coam_connection_setup}
    Run Keyword If    not ${skip_coam_connection_setup}    WA for coam connect    bts_host=${host}
    ${active_alarms}          coam.get_active_alarms    connection=${connection}
    Checking If Alarm Is On The Allowed List
    ...   alarms=${active_alarms}   fault_id=faultId    name_list=${not_allowed_alarms_classical}
    ...   alowed_alarms_list=${CLASSICAL_ALLOWED_ACITVE_ALARMS}
    ${not_allowed_list}    Run Keyword And Return Status    Should Be Empty   ${not_allowed_alarms_classical}
    Set Suite Variable    ${not_allowed_alarms_classical}
    Run Keyword If   '${not_allowed_list}'=='False'
    ...               Run Keywords
    ...               Run Keyword If    ${console}    Log Alarms List To Console
    ...               alarms_list=${not_allowed_alarms_classical}
    ...               msg=Not allowed alarm appeared on bts
    ...        AND    FAIL
    [Teardown]  Run Keyword If    not ${skip_coam_connection_setup}
    ...         Run Keyword and ignore error    coam.teardown    connection=${connection}

Check Unexpected Active Alarms On vCU
    [Arguments]          ${CU_WEBUI_IP}=${CU_WEBUI_IP}
    @{not_allowed_alarms}    Create List
    Set Test Variable     ${not_allowed_alarms}
    Connect To vCU    host_ip=${CU_WEBUI_IP}    loop_check=${2}
    ${active_alarms}          coam_cu.get_active_alarms
    Checking If Alarm Is On The Allowed List
    ...   alarms=@{active_alarms['alarms']}   fault_id=fault_id    fault_name=fault_name    alowed_alarms_list=${vCU_ALLOWED_ALARMS}
    ${not_allowed_list}    Run Keyword And Return Status    Should Be Empty   ${not_allowed_alarms}
    Run Keyword If   '${not_allowed_list}'=='False'
    ...               Run Keywords
    ...               Log Alarms List To Console
    ...               alarms_list=${not_allowed_alarms}
    ...               msg=Not allowed alarm appeared on CU
    ...               AND    FAIL
    [Teardown]    Run Keyword and ignore error    coam_cu.disconnect

Get Unexpected Active And Historical Alarms On vCU
    ${cu_historic_alarms_before_test}    Get Variable Value    ${cu_historic_alarms_before_test}    ${EMPTY}
    ${cu_active_alarms_before_test}    Get Variable Value    ${cu_active_alarms_before_test}    ${EMPTY}
    ${webui_connection}    Get Variable Value    ${webui_connection}    False
    Run Keyword If    '${webui_connection}'=='False'    Connect To vCU    loop_check=${2}
    TRY
        ${historic_alarms}    Wait Until Keyword Succeeds    2x    10s     coam_cu.Get Historical Alarms    use_m2m=${False}
    EXCEPT    AS    ${error}
        Log to console   Get historic_alarms failed due to ${error}, start to reconnect WebEM...
        Connect To vCU
        ${historic_alarms}    Wait Until Keyword Succeeds    2x    10s    coam_cu.Get Historical Alarms    use_m2m=${False}
    END
    ${historic_alarms}    remove_historic_alarms_occurs_before_test    ${cu_historic_alarms_before_test}    ${historic_alarms}
    ${historic_alarms}    remove_active_alarms_occurs_before_test    ${cu_active_alarms_before_test}    ${historic_alarms}
    BuiltIn.Sleep        3s
    ${active_alarms}     coam_cu.get_active_alarms
    Set Test Variable    ${historic_alarms}
    Set Test Variable    ${active_alarms}

Get Unexpected Active And Historical Alarms On vDU
    ${du_historic_alarms_before_test}    Get Variable Value    ${du_historic_alarms_before_test}    ${EMPTY}
    ${du_active_alarms_before_test}    Get Variable Value    ${du_active_alarms_before_test}    ${EMPTY}
    ${oam_web_ip}     set variable if     ':' in '''${DU_WEBUI_IP}'''    [${DU_WEBUI_IP}]    ${DU_WEBUI_IP}
    ${webui_connection}    Get Variable Value    ${webui_connection}    False
    Run Keyword If    '${webui_connection}'=='False'    Connect To vDU    ${oam_web_ip}
    TRY
        ${historic_alarms}    Wait Until Keyword Succeeds    2x    10s
        ...                   vdu.vdu_get_historical_alarms    vdu_connection=du_admin    timeout=120    use_m2m=${False}
    EXCEPT    AS    ${error}
        Log to console    Get historic_alarms failed due to ${error}, start to reconnect WebEM...
        Connect To vDU    ${oam_web_ip}
        ${historic_alarms}    Wait Until Keyword Succeeds    2x  10s
        ...                   vdu.vdu_get_historical_alarms   vdu_connection=du_admin   timeout=120    use_m2m=${False}
    END
    ${historic_alarms}    remove_historic_alarms_occurs_before_test    ${du_historic_alarms_before_test}    ${historic_alarms}
    ${historic_alarms}    remove_active_alarms_occurs_before_test    ${du_active_alarms_before_test}    ${historic_alarms}
    BuiltIn.Sleep        3s
    ${active_alarms}     vdu.vdu_get_active_alarms   vdu_connection=du_admin    use_m2m=${False}
    Set Test Variable    ${historic_alarms}
    Set Test Variable    ${active_alarms}

Check Unexpected Active Alarms On vDU
    [Arguments]          ${DU_WEBUI_IP}=${DU_WEBUI_IP}    ${log_to_console}=True
    @{not_allowed_alarms}    Create List
    Set Test Variable     ${not_allowed_alarms}
    ${oam_web_ip}   set variable if   ':' in '''${DU_WEBUI_IP}'''   [${DU_WEBUI_IP}]    ${DU_WEBUI_IP}
    Connect To vDU    host_ip=${oam_web_ip}    loop_check=${4}
    ${active_alarms}          vdu.vdu_get_active_alarms   vdu_connection=du_admin    use_m2m=${False}
    Checking If Alarm Is On The Allowed List
    ...    alarms=@{active_alarms['alarms']}   fault_id=fault_id   fault_name=fault_name    alowed_alarms_list=${vDU_ALLOWED_ALARMS}
    ${not_allowed_list}    Run Keyword And Return Status    Should Be Empty   ${not_allowed_alarms}
    Run Keyword If   '${not_allowed_list}'=='False' and '${log_to_console}'=='True'    Run Keywords
    ...               Log Alarms List To Console
    ...               alarms_list=${not_allowed_alarms}
    ...               msg=Not allowed alarm appeared on DU
    ...               AND    FAIL
    ...    ELSE IF    '${not_allowed_list}'=='False' and '${log_to_console}'=='False'    FAIL
    [Teardown]    Run Keyword and ignore error    vdu.disconnect   vdu_connection=du_admin

Check Unexpected Active And Historical Alarms on Cloud
    [Arguments]    ${vCUorvDU}   ${before_after}=before
    ${Not_allowed_active_alarms_list}     Create List
    ${Not_allowed_history_alarms_list}    Create List
    Run Keyword If   '${vCUorvDU}'=='vCU'   Get Unexpected Active And Historical Alarms On vCU
    ...       ELSE                          Get Unexpected Active And Historical Alarms On vDU
    Checking If Alarm Is On The Allowed List
    ...    alarms=@{active_alarms['alarms']}    fault_id=fault_id    fault_name=fault_name
    ...    alowed_alarms_list=${${vCUorvDU}_ALLOWED_ALARMS}    name_list=${Not_allowed_active_alarms_list}
    Checking If Alarm Is On The Allowed List
    ...    alarms=@{historic_alarms['alarms']}   fault_id=fault_id   fault_name=fault_name
    ...    alowed_alarms_list=${${vCUorvDU}_ALLOWED_HISTORICAL_ALARMS}    name_list=${Not_allowed_history_alarms_list}
    ${no_active_alarms}     Run Keyword And Return Status    Should Be Empty    ${Not_allowed_active_alarms_list}
    ${no_history_alarms}    Run Keyword And Return Status    Should Be Empty    ${Not_allowed_history_alarms_list}
    Set Variables Before Or After Snapshot Collection    ${Not_allowed_active_alarms_list}    ${Not_allowed_history_alarms_list}    ${before_after}
    ${res_bool_active}    ${res_bool_history}    Run Keyword If    '${before_after}'=='after'    Check If Lists Are Equal
    Log Active And Historical Alarms    vCUorvDU=${vCUorvDU}
    ...                                 before_after=${before_after}
    ...                                 no_active_alarms=${no_active_alarms}
    ...                                 no_history_alarms=${no_history_alarms}
    ...                                 res_bool_active=${res_bool_active}
    ...                                 res_bool_history=${res_bool_history}
    ...                                 Not_allowed_active_alarms_list=${Not_allowed_active_alarms_list}
    ...                                 Not_allowed_history_alarms_list=${Not_allowed_history_alarms_list}

Log Active And Historical Alarms
    [Arguments]    ${vCUorvDU}    ${before_after}    ${no_active_alarms}    ${no_history_alarms}    ${res_bool_active}    ${res_bool_history}
    ...            ${Not_allowed_active_alarms_list}   ${Not_allowed_history_alarms_list}
    ${log_history_alarm}=   Evaluate
    ...   ('${before_after}'=='before' and '${no_history_alarms}'=='False') or ('${before_after}'=='after' and '${res_bool_history}'=='False')
    ${log_active_alarm}=   Evaluate
    ...   ('${before_after}'=='before' and '${no_active_alarms}'=='False') or ('${before_after}'=='after' and '${res_bool_active}'=='False')
    Run Keyword If    ${log_history_alarm}
    ...               Log Alarms List To Console
    ...               alarms_list=${Not_allowed_history_alarms_list}
    ...               msg=Not allowed Historic Alarms appeared appeared on ${vCUorvDU}
    Run Keyword If   ${log_active_alarm}
    ...               Log Alarms List To Console
    ...               alarms_list=${Not_allowed_active_alarms_list}
    ...               msg=Not allowed Active Alarms appeared appeared on ${vCUorvDU}
    Run Keyword If    '${before_after}'=='after' and ('${res_bool_history}'=='False' or '${res_bool_active}'=='False')
    ...               Set Suite Variable  ${no_alarm_after_snapshot}  False
    Run Keyword If    ${log_history_alarm} or ${log_active_alarm}    FAIL

Check If Lists Are Equal
    [Documentation]    Check if alarm lists before and after snapshot collection are equal
    ${res_bool_active}     Run Keyword And Return Status    Lists Should Be Equal
    ...                    ${Not_allowed_active_alarms_list_before}    ${Not_allowed_active_alarms_list_after}
    ${res_bool_history}    Run Keyword And Return Status    Lists Should Be Equal
    ...                    ${Not_allowed_history_alarms_list_before}    ${Not_allowed_history_alarms_list_after}
    RETURN    ${res_bool_active}    ${res_bool_history}

Set Variables Before Or After Snapshot Collection
    [Arguments]          ${Not_allowed_active_alarms_list}    ${Not_allowed_history_alarms_list}    ${before_after}
    Set Test Variable    ${Not_allowed_active_alarms_list_${before_after}}     ${Not_allowed_active_alarms_list}
    Set Test Variable    ${Not_allowed_history_alarms_list_${before_after}}    ${Not_allowed_history_alarms_list}

Log Alarms List To Console
    [Arguments]          ${alarms_list}    ${msg}
    Log To Console   \n - ${msg}:
    FOR    ${alarm}    IN     @{alarms_list}
        Log to Console     ${alarm}
    END

Checking If Alarm Is On The Allowed List
    [Arguments]    ${alarms}    ${fault_id}    ${alowed_alarms_list}    ${fault_name}=faultName    ${name_list}=${not_allowed_alarms}
    ${moxa_ip_addr}     Get Variable Value    ${tl.custom['moxa_ip_addr']}    None
    ${moxa_port}        Get Variable Value    ${tl.custom['moxa_port']}    None
    ${cloud_fault23_cleared_time}=    get_fault_time_for_cloud    alarm_dict=@{alarms}    fault_id=23    time_key=cleared_time
    FOR    ${alarm}    IN    @{alarms}
        ${fault_id_final}      Set Variable If    '${alarm['${fault_id}']}'=='N/A'      alarm_id      ${fault_id}
        ${fault_name_final}    Set Variable If    '${alarm['${fault_name}']}'=='N/A'    alarm_name    ${fault_name}
        ${dict_fault_id}       Get From Dictionary    ${alarm}    ${fault_id_final}
        ${dict_fault_id}       Convert To String      ${dict_fault_id}
        ${msg_alarm}           assemble_msg_alarm     ${alarm}    ${fault_id_final}    ${fault_name_final}
        ${fault_is_allowed}        Run Keyword And Return Status    List Should Contain Value    ${alowed_alarms_list}    ${dict_fault_id}
        IF    not ${fault_is_allowed}
            ${vDU_build_flag}    Get Variable Value    ${vDU_build_flag}    ${False}
            IF    '${dict_fault_id}' == '4681'
                ${fault_is_allowed}    check_fault_4681_is_valid    ${alarm}
            ELSE IF    '${dict_fault_id}' == '4675'
                ${cloud_fault23_cleared_time}=    get_fault_time_for_cloud    alarm_dict=@{alarms}    fault_id=23    time_key=cleared_time
                ${fault_is_allowed}    is_fault4675_allowed    ${alarm}    ${cloud_fault23_cleared_time}
            ELSE IF    '${dict_fault_id}' == '4590' and ${vDU_build_flag}
                # details refer to QT-3382
                ${CCR_Fallback}    Get Variable Value    ${CCR_Fallback}    ${False}
                ${fault_is_allowed}    is_fault4590_allowed    ${alarm}    ${CCR_Fallback}
            ELSE IF        '${moxa_ip_addr}'!='None' and '${moxa_port}'!='None' and '${dict_fault_id}' == '4334'
                ${fault_is_allowed}    Set Variable    ${True}
            END
            IF    ${vDU_build_flag}
                ${aic_commission_tc_status}    get test case status by name    AIC Commission via REST API
                ${aic_deploy_tc_status}    get test case status by name    AIC deployment
                ${aic_additional_reset_tc_status}    get test case status by name    Additional Site Reset
                IF    '${aic_commission_tc_status}' != 'NA' or '${aic_deploy_tc_status}' != 'NA' or '${aic_additional_reset_tc_status}' != 'NA'
                    IF    '${dict_fault_id}' in ${vDU_ALLOWED_HISTORICAL_ALARMS_BY_TIME}.keys()
                        ${expected_cleanup_time}    Set Variable    ${vDU_ALLOWED_HISTORICAL_ALARMS_BY_TIME['${dict_fault_id}']}
                        ${vDU_fault_appear_time}
                        ...    get_fault_time_for_cloud    alarm_dict=@{alarms}    fault_id=${dict_fault_id}    time_key=appear_time
                        ${vDU_fault_cleared_time}
                        ...    get_fault_time_for_cloud    alarm_dict=@{alarms}    fault_id=${dict_fault_id}    time_key=cleared_time
                        ${fault_is_allowed}    is_cloud_alarm_expected_by_compare_time
                        ...    ${vDU_fault_appear_time}    ${vDU_fault_cleared_time}    ${expected_cleanup_time}
                    END
                END
                ${FHGW_update}    Get Variable Value    ${FHGW_update}    ${False}
                ${condition}    Catenate    ('${dict_fault_id}'=='1806' and "RMOD" in "${alarm["alarming_object"]}" and '${is_TDD}' == 'False')
                ...    or ('${dict_fault_id}'=='10' and ${FHGW_update} and '${is_TDD}' == 'False')
                ${FHGW_snapshot_condition}    Evaluate    ${condition}
                IF    not ${fault_is_allowed} and ${FHGW_snapshot_condition}
                    Set Suite Variable    ${FHGW_SNAPSHOT}    ${True}
                END
            END
        END
        Run Keyword If        '${fault_is_allowed}'=='False'    Append To List    ${name_list}    ${msg_alarm}
    END

Check Alarms In Ims File Common TS
    [Arguments]    ${reset_infomodel}=False     ${disconnect_infomodel}=False    ${name}=_    ${alias}=default    ${ims_log_dir}=${EMPTY}
    ${timestamp}    Get Timestamp
    Run Keyword And Continue On Failure    Check GPS Receiver Alarm    check_times=15
    Collect Infomodel Logs    ${ims_log_dir}    ${name}    ${timestamp}    ${alias}
    Check If Object Alarm_L Exist
    Modify Allowed Alarms List    name=${name}
    ${alarms_ims}    ${reset_history}    ${Not_allowed_active_alarms_ims}    ${Not_allowed_history_alarms_ims}
    ...    Check Alarms    ${ims_log_dir}    ${name}    ${timestamp}
    Log To Console Not Allowed Alarms    ${name}     ${Not_allowed_active_alarms_ims}    ${Not_allowed_history_alarms_ims}
    ...                                  ${reset_history}
    [Teardown]     Run Keyword if    ${disconnect_infomodel}    Run Keywords    Disconnect Infomodel    alias=${alias}
    ...            AND               Teardown Infomodel    alias=${alias}
    ...            ELSE IF           ${reset_infomodel}    Reset Infomodel       alias=${alias}

Log To Console Not Allowed Alarms
    [Arguments]    ${name}     ${Not_allowed_active_alarms_ims}    ${Not_allowed_history_alarms_ims}    ${reset_history}
    ${no_active_alarms}     Run Keyword And Return Status    Should Be Empty    ${Not_allowed_active_alarms_ims}
    ${no_history_alarms}    Run Keyword And Return Status    Should Be Empty    ${Not_allowed_history_alarms_ims}
    ${no_reset}             Run Keyword And Return Status    Should Be Empty    ${reset_history}
    IF    (not ${no_active_alarms} and '${name}'!='_before_TEST_') or not ${no_history_alarms}
        TRY
            ${alarms_ims_before_test}    ${reset_history_before_test}
            ...    ${Not_allowed_active_taf_alarms_ims_before_test}    ${Not_allowed_taf_history_alarms_ims_before_test}
            ...    Check Alarms    ${taf_ims_before_test}    before_test    ${EMPTY}
            ${not_allowed_alarm_appeared_before_test_details}    Combine Lists
            ...    ${Not_allowed_active_taf_alarms_ims_before_test}
            ...    ${Not_allowed_taf_history_alarms_ims_before_test}
            ${not_allowed_alarms_name}    Create List    active    history
            FOR    ${alarms_name}    IN    @{not_allowed_alarms_name}
                ${not_allowed_alarm_before_test}    Get Variable Value
                ...    ${not_allowed_${alarms_name}_alarm_before_test}    ${EMPTY}
                ${type}    Evaluate    type($not_allowed_alarm_before_test)
                IF    "${type}" != "<class 'list'>"
                    ${not_allowed_alarm_before_test}    Convert to List
                    ...    ${not_allowed_alarm_before_test}
                END
                ${not_allowed_alarm_appeared_before_test_details}    Combine Lists
                ...    ${not_allowed_alarm_appeared_before_test_details}    ${not_allowed_alarm_before_test}
            END
            IF    not ${no_active_alarms}
                Clear Previous Alarms
                ...    Not_allowed_ims_after_test=${Not_allowed_active_alarms_ims}
                ...    Not_allowed_ims_before_test=${not_allowed_alarm_appeared_before_test_details}
            END
            IF     not ${no_history_alarms}
                Clear Previous Alarms
                ...    Not_allowed_ims_after_test=${Not_allowed_history_alarms_ims}
                ...    Not_allowed_ims_before_test=${not_allowed_alarm_appeared_before_test_details}
            END
        EXCEPT    AS    ${error}
            Log    \nError occurred during checking taf ims collected before test: ${error}    WARN
        END
        ${no_active_alarms}     Run Keyword And Return Status    Should Be Empty    ${Not_allowed_active_alarms_ims}
        ${no_history_alarms}    Run Keyword And Return Status    Should Be Empty    ${Not_allowed_history_alarms_ims}
    END
    IF    not ${no_active_alarms}
        Log To Console    \nNot allowed Active Alarms appeared:
        List Not Allowed Alarms    ${Not_allowed_active_alarms_ims}
        IF    not ${no_reset}
            List Not Allowed Alarms    ${reset_history}
        END
        IF    '${name}'=='_before_TEST_'
            Log    The alarms listed here occurs before gnb installation and so error is ignored!!!\n\n    console=True
            Set Suite Variable    ${not_allowed_active_alarm_before_test}    ${Not_allowed_active_alarms_ims}
        ELSE
            ${snapshot_rmods}    get_rdc_snapshot_rmods    rdc_fid_list=${RDC_FID_LIST}    active_alarms=${Not_allowed_active_alarms_ims}
            IF    ${snapshot_rmods}
                RDC Snapshot    fid_trig_snapshot=${TRUE}  rmod_with_fid_list=${snapshot_rmods}
            END
        END
    END
    IF    not ${no_history_alarms}
        Log To Console  \nNot allowed Historic Alarms appeared:
        List Not Allowed Alarms    ${Not_allowed_history_alarms_ims}
        IF    '${name}'=='_before_TEST_'
            Log    The alarms listed here occurs before gnb installation and so error is ignored!!!\n\n    console=True
            Set Suite Variable    ${not_allowed_history_alarm_before_test}    ${Not_allowed_history_alarms_ims}
        END
    END
    ${condition}      Catenate    ('${no_active_alarms}'=='False' or '${no_history_alarms}'=='False') and
    ...                           '${name}'!='_before_TEST_' and '${name}'!='_all_test_'
    ${condition_2}    Catenate    ('${no_active_alarms}'=='False' or '${no_history_alarms}'=='False')
    ${log_alarm_condition}        Evaluate    ${condition}
    Run Keyword If    ${log_alarm_condition}    Run Keywords    Set Suite Variable    ${not_allowed_alarm_appeared_in_previous_test_case}    ${True}
    ...        AND    Fail
    ...    ELSE IF    ${condition_2} and '${name}'=='_all_test_' and '${not_allowed_alarm_appeared_in_previous_test_case}'=='False'
    ...               Log    The alarms listed here occurs during whole test, please check!    console=True

Check GPS Receiver Alarm
    [Arguments]    ${skip_coam_connection_setup}=${False}    ${check_times}=6    ${gps_status_check_after_firmware_upgrade}=${True}
    IF    not ${skip_coam_connection_setup}
        ${connection}    Run Keyword And Return Status    WA for coam connect    bts_host=192.168.255.129
    ELSE
        ${connection}    Set Variable    ${True}
    END
    ${verify_bts_startup_tc_status}    get test case status by name    Verify BTS Startup
    IF    '${verify_bts_startup_tc_status}' == 'PASS' or '${verify_bts_startup_tc_status}' == 'FAIL'
        ${verify_bts_startup_tc_status}
        ...    get test case status by name
        ...    Verify BTS Startup After Commissioning
    END
    IF    ${connection}
        FOR    ${i}    IN RANGE    0    ${check_times}
            ${is_4420_alarm_not_exists}    Check if FID 4420 Not Exists
            ...            host=192.168.255.129    skip_coam_connection_setup=${True}
            IF    ${is_4420_alarm_not_exists}
                IF   ${i}==0
                    RETURN
                ELSE IF   ${gps_status_check_after_firmware_upgrade}
                    Log To Console    -> Start to check GPS and TOPP status after GPS firmware upgrade finished
                    Set gnss_update_before_rf_detection as Suite Variable    ${verify_bts_startup_tc_status}
                    Wait Until Keyword Succeeds    8min    20s    Verify time synchronization (GPS+TOPP)
                    ...          topp_check_need=${False}
                    Log To Console    -> GPS status is OK
                    RETURN
                ELSE
                    Log To Console    -> GPS firmware upgrade finished, skip GPS status check!
                    Set gnss_update_before_rf_detection as Suite Variable    ${verify_bts_startup_tc_status}
                    RETURN
                END
            ELSE IF    ${i}==${${check_times}-1}
                Set gnss_update_before_rf_detection as Suite Variable    ${verify_bts_startup_tc_status}
                Fail    -> GPS firmware upgrade doesn't finish in time, please check!
            ELSE
                BuiltIn.Sleep    120s
            END
        END
    END

Set gnss_update_before_rf_detection as Suite Variable
    [Arguments]    ${verify_bts_startup_tc_status}
    ${gnss_update_before_rf_detection_not_exists}
    ...    Run Keyword And Return Status
    ...    Variable Should Not Exist    ${gnss_update_before_rf_detection}
    IF    ${gnss_update_before_rf_detection_not_exists} and '${verify_bts_startup_tc_status}'=='RUNNING'
        Set Suite Variable    ${gnss_update_before_rf_detection}    ${True}
    END

Check Alarms
    [Arguments]    ${ims_log_dir}    ${name}    ${timestamp}
    @{reset_history}    Create List
    &{Not_allowed_active_alarms_dict}    Create Dictionary
    &{Not_allowed_history_alarms_dict}    Create Dictionary
    @{alarms_ims}    Create List
    @{ims_log_path_list}    Create List
    IF    '.ims' not in '${ims_log_dir}'
        Append To List
        ...    ${ims_log_path_list}
        ...    ${OUTPUT_DIR}/${ims_log_dir}${tl.tl_cloud_topology}_${loadBuild}${name}admin_infomodel_${timestamp}.ims2
        IF    'before' not in '${name}'
            Append To List
            ...    ${ims_log_path_list}
            ...    ${OUTPUT_DIR}/${ims_log_dir}${tl.tl_cloud_topology}_${loadBuild}${name}taf_${timestamp}.ims2
        ELSE
            Set Suite Variable
            ...    ${taf_ims_before_test}
            ...    ${OUTPUT_DIR}/${ims_log_dir}${tl.tl_cloud_topology}_${loadBuild}${name}taf_${timestamp}.ims2
        END
    ELSE
        Append To List    ${ims_log_path_list}    ${ims_log_dir}
    END
    FOR    ${ims_log_path}    IN    @{ims_log_path_list}
        Check Alarms in Common Test
        ...    ${ims_log_path}
        ...    allowed_alarms=${CLASSICAL_ALLOWED_ACITVE_ALARMS}
        ...    name=${name}
        ...    ims_log_dir=${ims_log_dir.replace('.ims', '_')}
        ...    Not_allowed_active_alarms_dict=${Not_allowed_active_alarms_dict}
        ...    Not_allowed_history_alarms_dict=${Not_allowed_history_alarms_dict}
        ...    alarms_ims=${alarms_ims}
        ...    reset_history=${reset_history}
    END
    ${Not_allowed_active_alarms_ims}     Get Dictionary Values    ${Not_allowed_active_alarms_dict}
    ${Not_allowed_history_alarms_ims}    Get Dictionary Values    ${Not_allowed_history_alarms_dict}
    RETURN    ${alarms_ims}    ${reset_history}    ${Not_allowed_active_alarms_ims}    ${Not_allowed_history_alarms_ims}

Modify Allowed Alarms List
    [Arguments]    ${name}
    ${ue_type}        Get Variable Value    ${tl.ues[0].ue_type}    default
    ${is_ASOG_A101}      Get Variable Value    ${is_ASOG_A101}    ${False}
    ${cellConfiguration}     Get Variable Value     ${cellConfiguration}    ${EMPTY}
    IF    '${ue_type}'=='cus'
        Append To List    ${CLASSICAL_ALLOWED_ACITVE_ALARMS}    6202
        Append To List    ${CLASSICAL_ALLOWED_HISTORICAL_ALARMS}    6202
    END
    IF    '5G_NSA' in '${cellConfiguration}' and '_4G_' in '${cellConfiguration}'
        Append To List    ${CLASSICAL_ALLOWED_HISTORICAL_ALARMS}    6327
    END
    IF    ${is_ASOG_A101}       #WA for FID 61675 on A101 ASOG/H - FOT - CB013432-SR
        Append To List    ${CLASSICAL_ALLOWED_ACITVE_ALARMS}    61675
        Append To List    ${CLASSICAL_ALLOWED_HISTORICAL_ALARMS}    61675
    END
    IF   ${dualcore} and '${name}'=='_after_installation_gNB_package_'
        ${board_conf_after_sw_update}    Check Board Configuration
        ${board_conf_condition}    Evaluate    ${board_conf_before_sw_update}==${board_conf_after_sw_update}
        IF    not ${board_conf_condition}
            Append To List    ${CLASSICAL_ALLOWED_ACITVE_ALARMS}        4367
            Append To List    ${CLASSICAL_ALLOWED_HISTORICAL_ALARMS}    4367
        END
    END

Collect Infomodel Logs
    [Arguments]    ${ims_log_dir}    ${name}    ${timestamp}    ${alias}
    Save Infomodel Log    ${OUTPUT_DIR}/${ims_log_dir}${tl.tl_cloud_topology}_${loadBuild}${name}admin_infomodel_${timestamp}.ims2
    ...                   timeout=180    alias=${alias}
    Wait Until Keyword Succeeds    5x    15s    coam.connect to
    ...    bts_host=${LMP_IP}
    ...    update_interval=1000
    ...    name=ims_admin
    Wait Until Keyword Succeeds    3x  20s    coam.Collect IM Snapshot
    ...    target_file_name=${OUTPUT_DIR}/${ims_log_dir}${tl.tl_cloud_topology}_${loadBuild}${name}taf_${timestamp}.ims2
    ...    alias=ims_admin
    [Teardown]    coam.teardown    connection=ims_admin

Setup And Connect IM
    [Arguments]    ${setup_timeout}=30    ${connect_timeout}=90    ${alias}=default
    Setup Infomodel      address=192.168.255.129    port=443
    ...                  admin_api_log_dir=${OUTPUT DIR}/Additional_Execution_Logs/ADMIN_INFOMODEL_API
    ...                  timeout=${setup_timeout}      alias=${alias}
    Connect Infomodel    timeout=${connect_timeout}    alias=${alias}

Read Ims File in Common Test
    [Arguments]    ${IMS_FILE}    ${allowed_alarms}    ${Not_allowed_active_alarms_dict}    ${Not_allowed_history_alarms_dict}    ${alarms_ims}
    ...            ${reset_history}
    ${alarm_query}    Set Variable If  ${alarm_l_exists}    //ALARM_L-*    //ALARM-*
    @{alarm_change_sets}=  Get Change Sets  ${IMS_FILE}  ${alarm_query}
    FOR   ${alarm_change_set}  IN  @{alarm_change_sets}
       Run Keyword If   '${alarm_query}' == '//ALARM_L-*'  Get All Not Allowed Alarms
       ...               alarm_query=${alarm_query}
       ...               allowed_alarms=${allowed_alarms}
       ...               list_of_alarms=${alarm_change_set}
       ...               Not_allowed_active_alarms_dict=${Not_allowed_active_alarms_dict}
       ...               Not_allowed_history_alarms_dict=${Not_allowed_history_alarms_dict}
       ...               alarms_ims=${alarms_ims}
       ...               reset_history=${reset_history}
       Run Keyword If   '${alarm_query}' == '//ALARM-*'    Get All Not Allowed Alarms
       ...               alarm_query=${alarm_query}
       ...               allowed_alarms=${allowed_alarms}
       ...               list_of_alarms=${alarm_change_set}
       ...               Not_allowed_active_alarms_dict=${Not_allowed_active_alarms_dict}
       ...               Not_allowed_history_alarms_dict=${Not_allowed_history_alarms_dict}
       ...               alarms_ims=${alarms_ims}
       ...               reset_history=${reset_history}
    END

Check If Object Alarm_L Exist
    ${alarm_l_exists}       Run Keyword And Return Status    Query Infomodel    query=//ALARM_L-*    timeout=1
    ${alarm_l_not_exist}    Run Keyword And Return Status    Query Infomodel    query=//ALARM-*      timeout=1
    Log    ${alarm_l_exists}
    Log    ${alarm_l_not_exist}
    BuiltIn.Set Global Variable    ${alarm_l_exists}
    BuiltIn.Set Global Variable    ${alarm_l_not_exist}

Check Alarms in Common Test
    [Arguments]    ${ims_file}    ${allowed_alarms}    ${name}    ${ims_log_dir}    ${Not_allowed_active_alarms_dict}
    ...            ${Not_allowed_history_alarms_dict}    ${alarms_ims}    ${reset_history}
    Read Ims File in Common Test  ${ims_file}    ${allowed_alarms}    Not_allowed_active_alarms_dict=${Not_allowed_active_alarms_dict}
    ...            Not_allowed_history_alarms_dict=${Not_allowed_history_alarms_dict}    alarms_ims=${alarms_ims}    reset_history=${reset_history}
    ${name}=    Strip String	 ${name}    characters=_
    Save Alarms To File  file_name=${OUTPUT_DIR}/${ims_log_dir}alarms_${name}.txt  list_of_alarms=@{alarms_ims}

Clear Previous Alarms
    [Documentation]     As taf library will collect ims log which includes all previous alarms, this keyword is usded to clear alarms before test
    [Arguments]         ${Not_allowed_ims_after_test}    ${Not_allowed_ims_before_test}
    FOR    ${previous_alarm}    IN     @{Not_allowed_ims_before_test}
        ${matches}=    Get Matches    ${Not_allowed_ims_after_test}    ${previous_alarm}*
        ${matches_result}=    Run Keyword And Return Status    Should Not Be EMPTY    ${matches}
        Run Keyword If   ${matches_result}  Remove Values From List     ${Not_allowed_ims_after_test}    ${matches[0]}
    END

Check if FID 4420 Not Exists
    [Arguments]          ${host}=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}
    ...                  ${skip_coam_connection_setup}=${False}
    ${is_4420_alarm_not_exists}    Set Variable    ${True}
    TRY
        Run Keyword If    not ${skip_coam_connection_setup}    WA for coam connect    bts_host=${host}
        ${active_alarms}          coam.get_active_alarms    connection=coam_admin
        FOR    ${alarm}    IN    @{active_alarms}
           ${fault_id_final}    set variable if    '${alarm['faultId']}'=='N/A'    alarm_id    faultId
           ${dict_fault_id}      Get From Dictionary       ${alarm}   ${fault_id_final}
           ${dict_fault_id}    Convert To String    ${dict_fault_id}
           ${is_4420_alarm_not_exists}=  Run keyword and return status   should not be equal as integers   ${dict_fault_id}  4420
           Run Keyword If   '${is_4420_alarm_not_exists}'=='False'  Run Keywords
           ...   Log To Console  -> GPS firmware upgrade is ongoing!
           ...   AND   should not be equal as integers   ${dict_fault_id}  4420
        END
    EXCEPT    AS    ${error}
        Log    -> Check if FID 4420 not exists failed due to ${error}    WARN
    END
    RETURN    ${is_4420_alarm_not_exists}
    [Teardown]  Run Keyword If    not ${skip_coam_connection_setup}
    ...         Run Keyword and ignore error    coam.teardown    connection=${connection}

List Not Allowed Alarms
    [Arguments]       ${Not_allowed_alarms_ims}=${Not_allowed_alarms_ims}
    ${NODE_NAME}    Get Variable Value    ${NODE_NAME}    ${EMPTY}
    Remove Duplicates    ${Not_allowed_alarms_ims}
    Sort List    ${Not_allowed_alarms_ims}
    FOR  ${obj}  IN  @{Not_allowed_alarms_ims}
       Log   ${obj}   WARN
       IF    'FaultId: 7107' in '''${obj}''' and '4G' not in '${NODE_NAME}'
           Collect enb log via OAM IP
        END
    END

Retrieve faultID from Active alarm
    [Documentation]     It is used to get faulid for alarm query with action Remove
    [Arguments]   ${Not_allowed_active_alarms_dict}   ${alarm_distname}
    ${fault}    Get From Dictionary     ${Not_allowed_active_alarms_dict}   ${alarm_distname}
    ${faultId}=    Get Regexp Matches    ${fault}    FaultId: [\\d]+
    ${faultId}=    Split String    ${faultId[0]}    ${SPACE}
    RETURN    ${faultId[1]}

Get All Not Allowed Alarms
    [Arguments]   ${alarm_query}   ${allowed_alarms}     ${list_of_alarms}    ${Not_allowed_active_alarms_dict}
    ...            ${Not_allowed_history_alarms_dict}    ${alarms_ims}    ${reset_history}
    ${alarm_action}       Set Variable    ${list_of_alarms.action}
    ${alarm_timestamp}    Set Variable    ${list_of_alarms.timestamp}
    ${alarm_distname}     Set Variable    ${list_of_alarms.object.dist_name}
    ${alarm_detail}    Set Alarm variable
    ...    alarm_action=${alarm_action}
    ...    list_of_alarms=${list_of_alarms}
    ...    alarm_object=object.alarmText.alarmDetail
    ...    alarm_l_object=object.alarmInformation.alarmText.alarmDetail
    ...    alarm_query=${alarm_query}
    ${remove_flag}    Run Keyword And Return Status    Dictionary Should Contain Key    ${Not_allowed_active_alarms_dict}   ${alarm_distname}
    ${faultId}    Set Alarm variable
    ...    alarm_action=${alarm_action}
    ...    list_of_alarms=${list_of_alarms}
    ...    alarm_object=object.faultId
    ...    alarm_l_object=object.alarmInformation.faultId
    ...    alarm_query=${alarm_query}
    ${faultId}    Run Keyword If    '${alarm_action}'=='Remove' and ${remove_flag}
    ...    Retrieve faultID from Active alarm     ${Not_allowed_active_alarms_dict}   ${alarm_distname}
    ...    ELSE   Set Variable    ${faultId}
    ${alarm_source}    Set Alarm Variable
    ...    alarm_action=${alarm_action}
    ...    list_of_alarms=${list_of_alarms}
    ...    alarm_object=object.alarmingResourceDN
    ...    alarm_l_object=?
    ...    alarm_query=${alarm_query}
    ${alarm_additionalInfo}      Run Keyword If    '${faultId}' == '4681'
    ...    Set Alarm Variable
    ...    alarm_action=${alarm_action}
    ...    list_of_alarms=${list_of_alarms}
    ...    alarm_object=object.alarmText.alarmAdditionalInfo
    ...    alarm_l_object=object.alarmInformation.alarmText.alarmAdditionalInfo
    ...    alarm_query=${alarm_query}
    Run Keyword And Ignore Error    log    ${list_of_alarms.object}
    ${alarm_faultSignature}    Get Fault Signature Details For 4590    ${alarm_action}    ${list_of_alarms}    ${alarm_query}    ${faultId}
    ${is_active_alarm_not_allowed}    ${is_history_alarm_not_allowed}    Verify If Alarm Is Allowed
    ...    ${alarm_additionalInfo}    ${allowed_alarms}    ${faultId}
    ${msg_alarm}=    Run Keyword If  '${alarm_action}'=='Update'   Catenate  Alarm: ${alarm_detail}   --FaultId:  ${faultId}
    ${msg_update}=   Run Keyword If  '${alarm_action}'=='Update'   Catenate  Alarm:  ${alarm_detail}  --FaultId:  ${faultId}
    ...                   --alarmingResource:  ${alarm_source} was raised at ${alarm_timestamp}
    ${msg_remove}=    Run Keyword If    ${remove_flag}
    ...    Get From Dictionary    ${Not_allowed_active_alarms_dict}   ${alarm_distname}
    Run Keyword If    '${alarm_action}'=='Update'    Append To List    ${alarms_ims}    ${msg_alarm}
    ${4681_summary}    Get Variable Value    ${4681_summary}    ${EMPTY}
    ${alarm_faultSignature_check}       Replace String    ${alarm_faultSignature}    \n    ${SPACE}
    ${is_4590_not_allowed}     Evaluate    'category:POWER_OFF' not in '${alarm_faultSignature_check}'
    IF    '${alarm_action}'=='Update' and ${is_active_alarm_not_allowed}
        IF    '${faultId}' == '4681'
            Set To Dictionary    ${Not_allowed_active_alarms_dict}   ${alarm_distname}=${msg_update}, ${4681_summary}
        ELSE IF    '${faultId}' == '4590' and ${is_4590_not_allowed}
            Set To Dictionary    ${Not_allowed_active_alarms_dict}   ${alarm_distname}=${msg_update}\n ${alarm_faultSignature}\n
        ELSE IF    '${faultId}' == '4590' and '${is_4590_not_allowed}'=='False'
            Log to Console    \nNote: Fault4590 with category:POWER_OFF is allowed after POWER ON or POWER RESET!
        ELSE
            Set To Dictionary    ${Not_allowed_active_alarms_dict}   ${alarm_distname}=${msg_update}
        END
    ELSE IF    '${alarm_action}'=='Remove' and ${remove_flag} and ${is_active_alarm_not_allowed}
        IF    ${is_history_alarm_not_allowed}
            ${set_history_alarm_flag}     Set Variable      ${True}
            IF    '${faultId}' == '10'
                ${gnss_update_before_rf_detection}    Get Variable Value    ${gnss_update_before_rf_detection}    ${False}
                ${FRGU_ID}    Get Variable Value    ${FRGU_ID}    ${EMPTY}
                IF    ${gnss_update_before_rf_detection} and '${FRGU_ID}'!=''
                    ${rmod_match}    Get Regexp Matches    ${msg_remove}    ${FRGU_ID.split('/')[-1]}
                    IF    ${rmod_match}
                        Log to Console
                        ...    \nNote: Fault10 is expected on FRGU if GNSS update occurs after sw installation! Details refer to PR832766!
                        ${set_history_alarm_flag}     Set Variable      ${False}
                    END
                END
            END
            IF    ${set_history_alarm_flag}
                Set To Dictionary    ${Not_allowed_history_alarms_dict}    ${alarm_distname}=${msg_remove} and it was canceled at ${alarm_timestamp}
            END
            Remove From Dictionary  ${Not_allowed_active_alarms_dict}    ${alarm_distname}
        ELSE
            Remove From Dictionary  ${Not_allowed_active_alarms_dict}    ${alarm_distname}
        END
    END
    ${is_alarm_active}=    Run Keyword And Return Status    Should Not Be Empty    ${Not_allowed_active_alarms_dict}
    Run Keyword If    '${alarm_action}'=='Reset' and ${is_alarm_active}
    ...    Append To List    ${reset_history}    Reset was triggered at ${alarm_timestamp}, previous active alarm may disappear!!!

Verify If Alarm Is Allowed
    [Arguments]    ${alarm_additionalInfo}    ${allowed_alarms}    ${faultId}
    ${is_active_alarm_allowed}=    Check Alarm_Query Allowed Alarms in Common TS
    ...    faultId=${faultId}    alarm_additionalInfo=${alarm_additionalInfo}    allowed_alarms=${allowed_alarms}
    ${is_active_alarm_not_allowed}=   Evaluate    '${is_active_alarm_allowed}'=='FAIL' or '${is_active_alarm_allowed}'=='False'
    ${is_history_alarm_allowed}=    Check Alarm_Query Allowed Alarms in Common TS
    ...    faultId=${faultId}    alarm_additionalInfo=${alarm_additionalInfo}    allowed_alarms=${CLASSICAL_ALLOWED_HISTORICAL_ALARMS}
    ${is_history_alarm_not_allowed}=    Evaluate    '${is_history_alarm_allowed}'=='FAIL' or '${is_history_alarm_allowed}'=='False'
    RETURN    ${is_active_alarm_not_allowed}    ${is_history_alarm_not_allowed}

Get Fault Signature Details For 4590
    [Arguments]    ${alarm_action}    ${list_of_alarms}    ${alarm_query}    ${faultId}
    ${alarm_faultSignature}    Run Keyword If
    ...    '${faultId}' == '4590' and '${alarm_query}'=='//ALARM-*' and '${alarm_action}'=='Update'
    ...    Get Fault Signature Details    ${list_of_alarms.object.alarmText.alarmAdditionalInfo.faultSignature}
    ...    ELSE IF    '${faultId}' == '4590' and '${alarm_query}'=='//ALARM_L-*' and '${alarm_action}'=='Update'
    ...    Get Fault Signature Details    ${list_of_alarms.object.alarmInformation.alarmText.alarmAdditionalInfo.faultSignature}
    ...    ELSE    Set Variable    None
    RETURN    ${alarm_faultSignature}

Set Alarm Variable
    [Arguments]    ${alarm_action}    ${list_of_alarms}    ${alarm_object}    ${alarm_l_object}    ${alarm_query}
    ${alarm_variable}    Set Variable If    '${alarm_query}'=='//ALARM_L-*' and '${alarm_l_object}' == '?'    ?
    ...                 '${alarm_query}'=='//ALARM-*' and '${alarm_action}'=='Update'      ${list_of_alarms.${alarm_object}}
    ...                 '${alarm_query}'=='//ALARM_L-*' and '${alarm_action}'=='Update'    ${list_of_alarms.${alarm_l_object}}
    RETURN    ${alarm_variable}

Get Fault Signature Details
    [Arguments]    ${dict}
    ${fault_signature}=    Create list
    ${items}    Get Dictionary Items    ${dict}
    FOR    ${key}    ${value}   IN   @{items}
       Append To List    ${fault_signature}    ${key}:${value}
    END
    ${fault_signature_str}=    Catenate    SEPARATOR=\n    @{fault_signature}
    RETURN    ${fault_signature_str}

Check Alarm_Query Allowed Alarms in Common TS
    [Arguments]   ${faultId}    ${alarm_additionalInfo}    ${allowed_alarms}
    ${faultId}    Convert to String     ${faultId}
    ${loop_status}=   Run Keyword And Return Status
    ...    List Should Contain Value    ${allowed_alarms}    ${faultId}
    ${loop_status}=   Run Keyword If    not ${loop_status} and '${faultId}' == '4681'
    ...    check_fault_4681_is_valid    ${alarm_additionalInfo}
    ...    ELSE IF    '${moxa_ip_addr}'!='None' and '${moxa_port}'!='None' and '${faultId}' == '4334'
    ...    Set Variable    ${True}
    ...    ELSE    Set Variable    ${loop_status}
    RETURN   ${loop_status}

Save Alarms To File
    [Arguments]  ${file_name}  ${list_of_alarms}
    Create File  ${file_name}
    FOR   ${alarm}   IN   @{list_of_alarms}
       Append To File  ${file_name}  content=\t${alarm}\r\n
    END

Check Active Alarms For Stop And Fix
    [Documentation]          Save active alarms to file alarms.txt
    ${ue_type}         Get Variable Value    ${tl.ues[0].ue_type}    default
    @{alarms_stop_and_fix}   Create List
    WA for coam connect      bts_host=192.168.255.129
    ${active_alarms}         coam.get_active_alarms    connection=coam_admin
    FOR    ${active_alarm}    IN    @{active_alarms}
        ${faultID}        Convert To String    ${active_alarm['faultId']}
        ${fault_msg}      Set Variable         FaultId: ${active_alarm['faultId']}, FaultName: ${active_alarm['faultName']}
        ${iphyORcus_with_FID10}=    Evaluate    '${faultID}'=='10' and '${ue_type}'=='cus'
        Run Keyword If    '${faultID}' in $STOP_AND_FIX_ALARMS and '${iphyORcus_with_FID10}'=='False'
        ...    Append To List    ${alarms_stop_and_fix}    ${fault_msg}
        Run Keyword If   '${iphyORcus_with_FID10}'=='False'    List Should Not Contain Value
        ...    ${STOP_AND_FIX_ALARMS}    ${faultID}
        ...    Stop and fix Alarm is visible: ${fault_msg}
    END
    Set Suite Variable    ${alarms_stop_and_fix}
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown    connection=coam_admin

Get Alarms Before Cloud Test
    [Documentation]  This keyword is used to get historical and active alarms before cloud test
    ${cu_historic_alarms_before_test}    Set Variable    ${EMPTY}
    ${cu_active_alarms_before_test}    Set Variable    ${EMPTY}
    ${du_historic_alarms_before_test}    Set Variable    ${EMPTY}
    ${du_active_alarms_before_test}    Set Variable    ${EMPTY}
    ${vdu_connection}    Run Keyword And Return Status    Connect To vDU    host_ip=${DU_WEBUI_IP}
    IF    not ${is_LTE}
        ${vcu_connection}    Run Keyword And Return Status    Connect To vCU
    ELSE
        ${vcu_connection}    Set Variable    False
    END
    TRY
        IF    ${vdu_connection}
            ${du_active_alarms_before_test}    Run Keyword And Continue On Failure
            ...    vdu.vdu_get_active_alarms    vdu_connection=du_admin    use_m2m=${False}
            ${du_historic_alarms_before_test}
            ...    Run Keyword And Continue On Failure
            ...    vdu.vdu_get_historical_alarms    vdu_connection=du_admin    timeout=120    use_m2m=${False}
            IF     $du_active_alarms_before_test is None
                Log    Failed to get DU active alarms!!!    WARN
            ELSE IF     ${du_active_alarms_before_test['total']} > 0
                Log only Active Alarms    ${du_active_alarms_before_test}    vDU
            END
        END
        IF    ${vcu_connection}
            ${cu_active_alarms_before_test}    Run Keyword And Continue On Failure
            ...    coam_cu.get_active_alarms    use_m2m=${False}
            ${cu_active_alarms_before_test}    remove_8000_alarm_from_cu_active_alarms    ${cu_active_alarms_before_test}
            ${cu_historic_alarms_before_test}
            ...    Run Keyword And Continue On Failure
            ...    coam_cu.Get Historical Alarms    use_m2m=${False}
            IF     $cu_active_alarms_before_test is None
                Log     Failed to get CU active alarms!!!    WARN
            ELSE IF     ${cu_active_alarms_before_test['total']} > 0
                Log only Active Alarms    ${cu_active_alarms_before_test}    vCU
            END
        END
    EXCEPT    AS    ${error}
        Log    Get alarms failed before test failed due to ${error}, continue test!!!    WARN
    END
    Set Suite Variable    ${cu_historic_alarms_before_test}
    Set Suite Variable    ${du_historic_alarms_before_test}
    Set Suite Variable    ${cu_active_alarms_before_test}
    Set Suite Variable    ${du_active_alarms_before_test}
    [Teardown]    Run Keyword And Ignore Error     Run Keywords    vdu.disconnect    vdu_connection=du_admin
    ...           AND    coam_cu.disconnect

Log Active Alarms Cloud
    [Arguments]     ${CUorDU}    ${setup_connection}=${True}
    IF    ${setup_connection}
        Wait Until Keyword Succeeds    2min  10s  vdu.connect_to
        ...    host=${${CUorDU}_WEBUI_IP}
        ...    port=${EMPTY}
        ...    username=Nemuadmin
        ...    password=Nokia@123
        ...    secure=True
        ...    connection_name=${CUorDU}_admin
        ...    timeout=30
    END
    TRY
        ${active_alarms}      vdu.vdu_get_active_alarms    vdu_connection=${CUorDU}_admin    timeout=120    use_m2m=${False}
    EXCEPT    AS    ${error}
        Log    Get active alarms failed due to ${error}, skip alarms check!!!    WARN
        ${active_alarms}    Create List
        RETURN    ${active_alarms}
    END
    ${historic_alarms}    vdu.vdu_get_historical_alarms   vdu_connection=${CUorDU}_admin   timeout=120    use_m2m=${False}
    ${historic_alarms}    remove_historic_alarms_occurs_before_test    ${${CUorDU.lower()}_historic_alarms_before_test}    ${historic_alarms}
    ${historic_alarms}    remove_active_alarms_occurs_before_test    ${${CUorDU.lower()}_active_alarms_before_test}    ${historic_alarms}
    Log To Console    --> ${CUorDU} alarms
    Log                   Active Alarms:      console=True
    FOR    ${alarm}    IN    @{active_alarms['alarms']}
           ${alarm_key}    set variable if    '${alarm['fault_id']}'=='N/A'    alarm    fault
           Log To Console     Alarm: ${alarm['${alarm_key}_id']}, ${alarm['${alarm_key}_name']}
    END
    BuiltIn.Sleep                 2
    Log                   ${\n}Historic Alarms:    console=True
    FOR    ${alarm}    IN    @{historic_alarms['alarms']}
           ${alarm_key}    set variable if    '${alarm['fault_id']}'=='N/A'    alarm    fault
           Log To Console     Alarm: ${alarm['${alarm_key}_id']}, ${alarm['${alarm_key}_name']}
    END
    Log                   ${\n}         console=True
    RETURN    ${active_alarms}
    [Teardown]    Run Keyword And Ignore Error    coam_cu.disconnect

Log Active Alarms Classical
    [Arguments]          ${host}=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}
    Wait Until Keyword Succeeds    1min  15s    coam.connect_to    bts_host=${host}   update_interval=1000   name=coam
    ${active_alarms}     coam.get_active_alarms     connection=coam
    ${historic_alarms}   coam.get_historic_alarms   connection=coam    timeout=120
    Log To Console       \n\t### Active Alarms on DU ###
    FOR   ${alarm}   IN   @{active_alarms}
        Log To Console   \t- Alarm: ${alarm['alarmId']}, Fault: ${alarm['faultId']}, ${alarm['faultName']}
    END
    BuiltIn.Sleep                2
    Log To Console       \n\t### Historic Alarms on DU ###
    FOR   ${alarm}   IN   @{historic_alarms}
        Log To Console   \t- Alarm: ${alarm['alarmId']}, Fault: ${alarm['faultId']}, ${alarm['faultName']}
    END
    Connect To Common Unit    alias=smod
    ssh.download_file    remote_path=/ram/RawAlarmHistory.txt
    ...                  local_path=${OUTPUT_DIR}/Additional_Execution_Logs/RawAlarmHistory.txt
    ...                  connection=smod
    [Teardown]    coam.teardown    connection=coam

Log only Active Alarms
    [Arguments]    ${active_alarms}    ${cu_du}
    Log    ${\n}!!!There is active alarm in ${cu_du} before test started:!!!${\n}     WARN
    FOR    ${alarm}    IN    @{active_alarms['alarms']}
           ${alarm_key}    set variable if    '${alarm['fault_id']}'=='N/A'    alarm    fault
           Log To Console     Alarm: ${alarm['${alarm_key}_id']}, ${alarm['${alarm_key}_name']}
    END
