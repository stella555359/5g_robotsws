import ta5g_testline_management
import ta5g_setups_and_teardowns
import ta5g_iphy
import ta5g_commissioning
import ta5g_ue_measurements
import ta5g_enb


def setup_cloud_bts(iphy_xml_filepath=None, scfc_filepath_cu=None, scfc_filename_du1=None, scfc_filename_du2=None,
                    output_dirpath=None, perform_additional_tl_reset=False):
    ta5g_setups_and_teardowns().start_default_logging(output_dirpath=output_dirpath)
    try:
        if iphy_xml_filepath:
            ta5g_iphy().update_and_put_iphy_xml_aic(input_filepath=iphy_xml_filepath, output_dirpath=output_dirpath)
        if scfc_filepath_cu:
            ta5g_commissioning().perform_commissioning_vcu_aic(path_to_plan_file=scfc_filepath_cu)
        if scfc_filename_du1:
            ta5g_commissioning().find_scfc_and_fix_and_send_full_commissioning_vdu(scfc_filename=scfc_filename_du1,
                                                                                   vdu=1)
        if scfc_filename_du2:
            ta5g_commissioning().find_scfc_and_fix_and_send_full_commissioning_vdu(scfc_filename=scfc_filename_du2,
                                                                                   vdu=2)

        if perform_additional_tl_reset:
            ta5g_testline_management().trigger_site_reset_aic_vcu()
            ta5g_testline_management().trigger_site_reset_aic_vdu(vdu=1)
            if scfc_filename_du2:
                ta5g_testline_management().trigger_site_reset_aic_vdu(vdu=2)
        ta5g_iphy().wait_for_all_radios_to_be_enabled_aic(number_of_vdu=2)
    finally:
        ta5g_setups_and_teardowns().stop_default_logging(output_dirpath=output_dirpath)
