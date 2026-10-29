*** Settings ***
Documentation     author: tashia tan
...               Group: HGZ_SG5
...               contact: tashia.tan@nokia-sbell.com

Resource          ../../common/coam_resource.robot
Library           ../../libraries/verify_snapshot.py
Library           verify_snapshot.VerifySnapshot    WITH NAME    snap

*** Variables ***

*** Keywords ***
save snapshot
    [Arguments]    ${coverage}    ${save_location}
    selenium_coam.snapshot_collection_settings    coverage=${coverage}    save_location=${save_location}
    ${snapshot_log}   selenium_coam.collect_snapshot    snapshot_waiting_timeout=1800
    set suite variable    ${snapshot_log}
    ${snapshot_tmp_path}    ${snapshot_name}    Split Path   ${snapshot_log}
    set suite variable    ${snapshot_name}
    set suite variable    ${snapshot_tmp_path}

check snapshot collected in local driver and copy it
    OperatingSystem.File Should Exist     ${snapshot_log}
    ${rc}    ${output}    Run And Return Rc And Output    ls -l ${snapshot_tmp_path}
    should not contain    ${output}     ${snapshot_name}.part
    OperatingSystem.Copy File     ${snapshot_log}     ${SAVE LOG DIRECTORY}

unzip snapshot file
    snap.un_zip   path_name=${SAVE LOG DIRECTORY}    file_name=${snapshot_name}
    ${p1}    ${e1}    OperatingSystem.Split Extension    ${SAVE LOG DIRECTORY}/${snapshot_name}
    [Return]      ${p1}

check the expected file collected
    [Arguments]    ${pattern}
    ${unzip_file_path}=     unzip snapshot file
    log    ${unzip_file_path}
    set suite variable    ${unzip_file_path}
    @{files}=    OperatingSystem.List Files In Directory    path=${unzip_file_path}    pattern=${pattern}   absolute=${True}
    should not be empty    ${files}

remove the unzip directory
    run keyword and ignore error    WEBUI Logout
    run keyword and ignore error    OperatingSystem.Remove Directory    path=${unzip_file_path}    recursive=${True}