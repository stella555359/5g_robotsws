*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONFIG_PARAM}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
...               AND    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1
Suite Teardown    Common Suite Teardown    debug
Test Setup        Common Test Setup
Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_qiqluo
...               SBTS00    CN1_SQ6    CB010240
Resource          ./Resources/CB010240_resource.robot

*** Variables ***
${SWCONFIG_PARAM}                0x580497=1;0x57000B=0xFFFFEEF0;0x570029=0;0x570030=1;0x5B0613=1;0x10040=1;0x1003F=1
${SCF_PATH}                      ${CURDIR}/Config
${FULL_SCF}                      CB010240_A_SA_FR1_PMQAP.xml
${IPHY_FILE}                     ${CURDIR}/Resources/wts/iphy_4F_2T_BOO_LOO.xml
${WTS_LOCAL}                     ${CURDIR}/Resources/wts
${WTS_CFG}                       CB010240_A_SA_FR1_PMQAP.cfg
${WTS_DIR}                       /opt/wts/latest
${DL_BIG_DATA}                   500
${DL_MEDIUM_DATA}                100
${DL_SMALL_DATA}                 3
${EXP_SMALL_DL_TPUT}             1
${EXP_DL_TPUT}                   10
${EXP_ZERO_TPUT}                 0
@{EXP_DL_TPUT_LIST}              10    10    10
@{EXP_SMALL_TPUT_LIST}           1    0    0
@{EXP_ZERO_TPUT_LIST}            0    0    0
@{NONCA_UE_ID_LIST}              1    2    5
@{3F_UE_ID_LIST}                 3    4
@{3F_SCELL_PHYSICALID_LIST}      ${3F_SCELL_PHYSICALID_1}    ${3F_SCELL_PHYSICALID_2}
@{3F_SCELL_PHYSICALID_1}         51    54
@{3F_SCELL_PHYSICALID_2}         51    54
@{2F1T_SCELL_PHYSICALID_LIST}    50    51
${DL_BLER}                       100,100,100,100,100,100,100,100
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
&{COUNTER_INFO_RLC_PMQAP2_1}       cell_id=1    MO_name=NRPMQAP-2/HRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
&{COUNTER_INFO_RLC_PMQAP2_2}       cell_id=2    MO_name=NRPMQAP-2/HRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
&{COUNTER_INFO_RLC_PMQAP2_3}       cell_id=3    MO_name=NRPMQAP-2/HRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
&{COUNTER_INFO_RLC_PMQAP2_5}       cell_id=5    MO_name=NRPMQAP-2/HRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
@{PDCP_PM_LIST}                   M55352C01002    M55352C01003    M55352C01004    M55352C01005
&{COUNTER_INFO_PDCP_1}            cell_id=1    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
&{COUNTER_INFO_PDCP_2}            cell_id=2    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
&{COUNTER_INFO_PDCP_3}            cell_id=3    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
&{COUNTER_INFO_PDCP_5}            cell_id=5    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
@{PM_COUNTER_LIST}                @{MAC_PM_LIST}    @{RLC_PM_LIST}    @{RLC_PMQAP_PM_LIST}    #@{PDCP_PM_LIST}
@{MAC_COUNTER_INFO_LIST}          ${COUNTER_INFO_MAC_1}    ${COUNTER_INFO_MAC_2}    ${COUNTER_INFO_MAC_3}    ${COUNTER_INFO_MAC_5}
@{RLC_COUNTER_INFO_LIST}          ${COUNTER_INFO_RLC_1}    ${COUNTER_INFO_RLC_2}    ${COUNTER_INFO_RLC_3}    ${COUNTER_INFO_RLC_5}
@{RLC_PMQAP_COUNTER_INFO_LIST}    ${COUNTER_INFO_RLC_PMQAP_1}    ${COUNTER_INFO_RLC_PMQAP_2}    ${COUNTER_INFO_RLC_PMQAP_3}
...                               ${COUNTER_INFO_RLC_PMQAP_5}
@{RLC_PMQAP2_COUNTER_INFO_LIST}    ${COUNTER_INFO_RLC_PMQAP2_1}    ${COUNTER_INFO_RLC_PMQAP2_2}    ${COUNTER_INFO_RLC_PMQAP2_3}
...                               ${COUNTER_INFO_RLC_PMQAP2_5}
${cell1_counter_path}            PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${cell2_counter_path}            PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
${cell3_counter_path}            PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
${cell5_counter_path}            PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
@{L2STREAM_COMPONENT_CONFIG}     &{TTITRACE_CONFIG_L2HIPDCP}    &{TTITRACE_CONFIG_L2HIRLC}    &{TTITRACE_CONFIG_L2LO}

*** Test Cases ***
CB010240_ET_A_B3_301_3F_3F_NonCA_Big_Volume_PMQAP_Profiles_MultiUE_SA_FR1
    SA Multi NonCA UE Attach    ${NONCA_UE_ID_LIST}
    SA Multi UE Attach With Scell Blind Addition    ${3F_UE_ID_LIST}    ${3F_SCELL_PHYSICALID_LIST}    3
    ${CRNTI_UE5}    Get Crnti From Egate Log    5
    Wait Until PM Counter Update
    Delete RD BTS Counter xml
    Start Ttitrace With Streaming Mode
    SA Multi UE Start DL Traffic    ${NONCA_UE_ID_LIST}    ${DL_BIG_DATA}
    SA Multi UE Start DL Traffic    ${3F_UE_ID_LIST}    ${DL_BIG_DATA}
    Sleep    10s    reason=Wait For DL Transmission
    SA Check NonCA Multi UE Cell Dl Tput On Target    ${NONCA_UE_ID_LIST}    ${EXP_DL_TPUT_LIST}
    Check Multi UE DLCA Cell L1 Tput    ${3F_UE_ID_LIST}    ${EXP_DL_TPUT_LIST}    3
    SA Multi UE Stop DL Traffic    ${NONCA_UE_ID_LIST}
    SA Multi UE Stop DL Traffic    ${3F_UE_ID_LIST}
    Wait Until Keyword Succeeds    1min    3s    SA Check NonCA Multi UE Cell Dl TPut Equal To Target
    ...    ${NONCA_UE_ID_LIST}    ${EXP_ZERO_TPUT_LIST}
    Wait Until Keyword Succeeds    1min    3s    Check Multi UE DLCA Cell L1 Tput
    ...    ${3F_UE_ID_LIST}    ${EXP_ZERO_TPUT_LIST}    3
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    SA 5G Detach    ${3F_UE_ID_LIST[0]}
    SA 5G Detach    ${3F_UE_ID_LIST[1]}
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${rlc_pmqap2_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP2_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${calc_cell1_m55349c03002}    ${calc_cell1_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${True}    3F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C03002}-${calc_cell1_m55349c03002})
    ${gap_cell1_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C04002}-${calc_cell1_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00002}==${RLC_COUNTER_dict.cell1.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00003}==${RLC_COUNTER_dict.cell1.M55349C04002}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    ${calc_cell2_m55349c03002}    ${calc_cell2_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${False}    3F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C03002}-${calc_cell2_m55349c03002})
    ${gap_cell2_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C04002}-${calc_cell2_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00002}==${RLC_COUNTER_dict.cell2.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00003}==${RLC_COUNTER_dict.cell2.M55349C04002}
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    ${calc_cell3_m55349c03002}    ${calc_cell3_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${False}    3F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C03002}-${calc_cell3_m55349c03002})
    ${gap_cell3_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C04002}-${calc_cell3_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00002}==${RLC_COUNTER_dict.cell3.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00003}==${RLC_COUNTER_dict.cell3.M55349C04002}
    ${calc_cell5_m55309c00002}    ${calc_cell5_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    54    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell5_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell5.M55309C00002}-${calc_cell5_m55309c00002})
    ${gap_cell5_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell5.M55309C00003}-${calc_cell5_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55309c00003}<${exp_gap}
    ${calc_cell5_m55349c03002}    ${calc_cell5_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    54    FR1_FDD    ${False}    3F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell5_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell5.M55349C03002}-${calc_cell5_m55349c03002})
    ${gap_cell5_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell5.M55349C04002}-${calc_cell5_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP2_COUNTER_dict.cell5.M55353C00002}==${RLC_COUNTER_dict.cell5.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP2_COUNTER_dict.cell5.M55353C00003}==${RLC_COUNTER_dict.cell5.M55349C04002}
    [Teardown]    Run Keywords    SA Multi UE Detach    ${NONCA_UE_ID_LIST}
    ...    AND    Common Test Teardown

CB010240_ET_A_B3_304_3F_3F_Small_Volume_PMQAP_Profiles_MultiUE_SA_FR1
    SA Multi NonCA UE Attach    ${NONCA_UE_ID_LIST}
    SA Multi UE Attach With Scell Blind Addition    ${3F_UE_ID_LIST}    ${3F_SCELL_PHYSICALID_LIST}    3
    ${CRNTI_UE5}    Get Crnti From Egate Log    5
    Wait Until PM Counter Update
    Delete RD BTS Counter xml
    Start Ttitrace With Streaming Mode
    SA Multi UE Start DL Traffic    ${NONCA_UE_ID_LIST}    ${DL_SMALL_DATA}
    SA Multi UE Start DL Traffic    ${3F_UE_ID_LIST}    ${DL_SMALL_DATA}
    Sleep    10s    reason=Wait For DL Transmission
    SA Check NonCA Multi UE Cell Dl Tput On Target    ${NONCA_UE_ID_LIST}    ${EXP_SMALL_TPUT_LIST}
    Check Multi UE DLCA Cell L1 Tput    ${3F_UE_ID_LIST}    ${EXP_SMALL_TPUT_LIST}    3
    SA Multi UE Stop DL Traffic    ${NONCA_UE_ID_LIST}
    SA Multi UE Stop DL Traffic    ${3F_UE_ID_LIST}
    Wait Until Keyword Succeeds    1min    3s    SA Check NonCA Multi UE Cell Dl TPut Equal To Target
    ...    ${NONCA_UE_ID_LIST}    ${EXP_ZERO_TPUT_LIST}
    Wait Until Keyword Succeeds    1min    3s    Check Multi UE DLCA Cell L1 Tput
    ...    ${3F_UE_ID_LIST}    ${EXP_ZERO_TPUT_LIST}    3
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    SA 5G Detach    ${3F_UE_ID_LIST[0]}
    SA 5G Detach    ${3F_UE_ID_LIST[1]}
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${rlc_pmqap2_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP2_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${calc_cell1_m55349c03002}    ${calc_cell1_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${True}    3F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C03002}-${calc_cell1_m55349c03002})
    ${gap_cell1_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C04002}-${calc_cell1_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00002}==${RLC_COUNTER_dict.cell1.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00003}==${RLC_COUNTER_dict.cell1.M55349C04002}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    ${calc_cell2_m55349c03002}    ${calc_cell2_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${False}    3F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C03002}-${calc_cell2_m55349c03002})
    ${gap_cell2_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C04002}-${calc_cell2_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00002}==${RLC_COUNTER_dict.cell2.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00003}==${RLC_COUNTER_dict.cell2.M55349C04002}
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    ${calc_cell3_m55349c03002}    ${calc_cell3_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${False}    3F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C03002}-${calc_cell3_m55349c03002})
    ${gap_cell3_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C04002}-${calc_cell3_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00002}==${RLC_COUNTER_dict.cell3.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00003}==${RLC_COUNTER_dict.cell3.M55349C04002}
    ${calc_cell5_m55309c00002}    ${calc_cell5_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    54    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell5_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell5.M55309C00002}-${calc_cell5_m55309c00002})
    ${gap_cell5_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell5.M55309C00003}-${calc_cell5_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55309c00003}<${exp_gap}
    ${calc_cell5_m55349c03002}    ${calc_cell5_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    54    FR1_FDD    ${False}    3F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell5_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell5.M55349C03002}-${calc_cell5_m55349c03002})
    ${gap_cell5_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell5.M55349C04002}-${calc_cell5_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP2_COUNTER_dict.cell5.M55353C00002}==${RLC_COUNTER_dict.cell5.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP2_COUNTER_dict.cell5.M55353C00003}==${RLC_COUNTER_dict.cell5.M55349C04002}
    [Teardown]    Run Keywords    SA Multi UE Detach    ${NONCA_UE_ID_LIST}
    ...    AND    Common Test Teardown

CB010240_ET_A_B3_306_3F_3F_NonCA_Big_Volume_Retransmissions_PMQAP_Profiles_MultiUE_SA_FR1
    SA Multi NonCA UE Attach    ${NONCA_UE_ID_LIST}
    SA Multi UE Attach With Scell Blind Addition    ${3F_UE_ID_LIST}    ${3F_SCELL_PHYSICALID_LIST}    3
    ${CRNTI_UE5}    Get Crnti From Egate Log    5
    Wait Until PM Counter Update
    Delete RD BTS Counter xml
    Start Ttitrace With Streaming Mode
    SA Multi UE Start DL Traffic    ${NONCA_UE_ID_LIST}    ${DL_BIG_DATA}
    SA Multi UE Start DL Traffic    ${3F_UE_ID_LIST}    ${DL_BIG_DATA}
    Set BLER Testmode    1    ${EMPTY}    ${DL_BLER}
    CUDU L2 Send Action To GNB    1    bler    activate    1    0
    CUDU L2 Send Action To GNB    2    bler    activate    1    0
    CUDU L2 Send Action To GNB    3    bler    activate    1    1
    CUDU L2 Send Action To GNB    4    bler    activate    1    1
    CUDU L2 Send Action To GNB    5    bler    activate    1    0
    Sleep    10s    reason=Wait For DL Transmission
    SA Check NonCA Multi UE Cell Dl Tput On Target    ${NONCA_UE_ID_LIST}    ${EXP_DL_TPUT_LIST}
    Check Multi UE DLCA Cell L1 Tput    ${3F_UE_ID_LIST}    ${EXP_DL_TPUT_LIST}    3
    SA Multi UE Stop DL Traffic    ${NONCA_UE_ID_LIST}
    SA Multi UE Stop DL Traffic    ${3F_UE_ID_LIST}
    Wait Until Keyword Succeeds    1min    3s    SA Check NonCA Multi UE Cell Dl TPut Equal To Target
    ...    ${NONCA_UE_ID_LIST}    ${EXP_ZERO_TPUT_LIST}
    Wait Until Keyword Succeeds    1min    3s    Check Multi UE DLCA Cell L1 Tput
    ...    ${3F_UE_ID_LIST}    ${EXP_ZERO_TPUT_LIST}    3
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    SA 5G Detach    ${3F_UE_ID_LIST[0]}
    SA 5G Detach    ${3F_UE_ID_LIST[1]}
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${rlc_pmqap2_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP2_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${calc_cell1_m55349c03002}    ${calc_cell1_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${True}    3F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C03002}-${calc_cell1_m55349c03002})
    ${gap_cell1_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C04002}-${calc_cell1_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00002}==${RLC_COUNTER_dict.cell1.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00003}==${RLC_COUNTER_dict.cell1.M55349C04002}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    ${calc_cell2_m55349c03002}    ${calc_cell2_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${False}    3F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C03002}-${calc_cell2_m55349c03002})
    ${gap_cell2_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C04002}-${calc_cell2_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00002}==${RLC_COUNTER_dict.cell2.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00003}==${RLC_COUNTER_dict.cell2.M55349C04002}
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    ${calc_cell3_m55349c03002}    ${calc_cell3_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${False}    3F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C03002}-${calc_cell3_m55349c03002})
    ${gap_cell3_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C04002}-${calc_cell3_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00002}==${RLC_COUNTER_dict.cell3.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00003}==${RLC_COUNTER_dict.cell3.M55349C04002}
    ${calc_cell5_m55309c00002}    ${calc_cell5_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    54    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell5_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell5.M55309C00002}-${calc_cell5_m55309c00002})
    ${gap_cell5_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell5.M55309C00003}-${calc_cell5_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55309c00003}<${exp_gap}
    ${calc_cell5_m55349c03002}    ${calc_cell5_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    54    FR1_FDD    ${False}    3F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell5_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell5.M55349C03002}-${calc_cell5_m55349c03002})
    ${gap_cell5_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell5.M55349C04002}-${calc_cell5_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP2_COUNTER_dict.cell5.M55353C00002}==${RLC_COUNTER_dict.cell5.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP2_COUNTER_dict.cell5.M55353C00003}==${RLC_COUNTER_dict.cell5.M55349C04002}
    [Teardown]    Run Keywords    SA Multi UE Detach    ${NONCA_UE_ID_LIST}
    ...    AND    Common Test Teardown

