*** Settings ***

Documentation     [SUITE PURPOSE]  tests for DSS feature 7738-A CellSetup / Ue call and Traffic for 10Mhz
...               Test Case Scenario author   : anne.enyih@nokia.com
...               Test Case Scenario contact  : riyad.ferrag@nokia.com
...               Test Case automation author :
...               Test Case automation contact:
...               Creation Date               : July 10 2024
...               Modified Date               : July 25 2024
...               Last Modified by            : riyad.ferrag@nokia.com
#-------------------------------------------------------------------------------------------------------[150 characters]

Library           taf.sbts.oam.coam.admin           WITH NAME               coam
Library           ute_wtssim                        WITH NAME               wts
Library           ../resources/python/luashark_tools.py
Library           ../../../resources/SWENG/python/StringTool.py
Library           ../resources/common/TtiTrace/python/ttitrace.py   WITH NAME    nps_ttitraces_tools
Library           resources/python/Constants.py                     WITH NAME    MyConstants
Library           ../resources/DSS/python/dss_tools.py              WITH NAME    nps_dss_tools
Library           resources/python/tools.py                         WITH NAME    nps_7738_tools
Library           ../resources/DSS/python/robot_extension.py        WITH NAME    robot_extension
Library           resources/python/validate_retransmitted_ul_packets.py

# SWENG resources
Resource          ../../../resources/SWENG/robot/GenericTest.robot

# ttitrace ET resources
Resource          ../resources/common/TtiTrace/ttitrace.robot


# DSS common
Resource          ../resources/DSS/robot/btslog.robot
Resource          ../resources/DSS/robot/common_Dss_Keywords.robot
Resource          ../resources/DSS/robot/common_Dss_command.robot
Resource          ../resources/DSS/robot/common_Dss_SA_NSA.robot

# 7738 specific
Resource            resources/robot/CB007738_Kw_TestSetup.robot
Resource            resources/robot/CB007738_keywords.robot

Variables           resources/python/Constants.py


# Tags for QC mapping
Force Tags                          CA_5G_SW_FR-Villarceaux   RRM
...                                 PY36
...                                 master_classicalbts_all
...                                 CONFIGURED    5G_RAN    RAN_5G


Suite Setup         Run keywords      MyConstants.hello
...                 AND               set global variable         ${WITH_MCSHARK}       1
...                 AND               set global variable         ${SharkTool}          MC_SHARK
...                 AND               Test Suite Setup for CNI-95172
...                 AND               Get gNB cell 5g On air
...                 AND               Prepare TL for TTITraces
Suite Teardown      Test suite teardown for CNI-95172



*** Variables ***

${PATTERN_DL_70_SA_OK}      0011100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
${PATTERN_DL_100_SA_OK}      1011110011-1111111111-1011110011-1111111111-1011110011-1111111111-1011110011-1111111111
${PATTERN_DL_100_SA_OK_SSBPos6}      1111110011-1111111111-1111110011-1111111111-1111110011-1111111111-1111110011-1111111111
# R. Ads
${Delta_SCF}           ${CURDIR}/resources/config/Delta_SCF_CNI-95172.json
${gnb_alias}           gnb_under_test

#.................................

*** Test Cases ***

TestLine_preparation
    [Tags]    FULL_RUN    Cellsetup     10MHZ
    ...       CRT
    CB007738_Kw_TestSetup.Test Line Preparation    ${TestDSS10Mhz_7738_A1}

TestLine_CNI-95172_Test_setup
    [Tags]    FULL_RUN    Cellsetup   FULL_CALL  10MHZ
    ...       CRT
    [Setup]   Run Keywords    set Suite Variable    ${testCaseDir}    None      AND
    ...                       common_Dss_Keywords.Get testcase log directory
    CB007738_Kw_TestSetup.Test Setup 7738    ${TestDSS10Mhz_7738_A1}


# TC covered under New feature
[1]CNI-95172_3_1UE_TargetPct_75_and_nGBR_Traffic
   [Tags]    FULL_RUN     10MHZ    CNI-95172   7738_A4
   ...       CRT
   [Documentation]     Cellsetup Dss phase 3, BW= 10MHz, DL RATIO = 100%, Fast UL Allocation, SA 5g Call , DL/UL Tput
   [Setup]   Run Keywords    set Suite Variable    ${testCaseDir}    None                                 AND
   ...       CB007738_keywords.Clean Up Env                                                               AND
   ...       update Get Mem Usage Variable                                                                AND
   ...       set Suite Variable    ${dl_expect_tput_value}           90                                   AND
   ...       set Suite Variable    ${ul_expect_tput_value}           30                                   AND
   #         as each 20ms Prb used  is flickering from 35 to 20, the check need to be done using following ul TP value
   # ...       set Suite Variable    ${ul_expect_tput_value_for_TC11}  19                                   AND
   #          New target Tput with No Additionnal DMRS UL and PUSCH DMRS FDM deactivated
   ...       set Suite Variable    ${ul_expect_tput_value_for_TC11}  27                                   AND
   #         deviation need to take into account crm ul settings
   ...       set Suite Variable    ${deviation}                      10                                   AND
   ...       common_Dss_Keywords.Get testcase log directory                                               AND
   ...       common_Dss_Keywords.Prepare Test Name                                                        AND
   ...       common_Dss_Keywords.Start Tcpdump on TestPc    interface=eth3    option=-s0 sctp or icmp     AND
   ...       Set global variable    ${CELLSETUP_SHOULD_BE_CHECK}   0                                      AND
   ...       depends   TestLine_CNI-95172_Test_setup

   Get Mem Usage for 7738    period=before

   ${tc_name}        Set variable    TestLine_preparation
   ${tc_status}      getTcStatusByName    name=${tc_name}
   Run keyword if    '${tc_status}'!='PASS'
   ...               CB007738_Kw_TestSetup.Test Line Preparation    ${TestDSS10Mhz_7738_A4}
   ${tc_name}        Set variable    TestLine_CNI-95172_Test_setup
   ${tc_status}      getTcStatusByName    name=${tc_name}
   Run keyword if    '${tc_status}'!='PASS'
   ...           CB007738_Kw_TestSetup.Test Setup 7738    ${TestDSS10Mhz_7738_A4}

   # set CNI-95172 related NIDD parameters. At this step DSS configuration is finished
   Set CNI-95172 Params     ${Delta_SCF}    ${gnb_alias}

   # Update nrCellType into Context for CellId=1
   Update nrCellType into "${TestDSS10Mhz_7738_A4}" for cellID "1"

   # modification DL Ratio into the test param Ctx
   Update DSS DL pattern with     ${TestDSS10Mhz_7738_A4}     ${PATTERN_DL_70_SA_OK}
   Dated log       DL pattern into TestParam is ${TestDSS10Mhz_7738_A4.seq.dl_allocated_normal_subframes}
   # Update DSS qos load meas timer with     ${TestDSS10Mhz_7738_A3}    ${dl_qos_load_meas_timer}=10    ${ul_qos_load_meas_timer}=30
   Update DSS dl qos load meas timer "${10}" ms and ul qos load meas timer "${30}" ms into "${TestDSS10Mhz_7738_A4}"
   Dated log       DL qos_load_meas_timer into TestParam is ${TestDSS10Mhz_7738_A4.seq.dl_qos_load_meas_timer} ms
   Dated log       UL qos_load_meas_timer into TestParam is ${TestDSS10Mhz_7738_A4.seq.ul_qos_load_meas_timer} ms

   btslog.Start Btslog
   CB007738_keywords.TC DSS Phase3 CellSetup            ${TestDSS10Mhz_7738_A4}    egate_TC11
   # add here the DL Pattern list to add to CRMSim and active it ....
   DSS_5g_Periodic_UL_Fast_Allocation              ${TestDSS10Mhz_7738_A4}    egate_TC11
   # Configure Ul cell noise
   Setup_AP_TestMode            alias=egate_TC11

   Get Mem Usage for 7738    period=after_DSS_Phase3_CellSetup
   TC 7738-5g SA Call                              ${TestDSS10Mhz_7738_A4}    egate_TC11

   Get Mem Usage for 7738    period=after_7738-5g_SA_Call

   common_Dss_SA_NSA.DSS_5g_SA_UL_DL_Traffic      ${TestDSS10Mhz_7738_A4}
   ...                                             ul_rate=${ul_expect_tput_value}
   ...                                             dl_rate=${dl_expect_tput_value}
   ...                                             alias=egate_TC11
   # Activate UL cell noise test mode
   AP_TM_Activation     alias=egate_TC11
   Traced Sleep    5s      msg=Waiting for UL/DL Tput

   Run Keyword And Ignore Error    Get TTI traces
    # R. Ads : CNI-95172 DOD
    Dated Log       Verify reTx for nrcell.targetPctResourceReservedMcsUl set to 75%
    ${output}=      Run Keyword     ul_retx_check_v3       json_path_name=${tti_json_path}
    Dated Log       reTx verification process returned status = ${output}
    should be true  '${output}'=='True'    reTx is not as expected!
    # R. Ads end
   Start capture Backhaul XP for DSS    prefix=DSS_5g_SA_UL_DL_Traffic.1sTput.wXP
   Traced Sleep    1s      msg=Waiting for Xp pcap traces
   Dated log             Point AF_PATH and ENB_BUILD to local luashark XP package
   Point AF_PATH to local luashark XP package
   Point ENB_BUILD to local luashark XP package
   ${XpPdmlFile}    Stop capture Backhaul XP for DSS
   Get Mem Usage for 7738    period=after_DSS_5g_SA_UL_DL_Traffic
   Dated log     =========> Check UL and DL Qos Load Indication MeasuredNgbrNnbrLoad ...
   ${status}     ${avg_ul_MeasuredNgbrNnbrLoad}=  Run Keyword and Ignore Error
   ...           common_Dss_Keywords.Check UL Qos Load Indication MeasuredNgbrNnbrLoad
   ...                      ${XpPdmlFile}
   ...                      value=64
   ...                      with_verdict=False

   Run Keyword and Ignore Error      common_Dss_Keywords.Check DL Qos Load Indication MeasuredNgbrNnbrLoad       ${XpPdmlFile}

   Dated log     =========> get dl and ul throughput for ue (0x${TestDSS10Mhz_7738_A4.Context.UeId1})
   ${ul_throughput_for_ue1}=  nps_dss_tools.get_bearer_stats_SA   ue=${TestDSS10Mhz_7738_A4.Context.UeId1}
   ...                                                             pdu=1   qfi=1    direction=ul  alias=egate_TC11
   dated log     ul throughput for ue1 is ${ul_throughput_for_ue1} Mbps

   ${dl_throughput_for_ue1}=  nps_dss_tools.get_bearer_stats_SA   ue=${TestDSS10Mhz_7738_A4.Context.UeId1}
   ...                                                             pdu=1   qfi=1    direction=dl  alias=egate_TC11
   dated log     dl throughput for ue1 is ${dl_throughput_for_ue1} Mbps

#   Dated log     =========> Test if Expected ul throughput is reached [expected=${ul_expect_tput_value_for_TC11}Mbps]
#   ${ul_target_tput}=         Evaluate    float(${ul_expect_tput_value_for_TC11})
#   ${UL_tput_ok}              Verify xL tput     dir=UL    tput_value=${ul_throughput_for_ue1}
#   ...                                           expect_tput_value=${ul_target_tput}    tput_deviation=${deviation}
#   # following tested is moved from the KW to be sure if failed it is really reported
#   should be true    '${UL_tput_ok}'=='True'    Tput is not as expected!

   [Teardown]     Run Keywords       Produce Scout Data    AND
   ...                               common_Dss_Keywords.Stop Tcpdump on TestPc    interface=eth3    target_dir=${testCaseDir}     AND
   ...                               robot_extension.Run Keyword And Warn On Failure    btslog.Stop Btslog    target_dir=${testCaseDir}      AND
   ...                               robot_extension.Run Keyword And Warn On Failure    Get Mem Usage for 7738  period=Teardown    AND
   ...                               Teardown 7738     alias=egate_TC11           AND
   ...                               set Suite Variable  ${testCaseDir}  None   AND
   ...                               GenericTest.Display diagnosis


*** Keywords ***

TC 7738-5g SA Call
   [Documentation]                Test purpose is to test 5g DSS SA Call
   [Arguments]                    ${param}    ${alias}=default   ${w_force_ue_capa}=True
   Init Sequence                  ${param}
   Step           Start capture Bip and Xp for 7738    argument=TC_7738-5g_SA_Call.wL1L2Bip.wXP
   Step           common_Dss_SA_NSA.DSS_5g_Call_SA           argument=${alias}
   log to console       w_ue_capa=${w_force_ue_capa}
   # 12/15/2022 : tempory WA for CB008325 (ABIP)
   # run Keyword if   '${GNB_DU.bb[0].M.boardType}'=='ABIP'  Step    common_Dss_SA_NSA.DSS_5g_Call_SA    alias=${alias}  w_ue_capa=${w_force_ue_capa}
   # ...              ELSE                                   Step    common_Dss_SA_NSA.DSS_5g_Call_SA    argument=${alias}
   Step           Stop capture Bip and Xp for 7738           depends=Start capture Bip and Xp for 7738
   [Teardown]                      GenericTest.Display diagnosis

DSS_5g_Periodic_DL_Fast_Allocation
   [Arguments]         ${param}     ${alias}=default
   Init Sequence       ${param}
   Step      common_Dss_CellSetup.Periodic DL Fast Allocation      argument=${alias}

DSS_5g_Periodic_DL_Fast_Allocation_SSBSlot6
   [Arguments]         ${param}     ${alias}=default
   Init Sequence       ${param}
   Step      common_Dss_CellSetup.Periodic DL Fast Allocation SSBSlot6      argument=${alias}

DSS_5g_Periodic_UL_Fast_Allocation
   [Arguments]         ${param}     ${alias}=default
   Init Sequence       ${param}
   Step      Periodic UL Fast Allocation      argument=${alias}

Prepare TL for TTITraces
    [Documentation]    :
    ...    This keyword helps to download and install MULTI packages needed for TTITraces
    ...
    nps_ttitraces_tools.install_multidynamic_if_needed

Update DSS DL pattern with
   [Arguments]                    ${testParam}     ${dl_allocated_normal_subframes}

   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.seq.dl_allocated_normal_subframes}      set Variable     ${dl_allocated_normal_subframes}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Update DSS qos load meas timer with
   [Arguments]                    ${testParam}     ${dl_qos_load_meas_timer}=200    ${ul_qos_load_meas_timer}=200

   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.seq.dl_qos_load_meas_timer}      set Variable     ${dl_qos_load_meas_timer}
   ${testParam_dss.seq.ul_qos_load_meas_timer}      set Variable     ${ul_qos_load_meas_timer}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

#  Keyword with embedded arguments
Update DSS dl qos load meas timer "${dl_qos_load_meas_timer}" ms and ul qos load meas timer "${ul_qos_load_meas_timer}" ms into "${testParam}"
   ${testParam_dss}                 Tools.Dictionary Get              ${testParam}
   ${testParam_dss.seq.dl_qos_load_meas_timer}      set Variable     ${dl_qos_load_meas_timer}
   ${testParam_dss.seq.ul_qos_load_meas_timer}      set Variable     ${ul_qos_load_meas_timer}
   set suite variable    ${testParam_dss}
   [Return]      ${testParam_dss}

Get Mem Usage for 7738
  [Documentation]     Get Mem Usage for 7738
  ...                 w_Get_Mem_Usage is a global variable
  [Arguments]         ${period}=before
  return from Keyword if     '${w_Get_Mem_Usage}' == 'False'
  dated log    Get Mem Usage during period=${period}
  ${aliasGNB_2}=   common_Dss_Keywords.Connect to gNB Common Unit     gnb_id=0    du_id=0     comu_id=0
  set Test Variable       ${aliasGNB_2}
  robot_extension.Run Keyword And Warn On Failure     common_Dss_Keywords.Get Mem Usage      board_id=1
  ...                                                                                        period=${period}
  ...                                                                                        connection=${aliasGNB_2}
  robot_extension.Run Keyword And Warn On Failure     ssh.disconnect      connection=${aliasGNB_2}

Get TTI traces
    [Arguments]     ${suffix}=${EMPTY}   ${time}=1s    ${event_nr_max}=10000   ${w_convert_pcap_to_excelCsv}=True
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .
    Dated Log         Start TTI Traces in Streaming Mode
    ttitrace.Start TTI Traces in Streaming Mode      filter_bitmap2=0x0
    Traced Sleep    ${time}      msg=Waiting for TTI Traces
    Dated log         Stop TTI Traces in Streaming Mode...
    ${ttiTraceSubDir}   set Variable    TtiTrace-${time}-${tm}
    ${ttiTraceSubDir}   set Variable if    '${suffix}'!='${EMPTY}'     ${ttiTraceSubDir}-${suffix}
    ...                                                                ${ttiTraceSubDir}
    ${tti_trace_path}=     ttitrace.Stop TTI Traces in Streaming Mode    tti_trace_path=${testCaseDir}/${ttiTraceSubDir}
    Dated log         Decode TTI Traces...
    nps_ttitraces_tools.decode_tti_traces_using_TtitraceReaderEvtDec       desired_storage_directory=${testCaseDir}/${ttiTraceSubDir}
    ...                                                                    num_of_events=${event_nr_max}
    # R. Ads
    ${tti_json_path}=      ttitrace.Convert TTI trace from pcap to others    input_file_path=${tti_trace_path}
    Set Suite Variable      ${tti_json_path}
    # Dated log         Decoded json file path: ${tti_json_path}

    run keyword if   '${w_convert_pcap_to_excelCsv}'=='True'    run keywords
    ...               Dated log    Convert TTI trace from pcap to excelCsv...    AND
    ...               Run keyword and continue on failure     ttitrace.Convert TTI trace from pcap to excelCsv     input_file_path=${tti_trace_path}
    ...                                                                    output_file_path=${testCaseDir}/${ttiTraceSubDir}
    [return]     ${testCaseDir}/${ttiTraceSubDir}

Periodic UL Fast Allocation
    [Arguments]                 ${alias}=default

    ${msg_console}=   Catenate   ***DSS ${Param.Context.DSS_Phase} CRM Periodic UL Fast Allocation BW=${Param.seq.bandwidth} with alias=${alias}***
    Log to console   \n${blue} ${msg_console} ${normal}

    # ${ul_allocated_prb_list }=  Catenate   1,35

    # 3 PRB area defined because of longPUCCH
    ${prb_nr_pusch_area}=    set variable    ${Param.scfFile.nrcell.msg1FrequencyStart},${Param.seq.ULNbrOfPrb}
    ${ul_allocated_prb_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,3|${prb_nr_pusch_area}|49,3
    ...  ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'          set variable   0,3|${prb_nr_pusch_area}|76,3
    ...  ELSE                                                                           set variable   0,3|${prb_nr_pusch_area}|103,3


    common_Dss_CellSetup.DSS enb crm periodic allocation pattern UL   ul_allocated_prb_list=${ul_allocated_prb_list}
    ...                                                             alias=${alias}

    # ${ul_allocated_prb_list }=  Catenate   1,20

    # 3 PRB area defined because of longPUCCH
    ${prb_nr_pusch_area}=    set variable    ${Param.scfFile.nrcell.msg1FrequencyStart},20
    ${ul_allocated_prb_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,3|${prb_nr_pusch_area}|49,3
    ...  ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'          set variable   0,3|${prb_nr_pusch_area}|76,3
    ...  ELSE                                                                           set variable   0,3|${prb_nr_pusch_area}|103,3

    common_Dss_CellSetup.DSS enb crm periodic allocation pattern UL   ul_allocated_prb_list=${ul_allocated_prb_list}
    ...                                                             alias=${alias}

    common_Dss_CellSetup.DSS UL Cell Periodic Resource Allocation Phase3     alias=${alias}

    # Param variable is visible under the test suite

    sleep    2s    reason=make sure the cmd take affect

    log to console   \n${blue}***DSS CRM Periodic UL Fast Allocation BW=${Param.seq.bandwidth} completed*** ${normal}

    ${output}    wts.execute egate command and wait for data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1       alias=${alias}
    Log To Console    \n*** enb_crm_status enb=${Param.Context.eNBId} cell=1
    Log To Console    \n${output}

Setup Airphone Noise TestMode
    [Arguments]         ${alias}=default
    [Documentation]    Setup AP testmode to inject the desired noise power on various physical channels at cell level
    sleep   1

    ${msg}    Catenate    Setup AP testmode to add some noise at cell level
    Dated Log New Line      ${msg}
   #  ${cmd1}=    Catenate      ul_cell_noise_testmode_nr profile_id=1 noise_pusch=-710
   #  wts.execute egate command    cmd=${cmd1}     alias=${alias}
   #  sleep   1
   #  ${cmd2}=    Catenate      cell_testmode_set_nr gnb=2 cell_id=1 testmode=ul_cell_noise profile_id=1 action=activate
   #  wts.execute egate command    cmd=${cmd2}     alias=${alias}
   #  sleep   1
    ${cmd3}=    Catenate      ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-210
    wts.execute egate command    cmd=${cmd3}     alias=${alias}
    sleep   1
    log to console  \n***Airphone's Noise TestMode Setup completed for gnbId=2 and cell_id=1***

Setup_AP_TestMode
   [Arguments]         ${alias}=default
   Step      Setup Airphone Noise TestMode      argument=${alias}

Activate Airphone TestMode
    [Arguments]     ${alias}=default
    [Documentation]    Activate cell specific test mode profile on a specified cell(s)
    sleep   1

    ${msg}    Catenate    Activating cell noise specific TestMode
    Dated Log New Line      ${msg}
    ${cmd}    Catenate      ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate
    wts.execute egate command    cmd=${cmd}     alias=${alias}
    sleep   1
    log to console  \n***Airphone's Noise TestMode activation completed for gnbId=2 and cell_id=1***
    Wait '6s' for stability for reason 'wait for ul sinr adjust'

AP_TM_Activation
   [Arguments]         ${alias}=default
   Step      Activate Airphone TestMode      argument=${alias}

Set CNI-95172 Params
    [Documentation]        Dedicated KW to use a delta commissioning file
    [Arguments]                   ${deltaScf}         ${gnb_alias}
    Dated Log New Line            **** CNI-95172 delta commissioning started : Setting feature's related parameters ****
    coam.connect_to          name=${gnb_alias}
    Dated Log New Line            delta_file=${deltaScf}
    coam_parameter.perform_scf_delta_commission    delta_file=${deltaScf}    connection=${gnb_alias}
    OAM wait available
    coam.teardown            connection=${gnb_alias}
    Dated Log New Line            **** CNI-95172 : delta commissioning finished ****
#    Dated Log New Line            * * * * TL RESTART TRIGGERED * * * *
#    Restart TL
