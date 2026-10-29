*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONFIG_PARAM}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
...               AND    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Force Tags        CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD    CRT    RAN_5G_TDD    RAN_5G    Owner_qiqluo
...               SBTS00    CN1_SQ6    CB010240
Resource          ./Resources/CB010240_resource.robot

*** Variables ***
${SWCONFIG_PARAM}                 0x580497=1;0x57000B=0xFFFFEEF0;0x570030=1;0x5B0613=1;0x10040=1;0x1003F=1;0x5A0619=1
${SCF_PATH}                       ${CURDIR}/Config
${FULL_SCF}                       CB010240_A_NSA_FR2_Discard.xml
${DELTA_SCF_201_ACTIVE}           DELTA_SCF_201_Active.json
${DELTA_SCF_102_ACTIVE_0}         DELTA_SCF_102_Active_0.json
${DELTA_SCF_102_ACTIVE}           DELTA_SCF_102_Active.json
${DELTA_SCF_103_ACTIVE}           DELTA_SCF_103_Active.json
${DELTA_SCF_104_ACTIVE}           DELTA_SCF_104_Active.json
${DELTA_SCF_105_ACTIVE}           DELTA_SCF_105_Active.json
${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4T_LO_LO.xml
${WTS_LOCAL}                      ${CURDIR}/Resources/wts
${WTS_CFG}                        CB010240_A_NSA_FR2_PMQAP.cfg
${DL_BIG_DATA}                    500
${DL_MEDIUM_DATA}                 50
${DL_SMALL_DATA}                  3
${DL_TINY_DATA}                   1
${EXP_SMALL_DL_TPUT}              1
${EXP_DL_TPUT}                    10
${EXP_ZERO_TPUT}                  0
@{EXP_DL_TPUT_LIST}               3    3    3
@{EXP_ZERO_TPUT_LIST}             0    0    0
${NONCA_UE_ID_1}                  12
${NONCA_UE_ID_2}                  14
${NONCA_UE_ID_3}                  13
${3T_UE_ID}                       11
${GNB_ID}                         2
${CELL_ID}                        1
${BEARER_ID}                      2
@{3T_SCELL_PHYSICALID_LIST}       51    54
${DL_BLER}                        100,100,100,100,100,100,100,100
@{MAC_PM_LIST}                    M55309C00002    M55309C00003
&{COUNTER_INFO_MAC_1}             cell_id=1    MO_name=NMSDU    counter_ids_list=${MAC_PM_LIST}
&{COUNTER_INFO_MAC_2}             cell_id=2    MO_name=NMSDU    counter_ids_list=${MAC_PM_LIST}
&{COUNTER_INFO_MAC_3}             cell_id=3    MO_name=NMSDU    counter_ids_list=${MAC_PM_LIST}
&{COUNTER_INFO_MAC_4}             cell_id=4    MO_name=NMSDU    counter_ids_list=${MAC_PM_LIST}
@{RLC_PM_LIST}                    M55309C00036    M55309C00037
&{COUNTER_INFO_RLC_1}             cell_id=1    MO_name=NMSDU    counter_ids_list=${RLC_PM_LIST}
&{COUNTER_INFO_RLC_2}             cell_id=2    MO_name=NMSDU    counter_ids_list=${RLC_PM_LIST}
&{COUNTER_INFO_RLC_3}             cell_id=3    MO_name=NMSDU    counter_ids_list=${RLC_PM_LIST}
&{COUNTER_INFO_RLC_4}             cell_id=4    MO_name=NMSDU    counter_ids_list=${RLC_PM_LIST}
@{RLC_PMQAP_PM_LIST}              M55373C00001    M55373C00002
&{COUNTER_INFO_RLC_PMQAP_1}       cell_id=1    MO_name=NRPMQAP-1/LRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
&{COUNTER_INFO_RLC_PMQAP_2}       cell_id=2    MO_name=NRPMQAP-1/LRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
&{COUNTER_INFO_RLC_PMQAP_3}       cell_id=3    MO_name=NRPMQAP-1/LRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
&{COUNTER_INFO_RLC_PMQAP_4}       cell_id=4    MO_name=NRPMQAP-1/LRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
@{PDCP_PM_LIST}                   M55352C01002    M55352C01003    M55352C01004    M55352C01005
&{COUNTER_INFO_PDCP_1}            cell_id=1    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
&{COUNTER_INFO_PDCP_2}            cell_id=2    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
&{COUNTER_INFO_PDCP_3}            cell_id=3    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
&{COUNTER_INFO_PDCP_4}            cell_id=4    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
@{PM_COUNTER_LIST}                @{MAC_PM_LIST}    @{RLC_PM_LIST}    @{RLC_PMQAP_PM_LIST}    @{PDCP_PM_LIST}
@{MAC_COUNTER_INFO_LIST}          ${COUNTER_INFO_MAC_1}    ${COUNTER_INFO_MAC_2}    ${COUNTER_INFO_MAC_3}    ${COUNTER_INFO_MAC_4}
@{RLC_COUNTER_INFO_LIST}          ${COUNTER_INFO_RLC_1}    ${COUNTER_INFO_RLC_2}    ${COUNTER_INFO_RLC_3}    ${COUNTER_INFO_RLC_4}
@{RLC_PMQAP_COUNTER_INFO_LIST}    ${COUNTER_INFO_RLC_PMQAP_1}    ${COUNTER_INFO_RLC_PMQAP_2}    ${COUNTER_INFO_RLC_PMQAP_3}
...                               ${COUNTER_INFO_RLC_PMQAP_4}
@{PDCP_COUNTER_INFO_LIST}         ${COUNTER_INFO_PDCP_1}    ${COUNTER_INFO_PDCP_2}    ${COUNTER_INFO_PDCP_3}    ${COUNTER_INFO_PDCP_4}
${CELL1_COUNTER_PATH}             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${CELL2_COUNTER_PATH}             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
${CELL3_COUNTER_PATH}             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
${CELL4_COUNTER_PATH}             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
@{L2STREAM_COMPONENT_CONFIG}      &{TTITRACE_CONFIG_L2HIPDCP}    &{TTITRACE_CONFIG_L2HIRLC}    &{TTITRACE_CONFIG_L2LO}
${EXP_GAP}                        1500
@{LOG_NAME_LIST}                   btslog    x2pcap    snapshot    egatelog

*** Test Cases ***
CB010240_ET_A_B2_201_NonCA_MultiUE_Online_Modify_Discard_PMQAP_Profiles_NSA_FR2
    [Setup]    Common Test Setup
    NSA LTE Attach    ${NONCA_UE_ID_1}
    NSA LTE Attach    ${NONCA_UE_ID_2}
    NSA LTE Attach    ${NONCA_UE_ID_3}
    NSA 5G Attach    ${NONCA_UE_ID_1}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA 5G Attach    ${NONCA_UE_ID_2}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA 5G Attach    ${NONCA_UE_ID_3}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}    ${DL_MEDIUM_DATA}
    NSA Start DL Traffic    ${NONCA_UE_ID_2}    ${BEARER_ID}    ${DL_MEDIUM_DATA}
    NSA Start DL Traffic    ${NONCA_UE_ID_3}    ${BEARER_ID}    ${DL_MEDIUM_DATA}
    Sleep    10s    reason=Wait For DL Transmission
    Delta Commission With SCF File    ${DELTA_SCF_201_ACTIVE}
    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_2}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_3}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Stop Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}
    NSA Stop Traffic    ${NONCA_UE_ID_2}    ${BEARER_ID}
    NSA Stop Traffic    ${NONCA_UE_ID_3}    ${BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_1
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR2_TDD    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01005}==0
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${mac_counter_dict.cell1.M55309C00002}==${rlc_counter_dict.cell1.M55309C00036}==${rlc_pmqap_counter_dict.cell1.M55373C00001}
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${mac_counter_dict.cell1.M55309C00003}==${rlc_counter_dict.cell1.M55309C00037}==${rlc_pmqap_counter_dict.cell1.M55373C00002}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR2_TDD    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01005}==0
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR2_TDD    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01005}==0
    ${calc_cell4_m55309c00002}    ${calc_cell4_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    53    FR2_TDD    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${gap_cell4_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell4.M55309C00002}-${calc_cell4_m55309c00002})
    ${gap_cell4_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell4.M55309C00003}-${calc_cell4_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell4.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell4.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell4.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell4.M55352C01005}==0
    ${release_ue1}    Set Variable    enb_ue_dc_release bearer=${BEARER_ID} ue=${NONCA_UE_ID_1} by=enb cause=MISC_CauseMisc_unspecified
    ${release_ue2}    Set Variable    enb_ue_dc_release bearer=${BEARER_ID} ue=${NONCA_UE_ID_2} by=enb cause=MISC_CauseMisc_unspecified
    ${release_ue3}    Set Variable    enb_ue_dc_release bearer=${BEARER_ID} ue=${NONCA_UE_ID_3} by=enb cause=MISC_CauseMisc_unspecified
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${release_ue1}
    ...    pass_regexp=Successfully reconfigured dual connectivity    timeout=30
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${release_ue2}
    ...    pass_regexp=Successfully reconfigured dual connectivity    timeout=30
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${release_ue3}
    ...    pass_regexp=Successfully reconfigured dual connectivity    timeout=30
    ${RA_ue1}    Set Variable    enb_ue_dc_start ue=${NONCA_UE_ID_1} target_gnb=${GNB_ID} target_cells=${CELL_ID} bearer=${BEARER_ID} type=split_scg
    ${RA_ue2}    Set Variable    enb_ue_dc_start ue=${NONCA_UE_ID_2} target_gnb=${GNB_ID} target_cells=${CELL_ID} bearer=${BEARER_ID} type=split_scg
    ${RA_ue3}    Set Variable    enb_ue_dc_start ue=${NONCA_UE_ID_3} target_gnb=${GNB_ID} target_cells=${CELL_ID} bearer=${BEARER_ID} type=split_scg
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${RA_ue1}    pass_regexp=successful RA    timeout=30
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${RA_ue2}    pass_regexp=successful RA    timeout=30
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${RA_ue3}    pass_regexp=successful RA    timeout=30
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}    ${DL_BIG_DATA}
    NSA Start DL Traffic    ${NONCA_UE_ID_2}    ${BEARER_ID}    ${DL_BIG_DATA}
    NSA Start DL Traffic    ${NONCA_UE_ID_3}    ${BEARER_ID}    ${DL_BIG_DATA}
    Sleep    10s    reason=Wait For DL Transmission
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_2}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_3}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Stop Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}
    NSA Stop Traffic    ${NONCA_UE_ID_2}    ${BEARER_ID}
    NSA Stop Traffic    ${NONCA_UE_ID_3}    ${BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_2
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR2_TDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${calc_cell1_M55352C01002}    ${calc_cell1_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    50    FR2_TDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${gap_cell1_M55352C01002}    Evaluate    abs(${pdcp_counter_dict.cell1.M55352C01002}-${calc_cell1_M55352C01002})
    ${gap_cell1_M55352C01003}    Evaluate    abs(${pdcp_counter_dict.cell1.M55352C01003}-${calc_cell1_M55352C01003})
#    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55352C01002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55352C01003}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${mac_counter_dict.cell1.M55309C00002}==${rlc_counter_dict.cell1.M55309C00036}==${rlc_pmqap_counter_dict.cell1.M55373C00001}
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${mac_counter_dict.cell1.M55309C00003}==${rlc_counter_dict.cell1.M55309C00037}==${rlc_pmqap_counter_dict.cell1.M55373C00002}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01005}==0
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR2_TDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR2_TDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    ${calc_cell4_m55309c00002}    ${calc_cell4_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    53    FR2_TDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${gap_cell4_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell4.M55309C00002}-${calc_cell4_m55309c00002})
    ${gap_cell4_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell4.M55309C00003}-${calc_cell4_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_m55309c00003}<${exp_gap}
    [Teardown]    Run Keywords    NSA LTE Detach    ${NONCA_UE_ID_1}
    ...    AND    NSA LTE Detach    ${NONCA_UE_ID_2}
    ...    AND    NSA LTE Detach    ${NONCA_UE_ID_3}
    ...    AND    Common Test Teardown

CB010240_ET_B_B1_102_NonCA_Small_Volume_SingUE_5G_Leg_Counters_F1UX2U_PMQAP_Profiles_NSA_FR2
    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_SCF_102_ACTIVE_0}
    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    ...    AND    Common Test Setup
    NSA LTE Attach    ${NONCA_UE_ID_1}
    NSA 5G Attach    ${NONCA_UE_ID_1}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    Wait Until PM Counter Update
    # Delete RD BTS Counter Xml
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}    ${DL_SMALL_DATA}
    Sleep    10s    reason=Wait For DL Transmission
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_SMALL_DL_TPUT}
    NSA Stop Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_1
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict_1}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR2_TDD    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${calc_cell1_M55352C01002}    ${calc_cell1_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${gap_cell1_M55352C01002}    Evaluate    abs(${pdcp_counter_dict_1.cell1.M55352C01002}-${calc_cell1_M55352C01002})
    ${gap_cell1_M55352C01003}    Evaluate    abs(${pdcp_counter_dict_1.cell1.M55352C01003}-${calc_cell1_M55352C01003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_1.cell1.M55352C01002}>0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_1.cell1.M55352C01003}>0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_1.cell1.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_1.cell1.M55352C01005}==0
    NSA LTE Detach    ${NONCA_UE_ID_1}
    Delta Commission With SCF File    ${DELTA_SCF_102_ACTIVE}
    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    NSA LTE Attach    ${NONCA_UE_ID_1}
    NSA 5G Attach    ${NONCA_UE_ID_1}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    Wait Until PM Counter Update
    # Delete RD BTS Counter Xml
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}    ${DL_SMALL_DATA}
    Sleep    10s    reason=Wait For DL Transmission
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_SMALL_DL_TPUT}
    NSA Stop Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_2
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict_2}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR2_TDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${calc_cell1_M55352C01002}    ${calc_cell1_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${gap_cell1_M55352C01002}    Evaluate    abs(${pdcp_counter_dict_2.cell1.M55352C01002}-${calc_cell1_M55352C01002})
    ${gap_cell1_M55352C01003}    Evaluate    abs(${pdcp_counter_dict_2.cell1.M55352C01003}-${calc_cell1_M55352C01003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_1.cell1.M55352C01002}>${pdcp_counter_dict_2.cell1.M55352C01002}
    #Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_1.cell1.M55352C01003}>${pdcp_counter_dict_2.cell1.M55352C01003}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_2.cell1.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_2.cell1.M55352C01005}==0
    [Teardown]    Run Keywords    NSA LTE Detach    ${NONCA_UE_ID_1}
    ...    AND    Common Test Teardown

CB010240_ET_B_B1_103_NonCA_Big_Volume_SingUE_5G_Leg_Counters_F1U_PMQAP_Profiles_NSA_FR2
    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_SCF_103_ACTIVE}
    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    ...    AND    Common Test Setup
    NSA LTE Attach    ${NONCA_UE_ID_1}
    NSA 5G Attach    ${NONCA_UE_ID_1}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    Wait Until PM Counter Update
    # Delete RD BTS Counter Xml
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}    ${DL_BIG_DATA}
    Sleep    5s    reason=Wait For DL Transmission
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Stop Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    NSA Start DL Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}    ${DL_BIG_DATA}
    Sleep    5s    reason=Wait For DL Transmission
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Stop Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${mac_counter_dict.cell1.M55309C00002}==${rlc_counter_dict.cell1.M55309C00036}==${rlc_pmqap_counter_dict.cell1.M55373C00001}
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${mac_counter_dict.cell1.M55309C00003}==${rlc_counter_dict.cell1.M55309C00037}==${rlc_pmqap_counter_dict.cell1.M55373C00002}
    ${calc_cell1_M55352C01002}    ${calc_cell1_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    50    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_M55352C01002}    Evaluate    abs(${pdcp_counter_dict.cell1.M55352C01002}-${calc_cell1_M55352C01002})
    ${gap_cell1_M55352C01003}    Evaluate    abs(${pdcp_counter_dict.cell1.M55352C01003}-${calc_cell1_M55352C01003})
#    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55352C01002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55352C01003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01005}==0
    [Teardown]    Run Keywords    NSA LTE Detach    ${NONCA_UE_ID_1}
    ...    AND    Common Test Teardown

CB010240_ET_B_B1_104_NonCA_Big_Volume_SingUE_LTE_Leg_Counters_X2U_PMQAP_Profiles_NSA_FR2
    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_SCF_104_ACTIVE}
    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    ...    AND    Common Test Setup
    NSA LTE Attach    ${NONCA_UE_ID_1}
    NSA 5G Attach    ${NONCA_UE_ID_1}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    Wait Until PM Counter Update
    # Delete RD BTS Counter Xml
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}    ${DL_BIG_DATA}
    Sleep    5s    reason=Wait For DL Transmission
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Stop Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    NSA Start DL Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}    ${DL_BIG_DATA}
    Sleep    5s    reason=Wait For DL Transmission
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Stop Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    Run Keyword And Continue On Failure    Should Be True    ${mac_counter_dict.cell1.M55309C00002}==0
    Run Keyword And Continue On Failure    Should Be True    ${mac_counter_dict.cell1.M55309C00003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01004}>0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01005}>0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01003}==0
    [Teardown]    Run Keywords    NSA LTE Detach    ${NONCA_UE_ID_1}
    ...    AND    Common Test Teardown

CB010240_ET_B_B1_105_NonCA_Big_Volume_MultiUE_5G_Leg_Counters_F1UX2U_PMQAP_Profiles_NSA_FR2
    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_SCF_105_ACTIVE}
    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    ...    AND    Common Test Setup
    NSA LTE Attach    ${NONCA_UE_ID_1}
    NSA LTE Attach    ${NONCA_UE_ID_2}
    NSA LTE Attach    ${NONCA_UE_ID_3}
    NSA 5G Attach    ${NONCA_UE_ID_1}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA 5G Attach    ${NONCA_UE_ID_2}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA 5G Attach    ${NONCA_UE_ID_3}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    Wait Until PM Counter Update
    # Delete RD BTS Counter Xml
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}    ${DL_BIG_DATA}
    NSA Start DL Traffic    ${NONCA_UE_ID_2}    ${BEARER_ID}    ${DL_BIG_DATA}
    NSA Start DL Traffic    ${NONCA_UE_ID_3}    ${BEARER_ID}    ${DL_BIG_DATA}
    Sleep    10s    reason=Wait For DL Transmission
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_2}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_3}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Stop Traffic    ${NONCA_UE_ID_1}    ${BEARER_ID}
    NSA Stop Traffic    ${NONCA_UE_ID_2}    ${BEARER_ID}
    NSA Stop Traffic    ${NONCA_UE_ID_3}    ${BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
#    Run Keyword And Continue On Failure    Should Be True
#    ...    ${mac_counter_dict.cell1.M55309C00002}==${rlc_counter_dict.cell1.M55309C00036}==${rlc_pmqap_counter_dict.cell1.M55373C00001}
#    Run Keyword And Continue On Failure    Should Be True
#    ...    ${mac_counter_dict.cell1.M55309C00003}==${rlc_counter_dict.cell1.M55309C00037}==${rlc_pmqap_counter_dict.cell1.M55373C00002}
    ${calc_cell1_M55352C01002}    ${calc_cell1_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    50    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_M55352C01002}    Evaluate    abs(${pdcp_counter_dict.cell1.M55352C01002}-${calc_cell1_M55352C01002})
    ${gap_cell1_M55352C01003}    Evaluate    abs(${pdcp_counter_dict.cell1.M55352C01003}-${calc_cell1_M55352C01003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55352C01002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55352C01003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01004}>0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01005}>0
    [Teardown]    Run Keywords    NSA LTE Detach    ${NONCA_UE_ID_1}
    ...    AND    NSA LTE Detach    ${NONCA_UE_ID_2}
    ...    AND    NSA LTE Detach    ${NONCA_UE_ID_3}
    ...    AND    Common Test Teardown

