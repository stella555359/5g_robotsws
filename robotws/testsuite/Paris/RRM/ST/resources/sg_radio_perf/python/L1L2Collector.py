import os
import threading
import time
import taf.transport.ssh.interface as ssh


class L1L2Collector:
    def __init__(self):
        self._transferredFile = []
        self._allFilesTransferred = True
        self.sshManager = ssh.SSHManager()

    def _mainloop(self, tcpdumpFolder, destFolder):
        """
        Main collection loop - executed in parallel. Collect logs when they are available
        :param tcpdumpFolder: folder where to get the traces on the remote controller
        :param destFolder: folder where to put the traces on the local computer
        :return: N/A
        """
        try:
            os.makedirs(destFolder)
        except Exception:
            pass
        self._allFilesTransferred = False
        currentFileName = None
        while (not self._stopped) or (currentFileName is not None):
            time.sleep(5)
            currentFileName = self.getLastFile(tcpdumpFolder, destFolder)
            self._lastTransferredFile = currentFileName
        self._allFilesTransferred = True

    def startL1L2Collection(self, sourceItf, tcpdumpFolder, destFolder, controller, username, password):
        """
        Start the collection of pcap files on the controller
        :param sourceItf: interface where to get the traces
        :param tcpdumpFolder: folder where to get the traces on the remote controller
        :param destFolder: folder where to put the traces on the local computer
        :param controller: controller on which the traces will be taken address
        :param username: controller on which the traces will be taken username
        :param password: controller on which the traces will be taken password
        :return: N/A
        """
        self.sudo_password = password
        self.sshManager.connect_to(controller, username, password, alias='L1L2Connection')
        self.sshManager.execute('pkill -f "tcpdump -i %s"' % (sourceItf), connection='L1L2Connection')
        self.sshManager.send_command(
            'sudo sh -c "mkdir -p %s; chmod 777 %s; rm %s/tcpdump*.pcap*; ls -ltr %s; echo tcpdump -i %s -G 20'
            ' -C 100 -B 9000 -w %s/tcpdump-%%Y-%%m-%%d_%%Hh%%Mm%%S.pcap -W 50 > tcpdump.sh ;'
            ' chmod 777 tcpdump.sh; nohup ./tcpdump.sh"' % (tcpdumpFolder, tcpdumpFolder,
                                                            tcpdumpFolder, tcpdumpFolder, sourceItf,
                                                            tcpdumpFolder), connection='L1L2Connection', get_pty=True)
        try:
            self.sshManager.read_output_until('Password:', timeout=1, connection='L1L2Connection')
            self.sshManager.write_input("%s\n" % password, connection='L1L2Connection')
        except Exception:
            pass
        self._stopped = False
        self._allFilesTransferred = False
        threading.Thread(target=self._mainloop, args=(tcpdumpFolder, destFolder)).start()

    def stopL1L2Collection(self):
        """
        Stop the collection of pcap files
        :return: N/A
        """

        self.sshManager.send_command('sudo killall tcpdump', connection='L1L2Connection', get_pty=True)
        try:
            self.sshManager.read_output_until('Password:', timeout=1, connection='L1L2Connection')
            self.sshManager.write_input("%s\n" % self.sudo_password, connection='L1L2Connection')
        except Exception:
            pass
        self.sshManager.await_execution_end('L1L2Connection')

        self._stopped = True
        while not self._allFilesTransferred:
            pass
        self.sshManager.disconnect(connection='L1L2Connection')

    def getLastFile(self, tcpdumpFolder, destFolder):
        """
        Download a new file on the controller, if available
        :param tcpdumpFolder: folder where to get the traces on the remote controller
        :param destFolder: folder where to put the traces on the local computer
        :return: File name if a file has been downloaded. None otherwise
        """

        pCapFile = None
        # Get the directory and file listing
        listFile = self.sshManager.execute('ls %s -1' % (tcpdumpFolder), connection='L1L2Connection'). \
            encode('utf-8').replace('\r', '')
        dirListFull = list(filter(None, listFile.split('\n')))
        dirListFull.sort()
        # If the collection has not been stopped, the last pcap file is still being written and should not
        # be downloaded
        if self._stopped:
            dirList = dirListFull[:]
        else:
            dirList = dirListFull[:-1]
        # If there is at least one pcap file available
        if len(dirList) > 0:
            # Download every files available
            for fileName in dirList:
                sourceFile = tcpdumpFolder + "/" + fileName
                if sourceFile not in self._transferredFile:
                    pCapFile = destFolder + "/" + fileName
                    try:
                        os.remove(pCapFile)
                    except OSError:
                        pass
                    # download and delete the pcap file
                    self.sshManager.download_file(sourceFile, pCapFile, connection='L1L2Connection')
                    self.sshManager.send_command('sudo rm %s' % (sourceFile), connection='L1L2Connection',
                                                 get_pty=True)
                    try:
                        self.sshManager.read_output_until('Password:', timeout=1, connection='L1L2Connection')
                        self.sshManager.write_input("%s\n" % self.sudo_password, connection='L1L2Connection')
                    except Exception:
                        pass
                    self.sshManager.await_execution_end('L1L2Connection')
                    self._transferredFile.append(sourceFile)
        return pCapFile


# class tester
if __name__ == '__main__':
    L1L2 = L1L2Collector()
    # CV102:
    # L1L2.startL1L2Collection('ens3f1', '/var/volatile/autoTCPDump',
    # '/home/localuser/temp', '10.14.58.237', 'wrsroot', 'uteadmin')

    # CV039:
    # L1L2.startL1L2Collection('ensauto4f1', '/var/volatile/autoTCPDump',
    #                         '/home/localuser/temp', '10.14.34.211', 'wrsroot', 'uteadmin')

    time.sleep(5)
    L1L2.stopL1L2Collection()
