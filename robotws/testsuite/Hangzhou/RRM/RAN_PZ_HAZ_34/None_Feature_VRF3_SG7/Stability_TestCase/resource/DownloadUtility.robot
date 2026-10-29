*** Settings ***
Resource   Common.robot

*** Variables ***


*** Keywords ***
#------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------
# Create Download Full Link
Create Download Full Link
    [Arguments]   ${package_version}

    ${package_prefix}   Split String   ${package_version}   _
    ${package_prefix}   Set Variable   ${package_prefix[0]}
    @{wft_service_list}   Create List
    ...   https://10.57.169.252/build
    ...   https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build
    ...   https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
    ...   https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
    ...   https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build
    ...   https://es-si-s3-z2.eecloud.nsn-net.net/lterel/build
    ...   https://10.135.157.75/artifactory/mn-cosi-sran-central-public-remote/build
    ...   https://10.170.21.84/artifactory/mn-cosi-sran-central-public-local/build


    @{wft_services}   Create List
    FOR   ${wft_service}   IN   @{wft_service_list}
        ${wft_full_link_1}   Set Variable
        ...   ${wft_service}/${package_prefix}/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
        ${wft_full_link_2}   Set Variable
        ...   ${wft_service}/${package_prefix}/${package_version}_release_BTSSM_downloadable_A54.zip
        ${wft_full_link_3}   Set Variable
        ...   ${wft_service}/SBTSCD00/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
        Append To List   ${wft_services}   ${wft_full_link_1}   ${wft_full_link_2}   ${wft_full_link_3}
    END

    [Return]   ${wft_services}


#------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------
# Download Classical Common Package
Download Classical Common Package
    [Arguments]   ${package_version}   ${package_folder}=/home/ute/Downloads   ${old_package_folder}=/home/ute
    ${origin_path}   Set Variable   ${package_folder}/${package_version}_release_BTSSM_downloadable_A54.zip
    ${version_path}   Set Variable   ${package_folder}/${package_version}.zip

    ${old_origin_path}   Set Variable   ${old_package_folder}/${package_version}_release_BTSSM_downloadable_A54.zip
    ${old_version_path}   Set Variable   ${old_package_folder}/${package_version}.zip

    ${file_exists_origin}   Run Keyword and Return Status
    ...   OperatingSystem.File Should Exist   path=${origin_path}
    ${file_exists_version}   Run Keyword and Return Status
    ...   OperatingSystem.File Should Exist   path=${version_path}

    ${file_exists_old_origin}   Run Keyword and Return Status
    ...   OperatingSystem.File Should Exist   path=${old_origin_path}
    ${file_exists_old_version}   Run Keyword and Return Status
    ...   OperatingSystem.File Should Exist   path=${old_version_path}

    Run Keyword If   ${file_exists_origin}   OperatingSystem.Move File   ${origin_path}   ${version_path}
    Run Keyword If   ${file_exists_old_origin}   OperatingSystem.Move File   ${old_origin_path}   ${version_path}
    Run Keyword If   ${file_exists_old_version}   OperatingSystem.Move File   ${old_version_path}   ${version_path}

    ${file_exists}   Evaluate   ${file_exists_origin} or ${file_exists_version} or ${file_exists_old_origin} or ${file_exists_old_version}

    ${targetBD}   Run Keyword If   ${file_exists}   OperatingSystem.Run   command=unzip -l ${version_path} | grep -i TargetBD | awk '{print $4}'
    ...   ELSE   Set Variable   ${EMPTY}
    ${fileIntegrity}   Run Keyword And Return Status   Should Not Be Empty   ${targetBD}
    Run Keyword If   not ${fileIntegrity}   OperatingSystem.Run   command=rm -rf ${version_path}

    Return From Keyword If   ${fileIntegrity}   ${version_path}


    ${package_download_link}   Set Download Link   package_version=${package_version}

    Log To Console   Package Do Not Exist, Start to Download Package From WFT!
    Log To Console   Package Download Link: ${package_download_link}
    OperatingSystem.Run   command=rm -f wget-log*
    OperatingSystem.Run   command=wget --no-check-certificate -b ${package_download_link} -O ${version_path}
    Sleep   10s

    ${output}   OperatingSystem.Run   command=cat wget-log | head -n 20
    Should Contain   ${output}   Saving to
    ${output}   OperatingSystem.Run   command=cat wget-log | head -n 20
    Should Not Contain   ${output}   404 Not Found

    Wait Until Keyword Succeeds   90m   1m   Wait Until Wget Process Done   package_name=${version_path}
    OperatingSystem.File Should Exist   path=${version_path}
    OperatingSystem.Run   command=rm -f wget-log*
    Log To Console   Download Classical Package Finished!
    Log To Console   Package Path: ${version_path}
    [Return]   ${version_path}


Set Download Link
    [Arguments]   ${package_version}

    @{wft_services}   Create Download Full Link   package_version=${package_version}
    ${package_download_link}   Set Variable   ${EMPTY}

    FOR   ${wft_service}   IN   @{wft_services}
       ${http_code}   OperatingSystem.Run   command=echo $(curl -ksIL -w "%\{http_code\}" -o /dev/null ${wft_service})
       ${package_download_link}   Set Variable If   '${http_code.find('200')}'!='-1'   ${wft_service}   ${EMPTY}
       Exit For Loop If   '${http_code.find('200')}'!='-1'
    END
    Run Keyword If   "${package_download_link}"=="${EMPTY}"
    ...   FAIL   msg=Package Version Don't Exist In ALL Download Link. Please Download Manually.
    [Return]   ${package_download_link}


Wait Until Wget Process Done
    [Arguments]   ${package_name}
    ${output}   OperatingSystem.Run   command=cat wget-log | grep -i "saved"
    Should Contain   ${output}   ${package_name}


#------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------
# Download Package From Remote Server
Download Classical Common Package In Remote Server
    [Arguments]   ${package_version}   ${hostname}   ${username}   ${password}   ${connection}   ${remote_package_folder}=/home/ute/Downloads
    csn.Connect To   hostname=${hostname}   username=${username}   password=${password}   alias=${connection}


    ${origin_path}   Set Variable   ${remote_package_folder}/${package_version}_release_BTSSM_downloadable_A54.zip
    ${version_path}   Set Variable   ${remote_package_folder}/${package_version}.zip

    ${file_exists_origin}   csn.File Exists   remote_path=${origin_path}   connection=${connection}
    ${file_exists_version}   csn.File Exists   remote_path=${version_path}   connection=${connection}

    Run Keyword If   ${file_exists_origin}
    ...   csn.Execute   command=mv ${origin_path} ${version_path}   connection=${connection}

    Return From Keyword If   ${file_exists_origin} or ${file_exists_version}   ${version_path}

    ${package_download_link}   Set Download Link In Remote Server   package_version=${package_version}   connection=${connection}

    Log To Console   Package Do Not Exist, Start to Download Package From WFT!
    Log To Console   Package Download Link: ${package_download_link}
    csn.Execute   command=mkdir ${remote_package_folder}   connection=${connection}
    csn.Execute   command=cd ${remote_package_folder}; rm -f wget-log*   connection=${connection}
    csn.Execute   command=cd ${remote_package_folder}; wget --no-check-certificate -b ${package_download_link} -O ${version_path}
    ...  connection=${connection}
    Sleep   10s

    ${output}   csn.Execute   command=cd ${remote_package_folder}; cat wget-log | head -n 20   connection=${connection}
    Should Contain   ${output}   Saving to
    ${output}   csn.Execute   command=cd ${remote_package_folder}; cat wget-log | head -n 20   connection=${connection}
    Should Not Contain   ${output}   404 Not Found


    Wait Until Keyword Succeeds   90m   1m   Wait Until Wget Process Done In Remote Server
    ...   package_name=${version_path}   remote_package_folder=${remote_package_folder}   connection=${connection}
    csn.Assert File Exists   remote_path=${version_path}   connection=${connection}
    csn.Execute   command=cd ${remote_package_folder}; rm -f wget-log*   connection=${connection}
    Log To Console   Download Classical Package Finished!
    Log To Console   Package Path: ${version_path}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}
    [Return]   ${version_path}


Set Download Link In Remote Server
    [Arguments]   ${package_version}   ${connection}

    @{wft_services}   Create Download Full Link   package_version=${package_version}
    ${package_download_link}   Set Variable   ${EMPTY}

    FOR   ${wft_service}   IN   @{wft_services}
       ${http_code}   csn.Execute   command=echo $(curl -ksIL -w "%\{http_code\}" -o /dev/null ${wft_service})
       ...   connection=${connection}   timeout=${10}
       ${package_download_link}   Set Variable If   '${http_code.find('200')}'!='-1'   ${wft_service}   ${EMPTY}
       Exit For Loop If   '${http_code.find('200')}'!='-1'
    END
    Run Keyword If   "${package_download_link}"=="${EMPTY}"
    ...   FAIL   msg=Package Version Don't Exist In ALL Download Link. Please Download Manually.
    [Return]   ${package_download_link}

Wait Until Wget Process Done In Remote Server
    [Arguments]   ${package_name}   ${remote_package_folder}   ${connection}
    ${output}   csn.Execute   command=cd ${remote_package_folder}; cat wget-log | grep -i "saved"   connection=${connection}
    Should Contain   ${output}   ${package_name}


#------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------
# Download Classical Common Package Local And Upload To Remote Server
Download Classical Common Package Local And Upload To Remote Server
    [Arguments]   ${package_version}   ${hostname}   ${username}   ${password}   ${connection}
    ...   ${package_folder}=/home/ute/Downloads   ${remote_package_folder}=/d/oss/global/swmanager/swm_temp
    csn.Connect To   hostname=${hostname}   username=${username}   password=${password}   alias=${connection}

    ${origin_path}   Set Variable   ${remote_package_folder}/${package_version}_release_BTSSM_downloadable_A54.zip
    ${remote_package_path}   Set Variable   ${remote_package_folder}/${package_version}.zip

    ${file_exists_origin}   csn.File Exists   remote_path=${origin_path}   connection=${connection}
    ${file_exists_version}   csn.File Exists   remote_path=${remote_package_path}   connection=${connection}

    Run Keyword If   ${file_exists_origin}
    ...   csn.Execute   command=mv ${origin_path} ${remote_package_path}   connection=${connection}

    Return From Keyword If   ${file_exists_origin} or ${file_exists_version}   ${remote_package_path}


    ${package_path}   Download Classical Common Package   package_version=${package_version}   package_folder=${package_folder}
    Log To Console   Start To Upload Classical Common Package To Remote Server...
    csn.Upload File
    ...   local_path=${package_path}
    ...   remote_path=${remote_package_path}
    ...   timeout=2h
    ...   connection=${connection}
    csn.Assert File Exists   remote_path=${remote_package_path}   connection=${connection}
    csn.Execute   command=chmod 777 ${remote_package_path}   connection=${connection}
    Delete Classical Common Package   version_path=${package_path}
    Log To Console   Download Classical Common Package Local And Upload To Remote Server Finished!
    Log To Console   Remote Package Path: ${remote_package_path}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}
    [Return]   ${remote_package_path}


#------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------------------
# Remove Package
Delete Classical Common Package
    [Arguments]   ${version_path}
    ${status}   Run Keyword And Return Status   OperatingSystem.File Should Exist   ${version_path}
    Run Keyword If   ${status}   OperatingSystem.Run   command=rm -rf ${version_path}

    OperatingSystem.File Should Not Exist   path=${version_path}

Delete Classical Common Package In Remote Server
    [Arguments]   ${version_path}   ${hostname}   ${username}   ${password}   ${connection}
    csn.Connect To   hostname=${hostname}   username=${username}   password=${password}   alias=${connection}

    ${status}   csn.File Exists   remote_path=${version_path}   connection=${connection}
    Run Keyword If   ${status}   csn.Execute   command=rm -rf ${version_path}   connection=${connection}

    ${status}   csn.File Exists   remote_path=${version_path}   connection=${connection}
    Should Not Be True   ${status}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}
