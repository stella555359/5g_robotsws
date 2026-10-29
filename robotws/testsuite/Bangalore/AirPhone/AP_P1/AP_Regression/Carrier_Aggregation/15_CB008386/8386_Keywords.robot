*** Settings ***
Documentation     Contains 8386 feature related keywords
Resource        ../CA_Common_Keywords.robot

*** Variables ***
@{Counter_List}                    M55316C09000    M55310C01009    M55310C03009
@{nrrel_profile_id}                1    2    3    4    5    6    7    8
${interrat_gnb_delta_json}         ${WTS_CFG_PATH}/InterRAT_8386_delta.json
${anr_ir_gnb_delta_json}           ${WTS_CFG_PATH}/InterRAT_ANR_8386_delta.json
@{logical_cell_list}               1    2    3    4    5    6    7    8
${NUMBER_OF_CELLS}                 1

*** Keywords ***
Test Setup for FR2
    [Arguments]    &{kwargs}
    Set variables for TC    &{kwargs}
    Common Test Setup With Custom Configuration    &{kwargs}
    Establish X2 link    enb_id=1    gnb_id=2
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure Address Distribution Is Successful
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure UE SIB Decoding Is Successful
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Check for cell setup complete msg    ${logical_cell_list}
    Run Keyword And Ignore Error    Check pcap files in gNB
    Enable rrc traces in WTS
    Start AP TTI Traces    AP
    Start gNB TTI Traces
    Start WTS tcpdump for UDP traffic

Perform attach and detach
    [Arguments]    ${nsa_ue_list}    ${pass_regexp}=sCellIndex ${NSA_Scell_Index}[1]
    Attach For NSA UEs    ${nsa_ue_list}    ${pass_regexp}
    Detach NSA UEs for Blind ScellAddition    ${nsa_ue_list}

Start Traffic for NSA Non CA UE
    [Arguments]    ${ue_id_list}    ${bearer_id}=${bearer_id}    ${dl_tput}=${dl_tput}
    FOR    ${ue_id}    IN    @{ue_id_list}
        Start Traffic    ue_id=${ue_id}    dir=ul    id=${bearer_id}    mbps=${ul_tput}
    END
    FOR    ${ue_id}    IN    @{ue_id_list}
        Start Traffic    ue_id=${ue_id}    dir=dl    id=${bearer_id}    mbps=${dl_tput}
    END
    sleep    10s
