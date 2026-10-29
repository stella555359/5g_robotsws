*** Settings ***
Documentation     Keyword used for BBPooling and  MuMIMO

Library     ../python/BBpooling_MuMIMO.py
Resource      ./Admin.robot

*** Variables ***
${local_save_path}   /home/ute/BSR
${git_link}   "https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git"

*** Keywords ***
Get and Update BSR SW via gitlab
     [Arguments]      ${sw_file_name}
     Run   rm -rf ${local_save_path};mkdir -p ${local_save_path};git clone ${git_link} ${local_save_path}
     ADMIN Setup Admin
     ADMIN Update Software With Activation
     ...           sw_package=${local_save_path}/BSR_FILE/${sw_file_name}

Get and Update BSR SW
     [Arguments]      ${sw_path}   ${sw_folder}    ${sw_file_name}    ${dir_to_keep_package}
     ${target}=  Download software package    ${sw_path}   ${sw_folder}    ${sw_file_name}    ${dir_to_keep_package}
     ADMIN Setup Admin
     ADMIN Update Software With Activation
     ...           sw_package=${target}


Download software package
    [Documentation]  Downloads sw package from Artifactory using wget
    [Arguments]   ${sw_path}   ${sw_folder}    ${sw_file_name}    ${dir_to_keep_package}
    ${artifactory}  set variable    ${sw_path}
    ${source}   set variable  ${artifactory}/${sw_folder}/${sw_file_name}
    ${target}   set variable  ${dir_to_keep_package}/${sw_file_name}
    ${exists}   check_if_sw_already_exists  ${target}
    run keyword if  ${exists}==${False}  Perform Download  ${target}  ${dir_to_keep_package}  ${source}
    [Return]  ${target}


Perform Download
    [Arguments]   ${target}   ${dir_to_keep_package}  ${source}
    log to console  SW download: ${target}
    Run  mkdir -p ${dir_to_keep_package}; touch ${dir_to_keep_package}downloading
    Run  unset http_proxy; wget --progress=dot:giga ${source} -O ${target}
    Run  rm -f ${dir_to_keep_package}downloading

Set Srs beam position
    [Arguments]   ${profile_id}   ${quad_pos}    ${sub_quad_pos}
     wtsrunner.ul_mimo_srs_beam_pos_nr   profile_id=${profile_id}     mode=fixed    init_quad_pos=${quad_pos}
     ...     init_sub_quad_pos=${sub_quad_pos}   step=5    trigger_puxch_update=0      test_type=SRS
     sleep  2s

Activate MIMO profile
    [Arguments]   ${ue_id}    ${profile_id}
    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=ul_mimo_srs_beam_pos     action=activate     profile_id=${profile_id}


