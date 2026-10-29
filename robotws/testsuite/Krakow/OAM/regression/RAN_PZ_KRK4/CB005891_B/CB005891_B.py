import glob
from taf.nms.netact.ssh_node import SshNode as SshNode
from taf.ul.oam_kpi_calculations import oam_kpi_calculations
from robot.libraries.BuiltIn import logger
from taf.sbts.oam.coam.admin import admin


def reset_asirmod_from_netact(netact_address, netact_username, netact_password):
    netact1046 = SshNode(netact_address, netact_username, netact_password)
    netact1046.connect()
    netact1046.execute_command(
        "racclimx.sh -op Reset_NE -DN PLMN-PLMN/MRBTS-76148/EQM-1/APEQM-1/ASIRMOD-7,"
        "PLMN-PLMN/MRBTS-76148/EQM-1/APEQM-1/ASIRMOD-4,"
        "PLMN-PLMN/MRBTS-76148/EQM-1/APEQM-1/ASIRMOD-2 -v"
    )
    netact1046.disconnect()


def check_reset_time_based_on_kpi(ims_dir, kpi_name, timeout):
    ims_file = glob.glob(ims_dir + "/**/*.ims2", recursive=True)
    kpi = oam_kpi_calculations()
    kpi_res = kpi.calculate_kpis(kpi_names=[kpi_name], ims_file_path=ims_file)

    if int(kpi_res[kpi_name][0]["delta"].seconds) < int(timeout):
        logger.info(f"Reset time ({kpi_res[kpi_name][0]['delta'].seconds})s "
                    f"has NOT exceeded the given timeout ({timeout})s.")
    else:
        raise TimeoutError(
            f"Reset time ({kpi_res[kpi_name][0]['delta'].seconds})s has exceeded the given timeout ({timeout})s."
        )


def connect_and_start_ip_traffic_capturing(measurement_point, uplane_capturing):
    admin_obj = admin()
    admin_connection = admin_obj.connect_to()
    admin_obj.start_ip_capture_file(measurement_point, uplane_capturing, connection=admin_connection)


def stop_ip_traffic_capturing_download_file_and_disconnect(target_file_name):
    admin_obj = admin()
    admin_connection = admin_obj.connect_to()
    admin_obj.stop_ip_capture_file(connection=admin_connection)
    admin_obj.generate_ip_capture_file(connection=admin_connection)
    admin_obj.download_ip_capture_file(target_file_name, connection=admin_connection)
