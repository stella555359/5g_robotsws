*** Settings ***
Documentation    This file is for QT L3call keywords
Library     BuiltIn
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     ${CURDIR}/../python/attenuator.py
Library     ${CURDIR}/../python/cus.py
Resource    ${CURDIR}/plugin_keywords.robot
Resource    ${CURDIR}/adb_keywords.robot
Resource    ${CURDIR}/fastmile_keywords.robot
Resource    ${CURDIR}/huawei_router_and_iphy_keywords.robot

*** Keywords ***
L3 Call
    [Arguments]        ${test_line_type}    ${capability}
    ${UE_indexes}    Get Dictionary Keys    ${UEs${capability}}
    FOR    ${UE_index}    IN    @{UE_indexes}
        Set Variables For L3Call    ${UE_index}    ${capability}    ${UE_indexes}
        IF    '${UE}'=='huawei_router'
            Setup And Start Tshark On VM    vm_interface=${tl.UE['S1_interface']}
        ELSE IF    '${UE}'=='cus'
            Create CUS alias  alias=UE_1  ue_id=1  id_type=cus
        END
        Prepare PC For L3Call
        Set Concurrent Variables
        Run Keyword If    '${test_line_type}'=='AIC'          AIC Preparation
        Run Keyword If    'android' in '${UE}'                Prepare NAA Plugin
        Check And Set RF Number    ${test_line_type}    ${capability}
        Create Directories For L3Call
        Set Other L3Call Variables
        IF    ${count_UEs} > 1
            ${RF}    Evaluate    ${UE_index}+1
            Perform L3call    ${RF}    ${test_line_type}
        ELSE
             FOR    ${RF}    IN RANGE    1    ${index}+1
                Run Keyword If    'RF${RF}' in $RF_LIST    Perform L3call    ${RF}    ${test_line_type}
             END
        END
    END

Set Variables For L3Call
    [Arguments]    ${UE_index}    ${capability}    ${UE_indexes}
    ${count_UEs}    Get Length    ${UE_indexes}
    Set Test Variable    ${count_UEs}
    ${UE}    Get From Dictionary    ${UEs${capability}}    ${UE_index}
    Set Test Variable    ${UE}
    Set Test Variable    ${UE_index}
    Set Test Variable    ${attach_was_performed}    ${False}
    Set UE Variables   ${capability}    ${count_UEs}
    ${attenuation_port}    Get Variable Value    ${tl.attenuation['attenuation_port']}    3001
    Set Suite Variable    ${attenuation_port}

Teardown After L3Call
    ${is_atten}    Get Variable Value      ${is_atten}     ${False}
    ${UE}    Get Variable Value    ${UE}    ${EMPTY}
    IF    '${UE}' == ''
        Log    L3call test is not performed, skip teardown
        RETURN
    END
    IF    'WRO' in '${site}' and ('android' in '${UE}' or '${UE}' in ${UE_with_qualcomm_chip}) and ${ue_is_locked}
        Unlock PC
    END
    IF    'android' in '${UE}'
        Run Keyword And Ignore Error    Kill sshd And Start Cygwin
    END
    IF    '${UE}'=='huawei_router'
        Run Keyword and Ignore Error    Stop Tshark On VM
    END
    IF    '${UE}'=='cus'
        End CUS Scope
    END
    IF    'WRO' in '${site}' and ${is_atten}
        Run Keyword And Ignore Error
        ...    Wait until Keyword Succeeds    2x    30s    Suppress Attenuators After Test
    END

Create Directories For L3Call
    Create Directory    ${OUTPUT DIR}/L3_Call
    ${ue_log_dir}         Set Variable If    '${capability}'=='_2G'    ${OUTPUT DIR}/L3_Call/2G_call
    ...                                      '${capability}'=='_3G'    ${OUTPUT DIR}/L3_Call/3G_call
    ...                                      '${capability}'=='_4G'    ${OUTPUT DIR}/L3_Call/4G_call
    ...                                      '${capability}'=='_5G'    ${OUTPUT DIR}/L3_Call/5G_call
    Run Keywords                              Set Global Variable      ${ue_log_dir}
    ...                   AND                 Create Directory         ${ue_log_dir}

Check And Set RF Number
    [Arguments]    ${test_line_type}    ${capability}
    Run Keyword If   ${is_TDD_concurrent} == ${True}   Check MRAT RF number
    ...   ELSE IF    ${is_multi_RAT} == ${True}   Check MRAT RF number
    ...   ELSE IF    '${test_line_type}'=='classical'    Check RF Number
    ...   ELSE IF    '${test_line_type}'=='cudu'         Check RF Number    bts_host=${DU_coam_LMP_IP}
    ${index} =         Set Variable If   ${is_TDD_concurrent}==${True} or (${is_multi_RAT}==${True} and ${dualcore}==${True})    ${5G_CELL_length}
    ...                ${is_multi_RAT}==${True} and '${capability}'=='_2G' and ${dualcore}==${False}    ${GSM_CELL_length}
    ...                ${is_multi_RAT}==${True} and '${capability}'=='_3G' and ${dualcore}==${False}    ${WCDMA_CELL_length}
    ...                ${is_multi_RAT}==${True} and '${capability}'=='_4G' and ${dualcore}==${False}    ${LTE_CELL_length}
    ...                ${rf_number}
    Set Suite Variable    ${index}
    @{RF_LIST} =          BuiltIn.Set Variable If
    ...                   '${UE}'=='huawei_router'    ${4G_RF_LIST}
    ...                   '${UE}'=='cus'             ${4G_RF_LIST}
    ...                   '${UE}'=='fastmile' and ${is_TDD_concurrent}==${False} and '${capability}'=='_4G'    ${4G_RF_LIST}
    ...                   '${capability}'=='_2G'      ${GSM_RF_LIST}
    ...                   '${capability}'=='_3G'      ${WCDMA_RF_list}
    ...                   '${capability}'=='_4G'      ${LTE_RF_LIST}
    ...                   ${5G_RF_LIST}
    Set Global Variable    ${RF_LIST}

Prepare PC For L3Call
    Run Keyword If    ${has_cpc}    CPC info log
    Run Keyword If    '${UE}'=='askey'    Get CPC OS    cpc_addr=${cpc_addr}
    ...                cpc_username=${cpc_username}
    ...                cpc_password=${cpc_password}
    IF    'WRO' in '${site}' and ('android' in '${UE}' or '${UE}' in ${UE_with_qualcomm_chip})
        ${is_locked}    Run Keyword And Return Status    PC lock
        Set Suite Variable    ${ue_is_locked}    ${is_locked}
        IF    not ${is_locked}
            Fail
        END
    END
    Run Keyword If    'WRO' not in '${site}' and '${UE}'=='askey'    Check System Type

Set UE Variables
    [Arguments]    ${capability}    ${count_UEs}
    ${has_cpc}     Set Variable If    '${UE}'!='cus' and '${UE}'!='huawei_router' and '${UE}'!='fastmile'
    ...                               True    False
    IF    ${has_cpc}
        ${cpc_addr}        Get Variable Value    ${tl.ues[${UE_index}].ssh_connection_details.addr}        ${tl.ues[${UE_index}].ue_pc_address}
        ${cpc_password}    Get Variable Value    ${tl.ues[${UE_index}].ssh_connection_details.password}    ${tl.ues[${UE_index}].ue_pc_password}
        ${cpc_username}    Get Variable Value    ${tl.ues[${UE_index}].ssh_connection_details.username}    ${tl.ues[${UE_index}].ue_pc_login}
        Set Test Variable    ${cpc_addr}
        Set Test Variable    ${cpc_password}
        Set Test Variable    ${cpc_username}
    END
    Set Device Model     ${capability}
    ${index}    Evaluate    ${UE_index}+1
    ${capability_index}    Set Variable If    ${UE_index} > 0 and ${count_UEs} > 1    ${capability}_${index}    ${capability}
    Builtin.Set Global Variable    ${capability}
    Builtin.Set Global Variable    ${capability_index}
    Set Test Variable    ${has_cpc}
    Set Suite Variable    ${ue_is_locked}   False

Set Concurrent Variables
    ${is_TDD_concurrent}    Get Variable Value   ${tl.custom['TDD_concurrent']}   ${False}
    ${is_FDD_concurrent}    Get Variable Value   ${tl.custom["FDD_concurrent"]}   ${False}
    ${is_multi_RAT}         Get Variable Value   ${tl.custom['is_MRAT']}   ${False}
    Set Test Variable       ${is_TDD_concurrent}
    Set Test Variable       ${is_FDD_concurrent}
    Set Test Variable       ${is_multi_RAT}

Set Other L3Call Variables
    ${isLTE}       Run Keyword And Return Status    Should Not Be Empty    ${LTE_RF_LIST}
    ${is_atten}    Run Keyword And Return Status    Variable Should Exist    ${tl.attenuation['attenuation_index']}
    ${attenuator_type}     Get Variable Value    ${tl.attenuation['attenuator_type']}    not_set
    Set Test Variable     ${isLTE}
    Set Test Variable     ${is_atten}
    Set Test Variable     ${attenuator_type}

CPC info log
    ${cpc_info}    Set Variable
    ...    ${cpc_addr} ->
    ...    ${cpc_username} / ${cpc_password}
    Run Keyword and Ignore Error    Log To Console    PC connection: ${cpc_info}

Set Device Model
    [Arguments]        ${capability}
    ${ue_num}    get length    ${tl.ues}
    FOR    ${index}    IN RANGE    ${ue_num}
        ${device_model}    Set Variable If    '${capability}' in $tl.ues[${index}].capabilities    ${tl.ues[${index}].serial_number}
        ...    None
        Exit For Loop If    '${device_model}' != 'None'
    END
    ${device_model}    Set Variable If    '${device_model}' == 'None'    ${tl.ues[0].serial_number}    ${device_model}
    Set Global Variable    ${device_model}

AIC Preparation
    ${adblog_check}=   Get Variable Value       ${adblog_check}   False
    Set Suite Variable       ${adblog_check}
    ${oam_web_ip}   set variable if   ':' in '''${DU_WEBUI_IP}'''   [${DU_WEBUI_IP}]    ${DU_WEBUI_IP}
    IF    ${is_LTE}
        Wait Until Keyword Succeeds    2min    10s    lte_vdu.connect to
        ...    host=${oam_web_ip}
        ...    port=${EMPTY}
        ...    username=Nemuadmin
        ...    password=Nokia@123
        ...    secure=True
    ELSE
        Wait Until Keyword Succeeds    2min    10s  vdu.connect to
        ...    host=${oam_web_ip}
        ...    port=${EMPTY}
        ...    username=Nemuadmin
        ...    password=Nokia@123
        ...    vdu_version=cuoam_24r3   #Hardcode due to no key "power_state" of RF status in cuoam_24r3
        ...    secure=True
    END
    ${cell_info}    Check vDU RF Number
    ${cell_id_index}=   Get Variable Value       ${DU_cell_id_of_Shared_CU}    1
    ${cell_id}=  Evaluate  ${cell_id_index}
    Set Suite Variable    ${cell_id}
    IF    ${is_LTE}
        ${CellId}    Set Variable    ${cell_info['lncel'][0]['basicCell']['eutraCelId']}
    ELSE
        ${CellId}    set variable    ${cell_info[0]['NRCELL-${cell_id}']}
    END
    Log To Console    --> CellId is ${CellId}

Test L3 Call
    [Arguments]       ${RF}=1
    Preconditions For Test L3 Call
    ${attach}    Run Keyword And Return Status    Attach to the UE    ${RF}
    Postconditions For Attach    ${attach}    ${RF}
    ${data_transfer}    Run Keyword And Return Status    Perform Data Transfer
    Postconditions For Data Transfer    ${data_transfer}    ${RF}

Postconditions For Data Transfer
    [Arguments]    ${data_transfer}    ${RF}
    BuiltIn.Set Global Variable    ${data_transfer_RF${RF}}    ${data_transfer}
    ${status}         Run Keyword And Return Status    Variable Should Exist    ${message_${RF}}
    Run Keyword If    ${status}==${True} and ${data_transfer_RF${RF}}==${False}
    ...               Log To Console      Data transfer failed on RU[${RF}]: ${message_${RF}}
    Should Be True    ${data_transfer}    msg=Data Transfer Failed

Postconditions For Attach
    [Arguments]    ${attach}    ${RF}
    BuiltIn.Set Global Variable    ${attach_RF${RF}}    ${attach}
    Should Be True    ${attach}    msg=Attach Failed

Preconditions For Test L3 Call
    Run Keyword If    ${has_cpc}     Run Keywords    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                cpc_username=${cpc_username}
    ...                cpc_password=${cpc_password}
    ...  AND  Run Keyword and Ignore Error    Kill sshd process in controlPC
    ...  AND  ADB Check if device is offline or unauthorized and reboot  device=${device_model}

Attach to the UE
    [Arguments]       ${RF}
    Log To Console    \n\t ============================ UE ${UE} ATTACH RF ${RF} =====================
    TRY
        Run Keyword If    'android' in '${UE}'          Wait Until Keyword Succeeds    1x  30s    Plugin Attach    ${RF}
        ...    ELSE IF    '${UE}' == 'quectel'          Wait Until Keyword Succeeds    1x  30s    Plugin Attach     ${RF}
        ...    ELSE IF    '${UE}' == 'simcom'           Wait Until Keyword Succeeds    1x  30s    Plugin Attach     ${RF}
        ...    ELSE IF    '${UE}' == 'askey'            Wait Until Keyword Succeeds    1x  30s    Plugin Attach    ${RF}
        ...    ELSE IF    '${UE}' == 'cus'              Wait Until Keyword Succeeds    1x  30s    UE Attach CUS
        ...    ELSE IF    '${UE}' == 'huawei_router'    Wait Until Keyword Succeeds    1x  30s    Attach Huawei Router
        ...    ELSE IF    '${UE}' == 'fastmile'         Wait Until Keyword Succeeds    1x  30s    fastmile Attach    ${capability}
        ...       ELSE    Fail
        ...   No UE defined, or UE not in list: qualcomm, askey, android, cus, huawei_router, fastmile.
    EXCEPT  .*AssertionError.*    type=Regexp
        Log    AssertionError occurs, skip log warning to console!
        Fail
    EXCEPT  AS  ${error}
        Log    ${UE} attach failed due to ${error}    WARN
        Set Suite Variable    ${L3call_exception}    ${error}
        Fail
    END
    Log To Console    \n\t ============================ ATTACH END ==============================

Perform Data Transfer
    Log To Console    \n\t ========================== DATA TRANSFER ============================
    TRY
        Run Keyword If    'android' in '${UE}'           Check Plugin Data Transfer
        ...    ELSE IF    '${UE}' == 'quectel'           Check Plugin Data Transfer
        ...    ELSE IF    '${UE}' == 'simcom'            Check Plugin Data Transfer
        ...    ELSE IF    '${UE}' == 'askey'             Check Plugin Data Transfer
        ...    ELSE IF    '${UE}' == 'cus'               Check CUS Data Transfer
        ...    ELSE IF    '${UE}' == 'huawei_router'     Perform And Check Huawei Router Data Transfer
        ...    ELSE IF    '${UE}' == 'fastmile'          Fastmile Data Transfer    ${capability}
        ...       ELSE    Fail
        ...    No UE defined, or UE not in list: qualcomm, askey, android, cus, huawei_router, fastmile.
    EXCEPT  .*AssertionError.*    type=Regexp
        Log    AssertionError occurs, skip log warning to console!
        Fail
    EXCEPT  AS  ${error}
        Log    ${UE} data transfer failed due to ${error}    WARN
        Set Suite Variable    ${L3call_exception}    ${error}
        Fail
    END
    Log To Console    \n\t ======================== DATA TRANSFER END ===========================

Detach UE
    [Arguments]       ${RF}
    Log To Console    \n\t ============================ DETACH UE ==============================
    ${detach}    Set Variable     ${True}
    IF    'android' in '${UE}'
        ${detach}    Run Keyword And Return Status    taf.ue.Detach Ue     ${capability_index}
    ELSE IF    '${UE}' == 'quectel'
        Log To Console    Skipping detach for Quectel UE
    ELSE IF    '${UE}' == 'simcom'
        ${detach}    Run Keyword And Return Status    taf.ue.Detach Ue     ${capability_index}
    ELSE IF    '${UE}' == 'askey'
        ${detach}    Run Keyword And Return Status    taf.ue.Detach Ue     ${capability_index}
    ELSE IF    '${UE}' == 'cus'
        ${detach}    Run Keyword And Return Status    UE Detach CUS
    ELSE IF    '${UE}' == 'huawei_router'
        ${detach}    Run Keyword And Return Status    UE Detach Huawei Router
    ELSE IF    '${UE}' == 'fastmile'
        ${detach}    Run Keyword And Return Status    Fastmile Detach    ${capability}
    ELSE
        Fail    No UE defined, or UE not in list: qualcomm, askey, android, cus, huawei_router, fastmile.
    END
    Run Keyword If    not ${detach}    Log    UE detach failed on RF${RF}, pls check    WARN
    BuiltIn.Set Global Variable    ${detach_RF${RF}}    ${True}
    Log To Console    \n\t ============================ DETACH END ==============================

Reverse IQ on AEUD
    ${standard_cond}  Catenate    '${RU_type}'=='AEUD' and '${STREAM_NUMBER}'!='0.800' and '${STREAM_NUMBER}'!='0.190'
    ...                           and '${STREAM_NUMBER}'!='10.1800' and '${STREAM_NUMBER}'!='10.1100'
    ${1834_cond}      Catenate    '${RU_type}'=='AEUD' and ('${STREAM_NUMBER}'=='0.800' or '${STREAM_NUMBER}'=='0.190'
    ...                           or '${STREAM_NUMBER}'=='10.1800' or '${STREAM_NUMBER}'=='10.1100')
    ${standard_cond}  Evaluate    ${standard_cond}
    ${1834_cond}      Evaluate    ${1834_cond}
    Run Keyword If    ${standard_cond}    Reverse IQ on AEUD Standard
    Run Keyword If    ${1834_cond}        Reverse IQ on AEUD with 1834 Feature

Reverse IQ on AEUD Standard
    [Documentation]   Executes workaround on AEUD conducted unit (IQ reversal, done by Antenna Modules,
    ...               not present in TRX module).
    ${cu_du}          Get Variable Value    ${cu_du}    ${False}
    Run Keyword If    'class' in '${tl.tl_cloud_topology}' or '${cu_du}' == 'True'
    ...               Wait Until Keyword Succeeds    5min    30s    connect to ASIK    alias=asik
    ${proxy}          Set Variable If    'class' in '${tl.tl_cloud_topology}' or '${cu_du}' == 'True'    asik    BB1
    Run Keyword If    'cloud' in '${tl.tl_cloud_topology}' and '${cu_du}' != 'True'    Run Keywords
    ...               Connect to OAM    AND
    ...               Connect to DU from OAM
    ssh.connect_to    hostname=${RADIO_EOC_IP_ECPRI}    username=${RADIO_USERNAME}
    ...               password=${RADIO_PASSWORD}        alias=radio    proxy=${proxy}
    ssh.execute       /sbin/devmem 0xa0205030 32 0x0    connection=radio    timeout=60s
    ssh.execute       ssh 192.168.100.2 /sbin/devmem 0xa0205030 32 0x0    connection=radio    timeout=60s
    Log To Console    \n--> INFO: Workaround: AEUD Conducted -> IQ Constellation reversed.

Reverse IQ on AEUD with 1834 Feature
    [Documentation]   Reverse IQ on AEUD must be done when it's a conducted mode.
    ${RU_pass}        Get Variable Value  ${tl.${gnb_or_enb}s[0].dus[0].rus[0].default_ssh_connection_details.password}  umniedziala
    Connect To Common Unit Master    alias=asik
    ${out_put}        ssh.execute    command=cat /ffs/run/config/FRIps.txt    connection=asik    timeout=60s
    Log               ${out_put}
    ${pattern}        Set Variable          \(\(\\d\)\{1,3\}\\.\)\{3\}\(\\d\)\{1,3\}
    ${match_output}   Get Regexp Matches    ${out_put}    ${pattern}
    ${rf_ip}          Set Variable          ${match_output[0]}
    reserve_iq_data_feat_1834               rf_ip=${rf_ip}    alias=asik    password=${RU_pass}
    Log To Console    \n--> INFO: Workaround: AEUD Conducted -> IQ Constellation reversed.

Check Attenuator Status
    [Arguments]       ${ip}   ${pdu_ip}=${tl.attenuation['pdu_attenuator_ip']}
    ...               ${pdu_port}=${tl.attenuation['pdu_attenuator_port']}   ${model}=${pdu_model}
    ...               ${atten_port}=${attenuation_port}
    ${status}         Run Keyword And Return Status    Wait Until Keyword Succeeds    3x    10s    check_attenuator   ${ip}   ${atten_port}
    Log To Console    \n --> Attenuator active: ${status}
    Run Keyword If    '${status}'=='False'   Run Keywords
    ...               Wait Until Keyword Succeeds    3x    3 min    Reset Attenuator and Check
    ...               ${ip}    ${pdu_ip}    ${pdu_port}    ${model}
    ...        AND    Wait Until Keyword Succeeds    3x    3 min    Recall Attenuator    ${ip}
    [Teardown]    Telnet.close_connection

Reset Attenuator and Check
    [Arguments]         ${att_ip}=${tl.attenuation['attenuator_ip']}    ${pdu_ip}=${tl.attenuation['pdu_attenuator_ip']}
    ...                 ${pdu_port}=${tl.attenuation['pdu_attenuator_port']}    ${model}=${pdu_model}
    ...                 ${atten_port}=${attenuation_port}
    ${pdu_version}      Get Variable Value    ${tl.attenuation['pdu_attenuator_version']}    ${None}
    Reset port on PDU   PDU_IP=${pdu_ip}    PDU_PORT=${pdu_port}    model=${model}    version=${pdu_version}
    Wait Until Keyword Succeeds    2min  15s    check_attenuator    ${att_ip}   ${atten_port}

Check Telnet Connection to Attenuator
    [Arguments]         ${ip}=${tl.attenuation['attenuator_ip']}    ${port}=${attenuation_port}
    ${status}           Run Keyword And Return Status    Telnet.Open connection    ${ip}    port=${port}
    Should Contain      '${status}'    True
    [Teardown]    Telnet.close_connection

Recall Attenuator
    [Arguments]         ${ip}
    Telnet.Open connection    ${ip}    ${attenuation_port}
    Telnet.set_timeout  60s
    Telnet.set prompt   ${EMPTY}
    Telnet.Execute Command    recall
    BuiltIn.Sleep               5s
    Telnet.Execute Command    store
    BuiltIn.Sleep               5s
    [Teardown]          Telnet.close_connection

Check Cell Setup Classical
    Log To Console      --> INFO: Checking cell setup..
    Wait Until Keyword Succeeds    1min    15s    coam.connect to
    ...                            bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   update_interval=1000   name=coam_admin
    Wait Until Keyword Succeeds    3min    30s    Verify COAM Cell Setup 3RF
    [Teardown]    coam.teardown    connection=coam_admin

Verify COAM Cell Setup 3RF
    ${output}             coam.get_cells_info    timeout=30    connection=coam_admin
    Log Many              ${output}
    Should Not Be Empty   ${output}
    ${index}              Set Variable    ${1}
    FOR   ${elem}   IN    @{output}
        Should contain    ${elem['status']['operationalState']}    Enabled       ignore_case=True
        Should contain    ${elem['status']['proceduralStatus']}    configured    ignore_case=True
        Log To Console    \n RF${index} => ${elem['status']['operationalState']}
        ${index}          Set Variable    ${index + 1}
    END

Suppress Attenuators
    [Arguments]    ${atteunator}    ${dictionary}    ${attenuator_index}=0
    Log To Console      --> INFO: Suppressing test line attenuation
    att.Setup Attenuator      ${atteunator}
    ${ports}      Evaluate    list(${dictionary}.keys())
    ${values}     Evaluate    [90] * ${{len($ports)}}
    Log To Console    --> INFO: Ports to suppress: ${ports}
    Log To Console    --> INFO: Values to set: ${values}
    Wait Until Keyword Succeeds    60s    10s
    ...    att.Set Ports Attenuation    ${ports}    ${values}
    Read Attenuation And Continue With Warning    ${ports}    attenuator_index=${attenuator_index}
    Run Keyword And Ignore Error    att.disconnect

Read Attenuation And Continue With Warning
    [Arguments]    ${ports}    ${attenuator_index}=0
    TRY
        ${checks}    Wait Until Keyword Succeeds    90s    10s
        ...    att.Read Ports Attenuation    ${ports}
        IF    $checks is not None
            FOR    ${index}    IN RANGE    ${{len($ports)}}
                Log To Console
                ...    --> INFO: On Attenuator: ${tl.attenuators[${attenuator_index}].ip_addr} Port#${ports[${index}]} = ${checks[${index}]} dB
            END
        ELSE
            Fail    Read Ports Attenuation failed!!!!
        END
    EXCEPT  AS  ${error}
        Log    Read Attenuation FAILED due to ${error}, continue test!!!    WARN
    END

Setup And Verify Attenuation
    [Arguments]    ${atteunator_ip}    ${dictionary}    ${attenuator_index}=0
    att.Setup Attenuator    ${atteunator_ip}
    Log To Console      --> INFO: Setting test line attenuation
    ${ports}    Evaluate    list(${dictionary}.keys())
    ${values}   Evaluate    list(${dictionary}.values())
    Log To Console   --> Ports to set: ${ports}
    Log To Console   --> Values to set: ${values}
    att.Set Ports Attenuation    ${ports}    ${values}
    ${checks}     Run Keyword And Continue On Failure    att.Read Ports Attenuation    ${ports}
    IF    $checks is not None
        Log To Console  --> INFO: On ${tl.attenuators[${attenuator_index}].ip_addr}, Attenuations: ${checks} dB
    ELSE
        Log    Read Ports Attenuation failed on PA ${tl.attenuators[${attenuator_index}].ip_addr}!!!    WARN
    END
    Run Keyword And Ignore Error    att.disconnect

Collect UE logs flag
    ${collect_UE_logs}  Set Variable    ${True}
    BuiltIn.Set Global Variable    ${collect_UE_logs}

Perform L3call
    [Arguments]    ${RF}    ${test_line_type}
    Set Suite Variable              ${RF}
    ${first_call}                   Run Keyword And Return Status    Test L3 Call    RF=${RF}
    Retry Preparation For L3Call    ${first_call}    ${test_line_type}
    Run Keyword If                  ${first_call}==False    Run Keyword And Continue On Failure
    ...                             Test L3 Call    RF=${RF}
    [Teardown]     Detach UE    RF=${RF}

Retry Preparation For L3Call
    [Arguments]    ${first_call}    ${test_line_type}
    ${skip_L3Call_retest}    Get Variable Value    ${skip_L3Call_retest}    ${False}
    IF    ${first_call}
        Log to console    \n L3 call passed on the first try. \n
    ELSE IF    ${skip_L3Call_retest}
        Log To Console    \n ======= FIRST TRY FAILED. SKIP L3 CALL RETEST======= \n
        Fail    First L3 Call failed, skip retest
    ELSE
        Log To Console    \n ======= FIRST TRY FAILED. RETRY L3 CALL ======= \n
        Run Keyword and Ignore Error
        ...    Run Keyword If    '${attach_RF1}'=='${False}' and '${test_line_type}'=='AIC'    AIC_TDD_teardown
        Run Keyword and Ignore Error
        ...    Run Keyword If    '${test_line_type}'=='AIC' and '${dl_tput}'=='0.0' and '${ul_tput}'=='0.0'
        ...                       AIC_TDD_teardown
        IF    '${UE}'=='cus' and ${first_call}==False
            Run Keyword and Ignore Error    UE Detach CUS
        ELSE IF    '${first_call}'=='False' and '${UE}' == 'huawei_router'
            Restart Router
        END
    END

Kill sshd process in controlPC
    [Arguments]    ${alias}=controlPC
    ${cpc_type}=  get_cpc_osd  ${alias}
    Run Keyword If  '${cpc_type}'=='Windows'  kill_sshd_session_on_windows     ${alias}

Check status of adb device
    ${capability}    Get Variable Value    ${capability}    _5G
    ${device}        Get Variable Value    ${device_model${capability}}    ${device_model}
    Set Test Variable   ${device_model}    ${device}
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    ADB Check if device is offline or unauthorized and reboot    device=${device_model}
    ${device_in_adb}    Run Keyword And Return Status    ADB devices    device=${device_model}
    Set test variable   ${device_in_adb}
    [Teardown]    ssh.disconnect    connection=controlPC

PC lock
    [Documentation]   PC lock for case with multiple UEs on one PC    author: Michal Werstler
    Check System Type
    Log To Console    \n--> Locking PC lock for ${tl.tl_cloud_topology}_controlPC.lock...
    ${not_lock}    Run Keyword And Return Status    Wait Until Keyword Succeeds     30min  5sec    Check lock on control PC
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    Run Keyword If    ${not_lock}    Run Keywords
    ...          ssh.send_command    type nul > ${tl.tl_cloud_topology}_controlPC.lock    connection=controlPC
    ...   AND    Log To Console    --> PC locked: /home/wro5gqt or C:\\Users\\wro5gqt\\ > ${tl.tl_cloud_topology}_controlPC.lock
    ...   ELSE   Fail    PC is still locked by shared TL!!!
    [Teardown]    ssh.disconnect    connection=controlPC

Check System Type
    [Documentation]       Check system connection type cygwin/openSSH    author: Michal Werstler
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    ${system_connection_type}    check_system_connection_type    controlPC
    BuiltIn.Set Global Variable    ${system_connection_type}
    [Teardown]    ssh.disconnect    connection=controlPC

Check lock on control PC
    [Documentation]       PC lock for case with multiple UEs on one PC    author: Michal Werstler
    Connect to controlPC    cpc_addr=${cpc_addr}
    ...                     cpc_username=${cpc_username}
    ...                     cpc_password=${cpc_password}
    Run Keyword If         '${system_connection_type}' == 'cygwin'    Run Keywords
    ...                   ssh.send_command    rm ${tl.tl_cloud_topology}_controlPC.lock    connection=controlPC
    ...    AND            ssh.send_command    ls    connection=controlPC
    ...    ELSE           Run Keywords
    ...                   ssh.send_command    del ${tl.tl_cloud_topology}_controlPC.lock    connection=controlPC
    ...    AND            ssh.send_command    dir    connection=controlPC
    ${lock info}          ssh.read_output    connection=controlPC
    Should Not Contain    ${lock info}    controlPC.lock
    [Teardown]    ssh.disconnect    connection=controlPC

Unlock PC
    [Documentation]     PC unlock for case with multiple UEs on one PC    author: Michal Werstler
    TRY
        Connect to controlPC    cpc_addr=${cpc_addr}
        ...                     cpc_username=${cpc_username}
        ...                     cpc_password=${cpc_password}
        Run Keyword If    '${system_connection_type}' == 'cygwin'    ssh.send_command    rm *.lock    connection=controlPC
        ...    ELSE       ssh.send_command    del *.lock    connection=controlPC
        Log To Console      \n--> PC unlocked\n
    EXCEPT    AS    ${error}
        Log    \n!!!PC unlock failed due to ${error}!!!\n    WARN
    END
    [Teardown]    ssh.disconnect    connection=controlPC

Set Attenuators 1RF
    Run Keyword If    '${pdu_model}'!='None'    Check Attenuator Status    ${tl.attenuators[0].ip_addr}    ${tl.attenuation['pdu_attenuator_ip']}
    ...                                                                    ${tl.attenuation['pdu_attenuator_port']}    ${pdu_model}
    ${att}    Get Variable Value    ${tl.attenuation['attenuation_index']['att']}    ${False}
    IF    '${att}'!='${False}'
        Wait Until Keyword Succeeds    10x    15s    Setup And Verify Attenuation
        ...    ${tl.attenuators[0]}    ${tl.attenuation['attenuation${capability}']}     ${tl.attenuation['attenuation_index']['att']}
    END
    Set Other Attenuation

Set Other Attenuation
    ${NSA}    Get Variable Value    ${tl.attenuation['attenuation_index']['eNB']}    ${False}
    IF    '${NSA}'!='${False}'
        Wait Until Keyword Succeeds    10x    15s    Setup And Verify Attenuation
        ...    ${tl.attenuators[${NSA}]}   ${tl.attenuation['eNB_attenuation']}    ${tl.attenuation['attenuation_index']['eNB']}
    END
    ${other}    Get Variable Value    ${tl.attenuation['attenuation_index']['other']}    ${False}
    IF    '${other}'!='${False}'
        Wait Until Keyword Succeeds    10x    15s    Setup And Verify Attenuation
        ...    ${tl.attenuators[${other}]}    ${tl.attenuation['attenuation${capability}_other']}    ${tl.attenuation['attenuation_index']['other']}
    END

Set Attenuation For 3RF
    [Documentation]    Set attenuation for 5G testlines with 3 radio modules
    Wait Until Keyword Succeeds    2x    10s    Set Attenuators 3RF

Set Attenuators 3RF
    [Documentation]    Keyword is checking attenuator status by executing Check Attenuator Status For 3RF keyword and then tries to set
    ...                attenuations. To set attenuations in small number of steps dictionary groupped_attenuation is generated based on values stored
    ...                in attenuation_rfx and attenuation_index in __init__.py ex. generated dictionary for 3 RFs, first two RF served by attenuator
    ...                with index 'att_index0' and 3rd RF by attenuator with index 'att_index1' and L3 test performed for RF1 with
    ...                port1: value1, port2: value2 attenuations taken from attenuation_rf1 in __init__.py:
    ...                {att_index0: {port1: value1, port2: value2, port3: 90, port4: 90}, att_index1: {port1: 90, port2: 90}}
    ...    PRE: Keyword requires correctly defined and filled tl.attenuation structure from __init__.py
    ...    POST: Keyword checks attenuators and set attenuations for 3RF based on values defined in tl.attenuation structure from __init__.py.
    ...          If tl.attenuation['attenuation_index'] dictionary is not defined, checking and setting of attenuation is skipped.
    ${atten_index}    Get Variable Value    ${tl.attenuation['attenuation_index']}    ${False}
    IF    ${atten_index} != ${False}
        Run Keyword If    '${pdu_model}'!='None'    Check Attenuator Status For 3RF
        ${grouped_attenuation}=    generate_grouped_attenuation     tl_attenuation=${tl.attenuation}    attenuation_key=attenuation_rf${RF}
        FOR    ${key}    ${value}    IN    &{grouped_attenuation}
            Log To Console    \nAttenuator index: ${key}, attenuation to set for RF${RF}: ${value}
            Wait Until Keyword Succeeds    10x    15s    Setup And Verify Attenuation    ${tl.attenuators[${key}]}    ${value}     ${key}
        END
        Set Other Attenuation
    ELSE
        Log To Console    \nVariable tl.attenuation['attenuation_index'] doesn't exist in __init__.py, skipping checking and setting attenuation.
    END

Check Attenuator Status For 3RF
    [Documentation]    Keyword checks if attenuators are active and print statuses. Dictionary reduced_attenuation_index is storing only first keys
    ...                which indexes from  ${tl.attenuation['attenuation_index']} are unique. Unique attenuators have unique indexes. If all rfs are
    ...                connected to the same attenuator, data stored in pdu_attenuator_rfx_port is redundant.
    ...    PRE: Keyword require defined in __init__.py  attenuator indexes, attenuator ip address,
    ...         ip address of the PDU to which attenuator is connected , PDU port used to supply attenuator, PDU model.
    ...    POST: Keyword check attenuators statuses and print them.
    ${reduced_attenuation_index}=    reduce_attenuation_index    ${tl.attenuation['attenuation_index']}
    FOR    ${key}    ${value}    IN    &{reduced_attenuation_index}
        Log To Console    \nChecking attenuator status for attenuator index: ${value}
        Check Attenuator Status    ${tl.attenuators[${value}].ip_addr}    ${tl.attenuation['pdu_attenuator_ip']}
    ...                            ${tl.attenuation['pdu_attenuator_${key}_port']}    ${pdu_model}
    END

Suppress Attenuators After Test
    [Documentation]    Keyword suppress attenuations in the way that depends on TL configuration.
    ...                In 3RF case grouped_attenuation dictionary is generated by generate_grouped_attenuation function.
    ...                Because of suppress=${True} parameter is passed to the generate_grouped_attenuation all attenuation values are set to 90.
    ...                In current implementation of Suppress Attenuators keyword it doesn't matter but was done just in case.
    ...                Example of generated dictionary for 3 RFs, first two RF served by attenuator with index 'att_index0' and 3rd RF by attenuator
    ...                with index 'att_index1': {att_index0: {port1: 90, port2: 90, port3: 90, port4: 90}, att_index1: {port1: 90, port2: 90}}
    ...    PRE: Keyword requires properly filled values in tl.attenuation and tl.custom in __init__.py
    ...    POST: Keyword surpass attenuations after L3 call in the method depending on TL configuration.
    ${att}    Get Variable Value    ${tl.attenuation['attenuation_index']['att']}    ${False}
    IF    '${isLTE}'=='${False}' and '${rf_number}'=='3'
        ${grouped_attenuation}=    generate_grouped_attenuation     tl_attenuation=${tl.attenuation}    attenuation_key=attenuation_rf${RF}
        ...                                                         suppress=${True}
        FOR    ${key}    ${value}    IN    &{grouped_attenuation}
            Suppress Attenuators      ${tl.attenuators[${key}]}    ${value}    ${key}
        END
    ELSE IF    '${att}'!='${False}'
        Suppress Attenuators    ${tl.attenuators[0]}    ${tl.attenuation['attenuation${capability}']}
    END
    ${NSA}    Get Variable Value    ${tl.attenuation['attenuation_index']['eNB']}    ${False}
    IF    '${NSA}'!='${False}'
        Suppress Attenuators
        ...    ${tl.attenuators[${NSA}]}
        ...    ${tl.attenuation['eNB_attenuation']}
        ...    ${tl.attenuation['attenuation_index']['eNB']}
    END
    ${other}    Get Variable Value    ${tl.attenuation['attenuation_index']['other']}    ${False}
    IF    '${other}'!='${False}'
        Suppress Attenuators
        ...   ${tl.attenuators[${other}]}
        ...   ${tl.attenuation['attenuation${capability}_other']}
        ...   ${tl.attenuation['attenuation_index']['other']}
    END

Get CPC OS
    [Documentation]       get cpc os type  windows/linux
    [Arguments]         ${cpc_addr}=${tl.ues[0].ssh_connection_details.addr}
    ...                 ${cpc_username}=${tl.ues[0].ssh_connection_details.username}
    ...                 ${cpc_password}=${tl.ues[0].ssh_connection_details.password}
    ...                 ${alias}=controlPC
    Connect to controlPC    cpc_addr=${cpc_addr}    cpc_username=${cpc_username}    cpc_password=${cpc_password}    alias=${alias}
    ${cpc_type}         get_cpc_osd     ${alias}
    BuiltIn.Set Global Variable    ${cpc_type}
    [Teardown]    ssh.disconnect    connection=${alias}
