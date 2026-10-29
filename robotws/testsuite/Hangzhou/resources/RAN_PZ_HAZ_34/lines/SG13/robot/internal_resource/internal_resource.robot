*** Settings ***
Documentation    :copyright: Nokia
...              :contact: I_NSB_MN_RAN_RD_VRF_HAZ4_13@internal.nsn.com


Library     ../../python/lib/check_btslog.py
Library     ../../python/lib/access_env_info.py
#Library     ../../python/lib/CB008322_spill_srsswitchmeasurement.py
Library     tak_files
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library     ta_a2a
Library     ../../python/tak_pa/
Library     ../../python/tak_mcs/
Library     DateTime
Library     Collections
Library     OperatingSystem
Library     taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
Library     ../../python/scfc_modify/
Resource    internal_capture_log.robot
Resource    internal_airphone.robot
Resource    internal_gnb.robot
Resource    internal_check_log.robot
Resource    internal_qualcomm.robot
Resource    internal_mcs.robot
Resource    internal_spark.robot
Resource    internal_counter.robot


