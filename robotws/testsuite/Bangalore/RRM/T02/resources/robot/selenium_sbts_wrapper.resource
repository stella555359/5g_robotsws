*** Settings ***
Documentation   author: arunkumar.a@nokia.com
...             Selenium api functional keyword are using.
Library     taf.selenium.sbts    WITH NAME    selenium_sbts_lib
Resource    variables/Rjio_variables.robot


*** Keywords ***
RJIO_Sbts_Login_And_Disable_Screen_Lock
    [Documentation]    Login function
    [Arguments]    ${download_dir}=${save_log_directory}
    ...            ${timeout}=${60}
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${version}=SBTS00
    ...            ${browser}=Chrome
    # selenium_sbts_lib.enable_virtual_display
    selenium_sbts_lib.login    url=${url}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    ...                    version=${version}
    ...                    browser=${browser}
    selenium_sbts_lib.disable_message_box
    selenium_sbts_lib.disable_screen_lock

RJIO_Sbts_Logout_And_Close_Browser
    [Documentation]    Logout function
    Run Keyword And Ignore Error    selenium_sbts_lib.close_start_up_view_window    timeout=5
    Run Keyword And Ignore Error    selenium_sbts_lib.logout
    # Run Keyword And Ignore Error    selenium_sbts_lib.disable_virtual_display
    Run Keyword And Ignore Error    selenium_sbts_lib.close_browser
