*** Settings ***

Documentation
...   author: Damian Piasecki, Damian Zak
...   contact: damian.piasecki@nokia.com, damian.zak@nokia.com
...   description: Keywords to manipulate SCF for 5GC001349 feature

Library    OperatingSystem
Library    DateTime
Library    Telnet
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.config.scf    WITH NAME    scf
Library    ute_wtssim
Library    taf.gnb.oam.coam.admin
Library    ta5g_iperf_traffic
Library    ta5g_ue_mobility
Library    ta5g_enb
Library    ta5g_egate
Library    ta5g_tshark
Library    ta5g_ue_measurements
#Library    common_keywords.py


*** Keywords ***
Change Prach Index Value
    [Arguments]    ${value}
    [Documentation]      Change rach index value
    ...                  Creation Date: 20.01.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.zak@nokia.com

    admin.Connect To
    #connect_to(bts_host='192.168.255.129', bts_port=443, username='Nemuadmin', password='nemuuser', use_ssl=True, update_interval=5000,
	#...    admin_api_log_dir='', name='default', bundle_path=None, reconnect_with_default_on_failure=False, release='admin21a')
    Change Configuration Parameter
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=prachConfigurationIndex
    ...    value=${value}
    [Teardown]    admin.Teardown admin

Set Prach Sequence Type Unrestricted
    [Documentation]      Set prach sequence type to unrestricted
    ...                  Creation Date: 20.01.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.zak@nokia.com

    admin.Connect To
    Change Configuration Parameter
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=prachSequenceType
    ...    value=Unrestricted
    [Teardown]    admin.Teardown admin

Change pMaxNROwnCell Value
    [Arguments]    ${value}
    [Documentation]      Change pMaxNROwnCell value
    ...                  Creation Date: 20.01.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.zak@nokia.com

    #admin.Connect To
    #admin.connect_to    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'    password='nemuuser'    use_ssl=True
    #...    update_interval=5000    admin_api_log_dir=''    name='default'    bundle_path=None    reconnect_with_default_on_failure=False
    admin.setup_admin    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'    password='nemuuser'    use_ssl=True
    ...    update_interval=5000    
    Change Configuration Parameter
    ...    dist_name=MRBTS-9/NRBTS-602/NRCELL-1356
    ...    parameter=pMaxNROwnCell
    ...    value=${value}
    [Teardown]    admin.Teardown admin

Change ptpSyncRepPrd Value
    [Arguments]    ${value}
    [Documentation]      Change ptpSyncRepPrd Value
    ...                  Creation Date: 20.01.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.zak@nokia.com

    #admin.Connect To
    #admin.connect_to    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'    password='nemuuser'    use_ssl=True
    #...    update_interval=5000    admin_api_log_dir=''    name='default'    bundle_path=None    reconnect_with_default_on_failure=False
    admin.setup_admin    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'    password='nemuuser'    use_ssl=True
    ...    update_interval=5000    
    Change Configuration Parameter
    ...    dist_name=MRBTS-9/EQM-1/APEQM-1/RMOD-1
    ...    parameter=ptpSyncRepPrd
    ...    value=${value}
    [Teardown]    admin.Teardown admin

Change supervision-notification-interval
    [Arguments]    ${value}
    [Documentation]      Change pMaxNROwnCell value
    ...                  Creation Date: 20.01.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.zak@nokia.com

    #admin.Connect To
    admin.connect_to    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'    password='nemuuser'    use_ssl=True
    ...    update_interval=5000    admin_api_log_dir=''    name='default'    bundle_path=None    reconnect_with_default_on_failure=False
    admin.setup_admin    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'    password='nemuuser'    use_ssl=True
    ...    update_interval=5000       
    Change Configuration Parameter
    ...    dist_name=MRBTS-618/MNL-1
    ...    parameter=supvNtInr
    ...    value=${value}
    [Teardown]    admin.Teardown admin

Create Bandwidth Related Parameters List
    [Arguments]     ${chBw}
    [Documentation]      List containing channel bandwidth related parameters
    ...                  Creation Date: 25.03.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.piasecki@nokia.com

    ${chBw_param}    Create Dictionary    parameterName=chBw    value=${chBw}    operation=update
    ${bandwidth_related_parameters_list}    Create List    ${chBw_param}
    [Return]     ${bandwidth_related_parameters_list}

Change Bandwidth Value
    [Arguments]    ${value}
    [Documentation]      Change channel bandwidth value
    ...                  Creation Date: 01.02.2021
    ...                  Modified Date: 25.03.2021
    ...                  Last Modified by: damian.piasecki@nokia.com

    admin.Connect To
    ${bandwidth_related_parameters_list}    Create Bandwidth Related Parameters List
    ...    chBw=${value}
    admin.Perform Object Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=${bandwidth_related_parameters_list}
    ...    operation=update
    ...    skip_parameter_relation_errors=True
    Wait For GNB And Radio To Be In Proper State
    [Teardown]    admin.Teardown admin

Create TddFrameStructure Parameters List
    [Arguments]     ${frameStructureType}     ${guardPeriodLength}    ${lteToNrFrameShift}
    ...             ${tdLteUlDlConfig}    ${ulDlDataSlotRatio}
    [Documentation]      List containing tddframestructure parameters
    ...                  Creation Date: 20.01.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.zak@nokia.com

    ${tddFrameStructure_values_dict}     Create Dictionary    frameStructureType=${frameStructureType}
    ...                                                       guardPeriodLength=${guardPeriodLength}
    ...                                                       lteToNrFrameShift=${lteToNrFrameShift}
    ...                                                       tdLteUlDlConfig=${tdLteUlDlConfig}
    ...                                                       ulDlDataSlotRatio=${ulDlDataSlotRatio}
    ${tddFrameStructure_values_list}     Create List    ${tddFrameStructure_values_dict}
    ${tddFrameStructure_param}           Create Dictionary    parameterName=tddFrameStructure
    ...    value=${tddFrameStructure_values_list}    operation=update
    ${tddFrameStructure_parameters_list}    Create List    ${tddFrameStructure_param}
    [Return]    ${tddFrameStructure_parameters_list}

Configure TddFrameStructure
    [Arguments]     ${frameStructureType}     ${guardPeriodLength}    ${lteToNrFrameShift}
    ...             ${tdLteUlDlConfig}    ${ulDlDataSlotRatio}      ${skip_errors}
    [Documentation]      Configure tddframestructure
    ...                  Creation Date: 20.01.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.zak@nokia.com

    admin.Connect To
    ${tddFrameStructure_parameters_list}    Create tddFrameStructure Parameters List    ${frameStructureType}
    ...             ${guardPeriodLength}    ${lteToNrFrameShift}
    ...             ${tdLteUlDlConfig}    ${ulDlDataSlotRatio}
    admin.Perform Object Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=${tddFrameStructure_parameters_list}
    ...    operation=update
    ...    skip_parameter_relation_errors=${skip_errors}
    Wait For GNB And Radio To Be In Proper State
    [Teardown]    admin.Teardown admin

Configure Frame Structure 5GC001116_3
    [Arguments]     ${frameStructureType}=tdLte     ${guardPeriodLength}=4Symbols    ${lteToNrFrameShift}=3ms
    ...             ${tdLteUlDlConfig}=tdLteConfig2    ${ulDlDataSlotRatio}=3/7    ${skip_errors}=True
    [Documentation]      Configure 5GC001116_3 frame structure
    ...                  Creation Date: 01.02.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.piasecki@nokia.com

    Configure TddFrameStructure    frameStructureType=${frameStructureType}
    ...                            guardPeriodLength=${guardPeriodLength}
    ...                            lteToNrFrameShift=${lteToNrFrameShift}
    ...                            tdLteUlDlConfig=${tdLteUlDlConfig}
    ...                            ulDlDataSlotRatio=${ulDlDataSlotRatio}
    ...                            skip_errors=${skip_errors}

Configure Frame Structure 5GC001116_0
    [Arguments]     ${frameStructureType}=tdLte     ${guardPeriodLength}=4Symbols    ${lteToNrFrameShift}=0ms
    ...             ${tdLteUlDlConfig}=tdLteConfig2    ${ulDlDataSlotRatio}=3/7    ${skip_errors}=True
    [Documentation]      Configure 5GC001116_0 frame structure
    ...                  Creation Date: 01.02.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.piasecki@nokia.com

    Configure TddFrameStructure    frameStructureType=${frameStructureType}
    ...                            guardPeriodLength=${guardPeriodLength}
    ...                            lteToNrFrameShift=${lteToNrFrameShift}
    ...                            tdLteUlDlConfig=${tdLteUlDlConfig}
    ...                            ulDlDataSlotRatio=${ulDlDataSlotRatio}
    ...                            skip_errors=${skip_errors}

Configure Frame Structure 5GC001070
    [Arguments]     ${frameStructureType}=semiStatic     ${guardPeriodLength}=2Symbols    ${lteToNrFrameShift}=
    ...             ${tdLteUlDlConfig}=tdLteConfig2    ${ulDlDataSlotRatio}=3/7    ${skip_errors}=True
    [Documentation]      Configure 5GC001070 frame structure
    ...                  Creation Date: 01.02.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.piasecki@nokia.com

    Configure TddFrameStructure    frameStructureType=${frameStructureType}
    ...                            guardPeriodLength=${guardPeriodLength}
    ...                            lteToNrFrameShift=${lteToNrFrameShift}
    ...                            tdLteUlDlConfig=${tdLteUlDlConfig}
    ...                            ulDlDataSlotRatio=${ulDlDataSlotRatio}
    ...                            skip_errors=${skip_errors}

Perform HO Delta Recommissioning
    [Arguments]    ${delta_file}
    [Documentation]      Adding necessary objects and parameters for HO using json delta file
    ...                  Creation Date: 09.04.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.zak@nokia.com

    admin.Connect To
    Run Keyword    admin.Perform delta recommissioning
    ...    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    Wait For GNB And Radio To Be In Proper State
    [Teardown]    admin.Teardown admin

Change GNB IP Address
    [Arguments]    ${address}=${GNB_BH_IP}
    [Documentation]      Change gNB  IP address
    ...                  Creation Date: 28.04.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.piasecki@nokia.com

    admin.Connect To
    Change Configuration Parameter
    ...    dist_name=MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-1
    ...    parameter=localIpAddr
    ...    value=${address}
    Wait For GNB And Radio To Be In Proper State
    [Teardown]    admin.Teardown admin

change miRxWindowStats Value
    [Arguments]    ${value}
    [Documentation]      Change pMaxNROwnCell value
    ...                  Creation Date: 20.01.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.zak@nokia.com

    #admin.Connect To
    #admin.connect_to    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'    password='nemuuser'    use_ssl=True
    #...    update_interval=5000    admin_api_log_dir=''    name='default'    bundle_path=None    reconnect_with_default_on_failure=False   
    taf.gnb.oam.coam.admin.Setup Admin    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'    password='nemuuser'    use_ssl=True
    ...    update_interval=5000 
    Change Configuration Parameter
    ...    dist_name=MRBTS-9/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=miRxWindowStats
    ...    value=${value}
    [Teardown]    admin.Teardown admin

change miTrRxWindowStats Value
    [Arguments]    ${value}
    [Documentation]      Change pMaxNROwnCell value
    ...                  Creation Date: 20.01.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.zak@nokia.com

    #admin.Connect To
    #admin.connect_to    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'    password='nemuuser'    use_ssl=True
    #...    update_interval=5000    admin_api_log_dir=''    name='default'    bundle_path=None    reconnect_with_default_on_failure=False
    admin.setup_admin    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'    password='nemuuser'    use_ssl=True
    ...    update_interval=5000    
    Change Configuration Parameter
    ...    dist_name=MRBTS-9/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter=miTrRxWindowStats
    ...    value=${value}
    [Teardown]    admin.Teardown admin

change miNrEcpriUpFCp Value
    [Arguments]    ${value}
    [Documentation]      Change pMaxNROwnCell value
    ...                  Creation Date: 20.01.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.zak@nokia.com

    #admin.Connect To
    #admin.connect_to    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'    password='nemuuser'    use_ssl=True
    #...    update_interval=5000    admin_api_log_dir=''    name='default'    bundle_path=None    reconnect_with_default_on_failure=False
    admin.setup_admin    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'    password='nemuuser'    use_ssl=True
    ...    update_interval=5000    
    Change Configuration Parameter
    ...    dist_name=MRBTS-9/NRBTS-602/NRPMRNL-1
    ...    parameter=miNrEcpriUpFCp
    ...    value=${value}
    [Teardown]    admin.Teardown admin

Change Configuration Parameter
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    [Documentation]      Generic keyword to change single parameter value
    ...                  Creation Date: 12.12.2020
    ...                  Modified Date:
    ...                  Last Modified by: jacek.kozmic@nokia.com
    ${current_value}    Get Current Parameter Value    ${dist_name}    ${parameter}
    Run Keyword If    '${current_value}'!='${value}'
    ...    admin.Perform Parameter Recommissioning    dist_name=${dist_name}
    ...                                               parameter=${parameter}
    ...                                               operation=update
    ...                                               value=${value}
    ...                                               skip_parameter_relation_errors=True

Get Current Parameter Value
    [Arguments]    ${dist_name}    ${param_name}
    [Documentation]      Checking if object exist in current SCF file
    ...                  Creation Date: 11.12.2020
    ...                  Modified Date:
    ...                  Last Modified by: damian.piasecki@nokia.com
    ${temp_scf_file}    admin.Get Current Scf File    local_dir_path=/tmp
    ...                                               file_name=temp_scf.xml
    scf.Load Scf    ${temp_scf_file}
    ${param_value}   scf.get_value_from_scf    dist_name=${dist_name}    p_name=${param_name}
    [Return]    ${param_value}