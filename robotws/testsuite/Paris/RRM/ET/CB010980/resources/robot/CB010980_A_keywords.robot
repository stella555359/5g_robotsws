*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB010980 step A
...
...               Test Case Scenario author   : yann.ah.herve@nokia.com
...               Test Case Scenario contact  : yann.ah.herve@nokia.com
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 18-September-2025
...               Last Modified by            :
...               Modification:
...                       18-September-2025    | Creation
...                       29-October-2025      | Fix KW name

Library             taf.sbts.oam.coam.admin             WITH NAME      sbts_coam
Library            ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME     coam_parameter

Resource          ../../../../../resources/SWENG/robot/Connect.robot
Resource          ../../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../../../resources/SWENG/robot/KPIs.robot



*** Variables ***

${gnb_alias}                         gnb_under_test

${delta_scf_TC_A_007_Step_1}         testsuite/Paris/RRM/ET/CB010980/resources/config/Delta_Configuration_scf_TC_A_007_Init.json
${delta_scf_TC_A_007_Step_2}         testsuite/Paris/RRM/ET/CB010980/resources/config/Delta_Configuration_scf_TC_A_007_miNrNGSctpStatistics.json

${TC_A_007_PM_constraints_Step_1}    testsuite/Paris/RRM/ET/CB010980/resources/config/TC_A_B2_TC4_PM_Constraints_Step_1.csv
${TC_A_007_PM_constraints_Step_2}    testsuite/Paris/RRM/ET/CB010980/resources/config/TC_A_B2_TC4_PM_Constraints_Step_2.csv

${nbAttachDetachLoop}                15
${nbLockUnlock}                      8
${gp_duration}                       300

${trcColor}                          Evaluate    "${CYAN}"
${defColor}                          Evaluate    "${NORMAL}"
${OkColor}                           Evaluate    "${GREEN}"


*** Keywords ***

CB010980 Test Teardown

   # Disable traffic control drop mode before leaving test
    SSH Connect and Cmd     command=sudo tc qdisc del dev eth3 root netem            host=${HOST_EPCSIM}

    Test Teardown

CB010980_Update_SCF
    [Documentation]               Dedicated KW to apply a delta commissioning file.
    ...                           It performs delta commissioning and waits until gNB is up again
    ...                           (in case RAT reset is needed for example)
    [Arguments]                   ${delta_file}

    # Open connection towards cOAM
    sbts_coam.connect_to          name=${gnb_alias}

    # Apply delta scf
    coam_parameter.perform_scf_delta_commission      delta_file=${delta_file}    connection=${gnb_alias}
    ...                                              timeout=300                 skip_parameter_relation_errors=True

    OAM wait available

    sbts_coam.teardown            connection=${gnb_alias}

Perform UE Registers In Loop
   [Documentation]              Perfom UE register/deregister in loop to send UE related CP messages over NG

    FOR        ${i}      IN RANGE        0        ${nbAttachDetachLoop}
        UE Register             ue=${BASIC_UE_SA.ue}
        Launch PDU Session      ue=${BASIC_UE_SA.ue}    pdu=${BASIC_UE_SA.pdu}    gw=${BASIC_UE_SA.ue}
        Traced Sleep            5 seconds
        UE Deregister           id=${BASIC_UE_SA.ue}
        Traced Sleep            5 seconds
    END

CB010980_A_PMO_1_TC_NG-C_Resent_PM

    [Documentation]     The purpose of this test case is to check that PM counters related to the number of
    ...                 SCTP packets retransmitted over NG-C (SCTP_NG_CHRSNT) is consistent and well
    ...                 reported to webEM. The Linux tc (traffic control) command is used to drop SCTP packets
    ...                 randomly and PM are checked against reference values.

    Init Sequence   "CB010980_A_PMO_NG-C"
    Dated Log New Line              ---> Starting gNB commissioning

    # As a first step miNrNGSctpStatistics are disabled
    Critical Step   CB010980_Update_SCF                 ${delta_scf_TC_A_007_Step_1}

    # Dated Log New Line              ---> Restart TL
    Critical Step   Restart TL
    Dated Log New Line              ---> WTS setup SA
    Critical Step   WTS Setup       shouldUseLua=${False}

    # In order to have the same KPIs/counters for every run, it's needed to start test step at the
    # beginning of the next PM period. So, the script wait for the beginning of the next GP to before starting
    # the test. This should allow to have the same KPIs over every runs.
    ${zoi}                      ZOI Start                               gp=${gp_duration}
    ${zoi_end_remain}=          ZOI Remaining Sec                       ${zoi}
    ${start_loop_remaining}=    Evaluate                                ${zoi_end_remain} - ${gp_duration}
    Traced Sleep                ${start_loop_remaining} seconds         msg=Waiting ${start_loop_remaining} seconds before starting next step

    # Add packets loss over NG link by using tc (Traffic Control) command to trigger SCTP retransmissions
    Critical Step               SSH Connect and Cmd         command=sudo tc qdisc add dev eth3 root netem loss 20%
    ...                         host=${HOST_EPCSIM}

    # Step 1: SCTP PM reports off
    Critical Step               Perform UE Registers In Loop

    Dated Log                   ${trcColor}=== Waiting for end of ZOI ${defColor}
    ZOI Wait End                zoi=${zoi}

    # KPIs and counters checks
    ${pm_path}      Counters.Collect PM files from BTS    ${LOG_PATH}/PM
    Run Keyword And Expect Error    *Some constraints failed: ?3, 0, 0, 0, 0, 0, 0, 0, 0?
    ...                             KPI Evaluate    pmFile=${pm_path}
    ...                             constraintsFile=${TC_A_007_PM_constraints_Step_1}
    ...                             failOnError=${True}

    # SCTP PM reports are now enabled
    Critical Step   CB010980_Update_SCF                 ${delta_scf_TC_A_007_Step_2}

    ${zoi}                      ZOI Start                               gp=${gp_duration}
    ${zoi_end_remain}=          ZOI Remaining Sec                       ${zoi}
    ${start_loop_remaining}=    Evaluate                                ${zoi_end_remain} - ${gp_duration}
    Traced Sleep                ${start_loop_remaining} seconds         msg=Waiting ${start_loop_remaining} seconds before starting next step

    # Step 2: Attach/Detach
    Critical Step   Perform UE Registers In Loop

    Dated Log                   ${trcColor}=== Waiting for end of ZOI ${defColor}
    ZOI Wait End                zoi=${zoi}

    # KPIs and counters checks
    ${pm_path}      Counters.Collect PM files from BTS    ${LOG_PATH}/PM
    KPI Evaluate    pmFile=${pm_path}
    ...             constraintsFile=${TC_A_007_PM_constraints_Step_2}
    ...             failOnError=${True}