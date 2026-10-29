*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB006627: New SFN0 offset management

Resource            CommonKeywords.robot


*** Keywords ***
CB010294 Setup
    Log To Console    CB010294 setup
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

# CB010294 TC_03

L3 Call with SFP56 on ABIO
    # SCF is loaded on BTS
    ${status}=    COAM SCF Load    ${bts_addr}    ${scf_file_10294}
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
        IF    '${the_abio}' in '${configDN}'    BREAK
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

    Android UE Detach    ${UE_ALIAS_1}
    Android UE Attach    ${UE_ALIAS_1}
    Sleep    10s
    ${dl_value}=    Android DL Traffic    ${UE_ALIAS_1}    ${DURATION}    ${DL_THROUGHPUT}
    ${ul_value}=    Android UL Traffic    ${UE_ALIAS_1}    ${DURATION}    ${UL_THROUGHPUT}

    Should be True    ${dl_value} > ${DL_MIN_THROUGHPUT}
    Should be True    ${ul_value} > ${UL_MIN_THROUGHPUT}
