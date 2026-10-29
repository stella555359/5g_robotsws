*** Settings ***
Documentation
...    author: lihong
...    this case will verify keyword for CB007227-SR-B_PCMD_measurements for CUUP Records:ulRbPdcpMeasRecord and dlRbPdcpMeasRecord

#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot

*** Variables ***


*** Keywords ***
CB007227-SR-B_PCMD_measurements_for_U-Plane_CU-UP_PDCP_layer_report_content_verify

    log to console     check elemnet  for CUUP Records:ulRbPdcpMeasRecord and dlRbPdcpMeasRecord

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${OUTPUT_DIR}/${source_VCU_OAMAGENT_file}
     ...                        any_expression=nsetapx.CuUpVendorExtensionRecordDataType == 3
     ...                        filter=sctp.dstport==49148
    ${xpath_ul}   set variable   .//nsetapx.ulRbPdcpMeasRecord/nsetapx.data_element/nsetapx.rbData//nsetapx.CuUpUlRadioBearerPdcpMeasData_element
    ${ulpdcpm_endmark}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ul}/nsetapx.endMarker
    ${ulpdcpm_drbid}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ul}/nsetapx.drb_Id
    ${ulpdcpm_dataCollectionDuration}=     wireshark.get_field_value_by_xpath   xpath=${xpath_ul}/nsetapx.dataCollectionDuration
    ${ulpdcpm_sumOfPdcpSduRxBytes}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_ul}/nsetapx.sumOfPdcpSduRxBytes
    ${ulpdcpm_sumOfPdcpSduRxBytesDiscarded}=     wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_ul}/nsetapx.sumOfPdcpSduRxBytesDiscarded


     Load Pcap File with Filter any Expression
     ...                        pcap_file=${OUTPUT_DIR}/${source_VCU_OAMAGENT_file}
     ...                        any_expression=nsetapx.CuUpVendorExtensionRecordDataType == 4
     ...                        filter=sctp.dstport==49148
    ${xpath_dl}   set variable   .//nsetapx.dlRbPdcpMeasRecord/nsetapx.data_element/nsetapx.rbData//nsetapx.CuUpDlRadioBearerPdcpMeasData_element
    ${dlpdcpm_endmark}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dl}/nsetapx.endMarker
#    nsetapx.endMarker nsetapx.drb_Id nsetapx.dataCollectionDuration nsetapx.sumOfPdcpSduTxBytes nsetapx.sumOfPdcpSduTxBytesDiscarded
    ${dlpdcpm_drbid}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dl}/nsetapx.drb_Id
    ${dlpdcpm_dataCollectionDuration}=     wireshark.get_field_value_by_xpath   xpath=${xpath_dl}/nsetapx.dataCollectionDuration
    ${dlpdcpm_sumOfPdcpSduTxBytes}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_dl}/nsetapx.sumOfPdcpSduTxBytes
    ${dlpdcpm_sumOfPdcpSduTxBytesDiscarded}=     wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_dl}/nsetapx.sumOfPdcpSduTxBytesDiscarded

    ${ulpdcpm_length}   Get Length  ${ulpdcpm_endmark}
    FOR  ${idx}  IN RANGE  0   ${ulpdcpm_length}
         Should Be True   0<${ulpdcpm_drbid}[${idx}]<33
         Should Be True   0<${dlpdcpm_drbid}[${idx}]<33
         Should Be True   0<${ulpdcpm_dataCollectionDuration}[${idx}]<134273
         Should Be True   0<${dlpdcpm_dataCollectionDuration}[${idx}]<134273
         Should Be True   0<=${ulpdcpm_sumOfPdcpSduRxBytes}[${idx}]<114395448
         Should Be True   0<=${dlpdcpm_sumOfPdcpSduTxBytes}[${idx}]<688766189
         Should Be True   '${ulpdcpm_endmark}[${idx}]'=='0' or '${ulpdcpm_endmark}[${idx}]'=='1'
         Should Be True   '${dlpdcpm_endmark}[${idx}]'=='0' or '${dlpdcpm_endmark}[${idx}]'=='1'
    END
    Should Not Be Empty   ${ulpdcpm_sumOfPdcpSduRxBytesDiscarded}
    Should Not Be Empty   ${dlpdcpm_sumOfPdcpSduTxBytesDiscarded}


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
