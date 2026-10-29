*** Settings ***
Documentation
...    Maintainer: Michal Dziedzic, michal.dziedzic@nokia.com
Library     taf.hw.pdu    WITH NAME    pdu
Library     mix_keywords.py

Resource    BasicKeywords.robot

*** Variables ***
${Radio_PB_IP}          ${tl.pdus[0].addr}
${Radio_PB_Port}        ${tl.pdus[0].port_numbers}
${PDU_LOGIN}            ${tl.pdus[0].login}
${PDU_PASSWORD}         ${tl.pdus[0].password}
${Radio_alias}          Radio_PDU
${mv_cmd}               mv /mnt/factory/configs/unit/calibration_dlpath1.bin /mnt/factory/configs/unit/temp_calibration_dlpath1
${mv_cmd_backup}        mv /rom/factory_backup/calibration_dlpath1.bin /rom/factory_backup/temp_calibration_dlpath1
${restore_cmd}          mv /mnt/factory/configs/unit/temp_calibration_dlpath1 /mnt/factory/configs/unit/calibration_dlpath1.bin
${restore_cmd_backup}   mv /rom/factory_backup/temp_calibration_dlpath1 /rom/factory_backup/calibration_dlpath1.bin
${FID_4589}             4589
${FName_4589}           Unit power reset
&{Signature_4589}       category=POWER_OFF
...                     scope=RFM
${FID_4590}             4590
${FName_4590}           Fault signature for crash or failure
&{Signature_4590}       category=SW_FAILURE
...                     minor=RFM_GPP
...                     info=resetCause=1,resetSignal=26
${FID_1901}             1901
${FName_1901}           Radio autonomous reset as recovery action
&{Signature_1901}       category=SW_FAILURE
...                     extraInfo=faulty_cells=NR:1


*** Keywords ***
Power Reset Radio
    pdu.setup_pdu    model=FPFH
    ...              host=${Radio_PB_IP}
    ...              alias=${Radio_alias}
    ...              login=${PDU_LOGIN}
    ...              password=${PDU_PASSWORD}
    pdu.reset_ports    ports=${Radio_PB_Port}
    ...                time_interval=${10}
    ...                pdu_device=${Radio_alias}

Rename Radio File Via Cmd
    [Arguments]    ${cmd}=${mv_cmd}    ${cmd2}=${mv_cmd_backup}
    mix_keywords.connect_to_gnb    ${GNB_HTTP_ADDR}
    Wait Until Keyword Succeeds    6m    20s    Get RU IP Until Succeeds
    Sleep    20s
    mix_keywords.rename_ru_file    ${RU_IP}    CMD=${cmd};${cmd2}
    [Teardown]     Run Keyword And Ignore Error    mix_keywords.disconnect_to_gnb

Cancel Fault 1901
    Rename Radio File Via Cmd    ${restore_cmd}    ${restore_cmd_backup}
    Sleep    5m
    Connect to gnb coam via ssl   connection=default    bts_host=${GNB_HTTP_ADDR}
    ${is_active}    ADMIN Is Alarm Active   1901    connection=default
    Run Keyword If    ${is_active}     Rename Radio File Via Cmd    ${restore_cmd}    ${restore_cmd_backup}
    Wait Until Keyword Succeeds    600 sec    60 sec    Verify gNB is onAir

Get RU IP Until Succeeds
    ${RU_IP}    mix_keywords.get_frip
    ${Result}    Run Keyword And Return Status    Should not be equal    ${RU_IP}    0.0.0.0
    Should Be True    ${Result}
    Set Test Variable    ${RU_IP}

Process Alarm History
    [Arguments]    ${fid}    ${fname}    &{signature}
    ${alarm_history}    admin_api.get_alarm_history    connection=default
    ${status}    mix_keywords.check_fault_signature    ${alarm_history}    ${fid}    ${fname}    ${TRUE}    &{signature}
    Should Be True    ${status}
