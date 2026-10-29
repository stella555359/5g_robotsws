*** Settings ***
Documentation     Author:
...
Test Timeout      120 minutes
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LOO_AP_LOOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G

Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          SCFC_13709_TMO_CVR5.xml
${AIRPHONE_NAME}      iphy_tmo_6.xml
${WTS_NAME}           basic_setup_13709_tmo6.cfg
@{LOG_NAME_LIST}      gnb_snapshot    egatelog

${CHECK_COUNTER_NUM}        6
${CHECK_COUNTER_TIMES}      3

${UE_ID1}          1
${PDU_ID1}         1
${GW_ID1}          1
${SLICE_ID}       1
${UE_NUM_tdd_low}               1
${UE_NUM_tdd_high}         10
${UE_NUM_fdd_low}        51
${UE_NUM_fdd_high}        60

${EGATE_TAG}      MUmimo
${TTI_TAG}      tti
${TTI_TAG_BLER}      tti_bler
&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
...    NUMBER_OF_FILES=30
#@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
@{Rdparameter}    0x420062:1  0x800057:0
${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=UL_MIMO
#${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=0 init_sub_quad_pos=1 test_type=UL_MIMO
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=0 init_sub_quad_pos=2 test_type=UL_MIMO
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=0 init_sub_quad_pos=3 test_type=UL_MIMO
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id=5 mode=fixed init_quad_pos=1 init_sub_quad_pos=0 test_type=UL_MIMO
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id=6 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=UL_MIMO
${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id=7 mode=fixed init_quad_pos=1 init_sub_quad_pos=2 test_type=UL_MIMO
${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id=8 mode=fixed init_quad_pos=1 init_sub_quad_pos=3 test_type=UL_MIMO
${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id=9 mode=fixed init_quad_pos=2 init_sub_quad_pos=0 test_type=UL_MIMO
${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id=10 mode=fixed init_quad_pos=2 init_sub_quad_pos=1 test_type=UL_MIMO
${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id=11 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 test_type=UL_MIMO
${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id=12 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 test_type=UL_MIMO
${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id=13 mode=fixed init_quad_pos=3 init_sub_quad_pos=0 test_type=UL_MIMO
${PROFILE14}   ul_mimo_srs_beam_pos_nr profile_id=14 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=UL_MIMO
${PROFILE15}   ul_mimo_srs_beam_pos_nr profile_id=15 mode=fixed init_quad_pos=3 init_sub_quad_pos=2 test_type=UL_MIMO
${PROFILE16}   ul_mimo_srs_beam_pos_nr profile_id=16 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 test_type=UL_MIMO

@{Common_Rdparameter}    0x9D0000:15

@{13709_A_Rdparameter}    0x5808A6:1 #rdEnableOverloadErrMsg    0x5800CA:4004004 #rdMaxNumUeTdDl    0x5800CB:4004004 #rdMaxNumUeTdUl

@{13709_CB56_Rdparameter}    0x5808F9:9005 #rdRrcTriggeredOlcDlPerCent    0x5808FA:9005 #rdRrcTriggeredOlcUlPerCent
...    0x5808FC:9005 #rdL2PoolSigOvlSuspPsProcOlcPerCent    0x5901CF:4096 #rdStateHistoryBufferRuntimeSize

@{13709_ABIL_Rdparameter}    0x58052E:1 #rdExtLoadCtrlOnAbil

@{13709_D_Rdparameter}    0x5902CA:1 #rdEnableCB013709DUpd001#CPRT    0x5902BA:1 #rdEnableCB013709#CPRT
...    0x6601F0:1 #rdEnableCB013709DUpd001#CPRT    0x6601EF:1 #rdEnableCB013709#CPNRT


@{13709_F_Rdparameter}    0x58014D:3003 #rdSlotDurationSwitchingOlcPerCent    0x58012D:2 #rdK2min
...    0x580179:3003 #rdPDSCHSkipSpecialSlotOlcPerCent

@{13709_CB1_CA_Rdparameter}    0x5808E4:1 #rdExtendedOlcReleaseFlagForCa    0x5808ed:4003 #rdCaSusipendRelFddPerCent
...    0x5808ee:4003 #rdCaSuspendRelTddPerCent    0x5808ef:5004 #rdCaForbidScellActOlcFddDlPerCent
...    0x5808f0:5004 #rdCaForbidScellActOlcTddDlPerCent    0x5808f1:5004 #rdCaForbidScellActOlcFddUlPerCent
...    0x5808f2:5004 #rdCaForbidScellActOlcTddUlPerCent    0x5808f3:4003 #rdCaScellStopDataOlcFddDlPerCent
...    0x5808f4:4003 #rdCaScellStopDataOlcTddDlPerCent    0x5808f5:4003 #rdCaScellStopDataOlcFddUlPerCent
...    0x5808f6:4003 #rdCaScellStopDataOlcTddUlPerCent    0x5808f7:4003 #rdCaPcellStopDataOlcFddUlPerCent
...    0x5808f8:4003 #rdCaPcellStopDataOlcTddUlPerCent    0x5808FD:4003 #rdCoreSoftRtNrtStopScellActOlcPerCent
...    0x5901CF:4096 #rdStateHistoryBufferRuntimeSize

@{13709_CB_MU_Rdparameter}   0x5805D6:1001 #rdMuMimoRedvUeLowOlcDlPerCent    0x5805D7:2002 #rdMuMimoRedvUeMedOlcDlPerCent
...    0x5805D8:3003 #rdMuMimoRedvUeHighOlcDlPerCent    0x5805D9:4004 #rdMuMimoDeactOlcDlPerCent
...    0x5805D2:1001 #rdMuMimoRedvUeLowOlcUlPerCent    0x5805D3:2002 #rdMuMimoRedvUeMedOlcUlPerCent
...    0x5805D4:3003 #rdMuMimoRedvUeHighOlcUlPerCent    0x5805D5:4004 #rdMuMimoDeactOlcUlPerCent

@{13709_B_NBRRBG_Rdparameter}   0x5808EA:8008 #rdNominalBitrateOlcDlPerCent     0x5808EB:8008 #rdNominalBitrateOlcUlPerCent
...    0x5808EC:9005 #rdIntfAvdRbgRandOlcDlPerCent


*** Test Cases ***
CB013709_26R2Drop1-TMO-CVR-5_Verification
    Step1:Commission configuration for onair
    Step2:Attach 10UE in cell1 and check -A MU counter
    Step3:Attach 10UE in cell5 and check counter
    Step4:Disable MU and NBR
    Step5:Attach 10UE in cell1 and check -A MU counter again

*** Keywords ***
Step1:Commission configuration for onair
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Add GNB swconfig    @{Common_Rdparameter}
    Add GNB swconfig    @{13709_A_Rdparameter}
    Add GNB swconfig    @{13709_CB1_CA_Rdparameter}
    Add GNB swconfig    @{13709_CB_MU_Rdparameter}
    Add GNB swconfig    @{13709_B_NBRRBG_Rdparameter}
    Get and Update BSR File    par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Prepare gnb onair    multi_cells=True

Step2:Attach 10UE in cell1 and check -A MU counter
    Start capture only gnb syslog in 'step2_multiple_ues' file

    FOR    ${num}    IN RANGE    1    11    #10 pos
        airphone_execute_egate_command    ${PROFILE${num}}
    END
#cell1
    Log To Console    UE attach to cell1
    FOR    ${i}    IN RANGE    1    11
        run keyword and continue on failure    Attach UE to cell    ${i}
        ${j}    evaluate    ${i}%16+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
	   run keyword and continue on failure    Send trf for UE    ${i}    DL    175M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    50M    1
        Wait '2s' for stabible
    END
    Check 13079_A PM counters TDD
    Airphone Detach'${UE_NUM_tdd_low}'SA UE'${UE_NUM_tdd_high}'
    Stop capture only gnb syslog in 'step2_multiple_ues' file

Step3:Attach 10UE in cell5 and check counter
    Start capture only gnb syslog in 'step3' file

    FOR    ${num}    IN RANGE    1    11    #10 pos
        airphone_execute_egate_command    ${PROFILE${num}}
    END
#cell1
    Log To Console    UE attach to cell5
    FOR    ${i}    IN RANGE    51    61
        run keyword and continue on failure    Attach UE to cell    ${i}
        ${j}    evaluate    ${i}%16+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
	   run keyword and continue on failure    Send trf for UE    ${i}    DL    100M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    50M    1
        Wait '2s' for stabible
    END
    Check 13079_A PM counters FDD
    Airphone Detach'${UE_NUM_fdd_low}'SA UE'${UE_NUM_fdd_high}'
    Stop capture only gnb syslog in 'step3' file


Step4:Disable MU and NBR
    Start capture only gnb syslog in 'step4' file
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1   actNbrForNonGbrBearers    false    online
    Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1   actDlMuMimoEnh    false    online
    Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1   actUlMuMimo    false    online
    Wait '2s' for stabible
    TAF_ADMIN.teardown admin    connection=online
    Stop capture only gnb syslog in 'step4' file

Step5:Attach 10UE in cell1 and check -A MU counter again
    Start capture only gnb syslog in 'step5' file

    FOR    ${num}    IN RANGE    1    11    #10 pos
        airphone_execute_egate_command    ${PROFILE${num}}
    END
#cell1
    Log To Console    UE attach to cell1
    FOR    ${i}    IN RANGE    1    11
        run keyword and continue on failure    Attach UE to cell    ${i}
        ${j}    evaluate    ${i}%16+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
	   run keyword and continue on failure    Send trf for UE    ${i}    DL    175M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    50M    1
        Wait '2s' for stabible
    END
    Check 13079_A PM counters TDD again
    Airphone Detach'${UE_NUM_tdd_low}'SA UE'${UE_NUM_tdd_high}'
    Stop capture only gnb syslog in 'step5' file

check TP and bler with ttitrace
    [Arguments]    ${throughput}    ${time_avg}    ${tti_file}
    ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
    ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
    @{keys}  Get Dictionary Keys   ${a}
    FOR      ${key}     IN     @{keys}
        ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
        log to console   result is ${result}
        log to console   TP is ${throughput}
        should be true  ${result}>${throughput}
    END

Check SA UE throughput
    Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput

Verify multi SA UEs throughput
    FOR    ${num}    IN RANGE    1    8+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        Run Keyword If    ${num}!=${7} and ${num}!=${8}    should_be_true    ${dl_throughput_pcell}>200000
    END

Add RD parameter
     Add GNB swconfig    0x9D0000:15
     #CP-RT log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x590072:1
     #CP-NRT log level (avaiable after 19B, default = 2, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x41001b:1
     #CP-RT log level (default 1 in 19B, 2 in 20A, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x590072:1
     #CP-NRT log level (default = 2, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x66001b:1
     #CP-NB log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890001:1
     #CP-SB log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890002:1
     #CP-UE log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890003:1
     #CP-CL log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890004:1
     #CP-IF log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890005:1
     #CP-SCTP log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
     Add GNB swconfig    0x890006:1

Airphone SA Stop Data Traffic And Detach UE
     FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        Airphone SA Detach    ue_id=${num}
     END

Attach '${UE_NUM_SA}' SA UE
     FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       airphone_cleanup_egate_console_log
       Airphone SA Attach    ue_id=${num}
       Wait '2s' for stabible
       Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
       Wait '2s' for stabible
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
       Wait '2s' for stabible
       Collect AP egate log    ${EGATE_TAG}_${num}
       Wait '3s' for stabible
     END

Send Non GBR data to SA UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        SA send mutiple trf dl data    ${num}    4   175M   ${num}
        SA send mutiple trf ul data    ${num}    1    20M   ${num}
    END

Send GBR data to SA UE
    [Arguments]  ${ue_id}=1  ${pdu}=1    ${qfi}=2
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=${pdu} qfi\=${qfi} trf_id\=5 mbps\=5 dir\=dl
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=${pdu} qfi\=${qfi} trf_id\=5 mbps\=5 dir\=ul
    Wait '3s' for stabible

Execute AP Command before attach
    airphone_cleanup_egate_console_log
#    Airphone Setup X2 Connection

Release VONR
    [Arguments]    ${UE_ID}
    Airphone Pdu Session Modify    ${UE_ID}    ${UE_ID}    qosflows_to_del=2
    Airphone Pdu Session Modify    ${UE_ID}    ${UE_ID}    qosflows_to_del=3
	Wait '5s' for stabible

Check ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case08.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

Check PM counters
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
	${M55308C34019_PRB_DL_MU_MIMO_12LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34019    cell_id=1
    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34009    cell_id=1
    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34011    cell_id=1
    ${M55308C34015_PRB_DL_MU_MIMO_6PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34025   cell_id=1
    log to console     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}
    log to console     ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}
    log to console     ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}
    log to console     ${M55308C34015_PRB_DL_MU_MIMO_6PAIR_UE}
    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}>0
    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_6PAIR_UE}>0

Check 13079_A PM counters TDD
    [Arguments]    ${cell_grp_id}=0
    Set Test Variable    ${M55208C00001_PRE}    14
    Set Test Variable    ${M55208C00002_PRE}    14
    Set Test Variable    ${M55208C00003_PRE}    14
    Set Test Variable    ${M55208C00004_PRE}    14
    Set Test Variable    ${M55208C00005_PRE}    14
    Set Test Variable    ${M55208C00006_PRE}    14
    Set Test Variable    ${M55208C00020_PRE}    1500
    Set Test Variable    ${M55208C00029_PRE}    1500
    Set Test Variable    ${M55208C00033_PRE}    375
    Set Test Variable    ${M55208C00034_PRE}    6000
    Set Test Variable    ${M55208C00018_PRE}    375
    Set Test Variable    ${M55208C00027_PRE}    375
    Set Test Variable    ${M55208C00021_PRE}    375
    Set Test Variable    ${M55208C00022_PRE}    375
    Set Test Variable    ${M55208C00025_PRE}    375
#    Set Test Variable    ${M55308C34028_PRE}    0 # total mumber of mu paired UE PDSCH
#    Set Test Variable    ${M55308C35010_PRE}    0 # total mumber of mu paired UE PUSCH
    Wait '60s' for stabible
    FOR    ${num}    IN RANGE    1    ${CHECK_COUNTER_TIMES}
        ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
        Wait Throughput Timer    ${remaining_time}
        ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
        ${M55208C00001_PRE}   Check two times results    ${M55208C00001_PRE}    M55208C00001    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00002_PRE}   Check two times results    ${M55208C00002_PRE}    M55208C00002    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00003_PRE}   Check two times results    ${M55208C00003_PRE}    M55208C00003    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00004_PRE}   Check two times results    ${M55208C00004_PRE}    M55208C00004    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00005_PRE}   Check two times results    ${M55208C00005_PRE}    M55208C00005    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00006_PRE}   Check two times results    ${M55208C00006_PRE}    M55208C00006    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00020_PRE}   Check two times results    ${M55208C00020_PRE}    M55208C00020    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00029_PRE}   Check two times results    ${M55208C00029_PRE}    M55208C00029    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00033_PRE}   Check two times results    ${M55208C00033_PRE}    M55208C00033    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00034_PRE}   Check two times results    ${M55208C00034_PRE}    M55208C00034    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00018_PRE}   Check two times results    ${M55208C00018_PRE}    M55208C00018    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00027_PRE}   Check two times results    ${M55208C00027_PRE}    M55208C00027    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00021_PRE}   Check two times results    ${M55208C00021_PRE}    M55208C00021    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00022_PRE}   Check two times results    ${M55208C00022_PRE}    M55208C00022    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00025_PRE}   Check two times results    ${M55208C00025_PRE}    M55208C00025    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
#        ${M55308C34028_PRE}   Check two times results    ${M55308C34028_PRE}    M55308C34028    ${PM_counter_file}
#        ${M55308C35010_PRE}   Check two times results    ${M55308C35010_PRE}    M55308C35010    ${PM_counter_file}
        Should Be True    ${M55208C00001_PRE}>4
        Should Be True    ${M55208C00002_PRE}>4
        Should Be True    ${M55208C00003_PRE}>4
        Should Be True    ${M55208C00004_PRE}>4
        Should Be True    ${M55208C00005_PRE}>4
        Should Be True    ${M55208C00006_PRE}>4
	    Should Be True    ${M55208C00020_PRE}==1500
        Should Be True    ${M55208C00029_PRE}==1500
        Should Be True    ${M55208C00033_PRE}==375
        Should Be True    ${M55208C00034_PRE}==6000
        Should Be True    ${M55208C00018_PRE}==375
        Should Be True    ${M55208C00027_PRE}==375
        Should Be True    ${M55208C00021_PRE}==375
        Should Be True    ${M55208C00022_PRE}==375
        Should Be True    ${M55208C00025_PRE}==375
    END

Check 13079_A PM counters TDD again
    [Arguments]    ${cell_grp_id}=0
    Set Test Variable    ${M55208C00001_PRE}    14
    Set Test Variable    ${M55208C00002_PRE}    14
    Set Test Variable    ${M55208C00003_PRE}    14
    Set Test Variable    ${M55208C00004_PRE}    14
    Set Test Variable    ${M55208C00005_PRE}    14
    Set Test Variable    ${M55208C00006_PRE}    14
    Set Test Variable    ${M55208C00020_PRE}    0
    Set Test Variable    ${M55208C00029_PRE}    0
    Set Test Variable    ${M55208C00033_PRE}    375
    Set Test Variable    ${M55208C00034_PRE}    6000
    Set Test Variable    ${M55208C00018_PRE}    0
    Set Test Variable    ${M55208C00027_PRE}    0
    Set Test Variable    ${M55208C00021_PRE}    375
    Set Test Variable    ${M55208C00022_PRE}    375
    Set Test Variable    ${M55208C00025_PRE}    375
#    Set Test Variable    ${M55308C34028_PRE}    0 # total mumber of mu paired UE PDSCH
#    Set Test Variable    ${M55308C35010_PRE}    0 # total mumber of mu paired UE PUSCH
    Wait '60s' for stabible
    FOR    ${num}    IN RANGE    1    ${CHECK_COUNTER_TIMES}
        ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
        Wait Throughput Timer    ${remaining_time}
        ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
        ${M55208C00001_PRE}   Check two times results    ${M55208C00001_PRE}    M55208C00001    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00002_PRE}   Check two times results    ${M55208C00002_PRE}    M55208C00002    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00003_PRE}   Check two times results    ${M55208C00003_PRE}    M55208C00003    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00004_PRE}   Check two times results    ${M55208C00004_PRE}    M55208C00004    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00005_PRE}   Check two times results    ${M55208C00005_PRE}    M55208C00005    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00006_PRE}   Check two times results    ${M55208C00006_PRE}    M55208C00006    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00020_PRE}   Check two times results    ${M55208C00020_PRE}    M55208C00020    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00029_PRE}   Check two times results    ${M55208C00029_PRE}    M55208C00029    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00033_PRE}   Check two times results    ${M55208C00033_PRE}    M55208C00033    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00034_PRE}   Check two times results    ${M55208C00034_PRE}    M55208C00034    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00018_PRE}   Check two times results    ${M55208C00018_PRE}    M55208C00018    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00027_PRE}   Check two times results    ${M55208C00027_PRE}    M55208C00027    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00021_PRE}   Check two times results    ${M55208C00021_PRE}    M55208C00021    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00022_PRE}   Check two times results    ${M55208C00022_PRE}    M55208C00022    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00025_PRE}   Check two times results    ${M55208C00025_PRE}    M55208C00025    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
#        ${M55308C34028_PRE}   Check two times results    ${M55308C34028_PRE}    M55308C34028    ${PM_counter_file}
#        ${M55308C35010_PRE}   Check two times results    ${M55308C35010_PRE}    M55308C35010    ${PM_counter_file}
        Should Be True    ${M55208C00001_PRE}>4
        Should Be True    ${M55208C00002_PRE}>4
        Should Be True    ${M55208C00003_PRE}>4
        Should Be True    ${M55208C00004_PRE}>4
        Should Be True    ${M55208C00005_PRE}>4
        Should Be True    ${M55208C00006_PRE}>4
	    Should Be True    ${M55208C00020_PRE}==0
        Should Be True    ${M55208C00029_PRE}==0
        Should Be True    ${M55208C00033_PRE}==375
        Should Be True    ${M55208C00034_PRE}==6000
        Should Be True    ${M55208C00018_PRE}==0
        Should Be True    ${M55208C00027_PRE}==0
        Should Be True    ${M55208C00021_PRE}==375
        Should Be True    ${M55208C00022_PRE}==375
        Should Be True    ${M55208C00025_PRE}==375
    END

Check 13079_A PM counters FDD
    [Arguments]    ${cell_grp_id}=6
    Set Test Variable    ${M55208C00001_PRE}    21
    Set Test Variable    ${M55208C00002_PRE}    21
    Set Test Variable    ${M55208C00003_PRE}    21
    Set Test Variable    ${M55208C00004_PRE}    13
    Set Test Variable    ${M55208C00005_PRE}    13
    Set Test Variable    ${M55208C00006_PRE}    13
    Set Test Variable    ${M55208C00020_PRE}    0
    Set Test Variable    ${M55208C00029_PRE}    0
    Set Test Variable    ${M55208C00033_PRE}    375
    Set Test Variable    ${M55208C00034_PRE}    6000
    Set Test Variable    ${M55208C00018_PRE}    375
    Set Test Variable    ${M55208C00027_PRE}    375
#    Set Test Variable    ${M55308C34028_PRE}    0 # total mumber of mu paired UE PDSCH
#    Set Test Variable    ${M55308C35010_PRE}    0 # total mumber of mu paired UE PUSCH
    Wait '60s' for stabible
    FOR    ${num}    IN RANGE    1    ${CHECK_COUNTER_TIMES}
        ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
        Wait Throughput Timer    ${remaining_time}
        ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
        ${M55208C00001_PRE}   Check two times results    ${M55208C00001_PRE}    M55208C00001    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00002_PRE}   Check two times results    ${M55208C00002_PRE}    M55208C00002    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00003_PRE}   Check two times results    ${M55208C00003_PRE}    M55208C00003    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00004_PRE}   Check two times results    ${M55208C00004_PRE}    M55208C00004    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00005_PRE}   Check two times results    ${M55208C00005_PRE}    M55208C00005    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00006_PRE}   Check two times results    ${M55208C00006_PRE}    M55208C00006    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00020_PRE}   Check two times results    ${M55208C00020_PRE}    M55208C00020    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00029_PRE}   Check two times results    ${M55208C00029_PRE}    M55208C00029    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00033_PRE}   Check two times results    ${M55208C00033_PRE}    M55208C00033    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00034_PRE}   Check two times results    ${M55208C00034_PRE}    M55208C00034    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00018_PRE}   Check two times results    ${M55208C00018_PRE}    M55208C00018    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00027_PRE}   Check two times results    ${M55208C00027_PRE}    M55208C00027    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
#        ${M55308C34028_PRE}   Check two times results    ${M55308C34028_PRE}    M55308C34028    ${PM_counter_file}
#        ${M55308C35010_PRE}   Check two times results    ${M55308C35010_PRE}    M55308C35010    ${PM_counter_file}
        Should Be True    ${M55208C00001_PRE}>4
        Should Be True    ${M55208C00002_PRE}>4
        Should Be True    ${M55208C00003_PRE}>4
        Should Be True    ${M55208C00004_PRE}>4
        Should Be True    ${M55208C00005_PRE}>4
        Should Be True    ${M55208C00006_PRE}>4
	    Should Be True    ${M55208C00020_PRE}==0
        Should Be True    ${M55208C00029_PRE}==0
        Should Be True    ${M55208C00033_PRE}==375
        Should Be True    ${M55208C00034_PRE}==6000
        Should Be True    ${M55208C00018_PRE}==375
        Should Be True    ${M55208C00027_PRE}==375
    END

Check two times results
     [Arguments]    ${pre_count_value}    ${counter_id}    ${counter_file}    ${cell_grp_id}
        ${counter_value_cur}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
        ...    counter_id=${counter_id}    cell_grp_id=${cell_grp_id}
        Log To Console    counter:${counter_id}=${counter_value_cur}
        ${delta_count}=     Evaluate    abs(${counter_value_cur}-${pre_count_value}) if ${pre_count_value} != 0 else 0
        should be true    ${delta_count}<=10
        [return]    ${counter_value_cur}

Send trf for UE
    [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=1    duration=10800s    trf_id=${num}
    END
Attach UE to cell
    [Arguments]    ${ue_id}
    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=10
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=10
    airphone_set_traffic_type    ${ue_id}    1    internal
	airphone_execute_egate_command    ue_pdu_session_setup ue\=${ue_id} pdu\=1 nwslice\=1
    Wait '1s' for stabible

Airphone Detach'${LOW_UE_ID}'SA UE'${HIGH_UE_ID}'
     FOR    ${num}    IN RANGE    ${LOW_UE_ID}    ${HIGH_UE_ID}+1
        Airphone SA Detach    ue_id=${num}
     END
