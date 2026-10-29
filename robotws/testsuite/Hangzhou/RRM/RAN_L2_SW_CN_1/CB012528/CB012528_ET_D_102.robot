*** Settings ***
Documentation    ...
#Suite Setup       Common Suite Setup
#Test Setup        Common Test Setup
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags     CLOUD_5G_I_BOO_AP_LOOO    CB012528    CRT    RAN_5G    RAN_5G_TDD
#...            Owner_peafu    VRF4_11    SBTS00
#Resource       resources/CB012528_resource.robot
#
#*** Variables ***
#${SCF_PATH}              ${CURDIR}/Config/
#${FULL_SCFC}             SCF_12528_D102.xml
#${IPHY_XML}              ${CURDIR}/Config/wts/iphy_12528_D102.xml
#${LOCAL_WTS_DIR}         ${CURDIR}/Config/wts/
#${WTS_AP_XML}            airphone.xml
#${WTS_CFG}               12528_D102_3F_2T_nonCA.lua
#${SWCONFIG_PARAM_GNB}    0x58083A=0;0x580464=64
#${UE_ID_CELL1_CA}        1
#${UE_ID_CELL12_CA}       441
#${UE_ID_CELL1_NONCA}     481
#${UE_ID_CELL12_NOACA}    491
#@{5CC_DL_TPUT_LIST}      3    3    3    3    3
#&{XML_PARAMS_DICT}          actTwoCoresL2DeploymentFddFr1=false    actDPAOverloadControl=false
#&{VENDOR_CHANGE_DICT}       list_name=${EMPTY}
#...                         ref_value=${EMPTY}    params_dict=${XML_PARAMS_DICT}
#@{VENDOR_CHANGE_LIST}       ${VENDOR_CHANGE_DICT}
#
#*** Test Cases ***
#CB012528_ET_D_102_40_CAUE_10_NonCAUE_ABIO_Legacy_Deployment
#    Workaroud For Multi UE Of Airphone
#    Multi UE Attach And Setup DL Traffic    ${UE_ID_CELL1_CA}    1    20    30
#    Multi UE Attach And Setup DL Traffic    ${UE_ID_CELL12_CA}    441    460    30
#    Multi UE Attach And Setup DL Traffic    ${UE_ID_CELL1_NONCA}    481    490    10
#    Multi UE Attach And Setup DL Traffic    ${UE_ID_CELL12_NOACA}    491    500    10
#    Wait Until Keyword Succeeds    2min    30s    Check CAUE Tput    ${UE_ID_CELL1_CA}    1    20
#    Wait Until Keyword Succeeds    2min    30s    Check CAUE Tput    ${UE_ID_CELL12_CA}    441    460
#    Wait Until Keyword Succeeds    2min    30s    Check NonCA UE Tput    ${UE_ID_CELL1_NONCA}    481    490
#    Wait Until Keyword Succeeds    2min    30s    Check NonCA UE Tput    ${UE_ID_CELL12_NOACA}    491    500
#    Capture Convert Format Ttitrace With Streaming Mode    1s    log_dir=${test_log_directory}/ttitrace/1
#    Run Keyword And Ignore Error    Rename DL TTItrace CSV
#    CUDU L2 Check DTXNACK Rate    log_id=1    expect_rate=0.1
#    #CUDU L2 Check UL DTXCRC Rate    log_id=1    expect_rate=0.02
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}    swconfig_param=${SWCONFIG_PARAM_GNB}
#	...    vendor_change_list=${VENDOR_CHANGE_LIST}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#
#Workaroud For Multi UE Of Airphone
#    ${cmd}    Set Variable    uec_l2_testmode_params fixed_csi_report=true
#    ute_wtssim.Execute Egate Command    ${cmd}
#    Sleep    1s    Reason=wait for cmd execution
#
#Check CAUE Tput
#    [Arguments]    ${UE_ID}    ${start_ue}    ${end_ue}
#    FOR    ${UE_ID}    IN RANGE    ${start_ue}    ${end_ue}+1
#    Wait Until Keyword Succeeds    1min    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_ID}    ${5CC_DL_TPUT_LIST}    5
#    END
#
#Check NonCA UE Tput
#    [Arguments]    ${UE_ID}    ${start_ue}    ${end_ue}
#    FOR    ${UE_ID}    IN RANGE    ${start_ue}    ${end_ue}+1
#    Wait Until Keyword Succeeds    1min    5s    SA Check Average Traffic Bigger Than Target EGate    ${UE_ID}    1    dl    4
#    END
#
#Multi UE Attach And Setup DL Traffic
#    [Arguments]    ${UE_ID}    ${start_ue_num}    ${end_ue_num}    ${dl_mbps}=10
#    FOR    ${UE_ID}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
#    Single Ue Attach    ${ue_id}
#    Sleep    3s    Reason=wait for PDU session completed
#    END
#    FOR    ${UE_ID}    IN RANGE    ${start_ue_num}    ${end_ue_num}+1
#    SA Start DL Traffic Internal    ${UE_ID}    pdu_id=1    mbps=${dl_mbps}
#    Sleep    3s    Reason=wait for traffic send out
#    END
#
#Single Ue Attach
#    [Arguments]    ${ue_id}    ${pdu_id}=1
#    Log To Console    UE${ue_id} Start Attach...
#    SA 5G Attach    ue_id=${ue_id}
#    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${pdu_id}
#    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1
#    ...    pass_regexp=setup/reestablishment complete    timeout=3minutes
#
#SA Check Average Traffic Bigger Than Target EGate
#    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${tp_rate}
#    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir\=${dir}
#    ...    pass_regexp=Average packet interval    timeout=150
#    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
#    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
#    ${mavg}    Evaluate    ${avg}*0.000001
#    Log To Console    \n The average ${dir} tput is: ${mavg}M \n
#    ${tp_delta}    Evaluate    ${avg}*0.000001-${tp_rate}
#    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
#    Log To Console    The TPUT is bigger than target: ${tp_rate}M \n
#
#Rename DL TTItrace CSV
#    ${csvdir}    Set Variable    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    OperatingSystem.Run    cp ${csvdir}/output_dl.0.csv ${csvdir}/output_dl.csv
