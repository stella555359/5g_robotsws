*** Settings ***
Library   OperatingSystem
Library   utils.py


*** Keywords ***
Download software package
    [Documentation]  Downloads sw package from Artifactory using wget
    [Arguments]    ${sw_build}    ${sw_file_name}    ${dir_to_keep_package}

    ${artifactory}  set variable  http://artifactory-espoo1.ext.net.nokia.com/artifactory/
    ${source}   set variable  ${artifactory}mnp5g-central-public-local/System_Release/${sw_build}/${sw_file_name}
    ${target}   set variable  ${dir_to_keep_package}/${sw_file_name}
    ${exists}   check_if_sw_already_exists  ${target}

    run keyword if  ${exists}==${False}  Perform Download  ${target}  ${dir_to_keep_package}  ${source}

    [Return]  ${target}

Unzip SW package
    [Arguments]  ${zip_dir}

    ${dir}  ${zip_file}   split path  ${zip_dir}
    ${new_filedir}  ${ext}  split extension  ${zip_file}

    Run   unzip ${zip_dir} -d ${dir}/${new_filedir}
    [Return]  ${dir}/${new_filedir}

Delete SW package
    [Arguments]  ${zip_dir}

    Run    rm ${zip_dir}
    File Should Not Exist    ${zip_dir}

Zip SW package
    [Arguments]  ${dir}

    ${dir_no_trail}  normalize path  ${dir}
    ${nvm}  ${zip_name}  split path  ${dir_no_trail}

    Run   rm -r ${dir_no_trail}.zip
    Run   cd ${dir} && zip -r ../${zip_name}.zip *

    [Return]  ${dir_no_trail}.zip

Delete unzipped SW package
    [Arguments]  ${dir}

    Run    rm -rf ${dir}
    Directory Should Not Exist    ${dir}

Perform Download
    [Arguments]   ${target}   ${dir_to_keep_package}  ${source}

    log to console  SW download: ${target}
    Run  mkdir -p ${dir_to_keep_package}; touch ${dir_to_keep_package}downloading
    Run  unset http_proxy; wget --progress=dot:giga ${source} -O ${target}
    Run  rm -f ${dir_to_keep_package}downloading
