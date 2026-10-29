*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD
#...             CONFIGS_Bangalore/RRM/ET/CB008983/CB008983_A_06_MUE_SA.yml
#...               RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00     CONFIGURED   CRT

Documentation    :copyright: Nokia
...   CB008983:The aim of the feature is to support  1Tx DL and 2Rx UL per cell operation for NR FDD
...   REQUIREMENT_ID : 5G_RAN_USR_RRM_16660;5G_CP_ARC_ALG_7586;5G_CP_IF_RRC_9019;5G_CP_IF_RRC_9380;5G_CP_IF_RRC_9381;
...   5G_CP_IF_RRC_9382;5G_CP_IF_RRC_9383

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../CB008983/resources/CB008983_Resource.robot
Resource         ../resources/robot/common_log_collection.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          OperatingSystem
Library          taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library          taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Resource         ../resources/robot/AIC_Common_Keywords.robot
Resource         ../resources/robot/Common_Keywords.robot
Resource         ../resources/robot/ConformanceConstants/Constants_general.robot
Resource         ../CB009567/resource/9567_resource.robot
Resource         ../resources/robot/ConformanceConstants/Constants_for_Syslog.robot


Suite Setup             Run keywords     Test Suite Setup
...                     AND              AIC Software Build Info
...                     AND              Fetch Taf Library used in TL
...                     AND              Fast Delta Commission vDU With Delta XML File   ${delta_vdu}
...                     AND              Run keyword and Ignore error   Verify RMODs Online Status   ${1000}
...                     AND              log to console   loading cfg file
...                     AND              Configure UTE ETH3 IPs
...                     AND              Start WTS Using WTS_Runner      ${wts_cfg_file}



Suite Teardown         Run keywords        Kill WTS processes Using WTS_Runner

#Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#Test Teardown    Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/wts/basic_FDD_8983_T_F.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}               1
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${st_ue_id}            1
${en_ue_id}            8
${value}               0
${file_path}           /opt/iphy/latest/egate_console.log
${mimolayer}           4
${ss_pbch_power}       10
${overhead}            xOh6
${no_of_ports}         1
${cdm_type}            fd-CDM2
${density}             one
${delta_vdu}           ${CURDIR}/config/SBTS24R2/Delta_configuration_scf_MRBTS-CB008983.xml
${robotws}             /home/ute/MN/UTE/robotws
@{Cell_list}           NRCELL-1    NRCELL-2    NRCELL-3    NRCELL-4

*** Test Cases ***
[1][1.0] CB008983_A_5_robustness_SA_4UE_Attach_Data_Transmission
     [Documentation]      support for 1Tx DL and 2Rx UL per cell operation for NR FDD
    set test variable      ${LOG_PATH}
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set test variable     ${TEST_NAME}    
    Attach Multi Ue and Start Data
    Run Keyword And Continue on Failure     Verify egate and TTI trace
    Validate THP and Dettach UE


*** Keywords ***
Verify egate and TTI trace
    Verify 1TX config from egate_log     0    ${st_ue_id}    ${en_ue_id}    1
    set test variable      ${crnti_list}
    sleep  10s       reason=Wait for traffic to start
    ${cells}  create list   NRCELL-3
    Log To Console    \nStartingTTICapture
    Start L2Ps TTI logs from vDU    ${Cell_list}
    sleep  3s
    ${tti}    Stop L2Ps TTI logs from vDU    test_scenario=Ue_DLUL_data
    Decode TTI Trace    Ue_DLUL_data
    ${numofLayer}    Create List     RANK1    RANK1    RANK1    RANK1    RANK1    RANK1    RANK1    RANK1
    Validate numofLayers from TTI traces    ${tti}[ttitrace]    ${crnti_list}   ${numofLayer}
    Log To Console    \nDoneTTICapture



Attach Multi Ue and Start Data
    log to console   UE attach trigerring now...
    ${crnti_list}=     MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}
    set test variable      ${crnti_list}
    MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=14
    ...    pdu_id=${Pdu_session_ID}    trf_id=1       qfi_id=${qfi_id}
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     ul_rate=14
    ...    pdu_id=${Pdu_session_ID}    trf_id=1       qfi_id=${qfi_id}


Validate THP and Dettach UE
    sleep  60s       reason=Wait for traffic to start
    Run Keyword And Continue on Failure   Validate CellTHP For SA MultiUE    90    dl    ${st_ue_id}    ${en_ue_id}
    Run Keyword And Continue on Failure   Validate CellTHP For SA MultiUE    115    ul    ${st_ue_id}    ${en_ue_id}
    wtsrunner.ue_stats_nr     id=1-4     scell=0     type=pusch
    wtsrunner.ue_stats_nr     id=1-4     scell=0     type=pdsch
    sleep  3s
    Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    Run Keyword And Continue on Failure     MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

Validate CellTHP For SA MultiUE
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    ...                3. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${dl_rate}    ${dir}    ${st_ue_id}    ${en_ue_id}
    FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        wtsrunner.bearer_stats  ue=${ue_id}   pdu=1   qfi=1   dir=${dir}
        ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=10
        ${output}         Get Regexp Matches    ${bearer_stat_dl}    Average data rate +(\\d+)    1
        ${value} =    Evaluate      ${value}+int(${output[0]})
        log to console    Average data rate for UE : ${ue_id} is int(${output[0]})
    END
    ${result}         Evaluate    (${dl_rate} * 1000000 * 1.1) > int(${value}) > (${dl_rate} * 1000000 * 0.9)
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${value}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${value}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!

Verify SA log
    [Arguments]     ${file_path}    ${DSS_flag}    ${SA_flag}
	verify_reconfig.check_reconfig_msg     ${file_path}    ${SA_flag}
    verify_reconfig.check_rrcsetup_msg    ${file_path}

    FOR    ${INDEX}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        OperatingSystem.Run    mv ${robotws}/Reconfig_MSG_* ${LOG_PATH}/
        OperatingSystem.Run    mv ${robotws}/RrcSetup_MSG_* ${LOG_PATH}/
        ${output}    OperatingSystem.Get File   ${LOG_PATH}/Reconfig_MSG_${INDEX}.txt
#       xOverhead is coming in DSS case only
        Run Keyword If    ${DSS_flag} == 1    BuiltIn.Should Match Regexp    ${output}    xOverhead\\s${overhead}
        Run Keyword If    ${DSS_flag} == 1    BuiltIn.Should Match Regexp    ${output}
        ...    lte-CRS-ToMatchAround setup.*\\n.*\\n.*\\n.*\\n.*nrofCRS-Ports\\sn${no_of_ports}.*\\n.*v-Shift\\s${v-Shift}
        Run Keyword If    ${DSS_flag} == 1    BuiltIn.Should Match Regexp     ${output}
        ...     pdsch-ServingCellConfig setup.*\\n.*\\n.*\\n.*\\n.*maxMIMO-Layers\\s${mimolayer}
        ...     ELSE    BuiltIn.Should Match Regexp     ${output}
        ...     pdsch-ServingCellConfig setup.*\\n.*\\n.*maxMIMO-Layers\\s${mimolayer}
#       Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}    ss-PBCH-BlockPower\\s${ss_pbch_power}
        ${output2}    OperatingSystem.Get File    ${LOG_PATH}/RrcSetup_MSG_${INDEX}.txt
        BuiltIn.Should Match Regexp     ${output2}
        ...     nzp-CSI-RS-ResourceToAddModList.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*frequencyDomainAllocation other : '000001'B
        BuiltIn.Should Match Regexp     ${output2}
        ...     nzp-CSI-RS-ResourceToAddModList.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*nrofPorts\\sp2
        ...  .*\\n.*\\n.*cdm-Type\\s${cdm_type}.*\n.*density\\s${density}
    END
