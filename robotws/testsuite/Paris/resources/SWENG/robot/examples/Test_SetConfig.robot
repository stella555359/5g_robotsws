*** Settings ***
Library                 OperatingSystem
Resource                ../Setup.robot
Resource                ../SetConfig.robot

Documentation           Suite description

Suite Setup             Suite Setup

*** Variables ***

${nb_ue_SA}             5
${nb_ue_NSA}            5

*** Test Cases ***
Test JIRA 069
    [Tags]    DEBUG

    Create UEs in Cfg File      nb_nsa_ues=${nb_ue_NSA}
    ...                         nb_sa_ues=${nb_ue_SA}

