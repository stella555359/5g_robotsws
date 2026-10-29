*** Settings ***
Documentation   This is a keyword file for CB008731, part wireshark verification pcmd trace
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Variables ***

${filter_ngHoSrcRecord}           nsetapx.CuVendorExtensionRecordDataType == 21
${filter_pduSessionResInfoRec}    nsetapx.CuVendorExtensionRecordDataType == 14
${filter_ueSetupRec}              nsetapx.CuVendorExtensionRecordDataType == 13
${filter_ngHoTgtRecord}           nsetapx.CuVendorExtensionRecordDataType == 22

${failHO_el}    field[@name="nsetapx.data_element"]
${failHO_pduSessionResourceInfoRecord}   field[@name="nsetapx.pduSessionResourceInfoRecord"]/${failHO_el}
${failHO_ngHoTgtRecord}  field[@showname="CuVendorExtensionRecordDataType: ngHoTgtRecord (22)"]/field[@name="nsetapx.ngHoTgtRecord"]/${failHO_el}
${failHO_ueSetupRecord}  field[@showname="CuVendorExtensionRecordDataType: ueSetupRecord (13)"]/field[@name="nsetapx.ueSetupRecord"]/${failHO_el}

*** Keywords ***

verify wireshark 8731 t9
    [Documentation]    [PRIVATE]    verify wireshark for PCMD_trace_for_interRAT_HO_from_LTE_to_5G
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB008731_PCMD_trace_for_interRAT_HO_from_LTE_to_5G
    verify pcmd trace lte handover
    verify pcmd trace successful 5G handover
    verify pcmd trace failed 5G handover


verify pcmd trace lte handover
    [Documentation]    [PRIVATE]    verify pcmd trace lte handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify LTE handover - CuVendorExtensionRecordDataType contains ngHoSrcRecord
    ${cmd1}   set variable   tshark -r ${resultDir}/pcmd_trace_ho_lte/pcmd_trace_ho_lte.pcap -o ntrstr.port:49151 -Y "${filter_ngHoSrcRecord}"
    ${msg}     Run     ${cmd1} | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${1}
    ...     Wrong number of messages


verify pcmd trace successful 5G handover
    [Documentation]    [PRIVATE]    verify pcmd trace successful 5G handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify successful 5G handover - pduSessionResourceInfoRecord contains fiveQi 6,7,8,9
    ${cmd1}   set variable   tshark -r ${resultDir}/pcmd_trace_ho_5G/pcmd_trace_ho_5G.pcap -o ntrstr.port:49151 -Y "${filter_pduSessionResInfoRec}"
    ${cmd2}   set variable   -T pdml > ${resultDir}/pduSessionResInfoRec.xml
    ${rc}    Run And Return Rc     ${cmd1} ${cmd2}
    ${parsed_pdu}    parse xml    ${resultDir}/pduSessionResInfoRec.xml
    FOR    ${item}   ${qfi}   ${fiveQi}   ${erabId}    IN
    ...    0         1        6           0
    ...    1         2        7           1
    ...    2         3        8           2
    ...    3         4        9           3
       Log To Console   check if item ${item} contains qfi ${qfi}, fiveQi ${fiveQi}, erabId ${erabId}
       ${msg_string_req}         element to string    ${parsed_pdu}     xpath=.//field[@name="nsetapx.setupQosFlows"]/field[@show="Item ${item}"]
       run keyword and continue on failure   should contain    ${msg_string_req}   showname="qfi: ${qfi}"
       run keyword and continue on failure   should contain    ${msg_string_req}   showname="fiveQi: ${fiveQi}"
       run keyword and continue on failure   should contain    ${msg_string_req}   showname="erabId: ${erabId}"
    END
    ${msg}         element to string    ${parsed_pdu}     xpath=.//field[@name="nsetapx.pduSessionResourceInfoRecord"]
    Log To Console    --check pduSessionResourceInfoRecord contains showname="trigger: handover (2)"
    run keyword and continue on failure   should contain    ${msg}   showname="trigger: handover (2)"
    Log To Console    --check pduSessionResourceInfoRecord contains showname="result: success (0)"
    run keyword and continue on failure   should contain    ${msg}   showname="result: success (0)"



verify pcmd trace failed 5G handover
    [Documentation]    [PRIVATE]    verify pcmd trace failed 5G handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify pcmd trace failed 5G handover

    ${cmd1}   set variable   tshark -r ${resultDir}/pcmd_trace_hoFailure/pcmd_trace_hoFailure.pcap -o ntrstr.port:49151
    ${cmd2}   set variable   -T pdml > ${resultDir}/pcmd_HO_failure.xml
    ${rc}    Run And Return Rc     ${cmd1} ${cmd2}
    ${parsed_ho_fail}    parse xml    ${resultDir}/pcmd_HO_failure.xml

    Log To Console    --check pduSessionResourceInfoRecord contains showname="trigger: handover (2)"
    ${no_of_msgs}    Get Element Count      ${parsed_ho_fail}
    ...    xpath=.//${failHO_pduSessionResourceInfoRecord}/field[@showname="trigger: handover (2)"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${no_of_msgs}    ${1}
    ...     wrong number of Message pduSessionResourceInfoRecord, trigger: handover (2)

    Log To Console    --check pduSessionResourceInfoRecord contains showname="result: miscFailure (1)"
    ${no_of_msgs}    Get Element Count      ${parsed_ho_fail}
    ...    xpath=.//${failHO_pduSessionResourceInfoRecord}/field[@showname="result: miscFailure (1)"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${no_of_msgs}    ${1}
    ...     wrong number of Message pduSessionResourceInfoRecord, result: miscFailure (1)

    Log To Console    --check ueSetupRecord contains showname="trigger: other (0)"
    ${no_of_msgs}    Get Element Count      ${parsed_ho_fail}
    ...    xpath=.//${failHO_ueSetupRecord}/field[@showname="trigger: other (0)"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${no_of_msgs}    ${1}
    ...     wrong number of Message ueSetupRecord, trigger: other (0)

    Log To Console    --check ueSetupRecord contains showname="result: miscFailure (1)"
    ${no_of_msgs}    Get Element Count      ${parsed_ho_fail}
    ...    xpath=.//${failHO_ueSetupRecord}/field[@showname="result: miscFailure (1)"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${no_of_msgs}    ${1}
    ...     wrong number of Message ueSetupRecord, result: miscFailure (1)

    Log To Console    --check ngHoTgtRecord contains showname="result: miscFailure (1)"
    ${no_of_msgs}    Get Element Count      ${parsed_ho_fail}
    ...    xpath=.//${failHO_ngHoTgtRecord}/field[@showname="result: miscFailure (1)"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${no_of_msgs}    ${1}
    ...     wrong number of Message ngHoTgtRecord, result: miscFailure (1)
