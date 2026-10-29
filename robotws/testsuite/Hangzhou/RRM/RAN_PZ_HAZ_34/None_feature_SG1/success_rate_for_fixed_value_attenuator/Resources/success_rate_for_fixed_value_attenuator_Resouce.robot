*** Settings ***
Documentation    author:Liu Tiffany
...               contact: tiffany.liu@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC002479
Resource          ../../../5GC000496_C/Resources/L3Call.robot
#Resource          ../../../../../../resources/sites/Hangzhou/PROD/robot/power_ue/power_ue.robot
#Resource          ../../../../../../resources/sites/Hangzhou/PROD/robot/power_ue/UEs/huawei.robot
Resource          ../../../../../OAM/RAN_PZ_HAZ_34/None_Feature_SG1/OAM_Interface.robot
#Resource          ../../../../../../resources/common/coam_selenium.robot
#Resource          ../../../../../../resources/sites/Hangzhou/PROD/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
#Library           ReadJason.py
Library           ../../../5GC000638/Resources/coam_close.py
#Variables         ${CFGFILE_ON_GIT}/Delta_SCF.py
Library           OperatingSystem
Library           DateTime
Library           ute_wtssim
Library           ute_syslog
Library           ute_admin
Library           requests
Library           Collections
Library           Process
Library           String
Library           Telnet
Library           json
#Library           SeleniumLibrary
#Variables         ${CFGFILE_ON_GIT}/TLDelta.py
#Variables         ${CFGFILE_ON_GIT}/CB005752/Delta_SCF.py
#Variables         /home/ute/TAF/cfgfile/2479_Loop_times.py

*** Variables ***
#@{Attach_Rate_Result}          @{None}
#${URL_for_cell_edge}           http://toolscenter.eecloud.dynamic.nsn-net.net/api/oamkpi/cell_edge_input/?version=
#${URL_for_cell_edge}           http://toolscenter.eecloud.dynamic.nsn-net.net/api/oamkpi/cell_edge_input/
#${URL_for_cell_edge}     ${CASE_INPUT_CellEdge['Attach_Rate']['report_server_url']}

${dl_throughput_for_attach}    100Kbits/sec
${ul_throughput_for_attach}    100Kbits/sec
${traffic_time_for_attach}     20
${duration_for_attach}         300
${peak_TP_for_attach}          0
${AF_PATH}                     5G21A_GNB_0011_000800_001706
@{param_name}                  NR SSB RSRP[dBm]   NR SSB SINR[dB]    RRC Status

${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
${UE_TYPE_FOR_SUCCESS_RATE}                  ${tl.ues[0].capabilities[-1]}
${IMSI}                     ${tl.ues[0].imsi}
${IMSI1}                    ${tl.ues[1].imsi}
#${CFGFILE_ON_GIT}         /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
#${GoldenSCF_PATH}         ${GoldenSCF_ON_GIT}/${GoldenSCF}
#${CFGFILE_PATH}           /home/ute/TAF/cfgfile/

#${GoldenSCF_ON_GIT}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/
#${link_to_Artifact}       https://esisoj70.emea.nsn-net.net/artifactory/mnp5g-central-public/System_Release/
${link_to_Artifact}       https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/
${YAFT_PATH}              /opt/ute/YAFT

${CONTROL_PC_IP}            ${tl.ues[0].ssh_connection_details.addr}
${CONTROL_PC_USERNAME}      ${tl.ues[0].ssh_connection_details.username}
${CONTROL_PC_PASSWORD}      ${tl.ues[0].ssh_connection_details.password}

${PROGRAM}                  ${None}

${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_LMP_IP_URL}          https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}


${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

${PB_PORT}                  5000

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${PB_5GRU_IP}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

${MRBTS_ID}                 MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                 NRBTS-${tl.gnbs[0].global_bts_id}

${4G_WEBUI_IP}              ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${5G_WEBUI_IP}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${BTSMOD}                   5GOnly

${PMINTERVAL}               15

##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK2}              asik2                                               ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_ABIL}               abil                                                ##
${ALIAS_ABIL_SLAVE}         abil_slave                                          ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ENBCTLPC}           ENB_PC                                              ##
${ALIAS_SHP}                SHP                                                 ##
${ALIAS_LONER}              LONER                                               ##
${ALIAS_ASP_1A}             ASP_1A                                              ##
${ALIAS_APN1}               APN1                                                ##
${ALIAS_APN2}               APN2                                                ##
${UE_alias}                 UE_0                                                ##
${ALIAS_5GC}                5gc                                                 ##
########################END of alias Define#######################################

*** Keywords ***

TestSuite.CommonSuiteStart_for_success_rate
    [Documentation]    1.set log level
    ...                2.generate TL scf
    TestSuite.Start
#    Import Variables    ${CFGFILE_PATH}/Delta_SCF.py
#    Import Variables    ${CFGFILE_PATH}/CB005752/Delta_SCF.py
#    Import Variables     /home/ute/TAF/cfgfilde/2479_Loop_times.py
#    set suite variable   ${GoldenSCF_PATH}         ${GoldenSCF_ON_GIT}/${GoldenSCF}
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    ${Attach_Rate_Result}    create list
    set suite variable   ${Attach_Rate_Result}
    Conn.ResetCache
    gNB.SetLoggingSeverity    LoggingSeverity=debug
    gNB.FormatBTSID    MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
	set suite variable    ${DIST_NAME}   ${MRBTS_ID}/${NRBTS_ID}
#    gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_PATH}/${Golden_SCF}    TLDelta_PATH=${TLDelta_PATH}
#    ...            TestLineSCF_cell_num=1   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    ${info}     Basic.GetStreamInfo     vstring=${AF_PATH}
#    ${StreamInfo}    convert to string    ${info}
    ${StreamTarget}      ${version_Target}      Basic.GetStreamAndVersion    vstring=${AF_PATH}
    set suite variable    ${StreamTarget}

#    ${TL_S1_base_SCF}    Run Keyword If    "${StreamInfo}"=="None"    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_PATH}/${Golden_SCF}    TLDelta_PATH=${TLDelta_PATH}
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    ...    ELSE    gNB.Generate TL SCF
#    ...            GoldenSCF_PATH=${GoldenSCF_PATH}/${info['GoldenSCF']}    TLDelta_PATH=${CFGFILE_ON_GIT}/TLDelta_${info['StreamPrefix']}.py
#    ...            TestLineSCF_cell_num=${1}   cell_type=Both
#    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
#    [Return]     ${LOG_PATH}/TestLineSCF1Cell_Both.xml



TC.success_rate_for_fixed_value_attenuator
    [Arguments]  ${retry_times}=10
    Wait until keyword succeeds   20min   1min    COAM_VerifyOnAirViaFrontendAndBackend
     run keyword and ignore error    KW.ModifyCellName
     log    ${StreamTarget}
     run keyword and ignore error    KW.EnableFeatureCounter    Stream=${StreamTarget}
    Log To Console     UE_TYPE:${UE_TYPE}
    @{default_ue_index_list}    Create List    0
    Basic.CheckVariableValid   var=TLCommonConfig['MultiUECFG']['ue_index_for_call']    default_value=@{default_ue_index_list}
    FOR     ${ue_index}    IN    @{TLCommonConfig['MultiUECFG']['ue_index_for_call']}
    Basic.CheckVariableValid   var=TLCommonConfig['MultiUECFG']['${ue_index}']['call_loop']    default_value=10
    L3 Call with traffic    retry_times=5  traffic_time=250  duration=400
    ...    dl_throughput=1MKbits/sec   ul_throughput=1MKbits/sec
    ...    ue_index=${ue_index}    call_loop=${TLCommonConfig['MultiUECFG']['${ue_index}']['call_loop']}
    END
    Should be true    "${Attach_Rate_Result[0]['successrate']}"=="100.0%" and "${Attach_Rate_Result[-1]['successrate']}"!="100.0%"
    ${M55306C06001}    KW.GetCounterSumValue    counter_id=M55306C06001    full_path=[CELL1] CELLS/NRCELL-1/NRACH/RA_MSG3_RECEP
    ${M55306C00002}    KW.GetCounterSumValue    counter_id=M55306C00002    full_path=[CELL1] CELLS/NRCELL-1/NRACH/RA_ATT_CONT_A_PRMBL_SSB_01
    ${M55306C00003}    KW.GetCounterSumValue    counter_id=M55306C00003    full_path=[CELL1] CELLS/NRCELL-1/NRACH/RA_ATT_CONT_A_PRMBL_SSB_02
    ${M55125C02501}    KW.GetCounterSumValue    counter_id=M55125C02501    full_path=[CELL1] CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_STP_REQ_RECD
    ${M55125C02502}    KW.GetCounterSumValue    counter_id=M55125C02502    full_path=[CELL1] CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_STP_RESP_SENT
    ${ssb01_02}    Evaluate    ${M55306C00002}+${M55306C00003}
    ${succ_rate}    Evaluate    ${ssb01_02}/${M55306C06001}
    should be equal    ${M55125C02501}  ${M55125C02502}
    should be true    ${succ_rate}>=1 and ${succ_rate}<=1.05
   
    [Return]   ${attach success rate}

KW.EnableFeatureCounter
     [Arguments]    ${Stream}=SBTS22R3_ENB_0000
     Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
     run keyword if    '${Stream}'=='SBTS22R2_ENB_0000'    KW.ChangeMeasurementParameterIfStreamisOld
     ...    ELSE    KW.ChangeMeasurementParameterIfStreamisNew
     COAM_WebEM.ValidateAndActiveParameters
     run keyword and ignore error    COAM_WebEM.Logout

KW.ChangeMeasurementParameterIfStreamisOld
     ${pm_interval_org}    COAM_WebEM.GetParameterValue      ${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
     ...    Performance measurement data reporting interval
     ${miNrNGCC_org}    COAM_WebEM.GetParameterValue      ${DIST_NAME}/NRPMRNL-1      Measurement interval for NR NGAP Interface Report per CELL
     ${miNrRachUsage_org}    COAM_WebEM.GetParameterValue      ${DIST_NAME}/NRPMRNL-1      Measurement interval for NR RACH Usage
     set test variable      ${pm_interval_org}
     set test variable      ${miNrNGCC_org}
     set test variable      ${miNrRachUsage_org}
     run keyword if    '${pm_interval_org}'!='${PMINTERVAL}min'    KW.ChangeMeasurementReportingInterval
     ...    disname=${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1    parameter=Performance measurement data reporting interval
     ...    pm_time=${PMINTERVAL}min    abbre=reportingIntervalPm
     run keyword if    '${miNrNGCC_org}'!='${PMINTERVAL}min'    KW.ChangeMeasurementReportingInterval     disname=${DIST_NAME}/NRPMRNL-1
     ...    parameter=Measurement interval for NR NGAP Interface Report per CELL     pm_time=${PMINTERVAL}min    abbre=miNrNGCC
     run keyword if    '${miNrRachUsage_org}'!='${PMINTERVAL}min'    KW.ChangeMeasurementReportingInterval    disname=${DIST_NAME}/NRPMRNL-1
     ...    parameter=Measurement interval for NR RACH Usage     pm_time=${PMINTERVAL}min    abbre=miNrRachUsage

KW.ChangeMeasurementParameterIfStreamisNew
     ${pm_interval_org}    COAM_WebEM.GetParameterValue      ${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
     ...    Performance measurement data reporting interval
     ${miNrNGCC_org}    COAM_WebEM.GetParameterValue      ${DIST_NAME}/NRPMRNL-1      NR NGAP Interface Report per CELL
     ${miNrRachUsage_org}    COAM_WebEM.GetParameterValue      ${DIST_NAME}/NRPMRNL-1      NR RACH Usage
     set test variable      ${pm_interval_org}
     set test variable      ${miNrNGCC_org}
     set test variable      ${miNrRachUsage_org}
     run keyword if    '${pm_interval_org}'!='${PMINTERVAL}min'    KW.ChangeMeasurementReportingInterval
     ...    disname=${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
     ...    parameter=Performance measurement data reporting interval     pm_time=${PMINTERVAL}min    abbre=reportingIntervalPm
     run keyword if    '${miNrNGCC_org}'!='${PMINTERVAL}min'    KW.ChangeMeasurementReportingInterval     disname=${DIST_NAME}/NRPMRNL-1
     ...    parameter=NR NGAP Interface Report per CELL     pm_time=${PMINTERVAL}min    abbre=miNrNGCC
     run keyword if    '${miNrRachUsage_org}'!='${PMINTERVAL}min'    KW.ChangeMeasurementReportingInterval     disname=${DIST_NAME}/NRPMRNL-1
     ...    parameter=NR RACH Usage     pm_time=${PMINTERVAL}min    abbre=miNrRachUsage

KW.ModifyCellName
    Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
    ${cellname}    COAM_WebEM.GetParameterValue      ${DIST_NAME}/NRCELL-1      Cell name
    run keyword if         '${cellname}'!='CELL1'    COAM_WebEM.SetParameterValue    ${DIST_NAME}/NRCELL-1    Cell name    CELL1
    COAM_WebEM.ValidateAndActiveParameters
    run keyword and ignore error    COAM_WebEM.Logout

KW.ChangeMeasurementReportingInterval
    [Arguments]    ${disname}    ${parameter}    ${pm_time}    ${abbre}
    Wait Until Keyword Succeeds    2 times    30s
     ...    COAM_WebEM.SetParameterValue    ${disname}    ${parameter}    ${pm_time}    ${abbre}

KW.GetCounterSumValue
    [Arguments]    ${counter_id}    ${full_path}
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   ${counter_id}    ${full_path}
    log    ${res}
    run keyword and ignore error    COAM_WebEM.Logout
    ${values}    get dictionary values   ${res}
    log    ${values}
    log  The latest one is: ${values[-1]}
    ${length}    get length    ${values}
    set test variable     ${count_sum}     ${0}
    set test variable     ${Idx}     ${0}
    FOR    ${i}    IN RANGE    ${length}
          ${count_sum}    Evaluate    ${count_sum}+${values[${Idx}]}
          ${Idx}    Evaluate    ${i}+1
    END
    log    ${count_sum}
    [Return]   ${count_sum}

L3 Call with traffic
    [Arguments]    ${traffic_time}=20  ${duration}=300   ${dl_throughput}=10MKbits/sec   ${ul_throughput}=5MKbits/sec   ${retry_times}=3
    ...    ${ue_index}=${0}    ${call_loop}=${10}  ${path}=${PA_Controller_PATH}
#    AMTU.Connect     host=${CONTROL_PC_IP}     username=${CONTROL_PC_USERNAME}     password=${CONTROL_PC_PASSWORD}
    Basic.CheckVariableValid   var=TLCommonConfig['PAGroups']['attach_success_rate']['pa_default']    default_value=54
    ${pa_default}    Set Variable    ${TLCommonConfig['PAGroups']['attach_success_rate']['pa_default']}
    FOR    ${i}    IN RANGE    ${retry_times}
        AMTU.Connect     host=${CONTROL_PC_IP}     username=${CONTROL_PC_USERNAME}     password=${CONTROL_PC_PASSWORD}
        AMTU.SetToDefault    path=${path}
        ${pa_tmp}      Evaluate     ${pa_default}+${i}
        ${output}    AMTU.SetCellInfo    CellIdx=1   Value=${pa_tmp}  path=${path}
        log to console    ${output}
        ${attach success rate}    ${rsrp_average}     Attach for loop    ue_index=${ue_index}    retry_times_for_attach=${call_loop}
        Collect common info    pa=${pa_tmp}     attach_success_rate=${attach success rate}   rsrp=${rsrp_average}
        Log To Console   L3 CaLL has been setup for ${call_loop} times and attach success rate is ${attach success rate}%
    END
Attach for loop
      [Arguments]    ${ue_index}=${0}    ${retry_times_for_attach}=${10}
      ${attach_successful}   Set Variable   ${0}
      ${attach_failed}   Set Variable   ${0}
      ${attach_successful_tmp}   Set Variable   ${0}
      ${attach_failed_tmp}   Set Variable   ${0}
      ${rsrp}    Set Variable    ${0}
      ${rsrp_times}    Set Variable    ${0}
      ${rsrp_get_failed_times}     Set Variable    ${0}
      FOR    ${i}    IN RANGE    ${retry_times_for_attach}
          one_ue_start_L3CALL   ue_index=${ue_index}   ue_type=${UE_TYPE_FOR_SUCCESS_RATE}
          ...   dl_throughput=${dl_throughput_for_attach}   ul_throughput=${ul_throughput_for_attach}   traffic_time=${traffic_time_for_attach}
          ...   duration=${duration_for_attach}   peak_TP=0
          sleep  5s
          ${dl_thput}    Get param value with retry    ${10}    NR PDCP Thr. DL [Mbps]
          ${rsrp_tmp}      Get rsrp for loop
          Run Keyword And Ignore error   power_ue.Stop traffic   ue_type=${UE_TYPE_FOR_SUCCESS_RATE}    direction=dl      ue_index=${ue_index}
#          ${rrc_status_tmp}    Get rrc status only
#          log to console      rrc_status:${rrc_status_tmp}
#          ${attach_successful_tmp}   Set Variable If   '${rrc_status_tmp}'=='Connected'   ${1}
#            ...   '${rrc_status_tmp}'!='Connected'   ${0}
#          ${attach_failed_tmp}   Set Variable If   '${rrc_status_tmp}'!='Connected'   ${1}
#            ...   '${rrc_status_tmp}'=='Connected'   ${0}

#          ${cqi_tmp}    Get CQI only
#          log to console      NR CQI AVG value is:${cqi_tmp}
#          ${attach_successful_tmp}   Set Variable If   '${cqi_tmp}'!=''   ${1}   ${0}
#          ${attach_failed_tmp}   Set Variable If   '${cqi_tmp}'==''   ${1}    ${0}
#          ${dl_thput_in_Kbit}    evaluate   float(${dl_thput})x1000
          ${attach_successful_tmp}   Set Variable If   ${dl_thput} > 0.08  ${1}   ${0}
          ${attach_failed_tmp}   Set Variable If   ${dl_thput} <= 0.08   ${1}    ${0}
#          sleep    2s
          ${rsrp_get_failed_tmp}   Set Variable If   ${rsrp_tmp}==${0}   ${1}
            ...   ${rsrp_tmp}!=${0}     ${0}
          ${rsrp_get_failed_times}    Evaluate    ${rsrp_get_failed_times}+${rsrp_get_failed_tmp}
          ${rsrp}   Evaluate   ${rsrp_tmp}+${rsrp}
          ${attach_successful}   Evaluate    ${attach_successful}+${attach_successful_tmp}
          ${attach_failed}       Evaluate    ${attach_failed}+${attach_failed_tmp}
          log to console      L3 call has been executed for ${i+1} times
          log to console       Current rsrp is: ${rsrp_tmp}
          log to console       DL throughput is: ${dl_thput}Mbit/s
#          log to console      THe CQI that indicates attach result is :${cqi_tmp}
      END
      ${attach success rate}  Evaluate   round(100*${attach_successful}/(${attach_successful}+${attach_failed}),2)
      ${rsrp_times}     Evaluate     ${retry_times_for_attach}-${rsrp_get_failed_times}
      ${rsrp_times}     Set Variable If   ${rsrp_times}==${0}   ${1}   ${rsrp_times}!=${0}   ${rsrp_times}
      ${rsrp_average}      Evaluate       round(${rsrp}/${rsrp_times},2)
      [Return]     ${attach success rate}     ${rsrp_average}

#http://toolscenter.eecloud.dynamic.nsn-net.net/api/oamkpi/cell_edge_input/?
#version=SBTS21B_ENB_0000_001007_000000&testline=7_5_UTE5G402T1100&pa=64&rsrp=-122&successrate=100%

Get rsrp for loop
     ${rsrp}    Set Variable    ${0}
     ${rsrp_times}    Set Variable    ${0}
     ${rsrp_get_failed_times}     Set Variable    ${0}
     ${rsrp_get_times}     Set Variable    ${10}
    FOR    ${i}    IN RANGE    ${rsrp_get_times}
        ${rsrp_tmp}     Get RSRP only
        sleep     2s
        ${rsrp_get_failed_tmp}   Set Variable If   ${rsrp_tmp}==${0}   ${1}
        ...   ${rsrp_tmp}!=${0}     ${0}
        ${rsrp_get_failed_times}    Evaluate    ${rsrp_get_failed_times}+${rsrp_get_failed_tmp}
        ${rsrp}   Evaluate   ${rsrp_tmp}+${rsrp}
    END
    ${rsrp_times}     Evaluate     ${rsrp_get_times}-${rsrp_get_failed_times}
    ${rsrp_times}     Set Variable If   ${rsrp_times}==${0}   ${1}   ${rsrp_times}!=${0}   ${rsrp_times}
    ${rsrp_average}      Evaluate       round(${rsrp}/${rsrp_times},2)
    [Return]     ${rsrp_average}


Collect common info
    [Arguments]    ${testline}=${testline_name}     ${URL}=${CASE_INPUT_CellEdge['Attach_Rate']['report_server_url']}
    ...    ${pa}=40   ${rsrp}=0  ${attach_success_rate}=0   ${result_container}=${Attach_Rate_Result}
#    ${version}       GetgNBSWVersion
     ${version}       GetgNBActiveSWVersion
#    ${rsrp}          set variable     ${param_value}[0]
    ${rsrp_str}    evaluate    str(${rsrp})
    ${pa_str}    evaluate    str(${pa})
    ${one_time_result}   create dictionary    version=${version}  testline=${testline}   pa=${pa_str}   rsrp=${rsrp_str}
    ...    successrate=${attach_success_rate}%
    Append to list    ${result_container}    ${one_time_result}
#    ${URL_tmp1}      set variable     ${URL}${version}&testline=${testline}&pa=${pa}&rsrp=${rsrp}&successrate=${attach_success_rate}%
#    ${res}           requests.get    ${URL_tmp1}
#L3 Call with traffic
#    [Arguments]    ${traffic_time}=20  ${duration}=300   ${dl_throughput}=10MKbits/sec   ${ul_throughput}=5MKbits/sec   ${retry_times}=3
#    FOR    ${i}    IN RANGE    ${retry_times}
#         log to console    First UE start to attach
#         ${result2}    run keyword and return status     one_ue_start_L3CALL   ue_index=${1}   ue_type=${UE_TYPE}
#         ...   dl_throughput=${dl_throughput}   ul_throughput=${ul_throughput}   traffic_time=${traffic_time}  duration=${duration}
#         log to console   Second UE start to attach
#         ${result3}    run keyword and return status     one_ue_start_L3CALL   ue_index=${0}   ue_type=${UE_TYPE}
#         ...   dl_throughput=${dl_throughput}   ul_throughput=${ul_throughput}   traffic_time=${traffic_time}  duration=${duration}
#         run keyword and ignore error      collect attach result   result2=${result2}   result3=${result3}
#         log to console      L3 call has been completed for ${i+1} times
#    End
#    [Return]    ${attach_successful}   ${attach_failed}
Get rrc status only
     ${param_value}    Run Keyword And Continue On Failure    Get Param Value   ue_index=${0}   param=${param_name}
     ${rrc_status}    Set Variable    ${param_value}[2]
     [Return]       ${rrc_status}

Get CQI only
     ${cqi_param_name}    create list    NR CQI Avg.
     ${param_value}    Run Keyword And Continue On Failure    Get Param Value   ue_index=${0}   param=${cqi_param_name}
     [Return]       ${param_value}[0]

Get param value with retry
    [Arguments]    ${retry_times}     ${param}
    FOR   ${time}    IN RANGE    ${retry_times}
        ${value}    Get value of ${param} only
        log to console  The ${param} value get for the ${time+1} time is ${value}.
        Exit For Loop IF    '${value}'!=''
    END
    ${final_value}    set variable if   '${value}'==''    ${0}     ${value}
    [Return]   ${final_value}

Get value of ${param} only
     ${my_param_name}    create list    ${param}
     ${param_value}    Run Keyword And Continue On Failure    Get Param Value   ue_index=${0}   param=${my_param_name}
     [Return]       ${param_value}[0]

Get RSRP only
    ${rsrp}    Set Variable    ${0}
    ${param_value}    Run Keyword And Continue On Failure    Get Param Value   ue_index=${0}   param=${param_name}
    ${rsrp}   Run Keyword If   "${param_value}[0]"!="${None}" and "${param_value}[0]"!=""
    ...   Set Variable   ${param_value}[0]
    ...   ELSE   Set Variable   ${0}
    [Return]       ${rsrp}

Get Param Value
    [Arguments]       ${ue_index}=${0}    ${param}=[]   ${ue_alias}=UE_${ue_index}
    [Documentation]     Prepare UE for L3 call test.
    ...  :param   ue_alias: <str> store ue by ue_alias
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    ${param_value}    spark.get_parm_value_on_ue    param=${param}   ue_alias=${ue_alias}
    [Return]    ${param_value}


collect attach result
   [Arguments]   ${result}
    run keyword if    '${result}'=='True'     Evaluate attach_successful_num
    ...    ELSE IF    '${result}'!='True'     Evaluate attach_failed_num
    [Return]    ${attach_successful}   ${attach_failed}

Evaluate attach_successful_num
     ${attach_successful}   Evaluate   ${attach_successful}+1

Evaluate attach_failed_num
     ${attach_failed}   Evaluate   ${attach_failed}+1

one_ue_start_L3CALL
     [Arguments]    ${ue_index}=${0}   ${ue_type}=${UE_TYPE_FOR_SUCCESS_RATE}   ${traffic_time}=20  ${duration}=300
      ...     ${peak_TP}=0  ${power_reset}=True    ${dl_throughput}=100Kbits/sec   ${ul_throughput}=50Kbits/sec
#     log to console    ue_type:${ue_type}
#     log to console     capabilities[-1]:${tl.ues[0].capabilities[-1]}
#     log to console     capabilities[1]:${tl.ues[0].capabilities[1]}
     Basic.CheckVariableValid   var=TLCommonConfig['MultiUECFG']['${ue_index}']['detach_request']    default_value=true
     Basic.CheckVariableValid   var=TLCommonConfig['MultiUECFG']['${ue_index}']['power_reset']       default_value=true
     power_ue.Prepare UE    ue_type=${UE_TYPE_FOR_SUCCESS_RATE}    ue_index=${ue_index}  reset_sol=${True}
     ...    detach_request=${TLCommonConfig['MultiUECFG']['${ue_index}']['detach_request']}
     ...    power_reset=${TLCommonConfig['MultiUECFG']['${ue_index}']['power_reset']}
     power_ue.UE Detach       ue_type=${UE_TYPE}    ue_index=${ue_index}
     ...    power_reset=${TLCommonConfig['MultiUECFG']['${ue_index}']['power_reset']}
     sleep    10s
     ${date}   Get Current Date   exclude_millis=True
     log to console       ${date} start attach
     ${result}    run keyword and return status     power_ue.UE Attach    ue_type=${UE_TYPE}    ue_index=${ue_index}
     ...    power_reset=${TLCommonConfig['MultiUECFG']['${ue_index}']['power_reset']}
#     Run Keyword And Ignore Error    spark.power off    ue_alias=UE_${ue_index}
#     sleep    3s
#     ${result}    run keyword and return status    spark.power on    ue_alias=UE_${ue_index}
#     ${result}    run keyword and return status    GetAttachvalue    ue_type=${ue_type}  ue_index=${ue_index}
     should be true    '${result}'=='True'
#     log to console      attach result:${result}
     #sleep   30s to wait pdu successful
#     sleep    10s
     Run Keyword And Ignore error   single_ue.start traffic    ue_type=${ue_type}  ue_index=${ue_index}   duration=${duration}
      ...    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}
#     sleep    10s
#     log to console    UE traffic completed ...
#     ${check_traffic_result}    run keyword and return status   single_ue.check traffic   ue_index=${ue_index}   ue_type=${ue_type}
#     ...       peak_TP=${peak_TP_for_attach}
#     should be true    '${check_traffic_result}'=='True'
#     log to console    start to stop traffic and detach UE ...
#     Run Keyword And Ignore error   power_ue.Stop traffic   ue_type=${ue_type}     direction=dl      ue_index=${ue_index}
#     sleep  20s
#     Run Keyword And Ignore error  power_ue.Stop traffic    ue_type=${ue_type}     direction=ul       ue_index=${ue_index}
#     sleep  20s
#     Run Keyword And Ignore error    power_ue.UE Detach     ue_type=${ue_type}     power_reset=True      ue_index=${ue_index}
#     log to console    UE detach completed ...



single_ue.start traffic
    [Arguments]    ${ue_type}=${UE_TYPE}   ${ue_index}=${0}  ${duration}=10  ${dl_throughput}=100Kbits/sec  ${ul_throughput}=50Kbits/sec
    log to console  DL traffic started ...
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${UE_TYPE}    ue_index=${ue_index}   duration=${duration}
     ...     direction=dl     throughput=${dl_throughput}
#    log to console  UL traffic started ...
#    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${UE_TYPE}    ue_index=${ue_index}   duration=${duration}
#     ...     direction=ul     throughput=${ul_throughput}


single_ue.check traffic
    [Arguments]    ${peak_TP}=0  ${ue_index}=${0}   ${ue_type}=${UE_TYPE}
    run keyword if    "${peak_TP}" == "0"    single_ue.check throughput   ue_type=${UE_TYPE}  ue_index=${ue_index}
    ...    ELSE IF    "${peak_TP}" == "1"    single_ue.check throughput   ue_type=${UE_TYPE}  ue_index=${ue_index}  check_dl_TP=600  check_ul_TP=40

single_ue.check throughput
    [Arguments]    ${ue_index}=${0}   ${ue_type}=${UE_TYPE}  ${check_dl_TP}=0  ${check_ul_TP}=0
    ${dl_tp_status}   run keyword and return status    power_ue.Check throughput    ue_type=${UE_TYPE}  ue_index=${ue_index}
    ...      throughput=${check_dl_TP}   start_offset=${0}   direction=dl
#    ${ul_tp_status}   run keyword and return status    power_ue.Check throughput    ue_type=${UE_TYPE}  ue_index=${ue_index}
#    ...      throughput=${check_ul_TP}   start_offset=${0}  direction=ul
#    should be true     ${dl_tp_status} or ${ul_tp_status}
     should be true     ${dl_tp_status}

GetAttachvalue
    [Arguments]   ${ue_type}=${UE_TYPE}    ${ue_index}=${0}
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}
    ...    power_reset=${TLCommonConfig['MultiUECFG']['${ue_index}']['power_reset']}
    sleep    10s
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${ue_index}   ue_type=${UE_TYPE}    attach_mode=5G_SA
    ...    power_reset=${TLCommonConfig['MultiUECFG']['${ue_index}']['power_reset']}
    sleep    3s
    ${Rach_status}    run keyword and return status    power_ue.Verify attach    ue_index=${ue_index}
    ...    ue_type=${UE_TYPE}     4G_check=False    5Grach_ed=${5Grach_ed}
    should be true    '${Rach_status}'=='True'

Setup case for two CELL L3 call
    #run keyword and ignore error    Start BTSlogs Collection
    Set test Variable    ${attach success rate}   ${0}
    Set test Variable    ${attach_successful}    ${0}
    Set test Variable    ${attach_failed}        ${0}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}

Teardown case for two CELL L3 call
    ${statistics_attach_rate}    json.dumps    ${Attach_Rate_Result}
    &{final_data}   create dictionary    Result=${TEST STATUS}    attach_rate_result=${statistics_attach_rate}
    requests.post    ${CASE_INPUT_CellEdge['Attach_Rate']['report_server_url']}    data=${final_data}
    #Run Keyword And Ignore Error    Collect snapshot via webui
    #Run Keyword And Ignore Error    Stop BTSlogs Collection and get logs
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    run    command=killall firefox
    Run Keyword And Ignore Error    coam_close.force_close_coam_webdriver
    Conn.ResetCache





