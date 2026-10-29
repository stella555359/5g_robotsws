*** Settings ***
Documentation    Common variables for 5GC002569-A-1926 feature

*** Variables ***
${SCF_DEFAULT_FILE_PATH_DU}    /home/ute/Projects/mmw1_config/${testline_name}/scf/GNB_SCF_DU_MMW1_TL${tl.gnbs[0].instance_id}.xml
${LUA_SCRIPT_PATH}               /opt/ute/luashark/generated_luashark/luashark.lua
${SWCONFIG_DEFAULT_FILE_PATH}       /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${tl.gnbs[0].instance_id}.txt

@{INIT_QCI_LIST}   6    7
@{ADD_QCI_LIST}    8    9

# these are paths on UTE/TestPC
${IPSL_DEFAULT_TEMPLATE}    ${CURDIR}/../TestData/IPSL_FILES_TL${tl.gnbs[0].instance_id}

# these are paths on IPSL server(usually control PC)
${IPSL_TOOL_DIR}           c:/IpslTools
${IPSL_CONFIG_DIR}         c:/IPSL/TA_TMP/2569_A
${IPSL_COMPILER_FLAGS}     /pDIA05IGX /its /b
${DELAY_OF_DRB_SETUP}    300

# iperf related variables
${UL_THROUGHPUT}    100M
${DL_THROUGHPUT}    500M
${TRAFFIC_TIME}     6000
${UL_BUFFER_SIZE}   1400B
${DL_BUFFER_SIZE}   1400B
${DURATION_FOR_TPUT_STABLE}    60


${DL_PORTs}         ${tl.ues[0].iperf_details.ports}
${DL_PORT_QCI8}     ${tl.ues[0].iperf_details.port}
${DL_PORT_QCI6}     ${DL_PORTs[0]}
${DL_PORT_QCI7}     ${DL_PORTs[1]}
${DL_PORT_QCI9}     ${DL_PORTs[2]}

${UL_PORTS}         ${tl.appserver.iperf_details.ports}
${UL_PORT_QCI8}     ${UL_PORTS[0]}
${UL_PORT_QCI6}     ${UL_PORTS[1]}
${UL_PORT_QCI7}     ${UL_PORTS[2]}
${UL_PORT_QCI9}     ${UL_PORTS[3]}

@{DL_PORT_QCI6_7}          ${DL_PORT_QCI6}  ${DL_PORT_QCI7}
@{UL_PORT_QCI6_7}          ${UL_PORT_QCI6}  ${UL_PORT_QCI7}
@{DL_PORT_QCI6_7_8_9}      ${DL_PORT_QCI6}  ${DL_PORT_QCI7}  ${DL_PORT_QCI8}  ${DL_PORT_QCI9}
@{UL_PORT_QCI6_7_8_9}      ${UL_PORT_QCI6}  ${UL_PORT_QCI7}  ${UL_PORT_QCI8}  ${UL_PORT_QCI9}
