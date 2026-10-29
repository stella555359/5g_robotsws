*** Settings ***
Documentation   This Test Suite is for verifying the functionality
...             of the common keywords in wts_ue.robot

Library     OperatingSystem
Library     taf.config.wts     WITH NAME    wts

Resource    ../wts_ue.robot
Resource    ../ute_workarounds.robot
Resource    ../testline.robot

Suite Setup  UTE Cloud Workaround


*** Test Cases ***

test Kill WTS services
    [TAGS]      WTS
    Kill WTS services
    log to console  check result:
    ${result}   Run     pgrep 'egate\|edaemon'
    Builtin.should be empty  ${result}  

test Start WTS for Airphone
    [TAGS]      WTS
    Start WTS for Airphone
    ${result}   Run     pgrep 'egate\|edaemon'
    Builtin.should not be empty  ${result}

test Store Current swconfig from Airphone
    [TAGS]      WTS
    Store Current swconfig from Airphone
    file should exist  ${P_ORIG_AP_SWCONFIG}
    
test Collect egate log files
    [TAGS]      WTS
    ${target_dir}=  testline.Get Testcase Log Directory
    wts_ue.Collect egate log files
    file should exist  ${target_dir}/wtssim_egate*gz 
     
test Collect edaemon log files
    [TAGS]      WTS
    ${target_dir}=  testline.Get Testcase Log Directory
    wts_ue.Collect edaemon log files
    file should exist  ${target_dir}/wtssim_edaemon*gz
    
test Collect sos report logs
    [TAGS]      WTS
    ${target_dir}=  testline.Get Testcase Log Directory
    Collect sos report logs
    file should exist  ${target_dir}/SosReport*.tgz
        
test Upload Customized WTS Config
    [TAGS]      WTS
    ${suite_folder}     testline.Get test suite directory
    ${config_folder}    testline.Get test suite config directory
    Store Current WTS Config
    File Should Exist   ${P_ORIG_WTS_CONFIG}
    Upload Customized WTS Config    ${P_ORIG_WTS_CONFIG}    update_config=False

test Reload stored swconfig to Airphone
    [TAGS]      WTS
    Reload stored swconfig to Airphone
    
test Update SW Config file on AP System Module
    [TAGS]      WTS
    @{AP_MOD_RD_FLAGS}=    Create list    \#0x4711=42
    Update SW Config file on AP System Module  ${AP_MOD_RD_FLAGS}
    ${new_swconfig}  Get swconfig from Airphone
    Reload stored swconfig to Airphone
    ${new_swconfig_content}  Get file  ${new_swconfig}
    should contain  ${new_swconfig_content}   \#0x4711=42

test Update ARFCN in WTS Config
    [TAGS]      WTS
    Update ARFCN in WTS Config
    Log   Check that the global variables exist with some value
    FOR   ${varname}   IN   P_gNbCuType   P_cellTechnology   P_freqBandIndicatorNR   P_nrarfcn
       ${value}   Get Variable Value   ${${varname}}
       Should Be True   '${value}'!='${None}'   Error: ${varname} is None
    END

test Configure multiple UEs in WTS Basic Configuration File
    [TAGS]      WTS     MULTIUE
    &{UE}                               Create Dictionary
    ${number_of_ues}                    Set Variable    ${4}
    ${target_dir}                       testline.Get Testcase Log Directory
    Store Current WTS Config            ${target_dir}
    File Should Exist                   ${P_ORIG_WTS_CONFIG}
    ${destination_file}                 Set Variable    ${target_dir}/basic_setup_ci-SANSA-test-${number_of_ues}ues.cfg
    @{mode_list}                        Create List     NSA         SA
    @{mode_filter}                      Create List     *imsi=*     *suci=*
    @{source_list}                      Create List
    ...                                 ${tl.core.dir_path}/${tl.core.cfg_filename}
    ...                                 ${destination_file}
    FOR  ${mode}  ${filter}  ${source_file}   IN ZIP     ${mode_list}        ${mode_filter}     ${source_list}
        ${new_ue_id_list}               Configure multiple UEs in WTS Basic Configuration File
        ...                             source_file=${source_file}
        ...                             destination_file=${destination_file}
        ...                             number_of_ues=${number_of_ues}
        ...                             mode=${mode}
        ${new_nbr_of_ue}                Get Length                  ${new_ue_id_list}
        Run Keyword and Continue On Failure     Should Be Equal As Integers     ${new_nbr_of_ue}    ${number_of_ues}
        ...                             Nbr of returned UE ids ${new_nbr_of_ue} differ from requested nbr of UEs ${number_of_ues}!  values=${False}
        Run Keyword and Continue On Failure     File Should Exist   ${destination_file}
        wts.Load Wts Cfg                ${destination_file}
        ${lines_of_ues}                 wts.find all                set_ue
        ${lines_of_ues}                 Collections.Get Matches     ${lines_of_ues}     ${filter}
        Log List                        ${lines_of_ues}
        ${ue_count}                     Get Length                  ${lines_of_ues}
        Run Keyword and Continue On Failure     Should Be Equal As Integers     ${number_of_ues}    ${ue_count}
        ...                             Expected ${number_of_ues} UE(s) but found ${ue_count} UE(s) for ${mode}!    values=${False}
        Log To Console                  \nFound '${ue_count}' UE(s) for ${mode} in ${destination_file}
        Set To Dictionary               ${UE}   ${mode}=${ue_count}
    END
    Run Keyword and Continue On Failure     Should Be Equal As Integers         ${UE.NSA}    ${UE.SA}
    ...                                 Nbr of configured UE differ between modes: NSA=${UE.NSA} UE(s) vs. SA UE=${UE.SA} UE(s)!  values=${False}
    wts.Load Wts Cfg                    ${destination_file}
    ${lines_of_ues}                     wts.find all                set_ue
    ${ue_count}                         Get Length                  ${lines_of_ues}
    Run Keyword and Continue On Failure     Should Be Equal As Integers         ${number_of_ues*2}  ${ue_count}
    ...                                 Nbr of NSA+SA UEs (${ue_count}) isn't equal to number_of_ues*2 (${number_of_ues*2})!  values=${False}
    [Teardown]  Set Suite Variable    ${P_BASIC_CFG_CLEANED}    ${FALSE}


test Configure multiple UEs in WTS Basic Configuration File 1 UE
    [TAGS]      WTS
    Test WTS UE Config Change   number_of_ues=${1}      nsa_start_ue=${11}  sa_start_ue=${1}
    [Teardown]  Set Suite Variable    ${P_BASIC_CFG_CLEANED}    ${FALSE}

test Configure multiple UEs in WTS Basic Configuration File 2 UE
    [TAGS]      WTS     MULTIUE
    Test WTS UE Config Change   number_of_ues=${2}      nsa_start_ue=${11}  sa_start_ue=${1}
    [Teardown]  Set Suite Variable    ${P_BASIC_CFG_CLEANED}    ${FALSE}

test Configure multiple UEs in WTS Basic Configuration File With Start_ue_id Within Default Ue
    [TAGS]      WTS     MULTIUE
    Test WTS UE Config Change   number_of_ues=${5}      nsa_start_ue=${12}  sa_start_ue=${2}
    [Teardown]  Set Suite Variable    ${P_BASIC_CFG_CLEANED}    ${FALSE}

test Configure multiple UEs in WTS Basic Configuration File With Start_ue_id Outside Default Ue
    [TAGS]      WTS     MULTIUE
    Test WTS UE Config Change   number_of_ues=${10}     nsa_start_ue=${51}  sa_start_ue=${41}
    [Teardown]  Set Suite Variable    ${P_BASIC_CFG_CLEANED}    ${FALSE}



*** Keywords ***
Test WTS UE Config Change
    [Arguments]     ${number_of_ues}    ${nsa_start_ue}     ${sa_start_ue}
    &{UE}                               Create Dictionary
    ${target_dir}                       testline.Get Testcase Log Directory
    Store Current WTS Config            ${target_dir}
    File Should Exist                   ${P_ORIG_WTS_CONFIG}
    @{mode_list}                        Create List     NSA                 SA
    @{mode_filter}                      Create List     *imsi=*             *suci=*
    @{start_ue_list}                    Create List     ${nsa_start_ue}     ${sa_start_ue}
    FOR  ${mode}  ${filter}  ${start_ue}    IN ZIP      ${mode_list}        ${mode_filter}      ${start_ue_list}
        ${destination_file}             Set Variable    ${target_dir}/basic_setup_ci-${mode}-test-${number_of_ues}ues.cfg
        ${new_ue_id_list}               Configure multiple UEs in WTS Basic Configuration File
        ...                             destination_file=${destination_file}
        ...                             number_of_ues=${number_of_ues}
        ...                             mode=${mode}
        ...                             start_ue_id=${start_ue}
        ${new_nbr_of_ue}                Get Length                  ${new_ue_id_list}
        Run Keyword and Continue On Failure     Should Be Equal As Integers     ${new_nbr_of_ue}    ${number_of_ues}
        ...                             Nbr of returned UE ids ${new_nbr_of_ue} differ from requested nbr of UEs ${number_of_ues}!  values=${False}
        Run Keyword and Continue On Failure     File Should Exist   ${destination_file}
        wts.Load Wts Cfg                ${destination_file}
        ${lines_of_ues}                 wts.find all                set_ue
        ${lines_of_ues}                 Collections.Get Matches     ${lines_of_ues}     ${filter}
        Log List                        ${lines_of_ues}
        ${ue_count}                     Get Length                  ${lines_of_ues}
        Run Keyword and Continue On Failure     Should Be Equal As Integers     ${number_of_ues}    ${ue_count}
        ...                             Expected ${number_of_ues} UE(s) but found ${ue_count} UE(s) for ${mode}!    values=${False}
        Log To Console                  \nFound '${ue_count}' UE(s) for ${mode} in ${destination_file}
        Set To Dictionary               ${UE}   ${mode}=${ue_count}
        Set Suite Variable              ${P_BASIC_CFG_CLEANED}    ${FALSE}
    END
    Should Be Equal As Integers         ${UE.NSA}    ${UE.SA}
    ...                                 Nbr of configured UE differ between modes: NSA=${UE.NSA} UE(s) vs. SA UE=${UE.SA} UE(s)!  values=${False}
