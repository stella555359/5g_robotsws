*** Settings ***
Documentation     author: Frank Luo
...               Group: HGZ_SG1
...               contact: frank.s.luo@nokia-sbell.com

Resource          ../../../../RRM/Hangzhou/5GC000496_C/Resources/L3Call.robot
#Resource          ../../common/made_siso_common.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library           ../../5GC001278/Library/get_bts_info.py    WITH NAME    lib
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf    WITH NAME    scf
Library           XML   WITH NAME    ParseXML
Library           OperatingSystem
Library           Process
Library           Collections
Library           DateTime
Library           String
#Variables         ${CFGFILE_ON_GIT}/CB005864/Delta_SCF.py
#Variables         ${CFGFILE_ON_GIT}/TLDelta.py

*** Variables ***
#${CFGFILE_ON_GIT}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/
#${GoldenSCF_PATH}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/${GoldenSCF}

${TL_DeltaPath}          ${CFGFILE_ON_GIT}/TLDelta.py
${DeltaPath}            ${CFGFILE_ON_GIT}/CB005864/Delta_SCF.py
${initial_S2_SCF}       ${LOG_PATH}/TestLineSCF2Cell_Both.xml

${5GC_IP}         ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}    ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}    ${tl.core.default_ssh_connection_details.password}
${ALIAS_5GC}      5gc

${IMSI}           ${tl.ues[0].imsi}
${IMSI2}          ${tl.ues[1].imsi}

${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}

${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
&{fault_10}                 faultId=${10}    source=RMOD_R-1    severity=Critical    # No connection to unit
${alarm_filter_0}           1807
${alarm_filter_1}           No connection to unit
${CPRI_link_status}         /tmp/CPRI_link.log
${VM_CPRI_link}             /tmp/CPRI/
${vm_path}                  /home/ute/
${create_backup_dir}        backupscf/
${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
#${UE_TYPE}                  huawei
${asik_dir}                 /ffs/run/config/toor4nsn/

${remote_dir}=    /mnt/sw/
${local_dir}=   ${CURDIR}/
${file_name}=    DIR1
${correct_file}=   DIR2
${log_file_name}=   ru_log
${log_remote_dir}=    /ram/
${log_local_dir}=   ${OUTPUT_DIR}/


#@{bandswith}   60   80   100
@{bandswith}    80   100
${cell_index}   1
${dist_name}   MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-${cell_index}

*** Keywords ***
OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Documentation]    *****************
    ...    *****************
    ...    - [TEST PURPOSE] To Verify loop reset BTS--cell can be onair every time with configuring 4CC.
    ...    *******************
    ${fail_index}    Set variable    ${0}
    FOR    ${run_time}    IN RANGE    ${20}
        ${status}    run keyword and return status    BTS reset and check status
        ${fail_index}    Run keyword if    ${status}==${False}    Evaluate    ${fail_index}+1    ELSE    set variable    ${fail_index}
        Exit For Loop if    ${fail_index}==${2}
    END
    Should be true    ${fail_index}<${2}

BTS reset and check status
    Perform BTS Site Reset  download_dir=${TS_CASE_LOG_PATH}
    sleep   10min
    wait until keyword succeeds    5min    30s    Verify all cells should be onair

L3_Call
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${cell_list}    create list    ${cell_id}
         Run Keyword And Continue On Failure  Get UE From Init File and Make call    cell_list=${cell_list}
     ...   ue_num_each_call=1    dl_tp=1000M   ul_tp=50M    duration=${300}  loop_times=5    actual_rate=0.5
#     ...   dl_exp=500    ul_exp=40
    END

Modify RU Version and reboot RU
    [Arguments]  ${ru_index}=1
    Log To Console     Modify RU Version and reboot RU
    Connect to Common Unit Master
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
    ${output}=   csn.execute   command=cat /mnt/sw/DIR1   connection=RU_${ru_index}
    ${match}   ${activeBuild}=   Should Match Regexp   ${output}   activeBuildName=(\\\"[^\\\"]*\\\")
    ${modified_build}=   set variable  1${activeBuild}
    csn.execute   command=sed -i s/${activeBuild}/${modified_build}/g /mnt/sw/DIR1   connection=RU_${ru_index}
    csn.execute   command=cat /mnt/sw/DIR1   connection=RU_${ru_index}
    csn.send_command   command=Reboot   connection=RU_${ru_index}
    run keyword and ignore error  csn.disconnect   connection=RU_${ru_index}

Change RU Verison to original one and reboot RU
    [Arguments]  ${ru_index}=1
    Log To Console    Change RU Verison to original one and reboot RU
    ${error_file}=   set variable   ${remote_dir}${file_name}
    ${correct_file}=  set variable   ${remote_dir}${correct_file}
    Connect to Common Unit Master
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
    Write   \\cp ${correct_file} ${error_file}
    Read Until  expected=$
    Write   reboot

Change Bandwith
    [Documentation]   chbw change in webui
    [Arguments]   ${new_band}
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    ${dist_name_1}   Set Variable   ${tl.gnbs[0].global_bts_id}/${tl.gnbs[0].instance_id}/NRCELL-${1}
    ${dist_name_2}   Set Variable   ${tl.gnbs[0].global_bts_id}/${tl.gnbs[0].instance_id}/NRCELL-${2}
    ${curr_band_1}   selenium_coam.Get Parameter Value   dist_name=${dist_name_1}   filter_param=Channel bandwidth
    ${curr_band_2}   selenium_coam.Get Parameter Value   dist_name=${dist_name_2}   filter_param=Channel bandwidth
    Return From Keyword If   '${new_band}MHz'=='${curr_band_1}'  and  '${new_band}MHz'=='${curr_band_2}'
    COAM_WebEM.ModifyParameters   dist_name=${dist_name_1}   filter_param=Channel bandwidth   new_value=${new_band}MHz
    COAM_WebEM.ModifyParameters   dist_name=${dist_name_2}   filter_param=Channel bandwidth   new_value=${new_band}MHz
    COAM_WebEM.ValidateAndActiveParameters
    Wait until keyword succeeds    20 min    20 sec    COAM Check GNB cell on air
    Wait until keyword succeeds    10 min    20 sec   verify all cells should be onair
    [Teardown]   Run Keyword and Ignore Error   COAM_WebEM.Logout

COAM_WebEM.Login
    [Documentation]   parameter should be ${True} or ${False}
    [Arguments]      ${virtual_enable}=${TRUE}
    run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    ${WEBUI_URL}    ${WEBUI_USER}    ${WEBUI_PASSWORD}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock
    sleep    15s

COAM_WebEM.ModifyParameters
    [Arguments]    ${dist_name}=MRBTS-1907/NRBTS-7/NRCELL-1    ${filter_param}=Timer t301    ${new_value}=600ms
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value
    ...    dist_name=${dist_name}    filter_param=${filter_param}    new_value=${new_value}

COAM_WebEM.ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    #${error}    selenium_megazone.get_validation_error
    #log    ${error}
    #should be empty    ${error}
    Run Keyword If    '${activate_plan_despite_errors}'=='True'   selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE      selenium_coam.activate_plan

COAM_WebEM.Logout
    [Arguments]     ${virtual_disable}=${TRUE}
    selenium_coam.logout
    run keyword if      ${virtual_disable}    selenium_coam.disable_virtual_display

General_SiSo_LED_states_management_additional_scenarios
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify that LEDs on radio module works as specified.
    ...    ******************
    ...     Owner: Luo Frank    Zhu Jianhua   SG1
    [Arguments]  ${ru_index}=1
    log to console    \n Trigger Alarm 1937
    Modify Tdanger Value In Json File    init_value=${Tdanger_init}    target_value=${Tdanger_target}    cmd=touch
    log to console   \n Check Alarm 1937 Appear On WebEM
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=1937
    ${led_status_list}   create list   YELLOW OFF   YELLOW YELLOW
    Check LED Status In RU Log    ${led_status_list}   ru_index=${ru_index}
    log to console    \n Recovery Alarm 1937
    Modify Tdanger Value In Json File    init_value=${Tdanger_target}    target_value=${Tdanger_init}    cmd=rm -rf
    log to console    \n Check Alarm 1937 Disappear On WebEM
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1937
    Wait Until Keyword Succeeds    10min    30s    COAM Check GNB cell on air
    Remove Values From List    ${led_status_list}   YELLOW YELLOW
    append to list   ${led_status_list}  GREEN GREEN
    Check LED Status In RU Log    ${led_status_list}   ru_index=${ru_index}

OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI
    [Documentation]    *****************
    ...    *****************
    ...    - [TEST PURPOSE] To Verify loop reset RU--cell can be onair and l3call is ok every time
    ...    *******************
    ${fail_index}    Set variable    ${0}
    FOR    ${run_time}    IN RANGE    ${34}
        ${status}    run keyword and return status    RU reset and check status
        ${fail_index}    Run keyword if    ${status}==${False}    Evaluate    ${fail_index}+1    ELSE    set variable    ${fail_index}
        Exit For Loop if    ${fail_index}==${2}
    END
    Should be true    ${fail_index}<${2}

RU reset and check status
    [Arguments]  ${gnb_type}='NSA'
    Perform RU Reset    ru_index=${1}   download_dir=${TS_CASE_LOG_PATH}
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${sleep_time}       Evaluate    ${X2_link_shutdown_time}-1
    run keyword if  ${gnb_type}=='NSA'
    ...    run keywords  sleep    ${sleep_time}min   AND
    ...    Wait For Expect Fault Present  faultId=7300   timeout=500
    Wait Until Keyword Succeeds  10min    20 sec   COAM Check GNB cell on air
    Wait Until Keyword Succeeds  5min    20 sec   Verify all cells should be onair
    run keyword if   ${gnb_type}=='NSA'
    ...  Wait until keyword succeeds  6min  20sec  Expect Fault Should Absent    faultId=7300
    Run keyword if  ${gnb_type}=='NSA'   Wait Until Keyword Succeeds  5min    20 sec   COAM Check X2 link status from GNB
#    L3_Call_2UE
    [Teardown]  COAM selenium logout

SigSpark_Dual_UE attach and ULDL traffic
    [Arguments]    ${ue_type}=${UE_TYPE}
    Run Keyword And Continue On Failure   Clear UE info from AMF    ue_imsi=${IMSI}
    Run Keyword And Continue On Failure   Clear UE info from AMF    ue_imsi=${IMSI2}
    Run Keyword And Continue On Failure   power_ue.UE Attach    ue_type=${ue_type}     ue_index=${0}
    sleep    5s
    Run Keyword And Continue On Failure   power_ue.Verify attach    ue_type=${ue_type}    ue_index=${0}
    Run Keyword And Continue On Failure   power_ue.Start traffic    ue_type=${ue_type}    ue_index=${0}
    ...    apn_address=${NSA_APN}    ue_mode=NSA    direction=dl    throughput=1100MKbits/sec    duration=600
    Run Keyword And Continue On Failure   power_ue.Start traffic    ue_type=${ue_type}    ue_index=${0}    direction=ul
    ...    apn_address=${NSA_APN}    ue_mode=NSA     throughput=50MKbits/sec    duration=600
    Run Keyword And Continue On Failure   power_ue.UE Attach    ue_type=${ue_type}     ue_index=${1}
    sleep    5s
    Run Keyword And Continue On Failure   power_ue.Verify attach    ue_type=${ue_type}    ue_index=${1}
    Run Keyword And Continue On Failure   power_ue.Start traffic    ue_type=${ue_type}    ue_index=${1}    direction=dl
    ...    apn_address=${NSA_APN}    ue_mode=NSA    throughput=1100MKbits/sec    duration=600
    Run Keyword And Continue On Failure   power_ue.Start traffic    ue_type=${ue_type}    ue_index=${1}    direction=ul
    ...    apn_address=${NSA_APN}    ue_mode=NSA     throughput=50MKbits/sec    duration=600
    sleep    30
    Run Keyword And Continue On Failure   power_ue.Check throughput    ue_type=${ue_type}   ue_index=${0}   direction=dl
    ...    throughput=900
    Run Keyword And Continue On Failure   power_ue.Check throughput    ue_type=${ue_type}    ue_index=${0}    direction=ul
    ...    throughput=45
    Run Keyword And Continue On Failure   power_ue.Check throughput    ue_type=${ue_type}    ue_index=${1}    direction=dl
    ...    throughput=900
    Run Keyword And Continue On Failure   power_ue.Check throughput    ue_type=${ue_type}    ue_index=${1}    direction=ul
    ...    throughput=45

## SigSpark Specific##
PowerUE.Reserve UE
    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${capatibility_index}=${0}
    ...            ${reset_sol}=none    ${detach_request}=${true}
    [Timeout]      10min
    power_ue.Prepare UE   ue_type=${UE_TYPE}   ue_index=${ue_index}    ue_alias=${ue_alias}    capatibility_index=${capatibility_index}
    ...            reset_sol=${reset_sol}   detach_request=${detach_request}

PowerUE.Detach UE
    [Documentation]   applicalbe for Huawei SigSpark using the common-lib of PowerUE
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${power_reset}=False
    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}    ue_alias=${ue_alias}    power_reset=${power_reset}

###AMF operation###
Connect to 5GC
    csn.connect to    hostname=${5GC_IP}   username=${5GC_USERNAME}    password=${5GC_PASSWORD}    alias=${ALIAS_5GC}

Disconnect from 5GC
    csn.disconnect    connection=${ALIAS_5GC}

Clear UE info from AMF
   [Arguments]  ${ue_imsi}=${IMSI}   ${retry_times}=2
   Connect to 5GC
   ${imsi_presence}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi} 2> /dev/null| head -n 7 | grep GENERALINFO
   ...    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    csn.execute   command=cmm subscriber delete --imsi ${ue_imsi}    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    sleep   2min    # WA, make IMSI clear opeation is done completely.
   Disconnect from 5GC
