*** Settings ***
Documentation     [PURPOSE]
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
#Library           OperatingSystem
Library           ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/CmOperationsExtend.py


*** Variables ***
${TEST_LOG_DIR}    /home/ute/btsauto/
${BTS_OnAir_Timeout}    5


*** Keywords ***
[LTE3656_V_10] reset FHS in fullrack BTS
    [Documentation]    Short description.
    LTE3656_V_10_reset_FHS_in_fullrack_BTS.Precondition
    Step1 check FHS in BTS working well
    Step2 Reset FHS
    Step3 Check FHS and BTS status after FHS reset

Precondition
    [Documentation]    Short description.
    #Start syslog    log_dir=${TEST_LOG_DIR}    log_name=LTE3656-2.LOG
    Start Admin    alias=FHS
    ute_admin_infomodel.Setup Infomodel   address=192.168.255.129   port=443  use_ssl=true  timeout=5min  alias=FHS
    ute_admin_infomodel.Connect Infomodel  alias=FHS
    ${software_info}  taf.sbts.oam.coam.admin.Get Software Info  alias=FHS
    Set test variable  ${Active_Version_before}  ${software_info['Active SW version']}
    Set test variable  ${Passive_Version_before}  ${software_info['Passive SW version']}
    Set test variable  ${Planned_Version_before}  ${software_info['Planned SW version']}

Step1 check FHS in BTS working well
    [Documentation]    Short description.
    Log  Step1 check FHS in BTS  console=${true}
    Log  Check if object FHS is exist console=${TRUE}
    Check FHS exist
    Check FHS status  enabled
    Check if BTS onAir
    #start infomodel

Step2 Reset FHS
    [Documentation]    Short description.
    Log  Step2 Reset FHS  console=${true}
    Log  get FHS object name
    ${object}  Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-*/FHS_R-1    alias=FHS
    log   ${object}
    Set test variable  ${object}
    #run keyword and ignore error    Start Admin    alias=FHS
    ${execute_status}  Run keyword and return status    taf.sbts.oam.coam.admin.unit_reset_cp
    ...  dist_name=${object['dist_name']}   reset_type=soft  timeout=500s   alias=FHS
    run keyword if   ${execute_status}  Log  Reset FHS Successfully  console=${true}}  ELSE  Run keywords  Fail
    ...  Reset FHS failed!  AND  Log  Reset FHS failed!  console=${TRUE}

Step3 Check FHS and BTS status after FHS reset
    [Documentation]    Short description.
    Log  Step4 Check FHS and BTS status after FHS reset  console=${true}
    Confirm FHS reset
    Wait Until Keyword Succeeds    6min    30s    Check FHS status  enabled
    Wait Until Keyword Succeeds    6min    30s    Check BTS State By Admin  OnAir
    #Stop Syslog
    ute_admin_infomodel.teardown all aliases for infomodel

Check FHS exist
    [Documentation]    Short description.
    ${object_exist}  Run keyword and return status
    ...  Query Infomodel  /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-*/FHS_R-1    alias=FHS
    Run keyword if  ${object_exist}  Log  Object //MMRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-*/FHS_R-1 exists
    ...  console=${TRUE}  ELSE  Run keywords  Fail
    ...  Object MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-*/FHS_R-1 doesn't exist  AND  Log
    ...  Object MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-*/FHS_R-1 doesn't exist  console=${TRUE}

Check FHS status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${status}: <description>
    [Arguments]    ${status}
    Log  Check FHS status  console=${TRUE}
    ${object}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-*/FHS_R-1    alias=FHS
    Run keyword if  '${object['operationalState']}'=='${status}'  Log  Object FHS has correct status
    ...  console=${TRUE}  ELSE  Run keywords  Fail  FHS has value ${object['operationalState']}  AND
    ...  Log   FHS has value ${object['operationalState']}.  console=${true}

Confirm FHS reset
    [Documentation]    Short description.
    Save Infomodel log    FHSlog.ims2    alias=FHS
    ute_admin_infomodel.Initialize Ims2 Validator    FHSlog.ims2
    ute_admin_infomodel.Add Expected Ims2 Event    change ${object['dist_name']} [operationalState: enabled -> disabled]
    ${result}=    Run Keyword And Ignore Error    ute_admin_infomodel.Validate Ims2    alias=FHS
    Should Be True    '${result[0]}'=='PASS'
    Log    Validation Succeed

Check if BTS onAir
    [Documentation]    Short description.
    Log  Will now check if BTS is OnAir, timeout=${BTS_OnAir_Timeout}min, interval=10sec  console=${TRUE}
    Wait until keyword succeeds  ${BTS_OnAir_Timeout} min  10 sec  Check SBTS SOAM cells and modules
    Log Important Message  BTS is OnAir, all cells and modules are in expected states
