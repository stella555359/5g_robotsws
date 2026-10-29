"""
:copyright: Nokia Networks
:author: Lixia Tang
:contact: lixia.tang@nokia-sbell.com
"""

import os
import time


certificate_names = ['CA', 'Vendor', 'TA']
additional_ca_serial_number = 'E4B275541A1FC570'


def get_vendor_certificates(ip, password, user):
    interface = selenium_coam()
    interface.enable_virtual_display()
    interface.login(ip, password, user)
    vendor_certificates = interface.get_certificates_vendor()
    interface.logout()
    interface.disable_virtual_display()
    if vendor_certificates.keys() == certificate_names:
        return vendor_certificates


def web_login(ip, password, user):
    interface = selenium_coam()
    interface.enable_virtual_display()
    interface.login(ip, password, user)
    return interface


def if_certificate_available(
        interface, crt_number, cert_type, additional_ca_serial_number):
    cert_availability = interface.get_certificates(
        index=crt_number - 1, cert_types=cert_type)
    if cert_availability[cert_type]['Serial number'] == additional_ca_serial_number:
        return True
    else:
        return False


def add_additional_ca_certificates(ip, password, user, file_path):
    base_path = os.path.dirname(os.path.abspath(__file__))
    file_path = '/'.join([base_path, file_path])
    interface = web_login(ip, password, user)
    crt_number = interface.get_certificates_number(certificate_names[0])
    serial_numbers = []
    if crt_number:
        for cert_number in xrange(crt_number):
            serial_number = interface.get_certificates(
                index=cert_number, cert_types=certificate_names[0])
            serial_numbers.append(serial_number[
                certificate_names[0]]['Serial number'])
    if additional_ca_serial_number not in serial_numbers:
        interface.add_certificate(file_path)
    else:
        interface.logout()
        interface.disable_virtual_display()
        raise Exception(
            'The Additional CA Certificate with serial number {0} already exists'.format(
                additional_ca_serial_number))
    time.sleep(30)
    crt_number = interface.get_certificates_number(certificate_names[0])

    if not if_certificate_available(
            interface, crt_number, certificate_names[0], additional_ca_serial_number):
        interface.logout()
        interface.disable_virtual_display()
        raise Exception(
            'The Additional CA Certificate with id {0} add failed'.format(
                additional_ca_serial_number))
    interface.logout()
    interface.disable_virtual_display()


def add_bts_trust_chain(ip, password, user, file_path, cert_password):
    base_path = os.path.dirname(os.path.abspath(__file__))
    file_path = '/'.join([base_path, file_path])
    interface = web_login(ip, password, user)
    interface.install_bts_certificates_from_local(file_path, cert_password)
    time.sleep(30)
    crt_number = interface.get_certificates_number(certificate_names[2])
    interface.logout()
    interface.disable_virtual_display()
    if not crt_number:
        raise Exception(
            'The BTS trust chain add failed')


def check_bts_trust_chain_removed(ip, password, user):
    interface = web_login(ip, password, user)
    crt_number = interface.get_certificates_number(certificate_names[2])
    interface.logout()
    interface.disable_virtual_display()
    if crt_number:
        return False
    else:
        return True


def check_additional_ca_certificates_not_removed(ip, password, user):
    interface = web_login(ip, password, user)
    crt_number = interface.get_certificates_number(certificate_names[0])
    interface.logout()
    interface.disable_virtual_display()
    if not crt_number:
        return False
    else:
        return True


def delete_additional_ca_certificate(ip, password, user):
    interface = web_login(ip, password, user)
    crt_number = interface.get_certificates_number(certificate_names[0])
    serial_numbers = []
    if crt_number:
        for cert_number in xrange(crt_number):
            serial_number = interface.get_certificates(
                index=cert_number, cert_types=certificate_names[0])
            serial_numbers.append(serial_number[
                certificate_names[0]]['Serial number'])
    if additional_ca_serial_number not in serial_numbers:
        interface.logout()
        interface.disable_virtual_display()
        raise Exception(
            'The Additional CA Certificate with id {0} is not present on BTS'.format(
                additional_ca_serial_number))
    interface.delete_certificate(serial_numbers)
    time.sleep(30)
    crt_number = interface.get_certificates_number(certificate_names[0])
    cert_availability = interface.get_certificates(
        index=crt_number - 1, cert_types=certificate_names[0])
    interface.logout()
    interface.disable_virtual_display()

    if cert_availability:
        if cert_availability['CA']['Serial number'] == additional_ca_serial_number:
            raise Exception(
                'The Additional CA Certificate delete failed')
