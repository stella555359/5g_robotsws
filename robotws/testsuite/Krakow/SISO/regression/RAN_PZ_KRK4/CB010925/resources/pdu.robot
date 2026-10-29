*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: PDU keywords

Library     taf.hw.pdu    WITH NAME    pdu

*** Variables ***
${hpe_host}     ${tl.pdus[0].addr}
${hpe_port}     2
${hpe_alias}    UE_HPE
${hpe_model}    HPE
${snmp_user}    ${tl.pdus[0].snmp_user}

*** Keywords ***
Power Reset UE
    pdu.setup_pdu    host=${hpe_host}    alias=${hpe_alias}    model=${hpe_model}    snmp_user=${snmp_user}
    pdu.power_off    port=${hpe_port}    pdu_device=${hpe_alias}
    sleep    5
    pdu.power_on    port=${hpe_port}    pdu_device=${hpe_alias}
    pdu.teardown_pdu    pdu_device=${hpe_alias}
