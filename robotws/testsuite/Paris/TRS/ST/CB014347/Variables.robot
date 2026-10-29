*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB012184: L1 pool


*** Variables ***
# OAM 5GNB IP and IDs (or PCELL ENB for CA LTE inter ENB confs)
${bts_addr}=                    ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${gnb_mrbts}=                   MRBTS-${tl.gnbs[1].dus[0].instance_id}
${gnb_nrbts}=                   NRBTS-${tl.gnbs[1].dus[0].global_bts_id}
${gnb_lnbts}=                   LNBTS-${tl.gnbs[1].dus[0].global_bts_id}

# OAM LTE IP and IDs
${enb_addr}=                    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${enb_mrbts}=                   MRBTS-${tl.gnbs[0].dus[0].instance_id}
${enb_nrbts}=                   NRBTS-${tl.gnbs[0].dus[0].global_bts_id}
${enb_lnbts}=                   LNBTS-${tl.gnbs[0].dus[0].global_bts_id}

# SCF files
${scf_file_12184}=              testsuite/Paris/TRS/ST/CB012184/SCF_CV31_CB012184_TC25_GPS.xml

# Mirroring
${mirror_dpdk_addr}=            10.0.117.57
${mirror_dpdk_username}=        localuser
${mirror_dpdk_password}=        10c@1user

${mirror_switch_addr}=          10.0.117.57
${mirror_switch_username}=      admin
${mirror_switch_password}=      alcatel
${mirror_switch_port}=          C14    C23
