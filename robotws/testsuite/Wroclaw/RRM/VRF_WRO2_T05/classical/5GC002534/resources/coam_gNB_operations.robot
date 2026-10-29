*** Settings ***
Documentation
...     Keywords Purpose:
...         Keywords for SFP  speedAndDuplex test change  cases
...
...     AUTHOR (I&V-2):
...  author: Ismail MOALIGE
...  contact: ismail.moalige@nokia.com

Library     taf.sbts.oam.coam.admin              WITH NAME    coam
Library     XML   use_lxml=True
Library     String
Library     OperatingSystem
Library     SSHLibrary  timeout=60 minutes
Library     Collections
Library     taf.transport.ssh       WITH NAME   ssh
Resource     ${CURDIR}/coam_connections.robot
Library      ${CURDIR}/coam_gNB_operations.py


*** Variables ***
${bts_addr}=  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#${ASIK_IP}=                     10.193.1.31
#${ASIK_IP}=                     192.168.255.3
#${LMP_IP}=                      192.168.255.3
${MAX_TIME_RESTE}=              2400

${ASIK_USERNAME}=               toor4nsn
${ASIK_PASSWORD}=               oZPS0POrRieRtu
${WEBEM_USERNAME}=              Nemuadmin
${WEBEM_PASSWORD}=              nemuuser
@{emptyT}=
${scf_file}=                    ./current_scf.xml
${scf_bck_file}=                    ./current_bck_scf.xml

*** Keywords ***

Change Param On GNB
    [Arguments]    ${dist_name}      ${param_name}    ${param_value}   ${connection}    ${skip_parameter_relation_errors}=True
    ${result}=  change_parameter_on_gNB  dist_name=${dist_name}
    ...                      param_name=${param_name}
    ...                      param_value=${param_value}
    ...                      skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                      connection=${connection}
    [return]  ${result}

Check gNB is ready
    wait until keyword succeeds     ${MAX_TIME_RESTE}       15s     Check gNB State

Check gNB State
    ${gNB_connection}=  connect to admin
    ${gNB_status}=                  check_gNB_Ready                    connection=${gNB_connection}
    Should Be True              ${gNB_status}
    Run Keyword If  ${gNB_status}   Log To Console   \n gNB is ready now
    [Teardown]                      Teardown connection                 ${gNB_connection}