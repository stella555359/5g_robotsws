*** Settings ***
Documentation    author: xudeng
...              Group: RAN_PZ_HAZ3_SG02
...              contact: xueqin.deng@nokia-sbell.com

Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.config.scf    WITH NAME    scf
Library    robot.libraries.DateTime
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/python/csvanalyzer.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot

*** Variables ***
${12724_A_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00_12724_A.xml
${12724_C_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00_12724_C.xml
${12724_E_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00_12724_E.xml
${12724_F_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00_12724_F.xml
${12724_G_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00_12724_G.xml


${MRBTS}    MRBTS-4294967166
${NRBTS}    NRBTS-272390
${oam_ip}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${M55393C00001_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/SRBL2/M55393C00001
${M55393C00002_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/SRBL2/M55393C00002
${M55393C00003_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/SRBL2/M55393C00003
${M55393C00004_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/SRBL2/M55393C00004
${M55393C00005_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/SRBL2/M55393C00005
${M55393C00006_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/SRBL2/M55393C00006
${M55308C00150_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C00150
${M55308C00151_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C00151
${M55308C00152_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C00152
${M55308C00153_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C00153
${M55308C00154_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C00154
${M55308C00156_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C00156
${M55308C00157_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C00157
${M55308C00158_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C00158
${M55308C00160_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C00160
${M55301C00095_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NDLSQ/M55301C00095
${M55301C00094_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NDLSQ/M55301C00094
${M55301C00093_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NDLSQ/M55301C00093
${M55301C00092_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NDLSQ/M55301C00092
${M55301C00091_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NDLSQ/M55301C00091
${M55301C00090_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NDLSQ/M55301C00090
${M55113C00019_full_path}    ${MRBTS}/${NRBTS}/NRCELL-17/NF1CC/M55113C00019
${M55113C00020_full_path}    ${MRBTS}/${NRBTS}/NRCELL-17/NF1CC/M55113C00020
${M55113C00021_full_path}    ${MRBTS}/${NRBTS}/NRCELL-17/NF1CC/M55113C00021
${M55113C00022_full_path}    ${MRBTS}/${NRBTS}/NRCELL-17/NF1CC/M55113C00022
${M55308C00165_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C00165
${M55308C00166_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C00166
${M55308C00169_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C00169
${M55308C00170_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C00170
${M55308C10003_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C10003
${M55308C10001_full_path}    ${MRBTS}/${NRBTS}/NRCELL-1/NCELA/M55308C10001

${pa_ip}    ${tl.attenuator.ip_addr}
${pa_port}    ${tl.attenuator.port}
@{PA_value_25}    ${25.0}    ${25.0}   ${25.0}    ${25.0}
@{PA_value_65}    ${65.0}    ${65.0}   ${65.0}    ${65.0}


${apn0}    mdrb.nokia.com
@{new_fault_ids}    ${61644}    ${7307}    ${7311}
${if_commissioning}    False
@{CA_PA_value}    ${25.0}    ${25.0}   ${20.0}    ${25.0}
*** Keywords ***
CB012724_Suite_Setup
    SISO Coam Suite Setup
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=1
    Set Suite Variable    ${ue_type}
    FOR    ${id}    IN    @{new_fault_ids}
        ${dict}=    Create Dictionary    faultId=${id}
        Append To List    ${ALLOWED_FAULT}    ${dict}
    END
    Set Suite Variable     ${ALLOWED_FAULT}
	Run Keyword And Ignore Error    Set PA value    modify_list=${CA_PA_value}      port_num=${4}

CB012724_Suite_Teardown
    SISO Coam Suite Teardown

case_common_setup
    SISO Coam Test Setup

case_common_teardown
    SISO Coam Test Teardown

Restore DU SCF with timeout
    [Arguments]    ${source_SCF_path}    ${timeout}=300
    COAM Navigate to login page via webUI    timeout=${timeout}
    Load SCF without activation    ${source_SCF_path}
    Activate Plan
    Close DU start up window
    [Teardown]    DU COAM selenium logout

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

Wait Until Next Counter Update
    [Arguments]    ${counter_period}=5    ${connection}=ASIK Master
	Connect to Common Unit Master    alias=${connection}
    ${period}    Evaluate    ${counter_period}*60
    ${current}     csn.execute    command=date +%s    connection=${connection}
    ${current}    Get Line    ${current}    -1
    ${sleep}    Evaluate    ${period}+${period}-${current}+int(${current}/${period})*${period}
    Sleep    ${sleep}
	[Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${connection}

get_counters_values_sum
    [Arguments]    ${counters_values}
	${sum}    Evaluate    sum([int(x) for x in ${counters_values}])
	[Return]    ${sum}

COAM get pm counters dict via admin
    [Arguments]   ${counter_id_list}   ${bts_host}=${oam_ip}    ${timeout}=${900}   ${connection}=COAM
	COAM.Setup Admin    bts_host=${bts_host}    alias=${connection}
    ${counter_ids}   Set Variable   ,
    ${counter_ids}   Set Variable   ${counter_ids.join(${counter_id_list})}
    ${counters_dict}   coam.get_pm_counters
    ...   counter_ids=${counter_ids}
    ...   timeout=${timeout}
    ...   connection=${connection}
    [Return]   ${counters_dict}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown    connection=${connection}

Get counter latest value from dict
    [Arguments]    ${counters_dict}    ${BTS_or_TRS}    ${full_path}
    ${keys}=    Split String    ${full_path}    /
    ${keys}=    Create List    ${BTS_or_TRS}    @{keys}
    ${value}=    Set Variable    ${counters_dict}
    FOR    ${key}    IN    @{keys}
        ${value}=    Get From Dictionary    ${value}    ${key}
    END
    ${all_keys}=    Get Dictionary Keys    ${value}
    ${last_key}=    Get From List    ${all_keys}    -1
    ${last_value}=    Get From Dictionary    ${value}    ${last_key}
    [Return]    ${last_value}

MultiUE Start dlul traffic
    [Arguments]    ${ue_list}    ${apn}    ${ues_dltput}    ${ues_ultput}
    FOR    ${ue_index}    IN    @{ue_list}
        Run Keyword If   '${ues_dltput}[${ue_index}]'!='0MKbits/sec'    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}
        ...    direction=dl    throughput=${ues_dltput}[${ue_index}]    protocol=udp    duration=1200    apn_address=${apn}    ue_mode=MultiUE_SA
        Run Keyword If   '${ues_ultput}[${ue_index}]'!='0MKbits/sec'    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}
        ...    direction=ul    throughput=${ues_ultput}[${ue_index}]    protocol=udp    duration=1200    apn_address=${apn}    ue_mode=MultiUE_SA
        sleep    1s
    END
    log to console      UE ${ue_list} start dlul traffic

MultiUE Stop traffic
    [Arguments]    ${ue_list}    ${apn}
    FOR    ${ue_index}    IN    @{ue_list}
        UE Stop dl traffic    ue_index=${ue_index}    apn=${apn}
        sleep    1s
        UE Stop ul traffic    ue_index=${ue_index}    apn=${apn}
        sleep    1s
    END
    log to console      UE ${ue_list} stop traffic

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

Get counter latest update time from dict
    [Arguments]    ${counters_dict}    ${BTS_or_TRS}    ${full_path}
    ${keys}=    Split String    ${full_path}    /
    ${keys}=    Create List    ${BTS_or_TRS}    @{keys}
    ${value}=    Set Variable    ${counters_dict}
    FOR    ${key}    IN    @{keys}
        ${value}=    Get From Dictionary    ${value}    ${key}
    END
    ${all_keys}=    Get Dictionary Keys    ${value}
    ${last_key}=    Get From List    ${all_keys}    -1
    [Return]    ${last_key}

Get counter values after start time from dict
    [Arguments]    ${counters_dict}    ${BTS_or_TRS}    ${full_path}    ${start_time}
	${result}    create list
    ${keys}=    Split String    ${full_path}    /
    ${keys}=    Create List    ${BTS_or_TRS}    @{keys}
    ${value}=    Set Variable    ${counters_dict}
    FOR    ${key}    IN    @{keys}
        ${value}=    Get From Dictionary    ${value}    ${key}
    END
    ${all_keys}=    Get Dictionary Keys    ${value}
    FOR    ${key}    IN    @{all_keys}
        ${counter_value}=    Get From Dictionary    ${value}    ${key}
		${cmp}=    Evaluate    '${key}' > '${start_time}'
        Run Keyword If    ${cmp}    Append To List    ${result}    ${counter_value}
    END
    [Return]    ${result}

Set PA value
    [arguments]    ${modify_list}      ${port_num}      ${vender}=HBTE
    attenuator.setup_attenuator    attenuator=${tl.attenuator[2]}    alias=${vender}
    FOR      ${n}      IN RANGE      ${port_num}
          attenuator.set_attenuation
          ...      port=${tl.gnbs[0].dus[0].rus[4].attenuation_ports[${n}]}
          ...      value=${${modify_list}[${n}]}
          ...      attenuator_device=${vender}
    END
