import pexpect
import logging

logging.basicConfig(format='%(asctime)s - %(levelname)s: %(message)s',
                    filename='example.log',
                    level=logging.INFO)


class VmOperation:
    """
    Class provide VM connection operations.
    Usage example:
        ssh = VmOperation()
        connection = ssh.connect_to_vm('vm_ip_address'. 'vm_username', 'vm_password')
        ssh.disconnect_from_vm(connection)
    """
    def __init__(self):
        self.child = None

    def connect_to_vm(self, vm_ip_address, vm_username, vm_password):
        """
        Function to connect with VM.
        """
        try:
            self.child = pexpect.spawn('ssh {}@{}'.format(vm_username, vm_ip_address))
            # nie wiadomo czemu ale nie wymaga hasla
            # self.child.expect("[pP]assword:")
            # self.child.sendline(vm_password)
            self.child.expect('\\$')
            logging.info('Connection to VM created (ip: {})'.format(vm_ip_address))
            return self.child
        except Exception as e:
            logging.error('Connection to VM not created')

    def disconnect_from_vm(self):
        """
        Function to disconnect from VM
        """
        self.child.sendline('exit')
        self.child.expect('')
        logging.info('Connection to VM closed')
