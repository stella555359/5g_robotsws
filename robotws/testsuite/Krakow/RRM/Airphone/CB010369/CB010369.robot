*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks

Resource    resources/CB010369-common_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
...           CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...           CONFIGS_Krakow/CB010471/2_AWEUA_4_cells_SANSA_TDD.xml.yaml

Suite Setup     Run Keywords
...             Run setup
...     AND     Enable internal mirroring for alias  gNB2

#Suite Teardown    Run Suite Teardown


*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate.lua
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB010369/scfc_2_AWEUA_4_cells_SANSA_TDD.xml
${AP_XML}                 ${CURDIR}/../../../../../custom-config/Krakow/CB010369/iphy_2_AWEUA_4_cells_SANSA_TDD.xml
${SKIP_COUNTERS}=         ${FALSE}
${rtpm}=                  ${FALSE}
${NRRFSP_PROFILE1_inactivity_timer_value}    40
${NRRFSP_PROFILE2_inactivity_timer_value}    80
${NRRFSP_new_inactivity_timer_value}         120
${NRSPID_PROFILE1_inactivity_timer_value}    30
${NRSPID_PROFILE2_inactivity_timer_value}    60
${NRSPID_new_inactivity_timer_value}         90
${SrbINactivitytimerSA_value}                120
${NRRFSP_PROFILE1_IndexToRFSP_value}         1
${NRRFSP_PROFILE2_IndexToRFSP_value}         3
${NRSPID_PROFILE1_spid_value}                1
${NRSPID_PROFILE2_spid_value}                3
${SA_UE_id}                                  1
${NSA_UE_id}                                 11
${SA_cell_id}                                1
${NSA_cell_id}                               3

*** Test Cases ***
[1]TC1 Verification SPID based inactivity timer config during Bearer Context Setup
    Change nsaActivityNotificationLevel value    value=drb
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE1_spid_value}
    Attach UE and Verify SPID inactivitytimer in BearerContextSetup
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE1_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE1_inactivity_timer_value}
    ...    notification_level=drb
    Detach NSA UE    ue_id=${NSA_UE_id}
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE2_spid_value}
    Attach UE and Verify SPID inactivitytimer in BearerContextSetup
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE2_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE2_inactivity_timer_value}
    ...    notification_level=drb
    Detach NSA UE    ue_id=${NSA_UE_id}

    Change nsaActivityNotificationLevel value    value=ue
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE1_spid_value}
    Attach UE and Verify SPID inactivitytimer in BearerContextSetup
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE1_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE1_inactivity_timer_value}
    ...    notification_level=ue
    Detach NSA UE    ue_id=${NSA_UE_id}
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE2_spid_value}
    Attach UE and Verify SPID inactivitytimer in BearerContextSetup
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE2_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE2_inactivity_timer_value}
    ...    notification_level=ue
    Detach NSA UE    ue_id=${NSA_UE_id}

    [Teardown]    Common Teardown

[1]TC2 Verification SPID based inactivity timer config during Bearer Context Modification with Intra-DU HO
    Change nsaActivityNotificationLevel value    value=drb
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE1_spid_value}
    Handover UE and Verify SPID inactivitytimer in BearerContextSetup
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE1_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE1_inactivity_timer_value}
    ...    notification_level=drb
    Detach NSA UE    ue_id=${NSA_UE_id}
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE2_spid_value}
    Handover UE and Verify SPID inactivitytimer in BearerContextSetup
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE2_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE2_inactivity_timer_value}
    ...    notification_level=drb
    Detach NSA UE    ue_id=${NSA_UE_id}

    Change nsaActivityNotificationLevel value    value=ue
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE1_spid_value}
    Handover UE and Verify SPID inactivitytimer in BearerContextSetup
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE1_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE1_inactivity_timer_value}
    ...    notification_level=ue
    Detach NSA UE    ue_id=${NSA_UE_id}
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE2_spid_value}
    Handover UE and Verify SPID inactivitytimer in BearerContextSetup
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE2_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE2_inactivity_timer_value}
    ...    notification_level=ue
    Detach NSA UE    ue_id=${NSA_UE_id}

    [Teardown]    Common Teardown

[1]TC4 Verification of Successful SgNB Release due to expiration of SPID based Inactivity timer
    Change nsaActivityNotificationLevel value    value=drb
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE1_spid_value}
    Attach UE and Verify SPID inactivitytimer in BearerContextSetup
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE1_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE1_inactivity_timer_value}
    ...    notification_level=drb
    Verify bearer context inactivity notification after InactivityTimer expires
    ...    timeout=${NRSPID_PROFILE1_inactivity_timer_value}
    Detach NSA UE    ue_id=${NSA_UE_id}
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE2_spid_value}
    Attach UE and Verify SPID inactivitytimer in BearerContextSetup
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE2_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE2_inactivity_timer_value}
    ...    notification_level=drb
    Detach NSA UE    ue_id=${NSA_UE_id}

    Change nsaActivityNotificationLevel value    value=ue
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE1_spid_value}
    Attach UE and Verify SPID inactivitytimer in BearerContextSetup
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE1_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE1_inactivity_timer_value}
    ...    notification_level=ue
    Detach NSA UE    ue_id=${NSA_UE_id}
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE2_spid_value}
    Attach UE and Verify SPID inactivitytimer in BearerContextSetup
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE2_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE2_inactivity_timer_value}
    ...    notification_level=ue
    Detach NSA UE    ue_id=${NSA_UE_id}

    [Teardown]    Common Teardown

[1]TC5 Verification RFSP based inactivity timer config during Bearer Context Setup
    Change activitynotificationlevelSA value    value=drb
    Choose NRRFSP PROFILE by rfsp value    ue_id=${SA_UE_id}    IndexToRFSP_value=${NRRFSP_PROFILE1_IndexToRFSP_value}
    Attach UE and Verify RFSP inactivitytimer in BearerContextSetup
    ...    ue_id=${SA_UE_id}
    ...    cell_id=${SA_cell_id}
    ...    IndexToRFSP_value=${NRRFSP_PROFILE1_IndexToRFSP_value}
    ...    inactivity_timer_value=${NRRFSP_PROFILE1_inactivity_timer_value}
    ...    notification_level=drb
    Detach SA UE    ue_id=${SA_UE_id}
    Choose NRRFSP PROFILE by rfsp value    ue_id=${SA_UE_id}    IndexToRFSP_value=${NRRFSP_PROFILE2_IndexToRFSP_value}
    Attach UE and Verify RFSP inactivitytimer in BearerContextSetup
    ...    ue_id=${SA_UE_id}
    ...    cell_id=${SA_cell_id}
    ...    IndexToRFSP_value=${NRRFSP_PROFILE2_IndexToRFSP_value}
    ...    inactivity_timer_value=${NRRFSP_PROFILE2_inactivity_timer_value}
    ...    notification_level=drb
    Detach SA UE    ue_id=${SA_UE_id}

    Change activitynotificationlevelSA value    value=ue
    Choose NRRFSP PROFILE by rfsp value    ue_id=${SA_UE_id}    IndexToRFSP_value=${NRRFSP_PROFILE1_IndexToRFSP_value}
    Attach UE and Verify RFSP inactivitytimer in BearerContextSetup
    ...    ue_id=${SA_UE_id}
    ...    cell_id=${SA_cell_id}
    ...    IndexToRFSP_value=${NRRFSP_PROFILE1_IndexToRFSP_value}
    ...    inactivity_timer_value=${NRRFSP_PROFILE1_inactivity_timer_value}
    ...    notification_level=ue
    Detach SA UE    ue_id=${SA_UE_id}
    Choose NRRFSP PROFILE by rfsp value    ue_id=${SA_UE_id}    IndexToRFSP_value=${NRRFSP_PROFILE2_IndexToRFSP_value}
    Attach UE and Verify RFSP inactivitytimer in BearerContextSetup
    ...    ue_id=${SA_UE_id}
    ...    cell_id=${SA_cell_id}
    ...    IndexToRFSP_value=${NRRFSP_PROFILE2_IndexToRFSP_value}
    ...    inactivity_timer_value=${NRRFSP_PROFILE2_inactivity_timer_value}
    ...    notification_level=ue
    Detach SA UE    ue_id=${SA_UE_id}

    [Teardown]    Common Teardown

[1]TC6 Verification of Successful UE Context Release due to expiration of RFSP based Inactivity timer
    Change activitynotificationlevelSA value    value=drb
    Choose NRRFSP PROFILE by rfsp value    ue_id=${SA_UE_id}    IndexToRFSP_value=${NRRFSP_PROFILE1_IndexToRFSP_value}
    Attach UE and Verify RFSP inactivitytimer in BearerContextSetup
    ...    ue_id=${SA_UE_id}
    ...    cell_id=${SA_cell_id}
    ...    IndexToRFSP_value=${NRRFSP_PROFILE1_IndexToRFSP_value}
    ...    inactivity_timer_value=${NRRFSP_PROFILE1_inactivity_timer_value}
    ...    notification_level=drb
    Verify bearer context inactivity notification after InactivityTimer expires
    ...    timeout=${NRRFSP_PROFILE1_inactivity_timer_value}
    Verify UE context release after srbInactivityTimerSA expires    timeout=${SrbINactivitytimerSA_value}
    Detach SA UE and kill if failed    ue_id=${SA_UE_id}
    Choose NRRFSP PROFILE by rfsp value    ue_id=${SA_UE_id}    IndexToRFSP_value=${NRRFSP_PROFILE2_IndexToRFSP_value}
    Attach UE and Verify RFSP inactivitytimer in BearerContextSetup
    ...    ue_id=${SA_UE_id}
    ...    cell_id=${SA_cell_id}
    ...    IndexToRFSP_value=${NRRFSP_PROFILE2_IndexToRFSP_value}
    ...    inactivity_timer_value=${NRRFSP_PROFILE2_inactivity_timer_value}
    ...    notification_level=drb
    Verify bearer context inactivity notification after InactivityTimer expires
    ...    timeout=${NRRFSP_PROFILE2_inactivity_timer_value}
    Verify UE context release after srbInactivityTimerSA expires    timeout=${SrbINactivitytimerSA_value}
    Detach SA UE and kill if failed    ue_id=${SA_UE_id}

    Change activitynotificationlevelSA value    value=ue
    Choose NRRFSP PROFILE by rfsp value    ue_id=${SA_UE_id}    IndexToRFSP_value=${NRRFSP_PROFILE1_IndexToRFSP_value}
    Attach UE and Verify RFSP inactivitytimer in BearerContextSetup
    ...    ue_id=${SA_UE_id}
    ...    cell_id=${SA_cell_id}
    ...    IndexToRFSP_value=${NRRFSP_PROFILE1_IndexToRFSP_value}
    ...    inactivity_timer_value=${NRRFSP_PROFILE1_inactivity_timer_value}
    ...    notification_level=ue
    Verify bearer context inactivity notification after InactivityTimer expires
    ...    timeout=${NRRFSP_PROFILE1_inactivity_timer_value}
    Verify UE context release after srbInactivityTimerSA expires    timeout=${SrbINactivitytimerSA_value}
    Detach SA UE and kill if failed    ue_id=${SA_UE_id}
    Choose NRRFSP PROFILE by rfsp value    ue_id=${SA_UE_id}    IndexToRFSP_value=${NRRFSP_PROFILE2_IndexToRFSP_value}
    Attach UE and Verify RFSP inactivitytimer in BearerContextSetup
    ...    ue_id=${SA_UE_id}
    ...    cell_id=${SA_cell_id}
    ...    IndexToRFSP_value=${NRRFSP_PROFILE2_IndexToRFSP_value}
    ...    inactivity_timer_value=${NRRFSP_PROFILE2_inactivity_timer_value}
    ...    notification_level=ue
    Verify bearer context inactivity notification after InactivityTimer expires
    ...    timeout=${NRRFSP_PROFILE2_inactivity_timer_value}
    Verify UE context release after srbInactivityTimerSA expires    timeout=${SrbINactivitytimerSA_value}
    Detach SA UE and kill if failed    ue_id=${SA_UE_id}

    [Teardown]    Common Teardown

[1]TC7 Verification of Successful SPID based Inactivity timer configuration during Bearer Context Modification after spidInactivityTimer change
    Change nsaActivityNotificationLevel value    value=drb
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE1_spid_value}
    Attach UE and Verify SPID inactivitytimer in BearerContextModification
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE1_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE1_inactivity_timer_value}
    ...    new_inactivity_timer_value=${NRSPID_new_inactivity_timer_value}
    ...    profile_id=1
    ...    notification_level=drb
    Detach NSA UE    ue_id=${NSA_UE_id}
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE2_spid_value}
    Attach UE and Verify SPID inactivitytimer in BearerContextModification
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE2_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE2_inactivity_timer_value}
    ...    new_inactivity_timer_value=${NRSPID_new_inactivity_timer_value}
    ...    profile_id=2
    ...    notification_level=drb
    Detach NSA UE    ue_id=${NSA_UE_id}

    Change nsaActivityNotificationLevel value    value=ue
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE1_spid_value}
    Attach UE and Verify SPID inactivitytimer in BearerContextModification
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE1_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE1_inactivity_timer_value}
    ...    new_inactivity_timer_value=${NRSPID_new_inactivity_timer_value}
    ...    profile_id=1
    ...    notification_level=ue
    Detach NSA UE    ue_id=${NSA_UE_id}
    Choose NRSPID PROFILE by spid value    ue_id=${NSA_UE_id}    spid_value=${NRSPID_PROFILE2_spid_value}
    Attach UE and Verify SPID inactivitytimer in BearerContextModification
    ...    ue_id=${NSA_UE_id}
    ...    cell_id=${NSA_cell_id}
    ...    spid_value=${NRSPID_PROFILE2_spid_value}
    ...    inactivity_timer_value=${NRSPID_PROFILE2_inactivity_timer_value}
    ...    new_inactivity_timer_value=${NRSPID_new_inactivity_timer_value}
    ...    profile_id=2
    ...    notification_level=ue
    Detach NSA UE    ue_id=${NSA_UE_id}

    [Teardown]    Common Teardown

[1]TC8 Verification of Successful RFSP based Inactivity timer configuration during Bearer Context Modification after rfspInactivityTimer change
    Change activitynotificationlevelSA value    value=drb
    Choose NRRFSP PROFILE by rfsp value    ue_id=${SA_UE_id}    IndexToRFSP_value=${NRRFSP_PROFILE1_IndexToRFSP_value}
    Attach UE and Verify RFSP inactivitytimer in BearerContextModification
    ...    ue_id=${SA_UE_id}
    ...    cell_id=${SA_cell_id}
    ...    IndexToRFSP_value=${NRRFSP_PROFILE1_IndexToRFSP_value}
    ...    inactivity_timer_value=${NRRFSP_PROFILE1_inactivity_timer_value}
    ...    new_inactivity_timer_value=${NRRFSP_new_inactivity_timer_value}
    ...    profile_id=1
    ...    notification_level=drb
    Detach SA UE    ue_id=${SA_UE_id}
    Choose NRRFSP PROFILE by rfsp value    ue_id=${SA_UE_id}    IndexToRFSP_value=${NRRFSP_PROFILE2_IndexToRFSP_value}
    Attach UE and Verify RFSP inactivitytimer in BearerContextModification
    ...    ue_id=${SA_UE_id}
    ...    cell_id=${SA_cell_id}
    ...    IndexToRFSP_value=${NRRFSP_PROFILE2_IndexToRFSP_value}
    ...    inactivity_timer_value=${NRRFSP_PROFILE2_inactivity_timer_value}
    ...    new_inactivity_timer_value=${NRRFSP_new_inactivity_timer_value}
    ...    profile_id=2
    ...    notification_level=drb
    Detach SA UE    ue_id=${SA_UE_id}

    Change activitynotificationlevelSA value    value=ue
    Choose NRRFSP PROFILE by rfsp value    ue_id=${SA_UE_id}    IndexToRFSP_value=${NRRFSP_PROFILE1_IndexToRFSP_value}
    Attach UE and Verify RFSP inactivitytimer in BearerContextModification
    ...    ue_id=${SA_UE_id}
    ...    cell_id=${SA_cell_id}
    ...    IndexToRFSP_value=${NRRFSP_PROFILE1_IndexToRFSP_value}
    ...    inactivity_timer_value=${NRRFSP_PROFILE1_inactivity_timer_value}
    ...    new_inactivity_timer_value=${NRRFSP_new_inactivity_timer_value}
    ...    profile_id=1
    ...    notification_level=ue
    Detach SA UE    ue_id=${SA_UE_id}
    Choose NRRFSP PROFILE by rfsp value    ue_id=${SA_UE_id}    IndexToRFSP_value=${NRRFSP_PROFILE2_IndexToRFSP_value}
    Attach UE and Verify RFSP inactivitytimer in BearerContextModification
    ...    ue_id=${SA_UE_id}
    ...    cell_id=${SA_cell_id}
    ...    IndexToRFSP_value=${NRRFSP_PROFILE2_IndexToRFSP_value}
    ...    inactivity_timer_value=${NRRFSP_PROFILE2_inactivity_timer_value}
    ...    new_inactivity_timer_value=${NRRFSP_new_inactivity_timer_value}
    ...    profile_id=2
    ...    notification_level=ue
    Detach SA UE    ue_id=${SA_UE_id}

    [Teardown]    Common Teardown
