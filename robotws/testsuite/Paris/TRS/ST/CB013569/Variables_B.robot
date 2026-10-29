*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB013569


*** Variables ***
# OAM 5GNB IP and IDs (or PCELL ENB for CA LTE inter ENB confs)
${bts_addr}=                ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${gnb_mrbts}=               MRBTS-${tl.gnbs[0].dus[0].instance_id}
${gnb_nrbts}=               NRBTS-${tl.gnbs[0].dus[0].global_bts_id}
${gnb_lnbts}=               LNBTS-${tl.gnbs[0].dus[0].global_bts_id}

# BTS configuration

${CV174_scf_file_13569}=    testsuite/Paris/TRS/ST/CB013569/SCF_CV174_CB013569_TC_05.xml

# UE configuration
${UE_ALIAS_1}=              COM5
${CAPABILITIES}=            AT_UE
${DL_5G_THROUGHPUT}=        20 Mbits/sec
${DL_5G_MIN_THROUGHPUT}=    15000
${UL_5G_THROUGHPUT}=        15 Mbits/sec
${UL_5G_MIN_THROUGHPUT}=    10000
${DURATION}=                30s
${PROTOCOL}=                udp
${PACKET}=                  1000B
${DL_PORT}=                 34028
${UL_PORT}=                 34029

# Cells
${NRCELL1}=                 NRCELL-21
${NRCELL2}=                 NRCELL-22
