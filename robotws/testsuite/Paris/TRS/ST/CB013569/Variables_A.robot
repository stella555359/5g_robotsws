*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB013569


*** Variables ***
# OAM 5GNB IP and IDs (or PCELL ENB for CA LTE inter ENB confs)
${bts_addr}=                        ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${gnb_mrbts}=                       MRBTS-${tl.gnbs[0].dus[0].instance_id}
${gnb_nrbts}=                       NRBTS-${tl.gnbs[0].dus[0].global_bts_id}
${gnb_lnbts}=                       LNBTS-${tl.gnbs[0].dus[0].global_bts_id}

# BTS configuration

${CV180_scf_file_13569}=            testsuite/Paris/TRS/ST/CB013569/SCF_CV180_CB013569_TC_01.xml

# Spirent presets
${spirent_sentinel_addr}=           10.0.117.208
${spirent_sentinel_preset_4G}=      testsuite/Paris/TRS/ST/CB013569/Settings-AWHKB-4G.preset
${spirent_sentinel_preset_5G}=      testsuite/Paris/TRS/ST/CB013569/Settings-AWHKB-5G.preset
