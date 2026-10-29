*** Settings ***
Documentation                          Generic, Qualcomm and Prisma keywords created for 5GC001877_772 C and F Features

Resource                               ${CURDIR}/keywords_cOAM.robot
Library                                ${CURDIR}/keywords.py                             WITH NAME       mylibpython
Library                                ${CURDIR}/5GC000772_Resources.py                  WITH NAME       mylib772
Library                                taf.sbts.oam.coam.admin                           WITH NAME       coam
Library                                taf.transport.ssh                                 WITH NAME       csn
Library                                OperatingSystem
Library                                DateTime
Library                                XML
Library                                SSHLibrary                                        WITH NAME       robssh
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     taf.hw.rf_attenuator    WITH NAME    att
Library                                taf.ue
Library         taf.collectors.core         WITH NAME       core
Library         taf.collectors.tcpdump      WITH NAME       tcpdump
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/bip.robot
#Library            taf.hw.rf_attenuator    WITH NAME    PA_

*** Variables ***

${actCDrx}                  true
${drxLongCycle}             40ms
${drxOnDurationTimer}       10ms
${drxRetransTimerDl}        0slot
${drxRetransTimerUl}        0slot
${actInactDetNSAUe}         false
${nsaInactivityTimer}       10
${drxHarqRttTimerDl}        0symbols
${drxHarqRttTimerUl}        0symbols
${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}    #int
${5GRU2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}    #int
##PA
@{PA_value}    ${20}    ${10}    ${0}    #int list
@{att_connection_port}      ${5GRU1_ANT1}    ${5GRU2_ANT1}     #int list
${HBTE_max_value}           ${120}
${vendor}    topyoung
${att_ipaddr}    ${tl.attenuator[0].ip_addr}
${att_api_port}    ${tl.attenuator[0].port}
${ue_type}                  huawei

${PA_INFO}            ${tl.attenuator}
&{TimezoneD}    Poland=(GMT+1) Poland    Etc/UTC=(GMT+0) UTC  PRC=(GMT+8) Asia/Shanghai
*** Keywords ***

#######################################
### GENERIC KEYWORDS
#######################################

Campaign Test Setup
    [Documentation]                    Start The Cockpit Environment Campaign
    [Arguments]                        ${campaignId}       ${X2traces}       ${F1traces}
    mylib772.campaign_setup            ${campaignId}       ${GN_OAM_ADDR}
    Remove PM Files
    sleep                              1s
    Set 5G Load Version
    set suite variable                 ${x2apTraces}       ${X2traces}
    set suite variable                 ${f1apTraces}       ${F1traces}
    Check system module


Create Date List
    [Documentation]                    Date List Creation
    [Arguments]
    @{temporaryList}                   create list
    ${slotNumber}=                     mylibpython.getTimeSlotNumber    ${startCallDate}    ${EndCallDate}
    ...    ${PM_INTERVAL}
    append to list                     ${temporaryList}    ${startCallDate}
    ${newDate}    Set Variable    ${startCallDate}
    FOR    ${index}    IN RANGE    ${slotNumber}
        ${newDate}=         Add Time To Date    ${newDate}    ${PM_INTERVAL}min    exclude_millis=yes
        ${newDate}=         mylibpython.setToPMFormat    ${newDate}
        append to list      ${temporaryList}    ${newDate}
    END
    set suite variable                 ${timeSlotList}     ${temporaryList}
    log                                timeSlotList = ${timeSlotList}


Estimate Call Duration
    [Documentation]                    Based on attach and detach time, estimate the delta in second
    [Arguments]
    ${temporaryDate}=                  mylibpython.getCallDuration    ${AttachTime}    ${DetachTime}
    set suite variable                 ${CALL_DURATION}       ${temporaryDate}
    log                                Call Duration = ${CALL_DURATION}


Get Attach Time
    [Documentation]                    Establish the call
    [Arguments]
    ${temporaryDate}=                  Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    set suite variable                 ${AttachTime}       ${temporaryDate}
    log                                Call Started at = ${AttachTime}


Get Detach Time
    [Documentation]                    Release the established call
    [Arguments]
    ${temporaryDate}=                  Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    set suite variable                 ${DetachTime}       ${temporaryDate}
    log                                Call Released at = ${DetachTime}


GNB DBF Configuration Setup
    [Documentation]                    Download the SCF and the swconfig files on gNB
    [Arguments]                        ${SCF}    ${SWconfig}    ${NumberOfCells}=1
    Select the Right Environment
    ${swconfigPath}=                   catenate            ${CURDIR}/Swconfig_Directory
    ${SCFPath}=                        catenate            ${CURDIR}/SCF_Directory
#    Modify timezone in scf
    ${result}    Run Keyword and return status    OperatingSystem.File Should Not Exist
    ...    ${CURDIR}/SCF_Directory/${SCF}
    ${status}    Run Keyword and return status    Check Cell Availability Status is online    ${NumberOfCells}
    Run Keyword If    ${result} and ${status}    Activate DRX in scf    ${NumberOfCells}
    Run Keyword If    ${result} and ${status} and '${cell_num}' == '2'    Activate DRX in scf    ${CELL_FOR_HO}
    Run Keyword If    ${result} and ${status}    get scf file
    ${status1}    Run Keyword and return status    validate scf file
    run keyword if  not ${result} or ${status1}    get scf file
    validate scf file
    ${result}    Run Keyword and return status    OperatingSystem.File Should Not Exist
    ...    ${CURDIR}/Swconfig_Directory/${SWconfig}
    Run Keyword If    ${result}    download swconfig file
    connection_alias_store.Connect to Common Unit Master    alias=ASIK Master
    Run keyword and ignore error    swconf.Upload swConfig file to asik and crasign
    ...    localFilePath=${swconfigPath}/${SWconfig}    asik_alias=ASIK Master
    coam_gnb_classical.Connect to gnb coam via ssl
    ${result}    coam_gnb_classical.COAM Commission with scf file    scf_file_path=${SCFPath}/${SCF}
    ...    is_pdl_checking_needed=${True}    timeout=900
    wait until keyword succeeds    1200      60s    coam_gnb_classical.COAM Check GNB cell on air
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM

Modify timezone in scf
  ${rc}  ${output}  Run and Return RC and Output  timedatectl | grep "Time zone" |awk -F ' ' '{print $3}'
  ${modify_timezone}  set variable  ${TimezoneD}[${output}]
  Log to console     Modify timezone to ${modify_timezone}
  ${p_name}                          set variable                      timeZone
  FOR    ${index}    IN RANGE    ${time_num}
      ${CurrentValue}                    gNB Get Attribute value in SCF    dist_name=${Time_${index}}    p_name=${p_name}
      Run Keyword if                     '${CurrentValue}'!='${modify_timezone}'
      ...                                Change A SCF Parameter            dist_name=${Time_${index}}    p_name=${p_name}
      ...    value=${modify_timezone}
  END

Set 5G Load Version
    [Documentation]                    Extract the SW Version from WebEM
    set suite variable                 ${5GLoadVersion}    Trunk
    coam.connect_to                    bts_host=${GN_OAM_ADDR}
    ${swversion}=                      coam.get_sw_version
    set suite variable                 ${swversion}
    Run Keyword if                     '5G20A' in '${swversion}'    set suite variable    ${5GLoadVersion}    5G20A




Note Start Date
    [Documentation]                    Get the Call Start Date and Time
    [Arguments]
    ${temporaryDate}=                  Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:00
    set suite variable                 ${fullStartDate}                  ${temporaryDate}
    ${temporaryDate}=                  mylibpython.getPMFormattedTime    ${PM_INTERVAL}
    set suite variable                 ${startCallDate}                  ${temporaryDate}
    Log                                The Call Start Date is: ${startCallDate}


Note End Date
    [Documentation]                    Get the Call End Date and Time
    [Arguments]
    ${temporaryDate}=                  Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:00
    set suite variable                 ${fullEndDate}                  ${temporaryDate}
    ${temporaryDate}=                  mylibpython.getPMFormattedTime    ${PM_INTERVAL}
    set suite variable                 ${endCallDate}                  ${temporaryDate}
    Log                                The Call End Date is: ${endCallDate}
    Create Date List


Select the Right Environment
    [Documentation]                    Depending the runing SW load, select the right SCF and SwConfig
    [Arguments]
    coam.connect_to                    bts_host=${GN_OAM_ADDR}
    ${SW_Version}=                     coam.get_sw_version
    set suite variable                 ${SW_Version}
    ${release}    set variable    ${SW_Version.split("_")[0]}
    Run Keyword if                     '5G19A' in '${SW_Version}'     Set the 5GNB Environment    5G19A
    Run Keyword if                     '5G19B' in '${SW_Version}'     Set the 5GNB Environment    5G19B
    Run Keyword if                     '5G20A' in '${SW_Version}'     Set the 5GNB Environment    5G20A
    Run Keyword if                     '5G20B' in '${SW_Version}'     Set the 5GNB Environment    5G20B
    Run Keyword if                     '5G21A' in '${SW_Version}'     Set the 5GNB Environment    5G21A
    Run Keyword if                     '_0000_' in '${SW_Version}'     Set the 5GNB Environment    ${release}
    Run Keyword if                     '_999' in '${SW_Version}'     Set the 5GNB Environment    SBTS00
    coam.teardown


Set the 5GNB Environment
    [Documentation]                    Set the GNB SCF and SWconfig
    [Arguments]                        ${swversion}
    Log                                The ${swversion} has been detected
    # Set some 5GNB variables:
    ${tempName}=                       Set Cell Distant Name     ${CELL_NUMBER}
    ${cellName}=                       Catenate                  PLMN-PLMN/${tempName}
    ${selectedScfFile}=                Catenate                  ${swversion}_${SCF}
    ${selectedSwconfig}=               Catenate                  ${swversion}_${SWconfig}
    set suite variable                 ${cellName}
    set suite variable                 ${SCF}                    ${selectedScfFile}
    set suite variable                 ${SWconfig}               ${selectedSwconfig}



Set Cell Distant Name
    [Documentation]                    Depending the NSA or SA mode, set the distant name for the managed cell
    [Arguments]                        ${cell_number}
    ${cellDistName}=                   catenate       ${CV_${SA_OR_NSA_MODE}_NRCELL_${cell_number}}
    [Return]                           ${cellDistName}


Set NRBTS Distant Name
    [Documentation]                    Depending the NSA or SA mode, set the distant name for the managed NRBTS
    [Arguments]
    ${nrbtsDistName}=                  catenate        ${CV_${SA_OR_NSA_MODE}_NRBTS}
    [Return]                           ${nrbtsDistName}


Set NRDRX Distant Name
    [Documentation]                    Depending the NSA or SA mode, set the distant name for the managed NRDRX
    [Arguments]
    ${nrdrxDistName}=                  catenate        ${CV_${SA_OR_NSA_MODE}_NRBTS}/NRDRX-4
    [Return]                           ${nrdrxDistName}




#######################################
### State Machine KEYWORDS
#######################################

Launch The Use Case Detector
    [Documentation]                    Launch StateMachine To Check the Dataflow
    [Arguments]
    ${ListOfStateMachine}              Create List
    ...                                     @{SM_TO_BE_RUN}
    ...                                     Stub.sm
    mylib772.LaunchSpecificUCD         smList=${ListOfStateMachine}


#######################################
### DRX and SRB3 KEYWORDS
#######################################

Activate DRX
    [Documentation]                    Activate and Configure The DRX feature
    [Arguments]                        ${cell_id}
    ${d_name}=                         Set Cell Distant Name             ${cell_id}
    ${p_name}                          set variable                      actCDrx
    ${CurrentValue}                    gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=${p_name}
    Run Keyword if                     '${CurrentValue}'=='false'
    ...       Run Keywords         Change A SCF Parameter    dist_name=${d_name}    p_name=${p_name}    value=true
    ...       AND                  Run keyword and ignore error    Change A SCF Parameter    dist_name=${CV_NRBTS}
    ...    p_name=actNsaUeBasedAnrNr    value=true
    ...       AND                  Change A SCF Parameter    dist_name=${CV_NRBTS}    p_name=actDedicatedAnrDrxProfile
    ...    value=true
    ...       AND                  Run keyword and ignore error    Change A SCF Parameter    dist_name=${CV_NRBTS}
    ...    p_name=actSaUeBasedInterFreqAnrNr    value=true
    ...       AND                  Change A SCF Parameter    dist_name=${CV_NRBTS}    p_name=actDisableUlProactGrantAnr
    ...    value=true
    ...       AND                  Change A SCF Parameter    dist_name=${CV_NRCELL_1}    p_name=actDrxRetransTimerSupport
    ...    value=true
    ...       AND                  Run keyword and ignore error    Change A SCF Parameter    dist_name=${CV_NRCELL_1}
    ...    p_name=actEarlyDrxSetup    value=true

    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    set suite variable    ${release_sbts}
    Run keyword If  '${release_sbts}'=='SBTS23R2' or '${release_sbts}'=='SBTS23R3'
    ...    Log To Console  no_need_modify_actTcpBoostPug
    ...    ELSE IF    '${CurrentValue}'=='false'
    ...    Run keyword and ignore error  Change A SCF Parameter   dist_name=${d_name}    p_name=actTcpBoostPug
    ...    value=allUes

    sleep                              1s
    Run keyword If  '${release_sbts}'=='SBTS23R3'
    ...  Change The DRX Parameters 23R3    ${cell_id}              ${defDrxInactivityTimer}
    ...                                ${defDrxLongCycle}         ${defDrxOnDurationTimer}
    ...                                ${defDrxRetransTimerDl}    ${defDrxRetransTimerUl}
    ...  ELSE  Change The DRX Parameters    ${defDrxInactivityTimer}
    ...                                ${defDrxLongCycle}         ${defDrxOnDurationTimer}


Activate LONG DRX
    [Documentation]                    Activate and Configure The DRX feature
    [Arguments]                        ${cell_id}
    ${d_name}=                         Set Cell Distant Name             ${cell_id}
    ${p_name}                          set variable                      actCDrx
    ${CurrentValue}                    gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=${p_name}
    Run Keyword if                     '${CurrentValue}'=='false'
    ...                                Change A SCF Parameter       dist_name=${d_name}    p_name=${p_name}  value=true
    sleep                              1s
    Run keyword If  '${release_sbts}'=='SBTS23R3'
    ...  Change The DRX Parameters 23R3    ${cell_id}            40ms
    ...                                160ms        ${defDrxOnDurationTimer}
    ...                                ${defDrxRetransTimerDl}    ${defDrxRetransTimerUl}
    ...  ELSE  Change The DRX Parameters    40ms
    ...                                160ms        ${defDrxOnDurationTimer}


Activate SRB3
    [Documentation]                    Activate the SRB3 feature
    [Arguments]
    ${d_name}=                         Set NRBTS Distant Name
    ${p_name}                          set variable                      srb3SupportEnabled
    ${CurrentValue}                    gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=${p_name}
    Run Keyword if                     '${CurrentValue}'=='false'
    ...                                Change A SCF Parameter    dist_name=${d_name}    p_name=${p_name}   value=true


Change A SCF Parameter
    [Documentation]                    Change one SCF parameter to the desired value
    [Arguments]                        ${dist_name}    ${p_name}    ${value}
    wait until keyword succeeds    2x    5s
    ...    WebUI gNB Set Attribute Value     dist_name=${dist_name}    p_name=${p_name}   new_value=${value}
    wait until keyword succeeds    1200      20    Check Cell Availability Status is online    ${cell_num}
    ${modified_value}=    gNB Get Attribute value in SCF    dist_name=${dist_name}    p_name=${p_name}
    should be equal                    ${modified_value}                 ${value}
    sleep                              10s


Deactivate DRX
    [Documentation]                    De-Activate the DRX feature
    [Arguments]                        ${cell_id}
    ${d_name}=                         Set Cell Distant Name             ${cell_id}
    ${p_name}                          set variable                      actCDrx
    ${CurrentValue}                    gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=${p_name}
    Run Keyword if                     '${CurrentValue}'=='true'
    ...       Run Keywords         Change A SCF Parameter    dist_name=${CV_NRBTS}    p_name=actDisableUlProactGrantAnr
    ...    value=false
    ...       AND                  Change A SCF Parameter    dist_name=${CV_NRBTS}    p_name=actSaUeBasedInterFreqAnrNr
    ...    value=false
    ...       AND                  Change A SCF Parameter    dist_name=${CV_NRBTS}    p_name=actSaUeBasedAnrNr
    ...    value=false
    ...       AND                  Change A SCF Parameter    dist_name=${CV_NRCELL_1}    p_name=actDrxRetransTimerSupport
    ...    value=false
    ...       AND                  Run keyword and ignore error    Change A SCF Parameter    dist_name=${CV_NRCELL_1}
    ...    p_name=actEarlyDrxSetup    value=false

    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    Run keyword If  '${release_sbts}'=='SBTS23R2' or '${release_sbts}'=='SBTS23R3'
    ...    Log To Console  no_need_modify_actTcpBoostPug
    ...    ELSE IF   '${CurrentValue}'=='true'
    ...    Change A SCF Parameter   dist_name=${d_name}    p_name=actTcpBoostPug     value=disabled
	Run keyword If  '${release_sbts}'=='SBTS24R3'
	...    Change A SCF Parameter    dist_name=${CV_NRBTS}    p_name=actDedicatedAnrDrxProfile     value=false


    Run Keyword if     '${CurrentValue}'=='true'
    ...      Change A SCF Parameter    dist_name=${d_name}    p_name=${p_name}    value=false


    sleep                              1s
    Run keyword If  '${release_sbts}'=='SBTS23R3'
    ...  Change The DRX Parameters 23R3    ${cell_id}              ${defDrxInactivityTimer}
    ...                                ${defDrxLongCycle}         ${defDrxOnDurationTimer}
    ...                                ${defDrxRetransTimerDl}    ${defDrxRetransTimerUl}
    ...  ELSE  Change The DRX Parameters    ${defDrxInactivityTimer}
    ...                                ${defDrxLongCycle}         ${defDrxOnDurationTimer}



Deactivate SRB3
    [Documentation]                    Deactivate the SRB3 feature
    [Arguments]
    ${d_name}=                         Set NRBTS Distant Name
    ${p_name}                          set variable                      srb3SupportEnabled
    ${CurrentValue}                    gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=${p_name}
    Run Keyword if                     '${CurrentValue}'=='true'
    ...                                Change A SCF Parameter    dist_name=${d_name}    p_name=${p_name}    value=false


Change The DRX Parameters
    [Documentation]                    Change one or more DRX parameters via the webUI
    [Arguments]
    ...                                ${drxInactivityTimer}
    ...                                ${drxLongCycle}
    ...                                ${drxOnDurationTimer}

    ${d_name}=                         Set NRDRX Distant Name
    Run Keyword        Change A SCF Parameter    dist_name=${d_name}    p_name=drxInactivityTimer    value=${drxInactivityTimer}
	Run Keyword        Change A SCF Parameter    dist_name=${d_name}    p_name=drxLongCycle    value=${drxLongCycle}
	Run Keyword        Change A SCF Parameter    dist_name=${d_name}    p_name=drxOnDurationTimer    value=${drxOnDurationTimer}



# # Create the DRX parameters list
#    ${dict}=    create dictionary      drxInactivityTimer=${drxInactivityTimer}
#    ...                                drxLongCycle=${drxLongCycle}
#    ...                                drxOnDurationTimer=${drxOnDurationTimer}
#    ...                                drxRetransTimerDl=${drxRetransTimerDl}
#    ...                                drxRetransTimerUl=${drxRetransTimerUl}
#    ...                                drxHarqRttTimerDl=${drxHarqRttTimerDl}
#    ...                                drxHarqRttTimerUl=${drxHarqRttTimerUl}
#    ${NewValue}=    Create list        ${dict}
#
#    # New DRX parameters setup:
#    log                                New DRX parameters will be: ${NewValue}
#    ${distName}=                       Set Cell Distant Name    ${CellId}
#    WebUI gNB Set Attribute Value      dist_name=${distName}    p_name=drxProfile1    new_value=${NewValue}
#    sleep                              1s
#
#    # Get the new DRX parameters values:
#    log                                Get all DRX parameters values
#    ${new_DRX_parameters}=             Get All DRX Parameters   ${CellId}
#
#    # Read and check all DRX parameters one by one:
#    ${read_param_0}=                   Get From List            ${new_DRX_parameters}    0
#    should be equal                    ${read_param_0.text}     ${drxHarqRttTimerDl}
#    ${read_param_1}=                   Get From List            ${new_DRX_parameters}    1
#    should be equal                    ${read_param_1.text}     ${drxHarqRttTimerUl}
#    ${read_param_2}=                   Get From List            ${new_DRX_parameters}    2
#    should be equal                    ${read_param_2.text}     ${drxInactivityTimer}
#    ${read_param_3}=                   Get From List            ${new_DRX_parameters}    3
#    should be equal                    ${read_param_3.text}     ${drxLongCycle}
#    ${read_param_4}=                   Get From List            ${new_DRX_parameters}    4
#    should be equal                    ${read_param_4.text}     ${drxOnDurationTimer}
#    ${read_param_5}=                   Get From List            ${new_DRX_parameters}    5
#    should be equal                    ${read_param_5.text}     ${drxRetransTimerDl}
#    ${read_param_6}=                   Get From List            ${new_DRX_parameters}    6
#    should be equal                    ${read_param_6.text}     ${drxRetransTimerUl}

Change The DRX Parameters 23R3
    [Documentation]                    Change one or more DRX parameters via the webUI
    [Arguments]                        ${CellId}
    ...                                ${drxInactivityTimer}
    ...                                ${drxLongCycle}
    ...                                ${drxOnDurationTimer}
    ...                                ${drxRetransTimerDl}
    ...                                ${drxRetransTimerUl}

    # Create the DRX parameters list
    ${dict}=    create dictionary      drxInactivityTimer=${drxInactivityTimer}
    ...                                drxLongCycle=${drxLongCycle}
    ...                                drxOnDurationTimer=${drxOnDurationTimer}
    ...                                drxRetransTimerDl=${drxRetransTimerDl}
    ...                                drxRetransTimerUl=${drxRetransTimerUl}

    ${NewValue}=    Create list        ${dict}

    # New DRX parameters setup:
    log                                New DRX parameters will be: ${NewValue}
    ${distName}=                       Set Cell Distant Name    ${CellId}
    WebUI gNB Set Attribute Value      dist_name=${distName}    p_name=drxProfile1    new_value=${NewValue}
    sleep                              1s

    # Get the new DRX parameters values:
    log                                Get all DRX parameters values
    ${new_DRX_parameters}=             Get All DRX Parameters 23R3  ${CellId}

    # Read and check all DRX parameters one by one:
    ${read_param_0}=                   Get From List            ${new_DRX_parameters}    0
    should be equal                    ${read_param_0.text}     ${drxInactivityTimer}
    ${read_param_1}=                   Get From List            ${new_DRX_parameters}    1
    should be equal                    ${read_param_1.text}     ${drxLongCycle}
    ${read_param_2}=                   Get From List            ${new_DRX_parameters}    2
    should be equal                    ${read_param_2.text}     ${drxOnDurationTimer}
    ${read_param_3}=                   Get From List            ${new_DRX_parameters}    3
    should be equal                    ${read_param_3.text}     ${drxRetransTimerDl}
    ${read_param_4}=                   Get From List            ${new_DRX_parameters}    4
    should be equal                    ${read_param_4.text}     ${drxRetransTimerUl}


Get All DRX Parameters
    [Documentation]                    Read all DRX parameters via the webUI
    [Arguments]
    # Get and parse the SCF
    ${content}=                        gNB Get SCF Content
    ${xml_root}=                       XML.Parse XML    ${content}
    ${distName}=                       Set NRDRX Distant Name


    ${result}=          XML.Get Element    ${xml_root}
    ...                 .//managedObject[@distName="${distName}"]/p[@name="${drxInactivityTimer}"]



#    # Get all DRX parameters from WebEM
#    ${drx_parameters}=                 XML.Get Child Elements    ${xml_root}
#    ...                                .//managedObject[@distName="${distName}"]/list[@name="drxProfile1"]/item
#
#    # Read all parameters one by one:
#    ${drxHarqRttTimerDl}=              Get From List    ${drx_parameters}    0
#    ${drxHarqRttTimerUl}=              Get From List    ${drx_parameters}    1
#    ${drxInactivityTimer}=             Get From List    ${drx_parameters}    2
#    ${drxLongCycle}=                   Get From List    ${drx_parameters}    3
#    ${drxOnDurationTimer}=             Get From List    ${drx_parameters}    4
#    ${drxRetransTimerDl}=              Get From List    ${drx_parameters}    5
#    ${drxRetransTimerUl}=              Get From List    ${drx_parameters}    6
#
#    log                                DRX Parameters are :
#    log                                drxInactivityTimer: ${drxInactivityTimer.text}
#    log                                drxLongCycle : ${drxLongCycle.text}
#    log                                drxOnDurationTimer: ${drxOnDurationTimer.text}
#    log                                drxRetransTimerDl : ${drxRetransTimerDl.text}
#    log                                drxRetransTimerUl : ${drxRetransTimerUl.text}
#    log                                drxHarqRttTimerDl : ${drxHarqRttTimerDl.text}
#    log                                drxHarqRttTimerUl : ${drxHarqRttTimerUl.text}
#    # Return the parameters list:
#    [Return]                           ${drx_parameters}

Get All DRX Parameters 23R3
    [Documentation]                    Read all DRX parameters via the webUI
    [Arguments]                        ${CellId}
    # Get and parse the SCF
    ${content}=                        gNB Get SCF Content
    ${xml_root}=                       XML.Parse XML    ${content}
    ${distName}=                       Set Cell Distant Name    ${CellId}

    # Get all DRX parameters from WebEM
    ${drx_parameters}=                 XML.Get Child Elements    ${xml_root}
    ...                                .//managedObject[@distName="${distName}"]/list[@name="drxProfile1"]/item

    # Read all parameters one by one:
    ${drxInactivityTimer}=             Get From List    ${drx_parameters}    0
    ${drxLongCycle}=                   Get From List    ${drx_parameters}    1
    ${drxOnDurationTimer}=             Get From List    ${drx_parameters}    2
    ${drxRetransTimerDl}=              Get From List    ${drx_parameters}    3
    ${drxRetransTimerUl}=              Get From List    ${drx_parameters}    4

    log                                DRX Parameters are :
    log                                drxInactivityTimer: ${drxInactivityTimer.text}
    log                                drxLongCycle : ${drxLongCycle.text}
    log                                drxOnDurationTimer: ${drxOnDurationTimer.text}
    log                                drxRetransTimerDl : ${drxRetransTimerDl.text}
    log                                drxRetransTimerUl : ${drxRetransTimerUl.text}
    # Return the parameters list:
    [Return]                           ${drx_parameters}


Set Default DRX Settings From SCF
    [Documentation]                    The DRX parameters read in the applied SCF now define the default DRX settings
    [Arguments]
#    ...                                ${drxInactivityTimer}
#    ...                                ${drxLongCycle}
#    ...                                ${drxOnDurationTimer}
#    ...                                ${drxRetransTimerDl}
#    ...                                ${drxRetransTimerUl}
#    ...                                ${drxHarqRttTimerDl}
#    ...                                ${drxHarqRttTimerUl}

    ${d_name}=                         Set NRDRX Distant Name
    ${drxHarqRttTimerDl}               gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=drxHarqRttTimerDl
    set suite variable                 ${defDrxHarqRttTimerDl}    ${drxHarqRttTimerDl}
	${drxHarqRttTimerUl}               gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=drxHarqRttTimerUl
    set suite variable                 ${defDrxHarqRttTimerUl}    ${drxHarqRttTimerUl}
	${drxInactivityTimer}              gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=drxInactivityTimer
    set suite variable                 ${defDrxInactivityTimer}   ${drxInactivityTimer}
	${drxLongCycle}                    gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=drxLongCycle
    set suite variable                 ${defDrxLongCycle}         ${drxLongCycle}
	${drxOnDurationTimer}              gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=drxOnDurationTimer
    set suite variable                 ${defDrxOnDurationTimer}   ${drxOnDurationTimer}
	${drxRetransTimerDl}               gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=drxRetransTimerDl
    set suite variable                 ${defDrxRetransTimerDl}    ${drxRetransTimerDl}
	${drxRetransTimerUl}               gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=drxRetransTimerUl
    set suite variable                 ${defDrxRetransTimerUl}    ${drxRetransTimerUl}


    # Get and parse the SCF
#    ${content}=                        gNB Get SCF Content
#    ${xml_root}=                       XML.Parse XML             ${content}
#    ${distName}=                       Set Cell Distant Name     ${CellId}

#    # Get all DRX parameters from WebEM
#    ${drx_parameters}=                 XML.Get Child Elements    ${xml_root}
#    ...                                .//managedObject[@distName="${distName}"]/list[@name="drxProfile1"]/item
#
#    # Read all parameters one by one:
#    ${expression}=                     Get From List              ${drx_parameters}    0
#    set suite variable                 ${defDrxHarqRttTimerDl}    ${expression.text}
#    ${expression}=                     Get From List              ${drx_parameters}    1
#    set suite variable                 ${defDrxHarqRttTimerUl}    ${expression.text}
#    ${expression}=                     Get From List              ${drx_parameters}    2
#    set suite variable                 ${defDrxInactivityTimer}   ${expression.text}
#    ${expression}=                     Get From List              ${drx_parameters}    3
#    set suite variable                 ${defDrxLongCycle}         ${expression.text}
#    ${expression}=                     Get From List              ${drx_parameters}    4
#    set suite variable                 ${defDrxOnDurationTimer}   ${expression.text}
#    ${expression}=                     Get From List              ${drx_parameters}    5
#    set suite variable                 ${defDrxRetransTimerDl}    ${expression.text}
#    ${expression}=                     Get From List              ${drx_parameters}    6
#    set suite variable                 ${defDrxRetransTimerUl}    ${expression.text}

Set Default DRX Settings From SCF 23R3
    [Documentation]                    The DRX parameters read in the applied SCF now define the default DRX settings
    [Arguments]                        ${CellId}
    # Get and parse the SCF
    ${content}=                        gNB Get SCF Content
    ${xml_root}=                       XML.Parse XML             ${content}
    ${distName}=                       Set Cell Distant Name     ${CellId}

    # Get all DRX parameters from WebEM
    ${drx_parameters}=                 XML.Get Child Elements    ${xml_root}
    ...                                .//managedObject[@distName="${distName}"]/list[@name="drxProfile1"]/item

    # Read all parameters one by one:
    ${expression}=                     Get From List              ${drx_parameters}    0
    set suite variable                 ${defDrxInactivityTimer}   ${expression.text}
    ${expression}=                     Get From List              ${drx_parameters}    1
    set suite variable                 ${defDrxLongCycle}         ${expression.text}
    ${expression}=                     Get From List              ${drx_parameters}    2
    set suite variable                 ${defDrxOnDurationTimer}   ${expression.text}
    ${expression}=                     Get From List              ${drx_parameters}    3
    set suite variable                 ${defDrxRetransTimerDl}    ${expression.text}
    ${expression}=                     Get From List              ${drx_parameters}    4
    set suite variable                 ${defDrxRetransTimerUl}    ${expression.text}

Display New Default DRX Settings
    [Documentation]                    Display The Default DRX settings
    [Arguments]
    log                                The Default DRX Parameters Are Now This One:
    log                                drxInactivityTimer: ${defDrxInactivityTimer}
    log                                drxLongCycle : ${defDrxLongCycle}
    log                                drxOnDurationTimer: ${defDrxOnDurationTimer}
    log                                drxRetransTimerDl : ${defDrxRetransTimerDl}
    log                                drxRetransTimerUl : ${defDrxRetransTimerUl}
    log                                drxHarqRttTimerDl : ${defDrxHarqRttTimerDl}
    log                                drxHarqRttTimerUl : ${defDrxHarqRttTimerUl}

Get DRX State
    [Documentation]                    Read GNB Database And Return The DRX Activation Value
    [Arguments]                        ${cell_id}
    ${distName}=                       Set Cell Distant Name             ${cell_id}
    ${result}=                         gNB Get Attribute value in SCF    dist_name=${distName}    p_name=actCDrx
    [Return]                           ${result}


Test starting with deactivate
    [Documentation]                    As cDRX is activated, first deactivate then activate it
    [Arguments]                        ${cell_id}
    Deactivate DRX                     ${cell_id}
    Activate DRX                       ${cell_id}


Test starting with activate
    [Documentation]                    As cDRX is deactivated, first activate then deactivate it
    [Arguments]                        ${cell_id}
    Activate DRX                       ${cell_id}
    Deactivate DRX                     ${cell_id}


#######################################
### DRX COUNTERS KEYWORDS
#######################################

Check if HO counters are correct
    [Documentation]                    Check HO in DRX Counters values
    [Arguments]                        ${hoAttempt}        ${hoSuccess}
    ${expression}=                     Run Keyword If      ${hoAttempt} > 0 and ${hoSuccess} == ${hoAttempt}
    ...                                                    Set Variable    True
    ...                                            ELSE    Set Variable    False
    set suite variable                 ${checkHoDrxOn}     ${expression}


Check Counters Files For 1st Call
    Get and Check Counters Files
    ${expression}=                     Run Keyword If      '${checkDrxRatio}'=='True'
    ...                                                    Set Variable    True
    ...                                            ELSE    Set Variable    False
    set suite variable                 ${1stCallCounterCheck}              ${expression}


Check Counters Files For 2nd Call
    Get and Check Counters Files
    ${expression}=                     Run Keyword If      '${checkDrxRatio}'=='True'
    ...                                                    Set Variable    True
    ...                                            ELSE    Set Variable    False
    set suite variable                 ${2ndCallCounterCheck}              ${expression}


Get and Check Counters Files
    [Documentation]                    Get XML Counter Files list from WebEM
    [Arguments]
    # Get Counters files list:
    ${xmlList}=                        WebEM Get XML Counter Files      ${GN_OAM_ADDR}

    # Transfer counter files on VM disk:
    log                                Transfer counter files on VM disk
    ${xmlpath}=                        Catenate             /home/ute/${CAMPAIGN_NAME}_Counters/${fullStartDate}
    Create Directory                   ${xmlpath}
    set suite variable                 ${xmlpath}
    WebEM Download XML files           ${GN_OAM_ADDR}       ${xmlList}       ${xmlpath}

    # Get then display the DRX counters values:
    ${tempName}=                       Set Cell Distant Name     ${CELL_NUMBER}
    ${cellName}=                       Catenate                  PLMN-PLMN/${tempName}
    set suite variable                 ${cellName}
    log                                Get DRX counters values for cell : ${cellName}
    ${drxActive}=    WebEM Get Counter Value   ${xmlList}   ${xmlpath}   ${timeSlotList}   ${SLOTS_UE_DRX_ACTIVE}
    ...   ${cellName}
    ${drxSleep}=     WebEM Get Counter Value   ${xmlList}   ${xmlpath}   ${timeSlotList}   ${SLOTS_UE_DRX_SLEEP}
    ...    ${cellName}
    ${drxSleep}=                       Run Keyword If            '${drxSleep}'=='0'        evaluate          1
    ...                                            ELSE          Set Variable              ${drxSleep}
    Log                                drxActive: ${drxActive} / drxSleep : ${drxSleep}



   # Check if Slots DRX counters ratio are correct:
    log                                Select The Drx Counters Ratio Depending the Load
    Estimate The Drx Counters Ratio
    log                                Check DRX Counters ratio

    ${RatioMin}=                       Evaluate            ${THRESHOLD_MIN} / 100.0
    log to console    RatioMin ${RatioMin}
    ${RatioMax}=                       Evaluate            ${THRESHOLD_MAX} / 100.0
    log to console    RatioMax ${RatioMax}
    ${RatioSum}=                       Evaluate            ${drxActive}.0 / (${drxActive}.0 + ${drxSleep}.0)
    log to console    RatioSum ${RatioSum}
    ${expression}=                     Run Keyword If      ${RatioMin} < ${RatioSum} and ${RatioSum} < ${RatioMax}
    ...                                                    Set Variable    True
    ...                                            ELSE    Set Variable    False
    set suite variable                 ${checkDrxRatio}    ${expression}

Get and Check Counters Files II
    [Documentation]                    Get XML Counter Files list from WebEM
    [Arguments]
    # Get Counters files list:
    ${xmlList}=                        WebEM Get XML Counter Files      ${GN_OAM_ADDR}

    # Transfer counter files on VM disk:
    log                                Transfer counter files on VM disk
    ${xmlpath}=                        Catenate             /home/ute/${CAMPAIGN_NAME}_Counters/${fullStartDate}
    Create Directory                   ${xmlpath}
    WebEM Download XML files           ${GN_OAM_ADDR}       ${xmlList}       ${xmlpath}

    # Get then display the DRX counters values:
    ${tempName}=                       Set Cell Distant Name     ${CELL_NUMBER}
    ${cellName}=                       Catenate                  PLMN-PLMN/${tempName}
    log                                Get DRX counters values for cell : ${cellName}
    ${result}=           WebEM Get Counter Value III
    ...      ${xmlList}   ${xmlpath}   ${timeSlotList}   ${SLOTS_UE_DRX_ACTIVE}    ${SLOTS_UE_DRX_SLEEP}   ${cellName}
    set suite variable                 ${checkDrx160ms}   ${result}
    Log                                result 0 :OK 1 :NOK: ${checkDrx160ms}


Get and Check Counters Files for 5GC002396
    [Documentation]                    Get XML Counter Files list from WebEM
    [Arguments]
    # Get Counters files list:
    ${xmlList}=                        WebEM Get XML Counter Files      ${GN_OAM_ADDR}
    # Transfer counter files on VM disk:
    log                                Transfer counter files on VM disk
    ${xmlpath}=                        Catenate             /home/ute/${CAMPAIGN_NAME}_Counters/${fullStartDate}
    Create Directory                   ${xmlpath}
    WebEM Download XML files           ${GN_OAM_ADDR}       ${xmlList}       ${xmlpath}
    # Get then display the SA UE FULL POWER counters values:
    ${tempName}=                       Set Cell Distant Name     ${CELL_NUMBER}
    ${cellName}=                       Catenate                  PLMN-PLMN/${tempName}
    log                                Get UE FULL PWR counters values for cell : ${cellName}
#    ${result}=           WebEM Get Counter Value III
#    ...      ${xmlList}   ${xmlpath}   ${timeSlotList}   ${SLOTS_UE_DRX_ACTIVE}    ${SLOTS_UE_DRX_SLEEP}   ${cellName}
    ${result}=    WebEM Get Counter Value   ${xmlList}   ${xmlpath}   ${timeSlotList}   ${UE_FULL_PWR}   ${cellName}
    log to console    counter M55114C01501(SUM_SA_UE_FULL_PWR_FR1) is : ${result}
    #${result_max}=                       Evaluate            ${CALL_DURATION_NEW} + 120
    #${result_min}=                       Evaluate            ${CALL_DURATION_NEW} - 120
    # ${result_max}=                       Evaluate            ${CALL_DURATION} + 300
    #  ${result_min}=                       Evaluate            ${CALL_DURATION} - 240
    ${expression}=                     Run Keyword If      ${result} > 0
    ...                                                    Set Variable    True
    ...                                            ELSE    Set Variable    False
    set suite variable                 ${check_UE_FULL_POwer_Counter}    ${expression}
    Log                                Test Result is : ${check_UE_FULL_POwer_Counter}
    should be equal         '${check_UE_FULL_POwer_Counter}'    'True'
Check Counters Files HO IntraDU
    [Documentation]                    Get XML Counter Files list from WebEM: HO IntraDU Case
    [Arguments]
    # Get Counters files list:
    ${xmlList}=                        WebEM Get XML Counter Files      ${GN_OAM_ADDR}

    # Transfer counter files on VM disk:
    log                                Transfer counter files on VM disk
    ${xmlpath}=                        Catenate             /home/ute/${CAMPAIGN_NAME}_Counters/${fullStartDate}
    Create Directory                   ${xmlpath}
    WebEM Download XML files           ${GN_OAM_ADDR}       ${xmlList}       ${xmlpath}

    # First Cell -  Get then display the DRX counters values:
    ${tempName}=                       Set Cell Distant Name     ${CELL_NUMBER}
    ${cellName}=                       Catenate                  PLMN-PLMN/${tempName}
    log                                Get DRX counters values for cell : ${cellName}
    ${drxActive1}=    WebEM Get Counter Value   ${xmlList}   ${xmlpath}   ${timeSlotList}   ${SLOTS_UE_DRX_ACTIVE}
    ...   ${cellName}
    ${drxSleep1}=     WebEM Get Counter Value   ${xmlList}   ${xmlpath}   ${timeSlotList}   ${SLOTS_UE_DRX_SLEEP}
    ...    ${cellName}
    ${drxSleep1}=                      Run Keyword If            '${drxSleep1}'=='0'       evaluate          1
    ...                                            ELSE          Set Variable              ${drxSleep1}
    Log                                drxActive1: ${drxActive1} / drxSleep1 : ${drxSleep1}

    # Second Cell - Get then display the DRX counters values:
    ${tempName}=                       Set Cell Distant Name     ${CELL_FOR_HO}
    ${cellName}=                       Catenate                  PLMN-PLMN/${tempName}
    log                                Get DRX counters values for cell : ${cellName}
    ${drxActive2}=                     WebEM Get Counter Value   ${xmlList}   ${xmlpath}   ${timeSlotList}
    ...   ${SLOTS_UE_DRX_ACTIVE}   ${cellName}
    ${drxSleep2}=                      WebEM Get Counter Value   ${xmlList}   ${xmlpath}   ${timeSlotList}
    ...   ${SLOTS_UE_DRX_SLEEP}    ${cellName}
    ${drxSleep2}=                      Run Keyword If            '${drxSleep2}'=='0'        evaluate          1
    ...                                            ELSE          Set Variable              ${drxSleep2}
    Log                                drxActive2: ${drxActive2} / drxSleep2 : ${drxSleep2}

    # DRX Counters Total Value:
    ${drxSleep}=                       Evaluate            ${drxSleep1}.0 + ${drxSleep2}.0
    ${drxActive}=                      Evaluate            ${drxActive1}.0 + ${drxActive2}.0
    Log                                drxActive: ${drxActive} / drxSleep : ${drxSleep}

    # Get then display the HO counters values:
    ${hoAttempt}=                      WebEM Get Drx Counter Value   ${xmlList}   ${xmlpath}   ${timeSlotList}
    ...   ${HO_ATT_UE_IN_DRX}
    ${hoSuccess}=                      WebEM Get Drx Counter Value   ${xmlList}   ${xmlpath}   ${timeSlotList}
    ...   ${HO_SUCC_UE_IN_DRX}
    Log                                hoSuccess: ${hoSuccess} / hoAttempt : ${hoAttempt}

    # Check if Slots DRX counters ratio are correct:
    log                                Select The Drx Counters Ratio Depending the Load
    Estimate The Drx Counters Ratio
    log                                Check DRX Counters ratio
    ${RatioMin}=                       Evaluate            ${THRESHOLD_MIN} / 100.0
    ${RatioMax}=                       Evaluate            ${THRESHOLD_MAX} / 100.0
    ${RatioSum}=                       Evaluate            ${drxActive} / (${drxActive} + ${drxSleep})
    ${expression}=                     Run Keyword If      ${RatioMin} < ${RatioSum} and ${RatioSum} < ${RatioMax}
    ...                                                    Set Variable    True
    ...                                            ELSE    Set Variable    False
    set suite variable                 ${checkDrxRatio}    ${expression}

    # Check if the HO counters are correct:
    Check if HO counters are correct    ${hoAttempt}   ${hoSuccess}


Check Counters Files HO InterGNB
    [Documentation]      Get XML Counter Files list from WebEM: HO InterGNB Case - CODE A REVOIR DES QUE POSSIBLE
    [Arguments]                        ${GNB_HO_SOURCE}          ${GNB_HO_TARGET}
    # Get IP addresses of GNB Source and Target:
    ${GNB_SOURCE_OAM_ADDR}=            Catenate                  10.14.48.${GNB_HO_SOURCE}
    ${GNB_TARGET_OAM_ADDR}=            Catenate                  10.14.48.${GNB_HO_TARGET}

    # Get Counters files list:
    ${xmlList1}=                       WebEM Get XML Counter Files      ${GNB_SOURCE_OAM_ADDR}
    ${xmlList2}=                       WebEM Get XML Counter Files      ${GNB_TARGET_OAM_ADDR}

    # Transfer counter files on VM disk:
    log                                Transfer counter files on VM disk
    ${xmlpath1}=                       Catenate    /tmp/${CAMPAIGN_NAME}_Counters_CV${GNB_HO_SOURCE}/${fullStartDate}
    ${xmlpath2}=                       Catenate    /tmp/${CAMPAIGN_NAME}_Counters_CV${GNB_HO_TARGET}/${fullStartDate}
    Create Directory                   ${xmlpath1}
    Create Directory                   ${xmlpath2}
    WebEM Download XML files           ${GNB_SOURCE_OAM_ADDR}    ${xmlList1}       ${xmlpath1}
    WebEM Download XML files           ${GNB_TARGET_OAM_ADDR}    ${xmlList2}       ${xmlpath2}

    # First Cell - Get then display the DRX and HO counters values:
    ${cellName}=                       Catenate                  PLMN-PLMN/${CV${GNB_HO_SOURCE}_NRCELL_${CELL_NUMBER}}
    log                                Get DRX counters values for cell : ${cellName}
    ${drxActive1}=    WebEM Get Counter Value   ${xmlList1}   ${xmlpath1}   ${timeSlotList}   ${SLOTS_UE_DRX_ACTIVE}
    ...   ${cellName}
    ${drxSleep1}=     WebEM Get Counter Value   ${xmlList1}   ${xmlpath1}   ${timeSlotList}   ${SLOTS_UE_DRX_SLEEP}
    ...    ${cellName}
    ${drxSleep1}=                      Run Keyword If            '${drxSleep1}'=='0'        evaluate          1
    ...                                            ELSE          Set Variable              ${drxSleep1}
    Log                                drxActive1: ${drxActive1} / drxSleep1 : ${drxSleep1}
    ${hoAttempt1}=                     WebEM Get Drx Counter Value   ${xmlList1}   ${xmlpath1}   ${timeSlotList}
    ...   ${HO_ATT_UE_IN_DRX}
    ${hoSuccess1}=                     WebEM Get Drx Counter Value   ${xmlList1}   ${xmlpath1}   ${timeSlotList}
    ...   ${HO_SUCC_UE_IN_DRX}
    Log                                hoSuccess1: ${hoSuccess1} / hoAttempt1 : ${hoAttempt1}

    # Second Cell - Get then display the DRX and HO counters values:
    ${cellName}=                       Catenate                  PLMN-PLMN/${CV${GNB_HO_TARGET}_NRCELL_${CELL_FOR_HO}}
    log                                Get DRX counters values for cell : ${cellName}
    ${drxActive2}=                     WebEM Get Counter Value   ${xmlList2}   ${xmlpath2}   ${timeSlotList}
    ...   ${SLOTS_UE_DRX_ACTIVE}   ${cellName}
    ${drxSleep2}=                      WebEM Get Counter Value   ${xmlList2}   ${xmlpath2}   ${timeSlotList}
    ...   ${SLOTS_UE_DRX_SLEEP}    ${cellName}
    ${drxSleep2}=                      Run Keyword If            '${drxSleep2}'=='0'        evaluate          1
    ...                                            ELSE          Set Variable              ${drxSleep2}
    Log                                drxActive2: ${drxActive2} / drxSleep2 : ${drxSleep2}
    ${hoAttempt2}=                     WebEM Get Drx Counter Value   ${xmlList2}   ${xmlpath2}   ${timeSlotList}
    ...   ${HO_ATT_UE_IN_DRX}
    ${hoSuccess2}=                     WebEM Get Drx Counter Value   ${xmlList2}   ${xmlpath2}   ${timeSlotList}
    ...   ${HO_SUCC_UE_IN_DRX}
    Log                                hoSuccess2: ${hoSuccess2} / hoAttempt2 : ${hoAttempt2}

    # DRX Counters Total Value:
    ${drxSleep}=                       Evaluate            ${drxSleep1}.0 + ${drxSleep2}.0
    ${drxActive}=                      Evaluate            ${drxActive1}.0 + ${drxActive2}.0
    ${hoAttempt}=                      Evaluate            ${hoAttempt1}.0 + ${hoAttempt2}.0
    ${hoSuccess}=                      Evaluate            ${hoSuccess1}.0 + ${hoSuccess2}.0

    # Check if Slots DRX counters ratio are correct:
    log                                Select The Drx Counters Ratio Depending the Load
    Estimate The Drx Counters Ratio
    log                                Check DRX Counters ratio
    ${RatioMin}=                       Evaluate            ${THRESHOLD_MIN} / 100.0
    ${RatioMax}=                       Evaluate            ${THRESHOLD_MAX} / 100.0
    ${RatioSum}=                       Evaluate            ${drxActive}.0 / (${drxActive}.0 + ${drxSleep}.0)
    ${expression}=                     Run Keyword If      ${RatioMin} < ${RatioSum} and ${RatioSum} < ${RatioMax}
    ...                                                    Set Variable    True
    ...                                            ELSE    Set Variable    False
    set suite variable                 ${checkDrxRatio}    ${expression}

    # Check if the HO counters are correct:
    Check if HO counters are correct    ${hoAttempt}   ${hoSuccess}


Remove PM Files
    [Documentation]                    All PM and RD files will be removed...
    [Arguments]
    csn.Connect To    hostname=${GN_OAM_ADDR}     username=${GN_OAM_USR}    password=${GN_OAM_PWD}    alias=asik
    csn.Execute                        command=${rmPMFiles}        connection=asik
    csn.Execute                        command=${rmRDFiles}        connection=asik
    csn.disconnect                     connection=asik
    log                                All PM and RD files have been removed


Estimate The Drx Counters Ratio
    [Documentation]                    Depending the load, the ratio active vs sleep may be change
    [Arguments]
    coam.connect_to                    bts_host=${GN_OAM_ADDR}
    ${SW_Version}=                     coam.get_sw_version
    set suite variable                 ${SW_Version}
    Run Keyword if                     'SBTS' in '${SW_Version}'                Select DRX Ratio For SBTS Load
    Run Keyword if                     '5G21A' in '${SW_Version}'                  Select DRX Ratio For 5G21A Load
    Run Keyword if                     '5G19A' in '${SW_Version}'                  Select DRX Ratio For 5G19A Load
    Run Keyword if                     '5G19B_GNB_0007_001' in '${SW_Version}'     Select DRX Ratio For 5G19BB1 Load
    Run Keyword if                     '5G19B_GNB_0007_002' in '${SW_Version}'     Select DRX Ratio For 5G19BB2 Load
    Run Keyword if                     '5G19B_GNB_0007_003' in '${SW_Version}'     Select DRX Ratio For 5G19BB3 Load
    Run Keyword if                     '5G20A' in '${SW_Version}'                  Select DRX Ratio For 5G20A Load
    Run Keyword if                     '5G20B' in '${SW_Version}'                  Select DRX Ratio For 5G20B Load
    coam.teardown

Select DRX Ratio For SBTS Load
    [Documentation]                    Ratio for SBTS Load
    [Arguments]
    log                                A SBTS has been detected
    Run Keyword if                     '${IS_FIRST_CALL}'=='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      11
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      35
    Run Keyword if                     '${IS_FIRST_CALL}'!='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      11
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      24

Select DRX Ratio For 5G21A Load
    [Documentation]                    Ratio for 5G21A Load
    [Arguments]
    log                                A 5G21A has been detected
    Run Keyword if                     '${IS_FIRST_CALL}'=='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      11
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      35
    Run Keyword if                     '${IS_FIRST_CALL}'!='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      11
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      30

Select DRX Ratio For 5G20B Load
    [Documentation]                    Ratio for 5G20B Load
    [Arguments]
    log                                A 5G20B has been detected
    Run Keyword if                     '${IS_FIRST_CALL}'=='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      11
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      35
    Run Keyword if                     '${IS_FIRST_CALL}'!='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      11
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      30


Select DRX Ratio For 5G20A Load
    [Documentation]                    Ratio for 5G20A Load
    [Arguments]
    log                                A 5G20A has been detected
    Run Keyword if                     '${IS_FIRST_CALL}'=='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      23
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      28
    Run Keyword if                     '${IS_FIRST_CALL}'!='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      11
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      24


Select DRX Ratio For 5G19BB3 Load
    [Documentation]                    Ratio for 5G19BB3 Load
    [Arguments]
    log                                A 5G19B Branch 2 has been detected
    Run Keyword if                     '${IS_FIRST_CALL}'=='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      23
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      27
    Run Keyword if                     '${IS_FIRST_CALL}'!='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      11
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      14


Select DRX Ratio For 5G19BB2 Load
    [Documentation]                    Ratio for 5G19BB2 Load
    [Arguments]
    log                                A 5G19B Branch 2 has been detected
    Run Keyword if                     '${IS_FIRST_CALL}'=='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      23
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      27
    Run Keyword if                     '${IS_FIRST_CALL}'!='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      11
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      14


Select DRX Ratio For 5G19BB1 Load
    [Documentation]                    Ratio for 5G19BB1 Load
    [Arguments]
    log                                A 5G19B Branch 1 has been detected
    Run Keyword if                     '${IS_FIRST_CALL}'=='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      31
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      35
    Run Keyword if                     '${IS_FIRST_CALL}'!='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      18
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      22


Select DRX Ratio For 5G19A Load
    [Documentation]                    Ratio for 5G19A Load
    [Arguments]
    log                                A 5G19A has been detected
    Run Keyword if                     '${IS_FIRST_CALL}'=='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      23
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      27
    Run Keyword if                     '${IS_FIRST_CALL}'!='True'
        ...       Run Keywords         set suite variable    ${THRESHOLD_MIN}      11
        ...       AND                  set suite variable    ${THRESHOLD_MAX}      14


Wait For Next Counter Files
    [Documentation]  This function calculates the time (in sec) before the start of the next PM counters period and
    ...    sleep
    ${timeToSleep}=    mylibpython.timeToSleepBeforeNextCountersPeriod    counterPeriod=${pm_interval}    delay=1
    ...    offset=20
    Log    Wait ${timeToSleep} seconds for clean release
    sleep    ${timeToSleep}s


#######################################
### PRISMA KEYWORDS
#######################################

Change The Call Number
    [Documentation]                    Change to False the IS_FIRST_CALL variable
    [Arguments]     ${first_call}=False
    set suite variable                 ${IS_FIRST_CALL}      ${first_call}


Launch First Call
    [Documentation]                    Launch the First Call and modify the DRX param during call
    [Arguments]
    Prepare Test Scenario
#    Prepare The Prisma For SA Mode     ${SCENARIO_NAME}
    sleep                              10s
    mylib772.prepare_test              ${CAMPAIGN_NAME}
    mylib772.start_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    Note Start Date
    Launch Test And Sleep
    log                                Modify DRX Long Cycle to ${longCycleSecondValue} (this can take up to 35s)
    Change The DRX Parameters          ${defDrxInactivityTimer}
    ...                                ${longCycleSecondValue}    ${defDrxOnDurationTimer}
    log                                Wait end Scenario
    ${MaxScenarioTime}=                Evaluate    ${CALL_DURATION}
    Wait for scenario to end           ${MaxScenarioTime}s
    Note End Date
#    Stop Test Manager
    mylib772.stop_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    log                                Check Scenario Result
    Check Execution Result             1


Launch Second Call
    [Documentation]                    Launch the Second Call
    [Arguments]
    Prepare Test Scenario
#    Prepare The Prisma For SA Mode     ${SCENARIO_NAME}
    mylib772.start_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    Note Start Date
    Launch Test Scenario
    Note End Date
    mylib772.stop_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    Stop Test Manager
    log                                Check Scenario Result
    Check Execution Result             1
    log    Set DRX long cycle to Default Value (${defDrxLongCycle}) (this can take up to 35s)
    Change The DRX Parameters          ${defDrxInactivityTimer}
    ...                                ${defDrxLongCycle}         ${defDrxOnDurationTimer}


Launch Test and Analysis
    [Documentation]                    Launch the Test Scenario
    [Arguments]
    Prepare Test Scenario
#    Prepare The Prisma For SA Mode     ${SCENARIO_NAME}
    mylib772.prepare_test              ${CAMPAIGN_NAME}
    mylib772.start_traces   ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    Note Start Date
    Launch Test Scenario
    Note End Date
    Stop Test Manager
    mylib772.stop_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}


Launch Test And Sleep
    [Documentation]                    Launch the Prisma Scenario for TimerBeforeDrxModification sec
    [Arguments]
    Launch L3 Call Prisma
    sleep                              ${TimerBeforeDrxModification}


Launch Test Scenario
    [Documentation]                    Launch the Prisma Scenario
    [Arguments]
    Launch L3 Call Prisma
    ${MaxScenarioTime}=                Evaluate    ${CALL_DURATION} + 60
    Wait for scenario to end           ${MaxScenarioTime}s


Prepare Test Scenario
    [Documentation]                    Prepare The Prisma for SA Mode
    [Arguments]
    Prepare L3 Call Prisma real eNodeB SA Mode    ${SCENARIO_NAME}


Prepare The Prisma For SA Mode
    [Documentation]                    Prepare The Prisma for SA Mode
    [Arguments]                        ${scenarioName}
    Set Suite Variable                 ${GN_CELLID}            ${CELL_NUMBER}
    Set Suite Variable                 ${PPU_L2_ID}            p0-9
    Start Prisma UU Simulator real eNodeB SA Mode
    Start Prisma Airmosaic
    Configure Prisma Airmosaic         ${scenarioName}
    Connect To Test Manager
    Check Simulator Readiness
    Check SynchroSignals Successfully Detected By Prisma


Generic Suite Teardown
    [Documentation]                    End of The Test - Close Everything
    [Arguments]
    Run Keyword and Ignore Error       Activate DRX                      ${CELL_NUMBER}
    Run Keyword and Ignore Error       Activate DRX                      ${CELL_FOR_HO}
    Run Keyword and Ignore Error       Deactivate SRB3
    Run Keyword and Ignore Error       Stop L3 Call Prisma
    Run Keyword and Ignore Error       mylib772.stop_test                ${GN_OAM_ADDR}
    mylib772.campaign_teardown         ${CAMPAIGN_NAME}    ${GN_OAM_ADDR}    ${SUITE_STATUS}    ${SUITE MESSAGE}
    sleep                              1s
    Stop Test Manager


#######################################
### QUALCOMM KEYWORDS
#######################################

QCT Attach Ue Used In Test
    [Documentation]                    Establish the call
    [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_NSA
    ${5Gstatus}    Set Variable    PASS
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    #${power_status}    Set Variable    False
    Log to console         UE Attached
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}


QCT Detach UE Used In Test
    [Documentation]                    Release the established call
    [Arguments]
    ${passed}                          Run Keyword and return status   power_ue.UE Detach    ue_type=${ue_type}
    Log                                The Detach Ue Status is: ${passed}


QCT Estimate Call Duration
    [Documentation]                    Based on attach and detach time, estimate the delta in second
    [Arguments]
    ${temporaryDate}=                  mylibpython.getCallDuration    ${AttachTime}    ${DetachTime}
    set suite variable                 ${CALL_DURATION}       ${temporaryDate}
    log                                Call Duration = ${CALL_DURATION}


QCT Launch Test and Analysis
    [Documentation]                    Prepare and Launch the Test scenario
    [Arguments]                        ${UE_id}            ${campaignId}    ${attach_mode}=5G_NSA
    mylib772.prepare_test              campaignName=${campaignId}
    mylib772.start_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    Note Start Date
    Get Attach Time
    QCT Attach Ue Used In Test         ue_index=${UE_id}    attach_mode=${attach_mode}
    sleep                              ${CALL_DURATION}s
    Get Detach Time
    QCT Detach UE Used In Test
    Note End Date
    QCT Estimate Call Duration
    QCT Give Traces Time To Be Full
    mylib772.stop_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}

QCT Launch Test With Traffic and Analysis
    [Documentation]                    Prepare and Launch the Test scenario
    [Arguments]
    #mylib772.prepare_test              campaignName=${campaignId}
    #mylib772.start_traces              ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    #Start to collect wireshark log with admin
    #Start to collect wireshark log with admin f1ap
    #Start to collect wireshark log with admin in ASIB ASIL
    Get system module ip from positionInSubrack
    Run Keyword If   '${hw_info_new}' == 'ASIB'     Start to collect wireshark log with admin in ASIB ASIL
    ...         ELSE     Run Keywords    Start to collect wireshark log with admin  AND  Start to collect wireshark log with admin f1ap
    Note Start Date
    Get Attach Time
    ${5Grach_ed}    power_ue.UE Attach    ue_type=samsung    attach_mode=5G_NSA
    power_ue.Verify attach    ue_type=samsung    5Grach_ed=${5Grach_ed}    4G_check=False
    DL traffic

    power_ue.UE Detach    ue_type=samsung
    Note End Date
    Get Detach Time
    QCT Estimate Call Duration
    QCT Give Traces Time To Be Full
    #mylib772.stop_traces               ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    #Stop collecting wireshark log with admin
    #Stop collecting wireshark log with admin f1ap
    Run Keyword If   '${hw_info_new}' == 'ASIB'     Stop collecting wireshark log with admin
    ...         ELSE     Run Keywords  Stop collecting wireshark log with admin  AND  Stop collecting wireshark log with admin f1ap


DL traffic

    #taf.ue.Require Ue                      UE_1   capabilities=REAL_ANDROID_UE
#    taf.ue.Start Data Transfer  dt_name=DT_DL  ue_alias=UE_1  direction=dl
#    ...                  duration=1000s  buffer=8M  protocol=udp  throughput=300Mbits/sec     packet_size=1024b
#    ...                  packet=1024b

    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=300M
    ...    duration=1000    ue_type=samsung   protocol=udp    buffer_size=1400B    seg_size=1350    window=16M
    sleep                               900s


QCT Launch Test With Traffic and Analysis for 5GC002396
    [Documentation]                    Prepare and Launch the Test scenario
    [Arguments]                        ${UE_id}            ${campaignId}     ${ue_type}
    mylib772.prepare_test              campaignName=${campaignId}
    mylib772.start_traces              ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    #Precondition for MTK ue attach     ue_index=${UE_id}
    wait until keyword succeeds   3 times   5min    power_ue.Prepare UE    ue_index=${UE_id}    ue_type=${ue_type}
    Note Start Date
    Get Attach Time
    Run Keyword And Ignore Error       power_ue.UE Attach    ue_index=${UE_id}    ue_type=${ue_type}
    Log to console    attach successfully for SA
    MTK Start UL Traffic   ue_index=${UE_id}     ul_time=${CALL_DURATION_NEW}
    #sleep    30s
    sleep    30s
    Capture BIP Log And Convert To CSV     UlData_puschReceiveReqGrant_t.fullPowerPuschPowerScalingRatio
    sleep   70s
    #Run Keyword And Ignore Error    power_ue.UE Detach      ue_index=${UE_id}   ue_type=${ue_type}
    Note End Date
    Get Detach Time
    QCT Estimate Call Duration
    QCT Give Traces Time To Be Full
    mylib772.stop_traces               ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
QCT Launch Test With Traffic and Analysis for 5GC002396_D_08
    [Documentation]                    Prepare and Launch the Test scenario
    [Arguments]                        ${UE_id}            ${campaignId}     ${ue_type}
    mylib772.prepare_test              campaignName=${campaignId}
    mylib772.start_traces              ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    #Precondition for MTK ue attach   ue_index=${UE_id}
    wait until keyword succeeds   3 times   5min    power_ue.Prepare UE    ue_index=${UE_id}    ue_type=${ue_type}
    Note Start Date
    Get Attach Time
    Run Keyword And Ignore Error      power_ue.UE Attach    ue_index=${UE_id}    ue_type=${ue_type}
    Log to console    attach successfully for SA
    MTK Start UL Traffic    ue_index=${UE_id}    ul_time=${CALL_DURATION_NEW}
    sleep    10s


    #Adjust Attenuation Value For 2396    ${5GRU_ANT2}    value=${35}    att_connection_port=@{att_connection_port}
    att.setup_attenuator    attenuator=${PA_INFO}
    att.set_attenuation     port=${6}    value=${40}

    sleep    10s
    Capture BIP Log And Convert To CSV
    ...  uldata_puschreceivereq
    sleep   70s
    #Run Keyword And Ignore Error    power_ue.UE Detach      ue_index=${UE_id}   ue_type=${ue_type}
    Note End Date
    Get Detach Time
    QCT Estimate Call Duration
    QCT Give Traces Time To Be Full
    mylib772.stop_traces               ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
MTK Start UL Traffic
    [Arguments]    ${ue_index}=0   ${ul_time}=120   ${ul_port}=45970  ${process_num}=1  ${window}=2M
    ${command}    Catenate    adb -s 0123456789ABCDEF shell /data/local/tmp/iperf
    ...     -c ${tl.ues[${ue_index}].iperf_details.network_interface_address}
    ...     -u -p ${ul_port} -t ${ul_time} -P ${process_num} -i 1 -f m -b 40M -l 1400B -T 64 -w ${window}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send_command    command=${command}    connection=cpc_${ue_index}
    csn.disconnect    connection=cpc_${ue_index}

QCT Launch First Call
    [Documentation]                    Prepare and Launch the First Call
    [Arguments]                        ${UE_id}            ${campaignId}    ${attach_mode}=5G_NSA
    mylib772.prepare_test              campaignName=${campaignId}
    mylib772.start_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    Note Start Date
    Get Attach Time
    QCT Attach Ue Used In Test         ue_index=${UE_id}    attach_mode=${attach_mode}
    sleep                              ${TimerBeforeDrxModification}
    log    Modify DRX long cycle to ${longCycleSecondValue} (this can take up to 35s)
    Run keyword If  '${release_sbts}'=='SBTS23R3'
    ...  Change The DRX Parameters 23R3    ${CELL_NUMBER}             ${defDrxInactivityTimer}
    ...                                ${longCycleSecondValue}    ${defDrxOnDurationTimer}
    ...                                ${defDrxRetransTimerDl}    ${defDrxRetransTimerUl}
    ...  ELSE  Change The DRX Parameters    ${defDrxInactivityTimer}
    ...                                ${longCycleSecondValue}    ${defDrxOnDurationTimer}



    sleep                              ${TimerAfterDrxModification}
    Get Detach Time
    QCT Detach UE Used In Test
    Note End Date
    QCT Estimate Call Duration
    QCT Give Traces Time To Be Full
    Log                                x2apTraces: ${x2apTraces} / f1apTraces : ${f1apTraces}
    mylib772.stop_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}


QCT Launch Second Call
    [Documentation]                    Prepare and Launch the Second Call
    [Arguments]                        ${UE_id}            ${attach_mode}=5G_NSA
    mylib772.start_traces    ${GN_OAM_ADDR}      ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    Note Start Date
    Get Attach Time
    QCT Attach Ue Used In Test         ue_index=${UE_id}    attach_mode=${attach_mode}
    sleep                              ${CALL_DURATION}s
    Get Detach Time
    QCT Detach UE Used In Test
    Note End Date
    QCT Estimate Call Duration
    QCT Give Traces Time To Be Full
    mylib772.stop_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    log    Set DRX long cycle to Default Value (${defDrxLongCycle}) (this can take up to 35s)
    Run keyword If  '${release_sbts}'=='SBTS23R3'
    ...  Change The DRX Parameters 23R3    ${CELL_NUMBER}        ${defDrxInactivityTimer}
    ...                                ${defDrxLongCycle}        ${defDrxOnDurationTimer}
    ...                                ${defDrxRetransTimerDl}    ${defDrxRetransTimerUl}
    ...  ELSE  Change The DRX Parameters    ${defDrxInactivityTimer}
    ...                                ${defDrxLongCycle}         ${defDrxOnDurationTimer}


QCT Launch Call With HandOver
    [Documentation]                    During the Call an HandOver IntraDU is Done
    [Arguments]                        ${UE_id}            ${campaignId}
    mylib772.prepare_test              campaignName=${campaignId}
    mylib772.start_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    Note Start Date
    Get Attach Time
    QCT Attach Ue Used In Test         ue_index=${UE_id}
    mylib772.Start_HO_IntraDU
    Get Detach Time
    QCT Detach UE Used In Test
    Note End Date
    QCT Estimate Call Duration
    QCT Give Traces Time To Be Full
    mylib772.stop_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    mylib772.HO_Teardown


QCT Launch Call On UEs
    [Documentation]                    Prepare and Launch the Test scenario
    [Arguments]                        ${UE_id1}      ${UE_id2}      ${campaignId}    ${attach_mode}=5G_NSA
    mylib772.prepare_test              campaignName=${campaignId}
    mylib772.start_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    Note Start Date
    QCT Attach Ue Used In Test         ue_index=${UE_id1}    attach_mode=${attach_mode}
    sleep                              60s
    QCT Detach UE Used In Test
    sleep                              30s
    QCT Attach Ue Used In Test         ue_index=${UE_id2}    attach_mode=${attach_mode}
    sleep                              60s
    QCT Detach UE Used In Test
    Note End Date
    QCT Give Traces Time To Be Full
    mylib772.stop_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}


QCT Launch The Use Case Detector OLD WAY
    [Documentation]                    Launch StateMachine To Check the Dataflow
    [Arguments]
    ${ListOfStateMachine}              Create List    @{SM_TO_BE_RUN}
    Run Keyword if    '5G20A' in '${5GLoadVersion}'    append to list    ${ListOfStateMachine}    Stub.sm
    ...         ELSE                   append to list    ${ListOfStateMachine}    ${SM_TO_BE_RUN_20A}
    mylib772.LaunchSpecificUCD         smList=${ListOfStateMachine}


QCT Launch The Use Case Detector
    [Documentation]                    Launch StateMachine To Check the Dataflow
    [Arguments]
    ${ListOfStateMachine}              Create List
    FOR    ${list_item}     IN         @{SM_TO_BE_RUN}
           append to list              ${ListOfStateMachine}    ${list_item}
    END
    FOR    ${list_item}     IN         @{SM_TO_BE_RUN_20A}
           Run Keyword if   'Trunk' in '${5GLoadVersion}'    append to list    ${ListOfStateMachine}    ${list_item}
    END
    append to list                     ${ListOfStateMachine}    Stub.sm
    mylib772.LaunchSpecificUCD         smList=${ListOfStateMachine}


QCT Give Traces Time To Be Full
    [Documentation]                    Don't stop traces too quickly
    [Arguments]
    sleep                              15s


QCT Generic Suite Teardown
    [Documentation]                    End of The Test - Close Everything
    [Arguments]
    Run Keyword and Ignore Error       Activate DRX                      ${CELL_NUMBER}
    Run Keyword and Ignore Error       Activate DRX                      ${CELL_FOR_HO}
    Run Keyword and Ignore Error       Deactivate SRB3
    Run Keyword and Ignore Error       mylib772.stop_test                ${GN_OAM_ADDR}
    Run Keyword and Ignore Error       QCT Detach UE Used In Test
    mylib772.campaign_teardown         ${CAMPAIGN_NAME}    ${GN_OAM_ADDR}    ${SUITE_STATUS}    ${SUITE MESSAGE}
    sleep                              1s
    Run Keyword And Ignore Error       coam.teardown
    Run Keyword And Ignore Error       csn.reset_cache

QCT Generic Suite Teardown for 5GC002396
    [Documentation]                    End of The Test - Close Everything
    [Arguments]                 ${CAMPAIGN_NAME}=5GC002396
    #Adjust Attenuation Value    ${5GRU_ANT3}    value=${0}
    #Adjust Attenuation Value For 2396    ${5GRU_ANT3}    value=${0}    att_connection_port=@{att_connection_port2}
    #Adjust Attenuation Value For 2396    ${5GRU_ANT4}    value=${0}    att_connection_port=@{att_connection_port2}
    #Adjust Attenuation Value For 2396    ${5GRU_ANT5}    value=${0}    att_connection_port=@{att_connection_port3}
    #Adjust Attenuation Value For 2396    ${5GRU_ANT6}    value=${0}    att_connection_port=@{att_connection_port3}

    att.setup_attenuator    attenuator=${PA_INFO}
    att.set_attenuation     port=${1}    value=${0}
    att.set_attenuation     port=${2}    value=${0}
    att.set_attenuation     port=${7}    value=${0}
    att.set_attenuation     port=${8}    value=${0}

    Deactivate FullPwrMode feature
    Verify Site On Air
    Run Keyword and Ignore Error       mylib772.stop_test                ${GN_OAM_ADDR}
    mylib772.campaign_teardown         ${CAMPAIGN_NAME}    ${GN_OAM_ADDR}    ${SUITE_STATUS}    ${SUITE MESSAGE}
    sleep                              1s
    Run Keyword And Ignore Error       power_ue.UE Detach     ue_index=${UE_id}    ue_type=${ue_type}
    Run Keyword And Ignore Error       coam.teardown
    Run Keyword And Ignore Error       csn.reset_cache

QCT Generic Test Teardown
    [Documentation]                    End of The Test - Close Everything
    [Arguments]    ${CAMPAIGN_NAME}
    Run Keyword and Ignore Error       Activate DRX                      ${CELL_NUMBER}
    Run Keyword and Ignore Error       Activate DRX                      ${CELL_FOR_HO}
    Run Keyword and Ignore Error       Deactivate SRB3
    Run Keyword and Ignore Error       mylib772.stop_test                ${GN_OAM_ADDR}
    Run Keyword and Ignore Error       QCT Detach UE Used In Test
    mylib772.campaign_teardown         ${CAMPAIGN_NAME}    ${GN_OAM_ADDR}    ${TEST_STATUS}    ${TEST MESSAGE}
    sleep                              1s
    Run Keyword And Ignore Error       coam.teardown
    Run Keyword And Ignore Error       csn.reset_cache
#######################################
### ASKEY KEYWORDS
#######################################

ASKEY Require UE
    [Documentation]                    Prepare all data to be used with an Askey UE
    [Arguments]
    Wait Until Keyword Succeeds        120 s    5 s
    ...                                robssh.Open Connection      ${ip_addr_pcue}
    ...                                escape_ansi=True            newline=CRLF
    ...                                alias=PCUE-conn
    Wait Until Keyword Succeeds        120 s    5 s
    ...                                robssh.Login
    ...                                username=${pcue_uname}      password=${pcue_pswd}
    sleep                              2 s
    ${topurge}=                        robssh.Read
    #robssh.Set client Configuration    prompt=${prompt_pc_ue}

    # Copy Python script on UE PC
    robssh.Put File                    ${CURDIR}/Require_UE.py      ./Mng_UE/Require_UE.py
    sleep                              1 s
    robssh.Put File                    ${CURDIR}/AttachUE.py        ./Mng_UE/AttachUE.py
    sleep                              1 s
    robssh.Put File                    ${CURDIR}/DetachUE.py        ./Mng_UE/DetachUE.py
    sleep                              1 s
    robssh.Put File                    ${CURDIR}/AirplaneOff.py     ./Mng_UE/AirplaneOff.py
    sleep                              1 s
    robssh.Put File                    ${CURDIR}/AirplaneOn.py      ./Mng_UE/AirplaneOn.py

    # Require Askey UE
    ${commandToSend}=    catenate    ${Ppython3} ./Mng_UE/Require_UE.py -p ${AT_port} -i ${imsi} -e ${imei}
    ${rc}=                             Execute Command    ${commandToSend}   return_stdout=False    return_rc=True
    Should Be Equal                    ${rc}              ${0}


ASKEY Attach Ue Used In Test
    [Documentation]                    Establish the call
    [Arguments]
    ${commandToSend}=                  catenate    ${Ppython3} ./Mng_UE/AttachUE.py -p ${AT_port} -i ${ueIpAttach}
    ${rc}=                             Execute Command    ${commandToSend}   return_stdout=False    return_rc=True
    Should Be Equal                    ${rc}              ${0}


ASKEY Wait for Attach UE Used In Test
    [Documentation]                    When Airplane mode is set to Off, the UE will do automaticaly the attach
       ...                             It could take one minute.
       ...                             So, we just wait the attach by checking cyclally the attach
    [Arguments]
    ${commandToSend}=              catenate    ${Ppython3} ./Mng_UE/WaitAttachUE.py -p ${AT_port} -i ${ueIpAttach}
    ${rc}=                             Execute Command    ${commandToSend}   return_stdout=False    return_rc=True
    Should Be Equal                    ${rc}              ${0}


ASKEY Detach UE Used In Test
    [Documentation]                    Release the established call
    [Arguments]
    ${commandToSend}=                  catenate    ${Ppython3} ./Mng_UE/DetachUE.py -p ${AT_port} -i ${ueIpDetach}
    ${rc}=                             Execute Command    ${commandToSend}   return_stdout=False    return_rc=True
    Should Be Equal                    ${rc}              ${0}


ASKEY Airplane Mode On
    [Documentation]                    Activate the Airplane mode on UE
    [Arguments]
    ${commandToSend}=                  catenate    ${Ppython3} ./Mng_UE/AirplaneOn.py -p ${AT_port}
    ${rc}=                             Execute Command    ${commandToSend}   return_stdout=False    return_rc=True
    Should Be Equal                    ${rc}              ${0}


ASKEY Airplane Mode Off
    [Documentation]                    Deactivate the Airplane mode on UE
    [Arguments]
    ${commandToSend}=                  catenate    ${Ppython3} ./Mng_UE/AirplaneOff.py -p ${AT_port}
    ${rc}=                             Execute Command    ${commandToSend}   return_stdout=False    return_rc=True
    Should Be Equal                    ${rc}              ${0}


ASKEY Launch DL Traffic
    [Documentation]    Launch the UDP DL Traffic - Never Used ... so dont be surprised if it dont work
    [Arguments]                        ${test_duration}     ${throughput_dl}
    # Start Check AwaitEnd Verify UDP Data Transfer
    ${out}                             Convert Time            ${test_duration}         result_format=number
    ${duration}                        Convert to String       ${out}s
    # Start Data Transfer DL ${duration} ${throughput_dl}
    Start Data Transfer
    ...                                dt_name=DT_1
    ...                                ue_alias=UE_1
    ...                                direction=dl
    ...                                duration=${duration}
    ...                                throughput=${throughput_dl}
    ...                                protocol=udp
    ...                                packet_size=1350

    # Sleep for test_duration secondes
    sleep                              ${test_duration}


ASKEY Estimate Call Duration
    [Documentation]                    Based on attach and detach time, estimate the delta in second
    [Arguments]
    ${temporaryDate}=                  mylibpython.getCallDuration    ${AttachTime}    ${DetachTime}
    set suite variable                 ${CALL_DURATION}       ${temporaryDate}
    log                                Call Duration = ${CALL_DURATION}


ASKEY Give Traces Time To Be Full
    [Documentation]                    Don't stop traces too quickly
    [Arguments]
    sleep                              15s


ASKEY Launch Test and Analysis
    [Documentation]                    Prepare and Launch the Test scenario
    [Arguments]                        ${campaignId}
    mylib772.prepare_test              campaignName=${campaignId}
    mylib772.start_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    Note Start Date
    Get Attach Time
    ASKEY Attach Ue Used In Test
    sleep                              ${CALL_DURATION}s
    Get Detach Time
    ASKEY Detach UE Used In Test
    Note End Date
    ASKEY Estimate Call Duration
    ASKEY Give Traces Time To Be Full
    mylib772.stop_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}


ASKEY Launch First Call
    [Documentation]                    Prepare and Launch the First Call
    [Arguments]                        ${campaignId}
    mylib772.prepare_test              campaignName=${campaignId}
    mylib772.start_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    Note Start Date
    Get Attach Time
    ASKEY Attach Ue Used In Test
    sleep                              ${TimerBeforeDrxModification}
    log    Modify DRX long cycle to ${longCycleSecondValue} (this can take up to 35s)
    Change The DRX Parameters          ${defDrxInactivityTimer}
    ...                                ${longCycleSecondValue}    ${defDrxOnDurationTimer}
    sleep                              ${TimerAfterDrxModification}
    Get Detach Time
    ASKEY Detach UE Used In Test
    Note End Date
    ASKEY Estimate Call Duration
    ASKEY Give Traces Time To Be Full
    mylib772.stop_traces               ${GN_OAM_ADDR}    False    True    ${5GLoadVersion}    ${hw_type}


ASKEY Launch Second Call
    [Documentation]                    Prepare and Launch the Second Call
    [Arguments]
    mylib772.start_traces              ${GN_OAM_ADDR}      False    True    ${5GLoadVersion}    ${hw_type}
    Note Start Date
    Get Attach Time
    ASKEY Attach Ue Used In Test
    sleep                              ${CALL_DURATION}s
    Get Detach Time
    ASKEY Detach UE Used In Test
    Note End Date
    ASKEY Estimate Call Duration
    ASKEY Give Traces Time To Be Full
    mylib772.stop_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    log    Set DRX long cycle to Default Value (${defDrxLongCycle}) (this can take up to 35s)
    Change The DRX Parameters          ${defDrxInactivityTimer}
    ...                                ${defDrxLongCycle}         ${defDrxOnDurationTimer}


ASKEY Launch Call With HandOver
    [Documentation]                    During the Call an HandOver IntraDU is Done
    [Arguments]                        ${campaignId}
    mylib772.prepare_test              campaignName=${campaignId}
    mylib772.start_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    Note Start Date
    Get Attach Time
    ASKEY Attach Ue Used In Test
    mylib772.Start_HO_IntraDU
    Get Detach Time
    ASKEY Detach UE Used In Test
    Note End Date
    ASKEY Estimate Call Duration
    ASKEY Give Traces Time To Be Full
    mylib772.stop_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    mylib772.HO_Teardown


ASKEY Launch Call On UEs
    [Documentation]                    Prepare and Launch the Test scenario
    [Arguments]                        ${campaignId}
    mylib772.prepare_test              campaignName=${campaignId}
    mylib772.start_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    Note Start Date
    #  En théorie, on devrait faire ce que j'ai mis en commentaire:
    # ASKEY Attach Ue Used In Test       ${UE_id1}
    # sleep                              30s
    # ASKEY Attach Ue Used In Test       ${UE_id2}
    # sleep                              30s
    # ASKEY Detach UE Used In Test       ${UE_id1}
    # sleep                              30s
    # ASKEY Detach UE Used In Test       ${UE_id2}
    # Et comme en réalité on n'a qu'un seul mobile Askey, on fait 2 appels sur le meme mobile:
    ASKEY Attach Ue Used In Test
    sleep                              60s
    ASKEY Detach UE Used In Test
    sleep                              30s
    ASKEY Attach Ue Used In Test
    sleep                              60s
    ASKEY Detach UE Used In Test
    # Fin de la réalité
    Note End Date
    ASKEY Give Traces Time To Be Full
    mylib772.stop_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}


ASKEY Generic Suite Teardown
    [Documentation]                    End of The Test - Close Everything
    [Arguments]
    Run Keyword and Ignore Error       Activate DRX                      ${CELL_NUMBER}
    Run Keyword and Ignore Error       Activate DRX                      ${CELL_FOR_HO}
    Run Keyword and Ignore Error       Deactivate SRB3
    Run Keyword and Ignore Error       mylib772.stop_test                ${GN_OAM_ADDR}
    Run Keyword and Ignore Error       ASKEY Detach UE Used In Test      ${UE_id}
    mylib772.campaign_teardown         ${CAMPAIGN_NAME}    ${GN_OAM_ADDR}    ${SUITE_STATUS}    ${SUITE MESSAGE}
    sleep                              1s

Note After End Date
    [Documentation]                    Get the Call release Date and Time
    [Arguments]
    ${temporaryDate}=                  Add Time To Date    ${endCallDate}    ${PM_INTERVAL}min    exclude_millis=yes
    #${temporaryDate}=                  Add Time To Date    ${temporaryDate}    ${PM_INTERVAL}min    exclude_millis=yes
    ${temporaryDate}=                  mylibpython.setToPMFormat    ${temporaryDate}
    set suite variable                 ${afterCallDate}                   ${temporaryDate}
    Log                                The Call release Date is: ${afterCallDate}

    @{temporaryList}                   create list
    append to list                     ${temporaryList}    ${afterCallDate}
    set suite variable                 ${timeSlotList1}     ${temporaryList}
    log                                timeSlotList = ${timeSlotList1}
    # sleep                              ${pm_interval}mins

Get and Check Counters Files After End call
    [Documentation]                    Get XML Counter Files list from WebEM
    [Arguments]
    # Get Counters files list:
    ${xmlList}=                        WebEM Get XML Counter Files      ${GN_OAM_ADDR}

    # Transfer counter files on VM disk:
    log                                Transfer counter files on VM disk
    Run Keyword and Ignore Error       WebEM Download XML files           ${GN_OAM_ADDR}       ${xmlList}    ${xmlpath}
    ${xmlList}=                        UTE Get XML Counter Files    ${xmlpath}

    # Get then display the DRX counters values:
    log                                Get DRX counters values for cell : ${cellName}
    ${drxActive1}=                      WebEM Get Counter Value   ${xmlList}   ${xmlpath}   ${timeSlotList1}
    ...   ${SLOTS_UE_DRX_ACTIVE}   ${cellName}
    ${drxSleep1}=                       WebEM Get Counter Value   ${xmlList}   ${xmlpath}   ${timeSlotList1}
    ...   ${SLOTS_UE_DRX_SLEEP}    ${cellName}
    Log                                drxActive1: ${drxActive1} / drxSleep1 : ${drxSleep1}
    ${expression}=                     Run Keyword If      '${drxSleep1}'=='0' and '${drxActive1}'=='0'
    ...                                                    Set Variable    True
    ...                                            ELSE    Set Variable    False
    set suite variable                 ${checkCounter}    ${expression}

Check system module
#    ${hw_type}    set variable    ${tl.tl_cloud_topology.split('_')[4]}
    Connect to gnb coam via ssl
    ${fsm_info}    coam.get_fsm_info    connection=GNB_OAM
    ${hw_info}    Set Variable    ${fsm_info[0]['productName']}
    ${hw_infos}    Split String    ${hw_info}    ${SPACE}
    ${hw_info_position}    Set Variable    ${fsm_info[0]['positionInSubrack']}
    ${hw_info_position_s}    Get Substring    ${hw_info_position}    0    1
    ${hw_type}    Catenate    SEPARATOR=    ${hw_infos[0]}    ${hw_info_position_s}
    Log    ${hw_type}
    Set Suite Variable    ${hw_type}
    Run Keyword If    'ASIL' in '${hw_type}'    Set Suite Variable    ${hw_type}     ASIB


get scf file
    Log                   \nGet scf file ${SCF} and copy it to ${CURDIR}/SCF_Directory
    coam.connect_to                    bts_host=${GN_OAM_ADDR}
    Set Environment Variable               https_proxy                 ${empty}
    coam.get_current_scf_file    ${CURDIR}/SCF_Directory     ${SCF}
    scf.load_scf          ${CURDIR}/SCF_Directory/${SCF}
    coam.teardown

validate scf file
    Log                   \nvalidate ${CURDIR}/SCF_Directory/${SCF}
    Log to console    \nvalidate ${CURDIR}/SCF_Directory/${SCF}
    coam.connect_to                    bts_host=${GN_OAM_ADDR}
    Set Environment Variable               https_proxy                 ${empty}
    ${scf_validation_results}=            coam.validate_scf                ${CURDIR}/SCF_Directory/${SCF}
    Should Be Equal As Strings  ${scf_validation_results["pdlValidationResult"]["status"]}  OK
    coam.teardown

Activate DRX in scf
    [Documentation]                    Activate and Configure The DRX feature
    [Arguments]                        ${cell_id}
    Log     Modify DRX long cycle
    ${d_name}=                         Set Cell Distant Name             ${cell_id}
    ${p_name}                          set variable                      actCDrx
    ${CurrentValue}                    gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=${p_name}
    Run Keyword if                     '${CurrentValue}'=='false'
    ...                                Change A SCF Parameter            dist_name=${d_name}    p_name=${p_name}
    ...    value=true
    sleep                              1s
    ${d_name}=                         Set NRBTS Distant Name
#    ${p_name}                          set variable                      actInactDetNSAUe
#    ${CurrentValue}                    gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=${p_name}
#    Run Keyword if                     '${CurrentValue}'=='true'
#    ...                                Change A SCF Parameter            dist_name=${d_name}    p_name=${p_name}
#    ...    value=${actInactDetNSAUe}
    ${p_name}                          set variable                      nsaInactivityTimer
    ${CurrentValue}                    gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=${p_name}
    Run Keyword if                     '${CurrentValue}'!='${nsaInactivityTimer}'
    ...                                Change A SCF Parameter            dist_name=${d_name}    p_name=${p_name}
    ...    value=${nsaInactivityTimer}
    Set Suite Variable    ${drxInactivityTimer}    4ms
#    Run keyword if                     '5G2' in '${SCF}'    Set Suite Variable    ${drxInactivityTimer}    10ms
    Log     drxInactivityTimer:${drxInactivityTimer}
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
    set suite variable    ${release_sbts}
    Run keyword If  '${release_sbts}'=='SBTS23R3'
    ...  Change The DRX Parameters 23R3  ${CELL_NUMBER}          ${drxInactivityTimer}
    ...                                ${drxLongCycle}    ${drxOnDurationTimer}
    ...                                ${drxRetransTimerDl}    ${drxRetransTimerUl}
    ...  ELSE  Change The DRX Parameters    ${drxInactivityTimer}
    ...                                ${drxLongCycle}    ${drxOnDurationTimer}
    log                                Wait end Scenario

download swconfig file
    Log                   \n${CURDIR}/Swconfig_Directory/${SWconfig}
    csn.Connect To    hostname=${GN_OAM_ADDR}     username=${GN_OAM_USR}    password=${GN_OAM_PWD}    alias=asik
    ${output}=         csn.Execute    ls -trl /ffs/run/ | grep -w "swconfig.txt" | awk '{print $5}'
    ...    connection=asik
    Run Keyword If    '${output.split("\r\n")[0]}' != '0'    Run keyword and return status    csn.Download File
    ...    local_path=${CURDIR}/Swconfig_Directory/${SWconfig}                remote_path=/ffs/run/swconfig.txt
    ...   connection=asik
    Run keyword and return status    OperatingSystem.File Should Not Be Empty
    ...       ${CURDIR}/Swconfig_Directory/${SWconfig}
    Run Keyword And Ignore Error     OperatingSystem.Run
    ...    sed -i '/0x340000=3/d' ${CURDIR}/Swconfig_Directory/${SWconfig}
    OperatingSystem.Run    sed -i '$a\0x340000=3' ${CURDIR}/Swconfig_Directory/${SWconfig}
	Run Keyword And Ignore Error     OperatingSystem.Run
    ...    sed -i '/0x9d0000=3/d' ${CURDIR}/Swconfig_Directory/${SWconfig}
    OperatingSystem.Run    sed -i '$a\0x9d0000=3' ${CURDIR}/Swconfig_Directory/${SWconfig}
	Run Keyword And Ignore Error     OperatingSystem.Run
    ...    sed -i '/0x890073=0/d' ${CURDIR}/Swconfig_Directory/${SWconfig}
    OperatingSystem.Run    sed -i '$a\0x890073=0' ${CURDIR}/Swconfig_Directory/${SWconfig}
    [Teardown]    Run keyword and ignore error    csn.disconnect                     connection=asik


#Download luashark file
#    [Documentation]                    Download luashark file
#    OperatingSystem.Create Directory    /home/ute/luashark
#    OperatingSystem.List Files In Directory    /home/ute    *luashark*
#    OperatingSystem.Remove Files    /home/ute/*luashark.zip*
#    OperatingSystem.Remove Files    /home/ute/luashark*.zip*
#    OperatingSystem.List Files In Directory    /home/ute    *luashark*
#    ${files}    mylib772.get_file_for_Load    ${SW_Version}
#    Run Keyword Unless    'No' in '${files}'    mylib772.unzip_file    ${files}
#    OperatingSystem.Directory Should Not Be Empty      /home/ute/luashark/generated_luashark

QCT Launch NSA Call With HandOver
    [Arguments]    ${UE_id}
    [Documentation]    During the Call an HandOver IntraDU is Done

    Adjust Attenuation Value    ${5GRU1_ANT1}    value=${10}
    sleep    20s
    #mylib772.prepare_test    campaignName=${campaignId}
    #Set Suite Variable       ${hw_type}        ASIK
    #mylib772.start_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    #Start to collect wireshark log with admin
    #Start to collect wireshark log with admin f1ap
    Get system module ip from positionInSubrack
    Run Keyword If   '${hw_info_new}' == 'ASIB'     Start to collect wireshark log with admin in ASIB ASIL
    ...         ELSE     Run Keywords    Start to collect wireshark log with admin  AND  Start to collect wireshark log with admin f1ap
    Note Start Date
    Get Attach Time
    QCT Attach Ue Used In Test    ue_index=${UE_id}
    Adjust Attenuation Value    ${5GRU2_ANT1}    value=${20}
    sleep    ${CALL_DURATION}s
    Get Detach Time
    QCT Detach UE Used In Test
    Note End Date
    QCT Estimate Call Duration
    QCT Give Traces Time To Be Full
    #mylib772.stop_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    #Stop collecting wireshark log with admin
    #Stop collecting wireshark log with admin f1ap
    Run Keyword If   '${hw_info_new}' == 'ASIB'     Stop collecting wireshark log with admin
    ...         ELSE     Run Keywords  Stop collecting wireshark log with admin  AND  Stop collecting wireshark log with admin f1ap
    Adjust Attenuation Value    ${5GRU2_ANT1}    value=${10}
Get system module ip from positionInSubrack
    Connect to gnb coam via ssl
    ${fsm_info}    coam.get_fsm_info    connection=GNB_OAM
    #${hw_info}    Set Variable    ${fsm_info[0]['productName']}
    #${hw_infos}    Split String    ${hw_info}    ${SPACE}
    ${hw_info_position}    Set Variable    ${fsm_info[0]['positionInSubrack']}
    log to console    ${hw_info_position}
    Run Keyword If   '${hw_info_position}' == 'RightSide'   Set Suite Variable    ${f1ap_sship}     192.168.253.33
    ...            ELSE     Set Suite Variable    ${f1ap_sship}     192.168.253.17
    ${hw_info}    Set Variable    ${fsm_info[0]['productName']}
    ${hw_infos}    Split String    ${hw_info}    ${SPACE}
    #${hw_info_position}    Set Variable    ${fsm_info[0]['positionInSubrack']}
    #${hw_info_position_s}    Get Substring    ${hw_info_position}    0    1
    #${hw_type}    Catenate    SEPARATOR=    ${hw_infos[0]}    ${hw_info_position_s}
    ${hw_info_new}    Set Variable    ${hw_infos[0]}
    Log    ${hw_info_new}
    Set Suite Variable    ${hw_info_new}
    Run Keyword If    '${hw_info_new}'=='ASIL'    Set Suite Variable    ${hw_info_new}     ASIB
Start to collect wireshark log with admin f1ap
  Get system module ip from positionInSubrack
  wait until keyword succeeds  1min  5s  ssh.Connect to  hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
  ...  username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
  ...  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}  alias=ASIK
  wait until keyword succeeds  1min  5s  ssh.Connect To   hostname=${f1ap_sship}
  ...  username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
  ...  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}   proxy=ASIK  alias=LONER
  ssh.send_command    command=tcpdump -i any proto 0x84 -w /tmp/tcpdump-f1ap.pcap   connection=LONER
  sleep   3s
  ssh.disconnect      connection=LONER
  ssh.disconnect      connection=ASIK
  log to console    start capture f1 tcpdump
Stop collecting wireshark log with admin f1ap
  wait until keyword succeeds  1min  5s  ssh.Connect to  hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
  ...  username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
  ...  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}  alias=ASIK
   wait until keyword succeeds  1min  5s  ssh.Connect To   hostname=${f1ap_sship}
  ...  username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
  ...  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}   proxy=ASIK  alias=LONER
  ssh.send_command    command=pkill -f "tcpdump -i any"  connection=LONER
  sleep    5s
  ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
  Set Suite Variable    ${target_dir}        /home/ute/Projects/tcpdump_log
  Set Suite Variable    ${log_path_tcpdumpf1ap}    ${target_dir}/${timestamp}/tcpdump-f1ap${timestamp}.pcap
  Set Suite Variable    ${log_path_tcpdumpf1ap_pre}    ${target_dir}/${timestamp}
  Create Directory      ${log_path_tcpdumpf1ap_pre}
  ssh.download_file   /tmp/tcpdump-f1ap.pcap    ${log_path_tcpdumpf1ap}   connection=LONER
  Log to console      ssh.download_file_f1ap
  ssh.disconnect      connection=LONER
  ssh.disconnect      connection=ASIK
Start to collect wireshark log with admin
    wait until keyword succeeds  1min  5s  ssh.Connect to  hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...  username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}  alias=ASIK2
    ssh.send_command    command=tcpdump -i fp0 proto 0x84 -w /tmp/tcpdump-ngorx2.pcap   connection=ASIK2
    sleep   3s
    ssh.disconnect      connection=ASIK2
    log to console    start capture tcpdump
Start to collect wireshark log with admin in ASIB ASIL
    wait until keyword succeeds  1min  5s  ssh.Connect to  hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...  username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}  alias=ASIK2
    ssh.send_command    command=tcpdump -i any proto 0x84 -w /tmp/tcpdump-ngorx2.pcap   connection=ASIK2
    sleep   3s
    ssh.disconnect      connection=ASIK2
    log to console    start capture tcpdump
Stop collecting wireshark log with admin
  wait until keyword succeeds  1min  5s  ssh.Connect to  hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
  ...  username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
  ...  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}  alias=ASIK2
  ssh.send_command    command=pkill -f "tcpdump -i fp0"  connection=ASIK2
  sleep    5s
  ${timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
  Set Suite Variable    ${target_dir}        /home/ute/Projects/tcpdump_log
  Set Suite Variable    ${log_path_tcpdumpngx2ap}    ${target_dir}/${timestamp}/tcpdump-ngorx2${timestamp}.pcap
  Set Suite Variable    ${log_path_tcpdumpngx2ap_pre}    ${target_dir}/${timestamp}
  Create Directory      ${log_path_tcpdumpngx2ap_pre}
  ssh.download_file   /tmp/tcpdump-ngorx2.pcap    ${log_path_tcpdumpngx2ap}   connection=ASIK2
  Log to console      ssh.download_file_ngorx2
  ssh.disconnect      connection=ASIK2

Adjust Attenuation Value
    [Arguments]    ${ports}    ${value}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    att.set_attenuation     port=${ports}    value=${value}
    ${value_port1}    att.read_attenuation    port=${ports}
    should be equal    ${value_port1}    ${value}

Adjust Attenuation Value For 2396
    [Arguments]    ${ports}    ${value}   ${att_connection_port}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    att.set_attenuation     port=${ports}    value=${value}
    ${value_port1}    att.read_attenuation    port=${ports}
    should be equal    ${value_port1}    ${value}


QCT Launch SA Call With HandOver
    [Arguments]    ${UE_id}
    [Documentation]    During the Call an HandOver IntraDU is Done
    Adjust Attenuation Value    ${5GRU1_ANT1}    value=${20}
    sleep    20s
    #mylib772.prepare_test    campaignName=${campaignId}
    #Set Suite Variable       ${hw_type}        ASIK
    #mylib772.start_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    #Start to collect wireshark log with admin
    #Start to collect wireshark log with admin f1ap
    Get system module ip from positionInSubrack
    Run Keyword If   '${hw_info_new}' == 'ASIB'     Start to collect wireshark log with admin in ASIB ASIL
    ...         ELSE     Run Keywords    Start to collect wireshark log with admin  AND  Start to collect wireshark log with admin f1ap
    Note Start Date
    Get Attach Time
    QCT Attach Ue Used In Test    ue_index=${UE_id}    attach_mode=5G_SA
    Adjust Attenuation Value    ${5GRU1_ANT1}    value=${0}
    sleep    5s
    Adjust Attenuation Value    ${5GRU2_ANT1}    value=${20}
    sleep    ${CALL_DURATION}s
    Get Detach Time
    QCT Detach UE Used In Test
    Note End Date
    QCT Estimate Call Duration
    QCT Give Traces Time To Be Full
    #mylib772.stop_traces    ${GN_OAM_ADDR}    ${x2apTraces}    ${f1apTraces}    ${5GLoadVersion}    ${hw_type}
    #Stop collecting wireshark log with admin
    #Stop collecting wireshark log with admin f1ap
    Run Keyword If   '${hw_info_new}' == 'ASIB'     Stop collecting wireshark log with admin
    ...         ELSE     Run Keywords  Stop collecting wireshark log with admin  AND  Stop collecting wireshark log with admin f1ap
    Adjust Attenuation Value    ${5GRU2_ANT1}    value=${0}

Get tac value From SCF
    [Documentation]                    Get tac value From SCF
    [Arguments]                        ${cell_id}
    ${d_name}=                         Set Cell Distant Name             ${cell_id}
    ${d_name}=                         Catenate    ${d_name}/NRPLMNSET_SA-1
    ${p_name}                          set variable                      trackingAreaDN
    ${CurrentValue}                    gNB Get Attribute value in SCF    dist_name=${d_name}    p_name=${p_name}
    ${tac}    Fetch From Right    ${CurrentValue}    -
    [Return]                           ${tac}

Generic Suite Setup For Two Calls
    [Arguments]    ${CAMPAIGN_NAME}    ${CELL_NUMBER}    ${attach_mode}=5G_NSA
    Generic Test Setup    ${CAMPAIGN_NAME}    ${CELL_NUMBER}
    Log to console    QCT Launch First Call
    QCT Launch First Call    UE_id=${QCT_UE_ID_1}    campaignId=${CAMPAIGN_NAME}    attach_mode=${attach_mode}
    Log to console    Wait For Next Counter Files
    Wait For Next Counter Files
    Log to console    Check Counters Files For 1st Call
    Check Counters Files For 1st Call
    Log to console    Change The Call Number
    Change The Call Number
    Log to console    QCT Launch Second Call
    QCT Launch Second Call     UE_id=${QCT_UE_ID_1}       campaignId=${CAMPAIGN_NAME}    attach_mode=${attach_mode}
    Log to console    Wait For Next Counter Files
    Wait For Next Counter Files
    Log to console    Check Counters Files For 2nd Call
    Check Counters Files For 2nd Call
    Log to console    Get tac value From SCF
    ${tac}    Get tac value From SCF    ${CELL_NUMBER}
    Run Keyword If    '${attach_mode}' == '5G_SA'    Log to console    Copy_SM_for_different_release
    Run Keyword If    '${attach_mode}' == '5G_SA'    Copy_SM_for_different_release    ${swversion}
    ...    feature1877_772_C_SA_NG_CallEstablishmentAndRelease    ${tac}
    Log to console    QCT Launch The Use Case Detector
    QCT Launch The Use Case Detector
    Log to console    Change The Call Number
    Change The Call Number    first_call=True

Generic Suite Setup
    [Documentation]                    Set the dedicated SCF depending the Load
    [Arguments]    ${SCF}    ${SWconfig}    ${NumberOfCells}
    Log to console    gNB Get CellId and BTSId DN in SCF
    gNB Get CellId and BTSId DN in SCF
    Log to console    GNB DBF Configuration Setup
    GNB DBF Configuration Setup        ${SCF}    ${SWconfig}    ${NumberOfCells}
    #Log to console    Download luashark file
    #Download luashark file

    Download MCShark To UTE



Check Cell Availability Status is online after commissioning
    [Arguments]       ${CELL_NUMBER}
    Log to console    1Check Cell Availability Status is online
    Check Cell Availability Status is online            ${CELL_NUMBER}
    Log to console    Set Default DRX Settings From SCF
    Run keyword If  '${release_sbts}'=='SBTS23R3'
    ...  Set Default DRX Settings From SCF 23R3                ${CELL_NUMBER}
    ...  ELSE  Set Default DRX Settings From SCF
    Log to console    Get DRX State
    ${firstValue}                      Get DRX State    ${CELL_NUMBER}
    Log to console    Test starting with ${firstValue}
    Run Keyword if    '${firstValue}'=='true'           Test starting with deactivate     ${CELL_NUMBER}
    ...         ELSE                                    Test starting with activate       ${CELL_NUMBER}
    sleep                              30s
    Log to console    2Check Cell Availability Status is online
    Check Cell Availability Status is online            ${CELL_NUMBER}

Generic Suite Setup For one call
    [Arguments]       ${CAMPAIGN_NAME}    ${CELL_NUMBER}    ${attach_mode}=5G_NSA
    Generic Test Setup    ${CAMPAIGN_NAME}    ${CELL_NUMBER}
    Log to console    QCT Launch Test and Analysis
    QCT Launch Test and Analysis       UE_id=${QCT_UE_ID_1}      campaignId=${CAMPAIGN_NAME}
    ...    attach_mode=${attach_mode}
    Log to console    Wait For Next Counter Files
    Wait For Next Counter Files
    Log to console    Get tac value From SCF
    ${tac}    Get tac value From SCF    ${CELL_NUMBER}
    Run Keyword If    '${attach_mode}' == '5G_SA'    Log to console    Copy_SM_for_different_release
    Run Keyword If    '${attach_mode}' == '5G_SA'    Copy_SM_for_different_release    ${swversion}
    ...    feature1877_772_C_SA_NG_UeSupportsDRX_FeatureNotActive    ${tac}
    Log to console    QCT Launch The Use Case Detector
    QCT Launch The Use Case Detector

Generic Suite Setup For one call during Activating DRX
    [Arguments]       ${CAMPAIGN_NAME}    ${CELL_NUMBER}    ${attach_mode}=5G_NSA
    Generic Test Setup    ${CAMPAIGN_NAME}    ${CELL_NUMBER}
    Log to console    QCT Launch Test and Analysis
    QCT Launch Test and Analysis    UE_id=${QCT_UE_ID_1}    campaignId=${CAMPAIGN_NAME}    attach_mode=${attach_mode}
    Log to console    Wait For Next Counter Files
    Wait For Next Counter Files
    Log to console    Get and Check Counters Files
    Get and Check Counters Files
    Log to console    Get tac value From SCF
    ${tac}     Run Keyword If    '${attach_mode}' == '5G_SA'    Get tac value From SCF    ${CELL_NUMBER}
    Run Keyword If    '${attach_mode}' == '5G_SA'    Log to console    Copy_SM_for_different_release
    Run Keyword If    '${attach_mode}' == '5G_SA'    Copy_SM_for_different_release    ${swversion}
    ...    feature1877_772_C_SA_NG_CallEstablishmentAndRelease    ${tac}
    Log to console    QCT Launch The Use Case Detector
    QCT Launch The Use Case Detector

Generic Suite Setup For MultiUe
    [Arguments]       ${CAMPAIGN_NAME}    ${CELL_NUMBER}    ${attach_mode}=5G_NSA
    Generic Test Setup    ${CAMPAIGN_NAME}    ${CELL_NUMBER}
    Log to console    QCT Launch Call On UEs
    QCT Launch Call On UEs    UE_id1=${QCT_UE_ID_1}      UE_id2=${QCT_UE_ID_1}      campaignId=${CAMPAIGN_NAME}
    ...     attach_mode=${attach_mode}
    Log to console    Wait For Next Counter Files
    Wait For Next Counter Files
    Log to console    Get tac value From SCF
    ${tac}    Get tac value From SCF    ${CELL_NUMBER}
    Run Keyword If    '${attach_mode}' == '5G_SA'    Log to console    Copy_SM_for_different_release
    Run Keyword If    '${attach_mode}' == '5G_SA'    Copy_SM_for_different_release    ${swversion}
    ...    feature1877_772_C_SA_NG_CallEstablishmentAndRelease    ${tac}
    Log to console    QCT Launch The Use Case Detector
    QCT Launch The Use Case Detector

Generic Suite Setup For HO
    [Arguments]       ${CAMPAIGN_NAME}    ${CELL_NUMBER}    ${attach_mode}=5G_NSA
    Generic Test Setup    ${CAMPAIGN_NAME}    ${CELL_NUMBER}
    Log to console    QCT Launch With HandOver
    QCT Launch With HandOver    ${QCT_UE_ID_1}    ${CAMPAIGN_NAME}    ${attach_mode}
    Log to console    Wait For Next Counter Files
    Wait For Next Counter Files
#    Log to console    Get tac value From SCF
#    ${tac}    Get tac value From SCF    ${CELL_NUMBER}
#    Run Keyword If    '${attach_mode}' == '5G_SA'    Log to console    Copy_SM_for_different_release
#    Run Keyword If    '${attach_mode}' == '5G_SA'    Copy_SM_for_different_release    ${swversion}
#    ...    feature1877_772_C_SA_NG_CallEstablishmentAndRelease    ${tac}
#    Log to console    QCT Launch The Use Case Detector
#    QCT Launch The Use Case Detector
    Log to console     Check Counters Files HO IntraDU
    Check Counters Files HO IntraDU

QCT Launch With HandOver
    [Arguments]    ${QCT_UE_ID_1}    ${CAMPAIGN_NAME}    ${attach_mode}
    Run Keyword If    '${attach_mode}'=='5G_NSA'    QCT Launch NSA Call With HandOver    ${QCT_UE_ID_1}
    ...    ${CAMPAIGN_NAME}
    Run Keyword If    '${attach_mode}'=='5G_SA'    QCT Launch SA Call With HandOver    ${QCT_UE_ID_1}
    ...    ${CAMPAIGN_NAME}

Test Teardown
    [Arguments]    ${result}
    Log                                Test Result is : ${result}
    Should Contain                      ${result}    OK
	Run Keywords    Connect to gnb coam via ssl   AND    Run Keyword If Test Failed
    ...    COAM Save snapshot via rest api   AND    robot_common_operations.Common Case Teardown

case12_NSACallRelease_UeSupportsDRX
    Log to console    Note After End Date
    Note After End Date
    Log to console    Get and Check Counters Files After End call
    Get and Check Counters Files After End call
    Log to console    checkFeature_772_NSA_Counters for case12
    ${result}=                         mylib772.checkFeature_772_NSA_Counters    ${checkCounter}    12
    [Return]    ${result}


Set two parameters for case
    [Arguments]    ${sm_to_be_run}    @{SM_TO_BE_RUN_20A}
    @{SM_TO_BE_RUN}    Create List    ${sm_to_be_run}
    Set Suite Variable    @{SM_TO_BE_RUN}
    Set Suite Variable    @{SM_TO_BE_RUN_20A}

Set four parameters for case
    [Arguments]    ${sm_to_be_run_x2_1}    ${sm_to_be_run_x2_2}    ${sm_to_be_run_f1_1}
    ...    ${sm_to_be_run_f1_2}
    @{SM_TO_BE_RUN}    Create List    ${sm_to_be_run_x2_1}    ${sm_to_be_run_x2_2}
    @{SM_TO_BE_RUN_20A}    Create List    ${sm_to_be_run_f1_1}    ${sm_to_be_run_f1_2}
    Set Suite Variable    @{SM_TO_BE_RUN_20A}
    Set Suite Variable    @{SM_TO_BE_RUN}

Set three parameters for case
    [Arguments]    ${sm_to_be_run_x2_1}    ${sm_to_be_run_x2_2}    ${sm_to_be_run_f1_1}
    @{SM_TO_BE_RUN}    Create List    ${sm_to_be_run_x2_1}    ${sm_to_be_run_x2_2}
    @{SM_TO_BE_RUN_20A}    Create List    ${sm_to_be_run_f1_1}
    Set Suite Variable    @{SM_TO_BE_RUN_20A}
    Set Suite Variable    @{SM_TO_BE_RUN}

Set five parameters for case
    [Arguments]    ${sm_to_be_run_x2_1}    ${sm_to_be_run_x2_2}    ${sm_to_be_run_x2_3}
    ...    ${sm_to_be_run_f1_1}    ${sm_to_be_run_f1_2}
    @{SM_TO_BE_RUN}    Create List    ${sm_to_be_run_x2_1}    ${sm_to_be_run_x2_2}  ${sm_to_be_run_x2_3}
    @{SM_TO_BE_RUN_20A}    Create List    ${sm_to_be_run_f1_1}    ${sm_to_be_run_f1_2}
    Set Suite Variable    @{SM_TO_BE_RUN_20A}
    Set Suite Variable    @{SM_TO_BE_RUN}

Generic Test Setup
    [Arguments]       ${CAMPAIGN_NAME}    ${CELL_NUMBER}
    Log to console    gNB Get CellId and BTSId DN in SCF
    gNB Get CellId and BTSId DN in SCF
    Log to console    Campaign Test Setup
    Campaign Test Setup                ${CAMPAIGN_NAME}    ${X2traces}     ${F1traces}
    Log to console    Set Default DRX Settings From SCF
    Run keyword If  '${release_sbts}'=='SBTS23R3'
    ...  Set Default DRX Settings From SCF 23R3                ${CELL_NUMBER}
    ...  ELSE  Set Default DRX Settings From SCF
    Log to console    Display New Default DRX Settings
    Display New Default DRX Settings
    Log to console    Activate DRX
    Activate DRX                       ${CELL_NUMBER}
    Log to console    Activate DRX For HO CELL
    Run Keyword and Ignore Error    Activate DRX    ${CELL_FOR_HO}
    Log to console    Deactivate SRB3
    Deactivate SRB3
    Log to console    Require UE
    power_ue.Prepare UE    ue_type=${ue_type}
    Log to console    QCT Detach UE Used In Test
    Run Keyword and Ignore Error    QCT Detach UE Used In Test
    # Andriod UE adb reboot
