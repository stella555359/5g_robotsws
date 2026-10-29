*** Settings ***
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags        CRT    SBTS00   RAN_5G_TDD    RAN_5G   owner_l3gao    CLOUD_5G_I_BOO_AP_LOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

Documentation


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_122436_CASE07.xml
${AIRPHONE_NAME}    IPHY_AQQL_2CELL_APLO.xml
${WTS_NAME}    WTS_2AQQL_2cell_SA_NSA_CA.lua

@{LOG_NAME_LIST}    gnb_snapshot
${UE_NUM_SA}    1
${UE_NUM}    1

${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq

@{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
@{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID

${FILTER_f1ap_cellreconfig}    itf_l2_ps_cell_cellsetupreq||itf_l2_ps_cell_cellsetupresp||itf_l2_ps_cell_cellreconfigurationreq||
...    itf_l2_ps_cell_cellreconfigurationreq_t||itf_l2_ps_cell_cellreconfigurationresp||itf_l2_ps_cell_cellreconfigurationresp_t
@{titles_cell_reconfig}    itf_l2_ps_pdcch_DynamicAggregationLevelHRSetReconfig.blerTargetHr
...    itf_l2_ps_pdcch_DynamicAggregationLevelSetReconfig.blerTarget
...    itf_l2_ps_cell_CellReconfigurationReq_t.nrCellGrpId

${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=40 zenith\=30 srs_transmit_power_per_port\=-280,-280,-280,-280
@{TOOLS_LIST}    luashark    bip_script    common_config_golden    common_config_private    mcshark   ttitrace_decode

${TP_PEAK_DL}    1300000  #1.1gbps
${TP_PEAK_UL}    150000   #211mbps
${cell1_ue_end}    20    #start=1
${cell2_ue_end}    90    #start=60
${cell1_ue_HR_end}    2   #start=1
${cell2_ue_HR_end}    65    #start=60
${pdcch_misd_rate}    200
${cqicorr_up}    0.008
${cqicorrHr_up}    0.001

*** Test Cases ***
CNI122436_case007_multi_UEs_PDCCH_HR_BR_MIxed_KPI_test
#    Active GNB L2 feature debug traces
    step1:get ready for gnb
    step2:attach multi UEs to cell1
    step3:send buffer for UEs and check logs
    step4:add HR bear to UEs
    step5:online change TargetBler for Cell pdcchBlerTarget and pdcchBlerTargetHR and check
#    step6:check KPI
    step7:add PDCCH_DTX to UEs and check
    capture snapshot start once    step6

*** Keywords ***
step1:get ready for gnb
    Log To Console   \n-------------step1:get ready for gnb--------------------------------------
	Add RD
	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
    ${custom_error}    Create list    ERR/.uplane    ERR/L2-PS    ERR/l1_application_rt    #WRN/.uplane    #WRN/L2-PS
	Set Test Variable    ${custom_error}
	Prepare gnb onair
	Create SRS_pos profile


step2:attach multi UEs to cell1
    Log To Console   \n-------------step2:attach multi UEs to cell1---------------
    Start capture only gnb syslog in 'step2' file
	Attach SA UEs with f1ap    ue_start=1    ue_end=${cell1_ue_end}
	set SA UEs Pos    ue_start=1    ue_end=${cell1_ue_end}
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step2' file '${custom_error}'

step3:send buffer for UEs and check logs
    Log To Console   \n-------------step3:send buffer for UEs and check logs---------------------
    Start capture only gnb syslog in 'step3' file
    Airphone Cleanup Egate Console Log
    SA send data buffer    ue_start=1    ue_end=${cell1_ue_end}   data=45M    data_num=1
	run keyword and continue on failure	   Check non_CA SA UE throughput    ue_start=1    ue_end=${cell1_ue_end}
	...    dl_target=15000    ul_target=2000
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step3' file '${custom_error}'

step4:add HR bear to UEs
    Log To Console   \n-------------step4:add HR bear to UEs---------------------------------------
    Start capture only gnb syslog in 'step4' file
    Add HR bear to UEs    ue_start=1    ue_end=${cell1_ue_HR_end}
    Wait '5s' for stable
    Collect ttitrace and Check    tti_tag=tti_step4    ini_file=tti_dl    cell_id=all
    Wait '5s' for stable
	run keyword and continue on failure	   Check non_CA SA UE throughput    ue_start=1    ue_end=${cell1_ue_end}
	...    dl_target=15000    ul_target=2000
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step4' file '${custom_error}'
    capture snapshot start once    step4

step5:online change TargetBler for Cell pdcchBlerTarget and pdcchBlerTargetHR and check
    Log To Console   \n---------step5:online change TargetBler and check KPI----------
    Start capture only gnb syslog in 'syslog_step5_tableTag' file
    Online change br'1' and hr'20'
    Collect ttitrace and Check    tti_tag=tti_step5_br1_hr20    ini_file=tti_dl    cell_id=all
#    Online change br'10' and hr'100'
#    Collect ttitrace and Check    tti_tag=tti_step5_br10_hr100    ini_file=tti_dl    cell_id=all
    Online change br'100' and hr'1'
    Collect ttitrace and Check    tti_tag=tti_step5_br100_hr1    ini_file=tti_dl    cell_id=all
    Online change br'40' and hr'40'
    Collect ttitrace and Check    tti_tag=tti_step5_br100_hr1    ini_file=tti_dl    cell_id=all    #multi UE onlinechange no bler
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'syslog_step5_tableTag' file '${custom_error}'
#    capture snapshot start once    step5_table_${table_tag}

step7:add PDCCH_DTX to UEs and check
    Log To Console   \n-------------step7:add PDCCH_DTX to UEs---------------------------------------
    Start capture only gnb syslog in 'step7' file
    Airphone SA Stop Data     ue_start=1    ue_end=${cell1_ue_end}
    Airphone SA Detach UE    3    ${cell1_ue_end}     #detach all UE left 2ue to check pdcch offset
    SA send data buffer DL only    ue_start=1    ue_end=2   data=145M    data_num=4
    Add PDCCH_DTX to UEs    ue_start=1    ue_end=2
    Wait '10s' for stable
    Collect ttitrace and Check pddchoffset    tti_tag=tti_step7_br40_hr40    ini_file=tti_dl_dtx    cell_id=all
    Wait '5s' for stable
    Online change br'1' and hr'20'
    Collect ttitrace and Check pddchoffset    tti_tag=tti_step7_br1_hr20    ini_file=tti_dl_dtx    cell_id=all
    Online change br'10' and hr'100'
    Collect ttitrace and Check pddchoffset    tti_tag=tti_step10_br1_hr100    ini_file=tti_dl_dtx    cell_id=all
	run keyword and continue on failure	   Check non_CA SA UE throughput    ue_start=1    ue_end=2
	...    dl_target=15000    ul_target=0
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step7' file '${custom_error}'

Online change br'${pdcchBlerTarget}' and hr'${pdcchBlerTargetHR}'
    ${cqicorr_down}    ${cqicorrHr_down}  blertaget_value_nidd    ${pdcchBlerTarget}    ${pdcchBlerTargetHR}    ${cqicorr_up}    ${cqicorrHr_up}
    Start collect UE f1ap    blertarget_br${pdcchBlerTarget}_hr${pdcchBlerTargetHR}
    Online change parameters_24R3    delta_122436_24R3    ${pdcchBlerTarget}    ${pdcchBlerTargetHR}
    Stop collect UE f1ap    blertarget_br${pdcchBlerTarget}_hr${pdcchBlerTargetHR}
    check pdcchbler_target recofig    blertarget_br${pdcchBlerTarget}_hr${pdcchBlerTargetHR}    ${pdcchBlerTarget}    ${pdcchBlerTargetHR}

check pdcchbler_target recofig
    [Arguments]     ${bip_file}    ${pdcchBlerTarget}    ${pdcchBlerTargetHR}
    Log To Console   Check '${bip_file}'
    Run Keyword And ignore error    Convert BIP To CSV
    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_cellreconfig}    ${titles_cell_reconfig}
    compare_blerTargetBr    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${pdcchBlerTarget}    0
    compare_blerTargetBr    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${pdcchBlerTarget}    1
    compare_blerTargetHr    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${pdcchBlerTargetHR}    0
    compare_blerTargetHr    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${pdcchBlerTargetHR}    1
#    capture snapshot start once    step5

step6:check KPI
    Log To Console   \n---------step6:check KPI----------
    Start capture only gnb syslog in 'step6:check KPI' file
	run keyword and continue on failure	   Check non_CA SA UE throughput    ue_start=1    ue_end=${cell1_ue_end}
    ...    dl_target=15000    ul_target=2000
    ${PM_counter_file}    Get counter file
    ${CNI122436_kpi_list}    KPI counter check    ${PM_counter_file}    cell_id=1
    ${CNI_122436_kpi_list_cell2}    KPI counter check    ${PM_counter_file}    cell_id=2
#    Record result in excel    ${table_tag}    ${actMuAwareTdSch}     ${dlMuAwareCorrThd}
#    ...    ${8701_pair_counter_for_table}    ${CNI122436_kpi_list}
#    Collect ttitrace and Check    tti_tag=tti_step5_${table_tag}    ini_file=tti_dl    cell_id=all
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step6:check KPI' file '${custom_error}'



Collect ttitrace and Check pddchoffset
    [Arguments]     ${tti_tag}    ${ini_file}    ${cell_id}=all
    log to console    start collect ttitrace
    Start GNB Ttitrace With Streaming Mode    cell_id=${cell_id}    up_sw=L2Ps     name=${tti_tag}
    Wait for '0.5s' to stop ttitrace with name'${tti_tag}'
    run keyword and continue on failure	   Check ttitrace with ini    ${tti_tag}   ${ini_file}
    run keyword and continue on failure	   Check ttitrace with ini    ${tti_tag}   tti_ul_dtx
    run keyword and continue on failure	   cqiPdcchOffset_value_check_multiUE    ${TEST_LOG_DIRECTORY()}/All/${tti_tag}/tti_dl.csv

Record result in excel
    [Arguments]     ${table_tag}    ${actMuAwareTdSch}     ${dlMuAwareCorrThd}    ${8701_pair_counter_for_table}    ${9235_kpi_list}
    modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     0    ${table_tag}    9235_${actMuAwareTdSch}_mucor_${dlMuAwareCorrThd}
    FOR    ${num}    IN RANGE    0    18
        ${num_table}    evaluate    ${num}+1
        modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     ${num_table}    ${table_tag}
        ...    ${8701_pair_counter_for_table[${num}]}
    END

    FOR    ${num}    IN RANGE    0    8
        ${num_table}    evaluate    ${num}+19
        modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     ${num_table}     ${table_tag}
        ...    ${9235_kpi_list[${num}]}
    END


KPI counter check
    [Arguments]    ${PM_counter_file}     ${cell_id}=1
    ${NR_5055b}    get KPI NR_5055b    ${PM_counter_file}    ${cell_id}
    run keyword and continue on failure   should be true   ${NR_5055b}<0.001
    log to console    KPI NR_5055b residual bler is ${NR_5055b}

    ${NR_5054a}    get KPI NR_5054a    ${PM_counter_file}    ${cell_id}
    run keyword and continue on failure   should be true   ${NR_5054a}<0.01
    log to console    KPI NR_5054a ini bler is ${NR_5054a}


    ${PDSCH_INIRE_VOL_64TBL_MCS}    create list
    ${PDSCH_INIRE_VOL_256TBL_MCS}    create list
    FOR    ${num}    IN RANGE    0    32
        ${counter_22}   evaluate   2000+${num}
        ${counter_6}   evaluate   6000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_22}    cell_id=${cell_id}
        append to list    ${PDSCH_INIRE_VOL_64TBL_MCS}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_6}    cell_id=${cell_id}
        append to list    ${PDSCH_INIRE_VOL_256TBL_MCS}    ${result}
    END

#    log to console    PDSCH_INIRE_VOL_64TBL_MCS 0_to_31 is ${PDSCH_INIRE_VOL_64TBL_MCS}
#    log to console    PDSCH_INIRE_VOL_256TBL_MCS 0_to_31 is ${PDSCH_INIRE_VOL_256TBL_MCS}

    ${rt1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C03005    cell_id=${cell_id}
    ${rt2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10001    cell_id=${cell_id}
    ${rt3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00008    cell_id=${cell_id}
    ${rt4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00016    cell_id=${cell_id}
    ${rt5}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00018    cell_id=${cell_id}
    ${NR_5108d_numerato}    evaluate    8*(sum(${PDSCH_INIRE_VOL_64TBL_MCS})+sum(${PDSCH_INIRE_VOL_256TBL_MCS}))
    ${NR_5108d}    evaluate    ${NR_5108d_numerato}/(${rt1}*180*(${rt2}/(${rt3}+${rt4}+${rt5})))
#    log to console    KPI NR_5108d SE_downlink is ${NR_5108d}

    ${L_M55304C0400X}   create list
    ${M55304C0400X}    set variable    0
    FOR    ${num}    IN RANGE    0    10
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0400${num}    cell_id=${cell_id}
        ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
        append to list    ${L_M55304C0400X}    ${result}
    END

    FOR    ${num}    IN RANGE    10    32
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C040${num}    cell_id=${cell_id}
        ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
        append to list    ${L_M55304C0400X}    ${result}
    END

    ${L_M55304C0800X}   create list
    ${M55304C0800X}    set variable    0
    FOR    ${num}    IN RANGE    0    10
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0800${num}    cell_id=${cell_id}
        ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
        append to list    ${L_M55304C0800X}    ${result}
    END

    FOR    ${num}    IN RANGE    10    32
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C080${num}    cell_id=${cell_id}
        ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
        append to list    ${L_M55304C0800X}    ${result}
    END

    ${L_M55304C1000X}   create list
    ${M55304C1000X}    set variable    0
    FOR    ${num}    IN RANGE    0    10
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C1000${num}    cell_id=${cell_id}
        ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
        append to list    ${L_M55304C1000X}    ${result}
    END

    FOR    ${num}    IN RANGE    10    32
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C100${num}    cell_id=${cell_id}
        ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
        append to list    ${L_M55304C1000X}    ${result}
    END

    ${top_counter}    Evaluate    (${M55304C0400X}+${M55304C0800X}+${M55304C1000X})*8
    ${L_M55308}   create list
    ${M55308C03006}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C03006    cell_id=${cell_id}
    ${M55308C10002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10002    cell_id=${cell_id}
    ${M55308C00009}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00009    cell_id=${cell_id}
    ${M55308C00011}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00011    cell_id=${cell_id}
    append to list    ${L_M55308}    ${M55308C03006}
    append to list    ${L_M55308}    ${M55308C10002}
    append to list    ${L_M55308}    ${M55308C00009}
    append to list    ${L_M55308}    ${M55308C00011}
    ${bottom_counter}    Evaluate    ${M55308C03006}*180*(float(${M55308C10002})/(${M55308C00009}+${M55308C00011}))
    ${NR_5109d}    Evaluate    float(${top_counter}/${bottom_counter})
#    log to console    64qam:${L_M55304C0400X}
#    log to console    dft_s_ofdm:${L_M55304C0800X}
#    log to console    256qam:${L_M55304C1000X}
#    log to console    ${L_M55308}
#    log to console    SE_KPI_Value=${NR_5109d}

    ${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C12001    cell_id=${cell_id}
    ${NR_5258a}    evaluate    8*${MEAS_PERIOD_NR_MAC_PDU_TPUT}/1000000
#    log to console    KPI NR_5258a MAC SDU Cell Throughput in DL on DTCH is = ${NR_5258a}

    ${PDSCH_INI_VOL_64TBL_MCS_list}    create list
    ${PDSCH_INI_VOL_256TBL_MCS_list}    create list
    ${PDSCH_INI_VOL_LOWSE_MCS_list}    create list
    FOR    ${num}    IN RANGE    0    29
        ${counter_2}   evaluate   1000+${num}
        ${counter_3}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_2}    cell_id=${cell_id}
        append to list    ${PDSCH_INI_VOL_64TBL_MCS_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55366C0${counter_3}    cell_id=${cell_id}
        append to list    ${PDSCH_INI_VOL_LOWSE_MCS_list}    ${result}
    END

    FOR    ${num}    IN RANGE    0    28
        ${counter_3}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_3}    cell_id=${cell_id}
        append to list    ${PDSCH_INI_VOL_256TBL_MCS_list}    ${result}
    END

    ${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55304C00001    cell_id=${cell_id}
    ${PRB_USED_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10001    cell_id=${cell_id}
    ${PRB_AVAIL_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10003    cell_id=${cell_id}
#    log to console    PDSCH_INI_VOL_64TBL_MCS_list 0_to_28 is ${PDSCH_INI_VOL_64TBL_MCS_list}
#    log to console    PDSCH_INI_VOL_256TBL_MCS_list 0_to_27 is ${PDSCH_INI_VOL_256TBL_MCS_list}
#    log to console    MEAS_PERIOD_NR_MAC_PDU_TPUT is ${MEAS_PERIOD_NR_MAC_PDU_TPUT}
#    log to console    PRB_USED_PDSCH is ${PRB_USED_PDSCH}
#    log to console    PRB_AVAIL_PDSCH is ${PRB_AVAIL_PDSCH}

    ${PDSCH_INI_VOL_64TBL_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_64TBL_MCS_list})
    ${PDSCH_INI_VOL_256TBL_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_256TBL_MCS_list})
    ${PDSCH_INI_VOL_LOWSE_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_LOWSE_MCS_list})
    ${NR_5242b_fenzi1}    evaluate    8*(${PDSCH_INI_VOL_64TBL_MCS_sum}+${PDSCH_INI_VOL_256TBL_MCS_sum}+${PDSCH_INI_VOL_LOWSE_MCS_sum})
    ${NR_5242b_fenzi2}    evaluate    ${NR_5242b_fenzi1}/${MEAS_PERIOD_NR_MAC_PDU_TPUT}
    ${NR_5242b_fenmu}    evaluate    ${PRB_USED_PDSCH}/${PRB_AVAIL_PDSCH}
    ${NR_5242b}    evaluate    ${NR_5242b_fenzi2}/${NR_5242b_fenmu}
#    log to console    KPI NR_5242b MAC PDU Cell throughput on PDSCH considering PRB utilization is = ${NR_5242b}


    ${DL_MAC_SDU_VOL_DTCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C01001    cell_id=${cell_id}
    ${DATA_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00005    cell_id=${cell_id}
    ${DATA_SLOT_PDSCH_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00008    cell_id=${cell_id}
    ${ACC_UE_DL_DRB_DATA}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02000    cell_id=${cell_id}
    ${NR_5100b}    evaluate    8*${DL_MAC_SDU_VOL_DTCH}/(${ACC_UE_DL_DRB_DATA}*${DATA_SLOT_PDSCH_TIME}/${DATA_SLOT_PDSCH})

    ${ACC_SCHED_UE_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C17001    cell_id=${cell_id}
    ${TOTAL_COSCHED_UE_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02004    cell_id=${cell_id}
    ${DL_DATA_SLOTS}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00001    cell_id=${cell_id}
    ${DATA_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00005    cell_id=${cell_id}
    ${SSB_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00015    cell_id=${cell_id}
    ${TRS_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00017    cell_id=${cell_id}
    ${NR_5192c}    evaluate    ${ACC_SCHED_UE_PDSCH}/(${DATA_SLOT_PDSCH}+${SSB_SLOT_PDSCH}+${TRS_SLOT_PDSCH})
    ${NR_5112c}    evaluate    ${TOTAL_COSCHED_UE_PDSCH}/(${DL_DATA_SLOTS}+${SSB_SLOT_PDSCH}+${TRS_SLOT_PDSCH})

#NR_1418a Avg PDCCH DL CCE starv R
    ${SLT_UL_CCE_STARVATION_list}    create list
    ${SLT_DL_CCE_STARVATION_list}    create list
    ${SLT_UL_GRANT_CAPABILITY_list}    create list
    ${SLT_DL_GRANT_CAPABILITY_list}    create list
    FOR    ${num}    IN RANGE    2000    11000    3000
        ${counter_1}   evaluate   ${num}+1
        ${counter_2}   evaluate   ${num}+2
        ${counter_3}   evaluate   ${num}+3
        ${counter_4}   evaluate   ${num}+4
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55335C0${counter_1}    cell_id=${cell_id}
        append to list    ${SLT_UL_CCE_STARVATION_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55335C0${counter_2}    cell_id=${cell_id}
        append to list    ${SLT_DL_CCE_STARVATION_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55335C0${counter_3}    cell_id=${cell_id}
        append to list    ${SLT_UL_GRANT_CAPABILITY_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55335C0${counter_4}    cell_id=${cell_id}
        append to list    ${SLT_DL_GRANT_CAPABILITY_list}    ${result}
    END


    FOR    ${num}    IN RANGE    11000    31000    3000
        ${counter_1}   evaluate   ${num}+1
        ${counter_2}   evaluate   ${num}+2
        ${counter_3}   evaluate   ${num}+3
        ${counter_4}   evaluate   ${num}+4
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55335C${counter_1}    cell_id=${cell_id}
        append to list    ${SLT_UL_CCE_STARVATION_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55335C${counter_2}    cell_id=${cell_id}
        append to list    ${SLT_DL_CCE_STARVATION_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55335C${counter_3}    cell_id=${cell_id}
        append to list    ${SLT_UL_GRANT_CAPABILITY_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55335C${counter_4}    cell_id=${cell_id}
        append to list    ${SLT_DL_GRANT_CAPABILITY_list}    ${result}
    END

    ${Avg_PDCCH_CCE_starv_DL_UL}    evaluate    sum(${SLT_UL_CCE_STARVATION_list})+sum(${SLT_DL_CCE_STARVATION_list})
    ${Avg_PDCCH_CCE_capa}    evaluate    sum(${SLT_UL_GRANT_CAPABILITY_list})+sum(${SLT_DL_GRANT_CAPABILITY_list})
    ${Avg_PDCCH_CCE_starv_ratio}    evaluate    ${Avg_PDCCH_CCE_starv_DL_UL}/${Avg_PDCCH_CCE_capa}
    ${NR_5149a}    evaluate    ${Avg_PDCCH_CCE_starv_ratio}*1
#    log to console    KPI NR_5149a Avg_PDCCH_CCE_starv_ratio is = ${NR_5149a}

    ${Avg_PDCCH_CCE_starv_DL}    evaluate    sum(${SLT_DL_CCE_STARVATION_list})
    ${Avg_PDCCH_CCE_capa_DL}    evaluate    sum(${SLT_DL_GRANT_CAPABILITY_list})
    ${Avg_PDCCH_CCE_starv_DL_ratio}    evaluate    ${Avg_PDCCH_CCE_starv_DL}/${Avg_PDCCH_CCE_capa_DL}
    ${NR_1418a}    evaluate    ${Avg_PDCCH_CCE_starv_DL_ratio}*1
#    log to console    KPI NR_1418a Avg_PDCCH_CCE_starv_DL_ratio is = ${NR_1418a}

    ${Avg_PDCCH_CCE_starv_UL}    evaluate    sum(${SLT_UL_CCE_STARVATION_list})
    ${Avg_PDCCH_CCE_capa_UL}    evaluate    sum(${SLT_UL_GRANT_CAPABILITY_list})
    ${Avg_PDCCH_CCE_starv_UL_ratio}    evaluate    ${Avg_PDCCH_CCE_starv_DL}/${Avg_PDCCH_CCE_capa_UL}
    ${NR_1419a}    evaluate    ${Avg_PDCCH_CCE_starv_UL_ratio}*1
#    log to console    KPI NR_1419a Avg_PDCCH_CCE_starv_UL_ratio is = ${NR_1419a}

#NR_5120a Avg nr act UEs data buff DRBs DL
	${ACC_UE_DL_DRB_DATA}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02000    cell_id=${cell_id}
    ${SAMPLE_CNT_NR_CELL_UTIL_DL}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C01000    cell_id=${cell_id}
    ${Avg_num_act_UEs_with_databuffer_DL}    evaluate    ${ACC_UE_DL_DRB_DATA}/${SAMPLE_CNT_NR_CELL_UTIL_DL}
    ${NR_5120a}    evaluate    ${Avg_num_act_UEs_with_databuffer_DL}*1
#    log to console    KPI NR_5120a Avg_num_act_UEs_with_databuffer_DL is = ${NR_5120a}

#NR_5121a Avg nr act UEs data buff DRBs UL
	${ACC_UE_UL_DRB_DATA}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02002    cell_id=${cell_id}
    ${SAMPLE_CNT_NR_CELL_UTIL_UL}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C01001    cell_id=${cell_id}
    ${Avg_num_act_UEs_with_databuffer_UL}    evaluate    ${ACC_UE_UL_DRB_DATA}/${SAMPLE_CNT_NR_CELL_UTIL_UL}
    ${NR_5121a}    evaluate    ${Avg_num_act_UEs_with_databuffer_UL}*1
#    log to console    KPI NR_5121a Avg_num_act_UEs_with_databuffer_UL is = ${NR_5121a}

#NR_5192e Avg UEs per sl DL FDM MUMIMO
	${ACC_SCHED_UE_PDSCH_NOPAGING}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10010    cell_id=${cell_id}
    ${DATA_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00005    cell_id=${cell_id}
	${SSB_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00015    cell_id=${cell_id}
    ${TRS_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00017    cell_id=${cell_id}
    ${fenmu22}    evaluate    (${DATA_SLOT_PDSCH})+(${SSB_SLOT_PDSCH})+(${TRS_SLOT_PDSCH})
    ${NR_5192e}    evaluate    ${ACC_SCHED_UE_PDSCH_NOPAGING}/${fenmu22}
#    log to console    KPI NR_5192e Avg_UEs_per_sl_DL_FDM_MUMIMO is = ${NR_5192e}

#NR_5193b Avg UEs per sl UL FDM MUMIMO
	${ACC_SCHED_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C18001    cell_id=${cell_id}
    ${DATA_SLOT_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00006    cell_id=${cell_id}
	${PRACH_SLOTS_PUSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00010    cell_id=${cell_id}

    ${fenmu33}    evaluate    ${DATA_SLOT_PUSCH}+${PRACH_SLOTS_PUSCH}
    ${NR_5193b}    evaluate    ${ACC_SCHED_UE_PUSCH}/${fenmu33}
#    log to console    KPI NR_5193b Avg_UEs_per_sl_UL_FDM_MUMIMO is = ${NR_5193b}

#NR_5056b UL init BLER PUSCH
    ${initial_transmissions_sent}    create list
    ${initial_transmissions_SUC}    create list
    ${initial_transmissions_failed}    create list

    FOR    ${num}    IN RANGE    0    10
        ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55302C0000${num}    cell_id=${cell_id}
        append to list    ${initial_transmissions_sent}    ${result}
    END

    FOR    ${num}    IN RANGE    10    29
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55302C000${num}    cell_id=${cell_id}
        append to list    ${initial_transmissions_sent}    ${result}
    END

    FOR    ${num}    IN RANGE    0    28
        ${counter}   evaluate   6000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55302C0${counter}    cell_id=${cell_id}
        append to list    ${initial_transmissions_sent}    ${result}
    END

    FOR    ${num}    IN RANGE    0    28
        ${counter}   evaluate   11000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55302C${counter}    cell_id=${cell_id}
        append to list    ${initial_transmissions_sent}    ${result}
    END

    ${ini_send}    evaluate    sum(${initial_transmissions_sent})

    FOR    ${num}    IN RANGE    0    29
        ${counter}   evaluate   4000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55302C0${counter}    cell_id=${cell_id}
        append to list    ${initial_transmissions_SUC}    ${result}
    END

    FOR    ${num}    IN RANGE    0    28
        ${counter}   evaluate   8000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55302C0${counter}    cell_id=${cell_id}
        append to list    ${initial_transmissions_SUC}    ${result}
    END

    FOR    ${num}    IN RANGE    0    28
        ${counter}   evaluate   13000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55302C${counter}    cell_id=${cell_id}
        append to list    ${initial_transmissions_SUC}    ${result}
    END

    ${ini_send_succ}    evaluate    sum(${initial_transmissions_SUC})

    ${unsucc_pusch}    evaluate    ${ini_send}-${ini_send_succ}
    ${NR_5056b}    evaluate    ${unsucc_pusch}/${ini_send}
#    log to console    KPI NR_5056b UL_init_BLER_PUSCH is = ${NR_5056b}

#NR_5057c UL resid BLER PUSCH
    ${transmissions_failed_after_max_retry}    create list
    ${successful_transmissions}    create list
    FOR    ${num}    IN RANGE    0    32
        ${counter}   evaluate   3000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55302C0${counter}    cell_id=${cell_id}
        append to list    ${transmissions_failed_after_max_retry}    ${result}
    END

    FOR    ${num}    IN RANGE    0    32
        ${counter}   evaluate   7000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55302C0${counter}    cell_id=${cell_id}
        append to list    ${transmissions_failed_after_max_retry}    ${result}
    END

    FOR    ${num}    IN RANGE    0    32
        ${counter}   evaluate   12000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55302C${counter}    cell_id=${cell_id}
        append to list    ${transmissions_failed_after_max_retry}    ${result}
    END

    ${retrans_fail}    evaluate    sum(${transmissions_failed_after_max_retry})

    FOR    ${num}    IN RANGE    0    32
        ${counter}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55302C0${counter}    cell_id=${cell_id}
        append to list    ${successful_transmissions}    ${result}
    END

    FOR    ${num}    IN RANGE    0    32
        ${counter}   evaluate   9000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55302C0${counter}    cell_id=${cell_id}
        append to list    ${successful_transmissions}    ${result}
    END

    FOR    ${num}    IN RANGE    0    32
        ${counter}   evaluate   14000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55302C${counter}    cell_id=${cell_id}
        append to list    ${successful_transmissions}    ${result}
    END

    ${ini_retrans_succ}    evaluate    sum(${successful_transmissions})
    ${NR_5057c}    evaluate    ${retrans_fail}/(${ini_retrans_succ}+${retrans_fail})
#    log to console    KPI NR_5057c UL_init_BLER_PUSCH is = ${NR_5057c}

#NR_5068a Avg DL MCS, 256QAM
    ${packets_sent_with_MCSx_and_256QAM_table}    create list
    ${packets_sent_with_MCSx_and_256QAM_table_XX}    create list
    FOR    ${num}    IN RANGE    0    28
        ${counter}   evaluate   4000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter}    cell_id=${cell_id}
        append to list    ${packets_sent_with_MCSx_and_256QAM_table}    ${result}
        ${result_1}   evaluate   ${num}*${result}
        append to list    ${packets_sent_with_MCSx_and_256QAM_table_XX}    ${result_1}
    END

    ${fenzi223}    evaluate    sum(${packets_sent_with_MCSx_and_256QAM_table_XX})
    ${fenmu223}    evaluate    sum(${packets_sent_with_MCSx_and_256QAM_table})
    ${NR_5068a}    evaluate    ${fenzi223}/${fenmu223}
#     log to console    KPI NR_5068a Avg_DL_MCS_256QAM is = ${NR_5068a}

#Nr_5105a Avg UL MCS 256QAM
    ${packets_sent_with_MCSx_and_256QAM_table_UL}    create list
    ${packets_sent_with_MCSx_and_256QAM_table_XX_UL}    create list
    FOR    ${num}    IN RANGE    0    28
        ${counter}   evaluate   11000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55302C${counter}    cell_id=${cell_id}
        append to list    ${packets_sent_with_MCSx_and_256QAM_table_UL}    ${result}
        ${result_1}   evaluate   ${num}*${result}
        append to list    ${packets_sent_with_MCSx_and_256QAM_table_XX_UL}    ${result_1}
    END

    ${fenzi224}    evaluate    sum(${packets_sent_with_MCSx_and_256QAM_table_XX_UL})
    ${fenmu224}    evaluate    sum(${packets_sent_with_MCSx_and_256QAM_table_UL})
    ${Nr_5105a}    evaluate    ${fenzi224}/${fenmu224}
#     log to console    KPI Nr_5105a Avg_UL_MCS_256QAM is = ${Nr_5105a}

#Nr_5105a Avg UL MCS 256QAM
    ${AL_USED_PDCCH_list}    create list
    FOR    ${num}    IN RANGE    1    6
        ${counter}   evaluate   19000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55308C${counter}    cell_id=${cell_id}
        append to list    ${AL_USED_PDCCH_list}    ${result}
    END

#    log to console    PM counter AL_USED_PDCCH_list_1_2_4_8_16 is = ${AL_USED_PDCCH_list}
#    log to console    PM counter AL1_USED_PDCCH is = ${AL_USED_PDCCH_list[0]}
#    log to console    PM counter AL2_USED_PDCCH is = ${AL_USED_PDCCH_list[1]}
#    log to console    PM counter AL2_USED_PDCCH is = ${AL_USED_PDCCH_list[2]}
#    log to console    PM counter AL3_USED_PDCCH is = ${AL_USED_PDCCH_list[3]}
#    log to console    PM counter AL4_USED_PDCCH is = ${AL_USED_PDCCH_list[4]}


    log to console    cell_id ${cell_id}----KPI NR_5108d SE_downlink is = ${NR_5108d}
    log to console    cell_id ${cell_id}----KPI NR_5109d SE_uplink is = ${NR_5109d}
    log to console    cell_id ${cell_id}----KPI NR_5242b MAC PDU Cell throughput on PDSCH considering PRB utilization is = ${NR_5242b}
    log to console    cell_id ${cell_id}----KPI NR_5258a MAC SDU Cell Throughput in DL on DTCH is = ${NR_5258a}
    log to console    cell_id ${cell_id}----KPI NR_5100b Avg MAC user thp DL = ${NR_5100b}
    log to console    cell_id ${cell_id}----KPI NR_5192c Average number of scheduled UEs on PDSCH = ${NR_5192c}

    log to console   cell_id ${cell_id}----PM counter AL_USED_PDCCH_list_1_2_4_8_16 is = ${AL_USED_PDCCH_list}
    log to console   cell_id ${cell_id}----PM counter AL1_USED_PDCCH is = ${AL_USED_PDCCH_list[0]}
    log to console   cell_id ${cell_id}----PM counter AL2_USED_PDCCH is = ${AL_USED_PDCCH_list[1]}
    log to console   cell_id ${cell_id}----PM counter AL4_USED_PDCCH is = ${AL_USED_PDCCH_list[2]}
    log to console   cell_id ${cell_id}----PM counter AL8_USED_PDCCH is = ${AL_USED_PDCCH_list[3]}
    log to console   cell_id ${cell_id}----PM counter AL16_USED_PDCCH is = ${AL_USED_PDCCH_list[4]}
    log to console   cell_id ${cell_id}----KPI NR_5149a_Avg_PDCCH_CCE_starv_ratio is = ${NR_5149a}
    log to console   cell_id ${cell_id}----KPI NR_1418a_Avg_PDCCH_CCE_starv_DL_ratio is = ${NR_1418a}
    log to console   cell_id ${cell_id}----KPI NR_1419a_Avg_PDCCH_CCE_starv_UL_ratio is = ${NR_1419a}
    log to console   cell_id ${cell_id}----KPI NR_5120a_Avg_num_act_UEs_with_databuffer_DL is = ${NR_5120a}
    log to console   cell_id ${cell_id}----KPI NR_5121a_Avg_num_act_UEs_with_databuffer_UL is = ${NR_5121a}
    log to console   cell_id ${cell_id}----KPI NR_5192e_Avg_UEs_per_sl_DL_FDM_MUMIMO is = ${NR_5192e}
    log to console   cell_id ${cell_id}----KPI NR_5193b_Avg_UEs_per_sl_UL_FDM_MUMIMO is = ${NR_5193b}
    log to console   cell_id ${cell_id}----KPI NR_5056b_UL_init_BLER_PUSCH is = ${NR_5056b}
    log to console   cell_id ${cell_id}----KPI NR_5057c_UL_resid_BLER_PUSCH is = ${NR_5057c}
    log to console   cell_id ${cell_id}----KPI NR_5055b_residual bler is = ${NR_5055b}
    log to console   cell_id ${cell_id}----KPI NR_5054a_iniBler is = ${NR_5054a}
    log to console   cell_id ${cell_id}----KPI NR_5068a_Avg_DL_MCS_256QAM is = ${NR_5068a}
    log to console   cell_id ${cell_id}----KPI Nr_5105a_Avg_UL_MCS_256QAM is = ${Nr_5105a}
#    run keyword and continue on failure   should be true   ${NR_5054a}<0.1
#    run keyword and continue on failure   should be true   ${NR_5055b}<0.005
    ${CNI122436_kpi_list}   create list    ${AL_USED_PDCCH_list[0]}    ${AL_USED_PDCCH_list[1]}    ${AL_USED_PDCCH_list[2]}
        ...    ${AL_USED_PDCCH_list[3]}    ${AL_USED_PDCCH_list[4]}    ${NR_5149a}    ${NR_1418a}    ${NR_1419a}    ${NR_5120a}
        ...    ${NR_5121a}    ${NR_5192e}    ${NR_5193b}    ${NR_5056b}    ${NR_5057c}    ${NR_5055b}    ${NR_5054a}
        ...    ${NR_5068a}    ${Nr_5105a}

    [return]     ${CNI122436_kpi_list}

Build excel table
    ${first_colomn}   create list
    append to list    ${first_colomn}    AL1_USED_PDCCH    AL2_USED_PDCCH    AL4_USED_PDCCH    AL8_USED_PDCCH    AL16_USED_PDCCH
    append to list    ${first_colomn}    NR_5149a_Avg_PDCCH_CCE_starv_ratio
    append to list    ${first_colomn}    KPI NR_1418a_Avg_PDCCH_CCE_starv_DL_ratio
    append to list    ${first_colomn}    KPI NR_1419a_Avg_PDCCH_CCE_starv_UL_ratio
    append to list    ${first_colomn}    KPI NR_5120a_Avg_num_act_UEs_with_databuffer_DL
    append to list    ${first_colomn}    KPI NR_5121a_Avg_num_act_UEs_with_databuffer_UL
    append to list    ${first_colomn}    KPI NR_5192e_Avg_UEs_per_sl_DL_FDM_MUMIMO
    append to list    ${first_colomn}    KPI NR_5193b_Avg_UEs_per_sl_UL_FDM_MUMIMO
    append to list    ${first_colomn}    KPI NR_5056b_UL_init_BLER_PUSCH
    append to list    ${first_colomn}    KPI NR_5057c_UL_resid_BLER_PUSCH
    append to list    ${first_colomn}    KPI NR_5055b_residual bler
    append to list    ${first_colomn}    KPI NR_5054a_iniBler
    append to list    ${first_colomn}    KPI NR_5068a_Avg_DL_MCS_256QAM
    append to list    ${first_colomn}    KPI Nr_5105a_Avg_UL_MCS_256QAM
    modify excel cell       ${TEST_LOG_DIRECTORY()}/All/CNI122436_KPI.xls     Sheet1     0    0    ${SOFTWARE_INFO}_CNI122436_KPI_CASE07
    {list_num}    evaluate    len(${first_colomn})
    FOR    ${num}    IN RANGE    0    {list_num}+1
        ${num_table}    evaluate    ${num}+1
        modify excel cell       ${TEST_LOG_DIRECTORY()}/All/CNI122436_KPI.xls     Sheet1     ${num_table}    0    ${colomn_9235[${num}]}
    END

Online change parameters
    [Arguments]    ${delta_122436_24R1_2}    ${Cell1_tmp1}    ${Cell1_tmp2}    ${Cell2_tmp1}    ${Cell2_tmp2}
    log to console    ${delta_122436_24R1_2} ${Cell1_tmp1} ${Cell1_tmp2} ${Cell2_tmp1} ${Cell2_tmp2}
    ${template}    OperatingSystem.Get File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_122436_24R1_2}.json
    log to console    ${template}
    ${message} =    Replace Variables    ${template}
    Create File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_122436_24R1_2}_modified.json    ${message}
    Online recommissioning with delta json file
    ...   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_122436_24R1_2}_modified.json
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair

Online change parameters_24R3
    [Arguments]    ${delta_122436_24R3}    ${pdcchBlerTarget}    ${pdcchBlerTargetHR}
    log to console    ${delta_122436_24R3} ${pdcchBlerTarget} ${pdcchBlerTargetHR}
    ${template}    OperatingSystem.Get File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_122436_24R3}.json
    log to console    ${template}
    ${message} =    Replace Variables    ${template}
    Create File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_122436_24R3}_modified.json    ${message}
    Online recommissioning with delta json file
    ...   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_122436_24R3}_modified.json
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair

Add HR bear to UEs
    [Arguments]     ${ue_start}=1    ${ue_end}=5
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
        airphone_execute_egate_command    ue_pdu_session_modify ue\=${num} pdu\=${gw_pdu_r} qosflows_to_add\=4 by\=amf
       Log To Console   add HR to UE_${num}
    END

Add PDCCH_DTX to UEs
    [Arguments]     ${ue_start}=1    ${ue_end}=5
    airphone_execute_egate_command    bler_testmode_nr profile_id\=2 pdcch_misd_rate\=${pdcch_misd_rate}    #add pdcch dtx
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} scell\=0 testmode\=bler profile_id\=2 action\=activate
       Log To Console   add PDCCH_DTX to UE_${num}
    END


step5:send full buffer for T_F_T 3CC UE2 and check logs
    Log To Console   \n-------------step5:send full buffer for T_F_T 3CC UE2 and check logs---------------
    Start capture only gnb syslog in 'step5' file
    SA send full data buffer    ue_start=2    ue_end=2   data=150M
	run keyword and continue on failure	   Check non_CA SA UE throughput    ue_start=2    ue_end=2    dl_target=15000    ul_target=2000
    Collect ttitrace and Check    tti_tag=tti_step5_UE1_UE2    ini_file=Case36_step5_tti
    Send A1 event for UE'2' to add scell
    Collect ttitrace and Check    tti_tag=tti_step5_UE1_UE2_CA    ini_file=Case36_step5_tti_CA
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step5' file '${custom_error}'
    Collect AP egate log    step5

Send A1 event for UE'${UE_ID}' to add scell
    airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=100
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=0
    airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID} meas_obj_type\=nr\r


Send A1 event for UEs to add scell
    [Arguments]     ${ue_start}=1    ${ue_end}=5
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=100
    END
    Wait '10s' for stable

step5:override UE1 to rank1 and check logs
    Log To Console   \n-------------step5:override UE1 to rank1 and check logs---------------
    Start collect UE f1ap    step5_ue1_aperisrs_ue5RTbeam
    Airphone SA Stop Data    ue_start=6    ue_end=8
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=0  #rank1
    Wait '5s' for stable
    Stop collect UE f1ap    step5_ue1_aperisrs_ue5RTbeam
    Check UE srs_switch from s1ap    step5_ue1_aperisrs_ue5RTbeam    Case27_step5_F1ap_1
    SA send data for UEs    ue_start=6    ue_end=8
    Wait '5s' for stable
    run keyword and continue on failure	   Check SA UE throughput    ue_start=2    ue_end=8
    Collect ttitrace and Check    tti_tag=tti_step5    ini_file=Case27_step5_tti
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
    Wait '5s' for stable
    run keyword and continue on failure	   Check SA UE throughput    ue_start=1    ue_end=8

step6:detach and reattach ue1 and check rrc
    Log To Console   \n-------------step6:detach and reattach ue1 and check rrc---------------
    Airphone SA Detach UE    1    1
    Attach SA UEs with f1ap    1    1
    SA send data for UEs    ue_start=1    ue_end=1
    run keyword and continue on failure	   Check SA UE throughput    ue_start=1    ue_end=8
    Collect ttitrace and Check    tti_tag=tti_step6    ini_file=Case27_step6_tti
    Airphone SA Detach UE

step7:online change bfSubbandSize and run case again
    Log To Console   \n-------------step7:online change bfSubbandSize and run case again---------------
    Online change bfSubbandSize enabled
    Attach SA UEs with f1ap    ue_start=1    ue_end=18    tag=2
    SA send data for all 20UEs
	run keyword and continue on failure	   Check SA UE throughput    ue_start=1    ue_end=8
    Collect ttitrace and Check    tti_tag=tti_step3    ini_file=Case27_step7_tti    tag=2

Online change bfSubbandSize enabled
    Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8322_case27_16PRB.json
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    Wait '15s' for stable

step5:set 4port high power for UEs and check logs
    Log To Console   \n-------------step5:set 4port high power for UEs and check logs---------------
    Set ports power and creat file    profile_id=3    port1_power=-500    port2_power=-500    port3_power=-500    port4_power=-500
    FOR    ${num}    IN RANGE    ${UE_NUM_SA}    0    -1
        Start collect UE f1ap    step5_srsModify_${num}
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
        Wait '2s' for stable
        Stop collect UE f1ap    step5_srsModify_${num}
    END
    Check UE srs_switch from s1ap    step5_srsModify_2    Case16_step5_F1ap_2
    run keyword and continue on failure	   Check SA UE throughput    UE1_layer=4    UE2_layer=4
    Collect ttitrace and Check    tti_tag=tti_step5    ini_file=Case16_step5_tti


#get F1AP and UE id for test start
Start collect UE f1ap
    [Arguments]     ${bip_file}
    Log To Console    Start collect '${bip_file}' tcpdump
    ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
    Start Tcpdump    name=${bip_file}    options= -i any -C 300    remote_info=${executor_oam_vm}

Stop collect UE f1ap
    [Arguments]     ${bip_file}
    Log To Console    Stop collect '${bip_file}' tcpdump
    Stop Tcpdump    ${bip_file}    ${TEST_LOG_DIRECTORY()}/All/${bip_file}

Get Crnti and gnb_du_id from f1ap
    [Arguments]     ${bip_file}    ${ue_id}
    Log To Console   Check '${bip_file}' Crnti and gnb_du_id
    Run Keyword And ignore error    Convert BIP To CSV
    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_rrc_itl_l2ps}    ${titles_duID_Crnti}
    ${gnb_du_id_list}    Get col_values from bip csv    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    f1ap.GNB_DU_UE_F1AP_ID
    Set Test Variable    ${ue${ue_id}_gnb_du_id}    ${gnb_du_id_list[0]}
    ${ue_rnti}    Get col_values from bip csv    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    3gpp.rnti
    set suite variable     ${ue${ue_id}_rnti}    ${ue_rnti[0]}
    Log To Console   \n------UE${ue_id} gnb_du_id is ${ue${ue_id}_gnb_du_id},crnti is ${ue${ue_id}_rnti}-----



Get col_values from bip csv
    [Arguments]    ${csv_file}    ${col_name}
    ${col_values}    read_csv_columns    ${csv_file}    ${col_name}
    ${col_value_list}    Remove Duplicates    ${col_values}
    [return]     ${col_value_list}

Check UE srs_switch from s1ap
    [Arguments]     ${bip_file}    ${ini_path}
    Log To Console   Check '${bip_file}' srs_switch
    Run Keyword And ignore error    Convert BIP To CSV
    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_srsModify}    ${titles_tasSrsResourceInd}
    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/${ini_path}.ini     i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_file}/
#get F1AP and UE id for test end


Set ports power and creat file
    [Arguments]     ${profile_id}    ${port1_power}    ${port2_power}    ${port3_power}=-750    ${port4_power}=-750
    ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=${profile_id} mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
    ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0
    ...    srs_transmit_power_per_port\=${port1_power},${port2_power},${port3_power},${port4_power}
    airphone_execute_egate_command    ${cmd}

Collect bip and Check
    Start collect bip log
    Wait for '1s' to stop bip log with name'${BIP_TAG1}'

Add RD
    Add GNB swconfig	0x9D0000:15

Collect ttitrace and Check
    [Arguments]     ${tti_tag}    ${ini_file}    ${cell_id}=all
    log to console    start collect ttitrace
    Start GNB Ttitrace With Streaming Mode    cell_id=${cell_id}    up_sw=L2Ps     name=${tti_tag}
    Wait for '0.5s' to stop ttitrace with name'${tti_tag}'
    run keyword and continue on failure	   Check ttitrace with ini    ${tti_tag}   ${ini_file}
    run keyword and continue on failure	   Check ttitrace with ini    ${tti_tag}   tti_ul
#   run keyword and continue on failure	   split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${tti_tag}/tti_dl.csv



Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode    name=${tti_tag}
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti

Check ttitrace with ini
    [Arguments]     ${tti_tag}    ${ini_file}
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_tag}/

SA send data for UEs
    [Arguments]     ${ue_start}    ${ue_end}
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        SA send mutiple trf dl data    ${num}    1   120M   1    tcp
        SA send mutiple trf ul data    ${num}    1    10M   1
    END

SA send data for all 20UEs
    FOR    ${num}    IN RANGE    1    5
        SA send mutiple trf dl data    ${num}    1   120M   1    tcp
        SA send mutiple trf ul data    ${num}    1    10M   1
    END
    Wait '3s' for stable
    FOR    ${num}    IN RANGE    5    9
        SA send mutiple trf dl data    ${num}    1   120M   1    tcp
        SA send mutiple trf ul data    ${num}    1    10M   1
    END
    Wait '3s' for stable
    FOR    ${num}    IN RANGE    9    19
        SA send mutiple trf dl data    ${num}    1   10k   1    tcp
        SA send mutiple trf ul data    ${num}    1   10k   1
    END

Check non_CA SA UE throughput
    [Arguments]     ${ue_start}    ${ue_end}    ${dl_target}    ${ul_target}=100
    Wait until keyword succeeds    48s    8s    Verify non_CA SA UE throughput    ${ue_start}    ${ue_end}    ${dl_target}    ${ul_target}

Verify non_CA SA UE throughput
    [Arguments]     ${ue_start}    ${ue_end}    ${dl_target}    ${ul_target}
    ${UEs_TP_DL}   create list
    ${UEs_TP_UL}   create list
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#        run keyword and continue on failure    should_be_true    ${dl_throughput_pcell}>${dl_target}
#        run keyword and continue on failure    should_be_true    ${ul_throughput_pcell}>${ul_target}
        append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
        append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
    END
    log to console    dl_target ${dl_target} and ul_target ${ul_target}
    log to console    UE${ue_start} to UE${ue_end} DL_TP_result are ${UEs_TP_DL}
    log to console    UE${ue_start} to UE${ue_end} UL_TP_result are ${UEs_TP_UL}

Verify multi SA UEs throughput
    [Arguments]     ${ue_start}    ${ue_end}    ${dl_target}    ${ul_target}
    ${UEs_TP_DL}   create list
    ${UEs_TP_UL}   create list
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        run keyword and continue on failure    should_be_true    ${dl_throughput_pcell}>120000
        run keyword and continue on failure    should_be_true    ${ul_throughput_pcell}>10000
        append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
        append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
    END
    log to console    dl_target ${dl_target} and ul_target ${ul_target}
    log to console    UE${ue_start} to UE${ue_end} DL_TP_result are ${UEs_TP_DL}
    log to console    UE${ue_start} to UE${ue_end} UL_TP_result are ${UEs_TP_UL}



Create SRS_pos profile
    airphone_execute_egate_command    ${PROFILE2}

set SA UEs Pos
    [Arguments]     ${ue_start}=1    ${ue_end}=5
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    END

SA send data buffer
    [Arguments]     ${ue_start}=1    ${ue_end}=5    ${data}=15M    ${data_num}=1
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
        SA send mutiple trf dl data    ${num}    ${data_num}   ${data}   ${gw_pdu_r}    tcp
        SA send mutiple trf ul data    ${num}    1    20M   ${gw_pdu_r}
       Log To Console   send data for UE_${num}
    END

SA send data buffer DL only
    [Arguments]     ${ue_start}=1    ${ue_end}=5    ${data}=15M    ${data_num}=1
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
        SA send mutiple trf dl data    ${num}    ${data_num}   ${data}   ${gw_pdu_r}    tcp
        SA send mutiple trf ul data    ${num}    1    20M   ${gw_pdu_r}
       Log To Console   send data for UE_${num}
    END

Airphone SA Stop Data
    [Arguments]     ${ue_start}=1    ${ue_end}=${UE_NUM_SA}
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        ${gw_pdu_r}    evaluate    ${num}%10+1
        Airphone SA Stop Data Traffic     ${num}     bi    ${gw_pdu_r}
    END

Airphone SA Detach UE
    [Arguments]     ${ue_start}=1    ${ue_end}=${UE_NUM_SA}
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        Airphone SA Detach    ue_id=${num}
    END

Attach SA UEs with f1ap
    [Arguments]     ${ue_start}=1    ${ue_end}=${UE_NUM_SA}    ${tag}=1
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
       Start collect UE f1ap    UE${num}_attach_f1ap_${tag}
       Airphone SA Attach    ue_id=${num}
       Airphone Set Traffic Type    ue_id=${num}    pdu_id=${gw_pdu_r}    type=internal
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}   nwslice_id=1   gw_id=${gw_pdu_r}
       Wait '1s' for stable
       Log To Console   attach UE${num} successfully
       Stop collect UE f1ap    UE${num}_attach_f1ap_${tag}
       Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap_${tag}    ${num}
    END

Get counter file
    Wait '30s' for stable
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    log to console    ${remaining_time}
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
    [Return]    ${PM_counter_file}

capture snapshot start once
    [Arguments]    ${log_tag}
    Log To Console    --capture snapshot start
    Run Keyword And Ignore Error    Collect GNB SnapShot    target_file_name=${TEST_LOG_DIRECTORY()}/All/${log_tag}_gnb_comon_snapshot.zip
