*** Settings ***
Documentation    Common variables for 1596 1726 and 561 feature

*** Variables ***
${pdml_convert_f1ap_template}       {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml    #for 1726_GA_Continous
${RECOVERY_TIMEOUT}              10 min

${PTP_filter}    'ether proto 0x88f7'
${SyncE_filter}    'ether proto 0x8809'
${PTP_SyncE_filter}    'ether proto 0x88f7||0x8809'

${RU_log_02}    loner_561_A_02.pcap

${sourceportid}    ptp.v2.sourceportid
${clockidentity}    ptp.v2.clockidentity
${sync_message}     ptp.v2.messageid == 0x0
${announce_message}     ptp.v2.messageid == 0xb
${syncE_message}    eth.type == 0x8809 and ossp.esmc.event_flag == 0x0
${case_02_timer}    60s

${TSHARK_PATH}            /usr/bin/tshark
${PDML_CONVERT_X2AP_TEMPLATE}      {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
