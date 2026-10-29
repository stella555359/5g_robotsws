from taf.sbts.oam.coam.admin import admin
from robot.api import logger
import re


def get_operator_certificates(cert_list):
    try:
        return [cert for cert in cert_list if cert['source'] == 'Operator']
    except KeyError:
        logger.warn('Unknown certificate source.')


def get_certificates_fingerprints(cert_list):
    try:
        return [cert['fingerPrint'] for cert in cert_list]
    except KeyError:
        logger.warn('Unknown certificate fingerprint.')


def delete_multiple_certificates(fingerprints, connection):
    for fingerprint in fingerprints:
        connection.delete_certificate(fingerprint=fingerprint)


def get_secondary_cmp_delete_delta(server_type, bts_id):
    return [
        {
            'distName': 'MRBTS-{}/MNL-1/CERTH-1/{}'.format(bts_id, server_type),
            'operation': 'update',
            'parameters': [
                {
                    'parameterName': 'secondaryCaSubjectName',
                    'operation': 'delete',
                    'value': ''
                },
                {
                    'parameterName': 'secondaryServerHost',
                    'operation': 'delete',
                    'value': ''
                },
                {
                    'parameterName': 'secondaryServerPath',
                    'operation': 'delete',
                    'value': ''
                },
                {
                    'parameterName': 'secondaryServerPort',
                    'operation': 'delete',
                    'value': ''
                }
            ]
        }
    ]


def get_signature_algorithm(openssl_output):
    return re.findall(r'Signature Algorithm: (.*)', openssl_output)


def get_subject(openssl_output):
    return re.findall(r'subject=(.*)', openssl_output)


def get_serial_number(openssl_output):
    return re.findall(r'serial=(.*)', openssl_output)


def get_issuer(openssl_output):
    return re.findall(r'issuer=(.*)', openssl_output)
