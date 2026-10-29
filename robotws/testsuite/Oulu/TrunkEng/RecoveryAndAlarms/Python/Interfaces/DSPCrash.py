import socket
import struct
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.bbmods_and_socs import get_kepler_hex, get_bbmod_hex_position
from testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Resources.exceptions import SocketError, FaultGenerationFailure


class DSPCrash:
    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.alarms = BuiltIn().get_library_instance("ALARMS")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")

        self._socket = None
        self._target_ip = "192.168.255.129"
        self._target_port = 15004

    def open_connection(self):
        info(f"Open connection to {self._target_ip}:{self._target_port}")
        try:
            self._socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self._socket.settimeout(10.0)
            self._socket.connect((self._target_ip, self._target_port))
            self._socket.settimeout(2.0)
            info("Connection established")
        except socket.error as e:
            error(f"Could not open connection to {self._target_ip}:{self._target_port}.\n"
                  f"Is R&D port service enabled? Try with argument --enableRnDPort\nError: {e}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise SocketError(f"Could not open connection to {self._target_ip}:{self._target_port}. Error: {e}")

    def close_connection(self):
        info("Closing connection")
        try:
            self._socket.close()
        except socket.error as e:
            error(f"Failure in closing socket. Error: {e}"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise SocketError(f"Failure in closing socket. Error: {e}")

    def send_silent_crash_to_kepler(self, bci, kepler):
        """
        Send silent crash to DSP.
        :param obj bci: BBMOD object.
        :param str kepler: Kepler name - K2A, K2B, K2C or K2D.
        """

        side = "left"
        if "right" in bci.hw_path.lower():
            side = "right"
        bbmod_hex = f"0x{get_bbmod_hex_position(bci.name, side)}"
        kepler_hex = get_kepler_hex(kepler)
        info(f"DEBUG - BBMOD HEX: {bbmod_hex} KEPLER HEX: {kepler_hex}")
        self._generate_silent_crash_to_dsp("kepler", bbmod_hex, kepler_hex)

    def _generate_silent_crash_to_dsp(self, dsp_type, bbmod_hex, soc_hex):
        """
        Generate silent crash to DSP.
        :param dsp_type: "nyquist", "faraday" or "kepler"
        :param bbmod_hex: BBMOD hex.
        :param soc_hex: SoC hex.
        """
        success = False
        try_ctr = 0
        while not success and try_ctr < 10:
            info(f"Generating silentCrash GPIO: 0 to BBMOD hex: {bbmod_hex} {dsp_type} hex: {soc_hex}")
            success = True
            disable_edc_address = "0x01846008"
            disable_edc_data = ["0x00000008"]
            disable_mem_protection_addr = "0x0184A200"
            disable_mem_protection_data = ["0x0000FF3F"]
            gpio_address = "0x00800080"
            gpio_data = ["0x0000A120"]
            cache_l1_d_wb_all_address = "0x01845044"
            cache_l1_d_wb_all_data = ["0x00000001"]
            cache_l1_p_inv_all_address = "0x01845028"
            cache_l1_p_inv_all_data = ["0x00000001"]
            try:
                if dsp_type == "nyquist":
                    dsp_cpu_list = [1, 3, 2, 4]
                elif dsp_type == "kepler":
                    dsp_cpu_list = [1, 3, 2, 4, 5, 6, 7, 8]
                else:
                    dsp_cpu_list = [1, 3, 2]
                for x in dsp_cpu_list:
                    info(f"Disabling EDC from {soc_hex[0:3]+str(x)}")
                    success = success and self._write_to_dsp_with_browser_dsp_mem_req(
                        disable_edc_address, disable_edc_data, bbmod_hex, soc_hex[0:3]+str(x))
                    info(f"Disabling memory protection from {soc_hex[0:3]+str(x)}")
                    success = success and self._write_to_dsp_with_browser_dsp_mem_req(
                        disable_mem_protection_addr, disable_mem_protection_data, bbmod_hex, soc_hex[0:3]+str(x))
                    info(f"Patching fsync interrupt vector with GPIO: 0 from {soc_hex[0:3]+str(x)}")
                    success = success and self._write_to_dsp_with_browser_dsp_mem_req(
                        gpio_address, gpio_data, bbmod_hex, soc_hex[0:3] + str(x))
                    info(f"Flushing L1D and L1P caches from {soc_hex[0:3]+str(x)}")
                    success = success and self._write_to_dsp_with_browser_dsp_mem_req(
                        cache_l1_d_wb_all_address, cache_l1_d_wb_all_data, bbmod_hex, soc_hex[0:3] + str(x))
                    success = success and self._write_to_dsp_with_browser_dsp_mem_req(
                        cache_l1_p_inv_all_address, cache_l1_p_inv_all_data, bbmod_hex, soc_hex[0:3] + str(x))
                    if not success:
                        info(f"ERROR: In generating silent crash with CPU: {soc_hex[0:3] + str(x)}")
            except TypeError as e:
                error(f"Failure when sending silentCrash to DSP: {e}"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if not success:
                BuiltIn().sleep("1min")
        if success:
            info("Silent crash generated successfully.")
        else:
            error("Failed to generate silent crash.")
            raise FaultGenerationFailure("Failed to generate silent crash.")

    def _write_to_dsp_with_browser_dsp_mem_req(self, source_address, source_data, bbmod_hex, soc_hex):
        try:
            browser_dsp_memory_req = self._generate_browser_dsp_memory_req_message(
                source_address, source_data, bbmod_hex, soc_hex)
            packed_message = self._create_message(browser_dsp_memory_req)
            self._socket.send(packed_message)
            return True
        except socket.error as e:
            error(f"Failure when sending BROWSER_DSP_MEMORY_REQ 0x1BEB to BTS: {e}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            return False

    @staticmethod
    def _generate_browser_dsp_memory_req_message(source_address, source_data, bbmod_hex, soc_hex):
        browser_dsp_mem_req = {"headerMsgId": "0x00001BEB",
                               "headerReceiver": f"{bbmod_hex}{soc_hex[2:4]}023B",
                               "headerSender": "0x10110308",
                               "headerLenght": "0x0020",
                               "headerFlags": "0x0000",
                               "writeData": "0x00000001",
                               "dataCount": "0x00000004",
                               "dspDataAddress": source_address,
                               "dspData": source_data[0]
                               }
        if len(source_data) > 1:
            for y in range(len(source_data) - 1):
                browser_dsp_mem_req[f"extraDspData{str(y+1)}"] = source_data[y + 1]
                browser_dsp_mem_req["dataCount"] = "0x%.8x" % int(eval(browser_dsp_mem_req.get("dataCount")) + 4)
                browser_dsp_mem_req["headerLenght"] = f"0x{int(eval(browser_dsp_mem_req.get('headerLenght')) + 4)}4x"
        return browser_dsp_mem_req

    @staticmethod
    def _create_message(message_content):
        """
        Create message from dictionary.
        :param message_content: dictionary
        """
        packed_message = bytearray()
        for key in message_content.keys():
            if len(message_content.get(key)) == 6:
                packed_message.extend(struct.pack("H", socket.htons(int(eval(message_content.get(key))))))
            elif len(message_content.get(key)) == 4:
                packed_message.extend(struct.pack("B", int(eval(message_content.get(key)))))
            else:
                packed_message.extend(struct.pack("I", socket.htonl(int(eval(message_content.get(key))))))
        return packed_message
