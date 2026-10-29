# @Time    : 2022/1/24 15:58
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : common_variables.robot
# @Software: PyCharm
*** Settings ***
Documentation    Define some common variables

*** Variables ***
# RNC info
${RNC_INDEX}    ${0}
${RNC_ID}   ${tl.rncs[${RNC_INDEX}].rnc_id}
${RNC_IP}   ${tl.rncs[${RNC_INDEX}].logging_ssh_connection_details.addr}
${RNC_USER}   ${tl.rncs[${RNC_INDEX}].logging_ssh_connection_details.username}
${RNC_PASSWD}   ${tl.rncs[${RNC_INDEX}].logging_ssh_connection_details.password}

# GOMS info
${GOMS_IP}   ${tl.rncs[${RNC_INDEX}].oms_ip}
