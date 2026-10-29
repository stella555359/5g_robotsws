*** Settings ***
Suite Setup    Setup 2BTS env and set keyword prority    scf1=SCFC_1_for_C026.xml    scf2=SCFC_2_for_C026.xml
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs

Documentation    Suite description
...   author:      Flora Du
...   contact:     Flora.du@nokia-sbell.com
...   squad group: MMW_SG7
...   Feature:     CB008195_C026_NSA

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

@{set_cell3_pa_bad}
...    11=${45}
...    12=${45}
...    15=${45}
...    16=${45}

@{set_cell5_pa_bad}
...    3=${45}
...    4=${45}
...    5=${45}
...    6=${45}

@{attach_cell5_pa_values}
...    3=${20}
...    4=${20}
...    5=${20}
...    6=${20}

*** Test Cases ***
[1]CB008195-ET-C026_Verify_Successful_NSA non-GBR_DRB_Admission_multiple-cell_pooled_resource
    [Documentation]
    ...    Description:
    ...    This test case is to Verify Successful NSA non-GBR DRB Admission multiple-cell pooled resource limits check
    ...    that does not reach minQuota and there is no unused and unreserved multiple-cell pooled resources in Case of PScCell Change
    ...    allcated in Dedicate pool As Per PLMN.
    ...    5G_RAN_USR_RRM_23596, fully covered
    ...    CB008195-C#B1: NSA UE Context Admission, Static cell limits check - Success 

    ...    Precondition:
    ...    gNB/cell supports NSA mode (NRBTS.gNBCuType=NSA, NRCELL.cellDepType).
    ...    At least two cells configured.
    ...    gNB is up and work normal.
    ...    Configuration:
    ...      LTE(Cell1)    GNB(CELL5 with 8195 2UEs, cell3 without 8195 1UE)
    ...    Test Steps:
    ...    Step 1: NSA UE1 and UE2 attach to CELL5 and setup pdu sessions with total 2 drbs.
    ...    Step 2: NSA UE3 attach to CELL3.
    ...    Step 3: NSA UE3 perform pscell change to cell5.
    ...    Step 4: Perform NSA UE3 pscell change back to cell3.

    ...    Expected result:
    ...    Step 1: UE1 and UE2 attach success using ResourceGroupId-1 two dedicated DRB resource with PLMN-3 
    ...    Step 2: UE3 attachs success using 2 ResourceGroupId-1 common resource with PLMN-1.
    ...            There is no unsed and unreserved multiple-cell pooled resources now.
    ...    Step 3: UE3 HO should be succeed and using ResourceGroupId-1 dedicated drb resource with PLMN-3. b. traffic is stable.
    ...    Step 4: HO should be success.
    ...            Counters M55910C00015 and M55910C00016 should not be pegged. others couner as except
    [Tags]    C026    QC_57055
	Set cell3 and cell5 PA for attach
    Set test variable    ${UECFG}   ${TLCommonConfig["MultiUECFG"]}
    Set test variable    ${ue_type}    huawei_sigspark
	Detach all UEs
    Clear Counter Files    wait=${True}
    UE1 attach cell3
    UE2 and UE3 attach cell5
    UE1 handover from cell3 to cell5
	All UEs handover from cell5 to cell3
    Check Counters    ${CELL1_COUNTER}
    [Teardown]    Run Keyword And Ignore Error   All UEs Stop traffic and detach UE

*** Keywords ***
Set cell3 and cell5 PA for attach
    set_pa_values    ${attach_cell3_pa_values}
    set_pa_values    ${attach_cell5_pa_values}

UE2 and UE3 attach cell5
    #Delta_commission_parameters_bts2   ${cell5_nrcarprio_better_than_cell3}
    Delta Commission Parameters    NRCELL-5:administrativeState=Unlocked
	log to console    Unlock cell5
	Wait Until Keyword Succeeds    60s    2s   Object Should Exist  NRCELL-5:administrativeState=Unlocked
    FOR    ${ue}    IN    2    3
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
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue}    get_spark_license=False
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

UE1 attach cell3
	Delta Commission Parameters    NRCELL-5:administrativeState=Locked
	prepare and attach UE     ue=1    attach_cell_id=398

UE1 handover from cell3 to cell5
    log to console    UE1 handover from cell3 to cell5(396)
    #Delta_commission_parameters_bts2   ${cell5_nrcarprio_better_than_cell3}
    set_pa_values    ${set_cell3_pa_bad}
	#Wait Until Keyword Succeeds    120s    2s   Check NR PCI    ue_index=1    cell_pci=396
	Check Tput for one UE     ue=1
	Check Tput for one UE     ue=2
	Check Tput for one UE     ue=3

All UEs handover from cell5 to cell3
   log to console    All UEs handover from cell5 to cell3(398)    
   Set cell3 PA to good and set cell5 to bad
   #Wait Until Keyword Succeeds    120s    2s   Check NR PCI    ue_index=1    cell_pci=398
   #Check NR PCI    ue_index=2    cell_pci=398
   #Check NR PCI    ue_index=3    cell_pci=398
   Check Tput for one UE     ue=1
   Check Tput for one UE     ue=2
   Check Tput for one UE     ue=3

Set cell3 PA to good and set cell5 to bad
    set_pa_values    ${attach_cell3_pa_values}
    set_pa_values    ${set_cell5_pa_bad}

Lock cells and make UE attach cell2
    Delta Commission Parameters   NRCELL-2:administrativeState=Locked
    Delta Commission Parameters   NRCELL-3:administrativeState=Locked
    Delta Commission Parameters   NRCELL-4:administrativeState=Locked
    Delta Commission Parameters   NRCELL-5:administrativeState=Locked

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

Check throughput on gNB
    [Arguments]    ${direction}    ${throughput}    ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}
    ...    ${sample}=${10}    ${start_offset}=${3}    ${sleep_time}=${8}    ${cellid}=${EMPTY}    ${log_type}=Aasyslog    &{kwargs}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2Lo   log_name=data_${direction}.txt
    ${Tput_cell}    run keyword if    '${direction}' == 'dl'    Caculate DL throughput on gnb L2Lo with re
    ...                                                                                       dl_expect=${throughput}
    ...                                                                                       gnb_index=${gnb_index}
    ...                                                                                       du_index=${du_index}
    ...                                                                                       hw_slot=${hw_slot}
    ...                                                                                       sample=${sample}
    ...                                                                                       start_offset=${start_offset}
    ...                                                                                       sleep_time=${sleep_time}
    ...                                                                                       cellid=${cellid}
    ...                                                                                       log_type=${log_type}
    ...    ELSE IF    '${direction}' == 'ul'    Caculate UL throughput on gnb L2Lo with re    ul_expect=${throughput}
    ...                                                                                       gnb_index=${gnb_index}
    ...                                                                                       du_index=${du_index}
    ...                                                                                       hw_slot=${hw_slot}
    ...                                                                                       sample=${sample}
    ...                                                                                       start_offset=${start_offset}
    ...                                                                                       sleep_time=${sleep_time}
    ...                                                                                       cellid=${cellid}
    ...                                                                                       log_type=${log_type}
    [Return]    ${Tput_cell}
    [Teardown]    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}

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
    Common Test Teardown And Stop Capture Logs

Check NR PCI
    [Arguments]    ${ue_index}=${0}    ${cell_pci}=205
    ${param_name_list}    create list     NR PCI
    ${value_list}    spark.get_parm_value_on_ue       ue_alias=UE_${ue_index}    param=${param_name_list}
    Should Be True    ${value_list[0]}==${cell_pci}
