*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONFIG_PARAM}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
...               AND    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_qiqluo
...               SBTS00    CN1_SQ6    CB010240
# Resource        ./../CUDU_L2/common_setup_teardown.robot
# Library         ./Resources/CB010240_check.py
Resource          ./Resources/CB010240_resource.robot

*** Variables ***
${SWCONFIG_PARAM}                 0x580497=1;0x57000B=0xFFFFEEF0;0x570030=1;0x5B0613=1;0x10040=1;0x1003F=1
${SCF_PATH}                       ${CURDIR}/Config
${FULL_SCF}                       CB010240_A_SA_FR1_Swap.xml
${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4F_2T_BOO_LOO_Swap.xml
${WTS_LOCAL}                      ${CURDIR}/Resources/wts
${WTS_CFG}                        CB010240_A_SA_FR1_Swap.cfg
${DL_BIG_DATA}                    250
${EXP_DL_TPUT}                    5
${EXP_ZERO_TPUT}                  0
@{EXP_DL_TPUT_LIST}               3    3    3
@{EXP_ZERO_TPUT_LIST}             0    0
@{CA_UE_LIST_1}                   1    2
@{CA_UE_LIST_2}                   3    4
@{CA_UE_LIST_3}                   5    6
@{PCELL_ID_LIST}                  52    52
@{SCELL_PHYSICALID_1}             50    51
@{SCELL_PHYSICALID_2}             50    51
@{SCELL_PHYSICALID_LIST}          ${SCELL_PHYSICALID_1}    ${SCELL_PHYSICALID_2}
${DL_BLER}                        100,100,100,100,100,100,100,100
${A1THRESHOLD}                    105
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
@{PM_COUNTER_LIST}                @{MAC_PM_LIST}    @{RLC_PM_LIST}    @{RLC_PMQAP_PM_LIST}    #@{PDCP_PM_LIST}
@{MAC_COUNTER_INFO_LIST}          ${COUNTER_INFO_MAC_1}    ${COUNTER_INFO_MAC_2}    ${COUNTER_INFO_MAC_3}    ${COUNTER_INFO_MAC_5}
@{RLC_COUNTER_INFO_LIST}          ${COUNTER_INFO_RLC_1}    ${COUNTER_INFO_RLC_2}    ${COUNTER_INFO_RLC_3}    ${COUNTER_INFO_RLC_5}
@{RLC_PMQAP_COUNTER_INFO_LIST}    ${COUNTER_INFO_RLC_PMQAP_1}    ${COUNTER_INFO_RLC_PMQAP_2}    ${COUNTER_INFO_RLC_PMQAP_3}
...                               ${COUNTER_INFO_RLC_PMQAP_5}
#_@{PDCP_COUNTER_INFO_LIST}       ${COUNTER_INFO_PDCP_1}    ${COUNTER_INFO_PDCP_2}    ${COUNTER_INFO_PDCP_3}    ${COUNTER_INFO_PDCP_5}
${CELL1_COUNTER_PATH}             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${CELL2_COUNTER_PATH}             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
${CELL3_COUNTER_PATH}             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
${CELL5_COUNTER_PATH}             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-5
@{L2STREAM_COMPONENT_CONFIG}      &{ttitrace_config_l2hipdcp}    &{ttitrace_config_l2hirlc}    &{ttitrace_config_l2lo}

*** Test Cases ***
CB010240_ET_A_B15_1501_2F1T_Scell_Release_Big_Volume_MultiUE_SA_FR1
    SA Multi UE Attach With Scell A1 Addition    ${CA_UE_LIST_1}    ${PCELL_ID_LIST}    ${SCELL_PHYSICALID_LIST}    ${A1THRESHOLD}    3
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    SA Multi UE Start DL Traffic    ${CA_UE_LIST_1}    ${DL_BIG_DATA}
    Sleep    10s    reason=Wait For DL Transmission
    Check UE DL All Pcell Scell TP On Target For Single UE    ${CA_UE_LIST_1[0]}    ${EXP_DL_TPUT_LIST}    3
    Check UE DL All Pcell Scell TP On Target For Single UE    ${CA_UE_LIST_1[1]}    ${EXP_DL_TPUT_LIST}    3
    Trigger A2 Scell Release    ue_id=${CA_UE_LIST_1[0]}    scell_id=1    meas_id=2
    Trigger A2 Scell Release    ue_id=${CA_UE_LIST_1[1]}    scell_id=2    meas_id=3
    Sleep    5s
    SA Stop Data Traffic Internal    ${CA_UE_LIST_1[0]}    1
    SA Stop Data Traffic Internal    ${CA_UE_LIST_1[1]}    1
    Wait Until Keyword Succeeds    1min    3s    Check UE DL All Pcell Scell TP Equal To Target For Single UE
    ...    ${CA_UE_LIST_1[0]}    ${EXP_ZERO_TPUT_LIST}    2
    Wait Until Keyword Succeeds    1min    3s    Check UE DL All Pcell Scell TP Equal To Target For Single UE
    ...    ${CA_UE_LIST_1[1]}    ${EXP_ZERO_TPUT_LIST}    2
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    SA 5G Detach    ${CA_UE_LIST_1[0]}
    SA 5G Detach    ${CA_UE_LIST_1[1]}
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${calc_cell1_m55349c03002}    ${calc_cell1_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${False}    1T2F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C03002}-${calc_cell1_m55349c03002})
    ${gap_cell1_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C04002}-${calc_cell1_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c04002}<${exp_gap}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    ${calc_cell2_m55349c03002}    ${calc_cell2_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${False}    1T2F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C03002}-${calc_cell2_m55349c03002})
    ${gap_cell2_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C04002}-${calc_cell2_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c04002}<${exp_gap}
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    ${calc_cell3_m55349c03002}    ${calc_cell3_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${True}    1T2F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C03002}-${calc_cell3_m55349c03002})
    ${gap_cell3_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C04002}-${calc_cell3_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00002}==${RLC_COUNTER_dict.cell3.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00003}==${RLC_COUNTER_dict.cell3.M55349C04002}
    [Teardown]    Common Test Teardown

CB010240_ET_A_B15_1502_2F1T_Scell_Swap_Big_Volume_MultiUE_SA_FR1
    SA Multi UE Attach With Scell A1 Addition    ${CA_UE_LIST_2}    ${PCELL_ID_LIST}    ${SCELL_PHYSICALID_LIST}    ${A1THRESHOLD}    3
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    SA Multi UE Start DL Traffic    ${CA_UE_LIST_2}    ${DL_BIG_DATA}
    Sleep    10s    reason=Wait For DL Transmission
    Check UE DL All Pcell Scell TP On Target For Single UE    ${CA_UE_LIST_2[0]}    ${EXP_DL_TPUT_LIST}    3
    Check UE DL All Pcell Scell TP On Target For Single UE    ${CA_UE_LIST_2[1]}    ${EXP_DL_TPUT_LIST}    3
    Trigger A6 Event For Scell Swap    ue_id=${CA_UE_LIST_2[0]}    phycell_id=54    scell_index=2    scell_rsrp=55    nrsrp_nr=105    meas_id=5
    Trigger A6 Event For Scell Swap    ue_id=${CA_UE_LIST_2[1]}    phycell_id=54    scell_index=2    scell_rsrp=55    nrsrp_nr=105    meas_id=5
    Sleep    5s
    SA Stop Data Traffic Internal    ${CA_UE_LIST_2[0]}    1
    SA Stop Data Traffic Internal    ${CA_UE_LIST_2[1]}    1
    Wait Until Keyword Succeeds    1min    3s    Check UE DL All Pcell Scell TP Equal To Target For Single UE
    ...    ${CA_UE_LIST_2[0]}    ${EXP_ZERO_TPUT_LIST}    2
    Wait Until Keyword Succeeds    1min    3s    Check UE DL All Pcell Scell TP Equal To Target For Single UE
    ...    ${CA_UE_LIST_2[1]}    ${EXP_ZERO_TPUT_LIST}    2
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    SA 5G Detach    ${CA_UE_LIST_2[0]}
    SA 5G Detach    ${CA_UE_LIST_2[1]}
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${calc_cell1_m55349c03002}    ${calc_cell1_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${False}    1T2F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C03002}-${calc_cell1_m55349c03002})
    ${gap_cell1_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C04002}-${calc_cell1_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c04002}<${exp_gap}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    ${calc_cell2_m55349c03002}    ${calc_cell2_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${False}    1T2F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C03002}-${calc_cell2_m55349c03002})
    ${gap_cell2_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C04002}-${calc_cell2_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c04002}<${exp_gap}
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    ${calc_cell3_m55349c03002}    ${calc_cell3_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${True}    1T2F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C03002}-${calc_cell3_m55349c03002})
    ${gap_cell3_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C04002}-${calc_cell3_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00002}==${RLC_COUNTER_dict.cell3.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00003}==${RLC_COUNTER_dict.cell3.M55349C04002}
    [Teardown]    Common Test Teardown

CB010240_ET_A_B15_1503_2F1T_PCell_Change_Big_Volume_MultiUE_SA_FR1
    SA Multi UE Attach With Scell A1 Addition    ${CA_UE_LIST_3}    ${PCELL_ID_LIST}    ${SCELL_PHYSICALID_LIST}    ${A1THRESHOLD}    3
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    SA Multi UE Start DL Traffic    ${CA_UE_LIST_3}    ${DL_BIG_DATA}
    Sleep    10s    reason=Wait For DL Transmission
    Check UE DL All Pcell Scell TP On Target For Single UE    ${CA_UE_LIST_3[0]}    ${EXP_DL_TPUT_LIST}    3
    Check UE DL All Pcell Scell TP On Target For Single UE    ${CA_UE_LIST_3[1]}    ${EXP_DL_TPUT_LIST}    3
    Trigger A2 Event For Pcell Change    ue_id=${CA_UE_LIST_3[0]}    srsrp_nr=70    srsrq_nr=60    meas_id=4    newpcell=50
    Trigger A2 Event For Pcell Change    ue_id=${CA_UE_LIST_3[1]}    srsrp_nr=70    srsrq_nr=60    meas_id=4    newpcell=50
    Sleep    5s
    SA Stop Data Traffic Internal    ${CA_UE_LIST_3[0]}    1
    SA Stop Data Traffic Internal    ${CA_UE_LIST_3[1]}    1
    Wait Until Keyword Succeeds    1min    3s    Check UE DL All Pcell Scell TP Equal To Target For Single UE
    ...    ${CA_UE_LIST_3[0]}    ${EXP_ZERO_TPUT}    1
    Wait Until Keyword Succeeds    1min    3s    Check UE DL All Pcell Scell TP Equal To Target For Single UE
    ...    ${CA_UE_LIST_3[1]}    ${EXP_ZERO_TPUT}    1
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    SA 5G Detach    ${CA_UE_LIST_3[0]}
    SA 5G Detach    ${CA_UE_LIST_3[1]}
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${calc_cell1_m55349c03002}    ${calc_cell1_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${False}    1T2F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C03002}-${calc_cell1_m55349c03002})
    ${gap_cell1_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C04002}-${calc_cell1_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c04002}<${exp_gap}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    ${calc_cell2_m55349c03002}    ${calc_cell2_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${False}    1T2F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C03002}-${calc_cell2_m55349c03002})
    ${gap_cell2_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell2.M55349C04002}-${calc_cell2_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55349c04002}<${exp_gap}
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    ${calc_cell3_m55349c03002}    ${calc_cell3_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${True}    1T2F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C03002}-${calc_cell3_m55349c03002})
    ${gap_cell3_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C04002}-${calc_cell3_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00002}==${RLC_COUNTER_dict.cell3.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55353C00003}==${RLC_COUNTER_dict.cell3.M55349C04002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00002}==${RLC_COUNTER_dict.cell1.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00003}==${RLC_COUNTER_dict.cell1.M55349C04002}
    [Teardown]    Common Test Teardown

