*** Settings ***
Documentation
...   author: Fengcai Liu;Yongjie Liu
...   contact: amy.c.liu@nokia-sbell.com;yongjie.liu@nokia-sbell.com
...   this is kwyword for CB007942.
Library    Collections
Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Library           taf.sw.scout          WITH NAME    scout
Resource    ../../../T02/Common_Case/common_resource_new.robot


*** Keywords ***
Suite Setup For CUS
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    [Arguments]    ${scf_file}    ${swconfig}    ${cus}
    Common Suite Setup For Pet
    Setup For Ap  swconfig=${swconfig}  scf_file=${scf_file}  cus_yaml=${cus}
    Create Alias

Suite Teardown For CUS
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Common Suite Teardown For Pet
    Run Keyword And Ignore Error  fsmaccess.Teardown All Aliases For Enb Fsmaccess
    Run Keyword And Ignore Error  fsmaccess.Teardown All Aliases For Wts Fsmaccess

Create BTS Alias
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_2    enb_id=2    id_type=wts
    Create Enb Alias    GNB_3    enb_id=3    id_type=wts
    Create Enb Alias    ENB_4    enb_id=4    id_type=wts

Create UES Alias
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console    Create UES Alias
    FOR    ${ue_id}    IN RANGE    1    7
       Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END

Create Alias
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Create UES Alias
    Create BTS Alias
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Prepare Counter
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Pet FCT Exec Command    ${FCT_MASTER}    rm -rf /tmp/PM*
    Pet FCT Exec Command    ${FCT_MASTER}    rm -rf /tmp/RD*

Judge Counters For Case1
    [Arguments]    ${pmdict}
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Should Be True   ${pmdict}[M8048C0]==2
    Should Be True   ${pmdict}[M8048C1]==2
    Should Be True   ${pmdict}[M8023C0]>0
    Should Be True   ${pmdict}[M8023C1]==0
    Should Be True   ${pmdict}[M8023C6]>0
    Should Be True   ${pmdict}[M8023C7]==0
    Should Be True   ${pmdict}[M8023C21]>0
    Should Be True   ${pmdict}[M8023C27]==0

Judge Counters For Case2
    [Arguments]    ${pmdict}
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Should Be True   ${pmdict}[M8048C0]==0 and ${pmdict}[M8048C1]==0
    Should Be True   ${pmdict}[M8048C5]==4
    Should Be True   ${pmdict}[M8048C6]==2
    Should Be True   ${pmdict}[M8023C0]>0
    Should Be True   ${pmdict}[M8023C1]==0
    Should Be True   ${pmdict}[M8023C6]>0
    Should Be True   ${pmdict}[M8023C7]==0
    Should Be True   ${pmdict}[M8023C21]>0
    Should Be True   ${pmdict}[M8023C27]==0

Check Related PM Counters For Case1
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Pet Wait Until All PM File Done    ${FCT_MASTER}
    Create Directory    ${CASE_DIRE}/PMCounter
    Pet FCT Get File    ${FCT_MASTER}    /tmp/PM*.xml.gz    ${CASE_DIRE}/PMCounter/
    @{pmlist}=    Create List    M8048C0  M8048C1  M8023C0  M8023C1  M8023C6  M8023C7  M8023C21  M8023C27  M8012C25
    &{dt1}=    Create Dictionary
    ${distname}=    Set Variable    PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-3
    FOR    ${pmname}    IN    @{pmlist}
        ${pmvalue}=    Pet Sum Counter In Files    ${CASE_DIRE}/PMCounter/    ${pmname}    ${distname}
        Set To Dictionary    ${dt1}    ${pmname}=${pmvalue}
    END
    Judge Counters For Case1    ${dt1}

Check Related PM Counters For Case2
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Pet Wait Until All PM File Done    ${FCT_MASTER}
    Create Directory    ${CASE_DIRE}/PMCounter
    Pet FCT Get File    ${FCT_MASTER}    /tmp/PM*.xml.gz    ${CASE_DIRE}/PMCounter/
    @{pmlist}=    Create List    M8048C0  M8048C1  M8048C5  M8048C6  M8023C0  M8023C1  M8023C6  M8023C7
    ...     M8023C21  M8023C27  M8012C25
    &{dt1}=    Create Dictionary
    ${distname}=    Set Variable    PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-4
    FOR    ${pmname}    IN    @{pmlist}
        ${pmvalue}=    Pet Sum Counter In Files    ${CASE_DIRE}/PMCounter/    ${pmname}    ${distname}
        Set To Dictionary    ${dt1}    ${pmname}=${pmvalue}
    END
    Judge Counters For Case2    ${dt1}

Online Parameters Delete QciTabOperatorDefault
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     modify qciTabOperatorDefault to null
    coam.Perform Parameter Recommissioning    dist_name=MRBTS-1/LNBTS-1
    ...                                       operation=delete
    ...                                       parameter=qciTabOperatorDefault
    ...                                       value=99
    ...                                       connection=master

Online Parameters Modify QciTabOperatorDefault To 140
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     modify qciTabOperatorDefault to 140
    coam.Perform Parameter Recommissioning    dist_name=MRBTS-1/LNBTS-1
    ...                                       operation=update
    ...                                       parameter=qciTabOperatorDefault
    ...                                       value=140
    ...                                       connection=master

Online Parameters Modify QciTabOperator Delete Qci 99
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    [Arguments]    ${pm_file}
    Log To Console     delete qciTab99 Structure
    coam.Perform Delta Recommissioning    delta_file=${pm_file}    connection=master

Capture Bts Snapshot
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     Capture Bts Snapshot
    coam.Collect Snapshot    target_file_name=${CASE_DIRE}/snapshot.zip    connection=master    timeout=1800

Case Teardown For CUS
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Capture Bts Snapshot
    Run Keyword And Ignore Error    Stop Capture 5G Btslog
#    HAZ TC02 Get SCF Internal Id By Scout    no_ute=False
    Common Case Teardown For Pet

Start Capture Btslog
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Set Suite Variable    ${BTSLOG_FILENAME}   ${CASE_DIRE}/btslog/btslog.log
    ${collector}=    Pet Create Btslog Collector    host=127.0.0.1    port=51000    password=uteUTE!
    ...              filename=${BTSLOG_FILENAME}
    Set Suite Variable          ${COLLECTOR_5G}    ${collector}
    Pet Start Capture Btslog    ${COLLECTOR_5G}

Stop Capture 5G Btslog
    [Documentation]
    ...    author: yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    05.01.2024,yongjie.liu@nokia-sbell;amy.c.liu@nokia-sbell.com,case template draft
    Log To Console     Stop Capture 5G Btslog
    Pet Stop Capture Btslog    ${COLLECTOR_5G}
