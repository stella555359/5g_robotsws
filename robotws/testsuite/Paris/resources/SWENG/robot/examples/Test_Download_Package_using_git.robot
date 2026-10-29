*** Settings ***
Documentation           Suite description

Resource                ../Setup.robot
Resource                ../Oam.robot
Resource                ../Tools.robot


Suite Setup             Suite Setup from scratch    listBackupFiles=${FD_ALL}
...                                                 keepAllUeDataInCfgFile=${True}

Suite Teardown          Suite Teardown

Test Teardown           My Test Teardown


*** Test Cases ***
CB008830_Will_Use_OAM_Software_Update
    [Tags]                  DEBUG
    # Dated Log New Line          Test avec le projet Git public
    # ${git_path}                 set variable    https://gitlabe1.ext.net.nokia.com/csamson/sqdgrp_et_44.git
    # ${git_folder}               set variable    BSR
    # ${git_file_name}            set variable    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
    # ${target_dir}               set variable    /home/ute/BSR
    # Download Package Using Git                  git_path=${git_path}
    # ...                                         git_folder=${git_folder}
    # ...                                         git_file_name=${git_file_name}
    # ...                                         target_dir=${target_dir}

    Dated Log New Line          Test KW "Download Package Using Git" with "NPS_VRF_8_and_9" Git project AND with all input parameters
    ${git_path}                 set variable    gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
    ${token_name}               set variable    NpsVrfToken
    ${token_access}             set variable    glpat-4yNB_jaBXxz_BsyeAsgL
    ${git_folder}               set variable    CB008830
    ${git_file_name}            set variable    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
    ${target_dir}               set variable    ${LOG_PATH}/BSR_CB008830
    Download Package Using Git Update OAM       git_path=${git_path}
    ...                                         git_folder=${git_folder}
    ...                                         git_file_name=${git_file_name}
    ...                                         target_dir=${target_dir}
    ...                                         token_name=${token_name}
    ...                                         token_access=${token_access}
    sleep                       60

    Dated Log New Line          Test KW "Download Package Using Git" with "NPS_VRF_8_and_9" Git project AND with only mandatory parameters
    # ${git_path}                 set variable    gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
    # ${token_name}               set variable    NpsVrfToken
    # ${token_access}             set variable    glpat-4yNB_jaBXxz_BsyeAsgL
    ${git_folder}               set variable    CB008830
    ${git_file_name}            set variable    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
    # ${target_dir}               set variable    ${LOG_PATH}/BSR_CB008830
    Download Package Using Git Update OAM       git_folder=${git_folder}
    ...                                         git_file_name=${git_file_name}
    # ...                                         git_path=${git_path}
    # ...                                         target_dir=${target_dir}
    # ...                                         token_name=${token_name}
    # ...                                         token_access=${token_access}
    sleep                       60

    Dated Log New Line          Test KW "Download Package Using Git Update OAM" with "NPS_VRF_8_and_9" Git project
    ${git_path}                 set variable    gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
    ${token_name}               set variable    NpsVrfToken
    ${token_access}             set variable    glpat-4yNB_jaBXxz_BsyeAsgL
    ${git_folder}               set variable    CB011028
    ${git_file_name}            set variable    BSR_AEQE_8_H8_ALN60_ARP60_P00_COVERAGE_00426_00001.zip
    ${target_dir}               set variable    ${LOG_PATH}/BSR_CB011028
    Download Package Using Git                  git_path=${git_path}
    ...                                         git_folder=${git_folder}
    ...                                         git_file_name=${git_file_name}
    ...                                         target_dir=${target_dir}
    ...                                         token_name=${token_name}
    ...                                         token_access=${token_access}


*** Keywords ***
My Test Teardown
    [Documentation]        Perform needed actions at the end of a test case
    Test Teardown
    Restore Files          listFileDesc=${FD_ALL}
    OAM Restore Files
