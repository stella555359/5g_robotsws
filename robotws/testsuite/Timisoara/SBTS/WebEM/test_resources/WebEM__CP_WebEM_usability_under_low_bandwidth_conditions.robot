*** Settings ***
Documentation
    ...  This test case is created to test WebEM usability under low bandwidth conditions using Chrome DevTools Protocol (CDP). CDP is a protocol
    ...  that allows tools to inspect and control Chrome; here it is used to emulate slow network (throttling).
    ...  Throttling simulates poor connectivity (250 Kbps download and upload).
    ...  Extended page load timeout (15 minutes) is set for loading under throttling.
    ...  Network throttling is activated via CDP and page is reloaded.
    ...  Wait for WebEM to load and verify throttling is active (page load time indicates slow network).
    ...  Site Reset is performed. Reset Site button is clicked and modal is confirmed.
    ...  Wait for BTS data message and for all cells to be enabled within RECOVERY_TIMEOUT.
    ...  Verify all cells are in expected state.
    ...  BBMOD Reset is performed. Reset BBMODs and verify all cells are enabled within RECOVERY_TIMEOUT.
    ...  RMOD Reset is performed. Set window size, reset RMODs and verify all cells are enabled within RECOVERY_TIMEOUT.
    ...  Cells Block/unblock is performed for all RATs. Block and unblock cells and verify all cells are enabled within RECOVERY_TIMEOUT.
    ...  Network throttling is disabled in teardown to restore normal speed.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  # Time for SBTS to be onAir
${DISABLED_TIMEOUT}  500  # Time for HW to be disabled
${THROTTLE_DOWNLOAD_KBPS}  250  # Download speed limit in Kbps
${THROTTLE_UPLOAD_KBPS}  250  # Upload speed limit in Kbps
${THROTTLE_LATENCY_MS}  0  # Additional latency in milliseconds
${THROTTLE_PAGE_LOAD_TIMEOUT}  900  # Page load timeout in seconds (15 minutes)


*** Keywords ***
TC__WebEM__CP_WebEM_usability_under_low_bandwidth_conditions
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29867
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-29867 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf  SW-SBTS26  FEATURE-C&P

    Step1: Activate Network Throttling
    Step2: Site Reset
    Step3: BBMODs Reset
    Step4: RMODs Reset
    Step5: Cells Block/unblock


Step1: Activate Network Throttling
    Log  \nStep1: Activate Network Throttling  console=true
    Apply Network Throttling And Reload


Step2: Site Reset
    Log  \nStep2: Site reset  console=true
    Log  Reset SBTS  console=true
    Sleep  10  Time for page to be updated
    Wait Until Element Is Clicked  //*[contains(text(),'Reset Site')]
    Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Wait Until Keyword Succeeds  300  10  Page Should Contain
    ...  Unable to display BTS hardware and cells information due to missing, incomplete, or invalid BTS data.
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells
    Log  All cells are Enabled![OK]  console=true
    Close Startup View If Visible
    Log  Site was reset successfully![OK]  console=true


Step3: BBMODs Reset
    Log  \nStep3: BBMODs reset  console=true
    BBMODs Reset
    Log  Wait for all cells to be Enabled!  console=true
    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells
    IF  ${status}
        Log  All cells are Enabled [OK].  console=true
    ELSE
        Fail  Not all cells are Enabled after BBMODs reset [NOK].
    END


Step4: RMODs Reset
    Log  \nStep4: RMODs reset  console=true
    Set Window Size  ${1920}  ${2000}
    RMODs Reset
    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells
    IF  ${status}
        Log  All cells are Enabled [OK].  console=true
    ELSE
        Fail  Not all cells are Enabled after RMODs reset [NOK].
    END


Step5: Cells Block/unblock
    Log  \nStep5: Cells block/unblock  console=true
    Cells Block And Unblock For All RATs  ${RECOVERY_TIMEOUT}  ${DISABLED_TIMEOUT}
    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells
    IF  ${status}
        Log  All cells are Enabled![OK]  console=true
    ELSE
        Fail  Not all cells are Enabled![NOK]
    END


Get WebDriver Instance
    [Documentation]  Returns the current WebDriver instance from SeleniumLibrary.
    ...
    ...  Returns: WebDriver instance
    ...  Author: andreea.burtic@nokia.com

    ${sl}  Get Library Instance  SeleniumLibrary

    RETURN  ${sl.driver}


Enable Network Throttling Via CDP
    [Documentation]  Enable network throttling using Chrome DevTools Protocol (CDP).
    ...
    ...  Uses values from Variables section:
    ...  - THROTTLE_DOWNLOAD_KBPS
    ...  - THROTTLE_UPLOAD_KBPS
    ...  - THROTTLE_LATENCY_MS
    ...
    ...  Note: Throttling applies to all network requests after this call.
    ...
    ...  Example:
    ...  | Enable Network Throttling Via CDP |
    ...
    ...  Author: andreea.burtic@nokia.com

    ${download_bps}  Evaluate  int(${THROTTLE_DOWNLOAD_KBPS} * 125)
    ${upload_bps}  Evaluate  int(${THROTTLE_UPLOAD_KBPS} * 125)
    ${latency}  Evaluate  int(${THROTTLE_LATENCY_MS})
    ${webdriver}  Get WebDriver Instance

    ${params}  Evaluate  {'offline': False, 'latency': ${latency}, 'downloadThroughput': ${download_bps}, 'uploadThroughput': ${upload_bps}}

    Call Method  ${webdriver}  execute_cdp_cmd  Network.emulateNetworkConditions  ${params}
    Log  Network throttling ENABLED: Download=${THROTTLE_DOWNLOAD_KBPS}Kbps, Upload=${THROTTLE_UPLOAD_KBPS}Kbps  console=true


Disable Network Throttling Via CDP
    [Documentation]  Disable network throttling using Chrome DevTools Protocol (CDP).
    ...  Restores normal network speed (no limitations).
    ...
    ...  Example:
    ...  | Disable Network Throttling Via CDP |
    ...
    ...  Author: andreea.burtic@nokia.com

    ${webdriver}  Get WebDriver Instance

    ${params}  Evaluate  {'offline': False, 'latency': 0, 'downloadThroughput': -1, 'uploadThroughput': -1}

    Call Method  ${webdriver}  execute_cdp_cmd  Network.emulateNetworkConditions  ${params}
    Log  Network throttling DISABLED  console=true


Verify Network Throttling Is Active
    [Documentation]  Verify throttling by checking page load performance metrics.
    ...  Uses browser's Performance API to analyze resource loading times.
    ...
    ...  Returns: Page load time in seconds
    ...
    ...  Example:
    ...  | ${page_load_time} | Verify Network Throttling Is Active |
    ...
    ...  Author: andreea.burtic@nokia.com

    ${js_code}  Catenate  SEPARATOR=\n
    ...  var nav = performance.getEntriesByType('navigation')[0];
    ...  var pageLoadTimeMs = nav ? Math.round(nav.loadEventEnd - nav.startTime) : 0;
    ...  var pageLoadTimeSec = Math.round(pageLoadTimeMs / 1000);
    ...  var resources = performance.getEntriesByType('resource');
    ...  var resourceCount = resources.length;
    ...  return { pageLoadTime: pageLoadTimeSec, resourceCount: resourceCount };

    ${result}  Execute Javascript  ${js_code}
    ${page_load_time}  Set Variable  ${result}[pageLoadTime]
    ${resource_count}  Set Variable  ${result}[resourceCount]

    Log  Performance metrics: ${resource_count} resources loaded, page load time: ${page_load_time}s  console=true

    IF  ${page_load_time} >= 300
        Log  Throttling VERIFIED: Page load time ${page_load_time}s indicates slow network  console=true
    ELSE
        Fail  Throttling VERIFICATION FAILED: Page load time ${page_load_time}s - CDP throttling was not sent successfully
    END

    RETURN  ${page_load_time}


Apply Network Throttling And Reload
    [Documentation]  Enable network throttling via CDP and reload the page.
    ...  WebEM must already be open before calling this keyword.
    ...
    ...  Flow:
    ...  1. Set extended page load timeout
    ...  2. Enable CDP throttling
    ...  3. Reload page (so throttling applies)
    ...  4. Wait for page to load under throttled conditions
    ...  5. Verify throttling is active
    ...
    ...  Uses THROTTLE_PAGE_LOAD_TIMEOUT variable for timeout.
    ...
    ...  Example:
    ...  | Apply Network Throttling And Reload |
    ...
    ...  Author: andreea.burtic@nokia.com

    ${webdriver}  Get WebDriver Instance
    Call Method  ${webdriver}  set_page_load_timeout  ${THROTTLE_PAGE_LOAD_TIMEOUT}

    Enable Network Throttling Via CDP

    Log  Reloading page with throttling (this will be slow)...  console=true
    Reload Page

    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  ${THROTTLE_PAGE_LOAD_TIMEOUT}
    ...  WebEM not loaded under throttling in ${THROTTLE_PAGE_LOAD_TIMEOUT}

    ${page_load_time}  Verify Network Throttling Is Active
    Log  Throttling active: ${THROTTLE_DOWNLOAD_KBPS}Kbps down, ${THROTTLE_UPLOAD_KBPS}Kbps up  console=true


TC Setup
    Common Test Setup  tc_name=WebEM__CP_usability_under_low_bandwidth_conditions
    WebEM Setup


TC Teardown
    Disable Network Throttling Via CDP
    WebEM Teardown
    Common Test Teardown
