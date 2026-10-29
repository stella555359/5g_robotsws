*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONFIG_PARAM}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
...               AND    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Force Tags        CLOUD_5G_I_BOO_AP_LOO    RAN_5G_TDD    RAN_5G    Owner_qiqluo
...               SBTS00    CN1_SQ6    CB010240
Resource          ./Resources/CB010240_resource.robot

*** Variables ***
${SWCONFIG_PARAM}                 0x580497=1;0x57000B=0xFFFFEEF0;0x570030=1;0x5B0613=1;0x10040=1;0x1003F=1;0x5A0619=1;0x5A0608=1;0x890003=1
${SCF_PATH}                       ${CURDIR}/Config
${FULL_SCF}                       CB010240_A_SA_FR1_Discard_AutoDelete.xml
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
CB010240_ET_A_B2_203_3F_MultiUE_AutoDelete_SA_FR1
    [Setup]    Run Keywords    Common Test Setup
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    SA Multi UE Attach With Scell Blind Addition    ${3F_UE_ID_LIST}    ${3F_SCELL_PHYSICALID_LIST}    3
    SA Multi UE Start DL Traffic    ${3F_UE_ID_LIST}    250
    Check Multi UE DLCA Cell L1 Tput    ${3F_UE_ID_LIST}    ${EXP_DL_TPUT_LIST}    3
    SA Multi UE Stop DL Traffic    ${3F_UE_ID_LIST}
    Sleep    30s    reason=wait for l2lo trace log
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming
    Sleep    10s    reason=wait for l2lo trace log
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${pdcp_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${PDCP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell1.M55352C01005}==0
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00003}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict.cell2.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict.cell2.M55349C04002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell2.M55352C01005}==0
    ${calc_cell5_m55309c00002}    ${calc_cell5_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    54    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell5_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell5.M55309C00002}-${calc_cell5_m55309c00002})
    ${gap_cell5_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell5.M55309C00003}-${calc_cell5_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell5.M55353C00002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell5.M55353C00003}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict.cell5.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict.cell5.M55349C04002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01002}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01003}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01004}==0
    Run Keyword And Continue On Failure    Should Be True    ${pdcp_counter_dict.cell5.M55352C01005}==0
    ${calc_cell1_m55349c03002}    ${calc_cell1_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${True}    3F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C03002}-${calc_cell1_m55349c03002})
    ${gap_cell1_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C04002}-${calc_cell1_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c04002}<${exp_gap}
    [Teardown]    Common Test Teardown

