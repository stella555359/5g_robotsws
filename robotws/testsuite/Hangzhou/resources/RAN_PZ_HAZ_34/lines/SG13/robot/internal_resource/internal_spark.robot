*** Settings ***
Documentation    :copyright: Nokia
...              :contact: I_NSB_MN_RAN_RD_VRF_HAZ4_13@internal.nsn.com

*** Keywords ***
Spark UE Attach
    [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_SA    ${power_reset}=True
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}    get_spark_license=false
    ...    eq_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}    attach_mode=${attach_mode}
    Run keyword and ignore error    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False


Spark UE Send UL Traffic
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=10MKbits/sec    ${send_duration}=300    ${ue_mode}=SA    ${apn_address}=ststatic
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    Get Commercial UE IP     ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul    ue_index=${ue_index}    ue_mode=${ue_mode}
    ...    throughput=${send_traffic}    duration=${send_duration}    connection_type=current    apn_address=${apn_address}

Spark UE Send DL Traffic
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=50MKbits/sec    ${send_duration}=360    ${ue_mode}=SA    ${apn_address}=ststatic
    ...     ${iperf_port}=default
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    Get Commercial UE IP     ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl    ue_index=${ue_index}    ue_mode=${ue_mode}
    ...    throughput=${send_traffic}    duration=${send_duration}    apn_address=${apn_address}    iperf_port=${iperf_port}

Spark UE Send UL Traffic and Check Tput
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=50MKbits/sec   ${send_duration}=360    ${expect_traffic}=1    ${apn_address}=ststatic
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
#    Get Commercial UE IP     ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul
    ...    throughput=${send_traffic}    duration=${send_duration}    apn_address=${apn_address}
    sleep    120s
    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${expect_traffic}
#    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul

Spark UE Send DL Traffic and Check Tput
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=500M    ${send_duration}=360    ${expect_traffic}=40    ${apn_address}=ststatic
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}    ${check_source}=spark
#    Get Commercial UE IP     ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}    ue_alias=UE_${ue_index}
    ...    throughput=${send_traffic}    duration=${send_duration}    apn_address=${apn_address}
    sleep    120s
    ${tput_log}   power_ue.Collect Tput   ue_type=${ue_type}   duration=5m   ignore_time=1s   gnb_index=${0}    ue_alias=UE_${ue_index}
    ...    check_source=${check_source}
#    ${tput_result}   Run Keyword and Return Status   power_ue.Check Tput   ue_type=${ue_type}   direction=dl
#    ...   log=${tput_log}   cells=[1]   target_throughput=${expect_traffic}    check_source=${check_source}
    ${tput_result}   power_ue.Check Tput   ue_type=${ue_type}   direction=dl
    ...   log=${tput_log}   cells=[1]   target_throughput=${expect_traffic}    check_source=${check_source}
    Log To Console    dl_tput=${tput_result}
    #power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${expect_traffic}    ue_index=${ue_index}
#    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl

Spark UE Check Tput
    [Arguments]    ${ue_index}=${0}   ${expect_traffic}=100   ${direction}=dl    ${cells}=[1]    ${duration}=5m
    ...            ${target_avg_percent}=0.98    ${min_percent}=0.85    ${check_source}=spark    ${actCarrierAggregation}=${False}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${tput_log}   power_ue.Collect Tput   ue_type=${ue_type}   duration=${duration}   ignore_time=1s   gnb_index=${0}    ue_alias=UE_${ue_index}
    ...    check_source=${check_source}
    ${tput_result}   power_ue.Check Tput   ue_type=${ue_type}   direction=${direction}
    ...    log=${tput_log}   cells=${cells}   target_throughput=${expect_traffic}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    check_source=${check_source}    actCarrierAggregation=${actCarrierAggregation}
    Log To Console    tput=${tput_result}
    #${tput}    Set Variable    ${tput_result}[0]
    #${average}    Get from dictionary    ${tput}    average
    #Log To Console    average=${average}
    [Return]    ${tput_result}

Spark UE Stop traffic
    [Arguments]    ${direction}    ${ue_index}=${0}    ${ue_mode}=SA    ${apn_address}=ststatic
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=${direction}    ue_index=${ue_index}    ue_mode=${ue_mode}
    ...    ue_alias=UE_${ue_index}    apn_address=${apn_address}

Spark UE Detach
    [Arguments]    ${ue_index}=${0}    ${power_reset}=False
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${ue_index}    power_reset=${power_reset}

Spark Start UE Log
	[Arguments]    ${ue_index}
	[Documentation]    *****************
	...    This keyword is used to stop spark log
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ue_index | Yes | UE index |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

	Log To Console    spark start log
	${ue_alias}    set variable    UE_${ue_index}
	spark.start_log   ue_alias=${ue_alias}

Spark Stop UE Log
	[Arguments]    ${ue_index}    ${log_name}    ${filter}=${None}
	[Documentation]    *****************
	...    This keyword is used to stop spark log
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ue_index | Yes | UE index |
    ...    | log_name |  Yes |log_name for saving on UTE with .csv
    ...    | filter | NO | filter template name on spark(need set on spark)  default: test.txtmf|
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

	Log To Console    spark stop log
	${ue_alias}    set variable    UE_${ue_index}
	spark.stop_log    ue_alias=${ue_alias}    logname=${log_name}    filter=${filter}

Upload txtmf to spark
    [Arguments]    ${txtmf_path}    ${ip}    ${user_name}=spark    ${user_password}=spark
    [Documentation]    *****************
	...    This keyword is used to upload test.txtmf to spark
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | txtmf_path | Yes | test.zip path, test.txtmp compression to test.zip|
    ...    | ip |  Yes | spark ip |
    ...    | user_name | NO | ssh spark username|
    ...    | user_password | NO | ssh spark user password |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    unzip_file    ${txtmf_path}/test.zip    ${test_log_directory()}
    ${latest_spark}    get_latest_direcotory    ${ip}    ${user_name}    ${user_password}    C:\\Program Files (x86)    Spark
    ${spark_export_path}    catenate    SEPARATOR=    ${latest_spark}    \\Bin\\Config\\Module\\Export\\
    TAF_SSH.connect to    ${ip}    ${user_name}    ${user_password}    alias=spark
    TAF_SSH.upload file    ${test_log_directory()}/test/test.txtmf    ${spark_export_path}test.txtmf    connection=spark
