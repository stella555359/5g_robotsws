*** Settings ***
Documentation     KPI report   l3gao

*** Variables ***
${WEBUI_URL}                https://10.57.149.227
${WEBUI_IP}                 10.57.149.227
${WEBUI_USERNAME}           Nemuadmin
${WEBUI_PASSWORD}           nemuuser
${scout_testline_name}    7_5_UTE5G402T37844
${testline_name_x}    7_5_UTE5G402T37844
${api_key}                  e4de17a9d8d540e88e2e5740b805df7b
*** Keywords ***
Generate kpi report until success modify
    [Arguments]   ${mode}=0
    Wait '600s' for stable
    Generate kpi report2    report_name=VRF4_IWF_kpi    mode=${mode}

Generate kpi report2
    [Arguments]     ${report_name}   ${mode}=0
    #sleep   240min
    Log To Console    genarate KPI report...
    ${collect_log_start_time1}  DateTime.Get Current Date  result_format=%Y-%m-%d %H:%M:%S
    run keyword and ignore error     Generate kpi report in Scout2   report_name_1=${report_name}
       ...   collect_log_start_time=${collect_log_start_time1}   mode=${mode}

Generate kpi report in Scout2
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               Param: ${scout_testline_name} is "TL73_gNB" or "TL813_gNB", scout_testline_name in scout, type: str
    ...               Param: the style of ${end_time} and ${start_time} like as "2022-03-29 04:10:00"
    ...                      Time delta between start and end must be above 15 minutes"
    ...                      ${end_time} and ${start_time}:  Date and time must be in past
    ...                      Use the pm xml file under the path "/ffs/run/uri/PERFMON_FILES/" of gnb
    ...                      if " -rw-r--r-- 1 root btssw  72682 Mar 31 11:35 PM.BTS-813.20220331.033500.ANY.xml.gz "
    ...                      so ${end_time} or ${start_time} use 20220331.033500 into "2022-03-31 03:35:00"
    ...               Param: ${template_id}---https://scout.nsn-rdnet.net/kpis-templates/382/, 382 is ${template_id}
    ...               Param: ${api_key}---scout for easy access from robot framework to Scout API
    [Arguments]     ${collect_log_start_time}   ${alias}=scout  ${report_name_1}=Airphone_   ${mode}=0
    log to console   ${report_name_1}
    log to console   ${collect_log_start_time}
#    ${gnb_version}       Get_gNB_Active_SW_Version     #change
    ${new_timestamp}    Add Time to Date   ${collect_log_start_time}    -65 mins
    ${end_timestamp}    Add Time to Date   ${collect_log_start_time}    -5 mins
    ${new_timestamp1}    Get Substring    ${new_timestamp}    0    10
    ${new_timestamp2}    Get Substring    ${new_timestamp}    11    19
    ${end_timestamp1}    Get Substring    ${end_timestamp}    0    10
    ${end_timestamp2}    Get Substring    ${end_timestamp}    11    19

    log to console   debug1 ${SW_VERSION_TOTAL} ${SW_VERSION} ${SOFTWARE_INFO}

    ${start_iso_time}    Catenate   SEPARATOR=   ${new_timestamp1}   T   ${new_timestamp2}   +08:00
    ${end_iso_time}    Catenate   SEPARATOR=   ${end_timestamp1}   T   ${end_timestamp2}   +08:00

    capture snapshot start once    snapshot

    sleep    15min
    ${report_time}  DateTime.Get Current Date  result_format=%Y-%m-%d %H:%M:%S
    ${report_date}    Get Substring    ${report_time}    0    10
    Run Keyword If    ${mode} == 0
    ...   Set Test Variable    ${testmode}    RTM
    ...   ELSE
    ...   Set Test Variable    ${testmode}    FixMode
#    ${kpi_report_name}   Catenate    SEPARATOR=_   PZ4_SG01   ${report_date}   ${testline_name_X}   ${gnb_version}   ${testmode}
    ${kpi_report_name}   Catenate    SEPARATOR=_   PZ4_SG01   ${report_date}   ${testline_name_X}   ${SOFTWARE_INFO}   ${testmode}
    log to console    ${kpi_report_name}
    scout.setup_scout    scout_testline_name=${scout_testline_name}    api_key=${api_key}    alias=${alias}    timeout=1800
    ${report}    scout.generate kpi report    report_name=${kpi_report_name}
    ...                                       template_id=2049
    #...                                     template_id=2405
    ...                                       start_time=${start_iso_time}
    ...                                       end_time=${end_iso_time}
    ...                                       alias=${alias}
    log to console    ${report}
    set suite variable    ${id}    ${report[0]["id"]}
    ${name}   Run Keyword And Ignore error    set suite variable    ${name}        ${report}[name]
    ${cmd1}   set variable    curl -X 'GET' 'https://scout.nsn-rdnet.net/future/api/v1/kpis_reports/${id}/export_to_excel/
    ${cmd2}   set variable    ?apitoken=${api_key}' -H 'accept: application/vnd.api+json'
    ${url}    ${filename}    wait until keyword succeeds     20min    1min    GenreateReport    cmd=${cmd1}${cmd2}
    ${toolcenter}   set variable    toolscenter.eecloud.dynamic.nsn-net.net
    run    curl -X 'GET' 'http://${toolcenter}/api/rtm/addReport/?url=${url.strip()}&filename=${filename}' -H 'accept: */*'
    log to console    Generate kpi report in Scout completed
    [Teardown]    Run Keyword And Ignore Error    scout.teardown_scout_api    alias=${alias}

GenreateReport
    [Arguments]   ${cmd}
    ${ret}    Run    ${cmd}
    log to console    ${ret}
    should be true     ${ret.count('already exist as excel file')}>0
    #should contain    ${ret}    already exist as excel file
    ${ret}     ${dumy}    Split String From Right	 string=${ret}   separator=}     max_split=1
    ${dumy}     ${ret}    Split String 	 string=${ret}   separator={     max_split=1
    ${ret}    set variable    {${ret}}
    ${res}    Evaluate        json.loads('''${ret}''')                   json
    ${pre}    ${filename}    Split String	 string=${res["errors"][0]["detail"]}   separator=:     max_split=1
    ${url}    ${filename}    Split String From Right	 string=${filename}   separator=/     max_split=1
    [Return]   ${url}    ${filename}

Restart IWF
    [Documentation]    Restart iwf process and verify it is running

    Run Process    ps    -C    iwf    stdout=NONE    stderr=NONE
    Run Process    sudo    pkill    -9    iwf
    Wait Until Keyword Succeeds    10s    1s    IWF Should Be Stopped
    Run Process    sudo    python3    /opt/wts/latest/iwf_preconfigs.py
    Wait '15s' for stable
    Run Process    sudo    python3    /opt/wts/latest/iwf_launch.py
    Wait Until Keyword Succeeds    20s    2s    IWF Should Be Running

IWF Should Be Stopped
    ${rc}    Run And Return Rc    ps -C iwf
    Should Not Be Equal As Integers    ${rc}    0

IWF Should Be Running
    ${rc}    Run And Return Rc    ps -C iwf
    Should Be Equal As Integers    ${rc}    0


Ideal line PRB_mulayer counter check
    [Arguments]    ${PM_counter_file}    ${cell_id_t}
    ${8701_pair_counter}   create list
    ${8701_pair_counter_for_table}   create list
    FOR    ${num}    IN RANGE    1    30
        ${counter_1}   evaluate   4000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C3${counter_1}    cell_id=${cell_id_t}
        append to list    ${8701_pair_counter}    ${result}
    END
    log to console    8701_pair_counter all is = ${8701_pair_counter}
    log to console    PRB_DL_SU_MIMO_layer_1_2_3_4 are = ${8701_pair_counter[0:4]}
    log to console    PRB_DL_MU_MIMO_layer2_3_4_5_6_7_8 are = ${8701_pair_counter[4:11]}
    log to console    PRB_DL_MU_MIMO_layer2 is = ${8701_pair_counter[4]}
    log to console    PRB_DL_MU_MIMO_layer3 is = ${8701_pair_counter[5]}
    log to console    PRB_DL_MU_MIMO_layer4 is = ${8701_pair_counter[6]}
    log to console    PRB_DL_MU_MIMO_layer5 is = ${8701_pair_counter[7]}
    log to console    PRB_DL_MU_MIMO_layer6 is = ${8701_pair_counter[8]}
    log to console    PRB_DL_MU_MIMO_layer7 is = ${8701_pair_counter[9]}
    log to console    PRB_DL_MU_MIMO_layer8 is = ${8701_pair_counter[10]}
    log to console    PRB_DL_MU_MIMO_paired_UE_0_2_3_4_5_6_7_8 are = ${8701_pair_counter[11:15]} ${8701_pair_counter[23:27]}
    log to console    PRB_DL_MU_MIMO_layer_9_10_11_12_13_14_15_16 are = ${8701_pair_counter[15:23]}
    log to console    PRB_DL_MU_MIMO_layer_9 is = ${8701_pair_counter[15]}
    log to console    PRB_DL_MU_MIMO_layer_10 is = ${8701_pair_counter[16]}
    log to console    PRB_DL_MU_MIMO_layer_11 is = ${8701_pair_counter[17]}
    log to console    PRB_DL_MU_MIMO_layer_12 is = ${8701_pair_counter[18]}
    log to console    PRB_DL_MU_MIMO_layer_13 is = ${8701_pair_counter[19]}
    log to console    PRB_DL_MU_MIMO_layer_14 is = ${8701_pair_counter[20]}
    log to console    PRB_DL_MU_MIMO_layer_15 is = ${8701_pair_counter[21]}
    log to console    PRB_DL_MU_MIMO_layer_16 is = ${8701_pair_counter[22]}
    log to console    TOT_MU_MIMO_PAIR_UE and TOT_MU_MIMO_ELIG_UE are = ${8701_pair_counter[27]} ${8701_pair_counter[28]}
    ${sum_prb_layer1}    evaluate    ${8701_pair_counter[4]}*2+${8701_pair_counter[5]}*3+${8701_pair_counter[6]}*4
    ${sum_prb_layer2}    evaluate    ${8701_pair_counter[7]}*5+${8701_pair_counter[8]}*6+${8701_pair_counter[9]}*7+${8701_pair_counter[10]}*8
    ${sum_prb_layer3}    evaluate    ${8701_pair_counter[15]}*9+${8701_pair_counter[16]}*10+${8701_pair_counter[17]}*11+${8701_pair_counter[18]}*12
    ${sum_prb_layer4}    evaluate    ${8701_pair_counter[19]}*13+${8701_pair_counter[20]}*14+${8701_pair_counter[21]}*15+${8701_pair_counter[22]}*16
    ${sum_prb_layer_X_layer}    evaluate    ${sum_prb_layer1}+${sum_prb_layer2}+${sum_prb_layer3}+${sum_prb_layer4}

    log to console    sum_prb_layer_X_layer is ${sum_prb_layer_X_layer}

    ${PRB_DL_SU_MIMO_layer_total}    evaluate    sum(${8701_pair_counter[0:4]})
    ${PRB_DL_MU_MIMO_layer_total}    evaluate    sum(${8701_pair_counter[4:11]})+sum(${8701_pair_counter[15:23]})
    ${PRB_DL_MU_paired_UE_total}    evaluate    sum(${8701_pair_counter[12:15]})+sum(${8701_pair_counter[23:27]})
#    ${pair_to_muelig}    evaluate    ${8701_pair_counter[27]}/${8701_pair_counter[28]}
    run keyword and continue on failure   should be true   ${PRB_DL_MU_MIMO_layer_total}==${PRB_DL_MU_paired_UE_total}
    run keyword and continue on failure   should be true   ${PRB_DL_SU_MIMO_layer_total}>=${8701_pair_counter[11]}      #need check
    run keyword and continue on failure   should be true   ${PRB_DL_MU_MIMO_layer_total}==${PRB_DL_MU_paired_UE_total}
#    run keyword and continue on failure   should be true   ${pair_to_muelig}>0.98
    log to console    PRB_DL_SU_MIMO_layer_total is = ${PRB_DL_SU_MIMO_layer_total}
    log to console    PRB_DL_MU_MIMO_layer_total is = ${PRB_DL_MU_MIMO_layer_total}
    log to console    PRB_DL_MU_paired_UE_total is = ${PRB_DL_MU_paired_UE_total}
    append to list    ${8701_pair_counter_for_table}    ${8701_pair_counter[4]}    ${8701_pair_counter[5]}    ${8701_pair_counter[6]}
    ...    ${8701_pair_counter[7]}    ${8701_pair_counter[8]}    ${8701_pair_counter[9]}    ${8701_pair_counter[10]}
    ...    ${8701_pair_counter[15]}    ${8701_pair_counter[16]}    ${8701_pair_counter[17]}    ${8701_pair_counter[18]}
    ...    ${8701_pair_counter[19]}    ${8701_pair_counter[20]}    ${8701_pair_counter[21]}    ${8701_pair_counter[22]}
    ...    ${sum_prb_layer_X_layer}    ${PRB_DL_SU_MIMO_layer_total}    ${PRB_DL_MU_MIMO_layer_total}
    set global variable    ${8701_pair_counter}
    set global variable    ${8701_pair_counter_for_table}
    [Return]    ${8701_pair_counter_for_table}

KPI counter check
    [Arguments]    ${PM_counter_file}    ${cell_id_t}
    ${PDSCH_UNSUCC_64TBL_MCS}    create list
    ${PDSCH_SUCC_ANY_64TBL_MCS}    create list
    ${PDSCH_UNSUCC_256TBL_MCS}    create list
    ${PDSCH_SUCC_ANY_256TBL_MCS}    create list
    FOR    ${num}    IN RANGE    0    32
        ${counter_2}   evaluate   2000+${num}
        ${counter_3}   evaluate   3000+${num}
        ${counter_6}   evaluate   6000+${num}
        ${counter_7}   evaluate   7000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter_2}    cell_id=${cell_id_t}
        append to list    ${PDSCH_SUCC_ANY_64TBL_MCS}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter_3}    cell_id=${cell_id_t}
        append to list    ${PDSCH_UNSUCC_64TBL_MCS}    ${result}

	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter_6}    cell_id=${cell_id_t}
        append to list    ${PDSCH_SUCC_ANY_256TBL_MCS}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter_7}    cell_id=${cell_id_t}
        append to list    ${PDSCH_UNSUCC_256TBL_MCS}    ${result}
    END

#    log to console    PDSCH_SUCC_ANY_64TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_64TBL_MCS}
#    log to console    PDSCH_UNSUCC_64TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_64TBL_MCS}
#    log to console    PDSCH_SUCC_ANY_256TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_256TBL_MCS}
#    log to console    PDSCH_UNSUCC_256TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_256TBL_MCS}
    ${unsucc}    evaluate    sum(${PDSCH_UNSUCC_64TBL_MCS})+sum(${PDSCH_UNSUCC_256TBL_MCS})
    ${SUCC_ANY}    evaluate    sum(${PDSCH_SUCC_ANY_64TBL_MCS})+sum(${PDSCH_SUCC_ANY_256TBL_MCS})
    ${NR_5055b}    evaluate    ${unsucc}/(${SUCC_ANY}+${unsucc})
    run keyword and continue on failure   should be true   ${NR_5055b}<0.001
#    log to console    KPI NR_5055b residual bler is ${NR_5055b}

    ${PDSCH_INITX_64TBL_MCS}    create list
    ${PDSCH_SUCC_INI_64TBL_MCS}    create list
    ${PDSCH_INI_256TBL_MCS}    create list
    ${PDSCH_SUCC_INI_256TBL_MCS}    create list

    FOR    ${num}    IN RANGE    0    10
        ${counter_0}   evaluate   0+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0000${counter_0}    cell_id=${cell_id_t}
        append to list    ${PDSCH_INITX_64TBL_MCS}    ${result}
    END

    FOR    ${num}    IN RANGE    10    29
        ${counter_0}   evaluate   0+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C000${counter_0}    cell_id=${cell_id_t}
        append to list    ${PDSCH_INITX_64TBL_MCS}    ${result}
    END

    FOR    ${num}    IN RANGE    0    29
        ${counter_1}   evaluate   1000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter_1}    cell_id=${cell_id_t}
        append to list    ${PDSCH_SUCC_INI_64TBL_MCS}    ${result}
    END

    FOR    ${num}    IN RANGE    0    28   #256qam mcs max 28
        ${counter_4}   evaluate   4000+${num}
        ${counter_5}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter_4}    cell_id=${cell_id_t}
        append to list    ${PDSCH_INI_256TBL_MCS}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter_5}    cell_id=${cell_id_t}
        append to list    ${PDSCH_SUCC_INI_256TBL_MCS}    ${result}
    END

#    log to console    PDSCH_INITX_64TBL_MCS 0_to_28 is ${PDSCH_INITX_64TBL_MCS}
#    log to console    PDSCH_SUCC_INI_64TBL_MCS 0_to_28 is ${PDSCH_SUCC_INI_64TBL_MCS}
#    log to console    PDSCH_INI_256TBL_MCS 0_to_27 is ${PDSCH_INI_256TBL_MCS}
#    log to console    PDSCH_SUCC_INI_256TBL_MCS 0_to_27 is ${PDSCH_SUCC_INI_256TBL_MCS}

    ${ini_tx}    evaluate    sum(${PDSCH_INITX_64TBL_MCS})+sum(${PDSCH_INI_256TBL_MCS})
    ${ini_SUCC}    evaluate    sum(${PDSCH_SUCC_INI_64TBL_MCS})+sum(${PDSCH_SUCC_INI_256TBL_MCS})
    ${NR_5054a}    evaluate    (${ini_tx}-${ini_SUCC})/${ini_tx}
    run keyword and continue on failure   should be true   ${NR_5054a}<0.1


    ${PDSCH_INIRE_VOL_64TBL_MCS}    create list
    ${PDSCH_INIRE_VOL_256TBL_MCS}    create list
    FOR    ${num}    IN RANGE    0    32
        ${counter_22}   evaluate   2000+${num}
        ${counter_6}   evaluate   6000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_22}    cell_id=${cell_id_t}
        append to list    ${PDSCH_INIRE_VOL_64TBL_MCS}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_6}    cell_id=${cell_id_t}
        append to list    ${PDSCH_INIRE_VOL_256TBL_MCS}    ${result}
    END
#    log to console    PDSCH_INIRE_VOL_64TBL_MCS 0_to_31 is ${PDSCH_INIRE_VOL_64TBL_MCS}
#    log to console    PDSCH_INIRE_VOL_256TBL_MCS 0_to_31 is ${PDSCH_INIRE_VOL_256TBL_MCS}

    ${rt1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C03005    cell_id=${cell_id_t}
    ${rt2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10001    cell_id=${cell_id_t}
    ${rt3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00008    cell_id=${cell_id_t}
    ${rt4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00016    cell_id=${cell_id_t}
    ${rt5}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00018    cell_id=${cell_id_t}
    ${NR_5108d_numerato}    evaluate    8*(sum(${PDSCH_INIRE_VOL_64TBL_MCS})+sum(${PDSCH_INIRE_VOL_256TBL_MCS}))
    ${NR_5108d}    evaluate    ${NR_5108d_numerato}/(${rt1}*180*(${rt2}/(${rt3}+${rt4}+${rt5})))
#    log to console    KPI NR_5108d SE_downlink is ${NR_5108d}

    ${L_M55304C0400X}   create list
    ${M55304C0400X}    set variable    0
    FOR    ${num}    IN RANGE    0    10
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0400${num}    cell_id=${cell_id_t}
        ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
        append to list    ${L_M55304C0400X}    ${result}
    END

    FOR    ${num}    IN RANGE    10    32
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C040${num}    cell_id=${cell_id_t}
        ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
        append to list    ${L_M55304C0400X}    ${result}
    END

    ${L_M55304C0800X}   create list
    ${M55304C0800X}    set variable    0
    FOR    ${num}    IN RANGE    0    10
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0800${num}    cell_id=${cell_id_t}
        ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
        append to list    ${L_M55304C0800X}    ${result}
    END

    FOR    ${num}    IN RANGE    10    32
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C080${num}    cell_id=${cell_id_t}
        ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
        append to list    ${L_M55304C0800X}    ${result}
    END

    ${L_M55304C1000X}   create list
    ${M55304C1000X}    set variable    0
    FOR    ${num}    IN RANGE    0    10
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C1000${num}    cell_id=${cell_id_t}
        ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
        append to list    ${L_M55304C1000X}    ${result}
    END

    FOR    ${num}    IN RANGE    10    32
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C100${num}    cell_id=${cell_id_t}
        ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
        append to list    ${L_M55304C1000X}    ${result}
    END

    ${top_counter}    Evaluate    (${M55304C0400X}+${M55304C0800X}+${M55304C1000X})*8
    ${L_M55308}   create list
    ${M55308C03006}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C03006    cell_id=${cell_id_t}
    ${M55308C10002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10002    cell_id=${cell_id_t}
    ${M55308C00009}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00009    cell_id=${cell_id_t}
    ${M55308C00011}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00011    cell_id=${cell_id_t}
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
    ...    counter_id=M55309C12001    cell_id=${cell_id_t}
    ${NR_5258a}    evaluate    8*${MEAS_PERIOD_NR_MAC_PDU_TPUT}/1000000
#    log to console    KPI NR_5258a MAC SDU Cell Throughput in DL on DTCH is = ${NR_5258a}

    ${PDSCH_INI_VOL_64TBL_MCS_list}    create list
    ${PDSCH_INI_VOL_256TBL_MCS_list}    create list
    ${PDSCH_INI_VOL_LOWSE_MCS_list}    create list
    FOR    ${num}    IN RANGE    0    29
        ${counter_2}   evaluate   1000+${num}
        ${counter_3}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_2}    cell_id=${cell_id_t}
        append to list    ${PDSCH_INI_VOL_64TBL_MCS_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55366C0${counter_3}    cell_id=${cell_id_t}
        append to list    ${PDSCH_INI_VOL_LOWSE_MCS_list}    ${result}
    END

    FOR    ${num}    IN RANGE    0    28
        ${counter_3}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_3}    cell_id=${cell_id_t}
        append to list    ${PDSCH_INI_VOL_256TBL_MCS_list}    ${result}
    END

    ${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55304C00001    cell_id=${cell_id_t}
    ${PRB_USED_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10001    cell_id=${cell_id_t}
    ${PRB_AVAIL_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10003    cell_id=${cell_id_t}
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
    ...    counter_id=M55309C01001    cell_id=${cell_id_t}
    ${DATA_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00005    cell_id=${cell_id_t}
    ${DATA_SLOT_PDSCH_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00008    cell_id=${cell_id_t}
    ${ACC_UE_DL_DRB_DATA}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02000    cell_id=${cell_id_t}
    ${NR_5100b}    evaluate    8*${DL_MAC_SDU_VOL_DTCH}/(${ACC_UE_DL_DRB_DATA}*${DATA_SLOT_PDSCH_TIME}/${DATA_SLOT_PDSCH})

    ${ACC_SCHED_UE_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C17001    cell_id=${cell_id_t}
    ${TOTAL_COSCHED_UE_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02004    cell_id=${cell_id_t}
    ${DL_DATA_SLOTS}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00001    cell_id=${cell_id_t}
    ${DATA_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00005    cell_id=${cell_id_t}
    ${SSB_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00015    cell_id=${cell_id_t}
    ${TRS_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00017    cell_id=${cell_id_t}
    ${NR_5192c}    evaluate    ${ACC_SCHED_UE_PDSCH}/(${DATA_SLOT_PDSCH}+${SSB_SLOT_PDSCH}+${TRS_SLOT_PDSCH})
    ${NR_5112c}    evaluate    ${TOTAL_COSCHED_UE_PDSCH}/(${DL_DATA_SLOTS}+${SSB_SLOT_PDSCH}+${TRS_SLOT_PDSCH})

    log to console    KPI NR_5055b residual bler is = ${NR_5055b}
    log to console    KPI NR_5054a iniBler is = ${NR_5054a}
    log to console    KPI NR_5108d SE_downlink is = ${NR_5108d}
    log to console    KPI NR_5109d SE_uplink is = ${NR_5109d}
    log to console    KPI NR_5242b MAC PDU Cell throughput on PDSCH considering PRB utilization is = ${NR_5242b}
    should be true    ${NR_5242b} > 1200
    log to console    KPI NR_5258a MAC SDU Cell Throughput in DL on DTCH is = ${NR_5258a}
    log to console    KPI NR_5100b Avg MAC user thp DL = ${NR_5100b}
    log to console    KPI NR_5192c Average number of scheduled UEs on PDSCH = ${NR_5192c}
    run keyword and continue on failure   should be true   ${NR_5054a}<0.1
    run keyword and continue on failure   should be true   ${NR_5055b}<0.005
    ${9235_kpi_list}   create list    ${NR_5055b}    ${NR_5054a}    ${NR_5108d}    ${NR_5109d}    ${NR_5242b}
    ...    ${NR_5258a}    ${NR_5100b}    ${NR_5192c}
    [return]     ${9235_kpi_list}

# gnb logs capture
Get gnb_logs from git
     ${exist}    List Directory    /home/ute
    Run keyword if    'gnb_logs-tool' not in ${exist}    OperatingSystem.Run
    ...     cd ${f};git clone https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool;unzip -d ${f}gnb_logs-tool ${f}gnb_logs-tool/gnb_logs.zip
    OperatingSystem.Run    rm /home/ute/gnb_logs-tool/gnb_logs/stop_mon.log
    modify gnb_logs config

Start collect logs by gnb_logs
    [Arguments]    ${command}
    log to console    Start collect logs by gnb_logs
    OperatingSystem.Run    rm -rf /home/ute/gnb_logs-tool/gnb_logs/BTS-1_192.168.255.129*
    TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
    TAF_SSH.Execute    chmod 777 /home/ute/gnb_logs-tool/gnb_logs/gnb_logs    connection=bsh
    TAF_SSH.Send Command    cd /home/ute/gnb_logs-tool/gnb_logs;${command}    connection=bsh
    TAF_SSH.Read Output Until    (Q)uit    connection=bsh

Wait for '${time}' to stop collect logs by gnb tool
    log to console    stop collect logs by gnb tool
    Wait '${time}' for stable
    OperatingSystem.Run    touch /home/ute/gnb_logs-tool/gnb_logs/stop_mon.log
    Wait Until Keyword Succeeds    30000    10    file should contain
    ...    /home/ute/gnb_logs-tool/gnb_logs/tool.log    Tool finished running
    OperatingSystem.Run    scp /home/ute/gnb_logs-tool/gnb_logs/BTS-1_192.168.255.129* ${TEST_LOG_DIRECTORY()}/All

modify gnb_logs config
    setup_txt    /home/ute/gnb_logs-tool/gnb_logs/config.ini
    Modify Txt Node    TTI_log_files:100    BIP_log_files:12
    teardown_txt


