*** Settings ***
Documentation     author: Chen Xiaodong
...               contact: xiaodong.d.chen@nokia-sbell.com
...               squad group: SG_02
Suite Setup       679 Suite Setup
Suite Teardown    679 Suite TearDown
Force Tags        CB0011123         PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library           taf.hw.rf_attenuator.attenuator    WITH NAME    attenuator
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          Resources/5GC000679_common_keyword_Dingli.robot
Resource          ../5GC001655/Resources/1347_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot

*** Variables ***
${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs
${scf_path}          /home/ute/Downloads/SCF

${data_transfer_dl}     1500Mbits/sec
${data_transfer_ul}     80Mbits/sec
${Expected_Tput_DL}     1000
${Expected_Tput_UL}     40

@{modify_list}    30    30    30    30

*** Test Cases ***
[1]CB011123_SR_A_E03_B402_PDU1_PDU2_same_PC_offset
    [Tags]    CB011123    CRT_25R1
    [Setup]    Case Setup 11123
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/11123_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
    log to console      "UE_attach_Tput"
    Run Keyword And Ignore Error    spark attach and start DLUL traffic
    ...                                     data_transfer_dl=${data_transfer_dl}
    ...                                     data_transfer_ul=${data_transfer_ul}
    ...                                     n=5
    ...                                     ue_mode=SA
    ...                                     apn_address=wap1nokiacom
    log to console      "check_Tput"
    Run Keyword And Ignore Error    Check DL UL Tput on GNB
    Run Keyword And Ignore Error    All UEs Check Tput    num=8
    Run Keyword And Ignore Error    To capture Emil logs via gnb_logs tool
    Run Keyword And Ignore Error    Adjust PA to trigger RRC reestablish    port_num=4
    Run Keyword And Ignore Error    Check Emil log for 11123
    log to console      "UE_stop_Tput"
    All UEs Stop traffic    j=8    apn_address=wap1nokiacom
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=wap1nokiacom

*** Keywords ***
Case Setup 11123
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${version}     ${result}[0]
    robot_common_operations.Common Case Setup    allowed_faults_ids=1932

To capture Emil logs via gnb_logs tool
    [Documentation]     Author: xiaodong.d.chen@nokia-sbell.com
    [Arguments]     ${tool_path}=/home/ute/Downloads/gnb_logs
    ...    ${duration}=60    ${gnb_index}=${0}    ${gnb_ip}=192.168.255.129
    log to console    --- start gnb_logs collection---
    ${rm_old_logs_command}    catenate    cd ${tool_path};rm -rf BTS-${tl.gnbs[${gnb_index}].instance_id}_${gnb_ip}_*
    ${rc}=    run and return rc    command=${rm_old_logs_command}
    should be equal as integers    ${rc}    0
    ${start_capture_command}    Catenate
    ...    cd ${tool_path};./gnb_logs ${gnb_ip} -E ${duration}
    ${rc}    ${output}=    run and return rc and output    command=${start_capture_command}
    should be equal as integers    ${rc}    0
    should contain    ${output}    Tool finished running.
    log to console    --- logs collected complete ---

Check Emil log for 11123
    [Arguments]     ${tool_path}=/home/ute/Downloads/gnb_logs
    ${rc}=    run and return rc    command=unzip ${tool_path}/*Emil.zip

Adjust PA to trigger RRC reestablish
    [arguments]    ${port_num}
    ${Original_Value}    Get value from Attenuator    port_num=${port_num}
    Set Test variable    ${Original_Value}
    Modify attenuator value    modify_list=@{modify_list}    port_num=${port_num}
    sleep      5s
    Modify attenuator value    modify_list=${Original_Value}   port_num=${port_num}
    sleep      5s

Get value from Attenuator
    [arguments]    ${port_num}      ${vender}=HBTE
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=${vender}
    ${PA_value}      create list
    FOR      ${n}      IN RANGE      ${port_num}
        ${value}    attenuator.read_attenuation
         ...      port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${n}]}    attenuator_device=${vender}
        append to list      ${PA_value}      ${value}
    END
    [Return]      ${PA_value}

Modify attenuator value
    [arguments]    ${modify_list}      ${port_num}      ${vender}=HBTE
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=${vender}
    FOR      ${n}      IN RANGE      ${port_num}
          attenuator.set_attenuation
          ...      port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${n}]}
          ...      value=${${modify_list}[${n}]}
          ...      attenuator_device=${vender}
    END

Check DL UL Tput on GNB
    [Documentation]    check DL&UL tput on gnb
    ${DL_tput_cell10}    Check throughput on gNB    direction=dl    throughput=${Expected_Tput_DL}    cellid=331251722
    ${UL_tput_cell10}    Check throughput on gNB    direction=ul    throughput=${Expected_Tput_UL}    cellid=331251722

spark send CMD on UE
    [Arguments]    ${ue_index}    ${ue_alias}=UE_${ue_index}
    [Documentation]    send CMD for UE by spark
    spark.send_at_command_on_ue    command=AT+QNWPREFCFG="mode_pref",NR5G    ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=at+qnwlock="common/5g",6,509070,30,41    ue_alias=${ue_alias}
    spark.send_at_command_on_ue    command=at+QNWPREFCFG="nr5g_band",41:25:66:71     ue_alias=${ue_alias}
    log to console      "attach_${ue_alias}"
    spark.send_at_command_on_ue    command=at+cfun=1,1     ue_alias=${ue_alias}
    sleep      10s

Spark UE attach
    [Arguments]    ${n}    ${get_spark_license}=False
    [Documentation]    Attach
    ...          :param  n: The ue_index of Spark
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    log to console      "Prepare_UE${n}"
    power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${n}    get_spark_license=${get_spark_license}
    sleep      3s
    log to console      "send_CMD_UE${n}"
    Run Keyword And Continue On Failure    spark send CMD on UE    ue_index=${n}

spark attach and start DLUL traffic
    [Arguments]     ${data_transfer_dl}    ${data_transfer_ul}    ${n}
    ...             ${apn_address}    ${ue_mode}
    [Documentation]    Attach_start_DL_UL_tput
    ...          :param  n: The ue_index of Spark
    ...          :param  ue_mode: start traffic for NSA or SA
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    Run Keyword And Continue On Failure    Spark UE attach    n=${n}
    sleep      2s
    power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
    power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
