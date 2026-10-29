*** Settings ***
Documentation
...   author: Sreekumar Narimuri Kumaran
...   contact: sreekumar.narimuri_kumaran@nokia.com
...   Description: Topyoung attenuator resource file for ORAN CRT testline BTS1025/1026

Library    BuiltIn
Library    taf.hw.rf_attenuator    WITH NAME    atten

*** Variables ***
@{port_numbers}    1    2    3    4    5    6    7    8    9    10    11
${source_bts_rf_port}    5
${target_bts_rf_port}    9
${source_bts_rp1_rf_port}    2
@{attenuation_values_Startup1}    5dB    15dB    10dB    10dB    15dB    5dB    20dB    0dB
@{attenuation_values_Startup2}    30dB    40dB    50dB    60dB    70dB    90dB    120dB
@{attenuation_values_Trigger}    40dB    5dB    35dB    10dB    30dB    15dB    25dB    20dB    20dB    25dB    15dB    30dB
...     10dB    40dB    5dB    50dB    0dB    50dB
@{attenuation_values_Trigger_Load}    40dB    35dB    30dB    25dB    20dB    15dB    10dB    5dB    0dB
@{attenuation_values_Trigger_Load_CSFB1}    80dB    15dB    75dB    10dB    60dB    5dB    50dB    0dB
@{attenuation_values_Trigger_Load_CSFB2}    30dB    20dB    10dB    0dB
@{attenuation_values_Trigger_Load_SRVCC_target}    80dB		60dB	40dB	20dB	10dB	5dB	   0dB
@{attenuation_values_Trigger_Load_SRVCC_source}    5dB		10dB	20dB	40dB	60dB	80dB
@{rp1_cells_port_set_to_no_attenuation}    80dB		60dB	40dB	20dB	10dB	5dB	   0dB

*** Keywords ***
Setup Attenuator
    [Arguments]    ${pva_ip}    ${vendor}    ${model}
    atten.setup_attenuator    vendor=${vendor}    ip_addr=${pva_ip}    model=${model}    port=3001
	...    attenuation_port_numbers=${port_numbers}

Set Attenuation Values
    [Arguments]    ${port}    @{values}
    ${length}=    Get length    ${values}
    FOR    ${i}    IN RANGE    0    ${length}
        ${value}=    Set Variable    ${values[${i}]}
        log to console    ${value}
        atten.set_attenuation    port=${port}    value=${value}    confirm=True    confirmation_delay=5
    END

Set Attenuation Pairs
    [Arguments]    ${port1}    ${port2}    @{values}
    ${length}=    Get length    ${values}
    FOR    ${i}    IN RANGE    0    ${length}    2
        ${value1}=    Set Variable    ${values[${i}]}
        log to console    ${value1}
        ${i}=    Evaluate    ${i}+1
        ${value2}=    Set Variable    ${values[${i}]}
        log to console    ${value2}
        atten.set_attenuation    port=${port1}    value=${value1}    confirm=True    confirmation_delay=5
        atten.set_attenuation    port=${port2}    value=${value2}    confirm=True    confirmation_delay=5
    END

PVA_Attenuator_startup
    [Arguments]    ${pva_ip}    ${vendor}    ${model}
    Setup Attenuator    ${pva_ip}    ${vendor}    ${model}
    Set Attenuation Pairs    ${target_bts_rf_port}    ${source_bts_rf_port}    @{attenuation_values_Startup1}
    Set Attenuation Values    ${target_bts_rf_port}    @{attenuation_values_Startup2}

PVA_Attenuator_Trigger
    [Arguments]    ${pva_ip}    ${vendor}    ${model}
    Setup Attenuator    ${pva_ip}    ${vendor}    ${model}
    Set Attenuation Pairs    ${target_bts_rf_port}    ${source_bts_rf_port}    @{attenuation_values_Trigger}

PVA_Attenuator_Trigger_load
    [Arguments]    ${pva_ip}    ${vendor}    ${model}
    Setup Attenuator    ${pva_ip}    ${vendor}    ${model}
    Set Attenuation Values    ${target_bts_rf_port}    @{attenuation_values_Trigger_Load}

PVA_Attenuator_startup_CSFB
    [Arguments]    ${pva_ip}    ${vendor}    ${model}
    Setup Attenuator    ${pva_ip}    ${vendor}    ${model}
    Set Attenuation Pairs    ${target_bts_rf_port}    ${source_bts_rf_port}    @{attenuation_values_Trigger_Load_CSFB1}
    Set Attenuation Values    ${target_bts_rf_port}    @{attenuation_values_Trigger_Load_CSFB2}

PVA_Attenuator_SRVCC
    [Arguments]    ${pva_ip}    ${vendor}    ${model}
    Setup Attenuator    ${pva_ip}    ${vendor}    ${model}
	Set Attenuation Values    ${target_bts_rf_port}    @{attenuation_values_Trigger_Load_SRVCC_target}
	Set Attenuation Values    ${source_bts_rf_port}    @{attenuation_values_Trigger_Load_SRVCC_source}

PVA_Attenuator_no_att_for_rp1_radio
    [Arguments]    ${pva_ip}    ${vendor}    ${model}
    Setup Attenuator    ${pva_ip}    ${vendor}    ${model}
    Set Attenuation Values    ${source_bts_rp1_rf_port}    @{rp1_cells_port_set_to_no_attenuation}

PVA_Attenuator_full_att_for_rp1_radio
    [Arguments]    ${pva_ip}    ${vendor}    ${model}
    Setup Attenuator    ${pva_ip}    ${vendor}    ${model}
    Set Attenuation Values    ${source_bts_rp1_rf_port}    @{attenuation_values_Startup2}
