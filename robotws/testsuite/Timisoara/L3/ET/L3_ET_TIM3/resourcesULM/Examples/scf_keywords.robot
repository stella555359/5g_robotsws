*** Settings ***
Library    taf.config.scf            WITH NAME    scf
Library    taf.sbts.oam.coam.admin   WITH NAME    admin

*** Variables ***
${current_scf}   None

*** Keywords ***
Get Parameter Value from SCF
    [Arguments]    ${dist_name}     ${param_name}

    ${scf}=   Get Current SCF from gNodeB
    scf.LoadScf     ${scf}

    ${value}=   scf.Get Value From Scf
    ...     dist_name=${dist_name}
    ...     p_name=${param_name}

    [Return]    ${value}


Get Current SCF from gNodeB
    [Arguments]    ${gnb_id}=${0}

    ${current_scf}=    Run Keyword If    '${current_scf}'=='None'
    ...                                Get SCF from gNB    gnb_id=${gnb_id}    target_dir=${resultTestDir}
    ...                            ELSE
    ...                                Set Variable    ${current_scf}
    Set Test Variable    ${current_scf}
    [Return]    ${current_scf}


