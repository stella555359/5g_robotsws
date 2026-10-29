*** Settings ***
Documentation    author: Charlotte Wu
...              Group: RAN_PZ_HAZ3_SG02
...              contact: charlotte.wu@nokia-sbell.com

Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.config.scf    WITH NAME    scf
Library    taf.analyzer.pcap    WITH NAME    cap
Library    taf.ul.messaging.mtk    WITH NAME    mtk
Library    robot.libraries.DateTime
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/python/csvanalyzer.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

*** Variables ***
${10870_logpath}    ${OUTPUT DIR}/CB010870
${host_addr}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${mrbts_id}    ${tl.gnbs[0].instance_id}
${nrbts_id}    ${tl.gnbs[0].global_bts_id}
${f}    /home/ute/
${apn0}    mdrb.nokia.com
${apn1}    wap2.nokia.com
${dlport}    ${tl.appserver.iperf_details.port}
${iperf_gbr_port}    ${tl.appserver.iperf_details.port}
${apn_mdrb_nokia}    ${tl.core.pdns[1].apn}
${gbr_appserver}     ${tl.appserver.iperf_details.network_interface_address}

${default_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00.xml
${TDD_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00_TDD.xml
${CA_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00_CA.xml

${pa_ip}    ${tl.attenuator.ip_addr}
${pa_port}    ${tl.attenuator.port}
${appserver_addr}                    ${tl.appserver.iperf_details.ssh_connection_details.addr}
${appserver_username}                ${tl.appserver.iperf_details.ssh_connection_details.username}
${appserver_password}                ${tl.appserver.iperf_details.ssh_connection_details.password}

@{CA_PA_value}    ${25.0}    ${25.0}   ${20.0}    ${25.0}
@{TDD_PA_value}    ${127.0}    ${127.0}   ${127.0}    ${127.0}
@{new_fault_ids}    ${61644}    ${7307}    ${7311}
${if_commissioning}    False

*** Keywords ***
CB010870_Suite_Setup
    SISO Coam Suite Setup
    Run     mkdir ${10870_logpath}
    ${cell_list}    Create List    50
    Set Suite Variable    ${cell_list}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=1
    Set Suite Variable    ${ue_type}
    FOR    ${id}    IN    @{new_fault_ids}
        ${dict}=    Create Dictionary    faultId=${id}
        Append To List    ${ALLOWED_FAULT}    ${dict}
    END
    Set Suite Variable     ${ALLOWED_FAULT}
    #Mcshark of bookworm preparation for bip analysis

CB010870_Suite_Teardown
    SISO Coam Suite Teardown

case_common_setup
    SISO Coam Test Setup    allowed_faults_ids=61644,7307,7311

case_common_teardown
    SISO Coam Test Teardown

Set PA value
    [arguments]    ${modify_list}      ${port_num}      ${vender}=HBTE
    attenuator.setup_attenuator    attenuator=${tl.attenuator[2]}    alias=${vender}
    FOR      ${n}      IN RANGE      ${port_num}
          attenuator.set_attenuation
          ...      port=${tl.gnbs[0].dus[0].rus[4].attenuation_ports[${n}]}
          ...      value=${${modify_list}[${n}]}
          ...      attenuator_device=${vender}
    END

Perform and Check Vonr Call
    [Arguments]    ${mo_ueindex}=0    ${mt_ueindex}=7    ${callnumber}=+8613100008833    ${duration}=180
    ${CallMSNO}    Evaluate    ${mt_ueindex}+1
    spark.Update_test_plan  ue_alias=UE_${mo_ueindex}    call_type=2
    ...    CallMSNO=${CallMSNO}    CallNumber=${callnumber}    Duration=${duration}
    sleep    3s
    spark.Update_test_plan_callmt  ue_alias=UE_${mt_ueindex}
    sleep    5s
    spark.Start_test_plan  ue_alias=UE_${mo_ueindex}    task_name=CallMO
    sleep    2s
    spark.Start_test_plan  ue_alias=UE_${mt_ueindex}    task_name=CallMT
    sleep    10s
    #${Vonr_call_status}    Run Keyword And Continue On Failure   spark.get_Vonr_call_status_on_ue
    #...      ue_alias=UE_${mo_ueindex}   param={"LastEventIndex":0}
    #run keyword if    '${Vonr_call_status}'=='True'    sleep    10s
    #...    ELSE  Fail    VONR call failed

Check CA activated via rrc log
    [Arguments]    ${rrclog}    ${scellid}
    ${scellIdvalue}    Get filed value by xpath with filter
    ...    pcap=${rrclog}
    ...    filter=nr-rrc.sCellToAddModList
    ...    xpath=.//nr-rrc.sCellToAddModList//nr-rrc.SCellConfig_element/nr-rrc.sCellConfigCommon_element/nr-rrc.physCellId
    should contain    ${scellIdvalue}    ${scellid}

MultiUE Get dl tput on spark with 2CC CA
    [Arguments]    ${ue_list}
    ${dltput}        Create Dictionary
    ${dltput_pcell_parm}    Create List    NR MAC Thr. DL PCell
    ${dltput_scell_parm}    Create List    NR MAC Thr. DL SCell1
    FOR    ${ue_index}    IN    @{ue_list}
        ${dltput_pcell}    spark.get_parm_value_on_ue    param=${dltput_pcell_parm}    ue_alias=UE_${ue_index}
        ${dltput_scell}    spark.get_parm_value_on_ue    param=${dltput_scell_parm}    ue_alias=UE_${ue_index}
        ${dltput_pcell_scell}    Combine Lists    ${dltput_pcell}    ${dltput_scell}
        Set To Dictionary       ${dltput}     ${ue_index}=${dltput_pcell_scell}
        sleep    2s
    END
    log to console    dl tput is: ${dltput}
    [Return]    ${dltput}

MultiUE Check dl tput with 2CC CA
    [Arguments]    ${ue_list}    ${dltput}    ${ues_exp}
    FOR    ${ue_index}    IN    @{ue_list}
        should be true    ${dltput}[${ue_index}][0]>=${ues_exp}[${ue_index}][0]
        should be true    ${dltput}[${ue_index}][1]>=${ues_exp}[${ue_index}][1]
    END

Get filed value by xpath with filter
    [Arguments]    ${pcap}    ${filter}    ${xpath}    ${attribute_name}=show
    ${all_packets}=    cap.load_pcap_file    pcap_file=${pcap}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter}
    ${values}    cap.get_field_value_by_xpath    xpath=${xpath}    attribute_name=${attribute_name}
    log to console    ${xpath} value is: ${values}
    [Return]    ${values}

MultiUE L3 call DLUL and check throughput
    [Arguments]    ${ue_list}    ${apn}    ${ues_dltput}    ${ues_ultput}    ${ues_dlexp}    ${ues_ulexp}    ${get_spark_license}=false
    MultiUE Prepare    ue_list=${ue_list}    get_spark_license=${get_spark_license}
    sleep    20s
    MultiUE Attach    ue_list=${ue_list}
    sleep    20s
    MultiUE Start dlul traffic    ue_list=${ue_list}    apn=${apn}    ues_dltput=${ues_dltput}    ues_ultput=${ues_ultput}
    sleep    20s
    ${status}    ${error_msg}=    Run Keyword And Ignore Error    MultiUE Check throughput    ue_list=${ue_list}
    ...    ues_dlexp=${ues_dlexp}    ues_ulexp=${ues_ulexp}
    Run Keyword If    '${status}' == 'FAIL'    MultiUE Check throughput    ue_list=${ue_list}    ues_dlexp=${ues_dlexp}    ues_ulexp=${ues_ulexp}

MultiUE Prepare
    [Arguments]    ${ue_list}    ${get_spark_license}=false
    FOR    ${ue_index}    IN    @{ue_list}
        power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}     power_reset=true    get_spark_license=${get_spark_license}
        sleep    5s
    END
    log to console      UE ${ue_list} prepare

MultiUE Attach
    [Arguments]    ${ue_list}
    FOR    ${ue_index}    IN    @{ue_list}
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
        ...    attach_mode=5G_SA    power_reset=true
        sleep    10s
        spark verify attach and retry if attach failed   5Grach_ed=${5Grach_ed_0}    ue_index=${ue_index}    retry_times=3
        sleep    3s
    END
    log to console      UE ${ue_list} attach

MultiUE Detach
    [Arguments]    ${ue_list}
    FOR    ${ue_index}    IN    @{ue_list}
        power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}    power_reset=true
        sleep    5s
    END
    log to console      UE ${ue_list} detach

spark verify attach and retry if attach failed
    [Arguments]    ${5Grach_ed}    ${ue_index}    ${retry_times}
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed}    4G_check=False
    FOR    ${times}    IN RANGE    ${retry_times}
        ${status}    ${ue_ip}    run keyword and ignore error
        ...    spark.get_ue_ip_on_ue    ue_alias=UE_${ue_index}    ue_mode=MultiUE_SA
        ${ue_ip_valid}    Run Keyword And Return Status    should not be equal    ${ue_ip}    0.0.0.0
        Run Keyword If    '${status}'!='PASS' or '${ue_ip_valid}'!='True'    ue_recovery    ue_index=${ue_index}
        ...   ELSE   Exit For Loop
    END
    Run Keyword If    '${status}' == 'PASS'    log to console      ue ${ue_index} attach success and get ip: ${ue_ip}
    ...   ELSE   log to console      ue ${ue_index} attach failed for ${retry_times} times

ue_recovery
    [Arguments]    ${ue_index}
    log to console      ue ${ue_index} attach failed, try to recovery
	spark.send_at_command_on_ue    command=AT+CFUN=1,1    ue_alias=UE_${ue_index}
	sleep    120s
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}    power_reset=true
    sleep    60s
    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    ...    attach_mode=5G_SA    power_reset=true
    sleep    30s

MultiUE Start dlul traffic
    [Arguments]    ${ue_list}    ${apn}    ${ues_dltput}    ${ues_ultput}
    FOR    ${ue_index}    IN    @{ue_list}
        Run Keyword If   '${ues_dltput}[${ue_index}]'!='0MKbits/sec'    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}
        ...    direction=dl    throughput=${ues_dltput}[${ue_index}]    protocol=udp    duration=1200    apn_address=${apn}    ue_mode=MultiUE_SA
        ...    process_num=2
        sleep    20s
        Run Keyword If   '${ues_ultput}[${ue_index}]'!='0MKbits/sec'    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}
        ...    direction=ul    throughput=${ues_ultput}[${ue_index}]    protocol=udp    duration=1200    apn_address=${apn}    ue_mode=MultiUE_SA
        sleep    1s
    END
    log to console      UE ${ue_list} start dlul traffic

MultiUE Check throughput
    [Arguments]    ${ue_list}    ${ues_dlexp}    ${ues_ulexp}    ${cells}=${cell_list}    ${actCarrierAggregation}=${False}
    FOR    ${ue_index}    IN    @{ue_list}
        ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=10s    ue_index=${ue_index}
        ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${cells}    ue_index=${ue_index}
        ...    ultarget_throughput=${ues_ulexp}[${ue_index}]    dltarget_throughput=${ues_dlexp}[${ue_index}]
        ...    actCarrierAggregation=${actCarrierAggregation}
        sleep    1s
    END
    log to console      UE ${ue_list} check throughput

MultiUE Stop traffic
    [Arguments]    ${ue_list}    ${apn}
    FOR    ${ue_index}    IN    @{ue_list}
        UE Stop dl traffic    ue_index=${ue_index}    apn=${apn}
        sleep    1s
        UE Stop ul traffic    ue_index=${ue_index}    apn=${apn}
        sleep    1s
    END
    log to console      UE ${ue_list} stop traffic

g30_configuration_prepare
    ${cells}    Create List    1    2
    Du login page via webUI
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...    abbr=actSliceAwareScheduler
    ...    new_value=true
    ...    filter_param=Activate slice aware scheduler in DL
    sleep    3s
    FOR    ${cellid}    IN    @{cells}
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellid}
        ...    abbr=actRat1Alloc
        ...    new_value=true
        ...    filter_param=Activate FD resource allocation type1
        sleep    1s
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellid}
        ...    abbr=nrResourceGroupProfileDN
        ...    new_value=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRRESOURCEGROUP_PROFILE-1
        ...    filter_param=New Radio Resource Group Profile distinguished name in DL
        sleep    3s
    END
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    10s
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    DU COAM selenium logout
    sleep    10s

enable_slice
    [Arguments]    ${cells}
    Du login page via webUI
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...    abbr=actSliceAwareScheduler
    ...    new_value=true
    ...    filter_param=Activate slice aware scheduler in DL
    sleep    3s
    FOR    ${cellid}    IN    @{cells}
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellid}
        ...    abbr=nrResourceGroupProfileDN
        ...    new_value=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRRESOURCEGROUP_PROFILE-1
        ...    filter_param=New Radio Resource Group Profile distinguished name in DL
        sleep    3s
    END
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    10s
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    DU COAM selenium logout
    sleep    60s

disable_slice
    [Arguments]    ${cells}
    Du login page via webUI
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...    abbr=actSliceAwareScheduler
    ...    new_value=false
    ...    filter_param=Activate slice aware scheduler in DL
    sleep    3s
    FOR    ${cellid}    IN    @{cells}
        selenium_coam.delete_parameter    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellid}
        ...    filter_param=New Radio Resource Group Profile distinguished name in DL
        ...    abbr=nrResourceGroupProfileDN
        ...    timeout=${10}
        sleep    3s
    END
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    10s
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    DU COAM selenium logout
    sleep    10s

enable_prb_pooling
    Du login page via webUI
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...    abbr=actSlowPrbPooling
    ...    new_value=true
    ...    filter_param=Activate slow PRB pooling
    sleep    3s
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRDU-1
    ...    abbr=flexibleCAMode
    ...    new_value=NumberCellAmount
    ...    filter_param=Flexible 5G FR1 carrier aggregation mode
    sleep    3s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=${600}
    sleep    5s
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    DU COAM selenium logout
    sleep    60s

disable_prb_pooling
    Du login page via webUI
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...    abbr=actSlowPrbPooling
    ...    new_value=false
    ...    filter_param=Activate slow PRB pooling
    sleep    3s
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRDU-1
    ...    abbr=flexibleCAMode
    ...    new_value=BasicCAMode
    ...    filter_param=Flexible 5G FR1 carrier aggregation mode
    sleep    3s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=${600}
    sleep    5s
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    DU COAM selenium logout
    sleep    10s

enable_prb_blanking
    Du login page via webUI
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-1
    ...    abbr=actPRBBlanking
    ...    new_value=true
    ...    filter_param=Activate PRB blanking
    sleep    2s
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-1
    ...    abbr=nbrOfBlankedPRBsHighEdgeDL
    ...    new_value=4
    ...    filter_param=Number of blanked PRBs in high edge of downlink side
    sleep    2s
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-1
    ...    abbr=nbrOfBlankedPRBsLowEdgeDL
    ...    new_value=4
    ...    filter_param=Number of blanked PRBs in low edge of downlink side
    sleep    3s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    5s
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    DU COAM selenium logout
    sleep    60s

disable_prb_blanking
    Du login page via webUI
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-1
    ...    abbr=actPRBBlanking
    ...    new_value=false
    ...    filter_param=Activate PRB blanking
    sleep    2s
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-1
    ...    abbr=nbrOfBlankedPRBsHighEdgeDL
    ...    new_value=0
    ...    filter_param=Number of blanked PRBs in high edge of downlink side
    sleep    2s
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-1
    ...    abbr=nbrOfBlankedPRBsLowEdgeDL
    ...    new_value=0
    ...    filter_param=Number of blanked PRBs in low edge of downlink side
    sleep    3s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    5s
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    DU COAM selenium logout
    sleep    10s

update_scf
    [Arguments]    ${scfpath}
    log to console    update scf
    Restore DU SCF with timeout    source_SCF_path=${scfpath}
    Wait until keyword succeeds    10 min    30 sec
    ...    Du login page via webUI with timeout
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    Run Keyword And Ignore Error    Close DU start up window    60
    DU COAM selenium logout
    log to console    cell on air after commission
    sleep    150s

Check Rat1 activited
    [Arguments]    ${bip_csv}
    ${result1}=    Run
    ...    awk 'BEGIN{FS=","}{if($NF~"DlData_PdschSendReq")print $5}' ${bip_csv}
    ${rat0Bitmap_list}    Split String    string=${result1}    separator=\n
    FOR    ${rat0Bitmap}    IN    @{rat0Bitmap_list}
        should be equal    ${rat0Bitmap}    0
    END
    ${result2}=    Run
    ...    awk 'BEGIN{FS=","}{if($NF~"DlData_PdcchSendReq")print $NF}' ${bip_csv}
    ${dci_list}    Split String    string=${result2}    separator=\n
    FOR    ${dci}    IN    @{dci_list}
        should contain    ${dci}    DCI_1_1
    END


is_pdsch_line_needed
    [Arguments]    ${line}    ${sfn_pdcch}    ${slot_pdcch}
    ${sfn}    ${slot}    ${pdsch}    set variable    ${line}[1]    ${line}[2]    ${line}[-1]
    ${is_pdsch}    Run Keyword And Return Status    should contain    ${pdsch}    DlData_PdschSendReq
    ${is_pdsch_needed}    set variable if
    ...    ${is_pdsch} and ${sfn}==${sfn_pdcch} and ${slot}==${slot_pdcch}    True    False
    [Return]    ${is_pdsch_needed}

Check largest PDSCH sub area used with DCI_1_0
    [Arguments]    ${bip_files}    ${dci10}=DCI_1_0 - SI_RNTI    ${prefix}=largestsubarea
    ...    ${filter}=dldata_pdschsendreq || (3gpp.rnti == 65535 && DlData_DciInfo.dciSize == 48)
   ${field_list}    Create List    DlData_PdschGrant.startPrb    DlData_PdschGrant.numOfPrb
    ${bip_csv}    Decode bip log to csv file with filter
    ...    bip_list=${bip_files}
    ...    filter=${filter}
    ...    field_list=${field_list}
    ...    prefix=${prefix}
    ${result1}=    Run
    ...    grep -B 10 "${dci10}.*DCI_1_1" ${bip_csv} | tail -10
    ${line_list}    Split String    string=${result1}    separator=\n
    ${pdcch}    Split String    string=${line_list}[-1]    separator=,
    ${sfn_pdcch}    ${slot_pdcch}    ${rnti_pdcch}    set variable    ${pdcch}[1]    ${pdcch}[2]    ${pdcch}[3]
    log to console    sfn: ${sfn_pdcch}, slot: ${slot_pdcch}, rnti: ${rnti_pdcch}

    Reverse List    ${line_list}
    FOR    ${line_info}    IN    @{line_list}
        ${line}    Split String    string=${line_info}    separator=,
        ${is_pdsch_needed}    is_pdsch_line_needed    line=${line}    sfn_pdcch=${sfn_pdcch}    slot_pdcch=${slot_pdcch}
        ${is_dci10_pdsch}    set variable if    ${is_pdsch_needed} and ${line}[3]==${rnti_pdcch}    True    False
        ${dci10_startprb}    set variable if    ${is_dci10_pdsch}    ${line}[4]
        ${dci10_numofprb}    set variable if    ${is_dci10_pdsch}    ${line}[5]
        Exit For Loop If    ${is_dci10_pdsch}
    END

    ${dci10_endprb}    evaluate    ${dci10_startprb}+${dci10_numofprb}
    ${result}    Evaluate    (106-${dci10_endprb})<${dci10_startprb}
    ${largest_area_start}    set variable if    ${result}    0    ${dci10_endprb}
    ${largest_area_end}    set variable if    ${result}    ${dci10_startprb}    106
    log to console    largest PDSCH subarea: prb_start: ${largest_area_start}, prb_end: ${largest_area_end}

    FOR    ${line_info}    IN    @{line_list}
        ${line}    Split String    string=${line_info}    separator=,
        ${is_pdsch_needed}    is_pdsch_line_needed    line=${line}    sfn_pdcch=${sfn_pdcch}    slot_pdcch=${slot_pdcch}
        ${is_dci10_pdsch}    set variable if    ${is_pdsch_needed} and ${line}[3]!=${rnti_pdcch}    True    False
        run keyword if    ${is_dci10_pdsch}
        ...    check_dci11_allocated_in_largest_area    line=${line}    begin=${largest_area_start}    end=${largest_area_end}
        Exit For Loop If    ${is_dci10_pdsch}
    END

check_dci11_allocated_in_largest_area
    [Arguments]    ${line}    ${begin}    ${end}
    ${startprb}    set variable    ${line}[4]
    ${numofprb}    set variable    ${line}[5]
    should be true    ${begin}<=${startprb}<=${end}
    should be true    ${begin}<=${startprb}+${numofprb}<=${end}

Get current sw build version
    coam.connect to    bts_host=${host_addr}
    ${sw_info}=      coam.get_sw_version     connection=default
    ${sw_list}=    Split String    string=${sw_info}    separator=_
    ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==9999
    ${sw}=    Run Keyword If    '${status}'=='True'
    ...    set variable    SBTS00_${sw_list[1]}_${sw_list[2]}_${sw_list[3]}_${sw_list[4]}
    ...    ELSE    set variable    ${sw}
    Set Suite Variable    ${sw}
    [Teardown]    coam.teardown    connection=default

Mcshark preparation for bip analysis
    Get current sw build version
    ${wget_cmd}=    Set Variable
    ...    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/${sw}/
    Run    cd ${8927_logpath};${wget_cmd}
    ${MCShark}=    Run    ls ${8927_logpath}/artifactory/wslte5g_plugins-local/MCShark/${sw}/mcshark-4.0-*buster.so
    Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan/mcshark-*buster.so
    Run    sudo mv ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan/

Start collect log by gnb tool
    [Arguments]    ${command}=./gnb_logs ${host_addr} -b
    log to console    --- start to capture log via gnb tool ---
    ${exist}    List Directory    ${f}
    OperatingSystem.Run    rm ${f}/gnb_logs-tool/gnb_logs/stop_mon.log
    OperatingSystem.Run    rm ${f}/gnb_logs-tool/gnb_logs/*.zip
    ssh.Connect To    127.0.0.1    ute    iW_K#8.ute%A10h0m0ra    alias=bsh
    ssh.Execute    chmod 777 ${f}/gnb_logs-tool/gnb_logs/gnb_logs    connection=bsh
    ssh.Send Command    cd ${f}/gnb_logs-tool/gnb_logs;${command}    connection=bsh
    ssh.Read Output Until    (Q)uit    connection=bsh

Stop collect log by gnb tool
#    Wait '${time}' for stability
    log to console    --- stop gnb tool ---
    OperatingSystem.Run    touch ${f}/gnb_logs-tool/gnb_logs/stop_mon.log
    Wait Until Keyword Succeeds    300    10    file should contain
    ...    ${f}/gnb_logs-tool/gnb_logs/tool.log    Tool finished running

Download captured log to target dir and unzip
    [Arguments]    ${target_dir}=${8927_logpath}
    OperatingSystem.Run   command=cd ${target_dir}; rm -rf BTS-*_BIP*
    ${all_bip_file_list}   Create List
    log to console    --- start to Download bip result to specific folder ---
    @{bip_files}    List Files In Directory	   ${f}/gnb_logs-tool/gnb_logs	   BTS-*_BIP.zip
    OperatingSystem.Run    mv ${f}/gnb_logs-tool/gnb_logs/*.zip ${target_dir}
    ${bip_file}    Set Variable    ${bip_files[0]}
    ${file_name}    Set Variable    ${bip_file.split('.zip')[0]}
    Run    unzip ${target_dir}/${bip_file} -d ${target_dir}
    ${specific_bip_file}    List Files In Directory    ${target_dir}/${file_name}/bip
    ...                                                *Bip*.pcap*
    ...                                                absolute=${True}
    ${all_bip_file_list}     Combine Lists     ${specific_bip_file}    ${all_bip_file_list}
    ${bipfile_num}=    get length    ${all_bip_file_list}
    log to console    all captured bip file list : ${all_bip_file_list}
    [Return]     ${all_bip_file_list}

Download CP log to target dir and unzip
    [Arguments]    ${target_dir}=${10870_logpath}
    OperatingSystem.Run   command=cd ${target_dir}; rm -rf BTS-*_m*
    log to console    --- start to Download CP log to specific folder ---
    ${cp_log_name}     OperatingSystem.Run    command=cd ${f}/gnb_logs-tool/gnb_logs && ls BTS-*_m.zip
    ${cp_log_name}    Remove String    ${cp_log_name}    \n
    log to console    ${cp_log_name}
    set test variable    ${cp_log_name}
    OperatingSystem.Run   command=unzip ${f}/gnb_logs-tool/gnb_logs/${cp_log_name} -d ${target_dir}
    ${unzip_dir}    set variable    ${cp_log_name.split(".zip")[0]}
    ${cp_log_unzip_full_path}    set variable    ${target_dir}/${unzip_dir}/CPlane_E1F1.pcap
    set test variable    ${cp_log_unzip_full_path}
    log to console    ${cp_log_unzip_full_path}
    [Return]     ${cp_log_unzip_full_path}

file should contain
    [Arguments]    ${file}    ${str}
    ${ret}    OperatingSystem.Run   cat ${file} |grep "${str}"
    should not be empty    ${ret}

Decode bip log to csv file with filter
    [Arguments]    ${bip_list}    ${filter}    ${field_list}    ${prefix}
    ${index}    Set variable    0
    ${fields}=    Set Variable
    FOR    ${column}   IN    @{field_list}
        ${fields}=    Set Variable    ${fields} -e ${column}
    END
    FOR    ${pcap_file}   IN    @{bip_list}
        ${str_index}    Convert to string    ${index}
        ${csv_file}    Set variable    ${8927_logpath}/${prefix}${str_index}.csv
        ${cmd}    catenate      tshark -r ${pcap_file} -Y "${filter}"
        ...    -T fields -e _ws.col.No. -e 3gpp.sfn -e 3gpp.slot -e 3gpp.rnti
        ...    ${fields}
        ...    -e _ws.col.Info
        ...   -E header=y -E separator=, > ${csv_file}
        Run    ${cmd}
        ${index}     Evaluate    ${index} +1
    END
    ${current_time}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    log to console    current_time: ${current_time}
    Run    cat ${8927_logpath}/${prefix}*.csv > ${8927_logpath}/${prefix}_${current_time}.csv
    ${bip_csv}    Set variable    ${8927_logpath}/${prefix}_${current_time}.csv
    log to console    bip decode to csv: ${bip_csv}
    [Return]    ${bip_csv}

Check DCI 1_0 and DCI 1_1 in the same slot
    [Arguments]    ${bip_csv}    ${dci10_filed}
    ${result1}=    Run    awk 'BEGIN{FS=","}{print $NF}' ${bip_csv}
    ${lines}    Split String    string=${result1}    separator=\n
    ${dci_check}    Set variable    False
    FOR    ${infoline}    IN   @{lines}
        ${is_dci10}    run keyword and return status    should contain    ${infoline}    ${dci10_filed}
        ${is_dci11}    run keyword and return status    should contain    ${infoline}    DCI_1_1
        ${dci_check}    set variable if    ${is_dci10} and ${is_dci11}     ${True}    ${False}
        Exit For Loop If    ${dci_check}
    END
    log to console    ${dci10_filed} and DCI_1_1 in the same slot
    [Return]    ${dci_check}

UE Stop dl traffic
    [Arguments]   ${ue_index}    ${apn}=${apn0}
    Run Keyword And Ignore Error    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}
    ...    ue_type=${ue_type}    apn_address=${apn}    ue_mode=MultiUE_SA
    sleep    3s

UE Stop ul traffic
    [Arguments]   ${ue_index}    ${apn}=${apn0}
    Run Keyword And Ignore Error    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}
    ...    ue_type=${ue_type}    apn_address=${apn}    ue_mode=MultiUE_SA
    sleep    3s

MultiUE Start GBR dl traffic
    [Arguments]    ${ue_list}    ${ues_tput}    ${apn}=${apn_mdrb_nokia}    ${iperf_port}=${iperf_gbr_port}    ${appserver}=${gbr_appserver}
    FOR    ${ue_index}    IN    @{ue_list}
        power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}
        ...    direction=dl    throughput=${ues_tput}[${ue_index}]    duration=1200    apn_address=${apn}    ue_mode=MultiUE_SA
		...    iperf_port=${iperf_port}    appserver=${appserver}
        sleep    1s
    END
    log to console      UE ${ue_list} start dl GBR traffic

MultiUE Stop GBR dl traffic
    [Arguments]    ${ue_list}    ${apn}=${apn_mdrb_nokia}    ${iperf_port}=${iperf_gbr_port}    ${appserver}=${gbr_appserver}
    FOR    ${ue_index}    IN    @{ue_list}
        Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}
        ...    direction=dl    apn_address=${apn}    ue_mode=MultiUE_SA
		...    iperf_port=${iperf_port}    appserver=${appserver}
        sleep    1s
    END
    log to console      UE ${ue_list} start dl GBR traffic

Start_BTS_Logs
    [Arguments]    ${name}=btslog     ${bts_logs_dir}=/opt/btslog    ${log_dir}=/tmp/btslog2    ${alias}=ute
	ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=${alias}
    ssh.execute  command=if [ ! -d ${log_dir} ]; then mkdir ${log_dir}; else rm ${log_dir}/*; fi    connection=${alias}
    btslog.create_btslog_collector    name=${name}    btslog_path=${bts_logs_dir}/btslog
	...    btslog_launcher_path=${bts_logs_dir}/btslog_launcher    log_dir=${log_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

Stop_BTS_Logs
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

Check_GBR_Addition_Rejected_from_BTSLOG
    [arguments]    ${log_path}=/tmp/btslog2/    ${alias}=ute
	log to console    check btslog...
	ssh.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=${alias}
    ${out}=    OperatingSystem.Run  cat ${log_path}*.LOG | grep 'F1AP UeContextSetupFailure due to'
	${result}    Get Regexp Matches    ${out}    CauseRadioNetwork::noRadioResourcesAvailable

enable_or_disable_nbr
    [Arguments]    ${attr_value}
    Du login page via webUI
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-1
    ...    abbr=actNbrForNonGbrBearers
    ...    new_value=${attr_value}
    ...    filter_param=Activate nominal bitrate for non-GBR bearers
    sleep    2s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    5s
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    DU COAM selenium logout
    sleep    10s

g16_configuration_prepare
    update_scf    scfpath=${g16_scf}
    sleep    120s
    ${ue1_ch}    Create List    1    5    9    13
    set test variable    ${ue1_ch}
    set_haojin_pa    ch_list=${ue1_ch}    value=82

set_haojin_pa
    [Arguments]    ${ch_list}    ${value}    ${pa_ip}=${pa_ip}    ${pa_port}=${pa_port}
    FOR    ${ch}    IN    @{ch_list}
        ${arg1}    create list    HJ:${pa_ip}:${pa_port}:${ch}:${value}
        run keyword and ignore error    Set Attenuation Arbitrary Values    ${arg1}
        sleep    2s
    END
    log to console    set pa value: ch_list:${ch_list} value:${value}

Check multiple PDSCH sub area used with DCI_1_0
    [Arguments]    ${bip_files}    ${dci10}=DCI_1_0 - SI_RNTI    ${prefix}=prbcheckwdci10
    ...    ${filter}=dldata_pdschsendreq || (3gpp.rnti == 65535 && DlData_DciInfo.dciSize == 48)
   ${field_list}    Create List    DlData_PdschGrant.startPrb    DlData_PdschGrant.numOfPrb
    ${bip_csv}    Decode bip log to csv file with filter
    ...    bip_list=${bip_files}
    ...    filter=${filter}
    ...    field_list=${field_list}
    ...    prefix=${prefix}
    ${result1}=    Run
    ...    grep -B 10 "${dci10}.*DCI_1_1.*DCI_1_1" ${bip_csv} | tail -10
    ${line_list}    Split String    string=${result1}    separator=\n
    ${pdcch}    Split String    string=${line_list}[-1]    separator=,
    ${sfn_pdcch}    ${slot_pdcch}    ${rnti_pdcch}    set variable    ${pdcch}[1]    ${pdcch}[2]    ${pdcch}[3]
    log to console    sfn: ${sfn_pdcch}, slot: ${slot_pdcch}, rnti: ${rnti_pdcch}

    Reverse List    ${line_list}
    FOR    ${line_info}    IN    @{line_list}
        ${line}    Split String    string=${line_info}    separator=,
        ${is_pdsch_needed}    is_pdsch_line_needed    line=${line}    sfn_pdcch=${sfn_pdcch}    slot_pdcch=${slot_pdcch}
        ${is_dci10_pdsch}    set variable if    ${is_pdsch_needed} and ${line}[3]==65535    True    False
        ${dci10_startprb}    set variable if    ${is_dci10_pdsch}    ${line}[4]
        ${dci10_numofprb}    set variable if    ${is_dci10_pdsch}    ${line}[5]
        Exit For Loop If    ${is_dci10_pdsch}
    END
    ${dci10_endprb}    evaluate    ${dci10_startprb}+${dci10_numofprb}
    log to console    dci10 PDSCH subarea: prb_start: ${dci10_startprb}, prb_end: ${dci10_endprb}

    FOR    ${line_info}    IN    @{line_list}
        ${line}    Split String    string=${line_info}    separator=,
        ${is_pdsch_needed}    is_pdsch_line_needed    line=${line}    sfn_pdcch=${sfn_pdcch}    slot_pdcch=${slot_pdcch}
        Continue For Loop If	${is_pdsch_needed}==False or ${line}[3]==65535
        ${is_dci11_pdsch}    set variable if    ${is_pdsch_needed} and ${line}[3]!=65535    True    False
        ${dci11_startprb}    set variable if    ${is_dci11_pdsch}    ${line}[4]
        ${dci11_low}    set variable if    ${dci11_startprb}<${dci10_startprb}    True    False
        run keyword if    ${dci11_low}
        ...    check_dci11_allocated_in_multiple_subarea    line=${line}
        ...    dci10_startprb=${dci10_startprb}    location=0
        Exit For Loop If    ${dci11_low}
    END

    FOR    ${line_info}    IN    @{line_list}
        ${line}    Split String    string=${line_info}    separator=,
        ${is_pdsch_needed}    is_pdsch_line_needed    line=${line}    sfn_pdcch=${sfn_pdcch}    slot_pdcch=${slot_pdcch}
        Continue For Loop If	${is_pdsch_needed}==False or ${line}[3]==65535
        ${is_dci11_pdsch}    set variable if    ${is_pdsch_needed} and ${line}[3]!=65535    True    False
        ${dci11_startprb}    set variable if    ${is_dci11_pdsch}    ${line}[4]
        ${dci11_up}    set variable if    ${dci11_startprb}>=${dci10_endprb}    True    False
        run keyword if    ${dci11_up}
        ...    check_dci11_allocated_in_multiple_subarea    line=${line}
        ...    dci10_startprb=${dci10_startprb}    location=1
        Exit For Loop If    ${dci11_up}
    END
    should be true    ${dci11_low} and ${dci11_up}

check_dci11_allocated_in_multiple_subarea
    [Arguments]    ${line}    ${dci10_startprb}    ${location}
    ${startprb}    set variable    ${line}[4]
    ${numofprb}    set variable    ${line}[5]
    run keyword if    ${location}==0    should be true    ${startprb}+${numofprb}<=${dci10_startprb}
    run keyword if    ${location}==1    should be true    ${startprb}+${numofprb}<=106
    log to console    dci10 ${location} subarea allocated

CB008927_168_Suite_Setup
    robot_common_operations.Common Suite Setup
    CI_interface.Common Suite Setup
    Run     mkdir ${8927_logpath}
    ${cell_list}    Create List    2752513
    Set Suite Variable    ${cell_list}
    Set Suite Variable    ${dynamic_ue_index}    0
    Set Suite Variable    ${legacy_ue_index}    1
    ${dynamic_ue_type}    translate_power_ue_type_from_testline    ue_index=${dynamic_ue_index}
    Set Suite Variable    ${dynamic_ue_type}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${legacy_ue_index}
    Set Suite Variable    ${ue_type}
    #Mcshark of bookworm preparation for bip analysis

Mcshark of bookworm preparation for bip analysis
    Get current sw build version
    ${wget_cmd}=    Set Variable
    ...    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/${sw}/
    Run    cd ${8927_logpath};${wget_cmd}
    ${MCShark}=    Run    ls ${8927_logpath}/artifactory/wslte5g_plugins-local/MCShark/${sw}/mcshark-4.0-*bookworm.so
    Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan/mcshark-*bookworm.so
    Run    sudo mv ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan/

check_dynamicswitch_work
    [Arguments]    ${bip_file}    ${sfn}    ${slot}    ${rnti}
    ${rat0Bitmap_list}    Get filed value by xpath with filter
    ...    pcap=${bip_file}
    ...    filter=3gpp.sfn==${sfn} && 3gpp.slot==${slot} && 3gpp.rnti==${rnti} && dldata_pdschsendreq
    ...    xpath=.//DlData_PdschGrant.rat0Bitmap
    ${is_rat0_allocated}    run keyword and return status    should be true    ${rat0Bitmap_list}[-1]!=0
    Run Keyword If  '${is_rat0_allocated}'=='True'   log to console     rat0 allocated. sfn:${sfn}, slot:${slot}, rnti:${rnti}

    ${rat0Bitmap_list_1}    run keyword if    ${is_rat0_allocated}
    ...    Get filed value by xpath with filter
    ...    pcap=${bip_file}
    ...    filter=3gpp.rnti==${rnti} && dldata_pdschsendreq
    ...    xpath=.//DlData_PdschGrant.rat0Bitmap
    ${is_rat1_allocated}    run keyword and return status    should contain    ${rat0Bitmap_list_1}    0
    ${dynamicswitch_check}    set variable if    ${is_rat0_allocated} and ${is_rat1_allocated}     ${True}    ${False}
    [Return]    ${dynamicswitch_check}

Check dynamicswitch with DCI_1_0
    [Arguments]    ${bip_files}    ${prefix}
    ${bip2check}    create list    ${bip_files}[0]
    ${field_list}    Create List    DlData_DciInfo.dciSize
    ${bip_csv}    Decode bip log to csv file with filter  bip_list=${bip2check}
    ...    filter=3gpp.rnti == 65535 && DlData_DciInfo.dciSize == 50
    ...    field_list=${field_list}
    ...    prefix=${prefix}
    ${result1}=    Run    cat ${bip_csv}
    ${line_list}    Split String    string=${result1}    separator=\n
    FOR    ${line_info}    IN    @{line_list}
        ${line}    Split String    string=${line_info}    separator=,
        ${sfn_pdcch}    ${slot_pdcch}    ${rnti_pdcch}    set variable    ${line}[1]    ${line}[2]    ${line}[4]
        log to console    pdcch sfn: ${sfn_pdcch}, slot: ${slot_pdcch}, rnti: ${rnti_pdcch}
        ${dynamicswitch_check}    check_dynamicswitch_work
        ...    bip_file=${bip_files}[0]    sfn=${sfn_pdcch}    slot=${slot_pdcch}    rnti=${rnti_pdcch}
        Exit For Loop If    ${dynamicswitch_check}
    END

    should be true    '${dynamicswitch_check}'=='True'

Du login page via webUI with timeout
    [Arguments]  ${download_dir}=/home/ute    ${timeout}=300
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    selenium_coam.disable_message_box

Restore DU SCF with timeout
    [Arguments]    ${source_SCF_path}    ${timeout}=300
    Du login page via webUI with timeout    timeout=${timeout}
    Load SCF without activation    ${source_SCF_path}
    Activate Plan
    Close DU start up window
    [Teardown]    DU COAM selenium logout

modify actDlDynSwitchAlloc online
    [Arguments]    ${attr_value}    ${timeout}=300
    log to console    modify actDlDynSwitchAlloc online: ${attr_value}
    Du login page via webUI with timeout    timeout=${timeout}
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-1
    ...    abbr=actDlDynSwitchAlloc
    ...    new_value=${attr_value}
    ...    filter_param=Activate DL dynamic switch allocation
    sleep    2s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    5s
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    DU COAM selenium logout
    sleep    10s

Check dynamicswitch activated or dedicated
    [Arguments]    ${bip_files}    ${prefix}    ${flag}
    ${bip2check}    create list    ${bip_files}[0]
    ${field_list}    Create List    DlData_PdschGrant.rat0Bitmap
    ${bip_csv}    Decode bip log to csv file with filter  bip_list=${bip2check}
    ...    filter=DlData_PdschGrant.rat0Bitmap!=0
    ...    field_list=${field_list}
    ...    prefix=${prefix}
    ${result1}=    Run    cat ${bip_csv}
    ${line_list}    Split String    string=${result1}    separator=\n
    ${list_length}   Get Length  ${line_list}
    run keyword if    '${flag}'=='true'    should be true    ${list_length}>1
    ...    ELSE    should be true    ${list_length}==1
    log to console    check dynamicswitch ${flag} ok

check_rat1_scheduled_with_rat0
    [Arguments]    ${line_list}    ${rnti_dynamic}
    FOR    ${line_info}    IN    @{line_list}
        ${line}    Split String    string=${line_info}    separator=,
        ${rnti}    set variable    ${line}[3]
        ${rat0bitmap_legacyue}    set variable if    ${rnti}!=65535 and ${rnti}!=${rnti_dynamic}    ${line}[4]    1
        run keyword if    ${rat0bitmap_legacyue}==0		log to console
        ...    legacy ue ${rnti} with rat1 and dynamic ue ${rnti_dynamic} with rat0 are scheduled at the same slot: ${line}[2]
        Exit For Loop If    ${rat0bitmap_legacyue}==0
    END
    [Return]    ${rat0bitmap_legacyue}

Check rat0 and rat1 scheduled in the same slot
    [Arguments]    ${bip_files}    ${prefix}
    ${bip2check}    create list    ${bip_files}[0]
    ${field_list}    Create List    DlData_PdschGrant.rat0Bitmap
    ${bip_csv}    Decode bip log to csv file with filter  bip_list=${bip2check}
    ...    filter=DlData_PdschGrant.rat0Bitmap!=0
    ...    field_list=${field_list}
    ...    prefix=${prefix}
    ${result1}=    Run    cat ${bip_csv}
    ${line_list}    Split String    string=${result1}    separator=\n
    ${line_to_remove}     set variable    ${line_list}[0]
    Remove Values From List    ${line_list}    ${line_to_remove}
    ${dynamic_line}    Split String    string=${line_list}[-1]    separator=,
    ${rnti_dynamic}    set variable    ${dynamic_line}[3]
    log to console    dynamic switch ue rnti: ${rnti_dynamic}
    ${dynamicswith_sfn_slot}    Create Dictionary
    FOR    ${line_info}    IN    @{line_list}
        ${line}    Split String    string=${line_info}    separator=,
        Set To Dictionary    ${dynamicswith_sfn_slot}    ${line}[1]    ${line}[2]
    END

    FOR   ${sfn_dynamic}  IN  @{dynamicswith_sfn_slot.keys()}
        ${slot_dynamic}    set variable     ${dynamicswith_sfn_slot['${sfn_dynamic}']}
        log to console    sfn_dynamic: ${sfn_dynamic}, slot_dynamic: ${slot_dynamic}
        ${bip_csv_new}    Decode bip log to csv file with filter  bip_list=${bip2check}
        ...    filter=3gpp.sfn==${sfn_dynamic}&&3gpp.slot==${slot_dynamic}&&dldata_pdschsendreq
        ...    field_list=${field_list}
        ...    prefix=dynamic
        ${result2}=    Run    cat ${bip_csv_new}
        ${line_list2}    Split String    string=${result2}    separator=\n
        Remove From List    ${line_list2}    index=0
        ${rat0bitmap_legacyue}    check_rat1_scheduled_with_rat0    line_list=${line_list2}    rnti_dynamic=${rnti_dynamic}
        Exit For Loop If    ${rat0bitmap_legacyue}==0
    END
    should be true    ${rat0bitmap_legacyue}==0


Download captured tti to target dir and unzip
    [Arguments]    ${target_dir}=${8927_logpath}
    OperatingSystem.Run   command=cd ${target_dir}; rm -rf BTS-*_TTI*
    ${all_tti_file_list}   Create List
    log to console    --- start to Download tti result to specific folder ---
    @{tti_files}    List Files In Directory	   ${f}/gnb_logs-tool/gnb_logs	   BTS-*_TTI.zip
    OperatingSystem.Run    mv ${f}/gnb_logs-tool/gnb_logs/*.zip ${target_dir}
    ${tti_file}    Set Variable    ${tti_files[0]}
    ${file_name}    Set Variable    ${tti_file.split('.zip')[0]}
    Run    unzip ${target_dir}/${tti_file} -d ${target_dir}
    ${specific_tti_file}    List Files In Directory    ${target_dir}/${file_name}/tti/1518_ttiTrace/
    ...                                                *dl__all.csv*
    ...                                                absolute=${True}
    ${all_tti_file_list}     Combine Lists     ${specific_tti_file}    ${all_tti_file_list}
    ${ttifile_num}=    get length    ${all_tti_file_list}
    log to console    all captured tti file list : ${all_tti_file_list}
    [Return]     ${all_tti_file_list}

check_allprb_used
    [Arguments]    ${prbcount}    ${prbnums_mcs}
    ${prbused}    set variable    0
    FOR    ${prbnum_mcs_line}    IN    @{prbnums_mcs}
	    ${prbnum_mcs}=    Split String    string=${prbnum_mcs_line}    separator=${SPACE}
		${retx}    set variable if    ${prbnum_mcs}[1]>27    True    False
		exit for loop if   ${retx}
	    ${prbused}=    Evaluate    ${prbused}+${prbnum_mcs}[0]
    END
	${status}    run keyword if    '${retx}'!='True'    Run Keyword And Return Status    should be equal    ${prbcount}    ${prbused}
	...    ELSE    set variable    True
    [Return]    ${status}    ${prbused}

Check all prb are used in slot
    [Arguments]    ${bip_file}    ${prb_count}    ${slot_filter}    ${prefix}
    ${field_list}    Create List    DlData_PdschGrant.startPrb    DlData_PdschGrant.numOfPrb    DlData_PdschGrant.mcs
    ${bip_files}    Create List    ${bip_file}
    ${bip_csv}    Decode bip log to csv file with filter
    ...    bip_list=${bip_files}
    ...    filter=${slot_filter}&&((dldata_pdschsendreq&&3gpp.rnti!=65535)||(DlData_DciInfo.dciSize==48&&DlData_DciInfo.dciSize!=39))
    ...    field_list=${field_list}
    ...    prefix=${prefix}
    ${result1}=    Run     awk 'BEGIN{FS=","}{if($NF~"DlData_PdcchSendReq")print $2, $3}' ${bip_csv}
    ${lines1}    Split String    string=${result1}    separator=\n
    ${lines}    Get Slice From List    ${lines1}    start=1    end=-1
    ${errorcount}    set variable    0
    FOR    ${line}    IN    @{lines}
	    ${sfn_slot}=    Split String    string=${line}    separator=${SPACE}
	    ${prbsline}=    Run     awk 'BEGIN{FS=","}{if($2==${sfn_slot}[0]&&$3==${sfn_slot}[1]&&$NF~"DlData_PdschSendReq")print $6, $7}' ${bip_csv}
	    ${prbnums_mcs}    Split String    string=${prbsline}    separator=\n
	    ${status}    ${prbused}    check_allprb_used    prbcount=${prb_count}    prbnums_mcs=${prbnums_mcs}
	    run keyword if    '${status}'!='True'
	    ...    log to console    PRB not fully used with sfn: ${sfn_slot}[0], slot: ${sfn_slot}[1], prbcount: ${prb_count}, prbused: ${prbused}
	    ${errorcount}    run keyword if    '${status}'!='True'    Evaluate    ${errorcount}+1
	    ...		ELSE    Evaluate    ${errorcount}+0
    END
    log to console    error occurs when check all prb used: ${errorcount} times
    [Return]    ${errorcount}

get_time_ota_message
    [Arguments]    ${ota_message}
    ${ota_message_item}=    Split String    string=${ota_message}    separator=${SPACE}
    ${message_time}    Catenate    ${ota_message_item}[0]    ${ota_message_item}[1]
    ${message_epoch}    DateTime.Convert Date    date=${message_time}    result_format=epoch
    [Return]    ${message_epoch}

check_ota_message_mtk
    [Arguments]    ${ue_index}    ${msg}    ${start}
    ${start_epoch}    DateTime.Convert Date    date=${start}    result_format=epoch
    mtk.Setup    pyro_ip=${tl.ues[${ue_index}].ssh_connection_details.addr}    pyro_port=${tl.ues[${ue_index}].server_port}
    mtk.create_message_flow_alias    flow_alias=MTK_OTA_MESSAGE    message_type=ota_text
    ${result}    mtk.get_latest_messages_in_flow    flow_alias=MTK_OTA_MESSAGE
    FOR    ${item}    IN    @{result}
        ${flag}    Evaluate    ${msg} in """${item}"""
        ${message_epoch}    run keyword if    ${flag}    get_time_ota_message    ota_message=${item}
        ${message_check}    run keyword if    ${flag}    run keyword and return status    should be true    ${message_epoch}>=${start_epoch}
        run keyword if    ${message_check}    log to console    message check pass: ${item}
        exit for loop if   ${message_check}
    END
    Run Keyword If  '${message_check}'!='True'   log to console     message check failed: ${msg}
    run keyword and ignore error    should be true   ${message_check}

MTP attach and verify
    [Arguments]    ${ue_index}    ${ue_type}    ${apn}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}
    sleep    5s
    ${status}    ${ue_ip}    run keyword and ignore error
    ...    spark.create_pdu_session    ue_alias=UE_${ue_index}    id=1    apn=${apn}
    ${ue_ip_valid}    Run Keyword And Return Status    should not be equal    ${ue_ip}    0.0.0.0
    Run Keyword If    '${status}'!='PASS' or '${ue_ip_valid}'!='True'
    ...    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    power_reset=true
    [Return]    ${ue_ip}

Check rrc state
    [Arguments]    ${status}    ${ue_index}
    ${rrc_state}    Get rrc state on spark    ue_alias=UE_${ue_index}
    Should Contain    ${rrc_state}[0]    ${status}

Get rrc state on spark
    [Arguments]    ${ue_alias}
    ${param}     create list    RRC Status
    ${value}    spark.get_parm_value_on_ue    param=${param}    ue_alias=${ue_alias}
    [Return]    ${value}

trigger_rrcreconfiguration_via_ping
    [Arguments]    ${ue_ip}    ${timeout}=60 s
    Connect to APPserver    alias=APPserver
    ${cmd_ping_to_ue}    Set variable    ping -c 3 ${ue_ip}
    ${output_ping_to_ue}  ssh.execute  ${cmd_ping_to_ue}  connection=APPserver  timeout=${timeout}
    run keyword and ignore error    Should Contain    ${output_ping_to_ue}    rrt
    ssh.disconnect    connection=APPserver
    #${rrcreconfig_check}    Run Keyword And Return Status
    #...    wait until keyword succeeds    1min    1s    Check rrc state    status=Connected    ue_index=${ue_index}
    #log to console     rrc reconfig check: ${rrcreconfig_check}
    #run keyword and ignore error    should be true   ${rrcreconfig_check}

check_type3_startprb_in_coreset0
    [Arguments]    ${type3_startprbs}    ${coreset0start}    ${coreset0end}
    FOR    ${type3_startprb}    IN    @{type3_startprbs}
        should be true    ${coreset0start}<=${type3_startprb}<=${coreset0end}
    END

modify gscn online
    [Arguments]    ${attr_value}    ${timeout}=300
    log to console    modify gscn online: ${attr_value}
    Du login page via webUI with timeout    timeout=${timeout}
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-1
    ...    abbr=gscnOrSsPbchArfcn
    ...    new_value=${attr_value}
    ...    filter_param=Synchronization channel number
    sleep    2s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    5s
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    DU COAM selenium logout
    sleep    10s

Check prb allocation iwk 12669
    [Arguments]    ${bip_files}    ${prioritizedprb}    ${ssbend}    ${prefix}
    log to console    \ncheck prb allocation iwk 12669
    ${field_list}    Create List    DlData_PdschGrant.startPrb    DlData_PdschGrant.numOfPrb
    ${bip_csv}    Decode bip log to csv file with filter
    ...    bip_list=${bip_files}
    ...    filter=dldata_pdschsendreq
    ...    field_list=${field_list}
    ...    prefix=${prefix}
    ${result1}=    Run    cat ${bip_csv}
    ${line_list}    Split String    string=${result1}    separator=\n
    Remove From List    ${line_list}    index=0
    FOR    ${line_info}    IN    @{line_list}
        ${line}    Split String    string=${line_info}    separator=,
        ${sfn}    ${slot}    ${rnti}    ${startprb}    ${numofprb}
        ...		set variable    ${line}[1]    ${line}[2]    ${line}[3]    ${line}[4]    ${line}[5]
        ${status0}    run keyword and return status    should be true    ${rnti}==65535 or ${startprb}==0
        Continue For Loop If	${status0}==True
        ${status1}    check_prballocated_inpriority
        ...		startprb=${startprb}    numofprb=${numofprb}    prioritizedprb=${prioritizedprb}
        Continue For Loop If	${status1}==True
        ${subareaexist}    check_if_subareaexist    sfn=${sfn}    slot=${slot}    bip_csv=${bip_csv}
        ${status2}
        ...	   Run Keyword If    '${subareaexist}'=='True'    check_prballocated_frombottomofsubarea
        ...    sfn=${sfn}    slot=${slot}    rnti=${rnti}    startprb=${startprb}    bip_csv=${bip_csv}
        ...    ELSE IF    ${sfn}%2==0 and ${slot}==0	   check_ssbslot_prbuse
        ...	   sfn=${sfn}    slot=${slot}    rnti=${rnti}    startprb=${startprb}    ssbend=${ssbend}    bip_csv=${bip_csv}
        ...    ELSE    check_prballocated_frombottomofregion
        ...	   sfn=${sfn}    slot=${slot}    rnti=${rnti}    startprb=${startprb}    regionstart=0    bip_csv=${bip_csv}
        should be true    ${status2}
    END

check_prballocated_inpriority
    [Arguments]    ${startprb}    ${numofprb}    ${prioritizedprb}
    ${status}    run keyword and return status    should be true    ${startprb}+${numofprb}<=${prioritizedprb}
    [Return]    ${status}

check_if_subareaexist
    [Arguments]    ${sfn}    ${slot}    ${bip_csv}
    ${result}=    Run     awk 'BEGIN{FS=","}{if($2==${sfn}&&$3==${slot}&&$4==65535)print $5, $6}' ${bip_csv}
    ${subareaexist}    run keyword and return status    Should Not Be Empty    ${result}
    [Return]    ${subareaexist}

check_prballocated_frombottomofsubarea
    [Arguments]    ${sfn}    ${slot}    ${rnti}    ${startprb}    ${bip_csv}
    ${result}=    Run     awk 'BEGIN{FS=","}{if($2==${sfn}&&$3==${slot}&&$4==65535)print $5, $6}' ${bip_csv}
    ${lines}    Split String    string=${result}    separator=\n
    ${subareaend}    set variable    0
    FOR    ${line}    IN    @{lines}
        ${prb_start_num}=    Split String    string=${line}    separator=${SPACE}
        ${start}    set variable    ${prb_start_num}[0]
        ${end}    Evaluate    ${prb_start_num}[0]+${prb_start_num}[1]
        ${subareaend}    run keyword if    ${end}>${subareaend}    set variable   ${end}
    END
    ${status}    run keyword if    ${startprb}==${subareaend}    set variable    True
    ...    ELSE    check_multiueinsubarea
    ...    sfn=${sfn}    slot=${slot}    rnti=${rnti}    subareaend=${subareaend}    startprb=${startprb}    bip_csv=${bip_csv}
    [Return]    ${status}

check_multiueinsubarea
    [Arguments]    ${sfn}    ${slot}    ${rnti}    ${startprb}    ${subareaend}    ${bip_csv}
    ${result1}=    Run    awk 'BEGIN{FS=","}{if($2==${sfn}&&$3==${slot}&&$4!=65535&&$4!=${rnti})print $5, $6}' ${bip_csv}
    ${lines1}    Split String    string=${result1}    separator=\n
    FOR    ${line}    IN    @{lines1}
        ${prb_start_num}=    Split String    string=${line}    separator=${SPACE}
        ${start}    set variable    ${prb_start_num}[0]
        ${end}    Evaluate    ${prb_start_num}[0]+${prb_start_num}[1]
        ${status}    run keyword and return status    should be true    ${start}==${subareaend} and ${startprb}==${end}
        Exit For Loop If    '${status}'=='True'
    END
    [Return]    ${status}

check_prballocated_frombottomofregion
    [Arguments]    ${sfn}    ${slot}    ${rnti}    ${startprb}    ${regionstart}    ${bip_csv}
    ${result}=    Run     awk 'BEGIN{FS=","}{if($2==${sfn}&&$3==${slot}&&$4!=${rnti})print $5, $6}' ${bip_csv}
    ${lines}    Split String    string=${result}    separator=\n
    FOR    ${line}    IN    @{lines}
        ${prb_start_num}=    Split String    string=${line}    separator=${SPACE}
        ${start}    ${num}    set variable    ${prb_start_num}[0]    ${prb_start_num}[1]
        ${status}    run keyword and return status    should be true    ${start}==${regionstart} and ${startprb}==${start}+${num}
        Exit For Loop If    '${status}'=='True'
    END
    [Return]    ${status}

check_ssbslot_prbuse
    [Arguments]    ${sfn}    ${slot}    ${rnti}    ${startprb}    ${ssbend}    ${bip_csv}
    ${status}    run keyword if    ${startprb}==${ssbend}    set variable    True
    ...    ELSE    check_prballocated_frombottomofregion
    ...	   sfn=${sfn}    slot=${slot}    rnti=${rnti}    startprb=${startprb}    regionstart=${ssbend}    bip_csv=${bip_csv}
    [Return]    ${status}

config_h27_parameters_online
    [Arguments]    ${attr_value}    ${timeout}=300
    log to console    modify gscn online: ${attr_value}
    Du login page via webUI with timeout    timeout=${timeout}
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-1
    ...    abbr=gscnOrSsPbchArfcn
    ...    new_value=${attr_value}
    ...    filter_param=Synchronization channel number
    sleep    3s
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...    abbr=actSliceAwareScheduler
    ...    new_value=true
    ...    filter_param=Activate slice aware scheduler in DL
    sleep    3s
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    ...    abbr=nrResourceGroupProfileDN
    ...    new_value=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRRESOURCEGROUP_PROFILE-1
    ...    filter_param=New Radio Resource Group Profile distinguished name in DL
    sleep    3s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    5s
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    DU COAM selenium logout
    sleep    10s

modify actNbrForNonGbrBearers
    [Arguments]    ${attr_value}    ${timeout}=300
    log to console    modify gscn online: ${attr_value}
    Du login page via webUI with timeout    timeout=${timeout}
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-1
    ...    abbr=actNbrForNonGbrBearers
    ...    new_value=${attr_value}
    ...    filter_param=Activate nominal bitrate for non-GBR bearers
    sleep    2s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    5s
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    DU COAM selenium logout
    sleep    10s

CB008927_124_Suite_Setup
    robot_common_operations.Common Suite Setup
    CI_interface.Common Suite Setup
    Run     mkdir ${8927_logpath}
    ${cell_list}    Create List    153903105
    Set Suite Variable    ${cell_list}
    Set Suite Variable    ${dynamic_ue_index}    4
    ${dynamic_ue_type}    translate_power_ue_type_from_testline    ue_index=${dynamic_ue_index}
    Set Suite Variable    ${dynamic_ue_type}
	${ue_type}    translate_power_ue_type_from_testline    ue_index=0
    Set Suite Variable    ${ue_type}

MTPx80 start dl traffic
    [Arguments]    ${UE_IP}    ${dltput}    ${duration}=1200    ${dl_port}=${dlport}
    Start DL traffic via iperf on Appserver    dl_port=${dl_port}    process_num=1    ue_addr=${UE_IP}
    ...                                        dl_time=${duration}   dl_throughput=${dltput}    dl_length=1400B   protocol=udp
    log to console    \n... start dl udp traffic: ${dltput}

MTPx80 get UE ip
    [Arguments]     ${apn}    ${ue_index}
    ${ue_ips}    ute_ue.Get Ue Info    UE_${ue_index}    ips
    ${UE_IP}    set variable    ${ue_ips}[${apn}][0]
    log to console    \n... UE ip: ${UE_IP}
    [Return]    ${UE_IP}

MTPx80 stop dl traffic
    [Arguments]    ${port}=${dlport}
    Close the iperf process on APPserver    port=${port}
    Disconnect from app server
