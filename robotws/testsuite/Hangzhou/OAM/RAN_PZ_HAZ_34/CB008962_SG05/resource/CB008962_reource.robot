*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Variables    ./variable_CB008962.py
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/excel_chart.py
Documentation
...    Author:liu yue
...    contact:yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008962 in SBTS23R2 program

*** Keywords ***
CB008962 Case Precondition Setting
    ${modify_params}    create list
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    FOR    ${i}    IN RANGE    1    ${cell_num}+1
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i}
            ...    filter_param=Channel bandwidth    p_name=chBw    value=100MHz
        append to list    ${modify_params}    ${item}
    END
    FOR    ${i}    IN RANGE    1    ${cell_num}+1
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i}
            ...    filter_param=Maximum output power    p_name=pMax    value=34.9
        append to list    ${modify_params}    ${item}
    END
    FOR    ${i}    IN RANGE    1    ${cell_num}+1
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i}
            ...    filter_param=NR Cell type    p_name=nrCellType    value=8DL4UL
        append to list    ${modify_params}    ${item}
    END
    FOR    ${i}    IN RANGE    1    ${cell_num}+1
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i}
            ...    filter_param=Activate micro DTX optimized scheduler    p_name=actDtxOptimizedScheduler    value=true
        append to list    ${modify_params}    ${item}
    END
    FOR    ${i}    IN RANGE    1    ${cell_num}+1
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i}
            ...    filter_param=Downlink MIMO Mode    p_name=dlMimoMode    value=2x2 Closed Loop Spatial Multiplexing
        append to list    ${modify_params}    ${item}
    END
    ${item}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
        ...    filter_param=Activate micro discontinued transmission    p_name=actMicroDTX    value=true
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    filter_param=Power meter enabled    p_name=actPowerMeter    value=true
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
        ...    filter_param=SBTS Energy Consumption    p_name=mtBtsEnergyMonitoring    value=15min
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
        ...    filter_param=SBTS RFM energy monitoring    p_name=mtSBTSRfmEnergyMonitoring    value=15min
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
        ...    filter_param=SBTS SM Energy Monitoring    p_name=mtSBTSSmEnergyMonitoring    value=15min
    append to list    ${modify_params}    ${item}
    run keyword and ignore error    Modify Parameters On Webem    modify_params=${modify_params}
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    [Teardown]    selenium logout and close browser
CB008962 Get Counter Value
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    &{dict_counter_values}    Create dictionary
    ${content}    Get PM Counter content via Webem    counter_id=M40002C0
    ${time_list}    get dictionary keys   ${content}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    &{dict_counter_values}    Create dictionary
    ${M40002C0}    Get PM Counter value via Webem    counter_id=M40002C0    counter_time=${last_time}
    ${M40002C1}    Get PM Counter value via Webem    counter_id=M40002C1    counter_time=${last_time}
    ${M40002C2}    Get PM Counter value via Webem    counter_id=M40002C2    counter_time=${last_time}
    selenium logout and close browser
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    sleep    5s
    FOR    ${ru_index}    IN RANGE   1    4
        ${M40003C0}     Get PM Counter value via Webem    counter_id=M40003C0    counter_time=${last_time}
        ...    full_path=[${testline_name}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}/SBTS_RFM_Energy_Monitoring/MIN_INPUT_VOLTAGE_IN_RF
        set to dictionary    ${dict_counter_values}    M40003C0_${ru_index}    ${M40003C0}
        selenium logout and close browser
        sleep    2s
        Selenium Login And Disable Screen Lock
        sleep    1s
        run keyword and ignore error    selenium_coam.close_start_up_view_window
        sleep    1s
    END
    #run keyword and ignore error    selenium_coam.refresh_page
    selenium logout and close browser
    sleep    2s
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    sleep    5s
    FOR    ${ru_index}    IN RANGE   1    4
        ${M40003C1}     Get PM Counter value via Webem    counter_id=M40003C1    counter_time=${last_time}
        ...    full_path=[${testline_name}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}/SBTS_RFM_Energy_Monitoring/MAX_INPUT_VOLTAGE_IN_RF
        set to dictionary    ${dict_counter_values}    M40003C1_${ru_index}    ${M40003C1}
        selenium logout and close browser
        sleep    2s
        Selenium Login And Disable Screen Lock
        sleep    1s
        run keyword and ignore error    selenium_coam.close_start_up_view_window
        sleep    1s
    END
    #run keyword and ignore error    selenium_coam.refresh_page
    selenium logout and close browser
    sleep    2s
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    sleep    5s
    FOR    ${ru_index}    IN RANGE   1    4
        ${M40003C2}     Get PM Counter value via Webem    counter_id=M40003C2    counter_time=${last_time}
        ...    full_path=[${testline_name}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}/SBTS_RFM_Energy_Monitoring/RU_ENERGY_CONSUMPTION
        set to dictionary    ${dict_counter_values}    M40003C2_${ru_index}    ${M40003C2}
        selenium logout and close browser
        sleep    2s
        Selenium Login And Disable Screen Lock
        sleep    1s
        run keyword and ignore error    selenium_coam.close_start_up_view_window
        sleep    1s
    END
    #run keyword and ignore error    selenium_coam.refresh_page
    sleep    5s
    selenium logout and close browser
    sleep    2s
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    FOR    ${ru_index}    IN RANGE   1    4
        ${M40003C3}     Get PM Counter value via Webem    counter_id=M40003C3    counter_time=${last_time}
        ...    full_path=[${testline_name}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}/SBTS_RFM_Energy_Monitoring/RU_MIN_PWR_USAGE
        set to dictionary    ${dict_counter_values}    M40003C3_${ru_index}    ${M40003C3}
        selenium logout and close browser
        sleep    2s
        Selenium Login And Disable Screen Lock
        sleep    1s
        run keyword and ignore error    selenium_coam.close_start_up_view_window
        sleep    1s
    END
    #run keyword and ignore error    selenium_coam.refresh_page
    sleep    5s
    selenium logout and close browser
    sleep    2s
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    FOR    ${ru_index}    IN RANGE   1    4
        ${M40003C4}     Get PM Counter value via Webem    counter_id=M40003C4    counter_time=${last_time}
        ...    full_path=[${testline_name}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}/SBTS_RFM_Energy_Monitoring/RU_AVG_PWR_USAGE
        set to dictionary    ${dict_counter_values}    M40003C4_${ru_index}    ${M40003C4}
        selenium logout and close browser
        Selenium Login And Disable Screen Lock
        sleep    1s
        run keyword and ignore error    selenium_coam.close_start_up_view_window
        sleep    1s
    END
    #run keyword and ignore error    selenium_coam.refresh_page
    sleep    5s
    selenium logout and close browser
    sleep    2s
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    sleep    5s
    FOR    ${ru_index}    IN RANGE   1    4
        ${M40003C5}     Get PM Counter value via Webem    counter_id=M40003C5    counter_time=${last_time}
        ...    full_path=[${testline_name}] MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}/SBTS_RFM_Energy_Monitoring/RU_MAX_PWR_USAGE
        set to dictionary    ${dict_counter_values}    M40003C5_${ru_index}    ${M40003C5}
        selenium logout and close browser
        sleep    2s
        Selenium Login And Disable Screen Lock
        sleep    1s
        run keyword and ignore error    selenium_coam.close_start_up_view_window
        sleep    1s
    END
    run keyword and ignore error    selenium_coam.refresh_page
    sleep    5s
    #${M40003C1}    Get PM Counter value via Webem    counter_id=M40003C1    counter_time=${last_time}
    #${M40003C2}    Get PM Counter value via Webem    counter_id=M40003C2    counter_time=${last_time}
    #${M40003C3}    Get PM Counter value via Webem    counter_id=M40003C3    counter_time=${last_time}
    #${M40003C4}    Get PM Counter value via Webem    counter_id=M40003C4    counter_time=${last_time}
    #${M40003C5}    Get PM Counter value via Webem    counter_id=M40003C5    counter_time=${last_time}
    ${M40004C0}    Get PM Counter value via Webem    counter_id=M40004C0    counter_time=${last_time}
    ${M40004C1}    Get PM Counter value via Webem    counter_id=M40004C1    counter_time=${last_time}
    ${M40004C2}    Get PM Counter value via Webem    counter_id=M40004C2    counter_time=${last_time}
    ${M40004C3}    Get PM Counter value via Webem    counter_id=M40004C3    counter_time=${last_time}
    ${M40004C4}    Get PM Counter value via Webem    counter_id=M40004C4    counter_time=${last_time}
    ${M40004C5}    Get PM Counter value via Webem    counter_id=M40004C5    counter_time=${last_time}
    set to dictionary    ${dict_counter_values}    M40002C0    ${M40002C0}
    set to dictionary    ${dict_counter_values}    M40002C1    ${M40002C1}
    set to dictionary    ${dict_counter_values}    M40002C2    ${M40002C2}
    set to dictionary    ${dict_counter_values}    M40004C0    ${M40004C0}
    set to dictionary    ${dict_counter_values}    M40004C1    ${M40004C1}
    set to dictionary    ${dict_counter_values}    M40004C2    ${M40004C2}
    set to dictionary    ${dict_counter_values}    M40004C3    ${M40004C3}
    set to dictionary    ${dict_counter_values}    M40004C4    ${M40004C4}
    set to dictionary    ${dict_counter_values}    M40004C5    ${M40004C5}
    selenium logout and close browser
    [Return]     &{dict_counter_values}
    [Teardown]    selenium logout and close browser
Write lock PM counter value to excel
    log to console    write lock
    ${value_2_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40002C0
    ${value_3_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40002C1
    ${value_4_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40002C2
    ${value_6_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C0_1
    ${value_6_4}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C0_2
    ${value_6_5}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C0_3
    ${value_7_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C1_1
    ${value_7_4}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C1_2
    ${value_7_5}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C1_3
    ${value_8_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C2_1
    ${value_8_4}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C2_2
    ${value_8_5}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C2_3
    ${value_9_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C3_1
    ${value_9_4}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C3_2
    ${value_9_5}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C3_3
    ${value_10_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C4_1
    ${value_10_4}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C4_2
    ${value_10_5}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C4_3
    ${value_11_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C5_1
    ${value_11_4}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C5_2
    ${value_11_5}=   Get From Dictionary   ${dict_counter_values_lock}   M40003C5_3
    ${value_12_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40004C0
    ${value_13_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40004C1
    ${value_14_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40004C2
    ${value_15_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40004C3
    ${value_16_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40004C4
    ${value_17_3}=   Get From Dictionary   ${dict_counter_values_lock}   M40004C5
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=2    column=3    value=${value_2_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=3    column=3    value=${value_3_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=4    column=3    value=${value_4_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=3    value=${value_6_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=4    value=${value_6_4}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=5    value=${value_6_5}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=3    value=${value_7_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=4    value=${value_7_4}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=5    value=${value_7_5}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=3    value=${value_8_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=4    value=${value_8_4}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=5    value=${value_8_5}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=3    value=${value_9_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=4    value=${value_9_4}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=5    value=${value_9_5}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=3    value=${value_10_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=4    value=${value_10_4}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=5    value=${value_10_5}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=3    value=${value_11_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=4    value=${value_11_4}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=5    value=${value_11_5}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=12    column=3    value=${value_12_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=13    column=3    value=${value_13_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=14    column=3    value=${value_14_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=15    column=3    value=${value_15_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=16    column=3    value=${value_16_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=17    column=3    value=${value_17_3}
Write onair PM counter value to excel
    log to console    write on air
    ${value_2_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40002C0
    ${value_3_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40002C1
    ${value_4_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40002C2
    ${value_6_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C0_1
    ${value_6_7}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C0_2
    ${value_6_8}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C0_3
    ${value_7_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C1_1
    ${value_7_7}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C1_2
    ${value_7_8}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C1_3
    ${value_8_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C2_1
    ${value_8_7}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C2_2
    ${value_8_8}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C2_3
    ${value_9_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C3_1
    ${value_9_7}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C3_2
    ${value_9_8}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C3_3
    ${value_10_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C4_1
    ${value_10_7}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C4_2
    ${value_10_8}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C4_3
    ${value_11_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C5_1
    ${value_11_7}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C5_2
    ${value_11_8}=   Get From Dictionary   ${dict_counter_values_onAir}   M40003C5_3
    ${value_12_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40004C0
    ${value_13_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40004C1
    ${value_14_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40004C2
    ${value_15_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40004C3
    ${value_16_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40004C4
    ${value_17_6}=   Get From Dictionary   ${dict_counter_values_onAir}   M40004C5
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=2    column=6    value=${value_2_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=3    column=6    value=${value_3_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=4    column=6    value=${value_4_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=6    value=${value_6_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=7    value=${value_6_7}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=8    value=${value_6_8}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=6    value=${value_7_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=7    value=${value_7_7}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=8    value=${value_7_8}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=6    value=${value_8_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=7    value=${value_8_7}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=8    value=${value_8_8}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=6    value=${value_9_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=7    value=${value_9_7}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=8    value=${value_9_8}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=6    value=${value_10_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=7    value=${value_10_7}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=8    value=${value_10_8}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=6    value=${value_11_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=7    value=${value_11_7}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=8    value=${value_11_8}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=12    column=6    value=${value_12_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=13    column=6    value=${value_13_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=14    column=6    value=${value_14_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=15    column=6    value=${value_15_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=16    column=6    value=${value_16_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=17    column=6    value=${value_17_6}
Write medium load PM counter value to excel
    log to console    write medium load value
    ${value_2_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40002C0
    ${value_3_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40002C1
    ${value_4_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40002C2
    ${value_6_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C0_1
    ${value_6_10}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C0_2
    ${value_6_11}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C0_3
    ${value_7_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C1_1
    ${value_7_10}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C1_2
    ${value_7_11}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C1_3
    ${value_8_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C2_1
    ${value_8_10}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C2_2
    ${value_8_11}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C2_3
    ${value_9_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C3_1
    ${value_9_10}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C3_2
    ${value_9_11}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C3_3
    ${value_10_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C4_1
    ${value_10_10}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C4_2
    ${value_10_11}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C4_3
    ${value_11_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C5_1
    ${value_11_10}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C5_2
    ${value_11_11}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40003C5_3
    ${value_12_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40004C0
    ${value_13_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40004C1
    ${value_14_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40004C2
    ${value_15_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40004C3
    ${value_16_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40004C4
    ${value_17_9}=   Get From Dictionary   ${dict_counter_values_medium_load}   M40004C5
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=2    column=9    value=${value_2_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=3    column=9    value=${value_3_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=4    column=9    value=${value_4_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=9    value=${value_6_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=10    value=${value_6_10}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=11    value=${value_6_11}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=9    value=${value_7_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=10    value=${value_7_10}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=11    value=${value_7_11}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=9    value=${value_8_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=10    value=${value_8_10}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=11    value=${value_8_11}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=9    value=${value_9_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=10    value=${value_9_10}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=11    value=${value_9_11}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=9    value=${value_10_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=10    value=${value_10_10}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=11    value=${value_10_11}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=9    value=${value_11_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=10    value=${value_11_10}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=11    value=${value_11_11}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=12    column=9    value=${value_12_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=13    column=9    value=${value_13_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=14    column=9    value=${value_14_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=15    column=9    value=${value_15_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=16    column=9    value=${value_16_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=17    column=9    value=${value_17_9}
Write busy load PM counter value to excel
    log to console    write busy load
    ${value_2_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40002C0
    ${value_3_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40002C1
    ${value_4_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40002C2
    ${value_6_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C0_1
    ${value_6_13}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C0_2
    ${value_6_14}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C0_3
    ${value_7_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C1_1
    ${value_7_13}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C1_2
    ${value_7_14}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C1_3
    ${value_8_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C2_1
    ${value_8_13}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C2_2
    ${value_8_14}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C2_3
    ${value_9_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C3_1
    ${value_9_13}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C3_2
    ${value_9_14}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C3_3
    ${value_10_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C4_1
    ${value_10_13}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C4_2
    ${value_10_14}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C4_3
    ${value_11_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C5_1
    ${value_11_13}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C5_2
    ${value_11_14}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40003C5_3
    ${value_12_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40004C0
    ${value_13_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40004C1
    ${value_14_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40004C2
    ${value_15_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40004C3
    ${value_16_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40004C4
    ${value_17_12}=   Get From Dictionary   ${dict_counter_values_busy_load}   M40004C5
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=2    column=12    value=${value_2_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=3    column=12    value=${value_3_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=4    column=12    value=${value_4_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=12    value=${value_6_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=13    value=${value_6_13}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=14    value=${value_6_14}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=12    value=${value_7_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=13    value=${value_7_13}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=14    value=${value_7_14}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=12    value=${value_8_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=13    value=${value_8_13}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=14    value=${value_8_14}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=12    value=${value_9_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=13    value=${value_9_13}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=14    value=${value_9_14}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=12    value=${value_10_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=13    value=${value_10_13}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=14    value=${value_10_14}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=12    value=${value_11_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=13    value=${value_11_13}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=14    value=${value_11_14}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=12    column=12    value=${value_12_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=13    column=12    value=${value_13_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=14    column=12    value=${value_14_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=15    column=12    value=${value_15_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=16    column=12    value=${value_16_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=17    column=12    value=${value_17_12}
Write full load PM counter value to excel
    log to console    write full load
    ${value_2_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40002C0
    ${value_3_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40002C1
    ${value_4_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40002C2
    ${value_6_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C0_1
    ${value_6_16}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C0_2
    ${value_6_17}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C0_3
    ${value_7_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C1_1
    ${value_7_16}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C1_2
    ${value_7_17}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C1_3
    ${value_8_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C2_1
    ${value_8_16}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C2_2
    ${value_8_17}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C2_3
    ${value_9_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C3_1
    ${value_9_16}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C3_2
    ${value_9_17}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C3_3
    ${value_10_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C4_1
    ${value_10_16}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C4_2
    ${value_10_17}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C4_3
    ${value_11_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C5_1
    ${value_11_16}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C5_2
    ${value_11_17}=   Get From Dictionary   ${dict_counter_values_full_load}   M40003C5_3
    ${value_12_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40004C0
    ${value_13_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40004C1
    ${value_14_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40004C2
    ${value_15_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40004C3
    ${value_16_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40004C4
    ${value_17_15}=   Get From Dictionary   ${dict_counter_values_full_load}   M40004C5
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=2    column=15    value=${value_2_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=3    column=15    value=${value_3_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=4    column=15    value=${value_4_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=15    value=${value_6_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=16    value=${value_6_16}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=6    column=17    value=${value_6_17}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=15    value=${value_7_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=16    value=${value_7_16}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=7    column=17    value=${value_7_17}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=15    value=${value_8_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=16    value=${value_8_16}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=8    column=17    value=${value_8_17}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=15    value=${value_9_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=16    value=${value_9_16}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=9    column=17    value=${value_9_17}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=15    value=${value_10_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=16    value=${value_10_16}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=10    column=17    value=${value_10_17}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=15    value=${value_11_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=16    value=${value_11_16}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=11    column=17    value=${value_11_17}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=12    column=15    value=${value_12_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=13    column=15    value=${value_13_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=14    column=15    value=${value_14_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=15    column=15    value=${value_15_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=16    column=15    value=${value_16_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=17    column=15    value=${value_17_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx    sheet=Sheet1
    ...    row=18    column=1    value=${Active_SW_version}
Enable NR Test Dedicated State
    [Arguments]    ${ru_index}=1
    Verify all cells should be onair
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${boundary}    get the boundary of stream    stream=${stream}
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    log to console    \enable test dedicated state
    selenium_coam.enable_test_dedicated_state
    sleep    3min
    Wait Until Keyword Succeeds    5min    30s    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    Wait until keyword succeeds    8 min    20 sec    RU Should Be Online    ru_index=${ru_index}
    Wait Until Keyword Succeeds    5min    30s    Cell Status Info Should Be Disabled
    ...    bs_blocked=Unblocked    cell_type=nr    boundary=${boundary}
    [Teardown]    selenium logout and close browser
Disable NR Test Dedicated State
    log to console    \disable test dedicated state
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.disable_message_box
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_test_dedicated_state
    sleep    3s
    selenium logout and close browser
    sleep    180
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair
    [Teardown]   selenium logout and close browser
Start NR downlink test
    [Arguments]    ${power_backoff}=${0}    ${beam_id}=${983}    ${localcell_postfix}=${EMPTY}
    ...    ${level_of_load_burst}=${None}    ${type_of_load}=${None}    ${test_model}=NR-FR1-TM1.1
    log to console    Start NR downlink test
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.disable_message_box
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    ${nrarfcn_cell1}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...  filter_param=NR Absolute radio frequency channel number
    ${nrarfcn_cell2}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-2
    ...  filter_param=NR Absolute radio frequency channel number
    ${nrarfcn_cell3}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-3
    ...  filter_param=NR Absolute radio frequency channel number
    ${pci_cell1}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...  filter_param=Physical cell identifier
    ${pci_cell2}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-2
    ...  filter_param=Physical cell identifier
    ${pci_cell3}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-3
    ...  filter_param=Physical cell identifier
    log to console    start NRCELL-1 NR downlink test
    start 5g downlink test and check status
    ...    p_max=${34.9}    polarization=P_both    physical_cell_id=${pci_cell1}    nrarfcn=${nrarfcn_cell1}    test_id=${1}
    ...    power_backoff=${power_backoff}    beam_id=${beam_id}   local_cell=NRCELL-1${localcell_postfix}    test_model=${test_model}
    ...    level_of_load_burst=${level_of_load_burst}    type_of_load=${type_of_load}
    sleep    2s
    log to console    start NRCELL-2 NR downlink test
    start 5g downlink test and check status
    ...    p_max=${34.9}    polarization=P_both    physical_cell_id=${pci_cell2}    nrarfcn=${nrarfcn_cell2}    test_id=${2}
    ...    power_backoff=${power_backoff}    beam_id=${beam_id}   local_cell=NRCELL-2${localcell_postfix}    test_model=${test_model}
    ...    level_of_load_burst=${level_of_load_burst}    type_of_load=${type_of_load}
    sleep    2s
    log to console    start NRCELL-3 NR downlink test
    start 5g downlink test and check status
    ...    p_max=${34.9}    polarization=P_both    physical_cell_id=${pci_cell3}    nrarfcn=${nrarfcn_cell3}    test_id=${3}
    ...    power_backoff=${power_backoff}    beam_id=${beam_id}   local_cell=NRCELL-3${localcell_postfix}    test_model=${test_model}
    ...    level_of_load_burst=${level_of_load_burst}    type_of_load=${type_of_load}
    [Teardown]   selenium logout and close browser
CB008962 test suite setup
    SISO Coam Suite Setup
    check if BWF exist
    Get Ru Info
    run keyword and ignore error   upload and configure BWF
    Wait Until Keyword Succeeds    10min    30s    Verify all cells should be onair
    check if BWF exist
    ${cell_id_list}     Get All Cell Id
    ${cell_num}    get length     ${cell_id_list}
    Set Suite Variable    ${cell_num}
    Set Suite Variable    ${cell_id_list}
    CB008962 Case Precondition Setting
    clear_content    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx
    ...    sheet=Sheet1    min_row=${5}    max_row=${11}    min_col=${3}    max_col=${17}
    clear_merged_cells_content    filepath=/home/ute/TA/CB008962/CB008962_Result.xlsx
    ...    sheet=Sheet1    min_row=${2}    max_row=${17}    min_col=${3}    max_col=${17}
CB008962 test suite setup without configure BWF
    SISO Coam Suite Setup
    ${cell_id_list}     Get All Cell Id
    ${cell_num}    get length     ${cell_id_list}
    Set Suite Variable    ${cell_num}
    Set Suite Variable    ${cell_id_list}
    clear_content    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx
    ...    sheet=Sheet1    min_row=${5}    max_row=${11}    min_col=${3}    max_col=${17}
    clear_merged_cells_content    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx
    ...    sheet=Sheet1    min_row=${2}    max_row=${17}    min_col=${3}    max_col=${17}
CB008962 test suite setup without configure BWF test mode
    SISO Coam Suite Setup
    ${cell_id_list}     Get All Cell Id
    ${cell_num}    get length     ${cell_id_list}
    Set Suite Variable    ${cell_num}
    Set Suite Variable    ${cell_id_list}
    clear_content    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx
    ...    sheet=Sheet1    min_row=${5}    max_row=${11}    min_col=${3}    max_col=${17}
    clear_merged_cells_content    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx
    ...    sheet=Sheet1    min_row=${2}    max_row=${17}    min_col=${3}    max_col=${17}
    disable deepsleep Mode
Get PM Counter value via Webem
    [Arguments]    ${counter_id}    ${counter_time}   ${dist_name}=${None}    ${counter_type}=BTS
    ...    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem    counter_id=${counter_id}   dist_name=${dist_name}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${value}    get_from_dictionary    ${content}    ${counter_time}
    [Return]    ${value}
check if BWF exist
    &{bwf_status}    Create dictionary
    ${ru_index_list}    get all ru index
    Connect to Common Unit Master
    FOR    ${ru_index}    IN    @{ru_index_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
        ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
        ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
        ${output}    csn.execute    command=sudo ssh root@192.168.101.2 ls -l /run/coma/type/ | grep bfw    connection=RU_${ru_index}
        ${status}    run keyword and return status    Should not be empty    ${output}
        set to dictionary    ${bwf_status}    status_${ru_index}    ${status}
        csn.Disconnect   connection=RU_${ru_index}
        sleep    5s
    END
    csn.Disconnect   connection=ASIK Master
    Set Suite Variable    &{bwf_status}
    [Return]    &{bwf_status}
    [Teardown]    csn.Reset Cache
Get RU type Via File FRIps
    [Arguments]   ${ru_serial_number}    ${connection}=ASIK Master
    ${get_ru_ip_command}   Set Variable   cat /rom/config/FRIps.txt
    ${output}   csn.execute   command=${get_ru_ip_command}  connection=${connection}
    ${contained_ip_lines}   Get Lines Containing String   ${output}  ${ru_serial_number}   case-insensitive=${True}
    ${ru_type}  Set Variable    ${contained_ip_lines.split(';')}[4]
    [Return]   ${ru_type}
create runtime_config file
    ${ru_index_list}    get all ru index
    Connect to Common Unit Master
    FOR    ${ru_index}    IN    @{ru_index_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
        ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
        ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
        csn.execute    ${sudo} touch /mnt/runtime/runtime_config.txts    connection=RU_${ru_index}
        ${output}    csn.execute    ${sudo} ls -ll /mnt/runtime    connection=RU_${ru_index}
        Should Contain    ${output}    runtime_config.txt
        sleep    5s
        csn.Disconnect   connection=RU_${ru_index}
    END
    csn.Disconnect   connection=ASIK Master
    [Teardown]    csn.Reset Cache
Get Ru Info
    [Arguments]    ${ru_index}=${1}    ${asik_alias}=ASIK Master    ${connection}=GNB_OAM
    &{ru_ip_dic}    Create dictionary
    &{ru_type_dic}    Create dictionary
    Connect to Common Unit Master
    ${ru_index_list}    get all ru index
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${container_id}    Get FHNET Container ID    asik_alias=${asik_alias}
        &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
        ${ru_ip_addr}  Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}  connection=${connection}
        set to dictionary    ${ru_ip_dic}    ip_${ru_index}    ${ru_ip_addr}
        ${ru_type}    Get RU type Via File FRIps    ru_serial_number=${ru_info['serialNumber']}  connection=${asik_alias}
        set to dictionary    ${ru_type_dic}    ru_type_${ru_index}    ${ru_type}
    END
    Set Suite Variable    &{ru_ip_dic}
    Set Suite Variable    &{ru_type_dic}
    csn.Disconnect   connection=ASIK Master
    [Return]    &{ru_ip_dic}    &{ru_type_dic}
    [Teardown]    csn.Reset Cache
upload and configure BWF
    create runtime_config file
    ${ru_index_list}    get all ru index
    FOR    ${ru_index}    IN    @{ru_index_list}
        Run Keyword If    '${bwf_status}[status_${ru_index}]'=='True'
        ...    configure BWF on RU    ru_index=${ru_index}
    END

    sleep    120s

upload file to made
    [Arguments]    ${file_name}    ${asik_alias}=ASIK Master    ${ru_index}=1
    Connect to Common Unit Master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    Wait Until Keyword Succeeds   2 min  5 sec   csn.upload file
    ...                                          remote_path=/var/tmp
    ...                                          local_path=/home/ute/TA/CB008962/${file_name}
    ...                                          connection=RU_${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    csn.execute    command=${sudo} scp /var/tmp/${file_name} 192.168.101.2:/tmp    connection=RU_${ru_index}    timeout=300
    sleep    5s
    csn.execute    command=${sudo} scp /var/tmp/${file_name} 192.168.101.3:/tmp    connection=RU_${ru_index}    timeout=300
    sleep    5s
    csn.execute    command=${sudo} scp /var/tmp/${file_name} 192.168.101.4:/tmp    connection=RU_${ru_index}    timeout=300
    sleep    5s
    csn.execute    command=${sudo} scp /var/tmp/${file_name} 192.168.101.5:/tmp    connection=RU_${ru_index}    timeout=300
    sleep    5s
    csn.execute    command=${sudo} scp /var/tmp/${file_name} 192.168.101.6:/tmp    connection=RU_${ru_index}    timeout=300
    sleep    5s
    csn.execute    command=${sudo} scp /var/tmp/${file_name} 192.168.101.7:/tmp    connection=RU_${ru_index}    timeout=300
    sleep    5s
    csn.execute    command=${sudo} scp /var/tmp/${file_name} 192.168.101.8:/tmp    connection=RU_${ru_index}    timeout=300
    sleep    5s
    csn.execute    command=${sudo} scp /var/tmp/${file_name} 192.168.101.9:/tmp    connection=RU_${ru_index}    timeout=300
    sleep    5s
    csn.Disconnect   connection=RU_${ru_index}
    csn.Disconnect   connection=ASIK Master
    [Teardown]    csn.Reset Cache

configure BWF on RU
    [Arguments]    ${ru_index}=${1}
    log to console    configure BWF on RU ${ru_index}
    Run Keyword If    '${ru_type_dic}[ru_type_${ru_index}]'=='AEQE'
    ...    configure BWF on made    file_name=RF6.1_LF_Master_ECPRI_AEQE_bfwset_1_474750Adt.json    ru_index=${ru_index}
    ...    ELSE IF    '${ru_type_dic}[ru_type_${ru_index}]'=='AEQP'
    ...    configure BWF on made    file_name=RF6.1_LF_Master_ECPRI_AEQP_bfwset_1_475238Adt.json    ru_index=${ru_index}
    sleep    10s

Connect To Node Via RU Connection
    [Arguments]    ${node_id}    ${node_alias}=node_${node_id}    ${nodes}=${Node}    ${ru_index}=1
    ${nodes_length}    Get Length    ${nodes}
    FOR    ${i}    IN RANGE    0    ${nodes_length}
        ${node_ip}    run keyword if    ${Node[${i}]}[id]==${node_id}    set variable    ${Node[${i}]}[ip]
        Exit For Loop If    '${node_ip}'!='${None}'
    END
    csn.connect to    hostname=${node_ip}
    ...               username=root
    ...               password=a2%FgSz3$fHmdusap354xujw7a
    ...               alias=${node_alias}
    ...               proxy=RU_${ru_index}
execute command on specified Node
    [Arguments]    ${file_name}    ${node_id}
    ${sudo}    csn.execute    command=which sudo    connection=node_${node_id}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable
    ...    echo "/ action create ConfigAccess /cofi /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=node_${node_id}
    #Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/cofi action store PERMANENT DECODED "bfwset_inst0.bin" "/var/tmp/${file_name}"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=node_${node_id}
    #Should Contain    ${output}    done ok
    sleep    3s
    ${cmd_temp}   Set Variable
    ...    echo "/cofi action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=node_${node_id}
    Should Contain    ${output}    done ok
    sleep    2s

configure BWF on made
    [Arguments]    ${file_name}    ${asik_alias}=ASIK Master    ${ru_index}=1
    upload file to made    file_name=${file_name}    ru_index=${ru_index}
    Connect to Common Unit Master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=${asik_alias}
    Connect To Node Via RU Connection    node_id=1    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    execute command on specified Node    file_name=${file_name}    node_id=1    ru_index=${ru_index}
    csn.Disconnect   connection=node_1
    Connect To Node Via RU Connection    node_id=2    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    execute command on specified Node    file_name=${file_name}    node_id=2    ru_index=${ru_index}
    csn.Disconnect   connection=node_2
    Connect To Node Via RU Connection    node_id=3    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    execute command on specified Node    file_name=${file_name}    node_id=3    ru_index=${ru_index}
    csn.Disconnect   connection=node_3
    Connect To Node Via RU Connection    node_id=4    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    execute command on specified Node    file_name=${file_name}    node_id=4    ru_index=${ru_index}
    csn.Disconnect   connection=node_4
    Connect To Node Via RU Connection    node_id=5    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    execute command on specified Node    file_name=${file_name}    node_id=5    ru_index=${ru_index}
    csn.Disconnect   connection=node_5
    Connect To Node Via RU Connection    node_id=6    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    execute command on specified Node    file_name=${file_name}    node_id=6    ru_index=${ru_index}
    csn.Disconnect   connection=node_6
    Connect To Node Via RU Connection    node_id=7    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    execute command on specified Node    file_name=${file_name}    node_id=7    ru_index=${ru_index}
    csn.Disconnect   connection=node_7
    Connect To Node Via RU Connection    node_id=8    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    execute command on specified Node    file_name=${file_name}    node_id=8    ru_index=${ru_index}
    csn.Disconnect   connection=node_8
    csn.Disconnect   connection=RU_${ru_index}
    csn.Disconnect   connection=ASIK Master
    sleep    3s
    Perform RU Reset    ru_index=${ru_index}
    sleep    5min
    [Teardown]    csn.Reset Cache
Save result file
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${cmd_temp}    Set Variable    cp /home/ute/TA/CB008962/CB008962_Result.xlsx /home/ute/TA/CB008962_Result_${time_stamp}.xlsx
    ${res}    Run    ${cmd_temp}
Save result file CB012662
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${cmd_temp}    Set Variable
    ...    cp /home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx /home/ute/TA/CB008962_slotwiseload_result_${time_stamp}.xlsx
    ${res}    Run    ${cmd_temp}
CB008962 test suite teardown
    Save result file
    SISO Coam Suite Teardown
CB012662 test suite teardown
    Save result file CB012662
    Run Keyword And Ignore Error    enable deepsleep Mode
    SISO Coam Suite Teardown
UnBlock Cells and check status with deep sleep
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${block_list}  ${check_alarm}=${True}   ${technology}=NR   ${gnb_type}='NSA'
    Selenium Login And Disable Screen Lock
    sleep    1s
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    sleep    1s
    log to console  \n***unblock cells and check status***
    FOR    ${idx}  IN  @{block_list}
        log to console  \nunBlock Global cell ID : ${idx} for ${technology} and check status
        selenium_coam.unblock_cell    cell_idx=${idx}    technology=${technology}
    END
    sleep    10min
    Wait For Expect Fault To Disappear  faultId=49    timeout=60
    run keyword if  ${check_alarm}==${True} and ${gNB_type}=='NSA'
    ...    run keywords  Wait For Expect Fault To Disappear  faultId=7300   timeout=600   AND
    ...    Wait For Expect Fault To Disappear  faultId=7319   timeout=300
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    selenium logout and close browser
start 5g downlink test and check status
   [Arguments]   ${p_max}=${34.9}    ${polarization}=P_both    ${physical_cell_id}=${None}    ${nrarfcn}=${None}    ${test_id}=${1}
    ...    ${power_backoff}=${0}    ${beam_id}=${983}    ${local_cell}=${None}    ${test_model}=NR-FR1-TM1.1
    ...    ${level_of_load_burst}=${None}    ${type_of_load}=${None}
    selenium_coam.start_5g_downlink_test
    ...    local_cell=${local_cell}    power_backoff=${power_backoff}    test_model=${test_model}
    ...    p_max=${p_max}    polarization=${polarization}    physical_cell_id=${physical_cell_id}    beam_id=${beam_id}
    ...    nrarfcn=${nrarfcn}    ru_mode=NR_Only    timeout=20
    ...    level_of_load_burst=${level_of_load_burst}    type_of_load=${type_of_load}
    ${output}    selenium_coam.wait_for_5g_downlink_test_to_start    test_id=${test_id}
disable deepsleep Mode
    [Arguments]
    ${modify_params}    create list
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    ${item}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
        ...    filter_param=Energy Saving Mode Activation    p_name=energySavingMode    value=NORMAL
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
        ...    filter_param=Energy Saving Mode Activation    p_name=energySavingMode    value=NORMAL
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
        ...    filter_param=Energy Saving Mode Activation    p_name=energySavingMode    value=NORMAL
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    [Teardown]    selenium logout and close browser
enable deepsleep mode
    [Arguments]
    ${modify_params}    create list
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    ${item}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
        ...    filter_param=Energy Saving Mode Activation    p_name=energySavingMode    value=DEEPSLEEP
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
        ...    filter_param=Energy Saving Mode Activation    p_name=energySavingMode    value=DEEPSLEEP
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-3
        ...    filter_param=Energy Saving Mode Activation    p_name=energySavingMode    value=DEEPSLEEP
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    [Teardown]    selenium logout and close browser
Activate RD mode
    [Arguments]
    log to console    Activate RD mode
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    selenium_coam.change_bts_rnd_parameters    swsystem_component_idx=69    rnd_setting_type=Dynamic changes
    ...    rnd_in_json_format=[{"paramIndexNumber":39,"paramValue":1}]
    [Teardown]    selenium logout and close browser
Start NR downlink test slotwiseload
    [Arguments]    ${power_backoff}=${0}    ${beam_id}=${951}    ${localcell_postfix}=${EMPTY}
    ...    ${level_of_load_slot_wise}=${None}    ${type_of_load}=slotWiseLoad    ${test_model}=NR-FR1-TM1.1.ETSI
    ...    ${p_max}=${34.9}    ${polarization}=P_both
    log to console    Start NR downlink test
    Selenium Login And Disable Screen Lock
    run keyword and ignore error    selenium_coam.disable_message_box
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    ${nrarfcn_cell1}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...  filter_param=NR Absolute radio frequency channel number
    ${nrarfcn_cell2}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-2
    ...  filter_param=NR Absolute radio frequency channel number
    ${nrarfcn_cell3}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-3
    ...  filter_param=NR Absolute radio frequency channel number
    ${pci_cell1}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1
    ...  filter_param=Physical cell identifier
    ${pci_cell2}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-2
    ...  filter_param=Physical cell identifier
    ${pci_cell3}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-3
    ...  filter_param=Physical cell identifier
    log to console    start NRCELL-1 NR downlink test
    selenium_coam.start_5g_downlink_test
    ...    local_cell=NRCELL-1${localcell_postfix}    power_backoff=${power_backoff}    test_model=${test_model}
    ...    p_max=${p_max}    polarization=${polarization}    physical_cell_id=${pci_cell1}    beam_id=${beam_id}
    ...    nrarfcn=${nrarfcn_cell1}    ru_mode=NR_Only    timeout=${60}
    ...    level_of_load_slot_wise=${level_of_load_slot_wise}    type_of_load=${type_of_load}
    ...    spec_ssb_beam_pattern=1,2,3,4,5,6,7,8
    ${output}    selenium_coam.wait_for_5g_downlink_test_to_start    test_id=${1}
    sleep    2s
    log to console    start NRCELL-2 NR downlink test
    selenium_coam.start_5g_downlink_test
    ...    local_cell=NRCELL-2${localcell_postfix}    power_backoff=${power_backoff}    test_model=${test_model}
    ...    p_max=${p_max}    polarization=${polarization}    physical_cell_id=${pci_cell2}    beam_id=${beam_id}
    ...    nrarfcn=${nrarfcn_cell2}    ru_mode=NR_Only    timeout=${60}
    ...    level_of_load_slot_wise=${level_of_load_slot_wise}    type_of_load=${type_of_load}
    ...    spec_ssb_beam_pattern=1,2,3,4,5,6,7,8
    ${output}    selenium_coam.wait_for_5g_downlink_test_to_start    test_id=${2}
    sleep    2s
    log to console    start NRCELL-3 NR downlink test
    selenium_coam.start_5g_downlink_test
    ...    local_cell=NRCELL-3${localcell_postfix}    power_backoff=${power_backoff}    test_model=${test_model}
    ...    p_max=${p_max}    polarization=${polarization}    physical_cell_id=${pci_cell3}    beam_id=${beam_id}
    ...    nrarfcn=${nrarfcn_cell3}    ru_mode=NR_Only    timeout=${60}
    ...    level_of_load_slot_wise=${level_of_load_slot_wise}    type_of_load=${type_of_load}
    ...    spec_ssb_beam_pattern=1,2,3,4,5,6,7,8
    ${output}    selenium_coam.wait_for_5g_downlink_test_to_start    test_id=${3}
    [Teardown]   selenium logout and close browser
Write load_0_low PM counter value to excel
    log to console    Write load_0_low PM counter value to excel
    ${value_2_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40002C0
    ${value_3_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40002C1
    ${value_4_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40002C2
    ${value_6_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C0_1
    ${value_6_4}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C0_2
    ${value_6_5}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C0_3
    ${value_7_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C1_1
    ${value_7_4}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C1_2
    ${value_7_5}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C1_3
    ${value_8_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C2_1
    ${value_8_4}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C2_2
    ${value_8_5}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C2_3
    ${value_9_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C3_1
    ${value_9_4}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C3_2
    ${value_9_5}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C3_3
    ${value_10_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C4_1
    ${value_10_4}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C4_2
    ${value_10_5}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C4_3
    ${value_11_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C5_1
    ${value_11_4}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C5_2
    ${value_11_5}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40003C5_3
    ${value_12_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40004C0
    ${value_13_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40004C1
    ${value_14_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40004C2
    ${value_15_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40004C3
    ${value_16_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40004C4
    ${value_17_3}=   Get From Dictionary   ${dict_counter_values_load_0_low}   M40004C5
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=2    column=3    value=${value_2_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=3    column=3    value=${value_3_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=4    column=3    value=${value_4_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=3    value=${value_6_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=4    value=${value_6_4}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=5    value=${value_6_5}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=3    value=${value_7_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=4    value=${value_7_4}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=5    value=${value_7_5}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=3    value=${value_8_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=4    value=${value_8_4}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=5    value=${value_8_5}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=3    value=${value_9_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=4    value=${value_9_4}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=5    value=${value_9_5}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=3    value=${value_10_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=4    value=${value_10_4}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=5    value=${value_10_5}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=3    value=${value_11_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=4    value=${value_11_4}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=5    value=${value_11_5}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=12    column=3    value=${value_12_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=13    column=3    value=${value_13_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=14    column=3    value=${value_14_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=15    column=3    value=${value_15_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=16    column=3    value=${value_16_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=17    column=3    value=${value_17_3}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=18    column=1    value=${Active_SW_version}
Write load_10 PM counter value to excel
    log to console    write on air
    ${value_2_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40002C0
    ${value_3_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40002C1
    ${value_4_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40002C2
    ${value_6_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C0_1
    ${value_6_7}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C0_2
    ${value_6_8}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C0_3
    ${value_7_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C1_1
    ${value_7_7}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C1_2
    ${value_7_8}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C1_3
    ${value_8_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C2_1
    ${value_8_7}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C2_2
    ${value_8_8}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C2_3
    ${value_9_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C3_1
    ${value_9_7}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C3_2
    ${value_9_8}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C3_3
    ${value_10_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C4_1
    ${value_10_7}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C4_2
    ${value_10_8}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C4_3
    ${value_11_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C5_1
    ${value_11_7}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C5_2
    ${value_11_8}=   Get From Dictionary   ${dict_counter_values_load_10}   M40003C5_3
    ${value_12_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40004C0
    ${value_13_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40004C1
    ${value_14_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40004C2
    ${value_15_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40004C3
    ${value_16_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40004C4
    ${value_17_6}=   Get From Dictionary   ${dict_counter_values_load_10}   M40004C5
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=2    column=6    value=${value_2_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=3    column=6    value=${value_3_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=4    column=6    value=${value_4_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=6    value=${value_6_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=7    value=${value_6_7}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=8    value=${value_6_8}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=6    value=${value_7_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=7    value=${value_7_7}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=8    value=${value_7_8}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=6    value=${value_8_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=7    value=${value_8_7}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=8    value=${value_8_8}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=6    value=${value_9_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=7    value=${value_9_7}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=8    value=${value_9_8}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=6    value=${value_10_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=7    value=${value_10_7}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=8    value=${value_10_8}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=6    value=${value_11_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=7    value=${value_11_7}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=8    value=${value_11_8}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=12    column=6    value=${value_12_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=13    column=6    value=${value_13_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=14    column=6    value=${value_14_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=15    column=6    value=${value_15_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=16    column=6    value=${value_16_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=17    column=6    value=${value_17_6}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=18    column=1    value=${Active_SW_version}

Write load_30_medium PM counter value to excel
    log to console    Write load_30_medium PM counter value to excel
    ${value_2_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40002C0
    ${value_3_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40002C1
    ${value_4_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40002C2
    ${value_6_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C0_1
    ${value_6_10}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C0_2
    ${value_6_11}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C0_3
    ${value_7_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C1_1
    ${value_7_10}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C1_2
    ${value_7_11}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C1_3
    ${value_8_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C2_1
    ${value_8_10}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C2_2
    ${value_8_11}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C2_3
    ${value_9_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C3_1
    ${value_9_10}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C3_2
    ${value_9_11}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C3_3
    ${value_10_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C4_1
    ${value_10_10}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C4_2
    ${value_10_11}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C4_3
    ${value_11_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C5_1
    ${value_11_10}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C5_2
    ${value_11_11}=   Get From Dictionary   ${dict_counter_values_load_30}   M40003C5_3
    ${value_12_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40004C0
    ${value_13_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40004C1
    ${value_14_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40004C2
    ${value_15_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40004C3
    ${value_16_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40004C4
    ${value_17_9}=   Get From Dictionary   ${dict_counter_values_load_30}   M40004C5
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=2    column=9    value=${value_2_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=3    column=9    value=${value_3_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=4    column=9    value=${value_4_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=9    value=${value_6_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=10    value=${value_6_10}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=11    value=${value_6_11}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=9    value=${value_7_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=10    value=${value_7_10}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=11    value=${value_7_11}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=9    value=${value_8_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=10    value=${value_8_10}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=11    value=${value_8_11}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=9    value=${value_9_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=10    value=${value_9_10}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=11    value=${value_9_11}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=9    value=${value_10_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=10    value=${value_10_10}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=11    value=${value_10_11}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=9    value=${value_11_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=10    value=${value_11_10}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=11    value=${value_11_11}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=12    column=9    value=${value_12_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=13    column=9    value=${value_13_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=14    column=9    value=${value_14_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=15    column=9    value=${value_15_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=16    column=9    value=${value_16_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=17    column=9    value=${value_17_9}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=18    column=1    value=${Active_SW_version}
Write load_50_busy PM counter value to excel
    log to console    Write load_50_busy PM counter value to excel
    ${value_2_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40002C0
    ${value_3_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40002C1
    ${value_4_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40002C2
    ${value_6_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C0_1
    ${value_6_13}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C0_2
    ${value_6_14}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C0_3
    ${value_7_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C1_1
    ${value_7_13}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C1_2
    ${value_7_14}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C1_3
    ${value_8_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C2_1
    ${value_8_13}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C2_2
    ${value_8_14}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C2_3
    ${value_9_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C3_1
    ${value_9_13}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C3_2
    ${value_9_14}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C3_3
    ${value_10_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C4_1
    ${value_10_13}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C4_2
    ${value_10_14}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C4_3
    ${value_11_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C5_1
    ${value_11_13}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C5_2
    ${value_11_14}=   Get From Dictionary   ${dict_counter_values_load_50}   M40003C5_3
    ${value_12_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40004C0
    ${value_13_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40004C1
    ${value_14_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40004C2
    ${value_15_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40004C3
    ${value_16_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40004C4
    ${value_17_12}=   Get From Dictionary   ${dict_counter_values_load_50}   M40004C5
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=2    column=12    value=${value_2_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=3    column=12    value=${value_3_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=4    column=12    value=${value_4_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=12    value=${value_6_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=13    value=${value_6_13}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=14    value=${value_6_14}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=12    value=${value_7_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=13    value=${value_7_13}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=14    value=${value_7_14}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=12    value=${value_8_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=13    value=${value_8_13}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=14    value=${value_8_14}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=12    value=${value_9_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=13    value=${value_9_13}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=14    value=${value_9_14}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=12    value=${value_10_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=13    value=${value_10_13}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=14    value=${value_10_14}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=12    value=${value_11_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=13    value=${value_11_13}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=14    value=${value_11_14}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=12    column=12    value=${value_12_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=13    column=12    value=${value_13_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=14    column=12    value=${value_14_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=15    column=12    value=${value_15_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=16    column=12    value=${value_16_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=17    column=12    value=${value_17_12}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=18    column=1    value=${Active_SW_version}
Write load_70 PM counter value to excel
    log to console    Write load_70 PM counter value to excel
    ${value_2_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40002C0
    ${value_3_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40002C1
    ${value_4_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40002C2
    ${value_6_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C0_1
    ${value_6_16}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C0_2
    ${value_6_17}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C0_3
    ${value_7_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C1_1
    ${value_7_16}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C1_2
    ${value_7_17}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C1_3
    ${value_8_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C2_1
    ${value_8_16}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C2_2
    ${value_8_17}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C2_3
    ${value_9_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C3_1
    ${value_9_16}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C3_2
    ${value_9_17}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C3_3
    ${value_10_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C4_1
    ${value_10_16}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C4_2
    ${value_10_17}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C4_3
    ${value_11_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C5_1
    ${value_11_16}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C5_2
    ${value_11_17}=   Get From Dictionary   ${dict_counter_values_load_70}   M40003C5_3
    ${value_12_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40004C0
    ${value_13_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40004C1
    ${value_14_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40004C2
    ${value_15_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40004C3
    ${value_16_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40004C4
    ${value_17_15}=   Get From Dictionary   ${dict_counter_values_load_70}   M40004C5
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=2    column=15    value=${value_2_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=3    column=15    value=${value_3_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=4    column=15    value=${value_4_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=15    value=${value_6_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=16    value=${value_6_16}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=6    column=17    value=${value_6_17}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=15    value=${value_7_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=16    value=${value_7_16}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=7    column=17    value=${value_7_17}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=15    value=${value_8_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=16    value=${value_8_16}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=8    column=17    value=${value_8_17}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=15    value=${value_9_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=16    value=${value_9_16}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=9    column=17    value=${value_9_17}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=15    value=${value_10_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=16    value=${value_10_16}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=10    column=17    value=${value_10_17}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=15    value=${value_11_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=16    value=${value_11_16}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=11    column=17    value=${value_11_17}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=12    column=15    value=${value_12_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=13    column=15    value=${value_13_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=14    column=15    value=${value_14_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=15    column=15    value=${value_15_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=16    column=15    value=${value_16_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=17    column=15    value=${value_17_15}
    wirte_data_to_excel    filepath=/home/ute/TA/CB008962/CB008962_slotwiseload_result.xlsx    sheet=Sheet1
    ...    row=18    column=1    value=${Active_SW_version}
