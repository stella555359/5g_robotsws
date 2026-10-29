*** Settings ***
Documentation    This file contains 5GC000509 common keywords

Library           OperatingSystem
Library           ute_wtssim
Library           taf.analyzer.pdml    WITH NAME    pdml_analyser
Resource          ../../../Resources/robot/gnb.robot
Resource          ../../../Resources/robot/ute_setup.robot
Resource          ../../../Resources/robot/wts.robot
Resource          ../../../Resources/Variables/Common_Variables.robot
Resource          ../../../Resources/robot/suite_common_keywords.robot
Resource          ./5GC000509_ConfigManagement_Admin.robot
Resource          ../Resources/Common_Keywords.robot

*** Variables ***
${WTS_CFG_PATH}               ${CURDIR}/cfg
${NEA_NULL}                   1
${NEA_AES}                    2
${SEND_EXTENSION}             on
${MAX_SCG_PKTS_DIFF}          200

*** Keywords ***
Suite Setup
    [Arguments]    ${feature_folder}
    Suite Common Keywords    feature_folder=${feature_folder}
    Wait for gNB To Be Ready

Suite Teardown
    Run Keyword and Ignore Error    UE Detach    ue_id=${UE_ID}
    Common Suite Teardown Keywords

CleanUp
    ute_wtssim.Teardown All Aliases For Wts

Get UE ID For Ciphering Algorithm Required
    [Arguments]    ${nea}
    ${ue_id_variable}    Catenate    SEPARATOR=_    NEA    ${nea}
    ${ue_id}    Set Variable    ${${ue_id_variable}}
    [Return]    ${ue_id}

Attach Ue Based on Ciphering Algorithm
    [Arguments]    ${nea_cipher}
    ${UE_ID}    Get UE ID For Ciphering Algorithm Required    ${nea_cipher}
    Set Test Variable    ${UE_ID}
    UE Attach   ue_id=${UE_ID}   profile_id=${PROFILE_ID}

Verify Data Transmission on SCG
    Data Transmission Should not happen on MCG
    Data Transmission Should happen on SCG

Data Transmission Should happen on SCG
    Should be True    ${${total_pkts_sent_scg_after_sgnb_addition}} > ${${total_pkts_sent_mcg_after_sgnb_addition}}
    ...    msg = Data is not flowing over Sgnb
    Should be True    ${${total_pkts_recieved_scg_after_sgnb_addition}} > ${${total_pkts_recieved_mcg_after_sgnb_addition}}
    ...    msg = Data is not flowing over Sgnb

Data Transmission Should not happen on MCG
    Packet Difference Should be With In Range    ${total_pkts_sent_mcg_after_sgnb_addition}    ${total_pkts_sent_mcg}
    Packet Difference Should be With In Range    ${total_pkts_recieved_mcg_after_sgnb_addition}    ${total_pkts_recieved_mcg}

Store Packets Sent and Received Before Sgnb Addition
    ${total_pkts_sent_scg}    ${total_pkts_recieved_scg}    ${total_pkts_sent_mcg}    ${total_pkts_recieved_mcg}
    ...    Get Packets Sent And Received For SCG and MCG
    Set Test Variable    ${total_pkts_sent_scg}
    Set Test Variable    ${total_pkts_recieved_scg}
    Set Test Variable    ${total_pkts_sent_mcg}
    Set Test Variable    ${total_pkts_recieved_mcg}

Store Packets Sent and Received After Sgnb Addition
    ${total_pkts_sent_scg_after_sgnb_addition}    ${total_pkts_recieved_scg_after_sgnb_addition}
    ...    ${total_pkts_sent_mcg_after_sgnb_addition}    ${total_pkts_recieved_mcg_after_sgnb_addition}
    ...    Get Packets Sent And Received For SCG and MCG
    Set Test Variable    ${total_pkts_sent_scg_after_sgnb_addition}
    Set Test Variable    ${total_pkts_recieved_scg_after_sgnb_addition}
    Set Test Variable    ${total_pkts_sent_mcg_after_sgnb_addition}
    Set Test Variable    ${total_pkts_recieved_mcg_after_sgnb_addition}

Packet Difference Should be With In Range
    [Arguments]    ${packet_2}    ${packet_1}    ${allowed_difference}=${MAX_SCG_PKTS_DIFF}
    ${diff_packets}    Evaluate    ${${packet_2}} - ${${packet_1}}
    Should be True    ${${diff_packets}} <= ${${allowed_difference}}
    ...    msg = Data Transfer is happening on MCG after SCG Assition.

Store Original Cipher Parameters In GNB For Revert
    ${cipher_paramters_original_value}=    Get Cipher Parameters From gNB
    Set Suite Variable    ${cipher_paramters_original_value}
    ${nullfallback_original_value}=    Get NullFallback Parameter From gNB
    Set Suite Variable    ${nullfallback_original_value}

Revert Cipher Parameters in GNB to Original Value
    Update Original Cipher Params in gNB    ${cipher_paramters_original_value}

Revert NullFallback Parameter in GNB to Original Value
    Update Original nullfallback Param in gNB    ${nullfallback_original_value}

Validate Sgnb Addition Reject From Pcap
    ${pdml_file}    Stop pcap and convert X2AP to pdml
    ${pdml_entries}    pdml_analyser.get_pdml_entries   file_name=${pdml_file}  field_name=x2ap.SgNBAdditionRequestReject_element
    ...    attrib_name=showname    attrib_value=SgNBAdditionRequestReject
    ${attr_value}    pdml_analyser.get_attrib_value_from_pdml_entries    pdml_entries=${pdml_entries}    field_name=x2ap.radioNetwork
    ...    attrib_name=showname
    Should Contain    ${attr_value}[0]    radioNetwork: encryption-and-or-integrity-protection-algorithms-not-supported
    ...    msg= pdml attribute value: "${attr_value}" doesnot contain expected cause.

Store Original CBRA Preamble Parameter In GNB For Revert
    ${cbra_preamble_original_value}=    Get CBRA Preamble Parameter From gNB
    Set Suite Variable    ${cbra_preamble_original_value}

Revert Original CBRA Preamble Parameter in GNB to original Value
    Update Original CBRA Preamble Param in gNB    ${cbra_preamble_original_value}

RACH Dedicated IE Should Present in RRC Reconfiguration
    [Arguments]    ${type}=CFRA
    Get and Set RRC Reconfiguration PDML Entries
    ${attr_value}    pdml_analyser.get_attrib_value_from_pdml_entries    pdml_entries=${rrc_pdml_entries}    field_name=nr-rrc.rach_ConfigDedicated
    ...    attrib_name=showname
    Run Keyword If    "${type}" == "CFRA"    Should Contain    ${attr_value}[0]    rach-ConfigDedicated
    ...    msg= pdml attribute value: "${attr_value}" doesnot contain expected cause.    ELSE    Should be Empty    ${attr_value}
    ...    msg= Expected: RACH Dedicated IE Should not Present.

Get and Set RRC Reconfiguration PDML Entries
    ${pdml_file}    Stop pcap and convert X2AP to pdml
    ${rrc_pdml_entries}    pdml_analyser.get_pdml_entries   file_name=${pdml_file}  field_name=x2ap.SgNBAdditionRequestAcknowledge_element
    ...    attrib_name=showname    attrib_value=SgNBAdditionRequestAcknowledge
    Set Test Variable    ${rrc_pdml_entries}

RACH Dedicated IE Should Not Present in RRC Reconfiguration
    RACH Dedicated IE Should Present in RRC Reconfiguration    type=CBRA

CFRA Preamble Value Should Present in RRC Reconfiguration
    [Arguments]    ${expected_preamble}=60
    ${preamble_value}    pdml_analyser.get_attrib_value_from_pdml_entries    pdml_entries=${rrc_pdml_entries}    field_name=nr-rrc.ra_PreambleIndex
    ...    attrib_name=show
    Should Be Equal    ${preamble_value}[0]    ${expected_preamble}
    ...    msg= CFRA Preamble value: "${preamble_value}[0]" is not Matching with Preamble value being set: "${expected_preamble}"

