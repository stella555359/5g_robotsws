*** Settings ***
Documentation
...   Robot resource to handle initial commissiong with sw upgrade from Cloud Manager.
...   author: Abderrahmane NEZROUK
...   contact: abderrahmane.nezrouk@nokia.com
...   Adding of optional keyword wich can be used with skip agent option under cloud Manger
...   to skip initial commissioning if need it.
...   to skip commissioning please add the robot variable ${skip_init_commissioning}
...   Allowed value to skip commissionning are True, Yes, Oui, true, yes, oui
...   Sample:  -v skip_init_commissioning:yes

Library     OperatingSystem
Library     String
Library     taf.rfrl.common_resources.python.SWConfig  WITH NAME  SWConfig
Library     taf.rfrl.utilities.tl_config
Library     taf.rfrl.bts.commissioning
Library     py/radParams_handler.py        WITH NAME   radParams
Resource    taf/rfrl/bts/robot/gnb.robot


*** Variables ***
${ENB_BUILD}
${CONFIGURATION}
${ENB_BRANCH}
@{ALLOWED_ARG}    True    Yes    Oui    true    yes    oui


*** Keywords ***
Update gNB Software To Current Build Candidate
    # When dealing with cloud, set flag by_nominal to True
    # check if package is already downloaded by agent 5G classical
    ${sw_package_path}=  Set Variable  %{HOME}/.ute-ca/cache/bts/${ENB_BUILD}/${ENB_BUILD}_release_BTSSM_downloadable.zip
    ${file_not_exist}  Run keyword and return status  File Should Not Exist  ${sw_package_path}
    ${sw_package_path}  Run Keyword If  ${file_not_exist}  Download SW Package  sw_version=${ENB_BUILD}
    ...                 ELSE                               Set Variable  ${sw_package_path}
    Update gNB Software     sw_package_dir=${sw_package_path}     timeout=1800

Full Commissioning Upgrade and OnAir Check
    [Arguments]     ${bts_id}=${0}     ${prefix_tag}=${EMPTY}
	 Set BTSLog IP Port SWConfig and Upload it on Classical gNB    bts_id=${bts_id}     prefix_tag=${prefix_tag}
     Run Keyword and Ignore Error    Perform Full Commissioning on Classical gNB    bts_id=${bts_id}     prefix_tag=${prefix_tag}
     Update gNB Software To Current Build Candidate
     Wait For Site To Be Onair

Full Commissioning and OnAir Check
    [Arguments]     ${bts_id}=${0}     ${prefix_tag}=${EMPTY}
     ${skip_init_commissioning}=    Get Variable Value    ${skip_init_commissioning}    False
     run keyword if   '${skip_init_commissioning}' not in ${ALLOWED_ARG}  run keywords
     ...         Set BTSLog IP Port SWConfig and Upload it on Classical gNB    bts_id=${bts_id}     prefix_tag=${prefix_tag}    AND
	 ...         Perform Full Commissioning on Classical gNB    bts_id=${bts_id}    prefix_tag=${prefix_tag}    AND
     ...         Wait For Site To Be Onair
     ...    ELSE
     ...         Set BTSLog Rad Parameters on Classical gNB

Set BTSLog IP Port SWConfig and Upload it on Classical gNB
    [Documentation]    This keyword will set swconfig BTSLog IP and Port params locally on test PC
    ...                and upload it on classical gNB depend if the test is run on UTE VM or localser VM
    [Arguments]   ${bts_id}=${0}  ${prefix_tag}=${EMPTY}

    ${sw_filename}=  Set Variable If  '${prefix_tag}'=='${EMPTY}'  GNB${bts_id}_swconfig.txt
    ...                                                            ${prefix_tag}_GNB${bts_id}_swconfig.txt
    ${config_path}=  Replace String  ${CONFIGURATION}  .  /
    ${sw_path}=  join path  ${CURDIR}
    ...                     ../../../../../commissionings/
    ...                     ${config_path}
    ...                     ${ENB_BRANCH}
    ...                     ${sw_filename}
    ${0x10042}=  Set Variable If
    ...          '%{USER}'=='ute'        0xC0A8FF7E        # AaSysLogUdpAddress  192.168.255.126
    ...          '%{USER}'=='localuser'  0xC0A8FF82        # AaSysLogUdpAddress  192.168.255.130
    ${0x10043}=  Set Variable               0xC738            # AaSysLogUdpPort     51000
    @{parametersList}= 	Create List 	0x10042=${0x10042}  0x10043=${0x10043}
    SWConfig.modify_swConfig_file   ${parametersList}  ${sw_path}
    upload_swconfig_on_classical_gnb    bts_id=${bts_id}     prefix_tag=${prefix_tag}

Set BTSLog Rad Parameters on Classical gNB
    [Documentation]    This keyword will set BTSLog IP and Port rad params on gNB
    ...                using AaShell commandes
    ${0x10042}=  Set Variable If
    ...          '%{USER}'=='ute'        0xC0A8FF7E        # AaSysLogUdpAddress  192.168.255.126
    ...          '%{USER}'=='localuser'  0xC0A8FF82        # AaSysLogUdpAddress  192.168.255.130
    ${0x10043}=  Set Variable               0xC738            # AaSysLogUdpPort     51000
    ${0x10041}=  Set Variable               0x5               # Debug
    ${parametersList}= 	Catenate  SEPARATOR=${SPACE} 	0x10041=${0x10041}  0x10042=${0x10042}  0x10043=${0x10043}
    radParams.set_rad_flags    ${parametersList}   persistently=${True}
