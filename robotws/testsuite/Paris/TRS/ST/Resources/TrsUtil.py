import sys
import paramiko
import re
import time
from datetime import datetime


class TrsUtil(object):

    #
    # Convertion DateTime format of WebEm into number of seconds
    #
    def ConvertWebTime(self, valeur):

        forme = re.compile(r"(\d{2})-(\d{2}):(\d{2}):(\d{2})")
        exp = forme.match(valeur)

        if exp:
            secondes = ((24 * int(exp.group(1)) + int(exp.group(2))) * 60 + int(exp.group(3))) * 60 + int(exp.group(4))
            return secondes

        else:
            return 0

    #
    # Check presence of regular expression in BTSlog between two datetime
    #
    def CheckBtsLog(self, vm_ip, username, password, begin_date, end_date, ligne):

        # vm_ip="10.14.38.147"
        # username = "localuser"
        # password = "10c@1user"
        # begin_date="2023-01-17 13:30:00"
        # end_date="2023-01-17 15:00:00"
        # ligne=".*sending FeaturesSyncStatusInd.*interEnbCa=1.*"
        port = 22

        chaine = ".*<(.*T.*)>{contenu}".format(contenu=ligne)
        recherche = re.compile(chaine)

        # Connection
        try:
            client_ssh = paramiko.SSHClient()
            client_ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            client_ssh.connect(vm_ip, port=port, username=username, password=password)

            command = "cat `ls -rt /tmp/btslog2/*LOG` > /tmp/theBtsLog.txt"
            stdin, stdout, stderr = client_ssh.exec_command(command)

            sftp = client_ssh.open_sftp()
            sftp.get("/tmp/theBtsLog.txt", "/tmp/theBtsLog.txt")

            command = "rm /tmp/theBtsLog.txt"
            stdin, stdout, stderr = client_ssh.exec_command(command)

        # VM is not reachable
        except paramiko.SSHException:
            print("can't open connection")
            return 0

        finally:
            client_ssh.close()

        logFile = open("/tmp/theBtsLog.txt", "r")

        time_begin = datetime.strptime(begin_date, '%Y-%m-%d %H:%M:%S.%f')
        time_end = datetime.strptime(end_date, '%Y-%m-%d %H:%M:%S.%f')

        for line in logFile:

            test = recherche.match(line)

            if test:
                time_event = datetime.strptime(test.group(1), '%Y-%m-%dT%H:%M:%S.%f')
                if (time_event >= time_begin and time_event <= time_end):
                    return True

        return False

    #
    # Check if two values are equal +/- error
    #
    def ShouldBeQuiteEqual(self, val1, val2, error):
        if abs(abs(float(val1)) - abs(float(val2))) < float(error):
            return True
        else:
            return False

    #
    # Check if a string contains another
    #
    def ContainsSubstring(self, mainstr, substr):
        if substr in mainstr:
            return True
        else:
            return False
