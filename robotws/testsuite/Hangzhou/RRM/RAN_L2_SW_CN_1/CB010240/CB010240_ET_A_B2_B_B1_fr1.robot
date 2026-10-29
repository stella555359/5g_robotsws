*** Settings ***
Documentation    CB010240
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONFIG_PARAM}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
...               AND    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2
Suite Teardown    Common Suite Teardown    debug
Test Setup        Common Test Setup
Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_qiqluo
...               SBTS00    CN1_SQ6    CB010240
Resource          ./Resources/CB010240_resource.robot

*** Variables ***
${SWCONFIG_PARAM}                 0x580497=1;0x57000B=0xFFFFEEF0;0x570030=1;0x5B0613=1;0x10040=1;0x1003F=1;0x5A0619=1;0x5A0608=1;0x890003=1
${SCF_PATH}                       ${CURDIR}/Config
${FULL_SCF}                       CB010240_A_SA_FR1_Discard.xml
${DELTA_SCF_202_ACTIVE}           DELTA_SCF_202_Active.json
${DELTA_SCF_101_ACTIVE_0}         DELTA_SCF_101_Active_0.json
${DELTA_SCF_101_ACTIVE}           DELTA_SCF_101_Active.json
${DELTA_SCF_106_ACTIVE}           DELTA_SCF_106_Active.json
${DELTA_SCF_107_ACTIVE}           DELTA_SCF_107_Active.json
${DELTA_SCF_108_ACTIVE}           DELTA_SCF_108_Active.json
${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4F_2T_BOO_LOO_SANSA.xml
${WTS_LOCAL}                      ${CURDIR}/Resources/wts
${WTS_CFG}                        CB010240_A_SA_NSA_FR1_PMQAP.cfg
${DL_BIG_DATA}                    500
${DL_MEDIUM_DATA}                 50
${DL_TINY_DATA}                   1
${DL_SMALL_DATA}                  3
${EXP_SMALL_DL_TPUT}              1
${EXP_DL_TPUT}                    5
${EXP_ZERO_TPUT}                  0
@{EXP_DL_TPUT_LIST}               3    3    3
@{EXP_DL_TPUT_LIST_202}           3    0    0
@{EXP_ZERO_TPUT_LIST}             0    0    0
@{NONCA_UE_ID_LIST}               1    2    5
${NONCA_UE_ID}                    1
${NSA_NONCA_UE_ID_1}              91
${NSA_NONCA_UE_ID_2}              92
${NSA_NONCA_UE_ID_3}              93
${NSA_CA_UE_ID_1}                 94
${NSA_CA_UE_ID_2}                 95
${GNB_ID}                         2
${CELL_ID_1}                      1
${CELL_ID_2}                      2
${BEARER_ID}                      2
@{3F_UE_ID_LIST}                  3    4
@{3F_SCELL_PHYSICALID_LIST}       ${SCELL_PHYSICALID_1}    ${SCELL_PHYSICALID_2}
@{SCELL_PHYSICALID_1}             51    54
@{SCELL_PHYSICALID_2}             51    54
${DL_BLER}                        100,100,100,100,100,100,100,100
@{MAC_PM_LIST}                    M55309C00002    M55309C00003
&{COUNTER_INFO_MAC_1}             cell_id=1    MO_name=NMSDU    counter_ids_list=${MAC_PM_LIST}
&{COUNTER_INFO_MAC_2}             cell_id=2    MO_name=NMSDU    counter_ids_list=${MAC_PM_LIST}
&{COUNTER_INFO_MAC_3}             cell_id=3    MO_name=NMSDU    counter_ids_list=${MAC_PM_LIST}
&{COUNTER_INFO_MAC_5}             cell_id=5    MO_name=NMSDU    counter_ids_list=${MAC_PM_LIST}
@{RLC_PM_LIST}                    M55349C03002    M55349C04002
&{COUNTER_INFO_RLC_1}             cell_id=1    MO_name=NHRRC    counter_ids_list=${RLC_PM_LIST}
&{COUNTER_INFO_RLC_2}             cell_id=2    MO_name=NHRRC    counter_ids_list=${RLC_PM_LIST}
&{COUNTER_INFO_RLC_3}             cell_id=3    MO_name=NHRRC    counter_ids_list=${RLC_PM_LIST}
&{COUNTER_INFO_RLC_5}             cell_id=5    MO_name=NHRRC    counter_ids_list=${RLC_PM_LIST}
@{RLC_PMQAP_PM_LIST}              M55353C00002    M55353C00003
&{COUNTER_INFO_RLC_PMQAP_1}       cell_id=1    MO_name=NRPMQAP-1/HRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
&{COUNTER_INFO_RLC_PMQAP_2}       cell_id=2    MO_name=NRPMQAP-1/HRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
&{COUNTER_INFO_RLC_PMQAP_3}       cell_id=3    MO_name=NRPMQAP-1/HRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
&{COUNTER_INFO_RLC_PMQAP_5}       cell_id=5    MO_name=NRPMQAP-1/HRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
@{PDCP_PM_LIST}                   M55352C01002    M55352C01003    M55352C01004    M55352C01005
&{COUNTER_INFO_PDCP_1}            cell_id=1    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
&{COUNTER_INFO_PDCP_2}            cell_id=2    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
&{COUNTER_INFO_PDCP_3}            cell_id=3    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
&{COUNTER_INFO_PDCP_5}            cell_id=5    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
@{PM_COUNTER_LIST}                @{MAC_PM_LIST}    @{RLC_PM_LIST}    @{RLC_PMQAP_PM_LIST}    @{PDCP_PM_LIST}
@{MAC_COUNTER_INFO_LIST}          ${COUNTER_INFO_MAC_1}    ${COUNTER_INFO_MAC_2}    ${COUNTER_INFO_MAC_3}    ${COUNTER_INFO_MAC_5}
@{RLC_COUNTER_INFO_LIST}          ${COUNTER_INFO_RLC_1}    ${COUNTER_INFO_RLC_2}    ${COUNTER_INFO_RLC_3}    ${COUNTER_INFO_RLC_5}
@{RLC_PMQAP_COUNTER_INFO_LIST}    ${COUNTER_INFO_RLC_PMQAP_1}    ${COUNTER_INFO_RLC_PMQAP_2}    ${COUNTER_INFO_RLC_PMQAP_3}
...                               ${COUNTER_INFO_RLC_PMQAP_5}
@{PDCP_COUNTER_INFO_LIST}         ${COUNTER_INFO_PDCP_1}    ${COUNTER_INFO_PDCP_2}    ${COUNTER_INFO_PDCP_3}    ${COUNTER_INFO_PDCP_5}
${CELL1_COUNTER_PATH}             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${CELL2_COUNTER_PATH}             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
${CELL3_COUNTER_PATH}             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
${CELL5_COUNTER_PATH}             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
@{L2STREAM_COMPONENT_CONFIG}      &{ttitrace_config_l2hipdcp}    &{ttitrace_config_l2hirlc}    &{ttitrace_config_l2lo}
@{LOG_NAME_LIST}                   btslog    x2pcap    snapshot    egatelog

*** Test Cases ***
CB010240_ET_A_B2_202_3F_MultiUE_Online_Modify_Discard_PMQAP_Profiles_SA_FR1
    [Setup]    Run Keywords    Common Test Setup
    SA Multi UE Attach With Scell Blind Addition    ${3F_UE_ID_LIST}    ${3F_SCELL_PHYSICALID_LIST}    3
    ${crnti_ue3}    Get Crnti From Egate Log    3
    ${crnti_ue4}    Get Crnti From Egate Log    4
    Wait Until PM Counter Update
    # discard change not enable with online-change
    Start Ttitrace With Streaming Mode
    SA Multi UE Start DL Traffic    ${3F_UE_ID_LIST}    3
    Sleep    10s    reason=Wait For DL Transmission
    Delta Commission With SCF File    ${DELTA_SCF_202_ACTIVE}
    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    Check Multi UE DLCA Cell L1 Tput    ${3F_UE_ID_LIST}    ${EXP_DL_TPUT_LIST_202}    3
    SA Multi UE Stop DL Traffic    ${3F_UE_ID_LIST}
    Wait Until Keyword Succeeds    1min    3s    Check Multi UE DLCA Cell L1 Tput
    ...    ${3F_UE_ID_LIST}    ${EXP_ZERO_TPUT_LIST}    3
    Sleep    10s    reason=wait for l2lo trace log
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_1
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict_1}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01005}==0
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00003}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict_1.cell2.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict_1.cell2.M55349C04002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01005}==0
    ${calc_cell5_m55309c00002}    ${calc_cell5_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    54    FR1_FDD    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${gap_cell5_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell5.M55309C00002}-${calc_cell5_m55309c00002})
    ${gap_cell5_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell5.M55309C00003}-${calc_cell5_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell5.M55353C00002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell5.M55353C00003}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict_1.cell5.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict_1.cell5.M55349C04002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01005}==0
    # discard change enable after Reestablishment
    SA Multi 5G PDU Session Release    ${3F_UE_ID_LIST}
    SA Multi 5G PDU Session Reestablishment    ${3F_UE_ID_LIST}
    Wait Until PM Counter Update
    ${rlc_counter_dict_12}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    Start Ttitrace With Streaming Mode
    # Start GNB BIP By Admin Method
    SA Multi UE Start DL Traffic    ${3F_UE_ID_LIST}    250
    Sleep    10s    reason=Wait For DL Transmission
    SA Check NonCA Multi UE Cell Dl Tput On Target    ${3F_UE_ID_LIST}    ${EXP_DL_TPUT_LIST}
    SA Multi UE Stop DL Traffic    ${3F_UE_ID_LIST}
    Wait Until Keyword Succeeds    1min    3s    Check Multi UE DLCA Cell L1 Tput
    ...    ${3F_UE_ID_LIST}    ${EXP_ZERO_TPUT_LIST}    3
    Sleep    10s    reason=wait for l2lo trace log
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_2
    # Stop Gnb BIP By Admin Method    log_path=${TEST_LOG_Directory}/2
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict_2}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00002}==${RLC_COUNTER_dict_2.cell1.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00003}==${RLC_COUNTER_dict_2.cell1.M55349C04002}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00003}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict_2.cell2.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict_2.cell2.M55349C04002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01005}==0
    ${calc_cell5_m55309c00002}    ${calc_cell5_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    54    FR1_FDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${gap_cell5_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell5.M55309C00002}-${calc_cell5_m55309c00002})
    ${gap_cell5_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell5.M55309C00003}-${calc_cell5_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict_2.cell5.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict_2.cell5.M55349C04002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell5.M55353C00002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell5.M55353C00003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01005}==0
    ${calc_cell1_M55352C01002}    ${calc_cell1_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${calc_cell2_M55352C01002}    ${calc_cell2_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${calc_cell5_M55352C01002}    ${calc_cell5_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    54    FR1_FDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${calc_pdcp_volume_sum}    Evaluate    ${calc_cell1_M55352C01002}+${calc_cell2_M55352C01002}+${calc_cell5_M55352C01002}
    ${gap_pdcp_volume}    Evaluate    abs(${pdcp_counter_dict.cell1.M55352C01002}-${calc_pdcp_volume_sum})
    ${gap_pdcp_duration}    Evaluate    abs(${pdcp_counter_dict.cell1.M55352C01003}-${calc_cell1_M55352C01003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_pdcp_volume}<2500
    #Run Keyword And Continue On Failure    Should Be True    ${gap_pdcp_duration}<${exp_gap}
    # RLC counter updated partly after UE detach
    SA Multi UE Detach    ${3F_UE_ID_LIST}
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict_3}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell1_m55349c03002_1}    ${calc_cell1_m55349c04002_1}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${True}    3F    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${calc_cell1_m55349c03002_2}    ${calc_cell1_m55349c04002_2}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${True}    3F    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${calc_rlc_volume_sum}    Evaluate    ${calc_cell1_m55349c03002_1}+${calc_cell1_m55349c03002_2}
    ${calc_rlc_time_sum}    Evaluate    ${calc_cell1_m55349c04002_1}+${calc_cell1_m55349c04002_2}
    ${counter_rlc_volume_sum1}    Evaluate    ${rlc_counter_dict_1.cell1.M55349C03002}+${rlc_counter_dict_12.cell1.M55349C03002}
    ${counter_rlc_volume_sum2}    Evaluate    ${rlc_counter_dict_2.cell1.M55349C03002}+${rlc_counter_dict_3.cell1.M55349C03002}
    ${counter_rlc_volume_sum}    Evaluate    ${counter_rlc_volume_sum1}+${counter_rlc_volume_sum2}
    ${counter_rlc_time_sum1}    Evaluate    ${rlc_counter_dict_1.cell1.M55349C04002}+${rlc_counter_dict_12.cell1.M55349C04002}
    ${counter_rlc_time_sum2}    Evaluate    ${rlc_counter_dict_2.cell1.M55349C04002}+${rlc_counter_dict_3.cell1.M55349C04002}
    ${counter_rlc_time_sum}    Evaluate    ${counter_rlc_time_sum1}+${counter_rlc_time_sum2}
    ${gap_rlc_volume}    Evaluate    abs(${calc_rlc_volume_sum}-${counter_rlc_volume_sum})
    ${gap_rlc_time}    Evaluate    abs(${calc_rlc_time_sum}-${counter_rlc_time_sum})
    Run Keyword And Continue On Failure    Should Be True    ${gap_rlc_volume}<2000
    Run Keyword And Continue On Failure    Should Be True    ${gap_rlc_time}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${mac_counter_dict.cell1.M55309C00002}==0
    Run Keyword And Continue On Failure    Should Be True    ${mac_counter_dict.cell1.M55309C00003}==0
    Run Keyword And Continue On Failure    Should Be True    ${mac_counter_dict.cell2.M55309C00002}==0
    Run Keyword And Continue On Failure    Should Be True    ${mac_counter_dict.cell2.M55309C00003}==0
    Run Keyword And Continue On Failure    Should Be True    ${mac_counter_dict.cell5.M55309C00002}==0
    Run Keyword And Continue On Failure    Should Be True    ${mac_counter_dict.cell5.M55309C00003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01005}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01005}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01005}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00002}==${RLC_COUNTER_dict_3.cell1.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00003}==${RLC_COUNTER_dict_3.cell1.M55349C04002}
    [Teardown]    Run Keywords    Common Test Teardown

CB010240_ET_B_B1_101_NonCA_Small_Volume_SingUE_5G_Leg_Counters_PMQAP_Profiles_SA_FR1
    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_SCF_101_ACTIVE_0}
    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    ...    AND    Common Test Setup
    SA Single UE Attach    ${NONCA_UE_ID}
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    SA Start DL Traffic Internal    ${NONCA_UE_ID}    1    ${DL_MEDIUM_DATA}
    Sleep    20s    reason=Wait For DL Transmission
    SA Check UE Cell TPut On Target    ${NONCA_UE_ID}    1    dl    ${EXP_SMALL_DL_TPUT}
    SA Stop Data Traffic Internal    ${NONCA_UE_ID}    1
    Wait Until Keyword Succeeds    1min    3s    SA Check UE Cell TPut Equal To Target
    ...    ${NONCA_UE_ID}    1    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_1
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict_1}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming_1/tcpdump_ttitrace_MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<25000
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${calc_cell1_M55352C01002}    ${calc_cell1_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming_1/tcpdump_ttitrace_MacPduMuxReq.csv
    ${gap_cell1_M55352C01002}    Evaluate    abs(${pdcp_counter_dict_1.cell1.M55352C01002}-${calc_cell1_M55352C01002})
    ${gap_cell1_M55352C01003}    Evaluate    abs(${pdcp_counter_dict_1.cell1.M55352C01003}-${calc_cell1_M55352C01003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55352C01002}<30000
    # Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55352C01003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_1.cell1.M55352C01002}>0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_1.cell1.M55352C01003}>0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_1.cell1.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_1.cell1.M55352C01005}==0
    SA 5G Detach    ${NONCA_UE_ID}
    Delta Commission With SCF File    ${DELTA_SCF_101_ACTIVE}
    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    SA Single UE Attach    ${NONCA_UE_ID}
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    SA Start DL Traffic Internal    ${NONCA_UE_ID}    1    ${DL_MEDIUM_DATA}
    Sleep    20s    reason=Wait For DL Transmission
    SA Check UE Cell TPut On Target    ${NONCA_UE_ID}    1    dl    ${EXP_SMALL_DL_TPUT}
    SA Stop Data Traffic Internal    ${NONCA_UE_ID}    1
    Wait Until Keyword Succeeds    1min    3s    SA Check UE Cell TPut Equal To Target
    ...    ${NONCA_UE_ID}    1    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_2
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict_2}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming_2/tcpdump_ttitrace_MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_1.cell1.M55352C01002}>${pdcp_counter_dict_2.cell1.M55352C01002}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_1.cell1.M55352C01003}>${pdcp_counter_dict_2.cell1.M55352C01003}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_1.cell1.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict_1.cell1.M55352C01005}==0
    [Teardown]    Run Keywords    SA 5G Detach    ${NONCA_UE_ID}
    ...    AND    Common Test Teardown

CB010240_ET_B_B1_106_NonCA_Big_Volume_MultiUE_LTE_Leg_Counters_X2U_PMQAP_Profiles_NSA_FR1
    [Setup]    Case Test Setup    ${DELTA_SCF_106_ACTIVE}
    NSA LTE Attach    ${NSA_NONCA_UE_ID_1}
    NSA 5G Attach    ${NSA_NONCA_UE_ID_1}    ${GNB_ID}    ${CELL_ID_1}    ${BEARER_ID}
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NSA_NONCA_UE_ID_1}    ${BEARER_ID}    ${DL_BIG_DATA}
    Sleep    10s    reason=Wait For DL Transmission
    NSA Check Average Traffic Bigger Than Target    ${NSA_NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Stop Traffic    ${NSA_NONCA_UE_ID_1}    ${BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NSA_NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_1
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
    NSA LTE Attach    ${NSA_NONCA_UE_ID_2}
    NSA LTE Attach    ${NSA_NONCA_UE_ID_3}
    NSA 5G Attach    ${NSA_NONCA_UE_ID_2}    ${GNB_ID}    ${CELL_ID_1}    ${BEARER_ID}
    NSA 5G Attach    ${NSA_NONCA_UE_ID_3}    ${GNB_ID}    ${CELL_ID_1}    ${BEARER_ID}
    Wait Until PM Counter Update
    # Delete RD BTS Counter Xml
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NSA_NONCA_UE_ID_1}    ${BEARER_ID}    ${DL_BIG_DATA}
    NSA Start DL Traffic    ${NSA_NONCA_UE_ID_2}    ${BEARER_ID}    ${DL_BIG_DATA}
    NSA Start DL Traffic    ${NSA_NONCA_UE_ID_3}    ${BEARER_ID}    ${DL_BIG_DATA}
    Sleep    10s    reason=Wait For DL Transmission
    NSA Check Average Traffic Bigger Than Target    ${NSA_NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NSA_NONCA_UE_ID_2}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NSA_NONCA_UE_ID_3}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Stop Traffic    ${NSA_NONCA_UE_ID_1}    ${BEARER_ID}
    NSA Stop Traffic    ${NSA_NONCA_UE_ID_2}    ${BEARER_ID}
    NSA Stop Traffic    ${NSA_NONCA_UE_ID_3}    ${BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NSA_NONCA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_2
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${pdcp2_counter_dict}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    Run Keyword And Continue On Failure    Should Be True    ${mac_counter_dict.cell1.M55309C00002}==0
    Run Keyword And Continue On Failure    Should Be True    ${mac_counter_dict.cell1.M55309C00003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp2_counter_dict.cell1.M55352C01004}>${pdcp_counter_dict.cell1.M55352C01004}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp2_counter_dict.cell1.M55352C01005}>${pdcp_counter_dict.cell1.M55352C01005}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp2_counter_dict.cell1.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp2_counter_dict.cell1.M55352C01003}==0
    [Teardown]    Run Keywords    NSA LTE Detach    ${NSA_NONCA_UE_ID_1}
    ...    AND    NSA LTE Detach    ${NSA_NONCA_UE_ID_2}
    ...    AND    NSA LTE Detach    ${NSA_NONCA_UE_ID_3}
    ...    AND    Common Test Teardown

CB010240_ET_B_B1_107_1F1T_Big_Volume_MultiUE_5G_LTE_Leg_Counters_F1U_PMQAP_Profiles_NSA_FR1
    [Setup]    Case Test Setup    ${DELTA_SCF_107_ACTIVE}
    NSA LTE Attach    ${NSA_CA_UE_ID_1}
    NSA LTE Attach    ${NSA_CA_UE_ID_2}
    Serving Cell Index For 5G NR
    NSA 5G Attach    ${NSA_CA_UE_ID_1}    ${GNB_ID}    ${CELL_ID_2}    ${BEARER_ID}
    NSA 5G Attach    ${NSA_CA_UE_ID_2}    ${GNB_ID}    ${CELL_ID_2}    ${BEARER_ID}
    Sleep    10s    reason=Wait For DL Transmission
    Set Value For CQI Testmode
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NSA_CA_UE_ID_1}    ${BEARER_ID}    170
    NSA Start DL Traffic    ${NSA_CA_UE_ID_2}    ${BEARER_ID}    170
    Sleep    20s    reason=Wait For DL Transmission
    Check Scell Active Status    2    activated    pass
    NSA Check Average Traffic Bigger Than Target    ${NSA_CA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NSA_CA_UE_ID_2}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Stop Traffic    ${NSA_CA_UE_ID_1}    ${BEARER_ID}
    NSA Stop Traffic    ${NSA_CA_UE_ID_2}    ${BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NSA_CA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NSA_CA_UE_ID_2}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    NSA LTE Detach    ${NSA_CA_UE_ID_1}
    NSA LTE Detach    ${NSA_CA_UE_ID_2}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    ${calc_cell2_m55349c03002}    ${calc_cell2_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${True}    1F1T    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C03002}-${calc_cell2_m55349c03002})
    ${gap_cell2_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C04002}-${calc_cell2_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c03002}<120000
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c04002}<12000
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00002}==${RLC_COUNTER_dict.cell2.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00003}==${RLC_COUNTER_dict.cell2.M55349C04002}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01005}==0
    ${calc_cell2_M55352C01002}    ${calc_cell2_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${calc_cell3_M55352C01002}    ${calc_cell3_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${calc_pdcp_volume_sum}    Evaluate    ${calc_cell2_M55352C01002}+${calc_cell3_M55352C01002}
    ${gap_pdcp_volume}    Evaluate    abs(${pdcp_counter_dict.cell2.M55352C01002}-${calc_pdcp_volume_sum})
    ${gap_pdcp_duration}    Evaluate    abs(${pdcp_counter_dict.cell2.M55352C01003}-${calc_cell2_M55352C01003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_pdcp_volume}<1500
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<550
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell3.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell3.M55349C04002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00002}==${RLC_COUNTER_dict.cell3.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00003}==${RLC_COUNTER_dict.cell3.M55349C04002}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01005}==0
    [Teardown]    Common Test Teardown

CB010240_ET_B_B1_108_1F1T_Big_Volume_MultiUE_5G_LTE_Leg_Counters_F1UX2U_PMQAP_Profiles_NSA_FR1
    [Setup]    Case Test Setup    ${DELTA_SCF_108_ACTIVE}
    NSA LTE Attach    ${NSA_CA_UE_ID_1}
    Serving Cell Index For 5G NR
    NSA 5G Attach    ${NSA_CA_UE_ID_1}    ${GNB_ID}    ${CELL_ID_2}    ${BEARER_ID}
    Sleep    10s    reason=Wait For DL Transmission
    Set Value For CQI Testmode
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NSA_CA_UE_ID_1}    ${BEARER_ID}    ${DL_BIG_DATA}
    Sleep    20s    reason=Wait For DL Transmission
    Check Scell Active Status    2    activated    pass
    NSA Check Average Traffic Bigger Than Target    ${NSA_CA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Stop Traffic    ${NSA_CA_UE_ID_1}    ${BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NSA_CA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Sleep    2s    reason=wait l2lo trace log
    NSA LTE Detach    ${NSA_CA_UE_ID_1}
    Sleep    2s    reason=wait l2lo trace log
    # ${crnti_ue1}    Background SA UE    ${NONCA_UE_ID_LIST[0]}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_1
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    ${calc_cell2_m55349c03002}    ${calc_cell2_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${True}    1F1T    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${gap_cell2_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C03002}-${calc_cell2_m55349c03002})
    ${gap_cell2_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C04002}-${calc_cell2_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c03002}<2500
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00002}==${RLC_COUNTER_dict.cell2.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00003}==${RLC_COUNTER_dict.cell2.M55349C04002}
    ${calc_cell2_M55352C01002}    ${calc_cell2_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${calc_cell3_M55352C01002}    ${calc_cell3_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${calc_pdcp_volume_sum}    Evaluate    ${calc_cell2_M55352C01002}+${calc_cell3_M55352C01002}
    ${gap_pdcp_volume}    Evaluate    abs(${pdcp_counter_dict.cell2.M55352C01002}-${calc_pdcp_volume_sum})
    ${gap_pdcp_duration}    Evaluate    abs(${pdcp_counter_dict.cell2.M55352C01003}-${calc_cell2_M55352C01003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_pdcp_volume}<1500
    Run Keyword And Continue On Failure    Should Be True    ${gap_pdcp_duration}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01004}>0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01005}>0
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${test_log_directory}/ttitrace_streaming_1/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell3.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell3.M55349C04002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00002}==${RLC_COUNTER_dict.cell3.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00003}==${RLC_COUNTER_dict.cell3.M55349C04002}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01005}==0
    NSA LTE Attach    ${NSA_CA_UE_ID_1}
    NSA LTE Attach    ${NSA_CA_UE_ID_2}
    Serving Cell Index For 5G NR
    NSA 5G Attach    ${NSA_CA_UE_ID_1}    ${GNB_ID}    ${CELL_ID_2}    ${BEARER_ID}
    NSA 5G Attach    ${NSA_CA_UE_ID_2}    ${GNB_ID}    ${CELL_ID_2}    ${BEARER_ID}
    Sleep    10s    reason=Wait For DL Transmission
    Set Value For CQI Testmode
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NSA_CA_UE_ID_1}    ${BEARER_ID}    200
    NSA Start DL Traffic    ${NSA_CA_UE_ID_2}    ${BEARER_ID}    200
    Sleep    10s    reason=Wait For DL Transmission
    Check Scell Active Status    2    activated    pass
    NSA Check Average Traffic Bigger Than Target    ${NSA_CA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NSA_CA_UE_ID_2}    ${BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Stop Traffic    ${NSA_CA_UE_ID_1}    ${BEARER_ID}
    NSA Stop Traffic    ${NSA_CA_UE_ID_2}    ${BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NSA_CA_UE_ID_1}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NSA_CA_UE_ID_2}    ${BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Sleep    2s    reason=wait l2lo trace log
    NSA LTE Detach    ${NSA_CA_UE_ID_1}
    NSA LTE Detach    ${NSA_CA_UE_ID_2}
    Sleep    2s    reason=wait l2lo trace log
    # ${crnti_ue1}    Background SA UE    ${NONCA_UE_ID_LIST[0]}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_2
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${pdcp_counter_dict}    Run Keyword And Continue On Failure    Get Multi Cells Multi PM Counters Latest Values With Admin Advance
    ...    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    ${calc_cell2_m55349c03002}    ${calc_cell2_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${True}    1F1T    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${gap_cell2_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C03002}-${calc_cell2_m55349c03002})
    ${gap_cell2_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C04002}-${calc_cell2_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c03002}<35000
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c04002}<${exp_gap}
    ${calc_cell2_M55352C01002}    ${calc_cell2_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${calc_cell3_M55352C01002}    ${calc_cell3_M55352C01003}    Run Keyword And Continue On Failure    Get PDCP Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${calc_pdcp_volume_sum}    Evaluate    ${calc_cell2_M55352C01002}+${calc_cell3_M55352C01002}
    ${gap_pdcp_volume}    Evaluate    abs(${pdcp_counter_dict.cell2.M55352C01002}-${calc_pdcp_volume_sum})
    ${gap_pdcp_duration}    Evaluate    abs(${pdcp_counter_dict.cell2.M55352C01003}-${calc_cell2_M55352C01003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_pdcp_volume}<2000
    Run Keyword And Continue On Failure    Should Be True    ${gap_pdcp_duration}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01004}>0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01005}>0
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<600
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell3.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell3.M55349C04002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell3.M55352C01005}==0
    [Teardown]    Common Test Teardown

*** Keywords ***
Case Test Setup
    [Arguments]    ${delta_file}
    Delta Commission With SCF File    ${delta_file}
    ${status}    ${value}    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    Run Keyword Unless    '${status}'=='PASS'    Suite Setup Start WTS And Check OnAir Without Workaround
    ...    wts_cfg_file=CB010240_A_SA_NSA_FR1_PMQAP.cfg
    Common Test Setup
