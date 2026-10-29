*** Settings ***
Documentation    Common variables for 5GC001912-EB-1095 feature

*** Variables ***
${SCF_DEFAULT_FILE_PATH_CU_255}              /opt/ute/scf/SCF_CU_MMW1_TL${tl.gnbs[0].cu.instance_id}.xml
${SCF_DEFAULT_FILE_PATH_DU_416}          /opt/ute/scf/SCF_DU_MMW1_TL${tl.gnbs[0].dus[0].instance_id}.xml
${SCF_DEFAULT_FILE_PATH_DU_415}          /opt/ute/scf/SCF_DU_MMW1_TL${tl.gnbs[0].dus[1].instance_id}.xml

${SWCONFIG_DEFAULT_FILE_PATH_DU_416}        /opt/ute/swconfig/swconfig_MMW1_TL${tl.gnbs[0].dus[0].instance_id}.txt
${SWCONFIG_DEFAULT_FILE_PATH_DU_415}        /opt/ute/swconfig/swconfig_MMW1_TL${tl.gnbs[0].dus[1].instance_id}.txt
@{DU_LIST}     0    1

${E500_SCRIPTS_BASE}           ${CURDIR}/../TestData/E500_script
${TMA_APP_PATH}     ${tl.ues[0].tma_path}
${E500_ASC_IP}      192.168.10.8
${E500_ASC_GROUP}   fddtdd
${TMA_SSH_ALIAS}        tma_ssh
${TMA_TELNET_ALIAS}     tma_ssh
${TMA_APP_ALIAS}        e500

${FTP_SRV_IP}        ${tl.appserver.iperf_details.ssh_connection_details.addr}
${FTP_SRV_USER}      ${tl.appserver.iperf_details.ssh_connection_details.username}
${FILE_TO_DOWNLOAD}    /home/mmw_sg1/test_50M.txt
${DIR_ON_CPC}          /home/${tl.ues[0].tma_host.username}
${EXP_FILE_CHECKSUM}    905644000
${EXP_FILE_SIZE}        50000000

${A2_MEAS_ID}    1
${A1_MEAS_ID}    2
${A3_MEAS_ID}    3

${TRACE_CAPTURE_DELAY}    5s


# iperf related variables
${IPERF_PATH}       ${tl.ues[0].iperf_details.iperf_path}
${UL_THROUGHPUT}    100M
${DL_THROUGHPUT}    600M
${TRAFFIC_TIME}     900
${UL_BUFFER_SIZE}   1024B
${DL_BUFFER_SIZE}   1024B
${DURATION_FOR_TPUT_STABLE}    60
${APPSRV_IP}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
${IPERF_DL_PORT}     ${tl.ues[0].iperf_details.port}
${IPERF_UL_PORT}     ${tl.appserver.iperf_details.port}
