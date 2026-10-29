*** Settings ***
Documentation  Test case implementation of BEP/EDA CB008009-A feature. The scenario benchmarks following counter with
...            feature parameter on and off: M55349C03001, M55349C04001, M55349C04001, M55349C00009

Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008009/resources/keywords.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/multi_ue.robot
Library   taf.sbts.oam.coam.admin

*** Variables ***
@{ues}  ue_1

${tput_time}      60s
${dl_tput_value}  100 Mbits/sec
${ul_tput_value}  50  Mbits/sec

*** Keywords ***
[1]CB008009-B_6_UL_throughput_Time_counter_modification_on_SA
    Prepare Test Line for CB008009

    detach ues from cell  ${ues}
    attach ues to cell  ${ues}
    Start ULDL for UEs  ${ues}  ${tput_time}  ${dl_tput_value}  ${ul_tput_value}
    Wait for CB008009 counters
    Stop all datatransfers

    ${ul_volume_rlc_off}  Get M55349C03001 counter
    ${ul_time_rlc_off}    Get M55349C04001 counter
    ${ul_rls_qos9_off}    Get M55349C00009 counter
    ${ul_rlc_1cc_sa_off}  Get M55349C00042 counter
    ${ul_time_pmqap_off}  Get M55353C01001 counter

    Activate CB008009 feature

    detach ues from cell  ${ues}
    attach ues to cell  ${ues}
    Start ULDL for UEs  ${ues}  ${tput_time}  ${dl_tput_value}  ${ul_tput_value}
    Wait for CB008009 counters
    Stop all datatransfers

    ${ul_volume_rlc_on}  Get M55349C03001 counter
    ${ul_time_rlc_on}    Get M55349C04001 counter
    ${ul_rls_qos9_on}    Get M55349C00009 counter
    ${ul_rlc_1cc_sa_on}  Get M55349C00042 counter
    ${ul_time_pmqap_on}  Get M55353C01001 counter

    compare_counters_ratio  ${ul_volume_rlc_off}  ${ul_volume_rlc_on}
    compare_counters_ratio  ${ul_time_rlc_off}    ${ul_time_rlc_on}
    compare_counters_ratio  ${ul_rls_qos9_off}    ${ul_rls_qos9_on}
    compare_counters_ratio  ${ul_rlc_1cc_sa_off}  ${ul_rlc_1cc_sa_on}
    compare_counters_ratio  ${ul_time_pmqap_off}  ${ul_time_pmqap_on}
