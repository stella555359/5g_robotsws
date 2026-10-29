*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE]   TARF-Keywords.robot
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : christophe.samson@nokia.com
...               Creation Date               : 11-08-2023
...               Modified Date               : 11-08-2023
...               Last Modified by            : christophe.samson@nokia.com
...               Version   Date          Author                                   Notes
...               0.1       11-08-2023    christophe.samson@nokia.com              Creation
# --------------------------------------------------------------------------------------------------------------------------------------------------

# Libraries
Library      taf.transport.ssh                                   WITH NAME          ssh
Library      taf.sbts.oam.coam.admin.interface
Library      taf.sbts.oam.coam.admin                             WITH NAME          coam
Library      taf.collectors.pmcounters                           WITH NAME          tafpmcounters
Library      taf.collectors.tcpdump                              WITH NAME          tcpdump
Library      taf.collectors.core                                 WITH NAME          core
Library      ute_wtssim
Library      taf.config.wts                                      WITH NAME          wts_cfg
Library      ta_emss
# Library      ta_messaging
Library      re
Library      XML    True
Library      json
Library      ute_admin_infomodel

# Libraries SWENG
Library      ../../../../../../resources/SWENG/python/StringTool.py
Library      ../../../../../../resources/SWENG/python/ScfVendorOperations.py

# Libraries ET
Library      ../../../../resources/python/linux_cmds.py
Library      ../../../../resources/common/TtiTrace/python/ttitrace.py     WITH NAME          nps_ttitraces_tools
Library      ../../../../resources/DSS/python/robot_extension.py          WITH NAME          robot_extension

# Libraries TRF
Library      ../python/Constants-features.py                           WITH NAME          MyConstants
Library      ../python/Dev_lib.py
Library      ../python/avg_dl_data.py
Library      ../python/avg_ul_data.py
Library      ../python/tools.py                                        WITH NAME          nps_trf_tools
Library      ../python/tarf-lib.py
Library      testsuite/Paris/RRM/ET/resources/common/TtiTrace/python/tti_analyzer_framework/set_pandas.py            WITH NAME          set_pandas
Library      testsuite/Paris/RRM/ET/resources/common/TtiTrace/python/tti_analyzer_framework/tti_dataframe.py         WITH NAME          tti_dataframe
Library      ../python/tti_analysis/check_nack.py
Library      ../python/tti_analysis/check_ul_dtx_crc.py
Library      ../python/file.py
Library      ../python/set_ta_ssh_telnet.py                            WITH NAME          set_ta_ssh_telnet
Library      ../python/set_ta_xml.py                                   WITH NAME          set_ta_xml
Library      ../python/csirs_checker.py                                WITH NAME          csirs_checker
Library      ../python/trs_checker.py                                  WITH NAME          trs_checker
Library      ../python/pmcounter_throughput_evaluator.py               WITH NAME          pmcounter_throughput
Library      ../python/pmcounter_bler_evaluator.py                     WITH NAME          pmcounter_bler
Library      ../python/log_check.py                                    WITH NAME          log_check

# Resources SWENG
Resource      ../../../../../../resources/SWENG/robot/GenericTest.robot
Resource      ../../../../../../resources/SWENG/robot/Counters.robot
Resource      ../../../../../../resources/SWENG/robot/SetConfig.robot
Resource      ../../../../../../resources/SWENG/robot/Setup.robot
Resource      ../../../../../../resources/SWENG/robot/CallSetup.robot
Resource      ../../../../../../resources/SWENG/robot/Capture.robot
Resource      ../../../../../../resources/SWENG/robot/Traffic.robot
Resource      ../../../../../../resources/SWENG/robot/CaptureFilter.robot
Resource      ../../../../../../resources/SWENG/robot/Oam.robot
Resource      ../../../../../../resources/SWENG/robot/Tools.robot
Resource      ../../../../../../resources/SWENG/robot/Restart.robot
Resource      ../../../../../../resources/SWENG/robot/Scf.robot
Resource      ../../../../../../resources/SWENG/robot/Container.robot
Resource      ../../../../../../resources/SWENG/robot/Sherpa.robot
Resource      ../../../../../../resources/SWENG/robot/PacketSearch.robot
Resource      ../../../../../../resources/SWENG/robot/WtsXmlConfig.robot

# Resources
Resource     ../../../../resources/common/TtiTrace/ttitrace.robot

# Resources TRF
Resource     btslog.robot
Resource     apUDPlog.robot
Resource     DedicatedXmlConfig.robot
Resource     connect.robot

*** Variables ***

${f}    /home/ute/
${path_config_custom}                    ${CURDIR}/../config/custom
${SQR44_L2ET_GOLDEN_FILE_ADDRESS}        https://gitlabe1.ext.net.nokia.com/csamson/sqdgrp_et_44.git
${cfg_capa_file}                         ${path_config_custom}/ue_capabilities.cfg

${kill_btslog}     timeout 5 sudo kill -9 $(ps -ef|grep btslog|grep -v grep|awk '{print $2}') 1>/dev/null 2>&1
${kill_dpkg}       timeout 5 sudo kill -9 $(ps -ef|grep dpkg|grep tti-dec.deb|grep -v grep|awk '{print $2}') 1>/dev/null 2>&1
${kill_sherpa}     timeout 5 sudo kill -9 $(ps -ef|grep ./Sherpa|grep -v grep|grep -v run|awk '{print $2}') 1>/dev/null 2>&1
# ps -el | grep Sherpa | grep -v grep | grep -v run

&{P_UETYPE}                                                         &{EMPTY}

# check alarm that need to be ignored;
&{SBTS_EXPECTED_ALARMS_49}   alarmId=7102   faultId=49

${Enabled_}  regex"Enabled|enabled"
${Disabled_}  regex"Disabled|disabled"
${Online_}  regex"Online|None"
${Offline_}  regex"Offline|off line"
${Degraded_}  regex"Degraded|degraded"
${Online_Degraded_}  regex"Online|None|Degraded|degraded"
${NotInstalled_}  regex"NotInstalled|not installed"
${NotInstalled_Offline_}  regex"NotInstalled|not installed|Offline|off line"
${Failed_}  regex"Failed|failed"
${Failed_Offline_}  regex"Failed|failed|Offline|off line"
${Unlocked_}  regex"Unlocked|unlocked"
${Locked_}  regex"Locked|locked"
${ShuttingDown_}  regex"ShuttingDown|Shutting Down"
${Dependency_}  regex"Dependency|dependency"
${PowerOff_}  regex"PowerOff|power off"
${Testing_}  regex"Testing|testing"
${Initializing_}  regex"Initializing|initializing"
${Commissioned_}  regex"Commissioned|commissioned"
${NotCommissioned_}  regex"NotCommissioned|notCommissioned"
${IntegratedToRan_}  regex"IntegratedToRan|integrated to RAN"
${OnAir_}  regex"OnAir|onAir"
${OnAirDone_}  regex"OnAirDone|onAirDone"
${Test_}  regex"Test|test"
${Configured_}  regex"Configured|configured"
${IntegratedToRan_Configured_}  regex"IntegratedToRan|integrated to RAN|Configured|configured"
${Blocked_}  Blocked
${Unblocked_}  Unblocked
${Blocking_}  Blocking
${Unblocking_}  Unblocking
${Idle_}  Idle
${Active_}  Active
${Disabled_Enabled_}  regex"Disabled|disabled|Enabled|enabled"

&{Test Trace}                                       Type=Type Of trace
...                                                 Savedir=Save directory
...                                                 name=Name of the Traces
...                                                 Trigger=Info about Trigger

&{Test results}                                       Type=Type Of test
...                                                   Result=test Verdict

*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting


Check Trs periodicity is ${periodicity} wth ${trscsirs}
    ${periodicity_i}=     convert to integer     ${periodicity}
    ${status}=      tarf-lib.check_trs_periodicity      periodicity=${periodicity_i}     trscsirs_cells=${trscsirs}
    [return]    ${status}

load Json test data
    [Arguments]    ${Json test configuration}=${EMPTY}   ${dict_ues}=${EMPTY}   ${vendor_custom}=${EMPTY}   ${param}=${EMPTY}  ${dict_cells}=${EMPTY}
    return from keyword if   '${Json test configuration}'=='${EMPTY}'
    ${data_test}=    nps_trf_tools.load_json   ${Json test configuration}
    # dated log   data_test=${data_test}
    dated log   Upload data test for ${consTraceColor}${TEST NAME}${defColor} from json file
    # dated log   data_test=${data_test['${TEST NAME}']}
    ${dictAllParam}      Get From Dictionary
    ...     ${data_test['${TEST NAME}']}
    ...     dictParam
    ${dictParam}      Get From Dictionary
    ...     ${data_test['${TEST NAME}']}
    ...     dictParam
    ${CAPTURE}      Get From Dictionary
    ...     ${data_test['${TEST NAME}']}
    ...     CAPTURE
    ${totalNbOfUe}       Get From Dictionary
    ...     ${data_test['${TEST NAME}']}
    ...     NbOfUe
    Set To Dictionary       ${param}     totalNbOfUe       ${totalNbOfUe}
    ${dict_settings_all_ues}      Get From Dictionary
    ...     ${data_test['${TEST NAME}']}
    ...     dict_settings_all_ues
    ${dict_vendor_custom}      Get From Dictionary
    ...     ${data_test['${TEST NAME}']}
    ...     VENDOR_CUSTOM
    ${dict_ExpectedValues}      Get From Dictionary
    ...     ${data_test['${TEST NAME}']}
    ...     ExpectedValues
    # ${dict_settings_all_cells}      Get From Dictionary
    # ...     ${data_test['${TEST NAME}']}
    # ...     dict_settings_all_cells

    dated log    ${consTraceColor}${Json test configuration} present${defColor} ---> need to update test variables
    update test Variables       ${dictParam}    ${CAPTURE}
    set Test variable     ${dict_ues}    ${dict_settings_all_ues}
    set Test variable     ${vendor_custom}    ${dict_vendor_custom}
    set test variable     ${dictExpectedValues}   ${dict_ExpectedValues}
    # set Test variable     ${dict_cells}    ${dict_settings_all_cells}
    robot_extension.Run Keyword And Warn On Failure    Log dictionary          ${vendor_custom}   msg=vendor_custom_test
    robot_extension.Run Keyword And Warn On Failure    Log dictionary          ${dictExpectedValues}   msg=ExpectedValues_test

Process TTI Traces
    [Arguments]     ${Kw_Convert_TtiTrace_From_csv_to_Dict}=Convert TTI trace from csv to dict CB012738    ${step}=${EMPTY}
    ${ret}   ${tti_trace_path}    Run Keyword And Ignore Error   Get TTI traces      suffix=${step}
    ...                                                                              time=${GetTtiTraceTime}
    ...                                                                              w_convert_pcap_to_excelCsv=${w_convert_TtiPcap_to_excelCsv}

    Run Keyword If       '${ret}' == 'FAIL'    BuiltIn.Log    Failed to get TTI traces !!!!   level=ERROR
    Should Not be True   '${ret}' == 'FAIL'
    declare Trace in Trace List  Type=TtiTraces   Savedir=${tti_trace_path}   file_name=ttitrace_streaming.pcap    Trigger=${step}

    ${TTIcsv}  ${UL_TTIcsv}   Run keyword and continue on failure         Convert TTI trace from pcap to excelCsv CB012738
    ...                                                           ttitraceFilename=ttitrace_streaming.pcap    ttitracepath=${tti_trace_path}
    # ${TTIcsv} is used by "Check cellcsirs Assignement" Kw
    set test Variable     ${TTIcsv}
    Run Keywords       dated log    Tti csv file converted using TtiTraceDecoder.py legacyCsv ${TTIcsv}
    ...      AND       dated log    Tti csv file converted using TtiTraceDecoder.py legacyCsv ${UL_TTIcsv}
    Set Log Level    NONE
    ${tti_trace_dict_dl}=      Run keyword and continue on failure   ${Kw_Convert_TtiTrace_From_csv_to_Dict}    TTITraceCsv=${TTIcsv}
    ...                                                                                                 num_of_events=${GetTtiTraceNumOfEvent}
    ${tti_trace_dict_ul}=   Run keyword and continue on failure   Convert TTI trace from csv to dict CB007713    TTITraceCsv=${UL_TTIcsv}
    ...                                                                                                 num_of_events=${GetTtiTraceNumOfEvent}
    Set Log Level    TRACE
    robot_extension.Run Keyword And Warn On Failure      Check PRB Assignment CB008940        ${tti_trace_dict_dl}
    robot_extension.Run Keyword And Warn On Failure      Check UL PRB Assignment CB007113     ${tti_trace_dict_ul}
    [return]   ${tti_trace_path}   ${tti_trace_dict_dl}

Process TTI Traces For test Robustness
    [Arguments]     ${step}=${EMPTY}
    ${ret}   ${tti_trace_path}    Run Keyword And Ignore Error   Get TTI traces      suffix=${step}
    ...                                                                              time=${GetTtiTraceTime}
    ...                                                                              w_convert_pcap_to_excelCsv=${w_convert_TtiPcap_to_excelCsv}

    Run Keyword If       '${ret}' == 'FAIL'    BuiltIn.Log    Failed to get TTI traces !!!!   level=ERROR
    Should Not be True   '${ret}' == 'FAIL'
    declare Trace in Trace List  Type=TtiTraces   Savedir=${tti_trace_path}   file_name=ttitrace_streaming.pcap    Trigger=${step}
    ${TTIcsv}  ${UL_TTIcsv}   Run keyword and continue on failure         Convert TTI trace from pcap to excelCsv CB012738
    ...                                                           ttitraceFilename=ttitrace_streaming.pcap    ttitracepath=${tti_trace_path}
    # ${TTIcsv} is used by "Check cellcsirs Assignement" Kw
    set test Variable     ${TTIcsv}
    Run Keywords       dated log    Tti csv file converted using TtiTraceDecoder.py legacyCsv ${TTIcsv}
    ...      AND       dated log    Tti csv file converted using TtiTraceDecoder.py legacyCsv ${UL_TTIcsv}
    ${tti_trace_dict_dl}      Set Variable     ${EMPTY}
    [return]   ${tti_trace_path}   ${tti_trace_dict_dl}

Sleep with duration "${Time}"s and msg "${Msg}"
    Traced Sleep    duration=${Time}    msg=${Msg}

ObtainEmptyVariablesKeyword
    [Return]   ${EMPTY}     ${EMPTY}

ObtainVariablesKeyword
    [Return]  PASS   ${EMPTY}

AssignValues
    ${ret}    ${tti_trace_path}   ObtainVariablesKeyword


Update gNB Swconfig Content
    [Arguments]                      ${swconfig_gnb}
    [Documentation]     only update swconfig with ${swconfig_gnb} content
    ...        Exemple :
    ...              ${l2ps_rdEnableFDMPdschDmrs_0x5801a6}=      create dictionary          field=0x5801a6
    ...                                                                value=${testParam.rdEnableFDMPdschDmrs_0x5801a6}
    ...              ${cprt_log_level_0x590072}=       create dictionary                  field=0x590072          value=1
    ...              ${my_swconfig_gnb}=                 Create List           ${l2ps_rdEnableFDMPdschDmrs_0x5801a6}
    ...                                                                        ${cprt_log_level_0x590072}
    ...              Update gNB Swconfig Content   swconfig_gnb=${my_swconfig_gnb}
    ${isEmpty}    Run Keyword And Return Status    Should Be Empty      ${swconfig_gnb}
    return from keyword if     ${isEmpty}
    Set Fields in swconfig DU       param_list=${swconfig_gnb}

# 0x58057A 	rdFeatureFlagBitmapLevel  0 VIP  1 ERROR  2 WARNING  3 INFO  4 DEBUG  5 INVALID
# 0x58057B 	rdFeatureFlagBitmap0      Bit 12 DSS
# 0x58057C 	rdFeatureFlagBitmap1      Bit 31 DL.PDSCH_DMRS_FDM    Bit 19 DL.DCI
# L2PS_DSS_DEBUG_RAD_PARAMETERS = {    # Swconfig.txt
#    '0x58057a': '4',
#    '0x58057b': '0x1001',
#    '0x58057c': '0x80080000',
#}
#feature log pooling
#rdFeatureFlagBitmap1: 11 - PRB_POOLING.BASIC,12 - PRB_POOLING.DL,13 - PRB_POOLING.UL ==> binary 0011 1000 0000 0000
# 0x58057C=0x3800
#L2 feature flags
# 0x58057A=4 #pour ERR & WRN & INF & DBG

# feature BWP
# rdFeatureFlagBitmap1: 16 - BWP
# 0x58057C=0x10000

# L2.L2_PS.CELL
# L2.L2_PS.UL.DCI
# 0x58057a = 4
# 0x58057b = 2
# 0x58057d = 512

Set CB012738 L2PS Debug Specific RAD
    [Documentation]   Author: Ch SAMSON , set L2PS CB012738 debug Rad parameters

    ${l2ps_0x58057a}=      create dictionary          field=0x58057a     value=4
    # ${l2ps_0x58057c}=      create dictionary          field=0x58057c     value=0x10000
    # ${l2ps_0x58057b}=      create dictionary          field=0x58057b     value=0x2
    # ${l2ps_0x58057d}=      create dictionary          field=0x58057d     value=0x200
    # ${l2ps_0x58057c}=      create dictionary          field=0x58057c     value=0x2800
    # ${l2ps_0x580580}=      create dictionary          field=0x580580     value=0x800
    ${l2ps_0x58057c}=      create dictionary          field=0x58057c     value=0x2000

    ${swconfig_gnb}=       run Keyword if    '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'     Create List     ${l2ps_0x58057a}
    ...                                                                                                   ${l2ps_0x58057c}
    # ...                                                                                                   ${l2ps_0x580580}
    ...   ELSE                                                                            Create List

    run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log    -----> field=0x58057a value=4 # ERR & WRN & INF & DBG
    # run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log  -----> field=0x58057c value=0x10000 #rdFeatureFlagBitmap1 (L2.L2_PS.BWP)
    # run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log    -----> field=0x58057b value=0x2 #rdFeatureFlagBitmap1 (L2.L2_PS.CELL)
    # run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log   -----> field=0x58057d value=0x200 #rdFeatureFlagBitmap1 (L2.L2_PS.UL.DCI)

    # rdFeatureFlagBitmapLevel  (0x57A) = 4
    # rdFeatureFlagBitmap5 (0x580580) = 0x400 (L2.L2_PS.NBR_SAS_CONGESTIONCTRL)
    # rdFeatureFlagBitmap5 (0x580580) = 0x800 (L2.L2_PS.PRB_POOLING.SPECIAL_DBG)
    # rdFeatureFlagBitmap1  (0x58057c) = 0x1800    (L2.L2_PS.PRB_POOLING.BASIC and L2.L2_PS.PRB_POOLING.DL)
    # rdFeatureFlagBitmap1  (0x58057c) = 0x2800    (L2.L2_PS.PRB_POOLING.BASIC and L2.L2_PS.PRB_POOLING.UL)
    # rdFeatureFlagBitmap1  (0x58057c) = 0x2000    (L2.L2_PS.PRB_POOLING.UL)

    # ${text}=     Catenate    (L2.L2_PS.PRB_POOLING.BASIC and L2.L2_PS.PRB_POOLING.UL)
    # run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log  -----> field=0x58057c value=0x2800 #rdFeatureFlagBitmap1 ${text}
    ${text}=     Catenate    (L2.L2_PS.PRB_POOLING.UL)
    run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log  -----> field=0x58057c value=0x2000 #rdFeatureFlagBitmap1 ${text}
    # ${text}=    Catenate     (L2.L2_PS.PRB_POOLING.SPECIAL_DBG)
    # run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log  -----> field=0x580580 value=0x800 #rdFeatureFlagBitmap5 ${text}

    [return]    ${swconfig_gnb}

Set CB012738 L2PS Debug Specific RAD For PreCheck3
    [Documentation]   Author: Ch SAMSON , set L2PS CB012738 debug Rad parameters

    # DEBUG level
    # ${l2ps_0x58057a}=      create dictionary          field=0x58057a     value=4
    # INFO level
    ${l2ps_0x58057a}=      create dictionary          field=0x58057a     value=3
    ${l2ps_0x58057b}=      create dictionary          field=0x58057b     value=0x200000
    ${l2ps_0x58057c}=      create dictionary          field=0x58057c     value=0x14000
    ${l2ps_0x58057d}=      create dictionary          field=0x58057d     value=0x70000000

    ${swconfig_gnb}=       run Keyword if    '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'     Create List     ${l2ps_0x58057a}
    # ...                                                                                                   ${l2ps_0x58057b}
    # ...                                                                                                   ${l2ps_0x58057c}
    # ...                                                                                                   ${l2ps_0x58057d}
    ...   ELSE                                                                            Create List

    run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log    -----> field=0x58057a value=3 # ERR & WRN & INF
    # run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log    -----> field=0x58057a value=4 # ERR & WRN & INF & DBG
    # run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log    -----> field=0x58057b value=0x200000 #rdFeatureFlagBitmap0
    # run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log    -----> field=0x58057c value=0x14000 #rdFeatureFlagBitmap1
    # run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log    -----> field=0x58057d value=0x70000000 #rdFeatureFlagBitmap2

    # rdFeatureFlagBitmapLevel  (0x57A) = 4
    # rdFeatureFlagBitmap5 (0x580580) = 0x400 (L2.L2_PS.NBR_SAS_CONGESTIONCTRL)
    # rdFeatureFlagBitmap5 (0x580580) = 0x800 (L2.L2_PS.PRB_POOLING.SPECIAL_DBG)
    # rdFeatureFlagBitmap1  (0x58057c) = 0x1800    (L2.L2_PS.PRB_POOLING.BASIC and L2.L2_PS.PRB_POOLING.DL)
    # rdFeatureFlagBitmap1  (0x58057c) = 0x2800    (L2.L2_PS.PRB_POOLING.BASIC and L2.L2_PS.PRB_POOLING.UL)
    # rdFeatureFlagBitmap1  (0x58057c) = 0x2000    (L2.L2_PS.PRB_POOLING.UL)

    #rdFeatureFlagBitmapLevel
    # 0x58057a=0x4
    #rdFeatureFlagBitmap0
    # 0x58057b=0x200000
    #rdFeatureFlagBitmap1
    # 0x58057c=0x14000
    #rdFeatureFlagBitmap2
    # 0x58057d=0x70000000

    [return]    ${swconfig_gnb}

Set RAD Params Of 9836
    [Documentation]     Add or Modify the RAD params of 9836
    ...                 0x58057A=4 : L2 feature flags : ERR & WRN & INF & DBG
    ...                 0x58057C=0x3800 : rdFeatureFlagBitmap1
    ...                     bit 11 - PRB_POOLING.BASIC,
    ...                     bit 12   PRB_POOLING.DL,
    ...                     bit 13 - PRB_POOLING.UL ==> binary 0011 1000 0000 0000
    ...                 0x58057C=0x10000 : rdFeatureFlagBitmap1
    ...                     bit 16   BWP
    Dated Log New Line   Add RAD params of 9836 ......
    dated log    -----> field=0x3F007C value=500 #GNB BIP size, unit is M
    dated log    -----> field=0x420080 value=1 # 1=rdTddSubcellDeactEnable (CB009890)
    dated log    -----> field=0x4B000F value=1 # 1=RF_SW_Version_check_disabled
    ${rad_param_1}=      create dictionary       field=0x3F007C    value=500
    ${rad_param_2}=      create dictionary       field=0x420080    value=1   # rdTddSubcellDeactEnable (CB009890)
    ${rad_param_3}=      create dictionary       field=0x4B000F    value=1   # RF_SW_Version_check_disabled
    ${rad_param_list}=       Create List         ${rad_param_1}     ${rad_param_2}    ${rad_param_3}
    SetConfig.Set Fields in swconfig DU       param_list=${rad_param_list}
    ${l2ps_debug_swconfig_gnb}=      Set CB012738 L2PS Debug Specific RAD
    Update gNB Swconfig Content   ${l2ps_debug_swconfig_gnb}
    Dated Log New Line   RAD params of 9836 update completed


Set_NRBTS_mod_ListParam
    [Documentation]
    ...              This KW will help to set actDl256Qam on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${arg}    ${value}    ${modiflist}
    Dated Log      "${arg} set ${value}"
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    &{modify_param}   Create Dictionary
    ...                    parameter=${arg}
    ...                    dist_name=${dn}
    ...                    value=${value}
    Append To List     ${modiflist}          ${modify_param}
    [return]     ${modiflist}

Set_NRCELL_mod_ListParam
    [Documentation]
    ...              This KW will help to set actDl256Qam on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${arg}    ${value}    ${cell}  ${modiflist}
    Dated Log      "${arg} set ${value}"
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell}
    &{modify_param}   Create Dictionary
    ...                    parameter=${arg}
    ...                    dist_name=${dn}
    ...                    value=${value}
    Append To List     ${modiflist}          ${modify_param}
    [return]     ${modiflist}

Set_NIDD_modification_ListParam
    [Documentation]   Set_NIDD_modification_ListParam
    [Arguments]    ${pname}    ${value}    ${dn}    ${modiflist}
    Dated Log      "${pname} set ${value}"
    &{modify_param}   Create Dictionary
    ...                    parameter=${pname}
    ...                    dist_name=${dn}
    ...                    value=${value}
    Append To List     ${modiflist}          ${modify_param}
    [return]     ${modiflist}

Update gNB OAM List Param
    [Arguments]                      ${oam_param_gnb}
    [Documentation]     only update OAM Parameters with ${oam_param_gnb} content
    ${isEmpty}    Run Keyword And Return Status    Should Be Empty      ${oam_param_gnb}
    return from keyword if     ${isEmpty}
    OAM Set Params            ${oam_param_gnb}            # OAM need a list ....

All Available Cells Should Be Onair
     ${scf_dss_type}    testline-Keywords.Get Dss Info
     ${scf_CellDepType_Cell1}   testline-Keywords.Get CellDepType_Cell1 Info
     ${scf_dss_type}   set variable if   '${scf_dss_type}'=='DSS_Phase_3' and ${cell2_is_Dss}    DSS_Phase_3_2Cells    DSS_Phase_3
     IF    '${scf_dss_type}'=='DSS_Phase_3_2Cells' and '${gNbCuType}'!='NSA'
        TARF-Keywords.Cells 1 and 2 Should Be Onair    timeout=120
     ELSE IF     '${scf_dss_type}'=='DSS_Phase_3' and '${scf_CellDepType_Cell1}'=='NSA'
        TARF-Keywords.NSA Cell 1 Should Be Onair      timeout=120
     ELSE
        TARF-Keywords.All Cells Should Be Onair    timeout=120
     END

All Available Cells Should Be Onair version 1
     ${scf_dss_type}    testline-Keywords.Get Dss Info
     ${scf_CellDepType_Cell1}   testline-Keywords.Get CellDepType_Cell1 Info
     ${scf_dss_type}   set variable if   '${scf_dss_type}'=='DSS_Phase_3' and ${cell2_is_Dss}    DSS_Phase_3_2Cells    DSS_Phase_3
     IF    '${scf_dss_type}'=='DSS_Phase_3' and '${gNbCuType}'=='SA+NSA' and '${scf_CellDepType_Cell1}'!='NSA'
        TARF-Keywords.Cells 1 Should Be Onair      timeout=120
     ELSE IF    '${scf_dss_type}'=='DSS_Phase_3_2Cells' and '${gNbCuType}'!='NSA'
        TARF-Keywords.Cells 1 and 2 Should Be Onair    timeout=120
     ELSE IF     '${scf_dss_type}'=='DSS_Phase_3' and '${scf_CellDepType_Cell1}'=='NSA'
        TARF-Keywords.NSA Cell 1 Should Be Onair      timeout=120
     ELSE
        TARF-Keywords.All Cells Should Be Onair    timeout=120
     END

All Cells Should Be Onair
    [Arguments]    ${timeout}=120
    dated log      Check All Cells Should Be Onair...
    Dev_lib.cells_should_be_onair     timeout=${timeout}     check_sib=${True}    alias=coam_gnb

Cells 1 Should Be Onair
    [Arguments]    ${timeout}=120
    dated log      Check Cells 1 Should Be Onair...
    Dev_lib.cells_should_be_onair     cell_id=1    timeout=${timeout}    check_sib=${True}    alias=coam_gnb

NSA Cell 1 Should Be Onair
    [Arguments]    ${timeout}=120
    dated log      Check NSA Cells 1 Should Be Onair...
    Dev_lib.cells_should_be_onair     cell_id=1    timeout=${timeout}    check_sib=${False}    check_mib=${True}    alias=coam_gnb

Cells 1 and 2 Should Be Onair
    [Arguments]    ${timeout}=120
    dated log      Check Cells 1 and 2 Should Be Onair...
    Dev_lib.cells_should_be_onair     cell_id=1    timeout=${timeout}    check_sib=${True}    alias=coam_gnb
    Dev_lib.cells_should_be_onair     cell_id=2    timeout=${timeout}    check_sib=${True}    alias=coam_gnb

Cell 1 cell 2 and cell3 Should Be Onair
    dated log      Check Cell 1 Cell 2 and Cell3 Should Be Onair...
    Dev_lib.cells_should_be_onair     cell_id=1    check_sib=${True}    alias=coam_gnb
    Dev_lib.cells_should_be_onair     cell_id=2    check_sib=${True}    alias=coam_gnb
    Dev_lib.cells_should_be_onair     cell_id=3    check_sib=${True}    alias=coam_gnb

Cell 1 cell 2 Cell3 and cell4 Should Be Onair
    dated log      Check Cell 1 Cell 2 Cell3 and Cell4 Should Be Onair...
    Dev_lib.cells_should_be_onair     cell_id=1    check_sib=${True}    alias=coam_gnb
    Dev_lib.cells_should_be_onair     cell_id=2    check_sib=${True}    alias=coam_gnb
    Dev_lib.cells_should_be_onair     cell_id=3    check_sib=${True}    alias=coam_gnb
    Dev_lib.cells_should_be_onair     cell_id=4    check_sib=${True}    alias=coam_gnb

OnlineParamChange
    [documentation]     ${Online_Param} = @{PARAMS_FOR_FEATURE}
    ...                 for ex : ${Online_Param}=['MRBTS-1:btsName=7-20-UTE5GCLASSTL009 - IWK19',
    ...                                           'NRCELL-2:actPdschAtSsbSlots=true',
    ...                                           'NRCELL-2:dtxOptimizedScheduler:dtxPrbThreshold=100']
    [Arguments]    ${Online_Param}
    ${isEmpty}    Run Keyword And Return Status    Should Be Empty      ${Online_Param}
    return from keyword if     ${isEmpty}
    Dev_lib.delta_commission_parameters    ${Online_Param}
    OAM wait available     # instead of 'Cells 1 and 2 Should Be Onair' Kw Call

Set_NIDD_OnlineChange_ListParam
    [Documentation]   Set_NIDD_OnlineChange_ListParam
    [Arguments]    ${pname}    ${value}    ${dn}    ${modiflist}
    ${basename_pname_cmd}=    Catenate     basename ${dn}
    ${basename_pname}=   OperatingSystem.Run   ${basename_pname_cmd}
    Dated Log      "${basename_pname}:${pname} set ${value}"
    ${modify_param}=    Set Variable      ${basename_pname}:${pname}=${value}
    Append To List      ${modiflist}      ${modify_param}
    [return]     ${modiflist}

get item from dict
    [Arguments]    ${modiflist}    ${basename_dn}   ${pname}   ${mydict}
    ${items}     Get Dictionary Items   ${mydict}
    FOR    ${key}    ${value}     IN    @{items}
        ${res}=     Set Variable   ${key}=${value}
        ${modify_param}=    Set Variable      ${basename_dn}:${pname}:${res}
        Append To List      ${modiflist}      ${modify_param}
    END
    [return]     ${modiflist}

Set_NIDD_OnlineChange_From_List
    [Documentation]   Set_NIDD_OnlineChange_From_List
    ...     ${NIDD_struct} = {'dist_name':'&{item}[dist_name]','parameter':'&{item}[list_name]','value':[&{item}[value]]}
    [Arguments]    ${modiflist}     ${NIDD_struct}
    ${dist_name}=    Get From Dictionary    ${NIDD_struct}    dist_name
    ${basename_pname_cmd}=    Catenate     basename ${dist_name}
    ${basename_pname}=   OperatingSystem.Run   ${basename_pname_cmd}
    ${pname}=        Get From Dictionary    ${NIDD_struct}    parameter
    ${valueList}=    Get From Dictionary    ${NIDD_struct}    value
    Dated Log      "${basename_pname}:${pname} set ${valueList}"
    FOR     ${item}    IN    @{valueList}
        Dated Log     item=${item}
        ${modiflist}=     get item from dict    ${modiflist}  ${basename_pname}   ${pname}  ${item}
    END
    [return]     ${modiflist}

Set NIDD PARAMETERS VERSION 4
    [Arguments]    ${list}    ${kw_setOnLine_ListParam}=${EMPTY}     ${KwOnlineParamChange}=${EMPTY}
    #** SCF update
    Run Keyword And Return If    '${kw_setOnLine_ListParam}'=='${EMPTY}'
    ...                                        Dated log  "kw_setOnLine_ListParam" param empty when calling "Set NIDD PARAMETERS VERSION 4" Kw
    Run Keyword And Return If    '${KwOnlineParamChange}'=='${EMPTY}'
    ...                                        Dated log  "KwOnlineParamChange" param empty when calling "Set NIDD PARAMETERS VERSION 4" Kw
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    @{OAMParam_modiflist}    Create List
    scf.load_scf	 ${current_scf_fullname}
    FOR    ${item}    IN    @{list}
         ${val_dtxMaxRetentionDelay}=	 run Keyword if    'list_name' in ${item}   scf.get_value_from_scf    dist_name=&{item}[dist_name]
         ...                                                                              list_name=&{item}[list_name]
         ...                                                                              index=4
         # run Keyword if    'list_name' in ${item}       dated log   val_dtxMaxRetentionDelay=${val_dtxMaxRetentionDelay} for &{item}[dist_name]
         ${val_dtxPrbThreshold}=	 run Keyword if    'list_name' in ${item}   scf.get_value_from_scf    dist_name=&{item}[dist_name]
         ...                                                                              list_name=&{item}[list_name]
         ...                                                                              index=5
         # run Keyword if    'list_name' in ${item}        dated log   val_dtxPrbThreshold=${val_dtxPrbThreshold} for &{item}[dist_name]
         ${val_dtxMaxRetentionDelay_toCheck}=  run Keyword if    'list_name' in ${item}    Get From Dictionary  &{item}[value]   dtxMaxRetentionDelay
         # run Keyword if    'list_name' in ${item}        dated log     val_dtxMaxRetentionDelay_toCheck=${val_dtxMaxRetentionDelay_toCheck}
         ${val_dtxPrbThreshold_toCheck}=  run Keyword if    'list_name' in ${item}    Get From Dictionary  &{item}[value]   dtxPrbThreshold
         # run Keyword if    'list_name' in ${item}        dated log     val_dtxPrbThreshold_toCheck=${val_dtxPrbThreshold_toCheck}
         ${condition1}=   run Keyword if    'list_name' in ${item}   Evaluate   ${val_dtxPrbThreshold}==${val_dtxPrbThreshold_toCheck}
         ${condition2}=   run Keyword if    'list_name' in ${item}   Evaluate   ${val_dtxPrbThreshold}==${val_dtxPrbThreshold_toCheck}
         continue for loop if   'list_name' in ${item} and ${condition1} and ${condition2}
         &{NIDD_struct}    run Keyword if    'list_name' in ${item}       Evaluate
         ...                {'dist_name':'&{item}[dist_name]','parameter':'&{item}[list_name]','value':[&{item}[value]]}
         &{NIDD_OnLineChanges_struct}    run Keyword if    'list_name' in ${item}       Evaluate
         ...                {'dist_name':'&{item}[dist_name]','parameter':'&{item}[list_name]','value':[&{item}[value]]}
         run Keyword if    'list_name' in ${item} and '${kw_setOnLine_ListParam}'=='Set_NIDD_modification_ListParam'
         ...                                         Append To List     ${OAMParam_modiflist}          ${NIDD_struct}
         ...      ELSE                               set variable       ${OAMParam_modiflist}
         run Keyword if    'list_name' in ${item} and '${kw_setOnLine_ListParam}'=='Set_NIDD_OnlineChange_ListParam'
         ...                                         Set_NIDD_OnlineChange_From_List    ${OAMParam_modiflist}   ${NIDD_OnLineChanges_struct}
         ...      ELSE                               set variable       ${OAMParam_modiflist}
         continue for loop if     'list_name' in ${item}
         ${val}	 scf.get_value_from_scf   p_name=&{item}[pname]
         ...                              dist_name=&{item}[dist_name]
         continue for loop if  '${val}'=='&{item}[value]'
         ${val_to_update}=   set variable if   '${val.lower()}'!='&{item}[value]'     True
         ...                                                                          False
         ${OAMParam_modiflist}=  Run Keyword if   '${val_to_update}'=='True'    ${kw_setOnLine_ListParam}      &{item}[pname]
         ...                                                                                                   &{item}[value]
         ...                                                                                                   &{item}[dist_name]
         ...                                                                                                   ${OAMParam_modiflist}
         ...   ELSE              set variable   ${OAMParam_modiflist}
         Run Keyword if   '${val_to_update}'=='True'               Dated log    &{item}[pname] Updated in Scf
    END
    ${isEmpty}    Run Keyword And Return Status    Should Be Empty      ${OAMParam_modiflist}
    Run Keyword And Return If     ${isEmpty}     dated log     [${kw_setOnLine_ListParam}] OAM Param List to change empty...
    dated log     OAMParam_modiflist=${OAMParam_modiflist} to Online change...
    # Update gNB OAM List Param   ${OAMParam_modiflist}
    Run Keyword     ${KwOnlineParamChange}       ${OAMParam_modiflist}
    return from Keyword

Connect to COAM ADMIN
    [documentation]   only one Connect to COAM ADMIN call and coam_gnb alias is used by every coam request
    [Arguments]    ${gnb_id}=0  ${bts_host}=${EMPTY}
    ${bts_host}=  Set Variable if  '${bts_host}'=='${EMPTY}'  ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}  ${bts_host}
    coam.setup_admin    bts_host=${bts_host}    name=coam_gnb

Display Important NIDD param
    [Arguments]    ${w_setup_admin}=False
    StringTool.printLineWithTitle     title=NIDD parameters MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id} and MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL
    # ${num_of_cells}=    Get Cell Number
    ${bts_host}=  Set Variable if   '${w_setup_admin}'=='True'     ${tl.gnbs[${0}].cu.oam_http_connection_details.addr}
    run Keyword if     '${w_setup_admin}'=='True'     coam.setup_admin    bts_host=${bts_host}    name=coam_gnb
    ${num_of_cells}=    COAM Get Cell Number    connection=coam_gnb
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
        ${cell_id_}    Evaluate    ${cell_id} + ${1}
        ${cellgrp_id}=      Get Cell Group From Cell     cell_id=${cell_id_}  connection=coam_gnb
        ${msg_display}=    StringTool.getHeaderLine    CellId ${cell_id_} is located in     CellGroupId ${cellgrp_id}
        dated log      ${msg_display}
        # dated log     CellId ${cell_id_} => CellGroupId ${cellgrp_id}
    END
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    StringTool.printLineWithTitle     Display Voip, GBR, Frame Structure NIDD parameters
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
         ${cell_id_}    Evaluate    ${cell_id} + ${1}
         ${actNonVoNRGbrService}=    Get NRCELL Param from SCF   param=actNonVoNRGbrService   CellId=${cell_id_}
         ${actVoNR}=                 Get NRCELL Param from SCF   param=actVoNR   CellId=${cell_id_}
         ${maxNumOfGBRBearersSA}=    Get NRCELL Param from SCF   param=maxNumOfGBRBearersSA   CellId=${cell_id_}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/actNonVoNRGbrService
         ...                                             ${actNonVoNRGbrService}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/actVoNR
         ...                                             ${actVoNR}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/maxNumOfGBRBearersSA
         ...                                             ${maxNumOfGBRBearersSA}
         dated log      ${msg_display}
    END
    # seems that NRDRB-15 is mandatory for GBR VoiP bearer (QCI1)
    ${result}    scf.is_object_in_scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRDRB-15
    run keyword if    '${result}'=='False'    dated log  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRDRB-15 not PRESENT in SCF
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
         ${cell_grp_id}    Evaluate    ${cell_id} + ${0}
         ${cell_id_}    Evaluate    ${cell_id} + ${1}
         ${csiReportPeriodicity}=    Get NRCELL Param from SCF   param=csiReportPeriodicity   CellId=${cell_id_}
         ${csirsTrackingPeriod}=     Get NRCELL Param from SCF   param=csirsTrackingPeriod   CellId=${cell_id_}
         ${cellTechnology}=          Get NRCELL Param from SCF   param=cellTechnology   CellId=${cell_id_}
         ${frameStructureType}=   Run Keyword if   '${cellTechnology}'=='TDD'
         ...                             Get NRCELL Param from SCF   param=frameStructureType   CellId=${cell_id_}
         ...     ELSE                    Set Variable      ${None}
         ${ulDlDataSlotRatio}=      Run Keyword if   '${cellTechnology}'=='TDD'
         ...                             Get NRCELL Param from SCF   param=ulDlDataSlotRatio   CellId=${cell_id_}
         ...     ELSE                    Set Variable      ${None}
         ${actDtxOptimizedScheduler}=       Get NRCELL Param from SCF   param=actDtxOptimizedScheduler   CellId=${cell_id_}
         ${actDlPaWarmUp}=           Get NRCELL Param from SCF   param=actDlPaWarmUp   CellId=${cell_id_}
         # MRBTS-1/NRBTS-1/NRCELLGRP-0 => to improve later !!!!
         # ${ssBurstSetPeriod}=        Get NRCELLGRP Param from SCF   param_name=ssBurstSetPeriod   CellId=${cell_id_}
         ${ssBurstSetPeriod}	 scf.get_value_from_scf           p_name=ssBurstSetPeriod
         ...                                                      dist_name=MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELLGRP-${cell_grp_id}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/cellTechnology
         ...                                             ${cellTechnology}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/frameStructureType
         ...                                             ${frameStructureType}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/ulDlDataSlotRatio
         ...                                             ${ulDlDataSlotRatio}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/ssBurstSetPeriod
         ...                                             ${ssBurstSetPeriod}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/csiReportPeriodicity
         ...                                             ${csiReportPeriodicity}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/csirsTrackingPeriod
         ...                                             ${csirsTrackingPeriod}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/actDtxOptimizedScheduler
         ...                                             ${actDtxOptimizedScheduler}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/actDlPaWarmUp
         ...                                             ${actDlPaWarmUp}
         dated log      ${msg_display}
    END
    # Display NRRIM_PROFILE-1 NIDD param
    run keyword and ignore error     Display PRB POOLING NIDD param
    # Display PRB Blanking NIDD parameters
    StringTool.printLineWithTitle     title=-
    return from Keyword

Display NRRIM_PROFILE-1 NIDD param
    StringTool.printLineWithTitle
    ...     title=NRRIM_PROFILE-1 NIDD parameters MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id} and MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL
    ${num_of_cells}=    Get Cell Number
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    StringTool.printLineWithTitle     Display NRRIM_PROFILE NIDD parameters
    ${num_of_cells}=    Get Cell Number
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
         ${cell_id_}    Evaluate    ${cell_id} + ${1}
         ${nrRimMitigationScheme}=    Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=nrRimMitigationScheme   CellId=${cell_id_}
         ${numRbForRs}=               Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=numRbForRs   CellId=${cell_id_}
         ${numRsType1SetId}=          Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=numRsType1SetId   CellId=${cell_id_}
         ${repetitionRsType1}=        Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=repetitionRsType1   CellId=${cell_id_}
         ${rsNearFarConfig}=          Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=rsNearFarConfig   CellId=${cell_id_}
         ${rsTransTrigger}=           Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=rsTransTrigger   CellId=${cell_id_}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/NRRIM_PROFILE-1/nrRimMitigationScheme
         ...                                             ${nrRimMitigationScheme}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/NRRIM_PROFILE-1/numRbForRs
         ...                                             ${numRbForRs}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/NRRIM_PROFILE-1/numRsType1SetId
         ...                                             ${numRsType1SetId}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/NRRIM_PROFILE-1/repetitionRsType1
         ...                                             ${repetitionRsType1}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/NRRIM_PROFILE-1/rsNearFarConfig
         ...                                             ${rsNearFarConfig}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/NRRIM_PROFILE-1/rsTransTrigger
         ...                                             ${rsTransTrigger}
         dated log      ${msg_display}
         # ${startRbForRs}=        Get startRbForRs Parameters From gNB     CellId=${cell_id_}
         # ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/NRRIM_PROFILE-1/startRbForRs
         # ...                                             ${startRbForRs}
         # dated log      ${msg_display}
    END
    StringTool.printLineWithTitle     title=-
    return from Keyword

Display PRB POOLING NIDD param
    StringTool.printLineWithTitle
    ...     title=PRB POOLING NIDD parameters MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}
    ${num_of_cells}=    Get Cell Number
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    StringTool.printLineWithTitle     Display PRB POOLING NIDD parameters
    ${actSlowPrbPooling}=    Get NRBTS Param from SCF   param_name=actSlowPrbPooling
    ${msg_display}=    StringTool.getHeaderLine  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/actSlowPrbPooling (5GC001227 Baseband pooling of PRBs - FR1 FDD)
    ...                                          ${actSlowPrbPooling}
    dated log      ${msg_display}

    ${actSlowPrbPoolingFddFr1Enh}=    Get NRBTS Param from SCF   param_name=actSlowPrbPoolingFddFr1Enh
    ${text}=   Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/actSlowPrbPoolingFddFr1Enh (CB009215 PRB pooling for FDD cells - concept refinement)
    ${msg_display}=    StringTool.getHeaderLine     ${text}    ${actSlowPrbPoolingFddFr1Enh}
    dated log      ${msg_display}

    ${actSpatialStreamPooling}=    Get NRBTS Param from SCF   param_name=actSpatialStreamPooling
    ${text}=    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/actSpatialStreamPooling (5GC002093 Shared real time baseband resources - FR1 TDD)
    ${msg_display}=    StringTool.getHeaderLine     ${text}    ${actSpatialStreamPooling}
    dated log      ${msg_display}

    ${actTddPrePooling}=    Get NRBTS Param from SCF   param_name=actTddPrePooling
    ${text}=    Set Variable     MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/actTddPrePooling (5GC002093 Shared real time baseband resources - FR1 TDD)
    ${msg_display}=    StringTool.getHeaderLine     ${text}    ${actTddPrePooling}
    dated log      ${msg_display}

    ${actLargeBbPoolTddFr1}=    Get NRBTS Param from SCF   param_name=actLargeBbPoolTddFr1
    ${text}=    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/actLargeBbPoolTddFr1 (CB007112 Baseband pooling of up to 16 DL MIMO layers)
    ${msg_display}=    StringTool.getHeaderLine  ${text}      ${actLargeBbPoolTddFr1}
    dated log      ${msg_display}

    ${actBbPoolTddFr1}=    Get NRBTS Param from SCF   param_name=actBbPoolTddFr1
    ${msg_display}=    StringTool.getHeaderLine  MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/actBbPoolTddFr1 (CB008940 Baseband resource pooling - FR1 TDD)
    ...                                          ${actBbPoolTddFr1}
    dated log      ${msg_display}
    ${actBbPoolExtensionTddFr1}=    Get NRBTS Param from SCF   param_name=actBbPoolExtensionTddFr1
    ${text}=    Set Variable      MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/actBbPoolExtensionTddFr1 (CB010513 Baseband pooling - Extensions for FR1 TDD)
    ${msg_display}=    StringTool.getHeaderLine     ${text}      ${actBbPoolExtensionTddFr1}
    dated log      ${msg_display}
    ${actBbPoolTddFr1AlgEnh}=    Get NRBTS Param from SCF   param_name=actBbPoolTddFr1AlgEnh
    ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/actBbPoolTddFr1AlgEnh (TMO CAS)
         ...                                             ${actBbPoolTddFr1AlgEnh}
    dated log      ${msg_display}
    ${actBbPoolTddFr1Enh}=    Get NRBTS Param from SCF   param_name=actBbPoolTddFr1Enh
    ${text}=    Set Variable     MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/actBbPoolTddFr1Enh (CB011028 Baseband pooling - Enhancements for FR1 TDD)
    ${msg_display}=    StringTool.getHeaderLine          ${text}      ${actBbPoolTddFr1Enh}
    dated log      ${msg_display}

    ${allowSlowPrbPoolingStatNdmSrs}=    Get NRBTS Param from SCF   param_name=allowSlowPrbPoolingStatNdmSrs
    ${text}=    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/allowSlowPrbPoolingStatNdmSrs (slow static NDM-SRS PRB pooling is allowed or not)
    ${msg_display}=    StringTool.getHeaderLine          ${text}      ${allowSlowPrbPoolingStatNdmSrs}
    dated log      ${msg_display}

    ${actExplicitCsirsPoolSolution}=    Get NRBTS Param from SCF   param_name=actExplicitCsirsPoolSolution
    ${comment}=      Catenate    (CB010513-SR-A Activate explicit TRS CSI-RS pooling solution)
    ${text}=    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/actExplicitCsirsPoolSolution ${comment}
    ${msg_display}=    StringTool.getHeaderLine          ${text}      ${actExplicitCsirsPoolSolution}
    dated log      ${msg_display}

    ${comment}=      Catenate    (CB008247 Activate UE and cell specific CSI-RS coexist)
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
         ${cell_id_}    Evaluate    ${cell_id} + ${1}
         ${actUeCsirsCoexistCellCsirs}=    Get NRCELL Param from SCF   param=actUeCsirsCoexistCellCsirs   CellId=${cell_id_}
        ${text}=    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/actUeCsirsCoexistCellCsirs ${comment}
        ${msg_display}=    StringTool.getHeaderLine          ${text}      ${actUeCsirsCoexistCellCsirs}
        dated log      ${msg_display}
    END

    ${comment}=      Catenate    (CB012738-SR-A: TDD CSI-SR allocation Optimization)
    ${text}=    Set Variable   In vendorFile actTddCsirsAllocOptimization ${comment}
    ${msg_display}=    StringTool.getHeaderLine          ${text}      ${actTddCsirsAllocOptimizationInVendorFile}
    dated log      ${msg_display}

    ${actTddCsiRsOpt}=    Get NRBTS Param from SCF   param_name=actTddCsiRsOpt
    ${comment}=      Catenate    (CB012269: Activate TDD CSI-RS optimization)
    ${text}=    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/actTddCsiRsOpt ${comment}
    ${msg_display}=    StringTool.getHeaderLine          ${text}      ${actTddCsiRsOpt}
    dated log      ${msg_display}

    StringTool.printLineWithTitle     title=-
    return from Keyword

Display PRB Blanking NIDD parameters
    StringTool.printLineWithTitle
    ...     title=PRB Blanking NIDD parameters MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}
    ${num_of_cells}=    Get Cell Number
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    StringTool.printLineWithTitle     Display PRB Blanking NIDD parameters
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
         ${cell_id_}    Evaluate    ${cell_id} + ${1}
         ${actPRBBlanking}=                        Get NRCELL Param from SCF   param=actPRBBlanking   CellId=${cell_id_}
         ${trsMutingInBlankedPRBsEnabled}=         Get NRCELL Param from SCF   param=trsMutingInBlankedPRBsEnabled   CellId=${cell_id_}
         ${nbrOfBlankedPRBsHighEdgeDL}=            Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeDL   CellId=${cell_id_}
         ${nbrOfBlankedPRBsHighEdgeUL}=            Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeUL   CellId=${cell_id_}
         ${nbrOfBlankedPRBsLowEdgeDL}=             Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeDL   CellId=${cell_id_}
         ${nbrOfBlankedPRBsLowEdgeUL}=             Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeUL   CellId=${cell_id_}
         ${prachConfigurationIndex}=               Get NRCELL Param from SCF   param=prachConfigurationIndex   CellId=${cell_id_}
         ${msg1FrequencyStart}=                    Get NRCELL Param from SCF   param=msg1FrequencyStart   CellId=${cell_id_}
         ${trsMutingInBlankedPRBsEnabled}=         Get NRCELL Param from SCF   param=trsMutingInBlankedPRBsEnabled   CellId=${cell_id_}
         ${type0CoresetConfigurationIndex}=        Get NRCELL Param from SCF   param=type0CoresetConfigurationIndex   CellId=${cell_id_}
         ${type0SearchSpaceConfigurationIndex}=    Get NRCELL Param from SCF   param=type0SearchSpaceConfigurationIndex   CellId=${cell_id_}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/actPRBBlanking
         ...                                             ${actPRBBlanking}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/trsMutingInBlankedPRBsEnabled
         ...                                             ${trsMutingInBlankedPRBsEnabled}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/nbrOfBlankedPRBsLowEdgeDL
         ...                                             ${nbrOfBlankedPRBsLowEdgeDL}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/nbrOfBlankedPRBsLowEdgeUL
         ...                                             ${nbrOfBlankedPRBsLowEdgeUL}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/nbrOfBlankedPRBsHighEdgeDL
         ...                                             ${nbrOfBlankedPRBsHighEdgeDL}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/nbrOfBlankedPRBsHighEdgeUL
         ...                                             ${nbrOfBlankedPRBsHighEdgeUL}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/prachConfigurationIndex
         ...                                             ${prachConfigurationIndex}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/msg1FrequencyStart
         ...                                             ${msg1FrequencyStart}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/trsMutingInBlankedPRBsEnabled
         ...                                             ${trsMutingInBlankedPRBsEnabled}
         dated log      ${msg_display}
                  ${msg_display}=    StringTool.getHeaderLine   MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/type0CoresetConfigurationIndex
         ...                                             ${type0CoresetConfigurationIndex}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/type0SearchSpaceConfigurationIndex
         ...                                             ${type0SearchSpaceConfigurationIndex}
         dated log      ${msg_display}
    END
    StringTool.printLineWithTitle     title=-
    return from Keyword

Get periodicCsiAcquisition Parameters From gNB
    [Arguments]      ${CellId}=1   ${listindex}=0     ${nodeType}=Classical
    ${periodicCsiAcquisitionList_params_list}    Create List    csiReportPeriodicity    csirsNumberWithinReportPeriod_Set1
    ...                                          csirsPower    maxCsirsNumber    scramblingIdStep
    # Get SCF File (SCF.xml) is performed in test setup
    ${scf_path}    set Variable      ${test_scf_file}
    ${periodicCsiAcquisitionList_params_list_result}    nps_trf_tools.get_feature_paramters_from_scf    ${scf_path}
    ...        ${periodicCsiAcquisitionList_params_list}
    ...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}    periodicCsiAcquisition    index=${listindex}
    [Return]    ${periodicCsiAcquisitionList_params_list_result}


Display periodicCsiAcquisition NIDD parameters
    StringTool.printLineWithTitle
    ...     title=periodicCsiAcquisition NIDD parameters MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}
    ${num_of_cells}=    Get Cell Number
    StringTool.printLineWithTitle     Display periodicCsiAcquisition NIDD parameters
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
         ${cell_id_}    Evaluate    ${cell_id} + ${1}
         ${periodicCsiAcquisition_params_list_result}=    Get periodicCsiAcquisition Parameters From gNB        CellId=${cell_id_}
         ${msg_display}=    StringTool.getHeaderLine    NRCELL-${cell_id_}/periodicCsiAcquisition
         ...                                             ${periodicCsiAcquisition_params_list_result}
         dated log      ${msg_display}
    END
    StringTool.printLineWithTitle     title=-
    return from Keyword

Display NIDD param
    StringTool.printLineWithTitle
    ...     title=NIDD parameters MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}
    ${num_of_cells}=    Get Cell Number
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    StringTool.printLineWithTitle     Display NIDD parameters
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
         ${cell_id_}    Evaluate    ${cell_id} + ${1}
         # to bypass CELL3 and CELL4 (FDD Cells)
         ${cellTechnology}=               Get NRCELL Param from SCF   param=cellTechnology   CellId=${cell_id_}
         continue for loop if     '${cellTechnology}' == 'FDD'
         ${trsMutingInBlankedPRBsEnabled}=   Get NRCELL Param from SCF   param=trsMutingInBlankedPRBsEnabled   CellId=${cell_id_}
         ${nbrOfBlankedPRBsHighEdgeDL}=      Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeDL   CellId=${cell_id_}
         ${nbrOfBlankedPRBsHighEdgeUL}=      Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeUL   CellId=${cell_id_}
         ${nbrOfBlankedPRBsLowEdgeDL}=       Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeDL    CellId=${cell_id_}
         ${nbrOfBlankedPRBsLowEdgeUL}=       Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeUL    CellId=${cell_id_}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/trsMutingInBlankedPRBsEnabled
         ...                                             ${trsMutingInBlankedPRBsEnabled}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/nbrOfBlankedPRBsLowEdgeDL
         ...                                             ${nbrOfBlankedPRBsLowEdgeDL}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/nbrOfBlankedPRBsLowEdgeUL
         ...                                             ${nbrOfBlankedPRBsLowEdgeUL}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/nbrOfBlankedPRBsHighEdgeDL
         ...                                             ${nbrOfBlankedPRBsHighEdgeDL}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/nbrOfBlankedPRBsHighEdgeUL
         ...                                             ${nbrOfBlankedPRBsHighEdgeUL}
         dated log      ${msg_display}
    END
    StringTool.printLineWithTitle     title=-
    return from Keyword

Display CB010596 NIDD param
    StringTool.printLineWithTitle
    ...     title=CB010596 NIDD parameters MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}
    ${num_of_cells}=    Get Cell Number
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    StringTool.printLineWithTitle     Display CB010596 NIDD parameters
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
         ${cell_id_}    Evaluate    ${cell_id} + ${1}
         # to bypass CELL3 and CELL4 (FDD Cells)
         ${cellTechnology}=               Get NRCELL Param from SCF   param=cellTechnology   CellId=${cell_id_}
         continue for loop if     '${cellTechnology}' == 'FDD'
         ${actLongPucchResourceOpt}=      Get NRCELL Param from SCF   param=actLongPucchResourceOpt   CellId=${cell_id_}
         ${pucchF1ResOccConf}=            Get NRCELL Param from SCF   param=pucchF1ResOccConf   CellId=${cell_id_}
         ${actIncreasedFdmUsersPerSlot}=  Get NRCELL Param from SCF   param=actIncreasedFdmUsersPerSlot   CellId=${cell_id_}
         ${pucchNumberHarqAnPrbs}=        Get NRCELL Param from SCF   param=pucchNumberHarqAnPrbs   CellId=${cell_id_}
         ${actDynUlResAlloc}=             Get NRCELL Param from SCF   param=actDynUlResAlloc   CellId=${cell_id_}
         ${reqMinNumPuschPrb}=            Get NRCELL Param from SCF   param=reqMinNumPuschPrb   CellId=${cell_id_}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/actLongPucchResourceOpt
         ...                                             ${actLongPucchResourceOpt}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/pucchF1ResOccConf
         ...                                             ${pucchF1ResOccConf}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/actIncreasedFdmUsersPerSlot
         ...                                             ${actIncreasedFdmUsersPerSlot}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/pucchNumberHarqAnPrbs
         ...                                             ${pucchNumberHarqAnPrbs}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/actDynUlResAlloc(CB006878)
         ...                                             ${actDynUlResAlloc}
         dated log      ${msg_display}
         ${msg_display}=    StringTool.getHeaderLine    MRBTS-${MRBTS_ID}/NRBTS-${nrbts_id}/NRCELL-${cell_id_}/reqMinNumPuschPrb
         ...                                             ${reqMinNumPuschPrb}
         dated log      ${msg_display}
    END
    StringTool.printLineWithTitle     title=-
    return from Keyword

Check cellmappingtocsirspoolinggroup Assignment in Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         # Run Keyword if   '${contains_no_Syslogs}' == 'True'   dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure
         ...                                                                display cellmappingtocsirspoolinggroup in SysLog    syslog=${syslog}
         ...    ELSE                                dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

Check l1Subpool Assignment for CB012738 in Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         # Run Keyword if   '${contains_no_Syslogs}' == 'True'   dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure
         ...                                                                            Check Ull1Subpool Assignment CB012738 C    syslog=${syslog}
         ...    ELSE                                dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure
         ...                                                                            Check Dll1Subpool Assignment CB012738 C    syslog=${syslog}
         ...    ELSE                                dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure
         ...                                                                display totalStreamPrbs per l1PoolId in SysLog    syslog=${syslog}
         ...    ELSE                                dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

Check if BBRM ERR Assignment present in Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure   Check BBRM ERR Assignment
         ...                                                                                                                       syslog=${syslog}
         ...    ELSE                                           dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

Check if ESTATUS5G_NOTOK present in Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure   Check ESTATUS5G_NOTOK
         ...                                                                                                                       syslog=${syslog}
         ...    ELSE                                           dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure   Check GnbOamCellUpdateFailed
         ...                                                                                                                       syslog=${syslog}
         ...    ELSE                                           dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

Check if FaultID 6505 SSD Log Storage Overdraw present in Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure
         ...                                                   Check 6505 AASYSINFO_FS_OVERLOAD_IND_MSG    syslog=${syslog}
         ...    ELSE                                           dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

Check if FaultID IncorrectCellParameterSettingAI present in Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure
         ...                                                   Check IncorrectCellParameterSettingAI    syslog=${syslog}
         ...    ELSE                                           dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

Check MaxRlcRetransmission
    [Documentation]   Analyzing this kind of Syslog trace
    ...    Sending BearerErrorIndication due to MaxRlcRetransmission exceeded
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'BearerErrorIndication'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no BearerErrorIndication found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "BearerErrorIndication"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${bbrm_err}  tarf-lib.extract_BearerErrorIndication_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_err}
    run Keyword if    ${isEmpty}         log to console      no BearerErrorIndication found: ${bbrm_err}
    ${msg}=        Catenate   ${consTraceColor}no BearerErrorIndication found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    FOR    ${bbrm_err_elt}    IN    @{bbrm_err}
        BuiltIn.Log  ${syslog}: BearerErrorIndication found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}!
        ...  level=ERROR
        dated log    ${consTraceColorRed}BearerErrorIndication found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}${defColor}
    END
    [Return]        ${bbrm_err}

Check if MaxRlcRetransmission exceeded present in Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure
         ...                                                   Check MaxRlcRetransmission    syslog=${syslog}
         ...    ELSE                                           dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

Check ERR/.uplane/L2-PS
    [Documentation]   Analyzing this kind of Syslog trace
    ...    ERR/.uplane/L2-PS
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'ERR/.uplane/L2-PS'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no ERR/.uplane/L2-PS found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "ERR/.uplane/L2-PS"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${bbrm_err}  tarf-lib.extract_ERR_uplane_L2_PS_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_err}
    run Keyword if    ${isEmpty}         log to console      no ERR/.uplane/L2-PS found: ${bbrm_err}
    ${msg}=        Catenate   ${consTraceColor}no ERR/.uplane/L2-PS found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${TEST NAME}
    ${test_name}  set Variable if    '${status}'=='FAIL'    set variable    SUITE TEST
    ...                                                     set variable    ${TEST NAME[0:30]}
    ${index_err}=    Set Variable   ${0}
    FOR    ${bbrm_err_elt}    IN    @{bbrm_err}
        Exit For Loop If     ${index_err} > ${20}
        ${index_err}=    Evaluate    ${index_err} + ${1}
        Run Keyword If    ${index_err} == ${1} and '${W_ERR_L2PS_SYSLOG_ALLOWED}' == '1'
        ...                       BuiltIn.Log  ${test_name} ${syslog}: ERR/.uplane/L2-PS found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}!
        ...                                            level=ERROR
        Run Keyword If    ${index_err} == ${1} and '${W_ERR_L2PS_SYSLOG_ALLOWED}' == '0'
        ...                       BuiltIn.Log  ${test_name} ${syslog}: ERR/.uplane/L2-PS found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}!
        ...                                            level=ERROR
        dated log    ${consTraceColorRed}ERR/.uplane/L2-PS found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}${defColor}
        Run Keyword If   '${W_ERR_L2PS_SYSLOG_ALLOWED}'=='0'       Run Keyword And Continue On Failure
        ...                             Fail    msg=ERR/.uplane/L2-PS found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}
    END
    [Return]        ${bbrm_err}

Check if ERR/.uplane/L2-PS present in Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  Run Keyword And Continue On Failure
         ...                                                   Check ERR/.uplane/L2-PS     syslog=${syslog}
         ...    ELSE                                           dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

Check ERR/L2-PS
    [Documentation]   Analyzing this kind of Syslog trace
    ...    ERR/L2-PS
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'ERR/L2-PS'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no ERR/L2-PS found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "ERR/L2-PS"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${bbrm_err}  tarf-lib.extract_ERR_L2_PS_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_err}
    run Keyword if    ${isEmpty}         log to console      no ERR/L2-PS found: ${bbrm_err}
    ${msg}=        Catenate   ${consTraceColor}no ERR/L2-PS found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${TEST NAME}
    ${test_name}  set Variable if    '${status}'=='FAIL'    set variable    SUITE TEST
    ...                                                     set variable    ${TEST NAME[0:30]}
    ${index_err}=    Set Variable   ${0}
    FOR    ${bbrm_err_elt}    IN    @{bbrm_err}
        Exit For Loop If     ${index_err} > ${20}
        ${index_err}=    Evaluate    ${index_err} + ${1}
        Run Keyword If    ${index_err} == ${1} and '${W_ERR_L2PS_SYSLOG_ALLOWED}' == '1'
        ...                         BuiltIn.Log  ${test_name} ${syslog}: ERR/L2-PS found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}!
        ...                                            level=ERROR
        Run Keyword If    ${index_err} == ${1} and '${W_ERR_L2PS_SYSLOG_ALLOWED}' == '0'
        ...                         BuiltIn.Log  ${test_name} ${syslog}: ERR/L2-PS found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}!
        ...                                            level=ERROR
        dated log    ${consTraceColorRed}ERR/L2-PS found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}${defColor}
        Run Keyword If   '${W_ERR_L2PS_SYSLOG_ALLOWED}'=='0'       Run Keyword And Continue On Failure
        ...                             Fail    msg=ERR/L2-PS found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}
    END
    [Return]        ${bbrm_err}

Check if ERR/L2-PS present in Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  Run Keyword And Continue On Failure
         ...                                                   Check ERR/L2-PS     syslog=${syslog}
         ...    ELSE                                           dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

Check Resource Allocation Failed
    [Documentation]   Analyzing this kind of Syslog trace
    ...    resource allocation failed
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'resource allocation failed'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no resource allocation failed found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "resource allocation failed"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${bbrm_err}  tarf-lib.extract_resource_Allocation_Failed_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_err}
    run Keyword if    ${isEmpty}         log to console      no resource allocation failed found: ${bbrm_err}
    ${msg}=        Catenate   ${consTraceColor}no resource allocation failed found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${TEST NAME}
    ${test_name}  set Variable if    '${status}'=='FAIL'    set variable    SUITE TEST
    ...                                                     set variable    ${TEST NAME[0:30]}
    ${index_err}=    Set Variable   ${0}
    FOR    ${bbrm_err_elt}    IN    @{bbrm_err}
        Exit For Loop If     ${index_err} > ${20}
        ${index_err}=    Evaluate    ${index_err} + ${1}
        Run Keyword If    ${index_err} == ${1}
        ...  BuiltIn.Log  ${test_name} ${syslog}: resource allocation failed found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}!
        ...               level=WARN  console=True
        dated log    ${consTraceColorRed}resource allocation failed found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}${defColor}
    END
    [Return]        ${bbrm_err}

Check if resource allocation failed present in Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  Run Keyword And Continue On Failure
         ...                                                   Check Resource Allocation Failed     syslog=${syslog}
         ...    ELSE                                           dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

Check ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL
    [Documentation]   Analyzing this kind of Syslog trace
    ...    ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${bbrm_err}  tarf-lib.extract_ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_err}
    run Keyword if    ${isEmpty}         log to console      no ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL found: ${bbrm_err}
    ${msg}=        Catenate   ${consTraceColor}no ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${TEST NAME}
    ${test_name}  set Variable if    '${status}'=='FAIL'    set variable    SUITE TEST
    ...                                                     set variable    ${TEST NAME[0:30]}
    ${index_err}=    Set Variable   ${0}
    FOR    ${bbrm_err_elt}    IN    @{bbrm_err}
        Exit For Loop If     ${index_err} > ${20}
        ${index_err}=    Evaluate    ${index_err} + ${1}
        Run Keyword If    ${index_err} == ${1}
        ...  BuiltIn.Log  ${test_name} ${syslog}: ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}!
        ...               level=WARN  console=True
        dated log    ${consTraceColorRed}ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}${defColor}
    END
    [Return]        ${bbrm_err}

Check if ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL present in Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  Run Keyword And Continue On Failure
         ...                                                   Check ENDSSULSUBCARRIERRESOURCEALLOCATIONFAIL     syslog=${syslog}
         ...    ELSE                                           dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

Check ENDSSDLRESOURCEALLOCATIONFAIL
    [Documentation]   Analyzing this kind of Syslog trace
    ...    ENDSSDLRESOURCEALLOCATIONFAIL
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'ENDSSDLCELLRESOURCEAREAALLOCATIONFAIL'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no ENDSSDLCELLRESOURCEAREAALLOCATIONFAIL found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "ENDSSDLCELLRESOURCEAREAALLOCATIONFAIL"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${bbrm_err}  tarf-lib.extract_ENDSSDLRESOURCEALLOCATIONFAIL_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_err}
    run Keyword if    ${isEmpty}         log to console      no ENDSSDLCELLRESOURCEAREAALLOCATIONFAIL found: ${bbrm_err}
    ${msg}=        Catenate   ${consTraceColor}no ENDSSDLCELLRESOURCEAREAALLOCATIONFAIL found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${TEST NAME}
    ${test_name}  set Variable if    '${status}'=='FAIL'    set variable    SUITE TEST
    ...                                                     set variable    ${TEST NAME[0:30]}
    ${index_err}=    Set Variable   ${0}
    FOR    ${bbrm_err_elt}    IN    @{bbrm_err}
        Exit For Loop If     ${index_err} > ${20}
        ${index_err}=    Evaluate    ${index_err} + ${1}
        Run Keyword If    ${index_err} == ${1}
        ...  BuiltIn.Log  ${test_name} ${syslog}: ENDSSDLCELLRESOURCEAREAALLOCATIONFAIL found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}!
        ...               level=WARN  console=True
        dated log    ${consTraceColorRed}ENDSSDLCELLRESOURCEAREAALLOCATIONFAIL found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}${defColor}
    END
    [Return]        ${bbrm_err}

Check if ENDSSDLRESOURCEALLOCATIONFAIL present in Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  Run Keyword And Continue On Failure
         ...                                                   Check ENDSSDLRESOURCEALLOCATIONFAIL     syslog=${syslog}
         ...    ELSE                                           dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

Extract L2-PS/src/sgnl/psCell/CellSetupLogger
    [Documentation]   Analyzing this kind of Syslog trace
    ...    INF/.uplane/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp:
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'INF/.uplane/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp:'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no L2-PS/src/sgnl/psCell/CellSetupLogger found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "INF/.uplane/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp:"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${bbrm_err}  tarf-lib.extract_L2_PS_CellSetupLogger_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_err}
    run Keyword if    ${isEmpty}         log to console      no INF/.uplane/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp: found: ${bbrm_err}
    ${msg}=        Catenate   ${consTraceColor}no INF/.uplane/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp: found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${text}=    Catenate      Extract L2-PS/src/sgnl/psCell/CellSetupLogger FROM ${syslog} :
    Log Test results      ${text}
    ${text}=    Catenate      =============================================================
    Log Test results      ${text}
    FOR    ${bbrm_err_elt}    IN    @{bbrm_err}
        ${text}=    Catenate     line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}
        Log Test results      ${text}
    END
    [Return]        ${bbrm_err}

Extract INF/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp
    [Documentation]   Analyzing this kind of Syslog trace
    ...    INF/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp:
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'INF/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp:'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no INF/L2-PS/src/sgnl/psCell/CellSetupLogger found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "INF/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp:"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${bbrm_err}  tarf-lib.extract_INF_L2_PS_CellSetupLogger_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_err}
    run Keyword if    ${isEmpty}         log to console      no INF/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp: found: ${bbrm_err}
    ${msg}=        Catenate   ${consTraceColor}no INF/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp: found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${msg}=        Catenate   ${consTraceColor}INF/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp: found${defColor}
    dated log     ${msg}
    ${text}=    Catenate      Extract INF/L2-PS/src/sgnl/psCell/CellSetupLogger FROM ${syslog} :
    Log Test results      ${text}
    ${text}=    Catenate      =============================================================
    Log Test results      ${text}
    FOR    ${bbrm_err_elt}    IN    @{bbrm_err}
        ${text}=    Catenate     line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}
        Log Test results      ${text}
    END
    [Return]        ${bbrm_err}

Extract L2-PS/src/sgnl/psCell/CellSetupLogger from Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         Run Keyword if   '${contains_no_Syslogs}' == 'False'    robot_extension.Run Keyword And Warn On Failure
         ...                                                               Extract L2-PS/src/sgnl/psCell/CellSetupLogger      syslog=${syslog}
         ...    ELSE                                             dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
         Run Keyword if   '${contains_no_Syslogs}' == 'False'    robot_extension.Run Keyword And Warn On Failure
         ...                                                               Extract INF/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp    syslog=${syslog}
         ...    ELSE                                             dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

Extract [CSIRS] pattern
    [Documentation]   Analyzing this kind of Syslog trace
    ...    [CSIRS]
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     '[CSIRS]'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no [CSIRS] found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "\\[CSIRS\\]"
    # dated log     output=${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${bbrm_err}  extract_CSIRS_pattern_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_err}
    run Keyword if    ${isEmpty}         log to console      no [CSIRS] found: ${bbrm_err}
    ${msg}=        Catenate   ${consTraceColor}no [CSIRS] found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${msg}=        Catenate   ${consTraceColor}CSIRS pattern found${defColor}
    dated log     ${msg}
    ${text}=    Catenate      Extract [CSIRS] FROM ${syslog} :
    Log Test CSIRS results      ${text}
    ${text}=    Catenate      =============================================================
    Log Test CSIRS results      ${text}
    FOR    ${bbrm_err_elt}    IN    @{bbrm_err}
        ${text}=    Catenate     line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}
        Log Test CSIRS results      ${text}
    END
    [Return]        ${bbrm_err}

Extract [CSIRS] from Syslogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sort | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         Run Keyword if   '${contains_no_Syslogs}' == 'False'    robot_extension.Run Keyword And Warn On Failure
         ...                                                               Extract [CSIRS] pattern      syslog=${syslog}
         ...    ELSE                                             dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END

Get filtered message from syslog
    [Arguments]     ${syslog}       ${texttofilter}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${syslog} | grep ${texttofilter}
    # should not be empty                  ${output}
    [Return]        ${output}

Get filtered message from syslog with extented regular expression
    [Arguments]     ${syslog}       ${texttofilter}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${syslog} | grep -E ${texttofilter}
    # should not be empty                  ${output}
    [Return]        ${output}

Check Max Resource Set Configured
    [Arguments]    ${ttiLog}     ${csiRsFile}    ${maxCsiRsNumber}    ${Type}=TtiTrace
    ${status}   csirs_checker.checkRefSignal   ${ttiLog}   ${csiRsFile}   ${maxCsiRsNumber}
    declare Results in Test Results List      Type=${Type}: Check Max Resource Set Configured
    ...                                       Result=${status}
    run keyword if     '${status}' == 'False'  run keywords
    ...  Append To File   ${resultFile}    \nWRONG Max Resource Set Configured for calls\n
    ...  AND  Run Keyword And Continue On Failure   Fail   WRONG Max Resource Set Configured for calls
    ...  ELSE   Append To File   ${resultFile}   \nCheck Max Resource Set Configured for calls --> PASSED\n

Check cellcsirs Assignement
    [Arguments]     ${cellcsirs}     ${framestructure}=5GC001208     ${step}=${None}
    Append To File   ${csiRsFile}    \n\n***********************\nCell Specific Config\n***********************\n
    ${type}=    set variable if   '${step}' == '${None}'   SYSLOG     SYSLOG [${step}]
    ${CsiRsGrp}=     Set Variable     3
    Set test Variable     ${CsiRsGrp}
    ${res1}  Evaluate  len(set([a['csirsPoolingGroupId'] for a in ${sorted_csirsGroups}])) == ${CsiRsGrp}
    # case 4 Cells (ASOE) => only 3 cellCsiRsGrp
    # ${cellCsiRsGrp}=      evaluate     ${CsiRsGrp} + ${1}
    ${num_of_cells}=    Get Cell Number
    ${cellCsiRsGrp}=      Set Variable     ${CsiRsGrp}
    # ${res2}   evaluate   len(${cellcsirs}) == ${cellCsiRsGrp}
    ${res2}   evaluate   len(${cellcsirs}) == ${num_of_cells}
    ${Result}=    Evaluate     ${res1} and ${res2}
    declare Results in Test Results List     Type=${type} : Check Cell CSI-RS allocation Info from CellSetup
    ...                                      Result=${Result}
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # at this step, all cells should be configured with actCsirsMultiplexing (checked before...)
    ${actCsirsMultiplexing}	 scf.get_value_from_scf   p_name=actCsirsMultiplexing
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${actInfTddFrameMuting}	 scf.get_value_from_scf   p_name=actInfTddFrameMuting
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${actExplicitCsirsPoolSolution}=    Get NRBTS Param from SCF   param_name=actExplicitCsirsPoolSolution
    ${actTddCsirsAllocOptimization}=    Set Variable If   '${act9836TddCsirsAllocOptimization}'=='true'    ${True}    ${False}
    @{maxCsiRsNumber}=                      Create List
    @{csirsNbWithinReportPeriod_Set1}=      Create List
    @{csiReportPeriodicity}=            Create List
    @{nrCellIdList}=         Create List
    # beware that maxCsirsNumber must the same for all cells , at least , for cells mapped on same csirsPoolingGrp (case ASOE 4 Cells for ex)
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
         ${cell_grp_id}    Evaluate    ${cell_id} + ${0}
         ${cell_id_}       Evaluate    ${cell_id} + ${1}
         ${cell_id_string}    Convert to String     ${cell_id_}
         Append To List     ${nrCellIdList}    ${cell_id_string}
         ${periodicCsiAcquisitionList_params_list_result}=    Get periodicCsiAcquisition Parameters From gNB    CellId=${cell_id_}
         Append To List   ${csirsNbWithinReportPeriod_Set1}    ${periodicCsiAcquisitionList_params_list_result['csirsNumberWithinReportPeriod_Set1']}
         Append To List   ${maxCsiRsNumber}    ${periodicCsiAcquisitionList_params_list_result['maxCsirsNumber']}
         Append To List   ${csiReportPeriodicity}    ${periodicCsiAcquisitionList_params_list_result['csiReportPeriodicity']}
    END
    set test variable     ${maxCsiRsNumber}
    # ${expectedCellCsiRs}   csirs_checker.createCellCsiRs_9836   ${frameStructure}   ${actCsirsMultiplexing}  ${actExplicitCsirsPoolSolution}
    ${expectedCellCsiRs}   csirs_checker.createCellCsiRs_9836_v3_1  ${csiRsFile}    ${frameStructure}   ${actCsirsMultiplexing}
    ...     ${actExplicitCsirsPoolSolution}    ${csiReportPeriodicity}   ${csirsNbWithinReportPeriod_Set1}    ${maxCsiRsNumber}
    ...     ${sorted_csirsGroups}    ${nrCellIdList}   ${actTddCsirsAllocOptimization}   ${actInfTddFrameMuting}
    Dated log   expectedCellCsiRs=${expectedCellCsiRs}
    ${status}  run keyword and return status   Lists Should Be Equal     ${cellcsirs}        ${expectedCellCsiRs}
    declare Results in Test Results List     Type=${type} : Check Cell Specific CSI-RS allocation
    ...                                      Result=${status}
    Run Keyword If    '${step}' != '${None}'     Append To File      ${csiRsFile}     \nSTEP: ${step}\n
    csirs_checker.writeCsiRsConfigCellSpe   ${csiRsFile}      ${expectedCellCsiRs}   ${sorted_csirsGroups}
    Run Keyword If    ${Result} and ${status}     Append To File      ${resultFile}     \nCheck Cell Specific CSI-RS Allocation ---> PASSED\n
    ...     ELSE                                  Append To File      ${resultFile}     \nWRONG Cell Specific CSI-RS Allocation !!!\n
    Should be True     ${status} and ${Result}    msg=Check cellcsirs Assignement FAILED !!!
    [return]      ${status}

Check TrsCsiRs Assignement
    [Arguments]     ${trscsirs}     ${framestructure}=5GC001208    ${step}=${None}
    ${type}=    set variable if   '${step}' == '${None}'   SYSLOG     SYSLOG [${step}]
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # at this step, all cells should be configured with actCsirsMultiplexing (checked before...)
    ${actCsirsMultiplexing}	 scf.get_value_from_scf   p_name=actCsirsMultiplexing
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${actInfTddFrameMuting}	 scf.get_value_from_scf   p_name=actInfTddFrameMuting
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${numOfSubSectors}=       scf.get_value_from_scf   p_name=numOfSubSectors
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${actExplicitCsirsPoolSolution}=    Get NRBTS Param from SCF   param_name=actExplicitCsirsPoolSolution
    ${actBbPoolTddFr1}=                 Get NRBTS Param from SCF   param_name=actBbPoolTddFr1
    ${actTddCsirsAllocOptimization}=    Set Variable If   '${act9836TddCsirsAllocOptimization}'=='true'    ${True}    ${False}
    ${num_of_cells}=    Get Cell Number
    @{nrCellIdList}=    Create List
    @{beamCfg}=         Create List
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
         ${cell_grp_id}    Evaluate    ${cell_id} + ${0}
         ${cell_id_}       Evaluate    ${cell_id} + ${1}
         ${cell_id_string}    Convert to String     ${cell_id_}
         Append To List     ${nrCellIdList}    ${cell_id_string}
         ${numberOfTransmittedSsBlocks}=    Get NRCELLGRP Param from SCF   param_name=numberOfTransmittedSsBlocks   CellId=${cellId}
         Append To List     ${beamCfg}    ${numberOfTransmittedSsBlocks}
    END
    ${expectedTrsCsiRs}   trs_checker.createTrsCsiRs   ${frameStructure}   @{beamCfg}[0]   ${actBbPoolTddFr1}
    ...     ${actExplicitCsirsPoolSolution}    ${actInfTddFrameMuting}    ${actTddCsirsAllocOptimization}
    ...     ${numOfSubSectors}
    Dated log   expectedTrsCsiRs=${expectedTrsCsiRs}
    ${res1}  Evaluate   len(set([a['csirsPoolingGroupId'] for a in ${sorted_csirsGroups}])) == len(${expectedtrsCsiRs})
    ${res2}  Evaluate   len(${trscsirs}) == len(${expectedTrsCsiRs})
    ${Result}=    Evaluate     ${res1} and ${res2}
    declare Results in Test Results List     Type=${type} : Check Trs CSI-RS allocation Info from CellSetup
    ...                                      Result=${Result}
    ${status}  run keyword and return status   Lists Should Be Equal     ${trscsirs}        ${expectedTrsCsiRs}
    declare Results in Test Results List     Type=${type} : Check Trs CSI-RS allocation
    ...                                      Result=${status}
    trs_checker.writeCsiRsConfigTrs   ${csiRsFile}      ${expectedTrsCsiRs}
    Run Keyword If    ${Result} and ${status}     Append To File      ${resultFile}     \nCheck TRS CSI-RS Allocation ---> PASSED\n
    ...     ELSE                                  Append To File      ${resultFile}     \nWRONG TRS CSI-RS Allocation !!!\n
    Should be True    ${Result} and ${status}     msg=Check TrsCsiRs Assignement FAILED !!!
    [return]      ${res1}    ${res2}    ${status}

Check TrsCsiRs Assignement per SSB
    [Arguments]      ${sorted_trscsirs_ssb_slotoffset}   ${sorted_csirsGroups}    ${cellId}=1   ${framestructure}=5GC001208    ${step}=${None}
    ${type}=    set variable if   '${step}' == '${None}'   SYSLOG     SYSLOG [${step}]
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${numberOfTransmittedSsBlocks}=    Get NRCELLGRP Param from SCF   param_name=numberOfTransmittedSsBlocks   CellId=${cellId}
    ${ssb_block}=    Set Variable If    '${numberOfTransmittedSsBlocks}' == '8 beams'      SSBLOCKS_8
    ...                                 '${numberOfTransmittedSsBlocks}' == '6 beams'      SSBLOCKS_6
    ...                                 '${numberOfTransmittedSsBlocks}' == '4 beams'      SSBLOCKS_4
    ...                                 '${numberOfTransmittedSsBlocks}' == '2 beams'      SSBLOCKS_2     SSBLOCKS_6
    ${sorted_trscsirs_slotoffset_v3}   extract_trscsirs_with_ssb    ${sorted_trscsirs_ssb_slotoffset}  ${sorted_csirsGroups}
    ...                                                             lcrId=${cellId}  numberOfTransmittedSsBlocks=${ssb_block}
    dated log    sorted_trscsirs_slotoffset_ssb_v3 = ${sorted_trscsirs_slotoffset_v3}
    ${actCsirsMultiplexing}	 scf.get_value_from_scf   p_name=actCsirsMultiplexing
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellId}
    ${actInfTddFrameMuting}	 scf.get_value_from_scf   p_name=actInfTddFrameMuting
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellId}
    ${numOfSubSectors}=       scf.get_value_from_scf   p_name=numOfSubSectors
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellId}
    ${actExplicitCsirsPoolSolution}=    Get NRBTS Param from SCF   param_name=actExplicitCsirsPoolSolution
    ${actBbPoolTddFr1}=                 Get NRBTS Param from SCF   param_name=actBbPoolTddFr1
    ${actTddCsirsAllocOptimization}=    Set Variable If   '${act9836TddCsirsAllocOptimization}'=='true'    ${True}    ${False}
    ${numberOfTransmittedSsBlocks}=     Get NRCELLGRP Param from SCF   param_name=numberOfTransmittedSsBlocks   CellId=${cellId}
    ${expectedTrsCsiRs}   trs_checker.createTrsCsiRs   ${frameStructure}   ${numberOfTransmittedSsBlocks}   ${actBbPoolTddFr1}
    ...     ${actExplicitCsirsPoolSolution}    ${actInfTddFrameMuting}    ${actTddCsirsAllocOptimization}
    ...     ${numOfSubSectors}
    dated log     expectedTrsCsiRs=${expectedTrsCsiRs}
    ${sorted_expected_trscsirs_slotoffset}=    trs_checker.filter_trs_offset   ${expectedTrsCsiRs}   ${sorted_csirsGroups}  lcrId=${cellId}
    ${status}  run keyword and return status   Lists Should Be Equal   ${sorted_trscsirs_slotoffset_v3}    ${sorted_expected_trscsirs_slotoffset}[0]
    dated log     status=${status}
    ${text}   Catenate   Check Trs CSI-RS allocation Info from CellSetup Cell${cellId} with
    ...                   numberOfTransmittedSsBlocks=${numberOfTransmittedSsBlocks}
    declare Results in Test Results List     Type=${type} : ${text}
    ...                                      Result=${status}
    Should be True    ${status}     msg=Check TrsCsiRs Assignement Cell${cellId} FAILED !!!
    [return]         ${status}

Check cellcsirs Assignement version1
    [Arguments]     ${cellcsirs}     ${framestructure}=5GC001208
    ${json_string}=    OperatingSystem.Get File    ${CURDIR}/../../cellcsirs.json
    ${parsed_json}=    Evaluate    json.loads('''${json_string}''')    json
    ${filtered_json}        Evaluate
    ...     [sub['csirsPoolingGroups'] for sub in ${parsed_json} if sub['frameStructure'] == '${framestructure}'][0]
     ${sorted_json}        Evaluate
    ...     sorted(${filtered_json}, key=lambda p: p['csirsPoolingGroupId'])
    Dated Log New Line    [Check cellcsirs Assignement] cellcsirs=${cellcsirs}
    Dated Log New Line    [Check cellcsirs Assignement] sorted_json=${sorted_json}
    Lists Should Be Equal     ${cellcsirs}        ${sorted_json}

Extract l2::ps::cnfg::AddressDistributionReq_t from Syslog
    [Arguments]       ${sysLogsDir}=/tmp/btslog2
    StringTool.printLineWithTitle  title= Display bbPoolInfos from l2::ps::cnfg::AddressDistributionReq_t SysLogs
    ${commandToRun}     Catenate     cd ${sysLogsDir}; find . -name "*.LOG" -type f | sed -e 's/^\\.\\///g'
    ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
    ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
    Sort List          ${sysLog_files}
    FOR    ${syslog}    IN    @{sysLog_files}
         dated log    [Extract l2::ps::cnfg::AddressDistributionReq_t from Syslog] Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${syslog_wo_ext}=     Remove String     ${syslog}     .LOG
         ${output_AddressDistributionReq_t}   Get filtered message from syslog   ${sysLogsDir}/${syslog}  itf::l2::ps::cnfg::AddressDistributionReq:
         ${status}    Run Keyword And Return Status    Should Not Be Empty    ${output_AddressDistributionReq_t}
         exit for loop if    ${status}
    END
    ${bbPoolInfos}     extract_bbPoolInfos_from_syslog    ${output_AddressDistributionReq_t}
    ...                                                   file=${testCaseDir}/l2ps-AddressDistributionReq-${syslog_wo_ext}
    StringTool.printLineWithTitle  title=-
    # Log To Console      ${bbPoolInfos}
    [Return]       ${bbPoolInfos}

Extract l2::ps::cell::CellSetupReq_t and CellSetupResp_t from Syslog
    [Arguments]     ${sysLogsDir}=/tmp/btslog2    ${w_trace}=${False}    ${testCaseDir}=${EMPTY}
    ${commandToRun}     Catenate     cd ${sysLogsDir}; find . -name "*.LOG" -type f | sed -e 's/^\\.\\///g'
    ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
    ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
    Sort List          ${sysLog_files}
    ${output_CellSetupReq}=          Set Variable     ${EMPTY}
    ${output_CellGroupSetupReq}=     Set Variable     ${EMPTY}
    ${output_cellSetupRsp}=          Set Variable     ${EMPTY}
    ${csirsGroups}=                  Create List
    ${cellcsirs}=                    Create List
    ${uecsirs}=                      Create List
    FOR    ${syslog}    IN    @{sysLog_files}
         dated log    [Extract CellSetupReq_t and CellSetupResp_t from Syslog] Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${output_CellSetupReq_1}         Get filtered message from syslog with extented regular expression        ${sysLogsDir}/${syslog}
         ...                'l2::ps::cell::CellSetupReq:|l2::ps::cell::CellSetupReq_t':
         ${output_CellGroupSetupReq_1}    Get filtered message from syslog        ${sysLogsDir}/${syslog}     l2::ps::cell::CellGroupSetupReq:
         ${output_cellSetupRsp_1}         Get filtered message from syslog with extented regular expression        ${sysLogsDir}/${syslog}
         ...                'l2::ps::cell::CellSetupResp:|l2::ps::cell::CellSetupResp_t:'
         ${count_cells}=     Set Variable     ${0}
         ${nrCellIdentity}=    Get nrCellIdentity From coam ADMIN    cell_grp=0    cell_nr=1
         Dated Log      From COAM ADMIN nrCellIdentity=${nrCellIdentity}
         ${pattern}=     Catenate      "nrCellIdentity":${nrCellIdentity}
         ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellSetupReq_1}''')    re
         Dated Log      ${result} present in ${syslog}
         ${count}=      Get length  ${result}
         IF    ${count} == ${0}
             ${pattern}=     Catenate      "nrCellIdentity":16385
             ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellSetupReq_1}''')    re
             Dated Log      ${result} present in ${syslog}
             ${count}=      Get length  ${result}
         END
         # Dated Log      count=${count}
         ${count_cells}=     Evaluate     ${count_cells} + ${count}
         ${pattern}=     Catenate      "nrCellIdentity":16386
         ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellSetupReq_1}''')    re
         Dated Log      ${result} present in ${syslog}
         ${count}=      Get length  ${result}
         IF    ${count} == ${0}
             ${pattern}=     Catenate      "nrCellIdentity":32770
             ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellSetupReq_1}''')    re
             Dated Log      ${result} present in ${syslog}
             ${count}=      Get length  ${result}
         END
         ${count_cells}=     Evaluate     ${count_cells} + ${count}
         ${pattern}=     Catenate      "nrCellIdentity":16387
         ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellSetupReq_1}''')    re
         Dated Log      ${result} present in ${syslog}
         ${count}=      Get length  ${result}
        IF    ${count} == ${0}
             ${pattern}=     Catenate      "nrCellIdentity":32771
             ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellSetupReq_1}''')    re
             Dated Log      ${result} present in ${syslog}
             ${count}=      Get length  ${result}
         END
         ${count_cells}=     Evaluate     ${count_cells} + ${count}
         ${pattern}=     Catenate      "nrCellIdentity":16388
         ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellSetupReq_1}''')    re
         Dated Log      ${result} present in ${syslog}
         ${count}=       Get length  ${result}
         IF    ${count} == ${0}
             ${pattern}=     Catenate      "nrCellIdentity":32772
             ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellSetupReq_1}''')    re
             Dated Log      ${result} present in ${syslog}
             ${count}=      Get length  ${result}
         END
         ${count_cells}=     Evaluate     ${count_cells} + ${count}
         ${pattern}=     Catenate      "nrCellIdentity":16389
         ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellSetupReq_1}''')    re
         Dated Log      ${result} present in ${syslog}
         ${count}=       Get length  ${result}
         IF    ${count} == ${0}
             ${pattern}=     Catenate      "nrCellIdentity":32773
             ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellSetupReq_1}''')    re
             Dated Log      ${result} present in ${syslog}
             ${count}=      Get length  ${result}
         END
         ${count_cells}=     Evaluate     ${count_cells} + ${count}
         ${pattern}=     Catenate      "nrCellIdentity":16390
         ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellSetupReq_1}''')    re
         Dated Log      ${result} present in ${syslog}
         ${count}=       Get length  ${result}
         IF    ${count} == ${0}
             ${pattern}=     Catenate      "nrCellIdentity":32774
             ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellSetupReq_1}''')    re
             Dated Log      ${result} present in ${syslog}
             ${count}=      Get length  ${result}
         END
         ${count_cells}=     Evaluate     ${count_cells} + ${count}
         Dated Log   Nb Of Cells Found : ${count_cells}

         ${pattern}=     Catenate      "nrCellGrpId":0
         ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellGroupSetupReq_1}''')    re
         Dated Log      output_CellGroupSetupReq_1: ${result} present in ${syslog}
         ${pattern}=     Catenate      "nrCellGrpId":1
         ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellGroupSetupReq_1}''')    re
         Dated Log      output_CellGroupSetupReq_1: ${result} present in ${syslog}
         ${pattern}=     Catenate      "nrCellGrpId":2
         ${result}       Evaluate   re.findall(r'(${pattern})','''${output_CellGroupSetupReq_1}''')    re
         Dated Log      output_CellGroupSetupReq_1: ${result} present in ${syslog}

         ${status}    Run Keyword And Return Status    Should Not Be Empty    ${output_cellSetupRsp_1}
         ${output_cellSetupRsp}=     set Variable If    ${status}    ${output_cellSetupRsp_1}
         ...                                                         ${output_cellSetupRsp}
         ${status}    Run Keyword And Return Status    Should Not Be Empty    ${output_CellSetupReq_1}
         ${output_CellSetupReq}=     set Variable If    ${status}    ${output_CellSetupReq_1}
         ...                                                         ${output_CellSetupReq}
         ${status}    Run Keyword And Return Status    Should Not Be Empty    ${output_CellGroupSetupReq_1}
         ${output_CellGroupSetupReq}=     set Variable If    ${status}    ${output_CellGroupSetupReq_1}
         ...                                                              ${output_CellGroupSetupReq}
         ${syslog_wo_ext}=     Remove String     ${syslog}     .LOG
         ${status}    Run Keyword And Return Status    Should Not Be Empty    ${output_CellSetupReq}
         continue for loop If     not ${status}
         run Keyword If  ${w_trace}   dated log   [Extract l2::ps::cell::CellSetupReq_t and CellSetupResp_t from Syslog]
         ${nrCellGroups}   tarf-lib.extract_nrCellGrpId_from_syslog     ${output_CellSetupReq}
         ...                                                                file=${testCaseDir}/l2ps-cellsetup-${syslog_wo_ext}
         dated log     [ INFO ] nrCellGroups=${nrCellGroups}
         ${syslog_wo_ext}=     Remove String     ${syslog}     .LOG
         run Keyword If  ${w_trace}   dated log     [Extract l2::ps::cell::CellSetupReq_t and CellSetupResp_t from Syslog] csirsGroups=${csirsGroups}
         ${status}    ${csirsGroupsUpdated}   Run Keyword And Ignore Error   tarf-lib.extract_csirsPoolingGroupId_from_syslog
         ...                                                         syslogextract=${output_CellSetupReq}
         ...                                                         csirsgroups=${csirsGroups}
         ...                                                         file=${testCaseDir}/l2ps-cellsetup-${syslog_wo_ext}
         Run Keyword If    '${status}'=='PASS'    dated log        [ INFO ] csirsGroups=${csirsGroupsUpdated}
         ${status}      ${cellcsirs}      Run Keyword And Ignore Error     tarf-lib.extract_cellcsirs_from_syslog_cell
         ...                                                                ${output_cellSetupRsp}    ${csirsGroupsUpdated}  ${cellcsirs}
         ...                                                                ${testCaseDir}/l2ps-cellSetupRsp-${syslog_wo_ext}
         Run Keyword If    '${status}'=='PASS'    dated log        [ INFO ] cellcsirs_slots_offset=${cellcsirs}
         ${status}    ${uecsirs}        Run Keyword And Ignore Error    tarf-lib.extract_uecsirs_from_syslog
         ...                                                             ${output_cellSetupRsp}    ${csirsGroupsUpdated}   ${uecsirs}
         ...                                                             ${testCaseDir}/l2ps-cellSetupRsp-${syslog}
         # Run Keyword If    '${status}'=='PASS'    dated log        [ INFO ] uecsirs=${uecsirs}
    END

Extract egate_command
    [Documentation]   Analyzing this kind of egate trace
    ...    [session 1]: sim_log_set
    [Arguments]     ${dir}=${EMPTY}     ${egate_console}=egate_console.log

    ${commandToRun}     Catenate
    ...     cat ${dir}/${egate_console} | grep
    ...     '\\[session'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no [session found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${egate_console} | grep "\\[session"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${egate_cmd}  nps_trf_tools.extract_session_from_egateconsole   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${egate_cmd}
    run Keyword if    ${isEmpty}         log to console      no [session found: ${egate_cmd}
    ${msg}=        Catenate   ${consTraceColor}no [session found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${text}=    Catenate      egate_command FROM ${dir}/${egate_console} :
    Log egate command results      ${text}
    ${text}=    Catenate      =============================================================
    Log egate command results      ${text}
    FOR    ${egate_cmd_elt}    IN    @{egate_cmd}
        # ${text}=    Catenate     ${egate_cmd_elt}
        Log egate command results      ${egate_cmd_elt}
    END
    # [Return]        ${egate_cmd}

Display Bbrm configuration from Syslogs
   [Arguments]    ${btslog_dir}=/tmp/btslog2
   StringTool.printLineWithTitle  title= Display Bbrm configuration from SysLogs
   ${commandToRun}     Catenate     cd ${btslog_dir}; find . -name "*.LOG" -type f | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure   Display Bbrm configuration
         ...                                                                                                                  dir=${btslog_dir}
         ...                                                                                                                  syslog=${syslog}
         ...    ELSE                                           dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END
   StringTool.printLineWithTitle  title=-

Display SLOTTYPE configuration from Syslogs
   StringTool.printLineWithTitle  title= Display SLOTTYPE configuration from SysLogs
   ${commandToRun}     Catenate     cd /tmp/btslog2; find . -name "*.LOG" -type f | sed -e 's/^\\.\\///g'
   ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
   ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
   FOR    ${syslog}    IN    @{sysLog_files}
         dated log    Computing syslog File ${consTraceColor}${syslog}${defColor}...
         ${contains_no_Syslogs}=     Run Keyword And Return Status       Should Not Contain     ${syslog}     ${EMPTY}
         # ${contains_no_Syslogs}==True   => Syslog are not present !!!
         Run Keyword if   '${contains_no_Syslogs}' == 'False'  robot_extension.Run Keyword And Warn On Failure   Display SLOTTYPE configuration
         ...                                                                                                                  syslog=${syslog}
         ...    ELSE                                           dated log    ${consTraceColorRed}syslog are not present !!!${defColor}
   END
   StringTool.printLineWithTitle  title=-


Log dictionary
    [Documentation]  log key/value pairs from dictionary to the console
    [Arguments]  ${mydict}    ${msg}=-
    ${items}     Get Dictionary Items   ${mydict}   sort_keys=False
    StringTool.printLineWithTitle     title=${msg}
    FOR   ${key}    ${value}   IN   @{items}
        ${msg_display}=    StringTool.getHeaderLine    ${key}:   ${value}
        dated log     ${msg_display}
    END
    StringTool.printLineWithTitle     title=-

Update PRB Blanking NIDD param
    [Arguments]    ${dict_cells}
    ${NbOfCells}               get length        ${dict_cells}
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    @{OAMParam_modiflist}    Create List
    ${kw_setOnLine_ListParam}=  Set Variable If   '${W_OnlineChange_deltaComm}'=='1'    Set_NIDD_OnlineChange_ListParam
    ...                                                                                 Set_NIDD_modification_ListParam
    ${KwOnlineParamChange}=      Set Variable If  '${W_OnlineChange_deltaComm}'=='1'    OnlineParamChange
    ...                                                                                 Update gNB OAM List Param
    scf.load_scf	 ${current_scf_fullname}
    @{OAMParam_modiflist}    Create List
    FOR   ${index_cell}   IN RANGE    ${NbOfCells}
        # Exit For Loop If     ${index_cell} > ${2}
        ${index_cell_1}=    Evaluate    ${index_cell} + ${1}
        ${p_name}    set Variable    nbrOfBlankedPRBsLowEdgeDL
        ${val_e}    Get From Dictionary    ${dict_cells[${index_cell}]}    nbrOfBlankedPRBsLowEdgeDL
        ${dist_name}     set Variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${index_cell_1}
        ${val}	 scf.get_value_from_scf   p_name=${p_name}
         ...                              dist_name=${dist_name}
         # continue for loop if  '${val}'=='${val_e}'
         ${val_to_update}=   set variable if   '${val.lower()}'!='${val_e}'     True
         ...                                                                    False
         ${OAMParam_modiflist}=  Run Keyword if   '${val_to_update}'=='True'    ${kw_setOnLine_ListParam}      ${p_name}
         ...                                                                                                   ${val_e}
         ...                                                                                                   ${dist_name}
         ...                                                                                                   ${OAMParam_modiflist}
         ...   ELSE              set variable   ${OAMParam_modiflist}
         Run Keyword if   '${val_to_update}'=='True'               Dated log    ${p_name} Updated in Scf
         ${p_name}    set Variable    nbrOfBlankedPRBsLowEdgeUL
         ${val_e}    Get From Dictionary    ${dict_cells[${index_cell}]}    nbrOfBlankedPRBsLowEdgeUL
         ${dist_name}     set Variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${index_cell_1}
         ${val}	 scf.get_value_from_scf   p_name=${p_name}
         ...                              dist_name=${dist_name}
         # continue for loop if  '${val}'=='${val_e}'
         ${val_to_update}=   set variable if   '${val.lower()}'!='${val_e}'     True
         ...                                                                    False
         ${OAMParam_modiflist}=  Run Keyword if   '${val_to_update}'=='True'    ${kw_setOnLine_ListParam}      ${p_name}
         ...                                                                                                   ${val_e}
         ...                                                                                                   ${dist_name}
         ...                                                                                                   ${OAMParam_modiflist}
         ...   ELSE              set variable   ${OAMParam_modiflist}
         Run Keyword if   '${val_to_update}'=='True'               Dated log    ${p_name} Updated in Scf
         ${p_name}    set Variable    nbrOfBlankedPRBsHighEdgeDL
         ${val_e}    Get From Dictionary    ${dict_cells[${index_cell}]}    nbrOfBlankedPRBsHighEdgeDL
         ${dist_name}     set Variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${index_cell_1}
         ${val}	 scf.get_value_from_scf   p_name=${p_name}
         ...                              dist_name=${dist_name}
         # continue for loop if  '${val}'=='${val_e}'
         ${val_to_update}=   set variable if   '${val.lower()}'!='${val_e}'     True
         ...                                                                    False
         ${OAMParam_modiflist}=  Run Keyword if   '${val_to_update}'=='True'    ${kw_setOnLine_ListParam}      ${p_name}
         ...                                                                                                   ${val_e}
         ...                                                                                                   ${dist_name}
         ...                                                                                                   ${OAMParam_modiflist}
         ...   ELSE              set variable   ${OAMParam_modiflist}
         Run Keyword if   '${val_to_update}'=='True'               Dated log    ${p_name} Updated in Scf
         ${p_name}    set Variable    nbrOfBlankedPRBsHighEdgeUL
         ${val_e}    Get From Dictionary    ${dict_cells[${index_cell}]}    nbrOfBlankedPRBsHighEdgeUL
         ${dist_name}     set Variable     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${index_cell_1}
         ${val}	 scf.get_value_from_scf   p_name=${p_name}
         ...                              dist_name=${dist_name}
         # continue for loop if  '${val}'=='${val_e}'
         ${val_to_update}=   set variable if   '${val.lower()}'!='${val_e}'     True
         ...                                                                    False
         ${OAMParam_modiflist}=  Run Keyword if   '${val_to_update}'=='True'    ${kw_setOnLine_ListParam}      ${p_name}
         ...                                                                                                   ${val_e}
         ...                                                                                                   ${dist_name}
         ...                                                                                                   ${OAMParam_modiflist}
         ...   ELSE              set variable   ${OAMParam_modiflist}
         Run Keyword if   '${val_to_update}'=='True'               Dated log    ${p_name} Updated in Scf
    END
    # Update gNB OAM List Param   ${OAMParam_modiflist}
    Run Keyword     ${KwOnlineParamChange}       ${OAMParam_modiflist}
    # improvement : COAM Get SCF Kw is more fast than OAM Get SCF File kw!!!
    # ${test_scf_file}           OAM Get SCF File    dir=${LOG_PATH}      file=SCF.xml
    ${test_scf_file}             COAM Get SCF        local_dir_path=${LOG_PATH}      file=SCF.xml      alias=coam_gnb
    Set Suite Variable           ${test_scf_file}
    return from Keyword

Get Original TL Configuration Files
    [Arguments]                   ${BACKUP_DIR}=original_config_files

    testcase-Keywords.Prepare Logs Directory Path    resultDir=${LOG_PATH}   subdir=${BACKUP_DIR}
    ${configuration_directory}=    testcase-Keywords.Prepare Logs Directory Path    resultDir=${LOG_PATH}   subdir=config
    set suite variable       ${configuration_directory}

    ${ret}   ${original_vendor_file_list}   Run Keyword And Ignore Error      SetConfig.Download Vendor File
    ${cmd}=   Catenate    basename ${original_vendor_file_list}[0]
    ${original_vendor_file_name}=   OperatingSystem.Run   ${cmd}
    Run Keyword And Ignore Error    OperatingSystem.Move File       ${original_vendor_file_list}[0]   ${LOG_PATH}/${BACKUP_DIR}/.
    Dated Log               -----> Original Vendor File Name : ${LOG_PATH}/${BACKUP_DIR}/${original_vendor_file_name}

    # Save current  SCF file
    ${file_name}   set variable     SCF_Original.xml
    # ${original_scf_file}            OAM Get SCF File                file=${file_name}
    # improvement : COAM Get SCF Kw is more fast than OAM Get SCF File kw!!!
    ${original_scf_file}            COAM Get SCF     local_dir_path=${LOG_PATH}     file=${file_name}     alias=coam_gnb
    Set Suite Variable              ${original_scf_file}
    Dated Log New Line         Original SCF file stored to ${original_scf_file}
    Run keyword and Ignore error   OperatingSystem.Move File    ${original_scf_file}
    ...                                                         ${LOG_PATH}/${BACKUP_DIR}/${file_name}

    # Get swconfig file that will be restored during test suite teardown
    # ${alias_gnb}                    SSH Wait For Connect                ${GNB_DU.sys[0].M}
    ${alias_gnb}            connect.Connect to Node Common Unit

    ${file_name}   set variable     swconfig_Original.txt
    csn.download_file               remote_path=${SWCONFIG_PATH}
    ...                             local_path=${LOG_PATH}/${file_name}
    ...                             connection=${alias_gnb}
    Dated Log                  Default swconfig file stored to ${LOG_PATH}/${file_name}
    Run keyword and Ignore error   OperatingSystem.Move File    ${LOG_PATH}/${file_name}
    ...                                                         ${LOG_PATH}/${BACKUP_DIR}/${file_name}

    # Get EPC file configuration:
    ${alias_epc}                    SSH Wait For Connect                ${HOST_EPCSIM}
    ${file_name}   set variable     basic_wts_Original.cfg
    csn.download_file               remote_path=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                             local_path=${LOG_PATH}/${file_name}
    ...                             connection=${alias_epc}
    Dated Log                  Default basic cfg file stored to ${LOG_PATH}/${file_name}
    Run keyword and Ignore error   OperatingSystem.Move File    ${LOG_PATH}/${file_name}    ${LOG_PATH}/${BACKUP_DIR}/${file_name}

    ${file_name}   set variable     new_iphy_Original.xml
    Run keyword and Ignore error      TARF-Keywords.Get iPhy.xml file from Airphone    target_dir=${LOG_PATH}    file_name=${file_name}
    Dated Log                  Default /ffs/run/simmode/new_iphy.xml from Airphone stored to ${LOG_PATH}/${file_name}
    Run keyword and Ignore error     OperatingSystem.Move File    ${LOG_PATH}/${file_name}    ${LOG_PATH}/${BACKUP_DIR}/${file_name}

    # store original Airphone swconfig
    ${file_name}   set variable     ap_swconfig.txt
    ${ap_swconfig_orig}    TARF-Keywords.Store Current swconfig from Airphone     target_dir=${LOG_PATH}   file_name=${file_name}
    Dated Log                  Default /ffs/run/swconfig.txt from Airphone stored to ${ap_swconfig_orig}
    Run keyword and Ignore error     OperatingSystem.Copy File    ${ap_swconfig_orig}    ${LOG_PATH}/${BACKUP_DIR}/${file_name}.orig

Restore Orignal Configuration
    [Arguments]                   ${BACKUP_DIR}=original_config_files

    # Get swconfig file that will be restored during test suite teardown
    # ${status}    ${alias_gnb}          Run Keyword And Ignore Error        SSH Wait For Connect                ${GNB_DU.sys[0].M}
    # ${status}    ${alias_gnb}          Run Keyword And Ignore Error        SSH Wait For Connect     192.168.255.129
    ${status}    ${alias_gnb}            Run Keyword And Ignore Error    connect.Connect to Node Common Unit

    Run Keyword And Ignore Error       csn.upload_file                 remote_path=${SWCONFIG_PATH}
    ...                             local_path=${LOG_PATH}/${BACKUP_DIR}/swconfig_Original.txt
    ...                             connection=${alias_gnb}

    SSH Exec                        command=crasign ${SWCONFIG_PATH}           alias=${alias_gnb}

    Dated Log                 swconfig file has been restored to default (${LOG_PATH}/${BACKUP_DIR}/swconfig_original.txt)

    ${alias_epc}                    SSH Wait For Connect                ${HOST_EPCSIM}
    csn.upload_file                 remote_path=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                             local_path=${LOG_PATH}/${BACKUP_DIR}/basic_wts_Original.cfg
    ...                             connection=${alias_epc}

    Dated Log                basic cfg file has been restored to default (${LOG_PATH}/${BACKUP_DIR}/basic_wts_original.cfg)

    ${file_name}   set variable     new_iphy_Original.xml
    Run keyword and Ignore error      TARF-Keywords.Restore iPhy.xml file to Airphone    local_dir=${LOG_PATH}/${BACKUP_DIR}
    ...                                                                    file_name=${file_name}
    Dated Log            /ffs/run/simmode/iphy.xml has been restored with default ${LOG_PATH}/${BACKUP_DIR}/${file_name}

is fragmentationCapabilities present in AP iphy xml file
    ${file_name}   set variable     current_iphy.xml
    Run keyword and Ignore error      TARF-Keywords.Get iPhy.xml file from Airphone    target_dir=${LOG_PATH}    file_name=${file_name}
    Dated Log                  current /ffs/run/simmode/iphy.xml from Airphone stored to ${LOG_PATH}/${file_name}
    ${rc}    ${output}    Run And Return Rc And Output
    ...    command=cat ${LOG_PATH}/${file_name} | grep 'fragmentationCapabilities'
    ${status}    Run Keyword And Return Status    Should Not Be Empty    ${output}
    ${Fragmentation Capabilities present}=    set Variable    ${status}
    [Return]    ${Fragmentation Capabilities present}

is ulFeatures present in AP iphy xml file
    ${file_name}   set variable     current_iphy.xml
    Run keyword and Ignore error      Get iPhy.xml file from Airphone    target_dir=${LOG_PATH}    file_name=${file_name}
    Dated Log                  current /ffs/run/simmode/iphy.xml from Airphone stored to ${LOG_PATH}/${file_name}
    ${rc}    ${output}    Run And Return Rc And Output
    ...    command=cat ${LOG_PATH}/${file_name} | grep 'ulFeatures'
    ${status}    Run Keyword And Return Status    Should Not Be Empty    ${output}
    ${ulFeatures present}=    set Variable    ${status}
    [Return]    ${ulFeatures present}

remove ul features in /tmp/${iphy_filename}
    dated log     remove ul features from /tmp/${iphy_filename}
    ${iphy_filename_output}=     return_basename    ${iphy_filename}
    ${iphy_filename_output}      Remove String      ${iphy_filename_output}     .xml
    ${iphy_filename_output}      set variable       ${iphy_filename_output}_no_ulfearures.xml
    ${xml_content}=    OperatingSystem.Get File    /tmp/${iphy_filename}
    ${modified_content}=    Replace String Using Regexp    ${xml_content}         <ulFeatures>.*?</ulFeatures>        ${EMPTY}
# obsolete param:    ${modified_content}=    Replace String Using Regexp    ${modified_content}    <refinedBeams>.*?</refinedBeams>    ${EMPTY}
    ${modified_content}=    Replace String Using Regexp    ${modified_content}    <dlFeatures>.*?</dlFeatures>        ${EMPTY}
    OperatingSystem.Create File    /tmp/${iphy_filename_output}    ${modified_content}
    [return]    ${iphy_filename_output}

remove ulFeatures from AP file if present in /tmp
    [Arguments]    ${iphy_file}
    ${fileExists}=    nps_trf_tools.file_exists   ${iphy_file}
    ${iphy_filename}=      Run Keyword if   ${fileExists}==${True}     return_basename    ${iphy_file}
    ...                      ELSE                                      set Variable       ${None}
    ${fileiphyExistsInTmp}=    nps_trf_tools.file_exists   /tmp/${iphy_filename}
    ${AP ulFeatures}=     is ulFeatures present in AP iphy xml file
    ${iphy_filename_output}    run Keyword if     ${fileiphyExistsInTmp} and ${AP ulFeatures}     remove ul features in /tmp/${iphy_filename}
    ...                             ELSE                                                          Set Variable      ${EMPTY}
    [return]     ${iphy_filename_output}

Create Trace List
    [Documentation]    list of Trace Dict with Type, Savedir, name, TS, Trigger
    ${Test Trace List}     Create List
    set test Variable       ${Test Trace List}

declare Trace in Trace List
    [Documentation]    list of Trace Dict with Type, Savedir, name, TS, Trigger
    [Arguments]     ${Type}     ${Savedir}     ${file_name}      ${Trigger}
    &{Test Trace dictionary}=    Create Dictionary
    Set To Dictionary       ${Test Trace dictionary}        Type       ${Type}
    Set To Dictionary       ${Test Trace dictionary}        Savedir    ${Savedir}
    Set To Dictionary       ${Test Trace dictionary}        name       ${file_name}
    Set To Dictionary       ${Test Trace dictionary}        Trigger    ${Trigger}
    Append To List          ${Test Trace List}     ${Test Trace dictionary}
    set test Variable       ${Test Trace List}
    # dated log     Test Trace List=${Test Trace List}

Display Trace List
    [Documentation]    list of Trace Dict with Type, Savedir, name, TS, Trigger
    StringTool.printLineWithTitle     title=Display Test Trace List
    # dated log    Test Trace List = ${Test Trace List}

    nps_trf_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${Test Trace}    filename=test_Trace_list.json
    ${index}=    Set Variable    ${0}
    FOR     ${Item}    IN    @{Test Trace List}
        # dated log     Item=${Item}
        ${index}      Evaluate     ${index} + ${1}
        ${Type}    Get From Dictionary        ${Item}     Type
        ${msg}=   nps_trf_tools.getHeaderLine_13    Type        ${Type}
        dated log     ${msg}
        ${Savedir}    Get From Dictionary     ${Item}     Savedir
        ${msg}=   nps_trf_tools.getHeaderLine_13    Savedir     ${Savedir}
        dated log     ${msg}
        ${name}    Get From Dictionary        ${Item}     name
        ${msg}=   nps_trf_tools.getHeaderLine_13    name        ${name}
        dated log     ${msg}
        ${Trigger}    Get From Dictionary     ${Item}     Trigger
        ${msg}=   nps_trf_tools.getHeaderLine_13    Trigger     ${Trigger}
        dated log     ${msg}
        StringTool.printLineWithTitle     title=-
        nps_trf_tools.add_dictionary_to_json    dir_path=${testCaseDir}   key=${name}_${index}
        ...                                      dictionary=${Item}   filename=test_Trace_list.json
    END

Create Test Results List
    [Documentation]    list of Test Dict with Type, Result
    ${Test Results List}     Create List
    set test Variable       ${Test Results List}

declare Results in Test Results List
    [Documentation]    list of tests Dict with Type, Result
    [Arguments]     ${Type}     ${Result}
    &{Test Results dictionary}=    Create Dictionary
    Set To Dictionary       ${Test Results dictionary}        Type      ${Type}
    Set To Dictionary       ${Test Results dictionary}        Result    ${Result}
    Append To List          ${Test Results List}     ${Test Results dictionary}
    set test Variable       ${Test Results List}
    Append to File          ${resultFile}     \t\t--------> ${Type}: ${Result}\n
    # dated log     Test Results List=${Test Results List}

Display Test Results List
    [Documentation]    list of tests Dict with Type, Result
    StringTool.printLineWithTitle     title=Display Test Results List
    # dated log    Test Trace List = ${Test Trace List}

    nps_trf_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${Test Results}    filename=test_Results_list.json
    ${index}=    Set Variable    ${0}
    FOR     ${Item}    IN    @{Test Results List}
        # dated log     Item=${Item}
        ${index}     Evaluate     ${index} + ${1}
        ${Type}      Get From Dictionary     ${Item}     Type
        ${Result}    Get From Dictionary     ${Item}     Result
        ${msg}=   nps_trf_tools.getHeaderLine_13    ${Type}      ${Result}
        # Run Keyword If    'False' in ${Result}     BuiltIn.Log     msg=${Type}:${Result}     level=ERROR
        dated log     ${msg}
        nps_trf_tools.add_dictionary_to_json    dir_path=${testCaseDir}   key='${index}'
        ...                                      dictionary=${Item}   filename=test_Results_list.json   sort_keys=${False}
    END
    StringTool.printLineWithTitle     title=-

Save PDCCH Profile
    testcase-Keywords.Prepare Logs Directory Path    subdir=pdcch_profiles
    OperatingSystem.run     cp ${Cell1_PDCCHProfile_delta_file} ${testCaseDir}/pdcch_profiles
    OperatingSystem.run     cp ${Cell2_PDCCHProfile_delta_file} ${testCaseDir}/pdcch_profiles
    OperatingSystem.run     cp ${actPowerSavingBWP_activate_delta_file_Cell1} ${testCaseDir}/pdcch_profiles

    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=1    listindex=0
    # ${cellBwpList_params_list}    Create List    actPdcchCceFragmentControl    actUpperThrAckNackFiltering
    # ...                                          actUpperThrAckNackHrFiltering    bwpDN    cellBwpId    pdcchResourcePreference
    nps_trf_tools.write_dictionary_to_json  dir_path=${testCaseDir}/pdcch_profiles/
    ...                                      dictionary=${cellBwpList_params_list}    filename=cellBwpList.json
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=1    listindex=0
    nps_trf_tools.add_dictionary_to_json    dir_path=${testCaseDir}/pdcch_profiles/    key=CELL1_cellBwpId_0
    ...                                      dictionary=${cellBwpList_params_list}    filename=cellBwpList.json
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=1    listindex=1
    nps_trf_tools.add_dictionary_to_json    dir_path=${testCaseDir}/pdcch_profiles/    key=CELL1_cellBwpId_1
    ...                                      dictionary=${cellBwpList_params_list}    filename=cellBwpList.json
    ${ret}    ${cellBwpList_params_list}=    Run Keyword and Ignore Error     Get bwpDN Parameters From gNB     CellId=1    listindex=2
    Run Keyword If     '${ret}' == 'PASS'    Run Keyword and Ignore Error      nps_trf_tools.add_dictionary_to_json
    ...                                      dir_path=${testCaseDir}/pdcch_profiles/    key=CELL1_cellBwpId_2
    ...                                      dictionary=${cellBwpList_params_list}    filename=cellBwpList.json
    ...     ELSE                             Run Keyword and Ignore Error      nps_trf_tools.add_dictionary_to_json
    ...                                      dir_path=${testCaseDir}/pdcch_profiles/    key=CELL1_cellBwpId_2
    ...                                      dictionary='No cellBwpId_2'    filename=cellBwpList.json
    ${ret}    ${cellBwpList_params_list}=    Run Keyword and Ignore Error     Get bwpDN Parameters From gNB     CellId=1    listindex=3
    Run Keyword If     '${ret}' == 'PASS'    Run Keyword and Ignore Error      nps_trf_tools.add_dictionary_to_json
    ...                                      dir_path=${testCaseDir}/pdcch_profiles/    key=CELL1_cellBwpId_3
    ...                                      dictionary=${cellBwpList_params_list}    filename=cellBwpList.json
    ...     ELSE                             Run Keyword and Ignore Error      nps_trf_tools.add_dictionary_to_json
    ...                                      dir_path=${testCaseDir}/pdcch_profiles/    key=CELL1_cellBwpId_3
    ...                                      dictionary='No cellBwpId_3'    filename=cellBwpList.json
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=2    listindex=0
    nps_trf_tools.add_dictionary_to_json    dir_path=${testCaseDir}/pdcch_profiles/    key=CELL2_cellBwpId_0
    ...                                      dictionary=${cellBwpList_params_list}    filename=cellBwpList.json
    ${cellBwpList_params_list}=     Get bwpDN Parameters From gNB     CellId=2    listindex=1
    nps_trf_tools.add_dictionary_to_json    dir_path=${testCaseDir}/pdcch_profiles/    key=CELL2_cellBwpId_1
    ...                                      dictionary=${cellBwpList_params_list}    filename=cellBwpList.json
    ${ret}    ${cellBwpList_params_list}=    Run Keyword and Ignore Error     Get bwpDN Parameters From gNB     CellId=2    listindex=2
    Run Keyword If     '${ret}' == 'PASS'   Run Keyword and Ignore Error     nps_trf_tools.add_dictionary_to_json
    ...                                      dir_path=${testCaseDir}/pdcch_profiles/    key=CELL2_cellBwpId_2
    ...                                      dictionary=${cellBwpList_params_list}    filename=cellBwpList.json
    ...    ELSE                             Run Keyword and Ignore Error     nps_trf_tools.add_dictionary_to_json
    ...                                      dir_path=${testCaseDir}/pdcch_profiles/    key=CELL2_cellBwpId_2
    ...                                      dictionary='No cellBwpId_2'    filename=cellBwpList.json
    ${ret}    ${cellBwpList_params_list}=    Run Keyword and Ignore Error     Get bwpDN Parameters From gNB     CellId=2    listindex=3
    Run Keyword If     '${ret}' == 'PASS'    Run Keyword and Ignore Error     nps_trf_tools.add_dictionary_to_json
    ...                                      dir_path=${testCaseDir}/pdcch_profiles/    key=CELL2_cellBwpId_3
    ...                                      dictionary=${cellBwpList_params_list}    filename=cellBwpList.json
    ...    ELSE                              Run Keyword and Ignore Error     nps_trf_tools.add_dictionary_to_json
    ...                                      dir_path=${testCaseDir}/pdcch_profiles/    key=CELL2_cellBwpId_3
    ...                                      dictionary='No cellBwpId_3'    filename=cellBwpList.json

    return From Keyword If    '${W_DEBUG_INFO}'=='0'

    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-67
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell2-BWP_PROFILE-67-bwp-dedicated.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-67/PDCCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell2-BWP_PROFILE-67-PDCCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell2-BWP_PROFILE-67-searchSpaceCommon.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell2-BWP_PROFILE-67-PDCCH-1_CONFIG_DEDICATED.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-67/PDSCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell2-BWP_PROFILE-67-PDSCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-6
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell2-BWP_PROFILE-6-bwp-initial.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-6/PDCCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell2-BWP_PROFILE-6-PDCCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell2-BWP_PROFILE-6-searchSpaceCommon.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell2-BWP_PROFILE-6-PDCCH-1_CONFIG_DEDICATED.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-6/PDSCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell2-BWP_PROFILE-6-PDSCH-1.json

    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-57
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-57-bwp-dedicated.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-57/PDCCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-57-PDCCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-57-searchSpaceCommon.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-57/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-57-PDCCH-1_CONFIG_DEDICATED.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-57/PDSCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-57-PDSCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-5
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-5-bwp-initial.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-5/PDCCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-5-PDCCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-5-searchSpaceCommon.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-5-PDCCH-1_CONFIG_DEDICATED.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-5/PDSCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-5-PDSCH-1.json

    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-77
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-77-bwp-dedicated.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-77/PDCCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-77-PDCCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-77-searchSpaceCommon.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-77-PDCCH-1_CONFIG_DEDICATED.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-77/PDSCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-77-PDSCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-7
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-7-bwp-initial.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-7/PDCCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-7-PDCCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-7-searchSpaceCommon.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-7-PDCCH-1_CONFIG_DEDICATED.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-7/PDSCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-7-PDSCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-70
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-70-bwp-dedicated.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-70/PDCCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-70-PDCCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-70/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-70-searchSpaceCommon.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-70/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-70-PDCCH-1_CONFIG_DEDICATED.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-70/PDSCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-70-PDSCH-1.json

    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-27
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-27-bwp-dedicated.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-27/PDCCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-27-PDCCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-27-searchSpaceCommon.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-27/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-27-PDCCH-1_CONFIG_DEDICATED.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-27/PDSCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-27-PDSCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-2
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-2-bwp-initial.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-2/PDCCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-2-PDCCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-2-searchSpaceCommon.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-2-PDCCH-1_CONFIG_DEDICATED.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-2/PDSCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-2-PDSCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-20
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-20-bwp-dedicated.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-20/PDCCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-20-PDCCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-20-searchSpaceCommon.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-20/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-20-PDCCH-1_CONFIG_DEDICATED.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-20/PDSCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-20-PDSCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-23
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-23-bwp-dedicated.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-23/PDCCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/cell1-BWP_PROFILE-23-PDCCH-1.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-23-searchSpaceCommon.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-23/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-23-PDCCH-1_CONFIG_DEDICATED.json
    get_pdcch_profiles      scf_xml_path=${test_scf_file}
    ...                     distName=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-23/PDSCH-1
    ...                     json_outpath=${testCaseDir}/pdcch_profiles/Cell1-BWP_PROFILE-23-PDSCH-1.json

update test Variables
    [Arguments]         ${test_dictParam}      ${CAPTURE}
    StringTool.printLineWithTitle     title=-
    display_dictionnary_parameters_of_the_TestCase    ${test_dictParam}
    display_dictionnary_parameters_CAPTURE_of_the_TestCase    ${CAPTURE}
    ${w_generic_capture}               Get From Dictionary     ${test_dictParam}     w_generic_capture
    ${isCaptureCPRT}                   Get From Dictionary     ${test_dictParam}     w_CaptureCPRT
    ${isCaptureL1L2}                   Get From Dictionary     ${test_dictParam}     w_CaptureL1L2
    ${isCaptureCORE}                   Get From Dictionary     ${test_dictParam}     w_CaptureCORE
    ${isCaptureTti}                    Get From Dictionary     ${test_dictParam}     w_CaptureTti
    ${w_check_9890_using_sherpa}       Get From Dictionary     ${test_dictParam}     w_check_9890_using_sherpa
    ${w_convert_TtiPcap_to_excelCsv}   Get From Dictionary     ${test_dictParam}     w_convert_TtiPcap_to_excelCsv
    ${w_Basic_Call_to_Setup_Wtsemu}    Get From Dictionary     ${test_dictParam}     w_Basic_Call_to_Setup_Wtsemu
    ${enable_sherpa}                   Get From Dictionary     ${test_dictParam}     w_enable_sherpa_Traces
    ${w_GetL1L2Bip}                    Get From Dictionary     ${test_dictParam}     w_GetL1L2Bip
    ${w_GetTtiTrace}                   Get From Dictionary     ${test_dictParam}     w_GetTtiTrace
    ${w_ue_detach}                     Get From Dictionary     ${test_dictParam}     w_ue_detach
    ${w_DISPLAY_ue_stats_nr_15min}     Get From Dictionary     ${test_dictParam}     w_DISPLAY_ue_stats_nr_15min
    ${GetTtiTraceTime}                 Get From Dictionary     ${CAPTURE}     GetTtiTraceTime
    ${Getl1l2TraceTime}                Get From Dictionary     ${CAPTURE}     Getl1l2TraceTime
    ${GetSherpaTraceTime}              Get From Dictionary     ${CAPTURE}     GetSherpaTraceTime
    ${GetTtiTraceNumOfEvent}           Get From Dictionary     ${CAPTURE}     GetTtiTraceNumOfEvent
    Set Suite Variable      ${GetTtiTraceTime}
    Set Suite Variable      ${GetTtiTraceNumOfEvent}
    Set Suite Variable      ${Getl1l2TraceTime}
    Set Suite Variable      ${GetSherpaTraceTime}
    Set Suite Variable      ${enable_sherpa}
    Set Suite Variable      ${w_check_9890_using_sherpa}
    Set Suite Variable      ${w_generic_capture}
    Set Suite Variable      ${w_convert_TtiPcap_to_excelCsv}
    Set Suite Variable      ${w_Basic_Call_to_Setup_Wtsemu}
    Set Suite Variable      ${isCaptureCPRT}
    Set Suite Variable      ${isCaptureL1L2}
    Set Suite Variable      ${isCaptureCORE}
    Set Suite Variable      ${isCaptureTti}
    Set Suite Variable      ${enable_sherpa}
    Set Suite Variable      ${w_GetTtiTrace}
    Set Suite Variable      ${w_ue_detach}
    Set Suite Variable      ${w_DISPLAY_ue_stats_nr_15min}
    Set Suite Variable      ${w_GetL1L2Bip}

Set Reset Loop Counter
    [Documentation]                 INTERNAL USAGE
    ...                             ddal -s ddal_boot_set_reset_loop_count 0
    [Arguments]                     ${rlc_number}=0

    Dated log                       Initialize reset_loop_count on ${GNB_DU.name} (command =ddal -s ddal_boot_set_reset_loop_count ${rlc_number})
    ${alias}                        SSH Connect                          ${GNB_DU.sys[0].M}
    ${file}                         SSH Cmd                              command=ddal -s ddal_boot_set_reset_loop_count ${rlc_number}
    ...                             alias=${alias}

Configure the setting for the ${totalNbOfUe} UEs
    dated log      Configure the setting for the ${totalNbOfUe} ue's

UE Register
    [Documentation]           Register SA UE (signaling on gNB) and checking by apparition of message 'crnti' on eGate console.
    ...
    ...                       *Argument details:*
    ...    - *ue*:         Specified UE ID (default value = 1)
    ...    - *ue_capa*:    ue_nr_capabilities if Needed
    ...    - *timeout*:    (default: 30)
    [Arguments]    ${ue}=1    ${ue_nr_capabilities}=None    ${timeout}=30      ${expected_log}=UE now in NG RM Registered state
    # RDH: flush the buffer to be sure to have all egate console log
    CallSetup.Flush Egate Console Buffer
    run Keyword if      '${ue_nr_capabilities}'=='None'     wtsemu.ue_register    id=${ue}
    ...    ELSE                                             wtsemu.ue_register    id=${ue}    ue_nr_capabilities=${ue_nr_capabilities}
    Dated Log         Checking: ${expected_log}
    wtsemu.Read Wtsemu Output Until Re
    ...                             expected=${expected_log}
    ...                             timeout=${timeout}

CallSetup UE register UeId "${ue}" on Target cell "${CellId}"
    # CallSetup.UE Register  ue=${ue}
    ${elemMoins1}   Evaluate    ${ue}-${1}    #needed to navigate on dictionnary
    ${ue_capa}      Get From Dictionary
    ...     ${dict_settings_all_ues_global[${elemMoins1}]}
    ...     ue_capa
    wtsemu.ue_change_location         id=${ue}     cell=${CellId}
    TARF-Keywords.UE Register     ue=${ue}     ue_nr_capabilities=${ue_capa}

get bts status with COAM
    [Documentation]     : [PRIVATE]
    ...     get Specific bts status
    ...
    ...     timeout:   Time to wait for positive procedure result
    ...
    [Arguments]     ${oam_alias}     ${timeout}=30
    ${bts_status}=     coam.get_bts_statuses    timeout=${timeout}    connection=${oam_alias}
    Dated log    BTS procedural state is now: ${consTraceColor} ${bts_status['proceduralState']} ${defColor}
    [Return]     ${bts_status['proceduralState']}

Verify cellId setup with COAM
    [Documentation]     : [PRIVATE]
    ...     Verify Specific Cell status and BTS Cell setup status
    ...
    ...     cell_status:   cell status reported bu cOAM, using get_cells_info
    ...     cell_id:   Id of cell,
    ...     timeout:   Time to wait for positive procedure result
    ...
    [Arguments]    ${oam_alias}    ${cell_status}=None    ${cell_id}=1   ${timeout}=30
    ${P_internal_cell_dist_id}=  Set Variable   ${cell_status['id']['internal']}
    ${cell_status_}=    Set variable  ${cell_status['status']}
    ${bts_status}=     coam.get_bts_statuses    timeout=${timeout}    connection=${oam_alias}
    ${msg}=   Catenate    ${consTraceColor}Cell ${cell_id} ${defColor}[${P_internal_cell_dist_id}]
    Dated log    ${msg}
    ${msg}=   Catenate    operationalState=${cell_status_['operationalState']},
    ...                   proceduralStatus=${cell_status_['proceduralStatus']},
    ...                   administrativeState=${cell_status_['administrativeState']},
    Dated log    ${msg}
    ${msg}=   Catenate    blockingState=${cell_status_['blockingState']}
    Dated log    ${msg}
    Dated log    BTS procedural state is now: ${consTraceColor} ${bts_status['proceduralState']} ${defColor}
    Should be equal    ${cell_status_['operationalState']}         Enabled         ignore_case=true
    Should be equal    ${cell_status_['proceduralStatus']}         configured      ignore_case=true
    Should be equal    ${cell_status_['blockingState']}            Unblocked       ignore_case=true
    Should be equal    ${cell_status_['administrativeState']}      Unlocked        ignore_case=true
    Should be equal    ${bts_status['operationalState']}           Enabled         ignore_case=true
    Should be equal    ${bts_status['proceduralState']}           OnAir     msg=GNB is not on air, Current status is ${bts_status['proceduralState']}
    ...                                                                     ignore_case=true
    Should be equal    ${bts_status['blockingState']}             Unblocked       ignore_case=true
    [Return]  ${P_internal_cell_dist_id}

Verify cell setup with COAM
    [Documentation]     : [PRIVATE]
    ...     Verify Specific Cell status and BTS Cell setup status
    ...
    ...     cell_id:   Id of cell,
    ...     timeout:   Time to wait for positive procedure result
    ...
    [Arguments]     ${oam_alias}    ${cell_id}=0   ${timeout}=30
    ${cells_status}=    coam.get_cells_info    cell_type=nr     timeout=${timeout}    connection=${oam_alias}
    ${bts_status}=     coam.get_bts_statuses    timeout=${timeout}    connection=${oam_alias}
    ${P_internal_cell_dist_id}=  Set Variable   ${cells_status[${cell_id}]['id']['internal']}
    ${cell_status_}=    Set variable  ${cells_status[${cell_id}]['status']}
    ${msg}=   Catenate    ${consTraceColor}Cell ${cell_id}${defColor} [${P_internal_cell_dist_id}]
    Dated log    ${msg}
    ${msg}=   Catenate    operationalState=${cell_status_['operationalState']},
    ...                   proceduralStatus=${cell_status_['proceduralStatus']},
    ...                   administrativeState=${cell_status_['administrativeState']},
    Dated log    ${msg}
    ${msg}=   Catenate    blockingState=${cell_status_['blockingState']}
    Dated log    ${msg}
    Dated log    BTS procedural state is now: ${consTraceColor} ${bts_status['proceduralState']} ${defColor}
    Should be equal    ${cell_status_['operationalState']}         Enabled         ignore_case=true
    Should be equal    ${cell_status_['proceduralStatus']}         configured      ignore_case=true
    Should be equal    ${cell_status_['blockingState']}            Unblocked       ignore_case=true
    Should be equal    ${cell_status_['administrativeState']}      Unlocked        ignore_case=true
    Should be equal    ${bts_status['operationalState']}          Enabled         ignore_case=true
    Should be equal    ${bts_status['proceduralState']}           OnAir     msg=GNB is not on air, Current status is ${bts_status['proceduralState']}
    ...                                                                     ignore_case=true
    Should be equal    ${bts_status['blockingState']}             Unblocked       ignore_case=true
    [Return]  ${P_internal_cell_dist_id}   ${cells_status}

Verify that cellId are onair with COAM
    [Documentation]     [PRIVATE]
    [Arguments]      ${oam_alias}   ${globalCellId}=1
    ${output}=    coam.get_cells_info    cell_type=nr     timeout=30    connection=${oam_alias}
    FOR    ${cell}    IN    @{output}
        continue for loop if   '${cell['globalCellId']}' != '${globalCellId}'
        ${_internal_cell_dist_id}=  Verify cellId setup with COAM   oam_alias=${oam_alias}  cell_status=${cell}  cell_id=${globalCellId}
    END

Verify that cells are onair with COAM
    [Documentation]     [PRIVATE]
    [Arguments]      ${oam_alias}   ${num_of_cells}=1    ${cell_to_bypass}=${None}

    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
        ${cells_status}=    coam.get_cells_info    cell_type=nr     timeout=30    connection=${oam_alias}
        ${P_internal_cell_dist_id}=  Set Variable   ${cells_status[${cell_id}]['id']['internal']}
        # ${is_cell_to_bypass}=    run keyword and return status    Should Contain    ${P_internal_cell_dist_id}    ${cell_to_bypass}
        ${is_cell_to_bypass}=    run keyword and return status    SHOULD MATCH REGEXP    ${P_internal_cell_dist_id}    ${cell_to_bypass}[0]
        Continue for loop If    ${is_cell_to_bypass}
        ${is_cell_to_bypass}=    run keyword and return status    SHOULD MATCH REGEXP    ${P_internal_cell_dist_id}    ${cell_to_bypass}[1]
        Continue for loop If    ${is_cell_to_bypass}
        ${_internal_cell_dist_id}  ${cells_status}=  Verify cell setup with COAM   oam_alias=${oam_alias}   cell_id=${cell_id}
    END
    [return]   ${cells_status}

Get Cell Number
    [Arguments]    ${gnb_index}=0
    # NRCELL_DN_LIST is a global variable provided by AF
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist       ${NRCELL_DN_LIST}
    @{defaultList}=   Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    Run Keyword If   "${status}"=="FAIL"     Set Global Variable     ${NRCELL_DN_LIST}   ${defaultList}
    Remove Values from List    ${NRCELL_DN_LIST}    ${None}
    ${cell_number}    Set Variable    ${NRCELL_DN_LIST.__len__()}
    [Return]   ${cell_number}

COAM Get Cell Number
    [Documentation]  get cell number
    [Arguments]  ${connection}=GNB_OAM
    ${cells_info}=    coam.get_cells_info    connection=${connection}
    ${cell_nums}    Get Length    ${cells_info}
    [Return]  ${cell_nums}

Wait gNB cells 5g On air wo Print Cells Info
    [Documentation]        [PRIVATE]  Wait gNB cells 5g On air
    [Arguments]     ${num_of_cells}=1     ${cell_to_bypass}=${None}
    Return From Keyword If    "${WAIT_5G_CELL_ONAIR}" == "0"
    ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}
    ${cells_status}=   wait until keyword succeeds    1min    20s      Verify that cells are onair with COAM   oam_alias=${GNB_DU.oam.httpAlias}
    ...                                                                                     num_of_cells=${num_of_cells}
    ...                                                                                     cell_to_bypass=${cell_to_bypass}

Wait gNB cells 5g On air
    [Documentation]        [PRIVATE]  Wait gNB cells 5g On air
    [Arguments]     ${num_of_cells}=1     ${cell_to_bypass}=${None}
    Return From Keyword If    "${WAIT_5G_CELL_ONAIR}" == "0"
    ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}
    ${cells_status}=   wait until keyword succeeds    1min    20s      Verify that cells are onair with COAM   oam_alias=${GNB_DU.oam.httpAlias}
    ...                                                                                     num_of_cells=${num_of_cells}
    ...                                                                                     cell_to_bypass=${cell_to_bypass}

    # Dated Log   DBG - cells_status=${cells_status}
    ${dict_cells}=  Create dictionary
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
        Dated Log New Line  ${consTraceColor}=== cellId ${cell_id} === ${defColor}
        Dated Log           globalCellId=${cells_status[${cell_id}]['globalCellId']}
        Dated Log           configuration=${cells_status[${cell_id}]['id']['configuration']}
        Dated Log           band=${cells_status[${cell_id}]['band']}
        Dated Log           subCellList=${cells_status[${cell_id}]['subCellList']}
        Dated Log           cellName=${cells_status[${cell_id}]['cellName']}
        Dated Log           physicalCellId=${cells_status[${cell_id}]['physicalCellId']}
        Dated Log           technology=${cells_status[${cell_id}]['technology']}
        ${technology}=      set variable    ${cells_status[${cell_id}]['technology']}
        Dated Log           nrCellType=${cells_status[${cell_id}]['nrCellType']}
        Dated Log           cellDepType=${cells_status[${cell_id}]['cellDepType']}
        Dated Log           downlinkMimoMode=${cells_status[${cell_id}]['downlinkMimoMode']}
        Run Keyword if     '${technology}' == 'TDD'      Run Keywords    Dated Log     chBw=${cells_status[${cell_id}]['chBw']}    AND
        ...                                                              Dated Log     nrarfcn=${cells_status[${cell_id}]['nrarfcn']}
        ...   ELSE                                       Run Keywords    Dated Log     chBwUl=${cells_status[${cell_id}]['chBwUl']}    AND
        ...                                                              Dated Log     chBwDl=${cells_status[${cell_id}]['chBwDl']}    AND
        ...                                                              Dated Log     nrarfcnUl=${cells_status[${cell_id}]['nrarfcnUl']}  AND
        ...                                                              Dated Log     nrarfcnDl=${cells_status[${cell_id}]['nrarfcnDl']}

        ${val}  Create list  ${cells_status[${cell_id}]['globalCellId']}   ${cells_status[${cell_id}]['physicalCellId']}
        ...                  ${cells_status[${cell_id}]['nrCellType']}     ${cells_status[${cell_id}]['downlinkMimoMode']}
        ...                  ${cells_status[${cell_id}]['technology']}
        Set To Dictionary    ${dict_cells}    CellId-${cells_status[${cell_id}]['globalCellId']}=${val}
    END
    set suite variable   ${dict_cells}
    Dated log   dict_cells=${dict_cells}
    [Teardown]         OAM Disconnect                  ${GNB_DU.oam}


get subcellId Spool0 with COAM
    [Documentation]     [PRIVATE]
    [Arguments]      ${oam_alias}   ${num_of_cells}=1
    FOR    ${cell_id}    IN RANGE    ${num_of_cells}
        ${cells_status}=    coam.get_cells_info    cell_type=nr     timeout=${timeout}    connection=${oam_alias}
    END
    [return]   ${cells_status}

Get dlsubcellid for cellId by spool with COAM
    [Documentation]     [PRIVATE]
    [Arguments]      ${oam_alias}
    ${cells_status}=    coam.get_cells_info    cell_type=nr     timeout=30    connection=${oam_alias}
    #  subCellList=['Subcell-0 (DL)', 'Subcell-0 (UL)', 'Subcell-3 (DL)', 'Subcell-3 (UL)', 'Subcell-4 (DL)', 'Subcell-5 (DL)']
    ${dlsubcellSpool0List}=  Create List
    ${dlsubcellSpool1List}=  Create List
    FOR    ${cell}    IN    @{cells_status}
        ${subcellList_CellId}=  set Variable    ${cell['subCellList']}
        ${subcellList_PhysicalCellId}=   set Variable     ${cell['physicalCellId']}
        run Keyword if   '${subcellList_PhysicalCellId}' == '50'     dated log    subcellList_Cell50 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '51'     dated log    subcellList_Cell51 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '52'     dated log    subcellList_Cell52 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '53'     dated log    subcellList_Cell53 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '54'     dated log    subcellList_Cell54 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '55'     dated log    subcellList_Cell55 = ${subcellList_CellId}

        ${dlsubcellSpool0List}   run Keyword if   '${subcellList_PhysicalCellId}' == '50' or '${subcellList_PhysicalCellId}' == '52'
        ...                  nps_trf_tools.extract_dll1sp_from_COAM    ${subcellList_CellId}   ${dlsubcellSpool0List}
        ...                         ELSE                set Variable             ${dlsubcellSpool0List}
        ${dlsubcellSpool1List}   run Keyword if   '${subcellList_PhysicalCellId}' == '51' or '${subcellList_PhysicalCellId}' == '53'
        ...                  nps_trf_tools.extract_dll1sp_from_COAM    ${subcellList_CellId}   ${dlsubcellSpool1List}
        ...                         ELSE                set Variable             ${dlsubcellSpool1List}
    END
    # csamson : improve here the mapping subcellId <=> SubpoolId
    # using from syslog ${dll1spcells_syslog} from "Check UL and DL l1Subpool Assignment in Syslogs"
    ${notEmpty}    Run Keyword And Return Status    Should Not Be Empty     ${dll1spcells_syslog[4]}
    ${dlsubcellSpool0List}=    Run Keyword If     ${notEmpty}    Copy List     ${dll1spcells_syslog[4]}
    ...                          ELSE                            Copy List     ${dlsubcellSpool0List}
    ${notEmpty}    Run Keyword And Return Status    Should Not Be Empty     ${dll1spcells_syslog[4]}
    ${dlsubcellSpool1List}=    Run Keyword If     ${notEmpty}    Copy List     ${dll1spcells_syslog[5]}
    ...                          ELSE                            Copy List     ${dlsubcellSpool1List}
    [return]   ${dlsubcellSpool0List}   ${dlsubcellSpool1List}

Get ulsubcellid for cellId by spool with COAM
    [Documentation]     [PRIVATE]
    [Arguments]      ${oam_alias}
    ${cells_status}=    coam.get_cells_info    cell_type=nr     timeout=30    connection=${oam_alias}
    #  subCellList=['Subcell-0 (DL)', 'Subcell-0 (UL)', 'Subcell-3 (DL)', 'Subcell-3 (UL)', 'Subcell-4 (DL)', 'Subcell-5 (DL)']
    ${ulsubcellSpool0List}=  Create List
    ${ulsubcellSpool1List}=  Create List
    FOR    ${cell}    IN    @{cells_status}
        ${subcellList_CellId}=  set Variable    ${cell['subCellList']}
        ${subcellList_PhysicalCellId}=   set Variable     ${cell['physicalCellId']}
        run Keyword if   '${subcellList_PhysicalCellId}' == '50'     dated log    subcellList_Cell50 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '51'     dated log    subcellList_Cell51 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '52'     dated log    subcellList_Cell52 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '53'     dated log    subcellList_Cell53 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '54'     dated log    subcellList_Cell54 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '55'     dated log    subcellList_Cell55 = ${subcellList_CellId}
        ${ulsubcellSpool0List}   run Keyword if   '${subcellList_PhysicalCellId}' == '50' or '${subcellList_PhysicalCellId}' == '52'
        ...                  nps_trf_tools.extract_ull1sp_from_COAM    ${subcellList_CellId}   ${ulsubcellSpool0List}
        ...                         ELSE                set Variable             ${ulsubcellSpool0List}
        ${ulsubcellSpool1List}   run Keyword if   '${subcellList_PhysicalCellId}' == '51' or '${subcellList_PhysicalCellId}' == '53'
        ...                  nps_trf_tools.extract_ull1sp_from_COAM    ${subcellList_CellId}   ${ulsubcellSpool1List}
        ...                         ELSE                set Variable             ${ulsubcellSpool1List}
    END
    # csamson : improve here the mapping subcellId <=> SubpoolId
    # using from syslog ${ull1spcells_syslog} from "Check UL and DL l1Subpool Assignment in Syslogs"
    ${notEmpty}    Run Keyword And Return Status    Should Not Be Empty     ${ull1spcells_syslog[4]}
    ${ulsubcellSpool0List}=    Run Keyword If     ${notEmpty}    Copy List     ${ull1spcells_syslog[4]}
    ...                          ELSE                            Copy List     ${ulsubcellSpool0List}
    ${notEmpty}    Run Keyword And Return Status    Should Not Be Empty     ${ull1spcells_syslog[4]}
    ${ulsubcellSpool1List}=    Run Keyword If     ${notEmpty}    Copy List     ${ull1spcells_syslog[5]}
    ...                          ELSE                            Copy List     ${ulsubcellSpool1List}
    [return]   ${ulsubcellSpool0List}   ${ulsubcellSpool1List}

Get dlsubcellid for cellId by cell with COAM
    [Documentation]     [PRIVATE]
    [Arguments]      ${oam_alias}    ${PhysicalCellId1}=50    ${PhysicalCellId2}=51
    ${cells_status}=    coam.get_cells_info    cell_type=nr     timeout=30    connection=${oam_alias}
    #  subCellList=['Subcell-0 (DL)', 'Subcell-0 (UL)', 'Subcell-3 (DL)', 'Subcell-3 (UL)', 'Subcell-4 (DL)', 'Subcell-5 (DL)']
    ${dlsubcellSpool0List}=  Create List
    ${dlsubcellSpool1List}=  Create List
    FOR    ${cell}    IN    @{cells_status}
        ${subcellList_CellId}=  set Variable    ${cell['subCellList']}
        ${subcellList_PhysicalCellId}=   set Variable     ${cell['physicalCellId']}
        run Keyword if   '${subcellList_PhysicalCellId}' == '50'     dated log    subcellList_Cell50 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '51'     dated log    subcellList_Cell51 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '52'     dated log    subcellList_Cell52 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '53'     dated log    subcellList_Cell53 = ${subcellList_CellId}
        ${dlsubcellSpool0List}   run Keyword if   '${subcellList_PhysicalCellId}' == '${PhysicalCellId1}'
        ...                  nps_trf_tools.extract_dll1sp_from_COAM    ${subcellList_CellId}   ${dlsubcellSpool0List}
        ...                         ELSE                set Variable             ${dlsubcellSpool0List}
        ${dlsubcellSpool1List}   run Keyword if   '${subcellList_PhysicalCellId}' == '${PhysicalCellId2}'
        ...                  nps_trf_tools.extract_dll1sp_from_COAM    ${subcellList_CellId}   ${dlsubcellSpool1List}
        ...                         ELSE                set Variable             ${dlsubcellSpool1List}
    END
    [return]   ${dlsubcellSpool0List}   ${dlsubcellSpool1List}

Get ulsubcellid for cellId by cell with COAM
    [Documentation]     [PRIVATE]
    [Arguments]      ${oam_alias}    ${PhysicalCellId1}=50    ${PhysicalCellId2}=51
    ${cells_status}=    coam.get_cells_info    cell_type=nr     timeout=30    connection=${oam_alias}
    #  subCellList=['Subcell-0 (DL)', 'Subcell-0 (UL)', 'Subcell-3 (DL)', 'Subcell-3 (UL)', 'Subcell-4 (DL)', 'Subcell-5 (DL)']
    ${ulsubcellSpool0List}=  Create List
    ${ulsubcellSpool1List}=  Create List
    FOR    ${cell}    IN    @{cells_status}
        ${subcellList_CellId}=  set Variable    ${cell['subCellList']}
        ${subcellList_PhysicalCellId}=   set Variable     ${cell['physicalCellId']}
        run Keyword if   '${subcellList_PhysicalCellId}' == '50'     dated log    subcellList_Cell50 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '51'     dated log    subcellList_Cell51 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '52'     dated log    subcellList_Cell52 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '53'     dated log    subcellList_Cell53 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '54'     dated log    subcellList_Cell54 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '55'     dated log    subcellList_Cell55 = ${subcellList_CellId}
        ${ulsubcellSpool0List}   run Keyword if   '${subcellList_PhysicalCellId}' == '${PhysicalCellId1}'
        ...                  nps_trf_tools.extract_ull1sp_from_COAM    ${subcellList_CellId}   ${ulsubcellSpool0List}
        ...                         ELSE                set Variable             ${ulsubcellSpool0List}
        ${ulsubcellSpool1List}   run Keyword if   '${subcellList_PhysicalCellId}' == '${PhysicalCellId2}'
        ...                  nps_trf_tools.extract_ull1sp_from_COAM    ${subcellList_CellId}   ${ulsubcellSpool1List}
        ...                         ELSE                set Variable             ${ulsubcellSpool1List}
    END
    [return]   ${ulsubcellSpool0List}   ${ulsubcellSpool1List}

Get dlsubcellid list for cellId by cell with COAM
    [Documentation]     [PRIVATE]
    [Arguments]      ${oam_alias}    ${PhysicalCellId1}=50
    ${cells_status}=    coam.get_cells_info    cell_type=nr     timeout=30    connection=${oam_alias}
    #  subCellList=['Subcell-0 (DL)', 'Subcell-0 (UL)', 'Subcell-3 (DL)', 'Subcell-3 (UL)', 'Subcell-4 (DL)', 'Subcell-5 (DL)']
    ${dlsubcellList}=  Create List
    ${non_dlsubcellList}=  Create List
    FOR    ${cell}    IN    @{cells_status}
        ${subcellList_CellId}=  set Variable    ${cell['subCellList']}
        ${subcellList_PhysicalCellId}=   set Variable     ${cell['physicalCellId']}
        run Keyword if   '${subcellList_PhysicalCellId}' == '50'     dated log    subcellList_Cell50 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '51'     dated log    subcellList_Cell51 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '52'     dated log    subcellList_Cell52 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '53'     dated log    subcellList_Cell53 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '54'     dated log    subcellList_Cell54 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '55'     dated log    subcellList_Cell55 = ${subcellList_CellId}
        ${dlsubcellList}   run Keyword if   '${subcellList_PhysicalCellId}' == '${PhysicalCellId1}'
        ...                  nps_trf_tools.extract_dll1sp_from_COAM    ${subcellList_CellId}   ${dlsubcellList}
        ...                         ELSE                set Variable             ${dlsubcellList}
        ${non_dlsubcellList}   run Keyword if   '${subcellList_PhysicalCellId}' != '${PhysicalCellId1}'
        ...                  nps_trf_tools.extract_dll1sp_from_COAM    ${subcellList_CellId}   ${non_dlsubcellList}
        ...                         ELSE                set Variable             ${non_dlsubcellList}
    END
    [return]   ${dlsubcellList}   ${non_dlsubcellList}

Get ulsubcellid list for cellId by cell with COAM
    [Documentation]     [PRIVATE]
    [Arguments]      ${oam_alias}    ${PhysicalCellId1}=50
    ${cells_status}=    coam.get_cells_info    cell_type=nr     timeout=30    connection=${oam_alias}
    #  subCellList=['Subcell-0 (DL)', 'Subcell-0 (UL)', 'Subcell-3 (DL)', 'Subcell-3 (UL)', 'Subcell-4 (DL)', 'Subcell-5 (DL)']
    ${ulsubcellList}=  Create List
    ${non_ulsubcellList}=  Create List
    FOR    ${cell}    IN    @{cells_status}
        ${subcellList_CellId}=  set Variable    ${cell['subCellList']}
        ${subcellList_PhysicalCellId}=   set Variable     ${cell['physicalCellId']}
        run Keyword if   '${subcellList_PhysicalCellId}' == '50'     dated log    subcellList_Cell50 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '51'     dated log    subcellList_Cell51 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '52'     dated log    subcellList_Cell52 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '53'     dated log    subcellList_Cell53 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '54'     dated log    subcellList_Cell54 = ${subcellList_CellId}
        run Keyword if   '${subcellList_PhysicalCellId}' == '55'     dated log    subcellList_Cell55 = ${subcellList_CellId}
        ${ulsubcellList}   run Keyword if   '${subcellList_PhysicalCellId}' == '${PhysicalCellId1}'
        ...                  nps_trf_tools.extract_ull1sp_from_COAM    ${subcellList_CellId}   ${ulsubcellList}
        ...                         ELSE                set Variable             ${ulsubcellList}
        ${non_ulsubcellList}   run Keyword if   '${subcellList_PhysicalCellId}' != '${PhysicalCellId1}'
        ...                  nps_trf_tools.extract_ull1sp_from_COAM    ${subcellList_CellId}   ${non_ulsubcellList}
        ...                         ELSE                set Variable             ${non_ulsubcellList}
    END
    [return]   ${ulsubcellList}   ${non_ulsubcellList}

# --------------------------------------------------------------------------------------------------------------------------------------------------
Get Number Of Ue Configured With GBR Traffic
    [Documentation]
    ...     Conditions:     it is based on the argument ${dict_ues}
    ...     Actions:        it returns the number of ue's configured with GBR traffic
    ...     Checks:         it checks that the requested GBR throughput for the ue's is different from 0
    ...     Verdict:        the number of ue's configured with GBR traffic is returned
    [Arguments]             ${dict_ues}

    ${current_value}        Set Variable        0
    FOR    ${current_ue}    IN      @{dict_ues}
        ${current_value}=     Run Keyword If    ${current_ue.DL_throughput_GBR} > ${NO_THROUGHPUT}
        ...                                               Evaluate    ${current_value} + 1
        ...                               ELSE            Evaluate    ${current_value} + 0
    END
    Dated Log               The number of ue's configured with GBR traffic is ${current_value}
    [Return]                ${current_value}

Check Multi Ues Setting In List
    [Documentation]
    ...     Conditions:     it is based on the argument ${multiUesList}
    ...     Actions:        it logs all the ue's settings
    ...     Checks:         it needs no checks
    ...     Verdict:        the ue's list is defined
    [Arguments]             ${multiUesList}=None

    ${NbOfUes}              get length     ${multiUesList}
    Dated Log New Line      ===> Check Multi Ues Setting In List number of ue's in list: NbOfUes=${NbOfUes}
    FOR    ${current_elem}    IN      @{multiUesList}
        Dated Log    serving cell=${current_elem.target_cells} on gnb=${current_elem.target_gnb} for ue=${current_elem.ue}
    END
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Capture #
Captures Init
    [Documentation]
    ...     Conditions:     it needs no conditions
    ...     Actions:        it configures the parameters to initialize the captures for L1L2, CORE and CPRT
    ...     Checks:         it needs no checks
    ...     Verdict:        the parameters for the captures are initialized

    ${CaptureL1L2}          Capture L1L2 Set Upon Config            airscale=${GNB_DU}
    ${CaptureCORE}          Run Keyword If    ${isAic}
    ...                                       Capture CORE Set Upon Config    airscale=${GNB_CU}
    ...                                 ELSE
    ...                                       Capture CORE Set Upon Config    airscale=${GNB_DU}
    ${CaptureCPRT}          Capture CPRT Set Upon Config            airscale=${GNB_DU}
    Capture Init            ${CaptureL1L2}                          withTN=True
    Capture Init            ${CaptureCORE}                          withTN=True
    Capture Init            ${CaptureCPRT}                          withTN=True
    Set Suite Variable      ${CaptureL1L2}
    Set Suite Variable      ${CaptureCORE}
    Set Suite Variable      ${CaptureCPRT}

Captures Start
    [Documentation]
    ...     Conditions:     it is based on the arguments ${actionCORE} ${actionCPRT} ${actionL1L2}
    ...     Actions:        it starts the captures for L1L2 and/or CORE and/or CPRT depends on an argument
    ...     Checks:         it needs no checks
    ...     Verdict:        the captures are started
    [Arguments]             ${actionCORE}=${False}    # Capture CORE is not started by default
    ...                     ${actionCPRT}=${False}    # Capture CPRT is not started by default
    ...                     ${actionL1L2}=${False}    # Capture L1L2 is not started by default

    Run Keyword If          ${actionCORE}    Capture Start          capture=${CaptureCORE}
    Run Keyword If          ${actionCPRT}    Capture Start          capture=${CaptureCPRT}
    Run Keyword If          ${actionL1L2}    Capture Start          capture=${CaptureL1L2}

Captures Stop
    [Documentation]
    ...     Conditions:     it is based on the arguments ${actionCORE} ${actionCPRT} ${actionL1L2}
    ...     Actions:        it stops the captures for L1L2 and/or CORE and/or CPRT depending on an argument
    ...     Checks:         it needs no checks
    ...     Verdict:        the captures are stopped
    [Arguments]             ${actionCORE}=${True}     # Capture CORE is stopped by default
    ...                     ${actionCPRT}=${True}     # Capture CPRT is stopped by default
    ...                     ${actionL1L2}=${True}     # Capture L1L2 is stopped by default

    Run Keyword If          ${actionL1L2}    Run Keyword And Ignore Error    Capture Stop       capture=${CaptureL1L2}
    Run Keyword If          ${actionCORE}    Run Keyword And Ignore Error    Capture Stop       capture=${CaptureCORE}
    Run Keyword If          ${actionCPRT}    Capture Stop           capture=${CaptureCPRT}

# --------------------------------------------------------------------------------------------------------------------------------------------------
# Traffic #
DL Traffic SA Not Stopped with "${throughput}"Mbps "${duration}"s duration and "${deviation}" percent deviation with "${protocol}" protocol
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${ueSetting}
    ...     Actions:        it manages the DL traffic on the UE
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        DL traffic is passed

    Set To Dictionary       ${current_elem}        trf_id    ${current_elem.ue}
    Traffic UE DL           ueSetting=${current_elem}
    ...                               throughput=${throughput}
    ...                               captureCallback=None
    ...                               capture=None
    ...                               captureDuration=0
    ...                               duration=${duration}
    ...                               shouldBeStop=False
    ...                               shouldBeCheck=False
    ...                               deviation=${deviation}
    ...                               size=${current_elem.size}
    ...                               protocol=${protocol}

UL Traffic SA Not Stopped with "${throughput}"Mbps "${duration}"s duration and "${deviation}" percent deviation with "${protocol}" protocol
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${ueSetting}
    ...     Actions:        it manages the DL traffic on the UE
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        DL traffic is passed

    Set To Dictionary       ${current_elem}        trf_id    ${current_elem.ue}
    Traffic UE UL           ueSetting=${current_elem}
    ...                               throughput=${throughput}
    ...                               captureCallback=None
    ...                               capture=None
    ...                               captureDuration=0
    ...                               duration=${duration}
    ...                               shouldBeStop=False
    ...                               shouldBeCheck=False
    ...                               deviation=${deviation}
    ...                               protocol=${protocol}

DL Traffic GBR SA Not Stopped with "${throughput}"Mbps "${duration}"s duration and "${deviation}" percent deviation
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${nbOfUe} ${ueSetting}
    ...     Actions:        it manages the DL traffic GBR on the UE
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        DL traffic is passed

    # Step 1 on qfi=2 with protocol tcp
    Set To Dictionary       ${current_elem}        trf_id    2
    Set To Dictionary       ${current_elem}        qfi       2
    Traffic UE DL           ueSetting=${current_elem}
    ...                               throughput=${current_elem.DL_throughput_GBR}
    ...                               captureCallback=None
    ...                               capture=None
    ...                               captureDuration=0
    ...                               duration=${duration}
    ...                               shouldBeStop=False
    ...                               shouldBeCheck=False
    ...                               deviation=${deviation}
    ...                               protocol=tcp
    # Step 2 on qfi=3 with protocol udp
    Set To Dictionary       ${current_elem}        trf_id    3
    Set To Dictionary       ${current_elem}        qfi       3
    Traffic UE DL           ueSetting=${current_elem}
    ...                               throughput=${current_elem.DL_throughput_GBR}
    ...                               captureCallback=None
    ...                               capture=None
    ...                               captureDuration=0
    ...                               duration=${duration}
    ...                               shouldBeStop=False
    ...                               shouldBeCheck=False
    ...                               deviation=${deviation}
    ...                               protocol=udp

# --------------------------------------------------------------------------------------------------------------------------------------------------
Fetch common OAM SW version
    [Documentation]    :
    ...    Only used by KW "Fetch Current gNB SW Version"
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0  ${bts_host}=${EMPTY}  ${w_Display}=False
    ${gnb_sw_version}=    admin.get_sw_version    connection=coam_gnb
    ${gnb_sw_version}=    nps_trf_tools.reform_coam_sw_version    ${gnb_sw_version}
    set global variable    ${current_gNB_sw_version}      ${gnb_sw_version}
    ${msg}=   Run Keyword If   '${w_Display}'=='True'   StringTool.getHeaderLine    Fetch Current gNB SW Version:   ${gnb_sw_version}
    Run Keyword If   '${w_Display}'=='True'   StringTool.printLineWithTitle   -
    Run Keyword If   '${w_Display}'=='True'   Dated log             ${msg}
    Run Keyword If   '${w_Display}'=='True'   StringTool.printLineWithTitle   -
    [Return]    ${gnb_sw_version}

Fetch common OAM SW version 1
    [Documentation]    :
    ...    Only used by KW "Fetch Current gNB SW Version"
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0  ${bts_host}=${EMPTY}  ${w_Display}=False
    ${bts_host}=  Set Variable if  '${bts_host}'=='${EMPTY}'  ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}  ${bts_host}
    # admin.connect_to    bts_host=${bts_host}    name=gnb
    admin.setup_admin    bts_host=${bts_host}    name=gnb
    ${gnb_sw_version}=    admin.get_sw_version    connection=gnb
    admin.teardown    connection=gnb
    ${gnb_sw_version}=    nps_trf_tools.reform_coam_sw_version    ${gnb_sw_version}
    set global variable    ${current_gNB_sw_version}      ${gnb_sw_version}
    ${msg}=   Run Keyword If   '${w_Display}'=='True'   StringTool.getHeaderLine    Fetch Current gNB SW Version:   ${gnb_sw_version}
    Run Keyword If   '${w_Display}'=='True'   StringTool.printLineWithTitle   -
    Run Keyword If   '${w_Display}'=='True'   Dated log             ${msg}
    Run Keyword If   '${w_Display}'=='True'   StringTool.printLineWithTitle   -
    [Return]    ${gnb_sw_version}


Get TTI traces
    [Arguments]     ${suffix}=${EMPTY}   ${time}=1s    ${event_nr_max}=30000   ${w_convert_pcap_to_excelCsv}=True
    Dated Log         ======> Get TTI traces
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
    Run Keyword And Ignore Error   OperatingSystem.Run
    ...                                 cp ${testCaseDir}/${ttiTraceSubDir}/msg_all.csv ${testCaseDir}/${ttiTraceSubDir}/msg-all-${time}-${tm}.csv
    run keyword if   '${w_convert_pcap_to_excelCsv}'=='True'    run keywords
    ...               Dated log    Convert TTI trace from pcap to excelCsv...    AND
    ...               Run keyword and continue on failure     ttitrace.Convert TTI trace from pcap to excelCsv     input_file_path=${tti_trace_path}
    ...                                                                    output_file_path=${testCaseDir}/${ttiTraceSubDir}
    [return]     ${testCaseDir}/${ttiTraceSubDir}

Start TTI traces
    Dated Log         ======> Start TTI traces
    Dated Log         Start TTI Traces in Streaming Mode
    ttitrace.Start TTI Traces in Streaming Mode      filter_bitmap2=0x0

Stop and Get TTI traces
    [Arguments]     ${suffix}=${EMPTY}    ${event_nr_max}=30000   ${w_convert_pcap_to_excelCsv}=False    ${w_decoding}=False
    Dated Log         ======> Get TTI traces
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .
    Dated log         Stop TTI Traces in Streaming Mode...
    ${ttiTraceSubDir}   set Variable    TtiTrace-${tm}
    ${ttiTraceSubDir}   set Variable if    '${suffix}'!='${EMPTY}'     ${ttiTraceSubDir}-${suffix}
    ...                                                                ${ttiTraceSubDir}
    ${tti_trace_path}=     ttitrace.Stop TTI Traces in Streaming Mode    tti_trace_path=${testCaseDir}/${ttiTraceSubDir}

    Run Keyword If     '${w_decoding}' == 'True'     Decoding TTI traces    desired_storage_directory=${testCaseDir}/${ttiTraceSubDir}

    run keyword if   '${w_convert_pcap_to_excelCsv}'=='True' and '${w_decoding}'=='True'    run keywords
    ...               Dated log    Convert TTI trace from pcap to excelCsv...    AND
    ...               Run keyword and continue on failure     ttitrace.Convert TTI trace from pcap to excelCsv     input_file_path=${tti_trace_path}
    ...                                                                    output_file_path=${testCaseDir}/${ttiTraceSubDir}
    declare Trace in Trace List  Type=TtiTrace   Savedir=${testCaseDir}/${ttiTraceSubDir}
    ...                          file_name=ttitrace_streaming.pcap   Trigger=Test
    [return]     ${testCaseDir}/${ttiTraceSubDir}

Decoding TTI traces
    [Arguments]     ${desired_storage_directory}=${EMPTY}    ${event_nr_max}=30000
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .
    Dated log         Decode TTI Traces...
    nps_ttitraces_tools.decode_tti_traces_using_TtitraceReaderEvtDec       desired_storage_directory=${desired_storage_directory}
    ...                                                                    num_of_events=${event_nr_max}
    Run Keyword And Ignore Error   OperatingSystem.Run
    ...                                 cp ${desired_storage_directory}/msg_all.csv ${desired_storage_directory}/msg-all-${tm}.csv

Get L1L2 traces
    [Arguments]     ${time}=1s   ${prefix}=DL_UL_Tput  ${msg}=take BIP L1L2 traces with DL/UL Tput
    Dated Log         ======> Get L1L2 Bip Traces
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}
    ${CaptureBIP}              Capture L1L2 Set Upon Config             airscale=${GNB_DU}
    ${testCase}    Replace String    ${TEST_NAME[0:20]}    ${SPACE}    _
    ${testCase}    Replace String    ${testCase}    .    _
    ${testCase}    Remove String     ${testCase}    [1]
    ${testCase}    Remove String     ${testCase}    [1.0]
    ${testCase}    Remove String     ${testCase}    [2.0]
    ${testCase}    Remove String     ${testCase}    [
    ${testCase}    Remove String     ${testCase}    ]
    ${CaptureBIP.prefix}       set Variable   ${prefix}.${testCase}.${tm}
    ${CaptureBIP.withTN}       set Variable   False
    # not needed with L1L2Bip pcap using WEBEM
    # ${CaptureBIP.filter}       set variable   ether[12:2]=0x8951 or ether[16:2]=0x8951

    Capture Init   ${CaptureBIP}
    Capture start  ${CaptureBIP}
    Traced Sleep   ${time}     msg=${msg}
    dated log    => BEWARE that L1L2Bip Traces can take a long time...
    Capture stop   ${CaptureBIP}
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${CaptureBIP.path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${CaptureBIP.path}    ${testCaseDir}
    Run Keyword And Ignore Error    declare Trace in Trace List  Type=L1L2Bip   Savedir=${testCaseDir}
    ...                                                          file_name=${CaptureBIP.name}.pcap    Trigger=${prefix}
    [Return]    ${testCaseDir}/${CaptureBIP.name}

Start L1L2 traces
    [Arguments]    ${prefix}=DL_UL_Tput
    Dated Log         ======> Get L1L2 Bip Traces
    ${tm}    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}
    ${CaptureBIP}              Capture L1L2 Set Upon Config             airscale=${GNB_DU}
    ${testCase}    Replace String    ${TEST_NAME[0:20]}    ${SPACE}    _
    ${testCase}    Replace String    ${testCase}    .    _
    ${testCase}    Remove String     ${testCase}    [1]
    ${testCase}    Remove String     ${testCase}    [1.0]
    ${testCase}    Remove String     ${testCase}    [2.0]
    ${testCase}    Remove String     ${testCase}    [
    ${testCase}    Remove String     ${testCase}    ]
    ${CaptureBIP.prefix}       set Variable   ${prefix}.${testCase}.${tm}
    ${CaptureBIP.withTN}       set Variable   False
    Capture Init   ${CaptureBIP}
    Capture start  ${CaptureBIP}
    [Return]    ${CaptureBIP}

Stop L1L2 traces
    [Arguments]    ${CaptureBIP}
    Dated Log         ======> Stop L1L2 Bip Traces
    dated log    => BEWARE that L1L2Bip Traces can take a long time...
    Capture stop   ${CaptureBIP}
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${CaptureBIP.path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${CaptureBIP.path}    ${testCaseDir}
    Run Keyword And Ignore Error    declare Trace in Trace List  Type=L1L2Bip   Savedir=${testCaseDir}
    ...                                                          file_name=${CaptureBIP.name}.pcap    Trigger=Test
    [Return]    ${testCaseDir}/${CaptureBIP.name}

teardownP1
    dated log    =======> Test Teardown : Collecting logs...
    Run Keyword And Ignore Error     TARF-Keywords.Collect EGATE console Logs     all=${False}

    # Save current SCF file used during test cases
    ${current_scf_file}      COAM Get SCF     local_dir_path=${testCaseDir}   file=SCF_used_for_${FeatureId}_Tests.xml     alias=coam_gnb
    Set Suite Variable              ${current_scf_file}
    Dated Log New Line         Current ${FeatureId} SCF file stored to ${current_scf_file}

    # Get swconfig file used during tests
    # ${ret}   ${alias_gnb}           Run Keyword And Ignore Error         SSH Wait For Connect                ${GNB_DU.sys[0].M}
    ${ret}   ${alias_gnb}           Run Keyword And Ignore Error       connect.Connect to Node Common Unit
    Run Keyword And Ignore Error       csn.download_file               remote_path=${SWCONFIG_PATH}
    ...                             local_path=${testCaseDir}/swconfig_used_for_${FeatureId}_Tests.txt
    ...                             connection=${alias_gnb}
    Dated Log                  Current ${FeatureId} swconfig file stored to ${testCaseDir}/swconfig_used_for_${FeatureId}_Tests.txt

    # Get vendor file used during tests
    ${ret}   ${curent_vendor_file_list}   Run Keyword And Ignore Error      SetConfig.Download Vendor File
    ${cmd}=   Catenate    basename ${curent_vendor_file_list}[0]
    ${curent_vendor_file_name}=   OperatingSystem.Run   ${cmd}
    ${curent_vendor_file_name}      Remove String      ${curent_vendor_file_name}     _ori.xml
    ${curent_vendor_file_name}      Remove String      ${curent_vendor_file_name}     .xml
    Run Keyword And Ignore Error    OperatingSystem.Copy File       ${curent_vendor_file_list}[0]
    ...                                                             ${testCaseDir}/${curent_vendor_file_name}_used_for_${FeatureId}_Tests.xml
    Dated Log               -----> Current Vendor File Name : ${testCaseDir}/${curent_vendor_file_name}_used_for_${FeatureId}_Tests.xml

    # Get EPC file configuration used during tests
    ${alias_epc}                    SSH Wait For Connect                ${HOST_EPCSIM}
    csn.download_file               remote_path=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                             local_path=${testCaseDir}/basic_wts_used_for_${FeatureId}_Tests.cfg
    ...                             connection=${alias_epc}

    # Get AP configuration file used during tests
    ${ap_configfile}                Get XML AirPhoneConfig Path
    run Keyword if      '${ap_configfile}' != '${empty}'     csn.download_file     remote_path=${tl.core.dir_path}/${ap_configfile}
    ...                             local_path=${testCaseDir}/ApOamConfig_used_for_${FeatureId}_Tests.xml
    ...                             connection=${alias_epc}

    ${msg}=   Catenate    Current ${FeatureId} basic file ${tl.core.cfg_filename} stored
    ...                      to ${testCaseDir}/basic_wts_used_for_${FeatureId}_Tests.cfg
    Dated Log    ${msg}
    Dated Log  Current ${FeatureId} ApOamConfig file stored to ${testCaseDir}/ApOamConfig_used_for_${FeatureId}_Tests.xml

    # get Alarm at the end of the test and store it into a file
    Dated log New Line  OAM Get Active Alarms to Save into file
    # ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}

    # ${active_alarms}     OAM Get Active Alarms                   oam=${GNB_DU.oam}       textFormat=${False}
    ${active_alarms}     admin.get_active_alarms    connection=coam_gnb

    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    ${alarm_name_list}    Create List
    ${faultId}=     set variable if    ${isAiC}        fault_id
    ...                                                faultId
    ${faultName}=     set variable if    ${isAiC}      fault_name
    ...                                                faultName

    FOR    ${i}    IN RANGE    ${len}
         ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    ${faultId}
         ${tmp_name_id}    Get From Dictionary    ${active_alarms[${i}]}    ${faultName}
         Append To List    ${alarm_id_list}    ${tmp_id}
         Append To List    ${alarm_name_list}    ${tmp_name_id}
    END
    # Dated log     Active alarms: alarm_id_list=${alarm_id_list}
    # Dated log     Active alarms: alarm_name_list=${alarm_name_list}

    Append To File    ${testCaseDir}/OAM_Alarms_After_${TEST_NAME}.txt     Active Alarms Id List:\n${alarm_id_list}\n\n
    Append To File    ${testCaseDir}/OAM_Alarms_After_${TEST_NAME}.txt     Active Alarms Name List:\n${alarm_name_list}\n\n

    # OAM Disconnect                          ${GNB_DU.oam}

    Dated Log         Collect /ram/startup_l3.log and egate_console.log from Airphone...
    testcase-Keywords.Prepare Logs Directory Path    subdir=airphone
    Run Keyword And Ignore Error      TARF-Keywords.Collect EGATE console Logs
    Run keyword and Ignore error      TARF-Keywords.Get APL3 log from Airphone        target_dir=${testCaseDir}/airphone

    Dated Log         Collect /ffs/run/simmode/iphy.xml from Airphone...
    Run keyword and Ignore error      TARF-Keywords.Get iPhy.xml file from Airphone   target_dir=${testCaseDir}/airphone

    Dated Log         Collect /ffs/run/swconfig.txt from Airphone...
    Run keyword and Ignore error      Get SWCONFIG file from Airphone   target_dir=${testCaseDir}/airphone

    # Get EPC file configuration used during tests
    ${alias_epc}                    SSH Wait For Connect                ${HOST_EPCSIM}
    ${LuaFileName_generated}=    catenate    SEPARATOR=    ${tl.core.cfg_filename.replace(".cfg",".lua")}
    run keyword and ignore error     csn.download_file          remote_path=${tl.core.dir_path}/${LuaFileName_generated}
    ...                             local_path=${testCaseDir}/basic_wts_used_for_${FeatureId}_Tests.lua
    ...                             connection=${alias_epc}
    dated log    =======> Test Teardown : End Of Collecting logs...

teardownP2
    TARF-Keywords.Collect Logs if needed
    set Suite Variable    ${testCaseDir}    None

CleanBasicFiles
    [Documentation]         At the end of the test, this KW erase all Sweng adding arround basic cfg/lua
    Dated Log               ERASE LUA FILES from previous test
    ${alias}                SSH Connect           ${HOST_EPCSIM}
    ${myCommand}=           set variable          rm -f /opt/iphy/latest/basic*step2*.*;rm -rf /tmp/ute/
    ${result}=              SSH Exec              command=${myCommand}
    ...                                           alias=${alias}
    Dated Log               result=${result}

CleanUpSysLogs
    [Documentation]
    Dated Log               CleanUp Syslog from previous test
    ${commandToRun}     Catenate     rm -rf /tmp/btslog2/SYSLOG*.LOG
    ${ret}    ${results}     Run Keyword And Ignore Error    Run   ${commandToRun}
    Run Keyword if   '${ret}' == 'PASS'     dated log    ${consTraceColor}Syslog are removed${defColor}
    ...    ELSE                             dated log    ${consTraceColor}No Syslog present !!!${defColor}

Collect EGATE console Logs
    [Documentation]    This keyword is used to collect egate_console.log from the /opt/wts/latest/ folder
    ...                This is collected in the Test Log Folder
    [Arguments]       ${target_dir}=None    ${airphone_local_dir}=airphone    ${all}=${True}
    ${local_target_dir}=    Run Keyword If    '${target_dir}'=='None'    testcase-Keywords.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}

    ute_wtssim.setup_egate      egate_port=${tl.core.egate_port}
    ...                         host_ip=${tl.core.default_ssh_connection_details.addr}
    ...                         tool_dir=${tl.core.dir_path}
    ...                         alias=ap_egate
    ...                         ssh_user=ute
    ...                         ssh_pass=ute
    ute_wtssim.execute egate command         cmd=sim_log_set flush  timeout=1s  alias=ap_egate
    ute_wtssim.teardown_egate    alias=ap_egate

    # Connect to LTEEMU   alias=lteemu_alias
    ${alias}        SSH Connect   host=${HOST_EPCSIM}

    Dated Log      Collecting ${tl.core.dir_path}/egate_console.log...
    csn.download_file               remote_path=${tl.core.dir_path}/egate_console.log
    ...                             local_path=${local_target_dir}/egate_console.log
    ...                             connection=${alias}
    Dated Log                  egate_console.log file stored to ${local_target_dir}

    return From Keyword if    not ${all}

    Dated Log      Collecting ${tl.core.dir_path}/uec_1.log...
    csn.download_file               remote_path=${tl.core.dir_path}/uec_1.log
    ...                             local_path=${local_target_dir}/${airphone_local_dir}/uec_1.log
    ...                             connection=${alias}
    Dated Log                  uec_1.log file stored to ${local_target_dir}/${airphone_local_dir}

    Dated Log      Collecting ${tl.core.dir_path}/enb_1.log...
    csn.download_file               remote_path=${tl.core.dir_path}/enb_1.log
    ...                             local_path=${local_target_dir}/${airphone_local_dir}/enb_1.log
    ...                             connection=${alias}
    Dated Log                  enb_1.log file stored to ${local_target_dir}/${airphone_local_dir}

    Dated Log      Collecting ${tl.core.dir_path}/amf_1.log...
    csn.download_file               remote_path=${tl.core.dir_path}/amf_1.log
    ...                             local_path=${local_target_dir}/${airphone_local_dir}/amf_1.log
    ...                             connection=${alias}
    Dated Log                  amf_1.log file stored to ${local_target_dir}/${airphone_local_dir}

    Dated Log      Collecting ${tl.core.dir_path}/mme_1.log...
    csn.download_file               remote_path=${tl.core.dir_path}/mme_1.log
    ...                             local_path=${local_target_dir}/${airphone_local_dir}/mme_1.log
    ...                             connection=${alias}
    Dated Log                  mme_1.log file stored to ${local_target_dir}/${airphone_local_dir}

    Dated Log      Collecting ${tl.core.dir_path}/pgw_1.log...
    csn.download_file               remote_path=${tl.core.dir_path}/pgw_1.log
    ...                             local_path=${local_target_dir}/${airphone_local_dir}/pgw_1.log
    ...                             connection=${alias}
    Dated Log                  pgw_1.log file stored to ${local_target_dir}/${airphone_local_dir}
    Dated Log      Collecting ${tl.core.dir_path}/pgw_1.log...

    csn.download_file               remote_path=${tl.core.dir_path}/upf_1.log
    ...                             local_path=${local_target_dir}/${airphone_local_dir}/upf_1.log
    ...                             connection=${alias}
    Dated Log                  upf_1.log file stored to ${local_target_dir}/${airphone_local_dir}

Get APL3 log from Airphone
    [Documentation]    :Author: Ch SAMSON
    ...
    ...     :param ue_id:         Id of gnb                       [0.. ]  default=0
    ...     :param comu_id:       Id of Common Unit               [0..1]  default=0
    ...     :param target_dir:    (default None) save swconfig to path
    ...
    ...     :return:   startup_l3_log for further usage
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testcase-Keywords.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${ap_alias}=    connect.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    Dated log                       Check the startup_l3.log file: zipped or not zipped
    ssh.send command    ls -ltr /ram/startup_l3.log.xz   connection=${ap_alias}
    ${output_1}=    ssh.read output   connection=${ap_alias}
    ssh.send command    ls -ltr /ram/startup_l3.log   connection=${ap_alias}
    ${output_2}=    ssh.read output   connection=${ap_alias}
    ${lenght_1}                     Get Length                              ${output_1}
    ${length_2}                     Get Length                              ${output_2}
    Dated log                       AP startup_l3 length_xz:${lenght_1} - lenght_non_xz:${length_2}
    ${APL3_log}=    Set Variable If                 ${lenght_1} != 0                        startup_l3.log.xz
    ...                                             ${length_2} != 0                        startup_l3.log
    ...                                                                                     startup_l3.log
    ssh.Download File    remote_path=/ram/${APL3_log}    local_path=${target_dir}/ap_${APL3_log}    connection=${ap_alias}
    ssh.disconnect     ${ap_alias}
    [Return]    ${target_dir}/ap_${APL3_log}

Get iPhy.xml file from Airphone
    [Documentation]    :Author: Ch SAMSON
    ...
    ...     :param ue_id:         Id of gnb                       [0.. ]  default=0
    ...     :param comu_id:       Id of Common Unit               [0..1]  default=0
    ...     :param target_dir:    (default None) save swconfig to path
    ...
    ...     :return:   swconfig path for further usage
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${target_dir}=None    ${file_name}=ap_iphy.xml
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testcase-Keywords.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${ap_alias}=    connect.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    # WARNING : need to adapt new_iphy.xml  => iphy.xml  for AiC tests !!!
    # ${iphy_filename}     set variable if     ${isAiC}       iphy.xml
    # ...                                                     new_iphy.xml
    ${iphy_filename}     set variable     iphy.xml
    ssh.Download File    remote_path=/ffs/run/simmode/${iphy_filename}    local_path=${target_dir}/${file_name}    connection=${ap_alias}
    ssh.disconnect     ${ap_alias}
    [Return]    ${target_dir}/${file_name}

Restore iPhy.xml file to Airphone
    [Documentation]    :Author: Ch SAMSON
    ...
    ...     :param ue_id:         Id of gnb                       [0.. ]  default=0
    ...     :param comu_id:       Id of Common Unit               [0..1]  default=0
    ...     :param target_dir:    (default None) save swconfig to path
    ...
    ...     :return:   swconfig path for further usage
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${local_dir}=None    ${file_name}=ap_new_iphy.xml
    ${local_dir}=    Run Keyword If    '${local_dir}'=='None'    testcase-Keywords.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${local_dir}
    ${ap_alias}=    connect.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    ${iphy_filename}     set variable    iphy.xml
    ssh.upload File    local_path=${local_dir}/${file_name}    remote_path=/ffs/run/simmode/${iphy_filename}       connection=${ap_alias}
    ssh.disconnect     ${ap_alias}
    [Return]    ${local_dir}/${file_name}

Get SWCONFIG file from Airphone
    [Documentation]    :Author: Ch SAMSON
    ...
    ...     :param ue_id:         Id of gnb                       [0.. ]  default=0
    ...     :param comu_id:       Id of Common Unit               [0..1]  default=0
    ...     :param target_dir:    (default None) save swconfig to path
    ...
    ...     :return:   swconfig path for further usage
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${target_dir}=None    ${file_name}=ap_swconfig.txt
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testcase-Keywords.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${ap_alias}=    connect.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    ${swconfig_filename}     set variable       swconfig.txt
    ssh.Download File    remote_path=/ffs/run/${swconfig_filename}    local_path=${target_dir}/${file_name}    connection=${ap_alias}
    ssh.disconnect     ${ap_alias}
    [Return]    ${target_dir}/${file_name}

Store Current swconfig from Airphone
    [Documentation]    :
    ...    in case testcase needs to modify swconfig.txt on Airphone, collect current one as backup, Set path as Suite Variable ${P_ORIG_AP_SWCONFIG}
    ...
    ...    :param ue_id:      Id of ue                       [0.. ]  default=0
    ...    :param comu_id:    Id of Common Unit              [0..1]  default=0
    ...    :param target_dir: where to save original swconfig.txt, default with testline.Get Test Suite Config Directory
    ...
    ...    **Example:**
    ...    | Store Current swconfig from Airphone
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${target_dir}=None   ${file_name}=ap_swconfig.txt
    ${ORIG_SWCONFIG}=    Get SWCONFIG file from Airphone    ue_id=${0}    comu_id=${0}    target_dir=${target_dir}
    Run    mv ${ORIG_SWCONFIG} ${ORIG_SWCONFIG}.orig
    Set Suite Variable    ${P_ORIG_AP_SWCONFIG}    ${ORIG_SWCONFIG}.orig
    [Return]    ${ORIG_SWCONFIG}.orig


Collect all logs
    [Documentation]      Get GNB Logs from Coam. Files are put inside testCaseDir directory
    [Arguments]                 ${alias}=${HOST_EPCSIM.alias}

    ${COLLECT_LOGS}           Set Variable if
    ...                       "${TEST STATUS}" == "FAIL" and "${EXCLUDE_LOGS_IF_FAIL}" == "0"
    ...                       1    ${COLLECT_LOGS}

    Return From Keyword If    "${COLLECT_LOGS}" == "0"

    Dated Log         Collect WTS logs...
    testcase-Keywords.Prepare Logs Directory Path    subdir=wts
    TARF-Keywords.Collect WTS log files       target_dir=${testCaseDir}/wts

    return from Keyword if     '${ENABLE_TEST_TEARDOWN}'=='0'

    # BTS snapshot.
    Dated Log New Line         Get gNB snapshot...
    ${snapshot_path}     TARF-Keywords.Get GNB Logs from Coam
    testcase-Keywords.Prepare Logs Directory Path    subdir=snapshot
    ${status}   ${ret}   Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${snapshot_path}
    run Keyword if   '${status}'=='PASS'     Run Keyword And Ignore Error    OperatingSystem.Move File    ${snapshot_path}   ${testCaseDir}/snapshot
    run Keyword if   '${status}'=='PASS'     Dated Log     gNB snapshot ${snapshot_path} generated and copied into ${testCaseDir}/snapshot

    ${status}   ${snapshot_ims2_path}     Run Keyword And Ignore Error      TARF-Keywords.Collect IMS2 Coam
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${snapshot_ims2_path}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${snapshot_ims2_path}    ${testCaseDir}/snapshot
    Dated Log     gNB snapshot IMS2 ${snapshot_ims2_path} generated and copied into ${testCaseDir}/snapshot

    testcase-Keywords.Prepare Logs Directory Path    subdir=ap_sosreport
    Dated Log         Collect Current swconfig from Airphone...
    TARF-Keywords.Store Current swconfig from Airphone     target_dir=${testCaseDir}/ap_sosreport
    Dated Log          Collect Airphone Logs...
    TARF-Keywords.Collect sos report logs   target_dir=${testCaseDir}/ap_sosreport
    Dated Log     Sos report finished

Get GNB Logs from Coam
    [Arguments]    ${resultDir}=None   ${subdir}=${EMPTY}    ${with_timestamp}=${TRUE}
    return from Keyword if     ${isAiC}    ${EMPTY}
    ${resultDir}=    Run Keyword If    '${resultDir}'=='None'    testcase-Keywords.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${resultDir}
    ${logs_dir}   set variable     ${resultDir}/${subdir}
	coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
	${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${snapshot_path}=    run keyword if   '${with_timestamp}'=='${TRUE}'   set variable  ${logs_dir}/Snapshot_GNB_${timestamp}.zip
    ...    ELSE                                                            set variable  ${logs_dir}/Snapshot_GNB.zip
    coam.get_snapshot     target_file_name=${snapshot_path}    timeout=720    connection=coam_admin
    [Teardown]  run Keyword if   not ${isAiC}    coam.teardown    connection=coam_admin
    [Return]         ${snapshot_path}

Collect IMS2 Coam
    return from Keyword if   ${isAiC}
	coam.connect to   bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}   name=coam_admin
	${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${snapshot_path}=    set variable  ${LOG_PATH}/Snapshot_GNB_IMS2_${timestamp}.zip
    Run Keyword And Ignore Error    admin.collect_im_snapshot
    ...                             target_file_name=${snapshot_path}
    ...                             timeout=720
    ...                             connection=coam_admin
    [Teardown]  coam.teardown    connection=coam_admin
    [Return]         ${snapshot_path}

Get GNB Snapshot
    [Arguments]
    Dated log     get gNB snapshot...
    testcase-Keywords.Prepare Logs Directory Path    subdir=snapshot
    ${snapshot_path}    run Keyword     Get GNB Logs from Coam     subdir=snapshot
    Dated Log     gNB snapshot ${snapshot_path} generated

Get Gnb Snapshot if TestCase Failed
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${Gnb_Snapshot_if_TestCase_Failed}
    ${Gnb_Snapshot_if_TestCase_Failed}  set Variable if    '${status}'=='FAIL'    1
    ...                                                                           ${Gnb_Snapshot_if_TestCase_Failed}
    return from Keyword if   '${TEST STATUS}' != 'FAIL'
    return from Keyword if   '${Gnb_Snapshot_if_TestCase_Failed}' == '0'
    BuiltIn.Log      \nTest ${TEST_NAME} TestCase Failed ending   console=yes
    Run Keyword And Continue On Failure     Get GNB Snapshot

Connect to Core
    [Documentation]    :
    ...     setup ssh connection core and returns connection handle/alias
    ...     KW sould be called without arguments
    ...
    ...     :param alias: (optional) alias used for ssh connection
    ...
    ...     :return alias: alias for ssh connection to OAM
    ...
    [Arguments]    ${alias}=ssh-core
    ssh.Connect_to      hostname=${tl.core.default_ssh_connection_details.addr}
    ...                 username=${tl.core.default_ssh_connection_details.username}
    ...                 password=${tl.core.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]    ${alias}

Convert local PCAP to PDML
    [Documentation]
    ...
    ...    | source             | Path to the pcap file that has to be converted to pdml |
    ...    | target             | Path where the converted pdml file has to be stored |
    ...    | filter             | Define message filter  eg. "dldata_csirssendreq || uldata_pucchreceivereq || uldata_pucchreceiverespps" |
    ...    | option             | User defined options for tshark can be included here |
    ...
    [Arguments]  ${source}  ${target}  ${filter}=${EMPTY}  ${option}=${EMPTY}

    ${filter_arg}=    Set variable if    '${filter}'!='${EMPTY}'    -Y ${filter}    ${EMPTY}
    ${command}=  Set Variable      tshark -r "${source}" ${option} -T pdml ${filter_arg} >"${target}_"
    OperatingSystem.Run  ${command}
    nps_trf_tools.strip headers  source_file=${target}_  target_file=${target}
    OperatingSystem.Run  sudo rm ${target}_

Get latest modified file with defined pattern
    [Documentation]    :
    ...    It returns the latest modified file from a specified directory
    ...
    ...    :param path:    Path of directory to get the files
    ...    :param pattern: Optional matching pattern (default: ${EMPTY})
    ...
    ...    :returns lastModifiedFile: Latest modified file
    ...
    [Arguments]    ${path}    ${pattern}=${EMPTY}
    ${files}=    OperatingSystem.List files in directory    path=${path}    pattern=${pattern}
    ${lastModifiedFile}=    Get from list    ${files}    0
    ${time1}=    OperatingSystem.Get modified time    ${path}//${lastModifiedFile}    epoch
    FOR    ${file}    IN    @{files}
        ${time}=    Get modified time    ${path}//${file}    epoch
        ${lastModifiedFile}=    Set variable if    ${time1} < ${time}    ${file}    ${lastModifiedfile}
    END
    [Return]    ${lastModifiedFile}

Collect sos report logs
    [Documentation]
    ...    Sos report logs are needed in case of opening airphone pronto
    ...
    ...    :param target_dir:   directory to store the journal file
    ...    :param script_path:  path where sosReport.sh is located (default: ${tl.core.dir_path})
    ...
    [Arguments]    ${target_dir}=None    ${script_path}=${tl.core.dir_path}
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testcase-Keywords.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    # Call Get Sos Report from sweng
    Setup.Get Sos Report
    ${sos_report_file}=    TARF-Keywords.Get latest modified file with defined pattern    path=${LOG_PATH}
    ...                                                                     pattern=SosReport_${TEST NAME}.tgz
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist   ${LOG_PATH}/${sos_report_file}
    Run Keyword And Ignore Error    OperatingSystem.Move File    ${LOG_PATH}/${sos_report_file}    ${target_dir}/SosReport_${TEST NAME[0:30]}.tgz
    Dated Log     sos Report ${sos_report_file} generated and copied into ${target_dir}
    ${core_alias}=    TARF-Keywords.Connect to Core
    ssh.Download File    remote_path=${tl.core.dir_path}/sosReport_ASIK_ASIL.sh.log    local_path=${target_dir}/sosReport_ASIK_ASIL.sh.log
    ...    connection=${core_alias}
    ssh.disconnect     ${core_alias}

Collect sos report logs old version
    [Documentation]  [OBSOLETE][DONT WORK WITH ASIL!!!]
    ...    Sos report logs are needed in case of opening airphone pronto
    ...
    ...    :param target_dir:   directory to store the journal file
    ...    :param script_path:  path where sosReport.sh is located (default: ${tl.core.dir_path})
    ...
    [Arguments]    ${target_dir}=None    ${script_path}=${tl.core.dir_path}
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testcase-Keywords.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${core_alias}=    TARF-Keywords.Connect to Core
    ssh.execute    cd ${script_path}; ./sosReport.sh -c -s -nr -iphyDIR\=${tl.core.dir_path} -btsDIR\=${tl.core.dir_path}   connection=${core_alias}
    ssh.Download File    remote_path=${tl.core.dir_path}/iphyPsSnapshot.zip    local_path=${target_dir}/iphyPsSnapshot.zip
    ...    connection=${core_alias}
    ssh.Download File    remote_path=${tl.core.dir_path}/btsSnapshot.zip    local_path=${target_dir}/btsSnapshot.zip
    ...    connection=${core_alias}
    ssh.Download File    remote_path=${tl.core.dir_path}/sosReport.sh.log    local_path=${target_dir}/sosReport.sh.log
    ...    connection=${core_alias}
    ${sos_report_file}=    TARF-Keywords.Get latest modified file with defined pattern    path=${script_path}
    ...                                                                     pattern=SosReport*_complete_iphy1.tgz
    ssh.Download File    remote_path=${script_path}/${sos_report_file}    local_path=${target_dir}/${sos_report_file}
    ...    connection=${core_alias}
    ssh.disconnect     ${core_alias}

Collect Logs
    [Arguments]                 ${alias}=${HOST_EPCSIM.alias}
    Run Keyword And Ignore Error         testcase-Keywords.Get Testcase Log Directory
    Run Keyword And Ignore Error         TARF-Keywords.Collect all logs     ${alias}

Collect Logs if needed
    [Documentation]                 Collect logs if needed
    [Arguments]                 ${alias}=${HOST_EPCSIM.alias}
    log many     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL' or '${COLLECT_LOGS}' == '1'     TARF-Keywords.Collect Logs    ${alias}
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect logs

Collect WTS log files
    [Documentation]    Author: Ch SAMSON
    ...    Run keyword before egate teardown
    ...
    ...
    ...    :param target_dir:   directory to store the journal file
    ...    :param wts_alias:    alias name to handle egate for ute_wtssim    default=ap_egate
    ...
    [Arguments]    ${target_dir}=None    ${wts_alias}=ap_egate
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testcase-Keywords.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}

    ${alias}            SSH Connect         host=${HOST_EPCSIM}
    # option h added in case of WTS folder is a link
    Dated Log      tar zcvfh WTS.tgz ${tl.core.dir_path}
    ssh.execute    tar zcvfh WTS.tgz ${tl.core.dir_path}    connection=${alias}
    ssh.execute    ls -l ${tl.core.dir_path}/* >ls-l-WTS.txt       connection=${alias}
    ${HOME}=    Get Environment Variable    name=HOME
    csn.download_file               remote_path=${HOME}/WTS.tgz
    ...                             local_path=${target_dir}/WTS.tgz
    ...                             connection=${alias}
    csn.download_file               remote_path=${HOME}/ls-l-WTS.txt
    ...                             local_path=${target_dir}/ls-l-WTS.txt
    ...                             connection=${alias}
    Dated Log                  WTS log files stored to ${target_dir}

Connect to TestPC
    [Documentation]   :
    ...     Setup ssh connection to Test PC and returns connection handle/alias
    ...
    ...     **Note:** KW sould be called without arguments
    ...
    ...     :param alias: (optional) alias used for ssh connection
    ...
    ...     :return alias: for ssh connection to Testpc
    ...
    ...     **Example:**
    ...
    ...     | ${tpc_alias}=  Connect to TestPC
    ...     | ssh.execute  command=ls  connection=${tpc_alias}
    ...
    [Arguments]    ${alias}=ssh-test-pc
    ssh.Connect_to      hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 username=${tl.test_pc.default_ssh_connection_details.username}
    ...                 password=${tl.test_pc.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]    ${alias}

Start Tcpdump on TestPc
    [Documentation]    :Author: Soenke Kullberg
    ...     Start Tcpdump on test PC
    ...
    ...     :param option: (default="") Addtional options for tcpdump
    ...     :param interface: (default=fronthaul) Interface tcpdump
    ...     :param collector: (default gnb-${gnb_id}-oam-${interface}-tcpdump)  Name of collector **Impact on log filename**
    ...
    ...     **Example:**
    ...
    ...         | Start Tcpdump on TestPc     interface=eth0
    ...         | BuiltIn.Sleep     10 sec
    ...         | Stop Tcpdump on TestPc     interface=eth0
    [Arguments]     ${interface}  ${option}=${EMPTY}      ${collector}=testpc-${interface}-tcpdump
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    tcpdump.create_tcpdump_collector
    ...     name=${collector}
    ...     options=-i ${interface} ${option}
    ...     executor=${testpc_ssh_config}
    tcpdump.setup_collectors    names=${collector}
    tcpdump.start_collectors    names=${collector}
    tcpdump.set_suite_alias     ${collector}
    BuiltIn.Log    Tcpdump on test pc on interface ${interface} started successfully    console=yes
    [RETURN]    ${collector}


Stop Tcpdump on TestPc
    [Documentation]
    ...     Stop tcpdump on testpc
    ...     Logs are storred in Testcase Log directory
    ...
    ...     :param interface: (default=fronthaul) Interface for tcpdump
    ...     :param target_dir: Directory to store the pcap file
    ...
    ...     :return tcpdump-file: Path to tcpdump file
    ...
    [Arguments]     ${interface}  ${collector}=testpc-${interface}-tcpdump    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testcase-Keywords.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    tcpdump.stop_collectors         names=${collector}
    tcpdump.collect_collectors      names=${collector}   target_dir=${target_dir}
    tcpdump.teardown_collectors     names=${collector}
    BuiltIn.Log    Tcpdump on test pc on interface ${interface} stopped and collected successfully    console=yes
    [RETURN]    ${target_dir}/${collector}/${collector}.pcap

Check MCShark if present
   [Arguments]    ${w_log}=False
   # USER_PLUGIN_PATH="$HOME/.local/lib/wireshark/plugins"
   # USER_PLUGIN_PATH=$(tshark -G folders | grep '^Personal Lua Plugins:' | cut -d: -f2- | sed 's/^\s*//')
   # WR_ver=$(tshark -v | grep -oE "TShark\s\(Wireshark\)\s[0-9]+\.[0-9]" | grep -oE "[0-9]+\.[0-9]")
   # plugin_install_path="${USER_PLUGIN_PATH}/${WR_ver}/epan"
   ${USER_PLUGIN_PATH}=   Run   tshark -G folders | grep '^Personal Lua Plugins:' | cut -d: -f2- | sed 's/^\s*//'
   ${USER_PLUGIN_PATH}=    Catenate    ${USER_PLUGIN_PATH}
   ${WR_ver}=    Run    tshark -v | grep -oE 'TShark\\s\\(Wireshark\\)\\s[0-9]+\.[0-9]' | grep -oE '[0-9]+\.[0-9]'
   ${plugin_install_path}=   set variable   ${USER_PLUGIN_PATH}/${WR_ver}/epan
   ${debian_release}=     Run     lsb_release -r | awk -F'\t' '{print $2}'
   ${code_name}=     Run     lsb_release -c | awk -F'\t' '{print $2}'
   ${MCShark}=    Run    ls ${plugin_install_path}/mcshark-*${code_name}.so
   run Keyword if   "${w_log}"=="True"    Dated log      debian_release : ${debian_release}
   run Keyword if   "${w_log}"=="True"    Dated log      code_name : ${code_name}
   run Keyword if   "${w_log}"=="True"    Dated log      User plugin path : ${USER_PLUGIN_PATH}
   run Keyword if   "${w_log}"=="True"    Dated log      TShark version : ${WR_ver}
   run Keyword if   "${w_log}"=="True"    Dated log      Plugin install path : ${plugin_install_path}
   run Keyword if   "${w_log}"=="True"    Dated log      MCShark : ${MCShark}
   ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist       ${MCShark}
   ${contains}=     Run Keyword And Return Status       Should Not Contain     ${MCShark}     No such file or directory
   # ${contains}==True   => MCShark plugin already installed and present
   [Return]     ${contains}   ${MCShark}    ${debian_release}    ${code_name}

Install MCShark if Needed
    [Arguments]               ${current_sw_version}=None
    ${mcshark_present}  ${MCShark}    ${debian_release}    ${code_name}=    Check MCShark if present
    ${logs_dir}=    run Keyword if   "${mcshark_present}"=="False"
    ...              testcase-Keywords.Prepare Logs Directory Path   resultDir=${LOG_PATH}   subdir=install_Logs    with_timestamp=True
    ...   ELSE       set variable    None
    run Keyword if   "${mcshark_present}"=="False"    Install wslte plugins for MCShark    sw_version=${current_sw_version}
    ...                                                                                    local_dir=${logs_dir}
    ...   ELSE     Dated log    wslte plugins for MCShark ${MCShark} already installed
    # update variable
    ${mcshark_present}   ${MCShark}    ${debian_release}    ${code_name}=      pcap.Check MCShark if present
    ${msg}=    StringTool.getHeaderLine    Debian Release    ${debian_release}
    run Keyword if   "${msg}"!="${EMPTY}"      Dated log      ${msg}
    ${msg}=    StringTool.getHeaderLine    Debian Codename   ${code_name}
    run Keyword if   "${msg}"!="${EMPTY}"      Dated log      ${msg}
    ${msg}=   run Keyword if   "${mcshark_present}"=="True"    StringTool.getHeaderLine    MCShark plugin   ${MCShark}
    ...   ELSE                                        StringTool.getHeaderLine    MCShark plugin     Not installed
    run Keyword if   "${msg}"!="${EMPTY}"      Dated log      ${msg}
    set suite variable    ${mcshark_present}

Private Deactivate Sherpa and Stop Collect
    [Documentation]     Before using activate Sherpa traces on gnb using COAM gui or the dedicated KW.
    ...                 Condition: use ONLY after Activate Sherpa usage KW.
    [Arguments]                     ${desired_storage_directory}=${LOG_PATH}      ${keep_pcap_file}=${False}
    ${trace_dir}                    Set Variable                ${desired_storage_directory}
    Set Suite Variable              ${trace_dir}
    Run Keyword If      ${isAic}    Stop And Download Sherpa Trace On AIC
    Return From Keyword If          ${isAic}
    core.stop_collectors            names=l2stream3
    core.collect_collectors         names=l2stream3             target_dir=${trace_dir}
    core.teardown_collectors        names=l2stream3
    # If required, move the pcap file into a sub dir
    # By default, the generated .pcap files remain in the original directory and
    # will be erased at the next call of Sherpa
    Run Keyword If                  ${keep_pcap_file}==${True}
    ...                             Move Sherpa Pcap Files      ${trace_dir}

Convert TTI trace from csv to dict CB012738
    [Arguments]    ${TTITraceCsv}   ${num_of_events}=1000
    [Tags]     robot:flatten
    ${CsvFilename}      Remove String      ${TTITraceCsv}     .csv
    ${TTITraceCsv_w_CR}     set variable   ${CsvFilename}.w_CR.csv
    # echo -ne '\n' > test.csv; cat ttitrace_streaming.dl.issue.csv >> test.csv
    ${cmd}=   Catenate   SEPARATOR=   echo '\n' > ${TTITraceCsv_w_CR}; cat ${TTITraceCsv} >> ${TTITraceCsv_w_CR}
    OperatingSystem.Run     ${cmd}
    ${tti_trace_dict}    read_and_parse_tti_data    path_to_tti=${TTITraceCsv_w_CR}       num_of_events=${num_of_events}
    [Return]       ${tti_trace_dict}


display totalStreamPrbs per l1PoolId in SysLog
    [Documentation]   Analyzing this kind of Syslog trace
    ...    8D-cp_rt INF/cp_rt/CsiRsPoolingGroupsTdd.cpp:58 Created 3 CsiRsPoolingGroup(s) with totalStreamPrbs:2184 in l1PoolId:10
    [Arguments]     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat /tmp/btslog2/${syslog} | grep
    ...     'CsiRsPoolingGroup.*totalStreamPrbs*\d*.*l1PoolId\:(\d?)'

    ${output}=        OperatingSystem.Run
    ...    command=cat /tmp/btslog2/${syslog} | grep CsiRsPoolingGroup
    should not be empty                  ${output}

    ${totalStreamPrbs_l1PoolId_0}  ${totalStreamPrbs_l1PoolId_10}  ${cellmappingtocsirspoolinggroup}  extract_totalStreamPrbs_from_syslog   ${output}
    Should Not Be Empty     ${totalStreamPrbs_l1PoolId_0}
    log to console      totalStreamPrbs Assignment for l1PoolId 9: ${totalStreamPrbs_l1PoolId_0}
    log to console      totalStreamPrbs Assignment for l1PoolId 12: ${totalStreamPrbs_l1PoolId_10}
    log to console      cellmappingtocsirspoolinggroup: ${cellmappingtocsirspoolinggroup}
    ${msg}=   Catenate   totalStreamPrbs Assignment for l1PoolId 9 like [l1PoolId=0, totalStreamPrbs=2184]:
    dated log         ${consTraceColor}${msg} ${totalStreamPrbs_l1PoolId_0}${defColor}
    ${msg}=   Catenate   totalStreamPrbs Assignment for l1PoolId 12 like [l1PoolId=10, totalStreamPrbs=2184]:
    dated log         ${consTraceColorYellow}${msg} ${totalStreamPrbs_l1PoolId_10}${defColor}
    Set Suite Variable      ${totalStreamPrbs_l1PoolId_10}
    Set Suite Variable      ${totalStreamPrbs_l1PoolId_0}
    # ${msg}=   Catenate   cellmappingtocsirspoolinggroup :
    # dated log         ${consTraceColor}${msg} ${cellmappingtocsirspoolinggroup}${defColor}
    # CsiRsPoolingGroupsTdd.cpp:110 added NrCellIdentity:16385 with streamPrbDemand:1092 to CsiRsPoolingGroup 0
    #    (allocatedStreamPrbs:1092) in l1PoolId:10
    # ${msg}=   Catenate   CsiRsPoolingGroupsTdd: added NrCellIdentity: ( ) with streamPrbDemand: ( ) to CsiRsPoolingGroup ( )
    # ${msg}=   Catenate   ${msg} (allocatedStreamPrbs: ( )) in l1PoolId: ( )
    # dated log         ${consTraceColor}${msg} ${cellmappingtocsirspoolinggroup[0]}${defColor}
    # dated log         ${consTraceColor}${msg} ${cellmappingtocsirspoolinggroup[1]}${defColor}
    # dated log         ${consTraceColor}${msg} ${cellmappingtocsirspoolinggroup[2]}${defColor}
    Should Not Be Empty    ${cellmappingtocsirspoolinggroup}    msg=cellmappingtocsirspoolinggroup is empty
    ${msg}=  Catenate   CsiRsPoolingGroupsTdd: added NrCellIdentity: (${cellmappingtocsirspoolinggroup[0]}[0]) with streamPrbDemand:
    ${msg}=  Catenate   ${msg} (${cellmappingtocsirspoolinggroup[0]}[1]) to CsiRsPoolingGroup (${cellmappingtocsirspoolinggroup[0]}[2])
    ${msg}=  Catenate  ${msg} (allocatedStreamPrbs: (${cellmappingtocsirspoolinggroup[0]}[3])) in l1PoolId: (${cellmappingtocsirspoolinggroup[0]}[4])
    dated log         ${consTraceColor}${msg}${defColor}
    ${msg}=  Catenate  CsiRsPoolingGroupsTdd: added NrCellIdentity: (${cellmappingtocsirspoolinggroup[1]}[0]) with streamPrbDemand:
    ${msg}=  Catenate  ${msg} (${cellmappingtocsirspoolinggroup[1]}[1]) to CsiRsPoolingGroup (${cellmappingtocsirspoolinggroup[1]}[2])
    ${msg}=  Catenate  ${msg} (allocatedStreamPrbs: (${cellmappingtocsirspoolinggroup[1]}[3])) in l1PoolId: (${cellmappingtocsirspoolinggroup[1]}[4])
    dated log         ${consTraceColor}${msg}${defColor}
    ${msg}=  Catenate  CsiRsPoolingGroupsTdd: added NrCellIdentity: (${cellmappingtocsirspoolinggroup[0]}[0]) with streamPrbDemand:
    ${msg}=  Catenate  ${msg} (${cellmappingtocsirspoolinggroup[2]}[1]) to CsiRsPoolingGroup (${cellmappingtocsirspoolinggroup[2]}[2])
    ${msg}=  Catenate  ${msg} (allocatedStreamPrbs: (${cellmappingtocsirspoolinggroup[2]}[3])) in l1PoolId: (${cellmappingtocsirspoolinggroup[2]}[4])
    dated log         ${consTraceColor}${msg}${defColor}
    Set Suite Variable      ${totalStreamPrbs_l1PoolId_10}
    [Return]        ${totalStreamPrbs_l1PoolId_10}

display cellmappingtocsirspoolinggroup in SysLog
    [Documentation]   Analyzing this kind of Syslog trace
    ...    8D-cp_rt INF/cp_rt/CsiRsPoolingGroupsTdd.cpp:58 Created 3 CsiRsPoolingGroup(s) with totalStreamPrbs:2184 in l1PoolId:10
    [Arguments]     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat /tmp/btslog2/${syslog} | grep
    ...     'CsiRsPoolingGroup.*totalStreamPrbs*\d*.*l1PoolId\:(\d?)'

    ${output}=        OperatingSystem.Run
    ...    command=cat /tmp/btslog2/${syslog} | grep CsiRsPoolingGroup
    should not be empty                  ${output}

    ${totalStreamPrbs_l1PoolId_0}  ${totalStreamPrbs_l1PoolId_10}  ${cellmappingtocsirspoolinggroup}  extract_totalStreamPrbs_from_syslog   ${output}
    Should Not Be Empty     ${cellmappingtocsirspoolinggroup}        msg=cellmappingtocsirspoolinggroup is empty
    # log to console      totalStreamPrbs Assignment for l1PoolId 9: ${totalStreamPrbs_l1PoolId_0}
    # log to console      totalStreamPrbs Assignment for l1PoolId 12: ${totalStreamPrbs_l1PoolId_10}
    log to console      cellmappingtocsirspoolinggroup: ${cellmappingtocsirspoolinggroup}
    ${msg}=  Catenate   CsiRsPoolingGroupsTdd: added NrCellIdentity: (${cellmappingtocsirspoolinggroup[0]}[0]) with streamPrbDemand:
    ${msg}=  Catenate   ${msg} (${cellmappingtocsirspoolinggroup[0]}[1]) to CsiRsPoolingGroup (${cellmappingtocsirspoolinggroup[0]}[2])
    ${msg}=  Catenate  ${msg} (allocatedStreamPrbs: (${cellmappingtocsirspoolinggroup[0]}[3])) in l1PoolId: (${cellmappingtocsirspoolinggroup[0]}[4])
    dated log         ${consTraceColor}${msg}${defColor}
    ${msg}=  Catenate  CsiRsPoolingGroupsTdd: added NrCellIdentity: (${cellmappingtocsirspoolinggroup[1]}[0]) with streamPrbDemand:
    ${msg}=  Catenate  ${msg} (${cellmappingtocsirspoolinggroup[1]}[1]) to CsiRsPoolingGroup (${cellmappingtocsirspoolinggroup[1]}[2])
    ${msg}=  Catenate  ${msg} (allocatedStreamPrbs: (${cellmappingtocsirspoolinggroup[1]}[3])) in l1PoolId: (${cellmappingtocsirspoolinggroup[1]}[4])
    dated log         ${consTraceColor}${msg}${defColor}
    ${msg}=  Catenate  CsiRsPoolingGroupsTdd: added NrCellIdentity: (${cellmappingtocsirspoolinggroup[2]}[0]) with streamPrbDemand:
    ${msg}=  Catenate  ${msg} (${cellmappingtocsirspoolinggroup[2]}[1]) to CsiRsPoolingGroup (${cellmappingtocsirspoolinggroup[2]}[2])
    ${msg}=  Catenate  ${msg} (allocatedStreamPrbs: (${cellmappingtocsirspoolinggroup[2]}[3])) in l1PoolId: (${cellmappingtocsirspoolinggroup[2]}[4])
    dated log         ${consTraceColor}${msg}${defColor}
    ${msg}=  Catenate  CsiRsPoolingGroupsTdd: added NrCellIdentity: (${cellmappingtocsirspoolinggroup[3]}[0]) with streamPrbDemand:
    ${msg}=  Catenate  ${msg} (${cellmappingtocsirspoolinggroup[3]}[1]) to CsiRsPoolingGroup (${cellmappingtocsirspoolinggroup[3]}[2])
    ${msg}=  Catenate  ${msg} (allocatedStreamPrbs: (${cellmappingtocsirspoolinggroup[3]}[3])) in l1PoolId: (${cellmappingtocsirspoolinggroup[3]}[4])
    dated log         ${consTraceColor}${msg}${defColor}
    [Return]        ${totalStreamPrbs_l1PoolId_10}

display totalStreamPrbs per l1PoolId in SysLog with dir
    [Documentation]   Analyzing this kind of Syslog trace
    ...    8D-cp_rt INF/cp_rt/CsiRsPoolingGroupsTdd.cpp:58 Created 3 CsiRsPoolingGroup(s) with totalStreamPrbs:2184 in l1PoolId:10
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'CsiRsPoolingGroup.*totalStreamPrbs*\d*.*l1PoolId\:(\d?)'

    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep CsiRsPoolingGroup
    should not be empty                  ${output}

    ${totalStreamPrbs_l1PoolId_0}  ${totalStreamPrbs_l1PoolId_10}  ${cellmappingtocsirspoolinggroup}  extract_totalStreamPrbs_from_syslog   ${output}
    # Should Not Be Empty     ${totalStreamPrbs_l1PoolId_10}
    log to console      totalStreamPrbs Assignment for l1PoolId 0: ${totalStreamPrbs_l1PoolId_0}
    log to console      totalStreamPrbs Assignment for l1PoolId 10: ${totalStreamPrbs_l1PoolId_10}
    log to console      cellmappingtocsirspoolinggroup: ${cellmappingtocsirspoolinggroup}
    ${msg}=   Catenate   totalStreamPrbs Assignment for l1PoolId 0 like [l1PoolId=0, totalStreamPrbs]:
    dated log         ${consTraceColor}${msg} ${totalStreamPrbs_l1PoolId_0}${defColor}
    ${msg}=   Catenate   totalStreamPrbs Assignment for l1PoolId 10 like [l1PoolId=10, totalStreamPrbs=2184]:
    dated log         ${consTraceColorYellow}${msg} ${totalStreamPrbs_l1PoolId_10}${defColor}
    Set Suite Variable      ${totalStreamPrbs_l1PoolId_10}
    # ${msg}=   Catenate   cellmappingtocsirspoolinggroup :
    # dated log         ${consTraceColor}${msg} ${cellmappingtocsirspoolinggroup}${defColor}
    # CsiRsPoolingGroupsTdd.cpp:110 added NrCellIdentity:16385 with streamPrbDemand:1092 to CsiRsPoolingGroup 0
    #    (allocatedStreamPrbs:1092) in l1PoolId:10
    # ${msg}=   Catenate   CsiRsPoolingGroupsTdd: added NrCellIdentity: ( ) with streamPrbDemand: ( ) to CsiRsPoolingGroup ( )
    # ${msg}=   Catenate   ${msg} (allocatedStreamPrbs: ( )) in l1PoolId: ( )
    # dated log         ${consTraceColor}${msg} ${cellmappingtocsirspoolinggroup[0]}${defColor}
    # dated log         ${consTraceColor}${msg} ${cellmappingtocsirspoolinggroup[1]}${defColor}
    # dated log         ${consTraceColor}${msg} ${cellmappingtocsirspoolinggroup[2]}${defColor}
    ${ret}   ${msg}=  Run Keyword And Ignore Error
    ...        Catenate   CsiRsPoolingGroupsTdd: added NrCellIdentity: (${cellmappingtocsirspoolinggroup[0]}[0]) with streamPrbDemand:
    ${ret}   ${msg}=  Run Keyword And Ignore Error
    ...        Catenate   ${msg} (${cellmappingtocsirspoolinggroup[0]}[1]) to CsiRsPoolingGroup (${cellmappingtocsirspoolinggroup[0]}[2])
    ${ret}   ${msg}=  Run Keyword And Ignore Error
    ...      Catenate  ${msg} (allocatedStreamPrbs: (${cellmappingtocsirspoolinggroup[0]}[3])) in l1PoolId: (${cellmappingtocsirspoolinggroup[0]}[4])
    dated log         ${consTraceColor}${msg}${defColor}
    ${ret}   ${msg}=  Run Keyword And Ignore Error
    ...           Catenate  CsiRsPoolingGroupsTdd: added NrCellIdentity: (${cellmappingtocsirspoolinggroup[1]}[0]) with streamPrbDemand:
    ${ret}   ${msg}=  Run Keyword And Ignore Error
    ...           Catenate  ${msg} (${cellmappingtocsirspoolinggroup[1]}[1]) to CsiRsPoolingGroup (${cellmappingtocsirspoolinggroup[1]}[2])
    ${ret}   ${msg}=  Run Keyword And Ignore Error
    ...     Catenate  ${msg} (allocatedStreamPrbs: (${cellmappingtocsirspoolinggroup[1]}[3])) in l1PoolId: (${cellmappingtocsirspoolinggroup[1]}[4])
    dated log         ${consTraceColor}${msg}${defColor}
    ${ret}   ${msg}=  Run Keyword And Ignore Error
    ...           Catenate  CsiRsPoolingGroupsTdd: added NrCellIdentity: (${cellmappingtocsirspoolinggroup[0]}[0]) with streamPrbDemand:
    ${ret}   ${msg}=  Run Keyword And Ignore Error
    ...           Catenate  ${msg} (${cellmappingtocsirspoolinggroup[2]}[1]) to CsiRsPoolingGroup (${cellmappingtocsirspoolinggroup[2]}[2])
    ${ret}   ${msg}=  Run Keyword And Ignore Error
    ...      Catenate  ${msg} (allocatedStreamPrbs: (${cellmappingtocsirspoolinggroup[2]}[3])) in l1PoolId: (${cellmappingtocsirspoolinggroup[2]}[4])
    dated log         ${consTraceColor}${msg}${defColor}
    Set Suite Variable      ${totalStreamPrbs_l1PoolId_10}

    Display Bbrm configuration      dir=${dir}     syslog=${syslog}

    [Return]        ${totalStreamPrbs_l1PoolId_10}

Check BBRM ERR Assignment
    [Documentation]   Analyzing this kind of Syslog trace
    ...    1540190-EQ_L2PS_BBRM ERR/L2-PS/src/bbrm/subCellsPooling/PrbCapacityChecker.cpp[161]
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'BBRM ERR'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no BBRM ERR found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "BBRM ERR"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${bbrm_err}  extract_BBRM_ERR_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_err}
    run Keyword if    ${isEmpty}         log to console      no BBRM ERR found: ${bbrm_err}
    ${msg}=        Catenate   ${consTraceColor}no BBRM ERR found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${TEST NAME}
    ${test_name}  set Variable if    '${status}'=='FAIL'    set variable    SUITE TEST
    ...                                                     set variable    ${TEST NAME[0:30]}
    FOR    ${bbrm_err_elt}    IN    @{bbrm_err}
       BuiltIn.Log  ${test_name} ${syslog}: BBRM ERR found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}!
       ...  level=WARN
     dated log    ${consTraceColorRed}BBRM ERR found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}${defColor}
    END
    [Return]        ${bbrm_err}

Check ESTATUS5G_NOTOK
    [Documentation]   Analyzing this kind of Syslog trace
    ...    ESTATUS5G_NOTOK
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'ESTATUS5G_NOTOK'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no ESTATUS5G_NOTOK found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "ESTATUS5G_NOTOK"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${bbrm_err}  tarf-lib.extract_ESTATUS5G_NOTOK_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_err}
    run Keyword if    ${isEmpty}         log to console      no ESTATUS5G_NOTOK found: ${bbrm_err}
    ${msg}=        Catenate   ${consTraceColor}no ESTATUS5G_NOTOK found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${TEST NAME}
    ${test_name}  set Variable if    '${status}'=='FAIL'    set variable    SUITE TEST
    ...                                                     set variable    ${TEST NAME[0:30]}
    FOR    ${bbrm_err_elt}    IN    @{bbrm_err}
        BuiltIn.Log  ${test_name} ${syslog}: ESTATUS5G_NOTOK found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}!
        ...  level=WARN
        dated log    ${consTraceColorRed}ESTATUS5G_NOTOK found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}${defColor}
    END
    [Return]        ${bbrm_err}

Check GnbOamCellUpdateFailed
    [Documentation]   Analyzing this kind of Syslog trace
    ...    GnbOamCellUpdateFailed
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'GnbOamCellUpdateFailed'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no GnbOamCellUpdateFailed found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "GnbOamCellUpdateFailed"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${bbrm_err}  tarf-lib.extract_GnbOamCellUpdateFailed_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_err}
    run Keyword if    ${isEmpty}         log to console      no GnbOamCellUpdateFailed found: ${bbrm_err}
    ${msg}=        Catenate   ${consTraceColor}no GnbOamCellUpdateFailed found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${TEST NAME}
    ${test_name}  set Variable if    '${status}'=='FAIL'    set variable    SUITE TEST
    ...                                                     set variable    ${TEST NAME[0:30]}
    FOR    ${bbrm_err_elt}    IN    @{bbrm_err}
        BuiltIn.Log  ${test_name} ${syslog}: GnbOamCellUpdateFailed found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}!
        ...  level=WARN
        dated log    ${consTraceColorRed}GnbOamCellUpdateFailed found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}${defColor}
    END
    [Return]        ${bbrm_err}

Check 6505 AASYSINFO_FS_OVERLOAD_IND_MSG
    [Documentation]   Analyzing this kind of Syslog trace
    ...    6505 ( AASYSINFO_FS_OVERLOAD_IND_MSG  )
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'AASYSINFO_FS_OVERLOAD_IND_MSG'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no AASYSINFO_FS_OVERLOAD_IND_MSG found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "AASYSINFO_FS_OVERLOAD_IND_MSG"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${bbrm_err}  tarf-lib.extract_AASYSINFO_FS_OVERLOAD_IND_MSG_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_err}
    run Keyword if    ${isEmpty}         log to console      no AASYSINFO_FS_OVERLOAD_IND_MSG found: ${bbrm_err}
    ${msg}=        Catenate   ${consTraceColor}no AASYSINFO_FS_OVERLOAD_IND_MSG found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${TEST NAME}
    ${test_name}  set Variable if    '${status}'=='FAIL'    set variable    SUITE TEST
    ...                                                     set variable    ${TEST NAME[0:30]}
    FOR    ${bbrm_err_elt}    IN    @{bbrm_err}
        BuiltIn.Log  ${test_name} ${syslog}: AASYSINFO_FS_OVERLOAD_IND_MSG found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}!
        ...  level=WARN
        dated log    ${consTraceColorRed}AASYSINFO_FS_OVERLOAD_IND_MSG found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}${defColor}
    END
    [Return]        ${bbrm_err}

Check IncorrectCellParameterSettingAI
    [Documentation]   Analyzing this kind of Syslog trace
    ...    IncorrectCellParameterSettingAI
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'IncorrectCellParameterSettingAI'
    ${msg}=        Catenate   ${consTraceColorBgYellow}${consTraceColorBlack}no IncorrectCellParameterSettingAI found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "IncorrectCellParameterSettingAI"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    run Keyword if    ${isEmpty}      dated log   ${msg}
    Return From Keyword If      ${isEmpty}
    ${bbrm_err}  tarf-lib.extract_IncorrectCellParameterSettingAI_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_err}
    run Keyword if    ${isEmpty}         log to console      no IncorrectCellParameterSettingAI found: ${bbrm_err}
    ${msg}=        Catenate   ${consTraceColor}no IncorrectCellParameterSettingAI found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${TEST NAME}
    ${test_name}  set Variable if    '${status}'=='FAIL'    set variable    SUITE TEST
    ...                                                     set variable    ${TEST NAME[0:30]}
    FOR    ${bbrm_err_elt}    IN    @{bbrm_err}
        BuiltIn.Log  ${test_name} ${syslog}: IncorrectCellParameterSettingAI found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}!
        ...  level=WARN
        dated log    ${consTraceColorRed}IncorrectCellParameterSettingAI found: line ${bbrm_err_elt[0]} : ${bbrm_err_elt[1]}${defColor}
    END
    [Return]        ${bbrm_err}

Display Bbrm configuration
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'PRB pooling buffers'
    ${msg}=        Catenate   ${consTraceColor}no PRB pooling buffers found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "PRB pooling buffers"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    Return From Keyword If      ${isEmpty}    dated log   ${msg}
    ${bbrm_conf}  tarf-lib.extract_BBRM_conf_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_conf}
    run Keyword if    ${isEmpty}         log to console      no BBRM conf found: ${bbrm_conf}
    ${msg}=        Catenate   ${consTraceColor}no BBRM conf found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    FOR    ${bbrm_conf_elt}    IN    @{bbrm_conf}
        dated log    ${consTraceColor}BBRM conf found: line ${bbrm_conf_elt[0]} : PRB pooling buffer ${bbrm_conf_elt[1]}${defColor}
    END

    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "Bbrm conf: bbPoolInfo present"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    Return From Keyword If      ${isEmpty}    dated log   ${msg}
    ${bbrm_conf}  extract_BBRM_conf_2_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_conf}
    run Keyword if    ${isEmpty}         log to console      no BBRM conf found: ${bbrm_conf}
    ${msg}=        Catenate   ${consTraceColor}no BBRM conf found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    FOR    ${bbrm_conf_elt}    IN    @{bbrm_conf}
        dated log    ${consTraceColor}BBRM conf found: line ${bbrm_conf_elt[0]} : Bbrm conf: bbPoolInfo present ${bbrm_conf_elt[1]}${defColor}
    END

    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "Bbrm conf DL"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    Return From Keyword If      ${isEmpty}    dated log   ${msg}
    ${bbrm_conf}  tarf-lib.extract_BBRM_conf_3_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_conf}
    run Keyword if    ${isEmpty}         log to console      no BBRM conf found: ${bbrm_conf}
    ${msg}=        Catenate   ${consTraceColor}no BBRM conf found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    FOR    ${bbrm_conf_elt}    IN    @{bbrm_conf}
        dated log    ${consTraceColorYellow}BBRM conf found: line ${bbrm_conf_elt[0]} CB012738 : ${bbrm_conf_elt[1]}${defColor}
    END

    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "Bbrm conf UL"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    Return From Keyword If      ${isEmpty}    dated log   ${msg}
    ${bbrm_conf}  tarf-lib.extract_BBRM_conf_4_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_conf}
    run Keyword if    ${isEmpty}         log to console      no BBRM conf found: ${bbrm_conf}
    ${msg}=        Catenate   ${consTraceColor}no BBRM conf found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    FOR    ${bbrm_conf_elt}    IN    @{bbrm_conf}
        dated log    ${consTraceColorYellow}BBRM conf found: line ${bbrm_conf_elt[0]} CB012738 : ${bbrm_conf_elt[1]}${defColor}
    END

    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "(DOWNLINK)"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    Return From Keyword If      ${isEmpty}    dated log   ${msg}
    ${bbrm_conf}  extract_BBRM_conf_DL_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_conf}
    run Keyword if    ${isEmpty}         log to console      no DOWNLINK Info conf found: ${bbrm_conf}
    ${msg}=        Catenate   ${consTraceColor}no DOWNLINK info conf found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    FOR    ${bbrm_conf_elt}    IN    @{bbrm_conf}
        dated log    ${consTraceColor}BBRM conf found: line ${bbrm_conf_elt[0]} : ${bbrm_conf_elt[1]} : ${bbrm_conf_elt[2]}${defColor}
    END

    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "(UPLINK)"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    Return From Keyword If      ${isEmpty}    dated log   ${msg}
    ${bbrm_conf}  tarf-lib.extract_BBRM_conf_UL_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${bbrm_conf}
    run Keyword if    ${isEmpty}         log to console      no UPLINK Info conf found: ${bbrm_conf}
    ${msg}=        Catenate   ${consTraceColor}no UPLINK conf found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    FOR    ${bbrm_conf_elt}    IN    @{bbrm_conf}
        dated log    ${consTraceColor}BBRM conf found: line ${bbrm_conf_elt[0]} : ${bbrm_conf_elt[1]} : ${bbrm_conf_elt[2]}${defColor}
    END

    [Return]        ${bbrm_conf}

Create CellSetup Test result
    ${local_target_dir}=        Set Variable    ${LOG_PATH}
    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y%m%d-%H%M%S
    ${filename}   set Variable
    ...               CellSetupLogger-SYSLOG-${SUITE NAME}-${timeStamp}.log
    Run Keyword And Ignore Error    OperatingSystem.touch    ${local_target_dir}/${filename}
    Run Keyword And Ignore Error    OperatingSystem.run      echo "${text}" > ${local_target_dir}/${filename}
    set suite variable      ${log_file_results}       ${local_target_dir}/${filename}

Create Header Csv Test result
    [Arguments]          ${target_dir}=None           ${text}=Extract INF/.uplane/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp from SYSLOG...
    ${local_target_dir}=    Run Keyword If    '${target_dir}'=='None'    testcase-Keywords.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y%m%d-%H%M%S
    ${testCase}    Replace String    ${TEST_NAME[0:30]}    ${SPACE}    _
    ${testCase}    Replace String    ${testCase}    .    _
    ${testCase}    Remove String     ${testCase}    [1]
    ${testCase}    Remove String     ${testCase}    [1.0]
    ${testCase}    Remove String     ${testCase}    [2.0]
    ${testCase}    Remove String     ${testCase}    [
    ${testCase}    Remove String     ${testCase}    ]
    ${filename_csirs}   set Variable
    ...               CSIRS-SYSLOG-${testCase}-${timeStamp}.log
    ${text_csirs}=     Catenate      Extract [CSIRS] from SYSLOG...
    Run Keyword And Ignore Error    OperatingSystem.touch    ${local_target_dir}/${filename_csirs}
    Run Keyword And Ignore Error    OperatingSystem.run      echo "${text_csirs}" > ${local_target_dir}/${filename_csirs}
    set suite variable      ${log_file_csirs_results}       ${local_target_dir}/${filename_csirs}
    ${filename}   set Variable      egate_commands.log
    ${timeStamp}    get current date    result_format=%Y%m%d_%H%M%S
    ${timeStamp}=    Remove String    ${timeStamp.replace(' ','-')}
    Run Keyword And Ignore Error    OperatingSystem.touch    ${local_target_dir}/${filename}
    Run Keyword And Ignore Error    OperatingSystem.run      echo "${timeStamp} : ${filename}" > ${local_target_dir}/${filename}
    set suite variable      ${log_file_egate_command}       ${local_target_dir}/${filename}

Log Test CSIRS results
    [Arguments]                    ${text}
    Run Keyword And Ignore Error    OperatingSystem.run      echo "${text}" >> ${log_file_csirs_results}

Log Test results
    [Arguments]                    ${text}
    Run Keyword And Ignore Error    OperatingSystem.run      echo "${text}" >> ${log_file_results}

Log egate command results
    [Arguments]                    ${text}
    Run Keyword And Ignore Error    OperatingSystem.run      echo "${text}" >> ${log_file_egate_command}

Omit when SKIP_COUNTERS present
    [Documentation]     Accepts only keyword without kwargs
    [Arguments]     @{keyword_name_with_args}
    ${if_skip_counters}=   get variable value        ${SKIP_COUNTERS}     False
    ${if_skip_counters}=  Set Variable If     '${if_skip_counters}'=='True'
    ...                             ${True}                                 ${False}
    # ${if_skip_counters}=        nps_trf_tools.val to bool          ${if_skip_counters}
    Run Keyword if  ${if_skip_counters} == ${False}
    ...         @{keyword_name_with_args}

Omit when TtiTrace deactivated wo kwargs
    [Documentation]     Accepts only keyword without kwargs
    [Arguments]     @{keyword_name_with_args}
    ${if_not_skip}=     Evaluate     '${w_GetTtiTrace}' == 'True' and '${GetTtiTraceTime}' != '0'
    ${if_skip}=         Evaluate     not ${if_not_skip}
    ${if_skip}=  Set Variable If     '${if_skip}'=='True'
    ...                             ${True}                                 ${False}
    # ${if_skip}=        nps_trf_tools.val to bool          ${if_skip}
    ${ret}=     Run Keyword if  ${if_skip} == ${False}
    ...                              @{keyword_name_with_args}
    ...              ELSE            Set Variable    ${None}
    [return]     ${ret}

Omit when TtiTrace deactivated
    [Documentation]     Accepts keyword with args and kwargs
    [Arguments]     ${keyword_name}     @{varargs}     &{kwargs}
    ${if_not_skip}=     Evaluate     '${w_GetTtiTrace}' == 'True' and '${GetTtiTraceTime}' != '0'
    ${if_skip}=         Evaluate     not ${if_not_skip}
    ${if_skip}=  Set Variable If     '${if_skip}'=='True'
    ...                             ${True}                                 ${False}
    # ${if_skip}=        nps_trf_tools.val to bool          ${if_skip}
    ${ret}=     Run Keyword if  ${if_skip} == ${False}
    ...                              ${keyword_name}       @{varargs}     &{kwargs}
    ...              ELSE            Set Variable    ${None}
    [return]     ${ret}

Not Omit when TtiTrace deactivated
    [Documentation]     Accepts keyword with args and kwargs
    [Arguments]     ${keyword_name}     @{varargs}     &{kwargs}
    ${if_not_skip}=     Evaluate     '${w_GetTtiTrace}' == 'True' and '${GetTtiTraceTime}' != '0'
    ${if_skip}=         Evaluate     not ${if_not_skip}
    ${if_skip}=  Set Variable If     '${if_skip}'=='True'
    ...                             ${True}                                 ${False}
    # ${if_skip}=        nps_trf_tools.val to bool          ${if_skip}
    ${ret}=     Run Keyword if  ${if_skip} == ${True}
    ...                              ${keyword_name}       @{varargs}     &{kwargs}
    ...              ELSE            Set Variable    ${None}
    [return]     ${ret}

Omit when L1L2BipTrace deactivated wo kwargs
    [Documentation]     Accepts only keyword without kwargs
    [Arguments]     @{keyword_name_with_args}
    ${if_not_skip}=     Evaluate     '${w_GetL1L2Bip}' == 'True' and '${Getl1l2TraceTime}' != '0'
    ${if_skip}=         Evaluate     not ${if_not_skip}
    ${if_skip}=  Set Variable If     '${if_skip}'=='True'
    ...                             ${True}                                 ${False}
    # ${if_skip}=        nps_trf_tools.val to bool          ${if_skip}
    ${ret}=     Run Keyword if  ${if_skip} == ${False}
    ...                              @{keyword_name_with_args}
    ...              ELSE            Set Variable    ${None}
    [return]     ${ret}

Omit when L1L2BipTrace deactivated
    [Documentation]      Accepts keyword with args and kwargs
    [Arguments]        ${keyword_name}     @{varargs}     &{kwargs}
    ${if_not_skip}=     Evaluate     '${w_GetL1L2Bip}' == 'True' and '${Getl1l2TraceTime}' != '0'
    ${if_skip}=         Evaluate     not ${if_not_skip}
    ${if_skip}=  Set Variable If     '${if_skip}'=='True'
    ...                             ${True}                                 ${False}
    # ${if_skip}=        nps_trf_tools.val to bool          ${if_skip}
    ${ret}=     Run Keyword if  ${if_skip} == ${False}
    ...                              ${keyword_name}     @{varargs}     &{kwargs}
    ...              ELSE            Set Variable    ${None}
    [return]     ${ret}

Omit when L1L2BipTrace activated
    [Documentation]      Accepts keyword with args and kwargs
    [Arguments]        ${keyword_name}     @{varargs}     &{kwargs}
    ${if_not_skip}=     Evaluate     '${w_GetL1L2Bip}' == 'True' and '${Getl1l2TraceTime}' != '0'
    ${if_skip}=         Evaluate     not ${if_not_skip}
    ${if_skip}=  Set Variable If     '${if_skip}'=='True'
    ...                             ${True}                                 ${False}
    # ${if_skip}=        nps_trf_tools.val to bool          ${if_skip}
    ${ret}=     Run Keyword if  ${if_skip} == ${True}
    ...                              ${keyword_name}     @{varargs}     &{kwargs}
    ...              ELSE            Set Variable    ${None}
    [return]     ${ret}

Omit when CPRTTrace deactivated wo kwargs
    [Documentation]     Accepts only keyword without kwargs
    [Arguments]     @{keyword_name_with_args}
    ${if_not_skip}=     Evaluate     '${w_generic_capture}' == 'True' and ${isCaptureCPRT}
    ${if_skip}=         Evaluate     not ${if_not_skip}
    ${if_skip}=  Set Variable If     '${if_skip}'=='True'
    ...                             ${True}                                 ${False}
    # ${if_skip}=        nps_trf_tools.val to bool          ${if_skip}
    ${ret}=     Run Keyword if  ${if_skip} == ${False}
    ...                              @{keyword_name_with_args}
    ...              ELSE            Set Variable    ${None}
    [return]     ${ret}

Omit when CPRTTrace deactivated
    [Documentation]     Accepts keyword with args and kwargs
    [Arguments]    ${keyword_name}     @{varargs}     &{kwargs}
    ${if_not_skip}=     Evaluate     '${w_generic_capture}' == 'True' and ${isCaptureCPRT}
    ${if_skip}=         Evaluate     not ${if_not_skip}
    ${if_skip}=  Set Variable If     '${if_skip}'=='True'
    ...                             ${True}                                 ${False}
    # ${if_skip}=        nps_trf_tools.val to bool          ${if_skip}
    ${ret}=     Run Keyword if  ${if_skip} == ${False}
    ...                              ${keyword_name}     @{varargs}     &{kwargs}
    ...              ELSE            Set Variable    ${None}
    [return]     ${ret}

Display SLOTTYPE configuration
    [Arguments]     ${dir}=/tmp/btslog2     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat ${dir}/${syslog} | grep
    ...     'SlotTypeSelectorBase'
    ${msg}=        Catenate   ${consTraceColor}no SlotTypeSelectorBase found${defColor}
    ${output}=        OperatingSystem.Run
    ...    command=cat ${dir}/${syslog} | grep "SlotTypeSelectorBase"
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${output}
    Return From Keyword If      ${isEmpty}    dated log   ${msg}
    ${slottype_conf}  extract_SlotTypeSelectorBase_from_syslog   ${output}
    ${isEmpty}    Run Keyword And Return Status       should be empty       ${slottype_conf}
    run Keyword if    ${isEmpty}         log to console      no SlotTypeSelectorBase found: ${slottype_conf}
    ${msg}=        Catenate   ${consTraceColor}no SlotTypeSelectorBase found${defColor}
    return from Keyword if   ${isEmpty}     dated log   ${msg}
    ${text}=    Catenate      Display SLOTTYPE configuration FROM ${syslog} :
    Log Test results      ${text}
    ${text}=    Catenate      =============================================================
    Log Test results      ${text}
    ${index}=    Set Variable   ${0}
    FOR    ${slottype_conf_elt}    IN    @{slottype_conf}
        Exit For Loop If     ${index} > ${41}
        ${index}=    Evaluate    ${index} + ${1}
        ${text}=    Catenate    line: ${slottype_conf_elt[0]}; Slot=${slottype_conf_elt[1]}; Type=${slottype_conf_elt[2]};
        # Log Test results      ${text}
        Run Keyword And Ignore Error    OperatingSystem.run      echo "${text}" >> ${log_file_results}
    END

Check ULl1Subpool Assignment
   [Arguments]     ${syslog}=/tmp/

    ${commandToRun}     Catenate
    ...     cat /tmp/btslog2/${syslog} | grep
    ...     'SCellMappingReq.*TCellIdentity = (\d*).*l1SubpoolId\":(\d?)'

    ${output}=        OperatingSystem.Run
    ...    command=cat /tmp/btslog2/${syslog} | grep cprt::cm:: | grep CellMappingReq:
    # ...    command=cat /tmp/btslog2/${syslog} | grep SCellMappingReq:
    should not be empty                  ${output}

    ${ull1spcells_syslog}      extract_ull1sp_from_syslog     ${output}    ${ull1spcells_syslog}    ${testCaseDir}/l2ps-SCellMappingReq-syslog
    set test variable      ${ull1spcells_syslog}
    ${case1}    Run Keyword And Return Status    Should Not Be Empty     ${ull1spcells_syslog[1]}
    ${case2}    Run Keyword And Return Status    Should Not Be Empty     ${ull1spcells_syslog[3]}
    Should be true      ${case1} or ${case2}
    log to console      Check ULl1Subpool Assignment : ${ull1spcells_syslog}
    # ulSubcellId
    # sp0 = [0, 1, 2]
    # ulsubpoolid => 2 dlsubpool
    dated log         ${consTraceColor}4 ulSubpoolId${defColor}
    # dated log         ${consTraceColor}ulSubcellId/ulsubpoolid : ${l1spcells}${defColor}
    dated log         ${consTraceColor}Distribution of CellId and ulSubcellId in ulpool/ulSubpoolId: ${ull1spcells_syslog}${defColor}
    dated log         ${consTraceColor} sp0_poolId9 CellId in ulSubpoolId: ${ull1spcells_syslog[0]}${defColor}
    dated log         ${consTraceColor} sp1_poolId9 CellId in ulSubpoolId: ${ull1spcells_syslog[1]}${defColor}
    dated log         ${consTraceColor} sp2_poolId12 CellId in ulSubpoolId: ${ull1spcells_syslog[2]}${defColor}
    dated log         ${consTraceColor} sp3_poolId12 CellId in ulSubpoolId: ${ull1spcells_syslog[3]}${defColor}
    dated log         ${consTraceColor} sp0_poolId9 SubCellId in ulSubpoolId 0: ${ull1spcells_syslog[4]}${defColor}
    dated log         ${consTraceColor} sp1_poolId9 SubCellId in ulSubpoolId 1: ${ull1spcells_syslog[5]}${defColor}
    dated log         ${consTraceColor} sp2_poolId12 SubCellId in ulSubpoolId 2: ${ull1spcells_syslog[6]}${defColor}
    dated log         ${consTraceColor} sp3_poolId12 SubCellId in ulSubpoolId 3: ${ull1spcells_syslog[7]}${defColor}

    Set Suite Variable      ${ull1spcells_syslog}
    [Return]        ${ull1spcells_syslog}

Check Dll1Subpool Assignment
    [Arguments]     ${syslog}

    ${commandToRun}     Catenate
    ...     cat /tmp/btslog2/${syslog} | grep
    ...     'SCellMappingReq.*TCellIdentity = (\d*).*l1SubpoolId\":(\d?)'

    ${output}=        OperatingSystem.Run
    # ...    command=cat /tmp/btslog2/${syslog} | grep SCellMappingReq:
    ...    command=cat /tmp/btslog2/${syslog} | grep cprt::cm:: | grep CellMappingReq:
    should not be empty                  ${output}

    ${dll1spcells_syslog}      extract_dll1sp_from_syslog     ${output}    ${dll1spcells_syslog}   ${testCaseDir}/l2ps-SCellMappingReq-syslog
    set test variable     ${dll1spcells_syslog}
    ${case1}    Run Keyword And Return Status    Should Not Be Empty     ${dll1spcells_syslog[1]}
    ${case2}    Run Keyword And Return Status    Should Not Be Empty     ${dll1spcells_syslog[3]}
    Should be true      ${case1} or ${case2}
    log to console      Check Dll1Subpool Assignment : ${dll1spcells_syslog}
    # dlSubcellId
    # sp0 = [0, 1, 2, 3, 4, 5]
    # dlsubpoolid => 2 dlsubpool
    dated log         ${consTraceColor}4 dlSubpoolId${defColor}
    dated log         ${consTraceColor}Distribution of CellId and dlSubcellId in dlpool/dlSubpoolId: ${dll1spcells_syslog}${defColor}
    dated log         ${consTraceColor} sp0_poolId9 CellId in dlSubpoolId 0: ${dll1spcells_syslog[0]}${defColor}
    dated log         ${consTraceColor} sp1_poolId9 CellId in dlSubpoolId 1: ${dll1spcells_syslog[1]}${defColor}
    dated log         ${consTraceColor} sp2_poolId12 CellId in dlSubpoolId 2: ${dll1spcells_syslog[2]}${defColor}
    dated log         ${consTraceColor} sp3_poolId12 CellId in dlSubpoolId 3: ${dll1spcells_syslog[3]}${defColor}
    dated log         ${consTraceColor} sp0_poolId9 SubCellId in dlSubpoolId 0: ${dll1spcells_syslog[4]}${defColor}
    dated log         ${consTraceColor} sp1_poolId9 SubCellId in dlSubpoolId 1: ${dll1spcells_syslog[5]}${defColor}
    dated log         ${consTraceColor} sp2_poolId12 SubCellId in dlSubpoolId 2: ${dll1spcells_syslog[6]}${defColor}
    dated log         ${consTraceColor} sp3_poolId12 SubCellId in dlSubpoolId 3: ${dll1spcells_syslog[7]}${defColor}

    Set Suite Variable      ${dll1spcells_syslog}

    [Return]        ${dll1spcells_syslog}

update bbpoolInfo Dll1Subpool and Ull1Subpool Assignment
    ${cellSetupInfos}      Create Dictionary
    ${isFileNameDLCellMappingPresent}    Run Keyword And Return Status    Should Not Be Empty   ${FileNameDLCellMapping}
    Run Keyword If    '${isFileNameDLCellMappingPresent}' == 'False'
    ...                BuiltIn.Log    DL Cell mapping file not present (from Syslog), please check the config...    level=WARN    console=yes
    ${all_equal}    ${l1poolId}=    Run Keyword If   ${isFileNameDLCellMappingPresent}    check Dl Cell mapping from Syslog ${FileNameDLCellMapping}
    ...                                   ELSE                                            ObtainVariablesKeyword
    # 2 l1pools => 2 cases    ${l1poolId}=9 or ${l1poolId}=12
    ${dll1spcells}=     Create List
    ${ull1spcells}=     Create List
    ${l1poolId_nb}=     Evaluate     list(${l1poolId})[0]
    ${l1spcells_idx}    Set Variable If     '${l1poolId_nb}' == '9'     ${4}
    ...                                                                 ${6}
    ${l1spcells_idx_1}     Evaluate     ${l1spcells_idx}+${1}
    Append To List     ${dll1spcells}    ${dll1spcells_syslog[${l1spcells_idx}]}
    Append To List     ${dll1spcells}    ${dll1spcells_syslog[${l1spcells_idx_1}]}
    Append To List     ${ull1spcells}    ${ull1spcells_syslog[${l1spcells_idx}]}
    Append To List     ${ull1spcells}    ${ull1spcells_syslog[${l1spcells_idx_1}]}
    ${l1spcells}           Create Dictionary      dlL1SpCells     ${dll1spcells}       ulL1SpCells     ${ull1spcells}
    Set To Dictionary      ${cellSetupInfos}      l1poolId      ${l1poolId_nb}
    Set To Dictionary      ${cellSetupInfos}      l1SpCells     ${l1spcells}
    # Add indentation (4 spaces) to the JSON string
    # ${formatted_json_data}        Evaluate    json.dumps(${cellSetupInfos}, indent=4)       json
    ${formatted_json_data}        Evaluate    json.dumps(${cellSetupInfos})       json
    # Save the formatted JSON to the file
    OperatingSystem.Create File    ${testCaseDir}/bbpoolInfo_cell_setup.json    ${formatted_json_data}
    [return]     ${cellSetupInfos}


Verify RimRs based on pcap traces
    [Arguments]                   ${csirsTrackingSlotOffset_to_verify}=1
    Dated log     ==========> verify_dldata_rimrssendreq_Info from dldata_rimrssendreq l1l2Bip pcap file
    ${pattern}=     set variable      dldata_rimrssendreq
    ${output}=      nps_trf_tools.verify_csirsTrackingSlotOffset_Info     pattern=${pattern}
    ...                                                                     csirsTrackingSlotOffset_to_verify=${csirsTrackingSlotOffset_to_verify}
    [return]    ${output}

Check RimRs CB011028 Based L1L2 Bip
    [Documentation]                test purpose is to test RimRs info from syscom pcap
    [Arguments]                    ${capture}
    Extract Usefull info from dldata_rimrssendreq Pcap       ${capture}
    Dated log    ==========> Check If RimRsSendReq is Present : [${consTraceColorGreen}OK${defColor}]
    ${pattern1}=     set variable      DlData_CsiRsSendReq
    ${pattern2}=     set variable      DlData_RimRsSendReq
    ${output}        nps_trf_tools.verify_csi_rs_and_rim_rs_are_not_send_on_the_same_slot
    ...                                       pattern_csirs=${pattern1}
    ...                                       pattern_rimrs=${pattern2}
    Run keyword and continue on failure      should contain	                ${output}	                    passed
    ${text}=     set Variable If     '${output}'=='passed'      ${consTraceColorGreen}OK${defColor}
    ...                                                         ${consTraceColorRed}FAILED${defColor}
    Dated log    ==========> Check If CSI-RS and RIM-RS are not send on the same slot : [${text}]
    ${numRbForRs_scf}=   Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=numRbForRs   CellId=1
    ${numRbForRs}=     Set Variable If     '${numRbForRs_scf}' == '48 RBs'    48
    ...                                                                       96
    ${output}        nps_trf_tools.verify_rimrs_num_and_start_prbs
    ...                                       pattern_rimrs=DlData_RimRsSendReq
    ...                                       subcellId=0
    ...                                       expected_values_startPrb=0
    ...                                       expected_values_numOfPrb=${numRbForRs}
    Run keyword and continue on failure       should contain	                ${output}	       passed
    ${text}=     set Variable If     '${output}'=='passed'      ${consTraceColorGreen}OK${defColor}
    ...                                                         ${consTraceColorRed}FAILED${defColor}
    Dated log    ==========> Check If StartRBforRS When Rim-rs is Transmitting is Correctly Set for subcellId 0: [${text}]
    ${numRbForRs_scf}=   Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=numRbForRs   CellId=2
    ${numRbForRs}=     Set Variable If     '${numRbForRs_scf}' == '48 RBs'    48
    ...                                                                       96
    ${output}        nps_trf_tools.verify_rimrs_num_and_start_prbs
    ...                                       pattern_rimrs=DlData_RimRsSendReq
    ...                                       subcellId=1
    ...                                       expected_values_startPrb=0
    ...                                       expected_values_numOfPrb=${numRbForRs}
    Run keyword and continue on failure      should contain	                ${output}	           passed
    ${text}=     set Variable If     '${output}'=='passed'      ${consTraceColorGreen}OK${defColor}
    ...                                                         ${consTraceColorRed}FAILED${defColor}
    Dated log    ==========> Check If StartRBforRS When Rim-rs is Transmitting is Correctly Set for subcellId 1: [${text}]
    ${numRbForRs_scf}=   Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=numRbForRs   CellId=3
    ${numRbForRs}=     Set Variable If     '${numRbForRs_scf}' == '48 RBs'    48
    ...                                                                       96
    ${output}        nps_trf_tools.verify_rimrs_num_and_start_prbs
    ...                                       pattern_rimrs=DlData_RimRsSendReq
    ...                                       subcellId=2
    ...                                       expected_values_startPrb=0
    ...                                       expected_values_numOfPrb=${numRbForRs}
    Run keyword and continue on failure      should contain	                ${output}	            passed
    ${text}=     set Variable If     '${output}'=='passed'      ${consTraceColorGreen}OK${defColor}
    ...                                                         ${consTraceColorRed}FAILED${defColor}
    Dated log    ==========> Check If StartRBforRS When Rim-rs is Transmitting is Correctly Set for subcellId 2: [${text}]
    ${numRbForRs_scf}=   Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=numRbForRs   CellId=4
    ${numRbForRs}=     Set Variable If     '${numRbForRs_scf}' == '48 RBs'    48
    ...                                                                       96
    ${output}        nps_trf_tools.verify_rimrs_num_and_start_prbs
    ...                                       pattern_rimrs=DlData_RimRsSendReq
    ...                                       subcellId=3
    ...                                       expected_values_startPrb=0
    ...                                       expected_values_numOfPrb=${numRbForRs}
    Run keyword and continue on failure      should contain	                ${output}	            passed
    ${text}=     set Variable If     '${output}'=='passed'      ${consTraceColorGreen}OK${defColor}
    ...                                                         ${consTraceColorRed}FAILED${defColor}
    Dated log    ==========> Check If StartRBforRS When Rim-rs is Transmitting is Correctly Set for subcellId 3: [${text}]
    [return]    ${output}

# Info;sfn;slot;rnti;csirsTrackingSlotOffset
Extract Usefull info from dldata_rimrssendreq Pcap
    [Arguments]                     ${File}
    [Documentation]                 Extract dldata_rimrssendreq info from Pcap

    Dated log                   Extract dldata_rimrssendreq info from PCAP file [${File}]

    set test variable   ${pcapprocessed_dldata_rimrssendreq}    pcapprocessed_Extract_pcapprocessed_dldata_rimrssendreq.txt
    set test variable   ${pcapprocessed_dldata_rimrssendreq_path}  ${testCaseDir}/${pcapprocessed_dldata_rimrssendreq}
    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields -Y "dldata_rimrssendreq || dldata_csirssendreq" -e _ws.col.Info
    ...           -e 3gpp.sfn
    ...           -e 3gpp.slot
    ...           -e 3gpp.subcellid
    ...           -e DlData_RimRsSendReq_t.startPrb
    ...           -e DlData_RimRsSendReq_t.numOfPrb
    ...           -E header=y -E separator=';' > ${pcapprocessed_dldata_rimrssendreq_path}
    Run       ${cmd_mcshark}
    # remove space if present
    Run      command=sed -i -e 's/ //g' ${pcapprocessed_dldata_rimrssendreq_path}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_dldata_rimrssendreq_path}   _ws.col.Info
    ${pattern}=      set variable      DlData_RimRsSendReq
    ${extract}  OperatingSystem.grep file  ${pcapprocessed_dldata_rimrssendreq_path}
    ...                                    ${pattern}
    OperatingSystem.copy file    ${pcapprocessed_dldata_rimrssendreq_path}  ${testCaseDir}/msg_dldata_rimrssendreq_pcap.csv
    run keyword if  len($extract)==len($extract_col_info)     fail   DlData_RimRsSendReq not found


# specific to CB011028
Check RimRs CB011028
    [Arguments]    ${traceFilename}=${EMPTY}   ${ttitracepath}=/tmp/    ${vendor_custom}=${EMPTY}
    run Keyword if   '${traceFilename}'!='${EMPTY}'    run Keywords  Check RimRs CB011028 Based L1L2 Bip     ${traceFilename}
    ...                                                                                                      ${ttitracepath}
    ...                                                                                                      ${vendor_custom.maxNumUlSubcellL1Pool}
    ...                                                                                                      ${vendor_custom.maxNumUlSubcellL1Sp}
    ...                                             AND         return from Keyword

# specific to CB012738
Check PRB Assignment CB012738-A TC1
    [Arguments]    ${ttitraceFilename}=${EMPTY}   ${ttitracepath}=/tmp/    ${vendor_custom}=${EMPTY}
    run Keyword if   '${ttitraceFilename}'!='${EMPTY}'    run Keywords  Check PRB Assignment CB012738-A Based FilePkl
    ...                                                                                                      ${ttitraceFilename}
    ...                                                                                                      ${ttitracepath}
    ...                                                                                                      ${vendor_custom.maxNumDlSubcellL1Pool}
    ...                                                                                                      ${vendor_custom.maxNumDlSubcellL1Sp}
    ...                                             AND         return from Keyword

# specific to CB012738
Check PRB Assignment CB012738-B TC1
    [Arguments]    ${ttitraceFilename}=${EMPTY}   ${ttitracepath}=/tmp/    ${vendor_custom}=${EMPTY}
    run Keyword if   '${ttitraceFilename}'!='${EMPTY}'    run Keywords  Check PRB Assignment CB012738-B Based FilePkl
    ...                                                                                                      ${ttitraceFilename}
    ...                                                                                                      ${ttitracepath}
    ...                                                                                                      ${vendor_custom.maxNumUlSubcellL1Pool}
    ...                                                                                                      ${vendor_custom.maxNumUlSubcellL1Sp}
    ...                                             AND         return from Keyword

# specific to CB012738
Check PRB Assignment CB012738-B TC
    [Arguments]    ${ttitraceFilename}=${EMPTY}   ${ttitracepath}=/tmp/    ${vendor_custom}=${EMPTY}
    run Keyword if   '${ttitraceFilename}'!='${EMPTY}'    Check PRB Assignment CB012738-A Based FilePkl
    ...                                                                                           ${ttitraceFilename}
    ...                                                                                           ${ttitracepath}
    ...                                                                                           ${vendor_custom.maxNumDlSubcellL1Pool}
    ...                                                                                           ${vendor_custom.maxNumDlSubcellL1Sp}
    run Keyword if   '${ttitraceFilename}'!='${EMPTY}'    Check PRB Assignment CB012738-B Based FilePkl
    ...                                                                                           ${ttitraceFilename}
    ...                                                                                           ${ttitracepath}
    ...                                                                                           ${vendor_custom.maxNumUlSubcellL1Pool}
    ...                                                                                           ${vendor_custom.maxNumUlSubcellL1Sp}

# specific to CB012738
Check PRB Assignment CB012738-A Based FilePkl
    [Arguments]   ${FilePcap}   ${ttitracepath}   ${maxNumDlSubcellL1Pool}    ${maxNumDlSubcellL1Sp}
    ${tm}=    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .
    ${FilePkl}=   Run keyword and continue on failure     Extract TTI Trace and Convert to Pickle for CB012738
    ...                                                                         ttitraceFilename=${FilePcap}
    ...                                                                         ttitracepath=${ttitracepath}
    ${path_to_filtered_ttitrace_pkl}=   Run keyword and continue on failure     CB011028-lib.verify_TTITraces_for_CB012738_C1
    ...                                                                           path_to_pickle=${FilePkl}
    ...                                                                           name=dl_df_for_manual_analysis_all_subcells_CB012738_A-${tm}
    Run keyword and continue on failure     CB011028-lib.verify_TTITraces_for_CB012738_C2   path_to_pickle=${path_to_filtered_ttitrace_pkl}
    ...                                                                                     maxNumDlSubcellL1Pool=${maxNumDlSubcellL1Pool}
    ...                                                                                     maxNumDlSubcellL1Sp=${maxNumDlSubcellL1Sp}
    ${path_to_filtered_ttitrace_pkl}=   Run keyword and continue on failure     CB011028-lib.verify_TTITraces_for_CB012738_A_C3
    ...                                                                           path_to_pickle=${FilePkl}
    ...                                                                           name=dl_df_for_manual_analysis_all_subcells_CB012738_A_2-${tm}

# specific to CB012738
Check PRB Assignment CB012738-B Based FilePkl
    [Arguments]   ${FilePcap}   ${ttitracepath}   ${maxNumUlSubcellL1Pool}    ${maxNumUlSubcellL1Sp}
    ${tm}=    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}
    ${FilePkl}=   Run keyword and continue on failure     Extract TTI Trace and Convert to Pickle for CB012738 B
    ...                                                                         ttitraceFilename=${FilePcap}
    ...                                                                         ttitracepath=${ttitracepath}
    ${path_to_filtered_ttitrace_pkl}=   Run keyword and continue on failure     CB011028-lib.verify_TTITraces_for_CB012738_B_C1
    ...                                                                           path_to_pickle=${FilePkl}
    ...                                                                           name=ul_df_for_manual_analysis_all_subcells_CB012738-B-${tm}
    Run keyword and continue on failure     CB011028-lib.verify_TTITraces_for_CB012738_B_C2   path_to_pickle=${path_to_filtered_ttitrace_pkl}
    ...                                                                                       maxNumUlSubcellL1Pool=${maxNumUlSubcellL1Pool}
    ...                                                                                       maxNumUlSubcellL1Sp=${maxNumUlSubcellL1Sp}

Extract TTI Trace and Convert to Pickle to Check FdSched NbrPrb
    [Arguments]  ${ttitraceFilename}     ${ttitracepath}=/tmp/
    ${events_required}=  create list  utcTimeStampData   dlAllocatedPooledResourcesData
    ...                               dlFdSchedData
    ${path_to_tti_trace_pcap}=  set Variable   ${ttitracepath}/${ttitraceFilename}
    ${df}=   Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                 events_list=${events_required}
    ...                                                 write_to_pickle=${TRUE}
    Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                         tti_trace_filename=filtered_ttitrace_FdSched_NbrPrb.csv
    ${PklFilename}      Remove String      ${ttitraceFilename}     .pcap
    set suite variable    ${path_to_ttitrace_pkl_fdSched}    ${ttitracepath}/${PklFilename}.pkl
    OperatingSystem.Run    cp ${ttitracepath}/${PklFilename}.pkl ${ttitracepath}/${PklFilename}_FdSched_NbrPrb.pkl
    [return]     ${ttitracepath}/${PklFilename}.pkl

Check PRB Assignment CB011028-D FdSched NbrPrb Based TtiTrace
    [Arguments]   ${FilePcap}   ${ttitracepath}
    ${FilePkl}=   Run keyword and continue on failure     Extract TTI Trace and Convert to Pickle to Check FdSched NbrPrb
    ...                                                                         ttitraceFilename=${FilePcap}
    ...                                                                         ttitracepath=${ttitracepath}
    Run keyword and continue on failure     CB011028-lib.verify_TTITraces_for_CB011028_FdSched   path_to_pickle=${FilePkl}
    Run keyword and continue on failure     nps_trf_tools.verify_fdsched_nbrprb_not_exceed_dlallocatedpooledresourcesdata_numalloccellprbDl
    ...                                                                                           physcellid=50
    Run keyword and continue on failure     nps_trf_tools.verify_fdsched_nbrprb_not_exceed_dlallocatedpooledresourcesdata_numalloccellprbDl
    ...                                                                                           physcellid=51
    Run keyword and continue on failure     nps_trf_tools.verify_fdsched_nbrprb_not_exceed_dlallocatedpooledresourcesdata_numalloccellprbDl
    ...                                                                                           physcellid=52
    Run keyword and continue on failure     nps_trf_tools.verify_fdsched_nbrprb_not_exceed_dlallocatedpooledresourcesdata_numalloccellprbDl
    ...                                                                                           physcellid=53

Check Alarm Cleared All cells
    [Arguments]     ${nbCell}=0
    # 7506	gNB CpRtCell configuration update failure
    # 4540  5G cell update failure
    # ${aliasGNB}                     OAM Connect                             ${GNB_DU.oam}
    # Set Test Variable     ${aliasGNB}
    FOR    ${Cell_Id}    IN RANGE    0    ${nbCell}
        robot_extension.Run Keyword And Warn On Failure    Check Alarm Cleared
        ...                                           parameters=faultId=7506,severity=Critical,impactedCellsList[?]=${Cell_Id}
        robot_extension.Run Keyword And Warn On Failure    Check Alarm Cleared
        ...                                           parameters=faultId=4540,severity=Critical,impactedCellsList[?]=${Cell_Id}
    END
    # robot_extension.Run Keyword And Warn On Failure   OAM Disconnect                          ${GNB_DU.oam}

Cell Lock
    [Arguments]    ${cell_id}
    [Documentation]
    ...     Lock Cell
    Oam.OAM Cell Lock  cell_id=${cell_id}
    Dated Log   Current status of cell ${cell_id} is blocked

Cell Unlock
    [Arguments]    ${cell_id}
    Oam.OAM Cell Lock  state=UNLOCK     cell_id= ${cell_id}
    Dated Log   Current status of cell ${cell_id} is unblocked

Step ${index}: Perform Block SBTS cell ${cellId}
    Dated Log   Step ${consTraceColorRed} ${index} ${defColor}: ${consTraceColor} Perform Block SBTS cell ${cellId} ${defColor}
    ${Cell_state_blocked_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${Offline_}, blockingState=${Blocked_}
    ${Cell_state_unblocked_check}=  Set Variable  operationalState=${Disabled_Enabled_}, blockingState=${Unblocked_}
    ${Cell_state_blocked}=  Set Variable  operationalState=Disabled, availabilityStatus=Offline, blockingState=Blocked
    ${Cell_state_unblocked}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    Set Test Variable  ${Cell_state_blocked_check}
    Set Test Variable  ${Cell_state_unblocked_check}
    Set Test Variable  ${Cell_state_blocked}
    Set Test Variable  ${Cell_state_unblocked}
    Set Test Variable  ${ALARM_49_count}  0
    FOR  ${item}  IN  @{NR_CELL_list}
        # dated log    cell=${item}
        exit For Loop If     'NRCELL_R-${cellId}' in '${item}'
    END
    # dated log    NRCELL = ${item}
    Block SBTS cell   Cell_Id=${item}

Step ${index}: Perform Unblock SBTS cell ${cellId}
    Dated Log   Step ${consTraceColorRed} ${index} ${defColor}: ${consTraceColor} Perform Unblock SBTS cell ${defColor}
    ${Cell_state_blocked_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${Offline_}, blockingState=${Blocked_}
    ${Cell_state_unblocked_check}=  Set Variable  operationalState=${Disabled_Enabled_}, blockingState=${Unblocked_}
    ${Cell_state_blocked}=  Set Variable  operationalState=Disabled, availabilityStatus=Offline, blockingState=Blocked
    ${Cell_state_unblocked}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    Set Test Variable  ${Cell_state_blocked_check}
    Set Test Variable  ${Cell_state_unblocked_check}
    Set Test Variable  ${Cell_state_blocked}
    Set Test Variable  ${Cell_state_unblocked}
    Set Test Variable  ${ALARM_49_count}  0
    FOR  ${item}  IN  @{NR_CELL_list}
        # dated log    cell=${item}
        exit For Loop If     'NRCELL_R-${cellId}' in '${item}'
    END
    # dated log    NRCELL = ${item}
    Unblock SBTS cell   ${item}

Block SBTS cell
    [Arguments]  ${Cell_Id}
    ${cell_class_name}=      Set Variable      NRCEL
    # dated Log    Block SBTS cell ${Cell_Id}
    Log  *** Perform "Cell Block" operation on BTS: ${Cell_Id}  console=True
    coam.Block Cell  dist_name=${Cell_Id}  timeout=180  connection=coam_gnb
    Sleep  3s

    Log  *** Check BTS state and alarms after "Cell Block" operation on SBTS ${cell_class_name}  console=True
    coam.Assert  class_name=${cell_class_name}  id=${Cell_Id}  parameters=${Cell_state_blocked_check}  timeout=30  connection=coam_gnb
    Log  *** BTS ${Cell_Id} status:\n - ${Cell_state_blocked}  console=True

    Sleep  1s

    ${ALARM_49_count}=  Evaluate  ${ALARM_49_count} + 1
    Set Test Variable  ${ALARM_49_count}
    ${SBTS_EXPECTED_ALARMS_49_full}=  Prepare expected alarms list  ${SBTS_EXPECTED_ALARMS_49}  ${ALARM_49_count}
    Log  *** BTS "Cell blocked (0049)" alarm, expected number: ${ALARM_49_count}  console=True
    Check Alarm Raised     parameters=faultId=49,severity=Critical,impactedCellsList[?]=${Cell_Id}
    Log  *** BTS "Cell blocked (0049)" alarm, found number: ${ALARM_49_count}, as expected!  console=True

Unblock SBTS cell
    [Arguments]   ${Cell_Id}
    ${cell_class_name}=  Set Variable   NRCEL
    Log  *** Perform "Cell Unblock" operation on BTS: ${Cell_Id}  console=True
    coam.Unblock Cell  dist_name=${Cell_Id}  timeout=180  connection=coam_gnb
    Sleep  10s

    Log  *** Check BTS state and alarms after "Cell Unblock" operation on BTS ${cell_class_name}  console=True
    coam.Assert  class_name=${cell_class_name}  id=${Cell_Id}  parameters=${Cell_state_unblocked_check}  timeout=30  connection=coam_gnb
    Log  *** BTS ${Cell_Id} status:\n - ${Cell_state_unblocked}  console=True

    ${ALARM_49_count}=  Evaluate  ${ALARM_49_count} - 1
    Set Test Variable  ${ALARM_49_count}
    ${SBTS_EXPECTED_ALARMS_49_full}=  Prepare expected alarms list  ${SBTS_EXPECTED_ALARMS_49}  ${ALARM_49_count}
    Log  *** BTS "Cell blocked (0049)" alarm, expected number: ${ALARM_49_count}  console=True
    Check Alarm Cleared     parameters=faultId=49,severity=Critical,impactedCellsList[?]=${Cell_Id}
    Log  *** BTS "Cell blocked (0049)" alarm, found number: ${ALARM_49_count}, as expected!  console=True

Prepare expected alarms list
    [Documentation]
    ...  Keyword for creating list of alarms multiplicated by multiplication number
    ...  | Parameter             | Man. | Description                                    |
    ...  | exp_alarms_list       | Yes  | List with alarms prepared for multiplication   |
    ...  | multiplication_number | Yes  | Number by which alarms should be multiplicated |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description               |
    ...  | multiplicated_exp_list | List of lists with alarms |
    ...
    ...  *EXAMPLE*
    ...  | ${WCDMA_exp_alarms_multiplicated}= | Prepare expected alarms list | [['7665', 'Core']] | 5 |

    [Arguments]  ${exp_alarms_list}  ${multiplication_number}
    ${multiplicated_exp_list}=  create list
    FOR  ${index}  IN RANGE  ${multiplication_number}
        # Append to list  ${multiplicated_exp_list}  @{exp_alarms_list}
        Append to list  ${multiplicated_exp_list}  ${exp_alarms_list}
    END
    [Return]  ${multiplicated_exp_list}

# faultId=49, severity=Critical
Check Alarm Raised
    [Arguments]    ${parameters}=faultId=49,severity=Critical
    coam.assert_alarm_active    parameters=${parameters}    timeout=5   connection=coam_gnb

Check Alarm Cleared
    [Arguments]    ${parameters}=faultId=49,severity=Critical
    coam.assert_alarm_inactive    parameters=${parameters}    timeout=5   connection=coam_gnb

Set UE capa on EPCSim
    [Arguments]      ${ue_nr_capa_value}=${ue_nr_capabilities_SRS_SA}
    Modify Field in WtsEmu Cfg File
    ...                             field=ue_nr_capabilities                 value=${ue_nr_capa_value}

Modify Ue Capa for WTS
   [Arguments]       ${ue_nr_capa_value}=${ue_nr_capabilities_SRS_SA}
   Dated Log New Line   Set Ue capa for SA
   Set UE capa on EPCSim   ${ue_nr_capa_value}

Set UE Capabilities In WTS Config
    [Arguments]    ${ue_id}     ${capability_file}    ${capability_var}=capas
    ${cfg_file}     set variable         ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_cfg.Load Wts Cfg    ${cfg_file}
    wts_cfg.Modify    ue_param id=${ue_id}    ue_nr_capabilities=${capability_var} capability_file=${capability_file}
    wts_cfg.Save Wts Cfg    ${cfg_file}

Update Basic Configuration File for actDlSrsBm Test Mode
    dated log   ----------> Update Basic Configuration File for actDlSrsBm with cell_testmode_set_nr (${tl.core.dir_path}/${tl.core.cfg_filename})
    wts_cfg.Load Wts Cfg    ${tl.core.dir_path}/${tl.core.cfg_filename}
    # /opt/iphy/latest/basic_setup.cfg
    wts_cfg.insert   cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-40,-13,13,40    after    uec_param id=1
    wts_cfg.insert   cell_testmode_set_nr cell_id=3 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate    after    cell_srs_beam_pos_nr
    wts_cfg.insert   cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate    after    cell_srs_beam_pos_nr
    wts_cfg.insert   cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate    after    cell_srs_beam_pos_nr
    wts_cfg.insert
    ...     sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100
    ...         after    cell_srs_beam_pos_nr
    wts_cfg.Save Wts Cfg    ${tl.core.dir_path}/${tl.core.cfg_filename}
    # /opt/iphy/latest/basic_setup.cfg
    Return From Keyword

Update Basic Configuration File for actDlSrsBm Test Mode with azimuth=-70,-19,20,70
    dated log   ----------> Update Basic Configuration File for actDlSrsBm with cell_testmode_set_nr (${tl.core.dir_path}/${tl.core.cfg_filename})
    wts_cfg.Load Wts Cfg    ${tl.core.dir_path}/${tl.core.cfg_filename}
    # /opt/iphy/latest/basic_setup.cfg
    wts_cfg.insert    cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-70,-19,20,70    after    uec_param id=1
    wts_cfg.insert    cell_testmode_set_nr cell_id=3 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate    after    cell_srs_beam_pos_nr
    wts_cfg.insert    cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate    after    cell_srs_beam_pos_nr
    wts_cfg.insert    cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate    after    cell_srs_beam_pos_nr
    wts_cfg.insert
    ...        sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100
    ...         after    cell_srs_beam_pos_nr
    wts_cfg.Save Wts Cfg    ${tl.core.dir_path}/${tl.core.cfg_filename}
    # /opt/iphy/latest/basic_setup.cfg
    Return From Keyword

Update Basic Configuration File for actDlSrsBm Test Mode with azimuth=-70,-19,20,70 for 4cells
    dated log   ----------> Update Basic Configuration File for actDlSrsBm with cell_testmode_set_nr (${tl.core.dir_path}/${tl.core.cfg_filename})
    wts_cfg.Load Wts Cfg    ${tl.core.dir_path}/${tl.core.cfg_filename}
    # /opt/iphy/latest/basic_setup.cfg
    wts_cfg.insert    cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-70,-19,20,70    after    uec_param id=1
    wts_cfg.insert    cell_testmode_set_nr cell_id=4 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate    after    cell_srs_beam_pos_nr
    wts_cfg.insert    cell_testmode_set_nr cell_id=3 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate    after    cell_srs_beam_pos_nr
    wts_cfg.insert    cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate    after    cell_srs_beam_pos_nr
    wts_cfg.insert    cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate    after    cell_srs_beam_pos_nr
    wts_cfg.insert
    ...        sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100
    ...         after    cell_srs_beam_pos_nr
    wts_cfg.Save Wts Cfg    ${tl.core.dir_path}/${tl.core.cfg_filename}
    # /opt/iphy/latest/basic_setup.cfg
    Return From Keyword


CleanUp basic*step2*.* file
    [Documentation]    This keyword remove basic*step2*.* present in /opt/iphy/latest
    ...                use of -v robot option to force w_CleanUp_wtsFiles (default value is 1)
    ${status}  ${message}=   Run Keyword And Ignore Error      Variable Should Exist     ${w_CleanUp_wtsFiles}
    ${w_CleanUp_wtsFiles}  set Variable if    '${status}'=='FAIL'    1
    ...                                                              ${w_CleanUp_wtsFiles}
    Set Suite Variable              ${w_CleanUp_wtsFiles}
    return From Keyword If   '${w_CleanUp_wtsFiles}'=='0'
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    rm -f /opt/iphy/latest/basic*step2*.*
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    rm -f /opt/wts/latest/basic_wts_step2.cfg
    ${rc}    ${output}    robot_extension.Run Keyword And Warn On Failure      OperatingSystem.Run And Return Rc And Output
    ...                                        ls -l /opt/wts/latest/* >/tmp/ls-l-WTS-initial.txt

Get PYTHON Version
    [Documentation]    This keyword is to get PYTHON version including below 1 suite Metadata variable.
    ...                            and to get PYTHON interpreter full path including below 1 suite Metadata variable.
    ${pythonVersion}=    nps_trf_tools.return_python_version
    Set Suite Metadata    Python Version    ${pythonVersion}
    ${pythonFullPath}=    nps_trf_tools.return_python_interpreter_path
    Set Suite Metadata    Python Path    ${pythonFullPath}
    set suite variable    ${pythonFullPath}
    ${pythonVIRTUALENVPath}=    nps_trf_tools.return_python_virtualenv_path
    Set Suite Metadata    Python VIRTUALENV Path    ${pythonVIRTUALENVPath}
    set suite variable    ${pythonVIRTUALENVPath}


COAM Get SCF
    [Arguments]   ${gnb_id}=0   ${bts_host}=${EMPTY}   ${local_dir_path}=${LOG_PATH}   ${file}=SCF.xml    ${w_setup_admin}=False   ${alias}=coam_gnb
    ${bts_host}=  Set Variable if  '${bts_host}'=='${EMPTY}'  ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}  ${bts_host}
    # admin.connect_to    bts_host=${bts_host}    name=gnb
    run Keyword if     '${w_setup_admin}'=='True'    coam.setup_admin    bts_host=${bts_host}    name=${alias}
    ${scf_xml}   coam.get_current_scf_file
    ...   local_dir_path=${local_dir_path}
    ...   file_name=${file}
    ...   timeout=${300}
    ...   with_auto_configured_parameters=${True}
    ...   connection=${alias}
    [Return]   ${scf_xml}

COAM Get SCF Content
    [Documentation]   export_type: configuration, configurationAndRuntimeObjects, runtimeObjects
    [Arguments]   ${export_type}=configurationAndRuntimeObjects   ${connection}=COAM
    ${scf_xml}   coam.get_scf
    ...   export_type=${export_type}
    ...   timeout=${300}
    ...   connection=${connection}
    [Return]   ${scf_xml}

Set_XL_mod_ListParam
    [Documentation]
    ...              This KW will help to set actDl256Qam on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${arg}    ${value}    ${cell}  ${modiflist}
    Dated Log      "${arg} set ${value}"
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell}
    &{modify_param}   Create Dictionary
    ...                    parameter=${arg}
    ...                    dist_name=${dn}
    ...                    value=${value}
    Append To List     ${modiflist}          ${modify_param}
    [return]     ${modiflist}

Update local SCF
    # improvement : COAM Get SCF Kw is more fast than OAM Get SCF File kw!!!
    # ${test_scf_file}             OAM Get SCF File            dir=${LOG_PATH}      file=SCF.xml
    ${test_scf_file}               COAM Get SCF            local_dir_path=${LOG_PATH}      file=SCF.xml      alias=coam_gnb
    Set Suite Variable              ${test_scf_file}

Get_Private_variables_Suite_setup
    # ${test_scf_file}             OAM Get SCF File            dir=${LOG_PATH}      file=SCF.xml
    ${test_scf_file}             COAM Get SCF        local_dir_path=${LOG_PATH}      file=SCF.xml   alias=coam_gnb
    Set Suite Variable              ${test_scf_file}
    ${nodeType}=     set variable if   ${isAic}     Vdu
    ...                                             Classical
    ${status}  ${actBeamforming_cell1}=   run Keyword and ignore error     Get actBeamforming from SCF    nodeType=${nodeType}  CellId=1
    ${actBeamforming_cell1}=   set Variable if   '${status}'=='FAIL'    False
    ...                                                                 ${actBeamforming_cell1}
    ${status}  ${actBeamforming_cell2}=   run Keyword and ignore error    Get actBeamforming from SCF    nodeType=${nodeType}  CellId=2
    ${actBeamforming_cell2}=   set Variable if   '${status}'=='FAIL'    False
    ...                                                                 ${actBeamforming_cell2}
    ${actDl256Qam_cell1}=      Get actDl256Qam from SCF    nodeType=${nodeType}  CellId=1
    ${status}   ${actDl256Qam_cell2}=      run Keyword and ignore error    Get actDl256Qam from SCF    nodeType=${nodeType}  CellId=2
    ${actDl256Qam_cell2}=   set Variable if   '${status}'=='FAIL'    False
    ...                                                              ${actDl256Qam_cell2}
    ${original_Cipher}=        Get Cipher Parameters From gNB
    ${original_Integrity}=     Get Integrity Parameters From gNB
    Set Suite Variable   ${actBeamforming_cell1}
    Set Suite Variable   ${actBeamforming_cell2}
    Set Suite Variable   ${actDl256Qam_cell1}
    Set Suite Variable   ${actDl256Qam_cell2}
    Set Suite Variable    ${original_Cipher}
    Set Suite Variable    ${original_Integrity}
    StringTool.printLineWithTitle   Get Integrity and Ciphering Protection Algo Info from SCF
    Dated log   original_Cipher_prio=${original_Cipher}
    Dated log   original_Integrity_prio=${original_Integrity}
    ${higher_cipher}=  nps_trf_tools.get_higher_value_from_dict  ${original_Cipher}
    # Dated log    higher_cipher algo is ${higher_cipher}
    ${higher_integrity}=  nps_trf_tools.get_higher_value_from_dict  ${original_Integrity}
    # Dated log    higher_integrity algo is ${higher_integrity}
    &{dict_cipher}=   Create Dictionary        nea0=no_cipher  nea1_128=snow   nea2_128=aes  nea3_128=zuc
    &{dict_Integrity}=   Create Dictionary     nia0=no_cipher  nia1_128=snow   nia2_128=aes  nia3_128=zuc
    ${higher_cipher}=   set Variable      ${dict_cipher["${higher_cipher}"]}
    ${higher_Integrity}=   set Variable      ${dict_Integrity["${higher_Integrity}"]}
    # Dated log    higher_cipher algo is ${consTraceColor}${higher_cipher}${defColor}
    # Dated log    higher_Integrity algo is ${consTraceColor}${higher_Integrity}${defColor}
    ${msg_display}=    StringTool.getHeaderLine    higher_cipher algo is     ${consTraceColor}${higher_cipher}${defColor}
    dated log      ${msg_display}
    ${msg_display}=    StringTool.getHeaderLine    higher_Integrity algo is     ${consTraceColor}${higher_Integrity}${defColor}
    dated log      ${msg_display}
    StringTool.printLineWithTitle   -
    Set Suite Variable    ${higher_cipher}
    Set Suite Variable    ${higher_Integrity}

Update_Private_variables_Suite_setup
    Dated log    ====> Update Globale Variables
    # ${test_scf_file}             OAM Get SCF File            dir=${LOG_PATH}      file=SCF.xml
    ${test_scf_file}             COAM Get SCF        local_dir_path=${LOG_PATH}      file=SCF.xml   alias=coam_gnb
    Set Suite Variable              ${test_scf_file}
    ${nodeType}=     set variable if   ${isAic}     Vdu
    ...                                             Classical
    ${actBeamforming_cell1}=   Get actBeamforming from SCF    nodeType=${nodeType}  CellId=1
    ${status}  ${actBeamforming_cell2}=   run Keyword and ignore error    Get actBeamforming from SCF    nodeType=${nodeType}  CellId=2
    ${actBeamforming_cell2}=   set Variable if   ${status}!='PASSED'    False
    ...                                                                 ${actBeamforming_cell2}
    ${actDl256Qam_cell1}=      Get actDl256Qam from SCF    nodeType=${nodeType}  CellId=1
    ${status}   ${actDl256Qam_cell2}=      run Keyword and ignore error    Get actDl256Qam from SCF    nodeType=${nodeType}  CellId=2
    ${actDl256Qam_cell2}=   set Variable if   ${status}!='PASSED'    False
    ...                                                              ${actDl256Qam_cell2}
    ${original_Cipher}=        Get Cipher Parameters From gNB
    ${original_Integrity}=     Get Integrity Parameters From gNB
    Set Suite Variable   ${actBeamforming_cell1}
    Set Suite Variable   ${actBeamforming_cell2}
    Set Suite Variable   ${actDl256Qam_cell1}
    Set Suite Variable   ${actDl256Qam_cell2}
    Set Suite Variable    ${original_Cipher}
    Set Suite Variable    ${original_Integrity}
    StringTool.printLineWithTitle   Get Integrity and Ciphering Protection Algo Info from SCF
    Dated log   original_Cipher_prio=${original_Cipher}
    Dated log   original_Integrity_prio=${original_Integrity}
    ${higher_cipher}=  get_higher_value_from_dict  ${original_Cipher}
    # Dated log    higher_cipher algo is ${higher_cipher}
    ${higher_integrity}=  get_higher_value_from_dict  ${original_Integrity}
    # Dated log    higher_integrity algo is ${higher_integrity}
    &{dict_cipher}=   Create Dictionary        nea0=no_cipher  nea1_128=snow   nea2_128=aes  nea3_128=zuc
    &{dict_Integrity}=   Create Dictionary     nia0=no_cipher  nia1_128=snow   nia2_128=aes  nia3_128=zuc
    ${higher_cipher}=   set Variable      ${dict_cipher["${higher_cipher}"]}
    ${higher_Integrity}=   set Variable      ${dict_Integrity["${higher_Integrity}"]}
    # Dated log    higher_cipher algo is ${consTraceColor}${higher_cipher}${defColor}
    # Dated log    higher_Integrity algo is ${consTraceColor}${higher_Integrity}${defColor}
    ${msg_display}=    StringTool.getHeaderLine    higher_cipher algo is     ${consTraceColor}${higher_cipher}${defColor}
    dated log      ${msg_display}
    ${msg_display}=    StringTool.getHeaderLine    higher_Integrity algo is     ${consTraceColor}${higher_Integrity}${defColor}
    dated log      ${msg_display}
    StringTool.printLineWithTitle   -
    Set Suite Variable    ${higher_cipher}
    Set Suite Variable    ${higher_Integrity}

Get Cipher and Integrity Parameters From SCF
    # Dated log    ====> Get Cipher and Integrity Parameters From SCF
    ${original_Cipher}=        Get Cipher Parameters From gNB
    ${original_Integrity}=     Get Integrity Parameters From gNB
    Set Suite Variable    ${original_Cipher}
    Set Suite Variable    ${original_Integrity}
    StringTool.printLineWithTitle   Get Integrity and Ciphering Protection Algo Info from SCF
    Dated log   original_Cipher_prio=${original_Cipher}
    Dated log   original_Integrity_prio=${original_Integrity}
    ${higher_cipher}=  get_higher_value_from_dict  ${original_Cipher}
    # Dated log    higher_cipher algo is ${higher_cipher}
    ${higher_integrity}=  get_higher_value_from_dict  ${original_Integrity}
    # Dated log    higher_integrity algo is ${higher_integrity}
    &{dict_cipher}=   Create Dictionary        nea0=no_cipher  nea1_128=snow   nea2_128=aes  nea3_128=zuc
    &{dict_Integrity}=   Create Dictionary     nia0=no_cipher  nia1_128=snow   nia2_128=aes  nia3_128=zuc
    ${higher_cipher}=   set Variable      ${dict_cipher["${higher_cipher}"]}
    ${higher_Integrity}=   set Variable      ${dict_Integrity["${higher_Integrity}"]}
    # Dated log    higher_cipher algo is ${consTraceColor}${higher_cipher}${defColor}
    # Dated log    higher_Integrity algo is ${consTraceColor}${higher_Integrity}${defColor}
    ${msg_display}=    StringTool.getHeaderLine    higher_cipher algo is     ${consTraceColor}${higher_cipher}${defColor}
    dated log      ${msg_display}
    ${msg_display}=    StringTool.getHeaderLine    higher_Integrity algo is     ${consTraceColor}${higher_Integrity}${defColor}
    dated log      ${msg_display}
    StringTool.printLineWithTitle   -
    Set Suite Variable    ${higher_cipher}
    Set Suite Variable    ${higher_Integrity}

# for SNOW
# <list name="cipherPrefL">
#         <item>
#          <p name="nea0">1</p>
#          <p name="nea1_128">3</p>
#          <p name="nea2_128">9</p>
#          <p name="nea3_128">4</p>
#        </item>
#      </list>
#    <list name="integrityProtPrefL">
#        <item>
#          <p name="nia0">0</p>
#          <p name="nia1_128">3</p>
#          <p name="nia2_128">9</p>
#          <p name="nia3_128">4</p>
#         </item>
#      </list>

Modify no cipherPrefL and no integrityProtPrefL ListParam
    [Arguments]              ${cellId}   ${modiflist}
    &{ciphering_algo}       Create Dictionary     nea0=9
    ...                                        nea1_128=0
    ...                                        nea2_128=0
    ...                                        nea3_128=0
    &{modify_param1}   Evaluate  {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}','parameter': 'cipherPrefL','value':[&{ciphering_algo}]}

    &{integrity_algo}  Create Dictionary     nia0=9
    ...                                      nia1_128=0
    ...                                      nia2_128=0
    ...                                      nia3_128=0
    &{modify_param2}   Evaluate  {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}','parameter': 'integrityProtPrefL','value':[&{integrity_algo}]}
    Append To List     ${modiflist}          ${modify_param1}   ${modify_param2}
    [return]   ${modiflist}

Modify no cipherPrefL and AES integrityProtPrefL ListParam
    [Arguments]              ${cellId}   ${modiflist}
    &{ciphering_algo}       Create Dictionary     nea0=9
    ...                                        nea1_128=0
    ...                                        nea2_128=0
    ...                                        nea3_128=0
    &{modify_param1}   Evaluate  {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}','parameter': 'cipherPrefL','value':[&{ciphering_algo}]}

    &{integrity_algo}  Create Dictionary     nia0=0
    ...                                      nia1_128=0
    ...                                      nia2_128=9
    ...                                      nia3_128=0
    &{modify_param2}   Evaluate  {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}','parameter': 'integrityProtPrefL','value':[&{integrity_algo}]}
    Append To List     ${modiflist}          ${modify_param1}   ${modify_param2}
    [return]   ${modiflist}

Modify AES cipherPrefL and integrityProtPrefL ListParam
    [Arguments]              ${cellId}   ${modiflist}
    &{ciphering_algo}       Create Dictionary     nea0=1
    ...                                        nea1_128=3
    ...                                        nea2_128=9
    ...                                        nea3_128=4
    &{modify_param1}   Evaluate  {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}','parameter': 'cipherPrefL','value':[&{ciphering_algo}]}

    &{integrity_algo}  Create Dictionary     nia0=1
    ...                                      nia1_128=3
    ...                                      nia2_128=9
    ...                                      nia3_128=4
    &{modify_param2}   Evaluate  {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}','parameter': 'integrityProtPrefL','value':[&{integrity_algo}]}
    Append To List     ${modiflist}          ${modify_param1}   ${modify_param2}
    [return]   ${modiflist}

# for SNOW
# <list name="cipherPrefL">
#         <item>
#          <p name="nea0">1</p>
#          <p name="nea1_128">9</p>
#          <p name="nea2_128">3</p>
#          <p name="nea3_128">4</p>
#        </item>
#      </list>
#    <list name="integrityProtPrefL">
#        <item>
#          <p name="nia0">0</p>
#          <p name="nia1_128">9</p>
#          <p name="nia2_128">3</p>
#          <p name="nia3_128">4</p>
#         </item>
#      </list>

Modify SNOW cipherPrefL and integrityProtPrefL ListParam
    [Arguments]              ${cellId}   ${modiflist}
    &{ciphering_algo}       Create Dictionary     nea0=1
    ...                                        nea1_128=9
    ...                                        nea2_128=3
    ...                                        nea3_128=4
    &{modify_param1}   Evaluate  {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}','parameter': 'cipherPrefL','value':[&{ciphering_algo}]}

    &{integrity_algo}  Create Dictionary     nia0=1
    ...                                      nia1_128=9
    ...                                      nia2_128=3
    ...                                      nia3_128=4
    &{modify_param2}   Evaluate  {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}','parameter': 'integrityProtPrefL','value':[&{integrity_algo}]}
    Append To List     ${modiflist}          ${modify_param1}   ${modify_param2}
    [return]   ${modiflist}

# for ZUC
#      <list name="cipherPrefL">
#        <item>
#          <p name="nea0">1</p>
#          <p name="nea1_128">3</p>
#          <p name="nea2_128">4</p>
#          <p name="nea3_128">9</p>
#        </item>
#      </list>
#      <list name="integrityProtPrefL">
#        <item>
#          <p name="nia0">0</p>
#          <p name="nia1_128">3</p>
#          <p name="nia2_128">4</p>
#          <p name="nia3_128">9</p>
#        </item>

Modify ZUC cipherPrefL and integrityProtPrefL ListParam
    [Arguments]              ${cellId}   ${modiflist}
    &{ciphering_algo}       Create Dictionary     nea0=1
    ...                                        nea1_128=3
    ...                                        nea2_128=4
    ...                                        nea3_128=9
    &{modify_param1}   Evaluate  {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}','parameter': 'cipherPrefL','value':[&{ciphering_algo}]}

    &{integrity_algo}  Create Dictionary     nia0=1
    ...                                      nia1_128=3
    ...                                      nia2_128=4
    ...                                      nia3_128=9
    &{modify_param2}   Evaluate  {'dist_name': 'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}','parameter': 'integrityProtPrefL','value':[&{integrity_algo}]}
    Append To List     ${modiflist}          ${modify_param1}   ${modify_param2}
    [return]   ${modiflist}

Get dlMimoMode from SCF
    [Arguments]          ${nodeType}=Classical  ${CellId}=1
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${dlMimoMode}	 scf.get_value_from_scf   p_name=dlMimoMode
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    # ...              nodeType=${nodeType}
    [return]     ${dlMimoMode}

Get nrCellType from SCF
    [Arguments]          ${nodeType}=Classical  ${CellId}=1
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${nrCellType}	 scf.get_value_from_scf   p_name=nrCellType
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    # ...              nodeType=${nodeType}
    [return]     ${nrCellType}

Set 4x4 DL Mimo Mode
    [Documentation]
    ...              This KW will help to set 4x4 DL Mimo mode on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${cellId}
    @{modiflist}    Create List
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellId}
    &{modify_param1}   Create Dictionary
    ...                          parameter=nrCellType
    ...                          dist_name=${dn}
    ...                          value=4DL4UL
    &{modify_param2}   Create Dictionary
    ...                          parameter=dlMimoMode
    ...                          dist_name=${dn}
    ...                          value=4x4 or 4x2 Closed Loop Spatial Multiplexing

    # Dated log                                ${modify_param1}  ${modify_param2}
    Append To List     ${modiflist}          ${modify_param1}   ${modify_param2}
    # Dated log    \n
    OAM Set Params            ${modiflist}            # OAM need a list ....

Set 8x4 DL Mimo Mode ListParam
    [Documentation]
    ...              This KW will help to set 8x4 DL Mimo mode on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${cellId}   ${modiflist}
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellId}
    &{modify_param1}   Create Dictionary
    ...                          parameter=nrCellType
    ...                          dist_name=${dn}
    ...                          value=8DL4UL
    &{modify_param2}   Create Dictionary
    ...                          parameter=dlMimoMode
    ...                          dist_name=${dn}
    ...                          value=8x4 Closed Loop Spatial Multiplexing

    Append To List     ${modiflist}          ${modify_param1}   ${modify_param2}
    [return]   ${modiflist}

Set 4x4 DL Mimo Mode ListParam
    [Documentation]
    ...              This KW will help to set 4x4 DL Mimo mode on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${cellId}   ${modiflist}
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellId}
    &{modify_param1}   Create Dictionary
    ...                          parameter=nrCellType
    ...                          dist_name=${dn}
    ...                          value=4DL4UL
    &{modify_param2}   Create Dictionary
    ...                          parameter=dlMimoMode
    ...                          dist_name=${dn}
    ...                          value=4x4 or 4x2 Closed Loop Spatial Multiplexing

    Append To List     ${modiflist}          ${modify_param1}   ${modify_param2}
    [return]   ${modiflist}

Set 2x2 DL Mimo Mode
    [Documentation]
    ...              This KW will help to set 2x2 DL Mimo mode on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${cellId}
    @{modiflist}    Create List
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellId}
    &{modify_param1}   Create Dictionary
    ...                          parameter=nrCellType
    ...                          dist_name=${dn}
    ...                          value=2DL2UL
    &{modify_param2}   Create Dictionary
    ...                          parameter=dlMimoMode
    ...                          dist_name=${dn}
    ...                          value=2x2 Closed Loop Spatial Multiplexing

    # Dated log                                ${modify_param1}  ${modify_param2}
    Append To List     ${modiflist}          ${modify_param1}   ${modify_param2}
    # Dated log    \n
    OAM Set Params            ${modiflist}            # OAM need a list ....

Set 2x2 DL Mimo Mode ListParam
    [Documentation]
    ...              This KW will help to set 2x2 DL Mimo mode on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${cellId}   ${modiflist}
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellId}
    &{modify_param1}   Create Dictionary
    ...                          parameter=nrCellType
    ...                          dist_name=${dn}
    ...                          value=2DL2UL
    &{modify_param2}   Create Dictionary
    ...                          parameter=dlMimoMode
    ...                          dist_name=${dn}
    ...                          value=2x2 Closed Loop Spatial Multiplexing

    Append To List     ${modiflist}          ${modify_param1}   ${modify_param2}
    [return]      ${modiflist}

Set 2x2 UL Mimo Mode
    [Documentation]
    ...              This KW will help to set 2x2 UL Mimo mode on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${cellId}
    @{modiflist}    Create List
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellId}
    &{modify_param}   Create Dictionary
    ...                          parameter=ulMimoMode
    ...                          dist_name=${dn}
    ...                          value=Closed loop Spatial Multiplexing (2x2)

    # Dated log                                ${modify_param}
    Append To List     ${modiflist}          ${modify_param}
    # Dated log    \n
    OAM Set Params            ${modiflist}            # OAM need a list ....

Set 2x2 UL Mimo Mode ListParam
    [Documentation]
    ...              This KW will help to set 2x2 UL Mimo mode on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${cellId}    ${modiflist}
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellId}
    &{modify_param}   Create Dictionary
    ...                          parameter=ulMimoMode
    ...                          dist_name=${dn}
    ...                          value=Closed loop Spatial Multiplexing (2x2)

    Append To List     ${modiflist}          ${modify_param}
    [return]    ${modiflist}

Get UL Mimo Mode from SCF
    [Arguments]          ${nodeType}=Classical  ${CellId}=1
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${ulMimoMode}	 scf.get_value_from_scf   p_name=ulMimoMode
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    # ...              nodeType=${nodeType}
    [return]     ${ulMimoMode}

Get actUnlimitedDataRateDl from SCF
    [Arguments]          ${nodeType}=Classical
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${actUnlimitedDataRateDl}	 scf.get_value_from_scf   p_name=actUnlimitedDataRateDl
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...              nodeType=${nodeType}
    [return]     ${actUnlimitedDataRateDl}

Set actUnlimitedDataRateDl ListParam
    [Documentation]
    ...              This KW will help to set actUnlimitedDataRateDl on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${actUnlimitedDataRateDl}    ${modiflist}
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    &{modify_param}   Create Dictionary
    ...                          parameter=actUnlimitedDataRateDl
    ...                          dist_name=${dn}
    ...                          value=${actUnlimitedDataRateDl}

    Append To List     ${modiflist}          ${modify_param}
    [return]    ${modiflist}

Get actFdmEnhancedScheduling from SCF
    [Arguments]          ${nodeType}=Classical
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1
    ${actFdmEnhancedScheduling}	 scf.get_value_from_scf   p_name=actFdmEnhancedScheduling
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...              nodeType=${nodeType}
    [return]     ${actFdmEnhancedScheduling}

Set actFdmEnhancedScheduling ListParam
    [Documentation]
    ...              This KW will help to set actFdmEnhancedScheduling on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${actFdmEnhancedScheduling}    ${modiflist}
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    &{modify_param}   Create Dictionary
    ...                          parameter=actFdmEnhancedScheduling
    ...                          dist_name=${dn}
    ...                          value=${actFdmEnhancedScheduling}

    Append To List     ${modiflist}          ${modify_param}
    [return]    ${modiflist}

Get dlQam256PowerBackoffSub6 from SCF
    [Arguments]          ${nodeType}=Classical  ${CellId}=1
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${dlQam256PowerBackoffSub6}	 scf.get_value_from_scf   p_name=dlQam256PowerBackoffSub6
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    # ...              nodeType=${nodeType}
    [return]     ${dlQam256PowerBackoffSub6}

Set dlQam256PowerBackoffSub6 ListParam
    [Documentation]
    ...              This KW will help to set dlQam256PowerBackoffSub6 on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${cellId}   ${dlQam256PowerBackoffSub6}   ${modiflist}
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellId}
    &{modify_param}   Create Dictionary
    ...                          parameter=dlQam256PowerBackoffSub6
    ...                          dist_name=${dn}
    ...                          value=${dlQam256PowerBackoffSub6}

    Append To List     ${modiflist}          ${modify_param}
    [return]    ${modiflist}

Get btsName from SCF
    [Arguments]          ${nodeType}=Classical
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1
    ${param_value}	 scf.get_value_from_scf   p_name=btsName
    ...              dist_name=MRBTS-${MRBTS_ID}
    # ...              nodeType=${nodeType}
    [return]     ${param_value}

Set btsName ListParam
    [Documentation]
    ...              This KW will help to set CELL param on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${param_value}   ${modiflist}
    ${dn}             set variable           MRBTS-${MRBTS_ID}
    &{modify_param}   Create Dictionary
    ...                          parameter=btsName
    ...                          dist_name=${dn}
    ...                          value=${param_value}

    Append To List     ${modiflist}          ${modify_param}
    [return]    ${modiflist}

Update BtsName
    [Arguments]    ${modiflist}

    ${Current_btsName}=   Get btsName from SCF
    ${PartOfBtsName}=    set Variable   Aligned with CB011028
    ${FullbtsName}=      set Variable   CB012738 - ${testline_name} - ${PartOfBtsName}
    ${modiflist}=  Run Keyword if   '${Current_btsName.lower()}'!='${FullbtsName.lower()}'
    ...                                                                           Set btsName ListParam       param_value=${FullbtsName}
    ...                                                                                                       modiflist=${modiflist}
    ...   ELSE     set Variable    ${modiflist}
    [return]   ${modiflist}

Update OAM param to Aligned with 9890
   [Arguments]    ${cellId}    ${modiflist}

   ${modiflist}=   Update BtsName   ${modiflist}

   ${actProactUlScheduling}=    Get NRCELL Param from SCF   param=actProactUlScheduling  CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${actProactUlScheduling.lower()}'=='false'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=actProactUlScheduling
   ...                                                                                                       param_value=true
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${dlDMRSAdditionalPosition}=    Get NRCELL Param from SCF   param=dlDMRSAdditionalPosition   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${dlDMRSAdditionalPosition.lower()}'!='one additional dmrs'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=dlDMRSAdditionalPosition
   ...                                                                                                       param_value=One additional DMRS
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${actDlDataDmrsFdm}=    Get NRCELL Param from SCF   param=actDlDataDmrsFdm   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${actDlDataDmrsFdm.lower()}'!='false'   Modify dlDataDmrsFdm related Parameters    cellId=${cellId}
   ...                                                                                                       actDlDataDmrsFdm=false
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${ulDMRSAdditionalPosition}=    Get NRCELL Param from SCF   param=ulDMRSAdditionalPosition   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${ulDMRSAdditionalPosition.lower()}'!='one additional dmrs'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=ulDMRSAdditionalPosition
   ...                                                                                                       param_value=One additional DMRS
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${maxDlHarqTx}=    Get NRCELLGRP Param from SCF   param_name=maxDlHarqTx   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${maxDlHarqTx.lower()}'!='4'   Set NRCELLGRP Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=maxDlHarqTx
   ...                                                                                                       param_value=4
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${actBbPoolTddFr1}=    Get NRBTS Param from SCF   param_name=actBbPoolTddFr1   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${actBbPoolTddFr1.lower()}'!='4'   Set NRBTS Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=actBbPoolTddFr1
   ...                                                                                                       param_value=true
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${actSpatialStreamPooling}=    Get NRBTS Param from SCF   param_name=actSpatialStreamPooling   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${actSpatialStreamPooling.lower()}'!='false'   Set NRBTS Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=actSpatialStreamPooling
   ...                                                                                                       param_value=false
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${actTddPrePooling}=    Get NRBTS Param from SCF   param_name=actTddPrePooling   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${actTddPrePooling.lower()}'!='false'   Set NRBTS Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=actTddPrePooling
   ...                                                                                                       param_value=false
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${actBeamforming}=    Get NRCELL Param from SCF   param=actBeamforming   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${actBeamforming.lower()}'!='false'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=actBeamforming
   ...                                                                                                       param_value=true
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${actCsirsMultiplexing}=    Get NRCELL Param from SCF   param=actCsirsMultiplexing   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${actCsirsMultiplexing.lower()}'!='false'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=actCsirsMultiplexing
   ...                                                                                                       param_value=true
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${actPdschAtSsbSlots}=    Get NRCELL Param from SCF   param=actPdschAtSsbSlots   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${actPdschAtSsbSlots.lower()}'!='false'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=actPdschAtSsbSlots
   ...                                                                                                       param_value=true
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${actPdschRmCsirsForTracking}=    Get NRCELL Param from SCF   param=actPdschRmCsirsForTracking   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${actPdschRmCsirsForTracking.lower()}'!='false'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=actPdschRmCsirsForTracking
   ...                                                                                                       param_value=true
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${actRrcReconfigAtBeamSwitch}=    Get NRCELL Param from SCF   param=actRrcReconfigAtBeamSwitch   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${actRrcReconfigAtBeamSwitch.lower()}'!='false'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=actRrcReconfigAtBeamSwitch
   ...                                                                                                       param_value=true
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${actRrcReconfigAtBeamSwitch}=    Get NRCELL Param from SCF   param=actRrcReconfigAtBeamSwitch   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${actRrcReconfigAtBeamSwitch.lower()}'!='false'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=actRrcReconfigAtBeamSwitch
   ...                                                                                                       param_value=true
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${actUeCsirsCoexistCellCsirs}=    Get NRCELL Param from SCF   param=actUeCsirsCoexistCellCsirs   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${actUeCsirsCoexistCellCsirs.lower()}'!='false'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=actUeCsirsCoexistCellCsirs
   ...                                                                                                       param_value=true
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${actVoNR}=    Get NRCELL Param from SCF   param=actVoNR   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${actVoNR.lower()}'!='false'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=actVoNR
   ...                                                                                                       param_value=true
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${mMimoAntArrayMode}=    Get NRCELL Param from SCF   param=mMimoAntArrayMode   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${mMimoAntArrayMode.lower()}'!='full 64trx array (4x8x2)'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=mMimoAntArrayMode
   ...                                                                                                       param_value=Full 64TRX Array (4x8x2)
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${msg1FrequencyStart}=    Get NRCELL Param from SCF   param=msg1FrequencyStart   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${msg1FrequencyStart.lower()}'!='14'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=msg1FrequencyStart
   ...                                                                                                       param_value=14
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${numberOfRxBeamforming}=    Get NRCELL Param from SCF   param=numberOfRxBeamforming   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${numberOfRxBeamforming.lower()}'!='4rx'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=numberOfRxBeamforming
   ...                                                                                                       param_value=4Rx
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${pMaxNROwnCell}=    Get NRCELL Param from SCF   param=pMaxNROwnCell   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${pMaxNROwnCell.lower()}'!='20'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                                       param_name=pMaxNROwnCell
   ...                                                                                                       param_value=20
   ...                                                                                                       modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${type0SearchSpaceConfigurationIndex}=    Get NRCELL Param from SCF   param=type0SearchSpaceConfigurationIndex   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${type0SearchSpaceConfigurationIndex.lower()}'!='5'   Set NRCELL Param ListParam    cellId=${cellId}
   ...                                                                                               param_name=type0SearchSpaceConfigurationIndex
   ...                                                                                               param_value=5
   ...                                                                                               modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${basicBeamSet}=    Get NRCELL beamSet Param from SCF   param=basicBeamSet   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${basicBeamSet.lower()}'!='beamset_6'   Set NRCELL beamSet Param ListParam    cellId=${cellId}
   ...                                                                                               param_name=basicBeamSet
   ...                                                                                               param_value=beamSet_6
   ...                                                                                               modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${beamsMuted}=    Get NRCELL beamSet Param from SCF   param=beamsMuted   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${beamsMuted.lower()}'!='0'   Set NRCELL beamSet Param ListParam    cellId=${cellId}
   ...                                                                                               param_name=beamsMuted
   ...                                                                                               param_value=0
   ...                                                                                               modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${lowerEdgeAngle}=    Get NRCELL beamSet Param from SCF   param=lowerEdgeAngle   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${lowerEdgeAngle.lower()}'!='120'   Set NRCELL beamSet Param ListParam    cellId=${cellId}
   ...                                                                                               param_name=lowerEdgeAngle
   ...                                                                                               param_value=120
   ...                                                                                               modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${nrBtsBeamRefinementP2}=    Get NRCELL beamSet Param from SCF   param=nrBtsBeamRefinementP2   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${nrBtsBeamRefinementP2.lower()}'!='true'   Set NRCELL beamSet Param ListParam    cellId=${cellId}
   ...                                                                                               param_name=nrBtsBeamRefinementP2
   ...                                                                                               param_value=true
   ...                                                                                               modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${tiltOffset}=    Get NRCELL beamSet Param from SCF   param=tiltOffset   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${tiltOffset.lower()}'!='0'   Set NRCELL beamSet Param ListParam    cellId=${cellId}
   ...                                                                                               param_name=tiltOffset
   ...                                                                                               param_value=0
   ...                                                                                               modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${upperEdgeAngle}=    Get NRCELL beamSet Param from SCF   param=upperEdgeAngle   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${upperEdgeAngle.lower()}'!='60'   Set NRCELL beamSet Param ListParam    cellId=${cellId}
   ...                                                                                               param_name=upperEdgeAngle
   ...                                                                                               param_value=60
   ...                                                                                               modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${numberOfTransmittedSsBlocks}=    Get NRCELLGRP Param from SCF   param_name=numberOfTransmittedSsBlocks   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${numberOfTransmittedSsBlocks.lower()}'!='6 beams'   Set NRCELLGRP Param ListParam    cellId=${cellId}
   ...                                                                                               param_name=numberOfTransmittedSsBlocks
   ...                                                                                               param_value=6 beams
   ...                                                                                               modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   ${systemInformationTargetRate}=    Get NRSYSINFO_PROFILE Param from SCF   param=systemInformationTargetRate   CellId=${cellId}
   ${modiflist}=  Run Keyword if   '${systemInformationTargetRate.lower()}'!='157'   Set NRSYSINFO_PROFILE Param ListParam    cellId=${cellId}
   ...                                                                                               param_name=systemInformationTargetRate
   ...                                                                                               param_value=157
   ...                                                                                               modiflist=${modiflist}
   ...   ELSE     set Variable    ${modiflist}
   [return]   ${modiflist}

Set_XL_mod
    [Documentation]
    ...              This KW will help to set actDl256Qam on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${arg}    ${value}    ${cell}
    Dated Log      "${arg} set ${value}"
    @{modiflist}    Create List
           ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell}
           &{modify_param}   Create Dictionary
                             ...                    parameter=${arg}
                             ...                    dist_name=${dn}
                             ...                    value=${value}

           Dated log                                ${modify_param}
           Append To List     ${modiflist}          ${modify_param}
           Dated log    \n
    OAM Set Params            ${modiflist}            # OAM need a list ....
    Dated Log  on ${modify_param.dist_name}, ${arg} have been modified with value: ${value}

Get actBeamforming from SCF
    [Arguments]          ${nodeType}=Classical  ${CellId}=1
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${actBeamforming}	 scf.get_value_from_scf   p_name=actBeamforming
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    # ...              nodeType=${nodeType}
    [return]     ${actBeamforming}

Get actDl256Qam from SCF
    [Arguments]          ${nodeType}=Classical  ${CellId}=1
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${actDl256Qam}	 scf.get_value_from_scf   p_name=actDl256Qam
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    # ...              nodeType=${nodeType}
    [return]     ${actDl256Qam}

Get Cipher Parameters From gNB
    ${cipher_params_list}    Create List    nea0    nea1_128    nea2_128    nea3_128
    # Get SCF File (SCF.xml) is performed in test setup
    ${scf_path}    set Variable      ${test_scf_file}
    ${cipher_dict}    nps_trf_tools.get_feature_paramters_from_scf    ${scf_path}    ${cipher_params_list}
    ...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    cipherPrefL
    [Return]    ${cipher_dict}

Get Integrity Parameters From gNB
    ${integrity_params_list}    Create List    nia0    nia1_128    nia2_128    nia3_128
    # Get SCF File (SCF.xml) is performed in test setup
    ${scf_path}    set Variable      ${test_scf_file}
    ${integrity_dict}    nps_trf_tools.get_feature_paramters_from_scf    ${scf_path}    ${integrity_params_list}
    ...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    integrityProtPrefL
    [Return]    ${integrity_dict}

Modify Channels to support 4DL4UL nrCellType
    [Arguments]         ${CellId}=1
    ${Need_to_Perform_Commissioning}   set Variable   ${True}
    FOR  ${channelId}  IN RANGE  1   3
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
    END
    FOR  ${channelId}  IN RANGE  3   5
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
    END
    FOR  ${channelId}  IN RANGE  5   7
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${distName_CHANNELGROUP}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        ${dist_name}=             Set Variable              ${distName_CHANNELGROUP}
        ${version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-1    version
        Set Object                dist_name=${distName_CHANNEL}    class_name=CHANNEL   version=${version}
        Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        # Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
    END
    FOR  ${channelId}  IN RANGE  7   9
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${distName_CHANNELGROUP}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        ${dist_name}=             Set Variable              ${distName_CHANNELGROUP}
        ${version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-1     version
        Set Object                dist_name=${distName_CHANNEL}    class_name=CHANNEL   version=${version}
        Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        # Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
    END
    [return]   ${Need_to_Perform_Commissioning}

Modify Channels to support 8DL4UL nrCellType
    [Arguments]           ${CellId}=1
    ${Need_to_Perform_Commissioning}   set Variable   ${True}
    FOR  ${channelId}  IN RANGE  1   3
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        # ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        # ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        # run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
    END
    FOR  ${channelId}  IN RANGE  3   5
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        # ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        # ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        # run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
    END
    FOR  ${channelId}  IN RANGE  5   7
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${distName_CHANNELGROUP}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        ${dist_name}=             Set Variable              ${distName_CHANNELGROUP}
        ${version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-1    version
        Set Object                dist_name=${distName_CHANNEL}    class_name=CHANNEL   version=${version}
        Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        # Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
        # ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        # run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
    END
    FOR  ${channelId}  IN RANGE  7   9
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${distName_CHANNELGROUP}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        ${dist_name}=             Set Variable              ${distName_CHANNELGROUP}
        ${version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-1     version
        Set Object                dist_name=${distName_CHANNEL}    class_name=CHANNEL   version=${version}
        Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        # Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
        # ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        # run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
    END
    ${distName_CHANNELGROUP}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-2
    ${dist_name}=             Set Variable              ${distName_CHANNELGROUP}
    ${version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-1     version
    Set Object                dist_name=${distName_CHANNELGROUP}    class_name=CHANNELGROUP   version=${version}
    FOR  ${channelId}  IN RANGE  1   3
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-2/CHANNEL-${channelId}
        ${distName_CHANNELGROUP}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-2
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        ${dist_name}=             Set Variable              ${distName_CHANNELGROUP}
        ${version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-1     version
        Set Object                dist_name=${distName_CHANNEL}    class_name=CHANNEL   version=${version}
        # Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        # Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
        # ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        # run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
    END
      FOR  ${channelId}  IN RANGE  3   5
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-2/CHANNEL-${channelId}
        ${distName_CHANNELGROUP}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-2
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        ${dist_name}=             Set Variable              ${distName_CHANNELGROUP}
        ${version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-1     version
        Set Object                dist_name=${distName_CHANNEL}    class_name=CHANNEL   version=${version}
        # Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        # Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
        # ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        # run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
    END
    [return]   ${Need_to_Perform_Commissioning}

Modify Channels to support 8DL8UL nrCellType
    [Arguments]           ${CellId}=1
    ${Need_to_Perform_Commissioning}   set Variable   ${True}
    FOR  ${channelId}  IN RANGE  1   3
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
    END
    FOR  ${channelId}  IN RANGE  3   5
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
    END
    FOR  ${channelId}  IN RANGE  5   7
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${distName_CHANNELGROUP}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        ${dist_name}=             Set Variable              ${distName_CHANNELGROUP}
        ${version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-1    version
        Set Object                dist_name=${distName_CHANNEL}    class_name=CHANNEL   version=${version}
        Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        # Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
    END
    FOR  ${channelId}  IN RANGE  7   9
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${distName_CHANNELGROUP}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        ${dist_name}=             Set Variable              ${distName_CHANNELGROUP}
        ${version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-1     version
        Set Object                dist_name=${distName_CHANNEL}    class_name=CHANNEL   version=${version}
        Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        # Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
    END
    ${distName_CHANNELGROUP}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-2
    ${dist_name}=             Set Variable              ${distName_CHANNELGROUP}
    ${version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-1     version
    Set Object                dist_name=${distName_CHANNELGROUP}    class_name=CHANNELGROUP   version=${version}
    FOR  ${channelId}  IN RANGE  1   3
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-2/CHANNEL-${channelId}
        ${distName_CHANNELGROUP}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-2
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        ${dist_name}=             Set Variable              ${distName_CHANNELGROUP}
        ${version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-1     version
        Set Object                dist_name=${distName_CHANNEL}    class_name=CHANNEL   version=${version}
        Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        # Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
    END
      FOR  ${channelId}  IN RANGE  3   5
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-2/CHANNEL-${channelId}
        ${distName_CHANNELGROUP}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-2
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        ${dist_name}=             Set Variable              ${distName_CHANNELGROUP}
        ${version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-1     version
        Set Object                dist_name=${distName_CHANNEL}    class_name=CHANNEL   version=${version}
        Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        # Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
    END
    FOR  ${channelId}  IN RANGE  5   7
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-2/CHANNEL-${channelId}
        ${distName_CHANNELGROUP}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-2
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        ${dist_name}=             Set Variable              ${distName_CHANNELGROUP}
        ${version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-1    version
        Set Object                dist_name=${distName_CHANNEL}    class_name=CHANNEL   version=${version}
        Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=TX
        # Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
    END
    FOR  ${channelId}  IN RANGE  7   9
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-2/CHANNEL-${channelId}
        ${distName_CHANNELGROUP}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-2
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        ${dist_name}=             Set Variable              ${distName_CHANNELGROUP}
        ${version}=   scf.get_mo_attribute    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-1     version
        Set Object                dist_name=${distName_CHANNEL}    class_name=CHANNEL   version=${version}
        Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        # Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=direction  value=RX
        ${distName_resourceDN}=  Set variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${CellId}/PHYANT-1
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=channelId  value=${channelId}
        run keyword if   ${isObject}   Set Element  dist_name=${distName_CHANNEL}  p_name=resourceDN  value=${distName_resourceDN}
    END
    [return]   ${Need_to_Perform_Commissioning}

# ------------------------------------------------------------------------------------------------------------------------------------
# SCF manipulation Common Kw
# ------------------------------------------------------------------------------------------------------------------------------------

Set Element
    [Arguments]      ${dist_name}   ${p_name}   ${value}
    ${element_exist}=         scf.is_element_in_object  dist_name=${dist_name}    p_name=${p_name}
    Run Keyword IF            ${element_exist}
    ...                       scf.modify_scf_element    dist_name=${dist_name}    p_name=${p_name}     value=${value}
    ...         ELSE
    ...                       scf.add_element_to_scf    dist_name=${dist_name}    p_name=${p_name}     value=${value}

Remove Element
    [Documentation]   removes element if exists
    [Arguments]      ${dist_name}   ${p_name}
    ${element_exist}=         scf.is_element_in_object       dist_name=${dist_name}    p_name=${p_name}
    Run Keyword IF            ${element_exist}
    ...                       scf.remove_element_from_scf    dist_name=${dist_name}    p_name=${p_name}

Set Object
    [Arguments]      ${dist_name}   ${class_name}   ${version}=${NIDD_VERSION}
    ${mo_exist}=              scf.is_object_in_scf      dist_name=${dist_name}
    Run Keyword If            ${mo_exist}               scf.remove_mo_with_descendant_mos  dist_name=${dist_name}
    scf.add_object_to_scf     class_name=${class_name}  dist_name=${dist_name}             version=${version}

Remove Object
    [Arguments]               ${dist_name}
    ${mo_exist}=              scf.is_object_in_scf      dist_name=${dist_name}
    Run Keyword If            ${mo_exist}               scf.remove_mo_with_descendant_mos  dist_name=${dist_name}

Set List
    [Arguments]      ${dist_name}   ${list_name}
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}         list_name=${list_name}
    Run Keyword if            ${list_exist}             scf.remove_list_from_scf       dist_name=${dist_name}        list_name=${list_name}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=${list_name}

Set Element To List
    [Arguments]      ${dist_name}   ${list_name}   ${elements}
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}         list_name=${list_name}
    Run Keyword IF            ${list_exist}
    ...                       scf.add elements to list    dist_name=${dist_name}    list_name=${list_name}  elements=${elements}

Set Item To List
    [Arguments]      ${dist_name}   ${list_name}   ${elements}
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}         list_name=${list_name}
    Run Keyword IF            ${list_exist}
    ...                       scf.add item to list    dist_name=${dist_name}    list_name=${list_name}  elements=${elements}

Modify Item To List
    [Arguments]      ${dist_name}   ${list_name}   ${p_name}    ${value}
    ${list_exist}=            scf.is_list_in_object     dist_name=${dist_name}         list_name=${list_name}
    Run Keyword IF            ${list_exist}
    ...                       scf.modify_scf_element    dist_name=${dist_name}    list_name=${list_name}
    ...                                                 p_name=${p_name}     value=${value}

Set New List
    [Documentation]     if exists, otherwise add it
    [Arguments]      ${dist_name}   ${list_name}
    ${list_exist}=            scf.is_list_in_object  dist_name=${dist_name}     list_name=${list_name}
    run keyword if            ${list_exist}==True    scf.remove_list_from_scf  dist_name=${dist_name}   list_name=${list_name}
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=${list_name}

Remove Channels to support 2DL2UL nrCellType
    [Arguments]           ${CellId}=1
    ${Need_to_Perform_Commissioning}   set Variable     ${False}
    FOR  ${channelId}  IN RANGE  5   9
        ${distName_CHANNEL}=  Set variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CellId}/CHANNELGROUP-1/CHANNEL-${channelId}
        ${isObject}=   scf.is_object_in_scf    ${distName_CHANNEL}
        run keyword if   ${isObject}   scf.remove_mo_with_descendant_mos      dist_name=${distName_CHANNEL}
        ${Need_to_Perform_Commissioning}   run keyword if   ${isObject}   set Variable   ${True}
    END
    [return]   ${Need_to_Perform_Commissioning}

Commissioning SCF
    [Tags]                          INIT_AND_TEST
    [Arguments]                     ${ScfFile}
    Dated log                       Commisioning SCF : ${ScfFile}
    File should exist               ${ScfFile}                              SCF file ${ScfFile} not found
    OAM Perform Full Commissioning  scf_file=${ScfFile}
    Dated Log    End commissioning, wait for OAM to come back
    OAM wait available

Get NRCELL Param from SCF
    [Arguments]        ${param}   ${CellId}=1   ${nodeType}=Classical
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${param_value}	 scf.get_value_from_scf   p_name=${param}
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    # ...              nodeType=${nodeType}
    [return]     ${param_value}

Set NRCELL Param ListParam
    [Documentation]
    ...              This KW will help to set CELL param on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${cellId}    ${param_name}   ${param_value}   ${modiflist}
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellId}
    &{modify_param}   Create Dictionary
    ...                          parameter=${param_name}
    ...                          dist_name=${dn}
    ...                          value=${param_value}

    Append To List     ${modiflist}          ${modify_param}
    [return]    ${modiflist}

Get NRCELLGRP Param from SCF
    [Arguments]          ${param_name}  ${CellId}=1  ${nodeType}=Classical
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELLGRP-0
    ${cellGrpId}   Evaluate    ${cellId} - 1
    ${param_value}	 scf.get_value_from_scf   p_name=${param_name}
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cellGrpId}
    # ...              nodeType=${nodeType}
    [return]     ${param_value}

Set NRCELLGRP Param ListParam
    [Documentation]
    ...              This KW will help to set CELL param on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${cellId}    ${param_name}   ${param_value}   ${modiflist}
    ${cellGrpId}   Evaluate    ${cellId} - 1
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cellGrpId}
    &{modify_param}   Create Dictionary
    ...                          parameter=${param_name}
    ...                          dist_name=${dn}
    ...                          value=${param_value}

    Append To List     ${modiflist}          ${modify_param}
    [return]    ${modiflist}

Get NRSYSINFO_PROFILE Param from SCF
    [Arguments]          ${param_name}  ${CellId}=1  ${nodeType}=Classical
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${param_value}	 scf.get_value_from_scf   p_name=${param_name}
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRSYSINFO_PROFILE
    # ...              nodeType=${nodeType}
    [return]     ${param_value}

Set NRSYSINFO_PROFILE Param ListParam
    [Documentation]
    ...              This KW will help to set CELL param on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${cellId}    ${param_name}   ${param_value}   ${modiflist}
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRSYSINFO_PROFILE
    &{modify_param}   Create Dictionary
    ...                          parameter=${param_name}
    ...                          dist_name=${dn}
    ...                          value=${param_value}

    Append To List     ${modiflist}          ${modify_param}
    [return]    ${modiflist}

Get NRBTS Param from SCF
    [Arguments]          ${param_name}  ${CellId}=1  ${nodeType}=Classical
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    ${param_value}	 scf.get_value_from_scf   p_name=${param_name}
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...              nodeType=${nodeType}
    [return]     ${param_value}

Set NRBTS Param ListParam
    [Documentation]
    ...              This KW will help to set CELL param on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${cellId}    ${param_name}   ${param_value}   ${modiflist}
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    &{modify_param}   Create Dictionary
    ...                          parameter=${param_name}
    ...                          dist_name=${dn}
    ...                          value=${param_value}

    Append To List     ${modiflist}          ${modify_param}
    [return]    ${modiflist}

Get NRCELL beamSet Param from SCF
    [Arguments]        ${param}   ${CellId}=1   ${nodeType}=Classical
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${param_value}	 scf.get_value_from_scf   p_name=${param}
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}/beamSet
    # ...              nodeType=${nodeType}
    [return]     ${param_value}

Set NRCELL beamSet Param ListParam
    [Documentation]
    ...              This KW will help to set CELL beamSet param on line
    ...              OAM request is done 1 time with a dictionnary created in a loop
    [Arguments]    ${cellId}    ${param_name}   ${param_value}   ${modiflist}
    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellId}/beamSet
    &{modify_param}   Create Dictionary
    ...                          parameter=${param_name}
    ...                          dist_name=${dn}
    ...                          value=${param_value}

    Append To List     ${modiflist}          ${modify_param}
    [return]    ${modiflist}

Get NRCELL NRRIM_PROFILE-1 Param from SCF
    [Arguments]        ${param}   ${CellId}=1   ${nodeType}=Classical
    # Get SCF File (SCF.xml) in test setup
    ${current_scf_fullname}    set Variable      ${test_scf_file}
    scf.load_scf	 ${current_scf_fullname}
    # MRBTS-1/NRBTS-1/NRCELL-1
    ${param_value}	 scf.get_value_from_scf   p_name=${param}
    ...              dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}/NRRIM_PROFILE-1
    # ...              nodeType=${nodeType}
    [return]     ${param_value}

Get startRbForRs Parameters From gNB
    [Arguments]      ${CellId}=1   ${nodeType}=Classical
    ${startRbForRs_params_list}    Create List    p    p    p    p
    # Get SCF File (SCF.xml) is performed in test setup
    ${scf_path}    set Variable      ${test_scf_file}
    ${startRbForRs_dict}    nps_trf_tools.get_feature_paramters_from_scf    ${scf_path}    ${startRbForRs_params_list}
    ...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}/NRRIM_PROFILE-1    startRbForRs
   [Return]    ${startRbForRs_dict}

Modify dlDataDmrsFdm related Parameters
    [Documentation]                to update dlDataDmrsFdm  (For Classical Only)
    [Arguments]                    ${cellId}   ${actDlDataDmrsFdm}   ${modiflist}

    ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cellId}

    &{dlDataDmrsFdm0}    Create Dictionary     actDlDataDmrsFdm=${actDlDataDmrsFdm}

    @{dlDataDmrsFdm_value}    create list
    Append To List    ${dlDataDmrsFdm_value}    ${dlDataDmrsFdm0}
    &{dlDataDmrsFdm_params}   Create Dictionary   dist_name=${dn}
    ...    parameter=dlDataDmrsFdm
    ...    value=${dlDataDmrsFdm_value}
    dated log          dlDataDmrsFdm_params=${dlDataDmrsFdm_params}

    Append To List     ${modiflist}        ${dlDataDmrsFdm_params}
    [return]   ${modiflist}

Add missing SCF parameters
    [Arguments]          ${CellId}=1
    ${Need_to_Perform_Commissioning}   set Variable   ${True}
    Update local SCF
    scf.load_scf    ${test_scf_file}
    Set Element  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ...          p_name=mMimoAntArrayMode
    ...          value=Full 64TRX Array (4x8x2)
    Set Element  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ...          p_name=actUeCsirsCoexistCellCsirs
    ...          value=false
    &{dict}=    Create Dictionary    basicBeamSet=beamSet_1   leftEdgeAngle=60   nrBtsBeamRefinementP2=false
    ...                              beamsMuted=0   rightEdgeAngle=60   lowerEdgeAngle=45   tiltOffset=0   upperEdgeAngle=45
    scf.remove list from scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}   list_name=beamSet
    scf.add list to scf    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}   list_name=beamSet
    Set Item To List     dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CellId}
    ...                  list_name=beamSet
    ...                  elements=&{dict}
    scf.save_scf    ${test_scf_file}
    Commissioning SCF  ScfFile=${test_scf_file}

# ----------------------------------------------------------------------------- OAM request

Fetch Nidd Version From SCF File
    [Documentation]
    ...    This keyword fetches the NIDD version of NRBTS from current SCF file and create a suite variable with this NIDD version
    [Arguments]    ${scf_gnb}
    ${scf_file}=          OperatingSystem.Get File   ${scf_gnb}
    ${nrbts_nidd_ver}=	  Get Lines Containing String   ${scf_file}	 com.nokia.srbts.nrbts:NRBTS
    ${nrbts_nidd_list}    Split String   ${nrbts_nidd_ver}     "
    ${NIDD_VERSION}=      Evaluate   "${nrbts_nidd_list}[5]".replace("'", "")
    Set Suite Variable    ${NIDD_VERSION}

Get All Cell Group Id
    [Arguments]   ${gnb_id}=0   ${bts_host}=${EMPTY}   ${connection}=coam_gnb
    ${bts_host}=  Set Variable if  '${bts_host}'=='${EMPTY}'  ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}  ${bts_host}
    run Keyword if    '${connection}'=='${EMPTY}'    run Keywords    coam.setup_admin    bts_host=${bts_host}    name=coam_gnb_all_cell
    ...                                                AND           set Variable    ${connection}     coam_gnb_all_cell
    # [Arguments]    ${connection}=GNB_OAM
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    BuiltIn.Log Many      ${cell_info}    level=DEBUG
    ${number_of_cell_group_info}    get length    ${cell_info}
    ${cellgrp_list}    Get Dictionary Keys    ${cell_info}
    @{cellgrp_index_list}    create list
    FOR    ${cellgrp}    IN    @{cellgrp_list}
        ${cellgrp_index}    Fetch from right    ${cellgrp}    -
        ${cellgrp_index}  convert to integer  ${cellgrp_index}
        Append to list    ${cellgrp_index_list}    ${cellgrp_index}
    END
    Sort List   ${cellgrp_index_list}
    [Return]    ${cellgrp_index_list}

Get Cell Group From Cell
    [Arguments]    ${cell_id}    ${connection}=coam_gnb
    ${cellgrp_index_list}    Get All Cell Group Id    connection=${connection}
    FOR   ${cellgrp_index}   IN   @{cellgrp_index_list}
        ${cell_list}   Get Cell From Cell Group   cellgrp_id=${cellgrp_index}   connection=${connection}
        ${cellgrp_id}   Get Cell Group ID from Cell ID   cell_id=${cell_id}   cellgrp_index=${cellgrp_index}   cell_list=${cell_list}
        exit for loop if  "${cellgrp_id}" != "${None}"
    END
    [Return]    ${cellgrp_id}

Get Cell From Cell Group
    # [Arguments]    ${cellgrp_id}    ${connection}=GNB_OAM
    [Arguments]   ${cellgrp_id}     ${gnb_id}=0   ${bts_host}=${EMPTY}    ${connection}=coam_gnb
    ${bts_host}=  Set Variable if  '${bts_host}'=='${EMPTY}'  ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}  ${bts_host}
    run Keyword if    '${connection}'=='${EMPTY}'    run Keywords    coam.setup_admin    bts_host=${bts_host}    name=coam_gnb_all_cell_grp
    ...                                                AND           set Variable    ${connection}     coam_gnb_all_cell_grp
    ${subcells_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${cell_info}    get from dictionary    ${subcells_info}    NRCELLGRP-${cellgrp_id}\
    ${cell_list_info}    Get Dictionary Keys    ${cell_info}
    ${cell_list}  create list
    FOR  ${cell}  IN  @{cell_list_info}
        ${cell_index}    Fetch from right    ${cell}    -
        ${cell_index}    convert to integer    ${cell_index}
        append to list  ${cell_list}  ${cell_index}
    END
    Sort List   ${cell_list}
    [Return]  ${cell_list}

Get Cell Group ID from Cell ID
     [Arguments]    ${cell_id}    ${cellgrp_index}    ${cell_list}
     FOR   ${cell_index}   IN   @{cell_list}
         return from keyword if    '${cell_index}'=='${cell_id}'    ${cellgrp_index}
     END

# ------------------------------------------------------------------------------------------------------------------------------------
# End Of SCF manipulation Common Kw
# ------------------------------------------------------------------------------------------------------------------------------------

gNB_ModifyBtsName
    [Arguments]    ${json_path}    ${btsname_original}=btsNameToChange     ${btsname_new}=btsNameToChange
    run    command=sed -i 's|${btsname_original}|${btsname_new}|g' ${json_path}

Lock Cell${number}
  Dev_lib.delta_commission_parameters   NRCELL-${number}:administrativeState=Locked
  Dev_lib.Cell Should Be Locked  ${number}

Unlock Cell${number}
  Dev_lib.delta_commission_parameters  NRCELL-${number}:administrativeState=Unlocked
  Dev_lib.Cell Should Be Unlocked  ${number}
  Dev_lib.Cells Should Be OnAir  cell_id=${number}

check topology used is ${topo}
    ${reserve_file}=    Set Variable     /opt/ute/reservation.json
    ${file_exist}=      Run Keyword And Return Status    OperatingSystem.file_should_exist    ${reserve_file}
    ${cmd}=   run Keyword if   "${file_exist}"=="True"    Catenate
    ...                                           python -c 'import json;print(json.load(open("${reserve_file}"))["topology"])'
    ${rc}    ${topoUsed}=       run Keyword if   "${file_exist}"=="True"       OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${status}    Run Keyword and Return status     Should Be Equal As Integers    	${rc}	0
    ${topoOK}=   Set Variable If   ${status} and '${topoUsed}'=='${topo}'            ${True}
    ...                                                                              ${False}
    Set test Variable    ${CaptureBIP_Started}    ${False}
    Set test Variable    ${gnb_logs_started}      ${False}
    [return]     ${topoOK}      ${topoUsed}

# ------------------------------------------------------------------------------------------------------------------------------------

Convert TTI trace from pcap to data frame
    [Documentation]
    ...  This keyword converts TTi traces to json then to a pandas data frame and requires the Library taf.converters.eventdecoder and pandas
    ...  | input_file_path | Path to the input file (full Path with Filename) Example ${targed_Dir}/ttitraceStreaming.pcap |
    ...  | events_list | Filter events from the tti trace, leave blank if all events are needed Example: ulTdSchedSubcellData |
    ...  | write_to_pickle | Writes the generated dataframe to a pickle file, the pickle file will have the same name as the input_file_path |

    [Arguments]  ${input_file_path}=${EMPTY}    ${events_list}=${EMPTY}     ${num_of_events}=None    ${write_to_pickle}=${False}
    set_pandas.init_pandas
    ${input_file_path}=  nps_ttitraces_tools.add File ending if missing  file_path=${input_file_path}  file_ending=.pcap
    ${df}=  tti_dataframe.convert_tti_trace_to_df    ${input_file_path}    ${events_list}     ${num_of_events}
    Run Keyword If  ${write_to_pickle}  tti_dataframe.write_df_to_pickle  df=${df}  target_path=${input_file_path}
    [Return]  ${df}

Extract TTI Trace and Convert to Pickle VERSION REF
    [Arguments]  ${path_to_tti_trace_pcap}   ${ttitracepath}
    ${events_required}=  create list  utcTimeStampData   ulTdSchedSubcellData   ulHarqRxData   dlHarqRxDataArray   dlTdSchedSubcellData
    ...                               dlFdSchedData   csiSrReportData   ulFdSchedData    dlAllocatedPooledResourcesData     dlMetricIndData
    ${df}=   Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                 events_list=${events_required}
    # ...                                                 num_of_events=5000
    ...                                                 write_to_pickle=${TRUE}
    Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                         tti_trace_filename=filtered_ttitrace.csv

Convert TTI Traces to Dataframe and store as pickle
    [Arguments]     ${ttitraceFilename}     ${ttitracepath}=/tmp/
    ${path_to_tti_trace_pcap}     set Variable   ${ttitracepath}/${ttitraceFilename}
    Run keyword and continue on failure     Extract TTI Trace and Convert to Pickle
    ...                                                              path_to_tti_trace_pcap=${path_to_tti_trace_pcap}
    ...                                                              ttitracepath=${ttitracepath}
    ${PklFilename}      Remove String      ${ttitraceFilename}     .pcap
    set suite variable    ${path_to_ttitrace_pkl}    ${ttitracepath}/${PklFilename}.pkl
    [return]     ${ttitracepath}/${PklFilename}.pkl

Extract TTI Trace and Convert to Pickle for CB012738
    [Arguments]  ${ttitraceFilename}     ${ttitracepath}=/tmp/
    ${events_required}=  create list  utcTimeStampData   dlMetricIndData   dlAllocatedPooledResourcesData
    ...                               dlFdSchedData   dlHarqRxDataArray     ulFdSchedData   ulHarqRxData   dlFlowControlData
    ...                               dlInterL1SubpoolReconfData
    ${path_to_tti_trace_pcap}=  set Variable   ${ttitracepath}/${ttitraceFilename}
    ${df}=   Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                 events_list=${events_required}
    ...                                                 write_to_pickle=${TRUE}
    Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                         tti_trace_filename=filtered_ttitrace_CB012738_A.csv
    ${PklFilename}      Remove String      ${ttitraceFilename}     .pcap
    set suite variable    ${path_to_ttitrace_pkl_CB012738}    ${ttitracepath}/${PklFilename}.pkl
    OperatingSystem.Run    cp ${ttitracepath}/${PklFilename}.pkl ${ttitracepath}/${PklFilename}_CB012738.pkl
    [return]     ${ttitracepath}/${PklFilename}.pkl

Extract TTI Trace and Convert to Pickle for DL PRB Assignment
    [Arguments]  ${ttitraceFilename}     ${ttitracepath}=/tmp/
    ${events_required}=  create list  utcTimeStampData    dlFdSchedData    csiRsSchedData    dlAllocatedPooledResourcesData
    ${path_to_tti_trace_pcap}=  set Variable   ${ttitracepath}/${ttitraceFilename}
    ${df}=   Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                 events_list=${events_required}
    ...                                                 write_to_pickle=${TRUE}
    Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                         tti_trace_filename=filtered_ttitrace_Dl_Prb_Assign.csv
    ${PklFilename}      Remove String      ${ttitraceFilename}     .pcap
    set suite variable    ${path_to_ttitrace_pkl_CB012738}    ${ttitracepath}/${PklFilename}.pkl
    OperatingSystem.Run    cp ${ttitracepath}/${PklFilename}.pkl ${ttitracepath}/${PklFilename}_Dl_Prb_Assign.pkl
    [return]     ${ttitracepath}/${PklFilename}.pkl

Extract TTI Trace and Convert to Pickle for CB009890
    [Arguments]  ${ttitraceFilename}     ${ttitracepath}=/tmp/
    ${events_required}=  create list  utcTimeStampData   dlMetricIndData   dlAllocatedPooledResourcesData
    ...                               dlFdSchedData   dlHarqRxDataArray     ulFdSchedData   ulHarqRxData   dlFlowControlData
    ...                               dlInterL1SubpoolReconfData
    ${path_to_tti_trace_pcap}=  set Variable   ${ttitracepath}/${ttitraceFilename}
    ${df}=   Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                 events_list=${events_required}
    ...                                                 write_to_pickle=${TRUE}
    Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                         tti_trace_filename=filtered_ttitrace_CB012738.csv
    ${PklFilename}      Remove String      ${ttitraceFilename}     .pcap
    set suite variable    ${path_to_ttitrace_pkl_CB012738}    ${ttitracepath}/${PklFilename}.pkl
    OperatingSystem.Run    cp ${ttitracepath}/${PklFilename}.pkl ${ttitracepath}/${PklFilename}_CB012738.pkl
    [return]     ${ttitracepath}/${PklFilename}.pkl

Extract TTI Trace and Convert to Pickle for CB009890 B
    [Arguments]  ${ttitraceFilename}     ${ttitracepath}=/tmp/
    ${path_to_tti_trace_pcap}     set Variable   ${ttitracepath}/${ttitraceFilename}
    ${events_required}=  create list  utcTimeStampData   dlMetricIndData   dlAllocatedPooledResourcesData   ulAllocatedPooledResourcesData
    ...                               dlFdSchedData   dlTdSchedSubcellData   dlHarqRxDataArray   ulTdSchedSubcellData   ulHarqRxData   ulFdSchedData
    ...                               ulMetricIndData   csiSrReportData   dlFlowControlData
    ${df}=   Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                 events_list=${events_required}
    ...                                                 write_to_pickle=${TRUE}
    Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                         tti_trace_filename=filtered_ttitrace_CB012738_B.csv
    ${PklFilename}      Remove String      ${ttitraceFilename}     .pcap
    set suite variable    ${path_to_ttitrace_pkl}    ${ttitracepath}/${PklFilename}_CB012738_B.pkl
    OperatingSystem.Run    cp ${ttitracepath}/${PklFilename}.pkl ${ttitracepath}/${PklFilename}_CB012738_B.pkl
    [return]     ${ttitracepath}/${PklFilename}_CB012738_B.pkl


Extract TTI Trace and Convert to Pickle for DL Mimo
    [Arguments]  ${ttitraceFilename}     ${ttitracepath}=/tmp/
    ${path_to_tti_trace_pcap}     set Variable   ${ttitracepath}/${ttitraceFilename}
    ${events_required}=  create list  utcTimeStampData   dlMetricIndData
    ...                               dlFdSchedData   dlTdSchedSubcellData   dlHarqRxDataArray   ulTdSchedSubcellData   ulHarqRxData   ulFdSchedData
    ...                               ulMetricIndData   csiSrReportData
    ${df}=   Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                 events_list=${events_required}
    ...                                                 write_to_pickle=${TRUE}
    Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                         tti_trace_filename=filtered_ttitrace_DL_Mimo.csv
    ${PklFilename}      Remove String      ${ttitraceFilename}     .pcap
    set suite variable    ${path_to_ttitrace_pkl}    ${ttitracepath}/${PklFilename}_DL_Mimo.pkl
    OperatingSystem.Run    cp ${ttitracepath}/${PklFilename}.pkl ${ttitracepath}/${PklFilename}_DL_Mimo.pkl
    [return]     ${ttitracepath}/${PklFilename}_DL_Mimo.pkl

Convert TTI Traces to Dataframe and store as pickle for DL Mimo
    [Arguments]     ${ttitraceFilename}     ${ttitracepath}=/tmp/
    ${result}=    Run keyword and continue on failure     Extract TTI Trace and Convert to Pickle for DL Mimo
    ...                                                              ttitraceFilename=${ttitraceFilename}
    ...                                                              ttitracepath=${ttitracepath}
    ${is_tuple}=    Run Keyword And Return Status    Should Be A List    ${result}
    ${FilePkl}=    Run Keyword If    ${is_tuple}    Get From List    ${result}    1    ELSE    Set Variable    ${result}
    [return]   ${FilePkl}

Extract TTI Trace and Convert to Pickle for UL Mimo
    [Arguments]  ${ttitraceFilename}     ${ttitracepath}=/tmp/
    ${path_to_tti_trace_pcap}     set Variable   ${ttitracepath}/${ttitraceFilename}
    ${events_required}=  create list  utcTimeStampData   dlMetricIndData   dlAllocatedPooledResourcesData   ulAllocatedPooledResourcesData
    ...                               dlFdSchedData   dlTdSchedSubcellData   dlHarqRxDataArray   ulTdSchedSubcellData   ulHarqRxData   ulFdSchedData
    ...                               ulMetricIndData   csiSrReportData   dlFlowControlData    csiRsSchedData
    ${df}=   Convert TTI trace from PCAP to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...                                                 events_list=${events_required}
    ...                                                 write_to_pickle=${TRUE}
    Convert TTI trace from data frame to csv    ${df}   ${ttitracepath}
    ...                                         tti_trace_filename=filtered_ttitrace_UL_Mimo.csv
    ${PklFilename}      Remove String      ${ttitraceFilename}     .pcap
    set suite variable    ${path_to_ttitrace_pkl}    ${ttitracepath}/${PklFilename}_UL_Mimo.pkl
    OperatingSystem.Run    cp ${ttitracepath}/${PklFilename}.pkl ${ttitracepath}/${PklFilename}_UL_Mimo.pkl
    [return]     ${ttitracepath}/${PklFilename}_UL_Mimo.pkl

Convert TTI Traces to Dataframe and store as pickle for UL Mimo
    [Arguments]     ${ttitraceFilename}     ${ttitracepath}=/tmp/
    ${result}=    Run keyword and continue on failure     Extract TTI Trace and Convert to Pickle for UL Mimo
    ...                                                              ttitraceFilename=${ttitraceFilename}
    ...                                                              ttitracepath=${ttitracepath}
    ${is_tuple}=    Run Keyword And Return Status    Should Be A List    ${result}
    ${FilePkl}=    Run Keyword If    ${is_tuple}    Get From List    ${result}    1    ELSE    Set Variable    ${result}
    [return]   ${FilePkl}


# ------------------------------------------------------------------------------------------------------------------------------------

Collect PM Counters File
    [Arguments]         ${pm_files_path}=${LOG_PATH}/PM
    BuiltIn.Log     The PM counters file collected from gnb will be stored under : ${pm_files_path}
    ${latest_pm_file_name}   Counters.Collect PM files from BTS  ${pm_files_path}
    set Suite Variable    ${LATEST_FILE}       ${latest_pm_file_name}
    # BuiltIn.Log     \n***Latest pm counters file : ${LATEST_FILE}  console=yes
    Dated Log New Line     ***Latest pm counters file : ${LATEST_FILE}
    # Log to console  \n***Latest pm counters file : ${LATEST_FILE} ***
    [return]    ${latest_pm_file_name}

Collect PM
    Set suite variable    ${pmDir}    ${LOG_PATH}/PM
    Create Directory      ${pmDir}
    Dated log          LOG_PATH/PM:${pmDir}
    ${pm_latest}       Collect PM files from BTS    ${pmDir}
    Set suite variable    ${LATEST_FILE}    ${pm_latest}

Collect PM Counters file coam
   [Arguments]         ${target_dir}=${LOG_PATH}
    BuiltIn.Log To Console    \nuploading pm file from coam
    ${webservice}				Create Dictionary
    ...            host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...            password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...            port=443

    tafpmcounters.create pm collector
    ...    name=gnb_pm_counters
    ...    webservice=${webservice}
    ...    oam_type=coam
    tafpmcounters.setup collectors
    ...    names=gnb_pm_counters
    tafpmcounters.collect collectors
    ...    names=gnb_pm_counters
    ...    target_dir=${target_dir}
    tafpmcounters.teardown collectors
    ...    names=gnb_pm_counters

Check Tput over GP period NSA
    [Documentation]    Computes and checks the Tput UL and DL between start_per_time and end_per_time
    ...                Tputs should be equal to maximum Tputs all along the test, with 5% margin
    [Arguments]    ${nb_cell}=1    ${dl_expected_tput}=550    ${ul_expected_tput}=100

    #M55319C00001: MEAS_PERIOD_NR_PDCP_REPORT1
    #M55319C0200x : DL_VOL_TX_NSA_QOS_GRP_0x: DL PDCP SDU volume transmitted for NSA Bearer - QoS Group 0x: nbre de bytes
    #M55319C02009 : Tput PDCP DL en bytes sur QoS 9
    #M55319C0600x: UL PDCP SDU volume received for NSA Bearer - QoS Group 0x: nbre de bytes
    #M55319C06009: Tput PDCP UL en bytes sur QoS 9

    #M55304C00001: Duration of the measurement period for the NR MAC PDU throughput
    # les compteurs suivants sont en bytes
    #M55304C01001 a 28: Initial transmission volume on PDSCH with 64QAM MCS table using MCS x, i.e Cell PDSCH without retrans Tput
    #M55304C02001 a 28: Initial and retransmission volume on PDSCH with 64QAM MCS table using MCS x, i.e Cell PDSCH with retrans Tput
    #M55304C03001 a 28: Initial transmissions volume on PUSCH with CP-OFDM and 64QAM MCS table using MCS x, i.e Cell PUSCH without retrans Tput
    #M55304C04001 a 28: Initial and retransmission volume on PUSCH with CP-OFDM and 64QAM MCS table using MCS x, i.e Cell PUSCH with retrans Tput
    #M55304C05001 a 28: Initial transmission volume on PDSCH with 256QAM MCS table using MCS x, i.e Cell PDSCH without retrans Tput
    #M55304C06001 a 28: Initial and retransmission volume on PDSCH with 256QAM MCS table using MCS x, i.e Cell PDSCH with retrans Tput

    ${NRCELL_ID}                       set variable       1
    # ${counter_values_M55319C02009}  Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55319C02009   ${NRCELL_ID}
    # ${counter_values_M55319C00001}  Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55319C00001   ${NRCELL_ID}
    ${counter_values_M55319C02009}     Retrieve Latest Single Counter Value From Pm File    ${LATEST_FILE}    M55319C02009
    ${counter_values_M55319C00001}     Retrieve Latest Single Counter Value From Pm File    ${LATEST_FILE}    M55319C00001
    BuiltIn.Log   ***DL PDCP SDU volume transmitted for NSA Bearer - QoS Group 09 (M55319C02009) = ${counter_values_M55319C02009}   console=yes
    BuiltIn.Log   ***Duration of the measurement period for the PDCP Report 1 (M55319C00001) = ${counter_values_M55319C00001}       console=yes

    ${Tput_PDCP_DL}                    set variable        ${counter_values_M55319C02009}
    ${MEAS_PERIOD_NR_PDCP_REPORT1}     set variable        ${counter_values_M55319C00001}

    ${tputDL}=              evaluate        8 * ${Tput_PDCP_DL} / (1000 * ${MEAS_PERIOD_NR_PDCP_REPORT1})
    Dated log          TPUT PDCP DL = ${tputDL} Mbps

    ${counter_values_M55319C06009}     Retrieve Latest Single Counter Value From Pm File     ${LATEST_FILE}   M55319C06009
    BuiltIn.Log   ***UL PDCP SDU volume received for NSA Bearer - QoS Group 09 (M55319C02009) = ${counter_values_M55319C06009}   console=yes
    ${Tput_PDCP_UL}                    set variable        ${counter_values_M55319C06009}

    ${tputUL}=              evaluate        8 * ${Tput_PDCP_UL} / (1000 * ${MEAS_PERIOD_NR_PDCP_REPORT1})
    Dated log          TPUT PDCP uL = ${tputUL} Mbps

    ${dl_min_tput}           evaluate    round(${dl_expected_tput}) * 0.9
    ${ul_min_tput}           evaluate    round(${ul_expected_tput}) * 0.9

    # Should be true    ${tputDL} >= ${dl_min_tput}
    # Should be true    ${tputUL} >= ${ul_min_tput}

Check Tput over GP period SA
    [Documentation]    Computes and checks the Tput UL and DL between start_per_time and end_per_time
    ...                Tputs should be equal to maximum Tputs all along the test, with 5% margin
    [Arguments]    ${nb_cell}=1    ${dl_expected_tput}=550    ${ul_expected_tput}=100

    #M55319C00001: MEAS_PERIOD_NR_PDCP_REPORT1
    #M55319C0200x : DL_VOL_TX_NSA_QOS_GRP_0x: DL PDCP SDU volume transmitted for NSA Bearer - QoS Group 0x: nbre de bytes
    #M55319C02009 : Tput PDCP DL en bytes sur QoS 9
    #M55319C0600x: UL PDCP SDU volume received for NSA Bearer - QoS Group 0x: nbre de bytes
    #M55319C06009: Tput PDCP UL en bytes sur QoS 9

    #M55304C00001: Duration of the measurement period for the NR MAC PDU throughput
    # les compteurs suivants sont en bytes
    #M55304C01001 a 28: Initial transmission volume on PDSCH with 64QAM MCS table using MCS x, i.e Cell PDSCH without retrans Tput
    #M55304C02001 a 28: Initial and retransmission volume on PDSCH with 64QAM MCS table using MCS x, i.e Cell PDSCH with retrans Tput
    #M55304C03001 a 28: Initial transmissions volume on PUSCH with CP-OFDM and 64QAM MCS table using MCS x, i.e Cell PUSCH without retrans Tput
    #M55304C04001 a 28: Initial and retransmission volume on PUSCH with CP-OFDM and 64QAM MCS table using MCS x, i.e Cell PUSCH with retrans Tput
    #M55304C05001 a 28: Initial transmission volume on PDSCH with 256QAM MCS table using MCS x, i.e Cell PDSCH without retrans Tput
    #M55304C06001 a 28: Initial and retransmission volume on PDSCH with 256QAM MCS table using MCS x, i.e Cell PDSCH with retrans Tput

    ${counter_values_M55319C11006}     Retrieve Latest Single Counter Value From Pm File    ${LATEST_FILE}    M55319C11006
    ${counter_values_M55319C00001}     Retrieve Latest Single Counter Value From Pm File    ${LATEST_FILE}    M55319C00001
    BuiltIn.Log   ***DL PDCP SDU volume transmitted for SA Bearer - QoS Group 06 (M55319C11006) = ${counter_values_M55319C11006}   console=yes
    BuiltIn.Log   ***Duration of the measurement period for the PDCP Report 1 (M55319C00001) = ${counter_values_M55319C00001}       console=yes

    ${Tput_PDCP_DL}                    evaluate        int(${counter_values_M55319C11006})
    ${MEAS_PERIOD_NR_PDCP_REPORT1}     evaluate        int(${counter_values_M55319C00001})

    ${tputDL}=              evaluate        8 * ${Tput_PDCP_DL} / (1000 * ${MEAS_PERIOD_NR_PDCP_REPORT1})
    # ${tputDL}=              nps_trf_tools.compute_cell_throughput   pm_value=${Tput_PDCP_DL}  traffic_duration_sec=${MEAS_PERIOD_NR_PDCP_REPORT1}
    Dated log          TPUT PDCP DL = ${consTraceColorBgYellow}${consTraceColorBlack}${tputDL}${defColor} Mbps

    ${counter_values_M55319C16006}     Retrieve Latest Single Counter Value From Pm File     ${LATEST_FILE}   M55319C16006
    BuiltIn.Log   ***UL PDCP SDU volume received for SA Bearer - QoS Group 06 (M55319C16006) = ${counter_values_M55319C16006}   console=yes
    ${Tput_PDCP_UL}                    evaluate        int(${counter_values_M55319C16006})

    ${tputUL}=              evaluate        8 * ${Tput_PDCP_UL} / (1000 * ${MEAS_PERIOD_NR_PDCP_REPORT1})
    # ${tputUL}=              nps_trf_tools.compute_cell_throughput   pm_value=${Tput_PDCP_UL}  traffic_duration_sec=${MEAS_PERIOD_NR_PDCP_REPORT1}
    Dated log          TPUT PDCP UL = ${consTraceColorBgYellow}${consTraceColorBlack}${tputUL}${defColor} Mbps

    ${dl_min_tput}           evaluate    round(${dl_expected_tput}) * 0.9
    ${ul_min_tput}           evaluate    round(${ul_expected_tput}) * 0.9

    # DL RLC data PDU volume transmitted by Low RLC - QoS Group 06 (M55310C01006)
    # UL RLC data PDU volume received by Low RLC - QoS Group 06 (M55310C03006)
    ${counter_values_M55310C01006}     Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55310C01006   CellID=1
    BuiltIn.Log   ***DL RLC PDU volume transmitted by Low RLC - QoS Group 06 (M55310C01006) = ${counter_values_M55310C01006}   console=yes

    ${Tput_RLC_DL}                     evaluate       int(${counter_values_M55310C01006})
    ${MEAS_PERIOD_NR_PDCP_REPORT1}     evaluate       int(${counter_values_M55319C00001})
    ${traffic_duration_sec}            evaluate       int(300)

    ${tputDL}=         nps_trf_tools.compute_cell_throughput   pm_value=${Tput_RLC_DL}  traffic_duration_sec=${traffic_duration_sec}
    ${msg}   Catenate    Observed RLC DL TPUT = ${consTraceColorBgYellow}${consTraceColorBlack}${tputDL}${defColor} Mbps
    ...                   for CellID=${consTraceColorRed}1${defColor}
    Dated log          ${msg}

    ${counter_values_M55310C03006}     Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}   M55310C03006    CellID=1
    BuiltIn.Log   ***UL RLC PDU volume received by Low RLC - QoS Group 06 (M55310C03006) = ${counter_values_M55310C03006}   console=yes
    ${Tput_RLC_UL}                   evaluate       int(${counter_values_M55310C03006})

    ${tputUL}=         nps_trf_tools.compute_cell_throughput   pm_value=${Tput_RLC_UL}  traffic_duration_sec=${traffic_duration_sec}
    ${msg}   Catenate    Observed RLC UL TPUT = ${consTraceColorBgYellow}${consTraceColorBlack}${tputUL}${defColor} Mbps
    ...                   for CellID=${consTraceColorRed}1${defColor}
    Dated log    ${msg}

    # Should be true    ${tputDL} >= ${dl_min_tput}
    # Should be true    ${tputUL} >= ${ul_min_tput}

    ${counter_values_M55310C01006}     Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55310C01006   CellID=2
    BuiltIn.Log   ***DL RLC PDU volume transmitted by Low RLC - QoS Group 06 (M55310C01006) = ${counter_values_M55310C01006}   console=yes

    ${Tput_RLC_DL}                     evaluate        int(${counter_values_M55310C01006})
    ${MEAS_PERIOD_NR_PDCP_REPORT1}     evaluate        int(${counter_values_M55319C00001})

    ${tputDL}=         nps_trf_tools.compute_cell_throughput   pm_value=${Tput_RLC_DL}  traffic_duration_sec=${traffic_duration_sec}
    ${msg}   Catenate    Observed RLC DL TPUT = ${consTraceColorBgYellow}${consTraceColorBlack}${tputDL}${defColor} Mbps
    ...                   for CellID=${consTraceColorRed}2${defColor}
    Dated log          ${msg}

    ${counter_values_M55310C03006}     Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}   M55310C03006    CellID=2
    BuiltIn.Log   ***UL RLC PDU volume received by Low RLC - QoS Group 06 (M55310C03006) = ${counter_values_M55310C03006}   console=yes
    ${Tput_RLC_UL}                    evaluate        int(${counter_values_M55310C03006})

    ${tputUL}=         nps_trf_tools.compute_cell_throughput   pm_value=${Tput_RLC_UL}  traffic_duration_sec=${traffic_duration_sec}
    ${msg}   Catenate    Observed RLC UL TPUT = ${consTraceColorBgYellow}${consTraceColorBlack}${tputUL}${defColor} Mbps
    ...                   for CellID=${consTraceColorRed}2${defColor}
    Dated log          ${msg}

    ${counter_values_M55310C01006}     Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55310C01006   CellID=3
    BuiltIn.Log   ***DL RLC PDU volume transmitted by Low RLC - QoS Group 06 (M55310C01006) = ${counter_values_M55310C01006}   console=yes

    ${Tput_RLC_DL}                     evaluate        int(${counter_values_M55310C01006})
    ${MEAS_PERIOD_NR_PDCP_REPORT1}     evaluate        int(${counter_values_M55319C00001})

    ${tputDL}=         nps_trf_tools.compute_cell_throughput   pm_value=${Tput_RLC_DL}  traffic_duration_sec=${traffic_duration_sec}
    ${msg}   Catenate    Observed RLC DL TPUT = ${consTraceColorBgYellow}${consTraceColorBlack}${tputDL}${defColor} Mbps
    ...                   for CellID=${consTraceColorRed}3${defColor}
    Dated log          ${msg}

    ${counter_values_M55310C03006}     Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}   M55310C03006    CellID=3
    BuiltIn.Log   ***UL RLC PDU volume received by Low RLC - QoS Group 06 (M55310C03006) = ${counter_values_M55310C03006}   console=yes
    ${Tput_RLC_UL}                    evaluate        int(${counter_values_M55310C03006})

    ${tputUL}=         nps_trf_tools.compute_cell_throughput   pm_value=${Tput_RLC_UL}  traffic_duration_sec=${traffic_duration_sec}
    ${msg}   Catenate    Observed RLC UL TPUT = ${consTraceColorBgYellow}${consTraceColorBlack}${tputUL}${defColor} Mbps
    ...                   for CellID=${consTraceColorRed}3${defColor}
    Dated log          ${msg}

Calculate Average throughput per cell using PMC
    [Arguments]  ${validate_with_scenario}  ${cell_dist_name}  ${max_traffic_duration_for_scenario}  ${pmc_index}
    Log to console  Calculating Average throughput for cell: ${cell_dist_name} with pmc_index=${pmc_index}
    ${average_cell_throughput}=  pmcounter_throughput.get_average_cell_throughput_for_interval
    ...  object=${pmc_throughput_obj}
    ...  interval=${pmc_index}
    ...  traffic_duration_sec=${max_traffic_duration_for_scenario}
    ...  cell_dist_name=${cell_dist_name}
    ...  unit=Mbps
    # ...  ondir=${True}
    # put ondir=${False} to process only latest PM file
    ${msg}   Catenate   Observed UL TP:
    ...               ${validate_with_scenario}: ${consTraceColorBgBlue}${consTraceColorYellow}${average_cell_throughput['throughput_ul']}
    ...               ${average_cell_throughput['unit_ul']}${defColor}
    dated log    ${msg}
    ${msg}   Catenate   Observed DL TP:
    ...               ${validate_with_scenario}: ${consTraceColorBgBlue}${consTraceColorYellow}${average_cell_throughput['throughput_dl']}
    ...               ${average_cell_throughput['unit_dl']}${defColor}
    dated log    ${msg}
    [Return]  ${average_cell_throughput}

Calculate Throughput using PM Counters
    [Arguments]  ${cell_distName_params}   ${max_traffic_duration}=300
    ${througput_per_cell}=  Create Dictionary
    ${max_traffic_duration_int}   evaluate   int(${max_traffic_duration})
    FOR  ${cell_dist_name}  IN  @{cell_distName_params}
        ${average_cell_throughput}=  Calculate Average throughput per cell using PMC
        ...  cell_dist_name=${cell_dist_name}
        ...  max_traffic_duration_for_scenario=${max_traffic_duration_int}
        Set to dictionary  ${througput_per_cell}  ${cell_dist_name}=${average_cell_throughput}
    END
    [Return]  ${througput_per_cell}

Calculate BLER per cell using PMC
    [Arguments]  ${validate_with_scenario}  ${cell_dist_name}    ${pmc_index}
    Log to console  Calculating BLER for cell: ${cell_dist_name} with pmc_index=${pmc_index}
    ${cell_bler}=  pmcounter_bler.get_cell_bler_for_interval
    ...  object=${pmc_bler_obj}
    ...  interval=${pmc_index}
    ...  cell_dist_name=${cell_dist_name}
    ...  unit=%
    # ...  ondir=${True}
    # put ondir=${False} to process only latest PM file
    ${msg}   Catenate   Observed Initial UL BLER:
    ...               ${validate_with_scenario}: ${consTraceColorBgBlue}${consTraceColorYellow}${cell_bler['bler_ul']}
    ...               ${cell_bler['unit_ul']}${defColor}
    dated log    ${msg}
    ${msg}   Catenate   Observed Initial DL BLER:
    ...               ${validate_with_scenario}: ${consTraceColorBgBlue}${consTraceColorYellow}${cell_bler['bler_dl']}
    ...               ${cell_bler['unit_dl']}${defColor}
    dated log    ${msg}
    ${msg}   Catenate   Observed Residual UL BLER:
    ...               ${validate_with_scenario}: ${consTraceColorBgBlue}${consTraceColorYellow}${cell_bler['residual_bler_ul']}
    ...               ${cell_bler['unit_ul']}${defColor}
    dated log    ${msg}
    ${msg}   Catenate   Observed Residual DL BLER:
    ...               ${validate_with_scenario}: ${consTraceColorBgBlue}${consTraceColorYellow}${cell_bler['residual_bler_dl']}
    ...               ${cell_bler['unit_dl']}${defColor}
    dated log    ${msg}
    [Return]  ${cell_bler}

Calculate BLER using PM Counters
    [Arguments]  ${cell_distName_params}
    ${bler_per_cell}=  Create Dictionary
    FOR  ${cell_dist_name}  IN  @{cell_distName_params}
        ${cell_bler}=  Calculate BLER per cell using PMC
        ...  cell_dist_name=${cell_dist_name}
        Set to dictionary  ${bler_per_cell}  ${cell_dist_name}=${cell_bler}
    END
    [Return]  ${bler_per_cell}

Check RTPM counter: ${object_name} ${counter_name} (${counter_id}) is equal ${value:\d+}
    Run Keyword And Continue On Failure
    ...  nps_trf_tools.verify_that_rtpm_counter_value_is_equal_to
    ...      object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${object_name}
    ...      counter_id=${counter_id}
    ...      value=${value}

Check RTPM counter: ${object_name} ${counter_name} (${counter_id}) is in range ${lower:\d+} - ${higher:\d+}
    Run Keyword And Continue On Failure
    ...  nps_trf_tools.verify_that_rtpm_counter_value_is_equal_to
    ...      object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${object_name}
    ...      counter_id=${counter_id}
    ...      value=[${lower},${higher}]

Check RTPM counter: ${object_name} ${counter_name} (${counter_id}) is above ${value:\d+}
    Check RTPM counter: ${object_name} ${counter_name} (${counter_id}) is in range ${value} - 9999999

Check RTPM counter TA EMSS: ${object_name} ${counter_name} (${counter_id}) is equal ${value:\d+}
    Run Keyword And Continue On Failure
    ...  ta_emss.Verify that RTPM counter value is equal to
	...    object_name=${object_name}
	...    counter_id=${counter_id}
	...    value=${value}

Check RTPM counters BEAM_RECOVERY_BEAM_ID_0 and SUCC_BEAM_RECOVERY_BEAM_ID_0
    [Documentation]     pm counters collect is performed by "Collect PM Counters and process throughput using PM counters" Kw
    # for CELL1 ....
    # This histogram indicates the distribution of the serving Beam ID (BI) which UE was using before beam recovery was started.
    Check RTPM counter TA EMSS: NRCELL-1 BEAM_RECOVERY_BEAM_ID_0 (M55305C09001) is equal 1
    #This histogram indicates the distribution of the serving Beam ID (BI) which UE was using before beam recovery was started for successful beam
    #recoveries.
    Check RTPM counter TA EMSS: NRCELL-1 SUCC_BEAM_RECOVERY_BEAM_ID_0 (M55305C10001) is equal 1
    # for CELL2 ....
    # This histogram indicates the distribution of the serving Beam ID (BI) which UE was using before beam recovery was started.
    Check RTPM counter TA EMSS: NRCELL-2 BEAM_RECOVERY_BEAM_ID_0 (M55305C09001) is equal 0
    #This histogram indicates the distribution of the serving Beam ID (BI) which UE was using before beam recovery was started for successful beam
    #recoveries.
    Check RTPM counter TA EMSS: NRCELL-2 SUCC_BEAM_RECOVERY_BEAM_ID_0 (M55305C10001) is equal 0

Check RTPM counters BEAM_RECOVERY_BEAM_ID_0 and SUCC_BEAM_RECOVERY_BEAM_ID_0 Version 1
    [Documentation]     pm counters collect is performed by "Collect PM Counters and process throughput using PM counters" Kw
    ${pm_files_path}=      Set Variable     ${testCaseDir}/PMC/pm_files
    ${files_pm_list}    List Directory    ${pm_files_path}
    FOR    ${pm_file_name}    IN    @{files_pm_list}
        Continue for loop If      '.raw' in ${pm_file_name}
        set Suite Variable    ${LATEST_FILE}       ${pm_file_name}
        # for CELL1 ....
        # This histogram indicates the distribution of the serving Beam ID (BI) which UE was using before beam recovery was started.
        Check RTPM counter TA EMSS: NRCELL-1 BEAM_RECOVERY_BEAM_ID_0 (M55305C09001) is equal 1
        #This histogram indicates the distribution of the serving Beam ID (BI) which UE was using before beam recovery was started
        #for successful beamrecoveries.
        Check RTPM counter TA EMSS: NRCELL-1 SUCC_BEAM_RECOVERY_BEAM_ID_0 (M55305C10001) is equal 1
        # for CELL2 ....
        # This histogram indicates the distribution of the serving Beam ID (BI) which UE was using before beam recovery was started.
        Check RTPM counter TA EMSS: NRCELL-2 BEAM_RECOVERY_BEAM_ID_0 (M55305C09001) is equal 0
        #This histogram indicates the distribution of the serving Beam ID (BI) which UE was using before beam recovery was started
        #for successful beam recoveries.
        Check RTPM counter TA EMSS: NRCELL-2 SUCC_BEAM_RECOVERY_BEAM_ID_0 (M55305C10001) is equal 0
    	# Exit For Loop
    END

Kw Counter check negative values
    [Arguments]   ${nrcell}     ${countersExtract}
    append to file   ${resultFile}   \n\tCounter check: negative values\n
    FOR   ${counter}   IN    @{counterstocheck}
        ${status}   evaluate    ${countersExtract}[${nrcell}][${counter}] >= 0
        run keyword if   ${status}   append to file   ${resultFile}      \t\t${counter} (${countersExtract}[${nrcell}][${counter}]) OK\n
        ...  ELSE  run keywords   Run Keyword And Continue On Failure  fail   \nCounter check failed: Negative value for ${counter}  AND
        ...  append to file   ${resultFile}      \t\t${counter} (${countersExtract}[${nrcell}][${counter}]) not OK\n
    END

Kw Counter check zero values
    [Arguments]   ${nrcell}     ${countersExtract}
    append to file   ${resultFile}      \n\tCounter check: zero values\n
    FOR   ${counter}   IN    @{counterstocheck}
        ${status}   evaluate    ${countersExtract}[${nrcell}][${counter}] == 0
        run keyword if   not(${status})   append to file   ${resultFile}      \t\t${counter} (${countersExtract}[${nrcell}][${counter}]) OK\n
        ...  ELSE  run keywords   Run Keyword And Continue On Failure  fail   \nCounter check failed: Zero value for ${counter}  AND
        ...  append to file   ${resultFile}      \t\t${counter} (${countersExtract}[${nrcell}][${counter}]) not OK\n
    END

Kw Counter validation
    [Arguments]   ${nrcell}     ${countersExtract}
    append to file   ${resultFile}      \n\tCounter check: M55308C10005 <= M55308C10003
    ${status}   evaluate    ${countersExtract}[${nrcell}][M55308C10005] <= ${countersExtract}[${nrcell}][M55308C10003]
    run keyword if   ${status}   append to file   ${resultFile}
    ...    \tOK\n\t\tM55308C10005: ${countersExtract}[${nrcell}][M55308C10005], M55308C10003: ${countersExtract}[${nrcell}][M55308C10003]\n
    ...  ELSE  run keywords   Run Keyword And Continue On Failure  fail   \nCounter check failed: M55308C10005 <= M55308C10003  AND
    ...  append to file   ${resultFile}
    ...    \tnot OK\n\t\tM55308C10005: ${countersExtract}[${nrcell}][M55308C10005]\n\t\tM55308C10003: ${countersExtract}[${nrcell}][M55308C10003]\n

Set Counters Extract Value
    [Arguments]    ${countersExtract}    ${nrcell}    ${counter}    ${value}
    # Set To Dictionary    ${countersExtract}[${nrcell}][${counter}]    ${value}
    ${counter_cell}=     Create Dictionary
    Set To Dictionary    ${counter_cell}   ${counter}    ${value}
    Set To Dictionary    ${countersExtract}    ${nrcell}   ${counter_cell}
    [Return]     ${countersExtract}

loop over counters
    [Arguments]   ${cell_dist_name}    ${nrcell}    ${counterstocheck}    ${countersExtract}
    FOR   ${counter}   IN    @{counterstocheck}
        ${counter_cell}    get_counter_value       ${cell_dist_name}    ${counter}
        ${text}=    Catenate     for ${consTraceColorBgBlue}NRCELL-${nrcell}${defColor}
        dated log   ${counter}=${consTraceColorBgBlue}${counter_cell}${defColor} ${text}
        ${countersExtract}     Set Counters Extract Value    ${countersExtract}   ${nrcell}   ${counter}    ${counter_cell}
        # ${countersExtract}[${nrcell}][${counter}]    set variable    ${counter_cell}
    END
    [Return]    ${countersExtract}

Collect PM Counters and process throughput using PM counters
    Return From Keyword If        '${SKIP_COUNTERS}' == '0'
    Dated log     =========> Collect PM Counters File
    TARF-Keywords.Collect PM Counters File   pm_files_path=${testCaseDir}/PMC
    Get Cell Dist Parameters
    Dated log     =========> Calculate Throughput using PM Counters
    ${througput_per_cell}=   Calculate Throughput using PM Counters    ${cell_distName_params}
    nps_trf_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${througput_per_cell}    filename=pmc_average_tp_per_cell.json
    Dated log     =========> Calculate BLER using PM Counters
    ${bler_per_cell}=   Calculate BLER using PM Counters    ${cell_distName_params}
    nps_trf_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                      dictionary=${bler_per_cell}    filename=pmc_bler_per_cell.json
    robot_extension.Run Keyword And Warn On Failure    TARF-Keywords.Collect PM Counters file coam   target_dir=${testCaseDir}

Collect PM Counters and process version1
    @{counterstocheck}   Create List    M55308C00001   M55308C10001   M55308C10003   M55308C10005
    @{countersDesc}      Create List    M55308C00001: Sum of DL Data slots
    ...                                 M55308C10001: Number of PRBs used for PDSCH
    ...                                 M55308C10003: Number of PRBs available for PDSCH
    ...                                 M55308C10005: Number of PRBs available for PDSCH with L1 PRB Pooling
    @{nrCellId}      Create List     1   2   3   4
    ${i_cell}        set variable     ${0}
    ${countersExtract}=      Create Dictionary
    FOR  ${cell_dist_name}  IN  @{cell_distName_params}
        ${nrcell}=     set Variable     @{nrCellId}[${i_cell}]
        ${i_cell}=     Evaluate     ${i_cell} + ${1}
        ${countersExtract}=     loop over counters    cell_dist_name=${cell_dist_name}    nrcell=${nrcell}
        ...                                           counterstocheck=${counterstocheck}    countersExtract=${countersExtract}
    END

    FOR  ${counters}  IN  @{countersDesc}
         Append To File   ${resultFile}   \n${counters}
    END
    Append To File   ${resultFile}   \n
    FOR  ${cellId}  IN  @{nrCellId}
        append to file   ${resultFile}   \nNRCELL-${cellId}\n
        Kw Counter check negative values   NRCELL-${cellId}    ${countersExtract}
        Kw Counter check zero values   NRCELL-${cellId}    ${countersExtract}
        Kw Counter validation  NRCELL-${cellId}    ${countersExtract}
    END

Collect PM Counters and process with counters verification
    @{nrCellId}      Create List     1   2   3   4
    @{counterstocheck}   Create List    M55308C00001   M55308C10001   M55308C10003   M55308C10005
    @{countersDesc}      Create List    M55308C00001: Sum of DL Data slots
    ...                                 M55308C10001: Number of PRBs used for PDSCH
    ...                                 M55308C10003: Number of PRBs available for PDSCH
    ...                                 M55308C10005: Number of PRBs available for PDSCH with L1 PRB Pooling
    set test variable     ${nrCellId}
    set test variable     ${counterstocheck}
    set test variable     ${countersDesc}
    BuiltIn.Run Keyword And Warn On Failure    resources.wait for new pm filename and display ue stats nr
    ...                                                               raw_file=${False}    timeout=${600}
    ${start_time}           Get Time        epoch
    ${MeasPeriodToCheck}    Evaluate    (${start_time}//300)*300
    ${MeasPeriodToCheck}    convert to string   ${MeasPeriodToCheck}
    BuiltIn.Run Keyword And Warn On Failure    resources.wait for new pm filename and display ue stats nr
    ...                                                               raw_file=${False}    timeout=${600}
    ${countersData}  coam.get_counters_info  connection=coam_gnb  timeout=3min   dist_name=BTS/MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ${counter_groups} =    Get From Dictionary    ${countersData}      BTS
    ${counter_groups} =    Get From Dictionary    ${counter_groups}    MRBTS-${MRBTS_ID}
    ${counter_groups} =    Get From Dictionary    ${counter_groups}    NRBTS-${NRBTS_ID}
    ${counter_groups} =    Get From Dictionary    ${counter_groups}    NRCELL-1
    ${counter_groups} =    Get From Dictionary    ${counter_groups}    NCELA
    ${counter_groups} =    Get From Dictionary    ${counter_groups}    M55308C10003
    # dated log     counter_groups=${counter_groups}
    ${countersExtract}   nps_trf_tools.FnGetNrCellCounter  ${countersData}  MRBTS-${MRBTS_ID}  NRBTS-${NRBTS_ID}  ${nrCellId}
    ...                                                       NCELA  ${counterstocheck}    ${MeasPeriodToCheck}
    dated log      countersExtract=${countersExtract}
    FOR  ${counters}  IN  @{countersDesc}
         Append To File   ${resultFile}   \n${counters}
    END
    Append To File   ${resultFile}   \n
    FOR  ${cellId}  IN  @{nrCellId}
        Kw Counter check negative values   NRCELL-${cellId}    ${countersExtract}
        Kw Counter check zero values   NRCELL-${cellId}    ${countersExtract}
        Kw Counter validation  NRCELL-${cellId}    ${countersExtract}
    END
    # ${type_countersExtract}     Evaluate      type(${countersExtract})
    # dated log      type_countersExtract=${type_countersExtract}
    run Keyword and ignore error     nps_trf_tools.write_dictionary_to_json  dir_path=${testCaseDir}/
    ...                                          dictionary=${countersExtract}    filename=pmc_9836_counters_verification.json

# ------------------------------------------------------------------------------------------------------------------------------------

Extract Usefull info from itf_l2_ps_cell_cellsetupreq Pcap
    [Arguments]                     ${File}    ${subdir}
    [Documentation]                 Extract itf_l2_ps_cell_cellsetupreq info from Pcap

    Dated log                   Extract itf_l2_ps_cell_cellsetupreq info from PCAP file [${File}]

    set test variable   ${pcapprocessed_itf_l2_ps_cell_cellsetupreq}    pcapprocessed_Extract_pcapprocessed_itf_l2_ps_cell_cellsetupreq.txt
    set test variable   ${pcapprocessed_itf_l2_ps_cell_cellsetupreq_path}  ${testCaseDir}/${pcapprocessed_itf_l2_ps_cell_cellsetupreq}
    ${cmd1}=   set variable     tshark
    ${cmd}    catenate      ${cmd1} -r
    ...        ${File} -T fields -Y "itf_l2_ps_cell_cellsetupreq" -e _ws.col.Info
    ...           -e itf_l2_ps_cell_CellSetupReq_t.physCellId
    ...           -e itf_l2_ps_cell_CellSetupReq_t.lcrId
    ...           -e 3gpp.subcellid
    ...           -E header=y -E separator=';' > ${pcapprocessed_itf_l2_ps_cell_cellsetupreq_path}
    Run       ${cmd}
    # remove space if present
    Run      command=sed -i -e 's/ //g' ${pcapprocessed_itf_l2_ps_cell_cellsetupreq_path}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_itf_l2_ps_cell_cellsetupreq_path}   _ws.col.Info
    ${pattern}=     set variable   itf_l2_ps_cell_CellSetupReq
    ${extract}  OperatingSystem.grep file  ${pcapprocessed_itf_l2_ps_cell_cellsetupreq_path}
    ...                                    ${pattern}
    run keyword if  len($extract)==1 or len($extract)==0     fail   itf_l2_ps_cell_CellSetupReq not found
    OperatingSystem.copy file    ${pcapprocessed_itf_l2_ps_cell_cellsetupreq_path}
    ...                          ${testCaseDir}/${subdir}/msg_itf_l2_ps_cell_cellsetupreq_pcap.csv

Convert PCAP to PDML
    [Documentation]
    ...
    ...    | source             | Path to the pcap file that has to be converted to pdml |
    ...    | target             | Path where the converted pdml file has to be stored |
    ...    | filter             | Define message filter  eg. "dldata_csirssendreq || uldata_pucchreceivereq || uldata_pucchreceiverespps" |
    ...    | option             | User defined options for tshark can be included here |
    ...
    [Arguments]  ${source}  ${target}  ${filter}=${EMPTY}  ${option}=${EMPTY}

    TARF-Keywords.Connect to TestPC  alias=testPC_pdmlconversion
    ${filter_arg}=    Set variable if    '${filter}'!='${EMPTY}'    -Y ${filter}    ${EMPTY}
    ${command}=  Set Variable      tshark -r "${source}" ${option} -T pdml ${filter_arg} >"${target}_"
    ssh.send_command  ${command}  connection=testPC_pdmlconversion
    ssh.await execution end  connection=testPC_pdmlconversion  timeout=60min
    nps_trf_tools.strip headers  source_file=${target}_  target_file=${target}
    ssh.send command  sudo rm ${target}_  connection=testPC_pdmlconversion
    ssh.await execution end  connection=testPC_pdmlconversion  timeout=5min
    [Return]    ${target}
    [Teardown]  ssh.disconnect  connection=testPC_pdmlconversion

verify CellSetup SysCom Traces
    [Arguments]    ${isCaptureCPRT}=${False}
    return from keyword if   ${isCaptureCPRT}==${False}
    testcase-Keywords.Prepare Logs Directory Path    subdir=syscom
    ${cmd}=   Catenate    basename ${CaptureCPRT.path}
    ${file_name}=   OperatingSystem.Run   ${cmd}
    Extract Usefull info from itf_l2_ps_cell_cellsetupreq Pcap   File=${testCaseDir}/${file_name}   subdir=syscom
    ${PdmlFilename}      Remove String      ${file_name}     .pcap
    Convert PCAP to PDML     source=${testCaseDir}/${file_name}
    ...                      filter="sctp"
    ...                      target=${testCaseDir}/syscom/${PdmlFilename}.pdml
    set test variable       ${path_to_syscom_pdml}    ${testCaseDir}/syscom/${PdmlFilename}.pdml
    run keyword and ignore error    verify_CellSetup_SysCom_Pdml_Traces

Check NumMinPrbAlloc and NumMaxPrbAlloc in Dl PrbPoolingAllocationReport
#     [Arguments]             ${param}
    ${numRbForRs_scf}=   Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=numRbForRs   CellId=1
    ${numRbForRs}=     Set Variable If     '${numRbForRs_scf}' == '48 RBs'    48
    ...                                                                       96
    CB011028-D-Keywords.Verification of Number PRB Allocated within PRB Pooling Report with RIM-RS
    ...                                                             num_min_prb=${numRbForRs}
    ...                                                             num_max_prb=546
    ...                                                             prereq_data=${COL_NAME_NRCELLID}
    ...                                                             prereq_value=0x4001
    ...                                                             direction=Dl
    ${numRbForRs_scf}=   Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=numRbForRs   CellId=2
    ${numRbForRs}=     Set Variable If     '${numRbForRs_scf}' == '48 RBs'    48
    ...                                                                       96
    CB011028-D-Keywords.Verification of Number PRB Allocated within PRB Pooling Report with RIM-RS
    ...                                                             num_min_prb=${numRbForRs}
    ...                                                             num_max_prb=273
    ...                                                             prereq_data=${COL_NAME_NRCELLID}
    ...                                                             prereq_value=0x4002
    ...                                                             direction=Dl
    ${numRbForRs_scf}=   Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=numRbForRs   CellId=3
    ${numRbForRs}=     Set Variable If     '${numRbForRs_scf}' == '48 RBs'    48
    ...                                                                       96
    CB011028-D-Keywords.Verification of Number PRB Allocated within PRB Pooling Report with RIM-RS
    ...                                                             num_min_prb=${numRbForRs}
    ...                                                             num_max_prb=546
    ...                                                             prereq_data=${COL_NAME_NRCELLID}
    ...                                                             prereq_value=0x4003
    ...                                                             direction=Dl
    ${numRbForRs_scf}=   Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=numRbForRs   CellId=4
    ${numRbForRs}=     Set Variable If     '${numRbForRs_scf}' == '48 RBs'    48
    ...                                                                       96
    CB011028-D-Keywords.Verification of Number PRB Allocated within PRB Pooling Report with RIM-RS
    ...                                                             num_min_prb=${numRbForRs}
    ...                                                             num_max_prb=273
    ...                                                             prereq_data=${COL_NAME_NRCELLID}
    ...                                                             prereq_value=0x4004
    ...                                                             direction=Dl

Check NumMinPrbAlloc and NumMaxPrbAlloc in Dl PrbPoolingAllocationReport Version1 not compliant with RIM-RS
#     [Arguments]             ${param}
    ${numRbForRs_scf}=   Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=numRbForRs   CellId=1
    ${numRbForRs}=     Set Variable If     '${numRbForRs_scf}' == '48 RBs'    48
    ...                                                                       96
    CB011028-D-Keywords.Verification of Number PRB Allocated within PRB Pooling Report
    ...                                                             num_min_prb=${numRbForRs}
    ...                                                             num_max_prb=546
    ...                                                             prereq_data=${COL_NAME_NRCELLID}
    ...                                                             prereq_value=0x4001
    ...                                                             direction=Dl
    ${numRbForRs_scf}=   Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=numRbForRs   CellId=2
    ${numRbForRs}=     Set Variable If     '${numRbForRs_scf}' == '48 RBs'    48
    ...                                                                       96
    CB011028-D-Keywords.Verification of Number PRB Allocated within PRB Pooling Report
    ...                                                             num_min_prb=${numRbForRs}
    ...                                                             num_max_prb=273
    ...                                                             prereq_data=${COL_NAME_NRCELLID}
    ...                                                             prereq_value=0x4002
    ...                                                             direction=Dl
    ${numRbForRs_scf}=   Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=numRbForRs   CellId=3
    ${numRbForRs}=     Set Variable If     '${numRbForRs_scf}' == '48 RBs'    48
    ...                                                                       96
    CB011028-D-Keywords.Verification of Number PRB Allocated within PRB Pooling Report
    ...                                                             num_min_prb=${numRbForRs}
    ...                                                             num_max_prb=546
    ...                                                             prereq_data=${COL_NAME_NRCELLID}
    ...                                                             prereq_value=0x4003
    ...                                                             direction=Dl
    ${numRbForRs_scf}=   Get NRCELL NRRIM_PROFILE-1 Param from SCF   param=numRbForRs   CellId=4
    ${numRbForRs}=     Set Variable If     '${numRbForRs_scf}' == '48 RBs'    48
    ...                                                                       96
    CB011028-D-Keywords.Verification of Number PRB Allocated within PRB Pooling Report
    ...                                                             num_min_prb=${numRbForRs}
    ...                                                             num_max_prb=273
    ...                                                             prereq_data=${COL_NAME_NRCELLID}
    ...                                                             prereq_value=0x4004
    ...                                                             direction=Dl

Verification of Number PRB Allocated within PRB Pooling Report
    [Documentation]
    ...     Conditions:     it is based on the arguments ${num_min_prb} ${num_max_prb} ${num_prb_alloc} ${prereq_data} ${prereq_value} ${result_req}
    ...                     ${check_operator}
    ...     Actions:        it verifies all the numMinPrbAlloc, numMaxPrbAlloc and numPrbAlloc values of the recommended data
    ...     Checks:         it checks the values within PRB Pooling Allocation SubPool Report
    ...     Verdict:        numMinPrbAlloc, numMaxPrbAlloc and numPrbAlloc values are as expected
    [Arguments]             ${num_min_prb}=${NUM_MIN_PRB_DEFAULT}
    ...                     ${num_max_prb}=${NUM_MAX_PRB_DEFAULT}
    ...                     ${num_prb_alloc}=${NUM_MAX_PRB_DEFAULT}
    ...                     ${prereq_data}=${COL_NAME_SUBPOOLID}
    ...                     ${prereq_value}=0
    ...                     ${result_req}=True
    ...                     ${check_operator}===
    ...                     ${direction}=Dl

    ${file_path_report}     Set Variable        ${direction}_PrbPoolingAllocationReport_45_.csv
    # numMinPrbAlloc
    @{listOfValues}         Create List         ${num_min_prb}
    Dated Log New Line      Check if ${COL_NAME_NUMMINPRBALLOC}=${listOfValues} for ${prereq_data}=${prereq_value}
    Dated Log               ${file_path_report}
    ${verif_result}         Verify Value List In csv File Column
    ...                                         CsvName=${file_path_report}
    ...                                         Column_name=${COL_NAME_NUMMINPRBALLOC}
    ...                                         value_list=${listOfValues}
    ...                                         prereq_column=${prereq_data}
    ...                                         prereq_column_val=${prereq_value}
    Run Keyword If          ${verif_result} == True
    ...                     Dated Log    ${direction} Num Min PRB Alloc is equal to ${num_min_prb} for ${prereq_data}=${prereq_value}
    ...         ELSE        Dated Log    ${direction} Num Min PRB Alloc IS NOT EQUAL TO ${num_min_prb} for ${prereq_data}=${prereq_value}
    should be true          ${verif_result} == True
    # numMaxPrbAlloc
    @{listOfValues}         Create List         ${num_max_prb}
    Dated Log New Line      Check if ${COL_NAME_NUMMAXPRBALLOC}=${listOfValues} for ${prereq_data}=${prereq_value}
    Dated Log               ${file_path_report}
    ${verif_result}         Verify Value List In csv File Column
    ...                                         CsvName=${file_path_report}
    ...                                         Column_name=${COL_NAME_NUMMAXPRBALLOC}
    ...                                         value_list=${listOfValues}
    ...                                         prereq_column=${prereq_data}
    ...                                         prereq_column_val=${prereq_value}
    Run Keyword If          ${verif_result} == True
    ...                     Dated Log    ${direction} Num Max PRB Alloc is equal to ${num_max_prb} for ${prereq_data}=${prereq_value}
    ...         ELSE        Dated Log    ${direction} Num Max PRB Alloc IS NOT EQUAL TO ${num_max_prb} for ${prereq_data}=${prereq_value}
    should be true          ${verif_result} == True

Verification of Number PRB Allocated within PRB Pooling Report with RIM-RS
    [Documentation]
    ...     Conditions:     it is based on the arguments ${num_min_prb} ${num_max_prb} ${num_prb_alloc} ${prereq_data} ${prereq_value} ${result_req}
    ...                     ${check_operator}
    ...     Actions:        it verifies all the numMinPrbAlloc, numMaxPrbAlloc and numPrbAlloc values of the recommended data
    ...     Checks:         it checks the values within PRB Pooling Allocation SubPool Report
    ...     Verdict:        numMinPrbAlloc, numMaxPrbAlloc and numPrbAlloc values are as expected
    [Arguments]             ${num_min_prb}=${NUM_MIN_PRB_DEFAULT}
    ...                     ${num_max_prb}=${NUM_MAX_PRB_DEFAULT}
    ...                     ${num_prb_alloc}=${NUM_MAX_PRB_DEFAULT}
    ...                     ${prereq_data}=${COL_NAME_SUBPOOLID}
    ...                     ${prereq_value}=0
    ...                     ${result_req}=True
    ...                     ${check_operator}===
    ...                     ${direction}=Dl

    ${file_path_report}     Set Variable        ${direction}_PrbPoolingAllocationReport_45_.csv
    # numMinPrbAlloc where RIM_RS is present
    @{listOfValues}         Create List         ${num_min_prb}
    Dated Log New Line      Check if ${COL_NAME_NUMMINPRBALLOC}=${listOfValues} for ${prereq_data}=${prereq_value} where RIM-RS present
    Dated Log               ${file_path_report}
    ${verif_result}         verify_numminprb_for_cellid_where_rim_rs_is_present_in_csv_File
    ...                                         CsvName=${file_path_report}
    ...                                         NRCellid=${prereq_value}
    ...                                         expected_values_rim_rs=${num_min_prb}
    ...                                         expected_values_no_rim_rs=48
    Run Keyword If          '${verif_result}' == 'passed'
    ...                     Dated Log    ${direction} Num Min PRB Alloc is equal to ${num_min_prb} for ${prereq_data}=${prereq_value}
    ...         ELSE        Dated Log    ${direction} Num Min PRB Alloc IS NOT EQUAL TO ${num_min_prb} for ${prereq_data}=${prereq_value}
    should be true          '${verif_result}' == 'passed'
    # numMaxPrbAlloc
    @{listOfValues}         Create List         ${num_max_prb}
    Dated Log New Line      Check if ${COL_NAME_NUMMAXPRBALLOC}=${listOfValues} for ${prereq_data}=${prereq_value}
    Dated Log               ${file_path_report}
    ${verif_result}         Verify Value List In csv File Column
    ...                                         CsvName=${file_path_report}
    ...                                         Column_name=${COL_NAME_NUMMAXPRBALLOC}
    ...                                         value_list=${listOfValues}
    ...                                         prereq_column=${prereq_data}
    ...                                         prereq_column_val=${prereq_value}
    Run Keyword If          ${verif_result} == True
    ...                     Dated Log    ${direction} Num Max PRB Alloc is equal to ${num_max_prb} for ${prereq_data}=${prereq_value}
    ...         ELSE        Dated Log    ${direction} Num Max PRB Alloc IS NOT EQUAL TO ${num_max_prb} for ${prereq_data}=${prereq_value}
    should be true          ${verif_result} == True

# "STEP Number; Tput UE1; Tput UE2; Tput UE3; Tput UE4; Tput UE5; Tput UE6"
Create Header Csv Tput Test result
  [Arguments]                    ${text}=""
    ${testCase}    Replace String    ${TEST_NAME[0:30]}    ${SPACE}    _
    ${testCase}    Replace String    ${testCase}    .    _
    ${testCase}    Remove String     ${testCase}    [1]
    ${testCase}    Remove String     ${testCase}    [1.0]
    ${testCase}    Remove String     ${testCase}    [2.0]
    ${testCase}    Remove String     ${testCase}    [
    ${testCase}    Remove String     ${testCase}    ]
    ${text}        Catenate   "STEP Number; DL Tput UE1 (Mbps); UL Tput UE1 (Mbps); DL Tput UE2 (Mbps); UL Tput UE2 (Mbps);
    ...                        DL Tput UE3(Mbps) ; UL Tput UE3 (Mbps);
    ...                        DL Tput UE4(Mbps); UL Tput UE4(Mbps); DL Tput UE5(Mbps); UL Tput UE5(Mbps); DL Tput UE6(Mbps); UL Tput UE6(Mbps)"
    Run Keyword And Ignore Error    OperatingSystem.touch    ${testCaseDir}/TestResults_Tput_${testCase}.csv
    Run Keyword And Ignore Error    OperatingSystem.run      echo ${text} > ${testCaseDir}/TestResults_Tput_${testCase}.csv
    set suite variable      ${csv_file_tput_results}       ${testCaseDir}/TestResults_Tput_${testCase}.csv

Log Test Tput results
    [Arguments]                    ${text}   ${file}
    Run Keyword And Ignore Error    OperatingSystem.run      echo "${text}" >> ${file}

# ------------------------------------------------------------------------------------------------------------------------------------
# ADMIN Common Kw
# ------------------------------------------------------------------------------------------------------------------------------------

Admin Validate SCF
    [Documentation]
    ...  KW for SCF validation. SCF can be provided as input argument:
    ...  - if valued with absolute file path of stored SCF
    ...  - if empty, current SCF will be collected and validated.
    ...
    ...  | Parameter          | Man. | Description                                                     |
    ...  | scf_path_file      | No   | SCF file path                                                   |
    ...  | skip_param_rel_err | No   | skip parameter relation errors                                  |
    ...  | alias              | No   | alias of admin instance                                         |
    ...  | export_type        | No   | configuration, configurationAndRuntimeObjects or runtimeObjects |
    ...  | timeout            | No   | time to wait for positive procedure result                      |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                        |
    ...  | definition_errors_file | Path to definition_errors_file.txt |
    ...  | relation_errors_file   | Path to relation_errors_file.txt   |
    ...  | hardware_errors_file   | Path to hardware_errors_file.txt   |
    ...
    [Arguments]  ${scf_path_file}=${EMPTY}  ${skip_param_rel_err}=${TRUE}  ${alias}=coam_gnb
    ...    ${export_type}=configuration  ${timeout}=180    ${dir}=None

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  BuiltIn.Get Time  format=year,month,day,hour,min,sec
    ${scf_file_name}=  Set Variable  SCF_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.xml
    ${testCaseDir_result}=    Set Variable If    '${dir}'!='None'     ${dir}     ${testCaseDir}
    ${scf_path_file}=  Run Keyword If  '${scf_path_file}' == '${EMPTY}'
    ...  Set Variable  ${testCaseDir_result}/SCF_Validation/${scf_file_name}
    ...  ELSE  Set Variable  ${scf_path_file}

    ${scf_path_folder}  ${scf_name}=  Split Path  ${scf_path_file}

    Run Keyword If  '${scf_path_file}' != '${EMPTY}'
    ...               COAM Get SCF      local_dir_path=${scf_path_folder}   file=${scf_file_name}   alias=${alias}

    BuiltIn.Log  ${\n}=============  console=True
    BuiltIn.Log  Validate SCF: ${scf_path_file}  console=True
    ${LOOP}=    Set Variable     1
    FOR  ${cycle}  IN RANGE  1  ${LOOP}+1
        BuiltIn.Log  ${\n}=====================  console=True
        BuiltIn.Log  SCF Validation cycle: ${cycle}  console=True
        ${errors_dict}  coam.Validate_scf  scf_file=${scf_path_file}  skip_parameter_relation_errors=${skip_param_rel_err}
        ...    timeout=${timeout}  alias=${alias}
        BuiltIn.Log  ${\n}====================================  console=True
        BuiltIn.Log  SCF Validation for Definition Errors  console=True
        ${definitionErrorsSize}=  Run Keyword If  '${errors_dict["niddValidationResult"]["logs"]["definitionErrors"]}'=='None'
        ...    Set Variable  0
        ...  ELSE  Get Length  ${errors_dict["niddValidationResult"]["logs"]["definitionErrors"]}
        ${def_err_evaluated}  Evaluate  str(${errors_dict["niddValidationResult"]})
        ${definition_errors_file}
        ...    Set Variable  ${testCaseDir_result}/SCF_Validation/Definition_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
        Append To File  ${definition_errors_file}  ${def_err_evaluated}
        Run Keyword If  "${errors_dict["niddValidationResult"]["status"]}"=="OK"
        ...    Run Keywords   BuiltIn.Log  Definition Errors Count: ${definitionErrorsSize}  level=INFO  console=True
        ...         AND       BuiltIn.Log  Definition Errors Verdict: NIDD validation succeeded.  level=INFO  console=True
        ...  ELSE
        ...    Run Keywords   BuiltIn.Log  Definition Errors Count: ${definitionErrorsSize}  level=INFO  console=True
        ...     AND   BuiltIn.Log  Defined Errors Verdict: Parameter validation errors: ${definitionErrorsSize}, plz check ${definition_errors_file}!
        ...                                     level=WARN

        BuiltIn.Log  ${\n}==================================  console=True
        BuiltIn.Log  SCF Validation for Relation Errors  console=True
        ${relationErrorsSize}=  Get Length  ${errors_dict["pdlValidationResult"]["logs"]["relationErrors"]}
        ${rel_err_evaluated}  Evaluate  str(${errors_dict["pdlValidationResult"]["logs"]["relationErrors"]})
        ${relation_errors_file}  Set Variable
        ...    ${testCaseDir_result}/SCF_Validation/Relation_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
        Append To File  ${relation_errors_file}  ${rel_err_evaluated}
        Run Keyword If  "${errors_dict["pdlValidationResult"]["status"]}"!="OK" and ${relationErrorsSize}!=0
        ...          Run Keywords    BuiltIn.Log  Relation Errors Count: ${relationErrorsSize}  level=ERROR  console=True
        ...              AND         BuiltIn.Log  Relation Errors Verdict: Parameter validation errors present, please check ${relation_errors_file}
        ...                                    level=ERROR
        ...  ELSE
        ...          Run Keywords    BuiltIn.Log  Relation Errors Count: ${relationErrorsSize}  level=INFO  console=True
        ...              AND         BuiltIn.Log  Relation Errors Verdict: Parameter relation validation succeeded.  level=INFO  console=True

        BuiltIn.Log  ${\n}==================================  console=True
        BuiltIn.Log  SCF Validation for Hardware Errors  console=True
        ${hardwareErrorsSize}=  Get Length  ${errors_dict["pdlValidationResult"]["logs"]["hardwareErrors"]}
        ${hard_err_evaluated}  Evaluate  str(${errors_dict["pdlValidationResult"]["logs"]["hardwareErrors"]})
        ${hardware_errors_file}  Set Variable
        ...    ${testCaseDir_result}/SCF_Validation/Hardware_Errors_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.txt
        Append To File  ${hardware_errors_file}  ${hard_err_evaluated}
        Run Keyword If  "${errors_dict["pdlValidationResult"]["status"]}"!="OK" and ${hardwareErrorsSize}!=0
        ...            Run Keywords   BuiltIn.Log  Hardware Errors Count: ${hardwareErrorsSize}  level=INFO  console=True
        ...               AND         BuiltIn.Log  Hardware Errors Verdict: Parameter validation errors present, please check ${hardware_errors_file}
        ...                                  level=WARN
        ...  ELSE
        ...            Run Keywords   BuiltIn.Log  Hardware Errors Count: ${hardwareErrorsSize}  level=INFO  console=True
        ...               AND         BuiltIn.Log  Hardware Errors Verdict: Hardware relation validation succeeded.  level=INFO  console=True
        Run Keyword If  ${definitionErrorsSize} == 0 and ${relationErrorsSize} == 0 and ${hardwareErrorsSize} == 0
        ...  Return From Keyword  ${definition_errors_file}  ${relation_errors_file}  ${hardware_errors_file}
    END
    Run Keyword If  ${relationErrorsSize}!=0  FAIL
    ...                                       msg=Relation Errors Verdict: Parameter validation errors present, please check ${relation_errors_file}
    [Return]  ${definition_errors_file}  ${relation_errors_file}  ${hardware_errors_file}

ADMIN Update Software
    [Arguments]    ${sw_package}
    ...            ${should_activate}
    ...            ${timeout}=1800
    ...            ${alias}=coam_gnb
    coam.update_software
    ...    sw_package=${sw_package}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}
    ...    connection=${alias}

ADMIN Update Software With Activation
    [Arguments]    ${sw_package}
    ...            ${timeout}=1800
    ...            ${alias}=coam_gnb
    ADMIN Update Software
    ...    sw_package=${sw_package}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    alias=${alias}

Get and Update BSR SW
     [Arguments]      ${sw_path}   ${sw_folder}    ${sw_file_name}    ${dir_to_keep_package}
     ${target}=  Download software package    ${sw_path}   ${sw_folder}    ${sw_file_name}    ${dir_to_keep_package}
     # ${target}   set Variable   /home/ute/BSR/BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
     log to console   Update Software With Activation: ${target}
     ADMIN Update Software With Activation
     ...           sw_package=${target}
     ...           alias=coam_gnb

Get and Update BSR SW Using Git
     [Arguments]      ${sw_path}   ${sw_folder}    ${sw_file_name}    ${dir_to_keep_package}
     ${target}=  Download software package Using Git    ${sw_path}   ${sw_folder}    ${sw_file_name}    ${dir_to_keep_package}
     # ${target}   set Variable   /home/ute/BSR/BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
     log to console   Update Software With Activation: ${target}
     ADMIN Update Software With Activation
     ...           sw_package=${target}
     ...           alias=coam_gnb

Download software package
    [Documentation]  Downloads sw package from Artifactory using wget
    [Arguments]   ${sw_path}   ${sw_folder}    ${sw_file_name}    ${dir_to_keep_package}
    ${artifactory}  set variable    ${sw_path}
    ${source}   set variable  ${artifactory}/${sw_folder}/${sw_file_name}
    ${target}   set variable  ${dir_to_keep_package}/${sw_file_name}
    ${exists}   nps_trf_tools.check_if_sw_already_exists  ${target}
    run keyword if  ${exists}==${False}  Perform Download  ${target}  ${dir_to_keep_package}  ${source}
    [Return]  ${target}

Download software package Using Git
    [Documentation]  Downloads sw package from Artifactory using wget
    [Arguments]   ${sw_path}   ${sw_folder}    ${sw_file_name}    ${dir_to_keep_package}
    ${artifactory}  set variable    ${sw_path}
    ${target}   set variable  ${dir_to_keep_package}
    ${exists}   nps_trf_tools.check_if_sw_already_exists  ${target}/BSR/${sw_file_name}
    run keyword if  ${exists}==${False}  Perform Download from Git  ${artifactory}  ${target}
    [Return]  ${target}/BSR/${sw_file_name}

Perform Download from Git
    [Arguments]   ${target}   ${dir_to_keep_package}
    log to console  SW download: ${target}
    Run  mkdir -p ${dir_to_keep_package}; touch ${dir_to_keep_package}downloading
    Run    git clone ${target} ${dir_to_keep_package}
    Run  rm -f ${dir_to_keep_package}downloading

Perform Download
    [Arguments]   ${target}   ${dir_to_keep_package}  ${source}
    log to console  SW download: ${target}
    Run  mkdir -p ${dir_to_keep_package}; touch ${dir_to_keep_package}downloading
    Run  unset http_proxy; wget --progress=dot:giga ${source} -O ${target}
    Run  rm -f ${dir_to_keep_package}downloading

# ------------------------------------------------------------------------------------------------------------------------------------
# End Of ADMIN Common Kw
# ------------------------------------------------------------------------------------------------------------------------------------

Update WTS config file for SA MUEs
    [Arguments]    ${start_ue_id}    ${no_of_ues}
    ${current_cfg_file}    Set Variable    ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${new_cfg_filename}    Set Variable    new_after_adding_${no_of_ues}_Ues_${tl.core.cfg_filename}
    ${new_cfg_file}    Set Variable    ${tl.core.dir_path}/${new_cfg_filename}

    wts_cfg.Load Wts Cfg        ${current_cfg_file}
    Move file    ${current_cfg_file}    ${current_cfg_file}_bkp

    ${sa_ue_ids_list}=  nps_trf_tools.generate_list_of_ue_ids    start_ue_id=${start_ue_id}
    ...    number_of_ues=${no_of_ues}
    ${ue_nat_ip}=     wts_cfg.get_parameter     set_pdu_gateway id=1  ue_nat_ip
    ${suci}=     wts_cfg.get_parameter    set_ue simulated id=1    suci
    FOR  ${ue}  IN  @{sa_ue_ids_list}
        ${new_ip}=  nps_trf_tools.obtain_new_ip  ${ue}  ${ue_nat_ip}
        ${new_suci}=  nps_trf_tools.obtain_new_suci    ${ue}    ${suci}
        wts_cfg.clone_and_modify    set_ue simulated id=1      id=${ue} suci=${new_suci}         after   ue_param id=${ue-1}
        wts_cfg.clone_and_modify    ue_param id=1              id=${ue}                          after   set_ue simulated id=${ue}
        wts_cfg.clone_and_modify    set_pdu_gateway id=1       id=${ue} ue_nat_ip=${new_ip}      after   set_pdu_gateway id=${ue-1}
    END
    #---------------------------------------------------------------------------------------------------
    # Save and Use it
    #---------------------------------------------------------------------------------------------------
    wts_cfg.Save Wts Cfg        ${new_cfg_file}
    # update variable which contain the WTS (basic_*.cfg) config filename
    ${tl.core.cfg_filename}   set variable     ${new_cfg_filename}
    dated log   ----------> Update Basic Configuration File to add ${no_of_ues} SA MUEs (${tl.core.dir_path}/${tl.core.cfg_filename})

Update SpecificParameters to setup Ue configuration In WTS Cfg File
    [Documentation]        Update WTS basic.cfg config file with settings needed to setup Ue configuration
    ...       mme_pool_area
    ...               id=1
    ...               plmn
    ...
    [Arguments]                     ${ueId}     ${mcc}    ${mnc}

    ${current_cfg_file}    Set Variable    ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${new_cfg_filename}    nps_trf_tools.return_basename   ${current_cfg_file}
    ${new_cfg_file}    Set Variable    ${tl.core.dir_path}/${new_cfg_filename}

    wts_cfg.Load Wts Cfg        ${current_cfg_file}
    Move file    ${current_cfg_file}    ${current_cfg_file}_bkp

    #---------------------------------------------------------------------------------------------------
    # EPC CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    # wts_cfg.Modify    mme_pool_area id=1    plmn=${testParam.scfFile.nrbts.mcc}:${testParam.scfFile.nrbts.mnc}

    #---------------------------------------------------------------------------------------------------
    # UE CONFIGURATION
    #---------------------------------------------------------------------------------------------------

    # to prevent againt suci is not present in cfg file
    ${status}    ${ue_suci}=  Run Keyword And Ignore Error       wts_cfg.Get parameter    set_ue simulated id=${ueId}    suci
    ${new_ue_suci}=     Run Keyword if    '${ue_suci}'!='None'
    ...                nps_trf_tools.Modify suci for UE  ${ue_suci}  ${mcc}:${mnc}
    Run Keyword if    '${ue_suci}'!='None'     Run keywords
    ...                      wts_cfg.Modify     set_ue simulated id=${ueId}  suci=${new_ue_suci}     AND
    ...                      Dated log     cfg Modify : new_ue_suci is ${new_ue_suci}

    #---------------------------------------------------------------------------------------------------
    # Save and Use it
    #---------------------------------------------------------------------------------------------------
    wts_cfg.Save Wts Cfg        ${new_cfg_file}
    # update variable which contain the WTS (basic_*.cfg) config filename
    ${tl.core.cfg_filename}   set variable     ${new_cfg_filename}
    dated log   ----------> Update Basic Configuration File for ${ueId} Ue configuration (${tl.core.dir_path}/${tl.core.cfg_filename})
    # Move file    ${new_cfg_file}    ${new_cfg_file}_bkp

Update WTS config file for SA MUEs with target cells
    [Documentation]        Update WTS basic.cfg config file with settings needed to setup Ue configuration
    [Arguments]                     ${ueId}     ${target_cells}

    ${current_cfg_file}    Set Variable    ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${new_cfg_filename}    nps_trf_tools.return_basename   ${current_cfg_file}
    ${new_cfg_file}    Set Variable    ${tl.core.dir_path}/${new_cfg_filename}

    wts_cfg.Load Wts Cfg        ${current_cfg_file}
    Move file    ${current_cfg_file}    ${current_cfg_file}_bkp

    #---------------------------------------------------------------------------------------------------
    # UE CONFIGURATION
    #---------------------------------------------------------------------------------------------------

    Run keywords     wts_cfg.Modify     set_ue simulated id=${ueId}  cell=${target_cells}     AND
    ...              Dated log     cfg Modify : target_cells is ${target_cells} for UeId${ueId}

    #---------------------------------------------------------------------------------------------------
    # Save and Use it
    #---------------------------------------------------------------------------------------------------
    wts_cfg.Save Wts Cfg        ${new_cfg_file}
    # update variable which contain the WTS (basic_*.cfg) config filename
    ${tl.core.cfg_filename}   set variable     ${new_cfg_filename}
    dated log   ----------> Update Basic Configuration File for ${ueId} Ue configuration (${tl.core.dir_path}/${tl.core.cfg_filename})

Run ${traffic_rate:\d+}kbps ${direction:(UL|DL)} traffic on UE${ue_id:\d+} PDU${pdu_id:\d+} QFI${qfi_id:\d+} and wait ${seconds:\d+} seconds
    ${dir_param}    Convert To Lowercase    ${direction}
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir_param} kbps=${traffic_rate}
    ...  pass_regexp=Started .* Internal traffic
    Sleep  ${seconds}

Run small ${direction:(UL|DL)} traffic on UE${ue_id:\d+} and wait ${seconds:\d+} seconds and verify change to PS-BWP
    ${dir_param}    Convert To Lowercase    ${direction}
    wtsemu.trf_data_start     ue=${ue_id}   pdu=1    qfi=1    dir=${dir_param}   kbps=100
    # ${output}    wtsemu.read_wtsemu_output_until_re    expected=UDP ${direction} TRF: .*    timeout=10
    # ${output}         Get Lines Matching Regexp    ${output}    Bwp Switched from bwpId 1 to 2   partial_match=${TRUE}
    ${output}    wtsemu.read_wtsemu_output_until_re    expected=Bwp Switched from bwpId 1 to 2    timeout=10
    ${output_1}         Get Lines Matching Regexp    ${output}    Bwp Switched from bwpId 1 to 2   partial_match=${TRUE}
    Log to Console    ${output_1}
    ${output}         Get Lines Matching Regexp    ${output}    UDP ${direction} TRF: .*   partial_match=${TRUE}
    Log to Console    ${output}
    Sleep  ${seconds}

Run bigger ${direction:(UL|DL)} traffic on UE${ue_id:\d+} and wait ${seconds:\d+} seconds and verify change to dedicated BWP
    ${dir_param}    Convert To Lowercase    ${direction}
    wtsemu.trf_data_start     ue=${ue_id}   pdu=1    qfi=1    dir=${dir_param}    mbps=5
    # ${output}    wtsemu.read_wtsemu_output_until_re    expected=UDP ${direction} TRF: .*    timeout=10
    # ${output}         Get Lines Matching Regexp    ${output}    Bwp Switched from bwpId 2 to 1   partial_match=${TRUE}
    ${output}    wtsemu.read_wtsemu_output_until_re    expected=Bwp Switched from bwpId 2 to 1    timeout=10
    ${output_1}         Get Lines Matching Regexp    ${output}    Bwp Switched from bwpId 2 to 1   partial_match=${TRUE}
    Log to Console    ${output_1}
    ${output}         Get Lines Matching Regexp    ${output}    UDP ${direction} TRF: .*   partial_match=${TRUE}
    Log to Console    ${output}
    Sleep  ${seconds}

Run bigger ${direction:(UL|DL)} traffic on UE${ue_id:\d+} and wait ${seconds:\d+} seconds
    ${dir_param}    Convert To Lowercase    ${direction}
    wtsemu.trf_data_start     ue=${ue_id}   pdu=1    qfi=1    dir=${dir_param}    mbps=5
    ${output}    wtsemu.read_wtsemu_output_until_re    expected=UDP ${direction} TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP ${direction} TRF: .*   partial_match=${TRUE}
    Log to Console    ${output}
    Sleep  ${seconds}

Run ${direction:(UL|DL)} traffic to switch to dedicated BWP then run smaller traffic to switch to PS-BWP for UE${ue_id:\d+}
    Run bigger ${direction} traffic on UE${ue_id} and wait 5 seconds and verify change to dedicated BWP
    Run small ${direction} traffic on UE${ue_id} and wait 5 seconds and verify change to PS-BWP
    Wait Until Keyword Succeeds    10s    2s    Verify 100kbps ${direction} traffic on PDU-1 QFI-1 for UE${ue_id}

Run ${direction:(UL|DL)} traffic then run smaller traffic to switch to PS-BWP for UE${ue_id:\d+}
    Run bigger ${direction} traffic on UE${ue_id} and wait 5 seconds
    Run small ${direction} traffic on UE${ue_id} and wait 5 seconds and verify change to PS-BWP
    Wait Until Keyword Succeeds    10s    2s    Verify 100kbps ${direction} traffic on PDU-1 QFI-1 for UE${ue_id}

Activate CB010544 feature flag in NRCELL-${cell_id}
    Set NRCELL-${cell_id}.actInitialBWPFlexibility to True
    Wait 30s for cells [${cell_id}] operationalState change to [enabled]

Deactivate CB010544 feature flag in NRCELL-${cell_id}
    Set NRCELL-${cell_id}.actInitialBWPFlexibility to False
    Wait 30s for cells [${cell_id}] operationalState change to [enabled]

#=======================================================================================================================
# IPHY settings
#=======================================================================================================================

Set Context_AP IPHY gscn Cell1 with ${gscn}
    # WtsXmlConfig.startSession           file=iphy
    # update only gscn for cell1
    # WtsXmlConfig.setListEltText         //RE[1]//GSCN                   ${gscn}
    # WtsXmlConfig.stopSession            file=iphy
    ${result}=    Run Keyword And Ignore Error    DedicatedXmlConfig.startSession    iphy
    ${status}=    Run Keyword If    '${result[0]}'=='PASS'    Set Variable    ${True}    ELSE    Set Variable    ${False}
    Run Keyword If    ${status}
    ...    DedicatedXmlConfig.dedicated setListEltText         //RE[1]//GSCN                   ${gscn}
    Run Keyword If    ${status}
    ...    DedicatedXmlConfig.stopSession iphy
    Run Keyword Unless    ${status}    dated log    WARN: Set Context_AP IPHY gscn Cell1 failed - DedicatedXmlConfig not available

Set Context_AP IPHY gscn Cell2 with ${gscn}
    # WtsXmlConfig.startSession           file=iphy
    # update only gscn for cell1
    # WtsXmlConfig.setListEltText         //RE[2]//GSCN                   ${gscn}
    # WtsXmlConfig.stopSession            file=iphy
    ${result}=    Run Keyword And Ignore Error    DedicatedXmlConfig.startSession    iphy
    ${status}=    Run Keyword If    '${result[0]}'=='PASS'    Set Variable    ${True}    ELSE    Set Variable    ${False}
    Run Keyword If    ${status}
    ...    DedicatedXmlConfig.dedicated setListEltText         //RE[2]//GSCN                   ${gscn}
    Run Keyword If    ${status}
    ...    DedicatedXmlConfig.stopSession iphy
    Run Keyword Unless    ${status}    dated log    WARN: Set Context_AP IPHY gscn Cell2 failed - DedicatedXmlConfig not available

Set Context_AP IPHY AEHC Cell1
    DedicatedXmlConfig.startSession iphy
    DedicatedXmlConfig.dedicated setListEltText         //RE[1]//cardName                   AEHC
    DedicatedXmlConfig.dedicated setListEltText         //RE[1]//productCode                475124A
    DedicatedXmlConfig.dedicated setListEltText         //RE[1]//resourceBuildKey           LTX_AEHC
    DedicatedXmlConfig.stopSession iphy

Set Context_AP IPHY AEQE Cell1
    DedicatedXmlConfig.startSession iphy
    DedicatedXmlConfig.dedicated setListEltText         //RE[1]//cardName                   AEQE
    DedicatedXmlConfig.dedicated setListEltText         //RE[1]//productCode                474750A
    DedicatedXmlConfig.dedicated setListEltText         //RE[1]//resourceBuildKey           LTX_AEQE_E1
    DedicatedXmlConfig.stopSession iphy

Configure iphy For MU-MIMO All Cells
    [Documentation]         Modify iphy to enable SRS (current case is for DL Beam forming) and BSR file
    DedicatedXmlConfig.startSession iphy

    # DedicatedXmlConfig.addTextEltAll          Elt=//vcell     name=ulFeatures      val=advancedSRS
    # for all cell in iphy file
    DedicatedXmlConfig.addTextEltAll          Elt=//vcell     name=ulFeatures      val=ulMuMIMO
    # refinedBeams is Boolean value DEPRECATED
    # DedicatedXmlConfig.addTextEltAll          Elt=//vcell     name=refinedBeams    val=true
    DedicatedXmlConfig.addTextEltAll          Elt=//vcell     name=dlFeatures      val=pmiBeams

    ${Feat1}                            Create Dictionary    feature=FILE_DOWNLOAD                      support=1
    ${Feat2}                            Create Dictionary    feature=BEAMFORMING_PATTERNS_FILE          support=1
    ${Feat3}                            Create Dictionary    feature=BEAMFORMING_DATA_FILE_FORMAT_V1    support=0
    ${Feat4}                            Create Dictionary    feature=BEAMFORMING_DATA_FILE_FORMAT_V2    support=1
    @{Feat_list}                        Create List          ${Feat1}    ${Feat2}    ${Feat3}    ${Feat4}

    DedicatedXmlConfig.addObjectEltAll        Elt=//soap-config    name=supportedFeatures
    DedicatedXmlConfig.addItemsFromListAll    Elt=//soap-config/supportedFeatures    itemlist=${Feat_list}

    DedicatedXmlConfig.stopSession iphy

Configure iphy For MU-MIMO
    [Documentation]         Modify iphy to enable SRS (current case is for DL Beam forming) and BSR file
    DedicatedXmlConfig.startSession iphy

    # DedicatedXmlConfig.addTextEltAll          Elt=//vcell     name=ulFeatures      val=advancedSRS
    # Only for cell1 in iphy file
    DedicatedXmlConfig.addTextEltAll          Elt=//RE[1]//hardware//vcellList//vcell     name=ulFeatures      val=ulMuMIMO
    DedicatedXmlConfig.addTextEltAll          Elt=//RE[1]//hardware//vcellList//vcell     name=dlFeatures      val=pmiBeams

    ${Feat1}                            Create Dictionary    feature=FILE_DOWNLOAD                      support=1
    ${Feat2}                            Create Dictionary    feature=BEAMFORMING_PATTERNS_FILE          support=1
    ${Feat3}                            Create Dictionary    feature=BEAMFORMING_DATA_FILE_FORMAT_V1    support=0
    ${Feat4}                            Create Dictionary    feature=BEAMFORMING_DATA_FILE_FORMAT_V2    support=1
    @{Feat_list}                        Create List          ${Feat1}    ${Feat2}    ${Feat3}    ${Feat4}

    DedicatedXmlConfig.addObjectEltAll        Elt=//RE[1]//soap-config    name=supportedFeatures
    DedicatedXmlConfig.addItemsFromListAll    Elt=//RE[1]//soap-config/supportedFeatures    itemlist=${Feat_list}

    DedicatedXmlConfig.stopSession iphy

#=======================================================================================================================
# PCAP postprocessing procedures
#=======================================================================================================================

Display Info from cellSetup Pcap
    [Arguments]                     ${File}      ${w_display}=False
    [Documentation]                 Display Info from CPRT -> L2PS in GNB_CPRT_NODE Pcap

    Dated log                   Extract Info from CPRT -> L2PS in GNB_CPRT_NODE PCAP file [itf_l2_ps_cell_cellsetupreq] ${File}

    set test variable    ${pcapprocessed_Display_CPRT}    pcapprocessed_Display_itf_l2_ps_cell_CellSetupReq_CPRT.txt
    set test variable    ${pcapprocessed_Display_CPRT_path}    ${testCaseDir}/${pcapprocessed_Display_CPRT}
    # -Y "icom_5g"
    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields  -Y "icom_5g" -Y "itf_l2_ps_cell_cellsetupreq" -e _ws.col.Info
    ...           -e itf_l2_ps_cell_CellSetupReq_t.physCellId -e itf_l2_ps_cell_CellSetupReq_t.dlBandwidth
    ...           -e itf_l2_ps_cell_PrbBlanking.nbrOfBlankedPRBsLowEdgeDL -e itf_l2_ps_cell_PrbBlanking.nbrOfBlankedPRBsHighEdgeDL
    ...           -e itf_l2_ps_cell_PrbBlanking.nbrOfBlankedPRBsLowEdgeUL -e itf_l2_ps_cell_PrbBlanking.nbrOfBlankedPRBsHighEdgeUL
    ...           -e itf_l2_ps_cell_BwpDefinition.rbgSizePdsch -e itf_l2_ps_cell_BwpDefinition.numPdschPrbInSsbSlots
    ...           -E header=y -E separator=';' > ${pcapprocessed_Display_CPRT_path}
    Run       ${cmd_mcshark}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_Display_CPRT_path}   _ws.col.Info
    ${pattern}=     set variable     itf_l2_ps_cell_CellSetupReq
    ${extract}   OperatingSystem.grep file        ${pcapprocessed_Display_CPRT_path}   ${pattern}
    run keyword if  len($extract)==0     fail   ${pattern} not found
    OperatingSystem.copy file    ${pcapprocessed_Display_CPRT_path}
    ...                          ${testCaseDir}/pcapprocessed_itf_l2_ps_cell_CellSetupReq_CPRT.csv

    return From Keyword If     '${w_display}' == 'False'

    # ${extract_col_info}=       replace string  ${extract_col_info}    ;
    @{extract_col_info_formated}=    String.Split String      ${extract_col_info}   ;
    ${length_extract_col_info_formated}=    Get Length    ${extract_col_info_formated}
    # ${extract}=       replace string  ${extract}       ;
    @{extract_formated}=    String.Split String    ${extract}    ;
    ${length}=    Get Length    ${extract_formated}
    ${length_info}=     Evaluate     ${length} - ${length_extract_col_info_formated}
    ${indice_col}=      Set Variable     ${0}
    FOR    ${i}    IN RANGE    ${length_info}
        ${index_extract}=   Evaluate     ${i} + ${length_extract_col_info_formated} -${1}
        ${indice_col}=      run Keyword if      '${indice_col}'=='${length_extract_col_info_formated}'     set Variable    ${0}
        ...                    ELSE                                                                        set Variable    ${indice_col}
        Dated log                   --- ${extract_col_info_formated}[${indice_col}] = ${extract_formated}[${index_extract}]
        ${indice_col}=      Evaluate   ${indice_col} + ${1}
    END

Extract Info from itf_l2_ps_user_usermodifyreq_t Pcap
    [Arguments]                     ${File}
    [Documentation]                 Display Info from CPRT -> L2PS in GNB_CPRT_NODE Pcap

    Dated log                   Extract Info from CPRT -> L2PS in GNB_CPRT_NODE PCAP file [itf_l2_ps_user_usermodifyreq] ${File}

    # when CB010544 activated
    # (itf_l2_ps_user_usermodifyreq_t) && (itf_l2_ps_pdcch_UeBwp.prachConfigNotPresent_item == 1) && (itf_l2_ps_pdcch_UeBwp.cellBwpId == 0x02)
    ${CB010544_activated_cell1}=     tarf-lib.is_CB010544_activated_for_Cell1
    set test variable    ${pcapprocessed_Display_CPRT}    pcapprocessed_itf_l2_ps_user_usermodifyreq_t_CPRT.txt
    set test variable    ${pcapprocessed_Display_CPRT_path}    ${testCaseDir}/${pcapprocessed_Display_CPRT}
    # -Y "icom_5g"
    ${filter}=    Catenate   itf_l2_ps_user_usermodifyreq_t && (itf_l2_ps_pdcch_UeBwp.prachConfigNotPresent_item == 1)
    ...                      && (itf_l2_ps_pdcch_UeBwp.cellBwpId == 0x02)
    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields  -Y "icom_5g" -Y "${filter}" -e _ws.col.Info
    ...           -e 3gpp.rnti
    ...           -e itf_l2_ps_pdcch_UeBwp.cellBwpId
    ...           -e itf_l2_ps_pdcch_UeBwp.prachConfigNotPresent_item
    ...           -E header=y -E separator=';' > ${pcapprocessed_Display_CPRT_path}
    Run       ${cmd_mcshark}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_Display_CPRT_path}   _ws.col.Info
    ${pattern}=     set variable     itf_l2_ps_user_UserModifyReq
    ${extract}   OperatingSystem.grep file        ${pcapprocessed_Display_CPRT_path}   ${pattern}
    run Keyword if    ${CB010544_activated_cell1}     robot_extension.Run Keyword And Warn On Failure    should Not be True     len($extract)==0
    ...                                                                                                                   filter=${filter} not found
    ${prachConfigNotPresent_item_is_present_in_itf_l2_ps_user_UserModifyReq}=        Evaluate      len($extract)!=0
    OperatingSystem.copy file    ${pcapprocessed_Display_CPRT_path}
    ...                          ${testCaseDir}/pcapprocessed_prachConfigNotPresent_item_PSBWP_itf_l2_ps_user_usermodifyreq_t_CPRT.csv

    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields  -Y "icom_5g" -Y "itf_l2_ps_user_usermodifyreq_t" -e _ws.col.Info
    ...           -e 3gpp.rnti
    ...           -e itf_l2_ps_pdcch_UeBwp.cellBwpId
    ...           -e itf_l2_ps_pdcch_UeBwp.prachConfigNotPresent_item
    ...           -E header=y -E separator=';' > ${pcapprocessed_Display_CPRT_path}
    Run       ${cmd_mcshark}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_Display_CPRT_path}   _ws.col.Info
    ${pattern}=     set variable     itf_l2_ps_user_UserModifyReq
    ${extract}   OperatingSystem.grep file        ${pcapprocessed_Display_CPRT_path}   ${pattern}
    OperatingSystem.copy file    ${pcapprocessed_Display_CPRT_path}
    ...                          ${testCaseDir}/pcapprocessed_itf_l2_ps_user_usermodifyreq_t_CPRT.csv
    declare Results in Test Results List     Type=CPRT->L2PS: Check prachConfigNotPresent_item_is_present_in_itf_l2_ps_user_UserModifyReq
    ...                                      Result=${prachConfigNotPresent_item_is_present_in_itf_l2_ps_user_UserModifyReq}
    run keyword if  len($extract)==0     fail   ${pattern} not found

Extract Cell Mapping Info from cellSetup Pcap
    [Arguments]                     ${File}      ${w_display}=False
    [Documentation]                 Display Cell Mapping Info from CPRT -> L2PS in GNB_CPRT_NODE Pcap

    ${tm}=    Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}
    Dated log                   Extract Cell Mapping Info from CPRT -> L2PS in GNB_CPRT_NODE PCAP file ${File}

    set test variable    ${pcapprocessed_Display_CPRT}    pcapprocessed_Cell_Mapping_itf_l2_ps_cell_CellSetupReq_CPRT.txt
    set test variable    ${pcapprocessed_Display_CPRT_path}    ${testCaseDir}/${pcapprocessed_Display_CPRT}
    # -Y "icom_5g"
    ${cmd_mcshark}    Catenate      tshark -r
    ...        ${File} -T fields  -Y "icom_5g" -Y "itf_l2_ps_cell_cellsetupreq" -e _ws.col.Info
    ...           -e itf_l2_ps_cell_CellSetupReq_t.physCellId -e 3gpp.subcellid
    ...           -e itf_l2_ps_DlSubcell.dlSubcellPoolId
    ...           -e itf_l2_ps_DlSubcell.l1PoolId
    ...           -e itf_l2_ps_UlSubcell.ulSubcellPoolId
    ...           -e itf_l2_ps_UlSubcell.l1PoolId
    ...           -E header=y -E separator=';' > ${pcapprocessed_Display_CPRT_path}
    Run       ${cmd_mcshark}

    ${extract_col_info}   OperatingSystem.grep file        ${pcapprocessed_Display_CPRT_path}   _ws.col.Info
    ${pattern}=     set variable     itf_l2_ps_cell_CellSetupReq
    ${extract}   OperatingSystem.grep file        ${pcapprocessed_Display_CPRT_path}   ${pattern}
    run keyword if  len($extract)==0     fail   ${pattern} not found
    OperatingSystem.copy file    ${pcapprocessed_Display_CPRT_path}
    ...                          ${testCaseDir}/pcapprocessed_Cell_Mapping_itf_l2_ps_cell_CellSetupReq_CPRT.csv
    OperatingSystem.copy file    ${pcapprocessed_Display_CPRT_path}
    ...                          ${testCaseDir}/syscom/pcapprocessed_Cell_Mapping_itf_l2_ps_cell_CellSetupReq_CPRT.csv
    OperatingSystem.copy file    ${pcapprocessed_Display_CPRT_path}
    ...                          ${testCaseDir}/${postprocess_results}/pcapprocessed_Cell_Mapping_itf_l2_ps_cell_CellSetupReq_CPRT_${tm}.csv


Check CB012738 Based L1L2 PCAP
    [Documentation]                Kw purpose is postprocess l1L2 pcap if present
    [Arguments]                    ${captureL1L2}=${None}      ${step}=${None}
    return From Keyword if      '${captureL1L2}' == '${None}'
    ${step}=     Set Variable If    '${step}' == '${None}'     MAIN STEP
    ...                                                        ${step}
    ${nbrOfBlankedPRBsHighEdgeUL}=                  Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeUL   CellId=1
    ${nbrOfBlankedPRBsHighEdgeUL_int}=              Convert To Integer    ${nbrOfBlankedPRBsHighEdgeUL}
    ${nbrOfBlankedPRBsLowEdgeUL}=                   Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeUL    CellId=1
    ${nbrOfBlankedPRBsLowEdgeUL_int}=               Convert To Integer    ${nbrOfBlankedPRBsLowEdgeUL}
    ${nbrOfBlankedPRBsHighEdgeUL_Cell2}=            Get NRCELL Param from SCF   param=nbrOfBlankedPRBsHighEdgeUL   CellId=2
    ${nbrOfBlankedPRBsHighEdgeUL_int_Cell2}=        Convert To Integer    ${nbrOfBlankedPRBsHighEdgeUL_Cell2}
    ${nbrOfBlankedPRBsLowEdgeUL_Cell2}=             Get NRCELL Param from SCF   param=nbrOfBlankedPRBsLowEdgeUL    CellId=2
    ${nbrOfBlankedPRBsLowEdgeUL_int_Cell2}=         Convert To Integer    ${nbrOfBlankedPRBsLowEdgeUL_Cell2}
    Extract DL PRB Blanking Info from L1L2 Pcap    File=${captureL1L2}  subcellId=0
    Extract DL PRB Blanking Info from L1L2 Pcap    File=${captureL1L2}  subcellId=1
    ${first_prb_non_blanking_cell1}  ${last_prb_non_blanking_cell1}     Calculate DL first_prb_non_blanking and last_prb_non_blanking for Cell1
    ${first_prb_non_blanking_cell2}  ${last_prb_non_blanking_cell2}     Calculate DL first_prb_non_blanking and last_prb_non_blanking for Cell2
    ${last_prb_non_blanking_cell_PS_BWP}=     Evaluate      ${106}+${nbrOfBlankedPRBsLowEdgeUL_int}-${1}
    dated log       =====> tarf-lib.verify_Pcap_for_DL_PRBBLANKING for CELL1
    Run keyword and continue on failure    tarf-lib.verify_Pcap_for_DL_PRBBLANKING
    ...                                             filecsv=${testCaseDir}/pcapprocessed_PRb_Blanking_dldata_pdschsendreq_subcellId0.csv
    ...                                             first_prb_non_blanking_cell=${first_prb_non_blanking_cell1}
    ...                                             last_prb_non_blanking_cell=${last_prb_non_blanking_cell1}
    ...                                             first_prb_non_blanking_cell_PS_BWP=${nbrOfBlankedPRBsLowEdgeUL_int}
    ...                                             last_prb_non_blanking_cell_PS_BWP=${last_prb_non_blanking_cell_PS_BWP}
    ...                                             chBW_PSBWP=${106}
    declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_DL_PRBBLANKING Cell1 (PDSCH) for Step [${step}]     Result=${TestResult}
    dated log       =====> tarf-lib.run_PDSCH_prb_blanking_overlap_analysis_pcap_dl for CELL1
    Run keyword and continue on failure    tarf-lib.run_PDSCH_prb_blanking_overlap_analysis_pcap_dl
    ...                                             filecsv=${testCaseDir}/pcapprocessed_PRb_Blanking_dldata_pdschsendreq_subcellId0.csv
    ...                                             nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeUL_int}
    ...                                             nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeUL_int}
    # ...                                             chBW_PSBWP=${106}
    declare Results in Test Results List     Type=L1L2Bip: run_PDSCH_prb_blanking_overlap_analysis_pcap_dl Cell1 (PDSCH) for Step [${step}]
    ...                                                                           Result=${TestResult}
    ${last_prb_non_blanking_cell_PS_BWP_Cell2}=     Evaluate      ${106}+${nbrOfBlankedPRBsLowEdgeUL_int_Cell2}-${1}
    dated log       =====> tarf-lib.verify_Pcap_for_DL_PRBBLANKING for CELL2
    Run keyword and continue on failure    tarf-lib.verify_Pcap_for_DL_PRBBLANKING
    ...                                             filecsv=${testCaseDir}/pcapprocessed_PRb_Blanking_dldata_pdschsendreq_subcellId1.csv
    ...                                             first_prb_non_blanking_cell=${first_prb_non_blanking_cell2}
    ...                                             last_prb_non_blanking_cell=${last_prb_non_blanking_cell2}
    ...                                             first_prb_non_blanking_cell_PS_BWP=${nbrOfBlankedPRBsLowEdgeUL_int_Cell2}
    ...                                             last_prb_non_blanking_cell_PS_BWP=${last_prb_non_blanking_cell_PS_BWP_Cell2}
    ...                                             chBW_PSBWP=${106}
    declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_DL_PRBBLANKING Cell2 (PDSCH) for Step [${step}]     Result=${TestResult}
    dated log       =====> tarf-lib.run_PDSCH_prb_blanking_overlap_analysis_pcap_dl for CELL2
    Run keyword and continue on failure    tarf-lib.run_PDSCH_prb_blanking_overlap_analysis_pcap_dl
    ...                                             filecsv=${testCaseDir}/pcapprocessed_PRb_Blanking_dldata_pdschsendreq_subcellId1.csv
    ...                                             nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeUL_int_Cell2}
    ...                                             nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeUL_int_Cell2}
    # ...                                             chBW_PSBWP=${106}
    declare Results in Test Results List     Type=L1L2Bip: run_PDSCH_prb_blanking_overlap_analysis_pcap_dl Cell2 (PDSCH) for Step [${step}]
    ...                                                                             Result=${TestResult}
    ${UlData_PucchReceiveReq_not_present_Cell1}=     Extract UL PRB Blanking Info from L1L2 Pcap     File=${captureL1L2}    subcellId=0
    ${UlData_PucchReceiveReq_not_present_Cell2}=     Extract UL PRB Blanking Info from L1L2 Pcap     File=${captureL1L2}    subcellId=1
    # check of pucchAreaBoundaries and PucchResource no overlap with PrbBlaninkg regions
    dated log       =====> tarf-lib.verify_Pcap_for_pucchAreaBoundaries_UL_PRBBLANKING for CELL1
    Run Keyword If     ${UlData_PucchReceiveReq_not_present_Cell1}==${False}     Run keyword and continue on failure
    ...                 tarf-lib.verify_Pcap_for_pucchAreaBoundaries_UL_PRBBLANKING
    ...                            filecsv=${testCaseDir}/pcapprocessed_pucchAreaBoundaries_PRB_Blanking_uldata_pucchreceivereq_subcellId0.csv
    ...                            nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL_int}
    ...                            nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL_int}
    ...     ELSE      dated log   =====> no pucchAreaBoundaries check because UlData_PucchReceiveReq not present in pcap For CELL1
    ${TestResult}=    Set Variable If     ${UlData_PucchReceiveReq_not_present_Cell1}==${True}    WARNING : UlData_PucchReceiveReq_not_present_Cell1
    ...                                                                                           ${TestResult}
    declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_pucchAreaBoundaries_UL_PRBBLANKING Cell1 for Step [${step}]
    ...                                      Result=${TestResult}
    dated log       =====> tarf-lib.verify_Pcap_for_pucchResources_UL_PRBBLANKING for CELL1
    Run Keyword If     ${UlData_PucchReceiveReq_not_present_Cell1}==${False}     Run keyword and continue on failure
    ...                 tarf-lib.verify_Pcap_for_pucchResources_UL_PRBBLANKING
    ...                            filecsv=${testCaseDir}/pcapprocessed_pucchResources_PRB_Blanking_uldata_pucchreceivereq_subcellId0.csv
    ...                            nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL_int}
    ...                            nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL_int}
    ...     ELSE      dated log   =====> no pucchResources check because UlData_PucchReceiveReq not present in pcap For CELL1
    ${TestResult}=    Set Variable If     ${UlData_PucchReceiveReq_not_present_Cell1}==${True}    WARNING : UlData_PucchReceiveReq_not_present_Cell1
    ...                                                                                           ${TestResult}
    declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_pucchResources_UL_PRBBLANKING Cell1 for Step [${step}]
    ...                                      Result=${TestResult}
    dated log       =====> tarf-lib.verify_Pcap_for_eCpriPucchResourceAllocation_UL_PRBBLANKING for CELL1
    Run Keyword If    ${UlData_PucchReceiveReq_not_present_Cell1}==${False}  Run keyword and continue on failure
    ...                 tarf-lib.verify_Pcap_for_eCpriPucchResourceAllocation_UL_PRBBLANKING
    ...                            filecsv=${testCaseDir}/pcapprocessed_pucchAreaBoundaries_PRB_Blanking_uldata_pucchreceivereq_subcellId0.csv
    ...                            nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL_int}
    ...                            nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL_int}
    ...     ELSE      dated log   =====> no eCpriPucchResourceAllocation check because UlData_PucchReceiveReq not present in pcap For CELL1
    ${TestResult}=    Set Variable If     ${UlData_PucchReceiveReq_not_present_Cell1}==${True}    WARNING : UlData_PucchReceiveReq_not_present_Cell1
    ...                                                                                           ${TestResult}
    declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_eCpriPucchResourceAllocation_UL_PRBBLANKING Cell1 for Step [${step}]
    ...                                      Result=${TestResult}
    dated log       =====> tarf-lib.verify_Pcap_for_pucchAreaBoundaries_UL_PRBBLANKING for CELL2
    Run Keyword If     ${UlData_PucchReceiveReq_not_present_Cell2}==${False}   Run keyword and continue on failure
    ...                  tarf-lib.verify_Pcap_for_pucchAreaBoundaries_UL_PRBBLANKING
    ...                           filecsv=${testCaseDir}/pcapprocessed_pucchAreaBoundaries_PRB_Blanking_uldata_pucchreceivereq_subcellId1.csv
    ...                           nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL_int_Cell2}
    ...                           nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL_int_Cell2}
    ...     ELSE      dated log   =====> no check because UlData_PucchReceiveReq not present in pcap For CELL2
    ${TestResult}=    Set Variable If     ${UlData_PucchReceiveReq_not_present_Cell2}==${True}   WARNING : UlData_PucchReceiveReq_not_present_Cell2
    ...                                                                                          ${TestResult}
    declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_pucchAreaBoundaries_UL_PRBBLANKING Cell2 for Step [${step}]
    ...                                      Result=${TestResult}
    dated log       =====> tarf-lib.verify_Pcap_for_pucchResources_UL_PRBBLANKING for CELL2
    Run Keyword If     ${UlData_PucchReceiveReq_not_present_Cell2}==${False}     Run keyword and continue on failure
    ...               tarf-lib.verify_Pcap_for_pucchResources_UL_PRBBLANKING
    ...                            filecsv=${testCaseDir}/pcapprocessed_pucchResources_PRB_Blanking_uldata_pucchreceivereq_subcellId1.csv
    ...                            nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL_int_Cell2}
    ...                            nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL_int_Cell2}
    ...     ELSE      dated log   =====> no pucchResources check because UlData_PucchReceiveReq not present in pcap For CELL2
    ${TestResult}=    Set Variable If     ${UlData_PucchReceiveReq_not_present_Cell2}==${True}   WARNING : UlData_PucchReceiveReq_not_present_Cell2
    ...                                                                                          ${TestResult}
    declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_pucchResources_UL_PRBBLANKING Cell2 for Step [${step}]
    ...                                      Result=${TestResult}
    dated log       =====> tarf-lib.verify_Pcap_for_eCpriPucchResourceAllocation_UL_PRBBLANKING for CELL2
    Run Keyword If    ${UlData_PucchReceiveReq_not_present_Cell2}==${False}      Run keyword and continue on failure
    ...               tarf-lib.verify_Pcap_for_eCpriPucchResourceAllocation_UL_PRBBLANKING
    ...                            filecsv=${testCaseDir}/pcapprocessed_pucchAreaBoundaries_PRB_Blanking_uldata_pucchreceivereq_subcellId1.csv
    ...                            nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL_int_Cell2}
    ...                            nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL_int_Cell2}
    ...     ELSE      dated log   =====> no eCpriPucchResourceAllocation check because UlData_PucchReceiveReq not present in pcap For CELL2
    ${TestResult}=    Set Variable If     ${UlData_PucchReceiveReq_not_present_Cell2}==${True}    WARNING : UlData_PucchReceiveReq_not_present_Cell2
    ...                                                                                           ${TestResult}
    declare Results in Test Results List     Type=L1L2Bip: verify_Pcap_for_eCpriPucchResourceAllocation_UL_PRBBLANKING Cell2 for Step [${step}]
    ...                                      Result=${TestResult}

Get Status String
    [Documentation]                 INTERNAL USAGE
    ...                             Compute status string (PASS of FAIL, but in color manner)
    [Arguments]                     ${status}
    ${str}                          Run Keyword if                         '${status}'=='PASS'
    ...                             evaluate                               "${BG_GREEN}${BLACK}PASS${NORMAL}"
    ...                             ELSE
    ...                             evaluate                               "${BG_RED}${BLACK}FAIL${NORMAL}"
    [Return]                        ${str}

Get short String
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${str}
    ${type}                         Evaluate    type($str).__name__
    ${line}                         set variable if                         '${type}'=='NoneType'
    ...                             ${EMPTY}
    ...                             ${str.replace("\n","")}
    [Return]                        ${line}

Retrieve Step Status
    [Documentation]                 Retrieve Status step for a test (from step name)
    [Arguments]          ${StepName}=None
    ${msg}                          Evaluate
    ...                             "${BG_BLUE}${YELLOW}TEST RESULT of %-68s${NORMAL}" % ('${TEST_NAME}')
    ${KOrange}                      Set variable                           -1
    ${ret}                          Set variable                           PASS
    Log to console                  ${msg}
    FOR     ${step}    IN           @{ListStep}
        # skip iteration if ${step.name} is not equal to "StepName"
        Continue For Loop If   '${step.name}'!='${StepName}'
        ${str_status}               TARF-Keywords.Get Status String                          ${step.status}
        ${msg_line}                 TARF-Keywords.Get Short String                           ${step.msg}
        ${str}                      evaluate
        ...                         "\tSTEP %-2s : %-50s ${str_status} ${msg_line}" % ('${step.nb}','${step.name}')
        Log to console              ${str}
        ${ret}     Set Variable     ${step.status}
        Exit For Loop If       '${step.name}'=='${StepName}'
    END
    [Return]     ${ret}

Setup devices aliases
    # ta_messaging.Create ues alias   alias=UE  id_type=wts_5g
    # ta_messaging.Create UE Alias    alias=UE1    ue_id=1    id_type=wts_5g
    # ta_messaging.Create UE Alias    alias=UE2    ue_id=2    id_type=wts_5g
    ta_messaging.Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    ta_messaging.Create AMF device with alias 'AMF1' identified by ip=10.0.1.1

Install lua File into WTS
    [Arguments]          ${LuaFileToUsed_path}=${EMPTY}
    return From Keyword If     '${LuaFileToUsed_path}'=='${EMPTY}'
    OperatingSystem.Run    cp ${LuaFileToUsed_path} ${WTS_DIR}
    ${ret}                 nps_trf_tools.return_basename      ${LuaFileToUsed_path}
    [Return]     ${ret}

Calc Rbg Order
    [Arguments]    ${sfn}    ${slot}    ${pci}
    ${order_list}    rbg_order.calc_rbg_order    bwp_width=${273}    rat=TDD    slot_num=${20}    pci=${pci}
    ...    sfn=${sfn}   slot=${slot}
    [Return]    ${order_list}

Get Used Rbg List
    [Arguments]    ${order_list}    ${bitmap}
    ${order_list}    rbg_order.rbg_order_check    rbg_order_list=${order_list}    rat0bitmap=${bitmap}
    [Return]    ${order_list}

Convert Bitmap To Binary
    [Arguments]    ${Bitmap}
    ${result}=    Convert To Binary    ${Bitmap}
    [Return]    ${result}

Is Partial RBG Used
    [Arguments]    ${bitmap}
    ${is_prbg_used}    rbg_order.is_last_rbg_used    rat0bitmap=${bitmap}
    [Return]    ${is_prbg_used}

Is RBG Contiguous Used
    [Arguments]    ${bitmap}
    ${is_contigu_rbg_used}    rbg_order.is_contiguous_rbg_used    rat0bitmap=${bitmap}
    [Return]    ${is_contigu_rbg_used}

Check Is Full Used
    [Arguments]    ${Bitmap}
    Run keyword if    ${Bitmap} == "111111111111111111"    set test variable    ${res}    True
    ...    ELSE    set test variable    ${res}    False
    [Return]    ${res}

# ------------------------------------------------------------------------------------------------------------------------------------
#   ute_admin_infomodel
# ------------------------------------------------------------------------------------------------------------------------------------

Verify E2 link status
    [Arguments]    ${status}=active
    ute_admin_infomodel.Setup Infomodel    port=443    alias=E2check
    ute_admin_infomodel.Connect Infomodel    alias=E2check
    ute_admin_infomodel.Query Infomodel
    ...     query=every /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/NRBTS_R-*/NRE2LINK_R-* is [e2LinkStatus=${status}]
    ...     timeout=60    alias=E2check
    [teardown]    ute_admin_infomodel.Teardown Infomodel    alias=E2check

Kw Check errors in Syslog
    ${file_exist}=    Run Keyword And Return Status    OperatingSystem.file_should_exist    ${resultFile}
    IF     not ${file_exist}
        ${resultFile}    Set Variable     ${LOG_PATH}/resultFile_${SUITE NAME}.log
    END
    ${cmd_err_count}=    Catenate    grep -i -e ERR/L2-PS/ -e ERR/.uplane/L2-PS/ -e ERR/l1_application_rt/ -e ERR/.uplane/l1_application_rt/
    ...    -e ERR/l1_application_nrt/ -e ERR/.uplane/l1_application_nrt/ /tmp/btslog2/SYSLOG*.LOG | wc -l
    ${ErrorsCount}   OperatingSystem.Run  command=${cmd_err_count}
    ${cmd_wrn}=    Catenate    grep -i -e WRN/L2-PS/ -e WRN/l1_application_rt/ -e WRN/l1_application_nrt/ /tmp/btslog2/SYSLOG*.LOG | wc -l
    ${warningsCount}   OperatingSystem.Run  command=${cmd_wrn}
    ${cmd_err}=    Catenate    grep -i -e ERR/L2-PS/ -e ERR/.uplane/L2-PS/ -e ERR/l1_application_rt/ -e ERR/.uplane/l1_application_rt/
    ...    -e ERR/l1_application_nrt/ -e ERR/.uplane/l1_application_nrt/ /tmp/btslog2/SYSLOG*.LOG
    ${err_output}   OperatingSystem.Run  command=${cmd_err}
    ${full_cmd_wrn}=    Catenate    grep -i -e WRN/L2-PS/ -e WRN/l1_application_rt/ -e WRN/l1_application_nrt/ /tmp/btslog2/SYSLOG*.LOG
    ${full_wrn_output}   OperatingSystem.Run  command=${full_cmd_wrn}
    Append To File   ${resultFile}   \n****************\nCheck GNB syslog\n****************\n
    Append To File   ${resultFile}   \n\n---> Check GNB syslog\n
    Append To File  ${resultFile}     \nfind ${ErrorsCount} Errors in GNB syslog: use cmd=[${cmd_err}]\n
    Append To File  ${resultFile}     \nfind ${warningsCount} Warnings in GNB syslog: use cmd=[${cmd_wrn}]\n
    Run Keyword If    ${ErrorsCount} != ${0}     Append To File  ${resultFile}    \nfind ${ErrorsCount} Errors in GNB syslog:\n
    Run Keyword If    ${ErrorsCount} < ${100}    Append To File  ${resultFile}    ${err_output}\n
    ...    ELSE                                  Append To File  ${resultFile}    ${ErrorsCount} > 100, pls check GNB syslog files\n
    IF    ${ErrorsCount} > ${20}
        BuiltIn.Log  find ${ErrorsCount} Errors in GNB syslog: use cmd=[${cmd_err}]  level=ERROR  console=True
    ELSE IF   ${ErrorsCount} < ${20} and ${ErrorsCount} != ${0}
        BuiltIn.Log  find ${ErrorsCount} Errors in GNB syslog: use cmd=[${cmd_err}]  level=WARN  console=True
    ELSE
        nps_trf_tools.log_to_console_with_time_prefix   find L2PS ${ErrorsCount} Errors in GNB syslog: use cmd=[${cmd_err}]    level=INFO
    END
    IF  ${warningsCount} > ${40}
        BuiltIn.Log  find ${warningsCount} L2-PS Warnings in GNB syslog: use cmd=[${cmd_wrn}]  level=ERROR  console=True
    ELSE IF    ${warningsCount} < ${40} and ${warningsCount} != ${0}
        BuiltIn.Log  find ${warningsCount} L2-PS Warnings in GNB syslog: use cmd=[${cmd_wrn}]  level=WARN  console=True
    ELSE
        nps_trf_tools.log_to_console_with_time_prefix   find L2-PS ${warningsCount} Warnings in GNB syslog: use cmd=[${cmd_wrn}]   level=INFO
    END
    Run Keyword If    ${warningsCount} < ${50}   Append To File  ${resultFile}    ${full_wrn_output}\n
    ...    ELSE                                  Append To File  ${resultFile}    ${warningsCount} > 50, pls check GNB syslog files\n


Kw Check CPLANE errors in Syslog
    ${file_exist}=    Run Keyword And Return Status    OperatingSystem.file_should_exist    ${resultFile}
    IF     not ${file_exist}
        ${resultFile}    Set Variable     ${LOG_PATH}/resultFile_${SUITE NAME}.log
    END
    ${cmd_err_count}=    Catenate    grep -i -e ERR/cp_nb/ -e ERR/cp_cl/ -e ERR/cp_if/ -e ERR/cp_rt/
    ...    -e ERR/cp_nrt/ -e ERR/cp_ue/ -e ERR/cp_sctp/ -e ERR/up_ue/
    ...    /tmp/btslog2/SYSLOG*.LOG | wc -l
    ${ErrorsCount}   OperatingSystem.Run  command=${cmd_err_count}
    ${cmd_wrn}=    Catenate    grep -i -e WRN/cp_nb/ -e WRN/cp_cl/ -e WRN/cp_if/ -e WRN/cp_rt/ -e WRN/cp_nrt/ -e WRN/cp_ue/ -e WRN/cp_sctp/
    ...    -e WRN/up_ue/ /tmp/btslog2/SYSLOG*.LOG | wc -l
    ${warningsCount}   OperatingSystem.Run  command=${cmd_wrn}
    ${cmd_err}=    Catenate    grep -i -e ERR/cp_nb/ -e ERR/cp_cl/ -e ERR/cp_if/ -e ERR/cp_rt/ -e ERR/cp_nrt/ -e ERR/cp_ue/ -e ERR/cp_sctp/
    ...    -e ERR/up_ue/ /tmp/btslog2/SYSLOG*.LOG
    ${err_output}   OperatingSystem.Run  command=${cmd_err}
    ${full_cmd_wrn}=    Catenate    grep -i -e WRN/cp_nb/ -e WRN/cp_cl/ -e WRN/cp_if/ -e WRN/cp_rt/ -e WRN/cp_nrt/ -e WRN/cp_ue/ -e WRN/cp_sctp/
    ...    -e WRN/up_ue/ /tmp/btslog2/SYSLOG*.LOG
    ${full_wrn_output}   OperatingSystem.Run  command=${full_cmd_wrn}
    Append To File  ${resultFile}     \nfind ${ErrorsCount} CPLANE Errors in syslog: use cmd=[${cmd_err}]\n
    Append To File  ${resultFile}     \nfind ${warningsCount} CPLANE Warnings in syslog: use cmd=[${cmd_wrn}]\n
    Run Keyword If    ${ErrorsCount} != ${0}     Run Keywords
    ...                          Append To File  ${resultFile}    \nfind CPLANE ${ErrorsCount} Errors in syslog:\n
    ...                     AND  BuiltIn.Log  find CPLANE ${ErrorsCount} Errors in syslog: use cmd=[${cmd_err}]  level=ERROR
    Run Keyword If    ${ErrorsCount} < ${100}    Append To File  ${resultFile}    ${err_output}\n
    ...    ELSE                                  Append To File  ${resultFile}    ${ErrorsCount} > 100, pls check syslog files\n
    IF   ${ErrorsCount} > ${0}
        nps_trf_tools.log_to_console_with_time_prefix   find CPLANE ${ErrorsCount} Errors in syslog: use cmd=[${cmd_err}]    level=ERROR
    ELSE
        nps_trf_tools.log_to_console_with_time_prefix   find CPLANE ${ErrorsCount} Errors in syslog: use cmd=[${cmd_err}]    level=INFO
    END
    IF  ${warningsCount} >= ${40}
        nps_trf_tools.log_to_console_with_time_prefix  find CPLANE ${warningsCount} Warnings in syslog: use cmd=[${cmd_wrn}]  level=ERROR
    ELSE IF   ${warningsCount} < ${40} and ${warningsCount} != ${0}
        nps_trf_tools.log_to_console_with_time_prefix  find CPLANE ${warningsCount} Warnings in syslog: use cmd=[${cmd_wrn}]  level=WARN
    ELSE
        nps_trf_tools.log_to_console_with_time_prefix  find CPLANE ${warningsCount} Warnings in syslog: use cmd=[${cmd_wrn}]  level=INFO
    END
    Run Keyword If    ${warningsCount} <= ${100}  Append To File  ${resultFile}    ${full_wrn_output}\n
    ...    ELSE                                   Append To File  ${resultFile}    ${warningsCount} > 100, pls check syslog files\n

Check 4X4 MIMO enabled
    [Documentation]
    ...              Description: check whether 4*4 mimo enabled
    [Arguments]    ${dlMimoMode}
    @{mimo_mode_list}    create list    4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
    ${status}    run keyword and return status    list should contain value    ${mimo_mode_list}    ${dlMimoMode}
    ${4x4_mimo_enabled} =    set variable if    '${status}' == '${True}'    ${True}    ${False}
    [return]   ${4x4_mimo_enabled}

Get Lcid From BTSLog By QosId ${fiveQi} with Syslog path ${syslogPath}
    # [Arguments]    ${fiveQi}=7
    ${ret}    OperatingSystem.Run
    ...    command=cd ${syslogPath}; cat *.LOG |grep -a "qosId\: ${fiveQi}" | grep -av grep
    Should Contain    ${ret}    qosId\: ${fiveQi}
    # ${matches}    Get Regexp Matches    ${ret}    drbId\:\\d+
    ${matches}    Get Regexp Matches    ${ret}    drbId\s*:\s*\d+
    BuiltIn.Log    ${matches[-1]}
    ${matches_nums}    Create List
    FOR    ${match}    IN    ${matches}
        ${matches_num}    Get Regexp Matches     ${matches[-1]}    \\d+
        Append to List    ${matches_nums}    ${matches_num}[0]
    END
    [Return]    ${matches_nums}

# adaptation after taf.sbts.oam.coam.admin 2.104.2
Get nrCellIdentity In Binary Format
    [Arguments]    ${cell_grp}    ${cell_nr}
    ${connection}    coam.setup_admin
    ${subcells_info_dict}    coam.get_subcells_info    connection=${connection}
    ${nrCellIdentity_binary}    Convert To Binary
    ...                         ${subcells_info_dict['NRCELLGRP-${cell_grp}']['NRCELL-${cell_nr}']['NRCELL_R']['parameters']['nrCellIdentity']}
    ...                         prefix=0b	length=36
    [Return]    ${nrCellIdentity_binary}
    [Teardown]    coam.teardown_admin    connection=${connection}

# adaptation after taf.sbts.oam.coam.admin 2.104.2
Get nrCellIdentity From coam ADMIN
    [Arguments]    ${cell_grp}    ${cell_nr}    ${alias}=coam_gnb
    ${subcells_info_dict}    coam.get_subcells_info    connection=${alias}
    ${nrCellIdentity}    set variable
    ...                         ${subcells_info_dict['NRCELLGRP-${cell_grp}']['NRCELL-${cell_nr}']['NRCELL_R']['parameters']['nrCellIdentity']}
    [Return]    ${nrCellIdentity}


# -----------------------------------------------------------------------------------------------------------------------------

Verify Sequence in File
    [Documentation]
    ...    verify log sequence in file, base on sequence in defined list, check is case insensitive
    ...    if message in the list not found, then the check breaks, fails the keyword and displays a log with the reason for failure
    ...
    ...    Example:
    ...       | @{interRatHo_seq}=  Create List
    ...       | ...    ue_measurement_send_nr meas_id=\\d event=B2
    ...       | ...    HANDOVER REQUIRED: gNB=2
    ...       | ...    Received Handover Required from GNB-2 with Handover Type FIVEGS-TO-EPS and cause RAN ng inter system handover triggered for UE
    ...       | ...    Received Handover Request Acknowledge Message
    ...       | ...    message c1 : mobilityFromNRCommand
    ...       | Verify Sequence in File    /opt/iphy/latest/egate_console.log    @{interRatHo_seq}
    ...
    ...    | file_path |   file location |
    ...    | patternlist |     List of wanted regular expression |
    ...
    [Arguments]  ${ueid}    ${file_path}  @{patternlist}
    ${contents}=    OperatingSystem.Get File    ${file_path}
    log_check.verify_sequence_in_log    ${ueid}    ${contents}    @{patternlist}

