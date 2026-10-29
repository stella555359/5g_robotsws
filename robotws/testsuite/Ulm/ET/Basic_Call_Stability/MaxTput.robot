*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Determine max gNB/cell throughpout

Resource          ./UteCloudAcceptanceTest_Keywords.robot
Resource          ./MaxTput_Keywords.robot

Suite Setup       Prepare TL for Ute Cloud Acceptance Test
Suite Teardown    dcap.stop dcap container for all nodes

Test Setup        Perform Preconditions of Test Case
Test Teardown     Perform Postconditions of Test Case

*** Variables ***

@{IP_LIST_eth3_add}    10.0.1.3  10.0.1.4  10.0.1.5  10.0.1.6  10.0.1.7
@{IP_LIST_eth4_add}    10.0.2.3  10.0.2.4  10.0.2.5  10.0.2.6  10.0.2.7

${tdd_start_dl_mue}=  350
${tdd_step_dl_mue}=  10
${tdd_end_dl_mue}=  2000

${tdd_start_ul_mue}=  150
${tdd_step_ul_mue}=  5
${tdd_end_ul_mue}=  2000

${tdd_start_dl_sue}=  1350
${tdd_step_dl_sue}=  10
${tdd_end_dl_sue}=  2000

${tdd_start_ul_sue}=  150
${tdd_step_ul_sue}=  5
${tdd_end_ul_sue}=  2000

${fdd_start_dl_mue}=  150
${fdd_step_dl_mue}=  10
${fdd_end_dl_mue}=  2000

${fdd_start_ul_mue}=  200
${fdd_step_ul_mue}=  5
${fdd_end_ul_mue}=  2000

${fdd_start_dl_sue}=  350
${fdd_step_dl_sue}=  10
${fdd_end_dl_sue}=  2000

${fdd_start_ul_sue}=  200
${fdd_step_ul_sue}=  5
${fdd_end_ul_sue}=  2000

${duration}=  60
${threshold}=  10.0

*** Test Cases ***

Determine_Max_Throughput
    [Documentation]
    ...  Determine max gNB/single UE throughput
    [Tags]  tput
    ${UEs} =  Get number of all configured NRCELLs
    ${status}   ${cellTechnology}   Run Keyword And Ignore Error    wts_ue.Get cellTechnology Info
    IF  '${status}'=='FAIL'  FAIL  Can't determine cell technology
    Attach SA UEs   count=${UEs}
    Determine Max Throughput all UEs DL  UEs=${UEs}  tech=${cellTechnology}
    Determine Max Throughput all UEs UL  UEs=${UEs}  tech=${cellTechnology}
    Determine Max Throughput single UE DL  tech=${cellTechnology}
    Determine Max Throughput single UE UL  tech=${cellTechnology}
    Detach SA UEs   count=${UEs}
