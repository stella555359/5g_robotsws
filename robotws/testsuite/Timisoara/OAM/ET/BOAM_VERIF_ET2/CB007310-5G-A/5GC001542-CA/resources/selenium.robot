*** Settings ***
Documentation
...    Author: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Maintainer: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors


*** Variables ***
${XPath_TNL}=       //*[@id="main-view"]/div/div[1]/div[2]/global-search/div/wf-panel/wf-panel-section/div/div/div/
...     div/div[2]/global-search-tab-content/historical-counters-global-search/div/pm-tree/div/div/div/div/div/div[1]/i
${XPath_IPIF}=      //*[@id="main-view"]/div/div[1]/div[2]/global-search/div/wf-panel/wf-panel-section/div/div/div/
...     div/div[2]/global-search-tab-content/historical-counters-global-search/div/pm-tree/div/div/div/div/div/div[4]/i
${XPath_IPIF5}=     //*[@id="main-view"]/div/div[1]/div[2]/global-search/div/wf-panel/wf-panel-section/div/div/div/
...     div/div[2]/global-search-tab-content/historical-counters-global-search/div/pm-tree/div/div/div/div/div/div[5]/i
${XPath_IP_Interface_Statistics}=   //*[@id="main-view"]/div/div[1]/div[2]/global-search/div/wf-panel/wf-panel-section/
...     div/div/div/div/div[2]/global-search-tab-content/historical-counters-global-search/div/pm-tree/div/div/div/div/
...     div/div[6]/i
${XPath_M51321C0}=      //*[@id="main-view"]/div/div[1]/div[2]/global-search/div/wf-panel/wf-panel-section/div/div/div/div/
...     div[2]/global-search-tab-content/historical-counters-global-search/div/pm-tree/div/div/div/div/div/div[7]/
...     label/span
${XPath_TNL_Collapse}=      //*[@id="main-view"]/div/div[1]/div[2]/global-search/div/wf-panel/wf-panel-section/div/
...     div/div/div/div[2]/global-search-tab-content/historical-counters-global-search/div/pm-tree/div/div/div/div/
...     div/div[1]/label/span

*** Keywords ***
SELENIUM Prepare Enviroment
    SELENIUM Install Chromedriver
    SELENIUM Run Xvfb
    SELENIUM Export DISPLAY

SELENIUM Install Chromedriver
    Run
    ...    command=sudo cp /home/ute/trunk/selenium/chromedriver /usr/bin
    Run
    ...    command=sudo chmod +x /usr/bin/chromedriver

SELENIUM Run Xvfb
    Start Process
    ...    command=/usr/bin/Xvfb :99 -screen 0 1920x1080x16
    ...    shell=yes

SELENIUM Export DISPLAY
   Set Environment Variable
   ...     name=DISPLAY
   ...     value=:99

SELENIUM Input Text in Visible Element
    [Arguments]
    ...    ${locator}
    ...    ${text}
    ...    ${timeout}=10s
    Wait Until Element Is Visible
    ...    locator=${locator}
    ...    timeout=${timeout}
    Input Text
    ...    locator=${locator}
    ...    text=${text}

SELENIUM Pop Confirm
    SELENIUM Click Visible Element
    ...    locator=${POP_CONFIRM_BTN}

SELENIUM Click Visible Element
    [Arguments]
    ...    ${locator}
    ...    ${timeout}=30s
    Wait Until Element Is Visible
    ...    locator=${locator}
    ...    timeout=${timeout}
    Click Element
    ...    locator=${locator}

SELENIUM Teardown Enviroment
    Close All Browsers
    Terminate All Processes
