"""
:copyright: Nokia Networks
:author: Mateusz Pajor
:maintainer: Mateusz Pajor, Jakub Wachal, Mateusz Plinta
:contact: mateusz.pajor@nokia.com, jakub.wachal@nokia.com, mateusz.plinta@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG, MN_RAN_L2_SW_2_KRK_Vrf_SG
"""

import os

from robot.libraries.BuiltIn import BuiltIn

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.iphy_management import IphyManagement
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_airphone import get_sw_values_from_targetbd
from log_collection import get_test_log_dirpath
from variables import *


def prepare_iphy_file_default(iphy_filename="iphy_A_B3XX.xml", dest_filepath=None):
    iphy_file_local_path = os.path.join(RESOURCES_PATH, "iphy_config", iphy_filename)
    dest_filepath = dest_filepath or os.path.join(get_test_log_dirpath(), "test_adapted_iphy.xml")
    iphy_instance = CustomIphyManagement(source_local_iphy_path=iphy_file_local_path)
    iphy_instance.update_sw_and_bld_version(ru_type="AWEUB")
    iphy_instance.delete_cells(re_index=1)
    iphy_instance.add_cells()
    iphy_instance.change_gscn()
    iphy_instance.save_iphy_to_file(dest_filepath)
    iphy_instance.upload_iphy_to_airphone()
    iphy_instance.symlink_iphy_file_in_airphone()


def prepare_iphy_file_b6(iphy_filename="iphy_A_B3XX.xml", dest_filepath=None):
    iphy_file_local_path = os.path.join(RESOURCES_PATH, "iphy_config", iphy_filename)
    dest_filepath = dest_filepath or os.path.join(get_test_log_dirpath(), "test_adapted_iphy.xml")
    iphy_instance = CustomIphyManagement(source_local_iphy_path=iphy_file_local_path)
    iphy_instance.update_sw_and_bld_version(ru_type="AWEUB")
    iphy_instance.delete_cells(re_index=1)
    iphy_instance.add_cells(cell_subcell_map=DEFAULT_CELL_SUBCELL_MAP)
    iphy_instance.change_gscn()
    iphy_instance.add_aweua_fr2_cells()
    iphy_instance.save_iphy_to_file(dest_filepath)
    iphy_instance.upload_iphy_to_airphone()
    iphy_instance.symlink_iphy_file_in_airphone()


def prepare_iphy_file_b7(iphy_filename="iphy_A_B3XX.xml", dest_filepath=None):
    iphy_file_local_path = os.path.join(RESOURCES_PATH, "iphy_config", iphy_filename)
    dest_filepath = dest_filepath or os.path.join(get_test_log_dirpath(), "test_adapted_iphy.xml")
    iphy_instance = CustomIphyManagement(source_local_iphy_path=iphy_file_local_path)
    iphy_instance.update_sw_and_bld_version(ru_type="AWEUB")
    iphy_instance.delete_cells(re_index=1)
    iphy_instance.add_cells(cell_subcell_map=DEFAULT_CELL_SUBCELL_MAP)
    iphy_instance.change_gscn()
    iphy_instance.add_aeqe_fr1_cells()
    iphy_instance.save_iphy_to_file(dest_filepath)
    iphy_instance.upload_iphy_to_airphone()
    iphy_instance.symlink_iphy_file_in_airphone()


def prepare_iphy_file_d_b102(iphy_filename="iphy_A_B3XX.xml", dest_filepath=None):
    iphy_file_local_path = os.path.join(RESOURCES_PATH, "iphy_config", iphy_filename)
    dest_filepath = dest_filepath or os.path.join(get_test_log_dirpath(), "test_adapted_iphy.xml")
    iphy_instance = CustomIphyManagement(source_local_iphy_path=iphy_file_local_path)
    iphy_instance.update_sw_and_bld_version(ru_type="AWEUB")
    iphy_instance.delete_cells(re_index=1)
    iphy_instance.add_cells()
    iphy_instance.change_gscn()
    iphy_instance.add_aweub_radio_head()
    iphy_instance.save_iphy_to_file(dest_filepath)
    iphy_instance.upload_iphy_to_airphone()
    iphy_instance.symlink_iphy_file_in_airphone()


def restore_default_iphy():
    iphy_instance = IphyManagement(source_local_iphy_path=BASE_IPHY_PATH)
    iphy_instance.upload_iphy_to_airphone()
    iphy_instance.symlink_iphy_file_in_airphone()


def prepare_iphy_file(dest_filepath=None):
    suite_name = BuiltIn().get_variable_value("${SUITE_NAME}")
    if "A-B6" in suite_name:
        prepare_iphy_file_b6(dest_filepath=dest_filepath)
    elif "A-B7" in suite_name:
        prepare_iphy_file_b7(dest_filepath=dest_filepath)
    elif "D-B102" in suite_name:
        prepare_iphy_file_d_b102(dest_filepath=dest_filepath)
    else:
        prepare_iphy_file_default(dest_filepath=dest_filepath)


# code for future reference; will be deleted if not used at the end of the feature
def prepare_iphy_file_depreciated(iphy_filename, dl_ul_subcells=None, gscn_value=None, scs_ssb_value=None):
    iphy_instance = CustomIphyManagement(
        source_local_iphy_path=os.path.join(RESOURCES_PATH, "iphy_config", iphy_filename)
    )
    iphy_instance.load_iphy_contents_from_airphone()
    iphy_instance.update_sw_and_bld_version(ru_type="AWEUB")
    iphy_instance.change_radio_unit_type(ru_type="AWEUB", resource_build_key="")
    iphy_instance.delete_additional_radio_heads(re_index_to_omit=4)
    iphy_instance.delete_cells(re_index=1)
    iphy_instance.change_product_code_value(product_code="475167A", re_index=1)
    iphy_instance.adjust_first_optlink_values()
    iphy_instance.add_optlink_to_optlink_list(physicalId="2.7", virtualId="2", linkRate="25", rat="5G", re_index=1)
    iphy_instance.add_cells(dl_ul_subcells=dl_ul_subcells)
    iphy_instance.change_gscn(gscn_value=gscn_value)
    iphy_instance.change_scs_ssb(scs_ssb_value=scs_ssb_value)
    iphy_instance.upload_iphy_to_airphone()
    iphy_instance.symlink_iphy_file_in_airphone()


class CustomIphyManagement(IphyManagement):

    def adjust_first_optlink_values(self):
        first_optlink_aweub_changes = {
            "CPRI-Config/CPRI-RP1-RE_List/RE/hardware/optlink_List/optlink[1]/physicalId": "2.1",
            "CPRI-Config/CPRI-RP1-RE_List/RE/hardware/optlink_List/optlink[1]/linkRate": "25"
        }
        for path, value in first_optlink_aweub_changes.items():
            self.modify_scalar_element(path, value)

    def change_gscn(self, gscn_value=None, re_index=1):
        """
        Function to modify GSCN value in iphy file for each cell separately and upload to AP
        :param gscn_value: (dict) GSCN parameter value in dict format e.g gscn_value={"1": "22446", "2": "22452"}
        :param re_index: (int) Index of RE element; default to 1, so to the first radio head definition
        """
        if gscn_value is None:
            gscn_value = {51: "22446", 52: "22452", 53: "22458", 54: "22464",
                          55: "22470", 56: "22476", 57: "22482", 58: "22488"}
        if gscn_value:
            for key, value in gscn_value.items():
                cell_index = str(key)[1]
                re_path = self.get_radio_entity_path(index=re_index)
                path = re_path + f"/hardware/vcellList/vcell[{cell_index}]/GSCN"
                self.modify_scalar_element(path, value)
        else:
            raise ValueError("No GSCN value specified")

    def change_scs_ssb(self, scs_ssb_value=None):
        """
        Change <SCS_SSB></SCS_SSB> value in iphy file and upload to AP.
        :param scs_ssb_value: (dict) Modify SCS_SSB value in iphy.xml e.g. <SCS_SSB>240</SCS_SSB>
        :return: None
        """
        if scs_ssb_value is None:
            scs_ssb_value = {51: "240", 52: "240", 53: "240", 54: "240",
                             55: "240", 56: "240", 57: "240", 58: "240"}
        if scs_ssb_value:
            for key, value in scs_ssb_value.items():
                cell_index = str(key)[1]
                path = f"CPRI-Config/CPRI-RP1-RE_List/RE/hardware/vcellList/vcell[{cell_index}]/SCS_SSB"
                self.modify_scalar_element(path, value)
        else:
            raise ValueError("No SCS_SSB value specified")

    def add_cells(self, cell_subcell_map=None, re_index=1):
        """
        Function to add cells object in iphy file. For each cell user can specify direction of cell: DL or DL/UL

        :param cell_subcell_map: (dict) cell_subcell_map,
        :param re_index: (int) Index of RE element; default to 1, so to the first radio head definition
        """
        if cell_subcell_map is None:
            cell_subcell_map = BuiltIn().get_variable_value("${CELL_SUBCELL_MAP}") or DEFAULT_CELL_SUBCELL_MAP
        if cell_subcell_map:
            for key, value in cell_subcell_map.items():
                cell_index = str(key)[1]
                if "UL" in value:
                    cell_obj = f"<vcell>\n<cell>2.{cell_index}</cell>\n<phy_cell_id>{key}</phy_cell_id>" \
                        "\n<GSCN>22446</GSCN>" \
                        "\n<SCS_SSB>240</SCS_SSB>" \
                        "\n</vcell>"
                else:
                    cell_obj = f"<vcell>\n<cell>2.{cell_index}</cell>\n<phy_cell_id>{key}</phy_cell_id>" \
                        "\n<GSCN>22446</GSCN>" \
                        "\n<SCS_SSB>240</SCS_SSB>" \
                        "\n</vcell>"
                re_path = self.get_radio_entity_path(index=re_index)
                vcell_path = re_path + "/hardware/vcellList"
                self.add_element(path=vcell_path, value=cell_obj, index=None)
        else:
            raise ValueError("No cells directions in IPHY file specified")

    def add_aeqe_fr1_cells(self):
        sw_file_key_dictionary = get_sw_values_from_targetbd(ru_type="AEQE", resource_build_key="LTX_AEQE_E1")
        additional_aeqe_ru = AEQE_RADIO_HEAD
        formatted_additional_aeqe_ru = additional_aeqe_ru.format(
            build_version=sw_file_key_dictionary["resource_sw_version"],
            sw_version="".join(sw_file_key_dictionary["sw_file_key"]))

        self.add_element(path="CPRI-Config/CPRI-RP1-RE_List", value=formatted_additional_aeqe_ru)

    def add_aweua_fr2_cells(self):
        sw_file_key_dictionary = get_sw_values_from_targetbd(ru_type="AWEUA", resource_build_key="LTX_AWEUA")
        additional_aweua_ru = AWEUA_RADIO_HEAD
        formatted_additional_aweua_ru = additional_aweua_ru.format(
            build_version=sw_file_key_dictionary["resource_sw_version"],
            sw_version="".join(sw_file_key_dictionary["sw_file_key"]))

        self.add_element(path="CPRI-Config/CPRI-RP1-RE_List", value=formatted_additional_aweua_ru)

    def add_aweub_radio_head(self):
        sw_file_key_dictionary = get_sw_values_from_targetbd(ru_type="AWEUB", resource_build_key="LTX_AWEUB")
        additional_aweub_ru = AWEUB_RADIO_HEAD
        formatted_additional_aweub_ru = additional_aweub_ru.format(
            build_version=sw_file_key_dictionary["resource_sw_version"],
            sw_version="".join(sw_file_key_dictionary["sw_file_key"]))

        self.add_element(path="CPRI-Config/CPRI-RP1-RE_List", value=formatted_additional_aweub_ru)
