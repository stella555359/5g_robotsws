*** Settings ***
Documentation    Cloud pods keywords.
...              Authors:    Patryk Tatarek, Jagoda Kubacka
...              Contact:    patryk.tatarek@nokia.com, jagoda.kubacka@nokia.com

Resource    ../connections/connections.robot
Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    taf/rfrl/cbts/robot/ssh_operations.robot

Library     taf.transport.ssh    WITH NAME    ssh
Library     String

*** Keywords ***

#################################################### Main  Keywords ####################################################

Get Packets From Firewall
    [Documentation]    Description:    Keyword to get the number of packets from nftmgmt containter
    ...                Input:          nft_tables = all elements from nftmgmt contaiers. Get from "Get Nft Tables"
    ...                Output:         Output from the command
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${nft_tables}
    ${packets}         Get Regexp Matches    ${nft_tables}    (?<=packets )\\d+
    [Return]           ${packets}
