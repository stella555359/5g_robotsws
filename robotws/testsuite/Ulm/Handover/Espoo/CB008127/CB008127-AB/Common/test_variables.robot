*** Settings ***

Documentation   test_variables

*** Variables ***

#${EPCSIM_CFG_PATH}           ${CURDIR}/cfg/nsa_tdd_cmWv_fs/wts/egate_1c_1g_endc.lua
#${EPCSIM_CFG_PATH}           ${CURDIR}/cfg/nsa_tdd_cmWv_l1bp/wts/wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_NSA_L1b.cfg
${UE_ID}                     1
${GNB_ID}                    2
${CELL_ID}                   2
${DURATION}                  10s
${ICS_SETUP_RESP_SUCCESS}    ngap.procedureCode == 14 && ngap.NGAP_PDU == 1
${SGNB_RECONFIG_COMPLETE}    x2ap.procedureCode == 28 && x2ap.ResponseInformationSgNBReconfComp == 0
${RESET_TL}                  ${FALSE}
${DEFAULT_S1_MME_ALIAS}      default_s1_x2
@{ACCEPTED_BTS_STATES}       Configured    IntegratedToRan
