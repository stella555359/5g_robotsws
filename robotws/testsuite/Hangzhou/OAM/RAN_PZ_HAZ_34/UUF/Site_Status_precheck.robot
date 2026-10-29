*** Settings ***
Documentation     author: Xiaofei Li
...               contact: xiaofei.li@nokia-sbell.com
...               Site Status Pre-Check case.
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/upgrade_rollback.robot
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Scripts/gnb_handler.py
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/UUF_vars.py

Force Tags    SG_08    CA_5G_OAM    AUTHOR_xiaofei.li@nokia-sbell.com
...    PY36

*** Variables ***
${Source_Package}

*** Test Cases ***
Site Status Pre-Check
     [Setup]   log to console   Check Site Status
     run keyword and continue on failure   Validate Config by WebEM
     run keyword and continue on failure   Coam Check Site Status
     ${bts_id}   convert to string   ${MRBTS_ID}
     ${L3callBTS_status}   run keyword and return status   Dictionary Should Contain Key   ${BTS_L3call}   ${bts_id}
     run keyword and continue on failure   run keyword if   ${L3callBTS_status}   UUF_common.reboot_ue_pc   ${ue_pcs}
     ...   ELSE   log to console   no ue






