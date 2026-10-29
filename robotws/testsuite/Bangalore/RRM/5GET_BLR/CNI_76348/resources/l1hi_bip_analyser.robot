***Settings***
Library           OperatingSystem
Library           Collections
Library           DateTime
Library           logging
Resource          ../../resources/NPS/SWENG/robot/PacketSearch.robot
Library           ../../resources/NPS/SWENG/python_libs/luashark_tools.py
Library           luashark_tools.analyzer      isLuaSharkRequired=False    WITH NAME       analyzer

*** Variables ***
${FIELDS_MCS}    mcsTable

*** Keywords *** 
Get filtered PDML file from pcap
    [Arguments]                     ${pcapFile}       ${filterExp}=None
    [Documentation]                 Takes a Pcap file as input, and returns it into a PDML file
    ${filterPcap}=                  analyzer.filter_pcap            ${pcapFile}
    ...                             filterName=${filterExp}         filterExp=${filterExp}
    ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}
    [Return]    ${pdmlFile}


get matched packet in a list
    [Arguments]                     ${message}          ${pdmlFile}     ${FIELDS_name}
    [Documentation]                 returns a list of packets for matched packet
    @{listpacketMatch}              analyzer.get_match_from_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             path=${FIELDS_name}
    ...                             startPacket=1
    ...                             endPacket=10
    [return]          @{listpacketMatch}

Verify MCS in uldata_puschreceivereq
    [Arguments]                     
    ...      ${pcapFile}   ${FIELDS_name}   ${mcs_value}
    [Documentation]                 
    ...     Verifies mcs value used in uldata_puschreceivereq in provided pcap traces
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}         uldata_puschreceivereq
    @{list_of_values}    get matched packet in a list     uldata_puschreceivereq    ${pdmlFile}   ${FIELDS_name}
    FOR      ${mcs_packet}     IN      @{list_of_values}
        ${packet_mcs}               Get Value In Packet Match
        ...                   packetMatch=${mcs_packet}
        ...                   field=${FIELDS_name}
        should be true      '${packet_mcs}' == '${mcs_value}'
    END

Verify MCS in dldata_pdschsendreq
    [Arguments]
    ...      ${pcapFile}   ${FIELDS_name}   ${mcs_value}
    [Documentation]
    ...     Verifies mcs value used in dldata_pdschsendreq in provided pcap traces
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}         dldata_pdschsendreq
    @{list_of_values}    get matched packet in a list     dldata_pdschsendreq    ${pdmlFile}   ${FIELDS_name}
    FOR      ${mcs_packet}     IN      @{list_of_values}
        ${packet_mcs}               Get Value In Packet Match
        ...                   packetMatch=${mcs_packet}
        ...                   field=${FIELDS_name}
        should be true      '${packet_mcs}' == '${mcs_value}'
    END
