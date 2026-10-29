*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Keerthi.Chittoor
                 ...              :contact      : keerthi.chittoor@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008453 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,27.10.2025,keerthi.chittoor@nokia.com

*** Variables ***
${Log_Path}                              /home/ute/logs
${TC_DIR_CB008453_B_ITW3}                /home/ute/logs/CB008453_B_ITW3/
${TC_DIR_CB008453_B_ITW7}                /home/ute/logs/CB008453_B_ITW7/
${TC_DIR_CB008453_C_ITW1}                /home/ute/logs/CB008453_C_ITW1/

${FILE}                                  /opt/wts/latest/egate_console.log
${CSV_FILE}                              tdd_blocks.csv

${CFG_CB008453_B_ITW3_SCF}               CFG_CB008453_B_ITW3_SCFC_2_AWEUC_8_cells.xml
${CFG_CB008453_B_ITW7_SCF}               CFG_CB008453_B_ITW7_SCFC_2_AWEUC_8_cells.xml
${CFG_CB008453_C_ITW1_SCF}               CFG_CB008453_C_ITW1_SCFC_2_AWEUC_8_cells.xml

${CFG_CB008453_B_ITW3_WTS}               ${CURDIR}/../../config/wts/CB008453_B_ITW3_wts_212_UEs_NSA.lua
${CFG_CB008235_B_ITW3_IPHY}              ${CURDIR}/../../config/ap/CB008453_B_ITW3_AP_2_AWEUC_8cells.xml

${CFG_CB008235_C_ITW1_IPHY}              ${CURDIR}/../../config/ap/CB008453_C_ITW1_AP_IPHY.xml
${CFG_CB008453_C_ITW1_WTS}               ${CURDIR}/../../config/wts/CB008453_C_ITW1_WTS.lua

