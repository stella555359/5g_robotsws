# CB015286 - New NR Counters Designed
Robot test suite for feature CB015286.

## Abbreviation description.
* SA – Standalone
* NSA – Non-Standalone
* CA – Carrier Aggregation
* PCell – Primary Cell
* SCell – Secondary Cell
* MAC CE – MAC Control Element

## Required initial SBTS state (provided directly from SCF)
* SBTS is setup for the SA deployment and NSA deployment
* Carrier Aggregation (3CC) is enabled: CA_n25A-n41A-n71A
* The PCell (PCell_FDD n25) and 2 SCells (SCell_TDD – n41 and SCell_FDD – n71) are configured with the following parameters:
 - Secondary cell operational mode for SCell_TDD: NRBTS.NRCELL.NRREL.sCellOperationalMode is set to dlAndUl
 - Secondary cell operational mode SCell_FDD: NRBTS.NRCELL.NRREL.sCellOperationalMode is set to dlOnly
 - Secondary cell addition method for all SCells: NRBTS.NRCELL.NRREL.sCellAdditionMethod is set to covBasedA1
 - Secondary cells activation method: NRBTS.sCellActivationMethod is set to bufferBased.
 - NRBTS.actMeasBasedSCellAdditionSa is set to A1-based
* NRBTS.actCarAgPmCount is set to true
* NRBTS.NRPMRNL.miNrCaDu is set to 5min (change from 15min) to have shorter measurement window
* NRBTS.NRCELL.NRREL.handoverAllowedSA is set to forbidden to avoid handover to other cells
* SA UE is configured. The UE supports CA and the necessary band combination: CA_n25A-n41A-n71A
* NSA Carrier Aggregation (2CC) is enabled: DC_2A-71A_n41A
* The anchor cell LTE FDD b2 and PCell FDD n71 and SCell TDD – n41 are configured with the following parameters:
 - Secondary NR cell operational mode for SCell_FDD n71: NRBTS.NRCELL.NRREL.sCellOperationalMode is set to dlAndUl
 - Secondary cell addition method for SCell: NRBTS.NRCELL.NRREL.sCellAdditionMethod is set to covBasedA1
 - Secondary cells activation method: NRBTS.sCellActivationMethod is set to bufferBased
 - NRBTS.actMeasBasedSCellAdditionNsa is set to true
* NSA UE is configured. The UE supports NSA CA and the necessary band combination: DC_2A-71A_n41A


## Test cases

### CB015286_TMOUS_CVR_001_New_Counters_For_SA_CA_Scell_Activation_Deactivation_Verification 
This User Scenario verifies the new NR counters for CA scell activation/deactivation in the TMO top configuration for CB015286

* Owner: piotr.smolak@nokia.com
* Author: igor.kleschenok@nokia.com
* Maintainer: igor.kleschenok@nokia.com

#### Test scenario defined by owner
* Step 1:
  * Description:  
    Attach SA_UE to the PCell_FDD.
    Trigger SCell addition procedure for the SA_UE (sCellAdditionMethod is set to covBasedA1).
  * Expected:  
    The SA_UE attach is successful, and SCells are added successfully. 
* Step 2:
  * Description:  
    Trigger SCells activation procedure for the SA_UE (NRBTS.sCellActivationMethod is set to bufferBased)
  * Expected:  
    The MACCE_SENT_SCELL_ACT_SA_INI counter is incremented correctly for each TB containing the SCell activation MAC CE
    Same information from L2 traces to confirm that there was a TB containing the SCell activation MAC CE
    hasSCellActDeact – means that SCell activation/deactivation is present in TB
    sCellActDeact – inform about value of the bits which cells are currently activated (00110 = 6 – means that first and second SCells activated)
    priorityIndex – information if its initial transmission (DL MAC CE or retransmission HARQRETXDRB TB)
    The MACCE_SENT_SCELL_ACT_SA counter is also incremented correctly for each TB containing the SCell activation MAC CE
    All SCells are activated successfully.Based on counters we observed that there was one initial transmission
    Same information visible in TTI Traces on the screen and provided via logs
* Step 3:
  * Description:  
    Trigger SCell deactivation procedure for the SA_UE 
  * Expected:  
    The SCELL_DL_DEACT_DEACTMR_SA counter is incremented correctly for all deactivated SCells
    The MACCE_SENT_SCELL_DEACT_SA_INI counter is incremented correctly for each TB containing the SCell deactivation MAC CE
    Same information from L2 traces to confirm that there was a TB containing the SCell deactivation MAC CE
    The MACCE_SENT_SCELL_DEACT_SA counter is also incremented correctly for each TB containing the SCell deactivation MAC CE
    Upon successful HARQ ACK of the deactivation MAC CE,the MACCE_HARQ_ACK_SCELL_DEACT_SA counter is incremented correctly
    for each TB containing the SCell deactivation MAC CE
    All SCells are deactivated successfully
    Based on counters we observed that there was one initial transmission and no retransmissions during SCell deactivation procedure.
    Same information visible in TTI Traces on the screen and provided via logs

#### Pass criteria
* New NR counters in cell are incremented correctly

#### Automatic TC steps
* Preconditions
* Step 1: Start DL Traffic For UE
* Step 2: Stop Traffic And Release UE
* Step 3: Verify CA SCell Activation and Deactivation 
* Step 4: Verify Pm Counters

#### Test case developer notes
* Please make sure that all parameters from preconditions are set on the BTS.
* This test was tested on TL TMO 7_16_UTE5GCLOUDU049. Cell configuration: Primary cell(PCell) = 23,
  First Secondary cell(FSCell) = 13, Second Secondary cell (SSCell) = 3

#### History of changes
* 5.02.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1758 - Initial creation


### CB015286_TMOUS_CVR_001_New_Counters_For_NSA_CA_Scell_Activation_Deactivation_Verification 
This User Scenario verifies the new NR counters for CA scell activation/deactivation in the TMO top configuration for CB015286

* Owner: piotr.smolak@nokia.com
* Author: igor.kleschenok@nokia.com
* Maintainer: igor.kleschenok@nokia.com

#### Test scenario defined by owner
* Step 1:
  * Description:  
    Attach UE to LTE anchor cell and perform NSA call. Trigger SgNB addition procedure.
    (sCellAdditionMethod is set to covBasedA1).
  * Expected:  
    The NSA_UE attach is successful, and SCell is added successfully. 
* Step 2:
  * Description:  
    Trigger SCell activation procedure for the NSA_UE (NRBTS.sCellActivationMethod is set to bufferBased).
  * Expected:  
    The MACCE_SENT_SCELL_ACT_NSA_INI counter is incremented correctly for each TB containing the SCell activation MAC CE.
    Same information from L2 traces to confirm that there was a TB containing the SCell activation MAC CE.
    sCellActDeact – means that SCell activation/deactivation is present in TB
    hasSCellActDeact – inform about value of the bits which cells are currently activated (00100 = 4 – means that first SCells activated)
    priorityIndex – information if its initial transmission (DL MAC CE or retransmission HARQRETXDRB TB)
    The MACCE_SENT_SCELL_ACT_NSA counter is also incremented correctly for each TB containing the SCell activation MAC CE
    SCell is activated successfully.
* Step 3:
  * Description:  
    Trigger SCell deactivation procedure for the NSA_UE.
  * Expected:  
    The SCELL_DL_DEACT_DEACTMR_NSA counter is incremented correctly for deactivated SCell.
    The MACCE_SENT_SCELL_DEACT_NSA_INI counter is incremented correctly for each TB containing the SCell deactivation MAC CE.
    Same information from L2 traces to confirm that there was a TB containing the SCell deactivation MAC CE.
    The MACCE_SENT_SCELL_DEACT_NSA counter is also incremented correctly for each TB containing the SCell deactivation MAC CE.
    SCell is deactivated successfully.
    Based on counters we observed that there was one initial transmission and no retransmissions during SCell deactivation procedure.
    Same information visible in TTI Traces on the screen and provided via logs.

#### Pass criteria
* New NR counters in cell are incremented correctly

#### Automatic TC steps
* Preconditions
* Step 1: Start DL Traffic For UE
* Step 2: Stop Traffic And Release UE
* Step 3: Verify CA SCell Activation and Deactivation 
* Step 4: Verify Pm Counters

#### Test case developer notes
* Please make sure that all parameters from preconditions are set on the BTS.
* This test was tested on TL TMO 7_16_UTE5GCLOUDU049. Cell configuration: Anchor cell(LTE Cell) = 22,
  First Secondary cell(FSCell) = 12, Second Secondary cell (SSCell) = 303

#### History of changes
* 5.02.2026 - https://jiradc.ext.net.nokia.com/browse/IWK-1758 - Initial creation
