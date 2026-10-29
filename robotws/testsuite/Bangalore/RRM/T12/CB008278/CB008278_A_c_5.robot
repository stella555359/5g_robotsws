# Copyright (c) 2020 Nokia. All rights reserved.


*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Adarsha
...             :contact  : adarsha.p_hegde@nokia.com
...             This TC is to validate L3 call with Beamforming enabled in 10Mhz Channel Bandwidth.

Library     taf.wts.runner          WITH NAME      wtsrunner
Resource        resources/Keywords/CB008278_Keywords.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Suite TearDown for CB008278

*** Variables ***
${UE_ID}    1
${LOG_DIR}                     /home/ute/logs

*** Test Cases ***
[1][1.0] CB008278-A-c_5 Beamforming on TDD cell with 10MHz bandwidth
    [Documentation]      Beamforming on TDD cell with 10MHz bandwidth
    [Setup]    Prepare for test Case - CB008278_AC5
    wtsrunner.beam_control_testmode_nr  profile_id=1    ueBeamIndexInitial=0,1,2,3,4,5,6,7  ssbeam_bestbeam=0
    ...     ssbeam_rsrp_best=-44    ssbeam_rsrp_avg=-50
    wtsrunner.ue_testmode_set_nr    id=1    testmode=beam_control   action=activate     profile_id=1    beamaction=attach
    Make SA call
    Sleep   30s
    Stop Data Traffic for SA    ${UE_ID}
    [Teardown]     Run Keyword And Ignore Error      Common test case tear down LO AP LO


