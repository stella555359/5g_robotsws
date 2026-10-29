*** Settings ***
Documentation     author: Yang Di
...               contact: di.yang@nokia-sbell.com
...               Description:

*** Variables ***
${CONFIG_PATH}                         ${CURDIR}/config/sansa_tdd_cmWv
${EPCSIM_CFG_PATH_SANSA_TDD}           ${CURDIR}/config/sansa_tdd_cmWv/basic_setup.lua
${SBTS00_SCF_PATH}                     ${CURDIR}/config/sansa_tdd_cmWv/SCF_SBTS00.xml
${EPCSIM_CFG_PATH_SANSA_TDD_026_D}     ${CURDIR}/config/sansa_tdd_cmWv/D_case_26.lua
${026_D_SCF_PATH}                      ${CURDIR}/config/sansa_tdd_cmWv/026_D_Configuration_scf.xml
${EPCSIM_CFG_PATH_SANSA_TDD_010_A}     ${CURDIR}/config/sansa_tdd_cmWv/A_case_10.lua
${010_A_SCF_PATH}                      ${CURDIR}/config/sansa_tdd_cmWv/010_A_Configuration_scf.xml
${010_A_4C_SCF_PATH}                   ${CURDIR}/config/sansa_tdd_cmWv/010_A_4C_Configuration_scf.xml
${004_A_SCF_PATH}                      ${CURDIR}/config/sansa_tdd_cmWv/004_A_Configuration_scf.xml
${015_A_SCF_PATH}                      ${CURDIR}/config/sansa_tdd_cmWv/015_A_Configuration_scf.xml
${022_A_SCF_PATH}                      ${CURDIR}/config/sansa_tdd_cmWv/022_A_Configuration_scf.xml
${019_A_SCF_PATH}                      ${CURDIR}/config/sansa_tdd_cmWv/019_A_Configuration_scf.xml
${DELTA_FILES_PATH}                    ${CURDIR}/config/delta_files

${RESET_TL}                  ${FALSE}

@{ACCEPTED_BTS_STATES}       Configured    IntegratedToRan    OnAir

${NOKIA_PASS}                oZPS0POrRieRtu
${GNB_IP}                    192.168.255.1
${AP_IP}                     192.168.200.1

${ERadCcs_AaSysLogOutputLevel}    0x10040
${ERadCcs_AaSysLogInputLevel}     0x1003F
${ERadCcs_AaSysLogOutputMode}     0x10041

${DEBUG_LOG_LEVEL}  2

${COUNTER_AVE_NUMBER_OF_NSA_USERS_PMQAP}     M55160C00001
${COUNTER_AVE_NUM_NSA_USERS_DENOM_PMQAP}     M55160C00002
${COUNTER_PEAK_NUMBER_OF_NSA_USERS_PMQAP}    M55160C00003

${COUNTER_AVE_NUMBER_OF_SA_RRC_PMQAP}        M55161C00001
${COUNTER_AVE_NUMB_OF_SA_RRC_DENOM_PMQAP}    M55161C00002
${COUNTER_PEAK_NUMB_OF_SA_RRC_USER_PMQAP}    M55161C00003

${COUNTER_UL_PDCP_SDU_CU_PMQAP}              M55352C02001
${COUNTER_UL_PDCP_SDU_VOL_SNT_PMQAP}         M55352C02006
${COUNTER_DL_PDCP_SDU_USDAT_CU_PMQAP}        M55352C02003
${COUNTER_DL_PDCP_SDU_VOL_RCV_PMQAP}         M55352C02005

${COUNTER_DL_PDCP_SDU_DLY_CUUP_PMQAP}        M55159C00001
${COUNTER_UL_PDCP_SDU_DLY_CUUP_PMQAP}        M55159C00005

${COUNTER_MEAS_PERIOD_NR_PDCP_SLICE}         M55328C00001
${COUNTER_PDCP_SDU_DATA_NUM_DL_SLICE}        M55328C00002
${COUNTER_PDCP_SDU_DATA_VOL_DL_SLICE}        M55328C00003
${COUNTER_PDCP_SDU_DATA_NUM_UL_SLICE}        M55328C00004
${COUNTER_PDCP_SDU_DATA_VOL_UL_SLICE}        M55328C00005
${COUNTER_PDCP_SDU_DELAY_DL_SLICE}           M55328C00006
${COUNTER_PDCP_SDU_DELAY_UL_SLICE}           M55328C00007

${ENB_PATH}  MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}

${COUNTER_DL_PRB_USED_DATA_NRG}              M55910C00001
${COUNTER_DL_PRB_UTIL_SLOT_MAX_NRG}          M55910C00002

${COUNTER_PRB_AVAIL_PDSCH_NSA_PLMN}          M55338C01000
${COUNTER_PRB_USED_PDSCH_NSA_PLMN}           M55338C01001
${COUNTER_PRB_PDSCH_UTIL_RATIO_PLMN_MAX}     M55338C01002

${COUNTER_PRB_AVAIL_PDSCH_SLICES}            M55308C10007
${COUNTER_DL_PRB_AVAIL_SAS}                  M55308C10013

${COUNTER_DL_PRB_USED_DATA_PMQAP}            M55363C00001
${COUNTER_DL_PRB_UTIL_SLOT_MAX_PMQAP}        M55363C00003

&{fault_4459}     faultId=${4459}
&{fault_4655}     faultId=${4655}
&{fault_4654}     faultId=${4654}
&{fault_61652}    faultId=${61652}
&{fault_61524}    faultId=${61524}
&{fault_6502}     faultId=${6502}
&{fault_7523}     faultId=${7523}
&{fault_7100}     faultId=${7100}
@{ALLOWED_FAULT}    &{fault_4459}   &{fault_4655}   &{fault_4654}   &{fault_61652}   &{fault_61524}   &{fault_6502}
...               &{fault_7523}   &{fault_7100}

${WEBUI_ADDR}          ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}          ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}

@{PARAMS_IN_SWCONFIG}  ${EMPTY}

