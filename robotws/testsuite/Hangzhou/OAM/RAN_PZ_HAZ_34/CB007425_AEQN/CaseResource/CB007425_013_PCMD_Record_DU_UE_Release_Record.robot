*** Settings ***
Documentation
...  author : liang.6.chen@nokia-sbell.com
...  contact: liang.6.chen@nokia-sbell.com

Resource   ../Resource/Common.robot
Resource   ../Resource/Common_wireshark_xpath.robot

*** Variables ***

*** Keyword ***
013_PCMD_Record_DU_UE_Release_Record
    Load Pcap File with Filter any Expression
    ...   pcap_file=${OUTPUT_DIR}/${pcmd_file_webui}
    ...   any_expression=nsetapx.DuVendorExtensionRecordDataType == 2
    ...   filter=sctp.dstport==${dcap_server_port}
    ${crnti_list}   Get Nsetapx Crnti
    ${cfc_list}    Get Nsetapx CFC
    ${cfcq_list}   Get Nsetapx CFCQ
    ${scfcq_list}   Get Nsetapx SCFCQ
    ${crnti_list}   Remove Duplicates   ${crnti_list}
    ${crnti_length}    Get Length   ${crnti_list}
    ${seconds_list}    Get Nsetapx Seconds
    ${useconds_list}   Get Nsetapx Useconds 
    Check Seconds    ${seconds_list}
    Check Useconds   ${useconds_list}
    Should Be True   ${crnti_length}>0    
    FOR   ${idx}    IN RANGE    0   ${crnti_length}
        Should Match Regexp   ${cfc_list[${idx}]}   .*normal.*
        Should Match Regexp   ${cfcq_list[${idx}]}   .*none.*
        Should Match Regexp   ${scfcq_list[${idx}]}   .*none.*
    END
Case Setup: CB007425_013
    Log To Console   Case Setup: CB007425_013
Case Teardown: CB007425_013
    Log To Console   Case Teardown: CB007425_013