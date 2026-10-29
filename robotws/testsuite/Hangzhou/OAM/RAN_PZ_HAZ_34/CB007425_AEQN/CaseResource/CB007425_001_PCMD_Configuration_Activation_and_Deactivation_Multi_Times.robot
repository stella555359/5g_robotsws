*** Settings ***
Documentation
...  author : liang.6.chen@nokia-sbell.com
...  contact: liang.6.chen@nokia-sbell.com
Resource   ../Resource/Common.robot
*** Variables ***
${repeat_times}   20
*** Keyword ***
001_PCMD_Configuration_Activation_and_Deactivation_Multi_Times
    COAM Update PCMD Flag    false
    FOR   ${idx}    IN RANGE    0    ${repeat_times}
		    Start Tcpdump To Get PCMD   pcmd_file=${pcmd_file_webui}
		    COAM Update PCMD Flag    true
		    Sleep   10s
		    COAM Update PCMD Flag    false
		    Sleep   10s
		    Stop Tcpdump To Get PCMD    pcmd_file=${pcmd_file_webui}
		    Load Pcap File with Filter for 1756_B
		    ...      pcap_file=${OUTPUT_DIR}/${pcmd_file_webui}
		    ...      filter=tcp.dstport==${dcap_server_port}
		    ...      TraceMessage=2
		    ...      nodeType=2
		    Get And Verify Field Value By Xpath
		    ...      xpath_fir=.//nsetapx.TraceMessage/nsetapx.startSession_element/nsetapx.nodeType/
		    ...      xpath_sec=nsetapx.gnb_cu_Id_element/nsetapx.plmn_Identity
		    ...      exp=${plmn_Identity}
		    Get And Verify Field Value By Xpath
		    ...      xpath_fir=.//nsetapx.TraceMessage/nsetapx.startSession_element/nsetapx.cellId/
        ...      xpath_sec=nsetapx.nrcgi_element/nsetapx.cellIdentity
		    ...      exp=${cellIdentity}
		    #...      cell_num=${cell_numbers}
		    ...      cell_flag=true
		    Get And Verify Field Value By Xpath
		    ...      xpath_fir=.//nsetapx.TraceMessage/nsetapx.startSession_element/
        ...      xpath_sec=nsetapx.traceReference_element/nsetapx.traceId
		    ...      exp=${traceId}
    END
Case Setup: B_001
    Common Setup 1756
    Remove And Add PCMD Object
Case Teardown: B_001
    Common Teardown 1756