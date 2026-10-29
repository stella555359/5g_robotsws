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
${CFG_FT_LEGACY_SCRIPT_SA_16UE}    FT_PET_LEGACY_SA_CALL_16UEs_6200_DL()

${MCSHARK_PLUGIN}                  /home/ute/wireshark/plugins
${VAL_PET_SCRIPT_COMPLETE}         PET_FT_LEGACY script completed

${CB012971_CQI4_PROFILE5_CMD}            csi_override_testmode_nr profile_id=5 cqi_mode=fixed cqi=4
                                         ...     ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
