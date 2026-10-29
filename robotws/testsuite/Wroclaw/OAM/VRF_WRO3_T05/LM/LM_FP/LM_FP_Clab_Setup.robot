*** Settings ***
Documentation    OAM_changer
          ...  = Author =
          ...    _maciej.ferus@nokia.com_
          ...  = Maintainer =
          ...    _jacek.rolla@nokia.com_
          ...  = Summary =
          ...   We're currently using external tool to get netact name for ENB software version
          ...   but we're using our data for integration, since given dict is not enough for our needs.
          ...   Also, there is no assurance that keyword will return anything.
          ...   If tool checking is needed set ${use_tool} as True, else set as False
          ...   If external tools fails,
          ...   hardcoded variables will be used: ${hardcoded_lab}, ${branch_lab} and ${trunk_lab}
          ...   to determine to which netact oam_changer should connect machine that we're running test on.
          ...   Some variables are mutually exclusive:
          ...     By default test use ${branch_lab} and ${trunk_lab}.
          ...     If ${hardcoded_lab} is defined as not None value, it's using this variable by default.
          ...     If it's not, test is deciding whether software is branch, or trunk, and choose
          ...     ${branch_lab} or ${trunk_lab}.
          ...     So, it's mandatory to set ${hardcoded_lab} or ${branch_lab} and ${trunk_lab}.
          ...
          ...   Before you change variable to choosen netact, check if it can be found in dictionary
          ...   created by Set NetAct Dict keyword. If it's not there, under given keyword create dict like:
          ...   ${labXYZ}=    Create Dictionary    virtual_south=${ip}    mr=${mr}    agent_address=${agent_address}
          ...   where:
          ...     - ${ip} is BTSMED South IP
          ...     - ${mr} (optional) is value that can be found on netact site:
          ...        NE Integration Wizard -> New/Edit record -> MR
          ...        By default its: MRC-BTSMED/MR-BTSMED
          ...     - ${agent_address} (optional) is value that can be found on netact site:
          ...        NE Integration Wizard -> New/Edit record -> MRBTS address
          ...        By default its: mrbts-${ENB_ID}
          ...    then add dict to:
          ...    ${netact_oam_dictionary}
          ...    like:
          ...      labXYZ=${labXYZ}
          ...
          ...    Also, OAM_Changer it's probably used right now for purposes like:
          ...     - single runs for stabi or crt,
          ...     - night runs for crt,
          ...    So if YOU need to change netact OAM on your ENB to netact not defined under ${X_lab} variables
          ...    then change variable, but don't commit it to SVN. It might waste a lot of time for someone else.
          ...    If you're in dire need of commiting such changes to SVN, please contact:
          ...    maciej.ferus@nokia.com or damian.swierzewski.ext@nokia.com
          ...
          ...   = Steps =
          ...     - Get required ${hardcoded_lab} BTSMED south IP
          ...     - Determin whether change is needed, then change IP on enb or abort
          ...     - Integrate enb to netact (currently we don't have any way of checking whether enb is integrated)
          ...
          ...  = Pre - requirements =
          ...    - An eNB is onAir before test
          ...    - NetAct is working and is accessible from workstation
          ...
          ...    - ${hardcoded_lab} is defined
          ...    OR:
          ...    - ${branch_lab} and ${trunk_lab} are defined
          ...  = Additional info =
          ...    N/A


Library         Collections
Library         DateTime
Library         OperatingSystem
Library         Process
Library         SSHLibrary
Library         String
Library         XML    use_lxml=True
Library         ute_admin
Library         ute_admin_infomodel
Library         taf.nms.netact
Resource        ../LM_resources/lib_SFE.robot

Suite Setup  Run Keywords     Setup NMS    ${NMS_LAB}   AND
...                           Suite Setup Infomodel    im_port=443    AND
...                           Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=443    use_ssl=True    timeout=90s    AND
...                           Get And Set Enb Parameters    AND
...                           Get And Set Netact Parameters SRAN     AND
...                           Add Node    service_name=cmwas    hostname=${NA_WAS}    username=${NA_USER}    password=${NA_PASS}   AND
...                           Add Node    service_name=fmwas    hostname=${NA_WAS}    username=${NA_USER}    password=${NA_PASS}   AND
...                           Add web url    web_url=${WEB_URL}    username=${NA_USER}    password=${NA_PASS}   AND
...                           Decide Which Lab To Use    AND
...                           Set NetAct Dict

Suite Teardown  Run Keywords    Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Provision Plan
                                ...    plan_name=${ENB_ID}_full_backup    AND
...                             Teardown Infomodel    AND
...                             Teardown Admin    AND
...                             Delete Node    cmwas         AND
...                             Delete Node    fmwas         AND
...                             Clean All

*** Variables ***
${NMS_LAB}          srnclab2009
${ENB_ROOT_USER}    toor4nsn
${ENB_ROOT_PASS}    oZPS0POrRieRtu
${use_tool}         False
${btsmed_number}     2

*** Test Cases ***
Check OAM IP
    [Documentation]    Change oam to appropriate
    ${oam_ip}=    Get Required OAM IP
#    ${if_need_to_change}=    Check If OAM IP needs to be changed    ${oam_ip}
#    Run Keyword If    ${if_need_to_change}    Change OAM    ${oam_ip}
#    ...       ELSE                            Log    Changing OAM is not required    console=true

Integrate ENB
    [Documentation]    Integrate enb ${ENB_ID} with ${hardcoded_lab}
    ${mr}=    Get MR Instance
    ${status}  ${agent_address_from_dict}=    run keyword and ignore error    Get From Dictionary    ${netact_dict}    agent_address
    Wait Until keyword Succeeds    5x    1min    Integrate MRBTS With NetAct    release=${ENB_RELEASE}    mr=${mr}
    ...      mrbts_address=${ENB_MPLANE_IP}   dist_name=PLMN-PLMN/MRBTS-${ENB_ID}     security_mode=no TLS

Wait Until CM Upload works
    [Documentation]     Wait until enb is integrated
 #    Sleep    15 min
     Sleep    2 min
     Wait Until Keyword Succeeds    15x    1min    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}
    ...     parameters=None    verbose=True    schedule=None    ignore_errors=False    timeout=7200    # zwykĹ‚y CM UPLOAD
     Run Keyword and ignore error    Upload Alarms    dist_name=PLMN-PLMN/MRBTS-${ENB_ID}

*** Keywords ***
Decide Which Lab To Use
    [Documentation]    Decide which lab to use based on software
    ${software_version}=    Get Active Sw Version
    Set Suite Variable    ${software_version}
    Check FSM
    ${status_Netact_flat}     Run Keyword And Return Status  Variable Should Exist    ${Netact_flat}
    ${proper_netact_lab}    Run Keyword If     '${status_Netact_flat}' == 'True'    get netact by name     ${Netact_flat}
    ...    ELSE      Get enb Connected to Flat Netacts    ${ENB_RELEASE}
    ${netact_name}=    Get From Dictionary    ${proper_netact_lab}     netact_name
    Set Suite Variable    ${netact_name}    ${netact_name}
    Log    Chosen MetAct: ${netact_name}  console=True

Check FSM
    ${if_trunk}=    Set Variable If
    ...          "_0000_" in "${software_version}"    ${False}
    ...          "_9999_" in "${software_version}"    ${True}
    ...          "_ENB_" in "${software_version}"    ${False}
    Set Suite Variable    ${if_trunk}

Set Proper Lab Based On Software
    Run Keyword If
    ...               not ${if_trunk}    Set Suite Variable    ${hardcoded_lab}    ${branch_lab}
    ...    ELSE IF    ${if_trunk}        Set Suite Variable    ${hardcoded_lab}    ${trunk_lab}

Set NetAct Dict
    [Documentation]    Set netact dict for suite use
    ${netact_dict}=    Get Netacts For Software Release    ${if_trunk}    ${ENB_RELEASE}
    ${selected_netact_dict}=    Get From Dictionary    ${netact_dict}    ${netact_name}
    Set Suite Variable    ${netact_dict}    ${selected_netact_dict}

Get Required OAM IP
    [Documentation]    Get OAM IP
    ${oam_ip}=    Get From Dictionary    ${netact_dict}    virtual_south
    [Return]    ${oam_ip}

Get MR Instance
    [Documentation]    Get MR instance of given netact
    ${mr_instance_from_dict}=    Run Keyword and Return Status    Get From Dictionary    ${netact_dict}    mr
    ${mr_instance}=    Run Keyword If    ${mr_instance_from_dict}    Get From Dictionary    ${netact_dict}    mr
    ...                ELSE    Set Variable    MRC-COMMON/MR-COMMON
    [Return]    ${mr_instance}

Change OAM
    [Documentation]    Change oam to given and force this oam
    [Arguments]    ${oam_ip}
    Log    ${\n}Changing OAM IP to: ${oam_ip}    console=true
    Run Keyword If    '${EMPTY}'!='${oam_ip}'    Perform Parameter Recommissioning    MRBTS-${ENB_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...    oamPeerIpAddress    update    ${oam_ip}    skip_parameter_relation_errors=True
    Run Keyword If    '${EMPTY}'=='${oam_ip}'    Perform Parameter Recommissioning    MRBTS-${ENB_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...    oamPeerIpAddress    delete    ${oam_ip}    skip_parameter_relation_errors=True


Check If OAM IP needs to be changed
    [Arguments]    ${oam_ip}
    ${current_oam_ip}=    Get Parameter From Infomodel    /MRBTS-1/RAT-1/BTS_L-${ENB_SIDE}//MPLANENW_A-1    oamPeerIpAddress
    ${if_need_to_change}=    Run Keyword And Return Status    Should Not Be Equal As Strings    ${oam_ip}    ${current_oam_ip}
    Log    ${\n}Current OAM IP: ${current_oam_ip}    console=true
    [Return]    ${if_need_to_change}