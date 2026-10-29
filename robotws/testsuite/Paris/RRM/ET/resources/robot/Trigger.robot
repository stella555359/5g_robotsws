*** Settings ***
Documentation       CNI GENERIC TEST
Library             OperatingSystem
Library             Collections
Library             ../python/luashark_tools.py
Library             luashark_tools.analyzer       WITH NAME       analyzer
Library             ../../../../resources/SWENG/python/StringTool.py
Library             ../python/Trigger.py

*** Keywords ***

Get Triggers and responses UL Data Prach
    [Arguments]                     ${pcapFile}
    ...                             ${respDefList}
    ${pdmlFile}                     analyzer.pcap_to_pdml                   pcapFile=${pcapFile}
    @{listTrigger}                  Build List Trigger And Responses
    ...                                 pdmlFile=${pdmlFile}
    ...                                 packetName=uldata_prachreceivereq
    ...                                 respDefList=${respDefList}
    #...                                 respDefList=${UlDataPrachRespDefList}
    # Display all triggers and their responses
    FOR    ${trigger}  IN          @{listTrigger}
           Trigger.TriggerMsgPrint                                         triggerMsg=${trigger}
    END
    Set suite variable              ${listTrigger}

Build List Trigger And Responses
    [Documentation]                 Build a list of TriggerMsg by parsing a pdml file
    ...                             Responses are also searched and associated to each pertinent trigger
    ...                             Responses with same slot/sfn are associated to its trigger message
    [Arguments]                     ${pdmlFile}                             # Input PDML File
    ...                             ${packetName}                           # name of packet to be used as trigger
    ...                             ${respDefList}                          # list of definition of responses to associate
    ...                             ${excludeExtrema}=${True}
    # Building list of name of response
    ${respNameList}                 Create List
    FOR    ${def}  IN              @{respDefList}
           Append to list          ${respNameList}                         ${def.msg}
    END
    # Search for all triggers
    @{listTrigger}                  Get List Trigger
    ...                                 pdmlFile=${pdmlFile}
    ...                                 packetName=${packetName}
    ...                                 respNameList=${respNameList}
    ...                                 excludeExtrema=${excludeExtrema}
    # Search for all responses matching same slot
    FOR    ${RespDef}     IN       @{respDefList}
           @{ListMsg}              Get List Response Same Slot
           ...                         pdmlFile=${pdmlFile}
           ...                         respDef=${RespDef}
           ...                         slot=${listTrigger[0].slot}
           # then, searching responses matching same sfn, for all different trigger msg
           Get Responses Same Sfn  listTrigger=${listTrigger}
           ...                     respDef=${RespDef}
           ...                     listMsg=${listMsg}
    END
    [Return]                        @{listTrigger}


Get List Trigger
    [Documentation]                 Parse a pdml file to retrieve all trigger packet
    ...                             Then, build a list of TriggerMsg struct
    [Arguments]                     ${pdmlFile}
    ...                             ${packetName}
    ...                             ${respNameList}
    ...                             ${excludeExtrema}

    Dated log                       Search for ${packetName}
    @{ListPacketMatch}              analyzer.get_match_from_paths
    ...                                 pdmlFile=${pdmlFile}
    ...                                 packetName=${packetName}
    ...                                 pathList=${MSG_FIELDS_SLOT_SFN}
    ${len}                          Get Length                              ${ListPacketMatch}
    @{ListTrigger}                  Trigger.NewTriggerMsgList
    ...                                 packetList=${ListPacketMatch}
    ...                                 respNameList=${respNameList}
    ...                                 excludeExtrema=${False}
    Dated log                       ${packetName}: Found ${len} packets
    [Return]                        ${ListTrigger}


Get List Response Same Slot
    [Documentation]                 Parse a pdml file and search for all responses packets
    ...                             matching a response definition and matching same slot as the trigger
    [Arguments]                     ${pdmlFile}
    ...                             ${respDef}
    ...                             ${slot}
    Dated log                       Search for ${respDef.msg} with slot=${slot}
    @{listPacket}                   analyzer.get_match_from_paths
    ...                                 pdmlFile=${pdmlFile}
    ...                                 packetName=${respDef.msg}
    ...                                 pathList=${respDef.fields}
    ...                                 filter='slot$'==${slot}
    ${len}                          Get Length                              ${listPacket}
    Dated log                       ${respDef.msg}: Found ${len} packets
    [Return]                        ${listPacket}

Get Responses Same Sfn
    [Documentation]                 Filter a list of messages to get only responses matching same sfn
    ...                             as triggers, and add them to trigger structure
    ...                             This is done for all triggers in the trigger list
    [Arguments]                     ${listTrigger}                          # List of triggers
    ...                             ${respDef}                              # Response definition
    ...                             ${listMsg}                              # List of response to filter
    FOR    ${trigger}  IN          @{listTrigger}
           @{listPacketSameSfn}    analyzer.apply_filter
           ...                         listSubPacket=${listMsg}
           ...                         filter='sfn$'==${trigger.sfn}
           Trigger.addListRespToTrigger
           ...                     triggerMsg=${trigger}
           ...                     respName=${respDef.msg}
           ...                     listPacket=${listPacketSameSfn}
    END

Check At least one Response
    [Documentation]         Count nb of response of one type associated to a list of trigger
    ...                     Then check that it is in line with expected result
    ...                     expected is a boolean : at least one response or not
    [Arguments]             ${respName}         # Name of response
    ...                     ${expected}=${True}         # Expected result : True or False
    Dated log               Check at least one response for ${respName} is ${expected}
    ${total}                Set variable        ${0}
    FOR    ${trigger}  IN  @{ListTrigger}
           ${nbPacket}     Set Variable        ${trigger.dictResp['${respName}'].nbPacket}
           ${total}        Evaluate            ${total}+${nbPacket}
    END
    ${obtained}             set variable if     '${total}'=='0'
    ...                     ${False}             ${True}
    Dated log               Number of ${respName} found:${total} Expected:${expected} Obtained:${obtained}
    Should be equal         ${expected}         ${obtained}

Check Number Of Records in Responses
    [Documentation]                 Parse all trigger msg and check that records number in 2 responses
    ...                             are identical
    [Arguments]                     ${respName1}
    ...                             ${respName2}
    Dated log                       Checking nb of RECORDS in ${respName1} is same as in ${respName2}
    ${nbErrTotal}                   Set variable                            ${0}
    ${atLeastOne}                   Set Variable                            ${False}
    FOR    ${trigger}  IN          @{listTrigger}
           ${resp1}                Set variable                            ${trigger.dictResp['${respName1}']}
           ${resp2}                Set variable                            ${trigger.dictResp['${respName2}']}
           ${nbRec1}               Get length                              ${resp1.listRec}
           ${nbRec2}               Get length                              ${resp2.listRec}
           ${suffix1}              Set variable
           ...                     ${respName1}:Pck=${resp1.nbPacket} Rec=${nbRec1}
           ${suffix2}              Set variable
           ...                     ${respName2}:Pck=${resp2.nbPacket} Rec=${nbRec2}
           ${diag}                 Set variable if                         '${nbRec1}'=='${nbRec2}'
           ...                     OK                                      ERROR
           ${nbErr}                Set variable if                         '${nbRec1}'=='${nbRec2}'
           ...                     ${0}                                    ${1}
           ${nbErrTotal}           Evaluate                                ${nbErrTotal}+${nbErr}
           ${packetStr}            Get formated Packet name                ${trigger}
           ${atLeastOne}           Set variable if                         ${nbRec1}!=${0}
           ...                     ${True}                                 ${atLeastOne}
           Dated log               \tTrigger:${packetStr} ${suffix1} ${suffix2}: ${diag} AtLeastOne:${atLeastOne}
    END
    Dated log                       Found ${nbErrTotal} diff while comparing number of records between ${respName1} and ${respName2}
    Should be true                  ${atLeastOne}
    ...                             ERROR : No ${respName1} messages found in whole packets
    [Return]                        ${nbErrTotal}

Check Field in Response
    [Documentation]                 Check in a particular kind of response, for all trigger messages
    ...                             a field is set to a particular value for all found records
    [Arguments]                     ${respName}
    ...                             ${field}
    ...                             ${expected}
    ...                             ${test}===
    ...                             ${isSlotSfnStr}=${False}
    Dated log                       Checking in ${respName} that all ${field}${test}${expected}
    ${nbErrTotal}                   Set variable                            ${0}
    FOR    ${trigger}  IN          @{ListTrigger}
           ${slotSnfStr}           Set variable if                         ${isSlotSfnStr}
           ...                     Slot:${trigger.slot} SFN:${trigger.sfn}  ${EMPTY}
           ${nbErr}                Check Field in records
           ...                         listRec=${trigger.dictResp['${respName}'].listRec}
           ...                         field=${field}
           ...                         expected=${expected}
           ...                         test=${test}
           ...                         extraStr=${slotSnfStr}
           ${nbErrTotal}           Evaluate                                ${nbErrTotal}+${nbErr}
    END
    [Return]                        ${nbErrTotal}

Check Field in records
    [Documentation]                 Check in a list of records that a field is set to a particular value
    ...                             It only return the number of errors met
    [Arguments]                     ${listRec}
    ...                             ${field}
    ...                             ${expected}
    ...                             ${test}===
    ...                             ${extraStr}=${EMPTY}
    ${nbErr}                        Set variable                            ${0}
    FOR    ${rec}  IN              @{listRec}
           ${value}                Set Variable                            ${rec.fields['${field}']}
           ${testDiag}             Set Variable if                         '${expected}'=='${value}'
           ...                     ==                                      !=
           ${diag}                 Set variable if                         '${testDiag}'=='${test}'
           ...                     OK                                      ERROR
           ${curErr}               Set Variable if                         '${diag}'=='OK'
           ...                     ${0}                                    ${1}
           ${nbErr}                Evaluate                                ${nbErr}+${curErr}
           ${packetStr}            Get formated Packet name                ${rec}
           ${prefix}               Set Variable                            \tPacket:${packetStr} ${extraStr} RNTI:${rec.rnti}
           Dated log               ${prefix} ${field}:Expected=${expected} TEST=[${test}] Obtained=${value} :DIAG=${diag}
    END
    [Return]                        ${nbErr}

Get Formated Packet name
    [Arguments]                     ${rec}
    ${packetStr}                    Evaluate                                "{:36}".format($rec.packet.namedPacket.__str__())
    [Return]                        ${packetStr}

Get Decimal Value
    [Arguments]                     ${str}
    @{groups}                       Get Regexp Matches                      ${str}
    ...                                 0[x]0+([0-9a-f]+)                   1
    ${res}                          Convert To Integer                      @{groups}[0]
    #Dated log                       ${res}
    [return]                        ${res}


Get Triggers and responses DL Data SsBlockSendReq
    [Arguments]                     ${pcapFile}
    ${pdmlFile}                     analyzer.pcap_to_pdml                   pcapFile=${pcapFile}
    @{SsBlistTrigger}                  Build List Trigger And Responses
    ...                                 pdmlFile=${pdmlFile}
    ...                                 packetName=dldata_ssblocksendreq
    ...                                 respDefList=${DlDataScBlockSendReqDefList}
    ...                                 excludeExtrema=${False}
    # Display all triggers and their responses
    FOR    ${trigger}  IN          @{SsBlistTrigger}
           Trigger.TriggerMsgPrint                                         triggerMsg=${trigger}
    END
    Set suite variable              ${SsBlistTrigger}



Check At least one Response SSB
    [Documentation]         Count nb of response of one type associated to a list of trigger
    ...                     Then check that it is in line with expected result
    ...                     expected is a boolean : at least one response or not
    [Arguments]             ${respName}         # Name of response
    ...                     ${expected}=${True}        # Expected result : True or False
    Dated log               Check at least one response for ${respName} is ${expected}
    ${total}                Set variable        ${0}
    FOR    ${trigger}  IN  @{SsBlistTrigger}
           ${nbPacket}     Set Variable        ${trigger.dictResp['${respName}'].nbPacket}
           ${total}        Evaluate            ${total}+${nbPacket}
    END
    ${obtained}             set variable if     '${total}'=='0'
    ...                     ${False}             ${True}
    Dated log               Number of ${respName} found:${total} Expected:${expected} Obtained:${obtained}
    Should be equal         ${expected}         ${obtained}


Get Triggers and responses UL Data PrachReceiveInd
    [Arguments]                     ${pcapFile}
    ${pdmlFile}                         analyzer.pcap_to_pdml                   pcapFile=${pcapFile}
    @{PrachReceiveIndlistTrigger}       Build List Trigger And Responses
    ...                                 pdmlFile=${pdmlFile}
    ...                                 packetName=uldata_prachreceiveind
    ...                                 respDefList=${UlDataPrachReceiveIndDefList}
    # Display all triggers and their responses
    FOR    ${trigger}  IN          @{PrachReceiveIndlistTrigger}
           Trigger.TriggerMsgPrint                                         triggerMsg=${trigger}
    END
    Set suite variable              ${PrachReceiveIndlistTrigger}



Check message in PrachReceiveInd slot
    [Documentation]         Count nb of response of one type associated to a list of trigger
    ...                     Then check that it is in line with expected result
    ...                     expected is a boolean : at least one response or not
    [Arguments]             ${MsgName}         # Name of response
    ...                     ${expected}=${True}        # Expected result : True or False
    Dated log               Check at least one response for ${MsgName} is ${expected}
    ${total}                Set variable        ${0}
    FOR    ${trigger}  IN  @{PrachReceiveIndlistTrigger}
           ${nbPacket}     Set Variable        ${trigger.dictResp['${MsgName}'].nbPacket}
           ${total}        Evaluate            ${total}+${nbPacket}
    END
    ${obtained}             set variable if     '${total}'=='0'
    ...                     ${False}             ${True}
    Dated log               Number of ${MsgName} found:${total} Expected:${expected} Obtained:${obtained}
    Should be equal         ${expected}         ${obtained}

