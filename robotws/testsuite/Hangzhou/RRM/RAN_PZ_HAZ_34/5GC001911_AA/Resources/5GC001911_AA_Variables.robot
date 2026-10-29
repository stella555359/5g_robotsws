*** Settings ***
Documentation    Common variables for 5GC001911-AA-776 feature

*** Variables ***
${BTS_ID}    ${tl.gnbs[0].instance_id}
${SCF_DEFAULT_FILE_PATH_DU}    /home/ute/Projects/mmw1_config/${testline_name}/scf/GNB_SCF_DU_MMW1_TL${tl.gnbs[0].instance_id}.xml
${LUA_SCRIPT_PATH}               /opt/ute/luashark/generated_luashark/luashark.lua
${SWCONFIG_DEFAULT_FILE_PATH}       /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${BTS_ID}.txt

# these are paths on UTE/TestPC
${IPSL_DEFAULT_TEMPLATE}    ${CURDIR}/../TestData/IPSL_FILES_COMMON
${IPSL_CONFIG_UE1_QCI6_7_8_UE2_QCI_7_8_9}       ${CURDIR}/../TestData/IPSL_CONFIG_TL${BTS_ID}/IPSL_CONFIG_UE1_QCI6_7_8_UE2_QCI_7_8_9
${IPSL_CONFIG_UE1_QCI6_7_8_UE2_QCI_8_9_69_70}   ${CURDIR}/../TestData/IPSL_CONFIG_TL${BTS_ID}/IPSL_CONFIG_UE1_QCI6_7_8_UE2_QCI_8_9_69_70
${IPSL_CONFIG_UE1_QCI6_7_8_UE2_QCI_9_69_70}     ${CURDIR}/../TestData/IPSL_CONFIG_TL${BTS_ID}/IPSL_CONFIG_UE1_QCI6_7_8_UE2_QCI_9_69_70
${IPSL_CONFIG_UE1_QCI6_UE2_7}                   ${CURDIR}/../TestData/IPSL_CONFIG_TL${BTS_ID}/IPSL_CONFIG_UE1_QCI6_UE2_QCI7
${IPSL_CONFIG_UE1_QCI7_UE2_QCI9}                ${CURDIR}/../TestData/IPSL_CONFIG_TL${BTS_ID}/IPSL_CONFIG_UE1_QCI7_UE2_QCI9


# these are paths on IPSL server(usually control PC)
${IPSL_TOOL_DIR}           c:/IpslTools
${IPSL_CONFIG_DIR}         c:/IPSL/TA_TMP/1911_AA
${IPSL_COMPILER_FLAGS}     /pDIA05IGX /its /b

# iperf related variables
${UL_THROUGHPUT}    100M
${DL_THROUGHPUT}    80M
${SMALL_DATA_DL}    10
${SMALL_DATA_UL}    5
${TRAFFIC_TIME}     6000
${UL_BUFFER_SIZE}   1400B
${DL_BUFFER_SIZE}   1400B
${DURATION_FOR_TPUT_STABLE}    30
${TPUT_DEVIATION}    0.2

${UE1_DL_PORTs}        ${tl.ues[0].iperf_details.ports}
${UE1_DL_PORT_QCI8}    ${tl.ues[0].iperf_details.port}
${UE1_DL_PORT_QCI6}    ${UE1_DL_PORTs[0]}
${UE1_DL_PORT_QCI7}    ${UE1_DL_PORTs[1]}
${UE1_DL_PORT_QCI9}    ${UE1_DL_PORTs[2]}
${UE1_DL_PORT_QCI69}   ${UE1_DL_PORTs[3]}
${UE1_DL_PORT_QCI70}   ${UE1_DL_PORTs[4]}

${UE2_DL_PORTs}        ${tl.ues[1].iperf_details.ports}
${UE2_DL_PORT_QCI8}    ${tl.ues[1].iperf_details.port}
${UE2_DL_PORT_QCI6}    ${UE2_DL_PORTs[0]}
${UE2_DL_PORT_QCI7}    ${UE2_DL_PORTs[1]}
${UE2_DL_PORT_QCI9}    ${UE2_DL_PORTs[2]}
${UE2_DL_PORT_QCI69}   ${UE2_DL_PORTs[3]}
${UE2_DL_PORT_QCI70}   ${UE2_DL_PORTs[4]}

${UL_PORTS}            ${tl.appserver.iperf_details.ports}
${UE1_UL_PORT_QCI8}    ${UL_PORTS[0]}
${UE1_UL_PORT_QCI6}    ${UL_PORTS[1]}
${UE1_UL_PORT_QCI7}    ${UL_PORTS[2]}
${UE1_UL_PORT_QCI9}    ${UL_PORTS[3]}
${UE1_UL_PORT_QCI69}   ${UL_PORTS[4]}
${UE1_UL_PORT_QCI70}   ${UL_PORTS[5]}

${UE2_UL_PORT_QCI8}    ${UL_PORTS[6]}
${UE2_UL_PORT_QCI6}    ${UL_PORTS[7]}
${UE2_UL_PORT_QCI7}    ${UL_PORTS[8]}
${UE2_UL_PORT_QCI9}    ${UL_PORTS[9]}
${UE2_UL_PORT_QCI69}   ${UL_PORTS[10]}
${UE2_UL_PORT_QCI70}   ${UL_PORTS[11]}


@{UE1_DL_PORT_QCI6_7_8}      ${UE1_DL_PORT_QCI8}  ${UE1_DL_PORT_QCI6}  ${UE1_DL_PORT_QCI7}
@{UE1_UL_PORT_QCI6_7_8}      ${UE1_UL_PORT_QCI8}  ${UE1_UL_PORT_QCI6}  ${UE1_UL_PORT_QCI7}
@{UE2_DL_PORT_QCI7_8_9}      ${UE2_DL_PORT_QCI8}  ${UE2_DL_PORT_QCI7}  ${UE2_DL_PORT_QCI9}
@{UE2_UL_PORT_QCI7_8_9}      ${UE2_UL_PORT_QCI8}  ${UE2_UL_PORT_QCI7}  ${UE2_UL_PORT_QCI9}
@{UE2_DL_PORT_QCI8_9_69_70}      ${UE2_DL_PORT_QCI8}  ${UE2_DL_PORT_QCI9}  ${UE2_DL_PORT_QCI69}  ${UE2_DL_PORT_QCI70}
@{UE2_UL_PORT_QCI8_9_69_70}      ${UE2_UL_PORT_QCI8}  ${UE2_UL_PORT_QCI9}  ${UE2_UL_PORT_QCI69}  ${UE2_UL_PORT_QCI70}
@{UE2_DL_PORT_QCI9_69_70}        ${UE2_DL_PORT_QCI9}  ${UE2_DL_PORT_QCI69}  ${UE2_DL_PORT_QCI70}
@{UE2_UL_PORT_QCI9_69_70}        ${UE2_UL_PORT_QCI9}  ${UE2_UL_PORT_QCI69}  ${UE2_UL_PORT_QCI70}


