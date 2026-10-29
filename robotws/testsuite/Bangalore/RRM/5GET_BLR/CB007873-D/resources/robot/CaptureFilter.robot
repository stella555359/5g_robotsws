*** Settings ***
Documentation
...            == Purpose ==
...            Library to manage all Capture Filters services
...
...            == Description ==
...            Proposed keywords will offer services to get/create filter:
...            - for a particular messages.
...            - for BIP messages.
...            - for specific protocol : SCTP, X2AP, F1AP, UDP, TCP, ARP, ICMP or ICOM.
...            - for overhead L1 or SCTP.
...            - to exclude protocols.
...
...            *Main keywords are:*
...            | =Keyword Name= | =Param1= | =Param2= |
...            | get filter for particular msgs  | <bipMsgList> |                |
...            | get filter for sctp             | <capture>    |                |
...            | get filter for x2ap             | <capture>    |                |
...            | get filter for f1ap             | <capture>    |                |
...            | get filter all bip msgs         |              |                |
...            | get filter to exclude protocols | <capture>    | <protocolList> |
...
...            *Example:*
...            You may use them like this in your test:
...            - Get filter for all BIP messages:
...            | ${capture.filter} \ \ \ \ \ \ \ Get Filter all BIP msgs
...            | set suite variable \ \ \ \ \ \ ${capture.filter}
...            | Capture Start \ \ \ \ \ \ \ \ \ \ \ ${capture}
...
...            - Get filter for all TCP messages:
...            | ${capture.filter} \ \ \ \ \ \ \ Get Filter For TCP \ \ \ \ \ ${capture}
...            | set suite variable \ \ \ \ \ \ ${capture.filter}
...            | Capture Start \ \ \ \ \ \ \ \ \ \ \ ${capture}

...            - Get filter for no ARP messages:
...            | ${filter1} \ \ \ \ \ \ \ \ \ \ \ \ \ \ Get Filter For ARP \ \ \ ${capture}
...            | ${capture.filter} \ \ \ \ \ \ \ set variable \ \ \ \ \ \ \ \ \ 'not ${filter1}'
...            | set suite variable \ \ \ \ \ \ ${capture.filter}
...            | Capture Start \ \ \ \ \ \ \ \ \ \ \ ${capture}
...
...            - Get filter to exclude CPRT protocols
...            | ${CaptureCPRT} \ \ \ \ \ \ \ \ \ \ Capture CPRT Set Upon Config \ \ \ \ \ airscale=${GNB_DU}
...            | Set Suite Variable \ \ \ \ \ \ ${CaptureCPRT}
...            | ${CaptureCPRT.filter} \ \ \ Get Filter To Exclude protocols
...            | ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ capture=${CaptureCPRT}
...            | ... \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ protocolList=${filter_protocol}
...            | Capture Init \ \ \ \ \ \ \ \ \ \ \ \ capture=${CaptureCPRT} \ \ \ \ \ \ \ \ \ \ \ suffix=${suffix}
...            | Capture Start \ \ \ \ \ \ \ \ \ \ \ ${CaptureCPRT}


Library                             ../../../RRM/ET/resources/python/luashark_tools.py
Library                             luashark_tools.analyzer       WITH NAME       analyzer

*** Variables ***
# Ethernet layer
${OH_ETH}                           ${14}
${OH_LINUX}                         ${16}

# VLAN layer
${OH_VLAN}                          ${4}

# IP layer
${OH_IPV4}                          ${20}
${OH_IPV6}                          ${40}

# SCTP Layer
${OH_SCTP_COMMON}                   ${12}
${OH_SCTP_DATA_CHUNK}               ${16}
${OH_SCTP_SACK_CHUNK}               ${16}
${OH_SCTP_WO_SACK}                  ${${OH_SCTP_COMMON}+${OH_SCTP_DATA_CHUNK}}                            # 28
${OH_SCTP_W_SACK}                   ${${OH_SCTP_COMMON}+${OH_SCTP_DATA_CHUNK}+${${OH_SCTP_SACK_CHUNK}}}   # 44
${LEN_PROTO_SCTP}                   ${4}

# F1AP MESSAGES
${F1AP_PROTO_ID}                    0x0000003e
${X2AP_PROTO_ID}                    0x0000001b                                                             #27

# BIP MESSAGES
${LEN_BIP_ID}                       ${2}
${OH_ETH_TO_PROTO}                  ${12}
${OH_ETH_TO_MSG_ASIK}               ${${OH_ETH}+${10}}
${OH_ETH_TO_MSG_ASIB}               ${${OH_ETH}+${10}}
${OH_ETH_TO_MSG_ASIL}               ${${OH_ETH}+${10}}
${OH_ETH_TO_MSG_BOO}                ${${OH_ETH}+${18}}
${OH_ETH_TO_MSG_BO_LO}              ${${OH_ETH}+${14}}

# SYSCOM Messages
${SHIFT_TO_MSG_ID}                  ${2}

${PREFIX_ETHER_BIP_MSG_HEAD}        ether[${OH_ETH_TO_PROTO}:${LEN_BIP_ID}]
${PREFIX_ETHER_BIP_MSG_TYPE_ASIK}   ether[${OH_ETH_TO_MSG_ASIK}:${LEN_BIP_ID}]
${PREFIX_ETHER_BIP_MSG_TYPE_ASIB}   ether[${OH_ETH_TO_MSG_ASIB}:${LEN_BIP_ID}]
${PREFIX_ETHER_BIP_MSG_TYPE_ASIL}   ether[${OH_ETH_TO_MSG_ASIL}:${LEN_BIP_ID}]
${PREFIX_ETHER_BIP_MSG_TYPE_BO_LO}  ether[${OH_ETH_TO_MSG_BO_LO}:${LEN_BIP_ID}]
${PREFIX_ETHER_BIP_MSG_TYPE_BOO}    ether[${OH_ETH_TO_MSG_BOO}:${LEN_BIP_ID}]
${BIP_PROTO_ID}                     0x8951                                                                # 35153
${ARP_PROTO_ID}                     0x0806
${UDP_PROTO_ID}                     0x11
${TCP_PROTO_ID}                     0x06
${ICMPv4_PROTO_ID}                  0x01
${ICMPv6_PROTO_ID}                  0x03a
${SCTP_PROTO_ID}                    0x084

*** Keywords ***
# ==================================
# EXTERNAL API
# ==================================
Get Filter For F1AP
    [Documentation]                 Build filter expression for tcpdump command in order to capture only F1AP msgs.
    ...
    ...                             The keyword returns the builded filter.
    ...
    ...                             *Argument details:*
    ...                              - capture : specifies the interface of the card on which we want to filter.
    [Arguments]                     ${capture}
    ${filter}                       Get Filter For SCTP Proto            capture=${capture}
    ...                             proto=${F1AP_PROTO_ID}               ipList=IPV6
    [Return]                        ${filter}

Get Filter For X2AP
    [Documentation]                 Build filter expression for tcpdump command in order to capture only X2AP msgs.
    ...
    ...                             The keyword returns the builded filter.
    ...
    ...                             *Argument details:*
    ...                              - capture : specifies the interface of the card on which we want to filter.
    [Arguments]                     ${capture}
    ${filter}                       Get Filter For SCTP Proto            capture=${capture}
    ...                             proto=${X2AP_PROTO_ID}               ipList=IPV4
    [Return]                        ${filter}

Get filter for msgs ICOM
    [Documentation]                 Build filter expression for tcpdump command in order to capture only ICOM msgs.
    ...
    ...                             The keyword returns the builded filter.
    ...
    ...                             *Argument details:*
    ...                              - MsgList : specifies the messages on which we want to filter.
    ...                              - capture : specifies the interface of the card on which we want to filter.
    [Arguments]                     ${MsgList}
    ...                             ${capture}
    ${prefixL1}                     Get Overhead L1                      ${capture}
    # ETH/Linux + VLAN + IPV4 + SCTP : 14/16 + 4 + 20 + 28 + 2 = 68/70
    ${shiftIPV4_SCTP_wo_SACK}       evaluate
    ...                             ${prefixL1}+${OH_VLAN}+${OH_IPV4}+${OH_SCTP_WO_SACK}+${SHIFT_TO_MSG_ID}
    # ETH/Linux + VLAN + IPV4 + SCTP : 14/16 + 4 + 20 + 28 + 16 + 2 = 84/86
    ${shiftIPV4_SCTP_w_SACK}        evaluate
    ...                             ${prefixL1}+${OH_VLAN}+${OH_IPV4}+${OH_SCTP_W_SACK}+${SHIFT_TO_MSG_ID}
    # ETH/Linux + VLAN + IPV6 + SCTP : 14/16 + 4 + 40 + 28 + 2 = 88/90
    ${shiftIPV6_SCTP_wo_SACK}       evaluate
    ...                             ${prefixL1}+${OH_VLAN}+${OH_IPV6}+${OH_SCTP_WO_SACK}+${SHIFT_TO_MSG_ID}
    # ETH/Linux + VLAN + IPV6 + SCTP : 14/16 + 4 + 40 + 24 + 16 + 2 = 104/106
    ${shiftIPV6_SCTP_w_SACK}        evaluate
    ...                             ${prefixL1}+${OH_VLAN}+${OH_IPV6}+${OH_SCTP_W_SACK}+${SHIFT_TO_MSG_ID}
    # Get messages ids from csv file
    ${MESSAGE_IDS}                  analyzer.get_id_by_messages          msg_names=${MsgList}
    Should not be empty             ${MESSAGE_IDS}
    ...                             msg= This message name does not exists.Check correct name in csv file
    # Build prefix list
    @{ICOMPrefixList}               create list
    ...                             ${shiftIPV4_SCTP_wo_SACK}
    ...                             ${shiftIPV6_SCTP_wo_SACK}
    ...                             ${shiftIPV6_SCTP_w_SACK}
    ...                             ${shiftIPV4_SCTP_w_SACK}
    # Build filter:
    ${filter}                       set variable                         ${EMPTY}
    FOR     ${msgId}      IN        @{MESSAGE_IDS}
             ${filter}              Get ICOM filter
             ...                        msgId=${msgId}
             ...                        prefixList=${ICOMPrefixList}
             ...                        filter=${filter}
    END
    ${filter}                       set variable                         '${filter}'
    [Return]                        ${filter}

Get Filter all BIP msgs
    [Documentation]                 Build filter expression for tcpdump command in order to capture only BIP msgs.
    ...
    ...                             The keyword returns the builded filter.
    ...
    [Arguments]
    ${filter}                       set variable                         ${EMPTY}
    ${filter}                       Fill message Filter                  prefixType=${PREFIX_ETHER_BIP_MSG_HEAD}
    ...                                                                  msgId=${BIP_PROTO_ID}
    ...                                                                  filter=${filter}
    [Return]                        ${filter}

Get Filter For ARP
    [Documentation]                 Build filter expression for tcpdump command in order to capture only ARP msgs.
    ...
    ...                             The keyword returns the builded filter.
    ...
    ...                             *Argument details:*
    ...                              - capture : specifies the interface of the card on which we want to filter.
    [Arguments]                     ${capture}
    ${prefixL1}                     Get Overhead L1                      ${capture}
    # ARP_w_VLAN=ETH/Linux + VLAN -2: 14/16 + 4 -2 = 16/18
    ${shift_ARP_w_VLAN}             evaluate                             ${prefixL1}+${OH_VLAN}-2
    # ARP_wo_VLAN=ETH/Linux  -2: 14/16  -2 = 12/14
    ${shift_ARP_wo_VLAN}            evaluate                             ${prefixL1}-2
    ${filter}           Run Keyword if                                   ${prefixL1} != ${OH_LINUX}
    ...                     set variable
    ...                     (arp or broadcast or ether[${shift_ARP_w_VLAN}:2]==${ARP_PROTO_ID} or ether[${shift_ARP_wo_VLAN}:2]==${ARP_PROTO_ID})
    ...                 ELSE
    ...                     set variable
    ...                     (arp or ether[${shift_ARP_w_VLAN}:2]==${ARP_PROTO_ID} or ether[${shift_ARP_wo_VLAN}:2]==${ARP_PROTO_ID})
    [Return]                        ${filter}

Get Filter For UDP
    [Documentation]                 Build filter expression for tcpdump command in order to capture only UDP msgs.
    ...
    ...                             The keyword returns the builded filter.
    ...
    ...                             *Argument details:*
    ...                              - capture : specifies the interface of the card on which we want to filter.
    [Arguments]                    ${capture}
    ${prefixL1}                     Get Overhead L1                      ${capture}
    # UDP_w_VLAN=ETH/Linux + VLAN : 14/16 + 4 +6 = 24/26
    ${shift_UDP_w_VLAN}             evaluate                             ${prefixL1}+${OH_VLAN}+6
    ${filter}                       Run Keyword if                       ${prefixL1} != ${OH_LINUX}
    ...                             set variable
    ...                             (udp or ether[${shift_UDP_w_VLAN}:1]==${UDP_PROTO_ID} or ether[23:1]==${UDP_PROTO_ID})
    ...        ELSE                 set variable
    ...        (udp or ether[${shift_UDP_w_VLAN}:1]==${UDP_PROTO_ID} or ether[24:1]==${UDP_PROTO_ID} or ether[29:1]==${UDP_PROTO_ID})
    [Return]                        ${filter}

Get Filter For TCP
    [Documentation]                 Build filter expression for tcpdump command in order to capture only TCP msgs.
    ...
    ...                             The keyword returns the builded filter.
    ...
    ...                             *Argument details:*
    ...                              - capture : specifies the interface of the card on which we want to filter.
    [Arguments]                     ${capture}
    ${prefixL1}                     Get Overhead L1                      ${capture}
    # TCP_w_VLAN=ETH/Linux + VLAN : 14/16 + 4 +6 = 24/26
    ${filter}                       Run Keyword if                       ${prefixL1} != ${OH_LINUX}
    ...                             set variable                         ether[24:1]==${TCP_PROTO_ID}
    ...        ELSE                 set variable                         (tcp or ether[26:1]=${TCP_PROTO_ID} or ether[29:1]=${TCP_PROTO_ID})
    [Return]                        ${filter}

Get Filter For ICMP
    [Documentation]                 Build filter expression for tcpdump command in order to capture only ICMP msgs.
    ...
    ...                             The keyword returns the builded filter.
    ...
    ...                             *Argument details:*
    ...                              - capture : specifies the interface of the card on which we want to filter.
    [Arguments]                     ${capture}
    ${prefixL1}                     Get Overhead L1                      ${capture}
    # TCP_w_VLAN=ETH/Linux + VLAN : 14/16 + 4 +6 = 24/26
    ${filter}                       Run Keyword if                       ${prefixL1} != ${OH_LINUX}
    ...                             set variable                         (icmp or icmp6 or ether[24:1]=${ICMPv6_PROTO_ID})
    ...                             ELSE                                 set variable
    ...                             (icmp or icmp6 or ether[29:1]=${ICMPv4_PROTO_ID} or ether[26:1]=${ICMPv6_PROTO_ID})
    [Return]                        ${filter}

Get Filter For SCTP
    [Documentation]                 Build filter expression for tcpdump command in order to capture only SCTP msgs.
    ...
    ...                             The keyword returns the builded filter.
    ...
    ...                             *Argument details:*
    ...                              - capture : specifies the interface of the card on which we want to filter.
    [Arguments]                     ${capture}
    ${filter}                       set variable                            sctp
    [Return]                        ${filter}

Get Filter To Exclude protocols
    [Documentation]                 Build filter expression for tcpdump command in order to exclude not necessary protocols from capture.
    ...
    ...                             The keyword returns the builded filter.
    ...
    ...                             *Argument details:*
    ...                              - capture : specifies the interface of the card on which we want to filter.
    ...                              - protocolList : contains list of protocols we want to exclude. Ex: ARP,UDP,TCP,ICMP or SCTP.
    [Arguments]                     ${capture}
    ...                             ${protocolList}

    ${protoDICO}                    Create Dictionary
    ...                                   ARP      Get Filter For ARP
    ...                                   UDP      Get Filter For UDP
    ...                                   TCP      Get Filter For TCP
    ...                                   ICMP     Get Filter For ICMP
    ...                                   SCTP     Get Filter For SCTP
    ${filter}                       set variable                ${EMPTY}
    ${filter1}                      set variable                ${EMPTY}
    Should not be empty             ${protocolList}
    ...                             msg= Please fill the list of protocol
    FOR     ${protocol}      IN     @{protocolList}
             ${passed} =            Run Keyword And Return Status        Dictionary Should Contain Key
             ...                    ${protoDICO}    ${protocol}          msg=there is any keyword for this protocol, remove from the list
             ${filter}              BuiltIn.Run Keyword if               ${passed}
              ...                   Building Filter for protocols
              ...                                  ${capture}
              ...                                  ${filter1}
              ...                                  ${protoDICO}
              ...                                  ${filter}
              ...                                  ${protocol}
              ...        ELSE            set variable            ${filter}
    END
    ${filter}                       set variable                         'not ${filter}'
    [Return]                        ${filter}

Get Filter For Particular Msgs
    [Documentation]                 Build filter expression for tcpdump command in order to get only specified BIP msgs.
    ...
    ...                             The keyword returns the builded filter.
    ...
    ...                             *Argument details:*
    ...                              - bipMsgList: specifies the BIP messages to be captured,
    ...                             \ eg: bipMsgList DlData_SlotTypeReq\ \ \ \ DlData_PatternConfigReq\ \ \ \ SetupReq
    [Arguments]                     ${bipMsgList}
    ${filter}                       set variable                         ${EMPTY}
    # add a message to inform user that the list
    ${filter}                       BuiltIn.Run Keyword if               @{bipMsgList}==@{EMPTY}
    ...                             set variable                         ${filter}
    ...     ELSE                    Build up filter for all msgs         bipMsgList=${bipMsgList}
    ...                                                                  filter=${filter}
    [Return]                        ${filter}


# ==================================
# INTERNAL TOOLS
# ==================================

Get ICOM filter
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${msgId}
    ...                             ${prefixList}
    ...                             ${filter}
    FOR     ${prefix}      IN       @{prefixList}
              ${filter}             BuiltIn.Run Keyword if               '${filter}'=='${EMPTY}'
               ...                  set variable                          ether[${prefix}:2]=${msgId}
               ...         ELSE     set variable                          ${filter} or ether[${prefix}:2]=${msgId}
    END
    [Return]                        ${filter}

Building Filter for protocols
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${capture}
    ...                             ${filter1}
    ...                             ${protoDICO}
    ...                             ${filter}
    ...                             ${protocol}
    ${filter1}=                     Run Keyword                          ${protoDICO['${protocol}']}       ${capture}
    ${filter}                       BuiltIn.Run Keyword if               '${filter}'=='${EMPTY}'
    ...                             ${protoDICO['${protocol}']}          ${capture}
    ...         ELSE                set variable                         ${filter} and not ${filter1}
    [Return]                        ${filter}


Fill message Filter
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${prefixType}
    ...                             ${msgId}
    ...                             ${filter}=${EMPTY}
    ${filter}                       BuiltIn.Run Keyword if               '${filter}'=='${EMPTY}'
    ...                             set variable                         ${prefixType}=${msgId}
    ...     ELSE                    set variable                         ${filter} or ${prefixType}=${msgId}
    [Return]                        ${filter}


Build up filter for all msgs
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${bipMsgList}
    ...                             ${filter}
    ${MESSAGE_IDS}                  analyzer.get_message_Id              msg_names=${bipMsgList}
    Should not be empty             ${MESSAGE_IDS}
    ...                             msg= This message name does not exists.Check correct name in csv file
    ${gnbHw}                        set variable          ${GNB_DU.profil}
    Dated Log                       GNB HW is ${gnbHw}
    ${apHw}                         set variable          ${AP_DU.profil}
    ${PREFIX_ETHER_BIP_MSG_TYPE}    set variable        ${PREFIX_ETHER_BIP_MSG_TYPE_ASIK}
    ${PREFIX_ETHER_BIP_MSG_TYPE}    set variable if    '${GNB_DU.sys[0].M.boardType}'=='ASIL'
    ...                             ${PREFIX_ETHER_BIP_MSG_TYPE_ASIL}    ${PREFIX_ETHER_BIP_MSG_TYPE}
    ${PREFIX_ETHER_BIP_MSG_TYPE}    set variable if     '${gnbHw}'=='BOO' and ${TLConfig.isL1BP}==${True}
    ...                             ${PREFIX_ETHER_BIP_MSG_TYPE_BOO}   ${PREFIX_ETHER_BIP_MSG_TYPE}
    ${PREFIX_ETHER_BIP_MSG_TYPE}    set variable if     '${gnbHw}'=='BO' and ${TLConfig.isL1BP}==${True}
    ...                             ${PREFIX_ETHER_BIP_MSG_TYPE_ASIB}    ${PREFIX_ETHER_BIP_MSG_TYPE}
    ${PREFIX_ETHER_BIP_MSG_TYPE}    set variable if     '${gnbHw}'=='BO' and ${TLConfig.isL1BP}!=${True}
    ...                             ${PREFIX_ETHER_BIP_MSG_TYPE_BO_LO}   ${PREFIX_ETHER_BIP_MSG_TYPE}
    FOR     ${msgId}      IN        @{MESSAGE_IDS}
            ${filter}               Fill message Filter
    ...                             prefixType=${PREFIX_ETHER_BIP_MSG_TYPE}
    ...                             msgId=${msgId}                       filter=${filter}
    END
    ${filter}                       set variable                         ${filter}
    [Return]                        ${filter}


Get Overhead L1
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${capture}
    ${overheadL1}                   Set variable if                      '${capture.interface}'=='any'
    ...                             ${OH_LINUX}
    ...                             ${OH_ETH}
    [Return]                        ${overheadL1}

Get List Overhead SCTP
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${capture}
    ...                             ${ipList}
    ${L1}                           Get Overhead L1                      ${capture}
    ${L1_VLAN_IP_SCTP_WO_SACK}      evaluate        ${L1}+${OH_VLAN}+${OH_IPV4}+${OH_SCTP_WO_SACK}   # 14/16+4+20+28=66/68
    ${L1_VLAN_IP_SCTP_W_SACK}       evaluate        ${L1}+${OH_VLAN}+${OH_IPV4}+${OH_SCTP_W_SACK}    # 14/16+4+20+44=82/84
    ${L1_IP_SCTP_WO_SACK}           evaluate        ${L1}+${OH_IPV4}+${OH_SCTP_WO_SACK}              # 14/16+20+28  =62/64
    ${L1_IP_SCTP_W_SACK}            evaluate        ${L1}+${OH_IPV4}+${OH_SCTP_W_SACK}               # 14/16+20+44  =78/80
    ${L1_IP6_SCTP_WO_SACK}          evaluate        ${L1}+${OH_IPV6}+${OH_SCTP_WO_SACK}              # 14/16+40+28  =82/84
    ${L1_IP6_SCTP_W_SACK}           evaluate        ${L1}+${OH_IPV6}+${OH_SCTP_W_SACK}               # 14/16+40+44  =98/100
    @{list}                         Create List
    run keyword if                  'IPV4' in '${iplist}'
    ...                             append to list                       ${list}
    ...                             ${L1_VLAN_IP_SCTP_WO_SACK}           ${L1_VLAN_IP_SCTP_W_SACK}
    ...                             ${L1_IP_SCTP_WO_SACK}                ${L1_IP_SCTP_W_SACK}
    run keyword if                  'IPV6' in '${iplist}'
    ...                             append to list                       ${list}
    ...                             ${L1_IP6_SCTP_WO_SACK}               ${L1_IP6_SCTP_W_SACK}
    [Return]                        ${list}

Get Filter For SCTP Proto
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${capture}                           ${proto}
    ...                             ${ipList}
    @{list}                         Get List Overhead SCTP
    ...                             capture=${capture}                   ipList=${ipList}
    ${filter}                       set variable                         ${EMPTY}
    FOR    ${oh}       IN           @{list}
            ${to_proto}             evaluate                             ${oh}-${LEN_PROTO_SCTP}
            ${newFilter}            set variable                         ether[${to_proto}:${LEN_PROTO_SCTP}]=${proto}
            ${filter}               set variable if                      '${filter}'=='${EMPTY}'
            ...                     ${newFilter}                         ${filter} or ${newFilter}
    END
    [Return]                        ${filter}
