"""
Global static variables for XPATH in PCAP parsed to PDML format

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""

RLMC_PSCELL = "//nr-rrc.mrdc_SecondaryCellGroup//nr-rrc.spCellConfig_element//nr-rrc.radioLinkMonitoringConfig"
RLMC_SCELLS = "//nr-rrc.mrdc_SecondaryCellGroup//nr-rrc.sCellToAddModList//nr-rrc.radioLinkMonitoringConfig"
BEAM_FAILURE_MAX_COUNT = RLMC_PSCELL + "//nr-rrc.beamFailureInstanceMaxCount"
BEAM_FAILURE_DETECT = RLMC_PSCELL + "//nr-rrc.beamFailureDetectionTimer"
FDRS_ELEM = RLMC_PSCELL + "//nr-rrc.failureDetectionResourcesToAddModList//nr-rrc.RadioLinkMonitoringRS_element"
FDRS_ID = FDRS_ELEM + "/nr-rrc.radioLinkMonitoringRS_Id"
FDRS_PURPOSE = FDRS_ELEM + "/nr-rrc.purpose"
