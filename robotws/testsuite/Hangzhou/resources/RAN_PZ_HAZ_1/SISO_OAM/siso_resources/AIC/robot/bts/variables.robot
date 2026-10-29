*** Settings ***
Documentation     resource file


*** Variables ***
${CURRENT_CONFIG_ID}
${TESTED_CONFIG_ID}
@{CU_ALLOWED_FAULT}    Failure in connection between BTS and 3rd party tool
...                    BTS Reset Cause
@{VDU_ALLOWED_FAULT}   BTS Reset Cause
@{ADDITIONAL_CU_ALLOWED_ALARMS}
@{ADDITIONAL_VDU_ALLOWED_ALARMS}
${SW_BUILDS_DIR_PATH}        /home/ute/Downloads/
${PC_HOST}                   ${tl.test_pc.default_ssh_connection_details.addr}
${PC_USER}                   ${tl.test_pc.default_ssh_connection_details.username}
${PC_PASSWORD}               ${tl.test_pc.default_ssh_connection_details.password}
