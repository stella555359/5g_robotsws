*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB006627: New SFN0 offset management

Resource            CommonKeywords.robot


*** Keywords ***
CB010871 Setup
    Log To Console    CB010871 setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}
    Require UE    ue_alias=${UE_ALIAS_1}    capabilities=${CAPABILITIES}
    Require UE    ue_alias=${UE_ALIAS_2}    capabilities=${CAPABILITIES}

Test Setup
    Log To Console    Test setup
    # BTS is OnAir
    Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

    # Start the logs
    # Start All Logs

Test Teardown
    Log To Console    Test teardown
    # Save the logs and get Snapshot
    # Get All Logs

    # BTS is OnAir
    Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

# CB010871 TC_56

SFP56 on Yoda and switched network
    # SCF is loaded on BTS
    ${status}=    COAM SCF Load    ${bts_addr}    ${CV31_scf_file_10871}
    Log To Console    ${status}

    # BTS is OnAir without alarm
    Wait Until Keyword Succeeds    30 min    1 min    COAM Get 5g status enabled    ${bts_addr}
    COAM Check Fault not Displayed in webEM    ${bts_addr}    1868

    Android UE Attach    ${UE_ALIAS_2}
    Sleep    10s
    ${ul_value}=    Android UL Traffic    ${UE_ALIAS_2}    ${DURATION}    ${UL_THROUGHPUT}
    ${dl_value}=    Android DL Traffic    ${UE_ALIAS_2}    ${DURATION}    ${DL_THROUGHPUT}

    Should be True    ${ul_value} > ${UL_MIN_THROUGHPUT}
    Should be True    ${dl_value} > ${DL_MIN_THROUGHPUT}

# CB010871 TC_08 CV135

SFP56 on Yoda and 16 streams
    # SCF is loaded on BTS
    ${status}=    COAM SCF Load    ${bts_addr}    ${yoda_scf_file_10871}
    Log To Console    ${status}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    COAM Get 5g status enabled    ${bts_addr}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin
    ${bbmod_r_list}=    coam.get_managed_objects    BBMOD_R    connection=coam_admin
    FOR    ${bbmod_r}    IN    @{bbmod_r_list}
        ${parameters}=    Get From Dictionary    ${bbmod_r}    parameters
        Log To Console    ${parameters}
        ${distName_bbmod}=    Get From Dictionary    ${bbmod_r}    distName
        ${configDN}=    Get From Dictionary    ${parameters}    configDN
        IF    '${yoda_the_abip}' in '${configDN}'    BREAK
    END

    ${sfp_r_list}=    coam.get_managed_objects    SFP_R    connection=coam_admin
    FOR    ${sfp_r}    IN    @{sfp_r_list}
        ${distName_sfp}=    Get From Dictionary    ${sfp_r}    distName
        IF    '${distName_bbmod}' in '${distName_sfp}'    BREAK
    END

    ${parameters_sfp}=    Get From Dictionary    ${sfp_r}    parameters
    ${transceiverComplianceCode}=    Get From Dictionary    ${parameters_sfp}    transceiverComplianceCode
    Log To Console    ${transceiverComplianceCode}
    Should Be Equal As Strings    ${transceiverComplianceCode}    50Gbase_LR

    Run Keyword And Continue on failure    COAM Parameter Online update    ${bts_addr}    ${yoda_ecpri_cablink}
    ...    linkSpeed    eCpri25

    # Wait for alarm
    Wait until Keyword Succeeds    30 min    1 min    COAM Check Fault Displayed in webEM    ${bts_addr}    1868

    Run Keyword And Continue on failure    COAM Parameter Online update    ${bts_addr}    ${yoda_ecpri_cablink}
    ...    linkSpeed    eCpri50

    # BTS is OnAir without alarm
    Wait Until Keyword Succeeds    30 min    1 min    COAM Get 5g status enabled    ${bts_addr}
    COAM Check Fault not Displayed in webEM    ${bts_addr}    1868

    Android UE Attach    ${UE_ALIAS_1}
    Sleep    10s
    ${dl_value}=    Android DL Traffic    ${UE_ALIAS_1}    ${DURATION}    ${DL_THROUGHPUT}
    ${ul_value}=    Android UL Traffic    ${UE_ALIAS_1}    ${DURATION}    ${UL_THROUGHPUT}

    Should be True    ${dl_value} > ${DL_MIN_THROUGHPUT}
    Should be True    ${ul_value} > ${UL_MIN_THROUGHPUT}

# CB010871 TC_57 CV135

SFP56 on Fisto and 32 streams
    # SCF is loaded on BTS
    ${status}=    COAM SCF Load    ${bts_addr}    ${fisto_scf_file_10871}
    Log To Console    ${status}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    COAM Get 5g status enabled    ${bts_addr}

    Wait Until Keyword Succeeds    1min    10s    coam.connect to    bts_host=${bts_addr}    name=coam_admin
    ${bbmod_r_list}=    coam.get_managed_objects    BBMOD_R    connection=coam_admin
    FOR    ${bbmod_r}    IN    @{bbmod_r_list}
        ${parameters}=    Get From Dictionary    ${bbmod_r}    parameters
        Log To Console    ${parameters}
        ${distName_bbmod}=    Get From Dictionary    ${bbmod_r}    distName
        ${configDN}=    Get From Dictionary    ${parameters}    configDN
        IF    '${fisto_the_abip}' in '${configDN}'    BREAK
    END

    ${sfp_r_list}=    coam.get_managed_objects    SFP_R    connection=coam_admin
    FOR    ${sfp_r}    IN    @{sfp_r_list}
        ${distName_sfp}=    Get From Dictionary    ${sfp_r}    distName
        IF    '${distName_bbmod}' in '${distName_sfp}'    BREAK
    END

    ${parameters_sfp}=    Get From Dictionary    ${sfp_r}    parameters
    ${transceiverComplianceCode}=    Get From Dictionary    ${parameters_sfp}    transceiverComplianceCode
    Log To Console    ${transceiverComplianceCode}
    Should Be Equal As Strings    ${transceiverComplianceCode}    50Gbase_LR

    # BTS is OnAir without alarm
    Wait Until Keyword Succeeds    30 min    1 min    COAM Get 5g status enabled    ${bts_addr}
    COAM Check Fault not Displayed in webEM    ${bts_addr}    1868

    Android UE Detach    ${UE_ALIAS_2}
    Android UE Attach    ${UE_ALIAS_2}
    Sleep    10s
    ${dl_value}=    Android DL Traffic    ${UE_ALIAS_2}    ${DURATION}    ${DL_THROUGHPUT}
    ${ul_value}=    Android UL Traffic    ${UE_ALIAS_2}    ${DURATION}    ${UL_THROUGHPUT}

    Should be True    ${dl_value} > ${DL_MIN_THROUGHPUT}
    Should be True    ${ul_value} > ${UL_MIN_THROUGHPUT}
