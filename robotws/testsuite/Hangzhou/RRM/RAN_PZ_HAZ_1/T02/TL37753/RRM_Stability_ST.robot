*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resources_ST_Stability.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1   5G_CLASSICAL_Android_ASOE_2xAHPB_3xAVQA_RJIO

*** Variables ***
${owner_email}   anan.liu@nokia-sebll.com
# ${owner_email}   tacase_auto@nokia-sbell.com

${ue_1}    PQY0221B04018372
${ue_2}    8885dec7
${ue_3}    7LAY7HXWHQ4P5XFE
${ue_4}    9YS0220820007305
${ue_5}    M7FU9DCI9PJNSWDI
${ue_6}    FIRWWSMJYPMVFYZL
${ue_7}    FMR0224125042381
@{ue_list}  ${ue_1}  ${ue_2}  ${ue_3}  ${ue_4}

# @{ue_list}  ${ue_2}
${call_duration}   60
${trf_duration}   120
${round_num}    10

${server_ip}  10.68.254.194

# PA port and value
# @{source_pa_port_list}     1  3  7  10  12  16
@{source_pa_port_list_1ue}     1  10
@{source_pa_value_list_1_1ue}    0  20
@{source_pa_value_list_2_1ue}    20  0
&{source_1_1ue}  att_index=${0}  pa_port=${source_pa_port_list_1ue}  pa_value=${source_pa_value_list_1_1ue}  step=${2}  pa_type=32*8
&{source_2_1ue}  att_index=${0}  pa_port=${source_pa_port_list_1ue}  pa_value=${source_pa_value_list_2_1ue}  step=${2}  pa_type=32*8

@{source_pa_port_list_4ue}     1  10  3  12  7  16
@{source_pa_value_list_1_4ue}    0  20
@{source_pa_value_list_2_4ue}    20  0
&{source_1_4ue}  att_index=${0}  pa_port=${source_pa_port_list_4ue}  pa_value=${source_pa_value_list_1_4ue}  step=${2}  pa_type=32*8
&{source_2_4ue}  att_index=${0}  pa_port=${source_pa_port_list_4ue}  pa_value=${source_pa_value_list_2_4ue}  step=${2}  pa_type=32*8

# @{target_pa_port_list}     129  131  135  138  140  144
# @{target_pa_value_list_1}    0  10
# @{target_pa_value_list_2}    10  0
# &{target_1}    att_index=${0}  pa_port=${target_pa_port_list}  pa_value=${target_pa_value_list_1}  step=${2}  pa_type=32*8
# &{target_2}    att_index=${0}  pa_port=${target_pa_port_list}  pa_value=${target_pa_value_list_2}  step=${2}  pa_type=32*8

######################################################################################################################################
######################################################################################################################################
*** Test Cases ***
Load_Configuration
    Log to Console  Start to do full commission....
    ${out}    Parameter Operation    operation=full_commission   product_type=gnb
    ...                              scf_path=${CURDIR}/config/SCFC.xml
    Log To Console    gNB full commission result: ${out}

    Log to Console  Wait for gNB/Cell on-air...

    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=SITE_ONAIR+CELL_ONAIR    timeout=180s


Test
    # Initialize_PA
    # PA Operation    source=&{source_1}    target=none
    # PA Operation    source=&{source_2}    target=none

    SW_Upgrade  SBTS00_ENB_9999_250811_000007
    # SW_Rollback

Stability_1UE_Static
    # start_log_collection

    # Wait_for_Next_5min_Period

    Log to Console  \n-------------------------------------Test is started!-------------------------------
    ${test_start_time}  Get_Current_Time
    # KPI Operation    start_kpi_collection    product_type=gnb

    # Run_Traffic_Model_1UE_Static  ue=${ue_3}  round_num=${round_num}
    Run_Traffic_Model_1UE_Static  ue=${ue_1}  round_num=${1}

    ${test_end_time}  Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nTest duration: ${test_duration} seconds
    # ${zip_path1}    KPI Operation    finish_kpi_collection    product_type=gnb
    # KPI Operation    kpi_report_generate  pmfile_zip_path=${zip_path1}  owner=${owner_email}
    Log to Console  \n-------------------------------------Test is stopped!-------------------------------

    # Run Keyword And Ignore Error  stop_log_collection

Stability_1UE_Mobility_wo_HO
    start_log_collection

    Wait_for_Next_5min_Period
    Log to Console  \n-------------------------------------Test is started!-------------------------------
    ${test_start_time}  Get_Current_Time
    KPI Operation    start_kpi_collection    product_type=gnb

    Run_Traffic_Model_1UE_Mobility_wo_HO  ue=${ue_5}  round_num=${round_num}

    ${test_end_time}  Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nTest duration: ${test_duration} seconds
    ${zip_path1}    KPI Operation    finish_kpi_collection    product_type=gnb
    KPI Operation    kpi_report_generate    pmfile_zip_path=${zip_path1}    owner=${owner_email}
    Log to Console  \n-------------------------------------Test is stopped!-------------------------------

    Run Keyword And Ignore Error  stop_log_collection

Stability_Bechmark_1UE_Static
    start_log_collection

    Wait_for_Next_5min_Period
    Log to Console  \n-------------------------------------Test is started!-------------------------------
    ${test_start_time}  Get_Current_Time
    KPI Operation    start_kpi_collection    product_type=gnb

    Run_Traffic_Model_1UE_Static  ue=${ue_5}  round_num=${round_num}

    ${test_end_time}  Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nTest duration: ${test_duration} seconds

    ${zip_path1}    KPI Operation    finish_kpi_collection    product_type=gnb
    KPI Operation    kpi_report_generate    pmfile_zip_path=${zip_path1}    owner=${owner_email}
    Log to Console  \n-------------------------------------Test is stopped!-------------------------------

    Run Keyword And Ignore Error  stop_log_collection

    #-----------------------------2nd Round-------------------------------------------------------------
    start_log_collection

    Wait_for_Next_5min_Period
    Log to Console  \n-------------------------------------Test is started!-------------------------------
    ${test_start_time}  Get_Current_Time
    KPI Operation    start_kpi_collection    product_type=gnb

    Run_Traffic_Model_1UE_Static  ue=${ue_5}  round_num=${round_num}

    ${test_end_time}  Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nTest duration: ${test_duration} seconds

    ${zip_path2}    KPI Operation    finish_kpi_collection    product_type=gnb
    KPI Operation    kpi_report_generate    pmfile_zip_path=${zip_path2}    owner=${owner_email}
    Log to Console  \n-------------------------------------Test is stopped!-------------------------------

    Run Keyword And Ignore Error  stop_log_collection

    KPI Operation    benchmark_report_generate    pmfile_zip_path1=${zip_path1}    pmfile_zip_path2=${zip_path2}
    ...    owner=${owner_email}

Stability_Bechmark_1UE_Mobility_wo_HO
    start_log_collection

    Wait_for_Next_5min_Period
    Log to Console  \n-------------------------------------Test is started!-------------------------------
    ${test_start_time}  Get_Current_Time
    KPI Operation    start_kpi_collection    product_type=gnb

    Run_Traffic_Model_1UE_Mobility_wo_HO  ue=${ue_5}  round_num=${round_num}

    ${test_end_time}  Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nTest duration: ${test_duration} seconds
    ${zip_path1}    KPI Operation    finish_kpi_collection    product_type=gnb
    KPI Operation    kpi_report_generate    pmfile_zip_path=${zip_path1}    owner=${owner_email}
    Log to Console  \n-------------------------------------Test is stopped!-------------------------------

    Run Keyword And Ignore Error  stop_log_collection

    #-----------------------------2nd Round-------------------------------------------------------------
    start_log_collection

    Wait_for_Next_5min_Period
    Log to Console  \n-------------------------------------Test is started!-------------------------------
    ${test_start_time}  Get_Current_Time
    KPI Operation    start_kpi_collection    product_type=gnb

    Run_Traffic_Model_1UE_Mobility_wo_HO  ue=${ue_5}  round_num=${round_num}

    ${test_end_time}  Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nTest duration: ${test_duration} seconds
    ${zip_path2}    KPI Operation    finish_kpi_collection    product_type=gnb
    KPI Operation    kpi_report_generate    pmfile_zip_path=${zip_path2}    owner=${owner_email}
    Log to Console  \n-------------------------------------Test is stopped!-------------------------------

    Run Keyword And Ignore Error  stop_log_collection

    KPI Operation    benchmark_report_generate    pmfile_zip_path1=${zip_path1}    pmfile_zip_path2=${zip_path2}
    ...    owner=${owner_email}

Stability_4UE_Attach_Detach
    FOR  ${i}  IN RANGE  0  1
        Attach_Multiple_UE  @{ue_list}
        Sleep  10
        Detach_Multiple_UE  @{ue_list}
    END

Stability_4UE_Static
    start_log_collection

    Wait_for_Next_5min_Period
    Log to Console  \n-------------------------------------Test is started!-------------------------------
    ${test_start_time}  Get_Current_Time
    KPI Operation    start_kpi_collection    product_type=gnb

    Run_Traffic_Model_4UE_Static  @{ue_list}  round_num=${round_num}

    ${test_end_time}  Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nTest duration: ${test_duration} seconds
    ${zip_path1}    KPI Operation    finish_kpi_collection    product_type=gnb
    KPI Operation    kpi_report_generate    pmfile_zip_path=${zip_path1}    owner=anan.liu@nokia-sbell.com
    Log to Console  \n-------------------------------------Test is stopped!-------------------------------

    Run Keyword And Ignore Error  stop_log_collection

Stability_Bechmark_4UE_Static
    start_log_collection

    Wait_for_Next_5min_Period
    Log to Console  \n-------------------------------------Test is started!-------------------------------
    ${test_start_time}  Get_Current_Time
    KPI Operation    start_kpi_collection    product_type=gnb

    Run_Traffic_Model_4UE_Static  @{ue_list}  round_num=${round_num}

    ${test_end_time}  Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nTest duration: ${test_duration} seconds
    ${zip_path1}    KPI Operation    finish_kpi_collection    product_type=gnb
    KPI Operation    kpi_report_generate    pmfile_zip_path=${zip_path1}    owner=${owner_email}
    Log to Console  \n-------------------------------------Test is stopped!-------------------------------

    Run Keyword And Ignore Error  stop_log_collection
    #-----------------------------------2nd Round----------------------------------------------------------
    start_log_collection

    Wait_for_Next_5min_Period
    Log to Console  \n-------------------------------------Test is started!-------------------------------
    ${test_start_time}  Get_Current_Time
    KPI Operation    start_kpi_collection    product_type=gnb

    Run_Traffic_Model_4UE_Static  @{ue_list}  round_num=${round_num}

    ${test_end_time}  Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nTest duration: ${test_duration} seconds
    ${zip_path2}    KPI Operation    finish_kpi_collection    product_type=gnb
    KPI Operation    kpi_report_generate    pmfile_zip_path=${zip_path2}    owner=${owner_email}
    Log to Console  \n-------------------------------------Test is stopped!-------------------------------

    Run Keyword And Ignore Error  stop_log_collection

    KPI Operation    benchmark_report_generate    pmfile_zip_path1=${zip_path1}    pmfile_zip_path2=${zip_path2}
    ...  owner=${owner_email}

Stability_4UE_Mobility_wo_HO
    start_log_collection

    Wait_for_Next_5min_Period
    Log to Console  \n-------------------------------------Test is started!-------------------------------
    ${test_start_time}  Get_Current_Time
    KPI Operation    start_kpi_collection    product_type=gnb

    Run_Traffic_Model_4UE_Mobility_wo_HO  @{ue_list}  round_num=${round_num}

    ${test_end_time}  Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nTest duration: ${test_duration} seconds
    ${zip_path1}    KPI Operation    finish_kpi_collection    product_type=gnb
    KPI Operation    kpi_report_generate    pmfile_zip_path=${zip_path1}    owner=${owner_email}
    Log to Console  \n-------------------------------------Test is stopped!-------------------------------

    Run Keyword And Ignore Error  stop_log_collection

########################################################################################################################
########################################################################################################################
*** Keywords ***
Run_Traffic_Model_1UE_Static
    [Arguments]  ${ue}  ${round_num}
    # UE: IPERF + VONR Call + ICMP Ping + IPERF, duration is about ????
    Attach_1UE  ue=${ue}
    FOR  ${i}  IN RANGE  0  ${round_num}
        log to console  \n-------------------------Round ${i} --------------------------------
        ${start_time}  Get_Current_Time
        Start_IPerf_UDP_Data_Call_DL  ue=${ue}  dl_port=50001  dl_rate=200M  duration=30
        Start_IPerf_UDP_Data_Call_UL  ue=${ue}  ul_port=50002  ul_rate=10M  duration=30
        Start_VoNR_Call_6688  ue=${ue}
        sleep  60
        Stop_IPerf_UDP_Data_Call_DL  ue=${ue}  dl_port=50001  dl_rate=200M  duration=30
        Stop_IPerf_UDP_Data_Call_UL  ue=${ue}  ul_port=50002  ul_rate=10M  duration=30
        Start_ICMP_Ping  ue=${ue}  count=10  interval=3
        Stop_VONR_Call_6688    ue=${ue}
        Start_IPerf_UDP_Data_Call_DL  ue=${ue}  dl_port=50001  dl_rate=500M  duration=30
        Start_IPerf_UDP_Data_Call_UL  ue=${ue}  ul_port=50002  ul_rate=100M  duration=30
        sleep  30
        Stop_IPerf_UDP_Data_Call_DL  ue=${ue}  dl_port=50001  dl_rate=500M  duration=30
        Stop_IPerf_UDP_Data_Call_UL  ue=${ue}  ul_port=50002  ul_rate=100M  duration=30
        sleep  10
        ${end_time}  Get_Current_Time
        ${round_duration}  Evaluate  ${end_time} - ${start_time}
        Log to Console  \nRound ${i} duration: ${round_duration} seconds
    END
    Detach_1UE  ue=${ue}

Run_Traffic_Model_1UE_Mobility_wo_HO
    [Arguments]  ${ue}  ${round_num}
    # UE: IPERF + VONR Call + ICMP Ping + IPERF, duration is about ~180
    Attach_1UE  ue=${ue}
    FOR  ${i}  IN RANGE  0  ${round_num}
        log to console  \n-------------------------Round ${i} --------------------------------
        ${start_time}  Get_Current_Time
        Start_IPerf_UDP_Data_Call_DL  ue=${ue}  dl_port=50001  dl_rate=200M  duration=90
        Start_IPerf_UDP_Data_Call_UL  ue=${ue}  ul_port=50002  ul_rate=50M  duration=90
        Start_VoNR_Call_6688  ue=${ue}
        PA Operation    source=&{source_1_1ue}    target=none
        PA Operation    source=&{source_2_1ue}    target=none
        Stop_IPerf_UDP_Data_Call_DL  ue=${ue}  dl_port=50001  dl_rate=200M  duration=30
        Stop_IPerf_UDP_Data_Call_UL  ue=${ue}  ul_port=50002  ul_rate=50M  duration=30
        Stop_VONR_Call_6688    ue=${ue}
        Start_IPerf_UDP_Data_Call_DL  ue=${ue}  dl_port=50001  dl_rate=500M  duration=60
        Start_IPerf_UDP_Data_Call_UL  ue=${ue}  ul_port=50002  ul_rate=10M  duration=60
        PA Operation    source=&{source_1_1ue}    target=none
        PA Operation    source=&{source_2_1ue}    target=none
        Stop_IPerf_UDP_Data_Call_DL  ue=${ue}  dl_port=50001  dl_rate=500M  duration=60
        Stop_IPerf_UDP_Data_Call_UL  ue=${ue}  ul_port=50002  ul_rate=10M  duration=60
        sleep  10
        ${end_time}  Get_Current_Time
        ${round_duration}  Evaluate  ${end_time} - ${start_time}
        Log to Console  \nRound ${i} duration: ${round_duration} seconds
    END
    Detach_1UE  ue=${ue}

Run_Traffic_Model_4UE_Static
    [Arguments]  @{ue_list}  ${round_num}

    Attach_Multiple_UE  @{ue_list}
    FOR  ${i}  IN RANGE  0  ${round_num}
        log to console  \n-------------------------Round ${i} --------------------------------
        ${start_time}  Get_Current_Time

        Start_IPerf_UDP_Data_Call_DL  ue=${ue_1}  dl_port=50011  dl_rate=400M  duration=180
        Start_IPerf_UDP_Data_Call_UL  ue=${ue_1}  ul_port=50012  ul_rate=50M  duration=180
        Start_VoNR_Call_6688  ue=${ue_2}
        Start_IPerf_UDP_Data_Call_DL  ue=${ue_3}  dl_port=50031  dl_rate=50M  duration=150
        Start_IPerf_UDP_Data_Call_UL  ue=${ue_3}  ul_port=50032  ul_rate=5M  duration=150
        Start_IPerf_UDP_Data_Call_DL  ue=${ue_4}  dl_port=50041  dl_rate=10k  duration=60
        Start_IPerf_UDP_Data_Call_UL  ue=${ue_4}  ul_port=50042  ul_rate=1k  duration=60
        sleep  60
        Stop_IPerf_UDP_Data_Call_DL  ue=${ue_1}  dl_port=50011  dl_rate=400M  duration=180
        Stop_IPerf_UDP_Data_Call_UL  ue=${ue_1}  ul_port=50012  ul_rate=50M  duration=180
        Stop_VONR_Call_6688    ue=${ue_2}
        Stop_IPerf_UDP_Data_Call_DL  ue=${ue_3}  dl_port=50031  dl_rate=50M  duration=150
        Stop_IPerf_UDP_Data_Call_UL  ue=${ue_3}  ul_port=50032  ul_rate=5M  duration=150
        Stop_IPerf_UDP_Data_Call_DL  ue=${ue_4}  dl_port=50041  dl_rate=10k  duration=60
        Stop_IPerf_UDP_Data_Call_UL  ue=${ue_4}  ul_port=50042  ul_rate=1k  duration=60
        sleep  30

        ${end_time}  Get_Current_Time
        ${round_duration}  Evaluate  ${end_time} - ${start_time}
        Log to Console  \nRound ${i} duration: ${round_duration} seconds
    END
    Detach_Multiple_UE  @{ue_list}

Run_Traffic_Model_4UE_Mobility_wo_HO
    [Arguments]  @{ue_list}  ${round_num}

    Attach_Multiple_UE  @{ue_list}
    FOR  ${i}  IN RANGE  0  ${round_num}
        log to console  \n-------------------------Round ${i} --------------------------------
        ${start_time}  Get_Current_Time

        Start_IPerf_UDP_Data_Call_DL  ue=${ue_1}  dl_port=50011  dl_rate=400M  duration=180
        Start_IPerf_UDP_Data_Call_UL  ue=${ue_1}  ul_port=50012  ul_rate=50M  duration=180
        Start_VoNR_Call_6688  ue=${ue_2}
        Start_IPerf_UDP_Data_Call_DL  ue=${ue_3}  dl_port=50031  dl_rate=50M  duration=150
        Start_IPerf_UDP_Data_Call_UL  ue=${ue_3}  ul_port=50032  ul_rate=5M  duration=150
        Start_IPerf_UDP_Data_Call_DL  ue=${ue_4}  dl_port=50041  dl_rate=10k  duration=120
        Start_IPerf_UDP_Data_Call_UL  ue=${ue_4}  ul_port=50042  ul_rate=1k  duration=120
        PA Operation    source=&{source_1_4ue}    target=none
        PA Operation    source=&{source_2_4ue}    target=none
        Stop_IPerf_UDP_Data_Call_DL  ue=${ue_1}  dl_port=50011  dl_rate=400M  duration=180
        Stop_IPerf_UDP_Data_Call_UL  ue=${ue_1}  ul_port=50012  ul_rate=50M  duration=180
        Stop_VONR_Call_6688    ue=${ue_2}
        Stop_IPerf_UDP_Data_Call_DL  ue=${ue_3}  dl_port=50031  dl_rate=50M  duration=150
        Stop_IPerf_UDP_Data_Call_UL  ue=${ue_3}  ul_port=50032  ul_rate=5M  duration=150
        Stop_IPerf_UDP_Data_Call_DL  ue=${ue_4}  dl_port=50041  dl_rate=10k  duration=120
        Stop_IPerf_UDP_Data_Call_UL  ue=${ue_4}  ul_port=50042  ul_rate=1k  duration=120
        sleep  30

        ${end_time}  Get_Current_Time
        ${round_duration}  Evaluate  ${end_time} - ${start_time}
        Log to Console  \nRound ${i} duration: ${round_duration} seconds
    END
    Detach_Multiple_UE  @{ue_list}

Initialize_PA
    ${pa_port_list}  ${pa_value_list}  Split And Expand PA Parameters
    ...    pa_port=1-256;    pa_value=93;
    &{source}    Create Dictionary    att_index=${0}    pa_port=${pa_port_list}    pa_value=${pa_value_list}
    ...                               step=${10}
    PA Operation    operation=Initialize PA Value    source=&{source}

    ${pa_port_list}  ${pa_value_list}  Split And Expand PA Parameters
    ...    pa_port=1;3;7;10;12;16    pa_value=0;0;0;0;0;0
    &{source}    Create Dictionary    att_index=${0}    pa_port=${pa_port_list}    pa_value=${pa_value_list}
    ...                               step=${0}
    PA Operation    operation=Initialize PA Value    source=&{source}