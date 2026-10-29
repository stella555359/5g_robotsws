*** Settings ***
Documentation    :copyright    : Nokia
                 ...              :author       : Sharanya
                 ...              :contact      :
                 ...              :Description  : This file contains sos report utility keywords
                 ...                              Any changes review needed before commit


Library        ute_wtssim
Library        ta5g_commissioning
Library        taf.sbts.oam.coam.admin      WITH NAME    admin
Variables      ../PythonLib/UTILS.py
Library        CSV_validation_and_check1.py

*** Variables ***
${WTS_WORKING_DIR}             /opt/wts/latest
${sos_script_path}             /opt/wts/latest
${stop_asil_script}            ./stopTest.sh
*** Keywords ***
Collect Logs For The Test
    [Arguments]     ${Log_Path}
    Run           ${WTS_WORKING_DIR}/sosReport.sh -nr -c -s
    sleep         540s
    Run           cp Sos*.tgz ${Log_Path}
    Run           ls ${Log_Path}/SosReport*.tgz

Start SOS with BIP
    [Arguments]    ${sos_script_path}
    ${result}    Run Process    ${sos_script_path}/startTest.sh   shell=True   stdout=PIPE    stderr=PIPE
    sleep        60s
    log to console    \n${result} you may start the case

Stop and collect SOS
   [Arguments]    ${sos_script_path}    ${Log_Path}
   ${command}    Catenate    cd ${sos_script_path} && ./${stop_asil_script}
   Run     command=${command}
   Run     mv /opt/wts/latest/Sos*.tgz ${log_path}
   Run     cd -

