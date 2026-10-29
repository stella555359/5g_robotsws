*** Settings ***
Documentation


*** Variables ***
${hz_service}   https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local
${lte_service}   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build

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
