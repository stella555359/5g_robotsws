*** Settings ***
Resource         ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource         ../resources/robot/ConformanceTest_keywords_mcshark.robot
Resource         ../resources/robot/ConformanceTest_Setup_Env_mcshark.robot
Resource         ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot
#Resource         taf/rfrl/common_resources/robot/coam.robot
#Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
#Resource         ../resources/robot/TTI_Traces.robot
#Resource         ../resources/NPS/SWENG/robot/PacketSearch.robot
#Resource         ../resources/robot/Setup_Env.robot
#Resource         ../resources/robot/Airphone.robot
#Resource         ../resources/robot/WTS_Runner_Keywords.robot

#Library          taf.transport.ssh           WITH NAME    taf_ssh
#Library          taf.wts.runner              WITH NAME    wtsrunner
#Library          luashark_tools.analyzer       WITH NAME       analyzer
#Library          ute_admin                         WITH NAME   ute_adm
#Library          Collections
#Library          OperatingSystem
#Library          ta5g_tshark
#Library          ta5g_commissioning
#Library          taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
#Library          taf.transport.ssh                 WITH NAME    csn
#Library          OperatingSystem
#Library          String

*** Variables ***
&{AP_ASIK}                      ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik

*** Keywords ***

Get MCShark Version
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${sw_version}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    ${list_version}    Split String    ${sw_version}    _
    ${first}    ${rest}    Split String    ${sw_version}    _    1
    ${new_version}    Set Variable If    "${list_version}[2]"=="9999"
    ...    SBTS00_${rest}      ${sw_version}
    ${list_version}    Split String    ${new_version}    _
    ${rest}    ${last}    Split String From Right    ${new_version}    _    1
    ${latest_version}    Set Variable If    "${list_version}[0]"!="SBTS00" and "${list_version}[-1]"!="000000"
    ...    ${rest}_000000      ${new_version}
    [Return]    ${latest_version}

Download MCShark To UTE
    ${wireshark_version}    Run    ls /usr/lib/x86_64-linux-gnu/wireshark/plugins
    set suite variable     ${wireshark_version}
    ${sw_version}    Get MCShark Version
    ${cmd}    Set Variable    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${MCShark}    Run    ls ${EXECDIR}/artifactory/mcshark-local/${sw_version}/mcshark-${wireshark_version}*buster.so
    set suite variable     ${MCShark}
    ${is_MCShark_exist}    Run keyword and return status    Should not contain    ${MCShark}    No such file or directory
    Run keyword if   ${is_MCShark_exist}==${True}   Download MCShark If Have
    ...  ELSE         log to console    This version mcshark donot exit and use last version mcshark

Download MCShark If Have
    Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/mcshark-*buster.so
    Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/
    log to console    download mcshark successfully to UTE

Change IPHY File Value
    [Arguments]    ${RU_TYPE}   ${GSCN}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "card"|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    ${c1}${c2}
    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "GSCN"|awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  600s

Get IPHY XML From Airphone
    [Arguments]    ${save_dir}
    [Documentation]    This keyword is to get iphy.xml from Airphone, return file_path include name
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${save_dir} | Yes | where to save iphy.xml |
    ...
    ...    Examples:
    ...    | ${iphy_path} | Get IPHY XML From Airphone | ${OUTPUT_DIR} |
    ...
    OperatingSystem.Run    sshpass -p ${AP_ASIK.password} scp ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy.xml ${save_dir}
    OperatingSystem.Should Exist    ${save_dir}/iphy.xml
    ${iphy_path}    Set Variable    ${save_dir}/iphy.xml
    [Return]    ${iphy_path}

Send IPHY XML To Airphone
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ...
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/
    Should Be Equal As Integers    ${rc}    0
