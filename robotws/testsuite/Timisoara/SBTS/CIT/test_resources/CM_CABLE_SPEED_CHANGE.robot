*** Settings ***
Documentation
    ...  This is the resource for CM_Cable_Speed_Change TC

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${TIMEOUT}  360  # Timeout for Stability of BTS [s]
${DIST_NAME_CABLINK}  ${EMPTY}  # Dist_name for cablink which supports linkspeed = auto,
# ex: /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-10750/EQM_A-1/HWTOP_A-1/CABLINK_A-2


*** Keywords ***
TC__CM_Cable_Speed_Change
    Set Tags  CA-CM  OWNER-lukasz.rudzinski@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  AUTHOR-lukasz.rudzinski@nokia.com  PHASE-CIT  SW-SBTS19
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  FEATURE-LTE2060

    Precondition
    Step: 1 Perfom Cable Speed Change
    Step: 2 Check If BTS Is Reachable
    Step: 3 Check If BTS Was Restarted After Changed Parameter And Value Of Recommissioned Parameter
    Step: 4 Wait For SBTS OnAir And Restore Tested Cablink


Precondition
    Log  Precondition  console=True
    Collect SCF  ${TEST_FILES}/SCF__recommissioning.xml
    Log  SCF has been saved under ${TEST_FILES}/SCF__recommissioning.xml  console=True
    ${status}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${DIST_NAME_CABLINK}
    IF  ${status}
      Set Cablink And SCF Parameter  ${DIST_NAME_CABLINK}
    ELSE
      Find Randomly Cablink For Test Purposes
      Set Cablink And SCF Parameter  ${CABLINK}
    END


Step: 1 Perfom Cable Speed Change
    Log  Step: 1 Perfom cable speed change  console=True
    Perform Parameter Recommissioning  dist_name=${PARAMETER_SCF_DIST_NAME}  parameter=linkSpeed  operation=update  value=Auto
    ...  skip_parameter_relation_errors=true  timeout=${TIMEOUT}
    Log  Recommissioning of ${PARAMETER_SCF_DIST_NAME} done.  console=True


Step: 2 Check If BTS Is Reachable
    Log  Step: 2 Check If BTS Is Reachable  console=True
    Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${TIMEOUT}  remote_host=None
    Log  BTS is reachable  console=True
    Log  Check If BTS is stable  console=True
    Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=120  timeout=${TIMEOUT}  remote_host=None
    Log  BTS is stable  console=True


Step: 3 Check If BTS Was Restarted After Changed Parameter And Value Of Recommissioned Parameter
    Log  Step: 3 Check If BTS Was Restarted After Changed Parameter And Value Of Recommissioned Parameter  console=True
    Save Infomodel Log  ${BTS_FILES}/IM/Infomodel_Reset_Check.ims2
    ${was_triggered}  Infomodel Check IM Log If BTS Reset Was Triggered  ${BTS_FILES}/IM/Infomodel_Reset_Check.ims2
    ${status}  Run Keyword And Return Status
    ...  Query Infomodel  //${CABLINK_FOR_RECOMMISSIONING} is [linkSpeed=Auto]
    IF  ${was_triggered} and ${status}
      Log  BTS was restarted and parameter 'linkSpeed' has correct value  console=True
    ELSE
      Fail  Conditions from Step 3 weren't fulfilled  console=True
    END


Step: 4 Wait For SBTS OnAir And Restore Tested Cablink
    Log  Step: 4 Wait for SBTS OnAir And Restore Tested Cablink  console=True
    Log  \nCheck cells states  console=True
    Wait Until Keyword Succeeds  ${TIMEOUT}s  30s
    ...  Assert All Cells Are In Expected State
    Log  \nCheck active alarms  console=True
    Admin Check Active Alarms TAF


Find Randomly Cablink For Test Purposes
    ${cablinks}  Query Infomodel  get list //CABLINK_R-*
    ${scf_cablinks}  Create List
    FOR  ${cablink}  IN  @{cablinks}
        ${status}  Run Keyword And Return Status
        ...  Should Match Regexp  ${cablink['dist_name']}  .*CABLINK_R-[0-9]{4}
        IF  not ${status}  CONTINUE
        ${status}  Run Keyword And Return Status
        ...  Query Infomodel  ${cablink['configDN']} is [linkSpeed!=Auto]
        IF  ${status}  Append To List  ${scf_cablinks}  ${cablink['configDN']}
    END
    ${number_of_cablinks}  Get Length  ${scf_cablinks}
    ${cablink_index}  Evaluate  random.randint(0, ${number_of_cablinks}-1)  modules=random
    ${dist_name_cablink}  Get From List  ${scf_cablinks}  ${cablink_index}
    Set Test Variable  ${CABLINK}  ${dist_name_cablink}


Set Cablink And SCF Parameter
    [Arguments]  ${selected_cablink}

    ${selected_cablink}  Remove String Using Regexp  ${selected_cablink}  .*SCF-\\d/
    Set Test Variable  ${CABLINK_FOR_RECOMMISSIONING}  ${selected_cablink}
    ${selected_cablink}  Remove String Using Regexp  ${selected_cablink}  _A
    Set Test Variable  ${PARAMETER_SCF_DIST_NAME}  ${selected_cablink}


Restore Tested Cablink
    Admin Get Bts_id And Perform Commissioning  ${TEST_FILES}/SCF__recommissioning.xml  True  ${TIMEOUT}
    Sleep  60s
    Wait Until Keyword Succeeds  ${TIMEOUT}s  30s
    ...  Assert All Cells Are In Expected State


Custom Test Teardown
    Log  \nRestore tested cablink  console=True
    Restore Tested Cablink
    Common Test Teardown


TC Setup
    Common Test Setup  tc_name=CM_CABLE_SPEED_CHANGE


TC Teardown
    Custom Test Teardown
