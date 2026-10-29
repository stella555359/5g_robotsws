*** Settings ***
Documentation    Common variables for 1541 feature

*** Variables ***
${RU_1_SERIAL_NUM}               ${tl.gnbs[0].dus[0].rus[0].serial_number}
${RU_PRODUCT_CODE}               475068A.101
${RU_TYPE}                       ${tl.gnbs[0].dus[0].rus[0].radio_type}
${RU_RESOURCE_BUILD_KEY}         LTX_AWHHD_N1
${SCF_DEFAULT_FILE_PATH}          /opt/ute/scf/SCF_SG4_TL${tl.gnbs[0].instance_id}_4T2R.xml
${SCF_FILE_PATH_2T2R}             /opt/ute/scf/SCF_SG4_TL${tl.gnbs[0].instance_id}_2T2R.xml
${SWCONFIG_DEFAULT_FILE_PATH}     /opt/ute/swconfig/swconfig_SG4_TL${tl.gnbs[0].instance_id}.txt
${INTERFACE_TYPE}                CPRI
${MODULE_TYPE}                   RRH
${LMP_INTERNAL_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${LUA_SCRIPT_PATH}               /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${RECOVERY_TIMEOUT}              10 min

# UL/DL throughput
${UL_PORT}        ${tl.ues[0].iperf_details.ssh_connection_details.port}
${UL_LENGTH}      1024B
${UL_TIME}        6000
${DL_PORT}        ${tl.ues[0].iperf_details.port}
${DL_LENGTH}      1024B
${DL_TIME}        6000
${UL_THROUGHPUT}    200M
${DL_THROUGHPUT}    600M
#${UE0_PDU_IP}    10.57.242.54
#${UE0_PDU_PORT}    5

#expected percentage of given theoretical throuput
${EXP_TPUT_PERCENTAGE}                0.95
${PDL_CHECKING}    ${False}
