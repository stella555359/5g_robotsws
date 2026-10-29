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

# 10871 Yoda
${yoda_the_abip}=           BBMOD_A-2
${yoda_scf_file_10871}=     testsuite/Paris/TRS/ST/CB010871/SCF_CV135_AVQL_ABIP_50G_16streams.xml
${yoda_ecpri_cablink}=      ${gnb_mrbts}/EQM-1/HWTOP-1/CABLINK-5

# 10871 Fisto
${fisto_the_abip}=          BBMOD_A-2
${fisto_scf_file_10871}=    testsuite/Paris/TRS/ST/CB010871/SCF_CV135_AVQC_ABIP_50G_32streams.xml
${fisto_ecpri_cablink}=     ${gnb_mrbts}/EQM-1/HWTOP-1/CABLINK-7

# CV31
${CV31_the_abip}=           BBMOD_A-2
${CV31_scf_file_10871}=     testsuite/Paris/TRS/ST/CB010871/SCF_CV31_2ASIL_CB008004_AVQL_3cells.xml

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
