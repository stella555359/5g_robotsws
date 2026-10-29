*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}    swconfig_param=${SWCONFIG_PARAM}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
...               AND    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Force Tags        CLOUD_5G_I_BOO_AP_LOO    RAN_5G_TDD    RAN_5G    Owner_qiqluo
...               SBTS00    CN1_SQ6    CB010240
Resource          ./Resources/CB010240_resource.robot

*** Variables ***
${SWCONFIG_PARAM}                 0x580497=1;0x57000B=0xFFFFEEF0;0x570030=1;0x5B0613=1;0x10040=1;0x1003F=1;0x5A0619=1;0x5A0608=1;0x890003=1
${SCF_PATH}                       ${CURDIR}/Config
${FULL_SCF}                       CB010240_A_SA_FR1.xml
${DELTA_SCF_1101_DEACTIVE}        DELTA_SCF_1101_Deactive.json
${DELTA_SCF_1101_ACTIVE}          DELTA_SCF_1101_Active.json
${DELTA_SCF_1102_DEACTIVE}        DELTA_SCF_1102_Deactive.json
${DELTA_SCF_1102_ACTIVE}          DELTA_SCF_1102_Active.json
${DELTA_SCF_1108_ACTIVE}          DELTA_SCF_1108_Active.json
${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4F_2T_BOO_LOO.xml
${WTS_LOCAL}                      ${CURDIR}/Resources/wts
${WTS_CFG}                        CB010240_A_SA_FR1.cfg
${DL_BIG_DATA}                    500
${DL_MEDIUM_DATA}                 50
${DL_TINY_DATA}                   1
${DL_SMALL_DATA}                  3
${EXP_SMALL_DL_TPUT}              1
${EXP_TINY_DL_TPUT}               0.8
${EXP_DL_TPUT}                    5
${EXP_ZERO_TPUT}                  0
@{EXP_DL_TPUT_LIST}               3    3    3
@{EXP_ZERO_TPUT_LIST}             0    0    0
${NONCA_UE_ID}                    1
${NONCA_UE_ID_2}                  5
${NONCA_2_BEARER_UE_ID}           2
@{NONCA_UE_ID_LIST}               1    2    5
${3F_UE_ID}                       3
${2F1T_UE_ID}                     4
@{3F_SCELL_PHYSICALID_LIST}       51    54
@{2F1T_SCELL_PHYSICALID_LIST}     50    51
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
CB010240 ET A B11 1107 NonCA Big Volume MultiUE FDM SA FR1
    ${crnti_ue3}    Get Crnti From Egate Log    3
    ${crnti_ue4}    Get Crnti From Egate Log    4
    SA Multi NonCA UE Attach    ${NONCA_UE_ID_LIST}
    SA 5G CA Attach    ${3F_UE_ID}
    Check SA All Scell PhysicalID With UE ID    ${3F_UE_ID}    ${3f_scell_physicalid_list}    3
    SA 5G CA Attach    ${2F1T_UE_ID}
    Check SA All Scell PhysicalID With UE ID    ${2F1T_UE_ID}    ${2f1t_scell_physicalid_list}    3
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    SA Multi UE Start DL Traffic    ${NONCA_UE_ID_LIST}    ${DL_BIG_DATA}
    SA Start DL Traffic Internal    ${3F_UE_ID}    1    ${DL_BIG_DATA}
    SA Start DL Traffic Internal    ${2F1T_UE_ID}    1    ${DL_BIG_DATA}
    Sleep    10s    reason=Wait For DL Transmission
    SA Check NonCA Multi UE Cell Dl Tput On Target    ${NONCA_UE_ID_LIST}    ${EXP_DL_TPUT_LIST}
    Check UE DL All Pcell Scell TP On Target For Single UE    ${3F_UE_ID}    ${exp_dl_tput_list}    3
    Check UE DL All Pcell Scell TP On Target For Single UE    ${2F1T_UE_ID}    ${exp_dl_tput_list}    3
    SA Multi UE Stop DL Traffic    ${NONCA_UE_ID_LIST}
    SA Stop Data Traffic Internal    ${3F_UE_ID}    1
    SA Stop Data Traffic Internal    ${2F1T_UE_ID}    1
    Wait Until Keyword Succeeds    2min    3s    SA Check NonCA Multi UE Cell Dl TPut Equal To Target
    ...    ${NONCA_UE_ID_LIST}    ${EXP_ZERO_TPUT_LIST}
    Wait Until Keyword Succeeds    2min    3s    Check UE DL All Pcell Scell TP Equal To Target For Single UE
    ...    ${3F_UE_ID}    ${exp_zero_tput_list}    3
    Wait Until Keyword Succeeds    2min    3s    Check UE DL All Pcell Scell TP Equal To Target For Single UE
    ...    ${2F1T_UE_ID}    ${exp_zero_tput_list}    3
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    SA Multi UE Detach    ${NONCA_UE_ID_LIST}
    SA 5G Detach    ${2F1T_UE_ID}
    SA 5G Detach    ${3F_UE_ID}
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
    ...    50    FR1_FDD    ${True}    3F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv    ${crnti_ue4}
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
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    ${calc_cell3_m55349c03002}    ${calc_cell3_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${True}    1T2F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv    ${crnti_ue3}
    ${gap_cell3_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C03002}-${calc_cell3_m55349c03002})
    ${gap_cell3_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C04002}-${calc_cell3_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c04002}<${exp_gap}
    [Teardown]    Common Test Teardown

