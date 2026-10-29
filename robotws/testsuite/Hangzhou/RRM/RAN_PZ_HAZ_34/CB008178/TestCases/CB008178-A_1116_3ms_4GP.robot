*** Settings ***
Resource    ./../Resources/CB008178-A_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008985/Resources/CB008178_keywords.robot

Documentation    Suite description
...    author: Jiang Xian
...    contact: xian.jiang@nokia-sbell.com
...    squad group: I_NSB_MN_RAN_RD_VRF_HAZ3_01_S1_GMS
...    Feature CB008178

Suite Setup  8178 Suite preparation multiGNB   frame_bw=90M_1116_3ms_4GP    NSA_SA=${NSA_SA}
Suite Teardown  run keyword and ignore error    Common suite recovery

*** Variables ***
${DL_TPUT}         3000M
${UL_TPUT}         200M

*** Test Cases ***
CB008178-A-TC301-PMO-PDSCH_PUSCH_INIRE_VOL_SSB-eCPRI_TDD-2BF-MultiUE-SA_NSA
    [Tags]  CIT_TRUNK
    [Documentation]     Author: Jiang Xian
    ...    step1: UE attach 5 times, check  AVG_RX_PREAMBLE_POWER_SSB and RX_PREAMBLE_PWR_PRACH_LEVEL_** update correctly
    ...    step2: start DL and UL traffic, check PDSCH_INIRE_VOL_SSB，PUSCH_INIRE_VOL_SSB update correctly
    ...    Here subcell_id is for super cell testline, and the concept of that equal to SSB beam id for normal cell testline only when basicBeamSet=2.
    ...    In other basicBeamSet cases，please use NIDD beamsMuted to leave only 2 SSB beams.
    [Setup]     CB008178 Case setup   scf_template_path=${None}
    Set miNrMacPduTput to 5min
    run keyword and continue on failure     Change status for parameter cellBarred on GNB    exp_status=barred
    ...    list_cell_ids=2    timeout=2min
    run keyword and continue on failure     Prepare NRREL under specific cell   ca_group_mapping=${T_T_2CC_CA_GROUP_COMMON}
    set SSB beam only for normal cell testline    cell_id=1
    set SSB beam only for normal cell testline    cell_id=2
    #Sleep If Minute Is 5n+4
    #UE attach several times then check AVG_RX_PREAMBLE_POWER_SSB and RX_PREAMBLE_PWR_PRACH_LEVEL counters
    #...    cell_id=1   subcell_id=0    ssb_beam_needed=${True}   attach_times=${5}
    #...    target_file_name=step1_bip_log_attach_5_times

    ${TDD_UL_EXP_TPUT}   Create List    ${TDD_UL_EXP_TPUT_100M_CA}   0
    ${TDD_DL_EXP_TPUT}   Create List    ${TDD_DL_EXP_TPUT_100M_CA_PCELL}   ${TDD_DL_EXP_TPUT_100M_CA_SCELL}
    ${normalCell_ssb_list}   Create List    0    1
    log to console    Start to DL and UL traffic
    UE attach start DL and UL traffic then check PDSCH_INIRE_VOL_SSB and PUSCH_INIRE_VOL_SSB counters
    ...    cell_id=1    subcell_id=0   customized_log_name=step2_dl_ul_tput_check
    ...    exp_dl_indiv=${TDD_DL_EXP_TPUT}    exp_ul_indiv=${TDD_UL_EXP_TPUT}
    ...    dl_iperf_tput=${DL_TPUT}    ul_iperf_tput=${UL_TPUT}   normalCell_2TCA=${True}
    ...    normalCell_ssb_list=${normalCell_ssb_list}
    [Teardown]    run keyword and ignore error     8178 case teardown    detach_ue=${True}    frame_bw=90M_1116_3ms_4GP

*** Keywords ***
set SSB beam only for normal cell testline
    [Documentation]    set cells's beam type to SSB Beam only
    [Arguments]    ${cell_id}
    log to console    disable pSRS Beam feature   cell_id=${cell_id}
    Disable pSRS Beam feature via restAPI    cell_id=${cell_id}
    log to console    disable 5GC002200-PMI Beam feature
    Disable 5GC002200-PMI Beam feature via restAPI    cell_id=${cell_id}