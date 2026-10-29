*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : 5GC002637-A

Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Variables    ../TestData/2637_variables.py

*** Variables ***
${MAC_dl}    30000000
${MAC_ul}    1900000
${MAX_LOOP2}    19
${ui_version_M40P}    M40PUI1.1
@{cell_id1}    ${0}
*** Keywords ***
Online Delta Commission
    [Arguments]    ${dist_name}    ${filter_param}    ${target_value}
    ${current_value}    selenium_coam.get_parameter_value    dist_name=${dist_name}
	...    filter_param=${filter_param}
    run keyword if  not '${current_value}'=='${target_value}'
    ...    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}
    ...    new_value=${target_value}

Modify Parameters for Throughput Counter
    [Arguments]    ${actIpThpt}    ${miNrPDCPCell}    ${miNrHighRlcCell}
	wait until keyword succeeds    2min    20s    WEBUI Login
#    ${release}    Get program version based on gNB active version
#    ${flitervalue_actIpThpt}=   Run Keyword If   "${release}"=="master"
#    ...     Set Variable       Activate reporting of DL PDCP cell level and DL/UL RLC cell level throughput PM counters
#	...     ELSE    Set Variable     Activate reporting of DL PDCP cell level and DL/UL RLC cell level PM counters
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate reporting of DL PDCP cell level and DL/UL RLC cell level throughput PM counters
    ...    target_value=${actIpThpt}
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPMRNL-1
    ...    filter_param=NR PDCP Report Cell    target_value=${miNrPDCPCell}
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPMRNL-1
    ...    filter_param=NR High RLC Report Cell   target_value=${miNrHighRlcCell}
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${300}
    COAM Wait for gnb ready and cell setup    timeout=15min    gnb_type='NSA'
	selenium logout and close browser

Modify Parameters for MAC Throughput Counter
    [Arguments]    ${miNrCellUtilization}    ${miNrMacSduReport}
	wait until keyword succeeds    2min    20s    WEBUI Login
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPMRNL-1
    ...    filter_param=NR Cell Utilization    target_value=${miNrCellUtilization}
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPMRNL-1
    ...    filter_param=NR MAC SDU Report    target_value=${miNrMacSduReport}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    COAM Wait for gnb ready and cell setup    timeout=15min    gnb_type='NSA'
	selenium logout and close browser

Get wait value minutes
    [Arguments]    ${interval}
    Connect to Common Unit Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${wait_time}

MAC Throughput Counter Should Be Equal Zero
    [Arguments]    ${interval}
	Connect to Common Unit Master
	selenium login and disable screen lock
	${ACC_CELL_DL_DRB_DATA}    Get PM Counter via Webem    counter_id=M55308C26001    interval=${interval}
	Should be True    ${ACC_CELL_DL_DRB_DATA} == 0
    ${ACC_CELL_UL_DRB_DATA}    Get PM Counter via Webem    counter_id=M55308C26002    interval=${interval}
    Should be True    ${ACC_CELL_UL_DRB_DATA} == 0
	${ACC_UE_DL_SLEEP_DATA}    Get PM Counter via Webem    counter_id=M55308C27001    interval=${interval}
	Should be True    ${ACC_UE_DL_SLEEP_DATA} == 0
	${MAC_DTCH_CELL_THP_DL_MAX}    Get PM Counter via Webem    counter_id=M55309C12001    interval=${interval}
	Should be True    ${MAC_DTCH_CELL_THP_DL_MAX} == 0
	${MAC_DTCH_CELL_THP_UL_MAX}    Get PM Counter via Webem    counter_id=M55309C12002    interval=${interval}
	Should be True    ${MAC_DTCH_CELL_THP_UL_MAX} == 0
    selenium logout and close browser

MAC Throughput Counter Should Be Greater Than Zero
    [Arguments]    ${interval}
	Connect to Common Unit Master
	selenium login and disable screen lock
	${ACC_CELL_DL_DRB_DATA}    Get PM Counter via Webem    counter_id=M55308C26001    interval=${interval}
	Should be True    ${ACC_CELL_DL_DRB_DATA} > 0
    ${ACC_CELL_UL_DRB_DATA}    Get PM Counter via Webem    counter_id=M55308C26002    interval=${interval}
    Should be True    ${ACC_CELL_UL_DRB_DATA} > 0
	${ACC_UE_DL_SLEEP_DATA}    Get PM Counter via Webem    counter_id=M55308C27001    interval=${interval}
	Should be True    ${ACC_UE_DL_SLEEP_DATA} > 0
	${MAC_DTCH_CELL_THP_DL_MAX}    Get PM Counter via Webem    counter_id=M55309C12001    interval=${interval}
	Should be True    ${MAC_DTCH_CELL_THP_DL_MAX} > ${MAC_dl}
	${MAC_DTCH_CELL_THP_UL_MAX}    Get PM Counter via Webem    counter_id=M55309C12002    interval=${interval}
	Should be True    ${MAC_DTCH_CELL_THP_UL_MAX} > ${MAC_ul}
    selenium logout and close browser

Check and Get MAC Throughput Counter Length
    Connect to Common Unit Master
	selenium login and disable screen lock
    ${ACC_CELL_DL_DRB_DATA}    Get PM Counter content via Webem    counter_id=M55308C26001
    ${len_1}    get length  ${ACC_CELL_DL_DRB_DATA}
    ${ACC_CELL_UL_DRB_DATA}    Get PM Counter content via Webem    counter_id=M55308C26002
    ${len_2}    get length  ${ACC_CELL_UL_DRB_DATA}
    Should be True    ${len_1} == ${len_2}
    ${ACC_UE_DL_SLEEP_DATA}    Get PM Counter content via Webem    counter_id=M55308C27001
    ${len_3}    get length  ${ACC_UE_DL_SLEEP_DATA}
    Should be True    ${len_3} == ${len_2}
    ${MAC_DTCH_CELL_THP_DL_MAX}    Get PM Counter content via Webem    counter_id=M55309C12001
    ${len_4}    get length  ${MAC_DTCH_CELL_THP_DL_MAX}
    Should be True    ${len_4} == ${len_3}
    ${MAC_DTCH_CELL_THP_UL_MAX}    Get PM Counter content via Webem    counter_id=M55309C12002
    ${len_5}    get length  ${MAC_DTCH_CELL_THP_UL_MAX}
    Should be True    ${len_5} == ${len_4}
    selenium logout and close browser
    [Return]      ${len_1}

MAC_Throughput_Counter__Activate_Deactivate_via_WebEM
    [Arguments]    ${interval}
	${old_len}    Check and Get MAC Throughput Counter Length
	Should be True    ${old_len} > 0
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}    loop_times=${1}    duration=${120}
    ...    target_avg_percent=0.5    min_percent=0.2    buffer_size=800B    ui_version=${ui_version_M40P}
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
	${new_len}    Check and Get MAC Throughput Counter Length
	Should be True    ${new_len} > ${old_len}
    MAC Throughput Counter Should Be Greater Than Zero    interval=${interval}
    Modify Parameters for MAC Throughput Counter
    ...    miNrCellUtilization=disabled
    ...    miNrMacSduReport=disabled
	${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
	${halted_len}    Check and Get MAC Throughput Counter Length
	Should be True    ${halted_len} == ${new_len}
	Modify Parameters for MAC Throughput Counter
    ...    miNrCellUtilization=15min
    ...    miNrMacSduReport=15min
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
	${latest_len}    Check and Get MAC Throughput Counter Length
	Should be True    ${latest_len} > ${new_len}
#    MAC Throughput Counter Should Be Equal Zero    interval=${interval}

Generate New Thoughput Counter
    [Arguments]    ${counter_id}    ${interval}
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    selenium login and disable screen lock
	${old_counter_content}    Get PM Counter content via Webem    counter_id=${counter_id}
    ${old_len}    get length  ${old_counter_content}
    selenium logout and close browser
    ${ue_index_list}    create list    ${0}
    Ue Attach and Start DL UL Traffic    ue_index_list=${ue_index_list}    dl_tp=400M
    sleep    30s
    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index_list}
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
	selenium login and disable screen lock
	${new_counter_content}    Get PM Counter content via Webem    counter_id=${counter_id}
    ${new_len}    get length  ${new_counter_content}
	Should be True    ${new_len} > ${old_len}
	${new_counter_value}    Get PM Counter via Webem    counter_id=${counter_id}    interval=${interval}
	Run Keyword If    '${counter_id}'!='M55350C06001' and '${counter_id}'!='M55350C05007'
	...    Should be True    ${new_counter_value} > 0
	...    ELSE    Should be True    ${new_counter_value} == 0
    selenium logout and close browser

Throughput Counter Should Be Equal Zero
    [Arguments]    ${interval}
	Connect to Common Unit Master
	selenium login and disable screen lock
	${DL_PDCP_VOL_UE_TPUT_QOS_07}    Get PM Counter via Webem    counter_id=M55350C01007    interval=${interval}
	Should be True    ${DL_PDCP_VOL_UE_TPUT_QOS_07} == 0
    ${MAX_DL_PDCP_BURST_TPUT}    Get PM Counter via Webem    counter_id=M55350C02001    interval=${interval}
    Should be True    ${MAX_DL_PDCP_BURST_TPUT} == 0
	${DL_PDCP_VOL_UE_TPUT_5G_QOS07}    Get PM Counter via Webem    counter_id=M55350C03007    interval=${interval}
	Should be True    ${DL_PDCP_VOL_UE_TPUT_5G_QOS07} == 0
	${DL_PDCP_TIME_UE_TPUT_QOS_07}    Get PM Counter via Webem    counter_id=M55350C00007    interval=${interval}
	Should be True    ${DL_PDCP_TIME_UE_TPUT_QOS_07} == 0
	${MAX_DL_PDCP_BURST_TPUT_5GLEG}    Get PM Counter via Webem    counter_id=M55350C04001    interval=${interval}
	Should be True    ${MAX_DL_PDCP_BURST_TPUT_5GLEG} == 0
	${UL_RLC_VOL_UE_TPUT_QOS_07}    Get PM Counter via Webem    counter_id=M55349C01007    interval=${interval}
	Should be True    ${UL_RLC_VOL_UE_TPUT_QOS_07} == 0
    ${UL_RLC_TIME_UE_TPUT_QOS_07}    Get PM Counter via Webem    counter_id=M55349C00007    interval=${interval}
    Should be True    ${UL_RLC_TIME_UE_TPUT_QOS_07} == 0
	${MAX_UL_RLC_UE_TPUT}    Get PM Counter via Webem    counter_id=M55349C02001    interval=${interval}
	Should be True    ${MAX_UL_RLC_UE_TPUT} == 0
	${DL_PDCP_VOL_UE_TPUT_LTE_QOS07}    Get PM Counter via Webem    counter_id=M55350C05007    interval=${interval}
	Should be True    ${DL_PDCP_VOL_UE_TPUT_LTE_QOS07} == 0
	${MAX_DL_PDCP_BURST_TPUT_LTELEG}    Get PM Counter via Webem    counter_id=M55350C06001    interval=${interval}
	Should be True    ${MAX_DL_PDCP_BURST_TPUT_LTELEG} == 0
    selenium logout and close browser

Throughput Counter Should Be Greater Than Zero
    [Arguments]    ${interval}
    Connect to Common Unit Master
    selenium login and disable screen lock
    ${DL_PDCP_VOL_UE_TPUT_QOS_09}    Get PM Counter via Webem    counter_id=M55350C01009    interval=${interval}
    Should be True    ${DL_PDCP_VOL_UE_TPUT_QOS_09} > 0
    ${MAX_DL_PDCP_BURST_TPUT}    Get PM Counter via Webem    counter_id=M55350C02001    interval=${interval}
    ${dl_diff}    Get the diff    ${dl_ave}    ${MAX_DL_PDCP_BURST_TPUT}
    ${tmp}=   Evaluate    ${MAX_DL_PDCP_BURST_TPUT}*0.1
    Should be True    ${dl_diff} < ${tmp}
    ${DL_PDCP_VOL_UE_TPUT_5G_QOS09}    Get PM Counter via Webem    counter_id=M55350C03009    interval=${interval}
    Should be True    ${DL_PDCP_VOL_UE_TPUT_5G_QOS09} > 0
    ${DL_PDCP_TIME_UE_TPUT_QOS_09}    Get PM Counter via Webem    counter_id=M55350C00009    interval=${interval}
    Should be True    ${DL_PDCP_TIME_UE_TPUT_QOS_09} > 0
    ${MAX_DL_PDCP_BURST_TPUT_5GLEG}    Get PM Counter via Webem    counter_id=M55350C04001    interval=${interval}
    Should be True    ${MAX_DL_PDCP_BURST_TPUT_5GLEG} > 0
    ${UL_RLC_VOL_UE_TPUT_QOS_09}    Get PM Counter via Webem    counter_id=M55349C01009    interval=${interval}
    Should be True    ${UL_RLC_VOL_UE_TPUT_QOS_09} > 0
    ${UL_RLC_TIME_UE_TPUT_QOS_09}    Get PM Counter via Webem    counter_id=M55349C00009    interval=${interval}
    Should be True    ${UL_RLC_TIME_UE_TPUT_QOS_09} > 0
    ${MAX_UL_RLC_UE_TPUT}    Get PM Counter via Webem    counter_id=M55349C02001    interval=${interval}
    ${ul_diff}    Get the diff    ${ul_ave}    ${MAX_UL_RLC_UE_TPUT}
    ${tmp}=   Evaluate    ${MAX_UL_RLC_UE_TPUT}*0.1
    Should be True    ${ul_diff} < ${tmp}
#    ${DL_PDCP_VOL_UE_TPUT_LTE_QOS07}    Get PM Counter via Webem    counter_id=M55350C05007    interval=${interval}
#    Should be True    ${DL_PDCP_VOL_UE_TPUT_LTE_QOS07} == 0
#    ${MAX_DL_PDCP_BURST_TPUT_LTELEG}    Get PM Counter via Webem    counter_id=M55350C06001    interval=${interval}
#    Should be True    ${MAX_DL_PDCP_BURST_TPUT_LTELEG} == 0
    selenium logout and close browser

Check and Get Throughput Counter Length
    Connect to Common Unit Master
	selenium login and disable screen lock
    ${MAX_DL_PDCP_BURST_TPUT}    Get PM Counter content via Webem    counter_id=M55350C02001
    ${len_2}    get length  ${MAX_DL_PDCP_BURST_TPUT}
    ${MAX_DL_PDCP_BURST_TPUT_5GLEG}    Get PM Counter content via Webem    counter_id=M55350C04001
    ${len_5}    get length  ${MAX_DL_PDCP_BURST_TPUT_5GLEG}
    Should be True    ${len_5} == ${len_2}
	${MAX_UL_RLC_UE_TPUT}    Get PM Counter content via Webem    counter_id=M55349C02001
    ${len_8}    get length  ${MAX_UL_RLC_UE_TPUT}
    Should be True    ${len_8} == ${len_2}
	${MAX_DL_PDCP_BURST_TPUT_LTELEG}    Get PM Counter content via Webem    counter_id=M55350C06001
    ${len_10}    get length  ${MAX_DL_PDCP_BURST_TPUT_LTELEG}
    Should be True    ${len_10} == ${len_8}
    selenium logout and close browser
    [Return]      ${len_2}

Throughput_Counter_Activate_via_WebUI
    [Arguments]    ${interval}
    ${SCF_1CC}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_1S1CC_2637_
    Commissioning SCF And Check On Air    scf_path=${SCF_1CC}
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    ${old_len}    Check and Get Throughput Counter Length
    Should be True    ${old_len} > 0
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}    loop_times=${1}    duration=${120}
        ...    target_avg_percent=0.5    min_percent=0.2    buffer_size=800B    ui_version=${ui_version_M40P}
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    ${new_len}    Check and Get Throughput Counter Length
    Should be True    ${new_len} > ${old_len}
    ${average_new}    get_average_list    output_info_list=${output}
    ${dl_ave}    set variable    ${average_new}[1]
    ${ul_ave}    set variable    ${average_new}[0]
    ${dl_ave}=   Evaluate    ${dl_ave}*1000
    ${ul_ave}=   Evaluate    ${ul_ave}*1000
    set test variable    ${dl_ave}
    set test variable    ${ul_ave}
    Throughput Counter Should Be Greater Than Zero    interval=${interval}

Throughput_Counter_Deactivate_via_WebUI
    [Arguments]    ${interval}
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    ${old_len}    Check and Get Throughput Counter Length
    Should be True    ${old_len} > 0
    Modify Parameters for Throughput Counter
    ...    actIpThpt=true
    ...    miNrPDCPCell=disabled
    ...    miNrHighRlcCell=disabled
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    ${halted_len}    Check and Get Throughput Counter Length
    Should be True    ${halted_len} == ${old_len}
    Modify Parameters for Throughput Counter
    ...    actIpThpt=true
    ...    miNrPDCPCell=${interval}
    ...    miNrHighRlcCell=${interval}
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    ${new_len}    Check and Get Throughput Counter Length
    Should be True    ${new_len} > ${halted_len}
    Modify Parameters for Throughput Counter
    ...    actIpThpt=false
    ...    miNrPDCPCell=${interval}
    ...    miNrHighRlcCell=${interval}
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    sleep    ${interval}
    ${tmp}=   Evaluate    ${new_len}+1
#	${status}  run keyword and return status  Check and Get Throughput Counter Length
#    Should be True    ${status} == False
    ${halted_len_new}    Check and Get Throughput Counter Length
    Should be true   ${halted_len_new} == ${new_len} or ${halted_len_new} == ${tmp}

5GC002637-A_40_KPI_5100C_monitor
    [Arguments]    ${interval}
    ${SCF_1CC}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_1S1CC_2637_
    Commissioning SCF And Check On Air    scf_path=${SCF_1CC}
    ${wait_time}    Get wait value minutes    interval=${interval}
    sleep    ${wait_time}min
    verify all cells should be onair
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}    loop_times=${1}    duration=${120}
    ...    target_avg_percent=0.5    min_percent=0.2    buffer_size=800B    ui_version=${ui_version_M40P}
    FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP2}
        ${wait_time}    Get wait value minutes    interval=${interval}
        sleep    ${wait_time}min
        verify all cells should be onair
        Run Keyword And Ignore Error    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id1}    loop_times=${1}
        ...    duration=${120}    target_avg_percent=0.5    min_percent=0.2    buffer_size=800B    ui_version=${ui_version_M40P}
    END

Case Preparation
    log to console   \n*** set precondition: throughput counter activate ***
    ${SCF_1CC}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_1S1CC_2637_
    Commissioning SCF And Check On Air    scf_path=${SCF_1CC}
#    Modify Parameters for MAC Throughput Counter
#    ...    miNrCellUtilization=15min
#    ...    miNrMacSduReport=15min
#    Modify Parameters for Throughput Counter
#    ...    actIpThpt=true
#    ...    miNrPDCPCell=15min
#    ...    miNrHighRlcCell=15min
    ${wait_time}    Get wait value minutes    interval=15min
    sleep    ${wait_time}min
