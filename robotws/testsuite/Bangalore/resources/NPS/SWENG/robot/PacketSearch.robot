*** Settings ***
Documentation                       This module aims at providing some tools to search some packets in a capture
...                                 and filter them upon some fields
...
...                                 Main concepts/structured data are :
...                                 - pcapFile        : binary file containing a life capture on an interface
...                                 - pdmlFile        : translation into xml readable format of a pcap file
...                                 - path            : full path description string to reach a particular field in
...                                                     a pdml file
...                                                     example : icom_5g/uldata_prachreceivereq/UlData_PrachReceiveReq.PrachReceiveReq.sfn
...                                                     to reach sfn field in a uldata_prachreceivereq packet
...
...                                 - listPacketMatch : this is a list of packetMatch
...                                 - packetMatch     : When searching for a packetSearch, we collect a list of
...                                                     packetMatch. It is described by a NamedPacket and a dictionary
...                                                     of values. Keys are path, values are value of final field
...                                                     For a search on sfn and slot for uldata_prachreceivereq packet,
...                                                     we will have a packetMatch with :
...                                                     ${packetMatch.namedPacket.name} =  uldata_prachreceivereq
...                                                     ${packetMatch.namedPacket.index} = 12   # index of packet in pcap
...                                                     ${packetMatch.namedPacket} = uldata_prachreceivereq(12)
...                                                     ${packetMatch.packet} = <Packet Found (python struct)>
...                                                     ${packetMatch.fields['<pathForSlot>'].show} = 0x0000013 # value for slot
...                                                     ${packetMatch.fields['<pathForSfn>'].show} = 0x000002fd # value for sfn
...

Library                             Collections
Library                             String
Resource                            Tools.robot
Library                             ../python_libs/luashark_tools.py
Library                             luashark_tools.analyzer       WITH NAME       analyzer


*** Keywords ***
#===================================
# PACKET Search upon list of field
#===================================
Get Packet Match List
    [Documentation]                 Parse a pdml file and collect all packets matching a packet name
    ...                             and optionnaly a filter, then will collect for each packet
    ...                             a list of fields
    ...                             It will return a list of packetMatch (with required fields)
    [Arguments]                     ${pdmlFile}             # Pdml file to parse
    ...                             ${packetName}           # Name of packet to search
    ...                             ${pathList}             # List of fields to collect
    ...                             ${filter}=${EMPTY}      # Optional filter on packets
    ...                             ${startPacket}=${1}
    ...                             ${endPacket}=${-1}
    # Add a '$' to each field to collect to ensure they will be unique and terminate ones
    @{listField}                    Create List
    FOR    ${field}   IN           @{pathList}
        append to list              ${listField}                        ${field}$
    # Collect packets matching packetName
    END
    @{listPacketMatch}              get_match_from_paths                pdmlFile=${pdmlFile}
    ...                             packetName=${packetName}
    ...                             filter=${filter}
    ...                             pathList=${listField}
    ...                             startPacket=${startPacket}
    ...                             endPacket=${endPacket}
    [Return]                        ${listPacketMatch}

Show Packet Match List
    [Documentation]                 Display list of packet matching a search
    ...                             It will display the name of packet (with its range in capture)
    ...                             then, for each field, retrieve if exists the value of it
    ...                             By default, a short format is shown (one line)
    ...                             With ${isDisplayShort} set to false, it will take 1 line for packet naming,
    ...                             Then one line per field
    [Arguments]                     ${listPacketMatch}                  ${fields}
    ...                             ${isDisplayShort}=${True}
    run keyword if                  ${isDisplayShort}
    ...                             Show Packet Match List Short        ${listPacketMatch}                  ${fields}
    ...     ELSE                    Show Packet Match List Long         ${listPacketMatch}                  ${fields}

Show Packet Match List Short
    [Documentation]                 Display list of packet matching a search, short (one line) format
    [Arguments]                     ${listPacketMatch}                  ${fields}
    FOR    ${packet}       IN      @{listPacketMatch}
            ${str}                  Packet Match to Str
            ...                         packetMatch=${packet}
            ...                         fields=${fields}
            Dated log               ${str}

    END
Packet Match to Str
    [Documentation]                 Return a line with synthesis of a packet match
    [Arguments]                     ${packetMatch}                      ${fields}
    ${str}                          set variable                        Packet=${packetMatch.namedPacket}
    FOR    ${field}    IN          @{fields}
            ${value}                Get Value In Packet Match
            ...                         packetMatch=${packetMatch}
            ...                         field=${field}
            ${str}                  set variable                        ${str} ${field}=${value}
    END
    [Return]                        ${str}

Show Packet Match List Long
    [Documentation]                 Display list of packet matching a search, long format
    [Arguments]                     ${listPacketMatch}                  ${fields}
    FOR    ${packet}       IN      @{listPacketMatch}
            Show Packet Match       packetMatch=${packet}               fields=${fields}

    END
Show Packet Match
    [Documentation]                 Display one packet matching a search, long format
    [Arguments]                     ${packetMatch}                      ${fields}
    Dated log                       Packet=${packetMatch.namedPacket}
    ${len}                          get length                          ${fields}
    FOR    ${i}    IN RANGE        0   ${len}
            ${value}                Get Value In Packet Match
            ...                     packetMatch=${packetMatch}          field=${fields[${i}]}
            Dated Log               \t${fields[${i}]}=${value}

    END
Get Packet Match Dict List
    [Documentation]                 Get list of packet matching a search
    [Arguments]                     ${listPacketMatch}                  ${fields}
    @{valuelist_for_field}          Create List
    FOR    ${packet}       IN      @{listPacketMatch}
            ${list_element}             Get Packet Match Dict
            ...                         packetMatch=${packet}               fields=${fields}
            Append To List              ${valuelist_for_field}              ${list_element}
    END
    [Return]    ${valuelist_for_field}

Get Packet Match Dict
    [Documentation]                 Get dict element of packet matching a search
    [Arguments]                     ${packetMatch}                  ${fields}
    &{result_dict}                  Create Dictionary
    Dated log                       Packet=${packetMatch.namedPacket}
    ${len}                          get length                          ${fields}
    FOR    ${i}    IN RANGE        0   ${len}
            ${value}                Get Value In Packet Match
            ...                     packetMatch=${packetMatch}          field=${fields[${i}]}
            Dated Log               \t${fields[${i}]}=${value}
            Set To Dictionary       ${result_dict}                      ${fields[${i}]}                     ${value}
    END
    [Return]                        ${result_dict}

Get Value In Packet Match
    [Documentation]                 Return value of a field retrieved in a packetMatch
    ...                             if not found, it return an empty string
    [Arguments]                     ${packetMatch}                      ${field}
    ...                             ${kind}=show
    @{listPath}                     Get Dictionary Keys                 ${packetMatch.fields}
    ${field}                        Fetch From Left                     ${field}     $
    FOR    ${path}         IN      @{listPath}
            ${fieldName}            Get Field Name From Path            ${path}
            return from keyword if  '${fieldName}' in '${field}'          ${packetMatch.fields['${path}'].${kind}}
    END
    [Return]                        ${EMPTY}

List Packet Match Index
    [Documentation]                 Return a string representing the list of index of packets in
    ...                             a list of packetMatch
    [Arguments]                     ${listPacketMatch}
    ${str}                          Set Variable                        ${EMPTY}
    FOR    ${packet}      IN       @{listPacketMatch}
            ${num}                  Set variable                        ${packet.namedPacket.index}
            ${str}                  set variable                        ${str}${num},
    END
    [Return]                        ${str}

#===================================
# Common tools
#===================================
Get Field Name From Path
    [Documentation]                 Retrieve from a full exhaustive path the the field name
    ...                             meaning the most pertinent string representaing the field
    ...                             Example :
    ...                             if path is icom_5g/uldata_pucchreceivereq/UlData_PucchReceiveReq.PucchReceiveReq.slot
    ...                             it will return : 'slot'
    [Arguments]                     ${path}
    # Pattern is : <any string[.*]> <a non word[\\W]> <any suite of word[\\w*]>  <end of string[$]>
    # From this, we catch the third one as name
    @{shortKey}                     Get Regexp Matches                  ${path}
    ...                             .*\\W(\\w*)$                        1
    [Return]                        ${shortKey[0]}
