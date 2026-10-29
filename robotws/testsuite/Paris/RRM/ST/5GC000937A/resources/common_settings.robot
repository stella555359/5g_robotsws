*** Settings ***
Documentation
...      Purpose:
...         ll test Suites Libraries, Resources and Variables
...
...     AUTHOR (mmW&SC Pz NPS 4 SG):
...         I_MNP_5G_NPS_IVU_SISO_MOBILITY@nokia.coma

# External robot libraries:
# -------------------------
Library     OperatingSystem
Library     Collections
Library     XML
Library     String
Library     Process                      WITH NAME    process
Library     ArchiveLibrary               WITH NAME    archive

# Internal TAF libraries:
# -----------------------
Library     taf.ue                       WITH NAME    ue
Library     ute_ue
Library     taf.sw.reporting_portal     WITH NAME    ute_reporting_portal
Library     ute_tshark
Library     taf.hw.pdu                      WITH NAME    pdu
Library     taf.gnb.oam.commissioning    WITH NAME    commissioning
Library     taf.config.scf               WITH NAME    scf
Library     taf.transport.ssh            WITH NAME    ssh
Library     taf.analyzer.pcap            WITH NAME    cap
Library     taf.gnb.oam.coam.cu          WITH NAME    coam_cu
Library     taf.collectors.pmcounters    WITH NAME    tafpmcounters
Library     taf.collectors.journal       WITH NAME    journal
Library     taf.collectors.core          WITH NAME    core
Library     taf.collectors.tcpdump       WITH NAME    tcpdump

# Generique site Libraries/Resources:
# -----------------------------------
Library     ${CURDIR}/../../../../resources/ST/python/LK_manager.py    WITH NAME    LK
Library     ${CURDIR}/../../../../resources/ST/python/LK_handler.py

# Paris ST Libraries/Resources:
# --------------------------------------
Library     ${CURDIR}/../../resources/vm_handler.py
Library     ${CURDIR}/../../resources/custom_robot_keywords
Library     ${CURDIR}/../../resources/scf_parameters.py
Library     ${CURDIR}/../../resources/pm_analyze.py    WITH NAME      pm_analyze

# Test Suite Libraries/Resources:
# -------------------------------
Resource    ${CURDIR}/../resources/rp.robot
Resource    ${CURDIR}/../resources/kw.robot
Resource    ${CURDIR}/../resources/var.robot
Resource    ${CURDIR}/../resources/ue.robot
Resource    ${CURDIR}/../resources/pdu.robot
Resource    ${CURDIR}/../resources/lk.robot
Resource    ${CURDIR}/../resources/hytem.robot
Resource    ${CURDIR}/../resources/keywordbook-480.robot
Resource    ${CURDIR}/../resources/keywordbook-480_ext01.robot
Resource    ${CURDIR}/../resources/keywordbook-2056.robot
Resource    ${CURDIR}/../resources/keywordbook-937A033.robot
Variables   ${CURDIR}/../filters/ue_message_checker.py
Variables   ${CURDIR}/../filters/xpath_vars_ext01.yaml
Variables   ${CURDIR}/../filters/wireshark_filter.yaml

Library     ${CURDIR}/../resources/common_import/python/coam_parameter.py
Resource    ${CURDIR}/../resources/common_import/reporting.robot
Resource    ${CURDIR}/../resources/common_import/coam_ulm.robot
Resource    ${CURDIR}/../resources/common_import/connect.robot
Resource    ${CURDIR}/../resources/common_import/gnb.robot
Resource    ${CURDIR}/../resources/common_import/tcpdump.robot
Resource    ${CURDIR}/../resources/common_import/ute_workarounds.robot

Variables   ${CURDIR}/../resources/site/python/custom.py

Resource    ${CURDIR}/../../resources/sg_radio_perf/robot/preconditions.robot
Resource    ${CURDIR}/../../resources/sg_radio_perf/robot/Commissioning.robot
