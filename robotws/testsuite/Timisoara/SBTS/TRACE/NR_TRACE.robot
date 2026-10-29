*** Settings ***
Documentation    NR trace keywords
Library    taf.sw.dcap.rd

*** Variables ***
${tce_ipv4}    10.21.41.148
${tce_ipv6}    2a00:8a00:8000:10c:1:d:0:402
${tce_ip}    2a00:8a00:8000:10c:1:d:0:402
${lnbts_id}    5050
${tce_utf_user_name}    utfuser
${tce_utf_pwd}    utfadmin!

*** Keywords ***
Enable NR Tracing Falgs
    [Documentation]    Enable below flags:
    Log    TBD
