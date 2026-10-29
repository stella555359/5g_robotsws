*** Settings ***
Documentation
...    Author: Du Ning
...    Contact: ning.du@nokia-sbell.com
...    Common KWs for PDU use.
...    Please make sure you defined the following values in your TL __init__.py before you use these keywords:
...    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
...    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
...    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}



*** Keywords ***
Hard Reboot GNB
    [Documentation]    Author: Du Ning
    ...                Contact: ning.du@nokia-sbell.com
    ...                This keyword is used to hard reboot the gNB
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | NA | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Hard Reboot GNB |
    ...
    Log To Console    \nGNB is going to be hard rebooted!
    Perform Site Power Off
    Sleep    5s    reason=Wait the HW be stable
    Perform Site Power On
    Log To Console    \nGNB hard reboot done!

Perform Site Power On
    [Documentation]    Author: Du Ning
    ...                Contact: ning.du@nokia-sbell.com
    ...                This keyword is used to power on the gNB
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | NA | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Perform Site Power On |
    ...
    Log To Console    \nPower on the GNB!
    ${gnb_pdu_ip}=    Set Variable    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    ${gnb_pdu_port}=    Set Variable    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    ${gnb_pdu_vendor}=    Set Variable    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    PDU.Setup Pdu    model=${gnb_pdu_vendor}    host=${gnb_pdu_ip}    alias=gnb_pdu_on
    PDU.Power On    port=${gnb_pdu_port}    pdu_device=gnb_pdu_on
    PDU.Get Port Status    port=${gnb_pdu_port}    pdu_device=gnb_pdu_on

Perform Site Power Off
    [Documentation]    Author: Du Ning
    ...                Contact: ning.du@nokia-sbell.com
    ...                This keyword is used to power off the gNB
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | NA | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Perform Site Power Off |
    ...
    Log To Console    \nPower off the GNB!
    ${gnb_pdu_ip}=    Set Variable    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    ${gnb_pdu_port}=    Set Variable    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    ${gnb_pdu_vendor}=    Set Variable    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
    PDU.Setup Pdu    model=${gnb_pdu_vendor}    host=${gnb_pdu_ip}    alias=gnb_pdu_off
    PDU.Power Off    port=${gnb_pdu_port}    pdu_device=gnb_pdu_off
    PDU.Get Port Status    port=${gnb_pdu_port}    pdu_device=gnb_pdu_off
