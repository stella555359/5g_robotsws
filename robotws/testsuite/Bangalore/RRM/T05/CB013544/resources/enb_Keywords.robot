*** Settings ***
Documentation   This library shall contain the keywords that are needed specifically for gnb related operation

Library      Collections
Library      DateTime
Library      OperatingSystem
Library      String
Library      Telnet
Library      taf.sbts.oam.coam.admin    WITH NAME    admin
Library      taf.collectors.tcpdump    WITH NAME    tcpdump
Library      taf.collectors.core    WITH NAME    core
Library      taf.collectors.tshark        WITH NAME    tshark
Variables       ta5g_global_var

*** Variables ***
${GNB_IP}              192.168.255.129
${GNB_USERNAME}        toor4nsn
${GNB_PASSWORD}        oZPS0POrRieRtu

*** Keywords ***
Add RD Parameters Directly On GNB
    [Documentation]    This keyword directly appends RD parameters to swconfig.txt on gNB without backup.
    ...                Each parameter is sent separately to avoid "Argument list too long" error.
    ...                Author: bhakti.patel@nokia.com
    ...                Last Modified: 16-July-2025
    ...    | Input Parameters | Man. | Description |
    ...    | rd_parametrs | Yes | str joined by ; like: 0x580019=1;0x580011=0 |
    [Arguments]    ${rd_parametrs}
    ${rd_items}    String.Split String    ${rd_parametrs}    ;
    FOR    ${item}    IN    @{rd_items}
        Continue For Loop If    '${item}'=='${EMPTY}'
        ${cmd}    Set Variable    echo "${item}" >> /ffs/run/swconfig.txt
        Run    sshpass -p ${GNB_PASSWORD} ssh ${GNB_USERNAME}@${GNB_IP} '${cmd}'
    END
    Run    sshpass -p ${GNB_PASSWORD} ssh ${GNB_USERNAME}@${GNB_IP} 'crasign /ffs/run/swconfig.txt'

GNB Delta Commission
    [Documentation]    GNB Delta Commission where delta file is in .json format.
    [Arguments]    ${delta_file}    ${skip_parameter_relation_errors}=${True}    ${should_activate}=${True}   ${timeout}=300
    admin.Setup Admin
    Log To Console   ${EXEC_DIR}
    admin.Perform Delta Recommissioning        delta_file=${delta_file}
    ...     skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...     should_activate=${should_activate}   timeout=${timeout}
    [Teardown]    admin.Teardown Admin
