*** Settings ***
Documentation    Common variables for 1200 feature

*** Variables ***
${PROGRAM}                                    ${None}
&{SIG_DRB_RLO}                                 prefix=NR-RadioBearerConfig     code_stream=100928DE0F145CE0
&{SIG_DRB_RL_RESUME_LTE_TO_NR}                 prefix=NR-RadioBearerConfig     code_stream=100928DE0F14DCE0
&{SIG_DRB_RL_RESUME_LTE_TO_NR_LTE}             prefix=NR-RadioBearerConfig     code_stream=100928DE0F1480E0
&{SIG_DRB_RLO_SRB3}                            prefix=NR-DL-DCCH-Message       code_stream=0280804946F           #NR-DL-DCCH-Message
&{SIG_DRB_RL_RESUME_SRB3_LTE_TO_NR}            prefix=NR-DL-DCCH-Message       code_stream=0480804946F
&{SIG_DRB_RL_RESUME_SRB3_LTE_TO_NR_LTE}        prefix=NR-DL-DCCH-Message       code_stream=0480804946F
&{MUL_DRB_RLO}                                 prefix=NR-RadioBearerConfig     code_stream=102928DE0F145CE4988F078A2E70
&{MUL_DRB_RL_RESUME_LTE}                       prefix=NR-RadioBearerConfig     code_stream=102928DF8FC537392623F1F8A6E700
&{MUL_DRB_RL_RESUME_LTE_TO_NR_LTE}             prefix=NR-RadioBearerConfig     code_stream=102928DF8FC520392623F1F8A40700
&{DRB_WITH_NR}                                 prefix=NR-RadioBearerConfig     code_stream=140D311FAFC5373985
&{DRB_WITH_NRLTE}                              prefix=NR-RadioBearerConfig     code_stream=142D28DFAFC52039A623F5F8A40730A0
&{DRB_WITH_LTE_NRLTE}                          prefix=NR-RadioBearerConfig     code_stream=142928D39BC2

${E500_SCRIPTS_MUL_DRB}     ${CURDIR}/../TestData/E500_script_60m_aahf_mul_drb
${PHYS_CELLID}                                 50

${ASIK_ALIAS}              ASIK Master
${ASIK_SLAVE_ALIAS}        ASIK Slave
${ENB_ALIAS}               enblte
${ENB_OAM}                 ENB_OAM

${BTS_ID}         ${tl.gnbs[0].instance_id}
${SWCONFIG_DEFAULT_FILE_PATH}      /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_default_TL${BTS_ID}.txt
${SCF_DEFAULT_FILE_PATH}      /home/ute/Projects/mmw1_config/${testline_name}/scf/scf_SG4_TL${BTS_ID}.xml
${ENB_IP}                     ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${LUA_SCRIPT_PATH}        /home/ute/luashark_script/generated_luashark_TL${BTS_ID}/luashark.lua
${UPUE_LOG_PREFIX_Base}    1200_A_Base_UPUE_trace

${TRAFFIC_TIME}                  3600
${UL_THROUGHPUT}                 10
${DL_THROUGHPUT}                 50
@{IPERF_UL_PORT_LIST}            5410
@{IPERF_UL_PORT_LIST_MUL_DRB}    5410    5411
@{IPERF_UL_PORT_LIST_MUL_UE}     5410    5411    5412    5413    5414
${IPERF_DL_PORT}           ${tl.ues[0].iperf_details.port}
${IPERF_DL_DEDIC_PORT}     41113

#${IPERF_UL_PORT}           ${tl.appserver.iperf_details.port}
#${IPERF_UL_DEDIC_PORT}     5411
#@{IPERF_UL_PORT_LIST}       5410    5411    5412    5413    5414
@{IPERF_UL_PORT_LIST_TO_KILL}    5411    5412    5413    5414    41112    41088    41500

${DELTA_TO_ADD}                      8
# Data for multi UE cases
${NUMBER_OF_UE}             3
@{UE_INDEX_LIST}            0    1    2

${appserver_addr}        ${tl.appserver.iperf_details.ssh_connection_details.addr}
${appserver_username}    ${tl.appserver.iperf_details.ssh_connection_details.username}
${appserver_password}    ${tl.appserver.iperf_details.ssh_connection_details.password}

