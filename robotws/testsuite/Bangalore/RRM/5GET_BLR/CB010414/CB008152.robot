*** Settings ***
Documentation
...     author:                Ganesha U
...     email:                 Ganesha.u@nokia.com
...     Feature:               CB010414_CB008152
...     INTRODUCTION:     This user scenario describes NSA call Success,UL and DL Data Success of FDD 35 Mhz BW
...     TEST SET NAME:    [1]CB008152_A_B1_TC6_Verify_UE_attach_MAX_DL_UL_traffic_NSA
...                       This user scenario describes successful SgNB addition procedure for a UE for NR cell
...                       FR1-FDD bandwidth 35MHz with maximum supported DL and UL traffic.
...      TESTING SPLIT:    See CB008152 testplan
...      CONTACTS:         II_MN_RAN_RD_VRF_BLR1_T09_GMS <I_MN_RAN_RD_VRF_BLR1_T09@internal.nsn.com>
...      REFERENCES:       CB008152 CFAM
...      Requirement ID:  5G_RAN_USR_RRM_20822, CB_FIM_38784, CB_FIM_38783, CB_FIM_38785;5G_RAN_USR_RRM_22758

Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource            taf/rfrl/common_resources/robot/coam.robot
Resource            ../resources/robot/WTS_Runner_Keywords.robot
Resource            ../resources/robot/Airphone.robot
Library             ../resources/python/IphyUpdate.py
Library             taf.collectors.pmcounters
Library           taf.analyzer.pmcounter       WITH NAME    check_pm
Resource         ../CB008152/resources_keywords.resource


#    Test Suite Setup
Suite Setup         Run keywords     Test Suite Setup
...                 AND              AIC Software Build Info
...                 AND              Fetch Taf Library used in TL
...                 AND           Fast Delta Commission vCU Using Delta XML File     ${vcu_file_path}
...                 AND           Fast Delta Commission vDU With Delta XML File      ${rmod}
...                 AND           Fast Delta Commission vDU With Delta XML File      ${vdu_file_path}
...                 AND           Change RMOD in Iphy   ${iphy_file_path}    AHCA     AHFII   473966A    475656A   5383
...                 AND           ADD WideBand Flag in iphy   ${iphy_file_path}
...                 AND           AP Reboot Wait For Connection    ${120}
...                 AND           Verify RMODs Online Status   ${300}
...                 AND           sleep   60s    reason=f1 link should up
...                 AND           log to console   loading cfg file....
...                 AND           Start WTS Using WTS_Runner      ${wts_cfg_file}

Test Teardown      Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${iphy_file_path}  ${CURDIR}/config/SBTS24R3/iphy_35mz.xml
${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_35.cfg
${vcu_file_path}   ${CURDIR}/config/SBTS24R3/Delta_vcu.xml
${vdu_file_path}   ${CURDIR}/config/SBTS24R3/Delta_vdu.xml
${rmod}     ${CURDIR}/config/SBTS24R3/productcode.xml
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${UE_ID}    151
${reconf_filepath}      ${CURDIR}/../../../../../
${file_path}    /opt/iphy/latest/egate_console.log
${SA_flag}     0
${scs}    kHz15
${prb}    188

*** Test Cases ***
[1]CB008152_A_B1_TC6_Verify_UE_attach_MAX_DL_UL_traffic_NSA
    [Tags]   QC_343799   QCD_MN_RAN   QCP_RAN_ET
    [setup]  Testcase Setup
    X2AP Link Should be UP
    LTE Attach should be Successful  NSA_UE_ID=${UE_ID}
    UE Attach should be Successful  NSA_UE_ID=${UE_ID}     Trgt_Cell=4
    Trigger DL and UL Data
    Verify chBW from RRCReconfig message
    Validate Counter
    [Teardown]   Run Keyword and Continue on Failure   Trigger And Save Local Snapshot For vDU

*** Keywords ***
Trigger DL and UL Data
    Trigger DL Traffic for NSA    ue_id=${UE_ID}     Traffic_rate=mbps     dl_rate=150       trf_id=1
    Trigger DL Traffic for NSA    ue_id=${UE_ID}     Traffic_rate=mbps     dl_rate=150       trf_id=2
    Trigger DL Traffic for NSA    ue_id=${UE_ID}     Traffic_rate=mbps     dl_rate=150       trf_id=3
    Trigger UL Traffic for NSA    ue_id=${UE_ID}     Traffic_rate=mbps     ul_rate=150       trf_id=1
    Trigger UL Traffic for NSA    ue_id=${UE_ID}     Traffic_rate=mbps     ul_rate=150       trf_id=2
    Trigger UL Traffic for NSA    ue_id=${UE_ID}     Traffic_rate=mbps     ul_rate=150       trf_id=3

Get PM counter value modified
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}    ${pi_file_pattern}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=${pi_file_pattern}
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    Log to Console    ${moc}
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Be Equal  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   #console=${P_console}
    [Return]    ${pi_value}

Validate Counter
    Sync With Measurement Period    "vDU"
    Sync With Measurement Period    "vDU"
    Run Keyword and continue on failure    Common_Keywords.Collect pm counter kubectls      "vDU"
    ${path}   Set Variable    /home/ute/test_results/CB008152/${TEST_NAME}/gnb_pm_counters
    ${DL}     Get PM counter value modified    pm_files_location=${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-4    pi_id=M55310C01009     pi_file_pattern=*MRBTS*
    ${DL_Primary}    Evaluate    ${DL}*8/300000000
    Should be True    ${DL_Primary} > ${350}
    ${UL}     Get PM counter value modified    pm_files_location=${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-4    pi_id=M55310C03009     pi_file_pattern=*MRBTS*
    ${UL_Primary}    Evaluate    ${UL}*8/300000000
    Should be True    ${UL_Primary} > ${350}

Verify chBW from RRCReconfig message
    verify_reconfig.check_reconfig_msg     ${file_path}    ${SA_flag}
    OperatingSystem.Run    mv ${reconf_filepath}/Reconfig_MSG_* ${LOG_PATH}/
    ${output}    OperatingSystem.Get File   ${LOG_PATH}/Reconfig_MSG_1.txt
    BuiltIn.Should Match Regexp    ${output}
    ...    downlinkConfigCommon.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n
    ...    .*\\n.*\n.*subcarrierSpacing\\s${scs}.*\n.*carrierBandwidth\\s${prb}
    BuiltIn.Should Match Regexp    ${output}
    ...    uplinkConfigCommon.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\n.*subcarrierSpacing\\skHz15
    ...    .*\n.*carrierBandwidth\\s${prb}
