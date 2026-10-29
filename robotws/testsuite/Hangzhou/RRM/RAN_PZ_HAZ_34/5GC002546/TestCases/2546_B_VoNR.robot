*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/vonr.robot
Resource    ./../../CB007873/Resources/CB007873_keywords.robot


Documentation
...   author: Liu Zheng
...   contact: zheng.4.liu@nokia-sbell.com
...   squad group: MMW_SG1
...   feature : 5GC002546-B


Force Tags    5G_RRM
...    PY36
Suite Setup     Suite preparation for 2546
Suite Teardown    Run keyword and ignore error    CA Suite teardown


*** Variables ***
${COMMAND_TEMPLATE_FOR_PCAP_PARSER}    {tshark_path} -r {pcap_file} -Y  \"ngap\"  -T pdml


*** Test Cases ***
[1]5GC002546_B_B1_04_DRX setup for UEs having VoNR call for F-T CA with 2 SA UE
    [Documentation]    Author: Liu Zheng
    ...    Description: This case is to do voice over NR and UDP traffic with CA configuration.
    ...    Precondition1: CA is configured, cdrx is enabled.
    ...    Precondition2: VoNR is configured on GNB and X60 UE.
    ...    this case not need to check the peak
    ...    checkpoint for VoNR is that the voice call duration should be larger than 28s, no matter try_voice_call_duration
    ...    which means the duration between try to start a voice call and end a voice call.
    ...    try voice call duration is 50s, the voice call duration should be larger than 28s.
    [Tags]    CRT_TRUNK    CRT_21B    CIT_22R1    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
    [Setup]    Common case setup    is_alias_created=${True}    is_enb_status_check_needed=${False}
    ...    is_x2_check_from_enb_needed=${False}
    Test VoNR and UDP traffic    dl_tput=${DL_TPUT}    ul_tput=${UL_TPUT}   interface=any    command_template=${COMMAND_TEMPLATE_FOR_PCAP_PARSER}
    [Teardown]    run keywords    Run keyword and ignore error    Stop trace capturing    log_prefix=asik_master_vonr
    ...    connection_alias=ASIK Master    AND
    ...    Run keyword and ignore error    Common case teardown    detach_ue=${True}


*** Keywords ***
Suite preparation for 2546
    Set Suite Variable    ${dpa_enable}    ${True}
    Import NIDD variables    if_vonr_conf_needed=${True}
    set suite variable    ${PARAMS_TO_MODIFY}    ${PARAMS_TO_MODIFY_CDRX_VONR_ALIGNBWP}
    set suite variable    ${PARAMS_TO_ADD}    ${PARAMS_TO_ADD_FOR_VONR_AND_CDRX}
    CA Suite preparation


