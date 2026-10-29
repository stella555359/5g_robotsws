*** Settings ***
Documentation     Contains CB007949 feature related keywords
Resource        ../CA_Common_Keywords.robot

*** Variables ***
@{Counter_List}                     M55118C05506    M55118C07002    M55118C07003    M55316C03002    M55316C05002
@{ul_scell_id}                      0
@{3CC_scell_index}                  1     2
@{3CC_cell_index}                   0    1     2

*** Keywords ***
Test Setup for 7949
    [Arguments]    &{kwargs}
    Set variables for TC    &{kwargs}
    Common Test Setup With Custom Configuration    &{kwargs}
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure Address Distribution Is Successful
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure UE SIB Decoding Is Successful
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Check if cell setup completed
    Run Keyword And Ignore Error    Check pcap files in gNB
    Enable rrc traces in WTS
    Start AP TTI Traces    AP
    Start gNB TTI Traces
    Start WTS tcpdump for UDP traffic

Perform SA UE Register for Blind ScellAddition and Bufferbased ScellActivation for 3CC
    [Arguments]    ${sa_ue_list}    ${scell_index_list}=${3CC_scell_index}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        ${output}    Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}
        ...     pass_regexp=sCellIndex ${SA_Scell_Index}[1]    nwslice=1
        Verify scell addition for each scell index    ${scell_index_list}
    END

Validate uplink and downlink cell throughput from UE stats and bearer stats for dl CA
    [Arguments]    ${expected_dl_tput}    ${expected_ul_tput}    ${UE_List}    ${UL_Scell_Id}    ${DL_Scell_Id}
    ${expected_dl_value}    Evaluate    isinstance(${expected_dl_tput}, list) == True
    ${expected_total_dl_tput}    Run Keyword If    ${expected_dl_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_dl_tput}])    ELSE    Set Variable    ${expected_dl_tput}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for SA UE: ${ue_id}
        sleep    10s
        ${cell_stats_total_tput_UL}    ${bearer_stats_UL_tput}    Get throughput from ue stats and bearer stats
        ...    ${ue_id}    ${UL_Scell_Id}    dir=ul
        ${cell_stats_total_tput_DL}    ${bearer_stats_DL_tput}    Get throughput from ue stats and bearer stats
        ...     ${ue_id}    ${DL_Scell_Id}    dir=dl
        Total CA UE Throughput Verification from cell stats   ${cell_stats_total_tput_DL}    ${expected_total_dl_tput}
        Total CA UE Throughput Verification from cell stats   ${cell_stats_total_tput_UL}    ${expected_ul_tput}
    END
