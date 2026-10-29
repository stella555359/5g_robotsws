*** Settings ***
Documentation     [PURPOSE] keywords used for CB012535 feature
...
...               Automation author           : francois.tourlonnias@nokia.com


Library           ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME   sweng_coam_parameter
Library           taf.sbts.oam.coam.admin                                     WITH NAME   taf_sbts_coam
## Library           luashark_tools.analyzer       WITH NAME   analyzer
Library           Collections
Library           OperatingSystem
library           ../python/kwmkt_csvParser.py
library           ../python/miscellaneous.py
Library           ../python/CB012535_checkTTItrace.py

Resource          ../../../resources/robot/KeyWordMarket.robot
Resource          ../../../../../resources/SWENG/robot/CallSetup.robot

*** Variables ***
${CommissionToDo}                     ${True}
${BtsLogStarted}                      ${False}
# ${RRCScriptspath}                     ${CURDIR}/../resources/python
${RRCScriptsname}                     verify_reconfig.py
${VMmonitoring}                       ${False}  #will create a MONITORING directory, collect Top info each 20s and do a preprocessing of data

#FTS------------------------------------------------------------------------
# ${matrix}

${ISO}                                 False
${BeamFormingSet}                      False
${PowerCtrlSet}                        False
${gnb_alias}                           gnb_under_test

${TestsJsonPath}                       testsuite/Paris/RRM/ET/CB012535/resources/config/scf

${MPAPLOisoLOAPLO_WITH_BF}             ${TestsJsonPath}/scf_MPAPLOisoLOAPLO_WITH_BF_Cell1_Cell2_fresh.json
${MPAPLOisoLOAPLO_WO_BF}               ${TestsJsonPath}/scf_MPAPLOisoLOAPLO_WITHOUT_BF_Cell1_Cell2_fresh.json
${delta_file_iso_ULCL_powerCtrl}       ${TestsJsonPath}/scf_ULCL_powerCtrl_Cell1_Cell2_fresh.json

${delta_file_iso_SetBeamForming}       ${TestsJsonPath}/scf_setBF_Cell1_Cell2.json
${delta_file_iso_UnSetBeamForming}     ${TestsJsonPath}/scf_unsetBF_Cell1_Cell2.json
${UnSetBForming_nochannelpresent}     ${TestsJsonPath}/scf_unsetBF_Cell1_Cell2_light.json
${delta_file_iso_UnSetBF_C1C2_cha}     ${TestsJsonPath}/scf_unsetBF_channel_Cell1_Cell2.json
${delta_file_iso_SetUlDftsOfdm}        ${TestsJsonPath}/scf_UlDftsOfdm_activ_Cell1_Cell2.json

@{ManagedObjectList}                       #check of oject is only done on cell-1 as Cell-2 is always on same state
...    MRBTS-1/NRBTS-1/NRULCLPC_PROFILE-0
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8

${scf_type}                           Vdu
#FTS------------------------------------------------------------------------

*** Keywords ***
#FTS------------------------------------------------------------------------

# RadParam block ------------------------------------------------------------------------------------------------------
Set_RadParameters
    [Documentation]      Add or Modify the RAD params

    Dated Log New Line   Add RAD params for CB012535

    @{listraddic}=                                   Create list

    FOR     ${idx}     IN                            @{radList}

                Run Keyword If                       '${idx.value}' != '${EMPTY}'
                ...                                  Run keywords      dated log    -----> ${idx.field}=${idx.value}
                ...  AND                             Append To List    ${listraddic}    ${idx}
    END

    Dated Log                                        rad_param_dic= ${listraddic}
    SetConfig.Set Fields in swconfig DU              param_list=${listraddic}

# END RadParam block --------------------------------------------------------------------------------------------------
# basic block ---------------------------------------------------------------------------------------------------------
Set_basic_context
    [Documentation]    Adds basic.cfg elements for CB012535.
    ...                Adapts basic.cfg for each engaged UE.
    ...                Sets UE on a specific cell if a target cell is defined.
    ...                Sets UE context if UE NR capabilities are defined.

    Dated Log New Line   Add basic.cfg elements for CB012535

    FOR     ${idx}     IN                            @{param.ListOfUeEngaged}
            kwmkt_dbg_log                            basic.cfg adaptation for UE=${idx.ueid}

            Run Keyword If                          '${idx.Target_cell}'!='${EMPTY}'    kwmkt_SetUExonCelly    ${idx.ueid}    ${idx.Target_cell}
            Run Keyword If                          '${idx.ue_nr_capabilities}'!='${EMPTY}'
            ...                                      kwmkt_Set_Context_basic
            ...                                      ue_id_used=${idx.ueid}
            ...                                      capa=${idx.ue_nr_capabilities}
            ...                                      release=${idx.ue_release}
            ...                                      APPdcpPacketTrunc=${True}
    END

#RDH-ticket72: Update UE Id VRAN Case

# END basic block -----------------------------------------------------------------------------------------------------
# SCF NIDD block  -----------------------------------------------------------------------------------------------------

Set_SCF_ConfigMarket
    [Documentation]    Sets up the test configuration based on the SCF component.
    ...                Performs the commissioning step, combining JSON files if necessary.
    ...                Waits for OAM to be available after commissioning.

    [Arguments]                                    ${scfcompo}
    Dated Log New Line                             KW:Set_SCF_ConfigMarket ${scfcompo.jsonFile}


    # First : Get the SCF
    ${scf_file}        run keyword if      "${scf_type}" == "Vdu"
    ...                                                  OAM Get SCF File
    ...                                                  dir=${LOG_PATH}
    ...                                                  file=SCF_VDU.xml
    ...                                                  oam=${GNB_DU.oam}
    ...                                               ELSE
    ...                                                  OAM Get SCF File
    ...                                                  dir=${LOG_PATH}
    ...                                                  file=SCF_VCU.xml
    ...                                                  oam=${GNB_CU.oam}

    Dated log                                            Scf backup before test is ${scf_file}
    Dated log                                            Json file used will be ${scfcompo}
    taf_sbts_coam.connect_to                             name=${gnb_alias}
    sweng_coam_parameter.perform_scf_delta_commission    timeout=300
    ...                                                  delta_file=${scfcompo.jsonFile}
    ...                                                  connection=${gnb_alias}
    ...                                                  skip_parameter_relation_errors=${True}

Set_SCF_ofTheTest
    [Documentation]    Sets ChBw and eventual NIDD param on the fly.
    ...                Retrieves the SCF file and starts a session.
    ...                Iterates over a list of parameters to modify in the SCF.
    ...                Modifies the SCF either by setting an element or setting an element in a list.
    ...                Logs the modifications made to the SCF.
    ...                Stops the SCF session and performs a full commissioning.
    ...                Waits for OAM to be available after commissioning.
    [Arguments]                        ${L}=None
    kwmkt_dbg_log                      KW: Set_SCF_ofTheTest Arg: ${L}

    OAM Get SCF File                   file=SCF_intermediate_12535.xml
    ${scf_file_update_path}            set variable             ${LOG_PATH}/SCF_intermediate_12535.xml

    SCF StartSession              scf_file=${scf_file_update_path}

    # # ${modify_param}                 Set Parameters on SCF_COAM_TDD
    # # ...                             dir=${param.dir}
    # ${dist_name}=                      set variable     MRBTS-1/NRBTS-1/NRCELL-1     # 12535 => only first TDD as Cell1
    # ${sorted} =	                       Get Dictionary Keys    ${dic}
    kwmkt_dbg_log                      Scf Dic key list:${L}

    FOR    ${Lidx}     IN               @{L}

           ${dist_name}=                                               Get From Dictionary         ${Lidx}    dist_name
           ${status}  ${response}=     Run Keyword And Ignore Error    Get From Dictionary         ${Lidx}    list_name
        #    kwmkt_dbg_log               status / response : ${status} / ${response}
           ${list_name}=               Set Variable IF    "${status}" != "PASS"    ${EMPTY}        ${response}
           ${param}=                                                   Get From Dictionary         ${Lidx}    param
           ${value}=                                                   Get From Dictionary         ${Lidx}    value
           Run Keyword If              '${value}' != '${EMPTY}' and '${list_name}' == '${EMPTY}'
           ...                                      SCF Set element    dist_name=${dist_name}
           ...                                                         element_name=${param}
           ...                                                         element_value=${value}
           ...                                                         aicListEntity=vdu   scope=Both
           ...    ELSE                              SCF Set element in List
           ...                                                         dist_name=${dist_name}
           ...                                                         list_name=${list_name}
           ...                                                         element_name=${param}
           ...                                                         element_value=${value}
           ...                                                         aicListEntity=vdu   scope=Both

           ${console_msg}              Evaluate     "Database Modifications for ${dist_name} ..... ${list_name} ..... ${param} ..... value=${value}"
           Dated Log                   ${console_msg}
    END

    SCF StopSession               scf_file=${scf_file_update_path}

    Dated Log    =======> Be Patient the oam is may be not yet able to perform a second commissioning
    wait until keyword succeeds    10min    30s      OAM Perform Full Commissioning  scf_file=${scf_file_update_path}
    Dated Log    =======> second Commissioning done


    # Restart TL
    Dated Log New Line  "OAM wait available ..."
    OAM wait available
    Dated Log  "OAM wait available => OK"

# END SCF NIDD block  -------------------------------------------------------------------------------------------------

CB012535_Test_Teardown
    kwmkt_Test Teardown
    kwmkt_wtssim_UNsetup_egate

Suite Setup 12535
    [Documentation]    Sets up the test suite for CB012535.
    ...                Performs a suite setup with automatic teardown and keeps all UE data in the cfg file.
    ...                Backs up files before the test.
    ...                Initializes variables for the market.
    ...                Initializes the capture session.

    Read And Print Version    # Read and print the version of this 12535 framework level
    # Setup.Suite Setup From Scratch      automaticTeardown=${True}    keepAllUeDataInCfgFile=${True}    #diff between lines are kill egate eadeamon
    Setup.Suite Setup      automaticTeardown=${True}    keepAllUeDataInCfgFile=${True}
    Backup Files
    kwmkt_Init Variables
    kwmkt_Capt_session_init
    kwmkt_Init_Trace_color
    kwmkt_wtssim_setup_egate

Suite Teardown 12535
    [Documentation]    Performs teardown operations for the test suite CB012535.
    ...                Logs the start of the teardown process.
    ...                If KeepConfig is not set, restores files and performs the suite teardown.

    Run Keyword if                     not ${KeepConfig}    Run Keywords
    ...                                                     Dated Log New Line                 Suite Teardown 12535 is ongoing !!
    ...    AND                                              Restore Files
    ...    AND                                              Setup.Suite Teardown

# Test running
Cell_setup
    [Documentation]    Sets up the cell for the test.
    ...                Starts Btslog if userneed_Btslog is set.
    ...                Logs the alarm list at the beginning of the test.
    ...                Starts a capture if userneed_PCAP is set.
    ...                Sets up the call with Wtsemu in SA mode.
    ...                Stops the capture if userneed_PCAP is set.

    Run Keyword If      ${userneed_Btslog}           Start Btslog
    kwmkt_Alarmslist     Beg                          ${logsDir}
    Run Keyword If      ${userneed_PCAP}             kwmkt_Capture_Start    cellSetup

    Critical Step                                    CallSetup.Setup Wtsemu SA

    Run Keyword If      ${userneed_PCAP}             kwmkt_Capture_Stop     cellSetup

#---------------------------------------------------------------------------

# C H E C K  C O R N E R
pcap2csv
    [Documentation]    Checks a Bip Pcap file.
    ...                Step1: Executes Tshark command with a list of filters.
    ...                Step2: Parses the pcap using Tshark, returning a dictionary of results.

    [Arguments]     ${PcapType}=none    ${PcapLocation}=${CaptureBIP.path}    ${ParamItemValue_list}=${param.dod}
    kwmkt_dbg_log   Check_in_pcap args
    kwmkt_dbg_log   PcapType:${PcapType}
    kwmkt_dbg_log   PcapLocation:${PcapLocation}
    kwmkt_dbg_log   ParamItemValue_list: ${ParamItemValue_list}

    # STEP 1:   tshark filter and IE list constitution
    Dated Log New Line              Extract messages info from PCAP file here : ${PcapLocation}

    set test variable               ${pcapprocessed}           ${PcapType}_pcapprocessed.csv
    set test variable               ${pcapprocessed_path}      ${LOG_PATH}/${pcapprocessed}

    ${grep}=                        Set Variable    ${empty}
    ${filters}=                     Set Variable    ${empty}

    @{DoublonList}=                 Create List

    FOR     ${dic}     IN           @{ParamItemValue_list}
                                    ${ie}               Get From Dictionary     ${dic}     field
                                    ${msg}              Get From Dictionary     ${dic}     msg

                                    ${pres}             kwmkt_is_value_in_list    ${msg}     ${filters}

                                    ${filters}          Run Keyword If         '${filters}' == '${empty}'
                                    ...                                         Catenate    ${msg}  #cas vide
                                    ...                 ELSE                    kwmkt_Intermed    ${filters}    ${pres}    ${msg}

                                    # Dated Log           F I L T E R : ${filters}

                                    # ${result}           Evaluate               '${ie}' in @{DoublonList}
                                    ${result} =         Run Keyword And Return Status    Should Contain    ${DoublonList}    ${ie}
                                    Run Keyword If      ${result} == ${True}    Continue For Loop
                                    ${grep}             Catenate                ${grep} -e ${ie}
                                    Append To List                              ${DoublonList}    ${ie}
                                    kwmkt_dbg_log                               grep ${grep} DoublonList ${DoublonList}

    END

    kwmkt_dbg_log                   ensemble des grep: ${grep}
    kwmkt_dbg_log                   ensemble des filters: ${filters}

    #STEP 2
    ${cmd_mcshark}                  Catenate    tshark -r
    ...                             ${PcapLocation} -T fields -Y " ${filters} "
    ...                             -e 3gpp.sfn
    ...                             -e 3gpp.slot
    ...                             -e 3gpp.subcellid
    ...                             -e 3gpp.rnti
    ...                             ${grep}
    ...                             -E header=y -E separator=';' > ${pcapprocessed_path}
    Dated Log                       cmd_mcshark >${cmd_mcshark}<
    Run                             ${cmd_mcshark}
    Run                             command=sed -i -e 's/ //g' ${pcapprocessed_path}

Check_in_pcap
    [Documentation]    Checks a Bip Pcap file.
    ...                Compares results with expected values.
    ...                Returns a list of dictionaries with the checkup results.

    [Arguments]     ${PcapType}=none    ${PcapLocation}=${CaptureBIP.path}    ${ParamItemValue_list}=${param.dod}    ${SbcId}=0    ${elemRank}=0
    kwmkt_dbg_log   Check_in_pcap args
    kwmkt_dbg_log   PcapType:${PcapType}
    kwmkt_dbg_log   PcapLocation:${PcapLocation}
    kwmkt_dbg_log   ParamItemValue_list: ${ParamItemValue_list}
    kwmkt_dbg_log   SbcId: ${SbcId}
    kwmkt_dbg_log   elemRank: ${elemRank}
    #DOD
    #resultat obtenu MULTI CELL !!
    # UlData_puschReceiveReqGrant_t.numOfLayers                >{'non_empty_lines_count': 980, 'occurrences': {'2': 980}}<
    # UlData_puschReceiveReqGrant_t.mcs                        >{'non_empty_lines_count': 980, 'occurrences': {'27': 980}}<
    # UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag >{'non_empty_lines_count': 980, 'occurrences': {'0': 980}}<
    # UlData_pucchReceiveReqPucchResource_t.modulationType     >{'non_empty_lines_count': 121, 'occurrences': {'1': 29, '0': 90, '0,0': 2}}<
    # UlData_puschReceiveReqGrant_t.dmrsSequenceType           >{'non_empty_lines_count': 980, 'occurrences': {'0': 980}}<
    # UlData_puschReceiveReqGrant_t.ulDmrsAddPos               >{'non_empty_lines_count': 980, 'occurrences': {'1': 980}}<
    # UlData_pucchReceiveReqPucchResource_t.additionalDmrs     >{'non_empty_lines_count': 121, 'occurrences': {'0': 119, '0,0': 2}}<
    # dci.dci01.TPCforScheduledPUSCH                           >{'non_empty_lines_count': 0,   'occurrences': {}}<
    # UlData_pucchReceiveReqPucchResource_t.pucchFormat        >{'non_empty_lines_count': 121, 'occurrences': {'1': 111, '3': 8, '1,1': 2}}<

    # STEP 3
    Dated Log New Line    ======= SbcId: ${SbcId} =====================================================================
    @{dodreslist}=        Create List

    # kwmkt_dbg_log          ParamItemValue_list =>${ParamItemValue_list}<=
    # 18:46:31 	[16:46:31] Debug wwwwwwwwww: ParamItemValue_list:
    # [{'PcapType': 'L1L2', 'subcell_id': '0', 'msg': 'uldata_puschreceivereq', 'field': 'UlData_puschReceiveReqGrant_t.modulationOrder',
    #   'value': 'na', 'dodtype': 'sum_2FirstValues', 'PercentTol': '20'},
    #  {'PcapType': 'L1L2', 'subcell_id': '0', 'msg': 'uldata_puschreceivereq', 'field': 'UlData_puschReceiveReqGrant_t.mcs',
    #    'value': 'na', 'dodtype': 'Extract_FirstValue', 'PercentTol': '20'}]

    FOR    ${dic}    IN    @{ParamItemValue_list}
                           kwmkt_dbg_log       dic: ${dic}
                           ${subcell_id}       Get From Dictionary      ${dic}     subcell_id
                           ${ie}               Get From Dictionary      ${dic}     field
                           ${val}              Get From Dictionary      ${dic}     value
                           ${whichKWtoPlay}    Get From Dictionary      ${dic}     dodtype
                           ${Tol}              Get From Dictionary      ${dic}     PercentTol

                           Continue For Loop If      "${subcell_id}" != "${SbcId}"      #focus only on ${SbcId}

                           ${dic_res}=         read_csv_and_count_occurrences
                           ...                 ${pcapprocessed_path}    ${ie}      3gpp.subcellid    ${subcell_id}

                        #    kwmkt_dbg_log       dic_res >${dic_res}<
                           ${Datatomanage}     Get From Dictionary      ${dic_res}    non_empty_lines_count
                        #    kwmkt_dbg_log       Datatomanage ${Datatomanage}
                           Run Keyword If      "${Datatomanage}" == "0"    Run Keywords
                           ...                                             Dated Log    A L A R M no data to manage for ${dic}
                           ...                 AND                         Continue For Loop    #we jump to the nex iterration

                           ${occ}              Get From Dictionary      ${dic_res}    occurrences   #	${occ} = {'2': 1977}

                           kwmkt_dbg_log       >>> ${whichKWtoPlay} ${occ} ${val} ${SbcId} ${Tol} <<<

                           ${res}=    Run Keyword If    '${whichKWtoPlay}' == 'sum_2FirstValues'
                           ...                           ${whichKWtoPlay}      ${occ}
                           ...        ELSE IF           '${whichKWtoPlay}' == 'Extract_FirstValue'
                           ...                           ${whichKWtoPlay}      ${occ}
                           ...        ELSE IF           '${whichKWtoPlay}' == 'ExactValueForall'
                           ...                           ${whichKWtoPlay}      ${occ}    ${val}    ${SbcId}    ${Tol}
                           ...        ELSE IF           '${whichKWToPlay}' not in ['sum_2FirstValues', 'Extract_FirstValue', 'ExactValueForAll']
                           ...                           ${whichKWtoPlay}      ${occ}    ${val}    ${SbcId}    ${elemRank}


                        #    ${res1}=    Run Keyword If    '${whichKWtoPlay}' == 'sum_2FirstValues'
                        #    ...                            ${whichKWtoPlay}      ${occ}
                        #    ${res2}=    Run Keyword If    '${whichKWtoPlay}' == 'Extract_FirstValue'
                        #    ...                            ${whichKWtoPlay}      ${occ}
                        #    ${res3}=    Run Keyword If    '${whichKWtoPlay}' == 'ExactValueForall'
                        #    ...                            ${whichKWtoPlay}      ${occ}    ${val}    ${SbcId}    ${Tol}
                        #    ${res4}=    Run Keyword If    '${whichKWToPlay}' not in ['sum_2FirstValues', 'Extract_FirstValue', 'ExactValueForAll']
                        #    ...                            ${whichKWtoPlay}      ${occ}    ${val}    ${SbcId}    ${elemRank}

                        #    ${res}=     Run Keyword If    '${whichKWtoPlay}' == 'sum_2FirstValues'    Set Variable    ${res1}
                        #    ...         ELSE IF           '${whichKWtoPlay}' == 'Extract_FirstValue'  Set Variable    ${res2}
                        #    ...         ELSE IF           '${whichKWtoPlay}' == 'ExactValueForall'    Set Variable    ${res3}
                        #    ...         ELSE IF           '${whichKWToPlay}' not in ['sum_2FirstValues', 'Extract_FirstValue', 'ExactValueForAll']
                        #    ...                            ${whichKWtoPlay}                           Set Variable    ${res4}


                           Dated Log    res: ${res}


                           ${msg1}=    catenate     Check result for ${ie} Meth ${whichKWtoPlay} : ${val} => SbcId ${SbcId}
                           ...                      range:${elemRank} => ${occ} *** res ${res}
                           ${msg2}=    catenate     Check result for ${ie} Meth ${whichKWtoPlay} : ${val} => SbcId ${SbcId}
                           ...                      range:${elemRank} *** res ${res}

                           Run Keyword If     "${whichKWtoPlay}" != "DisplayAverage"    Dated Log    ${msg1}    ${msg2}

                           kwmkt_dbg_log       dodreslist before :${dodreslist}
                           Append To List      ${dodreslist}    ${res}
                           kwmkt_dbg_log       dodreslist after :${dodreslist}

    END
    [Return]    ${dodreslist}

extract_FirstValue
    [Arguments]    ${dic_occ}
    kwmkt_dbg_log             extract_FirstValue ARGS: dic_occ ${dic_occ}
    # here ${dic_occ} look like    {'1': 29, '0': 90, '0,0': 2}}  or  {'2': 1977}
    ${keys}=                  Get Dictionary Keys    ${dic_occ}          # here ${keys} contain  1,0, 0,0  or only 2

    ${first_key}=             Get From List    ${keys}    0
    ${first_value}=           Get From Dictionary    ${dic_occ}    ${first_key}
    kwmkt_dbg_log             first_key ${first_value}

    [Return]    ${first_value}

sum_2FirstValues
    [Arguments]    ${dic_occ}
    kwmkt_dbg_log             sum_2FirstValues ARGS: dic_occ ${dic_occ}
    # here ${dic_occ} look like    {'1': 29, '0': 90, '0,0': 2}}  or  {'2': 1977}
    ${keys}=                  Get Dictionary Keys    ${dic_occ}          # here ${keys} contain  1,0, 0,0  or only 2

    ${first_key}=             Get From List    ${keys}    0
    ${second_key}=            Get From List    ${keys}    1
    ${first_value}=           Get From Dictionary    ${dic_occ}    ${first_key}
    ${second_value}=          Get From Dictionary    ${dic_occ}    ${second_key}
    ${sum}=                   Evaluate    ${first_value} + ${second_value}
    kwmkt_dbg_log             first_key ${first_value} second_key ${second_value} sum ${sum}

    [Return]    ${sum}

Choose Most Representative
    [Arguments]    ${dictionary}
    kwmkt_dbg_log      Choose Most Representative ARGS: dictionary ${dictionary}
    # here ${dictionary} look like    {'1': 29, '0': 90, '0,0': 2}}  or  {'2': 1977}
    ${keys}=           Get Dictionary Keys    ${dictionary}          # here ${keys} contain  1,0, 0,0  or only 2
    Sort List          ${keys}
    kwmkt_dbg_log      keys non ordonne ${keys}
    # ${key}=            Convert To Integer     ${keys['0']}           # key = 1
    ${most_representative_key}=            Convert To Integer     @{keys}[0]
    kwmkt_dbg_log      most_representative_key ${most_representative_key}
    [Return]    ${most_representative_key}


ExactValueForall
    [Arguments]    ${dic_occ}    ${ReqestedValueForall}    ${SbcId}    ${Tol}
    kwmkt_dbg_log      --------- ExactValueForall args: --------------
    kwmkt_dbg_log      >>> ExactValueForall <<< dic_occ ${dic_occ} ReqestedValueForall ${ReqestedValueForall} SbcId ${SbcId} Tol ${Tol}

    ${total}=              Set Variable    0
    ${requested_total}=    Set Variable    0

    # dic_occ exemple {'1': 2319, '2': 57}
    ${Keys_unsorted}=    Get Dictionary Keys	${dic_occ}    sort_keys=False
    kwmkt_dbg_log  Keys_unsorted:${Keys_unsorted}

    FOR    ${dic}    IN     @{Keys_unsorted}
                            kwmkt_dbg_log  dic >${dic}<
                            ${value}=                    Get From Dictionary     ${dic_occ}    ${dic}
                            ${total}=                    Evaluate                ${total} + ${value}
                            ${requested_total}=          Run Keyword If         '${dic}' == '${ReqestedValueForall}'
                            ...                          Evaluate                ${requested_total} + ${value}
                            ...                          ELSE    Set Variable    ${requested_total}
    END
    kwmkt_dbg_log  total:${total}
    kwmkt_dbg_log  requested_total:${requested_total}

    ${percentage}=    Evaluate         (${total} - ${requested_total}) / ${total} * 100
    kwmkt_dbg_log     percentage:${percentage}
    ${status}=        Run Keyword If    ${percentage} > ${Tol}    Set Variable    ${False}    ELSE    Set Variable    ${True}
    kwmkt_dbg_log     -------------------ExactValueForall status------------------------------------:${status}
    [Return]          ${status}

InfEgalValueFarll
    [Documentation]    Checks if all dictionary elements are greater than or equal to ${minimalValueForall}.
    ...                Returns ${status}, a boolean indicating if all elements met the condition.

# MLLB_MH    If UlData_puschReceiveReqGrant_t.mcs<>0 or 1          Then KO else OK
#            Case one occurrence > 1 then KO
# {'1': 896, '2': 167, '0': 740}
# {'1': 1196, '0': 1040, '2': 158}
    [Arguments]         ${dic_occ}    ${minimalValueForall}    ${SbcId}=0    ${elemRank}=0    ${Tol}=1

    # ${backup}=   Set Variable      ${DBGlogs}
    # ${DBGlogs}=    Set Variable    ${True}

    kwmkt_dbg_log      --------- InfEgalValueFarll args: --------------
    kwmkt_dbg_log      InfEgalValueFarll args:${dic_occ} ${minimalValueForall} SbcId ${SbcId} rank ${elemRank} Tol ${Tol}

    # ${total}=              Set Variable    0
    # ${requested_total}=    Set Variable    0

    # dic_occ exemple {'1': 2319, '2': 57}
    ${Keys_unsorted}=    Get Dictionary Keys	${dic_occ}    sort_keys=False
    kwmkt_dbg_log  Keys_unsorted:${Keys_unsorted}

    ${sup}=    Evaluate           ${minimalValueForall} + 1

    ${total}=              Set Variable    0
    ${requested_total}=    Set Variable    0

    # dic_occ exemple {'1': 896, '2': 167, '0': 740}

    FOR    ${dic}    IN     @{Keys_unsorted}
                            kwmkt_dbg_log  dic >${dic}<
                            ${value}=                    Get From Dictionary     ${dic_occ}    ${dic}
                            ${total}=                    Evaluate                ${total} + ${value}
                            ${requested_total}=          Run Keyword If         '${dic}' <= '${sup}'
                            ...                          Evaluate                ${requested_total} + ${value}
                            ...                          ELSE    Set Variable    ${requested_total}
    END
    kwmkt_dbg_log  total:${total}
    kwmkt_dbg_log  requested_total:${requested_total}

    ${percentage}=    Evaluate         (${total} - ${requested_total}) / ${total} * 100
    kwmkt_dbg_log     percentage:${percentage}
    ${status}=        Run Keyword If    ${percentage} > ${Tol}    Set Variable    ${False}    ELSE    Set Variable    ${True}

    # ${DBGlogs}=    Set Variable    ${backup}

    [Return]            ${status}

DisplayAverage
    [Documentation]     Average of all dictionary element
    ...                 return ${AverOfall}
    ...
    ...                 In this script, we go through the dictionary and for each element (key, value), we multiply the key by the value,
    ...                 add the result to the total sum, and also increment the total number of occurrences. Finally, we divide the total
    ...                 sum by the total number of occurrences to obtain the average.
    ...                 note: we focus on element rank ${elemRank}=0

    [Arguments]         ${dic_occ}    ${value}    ${SbcId}=0    ${elemRank}=0
    kwmkt_dbg_log       DisplayAverage args: dic_occ toolong & ${value} ${SbcId}=0 ${elemRank}=0


    ${sum}              Set Variable    0
    ${total}            Set Variable    0

    #'-8.2846,-255,5.26072,-255': 1, '-3.45491,-255,4.56642,-255': 1
    #${occ} = {'-3.49266,-255,0.454872,-255': 1, '-3.8443,-255,3.09126,-255': 1, '-3.88939,-255,4.95436,-255': 1, '0.15

    # special behavior dmrsSequenceType
    # Way to mach offset in wireshark result only rank 0/2/4... hav potential information @tony
    ${elemRankplus1}=        Evaluate    ${elemRank} + 1
    ${RankEven}        Check If Even     ${elemRank}
    ${elemRank}=       Set Variable if   ${RankEven}    ${elemRank}    ${elemRankplus1}

        #    ${status}  ${response}=     Run Keyword And Ignore Error    Get From Dictionary         ${Lidx}    list_name
        # #    kwmkt_dbg_log               status / response : ${status} / ${response}
        #    ${list_name}=               Set Variable IF    "${status}" != "PASS"    ${EMPTY}        ${response}

    FOR    ${dic}    IN    @{dic_occ}
                           # kwmkt_dbg_log  dic >${dic}<
                           ${element}=      Split String    ${dic}    ,   # Séparez la cle en utilisant la virgule comme delimiteur
                           ${status}  ${key}=    Run Keyword And Ignore Error    Convert To Number    ${element}[${elemRank}]   # la j ai la valeur
                           Run keyword if        "${status}" != "PASS"    Continue For Loop
                           ${value}=        Get From Dictionary      ${dic_occ}      ${dic}    # la j ai le nombre de fois cette valeur

                           # kwmkt_dbg_log  element >${element}< key >${key}< value >${value}<
                           ${sum}=          Evaluate    ${sum} + float(${key}) * ${value}
                           ${total}=        Evaluate    ${total} + ${value}
                           #kwmkt_dbg_log  sum ${sum} total ${total}
    END
    ${average}=        Evaluate    ${sum} / ${total}

    ${AverOfall}=      convert to number         ${average}     2

    Dated Log          DisplayAverage return:${AverOfall}

    [Return]            ${AverOfall}


Check If Even
    [Documentation]    Checks if the given number (${elemRank}) is even. Returns ${True} if the number is even, ${False} otherwise.
    [Arguments]    ${elemRank}
    ${remainder}=     Evaluate    ${elemRank} % 2
    ${Status}=        Set Variable If    '${remainder}' == '0'    ${True}    ${False}
    [Return]          ${Status}

PercentOfEachCase
    [Documentation]     Return a list formated as below
    ...                 list[0] -> occurency number
    ...                 list[1] -> % CRC OK/0
    ...                 list[2] -> % CRC KO/1
    ...                 return ${list}

    [Arguments]         ${dic_occ}    ${value}    ${SbcId}=0    ${elemRank}=0
    kwmkt_dbg_log       PercentOfEachCase args:dic_occ ${dic_occ} value ${value} SbcId${SbcId} elemRank ${elemRank}
    # MLLB_MH    Count nb of  "UlData_UePuschReceiveRespHarqU_t.crc" occurrences
#            Count nb of UlData_UePuschReceiveRespHarqU_t.crc=NOK/1
#            Gives percentSbcId1PuschCRCKO CRC NOK
#            Display ONLY

    # occ:{'0,0': 1590, '1,0': 421, '0,1': 91, '1,1': 36, '0': 93} val:Display SbcId 0 elemRank:0
    @{list} =	Create List

    ${total_value}=           Set Variable    0
    FOR    ${key}             IN    @{dic_occ.keys()}
           ${value}=          Get From Dictionary    ${dic_occ}    ${key}
           ${total_value}=    Evaluate    ${total_value} + ${value}
    END

    Append To List	          ${list}	${total_value}
    kwmkt_dbg_log             Total Value: ${total_value}

    FOR    ${key}             IN    @{dic_occ.keys()}
           ${value}=          Get From Dictionary    ${dic_occ}    ${key}
           ${percentage}=     Evaluate    round((${value} / ${total_value}) * 100,2)
        kwmkt_dbg_log         Key: ${key} Value: ${value} Percent: ${percentage}%
        Append To List	      ${list}	${percentage}
    END

    kwmkt_dbg_log       PercentOfEachCase return: for ${dic_occ} return :${list}
    [Return]            ${list}

isSup_elemListx_vs_elemListy
    [Documentation]    extra KW helping to answer to following question based on PercentOfEachCase result
    ...                If percentSubcellId1PuschCRCKO > percentSubcellId0PuschCRCKO  Then KO else OK

    [Arguments]        ${list}    ${elemListx}    ${elemListy}

    ${element1}=       Get From List    ${list}    ${elemListx}
    ${element2}=       Get From List    ${list}    ${elemListy}

    ${status}=         Set Variable If    ${element1} > ${element2}    ${True}    ${False}

    [Return]           ${status}

Read And Print Version
    ${version_file_path}=    Set Variable    testsuite/Paris/RRM/ET/CB012535/resources/version.txt
    ${first_line}=           read_first_line    ${version_file_path}

    Dated Log New Line  CB012535 framework version = ${first_line}

Check_Alarm_List
    [Documentation]    Checks if an alarm is present in the alarm list.
    ...                Logs the alarm list and the alarm to be checked.
    ...                Returns 'Found' if the alarm is present, 'Not Found' otherwise.
    ...                Fails if the alarm is not found.
    ...                usage: Check_Alarm_List    alarm_waited

    [Arguments]    ${alarm_waited}
    ${alarm_list}=             kwmkt_Alarmslist    ${alarm_waited}_AlarmCheck
    ${result}=                 Set Variable If     '${alarm_waited}' in '@{alarm_list}'    Found    Not Found
    Dated Log                  == alarm_waited: ${alarm_waited} == ${alarm_list} == ${result}

    Return From Keyword If     '${result}' == 'Found'    ${result}
    Fail                        Alarm ${alarm_waited} not found

stepDisp
    [Arguments]    ${txt}
    Dated Log new line     ************************************************************************
    Dated Log              ${consTraceColorBgYellow}${consTraceColorBlack}---> [ STEP ] : ${txt}${defColor}
    Dated Log              ************************************************************************

LoopDatedLog
    [Arguments]                     ${msg}                                      ${first}=${False}
    ...                             ${deep}=${0}
    ...                             ${isConsole}=${True}                        ${isLogFile}=${True}
    ...                             ${loopnb}=0
    ${message}=                     Catenate    == loop nbr : ${loopnb} == ${msg}
    StringTool.datedConsole         str=${message}                              deep=${deep}
    ...                             first=${first}
    ...                             isConsole=${isConsole}                      isLogFile=${isLogFile}

1235_actRimMitigationExtend_false
    [Arguments]    ${loopstep}    ${p}    ${tti}    ${EnSher}
    Dated Log  actNrRim disable / actRimMitigationExtend False
    kwmkt_dbg_log  loopstep:${loopstep} p:${p} tti:${tti} EnSher:${EnSher}

    ${status_deactivloop}=          Set Variable    ${True}
    Set_SCF_ConfigMarket            ${p}

    # #wait 5min 7525 desapear
    # Traced Sleep                    ${param.Wait_RI_Alarm_desapear}    ==> Waiting RI detection to be disabled (7525)
    ${res}                          Check_Alarm_List                   7525
    ${status_deactivloop}           Run Keyword If                    '${res}'=='Found'    Set Variable    ${False}    ${True}

    #Check UE still attached
    ${active_ues}          kwmkt_Get_IDs_of_Attached_UEs_From_Egate    state='ACTIVE'
    Dated Log              active_ues >${active_ues}<
    Should Not Be Empty    ${active_ues}    No active UE found

    ${dl_stats}            kwmkt_Get_UE_Stats_From_Egate    ue_id=1     scell=0-4    type=pdsch    size_unit=auto
    ${ul_stats}            kwmkt_Get_UE_Stats_From_Egate    ue_id=1     scell=0-4    type=pusch    size_unit=auto
    Dated Log              UE Stats: DL=${dl_stats} Mbps
    Dated Log              UE Stats: UL=${ul_stats} Mbps


    #Check tti   retransmissions occur in first (Slot 8/18) and 2nd UL slot (Slot 9/19)
    Run Keyword If                 ${tti} and not ${EnSher}            kwmkt_TTI_capt    ${param.GetTtiTraceTime}    ${loopstep}
    # add check in TTI !!!!!!!!!!!!!!!!
    #avec action sur ${status_deactivloop} pour le retour

    [Return]                       ${status_deactivloop}

1235_actRimMitigationExtend_true_tti
    [Arguments]    ${loopstep}    ${p}    ${tti}    ${EnSher}

    Dated Log  actNrRim RI detection only / actRimMitigationExtend True
    kwmkt_dbg_log  loopstep:${loopstep} p:${p} tti:${tti} EnSher:${EnSher}

    # kwmkt_TTI_start                ${param.GetTtiTraceTime}

    ${status_RI}=                  Set Variable    ${True}
    Set_SCF_ConfigMarket           ${p}

    # Run Keyword If                  ${tti} and not ${EnSher}          kwmkt_TTI_stop     suffix=TTI_12535_OFF_ON
    # ...                                                                                  targpath=${logsDir}/tti

    # #wait 5min 7525 apear
    # Traced Sleep                   ${param.Wait_RI_Alarm}              ==> Waiting RI detection to be enabled (7525)
    ${res}                         Check_Alarm_List                    7525
    ${status_RI}                   Run Keyword If                     '${res}'=='Found'    Set Variable    ${True}    ${False}

    #Check UE still attached
    ${active_ues}                  kwmkt_Get_IDs_of_Attached_UEs_From_Egate    state='ACTIVE'
    Dated Log                      active_ues >${active_ues}<
    Should Not Be Empty           ${active_ues}    No active UE found

    # ${dl_stats}                   kwmkt_Get_UE_Stats_From_Egate    ue_id=1     scell=0-4    type=pdsch    size_unit=auto
    ${ul_stats}                   kwmkt_Get_UE_Stats_From_Egate    ue_id=1     scell=0-4    type=pusch    size_unit=auto
    Dated Log                     UE Stats: DL= -not generated here-  Mbps, UL=${ul_stats} Xbps

    [Return]                      ${status_RI}

1235_actRimMitigationExtend_true
    [Arguments]    ${loopstep}    ${p}    ${tti}    ${EnSher}

    Dated Log  actNrRim RI detection only / actRimMitigationExtend True
    kwmkt_dbg_log  loopstep:${loopstep} p:${p} tti:${tti} EnSher:${EnSher}

    ${status_activloop}=           Set Variable    ${True}
    Set_SCF_ConfigMarket           ${p}

    # #wait 5min 7525 apear
    # Traced Sleep                   ${param.Wait_RI_Alarm}              ==> Waiting RI detection to be enabled (7525)
    ${res}                         Check_Alarm_List                    7525
    ${status_activloop}            Run Keyword If                     '${res}'=='Found'    Set Variable    ${True}    ${False}

    #Check UE still attached
    ${active_ues}    kwmkt_Get_IDs_of_Attached_UEs_From_Egate    state='ACTIVE'
    Dated Log        active_ues >${active_ues}<
    Should Not Be Empty    ${active_ues}    No active UE found

    ${dl_stats}   kwmkt_Get_UE_Stats_From_Egate    ue_id=1     scell=0-4    type=pdsch    size_unit=auto
    ${ul_stats}   kwmkt_Get_UE_Stats_From_Egate    ue_id=1     scell=0-4    type=pusch    size_unit=auto
    Dated Log     UE Stats: DL=${dl_stats} Mbps, UL=${ul_stats} Mbps

    #Check tti   retransmissions occur in 2nd UL slot (Slot 9/19)
    Run Keyword If                 ${tti} and not ${EnSher}            kwmkt_TTI_capt    ${param.GetTtiTraceTime}    ${loopstep}
    # add check in TTI !!!!!!!!!!!!!!!!
    #avec action sur ${status_deactivloop} pour le retour

    [Return]                       ${status_activloop}

12535_CellBehaviorCheck
    [Documentation]    This keyword checks the behavior of a cell. It captures TTI pcap data, converts it to json and csv,
    ...                and then checks the scheduling slots based on the frame structure and the scheduling type.
    ...                   Possible frame structure actually are 1116_0ms and 1070.
    ...                   Possible scheduling types are middle_cell and cell_edge.
    ...
    ...                transmissions / retransmissions in the first slot and in the second slot are check vs CB012535 req.

    [Arguments]    ${step}    ${frameStruct}=1116_0ms    ${waitedSchedulingType}=middle_cell

    ${TTIpcap}              kwmkt_TTI_capt_pcap       tgtDir=${logsDir}/TTI_${step}    time=10s
    ${TTIjson}  ${TTIcsv}   kwmkt_TTI_convert_pcap    TTIpcap=${TTIpcap}

    ${nb1stTx1stSlot}    ${nbReTx1stSlot}    ${nb1stTx2ndSlot}    ${nbReTx2ndSlot}
    ...                     getUeUlSchedulingSlots    jsonPathName=${TTIjson}    frameStruct=${frameStruct}

    Dated Log New Line      12535_CellBehaviorCheck nb1stTx1stSlot step : ${step}
    Dated Log               ${nb1stTx1stSlot} nbReTx1stSlot:${nbReTx1stSlot} nb1stTx2ndSlot:${nb1stTx2ndSlot} nbReTx2ndSlot:${nbReTx2ndSlot}

    Run Keyword If    '${waitedSchedulingType}' == 'middle_cell'     RunKeywords
    ...                     Should Be True          ${nbReTx1stSlot} == 0 and ${nbReTx2ndSlot} != 0
    ...  AND                Should Be True          ${nb1stTx1stSlot} != 0 and ${nb1stTx2ndSlot} != 0

    Run Keyword If    '${waitedSchedulingType}' == 'cell_edge'     RunKeywords
    ...                     Should Be True          ${nbReTx1stSlot} == 0 and ${nbReTx2ndSlot} != 0
    ...  AND                Should Be True          ${nb1stTx1stSlot} == 0 and ${nb1stTx2ndSlot} != 0

#FTS------------------------------------------------------------------------


# Reserve Corner

# PM_Counter_Tput_Check_12535
#     [Documentation]   Check the throughput in DL 4TX with RI 3 is above a min value
#     ...               orig= CNI-68516/resources/robot/CNI-68516_0920_Resources.robot
#     [Arguments]       ${CellID}=1

#                                                                    #M55309C01001 => DL MAC SDU volume transmitted on DTCH
#                                                                    #M55309C00001 => Duration of the measurement period for the MAC SDU report

#                                                                    #M55301C10001 => PDSCH transmissions using 4TX transmission with rank 1

#     ${vol}=           Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55309C01001    ${CellID}
#     ${dur}=           Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55309C00001    ${CellID}
#     ${pdsch4TXR1}=    Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55301C10001    ${CellID}
#     Dated Log         +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#     Dated Log           vol ...... / M55309C01001 / DL MAC SDU volume transmitted on DTCH ..........................: ${vol} Bytes
#     Dated Log           dur ...... / M55309C00001 / Duration of the measurement period for the MAC SDU report ......: ${dur} ms
#     Dated Log           pdsch4TXR1 / M55301C10001 / PDSCH transmissions using 4TX transmission with rank 1 .........: ${pdsch4TXR1} Grants
#     Dated Log         +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# 	${tput}               Evaluate    8 * ${vol} / (1000 * ${dur})
#     ${nb_pdsch4TXR1_byS}    Evaluate    8 * ${pdsch4TXR1} / (1000 * ${dur})

#     Dated Log           tput .....................................................................................: ${tput} Mb/s
#     Dated Log           nb_pdsch4TXR1_byS ........................................................................: ${nb_pdsch4TXR1_byS} NbGrant/s
#     Dated Log         +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# #=======================================================================================================================
# # KW to perform checks in pcap files
# #=======================================================================================================================

# Check FDM UL in BIP Msg
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Dated log                       Check UL FDM Activation in BIP Msg
#     ...                             (BIPvalueDMrsCdmGroupWithoutData=1 when FDM activated else set to 2)
#     Filter and Check field          ${pcapFile}
#     ...                             filterExp=(uldata_puschreceivereq) && (_5g_l1_ul_l2_ps_uldata_puschreceivereqgrant_t)
#     ...                             msg=UlData_PuschReceiveReq
#     ...                             data=.numOfDmrsCdmGroupWithoutData
#     ...                             value=${value}
#     ...                             endPacket=${1}

# Check PuschMappingType UL in BIP Msg
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Dated log                       Check PuschMappingType in BIP Traces
#     Filter and Check field          ${pcapFile}
#     ...                             filterExp=(uldata_puschreceivereq) && (_5g_l1_ul_l2_ps_uldata_puschreceivereqgrant_t)
#     ...                             msg=UlData_PuschReceiveReq
#     ...                             data=.ulDmrsMappingType
#     ...                             value=${value}
#     ...                             endPacket=${1}

# Check dmrs TypeA Position in BIP Msg
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Dated log                       Check dmrs TypeA Pos in BIP Msg (BIPvaluedmrsTypeAPosition=2 for Pos2 else 3 for Pos3)
#     Filter and Check field          ${pcapFile}
#     ...                             filterExp=(uldata_puschreceivereq) && (_5g_l1_ul_l2_ps_uldata_puschreceivereqgrant_t)
#     ...                             msg=UlData_PuschReceiveReq
#     ...                             data=.ulDmrsTypeAPos
#     ...                             value=${value}
#     ...                             endPacket=${1}

# Check Additional DMRS UL in BIP Msg
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Dated log                       Check Additional DMRS UL in BIP Msg
#     ...                             (value=1 for 1 additional DMRS else 0 for No Additional DMRS)
#     Filter and Check field          ${pcapFile}
#     ...                             filterExp=(uldata_puschreceivereq) && (_5g_l1_ul_l2_ps_uldata_puschreceivereqgrant_t)
#     ...                             msg=UlData_PuschReceiveReq
#     ...                             data=.ulDmrsAddPos
#     ...                             value=${value}
#     ...                             endPacket=${1}

# Check UL PTRS in BIP Msg
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Dated log                       Check UL PTRS status in BIP Traces (value=1 for UL PTRS activated else 0 for UL PTRS De-activated)
#     Filter and Check field          ${pcapFile}
#     ...                             filterExp=(uldata_puschreceivereq) && (_5g_l1_ul_l2_ps_uldata_puschreceivereqgrant_t)
#     ...                             msg=UlData_PuschReceiveReq
#     ...                             data=.ulPtrsFlag
#     ...                             value=${value}
#     ...                             endPacket=${1}

# Check TransfPrecoder enabled in BIP Msg
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Dated log                       Check TransformPrecoder is enabled in BIP Msg
#     Filter and Check field          ${pcapFile}
#     ...                             filterExp=(uldata_puschreceivereq) && (_5g_l1_ul_l2_ps_uldata_puschreceivereqgrant_t)
#     ...                             msg=UlData_PuschReceiveReq
#     ...                             data=.puschTransformPrecoderFlag
#     ...                             value=${value}
#     ...                             endPacket=${1}


# Check modulation scheme for PucchF3
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Dated log                       Check modulation scheme for PucchF3
#     Filter and Check field          ${pcapFile}
#     ...                             filterExp=(uldata_pucchreceivereq) && (_5g_l1_ul_l2_ps_UlData_pucchReceiveReqPucchResource_t.pucchFormat == 1)
#     ...                             msg=uldata_pucchreceivereq
#     ...                             data=.modulationType
#     ...                             value=${value}
#     ...                             endPacket=${1}


# Check TransfPrecoder disabled in BIP Msg
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Dated log                       Check TransformPrecoder is disabled in BIP Msg
#     Filter and Check field          ${pcapFile}
#     ...                             filterExp=(uldata_puschreceivereq) && (_5g_l1_ul_l2_ps_uldata_puschreceivereqgrant_t)
#     ...                             msg=UlData_PuschReceiveReq
#     ...                             data=.puschTransformPrecoderFlag
#     ...                             value=${value}
#     ...                             endPacket=${1}

# Check UL 256QAM in BIP
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Dated log                       Check 256QAM UL mcsTable is used in BIP Traces (value=1 when 256QAM UL mcsTable is used)
#     Filter and Check field          ${pcapFile}
#     ...                             filterExp=(uldata_puschreceivereq) && (_5g_l1_ul_l2_ps_uldata_puschreceivereqgrant_t)
#     ...                             msg=UlData_PuschReceiveReq
#     ...                             data=.mcsTable
#     ...                             value=${value}
#     ...                             endPacket=${1}

# Check CRC OK for HarqU in BIP
#     [Arguments]                     ${pcapFile}
#     ...                             ${crc}=0
#     Dated log                       Check CRC OK for PuschReceiveRespHarqU in BIP Msg
#     Filter and Check field          ${pcapFile}
#     ...                             filterExp=uldata_puschreceiverespharqu
#     ...                             msg=UlData_PuschReceiveRespHarqU
#     ...                             data=.crc
#     ...                             value=${crc}
#     ...                             endPacket=${1}

# Check NO DTX for HarqU in BIP
#     [Arguments]                     ${pcapFile}
#     ...                             ${dtx}=0
#     Dated log                       Check NO DTX for PuschReceiveRespHarqU in BIP Msg
#     Filter and Check field          ${pcapFile}
#     ...                             filterExp=uldata_puschreceiverespharqu
#     ...                             msg=UlData_PuschReceiveRespHarqU
#     ...                             data=.dtx
#     ...                             value=${dtx}
#     ...                             endPacket=${1}

# Filter and Check field
#     [Arguments]                     ${pcapfile}
#     ...                             ${filterExp}=None               ${msg}=None
#     ...                             ${data}=none                    ${value}=None
#     ...                             ${startPacket}=${1}             ${endPacket}=${-1}
#     ${filterPcap}                   analyzer.filter_pcap            ${pcapFile}
#     ...                             filterName=${msg}               filterExp=${filterExp}
#     ${pdmlFile}=                    analyzer.pcap_to_pdml           ${filterPcap}

#     Dated log                       \tIn BIP messages ${msg} [${startPacket}..${endpacket}], check ${data}=${value}
#     analyzer.check_list             pdmlFile=${pdmlFile}
#     ...                             packetName=${msg}
#     ...                             path=${data}$
#     ...                             value=${value}
#     ...                             startPacket=${startPacket}
#     ...                             endPacket=${endPacket}

# Check UserSetupReq
#     [Arguments]                     ${pcapFile}                     ${field}                       ${value}
#     ${pcapFiltered}                 analyzer.filter_pcap
#     ...                             pcapInFile=${pcapFile}
#     ...                             filterName=UserSetupReq
#     ...                             filterExp=itf_l2_ps_user_usersetupreq
#     ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
#     ${msg}=                         Set Variable                    itf_l2_ps_user_UserSetupReq
#     Dated log                       In message ${msg}, check ${field}=${value}                     first=True
#     analyzer.check_list             pdmlFile=${pdmlFile}
#     ...                             packetName=${msg}
#     ...                             path=${msg}.${field}$
#     ...                             value=${value}

# Check Additional DMRS UL
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Check RRC Reconfiguration for Additional DMRS       pcapFile=${pcapFile}            prefix=nr-rrc.pusch_Config
#     ...                             value=${value}

# Check PuschMappingTypeA
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Check RRC Reconfiguration for PuschMappingTypeA       pcapFile=${pcapFile}            prefix=nr-rrc.pusch_Config
#     ...                             value=${value}

# Check dmrs TypeA Position
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Check RRC Reconfiguration for dmrs TypeA Position       pcapFile=${pcapFile}            prefix=nr-rrc.reconfigurationWithSync_element
#     ...                             value=${value}

# Check transformPrecoder enabled
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Check RRC Reconfiguration for TransformPrecoder enabled       pcapFile=${pcapFile}            prefix=nr-rrc.pusch_Config
#     ...                             value=${value}

# Check tp_pi2BPSK enabled
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Check RRC Reconfiguration for tp_pi2BPSK enabled       pcapFile=${pcapFile}            prefix=nr-rrc.pusch_Config
#     ...                             value=${value}

# Check dmrs-UplinkTransformPrecoding-r16 enabled
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Check RRC Reconfiguration for dmrs-UplinkTransformPrecoding-r16 enabled       pcapFile=${pcapFile}            prefix=nr-rrc.pusch_Config
#     ...                             value=${value}

# Check dmrs-UplinkTransformPrecodingPUCCH-r16 enabled
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Check RRC Reconfiguration for dmrs-UplinkTransformPrecodingPUCCH-r16 enabled       pcapFile=${pcapFile}            prefix=nr-rrc.pucch_Config
#     ...                             value=${value}

# Check powerBoostPi2BPSK enabled
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Check RRC Reconfiguration for powerBoostPi2BPSK        pcapFile=${pcapFile}            prefix=nr-rrc.uplinkConfig
#     ...                             value=${value}

# Check maxCodeRate Value
#     [Arguments]                     ${pcapFile}
#     ...                             ${value}
#     Check RRC Reconfiguration for maxCodeRate        pcapFile=${pcapFile}            prefix=nr-rrc.pucch-Config
#     ...                             value=${value}


# Check RRC Reconfiguration for TransformPrecoder enabled
#     [Arguments]                     ${pcapFile}
#     ...                             ${prefix}
#     ...                             ${field}=nr-rrc.transformPrecoder
#     ...                             ${value}=value
#     ${pcapFiltered}                 analyzer.filter_pcap
#     ...                             pcapInFile=${pcapFile}
#     ...                             filterName=X2AP
#     ...                             filterExp=x2ap
#     ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
#     Dated Log                       In RRC Reconfiguration, check ${prefix}/.../${field} is st to ${value}
#     ...                             first=True
#     ${msg}                          Set Variable                    SgNBModificationRequired
#     analyzer.check_list             pdmlFile=${pdmlFile}
#     ...                             packetName=${msg}
#     ...                             path=${prefix}/.*/${field}$
#     ...                             value=${value}


# Check RRC Reconfiguration fortp_pi2BPSK enabled
#     [Arguments]                     ${pcapFile}
#     ...                             ${prefix}
#     ...                             ${field}=nr-rrc.tp-pi2BPSK
#     ...                             ${value}=value
#     ${pcapFiltered}                 analyzer.filter_pcap
#     ...                             pcapInFile=${pcapFile}
#     ...                             filterName=X2AP
#     ...                             filterExp=x2ap
#     ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
#     Dated Log                       In RRC Reconfiguration, check ${prefix}/.../${field} is set to ${value}
#     ...                             first=True
#     ${msg}                          Set Variable                    SgNBModificationRequired
#     analyzer.check_list             pdmlFile=${pdmlFile}
#     ...                             packetName=${msg}
#     ...                             path=${prefix}/.*/${field}$
#     ...                             value=${value}


# Check RRC Reconfiguration for dmrs-UplinkTransformPrecoding-r16 enabled
#     [Arguments]                     ${pcapFile}
#     ...                             ${prefix}
#     ...                             ${field}=nr-rrc.dmrs-UplinkTransformPrecoding-r16
#     ...                             ${value}=value
#     ${pcapFiltered}                 analyzer.filter_pcap
#     ...                             pcapInFile=${pcapFile}
#     ...                             filterName=X2AP
#     ...                             filterExp=x2ap
#     ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
#     Dated Log                       In RRC Reconfiguration, check ${prefix}/.../${field} is set to ${value}
#     ...                             first=True
#     ${msg}                          Set Variable                    SgNBModificationRequired
#     analyzer.check_list             pdmlFile=${pdmlFile}
#     ...                             packetName=${msg}
#     ...                             path=${prefix}/.*/${field}$
#     ...                             value=${value}

# Check RRC Reconfiguration for dmrs-UplinkTransformPrecodingPUCCH-r16 enabled
#     [Arguments]                     ${pcapFile}
#     ...                             ${prefix}
#     ...                             ${field}=nr-rrc.dmrs-UplinkTransformPrecoding-r16
#     ...                             ${value}=value
#     ${pcapFiltered}                 analyzer.filter_pcap
#     ...                             pcapInFile=${pcapFile}
#     ...                             filterName=X2AP
#     ...                             filterExp=x2ap
#     ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
#     Dated Log                       In RRC Reconfiguration, check ${prefix}/.../${field} is set to ${value}
#     ...                             first=True
#     ${msg}                          Set Variable                    SgNBModificationRequired
#     analyzer.check_list             pdmlFile=${pdmlFile}
#     ...                             packetName=${msg}
#     ...                             path=${prefix}/.*/${field}$
#     ...                             value=${value}

# Check RRC Reconfiguration for powerBoostPi2BPSK
#     [Arguments]                     ${pcapFile}
#     ...                             ${prefix}
#     ...                             ${field}=nr-rrc.powerBoostPi2BPSK
#     ...                             ${value}=value
#     ${pcapFiltered}                 analyzer.filter_pcap
#     ...                             pcapInFile=${pcapFile}
#     ...                             filterName=X2AP
#     ...                             filterExp=x2ap
#     ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
#     Dated Log                       In RRC Reconfiguration, check ${prefix}/.../${field} is set to ${value}
#     ...                             first=True
#     ${msg}                          Set Variable                    SgNBModificationRequired
#     analyzer.check_list             pdmlFile=${pdmlFile}
#     ...                             packetName=${msg}
#     ...                             path=${prefix}/.*/${field}$
#     ...                             value=${value}

# Check RRC Reconfiguration for maxCodeRate
#     [Arguments]                     ${pcapFile}
#     ...                             ${prefix}
#     ...                             ${field}=nr-rrc.maxCodeRate
#     ...                             ${value}=value
#     ${pcapFiltered}                 analyzer.filter_pcap
#     ...                             pcapInFile=${pcapFile}
#     ...                             filterName=X2AP
#     ...                             filterExp=x2ap
#     ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
#     Dated Log                       In RRC Reconfiguration, check ${prefix}/.../${field} is set to ${value}
#     ...                             first=True
#     ${msg}                          Set Variable                    SgNBModificationRequired
#     analyzer.check_list             pdmlFile=${pdmlFile}
#     ...                             packetName=${msg}
#     ...                             path=${prefix}/.*/${field}$
#     ...                             value=${value}





# Check RRC Reconfiguration for Additional DMRS
#     [Arguments]                     ${pcapFile}
#     ...                             ${prefix}
#     ...                             ${field}=nr-rrc.dmrs_AdditionalPosition
#     ...                             ${value}=value
#     ${pcapFiltered}                 analyzer.filter_pcap
#     ...                             pcapInFile=${pcapFile}
#     ...                             filterName=X2AP
#     ...                             filterExp=x2ap
#     ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
#     Dated Log                       In RRC Reconfiguration, check ${prefix}/.../${field} is set to ${value}
#     ...                             first=True
#     ${msg}                          Set Variable                    SgNBAdditionRequestAcknowledge
#     analyzer.check_list             pdmlFile=${pdmlFile}
#     ...                             packetName=${msg}
#     ...                             path=${prefix}/.*/${field}$
#     ...                             value=${value}

# Check RRC Reconfiguration for PuschMappingTypeA
#     [Arguments]                     ${pcapFile}
#     ...                             ${prefix}
#     ...                             ${field}=nr-rrc.dmrs_UplinkForPUSCH_MappingTypeA
#     ...                             ${value}=value
#     ${pcapFiltered}                 analyzer.filter_pcap
#     ...                             pcapInFile=${pcapFile}
#     ...                             filterName=X2AP
#     ...                             filterExp=x2ap
#     ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
#     Dated Log                       In RRC Reconfiguration, check ${prefix}/.../${field} is st to ${value}
#     ...                             first=True
#     ${msg}                          Set Variable                    SgNBAdditionRequestAcknowledge
#     analyzer.check_list             pdmlFile=${pdmlFile}
#     ...                             packetName=${msg}
#     ...                             path=${prefix}/.*/${field}$
#     ...                             value=${value}

# Check RRC Reconfiguration for dmrs TypeA Position
#     [Arguments]                     ${pcapFile}
#     ...                             ${prefix}
#     ...                             ${field}=nr-rrc.dmrs_TypeA_Position
#     ...                             ${value}=value
#     ${pcapFiltered}                 analyzer.filter_pcap
#     ...                             pcapInFile=${pcapFile}
#     ...                             filterName=X2AP
#     ...                             filterExp=x2ap
#     ${pdmlFile}=                    analyzer.pcap_to_pdml           ${pcapFiltered}
#     Dated Log                       In RRC Reconfiguration, check ${prefix}/.../${field} is st to ${value}
#     ...                             first=True
#     ${msg}                          Set Variable                    SgNBAdditionRequestAcknowledge
#     analyzer.check_list             pdmlFile=${pdmlFile}
#     ...                             packetName=${msg}
#     ...                             path=${prefix}/.*/${field}$
#     ...                             value=${value}


# Check modulation scheme for PucchF3 in BIP Traces
#     Check modulation scheme for PucchF3          pcapFile=${CaptureBIP_TP_enabled.path}
#     ...                                           value=BSPK

# Check transformPrecoder enabled in BIP Traces
#     Check TransfPrecoder enabled in BIP Msg       pcapFile=${CaptureBIP_TP_enabled.path}
#     ...                                           value=${TransformPrecoder_enabled_FLAG}

# Check transformPrecoder disabled in BIP Traces
#     Check TransfPrecoder disabled in BIP Msg       pcapFile=${CaptureBIP_TP_disabled.path}
#     ...                                           value=${TransformPrecoder_disabled_FLAG}

# Check transformPrecoder enabled in RRC Msg
#     Check transformPrecoder enabled               pcapFile=${CaptureCORE.path}
#     ...                                           value=${TransformPrecoder_enabled}

# #=======================================================================================================================
# # KW to set some parameters in SCF
# #=======================================================================================================================

# Restore Default Context 12535
#     Set Freq and TDD Frame struct
#     Set UE capa on EPCSim               ue_nr_capa_value=${ue_nr_capa_defValue}




# Restart
#     [Tags]                             RESTART
#     Restart TL



# Get L1L2 Logs TP disabled

#     Dated Log                         ======> Get L1L2 Bip Traces with  TP disabled
#     ${CaptureBIP_TP_disabled}           Capture L1L2 Set Upon Config     airscale=${GNB_DU}

#     Capture Init                      capture=${CaptureBIP_TP_disabled}		suffix=_TP_OFF
#     Capture start                     ${CaptureBIP_TP_disabled}
#     Traced sleep                      5s
#     Capture stop                      ${CaptureBIP_TP_disabled}

#     Dated Log New Line                === path capture : ${CaptureBIP_TP_disabled.path} ===

#     Set Global Variable               ${CaptureBIP_TP_disabled.path}


# Get L1L2 Logs TP enabled

#     Dated Log                         ======> Get L1L2 Bip Traces with  TP enabled
#     ${CaptureBIP_TP_enabled}           Capture L1L2 Set Upon Config     airscale=${GNB_DU}

#     Capture Init                      capture=${CaptureBIP_TP_enabled}   suffix=_TP_ON
#     Capture start                     ${CaptureBIP_TP_enabled}
#     Traced sleep                      5s
#     Capture stop                      ${CaptureBIP_TP_enabled}

#     Dated Log New Line                === path capture : ${CaptureBIP_TP_enabled.path} ===

#     Set Global Variable               ${CaptureBIP_TP_enabled.path}


# Start Capture RRC Reconfiguration Message
#     #vbo#changing target to GNB_CU for vRAN2.0
#     ${CaptureFirstRRCReconf}    Run Keyword If    not ${isAic}    Capture CORE Set Upon Config    airscale=${GNB_DU}
#     ...               ELSE
#     ...                                                 Capture CORE Set Upon Config    airscale=${GNB_CU}
#     Capture Init                    ${CaptureFirstRRCReconf}           suffix=_First_RRC_RECONF
#     Set Suite Variable              ${CaptureFirstRRCReconf}

#     Capture Start                   capture=${CaptureFirstRRCReconf}
#     Dated Log New Line                === Started Capture for First RRC Reconf : ${CaptureFirstRRCReconf.path} ===
# 	Set Global Variable               ${CaptureFirstRRCReconf.path}


# Stop Capture RRC Reconfiguration Message
# 	Capture stop                      ${CaptureFirstRRCReconf}

# Test WTS Setup
#     WTS Setup

# Test Verify Cell Setup
#     UE Cell Setup Check

# SgNB Addition PRACH
#     SgNB Addition to ENB            ueSetting=${UE_SIMPLE}
#     ...                             captureCallback=None
#     ...                             capture=None

# Attach_FR1
#     UE Attach Check

# UL Traffic
#     Traffic UE UL                   throughput=2
#     ...                             captureCallback=Callback Capture L1L2
#     ...                             capture=${CaptureL1L2}
#     ...                             deviation=20

# DL Traffic
#     Traffic UE DL                   throughput=2
#     ...                             captureCallback=Callback Capture L1L2
#     ...                             capture=${CaptureL1L2}
#     ...                             deviation=20

# UL_DL Traffic
#     Traffic UE UL DL                throughput=2
#     ...                             captureCallback=Callback Capture L1L2
#     ...                             capture=${CaptureL1L2}
#     ...                             deviation=20

# UL Traffic SA
#     Traffic UE UL           ueSetting=${BASIC_UE_SA}
#     ...                             throughput=2
#     ...                             captureCallback=Callback Capture L1L2
#     ...                             capture=${CaptureL1L2}
#     ...                             deviation=20

# UL_DL Traffic SA
#     Traffic UE UL DL         ueSetting=${BASIC_UE_SA}
#     ...                              throughput=2
#     ...                              captureCallback=Callback Capture L1L2
#     ...                              capture=${CaptureL1L2}
#     ...                              deviation=20

# Build UEs list SA Multi UEs

#     [Arguments]             ${dict_ues}
#     ${totalNbOfUe}          get length          ${dict_ues}
#     Step                    Dated Log           Configure the setting for the ${totalNbOfUe} UEs
#     Set Global Variable     ${totalNbOfUe}

#     @{listOfUes}            Create List
#     FOR    ${current_id}    IN RANGE    0    ${totalNbOfUe}
#         ${current_ue}=                Evaluate                      ${current_id} + 1
#         ${current_ueSetting}=         Copy Dictionary               ${BASIC_UE_SA}
#         Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue}
#         Set To Dictionary             ${current_ueSetting}          pdu                 1
#         Set To Dictionary             ${current_ueSetting}          trf_id              ${current_ue}
#         Set To Dictionary             ${current_ueSetting}          target_gnb          2
#         Set To Dictionary             ${current_ueSetting}          target_cells        ${dict_ues[${current_id}].originalCell}
#         Set To Dictionary             ${current_ueSetting}          DL_throughput          ${dict_ues[${current_id}].DL_throughput}
#         Set To Dictionary             ${current_ueSetting}          DL_throughput_GBR      ${dict_ues[${current_id}].DL_throughput_GBR}
#         Set To Dictionary             ${current_ueSetting}          UL_throughput          ${dict_ues[${current_id}].UL_throughput}
#         Set To Dictionary             ${current_ueSetting}          ue_nr_capa          ${dict_ues[${current_id}].ue_nr_capa}

#         Append To List                ${listOfUes}                  ${current_ueSetting}
#     END
#     Dated Log New Line                UE_List=${listOfUes}

#     [Return]                          ${listOfUes}

# Perform L3 Call for single or multi UEs

#     [Arguments]           ${listOfUes}
#     FOR    ${current_elem}    IN    @{listOfUes}
#         Dated Log New Line     === SA Register UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
#         CallSetup.UE Register                                   ue=${current_elem.ue}
#         Dated Log New Line     === SA PDU SESSION for UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
#         CallSetup.Launch PDU Session                            ue=${current_elem.ue}
#         ...                                                     pdu=${current_elem.pdu}
#         ...                                                     gw=${current_elem.ue}
#     END


# Start UL Non GBR traffic for all the UEs
#     [Arguments]       ${listOfUes}
#     FOR    ${current_elem}    IN    @{listOfUes}
#         Run Keyword If      ${current_elem.UL_throughput} > ${NO_THROUGHPUT}     Run Keywords
#         ...    Dated Log New Line
#         ...       === Launch ${current_elem.UL_throughput}Mbits/s NonGBR UL traffic UE ${current_elem.ue} on cell ${current_elem.target_cells} ===
#         ...    AND       Start UL Traffic SA Not Stopped 		ueSetting=${current_elem}
#     END


# Start UL Traffic SA Not Stopped
#     [Documentation]
#     ...     Conditions:     it is based on the arguments ${param} ${ueSetting}
#     ...     Actions:        it manages the UL traffic on the UE
#     ...     Checks:         it checks nothing more than already done on lib.
#     ...     Verdict:        UL traffic is passed
#     [Arguments]             ${ueSetting}=${BASIC_UE_SA}

#     Set To Dictionary       ${ueSetting}        trf_id    1
#     Traffic UE UL           ueSetting=${ueSetting}
#     ...                     throughput=${ueSetting.UL_throughput}
#     ...                     captureCallback=None
#     ...                     capture=None
#     ...                     captureDuration=0
#     ...                     shouldBeStop=False

# Get UL throughput with Transform Precoder Enabled
#      [Arguments]       ${listOfUes}
#      FOR    ${current_elem}    IN    @{listOfUes}
# 			Dated Log New Line     === Checking avg tput for ${current_elem.ue} with TransPrecoder Enabled ===
# 			${ul_avg_enabled} = Traffic.Traffic Check Data Rate
# 			...					${expected_data_rate}=${ueSetting.UL_throughput}
# 			...                 ${deviation_in_percent}=5
# 			...					${additional_info}=Transform Precoder Enabled
# 			Should Be True    ${ul_avg_enabled}   True  #   Not care throughput but check tput>0 to avoid ue release abnormal issue
# 			Dated Log New Line     === Checking avg tput for ${current_elem.ue} with TransPrecoder Enabled is ${ul_avg_enabled} ===
#      END

# Get UL throughput with Transform Precoder Disabled
#      [Arguments]       ${listOfUes}
#      FOR    ${current_elem}    IN    @{listOfUes}
# 			Dated Log New Line     === Checking avg tput for ${current_elem.ue} with TransPrecoder Disabled ===
# 			${ul_avg_disabled} = Traffic.Traffic Check Data Rate
# 			...					${expected_data_rate}=${ueSetting.UL_throughput}
# 			...                 ${deviation_in_percent}=5
# 			...					${additional_info}=Transform Precoder Disabled
# 			Should Be True    ${ul_avg_disabled}   True  #   Not care throughput but check tput>0 to avoid ue release abnormal issue
# 			Dated Log New Line     === Checking avg tput for ${current_elem.ue} with TransPrecoder Disabled is ${ul_avg_disabled} ===
#      END

# #MODULE ON REFLEXION
# # Verify Parameters in RRCReconf form Egate_console
# # 		  [Documentation]
# # 		  ...     Conditions:     It is based on several Arguments as shown in the arguments
# #           ...     Actions:        It extracts the RRR_reconf_message(s) from egate console using the python scripty verify_reconfig
# #           ...		  			  and stores each one into a seprate files depending
# # 		  ...					  on the number of RRCReconfig messages are present in the file.The name of this file
# # 		  ...					  is passed as argument.Possible values are written in the constants.py file.
# #           ...     Checks:         it checks the the values passed as arguments are the values present in the file.
# # 		  ...					  Since deferent RRC reconf message can have or not have a parameter depending on the
# # 		  ...					  scenario, use the word IGNORE and this parameter will not be checked in the RRR Recong message
# #           ...     Verdict:        All values are as expected

# # 		  [Arguments] 				${RRC_Reconf_file_name}=Reconfig_MSG_1
# # 		  ...						${keepRRCFiles}=false
# # 		  ...						${transformPrecoder}=enabled
# #           ...						${tp_pi2BPSK}=enabled
# # 		  ...						${dmrs-UplinkTransformPrecoding-r16}=enabled
# # 		  ...						${dmrs-UplinkTransformPrecodingPUCCH-r16}=enabled
# # 		  ...						${powerBoostPi2BPSK}=enabled
# # 		  ...						${maxCodeRate}=zeroDot15

# # 		  CallSetup.Flush Egate Console Buffer
# # #		  ${alias}                  SSH Connect and Exec      host=${HOST_EPCSIM}
# # #		  ...												  command=cp ${RRCScriptspath}/${RRCScriptsname} ${LOG_PATH}/

# # 		  ${alias}					SSH Upload Script		  host=${HOST_EPCSIM}
# # 		  ...												  scriptFile=${RRCScriptsname}
# # 		  ...												  localPath=${RRCScriptspath}
# # 		  ...												  remotePath=${LOG_PATH}/
# # 		  Traced Sleep					  2s

# # 		  ${output}                       SSH Cmd
# # 		   ...                            command=python ${LOG_PATH}/${RRCScriptsname}
# #            ...                            alias=${alias}

# # 		  Traced Sleep					  2s

# # 		  ${output}                       SSH Cmd
# # 		   ...                            command=${tl.core.dir_path}/egate_console.log
# #            ...                            alias=${alias}

# # 		  Traced Sleep					  2s
# # 		  IF                  			 				$tp_pi2BPSK != ignore
# # 				If 						  				$tp_pi2BPSK == enabled
# # 						${output}                       SSH Cmd
# # 						...                             command=grep 'tp-pi2BPSK enabled'  ${LOG_PATH}/${RRC_Reconf_file_name}
# # 						...                             alias=${alias}
# # 						should contain                  ${output}                     tp-pi2BPSK enabled
# # 				ELSE
# # 						${output}                       SSH Cmd
# # 						...                             command= grep 'tp-pi2BPSK enabled'  ${LOG_PATH}/${RRC_Reconf_file_name}
# # 						...                             alias=${alias}
# # 						should contain                  ${output}                     tp-pi2BPSK enabled

# # 		  IF											$dmrs-UplinkTransformPrecoding-r16 != ignore
# # 				If                  					$dmrs-UplinkTransformPrecoding-r16 == enabled
# # 						${output}                       SSH Cmd
# # 						...                        command =grep 'dmrs-UplinkTransformPrecoding-r16 enabled'  ${LOG_PATH}/${RRC_Reconf_file_name}
# # 						...                             alias=${alias}
# # 						should contain                  ${output}                     dmrs-UplinkTransformPrecoding-r16 enabled
# # 				  ELSE
# # 						${output}                       SSH Cmd
# # 						...                             command 'dmrs-UplinkTransformPrecoding-r16 disabled'  ${LOG_PATH}/${RRC_Reconf_file_name}
# # 						...                             alias=${alias}
# # 						should contain                  ${output}                     dmrs-UplinkTransformPrecoding-r16 disabled

# # 		  Traced Sleep					  2s
# # 		   IF 									$keepRRCFiles==false
# # 				${output}                       SSH Cmd
# # 				...                             command= rm -rf ${LOG_PATH}/Reconfig_MSG*
# # 				...                             alias=${alias}

# #	Critical Step					Check transformPrecoder enabled   pcapFile=CaptureFirstRRCReconf    value=enabled
# #	Critical Step					Check tp_pi2BPSK enabled   pcapFile=CaptureFirstRRCReconf    value=enabled
# #	Critical Step					Check dmrs-UplinkTransformPrecoding-r16 enabled   #To be added when feature is activated
# #	Critical Step					Check dmrs-UplinkTransformPrecodingPUCCH-r16 enabled    #To be added when feature is activated
# #	Critical Step					Check powerBoostPi2BPSK enabled  pcapFile=CaptureFirstRRCReconf    value=TRUE
# #	Critical Step					Check maxCodeRate Value   pcapFile=CaptureFirstRRCReconf    value=zeroDot15


# #==========================================
# #Customised rename of sherpa logs
# #==========================================
# Rename Of Sherpa Logs
#     ${TestName}                     getFormattedName
#     Copy File                       ${LOG_PATH}/l2stream3/tcpdump/tcpdump.pcap        ${LOG_PATH}/l2stream3/tcpdump/${TestName}.pcap

