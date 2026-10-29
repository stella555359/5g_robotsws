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

Library     taf.rfrl.utilities.tl_config
Library     taf.rfrl.bts.commissioning
Resource    taf/rfrl/bts/robot/gnb.robot

*** Variables ***
${ENB_BUILD}
@{ALLOWED_ARG}    True    Yes    Oui    true    yes    oui


*** Keywords ***
Update gNB Software To Current Build Candidate
    # When dealing with cloud, set flag by_nominal to True
    ${sw_package_path}  Download SW Package   sw_version=${ENB_BUILD}
    Update gNB Software     sw_package_dir=${sw_package_path}     timeout=1800

Full Commissioning Upgrade and OnAir Check
    [Arguments]     ${bts_id}=${0}     ${prefix_tag}=${EMPTY}
	 upload_swconfig_on_classical_gnb    bts_id=${bts_id}     prefix_tag=${prefix_tag}
     Run Keyword and Ignore Error    Perform Full Commissioning on Classical gNB    bts_id=${bts_id}     prefix_tag=${prefix_tag}
     Update gNB Software To Current Build Candidate
     Wait For Site To Be Onair

Full Commissioning and OnAir Check
    [Arguments]     ${bts_id}=${0}     ${prefix_tag}=${EMPTY}
     ${skip_init_commissioning}=    Get Variable Value    ${skip_init_commissioning}    False
     run keyword if   '${skip_init_commissioning}' not in ${ALLOWED_ARG}  run keywords
     ...         upload_swconfig_on_classical_gnb    bts_id=${bts_id}     prefix_tag=${prefix_tag}    AND
	 ...         Perform Full Commissioning on Classical gNB    bts_id=${bts_id}    prefix_tag=${prefix_tag}    AND
     ...         Wait For Site To Be Onair
     ...    ELSE    Log    initial commissioning is aboreted
