*** Settings ***
Documentation    This is for variables in CB010413 CB008985 feature.

*** Variables ***
${testline_name}    7_5_UTE5G401T2116      # WA: dummy value for ${testline_name}, only for pipeline use.
${GNB_INDEX}    ${0}
${VDU_INDEX}    ${0}
${CU_CONNECTION}    OAM_CU${GNB_INDEX}
${DU_CONNECTION}    OAM_gnb${GNB_INDEX}_du${VDU_INDEX}
${PROGRAM}    master

${CU_SCF_TEMPLATE_PATH}     /home/ute/Projects/mmw1_config/${testline_name}/GNB_SCF_CU_MMW1_TL${tl.gnbs[0].cu.instance_id}.xml
${DU_SCF_TEMPLATE_PATH}     /home/ute/Projects/mmw1_config/${testline_name}/GNB_SCF_DU_MMW1_TL${tl.gnbs[0].dus[0].instance_id}.xml
@{LIST_DU_SCF_FILE_PATH}     ${DU_SCF_TEMPLATE_PATH}

${IS_LOG_CAPTURED_CASE_LEVEL}                       ${True}
${IS_LOG_CAPTURED_WHEN_CHECK_TPUT_FAILED}           ${TRUE}    # For debug tput issue

${TIMER_FOR_MODIFY_VIA_API}    5min

${DL_TPUT_IPERF}         1600M
${UL_TPUT_IPERF}         200M
${DURATION_OF_TRAFFIC}    3600
${DURATION_OF_TPUT_CHECK}    60s
${TPUT_AVG_PERCENT_COMMON}    0.7
${TPUT_MIN_PERCENT_COMMON}    0.5

