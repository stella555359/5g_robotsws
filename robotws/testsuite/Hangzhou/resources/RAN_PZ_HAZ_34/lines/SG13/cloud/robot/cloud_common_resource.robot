*** Settings ***
Documentation


Library     ../../python/tak_files/
Library     ../python/testline.py      WITH NAME    testline
Library     ../../python/tak_qc/tak_qc/qc_info_parser.py
Library     ../../python/tak_log/

*** Variables ***
${PC_HOST}                   ${tl.test_pc.default_ssh_connection_details.addr}
${PC_USER}                   ${tl.test_pc.default_ssh_connection_details.username}
${PC_PASSWORD}               ${tl.test_pc.default_ssh_connection_details.password}
