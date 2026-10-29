*** Settings ***
Documentation     Author:
...
Test Timeout      240 minutes
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LOO_AP_LOOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G

Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          SCFC_13709_TMO_CVR6.xml
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
...    0x580821:40040040#rdMaxAdaptiveSlotProcessingRatio_perCent    0x580822:30030030 #rdMinAdaptiveSlotProcessingRatio_perCent

@{13709_BB3_microdtx_Rdparameter}    0x450027:1 #rdEnableDeveloperAccounter    00x45000A:1     0x5808E8:5005 #rdMicroDtxOlcDlPerCent 0x5808E8

@{13709_ABIL_Rdparameter}    0x58052E:1 #rdExtLoadCtrlOnAbil

@{13709_D_Rdparameter}    0x5902CA:1 #rdEnableCB013709DUpd001#CPRT    0x5902BA:1 #rdEnableCB013709#CPRT
...    0x6601F0:1 #rdEnableCB013709DUpd001#CPRT    0x6601EF:1 #rdEnableCB013709#CPNRT

@{13709_F_Rdparameter}    0x58014D:3003 #rdSlotDurationSwitchingOlcPerCent    0x58012D:2 #rdK2min
...    0x580179:3003 #rdPDSCHSkipSpecialSlotOlcPerCent

@{13709_BB5_tcpboost_Rdparameter}    0x58057a:4    0x580580:0x800000    0x5808e9:10005    0x4B000F:1

@{B_B4_powersaving_RD_parameter}    0x5808E7:9005 #rdPowerSavingsOlcDlPerCent
...    0x58057a:0x3 #Enable feature flag syslogs
...    0x58057e:0x2000000 #L2.L2_PS.DL.POWER_SAVING.MMIMO_MUTING
...    0x58057d:0x1 #L2.L2_PS.DL.LOAD_MEAS

@{13709_CB_MU_Rdparameter}   0x5805D6:1001 #rdMuMimoRedvUeLowOlcDlPerCent    0x5805D7:2002 #rdMuMimoRedvUeMedOlcDlPerCent
...    0x5805D8:3003 #rdMuMimoRedvUeHighOlcDlPerCent    0x5805D9:4004 #rdMuMimoDeactOlcDlPerCent
...    0x5805D2:1001 #rdMuMimoRedvUeLowOlcUlPerCent    0x5805D3:2002 #rdMuMimoRedvUeMedOlcUlPerCent
...    0x5805D4:3003 #rdMuMimoRedvUeHighOlcUlPerCent    0x5805D5:4004 #rdMuMimoDeactOlcUlPerCent

@{13709_B_NBRRBG_Rdparameter}   0x5808EA:8008 #rdNominalBitrateOlcDlPerCent     0x5808EB:8008 #rdNominalBitrateOlcUlPerCent
...    0x5808EC:9005 #rdIntfAvdRbgRandOlcDlPerCent


*** Test Cases ***
CB013709_26R2Drop2-TMO-CVR-6_Verification
    Step1:Commission configuration for onair
    Step2:Attach 10UE in cell1 and check counter
    Step3:Attach 10UE in cell5 and check counter
    Step4:Disable powersaving dtx tcpboost
    Step5:Attach 10UE in cell1 and check -A MU counter again
    Step6:Attach 10UE in cell5 and check counter again

*** Keywords ***
Step1:Commission configuration for onair
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Add GNB swconfig    @{Common_Rdparameter}
    Add GNB swconfig    @{13709_A_Rdparameter}
    Add GNB swconfig    @{13709_BB3_microdtx_Rdparameter}
    Add GNB swconfig    @{13709_BB5_tcpboost_Rdparameter}
    Add GNB swconfig    @{B_B4_powersaving_RD_parameter}
    Get and Update BSR File    par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Prepare gnb onair    multi_cells=True

Step2:Attach 10UE in cell1 and check counter
    Start capture only gnb syslog in 'step2_multiple_ues' file
#cell1
    Log To Console    UE1-2 attach to cell1
    FOR    ${i}    IN RANGE    1    3
        run keyword and continue on failure    Attach UE to cell    ${i}
	   run keyword and continue on failure    Send trf for UE    ${i}    DL    175M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    100M    1
        Wait '2s' for stabible
    END
    Check PM counters
    run keyword and continue on failure    Check 13079_A PM counters TDD lowload
    Log To Console    UE3-10 attach to cell1
    FOR    ${i}    IN RANGE    3    11
        run keyword and continue on failure    Attach UE to cell    ${i}
	   run keyword and continue on failure    Send trf for UE    ${i}    DL    175M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    100M    1
        Wait '2s' for stabible
    END
    Check PM counters highload
    run keyword and continue on failure    Check 13079_A PM counters TDD highload
    Airphone Detach'${UE_NUM_tdd_low}'SA UE'${UE_NUM_tdd_high}'
    Stop capture only gnb syslog in 'step2_multiple_ues' file

Step3:Attach 10UE in cell5 and check counter
    Start capture only gnb syslog in 'step3' file
    #cell5
    Log To Console    UE51-52 attach to cell5
    FOR    ${i}    IN RANGE    51    53
        run keyword and continue on failure    Attach UE to cell    ${i}
	   run keyword and continue on failure    Send trf for UE    ${i}    DL    100M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    50M    1
        Wait '2s' for stabible
    END
    Check PM counters    cell_id=5
    run keyword and continue on failure    Check 13079_A PM counters FDD
    Log To Console    UE53-60attach to cell5
    FOR    ${i}    IN RANGE    53    61
        run keyword and continue on failure    Attach UE to cell    ${i}
	   run keyword and continue on failure    Send trf for UE    ${i}    DL    100M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    50M    1
        Wait '2s' for stabible
    END
    Check PM counters highload    cell_id=5
    run keyword and continue on failure    Check 13079_A PM counters FDD highload
    Airphone Detach'${UE_NUM_fdd_low}'SA UE'${UE_NUM_fdd_high}'
    Stop capture only gnb syslog in 'step3' file

Step4:Disable powersaving dtx tcpboost
    Start capture only gnb syslog in 'step4' file
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1   actDtxOptimizedScheduler    false    online
    Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1   actEnhDtxOptimizedScheduler    false    online
    Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1   actTcpBoostPug    disabled    online
    Perform online change value    MRBTS-1/NRBTS-1   actNrLBPowerSaving    false    online
    Perform online change value    MRBTS-1/NRBTS-1/NRCELL-5   actDtxOptimizedScheduler    false    online
    Perform online change value    MRBTS-1/NRBTS-1/NRCELL-5   actEnhDtxOptimizedScheduler    false    online
    Perform online change value    MRBTS-1/NRBTS-1/NRCELL-5   actTcpBoostPug    disabled    online
    Wait '2s' for stabible
    TAF_ADMIN.teardown admin    connection=online
    Stop capture only gnb syslog in 'step4' file

Step5:Attach 10UE in cell1 and check -A MU counter again
    Start capture only gnb syslog in 'step5_multiple_ues' file
#cell1
    Log To Console    UE1-10 attach to cell1
    FOR    ${i}    IN RANGE    1    11
        run keyword and continue on failure    Attach UE to cell    ${i}
	   run keyword and continue on failure    Send trf for UE    ${i}    DL    175M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    100M    1
        Wait '2s' for stabible
    END
    Check PM counters highload
    run keyword and continue on failure    Check 13079_A PM counters TDD highload again
    Airphone Detach'${UE_NUM_tdd_low}'SA UE'${UE_NUM_tdd_high}'
    Stop capture only gnb syslog in 'step5_multiple_ues' file

Step6:Attach 10UE in cell5 and check counter again
    Start capture only gnb syslog in 'step6' file
    #cell5
    Log To Console    UE51-61 attach to cell5
    FOR    ${i}    IN RANGE    51    61
        run keyword and continue on failure    Attach UE to cell    ${i}
	   run keyword and continue on failure    Send trf for UE    ${i}    DL    100M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    50M    1
        Wait '2s' for stabible
    END
    Check PM counters highload    cell_id=5
    run keyword and continue on failure    Check 13079_A PM counters FDD highload again
    Airphone Detach'${UE_NUM_fdd_low}'SA UE'${UE_NUM_fdd_high}'
    Stop capture only gnb syslog in 'step6' file

Check SA UE throughput
    Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput

Verify multi SA UEs throughput
    FOR    ${num}    IN RANGE    1    8+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        Run Keyword If    ${num}!=${7} and ${num}!=${8}    should_be_true    ${dl_throughput_pcell}>200000
    END

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
    [Arguments]    ${cell_id}=1
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
	${M55308C33000_MICRO_DTX_OPTIMIZED}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C33000    cell_id=${cell_id}
    ${M55308C33001_MICRO_DTX_NO_BUNDLING}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C33001    cell_id=${cell_id}
    ${M55308C00038_TCP_BOOST_TOTAL_DURATION}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00038    cell_id=${cell_id}
    ${M55308C00039_TCP_BOOST_NUM_OF_CYCLES}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00039   cell_id=${cell_id}
    log to console     ${M55308C33000_MICRO_DTX_OPTIMIZED}
    log to console     ${M55308C33001_MICRO_DTX_NO_BUNDLING}
    log to console     ${M55308C00038_TCP_BOOST_TOTAL_DURATION}
    log to console     ${M55308C00039_TCP_BOOST_NUM_OF_CYCLES}
    should_be_true    ${M55308C33000_MICRO_DTX_OPTIMIZED}>0
    should_be_true    ${M55308C33001_MICRO_DTX_NO_BUNDLING}>=0
    should_be_true    ${M55308C00038_TCP_BOOST_TOTAL_DURATION}>0
    should_be_true    ${M55308C00039_TCP_BOOST_NUM_OF_CYCLES}>0

Check PM counters highload
    [Arguments]    ${cell_id}=1
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
	${M55308C33000_MICRO_DTX_OPTIMIZED}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C33000    cell_id=${cell_id}
    ${M55308C33001_MICRO_DTX_NO_BUNDLING}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C33001    cell_id=${cell_id}
    ${M55308C00038_TCP_BOOST_TOTAL_DURATION}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00038    cell_id=${cell_id}
    ${M55308C00039_TCP_BOOST_NUM_OF_CYCLES}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00039   cell_id=${cell_id}
    log to console     ${M55308C33000_MICRO_DTX_OPTIMIZED}
    log to console     ${M55308C33001_MICRO_DTX_NO_BUNDLING}
    log to console     ${M55308C00038_TCP_BOOST_TOTAL_DURATION}
    log to console     ${M55308C00039_TCP_BOOST_NUM_OF_CYCLES}
    should_be_true    ${M55308C33000_MICRO_DTX_OPTIMIZED}==0
    should_be_true    ${M55308C33001_MICRO_DTX_NO_BUNDLING}==0
    should_be_true    ${M55308C00038_TCP_BOOST_TOTAL_DURATION}==0
    should_be_true    ${M55308C00039_TCP_BOOST_NUM_OF_CYCLES}==0

Check 13079_A PM counters TDD lowload
    [Arguments]    ${cell_grp_id}=0
    Set Test Variable    ${M55208C00001_PRE}    0
    Set Test Variable    ${M55208C00002_PRE}    0
    Set Test Variable    ${M55208C00003_PRE}    0
    Set Test Variable    ${M55208C00004_PRE}    0
    Set Test Variable    ${M55208C00005_PRE}    0
    Set Test Variable    ${M55208C00006_PRE}    0
    Set Test Variable    ${M55208C00016_PRE}    0
    Set Test Variable    ${M55208C00017_PRE}    0
    Set Test Variable    ${M55208C00026_PRE}    0
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
        ${M55208C00016_PRE}   Check two times results    ${M55208C00016_PRE}    M55208C00016    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00017_PRE}   Check two times results    ${M55208C00017_PRE}    M55208C00017    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00026_PRE}   Check two times results    ${M55208C00026_PRE}    M55208C00026    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        Should Be True    ${M55208C00001_PRE}==0
        Should Be True    ${M55208C00002_PRE}==0
        Should Be True    ${M55208C00003_PRE}==0
        Should Be True    ${M55208C00004_PRE}==0
        Should Be True    ${M55208C00005_PRE}==0
        Should Be True    ${M55208C00006_PRE}==0
	    Should Be True    ${M55208C00016_PRE}==0
        Should Be True    ${M55208C00017_PRE}==0
        Should Be True    ${M55208C00026_PRE}==0
    END

Check 13079_A PM counters TDD highload
    [Arguments]    ${cell_grp_id}=0
    Set Test Variable    ${M55208C00001_PRE}    13
    Set Test Variable    ${M55208C00002_PRE}    13
    Set Test Variable    ${M55208C00003_PRE}    13
    Set Test Variable    ${M55208C00004_PRE}    14
    Set Test Variable    ${M55208C00005_PRE}    14
    Set Test Variable    ${M55208C00006_PRE}    14
    Set Test Variable    ${M55208C00016_PRE}    375
    Set Test Variable    ${M55208C00017_PRE}    375
    Set Test Variable    ${M55208C00026_PRE}    375
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
        ${M55208C00016_PRE}   Check two times results    ${M55208C00016_PRE}    M55208C00016    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00017_PRE}   Check two times results    ${M55208C00017_PRE}    M55208C00017    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00026_PRE}   Check two times results    ${M55208C00026_PRE}    M55208C00026    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        Should Be True    ${M55208C00001_PRE}>8
        Should Be True    ${M55208C00002_PRE}>8
        Should Be True    ${M55208C00003_PRE}>8
        Should Be True    ${M55208C00004_PRE}>10
        Should Be True    ${M55208C00005_PRE}>10
        Should Be True    ${M55208C00006_PRE}>10
	    Should Be True    ${M55208C00016_PRE}>360 and ${M55208C00016_PRE}<390
        Should Be True    ${M55208C00017_PRE}>360 and ${M55208C00017_PRE}<390
        Should Be True    ${M55208C00026_PRE}==375
    END

Check 13079_A PM counters TDD highload again
    [Arguments]    ${cell_grp_id}=0
    Set Test Variable    ${M55208C00001_PRE}    13
    Set Test Variable    ${M55208C00002_PRE}    13
    Set Test Variable    ${M55208C00003_PRE}    13
    Set Test Variable    ${M55208C00004_PRE}    14
    Set Test Variable    ${M55208C00005_PRE}    14
    Set Test Variable    ${M55208C00006_PRE}    14
    Set Test Variable    ${M55208C00016_PRE}    0
    Set Test Variable    ${M55208C00017_PRE}    0
    Set Test Variable    ${M55208C00026_PRE}    0
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
        ${M55208C00016_PRE}   Check two times results    ${M55208C00016_PRE}    M55208C00016    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00017_PRE}   Check two times results    ${M55208C00017_PRE}    M55208C00017    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00026_PRE}   Check two times results    ${M55208C00026_PRE}    M55208C00026    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        Should Be True    ${M55208C00001_PRE}>8
        Should Be True    ${M55208C00002_PRE}>8
        Should Be True    ${M55208C00003_PRE}>8
        Should Be True    ${M55208C00004_PRE}>10
        Should Be True    ${M55208C00005_PRE}>10
        Should Be True    ${M55208C00006_PRE}>10
	    Should Be True    ${M55208C00016_PRE}==0
        Should Be True    ${M55208C00017_PRE}==0
        Should Be True    ${M55208C00026_PRE}==0
    END

Check 13079_A PM counters FDD
    [Arguments]    ${cell_grp_id}=6
    Set Test Variable    ${M55208C00001_PRE}    0
    Set Test Variable    ${M55208C00002_PRE}    0
    Set Test Variable    ${M55208C00003_PRE}    0
    Set Test Variable    ${M55208C00004_PRE}    0
    Set Test Variable    ${M55208C00005_PRE}    0
    Set Test Variable    ${M55208C00006_PRE}    0
    Set Test Variable    ${M55208C00016_PRE}    0
    Set Test Variable    ${M55208C00017_PRE}    0
    Set Test Variable    ${M55208C00026_PRE}    0
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
        ${M55208C00016_PRE}   Check two times results    ${M55208C00016_PRE}    M55208C00016    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00017_PRE}   Check two times results    ${M55208C00017_PRE}    M55208C00017    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00026_PRE}   Check two times results    ${M55208C00026_PRE}    M55208C00026    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        Should Be True    ${M55208C00001_PRE}==0
        Should Be True    ${M55208C00002_PRE}==0
        Should Be True    ${M55208C00003_PRE}==0
        Should Be True    ${M55208C00004_PRE}==0
        Should Be True    ${M55208C00005_PRE}==0
        Should Be True    ${M55208C00006_PRE}==0
	    Should Be True    ${M55208C00016_PRE}==0
        Should Be True    ${M55208C00017_PRE}==0
        Should Be True    ${M55208C00026_PRE}==0
    END

Check 13079_A PM counters FDD highload
    [Arguments]    ${cell_grp_id}=6
    Set Test Variable    ${M55208C00001_PRE}    13
    Set Test Variable    ${M55208C00002_PRE}    13
    Set Test Variable    ${M55208C00003_PRE}    13
    Set Test Variable    ${M55208C00004_PRE}    12
    Set Test Variable    ${M55208C00005_PRE}    12
    Set Test Variable    ${M55208C00006_PRE}    12
    Set Test Variable    ${M55208C00016_PRE}    375
    Set Test Variable    ${M55208C00017_PRE}    375
    Set Test Variable    ${M55208C00026_PRE}    375
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
        ${M55208C00016_PRE}   Check two times results    ${M55208C00016_PRE}    M55208C00016    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00017_PRE}   Check two times results    ${M55208C00017_PRE}    M55208C00017    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00026_PRE}   Check two times results    ${M55208C00026_PRE}    M55208C00026    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        Should Be True    ${M55208C00001_PRE}>8
        Should Be True    ${M55208C00002_PRE}>8
        Should Be True    ${M55208C00003_PRE}>8
        Should Be True    ${M55208C00004_PRE}>10
        Should Be True    ${M55208C00005_PRE}>10
        Should Be True    ${M55208C00006_PRE}>10
	    Should Be True    ${M55208C00016_PRE}>360 and ${M55208C00016_PRE}<390
        Should Be True    ${M55208C00017_PRE}>360 and ${M55208C00017_PRE}<390
        Should Be True    ${M55208C00026_PRE}==375
    END

Check 13079_A PM counters FDD highload again
    [Arguments]    ${cell_grp_id}=6
    Set Test Variable    ${M55208C00001_PRE}    13
    Set Test Variable    ${M55208C00002_PRE}    13
    Set Test Variable    ${M55208C00003_PRE}    13
    Set Test Variable    ${M55208C00004_PRE}    12
    Set Test Variable    ${M55208C00005_PRE}    12
    Set Test Variable    ${M55208C00006_PRE}    12
    Set Test Variable    ${M55208C00016_PRE}    0
    Set Test Variable    ${M55208C00017_PRE}    0
    Set Test Variable    ${M55208C00026_PRE}    0
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
        ${M55208C00016_PRE}   Check two times results    ${M55208C00016_PRE}    M55208C00016    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00017_PRE}   Check two times results    ${M55208C00017_PRE}    M55208C00017    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        ${M55208C00026_PRE}   Check two times results    ${M55208C00026_PRE}    M55208C00026    ${PM_counter_file}    cell_grp_id=${cell_grp_id}
        Should Be True    ${M55208C00001_PRE}>8
        Should Be True    ${M55208C00002_PRE}>8
        Should Be True    ${M55208C00003_PRE}>8
        Should Be True    ${M55208C00004_PRE}>10
        Should Be True    ${M55208C00005_PRE}>10
        Should Be True    ${M55208C00006_PRE}>10
	    Should Be True    ${M55208C00016_PRE}==0
        Should Be True    ${M55208C00017_PRE}==0
        Should Be True    ${M55208C00026_PRE}==0
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