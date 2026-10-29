*** Settings ***
Documentation
...    author: jqu003
...    this case will verify keyword for TA of CB008208

#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot
#Library     ../Library/list_time_check.py

*** Variables ***


*** Keywords ***
CB008208-5G-A-15_Classical_gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Release
    log to console     check elemnet  gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Release
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${TCPDUMP_PATH}
     ...                        any_expression=nsetapx.CuVendorExtensionRecordDataType == 10&&nsetapx.releasedBearers == 1
     ...                        filter=sctp.dstport==${dcap_server_port}
    ${common_path}   set variable   .//nsetapx.CuVendorExtensionRecordDataType/nsetapx.bearerRecord/nsetapx.data_r1_element
    ${common_path2}   set variable     ${common_path}/nsetapx.releasedBearers//nsetapx.CuBearerDataReleaseItem/nsetapx.ngranBearer_element
    ${bearerrelease_trigger_list}   wireshark.get_field_value_by_xpath   xpath=${common_path}/nsetapx.trigger
    ${bearerreleaseitems_list}   wireshark.get_field_value_by_xpath   xpath=${common_path}/nsetapx.releasedBearers
    ${bearerreleasedrbId_list}   wireshark.get_field_value_by_xpath
    ...   xpath=${common_path2}/nsetapx.drb_Id
    ${bearerrelease_pducessionId_list}   wireshark.get_field_value_by_xpath
    ...   xpath=${common_path2}/nsetapx.pduSessionId
    ${crnti_list}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.crnti
    ${crnti_HO_list}   Remove Duplicates   ${crnti_list}
    ${crnti_HO_length}=     Get Length   ${crnti_HO_list}

    Load Pcap File with Filter any Expression
        ...   pcap_file=${TCPDUMP_PATH}
        ...   any_expression=nsetapx.CuVendorExtensionRecordDataType == 14 && nsetapx.trigger == 5
        ...   filter=tcp.dstport==${dcap_server_port}
    ${pduSessionId_release_items}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.releasedPduSessionResources
    ${pduSessionId_release}   wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.releasedPduSessionResources//nsetapx.PduSessionResourceReleaseItem_element/nsetapx.pduSessionId

    Should Be True   ${bearerreleaseitems_list} == ${pduSessionId_release_items}
    Should Be True   ${bearerrelease_pducessionId_list} == ${pduSessionId_release}
    Should Contain X Times   ${bearerrelease_trigger_list}   0   ${crnti_HO_length}
    Length Should Be   ${bearerreleasedrbId_list}   ${crnti_HO_length}
Case Setup: CB008208-5G-A-21
    Log To Console   Case Setup: CB009881-CB008208-5G-A-15


Case Teardown: CB008208-5G-A-21
    Log To Console   Case Teardown: CB009881-CB008208-5G-A-15


