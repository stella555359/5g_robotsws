*** Settings ***
Documentation
...   author: Liguo Zhang
...   contact: liguo.zhang@nokia-sbell.com
...   Description: this is CB008216-SR b22 test case.

# Resource           ../Resources/common_resource.robot
# Resource           ../../Resources/Common/Airphone.robot
# # Resource          ../Resources/top50_resource.robot
# Suite Setup       Common MultiBTS Suite Setup For RRM
# # Suite Setup       Common Suite Setup For RRM
# Test Setup            Common MultiBTS Test Setup For RRM
# # Test Setup          Common Test Setup For RRM
# Test Teardown     Run Keywords    Common MultiBTS Test Teardown For RRM    AND
# ...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
# # Test Teardown    Common Test Teardown For RRM
# Suite Teardown    Common MutliBTS Suite Teardown For RRM
# # Suite Teardown    Common Suite Teardown For RRM
# Force Tags        CRT/CIT/CDRT     #Tag Item
# # ...   PY27
# ...      RAN_5G                    #Product [RAN_5G]
# # ...      CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
# ...      SBTS00/SBTS21B           # it is for auto trigger by ute cloud with the release
# # ...      STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
# ...      RAN_PZ_HAZ_1             #Competence Area
# ...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
# ...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


# Test Timeout    60 minutes

# *** Variables ***
# #reduce global paramter as possilbe and automatically got from gNB or __init__
# &{fault_4334}            faultId=${4334}
# &{fault_4293}            faultId=${4293}
# &{fault_7300}            faultId=${7300}
# @{Ohter_Allow_Alarms}      &{fault_7300}    &{fault_4334}    &{fault_4293}
# # ${DEBUG_MODE}            ${TRUE}
# # ${REMOTE_MODE}           ${TRUE}
# ${parameter}           act5qiAndUlNguTnlQosFlowMod
# ${dist_name}           MRBTS-1/NRBTS-1
# *** Test Cases ***
# CB008126-A-B2 TNL modification for single PDU session with GBR and VoNR and nonGBR
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim
#     ...    base_path=${CURDIR}/Airphone
#     Disable CB008126
#     Start tcpdump by command For Remote
#     Airphone Attach    ue_id=1    call_type=SA
#     Airphone Start Traffic    mbps=5m
#     Airphone Start Traffic    mbps=5m    dir=ul
#     Sleep    10s
#     ${Courrent_DLTput}    Airphone Get Average Throughput
#     ${Courrent_ULTput}    Airphone Get Average Throughput    dir=ul
#     Log To Console    UE1DLULTPUT:${Courrent_DLTput} and ${Courrent_ULTput}
#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    switch_ul_tunnel_endpoint=ip_teid by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     Sleep    20s
#     ${Courrent_Tput}    Airphone Get Average Throughput
#     Log To Console    ${Courrent_Tput}
#     Stop tcpdump And download by command For Remote
#     ${capture_file_path_source}    Download wireshark log to testvm For Remote
#     Check PDURESOURCEMODIFYFAILRESPONSE In Wireshark Log    ${capture_file_path_source}
#     Airphone Stop Traffic
#     Airphone Detach    ue_id=1    call_type=SA

#     Enable CB008126
#     Run Keyword And Ignore Error    Connect To One Site FCT
#     Start tcpdump by command For Remote
#     Airphone Attach    ue_id=1    call_type=SA
#     Airphone Start Traffic    mbps=5m
#     Airphone Start Traffic    mbps=5m   dir=ul
#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    switch_ul_tunnel_endpoint=ip_teid by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     Sleep    20s
#     Stop tcpdump And download by command For Remote
#     ${capture_file_path_source}    Download wireshark log to testvm For Remote
#     Check PDURESOURCEMODIFYSUCCESSRESPONSE In Wireshark Log    ${capture_file_path_source}

# CB008126-A-B22 Failed TNL modification for single PDU with nongbr only with FAF disabled
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim
#     ...    base_path=${CURDIR}/Airphone
#     Disable CB008126
#     Start tcpdump by command For Remote
#     Airphone Attach    ue_id=1    call_type=SA
#     Airphone Start Traffic    mbps=5m
#     Airphone Start Traffic    mbps=5m    dir=ul
#     Sleep    10s
#     ${Courrent_DLTput}    Airphone Get Average Throughput
#     ${Courrent_ULTput}    Airphone Get Average Throughput    dir=ul
#     Log To Console    UE1DLULTPUT:${Courrent_DLTput} and ${Courrent_ULTput}
#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    switch_ul_tunnel_endpoint=ip_teid by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     Sleep    20s
#     ${Courrent_Tput}    Airphone Get Average Throughput
#     Log To Console    ${Courrent_Tput}
#     Stop tcpdump And download by command For Remote
#     ${capture_file_path_source}    Download wireshark log to testvm For Remote
#     Check PDURESOURCEMODIFYFAILRESPONSE In Wireshark Log    ${capture_file_path_source}
#     Airphone Stop Traffic
#     Airphone Detach    ue_id=1    call_type=SA

#     Enable CB008126
#     Run Keyword And Ignore Error    Connect To One Site FCT
#     Start tcpdump by command For Remote
#     Airphone Attach    ue_id=1    call_type=SA
#     Airphone Start Traffic    mbps=5m
#     Airphone Start Traffic    mbps=5m   dir=ul
#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    switch_ul_tunnel_endpoint=ip_teid by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     Sleep    20s
#     Stop tcpdump And download by command For Remote
#     ${capture_file_path_source}    Download wireshark log to testvm For Remote
#     Check PDURESOURCEMODIFYSUCCESSRESPONSE In Wireshark Log    ${capture_file_path_source}

# CB008126-A-B22 Failed TNL modification followed by outgoing HO
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim
#     ...    base_path=${CURDIR}/Airphone
#     Disable CB008126
#     Run Keyword And Ignore Error    Connect To One Site FCT
#     Start tcpdump by command For Remote
#     Airphone Attach    ue_id=1    call_type=SA
#     Sleep    3s
#     Airphone Start Traffic    mbps=5m
#     Sleep    3s
#     Airphone Start Traffic    mbps=5m    dir=ul
#     Sleep    10s
#     ${Courrent_Tput}    Airphone Get Average Throughput
#     Log To Console    ${Courrent_Tput}
#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    switch_ul_tunnel_endpoint=ip_teid by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     Sleep    10s
#     ${Courrent_Tput}    Airphone Get Average Throughput
#     Log To Console    ${Courrent_Tput}
#     # ${MeasureID}    Airphone Get Measurement ID
#     Airphone Send Measurement NR    ue_id=1    meas_id=1    phycell_id=52
#     Sleep     10s
#     Stop tcpdump And download by command For Remote
#     ${capture_file_path_source}    Download wireshark log to testvm For Remote
#     Check PDUSESSIONSETUP In Wireshark Log    ${capture_file_path_source}


# *** Keywords ***
# Disable CB008126     #Disable 5QI, UL TNL tunnel IP modification function
#     Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
#     ${value}    Set Variable    false
#     coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
#     ...    value=${value}    operation=update    connection=commission
#     [Teardown]    COAM_Admin.Logout    connection=commission

# Enable CB008126     #Enable 5QI, UL TNL tunnel IP modification function
#     Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
#     ${value}    Set Variable    true
#     coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
#     ...    value=${value}    operation=update    connection=commission
#     [Teardown]    COAM_Admin.Logout    connection=commission

# Check PDURESOURCEMODIFYSUCCESSRESPONSE In Wireshark Log
#     [Arguments]  ${capture_file_path}
#     ${output}    Parse Pcap by expression    filter_expression=ngap
#     ...    input_file=${capture_file_path}
#     Should Contain    ${output}    PDUSessionResourceModifyRequest
#     Should Contain    ${output}    PDUSessionResourceModifyResponse

#     ${output}    Parse Pcap by expressionbackup
#     ...    filter='ngap.PDUSessionResourceModifyListModRes == 1'
#     ...    filter_expression='ngap.TransportLayerAddressIPv4 == 10.0.1.200'
#     ...    input_file=${capture_file_path}

# Check PDURESOURCEMODIFYFAILRESPONSE In Wireshark Log
#     [Arguments]  ${capture_file_path}
#     ${output}    Parse Pcap by expression    filter_expression=ngap
#     ...    input_file=${capture_file_path}
#     Should Contain    ${output}    PDUSessionResourceModifyRequest
#     Should Contain    ${output}    PDUSessionResourceModifyResponse

#     ${output}    Parse Pcap by expressionbackup
#     ...    filter='ngap.PDUSessionResourceFailedToModifyListModRes == 1'
#     ...    filter_expression='ngap.radioNetwork == 0'
#     ...    input_file=${capture_file_path}

# Check PDUSESSIONSETUP In Wireshark Log
#     [Arguments]  ${capture_file_path}
#     ${output}    Parse Pcap by expression    filter_expression=xnap
#     ...    input_file=${capture_file_path}
#     Should Contain    ${output}    HandoverRequest
#     Should Contain    ${output}    HandoverRequestAcknowledge

#     ${output}    Parse Pcap by expressionbackup
#     ...    filter='xnap.pduSessionResourcesToBeSetup_List == 1'
#     ...    filter_expression='xnap.TransportLayerAddressIPv4 == 10.0.1.1'
#     ...    input_file=${capture_file_path}

