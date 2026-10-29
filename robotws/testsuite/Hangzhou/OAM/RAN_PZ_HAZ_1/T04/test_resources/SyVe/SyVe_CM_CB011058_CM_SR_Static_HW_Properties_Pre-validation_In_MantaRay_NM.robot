*** Settings ***
Documentation       Test suite for NFTA SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
#${SCF_File}     /home/ute/Downloads/37376.xml
#${plannedSWReleaseVersion}    SBTS25R2_ENB_0000_000001_000000     #if not empty, will add plannedSWReleaseVersion in scf,if empty need manual
                                                    # add plannedSWReleaseVersion in scf and need same as current site version.
${SRNCLAB}      SRNCLAB1016    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_CB011058_CM_SR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    RAN_ST_CB012523-B_003_Disable feature after cell is disable due to feature enable
    ...    RAN_ST_CNI-131432_005_Cell is not impact with feature disable when NMS link disconnect
    ...    Precondition: manual set corresponding AoM parameter:miNrCellAvailability as 5min
    ...    The main steps performed for the test are:
    ...
    ...
    ...    Pass criteria: operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.10.2025
    ...    *******************
    ...    Test case flowchart
    ...    *******************

    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Convert SCF To NetAct Model
    Step 5: Check Builds Exist In NetAct
    Step 6: Pre_Validate Plan
    Step 7: Check final alarms status from Netact
    Step 8: Check final BTS state
    Step 9: Check final number and state of Cells and RMs

Step ${index}: Convert SCF To NetAct Model
    Log To Console    Step ${index}: Convert SCF To NetAct Model
    #Set Test Variable    ${mrbts_id}    37376     #if need test non LMP bts
    ${SCF_File_Modifed}    Add PlannedSWReleaseVersion And Recommission    ${active SW version}    ${BTS_scf_initial}
    ${file_name}    Fetch From Right    ${SCF_File_Modifed}    /
    ${file_path}    Fetch From Left    ${SCF_File_Modifed}    ${file_name}
    ${time}    Get Time    epoch
    Set Test Variable    ${plan_name}    CB011085_TA_case_SR_plan_${time}
    ${status}=    Run Keyword And Return Status    netact.Import SCF   local_dir=${file_path}
    ...    file_name=${file_name}    plan_name=${plan_name}


Add PlannedSWReleaseVersion And Recommission
    [Arguments]    ${plannedSW}    ${scf_file}
    ${file_name}    Fetch From Right    ${scf_file}    /
    ${file_path}    Fetch From Left    ${scf_file}    ${file_name}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${scf_file}

    ${mo_dn}    Set Variable    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNBTS_FDD-0
    ${param}    Set Variable    actFlexBbUsage
    L_XML.Set Element Text    ${scf_xml}    true    \r\n
        ...    cmData/managedObject[@distName="${mo_dn}"]/p[@name="${param}"]
    ${elements_for_lncell}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="NOKLTE:LNCEL_FDD"]
    FOR    ${element}    IN    @{elements_for_lncell}
        L_XML.Set Element Text    ${element}    420    \r\n
        ...    p[@name="maxNumActUE"]
    END
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="com.nokia.srbts.mnl:MNL"]/p[@name="plannedSWReleaseVersion"]
    ...    remove_tail=${True}
    L_XML.Add Element    ${scf_xml}    <p name="plannedSWReleaseVersion"/>    xpath=cmData/managedObject[@distName="MRBTS-${mrbts_id}/MNL-1"]
    L_XML.Set Element Text    ${scf_xml}    ${plannedSW}    \r\n
    ...    cmData/managedObject[@distName="MRBTS-${mrbts_id}/MNL-1"]/p[@name="plannedSWReleaseVersion"]
    L_XML.Save XML    ${scf_xml}    ${file_path}modifed_${file_name}
    ${file_content}    OperatingSystem.Get File    ${file_path}modifed_${file_name}
    ${file_content}    Replace String    ${file_content}    \&\#13;    ${EMPTY}
    ${parsed_xml}    XML.Parse XML    ${file_content}
    XML.Save Xml    ${parsed_xml}    ${file_path}modifed_${file_name}
    [Return]    ${file_path}modifed_${file_name}

Step ${index}: Check Builds Exist In NetAct
    Log To Console    Step ${index}: Check Builds Exist In NetAct
    ${build_exist}    netact.Is Imported    ${active SW version}
    Return From Keyword If    ${build_exist}
    ${sub_build}    Fetch From Right    ${active SW version}     ENB_    #SBTS25R2_ENB_9999_250107_000001
    ${head_build}    Fetch From Left    ${active SW version}    _ENB_${sub_build}
    ${target_sw_name}    Set Variable If    "${Trunk_Prefix}"=="${head_build}"    SBTS00_ENB_${sub_build}    ${active SW version}
    ${head_build_download}    Set Variable If    "${Trunk_Prefix}"=="${head_build}"    SBTS00    ${head_build}
    Download SBTS SW Build    ${target_sw_name}    /home/ute/Downloads/CB011058    ${head_build_download}
    ${ret}    OperatingSystem.File Should Exist    /home/ute/Downloads/CB011058/${target_sw_name}.zip
    OperatingSystem.Run And Return Rc And Output
    ...    mv /home/ute/Downloads/CB011058/${target_sw_name}.zip /home/ute/Downloads/CB011058/${active SW version}.zip
    Import SBTS SW Build To NetAct    ${active SW version}    /home/ute/Downloads/CB011058

Step ${index}: Pre_Validate Plan
    Log To Console    Step ${index}: Pre_Validate Plan
    ${status}    ${out}    Run Keyword And Ignore Error    netact.prevalidate_plan    plan_name=${plan_name}    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}
    Log To Console    ${out}
    Should Be Equal As Strings    ${status}    FAIL
    Should Contain    ${out}
    ...    It is required that LNBTS_FDD-0.actFlexBbUsage (value: true) is equal to false if only AirScale deployment or (AirScale+FSMr3)

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log To Console    Step ${index}: Check ${when} BTS state
    Wait Until Keyword Succeeds    5 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF
    Return From Keyword If    '${when}'!='initial'

Step ${index}: Check ${when} alarms status from WebEM
    Log To Console    Step ${index}: Check ${when} alarms status from WebEM
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log To Console    Step ${index}: Check ${when} alarms status from Netact
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log To Console    Step ${index}: Check final number and state of Cells and RMs
    Final Checks SyVe

TC Setup
    Log To Console    TC Setup
    Common Test Setup

TC Teardown
    Log To Console    TC Teardown
    Common Test Teardown


