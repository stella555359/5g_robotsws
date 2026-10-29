*** Settings ***
Documentation
...   author: keli.weng
...   contact: keli.weng@nokia-sbell.com
...   Description: this is a robot case about CB008126-CR B2.

# Resource           ../Resources/vran_resource.robot
# Suite Setup       Common Suite Setup For AIC
# # Test Setup        Common Test Setup For AIC
# Test Setup        Run Keywords    Common Test Setup For AIC    AND
# ...     AIC Case Setup    airphone_config_tag=SA_Cloud_DC
# ...    base_path=${CURDIR}/Airphone
# Test Teardown     Common Test Teardown For AIC
# Suite Teardown    Common Suite Teardown For AIC
# Force Tags        CRT/CIT/CDRT     #Tag Item
# ...      RAN_5G                    #Product [RAN_5G]
# # ...      CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
# ...      SBTS00           # it is for auto trigger by ute cloud with the release
# ...      RAN_PZ_HAZ_1             #Competence Area
# ...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
# ...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


# Test Timeout    30 minutes

# *** Variables ***
# @{Ohter_Allow_Alarms}
# *** Test Cases ***
# CB008126-CR-A-B2 Cloud successful TNL modification
#     Online Modify vCU Parametrs For Enable CB008126
#     Log To Console    ${\n}Start to test...${\n}
#     Start Wireshark Log In vCU   gnb_index=${0}
#     ...                          container_name=nwmgmt
#     ...                          pod_name=cpif
#     ...                          timeout=${10}
#     ...                          protocol=sctp
#     ...                          interface=any
#     sleep   15s
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Attach is done. =============${\n}
#     Airphone Start Traffic    mbps=5m    dir=dl
#     Log To Console      ${\n}============= DL traffic is started. =============${\n}
#     Airphone Start Traffic    mbps=5m    dir=ul
#     Log To Console      ${\n}============= UL traffic is started. =============${\n}
#     Sleep    10s
#     ${Courrent_Tput}    Airphone Get Average Throughput
#     Log To Console    ${Courrent_Tput}
#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    switch_ul_tunnel_endpoint=ip_teid by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     ${Courrent_Tput}    Airphone Get Average Throughput
#     Log To Console    ${Courrent_Tput}
#     sleep    10s
#     ${wireshark_local_file_path_1}    Stop Wireshark Log And Download To K8s Master In vCU   gnb_index=${0}
#     ...    container_name=nwmgmt
#     ...    pod_name=cpif
#     ...    timeout=${10}
#     ...    log_name=test_tcpdump
#     Check E1AP PDUSESSIONMODIFYREQUEST In Wireshark Log    ${wireshark_local_file_path_1}
#     Check PDURESOURCEMODIFYSUCCESSRESPONSE In Wireshark Log    ${wireshark_local_file_path_1}


# *** Keywords ***
# Online Modify vCU Parametrs For Enable CB008126
#     [Documentation]    Enable 5QI, UL TNL tunnel IP modification function
#     @{para_list}   Create List   act5qiAndUlNguTnlQosFlowMod
#     @{value_list}   Create List   true
#     @{mo_list}   Create List   MRBTS-1/NRBTS-1
#     ${out}   Parameter Operation    operation=parameter_update   product_type=vcu   para_list=${para_list}
#     ...      value_list=${value_list}   mo_list=${mo_list}
#     Log To Console    paramter update result: ${out}

# Online Modify vCU Parametrs For Disable CB008126
#     [Documentation]    Disable 5QI, UL TNL tunnel IP modification function
#     @{para_list}   Create List   act5qiAndUlNguTnlQosFlowMod
#     @{value_list}   Create List   false
#     @{mo_list}   Create List   MRBTS-1/NRBTS-1
#     ${out}   Parameter Operation    operation=parameter_update   product_type=vcu   para_list=${para_list}
#     ...      value_list=${value_list}   mo_list=${mo_list}
#     Log To Console    paramter update result: ${out}

# Check E1AP PDUSESSIONMODIFYREQUEST In Wireshark Log
#     [Arguments]  ${capture_file_path}
#     ${output}    Analysis Wireshark Log    ${capture_file_path}
#     ...    filter_expression=e1ap
#     Should Contain    ${output}    BearerContextSetupRequest
#     Should Contain    ${output}    BearerContextModificationRequest
#     ${output}    Analysis Wireshark Log    ${capture_file_path}
#     ...    filter_expression=e1ap.PDU_Session_Resource_To_Modify_List == 1
#     ...    append_cmd=-T pdml
#     ${output}    Analysis Wireshark Log    ${capture_file_path}
#     ...    filter_expression=e1ap.transportLayerAddressIPv4 == 10.0.11.200
#     ...    append_cmd=-T pdml
#     # Log      ${output}

# Check PDURESOURCEMODIFYSUCCESSRESPONSE In Wireshark Log
#     [Arguments]  ${capture_file_path}
#     ${output}    Analysis Wireshark Log    ${capture_file_path}
#     ...    filter_expression=ngap
#     Should Contain    ${output}    PDUSessionResourceModifyRequest
#     Should Contain    ${output}    PDUSessionResourceModifyResponse
#     ${output}    Analysis Wireshark Log    ${capture_file_path}
#     ...    filter_expression=ngap.PDUSessionResourceModifyListModRes == 1
#     ...    append_cmd=-T pdml
#     ${output}    Analysis Wireshark Log    ${capture_file_path}
#     ...    filter_expression=ngap.TransportLayerAddressIPv4 == 10.0.11.200
#     ...    append_cmd=-T pdml