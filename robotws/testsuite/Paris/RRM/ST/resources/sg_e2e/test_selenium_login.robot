*** Settings ***

Documentation
...
...     AUTHOR (I&V-1):
...         Abderrahlamane Nezrouk

Library      OperatingSystem
Library      String
Library      Collections
Library      BuiltIn

Resource      ${CURDIR}/coam_selenium.robot

*** Variables ***
${GNB_Architecture}    CLASSICAL

*** Test Cases ***
Run Login Logout Scenario
    [Teardown]     Selenium Logout

    ${cmd}    set variable     pip list | grep selenium
    ${res}    Run    ${cmd}
    log    ${res}

    ${cmd}    set variable    which geckodriver
    ${res}    Run    ${cmd}
    log    ${res}

    ${cmd}    set variable     geckodriver --version
    ${res}    Run    ${cmd}
    log    ${res}

    ${cmd}    set variable     firefox --version
    ${res}    Run    ${cmd}
    log    ${res}

    Selenium Login
