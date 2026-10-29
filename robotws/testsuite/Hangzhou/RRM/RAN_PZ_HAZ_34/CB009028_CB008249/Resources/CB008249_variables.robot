*** Settings ***
Documentation    This is about common variables used for CB008249 feature.

*** Variables ***
${testline_name}    7_5_UTE5G402T420
${NSA_SA}          SA
${DL_TPUT}         1500M
${UL_TPUT}         300M

${VICTIM_MRBTS_ID}        ${tl.gnbs[0].instance_id}
${SCF_DEFAULT_FILE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${VICTIM_MRBTS_ID}.xml
${SWCONFIG_DEFAULT_FILE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${VICTIM_MRBTS_ID}.txt

${AGGRESSOR_MRBTS_ID}        ${tl.gnbs[1].instance_id}
${AGGRESSOR_GNB_SWCONFIG_DEFAULT_FILE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${AGGRESSOR_MRBTS_ID}.txt
${AGGRESSOR_GNB_SCF_DEFAULT_FILE_PATH}    /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${AGGRESSOR_MRBTS_ID}.xml

${AGGRESSOR_GNB_OAM_ALIAS}    GNB_OAM_AGGRESSOR
${AGGRESSOR_GNB_ASIK_ALIAS}    GNB_ASIK_AGGRESSOR
