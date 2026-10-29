# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    author:
# ...    contact:
# ...    squad group: 5G_PZ_MMW_HZ_2_SG
# ...    feature : Rjio_AQQJ_cases
# 
# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# 
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
# 
# *** Variables ***
# #${nrbtsID}        ${tl.gnbs[0].global_bts_id}
# #${mrbtsID}         ${tl.gnbs[0].instance_id}
# ${cellid}          1
# ${target_value}     true
# ${reset_number}    1
# #${if_commissioning}    False
# 
# *** Test Cases ***
# [1]Rjio_E2E_08_Parameter_Modification_Objectlocking
#     [Documentation]  The purpose of this Test Case is to modify parameter Object locking type.
#     [Tags]
#     [Timeout]    1h
#     [Setup]    SISO Coam Test Setup
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     Get Filter one_parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1    abbr=dlMimoMode    filter_param=Downlink MIMO Mode
#     Run Keyword If    '${para_value}'!='4x4 or 4x2 Closed Loop Spatial Multiplexing'
#     ...    Modify Rjio08 para in webui
#     Restore dlMimoMode in webui
#     [Teardown]    run keywords    selenium logout and close browser    AND    SISO Coam Test Teardown
# 
# [1]Rjio_E2E_09_Parameter_Modification_Site_Reset
#     [Documentation]  The purpose of this Test Case is to modify parameter qosClassificationCriteria reboot and recover.
#     [Tags]
#     [Timeout]    1h
#     [Setup]    SISO Coam Test Setup
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     Get Filter one_parameter    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1    abbr=qosClassificationCriteria
#     ...    filter_param=QoS classification mode
#     Run Keyword If    '${para_value}'!='PCP'    modify qosClassificationCriteria in webui
#     ${qosvalue}    Get Filter one_parameter    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1    abbr=qosClassificationCriteria
#     ...    filter_param=QoS classification mode
#     Should Be Equal    ${qosvalue}    PCP
#     Log To Console    'reboot BTS'
#     reboot bts
#     Log To Console    'recover PCP to DSCP'
#     Close Start Up View    timeout=60
#     recover qosClassificationCriteria and check in webui
#     [Teardown]    run keywords    selenium logout and close browser    AND    SISO Coam Test Teardown
# 
# 
# #[1]Rjio_AQQJ_17_Online_mMIMO_Parameter_Modification
#    # [Documentation]  The purpose of this Test Case is to modify parameter dlMimoMode/basicBeamSet.
#    # ...    this type of Parameter only has "Object locking" modification type.
#    # [Tags]
#    # [Timeout]    2h
#    # [Setup]    SISO Coam Test Setup
#    # Selenium Login And Disable Screen Lock
#    # Close Start Up View    timeout=60
#     #Get Filter one_parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-3    abbr=basicBeamSet    filter_param=Basic Beam Set
#     #Run Keyword If    '${para_value}'!='beamSet_6'
#     #...    Modify one parameter via webui    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-3
#     #...    abbr=basicBeamSet    new_value=beamSet_6    filter_param=Basic Beam Set
#     #Log To Console   'Recover parameter to original'
#     #Modify one parameter via webui    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-3
#     #...     abbr=basicBeamSet    new_value=beamSet_5_1    filter_param=Basic Beam Set
#     #Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
#     #[Teardown]    run keywords    selenium logout and close browser    AND    SISO Coam Test Teardown
# 
# [1]Rjio_AQQJ_18_Online_TNL_Parameter_Modification
#     [Documentation]  The purpose of this Test Case is to modify parameter l2IngressRate.
#     [Tags]
#     [Timeout]    1h
#     [Setup]    SISO Coam Test Setup
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     Get Filter one_parameter    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1    abbr=l2IngressRate
#     ...    filter_param=Ethernet interface ingress rate limiter
#     Run Keyword If    '${para_value}'!='1000000'
#     ...    Modify one parameter via webui    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1    abbr=l2IngressRate    new_value=1000000
#     ...    filter_param=Ethernet interface ingress rate limiter
#     ${abbrvalue}    Get Filter one_parameter    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1    abbr=l2IngressRate
#     ...    filter_param=Ethernet interface ingress rate limiter
#     Should Be Equal    ${abbrvalue}    1000000 (kbps)
#     Log To Console    'Recover parameter to original'
#     Run Keyword If    '${para_value}'!='10000000'
#     ...    Modify one parameter via webui    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1    abbr=l2IngressRate    new_value=10000000
#     ...    filter_param=Ethernet interface ingress rate limiter
#     ${abbrvalue}    Get Filter one_parameter    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1    abbr=l2IngressRate
#     ...    filter_param=Ethernet interface ingress rate limiter
#     Should Be Equal    ${abbrvalue}    10000000 (kbps)
#     Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
#     [Teardown]    run keywords    selenium logout and close browser    AND    SISO Coam Test Teardown
# 
# 
# *** Keywords ***
# reboot bts
#     Connect to gnb coam via ssl
#     Perform BTS Site Reset On WebUI
#     sleep    60s
#     Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
#     [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# Modify Rjio08 para in webui
#     log to console    'delete object and modify parameter'
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cellid}
#     ...    abbr=dlMimoMode
#     ...    new_value=4x4 or 4x2 Closed Loop Spatial Multiplexing
#     ...    filter_param=Downlink MIMO Mode
#     sleep    1s
#     selenium_coam.delete_parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1    filter_param=CSI-RS power
#     ...    abbr=csirsPower
#     selenium_coam.delete_parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
#     ...    filter_param=Number of CSI-RS resource period in one CSI report period    abbr=csirsNumberWithinReportPeriod_Set1
#     selenium_coam.delete_parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1    filter_param=Maximum CSI-RS number
#     ...    abbr=maxCsirsNumber
#     sleep    1s
#     ${error}    selenium_coam.validate_plan
#     Log To Console    ${error}
#     Log To Console    Activate plan
#     sleep    8s
#     selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=900
#     Run Keyword And Ignore Error    COAM Teardown gnb connections
#     Connect to gnb coam via ssl
#     Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
#     Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# modify_check_recover parameter l2QoSEnabled
#     ${value_origin}    Get Filter one_parameter    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1    abbr=l2QoSEnabled
#     ...    filter_param=Enable layer 2 QoS awareness per switch-port
#     set suite variable    ${value_origin}
#     Run Keyword If    '${value_origin}'!='true'
#     ...    Modify one parameter via webui    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...    abbr=l2QoSEnabled
#     ...    new_value=${target_value}
#     ...    filter_param=Enable layer 2 QoS awareness per switch-port
#     ${para_value}    Get Filter one_parameter    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1    abbr=l2QoSEnabled
#     ...    filter_param=Enable layer 2 QoS awareness per switch-port
#     Should Be Equal    ${para_value}    ${target_value}
#     Log To Console    'Recover parameter to original'
#     Run Keyword If    '${para_value}'!='false'
#     ...    Modify one parameter via webui    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1    abbr=l2QoSEnabled    new_value=false
#     ...    filter_param=Enable layer 2 QoS awareness per switch-port
#     ${para_value}    Get Filter one_parameter    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1    abbr=l2QoSEnabled
#     ...    filter_param=Enable layer 2 QoS awareness per switch-port
#     Should Be Equal    ${para_value}    ${value_origin}
# 	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
# 
# modify qosClassificationCriteria in webui
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...    abbr=qosClassificationCriteria
#     ...    new_value=PCP
#     ...    filter_param=QoS classification mode
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1
#     ...    abbr=portDefaultVlanPriority
#     ...    new_value=1
#     ...    filter_param=Port default VLAN priority
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/IBRGPRT-1
#     ...    abbr=portDefaultVlanPriority
#     ...    new_value=1
#     ...    filter_param=Port default VLAN priority
#     sleep    1s
#     selenium_coam.validate_plan
#     sleep    5s
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
# 
# recover qosClassificationCriteria and check in webui
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
#     ...    abbr=qosClassificationCriteria
#     ...    new_value=DSCP
#     ...    filter_param=QoS classification mode
#     sleep    1s
#     selenium_coam.validate_plan
#     sleep    5s
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
#     ${para_value}    Get Filter one_parameter    dist_name=MRBTS-${mrbtsID}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1    abbr=qosClassificationCriteria
#     ...    filter_param=QoS classification mode
#     Should Be Equal    ${para_value}    DSCP
# 
# Restore dlMimoMode in webui
#     Run Keyword And Ignore Error    selenium logout and close browser
#     Selenium Login And Disable Screen Lock
#     Close Start Up View    timeout=60
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
#     ...    abbr=dlMimoMode
#     ...    new_value=8x4 Closed Loop Spatial Multiplexing
#     ...    filter_param=Downlink MIMO Mode
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
#     ...    abbr=csirsPower
#     ...    new_value=18
#     ...    filter_param=CSI-RS power
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
#     ...    abbr=maxCsirsNumber
#     ...    new_value=4
#     ...    filter_param=Maximum CSI-RS number
#     selenium_coam.set_parameter_value
#     ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
#     ...    abbr=csirsNumberWithinReportPeriod_Set1
#     ...    new_value=1
#     ...    filter_param=Number of CSI-RS resource period in one CSI report period
#     sleep    1s
#     selenium_coam.validate_plan
#     sleep    8s
#     selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=900
#     Run Keyword And Ignore Error    COAM Teardown gnb connections
#     Connect to gnb coam via ssl
#     Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
#     Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# Modify one parameter via webui
#     [Arguments]    ${dist_name}=${dist_name}    ${abbr}=${abbr}    ${new_value}=${new_value}    ${filter_param}=${filter_param}
#     selenium_coam.set_parameter_value
#     ...    dist_name=${dist_name}
#     ...    abbr=${abbr}
#     ...    new_value=${new_value}
#     ...    filter_param=${filter_param}
#     sleep    1s
#     selenium_coam.validate_plan
#     sleep    8s
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
# 
# Get Filter one_parameter
#     [Arguments]    ${dist_name}=${dist_name}    ${abbr}=${abbr}    ${filter_param}=${filter_param}
#     ${para_value}    selenium_coam.get_parameter_value
#     ...   dist_name=${dist_name}
#     ...   abbr=${abbr}
#     ...   filter_param=${filter_param}
#     set suite variable    ${para_value}
#     [Return]    ${para_value}
