*** Settings ***
Documentation    Common variables

*** Variables ***
${MRBTS_ID}                           ${tl.gnbs[0].instance_id}
${NRBTS_ID}                           ${tl.gnbs[0].global_bts_id}
${SWCONFIG_DEFAULT_FILE_PATH}         /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${MRBTS_ID}.txt
${SCF_DEFAULT_FILE_PATH}              /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${MRBTS_ID}.xml
${ENB_ID}                             ${tl.enbs[0].instance_id}
${NSA_SA}  SA

${LUA_SCRIPT_PATH}        /home/ute/luashark_script/generated_luashark/luashark.lua

${AMIA_LEFT}    ${False}

${TIMER_FOR_MODIFY_VIA_API}    5min
${TIMER_FOR_CELL_ON_AIR}       8min

# Traffic related variables
${WAIT_TIME_FOR_TPUT_STABLE}       30s
${DURATION_OF_DATA_TRANSFER}       600s
${DURATION_OF_TPUT_CHECK}          60s
${DL_TPUT}                         1200M     # DL traffic of PCELL 20M + SCELL 60M
${UL_TPUT}                         100M      # UL traffic of PCELL 20M

${PCELL_EXP_DL}    100
${PCELL_EXP_UL}    50
${SCELL_EXP_DL}    600
${SCELL_EXP_UL}    50

${A2_MEAS_ID}    1
${A1_MEAS_ID}    2
${A3_MEAS_ID}    3
${A5_MEAS_ID}    4

@{GNB_PS_CELL_INDEX_LIST}    ${PCELL_ID}    ${SCELL_ID}


### mobility case related variables
${ADJ_MRBTS_ID}                           ${tl.gnbs[1].instance_id}
#${ADJ_SWCONFIG_DEFAULT_FILE_PATH}         /opt/ute/swconfig/swconfig_MMW1_TL${ADJ_MRBTS_ID}.txt
${ADJ_SWCONFIG_DEFAULT_FILE_PATH}         ${SWCONFIG_DEFAULT_FILE_PATH}
${ADJ_SCF_DEFAULT_FILE_PATH}              /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${ADJ_MRBTS_ID}.xml

${ADJ_GNB_ASIK_ALIAS}                     ADJ_GNB_ASIK
${ADJ_GNB_OAM_ALIAS}                      GNB_OAM_ADJ

${PCELL_RU_INDEX}        ${PCELL_LIST[${CA_GROUP_INDEX}]['ru_index_in_testline_file']}
${SCELL_RU_INDEX}        ${SCELL_LIST[${CA_GROUP_INDEX}]['ru_index_in_testline_file']}
${INIT_PA_VALUE_10152}         0
${A2_MEAS_PA_VALUE_10152}      25
${INIT_PA_VALUE_10153_RU_0}    0
${INIT_PA_VALUE_10153_RU_1}    0

${INIT_PA_VALUE_1170}        0
${A2_MEAS_PA_VALUE_1170}     45
${INIT_PA_VALUE_564_RU_0}    0
${INIT_PA_VALUE_564_RU_1}    0

${INIT_PA_VALUE_255}        10
${A2_MEAS_PA_VALUE_255}     25
${INIT_PA_VALUE_1173_RU_0}    0
${INIT_PA_VALUE_1173_RU_1}    0

# Flag used to define whether snapshot/ bts logs are needed in case teardown
${IS_LOG_CAPTURED_CASE_LEVEL}                       ${True}


# ENB SCF
${ENB_SCF_DEFAULT_FILE_PATH}              /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${ENB_ID}_ENB.xml
