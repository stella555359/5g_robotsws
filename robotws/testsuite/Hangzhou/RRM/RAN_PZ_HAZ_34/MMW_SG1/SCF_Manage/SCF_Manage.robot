*** Settings ***
Library     OperatingSystem
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/check_testline/Resources/scf_project_manage.py

Documentation    Suite description
...   author: Cheng Catherine
...   contact: catherine.cheng@nokia-sbell.com
...   squad group: MMW_SG1


*** Variables ***
${url}                  git@wrgitlab.ext.net.nokia.com:mmw1/mmw1_config.git
${scf_path}             /home/ute/Projects/mmw1_config/
${backup_path}          /tmp/mmw1_config_backup

*** Test Cases ***
Clean And Re-clone SCF Project
    [Tags]
    [Documentation]   author: catherine.cheng@nokia-sbell.com
    ...      1. backup  /home/ute/Projects/mmw1_config/ to /tmp/mmw1_config_backup
    ...      2. delete  /home/ute/Projects/mmw1_config/ and re-git clone mmw1_config
    ...      3. teardown: try to restore /home/ute/Projects/mmw1_config/ from /tmp/mmw1_config_backup if src not exists
    [Setup]
    run keyword and continue on failure  backup_project    ${scf_path}    ${backup_path}
    run keyword and continue on failure    redo_git_clone    ${url}    ${scf_path}
    [Teardown]    restore_project_if_needed    ${scf_path}    ${backup_path}
