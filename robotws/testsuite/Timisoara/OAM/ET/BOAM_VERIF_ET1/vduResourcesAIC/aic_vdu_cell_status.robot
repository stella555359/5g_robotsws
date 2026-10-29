*** Settings ***
Documentation
...     31.03.2025 -- RF5.0 issues

Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           taf.transport.ssh                     WITH NAME    tafssh
Resource          aic_vdu_collect_log.robot
Resource          aic_vdu_ru_status.robot

*** Variables ***
${G_VDU_NAME}           vdu1
${CLUSTER_NAME}         cran1
${G_OAM_PODS_NAME}      po-${CLUSTER_NAME}-oam-0
${G_CPRT_PODS_NAME}     po-${CLUSTER_NAME}-cprt-0
${G_USER}               core

*** Keywords ***
Check F1 interface and x2 connection
    [Documentation]  Check F1 interface and x2 connection
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check F1 interface and x2 connection |
    Collect Container Logs    ${G_CPRT_PODS_NAME}    ctr-${CLUSTER_NAME}-cprt
    ${F1CLinkStatusDU_status} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-cprt.log |grep -i 'F1 setup successfully'
    Should Contain    ${F1CLinkStatusDU_status}    F1 setup successfully
    ${X2LinkStatusDU_status} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-cprt.log |grep -i 'GnbCuConfigurationUpdate'
    Should Contain    ${X2LinkStatusDU_status}       f1ap::GnbCuConfigurationUpdateAck to CU

Check Carrier Configuration
    [Documentation]  Check Carrier Configuration
    ...  author: yingguo.ying@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Carrier Configuration |
    Collect Container Logs    ${G_OAM_PODS_NAME}    ctr-${CLUSTER_NAME}-oamfh
    ${localAddress} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i '<parameterName>localAddress</parameterName>'
    Should Contain    ${localAddress}    <newValue>0</newValue>    <newValue>1</newValue>    <newValue>8</newValue>
    ...    <newValue>9</newValue>
    ${localAddressMask} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i '<parameterName>localAddressMask</parameterName>'
    Should Contain    ${localAddressMask}    <newValue>16383</newValue>
    ${supportedSectionType} =   tafssh.execute    cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i 'supportedSectionType'
    Should Contain    ${supportedSectionType}    <sectionType>1</sectionType>    <sectionType>3</sectionType>
    ${TxArrayCarrier} =   tafssh.execute    cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i 'defaultSubcarrierSpacing'
    Should Contain    ${TxArrayCarrier}    <newValue>KHZ_15</newValue>
    ...     <parameterName>fftSamplingOffset</parameterName><newValue>32</newValue>
    ...    <parameterName>cyclicPrefix</parameterName><newValue>NORMAL_CP</newValue>
    ${sfnOffsets} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i '<parameterName>sfnOffsets</parameterName>'
    Should Contain    ${sfnOffsets}    <newValue><alpha>0</alpha><beta>0</beta></newValue>
    ${remoteAddress} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i '<parameterName>remoteAddress</parameterName>'
    Should Contain    ${remoteAddress}    <newValue>0</newValue>    <newValue>1</newValue>    <newValue>8</newValue>
    ...    <newValue>9</newValue>
    ${format} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i '<parameterName>format</parameterName>'
    Should Contain    ${format}    <newValue>IQ16</newValue>
    ${carrier_status} =   tafssh.execute
    ...     cat /home/${G_USER}/${G_VDU_NAME}.ctr-${CLUSTER_NAME}-oamfh.log |grep -i '<parameterName>active</parameterName>'
    Should Contain    ${carrier_status}    <newValue>TRUE</newValue>

Check cell onair
    [Arguments]  ${rf_type}=AHCA
    [Documentation]  Check cell onair
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check cell onair |
    log to console    Check Cell onair
    run keyword if  '''${rf_type}'''='''AEQP'''     Ecpri_ru_power_check    ELSE
    ...     Check RF Power for vDU      type=${rf_type}

Check multicell onair
    [Arguments]  ${cell_num}=2
    [Documentation]  Check cell onair
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check cell onair |
    log to console    Check Cell onair
    FOR    ${ru_index}    IN RANGE   1   ${cell_num}+1
       Check RF Power for vDU     ru_index=${ru_index}
    END

Check F1 status
    [Documentation]  Check F1 status
    ...  author: xin.6.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check F1 status |
#    vDU Cluster Login With Tenant
    ${F1_status} =   tafssh.execute
    ...  kubectl exec -it ${G_CPRT_PODS_NAME} -c ctr-${CLUSTER_NAME}-cprt -n ${CLUSTER_NAME} -- cat tmp/startup_DEFAULT.log | grep -i 'F1 setup'
    Should Contain    ${F1_status}    F1 setup successfully

Check Cell Status
    [Arguments]     ${cell_status}      #${cell_index}=0
    [Documentation]  Check Cell Status
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | cell_status | yes | enabled or disabled |
    ...    *RETURN VALUE*
    ...    none
    ...
    ...    Example
    ...    | Check Cell Status | cell_status=enabled |
#    @{cell_status}=   vdu.get_vdu_cells_status
#    &{cell_status}=   set variable    @{cell_status}[${cell_index}]
    run keyword if  """${cell_status}"""=="""enabled"""   should be equal  ${cell_status.operational_state}    enabled
    run keyword if  """${cell_status}"""=="""disabled"""   should be equal  ${cell_status.operational_state}    disabled
