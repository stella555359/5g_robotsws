*** Settings ***
Documentation    Common variables for 2546-B feature

*** Variables ***
##x2log
${luashark_path}         /home/ute/generated_luashark/luashark.lua
${LUA_SCRIPT_PATH}       /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${X2AP_COMMAND}       {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
${E1AP_COMMAND}       {tshark_path} -r {pcap_file} -Y  \"e1ap\"  -T pdml
${S1AP_COMMAND}       {tshark_path} -r {pcap_file} -Y  \"s1ap\"  -T pdml

${TSHARK_PATH}           /usr/bin/tshark
${GNB_COAM_ALIAS}         GNB_OAM



${SCELL_RU_INDEX_10152}      ${0}
${SCELL_RU_INDEX_1170}        ${0}
${SCELL_RU_INDEX_255}        ${0}
${SCELL_RU_INDEX_248}        ${0}
@{SCELL_BAD_10152}      50  50  50  50
@{SCELL_GOOD_10152}      0  0  0  0
@{SCELL_BAD_1170}     50  50  50  50
@{SCELL_GOOD_1170}      0  0  0  0
@{SCELL_BAD_255}      50  50  50  50
@{SCELL_GOOD_255}      0  0  0  0

@{SCELL_BAD_248}      50  50  50  50
@{SCELL_GOOD_248}      0  0  0  0
