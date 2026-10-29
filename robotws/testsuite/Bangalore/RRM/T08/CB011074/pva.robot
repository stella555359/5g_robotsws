*** Settings ***
Documentation
...  Description: Topyoung attenuator resource file for ORAN CRT testline BTS1042

Library  BuiltIn
Library  taf.hw.rf_attenuator  WITH NAME  atten

*** Variables ***
${pva_ip}  10.45.153.212
${vendor}  TOPYOUNG
${model}  TAS16T16-51-120-1N-DEJS
@{port_numbers}  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15  16
${rf_port_14}  14
${rf_port_13}  13
${rf_port_15}  15
@{attenuation_values_cell3}  0dB  10dB  30dB  40dB  50dB  40dB  25dB  10dB  0dB
@{attenuation_values_cell4}  0dB  120dB  10dB  120dB  13dB  120dB  16dB  120dB  19dB  40dB  22dB  40dB
...  25dB  40dB  28dB  45dB  31dB  30dB  34dB  30dB  37dB  20dB  40dB  10dB
...  45dB  0dB  50dB  0dB
@{attenuation_values_cell5}  120dB  0dB  120dB  10dB  120dB  20dB  50dB  35dB  0dB  40dB
...  0dB  90dB  0dB  80dB
@{attenuation_values_cell6}  0dB  10dB  20dB  30dB  40dB  50dB  58dB
@{attenuation_values_cell7}  0dB  10dB  20dB  35dB  50dB  35dB  20dB  5dB  0dB
@{attenuation_values_cell8}  120dB
@{attenuation_values_cell10}  50dB  120dB
${value1}  0dB
${value2}  120dB

*** Keywords ***
Setup Attenuator
    [Arguments]  ${pva_ip}  ${vendor}  ${model}
    atten.setup_attenuator  vendor=${vendor}  ip_addr=${pva_ip}  model=${model}  port=3001
    ...  attenuation_port_numbers=${port_numbers}

Set Attenuation Values
    [Arguments]  ${port}  @{values}
    ${length}=  Get length  ${values}
    FOR  ${i}  IN RANGE  0  ${length}
        ${value}=  Set Variable  ${values[${i}]}
        log to console  ${value}
        atten.set_attenuation  port=${port}  value=${value}  confirm=True  confirmation_delay=5
    END

Set Attenuation Pairs
    [Arguments]  ${port1}  ${port2}  @{values}
    ${length}=  Get length  ${values}
    FOR  ${i}  IN RANGE  0  ${length}  2
        ${value1}=  Set Variable  ${values[${i}]}
        log to console  ${value1}
        ${i}=  Evaluate  ${i}+1
        ${value2}=  Set Variable  ${values[${i}]}
        log to console  ${value2}
        atten.set_attenuation  port=${port1}  value=${value1}  confirm=True  confirmation_delay=5
        atten.set_attenuation  port=${port2}  value=${value2}  confirm=True  confirmation_delay=5
    END

PVA_Attenuator_Cell1
    [Arguments]  ${pva_ip}  ${vendor}  ${model}
    Setup Attenuator  ${pva_ip}  ${vendor}  ${model}
    atten.set_attenuation  port=${rf_port_14}  value=${value1}  confirm=True  confirmation_delay=2
    atten.set_attenuation  port=${rf_port_13}  value=${value2}  confirm=True  confirmation_delay=2
    atten.set_attenuation  port=${rf_port_15}  value=${value2}  confirm=True  confirmation_delay=2

PVA_Attenuator_Cell2
    [Arguments]  ${pva_ip}  ${vendor}  ${model}
    Setup Attenuator  ${pva_ip}  ${vendor}  ${model}
    atten.set_attenuation  port=${rf_port_14}  value=${value2}  confirm=True  confirmation_delay=2
    atten.set_attenuation  port=${rf_port_13}  value=${value1}  confirm=True  confirmation_delay=2

PVA_Attenuator_Cell3
    [Arguments]  ${pva_ip}  ${vendor}  ${model}
    Setup Attenuator  ${pva_ip}  ${vendor}  ${model}
    Set Attenuation Values  ${rf_port_14}  @{attenuation_values_cell3}

PVA_Attenuator_Cell4
    [Arguments]  ${pva_ip}  ${vendor}  ${model}
    Setup Attenuator  ${pva_ip}  ${vendor}  ${model}
    Set Attenuation Pairs  ${rf_port_14}  ${rf_port_13}  @{attenuation_values_cell4}

PVA_Attenuator_Cell5
    [Arguments]  ${pva_ip}  ${vendor}  ${model}
    Setup Attenuator  ${pva_ip}  ${vendor}  ${model}
    Set Attenuation Pairs  ${rf_port_14}  ${rf_port_13}  @{attenuation_values_cell5}

PVA_Attenuator_Cell6
    [Arguments]  ${pva_ip}  ${vendor}  ${model}
    Setup Attenuator  ${pva_ip}  ${vendor}  ${model}
    Set Attenuation Values  ${rf_port_14}  @{attenuation_values_cell6}

PVA_Attenuator_Cell7
    [Arguments]  ${pva_ip}  ${vendor}  ${model}
    Setup Attenuator  ${pva_ip}  ${vendor}  ${model}
    Set Attenuation Values  ${rf_port_14}  @{attenuation_values_cell7}

PVA_Attenuator_Cell8
    [Arguments]  ${pva_ip}  ${vendor}  ${model}
    Setup Attenuator  ${pva_ip}  ${vendor}  ${model}
    Set Attenuation Values  ${rf_port_14}  @{attenuation_values_cell8}

PVA_Attenuator_Cell9
    [Arguments]  ${pva_ip}  ${vendor}  ${model}
    Setup Attenuator  ${pva_ip}  ${vendor}  ${model}
    atten.set_attenuation  port=${rf_port_14}  value=${value2}  confirm=True  confirmation_delay=2
    atten.set_attenuation  port=${rf_port_13}  value=${value1}  confirm=True  confirmation_delay=2

PVA_Attenuator_Cell10
    [Arguments]  ${pva_ip}  ${vendor}  ${model}
    Setup Attenuator  ${pva_ip}  ${vendor}  ${model}
    atten.set_attenuation  port=${rf_port_14}  value=${value1}  confirm=True  confirmation_delay=2
    Set Attenuation Values  ${rf_port_13}  @{attenuation_values_cell10}
