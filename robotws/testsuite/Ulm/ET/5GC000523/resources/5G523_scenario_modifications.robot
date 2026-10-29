*** Settings ***
Documentation    Scenario specific keywords for Feature <ID>
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource   ../../../resources/Common/testline.robot
Resource   ../../../resources/Common/gnb.robot
Resource   ../../../resources/Common/commissioning.robot
Library    taf.config.scf                                  WITH NAME   scf
Library    ../../L2/libraries/ScfChanges.py                WITH NAME   scf_changes


*** Keywords ***

#-----------For Test Execution -----------------#
Run Scenario specific Keywords before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    Run Keyword And Continue On Failure    Run Keywords    @{scenario_specific_keywords}
    Log    The following Keywords were Run: ${scenario_specific_keywords}


Run Feature specific keywords before attach
    RETURN


Run Feature specific keywords after attach before traffic is started
    RETURN


Run Feature specific keywords during traffic before detach
    [Arguments]  ${traffic_duration}
    sleep  ${traffic_duration}


Run Feature specific keywords after traffic before detach
    RETURN


Run Feature specific keywords after detach
    sleep  30s


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


#-----------For Suite Setup -----------------#

Make necessary changes to SCF
    ${scf_path}=  Get SCF from gNB
    ${scf_conent}=  OperatingSystem.Get File    ${scf_path}
    scf_changes.Load Scf    ${scf_conent}
        Set SW POSTFIX Variable
        Enable Short PUCCH
        Change reporting interval
        # Force Traffic over NR
        Disable Proactive UL Scheduling
        IF    '${SW_POSTFIX}'=='MMWV_SA'    Workaround for CB008285
        ${configuration_directory}=  testline.Get Test Suite Config Directory
    ${commisioning_data}=  scf_changes.Get Modifications For Commissioning
    commissioning.Commission Managed Object List  managed_objects=${commisioning_data}  gnb_id=${0}  skip_parameter_relation_errors=${False}


Update Basic Configuration File
    RETURN


#--------------For SCF Changes----------------------#

Set SW POSTFIX Variable
    ${ue_type}=    set variable if    'WV SA' in '${SUITE_NAME}'    SA    NSA
    ${SW_POSTFIX}=    set variable    ${SW_WAVELENGTH}_${ue_type}
    set suite variable    ${SW_POSTFIX}


Change reporting interval
    [Arguments]    ${interval_duration}=5min
    # ${distName_NRPMRNL}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRPMRNL-[1-9]+
    FOR    ${p_name}    IN
    ...    miNrCellAvailability
    ...    miNrCellUtilization
    ...    miNrTimingAdvance
    ...    miNrUlSignalQuality
    ...    miNrUlHarq
            scf_changes.Add Robot Change    regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRPMRNL-[1-9]+    p_name=${p_name}    value=${interval_duration}
    END
    # ${distName_PMCADM}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=MNL-[1-9]+/MNLENT-[1-9]+/PMCADM-[1-9]+
   scf_changes.Add Robot Change    value=${interval_duration}  regex=MRBTS-[1-9]+/MNL-[1-9]+/MNLENT-[1-9]+/PMCADM-[1-9]+  p_name=reportingIntervalPm


Enable Short PUCCH
    scf_changes.Add Robot Change    value=shortPucch  regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRCELL-[1-2]+  p_name=pucchModeSelect


Force Traffic over NR
    ${bts_distNames}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=MRBTS-[1-9]+/NRBTS-[1-9]+
    ${dlDataSplitMode}=    scf.Get all values from scf    p_name=dlDataSplitMode
    ${no_modes}    Get length    ${dlDataSplitMode}
    FOR    ${id}    IN RANGE    1    ${no_modes}+1
       scf_changes.Add Robot Change  value=dlOverF1U  regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRDRB-[1-9]+
       ...  p_name=dlDataSplitMode  list_name=nsaDrbParam
       scf_changes.Add Robot Change  value=true  regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRDRB-[1-9]+
       ...  p_name=actPrioritizeX2AfterInactivity  list_name=nsaDrbParam
       scf_changes.Add Robot Change  value=false  regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRDRB-[1-9]+
       ...  p_name=actX2DuplicateTxNSA3x  list_name=nsaDrbParam
       scf_changes.Add Robot Change  value=5  regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRDRB-[1-9]+
       ...  p_name=dlDataSplitBufferBuildUpThreshold  list_name=nsaDrbParam
       scf_changes.Add Robot Change  value=5  regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRDRB-[1-9]+
       ...  p_name=dlDataSplitBufferBuildUpThresholdPrioritizeX2  list_name=nsaDrbParam
       scf_changes.Add Robot Change  value=5  regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRDRB-[1-9]+
       ...  p_name=dlDataSplitGainThreshold  list_name=nsaDrbParam
       scf_changes.Add Robot Change  value=dlOverF1U  regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRDRB-[1-9]+
       ...  p_name=dlDataSplitMode  list_name=nsaDrbParam
       scf_changes.Add Robot Change  value=ulOverNr   regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRDRB-[1-9]+
       ...  p_name=ulDataPath       list_name=nsaDrbParam
    END


Disable Proactive UL Scheduling
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRCELL-[1-9]+
    sort list  ${distName_NRCELL}
    ${element_exists}=   scf.is element in object    dist_name=${distName_NRCELL[0]}    p_name=actProactUlScheduling
    IF   ${element_exists}
        scf_changes.Add Robot Change   regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRCELL-[1-9]+   p_name=actProactUlScheduling   value=false
    END
    scf_changes.Add Robot Change    regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRCELL-[1-9]+    p_name=actDl256Qam            value=false
    scf_changes.Add Robot Change    regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRCELL-[1-9]+    p_name=actUl256Qam            value=false


Workaround for CB008285
    [Documentation]  WA for "T300 expiration"
    scf_changes.Add Robot Change    regex=MRBTS-[1-9]+/NRBTS-[1-9]+/NRCELL-[1-9]+    p_name=actRrcReconfigAtBeamSwitch    value=true


Update SCF Parameters and commission gNB
    [Arguments]  ${param_list}  ${delta_scf_filename}=SCF_updated_delta.xml
    ${scf_path}=  Get SCF from gNB
    ${configuration_directory}=  Get Test Suite Config Directory
    ${path_delta_scf}=  Generate Delta Commissioning File   scf_path=${scf_path}  parameters_list=${param_list}
    ...  target_local_path=${configuration_directory}/${delta_scf_filename}
    Execute delta commissioning  delta_scf_template=${path_delta_scf}   resultDir=${OUTPUT_DIR}
