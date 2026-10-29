import subprocess
import time

"""
Author : arunkumar.a@nokia.com
Module used with data Traffic handler over iperf2 . Main scope is Quectel Device like BG95.
"""


class Traffic_handler(object):

    def udp_data_transfer(self, ue_ip=None, ftpserverip=None, ftpusername=None, ftppassword=None,
                          length=10, intervel=1, timeout=10, sizeofdata="100K"):
        '''
        Using ftp server transfering data through UDP.
        ue_ip: "at+cgpaddr" can provide it. or taf.ue.get_ue can return ue ip
        ftpserverip: Jumbo server ( Try mnaully once because of not Guarenty )
        ftpusername & ftppassword: use "ftpuser"
        sizeofdata : (in bytes) 100K
        '''
        try:
            print("[ INFO ]: UDP Data Tranfer started.")

            command = "sshpass -p " + ftppassword + \
                      " ssh " + str(ftpusername) + "@" + str(ftpserverip) + " 'hostname; iperf -u -c " + \
                      str(ue_ip) + " -l " + str(length) + " -i " + str(intervel) + \
                      " -t " + str(timeout) + " -b " + str(sizeofdata) + " \'"
            print(f"Using IPERF command: {command}")
            result = subprocess.call(command,
                                     stdin=None,
                                     stdout=None,
                                     shell=True, )
            if result == 0:
                print(f"UDP Data Transfer is successful. Return code: {result}")
            else:
                print(f"UDP Data Transfer Failed. Return code: {result}")
            return result
        except subprocess.CalledProcessError as err:
            raise err("UDP Data Transfer failed.\ncheck in suprocess call function")
