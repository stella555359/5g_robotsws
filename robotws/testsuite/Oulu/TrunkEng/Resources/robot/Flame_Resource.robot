*** Settings ***
Documentation       Suite description
Library             ../python/FlameResults.py
Library             ../python/InstallFlame.py
Library             Process
Library             OperatingSystem

*** Variables ***
${STDOUT_FILE}          ${OUTPUT_DIR}${/}stdout.txt

*** Keywords ***
Run Flame Script
    [Arguments]   ${path_to_fws}  ${tags}=${EMPTY}
    run keyword and ignore error  Run Process  sudo  iptables  -I  INPUT  4  -i  eth0  -p  tcp  --dport  13062  -j  ACCEPT
    Install flame
    Get File from Robotfiles Repository  ${path_to_fws}
    ${result}=  Run Process  flame5  --ute-cloud  --tags\=${tags}  -w  /home/ute/test.fws  -l  ${OUTPUT_DIR}  stdout=${STDOUT_FILE}
    run keyword and ignore error  Run Process  sudo  iptables  -D  INPUT  4
    Return Results  ${result}  ${OUTPUT_DIR}


Get File from Robotfiles Repository
    [Arguments]  ${path_to_fws}
    Run  svn export --force --username ca_ute_test --password utetest ${path_to_fws} /home/ute/test.fws
    File Should Exist  /home/ute/test.fws
