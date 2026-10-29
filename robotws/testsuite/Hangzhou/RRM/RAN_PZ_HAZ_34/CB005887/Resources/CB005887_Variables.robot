*** Variables ***

${SCF_DEFAULT_FILE_PATH_8CC_CA}    /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}.xml


${ENB_SCF_DEFAULT_FILE_PATH}      /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_ENB.xml

#data transfer
${DATA_TRANSFER_DIRECTION_UL}    ul
${DATA_TRANSFER_DIRECTION_DL}    dl
${DATA_TRANSFER_DIRECTION_DL_UL}     both
${DURATION_TIME}       5 min
${INTERVAL_TIME}        30 s
${TOTAL_TIME}           10 min
${TPUT_PERCENTAGE}      0.95
@{GNB_PS_CELL_INDEX_LIST}      1  2  3  4
${REPEAT_TIME}   1
${PDML_CONVERT_X2AP_TEMPLATE}      {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
${TSHARK_PATH}            /usr/bin/tshark



${UL_PORT}          ${tl.ues[0].iperf_details.ssh_connection_details.port}
${UL_LENGTH}        1400
${DL_PORT}          ${tl.ues[0].iperf_details.port}
${DL_LENGTH}        1400
${UL_THROUGHPUT}    600M
${DL_THROUGHPUT}    1500M
${UL_EXPECT}         400
${UL_EXPECT_3CC}    300
${DL_EXPECT}        2000
${UL_EXPECT_PEAK}    420
