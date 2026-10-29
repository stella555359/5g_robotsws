import testsuite.Wroclaw.OAM.VRF_WRO3_T04.common_resources.scf.scf_operations as scf_operations
from taf.config.scf.interface import scf
from robot.api.logger import console
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.scf.exceptions import ElementNotFound
scf = scf()


def prepare_NTP_configuration(base_scf_path, new_scf_path):
    console("scf NTP setup...")
    scf.load_scf(file_path=base_scf_path)
    mrbts_id = scf_operations.get_mo_id(scf_path=base_scf_path, mo_name="MRBTS")
    _set_ntp_object(mrbts_id=mrbts_id)
    scf.save_scf(file_path=new_scf_path)
    console("SCF file with NTP has been prepared.")
    return new_scf_path


def _set_ntp_object(mrbts_id):
    console("Setting NTP object...")
    if scf.is_object_in_scf(dist_name="MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1".format(mrbts_id)):
        scf.remove_mo_with_descendant_mos(
            dist_name="MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1".format(mrbts_id)
        )
    version = scf.get_mo_attribute(
        dist_name="MRBTS-{}/MNL-1/MNLENT-1/SYNC-1".format(mrbts_id),
        attribute="version"
    )
    scf.add_object_to_scf(
        dist_name="MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1".format(mrbts_id),
        class_name="com.nokia.srbts.mnl:NTP",
        version=version
    )
    scf.add_element_to_scf(
        dist_name="MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1".format(mrbts_id),
        p_name="ntpAlarmingThreshold",
        value="300"
    )
    scf.add_element_to_scf(
        dist_name="MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1".format(mrbts_id),
        p_name="ntpDscp",
        value="46"
    )
    scf.add_list_to_scf(
        dist_name="MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1".format(mrbts_id),
        list_name="ntpServerIpAddrOrFqdnList",
    )
    scf.add_elements_to_list(
        dist_name="MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1".format(mrbts_id),
        list_name="ntpServerIpAddrOrFqdnList",
        elements=["10.42.187.248"]
    )
