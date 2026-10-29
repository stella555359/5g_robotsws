import os
import re
import ssl


def prepare_list_from_console(console_output, split_param="\r\n"):
    list_from_console_output = console_output.split(split_param)
    try:
        list_from_console_output.remove("/etc/swanctl/rsa/enbKey.pem")
    except Exception as e:
        print("/etc/ipsec.d/private/enbKey.pem is not on list")
    return list_from_console_output


def decode_cert(cert_path):
    """
    return sth like that
        {
        'subjectAltName': (
            (
                'DNS',
                'L1192010995.nokiasolutionsandnetworks.com'
            ),
            ),
        'notBefore': u'May 17 08:21:49 2019 GMT',
        'serialNumber': u'8D00006B6B',
        'notAfter': 'May 14 08:51:49 2031 GMT',
        'version': 3L,
        'subject': (
                        (
                            ('organizationName', u'Nokia Solutions and Networks'),
                        ),
                        (
                            ('commonName', u'L1192010995.nokiasolutionsandnetworks.com'),
                        )
                    ),

        'issuer': (
                    (
                        ('organizationName', u'Nokia Siemens Networks'),
                    ),
                    (
                        ('commonName', u'Factory Certification Authority'),
                    )
        )
    }
    """
    cert_file_base_name = cert_path
    cert_file_name = os.path.join(os.path.dirname(__file__), cert_file_base_name)
    try:
        cert_dict = ssl._ssl._test_decode_cert(cert_file_name)
    except Exception as e:
        print("Error decoding certificate: {0:}".format(e))
    else:
        return cert_dict


def compare_certs(cert_1, cert_2):
    if cert_1['issuer'][1][0][1] != cert_2['issuer'][1][0][1]:
        assert False, "Issuer fields are different"
    if cert_1['issuer'][0][0][1] != cert_2['issuer'][0][0][1]:
        assert False, "Issuer fields are different X"
    if cert_1['subject'][0][0][1] != cert_2['subject'][0][0][1]:
        assert False, "Subject fields are different"
    if cert_1['subject'][1][0][1] != cert_2['subject'][1][0][1]:
        assert False, "Subject fields are different"
    if cert_1['serialNumber'] != cert_2['serialNumber']:
        assert False, "Serial number fields are different"


def prepare_x509_fields(cert):
    stream = os.popen('openssl x509 -text -in {}'.format(cert))
    output = stream.read()
    cuted_output = output.split('X509v3 extensions:\n')[1].split('Signature Algorithm')[0]
    list_params = re.sub(r'\s{2,}', '\n', cuted_output)
    list_params = re.sub(':\n', '\n', list_params).split('\n')
    X509_dict = {}
    for i in range(int(len(list_params) / 2 - 1)):
        X509_dict[list_params[2 * i + 1]] = list_params[2 * i + 2]
    return X509_dict


def compare_x509_fields(cert1, cert2):
    cert1_x509 = prepare_x509_fields(cert1)
    cert2_x509 = prepare_x509_fields(cert2)
    if cert1_x509['X509v3 Authority Key Identifier'] != cert2_x509['X509v3 Authority Key Identifier']:
        assert False, "X509v3 Authority Key Identifier fields are different"
    if cert1_x509['X509v3 Subject Key Identifier'] != cert2_x509['X509v3 Subject Key Identifier']:
        assert False, "X509v3 Subject Key Identifier fields are different"


def check_file_exist(output):
    return False if 'No such file or directory' in output else True
