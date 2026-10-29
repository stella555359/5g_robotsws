*** Settings ***
Documentation    Author: Arunkumar A
...  contact: arunkumar.a@nokia.com
...  QC Test instance id for reporting portal update.

*** Variables ***
&{E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call}    QC_ID_SBTS00=691561   
...    QC_ID_SBTS24R1=692179   
...    QC_ID_SBTS24R2=773767
&{E2E_TL_Site_reset_without_HWF_with_OAM_KPI}   QC_ID_SBTS00=516470   
...    QC_ID_SBTS24R1=692178     
...    QC_ID_SBTS23R4=720099    
...    QC_ID_SBTS24R2=773773
...    BTS_1055_QC_ID_SBTS00=733026

&{E2E_TL_SW_upgrade_rollback_with_OAM_KPI}  QC_ID_SBTS00=516469    
...    QC_ID_SBTS24R1=692181    
...    QC_ID_SBTS23R4=720098    
...    QC_ID_SBTS24R2=773774
...    BTS_1055_QC_ID_SBTS00=733024

&{E2E_TL_Delta_Commissioning_With_NR_Rat_Reset}   QC_ID_SBTS00=691560    
...    QC_ID_SBTS24R1=692180
...    QC_ID_SBTS23R4=720102    
...    QC_ID_SBTS24R2=773768
&{E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI}    QC_ID_SBTS00=516468    
...    QC_ID_SBTS24R1=692186
...    QC_ID_SBTS23R4=720101    
...    QC_ID_SBTS24R2=773775
&{E2E_TL_RU_Reset_with_OAM_KPI}   QC_ID_SBTS00=516467    
...    QC_ID_SBTS24R1=692177    
...    QC_ID_SBTS23R4=720100   
...    QC_ID_SBTS24R2=773776
&{Rjio_E2E_63_Mobility_UE_based_ANR}    QC_ID_SBTS00=689256    
...    QC_ID_SBTS24R1=692187   
...    QC_ID_SBTS24R2=773770
&{Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor}    QC_ID_SBTS00=689257   
...    QC_ID_SBTS24R1=692188    
...    QC_ID_SBTS24R2=773769
&{[CB007511]Deepsleep mode for energy efficiency based on CB007511}    QC_ID_SBTS00=665750    
...    QC_ID_SBTS24R1=692182
&{Robustness Deepsleep mode for energy efficiency based on CB007511}    QC_ID_SBTS00=689265    
...    QC_ID_SBTS24R1=692189    
...    QC_ID_SBTS23R4=720103
&{Regression Scenario for Sleeping Cell Detection when GPS signal is recovered after longer interruption}    QC_ID_SBTS00=669960    
...    QC_ID_SBTS24R1=692183
&{RJIO_KPI & counter verification for VoNR traffic}   QC_ID_SBTS00=761661    
...    QC_ID_SBTS23R4=755662
&{RJIO_KPI & counter verification with multiple slices}    QC_ID_SBTS00=761662    
...    QC_ID_SBTS23R4=755663
&{RJIO_RACH success rate verification on multiple slices}    QC_ID_SBTS00=761663    
...    QC_ID_SBTS23R4=755664
&{RJIO_Throughput verification on slicing configuration}    QC_ID_SBTS00=761664    
...    QC_ID_SBTS23R4=755665
&{TC47 Performing parameter changes which require BTS restart in RJio configuration}   QC_ID_SBTS00=587775   
...    QC_ID_SBTS24R1=692185   
...    QC_ID_SBTS24R2=773771
&{TC43 Performing Online Parameter Changes to enable sleeping cell feature in RJio configuration}    QC_ID_SBTS00=587774
...    QC_ID_SBTS24R1=692184    
...    QC_ID_SBTS24R2=773772