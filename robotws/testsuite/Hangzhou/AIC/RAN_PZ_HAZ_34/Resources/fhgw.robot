*** Settings ***
Documentation
#...   jie.8.liu@nokia-sbell.com

*** Variables ***

*** Keywords ***
Get FHGW Package info
    [Arguments]    ${sw_package}
    log to console   ${sw_package}
    @{fhgw_version_list}=     split_string    ${sw_package}   _
    ${fhgw_version_name}   set variable   ${fhgw_version_list[0]}
    @{version_num}   split_string    ${fhgw_version_list[1]}   .
    ${version_info}   set variable   ${version_num[0]}.${version_num[1]}.${version_num[2]}
    ${version_news}   set variable   ${fhgw_version_list[0]}_${version_info}
    ${index_url}   Set Variable
    ...  http://10.109.2.86/artifactory/fhgw-releasedbuilds/builds/${fhgw_version_list[0]}/${version_news}/Artifacts
    ${file_name}   _Get Package File Name   ${index_url}   ${fhgw_version_name}
    ${import_build_info}     set variable     ${version_news}_${fhgw_version_list[3]}
    ${package_link}   set variable    ${index_url}/${file_name}
    [Return]   ${package_link}    ${import_build_info}


_Get Package File Name
    [Arguments]   ${url}   ${fhgw_version_name}
    ${file_path}   Get A Directory    fhgw_index
    OperatingSystem.Run   command=wget -P ${file_path} ${url}
    ${file_name}   get_info_from_file_with_re    ${file_path}/Artifacts    >${fhgw_version_name}.+tar.gz
    ${file_name}   Get Substring    ${file_name}   1
    [Return]    ${file_name}


FHGW Get Nidd Adaption Version
    [Documentation]  GW Get Nidd Adaption Version
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    NIDD_Adaptation_Version_CM
    ...
    ...    Example
    ...    | ${version} | GW Get Nidd Adaption Version |
    ...
    ${fhgw_alias}=   Get Unique Id
    Connect to FHGW   alias=${fhgw_alias}
    ${out}   issh.Execute  command=cat /etc/fhgw-release   alias=${fhgw_alias}
    ${res}=  Get Regexp Matches   ${out}   NIDD_Adaptation_Version_CM=(\\S+)   1
    ${nidd_adaption_version}   Convert To String   ${res[0]}
    Disconnect Interactive Connection  alias=${fhgw_alias}
    [Return]   ${nidd_adaption_version}


FHGW Generate SCF For Ecpri Master
    [Arguments]   ${master_dn_list}  ${gnb_index}=0   ${fhgw_index}=0
    [Documentation]  FHGW Generate SCF For Ecpri Master
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | master_dn_list   |  yes | master dn list to be configured |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     fhgw scf file
    ...
    ...    Example
    ...    | ${scf_path} | FHGW Generate SCF For Ecpri Master | ${master_dn_list} |
    ...
    ${fhgw_config}    Get FHGW Config   gnb_index=${gnb_index}  fhgw_index=${fhgw_index}
    ${fhgw_id}=    Set Variable   ${fhgw_config["FHGW"]["fhgwId"]}
    ${fhgw_name}   Set Variable   ${fhgw_config["FHGW"]["fhgwName"]}
    ${timestamp}=         DateTime.Get Current Date    result_format=%Y-%m-%dT%H:%M:%S+02:00
    ${xml1}=  Set Variable    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    ${xml2}=  Set Variable    <raml version="2.1" xmlns="raml21.xsd">
    ${xml3}=  Set Variable    <cmData type="plan" scope="changes" name="${fhgw_name}"><header>
    ${xml4}=  Set Variable  <log action="create" dateTime="${timestamp}">TA Update Snc Master</log>
    ${xml5}=  Set Variable  </header></cmData></raml>
    ${xmlfile}=    Set Variable    ${xml1}${xml2}${xml3}${xml4}${xml5}
    ${alias}   Get Unique Id
	${path_to_plan}   Get A File   scf  sync_master_${alias}.xml
    create file  ${path_to_plan}  ${xmlfile}
    ${version}=  FHGW Get Nidd Adaption Version
    ${dist_name}=   Set Variable  ${fhgw_name}/MNL-1/SYNC-1
    scf.Load_Scf  file_path=${path_to_plan}
    scf.Add_Object_To_Scf  class_name=com.nokia.fhgw:SYNC  dist_name=${dist_name}  version=${version}  operation=update
    scf.Add_Element_To_Scf  dist_name=${dist_name}   p_name=actEcpriMasterClock  value=1
    scf.Add_List_To_Scf     dist_name=${dist_name}  list_name=eCpriMasterPortConfDNList
    scf.Add_Elements_To_List  dist_name=${dist_name}  list_name=eCpriMasterPortConfDNList  elements=${master_dn_list}
    FOR   ${item}   IN   @{master_dn_list}
      scf.Add_Object_To_Scf  class_name=com.nokia.fhgw:INTF  dist_name=${item}
    ...  version=${version}  operation=update
      scf.Add_Element_To_Scf  dist_name=${item}   p_name=adminState  value=1
    END
    scf.save_scf   ${path_to_plan}
    [Return]    ${path_to_plan}


FHGW Get ECpriMasterPortConfDNList
    [Arguments]     ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]  FHGW Get ECpriMasterPortConfDNList
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     master port configure dn list
    ...
    ...    Example
    ...    | ${dn_list} | FHGW Get ECpriMasterPortConfDNList |
    ...
    ${alias}  Get Unique Id
    Connect to FHGW  alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${out}   issh.Execute   command=redis-cli get eCpriMasterPortConfDNList   check_result=${False}   alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${master_port_dn_list}  Get Regexp Matches  ${out}  (FHGW-\\d+/TNL-1/INTF-frontPanelPort_\\d+)  1
    [Return]  ${master_port_dn_list}


FHGW Get ECpriMasterPortConfList
    [Arguments]     ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]  FHGW Get ECpriMasterPortConfList
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     master port configure list
    ...
    ...    Example
    ...    | ${master_conf_list} | FHGW Get ECpriMasterPortConfList |
    ...
    ${alias}  Get Unique Id
    Connect to FHGW  alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${out}   issh.Execute   command=redis-cli get eCpriMasterPortConfList   check_result=${False}   alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${master_port_list}  Get Regexp Matches  ${out}  PORT-(\\d+)  1
    [Return]  ${master_port_list}


FHGW Get ptpSyncInPort From Testline Config
    [Arguments]     ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Documentation]  FHGW Get ptpSyncInPort
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     ptp SyncIn Port
    ...
    ...    Example
    ...    | ${ptpSyncInPort} | FHGW Get ptpSyncInPort |
    ...
    ${fhgw_dict}  get_fhgw_extra_config_dictionary_from_testLine  gnb_index=${gnb_index}
    ...  vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${ptpSyncInPort}  pop_from_dictionary  ${fhgw_dict}  ptpSyncInPort   0
    [Return]  ${ptpSyncInPort}


FHGW Get PtpSyncInPortConfDNList
    [Arguments]     ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]  FHGW Get PtpSyncInPortConfDNList
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     ptp sync in port configure dn list
    ...
    ...    Example
    ...    | ${port_dn_list} | FHGW Get PtpSyncInPortConfDNList |
    ...
    ${alias}  Get Unique Id
    Connect to FHGW  alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${out}   issh.Execute   command=redis-cli get ptpSyncInPortConfDNList   check_result=${False}   alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${syncin_dn_list}  Get Regexp Matches  ${out}  (FHGW-\\d+/TNL-1/INTF-frontPanelPort_\\d+)  1
    [Return]  ${syncin_dn_list}


FHGW Master Clock Should Be OK
    [Arguments]     ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]  FHGW Master Clock Should Be OK
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     None
    ...
    ...    Example
    ...    | FHGW Master Clock Should Be OK |
    ...

    ${alias}  Get Unique Id
    Connect to FHGW  alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${out}   issh.Execute   command=redis-cli get eCpriMasterClockState   check_result=${False}   alias=${alias}
    ${out}  Strip Prompt  ${out}
    Should Contain  ${out}   MASTER_CLOCK_OK


FHGW Sync Status Should Be Locked
    [Arguments]     ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]  FHGW Sync Status Should Be Locked
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     None
    ...
    ...    Example
    ...    | FHGW Sync Status Should Be Locked |
    ...
    ${alias}  Get Unique Id
    Connect to FHGW  alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${out}   issh.Execute   command=redis-cli get syncStatus  check_result=${False}   alias=${alias}
    ${out}  Strip Prompt  ${out}
    Should Contain  ${out}   LOCKED


FHGW Generate SCF For PTP sync
    [Arguments]   ${master_dn_list}  ${gnb_index}=0   ${fhgw_index}=0
    [Documentation]  FHGW Generate SCF For Ecpri Master
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | master_dn_list   |  yes | master dn list to be configured |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     fhgw scf file
    ...
    ...    Example
    ...    | ${scf_path} | FHGW Generate SCF For PTP sync | ${master_dn_list} |
    ...
    ${fhgw_config}    Get FHGW Config   gnb_index=${gnb_index}  fhgw_index=${fhgw_index}
    ${fhgw_id}=    Set Variable   ${fhgw_config["FHGW"]["fhgwId"]}
    ${fhgw_name}   Set Variable   ${fhgw_config["FHGW"]["fhgwName"]}
    ${timestamp}=         DateTime.Get Current Date    result_format=%Y-%m-%dT%H:%M:%S+02:00
    ${xml1}=  Set Variable    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    ${xml2}=  Set Variable    <raml version="2.1" xmlns="raml21.xsd">
    ${xml3}=  Set Variable    <cmData type="plan" scope="changes" name="${fhgw_name}"><header>
    ${xml4}=  Set Variable    <log action="create" dateTime="${timestamp}">TA Update to PTP sync</log>
    ${xml5}=  Set Variable    </header></cmData></raml>
    ${xmlfile}=    Set Variable    ${xml1}${xml2}${xml3}${xml4}${xml5}
    ${alias}   Get Unique Id
	${path_to_plan}   Get A File   scf  sync_ptp_${alias}.xml
    create file  ${path_to_plan}  ${xmlfile}
    ${version}=  FHGW Get Nidd Adaption Version
    ${dist_name_sync}=   Set Variable  ${fhgw_name}/MNL-1/SYNC-1
    ${dist_name_clock}=   Set Variable  ${fhgw_name}/MNL-1/SYNC-1/CLOCK-1
    scf.Load_Scf  file_path=${path_to_plan}
    scf.Add_Object_To_Scf  class_name=com.nokia.fhgw:SYNC  dist_name=${dist_name_sync}  version=${version}
    ...  operation=update
    scf.Add_Element_To_Scf  dist_name=${dist_name_sync}   p_name=ptpSyncInPortConfDNList  value=${master_dn_list}

    scf.Add_Object_To_Scf  class_name=com.nokia.fhgw:CLOCK  dist_name=${dist_name_clock}  version=${version}
    ...  operation=update
    scf.Add_List_To_Scf     dist_name=${dist_name_clock}  list_name=syncInputList
    ${ptp_dict}         Create dictionary       syncInputType     15      syncInputPrio    1
    scf.Add_Item_To_List    dist_name=${dist_name_clock}   list_name=syncInputList     elements=${ptp_dict}

    scf.Add_Object_To_Scf  class_name=com.nokia.fhgw:INTF  dist_name=${master_dn_list}   version=${version}
    ...  operation=update
    scf.Add_Element_To_Scf  dist_name=${master_dn_list}  p_name=adminState  value=1


    scf.save_scf   ${path_to_plan}
    [Return]    ${path_to_plan}


FHGW Generate SCF For DomainNumber
    [Arguments]   ${domain_number}  ${gnb_index}=0   ${fhgw_index}=0
    [Documentation]  FHGW Generate SCF For Ecpri Master
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | master_dn_list   |  yes | master dn list to be configured |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     fhgw scf file
    ...
    ...    Example
    ...    | ${scf_path} | FHGW Generate SCF For Ecpri Master |  ${domain_number}|
    ...
    ${fhgw_config}    Get FHGW Config   gnb_index=${gnb_index}  fhgw_index=${fhgw_index}
    ${fhgw_id}=    Set Variable   ${fhgw_config["FHGW"]["fhgwId"]}
    ${fhgw_name}   Set Variable   ${fhgw_config["FHGW"]["fhgwName"]}
    ${version}=  FHGW Get Nidd Adaption Version
    ${distName}   Set Variable    ${fhgw_id}/MNL-1/SYNC-1/CLOCK-1/TOPP-1
    ${timestamp}=         DateTime.Get Current Date    result_format=%Y-%m-%dT%H:%M:%S+02:00
    ${xml1}=  Set Variable    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    ${xml2}=  Set Variable    <raml version="2.1" xmlns="raml21.xsd">
    ${xml3}=  Set Variable    <cmData type="plan" scope="changes" name="${fhgw_name}"><header>
    ${xml4}=  Set Variable    <log action="create" dateTime="${timestamp}">TA Update DomainNumber</log>
    ${xml5}=  Set Variable    </header></cmData></raml>
    ${xmlfile}=    Set Variable    ${xml1}${xml2}${xml3}${xml4}${xml5}
    ${alias}   Get Unique Id
	${path_to_plan}   Get A File   scf  sync_domain_${alias}.xml
    create file  ${path_to_plan}  ${xmlfile}
    ${version}=  FHGW Get Nidd Adaption Version
    ${dist_name_topp}=   Set Variable  ${fhgw_name}/MNL-1/SYNC-1/CLOCK-1/TOPP-1
    scf.Load_Scf  file_path=${path_to_plan}
    scf.Add_Object_To_Scf  class_name=com.nokia.fhgw:TOPP  dist_name=${dist_name_topp}  version=${version}
    ...  operation=update
    scf.Add_Element_To_Scf  dist_name=${dist_name_topp}   p_name=topDomainNumber  value=${domain_number}

    create file  ${path_to_plan}  ${xmlfile}
    scf.save_scf   ${path_to_plan}
    [Return]    ${path_to_plan}


FHGW Sync Input Type Shoube be Correct
    [Arguments]     ${synctype}   ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]  FHGW Master Clock Should Be OK
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | synctype      |  yes | TOPP, GNSS |
    ...    *RETURN VALUE*
    ...     None
    ...
    ...    Example
    ...    | FHGW Sync Input Type Shoube be Correct|  ${synctype}|
    ...
    ${alias}  Get Unique Id
    Connect to FHGW  alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${out}   issh.Execute   command=redis-cli get syncInputType   check_result=${False}   alias=${alias}
    ${out}  Strip Prompt  ${out}
    Should Contain  ${out}   ${synctype}


Get FHGW Sync Input Type
    [Arguments]    ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]  FHGW Master Clock Should Be OK
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | synctype      |  yes | TOPP, GNSS |
    ...    *RETURN VALUE*
    ...     None
    ...
    ...    Example
    ...    | FHGW Sync Input Type Shoube be Correct|  ${synctype}|
    ...
    ${alias}  Get Unique Id
    Connect to FHGW  alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${out}   issh.Execute   command=redis-cli get syncInputType   check_result=${False}   alias=${alias}
    ${out}  Strip Prompt  ${out}
    [Return]   ${out}


FHGW Generate SCF For ECpriMasterDomainNumber
    [Arguments]   ${domain_number}  ${gnb_index}=0   ${fhgw_index}=0
    [Documentation]  FHGW Generate SCF For ECpriMasterDomainNumber
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | domain_number   |  yes | domain_number to configure |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     fhgw scf file
    ...
    ...    Example
    ...    | ${scf_path} | FHGW Generate SCF For ECpriMasterDomainNumber |  ${domain_number}|
    ...
    ${fhgw_config}    Get FHGW Config   gnb_index=${gnb_index}  fhgw_index=${fhgw_index}
    ${fhgw_id}=    Set Variable   ${fhgw_config["FHGW"]["fhgwId"]}
    ${fhgw_name}   Set Variable   ${fhgw_config["FHGW"]["fhgwName"]}
    ${version}=  FHGW Get Nidd Adaption Version
    ${distName}   Set Variable    ${fhgw_id}/MNL-1/SYNC-1/CLOCK-1/TOPP-1
    ${timestamp}=         DateTime.Get Current Date    result_format=%Y-%m-%dT%H:%M:%S+02:00
    ${xml1}=  Set Variable    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    ${xml2}=  Set Variable    <raml version="2.1" xmlns="raml21.xsd">
    ${xml3}=  Set Variable    <cmData type="plan" scope="changes" name="${fhgw_name}"><header>
    ${xml4}=  Set Variable    <log action="create" dateTime="${timestamp}">TA Update DomainNumber</log>
    ${xml5}=  Set Variable    </header></cmData></raml>
    ${xmlfile}=    Set Variable    ${xml1}${xml2}${xml3}${xml4}${xml5}
    ${alias}   Get Unique Id
	${path_to_plan}   Get A File   scf  sync_ecprimaster_domain_${alias}.xml
    Create File  ${path_to_plan}  ${xmlfile}
    ${version}=  FHGW Get Nidd Adaption Version
    ${dist_name_ecprimaster}=   Set Variable  ${fhgw_name}/MNL-1/SYNC-1/ECPRIMASTER-1
    scf.Load_Scf  file_path=${path_to_plan}
    scf.Add_Object_To_Scf  class_name=com.nokia.fhgw:ECPRIMASTER  dist_name=${dist_name_ecprimaster}
    ...  version=${version}  operation=update
    scf.Add_Element_To_Scf  dist_name=${dist_name_ecprimaster}   p_name=eCpriMasterDomainNumber  value=${domain_number}
    Create File  ${path_to_plan}  ${xmlfile}
    scf.Save_Scf   ${path_to_plan}
    [Return]    ${path_to_plan}


FHGW Get TopDomainNumber
    [Arguments]     ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]  FHGW Get TopDomainNumber
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     TopDomainNumber
    ...
    ...    Example
    ...    | FHGW Get TopDomainNumber |
    ...
    ${alias}  Get Unique Id
    ${sync_type}   Get FHGW Sync Input Type
    Return From Keyword If    '''TOPP''' not in '''${sync_type}'''   -1
    ${fhgw_account_info}   Get FHGW Account Info
    ${password}   Set Variable  ${fhgw_account_info["admin_user_password_plain"]}
    Connect to FHGW  alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${old_prompt}  issh.get_prompt   alias=${alias}
    ${new_prompt}  Set Variable  ${old_prompt}|Password:
    issh.set_prompt    ${new_prompt}    alias=${alias}
    issh.Execute   command=sudo fhgwcli config-mgmt getcurrentconfig FHGW  check_result=${False}   alias=${alias}
#    issh.Execute   command=fhgwcli config-mgmt getcurrentconfig SYNC  check_result=${False}   alias=${alias}
#    Sleep  3sec
#    issh.Execute   command=${password}  check_result=${False}   alias=${alias}
#    issh.set_prompt  ${old_prompt}   alias=${alias}
    Sleep  15sec

    ${out}   issh.Execute   command=sudo cat /root/cmnmsutils/data_SYNC.xml | grep topDomainNumber
    ...  check_result=${False}   alias=${alias}
    Sleep  3sec
#    ${out}   issh.Execute   command=${password}  check_result=${False}   alias=${alias}
#    ${cmd}  set variable  cat /home/toor4nsn/cmnmsutils/data_SYNC.xml | grep topDomainNumber
#    ${out}  Run Keyword If  '''topDomainNumber''' not in '''${out}'''  issh.Execute   command=${cmd}
#    ...  check_result=${False}   alias=${alias}
#    ...   ELSE    set variable   ${out}
#    issh.set_prompt  ${old_prompt}   alias=${alias}
    ${top_domain}   Get Regexp Matches  ${out}  <p name="topDomainNumber">(\\d+)</p>  1
    [Return]  ${top_domain[0]}


FHGW Get ECpriMasterDomainNumber
    [Arguments]     ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]  FHGW Get ECpriMasterDomainNumber
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    eCpriMasterDomainNumber
    ...
    ...    Example
    ...    | FHGW Get ECpriMasterDomainNumber |
    ...
    ${alias}  Get Unique Id
    ${sync_type}   Get FHGW Sync Input Type
    Return From Keyword If    '''TOPP''' not in '''${sync_type}'''   -1
    ${fhgw_account_info}   Get FHGW Account Info
    ${password}   Set Variable  ${fhgw_account_info["admin_user_password_plain"]}
    Connect to FHGW  alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${old_prompt}  issh.Get_Prompt   alias=${alias}
    ${new_prompt}  Set Variable  ${old_prompt}|Password:
    issh.Set_Prompt    ${new_prompt}    alias=${alias}
    issh.Execute   command=sudo fhgwcli config-mgmt getcurrentconfig FHGW  check_result=${False}   alias=${alias}
#    issh.Execute   command=fhgwcli config-mgmt getcurrentconfig SYNC  check_result=${False}   alias=${alias}
#    Sleep  3sec
#    issh.Execute   command=${password}  check_result=${False}   alias=${alias}
#    issh.Set_Prompt  ${old_prompt}   alias=${alias}
    Sleep  15sec
    ${out}   issh.Execute   command=sudo cat /root/cmnmsutils/data_SYNC.xml | grep eCpriMasterDomainNumber
    ...  check_result=${False}   alias=${alias}
#    Sleep  3sec
#    ${out}   issh.Execute   command=${password}  check_result=${False}   alias=${alias}
#    issh.Set_Prompt  ${old_prompt}   alias=${alias}
#    ${cmd}  set variable  sudo cat /root/cmnmsutils/data_SYNC.xml | grep eCpriMasterDomainNumber
#    ${out}  Run Keyword If  '''eCpriMasterDomainNumber''' not in '''${out}'''  issh.Execute   command=${cmd}
#    ...  check_result=${False}   alias=${alias}
#    ...   ELSE    set variable   ${out}
    ${top_domain}   Get Regexp Matches  ${out}  <p name="eCpriMasterDomainNumber">(\\d+)</p>  1
    [Return]  ${top_domain[0]}


FHGW Restart SyncApp
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]  FHGW Restart SyncApp
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | FHGW Restart SyncApp |
    ...
    ${alias}  Get Unique Id
    ${fhgw_account_info}   Get FHGW Account Info
    ${password}   Set Variable  ${fhgw_account_info["admin_user_password_plain"]}
    Connect to FHGW  alias=${alias}
    ${old_prompt}  issh.Get_Prompt   alias=${alias}
    ${new_prompt}  Set Variable  ${old_prompt}|assword:
    issh.Set_Prompt    ${new_prompt}    alias=${alias}
    ${res}=   issh.Execute  command=sudo systemctl restart syncApp switch-manager  check_result=${False}
     ...  alias=${alias}
    sleep  2s
    ${out}   Run Keyword If   """assword:""" in """${res}"""  issh.execute  command=${password}
    ...  check_result=${False}   alias=${alias}
    issh.set_prompt   ${old_prompt}   alias=${alias}


FHGW Get Acitve Alarms
    [Arguments]     ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]  FHGW Get Acitve Alarms
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     master port configure dn list
    ...
    ...    Example
    ...    | ${dn_list} | FHGW Get ECpriMasterPortConfDNList |
    ...
    ${alias}  Get Unique Id
    Connect to FHGW  alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
#    ${out}   issh.Execute   command=fhgwcli alarms list active-detailed   check_result=${False}   alias=${alias}
#    ${out}  Strip Prompt  ${out}
    ${out}   issh.Execute   command=fhgwcli alarms list active-detailed |awk '{print$3}'
    ...  check_result=${False}   alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${alarm_list}  Get Regexp Matches  ${out}  (\\d+)  1
    [Return]  ${alarm_list}


FHGW Get History Alarms
    [Arguments]     ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]  FHGW Get History Alarms
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     master port configure dn list
    ...
    ...    Example
    ...    | ${dn_list} | FHGW Get ECpriMasterPortConfDNList |
    ...
    ${alias}  Get Unique Id
    Connect to FHGW  alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
#    ${out}   issh.Execute   command=fhgwcli alarms list history-detailed   check_result=${False}   alias=${alias}
#    ${out}  Strip Prompt  ${out}
    ${old_timerout}   issh.Set Timeout    200    alias=${alias}
    ${out}   issh.Execute   command=fhgwcli alarms list history |awk '{print$5}'
    ...  check_result=${False}   alias=${alias}
    issh.set timeout     ${old_timerout}    alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${alarm_list}  Get Regexp Matches  ${out}  (\\d+)  1
    [Return]  ${alarm_list}


FHGW Generate SCF For Both GPS And PTP Sync
    [Arguments]   ${ecpri_master_dn_list}  ${master_dn_list}  ${gnb_index}=0   ${fhgw_index}=0
    [Documentation]  FHGW Generate SCF For Both GPS And PTP sync
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | master_dn_list   |  yes | master dn list to be configured |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...     fhgw scf file
    ...
    ...    Example
    ...    | ${scf_path} | FHGW Generate SCF For PTP sync | ${master_dn_list} |
    ...
    ${fhgw_config}    Get FHGW Config   gnb_index=${gnb_index}  fhgw_index=${fhgw_index}
    ${fhgw_id}=    Set Variable   ${fhgw_config["FHGW"]["fhgwId"]}
    ${fhgw_name}   Set Variable   ${fhgw_config["FHGW"]["fhgwName"]}
    ${timestamp}=         DateTime.Get Current Date    result_format=%Y-%m-%dT%H:%M:%S+02:00
    ${xml1}=  Set Variable    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    ${xml2}=  Set Variable    <raml version="2.1" xmlns="raml21.xsd">
    ${xml3}=  Set Variable    <cmData type="plan" scope="changes" name="${fhgw_name}"><header>
    ${xml4}=  Set Variable    <log action="create" dateTime="${timestamp}">TA Update to GPS And PTP sync</log>
    ${xml5}=  Set Variable    </header></cmData></raml>
    ${xmlfile}=    Set Variable    ${xml1}${xml2}${xml3}${xml4}${xml5}
    ${alias}   Get Unique Id
	${path_to_plan}   Get A File   scf  sync_gps_and_ptp_${alias}.xml
    create file  ${path_to_plan}  ${xmlfile}
    ${version}=  FHGW Get Nidd Adaption Version
    ${dist_name_sync}=   Set Variable  ${fhgw_name}/MNL-1/SYNC-1
    ${dist_name_clock}=   Set Variable  ${fhgw_name}/MNL-1/SYNC-1/CLOCK-1
    scf.Load_Scf  file_path=${path_to_plan}
    scf.Add_Object_To_Scf  class_name=com.nokia.fhgw:INTF  dist_name=${master_dn_list}   version=${version}
    ...  operation=update
    scf.Add_Element_To_Scf  dist_name=${master_dn_list}  p_name=adminState  value=1

    scf.Add_Object_To_Scf  class_name=com.nokia.fhgw:SYNC  dist_name=${dist_name_sync}  version=${version}
    ...  operation=update
    scf.Add_Element_To_Scf  dist_name=${dist_name_sync}   p_name=ptpSyncInPortConfDNList  value=${master_dn_list}

    scf.Add_Element_To_Scf  dist_name=${dist_name_sync}   p_name=actEcpriMasterClock  value=1
    scf.Add_List_To_Scf     dist_name=${dist_name_sync}   list_name=eCpriMasterPortConfDNList
    scf.Add_Elements_To_List  dist_name=${dist_name_sync}  list_name=eCpriMasterPortConfDNList
    ...  elements=${ecpri_master_dn_list}

    scf.Add_Object_To_Scf  class_name=com.nokia.fhgw:CLOCK  dist_name=${dist_name_clock}  version=${version}
    ...  operation=update
    scf.Add_List_To_Scf     dist_name=${dist_name_clock}  list_name=syncInputList
    ${ptp_dict}         Create dictionary       syncInputType     15      syncInputPrio    1
    scf.Add_Item_To_List    dist_name=${dist_name_clock}   list_name=syncInputList     elements=${ptp_dict}

    ${gps_dict}         Create dictionary       syncInputType     2      syncInputPrio    2
    scf.Add_Item_To_List    dist_name=${dist_name_clock}   list_name=syncInputList     elements=${gps_dict}
    scf.save_scf   ${path_to_plan}
    [Return]    ${path_to_plan}


FHGW Active Sync Type Shoube be Correct
    [Arguments]     ${synctype}   ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]   Run Keyword And Ignore Error  Disconnect Interactive Connection   alias=${alias}
    [Documentation]  FHGW Active Sync Type Shoube be Correct
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...    | synctype      |  yes | TOPP, GNSS |
    ...    *RETURN VALUE*
    ...     None
    ...
    ...    Example
    ...    | FHGW Sync Input Type Shoube be Correct|  ${synctype}|
    ...
    ${alias}  Get Unique Id
    Connect to FHGW  alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}  fhgw_index=${fhgw_index}
    ${out}   issh.Execute   command=redis-cli get activeTimeSource   check_result=${False}   alias=${alias}
    ${out}  Strip Prompt  ${out}
    Should Contain  ${out}   ${synctype}
