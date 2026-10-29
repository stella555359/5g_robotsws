*** Settings ***
Documentation    Resource file for PDU operation.
Library        taf.hw.pdu    WITH NAME    taf_pdu

*** Variables ***
${pdu}                        gude

*** Keywords ***
Turn Off SMOD on PDU
    [Documentation]         The KW to power off and power on system module.
    ...                     All variables are taken from init.
    ...                     Author = jagoda.kubacka@nokia.com
    taf_pdu.setup_pdu       model=${pdu_model}    host=${pdu_ip}    alias=${pdu}    version=${pdu_version}
    taf_pdu.power_off       ${pdu_port}    pdu_device=${pdu}
    Sleep                   10s    reason=Wait until SMOD is power off completely
    taf_pdu.power_on        ${pdu_port}    pdu_device=${pdu}
    [Teardown]              taf_pdu.teardown_pdu    pdu_device=${pdu}
