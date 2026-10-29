*** Settings ***

Documentation     [SUITE PURPOSE]   feature CB013098-SR_A Parameter modification type improvement part 3
...               Prerequisite      : gNB configured with 6 Cells
...               Scope             : TBD
...
...               Test Case Scenario author   : philippe.daroux@nokia.com
...               Creation Date               : 14-08-2025
...               Modified Date               : 16-09-2025
...               Last Modified by            : philippe.daroux@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2507    philippe.daroux@nokia.com             Creation

Resource          ./resources/robot/CB013098_SR-Common-Keywords.robot
Resource          ./resources/robot/CB013098_SR-Keywords.robot


Force Tags        CA_5G_SW_FR-Villarceaux    RRM
...               PY39
...               CLOUD_5G_I_MP_AP_LOOO    SANSA_FS_ECPRI_CMWV_TDD
...               master_classicalbts_all    SBTS00
...               RAN_5G_TDD     CONFIGURED    5G_RAN    RAN_5G    CRT



Suite Setup       CB013098_SR-Common-Keywords.Suite Setup CB013098
...               yaml_file_path=${CURDIR}/../../../../../custom-config/ParisSaclay/CB013098/CB013098_SR_A/custom_config_ABIP_Dedicated.yaml


*** Variables ***
&{TC_6_Cells}                                                       nbCell=6

# ---------------------------------------------------------------------------------------------------------------
*** Test Cases ***


[1]CB013098_SR
    [Documentation]     CB013098-SR Parameter modification type improvement part 3
    ...                 Conditions:
    ...                     6 TDD Cells on ABIP
    ...                       ActmultiplededicatedBwp=TRUE
    ...                       actGnbInitRlf=TRUE
    ...                       actGnbInitRlf=TRUE
    ...                       Bwp44=large Band
    ...                       Bwp55=small band
    ...                       Bwp66=powersaving
    ...                     NRCELL-1 (50) set to Large and small band
    ...                     NRCELL-2 (51) set to large band
    ...                     NRCELL-3 (52) set to large and small band as well as power saving
    ...                     NRCELL3(linked to RLF):
    ...                     rlpDetDlHarqThreshold=12
    ...                     tRLFindForDU=3000ms
    ...                     tWaitingRlRecover">30000ms
    ...                     rlpRecDlHarqThreshold=2
    ...
    ...
    ...                 STEP1 actMultipleDedicatedBWPs Online modification
    ...                     1) cell setup with 6 TDD
    ...                     2) Call setup with DL+UL traffic, all Ues support large band by default except Ue4 supporting small band
    ...                         NRCELL-1 (50) : 1 SA UE, UE id 1, DL 175mbps + UL 75mbps;
    ...                         NRCELL-2 (51) : 1 SA UE, UE id 2, DL 175mbps + UL 75mbps;
    ...                         NRCELL-3 (52) : 1 SA UE, UE id 3, DL 175mbps + UL 75mbps;
    ...                         NRCELL-3 (52) : 1 SA UE, UE id 4(supporting small band only), DL 175mbps + UL 75mbps;
    ...                         NRCELL-3 (52) : 1 NSA UE, UE id 5, DL 175mbps + UL 75mbps;
    ...                     3) Deactivated actMultipleDedicatedBWPs
    ...                     4) Detach all Ues
    ...                     5) Attach all Ues
    ...                         Checks:
    ...                         UE4 can no more attach (Cell3 does no more support Small band
    ...                        Call setup with DL+UL traffic is possible only on Ues supporting large band
    ...                     4) Detach all Ues
    ...
    ...                 STEP2 powerSavingBwpSwitching threshold Online modification
    ...                     1) Call setup with DL+UL traffic
    ...                         NRCELL-3 (52) : 1 SA UE, UE id 3,(supporting power saving)
    ...                         Send DL and UL traffic in order to be at the border of powerSaving switching
    ...                         Checks: On egate console that UE3 is BWP1(meaning Dedicated band)
    ...                     2) modify all powerSavingBwpSwitching threshold by tunning
    ...                        the DL/UL switching from dedicated to power saving BW
    ...                                 <list name="powerSavingBwpSwitching">
    ...                                 <p name="dlBufferEmptyRatioFromPsBwp">40</p>
    ...                                 <p name="dlBufferEmptyRatioToPsBwp">90</p>
    ...                                 <p name="dlRateThresholdFromPsBwp">500</p>
    ...                                 <p name="dlRateThresholdToPsBwp">100</p>
    ...                                 <p name="mcsThresholdVoNRFromPsBwp">4</p>
    ...                                 <p name="mcsThresholdVoNRToPsBwp">5</p>
    ...                                 <p name="measurementDurationFromPsBwp">160</p>
    ...                                 <p name="measurementDurationToPsBwp">640</p>
    ...                                 <p name="ulBufferEmptyRatioFromPsBwp">40</p>
    ...                                 <p name="ulBufferEmptyRatioToPsBwp">90</p>
    ...                                 <p name="ulRateThresholdNoVoNRFromPsBwp">100</p>
    ...                                 <p name="ulRateThresholdNoVoNRToPsBwp">80</p>
    ...                                 <p name="ulRateThresholdVoNRFromPsBwp">100</p>
    ...                                 <p name="ulRateThresholdVoNRToPsBwp">80</p>
    ...                         Checks:
    ...                         On egate console that UE3 switched from BWP1 to BWP2 (meaning swtched to power saving)
    ...                     3) Detach all Ues
    ...
    ...                 STEP3 actGnbInitRlf Online modification
    ...                     1) Attach UE3(SA) and UE5(NSA) on Cell3
    ...                     2) Call setup with DL+UL traffic
    ...                     3) set actGnbInitRlf to FALSE
    ...                     4) Generate RLF on UE3 and UE5
    ...                         Checks:
    ...                         NO RRCRelease message is sent this F1AP message with:
    ...                         cause value of 'rl-failure-others' to gNB-CU-CP to indicate the RLF happened
    ...                     5) Detach all Ues
    ...                     1) Attach UE3(SA) and UE5(NSA) on Cell3
    ...                     2) Call setup with DL+UL traffic
    ...                     3) set actGnbInitRlf to TRUE
    ...                     4) Generate RLF on UE3 and UE5
    ...                         Checks:
    ...                         gNB-DU sends F1AP: UE CONTEXT MODIFICATION REQUIRED message with:
    ...                         cause value of 'rl-failure-others' to gNB-CU-CP to indicate the RLF happened.

   # TEST
    TC CB013098-DL-UL-Traffic             UEdefListparam=${UE_Def_DL_UL_List_SA_NSA}
    #[Teardown]      CB013199-Common-Keywords.End Of TC
