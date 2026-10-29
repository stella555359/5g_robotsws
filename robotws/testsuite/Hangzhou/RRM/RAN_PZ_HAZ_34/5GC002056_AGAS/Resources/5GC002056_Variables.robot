*** Settings ***
Documentation    Common variables for 2056 feature

*** Variables ***
${SCF_DEFAULT_FILE_PATH}          /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}.xml
${ENB_SCF_DEFAULT_FILE_PATH}      /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_ENB.xml
${SWCONFIG_DEFAULT_FILE_PATH}     /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${tl.gnbs[0].instance_id}.txt
${TIMEOUT_MODIFY_PARA}               6 min                    #timeout for COAM update several parameters via rest api
${RECOVERY_TIMEOUT}              10 min
${GNB_COAM_ALIAS}                 GNB_OAM
# UL/DL throughput
${UL_PORT}          ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}          ${tl.ues[0].iperf_details.port}
${UL_THROUGHPUT}    30M
${DL_THROUGHPUT}    200M
${EXP_AVG_TPUT_PERCENTAGE}    0.90
${EXP_MAX_TPUT_PERCENTAGE}    1.5
${EXP_MIN_TPUT_PERCENTAGE}    0.85



