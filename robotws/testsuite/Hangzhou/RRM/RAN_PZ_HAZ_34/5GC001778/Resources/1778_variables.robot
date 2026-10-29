*** Settings ***
Documentation    Common variables for 1778 feature
...   author: Ren Biyao
...   contact: biyao.ren@nokia-sbell.com
...   squad group: MMW_SG1

*** Variables ***
${MRBTS_ID}                          ${tl.gnbs[0].instance_id}
${SCF_DEFAULT_FILE_PATH_DU}         /home/ute/Projects/mmw1_config/${testline_name}/scf/GNB_SCF_DU_MMW1_TL${MRBTS_ID}.xml
${SWCONFIG_DEFAULT_FILE_PATH}       /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${MRBTS_ID}.txt
${NRTRACER_PATH}                    /sharedvolume/ntracer/_data/
${MRBTS_ID}                          ${tl.gnbs[0].instance_id}
${NRBTS_ID}                          ${tl.gnbs[0].global_bts_id}
${CU_DELTA_PLAN}                     delta-plan
