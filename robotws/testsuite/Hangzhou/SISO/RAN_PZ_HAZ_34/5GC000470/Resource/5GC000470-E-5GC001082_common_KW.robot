*** Settings ***
Documentation    Resource file used for  Feature 5GC000470-E-5GC001082 cases
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001178-A/Resource/5GC001178-A-5GC001082_common_KW.robot

*** Variables ***
#${target_version}              0.800.206

*** Keywords ***
"${Step}" Login WebUI and check env
    log to console    Login WebUI and check env
    wait until keyword succeeds      3min    10s     WEBUI Login
	Check board and cell status

"${Step}" Select SW build and download to VM from external value
    log to console    Select SW build and download to VM from external value
    ${package_full_link}    Get link For Download from external value    version_type=Active
    ${upgrade_package_abs_path}    Download SW Build to VM     package_full_link=${package_full_link}
    set suite variable    ${upgrade_package_abs_path}

"${Step}" Start site upgrade without active
    log to console    Start site upgrade without active
    Download package to site         if_active=${FALSE}        upgrade_package_path=${upgrade_package_abs_path}
    selenium_coam.disable_screen_lock
    wait until keyword succeeds    80min     1min     Check SW download progress finished
    selenium_coam.enable_screen_lock

"${Step}" Start site upgrade with active
   	log to console    Start site upgrade with active
	Download package to site         if_active=${TRUE}        upgrade_package_path=${upgrade_package_abs_path}
    selenium_coam.disable_screen_lock
    wait until keyword succeeds    30min     1min     Check site reset actually finished
    selenium_coam.enable_screen_lock
	wait until keyword succeeds      3min    10s     WEBUI Login

"${Step}" Check the SW package download finished from external value
    log to console    Check the SW package download finished from external value
    wait until keyword succeeds    4min    10s     Check SW version with external package value    check_version=Planned
	
"${Step}" Check the SW package upgrade finished from external value
    log to console    Check the SW package upgrade finished from external value
    wait until keyword succeeds    4min    10s     Check SW version with external package value    check_version=Active

"${Step}" Check the update report
    log to console    Check the update report
    Check the update report
	
"${Step}" Logout webui
    log to console    logout webui
    run keyword and ignore error    WEBUI Logout
	
Select SW build and download to VM
    [Arguments]    ${select_type}
    log to console    Select SW build and download to VM
    ${version_b4_update}    ${package_full_link}    Get The Version link For Download    version_type=${select_type}
    set suite variable    ${version_b4_update}
    ${upgrade_package_abs_path}    Download SW Build to VM    package_full_link=${package_full_link}
    set suite variable    ${upgrade_package_abs_path}	

Check the SW download or upgrade finished
    [Arguments]    ${b4_type}    ${after_type}
    log to console    Check the SW download or upgrade finished
    wait until keyword succeeds    10min    30s    WEBUI Login
    wait until keyword succeeds    5min    10s    Check sw version without external package value    version_b4=${version_b4_update}
    ...    cp_b4=${b4_type}    cp_after=${after_type}	

"${Step}" Start site upgrade same as active version with active
   	log to console    Start site upgrade same as active version with active
    Download package to site    if_active=${TRUE}        upgrade_package_path=${upgrade_package_abs_path}
    selenium_coam.disable_screen_lock
    wait until keyword succeeds    15min    10s    Check reset progress when same as active version
    selenium_coam.enable_screen_lock
	
