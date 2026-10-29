*** Settings ***
Documentation
...    author: lihong
...    this case will verify keyword for TA of CB007227-SR-F_varify_content_of_PCMD_measurements_for_RLC_layer_UL

#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot

*** Variables ***


*** Keywords ***
CB007227-SR-F_varify_content_of_PCMD_measurements_for_RLC_layer_UL

# log to console     check elemnet  for CUUP Records:ulRbPdcpMeasRecord and dlRbPdcpMeasRecord

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${OUTPUT_DIR}/${source_VDU_OCP_file}
     ...                        any_expression=nsetapx.DuVendorExtensionRecordDataType == 17
     ...                        filter=sctp.dstport==49148
    ${xpath_ul_P1}   set variable   .//nsetapx.ulRbRlcThroughputRecord/nsetapx.data_element/nsetapx.rbData
    ${xpath_ul}   set variable   ${xpath_ul_P1}//nsetapx.DuUlRadioBearerRlcThroughputData_element
    
    ${ulRbRlcThroughput_endmark}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ul}/nsetapx.endMarker
    ${ulRbRlcThroughput_drbid}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ul}/nsetapx.drb_Id
    ${ulRbRlcThroughput_dataCollectionDuration}=     wireshark.get_field_value_by_xpath   xpath=${xpath_ul}/nsetapx.dataCollectionDuration
    ${ulRbRlcThroughput_timeOfUeDataBurstRx}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_ul}/nsetapx.timeOfUeDataBurstRx
    ${ulRbRlcThroughput_sumOfRlcSduRxDataBurstBytes}=     wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_ul}/nsetapx.sumOfRlcSduRxDataBurstBytes

    ${ulRbRlcThroughput_length}   Get Length  ${ulRbRlcThroughput_endmark}
    FOR  ${idx}  IN RANGE  0   ${ulRbRlcThroughput_length}
         Should Be True   0<${ulRbRlcThroughput_drbid}[${idx}]<33
         Should Be True   0<${ulRbRlcThroughput_dataCollectionDuration}[${idx}]<134273
         Should Be True   0<=${ulRbRlcThroughput_sumOfRlcSduRxDataBurstBytes}[${idx}]<114395448
         Should Be True   0<=${ulRbRlcThroughput_timeOfUeDataBurstRx}[${idx}]<1074176
         Should Be True   '${ulRbRlcThroughput_endmark}[${idx}]'=='0' or '${ulRbRlcThroughput_endmark}[${idx}]'=='1'
    END



Case Setup: CB007227-SR-B
    Log To Console   Case Setup: CB007227-SR-B
#    Common Setup 1756
#    Remove And Add PCMD Object
#
#    Start Tcpdump To Get PCMD   pcmd_file=EA_21.pcap
#    L3CALL Precondition
#    Wait Until Keyword Succeeds   3x   10s   Attach UE BETA
#
#    Sleep   30s
#    Stop Tcpdump To Get PCMD   pcmd_file=EA_21.pcap
#    Detach UE BETA

Case Teardown: CB007227-SR-B
    Log To Console   Case Teardown: CB007227-SR-B
#    Detach UE BETA
#    Common Teardown 1756
