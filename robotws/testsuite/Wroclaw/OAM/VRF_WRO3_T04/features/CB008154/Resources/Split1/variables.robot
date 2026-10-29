*** Settings ***
Documentation
...     description:    Variables for test cases for the CB008154 feature.

*** Variables ***
${bts_id}                       ${BTS_ID}
${cmp_default}                  CN=Nokia_8154_default
${cmp_1}                        CN=Nokia_8154
${cmp_2}                        CN=Nokia_8154_2
${FIRST_CERT_FILE_P12_HEX}=     ${CURDIR}/8154_First.txt
${SECOND_CERT_FILE_P12_HEX}=    ${CURDIR}/8154_Second.txt
${THIRD_CERT_FILE_P12_HEX}=     ${CURDIR}/8154_Third.txt
${FIRST_CERT_P12}               trust_chain_first.p12
${SECOND_CERT_P12}              trust_chain_second.p12
${THIRD_CERT_P12}               trust_chain_third.p12
${CERT_P12_PASSWORD}            YT_xk39b
