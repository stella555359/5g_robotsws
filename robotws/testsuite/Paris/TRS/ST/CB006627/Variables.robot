*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB006627: SyncE Assisted Holdover


*** Variables ***
# Margin for assisted holdver duration (+/-)
${Margin}=          15 min

# OAM 5GNB IP
${bts_addr}=        ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${gnb_mrbts}=       MRBTS-${tl.gnbs[1].dus[0].instance_id}

# OAM LTE IP
${enb_addr}=        ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${enb_mrbts}=       MRBTS-${tl.gnbs[0].dus[0].instance_id}

# Result to save logs
${result_path}=     /home/ute/test_results
