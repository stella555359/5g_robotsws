** Settings ***
Documentation   This is a keyword file for 5GC000480-L, part wireshark
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${WIRESHARK_RUNNING}     false

${SgNBAddReqAck_RRCreconf}    (x2ap.procedureCode == 27) && (ip.dst == 10.0.1.137)
${xpath_spCellConfigCommon}   field[@showname="spCellConfigCommon"]
${xpath_physCellId}           field[@name="nr-rrc.physCellId"]
${xpath_sCellToAddModList}    field[@name="nr-rrc.sCellToAddModList"]
${xpath_sCellConfigCommon}    field[@showname="SCellConfig"]/field[@showname="sCellConfigCommon"]
${xpath_sCellConfigCommon_element}    field[@name="nr-rrc.sCellConfigCommon_element"]



*** Keywords ***

Start Wireshark Trace
    [Documentation]    [PRIVATE]    start wireshark trace
    ...       :Autor: Sylvia Schneider
    tcpdump.Start TCPDump On TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Sleep     1s
    Set Suite Variable      ${WIRESHARK_RUNNING}    true


Stop Wireshark Trace
    [Documentation]    [PRIVATE]    stop wireshark trace
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${WIRESHARK_RUNNING}'=='false'   RETURN
    Sleep     2s
    @{result_place}    Split String     ${wireshark_store}    /
    ${tcpdump_dir}     Remove String    ${wireshark_store}    /${result_place}[-1]
    ${tcpdump_file}    tcpdump.Stop TCPDump On TestPc
    ...  collector=dump_testpc
    ...  target_dir=${tcpdump_dir}
    Sleep     2s
    Move File    ${tcpdump_file}    ${wireshark_store}
    Set Suite Variable      ${WIRESHARK_RUNNING}    false


Stop Wireshark Trace For Setup
    [Documentation]    [PRIVATE]    stop wireshark trace for setup
    ...       :Autor: Sylvia Schneider
    Stop Wireshark Trace            wireshark_store=${resultDir}/wireshark_startTL.pcap


Get SgNBAddReqAck_RRCreconf Message And Convert To Xml
    [Documentation]    [PRIVATE]    Get SgNBAddReqAck_RRCreconf Message And Convert To Xml
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${file}
    Run And Return Rc     tshark -r ${file}.pcap -Y "${SgNBAddReqAck_RRCreconf}" -T pdml > ${file}.xml
    ${rrc_xml}    Parse Xml    ${file}.xml
    Set Test Variable    ${rrc_xml}


Verify spCellConfigCommon Contains physCellId ${phyCell_expected}
    [Documentation]    [PRIVATE]    Verify spCellConfigCommon Contains physCellId
    ...       :Autor: Sylvia Schneider
    Log To Console    \n..checking in "spCellConfigCommon" field "nr-rrc.physCellId" contains phyCell show ${phyCell_expected}
    Run Keyword And Continue On Failure   Element Attribute Should Match    ${rrc_xml}
    ...    show
    ...    ${phyCell_expected}
    ...    xpath=.//${xpath_spCellConfigCommon}/${xpath_physCellId}


Verify sCellConfigCommon With Several Items Containing
    [Documentation]    [PRIVATE]    verify wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]    @{physCell_list_expected}
    Log To Console    ..checking that correct number of items in xpath_sCellToAddModList
    ${no_of_items_expected}  Get Length    ${physCell_list_expected}
    ${no_of_items_xml}   Get Element Attribute    ${rrc_xml}  show  xpath=.//${xpath_sCellToAddModList}
    Run Keyword And Continue On Failure   Should Be Equal As Integers   ${no_of_items_expected}   ${no_of_items_xml}
    ${physCellId_list_xml}   Create List
    Set Test Variable   ${physCellId_list_xml}
    FOR   ${index}    IN RANGE   0    ${no_of_items_xml}
          Check ScellConfigCommon Item ${index}
    END
    FOR   ${exp_item}   IN   @{physCell_list_expected}
       Log To Console    ..checking that "nr-rrc.sCellConfigCommon_element" contains field "nr-rrc.physCellId" with value ${exp_item}
       Run Keyword And Continue On Failure
       ...   List Should Contain Value    ${physCellId_list_xml}     ${exp_item}      physCellId ${exp_item} not present
    END


Check ScellConfigCommon Item ${item_id}
    [Documentation]    [PRIVATE]    extract physCellId from sCellConfigCommon
    ...       :Autor: Sylvia Schneider
    ${_}   ${value}   Run Keyword And Ignore Error   Get Element Attribute
    ...   ${rrc_xml}
    ...   show
    ...   xpath=.//field[@show="Item ${item_id}"]/${xpath_sCellConfigCommon}/${xpath_physCellId}
    Append To List     ${physCellId_list_xml}    ${value}


Verify sCellConfigCommon Containing Item physCellId ${phyCell_expected}
    [Documentation]    [PRIVATE]    Verify sCellConfigCommon Containing Item physCellId
    ...       :Autor: Sylvia Schneider
    Log To Console    ..checking that "nr-rrc.sCellConfigCommon_element" contains field "nr-rrc.physCellId" with value ${phyCell_expected}
    Run Keyword And Continue On Failure   Element Attribute Should Match    ${rrc_xml}
    ...    show
    ...    ${phyCell_expected}
    ...    xpath=.//${xpath_sCellConfigCommon_element}/${xpath_physCellId}


Verify physCellId Not Present 51 52 53
    [Documentation]    [PRIVATE]    Verify physCellId Not Present 51 52 53
    ...       :Autor: Sylvia Schneider
    FOR   ${id}    IN   51   52   53
       Log To Console    \nverify "physCellId: ${id}" does not exist
       Run Keyword And Continue On Failure   Element should not exist   source=${rrc_xml}   xpath=.//field[@showname="physCellId: ${id}"]
       ...    message="physCellId: ${id}" should not exist
   END


Verify Wireshark 4CC
    [Documentation]    [PRIVATE]    verify wireshark 4CC
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify wireshark UE101 SgNBAdditionRequestAcknowledge, RRC Reconfiguation
    Get SgNBAddReqAck_RRCreconf Message And Convert To Xml   file=${resultDir}/UE101
    Verify spCellConfigCommon Contains physCellId 50
    Verify sCellConfigCommon With Several Items Containing     51  52  53


Verify Wireshark t2
    [Documentation]    [PRIVATE]    verify wireshark t2
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify wireshark UE101 SgNBAdditionRequestAcknowledge, RRC Reconfiguation
    Get SgNBAddReqAck_RRCreconf Message And Convert To Xml   file=${resultDir}/UE101
    Verify spCellConfigCommon Contains physCellId 50
    Verify sCellConfigCommon With Several Items Containing    51  52


Verify Wireshark t7
    [Documentation]    [PRIVATE]    verify wireshark t7
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify wireshark UE101 SgNBAdditionRequestAcknowledge, RRC Reconfiguation
    Get SgNBAddReqAck_RRCreconf Message And Convert To Xml   file=${resultDir}/UE101
    Verify spCellConfigCommon Contains physCellId 50
    Verify sCellConfigCommon With Several Items Containing    52  53


Verify Wireshark 2CC
    [Documentation]    [PRIVATE]    verify wireshark 2CC
    ...       :Autor: Sylvia Schneider
    Get SgNBAddReqAck_RRCreconf Message And Convert To Xml   file=${resultDir}/UE101
    Verify spCellConfigCommon Contains physCellId 50
    Verify sCellConfigCommon Containing Item physCellId 51


Verify Wireshark t4
    [Documentation]    [PRIVATE]    verify wireshark t4
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify wireshark UE101 SgNBAdditionRequestAcknowledge, RRC Reconfiguation
    Get SgNBAddReqAck_RRCreconf Message And Convert To Xml   file=${resultDir}/UE101
    Verify spCellConfigCommon Contains physCellId 50
    Verify sCellConfigCommon With Several Items Containing    51  52  53

    Log To Console    \nverify wireshark UE102 SgNBAdditionRequestAcknowledge, RRC Reconfiguation
    Get SgNBAddReqAck_RRCreconf Message And Convert To Xml   file=${resultDir}/UE102
    Verify spCellConfigCommon Contains physCellId 50
    Verify sCellConfigCommon Containing Item physCellId 51


Verify Wireshark t5
    [Documentation]    [PRIVATE]    verify wireshark t5
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify wireshark UE101 SgNBAdditionRequestAcknowledge, RRC Reconfiguation
    Get SgNBAddReqAck_RRCreconf Message And Convert To Xml   file=${resultDir}/UE101
    Verify spCellConfigCommon Contains physCellId 50
    Verify sCellConfigCommon With Several Items Containing    51  52  53

    Log To Console    \nverify wireshark UE102 SgNBAdditionRequestAcknowledge, RRC Reconfiguation
    Get SgNBAddReqAck_RRCreconf Message And Convert To Xml   file=${resultDir}/UE102
    Verify spCellConfigCommon Contains physCellId 51
    Verify sCellConfigCommon With Several Items Containing    52  53

    Log To Console    \nverify wireshark UE103 SgNBAdditionRequestAcknowledge, RRC Reconfiguation
    Get SgNBAddReqAck_RRCreconf Message And Convert To Xml   file=${resultDir}/UE103
    Verify spCellConfigCommon Contains physCellId 50


Verify Wireshark t9
    [Documentation]    [PRIVATE]    verify wireshark t9
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify wireshark UE101 SgNBAdditionRequestAcknowledge, RRC Reconfiguation
    Get SgNBAddReqAck_RRCreconf Message And Convert To Xml   file=${resultDir}/UE101
    Verify spCellConfigCommon Contains physCellId 50
    Verify sCellConfigCommon With Several Items Containing    51  52  53

    Log To Console    \nverify wireshark UE102 SgNBAdditionRequestAcknowledge, RRC Reconfiguation
    Get SgNBAddReqAck_RRCreconf Message And Convert To Xml   file=${resultDir}/UE102
    Verify physCellId Not Present 51 52 53
