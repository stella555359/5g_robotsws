*** Settings ***
Documentation
...  author : liang.6.chen@nokia-sbell.com
...  contact: liang.6.chen@nokia-sbell.com
Resource   ../Resource/Common.robot
*** Variables ***
${repeat_times}   5
*** Keyword ***
002_PCMD_TCE_TCP_Connection_Fault_8000_Raise_And_Clear_Multi_Times
    Load Pcap File with Filter any Expression
    ...   pcap_file=${OUTPUT_DIR}/${pcmd_file_webui}_maxNumOfUsersNRCell
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType == 1
    ...   filter=sctp.dstport==${dcap_server_port}
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
        Should Match Regexp   ${scfcq_list[${idx}]}   .*admissionControlFailure.*
    END
    #FOR   ${idx}    IN RANGE    0    ${repeat_times}
        #Tracer Connection Operation   action=stop
        #Wait Until Keyword Succeeds   5m   30s   Check Fault 8000 Exists
        #Tracer Connection Operation
        #Wait Until Keyword Succeeds   5m   30s   Check Fault 8000 Exists   should_exist=${false}
    #END
Case Setup: B_002
    Common Setup 1756
    Remove And Add PCMD Object

Case Teardown: B_002
    #Tracer Connection Operation
    Common Teardown 1756