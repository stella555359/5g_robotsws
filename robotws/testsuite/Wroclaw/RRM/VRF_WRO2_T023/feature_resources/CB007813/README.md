# CB007813 5G-A IntragNB inter freq HO 10DL10UL 30DL10UL SA
Canadian operators would like to use the asymmetric spectrum with the configuration
of DL 30 MHz + UL 10 MHz. This feature only provides a single carrier for DL 30MHz bandwidth. 
 
This feature introduces: 
* the asymmetric spectrum with 4T4R DL 30 MHz / UL 10 MHz (or 2T2R DL 30 MHz / UL 10 MHz carriers for ASiR) for FR1 FDD on n66 band 

## Developer notes
* UE is on QUALCOMM chipset
* QXDM, QCAT and License Keeper should be installed on UE_PC
* cygwin is installed on UE_PC
* In case of removing reset in Preconditions, collection time counter in step 3 should not exceed TC duration from beginning.
* Third BWP profile should be configured on asymmetric cell.

## Test line requirements
This section is taken from automation requests done by Anna Konior - TC QC reference:
* CB007813 5G-A IntragNB inter freq HO 10DL10UL 30DL10UL SA

* real gNB (SA)
* real Core
* ASIL
* ABIO/ABIN
* UE

### Example configuration
* ASIL+ABIO

### Required initial BTS state (not to be checked but provided directly from SCF)

* Two SA cell are configured and onAir: first symmetric 10DL10UL second asymmetric 30DL10UL 
* gNB is up and running without any faults and/or warning messages.

## Test cases

### CB007813_5G_A_Intra_gNB_inter_freq_HO_10DL10UL_30DL10UL_SA

Purpose of this test case is to verify intra gNB SA HO between asymmetric cells.

* Owner: anna.konior@nokia.com
* Author: lukasz.parzybut@nokia.com
* Maintainer: szymon.startek@nokia.com

#### Test specific Preconditions

* Intra gNB Handover properly configured
* Asymetric cells configured according to TP specification.


#### Test scenario defined by owner

* Step 1: Check BTS status.
* Step 2: Attach UE to cell A and start DL data traffic
* Step 3: Perform handover from cell A to cell B
* Step 4: Perform handover from cell B to cell A


Comment: to optimize performance and logs size steps 3,4 are merged into one step. Functionality stays the same.


#### Pass Criteria

* Step 1: Both source and target cells are on air.
* Step 2: Ue is attached to cell A (asymmetric) and data traffic is possible.
* Step 3.1: NR5G MAC RACH Trigger reason is HANDOVER in both HO cases
* Step 3.2: NR5G MAC RACH Attempt result is SUCCESS in both HO cases
* Step 4: Counter M55139C02502 is incremented.


#### Automatic TC steps
* Preconditions
    * UE Is Ready For Test
    * 1min counters flag is activated
    * QXDM and QCAT license is reserved
    * Source cell is unattenuated
* Step 1:
    * UE Attach
* Step 2:
    * Collect counters
* Step 3: 
    * RRC Logs are started
    * Data Transfer is started
    * HO is performed from cell A(asymmetric) to cell B(symmetric)
    * HO is performed from cell B(symmetric) to cell A(asymmetric)
    * RRC Logs are collected
* Step 4:
    * Check RRC Logs for handover messages
    * Check Counter M55139C02502


#### History of changes
* 09.11.2022 - Initial creation https://jiradc.ext.net.nokia.com/browse/IWK-836
* 16.01.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1181 - Parametrize value of 3gpp.subcellid in keywords 
  Extract And Analyze PDSCHSendReq From BIP and Extract And Analyze CSIRSSendReq From BIP
* 13.02.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1207 - parametrize values of UE and attenuator aliases
* 29.04.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1277 - change counter collection from 1min to value of miNrRSADU, remove adding/removing 1min counter flag from swconfig; 
             - https://jiradc.ext.net.nokia.com/browse/IWK-1278 - remove CB007813-B functionality due to CNI-110957
* 25.06.2024 - https://jiradc.ext.net.nokia.com/browse/IWK-1317 - change maintainer of the TC
* 16.04.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1455 - increased number of attempts to obtain Qualcomm licenses
* 23.06.2025 - https://jiradc.ext.net.nokia.com/browse/IWK-1503 - License Keeper login/password changed 