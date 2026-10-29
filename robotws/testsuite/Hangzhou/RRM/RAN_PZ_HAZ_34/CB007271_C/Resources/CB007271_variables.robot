*** Settings ***
Documentation    This is about common variables used for CB007271 feature.

*** Variables ***
${testline_name}    7_5_UTE5G402T406
${NSA_SA}          SA
${DL_TPUT}         420M
${UL_TPUT}         100M

${ENB_SCF_DEFAULT_FILE_PATH}         /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.enbs[0].instance_id}_ENB.xml
