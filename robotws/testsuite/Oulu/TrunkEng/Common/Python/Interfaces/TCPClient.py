import socket as s
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import TCPFailure


class TCPClient:

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")

    @staticmethod
    def send_and_receive_tcp(ip_address, port, message, first_receive=False, print_output=False):
        try:
            with s.socket(s.AF_INET, s.SOCK_STREAM) as tcp_socket:
                tcp_socket.settimeout(10)
                tcp_socket.connect((ip_address, port))
                if first_receive:
                    tcp_socket.recv(1024)
                if print_output:
                    info("Sending message: {}".format(message))
                message += "\r\n"
                tcp_socket.sendall(message.encode())
                received_data = tcp_socket.recv(1024)
                received_data = received_data.decode()
                if print_output:
                    info("Received data: {}".format(received_data))
                return received_data
        except OSError as e:
            error("OSError occurred\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "No space left on device" in str(e):
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
            raise TCPFailure
        finally:
            tcp_socket.close()
