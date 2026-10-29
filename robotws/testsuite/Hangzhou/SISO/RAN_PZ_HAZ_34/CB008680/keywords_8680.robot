*** Settings ***
Documentation     author: Yang Liqin
...               contact: liqin.yang@nokia-sbell.com
...               squad group: MMW_SG_05
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           DateTime

Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/wireshark_for_5gClassicalBTS.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Power_Meter_counter_update_for_energy_consumption.robot
Resource    ${BASIC_PATH_5G}/General_Amber_Feature_parameter_actMicroDtx_migration_check.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/CB006277-PhaseF/resource/CB006277-F_common_resource.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_Climate_profile_configuration.robot
#Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Library    taf.selenium.sbts    WITH NAME    selenium_sbts
Library    taf.transport.ssh    WITH NAME    csn
Variables   ${CURDIR}/8680_variable.py
Library    ${CURDIR}/8680_variable.py
Library    ${CURDIR}/variables_8562.py
Variables     ${CURDIR}/variables_8562.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/admin_sbts.robot
Variables    ${CURDIR}/env.py
Library     taf/rfrl/csv4all/CSV4AllTestCases.py
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/UUF/UUF_common_keywords.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
# Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot

*** Variables ***
${PATH_Storage}    /home/ute/CB008680
#@{RMOD_LIST}            ENERGY_EFFICIENCY/RMOD/RMOD_R-1
${WAIT_TIME}            20
${ADV_PS}               0.09
${ERROR_RANGE}          0.05
${ultp}          0.85
${dltp}          0.85
#${ue_type}    huawei
${ue_index}    ${0}
${file_Storage}    /home/ute/CB008680/download
${UUF_path}  /home/ute/UUF_SW/SBTS
${attach_cell_id}    0
${UL_DL_TP_Change}    0.1
${BTSID}    MRBTS-${tl.gnbs[0].instance_id}
${INSID}        ${BTSID}/NRBTS-${tl.gnbs[0].global_bts_id}
${WEBUI_ADDR}   ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}   ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}

#${SHERPA_LOG_PATH}          /home/ute/sherpa_log/
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}            ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}            ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${PA1_INFO}                 ${tl.attenuators[0]}
${ALIAS_ASIK}               asik
${ALIAS_ASIK_SLAVE}         asik_slave
#${SWCONFIG_DEFAULT_FILE_PATH}       ${CURDIR}/Configuration/swconfig_base.txt

${TS_LOG_PATH_BASE}    ${output_dir}
${dcap_ip}     10.101.60.55
#${dcap_ip}     ${tl.test_pcs[2].default_ssh_connection_details.addr}
${dcap_port}    443

${mrbtsID}      ${tl.gnbs[0].instance_id}
${nrbtsID}      ${tl.gnbs[0].global_bts_id}
${cell_index}        1
${blocksum}             0
${unblocksum}             0
${connection}        GNB_OAM

${sleep}      AWAKE

${sbts_addr}        ${WEBUI_IP}
${http_username}    ${WEBUI_USERNAME}
${http_password}    ${WEBUI_PASSWORD}
&{fault_6450}       faultId=${6450}
&{fault_4527}       faultId=${4527}
&{fault_6327}       faultId=${6327}
&{fault_61652}       faultId=${61652}
&{fault_61524}       faultId=${61524}
&{fault_4654}       faultId=${4654}
&{fault_4655}       faultId=${4655}
&{fault_7319}       faultId=${7319}
&{fault_7300}       faultId=${7300}
@{ALLOWED_FAULT}    &{fault_61652}    &{fault_61524}  &{fault_4654}    &{fault_4655}  &{fault_7319}  &{fault_7300}  &{fault_6450}
${package_link}   https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/

${path_to_svn_factory}    https://svne1.ext.net.nokia.com/isource/svnroot/BTS_D_RF_6/CTA6/tags/
${path_to_svn}    https://svne1.ext.net.nokia.com/isource/svnroot/BTS_D_RF_10/CTA6/tags/
${serial_number}  1M212306543
${RF_temperature_high_threshold}  ${120}
${BSR_package_3840}  BSR_AQQQA_6_H6_ALN60_ARP60_P00_COVE3840_00424_00001
${BSR_package_3500}  BSR_AQQQA_6_H6_ALN60_ARP60_P00_COV3500_00424_00001
${bsr_url}  https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/tools/Pz3SG05/
${bsr_file1}  BSR_AQQQA_6_H6_ALN60_ARP60_P00_COV3500_00424_00001.zip
${bsr_file2}  BSR_AQQQA_6_H6_ALN60_ARP60_P00_COVE3840_00424_00001.zip

@{customers}             Generic
${runs_of_uuf_upgrade_withcall}   ${1}
${runs_of_uuf_reset_withcall}     ${2}
@{critical_faults}       10    16    1806    1868    4341    4352    4383
${is_enb_test}     False
${disable_syslog_check}    True
${remote_node_update}    False
${should_be_reported}    ${False}
@{TEMPORARY_ALLOWED_FAULTS}

${cloud_ute_directory}  /home/ute/.ute-ca/cache/bts
@{SW_Release}  SBTS25R1  SBTS25R2
*** Keywords ***
Test Case Setup
    [Arguments]     ${case_name}
    ${TS_CASE_LOG_PATH}    catenate     SEPARATOR=/    ${PATH_Storage}    ${case_name}
    Set Test Variable    ${TS_CASE_LOG_PATH}
    Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/${case_name}
    Test Case Setup siso

    #Run keyword If    ${onair_status}==${False}    Perform BTS Site Reset
    #COAM Wait for gnb ready and cell setup    timeout=20 min

    #scf commission and wait for on-air
    #CI_interface.Common Suite Setup

    #Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}    file_path=${TS_CASE_LOG_PATH}


Test Case Setup siso
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${onair_status}    Run keyword and Return Status    COAM Check GNB cell on air
    ${exist_fault}    coam_gnb_classical.COAM Get active alarms
    ${ALLOWED_FAULT}    Copy List    ${exist_fault}
    Set test variable    ${ALLOWED_FAULT}
    add fault to the allowed fault list    faultId=${4592}
    ${exist_fault}    Copy List    ${ALLOWED_FAULT}
    Set test variable    ${exist_fault}

Test Case Teardown
    #Run keyword And Ignore Error    UE Dettach and Stop traffic     ue_index=${0}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds  10min  20 sec  COAM Check X2 link status from GNB
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}    file_path=${TS_CASE_LOG_PATH}
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api  timeout=900
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections
    #Run Keyword If Test Passed  Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True

scf commission and wait for on-air numOfSegment0
    ${var_status}    ${ci_var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ...    gnb_index=${0}   du_index=${0}    common_unit_index=${0}

    run keyword if      '${ci_var_dict}[testline]'=='7_5_UTE5G402T1913'
    ...    scf commission New  scf_name=SCF_SBTS00_numOfSegment0_1913.xml
    ...    ELSE IF   '${ci_var_dict}[testline]'=='7_5_UTE5G402T1914'
    ...    scf commission New  scf_name=SCF_SBTS00_numOfSegment0_1914.xml
  ...    ELSE IF   '${ci_var_dict}[testline]'=='7_5_UTE5G402T2008'
  ...    scf commission New  scf_name=SCF_SBTS00_numOfSegment0_2008.xml

scf commission and wait for on-air Eirpcontrol
    ${var_status}    ${ci_var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ...    gnb_index=${0}   du_index=${0}    common_unit_index=${0}

    run keyword if      '${ci_var_dict}[testline]'=='7_5_UTE5G402T1913'
    ...    scf commission New  scf_name=SCF_SBTS00_1913.xml
    ...    ELSE IF   '${ci_var_dict}[testline]'=='7_5_UTE5G402T1914'
    ...    scf commission New  scf_name=SCF_SBTS00_1914.xml
  ...    ELSE IF   '${ci_var_dict}[testline]'=='7_5_UTE5G402T2008'
  ...    scf commission New  scf_name=SCF_SBTS00_2008.xml


scf commission and wait for on-air cell-add-delete
    ${var_status}    ${ci_var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ...    gnb_index=${0}   du_index=${0}    common_unit_index=${0}

    run keyword if      '${ci_var_dict}[testline]'=='7_5_UTE5G402T1913'
    ...    scf commission New  scf_name=SCF_SBTS00_1913.xml
    ...    ELSE IF   '${ci_var_dict}[testline]'=='7_5_UTE5G402T1914'
    ...    scf commission New  scf_name=SCF_SBTS00_1914.xml
  ...    ELSE IF   '${ci_var_dict}[testline]'=='7_5_UTE5G402T2008'
  ...    scf commission New  scf_name=SCF_SBTS00_2008.xml

scf commission New
    [Arguments]    ${scf_name}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_name}    timeout=${600}    is_pdl_checking_needed=${False}
    sleep    3min
    Wait Until Keyword Succeeds    15min    20s    COAM Check GNB cell on air
    COAM Teardown gnb connections

Suite Case Setup
    Run Keyword And Ignore Error    coam.teardown
    android_ue.Kill ADB application
#    log to console    Common Suite Setup
#    wait until keyword succeeds    3x    20min     CI_interface.Common Suite Setup

    ${ue_type}    translate power ue type from testline    ${ue_index}
    set suite variable  ${ue_type}

    power_ue.Prepare UE      ue_index=${ue_index}    ue_type=${ue_type}
    Run keyword And Ignore Error    UE Dettach and Stop traffic     ue_index=${ue_index}
    log to console  Get Active SW Version
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream1}    set variable     ${split_version}[0]
    ${download_build}  Run Keyword If  ${Active_SW_version.count('ENB_9999')}>0  Replace String    ${Active_SW_version}
    ...  ${stream1}    SBTS00
    ...  ELSE     Set Variable   ${Active_SW_version}
    set suite variable      ${Active_SW_version}
    set suite variable    ${download_build}
    ${stream}    Set Variable If    ${Active_SW_version.count('ENB_9999')}>0    SBTS00    ${stream1}
    ${release}  Run Keyword And Return Status  Should Not Contain  ${SW_Release}  ${stream}
    set suite variable  ${stream}
    set suite variable  ${release}
    Get physCellId

    [Teardown]  run keyword and ignore error    COAM Teardown gnb connections

Get physCellId
    taf_coam.COAM Login
    ${physical_0}  taf_coam.COAM Get Parameter Value  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1   parameter=physCellId
    ${physical_1}  taf_coam.COAM Get Parameter Value  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2   parameter=physCellId
    set suite variable    ${physical_0}
    set suite variable    ${physical_1}
    [Teardown]  taf_coam.COAM Logout

Suite Case Teardown
    log to console    Common Suite Setup
    #CI_interface.Common Suite Setup

Manual_Siso_PM_5G_uDTX
    Get physCellId
    ${dist_name_1}    BuiltIn.Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1
    #scf.Activate Parameter Value    dist_name=${dist_name_1}    p_name=administrativeState    new_value=Locked
    wait until keyword succeeds    3x    5min     Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify power meter for RU on WebUI
    log to console   \n disable Power Saving mode
    Modify and Check RMOD Power Parameter    power_status=false
    sleep   300s
    log to console   \n get the values of RU power consumption with uDTX disabled on OnAir state
    ${power_dic1}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=15min
    log to console   \n enable Power Saving mode
    Modify and Check RMOD Power Parameter    power_status=true
    sleep   300s

    log to console   \n get the values of RU power consumption with uDTX enabled on OnAir state
    ${power_dic2}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=15min
    Run Keyword And Continue On Failure  Check DTX Power Change    power_off=${power_dic1}    power_on=${power_dic2}
    ${ul_tp_power_on}  ${dl_tp_power_on}  UE Attach and Start traffic   attach_mode=5G_SA
    # UE Dettach and Stop traffic
    log to console   \n disable Power Saving mode
    Modify and Check RMOD Power Parameter    power_status=false
    sleep   300s

    log to console   \n get the values of RU power consumption with uDTX disabled on OnAir state
    ${power_dic3}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=15min
    Run Keyword And Continue On Failure  Check DTX Power Change    power_off=${power_dic1}    power_on=${power_dic3}  is_same_settings=true
    ${ul_tp_power_off}  ${dl_tp_power_off}  UE Attach and Start traffic   attach_mode=5G_SA
    # UE Dettach and Stop traffic
    Run Keyword And Continue On Failure  Check DTX TP Change    power_off_TP=${ul_tp_power_off}    power_on_TP=${ul_tp_power_on}
    Run Keyword And Continue On Failure  Check DTX TP Change    power_off_TP=${dl_tp_power_off}    power_on_TP=${dl_tp_power_on}

    [Teardown]  Run keywords  Run Keyword And Ignore Error  Selenium Logout And Close Browser  AND  Run keyword and ignore error
    ...    scf.Activate Parameter Value    dist_name=${dist_name_1}
    ...    p_name=administrativeState    new_value=Unlocked  AND  log to console    Common Suite Setup
    ...  AND  CI_interface.Common Suite Setup

UE Dettach and Stop traffic
    [Arguments]    ${ue_index}=${0}
    Log To Console    \n UE Dettach and Stop traffic

    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}
    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_index}
Check DTX Power Change
    [Arguments]    ${power_off}    ${power_on}  ${is_same_settings}=false
    log to console  Check DTX Power Change
    ${power_change}    Evaluate    (${power_off}-${power_on})/${power_off}
    Run Keyword If    '${is_same_settings}'=='false'    Should Be True    ${power_change}>${ADV_PS}
    ...    ELSE    Should Be True    ${power_change}<${ERROR_RANGE}

Check DTX TP Change
    [Arguments]    ${power_off_TP}    ${power_on_TP}
    log to console  Check DTX Power Change
    ${TP_change}    Evaluate    (${power_off_TP}-${power_on_TP})/${power_off_TP}
    Should Be True    ${TP_change}<${UL_DL_TP_Change}

Barred nr cell
    [Arguments]  ${cell_idx}=${2}  ${barred_value}=barred
    Log To Console    Perform cell-${cell_idx} barred
    scf.Activate Parameter Value
      ...  dist_name=${INSID}/NRCELL-${cell_idx}    p_name=cellBarred  new_value=${barred_value}

Unbarred nr cell
    [Arguments]  ${cell_idx}=${2}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Log To Console    Perform cell-${cell_idx} notbarred
    scf.Activate Parameter Value
      ...  dist_name=${INSID}/NRCELL-${cell_idx}    p_name=cellBarred  new_value=notBarred

Reboot UE If no UE IP
    [Arguments]  ${ue_index}=${0}  ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send command    command=adb -s ${serial_number} shell svc data enable
    ...    connection=cygwin
    ...    timeout=15
    ${status}  Run Keyword And Return Status  Verify UE detach successfully for commerical UE  ue_index=${ue_index}
    Run Keyword If  ${status}  Run Keywords  Log To Console  Reboot UE If no UE IP
    ...  AND  keywords_8680.Andriod UE adb reboot  ue_index=${ue_index}
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cygwin

Andriod UE adb reboot
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    keywords_8680.ADB reboot ue    ue_index=${ue_index}   serial_number=${serial_number}
    Log to console    wait for adb startup
    BuiltIn.sleep    30s
    keywords_8680.Check UE device exist1    ue_index=${ue_index}


Connect to control pc enhanced1
    [Documentation]  This keyword's is to connect to the UE control PC, add WA to restart the ssh servers.
    [Arguments]    ${ue_index}=${0}
    ...             ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...             ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...             ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ${cpc_status}    run keyword and return status
    ...              Connect to control pc    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}    alias=cpc_${ue_index}

ADB Reboot UE
    [Documentation]  Use adb command to reboot the android ue device
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    keywords_8680.Connect to control pc enhanced1    ${ue_index}
    csn.execute    command=adb -s ${serial_number} reboot   connection=cpc_${ue_index}
    csn.disconnect   connection=cpc_${ue_index}
    sleep    10s


Check UE device exist1
    [Documentation]   Check the UE device is connect to control pc normally.
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    keywords_8680.Connect to control pc enhanced1    ${ue_index}
    wait until keyword succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}    serial_number=${serial_number}
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cpc_${ue_index}


UE Attach and Start traffic
    [Arguments]     ${cell_used_in_test}=None  ${remote}=${False}  ${duration}=1200  ${attach_mode}=5G_SA
    ...    ${physCellId}=${physical_0}    ${ue_index}=${0}
    ...    ${actCarrierAggregation}=${False}  ${cell_id}=${attach_cell_id}  ${barred}=${True}
    Run Keyword If  ${barred}  Barred nr cell
    ${lnrel_dist_exists}=  Run keyword and return status  Variable Should Exist  ${lnrel_dist}
    Run keyword if  '${lnrel_dist_exists}'=='${True}' and '${attach_mode}'=='5G_SA' and ${barred}
    ...  Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=locked
    sleep    60s
    log  ${cell_used_in_test}
    log  ${remote}
    log to console  UE Attach and Start traffic
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}    ue_index=${ue_index}  pci=${physCellId}
    Run Keyword If  ${barred}  keywords_8680.Reboot UE If no UE IP
    ${iperf_type}  set variable if  '${ue_type}'=='huawei' or '${ue_type}'=='nokia_fastmile'  via_app  via_command
    # Run Keyword If  ${barred}
    power_ue.Start traffic  ue_type=${ue_type}  direction=dl  throughput=150M  duration=${duration}
    ...    ue_index=${ue_index}    iperf_type=via_command
    # ...  ELSE  power_ue.Start traffic  ue_type=${ue_type}  direction=dl  throughput=150M  duration=${duration}
    # ...    ue_index=${ue_index}
    #...    ue_index=${ue_index}    iperf_type=via_app
#    Wait until keyword succeeds    2X  30s  Verify attach by adb    physCellId=${physCellId}    attach_mode=${attach_mode}
#    ...    ue_index=${ue_index}
    power_ue.Start traffic  ue_type=${ue_type}  direction=ul  throughput=20M  duration=${duration}
    #...    ue_index=${ue_index}    iperf_type=via_app
    ...    ue_index=${ue_index}    iperf_type=${iperf_type}
    sleep  2

    Connect to gnb coam via ssl
    ${list_of_cell_ids}  Get List of NR Cell ID
    ${cell_list}  create list
    Run keyword If  ${actCarrierAggregation} == ${False}  Run keywords
    ...  Append To List  ${cell_list}  ${list_of_cell_ids}[${cell_id}]  AND
    ...  set suite variable  ${list_of_cell_ids}  ${cell_list}

    ${log}    power_ue.Collect Tput  check_source=Aasyslog  ue_type=${ue_type}    duration=2m
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
    ...    ultarget_throughput=${ultp}    dltarget_throughput=${dltp}    actCarrierAggregation=${actCarrierAggregation}
    ...    min_percent=0
    ${ul_average}  ${dl_average}  Get UL and DL Average Value  ${all_tp}
    run keyword and ignore error  Get nrCellIdentity for SA UE  nrCId=${list_of_cell_ids}[0]
    [Return]  ${ul_average}  ${dl_average}
    [Teardown]    Run Keywords  Run Keyword And Ignore Error  Run Keyword If  ${barred}  Unbarred nr cell
    ...  AND  Run Keyword And Ignore Error  Run keyword if  '${lnrel_dist_exists}'=='${True}' and ${barred}
    ...  Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=unlocked
    ...  AND  sleep    60s
    # ...  AND  Run Keyword And Ignore Error  COAM Teardown gnb connections
    ...  AND  UE Dettach and Stop traffic    ue_index=${ue_index}
    ...  AND  Run Keyword If  ${barred}  Connect to gnb coam via ssl

Get UL and DL Average Value
    [Documentation]     Get average number and print
    [Arguments]       ${all_tp}
    ${x1}=  Get From List  ${all_tp}  0
    ${x3}=  Get From List  ${x1}  0
    ${ul_average}=  Get From Dictionary    ${x3}    average
    Log to console   The UL average result is ${ul_average}
    ${x2}=  Get From List  ${all_tp}  1
    ${x4}=  Get From List  ${x2}  0
    ${dl_average}=  Get From Dictionary    ${x4}    average
    Log to console   The DL average result is ${dl_average}
   [Return]  ${ul_average}  ${dl_average}

Modify and Check RMOD Power Parameter
    [Arguments]    ${power_status}=true
    ${status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission
    ...    abbr=actMicroDTX
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission  p_name=actMicroDTX  value=${power_status}
    append to list  ${modify_params}  ${item}
    ${result}  Run Keyword And Return Status  Should Not Contain Any  ${stream}  SBTS23R3  SBTS23R2
    ${item1}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission advanced  p_name=actMicroDTXAdvanced  value=${power_status}
    Run Keyword If  ${result}  append to list  ${modify_params}  ${item1}
    ${status1}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission advanced
    ...    abbr=actMicroDTXAdvanced
    ${item2}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based mMIMO TX power saving  p_name=actNrLBmMimoRTXPowerSaving  value=${power_status}
    Run Keyword If  ${result}  append to list  ${modify_params}  ${item2}
    ${status2}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based mMIMO TX power saving
    ...    abbr=actNrLBmMimoRTXPowerSaving
  ${item3}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR cell-level extended configurations for MIMO muting and cell switch off  p_name=actNrExtCellSOMethod
  ...    value=${power_status}
    Run Keyword If  ${result}  append to list  ${modify_params}  ${item3}
    ${status3}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR cell-level extended configurations for MIMO muting and cell switch off
    ...    abbr=actNrExtCellSOMethod
    ${item4}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate mixed mode load-based power saving  p_name=actNrMixedSOMethod  value=${power_status}
    Run Keyword If  ${result}  append to list  ${modify_params}  ${item4}
    ${status4}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate mixed mode load-based power saving
    ...    abbr=actNrMixedSOMethod
    ${m}  Set Variable  '${status}'!='${power_status}'
    Run Keyword If
    ...  ${result} and (${m} or '${status1}'!='${power_status}' or '${status2}'!='${power_status}')
    ...  Run Keywords  Modify Parameters On Webem  modify_params=${modify_params}  timeout=900
    ...    AND  sleep  20
    ...  ELSE IF  ${m}  Run Keywords  Modify Parameters On Webem  modify_params=${modify_params}  timeout=900
    ...    AND  sleep  20
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission
    ...    abbr=actMicroDTX
    should be true  '${currect_status}'=='${power_status}'
    ${currect_status1}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission advanced
    ...    abbr=actMicroDTXAdvanced
    Run Keyword If  ${result}  should be true  '${currect_status1}'=='${power_status}'
    ${currect_status2}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based mMIMO TX power saving
    ...    abbr=actNrLBmMimoRTXPowerSaving
    Run Keyword If  ${result}  should be true  '${currect_status2}'=='${power_status}'
    Connect to gnb coam via ssl
    Wait until keyword succeeds    20 min    20 sec    COAM Check GNB cell on air
    [Teardown]  Run Keyword And Ignore Error  COAM Teardown gnb connections

Check and Modify power meter for RU on WebUI
    log to console  Check and Modify power meter for RU on WebUI
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Power meter enabled    abbr=actPowerMeter    new_value=true
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/PMMNL-1
    ...    filter_param=SBTS RFM energy monitoring    abbr=mtSBTSRfmEnergyMonitoring    new_value=15min
    sleep  1min


General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
    Selenium Login And Disable Screen Lock
    @{clock_class_list}    create list    8
    ${old_clock_class_list}    Modify Accepted clock class list with activate ignore error    acceptedClockClass=${clock_class_list}
    log to console  \n Wait For Fault 1900 Present
    ${status2}  Run Keyword and Return status  Expect Fault Should Present in History Alarm  faultId=${1900}  alarmId=${7101}
    Run Keyword If  '${status2}'!='True'  Wait For Expect Fault Present    faultId=${1900}    timeout=1200
    @{old_clock_class_list0}    convert to list    ${old_clock_class_list}
    Modify Accepted clock class list    acceptedClockClass=${old_clock_class_list0}
    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20 min
    Run Keyword If  '${status2}'!='True'  log to console  \n Wait For Fault 1900 Disappear
    Run Keyword If  '${status2}'!='True'  Wait For Expect Fault To Disappear    faultId=${1900}    timeout=1200
    Run Keyword And Ignore Error  Selenium Logout And Close Browser
    sleep  6min
    Selenium Login And Disable Screen Lock
    Check Sync State and Slave State    sync_state=Locked    slave_state=Locked
    [Teardown]  Run Keywords  Run Keyword And Ignore Error  Modify Accepted clock class list  acceptedClockClass=${old_clock_class_list}
    ...  AND  Teardown for General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed

Teardown for General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
  ${status}  Run Keyword and Return status  Wait until keyword succeeds  20 min  60 sec  verify all cells should be onair
  Run Keyword If  '${status}'!='True'  Perform BTS Site Reset
  Wait until keyword succeeds  20 min  60 sec  verify all cells should be onair
  Run Keyword And Ignore Error  Selenium Logout And Close Browser

Expect Fault Should Present in History Alarm
    [Documentation]    Auther: liqin.yang@nokia-sbell.com
    ...               Description: check expect alarm exist,add severity checkpoint
    ...               :param severity<str>: optional,value:Critical,Major,Minor,Warning
    ...               add checkpoint alarm id and fault id should be mapped
    ...               add ${alarm['configObjectName']} due to some object don't have runtime object
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}    ${du_index}=0    ${is_need_to_setup_gnb_connection}=${True}
    ${faultId}    Convert To Integer    ${faultId}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${connection}    Set variable if  '${du_index}'=='0'    ${connection}    ${connection}_du${du_index}
    Run keyword if    ${has_cbts} and ${is_need_to_setup_gnb_connection}
    ...    Cloud DU connect to gnb coam via ssl
    ...        connection=${connection}    du_index=${du_index}
    ...    ELSE IF    '${has_cbts}'=='${False}' and ${is_need_to_setup_gnb_connection}
    ...      Connect to gnb coam via ssl    connection=${connection}
    @{alarms}    coam.get_historic_alarms    connection=${connection}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Contain     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}    AND
                  ...                      Run Keyword If    '${config_object_name}'!='${None}'
                  ...                      Should Contain    ${alarm['configObjectName']}    ${config_object_name}
      Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

8680_General_SiSo_custom_beam_set_realization_to_gNB
    [Arguments]  ${call_keyword}=UE Attach and Start traffic
        ...    ${artifactory_token}="Authorization: Bearer cmVmdGtuOjAxOjE3OTI5MjExOTA6ME1uaG1sTzdKYTduOVpVNnM1TVpJcDNueVND"
    Run    sudo mkdir /home/ute/Downloads/
    Run    sudo chmod 777 /home/ute/Downloads/
  Run    wget -P /home/ute/Downloads/ ${bsr_url}${bsr_file1} --no-proxy --header=${artifactory_token}
  Run    wget -P /home/ute/Downloads/ ${bsr_url}${bsr_file2} --no-proxy --header=${artifactory_token}
  run keywords    BSR Setup    AND    SISO Coam Test Setup
    ${cell_list}    Get All Cell Id
    Set Test Variable   ${cell_list}
    ${scf_file}  scf.Get real SCF From BTS
    Set Test Variable  ${scf_file}
        ${cell_group_list}    Get All Cell Group Id
    # ${cell_group}    set variable if      ${flag}==${true}    ${cell_group_list}[0]
    # ...    ${cell_group_list}[1]
    ${cell_num}  Get Length  ${cell_list}
    FOR  ${id}  IN RANGE  ${cell_num}
      Exit For Loop If  ${id}==2 and '${mrbtsID}'=='1914'
      ${nrarfcn}  Get Parameter Value from SCF  parameter=nrarfcn  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_list}[${id}]
      ...  scf_file_path=${scf_file}
      ${BSR_package}  Set Variable If  ${nrarfcn}>636667   ${BSR_package_3840}  ${BSR_package_3500}
      General_SiSo_Activate_BSR_to_gNB_through_parameter_WebEM_Classical  cell=${cell_list}[${id}]  cell_group=${cell_group_list}[${id}]
      ...  BSR_package=${BSR_package}
    END
    #Get UE and Make call
    Run Keyword And Continue On Failure  ${call_keyword}
    Connect to gnb coam via ssl
    General_SiSo_Deactivate_Custome_BSR_WebEM_Classical
    #Get UE and Make call
    Run Keyword And Continue On Failure  ${call_keyword}
    Connect to gnb coam via ssl




General_SiSo_Activate_BSR_to_gNB_through_parameter_WebEM_Classical
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] to Check Installed BSR can be applied by user
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.23.2022 - - Created
    ...    *******************
    ...    Owner_di.yang@nokia-sbell.com
    [Arguments]  ${cell_group}  ${cell}  ${BSR_package}=BSR_AQQQA_6_H6_ALN60_ARP60_P00_COV3840_00424_00001
    ${BSR_path}   Set Variable    /home/ute/Downloads
    log to console    \nMake sure BSR_package in VM PATH:/home/ute/Downloads
    Selenium Login And Disable Screen Lock
    Download and update AQQQA BSR package    BSR_path=${BSR_path}    BSR_package=${BSR_package}
    log to console    \nActivate custom beam set realization
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
        ...    filter_param=Activate custom beam set realization  p_name=actCustomBsr  value=true
    append to list  ${modify_params}  ${item}

    # ${flag}    run keyword and return status     Should contain    ${BSR_package}    3840
    # ${cell}    set variable if      ${flag}==${true}    ${cell_list}[0]
    # ...    ${cell_list}[1]
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell}
    ...    filter_param=Basic Beam Set  p_name=basicBeamSet  value=beamSet_6
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell}
    ...    filter_param=Custom Beam Set Name  p_name=customBeamSetName  value=${BSR_package}
    append to list  ${modify_params}  ${item}
    # ${cell_group_list}    Get All Cell Group Id
    # ${cell_group}    set variable if      ${flag}==${true}    ${cell_group_list}[0]
    # ...    ${cell_group_list}[1]
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${cell_group}
    ...    filter_param=Number of transmitted Synchronization Signal Blocks  p_name=numberOfTransmittedSsBlocks  value=6 beams
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    sleep  60
    ${beamSetInUse}   selenium_coam.get_parameter_details    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell}
    ...  filter_param=Beam Set in Use    abbr=beamSetInUse
    Should Be Equal As Strings    ${beamSetInUse['Actual value']}    ${BSR_package}
    Wait until keyword succeeds    10 min    20 sec   verify all cells should be onair
    [Teardown]  Selenium Logout And Close Browser

General_SiSo_Deactivate_Custome_BSR_WebEM_Classical
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] to Check Installed BSR can be deactivated by user
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.23.2022 - - Created
    ...    *******************
    ...    Owner_di.yang@nokia-sbell.com
    ...  ${BSR_package_1}=BSR_AQQQA_6_H6_ALN60_ARP60_P00_COV3840_00424_00001
    ...  ${BSR_package_2}=BSR_AQQQA_6_H6_ALN60_ARP60_P00_COV3500_00424_00001
    Selenium Login And Disable Screen Lock
    log to console    \nDeactivate custom beam set realization
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate custom beam set realization  p_name=actCustomBsr  value=false
    append to list  ${modify_params}  ${item}
    FOR    ${cell}    IN    @{cell_list[:2]}
        ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell}
        ...    filter_param=Basic Beam Set  p_name=basicBeamSet  value=beamSet_6
        append to list  ${modify_params}  ${item}
        ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell}
        ...    filter_param=Custom Beam Set Name  p_name=customBeamSetName  value=${EMPTY}
        append to list  ${modify_params}  ${item}
    END
    Modify Parameters On Webem    modify_params=${modify_params}
    sleep  60
    Remove not used beam set realization software
    Wait until keyword succeeds    10 min    20 sec   verify all cells should be onair
    [Teardown]  Selenium Logout And Close Browser

Get UE and Make call
    [Arguments]  ${ue_index}=0    ${dl_tp}=300M  ${ul_tp}=20M    ${duration}=120    ${dl_exp}=300    ${ul_exp}=20
    ...    ${target_avg_percent}=0.1    ${min_percent}=0.0000001
    UE precondition   ue_index=${ue_index}
    run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
    power_ue.UE Attach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
    Sleep   10s
    keywords_8680.Reboot UE If no UE IP
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    duration=${duration}
    ...    ue_type=${ue_${ue_index}_type}    protocol=udp    buffer_size=1400B  throughput=${dl_tp}  window=8M
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    duration=${duration}
    ...    ue_type=${ue_${ue_index}_type}    protocol=udp    buffer_size=1400B  throughput=${ul_tp}  window=8M    iperf_type=via_command
    ${check_time}=    Evaluate     ${duration}-80
    ${log}    power_ue.Collect Tput    ue_type=${ue_${ue_index}_type}    filter=L2Lo    duration=${check_time}
    ${list_of_cell_ids}  create list
    FOR   ${cell_index}   IN   @{cell_list}
        ${cell_identify}=    Evaluate     16384*${tl.gnbs[0].global_bts_id}+${cell_index}
        ${cell_identify}   convert to string   ${cell_identify}
        append to list  ${list_of_cell_ids}  ${cell_identify}
    END
    power_ue.Check Tput    ue_type=${ue_${ue_index}_type}    direction=DL    log=${log}    cells=${list_of_cell_ids}
    ...    target_throughput=${dl_exp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    actCarrierAggregation=${True}
    power_ue.Check Tput    ue_type=${ue_${ue_index}_type}    direction=UL    log=${log}    cells=${list_of_cell_ids}
    ...    target_throughput=${ul_exp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    actCarrierAggregation=${True}
    ${ue_index_list}    create list    ${ue_index}
    [Teardown]    run keywords  run keyword and ignore error  csn.disconnect    connection=ASIK Master  AND
    ...  Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index_list}

BSR Setup
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}

Download and update AQQQA BSR package
    [Arguments]    ${BSR_path}    ${BSR_package}
    log to console    \nDownload and update BSR package
    ${BSR_package_path}    set variable     ${BSR_path}/${BSR_package}.zip
    selenium_coam.load_software_package_from_local_drive    file_path=${BSR_package_path}
    sleep    15s
    selenium_coam.software_update    is_activate=${True}
    sleep    15s
    ${beam_set_realization_software}    selenium_coam.get_beam_set_realization_software_info    timeout=${120}
    ${ret_0}    run keyword and return status    Should Be Equal    ${beam_set_realization_software[0]['BSR package']}    ${BSR_package}
    ${ret_1}    run keyword and return status    Should Be Equal    ${beam_set_realization_software[1]['BSR package']}    ${BSR_package}
    ${ret}    Set variable if  (${ret_0} or ${ret_1})   ${True}   ${False}
    Should be true    ${ret}

UE precondition
    [Documentation]   Require UE precondition, and avoid the duplicated require_ue actions same UE
    [Arguments]   ${ue_index}
    ${ue_type_res}   Run Keyword And Ignore Error   Get power UE type   ${ue_index}
    ${ue_type}   Run Keyword If   '${ue_type_res[0]}'=='FAIL'   Set Variable   ${tl.ues[${ue_index}].capabilities[1]}
    ...  ELSE   Set Variable   ${ue_type_res[1]}
    Set Suite Variable   ${ue_${ue_index}_type}   ${ue_type}
    Wait Until Keyword Succeeds   1m   10s   Check UE device   ue_index=${ue_index}
    #power_ue.Prepare UE   ue_type=${ue_type}   ue_index=${ue_index}   is_need_to_kill_vysor=${false}
    ${location_level}   Run Keyword and Return Status   Log   ${TEST_NAME}
    Run Keyword If   ${location_level}   Set Test Variable   ${ue_${ue_index}_required}   ${true}
    ...   ELSE   Set Suite Variable   ${ue_${ue_index}_required}   ${true}
    Run Keyword If   ${location_level}   Set Test Variable   ${ue_${ue_index}_nrCellId}   None
    ...   ELSE   Set Suite Variable   ${ue_${ue_index}_nrCellId}   None

Get power UE type
    [Arguments]   ${ue_index}
    [Documentation]   Add this keyword to avoid the `get_ue_type` timeout
    [Timeout]   180s
    ${ue_type}   ue.get_ue_type   ${tl.ues[${ue_index}]}
    [Return]   ${ue_type}

Check UE device
    [Documentation]   Check the UE device is connect to control pc normally.
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...             ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...             ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...             ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}    alias=cpc_${ue_index}
    wait until keyword succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}    serial_number=${serial_number}
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cpc_${ue_index}


CB008562_SR_B_5G_AQQL_01_Antenna_Online_Monitoring_using_WebEM_with_break
    [Tags]   8562
    sleep    60s
    run    ps auxf|grep Xvfb |awk '{print $2}'|xargs kill -9
    run    ps auxf| grep geckodriver|awk '{print $2}'|xargs kill -9
    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    wait until keyword succeeds    1200      30s    COAM Check All Cells Onair     connection=${connection}
#    block_cell     cell_index=2
    Selenium Login And Disable Screen Lock
    selenium_sbts.select_antenna_lines_for_monitoring
    selenium_sbts.start_antenna_line_monitoring
    ${monitor_start_time}    DateTime.Get Current Date    result_format=timestamp
    sleep    20s
    ${call_start_time}    DateTime.Get Current Date    result_format=timestamp
    ${UE_attach_time}    ${UE_detach_time}   L3_call_with_data_transfer    tput_info=${tput_define}    cell_id=${cell_index}
    ...    target_avg_percent=${0.1}    min_percent=${0.1}    duration=${20}    tput_from=self_define
    selenium_sbts.stop_antenna_line_monitoring
    selenium_sbts.get_monitored_values
    ${antenna_lines_CSV_file}    selenium_sbts.export_monitored_value_to_csv

    ${call_end_time}    DateTime.Get Current Date    result_format=timestamp
    ${elapsed_call_time}    DateTime.Subtract Date From Date    ${UE_detach_time}    ${UE_attach_time}
    ${elapsed_monitor_call_time}    DateTime.Subtract Date From Date    ${UE_attach_time}    ${monitor_start_time}
    log    ${elapsed_call_time}
    log    ${elapsed_monitor_call_time}
    ${no_call_times}    evaluate    ${elapsed_monitor_call_time}/10
    ${call_times}    Evaluate    ${elapsed_call_time}/10
    ${no_call_times_integer}    get_integer    number=${no_call_times}
    ${call_times_integer}    get_integer    number=${call_times}
    ${slice_no_call_integer_times}    Evaluate    ${no_call_times_integer}+1
    ${RSSI_value}    ${RSSI_value_dict}   ${ETP_value}    ${ETP_value_dict}
    ...    ${lenth_RSSI_value}    ${lenth_char_RSSI}    ${lenth_integer_RSSI}
    ...    ${integer_RSSI}   ${character_RSSI}
    ...    get_AQQQA_CSV_content    file=${antenna_lines_CSV_file}

    log to console    check RSSI's value during call and no_call...
    log    ${RSSI_value_dict}
    ${call_times_RSSI}    Evaluate    ${call_times_integer}*4
    should be true    ${call_times_RSSI}>=${lenth_integer_RSSI}
    ${judge_call_value_RSSI}    judge value    list=${integer_RSSI}
    should be equal    ${judge_call_value_RSSI}    True
    ${judge_without_call_RSSI}    judge value    list=${character_RSSI}
    should be equal    ${judge_without_call_RSSI}    False

    log to console    check ETP's value...
    log    ${ETP_value_dict}
    ${judge_ETP_value}    judge value    list=${ETP_value}
    should be equal    ${judge_ETP_value}    True
#    unblock_cell     cell_index=2
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}    AND
    ...    selenium_sbts.stop_antenna_line_monitoring
    ...    selenium logout and close browser


CB008017-5G-B_01_beamforing_L3_Call_on_Activation_of_DL_PRB_Muting_on_Loki-based_BBU
    [Tags]   8017
    ${add_str}   Convert To String   ${delta_8017}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    run keyword and ignore error    SCF delta recommission       delta_file=${add_str}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    enable rdNrEnableDlPrbMuting
    #power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=50M    duration=1600
    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=15
    #sleep   300s
    #power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=15
    Disable DL PRB muting
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    power_ue.UE Detach    ue_type=${ue_type}

    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}    AND
    ...    Disable DL PRB muting     AND
    ...    power_ue.UE Detach    ue_type=${ue_type}

block_cell
    [Arguments]        ${connection}=GNB_OAM     ${cell_index}=2
    ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=/MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    timeout=30   operational_State=Enabled
        ...    procedural_Status=configured
        ...    blockingState=Unblocked    administrative_State=Unlocked

    coam.block_cell
    ...  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}   timeout=60    connection=${connection}

    ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=/MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    timeout=30   operational_State=disabled
        ...    procedural_Status=initialization required
        ...    blockingState=blocked    administrative_State=Unlocked


unblock_cell
    [Arguments]       ${connection}=GNB_OAM    ${cell_index}=2
    ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=/MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    timeout=30   operational_State=disabled
        ...    procedural_Status=initialization required
        ...    blockingState=blocked    administrative_State=Unlocked

    coam.unblock_cell
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    timeout=60    connection=${connection}

    ${res}    Wait Until Keyword Succeeds     1 min  1s    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=/MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    timeout=30   operational_State=Enabled
        ...    procedural_Status=configured
        ...    blockingState=Unblocked    administrative_State=Unlocked

enable rdNrEnableDlPrbMuting
    [Arguments]  ${loner_select}=1    ${domain_name}=FrontHaul
    csn.connect to   hostname=${ASIK_IP}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    ${rdNrEnableDlPrbMuting_set}   csn.execute   command=bsh 1:${loner_select} confmgmtbrowser write FrontHaul rdNrEnableDlPrbMuting 0xFFFFFFFF
    ...   connection=ASIK Master
    ${rdNrEnableDlPrbMuting_check}   csn.execute   command=bsh 1:${loner_select} confmgmtbrowser read ${domain_name} rdNrEnableDlPrbMuting
    ...   connection=ASIK Master
    Should Contain    ${rdNrEnableDlPrbMuting_check}    0xFFFFFFFF
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=ASIK Master




Disable DL PRB muting
    [Arguments]  ${loner_select}=1  ${domain_name}=FrontHaul     ${expect_value}=VALUE: 0
    csn.connect to   hostname=${ASIK_IP}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    ${rdNrEnableDlPrbMuting_set}   csn.execute   command=bsh 1:${loner_select} confmgmtbrowser write FrontHaul rdNrEnableDlPrbMuting 0
    ...   connection=ASIK Master
    ${rdNrEnableDlPrbMuting_check}   csn.execute   command=bsh 1:${loner_select} confmgmtbrowser read ${domain_name} rdNrEnableDlPrbMuting
    ...   connection=ASIK Master
    Should Contain    ${rdNrEnableDlPrbMuting_check}    ${expect_value}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=ASIK Master

L3_call_with_data_transfer
    [Arguments]    ${tput_info}   ${cell_id}=${None}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${ue_ul_layer}=1    ${tput_from}=tool
    ...    ${connection}=GNB_OAM    ${duration_call}=${1800}   ${ue_index}=${0}
    ${avg_expect_rate}    Run Keyword If    ${target_avg_percent}==${None}    getAvgExpect_rate    ELSE
    ...    set variable    ${target_avg_percent}
    ${min_expect_rate}    Run keyword If    ${min_percent}==${None}    getMinExpect_rate    ELSE
    ...    set variable    ${min_percent}
    ${tput_info_total}    create dictionary
    log to console    use ue${ue_index} to make call on cell${cell_id}
    ${tput_cell}    run keyword if    '${tput_from}'=='tool'    getTputInfo_by_tool    ue_ul_layer=${ue_ul_layer}
    ...    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    duration=${duration}    connection=${connection}    ELSE    set variable    ${tput_info[${cell_id}]}
    log to console    tput info for cell ${cell_id} is: ${tput_cell}
    set to dictionary    ${tput_info_total}    ${cell_id}    ${tput_cell}
    ${tput_info}   set variable    ${tput_cell}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepareAasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    ${UE_attach_time}    DateTime.Get Current Date    result_format=timestamp
    ${gNb_CuType}   Get gNB CU type
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    keywords_8680.Reboot UE If no UE IP
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    ${dl_tp}    set variable    ${tput_info['dl_tp']}
    ${ul_tp}    set variable    ${tput_info['ul_tp']}
    ${tput_spark}    run keyword if    '${ue_type}'=='huawei_sigspark'    generateTput_for_spark_ue    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ${dl_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable     ${tput_spark[0]}   ELSE    set variable   ${dl_tp}
    ${ul_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable    ${tput_spark[1]}    ELSE    set variable   ${ul_tp}
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    log to console    start dl traffic...
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}    ue_mode=${gNb_CuType}
    log to console    start ul traffic...
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}
    ...    data_amount=2M    ue_mode=${gNb_CuType}
    ${tput_log}    power_ue.Collect Tput    ue_type=huawei    duration=${duration}
#    check_tput_for_cell    tput_info=${tput_info_total}    cell_id=${cell_id}    ue_index=${ue_index}    tput_log=${tput_log}
#    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    duration=${duration}    connection=${connection}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    protocol=${protocol}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_type=${iperf_type}    protocol=${protocol}
    ${UE_detach_time}    DateTime.Get Current Date    result_format=timestamp
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    [Return]    ${UE_attach_time}    ${UE_detach_time}


check_tput_for_cell
    [Documentation]    check tput for pointed cell
    ...  :param  tput_info    dict, key is cell id. value should contain dl_exp and ul_exp. E.G
    ...          {
    ...              1: {
    ...                  'dl_exp': 300,
    ...                  'ul_exp': 20,
    ...              },
    ...          }
    ...  :param  cell_id E.G 1
    ...  :param  ue_index E.G 0
    ...  :param  tput_log  output of power_ue.Collect Tput
    [Arguments]    ${tput_info}    ${cell_id}    ${ue_index}    ${tput_log}    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${connection}=GNB_OAM
    ${dl_exp}    set variable    ${tput_info['${cell_id}']['dl_exp']}
    ${ul_exp}    set variable    ${tput_info['${cell_id}']['ul_exp']}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    #1969
    #${cell_id}    Convert To String    ${cell_mapping[${311}]['nrCellIdentity']}
    #1913  2005
    ${cell_id}    Convert To String    ${cell_mapping[${1}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    ${ue_type}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable    huawei    ELSE    set variable    ${ue_type}
    ${output}    power_ue.Check Bi Tput   ue_type=${ue_type}    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
    ...    dltarget_throughput=${dl_exp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}


generateTput_for_spark_ue
    [Documentation]    unit adaption of dl_tp and ul_tp for spark ue
    ...  :param   dl_tp:  500M, return 500M/sec
    ...  :param   ul_tp:  50M, return 50M/sec
    [Arguments]    ${dl_tp}    ${ul_tp}
    ${dl_tp}    Fetch From Left    ${dl_tp}    .
    ${ul_tp}    Fetch From Left    ${ul_tp}    .
    ${dl_tp}    run keyword if    '${dl_tp[-1]}'!='M'    set variable    ${dl_tp}M/sec    ELSE
    ...    set variable    ${dl_tp}/sec
    ${ul_tp}    run keyword if    '${ul_tp[-1]}'!='M'    set variable    ${ul_tp}M/sec    ELSE
    ...    set variable    ${ul_tp}/sec
    [Return]    ${dl_tp}  ${ul_tp}
    log to console    \n${output}


prepareAasyslog_process
    [Documentation]    kill the old aaslog progress, and start a new one
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt




getTputInfo_by_tool
    [Documentation]    return the tput calculated by nrdim tool
    [Arguments]    ${ue_ul_layer}=1    ${cell_id}=1    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${duration}=600
    ...    ${connection}=GNB_OAM
    ${release}    Get program version based on gNB active version
    ${scf_path}    download scf download via rest api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    ${nband}    Get Cell Nband    cell_id=${cell_id}    connection=${connection}
    ${bbname}    Get bbmod name    cell_id=${cell_id}    connection=${connection}
    ${bbname}    set variable if    '${bbname}'=='${None}'    ABIO AirScale Capacity    ${bbname}
    ${testline_name}    Get Testline Name
    ${ue_ul_layer}    get_ue_ul_layer_from_ue_mapping_file    testline_name=${testline_name}    ue_ul_layer=${ue_ul_layer}
    ${tput_info}    generate_real_peak_info    cell_id=${cell_id}    scf_path=${scf_path}   ue_ul_layer=${ue_ul_layer}
    ...     avg_expect_rate=${target_avg_percent}    min_expect_rate=${min_percent}    duration=${duration}
    ...    nband=${nband}    productName=${bbname}    release=${release}
    [Return]    ${tput_info}

getAvgExpect_rate
    [Documentation]    get target average percent of tput. if rate_for_stream is not defined in variable.py, the default value is 0.95
    ${release}    Get program version based on gNB active version
    ${status}    run keyword and return status    variable should exist    ${rate_for_stream}
    @{dict_keys}    run keyword if    ${status}    Get Dictionary Keys    ${rate_for_stream}
    ${rate_avg}    run keyword if    '${release}' in @{dict_keys}    get from dictionary    ${rate_for_stream}    ${release}
    ...    ELSE    set variable    ${0.95}
    ${rate_avg}    run keyword if   '${rate_avg}'=='peak'    set variable    ${0.95}
    ...    ELSE    set variable    ${rate_avg}
    [Return]    ${rate_avg}

getMinExpect_rate
    [Documentation]    get min percent of tput. if rate_for_stream_min is not defined in variable.py, the default value is 0.85
    ${release}    Get program version based on gNB active version
    ${status}    run keyword and return status    variable should exist    ${rate_for_stream_min}
    @{dict_keys}    run keyword if    ${status}    Get Dictionary Keys    ${rate_for_stream_min}
    ${rate_min}    run keyword if    '${release}' in @{dict_keys}    get from dictionary    ${rate_for_stream_min}    ${release}
    ...    ELSE    set variable    ${0.85}
    [Return]    ${rate_min}



CB007273-D_12_Scorpio_FrTxOutOfOrder_F1907
    [Tags]   1907
    Modify Value In Json File AQQQA     target_value=0.0000001

Manual_SiSo_SM_Climate_profile_configuration
    [Tags]   climate
    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=${300}
    ${systemModule}   Set Variable   ${bts_info['systemModules'][0]['productName']}
    @{split_list}   Split String   ${systemModule}   ${SPACE}
    Set Suite Variable   ${SYSTEM_MODULE}   ${split_list[0]}
    #2005
    ${system_module_0}=    set variable    ${SYSTEM_MODULE} SMOD-1/SMOD_R-1
    Manual_SiSo_SM_Climate_profile_configuration.Manual_SiSo_SM_Climate_profile_configuration
    ...   system_module=${system_module_0}
    #1914 dualcore
#    ${system_module1}=    set variable   ASIL SMOD-1/SMOD_R-2
#    ${system_module2}=    set variable   ASIL SMOD-2/SMOD_R-1
#    Manual_SiSo_SM_Climate_profile_configuration_dualcore
#    ...    system_module1=${system_module1}     system_module2=${system_module2}
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}    AND
    ...    selenium logout and close browser

General_SiSo_Cell_switch-off_for_Energy_Efficiency_enhancement
    [Tags]   powersave

    ${add_str}   Convert To String   ${delta_energySaving_update}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    run keyword and ignore error    SCF delta recommission       delta_file=${add_str}

    ${add_str}   Convert To String   ${delta_energySaving_delete}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    run keyword and ignore error    SCF delta recommission       delta_file=${add_str}

    ${add_str}   Convert To String   ${delta_energySaving_delete1}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    run keyword and ignore error    SCF delta recommission       delta_file=${add_str}

    ${power1}      run keyword    check RU and cell powerState    sleep=AWAKE   Energy_saving_state=notEnergySaving
    ${range}     Evaluate    ${power1}/2


    #${add_str}   Convert To String   ${delta_energySave_add}
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS

    ${add_str}    Run keyword If  '${release_sbts}'=='SBTS23R2'
    ...    Convert To String   ${delta_energySave_add_23R2}
    ...    ELSE   Convert To String   ${delta_energySave_add}

    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    run keyword and ignore error    SCF delta recommission       delta_file=${add_str}

    log to console    wait about 12min for RU enter energySaving state

    ${power2}    wait until keyword succeeds    1000s      60s
    ...         check RU and cell powerState    sleep=Sleep   Energy_saving_state=energySaving
    sleep    240s     reason=wait RU enter energySaving state
    ${power3}      run keyword    check RU and cell powerState    sleep=Sleep   Energy_saving_state=energySaving
    Run keyword if      ${power3}>${range}     FAIL
    #recover env

    ${add_str}   Convert To String   ${delta_energySaving_update}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    run keyword and ignore error    SCF delta recommission       delta_file=${add_str}

General_SiSo_SBTS_RM_TEMP counter - activation
    [Tags]   counter

    ${add_str}   Convert To String   ${delta_M40005C2_M40008C1}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    run keyword and ignore error    SCF delta recommission       delta_file=${add_str}

    log to console    wait about 15min for M40005C2 M40008C1
    sleep     16min       reason=wait M40005C2_M40008C1 enable
    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
  ${status}  run keyword and return status  Should Contain Any  ${release_sbts}  SBTS23R3  SBTS23R4  SBTS24R1
  ${M40005C2length1}  ${M40005C2}  run keyword if  ${status}
    ...  get counter value and length  dist_name=${M40005C2_distname_before_24R2}
  ...  json_path=${M40005C2_path_before_24R2}
    ...  ELSE  get counter value and length  dist_name=${M40005C2_distname}  json_path=${M40005C2_path}
  ${M40008C1length1}  ${M40008C1}  run keyword if  ${status}
    ...  get counter value and length  dist_name=${M40008C1_distname_before_24R2}
  ...  json_path=${M40008C1_path_before_24R2}
  ...  ELSE  get counter value and length  dist_name=${M40008C1_distname}  json_path=${M40008C1_path}
    log to console    wait about 15min for M40005C2 M40008C1 change
    sleep     16min     reason=wait M40005C2_M40008C1 change
  ${M40005C2length2}  ${M40005C2}  run keyword if  ${status}
    ...  get counter value and length  dist_name=${M40005C2_distname_before_24R2}
  ...  json_path=${M40005C2_path_before_24R2}
    ...  ELSE  get counter value and length  dist_name=${M40005C2_distname}  json_path=${M40005C2_path}
  ${M40008C1length2}  ${M40008C1}  run keyword if  ${status}
    ...  get counter value and length  dist_name=${M40008C1_distname_before_24R2}
  ...  json_path=${M40008C1_path_before_24R2}
  ...  ELSE  get counter value and length  dist_name=${M40008C1_distname}  json_path=${M40008C1_path}
    Run keyword if      ${M40005C2length2}==${M40005C2length1}     FAIL
    Run keyword if      ${M40008C1length2}==${M40008C1length1}     FAIL
    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}
    #recover env
    ${add_str}   Convert To String   ${delta_M40005C2_M40008C1_disable}
    ${add_str}   Set Variable   ${add_str.replace("'","\"")}
    run keyword and ignore error    SCF delta recommission       delta_file=${add_str}

Manual_SiSo_SM_KPI5_capacity_module_reset_downtime
    [Tags]   BBMODreset
    ${sum}    set variable   0
    ${BBMOD_reset_time_list}   create list
    ${round}   set variable   2
    FOR  ${i}    IN RANGE   ${round}
        log to console    round ${i} reset BBMOD
        ${duration}     run keyword and continue on failure     BBMOD reset time test
        append to list    ${BBMOD_reset_time_list}    ${duration}
        ${sum}     Evaluate   ${sum}+${duration}
    END
    sort and handle list    list=${BBMOD_reset_time_list}    sum=${sum}    round=${round}

Manual_SiSo_SM_KPI_54_Power-on_RU_startup_availability
    [Tags]   poweron
    Generate test case log path
    #coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    ${RU_poweron_time_list}   create list
    ${sum}    set variable   0
    ${round}   set variable   2
    FOR  ${i}    IN RANGE   ${round}
        coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
        log to console    round ${i}
        RU poweroff
        log to console    check alarm
        sleep    20s     reason=wait poweroff stable
        ${duration}    run keyword and continue on failure    RU poweron time test
        append to list    ${RU_poweron_time_list}    ${duration}
        ${sum}     Evaluate   ${sum}+${duration}
        coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}
     END
     Sort List    ${RU_poweron_time_list}
     ${min_time}   Get Slice From List    ${RU_poweron_time_list}    0    1
     ${last_index}     Evaluate     ${round}-1
     ${max_time}   Get Slice From List    ${RU_poweron_time_list}    ${last_index}
     ${average_time}    Evaluate     ${sum}/${round}

    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}

Manual_SiSo_SM_KPI_51a_b_RU_reset_downtime
    [Tags]    reset
#    Generate suite log path
    Generate test case log path
    @{traces}    create list   condor5gSyslog
    ${sum}    set variable   0
    ${RU_reset_time_list}   create list
    ${round}   set variable   2
    FOR  ${i}    IN RANGE   ${round}
        log to console    round ${i}
        run keyword and continue on failure    DCAP.Start_Collect_Trace   traces=${traces}
        RU Module Reset From GUI
        #run keyword and continue on failure    DCAP.Stop_Collect_Trace_and_Get_Result
        run keyword and continue on failure      Stop_Collect_Trace_and_Get_Result_test
        run keyword and continue on failure    DCAP.Extract_out_Log_Files   tracer=syslog
        ${duration}    run keyword and continue on failure     verify DCAP syslog for RU reset
        append to list    ${RU_reset_time_list}    ${duration}
        ${sum}     Evaluate   ${sum}+${duration}
     END
     Sort List    ${RU_reset_time_list}
     ${min_time}   Get Slice From List    ${RU_reset_time_list}    0    1
     ${last_index}     Evaluate     ${round}-1
     ${max_time}   Get Slice From List    ${RU_reset_time_list}    ${last_index}
     ${average_time}    Evaluate     ${sum}/${round}


Manual_SiSo_SM_KPI_17a_b _Block_unblock_cell_duration
    [Tags]   block
    ${round}   set variable   3
    FOR   ${i}    IN RANGE   ${round}
        log to console    round ${i}
        log to console   block_cell_start
        ${tmp1}   run keyword    block_cell_test
        log to console   unblock_cell_start
        ${tmp2}   run keyword    unblock_cell_test
        ${blocksum}   Evaluate    ${tmp1}+${blocksum}
        ${unblocksum}   Evaluate    ${tmp2}+${unblocksum}
    END
    ${average_block_time}   Evaluate   ${blocksum}/${round}
    ${average_unblock_time}   Evaluate   ${unblocksum}/${round}


Stop_Collect_Trace_and_Get_Result_test
    [Arguments]   ${timeout}=5min
    [Documentation]  Stop tracing, delete to traces to save server space, then remove the bts from the dcapserver.
    ...     return: path of downloaded trace file in zip format, and the content in the zip file.
    Log to console   Stop collecting dcap log.
    rd.stop_trace
    sleep    ${timeout}
    ${trace_file_path}    rd.get_results
    ${trace_result_content}    rd.get_result_file_contents
    ${PATHONLY}   ${SNAPSHOTNAME}   Split String From Right    string=${trace_file_path}   separator=/     max_split=1
    ${PATHONLY}   ${SNAPSHOTNAMEContent}   Split String From Right
    ...      string=${trace_result_content}   separator=/     max_split=1
    run    mv ${trace_file_path} ${LOG_PATH}/.
    run    mv ${trace_result_content} ${LOG_PATH}/.
    set test variable   ${trace_file_path}    ${LOG_PATH}/${SNAPSHOTNAME}
    set test variable   ${trace_result_content}    ${LOG_PATH}/${SNAPSHOTNAMEContent}
    rd.delete_trace
    rd.delete_bts
    [Return]  ${trace_file_path}  ${trace_result_content}



block_cell_test
    [Arguments]   ${connection}=GNB_OAM
    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}

    ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=/MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    timeout=30   operational_State=Enabled
        ...    procedural_Status=configured
        ...    blockingState=Unblocked    administrative_State=Unlocked
    ${t}    robot.libraries.DateTime.Get Current Date     result_format=timestamp
    ${time_stamp}     Convert Date    ${t}    epoch
    coam.block_cell
    ...  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    timeout=60    connection=${connection}

    ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=/MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    timeout=30   operational_State=disabled
        ...    procedural_Status=initialization required
        ...    blockingState=blocked    administrative_State=Unlocked

    ${t}    robot.libraries.DateTime.Get Current Date     result_format=timestamp
    ${time_stamp2}     Convert Date    ${t}    epoch
    ${block_time}    Evaluate   ${time_stamp2}-${time_stamp}
    Run keyword if      ${block_time}>20    FAIL
    [Return]     ${block_time}
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}


unblock_cell_test
    [Arguments]    ${connection}=GNB_OAM
    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=/MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    timeout=30   operational_State=disabled
        ...    procedural_Status=initialization required
        ...    blockingState=blocked    administrative_State=Unlocked

    coam.unblock_cell
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    timeout=60    connection=${connection}

    ${t}    robot.libraries.DateTime.Get Current Date     result_format=timestamp
    ${time_stamp}     Convert Date    ${t}    epoch

    ${res}    Wait Until Keyword Succeeds     1 min  1s    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=/MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
        ...    timeout=30   operational_State=Enabled
        ...    procedural_Status=configured
        ...    blockingState=Unblocked    administrative_State=Unlocked

    ${t}    robot.libraries.DateTime.Get Current Date     result_format=timestamp
    ${time_stamp2}     Convert Date    ${t}    epoch
    ${unblock_time}    Evaluate   ${time_stamp2}-${time_stamp}
    Run keyword if      ${unblock_time}>25    FAIL
    [Return]     ${unblock_time}
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}

RU Module Reset From GUI
    [Arguments]    ${connection}=GNB_OAM
    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        ${cell_group_idx}    Evaluate    ${ru_index}-1
        Perform RU Reset    ru_index=${ru_index}
        Wait Until Keyword Succeeds    90 sec    5 sec
        ...   RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
    END
#    wait until keyword succeeds    1200      30s    coam_gnb_classical.COAM Check GNB cell on air
    wait until keyword succeeds    1200      30s    COAM Check All Cells Onair     connection=${connection}
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}


RU poweroff
    [Arguments]    ${connection}=GNB_OAM
    #coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        ${cell_group_idx}    Evaluate    ${ru_index}-1
        Perform RU Power Off    ru_index=${ru_index}
        Wait Until Keyword Succeeds    90 sec    5 sec
        ...   RU Should Be Power Off    ru_index=${ru_index}    connection=${connection}
    END
#    wait until keyword succeeds    1200      30s    coam_gnb_classical.COAM Check GNB cell on air
#    wait until keyword succeeds    1200      30s    COAM Check All Cells Onair     connection=${connection}
#    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
#   ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}

RU poweron time test
    [Arguments]    ${connection}=GNB_OAM
    #coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    ${t}    robot.libraries.DateTime.Get Current Date     result_format=timestamp
    ${time_stamp}     Convert Date    ${t}    epoch
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        ${cell_group_idx}    Evaluate    ${ru_index}-1
        Perform RU Power On    ru_index=${ru_index}
        Wait Until Keyword Succeeds    360 sec    30 sec
        ...    RU Should Be Online    ru_index=${ru_index}    connection=${connection}
    END
    wait until keyword succeeds    1200      30s    COAM Check All Cells Onair     connection=${connection}
    ${t}    robot.libraries.DateTime.Get Current Date     result_format=timestamp
    ${time_stamp2}     Convert Date    ${t}    epoch
    ${RU_poweron_duration}    Evaluate   ${time_stamp2}-${time_stamp}
    Run keyword if      ${RU_poweron_duration}>500    FAIL
    [Return]     ${RU_poweron_duration}


Setup case for 8680
    log to console     Case Start

Setup Suite for 8680
#    SCF commission     SCF=${scf}
    Generate suite log path
    #Generate test case log path




SCF commission
    [Arguments]    ${SCF}
    coam_gnb_classical.Connect to gnb coam via ssl
    ${result}    coam_gnb_classical.COAM Commission with scf file    scf_file_path=${SCF}
    ...    is_pdl_checking_needed=${True}    timeout=900
    wait until keyword succeeds    1200      10    COAM Check All Cells Onair     connection=GNB_OAM
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM

SCF delta recommission
    [Arguments]    ${delta_file}
    coam_gnb_classical.Connect to gnb coam via ssl
    run keyword and ignore error     csn.disconnect    connection=ASIK Master
    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...                                   skip_parameter_relation_errors=${true}
    ...                                   should_activate=${true}
    ...                                   timeout=${600}
    ...                                   connection=GNB_OAM
    wait until keyword succeeds    1200      10    COAM Check All Cells Onair     connection=GNB_OAM
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM



DU_WebEM.Check NR Cell status
    [Documentation]  This KW is for get one cell status and check cell onair
    [Arguments]    ${cell_internal_id}    ${operational_State}=${empty}
    ...    ${procedural_Status}=${empty}    ${availability_Status}=${empty}    ${blockingState}=${empty}
    ...    ${administrative_State}=${empty}
    ${cell_info}=    coam.get_cell_specific_info
    ...   cell_id=${cell_internal_id}   timeout=30    connection=GNB_OAM
    Run keyword if   '${operational_State}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['operationalState']}    ${operational_State}    ignore_case=true
    Run keyword if   '${procedural_Status}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['proceduralStatus']}    ${procedural_Status}     ignore_case=true
    Run keyword if   '${availability_Status}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['availabilityStatus']}    ${availability_Status}    ignore_case=true
    Run keyword if   '${blockingState}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['blockingState']}    ${blockingState}    ignore_case=true
    Run keyword if   '${administrative_State}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['administrativeState']}    ${administrative_State}    ignore_case=true


verify DCAP syslog for RU reset
    [Arguments]  ${log_files}=${all_log_file_paths}  ${log_path}=${extract_log_path}
    run   rm -rf /tmp/RU_reset.log
    FOR    ${item}    IN     @{log_files}
        ${txt}     run    command=cat ${log_path}/${item} |grep "OnAirDone" >>/tmp/RU_reset.log
    END
    ${start_time}    run   command=cat /tmp/RU_reset.log|cut -d '<' -f 2|cut -d '>' -f 1|sed 's/T/ /g'|sort -r|tail -n 1
    ${start_time}     Convert Date    ${start_time}    epoch

    ${end_time}     run   command=cat /tmp/RU_reset.log|cut -d '<' -f 2|cut -d '>' -f 1|sed 's/T/ /g'|sort|tail -n 1
    ${end_time}     Convert Date    ${end_time}    epoch
    ${RU_reset_duration}    Evaluate   ${end_time}-${start_time}
    Run keyword if      ${RU_reset_duration}>450    FAIL
    [Return]     ${RU_reset_duration}

BBMOD reset time test
    [Documentation]   author: Ding Lili
    [Arguments]    ${connection}=GNB_OAM
    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}

    Run Keyword And Ignore Error       coam.reset_unit
    ...   dist_name=/MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...    reset_type=Warm  timeout=200s  connection=${connection}
    ${t}    robot.libraries.DateTime.Get Current Date     result_format=timestamp
    ${start_time_stamp}     Convert Date    ${t}    epoch
    sleep   180s    reason=wait on air
    wait until keyword succeeds    800      5s    COAM Check All Cells Onair     connection=${connection}
    ${t}    robot.libraries.DateTime.Get Current Date     result_format=timestamp
    ${end_time_stamp}     Convert Date    ${t}    epoch
    ${BBMOD_reset_duration}    Evaluate   ${end_time_stamp}-${start_time_stamp}
    #Run keyword if      ${BBMOD_reset_duration}>425    FAIL
    Run keyword if      ${BBMOD_reset_duration}>420    FAIL
    [Return]     ${BBMOD_reset_duration}
    [Teardown]    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}

sort and handle list
    [Arguments]   ${list}=${list}   ${round}=${round}    ${sum}=${sum}
    Sort List    ${list}
    ${min_time}   Get Slice From List    ${list}    0    1
    ${last_index}     Evaluate     ${round}-1
    ${max_time}   Get Slice From List    ${list}    ${last_index}
    ${average_time}    Evaluate     ${sum}/${round}
DU_WebEM.Check NR Cell Energy saving state
    [Documentation]  This KW is for get one cell status and check cell onair
    [Arguments]    ${cell_internal_id}    ${Energy_saving_state}=${empty}
    ${cell_info}=    coam.get_cell_specific_info
    ...   cell_id=${cell_internal_id}   timeout=30    connection=GNB_OAM
    Run keyword if   '${Energy_saving_state}' != '${empty}'
    ...   Should be equal    ${cell_info['energySavingState']}    ${Energy_saving_state}    ignore_case=true

check RU and cell powerState
    [Arguments]     ${ru_index}=1   ${connection}=GNB_OAM   ${cell_index}=1
    ...             ${sleep}=AWAKE   ${Energy_saving_state}=notEnergySaving
    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    DU_WebEM.Check NR Cell Energy saving state
    ...    cell_internal_id=/MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}
    ...    Energy_saving_state=${Energy_saving_state}
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}    connection=${connection}
    ${resp}=    coam.Get_Measurements    measurement_type=realTime    connection=${connection}
    Should be equal as strings     ${ru_status['status']['powerState']}     ${sleep}
                                  ...  msg=Current RU operationalStatus is not in sleep status    ignore_case=${True}
    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}

    ${var_status}    ${ci_var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ...    gnb_index=${0}   du_index=${0}    common_unit_index=${0}
    FOR  ${item}   IN  @{resp}
       Check power info  ${item}
    END
#    run keyword if      '&{ci_var_dict}[testline]'=='7_5_UTE5G402T1913'
#    ...    set suite variable  ${RMOD_Num}  ${0}
#    ...    ELSE IF   '&{ci_var_dict}[testline]'=='7_5_UTE5G402T1914'
#    ...    set suite variable  ${RMOD_Num}  ${0}

    [Return]    ${m_power_info}

Check power info
    [Arguments]  ${dict}
    FOR  ${key}  IN  @{dict}
       Run Keyword If  'ENERGY_EFFICIENCY\/RMOD\/RMOD_R-1' in '${key}'
       ...  Set Test Variable   ${m_power_info}   ${dict['${key}']['power']}
       Run Keyword If  'ENERGY_EFFICIENCY\/RMOD\/RMOD_R-2' in '${key}'
       ...  Set Test Variable   ${m_power_info}   ${dict['${key}']['power']}
    END

get counter value and length
    [Arguments]   ${dist_name}=${dist_name}   ${connection}=GNB_OAM    ${json_path}=${json_path}
#    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    ${counters_info}    coam.get_counters_info   dist_name=${dist_name}      connection=${connection}    timeout=120
    ${counters_info}      set variable      ${counters_info${json_path}}
    ${length}    get length     ${counters_info}
#    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}
    [return]    ${length}   ${counters_info}
Manual_SiSo_SM_Climate_profile_configuration_dualcore
    [Documentation]
        ...    *****************
        ...    - [TEST PURPOSE]Purpose of this test case is to verify Climate control Profiling parameter
        ...    set by operator via WebEM/SCF.
        ...    taf.selenium.sbts should update to taf.selenium.sbts V0.52
    [Arguments]    ${system_module1}=ASIL SMOD-1/SMOD_R-2     ${system_module2}=ASIL SMOD-2/SMOD_R-1
    Test preconditions
    Modify Climate control profile through Webem dualcore    paraValue=Low Noise
    Modify Climate control profile through Webem dualcore    paraValue=Linear
    Modify Climate control profile through Webem dualcore    paraValue=Optimized Cooling
    Modify Climate control profile through SCF dualcore    paraValue=Low Noise
    Modify Climate control profile through SCF dualcore    paraValue=Linear
    Modify Climate control profile through SCF dualcore    paraValue=Optimized Cooling
    Modify Climate control profile through Commissioning Wizard dualcore
    ...      paraValue=Low Noise    system_module1=${system_module1}   system_module2=${system_module2}
    Modify Climate control profile through Commissioning Wizard dualcore
    ...      paraValue=Linear    system_module1=${system_module1}   system_module2=${system_module2}
    Modify Climate control profile through Commissioning Wizard dualcore
    ...     paraValue=Optimized Cooling    system_module1=${system_module1}   system_module2=${system_module2}
    [Teardown]   Selenium Logout And Close Browser

Modify Climate control profile through Commissioning Wizard dualcore
    [Arguments]    ${system_module1}=ASIL SMOD-1/SMOD_R-2   ${system_module2}=ASIL SMOD-2/SMOD_R-1   ${paraValue}=Linear
    log to console    \n***Modify Climate control profile through Commissioning Wizard***
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    selenium_coam.go_to_commissioning_tab    target_tab_path=System Module Configuration
    selenium_coam.configure_system_module_configuration
    ...    system_module=${system_module1}    climate_control_profile=${paraValue}
    selenium_coam.configure_system_module_configuration
    ...    system_module=${system_module2}    climate_control_profile=${paraValue}
    selenium_coam.submit
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    sleep    3s
    ${currentValue1}    selenium_coam.get_parameter_value  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...  filter_param=Climate control profiling
    ${currentValue2}    selenium_coam.get_parameter_value  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-2
    ...  filter_param=Climate control profiling
    Should be Equal    ${currentValue1}    ${paraValue}
    Should be Equal    ${currentValue2}    ${paraValue}
    selenium logout and close browser
    [Teardown]  selenium logout and close browser

Modify Climate control profile through Webem dualcore
    [Arguments]    ${paraValue}
    log to console    \n***Modify Climate control profile through Webem***
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    ${modify_params}    create list
    ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
        ...    filter_param=Climate control profiling    p_name=climateControlProfiling    value=${paraValue}
    ${item2}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-2
        ...    filter_param=Climate control profiling    p_name=climateControlProfiling    value=${paraValue}
    append to list    ${modify_params}    ${item}
    append to list    ${modify_params}    ${item2}
    Modify Parameters On Webem LTE    modify_params=${modify_params}
    sleep    10s
    ${currentValue1}    selenium_coam.get_parameter_value  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...  filter_param=Climate control profiling
    ${currentValue2}    selenium_coam.get_parameter_value  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-2
    ...  filter_param=Climate control profiling
    Should be Equal    ${currentValue1}    ${paraValue}
    Should be Equal    ${currentValue2}    ${paraValue}
    [Teardown]    Selenium Logout And Close Browser
Modify Climate control profile through SCF dualcore
    [Arguments]   ${paraValue}    ${gnb_index}=${0}    ${connection}=GNB_OAM
    log to console    \n***Modify Climate control profile through SCF***
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    ${modify_params}    create list
    ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
        ...    filter_param=Climate control profiling    p_name=climateControlProfiling    value=${paraValue}
    ${item2}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-2
        ...    filter_param=Climate control profiling    p_name=climateControlProfiling    value=${paraValue}
    append to list    ${modify_params}    ${item}
    append to list    ${modify_params}    ${item2}
    Modify Parameters In SCF From Webem And Commission LTE
    ...       ${modify_params}    gnb_index=${gnb_index}    connection=${connection}
    sleep  100s    reason=wait for cell onair
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    sleep  100s    reason=wait for stable
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    ${currentValue}    selenium_coam.get_parameter_value  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...  filter_param=Climate control profiling
    ${currentValue2}    selenium_coam.get_parameter_value  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-2
    ...  filter_param=Climate control profiling
    Should be Equal    ${currentValue}    ${paraValue}
    Should be Equal    ${currentValue2}    ${paraValue}
    selenium logout and close browser
    [Teardown]    Selenium Logout And Close Browser

Modify Value In Json File AQQQA
    [Arguments]        ${target_value}        ${ru_index}=1    ${connection}=GNB_OAM
    log to console    \n Modify Value In Json File
    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    csn.connect to   hostname=${ASIK_IP}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    log to console    \n precheck alarm confirm no fault 1397 at beginning
    ${output}  csn.execute  command=cat /ram/fault_history_log.txt|grep 1397|wc -l   connection=RU_${ru_index}
    Should Be Equal     "${output.replace('\n','').strip()}"    "0"
    ${cmd}   Set Variable   echo "/ action create ConfigAccess /ca /module"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute   command=${cmd}    connection=RU_${ru_index}
    sleep    2s
    ${cmd}   Set Variable
    ...    echo '/ca action fetch DECODED "dpdmr_dlpath1.bin" "/ram/dpdmr_dlpath1.json"'|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    log to console     \n update json and reset RU generate alarm
    csn.send_command
    ...   command=sudo sed -i 's/"dpdMseLimit":.*,/"dpdMseLimit": ${target_value},/g' /ram/dpdmr_dlpath1.json    connection=RU_${ru_index}
    sleep   2s
    csn.send_command
    ...   command=sudo sed -i '192{s/[0-9].[0-9]/${target_value}/g}' /ram/dpdmr_dlpath1.json    connection=RU_${ru_index}
    sleep   2s
    csn.send_command
    ...   command=sudo sed -i '196{s/[0-9].[0-9]/${target_value}/g}' /ram/dpdmr_dlpath1.json    connection=RU_${ru_index}
    sleep   2s
    ${output}     csn.execute    command=sudo cat /ram/dpdmr_dlpath1.json|grep dMonMseLimit -A 150    connection=RU_${ru_index}
    sleep    2s
    #log to console    \n ${output}
    sleep    2s
    ${cmd}   Set Variable
    ...    echo '/ca action store PERMANENT DECODED "dpdmr_dlpath1.bin" "/ram/dpdmr_dlpath1.json"'|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=ASIK Master
    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}
    RU Module Reset From GUI
    log to console    \n wait about 2mins to check alarm 1907 on webem and 1397 on RU
    sleep   120s    reason=wait for 1397 and 1907 alarm appeared
    coam_gnb_classical.Connect to gnb coam via ssl      connection=${connection}
    check alarm if contain faultid    faultid=1907
    csn.connect to   hostname=${ASIK_IP}   username=${asik_username}   password=${asik_password}   alias=ASIK Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${output}  csn.execute  command=cat /ram/fault_history_log.txt|grep 1397|wc -l   connection=RU_${ru_index}
    Should not Be Equal     "${output.replace('\n','').strip()}"    "0"
    log to console      \n rm dpdmr_dlpath.bin* and reset RU to clear alarm 1907 and 1397
    csn.send_command    command=sudo rm -f /mnt/runtime/configs/11/DLPATH_2_0/dpdmr_dlpath.bin*   connection=RU_${ru_index}
    sleep   2s
    ${cmd}   Set Variable
    ...    echo '/ action create ConfigAccess /ca /module'|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable
    ...    echo '/ca action delete "dpdmr_dlpath1.bin"'|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=ASIK Master
    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}
    RU Module Reset From GUI
    [Teardown]   Run keyword and ignore error     Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=${connection}   AND
    ...    csn.disconnect    connection=RU_${ru_index}

check alarm if contain faultid
    [Arguments]       ${faultid}=1907           ${connection}=GNB_OAM
    ${active_alarms_list}    coam.get_active_alarms    connection=${connection}
    ${flag}   set variable   False
    FOR  ${alarm}  IN  @{active_alarms_list}
        log to console    ${alarm['faultId']}
        ${flag}    Set Variable If    ${alarm['faultId']}==${faultid}   True    False
        exit for loop if    '${flag}'=='True'
    END
    Run Keyword If    ${flag} == ${False}    FAIL

ST SiSo RF Factory SW update
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    ${RUBuild_before}  Get RU SW version
    Upload file to RU and Install SW
    Run Keyword And Continue On Failure  Wait For Expect Fault Present    faultId=${23}    timeout=960
    ${RUBuild_after}  Get RU SW version
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds  20min  5s  coam_siso_common.RU Should Be Offline
    Run Keyword And Continue On Failure  Verify RMOD With incompatible Software  RUbuild_before=${RUbuild_before}
    ...  RUbuild_after=${RUbuild_after}
    Log to console  DownLoad ${download_build} to UTE
    ${sw_package}  Get the target build Path  5g_target_sw=${download_build}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Log to console  Update SW ${download_build} SBTS
    ${sw_upgrade_result}    _Update SW SBTS    sw_path=${sw_package}    timeout=1200
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}  file_path=${TS_CASE_LOG_PATH}
    ${Active_SW_version_after}    Get Active SW Version
    should be equal  ${Active_SW_version_after}    ${Active_SW_version}
    Set Test Variable  ${ultp}  10
    Set Test Variable  ${dltp}  5
    UE Attach and Start traffic  cell_id=0  physCellId=${physical_0}
    Run Keyword And Continue On Failure  Upload passive file to RU and Install SW
    [Teardown]    Run Keyword And Ignore Error  COAM Teardown gnb connections

Get RU Image Chksum and File Version
    Log To Console  Get RU Image Chksum and File Version
    ${str}  Remove String  ${stream}  SBTS
    Set Test Variable  ${rf}    ${tl_config.RF_FACTORY_SW_STORAGE['${serial_number}']}
    Set Test Variable  ${RU_image_directory}  ${rf['SW_PATH']}
    ${RU_image}  Set Variable  ${rf['IMAGE_FILE_${str}']}
    ${checksum}  Set Variable  ${rf['checksum_${str}']}
    Set Test Variable  ${file_version}  ${rf['fileVersion_${str}']}
    [Return]  ${RU_image}  ${checksum}

Upload file to RU and Install SW
    ${RU_image}  ${checksum}  Get RU Image Chksum and File Version
    Get file from svn  file_name=${RU_image}
    Upload file to RU  RU_image=${RU_image}
    Install SW on RU  RU_image=${RU_image}  checksum=${checksum}
    Activate SW on RU  fileName=${RU_image}
    [Teardown]  Run Keywords  Run Keyword And Ignore Error  csn.Disconnect  connection=RU
    ...  AND  Run Keyword And Ignore Error  COAM Teardown gnb connections

Get file from svn
    [Arguments]    ${file_name}
    Log To Console  Get file from svn
    ${path_to_file}=   Set Variable    ${file_version}/C_Element/SE_RFM/SS_CTA6/Target/
    ${path_to_svn_file}=    Set Variable    ${path_to_svn_factory}${path_to_file}
    Run Keyword And Continue On Failure  create directory  ${RU_image_directory}
    ${checkIfExists}=    Run Keyword and Return Status    OperatingSystem.File Should Exist  ${RU_image_directory}${file_name}
    Run Keyword If      '${checkIfExists}'=='True'        Log To Console    the RU build is already on the ute
    Run Keyword If      '${checkIfExists}'=='False'  Run
    ...  svn export --force --username ca_ute_test --password utetest ${path_to_svn_file}${file_name} ${RU_image_directory}${file_name}
    OperatingSystem.Wait Until Created
    ...                 path=${RU_image_directory}${file_name}
    ...                 timeout=200
    OperatingSystem.File Should Exist    ${RU_image_directory}${file_name}

Upload file to RU
    [Arguments]  ${RU_image}
    Log To Console  Upload ${RU_image} to RU
    Connect to gnb coam via ssl
  Connect to Common Unit Master
    Connect to RU With Allocated IP
    csn.upload File    remote_path=/tmp/${RU_image}    local_path=${RU_image_directory}${RU_image}
    ...    connection=RU    timeout=60s
    sleep    20s

Install SW on RU
    [Arguments]    ${RU_image}  ${checksum}
    Log To Console  Install SW on RU
    ${out}  Get command output on RU  command=sudo SWmanShellCommand -s /tmp/${RU_image} ${checksum} ${file_version} ""
    should contain   ${out}   OK
    csn.send command    \n    connection=RU

Activate SW on RU
    [Arguments]  ${fileName}
    Log To Console  Activate ${file_version} SW on RU
    ${out}  Get command output on RU  command=sudo SWmanShellCommand -a ${file_version} ${file_version} ${fileName} ${file_version}
    should contain   ${out}   OK
    csn.execute    sudo pssreboot hw    connection=RU
    csn.await execution end    timeout=120s    connection=RU
    [Teardown]  Run Keywords  Run Keyword And Ignore Error  csn.Disconnect  connection=RU
    ...  AND  Run Keyword And Ignore Error  COAM Teardown gnb connections

Get command output on RU
    [Arguments]    ${command}    ${ru_alias}=RU
    csn.Send Command    command=${command}    connection=${ru_alias}
    csn.await execution end    timeout=180s    connection=${ru_alias}
    ${GET_SW}  csn.Read Output    connection=${ru_alias}
    ${GET_SW}  strip_string    ${GET_SW}
    log to console    ${GET_SW}
    [Return]    ${GET_SW}

Get RU SW version
    Log To Console  Get RU SW version
    csn.reset_cache
    Connect to gnb coam via ssl
  Connect to Common Unit Master
    Connect to RU With Allocated IP  ru_index=${1}
    ${activeRUBuild}    Get command output on RU    command=sudo SWmanShellCommand -i |grep activeBuildName:|awk '{print $2}'
    log to console    activeBuildName is:${activeRUBuild}
    [Return]  ${activeRUBuild}
    [Teardown]  Run Keywords  Run Keyword And Ignore Error  csn.Disconnect  connection=RU
    ...  AND  Run Keyword And Ignore Error  COAM Teardown gnb connections

Verify RMOD With incompatible Software
    [Arguments]    ${RUbuild_before}    ${RUbuild_after}
    Log To Console  Verify RMOD With incompatible Software
    Should Not Be Equal As Strings  ${RUbuild_before}  ${RUbuild_after}
    Should Be Equal As Strings  ${RUbuild_after}  ${file_version}

Get Passive file from svn
    [Arguments]    ${Passive_file}
    Log To Console  Get Passive file from svn
    ${path_to_file}=   Set Variable    ${Passive_file}/C_Element/SE_RFM/SS_CTA6/Target/
    ${path_to_svn_file}=    Set Variable    ${path_to_svn}${path_to_file}
    Remove files  ${RU_image_directory}/*
    Run
    ...  svn export --force --username ca_ute_test --password utetest ${path_to_svn_file} ${RU_image_directory}
    ${RU_tmp}  Run  ls -al ${RU_image_directory}rfsw-package-aqql_* |head -1 | awk '{print $9}'
    @{split_version}    string.split string    ${RU_tmp}    separator=/
    ${RU_image_tmp}    set variable     ${split_version}[-1]
    ${RU_image}  Set Variable  ${RU_image_tmp.split("\r\n")[0]}
    @{split_tmp}    string.split string    ${RU_image}    separator=.
    ${checksum_tmp}    set variable     ${split_tmp}[0]
    @{split_version}    string.split string    ${checksum_tmp}    separator=_
    ${checksum}    set variable     ${split_version}[-1]
    #${checksum}  Convert To Lower Case  ${checksum_tmp}
    [Return]  ${RU_image}  ${checksum}

Upload passive file to RU and Install SW
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    Connect to RU With Allocated IP  ru_index=${1}
    ${ru_target_build}  COAM get ru sw version from target BD file
    ${RU_image}  ${checksum}  Get Passive file from svn  Passive_file=${ru_target_build}
    Upload file to RU  RU_image=${RU_image}
    Set Test Variable  ${file_version}  ${ru_target_build}
    Install passive SW on RU  RU_image=${RU_image}  checksum=${checksum}
    [Teardown]  Run Keywords  Run Keyword And Ignore Error  csn.Disconnect  connection=RU
    ...  AND  Run Keyword And Ignore Error  COAM Teardown gnb connections

Install passive SW on RU
    [Arguments]    ${RU_image}  ${checksum}  ${ru_alias}=RU
    Log To Console  Install SW on RU
    ${out}  Get command output on RU  command=sudo SWmanShellCommand -s /tmp/${RU_image} ${checksum} ${checksum} ""
    should contain   ${out}   OK
    csn.send command    \n    connection=${ru_alias}

Calculate KPI
    [Arguments]    ${kpi_list}    ${result_save_name}=kpi     ${need_average}=${False}
    ...    ${kpi_params}=${None}    ${connection}=GNB_OAM
    ...    ${all_ims}=${None}
    [Documentation]    This kw is used to calculate the KPI
    ...    Author: Winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | kpi_list | yes | the kpi need calculate,like kpi1a, kpi1b, kpi1c |
    ...    | result_save_name | No | save result result name |
    ...    | need_average | No | need average value or others |
    ...    | kpi_params | No | for specific kpi that need input params |
    ...    | disconnect_ims | No | for kpi4 uuf that need disconnected ims logs |
    ...    Example
    ...    | ${kpi3_param} | create dictionary | start_point_timestamp=${kpi_cal_starttime} |
    ...    | ${kpi_params} | create dictionary | kpi3=${kpi3_param} |
    ...    | Calculate KPI | kpi_list=@{SBTS_Cold_Reset_WO_HWF_KPI} | kpi_params=${kpi_params} |
    ...
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    coam.collect_infomodel_log_from_current_session
    ...    target_file_name=${TS_CASE_LOG_PATH}${/}KPI_calculate_${timestamp}.ims2
    ...    connection=${connection}
    ${ims_file_paths}    Run Keyword If    "${all_ims}"!="${None}"
    ...    Set Variable    ${all_ims}
    ...    ELSE    Set Variable    ${TS_CASE_LOG_PATH}${/}KPI_calculate_${timestamp}.ims2
    Run Keyword If    "${all_ims}"!="${None}"
    ...    Append To List    ${ims_file_paths}    ${TS_CASE_LOG_PATH}${/}KPI_calculate_${timestamp}.ims2
    oam_kpi.calculate_kpis    kpi_names=${kpi_list}
    ...    ims_file_path=${ims_file_paths}
    ...    kpi_params=${kpi_params}
    oam_kpi.save_results_to_file  file_path=${TS_CASE_LOG_PATH}${/}${result_save_name}.json
    ${kpi_results}    Run Keyword If    ${need_average}    oam_kpi.get_average_results
    ...    ELSE    oam_kpi.get_results
    [Return]    ${kpi_results}
    [Teardown]    oam_kpi.clear_results

Get rmod port
    ${links}  coam.Get Sfp Links  timeout=20  connection=GNB_OAM
    ${connected}  Collections.Get From Dictionary  ${links}  connected
    ${numb_of_links}  BuiltIn.Get Length  ${connected}
    FOR  ${x}  IN RANGE  ${numb_of_links}
      ${rmod_name}  Set Variable  ${links["connected"][${x}]["parent"]["source"]["parameters"]["productName"]}
      ${status2}  Run Keyword And Return Status  Should Contain  ${rmod_name}  AQQQA
      Run Keyword If  ${status2}  Run Keywords  Set test Variable  ${rmod_port}
      ...  ${links["connected"][${x}]["parent"]["source"]["physicalPort"]}  AND  Exit For Loop
    END
    ${rmod_port}  Convert To String  ${rmod_port}
    ${rf_port_tmp}    Fetch From Right    ${rmod_port}   OPT_IF
    ${rf_port_id}  Evaluate  ${rf_port_tmp}-1
    [Return]  ${rf_port_id}

8680_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Arguments]    ${is_get_snapshot_via_selenium}=${False}
    log to console    Wait 10 mins before Collect Snapshot
    sleep    600
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
        8680_Verify RFSW Log Include In Snapshot  ru_index=${ru_index}  ru_alias=RU_${ru_index}  snapshot_path=${SAVE LOG DIRECTORY}
        ...    is_get_snapshot_via_selenium=${is_get_snapshot_via_selenium}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

8680_Verify RFSW Log Include In Snapshot
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...    is_get_snapshot_via_selenium: if set to ${True} use selenium for collect, if ${False} use rest api
    [Arguments]   ${ru_index}=${1}   ${ru_alias}=RU   ${connection}=GNB_OAM   ${snapshot_path}=${TS_CASE_LOG_PATH}    ${timeout}=900
    ...    ${is_get_snapshot_via_selenium}=${False}

    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${version}=    Set Variable If
    ...     '${stream}'=='SBTS24R3'        SBTS24R3
    ...     '${stream}'=='SBTS25R1'        SBTS25R1
    ...     '${stream}'=='SBTS25R3'        SBTS25R3
    ...     '${stream}'=='SBTS25R2'        SBTS25R2
    ...     SBTS00
    ${prefix_name}    Set Variable If   '${version}'=='SBTS24R3' or '${version}'=='SBTS25R1'    BTS    BTS${mrbtsID}
    ${log_on_snapshot}   Run keyword if    ${is_get_snapshot_via_selenium}
    ...    Get RFSW Log File List On Snapshot via webUI    ru_index=${ru_index}    snapshot_path=${snapshot_path}    connection=${connection}
	...    prefix_name=${prefix_name}
    ...    ELSE    Get RFSW Log File List On Snapshot  ru_index=${ru_index}    snapshot_path=${snapshot_path}    connection=${connection}
    ...    timeout=${timeout}  prefix_name=${prefix_name}
    ${log_on_ru}   Get RFSW Log File List On RU   connection=${ru_alias}    download_dir=${snapshot_path}
    ${not_include_list}    Create List
    FOR  ${item}  IN  @{log_on_ru}
       ${status}  Run Keyword And Return Status  Should Contain Match   ${log_on_snapshot}   regexp=.*${item}.*
       Run Keyword If  ${status}==${False}     Append to List    ${not_include_list}     ${item}
    END
    ${length}    Get Length    ${not_include_list}
    Should Be Equal As Integers   ${length}   ${0}   msg=Item ${not_include_list} not include in snapshot logs

8680_Manual_SiSo_SM_RF_Module_lock_unlock
    [Arguments]  ${call_keyword}=UE Attach and Start traffic
    ${ru_index_list}    get all ru index
    Selenium Login And Disable Screen Lock

    FOR  ${lock_id}  IN  ${ru_index_list}[0]
        Sleep    3s

        Run Keyword And Continue On Failure  ${call_keyword}
        ${operate_list}    create list    ${lock_id}
        Lock and unlock RU    operate_list=${operate_list}
        Sleep    3s
        Run Keyword And Continue On Failure  ${call_keyword}

    END
    [Teardown]    Selenium Logout And Close Browser


Lock and unlock RU
    [Arguments]  ${operate_list}
  FOR  ${i}  IN RANGE  10
        Log To Console  lock and unlock RU ${i} times
        Lock all RUs SISO    ru_index_list=${operate_list}
        Sleep    3s
        Unlock all RUs SISO    ru_index_list=${operate_list}
        Sleep    3s
    END

8680_General_SiSo_RF_module_reset_from_GUI_with_L3call
   [Arguments]      ${connection}=GNB_OAM    ${gnb_index}=0  ${call_keyword}=UE Attach and Start traffic
    ${ru_index_list}     Get All RU Index    connection=${connection}
    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        log to console    \n***RF Module index ${ru_index} Reset from GUI***
        ${ru_index}  Convert To Integer    ${ru_index}
        RF_module_reset_from_GUI_with_L3call    ru_index=${ru_index}  call_keyword=${call_keyword}

    END
    Connect to gnb coam via ssl
    Check RF Startup and Gnb Status    ${ru_index_list}    gnb_index=${gnb_index}    connection=${connection}
    verify all cells should be onair    connection=${connection}
    [Teardown]    Selenium Logout And Close Browser


RF_module_reset_from_GUI_with_L3call
    [Arguments]   ${ru_index}  ${call_keyword}=UE Attach and Start traffic
  FOR  ${i}  IN RANGE  5
        Log To Console  reset ru ${i} times
        selenium_coam.reset_ru  ru_index=${ru_index}
        Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
        Sleep    300s
        Wait Until Keyword Succeeds    20min    5s    verify all cells should be onair    connection=${connection}
        sleep    60s
        wait until keyword succeeds    3x    5min  Run Keyword And Continue On Failure  ${call_keyword}
    END

8680_E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Arguments]   ${call_keyword}=UE Attach and Start traffic
    [Documentation]  default path:/home/ute/UUF_SW/SBTS
    Check Rollback is needed before sw upgrade
    Get BTS SW Version    gnb_index=${0}
    ${target_sw}  ${target_sw_link}  get sw name  SW=${PASSIVE_SW}
    ${5g_target_sw}  ${bts_version}    Split String From Right    ${target_sw}    _release_     1
    Create swconfig file
    AlarmWatchdog.add_allow_alarms    fault_id=61649
	AlarmWatchdog.add_allow_alarms    fault_id=16
	AlarmWatchdog.add_allow_alarms    fault_id=4714
    Add fault id to exist fault
    ${NODES}  Prepare Nodes  target_sw=${5g_target_sw}  source_sw=${ACTIVE_SW}
    CSV4AllTestCases.E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...     iterations_per_node=${runs_of_uuf_upgrade_withcall}
    ...          customers_list=${customers}
    ...          report=${should_be_reported}
    ...    restore_to_target_sw=${False}
    ...          l3_call_method=${call_keyword}
    # AlarmWatchdog.remove_allow_alarms    fault_id=61649
    [Teardown]  Run Keyword And Ignore Error  OperatingSystem.Remove Directory  ${UUF_path}  recursive=True

Add fault id to exist fault
    [Arguments]  ${faultid}=${61649}
    ${ALLOWED_FAULT}    Copy List    ${exist_fault}
    Set test variable    ${ALLOWED_FAULT}
    add fault to the allowed fault list    faultId=${faultid}
    ${exist_fault}    Copy List    ${ALLOWED_FAULT}
    Set test variable    ${exist_fault}

8680_UUF_SW_Activation_Reset
    [Arguments]   ${call_keyword}=UE Attach and Start traffic
    [Timeout]   24h
    Create swconfig file
    AlarmWatchdog.add_allow_alarms    fault_id=61649
    Add fault id to exist fault
	Get BTS SW Version    gnb_index=${0}
    ${NODES}  Prepare Nodes  target_sw=${download_build}  source_sw=${download_build}
    CSV4AllTestCases.E2E TL ACTIVATION RESET TEST
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODES}
    ...     iterations_per_node=${runs_of_uuf_reset_withcall}
    ...          customers_list=${customers}
    ...          report=${should_be_reported}
    ...          l3_call_method=${call_keyword}
#    AlarmWatchdog.remove_allow_alarms    fault_id=61649

Prepare Nodes
    [Arguments]  ${target_sw}=${Active_SW_version}  ${source_sw}=${Active_SW_version}
    ${NODES}    Create List
    ${node_dict}    Create Dictionary  node_alias=gnb  testline_object=${tl.gnbs[0]}
        ...    source_sw=${source_sw}
        ...    target_sw=${target_sw}
        ...    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS}
        ...    custom_allowed_alarms=${critical_faults}
    Append To List    ${NODES}    ${node_dict}
    [Return]  ${NODES}

Get the target build Path
  [Arguments]  ${5g_target_sw}
  ${target_path1}  Set Variable  ${cloud_ute_directory}/${5g_target_sw}/${5g_target_sw}_release_BTSSM_downloadable_A54.zip
    ${cmd1}  Set Variable  ls ${target_path1}
    ${rc1}  ${output1}  Run And Return Rc And Output  ${cmd1}
    ${exist1}  Run Keyword And Return Status  Should not contain  ${output1}  No such file or directory
    ${target_path2}  Set Variable  ${PATH_Storage}/${5g_target_sw}_release_BTSSM_downloadable_A54.zip
    ${cmd2}  Set Variable  ls ${target_path2}
    ${rc2}  ${output2}  Run And Return Rc And Output  ${cmd2}
    ${exist2}  Run Keyword And Return Status  Should not contain  ${output2}  No such file or directory
    Run Keyword And Continue On Failure  create directory  ${file_Storage}
    ${5G_pakage_path}  Run Keyword If  '${exist1}'=='${True}'  Set Variable  ${target_path1}
    ...  ELSE IF  '${exist2}'=='${True}'  Set Variable  ${target_path2}
    ...  ELSE  _DownLoad Target SW to UTE    package_link=${package_link}
    ...   target_version=${5g_target_sw}    local_path=${file_Storage}
    Log To Console  Get the target build Path
    [Return]  ${5G_pakage_path}

Create swconfig file
  [Arguments]    ${connection}=ASIK Master    ${gnb_index}=${0}    ${du_index}=${0}
  Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
  Connect to Common Unit Master    alias=${connection}    gnb_index=${gnb_index}    du_index=${du_index}
  ${exist_1}  csn.File Exists  /ffs/run/swconfig.txt  connection=${connection}
  Run Keyword If  not ${exist_1}  csn.execute  echo '0x10041=5' > /ffs/run/swconfig.txt  connection=${connection}
  Log To Console  Create swconfig file
  ${count_smods}  Get SMOD Num
  Run Keyword If    ${count_smods}>${1}  Create swconfig file for right SMOD
  [Teardown]  Run Keyword And Continue On Failure  ssh.Disconnect  connection=${connection}

Create swconfig file for right SMOD
  [Arguments]    ${connection}=ASIK Master    ${gnb_index}=${0}    ${du_index}=${0}
    ...            ${connection_right}=ASIK Right
  csn.connect to
    ...               hostname=fct-4a
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection_right}
    ...               proxy=${connection}
  ${exist_2}  csn.File Exists  /ffs/run/swconfig.txt  connection=${connection_right}
  Run Keyword Unless  ${exist_2}  csn.execute  echo '0x10041=2' > /ffs/run/swconfig.txt  connection=${connection_right}
  Log To Console  Create swconfig file for right SMOD
  [Teardown]  Run Keyword And Continue On Failure  csn.Disconnect  connection=${connection_right}

Get SMOD Num
    ${hw_info}    coam.get_detected_hw_info    connection=GNB_OAM
    @{list_smods}    Set variable    ${hw_info['systemModules']}
    ${count_smods}    Get length    ${list_smods}
    Should be true    ${count_smods}>=${1}    msg=Check SMOD status failed as total SMOD number is less than 1
    Log To Console  Get SMOD Num:${count_smods}
    [Return]   ${count_smods}

RU_entering_deep_sleep_mode_after_the_last_cell_locked
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify RU is entering deep sleep mode
    ...    when all carriers are deactivated
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.09.2020 - - Created
    ...    *******************
    ...    Owner_xuewen.zhang@nokia-sbell.com
    [Arguments]    ${LOOPS}=${1}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock    version=${stream}
    log to console  \n Disable 5GC000431
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    version=${stream}
    # Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false
    # log to console  \n Enable CB007511
    # Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    # ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=DEEPSLEEP
    log to console  \n Lock all cells
    ${lock_list}  Get All Cell Id
    FOR  ${loop}  IN RANGE  ${LOOPS}
        Lock cells or groups and check status  lock_list=${lock_list}  is_group=${False}  check_alarm=${False}
            ...    gnb_type='${gNb_CuType}'
        log to console  \n Wait 600s
        sleep    600
        Run Keyword And Ignore Error    Selenium Logout And Close Browser
        wait until keyword succeeds    10x   10s    Selenium Login And Disable Screen Lock    version=${stream}
        Wait until keyword succeeds    5min    30s    RU1_AQQL Status Info Should Be Sleep
        Unlock cells or groups and check status from sleep mode  lock_list=${lock_list}  is_group=${False}  check_alarm=${False}
        sleep    300
        Wait until keyword succeeds    5min    30s    RU Status Info Should Be Normal
    END
    [Teardown]    Run keywords
    # Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=true
    # ...    AND   Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    # ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=NORMAL
    ...    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    ...    AND   Selenium Logout And Close Browser
