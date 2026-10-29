*** Settings ***

Documentation
...    Maintainer:    Author

Library    Collections
Library    Process
Library    String
Library    OperatingSystem

Library    taf.hw.optical_switch  WITH NAME   optical_switch


*** Variables ***
${SWITCH_VALUES}

*** Keywords ***

Actual optical switch setting
    ${dictionary_switch_value}=   Get Optical Switch Configuration  ${OUT_SWITCH_IP}   ${SWITCH_MODEL}   Leoni   default
    log to console     ${dictionary_switch_value}
    Set test variable   ${SWITCH_DICT}    ${dictionary_switch_value}
    ${list_switch_names}=   Get Dictionary Keys    ${dictionary_switch_value}
    ${list_switch_values}=   Get Dictionary Items   ${dictionary_switch_value}
    Set test variable   ${SWITCH_LIST}    ${list_switch_values}
    Set test variable   ${SWITCH_NAMES_LIST}    ${list_switch_names}

Get Optical Switch Configuration
    [Arguments]    ${addr}   ${model}   ${optical_switch}   ${alias}
    ${model}=  Set Variable         ${OPTICAL_SWITCHES_MATRIX['${model}']}
    optical_switch.setup_optical_switch
    ...    addr=${addr}
    ...    model=${model}
    ...    optical_switch=${optical_switch}
    ...    alias=${alias}
    ${switch_channels}=  optical_switch.get_optical_switch_channels    optical_switch_device=${alias}
    [Teardown]    Run Keyword And Ignore Error    optical_switch.teardown    optical_switch_device=${alias}
    [Return]    ${switch_channels}

Create Switch Settings Dictionary
    Actual optical switch setting
    ${SWITCH_SETTINGS}=   Create Dictionary
    ${SWITCH_CONECTIONS}=   Create Dictionary
    FOR  ${index}    IN    @{SWITCH_NAMES_LIST}
          ${os_port_0_type}=    evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
            ...    //Unit[@Type="${SWITCH_MODEL}"][@OpticalSwitch="Leoni"]/Switch[@SwitchSection="${index}"][@SectionPort="0"]/@Type
          ${os_port_0_SN}=    evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
            ...    //Unit[@Type="${SWITCH_MODEL}"][@OpticalSwitch="Leoni"]/Switch[@SwitchSection="${index}"][@SectionPort="0"]/@SerialNumber
          ${os_port_0_port}=    evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
            ...    //Unit[@Type="${SWITCH_MODEL}"][@OpticalSwitch="Leoni"]/Switch[@SwitchSection="${index}"][@SectionPort="0"]/@Port
          ${os_port_1_type}=    evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
            ...    //Unit[@Type="${SWITCH_MODEL}"][@OpticalSwitch="Leoni"]/Switch[@SwitchSection="${index}"][@SectionPort="1"]/@Type
          ${os_port_1_SN}=    evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
            ...    //Unit[@Type="${SWITCH_MODEL}"][@OpticalSwitch="Leoni"]/Switch[@SwitchSection="${index}"][@SectionPort="1"]/@SerialNumber
          ${os_port_1_port}=    evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
            ...    //Unit[@Type="${SWITCH_MODEL}"][@OpticalSwitch="Leoni"]/Switch[@SwitchSection="${index}"][@SectionPort="1"]/@Port
          ${os_port_2_type}=    evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
            ...    //Unit[@Type="${SWITCH_MODEL}"][@OpticalSwitch="Leoni"]/Switch[@SwitchSection="${index}"][@SectionPort="2"]/@Type
          ${os_port_2_SN}=    evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
            ...    //Unit[@Type="${SWITCH_MODEL}"][@OpticalSwitch="Leoni"]/Switch[@SwitchSection="${index}"][@SectionPort="2"]/@SerialNumber
          ${os_port_2_port}=    evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
            ...    //Unit[@Type="${SWITCH_MODEL}"][@OpticalSwitch="Leoni"]/Switch[@SwitchSection="${index}"][@SectionPort="2"]/@Port
          ${os_port_3_type}=    evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
            ...    //Unit[@Type="${SWITCH_MODEL}"][@OpticalSwitch="Leoni"]/Switch[@SwitchSection="${index}"][@SectionPort="3"]/@Type
          ${os_port_3_SN}=    evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
            ...    //Unit[@Type="${SWITCH_MODEL}"][@OpticalSwitch="Leoni"]/Switch[@SwitchSection="${index}"][@SectionPort="3"]/@SerialNumber
          ${os_port_3_port}=    evaluate xpath    ${GLO_TL_DESCRIPTOR_FILE_PATH}
            ...    //Unit[@Type="${SWITCH_MODEL}"][@OpticalSwitch="Leoni"]/Switch[@SwitchSection="${index}"][@SectionPort="3"]/@Port
          Set To Dictionary    ${SWITCH_SETTINGS}
            ...                  switch${index}_port0=${os_port_0_type[0]}${os_port_0_SN[0]}_port_${os_port_0_port[0]}
            ...                  switch${index}_port1=${os_port_1_type[0]}${os_port_1_SN[0]}_port-${os_port_1_port[0]}
            ...                  switch${index}_port2=${os_port_2_type[0]}${os_port_2_SN[0]}_port_${os_port_2_port[0]}
            ...                  switch${index}_port3=${os_port_3_type[0]}${os_port_3_SN[0]}_port_${os_port_3_port[0]}
            ...                  switch${index}_port4=None
          Log Dictionary    ${SWITCH_SETTINGS}
           Run keyword if    "${os_port_0_type[0]}"!="Switch"
            ...    Set To Dictionary    ${SWITCH_CONECTIONS}   switch${index}=${os_port_0_type[0]}${os_port_0_SN[0]}_port_${os_port_0_port[0]}
    END
    Set test Variable    ${OUT_SWITCH_SETTINGS}     ${SWITCH_SETTINGS}
    Set Test Variable    ${OUT_SWITCH_CONECTIONS}   ${SWITCH_CONECTIONS}
    Create Actual Switch Settings Directory

Create Actual Switch Settings Directory
    ${ACTUAL_SWITCH_SETTINGS}=   Create Dictionary
    ${ACTUAL_SWITCH_CONECTIONS} =   Create Dictionary
    ${list_switch}=   Get Dictionary Items   ${OUT_SWITCH_SETTINGS}
    FOR  ${key}  ${value}  IN    @{list_switch}
          ${sw}=  Run Keyword And Ignore Error   Should Match  "${value}"  "Switch*"
          Run Keyword if   "${sw[0]}"=="PASS"
            ...    Set To Dictionary    ${OUT_SWITCH_CONECTIONS}   ${key[0:7]}=switch${value[12]}
          Log Dictionary    ${OUT_SWITCH_CONECTIONS}
    END
    ${switch_con}=   Get Dictionary Items   ${OUT_SWITCH_CONECTIONS}
    ${switch_relations}=   Remove Duplicates    ${switch_con}
    FOR  ${key}  ${value}  IN    @{SWITCH_LIST}
          ${actual_set}=   get from dictionary  ${OUT_SWITCH_SETTINGS}  switch${key}_port${value}
          Set To Dictionary    ${ACTUAL_SWITCH_SETTINGS}   switch${key}=${actual_set}
    END
    Log Dictionary    ${ACTUAL_SWITCH_SETTINGS}
#    Remove Values From List  @{switch_relations}
    FOR  ${key}  ${value}  IN  @{switch_relations}
          ${sw}=  Run Keyword And Ignore Error  Should Match  "${value}"  "*switch*"
          ${x}=   set variable if   "${sw[0]}"=="PASS"   ${ACTUAL_SWITCH_SETTINGS.${value}}
          ${y}=   get from dictionary   ${ACTUAL_SWITCH_SETTINGS}   ${key}
          Run keyword if  "${sw[0]}"=="PASS"
            ...   Set To Dictionary          ${ACTUAL_SWITCH_CONECTIONS}    switch${key}_${x}=${value}_${y}   #wyrz
            ...   ELSE  Set To Dictionary    ${ACTUAL_SWITCH_CONECTIONS}    switch${key}_${y}=${value}
          Log Dictionary     ${ACTUAL_SWITCH_CONECTIONS}
    END
    Log Dictionary     ${ACTUAL_SWITCH_CONECTIONS}
    Set test variable    ${OUT_ACTUAL_SWITCH_CONECTIONS}  ${ACTUAL_SWITCH_CONECTIONS}
    Set test variable    ${OUT_ACTUAL_SWITCH_SETTINGS}    ${ACTUAL_SWITCH_SETTINGS}
    log to console     Actual Switch Connections: ${ACTUAL_SWITCH_CONECTIONS}

Hot Remove All BTS Links
    [Arguments]    ${switch_ip}=${OUT_SWITCH_IP}
    ...            ${model}=${SWITCH_MODEL}    ${alias}=default
    ${switch_settings} =   Create Dictionary
    ${switch_value}=  set variable   4
    ${hw_on}=   get dictionary items   ${OUT_ACTUAL_SWITCH_CONECTIONS}
    FOR   ${index}  IN    @{hw_on}
          ${switch_connection}=   Run Keyword And Ignore Error   Get From Dictionary  ${SWITCH_DICT}   ${index[0:7]}
          ${bts}=   Run Keyword And Ignore Error   Should Match  "${index}"   "*${OUT_CURRENT_SM_SERIAL_NUMBERS[0]}*"
          Run keyword if  "${bts[0]}"=="PASS" and "${switch_connection[0]}"=="PASS"
          ...    Set To Dictionary    ${switch_settings}   ${index[0:7]}=${switch_value[0]}
          Run keyword if  "${bts[0]}"=="PASS" and "${switch_connection[0]}"=="FAIL"  Run keywords
          ...    Remove From Dictionary   ${switch_settings}   switch3
          ...    AND   Set To Dictionary    ${switch_settings}   switch3=${switch_value[0]}
          Run keyword if  "${bts[0]}"=="FAIL"  Run keyword if  "${switch_connection[0]}"=="PASS"
          ...    Set To Dictionary   ${switch_settings}   ${index[0:7]}=${switch_connection[1]}
    END
    Log Dictionary   ${switch_settings}
    ${os_config_settings_list}    Set Optical Configuration    ${switch_settings}
    ${switch_settings}=   Setup Optical Switch Configuration   ${switch_ip}   ${model}   Leoni   ${os_config_settings_list}  ${alias}
    sleep  60s


Hot Insert All BTS Links
    [Arguments]    ${switch_ip}=${OUT_SWITCH_IP}
    ...            ${model}=${SWITCH_MODEL}    ${alias}=default
    ${os_config_settings_list}    Set Optical Configuration    ${SWITCH_DICT}
    ${switch_settings}=  Setup Optical Switch Configuration   ${switch_ip}   ${model}   Leoni   ${os_config_settings_list}  ${alias}
    sleep  60s


Optical Switch Channel Change
    [Arguments]    ${switch_ip}   ${port_change}   ${model}=6x4
    ${Optical_switch_settings_link}=  convert to string    ${port_change}
    ${Optical_switch_settings_link}=  evaluate   ${Optical_switch_settings_link}
    ${os_config_settings_list}    Set Optical Configuration    ${Optical_switch_settings_link}
    ${switch_settings}=  Setup Optical Switch Configuration   ${switch_ip}   ${model}   Leoni   ${os_config_settings_list}  ${alias}


Optical Switch Set Multiple Channels Based On Dictonary
    [Arguments]    ${switch_ip}    ${dictionary_settings}    ${model}=6x4
    ${os_config_settings_list}    Set Optical Configuration    ${dictionary_settings}
    ${switch_settings}=  Setup Optical Switch Configuration   ${switch_ip}   ${model}   Leoni   ${os_config_settings_list}  default
    Sleep  2s


Optical Switch Get Channels For Hot Insert Collection
    [Arguments]    ${switch_ip}
    [Documentation]   author: tadeusz.brylkowski@nokia.com
    ...               Return only channels needed for hot remove collection.
    Get Optical Switch Configuration    ${switch_ip}   ${model}   Leoni   default
    Remove From Dictionary    ${optical_channels}   4   5
    ${os_config_settings_list}    Set Optical Configuration    ${optical_channels}
    ${switch_settings}=  Setup Optical Switch Configuration   ${switch_ip}   ${model}   Leoni   ${os_config_settings_list}  default
    [Return]   ${switch_settings}

Optical Switch Prepare Values For Channel Changes
    [Arguments]    ${switch_channel_list_to_change}    ${channel_value_list_to_change}
    ${optical_channels_new}=   Create Dictionary
    ${keys_switch}=    Get Dictionary Keys    ${switch_channel_list_to_change}
    ${temp}=   set variable  0
    ${temp}=   convert to integer  ${temp}
    FOR    ${out_index}    IN    @{keys_switch}
        Set To Dictionary   ${optical_channels_new}    ${out_index}     ${channel_value_list_to_change[${temp}]}
        ${temp}=   evaluate  ${temp}+1
    END
    [Return]  ${optical_channels_new}

Optical Switch Prepare Value For Channel Change
    [Arguments]  ${sm_port_list}  ${port_number_to_change}
    ${sm_port_list}=  Set Variable  ${sm_port_list[0]}
    ${sm_port_list}=  Convert To Integer   ${sm_port_list}
    ${sm_port_list}=  Evaluate  ${sm_port_list} + 1
    ${sm_port_list}=  Convert To String  ${sm_port_list}
    ${switch}=  Set Variable  switch
    ${out_switch_value}=  Catenate  SEPARATOR=  ${switch}  ${sm_port_list}
    ${out_dictionary_value}=  create dictionary
    Set To Dictionary   ${out_dictionary_value}   ${out_switch_value}   ${port_number_to_change}
    [Return]   ${out_dictionary_value}

Optical Switch Return Switch Section For Channel Value
    [Arguments]    ${switch_ip}      ${value_to_change}    ${alias}=default
    ${dictionary_optical_channels}=   Get Optical Switch Configuration  ${switch_ip}   ${SWITCH_MODEL}   Leoni   default
    Remove From Dictionary    ${dictionary_optical_channels}     4   5    6
    ${switch_values}=   Get Dictionary Values    ${dictionary_optical_channels}
    ${switch_keys}=    Get Dictionary Keys    ${dictionary_optical_channels}
    ${channel_value}=    Optical Switch Check Vaule     ${switch_values}    ${value_to_change}    ${switch_keys}
    [Return]    ${channel_value}


Optical Switch Check Vaule
    [Arguments]    ${switch_values}    ${value_to_change}    ${switch_keys}
    @{out_switch_section}=    Create List
    ${count_items}=    Get Length    ${switch_values}
    FOR     ${index}    IN RANGE    ${count_items}
        Run Keyword If    ${switch_values[${index}]}==${value_to_change}    Append To List    ${out_switch_section}    ${switch_keys[${index}]}
    END
    [Return]    ${out_switch_section[0]}


Optical Switch Remove Optical Link
    [Arguments]    ${sm_port_list}    ${switch_value}    ${switch_ip}   ${model}=${SWITCH_MODEL}  ${alias}=default
    ${section_to_change}=    Optical Switch Return Switch Section For Channel Value    ${switch_ip}    ${sm_port_list}
    ${dictionary_switch_value}=    Create Dictionary   ${section_to_change}=${switch_value}
    ${switch_value}=    convert to integer     ${switch_value}
    ${switch_settings}=  Setup Optical Switch Settigs   ${switch_ip}   ${model}   Leoni   ${dictionary_switch_value}  ${alias}
    Sleep  1s

Optical Switch Insert Optical Link To Free Port
    [Arguments]    ${out_not_used_system_module_port}    ${switch_ip}    ${switch_value}=4
    ...            ${model}=${SWITCH_MODEL}    ${alias}=default
    ${section_to_change}=    Optical Switch Return Switch Section For Channel Value    ${switch_ip}    ${switch_value}
    ${out_not_used_system_module_port}=    convert to integer     ${out_not_used_system_module_port}
    ${dictionary_switch_value}=    Create Dictionary   ${section_to_change}=${out_not_used_system_module_port}
    ${model}=  Set Variable         ${OPTICAL_SWITCHES_MATRIX['${model}']}
    ${switch_settings}=   Setup Optical Switch Settigs   ${switch_ip}   ${model}   Leoni   ${dictionary_switch_value}  ${alias}
    sleep  20s

Optical Swich Change Port To SM Port Variable
    [Arguments]  ${sm_port_list}   ${switch_ip}    ${model}=${SWITCH_MODEL}    ${alias}=default
    ${switch_value}=   create dictionary    switch1=${sm_port_list[0]}    switch2=${sm_port_list[1]}
    ${switch_settings}=  Setup Optical Switch Configuration   ${switch_ip}   ${model}   Leoni   ${switch_value}  ${alias}
    sleep  1s
    Teardown Optical Switch    alias=${alias}


Optical Switch Insert Optical Link To Second Port
    [Arguments]    ${out_not_used_system_module_port}    ${switch_ip}    ${model}=${SWITCH_MODEL}    ${alias}=default
    ${switch_value}=  set variable   1
    ${section_to_change}=    Optical Switch Return Switch Section For Channel Value    ${switch_ip}    ${switch_value}
    ${dictionary_switch_value}=    Create Dictionary   ${section_to_change}=${out_not_used_system_module_port}
    Setup Optical Switch Configuration   ${switch_ip}   ${model}   Leoni   ${dictionary_switch_value}  ${alias}
    sleep  20s

Number of cablinks
    [Arguments]   ${switch_ip}    ${model}    ${alias}=default
    Run keyword if  "${model}"=="10x2"    Set test variable     ${OUT_EXPECTED_CABLINK_COUNT}   2
    ...    ELSE     Number of cablinks for x4 Switch    ${switch_ip}    ${model}

Number of cablinks for x4 Switch
    [Arguments]   ${switch_ip}    ${model}
    ${dictionary_optical_channels}=   Get Optical Switch Configuration  ${switch_ip}   ${model}   Leoni   default
    ${switch1}=   Get From Dictionary   ${dictionary_optical_channels}   ${1}
    ${switch2}=   Get From Dictionary   ${dictionary_optical_channels}   ${2}
    ${switch3}=   Get From Dictionary   ${dictionary_optical_channels}   ${3}
    ${matches}=   Get Regexp Matches    ${switch1}${switch2}${switch3}   4
    ${4_count}=   Get Length            ${matches}
    ${os_conf}=    Get From Dictionary    ${${CONFIGURATION_NAME}}    OS
    ${x}   run keyword and ignore error   Should Match Regexp   ${os_conf}    .*3-.*
    Run keyword if   '${x[0]}'!='PASS'   Set Test Variable    ${4_count}   2
    ${OUT_EXPECTED_CABLINK_COUNT}=  Run Keyword If
    ...     '${RF_CABLINKS_NUMBER}'!='${EMPTY}'      Set Variable  ${RF_CABLINKS_NUMBER}
    ...   ELSE IF                      ${4_count}==2   Set Variable  1
    ...   ELSE IF                      ${4_count}==1   Set Variable  2
    ...   ELSE IF                      ${4_count}==0   Set Variable  3
    ...   ELSE IF                      ${4_count}==3   Set Variable  1
    Set test variable     ${OUT_EXPECTED_CABLINK_COUNT}


