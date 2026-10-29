import os
import time
from taf.selenium.gnb.oam.coam.classical import classical
from taf.selenium.sbts import sbts
from taf.transport.ssh import interface

certificate_names = ['CA', 'Vendor', 'TA']
crt_serial_number = '0x9580F5FA96F73DD0'
certificate_full_names = ["TrustAnchor", "CertificateAuthority", "EndEntity"]

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


def verify_vendor_certificates(vendor_certs):
    bts_certs = []
    for cert in vendor_certs:
        for data in cert:
            if data == "type":
                bts_certs.append(cert[data])
    return set(bts_certs) == set(certificate_full_names)


def select_interface_depend_on_sw_version(sw_ver):
    if sw_ver == "5G21A":
        interface = classical()
    else:
        interface = sbts()
    return interface


def get_vendor_certificates(ip, password, user, sw_ver):
    interface = select_interface_depend_on_sw_version(sw_ver)
    interface.enable_virtual_display()
    interface.login(ip, password, user)
    vendor_certificates = interface.get_certificates_vendor()
    interface.logout()
    interface.disable_virtual_display()
    if vendor_certificates.keys() == certificate_names:
        return vendor_certificates


def web_login(ip, password, user, sw_ver):
    interface = select_interface_depend_on_sw_version(sw_ver)
    interface.enable_virtual_display()
    interface.login(ip, password, user)
    return interface


def if_certificate_available(interface, crt_number, cert_type, crt_serial_number):
    cert_availability = interface.get_certificates(
        index=crt_number - 1, cert_types=cert_type)
    if crt_serial_number in cert_availability[cert_type]['Serial number']:
        return True
    else:
        return False


def add_operator_bts_certificate(ip, password, user, file_path, sw_ver):
    base_path = os.path.dirname(os.path.abspath(__file__))
    file_path = '/'.join([base_path, file_path])
    interface = web_login(ip, password, user, sw_ver)
    window_exist = interface.start_up_view_window_exists()
    if window_exist is True:
        interface.close_start_up_view_window()
    else:
        pass
    crt_number = interface.get_certificates_number(certificate_names[2])
    serial_numbers = []
    if crt_number:
        for cert_number in iter(range(crt_number)):
            serial_number = interface.get_certificates(
                index=cert_number, cert_types=certificate_names[2])
            serial_numbers.append(serial_number[
                                      certificate_names[2]]['Serial number'])
    if crt_serial_number not in serial_numbers:
        interface.install_bts_certificates_from_local(additional_ca_file_path=file_path)
    else:
        raise Exception(
            'The certificate with serial number {0} already exists'.format(
                crt_serial_number))
    time.sleep(50)
    crt_number = interface.get_certificates_number(certificate_names[2])
    if not if_certificate_available(
            interface, crt_number, certificate_names[2], crt_serial_number):
        raise Exception(
            'The TA Certificate with id {0} is not present on BTS'.format(
                crt_serial_number))
    interface.logout()
    interface.disable_virtual_display()


def delete_operator_bts_certificate(ip, password, user, sw_ver):
    interface = web_login(ip, password, user, sw_ver)
    window_exist = interface.start_up_view_window_exists()
    if window_exist is True:
        interface.close_start_up_view_window()
    else:
        pass
    crt_number = interface.get_certificates_number(certificate_names[2])
    serial_numbers = []
    if crt_number:
        for cert_number in iter(range(crt_number)):
            serial_number = interface.get_certificates(
                index=cert_number, cert_types=certificate_names[2])
            serial_numbers.append(serial_number[
                                      certificate_names[2]]['Serial number'])
    if crt_serial_number not in serial_numbers:
        raise Exception(
            'The TA Certificate with id {0} is not present on BTS'.format(
                crt_serial_number))
    interface.delete_certificate([crt_serial_number])
    time.sleep(50)
    crt_number = interface.get_certificates_number(certificate_names[2])
    cert_availability = interface.get_certificates(
        index=crt_number-1, cert_types=certificate_names[2])
    if cert_availability:
        if cert_availability['TA']['Serial number'] == crt_serial_number:
            raise Exception(
                'The TA Certificate with id {0} is present on BTS'.format(
                    crt_serial_number))
    interface.logout()
    interface.disable_virtual_display()
