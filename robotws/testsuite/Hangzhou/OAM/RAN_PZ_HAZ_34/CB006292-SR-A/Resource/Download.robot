*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com
Resource   Common.robot

*** Variables ***
${hz_service}   https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local
${sbts_service}   https://artifactory-hz1.int.net.nokia.com/artifactory/mnpsbts-central-local
${lte_service}   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
${remote_server_dir}   /var/home/core/CB006292/

*** Keywords ***
Download Classical Common Package
    [Arguments]   ${package_version}
    Set Suite Variable   ${PACKAGE_NAME}   ${package_version}_release_BTSSM_downloadable_A54.zip
    Set Suite Variable   ${PACKAGE_PATH}   ${OUTPUT_DIR}/${PACKAGE_NAME}
    ${file_exists}   Run Keyword and Return Status   OperatingSystem.File Should Exist   path=${package_path}
    Return From Keyword If   ${file_exists}   ${package_path}

    ${package_download_link}   Set Download Link   package_version=${package_version}

    Log To Console   Package Do Not Exist, Start to Download Package From WFT!
    Log To Console   Package Download Link: ${package_download_link}
    OperatingSystem.Run   command=rm -f wget-log*
    OperatingSystem.Run   command=wget -b ${package_download_link} -O ${OUTPUT_DIR}/${PACKAGE_NAME}
    Sleep   10s
    ${output}   OperatingSystem.Run   command=cat wget-log
    Should Not Contain   ${output}   404 Not Found
    Wait Until Keyword Succeeds   1h   1m   Wait Until Wget Process Done   package_name=${PACKAGE_NAME}
    OperatingSystem.File Should Exist   path=${package_path}
    Log To Console    Download Classical Package Finished!
    [Return]   ${package_path}

Set Download Link
    [Arguments]   ${package_version}
    @{wft_services}   Create List
    ...   ${hz_service}/${RELEASE}_packages/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
    ...   ${sbts_service}/${RELEASE}_packages/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
    ...   ${lte_service}/${RELEASE}/${package_version}_release_BTSSM_downloadable_A54.zip

    ${package_download_link}   Set Variable   ${wft_services[-1]}

    FOR   ${wft_service}   IN   @{wft_services}
       ${http_code}   OperatingSystem.Run   command=echo $(curl -sIL -w "%\{http_code\}" -o /dev/null ${wft_service})
       ${package_download_link}   Set Variable If   '${http_code.find('200')}'!='-1'   ${wft_service}
       ...   ${True}   ${package_download_link}
       Exit For Loop If   '${http_code.find('200')}'!='-1'
    END
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
    [Arguments]   ${package_version}   ${connection}=EDGE
    Set Suite Variable   ${PACKAGE_NAME}   ${package_version}_release_BTSSM_downloadable_A54.zip
    Set Suite Variable   ${REMOTE_PACKAGE_PATH}   ${remote_server_dir}/${PACKAGE_NAME}
    ${file_exists}   csn.File Exists   remote_path=${REMOTE_PACKAGE_PATH}   connection=${connection}
    Return From Keyword If   ${file_exists}   ${REMOTE_PACKAGE_PATH}

    ${package_download_link}   Set Download Link In Remote Server   package_version=${package_version}   connection=${connection}

    Log To Console   Package Do Not Exist, Start to Download Package From WFT!
    Log To Console   Package Download Link: ${package_download_link}
    csn.Execute   command=mkdir ${remote_server_dir}   connection=${connection}
    csn.Execute   command=cd ${remote_server_dir}; rm -f wget-log*   connection=${connection}
    csn.Execute   command=cd ${remote_server_dir}; wget -b ${package_download_link} -O ${remote_server_dir}/${PACKAGE_NAME}  connection=${connection}
    Sleep   10s
    ${output}   csn.Execute   command=cd ${remote_server_dir}; cat wget-log   connection=${connection}
    Should Not Contain   ${output}   404 Not Found
    Wait Until Keyword Succeeds   1h   1m   Wait Until Wget Process Done In Remote Server   package_name=${PACKAGE_NAME}   connection=${connection}
    csn.Assert File Exists   remote_path=${REMOTE_PACKAGE_PATH}   connection=${connection}
    Log To Console    Download Classical Package Finished!
    [Return]   ${REMOTE_PACKAGE_PATH}

Set Download Link In Remote Server
    [Arguments]   ${package_version}   ${connection}=EDGE
    @{wft_services}   Create List
    ...   ${hz_service}/${RELEASE}_packages/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
    ...   ${sbts_service}/${RELEASE}_packages/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
    ...   ${lte_service}/${RELEASE}/${package_version}_release_BTSSM_downloadable_A54.zip

    ${package_download_link}   Set Variable   ${wft_services[-1]}

    FOR   ${wft_service}   IN   @{wft_services}
       ${http_code}   csn.Execute   command=echo $(curl -sIL -w "%\{http_code\}" -o /dev/null ${wft_service})   connection=${connection}
       ${package_download_link}   Set Variable If   '${http_code.find('200')}'!='-1'   ${wft_service}
       ...   ${True}   ${package_download_link}
       Exit For Loop If   '${http_code.find('200')}'!='-1'
    END
    [Return]   ${package_download_link}

Wait Until Wget Process Done In Remote Server
    [Arguments]   ${package_name}   ${connection}=EDGE
    ${output}   csn.Execute   command=cd ${remote_server_dir}; cat wget-log | grep -i "saved"   connection=${connection}
    Should Contain   ${output}   ${package_name}

