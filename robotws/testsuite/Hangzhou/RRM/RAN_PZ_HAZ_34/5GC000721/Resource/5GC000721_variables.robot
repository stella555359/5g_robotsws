
*** Settings ***
Documentation    Common variables for 721 feature

*** Variables ***

${SCF_DEFAULT_FILE_PATH_721}          ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_709_721.xml
${SCF_DEFAULT_FILE_PATH_721_common_load}          ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00_721.xml
${dl_cell}                        1,2
${ul_cell}                        1,2
${expected_dl_tput_max}           1200
${expected_dl_tput_min}           0
${expected_ul_tput}               0
${CC_num}                         1
${ul_num_exp}                     1
${SWCONFIG_DEFAULT_FILE_PATH_709}     /opt/ute/swconfig/swconfig_MMW1_TL709.txt
${RECOVERY_TIMEOUT}            300
