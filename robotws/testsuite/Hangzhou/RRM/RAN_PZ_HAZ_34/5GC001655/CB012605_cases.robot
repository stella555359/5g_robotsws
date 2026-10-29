*** Settings ***
Documentation     author: Yu Lu
...               contact: lu.1.yu@nokia-sbell.com
...               squad group: SG_02
Suite Setup       Common Suite Setup for COAM
Suite Teardown    Common Suite Teardown
Force Tags        5G_RRM
...    PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/Resource_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          Resources/1347_common_keyword.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          Resources/common_keyword_RRM_SG2.robot

*** Variables ***
${data_transfer_dl}     2000Mbits/sec
${data_transfer_ul}     200Mbits/sec

${Expected_Throughput_DL}     100
${Expected_Throughput_UL}     10


*** Test Cases ***
[1]CB012605_B_1_ allocate cell-specific PUCCH stream-PRBs during cell addition_6_cells
    [Setup]    Case Setup
#    enable 72e Load Case SCF and Commission SCF for 12605    scf_file_path=commissionings/HGZ/7_5_UTE5G402T792/${version}_CB012605.xml
    Reload Case SCF and Commission    scf_file=${SCF_PATH}/commissionings/HGZ/7_5_UTE5G402T792/${version}_CB012605.xml
#    Restart CPE proxy
#    Reboot cpe for test    ue_index=${8}
#    Sleep    5min
#    Run keyword and ignore error    Start Btslog Collect
#    muti ue traffic and catch TTI
#    Run keyword and ignore error    Stop Btslog Collect    target_dir=${TS_CASE_LOG_PATH}
#    check TTI for 12605    TTI_path=&{tti_log_path}[DL]
    [Teardown]    Case Teardown

*** Keywords ***
Common Suite Setup for COAM
    Connect to gnb coam via ssl
    robot_common_operations.Common Suite Setup
    ${version}     get software version
    Set suite variable    ${version}    ${version}
    Get SCF path for 12605    version=${version}
#    Recover swconfig file for 12605     swconfig_file=${SCF_PATH}/commissionings/HGZ/7_5_UTE5G402T792/swconfig.txt

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file}    timeout=400
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Common Suite Teardown
    robot_common_operations.Common Suite Teardown

Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
#    robot_common_operations.Common Case Setup    allowed_faults_ids=4282
    robot_common_operations.Common Case Setup

enable 72e Load Case SCF and Commission SCF for 12605
    [Arguments]    ${scf_file_path}
    enable 72e and commission scf    scf_path=${SCF_PATH}/${scf_file_path}    activate_plan_despite_errors=${True}
    ...                              is_need_to_check_validation_errors=${False}
    COAM Wait for gnb ready and cell setup    timeout=15 min

Recover swconfig file for 12605
    [Arguments]  ${swconfig_file}
    Connect to Common Unit Master
    Upload_swConfig_file_to_asik_and_crasign    localFilePath=${swconfig_file}    asik_alias=ASIK Master
    Csn.Disconnect    connection=ASIK Master

Get SCF path for 12605
    [Arguments]  ${version}
    Selenium Login And Disable Screen Lock    version=${version}
    log to console  ${CURDIR}
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -47
    Set suite variable    ${SCF_PATH}    ${SCF_PATH}
    log to console    ${SCF_PATH}

Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run keyword and ignore error    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

get software version
    COAM Navigate to login page via webUI
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    Set suite Variable    ${current_version}    ${current_version['Active']}
    COAM selenium logout
    ${stream}    String.Get Substring    ${current_version}    0    8
    [Return]     ${stream}

check TTI for 12605
    [Arguments]    ${TTI_path}    ${filte_item}
    ${values}    check_tti_by_value    file_path=${TTI_path}    filte_item=${filte_item}    find_value=gbrPrbLoad

muti ue traffic and catch TTI
    cpe attach and traffic
    spark attach and traffic
    &{tti_log_path_GBR}    Capture TTI log
	Set Test Variable    &{tti_log_path}
	cpe collect tuput and stop traffic
	spark collect tuput and stop traffic

cpe attach and traffic
    [Arguments]  ${throughput_ul}=200M    ${throughput_dl}=2000M
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[2]
    Set Test Variable      ${cell1}      ${cell1}
    log to console    \n***Prepare UE_9***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${8}
    Set Test Variable      ${ue_type}      ${ue_type}
#    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${8}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${throughput_ul}     duration=2000    process_num=5
    ...       ue_index=${8}
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${throughput_dl}     duration=2000
    ...       ue_index=${8}

cpe collect tuput and stop traffic
    [Arguments]  ${target_throughput_ul}=100    ${target_throughput_dl}=1200
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m    check_source=Aasyslog
    ...      ue_index=${8}
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${cell1}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}    check_source=Aasyslog
    ...        ue_index=${8}
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${cell1}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}    check_source=Aasyslog
    ...       ue_index=${8}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl    ue_index=${8}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul    ue_index=${8}

spark attach and traffic
    ${cells}    Get NRcellid list
    ${cell2}    Create list    ${cells}[0]
    Set Test Variable      ${cell2}      ${cell2}
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=0
    Set test variable    ${ue_type_spark}    ${ue_type}
    log to console      "4UE_attach_Tput"
    spark UEs attach and start DLUL traffic    duration=3s    ue_num=${4}

spark UEs attach and start DLUL traffic
    [Arguments]     ${ue_num}    ${apn_address}=dxdata1    ${ue_mode}=SA    ${attach_mode}=5G_SA
    FOR    ${i}    IN RANGE    ${ue_num}
        spark attach and start DLUL traffic     data_transfer_dl=${data_transfer_dl}
        ...                                     data_transfer_ul=${data_transfer_ul}
        ...                                     n=${i}
        ...                                     ue_mode=${ue_mode}
        ...                                     attach_mode=${attach_mode}
        ...                                     apn_address=${apn_address}
    END

spark attach and start DLUL traffic
    [Arguments]     ${data_transfer_dl}    ${data_transfer_ul}    ${n}
    ...             ${apn_address}    ${ue_mode}    ${attach_mode}
    [Documentation]    Attach_start_DL_UL_tput
    ...          :param  n: The ue_index of Spark
    ...          :param  ue_mode: start traffic for NSA or SA
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    run keyword and ignore error    Spark UE attach    n=${n}    attach_mode=${attach_mode}
    sleep      2s
    power_ue.Start traffic     ue_type=${ue_type_spark}    direction=dl    throughput=${data_transfer_dl}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
    power_ue.Start traffic     ue_type=${ue_type_spark}    direction=ul    throughput=${data_transfer_ul}    duration=3000
    ...                        ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}

Spark UE attach
    [Arguments]    ${n}    ${attach_mode}    ${get_spark_license}=False
    [Documentation]    Attach
    ...          :param  n: The ue_index of Spark
    ...          :param  attach_mode: attach for 5G_NSA or 5G_SA
    ...          :param  nettype:  Spark HO for 'NSA' or 'SA+NSA' or 'AUTO'
    log to console      "Prepare_UE${n}"
    power_ue.Prepare UE     ue_type=${ue_type_spark}    ue_index=${n}    get_spark_license=${get_spark_license}
    sleep      3s
    log to console      "attach_UE${n}"
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type_spark}     attach_mode=${attach_mode}    ue_index=${n}
    power_ue.Verify attach     ue_type=${ue_type_spark}    4G_check=False    5Grach_ed=${5Grach_ed}     ue_index=${n}

spark collect tuput and stop traffic
    log to console      "4UE_check_Tput"
    Run Keyword And Ignore Error    Check throughput on gNB    direction=dl    throughput=300    cellid=${cell2}
    Run Keyword And Ignore Error    Check throughput on gNB    direction=ul    throughput=10    cellid=${cell2}
    Run Keyword And Ignore Error    All UEs Check Tput    num=4
    log to console      "4UE_stop_Tput"
    All UEs Stop traffic    j=4    apn_address=dxdata1

Check throughput on gNB
    [Arguments]    ${direction}    ${throughput}    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}
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

All UEs Check Tput
    [Arguments]     ${num}=10
    FOR    ${i}    IN RANGE    ${num}
        Check Tput for one UE     n=${i}
    END

Check Tput for one UE
    [Arguments]     ${n}
    [Documentation]    check_tput
    ...                :param  n: The ue_index of Dingli
    log to console      "check traffic UE${n}"
    run keyword and ignore error    power_ue.Check throughput    ue_type=${ue_type_spark}    direction=dl    throughput=${Expected_Throughput_DL}
    ...                                                          ue_index=${n}
    run keyword and ignore error    power_ue.Check throughput    ue_type=${ue_type_spark}    direction=ul    throughput=${Expected_Throughput_UL}
    ...                                                          ue_index=${n}

All UEs Stop traffic
    [Arguments]     ${apn_address}    ${ue_mode}=SA    ${j}=10
    [Documentation]    stop_DLUL_traffic
    FOR    ${i}    IN RANGE    ${j}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type_spark}    direction=dl    ue_index=${i}    ue_mode=${ue_mode}
        ...                                                      apn_address=${apn_address}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type_spark}    direction=ul    ue_index=${i}    ue_mode=${ue_mode}
        ...                                                      apn_address=${apn_address}
    END
