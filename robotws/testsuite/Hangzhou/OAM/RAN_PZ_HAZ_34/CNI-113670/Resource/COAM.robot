*** Settings ***
Documentation
...    Author: yin.4.chen@nokia-sbell.com
...    Feature CNI-113670 Automation

Resource   Common.robot

*** Keywords ***
Check DFE Failure Fault
    [Arguments]   ${check_fault_list}=@{EMPTY}
    COAM Login
    ${active_alarms}   coam.get_active_alarms   connection=COAM   timeout=10
    @{active_fault_list}   Create List
    FOR   ${active_alarm}   IN   @{active_alarms}
        ${faultId}   Get Variable Value   ${active_alarm['faultId']}   ${EMPTY}
        Continue For Loop If   "${faultId}"=="${EMPTY}"
        Append To List   ${active_fault_list}   ${faultId}
    END
    List Should Contain Sub List   ${active_fault_list}   ${check_fault_list}
    [Return]   ${active_fault_list}
    [Teardown]   COAM Logout


Check DFE Failure Fault Severity
    [Arguments]   ${check_fault_id}   ${check_fault_severity}
    COAM Login
    ${active_alarms}   coam.get_active_alarms   connection=COAM   timeout=10
    FOR   ${active_alarm}   IN   @{active_alarms}
        ${faultId}   Get Variable Value   ${active_alarm['faultId']}   ${EMPTY}
        ${severity}   Get Variable Value   ${active_alarm['severity']}   ${EMPTY}
        Continue For Loop If   "${faultId}"=="${EMPTY}" or "${faultId}"!="${check_fault_id}"

        Should Be Equal   ${severity}   ${check_fault_severity}
    END
    [Teardown]   COAM Logout



# ==================================================================================================================================================
# ==================================================================================================================================================
# ==================================================================================================================================================
Check Ongoing RMOD Status
    COAM Login
    ${hw_info}   coam.get_detected_hw_info   connection=COAM

    ${rmod_list}   Get Variable Value   ${hw_info["radioModules"]["rmod"]}
    FOR   ${rmod_info}   IN   @{rmod_list}
        ${rmod_sn}   Get Variable Value   ${rmod_info["serialNumber"]}
        Continue For Loop If   "${rmod_sn}"!="${RANDOM_AEHC["ru_serial"]}"

        ${rmod_status}   Get Variable Value   ${rmod_info["status"]}

        ${administrativeState}   Get Variable Value   ${rmod_status["administrativeState"]}
        ${availabilityStatus}   Get Variable Value   ${rmod_status["availabilityStatus"]}
        ${operationalState}   Get Variable Value   ${rmod_status["operationalState"]}
        ${usageState}   Get Variable Value   ${rmod_status["usageState"]}
        ${proceduralStatus}   Get Variable Value   ${rmod_status["proceduralStatus"]}

        Should Not Be Equal   ${availabilityStatus.lower()}   degraded
        Should Not Be Equal   ${availabilityStatus.lower()}   failed
    END
    [Teardown]   COAM Logout


Check Ongoing Active Fault
    COAM Login
    ${active_alarms}   coam.get_active_alarms   connection=COAM   timeout=10
    @{active_fault_list}   Create List
    FOR   ${active_alarm}   IN   @{active_alarms}
        ${faultId}   Get Variable Value   ${active_alarm['faultId']}   ${EMPTY}
        Continue For Loop If   "${faultId}"=="${EMPTY}"
        Append To List   ${active_fault_list}   ${faultId}
    END
    List Should Not Contain Value   ${active_fault_list}   ${2934}
    List Should Not Contain Value   ${active_fault_list}   ${2935}
    [Teardown]   COAM Logout


# ==================================================================================================================================================
# ==================================================================================================================================================
# ==================================================================================================================================================
COAM ADMIN Check RMOD Degraded
    COAM Login
    ${hw_info}   coam.get_detected_hw_info   connection=COAM

    ${rmod_list}   Get Variable Value   ${hw_info["radioModules"]["rmod"]}
    FOR   ${rmod_info}   IN   @{rmod_list}
        ${rmod_sn}   Get Variable Value   ${rmod_info["serialNumber"]}
        Continue For Loop If   "${rmod_sn}"!="${RANDOM_AEHC["ru_serial"]}"

        ${rmod_status}   Get Variable Value   ${rmod_info["status"]}

        ${administrativeState}   Get Variable Value   ${rmod_status["administrativeState"]}
        ${availabilityStatus}   Get Variable Value   ${rmod_status["availabilityStatus"]}
        ${operationalState}   Get Variable Value   ${rmod_status["operationalState"]}
        ${usageState}   Get Variable Value   ${rmod_status["usageState"]}
        ${proceduralStatus}   Get Variable Value   ${rmod_status["proceduralStatus"]}

        Should Be Equal   ${availabilityStatus.lower()}   degraded
    END
    [Teardown]   COAM Logout


COAM ADMIN Check RMOD Failed
    COAM Login
    ${hw_info}   coam.get_detected_hw_info   connection=COAM

    ${rmod_list}   Get Variable Value   ${hw_info["radioModules"]["rmod"]}
    FOR   ${rmod_info}   IN   @{rmod_list}
        ${rmod_sn}   Get Variable Value   ${rmod_info["serialNumber"]}
        Continue For Loop If   "${rmod_sn}"!="${RANDOM_AEHC["ru_serial"]}"

        ${rmod_status}   Get Variable Value   ${rmod_info["status"]}

        ${administrativeState}   Get Variable Value   ${rmod_status["administrativeState"]}
        ${availabilityStatus}   Get Variable Value   ${rmod_status["availabilityStatus"]}
        ${operationalState}   Get Variable Value   ${rmod_status["operationalState"]}
        ${usageState}   Get Variable Value   ${rmod_status["usageState"]}
        ${proceduralStatus}   Get Variable Value   ${rmod_status["proceduralStatus"]}

        Should Be Equal   ${availabilityStatus.lower()}   failed
    END
    [Teardown]   COAM Logout



# ==================================================================================================================================================
# ==================================================================================================================================================
# ==================================================================================================================================================
COAM ADMIN Check Cell Degraded
    [Arguments]   ${cell_dn_list}=@{AEHC_CELL_DN_LIST}
    COAM Login

    ${cell_list}   coam.get_cells_info   cell_type=nr   connection=COAM

    FOR   ${cell}   IN   @{cell_list}
        ${cell_dn}   Set Variable   ${cell["id"]["configuration"]}
        Continue For Loop If   "${cell_dn}" not in ${cell_dn_list}

        ${operationalState}         Get Variable Value   ${cell['status']['operationalState']}      N/A
        ${usageState}               Get Variable Value   ${cell['status']['usageState']}            N/A
        ${proceduralStatus}         Get Variable Value   ${cell['status']['proceduralStatus']}      N/A
        ${administrativeState}      Get Variable Value   ${cell['status']['administrativeState']}   N/A
        ${availabilityStatus}       Get Variable Value   ${cell['status']['availabilityStatus']}    N/A

        Run Keyword If   "${operationalState}"!="N/A"
        ...   Should Be Equal   ${operationalState.lower()}         enabled
        # # Sometimes usageState=Idle
        Run Keyword If   "${usageState}"!="N/A"
        ...   Should Be Equal   ${usageState.lower()}               active
        Run Keyword If   "${proceduralStatus}"!="N/A"
        ...   Should Be Equal   ${proceduralStatus.lower()}         configured
        Run Keyword If   "${administrativeState}"!="N/A"
        ...   Should Be Equal   ${administrativeState.lower()}      unlocked
        Should Be Equal   ${availabilityStatus.lower()}             degraded
    END
    [Teardown]   COAM Logout


COAM ADMIN Check Cell Failed
    [Arguments]   ${cell_dn_list}=@{AEHC_CELL_DN_LIST}
    COAM Login
    ${cell_list}   coam.get_cells_info   cell_type=nr   connection=COAM
    FOR   ${cell}   IN   @{cell_list}
        ${cell_dn}   Set Variable   ${cell["id"]["configuration"]}
        Continue For Loop If   "${cell_dn}" not in ${cell_dn_list}

        ${operationalState}         Get Variable Value   ${cell['status']['operationalState']}      N/A
        ${usageState}               Get Variable Value   ${cell['status']['usageState']}            N/A
        ${proceduralStatus}         Get Variable Value   ${cell['status']['proceduralStatus']}      N/A
        ${administrativeState}      Get Variable Value   ${cell['status']['administrativeState']}   N/A
        ${availabilityStatus}       Get Variable Value   ${cell['status']['availabilityStatus']}    N/A
        Should Be Equal   ${availabilityStatus.lower()}   failed
    END
    [Teardown]   COAM Logout


COAM ADMIN Check Cell Onair
    COAM Login
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=${60}
    ${cell_info}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['cells']}
    ...   ELSE   Set Variable   ${bts_info['cells']}
    ${cell_list}   Get Dictionary Values   ${cell_info}
    ${cell_list}   Evaluate   [item for sublist in ${cell_list} for item in sublist]

    FOR   ${cell}   IN   @{cell_list}
        ${operationalState}         Get Variable Value   ${cell['status']['operationalState']}      N/A
        ${usageState}               Get Variable Value   ${cell['status']['usageState']}            N/A
        ${proceduralStatus}         Get Variable Value   ${cell['status']['proceduralStatus']}      N/A
        ${administrativeState}      Get Variable Value   ${cell['status']['administrativeState']}   N/A
        ${availabilityStatus}       Get Variable Value   ${cell['status']['availabilityStatus']}    N/A

        Run Keyword If   "${operationalState}"!="N/A"
        ...   Should Be Equal   ${operationalState.lower()}       enabled
        # # Sometimes usageState=Idle
        Run Keyword If   "${usageState}"!="N/A"
        ...   Should Be Equal   ${usageState.lower()}             active
        Run Keyword If   "${proceduralStatus}"!="N/A"
        ...   Should Be Equal   ${proceduralStatus.lower()}       configured
        Run Keyword If   "${administrativeState}"!="N/A"
        ...   Should Be Equal   ${administrativeState.lower()}    unlocked
        Run Keyword If   "${availabilityStatus}"!="N/A"
        ...   Should Not Be Equal   ${availabilityStatus.lower()}   degraded
    END
    [Teardown]   COAM Logout



# ==================================================================================================================================================
# ==================================================================================================================================================
# ==================================================================================================================================================
Get RMOD DN
    [Arguments]   ${scf_path}=${OUTPUT_DIR}/full_commission.xml
    ${scf_xml}   XML.Parse XML   ${scf_path}
    ${rmod_r}   XML.Get Element   ${scf_xml}
    ...   xpath=cmData/managedObject[@class="com.nokia.srbts.eqmr:RMOD_R"]/p[@name="serialNumber" and text()="${RANDOM_AEHC["ru_serial"]}"]/..
    ${AEHC_RMOD_DN}   XML.Get Element Text   ${rmod_r}   p[@name="configDN"]
    ${AEHC_RMOD_DN}   Should Match Regexp   ${AEHC_RMOD_DN}   MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/RMOD-\\d+
    Log To Console   ${AEHC_RMOD_DN}
    Set Suite Variable   ${AEHC_RMOD_DN}


Get Cell DN List
    [Arguments]   ${scf_path}=${OUTPUT_DIR}/full_commission.xml
    ${scf_xml}   XML.Parse XML   ${scf_path}
    ${MRBTS_DN}   Get Element Attribute   ${scf_xml}   name=distName   xpath=cmData/managedObject[@class="com.nokia.srbts:MRBTS"]

    @{lcelnr_elem_list}   Get Elements   ${scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:LCELNR"]
    FOR   ${lcelnr_elem}   IN   @{lcelnr_elem_list}
        ${lcelnr_dn}   Get Element Attribute   ${lcelnr_elem}   name=distName   xpath=.
    END

    @{AEHC_CELL_DN_LIST}   Create List
    @{nrcell_elem_list}   Get Elements   ${scf_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    FOR   ${nrcell_elem}   IN   @{nrcell_elem_list}
        ${nrcell_dn}   Get Element Attribute   ${nrcell_elem}   name=distName   xpath=.
        ${lcelnr_id}   Get Element Text   ${nrcell_elem}   xpath=p[@name="lcrId"]
        ${lcelnr_dn}   Set Variable   ${MRBTS_DN}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcelnr_id}

        @{rmod_dn_list}   Get RMOD From LCELNR   lcelnr_dn=${lcelnr_dn}
        Run Keyword If   "${AEHC_RMOD_DN}" in ${rmod_dn_list}   Append To List   ${AEHC_CELL_DN_LIST}   ${nrcell_dn}
    END
    Log To Console   ${AEHC_CELL_DN_LIST}
    Set Suite Variable   ${AEHC_CELL_DN_LIST}


Get RMOD From LCELNR
    [Arguments]   ${lcelnr_dn}   ${scf_path}=${OUTPUT_DIR}/full_commission.xml

    ${scf_xml}   XML.Parse XML   ${scf_path}
    @{channel_elem_list}   XML.Get Elements   ${scf_xml}
    ...   xpath=cmData/managedObject[contains(@distName, "${lcelnr_dn}/") and @class="com.nokia.srbts.mnl:CHANNEL"]
    @{rmod_dn_list}   Create List
    FOR   ${channel_elem}   IN   @{channel_elem_list}
        ${resourceDN_exist}   ${resourceDN}   Run Keyword And Ignore Error   XML.Get Element Text   ${channel_elem}   xpath=p[@name="resourceDN"]
        ${antlDN_exist}   ${antlDN}   Run Keyword And Ignore Error   XML.Get Element Text   ${channel_elem}   xpath=p[@name="antlDN"]

        ${check_dn}   Set Variable If
        ...   "${resourceDN_exist}"=="PASS"   ${resourceDN}
        ...   "${antlDN_exist}"=="PASS"   ${antlDN}

        ${rmod_dn}   Get Regexp Matches   ${check_dn}   MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/RMOD-\\d+   0
        Append To List   ${rmod_dn_list}   ${rmod_dn[0]}
    END
    ${rmod_dn_list}   Remove Duplicates   ${rmod_dn_list}
    [Return]   ${rmod_dn_list}

