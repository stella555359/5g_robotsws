*** Settings ***
Documentation
...   Author: Jing.Qu@nokia-sbell.com

#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot

*** Variables ***

*** Keyword ***
CB009444_CB008208_gNBCubearerRecord_for_NSA_intra_en_gNB_inter_DU_mobility
#B104, target cell
    FOR   ${item}   IN   @{NSA_INTRA_target_crnti_HO_list}
        log to console   check BearerRecord
        Load Pcap File with Filter any Expression
            ...   pcap_file=${NSA_INTRA_gNB_HO_PATH}
            ...   any_expression=nsetapx.setupBearers == 1 && nsetapx.crnti == ${item} && nsetapx.cellIdentity == ${target_cell_identity_filter}
            ...   filter=tcp.dstport==${dcap_server_port}

        ${common_path}   set variable   .//nsetapx.bearerRecord/nsetapx.data_element/nsetapx.setupBearers//nsetapx.CuBearerSetupItem_element

        ${drbId}   wireshark.get_field_value_by_xpath
        ...   xpath=${common_path}/nsetapx.drb_Id

        ${erabId}   wireshark.get_field_value_by_xpath
        ...   xpath=${common_path}/nsetapx.erabId

        ${qci}   wireshark.get_field_value_by_xpath
        ...   xpath=${common_path}/nsetapx.eutran_Qos_element/nsetapx.qci

        ${priorityLevel}   wireshark.get_field_value_by_xpath
        ...   xpath=${common_path}/nsetapx.eutran_Qos_element/nsetapx.arp_element/nsetapx.priorityLevel

        ${preemptionCapability}   wireshark.get_field_value_by_xpath
        ...   xpath=${common_path}/nsetapx.eutran_Qos_element/nsetapx.arp_element/nsetapx.preemptionCapability

        ${preemptionVulnerability}   wireshark.get_field_value_by_xpath
        ...   xpath=${common_path}/nsetapx.eutran_Qos_element/nsetapx.arp_element/nsetapx.preemptionVulnerability

        ${triggerReason}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.bearerRecord/nsetapx.data_element/nsetapx.trigger
        ...   attribute_name=showname

        log to console   info in SgNBAdditionReguest
        Load Pcap File with Filter any Expression
            ...   pcap_file=${NSA_INTRA_gNB_HO_PATH}
            ...   any_expression=x2ap.procedureCode == 27 && x2ap.id == 205
            ...   filter=tcp.dstport==36422

        ${SgNBAddRe_path1}   set variable   .//x2ap.X2AP_PDU/x2ap.initiatingMessage_element/x2ap.value_element/x2ap.SgNBAdditionRequest_element//
        ${SgNBAddRe_path2}   set variable   x2ap.ProtocolIE_Field_element/x2ap.value_element/x2ap.E_RABs_ToBeAdded_SgNBAddReqList//
        ${SgNBAddRe_path3}   set variable   x2ap.ProtocolIE_Single_Container_element/x2ap.value_element/x2ap.E_RABs_ToBeAdded_SgNBAddReq_Item_element
        ${SgNBAddRe_path}   set variable   ${SgNBAddRe_path1}${SgNBAddRe_path2}${SgNBAddRe_path3}

        ${erabId_SgNB}   wireshark.get_field_value_by_xpath
        ...   xpath=${SgNBAddRe_path}/x2ap.e_RAB_ID

        ${drbId_SgNB}   wireshark.get_field_value_by_xpath
        ...   xpath=${SgNBAddRe_path}/x2ap.drb_ID

        ${qci_SgNB}   wireshark.get_field_value_by_xpath
        ...   xpath=${SgNBAddRe_path}/x2ap.resource_configuration/x2ap.sgNBPDCPpresent_element/x2ap.full_E_RAB_Level_QoS_Parameters_element/x2ap.qCI

        ${preemption_path1}   set variable  /x2ap.resource_configuration/x2ap.sgNBPDCPpresent_element/x2ap.full_E_RAB_Level_QoS_Parameters_element/
        ${preemption_path2}   set variable  x2ap.allocationAndRetentionPriority_element

        ${priorityLevel_SgNB}   wireshark.get_field_value_by_xpath
        ...   xpath=${SgNBAddRe_path}${preemption_path1}${preemption_path2}/x2ap.priorityLevel

        ${preemptionCapability_SgNB}   wireshark.get_field_value_by_xpath
        ...   xpath=${SgNBAddRe_path}${preemption_path1}${preemption_path2}/x2ap.pre_emptionCapability

        ${preemptionVulnerability_SgNB}   wireshark.get_field_value_by_xpath
        ...   xpath=${SgNBAddRe_path}${preemption_path1}${preemption_path2}/x2ap.pre_emptionVulnerability

        log to console   check drbId and erabId
        run keyword if   ${drbId[0]}>32 or ${drbId[0]}<1 or ${erabId[0]}>15 or ${erabId[0]}<0   Fail   msg=drbId or erabId is not in range scope

        list should contain sub list  ${erabId_SgNB}   ${erabId}
        list should contain sub list  ${drbId_SgNB}   ${drbId}

        log to console   check eutranQoS
        should not be empty   ${qci}
        should not be empty   ${priorityLevel}
        should not be empty   ${preemptionCapability}
        should not be empty   ${preemptionVulnerability}
        list should contain sub list  ${qci_SgNB}   ${qci}
        list should contain sub list  ${priorityLevel_SgNB}   ${priorityLevel}
        list should contain sub list  ${preemptionCapability_SgNB}   ${preemptionCapability}
        list should contain sub list  ${preemptionVulnerability_SgNB}   ${preemptionVulnerability}

        log to console   check Trigger Reason
        Should Contain Match   ${triggerReason}   regexp=.*intragNBHandover.*
    END

Get drbId erabId and eutranQoS from Tcpdump
    [Arguments]  ${file}   ${fileter_expression}   ${bearer_info}
    Load Pcap File with Filter any Expression
            ...   pcap_file=${file}
            ...   any_expression=${fileter_expression}
            ...   filter=tcp.dstport==${dcap_server_port}

        ${drbId}   wireshark.get_field_value_by_xpath
        ...   xpath=.//${bearer_info}/nsetapx.drb_Id

        ${erabId}   wireshark.get_field_value_by_xpath
        ...   xpath=.//${bearer_info}/nsetapx.erabId

        ${eutranQoS}   wireshark.get_field_value_by_xpath
        ...   xpath=.//${bearer_info}/nsetapx.eutran_Qos_element/nsetapx.qci
    [Return]  ${drbId}   ${erabId}   ${eutranQoS}

