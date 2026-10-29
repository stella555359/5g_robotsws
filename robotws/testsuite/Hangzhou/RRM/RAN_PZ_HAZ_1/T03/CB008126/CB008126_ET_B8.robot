*** Settings ***
Documentation
...   author: Liguo Zhang
...   contact: liguo.zhang@nokia-sbell.com
...   Description: This is CB008126-SR B8 CRT cases script

# Resource           ../Resources/common_resource.robot
# Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
# Resource           ../../Resources/Classical/RRM_Common_Resource.robot
# Resource           ../../Resources/Common/Airphone.robot
# Suite Setup        Common MultiBTS Suite Setup For RRM
# Test Setup         Common MultiBTS Test Setup For RRM
# Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
# ...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
# Suite Teardown     Common MutliBTS Suite Teardown For RRM
# Force Tags         CRT/CIT/CDRT     #Tag Item
# ...                RAN_5G                    #Product [RAN_5G]
# # ...              CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
# ...                SBTS00           # it is for auto trigger by ute cloud with the release
# # ...              STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
# ...                RAN_PZ_HAZ_1             #Competence Area
# ...                RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
# ...                TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


# Test Timeout       60 minutes

# *** Variables ***
# #reduce global paramter as possilbe and automatically got from gNB or __init__
# &{fault_4334}            faultId=${4334}
# &{fault_4293}            faultId=${4293}
# &{fault_7300}            faultId=${7300}
# &{fault_7107}            faultId=${7107}
# @{Ohter_Allow_Alarms}      &{fault_7300}    &{fault_4334}    &{fault_4293}    &{fault_7107}
# # ${DEBUG_MODE}          ${TRUE}
# # ${REMOTE_MODE}       ${TRUE}
# # ${PATH}              /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/5GC001729/config/SBTS24R2
# # ${PATH2}               /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T03/CB008126/Airphone

# *** Test Cases ***
# CB008126-A-B8 UL TNL modification received in inactive state
#     [Documentation]
#     ...    author: Liguo Zhang
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_B8
#     ...    base_path=${CURDIR}/Airphone
#     ...    call_type=sa
#     ${UE_setting}    Catenate    amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on
#     ...    ue_identity_index_value=1
#     ...    ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=7627107,100,200,201,788,0
#     Airphone Execute Egate Command
#     ...    cmd=${UE_setting}
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= BTS, 5GCN and AP are ready. =============${\n}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Attach is done. =============${\n}
#     Sleep    80 seconds
#     Airphone Execute Egate Command    cmd=ue_disp id=1
#     ...    pass_regexp=UE_INACTIVE
#     Log To Console      ${\n}============= UE is in INACTIVE State. =============${\n}
#     #Check the UE status, should be INACTIVE
#     Run Keyword And Ignore Error    Connect To One Site FCT
#     Start tcpdump by command For Remote
#     Sleep    10s
#     ${ret}    airphone_pdu_session_modify    ue_id=1
#     ...    pdu_id=1
#     ...    switch_ul_tunnel_endpoint=ip_teid by=amf
#     ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     Airphone Execute Egate Command    cmd=ue_disp id=1
#     ...    pass_regexp=UE_INACTIVE
#     Log To Console      ${\n}============= UE is still in INACTIVE State after modification. =============${\n}
#     #Check the UE status, should be INACTIVE after UL NGU TNL modified
#     Log To Console      ${\n}============= Start Traffic on UE. =============${\n}
#     Airphone Start Traffic    dir=dl    mbps=5m
#     # UE enters active state due to sending DL Traffic
#     Sleep    30 seconds
#     ${Courrent_DLTput}    Airphone Get Average Throughput
#     Log To Console    ${Courrent_DLTput}
#     Stop tcpdump And download by command For Remote
#     ${capture_file_path_source}    Download wireshark log to testvm For Remote
#     Log To Console      ${\n}============= Check Logs. =============${\n}
#     Check PDURESOURCEMODIFYSUCCESSRESPONSE In Wireshark Log    ${capture_file_path_source}
#     Log To Console      ${\n}============= Stop Traffic on UE. =============${\n}
#     Airphone Stop Traffic    ue_id=1
#     # Log To Console      ${\n}============= Wait for UE entering INACTIVE State. =============${\n}
#     # Sleep    80 seconds
#     # #UE inactivity because no Tput
#     # Airphone Execute Egate Command    cmd=ue_disp id=1
#     # ...    pass_regexp=UE_INACTIVE
#     # Log To Console      ${\n}============= UE is in INACTIVE State. =============${\n}
#     # Run Keyword And Ignore Error    Connect To One Site FCT
#     # Start tcpdump by command For Remote
#     # Sleep    10s
#     # ${ret}    airphone_pdu_session_modify    ue_id=1
#     # ...    pdu_id=1
#     # ...    switch_ul_tunnel_endpoint=teid_only by=amf
#     # ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
#     # Airphone Execute Egate Command    cmd=ue_disp id=1
#     # ...    pass_regexp=UE_INACTIVE
#     # Log To Console      ${\n}============= UE is still in INACTIVE State after modification. =============${\n}
#     # #Check the UE status, should be INACTIVE
#     # Airphone Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=1 gnb=2 cell=1 cause=mo_Data
#     # ...    pass_regexp=${None}
#     # Airphone Execute Egate Command    cmd=ue_nr_rrc_resume id=1
#     # ...    pass_regexp=UE performed resume procedure
#     # Airphone Start Traffic    mbps=5m    dir=ul
#     # Log To Console      ${\n}============= Start Traffic on UE. =============${\n}
#     # # UE enters active state due to sending UL Traffic
#     # Sleep   20 seconds
#     # ${Courrent_ULTput}    Airphone Get Average Throughput    dir=ul
#     # Log to console    ${Courrent_ULTput}
#     # Stop tcpdump And download by command For Remote
#     # ${capture_file_path_source}    Download wireshark log to testvm For Remote
#     # Check PDURESOURCEMODIFYTEIDRESPONSE In Wireshark Log    ${capture_file_path_source}
#     # Run Keyword And Ignore Error    Connect To One Site FCT
#     # Start tcpdump by command For Remote
#     # Sleep    10s
#     # Log To Console      ${\n}============= Trigger UE handover. =============${\n}
#     # # Send MR to trigger the Handover
#     # Airphone Send Measurement NR    ue_id=1    meas_id=1    phycell_id=52
#     # Sleep     10s
#     # Stop tcpdump And download by command For Remote
#     # ${capture_file_path_source}    Download wireshark log to testvm For Remote
#     # Check PDUSESSIONSETUP In Wireshark Log    ${capture_file_path_source}

# *** Keywords ***

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

# Check PDURESOURCEMODIFYTEIDRESPONSE In Wireshark Log
#     [Arguments]  ${capture_file_path}
#     ${output}    Parse Pcap by expression    filter_expression=ngap
#     ...    input_file=${capture_file_path}
#     Should Contain    ${output}    PDUSessionResourceModifyRequest
#     Should Contain    ${output}    PDUSessionResourceModifyResponse

#     ${output}    Parse Pcap by expressionbackup
#     ...    filter='ngap.PDUSessionResourceModifyListModRes == 1'
#     ...    filter_expression='ngap.gTP_TEID == 00:00:00:02'
#     ...    input_file=${capture_file_path}

# Check PDUSESSIONSETUP In Wireshark Log
#     [Arguments]  ${capture_file_path}
#     ${output}    Parse Pcap by expression    filter_expression=xnap
#     ...    input_file=${capture_file_path}
#     Should Contain    ${output}    HandoverRequest
#     Should Contain    ${output}    HandoverRequestAcknowledge

#     ${output}    Parse Pcap by expressionbackup
#     ...    filter='xnap.pduSessionResourcesToBeSetup_List == 1'
#     ...    filter_expression='xnap.gtp_teid == 00:00:00:02'
#     ...    input_file=${capture_file_path}