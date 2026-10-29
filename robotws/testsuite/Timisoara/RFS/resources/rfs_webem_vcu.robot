*** Settings ***
Documentation  WebEM VCU Resource

Library  SeleniumLibrary  run_on_failure=Nothing
Resource  rfs_webem_common.robot

*** Keywords ***

VCU WebEM Setup
    [Documentation]  This keyword is used to vCU WebEM Setup.
    [Arguments]  ${alias}  ${timeout}=60s

    Set Screenshot Directory  ${Test Results Dir}/webem_screenshots
    Open VCU WebEM  alias=${alias}  timeout=${timeout}

VCU WebEM Teardown
    [Documentation]  This keyword is used to vCU WebEM Teardown.
    [Arguments]  ${alias}

    Switch Browser  ${alias}
    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    Capture Page Screenshot  vCU_Snapshot_after_test_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.png
    Logout From CBTS
    Close Browser

Open VCU WebEM
    [Documentation]  This keyword opens the vCU WebEM in chrome browser and maximizes the window.
    [Arguments]  ${alias}  ${timeout}

    ${vcu_ip}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_CU_IP_ADDRESS]
    ${vcu_port}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_CU_PORT]
    ${vcu_username}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_CU_USERNAME]
    ${vcu_password}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_CU_PASSWORD]

    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=/home/ute/Downloads
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors          # Ignore SSL errors (useful on VMs with self-signed certs)
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors  # Bypasses HTTPS certificate checks in test environments
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking     # Allow popups/windows to open during automation tests
    Call Method  ${chrome_options}  add_argument  --headless                   # Run without UI (headless mode, needed on VMs)
    Call Method  ${chrome_options}  add_argument  --no-sandbox                 # Avoid sandbox issues in VMs; safe with/without headless
    Call Method  ${chrome_options}  add_argument  --disable-dev-shm-usage      # Prevent shared memory crashes in VMs; safe with/without headless
    Call Method  ${chrome_options}  add_argument  --disable-gpu                # Disable GPU acceleration (mainly for headless/VM stability on Linux)
    Call Method  ${chrome_options}  add_argument  --disable-extensions         # Disable extensions (reduce overhead; safe with/without headless)
    Create Webdriver  Chrome  alias=${alias}  options=${chrome_options}
    Switch Browser  ${alias}
    Go To  https://${vcu_ip}:${vcu_port}
    Set Window Size  ${1920}  ${1800}
    Check Private Connection From BTS
    Login On CBTS  username=${vcu_username}  password=${vcu_password}
    Confirm Legal Notice From CBTS
    Log  Wait until the page is loaded!  console=true
    Wait Until Element Is Visible  //span[contains(@class, 'title') and contains(text(), 'DUs Status Summary')]  ${timeout}
    ...  WebElement is not fully loaded in ${timeout} seconds.
    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    Capture Page Screenshot  vCU_WebEM_initial_state_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.png
