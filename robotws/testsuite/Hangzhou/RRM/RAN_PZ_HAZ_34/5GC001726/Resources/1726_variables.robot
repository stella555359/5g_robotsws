*** Settings ***
Documentation    Common variables for 1726 feature

*** Variables ***
${PROGRAM}                                    ${None}
${BTS_ID}                                     ${tl.gnbs[0].instance_id}
${SWCONFIG_DEFAULT_FILE_PATH}     /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${BTS_ID}.txt
${SCF_DEFAULT_FILE_PATH}     /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${BTS_ID}_8cc_CA.xml
${5CC_SCF_DEFAULT_FILE_PATH}     /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${BTS_ID}_5cc_CA.xml
${LUA_SCRIPT_PATH}        /home/ute/luashark_script/generated_luashark/luashark.lua
${TIMEOUT_CLUSTER}    10 min
${TIMEOUT_REST_API_RESTART}    600

#traffic variables
${UL_PORT}        ${tl.ues[0].iperf_details.ssh_connection_details.port}
${UL_LENGTH}      1024B
${TRAFFIC_TIME}   3600
${DL_PORT}        ${tl.ues[0].iperf_details.port}
${DL_LENGTH}      1024B

@{PCELL_INDEX}    1    2
${ENB_IP}         ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

#cobham
${MULTI_DRB_CODE_STREAM}        NR-RadioBearerConfig 142928D39BC2
${E500_SCRIPTS_BASE}            ${CURDIR}/../TestData/E500_script_056
${E500_SCRIPTS_MUL_DRB}         ${CURDIR}/../TestData/E500_script_056_mul_drb
${IPERF_DL_DEDIC_PORT}          5410
${IPERF_UL_DEDIC_PORT}          5411

${EXPECTED_DTX_RATIO}    0.02
${EXPECTED_BLER}    0.1

# Data for cobham multi UE cases
${E500_SCRIPTS_MULTI_UE}    ${CURDIR}/../TestData/E500_script_056_mutli_ue
@{IPERF_UL_PORT_LIST}       5410    5411    5412    5413    5414    5415    5416    5417    5418    5419    5420
@{IPERF_UL_PORT_LIST_TO_KILL}    5411    5412    5413    5414    5415    5416    5417    5418    5419    5420    54112
${NUMBER_OF_UE}             11

# PA initial value
${IDEAL_LAYER0_UL_ATTEN}    32
${IDEAL_LAYER0_DL_ATTEN}    32
${IDEAL_LAYER1_UL_ATTEN}    32
${IDEAL_LAYER1_DL_ATTEN}    32

#initialized the variables
${appserversim_addr}                ${None}
${appserversim_password}            ${None}
${appserversim_username}            ${None}
${attenuation_port}                 ${None}
${TM500_IP}                         ${None}
${E500_PW}                          ${None}
${TM500_PORT}                       ${None}
${E500_USER}                        ${None}
${E500_SSH_USER}                    ${None}
${E500_ASC_USER}                    ${None}
${TM500_PW}                         ${None}
${TM500_USER}                       ${None}
${TMA_APP_PATH}                     ${None}

@{LIST_ATTENUATION_VALUE}           ${None}
${ATTENUATOR_ADDR}                  ${None}

${RETRY_TIME}                       ${3}

${TSHARK_PATH}            /usr/bin/tshark
${PDML_CONVERT_X2AP_TEMPLATE}      {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
