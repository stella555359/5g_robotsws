*** Settings ***
Force Tags      CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#...   PY27
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Resource         ./CB008200_Resource.robot
Resource         ../resources/robot/common_log_collection.robot
Library          ./resources/python/PM_Counter_Verify.py


Suite Setup         Run keywords     Suite setup from scratch
#Suite Setup         Run keywords      Prepare TL with all config files
...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                         scfc_filename=Configuration_scf_c3_c4.xml
#...                 AND     Update GSCN in AP Iphy Xml     gscn=1582
#...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
#...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_FDD_VONR_MultiUE_C3_C4.json
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
#...                 AND    Configure UTE ETH3 IPs

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Stop Syslog CPRT BIP Logs       #Enable here if issue reports
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Test Teardown        Link SCOUT SCF to Configuration ID for Reporting

Documentation
...
...             author:            Jayagovinda K S, jayagovinda.1.ks@nokia.com
...             maintainer:        Jayagovinda K S, jayagovinda.1.ks@nokia.com
...
...             INTRODUCTION:      Feature provides counters for measuring VoNR statistics for clear understanding of the performance of Voice over
...              NR calls in the network.The feature provides counters related to Retainability, Accessibility , Utilzation and VoNR Quality
...             The feature also provides some counters at PMQAP level.
...             TEST SET NAME:    1)CB008200-C_3_Measuring_VoNR_DL_Muteness_DL_INACT_VONR_BIN_XX
...                                The purpose of this test is to verify BIN level counter to measure inactivity or muteness in DL for VoNR call.
...                               2)CB008200-C_4_Measuring_VoNR_UL_Muteness_ UL_INACT_VONR_BIN_XX
...                                The purpose of this test is to verify BIN level counter to measure inactivity or muteness in UL for VoNR call.

...             TESTING SPLIT:     See CB008200 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008200 CFAM
...             Requirement ID:    5G_PM_505


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_1CC_fdd_multi_ue_vonr.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${qfi_id}    1
${Q_O_ADD}      1
${RTP_COD}      1
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${1}
${ue_id}         ${1}
#${SCFC}         ${CURDIR}/config/SCF/Configuration_scf_c3_c4.xml
${IPHY_FILE}    ${CURDIR}/config/SCF/iphy_c3_c4.xml
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${BIP_SCRIPT_PATH}         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/config/script/
${port}                    22

*** Test Cases ***
[1]CB008200-C_3_Measuring_VoNR_DL_Muteness_DL_INACT_VONR_BIN_XX

#Starting CPRT Trace Capturing
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...

	Wait until the next Measurement Period starts  additional_time=${20}
    VoNR Call Setup and Counter Update from DL_INACT_BIN_01 to DL_INACT_BIN_04
    Wait until the current Measurement Period stops  additional_time=${30}
    CB008200_Resource.Collect PM Counters
    Get BIN counters and validate     M55350C09001    M55350C09002    M55350C09003    M55350C09004    ${10}

	Wait until the next Measurement Period starts  additional_time=${20}
    VoNR Call Setup and Counter Update from DL_INACT_BIN_05 to DL_INACT_BIN_08
    Wait until the current Measurement Period stops  additional_time=${30}
    CB008200_Resource.Collect PM Counters
    Get BIN counters and validate     M55350C09005    M55350C09006    M55350C09007    M55350C09008    ${10}

	Wait until the next Measurement Period starts  additional_time=${20}
    VoNR Call Setup and Counter Update from DL_INACT_BIN_09 to DL_INACT_BIN_10



[1]CB008200-C_4_Measuring_VoNR_UL_Muteness_UL_INACT_VONR_BIN_XX


    VoNR Call Setup and Counter Update from UL_INACT_BIN_01 to UL_INACT_BIN_02
    Wait until the current Measurement Period stops  additional_time=${30}
    CB008200_Resource.Collect PM Counters
    Get BIN counters and validate     M55350C10001    M55350C10002    ${10}
    Get BIN counters and validate     M55350C09009    M55350C09010    ${10}

	Wait until the next Measurement Period starts  additional_time=${20}
    VoNR Call Setup and Counter Update from UL_INACT_BIN_03 to UL_INACT_BIN_06
    Wait until the current Measurement Period stops  additional_time=${30}
    CB008200_Resource.Collect PM Counters
    Get BIN counters and validate     M55350C10003    M55350C10004    M55350C10005    M55350C10006    ${10}

    Wait until the next Measurement Period starts  additional_time=${20}
    VoNR Call Setup and Counter Update from UL_INACT_BIN_07 to UL_INACT_BIN_10
    Wait until the current Measurement Period stops  additional_time=${30}
    CB008200_Resource.Collect PM Counters
    Get BIN counters and validate    M55350C10007    M55350C10008    M55350C10009    M55350C10010    ${10}


*** Keywords ***

Modify IPHY File And Send to Airphone Custom
    [Arguments]    ${iphy_path}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom   ${iphy_path}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
    ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
    Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    END
    Send IPHY XML To Airphone custom    ${iphy_path}

Get RRU Type From Local IPHY XML Custom
    [Arguments]    ${iphy_path}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${x}  Set Variable  <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>\\n\\s+(?=<\\/RE>)
    @{RRU_type_for_version}    String.Get Regexp Matches    ${content}    ${x}    RRU_type    Ecpri_tag
    @{RRU_type_list}    String.Get Regexp Matches    ${content}    ${x}    RRU_type
    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list[0]}
    Log To Console   RRU Type List from local iphy.xml: ${RRU_type_list}
     Log To Console    RRU Type from local iphy.xml: ${RRU_TYPE}
    [Return]    @{RRU_type_for_version}

Get RRU Version From TargetBD File Custom
    [Arguments]    ${RRU_type}    ${save_dir}
    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
    ...    "${RRU_type[0]}"=="AEUB"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AHLOA"    ${RRU_type[0]}
    ...    "${RRU_type[1]}"=="ecpri"    ${RRU_type[0]}_E1
    ...    ${RRU_type[0]}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
    [Return]    @{RRU_Version}[0]

Modify RRU Version Of IPHY XML Custom
    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${bldVersion}=    String.Get Regexp Matches    ${content}
    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
    ...    bldVersion
    Log Many    ${bldVersion[0]}    ${RRU_Version}
    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
    Log To Console    ${new_content}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}


Send IPHY XML To Airphone custom
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -f /ffs/run/simmode/*.xml
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
    Should Be Equal As Integers    ${rc}    0
    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
    Should Be Equal As Integers    ${rc}    0

