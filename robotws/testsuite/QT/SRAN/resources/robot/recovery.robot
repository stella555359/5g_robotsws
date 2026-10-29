*** Settings ***
Documentation       Robot keywords for Smart Recovery Test Case
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      taf.hw.pdu  WITH NAME   pdu
Library      ${CURDIR}/../python/pdu_lib.py

Resource     ${CURDIR}/states.robot
Resource     ${CURDIR}/common.robot
Resource     ${CURDIR}/classical_keywords.robot
Resource     ${CURDIR}/additional_check.robot

*** Keywords ***
Recovery Suite Setup
    Create Directory    ${OUTPUT DIR}/Additional_Execution_Logs
    Set GNB or ENB Flag
    ${rf_num}      Get Length            ${tl.${gnb_or_enb}s[0].dus[0].rus}
    ${smod_num}    Get Length            ${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units}
    ${ue_type}     Get Variable Value    ${tl.ues[0].ue_type}    None
    Set Suite Variable    ${rf_num}
    Set Suite Variable    ${smod_num}
    Set Suite Variable    ${ue_type}
    Run Keyword And Ignore Error    Start BTSlogs Collection

Recovery Suite Teardown
    WA for coam connect
    Stop BTSlogs Collection And Get Logs    target_path=${OUTPUT_DIR}    local_path=${tl.tl_cloud_topology}_SYSLOG_
    Save Snapshot For Classical
    [Teardown]    coam.teardown    connection=coam_admin

Perform Site Reset
    TRY
        WA for coam connect
        Log To Console    \n Perform Site Reset
        coam.Reset Site    connection=coam_admin
    EXCEPT  AS  ${error}
        Log To Console  --> !!!Warning!!! Perform Site Reset Failed due to ${error}
    END
    [Teardown]    coam.teardown    connection=coam_admin

Perform Power Reset
    Log To Console    \n Perform smod power off
    Run Keyword If    '${site}'=='TSR'    Run Keywords
    ...    Log To Console    Note: reversed PDU action is performed on TSR site!!!!
    ...    AND    Power On SMOD
    ...    ELSE   Power Off SMOD
    Log To Console    \n Perform rf power off
    Run Keyword If    '${site}'=='TSR'    Run Keywords
    ...    Log To Console    Note: reversed PDU action is performed on TSR site!!!!
    ...    AND    Power On RF
    ...    ELSE   Power Off RF
    Log To Console    \n Perform smod power on
    Run Keyword If    '${site}'=='TSR'    Run Keywords
    ...    Log To Console    Note: reversed PDU action is performed on TSR site!!!!
    ...    AND    Power Off SMOD
    ...    ELSE   Power On SMOD
    Log To Console    \n Perform rf power on
    Run Keyword If    '${site}'=='TSR'    Run Keywords
    ...    Log To Console    Note: reversed PDU action is performed on TSR site!!!!
    ...    AND    Power Off RF
    ...    ELSE   Power On RF

Check If Alarm SW Fallback Exists
    WA for coam connect    bts_host=192.168.255.129
    ${active_alarms}       coam.get_active_alarms    connection=coam_admin
    ${sw_fallback}         Run Keyword And Return Status    Should Contain    ${active_alarms}    SW fallback    ignore_case=True
    Set Suite Variable     ${sw_fallback}
    [Teardown]    coam.teardown    connection=coam_admin

Perform Rollback
    [Arguments]    ${bts_host}=192.168.255.129
    Get BTS SW Version      log=rollback    bts_host=${bts_host}    coam_connection=${True}
    Log To Console          Perform software rollback
    WA for coam connect     bts_host=${bts_host}
    Rollback Software       connection=coam_admin
    BuiltIn.Sleep    10s
    [Teardown]    coam.teardown    connection=coam_admin

Verify BTS State By Ping
    [Arguments]    ${ip}=192.168.255.129    ${not_pingable}=True    ${wait_ping_time}=6min
    Run Keyword If    ${not_pingable}    Run Keywords    Log To Console    \n Check If BTS Is Not Pingable
    ...        AND    Wait Until Keyword Succeeds    120s    10s
    ...        Check If BTS Is Pingable    ip=${ip}    Pingable_or_NotPingable=NotPingable
    Log To Console                 ${SPACE}Check If BTS Is Pingable
    Wait Until Keyword Succeeds    ${wait_ping_time}    10s    Check If BTS Is Pingable    ip=${ip}

Verify Rollback
    Check If BTS Is Pingable
    ${target_SW}    Set Variable    ${passive_SW}
    Get BTS SW Version    time=2min    log=rollback    coam_connection=${True}
    Should Be True    '${target_SW}'=='${active_SW}'    Rollback Software failed

Verify BTS After Recovery
    Wait Until Keyword Succeeds      5min  30s    WA for coam connect
    Log To Console                   \n Verify BTS After Recovery \n
    Log To Console                   \t Verify Smod Detection
    Wait Until Keyword Succeeds      5min  30s    Check Smod State
    Log To Console                   \t | PASS | \n
    Get Smod Name
    Run Keyword If                   'ASO' not in '${smod_type}'       Run Keywords
    ...                              Log To Console                   \t Verify BBmod Detection
    ...        AND                   Wait Until Keyword Succeeds      5min  30s    Check BBmod State
    ...        AND                   Log To Console                   \t | PASS | \n
    Log To Console                   \t Verify RF Detection
    Wait Until Keyword Succeeds      10min  30s     Check RF Status    logs=${True}
    Log To Console                   \t | PASS | \n
    Verify Cells Setup For Recovery
    Log To Console                   \t | PASS | \n
    [Teardown]    coam.teardown      connection=coam_admin

Verify Cells Setup For Recovery
    [Arguments]    ${time}=10min
    Log To Console                   \t Verify Cells Setup
    IF    '${ue_type}'=='cus'
        Wait Until Keyword Succeeds    ${time}  30s    Verify CUS Cells Setup
    ELSE
        Wait Until Keyword Succeeds    ${time}  30s    Verify Cells Setup
    END

Verify CUS Cells Setup
    ${cell_list}    Get Parameters For All    class_name=LNCEL    timeout=30    connection=coam_admin
    FOR    ${cell}    IN    @{cell_list}
        Log Many    ${cell}
        ${validated}    Run Keyword And Return Status    Should Be Equal As Strings
        ...             ${cell['proceduralState']}     validated    ignore_case=True
        ${onairdone}    Run Keyword And Return Status    Should Be Equal As Strings
        ...             ${cell['proceduralState']}     onairdone    ignore_case=True
        Should Be True    ${validated} or ${onairdone}
    END

Get Smod Name
    Connect to Common Unit          alias=smod
    ${smod_type}                    get_board_name    board=master    hw_config=${hw_config}    connection=smod
    Set Global Variable               ${smod_type}
    [Teardown]    ssh.disconnect    connection=smod

Power ${OnorOff} ${SMODorRF}
    FOR    ${item}    IN RANGE    ${${SMODorRF.lower()}_num}
        ${SMOD_pdu_addr}=   Get Variable Value
        ...           ${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[${item}].pdu_port.pdu.addr}   None
        ${RF_pdu_addr}=    Get Variable Value
        ...           ${tl.${gnb_or_enb}s[0].dus[0].rus[${item}].pdu_port.pdu.addr}    None
        ${SMOD_pdu_port}=   Get Variable Value
        ...    ${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[${item}].pdu_port.port_no}   None
        ${RF_pdu_port}=    Get Variable Value
        ...    ${tl.${gnb_or_enb}s[0].dus[0].rus[${item}].pdu_port.port_no}    None
        ${SMOD_pdu_version}=   Get Variable Value
        ...    ${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[${item}].pdu_port.pdu.version}   default
        ${RF_pdu_version}=    Get Variable Value
        ...    ${tl.${gnb_or_enb}s[0].dus[0].rus[${item}].pdu_port.pdu.version}     default
        ${SMOD_pdu_vendor}=   Get Variable Value
        ...    ${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[${item}].pdu_port.pdu.vendor}   None
        ${RF_pdu_vendor}=    Get Variable Value
        ...    ${tl.${gnb_or_enb}s[0].dus[0].rus[${item}].pdu_port.pdu.vendor}     None
        Run Keyword If    '${${SMODorRF}_pdu_addr}'!='None'    common.Power ${OnorOff} PDU Port
        ...                            PDU_IP=${${SMODorRF}_pdu_addr}
        ...                            PDU_PORT=${${SMODorRF}_pdu_port}
        ...                            version=${${SMODorRF}_pdu_version}
        ...                            alias=pdu
        ...                            model=${${SMODorRF}_pdu_vendor}
        ...       ELSE    Log To Console    Power Reset ${SMODorRF}${item} was not performed - pdu not set!
    END

Power Reset SMOD
    FOR    ${item}    IN RANGE    ${smod_num}
        ${status}     Run Keyword And Return Status    Variable Should Exist
        ...           ${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[${item}].pdu_port.pdu.addr}
        ${version}    Get Variable Value    ${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[${item}].pdu_port.pdu.version}    default
        Run Keyword If    ${status}    Reset port on PDU
        ...                            PDU_IP=${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[${item}].pdu_port.pdu.addr}
        ...                            PDU_PORT=${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[${item}].pdu_port.port_no}
        ...                            version=${version}
        ...                            alias=smodpdu
        ...                            model=${tl.${gnb_or_enb}s[0].dus[0].airscale.common_units[${item}].pdu_port.pdu.vendor}
        ...       ELSE    Log To Console    Power Reset SMOD${item} was not performed - pdu not set!
    END

Power Reset RF
    FOR    ${item}    IN RANGE    ${rf_num}
        ${status}     Run Keyword And Return Status    Variable Should Exist
        ...           ${tl.${gnb_or_enb}s[0].dus[0].rus[${item}].pdu_port.pdu.addr}
        Run Keyword If    ${status}    Reset port on PDU
        ...                            PDU_IP=${tl.${gnb_or_enb}s[0].dus[0].rus[${item}].pdu_port.pdu.addr}
        ...                            PDU_PORT=${tl.${gnb_or_enb}s[0].dus[0].rus[${item}].pdu_port.port_no}
        ...                            version=${tl.${gnb_or_enb}s[0].dus[0].rus[${item}].pdu_port.pdu.version}
        ...                            alias=rfpdu
        ...                            model=${tl.${gnb_or_enb}s[0].dus[0].rus[${item}].pdu_port.pdu.vendor}
        ...       ELSE    Log To Console    Power Reset RF${item} was not performed - pdu not set!
    END

Power Cycle Askey Shieldbox
    Log To Console    --> WARN: adb device not available! -> Power cycle ShieldBox
    ${pdu_reboot}     Run Keyword And Return Status    reboot_pdu_port    ip=${tl.custom['askey_pdu_ip']}    port=${tl.custom['askey_pdu_port']}
    Log To Console    ${pdu_reboot}
    Run Keyword If    '${pdu_reboot}'=='${True}'    Run Keywords
    ...    Log To Console    --> INFO: ASKEY PDU reboot SUCCEED waiting for device [60 sec...]
    ...    AND        BuiltIn.Sleep    60s
    ...    ELSE IF    '${pdu_reboot}'!='True'    Log To Console    --> INFO: ASKEY pdu reboot FAILED
    [Teardown]    Set Suite Variable    ${askey_reboot}    True
