*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

*** Variables ***
${beam_1}=    SEPARATOR=
...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5,6,7
...    ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
${beam_2}=    SEPARATOR=
...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5,6,7
...    ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
${beam_3}=    SEPARATOR=
...    beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5,6,7
...    ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125
${beam_4}=    SEPARATOR=
...    beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5,6,7
...    ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120
${beam_5}=    SEPARATOR=
...    beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5,6,7
...    ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139
${beam_6}=    SEPARATOR=
...    beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4,6,7
...    ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70
${beam_7}=    SEPARATOR=
...    beam_control_testmode_nr profile_id=7 ueBeamIndexInitial=6,0,1,2,3,4,5,7
...    ssbeam_bestbeam=6 ssbeam_rsrp_best=-46 ssbeam_rsrp_avg=-100
${beam_8}=    SEPARATOR=
...    beam_control_testmode_nr profile_id=8 ueBeamIndexInitial=7,0,1,2,3,4,5,6
...    ssbeam_bestbeam=7 ssbeam_rsrp_best=-48 ssbeam_rsrp_avg=-100

*** Keywords ***
Prepare Beam Profiles
    Execute Egate Command
    ...    cmd=${beam_1}
    Execute Egate Command
    ...    cmd=${beam_2}
    Execute Egate Command
    ...    cmd=${beam_3}
    Execute Egate Command
    ...    cmd=${beam_4}
    Execute Egate Command
    ...    cmd=${beam_5}
    Execute Egate Command
    ...    cmd=${beam_6}
    Execute Egate Command
    ...    cmd=${beam_7}
    Execute Egate Command
    ...    cmd=${beam_8}



Create Cqi Profile
    Execute Egate Command
    ...    cmd=csi_override_testmode_nr profile_id=1 cqi_mode=oscillating cqi=1 cqi_min=1 cqi_max=7 cqi_step=1 cqi_period=3


Activate Cqi Profile
    [Arguments]    ${ue_id}    ${profile_id}
    Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=csi_override profile_id=${profile_id} action=activate


Create Bler Profile
    Execute Egate Command
    ...    cmd=bler_testmode_nr profile_id=1 dl_bler=150,50,20,10,10,10,10,10 ul_bler=150,50,20,10,10,10,10,10


Activate Bler Profile
    [Arguments]    ${ue_id}    ${profile_id}
    Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=bler profile_id=${profile_id} action=activate


Deactivate Bler Profile
    [Arguments]    ${ue_id}    ${profile_id}
    Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=bler profile_id=${profile_id} action=deactivate
