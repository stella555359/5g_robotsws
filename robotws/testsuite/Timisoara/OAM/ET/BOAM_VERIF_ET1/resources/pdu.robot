*** Settings ***
Documentation
...         Author: krzysztof.gryga@nokia.com, rafal.janik@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com
...         Maintainer: rafal.janik@nokia.com, krzysztof.gryga@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com

Library     taf.pdu.interface.pdu
Library     Collections

*** Variables ***
${PDU_ALIAS_GNB}=    		        alias_pdu_gnb
${PDU_ALIAS_RMOD_1}=    	        alias_pdu_rmod1
${PDU_ALIAS_RMOD_2}=    	        alias_pdu_rmod2
${PDU_ALIAS_FAN_BREAKER}=           alias_pdu_fanbreaker
${PDU_ALIAS_GPS_BREAKER}=	        alias_pdu_gpsbreaker
${PDU_CONFIG_HOST_GNB}=      	    ${tl.pdus[0].addr}
${PDU_CONFIG_HOST_RMOD_1}=    	    ${tl.pdus[1].addr}
${PDU_CONFIG_HOST_RMOD_2}=    	    ${tl.pdus[2].addr}
${PDU_CONFIG_HOST_FAN_BREAKER}=     ${tl.pdus[3].addr}
${PDU_CONFIG_HOST_GPS_BREAKER}=     ${tl.pdus[4].addr}
${PDU_CONFIG_MODEL_GNB}=     	    ${tl.pdus[0]}
${PDU_CONFIG_MODEL_RMOD_1}=    		${tl.pdus[1]}
${PDU_CONFIG_MODEL_RMOD_2}=    		${tl.pdus[2]}
${PDU_CONFIG_MODEL_FAN_BREAKER}=    ${tl.pdus[3]}
${PDU_CONFIG_MODEL_GPS_BREAKER}=    ${tl.pdus[4]}
${PDU_DEVICE_GNB}=        	        gnb
${PDU_DEVICE_RMOD_1}=               rmod1
${PDU_DEVICE_RMOD_2}=               rmod2
${PDU_DEVICE_FAN_BREAKER}=          fanbreaker
${PDU_DEVICE_GPS_BREAKER}=          gpsbreaker
${PDU_PORT_GNB}=        	        ${tl.pdus[0].pdu_ports}
${PDU_PORT_RMOD_1}=        	        ${tl.pdus[1].pdu_ports}
${PDU_PORT_RMOD_2}=        	        ${tl.pdus[2].pdu_ports}
${PDU_PORT_FAN_BREAKER}=        	${tl.pdus[3].pdu_ports}
${PDU_PORT_GPS_BREAKER}=        	${tl.pdus[4].pdu_ports}

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
    Run Keyword If    '${device}' == '${PDU_DEVICE_GNB}'
    ...    Run Keywords    Set Test Variable    ${path}    ${PDU_PORT_GNB}    AND
    ...    Set Test Variable    ${alias}    ${PDU_ALIAS_GNB}
    ...    ELSE IF     '${device}' == '${PDU_DEVICE_RMOD_1}'
    ...    Run Keywords    Set Test Variable    ${path}    ${PDU_PORT_RMOD_1}    AND
    ...    Set Test Variable    ${alias}    ${PDU_ALIAS_RMOD_1}
    ...    ELSE IF     '${device}' == '${PDU_DEVICE_RMOD_2}'
    ...    Run Keywords    Set Test Variable    ${path}    ${PDU_PORT_RMOD_2}    AND
    ...    Set Test Variable    ${alias}    ${PDU_ALIAS_RMOD_2}
    ...    ELSE IF    '${device}' == '${PDU_DEVICE_FAN_BREAKER}'
    ...    Run Keywords    Set Test Variable  ${path}    ${PDU_PORT_FAN_BREAKER}    AND
    ...    Set Test Variable    ${alias}    ${PDU_ALIAS_FAN_BREAKER}
    ...    ELSE IF    '${device}' == '${PDU_DEVICE_GPS_BREAKER}'
    ...    Run Keywords    Set Test Variable  ${path}    ${PDU_PORT_GPS_BREAKER}    AND
    ...    Set Test Variable    ${alias}    ${PDU_ALIAS_GPS_BREAKER}
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
