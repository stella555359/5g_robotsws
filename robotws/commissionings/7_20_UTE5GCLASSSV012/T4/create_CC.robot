*** Settings ***
Documentation    Suite description
# Library    taf.ul.auto_commissioning    WITH NAME    CC

*** Variables ***

${base_scf_addr}=       ${CURDIR}\/base.xml
${custom_scf_addr}=     ${CURDIR}\/custom.xml
${json_addr}=           ${CURDIR}\/result.json

*** Test Cases ***

generate JSON
     Log  INFO:Start generate_json_delta
#    CC.generate_json_delta    ${base_scf_addr}    ${custom_scf_addr}    ${json_addr}
