*** Settings ***
Library    taf.ul.gnb.bip.collection   WITH NAME   bip_collection
Library    Collections

Documentation
...    This file contains keywords used for testing Feature CB013206 on Cloud RINLINE.

*** Keywords ***
Enable In Session Counters And Set Pmqap Profiles
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/delta_set_X2DataFwdGuard_to_10.json
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/delta_enable_miNrX2ccNrpmqap.json
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/delta_PMQAP_6_9.json

Set X2datafwdguard To 10
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/delta_set_X2DataFwdGuard_to_10.json

Enable Minrx2ccnrpmqap
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/delta_enable_miNrX2ccNrpmqap.json

Enable Counters And Profiles
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/delta_PMQAP_6_9.json

Start Data Traffic For Nsa Ue
    [Arguments]    ${ue_id}    ${bearer}    ${direction}    ${mbps}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} id=${bearer} dir=${direction} mbps=${mbps}

Wait For Normal Ue Release Initiated By MenB
    [Arguments]   ${ue_id}
    Execute Egate Command    cmd=enb_ue_dc_release ue=${ue_id} by=enb cause=RN_user_inactivity

Wait For Abnormal Ue Release Initiated By MenB
    [Arguments]   ${ue_id}
    Execute Egate Command    cmd=enb_ue_dc_release ue=${ue_id} by=enb cause=RN_CauseRadioNetwork_unspecified

Perform Abnormal Releases Initiated By Sgnb
    Execute Egate Command    cmd=ue_dc_rlf ue=11 failure_type=scg_reconfig_failure