*** Settings ***
Documentation     Contains 2339 feature related keywords
Resource        ../CA_Common_Keywords.robot

*** Variables ***
@{Counter_List}                    M55316C09000    M55310C01009    M55310C03009

*** Keywords ***
Validate Pcell Throughput from UE stats for Non CA Capable UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${scell}=0
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for Non CA Capable SA UE: ${ue_id}
        ${pcell_tput_dl}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=${scell}    type=pdsch
        ${pcell_tput_ul}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=${scell}    type=pusch
        Total CA UE Throughput Verification from cell stats   ${pcell_tput_dl}    ${expected_dl_tput}
        Total CA UE Throughput Verification from cell stats   ${pcell_tput_ul}    ${expected_ul_tput}
    END
