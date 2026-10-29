*** Settings ***
Library     BuiltIn
Library     OperatingSystem
Library     XML   True
#Library     taf.nms.nom         WITH NAME   nom
Library      taf.transport.ssh   WITH NAME   csn
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/siso_resource.robot
#Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
#Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
#Resource     taf/rfrl/common_resources/robot/connection_alias_store.robot

#Resource    Certifacate.robot
#Resource    Integration.robot
Library     Utils.py

#Resource    Certifacate.robot
#Resource    Download.robot
#Resource    Integration.robot

#Resource    ../../common/taf_coam.robot
#Resource    ../../common/taf_nom.robot

Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_nom.robot

Variables   ALL_Variables.py
#Variables   ../../libraries/global_vars.py
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py




*** Variables ***
${SET_NOM_NAME}   NOM07
#${REINTEGRATE_FLAG}   ${False}
${TLS_FLAG}    ${False}
# ${CERT_FLAG}   ${True}
${vault_ip}   10.93.130.149
${vault_username}   root
${vault_password}   Salasana1!
${cert_password}   123456

${target_version}

${hz_service}   https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local
${lte_service}   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build


${integrate_content}   SEPARATOR=
...   <?xml version="1.0" encoding="UTF-8"?><raml xmlns="raml21.xsd" version="2.1">
...       <cmData type="plan" scope="all" name="NE-xxx-Integration-TLS">
...           <header><log dateTime="2021-10-28T05:52:40Z" action="export"></log></header>
...           <managedObject distName="MRBTS-xxx/MRBTSINT-AUTO" class="com.nokia.nms.integration:MRBTSINT" operation="create" version="1.0">
...               <p name="sbiNetConnectedTo">sbi-default-ipv4</p>
...               <p name="tlsHostNameCheck">false</p>
...               <p name="username">wsuser</p>
...               <p name="password">A0zY~rP#8Mx@</p>
...               <p name="host">xx.xx.xx.xx</p>
...               <p name="tlsCA"></p>
...           </managedObject>
...       </cmData>
...   </raml>


${deintegrate_content}   SEPARATOR=
...    <?xml version="1.0" encoding="UTF-8"?><raml xmlns="raml21.xsd" version="2.1">
...        <cmData type="plan" scope="all" name="NE-xxx-Deintegration">
...            <managedObject distName="MRBTS-xx/MRBTSINT-AUTO" class="com.nokia.nms.integration:MRBTSINT" operation="delete" version="1.0" />
...        </cmData>
...    </raml>




*** Keywords ***
Common Setup
    [Arguments]   ${NOM_NAME}=${SET_NOM_NAME}
    Log To Console   ${EMPTY}
    Set Suite Variable   ${BTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable   ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
    Set Suite Variable   ${MO_NAME}   MRBTS-${BTS_ID}
    Set Suite Variable   ${NRBTS_NAME}   MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    Set Suite Variable   ${DN}   PLMN-PLMN/${MO_NAME}
    Set Suite Variable   ${NOM_NAME}
    Set Suite Variable     ${MO_ID}       ${MO_NAME}/MNL-1/MNL_R-1
    Get ALL Suite Variables
    COAM Login
    ${status}   Run Keyword And Return Status   NOM Login
    run keyword if  not ${status}   Run Keywords
    ...   Run Keyword And Ignore Error   NOM Logout   AND
    ...   NOM Login
    #Run Keyword If   ${REINTEGRATE_FLAG}   ReIntegrate GNB To NOM
    Log ALL Suite Variables

Common Teardown
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword And Ignore Error   NOM Logout
    CI_interface.Common Case Teardown



Get ALL Suite Variables
    Set Suite Variable   ${APIGW_URI}   ${ALL_NOM_Variables['${NOM_NAME}']['apigw_uri']}
    Set Suite Variable   ${USER_MGMT_URI}   ${ALL_NOM_Variables['${NOM_NAME}']['user_mgmt_uri']}
    Set Suite Variable   ${API_USERNAME}   ${ALL_NOM_Variables['${NOM_NAME}']['api_username']}
    Set Suite Variable   ${API_PASSWORD}   ${ALL_NOM_Variables['${NOM_NAME}']['api_password']}



Log ALL Suite Variables
    Log To Console   NOM_NAME: ${NOM_NAME}
    Log To Console   APIGW_URI: ${APIGW_URI}
    Log To Console   USER_MGMT_URI: ${USER_MGMT_URI}
    Log To Console   API_USERNAME: ${API_USERNAME}
    Log To Console   API_PASSWORD: ${API_PASSWORD}
    Log To Console   BTS_ID: ${BTS_ID}
    Log To Console   MO_NAME: ${MO_NAME}
    Log To Console   DN: ${DN}
    Log To Console    MO_ID: ${MO_ID}



Check gNB Should Be Normal
    Log To Console  Check gNB Should Be Normal
    Run Keyword And Ignore Error    WEBUI Logout
    WEBUI Login
    run keyword and ignore error    selenium_coam.close_start_up_view_window
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.disable_message_box
    run keyword and ignore error    selenium_coam.refresh_page
    Wait Until Keyword Succeeds    15min    1min    check gNB Staus onAir
    ...  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}    search_text=Operational state
    sleep    5s
    Run Keyword And Ignore Error    WEBUI Logout


Provision SW via connect_to_nom
  [Arguments]   ${DN_NAME}    ${timeout}    ${ne_sw_version}    ${download}    ${activate}
  NOM Login
  ${DN_NAME}     Create List    ${DN_NAME}
  ${status}   Run Keyword and Continue on Failure    nom.provision_sw    integrated_ids=${DN_NAME}
  ...    ne_sw_version=${ne_sw_version}    download=${download}    activate=${activate}    timeout=${timeout}
  log to console    ${status}
  [Teardown]  Run Keyword And Ignore Error   NOM Logout
  [Return]  ${status}


Check the planned version
    Upload Configuration via nom    DN_NAME=${MO_NAME}
    ${bts_active_version}     ${bts_planned_version}    Get planned version from WebUI
    ${active5GRATSWVersion}     ${plannedSWReleaseVersion}    Get Planned_version via NOM
    Should be equal    ${bts_planned_version}     ${plannedSWReleaseVersion}


Check the active version
     Upload Configuration via nom    DN_NAME=${MO_NAME}
     ${return_active_version}   ${return_passive_version}     Get gNB SW version string
     ${activeSWReleaseVersion}     ${passiveSWReleaseVersion}    Get Sw_version via NOM
     Should be equal    ${return_active_version}     ${activeSWReleaseVersion}


Get gNB SW version string
    [Arguments]  ${bts_host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    csn.connect_to   hostname=${bts_host}    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}    alias=connection_du
    csn.send command    command=ls -al /ffs/run/ | grep -i TargetBD | grep -v .p7 | awk '{print $9}'
    ...  connection=connection_du
    ${return_active_version}  csn.Read Output   connection=connection_du
    ${return_active_version}     Remove String    ${return_active_version}   TargetBD_
    ${return_active_version}     Remove String    ${return_active_version}   .xml\n
    log to console   ${return_active_version}
    csn.send command    command=ls -al /ffs/stb/ | grep -i TargetBD | grep -v .p7 | awk '{print $9}'
    ...    connection=connection_du
    ${return_passive_version}  csn.Read Output   connection=connection_du
    ${return_passive_version}     Remove String    ${return_passive_version}   TargetBD_
    ${return_passive_version}     Remove String    ${return_passive_version}   .xml\n
    log to console   ${return_passive_version}
    [Teardown]  csn.disconnect     connection=connection_du
    [Return]    ${return_active_version}   ${return_passive_version}

Get Version
    [Arguments]  ${bts_host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Log To Console    Get Version
    ${connection}    coam.connect_to    bts_host=${bts_host}     name=GNB_OAM
    ${version}    coam.get_sw_version    connection=${connection}
    [Return]    ${version}
    [Teardown]    coam.Teardown  connection=${connection}

Upload Configuration via nom
   [Arguments]    ${DN_NAME}
    #${client_id}     Connect to NOM
    #${operation_deintegrate_id}    nom.deintegrate_ne  plan_name=${deintegrate_plan_name}  timeout=300
    #${operation_integrate_id}    nom.integrate_ne    plan_name=${integrate_plan_name}  timeout=300    reintegrate=${False}
    ${status}   Run Keyword And Return Status   NOM Login
    run keyword if  not ${status}   Run Keywords
    ...   Run Keyword And Ignore Error   NOM Logout   AND
    ...   NOM Login
    sleep     10s
    ${DN_NAME}   Create list    ${DN_NAME}
    Run Keyword And Continue On Failure  nom.upload_parameter   ${DN_NAME}    timeout=60
    [Teardown]  Run Keyword And Ignore Error   NOM Logout

Check Suitable SW Package
    ${sw_version}   Set Variable    None
    @{software_list}   NOM Get Software List
    Log To Console   Get Suitable SW Package IN NOM:
    FOR   ${software_version}   IN   @{software_list}
        ${sw_version}   Set Variable If   '${software_version.find("${RELEASE}")}'!='-1' and '${software_version}'=='${PACKAGE_VERSION}'
        ...     ${software_version}      ${sw_version}
        Exit For Loop If   '${software_version.find("${RELEASE}")}'!='-1' and '${software_version}'=='${PACKAGE_VERSION}'
    END
    Return From Keyword If   '${sw_version}'!='None'   ${sw_version}
    #:FOR   ${software_version}   IN   @{software_list}
    #    ${sw_version}   Set Variable If   '${software_version.find("SBTS")}'!='-1' and '${software_version}'!='${PACKAGE_VERSION}'
    #   ...     ${sw_version}      ${software_version}
    #   Exit For Loop If   '${software_version.find("SBTS")}'!='-1' and '${software_version}'!='${PACKAGE_VERSION}'
    #END
    [Return]   ${sw_version}


Get planned version from WebUI
    [Arguments]  ${bts_host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    csn.connect_to   hostname=${bts_host}    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}    alias=connection_du
    csn.send command    command=ls -al /ffs/run/ | grep -i TargetBD | grep -v .p7 | awk '{print $9}'
    ...  connection=connection_du
    ${bts_active_version}  csn.Read Output   connection=connection_du
    ${bts_active_version}     Remove String    ${bts_active_version}   TargetBD_
    ${bts_active_version}     Remove String   ${bts_active_version}   .xml\n
    log to console   ${bts_active_version}
    csn.send command    command=ls /srv/nfs/ffs:stb/planned | grep -i TargetBD | grep -v .p7
    ...    connection=connection_du
    ${bts_planned_version}  csn.Read Output   connection=connection_du
    ${bts_planned_version}     Remove String    ${bts_planned_version}   TargetBD_
    ${bts_planned_version}     Remove String    ${bts_planned_version}   .xml\n
    log to console   ${bts_planned_version}
    [Teardown]  csn.disconnect     connection=connection_du
    [Return]  ${bts_active_version}     ${bts_planned_version}

Get Sw_version via NOM
     ${status}   Run Keyword And Return Status   NOM Login
     run keyword if  not ${status}   Run Keywords
     ...   Run Keyword And Ignore Error   NOM Logout   AND
     ...   NOM Login
     sleep     10s
     ${MO_ID}    Create List   ${MO_ID}
     ${return_sw_status}    nom.get_managed_objects_parameters   1    ${MO_ID}
     ${activeSWReleaseVersion}      set variable    ${return_sw_status['result'][0]['parameters']['activeSWReleaseVersion']}
     ${passiveSWReleaseVersion}    set variable   ${return_sw_status['result'][0]['parameters']['passiveSWReleaseVersion']}
     [Teardown]  Run Keyword And Ignore Error   NOM Logout
     [Return]   ${activeSWReleaseVersion}     ${passiveSWReleaseVersion}

Get Planned_version via NOM
     ${status}   Run Keyword And Return Status   NOM Login
     run keyword if  not ${status}   Run Keywords
     ...   Run Keyword And Ignore Error   NOM Logout   AND
     ...   NOM Login
     sleep     10s
     ${MO_ID}    Create List    ${MO_ID}
     ${return_sw_status}    nom.get_managed_objects_parameters   1    ${MO_ID}
     ${activeSWReleaseVersion}      set variable    ${return_sw_status['result'][0]['parameters']['activeSWReleaseVersion']}
     ${plannedSWReleaseVersion}    set variable   ${return_sw_status['result'][0]['parameters']['plannedSWReleaseVersion']}
     [Teardown]    Run Keyword And Ignore Error   NOM Logout
     [Return]   ${activeSWReleaseVersion}     ${plannedSWReleaseVersion}



Import Software Package To NOM
    #${packages}   Get_Package_Version   package_header=${RELEASE}
    #Set Suite Variable   ${NEW_PACKAGE_VERSION}   ${packages[0]['version']}
     Set Suite Variable   ${NEW_PACKAGE_VERSION}   ${target_version}
    ${package_path}   Download Classical Common Package   package_version=${NEW_PACKAGE_VERSION}

    Log To Console   Import Software To NOM Started...
    NOM Import Software   file_directory=${OUTPUT_DIR}   file_name=${PACKAGE_NAME}   sw_version=${NEW_PACKAGE_VERSION}
    NOM Check Software Exist   software_version=${NEW_PACKAGE_VERSION}
    OperatingSystem.Run   command=rm -rf ${package_path}
    Log To Console   Import Software To NOM Finished.

    [Return]   ${NEW_PACKAGE_VERSION}


NOM Activate Software And Return Operation ID
    [Documentation]
    ...   @{gnb_list}   Create List   MRBTS-1234   MRBTS-5678
    ...   ${sw_version}   Set Variable   SBTS00_ENB_9999_211103_000002
    [Arguments]   ${gnb_list}   ${sw_version}
    ${status}   Run Keyword And Return Status   NOM Login
    run keyword if  not ${status}   Run Keywords
    ...   Run Keyword And Ignore Error   NOM Logout   AND
    ...   NOM Login
    sleep     10s
    ${operation_id}   nom.provision_sw
    ...   integrated_ids=${gnb_list}
    ...   ne_sw_version=${sw_version}
    ...   download=${False}
    ...   activate=${True}
    ...   timeout=${7200}
    ...   run_async=${True}
    Dictionary Should Contain Key   ${operation_id}   operation_id
    [Return]   ${operation_id['operation_id']}


NOM Get Active Alarms Via Rest
   [Arguments]    ${integrated_id}
   ${status}   Run Keyword And Return Status   NOM Login
   run keyword if  not ${status}    Run Keywords
    ...    Run Keyword And Ignore Error   NOM Logout   AND
    ...   NOM Login
    ${alarms_info}=  nom.get_alarms_from_integrated_ne  integrated_id=${integrated_id}    only_active=${True}
    #${alarm_id}   set variable   ${alarm['specific_problem']}
    ${return_fault}    Utils.get_fault_id_via_nom     ${alarms_info['alarms']}
    ${return_fault}    remove duplicates   ${return_fault}
    sort list  ${return_fault}
    log to console    ${return_fault}
    [Teardown]  Run Keyword And Ignore Error  NOM Logout
    [Return]   ${return_fault}


Get Alarm Info from WebUI
    [Arguments]   ${timeout}    ${alias}=GNB_OAM
    #WEBUI Login
    Connect to gnb coam via ssl
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=${alias}
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    faultId
        ${fault_name}    get from dictionary    ${item}    faultName
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${fault_name_list}    ${fault_name}
    END
    sort list    ${fault_id_list}
    [Teardown]  Run Keyword And Ignore Error   WebUI Logout
    [Return]   ${fault_id_list}



Rollback SW via connect_to_nom
  [Arguments]   ${DN_NAME}    ${timeout}
   ${status}   Run Keyword And Return Status   NOM Login
   run keyword if  not ${status}    Run Keywords
    ...    Run Keyword And Ignore Error   NOM Logout   AND
    ...   NOM Login
  ${DN_NAME}     Create List    ${DN_NAME}
  ${status}     Run Keyword And Ignore Error    nom.rollback_sw     ${DN_NAME}    ${timeout}
  log to console    ${status}
  [Teardown]  Run Keyword And Ignore Error   NOM Logout
  [Return]  ${status}


Download Classical Common Package
    [Arguments]   ${package_version}
    Set Suite Variable   ${PACKAGE_NAME}   ${package_version}_release_BTSSM_downloadable_A54.zip
    Set Suite Variable   ${PACKAGE_PATH}   ${OUTPUT_DIR}/${PACKAGE_NAME}
    ${file_exists}   Run Keyword and Return Status   OperatingSystem.File Should Exist   path=${package_path}
    Return From Keyword If   ${file_exists}   ${package_path}

    ${package_download_link}   Set Download Link   package_version=${package_version}

    Log To Console   Package Do Not Exist, Start to Download Package From WFT!
    Log To Console   Package Download Link: ${package_download_link}
    OperatingSystem.Run   command=rm -f wget-log*
    OperatingSystem.Run   command=wget -b ${package_download_link} -O ${OUTPUT_DIR}/${PACKAGE_NAME}
    Sleep   10s
    ${output}   OperatingSystem.Run   command=cat wget-log
    Should Not Contain   ${output}   404 Not Found
    Wait Until Keyword Succeeds   1h   1m   Wait Until Wget Process Done   package_name=${PACKAGE_NAME}
    OperatingSystem.File Should Exist   path=${package_path}
    Log To Console    Download Classical Package Finished!
    [Return]   ${package_path}

Set Download Link
    [Arguments]   ${package_version}
    @{wft_services}   Create List
    ...   ${hz_service}/${RELEASE}_packages/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
    ...   ${lte_service}/${RELEASE}/${package_version}_release_BTSSM_downloadable_A54.zip

    ${package_download_link}   Set Variable   ${wft_services[-1]}

    FOR   ${wft_service}   IN   @{wft_services}
       ${http_code}   OperatingSystem.Run   command=echo $(curl -sIL -w "%\{http_code\}" -o /dev/null ${wft_service})
       ${package_download_link}   Set Variable If   '${http_code.find('200')}'!='-1'   ${wft_service}
       ...   ${True}   ${package_download_link}
       Exit For Loop If   '${http_code.find('200')}'!='-1'
    END
    [Return]   ${package_download_link}

Wait Until Wget Process Done
    [Arguments]   ${package_name}
    ${output}   OperatingSystem.Run   command=cat wget-log | grep -i "saved"
    Should Contain   ${output}   ${package_name}
