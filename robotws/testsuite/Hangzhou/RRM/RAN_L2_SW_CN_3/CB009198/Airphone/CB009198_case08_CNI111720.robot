*** Settings ***
Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_BLLL_AP_LOO    AP    owner_l3gao    CRT    SBTS00
...      RAN_5G_TDD    RAN_5G
Resource          ../../resources/KISS/robot/common_resource.robot
Resource          ../../resources/sg10/internal_resource/internal_resource.robot
Documentation
...     AdditionalDMRS_Auto   --change to one additional with ulptrs false

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
#${SCFC_NAME}    CB009198_CASE08_BLLL_CNI111720.xml
#${AIRPHONE_NAME}    IPHY_AEQE_2CELL_BLLL_AP_LOO_difNrafcn.xml
#${WTS_NAME}      WTS_SANSA_n78_8SA_32NSA_8DL4UL_2CELL_MU_APLO.cfg
${SCFC_NAME}    CB009198_CASE09_BLLL.xml
${AIRPHONE_NAME}    IPHY_AEQE_2CELL_2BLLL_AP_LOO.xml
${WTS_NAME}      WTS_SANSA_n78_8SA_32NSA_8DL4UL_2CELL_MU_APLO_111720.cfg
${UE_ID1}         1
${UE_ID2}         2
${UE_ID3}         3
${UE_ID4}         4
@{LOG_NAME_LIST}    gnb_snapshot    # ap_snapshot    egatelog
${FILTER_1}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
@{titles_1}    DlData_PdschGrant.bestBeamPowerOffset
&{GNBMIRRORINGCONFIGS}    BB_SLOT_1='false'    BB_SLOT_2='false'    BB_SLOT_5='true'    L2_L1_BIP='true'
...    NUMBER_OF_FILES=10    FILE_SIZE_MBYTES=100
...    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='false'   L2RT_MIRRORING='false'    CPRT_MIRRORING='false'
${UE_NUM}         60
${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
@{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch

*** Test Cases ***
CB009198_B_B9_case08_SA_PUSCH_typeA_DMRSpos3_PTRSOFF_AdditionalDMRS_Auto_And_DFT_S_OFDM
    ${custom_error}    Create list    ERR/.uplane    ERR/L2-PS    ERR/l1_application_rt    WRN/.uplane    WRN/L2-PS
	Set Test Variable    ${custom_error}
    Add RD
    Prepare gnb onair
    Attach '${UE_NUM}' SA UE
    Start capture gnb and ap syslog in 'case08_all' file
    SA '${UE_NUM}' UE Data buffer send
    Wait '5s' for stable
    Check multi UE throughput    UE_start=1
    Add pathloss110 to UE to decrease SINR to trigger precoder enable
    capture snapshot start once    pathloss110
    Check multi UE throughput    UE_start=1
    Add pathloss10 to UE to increase SINR to trigger precoder disable
    capture snapshot start once    pathloss10
#    Add pathloss to UE step by step
    Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'case08_all' file '${custom_error}'

*** Keywords ***
capture snapshot start once
    [Arguments]    ${log_tag}
    Log To Console    --capture snapshot start
    Run Keyword And Ignore Error    Collect GNB SnapShot    target_file_name=${TEST_LOG_DIRECTORY()}/All/${log_tag}_gnb_comon_snapshot.zip

Add RD
    Add GNB swconfig    0x9D0000:15
#    Add GNB swconfig    0x580981:1    #enable CNI111720

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode    name=${tti_tag}
#    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti

SA '${UE_NUM}' UE Data buffer send
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
       SA send mutiple trf dl data    ${num}    1   55M    ${gw_pdu_r}    tcp
       SA send mutiple trf ul data    ${num}    1   5M    ${gw_pdu_r}    tcp
    END

Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
       Airphone SA Stop Data Traffic     ${num}     BI    ${gw_pdu_r}
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '4s' for stabible
    END

Execute AP Command before attach
    airphone_cleanup_egate_console_log
    Airphone Setup X2 Connection
et UEs Pos
check_SRS_resource_and_PDSCH_scramblingID
    [Arguments]    ${EGATE_TAG}
    check_log_with_au2anlysis    ${CURDIR}/ini/check_SRS_resource_and_PDSCH_scramblingID_8701_case02.ini    p
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate


Check mupair in ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/8701_case02_mupair.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Overide UE bler
   airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=100,2,3,4,5,6
   airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
   airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=activate
   airphone_execute_egate_command    ue_testmode_set_nr id\=3 scell\=0 testmode\=bler profile_id\=1 action\=activate
   airphone_execute_egate_command    ue_testmode_set_nr id\=4 scell\=0 testmode\=bler profile_id\=1 action\=activate

Start collect UE'${ue_id}' tcpdump
    Log To Console    Start collect UE'${ue_id}' tcpdump
    ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
    Start Tcpdump    name=tcp_attach_ue${ue_id}    options= -i any -C 100   remote_info=${executor_oam_vm}

Stop collect UE'${ue_id}' tcpdump
    Log To Console    Stop collect UE'${ue_id}' tcpdump
    Stop Tcpdump    tcp_attach_ue${ue_id}    ${TEST_LOG_DIRECTORY()}/All/tcpdump

Check UE'${ue_id}' DFTS disable in attach_tcpdump
    Log To Console   Check UE'${ue_id}' DFTS disable
    Run Keyword And ignore error    Convert BIP To CSV
    ...    ${TEST_LOG_DIRECTORY()}/All/tcpdump/tcp_attach_ue${ue_id}.pcap
    ...    ${TEST_LOG_DIRECTORY()}/All/tcpdump/f1ap${ue_id}.csv    ${FILTER_f1ap}    ${titles_f1ap}

    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tcpdump_attach_ue${ue_id}_case3.ini    i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/tcpdump

Check throughput
    [Arguments]    ${ue1_dl_tput}    ${ue1_ul_tput}
    Wait until keyword succeeds    60s    5s    Verify throughput    ${ue1_dl_tput}    ${ue1_ul_tput}

Check multi UE throughput
    [Arguments]     ${UE_start}
    FOR    ${num}    IN RANGE    ${UE_start}    ${UE_start}+${UE_NUM}
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        Log To Console    \nUE_${num}_PcellTP_${dl_throughput_pcell}_ULTP_${ul_throughput_pcell}
    END

Verify throughput
    [Arguments]    ${ue1_dl_tput}    ${ue1_ul_tput}
    ${UEs_TP_DL}   create list
    ${UEs_TP_UL}   create list
    ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
    ${ul_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pusch    tput_type=ave
    Log To Console    ue1_dl_tput:${dl_throughput_ue1}  ue1_target:${ue1_dl_tput}
    Log To Console    ue1_UL_tput:${ul_throughput_ue1}  ue1_target:${ue1_ul_tput}
    run keyword and continue on failure     should_be_true    ${dl_throughput_ue1}>${ue1_dl_tput}
    run keyword and continue on failure     should_be_true    ${ul_throughput_ue1}>${ue1_ul_tput}


print UE dl and ul tp
    Wait '5s' for stable
    ${ul_throughput_pcell_ue}    airphone_get_throughput_on_specific_scell    1    0    type=pusch    tput_type=ave
    ${dl_throughput_pcell_ue}    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
    log to console    \n ue ul_throughput_pcell_ue ${ul_throughput_pcell_ue}
    log to console    \n ue dl_throughput_pcell_ue ${dl_throughput_pcell_ue}


Check rrc log for precoder DFT_S
    [Arguments]    ${egate tag}    ${ini}
    Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate_${egate tag}    unzip=TRUE
    run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/${ini}.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_${egate tag}

Attach '${UE_NUM}' SA UE
    Start capture gnb and ap syslog in 'SA_${UE_NUM}_ue_rrc' file
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       airphone_cleanup_egate_console_log
       Log To Console   ${\n}-----register UE ${num} ------
#       Start collect UE'${num}' tcpdump
       ${gw_pdu_r}    evaluate    ${num}%10+1
       Airphone SA Attach    ue_id=${num}
       Airphone Set Traffic Type    ue_id=${num}    pdu_id=${gw_pdu_r}    type=internal
       Airphone Pdu Session Setup   ue_id=${num}    pdu_id=${gw_pdu_r}   nwslice_id=1    gw_id=${gw_pdu_r}
       SA send mutiple trf ul data    ${num}    1   100K    ${gw_pdu_r}    tcp
#       Wait '8s' for stable    #receive rank2 reconfig message
#       Stop collect UE'${num}' tcpdump
#       Check UE'${num}' DFTS disable in attach_tcpdump
#       run keyword and continue on failure    Check rrc log for precoder DFT_S
#       ...    UE${num}    rrc_9198_case08_attach_precoder_disable
    END
    Stop capture gnb and ap syslog in 'SA_${UE_NUM}_ue_rrc' file

Add pathloss110 to UE to decrease SINR to trigger precoder enable
    log to console    \n Add pathloss ---110--- and check tti
    airphone_cleanup_egate_console_log
    Start collect ttitrace    tti_name=SA_UE_path110
    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=2 pathloss\=120
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_sinr action\=activate profile_id\=2 scell\=0
    END
    log to console    decode tti start
    Wait for '1s' to stop ttitrace with name'SA_UE_path110'
    Wait '5s' for stable
#    Start collect bip log
#    Wait for '1s' to stop bip log with name'BIP_110'
#    Get 9198 counter
    run keyword and continue on failure    Check rrc log for precoder DFT_S    pathloss110    rrc_9198_case08_addpath110_precoder_enable

Start collect ttitrace
    [Arguments]    ${tti_name}
    log to console    start collect ttitrace
    Start GNB Ttitrace With Streaming Mode    name=${tti_name}

Add pathloss10 to UE to increase SINR to trigger precoder disable
    log to console    \n Add pathloss ---30--- and check tti
    airphone_cleanup_egate_console_log
    Start collect ttitrace    tti_name=SA_UE_path10
    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=2 pathloss\=10
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_sinr action\=activate profile_id\=2 scell\=0
    END
    Wait for '2s' to stop ttitrace with name'SA_UE_path10'
    Wait '3s' for stable
    run keyword and continue on failure    Check rrc log for precoder DFT_S    pathloss30    rrc_9198_case08_addpath30_precoder_disable
    print UE dl and ul tp
    #${ul_throughput_pcell_ue}    airphone_get_throughput_on_specific_scell    1    0    type=pusch    tput_type=ave

Get 9198 counter
    log to console    ${\n}---wait for 80s for counter---
    Wait '80s' for stable
    log to console    ${\n}---capture counter start---
    ${PUSCH_DFT_INI_64TBL_MCS_0_to_27}   create list
    ${PUSCH_DFT_UNSUCC_64TBL_MCS_0_to_27}   create list
    ${PUSCH_DFT_SUCC_INI_64TBL_MCS_0_to_27}   create list
    ${PUSCH_DFT_SUCC_ANY_64TBL_MCS_0_to_27}   create list
    ${PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27}   create list
    ${PUSCH_DFT_INRE_VOL_64TBL_MCS_0_to_27}   create list
    ${PUSCH_DFT_RANK1_PMI_0_to_5}   create list
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    log to console    counter remianing time is ${remaining_time}
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
    FOR    ${num}    IN RANGE    0    28
        ${counter_1}   evaluate   6000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55302C0${counter_1}    cell_id=1
        set suite variable     ${PUSCH_DFT_INI_64TBL_MCS${num}}     ${result}
        append to list    ${PUSCH_DFT_INI_64TBL_MCS_0_to_27}    ${PUSCH_DFT_INI_64TBL_MCS${num}}
#        log to console    PUSCH_DFT_INI_64TBL_MCS_0_to_27 are ${PUSCH_DFT_INI_64TBL_MCS_0_to_27}

        ${counter_2}   evaluate   7000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55302C0${counter_2}    cell_id=1
        set suite variable     ${PUSCH_DFT_UNSUCC_64TBL_MCS${num}}     ${result}
        append to list    ${PUSCH_DFT_UNSUCC_64TBL_MCS_0_to_27}    ${PUSCH_DFT_UNSUCC_64TBL_MCS${num}}
#        log to console    PUSCH_DFT_UNSUCC_64TBL_MCS_0_to_27 are ${PUSCH_DFT_UNSUCC_64TBL_MCS_0_to_27}

        ${counter_3}   evaluate   8000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55302C0${counter_3}    cell_id=1
        set suite variable     ${PUSCH_DFT_SUCC_INI_64TBL_MCS${num}}     ${result}
        append to list    ${PUSCH_DFT_SUCC_INI_64TBL_MCS_0_to_27}    ${PUSCH_DFT_SUCC_INI_64TBL_MCS${num}}
#        log to console    PUSCH_DFT_SUCC_INI_64TBL_MCS_0_to_27 are ${PUSCH_DFT_SUCC_INI_64TBL_MCS_0_to_27}

        ${counter_4}   evaluate   9000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55302C0${counter_4}    cell_id=1
        set suite variable     ${PUSCH_DFT_SUCC_ANY_64TBL_MCS${num}}     ${result}
        append to list    ${PUSCH_DFT_SUCC_ANY_64TBL_MCS_0_to_27}    ${PUSCH_DFT_SUCC_ANY_64TBL_MCS${num}}
#        log to console    PUSCH_DFT_SUCC_ANY_64TBL_MCS_0_to_27 are ${PUSCH_DFT_SUCC_ANY_64TBL_MCS_0_to_27}

        ${counter_5}   evaluate   7000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55304C0${counter_5}    cell_id=1
        set suite variable     ${PUSCH_DFT_INI_VOL_64TBL_MCS${num}}     ${result}
        append to list    ${PUSCH_DFT_INRE_VOL_64TBL_MCS_0_to_27}    ${PUSCH_DFT_INI_VOL_64TBL_MCS${num}}
#        log to console    PUSCH_DFT_INRE_VOL_64TBL_MCS_0_to_27 are ${PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27}

        ${counter_6}   evaluate   8000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55304C0${counter_6}    cell_id=1
        set suite variable     ${PUSCH_DFT_INRE_VOL_64TBL_MCS${num}}     ${result}
        append to list    ${PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27}    ${PUSCH_DFT_INI_VOL_64TBL_MCS${num}}
#        log to console    PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27 are ${PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27}
    END

    FOR    ${num}    IN RANGE    0    6
        ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55303C2100${num}    cell_id=1
        set suite variable     ${PUSCH_DFT_RANK1_PMI${num}}     ${result}
        append to list    ${PUSCH_DFT_RANK1_PMI_0_to_5}    ${PUSCH_DFT_RANK1_PMI${num}}
#        log to console    PUSCH_DFT_RANK1_PMI_0_to_5 are ${PUSCH_DFT_RANK1_PMI_0_to_5}
    END

    log to console    PUSCH_DFT_INI_64TBL_MCS_0_to_27 are ${PUSCH_DFT_INI_64TBL_MCS_0_to_27}
    log to console    PUSCH_DFT_SUCC_INI_64TBL_MCS_0_to_27 are ${PUSCH_DFT_SUCC_INI_64TBL_MCS_0_to_27}
    log to console    PUSCH_DFT_SUCC_ANY_64TBL_MCS_0_to_27 are ${PUSCH_DFT_SUCC_ANY_64TBL_MCS_0_to_27}
    log to console    PUSCH_DFT_UNSUCC_64TBL_MCS_0_to_27 are ${PUSCH_DFT_UNSUCC_64TBL_MCS_0_to_27}
    log to console    PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27 are ${PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27}
    log to console    PUSCH_DFT_INRE_VOL_64TBL_MCS_0_to_27 are ${PUSCH_DFT_INI_VOL_64TBL_MCS_0_to_27}
    log to console    PUSCH_DFT_RANK1_PMI_0_to_5 are ${PUSCH_DFT_RANK1_PMI_0_to_5}

    ${MAC_DTCH_CELL_THP_DL_MAX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C12001    cell_id=1
    ${MAC_DTCH_CELL_THP_UL_MAX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C12002    cell_id=1
    ${Cell1_DL_TP_total}    evaluate    ${MAC_DTCH_CELL_THP_DL_MAX}*8/1024/1024
    log to console    Cell1_TP_total is ${Cell1_DL_TP_total}



Add pathloss to UE step by step
    log to console    \n Add pathloss to UE step by step
    log to console    \n Add pathloss ---120--- and check tti
    Start collect ttitrace    tti_name=SA_UE_path120
    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=120
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
    Wait for '2s' to stop ttitrace with name'SA_UE_path120'
    print UE dl and ul tp
#    Wait '5s' for stable
#    Start collect bip log
#    Wait for '1s' to stop bip log with name'BIP_120'
#    Get 9198 counter
#    ${ul_throughput_pcell_ue}    airphone_get_throughput_on_specific_scell    1    0    type=pusch    tput_type=ave

    log to console    \n Add pathloss ---115--- and check tti
    Start collect ttitrace    tti_name=SA_UE_path115
    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=115
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
    Wait for '2s' to stop ttitrace with name'SA_UE_path115'
    print UE dl and ul tp
    Wait '5s' for stable
    Start collect bip log
    Wait for '1s' to stop bip log with name'BIP_115'
#    Get 9198 counter
#
    log to console    \n Add pathloss ---105--- and check tti
    Start collect ttitrace    tti_name=SA_UE_path105
    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=105
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
    Wait for '2s' to stop ttitrace with name'SA_UE_path105'
    print UE dl and ul tp
#    Start collect bip log
#    Wait for '1s' to stop bip log with name'BIP_105'
    #${ul_throughput_pcell_ue}    airphone_get_throughput_on_specific_scell    1    0    type=pusch    tput_type=ave

    log to console    \n Add pathloss ---100--- and check tti
    Start collect ttitrace    tti_name=SA_UE_path100
    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=100
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
    Wait for '2s' to stop ttitrace with name'SA_UE_path100'
    print UE dl and ul tp
#    Start collect bip log
#    Wait for '1s' to stop bip log with name'BIP_100'
    #${ul_throughput_pcell_ue}    airphone_get_throughput_on_specific_scell    1    0    type=pusch    tput_type=ave

    log to console    \n Add pathloss ---95--- and check tti
    Start collect ttitrace    name=SA_UE_path95
    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=95
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
    Wait for '2s' to stop ttitrace with name'SA_UE_path95'
    print UE dl and ul tp
#    Start collect bip log
#    Wait for '1s' to stop bip log with name'BIP_95'

    log to console    \n Add pathloss ---90--- and check tti
    Start collect ttitrace    tti_name=SA_UE_path90
    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=90
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
    Wait for '2s' to stop ttitrace with name'SA_UE_path90'
    print UE dl and ul tp
#    Get 9198 counter
#    Start collect bip log
#    Wait for '1s' to stop bip log with name'BIP_90'
