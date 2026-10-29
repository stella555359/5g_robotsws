*** Settings ***
Documentation     CB013709 MU disable case
...
Test Timeout      240 minutes
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LOO_AP_LOOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G

Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Resource    ./Resource/13709_keyword.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}          scfc_6cc_looo.xml
${AIRPHONE_NAME}      iphy_6cc_looo.xml
${WTS_NAME}           wts_6cc_looo.lua
#${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
@{LOG_NAME_LIST}      gnb_snapshot    egatelog

${UE_ID1}          1
${PDU_ID1}         1
${GW_ID1}          1
${SLICE_ID}       1
${UE_NUM_SA}         5
${UE_NUM_SA_VONR}         2
${UE_NUM_NSA}        2
${UE_NUM_NSA_ID}        12
${EGATE_TAG}      MUmimo
${TTI_TAG}      tti
${TTI_TAG_BLER}      tti_bler
&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
...    NUMBER_OF_FILES=30

@{Rdparameter}    0x420062:1  0x800057:0
${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60

${CHECK_COUNTER_NUM}        6
${CHECK_COUNTER_TIMES}      3


${pattern}     t2r4_n2_pusch_1layer
${pattern1}    CA_P2_8x4_t2r4_n2
${pattern2}    CA_P2_8x4_t1r4_n1
${pattern3}    CA_P2_8x4_t4r4_n4
${pattern4}    CA_P2_8x4_noTas_n2
${pattern5}    TDD_NSA_CA_NoRefinebeam

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


*** Test Cases ***
CB013709_CB_B3_case009_Interworking_with_DL_MUMIMO_during_high_load
   Step1:Commission configuration for onair
   Step2:Attach 200UE in cell and check -A counter
   Step3:Check MU disable


*** Keywords ***
Step1:Commission configuration for onair
    Log To Console   \n----------Step1:Commission the above configuration on WebUI-------
    Add Common RD parameter
    Add 13079_A RD parameter
    Add 13079_CB RD parameter
    Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H3H3_ALN60_ARP60_P00_COVERAGE_00444_00002
    Prepare gnb onair    multi_cells=True

Step2:Attach 200UE in cell and check -A counter
    Start capture only gnb syslog in 'step2_multiple_ues' file

    FOR    ${num}    IN RANGE    1    17    #16 pos
        airphone_execute_egate_command    ${PROFILE${num}}
    END

#cell1
    Log To Console    UE attach to cell1
    FOR    ${i}    IN RANGE    1    150
        run keyword and continue on failure    Attach UE to cell    ${i}
        ${j}    evaluate    ${i}%16+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
		run keyword and continue on failure    Send trf for UE    ${i}    DL    10M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    3M    1
        Wait '2s' for stabible
    END

    Check 13079_A PM counters

    [Teardown]    Stop capture only gnb syslog in 'step2_multiple_ues' file


Step4:Attach 200UE per cell
#    Start capture only gnb syslog in 'step4_multiple_ues' file

    FOR    ${num}    IN RANGE    1    17    #16 pos
        airphone_execute_egate_command    ${PROFILE${num}}
    END

#cell1
    Log To Console    UE attach to cell1
    FOR    ${i}    IN RANGE    1    150
        run keyword and continue on failure    Attach UE to cell    ${i}
        ${j}    evaluate    ${i}%16+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
		run keyword and continue on failure    Send trf for UE    ${i}    DL    6M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    3M    1
        Wait '2s' for stabible
    END

#cell2
    Log To Console    UE attach to cell2
    FOR    ${i}    IN RANGE    201    400
        run keyword and continue on failure    Attach UE to cell    ${i}
        ${j}    evaluate    ${i}%16+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
		run keyword and continue on failure    Send trf for UE    ${i}    DL    6M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    3M    1
        Wait '2s' for stabible
    END

#cell3
    Log To Console    UE attach to cell3
    FOR    ${i}    IN RANGE    401    600
        run keyword and continue on failure    Attach UE to cell    ${i}
        ${j}    evaluate    ${i}%16+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
		run keyword and continue on failure    Send trf for UE    ${i}    DL    6M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    3M    1
        Wait '2s' for stabible
    END

#cell4
    Log To Console    UE attach to cell4
    FOR    ${i}    IN RANGE    601    800
	    #airphone_execute_egate_command    ue_change_location id\=${i} cell\=4
        run keyword and continue on failure    Attach UE to cell    ${i}
        ${j}    evaluate    ${i}%34+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
        run keyword and continue on failure    Send trf for UE    ${i}    DL    7M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    3M    1
        Wait '2s' for stabible
   END

#cell5
    Log To Console    UE attach to cell5
    FOR    ${i}    IN RANGE    801    1000
        run keyword and continue on failure    Attach UE to cell    ${i}
        ${j}    evaluate    ${i}%34+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
        run keyword and continue on failure    Send trf for UE    ${i}    DL    6M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    3M    1
        Wait '2s' for stabible
    END

#cell6
    Log To Console    UE attach to cell6
    FOR    ${i}    IN RANGE    1001    1200
        run keyword and continue on failure    Attach UE to cell    ${i}
        ${j}    evaluate    ${i}%34+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${i} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${j}
        run keyword and continue on failure    Send trf for UE    ${i}    DL    5M    1
        run keyword and continue on failure    Send trf for UE    ${i}    UL    3M    1
        Wait '2s' for stabible
    END

    Wait '30s' for stabible
#    [Teardown]    Stop capture only gnb syslog in 'step4_multiple_ues' file

Step3:Trigger everity metrics for high load and check counter
    Log To Console   \n----------Step4:Trigger everity metrics for a high load-------
    Start capture gnb and ap syslog in 'step3_highload' file
    Check 13079_A PM counters
    [Teardown]  Stop capture gnb and ap syslog in 'step3_highload' file

Check 13079_A PM counters
    Set Test Variable    ${M55208C00001_PRE}    0
    Set Test Variable    ${M55208C00002_PRE}    0
    Set Test Variable    ${M55208C00003_PRE}    0
    Set Test Variable    ${M55208C00004_PRE}    0
    Set Test Variable    ${M55208C00005_PRE}    0
    Set Test Variable    ${M55208C00006_PRE}    0
    Set Test Variable    ${M55208C00033_PRE}    0
    Set Test Variable    ${M55208C00034_PRE}    0

    FOR    ${num}    IN RANGE    1    ${CHECK_COUNTER_TIMES}
        ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
        Wait Throughput Timer    ${remaining_time}
        ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
        ${M55208C00001_PRE}   Check two times results    ${M55208C00001_PRE}    M55208C00001    ${PM_counter_file}
        ${M55208C00002_PRE}   Check two times results    ${M55208C00002_PRE}    M55208C00002    ${PM_counter_file}
        ${M55208C00003_PRE}   Check two times results    ${M55208C00003_PRE}    M55208C00003    ${PM_counter_file}
        ${M55208C00004_PRE}   Check two times results    ${M55208C00004_PRE}    M55208C00004    ${PM_counter_file}
        ${M55208C00005_PRE}   Check two times results    ${M55208C00005_PRE}    M55208C00005    ${PM_counter_file}
        ${M55208C00006_PRE}   Check two times results    ${M55208C00006_PRE}    M55208C00006    ${PM_counter_file}
        ${M55208C00034_PRE}   Check two times results    ${M55208C00034_PRE}    M55208C00034    ${PM_counter_file}
        ${M55208C00033_PRE}   Check two times results    ${M55208C00033_PRE}    M55208C00033    ${PM_counter_file}

        Should Be True    ${M55208C00002_PRE}>4
        Should Be True    ${M55208C00003_PRE}>4
        Should Be True    ${M55208C00005_PRE}>4
        Should Be True    ${M55208C00006_PRE}>4
		Should Be True    ${M55208C00001_PRE}>4
        Should Be True    ${M55208C00004_PRE}>4
        Should Be True    ${M55208C00033_PRE}>100
        Should Be True    ${M55208C00034_PRE}>100
    END

Step3:Check MU disable
    Set Test Variable    ${M55308C34028_PRE}    0 # total mumber of mu paired UE PDSCH
    Set Test Variable    ${M55308C35010_PRE}    0 # total mumber of mu paired UE PUSCH

    FOR    ${num}    IN RANGE    1    ${CHECK_COUNTER_TIMES}
        ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
        Wait Throughput Timer    ${remaining_time}
        ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
        ${M55308C34028_PRE}   Check two times results    ${M55308C34028_PRE}    M55308C34028    ${PM_counter_file}
        ${M55308C35010_PRE}   Check two times results    ${M55308C35010_PRE}    M55308C35010    ${PM_counter_file}

        Should Be True    ${M55308C34028_PRE}=0
        Should Be True    ${M55308C35010_PRE}=0
    END


Check two times results
     [Arguments]    ${pre_count_value}    ${counter_id}    ${counter_file}
        ${counter_value_cur}=    get_counter_value_from_counter_file_by_grp    counter_file=${counter_file}
        ...    counter_id=${counter_id}    cell_grp_id=0
        Log To Console    counter:${counter_id}=${counter_value_cur}
        ${delta_count}=     Evaluate    abs(${counter_value_cur}-${pre_count_value}) if ${pre_count_value} != 0 else 0
        should be true    ${delta_count}<=2
        [return]    ${counter_value_cur}

Resend UL data
    FOR    ${i}    IN RANGE    36    46
        Stop UE DL Traffic    ${i}
        Wait '1s' for stable running
        Send trf for UE    ${i}    UL    20M   1
    END

Resend DL data
    FOR    ${i}    IN RANGE    1    11
        Stop UE DL Traffic    ${i}
        Wait '1s' for stabible
        Send trf for UE    ${i}    DL    30M   1
        ${i_2}    evaluate    ${i}+34
        Stop UE DL Traffic    ${i_2}
        Wait '2s' for stabible
        Send trf for UE    ${i_2}    DL    40M   1
    END

UEs moving
    [Arguments]    ${ue_id}
    FOR    ${i}    IN RANGE    2    36
        airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${i}
    END

#Attach UE to cell
#    [Arguments]    ${ue_id}    ${pattern}
#    ${ue_ability}    Obtain Ue Capability    ${pattern}
#    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=10    ue_capability=${ue_ability}
#    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=10    ue_capability=${ue_ability}
#    airphone_set_traffic_type    ${ue_id}    1    internal
#	airphone_execute_egate_command    ue_pdu_session_setup ue\=${ue_id} pdu\=1 nwslice\=1
#    Wait '1s' for stabible

Attach UE to cell
    [Arguments]    ${ue_id}
    ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=10
    Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=10
    airphone_set_traffic_type    ${ue_id}    1    internal
	airphone_execute_egate_command    ue_pdu_session_setup ue\=${ue_id} pdu\=1 nwslice\=1
    Wait '1s' for stabible

Send trf for UE
    [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=1    duration=10800s    trf_id=${num}
    END

Stop UE DL Traffic
    [Arguments]    ${ue_id}
    airphone_sa_stop_data_traffic    ${ue_id}    DL

Detach UE
    [Arguments]    ${ue_id}
    airphone_sa_detach    ue_id=${ue_id}    timeout=30

Detach All UEs
    FOR    ${i}    IN RANGE    1    11
        Airphone Sa Stop Data Traffic    ${i}    dl
        Detach UE    ${i}
    END

    FOR    ${i}    IN RANGE    51    61
        Airphone Sa Stop Data Traffic    ${i}    dl
        Detach UE    ${i}
    END


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
#    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/


Add 13079_CB RD parameter
    Add GNB swconfig    0x5805D6:1001 #rdMuMimoRedvUeLowOlcDlPerCent
    Add GNB swconfig    0x5805D7:2002 #rdMuMimoRedvUeMedOlcDlPerCent
    Add GNB swconfig    0x5805D8:3003 #rdMuMimoRedvUeHighOlcDlPerCent
    Add GNB swconfig    0x5805D9:4004 #rdMuMimoDeactOlcDlPerCent
    Add GNB swconfig    0x5805D2:1001 #rdMuMimoRedvUeLowOlcUlPerCent
    Add GNB swconfig    0x5805D3:2002 #rdMuMimoRedvUeMedOlcUlPerCent
    Add GNB swconfig    0x5805D4:3003 #rdMuMimoRedvUeHighOlcUlPerCent
    Add GNB swconfig    0x5805D5:4004 #rdMuMimoDeactOlcUlPerCent



Add 13079_A RD parameter
    #13709 overload control
    Add GNB swconfig    0x5808A6:1 #rdEnableOverloadErrMsg
    #13709-rt
    Add GNB swconfig    0x5800CA:3003003 #rdMaxNumUeTdDl
    Add GNB swconfig    0x5800CB:3003003 #rdMaxNumUeTdUl
    ##13709-nrt
    #Add GNB swconfig    0x580932:5 #rdNbProcedureContextsMaxLimit
    #Add GNB swconfig    0x580933:1 #rdNbProcedureContextsLow
    #0x580934 = 2 #rdNbProcedureContextsHigh
    #13709-core
    Add GNB swconfig    0x580821:30030030 #rdMaxAdaptiveSlotProcessingRatio_perCent
    Add GNB swconfig    0x580822:30030030 #rdMinAdaptiveSlotProcessingRatio_perCent


Add Common RD parameter
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

UE PDU Session Modify to Add
  [Arguments]  ${ue_id}=1   ${pdu}=1   ${set_qosflow_id}=2    ${fiveQi}=1    ${qfi}=2
  ${ret1}=  airphone_execute_egate_command  ue_pdu_session_modify ue\=${ue_id} pdu\=${pdu} qosflows_to_add\=${set_qosflow_id} by\=amf
  ...  pass_regexp=QoS Routing Table
  Log To Console    ${fiveQi}
  Log To Console    ${qfi}
#  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi ${qfi}
#  Should Contain  ${ret1}  discardTimer ms150

UE PDU Session Modify to Del
  [Arguments]  ${ue_id}=1  ${pdu}=1
  ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=2 by=amf
  ...  rrcReconfigurationComplete
  Should Contain  ${ret1}  Removed FiveQi:Qfi mapping fiveQi 1 qfi 2

UE PDU Session Setup with Multi Qosflow
  [Arguments]  ${additional_qosflows_to_activate}=2  ${fiveQi_1}=5  ${fiveQi_2}=1  ${ue_id}=1  ${gw}=1  ${pdu}=1
  airphone_execute_egate_command  smf_param id\=1 reset
  airphone_execute_egate_command  smf_param id\=1 additional_qosflows_to_activate\=${additional_qosflows_to_activate}
  ${ret1}=  airphone_execute_egate_command  ue_pdu_session_setup pdu\=${pdu} ue\=${ue_id} nwslice\=1 gw\=${gw}
  ...  pass_regexp=QoS Routing Table
  Log To Console    ${fiveQi_1}
  Log To Console    ${fiveQi_2}
#  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi_1} qfi 1
#  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi_2} qfi 2
  airphone_execute_egate_command  smf_param id\=1 reset

Send Non GBR data to SA UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        SA send mutiple trf dl data    ${num}    1   175M   ${num}
#        SA send mutiple trf ul data    ${num}    1    20M   ${num}
    END

Send GBR data to SA UE
    [Arguments]  ${ue_id}=1  ${pdu}=1    ${qfi}=2
    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=${pdu} qfi\=${qfi} trf_id\=5 mbps\=50 dir\=dl
#    airphone_execute_egate_command    trf_data_start ue\=${ue_id} pdu\=${pdu} qfi\=${qfi} trf_id\=5 mbps\=5 dir\=ul
    Wait '1s' for stabible

Add bearer for all UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        Add GBR bearer    ue_id=${num}    set_qfi_low=3    set_qfi_high=4    qfi_start=2
        Add nonGBR bearer    ue_id=${num}    set_qfi_low=8    set_qfi_high=10    qfi_start=4
    END


Add GBR bearer
    [Arguments]  ${ue_id}=1    ${set_qfi_low}=1    ${set_qfi_high}=1    ${qfi_start}=2
    FOR    ${set_qfi}    IN RANGE    ${set_qfi_low}    ${set_qfi_high}+1
         ${five_qi}    set variable    ${set_qfi}+1
         UE PDU Session Modify to Add    ue_id=${ue_id}  pdu=${ue_id}    set_qosflow_id=${set_qfi}    fiveQi=${five_qi}    qfi=${qfi_start}
         Wait '1s' for stabible
         Send GBR data to SA UE    ue_id=${ue_id}    pdu=${ue_id}    qfi=${qfi_start}
         ${qfi_start}    evaluate    ${qfi_start}+1
    END

Add nonGBR bearer
    [Arguments]  ${ue_id}=1    ${set_qfi_low}=8    ${set_qfi_high}=11    ${qfi_start}=2
    FOR    ${set_qfi}    IN RANGE    ${set_qfi_low}    ${set_qfi_high}+1
         ${five_qi}    set variable    ${set_qfi}-1
         UE PDU Session Modify to Add    ue_id=${ue_id}  pdu=${ue_id}    set_qosflow_id=${set_qfi}    fiveQi=${five_qi}    qfi=${qfi_start}
         Send GBR data to SA UE    ue_id=${ue_id}    pdu=${ue_id}    qfi=${qfi_start}
         ${qfi_start}    evaluate    ${qfi_start}+1
    END

Execute AP Command before attach
    airphone_cleanup_egate_console_log
#    Airphone Setup X2 Connection


Release VONR
    [Arguments]    ${UE_ID}
    Airphone Pdu Session Modify    ${UE_ID}    ${UE_ID}    qosflows_to_del=2
    Airphone Pdu Session Modify    ${UE_ID}    ${UE_ID}    qosflows_to_del=3
	Wait '5s' for stabible


UE '${ue_id}' fix RANK1
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=1 scell\=0

UE '${ue_id}' fix RANK2
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=2 scell\=0


UE '${ue_id}' fix RANK3
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=3 scell\=0



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
