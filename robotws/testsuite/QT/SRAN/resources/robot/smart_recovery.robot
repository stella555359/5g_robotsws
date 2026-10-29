*** Settings ***
Documentation       Robot keywords for Smart Recovery Test Case
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      taf.hw.pdu  WITH NAME   pdu
Library     ${CURDIR}/../python/str.py

Resource     ${CURDIR}/states.robot
Resource     ${CURDIR}/common.robot
Resource     ${CURDIR}/classical_keywords.robot
Resource     ${CURDIR}/additional_check.robot
Resource     ${CURDIR}/recovery.robot

*** Variables ***
@{STEPS}        coam_connect    lmp_connect    passive_sw_status    webem_status    smod_status    bbmod_status    rf_status
...             onAir_status    alarms    labPC_status    PA_status    UE_status
@{NSA_STEPS}    coam_connect_enb    smod_status_enb    bbmod_status_enb    rf_status_enb    onAir_status_enb    alarms_enb
@{JENKINS_ENVS_RECOVERY}      WORKSPACE    branch    deployment    site    NODE_NAME    hw_config    node_name_short

${TESTLINE_OFF}          ${False}
${RECOVERY}              ${False}
${SMOD_RESET}            ${False}
${SMOD_RESET_ENB}        ${False}
${SW_ROLLBACK}           ${False}
${SW_ROLLBACK_ENB}       ${False}
${RF_RESET}              ${False}
${RF_RESET_ENB}          ${False}
${COMMISSION}            ${False}
${YAFT}                  ${False}
${LMP_RECOVERY}          ${False}
${ALARM_RECOVERY_STEP}   0
${MAX_RECOVERY_TRIES}    6

${enb_host}              None
${labPC_status}          ${True}
${PA_status}             ${True}
${UE_status}             ${True}
${rf_pdu_status}         ${True}
${smod_pdu_status}       ${True}
${alarms}                ${True}
${onAir_status}          ${True}
${build_not_exists}      ${False}
@{software_update_alarms}    30    23    27    4681    4082   4083   4085    4489    4392    6929
@{software_rollback_alarms}    4383   6918   1806    1927    4748    2087    4559
@{enb_recovery_alarms}    7319    7308

*** Keywords ***
# ----------------------------------------------------------------------------------------
# ------------------------------------ SETUP & TEARDOWN ----------------------------------

Smart Recovery Suite Setup
    Set Color For Logs
    Set GNB or ENB Flag
    Set Variables For Recovery
    Set UE Type
    Run Keyword And Ignore Error    Start BTSlogs Collection
    ${UE_exist}      Run Keyword And Return Status     Should Not Be Empty    ${UEs}
    ${real_UE}    Set Variable If
    ...  '${UE_exist}' and 'cus' not in @{UEs} and 'fastmile' not in @{UEs}
    ...   True    False
    Set Suite Variable    ${real_UE}
    Modify Alarms White List
    ${attenuation_port}    Get Variable Value    ${tl.attenuation['attenuation_port']}    3001
    Set Suite Variable    ${attenuation_port}
    RUN    mkdir ${OUTPUT DIR}/Additional_Execution_Logs/

Set eNB Host For NSA
    ${enb_oam}            Get Variable Value      ${tl.enbs[0].oam_ip}
    ${enb_lmp}            Get Variable Value      ${tl.enbs[0].system_module.common_units[0].lmp_connection.addr}
    ${enb_host}           Set Variable If         '${enb_oam}'=='None'    ${enb_lmp}    ${enb_oam}
    Set Suite Variable    ${enb_host}
    Run Keyword If        '${enb_host}'=='None'   Log To Console
    ...    \n ${red}!!! Precheck for eNB will be not executed, please check init.py! !!!${rm_color} \n

Set Variables For Recovery
    ${rf_num}          Get Length            ${tl.${gnb_or_enb}s[0].dus[0].rus}
    ${smod_num}        Get Length            ${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units}
    IF    'NSA' in '${NODE_NAME}' and '4G' not in '${NODE_NAME}'
        ${is_standalone}    Set Variable    ${False}
    ELSE
        ${is_standalone}    Set Variable    ${True}
    END
    ${SBTS}            Evaluate              "ENB" in "${streamVersion}"
    ${STREAM_NUMBER}   Set Variable If       ${SBTS}    ${release}    ${streamVersion}
    ${dualcore}        Run Keyword And Return Status    Should Contain    ${NODE_NAME}    ASIM_ASIM
    ${airscale_fsmf}   Run Keyword And Return Status    Should Contain    ${NODE_NAME}    ASIB_FSMF
    ${nidd_basebuild}  Get Variable Value    ${nidd_basebuild}    ${None}
    ${nidd_ver}        Get Variable Value    ${nidd_ver}    ${EMPTY}
    Set Suite Variable    ${rf_num}
    Set Suite Variable    ${smod_num}
    Set Suite Variable    ${is_standalone}
    Set Suite Variable    ${STREAM_NUMBER}
    Set Suite Variable    ${dualcore}
    Set Suite Variable    ${airscale_fsmf}
    Set Suite Variable    ${nidd_basebuild}
    Set Suite Variable    ${nidd_ver}
    Set Suite Variable    ${loadBuild}    ${last_released_build}
    Set Suite Variable    ${vCU_build_flag}   ${False}
    Set Suite Variable    ${vDU_build_flag}   ${False}
    Set Suite Variable    ${custom_config}    ${False}
    Run Keyword If    ${is_standalone} == ${False}    Set eNB Host For NSA
    Run Keyword If    ${is_standalone} == ${False} and '${enb_host}'!='None'    Set Variables For NSA eNB

Set Variables For NSA eNB
    TRY
        ${enb_rf_num}    Get Length    ${tl.enbs[0].rms}
        Set Suite Variable    ${enb_rf_num}
    EXCEPT  AS  ${error}
        Log To Console  --> !!!Warning!!! Set NSA eNB Variables failed to ${error}
        Set Suite Variable    ${enb_rf_num}    1
    END


Modify Alarms White List
    ${moxa_ip_addr}     Get Variable Value    ${tl.custom['moxa_ip_addr']}    None
    ${moxa_port}        Get Variable Value    ${tl.custom['moxa_port']}    None
    Run Keyword If    '${moxa_ip_addr}'!='None' and '${moxa_port}'!='None'
    ...    Append To List             ${CLASSICAL_ALLOWED_ACITVE_ALARMS}    4334
    Remove Values From List    ${CLASSICAL_ALLOWED_ACITVE_ALARMS}    1898    4298
    Run Keyword If    'cus' in $UEs    Append To List    ${CLASSICAL_ALLOWED_ACITVE_ALARMS}     6202

Smart Recovery Suite Teardown
    WA for coam connect
    Stop BTSlogs Collection And Get Logs    target_path=${OUTPUT_DIR}    local_path=${tl.tl_cloud_topology}_SYSLOG_
    Save Snapshot For Classical
    [Teardown]    coam.teardown    connection=coam_admin

# ----------------------------------------------------------------------------------------
# ----------------------------------------- PRECHECK -------------------------------------

Precheck For Recovery
    [Arguments]    ${labPC_time}=5min    ${coam_time}=5min    ${lmp_time}=2min    ${smod_time}=5min     ${bbmod_time}=5min
    ...            ${rf_time}=10min      ${onair_time}=5min   ${alarm_time}=1min    ${UE_time}=2min    ${UE_ENV_check}=true
    Builtin.Set Global Variable    ${RECOVERY}    ${False}
    Log To Console                 \n \n INFO: Precheck ${gnb_or_enb}
    Verify BTS Recovery            coam_time=${coam_time}    smod_time=${smod_time}    bbmod_time=${bbmod_time}    rf_time=${rf_time}
    ...                            lmp_time=${lmp_time}
    IF    ${coam_connect}
        Check OnAir Status     onair_time=${onair_time}
        Check Alarms Status    alarm_time=${alarm_time}
        IF    ${real_UE} and '${UE_ENV_check}'=='true'
            Check LabPC Status    ${labPC_time}
            Check PA Status
            Check UE Status    UE_time=${UE_time}
        END
    END
    FOR    ${item}    IN    @{STEPS}
           Builtin.Set Global Variable    ${${item}}
           Run Keyword If                 '${${item}}'=='False'    Run Keywords
           ...                            Log    !!! Check ${item} FAILED !!!    level=WARN
           ...        AND                 Builtin.Set Global Variable    ${RECOVERY}    ${True}
    END
    Log To Console    \n \n INFO: Precheck ${gnb_or_enb} DONE
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=coam_admin

Check OnAir Status
    [Arguments]               ${name}=${EMPTY}    ${onair_time}=2min
    IF    '${name}'=='${EMPTY}'
        IF    '${rf_status}'=='True'
            ${onAir_status}           Run Keyword And Return Status   Verify OnAir    ${onair_time}
        ELSE
            ${onAir_status}           Set Variable    ${False}
        END
    ELSE
        ${onAir_status}           Run Keyword And Return Status    Verify OnAir For NSA    ${onair_time}
    END
    Log Result To Console     ${onAir_status}    onAir_status${name}

Check Alarms Status
    [Arguments]              ${alarm_time}=5min    ${bts_host}=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}    ${name}=${EMPTY}
    Log To Console           \n Check Active Alarms
    TRY
        Wait Until Keyword Succeeds    ${alarm_time}    30s
        ...                      Check Active Alarms    ${bts_host}    ${name}
    EXCEPT    .*should be empty.*    type=Regexp
        Log    --> !!!Warning!!! Check alarms failed!
    EXCEPT  AS  ${error}
        Log To Console  --> !!!Warning!!! Check alarms failed due to ${error}
    END
    ${alarms}                Run Keyword And Return Status    Should Be Empty    ${not_allowed_list}
    Run Keyword If           ${alarms}==${False}    Log To Console    ${message}
    Log Result To Console    ${alarms}    alarms${name}

Check LabPC Status
    [Arguments]              ${labPC_time}=5min
    Log To Console           \n Check If LabPC Is Pingable
    ${labPC_status}          Run Keyword And Return Status    Wait Until Keyword Succeeds    ${labPC_time}    10s
    ...                      Check If LabPC Is Pingable
    Log Result To Console    ${labPC_status}    labPC_status

Check PA Status
    Log To Console      \n Check PA Status
    ${pa_status}    Run Keyword If    '${site}'=='WRO'    Run Keyword And Return Status    Variable Should Exist    ${tl.attenuation}
    ...                 ELSE    Get Variable Value    ${tl.attenuator.ip_addr}    ${False}
    Run Keyword If    '${pa_status}'=='False'    Log To Console    test line doesn't have PA
    ${pa_check_status}=    Run Keyword If    '${pa_status}'!='False'   Run Keyword And Return Status    Check PA reachable
    Run Keyword If    '${pa_status}'!='False'    Log Result To Console    ${pa_check_status}    PA_status

Check UE Status
    [Arguments]       ${UE_time}=2min
    Log To Console    \n Check UE Status
    ${UE_status}      Run Keyword And Return Status    Run Keyword If    ${labPC_status}
    ...               Wait Until Keyword Succeeds    ${UE_time}    10s    Check If UE Is Enabled
    Run Keyword If    ${labPC_status}    Log Result To Console    ${UE_status}    UE_status

Precheck NSA eNB For Recovery
    [Arguments]    ${coam_time}=30s    ${smod_time}=30s    ${bbmod_time}=30s    ${rf_time}=30s    ${onair_time}=30s    ${alarm_time}=30s
    Log To Console           \n \n INFO: Precheck enb for NSA
    Verify BTS Recovery      bts_host=${enb_host}    name=_enb    coam_time=${coam_time}    smod_time=${smod_time}
    ...                      bbmod_time=${bbmod_time}    rf_time=${rf_time}
    Check OnAir Status       _ENB    ${onair_time}
    Check Alarms Status      ${alarm_time}    ${enb_host}    _ENB
    FOR    ${item}    IN     @{NSA_STEPS}
           Set Global Variable    ${${item}}
           Run Keyword If       '${${item}}'=='False'    Log    !!! Check ${item} FAILED !!!    level=WARN
    END
    Log To Console    \n \n INFO: Precheck enb for NSA DONE

Verify OnAir
    [Arguments]    ${onair_time}=2min
    WA for coam connect
    Log To Console    \n Verify OnAir
    Run Keyword If    'cus' in $UEs    Reach OnAir WTS
    ${onair_time}    set Variable if    'cus' in $UEs    5min    ${onair_time}
    Wait Until Keyword Succeeds    ${onair_time}    10    Verify Cells Setup
    [Teardown]    coam.Teardown    connection=coam_admin

Verify OnAir For NSA
    [Arguments]    ${onair_time}=2min
    Log To Console       \n Verify OnAir For NSA
    coam.Connect To       bts_host=${enb_host}    name=coam_admin
    Wait Until Keyword Succeeds    ${onair_time}    10    Verify Cells Setup    connection=coam_admin
    [Teardown]            coam.Teardown    connection=coam_admin

Check If LabPC Is Pingable
    FOR  ${ue}  IN  @{tl.ues}
        ${cpc_addr}=        Get Variable Value    ${ue.ssh_connection_details.addr}    ${ue.ue_pc_address}
        Check If IP Is Pingable    ${cpc_addr}
    END

Check Active Alarms
    [Arguments]    ${bts_host}=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}    ${name}=${EMPTY}
    @{not_allowed_alarms}  Create List
    Set Global Variable      ${message}    ${EMPTY}
    WA for coam connect    ${bts_host}
    ${is_ASOG_A101}     is_ASOG_A101
    IF    '61675' not in ${CLASSICAL_ALLOWED_ACITVE_ALARMS} and ${is_ASOG_A101}
        Append To List    ${CLASSICAL_ALLOWED_ACITVE_ALARMS}    61675
    END
    ${active_alarms}       coam.get_active_alarms    connection=coam_admin
    ${sw_fallback}         Run Keyword And Return Status    Should Contain    ${active_alarms}    SW fallback    ignore_case=True
    Set Suite Variable     ${sw_fallback${name}}    ${sw_fallback}
    FOR    ${active_alarm}    IN    @{active_alarms}
        ${faultID}         Convert To String    ${active_alarm['faultId']}
        ${fault_status}    Run Keyword And Return Status    List Should Contain Value    ${CLASSICAL_ALLOWED_ACITVE_ALARMS}    ${faultID}
        ${fault_status}    Run Keyword If    '${fault_status}'=='False' and '${faultID}' == '4681'
        ...                check_fault_4681_is_valid    ${active_alarm}
        ...     ELSE IF    '${fault_status}'=='False'        Set Variable    ${False}
        ...        ELSE    Set Variable    ${True}
        Run Keyword If     ${fault_status}==${False}    Run Keywords
        ...                Append To List    ${not_allowed_alarms}    ${faultID}
        ...        AND     Set Global Variable    ${message}
        ...                ${message} \n Not allowed alarm appeared on bts: ${active_alarm['faultId']}, ${active_alarm['faultName']} \n
    END
    Set Global Variable    ${not_allowed_list${name}}    ${not_allowed_alarms}
    Set Global Variable    ${message}
    Should Be Empty      ${not_allowed_alarms}

Check If UE Is Enabled
    FOR  ${ue}  IN  @{tl.ues}
        IF    '${ue.ue_type}'=='huawei_router'
            Log To Console           \n Skip check for huawei router
        ELSE
            ${cpc_addr}=        Get Variable Value    ${ue.ssh_connection_details.addr}    ${ue.ue_pc_address}
            ${cpc_username}=    Get Variable Value    ${ue.ssh_connection_details.username}    ${ue.ue_pc_login}
            ${cpc_password}=    Get Variable Value    ${ue.ssh_connection_details.password}    ${ue.ue_pc_password}
            Connect to controlPC    cpc_addr=${cpc_addr}
            ...                     cpc_username=${cpc_username}
            ...                     cpc_password=${cpc_password}
            Wait Until Keyword Succeeds        30s  10s                 ADB Check And Get Output    ${ue.serial_number}
        END
    END
    [Teardown]    ssh.disconnect    connection=controlPC

ADB Check And Get Output
    [Arguments]       ${device}
    ${adb_visible}    Run Keyword And Return Status    ADB devices    device=${device}
    Run Keyword If    ${adb_visible}==${False}    Run Keywords    ADB Check adb devices output    device=${device}
    ...        AND    Set Global Variable    ${is_device_off_${device}}    ${is_device_off}
    ...        AND    Fail

Log Result To Console
    [Arguments]       ${result}   ${name}
    Run Keyword If    ${result}    Log To Console      | ${green}PASS${rm_color} |
    ...       ELSE    Log To Console      | ${red}FAIL${rm_color} |
    Set Global Variable    ${${name}}    ${result}

Verify BTS Recovery
    [Arguments]        ${bts_host}=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}    ${name}=${EMPTY}
    ...                ${coam_time}=5min    ${lmp_time}=2min    ${smod_time}=5min    ${bbmod_time}=5min    ${rf_time}=10min
    ${smod_type}      Set Variable    default
    Set Global Variable    ${smod_status${name}}     Not checked
    Set Global Variable    ${bbmod_status${name}}    Not checked
    Set Global Variable    ${rf_status${name}}       Not checked
    Set Global Variable    ${passive_sw_status}      Not checked
    Set Global Variable    ${webem_status}           Not checked
    Set Global Variable    ${commission_status}      Not checked
    Verify COAM Connection    ${bts_host}    ${name}    ${coam_time}
    IF    'enb' not in '${name}'
        Verify LMP Connection     ${lmp_time}
    END
    IF    'enb' not in '${name}' and ${lmp_connect}
        Verify Passive SW version
        Verify WebEM Access via Selenium
    END
    IF    ${coam_connect${name}} and ${coam_connect} and ${lmp_connect}
        TRY
            Get Smod Name
        EXCEPT  AS  ${error}
            Log To Console  --> !!!Warning!!! Get Smod Name failed due to ${error}
            ${connection_error}    Get Regexp Matches    ${error}    ConnectFailedError|unable to connect to
            IF    ${connection_error}
                Set Global Variable    ${coam_connect${name}}    ${False}
                Set Global Variable    ${lmp_connect}    ${False}
            ELSE
                Fail
            END
        END
    END
    IF    '${smod_type}'=='default'
        Log To Console   \n ${red}SMOD type is not set!${rm_color} \n
    END
    IF    ${coam_connect${name}}
        Verify Smod For Recovery    ${name}    ${smod_time}
    END
    ${bbmod_check}    Evaluate    '${smod_type}'!='default' and ('ASO' not in '${smod_type}' or '${name}'!='${EMPTY}')
    IF    ${bbmod_check} and '${smod_status${name}}'=='${True}' and ${coam_connect${name}}
        Verify Bbmod For Recovery    ${name}    ${bbmod_time}
    END
    IF    '${smod_status${name}}'=='${True}' and ${coam_connect${name}} and '${commission_status}'=='True'
        Verify RF For Recovery    ${name}    ${rf_time}
    END
    [Teardown]    Run Keyword And Ignore Error    coam.teardown      connection=coam_admin

Verify COAM Connection
    [Arguments]              ${bts_host}=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}    ${name}=${EMPTY}
    ...                      ${coam_time}=5min
    Log To Console           \n Verify COAM Connection
    ${coam_connect}          Run Keyword And Return Status
    ...                      Wait Until Keyword Succeeds      ${coam_time}  30s    WA for coam connect    ${bts_host}
    Log Result To Console    ${coam_connect}    coam_connect${name}

Verify LMP Connection
    [Arguments]                 ${lmp_time}=2min
    Log To Console              \n Verify LMP Connection
    ${lmp_connect}          Run Keyword And Return Status
    ...                         Wait Until Keyword Succeeds    ${lmp_time}    15s    coam.connect to
    ...                         bts_host=${LMP_IP}
    ...                         update_interval=1000
    ...                         name=coam_admin_129
    Run Keyword If              ${lmp_connect}==${False}    Log To Console    LMP ${LMP_IP} connection FAILED!
    Log Result To Console       ${lmp_connect}    lmp_connect

Verify Smod For Recovery
    [Arguments]    ${name}=${EMPTY}    ${smod_time}=5min
    Log To Console           \n Verify Smod Detection
    ${smod_status}           Run Keyword And Return Status    Wait Until Keyword Succeeds    ${smod_time}  30s    Check Smod State
    Log Result To Console    ${smod_status}    smod_status${name}

Verify Bbmod For Recovery
    [Arguments]    ${name}=${EMPTY}    ${bbmod_time}=5min
    Log To Console           \n Verify BBmod Detection
    ${bbmod_status}          Run Keyword And Return Status    Wait Until Keyword Succeeds    ${bbmod_time}    30s    Check BBmod State
    Log Result To Console    ${bbmod_status}    bbmod_status${name}

Verify RF For Recovery
    [Arguments]    ${name}=${EMPTY}    ${rf_time}=10min
    Log To Console           \n Verify RF Detection
    ${rf_status}             Run Keyword And Return Status    Wait Until Keyword Succeeds      ${rf_time}  30s     Check RF Status    logs=${True}
    TRY
        Run Keyword If           ${rf_status}==${False}    Log HW Status    hw=RF
    EXCEPT  AS  ${error}
        Log To Console  --> !!!Warning!!! Verify RF For Recovery failed due to ${error}
        IF    "'{output_RF}' not found" in """${error.replace('"', '')}"""
            Set Suite Variable    ${commission_recovery}    ${True}
        END
    END
    Log Result To Console    ${rf_status}    rf_status${name}

Verify Passive SW version
    Log To Console           \n Verify Passive SW version
    TRY
        Get BTS SW Version    bts_host=${LMP_IP}    check_times=1    alias=coam_admin_129
        ${passive_sw_status}    Evaluate    $passive_SW is not None and ${{len($passive_SW)}} > 0
        Log Result To Console    ${passive_sw_status}    passive_sw_status
        ${output}    coam.get_bts_info    connection=coam_admin_129
        ${bts_status}    Set Variable    ${output['status']['proceduralState']}
        IF    '${bts_status}'=='NotCommissioned'
            Log Result To Console    ${False}    commission_status
        ELSE
            Set Global Variable    ${commission_status}    ${True}
        END
    EXCEPT    AS    ${error}
        Log To Console  --> !!!Warning!!! Verify Passive SW version failed due to ${error}
        Log Result To Console    ${False}    commission_status
    END
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=coam_admin_129

Verify WebEM Access via Selenium
    Log To Console           \n Verify WebEM Access via Selenium
    ${webem}                 Run Keyword And Return Status    Check Access To WebEm
    Set Global Variable    ${webem_status}    ${webem}
    Run Keyword If           '${webem_status}'=='False'
    ...    Log To Console    --> !!!Warning!!! WebEM access is not available via Selenium!
    Log Result To Console    ${webem_status}    webem_status
# ----------------------------------------------------------------------------------------
# ----------------------------------------- RECOVERY -------------------------------------
Run Smart Recovery
    FOR    ${index}    IN RANGE    1    ${${MAX_RECOVERY_TRIES}+1}
        ${status}    Run Keyword And Return Status    Smart Recovery   index=${index}
        ${TESTLINE_OFF}    Set Variable If     '${status}'!='${True}'    ${True}    ${TESTLINE_OFF}
        Exit For Loop If    ${TESTLINE_OFF}
        Precheck For Recovery    UE_ENV_check=${UE_ENV_check}
        Exit For Loop If    '${RECOVERY}'=='${False}'
    END

Smart Recovery
    [Arguments]    ${index}
    Log To Console    \n ------------------------------------------------------------------------------
    Log To Console    SMART RECOVERY START LOOP: ${index} / Total: ${MAX_RECOVERY_TRIES}  \n
    BTS Recovery
    Run Keyword If    ${PA_status}==${False}    PA Recovery
    Run Keyword If    ${UE_status}==${False}    UE Recovery
    Log To Console    \n \n SMART RECOVERY END
    Log To Console    ------------------------------------------------------------------------------ \n

BTS Recovery
    IF    '${commission_status}'=='False'
        Recovery for uncommission status
    ELSE IF    '${coam_connect}'=='False' and '${lmp_connect}'=='False'
        Recovery For COAM
    ELSE IF    '${coam_connect}'=='True' and '${lmp_connect}'=='False'
        Recovery For LMP    ${True}
    ELSE IF    ('${coam_connect}'=='False' and '${lmp_connect}'=='True')
        Recovery For SMOD
    ELSE IF    '${alarms}'=='False'
        Check Not Allowed Alarms
    ELSE IF    '${smod_status}'=='False' or '${bbmod_status}'=='False'
        Recovery For SMOD
    ELSE IF    '${rf_status}'=='False'
        Recovery For RF
    ELSE IF    '${onAir_status}'=='False'
        Recovery For SMOD
    ELSE IF    '${labPC_status}'=='False'
        Set Global Variable     ${TESTLINE_OFF}    ${True}
        Log    Please check labPC!    WARN
    ELSE IF    '${passive_sw_status}'=='False' or '${webem_status}'=='False'
        Recovery for passive sw empty
    END

Recovery For LMP
    [Arguments]    ${rollback}=${True}
    ${is_sw_update_performed}    Get Variable Value    ${is_sw_update_performed}    ${False}
    IF    ${LMP_RECOVERY}==${False} and not ${rollback}
        Log To Console    \n Disable Ethernet Port Security & Enable SSH Access
        Allow To Connect To BTS After NIDD Downgrade    recovery=${True}
        Set Global Variable     ${LMP_RECOVERY}    ${True}
    ELSE IF     ${LMP_RECOVERY}==${False} and ${rollback} and not ${SW_ROLLBACK}
        Perform And Verify Rollback    bts_host=${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}
        Set Global Variable     ${LMP_RECOVERY}    ${True}
    ELSE IF     ${LMP_RECOVERY}==${True} and ${rollback} and ${SW_ROLLBACK} and not ${is_sw_update_performed}
        Perform SW Update
    ELSE IF     ${LMP_RECOVERY}==${True} and ${rollback} and ${SW_ROLLBACK} and ${is_sw_update_performed}
        Log    BTS cannot be recovered by rollback and sw update, TL will be turned off!!!    WARN
        Set Global Variable    ${TESTLINE_OFF}    ${True}
    ELSE
        Set Global Variable     ${TESTLINE_OFF}    ${True}
        Log    Please check lmp connection!    WARN
    END

Check Not Allowed Alarms
    Log To Console    \n \n Check Not Allowed Alarms
    Log    Not allowed alarm is visible: ${not_allowed_list}! \n    WARN
    ${alarm_str}    Catenate    SEPARATOR=_    @{not_allowed_list}
    ${update_needed}    Check If specific recovery needed for not allowed alarms    alarms=@{software_update_alarms}
    ${rollback_needed}    Check If specific recovery needed for not allowed alarms    alarms=@{software_rollback_alarms}
    ${enb_recovery_needed}    Check If specific recovery needed for not allowed alarms    alarms=@{enb_recovery_alarms}
    ${is_sw_update_performed}    Get Variable Value    ${is_sw_update_performed_for_${alarm_str}}    ${False}
    ${has_enb}    Evaluate    "${tl.enbs}"!="None"
    IF    ${update_needed} and not ${is_sw_update_performed}
        Perform SW Update
    ELSE IF    ${update_needed} and ${is_sw_update_performed}
        Log    BTS cannot be recovered by sw update, TL will be turned off!!!    WARN
        Set Global Variable    ${TESTLINE_OFF}    ${True}
    ELSE IF    ${rollback_needed} and not ${SW_ROLLBACK}
        Perform And Verify Rollback
    ELSE IF    ${rollback_needed} and ${SW_ROLLBACK}
        Log    BTS cannot be recovered by sw rollback, TL will be turned off!!!    WARN
        Set Global Variable    ${TESTLINE_OFF}    ${True}
    ELSE IF    ${enb_recovery_needed} and ${has_enb} and not ${SMOD_RESET_ENB}
        Perform ENB Power Reset
    ELSE IF    ${enb_recovery_needed} and ${has_enb} and ${SMOD_RESET_ENB}
        Log    BTS cannot be recovered by enb reset, TL will be turned off!!!    WARN
        Set Global Variable    ${TESTLINE_OFF}    ${True}
    ELSE IF    '6450' in $not_allowed_list
        Recovery for 6450 alarm
    ELSE IF    '4741' in $not_allowed_list
        Perform Site Reset
    ELSE IF    '10' in $not_allowed_list and '${bbmod_status}'=='False'
        Recovery For SMOD
    ELSE IF    '10' in $not_allowed_list or '2934' in $not_allowed_list and '${rf_status}'=='False'
        Recovery For RF
    ELSE IF    '1850' in $not_allowed_list
        Recovery for 1850 alarm
    ELSE IF    '1900' in $not_allowed_list and '${rf_status}'=='True'
        Recovery for 1900 alarm
    ELSE IF    '4334' in $not_allowed_list
        Recovery for 4334 alarm
    ELSE IF    '6202' in $not_allowed_list and 'huawei_router' in ${UEs}
        ${result}    Restart ePC SIM
        IF    not ${result}
            Set Global Variable    ${TESTLINE_OFF}    ${True}
        END
    ELSE IF    '4123' in $not_allowed_list
        Log    TL will be turned off to wait GPS survey finish!!!    WARN
        Set Global Variable    ${TESTLINE_OFF}    ${True}
    ELSE
        Recovery For Not Allowed Alarm
    END

Recovery for 4334 alarm
    ${recover_4334}    Get Variable Value    ${recover_4334}    ${False}
    Run Keyword If    not ${recover_4334}    Run Keywords
    ...    Log To Console    Recovery for 4334 alarm started
    ...    AND    ssh.connect to    hostname=192.168.255.129
    ...           username=toor4nsn
    ...           password=oZPS0POrRieRtu
    ...           alias=LMP
    ...    AND    Log To Console    send command uboot_env set console_uart=-1
    ...    AND    ssh.execute    command=uboot_env set console_uart=-1    connection=LMP    timeout=60s
    ...    AND    Log To Console    send command reboot
    ...    AND    ssh.send_command    command=reboot    connection=LMP
    ...    AND    Log To Console    Wait for 60s
    ...    AND    BuiltIn.Sleep  60s
    ...    AND    Set Suite Variable    ${recover_4334}    ${True}
    ...    ELSE IF   ${recover_4334} and not ${sw_fallback} and not ${SW_ROLLBACK}   Run Keywords
    ...    Log To Console    Try to rollback to recover alarm 4334
    ...    AND    Perform And Verify Rollback
    ...    ELSE   Run Keywords
    ...    Set Global Variable    ${TESTLINE_OFF}    ${True}
    ...    AND    Log
    ...    Testline will be turned off due to 4334 alarm cannot be recovered after uboot command and rollback!!!   WARN

Recovery for 6450 alarm
    ${is_snapshot_saved}=    Get Variable Value    ${is_snapshot_saved}    ${False}
    IF    not ${is_snapshot_saved}
        WA for coam connect
        Run Keyword And Continue On Failure    Save Snapshot For Classical    sw_d=default
        Set Suite Variable    ${is_snapshot_saved}     ${True}
    ELSE
        Recovery For Not Allowed Alarm
    END

Recovery for 1850 alarm
    Run Keyword If    not ${RF_RESET} and not ${SMOD_RESET}    Run Keywords
    ...    smart_recovery.Power Reset RF
    ...    AND    smart_recovery.Power Reset SMOD
    ...    AND    Set Global Variable    ${SMOD_RESET}    ${True}
    ...    AND    Set Global Variable    ${RF_RESET}    ${True}
    ...    ELSE    Recovery For Not Allowed Alarm

Recovery for 1900 alarm
    WA for coam connect    ${LMP_IP}
    Run Keyword If    not ${COMMISSION}   Run Keywords
    ...               Perform Commissioning With NIDD Check For Classical
    ...    AND        Set Global Variable    ${COMMISSION}    ${True}
    ...    ELSE IF    ${COMMISSION} and not ${sw_fallback} and not ${SW_ROLLBACK}
    ...               Perform And Verify Rollback
    ...    ELSE       Run Keywords
    ...               Log    TL cannot be recovered from 1900 alarm after SCF commission or rollback!!!    WARN
    ...    AND        Set Global Variable     ${TESTLINE_OFF}    ${True}

Recovery for passive sw empty
    ${is_sw_update_performed_for_passive_sw_empty}    Get Variable Value    ${is_sw_update_performed_for_passive_sw_empty}
    IF    ${is_sw_update_performed_for_passive_sw_empty}
        Set Global Variable    ${TESTLINE_OFF}    ${True}
        Log    Passive SW version is empty, TL will be turned off!!!    WARN
    ELSE
        Perform SW Update
        Set Suite Variable    ${is_sw_update_performed_for_passive_sw_empty}    ${True}
    END

Recovery for uncommission status
    WA for coam connect    ${LMP_IP}
    IF    not ${COMMISSION}
        Perform Commissioning With NIDD Check For Classical
        Set Global Variable    ${COMMISSION}    ${True}
    ELSE
        Log    TL cannot be recovered after SCF commission!!!    WARN
        Set Global Variable     ${TESTLINE_OFF}    ${True}
    END

Check If specific recovery needed for not allowed alarms
    [Arguments]    ${alarms}
    FOR    ${alarm}    IN    @{alarms}
        Return From Keyword If    '${alarm}' in $not_allowed_list    ${True}
    END
    Return From Keyword    ${False}

Perform SW Update
    ${alarm_str}    Catenate    SEPARATOR=_    @{not_allowed_list}
    TRY
        Get BTS SW Version     log=${False}    bts_host=${LMP_IP}    coam_connection=${True}
        ${active_SW_short}   get_short_name_of_sbts_build    ${active_SW}
        IF    '${last_released_build}' == "null"
            IF    '${active_SW.replace("SBTS", "").split('_')}[0]' == '${TRUNK_BRANCH_NUM}'
                Set Global Variable    ${last_released_build}    SBTS00_${active_SW_short.replace("T1", "").replace("T2", "")}
            ELSE
                Set Global Variable    ${last_released_build}    ${active_SW}
            END
        END
        ${last_released_build_short}    get_short_name_of_sbts_build    ${last_released_build}
        IF    '${last_released_build_short}' in '${active_SW_short}' and 'T1' in '${active_SW_short}'
            ${T1orT2}    Set Variable    None
            ${sw_package}   Set Variable
            ...    /media/builds/${last_released_build}/${last_released_build}_release_BTSSM_downloadable_A54.zip
        ELSE
            ${T1orT2}    Set Variable    T1
            ${sw_package}   Set Variable
            ...    /media/builds/${last_released_build}/${last_released_build}_release_BTSSM_downloadable_testpackage_T1_A54.zip
        END
        Check If Package Exists     ${sw_package}    ${last_released_build}
        Retry SBTS Package Installation If BTS is Busy    T1orT2=${T1orT2}
        ...   sw_package=${sw_package}
    EXCEPT  AS  ${error}
        Log To Console  --> !!!Warning!!! SW update failed due to ${error}
        IF    "Keyword 'Get software info' failed" in """${error.replace('"', '')}""" and not ${COMMISSION}
            Recovery for 1900 alarm
            Set Global Variable    ${COMMISSION}    ${True}
        END
        ${yaft_needed}    Get Regexp Matches    ${error}    FW update failure|Could not revert activation of Radio Software
        IF    ${yaft_needed}
            IF    ${YAFT}
                Set Global Variable     ${TESTLINE_OFF}    ${True}
            ELSE
                Perform Recovery With Netboot And Yaft
            END
        END
    END
    Set Suite Variable    ${is_sw_update_performed_for_${alarm_str}}    ${True}

Check If Package Exists
    [Arguments]                ${testpackage_path}    ${testpackage}
    ${testpackage_status}      Run Keyword And Return Status    OperatingSystem.File Should Exist    ${testpackage_path}
    Run Keyword If             ${testpackage_status}==${False}    Run Keywords
    ...                        Set Global Variable    ${build_not_exists}    ${testpackage}
    ...        AND             Set Global Variable    ${TESTLINE_OFF}    ${True}
    ...        AND             Fail    \n ${red}Package ${testpackage_path} need to be downloaded!${rm_color} \n

Get Package Path
    [Arguments]    ${path}=/media/builds    ${type}=None
    ${active_SW_SBTS00}    Get Substring      ${active_SW}    8
    ${active_SW}           Set Variable If    '${branch}' == 'SBTS00'    SBTS00${active_SW_SBTS00}    ${active_SW}
    ${active_SW_T0}        Fetch From Left    ${active_SW}    T1
    ${active_SW_T0}        Fetch From Left    ${active_SW_T0}    T2
    ${testpackage}         Set Variable If    ('${type}'=='None' and 'T1' in '${active_SW}') or '${type}'=='T1'    _testpackage_T1
    ...                                       ('${type}'=='None' and 'T2' in '${active_SW}') or '${type}'=='T2'    _testpackage_T2
    ...                                       ${EMPTY}
    ${testpackage_path}    Set Variable       ${path}/${active_SW_T0}/${active_SW_T0}_release_BTSSM_downloadable${testpackage}_A54.zip
    Set Global Variable      ${active_SW_T0}
    Set Global Variable      ${active_SW}
    Set Global Variable      ${testpackage}
    Set Global Variable      ${testpackage_path}

Download Build
    [Documentation]    Download selected package.
    [Arguments]    ${target_dir}    ${testpackage}    ${sw}=${active_SW}
    ...            ${url}=https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
    Log To Console    \n Download Build ${testpackage} \n
    OperatingSystem.Run
    ...    aria2c -x 16 -s 16 ${url}/${branch}/${sw}/${sw}_release_BTSSM_downloadable${testpackage}_A54.zip -d ${target_dir}
    OperatingSystem.File Should Exist      ${target_dir}/${sw}_release_BTSSM_downloadable${testpackage}_A54.zip

Recovery For Not Allowed Alarm
    Run Keyword If    '${ALARM_RECOVERY_STEP}'=='0'    Run Keywords    Perform Site Reset
    ...        AND    Set Global Variable    ${ALARM_RECOVERY_STEP}    1
    ...    ELSE IF    '${ALARM_RECOVERY_STEP}'=='1'    Run Keywords    smart_recovery.Power Reset SMOD
    ...        AND    Set Global Variable    ${ALARM_RECOVERY_STEP}    2
    ...    ELSE IF    ${sw_fallback}!=${True} and '${ALARM_RECOVERY_STEP}'=='2' and not ${SW_ROLLBACK}
    ...    Run Keywords    Perform And Verify Rollback
    ...        AND    Set Global Variable    ${ALARM_RECOVERY_STEP}    3
    ...       ELSE    Run Keywords   Log
    ...    Not allowed alarm is still visible after site reset, smod power reset or rollback, TL will be turned off!!!   WARN
    ...    AND   Set Global Variable    ${TESTLINE_OFF}    ${True}

Recovery For COAM
    ${sw_fallback}       Get Variable Value           ${sw_fallback}    ${False}
    Set Global Variable    ${sw_fallback}
    IF    ${SMOD_RESET}!=${True}
        smart_recovery.Power Reset SMOD
    ELSE IF    ${SMOD_RESET} and ${YAFT}
        Set Global Variable     ${TESTLINE_OFF}    ${True}
    ELSE IF    'FSMF_FBBC' in '${NODE_NAME}'
        IF    ${SW_ROLLBACK}
            Log    Site recovery failed after ROLLBACK, please check!    WARN
            Set Global Variable    ${TESTLINE_OFF}    ${True}
        ELSE
            smart_recovery.Power Reset SMOD
            Perform And Verify Rollback
            ...    bts_host=192.168.255.129    uboot_rollback=${True}    uboot_rollback_max_retries=${1}
        END
    ELSE
        Perform Recovery With Netboot And Yaft
    END

Perform Recovery With Netboot And Yaft
    TRY
        Set Global Variable         ${YAFT}    ${True}
        Check If Package Exists     /media/builds/${last_released_build}/${last_released_build}_release_BTSSM_downloadable_A54.zip
        ...                         ${last_released_build}
        Set Global Variable    ${AF_PATH}         /media/builds/${last_released_build}
        Set Global Variable    ${loadBuild}       ${last_released_build}
        Perform Netboot And Yaft
    EXCEPT  AS  ${error}
        Log To Console  --> !!!Warning!!! Perform Recovery With Netboot And Yaft Failed due to ${error}
    END

    [Teardown]    OperatingSystem.Run    rm -f /tmp/${branch}_*

Perform Netboot And Yaft
    ${netboot_enabled}    Run Keyword And Return Status    Start dnsmasq service on VM
    IF    ${netboot_enabled}
        Log To Console    \n YAFT via netboot will be performed to recover TL!!!
        IF    ${airscale_fsmf} or ${dualcore}
            Remove From Dictionary    ${AIRSCALE_FSMF_DUALCORE_testpc_index_map}    slave
            ${board_testpc_index_map}    Set Variable    ${AIRSCALE_FSMF_DUALCORE_testpc_index_map}
        ELSE
             ${board_testpc_index_map}    Set Variable    ${single_board_testpc_index_map}
        END
        ${yaft_res}    Run Keyword And Return Status    Perform Yaft
        ...    ${board_testpc_index_map}    netboot_enabled=True
        ...    yaft_build_path=${AF_PATH}/${last_released_build}_release_BTSSM_downloadable_A54.zip
        IF    ${yaft_res}
            ${stop_dnsmasq}    RUN    command=sudo /etc/init.d/dnsmasq stop
            ${pdu_reboot}       Run Keyword And Return Status   smart_recovery.Power Reset SMOD
            IF    ${pdu_reboot}
                Wait Until Keyword Succeeds    5min  30s    Check If BTS Is Pingable
            ELSE
                Set Global Variable     ${TESTLINE_OFF}    ${True}
                Fail    PDU reboot failed after stopping dnsmasq, TL is still in netboot mode!!!
            END
        ELSE
            Perform And Verify Rollback    bts_host=192.168.255.1    uboot_rollback=${True}
            ${stop_dnsmasq}    RUN    command=sudo /etc/init.d/dnsmasq stop
            ${pdu_reboot}       Run Keyword And Return Status   smart_recovery.Power Reset SMOD
            IF    not ${pdu_reboot}
               Fail    PDU reboot failed after yaft, TL is still in netboot mode!!!
            END
        END
    ELSE
        ${is_testline_off}    Get Variable Value     ${TESTLINE_OFF}    ${False}
        IF    not ${is_testline_off}
            Log    Netboot cannot be enabled, YAFT via netboot cannot be proceeded.    WARN
            Set Global Variable     ${TESTLINE_OFF}    ${True}
            ${stop_dnsmasq}    RUN    command=sudo /etc/init.d/dnsmasq stop
            ${pdu_reboot}       Run Keyword And Return Status   smart_recovery.Power Reset SMOD
            IF    not ${pdu_reboot}
                Fail    PDU reboot failed after stopping dnsmasq, TL is still in netboot mode!!!
            END
        END
    END
    [Teardown]

Prepare TL And Perform Netboot
    [Arguments]         ${smod_pdu_host}=${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    ...                 ${smod_pdu_port}=${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    ...                 ${script_path}=/home/ute/robotws/testsuite/QT/SRAN/resources/scripts
    Set SMOD Type
    Run Keyword If      'ASO' not in '${smod_type}'    Set BBMOD Type For YAFT
    ${smod_type_lower_case}    Convert To Lower Case    ${smod}
    Run                 sudo chmod 777 ${script_path}/netboot-script.sh
    Log To Console      Execute ${script_path}/etboot-script.sh and start dnsmasq
    Run    cd ${script_path} && ./netboot-script.sh ${smod_type_lower_case}
    Run                 sudo systemctl start dnsmasq
    ${pdu_reboot}       Run Keyword And Return Status    reboot_pdu_port    ip=${smod_pdu_host}    port=${smod_pdu_port}
    Log To Console      \n Smod PDU host: ${smod_pdu_host}
    Log To Console      Smod PDU port: ${smod_pdu_port} \n
    Run Keyword If      '${pdu_reboot}'=='${False}'    Log To Console    \n\t\t> > > PDU reboot FAILED < < < [ !!! ]\n
    ...                                        ELSE    Log To Console    \n\t\t> > > PDU reboot succeeded < < < \n
    Run    sudo systemctl status dnsmasq
    Connect to gNB And Mount Partitions
    [Teardown]    Run    sudo systemctl stop dnsmasq

Start dnsmasq service on VM
    @{start_netboot_service_cmd}    Create List    sudo systemctl stop systemd-resolved
    ...                                            sudo systemctl start dnsmasq.service
    ...                                            sudo systemctl --no-pager status dnsmasq.service
    FOR    ${cmd}    IN    @{start_netboot_service_cmd}
        ${output}    RUN    command=${cmd}
        BuiltIn.Sleep    2s
    END
    IF    "active (running)" in '''${output.replace("'", "")}'''
        Log To Console    \ndnsmasq service started
        ${start_dnsmasq}    RUN    command=sudo /etc/init.d/dnsmasq start
        smart_recovery.Power Reset SMOD
        Wait Until Keyword Succeeds    10min    10s    Check If BTS Is Pingable    ip=192.168.255.1
        Wait Until Keyword Succeeds    3min   30s    ssh.connect_to
        ...                                          hostname=192.168.255.1
        ...                                          username=toor4nsn
        ...                                          password=oZPS0POrRieRtu
        ...                                          alias=bts
    ELSE
        Log    dnamasq.service start failed, YAFT via netboot cannot be proceeded.    WARN
        Set Global Variable     ${TESTLINE_OFF}    ${True}
        Fail
    END

Recovery For SMOD
    ${sw_fallback}       Get Variable Value           ${sw_fallback}    ${False}
    Run Keyword If    ${SMOD_RESET}!=${True}      smart_recovery.Power Reset SMOD
    ...    ELSE IF    ${sw_fallback}!=${True} and ${SMOD_RESET} and not ${SW_ROLLBACK}    Perform And Verify Rollback
    ...    ELSE IF    ${sw_fallback} and ${SMOD_RESET}    Log    Alarm SW fallback is visible - SW rollback will be not performed!    WARN
    ...   ELSE        Run Keywords
    ...   Log         SMOD Recovery Failed After power reset and rollback, pls check manually!    WARN
    ...   AND         Set Global Variable    ${TESTLINE_OFF}    ${True}

Recovery For RF
    ${sw_fallback}       Get Variable Value           ${sw_fallback}    ${False}
    ${commission_recovery}    Get Variable Value     ${commission_recovery}    ${False}
    IF    ${commission_recovery} and not ${COMMISSION}
        Recovery for 1900 alarm
        Set Global Variable    ${COMMISSION}    ${True}
    ELSE IF    ${commission_recovery} and ${COMMISSION}
        Log    Site recovery failed after commission, please check!    WARN
        Set Global Variable    ${TESTLINE_OFF}    ${True}
    ELSE IF    ${RF_RESET}!=${True}
        smart_recovery.Power Reset RF
    ELSE IF    ${RF_RESET} and ${SMOD_RESET}!=${True}
        smart_recovery.Power Reset SMOD
    ELSE IF    not ${SW_ROLLBACK} and ${sw_fallback}!=${True} and ${SMOD_RESET} and ${RF_RESET}
        Perform And Verify Rollback
    ELSE IF    ${SW_ROLLBACK} and ${sw_fallback}!=${True} and ${SMOD_RESET} and ${RF_RESET}
        Log    RF recovery failed after RF Power Reset, SMOD Power Reset And ROLLBACK, please check!    WARN
        Set Global Variable    ${TESTLINE_OFF}    ${True}
    ELSE IF    ${sw_fallback} and ${SMOD_RESET}
        Log    Alarm SW fallback is visible - SW rollback will be not performed!    WARN
        Set Global Variable    ${TESTLINE_OFF}    ${True}
    END

Perform And Verify Rollback
    [Arguments]    ${bts_host}=192.168.255.129    ${uboot_rollback}=${False}    ${uboot_rollback_max_retries}=${3}
    TRY
        IF    ${uboot_rollback}
            Perform uboot Rollback
            ...    bts_host=${bts_host}    uboot_rollback_max_retries=${uboot_rollback_max_retries}
        ELSE
            Log To Console    \n Perform Rollback via webem
            Perform Rollback    bts_host=${bts_host}
        END
        Verify BTS State By Ping    ip=${bts_host}    wait_ping_time=10min
        IF    not ${uboot_rollback}
            Verify Rollback
        END
    EXCEPT  AS  ${error}
        IF    not ${uboot_rollback}
            ${match}    Get Regexp Matches    ${error}    Given ip.*is not reachable
            IF    ${match}
                Log    Perform And Verify Rollback failed due to ${error}    WARN
            ELSE
                Log    \n Rollback via webem failed, trying to rollback via uboot command...    WARN
                Perform uboot Rollback
                ...    bts_host=${bts_host}    uboot_rollback_max_retries=${uboot_rollback_max_retries}
                Verify BTS State By Ping    ip=${bts_host}    wait_ping_time=10min
            END
        ELSE
            Log To Console    \n Rollback via uboot command failed, Testline will be turned off!!!\n
            Set Global Variable     ${TESTLINE_OFF}    ${True}
        END
    END
    Set Global Variable    ${SW_ROLLBACK}    ${True}

Perform uboot Rollback
    [Arguments]    ${bts_host}=192.168.255.129    ${uboot_rollback_max_retries}=${3}
    RUN    chmod +x ${CURDIR}/../scripts/uboot_rollback.sh
    FOR    ${retry}    IN RANGE    1    ${uboot_rollback_max_retries}+1
        Log To Console    \n Rollback via uboot command, trials: ${retry} / ${uboot_rollback_max_retries}
        ${res}    RUN    cd ${CURDIR}/../scripts && ./uboot_rollback.sh "${bts_host}"
        IF    'Reboot command executed' in '''${res.replace("'", "")}'''
            Log to Console    \n ${green}Rollback is successfully performed${rm_color}
            BREAK
        ELSE IF   ${retry}==${uboot_rollback_max_retries}
            Log
            ...    ${red}Fails to rollback software via uboot command: ${res}, Testline will be turned off!!!${rm_color}
            ...    WARN
            Set Global Variable     ${TESTLINE_OFF}    ${True}
        ELSE
            Log To Console    \n Rollback via uboot command failed, retrying...
        END
    END

PA Recovery
    Log To Console     \n PA recovery \n
    ${pa_type}         Get Variable Value               ${tl.attenuation['attenuator_type']}    default
    ${attens_check}    Run Keyword And Return Status    Variable Should Exist    ${tl.attenuators}
    ${atten_check}     Run Keyword And Return Status    Variable Should Exist    ${tl.attenuator}
    ${ping_status}     Run Keyword And Return Status    Run Keyword If
    ...                '${pa_type}'=='EUBUS'            Check If IP Is Pingable    ${tl.attenuation['attenuator_ip']}
    ...    ELSE IF     ${attens_check}                  Check If IP Is Pingable For Attenuators
    ...    ELSE IF     ${atten_check}                   Check If IP Is Pingable    ${tl.attenuator.ip_addr}
    Run Keyword If     ${ping_status}    Log To Console     Ping PA is OK, TL will be disabled! \n
    ...       ELSE                       Log To Console     Ping PA is NOT OK, reset will be executed! \n
    Run Keyword If     '${pa_type}'=='EUBUS' and ${ping_status}==${False}    Reset Attenuator and Check    ${tl.attenuation['attenuator_ip']}
    ...  ELSE IF       ${attens_check} and ${ping_status}==${False}          Reset Attenuator and Check    ${tl.attenuators[${PA_recovery}].ip_addr}
    ...  ELSE IF       ${atten_check} and ${ping_status}==${False}           Reset Attenuator and Check    ${tl.attenuator.ip_addr}
    ...     ELSE       Set Global Variable    ${TESTLINE_OFF}    ${True}

Check If IP Is Pingable For Attenuators
    ${attenuators}    Get Variable Value   ${tl.attenuators}
    ${nr}    Get Length    ${attenuators}
    FOR    ${atten_index}    IN RANGE    0    ${nr}
           ${status}    Run Keyword And Return Status    Check If IP Is Pingable    ${tl.attenuators[${atten_index}].ip_addr}
           Run Keyword If    ${status}==${False}    Run Keywords    Set Global Variable    ${PA_recovery}    ${atten_index}
           ...        AND    Fail
    END

UE Recovery
    ${cpc_addr}        Get Variable Value    ${tl.ues[${UE_index}].ssh_connection_details.addr}        ${tl.ues[${UE_index}].ue_pc_address}
    ${cpc_password}    Get Variable Value    ${tl.ues[${UE_index}].ssh_connection_details.password}    ${tl.ues[${UE_index}].ue_pc_password}
    ${cpc_username}    Get Variable Value    ${tl.ues[${UE_index}].ssh_connection_details.username}    ${tl.ues[${UE_index}].ue_pc_login}
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    FOR  ${ue}  IN  @{tl.ues}
        ${is_device_off}    Get Variable Value    ${is_device_off_${ue.serial_number}}    None
        Run Keyword If    'offline' in '''${is_device_off}''' or 'unauthorized' in '''${is_device_off}'''
        ...               ADB recover from offline or unauthorized    device=${device}    print=${is_device_off}
        ...    ELSE IF    '''${is_device_off}'''=='${EMPTY}' and '${tl.tl_cloud_topology}' in $testlines_with_wihajster
        ...               Reboot UE With Wihajster And Wait For Status Change
        ...    ELSE IF    '''${is_device_off}'''=='${EMPTY}' and '${ue.ue_type}'=='askey'
        ...               Power Cycle Askey Shieldbox
        ...    ELSE IF    '_SA_' in '${NODE_NAME}'   Run Keywords    Log To Console    Please check 'NR only' in UE settings!
        ...        AND    Set Global Variable     ${TESTLINE_OFF}    ${True}
        ...       ELSE    Set Global Variable     ${TESTLINE_OFF}    ${True}
    END
    [Teardown]    ssh.disconnect    connection=controlPC

Get eNB SW Version
    WA for coam connect    ${enb_host}
    ${BTS_SW_Info}=   Get software info    alias=coam_admin
    ${active_SW_ENB}=     Get from dictionary    ${BTS_SW_Info}    Active SW version
    ${passive_SW_ENB}=    Get from dictionary    ${BTS_SW_Info}    Passive SW version
    Set Global Variable    ${active_SW_ENB}
    Set Global Variable    ${passive_SW_ENB}
    [Teardown]        coam.teardown_admin    connection=coam_admin

Power Reset SMOD
    [Arguments]    ${name}=${EMPTY}
    Log To Console    \n Perform smod power off
    TRY
        Run Keyword If    '${site}'=='TSR'    Run Keywords
        ...    Log To Console    Note: reversed PDU action is performed on TSR site!!!!
        ...    AND    Power On SMOD
        ...    ELSE   Power Off SMOD
        Log To Console    \n Perform smod power on
        Run Keyword If    '${site}'=='TSR'    Run Keywords
        ...    Log To Console    Note: reversed PDU action is performed on TSR site!!!!
        ...    AND    Power Off SMOD
        ...    ELSE   Power On SMOD
        Run Keyword If    '${name}'!='${EMPTY}'    Verify BTS State By Ping
    EXCEPT  AS  ${error}
        Log To Console  --> !!!Warning!!! Power Reset SMOD Failed due to ${error}
    END
    Set Global Variable    ${SMOD_RESET${name}}    ${True}

Power Reset RF
    [Arguments]    ${name}=${EMPTY}
    Log To Console    \n Perform rf power off
    TRY
        Run Keyword If    '${site}'=='TSR'    Run Keywords
        ...    Log To Console    Note: reversed PDU action is performed on TSR site!!!!
        ...    AND    Power On RF
        ...    ELSE   Power Off RF
        Log To Console    \n Perform rf power on
        Run Keyword If    '${site}'=='TSR'    Run Keywords
        ...    Log To Console    Note: reversed PDU action is performed on TSR site!!!!
        ...    AND    Power Off RF
        ...    ELSE   Power On RF
    EXCEPT  AS  ${error}
        Log To Console  --> !!!Warning!!! Power Reset RF Failed due to ${error}, TL will be turned off!!!
        Set Global Variable     ${TESTLINE_OFF}    ${True}
    END
    Set Global Variable    ${RF_RESET${name}}    ${True}

Perform ENB Power Reset
    Log To Console    \n Perform ENB Power Reset
    Set Global Variable     ${SMOD_RESET_ENB}     ${True}
    Set Global Variable     ${RF_RESET_ENB}     ${True}
    smart_recovery.Power OnOff SMOD for ENB    action=OFF
    smart_recovery.Power OnOff RF for ENB    action=OFF
    smart_recovery.Power OnOff SMOD for ENB    action=ON
    smart_recovery.Power OnOff RF for ENB    action=ON
    Wait Until Keyword Succeeds    5min    30s     Check If BTS Is Pingable    ip=${enb_host}

Power OnOff RF for ENB
    [Arguments]    ${action}=${POWER_ACTION}
    ${enb_rf}     Get Variable Value   ${tl.enbs[0].rms}    ${tl.enbs[0].dus[0].rus}
    IF    $enb_rf is None
        Log    \n No RF PDU found for ENB, please check!    WARN
        RETURN
    END
    ${enb_rf_num}    Evaluate    len($enb_rf)
    IF   '${enb_rf_num}'=='0'
        Log    \n No RF PDU found for ENB, please check!    WARN
        RETURN
    END
    FOR  ${i}  IN RANGE  ${enb_rf_num}
        ${pdu_model}    Get variable Value    ${tl.enbs[0].rms[${i}].pdu_port.pdu.vendor}   ${tl.enbs[0].dus[0].rus[${i}].pdu_port.pdu.vendor}
        ${pdu_ip}    Get variable Value    ${tl.enbs[0].rms[${i}].pdu_port.pdu.addr}    ${tl.enbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}
        ${pdu_port}    Get variable Value    ${tl.enbs[0].rms[${i}].pdu_port.port_no}    ${tl.enbs[0].dus[0].rus[${i}].pdu_port.port_no}
        IF    '${pdu_model}'=='Gude'
            ${pdu_version}     Get variable Value    ${tl.enbs[0].rms[${i}].pdu_port.pdu.version}
            ...    ${tl.enbs[0].dus[0].rus[${i}].pdu_port.pdu.version}
            pdu.Setup Pdu
            ...    host=${pdu_ip}
            ...    model=${pdu_model}
            ...    version=${pdu_version}
            ...    alias=enbrfpdu
        ELSE
            pdu.Setup Pdu
            ...    host=${pdu_ip}
            ...    model=${pdu_model}
            ...    alias=enbrfpdu
        END
        IF  '${action}'=='OFF'
            pdu.power_off  port=${pdu_port}  pdu_device=enbrfpdu
        ELSE
            pdu.power_on  port=${pdu_port}  pdu_device=enbrfpdu
        END
        BuiltIn.Sleep  10s
        ${pdu_status}=    pdu.get_port_status    port=${pdu_port}  pdu_device=enbrfpdu
        ${expected_status}=    Convert to lowercase    ${action}
        Should contain    ${pdu_status}    ${expected_status}
    END
    [Teardown]  Run Keyword And Ignore Error    pdu.teardown_pdu    pdu_device=enbrfpdu

Power OnOff SMOD for ENB
    [Arguments]    ${action}=${POWER_ACTION}
    ${enb_bbu}=    Get Variable Value    ${tl.enbs[0].system_module.common_units}
    ...    ${tl.enbs[0].dus[0].airscale.common_units}
    IF    $enb_bbu is None
        Log    \n No SMOD PDU found for ENB, please check!    WARN
        RETURN
    END
    ${enb_bbu_num}    Evaluate    len($enb_bbu)
    IF    '${enb_bbu_num}'=='0'
        Log    \n No SMOD PDU found for ENB, please check!    WARN
        RETURN
    END
    FOR  ${num}  IN RANGE  ${enb_bbu_num}
        ${enb_SMOD_PDU_IP}    Get Variable Value    ${tl.enbs[0].system_module.common_units[${num}].pdu_port.pdu.addr}
        ...    ${tl.enbs[0].dus[0].airscale.common_units[${num}].pdu_port.pdu.addr}
        ${enb_SMOD_PDU_PORT}    Get Variable Value    ${tl.enbs[0].system_module.common_units[${num}].pdu_port.port_no}
        ...     ${tl.enbs[0].dus[0].airscale.common_units[${num}].pdu_port.port_no}
        ${enb_SMOD_PDU_VENDOR}    Get Variable Value    ${tl.enbs[0].system_module.common_units[${num}].pdu_port.pdu.vendor}
        ...    ${tl.enbs[0].dus[0].airscale.common_units[${num}].pdu_port.pdu.vendor}
        IF    '${enb_SMOD_PDU_VENDOR}'=='Gude'
            ${enb_SMOD_PDU_VERSION}    Get Variable value
            ...    ${tl.enbs[0].system_module.common_units[${num}].pdu_port.pdu.version}
            ...    ${tl.enbs[0].dus[0].airscale.common_units[${num}].pdu_port.pdu.version}
            pdu.Setup Pdu
            ...    host=${enb_SMOD_PDU_IP}
            ...    model=${enb_SMOD_PDU_VENDOR}
            ...    version=${enb_SMOD_PDU_VERSION}
            ...    alias=enbsmodpdu
        ELSE
            pdu.Setup Pdu
            ...    host=${enb_SMOD_PDU_IP}
            ...    model=${enb_SMOD_PDU_VENDOR}
            ...    alias=enbsmodpdu
        END
        IF    '${action}'=='OFF'
            pdu.power_off    port=${enb_SMOD_PDU_PORT}    pdu_device=enbsmodpdu
        ELSE
            pdu.power_on    port=${enb_SMOD_PDU_PORT}    pdu_device=enbsmodpdu
        END
        ${pdu_status}=  pdu.get_port_status    port=${enb_SMOD_PDU_PORT}  pdu_device=enbsmodpdu
        ${expected_status}=    Convert to lowercase    ${action}
        Should contain    ${pdu_status}    ${expected_status}
    END
    [Teardown]    Run Keyword And Ignore Error    pdu.teardown_pdu    pdu_device=enbsmodpdu

Check PDU Status
    ${rf_pdu_status}      Run Keyword And Return Status    Check RF PDU
    ${smod_pdu_status}    Run Keyword And Return Status    Check SMOD PDU
    Set Global Variable     ${rf_pdu_status}
    Set Global Variable     ${smod_pdu_status}
    Run Keyword If        (${rf_pdu_status}==${False} or ${smod_pdu_status}==${False}) and ${RECOVERY} and '${force_power_on}'=='false'
    ...                   Log To Console    \n ${red}PDU Status is OFF, recovery will be not executed!${rm_color} \n
    ...    ELSE IF        (${rf_pdu_status}==${False} or ${smod_pdu_status}==${False}) and ${RECOVERY} and '${force_power_on}'=='true'
    ...                   Log To Console    \n ${red}PDU Status is OFF, recovery will be executed!${rm_color} \n
    ${TESTLINE_OFF}       Set Variable If    (${rf_pdu_status}==${False} or ${smod_pdu_status}==${False}) and '${force_power_on}'=='false'
    ...                   ${True}    ${TESTLINE_OFF}
    Set Global Variable     ${TESTLINE_OFF}

Check RF PDU
    FOR    ${item}    IN RANGE    ${rf_num}
        ${status}     Run Keyword And Return Status    Variable Should Exist
        ...           ${tl.${gnb_or_enb}s[0].dus[0].rus[${item}].pdu_port.pdu.addr}
        ${version}    Get Variable Value    ${tl.${gnb_or_enb}s[0].dus[0].rus[${item}].pdu_port.pdu.version}    None
        Run Keyword If    ${status}
        ...               Get PDU Status    tl.${gnb_or_enb}s[0].dus[0].rus[${item}]    ${version}    ${gnb_or_enb}rfpdu
        ...       ELSE    Log To Console    ${red}Check RF PDU was not performed - pdu not set!${rm_color}
    END

Check SMOD PDU
    FOR    ${item}    IN RANGE    ${smod_num}
        ${status}     Run Keyword And Return Status    Variable Should Exist
        ...          ${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[${item}].pdu_port.pdu.addr}
        ${version}    Get Variable Value    ${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[${item}].pdu_port.pdu.version}    None
        Run Keyword If    ${status}
        ...               Get PDU Status    tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[${item}]    ${version}    ${gnb_or_enb}smodpdu
        ...       ELSE    Log To Console    ${red}Check SMOD PDU was not performed - pdu not set!${rm_color}
    END

Get PDU Status
    [Arguments]      ${path}    ${version}    ${alias}
    pdu.Setup Pdu    host=${${path}.pdu_port.pdu.addr}
    ...              model=${${path}.pdu_port.pdu.vendor}
    ...              version=${version}
    ...              alias=${alias}
    ${pdu_status}=    pdu.get_port_status    port=${${path}.pdu_port.port_no}
    ...                                      pdu_device=${alias}
    Run Keyword If    'TSR' in '${NODE_NAME}'    Should contain    ${pdu_status}    OFF    ignore_case=True
    ...       ELSE                               Should contain    ${pdu_status}    ON     ignore_case=True

Set Testline Status
    [Arguments]        ${TESTLINE_OFF}
    ${SET_NO_RECOVERY}    Get Variable Value    ${SET_NO_RECOVERY}    ${False}
    ${TESTLINE_OFF}    Set Variable If    ${RECOVERY}    ${True}    ${TESTLINE_OFF}
    Run Keyword If     ${SET_NO_RECOVERY}    Append To File    ${OUTPUT_DIR}/testline_status.txt    RECOVERY=NO
    ...    ELSE IF     ${TESTLINE_OFF}    Run Keywords
    ...                Log    ${red}!!! TESTLINE will be disabled !!!${rm_color}    level=WARN
    ...        AND     Append To File    ${OUTPUT_DIR}/testline_status.txt    RECOVERY=FAIL
    ...    ELSE IF     '${build_not_exists}'!='${False}'    Append To File    ${OUTPUT_DIR}/testline_status.txt    RECOVERY=FAIL
    ...       ELSE     Append To File    ${OUTPUT_DIR}/testline_status.txt    RECOVERY=SUCCESS
    ${description}     Set Variable    ${EMPTY}
    FOR    ${item}    IN    @{STEPS}
           Run Keyword If       '${${item}}'=='False'    Run Keywords
           ...                  Set Global Variable    ${description}    ${description}${item}${SPACE}
           ...        AND       Run Keyword If    '${item}'=='alarms'
           ...                  Set Global Variable    ${description}    ${description}(Not allowed alarm: ${not_allowed_list})${SPACE}
    END
    ${description_status}    Run Keyword And Return Status    Should Be Empty    ${description}
    Run Keyword If     ${rf_pdu_status}==${False} and '${force_power_on}'=='false'        Append To File    ${OUTPUT_DIR}/testline_status.txt
    ...                \ndescription=BTS Smart Recovery turned node off: Recovery was not executed because RF PDU is OFF.
    ...    ELSE IF     ${smod_pdu_status}==${False} and '${force_power_on}'=='false'    Append To File    ${OUTPUT_DIR}/testline_status.txt
    ...                \ndescription=BTS Smart Recovery turned node off: Recovery was not executed because SMOD PDU is OFF.
    ...    ELSE IF     '${build_not_exists}'!='${False}'    Append To File    ${OUTPUT_DIR}/testline_status.txt
    ...                \nbuild_not_exists=${build_not_exists}
    ...    ELSE IF     ${description_status}==${False}    Append To File    ${OUTPUT_DIR}/testline_status.txt
    ...                \ndescription=BTS Smart Recovery turned node off: Recovery was not successful, check failed: ${description}
