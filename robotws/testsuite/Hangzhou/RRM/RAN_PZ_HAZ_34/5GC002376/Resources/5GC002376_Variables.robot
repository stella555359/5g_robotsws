*** Settings ***
Documentation    Common variables for 2376 feature

*** Variables ***
${DU_SCF_DEFAULT_FILE_PATH}     /home/ute/Projects/mmw1_config/${testline_name}/scf/GNB_SCF_DU_MMW1_TL${tl.gnbs[0].instance_id}.xml
${ENB_SCF_DEFAULT_FILE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/scf/ENB_SCF_MMW1_TL${tl.gnbs[0].instance_id}.xml
${DU_SWCONFIG_DEFAULT_FILE_PATH}     /home/ute/Projects/mmw1_config/swconfig_MMW1_TL${tl.gnbs[0].instance_id}.txt
${TIMEOUT_MODIFY_PARA}               6 min                    #timeout for COAM update several parameters via rest api

# UL/DL throughput
${UL_PORT}          ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}          ${tl.ues[0].iperf_details.port}
${UL_THROUGHPUT}    70M
${DL_THROUGHPUT}    300M
${EXP_AVG_TPUT_PERCENTAGE}    0.90
${EXP_MAX_TPUT_PERCENTAGE}    1.5
${EXP_MIN_TPUT_PERCENTAGE}    0.85



