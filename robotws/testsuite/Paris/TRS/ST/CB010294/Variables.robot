*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB010294


*** Variables ***
# OAM 5GNB IP and IDs (or PCELL ENB for CA LTE inter ENB confs)
${bts_addr}=                ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${gnb_mrbts}=               MRBTS-${tl.gnbs[0].dus[0].instance_id}
${gnb_nrbts}=               NRBTS-${tl.gnbs[0].dus[0].global_bts_id}
${gnb_lnbts}=               LNBTS-${tl.gnbs[0].dus[0].global_bts_id}

# BTS configuration

# 10294
${the_abio}=                BBMOD_A-3
${scf_file_10294}=          testsuite/Paris/TRS/ST/CB010294/SCF_CV135_AVQL_ABIO.xml

# UE configuration
${UE_ALIAS_1}=              ANDROID_UE_1
${UE_ALIAS_2}=              ANDROID_UE_2
${CAPABILITIES}=            REAL_UE
${DL_THROUGHPUT}=           100 Mbits/sec
${DL_MIN_THROUGHPUT}=       66000
${UL_THROUGHPUT}=           25 Mbits/sec
${UL_MIN_THROUGHPUT}=       15000
${DURATION}=                30s
${PROTOCOL}=                udp
${PACKET}=                  1000B
${DL_PORT}=                 34018
${UL_PORT}=                 34019
