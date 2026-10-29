# @Time    : 2021/10/27 14:10
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : Globe_Lab_LTE_Precondition.robot
# @Software: PyCharm
# @Doc     : Globe LTE Precondition
*** Settings ***
Resource    Globe_Lab_LTE_Keywords.robot
Resource    taf/rfrl/bts/robot/enb.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library     taf.sbts.oam.coam.admin        WITH NAME    admin

*** Keywords ***
Globe Common Suite Setup
    gnb_classical_hangzhou.Get Initial Attenuation Values For RU
    Set PA Make Enb1 Signal Stronger

Case BFT 1-1 Precondition
    Keep enb1 single cell unlock

Case BFT 1-2 Precondition
    Keep enb1 single cell unlock

Case BFT 1-3 Precondition
    Keep enb1 single cell unlock

Case BFT 3-1 Precondition
    Set PA Make Enb1 Signal Stronger

Case BFT 3-2 Precondition
    Set PA Make Enb1 Signal Stronger

Case BFT 5-1 Precondition
    #Set PA Make Enb1 Signal Stronger
    Sleep    1

Case BFT 5-2 Precondition
    #Set PA Make Enb1 Signal Stronger
    Sleep    1

Case BFT 6-1 Precondition
    Verify No Critical Alarms

Case PDFT 2-1 Precondition
    Sleep    1

Case PDFT 2-2 Precondition
    Sleep    1

Case PDFT 3-1 Precondition
    Set PA Make Enb1 Signal Stronger
    Keep enb1 single cell unlock

Case PDFT 3-2 Precondition
    Connect to eNB via ssl  enb_index=0
    Unlock Parameter    ${ENB0 DIST MME0}
    Lock Parameter    ${ENB0 DIST MME1}
    Enblte close down
    Connect to eNB via ssl  enb_index=1
    Lock Parameter    ${ENB1 DIST MME0}
    Unlock Parameter    ${ENB1 DIST MME1}
    Enblte close down
    Set PA Make Enb1 Signal Stronger

Case PDFT 4-1 Precondition
    Set PA Make Enb1 Signal Stronger

Case PDFT 4-2 Precondition
    Set PA Make Enb1 Signal Stronger

Case PDFT 5-1 Precondition
    [Documentation]     Author: Chen Jian
    ...                 Description: Make enb1 cellReselectionPriority lower
    ...                 Configuration:  Set enb1 signal stronger
    ...                                 Set enb1 cellReSelPrio lower (enb1:1 & enb2:6 & skip error)
    Set PA Make Enb1 Signal Stronger
    Connect to eNB via ssl    enb_index=0
    enblte.perform_parameter_recommissioning       dist_name=${ENB0 DIST CELL12 RESEL}
    ...                                            parameter=cellReSelPrio
    ...                                            operation=update
    ...                                            value=1
    ...                                            skip_parameter_relation_errors=True
    ...                                            connection=enblte
    Enblte close down
    Connect to eNB via ssl    enb_index=1
    enblte.perform_parameter_recommissioning       dist_name=${ENB1 DIST CELL8 RESEL}
    ...                                            parameter=cellReSelPrio
    ...                                            operation=update
    ...                                            value=6
    ...                                            skip_parameter_relation_errors=True
    ...                                            connection=enblte
    Enblte close down

Case PDFT 5-2 Precondition
    [Documentation]     Author: Chen Jian
    ...                 Description: Make enb1 cellReselectionPriority higher
    ...                 Configuration:  Set enb1 signal stronger
    ...                                 Set enb1 cellReSelPrio higher (enb1:6 & enb2:1 & skip error)
    Set PA Make Enb1 Signal Stronger
    Connect to eNB via ssl    enb_index=0
    enblte.perform_parameter_recommissioning       dist_name=${ENB0 DIST CELL12 RESEL}
    ...                                            parameter=cellReSelPrio
    ...                                            operation=update
    ...                                            value=6
    ...                                            skip_parameter_relation_errors=True
    ...                                            connection=enblte
    Enblte close down
    Connect to eNB via ssl    enb_index=1
    enblte.perform_parameter_recommissioning       dist_name=${ENB1 DIST CELL8 RESEL}
    ...                                            parameter=cellReSelPrio
    ...                                            operation=update
    ...                                            value=1
    ...                                            skip_parameter_relation_errors=True
    ...                                            connection=enblte
    Enblte close down

Case PDFT 6-1 Precondition
    [Documentation]     Author: Chen Jian
    ...                 Description: Import scf complete configuration
    ...                 Configuration:  eNBs are operation and with same frequency
    ...                                 No X2 link between eNB-1 and eNB-2
    ...                                 No Network relation between eNB-1 and eNB-2
    ...                                 Configure anrOmExtEnable = true on both eNB-1 and eNB-2
    No Operation

Case PDFT 6-2 Precondition
    Sleep    1
    #Globe Commission With Scf File    gnb_index=0    scf_file_path=${CURDIR}/scf/enb0-6-2.xml
    #Globe Commission With Scf File    gnb_index=1    scf_file_path=${CURDIR}/scf/enb1-6-2.xml
    Set PA Make Enb2 Signal Stronger
