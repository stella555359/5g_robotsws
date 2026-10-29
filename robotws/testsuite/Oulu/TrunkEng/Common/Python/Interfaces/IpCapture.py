from datetime import datetime

from robot.libraries.BuiltIn import BuiltIn

from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import error, info


class IpCapture:
    """
    Class for IP traffic capturing. Atm. supports only file capturing.
    Basic usage:
    Library           testsuite.Oulu.TrunkEng.Common.Python.Interfaces.IpCapture   WITH NAME   IpCapture
    IpCapture.start_ip_capture_file    measurement_point=NE_Terminated/Transport_Interface
    IpCapture.stop_and_download_ip_capture_file
    """

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.logger = BuiltIn().get_library_instance("LOG")

    def start_ip_capture_file(
        self,
        measurement_point,
        uplane_capturing=True,
        password=None,
        timeout=120,
        alias=None,
    ):
        info(f"Starting IP capture file for measurement point {measurement_point}")
        output = self.admin.start_ip_capture_file(
            measurement_point, uplane_capturing, password, timeout, alias
        )
        if isinstance(output, str):
            if "Succeeded" in output:
                info(
                    f"IP capture file started successfully for measurement point {measurement_point}"
                )
                return True
            else:
                error(
                    f"Failed to start IP capture file for measurement point {measurement_point}. Status is {output}"
                )
                return False
        else:
            info(
                f"IP capture file started successfully for measurement point {measurement_point}. "
                f"Detailed output: {output}"
            )
            return output

    def stop_ip_capture_file(self, timeout=120, alias=None, detailed_output=False):
        info("Stopping IP capture file")
        output = self.admin.stop_ip_capture_file(timeout, alias, detailed_output)
        if isinstance(output, str):
            if "Succeeded" in output:
                info("IP capture file stopped successfully")
                return True
            else:
                error(f"Failed to stop IP capture file. Status is {output}")
                return False
        else:
            info(f"IP capture file stopped successfully. Detailed output: {output}")
            return output

    def generate_ip_capture_file(
        self, password="", timeout=120, alias=None, detailed_output=False
    ):
        info("Generating IP capture file")
        output = self.admin.generate_ip_capture_file(
            password, timeout, alias, detailed_output
        )
        if isinstance(output, str):
            if "Succeeded" in output:
                info("IP capture file generated successfully")
                return True
            else:
                error(f"Failed to generate IP capture file. Status is {output}")
                return False
        else:
            info(f"IP capture file generated successfully. Detailed output: {output}")
            return output

    def download_ip_capture_file(
        self, target_file_name, timeout=120, alias=None, detailed_output=False
    ):
        info(f"Downloading IP capture file to {target_file_name}")
        output = self.admin.download_ip_capture_file(
            target_file_name, timeout, alias, detailed_output
        )
        if isinstance(output, str):
            if "Download file succeeded" in output:
                info(f"IP capture file downloaded successfully to {target_file_name}")
                return True
            else:
                error(
                    f"Failed to download IP capture file to {target_file_name}. Status is {output}"
                )
                return False
        else:
            info(
                f"IP capture file downloaded successfully to {target_file_name}. Detailed output: {output}"
            )
            return output

    def stop_and_download_ip_capture_file(
        self,
        password="",
        target_file_name="",
        timeout=120,
        alias=None,
        detailed_output=False,
    ):
        self.stop_ip_capture_file(timeout, alias, detailed_output)
        self.generate_ip_capture_file(password, timeout, alias, detailed_output)
        if not target_file_name:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            target_file_name = (
                self.logger.log_dir + f"/ip_capture_file_{timestamp}.pcap"
            )
        self.download_ip_capture_file(target_file_name, timeout, alias, detailed_output)
