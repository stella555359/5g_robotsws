*** Settings ***
Documentation    CB010240
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
CB010240_ET_A_B11_1102_NonCA_Small_Volume_SingleUE_SA_FR1
    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_SCF_1102_ACTIVE}
    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    ...    AND    Common Test Setup
    SA Single UE Attach    ${NONCA_UE_ID}
    Wait Until PM Counter Update
    # Delete RD BTS Counter Xml
    Start Ttitrace With Streaming Mode
    SA Start DL Traffic Internal    ${NONCA_UE_ID}    1    ${DL_SMALL_DATA}
    Sleep    20s    reason=Wait For DL Transmission
    SA Check UE Cell TPut On Target    ${NONCA_UE_ID}    1    dl    ${EXP_SMALL_DL_TPUT}
    # Capture Convert L2LOL2HI Ttitrace With Streaming Mode    1s
    SA Stop Data Traffic Internal    ${NONCA_UE_ID}    1
    Wait Until Keyword Succeeds    1min    3s    SA Check UE Cell TPut Equal To Target
    ...    ${NONCA_UE_ID}    1    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_1
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    Run Keyword And Continue On Failure    Should Be True    ${mac_counter_dict.cell1.M55309C00002}==0
    Run Keyword And Continue On Failure    Should Be True    ${mac_counter_dict.cell1.M55309C00003}==0
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C04002}==0
    #${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    #Run Keyword And Continue On Failure    Should Be True    ${rlc_pmqap_counter_dict.cell1.M55353C00002}==0
    #Run Keyword And Continue On Failure    Should Be True    ${rlc_pmqap_counter_dict.cell1.M55353C00003}==0
    # Save RD BTS Counter Xml And Gunzip    ${test_log_directory}/1
    # Check PM Counter Is Zero    ${m55309c00002_name}    ${CELL1_COUNTER_PATH}    ${measurementtype}    counter_log=${test_log_directory}/1
    # Check PM Counter Is Zero    ${m55309c00003_name}    ${CELL1_COUNTER_PATH}    ${measurementtype}    counter_log=${test_log_directory}/1
    SA 5G Detach    ${NONCA_UE_ID}
    Delta Commission With SCF File    ${DELTA_SCF_1108_ACTIVE}
    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    SA Single UE Attach    ${NONCA_UE_ID}
    Wait Until PM Counter Update
    # Delete RD BTS Counter Xml
    Start Ttitrace With Streaming Mode
    SA Start DL Traffic Internal    ${NONCA_UE_ID}    1    ${DL_MEDIUM_DATA}
    Sleep    20s    reason=Wait For DL Transmission
    SA Check UE Cell TPut On Target    ${NONCA_UE_ID}    1    dl    ${EXP_SMALL_DL_TPUT}
    # Capture Convert L2LOL2HI Ttitrace With Streaming Mode    1s
    SA Stop Data Traffic Internal    ${NONCA_UE_ID}    1
    Wait Until Keyword Succeeds    1min    3s    SA Check UE Cell TPut Equal To Target
    ...    ${NONCA_UE_ID}    1    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_2
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming_2/tcpdump_ttitrace_MacPduMuxReq.csv    ${30}    ${2}
    ${gap_cell1_m55309c00002}    Evaluate    abs(${MAC_COUNTER_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${MAC_COUNTER_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C03002}==${MAC_COUNTER_dict.cell1.M55309C00002}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C04002}==${MAC_COUNTER_dict.cell1.M55309C00003}
   # Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00002}==${RLC_COUNTER_dict.cell1.M55349C03002}
   # Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00003}==${RLC_COUNTER_dict.cell1.M55349C04002}
    SA 5G Detach    ${NONCA_UE_ID}
    Delta Commission With SCF File    ${DELTA_SCF_1102_DEACTIVE}
    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    SA Single UE Attach    ${NONCA_UE_ID}
    Wait Until PM Counter Update
    Start Ttitrace With Streaming Mode
    SA Start DL Traffic Internal    ${NONCA_UE_ID}    1    ${DL_TINY_DATA}
    Sleep    20s    reason=Wait For DL Transmission
    SA Check UE Cell TPut On Target    ${NONCA_UE_ID}    1    dl    ${EXP_TINY_DL_TPUT}
    SA Stop Data Traffic Internal    ${NONCA_UE_ID}    1
    Wait Until Keyword Succeeds    1min    3s    SA Check UE Cell TPut Equal To Target
    ...    ${NONCA_UE_ID}    1    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_3
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    #${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming_3/tcpdump_ttitrace_MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${MAC_COUNTER_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${MAC_COUNTER_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C03002}==${MAC_COUNTER_dict.cell1.M55309C00002}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C04002}==${MAC_COUNTER_dict.cell1.M55309C00003}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00002}==${RLC_COUNTER_dict.cell1.M55349C03002}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00003}==${RLC_COUNTER_dict.cell1.M55349C04002}
    [Teardown]    Run Keywords    SA 5G Detach    ${NONCA_UE_ID}
    ...    AND    Common Test Teardown

CB010240_ET_A_B11_1103_3F_Big_Volume_SingleUE_SA_FR1
    SA 5G CA Attach    ${3F_UE_ID}
    Check SA All Scell PhysicalID With UE ID    ${3F_UE_ID}    ${3f_scell_physicalid_list}    3
    Wait Until PM Counter Update
    # Delete RD BTS Counter Xml
    Start Ttitrace With Streaming Mode
    SA Start DL Traffic Internal    ${3F_UE_ID}    1    ${DL_BIG_DATA}
    Sleep    20s    reason=Wait For DL Transmission
    Check UE DL All Pcell Scell TP On Target For Single UE    ${3F_UE_ID}    ${exp_dl_tput_list}    3
    SA Stop Data Traffic Internal    ${3F_UE_ID}    1
    Wait Until Keyword Succeeds    1min    3s    Check UE DL All Pcell Scell TP Equal To Target For Single UE
    ...    ${3F_UE_ID}    ${exp_zero_tput_list}    3
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    SA 5G Detach    ${3F_UE_ID}
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    #${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
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
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00002}==0
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell2.M55353C00003}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict.cell2.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict.cell2.M55349C04002}==0
    ${calc_cell5_m55309c00002}    ${calc_cell5_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    54    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell5_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell5.M55309C00002}-${calc_cell5_m55309c00002})
    ${gap_cell5_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell5.M55309C00003}-${calc_cell5_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell5_m55309c00003}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell5.M55353C00002}==0
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell5.M55353C00003}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict.cell5.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_COUNTER_dict.cell5.M55349C04002}==0
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00002}==${RLC_COUNTER_dict.cell1.M55349C03002}
    Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00003}==${RLC_COUNTER_dict.cell1.M55349C04002}
    [Teardown]    Common Test Teardown

CB010240_ET_A_B11_1104_NonCA_Big_Volume_Retransmissions_SingleUE_SA_FR1
    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRPMRNL-1/NRPMQAP-1    cfg5qiRange    5,7-9
    SA Single UE Attach    ${NONCA_UE_ID}
    Wait Until PM Counter Update
    # Delete RD BTS Counter Xml
    Start Ttitrace With Streaming Mode
    SA Start DL Traffic Internal    ${NONCA_UE_ID}    1    ${DL_BIG_DATA}
    Set BLER Testmode    1    ${empty}    ${DL_BLER}
    CUDU L2 Send Action To GNB    1    bler    activate    1    0
    Sleep    5s    reason=Wait For DL Transmission
    SA Check UE Cell TPut On Target    ${NONCA_UE_ID}    1    dl    ${EXP_DL_TPUT}
    SA Stop Data Traffic Internal    ${NONCA_UE_ID}    1
    Wait Until Keyword Succeeds    1min    3s    SA Check UE Cell TPut Equal To Target
    ...    ${NONCA_UE_ID}    1    dl    ${EXP_ZERO_TPUT}
    SA Start DL Traffic Internal    ${NONCA_UE_ID}    1    ${DL_BIG_DATA}
    Sleep    5s    reason=Wait For DL Transmission
    SA Check UE Cell TPut On Target    ${NONCA_UE_ID}    1    dl    ${EXP_DL_TPUT}
    SA Stop Data Traffic Internal    ${NONCA_UE_ID}    1
    Wait Until Keyword Succeeds    1min    3s    SA Check UE Cell TPut Equal To Target
    ...    ${NONCA_UE_ID}    1    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_M55309C00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_M55309C00002})
    ${gap_cell1_M55309C00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_M55309C00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55309C00002}<${EXP_GAP}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_M55309C00003}<${EXP_GAP}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    #${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C03002}==${mac_counter_dict.cell1.M55309C00002}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C04002}==${mac_counter_dict.cell1.M55309C00003}
    #Run Keyword And Continue On Failure    Should Be True    ${rlc_pmqap_counter_dict.cell1.M55353C00002}==0
   # Run Keyword And Continue On Failure    Should Be True    ${rlc_pmqap_counter_dict.cell1.M55353C00002}==0
    [Teardown]    Run Keywords    SA 5G Detach    ${NONCA_UE_ID}
    ...    AND    Common Test Teardown

CB010240_ET_A_B11_1105_2F1T_NonCA_Big_Volume_MultiUE_SA_FR1
    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRPMRNL-1/NRPMQAP-1    cfg5qiRange    5,7-9
    SA Single UE Attach    ${NONCA_UE_ID_2}
    SA 5G CA Attach    ${2F1T_UE_ID}
    Check SA All Scell PhysicalID With UE ID    ${2F1T_UE_ID}    ${2f1t_scell_physicalid_list}    3
    Wait Until PM Counter Update
    # Delete RD BTS Counter Xml
    Start Ttitrace With Streaming Mode
    SA Start DL Traffic Internal    ${NONCA_UE_ID_2}    1    ${DL_BIG_DATA}
    SA Start DL Traffic Internal    ${2F1T_UE_ID}    1    ${DL_BIG_DATA}
    Sleep    10s    reason=Wait For DL Transmission
    SA Check UE Cell TPut On Target    ${NONCA_UE_ID_2}    1    dl    ${EXP_DL_TPUT}
    Check UE DL All Pcell Scell TP On Target For Single UE    ${2F1T_UE_ID}    ${exp_dl_tput_list}    3
    SA Stop Data Traffic Internal    ${NONCA_UE_ID_2}    1
    SA Stop Data Traffic Internal    ${2F1T_UE_ID}    1
    Wait Until Keyword Succeeds    1min    3s    SA Check UE Cell TPut Equal To Target
    ...    ${NONCA_UE_ID_2}    1    dl    ${EXP_ZERO_TPUT}
    Wait Until Keyword Succeeds    1min    3s    Check UE DL All Pcell Scell TP Equal To Target For Single UE
    ...    ${2F1T_UE_ID}    ${exp_zero_tput_list}    3
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    SA 5G Detach    ${2F1T_UE_ID}
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    #${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${calc_cell1_m55349c03002}    ${calc_cell1_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    50    FR1_TDD    ${False}    1T2F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell1_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C03002}-${calc_cell1_m55349c03002})
    ${gap_cell1_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell1.M55349C04002}-${calc_cell1_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55349c04002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C03002}<${mac_counter_dict.cell1.M55309C00002}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C04002}<${mac_counter_dict.cell1.M55309C00003}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell2.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell2.M55349C04002}==0
    ${calc_cell3_m55309c00002}    ${calc_cell3_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00002}-${calc_cell3_m55309c00002})
    ${gap_cell3_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell3.M55309C00003}-${calc_cell3_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00002}<600
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55309c00003}<${exp_gap}
    ${calc_cell3_m55349c03002}    ${calc_cell3_m55349c04002}    Run Keyword And Continue On Failure    Get RLC Value From L2LO Ttitrace Log
    ...    52    FR1_TDD    ${True}    1T2F    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell3_m55349c03002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C03002}-${calc_cell3_m55349c03002})
    ${gap_cell3_m55349c04002}    Evaluate    abs(${rlc_counter_dict.cell3.M55349C04002}-${calc_cell3_m55349c04002})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c03002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell3_m55349c04002}<${exp_gap}
    #Run Keyword And Continue On Failure    Should Be True    ${rlc_pmqap_counter_dict.cell1.M55353C00002}==0
    #Run Keyword And Continue On Failure    Should Be True    ${rlc_pmqap_counter_dict.cell1.M55353C00002}==0
    [Teardown]    Run Keywords    SA 5G Detach    ${NONCA_UE_ID_2}
    ...    AND    Common Test Teardown

CB010240_ET_A_B11_1106_2F1T_NonCA_Big_Volume_Retransmissions_MultiUE_SA_FR1
    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRPMRNL-1/NRPMQAP-1    cfg5qiRange    5-9
    SA Single UE Attach    ${NONCA_UE_ID}
    SA 5G CA Attach    ${2F1T_UE_ID}
    Check SA All Scell PhysicalID With UE ID    ${2F1T_UE_ID}    ${2f1t_scell_physicalid_list}    3
    Wait Until PM Counter Update
    # Delete RD BTS Counter Xml
    Start Ttitrace With Streaming Mode
    SA Start DL Traffic Internal    ${NONCA_UE_ID}    1    ${DL_BIG_DATA}
    SA Start DL Traffic Internal    ${2F1T_UE_ID}    1    ${DL_BIG_DATA}
    Set BLER Testmode    1    ${empty}    ${DL_BLER}
    CUDU L2 Send Action To GNB    1    bler    activate    1    0
    CUDU L2 Send Action To GNB    4    bler    activate    1    1
    Sleep    5s    reason=Wait For DL Transmission
    SA Check UE Cell TPut On Target    ${NONCA_UE_ID}    1    dl    ${EXP_DL_TPUT}
    Check UE DL All Pcell Scell TP On Target For Single UE    ${2F1T_UE_ID}    ${exp_dl_tput_list}    3
    SA Stop Data Traffic Internal    ${NONCA_UE_ID}    1
    SA Stop Data Traffic Internal    ${2F1T_UE_ID}    1
    Wait Until Keyword Succeeds    1min    3s    SA Check UE Cell TPut Equal To Target
    ...    ${NONCA_UE_ID}    1    dl    ${EXP_ZERO_TPUT}
    Wait Until Keyword Succeeds    1min    3s    Check UE DL All Pcell Scell TP Equal To Target For Single UE
    ...    ${2F1T_UE_ID}    ${exp_zero_tput_list}    3
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    SA 5G Detach    ${2F1T_UE_ID}
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    #${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
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
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C03002}<${mac_counter_dict.cell1.M55309C00002}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C04002}<${mac_counter_dict.cell1.M55309C00003}
    ${calc_cell2_m55309c00002}    ${calc_cell2_m55309c00003}    Run Keyword And Continue On Failure    Get Value From L2LO Ttitrace Log
    ...    51    FR1_FDD    ${test_log_directory}/ttitrace_streaming/MacPduMuxReq.csv
    ${gap_cell2_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00002}-${calc_cell2_m55309c00002})
    ${gap_cell2_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell2.M55309C00003}-${calc_cell2_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00002}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell2_m55309c00003}<${exp_gap}
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell2.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell2.M55349C04002}==0
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
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00002}==${RLC_COUNTER_dict.cell1.M55349C03002}
    #Run Keyword And Continue On Failure    Should Be True    ${RLC_PMQAP_COUNTER_dict.cell1.M55353C00003}==${RLC_COUNTER_dict.cell1.M55349C04002}
    [Teardown]    Run Keywords    SA 5G Detach    ${NONCA_UE_ID}
    ...    AND    Common Test Teardown
    ...    AND    Collect UTE SosReport    log_dir=${test_log_directory}

CB010240_ET_A_B11_1101_NonCA_Online_Active_DL_MAC_SDU_User_Throughput_PM_Counters_SingleUE_SA_FR1
    [Setup]    Run Keywords    Delta Commission With SCF File    ${DELTA_SCF_1101_DEACTIVE}
    ...    AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    ...    AND    Common Test Setup
    SA Single UE Attach    ${NONCA_2_BEARER_UE_ID}
    Wait Until PM Counter Update
    # Delete RD BTS Counter Xml
    # Start Ttitrace With Streaming Mode
    SA Start DL Traffic Internal    ${NONCA_2_BEARER_UE_ID}    1    ${DL_BIG_DATA}
    UE GBR Establishment And DL Tput    ${NONCA_2_BEARER_UE_ID}    ${DL_MEDIUM_DATA}
    Sleep    20s    reason=Wait For DL Transmission
    SA Check UE Cell TPut On Target    ${NONCA_2_BEARER_UE_ID}    1    dl    ${EXP_DL_TPUT}
    SA Stop Data Traffic Internal    ${NONCA_2_BEARER_UE_ID}    1
    # Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_1
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
   # ${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    Run Keyword And Continue On Failure    Should Be True    ${mac_counter_dict.cell1.M55309C00002}==0
    Run Keyword And Continue On Failure    Should Be True    ${mac_counter_dict.cell1.M55309C00003}==0
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C03002}==0
    Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C04002}==0
    #Run Keyword And Continue On Failure    Should Be True    ${rlc_pmqap_counter_dict.cell1.M55353C00002}==0
    #Run Keyword And Continue On Failure    Should Be True    ${rlc_pmqap_counter_dict.cell1.M55353C00002}==0
    SA 5G Detach    ${NONCA_2_BEARER_UE_ID}
    Delta Commission With SCF File    ${DELTA_SCF_1101_ACTIVE}
    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    SA Single UE Attach    ${NONCA_2_BEARER_UE_ID}
    Wait Until PM Counter Update
    # Delete RD BTS Counter Xml
    Start Ttitrace With Streaming Mode
    SA Start DL Traffic Internal    ${NONCA_2_BEARER_UE_ID}    1    250
    UE GBR Establishment And DL Tput    ${NONCA_2_BEARER_UE_ID}    ${DL_MEDIUM_DATA}
    SA Check UE Cell TPut On Target    ${NONCA_2_BEARER_UE_ID}    1    dl    ${EXP_DL_TPUT}
    Sleep    10s    reason=Wait For DL Transmission
    SA Stop Data Traffic Internal    ${NONCA_2_BEARER_UE_ID}    1
    Wait Until Keyword Succeeds    2min    3s    SA Check UE Cell TPut Equal To Target
    ...    ${NONCA_2_BEARER_UE_ID}    1    dl    ${EXP_ZERO_TPUT}
    Stop Convert L2LOL2HI Ttitrace With Streaming Mode    log_dir=${test_log_directory}/ttitrace_streaming_2
    Wait Until PM Counter Update
    ${mac_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${MAC_COUNTER_INFO_LIST}
    ${calc_cell1_m55309c00002}    ${calc_cell1_m55309c00003}    Get Value For Multi Bearer From L2LO Ttitrace Log
    ...    50    FR1_FDD    ${test_log_directory}/ttitrace_streaming_2/MacPduMuxReq.csv
    ${gap_cell1_m55309c00002}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00002}-${calc_cell1_m55309c00002})
    ${gap_cell1_m55309c00003}    Evaluate    abs(${mac_counter_dict.cell1.M55309C00003}-${calc_cell1_m55309c00003})
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00002}<600
    Run Keyword And Continue On Failure    Should Be True    ${gap_cell1_m55309c00003}<${exp_gap}
    ${rlc_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_COUNTER_INFO_LIST}
    #${rlc_pmqap_counter_dict}    Get Multi Cells Multi PM Counters Latest Values With Admin Advance    ${RLC_PMQAP_COUNTER_INFO_LIST}
    #Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C03002}>=${rlc_pmqap_counter_dict.cell1.M55353C00002}
   # Run Keyword And Continue On Failure    Should Be True    ${rlc_counter_dict.cell1.M55349C04002}>=${rlc_pmqap_counter_dict.cell1.M55353C00003}
    [Teardown]    Run Keywords    SA 5G Detach    ${NONCA_2_BEARER_UE_ID}
    ...    AND    Common Test Teardown
