*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
EA_21_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record
    log to console     check elemnet  PDU_Session_Info_Record_for_trigger: initialCtxSetup (1)
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${TCPDUMP_PATH}
     ...                          any_expression=nsetapx.CuVendorExtensionRecordDataType == 13
     ...                        filter=sctp.dstport==${dcap_server_port}
#    ${ran-ue-ngap-Id_list_m}=    wireshark.get_field_value_by_xpath
#    ...   xpath=.//nsetapx.ueSetupRecord/nsetapx.data_element/nsetapx.ran_ue_ngap_Id
#    ${ran-ue-ngap-Id_Id_list}   Remove Duplicates   ${ran-ue-ngap-Id_list_m}
    ${crnti_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.crnti
    ${crnti_single_list}   Remove Duplicates   ${crnti_list}
    ${ran-ue-ngap-Id_Id_list}   Create List
    FOR   ${item}   IN   @{crnti_single_list}
        Load Pcap File with Filter any Expression
        ...                        pcap_file=${TCPDUMP_PATH}
        ...                        any_expression=nsetapx.CuVendorExtensionRecordDataType == 13 && nsetapx.crnti == ${item}
        ...                        filter=sctp.dstport==${dcap_server_port}
        ${ran-ue-ngap-Id_list_m}    wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.ueSetupRecord/nsetapx.data_element/nsetapx.ran_ue_ngap_Id
#        ${status}   run keyword and return status   Length Should Be   ${ran-ue-ngap-Id_list_m}   ${2}
        ${length}   Get Length   ${ran-ue-ngap-Id_list_m}
        ${status1}   set variable if   ${length}>${2}   ${True}   ${False}
        ${status2}   run keyword if   ${length}==${2}   run keyword and return status   should be equal
        ...   ${ran-ue-ngap-Id_list_m[0]}   ${ran-ue-ngap-Id_list_m[1]}
        run keyword if   ${status1} or ${status2}   Append To List   ${ran-ue-ngap-Id_Id_list}   ${ran-ue-ngap-Id_list_m}[0]
        ...   ELSE   Remove Values From List   ${crnti_single_list}   ${item}
    END
    ${crnti_single_length}=  Get Length   ${crnti_single_list}

    Load Pcap File with Filter any Expression
    ...                        pcap_file=${TCPDUMP_PATH}
    ...                        any_expression=nsetapx.CuVendorExtensionRecordDataType == 13
    ...                        filter=sctp.dstport==${dcap_server_port}

    FOR   ${idx}    IN RANGE    0   ${crnti_single_length}
        ${ngap_PDU_list}    ${ngap_pdusetup_list}   ${ngap_pdusetup_success_list}
        ...   Get PDU Item Lists from Ngap   ${TCPDUMP_PATH}   InitialContext   ${ran-ue-ngap-Id_Id_list}[${idx}]
        ${Record_PDU_list}   ${PDUSetup_Items_list}
        ...   Get PDU Item Lists from PDUsession Record   ${TCPDUMP_PATH}   InitialContext   ${crnti_single_list}[${idx}]
        Should Be True   ${ngap_pdusetup_list} == ${PDUSetup_Items_list}
        Should Be True   ${Record_PDU_list[0][0]} == 1
        run keyword if   ${ngap_pdusetup_success_list}   Should Be True   ${Record_PDU_list[1][0]} == 0
        ...   ELSE    Should Be True   ${Record_PDU_list[1][0]} == 1
        run keyword if   ${ngap_pdusetup_list}[0]>1   Should Be True   ${ngap_PDU_list}[1] == ${Record_PDU_list}[3]
        run keyword if   ${ngap_pdusetup_list}[0]>0   Should Be True   ${ngap_PDU_list}[0] == ${Record_PDU_list}[2]
        ...   ELSE    FAIL
    END
    Log To Console   check value is OK

Case Setup: EA_21
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: EA_21

Case Teardown: EA_21
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: EA_21
    Check Extra Reset From Blackbox on Teardown   Reset_before=${RESET_REASON}
