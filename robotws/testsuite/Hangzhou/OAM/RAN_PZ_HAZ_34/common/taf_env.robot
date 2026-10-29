*** Settings ***
Documentation   Author: jingmin.he@nokia-sbell.com
Library   OperatingSystem

Library    taf.collectors.btslog        WITH NAME    btslog

*** Variables ***
${package_web_service}    https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${package_folder}   /mnt/5g_build/System_Release/

*** Keywords ***
Change ASOE Parallel QC Path
    [Arguments]   ${folder_path}=${CURDIR}
    ${qc_files}   List Files In Directory   ${folder_path}   *.qc
    Return From Keyword If   len(${qc_files})==${0}
    Log to Console   ${folder_path}${/}${qc_files[0]}
    ${content}   Run   grep -i \"\\\\\\\\RAN_PZ_VERF_CN_SG07\" -A 2 ${folder_path}${/}${qc_files[0]}
    ${test_set}   Should Match Regexp   ${content}   \\".*\\":\\s*\\[
    ${set_name}   Should Match Regexp   ${test_set}   \\".*\\"
    ${pure_name}   Should Match Regexp   ${set_name}   [^"]+
    Log to console   Origin Set: ${pure_name}
    Run   sed -i \'s/${pure_name}/ASOE/g\' ${folder_path}${/}${qc_files[0]}
    Run   cat ${folder_path}${/}${qc_files[0]}

Get Package Path by Version
    [Documentation]   Package file path
    [Arguments]   ${package_version}
#    ${package_folder}   set variable   /mnt/5g_build/System_Release/
    ${mount_request}=   Run Keyword and return status   OperatingSystem.Directory Should Exist   ${package_folder}
    run keyword if  not ${mount_request}   Mount NFS File Server
    ${mount_request}=   Run Keyword and return status   OperatingSystem.Directory Should Exist   ${package_folder}
    ${package_name}=    Run Keyword If    ${mount_request}   Set Package Name   package_version=${package_version}
    ${package_exist}   run keyword and return status   should contain    ${package_name}   ${package_version}
    ${package_name}=   Run Keyword If    ${package_exist}   set variable   ${package_name}
    ...   ELSE   Download Classical Package   ${package_version}
    [Return]   ${package_name}

Set Package Name
    [Documentation]   Package file name return
    [Arguments]   ${package_version}
    ${release_info}=   Get gnb release
    ${package_name}    set variable
    ${package_name}    Run   find ${package_folder} -name \'Air*${package_version}.zip\'
    [Return]    ${package_name}

Mount NFS File Server
    [Documentation]   DEP. NFS file server mount
    Run   service nfs-server start
    Run   mkdir -p /mnt/5g_build
    Run   umount /mnt/5g_build
    Run   mount -t nfs 10.57.169.251:/disk3/nfs/5g_build /mnt/5g_build -o ro,soft,intr,retry=1,rsize=32768,wsize=3276

Wait Until Wget Process Done
    [Arguments]   ${package_name}
    ${output}   Run   cat wget-log | grep -i "saved"
    Should Contain   ${output}   ${package_name}

Download Classical Package
    [Arguments]   ${package_version}
    ${file_exists}   Run Keyword and Return Status   OperatingSystem.File Should Exist   ${package_path}
    ${package_download_dir}=   Set Variable
    ...   ${package_web_service}/${package_version}
    ${package_download_path}=   Set Variable   ${package_download_dir}/AirScale-${package_version}.zip
    ${package_path}   Run Keyword If   ${file_exists}   Set Variable   /home/ute/Downloads/AirScale-${package_version}.zip
    ...    ELSE   Download Package in path   ${package_download_path}   /home/ute/Downloads   AirScale-${package_version}.zip
    Set Suite Variable   ${package_path}
    [Return]   ${package_path}

Download Package in path
    [Arguments]   ${url}   ${local_dir}   ${file_name}
    Log To Console    \nPackage Do Not Exist, Start to Download Package From WFT!
    Run   rm -f wget-log*
    Run   wget -b ${url} -P ${local_dir}
    Wait Until Keyword Succeeds   1h   1m   Wait Until wget process done   ${file_name}
    OperatingSystem.File Should Exist   ${local_dir}${/}${file_name}
    Log To Console    Download Classical Package Finished!
    [Return]   ${local_dir}${/}${file_name}

IPV6 no proxy setting
    [Arguments]   ${ip_addr}
    ${proxy_exist}   Run Keyword and Return Status   Environment Variable Should Be Set   no_proxy
    Run Keyword If   ${proxy_exist}   Run Keyword If   "%{no_proxy}".count("${ip_addr}") == 0
    ...   OperatingSystem.Append To Environment Variable   no_proxy   ${ip_addr}
    ...   ELSE    OperatingSystem.Set Environment Variable   no_proxy   ${ip_addr}

Get Super Command Startup
    [Documentation]   Check if the current user is "root", if no, all special command should start with "sudo"
    ${user}   Run   command=whoami
    ${super_cmd}   Run Keyword If   '${user}'=='root'   Set Variable   ${EMPTY}
    ...   ELSE   Set Variable   sudo${SPACE}
    [Return]   ${super_cmd}
