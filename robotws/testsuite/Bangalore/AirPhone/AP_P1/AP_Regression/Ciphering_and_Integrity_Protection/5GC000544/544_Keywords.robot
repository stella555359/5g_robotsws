*** Settings ***
Documentation     Contains 544 feature related keywords
Library           Collections
Library           ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store
Library           ../../../Resources/Python/AdminHelper.py    WITH NAME    admin_helper
Library           ../../../Resources/Python/LogStore.py    WITH NAME   log_store
Resource          ../../../Resources/Variables/Common_Variables.robot
Resource          ../../../Resources/robot/tshark.robot

*** Variables ***
${wireshark_filter_tcB04}    ${CURDIR}/resources/TC_B04_exp_file.txt
${wireshark_filter_tcB15}    ${CURDIR}/resources/TC_B15_exp_file.txt
${wireshark_filter_tcD14}    ${CURDIR}/resources/TC_D14_exp_file.txt
${wireshark_filter_tcD15}    ${CURDIR}/resources/TC_D15_exp_file.txt
${wireshark_filter_tcB05}    ${CURDIR}/resources/TC_B05_exp_file.txt
${wireshark_filter_tcD05}    ${CURDIR}/resources/TC_D05_exp_file.txt
${wireshark_filter_tcC01}    ${CURDIR}/resources/TC_C01_exp_file.txt
${null_aes_srb3}    1
${aes_aes_dl}     2
${aes_aes_ul}     7
${snow3g_aes_srb3}    4
${aes_snow3g_srb3}    5
${zuc_zuc_srb3}    6
${nrbts_distname}    MRBTS-2003/NRBTS-2003
${nrcell_distname}    MRBTS-2003/NRBTS-2003/NRCELL-1

*** Keywords ***
SRB3 Enabled And Ciphering Algorithm Should Match in PCAP
    [Arguments]    ${wireshark_filter}=None
    ${pcap_file}=   log_store.get_gnb_pcap
    PCAP File Should have Messages Defined in Filter File    pcap_file=${pcap_file}
    ...    wireshark_filter_file=${wireshark_filter}

Get UE ID For Ciphering And Integration Alogrithm Required
    [Arguments]    ${nea}=null    ${nia}=null    ${verify}=srb3
    [Documentation]    Get the UE Id to be used in the setup.cfg which has the Ciphering and Integration Algorithm
    ...    combination already configured.
    ...    For Example if Ciphering (nea) is 'aes' and Integration Protocol (nia) is 'aes' and we have
    ...    ue_nr_capabilities configured for DLRRCMessageTransfer then the value of the ue_id is got from
    ...    variable ${aes_aes_dl} which is a combination of the arguments ${nea}, ${nia} and ${verify}
    ${ue_id_variable}    Catenate    SEPARATOR=_    ${nea}    ${nia}    ${verify}
    ${ue_id}    Set Variable    ${${ue_id_variable}}
    [Return]    ${ue_id}

Enable Parameters Related to SRB3
    Initialise delta store
    ${nrbts_distname}    admin_helper.get distname for nrbts
    ${nrcell_distname}    admin_helper.get distname for nrcell using logical id    logical_cell_id=1
    delta_store.update managed object and parameter to delta    dist_name=${nrbts_distname}    srb3SupportEnabled=true
    ...    actIntraFreqInterGnbMobilityNSA3x=true     actIntraFreqIntraGnbMobilityNSA=true
    delta_store.update managed object and parameter to delta    dist_name=${nrcell_distname}    actCDrx=true
    ...    a3MeasEnabled=rsrp
    delta_store.add_list_parameters_to_delta    dist_name=${nrcell_distname}    list_name=a3MeasSsbRsrp
    ...    a3HysteresisSsbRsrp=0    a3OffsetSsbRsrp=0    a3TimeToTriggerSsbRsrp=ms0
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    ${delta_store}

Wait For RRCMessageTransfer To be Sent
    [Arguments]    ${time}=10s
    Sleep    ${time}

Trigger Cell HO Measurement Report
    [Arguments]    ${id}=1    ${meas_id}=1    ${index}=0    ${nrs_result}=40:0:0    ${event}=A3    ${srsrp_nr}=30
    ...    ${phycell_id}=10    ${nrsrp_nr}=40
    ${args_part1}    Set Variable    id\=${id} meas_id\=${meas_id} index\=${index} nrs_result\=${nrs_result}
    ${args_part2}    Set Variable    event\=${event} srsrp_nr\=${srsrp_nr} phycell_id\=${phycell_id} nrsrp_nr\=${nrsrp_nr}
    Execute Egate Command    ue_measurement_send_nr ${args_part1} ${args_part2}

Revert Parameters Related to SRB3
    Delete Delta If Alread Present    name=default
    Initialise delta store
    ${nrbts_distname}    admin_helper.get distname for nrbts
    ${nrcell_distname}    admin_helper.get distname for nrcell using logical id    logical_cell_id=1
    delta_store.update managed object and parameter to delta    dist_name=${nrbts_distname}    srb3SupportEnabled=false
    ...    actIntraFreqInterGnbMobilityNSA3x=false    actIntraFreqIntraGnbMobilityNSA=false
    delta_store.update managed object and parameter to delta    dist_name=${nrcell_distname}    actCDrx=false
    ...    a3MeasEnabled=none
    ${delta_store}    Collect Delta Store
    gnb.Recommission GNB With Delta    ${delta_store}

Attach to UE Based on Ciphering Algorithm
    [Arguments]    ${nea}=null    ${nia}=null    ${verify}=srb3
    ${UE_ID}    Get UE ID For Ciphering And Integration Alogrithm Required    ${nea}    ${nia}    ${verify}
    Set Test Variable    ${UE_ID}
    UE Attach    ue_id=${UE_ID}    profile_id=${PROFILE_ID}
    SGNB Addition For Bearer    ue_id=${UE_ID}    target_gnb=${GNB_ID}    target_cells=${CELL_ID}
    ...    bearer=${BEARER_ID}

Attach to UE For UL and DL RRCMessageTransfer
    UE Attach    ue_id=${aes_aes_dl}    profile_id=${PROFILE_ID}
    UE Attach    ue_id=${aes_aes_ul}    profile_id=${PROFILE_ID}
    SGNB Addition For Bearer    ue_id=${aes_aes_ul}    target_gnb=${GNB_ID}    target_cells=${CELL_ID}
    ...    bearer=${BEARER_ID_UL}
    Trigger RRCMessage Transfer    ${aes_aes_ul}
    SGNB Addition For Bearer    ue_id=${aes_aes_dl}    target_gnb=${GNB_ID}    target_cells=${CELL_ID}
    ...    bearer=${BEARER_ID}
    Trigger RRCMessage Transfer    ${aes_aes_dl}

Trigger RRCMessage Transfer
    [Arguments]    ${ue_id}
    Trigger Cell HO Measurement Report    ${ue_id}
    Wait For RRCMessageTransfer To be Sent    time=5s

Perform UE Dettach for both UE
    UE Detach    ue_id=${aes_aes_dl}
    UE Detach    ue_id=${aes_aes_ul}
