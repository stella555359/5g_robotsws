*** Settings ***

Documentation
...                 author/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 maintainer/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 Keywords for CNI-99209 tests

Library     SeleniumLibrary
Library     OperatingSystem
Library     SSHLibrary
Library     ta_emss
Library     on_air_tl_preparation.testline_preparation    WITH NAME    tl_prep
Library     taf.rfrl.ue.logs.qxdm_logs.WindowsUePcUtil
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/common/gnb_scf.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Keywords ***

Test Setup
    Log to console    \n--Test Setup started--\n
    Wait For Site To Be Onair
    Common preconditions With Watching Alarms
    Log to console    \n--Test Setup done--\n
    Log to console    \n--Starting test ${TEST_NAME}--\n

Test Teardown
    Log to console    \n--Finished test ${TEST_NAME}--\n
    Log to console    \n--Test Teardown started--\n
    Close All Browsers
    Common postconditions With Watching Alarms
    Log to console    \n--Test Teardown done--\n

Suite Setup
    Log to console    \n--Suite Setup started--\n
    tl_prep.Power On All Pdu Ports
    Setup build specific variables
    Prepare BTS configuration
    Common Suite Setup
    Reset gNB
    Wait For Site To Be Onair
    Set Suite Variable    ${IS_ASIR_CONFIGURATION}    ${False}
    Setup EMSSIM
    Log to console    \n--Suite Setup done--\n

Suite Teardown
    Log to console    \n--Suite Teardown started--\n
    Common Suite Teardown
    Run keyword and ignore error    Logout of asir webem
    Close All Browsers
    Log to console    Tearing down EMSSIM
    Run Keyword And Ignore Error    Teardown EMss    alias=asir1
    Log to console    \n--Suite Teardown done--\n

Run Keyword And Retry On Error
    [Arguments]    ${keyword}    ${attempts}    &{args}
    FOR    ${_}    IN RANGE    ${attempts}
        TRY
            Run Keyword    ${keyword}    &{args}
        EXCEPT    .*    type=regexp
            Log    \n--exception occured attempting again--\n    console=${True}
        ELSE
            RETURN
        END
    END

Deactivate ne3s
    ${output}=    Run Emssim Command    ne3s_deactivate    alias=asir1    get_full_data=True
    ${output}=    Convert To String    ${output}
    Log    ${output}    console=${True}
    Should Contain    ${output}    Proxy Command ne3s_deactivate SUCCEEDED
    Sleep    5s
    Run EMSSIM Command  proxy_clear  get_full_data=True  alias=asir1

Run EMSSIM NE3S Activation and deactivation
    [Arguments]    ${username}    ${password}
    [Teardown]    Deactivate ne3s

    ${output}=    Run Emssim Command    ne3s_activate -user ${username} -password ${password}    alias=asir1    get_full_data=True
    ${output}=    Convert To String    ${output}
    Log    ${output}    console=${True}
    Should Contain    ${output}    Proxy Command ne3s_activate SUCCEEDED
    Sleep    5s
    ${output}=    Run EMSSIM Command  proxy_show  get_full_data=True  alias=asir1
    ${output}=    Convert To String    ${output}
    Log    ${output}    console=${True}
    Should Not Contain    ${output}    Ne3sRegister flow failure
    Run EMSSIM Command  proxy_clear  get_full_data=True  alias=asir1

Attempt ASIR Connection
    [Arguments]    ${password}
    Open Connection    192.168.255.129    alias=GNB    timeout=15s
    Login    username=${bts_username}    password=${bts_password}
    Write    lxc-attach --name 0x2018 ssh ${hub_username}@${hub_ip}
    Run keyword and ignore error    Read Until    Are you sure
    Run keyword and ignore error    Write    yes
    Read Until    Password:
    Write    ${password}
    Read Until    ${hub_username}@fzhub
    Close Connection


Wait and click
    [Arguments]    ${locator}    ${timeout}=10s
    Wait Until Page Contains Element    ${locator}    timeout=${timeout}
    Wait Until Element is Visible    ${locator}    timeout=${timeout}
    Click Element    ${locator}

Wait and input
    [Arguments]    ${locator}    ${input}    ${timeout}=10s
    Wait Until Page Contains Element    ${locator}    timeout=${timeout}
    Wait Until Element is Visible    ${locator}    timeout=${timeout}
    Input Text    ${locator}    ${input}

Open asir login page
    Open Browser    https://192.168.255.129:3601/    browser=headlessfirefox
    Wait and input    //*[@data-placeholder="Username"]    Nemuadmin
    Wait and input    //*[@data-placeholder="Password"]    nemuuser
    Click Button    //button[contains(text(),"Log in")]
    Wait and click    //button[contains(text(),"Accept")]

Enter account settings
    Wait and click    //*[@data-mat-icon-name="commissioningIcon"]
    Wait and click    //button[@id="accountsStartButton"]

Perform config reset inlcuding ASI password storage
    Wait and click    //*[@data-mat-icon-name="commissioningIcon"]
    Wait and click    //button[@id="configResetStartButton"]
    Wait and click    //mat-checkbox[@id="clear-passwords-checkbox"]
    Wait and click    //button[contains(text(),"Continue")]
    Wait and click    //button[contains(text(),"Finish")]    timeout=600s

Set Ne3s user account password
    [Arguments]    ${password}
    Wait and click    //div[@class="select-wrapper"]
    Wait and click    //mat-option[@id="accountType1"]
    Wait and input    //input[contains(@class, 'newPassword')]    ${password}
    Wait and input    //input[contains(@class, 'confirmPassword')]    ${password}
    Wait and click    //button[contains(text(),"Continue")]
    Wait and click    //button[contains(text(),"Finish")]

Reset Ne3s user account password
    Wait and click    //div[@class="select-wrapper"]
    Wait and click    //mat-option[@id="accountType1"]
    Wait and click    //span[@class="mat-checkbox-inner-container"]
    Wait and click    //button[contains(text(),"Continue")]
    Wait and click    //button[contains(text(),"Finish")]

Set Hub user account password
    [Arguments]    ${password}
    Wait and click    //div[@class="select-wrapper"]
    Wait and click    //mat-option[@id="accountType0"]
    Wait and input    //input[contains(@class, 'newPassword')]    ${password}
    Wait and input    //input[contains(@class, 'confirmPassword')]    ${password}
    Wait and click    //button[contains(text(),"Continue")]
    Wait and click    //button[contains(text(),"Finish")]

Reset Hub user account password
    Wait and click    //div[@class="select-wrapper"]
    Wait and click    //mat-option[@id="accountType0"]
    Wait and click    //span[@class="mat-checkbox-inner-container"]
    Wait and click    //button[contains(text(),"Continue")]
    Wait and click    //button[contains(text(),"Finish")]

Logout of asir webem
    Wait and click    //a[@id="user-information"]
    Wait and click    //a[@id="log_out"]
    Sleep    5s

Get validation errors
    ${validation_errors}=     Get WebElements    //li[@class="ng-star-inserted validator-info-error"]/span
    Log    ${validation_errors}     console=${True}
    RETURN    ${validation_errors}

Parse validation errors
    [Arguments]    ${validation_errors}

    IF    ${{len($validation_errors) == 0}}
        FAIL    No validation errors found
    END

    FOR   ${error}    IN    @{validation_errors}
        ${error_text}=    Get Text    ${error}
        Log    ${error_text}    console=${True}
    END

Perform software rollback
    perform_rollback
    Sleep    900s

Prepare BTS configuration
    Log    Performing gNB commissioning on branch: ${build_branch}    console=${True}
    Perform Full Commissioning on Classical gNB    prefix_tag=${None}    custom_config=${False}
    Log    Performing ASIR commissioning on branch: ${build_branch}   console=${True}
    Sleep    30s
    Perform asir scf recommissioning
    Log    Awaiting OnAir site state    console=${True}
    Wait For Site To Be Onair

Perform asir scf recommissioning
    gnb_asir.perform_asir_commissioning    commissionings/Krakow/7_7_UTE5GCLOUDT2SK192/${build_branch}/GNB0_ASIR_SCF.xml

Install EMSSIM
    [Arguments]    ${alias}=asir1
    Log    Downloading EMSSIM .deb package    console=${True}
    Run    wget ${EMSSIM_download_link} -O /home/ute/Downloads/emssim.deb
    Log    Installing EMSSIM package    console=${True}
    Run    sudo dpkg -i /home/ute/Downloads/emssim.deb
    Log    Creating user account for asir with associated bts address
    Run    sudo /opt/emssim/util/add_user.pl -u ${alias} -ip ${bts_mplane_ip}
    Log    Finished EMSSIM installation    console=${True}

Check if EMSSIM is installed on the VM
    [Arguments]    ${alias}=asir1
    ${output}=    Run    getent passwd ${alias}
    IF    'asir1' not in '${output}'
        RETURN    ${False}
    END
    RETURN    ${True}

Setup EMSSIM
    ${is_emssim_installed}=    Check if EMSSIM is installed on the VM
    IF    not ${is_emssim_installed}
        Log    EMSSIM is not installed    console=${True}
        Install EMSSIM
    END
    Log    Setting up EMSSIM    console=${True}
    Log    Using bts IP: ${bts_mplane_ip}    console=${True}
    Setup Emss    bts_ip=${bts_mplane_ip}    user=asir1    alias=asir1    wait_connected=False

Setup build specific variables
    ${_build_branch}=    Set Variable    ${ENB_BUILD.split("_")[0]}
    Set Suite Variable    ${build_branch}    ${_build_branch}
    Log to console    \n-- Detected build branch: ${build_branch} --\n