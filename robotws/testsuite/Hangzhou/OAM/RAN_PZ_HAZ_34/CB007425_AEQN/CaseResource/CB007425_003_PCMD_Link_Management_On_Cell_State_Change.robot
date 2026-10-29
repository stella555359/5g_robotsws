*** Settings ***
Documentation
...  author : liang.6.chen@nokia-sbell.com
...  contact: liang.6.chen@nokia-sbell.com
Resource   ../Resource/Common.robot
Resource   ../../5GC000376/Resource/coam.robot
*** Variables ***
*** Keyword ***
003_PCMD_Link_Management_On_Cell_State_Change
    Load Pcap File with Filter for 1756_B
    ...      pcap_file=${OUTPUT_DIR}/${pcmd_file_webui}_remove_cell
    ...      filter=tcp.dstport==${dcap_server_port}
    ...      TraceMessage=3
    ...      nodeType=2
    Get And Verify Field Value By Xpath
    ...      xpath_first=.//nsetapx.TraceMessage/nsetapx.startSession_element/nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
    ...      exp=${${cellIdentity}}
    ...      cell_num=1
    ...      cell_flag=true
    Load Pcap File with Filter for 1756_B
    ...      pcap_file=${OUTPUT_DIR}/${pcmd_file_webui}_add_cell
    ...      filter=tcp.dstport==${dcap_server_port}
    ...      TraceMessage=2
    ...      nodeType=2
    Get And Verify Field Value By Xpath
    ...      xpath_first=.//nsetapx.TraceMessage/nsetapx.startSession_element/nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
    ...      exp=${${cellIdentity}}
    ...      cell_num=1
    ...      cell_flag=true
    Load Pcap File with Filter for 1756_B
    ...      pcap_file=${OUTPUT_DIR}/${pcmd_file_webui}_block_cell
    ...      filter=tcp.dstport==${dcap_server_port}
    ...      TraceMessage=3
    ...      nodeType=2
    Get And Verify Field Value By Xpath
    ...      xpath_first=.//nsetapx.TraceMessage/nsetapx.startSession_element/nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
    ...      exp=${${cellIdentity}}
    ...      cell_num=${cell_numbers}
    ...      cell_flag=true
    Load Pcap File with Filter for 1756_B
    ...      pcap_file=${OUTPUT_DIR}/${pcmd_file_webui}_unb2lock_cell
    ...      filter=tcp.dstport==${dcap_server_port}
    ...      TraceMessage=2
    ...      nodeType=2
    Get And Verify Field Value By Xpath
    ...      xpath_first=.//nsetapx.TraceMessage/nsetapx.startSession_element/nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
    ...      exp=${${cellIdentity}}
    ...      cell_num=${cell_numbers}
    ...      cell_flag=true
Case Setup: B_003
    Common Setup 1756
    Remove And Add PCMD Object
Case Teardown: B_003
    Common Teardown 1756