"""
:copyright: Nokia Networks
:author: Lixia Tang
:contact: lixia.tang@nokia-sbell.com
"""

from taf.transport.ssh import interface


certificate_list = ['NokiaFactoryCA2067.pem',
                    'NSNFactoryCA.pem',
                    'NokiaRootCA.pem',
                    'NokiaRootCA2067.pem']


def check_certificate(ip, username, password):
    ssh = interface.ssh()
    connection = ssh.connect_to(ip, username, password)
    for cert in certificate_list:
        ffs_run_content = connection.execute(
            command="test -e /etc/ssl/certs/{0} "
                    "&& echo file exists || echo file not found".format(cert))
        if ffs_run_content.strip() != 'file exists':
            raise Exception('No Certificate {0} was found at {1}'.format(
                cert, '/etc/ssl/certs/'))
