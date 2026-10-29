*** Settings ***
Documentation
    ...  vCU/vDU M2M Rest Api interface shall support command to configure or update configuration UPlane or CPlane tracing:
    ...  • dscp
    ...  • trace type (UPlane or CPlane)
    ...  • uplane IP address
    ...  • port number
    ...  Usage of this command requires setting of TRBLCADM/actInternalTrace to true with 'provisions' M2M Rest Api for delta plan operations

Resource  ../../common_resources/M2M_Interface.robot
Resource  ../../common_resources/vcu_frame.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__KPI__CBTS__Configure_Common_UPlane_CPlane_tracing
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27397
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  04.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-27397 - Initial TAT creation
    ...  28.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-28671 - Replace MRBTS
    ...  ******************

    Set Tags  CA-KPI  cristian.bulea@nokia.com  AUTHOR-bogdan.boldurean@nokia.com  MAINTAINER-bogdan.boldurean@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  FEATURE-CB009006-C

    Step1: Set Parameters
    Step2: Configure UPlane Traceing VCU
    Step3: Configure UPlane Traceing VDU
    Step4: Configure CPlane Traceing VDU
    Step5: Wrong DSCP Configure DSCP UPlane Traceing VCU
    Step6: Wrong DSCP Configure DSCP UPlane Traceing VDU
    Step7: Wrong DSCP Configure DSCP CPlane Traceing VDU


Step1: Set Parameters
    Log  Step1: Set Parameter  console=True
    Change Specific Parameter For VCU  actInternalTrace  true  MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    Change Specific Parameter For VDU  actInternalTrace  true  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    Log  Set test parameters to be used.  console=ture
    ${rand_dscp}  Evaluate  random.randint(0,15)  random
    ${rand_port}  Evaluate  random.randint(1024, 65535)  random
    Set Test Variable  ${UPLANE_IP}  10.10.10.10
    Set Test Variable  ${UPLANE_PORT}  ${rand_port}
    Set Test Variable  ${DSCP}  ${rand_dscp}
    Log  UPLANE_IP: ${UPLANE_IP}  console=true
    Log  UPLANE_PORT:${UPLANE_PORT}  console=true
    Log  DSCP: ${DSCP}  console=true


Step${index}: Configure ${trace_type} Traceing ${unit}
    Log  Step${index}: Configure ${trace_type} Traceing ${unit}  console=True
    Login Using M2M Interface  ${${unit}_OAM_IP}
    Run M2M Command  GET  https://${${unit}_OAM_IP}/api/licensed/v1/traces/common-configuration  Bearer  ${TOKEN}
    Run M2M Command  PUT  https://${${unit}_OAM_IP}/api/licensed/v1/traces/common-configuration  Bearer  ${TOKEN}
    ...  -d "{\\"dscp\\":${DSCP}, \\"traceType\\":\\"${trace_type}\\", \\"uplaneIpAddress\\":\\"${UPLANE_IP}\\", \\"uplanePort\\":${UPLANE_PORT}}"
    Wait Until Keyword Succeeds  120  10
    ...  Check If Configuration Was Updated  ${${unit}_OAM_IP}

    [Teardown]  Logout Using M2M Interface  ${${unit}_OAM_IP}


Step${index}: Wrong DSCP Configure ${trace_type} Traceing ${unit}
    Log  Step${index}: Wrong DSCP configure ${trace_type} Traceing ${unit}  console=True
    Login Using M2M Interface  ${${unit}_OAM_IP}
    ${m2m_output}  Run M2M Command  GET  https://${${unit}_OAM_IP}/api/licensed/v1/traces/common-configuration  Bearer  ${TOKEN}
    ${m2m_output}  Remove M2M Output Noise  ${m2m_output}
    ${initial_values}  Evaluate  ${m2m_output}
    Run M2M Command  PUT  https://${${unit}_OAM_IP}/api/licensed/v1/traces/common-configuration  Bearer  ${TOKEN}
    ...  -d "{\\"dscp\\":16, \\"traceType\\":\\"${trace_type}\\", \\"uplaneIpAddress\\":\\"${UPLANE_IP}\\", \\"uplanePort\\":${UPLANE_PORT}}"
    Sleep  1m  Wait for configuration change.
    Check Configuration Was Not Changed After Giving Wrong Values  ${${unit}_OAM_IP}  ${initial_values}[dscp]

    [Teardown]  Logout Using M2M Interface  ${${unit}_OAM_IP}


Check If Configuration Was Updated
    [Arguments]  ${ip}

    Log  Wait until configuration is updated...  console=true
    ${m2m_output}  Run M2M Command  GET  https://${ip}/api/licensed/v1/traces/common-configuration  Bearer  ${TOKEN}
    ${m2m_output}  Remove M2M Output Noise  ${m2m_output}
    ${dict}  Evaluate  ${m2m_output}
    Should Be Equal As Strings  ${dict}[dscp]  ${DSCP}  DSCP not updated.
    Should Be Equal As Strings  ${dict}[uplaneIpAddress]  ${UPLANE_IP}  UPlane IP not updated.
    Should Be Equal As Strings  ${dict}[uplanePort]  ${UPLANE_PORT}  UPlane port not updated.


Check Configuration Was Not Changed After Giving Wrong Values
    [Arguments]  ${ip}  ${initial_dscp}

    Log  Check configuration was not changed after giving wrong values...  console=true
    ${m2m_output}  Run M2M Command  GET  https://${ip}/api/licensed/v1/traces/common-configuration  Bearer  ${TOKEN}
    ${m2m_output}  Remove M2M Output Noise  ${m2m_output}
    ${dict}  Evaluate  ${m2m_output}
    Should Be Equal As Strings  ${dict}[dscp]  ${initial_dscp}  DSCP was updated.[NOK]


TC Setup
    Common VCU Setup
    Common VDU Setup
    Modify Resource Search Order  KPI__CBTS__Configure_Common_UPlane_CPlane_tracing


TC Teardown
    Common VCU Teardown
    Common VDU Teardown
