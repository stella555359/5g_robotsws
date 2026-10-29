*** Settings ***
Library     BuiltIn
Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME   csn

Resource    COAM.robot

Resource    ../../common/taf_coam.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Variables   ../../libraries/global_vars.py

*** Variables ***
@{counter_id_list}   M40002C0   M40002C1   M40002C2
...   M40003C0   M40003C1   M40003C2   M40003C3   M40003C4   M40003C5
...   M40004C0   M40004C1   M40004C2   M40004C3   M40004C4   M40004C5

*** Keywords ***
Common Setup
    Log To Console   ${EMPTY}
    Set Suite Variable   ${MRBTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable   ${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}
    Set Suite Variable   ${MRBTS}   MRBTS-${MRBTS_ID}
    Set Suite Variable   ${NRBTS}   NRBTS-${NRBTS_ID}
    Set Suite Variable   ${INSID}   ${MRBTS}/${NRBTS}
    # Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    # Wait Until Keyword Succeeds   5m   1m   COAM Login
    # Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
    COAM Login
    COAM Backup Full SCF
    Get ALL Suite Variables
    Initialize Power Meter Releated Parameters
    Sleep   16m
    # ${status}   Run Keyword And Return Status   Get Power Meter Releated Counters
    # Run Keyword If   ${status}   Sleep   16m
    # ...   ELSE   Sleep   32m

Common Teardown
    Run Keyword And Ignore Error   COAM Logout

Get ALL Suite Variables
    ${local_xml}   XML.Parse XML   ${OUTPUT_DIR}/full_commission.xml
    @{RMOD_ID_LIST}   Create List
    ${rmods_eles}   Get Elements   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:RMOD"]
    FOR   ${rmod_ele}   IN   @{rmods_eles}
        ${rmod}   Get Element Attribute   ${rmod_ele}   distName
        Append To List   ${RMOD_ID_LIST}   ${rmod.split('/')[-1]}
    END
    Set Suite Variable   ${RMOD_ID_LIST}

    @{SMOD_ID_LIST}   Create List
    ${smods_eles}   Get Elements   ${local_xml}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:SMOD"]
    FOR   ${smod_ele}   IN   @{smods_eles}
        ${smod}   Get Element Attribute   ${smod_ele}   distName
        Append To List   ${SMOD_ID_LIST}   ${smod.split('/')[-1]}
    END
    Set Suite Variable   ${SMOD_ID_LIST}
