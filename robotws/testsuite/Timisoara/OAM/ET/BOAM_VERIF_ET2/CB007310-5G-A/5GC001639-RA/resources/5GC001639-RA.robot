*** Settings ***
Documentation
...    Author: Nicolae Bulata
...    Maintainer: Izabela Muntean
...    Test Description: 5GC001639-RA-a2
...    AC/REQ: LTE_OPR_AC_3110 / LTE_OPR_REQ_12866

Resource    ./webem.robot

Resource    ../../../resources/admin.robot
Resource   ../../../resources/admin_infomodel.robot
Resource    ../../../resources/pretest_posttest.robot
Resource    ../../../resources/system.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process

*** Variables ***
${TIMEOUT_STATUS_MESSAGES}       10
${TIMEOUT_COLLECTION_COMPLETED}  1000
${BTS_ID}                        10009  #for UTE  #1  #for local  #$10009
${DIR_DOWNLOADS}                 /home/ute/Downloads
${DIR_RESULTS}                   /tmp
${DIR_UNZIP}                     ${DIR_RESULTS}  #could be /tmp/full if issue in /home/ute
${SNAPSHOT_FILE_NAME_BEGINNING}  Snapshot_MRBTS-${BTS_ID}_      #for UTE  #Snapshot_MRBTS  #Snapshot_MRBTS-1_
${SNAPSHOT_FILE_NAME}            ${SNAPSHOT_FILE_NAME_BEGINNING}*.zip  #Snapshot_MRBTS-1_*.zip
${METADATA_FILE_NAME}            BTS_*_metadata.txt    #for UTE #BTS*_metadata.txt  #BTS1_*_metadata.txt
${BTS_PART_DIRS}                 BTS*part*  #BTS1_*part*
${FileNumber}           		 15
${keyword}=                      5G
@{log_file_names}                FileList_SWDownload_Start.xz  FileList_SWDownload_End.xz
${SW_DESTINATION}                /home/ute

#${WELCOME_SCREEN_USERNAME_INPUT}=     //div[@class="p-inputgroup"]//input[@placeholder="Username"]
#${WELCOME_SCREEN_PASS_INPUT}=         //div[@class="p-inputgroup"]//input[@placeholder="Password"]

*** Keywords ***
Trigger technical log collection from WebEM and upload locally collected data

    Run     chmod 777 ${DIR_DOWNLOADS}/*
    Run     chmod 777 ${DIR_RESULTS}/*
    Get Software Release
    WEBEM Prepare Enviroment
    WEBEM Login To Web Element Manager   ${sw_release}
    WEBEM Go To Diagnostic Snapshot
    WEBEM Start Collect Snapshot
    Run Keyword and Continue on Failure  WEBEM Wait Until Page Contains Element of Class and Contains Text
    ...  class=status-label  text=Sending request...  timeout=${TIMEOUT_STATUS_MESSAGES}
    Run Keyword and Ignore Error  WEBEM Wait Until Page Contains Element of Class and Contains Text
    ...  class=status-label  text=Collecting files...  timeout=${TIMEOUT_STATUS_MESSAGES}
    WEBEM Wait Until Page Contains Element of Class and Contains Text
    ...  class=status-label  text=Collection  timeout=${TIMEOUT_COLLECTION_COMPLETED}
    WEBEM Page Should Not Contain Element of Class With Text
    ...  class=status-label  text=Collection couldn  loglevel=NONE
    WEBEM Wait Until Page Contains Element of Class and Contains Text
    ...  class=status-label  text=Collection completed  timeout=${TIMEOUT_COLLECTION_COMPLETED}
    Sleep  600
    OperatingSystem.File Should Exist  ${DIR_DOWNLOADS}/${SNAPSHOT_FILE_NAME}
    Run                             mv ${DIR_DOWNLOADS}/${SNAPSHOT_FILE_NAME} ${DIR_RESULTS}
    Sleep  30
    #Run                             cp -pP ${DIR_RESULTS}/${SNAPSHOT_FILE_NAME} ${DIR_UNZIP}/snapshot.zip
    Check Snapshot

    #optional stuff below. if test is OK till now, then is passed
    # <NE ID> = Network Element identifier (MRBTS-MRBTS.mrbtsid)
    ${rc}  ${output}=  Run And Return Rc And Output  hostname | sed 's/-/_/' | sed 's/-/_/'   #5G
    #${rc}  ${output}=  Run And Return Rc And Output  hostname   #4G
    Run Keyword and Ignore Error  OperatingSystem.File Should Exist  ${DIR_RESULTS}/${SNAPSHOT_FILE_NAME_BEGINNING}${output}*.zip

    #Cleanup files - neded only when test is executed automatically to clean big files
    Run Keyword and Ignore Error  Run  ls -1 ${DIR_UNZIP}/snapshot/*.zip | xargs rm -f
    Run Keyword and Ignore Error  Run  ls -1d ${DIR_UNZIP}/snapshot/${BTS_PART_DIRS} | xargs rm -rf
    Run Keyword and Ignore Error  Run  ls -1 ${DIR_UNZIP}/snapshot.zip | xargs rm -f

Check Snapshot
    Wait Until Keyword Succeeds    5x    5 minutes
    ...          Run     unzip -o ${DIR_RESULTS}/${SNAPSHOT_FILE_NAME} -d ${DIR_RESULTS}/snapshot
    Sleep  150
    #LTE_OPR_REQ_19022  #LTE_OPR_AC_9075
    OperatingSystem.File Should Exist  ${DIR_RESULTS}/snapshot/snapshot_file_list.txt
    #LTE_OPR_REQ_8073   #LTE_OPR_AC_3111
    OperatingSystem.File Should Exist  ${DIR_RESULTS}/snapshot/${METADATA_FILE_NAME}


Check the InfoModel snapshot is saved on Operator's PC
    [Tags]  CRT  CA_RAN_BOAM_VERIF   QCP_RAN_ET   QCD_MN_RAN   QC_2721950    # QCP_BTS_OAM  QCD_MN_BTS_OAM
    WEBEM Login To Web Element Manager
    WEBEM Go to Procedures IM Snapshot

    Run Keyword and Continue on Failure  WEBEM Wait Until Element Is Visible
    ...  locator=${WEBEM_BUTTON_IM_SNAPSHOT_EXECUTE_LOCATOR}  timeout=30
    Run Keyword and Continue on Failure  WEBEM Wait Until Element Is Enabled
    ...  locator=${WEBEM_BUTTON_IM_SNAPSHOT_EXECUTE_LOCATOR}  timeout=30

    Wait Until Keyword Succeeds  30  1  WEBEM Start IM Snapshot

    Run Keyword and Continue on Failure  WEBEM Wait Until Element Is Visible
    ...  locator=//div[contains(text(),'Snapshot downloading in progress')]
    WEBEM Wait Until Element Is Visible  locator=//div[contains(text(),'Succeeded')]
    Sleep  10
    OperatingSystem.File Should Exist  ${DIR_DOWNLOADS}/im-snapshot_MRBTS*.ims2
    Run Keyword and Ignore Error  Run
    ...                           mv ${DIR_DOWNLOADS}/im-snapshot_MRBTS*.ims2 ${DIR_RESULTS}

UTE TL Preparation
    [Documentation]  Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    #TO DO:             Add Check for onAir State. For cases when the Suite is run more than one time
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  5GC001639-RA.Configured_SwDownload_SwUpdate_OnAir
    ...     ELSE    Log To Console  --- BTS already onAir ---
    ADMIN Teardown Admin

Configured_SwDownload_SwUpdate_OnAir
    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release
    ADMIN Perform Commissioning
    ...   scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
    ${configured}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    Run Keyword If  '${configured}' == 'True'  Sleep  180
    Run Keyword Unless   ${configured}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    ...    AND     Sleep  180
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords
    ...    Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found.
    ${onair}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Run Keyword Unless   ${onair}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
