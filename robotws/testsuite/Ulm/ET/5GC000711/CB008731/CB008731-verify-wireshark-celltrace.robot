*** Settings ***
Documentation   This is a keyword file for CB008731, part wireshark verification cell trace
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Variables ***

${filter_ho_notify}         ngap.procedureCode==11
${filter_ho_req}            (ngap.procedureCode==13) && !(ngap.NGAP_PDU==1)
${filter_ho_req_ack}        (ngap.procedureCode==13) && (ngap.NGAP_PDU==1)

#${filter_ho_req_ack2}      (ngap.procedureCode == 13) && (ip.src == 10.0.1.2)
${filter_ho_req2}           (ngap.procedureCode == 13) && (ip.dst == 10.0.1.2)
${filter_ho_failure}        (ngap.radioNetwork == 8) && (ip.src == 10.0.1.2)


*** Keywords ***

verify wireshark 8731 t8
    [Documentation]    [PRIVATE]    verify wireshark for Cell_trace_for_interRAT_HO_from_LTE_to_5G
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB008731_Cell_trace_for_interRAT_HO_from_LTE_to_5G

    ${cmd1}   Set Variable   tshark -r ${resultDir}/cell_trace/cell_trace.pcap -o ntrstr.port:49151 -Y "ngap.procedureCode == 13"
    ${cmd2}   Set Variable   -T pdml > ${resultDir}/celltrace_ntrstr.xml
    ${rc}    Run And Return Rc    ${cmd1} ${cmd2}
    ${parsed_ntrstr}    Parse Xml    ${resultDir}/celltrace_ntrstr.xml

    Log to console    verify that handover request message is the same in ngap and ntrstr
    ${msg_string_req}        Element To String    ${parsed_ntrstr}   xpath=.//proto[@showname="NG Application Protocol (HandoverRequest)"]
    ${ntrstr_ho_req_tmp1}    Remove Pos And Leading Spaces                                     ${msg_string_req}
    ${ntrstr_ho_req_tmp2}    Remove Bad Chars From ngap.SourceToTarget_TransparentContainer    ${ntrstr_ho_req_tmp1}
    ${ntrstr_ho_req}         Remove Bad Chars From ngap.rRCContainer                           ${ntrstr_ho_req_tmp2}
    Create File    ${resultDir}/ho_req_ntrstr1.txt            ${ntrstr_ho_req}

    ${parsed_ngap}   Create Xml File
    ...    wireshark_file=${resultDir}/wireshark_part3.pcap
    ...    filter=${filter_ho_req}
    ...    xml_file=${resultDir}/ho_req_ngap.xml
    ${ngap_part_tmp1}     Ngap Get Format Save String    parsed_string=${parsed_ngap}
    ${ngap_part_tmp2}     Remove Bad Chars From ngap.SourceToTarget_TransparentContainer    ${ngap_part_tmp1}
    ${ngap_ho_req}        Remove Bad Chars From ngap.rRCContainer                       ${ngap_part_tmp2}
    Create File      ${resultDir}/ngap_ho_req.txt          ${ngap_ho_req}
    Run Keyword And Continue On Failure   Should Be Equal    ${ntrstr_ho_req}   ${ngap_ho_req}


    Log to console    verify that handover request acknowledge message is the same in ngap and ntrstr
    ${msg_string_ack}      Element To String    ${parsed_ntrstr}   xpath=.//proto[@showname="NG Application Protocol (HandoverRequestAcknowledge)"]
    ${ntrstr_ho_req_ack_tmp1}    Remove Pos And Leading Spaces                                      ${msg_string_ack}
    ${ntrstr_ho_req_ack_tmp2}    Remove Bad Chars From ngap.TargetToSource_TransparentContainer     ${ntrstr_ho_req_ack_tmp1}
    ${ntrstr_ho_req_ack}         Remove Bad Chars From ngap.rRCContainer                            ${ntrstr_ho_req_ack_tmp2}
    Create File   ${resultDir}/ho_req_ack_ntrstr1.txt            ${ntrstr_ho_req_ack}

    ${parsed_ngap}   Create Xml File
    ...    wireshark_file=${resultDir}/wireshark_part3.pcap
    ...    filter=${filter_ho_req_ack}
    ...    xml_file=${resultDir}/ho_req_ack_ngap.xml
    ${ngap_part_tmp1}     Ngap Get Format Save String    parsed_string=${parsed_ngap}
    ${ngap_part_tmp2}     Remove Bad Chars From ngap.TargetToSource_TransparentContainer    ${ngap_part_tmp1}
    ${ngap_ho_req_ack}    Remove Bad Chars From ngap.rRCContainer                           ${ngap_part_tmp2}
    Create File      ${resultDir}/ngap_ho_req_ack.txt          ${ngap_ho_req_ack}
    Run Keyword And Continue On Failure   Should Be Equal    ${ntrstr_ho_req_ack}   ${ngap_ho_req_ack}


    Log to console    verify that handover notify message is the same in ngap and ntrstr
    ${cmd1}   Set Variable   tshark -r ${resultDir}/cell_trace/cell_trace.pcap -o ntrstr.port:49151 -Y "${filter_ho_notify}"
    ${cmd2}   Set Variable   -T pdml > ${resultDir}/celltrace_ntrstr_notif.xml
    ${rc}    Run And Return Rc    ${cmd1} ${cmd2}
    ${parsed_ntrstr_notif}    Parse Xml    ${resultDir}/celltrace_ntrstr_notif.xml
    ${msg_string_notify}    Element To String    ${parsed_ntrstr_notif}   xpath=.//proto[@showname="NG Application Protocol (HandoverNotify)"]
    ${ntrstr_ho_notify}     Remove Pos And Leading Spaces   ${msg_string_notify}
    Create File    ${resultDir}/ho_notify_ntrstr1.txt         ${ntrstr_ho_notify}
    ${parsed_ngap}   Create Xml File
    ...    wireshark_file=${resultDir}/wireshark_part3.pcap
    ...    filter=${filter_ho_notify}
    ...    xml_file=${resultDir}/ho_notify_ngap.xml
    ${ngap_part}     Ngap Get Format Save String    parsed_string=${parsed_ngap}
    Run Keyword And Continue On Failure   Should Be Equal    ${ntrstr_ho_notify}   ${ngap_part}


    Log To Console    \nverify that ho_failure message is the same in ngap and ntrstr
    Log To Console    preparing ntrstr failure message which contains HandoverRequest and HandoverFailure
    ${cmd1}   Set Variable   tshark -r ${resultDir}/cell_trace_hoFailure/cell_trace_hoFailure.pcap -o ntrstr.port:49151 -Y "${filter_ho_failure}"
    ${cmd2}   Set Variable   -T pdml > ${resultDir}/ho_fail_ntrstr.xml
    ${rc}    Run And Return Rc    ${cmd1} ${cmd2}
    ${parsed_ntrstr}    Parse Xml    ${resultDir}/ho_fail_ntrstr.xml
    ${msg_string_req}         Element To String    ${parsed_ntrstr}     xpath=.//proto[@showname="NG Application Protocol (HandoverRequest)"]
    ${msg_string_fail}        Element To String    ${parsed_ntrstr}     xpath=.//proto[@showname="NG Application Protocol (HandoverFailure)"]
    ${ntrstr_part_req_tmp1}        Remove Pos And Leading Spaces   ${msg_string_req}
    ${ntrstr_part_req_tmp2}    Remove Bad Chars From ngap.SourceToTarget_TransparentContainer    ${ntrstr_part_req_tmp1}
    ${ntrstr_part_req}         Remove Bad Chars From ngap.rRCContainer                           ${ntrstr_part_req_tmp2}

    ${ntrstr_part_fail}       Remove Pos And Leading Spaces   ${msg_string_fail}
    Create File    ${resultDir}/ho_req_ntrstr2.txt           ${ntrstr_part_req}
    Create File    ${resultDir}/ho_fail_ntrstr2.txt          ${ntrstr_part_fail}

    Log To Console    preparing ngap HandoverRequest and HandoverFailure messages
    ${parsed_ngap}   Create Xml File
    ...    wireshark_file=${resultDir}/wireshark_part5.pcap
    ...    filter=${filter_ho_req2}
    ...    xml_file=${resultDir}/ho_req_ngap2.xml
    ${ngap_part_req_tmp1}     Ngap Get Format Save String    parsed_string=${parsed_ngap}
    ${ngap_part_req_tmp2}     Remove Bad Chars From ngap.SourceToTarget_TransparentContainer    ${ngap_part_req_tmp1}
    ${ngap_part_req}      Remove Bad Chars From ngap.rRCContainer                       ${ngap_part_req_tmp2}

    ${parsed_ngap}   Create Xml File
    ...    wireshark_file=${resultDir}/wireshark_part5.pcap
    ...    filter=${filter_ho_failure}
    ...    xml_file=${resultDir}/ho_fail_ngap2.xml
    ${ngap_part_fail}     Ngap Get Format Save String    parsed_string=${parsed_ngap}

    Log To Console    comparing ntrstr and ngap ho request
    Run Keyword And Continue On Failure   Should Be Equal    ${ntrstr_part_req}     ${ngap_part_req}
    Log To Console    comparing ntrstr and ngap ho fail
    Run Keyword And Continue On Failure   Should Be Equal    ${ntrstr_part_fail}    ${ngap_part_fail}

    Log To Console    \nverify behaviour when cell trace not activated
    Log To Console    verify no ntrstr messages present
    ${msg}     Run
    ...   tshark -r ${resultDir}/cell_trace_off/cell_trace_off.pcap -o ntrstr.port:49151 -Y "${filter_ho_req}" 2> ${CURDIR}\err.txt | wc -l
    ${fileSize}  get file size    ${CURDIR}\err.txt
    IF    ${fileSize} > 0   Fail    error in tshark command
    ...         ELSE   Run Keyword And Continue On Failure   Should Be True    ${msg}==${0}
                ...     no ntrstr messages expected, because cell trace not active
    Log To Console    verify 1 handover request message in wireshark
    ${msg}     Run     tshark -r ${resultDir}/wireshark_part6.pcap -Y "${filter_ho_req2}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${1}
    ...     Wrong number of handover request messages in wireshark


Create Xml File
    [Documentation]    [PRIVATE]    Create Xml File
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}    ${filter}    ${xml_file}
    Setup Tshark    eth1
    read_pcap_and_save_to_file
    ...   filename=${xml_file}
    ...   packet_filter=${filter}
    ...   output_type=pdml
    ...   pcap_file_path=${wireshark_file}
    Teardown Tshark
    ${pdml_xml}    Parse Xml    ${xml_file}
    RETURN     ${pdml_xml}


Ngap Get Format Save String
    [Documentation]    [PRIVATE]    get element proto ngap and format and save it
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${parsed_string}
    ${msg_string}    Element To String    ${parsed_string}     xpath=.//proto[@name="ngap"]
    ${msg_all}       Remove Pos And Leading Spaces   ${msg_string}
    RETURN   ${msg_all}


Remove Pos And Leading Spaces
    [Documentation]    [PRIVATE]    remove pos object and leading spaces for later comparison
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${msg_string}

    ${tmp_msg}   remove string using regexp   ${msg_string}   pos="[0-9]*"

    ${msg_all}   Set Variable    ${EMPTY}
    @{lines}  Split To Lines    ${tmp_msg}
    FOR    ${line}  IN    @{lines}
        ${tmp}   Strip String   ${line}   mode=left
        ${msg_all}   Catenate   SEPARATOR=\n   ${msg_all}    ${tmp}
    END
    RETURN   ${msg_all}


Remove Bad Chars From ngap.SourceToTarget_TransparentContainer
    [Documentation]    [PRIVATE]    Remove Bad Chars From ngap.SourceToTarget_TransparentContainer
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${msg_string}

    ${upd_string}   Replace String Using Regexp   ${msg_string}
    ...   field name="ngap.SourceToTarget_TransparentContainer" showname="SourceToTarget-TransparentContainer.*
    ...   field name="ngap.SourceToTarget_TransparentContainer"-UPDATE
    RETURN   ${upd_string}


Remove Bad Chars From ngap.rRCContainer
    [Documentation]    [PRIVATE]    Remove Bad Chars From ngap.rRCContainer
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${msg_string}

    ${upd_string}   Replace String Using Regexp   ${msg_string}
    ...   field name="ngap.rRCContainer" showname="rRCContainer.*
    ...   field name="ngap.rRCContainer"-UPDATE
    RETURN   ${upd_string}


Remove Bad Chars From ngap.TargetToSource_TransparentContainer
    [Documentation]    [PRIVATE]    Remove Bad Chars From ngap.TargetToSource_TransparentContainer
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${msg_string}

    ${upd_string}   Replace String Using Regexp   ${msg_string}
    ...   field name="ngap.TargetToSource_TransparentContainer" showname="TargetToSource-TransparentContainer.*
    ...   field name="ngap.TargetToSource_TransparentContainer"-UPDATE
    RETURN   ${upd_string}
