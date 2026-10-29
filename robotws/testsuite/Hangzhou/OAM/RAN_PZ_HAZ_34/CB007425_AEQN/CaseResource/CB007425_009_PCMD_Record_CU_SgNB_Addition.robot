*** Settings ***
Documentation
...  author : liang.6.chen@nokia-sbell.com
...  contact: liang.6.chen@nokia-sbell.com
Resource   ../Resource/Common.robot
Resource   ../Resource/Common_wireshark_xpath.robot
*** Variables ***

*** Keyword ***
009_PCMD_Record_CU_SgNB_Addition
    log to console   check NSA_SgNBAdditionTraceRecord_normal_call_scenario
    &{eNB_info}   Get eNB Variables
    Load Pcap File with Filter any Expression
    ...   pcap_file=${OUTPUT_DIR}/${pcmd_file_webui}
    ...   any_expression=x2ap.procedureCode == 27&&ip.dst == ${eNB_info}[ip]
    ...   filter=sctp.dstport==36422
    ${x2ap_menbUeX2APId}   Get X2AP MenbUeX2APId
    ${x2ap_sgnbUeX2APId}   Get X2AP SgnbUeX2APId
    Load Pcap File with Filter any Expression
    ...   pcap_file=${OUTPUT_DIR}/${pcmd_file_webui}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType == 1
    ...   filter=sctp.dstport==${dcap_server_port}
    ${trigger_list}   Get Nsetapx Trigger
    ${result_list}    Get Nsetapx Result
    ${enbid_list}    Get Nsetapx Enbid Element
    ${enbplmn_list}    Get Nsetapx Enb Plmn
    ${enbmacro_list}   Get Nsetapx Enbid
    ${enbmacroId}    Get Nsetapx Macro Enbid
    ${menbUeX2APId}   Get Nsetapx MenbUeX2APId
    ${sgnbUeX2APId}   Get Nsetapx SgnbUeX2APId
    ${CuReqRcvTimeS}    Get Nsetapx CuReqRcvTimeS
    ${CuReqRcvTimeUS}   Get Nsetapx CuReqRcvTimeUS
    ${CuReqAckSndTimeS}    Get Nsetapx CuReqAckSndTimeS
    ${CuReqAckSndTimeUS}   Get Nsetapx CuReqAckSndTimeUS
    ${ReconfCmplRcvS}    Get Nsetapx ReconfCmplRcvS
    ${ReconfCmplRcvUS}   Get Nsetapx ReconfCmplRcvUS
    ${snStatusTransferRcvS}    Get Nsetapx snStatusTransferRcvS
    ${snStatusTransferRcvUS}   Get Nsetapx snStatusTransferRcvUS
    ${crnti_list}   Get Nsetapx Crnti
    ${crnti_list}   Remove Duplicates   ${crnti_list}
    ${crnti_length}    Get Length   ${crnti_list}
    ${seconds_list}    Get Nsetapx Seconds
    ${useconds_list}   Get Nsetapx Useconds    
    Check Seconds    ${seconds_list}
    Check Useconds   ${useconds_list}
    Should Be True   ${menbUeX2APId} == ${x2ap_menbUeX2APId}
    Should Be True   ${sgnbUeX2APId} == ${x2ap_sgnbUeX2APId}
    Should Be True   ${crnti_length}>0    
    FOR   ${idx}    IN RANGE    0   ${crnti_length}
        Should Match Regexp   ${trigger_list[${idx}]}   .*initialNsaCall.*
        Should Match Regexp   ${result_list[${idx}]}   .*success.*
        Should Match Regexp   ${enbid_list[${idx}]}   .*enb-Id.*
        ${globaleNBId_info}   Should Match Regexp   ${enbmacroId[${idx}]}   value.*
        ${globaleNBId}   Should Match Regexp   ${globaleNBId_info}   \\d+
        should be equal   ${eNB_info}[globaleNBId]   ${${globaleNBId}}
        ${plman_clear}   Remove String   ${enbplmn_list}[${idx}]   :
        Should Be True   '${plman_clear}' == '${PLMN_IDENTITY}'
        should not be empty   ${CuReqRcvTimeS[${idx}]}
        should not be empty   ${CuReqRcvTimeUS[${idx}]}
        should not be empty   ${CuReqAckSndTimeS[${idx}]}
        should not be empty   ${CuReqAckSndTimeUS[${idx}]}
        should not be empty   ${ReconfCmplRcvS[${idx}]}
        should not be empty   ${ReconfCmplRcvUS[${idx}]}
        should not be empty   ${snStatusTransferRcvS[${idx}]}
        should not be empty   ${snStatusTransferRcvUS[${idx}]}
    END
Case Setup: CB007425_009
    Log To Console   Case Setup: CB007425_009
Case Teardown: CB007425_009
    Log To Console   Case Teardown: CB007425_009
