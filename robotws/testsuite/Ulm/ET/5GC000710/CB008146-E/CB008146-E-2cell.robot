*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB008146-E 2 cell config
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        CB008146-E-keywords.robot
Resource        CB008146-E-commissioning-2cell.robot
Resource        CB008146-E-verify-counter.robot
Resource        CB008146-E-wts.robot
Resource        CB008146-E-parameter-settings.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/reporting.robot
Resource        ../../resources/SQD60/keywords-tracing.robot

Suite Setup       Suite Setup CB008146E
Suite Teardown    Suite Teardown CB008146E

*** Variables ***
${logs_collected}                     False


*** Test Cases ***

CB008146_E_SA_intraGnb_intraDU_interFreq_handover_with_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                UE1 select profile 3 and no A2 measurement configuration
    ...                UE2 select profile 3 and A2 measurement configuration for redirection and for handover
    ...                M55157C00035 NRMOP_SA_PROFILE_SELECTED_03
    ...       :Autor: Sylvia Schneider
    [Tags]   t7    CRT
    [Setup]   Perform Preconditions of Test Scenario CB008146E
    Load wts file      2 cell config
    Bring Airphone TL to on Air status
    check wts in active state
    prepare counters and expected values 2 cell config

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    set AMF param indexToRFSP     indexToRFSP=88
    UE Register    nwslice=1,2
    start Pdu and check      id_pdu_gw=1       nwslice=1    check=Initial Context Setup Successful
    send A2 measurement with srsrp_nr and srsrq_nr    srsrp_nr=30   srsrq_nr=30   meas_id=1     UE_id=1
    change indexToRFSP     indexToRFSP=99
    send A3 measurement with srsrp_srsrq and nrsrp_nrsrq and check
    send A2 measurement with srsrp_nr and srsrq_nr    srsrp_nr=30   srsrq_nr=30   meas_id=7     UE_id=1
    start Pdu and check      id_pdu_gw=2       nwslice=2    check=rrcReconfigurationComplete
    release Pdu
    send A5 measurement               nrsrq_nr=29
    send A5 measurement and check     nrsrq_nr=32
    send A2 measurement with srsrp_nr and srsrq_nr and check    srsrp_nr=24   srsrq_nr=30   meas_id=14    UE_id=1
    ...    check=Location changed to eNB-2 cell 2

    stop wireshark trace

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values 2 cell config
    verify egate log 2 cell config

    [Teardown]   Perform Postconditions of Test Scenario CB008146E




*** Keywords ***
Suite Setup CB008146E
    [Documentation]    [PRIVATE]    Prepare TL for CB008146-E
    ...       :Autor: Sylvia Schneider
    Create ips for simulated gnb
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Check TL Infos
    gnb.Store Current SCF from gNB
    get nrarfcn plmn tac version from gNB SCF
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    update gscn in iphy file
    Update wts file for TC CB008146E 2 cell config
    Update and activate SCF


Perform Preconditions of Test Scenario CB008146E
    [Documentation]    [PRIVATE]    preconditions for CB008146E
    ...       :Autor: Sylvia Schneider
    Create a Test Scenario Folder
    Set test variable   ${log_number}    1
    get scf coam    ${resultDir}    SCFC_CB008146E_2cell_final.xml
    Log To Console    final SCF saved ${resultDir}/SCFC_CB008146E_2cell_final.xml


update gscn in iphy file
    [Documentation]    [PRIVATE]    update gscn in iphy file
    ...       :Autor: Sylvia Schneider
    Log To Console    setting GSCN to value 7995, 7880 in /ffs/run/simmode/new_iphy.xml
    ${ACU_alias}    Connect to Airphone Common Unit
    ssh.execute    cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ACU_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml    ${resultBaseDir}/new_iphy.xml    connection=${ACU_alias}

    ${contents}    Get File    ${resultBaseDir}/new_iphy.xml
    ${all_parts}    Split String      ${contents}     </RE>
    ${upd0}    Replace String Using Regexp    ${all_parts}[0]         GSCN>.*<\/GSCN>   GSCN>7995<\/GSCN>
    ${upd1}    Replace String Using Regexp    ${all_parts}[1]         GSCN>.*<\/GSCN>   GSCN>7880<\/GSCN>
    ${new contents}      catenate         SEPARATOR=</RE>   ${upd0}                    ${upd1}
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[2]
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[3]
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[4]

    Create File    ${resultBaseDir}/new_iphy_upd.xml    ${new contents}
    ssh.Upload File    ${resultBaseDir}/new_iphy_upd.xml    /rom/simmode/new_iphy.xml   connection=${ACU_alias}


get nrarfcn plmn tac version from gNB SCF
    [Documentation]    [PRIVATE]    get values from SCF for update in wts and commissioning
    ...       :Autor: Sylvia Schneider
    ${parsed_SCF}    parse XML    ${P_ORIG_SCF}
    ${mcc_SCF}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mcc"]
    set suite variable   ${mcc_SCF}
    Log To Console    set suite variable mcc_SCF to value: ${mcc_SCF}
    ${mnc_SCF}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mnc"]
    set suite variable   ${mnc_SCF}
    Log To Console    set suite variable mnc_SCF to value: ${mnc_SCF}
    ${mnclenght_SCF}    get element text    ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mncLength"]
    set suite variable   ${mnclenght_SCF}
    Log To Console    set suite variable mnclenght_SCF to value: ${mnclenght_SCF}
    ${fiveGsTac_SCF}    get element text    ${parsed_SCF}
    ...    xpath=.//managedObject[@class="com.nokia.srbts.nrbts:TRACKINGAREA"]/p[@name="fiveGsTac"]
    set suite variable   ${fiveGsTac_SCF}
    Log To Console    set suite variable fiveGsTac_SCF to value: ${fiveGsTac_SCF}
    ${version_SCF}    get element attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="${bts_distName}"]
    set suite variable   ${version_SCF}
    Log To Console    set suite variable version_SCF to value: ${version_SCF}


Perform Postconditions of Test Scenario CB008146E
    [Documentation]    [PRIVATE]    postconditions for CB008146E
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Set SCOUT TC ID for Reporting
    Run Keyword And Continue On Failure   stop wireshark trace
    Run Keyword And Continue On Failure   end dcap tracing and collect traces
    Run Keyword And Continue On Failure   Teardown Egate Connection for Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect snapshot and sos report data     ${resultDir}


Suite Teardown CB008146E
    [Documentation]    [PRIVATE]    suite teardown for CB008146E
    ...       :Autor: Sylvia Schneider
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    Collect snapshot and sos report data   ${resultBaseDir}
    Reload Stored WTS Config


start Pdu and check
    [Documentation]    [PRIVATE]    start PDU session in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${id_pdu_gw}    ${nwslice}    ${check}
    Log To Console    execute on wts: ue_pdu_session_setup pdu=${id_pdu_gw} ue=1 nwslice=${nwslice} gw=${id_pdu_gw}
    Log To Console    check on wts : "pass_regexp=${check}"
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_pdu_session_setup pdu=${id_pdu_gw} ue=1 nwslice=${nwslice} gw=${id_pdu_gw}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Save egate log          ${output_egate}


release Pdu
    [Documentation]    [PRIVATE]    release PDU session in wts
    ...       :Autor: Sylvia Schneider
    Log To Console    execute on wts: ue_pdu_session_release ue=1 pdu=1 by=ue
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_pdu_session_release ue=1 pdu=1 by=ue
    ...    return_output=True
    ...    alias=ap_egate
    Save egate log          ${output_egate}


change indexToRFSP
    [Documentation]    [PRIVATE]    change indexToRFSP
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${indexToRFSP}
    Log To Console    execute on wts: ue_ctx_ng_mod id=1 indexToRFSP=${indexToRFSP}
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_ctx_ng_mod id=1 indexToRFSP=${indexToRFSP}
    ...    return_output=True
    ...    alias=ap_egate
    Save egate log          ${output_egate}


send A3 measurement with srsrp_srsrq and nrsrp_nrsrq and check
    [Documentation]    [PRIVATE]    send A3 measurement with srsrp_srsrq and nrsrp_nrsrq in wts
    ...       :Autor: Sylvia Schneider
    Log To Console
    ...   execute on wts: ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=51 nrsrp_nr=50 nrsrq_nr=45 meas_id=6 id=1
    Log To Console    check on wts : "pass_regexp=rrcReconfigurationComplete"
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_measurement_send_nr event=A3 srsrp_nr=30 srsrq_nr=30 phycell_id=51 nrsrp_nr=50 nrsrq_nr=45 meas_id=6 id=1
    ...    return_output=True
    ...    pass_regexp=rrcReconfigurationComplete
    ...    alias=ap_egate
    Save egate log          ${output_egate}


send A5 measurement
    [Documentation]    [PRIVATE]    send A5 measurement in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrsrq_nr}
    Log To Console
    ...   execute on wts: ue_measurement_send_nr event=A5 srsrp_nr=90 srsrq_nr=35 phycell_id=50 nrsrp_nr=100 nrsrq_nr=${nrsrq_nr} meas_id=12 id=1
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_measurement_send_nr event=A5 srsrp_nr=90 srsrq_nr=35 phycell_id=50 nrsrp_nr=100 nrsrq_nr=${nrsrq_nr} meas_id=12 id=1
    ...    return_output=True
    ...    alias=ap_egate
    Save egate log          ${output_egate}


send A5 measurement and check
    [Documentation]    [PRIVATE]    send A5 measurement and check in wts
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrsrq_nr}
    Log To Console
    ...   execute on wts: ue_measurement_send_nr event=A5 srsrp_nr=90 srsrq_nr=35 phycell_id=50 nrsrp_nr=100 nrsrq_nr=${nrsrq_nr} meas_id=12 id=1
    Log To Console    check on wts : "pass_regexp=rrcReconfigurationComplete"
    sleep     5s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=ue_measurement_send_nr event=A5 srsrp_nr=90 srsrq_nr=35 phycell_id=50 nrsrp_nr=100 nrsrq_nr=${nrsrq_nr} meas_id=12 id=1
    ...    return_output=True
    ...    pass_regexp=rrcReconfigurationComplete
    ...    alias=ap_egate
    Save egate log          ${output_egate}


verify egate log 2 cell config
    [Documentation]    [PRIVATE]    verify egate log for 2 cell config
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify A3 measurement triggering handover
    verify string present in egate log    egate_log=egate_log4.txt   search_text=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Log To Console    \nVerify 2nd A5 measurement triggering handover back
    verify string present in egate log    egate_log=egate_log9.txt   search_text=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    Log To Console    \nVerify A2 measurement triggering redirect
    verify string present in egate log    egate_log=egate_log10.txt
    ...   search_text=Received RRCConnectionRelease with NR redirectedCarrierInfo=636666; redirect to gNB-2 cell 2 will be done
    verify string present in egate log    egate_log=egate_log10.txt   search_text=Location changed to eNB-2 cell 2


verify string present in egate log
    [Documentation]    [PRIVATE]    verify string present
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${egate_log}    ${search_text}
    ${contents}    Get File           ${resultDir}/${egate_log}
    Log To Console       check that "${search_text}" present
    Run Keyword and Continue on Failure    Should Contain           ${contents}         ${search_text}
