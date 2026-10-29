*** Settings ***
Documentation    Common variables for 7464 feature

*** Variables ***
${SCF_DEFAULT_FILE_PATH}          /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_step2.xml
@{GNB_PS_CELL_INDEX_LIST}        1    2
${UL_THROUGHPUT}    50M
${DL_THROUGHPUT}    100M
