*** Settings ***
Documentation    This is about common variables used for 7880 feature.

*** Variables ***
# WA: dummy value for ${testline_name}, only for pipeline use.
${testline_name}    7_5_UTE5G402T2126
${IS_LOG_CAPTURED_CASE_LEVEL}                       ${True}
${MRBTS_ID}                                         ${tl.gnbs[0].instance_id}
${NRBTS_ID}                                         ${tl.gnbs[0].global_bts_id}
${DN_MRBTS}                                         MRBTS-${MRBTS_ID}
${DN_NRBTS}                                         ${DN_MRBTS}/NRBTS-${NRBTS_ID}
${DN_NRDU1}                                         ${DN_NRBTS}/NRDU-1
${NSA_SA}                      SA
${TIMER_FOR_MODIFY_VIA_API}    5min
${TIMER_FOR_CELL_ON_AIR}       15min
${TIMER_FOR_ONLINE_STATUS_CHECK}    5min
${DL_TPUT_IPERF}    430M
${UL_TPUT_IPERF}    50M
