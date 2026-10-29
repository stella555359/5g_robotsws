*** Settings ***
Documentation     author: Frank Luo
...               contact: frank.s.luo@nokia-sbell.com
...               Cases in 5GC000900 that requires one mixed cell and  two UE:
...               Sigspark with two Huawei Mate30 will use for both SA and NSA call, UE mode(SA/NSA) is setup at UE side.
...               ue_index=${0} is SA Mode, ue_index=${1} is NSA Mode
Resource          ../../5GC000496_C/Resources/L3Call.robot
Resource          ../Resources/5GC000900_PowerUE.robot
#Library           taf.ue    WITH NAME    ute_ue
Library           taf.ue.rpc.mtk    WITH NAME	rpc_mtk
Library           taf.ul.messaging.mtk      WITH NAME    mtk_msg
#Variables         ${CFGFILE_PATH}5GC002334/Delta.py
#Variables         ${CFGFILE_PATH}5GC002056-900/Delta.py
#Variables         ${CFGFILE_PATH}TLDelta.py
#Variables         ${CFGFILE_PATH}/5GC000900/Delta_SCF.py


*** Variables ***
${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}
${IMSI}                     ${tl.ues[0].imsi}
${IMSI1}                    ${tl.ues[1].imsi}
#${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
#${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${MRBTS_ID}                  MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                  NRBTS-${tl.gnbs[0].global_bts_id}

${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

#${CFGFILE_PATH}             /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${DeltaPath}                ${CFGFILE_PATH}/5GC000900/Delta_SCF.py
#${CFGFILE_for_case07}       ${CFGFILE_PATH}5GC002334/scf_s11_nsa_both.xml
${Original_CFGFILE}         ${LOG_PATH}/TestLineSCF1Cell_Both.xml

#${GoldenScf_PATH}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG
${UE_alias}                 UE_0

${TLDelta_PATH}              ${CFGFILE_PATH}
${initial_S1_SCF}            ${LOG_PATH}/TestLineSCF1Cell_Both.xml

${AMF_IP}                   ${tl.core.mme_ip}
${5GC_IP}                   ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}             ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}             ${tl.core.default_ssh_connection_details.password}
${ENB_WEBUI_IP}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

##################define these variable for convenient############################
${ALIAS_ASIK}               asik
${ALIAS_ASIK_SLAVE}         asik_slave
${ALIAS_UTE}                ute
${ALIAS_REAL_EPC_SERVER}    Real_EPC
${ALIAS_LONER}              LONER
${ALIAS_ASP_1A}             ASP_1A
${ALIAS_5GC}                5gc
${ALIAS_ENBCTLPC}           ENB_PC
${ALIAS_SHP}                SHP
${ALIAS_E500}               E500
${ALIAS_PRISMA}             Prisma
${AlIAS_QC}                 Qualcomm
${QC_UE_alias}              QC_UE
${MTK_UE_alias}             MTK_UE
########################END of alias Define#######################################

*** Keywords ***
###################################Case Level  Keywords###########################
TC.5GC000900_AA_12_Single_NSA_UE_And_01_Single_SA_UE_Attach_To_DualMode_Cell_With_Mixed_UL_DL
    [Documentation]  Main test Steps:
    ...   1) Wait until Cell on air (NG + X2 all available)
    ...   2) SA L3 Call with UE_0, start DL dnd UL traffic
    ...   3) NSA L3 call with UE_1, start DL dnd UL traffic
    ...   4) Verifiy throughput
    [Arguments]   ${apn_address_SA}=wap1nokiacom   ${apn_address_NSA}=DXMDRB24
    X2 Should Be Ready
    Check if Cell On Air
    Dual_UE_Call_with_traffic_SA_NSA_call     apn_address_SA=${apn_address_SA}       apn_address_NSA=${apn_address_NSA}

TC.5GC000900_A_004_gNB_Shall_Support_SA_Cells_and_NSA_Cells_Together
    [Arguments]   ${apn_address_NSA}=DXMDRB24
#    NSA Cell Should Be On Air With NG Failure Triggered By Unavailable AMF    # temperarily cancelled.
    NSA Cell Should Be On Air With NG Failure Triggered By ACL rule
    wait until keyword succeeds    2x   1min     Both NSA cell and SA cell Should Be On Air
#    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${1}
#    One_UE Call with traffic    ue_index=${1}
#    run keyword and ignore error    Stop UE Traffic    ue_index=${1}
     #delete argument attach_mode=5G_NSA,because spark is not stable with only detach and attach function
    UE.One_UE_Call_with_traffic    ue_index=${1}     imsi=${IMSI1}
    ...    ue_mode=NSA    apn_address=${apn_address_NSA}
    SA Cell Should Be On Air With X2 Failure Triggered By ACL rule
    wait until keyword succeeds    2x   1min     Both NSA cell and SA cell Should Be On Air

TC.5GC000900_AA_05_Single_NSA_UE_And_Single_SA_UE_Attach_To_DualMode_Cell
    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
    run   cp ${CFGFILE_PATH}/SCF_SBTS00.xml ${initial_S1_SCF}
    gNB.ModifySCF    InputFile=${initial_S1_SCF}    OutputFile=${LOG_PATH}/900_AA05_SCF.xml
    ...     ParamterToModify=${PARAMS_TO_MODIFY_900_AA_005}
    GNB.Commissioning   scf_file=900_AA05_SCF.xml   file_path=${LOG_PATH}
#    gNB.CommissionWithRetry    scf_file=${LOG_PATH}/900_AA05_SCF.xml    model=HBTE
    Process.Verify gNB Readiness and Fail Case if Not After Reset
    X2 Should Be Ready
#    gNB.Connect
    Log To Console    Modify paramter to trigger RAT reset
    COAM_WebEM.Login
#    selenium_coam.set_parameter_value    dist_name=MRBTS-10031/NRBTS-10031/NRCELL-1
#    ...    filter_param=Activate PRACH slot uplink channel multiplexing
#    ...    new_value=false   abbr=actPrachMultiplexing
#     selenium_coam.set_parameter_value    dist_name=MRBTS-10031/NRBTS-10031/NRPMRNL-1
#    ...    filter_param=Central unit (CU) traffic measurement
#    ...    new_value=5min   abbr=miNrNTRAF
#    selenium_coam.validate_plan
#    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
#    ...    timeout=600
    COAM_WebEM.SetParameterValue    distName=MRBTS-10031/NRBTS-10031/NRCELL-201
    ...    abbr=Activate PRACH slot uplink channel multiplexing	    value=false
    COAM_WebEM.SetParameterValue    distName=MRBTS-10031/NRBTS-10031/NRCELL-201
    ...    abbr=Frequency band Indicator NR	    value=78
    COAM_WebEM.SetParameterValue    distName=MRBTS-10031/NRBTS-10031/NRPMRNL-1
    ...    abbr=Central unit (CU) traffic measurement	    value=5min
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout
    Process.Verify gNB Readiness and Fail Case if Not After Reset
    sleep    5min
    MultiUE.L3Call  UECFG=${TLCommonConfig['MultiUECFG']}
    sleep    5min
    Log To Console    Compare counters
    COAM_Admin.CompareCounterValue    counter_id=M55131C00001
    COAM_WebEM.Login
    COAM_WebEM.SetParameterValue    distName=MRBTS-10031/NRBTS-10031/NRCELL-201
    ...    abbr=Frequency band Indicator NR	    value=77
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout
    Process.Verify gNB Readiness and Fail Case if Not After Reset
   # MultiUE.L3Call  UECFG=${TLCommonConfig['MultiUECFG']}
#    PowerUE.Reserve UE   ue_index=${0}
#    PowerUE.Reserve UE   ue_index=${1}
#    Dual_UE Call with_traffic
#    Run Keyword And Ignore error    PowerUE.Detach UE  ue_index=${0}    power_reset=True
#    Run Keyword And Ignore error    PowerUE.Detach UE   ue_index=${1}   power_reset=True

TC.5GC000900_B_001_Mixed_Mode_Cell_Setup
    [Documentation]  This purpose of this case is to test the Dual Mode cell setup;
    ...   Main test Steps:
    ...   1) load Dual Mode scf
    ...   2) Wait until Cell on air (NG + X2 all available)
    COAM_WebEM.Login
    ${status}=    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${Original_CFGFILE}
    Should be True    ${status}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}
    ...    timeout=${300}
    X2 Should Be Ready
    Run Keyword And Ignore error    COAM_WebEM.Logout
    Process.Verify gNB Readiness and Fail Case if Not After Reset

TC.5GC000900_B_006_Cell_Reconfiguration_when_Access_Mode_Change_between_SA_and_Mixed
    [Documentation]  The purpose of this test case is to check cell onair and SA UE attach successfully
    ...              when cell deptype change betweeen SA and BOTH mode.
    ...    Main test Steps:
    ...   1) SA scf loded, check cell on air
    ...   2) Switch celldepmode from SA to Both, and check on air.
    ...   3) SA L3 call with DL and UL traffic
    ...   (This step is optional for different case)  4) NSA L3 call with DL and UL traffic
    ...   5) Switch celldepmode from Both to SA, and check on air.
    ...   6) Restart SA L3 call with DL traffic
    [Arguments]   ${NSA_CALL}=False    ${apn_address_SA}=wap1nokiacom   ${apn_address_NSA}=DXMDRB24
     Change Cell Mode from SA to Both
     X2 Should Be Ready
     Check if Cell On Air
#     5GC000900_Resources.UE Attach
     run keyword if       "${NSA_CALL}"=="False"      UE.One_UE_Call_with_traffic     apn_address=${apn_address_SA}
     ...        check_throughput_dl=10    check_throughput_ul=5   check_avg_percent=0.9     min_percent=0.7
     ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
     ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}
     ...      ELSE IF     "${NSA_CALL}"=="True"       Dual_UE_Call_with_traffic_SA_NSA_call
     ...                   apn_address_SA=${apn_address_SA}       apn_address_NSA=${apn_address_NSA}
     Change Cell Mode from Both to SA
     Check if Cell On Air
     sleep   15s
     UE.One_UE_Call_with_traffic    apn_address=${apn_address_SA}    check_throughput_dl=10
     ...       check_throughput_ul=5     check_avg_percent=0.9     min_percent=0.7
     ...    detach_request=${TLCommonConfig["MultiUECFG"]["0"]["detach_request"]}
     ...    power_reset=${TLCommonConfig["MultiUECFG"]["0"]["power_reset"]}

#     5GC000900_Resources.UE Attach

TC.5GC000900_B_007_Cell_Reconfiguration_when_Access_Mode_Change_between_NSA_and_Mixed
    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
    gNB.ModifySCF    InputFile=${initial_S1_SCF}    OutputFile=${LOG_PATH}/900_B07_SCF.xml
    ...     ParamterToModify=${PARAMS_TO_MODIFY_900_B_007}   ParameterToDelete=${PARAMS_TO_DELETE_900_B_007}
    GNB.Commissioning   scf_file=900_B07_SCF.xml   file_path=${LOG_PATH}

    Process.Verify gNB Readiness and Fail Case if Not After Reset
    X2 Should Be Ready
    Change Cell Mode from NSA to Both
    Check if Cell On Air
    PowerUE.Reserve UE   ue_index=${0}
    PowerUE.Reserve UE   ue_index=${1}
    Dual_UE Call with DL traffic
    Change Cell Mode from Both to NSA
    Check if Cell On Air
    One_UE Call with DL traffic   ue_index=${1}    apn_address=${NSA_APN}    ue_mode=NSA
    Run Keyword And Ignore error    PowerUE.Detach UE  ue_index=${0}
    Run Keyword And Ignore error    PowerUE.Detach UE   ue_index=${1}

#TC.5GC000900_B_007_Cell_Reconfiguration_when_Access_Mode_Change_between_NSA_and_Mixed
#    [Documentation]  Main test Steps:  from 900, not runned;
#    ...   1) NSA scf loded, check cell on air
#    ...   2) Switch celldepmode from NSA to Both, and check on air.
#    ...   3) SA L3 call with DL traffic using Huawei SigSpark
#    ...   4) NSA L3 call with DL traffic using Huawei SigSpark
#    ...   5) Switch celldepmode from Both to NSA, and check on air.
#    ...   6) Restart NSA L3 call with DL traffic
##    [Tags]    Classicalbts    Blow6GHz    3GPPDEC   Mixed    TA
##    [Setup]    Setup Case 07
##    [Teardown]    Teardown Case
#    Change Cell Mode from NSA to Both
#    Check if Cell On Air
#    #PowerUE.Reserve UE   ue_index=${0}
#    PowerUE.Reserve UE   ue_index=${1}
#    #Dual_UE Call with_traffic
#    UE.One_UE_Call_with_traffic   ue_index=${1}
#    Change Cell Mode from Both to NSA
#    Check if Cell On Air
#    UE.One_UE_Call_with_traffic   ue_index=${1}
#    #Run Keyword And Ignore error    PowerUE.Detach UE  ue_index=${0}
#    Run Keyword And Ignore error    PowerUE.Detach UE   ue_index=${1}


TC.5GC000900_B_005_Mixed_Mode_Cell_Setup_When_NSA_Succeed_but_SA_Fail
    [Documentation]  Main test Steps:
    ...   1) loded 900 B05 SCF, cell on air but SA cell Degraded
    ...   2) check fault 7316 NgSetupFailure raised
    ...   3) check fault 7103 SA cell activation raised
    ...   4) check NSA UE attach OK and start traffic
    ...   5) check SA UE attach fail
    #COAM_WebEM.VerifyCellOnAir
    Run Keyword And Continue On Failure    wait until keyword succeeds   15x   1min    Check Certain Alarm from Active Alarms
    ...    target_alarm_id=7114    target_fault_id=7107
    ...    target_fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    ${status}   COAM_WebEM.GetCellStatus    cell_idx=${cell_idx_of_900_B5}
    log    ${status}
#    Run Keyword And Continue On Failure    TC.Check_Cell_Status    operationalValue=Enabled    availabilityValue=Degraded
#    ...    administrativeValue=Unlocked    cell_idx=${cell_idx_of_900_B5}    cell_group_idx=${cell_group_idx_of_900_B5}
    Should Be Equal As Strings    ${status['Status']['Operational state']}    enabled    ignore_case=True
    Should Be Equal As Strings    ${status['Status']['Availability status']}    degraded    ignore_case=True
    Should Be Equal As Strings    ${status['Status']['Administrative state']}    Unlocked    ignore_case=True
#    Run Keyword And Continue On Failure    wait until keyword succeeds   6x   1min    Check Certain Alarm from Active Alarms
#    ...    target_alarm_id=7107    target_fault_id=7316    target_fault_name=NgSetupFailure
    @{NSA_UE}    create list    1
    Set To Dictionary    ${TLCommonConfig['MultiUECFG']}    ue_index_for_call     ${NSA_UE}
    MultiUE.L3Call  UECFG=${TLCommonConfig['MultiUECFG']}

    @{SA_UE}    create list    0
    Set To Dictionary    ${TLCommonConfig['MultiUECFG']}    ue_index_for_call      ${SA_UE}
    ${res}    run keyword and ignore error    MultiUE.L3Call  UECFG=${TLCommonConfig['MultiUECFG']}
    should be true    '${res[0]}'!='PASS'
    COAM_WebEM.Login
    COAM_WebEM.SetParameterValue    distName=MRBTS-10031/NRBTS-10031/NRCELL-201
    ...    abbr=Frequency band Indicator NR	    value=77
    run keyword and ignore error    COAM_WebEM.SetParameterValue    distName=MRBTS-10031/NRBTS-10031/SERVEDAMF-1
    ...    abbr=AMF IPv4/v6 Address / FQDN    value=10.110.133.68
    run keyword and ignore error    COAM_WebEM.SetParameterValue    distName=MRBTS-10031/NRBTS-10031
    ...    abbr=NSA cell activation alarm timer    value=600
    run keyword and ignore error    COAM_WebEM.SetParameterValue    distName=MRBTS-10031/NRBTS-10031
    ...    abbr=SA cell activation alarm timer    value=600
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout

#    Clear UE info from AMF with Retry
#    Run Keyword And Continue On Failure    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${0}
#    Run Keyword And Continue On Failure    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${1}
#    UE Attach and Start data transfer with Log Capturing    ue_index=${1}    apn_address=${NSA_APN}    ue_mode=NSA
#    PowerUE.Check Throughput for DL and UL    ue_index=${1}
#    UE Attach and Start data transfer with Log Capturing    ue_index=${0}    apn_address=${SA_APN}    ue_mode=SA
#    ${SA_Check}    run keyword and return status    PowerUE.Check Throughput for DL and UL    ue_index=${0}
#    Run Keyword And Continue On Failure    should be true    '${SA_Check}' == 'False'
#    Run Keyword And Ignore error    PowerUE.Detach UE  ue_index=${0}    power_reset=True
#    Run Keyword And Ignore error    PowerUE.Detach UE   ue_index=${1}   power_reset=True



###################################Case Level  Keywords END###########################################

###################################Cell Level  Keywords ##############################################
Change Cell Mode from NSA to Both
    COAM_WebEM.Login
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1    filter_param=Cell deployment type    new_value=${cellDepType}
    selenium_coam.set_parameter_value     dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1   filter_param=Tracking Area distinguished name
    ...    new_value=${MRBTS_ID}/${NRBTS_ID}/TRACKINGAREA-210
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout
    Check if Cell On Air

Change Cell Mode from Both to NSA
    COAM_WebEM.Login
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1    filter_param=Cell deployment type    new_value=NSA
    selenium_coam.delete_parameter    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1  filter_param=Tracking Area distinguished name
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout
    Check if Cell On Air

Change Cell Mode from SA to Both
    COAM_WebEM.Login
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1    filter_param=Cell deployment type
    ...    new_value=${CASE_INPUT_SPECIFIC['5GC000900']['Cell deployment type']}
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1    filter_param=Configured EPS tracking area code  new_value=100
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout
    Check if Cell On Air

Change Cell Mode from Both to SA
    COAM_WebEM.Login
    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1    filter_param=Cell deployment type   new_value=SA
    selenium_coam.delete_parameter    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1  filter_param=Configured EPS tracking area code
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout
    Check if Cell On Air

Check if Cell On Air
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   5x   2min   COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}    fail    msg=gnb is not on air!

NSA Cell Should be On Air With NG Failure Triggered By ACL rule
    [Documentation]  saCellActivationTimer was set to 60s.
    ...  if the timere changed, chagne the interval and duration of alarm checking accoringly.
    [Teardown]     Apply Drop ACL Rule to Specific Link   link=NG    operation=deactive
    log to console    Trigger NG fail and Check NSA cell Online SA cell Offline
    COAM_WebEM.Login
    COAM_WEBEM.LockUnlcokCell     cell_idx=2    timeout=60    action=lock
    Apply Drop ACL Rule to Specific Link   link=NG    operation=active
    wait until keyword succeeds   6x   1min    Check Certain Alarm from Active Alarms    target_alarm_id=7107
    ...    target_fault_id=7304    target_fault_name=${target_FID7304_name}
    sleep   5min
    COAM_WebEM.Login
    COAM_WEBEM.LockUnlcokCell    cell_idx=2    timeout=60    action=unlock
    wait until keyword succeeds   6x   2min    Check Certain Alarm from Active Alarms    target_alarm_id=7114
    ...    target_fault_id=7103    target_fault_name=${target_FID7103_name}
    #COAM_WebEM.Logout
    wait until keyword succeeds     3x    1min    NSA Online SA Offline
    log to console    Trigger NG fail and Check NSA cell Online SA cell Offline success

SA Cell Should Be On Air With X2 Failure Triggered By ACL rule
    [Documentation]  nsaCellActivationTimer was set to 60s.
    ...  if the timere changed, chagne the interval and duration of alarm checking accoringly.
    [Teardown]     Apply Drop ACL Rule to Specific Link   link=X2    operation=deactive
    log to console    Trigger X2 fail and Check SA cell Online NSA cell Offline
    COAM_WebEM.Login
    COAM_WEBEM.LockUnlcokCell     cell_idx=1    timeout=60     action=lock
    Apply Drop ACL Rule to Specific Link   link=X2    operation=active
    sleep   5min
    COAM_WEBEM.LockUnlcokCell     cell_idx=1    timeout=60     action=unlock
    wait until keyword succeeds   6x   2min    Check Certain Alarm from Active Alarms    target_alarm_id=7114
    ...    target_fault_id=7100    target_fault_name=${target_FID7100_name}
    #COAM_WebEM.Logout
    wait until keyword succeeds     3x    1min    SA Online NSA Offline
    log to console    Trigger X2 fail and Check SA cell Online NSA cell Offline success

Apply Drop ACL Rule to Specific Link
    [Arguments]    ${link}    ${operation}
    [Documentation]  link:  NG or X2,  NG maps to port 38412, and  X2 to 36422
    ...      Operation:   active or deactive.
    ${dport}     Set variable if  '${link}'=='NG'    38412    36422
    ${dport}     Set variable if  '${link}'=='X2'    36422    38412
    ${action}    Set variable if  '${operation}'=='active'    A    D
    ${action}    Set variable if  '${operation}'=='deactive'    D   A
    gNB.Connect
    ssh.execute    command=iptables -t mangle -${action} INPUT -m comment --comment 100 -p sctp --dport ${dport} -j DROP   connection=${ALIAS_ASIK}
    sleep   5s
    gNB.Disconnect

Check Certain Alarm from Active Alarms
     [Arguments]     ${target_alarm_id}    ${target_fault_id}    ${target_fault_name}
    COAM_WebEM.Login
    ${alarm_info}    selenium_coam.get_active_alarm_info
    Set test variable    ${alarm_info}
    ${length}    Get length     ${alarm_info}
    FOR    ${i}    IN RANGE    ${length}
        ${res}    run keyword and return status    Check Certain Alarm  alarm_id=${alarm_info[${i}]['Alarm ID']}
    ...    fault_id=${alarm_info[${i}]['Fault ID']}    fault_name=${alarm_info[${i}]['Fault name']}   target_alarm_id=${target_alarm_id}
    ...    target_fault_id=${target_fault_id}    target_fault_name=${target_fault_name}
        Run Keyword If    ${res}    Exit For Loop
    END
    run keyword if  not ${res}   Fail    Alarm ${target_alarm_id} not found!
    COAM_WebEM.Logout

Check Certain Alarm
    [Arguments]   ${alarm_id}    ${fault_id}    ${fault_name}   ${target_alarm_id}    ${target_fault_id}    ${target_fault_name}
    run keyword and ignore error    should contain   container=${alarm_id}   item=${target_alarm_id}
    Run Keyword And Continue On Failure    should contain   container=${fault_id}   item=${target_fault_id}
    Run Keyword And Continue On Failure    should contain   container=${fault_name}   item=${target_fault_name}

NSA Online SA Offline
    COAM_Admin.Login
    Cell Should Be Online   cell_idx=1    cell_group_idx=0     connection=COAM
    Cell Should Be Offine   cell_idx=2   cell_group_idx=1     connection=COAM
    COAM_Admin.Logout

SA Online NSA Offline
    COAM_Admin.Login
    Cell Should Be Offine   cell_idx=1    cell_group_idx=0    connection=COAM
#    Cell Should Be Online   cell_idx=2    cell_group_idx=1     connection=COAM   # further feature.
    COAM_Admin.Logout

Cell Should Be Online
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   Enabled
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  Online
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  Unlocked

Cell Should Be Offine
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   Disabled
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}   Offline
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  Unlocked

Both NSA cell and SA cell Should Be On Air
     log to console    Check Both NSA cell and SA cell Should Be On Air
     Check if gNB is Cell On Air    failure_msg=gNB is not on air after the 1st comssionning.
     COAM_Admin.Login
     wait until keyword succeeds    4x    2min   Cell Should Be Online   cell_idx=1    cell_group_idx=0     connection=COAM
     wait until keyword succeeds    4x    2min   Cell Should Be Online   cell_idx=2    cell_group_idx=1     connection=COAM
     COAM_Admin.Logout
     log to console    Check Both NSA cell and SA cell Should Be On Air success

Check if gNB is Cell On Air
    [Arguments]   ${failure_msg}=Gnb not on air!
    ${gNB_on_air}    run keyword and return status    wait until keyword succeeds   5x   2min   COAM_VerifyOnAirViaFrontendAndBackend
    run keyword if  not ${gNB_on_air}    fail    msg=${failure_msg}


TC.Check_Cell_Status
    [Arguments]   ${operationalValue}    ${availabilityValue}    ${administrativeValue}    ${cell_idx}=${1}
    ...    ${cell_group_idx}=${0}   ${timeout}=10    ${connection}=COAM
    COAM_Admin.Login
    ${subcell_status}=  Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   ${operationalValue}
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}   ${availabilityValue}
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  ${administrativeValue}
    COAM_Admin.Logout

Unlock Cell
    [Arguments]   ${cell_idx}=1    ${timeout}=300
    ${cell_info}=    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="Locked"    run keywords
    ...    selenium_coam.unlock_cell    cell_idx=${cell_idx}   timeout=${timeout}
    ...    AND    Sleep  4min
    ${cell_info}=    selenium_coam.get_cell_info   cell_idx=${cell_idx}
    should be true    '${cell_info['Status']['Administrative state']}'=="Unlocked"
###################################Cell Level  Keywords END###########################################

###################################UE Operration######################################################

#Dual_UE Call with_traffic
#    [Arguments]
#    Clear UE info from AMF with Retry
#    One_UE Call with traffic    ue_index=${0}
#    One_UE Call with traffic    ue_index=${1}
Dual_UE Call with_traffic
    [Arguments]
    run keyword and ignore error    Clear UE info from AMF with Retry
    UE Attach and Start data transfer with Log Capturing    ue_index=${0}    apn_address=${SA_APN}    ue_mode=SA
    PowerUE.Check Throughput for DL and UL    ue_index=${0}
    UE Attach and Start data transfer with Log Capturing    ue_index=${1}    apn_address=${NSA_APN}    ue_mode=NSA
    PowerUE.Check Throughput for DL and UL    ue_index=${1}
    PowerUE.Check Throughput for DL and UL    ue_index=${0}

Dual_UE Call with DL traffic
    [Arguments]
    Clear UE info from AMF with Retry
    UE Attach and Start data transfer with Log Capturing    ue_index=${0}    apn_address=${SA_APN}    ue_mode=SA
    PowerUE.Check DL Throughput  ue_index=${0}
    UE Attach and Start data transfer with Log Capturing    ue_index=${1}   apn_address=${NSA_APN}    ue_mode=NSA
    PowerUE.Check DL Throughput  ue_index=${1}
    PowerUE.Check DL Throughput  ue_index=${0}
#One_UE Call with traffic
#    [Arguments]   ${ue_index}=${0}
#    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=True
#    sleep     10s
#    ${5Grach_ed}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    power_reset=True
#    power_ue.Verify attach    ue_index=${0}    ue_type=${UE_TYPE}    4G_check=False    5Grach_ed=${5Grach_ed}
#    PowerUE.Start DL Traffic    apn_address=mdrbnokiacom    ue_index=${ue_index}
#    PowerUE.Start UL Traffic    apn_address=mdrbnokiacom    ue_index=${ue_index}
#    sleep  60s
#    PowerUE.Check DL Throughput  ue_index=${ue_index}    throughput=5
#    PowerUE.Check UL Throughput  ue_index=${ue_index}    throughput=2
#    5GC000900_Resources.Stop Traffic  ue_index=${ue_index}
#    Run Keyword And Ignore error    PowerUE.Detach UE  ue_index=${0}    power_reset=True

Dual_UE_Call_with_traffic_SA_NSA_call
    [Arguments]    ${apn_address_SA}=wap1nokiacom       ${apn_address_NSA}=DXMDRB24
    log to console    1. SA UE CALL AND DATA TRANSFER
    UE.One_UE_Call_with_traffic    ue_index=${0}     Traffic_hold=True   imsi=${IMSI}      attach_mode=5G_SA
    ...    ue_mode=SA     apn_address=${apn_address_SA}
    log to console    2. NSA UE CALL AND DATA TRANSFER
    #delete argument attach_mode=5G_NSA,because spark is not stable with only detach and attach function
    UE.One_UE_Call_with_traffic    ue_index=${1}     Traffic_hold=True   imsi=${IMSI1}
    ...    ue_mode=NSA    apn_address=${apn_address_NSA}
    log to console    3. STOP DATA TRANSFER
    power_ue.Stop traffic    ue_type=${UE_TYPE}      direction=dl     ue_index=${0}
    ...                      apn_address=${apn_address_SA}            ue_mode=SA
    power_ue.Stop traffic    ue_type=${UE_TYPE}      direction=ul     ue_index=${0}
    ...                      apn_address=${apn_address_SA}            ue_mode=SA
    power_ue.Stop traffic    ue_type=${UE_TYPE}      direction=dl     ue_index=${1}
    ...                      apn_address=${apn_address_NSA}           ue_mode=NSA
    power_ue.Stop traffic    ue_type=${UE_TYPE}      direction=ul     ue_index=${1}
    ...                      apn_address=${apn_address_NSA}           ue_mode=NSA
    power_ue.UE Detach       ue_type=${UE_TYPE}     power_reset=True  ue_index=${0}
    power_ue.UE Detach       ue_type=${UE_TYPE}     power_reset=True  ue_index=${1}

Stop UE Traffic
    [Arguments]   ${ue_index}=${0}
    ${apn_address}     Set variable if  ${ue_index}==${0}    ${SA_APN}    ${NSA_APN}
    ${ue_mode}    Set variable if  ${ue_index}==${0}    SA    NSA
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=dl    ue_index=${ue_index}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    power_ue.Stop traffic    ue_type=${UE_TYPE}    direction=ul    ue_index=${ue_index}
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}

Stop Traffic
    [Arguments]   ${ue_index}=${0}
    PowerUE.Stop UL Traffic    apn_address=mdrbnokiacom    ue_index=${ue_index}
    PowerUE.Stop DL Traffic    apn_address=mdrbnokiacom    ue_index=${ue_index}

###############################UE Operration END#####################################################

###############################Suite Setup Case Setup################################################
Setup The Suite
    Run Keyword And Ignore Error    Import Variables     ${CFGFILE_PATH}5GC002334/Delta.py
    Run Keyword And Ignore Error    Import Variables     ${CFGFILE_PATH}5GC002056-900/Delta.py
    TestSuite.Start
    Import Variables     ${CFGFILE_PATH}/5GC000900/Delta_SCF.py
    set suite variable     ${DeltaPath}       ${CFGFILE_PATH}/5GC000900/Delta_SCF.py
    Run Keyword And Ignore Error    set suite variable   ${CFGFILE_for_case06}       ${CFGFILE_PATH}5GC002334/scf_s11_sa_both.xml
    Run Keyword And Ignore Error    set suite variable   ${CFGFILE_for_case07}       ${CFGFILE_PATH}5GC002334/scf_s11_nsa_both.xml
#    Reset gNB until Ready
    Run Keyword And Ignore Error     PA.AdjustAttenuationValueByGroups
    Setup Suite
    gNB.FormatBTSID
    gNB.SetLoggingSeverity    LoggingSeverity=debug
#    GNB.SwconfigReplace  file_path=${CFGFILE_PATH}/5GC000900

	Run Keyword And Ignore Error    gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}    TLDelta_PATH=${CFGFILE_PATH}
    ...            TestLineSCF_cell_num=${1}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}

    ${ENB_SCF}     COAM_Admin.GeteNBSCFbyStream    IP=${ENB_WEBUI_IP}
    ENB_Admin.Commission    scf_file=${ENB_SCF}
#    Reserve ue for tests    UE_alias=${QC_UE_alias}    UE_CAPABILITIES=REAL_ANDROID_UE
#   Run Keyword And Ignore Error    Adjust RU1 Attenuation to ${0}
#    Run Keyword And Ignore Error    PA.AdjustAttenuationValueByGroup    PAGroup=${TLCommonConfig['PAGroups']['1']}
#   Run Keyword And Ignore Error    Adjust GNB2_RU1 Attenuation to ${60}

Teardown The Suite
    [Arguments]    ${recover_scf}=no
    TestSuite.Stop
    Teardown Suite
    run keyword if    '${recover_scf}'=='yes'    GNB.Commissioning  scf_file=scf_s1_mixed.xml   file_path=${CFGFILE_PATH}/5GC000900
    Run Keyword And Ignore Error    PA.AdjustAttenuationValueByGroup
#    Adjust RU1 Attenuation to ${0}
#    Run Keyword And Ignore Error    PA.AdjustAttenuationValueByGroup    PAGroup=${TLCommonConfig['PAGroups']['1']}
#    Adjust GNB2_RU1 Attenuation to ${0}

Teardown My Case
    [Arguments]    ${recover_cell}=no    ${recover_scf}=no
    run keyword if    '${recover_cell}'=='yes'        run keywords
    ...    COAM_WebEM.Login
    ...    AND    Unlock Cell
    ...    AND    COAM_WebEM.Logout
    Teardown Case
    run keyword if    '${recover_scf}'=='yes'    GNB.Commissioning  scf_file=scf_s1_mixed.xml

Setup My Suite
    TestSuite.Start
    run keyword and ignore error    Import Variables     ${CFGFILE_PATH}5GC002334/Delta.py
    run keyword and ignore error    Import Variables     ${CFGFILE_PATH}5GC002056-900/Delta.py
    run keyword and ignore error    Import Variables     ${CFGFILE_PATH}/5GC000900/Delta_SCF.py
    Run Keyword And Ignore Error    set suite variable   ${DeltaPath}                ${CFGFILE_PATH}/5GC000900/Delta_SCF.py
    Run Keyword And Ignore Error    set suite variable   ${CFGFILE_for_case06}       ${CFGFILE_PATH}5GC002334/scf_s11_sa_both.xml
    Run Keyword And Ignore Error    set suite variable   ${CFGFILE_for_case07}       ${CFGFILE_PATH}5GC002334/scf_s11_nsa_both.xml
    Run Keyword And Ignore Error    Basic.CheckVariableValid
    ...    var=CASE_INPUT_SPECIFIC['5GC000900']['Cell deployment type']    default_value=both
    Run Keyword And Ignore Error    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
    Run Keyword And Ignore Error    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
    Setup Suite
    gNB.FormatBTSID
    Modify GoldenSCF to TestLineSCF


Modify GoldenSCF to TestLineSCF
    run    cp ${GoldenSCF_ON_GIT}/${GoldenSCF} ${LOG_PATH}/GoldenSCF.xml
    gNB.ReplaceSCFbtsID     SCFFilePath=${LOG_PATH}/GoldenSCF.xml
	...                     MRBTSID=${MRBTS_ID}
    ...                     NRBTSID=${NRBTS_ID}
    gNB.ReplaceDeltaID     DeltaPath=${TLDelta_PATH}/TLDelta.py
    ...                    MRBTSID=${MRBTS_ID}
    ...                    NRBTSID=${NRBTS_ID}
    gNB.ModifySCF    InputFile=${LOG_PATH}/GoldenSCF.xml
    ...              OutputFile=${Original_CFGFILE}
    ...              ParameterToDelete=${TL_PARAMS_TO_DELETE_1CELL}
    ...              MOsToAdd=${TL_ADD_MOS_1CELL}
    ...              ParamterToModify=${TL_PARAMS_TO_MODIFY_1CELL}
    ...              ListParamterToModify=${TL_LIST_PARAMS_TO_MODIFY_1CELL}
    ...              ListToAdd=${TL_LIST_TO_ADD_1CELL}

KW.CaseInit
    TestCase.Start
    Setup Case
    gNB.ReplaceSCFbtsID     SCFFilePath=${Original_CFGFILE}
	...                     MRBTSID=${MRBTS_ID}
    ...                     NRBTSID=${NRBTS_ID}
    gNB.ReplaceDeltaID     DeltaPath=${CFGFILE_PATH}5GC002334/Delta.py
    ...                    MRBTSID=${MRBTS_ID}
    ...                    NRBTSID=${NRBTS_ID}
    gNB.ModifySCF    InputFile=${Original_CFGFILE}
    ...              OutputFile=${CFGFILE_for_case06}
    ...              ParameterToDelete=${PARAMS_TO_DELETE_900B_006}
    ...              ParamterToModify=${PARAMS_TO_MODIFY_900B_006}
    gNB.Commission   scf_file=${CFGFILE_for_case06}
    Process.Verify gNB Readiness and Fail Case if Not After Reset

Setup Case 07
    Setup Case
    gNB.ModifySCF    InputFile=${Original_CFGFILE}
    ...              OutputFile=${CFGFILE_for_case07}
    ...              ParameterToDelete=${PARAMS_TO_DELETE_900B_007}
    ...              ParamterToModify=${PARAMS_TO_MODIFY_900B_007}
    gNB.Commission   scf_file=${CFGFILE_for_case07}
    Process.Verify gNB Readiness and Fail Case if Not After Reset
    X2 Should Be Ready

Setup Case A_4
    log to console    CASE STARTING
    Run Keyword And Ignore Error    TestCase.Start
    BtsLog.StartBTSlogCollection
    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${0}
    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${1}
    gNB.ModifySCF    InputFile=${Original_CFGFILE_2Cell}
    ...              OutputFile=${LOG_PATH}/2056-900_A04.xml
    ...              ParameterToDelete=${PARAMS_TO_Delete_900A_004}
    ...              ParamterToModify=${PARAMS_TO_MODIFY_900A_004}
    gNB.CommissionWithRetry   scf_file=${LOG_PATH}/2056-900_A04.xml    model=HBTE
    wait until keyword succeeds    2x    1min    Both NSA cell and SA cell Should Be On Air

Setup Case AA_12
    log to console    CASE STARTING
    Run Keyword And Ignore Error    TestCase.Start
    BtsLog.StartBTSlogCollection
    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${0}
    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${1}
    gNB.CommissionWithRetry   scf_file=${Original_CFGFILE_1Cell}    model=HBTE
    wait until keyword succeeds    8x    2min    gNB.VerifyOnAirViaOAMUntilReady
    X2 Should Be Ready

Setup Case 06
    log to console    CASE STARTING
    Run Keyword And Ignore Error    TestCase.Start
    gNB.ModifySCF    InputFile=${Original_CFGFILE_1Cell}
    ...              OutputFile=${LOG_PATH}/SCF_2056-900_B06.xml
    ...              ParameterToDelete=${PARAMS_TO_DELETE_900B_006}
    ...              ParamterToModify=${PARAMS_TO_MODIFY_900B_006}
    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${0}
    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${1}
    BtsLog.StartBTSlogCollection
    gNB.CommissionWithRetry   scf_file=${LOG_PATH}/SCF_2056-900_B06.xml    model=HBTE
    Process.Verify gNB Readiness and Fail Case if Not After Reset

Setup Case For B05
    log to console    CASE STARTING
    TestCase.CommonStart
#    ENB.Commissioning    scf_file=TestLineSCFeNB.xml    file_path=${CFGFILE_PATH}
    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
    gNB.ModifySCF    InputFile=${Original_CFGFILE}
    ...              OutputFile=${LOG_PATH}/900_B05_SCF.xml
    ...              ParameterToDelete=${PARAMS_TO_DELETE_900_B_05}
    ...              ParamterToModify=${PARAMS_TO_MODIFY_900_B_05}
    ...              MOsToAdd=${ADD_MOs_900_B_05}    ListToAdd=${ADD_TO_List_900_B_05}
    Run Keyword And Ignore Error    BtsLog.StartBTSlogCollection
    gNB.CommissionWithRetry   scf_file=${LOG_PATH}/900_B05_SCF.xml    model=HBTE
    COAM_WebEM.Login
    COAM_WebEM.SetParameterValue    distName=MRBTS-10031/NRBTS-10031/NRCELL-201
    ...    abbr=Frequency band Indicator NR	    value=78
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout
    wait until keyword succeeds   10x   1min    gNB.VerifyOnAirViaOAMUntilReady


Setup Suite For 2056
    Run Keyword And Ignore Error    TestSuite.Start
    Run Keyword And Ignore Error    Create Log Directories
    gNB.FormatBTSID
    set suite variable   ${OAM_TYPE}    COAM
    Run Keyword And Ignore Error    Basic.CheckVariableValid
    ...    var=CASE_INPUT_SPECIFIC['5GC000900']['Cell deployment type']    default_value=both
    Conn.ResetCache
    Run Keyword And Ignore Error    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${0}
    Run Keyword And Ignore Error    power_ue.Prepare UE   ue_type=${UE_TYPE}  ue_index=${1}
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    ${info}     Basic.GetStreamInfo     vstring=${AF_PATH}
    ${StreamInfo}    convert to string    ${info}
    ${outputfile_1cell}    Run Keyword If    "${StreamInfo}"=="None"    gNB.Generate TL SCF
    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}    TLDelta_PATH=${CFGFILE_PATH}
    ...            TestLineSCF_cell_num=${1}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    ...    ELSE    gNB.Generate TL SCF
    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${info['GoldenSCF']}    TLDelta_PATH=${CFGFILE_PATH}/TLDelta_${info['StreamPrefix']}.py
    ...            TestLineSCF_cell_num=${1}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable    ${Original_CFGFILE_1Cell}    ${outputfile_1cell}
    ${outputfile_2cell}    Run Keyword If    "${StreamInfo}"=="None"    gNB.Generate TL SCF
    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${GoldenSCF}    TLDelta_PATH=${CFGFILE_PATH}
    ...            TestLineSCF_cell_num=${2}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    ...    ELSE    gNB.Generate TL SCF
    ...            GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${info['GoldenSCF']}    TLDelta_PATH=${CFGFILE_PATH}/TLDelta_${info['StreamPrefix']}.py
    ...            TestLineSCF_cell_num=${2}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable    ${Original_CFGFILE_2Cell}    ${outputfile_2cell}
    Run Keyword And Ignore Error    PA_Adjust Attenuation Ports To Same Value
    ...    ports=${PA_PORTS}    value=${120}    attenuator=${PA_INFO}
    Run Keyword And Ignore Error    PA.AdjustTheAttenuationValue
    ...    ports=${PA_PORTS[0]}    value=${0}    attenuator=${PA_INFO}
    Run Keyword And Ignore Error    PA.AdjustTheAttenuationValue
    ...    ports=${PA_PORTS[1]}    value=${0}    attenuator=${PA_INFO}
    Run Keyword And Ignore error   run   command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore error   run   command=killall Xvfb
    Run Keyword And Ignore error   run   command=killall geckodriver
    ENB.Commissioning    scf_file=TestLineSCFeNB.xml    file_path=${CFGFILE_PATH}

PA_Adjust Attenuation Ports To Same Value
    [Arguments]    ${ports}    ${value}    ${attenuator}=${PA_INFO}
    PA.setup_attenuator    attenuator=${attenuator}
    ${length}    Get Length    ${ports}
    FOR    ${i}    IN RANGE    ${length}
        PA_.set_attenuation     port=${ports[${i}]}    value=${value}
        PA_.read_attenuation    port=${ports[${i}]}
    END

COAM_Admin.CompareCounterValue
    [Arguments]    ${counter_id}
    COAM_WebEM.Login
    ${date}   Get Current Date   exclude_millis=True
    ${res}  selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    should be true    max(${values[-1]},${values[-2]})>${values[0]}
    COAM_WebEM.Logout
###############################Suite Setup Case Setup END############################################

###############################Suite Teardown Case Teardown##########################################
KW.CaseDestroy
    [Arguments]
    gNB.Connect
    Run Keyword And Ignore Error     Wireshark.StopCapturingALLlog     # to be combined with the following two
    Run Keyword And Ignore Error     ssh.execute   command=killall -2 tcpdump   connection=${ALIAS_ASIK}
    Run Keyword And Ignore Error     ssh.execute   command=killall -2 tcpdump   connection=${ALIAS_ASIK_SLAVE}
#    Run Keyword And Ignore Error     Check UE status from AMF
#    Run Keyword If Test Failed    Run Keyword And Ignore Error     Collect Snapshot
    Run Keyword And Ignore Error     Stop BTSlogs Collection and get logs
    Run Keyword And Ignore Error    run    sudo mkdir -p -m 777 ${Log_PATH_Artifactory}
    Run Keyword And Ignore Error    run    sudo scp -r ${LOG_PATH}/* ${Log_PATH_Artifactory}
#    Run Keyword If Test Failed    Run Keyword And Ignore Error     Collect gNB Logs
    Run Keyword And Ignore error     selenium_coam.disable_virtual_display
    Run Keyword And Ignore error     Kill Xvfb in UTE
    Run Keyword And Ignore error     force_close_coam_webdriver
    Run Keyword And Ignore error     run    command=killall firefox
    Run Keyword And Ignore error     run    command=killall geckodriver
#    Run Keyword And Ignore error     Clear UE info from AMF with Retry
    Conn.ResetCache
    TestCase.Stop

Teardown Case For 2056
    COAM_WebEM.Login
    Run Keyword And Ignore error    Stop UE Traffic   ue_index=${0}
    Run Keyword And Ignore error    Stop UE Traffic   ue_index=${1}
    Run Keyword And Ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}
    Run Keyword And Ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${1}
    Run Keyword And Ignore Error    COAM_WEBEM.LockUnlcokCell    cell_idx=1    timeout=60
    Run Keyword And Ignore Error    COAM_WEBEM.LockUnlcokCell    cell_idx=2    timeout=60
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    #gNB.Connect
    Run Keyword And Ignore Error    kill GNB wireshark process
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'        Collect logs
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Conn.ResetCache
    log to console    CASE DONE
    Run Keyword And Ignore Error    TestCase.Stop

TestSuilt.Destroy
    TestSuite.Stop

kill GNB wireshark process
    Run Keyword And Ignore Error    ssh.execute    command=killall -2 tcpdump    connection=${ALIAS_ASIK}
    Run Keyword And Ignore Error    ssh.execute    command=lxc-attach -n 0xe004 -- killall -2 tcpdump    connection=${ALIAS_ASIK}

Collect logs
    Run Keyword And Ignore Error    gNB.CollectSnapshot
###############################Suite Teardown Case Teardown END#######################################
