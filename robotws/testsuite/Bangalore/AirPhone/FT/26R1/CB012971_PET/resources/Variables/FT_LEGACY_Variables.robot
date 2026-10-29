*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to Multiple UE SA  only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,28.03.2026,vadivelan.manickavasagam@nokia.com

*** Variables ***
${Log_Path}                        ${OUTPUT_DIR}
${TC_DIR_FT_LEGACY}                ${OUTPUT_DIR}/FT_LEGACY/

${FT_LEGACY_PET_B_CFG_DIR}         ${CURDIR}/../../config/wts/PET_CFG_B
${ROUTE_10_0_1_61_M24}     10.0.1.61/24
${DEV_ETH3}     eth3
${CFG_FT_LEGACY_IPHY}              ${CURDIR}/../../config/ap/FT_LEGACY_IPHY.xml
${CFG_FT_LEGACY_GNB_SCF}           ${CURDIR}/../../FT_LEGACY/config/SBTS26R1/FT_LEGACY_SCF.xml
${CFG_BSR_FILE_AVQL}               ${CURDIR}/../../config/gnb/BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip
${CFG_SANSA_LUA}                   sansa.lua
${CFG_PET_CB012971__SCRIPT_SA_4UE}    CB012971_8235_PET_1116_0ms_MUMIMO_SRSBF_4UEs_6200_DL()

${MCSHARK_PLUGIN}                  /home/ute/wireshark/plugins
${VAL_PET_SCRIPT_COMPLETE}         CB012971_8235_PET_1116_0ms_MUMIMO_SRSBF_4UEs_6200_DL script completed

${CB012971_CQI4_PROFILE5_CMD}            csi_override_testmode_nr profile_id=5 cqi_mode=fixed cqi=4
                                         ...     ri_mode=fixed ri=3 pmi_mode=fixed pmi=1

${VAL_UL_SB_SRS_ENABLED}           ulCellUeSetupReq.payload().dlSubbandBeamforming().dlSubbandBfAct() 1
${VAL_UL_SB_SRS_SIZE_2}              dlSubbandBeamforming().bfSubbandSize() 2


${CM_UE_1_DL_STATS}                ue_stats_nr id=1 type=pdsch
${CM_UE_2_DL_STATS}                ue_stats_nr id=2 type=pdsch
${CM_UE_3_DL_STATS}                ue_stats_nr id=3 type=pdsch
${CM_UE_4_DL_STATS}                ue_stats_nr id=4 type=pdsch
${CM_UE_5_DL_STATS}                ue_stats_nr id=5 type=pdsch
${CM_UE_6_DL_STATS}                ue_stats_nr id=6 type=pdsch
${CM_UE_7_DL_STATS}                ue_stats_nr id=7 type=pdsch
${CM_UE_8_DL_STATS}                ue_stats_nr id=8 type=pdsch

${CM_UE_1_UL_STATS}                   ue_stats_nr id=1 type=pusch
${CM_UE_2_UL_STATS}                   ue_stats_nr id=2 type=pusch
${CM_UE_3_UL_STATS}                   ue_stats_nr id=3 type=pusch
${CM_UE_4_UL_STATS}                   ue_stats_nr id=4 type=pusch
${CM_UE_5_UL_STATS}                   ue_stats_nr id=5 type=pusch
${CM_UE_6_UL_STATS}                   ue_stats_nr id=6 type=pusch
${CM_UE_7_UL_STATS}                   ue_stats_nr id=7 type=pusch
${CM_UE_8_UL_STATS}                   ue_stats_nr id=8 type=pusch
${CM_UE_9_UL_STATS}                   ue_stats_nr id=9 type=pusch
${CM_UE_10_UL_STATS}                  ue_stats_nr id=10 type=pusch


