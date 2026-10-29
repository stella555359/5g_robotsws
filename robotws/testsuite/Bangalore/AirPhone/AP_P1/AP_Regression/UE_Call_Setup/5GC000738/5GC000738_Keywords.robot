*** Settings ***
Documentation    This file contains 5GC000738 keywords

Library           OperatingSystem
Library           ute_wtssim
Library           XML
Resource          ../../../Resources/robot/gnb.robot
Resource          ../../../Resources/robot/ute_setup.robot
Resource          ../../../Resources/robot/wts.robot
Resource          ../../../Resources/robot/airphone.robot
Resource          ./5GC000738_ConfigManagement_Admin.robot
Resource          ../../../Resources/robot/suite_common_keywords.robot
Resource          ../../../Resources/robot/swconfig_keywords.robot
Library           taf.analyzer.pdml    WITH NAME    pdml_analyser

*** Variables ***
${mobile_country_code}     Mobile Country Code (MCC): Nokia verification Ulm (555)
${mobile_network_code1}    Mobile Network Code (MNC): Unknown (10)
${mobile_network_code2}    Mobile Network Code (MNC): Unknown (20)
${wait_time}               5s

*** Keywords ***
Suite Setup
    Suite Common Keywords    feature_folder=5GC000738
    Wait for gNB To Be Ready
    Store Original Parameters in GNB For Revert
    Enable PLMN Parameters for Sngb Addition and Modification
    wait for gnb to be ready
    Prepare Environment Based On Run Type

Suite Teardown
    Common Suite Teardown Keywords
    Revert PLMN parameters in GNB to original Value

Store Original Parameters in GNB For Revert
    Get List of Parameters From gNB

Test Setup
    Create Test Case Folder
    Start pcap collection in gNB and WTS
    Start WTS And Extablish X2 Link

Set PLMN Values
   [Arguments]   ${mcc}    ${mnc}
   Execute Egate Command    cmd=enb_endc_param id=1 selected_plmn=${mcc}:${mnc}

Trigger Sgnb Modification
   [Arguments]   ${ue_id}   ${cause}
   Execute Egate Command    enb_ue_dc_modify ue\=${ue_id} by\=enb cause\=${cause}

Validate PLMN in SgNBadditionReq msg From Pcap
    ${pdml_file}    Stop pcap and convert X2AP to pdml
    ${pdml_entries}    pdml_analyser.get_pdml_entries   file_name=${pdml_file}  field_name=x2ap.SgNBAdditionRequest_element
    ...    attrib_name=showname    attrib_value=SgNBAdditionRequest
    MCC and MNC Should Match in PDML    ${pdml_entries}    mcc=${mobile_country_code}    mnc=${mobile_network_code1}

Validate PLMN in SgNBModificationReq msg From Pcap
    ${pdml_file}    Stop pcap and convert X2AP to pdml
    ${pdml_entries}    pdml_analyser.get_pdml_entries   file_name=${pdml_file}  field_name=x2ap.SgNBModificationRequest_element
    ...    attrib_name=showname    attrib_value=SgNBModificationRequest
    MCC and MNC Should Match in PDML    ${pdml_entries}    mcc=${mobile_country_code}    mnc=${mobile_network_code2}

MCC and MNC Should Match in PDML
    [Arguments]    ${pdml_entries}    ${mcc}    ${mnc}
    ${mcc_value}    pdml_analyser.get_attrib_value_from_pdml_entries    pdml_entries=${pdml_entries}
    ...    field_name=e212.mcc    attrib_name=showname
    ${mnc_value}    pdml_analyser.get_attrib_value_from_pdml_entries    pdml_entries=${pdml_entries}
    ...    field_name=e212.mnc    attrib_name=showname
    Should Contain    ${mcc_value}    ${mcc}    value not matching in the pcap
    Should Contain    ${mnc_value}    ${mnc}    value not matching in the pcap

Wait before Validation
    Sleep    ${wait_time}

SGNB Addition For Default Bearer
    SGNB Addition For Bearer   ue_id=${UE_ID}   target_gnb=${GNB_ID}    target_cells=${CELL_ID}   bearer=${BEARER_ID}

Start Data Transfer on Default UE
    Start Data Transfer And Verify Throughput    bearer=${BEARER_ID}    ue_id=${UE_ID}

Sgnb Modification for Default UE
    Trigger Sgnb Modification    ue_id=${UE_ID}   cause=MISC_CauseMisc_unspecified