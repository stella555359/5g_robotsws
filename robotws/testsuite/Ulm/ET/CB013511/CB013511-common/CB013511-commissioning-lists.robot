*** Settings ***
Documentation   This is a keyword file for CB013511, part commissioning - lists
...             Team: 'MI MN RAN RD VRF ULM 4'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Library   XML

*** Keywords ***

Add Lists For Common_A_SE_TC02_TC03
    [Documentation]    [PRIVATE]    Add Lists For Common_A_SE_TC02_TC03
    ...       :Author: Sylvia Schneider
    Add measPrMaNSAList To NRCELL-1
    Add measPrMaNSAList To NRCELL-6
    Add List a4PeriodicMeasControlNSA


Add Lists For Common_A_SE_TC05
    [Documentation]    [PRIVATE]    Add Lists For Common_A_SE_TC05
    ...       :Author: Sylvia Schneider
    Add a2MeasSCellRelSsbRsrq To NRCELL-1 And NRCELL-3
    Add measPrMaNSAList To NRCELL-1 And NRCELL-3
    Add List a4PeriodicMeasControlNSA
    Update carrierAggregationSupportList NRDU-1


Add Lists For Common_A_SE_TC04
    [Documentation]    [PRIVATE]    Add Lists For Common_A_SE_TC04
    ...       :Author: Sylvia Schneider
    Add measPrMaNSAList To NRCELL-1
    Add List a4PeriodicMeasControlNSA
    Add measPrMaNSAList To NRCELL-6
    Update carrierAggregationSupportList NRDU-1


Create Single List measPrMaNSAList
    [Documentation]    [PRIVATE]    Create Single List measPrMaNSAList
    ...       :Author: Sylvia Schneider
    [Arguments]   ${nsa_id}    ${nrcell_id}
    ${new_list}  Catenate      SEPARATOR=\n
    ...   <list name="measPrMaNSAList">
    ...   <item>
    ...   <p name="measPrPriority">1</p>
    ...   <p name="nrMeasPrMaNSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-${nsa_id}</p>
    ...   </item>
    ...   </list>
    Log To Console    add measPrMaNSAList To NRCELL-${nrcell_id}
    XML.Add Element       ${scf_xml}     ${new_list}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]


Add measPrMaNSAList To NRCELL-1
    [Documentation]    [PRIVATE]    Add measPrMaNSAList To NRCELL-1
    ...       :Author: Sylvia Schneider
    Create Single List measPrMaNSAList    nsa_id=1      nrcell_id=1


Add measPrMaNSAList To NRCELL-1 And NRCELL-3
    [Documentation]    [PRIVATE]    Add measPrMaNSAList To NRCELL-1 And NRCELL-3
    ...       :Author: Sylvia Schneider
    Create Single List measPrMaNSAList    nsa_id=1      nrcell_id=1
    Create Single List measPrMaNSAList    nsa_id=2      nrcell_id=3


Add measPrMaNSAList To NRCELL-6
    [Documentation]    [PRIVATE]    Add measPrMaNSAList To NRCELL-6
    ...       :Author: Sylvia Schneider
    ${new_list}  Catenate      SEPARATOR=\n
    ...   <list name="measPrMaNSAList">
    ...   <item>
    ...   <p name="measPrPriority">1</p>
    ...   <p name="nrMeasPrMaNSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2</p>
    ...   </item>
    ...   <item>
    ...   <p name="measPrPriority">100</p>
    ...   <p name="nrMeasPrMaNSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-3</p>
    ...   </item>
    ...   </list>
    Log To Console    add measPrMaNSAList To NRCELL-6
    XML.Add Element       ${scf_xml}     ${new_list}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-6"]


Create Single List a4PeriodicMeasControlNSA
    [Documentation]    [PRIVATE]    Create Single List a4PeriodicMeasControlNSA
    ...       :Author: Sylvia Schneider
    [Arguments]   ${nrcell_id}
    ${new_list}  Catenate      SEPARATOR=\n
    ...   <list name="a4PeriodicMeasControlNSA">
    ...   <item>
    ...   <p name="a4Fr1SupervisionTimer">4000</p>
    ...   <p name="a4Fr2SupervisionTimer">6000</p>
    ...   <p name="a4MeasMaxNumber">5</p>
    ...   <p name="a4RetryTimer">10</p>
    ...   </item>
    ...   </list>
    Log To Console    add list a4PeriodicMeasControlNSA To NRCELL-${nrcell_id}
    XML.Add Element       ${scf_xml}     ${new_list}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]


Add List a4PeriodicMeasControlNSA
    [Documentation]    [PRIVATE]    Add List a4PeriodicMeasControlNSA
    ...       :Author: Sylvia Schneider
    FOR   ${nrcell_id}   IN   10   11   13   14
        Create Single List a4PeriodicMeasControlNSA   ${nrcell_id}
    END


Create Single List a2MeasSCellRelSsbRsrq
    [Documentation]    [PRIVATE]    Create Single List a2MeasSCellRelSsbRsrq
    ...       :Author: Sylvia Schneider
    [Arguments]    ${a2ThresholdSCellRelSsbRsrq}    ${a2TimeToTriggerSCellRelSsbRsrq}    ${nrcell_id}
    ${new_list}  Catenate      SEPARATOR=\n
    ...   <list name="a2MeasSCellRelSsbRsrq">
    ...   <item>
    ...   <p name="a2HysteresisSCellRelSsbRsrq">0</p>
    ...   <p name="a2ThresholdSCellRelSsbRsrq">${a2ThresholdSCellRelSsbRsrq}</p>
    ...   <p name="a2TimeToTriggerSCellRelSsbRsrq">${a2TimeToTriggerSCellRelSsbRsrq}</p>
    ...   </item>
    ...   </list>
    Log To Console    add a2MeasSCellRelSsbRsrq To NRCELL-${nrcell_id}
    XML.Add Element       ${scf_xml}     ${new_list}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]


Add a2MeasSCellRelSsbRsrq To NRCELL-1 And NRCELL-3
    [Documentation]    [PRIVATE]    Add a2MeasSCellRelSsbRsrq To NRCELL-1 And NRCELL-3
    ...       :Author: Sylvia Schneider
    FOR   ${a2ThresholdSCellRelSsbRsrq}    ${a2TimeToTriggerSCellRelSsbRsrq}    ${nrcell_id}    IN
    ...   49                               480ms                                1
    ...   51                               256ms                                3
       Create Single List a2MeasSCellRelSsbRsrq   ${a2ThresholdSCellRelSsbRsrq}    ${a2TimeToTriggerSCellRelSsbRsrq}    ${nrcell_id}
    END


Update carrierAggregationSupportList NRDU-1
    [Documentation]    [PRIVATE]    Update carrierAggregationSupportList NRDU-1
    ...       :Author: Sylvia Schneider
    XML.Remove Element    ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRDU-1"]/list[@name="carrierAggregationSupportList"]
    ${new_list}  Catenate      SEPARATOR=\n
    ...   <list name="carrierAggregationSupportList">
    ...   <p>ca_Fdd_Fdd</p>
    ...   <p>ca_Fdd_Fr1Tdd_Sa</p>
    ...   <p>ca_Fdd_Fr1Tdd_Nsa</p>
    ...   <p>ca_Fdd_Fr1Tdd_Sa_WithUl</p>
    ...   <p>ca_Fr1Tdd_Sa</p>
    ...   <p>ca_Fr1Tdd_Nsa</p>
    ...   <p>ca_Fr1Tdd_Fdd_Sa</p>
    ...   <p>ca_Fr1Tdd_Fdd_Nsa</p>
    ...   <p>ca_Fr1Tdd_Fdd_Sa_WithUl</p>
    ...   <p>ca_Fdd_Any_Sa</p>
    ...   <p>ca_Fr1Tdd_Any_Sa</p>
    ...   </list>
    Log To Console    add carrierAggregationSupportList
    XML.Add Element       ${scf_xml}     ${new_list}   xpath=.//managedObject[@distName="${bts_distName}/NRDU-1"]
