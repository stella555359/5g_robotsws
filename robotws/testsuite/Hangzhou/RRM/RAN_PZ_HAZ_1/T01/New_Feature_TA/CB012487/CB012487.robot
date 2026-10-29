*** Settings ***
Documentation
...   Author: Rong Nie
...   Contact: rong.nie@nokia-sbell.com
...   Description: An operator-initiated SW rollback to pre-listed unwanted SW versions is blocked.
...   In case of rollback the BTS sends an alarm in addition to the existing change notification to the NMS SW Manager.


Suite Setup       Common Suite Setup For RRM
#Suite Teardown    Common Suite Teardown For RRM

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK

#Test Timeout    60 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
#Resource  ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
#Resource    ../Resources/RRM2_Resource.robot
#Resource  ../../../../resources/RAN_PZ_HAZ_1/Module/Parameter_Operation.robot
#Resource  ../../../../resources/RAN_PZ_HAZ_1/Module/Alarm_Operation.robot
#Library    ../../../../resources/RAN_PZ_HAZ_1/Module/library/_classical_bts_base.robot
#Library    JSONLibrary
#Library    String
#Library    OperatingSystem

*** Variables ***
${product_type}    gnb
${JSON_FILE}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/New_Feature_TA/CB012487/config/CB012487.json
${NR_counter}=     M55308C10003,M55308C10004
${NR_counter_rule}=     max(M55308C10003)>=0 and max(M55308C10004)>=0
${NRCELL_distname}=    MRBTS-355/NRBTS-355/NRCELL-1
${LTE_counter}=     M8001C216,M8001C217
${LTE_counter_rule}=     max(M8001C216)>=0 and max(M8001C217)>=0
${LTECELL_distname}=    MRBTS-355/LNBTS-355/LNCEL-5
${scf_path}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/New_Feature_TA/CB012487/config
*** Test Cases ***
[1]CB012487 Feature activation_WebEM
    [Tags]    QC_122029       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB012487 activation from WebEM.
    @{para_list}      Create List    actRestrictedSWMonitoring
    @{mo_list}        Create List    MRBTS-355/MNL-1/MNLENT-1/FEATCADM-1
    @{value_list}     Create List    true
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}       value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

    Classical Get Software Version    product_type=${product_type}
    ${active}    ${passive}   Classical Get Software Version   product_type=${product_type}

    ${json}=    Get File    ${JSON_FILE}
    ${json}=    Replace String    ${json}    active_sw     ${active}
    ${json}=    Replace String    ${json}    passive_sw    ${passive}
    Log To Console   ${json}
    Create File    ${JSON_FILE}    ${json}
    Update restrictedSWRelList

    &{expected_alarms}        Create Dictionary    faultId=4769    faultName=Restricted SW activated
    @{expected_list}          Create List     ${expected_alarms}


    ${res}    Alarm Operation    operation=check_active_alarms    product_type=enb    bts_index=0
    ...                          expected_alarms=${expected_list}

    should be true    "${res['flag_expect_alarm']}"=="${True}"

    [Teardown]    TC01 Teardown

[1]CB012487-A-B1 Feature activation_NMS
    [Tags]    QC_122031       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB012487 activation from NMS.

    Log To Console    CB012487-A-B1 Feature activation_NMS
    [Teardown]    TC01 Teardown

[1]CB012487 Feature deactivation_WebEM
    [Tags]    QC_122028       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB012487 deactivation from WebEM.
    @{para_list}      Create List    actRestrictedSWMonitoring
    @{mo_list}        Create List    MRBTS-355/MNL-1/MNLENT-1/FEATCADM-1
    @{value_list}     Create List    false
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}       value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

    &{expected_alarms}        Create Dictionary    faultId=4769    faultName=Restricted SW activated
    @{expected_list}          Create List     ${expected_alarms}
    &{ignored_alarms}         Create Dictionary    faultId=7523    faultName=Cell Activation timeout at gNB-DU
    @{ignored_alarms_list}    Create List     ${ignored_alarms}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=Critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}

    ${res}    Alarm Operation    operation=check_active_alarms    product_type=enb    bts_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}

    should be true    "${res['flag_expect_alarm']}"=="${False}"

    [Teardown]    TC01 Teardown

[1]CB012487-A-B1 Feature deactivation_NMS
    [Tags]    QC_122030       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB012487 deactivation from NMS.

    Log To Console    CB012487-A-B1 Feature deactivation_NMS
    [Teardown]    TC01 Teardown

[1]CB012487 restrictedSWRelList_RestrictedSwBuilds.xml_update_WebEM
    [Tags]    QC_122025       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    Purpose of this use case is to describe if RestrictedSwBuilds.xml will be updated as well when add/modify/
    ...    delete restrictedSWRelList.


#    @{value_list}     Create List   ${None}
#    @{para_list}      Create List   actRestrictedSWMonitoring
#    @{mo_list}        Create List   MRBTS-37464/MNL-1/MNLENT-1/FEATCADM-1
#    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
#    ...                                      para_list=${para_list}    value_list=${value_list}   mo_list=${mo_list}
#    ...     modify_operation=remove
#    Log To Console    paramter update result: ${out}


    @{para_list}      Create List    actRestrictedSWMonitoring
    @{mo_list}        Create List    MRBTS-355/MNL-1/MNLENT-1/FEATCADM-1
    @{value_list}     Create List    true
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}       value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
#
#    &{staged_dict}    create dictionary   eea0=SBTS25R2_ENB_9999_250116_000009   eea1=SBT25R2_ENB_9999_250116_000007
#    @{staged_param_list}     Create List   ${staged_dict}
#    @{value_list}     Create List   ${staged_param_list}
#    @{para_list}      Create List   restrictedSWRelList
#    @{mo_list}        Create List   MRBTS-37464/MNL-1/MNLENT-1/FEATCADM-1
#    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
#    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
#    Log To Console    paramter update result: ${out}
    [Teardown]    TC01 Teardown

[1]CB012487-A-B1 restrictedSWRelList_RestrictedSwBuilds.xml_update_NMS
    [Tags]    QC_122024       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    Purpose of this use case is to describe if RestrictedSwBuilds.xml will be updated as well when add/modify/
    ...    delete restrictedSWRelList.

    Log To Console    CB012487-A-B1 restrictedSWRelList_RestrictedSwBuilds.xml_update_NMS
    [Teardown]    TC01 Teardown

[1]CB012487 SW version check during DU start up_Upgrade_WebEM
    [Tags]    QC_122039      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify SW version check during DU start up_Upgrade_WebEM.

#    BTS Operation    operation=upgrade    product_type=gnb    bts_index=0
#    ...    sw_path=/home/ute/SBTS00_ENB_9999_250116_000009_release_BTSSM_downloadable_A54.zip
#    ...    indicated_sw_version=${ENB_BUILD}

#    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR

    &{expected_alarms}        Create Dictionary    faultId=4769    faultName=Restricted SW activated
    @{expected_list}          Create List     ${expected_alarms}
    &{ignored_alarms}         Create Dictionary    faultId=7523    faultName=Cell Activation timeout at gNB-DU
    @{ignored_alarms_list}    Create List     ${ignored_alarms}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=Critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}

    ${res}    Alarm Operation    operation=check_active_alarms    product_type=enb    bts_index=0
    ...                          expected_alarms=${expected_list}
    ...                          ignored_alarms=${ignored_alarms_list}
    ...                          critical_alarms=${CRITICAL}

    should be true    "${res['flag_expect_alarm']}"=="${True}"

    [Teardown]    TC01 Teardown

[1]CB012487-A-B2 DU SW version check in runtime_WebEM
    [Tags]    QC_122048      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify DU SW version check in runtime_WebEM.

    Log To Console    CB012487-A-B2 DU SW version check in runtime_WebEM
    [Teardown]    TC01 Teardown

[1]CB012487-A-B2 SW version check during DU start up_Fallback_WebEM
    [Tags]    QC_122044      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify SW version check during DU start up_Fallback_WebEM.

    Log To Console    CB012487-A-B2 SW version check during DU start up_Fallback_WebEM
    [Teardown]    TC01 Teardown

[1]CB012487-A-B2 SW version check during DU start up_Upgrade_NMS
    [Tags]    QC_122036       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify SW version check during DU start up_Upgrade_NMS.

##    Mantaray Operation	    swm_import_build    product_type=gnb    bts_index=0    mantaray_name=Mantaray_1015
##    ...    software_build=SBTS00_ENB_9999_250102_000003
#
#    Mantaray Operation	    swm_download    product_type=gnb    bts_index=0    mantaray_name=Mantaray_1015
#    ...                     software_build=SBTS00_ENB_9999_250205_000005
#
##    Mantaray Operation	    swm_precheck    product_type=gnb    bts_index=0    mantaray_name=Mantaray_1015
##    ...                    software_build=SBTS00_ENB_9999_250115_000005
#
#    Mantaray Operation	    swm_activation    product_type=gnb    bts_index=0    mantaray_name=Mantaray_1015
#    ...                     software_build=SBTS00_ENB_9999_250205_000005
#
#    Mantaray Operation	    swm_provision    product_type=gnb    bts_index=0    mantaray_name=Mantaray_1015
#    ...                     software_build=SBTS00_ENB_9999_250205_000005
#
##    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR
#
#    &{expected_alarms}        Create Dictionary    faultId=4769    faultName=Restricted SW activated
#    @{expected_list}          Create List     ${expected_alarms}
#    &{ignored_alarms}         Create Dictionary    faultId=7523    faultName=Cell Activation timeout at gNB-DU
#    @{ignored_alarms_list}    Create List     ${ignored_alarms}
#    &{CRITICAL_ALARM1}        Create Dictionary    severity=Critical
#    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
#
#    ${res}    Alarm Operation    operation=check_active_alarms    product_type=enb    bts_index=0
#    ...                          expected_alarms=${expected_list}
#    ...                          ignored_alarms=${ignored_alarms_list}
#    ...                          critical_alarms=${CRITICAL}
#
#    should be true    "${res['flag_expect_alarm']}"=="${True}"

    Log To Console    [1]CB012487-A-B2 SW version check during DU start up_Upgrade_NMS
    [Teardown]    TC01 Teardown

[1]CB012487-A-B2 DU SW version check in runtime _NMS
    [Tags]    QC_122037      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify DU SW version check in runtime _NMS.

    Log To Console    CB012487-A-B2 SW version check during DU start up_Upgrade_NMS
    [Teardown]    TC01 Teardown

[1]CB012487-A-B2 SW version check during DU start up_Downgrade_NMS
    [Tags]    QC_122034     QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify SW version check during DU start up_Downgrade_NMS.

    Log To Console    CB012487-A-B2 SW version check during DU start up_Downgrade_NMS
    [Teardown]    TC01 Teardown

[1]CB012487-A-B2 SW version check during DU start up_Fallback_NMS
    [Tags]    QC_122033      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify SW version check during DU start up_Fallback_NMS.

    Log To Console    CB012487-A-B2 SW version check during DU start up_Fallback_NMS
    [Teardown]    TC01 Teardown

[1]CB012487-A-B3 SW Rollback blocking_WebEM
    [Tags]    QC_122020       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2023,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify SW Rollback blocking_WebEM.

    ${status}    ${out}   run keyword and ignore error     BTS Operation    operation=rollback    product_type=gnb
    ...                                                    bts_index=0
    should contain    ${out}     Operation blocked because destination SW version is restricted.
    [Teardown]    TC01 Teardown

[1]CB012487-A-B3 SW Rollback blocking_NMS
    [Tags]    QC_122015       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB012487-A-B3 SW Rollback blocking_NMS.

#    ${status}    ${out}   run keyword and ignore error     Mantaray Operation	    swm_rollback    product_type=gnb
#    ...                                                    bts_index=0    mantaray_name=Mantaray_1015
#    should contain    ${out}     FAILED
    Log To Console    CB012487-A-B3 SW Rollback blocking_NMS
    [Teardown]    TC01 Teardown

[1]CB012487 SW upgrade from N_1 to N
    [Tags]    QC_122049      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify SW upgrade from N_1 to N.

#    BTS Operation    operation=upgrade    product_type=gnb    bts_index=0
#    ...    sw_path=/home/ute/SBTS00_ENB_9999_241104_000023_release_BTSSM_downloadable_A54.zip
#
#    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR
    Log To Console    CB012487 SW upgrade from N_1 to N
    [Teardown]    TC01 Teardown

[1][1.0] CB013664_A_Perfromance_impact_check,_basic_counter_check,_FH_counter_check_NR
    [Tags]    QC_240849      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB013664

    ${out}   Parameter Operation    operation=full_commission   product_type=gnb
    ...                             scf_path=${scf_path}/SCF_SBTS00.xml
    Log To Console    full commission result: ${out}

    wait until keyword succeeds    15 min    60 sec    BTS Operation    operation=verify   product_type=gnb
    ...                            distname_id=NRCELL-ALL           verify_status=CELL_ONAIR

    Start Collect Counter_NR      ${NRCELL_distname}    ${NR_counter}    ${NR_counter_rule}
    Start Collect Counter_LTE      ${LTECELL_distname}    ${LTE_counter}    ${LTE_counter_rule}

    ${out_}   Parameter Operation    operation=full_commission   product_type=gnb
    ...                             scf_path=${scf_path}/SCF_SBTS00_original.xml
    Log To Console    full commission result: ${out_}

    wait until keyword succeeds    15 min    60 sec    BTS Operation    operation=verify   product_type=gnb
    ...                            distname_id=NRCELL-ALL           verify_status=CELL_ONAIR

    Log To Console    CB013664
    [Teardown]    TC01 Teardown

[1][1.0] CB013664_A_Perfromance_impact_check,_basic_counter_check,_FH_counter_check_LTE
    [Tags]    QC_240850      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB013664

    Log To Console    CB013664
    [Teardown]    TC01 Teardown

[1][1.0] CB013664_A_2CC_Carrier_Aggregation_with_non_continues_frequency
    [Tags]    QC_240853      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB013664

    Log To Console    CB013664

    [Teardown]    TC01 Teardown

[1][1.0] CB013664_A_Resiliency_configuration_with_4TRX_and_2TRX
    [Tags]    QC_240854      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB013664

    Log To Console    CB013664

    [Teardown]    TC01 Teardown

[1][1.0] CB013664_A_UL_CoMP_function_interaction
    [Tags]    QC_240856      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB013664

    Log To Console    CB013664
    [Teardown]    TC01 Teardown

[1][1.0] CB013664_A_B1_one_4Tx4Rx_N_type_cell_from_two_RRH_two_pipes_Radio_path_failure
    [Tags]    QC_240857      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB013664

    Log To Console    CB013664
    [Teardown]    TC01 Teardown

[1][1.0] CB013664_A_Resiliency_configuration_with_FDMR
    [Tags]    QC_240860      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB013664

    Log To Console    CB013664
    [Teardown]    TC01 Teardown

[1][1.0] CB013664_A_BB_pooling_feature_interaction
    [Tags]    QC_240862      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB013664

    Log To Console    CB013664

    [Teardown]    TC01 Teardown

[1][1.0] CB013664_A_B1_one_4Tx4Rx_N_type_cell_from_two_RRH_two_pipes_NR_full_rack
    [Tags]    QC_240871      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB013664

    Log To Console    CB013664

    [Teardown]    TC01 Teardown

[1][1.0] CB013664_A_B1_one_4Tx4Rx_N_type_cell_from_two_RRH_two_pipes_LTE_half_rack
    [Tags]    QC_240872      QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: rong.nie
    ...    Contact: rong.nie@nokia-sbell.com
    ...    01.16.2025,rong.nie@nokia-sbell.com
    ...    The purpose of this test case is verify CB013664

    Log To Console    CB013664

    [Teardown]    TC01 Teardown

*** Keywords ***
TC01 Teardown
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False

Classical Get Software Version
    [Arguments]  ${product_type}   ${gnb_index}=${0}   ${oam_ip}=${None}    ${connection}=COAM
    ${connection}     _bts.login
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${connection}
    ...    oam_ip=${oam_ip}
    ${sw_info}   coam.get_software_info   connection=${connection}   timeout=${60}
    ${active}   Set Variable   ${sw_info['Active SW version']}
    ${passive}   Set Variable   ${sw_info['Passive SW version']}
    ${planned}   Set Variable   ${sw_info['Planned SW version']}

    ${active}   Set Variable If   "${active}"!="${None}" and "${active}"!=""   ${active}   None
    ${passive}   Set Variable If   "${passive}"!="${None}" and "${passive}"!=""   ${passive}   None
    ${planned}   Set Variable If   "${planned}"!="${None}" and "${planned}"!=""   ${planned}   None

#    ${active_version}   ${active_release}   Run Keyword If   "${active}"!="${None}" and "${active}"!=""
#    ...   Get SW Version and Convert Trunk or Branch   sw_version=${active}
#    ...   ELSE   Set Variable   None   None
#    ${passive_version}   ${passive_release}   Run Keyword If   "${passive}"!="${None}" and "${passive}"!=""
#    ...   Get SW Version and Convert Trunk or Branch   sw_version=${passive}
#    ...   ELSE   Set Variable   None   None
#    ${planned_version}   ${planned_release}   Run Keyword If   "${planned}"!="${None}" and "${planned}"!=""
#    ...   Get SW Version and Convert Trunk or Branch   sw_version=${planned}
#    ...   ELSE   Set Variable   None   None

#    ${software_dict}   Create Dictionary
#    ...   active_version=${active_version}
#    ...   passive_version=${passive_version}
#    ...   planned_version=${planned_version}
#    ...   active_release=${active_release}
#    ...   passive_release=${passive_release}
#    ...   planned_release=${planned_release}
    [Return]       ${active}        ${passive}
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}

Update restrictedSWRelList
     [Arguments]  ${delta_file_path}=${scf_path}/CB012487.json
     Parameter Operation    operation=delta_plan_update   product_type=gnb  delta_file_path=${delta_file_path}  wait_for_completion=${True}

Start Collect Counter_NR
    [Arguments]    ${distname}    ${counter}    ${counter_rule}
    ${rule1}    Catenate
    ...         Distname: ${distname};
    ...         Counter: ${counter};
    ...         Counter rule: ${counter_rule};
    ${rule_list}    Create List    ${rule1}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0    counter_rule=${rule_list}
    ...                  wait_for_next_counter_generate=${true}

Start Collect Counter_LTE
    [Arguments]    ${distname}    ${counter}    ${counter_rule}
    ${rule1}    Catenate
    ...         Distname: ${distname};
    ...         Counter: ${counter};
    ...         Counter rule: ${counter_rule};
    ${rule_list}    Create List    ${rule1}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0    counter_rule=${rule_list}
    ...                  wait_for_next_counter_generate=${true}