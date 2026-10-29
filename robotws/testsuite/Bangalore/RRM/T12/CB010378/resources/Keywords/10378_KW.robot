*** Settings ***
Documentation      this keywords are specific to CB010378 feature.
Resource       ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource       ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource       ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource       ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${DeltaConfigDir}       ${CURDIR}/../../config/scf/
${APConfigDir}          ${CURDIR}/../../config/ap/
${AP_CONFIG_BASIC}     ${CURDIR}/../../config/wts
${TOPOLOGY}     CLOUD_5G_I_LO_AP_LO
${VLAN_ID}        ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}         MRBTS-1
${vlanif_distname}         ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1


*** Keywords ***
Commision scf and iphy
    [Documentation]    This keyword is used to upload required iphy and commissioning GNB with required scf
    [Arguments]    ${scf}=${EMPTY}       ${iphy}=${EMPTY}
    Run Keyword Unless    '${iphy}' == '${EMPTY}'    update_and_put_iphy_xml
    ...      input_filepath=${iphy}
    Run Keyword Unless    '${scf}' == '${EMPTY}'     tcom.Send Delta Commissioning
    ...    ${scf}

Prepare for test Case - CB0010378_B10_1
    ${Test_CaseNumber}     Set Variable    CB010378_B10
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    update_and_put_iphy_xml         ${APConfigDir}/3cell_iphy.xml
    Log to Console      \n Sending full commission
    Full Commission With SCF File For UTE      ${DeltaConfigDir}/B10_SCF.xml
    Sleep   180s
    Wait Coam Site to be Ready
    Start UTE WTS      CB010378_B1B2.cfg
    Basic Bring up

Enable ff for CB0010378_B10_1
    Create Basic Interface on UTE
    update_and_put_iphy_xml         ${APConfigDir}/3cell_iphy.xml
    Log to Console      \n Sending full commission
    Full Commission With SCF File For UTE      ${DeltaConfigDir}/B10_SCF.xml
    Sleep   180s
    Wait Coam Site to be Ready
    Start UTE WTS     CB010378_B1B2.cfg
    Basic Bring up

Disable ff for CB010378_B10_1
    Create Basic Interface on UTE
    update_and_put_iphy_xml         ${APConfigDir}/3cell_iphy.xml
    Log to Console      \n Sending full commission
    Full Commission With SCF File For UTE      ${DeltaConfigDir}/B10_FD_SCF.xml
    Sleep    180s
    Wait Coam Site to be Ready
    Start UTE WTS     basic_IADU_IEFR_SA77_78_extn77.cfg
    Basic Bring up

Prepare for test Case - CB0010378_B1B2_TC1
    ${Test_CaseNumber}     Set Variable    CB010378_B1B2
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    update_and_put_iphy_xml         ${APConfigDir}/3cell_iphy.xml
    Log to Console      \n Sending full commission
    Full Commission With SCF File For UTE      ${DeltaConfigDir}/B1B2_Robustness_SCF.xml
    Sleep    360s
    Wait Coam Site to be Ready
    Start UTE WTS      CB010378_B1B2.cfg
    Basic Bring up

Prepare for test Case - CB0010378_B5_TC1
    ${Test_CaseNumber}=     Set Variable    CB010378_B5
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    update_and_put_iphy_xml         ${APConfigDir}/3cell_iphy.xml
    Log to Console      \n Sending full commission
    Full Commission With SCF File For UTE      ${DeltaConfigDir}/B5_SCF.xml
    Sleep    180s
    Wait Coam Site to be Ready
    Start UTE WTS      CB010378_B1B2.cfg
    Basic Bring up

Prepare for test Case - CB0010378_B4_1
    ${Test_CaseNumber}=     Set Variable    CB010378_B4
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    update_and_put_iphy_xml         ${APConfigDir}/3cell_iphy.xml
    Log to Console      \nSending full commission
    Full Commission With SCF File For UTE      ${DeltaConfigDir}/B4_SCF.xml
    Sleep    180s
    Wait Coam Site to be Ready
    Start UTE WTS      CB010378_B1B2.cfg
    Basic Bring up

Prepare for test Case - CB0010378_B6_TC1
    ${Test_CaseNumber}=     Set Variable    CB010378_B6
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    update_and_put_iphy_xml         ${APConfigDir}/3cell_iphy.xml
    Log to Console      \nSending full commission
    Full Commission With SCF File For UTE      ${DeltaConfigDir}/B6_SCF.xml
    Sleep    180s
    Wait Coam Site to be Ready
    Start UTE WTS      B6.cfg
    Basic Bring up

Prepare for test Case - CB0010378_B9
    ${Test_CaseNumber}=     Set Variable    CB010378_B9
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Create Basic Interface on UTE
    update_and_put_iphy_xml         ${APConfigDir}/LO_AP_LO_Fdd_Tdd_iphy.xml
    Log to Console      \nSending full commission
    Full Commission With SCF File For UTE      ${DeltaConfigDir}/B9_SCF.xml
    Sleep    180s
    Wait Coam Site to be Ready
    Start UTE WTS      wts_cfg_Resel.cfg
    Basic Bring up

Common test case tear down
    Delete Basic Interface on UTE
    Collect Logs For The Test           ${Log_Path}
    update_and_put_iphy_xml         ${APConfigDir}/FromSetupIphy.xml
    Full Commission With SCF File For UTE      ${DeltaConfigDir}/FromSetupSCF.xml
    sleep   200s

Common test case tear down LO AP LO
    Delete Basic Interface on UTE
    Collect Logs For The Test           ${Log_Path}
    update_and_put_iphy_xml         ${APConfigDir}/LO_AP_LO_iphy.xml
    Full Commission With SCF File For UTE      ${DeltaConfigDir}/LO_AP_LO_SCF.xml
    sleep   360s

Trigger A2 redirect Measurement
    [Arguments]    ${ue_id}     ${meas_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A2
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=RRCConnectionRelease   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    RRCConnectionRelease   partial_match=${TRUE}
    Log to Console    ${output}

Trigger A1 Measurement
    [Arguments]     ${ue_id}    ${meas_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}
    ...         event=A1       rs_type=ssb     srsrp_nr=30
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=rrcReconfigurationComplete   timeout=15
    ${output}   Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Trigger A4 Measurement
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    phycell_id=${phycell_id}
    ...      event=A4       nrsrp_nr=80

UE Deregister
    [Arguments]    ${ue_id}
    wtsrunner.ue_deregister    id=${ue_id}    by=amf

Check Pattern in Egate Console Log
    [Arguments]    ${pattern}    ${file}=${run_script_log_set}
    [Documentation]    This keyword checks if the ${pattern} is present in the egate_console.log file for the SA variant
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Run Keyword If    '${variant_name}' != '4G5G_COMBO_MultiUE'
    ...    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search pattern should Exists In EGATE
    ...                            ${WTS_DIR}/egate_console.log     ${pattern}


