*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB008004: New SFN0 offset management


*** Variables ***
# Domain ID for eCPRI PTP
${new_ptp_domain_id}=               34

# OAM 5GNB IP and IDs (or PCELL ENB for CA LTE inter ENB confs)
${bts_addr}=                        ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${gnb_mrbts}=                       MRBTS-${tl.gnbs[1].dus[0].instance_id}
${gnb_nrbts}=                       NRBTS-${tl.gnbs[1].dus[0].global_bts_id}
${gnb_lnbts}=                       LNBTS-${tl.gnbs[1].dus[0].global_bts_id}

${bts_smod_addr}=                   ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${bts_smod_username}=               ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${bts_smod_password}=               ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

# ECPRI AZQO RU SN
${ru_name}=                         AZQO
#${azqo_username}=                   rfsw
#${azqo_password}=                   5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
${azqo_username}=                   serviceuser
${azqo_password}=                   wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=

# SCF files

${scf_file_8004_a_tc_05}=           testsuite/Paris/TRS/ST/CB008004/SCF_CV31_2ASIL_CB008004_A.xml
${scf_file_8004_ce_tc_06}=          testsuite/Paris/TRS/ST/CB008004/SCF_CV31_2ASIL_CB008004_A.xml
${scf_file_8004_cd_tc_02}=          testsuite/Paris/TRS/ST/CB008004/SCF_CV31_2ASIL_CB008004_A.xml
${scf_file_8004_cc_tc_02}=          testsuite/Paris/TRS/ST/CB008004/SCF_CV31_2ASIL_CB008004_A.xml
${scf_file_8004_cc_tc_02_23R4}=     testsuite/Paris/TRS/ST/CB008004/SCF_CV31_CB008004_23R4.xml
${scf_file_9055_tc_06}=             testsuite/Paris/TRS/ST/CB008004/SCF_CV31_AZQO_CB008004.xml

# CB008004_CC configuration
${UE_ALIAS_1}=                      UE_1
${CAPABILITIES}=                    REAL_UE
${UL_THROUGHPUT}=                   25 Mbits/sec
${UL_MIN_THROUGHPUT}=               15000
${DL_THROUGHPUT}=                   100 Mbits/sec
${DL_MIN_THROUGHPUT}=               66000
${DURATION}=                        30s
${PROTOCOL}=                        udp
${PACKET}=                          1000B
${DL_PORT}=                         34018
${UL_PORT}=                         34019

# CB008004_CE configuration
${CE_TDDCELL_1}=                    NRCELL-108
${CE_TDDCELL_2}=                    NRCELL-109
${CE_framestartoffset_1}=           5000
${CE_sfnoffset_1}=                  -900
${CE_sfnoffset_2}=                  2500

# CB009055 configuration
${ABIP_TDDCELL_1}=                  NRCELL-108
${ABIP_TDDCELL_2}=                  NRCELL-109
${ABIP_framestartoffset_1}=         5000
${ABIP_sfnoffset_1}=                -900
${ABIP_sfnoffset_2}=                2500

# CB008004_CD configuration
${CD_5GCELL_1}=                     NRCELL-25
${CD_5GCELL_2}=                     NRCELL-26
${CD_4GCELL_1}=                     LNCEL-66
${CD_4GCELL_2}=                     LNCEL-67
${CD_framestartoffset_1}=           2000
${CD_framestartoffset_2}=           3100
${CD_framestartoffset_3}=           3200
${CD_sfnoffset_1}=                  4000
${CD_sfnoffset_2}=                  4000

# CB008004_CC_Cconfiguration
${CC_5GCELL}=                       NRCELL-51
${CC_4GCELL}=                       LNCEL-41
${CC_framestartoffset_5G}=          2302.34
${CC_sfnoffset_5G}=                 0
${CC_framestartoffset_4G}=          9302.34
${CC_sfnoffset_4G}=                 -1

# Spirent Sentinel
${spirent_sentinel_addr}=           10.0.117.208
${spirent_sentinel_preset_ce}=      testsuite/Paris/TRS/ST/CB008004/Settings-AZQO_PCI108.preset
${spirent_sentinel_preset_cd}=      testsuite/Paris/TRS/ST/CB008004/Settings-AHFII-LNCELL-66.preset
${spirent_sentinel_preset_abip}=    testsuite/Paris/TRS/ST/CB008004/Settings-AZQO_PCI108.preset

# OAM LTE IP and IDs
${enb_addr}=                        ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${enb_mrbts}=                       MRBTS-${tl.gnbs[0].dus[0].instance_id}
${enb_nrbts}=                       NRBTS-${tl.gnbs[0].dus[0].global_bts_id}
${enb_lnbts}=                       LNBTS-${tl.gnbs[0].dus[0].global_bts_id}
