*** Settings ***
Documentation    1348 A14 TC Resource file
...              Author : Annie Wong          annie.wong@nokia.com
...                     : Florence Thepot     florence.thepot@nokia.com
...                     : Pape Diallo         pape.diallo@nokia.com
...         Last update : 11.06.2021

Resource      ../../../resources/sg_radio_perf/robot/Keywords_Attenuation.robot
Resource      ../../../resources/sg_radio_perf/robot/preconditions.robot
Resource      ../../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource      ../../../resources/sg_radio_perf/robot/Commissioning.robot
Resource      keywords_5GCounters_common.robot


*** Variables ***
${scf_file_1348}             ${CURDIR}/../../scf/SCF_CV112_ASOE_CB012535_FS1116_3ms_V1.xml
${input_channels}           0,1
${input_channels_ports}     0,1,2,3,4,5,6,7
${signals_min}              350,350
${attenuator_id}            0
${verify}                   True
${signals_max}              935,935
${signals_max_ports}        935,935,935,935,935,935,935,935
${btsName1348}              CV112_SA_ASOE_AEQN_AEHC_CB012535_V1
${nrcellid_1}		    1
#@{l1l2_value}               ${l1l2_M55301C01029}   ${l1l2_M55301C01030}   ${l1l2_M55301C01031}

*** Keywords ***
5GCounters_Suite_Setup
    [Arguments]       ${gnb_id}=${0}   ${direction}=DL
    # this is mandatory : retrieve testsuite variables for gNB
    Setup Testline Suite Variables
    Set Attenuation Channels   input_channels=${input_channels_ports}
    ...    signals=${signals_max_ports}   attenuator_id=${attenuator_id}   verify=${verify}
    TestSuite Basic PreConditions     archive_gnb_config=${True}   archive_type=scf   gnb=${gnb_id}
    keywords_5GCounters_common.Check gNB and Get reportingIntervalPm Value           gNB=${gnb_id}
    # prepare scf
    log     Prepare SCF:              console=${DEBUG_MODE_CONSOLE}

    # check btsName
    get btsNameScf from SCF

    ${substr} =	Get Substring    ${btsNameScf}    0    4
    ${nrcellid_1}=    Set Variable If    'TL327' == ${substr}    301
    Set Suite Variable    ${nrcellid_1}

    keywords_5GCounters_common.get dlModulation from SCF           gNB=${gnb_id}    NRCELL=${nrcellid_1}
    Log         btsNameSource=${btsNameScf}                console=${DEBUG_MODE_CONSOLE}
    Log         btsNameTarget=${btsName1348}                console=${DEBUG_MODE_CONSOLE}

    Keywords_gNB.Create cOAM Session with alias                gnb_id=${gnb_id}        alias=coam_admin

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log             Begin : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}
    Run keyword if  '${btsName1348}' != '${btsNameScf}'         Do Commissioning            ${scf_file_1348}          gNB=${gnb_id}

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log             End : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}

    Set Attenuation Channels   input_channels=${input_channels}   signals=${signals_min}   attenuator_id=${attenuator_id}   verify=${verify}
    Run keyword if  '${direction}' == 'DL'    5GCounters_c with call and DL traffic and L1L2 traces and Collect Pm in TestSuiteDir
    Run keyword if  '${direction}' == 'UL'    5GCounters_b with call and UL traffic and L1L2 traces and Collect Pm in TestSuiteDir


#todo rename 5GCounters_Create_Suite_Variables ?

Create Batch Suite Variables
    [Arguments]       ${l1l2_prefix}   ${from}=0    ${to}=32

    FOR  ${i}  IN RANGE  ${from}    ${to}
	#add leading zero 1 becom 001
        ${i}=  Evaluate        '${i}'.zfill(3)
        ${l1l2_name} =  Catenate  SEPARATOR=  ${l1l2_prefix}  ${i}
        Set Suite Variable  ${${l1l2_name}}    0
    END


Add Range To Dict
    [Arguments]       ${l1l2_dict}    ${prefix}   ${from}=0    ${to}=32

    FOR  ${i}  IN RANGE  ${from}    ${to}
        ${i}=  Evaluate    '${i}'.zfill(3)
        ${l1l2_name} =  Catenate    SEPARATOR=  ${prefix}  ${i}
 	Set To Dictionary    ${l1l2_dict}    ${l1l2_name}     ${${l1l2_name}}
    END


Create Suite Variables
    #M55301C01000 to M55301C01031
    Create Batch Suite Variables    M55301C01    0    32

    #M55301C17000 to M55301C17031
    Create Batch Suite Variables    M55301C17    0    32

    #l1l2_M55303C05000 to l1l2_M55303C05025
    Create Batch Suite Variables    M55303C05    0    26

    Set Suite Variable    ${M55303C06001}   0
    Set Suite Variable    ${M55303C06002}   0

    Set Suite Variable    ${M55308C00005}   0
    Set Suite Variable    ${M55308C00006}   0
    Set Suite Variable    ${M55308C00015}   0
    Set Suite Variable    ${M55308C00016}   0

    #M55308C00123 to M55308C00139
    Create Batch Suite Variables    M55308C00    123    139

    Set Suite Variable    ${M55308C10001}   0
    Set Suite Variable    ${M55308C10002}   0

    Set Suite Variable    ${M55308CRD54015}   0
    Set Suite Variable    ${M55308CRD54016}   0
    Set Suite Variable    ${M55308CRD54017}   0


5GCounters_Suite_Setup_youssef
    [Arguments]       ${gnb_id}=${0}   ${direction}=DL
    Setup Testline Suite Variables
    Create Suite Variables

    TestSuite Basic PreConditions    archive_gnb_config=${True}    archive_type=scf    gnb=${gnb_id}
    keywords_5GCounters_common.Check gNB and Get reportingIntervalPm Value    gNB=${gnb_id}

    get btsNameScf from SCF

    ${substr} =	Get Substring    ${btsNameScf}    0    5
    ${nrcellid_1}=    Set Variable If    'TL327' == '${substr}'    301
    ${btsNameScf}=    Set Variable If    'TL327' == '${substr}'    ${btsName1348}
    Set Suite Variable    ${nrcellid_1}

    keywords_5GCounters_common.get dlModulation from SCF	gNB=${gnb_id}        NRCELL=${nrcellid_1}
    Keywords_gNB.Create cOAM Session with alias                	gnb_id=${gnb_id}     alias=coam_admin

    ${timeStamp}=	DateTime.Get current date	exclude_millis=True		result_format=%Y:%m:%d %H:%M:%S
    Log             	Begin : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}

    #Run keyword if  	'${btsName1348}' != '${btsNameScf}'	Do Commissioning    ${scf_file_1348}    gNB=${gnb_id}

    ${timeStamp}=    DateTime.Get current date    exclude_millis=True    result_format=%Y:%m:%d %H:%M:%S
    Log             End : ${timeStamp}            console=${DEBUG_MODE_CONSOLE}

    Run keyword if  '${direction}' == 'DL'    5GCounters_c with call and DL traffic and L1L2 traces and Collect Pm in TestSuiteDir
    Run keyword if  '${direction}' == 'UL'    5GCounters_b with call and UL traffic and L1L2 traces and Collect Pm in TestSuiteDir


5GCounters_Suite_Teardown
    [Arguments]       ${gnb_id}=${0}
    #Set Attenuation Channels    input_channels=${input_channels}   signals=${signals_max}   attenuator_id=${attenuator_id}   verify=${verify}
    TestSuite Basic Teardown     restore_gnb_config=${False}     restore_type=scf      gnb=${gnb_id}
    Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin


5GCounters_TC_Check_PI_vs_l1l2
    [Arguments]      ${counter}   ${gnb_id}=${0}    ${ue_id}=${0}   ${min_value}=${False}
    ${pi_value}=   pm_analyze.get_pi_value_for_one_cell_from_file
    ...              pi_dir=${PM_PATH}      pi_name=${counter}     file_name=${PM_FILENAME}    cell=301

    #bypass robocop pipeline
    ${gnb_id}    Set Variable    ${gnb_id}
    ${ue_id}    Set Variable    ${ue_id}

    Log To Console    Checking : ${counter}...
    Log    ${l1l2_M55301xx}    console=${DEBUG_MODE_CONSOLE}

    #set to Dictionary   ${pi_dict}   ${counter}   ${pi_value}
    ${l1l2_value}   Get From Dictionary   ${l1l2_M55301xx}   ${counter}
    log    ${counter}=${pi_value} - Value extracted in L1L2=${l1l2_value}   console=${DEBUG_MODE_CONSOLE}
    Run Keyword If     '${min_value}'!='${False}'   should be true   ${pi_value} > ${min_value}
    should be true     abs(${pi_value}-${l1l2_value})<=0.02*${pi_value}


