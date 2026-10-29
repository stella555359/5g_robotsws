*** Settings ***
Documentation    author: Deng Xueqin
...              Group: RAN_PZ_HAZ3_SG02
...              contact: xueqin.deng@nokia-sbell.com

Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.config.scf    WITH NAME    scf
Library    taf.analyzer.pcap    WITH NAME    cap
Library    taf.ul.messaging.mtk    WITH NAME    mtk
Library    robot.libraries.DateTime
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/python/csvanalyzer.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/python/tak_pa/
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG13/robot/common_resource/common_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot

*** Variables ***
${8927_logpath}    ${OUTPUT DIR}/CB008927
${bip_log_path}    ${8927_logpath}/l1l2bip/
${bip_prefix1}    BTS*_1011_mirroring_L2L1_
${host_addr}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${mrbts_id}    ${tl.gnbs[0].instance_id}
${nrbts_id}    ${tl.gnbs[0].global_bts_id}
${f}    /home/ute/
${apn0}    ${tl.core.pdns[0].apn}
${apn1}    ${tl.core.pdns[1].apn}
${dlport}    ${tl.appserver.iperf_details.port}
${iperf_gbr_port}    ${tl.appserver.iperf_details.port}
${apn_mdrb_nokia}    ${tl.core.pdns[1].apn}
${gbr_appserver}     ${tl.appserver.iperf_details.network_interface_address}

${default_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00.xml
${g26_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_case_G26.xml
${g19_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_case_G19.xml
${g11_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_case_G11.xml
${g16_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_case_G16.xml
${k3_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_case_K3.xml
${s16_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_case_S16.xml
${wireshark_config}    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008927/Resources/Wireshark/

${pa_ip}    ${tl.attenuator.ip_addr}
${pa_port}    ${tl.attenuator.port}
${appserver_addr}                    ${tl.appserver.iperf_details.ssh_connection_details.addr}
${appserver_username}                ${tl.appserver.iperf_details.ssh_connection_details.username}
${appserver_password}                ${tl.appserver.iperf_details.ssh_connection_details.password}
*** Keywords ***
CB008927_Suite_Setup
    robot_common_operations.Common Suite Setup
    CI_interface.Common Suite Setup
    Run     mkdir ${8927_logpath}
    ${cell_list}    Create List    50
    Set Suite Variable    ${cell_list}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=0
    Set Suite Variable    ${ue_type}
    run keyword and ignore error    Download and prepare gnb_logs

CB008927_Suite_Teardown
    SISO Coam Suite Teardown

case_common_setup
    SISO Coam Test Setup

case_common_teardown
    SISO Coam Test Teardown

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

MultiUE L3 call DL and check throughput
    [Arguments]    ${ue_list}    ${apn}    ${ues_tput}    ${ues_exp}    ${get_spark_license}=false
    MultiUE Prepare    ue_list=${ue_list}    get_spark_license=${get_spark_license}
    sleep    20s
    MultiUE Attach    ue_list=${ue_list}
    sleep    20s
    MultiUE Start dl traffic    ue_list=${ue_list}    apn=${apn}    ues_tput=${ues_tput}
    sleep    15s
    MultiUE Check throughput    ue_list=${ue_list}    ues_exp=${ues_exp}

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
    log to console      ue ${ue_index} attach ${retry_times} times and get ue IP: ${ue_ip}
    should be true    ${ue_ip_valid}

ue_recovery
    [Arguments]    ${ue_index}
    log to console      ue ${ue_index} attach failed, try to recovery
	run keyword and ignore error
    ...    spark.send_at_command_on_ue    command=AT+CFUN=1,1    ue_alias=UE_${ue_index}
	sleep    120s
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}    power_reset=true
    sleep    60s
    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    ...    attach_mode=5G_SA    power_reset=true
    sleep    30s

MultiUE Start dl traffic
    [Arguments]    ${ue_list}    ${apn}    ${ues_tput}
    FOR    ${ue_index}    IN    @{ue_list}
        power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}
        ...    direction=dl    throughput=${ues_tput}[${ue_index}]    duration=1200    apn_address=${apn}    ue_mode=MultiUE_SA
        sleep    1s
    END
    log to console      UE ${ue_list} start dl traffic

MultiUE Check throughput
    [Arguments]    ${ue_list}    ${ues_exp}    ${cells}=${cell_list}    ${actCarrierAggregation}=${False}
    FOR    ${ue_index}    IN    @{ue_list}
        ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    ue_index=${ue_index}
        ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${cells}    ue_index=${ue_index}
        ...    ultarget_throughput=0    dltarget_throughput=${ues_exp}[${ue_index}]    actCarrierAggregation=${actCarrierAggregation}
        sleep    1s
    END
    log to console      UE ${ue_list} check throughput

MultiUE Stop dl traffic
    [Arguments]    ${ue_list}    ${apn}
    FOR    ${ue_index}    IN    @{ue_list}
        UE Stop dl traffic    ue_index=${ue_index}    apn=${apn}
        sleep    1s
    END
    log to console      UE ${ue_list} stop dl traffic

g30_configuration_prepare
    ${cells}    Create List    1    2
    COAM Navigate to login page via webUI    timeout=300
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
    COAM Navigate to login page via webUI    timeout=300
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
    COAM Navigate to login page via webUI    timeout=300
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
    COAM Navigate to login page via webUI    timeout=300
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
    COAM Navigate to login page via webUI    timeout=300
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
    COAM Navigate to login page via webUI    timeout=300
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
    COAM Navigate to login page via webUI    timeout=300
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
    ...    COAM Navigate to login page via webUI    timeout=300
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    Run Keyword And Ignore Error    Close DU start up window
    DU COAM selenium logout
    log to console    cell on air after commission
    sleep    150s

Check Rat1 activited
    [Arguments]    ${bip_csv}
    ${result1}=    Run
    ...    awk 'BEGIN{FS=","}{if($NF~"DlData_PdschSendReqLoner")print $7}' ${bip_csv}
    ${rat0Bitmap_list}    Split String    string=${result1}    separator=\n
    FOR    ${rat0Bitmap}    IN    @{rat0Bitmap_list}
        should be equal    ${rat0Bitmap}    0
    END
    ${result2}=    Run
    ...    awk 'BEGIN{FS=","}{if($NF~"DlData_PdcchSendReqLoner")print $NF}' ${bip_csv}
    ${dci_list}    Split String    string=${result2}    separator=\n
    FOR    ${dci}    IN    @{dci_list}
        should contain    ${dci}    DCI_1_1
    END

Check DCI_1_1 in TRS slot
    [Arguments]    ${bip_files}    ${prb_count}=${84}    ${prefix}=trsprbcheck
    ${field_list}    Create List    DlData_PdschGrantLoner.startPrb    DlData_PdschGrantLoner.numOfPrb
    ${filter_trs}    set variable   ((3gpp.slot==1||3gpp.slot==2)&&3gpp.sfn%8==0)
    ${bip_csv}    Decode bip log to csv file with filter
    ...    bip_list=${bip_files}
    ...    filter=${filter_trs}&&((dldata_pdschsendreqloner&&3gpp.rnti!=65535)||(DlData_DciInfoLoner.dciSize==48&&DlData_DciInfoLoner.dciSize!=39))
    ...    field_list=${field_list}
    ...    prefix=${prefix}
    ${result1}=    Run
    ...    grep -B 10 "DCI_1_1" ${bip_csv} | tail -10
    ${line_list}    Split String    string=${result1}    separator=\n
    ${pdcch}    Split String    string=${line_list}[-1]    separator=,
    ${sfn_pdcch}    ${slot_pdcch}    set variable    ${pdcch}[1]    ${pdcch}[2]
    log to console    sfn: ${sfn_pdcch}, slot: ${slot_pdcch}
    ${prbcount}    set variable    0
    FOR    ${line_info}    IN    @{line_list}
        ${line}    Split String    string=${line_info}    separator=,
        ${is_pdsch_needed}    is_pdsch_line_needed    line=${line}    sfn_pdcch=${sfn_pdcch}    slot_pdcch=${slot_pdcch}
        ${prbnum}    set variable if    ${is_pdsch_needed}    ${line}[5]    0
        ${prbcount}=    Evaluate    ${prbcount}+${prbnum}
    END
    should be equal    ${prbcount}    ${prb_count}

Check all the PRBs area allocated without DCI_1_0
    [Arguments]    ${bip_files}    ${prb_count}=${106}    ${prefix}=prbcheckwodci10
    ${field_list}    Create List    DlData_PdschGrantLoner.startPrb    DlData_PdschGrantLoner.numOfPrb
    ${bip_csv}    Decode bip log to csv file with filter
    ...    bip_list=${bip_files}
    ...    filter=(3gpp.slot>=3)&&((dldata_pdschsendreqloner&&3gpp.rnti!=65535)||(DlData_DciInfoLoner.dciSize==48&&DlData_DciInfoLoner.dciSize!=39))
    ...    field_list=${field_list}
    ...    prefix=${prefix}
    ${result1}=    Run
    ...    grep -B 10 "DCI_1_1.*DCI_1_1" ${bip_csv} | tail -10
    ${line_list}    Split String    string=${result1}    separator=\n
    ${pdcch}    Split String    string=${line_list}[-1]    separator=,
    ${sfn_pdcch}    ${slot_pdcch}    set variable    ${pdcch}[1]    ${pdcch}[2]
    log to console    sfn: ${sfn_pdcch}, slot: ${slot_pdcch}
    ${prbcount}    set variable    0
    FOR    ${line_info}    IN    @{line_list}
        ${line}    Split String    string=${line_info}    separator=,
        ${is_pdsch_needed}    is_pdsch_line_needed    line=${line}    sfn_pdcch=${sfn_pdcch}    slot_pdcch=${slot_pdcch}
        ${prbnum}    set variable if    ${is_pdsch_needed}    ${line}[5]    0
        ${prbcount}=    Evaluate    ${prbcount}+${prbnum}
    END
    should be equal    ${prbcount}    ${prb_count}

is_pdsch_line_needed
    [Arguments]    ${line}    ${sfn_pdcch}    ${slot_pdcch}
    ${sfn}    ${slot}    ${pdsch}    set variable    ${line}[1]    ${line}[3]    ${line}[-1]
    ${is_pdsch}    Run Keyword And Return Status    should contain    ${pdsch}    DlData_PdschSendReqLoner
    ${is_pdsch_needed}    set variable if
    ...    ${is_pdsch} and ${sfn}==${sfn_pdcch} and ${slot}==${slot_pdcch}    True    False
    [Return]    ${is_pdsch_needed}

Check largest PDSCH sub area used with DCI_1_0
    [Arguments]    ${bip_files}    ${dci10}=DCI_1_0    ${prefix}=largestsubarea
    ...    ${filter}=dldata_pdschsendreqloner || (3gpp.rnti == 65535 && DlData_DciInfoLoner.dciSize == 48)
   ${field_list}    Create List    DlData_PdschGrantLoner.startPrb    DlData_PdschGrantLoner.numOfPrb
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
        ${is_dci10_pdsch}    set variable if    ${is_pdsch_needed} and ${line}[5]==${rnti_pdcch}    True    False
        ${dci10_startprb}    set variable if    ${is_dci10_pdsch}    ${line}[6]
        ${dci10_numofprb}    set variable if    ${is_dci10_pdsch}    ${line}[7]
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
        ${is_dci10_pdsch}    set variable if    ${is_pdsch_needed} and ${line}[5]!=${rnti_pdcch}    True    False
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
    [Arguments]    ${command}=sudo ./gnb_logs ${host_addr} -b    ${path_to_gnb_logs}=/home/ute/gnb_logs-tool/
    log to console    --- start to capture log via gnb tool ---
    ${exist}    List Directory    ${f}
    Run    sudo rm ${path_to_gnb_logs}gnb_logs/stop_mon.log
    Run    sudo rm ${path_to_gnb_logs}gnb_logs/*.zip
    ssh.Connect to    hostname=127.0.0.1
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=bsh
    ssh.Send Command    cd ${path_to_gnb_logs}gnb_logs;${command}    connection=bsh
    ssh.Read Output Until    (Q)uit    connection=bsh

Stop collect log by gnb tool
#    Wait '${time}' for stability
    log to console    --- stop gnb tool ---
    Run    sudo touch ${f}/gnb_logs-tool/gnb_logs/stop_mon.log
    sleep    1min
    Wait Until Keyword Succeeds    20min    60 sec    file should contain
    ...    ${f}/gnb_logs-tool/gnb_logs/tool.log    Tool finished running

Download captured log to target dir and unzip
    [Arguments]    ${target_dir}=${8927_logpath}
    OperatingSystem.Run   command=cd ${target_dir}; sudo rm -rf BTS-*_BIP*
    ${all_bip_file_list}   Create List
    log to console    --- start to Download bip result to specific folder ---
    @{bip_files}    List Files In Directory	   ${f}/gnb_logs-tool/gnb_logs	   BTS-*_BIP.zip
    OperatingSystem.Run    sudo mv ${f}/gnb_logs-tool/gnb_logs/*.zip ${target_dir}
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
    [Arguments]    ${target_dir}=${8927_logpath}
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
	Run    sudo rm ${8927_logpath}/${prefix}*.csv
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
    ${src_bip_csv}    Set variable    ${8927_logpath}/${prefix}_${current_time}.csv
	${bip_csv}    Set variable    ${8927_logpath}/${prefix}_${current_time}_format.csv
    Run    cat ${8927_logpath}/${prefix}*.csv > ${src_bip_csv}
	Clean CSV Backslash    input=${src_bip_csv}    output=${bip_csv}
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
    COAM Navigate to login page via webUI    timeout=300
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

Check DCI10 DCI11 Subarea Usage
    [Arguments]    ${lines}
    ${dci10_startprb}=    Set Variable    None
    ${dci10_numofprb}=    Set Variable    None
    ${prb_total}=    Set Variable    106
    # 1. Find DCI10 row (rnti==65535)
    FOR    ${line}    IN    @{lines}
        ${cols}=    Split String    ${line}    ,
        ${rnti}    set variable    ${cols}[5]
		${dci10_startprb}    Set Variable If    '${rnti}'=='65535'    ${cols}[6]
		${dci10_numofprb}    Set Variable If    '${rnti}'=='65535'    ${cols}[7]
		Exit For Loop If    '${rnti}'=='65535'
    END
    Should Not Be Empty    ${dci10_startprb}
    Should Not Be Empty    ${dci10_numofprb}
    ${dci10_endprb}=    Evaluate    ${dci10_startprb}+${dci10_numofprb}
    # Calculate subarea ranges
    ${subarea_low_start}=    Set Variable    0
    ${subarea_low_end}=    Set Variable    ${dci10_startprb}
    ${subarea_up_start}=    Set Variable    ${dci10_endprb}
    ${subarea_up_end}=    Set Variable    ${prb_total}
    Log To Console    DCI10 PRB range: [${dci10_startprb}, ${dci10_endprb})
    # 2. Check if DCI11 covers both subareas
    ${low_used}=    Set Variable    False
    ${up_used}=    Set Variable    False
    FOR    ${line}    IN    @{lines}
        ${cols}=    Split String    ${line}    ,
        ${rnti}    set variable    ${cols}[5]
        Run Keyword If    '${rnti}'=='65535'    Continue For Loop
        ${startprb}=    Set Variable    ${cols}[6]
        ${numofprb}=    Set Variable    ${cols}[7]
        ${endprb}=    Evaluate    ${startprb} + ${numofprb}
        Log To Console    DCI11 row: rnti=${rnti}, startprb=${startprb}, endprb=${endprb}
        # Check if covers low subarea
        ${low_used}    Set Variable If    ${startprb}<${subarea_low_end} and ${endprb}<=${subarea_low_end}    True    ${low_used}
        # Check if covers up subarea
        ${up_used}   Set Variable If    ${startprb}>=${subarea_up_start} and ${endprb}<=${subarea_up_end}    True    ${up_used}
    END
    Log To Console    low_used=${low_used}, up_used=${up_used}
    Should Be True    ${low_used}
    Should Be True    ${up_used}

Check multiple PDSCH sub area used with DCI_1_0
    [Arguments]    ${bip_files}    ${prefix}=prbcheckwdci10
    ...    ${filter}=3gpp.subcellid==0&&dldata_pdschsendreqloner || (3gpp.rnti == 65535 && DlData_DciInfoLoner.dciSize == 48)
   ${field_list}    Create List    DlData_PdschGrantLoner.startPrb    DlData_PdschGrantLoner.numOfPrb
    ${bip_csv}    Decode bip log to csv file with filter
    ...    bip_list=${bip_files}
    ...    filter=${filter}
    ...    field_list=${field_list}
    ...    prefix=${prefix}
	${check_result}=    Set Variable    False
    ${result1}    Run    cat ${bip_csv} | grep 'DCI_1_0.*DCI_1_1.*DCI_1_1' | awk -F',' '{print $2,$3}'
    ${lines}    Split String    string=${result1}    separator=\n
    FOR    ${line}    IN    @{lines}
	    ${sfnslot}=    Split String    string=${line}    separator=${SPACE}
		${pdschlines}    Run     awk 'BEGIN{FS=","}{if($2==${sfnslot}[0]&&$4==${sfnslot}[1]&&$NF~"DlData_PdschSendReqLoner")print $0}' ${bip_csv}
		${pdsch_list}    Split String    string=${pdschlines}    separator=\n
		${check_result}    run keyword and return status    Check DCI10 DCI11 Subarea Usage    lines=${pdsch_list}
		Exit For Loop If    ${check_result}
    END
    should be true    ${check_result}

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
    run keyword and ignore error    Download and prepare gnb_logs

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
    ...    filter=3gpp.sfn==${sfn} && 3gpp.slot==${slot} && 3gpp.rnti==${rnti} && dldata_pdschsendreqloner
    ...    xpath=.//DlData_PdschGrantLoner.rat0Bitmap
    ${is_rat0_allocated}    run keyword and return status    should be true    ${rat0Bitmap_list}[-1]!=0
    Run Keyword If  '${is_rat0_allocated}'=='True'   log to console     rat0 allocated. sfn:${sfn}, slot:${slot}, rnti:${rnti}

    ${rat0Bitmap_list_1}    run keyword if    ${is_rat0_allocated}
    ...    Get filed value by xpath with filter
    ...    pcap=${bip_file}
    ...    filter=3gpp.rnti==${rnti} && dldata_pdschsendreqloner
    ...    xpath=.//DlData_PdschGrantLoner.rat0Bitmap
    ${is_rat1_allocated}    run keyword and return status    should contain    ${rat0Bitmap_list_1}    0
    ${dynamicswitch_check}    set variable if    ${is_rat0_allocated} and ${is_rat1_allocated}     ${True}    ${False}
    [Return]    ${dynamicswitch_check}

Check dynamicswitch with DCI_1_0
    [Arguments]    ${bip_files}    ${prefix}
    ${bip2check}    create list    ${bip_files}[0]
    ${field_list}    Create List    DlData_DciInfoLoner.dciSize
    ${bip_csv}    Decode bip log to csv file with filter  bip_list=${bip2check}
    ...    filter=3gpp.rnti == 65535 && DlData_DciInfoLoner.dciSize == 50
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

Restore DU SCF with timeout
    [Arguments]    ${source_SCF_path}    ${timeout}=300
    COAM Navigate to login page via webUI    timeout=${timeout}
    Load SCF without activation    ${source_SCF_path}
    Activate Plan
    Close DU start up window
    [Teardown]    DU COAM selenium logout

modify actDlDynSwitchAlloc online
    [Arguments]    ${attr_value}    ${timeout}=300
    log to console    modify actDlDynSwitchAlloc online: ${attr_value}
    COAM Navigate to login page via webUI    timeout=${timeout}
    wait until keyword succeeds    1min    20s    selenium_coam.set_parameter_value
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
    ${field_list}    Create List    DlData_PdschGrantLoner.rat0Bitmap
    ${bip_csv}    Decode bip log to csv file with filter  bip_list=${bip2check}
    ...    filter=DlData_PdschGrantLoner.rat0Bitmap!=0
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
        ${rnti}    set variable    ${line}[5]
        ${rat0bitmap_legacyue}    set variable if    ${rnti}!=65535 and ${rnti}!=${rnti_dynamic}    ${line}[6]    1
        run keyword if    ${rat0bitmap_legacyue}==0		log to console
        ...    legacy ue ${rnti} with rat1 and dynamic ue ${rnti_dynamic} with rat0 are scheduled at the same slot: ${line}[3]
        Exit For Loop If    ${rat0bitmap_legacyue}==0
    END
    [Return]    ${rat0bitmap_legacyue}

Check rat0 and rat1 scheduled in the same slot
    [Arguments]    ${bip_files}    ${prefix}
    ${bip2check}    create list    ${bip_files}[0]
    ${field_list}    Create List    DlData_PdschGrantLoner.rat0Bitmap
    ${bip_csv}    Decode bip log to csv file with filter  bip_list=${bip2check}
    ...    filter=DlData_PdschGrantLoner.rat0Bitmap!=0
    ...    field_list=${field_list}
    ...    prefix=${prefix}
    ${result1}=    Run    cat ${bip_csv}
    ${line_list}    Split String    string=${result1}    separator=\n
    ${line_to_remove}     set variable    ${line_list}[0]
    Remove Values From List    ${line_list}    ${line_to_remove}
    ${dynamic_line}    Split String    string=${line_list}[-1]    separator=,
    ${rnti_dynamic}    set variable    ${dynamic_line}[5]
    log to console    dynamic switch ue rnti: ${rnti_dynamic}
    ${dynamicswith_sfn_slot}    Create Dictionary
    FOR    ${line_info}    IN    @{line_list}
        ${line}    Split String    string=${line_info}    separator=,
        Set To Dictionary    ${dynamicswith_sfn_slot}    ${line}[1]    ${line}[3]
    END

    FOR   ${sfn_dynamic}  IN  @{dynamicswith_sfn_slot.keys()}
        ${slot_dynamic}    set variable     ${dynamicswith_sfn_slot['${sfn_dynamic}']}
        log to console    sfn_dynamic: ${sfn_dynamic}, slot_dynamic: ${slot_dynamic}
        ${bip_csv_new}    Decode bip log to csv file with filter  bip_list=${bip2check}
        ...    filter=3gpp.sfn==${sfn_dynamic}&&3gpp.slot==${slot_dynamic}&&dldata_pdschsendreqloner
        ...    field_list=${field_list}
        ...    prefix=dynamic
        ${result2}=    Run    cat ${bip_csv_new}
        ${line_list2}    Split String    string=${result2}    separator=\n
        ${line_to_remove2}     set variable    ${line_list2}[0]
        Remove Values From List    ${line_list2}    ${line_to_remove2}
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
    OperatingSystem.Run    sudo mv ${f}/gnb_logs-tool/gnb_logs/*.zip ${target_dir}
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
    ${field_list}    Create List    DlData_PdschGrantLoner.startPrb    DlData_PdschGrantLoner.numOfPrb    DlData_PdschGrantLoner.mcs
    ${bip_files}    Create List    ${bip_file}
    ${bip_csv}    Decode bip log to csv file with filter
    ...    bip_list=${bip_files}
    ...    filter=${slot_filter}&&((dldata_pdschsendreqloner&&3gpp.rnti!=65535)||(DlData_DciInfoLoner.dciSize==48&&DlData_DciInfoLoner.dciSize!=39))
    ...    field_list=${field_list}
    ...    prefix=${prefix}
    ${result1}=    Run     awk 'BEGIN{FS=","}{if($NF~"DlData_PdcchSendReqLoner")print $2, $3}' ${bip_csv}
    ${lines1}    Split String    string=${result1}    separator=\n
    ${lines}    Get Slice From List    ${lines1}    start=1    end=-1
    ${errorcount}    set variable    0
    FOR    ${line}    IN    @{lines}
	    ${sfn_slot}=    Split String    string=${line}    separator=${SPACE}
	    ${prbsline}=    Run     awk 'BEGIN{FS=","}{if($2==${sfn_slot}[0]&&$4==${sfn_slot}[1]&&$NF~"DlData_PdschSendReqLoner")print $8, $9}' ${bip_csv}
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
    COAM Navigate to login page via webUI    timeout=${timeout}
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

config_h27_parameters_online
    [Arguments]    ${attr_value}    ${timeout}=300
    log to console    modify gscn online: ${attr_value}
    COAM Navigate to login page via webUI    timeout=${timeout}
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
    COAM Navigate to login page via webUI    timeout=${timeout}
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
    SISO Coam Suite Setup
    ${testline}   String.Fetch From Right    string=${CONFIGURATION}    marker=.
    set suite variable    ${b4_scf}    /home/ute/MN/UTE/robotws/commissionings/HGZ/${testline}/SCF_case_B4.xml
    Run     mkdir ${8927_logpath}
    ${cell_list}    Create List    153903105
    Set Suite Variable    ${cell_list}
    Set Suite Variable    ${dynamic_ue_index}    4
    ${dynamic_ue_type}    translate_power_ue_type_from_testline    ue_index=${dynamic_ue_index}
    Set Suite Variable    ${dynamic_ue_type}
	${ue_type}    translate_power_ue_type_from_testline    ue_index=0
    Set Suite Variable    ${ue_type}
    ${nr_phy_cell_ids}    set variable    363
    Set Suite Variable    ${nr_phy_cell_ids}
    run keyword and ignore error    Wireshark configuration prepare

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

modify actRat1Alloc online
    [Arguments]    ${attr_value}    ${timeout}=300
    log to console    modify actRat1Alloc online: ${attr_value}
    COAM Navigate to login page via webUI    timeout=${timeout}
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-1
    ...    abbr=actRat1Alloc
    ...    new_value=${attr_value}
    ...    filter_param=Activate FD resource allocation type1
    sleep    2s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=False
    sleep    5s
    Wait until keyword succeeds    15 min    30 sec
    ...    Du Check cell on air via WebUI without login
    DU COAM selenium logout
    sleep    10s

check actDlDynSwitchAlloc modification online
    [Arguments]    ${attr_value}    ${timeout}=300
    log to console    modify actRat1Alloc online: ${attr_value}
    COAM Navigate to login page via webUI    timeout=${timeout}
    selenium_coam.set_parameter_value
    ...    dist_name=NRCELL-1
    ...    abbr=actDlDynSwitchAlloc
    ...    new_value=${attr_value}
    ...    filter_param=Activate DL dynamic switch allocation
    sleep    2s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=False

Download and prepare gnb_logs
    [Arguments]   ${path_to_gnb_logs}=/home/ute/gnb_logs-tool/
    Run    sudo rm -rf ${path_to_gnb_logs}
    Run    wget -P ${path_to_gnb_logs} https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool/-/raw/main/gnb_logs.zip
    Run    unzip ${path_to_gnb_logs}gnb_logs.zip -d ${path_to_gnb_logs}
    Run    sudo rm ${path_to_gnb_logs}gnb_logs.zip
    Run    chmod 777 ${path_to_gnb_logs}gnb_logs/*
    Run    cd /home/ute/gnb_logs-tool/gnb_logs;sudo ./gnb_logs -v
    Run    sudo sed -i 's/Tti_raw_logs_only.*=.*yes/Tti_raw_logs_only = no/' /home/ute/gnb_logs-tool/gnb_logs/config.ini

Wireshark configuration prepare
    Run    cp ${wireshark_config}* /home/ute/.config/wireshark/

Start to collect bip log new
    [Arguments]    ${nr_phy_cell_ids}
    Run   command=rm ${bip_log_path}* -rf
    ${webservice}=  Create Dictionary
    ...  host=${tl.gnbs[${0}].dus[${0}].f1_m_ip_addr}
    ...  user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=l1l2bip
    ...  webservice=${webservice}
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    ...  timeout=1500
    core.setup_collectors    names=l1l2bip
    core.start_collectors    names=l1l2bip
    core.Set Suite Alias     l1l2bip
    Log To Console    \n start collecting bip

Stop to collect bip log new
    [Arguments]    ${target_dir}=${8927_logpath}
    core.stop_collectors    names=l1l2bip
    core.collect_collectors    names=l1l2bip       target_dir=${target_dir}
    core.teardown_collectors    names=l1l2bip
    Log To Console    \n stop collecting bip

Get BIP Filelist
    [Arguments]    ${log_path}=${bip_log_path}   ${connection}=UTE_CON   ${mergecap_wait}=120s
    Log To Console    \n merge cap wait ${mergecap_wait}
    csn.connect to
    ...               hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=UTE_CON
    @{list_log_names}     ssh_common_commands.get_file_names_under_directory    directory=${log_path}    connection=${connection}
    ...    file_indicator=${bip_prefix1}*.pcap
    Run Keyword And Ignore Error    Log to console   ${list_log_names}[0]
    ${bip_path}    set variable    ${log_path}${list_log_names}[0]
    Log To Console    \n get bip file: ${bip_path}
    ${bip_files}    Create List    ${bip_path}
    [Return]    ${bip_files}

check_blanking_prb_not_used
    [Arguments]    ${bip_files}    ${prb_blank_high}=4    ${prb_blank_low}=4    ${prb_count}=${106}    ${prefix}=prbblanking
    ${field_list}    Create List    DlData_PdschGrantLoner.startPrb    DlData_PdschGrantLoner.numOfPrb
    ${bip_csv}    Decode bip log to csv file with filter
    ...    bip_list=${bip_files}
    ...    filter=dldata_pdschsendreqloner
    ...    field_list=${field_list}
    ...    prefix=${prefix}
    ${result1}=    Run    cat ${bip_csv}
    ${line_list}    Split String    string=${result1}    separator=\n
    ${line_to_remove}     set variable    ${line_list}[0]
    Remove Values From List    ${line_list}    ${line_to_remove}
    FOR    ${line_info}    IN    @{line_list}
        ${line}    Split String    string=${line_info}    separator=,
        ${startprb}    ${numofprb}
        ...		set variable    ${line}[6]    ${line}[7]
        should be true    ${prb_blank_low}<=${startprb}
        should be true    ${startprb}+${numofprb}<=${prb_count}-${prb_blank_high}
    END

Clean CSV Backslash
    [Arguments]    ${input}    ${output}
    ${content}=    Get File    ${input}
    ${cleaned}=    Replace String    string=${content}    search_for=\\    replace_with=${EMPTY}
    Create File    ${output}    ${cleaned}