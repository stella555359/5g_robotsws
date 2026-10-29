*** Settings ***
Documentation

...    Creating connections between ports in Optical Switch
...    Author: Zygmunt Rugowski
...    Contact: zygmunt.rugowski@nokia.com
...    Optical Switch is used to changing connections between input (2 ports) and output (12 ports)


Library    Telnet


*** Variables ***

${Optical_Switch_IP}=        10.42.54.234
${Optical_Switch_IP_Port}=        23
${verification_connections}=       set?    #Command for Optical Switch which verifies connections between ports
${set_remove}=       set00   #Command for Optical Switch which removes all connections between ports
${verification_no_connections}=    blind       #Message which confirms, that there is no connection in Optical Switch


*** Keywords ***
Logon to the Optical Switch
    [Documentation]  This keyword logons to Optical Switch
    Telnet.Open Connection      ${Optical_Switch_IP}      ${Optical_Switch_IP_Port}
    log to console      Connection to Optical Switch is ready

Set the connections in Optical Switch
    [Documentation]  This keyword sends commands which set up connection between input and output ports in Optical Switch
    [Arguments]   ${port_input}    ${port_output}
    run keyword and ignore error    Telnet.Write    set${port_input}${port_output}
    sleep   7s
    Set prompt    ${EMPTY}
    ${First_connection}    Write	    ${verification_connections}
    ${Second_connection}    Read
    log to console    Existed connection(s) in the Optical Switch:
    log to console  ${First_connection}${Second_connection}

Remove all connections in Optical Switch
    [Documentation]  This keyword sends commands which cancel all connections between input and outputs ports in Optical Switch
    run keyword and ignore error  Telnet.Write      ${set_remove}
    sleep   7s


Logout from Optical Switch
    [Documentation]  This keyword logouts from Optical Switch
    Telnet.Close Connection
    log to console      Connection to Optical Switch is closed

Creating connections in Optical Switch
    [Arguments]   ${port_input}    ${port_output}
    [Documentation]  This keyword creates connection between ports in optical switch.
    ...      It's possible to choice 2 input ports (1 or 2) and 12 output  ports (1-12).
    Logon to the Optical Switch
    Set the connections in Optical Switch    ${port_input}   ${port_output}
    [Teardown]  Logout from Optical Switch

Close all connections in Optical Switch
    [Documentation]  This keyword cancels all connections in Optical Switch
    Logon to the Optical Switch
    Remove all connections in Optical Switch
    [Teardown]  Logout from Optical Switch

