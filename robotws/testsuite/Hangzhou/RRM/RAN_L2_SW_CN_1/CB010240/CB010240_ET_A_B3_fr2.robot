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
${SWCONFIG_PARAM}               0x580497=1;0x57000B=0xFFFFEEF0;0x570029=0;0x570030=1;0x5B0613=1;0x10040=1;0x1003F=1
${SCF_PATH}                     ${CURDIR}/Config
${FULL_SCF}                     CB010240_A_NSA_FR2_PMQAP.xml
${IPHY_FILE}                    ${CURDIR}/Resources/wts/iphy_4T_LO_LO.xml
${WTS_LOCAL}                    ${CURDIR}/Resources/wts
${DELTA_SCF_303_ACTIVE}         DELTA_SCF_303_Active.json
${WTS_CFG}                      CB010240_A_NSA_FR2_PMQAP.cfg
${DL_BIG_DATA}                  500
${DL_MEDIUM_DATA}               100
${DL_SMALL_DATA}                3
${EXP_SMALL_DL_TPUT}            1
${EXP_DL_TPUT}                  10
${EXP_ZERO_TPUT}                0
@{EXP_DL_TPUT_LIST}             10    10    10
@{EXP_ZERO_TPUT_LIST}           0    0    0
@{EXP_SMALL_TPUT_LIST}          1    1    1
${NONCA_UE_ID_1}                12
${NONCA_UE_ID_2}                13
${NONCA_UE_ID_3}                14
${CA_UE_ID_1}                   11
${CA_UE_ID_2}                   15
${GNB_ID}                       2
${CELL_ID}                      1
${CELL_ID_2}                    2
${CELL_ID_3}                    3
${DEFAULT_BEARER_ID}            2
${NEW_BEARER_ID}                3
${DL_BLER}                      100,100,100,100,100,100,100,100
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
&{COUNTER_INFO_RLC_PMQAP2_1}       cell_id=1    MO_name=NRPMQAP-2/LRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
&{COUNTER_INFO_RLC_PMQAP2_2}       cell_id=2    MO_name=NRPMQAP-2/LRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
&{COUNTER_INFO_RLC_PMQAP2_3}       cell_id=3    MO_name=NRPMQAP-2/LRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
&{COUNTER_INFO_RLC_PMQAP2_4}       cell_id=4    MO_name=NRPMQAP-2/LRLCQ    counter_ids_list=${RLC_PMQAP_PM_LIST}
@{PDCP_PM_LIST}                   M55352C01002    M55352C01003    M55352C01004    M55352C01005
&{COUNTER_INFO_PDCP_1}            cell_id=1    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
&{COUNTER_INFO_PDCP_2}            cell_id=2    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
&{COUNTER_INFO_PDCP_3}            cell_id=3    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
&{COUNTER_INFO_PDCP_4}            cell_id=4    MO_name=NRPMQAP-1/PDCPQ    counter_ids_list=${PDCP_PM_LIST}
@{PM_COUNTER_LIST}                @{MAC_PM_LIST}    @{RLC_PM_LIST}    @{RLC_PMQAP_PM_LIST}    #@{PDCP_PM_LIST}
@{MAC_COUNTER_INFO_LIST}          ${COUNTER_INFO_MAC_1}    ${COUNTER_INFO_MAC_2}    ${COUNTER_INFO_MAC_3}    ${COUNTER_INFO_MAC_4}
@{RLC_COUNTER_INFO_LIST}          ${COUNTER_INFO_RLC_1}    ${COUNTER_INFO_RLC_2}    ${COUNTER_INFO_RLC_3}    ${COUNTER_INFO_RLC_4}
@{RLC_PMQAP_COUNTER_INFO_LIST}    ${COUNTER_INFO_RLC_PMQAP_1}    ${COUNTER_INFO_RLC_PMQAP_2}    ${COUNTER_INFO_RLC_PMQAP_3}
...                               ${COUNTER_INFO_RLC_PMQAP_4}
@{RLC_PMQAP2_COUNTER_INFO_LIST}    ${COUNTER_INFO_RLC_PMQAP2_1}    ${COUNTER_INFO_RLC_PMQAP2_2}    ${COUNTER_INFO_RLC_PMQAP2_3}
...                               ${COUNTER_INFO_RLC_PMQAP2_4}
${cell1_counter_path}            PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${cell2_counter_path}            PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
${cell3_counter_path}            PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
${cell4_counter_path}            PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
@{L2STREAM_COMPONENT_CONFIG}     &{TTITRACE_CONFIG_L2HIPDCP}    &{TTITRACE_CONFIG_L2HIRLC}    &{TTITRACE_CONFIG_L2LO}
${EXP_GAP}                       1500
@{LOG_NAME_LIST}                 btslog    x2pcap    snapshot    egatelog

*** Test Cases ***
CB010240_ET_A_B3_302_4T_4T_NonCA_Big_Volume_PMQAP_Profiles_MultiUE_NSA_FR2
    NSA LTE Attach    ${NONCA_UE_ID_1}
    NSA LTE Attach    ${NONCA_UE_ID_2}
    NSA LTE Attach    ${NONCA_UE_ID_3}
    NSA 5G Attach    ${NONCA_UE_ID_1}    ${GNB_ID}    ${CELL_ID}    ${DEFAULT_BEARER_ID}
    NSA 5G Attach    ${NONCA_UE_ID_2}    ${GNB_ID}    ${CELL_ID_2}    ${DEFAULT_BEARER_ID}
    NSA 5G Attach    ${NONCA_UE_ID_3}    ${GNB_ID}    ${CELL_ID_3}    ${DEFAULT_BEARER_ID}
    NSA LTE Attach    ${CA_UE_ID_1}
    NSA LTE Attach    ${CA_UE_ID_2}
    Serving Cell Index For 5G NR
    NSA 5G Attach    ${CA_UE_ID_1}    ${GNB_ID}    ${CELL_ID}    ${DEFAULT_BEARER_ID}
    NSA 5G Attach    ${CA_UE_ID_2}    ${GNB_ID}    ${CELL_ID}    ${DEFAULT_BEARER_ID}
    Set Value For CQI Testmode
    Wait Until PM Counter Update
    Delete RD BTS Counter xml
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NONCA_UE_ID_1}    ${DEFAULT_BEARER_ID}    ${DL_MEDIUM_DATA}
    NSA Start DL Traffic    ${NONCA_UE_ID_2}    ${DEFAULT_BEARER_ID}    ${DL_MEDIUM_DATA}
    NSA Start DL Traffic    ${NONCA_UE_ID_3}    ${DEFAULT_BEARER_ID}    ${DL_MEDIUM_DATA}
    NSA Start DL Traffic    ${CA_UE_ID_1}    ${DEFAULT_BEARER_ID}    ${DL_BIG_DATA}
    NSA Start DL Traffic    ${CA_UE_ID_2}    ${DEFAULT_BEARER_ID}    ${DL_BIG_DATA}
    Sleep    15s    reason=Wait For DL Transmission
    Check Scell Active Status    2    activated    pass
    Check Scell Active Status    3    activated    pass
    Check Scell Active Status    4    activated    pass
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_1}    ${DEFAULT_BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_2}    ${DEFAULT_BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_3}    ${DEFAULT_BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${CA_UE_ID_1}    ${DEFAULT_BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${CA_UE_ID_2}    ${DEFAULT_BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Stop Traffic    ${NONCA_UE_ID_1}    ${DEFAULT_BEARER_ID}
    NSA Stop Traffic    ${NONCA_UE_ID_2}    ${DEFAULT_BEARER_ID}
    NSA Stop Traffic    ${NONCA_UE_ID_3}    ${DEFAULT_BEARER_ID}
    NSA Stop Traffic    ${CA_UE_ID_1}    ${DEFAULT_BEARER_ID}
    NSA Stop Traffic    ${CA_UE_ID_2}    ${DEFAULT_BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NONCA_UE_ID_1}    ${DEFAULT_BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${CA_UE_ID_1}    ${DEFAULT_BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    NSA LTE Detach    ${CA_UE_ID_1}
    NSA LTE Detach    ${CA_UE_ID_2}
    NSA LTE Detach    ${NONCA_UE_ID_1}
    NSA LTE Detach    ${NONCA_UE_ID_2}
    NSA LTE Detach    ${NONCA_UE_ID_3}
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${rlc_pmqap2_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP2_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${calc_cell1_M55309C00036}    ${calc_cell1_M55309C00037}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log FR2
    ...    50    FR2_TDD    ${True}    4T    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_M55309C00036}    Evaluate    abs(${rlc_counter_dict.cell1.M55309C00036}-${calc_cell1_M55309C00036})
    ${gap_cell1_M55309C00037}    Evaluate    abs(${rlc_counter_dict.cell1.M55309C00037}-${calc_cell1_M55309C00037})
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55309C00036}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55309C00037}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00001}==${RLC_COUNTER_dict.cell1.M55309C00036}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00002}==${RLC_COUNTER_dict.cell1.M55309C00037}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00001}>0
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00002}>0
    Run Keyword And Continue On Failure    Should Be True
    ...     ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00001}==${RLC_PMQAP2_COUNTER_DICT.cell1.M55373C00001}
    Run Keyword And Continue On Failure    Should Be True
    ...     ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00002}==${RLC_PMQAP2_COUNTER_DICT.cell1.M55373C00002}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    ${calc_cell2_M55309C00036}    ${calc_cell2_M55309C00037}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log FR2
    ...    51    FR2_TDD    ${False}    4T    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_M55309C00036}    Evaluate    abs(${rlc_counter_dict.cell2.M55309C00036}-${calc_cell2_M55309C00036})
    ${gap_cell2_M55309C00037}    Evaluate    abs(${rlc_counter_dict.cell2.M55309C00037}-${calc_cell2_M55309C00037})
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_M55309C00036}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_M55309C00037}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00001}==${RLC_COUNTER_dict.cell2.M55309C00036}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00002}==${RLC_COUNTER_dict.cell2.M55309C00037}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00001}>0
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00002}>0
    Run Keyword And Continue On Failure    Should Be True
    ...    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00001}==${RLC_PMQAP2_COUNTER_DICT.cell2.M55373C00001}
    Run Keyword And Continue On Failure    Should Be True
    ...    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00002}==${RLC_PMQAP2_COUNTER_DICT.cell2.M55373C00002}
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    ${calc_cell3_M55309C00036}    ${calc_cell3_M55309C00037}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log FR2
    ...    52    FR2_TDD    ${False}    4T    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_M55309C00036}    Evaluate    abs(${rlc_counter_dict.cell3.M55309C00036}-${calc_cell3_M55309C00036})
    ${gap_cell3_M55309C00037}    Evaluate    abs(${rlc_counter_dict.cell3.M55309C00037}-${calc_cell3_M55309C00037})
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_M55309C00036}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_M55309C00037}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00001}==${RLC_COUNTER_dict.cell3.M55309C00036}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00002}==${RLC_COUNTER_dict.cell3.M55309C00037}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00001}>0
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00002}>0
    Run Keyword And Continue On Failure    Should Be True
    ...    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00001}==${RLC_PMQAP2_COUNTER_DICT.cell3.M55373C00001}
    Run Keyword And Continue On Failure    Should Be True
    ...    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00002}==${RLC_PMQAP2_COUNTER_DICT.cell3.M55373C00002}
    ${calc_cell4_m55309c00002}    ${calc_cell4_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    53    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell4_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell4.M55309C00002}-${calc_cell4_m55309c00002})
    ${gap_cell4_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell4.M55309C00003}-${calc_cell4_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_m55309c00003}<${exp_gap}
    ${calc_cell4_M55309C00036}    ${calc_cell4_M55309C00037}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log FR2
    ...    53    FR2_TDD    ${False}    4T    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell4_M55309C00036}    Evaluate    abs(${rlc_counter_dict.cell4.M55309C00036}-${calc_cell4_M55309C00036})
    ${gap_cell4_M55309C00037}    Evaluate    abs(${rlc_counter_dict.cell4.M55309C00037}-${calc_cell4_M55309C00037})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_M55309C00036}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_M55309C00037}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00001}==${RLC_COUNTER_dict.cell4.M55309C00036}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00002}==${RLC_COUNTER_dict.cell4.M55309C00037}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00001}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00002}==0
    Run Keyword And Continue On Failure    Should Be True
    ...    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00001}==${RLC_PMQAP2_COUNTER_DICT.cell4.M55373C00001}
    Run Keyword And Continue On Failure    Should Be True
    ...    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00002}==${RLC_PMQAP2_COUNTER_DICT.cell4.M55373C00002}
    [Teardown]    Common Test Teardown

CB010240_ET_A_B3_303_4T_4T_Small_Volume_PMQAP_Profiles_MultiUE_NSA_FR2
    # [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_SCF_303_ACTIVE}
    # ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    # ...    AND    Common Test Setup
    NSA LTE Attach    ${NONCA_UE_ID_1}
    NSA LTE Attach    ${NONCA_UE_ID_2}
    NSA LTE Attach    ${NONCA_UE_ID_3}
    NSA 5G Attach    ${NONCA_UE_ID_1}    ${GNB_ID}    ${CELL_ID}    ${DEFAULT_BEARER_ID}
    NSA 5G Attach    ${NONCA_UE_ID_2}    ${GNB_ID}    ${CELL_ID}    ${DEFAULT_BEARER_ID}
    NSA 5G Attach    ${NONCA_UE_ID_3}    ${GNB_ID}    ${CELL_ID}    ${DEFAULT_BEARER_ID}
    NSA LTE Attach    ${CA_UE_ID_1}
    NSA LTE Attach    ${CA_UE_ID_2}
    Serving Cell Index For 5G NR
    NSA 5G Attach    ${CA_UE_ID_1}    ${GNB_ID}    ${CELL_ID}    ${DEFAULT_BEARER_ID}
    NSA 5G Attach    ${CA_UE_ID_2}    ${GNB_ID}    ${CELL_ID}    ${DEFAULT_BEARER_ID}
    Set Value For CQI Testmode
    ${CRNTI_UE15}    Get Crnti From Egate Log    ${CA_UE_ID_2}
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NONCA_UE_ID_1}    ${DEFAULT_BEARER_ID}    ${DL_MEDIUM_DATA}
    NSA Start DL Traffic    ${NONCA_UE_ID_2}    ${DEFAULT_BEARER_ID}    ${DL_MEDIUM_DATA}
    NSA Start DL Traffic    ${NONCA_UE_ID_3}    ${DEFAULT_BEARER_ID}    ${DL_MEDIUM_DATA}
    NSA Start DL Traffic    ${CA_UE_ID_1}    ${DEFAULT_BEARER_ID}    ${DL_BIG_DATA}
    NSA Start DL Traffic    ${CA_UE_ID_2}    ${DEFAULT_BEARER_ID}    ${DL_SMALL_DATA}
    Sleep    15s    reason=Wait For DL Transmission
    Check Scell Active Status    2    activated    pass
    Check Scell Active Status    3    activated    pass
    Check Scell Active Status    4    activated    pass
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_1}    ${DEFAULT_BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_2}    ${DEFAULT_BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_3}    ${DEFAULT_BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${CA_UE_ID_1}    ${DEFAULT_BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${CA_UE_ID_2}    ${DEFAULT_BEARER_ID}    dl    ${EXP_SMALL_DL_TPUT}
    NSA Stop Traffic    ${NONCA_UE_ID_1}    ${DEFAULT_BEARER_ID}
    NSA Stop Traffic    ${NONCA_UE_ID_2}    ${DEFAULT_BEARER_ID}
    NSA Stop Traffic    ${NONCA_UE_ID_3}    ${DEFAULT_BEARER_ID}
    NSA Stop Traffic    ${CA_UE_ID_1}    ${DEFAULT_BEARER_ID}
    NSA Stop Traffic    ${CA_UE_ID_2}    ${DEFAULT_BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NONCA_UE_ID_1}    ${DEFAULT_BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${CA_UE_ID_1}    ${DEFAULT_BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    NSA LTE Detach    ${CA_UE_ID_1}
    NSA LTE Detach    ${CA_UE_ID_2}
    NSA LTE Detach    ${NONCA_UE_ID_1}
    NSA LTE Detach    ${NONCA_UE_ID_2}
    NSA LTE Detach    ${NONCA_UE_ID_3}
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${rlc_pmqap2_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP2_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${calc_cell1_M55309C00036}    ${calc_cell1_M55309C00037}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log FR2
    ...    50    FR2_TDD    ${True}    4T    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_M55309C00036}    Evaluate    abs(${rlc_counter_dict.cell1.M55309C00036}-${calc_cell1_M55309C00036})
    ${gap_cell1_M55309C00037}    Evaluate    abs(${rlc_counter_dict.cell1.M55309C00037}-${calc_cell1_M55309C00037})
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55309C00036}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55309C00037}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00001}==${RLC_COUNTER_dict.cell1.M55309C00036}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00002}==${RLC_COUNTER_dict.cell1.M55309C00037}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00001}>0
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00002}>0
    #...    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00001}==${RLC_PMQAP2_COUNTER_DICT.cell1.M55373C00001}
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00002}==${RLC_PMQAP2_COUNTER_DICT.cell1.M55373C00002}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    ${calc_cell2_M55309C00036}    ${calc_cell2_M55309C00037}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log FR2
    ...    51    FR2_TDD    ${False}    4T    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_M55309C00036}    Evaluate    abs(${rlc_counter_dict.cell2.M55309C00036}-${calc_cell2_M55309C00036})
    ${gap_cell2_M55309C00037}    Evaluate    abs(${rlc_counter_dict.cell2.M55309C00037}-${calc_cell2_M55309C00037})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_M55309C00036}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_M55309C00037}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00001}==${RLC_COUNTER_dict.cell2.M55309C00036}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00002}==${RLC_COUNTER_dict.cell2.M55309C00037}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00001}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00002}==0
    Run Keyword And Continue On Failure    Should Be True
    ...    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00001}==${RLC_PMQAP2_COUNTER_DICT.cell2.M55373C00001}
    Run Keyword And Continue On Failure    Should Be True
    ...    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00002}==${RLC_PMQAP2_COUNTER_DICT.cell2.M55373C00002}
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    ${calc_cell3_M55309C00036}    ${calc_cell3_M55309C00037}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log FR2
    ...    52    FR2_TDD    ${False}    4T    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_M55309C00036}    Evaluate    abs(${rlc_counter_dict.cell3.M55309C00036}-${calc_cell3_M55309C00036})
    ${gap_cell3_M55309C00037}    Evaluate    abs(${rlc_counter_dict.cell3.M55309C00037}-${calc_cell3_M55309C00037})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_M55309C00036}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_M55309C00037}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00001}==${RLC_COUNTER_dict.cell3.M55309C00036}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00002}==${RLC_COUNTER_dict.cell3.M55309C00037}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00001}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00002}==0
    Run Keyword And Continue On Failure    Should Be True
    ...    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00001}==${RLC_PMQAP2_COUNTER_DICT.cell3.M55373C00001}
    Run Keyword And Continue On Failure    Should Be True
    ...    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00002}==${RLC_PMQAP2_COUNTER_DICT.cell3.M55373C00002}
    ${calc_cell4_m55309c00002}    ${calc_cell4_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    53    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell4_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell4.M55309C00002}-${calc_cell4_m55309c00002})
    ${gap_cell4_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell4.M55309C00003}-${calc_cell4_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_m55309c00003}<${exp_gap}
    ${calc_cell4_M55309C00036}    ${calc_cell4_M55309C00037}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log FR2
    ...    53    FR2_TDD    ${False}    4T    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell4_M55309C00036}    Evaluate    abs(${rlc_counter_dict.cell4.M55309C00036}-${calc_cell4_M55309C00036})
    ${gap_cell4_M55309C00037}    Evaluate    abs(${rlc_counter_dict.cell4.M55309C00037}-${calc_cell4_M55309C00037})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_M55309C00036}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_M55309C00037}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00001}==${RLC_COUNTER_dict.cell4.M55309C00036}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00002}==${RLC_COUNTER_dict.cell4.M55309C00037}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00001}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00002}==0
    Run Keyword And Continue On Failure    Should Be True
    ...    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00001}==${RLC_PMQAP2_COUNTER_DICT.cell4.M55373C00001}
    Run Keyword And Continue On Failure    Should Be True
    ...    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00002}==${RLC_PMQAP2_COUNTER_DICT.cell4.M55373C00002}
    [Teardown]    Common Test Teardown

CB010240_ET_A_B3_305_4T_4T_NonCA_Big_Volume_Retransmissions_PMQAP_Profiles_MultiUE_NSA_FR2
    NSA LTE Attach    ${NONCA_UE_ID_1}
    NSA LTE Attach    ${NONCA_UE_ID_2}
    NSA LTE Attach    ${NONCA_UE_ID_3}
    NSA 5G Attach    ${NONCA_UE_ID_1}    ${GNB_ID}    ${CELL_ID}    ${DEFAULT_BEARER_ID}
    NSA 5G Attach    ${NONCA_UE_ID_2}    ${GNB_ID}    ${CELL_ID_2}    ${DEFAULT_BEARER_ID}
    NSA 5G Attach    ${NONCA_UE_ID_3}    ${GNB_ID}    ${CELL_ID_3}    ${DEFAULT_BEARER_ID}
    NSA LTE Attach    ${CA_UE_ID_1}
    NSA LTE Attach    ${CA_UE_ID_2}
    Serving Cell Index For 5G NR
    NSA 5G Attach    ${CA_UE_ID_1}    ${GNB_ID}    ${CELL_ID}    ${DEFAULT_BEARER_ID}
    NSA 5G Attach    ${CA_UE_ID_2}    ${GNB_ID}    ${CELL_ID}    ${DEFAULT_BEARER_ID}
    Set Value For CQI Testmode
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    NSA Start DL Traffic    ${NONCA_UE_ID_1}    ${DEFAULT_BEARER_ID}    ${DL_MEDIUM_DATA}
    NSA Start DL Traffic    ${NONCA_UE_ID_2}    ${DEFAULT_BEARER_ID}    ${DL_MEDIUM_DATA}
    NSA Start DL Traffic    ${NONCA_UE_ID_3}    ${DEFAULT_BEARER_ID}    ${DL_MEDIUM_DATA}
    NSA Start DL Traffic    ${CA_UE_ID_1}    ${DEFAULT_BEARER_ID}    ${DL_BIG_DATA}
    NSA Start DL Traffic    ${CA_UE_ID_2}    ${DEFAULT_BEARER_ID}    ${DL_SMALL_DATA}
    Set BLER Testmode    1    ${EMPTY}    ${DL_BLER}
    CUDU L2 Send Action To GNB    ${NONCA_UE_ID_1}    bler    activate    1    0
    CUDU L2 Send Action To GNB    ${NONCA_UE_ID_2}    bler    activate    1    0
    CUDU L2 Send Action To GNB    ${NONCA_UE_ID_3}    bler    activate    1    0
    CUDU L2 Send Action To GNB    ${CA_UE_ID_1}    bler    activate    1    0
    CUDU L2 Send Action To GNB    ${CA_UE_ID_2}    bler    activate    1    0
    Sleep    15s    reason=Wait For DL Transmission
    Check Scell Active Status    2    activated    pass
    Check Scell Active Status    3    activated    pass
    Check Scell Active Status    4    activated    pass
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_1}    ${DEFAULT_BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_2}    ${DEFAULT_BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${NONCA_UE_ID_3}    ${DEFAULT_BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${CA_UE_ID_1}    ${DEFAULT_BEARER_ID}    dl    ${EXP_DL_TPUT}
    NSA Check Average Traffic Bigger Than Target    ${CA_UE_ID_2}    ${DEFAULT_BEARER_ID}    dl    ${EXP_SMALL_DL_TPUT}
    NSA Stop Traffic    ${NONCA_UE_ID_1}    ${DEFAULT_BEARER_ID}
    NSA Stop Traffic    ${NONCA_UE_ID_2}    ${DEFAULT_BEARER_ID}
    NSA Stop Traffic    ${NONCA_UE_ID_3}    ${DEFAULT_BEARER_ID}
    NSA Stop Traffic    ${CA_UE_ID_1}    ${DEFAULT_BEARER_ID}
    NSA Stop Traffic    ${CA_UE_ID_2}    ${DEFAULT_BEARER_ID}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${NONCA_UE_ID_1}    ${DEFAULT_BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Wait Until Keyword Succeeds    1min    3s    NSA Check Average Traffic Equal To Target
    ...    ${CA_UE_ID_1}    ${DEFAULT_BEARER_ID}    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    NSA LTE Detach    ${CA_UE_ID_1}
    NSA LTE Detach    ${CA_UE_ID_2}
    NSA LTE Detach    ${NONCA_UE_ID_1}
    NSA LTE Detach    ${NONCA_UE_ID_2}
    NSA LTE Detach    ${NONCA_UE_ID_3}
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${rlc_pmqap2_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP2_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${calc_cell1_M55309C00036}    ${calc_cell1_M55309C00037}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log FR2
    ...    50    FR2_TDD    ${True}    4T    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_M55309C00036}    Evaluate    abs(${rlc_counter_dict.cell1.M55309C00036}-${calc_cell1_M55309C00036})
    ${gap_cell1_M55309C00037}    Evaluate    abs(${rlc_counter_dict.cell1.M55309C00037}-${calc_cell1_M55309C00037})
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55309C00036}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55309C00037}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00001}==${RLC_COUNTER_dict.cell1.M55309C00036}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00002}==${RLC_COUNTER_dict.cell1.M55309C00037}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00001}>0
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00002}>0
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00001}==${RLC_PMQAP2_COUNTER_DICT.cell1.M55373C00001}
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${RLC_PMQAP_COUNTER_dict.cell1.M55373C00002}==${RLC_PMQAP2_COUNTER_DICT.cell1.M55373C00002}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    ${calc_cell2_M55309C00036}    ${calc_cell2_M55309C00037}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log FR2
    ...    51    FR2_TDD    ${False}    4T    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_M55309C00036}    Evaluate    abs(${rlc_counter_dict.cell2.M55309C00036}-${calc_cell2_M55309C00036})
    ${gap_cell2_M55309C00037}    Evaluate    abs(${rlc_counter_dict.cell2.M55309C00037}-${calc_cell2_M55309C00037})
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_M55309C00036}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_M55309C00037}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00001}==${RLC_COUNTER_dict.cell2.M55309C00036}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00002}==${RLC_COUNTER_dict.cell2.M55309C00037}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00001}>0
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00002}>0
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00001}==${RLC_PMQAP2_COUNTER_DICT.cell2.M55373C00001}
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${RLC_PMQAP_COUNTER_dict.cell2.M55373C00002}==${RLC_PMQAP2_COUNTER_DICT.cell2.M55373C00002}
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    ${calc_cell3_M55309C00036}    ${calc_cell3_M55309C00037}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log FR2
    ...    52    FR2_TDD    ${False}    4T    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_M55309C00036}    Evaluate    abs(${rlc_counter_dict.cell3.M55309C00036}-${calc_cell3_M55309C00036})
    ${gap_cell3_M55309C00037}    Evaluate    abs(${rlc_counter_dict.cell3.M55309C00037}-${calc_cell3_M55309C00037})
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_M55309C00036}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_M55309C00037}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00001}==${RLC_COUNTER_dict.cell3.M55309C00036}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00002}==${RLC_COUNTER_dict.cell3.M55309C00037}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00001}>0
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00002}>0
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00001}==${RLC_PMQAP2_COUNTER_DICT.cell3.M55373C00001}
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${RLC_PMQAP_COUNTER_dict.cell3.M55373C00002}==${RLC_PMQAP2_COUNTER_DICT.cell3.M55373C00002}
    ${calc_cell4_m55309c00002}    ${calc_cell4_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    53    FR2_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell4_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell4.M55309C00002}-${calc_cell4_m55309c00002})
    ${gap_cell4_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell4.M55309C00003}-${calc_cell4_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_m55309c00003}<${exp_gap}
    ${calc_cell4_M55309C00036}    ${calc_cell4_M55309C00037}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log FR2
    ...    53    FR2_TDD    ${False}    4T    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell4_M55309C00036}    Evaluate    abs(${rlc_counter_dict.cell4.M55309C00036}-${calc_cell4_M55309C00036})
    ${gap_cell4_M55309C00037}    Evaluate    abs(${rlc_counter_dict.cell4.M55309C00037}-${calc_cell4_M55309C00037})
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_M55309C00036}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${gap_cell4_M55309C00037}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00001}==${RLC_COUNTER_dict.cell4.M55309C00036}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00002}==${RLC_COUNTER_dict.cell4.M55309C00037}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00001}==0
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00002}==0
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00001}==${RLC_PMQAP2_COUNTER_DICT.cell4.M55373C00001}
    #Run Keyword And Continue On Failure    Should Be True
    #...    ${RLC_PMQAP_COUNTER_dict.cell4.M55373C00002}==${RLC_PMQAP2_COUNTER_DICT.cell4.M55373C00002}
    [Teardown]    Common Test Teardown
