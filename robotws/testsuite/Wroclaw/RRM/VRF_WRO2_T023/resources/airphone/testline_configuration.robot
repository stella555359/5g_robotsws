*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Palina Krasnova
...              :contact: palina.krasnova@nokia.com
...              This resources contains keywords related to testline configuration

Library    Process


*** Keywords ***
Configure Interfaces
    [Documentation]
    ...    Configures specified interfaces on virtual machine
    ...
    ...    | **Author:** palina.krasnova@nokia.com
    ...
    ...    **Input Parameters:**
    ...
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | Parameter              | Man.  | Description                                                          |
    ...    +========================+======+=======================================================================+
    ...    | eth                    | Yes   | Interface name.                                                      |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | ips_range              | Yes   | List of ips to be configured for the specified interface.            |
    ...    +------------------------+------+-----------------------------------------------------------------------+

    [Arguments]    ${eth}    ${ips_range}
    FOR    ${ip}    IN    @{ips_range}
        Run    sudo ip addr add 10.0.1.${ip}/24 dev ${eth}
    END

Stop Interfaces
    [Documentation]
    ...    Stops specified interfaces on virtual machine
    ...
    ...    | **Author:** wojciech.peciak@nokia.com
    ...
    ...    **Input Parameters:**
    ...
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | Parameter              | Man.  | Description                                                          |
    ...    +========================+======+=======================================================================+
    ...    | eth                    | Yes   | Interface name.                                                      |
    ...    +------------------------+------+-----------------------------------------------------------------------+
    ...    | ips_range              | Yes   | List of ips to be stopped for the specified interface.               |
    ...    +------------------------+------+-----------------------------------------------------------------------+

    [Arguments]    ${eth}    ${ips_range}
    FOR    ${ip}    IN    @{ips_range}
        Run    sudo ip addr del 10.0.1.${ip}/24 dev ${eth}
    END
