*** Settings ***
Documentation
...    author: lihong
...    this case will verify keyword for TA of CB007227-SR-C_varify_content_of_PCMD_measurements_for_U-Plane_DU_RLC_layer_DL_IP_Latency

#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot

*** Variables ***


*** Keywords ***
CB007227-SR-C_varify_content_of_PCMD_measurements_for_U-Plane_DU_RLC_layer_DL_IP_Latency

    log to console     check elemnet  CB007227-SR-C_varify_content_of_PCMD_measurements_for_U-Plane_DU_RLC_layer_DL_IP_Latency

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${OUTPUT_DIR}/${source_VDU_OCP_file}
     ...                        any_expression=nsetapx.DuVendorExtensionRecordDataType == 6
     ...                        filter=sctp.dstport==49148

    ${dlRbRlcMeasRecord_avgIpLatency}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.avgIpLatency_element   attribute_name=showname
    ${dlRbRlcMeasRecord_sumOfDelays}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.avgIpLatency_element/nsetapx.sumOfDelays
    ${dlRbRlcMeasRecord_numOfRlcSdus}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.avgIpLatency_element/nsetapx.numOfRlcSdus

    ${dlRbRlcMeasRecord_drb_Id}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.DlRadioBearerRlcMeasData_element/nsetapx.drb_Id

    ${drb_Id_length}   Get Length  ${dlRbRlcMeasRecord_drb_Id}
    ${avgIpLatency_length}   Get Length  ${dlRbRlcMeasRecord_avgIpLatency}
    ${sumOfDelays_length}   Get Length  ${dlRbRlcMeasRecord_sumOfDelays}
    ${numOfRlcSdus_length}   Get Length  ${dlRbRlcMeasRecord_numOfRlcSdus}
    Should Contain Match   ${dlRbRlcMeasRecord_avgIpLatency}   regexp=.*avgIpLatency.*
    should not be empty   ${dlRbRlcMeasRecord_sumOfDelays}
    should not be empty   ${dlRbRlcMeasRecord_sumOfDelays}
    Should Be True   ${drb_Id_length}==${avgIpLatency_length}==${sumOfDelays_length}==${numOfRlcSdus_length}


Case Setup: CB007227-SR-C_varify_content_of_PCMD_measurements_for_U-Plane_DU_RLC_layer_DL_IP_Latency
    Log To Console   Case Setup: CB007227-SR-C_varify_content_of_PCMD_measurements_for_U-Plane_DU_RLC_layer_DL_IP_Latency
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

Case Teardown: CB007227-SR-C_varify_content_of_PCMD_measurements_for_U-Plane_DU_RLC_layer_DL_IP_Latency
    Log To Console   CB007227-SR-C_varify_content_of_PCMD_measurements_for_U-Plane_DU_RLC_layer_DL_IP_Latency
#    Detach UE BETA
#    Common Teardown 1756

