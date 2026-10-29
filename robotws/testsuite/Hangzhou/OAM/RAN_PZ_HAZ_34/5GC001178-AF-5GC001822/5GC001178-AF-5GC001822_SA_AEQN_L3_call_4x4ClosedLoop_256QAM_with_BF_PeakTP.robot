*** Settings ***
Documentation    5GC001178-AF-5GC001822_SA_AEQN_L3_call_4x4ClosedLoop_256QAM_with_BF_PeakTP
Resource   ../common/taf_coam.robot
Resource   ../common/Inseego.robot
Resource   ./Resource/common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Force Tags   SG_08   CA_5G_Siso         CRT
...    PY36

*** Variables ***
${dl_tput}   900
${ul_tput}   100
${L3CALL_CELLID}    2

*** Test Cases ***
[1]5GC001178-AF-5GC001822_SA_AEQN_L3_call_4x4ClosedLoop_256QAM_with_BF_PeakTP
    [Tags]    AUTHOR_david.wang@nokia-sbell.com
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup
#    ...   AND   COAM WEBUI Change CHBW to 100MHZ   L3CALL_CELLID=${L3CALL_CELLID}
    ...   AND   COAM Login   alias=${coam_alias}
    ...   AND   Wait Until Keyword Succeeds   5min    30s    COAM Check BTS OnAir   connection=${coam_alias}
    ${Nrdim_param_dic}     Create dictionary     pucchPrb=${20}    actDynUlResAlloc=${1}     pCsiPrbsPerCell=${2}    pCSIPrbsPerUe=${1}
    ...    NbUes=${1}
    ${dl_expect}    ${ul_expect}    Get Expected Throughput by NRDIM    cellid=${L3CALL_CELLID}    Nrdim_param_dic=${Nrdim_param_dic}
#    ${dl_expect}   Evaluate   int(${dl_calc})  # from 870
#    ${ul_expect}   Evaluate   int(${ul_calc})  # from 90
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${iperf_port}   Set Variable If   '${ue_type}'=='askey'    58092
    ...   ${tl.ues[${ue_index}].iperf_details.port}>${50000}   ${tl.ues[${ue_index}].iperf_details.port}
    ...   '${tl.gnbs[0].global_bts_id}'=='None'   58092
    ...   len("${tl.gnbs[0].global_bts_id}")==${2}   580${tl.gnbs[0].global_bts_id}   58${tl.gnbs[0].global_bts_id}
    Wait Until Keyword Succeeds   3 times   30s     Call Setup and check tput  port=${iperf_port}   method=PEAK
    ...   tput=${dl_tput}   tput_expect=${dl_expect}
    ...   peak_ul=${ul_tput}   ul_expect=${ul_expect}
    [Teardown]   Run Keywords   Wait Until Keyword Succeeds   3 times   30s    Reboot UE control PC ASEKY    AND
    ...   CI_interface.Common Case Teardown   AND   COAM Logout   connection=${coam_alias}
