*** Settings ***
Documentation     author: Venkatesh
...               contact: venkatesh.1.venkatesh@nokia.com
...               Description:  This File contains Common Keywords used in all the Features under UE_Call_Setup
...               Functionality.

Library     ute_wtssim
Resource    ../../../Resources/robot/gnb.robot
Resource    ../../../Resources/robot/ute_setup.robot
Resource    ../../../Resources/robot/wts.robot
Resource    ./Common_ConfigManagement_Admin_Keywords.robot
Library     taf.analyzer.pdml    WITH NAME    pdml_analyser


*** Keywords ***
Attach to Default UE
   UE Attach   ue_id=${UE_ID}   profile_id=${PROFILE_ID}

Start Data Transfer And Verify It is Through MCG
   [Arguments]    ${timeout}=${DEFAULT_DATATIMEOUT}
   Start Data Transfer And Verify Throughput    bearer=${BEARER_ID}    ue_id=${UE_ID}    timeout=${timeout}
   ...    dl_dc_cell_group=mcg   ul_dc_cell_group=mcg

Perform SGNB Addition For Bearer
   [Arguments]    ${pass_regexp}=reported successful RA
   SGNB Addition For Bearer    ue_id=${UE_ID}    target_gnb=${GNB_ID}    target_cells=${CELL_ID}
   ...                         bearer=${BEARER_ID}    type=split_scg    pass_regexp=${pass_regexp}

Release 5G Bearer
   [Arguments]    ${release_cause}=off
   Release ENDC Bearer    ue_id=${UE_ID}    bearer=${BEARER_ID}    cause=${release_cause}

Wait After Sgnb Addition
   [Arguments]    ${sleep_timer}=1min
   Sleep    ${sleep_timer}

Store Original DL Forward Parameters in GNB For Revert
    ${dl_dataforwording_original_value}=    Get DL Forwarding Parameters From gNB
    Set Suite Variable    ${dl_dataforwording_original_value}

Revert DL Forwarding Parameter in GNB to original Value
    Update Original DL Forwarding params in gNB    ${dl_dataforwording_original_value}

Get Packets Sent And Received For SCG and MCG
    ${total_pkts_sent_scg}    ${total_pkts_recieved_scg}    Get Packets Sent And Received    bearer=${BEARER_ID}   ue_id=${UE_ID}
    ...    dc_cell_group=scg
    ${total_pkts_sent_mcg}    ${total_pkts_recieved_mcg}    Get Packets Sent And Received    bearer=${BEARER_ID}   ue_id=${UE_ID}
    ...    dc_cell_group=mcg
    [Return]    ${total_pkts_sent_scg}    ${total_pkts_recieved_scg}    ${total_pkts_sent_mcg}    ${total_pkts_recieved_mcg}

Ue Attach Based with null cipher
    Attach Ue Based on Ciphering Algorithm    nea_cipher=NULL

Ue Attach Based with aes cipher
    Attach Ue Based on Ciphering Algorithm    nea_cipher=AES

Sgnb Addition Should Fail
    [Arguments]    ${expected_error}
    ${status}    Run Keyword And Return Status    Perform SGNB Addition For Bearer    pass_regexp=${expected_error}
    Run Keyword If    not ${status}    FAIL    msg = Expected Message: "${expected_error}" didnot appear.

Check GNB Status before WTS Start
    Check if gNB is reachable    gnb_ip=${GNB_IP}
    Wait for gNB To Be Ready

Validate Sgnb Release Required From Pcap
    [Arguments]    ${cause}
    ${pdml_file}    Stop pcap and convert X2AP to pdml
    ${pdml_entries}    pdml_analyser.get_pdml_entries   file_name=${pdml_file}  field_name=x2ap.SgNBReleaseRequired_element
    ...    attrib_name=showname    attrib_value=SgNBReleaseRequired
    ${attr_value}    pdml_analyser.get_attrib_value_from_pdml_entries    pdml_entries=${pdml_entries}    field_name=x2ap.radioNetwork
    ...    attrib_name=showname
    Should Contain    ${attr_value}[0]    ${cause}
    ...    msg= pdml attribute value: "${attr_value}[0]" doesnot contain expected cause: ${cause}

Start Uplink Traffic
    Start Uplink Data Transfer    bearer=${BEARER_ID}    ue_id=${UE_ID}
