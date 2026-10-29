*** Settings ***
Documentation    1348 A14 TC Resource file
...              Author : Annie Wong          annie.wong@nokia.com
...                     : Florence Thepot     florence.thepot@nokia.com
...                     : Pape Diallo         pape.diallo@nokia.com
...         Last update : 11.06.2021

Resource      ../../resources/sg_radio_perf/robot/Keywords_Attenuation.robot
Resource      ../../resources/sg_radio_perf/robot/preconditions.robot
Resource      ../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource      ../../resources/sg_radio_perf/robot/Commissioning.robot
Resource      keywords_1348_common.robot




*** Variables ***
${scf_file_1348}            /home/localuser/TafProject/robotws5g/config_CV112_updated/scf_CV112_1348_7827_with_VLAN_4089_V4.xml
${input_channels}           0,1
${input_channels_ports}     0,1,2,3,4,5,6,7
${signals_min}              300,300
${attenuator_id}            0
${verify}                   True
${signals_max}              935,935
${signals_max_ports}        935,935,935,935,935,935,935,935
${btsName1348}              CV112_SA_2ABIO_AEQN_AEHC_eCPRI_MIMO4x4_Paris_Saclay_1348_7827_V4

*** Keywords ***
7827_1348_A_14_Suite_Setup
    [Arguments]       ${gnb_id}=${0}
    # this is mandatory : retrieve testsuite variables for gNB
    Setup Testline Suite Variables
    Set Attenuation Channels   input_channels=${input_channels_ports}
    ...    signals=${signals_max_ports}   attenuator_id=${attenuator_id}   verify=${verify}
    TestSuite Basic PreConditions     archive_gnb_config=${True}   archive_type=scf   gnb=${gnb_id}
    keywords_1348_common.Check gNB and Get reportingIntervalPm Value           gNB=${gnb_id}
    # prepare scf
    log     Prepare SCF:              console=${DEBUG_MODE_CONSOLE}

    # check btsName
    get btsNameScf from SCF

    Log         btsNameSource=${btsNameScf}                console=${DEBUG_MODE_CONSOLE}
    Log         btsNameTarget=${btsName1348}                console=${DEBUG_MODE_CONSOLE}

    Keywords_gNB.Create cOAM Session with alias                gnb_id=${gnb_id}        alias=coam_admin

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log             Begin : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}

    Run keyword if  '${btsName1348}' != '${btsNameScf}'         Do Commissioning            ${scf_file_1348}          gNB=${gnb_id}

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log             End : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}
    Set Attenuation Channels   input_channels=${input_channels}   signals=${signals_min}   attenuator_id=${attenuator_id}   verify=${verify}

 #   Recommission actPrachMultiplexing CELL1                    value=true               gNB=${gnb_id}     connection=coam_admin
 #   Keywords_gNB.Check gNB State                               gNB=${gnb_id}
 #    Recommission actFdmScheduling                             value=true               gNB=${gnb_id}     connection=coam_admin
 #    Keywords_gNB.Check gNB State                              gNB=${gnb_id}
 #    Recommission actBeamforming CELL1                         value=true               gNB=${gnb_id}     connection=coam_admin
 #    Keywords_gNB.Check gNB State                              gNB=${gnb_id}
 #    Recommission msg1FrequencyStart CELL1                     value=30                      gNB=${gnb_id}     connection=coam_admin
 #    Keywords_gNB.Check gNB State                              gNB=${gnb_id}
 #    Recommission actFdmEnhancedScheduling                     value=true                   gNB=${gnb_id}     connection=coam_admin
 #    Keywords_gNB.Check gNB State                              gNB=${gnb_id}
 #    Recommission pucchModeSelect CELL1                        value=longPucch         gNB=${gnb_id}     connection=coam_admin
 #    Keywords_gNB.Check gNB State                              gNB=${gnb_id}
 #    Recommission actPerCsiReportBundlingTddFr1 CELL1            value=true                  gNB=${gnb_id}     connection=coam_admin
 #    Keywords_gNB.Check gNB State                              gNB=${gnb_id}
 #  Recommission dlDMRSAdditionalPosition CELL1              value=Automatic        gNB=${gnb_id}     connection=coam_admin
 #  Keywords_gNB.Check gNB State
 #  Recommission ulDMRSAdditionalPosition CELL1             value=Automatic       gNB=${gnb_id}     connection=coam_admin
 #  Keywords_gNB.Check gNB State
 #  Recommission gscnOrSsPbchArfcn CELL1                        value=7783              gNB=${gnb_id}     connection=coam_admin
 #  Keywords_gNB.Check gNB State
 #
 #  Recommission nrarfcn CELL1                                   value=630000           gNB=${gnb_id}     connection=coam_admin
 #  Keywords_gNB.Check gNB State
 #
 #
 #  Recommission prachConfigurationIndex148 CELL1                gNB=${gnb_id}     connection=coam_admin
 #  Keywords_gNB.Check gNB State
 # save modified scf
 #   admin.get_current_scf_file      ${OUTPUTDIR}   scf_modified.xml   connection=coam_admin


7827_1348_A_14_Suite_Teardown
    [Arguments]       ${gnb_id}=${0}
    Set Attenuation Channels    input_channels=${input_channels}   signals=${signals_max}   attenuator_id=${attenuator_id}   verify=${verify}
    TestSuite Basic Teardown     restore_gnb_config=${False}     restore_type=scf      gnb=${gnb_id}
    Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin


5GC001348_7827_TC_A14
    [Documentation]    The purpose of this test is to establish SA call with full UL Thr in good radio condition with
    ...                prachConfigurationIndex=98 ; Bandwidth 100 MHz ; UL to DL Data slot ratio: 1/4 FR1 1208 ;
    ...                framestructure=semiStatic. Full granularity is M55308C10004 & M55308C10002 is about 32580000:
    ...                (7 x (273) PRB + 1 x (261) PRB [273 -12 RACH PRBs] for 20 ms ; for 5 mn = 32580000).
    ...                BF on 2 BeamSet + 7827 (longPUCCH) => M55308C10004=29403195 & M55308C10002=29173240
    ...                 msg1frequencyStart at 30 ==> 7 X 247 + 1 X216 sur 20 ms so for 5min 29 175 000
    ...                 possible 2% loss can be expected = about M55308C10004=28 591 500
    ...                Test Steps Executions:
    ...                - Retrieve the PM reports from Suite Setup, where the following value (expected value)
    ...                  should be greater than 0.
    ...                  possible 2% loss can be expected = about 31928400
    [Arguments]       ${gnb_id}=${0}    ${ue_id}=${0}
    #  test suite variables ${PM_FILENAME} and ${PM_PATH} will be set :
    keywords_1348_common.1348 A14 A20 with call and UL traffic and Collect Pm in TestSuiteDir
    ...           tput_ul=${ul_throughput}
    ...           duration=${ul_time_s}
    ...           gNB=${gnb_id}
    ...           ue_index=${ue_id}
    ...           ue_capabilities=${ue_capability}

    # This counter provides the number of available PRB for PUSCH
    ${pi_M55308C10004}=     pm_analyze.get_pi_value_for_one_cell_from_file
    ...             pi_dir=${PM_PATH}      pi_name=M55308C10004      file_name=${PM_FILENAME}    cell=1
    log      M55308C10004=${pi_M55308C10004}       console=${DEBUG_MODE_CONSOLE}

    # This counter provides the number of used PRBs for PUSCH
    ${pi_M55308C10002}=     pm_analyze.get_pi_value_for_one_cell_from_file
    ...             pi_dir=${PM_PATH}      pi_name=M55308C10002      file_name=${PM_FILENAME}    cell=1
    log      M55308C10002=${pi_M55308C10002}       console=${DEBUG_MODE_CONSOLE}

    #should be true     ${pi_M55308C10004}>32580000
    should be true     ${pi_M55308C10004}>28591500
    # should be true     ${pi_M55308C10002}>32580000
    should be true     ${pi_M55308C10002}>28591500
