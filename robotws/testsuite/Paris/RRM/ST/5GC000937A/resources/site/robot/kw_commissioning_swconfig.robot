*** Settings ***
Documentation
...    author:      Alain Brethereau
...    contact:     alain.brethereau@nokia.com
...    Description: Commissioning with 192.168.255.129, copy swconfig.txt and Wait for onAir on all DUs
...                    with robot5G/custom-config/<site>/<TL name>/<Branche>/<TL name>_<Branche>_scf.xml
...    Version:     0.6
...    Date:        2021-04-01

Library    os
Library    os.path
Library    String
Library    Collections
Library    OperatingSystem
Library    taf.rfrl.bts.commissioning
Library    taf.transport.ssh                         WITH NAME    ssh
Library    taf.gnb.oam.coam.admin                    WITH NAME    admin


    # -v ENB_BUILD:5G_0.800.2986 -v ENB_BRANCH:5G -v CONFIGURATION:Wroclaw.2_16_UTE5GCLASSICAL2986

*** Keywords ***
Commissioning Classical and Copy SWConfig file
    [Arguments]    ${scfFileNameReq}=${None}     ${withOnAir}=False    ${skip_parameter_relation_errors}=True

    log            ENB_BRANCH: ${ENB_BRANCH}, ENB_BUILD: ${ENB_BUILD}, CONFIGURATION: ${CONFIGURATION}

    @{scenarioPath}=    Split String           ${SUITE SOURCE}    /
    ${i}                Get Index From List    ${scenarioPath}   testsuite
    ${repPath}=         Evaluate               "/".join(${scenarioPath}[:${i} ])
    # ${repPath}=         u.Get Repository Path
    ${conf}=            Split String         ${CONFIGURATION}     .
    ${branch}=          Split String         ${ENB_BRANCH}        _

    # swconfig.txt copy
    ${swconfig_path}=    Get swconfig File Path   ${repPath}   ${conf[0]}   ${conf[1]}   ${branch[0]}
    log      swconfig: ${swconfig_path}
    ${lmp}=              Set Variable     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection}
    Wait until Keyword Succeeds  60s   1s
    ...   ssh.connect_to     hostname=${lmp.addr}    username=${lmp.username}   password=${lmp.password}   alias=gNB
    ssh.Upload File      local_path=${swconfig_path}    remote_path=/ffs/run/swconfig.txt    connection=gNB
    ssh.Disconnect       connection=gNB


    # scf commissioning
    ${scfPath}=         Get Scf File Path   ${repPath}   ${conf[0]}   ${conf[1]}   ${branch[0]}     ${scfFileNameReq}
    log      swconfig: ${scfPath}
    ${user}=             Set Variable     ${tl.gnbs[0].cu.oam_http_connection_details.username}
    ${pwd}=              Set Variable     ${tl.gnbs[0].cu.oam_http_connection_details.password}
    ${isConnected}=    Run Keyword And Ignore Error    Wait until Keyword Succeeds  600s   1s
    ...   admin.connect_to   bts_host=192.168.255.129   bts_port=443   username=${user}   password=${pwd}   name=coam
    Run Keyword If     \"${isConnected}[0]\"!="PASS"          Wait until Keyword Succeeds  600s   1s
    ...   admin.connect_to   bts_host=192.168.255.1     bts_port=443   username=${user}   password=${pwd}   name=coam

    admin.perform_commissioning   scf_file=${scfPath}
    ...                           skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                           should_activate=True     timeout=900   connection=coam
    admin.teardown    connection=coam


    # Wait Cell On-Air
    Run Keyword If    ${withOnAir}       Wait for onAir on all DUs


Get Scf File Path
    [Arguments]     ${repPath}   ${site_name}      ${tl_name}      ${branch_name}     ${scfFileNameReq}

    ${p_comm}=       Set Variable        ${repPath}/commissionings/${site_name}/${tl_name}/${branch_name}/
    ${p_cust}=       Set Variable        ${repPath}/custom-config/${site_name}/${tl_name}/${branch_name}/

    ${isExist_pcm_req}=    evaluate   os.path.exists("${p_comm}/${scfFileNameReq}.xml")    modules=os
    ${isExist_pct_req}=    evaluate   os.path.exists("${p_cust}/${scfFileNameReq}.xml")    modules=os
    ${isExist_pcm_sm}=     evaluate   os.path.exists("${p_comm}/${tl_name}_${branch_name}_SCF.xml")    modules=os
    ${isExist_pcm_s}=      evaluate   os.path.exists("${p_comm}/${tl_name}_${branch_name}_scf.xml")    modules=os
    ${isExist_pct_sm}=     evaluate   os.path.exists("${p_cust}/${tl_name}_${branch_name}_SCF.xml")    modules=os
    ${isExist_pct_s}=      evaluate   os.path.exists("${p_cust}/${tl_name}_${branch_name}_scf.xml")    modules=os


    ${p}=     Run Keyword If   ${isExist_pcm_req}   Set Variable     ${p_comm}/${scfFileNameReq}.xml
    ...   ELSE IF              ${isExist_pct_req}   Set Variable     ${p_cust}/${scfFileNameReq}.xml
    ...   ELSE IF              ${isExist_pcm_sm}    Set Variable     ${p_comm}/${tl_name}_${branch_name}_SCF.xml
    ...   ELSE IF              ${isExist_pcm_s}     Set Variable     ${p_comm}/${tl_name}_${branch_name}_scf.xml
    ...   ELSE IF              ${isExist_pct_sm}    Set Variable     ${p_cust}/${tl_name}_${branch_name}_SCF.xml
    ...   ELSE IF              ${isExist_pct_s}     Set Variable     ${p_cust}/${tl_name}_${branch_name}_scf.xml
    ...   ELSE                                      Get First SCF File    ${p_comm}

    [return]    ${p}


Get First SCF File
    [Arguments]     ${p_comm}

    ${lFile}=      evaluate   os.listdir("${p_comm}")   modules=os
    log to console    ${lFile}
    ${lscfm}        Create List
    ${lscf}         Create List
    FOR  ${f}   IN   @{lFile}
        ${match}   ${value}     Run Keyword And Ignore Error    Should Contain   ${f}    _SCF.xml
        Run Keyword If   '${match}'=='PASS'    Append To List     ${lscfm}     ${f}
        ${match}   ${value}     Run Keyword And Ignore Error    Should Contain   ${f}    _scf.xml
        Run Keyword If   '${match}'=='PASS'    Append To List     ${lscf}      ${f}
    END

    ${p}=    Run Keyword If      ${lscfm}    Set Variable     ${lscfm[0]}
    ...      ELSE IF             ${lscf}     Set Variable     ${lscf[0]}
    ...      ELSE                            Set Variable     -

    [return]    ${p_comm}/${p}


Get swconfig File Path
    [Arguments]     ${repPath}   ${site_name}      ${tl_name}      ${branch_name}

    ${sPath}=        Set Variable         ${repPath}/commissionings/${site_name}/${tl_name}/${branch_name}/swconfig.txt

    ${isExist}=     evaluate   os.path.exists("${sPath}")    modules=os
    ${p}=      Run Keyword If     ${isExist}       Set Variable       ${sPath}
    ...   ELSE      Set Variable     ${repPath}/custom-config/${site_name}/${tl_name}/${branch_name}/swconfig.txt

    [return]    ${p}
