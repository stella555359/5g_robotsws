*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ONAP.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library            taf.sbts.oam.coam.admin
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py
Library           taf.transport.ssh    WITH NAME    ssh
Library           lxml    WITH NAME    xml
Library           taf.hw.pdu
Library           OperatingSystem


*** Variables ***
${TARGET_SW_NAME}    ${None}    # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}    /home/ute/btsauto/TARGET_SW/    # Directory in which TC should look for sw package. RGET
${UPDATE_TIMEOUT}    1500    # Timeout for Download and Activation [sec]
${SW Download Timeout}    1800
${SW Activation Timeout}                          150  # Given in seconds; That is a timeout for SW download a
${Ping loss timeout}                              420  # Timeout for ping loss during reset
${Ping regain timeout}                            600  # Timeout for ping regain during reset
${BTS_OnAir_Timeout}                               15  # Timeout for BTS on Air (in minutes)
${Test_Timeout}                                    30  # Test timeout (in minutes)
${ONAP_server}	                        10.110.73.138
${BTS_INFO}          10.106.243.13
${HW_OFF_ID_LIST}
${NUMBER_OF_RMODS_TO_TURN_OFF}                 1
${RM_DETECTION_TIMEOUT}            20min

#CB014041_SR_SCF_upload_frozen_parameter_with_different_value_from_MFV_failed_for Classical BTS via WebEM and O1 SMO
##The case include download and activation
#    [Tags]        3_5_UTE4G223
#    [Setup]    log     11111
#    CB014041_SR_SCF_upload_frozen_parameter_with_different_value_from_MFV_failed_for Classical BTS via WebEM and O1 SMO
#    [Teardown]     log     112222222
#
#CB014041_SR_SCF_upload_frozen_parameter_with_different_value_from_MFV_failed_for Classical BTS via NMS
##The case include download and activation
#    [Tags]        3_5_UTE4G223
#    [Setup]    log     11111
#    TC_CB014041_SR_SCF_upload_frozen_parameter_with_different_value_from_MFV_failed_for Classical BTS via NMS
#    [Teardown]     log     112222222

#CB014041_SR_SCF_update_frozen_parameter_with_different_value_from_MFV_failed_for Cloud BTS
#    [Tags]        3_5_UTE4G223
#    [Setup]    log     11111
#    TC_CB014041_SR_SCF_update_frozen_parameter_with_different_value_from_MFV_failed_for Cloud BTS
#    [Teardown]     log     112222222



*** Keywords ***
TC_CB014041_SR_SCF_upload_frozen_parameter_with_different_value_from_MFV_failed
    #Step 1.change paramters on netact
    Step 2.change paramters on webem
    #Step 3.change paramters on onap




TC_CB014041_SR_Configuration Data Check after Migration and Upgrade for Classical BTS
    Step 1.ensure bts in not 25R2
    Step 2.change paramters on webem on old release
    Step 3.upgrade fail




#TC_CB014041_SR_SCF_upload_frozen_parameter_with_different_value_from_MFV_failed_for Classical BTS via NMS

TC_CB014041_SR_SCF_update_frozen_parameter_with_different_value_from_MFV_failed_for Cloud BTS
    taf.gnb.oam.coam.vdu.connect to     10.56.213.82     443     Nemudamin     xxxxx
    ${Resuit}=     Run Keyword and ignore error     taf.gnb.oam.coam.vdu.Perform Delta Recommissioning
    ...    delta_webem_cloud.json
    #get_status_of_perform_delta_recommissioning      ${Resuit[1][0]}
    taf.gnb.oam.coam.vdu.disconnect

TC_CB014041_SR_Configuration Data Check after Migration and Upgrade for Cloud BTS
    taf.gnb.oam.coam.vdu.connect to     10.56.213.82     443     Nemudamin     xxxxx
    Step 2.change paramters on webem on old release
    Step 3.check parameter not like 25R2 after upgrade
    taf.gnb.oam.coam.vdu.disconnect

TC_CB014041_SR_Exploratory and Robustness Test for Cloud BTS
    taf.gnb.oam.coam.vdu.connect to     10.56.213.82     443     Nemudamin     xxxxx
    change old release scf
    full comission scf
    check Mfv value already frozen on 25r3


Step 2.change paramters on webem on old release for cloud
    ${Resuit}=     Run Keyword and ignore error     taf.gnb.oam.coam.vdu.Perform Delta Recommissioning
    ...    delta_webem_cloud.json
    Run Keyword if     '${Resuit[0]}'    Log    case pass
    ...  ELSE   Log    fail



Step 1.ensure bts in not 25R2
    taf.sbts.oam.coam.admin.setup_admin    192.168.255.129
    ${Resuit}=     taf.sbts.oam.coam.admin.get_software_info

Step 2.change paramters on webem on old release
    ${Resuit}=     Run Keyword and ignore error     taf.sbts.oam.coam.admin.Perform Delta Recommissioning    delta_webem_25R2.json
    Run Keyword if     '${Resuit[0]}'    Log    case pass
    ...  ELSE   Log    fail

Step 3.upgrade fail
    ${Resuit}=    Run Keyword and ignore error     taf.sbts.oam.coam.admin.update_software
    ...    /home/ute/Downloads/SBTS00_ENB_9999_250325_000012_release_BTSSM_downloadable_A54.zip     timeout=3600


Step 2.change paramters on webem

    ${Resuit}=     Run Keyword and ignore error     taf.sbts.oam.coam.admin.Perform Delta Recommissioning    delta_webem.json
    Log      ${Resuit[1][-100:]}
    ${point1}=      Run Keyword and return status     Should Contain     ${Resuit[1]}        ErrorCode: 23
    ${point2}=      Run Keyword and return status     Should Contain     ${Resuit[1]}      actvalidationonupgrade
    ${point3}=      Run Keyword and return status     Should Contain    ${Resuit[1]}      actRatResetEnhancement
    ${point4}=      Run Keyword and return status     Should Contain     ${Resuit[1]}     planFileActivationMode
    ${point5}=      Run Keyword and return status     Should Contain      ${Resuit[1]}     validatePlanAgainstDetectedHW
    ${point_all}     Evaluate       ${point1} and ${point2} and ${point3} and ${point4} and ${point5}
    Run Keyword if     '${Resuit[0]}'=='FAIL' and ${point_all}==${True}     Log    case pass
    ...  ELSE   Log    fail


Step 2.full commission scf on webem
    taf.sbts.oam.coam.admin.setup_admin    192.168.255.129
    ${Resuit}=     Run Keyword and ignore error     taf.sbts.oam.coam.admin.Perform Delta Recommissioning    delta_webem.json
    Log      ${Resuit[1][-100:]}
    ${point1}=      Run Keyword and return status     Should Contain     ${Resuit[1]}        ErrorCode: 23
    ${point2}=      Run Keyword and return status     Should Contain     ${Resuit[1]}      actvalidationonupgrade
    ${point3}=      Run Keyword and return status     Should Contain    ${Resuit[1]}      actRatResetEnhancement
    ${point4}=      Run Keyword and return status     Should Contain     ${Resuit[1]}     planFileActivationMode
    ${point5}=      Run Keyword and return status     Should Contain      ${Resuit[1]}     validatePlanAgainstDetectedHW
    ${point_all}     Evaluate       ${point1} and ${point2} and ${point3} and ${point4} and ${point5}
    Run Keyword if     '${Resuit[0]}'=='FAIL' and ${point_all}==${True}     Log    case pass
    ...  ELSE   FAIL    fail
    taf.sbts.oam.coam.admin.Teardown

Step 1.change paramters on netact

    taf.nms.netact.Add Node    cmwas    10.56.3.18   omc    Nokia123!
    ${web_url}=    taf.nms.netact.Detect WEB URL
    #Upload SCF To NetAct	${path}		${file}
    taf.nms.netact.Upload Configuration     PLMN-PLMN/MRBTS-5339
    taf.nms.netact.Add WEB URL    jiang7lbwas.jiang7.srnhz.nsn-rdnet.net     omc     Nokia123!
    taf.nms.netact.Import Configuration    delta_netact.xml      local_dir=${CURDIR}     plan_name=14041_plan

    #${Resuit}=     Run Keyword and ignore error      taf.nms.netact.Validate Plan     14041_plan    PLMN-PLMN/MRBTS-5339
    ${Resuit}=     Run Keyword and ignore error      taf.nms.netact.Provision Plan      14041_plan    PLMN-PLMN/MRBTS-5339
    ...    provisioning_operation=preactivate
    ${point1}=      Run Keyword and return status     Should Contain     ${Resuit[1]}         Pdl validation failed

    taf.nms.netact.Delete Plan      14041_plan
    taf.nms.netact.Delete Node    cmwas
    taf.nms.netact.Clean All
    Run Keyword if     '${Resuit[0]}'=='FAIL' and ${point1}==${True}     Log    case pass
    ...  ELSE   FAIL    fail

#change actvalidationonupgrade to false
#change linkmodedc to on
#change actRatResetEnhancement to false
#change validatePlanAgainstDetectedHW to true and planFileActivationMode to others
