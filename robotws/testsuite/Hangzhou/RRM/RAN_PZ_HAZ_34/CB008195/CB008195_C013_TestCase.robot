*** Settings ***
Suite Setup    Setup 2BTS env and set keyword prority    scf1=SCFC_1_for_C013.xml    scf2=SCFC_2_for_C013.xml
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs

Documentation    Suite description
...   author:      Zhu Baijie
...   contact:     Baijie.zhu@nokia-sbell.com
...   squad group: MMW_SG7
...   Feature:     CB008195_C013_NSA

Force Tags    5G_RRM
...   PY39

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resource/Common_Keywords.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008195/resource/Spark_8UEs.py

*** Variables ***
${SNAPSHOT_FLAG}      pass:False,fail:False
${SOS_REPORT_FLAG}    pass:False,fail:False
${EMIL_FLAG}          False
${SOS_REPORT_STARTUP_1_FLAG}    pass:False,fail:False

@{attach_cell3_pa_values}
...    11=${35}
...    12=${35}
...    15=${35}
...    16=${35}

@{attach_cell5_pa_values}
...    3=${20}
...    4=${20}
...    5=${20}
...    6=${20}

*** Test Cases ***
[1]CB008195-ET-C013_Verify Successful NSA UE Cont m-cell pooled res limits check that reach minQ and there has unused and unres m-cell p res
    [Documentation]
    ...    Description:
    ...    To Verify NSA UE Context Static cell limits check Success With resource allcated in common pool As Per PLMN.
    ...    Precondition:
    ...    gNB is up and work normal
    ...    Test Steps:
    ...    Step 1: NSA UE7, UE8 attach to CELL5 with PLMN-2 to occupy ResourceGroupId-1 common resources.
    ...    Expected Result: UE attach successfully using ResourceGroupId-1 common resource with PLMN-2.
    ...    Step 2: NSA UE1 attach to CELL3 with PLMN-1 to occupy ResourceGroupId-2 dedicated resources.
    ...    Expected Result: UE attach successfully using ResourceGroupId-2 dedicated resource with PLMN-1, common resource is still
    ...    available for this RG and  left pool resources is 1.
    ...    Step 3: start DL traffic for UE1
    ...    Expected Result: Stable DL throughput is achieved(No BLER, DTX, NACK, CRC KO)
    ...    Step 4: NSA UE2 attach to CELL3 with PLMN-1.
    ...    Expected Result: UE attach sucessfully using ResourceGroup-2 common resource with PLMN-1(minQuota is reached by UE1),
    ...    then left pool resources is 0.
    ...    Step 5: start DL traffic for UE2
    ...    Expected Result: Stable DL throughput is achieved(No BLER, DTX, NACK, CRC KO)
    ...    Step 6: NSA UE3 attach to CELL3 with PLMN-1.
    ...    Expected Result: UE attach failed due to no pool resource left.
    ...    Step 7: Release NSA UE8 to release ResourceGroupId-1 common resource.
    ...    Expected Result: NSA UE8 release successsfully.
    ...    Step 8: NSA UE3 attach to CELL3 with PLMN-1.
    ...    Expected Result: UE attach successfully using ResourceGroup-2 common resource with PLMN-1(minQuota is reached by UE3).
    ...    Step 9: Also check reoucegroup relevant counters.
    [Tags]    C013    QC_59857
    Set cell3 and cell5 PA for attach
    Set test variable    ${UECFG}   ${TLCommonConfig["MultiUECFG"]}
    Set test variable    ${ue_type}    huawei_sigspark
    Run keyword and ignore error    Unlock cell band
    Detach all UEs
    Clear Counter Files    wait=${True}
    UE7 and UE8 attach cell5 with PLMN2 to occupy ResourceGroupId-1 common resources
    UE1 and UE2 attach cell3 with PLMN1 to occupy ResourceGroupId-2 dedicated and common resource and then no pool resouce left
    UE3 attach cell3 with PLMN1 failed due to no pool resouce left
    Detach UE8 and generate one pool resource
    UE3 attach cell3 with PLMN1 sucessfully
    Check Counters    ${CELL_COUNTER}
    [Teardown]    Run Keyword And Ignore Error   All UEs Stop traffic and detach UE

*** Keywords ***
Set cell3 and cell5 PA for attach
    set_pa_values    ${attach_cell3_pa_values}
    set_pa_values    ${attach_cell5_pa_values}

UE7 and UE8 attach cell5 with PLMN2 to occupy ResourceGroupId-1 common resources
    Delta Commission Parameters    NRCELL-5:administrativeState=Unlocked
    log to console    Unlock cell5
    Wait Until Keyword Succeeds    60s    2s   Object Should Exist  NRCELL-5:administrativeState=Unlocked
    FOR    ${ue}    IN     6    7
        prepare and attach UE     ue=${ue}    attach_cell_id=396
    END

prepare and attach UE
    [Arguments]    ${ue}=1    ${attach_cell_id}=398
    log to console      Set variable according to TLCommonConfig
    ${detach_request}  set variable    ${UECFG['${ue}']["detach_request"]}
    ${power_reset}     set variable    ${UECFG['${ue}']["power_reset"]}
    ${ue_mode}         set variable    ${UECFG['${ue}']["ue_mode"]}
    ${apn}             set variable    ${UECFG['${ue}']['apn']}
    ${ul_tp}           set variable    ${UECFG['${ue}']['ul']['target_throughput']}
    ${ul_dur}          set variable    ${UECFG['${ue}']['ul']['duration']}
    ${dl_tp}           set variable    ${UECFG['${ue}']['dl']['target_throughput']}
    ${dl_dur}          set variable    ${UECFG['${ue}']['dl']['duration']}
    ${tg_percent}      set variable    ${UECFG['${ue}']['target_percent']}
    ${attach_mode}     set variable    ${UECFG['${ue}']["attach_mode"]}
    ${apn_address}     set variable    ${UECFG['${ue}']["apn_address"]}
    ${dt_name}         set variable    ${UECFG['${ue}']["dt_name"]}
	#Delta_commission_parameters_bts2   ${cell3_nrcarprio_better_than_cell5}
	sleep    3s
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue}    get_spark_license=False    force_check_ue=${True}
    sleep    3s
    log to console    ${TLCommonConfig["MultiUECFG"]['ue_index_for_call']}_${ue}_attach
    #spark ue attach by power off and power on    ue_alias=UE_${ue}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}     attach_mode=${attach_mode}    ue_index=${ue}
    power_ue.Verify attach     ue_type=${ue_type}    4G_check=True    5Grach_ed=${5Grach_ed}     ue_index=${ue}
    ...    cell_id=${attach_cell_id}
    sleep    3s
    log to console    ${TLCommonConfig["MultiUECFG"]['ue_index_for_call']}_${ue}_send_traffic
    power_ue.Start traffic     ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${dl_dur}
    ...                        ue_index=${ue}    ue_mode=${ue_mode}    apn_address=${apn_address}    dt_name=${dt_name}
    power_ue.Start traffic     ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${ul_dur}
    ...                        ue_index=${ue}    ue_mode=${ue_mode}    apn_address=${apn_address}    dt_name=${dt_name}
    sleep    5s
    log to console    ${TLCommonConfig["MultiUECFG"]['ue_index_for_call']}_traffic_check_on_UEside
    Check Tput for one UE     ue=${ue}

UE3 attach cell3 with PLMN1 failed due to no pool resouce left
    [Arguments]    ${ue}=2
    log to console      Set variable according to TLCommonConfig
    ${detach_request}  set variable    ${UECFG['${ue}']["detach_request"]}
    ${power_reset}     set variable    ${UECFG['${ue}']["power_reset"]}
    ${ue_mode}         set variable    ${UECFG['${ue}']["ue_mode"]}
    ${apn}             set variable    ${UECFG['${ue}']['apn']}
    ${ul_tp}           set variable    ${UECFG['${ue}']['ul']['target_throughput']}
    ${ul_dur}          set variable    ${UECFG['${ue}']['ul']['duration']}
    ${dl_tp}           set variable    ${UECFG['${ue}']['dl']['target_throughput']}
    ${dl_dur}          set variable    ${UECFG['${ue}']['dl']['duration']}
    ${tg_percent}      set variable    ${UECFG['${ue}']['target_percent']}
    ${attach_mode}     set variable    ${UECFG['${ue}']["attach_mode"]}
    ${apn_address}     set variable    ${UECFG['${ue}']["apn_address"]}
    ${dt_name}         set variable    ${UECFG['${ue}']["dt_name"]}
	sleep    3s
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue}    get_spark_license=False    force_check_ue=${True}
    sleep    3s
    log to console    ${TLCommonConfig["MultiUECFG"]['ue_index_for_call']}_${ue}_attach
    #Lock band 1+band 78 for UE3
    spark.send_at_command_on_ue    ue_alias=UE_${ue}    command=AT+GTACT=17,,,101,5078
    sleep    3s
    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=${attach_mode}    ue_index=${ue}
    #Verify Attach Status    ue_index=${ue_index}
    ${event_name_list}    create list     NR5G Cell Add Success
    ${count_list}    spark.get_event_count_on_ue    index=${ue}    ue_alias=UE_${ue}    event_name=${event_name_list}
    should be true    ${${count_list}[0]}==0
    log to console    ${ue}_attach expect failed

UE1 and UE2 attach cell3 with PLMN1 to occupy ResourceGroupId-2 dedicated and common resource and then no pool resouce left
    Delta Commission Parameters    NRCELL-3:administrativeState=Unlocked
	log to console    Unlock cell3
	Wait Until Keyword Succeeds    60s    2s   Object Should Exist  NRCELL-3:administrativeState=Unlocked
    FOR    ${ue}    IN    0    1
        prepare and attach UE     ue=${ue}    attach_cell_id=398
    END

UE3 attach cell3 with PLMN1 sucessfully
	prepare and attach UE     ue=2    attach_cell_id=398

spark ue attach by power off and power on
    [Arguments]    ${ue_alias}
    spark.power_off    ue_alias=${ue_alias}
    sleep    2s
    spark.power_off    ue_alias=${ue_alias}
    sleep    2s
    spark.power_on    ue_alias=${ue_alias}
    sleep    2s
    spark.power_on    ue_alias=${ue_alias}
    sleep    2s

Detach all UEs
   log to console    detach all UEs
    FOR    ${ue}    IN RANGE    0     8
	    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue}    get_spark_license=False
        power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue}   power_reset=Flase
    END

Check Tput for one UE
    [Arguments]     ${ue}    ${ue_type}=huawei_sigspark    ${Expected_Throughput_DL}=5    ${Expected_Throughput_UL}=1
    [Documentation]    check_tput
    ...                :param  n: The ue_index of Dingli
    run keyword and ignore error    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${Expected_Throughput_DL}
    ...                                                          ue_index=${ue}
    run keyword and ignore error    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${Expected_Throughput_UL}
    ...                                                          ue_index=${ue}

All UEs Stop traffic and detach UE
    [Arguments]    ${ue_type}=huawei_sigspark 
    [Documentation]    stop_DLUL_traffic
    log to console      "Stop all UE traffic and detach"
    FOR    ${ue}    IN    @{UECFG['ue_index_for_call']}
        ${ue_mode}         set variable    ${UECFG['${ue}']["ue_mode"]}
        ${apn_address}     set variable    ${UECFG['${ue}']["apn_address"]}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue}    ue_mode=${ue_mode}
        ...                                                      apn_address=${apn_address}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue}    ue_mode=${ue_mode}
        ...                                                      apn_address=${apn_address}
        sleep    1s
        power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue}   power_reset=Flase
        sleep    2s
    END
	Delta Commission Parameters    NRCELL-5:administrativeState=Unlocked
	#Delta Commission Parameters    NRCELL-3:administrativeState=Unlocked
	#Delta_commission_parameters_bts2   ${cell5_nrcarprio_better_than_cell3}
	#Delta_commission_parameters_bts2   ${cell3_nrcarprio_better_than_cell5}
	power_ue.Prepare UE    ue_type=${ue_type}    ue_index=2    get_spark_license=False
	spark.send_at_command_on_ue    ue_alias=UE_2    command=AT+GTACT=10
    Common Test Teardown And Stop Capture Logs

Detach UE8 and generate one pool resource
    [Arguments]   ${ue}=7    ${ue_type}=huawei_sigspark
    [Documentation]    stop_DLUL_traffic_and_detach_ue7
    log to console      "Stop UE8 traffic and detach"
    ${ue_mode}         set variable    ${UECFG['${ue}']["ue_mode"]}
    ${apn_address}     set variable    ${UECFG['${ue}']["apn_address"]}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue}    ue_mode=${ue_mode}
    ...                                                      apn_address=${apn_address}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue}    get_spark_license=False
    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue}   power_reset=Flase
    sleep    3s

Unlock cell band
    FOR    ${ue_no}    IN RANGE    0     8
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_no}    power_reset=true    get_spark_license=False
        ${result1}    spark.send_at_command_on_ue    ue_alias=UE_${ue_no}    command=at+gtcelllock=0
        ${result2}    spark.send_at_command_on_ue    ue_alias=UE_${ue_no}    command=AT+GTACT=10
        ${result3}    spark.send_at_command_on_ue    ue_alias=UE_${ue_no}    command=AT+CFUN=15
    END