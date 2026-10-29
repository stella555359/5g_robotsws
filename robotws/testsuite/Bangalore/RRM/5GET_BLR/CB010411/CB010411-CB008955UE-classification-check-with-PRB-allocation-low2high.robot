*** Settings ***
Force Tags      CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH     CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH


Documentation    :copyright: Nokia
...         The aim of the CB008955 feature is to to increase overall throughput performance in the cluster of cells.
...         By limiting the interference level experienced by high performing UEs.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         This user scenario validates configuration parameters related to choosing of eligible Ues on the basis of
...         MCS and PRB allocation at least 273 PRB from high2low on 100MHz

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner

Resource         ./8955_new_resources.robot
#Resource          ./resources/common/common_setup_teardown.robot
#Library          ./resources/python/read_csv.py

########### AIC ###########
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
#Library             taf.transport.ssh           WITH NAME    taf_ssh
#Library             taf.wts.runner              WITH NAME    wtsrunner
Library             taf.collectors.tcpdump    WITH NAME    tcpdumpAIC
Library             taf.collectors.l2stream3    WITH NAME    l2stream3AIC
Library             taf.collectors.core    WITH NAME    coreAIC
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot

Suite Setup             Run keywords     Test Suite Setup
...                     AND              AIC Software Build Info
...                     AND              Fetch Taf Library used in TL
...                     AND              Fast Delta Commission vDU With Delta XML File   ${delta_vdu}
...                     AND              Fast Delta Commission vCU Using Delta XML File   ${delta_cu}
...                     AND              sleep    60s
...                     AND              Run keyword and Ignore error   Verify RMODs Online Status   ${800}
...                     AND              sleep    60s
...                     AND              log to console   loading cfg file
...                     AND              Configure UTE ETH3 IPs
...                     AND              Start WTS Using WTS_Runner      ${wts_cfg_file}
...                     AND              sleep  120s
Suite Teardown         Run keywords        Kill WTS processes Using WTS_Runner



*** Variables ***
${delta_vdu}                ${CURDIR}/config/SBTS25R1/8955_DU_delta.xml
${delta_cu}                 ${CURDIR}/config/SBTS25R1/8955_CU_delta.xml
${wts_cfg_file}     ${CURDIR}/config/wts/8955.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${Q_O_ADD}      1
${RTP_COD}      1
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${3}
${st_ue_id_1}    ${3}
${en_ue_id_1}    ${3}


*** Test Cases ***
[1]CB008955_UE-Classification_with_PRB_allocation_low2high_with_100mhz_with_VRAn4.0_gNB_with_2_UE

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console     ${LOG_PATH}
    ${TESTCASE_LOG_PATH}  Set Variable     ${LOG_PATH}
    set test variable     ${TESTCASE_LOG_PATH}
    Make MultiUE 5qi1 call with varying cqi and collect ttitrace
    Sleep   5s
    ${cells}  create list   NRCELL-1
    Run Keyword and continue on failure    Start L2Ps TTI logs from vDU    ${cells}
    sleep  3s
    ${tti}    Stop L2Ps TTI logs from vDU    test_scenario=New1
    Run Keyword and continue on failure    Decode TTI Trace    New1
    ${sleep_time} =  Count Measurement Period
    Log to console  Wait ${sleep_time} till new period of counter is started..    console=True
    Sleep  ${sleep_time}s  reason=Wait till new period of counter is started.
    Sleep   600
    Run Keyword and continue on failure    Common_Keywords.Collect pm counter kubectls      "vDU"
    Log to Console    Verifying counters.....
    Run Keyword and continue on failure    Verify UL and DL ScheduledUes with counter_vDU    M55308C10008    M55308C00019    *MRBTS*

*** Keywords ***
Make MultiUE 5qi1 call with varying cqi and collect ttitrace
    MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}
    Sleep   2s
#    Sync With Measurement Period     "vDU"
    MultiUE Trigger DL Traffic for SA    1  1   Traffic_rate=mbps     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    1  1   Traffic_rate=mbps     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    2  2   Traffic_rate=mbps     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    2  2   Traffic_rate=mbps     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    3  3   Traffic_rate=mbps     dl_rate=130       pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    3  3   Traffic_rate=mbps     ul_rate=25        pdu_id=1     trf_id=1     qfi_id=1
    Sleep   30
    Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

Verify egate and TTI trace
    set test variable      ${crnti_list}
    sleep  10s       reason=Wait for traffic to start
    ${numofLayer}    Create List     RANK1    RANK1    RANK1    RANK1    RANK1    RANK1    RANK1    RANK1
    Log To Console    \nStartingTTICapture
    Log To Console    \nDoneTTICapture

Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3



Count Measurement Period
    ${seconds_now} =  Get Current Date  result_format=%S
    ${seconds_int} =  Convert To Integer  ${seconds_now}
    ${time} =  Run Keyword If   1 <= ${seconds_int} <= 59    Subtract Time From Time  60  ${seconds_int}
    ...                  ELSE                                Set Variable  0
    [Return]  ${time}


Collect PM Counters
    [Arguments]  ${target_dir_path}=${LOG_PATH}/pm_counters  ${xml_files_left}=1  ${host}=192.168.255.129
    ...          ${user}=Nemuadmin  ${password}=Nokia@123    ${time_interval}=3 min  ${intervals}=1,2,4

    ${target_dir}  ${name}=  Split String From Right  ${target_dir_path}  separator=/  max_split=1
    ${webservice} =  Create Dictionary
    ...  host=${host}
    ...  user=${user}
    ...  password=${password}
    taf.collectors.pmcounters.create cOAM vDU PM collector
    ...  name=${name}
    ...  webservice=${webservice}
    ...  for_last=${time_interval}
    ...  intervals=${intervals}
    taf.collectors.pmcounters.Setup_Collectors
    ...  names=${name}
    taf.collectors.pmcounters.Collect_Collectors
    ...  names=${name}
    ...  target_dir=${target_dir}
    taf.collectors.pmcounters.teardown_collectors
    ...  names=${name}
    Run  find ${target_dir}/${name} -name '*.xml' | sort -nk1 | head -n -${xml_files_left}| xargs rm -rf
    [Teardown]  taf.collectors.pmcounters.Teardown Collectors  names=${name}


Get Counters Values
    [Arguments]  ${files_path}  ${counter}  ${dist_name}  ${counters_amount}=all
    ${counter_list} =  Create List  ${counter}
    ${pi_dict} =  get_actual_pm_values.Get PI Value
    ...  pi_list=${counter_list}
    ...  pi_dir=${files_path}
    ...  pi_file_pattern=PM*
    ${pi_dict} =  Set Variable If  '${counters_amount}'.lower() == 'all'
    ...                             ${pi_dict}
    ...                             ${pi_dict[-${counters_amount}:]}
    ${all_counters_dicts} =  Evaluate  [list(x.values())[0] for x in ${pi_dict}]
    ${counter_values} =  Evaluate  [x['${counter}']['${dist_name}'] for x in ${all_counters_dicts} if '${counter}' in x.keys()]
    Should Not Be Empty  ${counter_values}  msg=Counter was not collected
    [Return]  ${counter_values}

Verify UL and DL ScheduledUes with counter_vDU
    [Arguments]    ${PM_PCELL_COUNTER1}    ${PM_PCELL_COUNTER2}      ${pi_file_pattern}
    ${path}   Set Variable    /home/ute/logs/CB010411-CB008955UE-classification-check-with-PRB-allocation-low2high/${TEST_NAME}/gnb_pm_counters
    ${a}    Set Variable    /home/ute/test_results
    ${b}    Set Variable          CB010411-CB008955UE-classification-check-with-PRB-allocation-low2high/${TEST_NAME}/
gnb_pm_counters
    ${path1}    Set Variable    ${a}/${b}
    Operatingsystem.Run     mkdir -p ${path1} ; mkdir -p ${path}
    Operatingsystem.Run	    cp -r ${path1}/* ${path}/*
    ${actual_pm_values_1}     Get PM counter value modified    pm_files_location=${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER1}     pi_file_pattern=${pi_file_pattern}
    Should Be True    ${actual_pm_values_1}
    Run Keyword And Continue on Failure    should be true    ${actual_pm_values_1}<=600000
    Log to console     ${actual_pm_values_1}
    ${actual_pm_values_2}     Get PM counter value modified    pm_files_location=${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER2}     pi_file_pattern=${pi_file_pattern}
    Run Keyword And Continue on Failure    should be true    ${actual_pm_values_2}<=5000
    Log to console      ${actual_pm_values_2}

Get PM counter value modified
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}    ${pi_file_pattern}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=${pi_file_pattern}
    ${last_report}    Get From List   ${PM_report_dict_list}     -2
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    Log to Console    ${moc}
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Be Equal  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   #console=${P_console}
    [Return]    ${pi_value}

Validate CS2 list after 10312 flag enabled
    [Arguments]   ${csv_file_path}
    ${Check}    Verify cs2list_DL_10312_on     ${csv_file_path}/output_dl_formated.csv
    run keyword and continue on failure   Run Keyword if   ${Check}!=${True}   Fail   cslist is not matching
    ${Check1}   Verify cs2list_UL_10312_on     ${csv_file_path}/output_ul_formated.csv
    run keyword and continue on failure   Run Keyword if   ${Check1}!=${True}   Fail   cslist is not matching

Verify cs2list_DL_10312_on
    [Arguments]   ${csv_file_path}
    ${Result}    verify_cs2_list.check_cs2_list_DL_10312_on    ${csv_file_path}
    [Return]   ${Result}

Verify cs2list_UL_10312_on
    [Arguments]   ${csv_file_path}
    ${Result}    verify_cs2_list.check_cs2_list_UL_10312_on    ${csv_file_path}
    [Return]   ${Result}

