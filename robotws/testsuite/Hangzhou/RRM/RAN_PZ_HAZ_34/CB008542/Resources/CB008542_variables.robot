*** Settings ***
Documentation    This is about common variables used for 8542 feature.

*** Variables ***
# WA: dummy value for ${testline_name}, only for pipeline use.
${testline_name}    7_5_UTE5G402T248
${CA_GROUP_TYPE}    T+F
${IS_LOG_CAPTURED_CASE_LEVEL}    ${True}

${NSA_SA}    NSA

${ENB_ID}                             ${tl.enbs[0].instance_id}
${ENB_SCF_DEFAULT_FILE_PATH}          /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${ENB_ID}_ENB.xml

@{carrierAggregationSupportList_With_T_F}     ca_Fr1Tdd_Fdd_Nsa    ca_Fdd_Fr1Tdd_Nsa
@{carrierAggregationSupportList_without_T_F}    ca_Fdd_Fr1Tdd_Nsa
${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}  75
${A2_THRESHOLD_SCELL_REL_SSB_RSRP}  70

${A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP}    71
${A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP}    60

${PA_A1_BASED_PCELL_SWTICH}    ${0}
${PA_A2_BASED_PCELL_SWTICH}    ${35}

${PCELL_TDD_DL_TRAFFIC_SMALL}  100

${PCELL_EXP_DL}    1400
${PCELL_EXP_UL}    60
${SCELL_EXP_DL}    190
${SCELL_EXP_UL}    60
${DL_TPUT}         1800M
${UL_TPUT}         250M

${ENB_Cellid_10359}   4
${ENB_Cellid_255}   1
${ENB_Cellid_10152}   4
${ENB_Cellid_1170}    1
