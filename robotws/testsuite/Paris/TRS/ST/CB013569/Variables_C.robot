*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB013569


*** Variables ***
# OAM 5GNB IP and IDs (or PCELL ENB for CA LTE inter ENB confs)
${bts_addr}=                ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${gnb_mrbts}=               MRBTS-${tl.gnbs[0].dus[0].instance_id}
${gnb_nrbts}=               NRBTS-${tl.gnbs[1].dus[0].global_bts_id}
${gnb_lnbts}=               LNBTS-${tl.gnbs[0].dus[0].global_bts_id}

# BTS configuration

${CV31_scf_file_13569}=     testsuite/Paris/TRS/ST/CB013569/SCF_CV31_CB013569_TC_11.xml

# UE configuration
${UE_ALIAS_1}=              COM9
${CAPABILITIES}=            AT_UE
${DL_4G_THROUGHPUT}=        10 Mbits/sec
${DL_4G_MIN_THROUGHPUT}=    5000
${UL_4G_THROUGHPUT}=        5 Mbits/sec
${UL_4G_MIN_THROUGHPUT}=    2500
${DL_5G_THROUGHPUT}=        40 Mbits/sec
${DL_5G_MIN_THROUGHPUT}=    30000
${UL_5G_THROUGHPUT}=        25 Mbits/sec
${UL_5G_MIN_THROUGHPUT}=    15000
${DURATION}=                30s
${PROTOCOL}=                udp
${PACKET}=                  1000B
${DL_PORT}=                 34028
${UL_PORT}=                 34029

# Cells
${LTECELL}=                 LNCEL-121
${NRCELL}=                  NRCELL-521
