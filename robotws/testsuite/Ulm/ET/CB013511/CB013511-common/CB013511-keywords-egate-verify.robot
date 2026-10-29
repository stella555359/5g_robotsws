*** Settings ***
Documentation   This is a keyword file for CB013511 part egate verify
...             Team: 'MI MN RAN RD VRF ULM 4'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Library    OperatingSystem
Library    String
Library    XML


*** Keywords ***

Verify Egate Logs A_SE_TC02_B2_ALT1
    [Documentation]    [PRIVATE]    Verify Egate Logs A_SE_TC02_B2_ALT1
    ...       :Author: Sylvia Schneider
    Verify SgNBAddition
    Verify Meas Config After SgNBAddition
    Verify Handover
    Verify Meas Config After Handover
    Verify Throughput After Handover


Verify Egate Logs A_SE_TC05
    [Documentation]    [PRIVATE]    Verify Egate Logs A_SE_TC05
    ...       :Author: Sylvia Schneider
    Run Keyword And Continue On Failure   Verify SgNBAddition
    Run Keyword And Continue On Failure   Verify Meas Config After SgNBAddition TC05
    Run Keyword And Continue On Failure   Verify Intra DU Handover
    Run Keyword And Continue On Failure   Verify Meas Config After Handover TC05


Verify Egate Logs A_SE_TC04
    [Documentation]    [PRIVATE]    Verify Egate Logs A_SE_TC04
    ...       :Author: Sylvia Schneider
    Run Keyword And Continue On Failure   Verify SgNBAddition
    Run Keyword And Continue On Failure   Verify Meas Config After SgNBAddition TC05
    Run Keyword And Continue On Failure   Verify MeNB Handover
    Run Keyword And Continue On Failure   Verify Meas Config After Handover TC04


Verify String Present
    [Documentation]    [PRIVATE]    Verify String Present
    ...       :Author: Sylvia Schneider
    [Arguments]   ${contents}     ${search}
    Log To Console    -- Verify "${search}" present
    TRY
       Should Contain    ${contents}     ${search}
    EXCEPT
       Fail   "${search}" not present
    END


Verify SgNBAddition
    [Documentation]    [PRIVATE]    Verify SgNBAddition
    ...       :Author: Sylvia Schneider
    Log To Console    \nVerify SgNBAddition in file ${resultDir}/sgNB_add.txt
    ${contents}    OperatingSystem.Get File           ${resultDir}/sgNB_add.txt

    ${search}   Set Variable   UE111: pSCellFrequency with value 520110 present
    Verify String Present   ${contents}     ${search}
    Verify spCellConfigCommon                             contents=${contents}    physCellId=51
    Verify Successfully Reconfigured Dual Connectivity    contents=${contents}


Verify Successfully Reconfigured Dual Connectivity
    [Documentation]    [PRIVATE]   Verify Successfully Reconfigured Dual Connectivity
    ...       :Author: Sylvia Schneider
    [Arguments]  ${contents}
    ${search}   Set Variable   UE111: Successfully reconfigured dual connectivity
    Verify String Present   ${contents}     ${search}


Verify spCellConfigCommon
    [Documentation]    [PRIVATE]    Verify spCellConfigCommon
    ...       :Author: Sylvia Schneider
    [Arguments]  ${contents}   ${physCellId}

    ${search}   Set Variable   spCellConfig{servCellIndex8,reconfigurationWithSync{spCellConfigCommon{physCellId${physCellId},
    Log To Console    -- Verify "${search}" present
    ${tmp1}            String.Split String     ${contents}           physicalCellGroupConfig
    ${tmp2}            String.Split String     ${tmp1}[1]            downlinkConfigCommon
    ${spCellConfig}    Set Variable      ${tmp2}[0]
    ${tmp3}            String.Replace String   ${spCellConfig}     \n     ${EMPTY}
    ${tmp4}            String.Replace String     ${tmp3}   ${SPACE}    ${EMPTY}
    ${item_present}    Run Keyword And Return Status    Should Contain    ${tmp4}     ${search}
    IF  '${item_present}'=='False'    Fail   "${search}" not present


Get A TimeToTrigger Parameter Value From IAF List
    [Documentation]    [PRIVATE]    Get A TimeToTrigger Parameter Value From IAF List
    ...       :Author: Sylvia Schneider
    [Arguments]   ${IAF}   ${list}   ${param}
    ${xpath}  Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${IAF}"]/list[@name="${list}"]
    ${tmp1}  XML.Get Element Text  ${scf_vrf}  xpath=.//${xpath}/item/p[@name="${param}"]
    ${tmp2}  String.Remove String  ${tmp1}   ms
    ${value}  Catenate   ${tmp2}   ms
    Log To Console    -- IAF-${IAF} list "${list}" param "${param}" has value "${value}"
    RETURN   ${value}


Get A TimeToTrigger Parameter Value From NRCELL List
    [Documentation]    [PRIVATE]    Get A TimeToTrigger Parameter Value From NRCELL List
    ...       :Author: Sylvia Schneider
    [Arguments]   ${NRCELL}   ${list}   ${param}
    ${xpath}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-${NRCELL}"]/list[@name="${list}"]
    ${tmp1}  XML.Get Element Text  ${scf_vrf}  xpath=.//${xpath}/item/p[@name="${param}"]
    ${tmp2}  String.Remove String  ${tmp1}   ms
    ${value}  Catenate   ${tmp2}   ms
    Log To Console    -- NRCELL-${NRCELL} list "${list}" param "${param}" has value "${value}"
    RETURN   ${value}


Get A Parameter Value From IAF List
    [Documentation]    [PRIVATE]    Get A Parameter Value From IAF List
    ...       :Author: Sylvia Schneider
    [Arguments]   ${IAF}   ${list}   ${param}
    ${xpath}  Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${IAF}"]/list[@name="${list}"]
    ${value}  XML.Get Element Text  ${scf_vrf}  xpath=.//${xpath}/item/p[@name="${param}"]
    Log To Console    -- IAF-${IAF} list "${list}" param "${param}" has value "${value}"
    RETURN   ${value}


Get A Parameter Value From NRCELL List
    [Documentation]    [PRIVATE]    Get A Parameter Value From NRCELL List
    ...       :Author: Sylvia Schneider
    [Arguments]   ${NRCELL}   ${list}   ${param}
    ${xpath}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-${NRCELL}"]/list[@name="${list}"]
    ${value}  XML.Get Element Text  ${scf_vrf}  xpath=.//${xpath}/item/p[@name="${param}"]
    Log To Console    -- NRCELL-${NRCELL} list "${list}" param "${param}" has value "${value}"
    RETURN   ${value}


Verify Meas Config After SgNBAddition
    [Documentation]    [PRIVATE]    Verify Meas Config After SgNBAddition
    ...       :Author: Sylvia Schneider
    Log To Console    \nVerify measurements after SgNBAddition in file ${resultDir}/disp_meas_config_UE111_after_sgnbAdd.txt
    ${scf_vrf}    XML.Parse Xml    ${resultDir}/SCF_final.xml
    Set Test Variable     ${scf_vrf}

    ${a3TimeToTriggerSsbRsrp}   Get A TimeToTrigger Parameter Value From IAF List     IAF=1   list=a3MeasSsbRsrp   param=a3TimeToTriggerSsbRsrp

    ${a5Threshold1SsbRsrp}      Get A Parameter Value From IAF List                   IAF=1   list=a5MeasSsbRsrp   param=a5Threshold1SsbRsrp
    ${a5Threshold2SsbRsrp}      Get A Parameter Value From IAF List                   IAF=1   list=a5MeasSsbRsrp   param=a5Threshold2SsbRsrp
    ${a5TimeToTriggerSsbRsrp}   Get A TimeToTrigger Parameter Value From IAF List     IAF=1   list=a5MeasSsbRsrp   param=a5TimeToTriggerSsbRsrp

    ${a2ThresholdhoSsbRsrp}      Get A Parameter Value From IAF List                  IAF=1   list=a2MeashoSsbRsrp   param=a2ThresholdhoSsbRsrp
    ${a2TimeToTriggerhoSsbRsrp}   Get A TimeToTrigger Parameter Value From IAF List   IAF=1   list=a2MeashoSsbRsrp   param=a2TimeToTriggerhoSsbRsrp

    ${a2ThresholdReleaseSsbRsrp}   Get A Parameter Value From NRCELL List   NRCELL=1   list=a2MeasReleaseSsbRsrp   param=a2ThresholdReleaseSsbRsrp
    ${a2TimeToTriggerReleaseSsbRsrp}
    ...   Get A TimeToTrigger Parameter Value From NRCELL List   NRCELL=1   list=a2MeasReleaseSsbRsrp   param=a2TimeToTriggerReleaseSsbRsrp

    ${a1ThresholdSCellAddSsbRsrpTDD}
    ...   Get A Parameter Value From NRCELL List   NRCELL=1   list=a1MeasSCellAddSsbRsrp   param=a1ThresholdSCellAddSsbRsrpTDD
    ${a1TimeToTriggerSCellAddSsbRsrp}
    ...   Get A TimeToTrigger Parameter Value From NRCELL List   NRCELL=1   list=a1MeasSCellAddSsbRsrp   param=a1TimeToTriggerSCellAddSsbRsrp

    ${contents}    OperatingSystem.Get File         ${resultDir}/disp_meas_config_UE111_after_sgnbAdd.txt
    ${tmp1}        String.Split String              ${contents}       DETAILED INFO ABOUT NR REPORT CONFIGURATIONS
    ${tmp2}        String.Split String              ${tmp1}[1]        UE111 MEASUREMENT IDENTITIES
    ${nr_rep_configs}   Set Variable   ${tmp2}[0]

    ${search1}   Set Variable   TimeToTrigger: ${a3TimeToTriggerSsbRsrp}, ReportOnLeave: false, EventA3
    ${search2}   Catenate   TimeToTrigger: ${a5TimeToTriggerSsbRsrp}, ReportOnLeave: false,
    ...   EventA5: threshold1=Threshold: RSRP ${a5Threshold1SsbRsrp} threshold2=Threshold: RSRP ${a5Threshold2SsbRsrp}
    ${search3}   Set Variable
    ...   TimeToTrigger: ${a2TimeToTriggerhoSsbRsrp}, ReportOnLeave: false, EventA2: Threshold: RSRP ${a2ThresholdhoSsbRsrp}
    ${search4}   Set Variable
    ...   TimeToTrigger: ${a2TimeToTriggerReleaseSsbRsrp}, ReportOnLeave: false, EventA2: Threshold: RSRP ${a2ThresholdReleaseSsbRsrp}
    ${search5}   Set Variable
    ...   TimeToTrigger: ${a1TimeToTriggerSCellAddSsbRsrp}, ReportOnLeave: true, EventA1: Threshold: RSRP ${a1ThresholdSCellAddSsbRsrpTDD}

    FOR   ${search}   IN   ${search1}  ${search2}   ${search3}   ${search4}   ${search5}
        Verify String Present   ${nr_rep_configs}     ${search}
    END


Verify Meas Config After SgNBAddition TC05
    [Documentation]    [PRIVATE]    Verify Meas Config After SgNBAddition TC05
    ...       :Author: Sylvia Schneider
    Log To Console    \nVerify measurements after SgNBAddition in file ${resultDir}/disp_meas_config_UE111_after_sgnbAdd.txt
    ${scf_vrf}    XML.Parse Xml    ${resultDir}/SCF_final.xml
    Set Test Variable     ${scf_vrf}

    ${a3TimeToTriggerSsbRsrp}   Get A TimeToTrigger Parameter Value From IAF List     IAF=1   list=a3MeasSsbRsrp   param=a3TimeToTriggerSsbRsrp

    ${a5Threshold1SsbRsrp}      Get A Parameter Value From IAF List                   IAF=1   list=a5MeasSsbRsrp   param=a5Threshold1SsbRsrp
    ${a5Threshold2SsbRsrp}      Get A Parameter Value From IAF List                   IAF=1   list=a5MeasSsbRsrp   param=a5Threshold2SsbRsrp
    ${a5TimeToTriggerSsbRsrp}   Get A TimeToTrigger Parameter Value From IAF List     IAF=1   list=a5MeasSsbRsrp   param=a5TimeToTriggerSsbRsrp

    ${a2ThresholdhoSsbRsrp}      Get A Parameter Value From IAF List                  IAF=1   list=a2MeashoSsbRsrp   param=a2ThresholdhoSsbRsrp
    ${a2TimeToTriggerhoSsbRsrp}   Get A TimeToTrigger Parameter Value From IAF List   IAF=1   list=a2MeashoSsbRsrp   param=a2TimeToTriggerhoSsbRsrp

    ${a2ThresholdReleaseSsbRsrp}       Get A Parameter Value From IAF List
    ...                                                                  IAF=1    list=a2MeasReleaseSsbRsrp   param=a2ThresholdReleaseSsbRsrp
    ${a2TimeToTriggerReleaseSsbRsrp}   Get A TimeToTrigger Parameter Value From IAF List
    ...                                                                  IAF=1    list=a2MeasReleaseSsbRsrp   param=a2TimeToTriggerReleaseSsbRsrp

    ${a1ThresholdSCellAddSsbRsrpTDD}      Get A Parameter Value From IAF List
    ...                                                                  IAF=1   list=a1MeasSCellAddSsbRsrp   param=a1ThresholdSCellAddSsbRsrpTDD
    ${a1TimeToTriggerSCellAddSsbRsrp}   Get A TimeToTrigger Parameter Value From IAF List
    ...                                                                  IAF=1   list=a1MeasSCellAddSsbRsrp   param=a1TimeToTriggerSCellAddSsbRsrp

    ${contents}    OperatingSystem.Get File         ${resultDir}/disp_meas_config_UE111_after_sgnbAdd.txt
    ${tmp1}        String.Split String              ${contents}       DETAILED INFO ABOUT NR REPORT CONFIGURATIONS
    ${tmp2}        String.Split String              ${tmp1}[1]        UE111 MEASUREMENT IDENTITIES
    ${nr_rep_configs}   Set Variable   ${tmp2}[0]

    ${search1}   Set Variable   TimeToTrigger: ${a3TimeToTriggerSsbRsrp}, ReportOnLeave: false, EventA3
    ${search2}   Catenate   TimeToTrigger: ${a5TimeToTriggerSsbRsrp}, ReportOnLeave: false,
    ...   EventA5: threshold1=Threshold: RSRP ${a5Threshold1SsbRsrp} threshold2=Threshold: RSRP ${a5Threshold2SsbRsrp}
    ${search3}   Set Variable
    ...   TimeToTrigger: ${a2TimeToTriggerhoSsbRsrp}, ReportOnLeave: false, EventA2: Threshold: RSRP ${a2ThresholdhoSsbRsrp}
    ${search4}   Set Variable
    ...   TimeToTrigger: ${a2TimeToTriggerReleaseSsbRsrp}, ReportOnLeave: false, EventA2: Threshold: RSRP ${a2ThresholdReleaseSsbRsrp}
    ${search5}   Set Variable
    ...   TimeToTrigger: ${a1TimeToTriggerSCellAddSsbRsrp}, ReportOnLeave: true, EventA1: Threshold: RSRP ${a1ThresholdSCellAddSsbRsrpTDD}

    FOR   ${search}   IN   ${search1}  ${search2}   ${search3}   ${search4}   ${search5}
        Verify String Present   ${nr_rep_configs}     ${search}
    END


Verify Handover
    [Documentation]    [PRIVATE]    Verify Handover
    ...       :Author: Sylvia Schneider
    Log To Console    \nVerify intra-MeNB HO with PSCell change in file ${resultDir}/intra_MeNB_HO.txt
    ${contents}    OperatingSystem.Get File           ${resultDir}/intra_MeNB_HO.txt

    FOR   ${search}   IN   UE111: Sending SgNB Modification Request
    ...                    UE111: Proxy (eNB 2 cell 6) reported successful RA
    ...                    UE111: Dual Connectivity reconfiguration is successful
    ...                    UE111: Intra-eNB handover from ENB-1.2 to ENB-1.1 performed
    ...                    SgNBReconfigurationComplete sent to ENB-2
    ...                    SgNBModificationConfirm sent to ENB-2
        Verify String Present   ${contents}     ${search}
    END

    Verify spCellConfigCommon                             contents=${contents}    physCellId=56
    Verify Successfully Reconfigured Dual Connectivity    contents=${contents}


Verify Intra DU Handover
    [Documentation]    [PRIVATE]    Verify Intra DU Handover
    ...       :Author: Sylvia Schneider
    Log To Console    \nVerify intra-DU PS cell change from Cell-1 to Cell-3 in file ${resultDir}/intra_DU_HO.txt
    ${contents}    OperatingSystem.Get File           ${resultDir}/intra_DU_HO.txt

    ${search}  Set Variable    UE111: Proxy (eNB 2 cell 3) reported successful RA
    Verify String Present   ${contents}     ${search}

    Verify spCellConfigCommon                             contents=${contents}    physCellId=53
    Verify Successfully Reconfigured Dual Connectivity    contents=${contents}


Verify MeNB Handover
    [Documentation]    [PRIVATE]    Verify MeNB Handover
    ...       :Author: Sylvia Schneider
    Log To Console    \nVerify intra-MeNB HO with PSCell change in file ${resultDir}/intra_MeNB_HO.txt
    ${contents}    OperatingSystem.Get File           ${resultDir}/intra_MeNB_HO.txt

    FOR   ${search}   IN   UE111: Proxy (eNB 2 cell 6) reported successful RA
    ...                    UE111: Dual Connectivity reconfiguration is successful
    ...                    UE111: Inter-eNB handover from ENB-3.1 to ENB-1.1 performed
    ...                    SgNBReconfigurationComplete sent to ENB-2
    ...                    SgNBModificationConfirm sent to ENB-2
        Verify String Present   ${contents}     ${search}
    END

    Verify spCellConfigCommon                             contents=${contents}    physCellId=56
    Verify Successfully Reconfigured Dual Connectivity    contents=${contents}


Verify Meas Config After Handover
    [Documentation]    [PRIVATE]    Verify Meas Config After Handover
    ...       :Author: Sylvia Schneider
    Log To Console    \nVerify measurements after HO in file ${resultDir}/disp_meas_config_UE111_after_HO.txt
    ${scf_vrf}    XML.Parse Xml    ${resultDir}/SCF_final.xml
    Set Test Variable     ${scf_vrf}

    ${a3TimeToTriggerSsbRsrp}     Get A TimeToTrigger Parameter Value From IAF List   IAF=3   list=a3MeasSsbRsrp   param=a3TimeToTriggerSsbRsrp

    ${a5Threshold1SsbRsrp}        Get A Parameter Value From IAF List                 IAF=3   list=a5MeasSsbRsrp   param=a5Threshold1SsbRsrp
    ${a5Threshold2SsbRsrp}        Get A Parameter Value From IAF List                 IAF=3   list=a5MeasSsbRsrp   param=a5Threshold2SsbRsrp
    ${a5TimeToTriggerSsbRsrp}     Get A TimeToTrigger Parameter Value From IAF List   IAF=3   list=a5MeasSsbRsrp   param=a5TimeToTriggerSsbRsrp

    ${a2ThresholdhoSsbRsrp}       Get A Parameter Value From IAF List                 IAF=3   list=a2MeashoSsbRsrp   param=a2ThresholdhoSsbRsrp
    ${a2TimeToTriggerhoSsbRsrp}   Get A TimeToTrigger Parameter Value From IAF List   IAF=3   list=a2MeashoSsbRsrp   param=a2TimeToTriggerhoSsbRsrp

    ${a2ThresholdReleaseSsbRsrp}   Get A Parameter Value From NRCELL List   NRCELL=6   list=a2MeasReleaseSsbRsrp   param=a2ThresholdReleaseSsbRsrp
    ${a2TimeToTriggerReleaseSsbRsrp}
    ...   Get A TimeToTrigger Parameter Value From NRCELL List   NRCELL=6   list=a2MeasReleaseSsbRsrp   param=a2TimeToTriggerReleaseSsbRsrp

    ${contents}    OperatingSystem.Get File         ${resultDir}/disp_meas_config_UE111_after_HO.txt
    ${tmp1}        String.Split String     ${contents}       DETAILED INFO ABOUT NR REPORT CONFIGURATIONS
    ${tmp2}        String.Split String     ${tmp1}[1]        UE111 MEASUREMENT IDENTITIES
    ${nr_rep_configs}   Set Variable   ${tmp2}[0]

    ${search1}   Set Variable   TimeToTrigger: ${a3TimeToTriggerSsbRsrp}, ReportOnLeave: false, EventA3
    ${search2}   Catenate   TimeToTrigger: ${a5TimeToTriggerSsbRsrp}, ReportOnLeave: false,
    ...   EventA5: threshold1=Threshold: RSRP ${a5Threshold1SsbRsrp} threshold2=Threshold: RSRP ${a5Threshold2SsbRsrp}
    ${search3}   Set Variable
    ...   TimeToTrigger: ${a2TimeToTriggerhoSsbRsrp}, ReportOnLeave: false, EventA2: Threshold: RSRP ${a2ThresholdhoSsbRsrp}
    ${search4}   Set Variable
    ...   TimeToTrigger: ${a2TimeToTriggerReleaseSsbRsrp}, ReportOnLeave: false, EventA2: Threshold: RSRP ${a2ThresholdReleaseSsbRsrp}

    FOR   ${search}   IN   ${search1}  ${search2}   ${search3}   ${search4}
        Verify String Present   ${nr_rep_configs}     ${search}
    END


Verify Meas Config After Handover TC05
    [Documentation]    [PRIVATE]    Verify Meas Config After Handover TC05
    ...       :Author: Sylvia Schneider
    Log To Console    \nVerify measurements after HO in file ${resultDir}/disp_meas_config_UE111_after_HO.txt
    ${scf_vrf}    XML.Parse Xml    ${resultDir}/SCF_final.xml
    Set Test Variable     ${scf_vrf}

    ${a3TimeToTriggerSsbRsrp}     Get A TimeToTrigger Parameter Value From IAF List   IAF=2   list=a3MeasSsbRsrp   param=a3TimeToTriggerSsbRsrp

    ${a5Threshold1SsbRsrp}        Get A Parameter Value From IAF List                 IAF=2   list=a5MeasSsbRsrp   param=a5Threshold1SsbRsrp
    ${a5Threshold2SsbRsrp}        Get A Parameter Value From IAF List                 IAF=2   list=a5MeasSsbRsrp   param=a5Threshold2SsbRsrp
    ${a5TimeToTriggerSsbRsrp}     Get A TimeToTrigger Parameter Value From IAF List   IAF=2   list=a5MeasSsbRsrp   param=a5TimeToTriggerSsbRsrp

    ${a2ThresholdReleaseSsbRsrp}      Get A Parameter Value From IAF List
    ...                               IAF=2  list=a2MeasReleaseSsbRsrp  param=a2ThresholdReleaseSsbRsrp
    ${a2TimeToTriggerReleaseSsbRsrp}  Get A TimeToTrigger Parameter Value From IAF List
    ...                               IAF=2  list=a2MeasReleaseSsbRsrp  param=a2TimeToTriggerReleaseSsbRsrp

    ${contents}    OperatingSystem.Get File         ${resultDir}/disp_meas_config_UE111_after_HO.txt
    ${tmp1}        String.Split String     ${contents}       DETAILED INFO ABOUT NR REPORT CONFIGURATIONS
    ${tmp2}        String.Split String     ${tmp1}[1]        UE111 MEASUREMENT IDENTITIES
    ${nr_rep_configs}   Set Variable   ${tmp2}[0]

    ${search1}   Set Variable   TimeToTrigger: ${a3TimeToTriggerSsbRsrp}, ReportOnLeave: false, EventA3
    ${search2}   Catenate   TimeToTrigger: ${a5TimeToTriggerSsbRsrp}, ReportOnLeave: false,
    ...   EventA5: threshold1=Threshold: RSRP ${a5Threshold1SsbRsrp} threshold2=Threshold: RSRP ${a5Threshold2SsbRsrp}
    ${search3}   Set Variable
    ...   TimeToTrigger: ${a2TimeToTriggerReleaseSsbRsrp}, ReportOnLeave: false, EventA2: Threshold: RSRP ${a2ThresholdReleaseSsbRsrp}

    FOR   ${search}   IN   ${search1}  ${search2}   ${search3}
        Verify String Present   ${nr_rep_configs}     ${search}
    END


Verify Meas Config After Handover TC04
    [Documentation]    [PRIVATE]    Verify Meas Config After Handover TC04
    ...       :Author: Sylvia Schneider
    Log To Console    \nVerify measurements after HO in file ${resultDir}/disp_meas_config_UE111_after_HO.txt
    ${scf_vrf}    XML.Parse Xml    ${resultDir}/SCF_final.xml
    Set Test Variable     ${scf_vrf}

    ${a3TimeToTriggerSsbRsrp}     Get A TimeToTrigger Parameter Value From IAF List   IAF=3   list=a3MeasSsbRsrp   param=a3TimeToTriggerSsbRsrp

    ${a5Threshold1SsbRsrp}        Get A Parameter Value From IAF List                 IAF=3   list=a5MeasSsbRsrp   param=a5Threshold1SsbRsrp
    ${a5Threshold2SsbRsrp}        Get A Parameter Value From IAF List                 IAF=3   list=a5MeasSsbRsrp   param=a5Threshold2SsbRsrp
    ${a5TimeToTriggerSsbRsrp}     Get A TimeToTrigger Parameter Value From IAF List   IAF=3   list=a5MeasSsbRsrp   param=a5TimeToTriggerSsbRsrp

    ${a2ThresholdhoSsbRsrp}       Get A Parameter Value From IAF List
    ...                           IAF=3  list=a2MeashoSsbRsrp  param=a2ThresholdhoSsbRsrp
    ${a2TimeToTriggerhoSsbRsrp}   Get A TimeToTrigger Parameter Value From IAF List
    ...                           IAF=3  list=a2MeashoSsbRsrp  param=a2TimeToTriggerhoSsbRsrp

    ${a2ThresholdReleaseSsbRsrp}      Get A Parameter Value From IAF List
    ...                               IAF=3  list=a2MeasReleaseSsbRsrp  param=a2ThresholdReleaseSsbRsrp
    ${a2TimeToTriggerReleaseSsbRsrp}  Get A TimeToTrigger Parameter Value From IAF List
    ...                               IAF=3  list=a2MeasReleaseSsbRsrp  param=a2TimeToTriggerReleaseSsbRsrp

    ${contents}    OperatingSystem.Get File         ${resultDir}/disp_meas_config_UE111_after_HO.txt
    ${tmp1}        String.Split String     ${contents}       DETAILED INFO ABOUT NR REPORT CONFIGURATIONS
    ${tmp2}        String.Split String     ${tmp1}[1]        UE111 MEASUREMENT IDENTITIES
    ${nr_rep_configs}   Set Variable   ${tmp2}[0]

    ${search1}   Set Variable   TimeToTrigger: ${a3TimeToTriggerSsbRsrp}, ReportOnLeave: false, EventA3
    ${search2}   Catenate   TimeToTrigger: ${a5TimeToTriggerSsbRsrp}, ReportOnLeave: false,
    ...   EventA5: threshold1=Threshold: RSRP ${a5Threshold1SsbRsrp} threshold2=Threshold: RSRP ${a5Threshold2SsbRsrp}
    ${search3}   Set Variable
    ...   TimeToTrigger: ${a2TimeToTriggerhoSsbRsrp}, ReportOnLeave: false, EventA2: Threshold: RSRP ${a2ThresholdhoSsbRsrp}
    ${search4}   Set Variable
    ...   TimeToTrigger: ${a2TimeToTriggerReleaseSsbRsrp}, ReportOnLeave: false, EventA2: Threshold: RSRP ${a2ThresholdReleaseSsbRsrp}

    FOR   ${search}   IN   ${search1}  ${search2}   ${search3}   ${search4}
        Verify String Present   ${nr_rep_configs}     ${search}
    END


Verify Throughput After Handover
    [Documentation]    [PRIVATE]    Verify Throughput After Handover
    ...       :Author: Sylvia Schneider
    Log To Console    \nVerify throughput after Handover
    FOR   ${file}   ${ue_id}  ${expected_throughput}   IN
    ...   pdsch     111       2
    ...   pusch     111       2
        Log To Console    \nVerify file egate_throughput_${file}_ue${ue_id}.txt
        ${contents}    OperatingSystem.Get File           ${resultDir}/egate_throughput_${file}_ue${ue_id}.txt
        ${line}      String.Get Lines Containing String     ${contents}     1 cell
        @{temp}      String.Split String                    ${line}
        ${average_throughput}   Set Variable   ${temp}[2]
        Log To Console    Verify that average_throughput ${average_throughput} > expected value ${expected_throughput}
        TRY
              Should Be True   ${average_throughput} > ${expected_throughput}
        EXCEPT
              Fail    failed average_throughput ${average_throughput} > expected value ${expected_throughput}
        END
    END
