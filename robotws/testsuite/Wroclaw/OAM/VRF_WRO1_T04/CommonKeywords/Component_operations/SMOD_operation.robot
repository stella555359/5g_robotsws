*** Settings ***
Documentation
...    Author:          Bartlomiej Lebda
...    Maintainer:      Bartlomiej Lebda
...    Contact:         bartlomiej.lebda@nokia.com
...    Team in charge:  I_EXT_PZ_1_WRO_6_GMS
...    Description:     The following keywords are responsible for perform basic SMOD operations

Library     taf.transport.ssh          WITH NAME    ssh
Resource    ../Component_states/BasicKeywords.robot
Resource    ../Connections/Connectivity_keywords.robot

*** Variables ***
*** Keywords ***
Get RU IP from ASIx
    [Documentation]
    ...     -----------------------------------------------------------------------------------------
    ...     Getting RMOD IP address from the FRIps.txt file located on SMOD.
    ...     In case of more radio modules, it is recommended to use KW Get RU IP from Info Model.
    ...     As arguments it takes:
    ...                            - connection - by default alias is 'asik'
    ...     This KW returns:
    ...                            - RU IP Address. In case of more radio modules, it returns the
    ...                              last address listed in the FRIps.txtfile
    ...     -----------------------------------------------------------------------------------------
    [Arguments]    ${connection}=asik
    Connect Ssh To Asix    ${connection}
    ${FRIps}    ssh.execute            cat /rom/config/FRIps.txt    connection=${connection}
    ${RU_IP}    Get Regexp Matches     ${FRIps}    ;[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+;
    ${RU_IP}    get from list          ${RU_IP}    -1
    ${RU_IP}    Remove String          ${RU_IP}    ;
    should not be empty                ${RU_IP}
    [Return]    ${RU_IP}
