*** Settings ***
Documentation     author: Chen Xiaodong
...               contact: xiaodong.d.chen@nokia-sbell.com
...               squad group: SG_02
Suite Setup       679 Suite Setup
Suite Teardown    679 Suite TearDown
Force Tags        CB008600         PY36
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
Resource          Resources/CB012238_keywords.robot
Variables         Resources/CB012238_variables.py

*** Variables ***
${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs
${scf_path}          /home/ute/Downloads/SCF

${data_transfer_dl}     1500Mbits/sec
${data_transfer_ul}     80Mbits/sec

*** Test Cases ***
[1][1.0]CB008600_SR_D_18_B4_Successful Intra-gNB Inter-DU Handover for UE configured with DC-GBR DRB
    [Tags]    CB008600    CRT_trunk
    [Setup]    Case Setup 8600
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/8600_scf.xml
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type}
#    log to console      "UE3_attach_Tput"
#    Run Keyword And Ignore Error    spark attach and start DLUL traffic
#    ...                                     data_transfer_dl=${data_transfer_dl}
#    ...                                     data_transfer_ul=${data_transfer_ul}
#    ...                                     n=2
#    ...                                     ue_mode=SA
#    ...                                     apn_address=mdrbnokiacom
#    sleep      300s
#    Run Keyword And Ignore Error    8600 counter check_1
#    log to console      "UE5_attach_Tput"
#    Run Keyword And Ignore Error    spark UE attach    n=4
#    log to console      "UE5_attach_failed_dueto_not_radio_resource"
#    sleep      300s
#    Run Keyword And Ignore Error    8600 counter check_1
#    Run Keyword And Ignore Error    spark send CMD detach all UE
#    log to console      "UE3_attach_Tput"
#    Run Keyword And Ignore Error    spark attach and start DLUL traffic
#    ...                                     data_transfer_dl=1Mbits/sec
#    ...                                     data_transfer_ul=1Mbits/sec
#    ...                                     n=2
#    ...                                     ue_mode=SA
#    ...                                     apn_address=mdrbnokiacom
#    sleep      300s
#    Run Keyword And Ignore Error    8600 counter check_2
#    log to console      "UE5_attach_Tput"
#    Run Keyword And Ignore Error    spark UE attach    n=4
#    log to console      "UE5_attach_success"
#    sleep      300s
#    Run Keyword And Ignore Error    8600 counter check_3
#    Run Keyword And Ignore Error    spark UE attach    n=5
#    log to console      "UE6_attach_failed_dueto_maxNumOfDcGbrBearersSA=2"
#    sleep      300s
#    Run Keyword And Ignore Error    8600 counter check_33
#    log to console      "UE_stop_Tput"
#    All UEs Stop traffic    j=8    apn_address=mdrbnokiacom
#    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=mdrbnokiacom
    Run Keyword And Ignore Error    CB008600 UEs attach and start traffic       host=${spark_ip}
    ...                                                                         port=${spark_port}
    Run Keyword And Ignore Error    CB008600 check counters                     counters_id=${CB008600_COUNTERS}
    ...                                                                         counters_unique_path=${CB008600_PATH}
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/CB008118_scf.xml
    Run Keyword And Ignore Error    CB008118 Ue Attach And Start Dl Ul Traffic    host=${spark_ip}
    ...                                                                           port=${spark_port}
    ...                                                                           appserver=${appserver}
    ...                                                                     appserver_username=${appserver_username}
    ...                                                                     appserver_password=${appserver_password}
    sleep      300s
    Run Keyword And Ignore Error    CB0081118 Check Counters       counters_id=${CB008118_COUNTERS}
    ...                                                            counters_unique_path=${CB008118_PATH}
    Run Keyword And Ignore Error    CB008118 Stop Dl Ul Traffic    host=${spark_ip}
    ...                                                            port=${spark_port}
    ...                                                            appserver=${appserver}
    ...                                                            appserver_username=${appserver_username}
    ...                                                            appserver_password=${appserver_password}
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/CNI140147_scf.xml
    Run Keyword And Ignore Error    CNI140147 Attach Ue And Trigger Handover
    Sleep    360s
    Run Keyword And Ignore Error    CNI140147 Check Counters        counters_id=${CNI140147_COUNTERS}
    ...                                                             counters_unique_path=${CNI140147_PATH}
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=mdrbnokiacom

*** Keywords ***
Case Setup 8600
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${version}     ${result}[0]
    robot_common_operations.Common Case Setup    allowed_faults_ids=49

8600 counter check_1
    [Documentation]    check related PM counter value
    ${M55138C00075}      Get BTS Counters from webUI    counter_id=M55138C00075
    ${M55138C00076}      Get BTS Counters from webUI    counter_id=M55138C00076
    ${M55139C00034}      Get BTS Counters from webUI    counter_id=M55139C00034
    ${M55139C00035}      Get BTS Counters from webUI    counter_id=M55139C00035
    ${M55138C01001}      Get BTS Counters from webUI    counter_id=M55138C01001
    ${M55138C01002}      Get BTS Counters from webUI    counter_id=M55138C01002
    Should be true    ${M55138C00075}=1
    Should be true    ${M55138C00076}=1
    Should be true    ${M55139C00034}=1
    Should be true    ${M55139C00035}=1
    Should be true    ${M55138C01001}=1
    Should be true    ${M55138C01002}=1

8600 counter check_2
    [Documentation]    check related PM counter value
    ${M55138C00075}      Get BTS Counters from webUI    counter_id=M55138C00075
    ${M55138C00076}      Get BTS Counters from webUI    counter_id=M55138C00076
    ${M55139C00034}      Get BTS Counters from webUI    counter_id=M55139C00034
    ${M55139C00035}      Get BTS Counters from webUI    counter_id=M55139C00035
    ${M55138C01001}      Get BTS Counters from webUI    counter_id=M55138C01001
    ${M55138C01002}      Get BTS Counters from webUI    counter_id=M55138C01002
    Should be true    ${M55138C00075}=2
    Should be true    ${M55138C00076}=2
    Should be true    ${M55139C00034}=2
    Should be true    ${M55139C00035}=2
    Should be true    ${M55138C01001}=2
    Should be true    ${M55138C01002}=2

8600 counter check_3
    [Documentation]    check related PM counter value
    ${M55138C00075}      Get BTS Counters from webUI    counter_id=M55138C00075
    ${M55138C00076}      Get BTS Counters from webUI    counter_id=M55138C00076
    ${M55139C00034}      Get BTS Counters from webUI    counter_id=M55139C00034
    ${M55139C00035}      Get BTS Counters from webUI    counter_id=M55139C00035
    ${M55138C01001}      Get BTS Counters from webUI    counter_id=M55138C01001
    ${M55138C01002}      Get BTS Counters from webUI    counter_id=M55138C01002
    Should be true    ${M55138C00075}=3
    Should be true    ${M55138C00076}=3
    Should be true    ${M55139C00034}=3
    Should be true    ${M55139C00035}=3
    Should be true    ${M55138C01001}=3
    Should be true    ${M55138C01002}=3

8600 counter check_33
    [Documentation]    check related PM counter value
    ${M55138C00077}      Get BTS Counters from webUI    counter_id=M55138C00077
    ${M55138C01003}      Get BTS Counters from webUI    counter_id=M55138C01003
    Should be true    ${M55138C00077}=1
    Should be true    ${M55138C01003}=1

spark send CMD detach all UE
    [Documentation]    dettach all UE
    log to console      "detach_ues"
    FOR    ${i}    IN RANGE    8
        power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${i}    get_spark_license=False
        spark.send_at_command_on_ue    command=AT+CFUN=0        ue_alias=UE_${i}
    END

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