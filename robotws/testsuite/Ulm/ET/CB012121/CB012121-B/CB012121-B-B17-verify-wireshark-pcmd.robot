*** Settings ***
Documentation   This is a keyword file for CB012121-B-B17, part wireshark verification pcmd
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Variables ***

${filter_ueMeasRecord}               nsetapx.CuVendorExtensionRecordDataType == 3
${filter_eutranCarrierFreq}          nsetapx.eutranCarrierFreq == 1

*** Keywords ***


verify wireshark pcmd CB012121-B-B17
    [Documentation]    [PRIVATE]    verify wireshark pcmd CB012121-B-B17
    ...       :Autor: Sylvia Schneider
    Log To Console    \nverify pcmd trace
    Log To Console    filter for the message which contains ueMeasRecord and eutranCarrierFreq:1
    ${filter}   Set Variable   ${filter_ueMeasRecord} && ${filter_eutranCarrierFreq}

    ${cmd1}   Set Variable   tshark -r ${resultDir}/pcmd_trace_B17/pcmd_trace_B17.pcap -o ntrstr.port:49151
    ${cmd2}   Set Variable   -Y "${filter}" -T pdml > ${resultDir}/pcmd_trace.xml
    ${rc}    Run And Return Rc     ${cmd1} ${cmd2}
    ${parsed_trace}    Parse Xml    ${resultDir}/pcmd_trace.xml

    FOR   ${xpath}   IN
    ...   field[@showname\="eutranCarrierFreq: 1"]
    ...   field[@showname\="triggerType: b2 (7)"]
    ...   field[@showname\="purpose: interRatHo (7)"]
    ...   field[@showname\="MeasResultServingMo"]/field[@showname="servCellId: 0"]
    ...   field[@showname\="MeasResultServingMo"]/field[@showname="pci: 50"]
    ...   field[@showname\="ssbCellResult"]/field[@showname="rsrp: 11"]
    ...   field[@showname\="ssbCellResult"]/field[@showname="rsrq: 11"]
    ...   field[@showname\="measResultSsb"]/field[@showname="rsrp: 11"]
    ...   field[@showname\="measResultSsb"]/field[@showname="rsrq: 11"]
    ...   field[@name\="nsetapx.MeasResultNeighCellEutran_element"]/field[@showname="pci: 11"]
    ...   field[@showname\="cellResult"]/field[@showname="rsrp: 30"]
    ...   field[@showname\="cellResult"]/field[@showname="rsrq: 30"]
       Log To Console   verify 1 item present "${xpath}"
       ${no_of_msgs}    Get Element Count      ${parsed_trace}   xpath=.//${xpath}
       Run Keyword And Continue On Failure   Should Be Equal As Integers    ${no_of_msgs}    ${1}
    END

