*** Settings ***
Documentation
...  author : liang.6.chen@nokia-sbell.com
...  contact: liang.6.chen@nokia-sbell.com

Resource   ../Resource/Common.robot
Resource   ../Resource/Common_wireshark_xpath.robot

*** Variables ***

*** Keyword ***
014_PCMD_Record_CU_UE_Release_Record
    Load Pcap File with Filter any Expression
    ...   pcap_file=${OUTPUT_DIR}/${pcmd_file_webui}_nsaInactivityTimer
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType == 1
    ...   filter=sctp.dstport==${dcap_server_port}
    ${crnti_list}   Get Nsetapx Crnti
    ${cfc_list}    Get Nsetapx CFC
    ${cfcq_list}   Get Nsetapx CFCQ
    ${scfcq_list}   Get Nsetapx SCFCQ
    ${seconds_list}    Get Nsetapx Seconds
    ${useconds_list}   Get Nsetapx Useconds    
    Check Seconds    ${seconds_list}
    Check Useconds   ${useconds_list} 
    FOR   ${idx}    IN RANGE    0   1
        Should Match Regexp   ${cfc_list[${idx}]}   .*normal.*
        Should Match Regexp   ${cfcq_list[${idx}]}   .*sgnbInitiated.*
        Should Match Regexp   ${scfcq_list[${idx}]}   .*internal.*
    END
Case Setup: CB007425_014
    Log To Console   Case Setup: CB007425_014
Case Teardown: CB007425_014
    Log To Console   Case Teardown: CB007425_014