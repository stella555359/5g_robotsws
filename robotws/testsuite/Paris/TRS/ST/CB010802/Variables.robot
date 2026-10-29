*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB008004: New SFN0 offset management


*** Variables ***
# OAM 5GNB IP and IDs (or PCELL ENB for CA LTE inter ENB confs)
${bts_addr}=            ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${gnb_mrbts}=           MRBTS-${tl.gnbs[1].dus[0].instance_id}
${gnb_nrbts}=           NRBTS-${tl.gnbs[1].dus[0].global_bts_id}
${gnb_lnbts}=           LNBTS-${tl.gnbs[1].dus[0].global_bts_id}

# OAM LTE IP and IDs
${enb_addr}=            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${enb_mrbts}=           MRBTS-${tl.gnbs[0].dus[0].instance_id}
${enb_nrbts}=           NRBTS-${tl.gnbs[0].dus[0].global_bts_id}
${enb_lnbts}=           LNBTS-${tl.gnbs[0].dus[0].global_bts_id}

# SCF files
${scf_file_10802}=      testsuite/Paris/TRS/ST/CB010802/SCF_CV31_2ASIL_CB010802.xml

# cells
${TDDCELL_1}=           108
${TDDCELL_2}=           109
