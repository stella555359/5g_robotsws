# @Time    : 2022/1/24 15:58
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : common_variables.robot
# @Software: PyCharm
*** Settings ***
Documentation    Define some common variables

*** Variables ***
${TS_LOG_PATH_BASE}     /home/ute/MMW_SG5
${TS_LOG_PATH_CLOUD}    /home/ute/test_results
${TS_CASE_LOG_PATH}     /home/ute/MMW_SG5

${GENERAL_SISO_CASES_PATH}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso

# Global wireshark log path
${BIP_FILE_PATH}                ${TS_CASE_LOG_PATH}/l1l2bip
${REMOTE_PCAP_PATH}             /tmp/tmp.pcap
${REMOTE_PCAP_PATH_SEC}             /tmp/tmp_sec.pcap
${TSHARK_PATH}                  /usr/bin/tshark
${LUASHARK_PATH}                /home/ute/luashark/generated_luashark/luashark.lua
${PDML_CONVERT_X2AP_TEMPLATE}   {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml

# GNB info
${GNB_INDEX}    ${0}
${MRBTS_ID}   ${tl.gnbs[${GNB_INDEX}].instance_id}
${NRBTS_ID}   ${tl.gnbs[${GNB_INDEX}].global_bts_id}
${GLOBAL_CELL_ID}   ${1}

# ENB info
${ENB_INDEX}    ${0}
${ENB_MRBTS_ID}     ${tl.enbs[${ENB_INDEX}].instance_id}
${ENB_LNBTS_ID}     ${tl.enbs[${ENB_INDEX}].global_bts_id}
${GLOBAL_LNCELL_ID}   ${1}

${ENB_INDEX2}    ${1}
${ENB_MRBTS_ID2}     ${tl.enbs[${ENB_INDEX2}].instance_id}
${ENB_LNBTS_ID2}     ${tl.enbs[${ENB_INDEX2}].global_bts_id}
${GLOBAL_LNCELL_ID2}   ${1}
