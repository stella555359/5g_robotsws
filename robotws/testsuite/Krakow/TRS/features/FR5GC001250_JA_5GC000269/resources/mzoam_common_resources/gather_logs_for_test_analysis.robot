*** Settings ***
Documentation
...  Author: Filip Hein
...  Contact: filip.hein@nokia.com
...  Alternative contact: trsautowro@groups.nokia.com

Library     OperatingSystem
Library     DateTime

*** Keywords ***

Gather screenshots of failed selenium keywords
    Create directory for logs
    ${our_screenshots_path}=  Set variable  ${logs_path}/screenshots
    Run  mkdir -p ${our_screenshots_path}
    ${sel_mz}=  get library instance  taf.ul.oam.selenium_megazone
    Log to console  ${sel_mz._debug_dir}
    Sleep  3s
    Run  cp -R ${sel_mz._debug_dir}/. ${our_screenshots_path}

Create directory for logs
    ${date}=  DateTime.Get Current Date
    Set Global Variable  ${global_date}  ${date}
    Set Global Variable  ${logs_path}    ${OUTPUT DIR}/TRS_SEC_${date[0:10]}/${date[11:19]}
    log to console  LOGS WILL BE GATHERED TO: ${logs_path}
    Run  mkdir -p ${logs_path}
