*** Settings ***
Documentation
...         Author: krzysztof.gryga@nokia.com, rafal.janik@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com
...         Maintainer: rafal.janik@nokia.com, krzysztof.gryga@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com

Library     taf.pdu.interface.pdu
Library     Collections
Library     ../CommonKeywords/utils.py

*** Variables ***
${PDU_ALIAS_GNB}=    		        alias_pdu_gnb
${PDU_ALIAS_RMOD_1}=    	        alias_pdu_rmod1
${PDU_ALIAS_RMOD_2}=    	        alias_pdu_rmod2
${PDU_ALIAS_FAN_BREAKER}=           alias_pdu_fanbreaker
${PDU_ALIAS_GPS_BREAKER}=	        alias_pdu_gpsbreaker
#${PDU_CONFIG_HOST_GNB}=      	    ${tl.pdus[0].addr}
#${PDU_CONFIG_HOST_RMOD_1}=    	    ${tl.pdus[1].addr}
#${PDU_CONFIG_HOST_RMOD_2}=    	    ${tl.pdus[2].addr}
#${PDU_CONFIG_HOST_FAN_BREAKER}=     ${tl.pdus[3].addr}
#${PDU_CONFIG_HOST_GPS_BREAKER}=     ${tl.pdus[4].addr}
#${PDU_CONFIG_MODEL_GNB}=     	    ${tl.pdus[0]}
#${PDU_CONFIG_MODEL_RMOD_1}=    		${tl.pdus[1]}
#${PDU_CONFIG_MODEL_RMOD_2}=    		${tl.pdus[2]}
#${PDU_CONFIG_MODEL_FAN_BREAKER}=    ${tl.pdus[3]}
#${PDU_CONFIG_MODEL_GPS_BREAKER}=    ${tl.pdus[4]}
${PDU_DEVICE_GNB}=        	        gnb
${PDU_DEVICE_RMOD_1}=               rmod1
${PDU_DEVICE_RMOD_2}=               rmod2
${PDU_DEVICE_FAN_BREAKER}=          fanbreaker
${PDU_DEVICE_GPS_BREAKER}=          gpsbreaker
#${PDU_PORT_GNB}=        	        ${tl.pdus[0].pdu_ports}
#${PDU_PORT_RMOD_1}=        	        ${tl.pdus[1].pdu_ports}
#${PDU_PORT_RMOD_2}=        	        ${tl.pdus[2].pdu_ports}
#${PDU_PORT_FAN_BREAKER}=        	${tl.pdus[3].pdu_ports}
#${PDU_PORT_GPS_BREAKER}=        	${tl.pdus[4].pdu_ports}
${PDU_UTE_DEVICE_GNB}               enb
${PDU_UTE_DEVICE_RMOD_1}            rf_1
${PDU_UTE_DEVICE_RMOD_2}            rf_2
${PDU_UTE_DEVICE_ALL_RMODS}         rf_all
${PDU_UTE_COMMAND_OFF}              ute_tl power_off
${PDU_UTE_COMMAND_ON}               ute_tl power_on
${PDU_UTE_COMMAND_REBOOT}           ute_tl reboot

*** Keywords ***
PDU Setup Gnb
    [Arguments]    ${model}=${PDU_CONFIG_MODEL_GNB}
    ...            ${host}=${PDU_CONFIG_HOST_GNB}
    ...            ${alias}=${PDU_ALIAS_GNB}
    taf.pdu.interface.pdu.setup_pdu
    ...    model=${model}
    ...    host=${host}
    ...    alias=${alias}

PDU Setup Rmod 1
    [Arguments]    ${model}=${PDU_CONFIG_MODEL_RMOD_1}
    ...            ${host}=${PDU_CONFIG_HOST_RMOD_1}
    ...            ${alias}=${PDU_ALIAS_RMOD_1}
    taf.pdu.interface.pdu.setup_pdu
    ...    model=${model}
    ...    host=${host}
    ...    alias=${alias}

PDU Setup Rmod 2
    [Arguments]    ${model}=${PDU_CONFIG_MODEL_RMOD_2}
    ...            ${host}=${PDU_CONFIG_HOST_RMOD_2}
    ...            ${alias}=${PDU_ALIAS_RMOD_2}
    taf.pdu.interface.pdu.setup_pdu
    ...    model=${model}
    ...    host=${host}
    ...    alias=${alias}

PDU Setup Fan Breaker
    [Arguments]    ${model}=${PDU_CONFIG_MODEL_FAN_BREAKER}
    ...            ${host}=${PDU_CONFIG_HOST_FAN_BREAKER}
    ...            ${alias}=${PDU_ALIAS_FAN_BREAKER}
    taf.pdu.interface.pdu.setup_pdu
    ...    model=${model}
    ...    host=${host}
    ...    alias=${alias}

PDU Setup GPS Breaker
    [Arguments]    ${model}=${PDU_CONFIG_MODEL_GPS_BREAKER}
    ...            ${host}=${PDU_CONFIG_HOST_GPS_BREAKER}
    ...            ${alias}=${PDU_ALIAS_GPS_BREAKER}
    taf.pdu.interface.pdu.setup_pdu
    ...    model=${model}
    ...    host=${host}
    ...    alias=${alias}

PDU Action
    [Arguments]    ${device}
    ...            ${action}


    ${parameters}    Get ports and aliases dict list
    ${device_params}    get dict that has value  ${parameters}  ${device}
    ${path}    get from dictionary  ${device_params}  port
    ${alias}    get from dictionary  ${device_params}  alias
    Run Keyword If    '${action}' == 'status'
    ...    PDU Status
    ...        port_no=${path}
    ...        alias=${alias}
    ...    ELSE IF  '${action}' == 'on'
    ...    PDU Turn On
    ...        port_no=${path}
    ...        alias=${alias}
    ...    ELSE IF   '${action}' == 'off'
    ...    PDU Turn Off
    ...        port_no=${path}
    ...        alias=${alias}

PDU Status
    [Arguments]    ${port_no}
    ...            ${alias}
    ${port_no}    PDU Get Port No
    ...    port_no=${port_no}
    Log    ${port_no}
    run keyword and return  taf.pdu.interface.pdu.get_port_status
    ...    port=${port_no}
    ...    pdu_device=${alias}

PDU Turn On
    [Arguments]    ${port_no}
    ...            ${alias}
    ${port_no}    PDU Get Port No
    ...    port_no=${port_no}
    taf.pdu.interface.pdu.power_on
    ...    port=${port_no}
    ...    pdu_device=${alias}

PDU Turn Off
    [Arguments]    ${port_no}
    ...            ${alias}
    ${port_no}    PDU Get Port No
    ...    port_no=${port_no}
    taf.pdu.interface.pdu.power_off
    ...    port=${port_no}
    ...    pdu_device=${alias}

PDU Get Port No
    [Arguments]    ${port_no}
    ${port_no}    Get Dictionary Keys    ${port_no}
    [Return]    ${port_no[0]}

Get ports and aliases dict list
    ${dev1}=    create dictionary    device=${PDU_DEVICE_GNB}
    ...                               port=${PDU_PORT_GNB}
    ...                               alias=${PDU_ALIAS_GNB}

    ${dev2}=    create dictionary    device=${PDU_DEVICE_RMOD_1}
    ...                               port=${PDU_PORT_RMOD_1}
    ...                               alias=${PDU_ALIAS_RMOD_1}

    ${dev3}=    create dictionary    device=${PDU_DEVICE_RMOD_2}
    ...                               port=${PDU_PORT_RMOD_2}
    ...                               alias=${PDU_ALIAS_RMOD_2}

    ${dev4}=    create dictionary    device=${PDU_DEVICE_FAN_BREAKER}
    ...                               port=${PDU_PORT_FAN_BREAKER}
    ...                               alias=${PDU_ALIAS_FAN_BREAKER}

    ${dev5}=    create dictionary    device=${PDU_DEVICE_GPS_BREAKER}
    ...                               port=${PDU_PORT_GPS_BREAKER}
    ...                               alias=${PDU_ALIAS_GPS_BREAKER}

    @{parameter_list}=    create list    ${dev1}    ${dev2}    ${dev3}    ${dev4}    ${dev5}

    [Return]  @{parameter_list}

Get pdu port
    [Arguments]  ${device}
    log to console  ${device}
    ${path}    Set Variable If    '${device}' == '${PDU_DEVICE_GNB}'           ${PDU_PORT_GNB}
    return from keyword if    is not none  ${path}    ${path}
    ${path}    Set Variable If    '${device}' == '${PDU_DEVICE_RMOD_1}'        ${PDU_PORT_RMOD_1}
    return from keyword if    is not none  ${path}    ${path}
    ${path}    Set Variable If    '${device}' == '${PDU_DEVICE_RMOD_2}'        ${PDU_PORT_RMOD_2}
    return from keyword if    is not none  ${path}    ${path}
    ${path}    Set Variable If    '${device}' == '${PDU_DEVICE_FAN_BREAKER}'   ${PDU_PORT_FAN_BREAKER}
    return from keyword if    is not none  ${path}    ${path}
    ${path}    Set Variable If    '${device}' == '${PDU_DEVICE_GPS_BREAKER}'   ${PDU_PORT_GPS_BREAKER}

    [Return]  ${path}

Get pdu alias
    [Arguments]  ${device}
    ${alias}    Set Variable If    '${device}' == '${PDU_DEVICE_GNB}'           ${PDU_ALIAS_GNB}
    return from keyword if   is not none  ${alias}    ${alias}
    ${alias}    Set Variable If    '${device}' == '${PDU_DEVICE_RMOD_1}'        ${PDU_ALIAS_RMOD_1}
    return from keyword if   is not none  ${alias}    ${alias}
    ${alias}    Set Variable If    '${device}' == '${PDU_DEVICE_RMOD_2}'        ${PDU_ALIAS_RMOD_2}
    return from keyword if   is not none  ${alias}    ${alias}
    ${alias}    Set Variable If    '${device}' == '${PDU_DEVICE_FAN_BREAKER}'   ${PDU_ALIAS_FAN_BREAKER}
    return from keyword if   is not none  ${alias}    ${alias}
    ${alias}    Set Variable If    '${device}' == '${PDU_DEVICE_GPS_BREAKER}'   ${PDU_ALIAS_GPS_BREAKER}

    [Return]  ${alias}

PDU Action With UTE Command
    [Arguments]    ${ute_device}
    ...            ${ute_command}
    Run    ${ute_command} ${ute_device}

PDU Turn Off Gnb With UTE Command
    PDU Action With UTE Command
    ...    ute_device=${PDU_UTE_DEVICE_GNB}
    ...    ute_command=${PDU_UTE_COMMAND_OFF}

PDU Turn Off Rmod 1 With UTE Command
    PDU Action With UTE Command
    ...    ute_device=${PDU_UTE_DEVICE_RMOD_1}
    ...    ute_command=${PDU_UTE_COMMAND_OFF}

PDU Turn Off Rmod 2 With UTE Command
    PDU Action With UTE Command
    ...    ute_device=${PDU_UTE_DEVICE_RMOD_2}
    ...    ute_command=${PDU_UTE_COMMAND_OFF}

PDU Turn Off All Rmods With UTE Command
    PDU Action With UTE Command
    ...    ute_device=${PDU_UTE_DEVICE_ALL_RMODS}
    ...    ute_command=${PDU_UTE_COMMAND_OFF}

PDU Turn On Gnb With UTE Command
    PDU Action With UTE Command
    ...    ute_device=${PDU_UTE_DEVICE_GNB}
    ...    ute_command=${PDU_UTE_COMMAND_ON}

PDU Turn On Rmod 1 With UTE Command
    PDU Action With UTE Command
    ...    ute_device=${PDU_UTE_DEVICE_RMOD_1}
    ...    ute_command=${PDU_UTE_COMMAND_ON}

PDU Turn On Rmod 2 With UTE Command
    PDU Action With UTE Command
    ...    ute_device=${PDU_UTE_DEVICE_RMOD_2}
    ...    ute_command=${PDU_UTE_COMMAND_ON}

PDU Turn On All Rmods With UTE Command
    PDU Action With UTE Command
    ...    ute_device=${PDU_UTE_DEVICE_ALL_RMODS}
    ...    ute_command=${PDU_UTE_COMMAND_ON}

PDU Reset Gnb With UTE Command
    PDU Action With UTE Command
    ...    ute_device=${PDU_UTE_DEVICE_GNB}
    ...    ute_command=${PDU_UTE_COMMAND_REBOOT}

PDU Reset Rmod With UTE Command
    PDU Action With UTE Command
    ...    ute_device=${PDU_UTE_DEVICE_RMOD_1}
    ...    ute_command=${PDU_UTE_COMMAND_REBOOT}

PDU Reset Rmod 2 With UTE Command
    PDU Action With UTE Command
    ...    ute_device=${PDU_UTE_DEVICE_RMOD_2}
    ...    ute_command=${PDU_UTE_COMMAND_REBOOT}

PDU Reset All Rmods With UTE Command
    PDU Action With UTE Command
    ...    ute_device=${PDU_UTE_DEVICE_ALL_RMODS}
    ...    ute_command=${PDU_UTE_COMMAND_REBOOT}
