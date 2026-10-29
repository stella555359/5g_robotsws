*** Settings ***
Documentation
...    Author: yin.4.chen@nokia-sbell.com
...    Feature CNI-103502 Automation

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

