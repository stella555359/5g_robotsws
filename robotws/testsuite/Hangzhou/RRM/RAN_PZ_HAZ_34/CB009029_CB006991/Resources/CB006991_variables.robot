*** Settings ***
Documentation    This is about common variables used for CB006991 feature.

*** Variables ***
${testline_name}    7_5_UTE5G402T2135
${NSA_SA}          SA

${VICTIM_MRBTS_ID}        ${tl.gnbs[0].instance_id}
${SCF_DEFAULT_FILE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${VICTIM_MRBTS_ID}.xml
${SWCONFIG_DEFAULT_FILE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${VICTIM_MRBTS_ID}.txt

${AGGRESSOR_MRBTS_ID}        ${tl.gnbs[1].instance_id}
${AGGRESSOR_GNB_SCF_DEFAULT_FILE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${AGGRESSOR_MRBTS_ID}.xml
${AGGRESSOR_GNB_SWCONFIG_DEFAULT_FILE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${AGGRESSOR_MRBTS_ID}.txt

${TCE_IP_ADDR}    10.57.241.82
${TCE_PORT}    49148

# frame_structure_bw: 1116_3MS_4GP_100MHZ, 1116_0MS_6GP_60MHZ, 1208_2gp_40mhz, 1070_2gp_80mhz
${STR_1116_3MS_4GP_100MHZ}    1116_3ms_4gp_100mhz
${STR_1116_0MS_6GP_60MHZ}    1116_0ms_6gp_60mhz
${STR_1208_2GP_40MHZ}    1208_2gp_40mhz
${STR_1070_2GP_80MHZ}    1070_2gp_80mhz
${DEFAULT_RS_DETECTION_DURATION_WO_RI}    ${30}
${MIN_RS_DETECTION_DURATION_WO_RI}    ${10}
