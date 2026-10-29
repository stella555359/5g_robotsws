*** Settings ***
Force Tags    PY36
Documentation     author: Ruiyu Han
...               contact: ruiyu.han@nokia-sbell.com
...               Upgrade and Rollback UUF case.
Library     OperatingSystem
Library    String
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot

*** Variables ***
${scf_link}    git@gitlabe1.ext.net.nokia.com:SG8/golden_scf.git
${tl_name}    TL${MRBTS_ID}
${swconfig}    false
${stand_alone}   NSA

*** Test Cases ***
Perform SCF in Advance
    [Setup]    SCF Case Setup
    Run Keyword If   ${${swconfig}} and '${swconfig_path}'!='false'   Install Swconfig File    swconfig_path=${swconfig_path}
    ...    ELSE    LOG    swconfig wouldn't install!    WARN
#    run keyword    ${webui_scf} Perform SCF Commission    filepath=${scf_path}
    gNB_import_SCF_on_COAM   ${LMP_ADDR}    ${scf_path}
    run keyword if   ${webui_scf.count('Megazone')}>0    wait until keyword succeeds    5 min    5 s    Wait for Site Unavailability
    [Teardown]    SCF Case Teardown

X2enb Rollback
    run keyword if   '${ENBs[0]['addr']}' != '1.1.1.1'    rollback x2enb to lower build


*** Keywords ***
SCF Case Setup
    run keyword if  not ${${DEBUG}}   selenium_netact.enable_virtual_display
    Check running nms mode
    Check and Set SCF Webui
    ${ori_release}   Catch build release   ${origin_version}
    ${NE_release}   Convert To Lowercase   ${ori_release}
    ${stand_type}   Convert To Lowercase   ${stand_alone}
    ${NetAct_name}   Convert To Lowercase   ${netact_global_configuration['${netact_nodeip}']['name']}
    ${scf}   set variable  gnb_scf_${NE_release}_${stand_type}_${NetAct_name}.xml
    ${status}   Run Keyword And Return Status   Fetch SCF from Git   ${scf}
    set suite variable     ${scf_status}    ${status}
    Run keyword if   '${status}'=='False'  FAIL 
    Get SCF Param    SCF_path=${scf_path}
    Fetch Swconfig IF Exist
    Set gNB SW version and Release
    Switch to source build
    run keyword    Check Cell Setup in ${webui_scf}

SCF Case Teardown
    run keyword if   '${scf_status}'=='True'    Check Cell Setup in ${webui_scf}
    run keyword if  not ${${DEBUG}}   selenium_netact.disable_virtual_display

Check and Set SCF Webui
#    ${version_release}    ${rest}    Split String From Right    ${origin_version}    .    1
    ${version_release}   Catch build release   ${origin_version}
    set suite variable     ${webui_scf}    COAM


Get Current SW version
   ${active}  ${passive}   Get gNB SW version
#   ${version_release}    ${rest}    Split String From Right    ${active}    .    1
   ${version_release}   Catch build release   ${active}
   ${webui}    set variable    COAM
   [Return]    ${webui}


Fetch SCF from Git
    [Arguments]  ${scf}
    log to console    Fetch SCF from Git
    Run    sudo rm -rf /home/ute/scf/
    Sleep    10s
    Run    sudo rm -f /home/ute/output*.log
    Log    \nStart to Download SCF From GIT!    WARN
    ${output}    Run   git clone ${scf_link} /home/ute/scf --progress --verbose
    Wait Until Git Clone Process Done    output=${output}
    Log To Console    Download SCF Finished!
    ${output}    Run    ls /home/ute/scf/${tl_name}/${webui_scf}/
    run keyword if   ${output.count('${scf}')}>0
    ...    Set Suite Variable   ${scf_path}   /home/ute/scf/${tl_name}/${webui_scf}/${scf}
    ...    ELSE    FAIL    [ERROR] SCF doesn't exist in gitlab!

Install Swconfig File
    [Arguments]    ${swconfig_path}
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.Upload File    local_path=${swconfig_path}    remote_path=/rom/swconfig.txt    connection=gnb
    csn.execute    crasign /rom/swconfig.txt    connection=gnb
    log to console    Install Swconfig File finished!
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb

Fetch Swconfig IF Exist
    ${output}    Run    ls /home/ute/scf/${tl_name}/${webui_scf}
    run keyword if     ${output.count('swconfig')}>0
    ...    Set Suite Variable   ${swconfig_path}    /home/ute/scf/${tl_name}/${webui_scf}/swconfig.txt
    ...    ELSE    run keywords    Set Suite Variable   ${swconfig_path}    false
    ...    AND    Log    swconfig doesn't exist in gitlab!    WARN

Wait for Site Unavailability for Perform SCF
    ${output}    RUN    ping ${LMP_ADDR} -c 3
    ${output}    Get Regexp Matches    ${output}    \\d{0,3}% packet loss
    ${output}    Fetch From Left    ${output[0]}    %
    should be true    ${${output}}> ${90}
