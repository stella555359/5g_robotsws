from datetime import datetime
from robot.api import logger


def verify_ecdsa_certificates(certs_list,  sw_release_name, subject_name='CN = CB005999_test'):
    ecdsa_certs = [cert for cert in certs_list if cert['keyPoolType'] == 'ECDSA' and cert['issuer'] == subject_name]

    assert len(ecdsa_certs) > 0, 'Lack of ECDSA certificates'

    for cert in ecdsa_certs:
        if cert['type'] == 'TrustAnchor':
            assert cert['issuedTo'] == subject_name, 'Wrong subject value'

        if cert['type'] == 'EndEntity':
            _check_cert_creation_date(cert['validFrom'], sw_release_name)


def _check_cert_creation_date(valid_from_timestamp, sw_release_name):
    if 'SBTS24R1' in sw_release_name or 'SBTS23R4' in sw_release_name or 'SBTS23R3' in sw_release_name:
        valid_from_date = datetime.strptime(valid_from_timestamp, '%b %d %H:%M:%S %Y %Z').date()
        today_date = datetime.now().date()
    else:
        valid_from_date = datetime.strptime(valid_from_timestamp, '%Y-%m-%dT%H:%M:%S+00:00').date()
        today_date = datetime.now().date()

    counter = (datetime.now()-datetime.strptime(valid_from_timestamp, '%Y-%m-%dT%H:%M:%S+00:00')).days

    assert valid_from_date == today_date or counter == 1, 'Wrong validFrom date'


def verify_cmp_key_update(certs_before, certs_after):
    ecdsa_cert_before = [cert for cert in certs_before if
                         cert['issuer'] == 'CN = CB005999_test' and cert['type'] == 'EndEntity']

    ecdsa_cert_after = [cert for cert in certs_after if
                        cert['issuer'] == 'CN = CB005999_test' and cert['type'] == 'EndEntity']

    logger.info(ecdsa_cert_before[0]['validFrom'], also_console=True)
    logger.info(ecdsa_cert_after[0]['validFrom'], also_console=True)

    assert len(ecdsa_cert_before) > 0, 'Lack of ECDSA certificate'
    assert len(ecdsa_cert_after) > 0, 'Lack of ECDSA certificate'
    assert ecdsa_cert_before[0]['validFrom'] != ecdsa_cert_after[0]['validFrom'], 'CMP Key not updated'


def verify_trust_anchor_update(certs_before, certs_after):
    ecdsa_cert_before = [cert for cert in certs_before if cert['keyPoolType'] == 'ECDSA']

    ecdsa_cert_after = [cert for cert in certs_after if cert['keyPoolType'] == 'ECDSA']

    assert len(ecdsa_cert_before) > 0, 'Lack of ECDSA certificate'
    assert len(ecdsa_cert_after) > 0, 'Lack of ECDSA certificate'

    trust_anchor_before = [cert for cert in ecdsa_cert_before if cert['type'] == 'TrustAnchor'][0]
    end_entity_before = [cert for cert in ecdsa_cert_before if cert['type'] == 'EndEntity'][0]

    trust_anchor_after = [cert for cert in ecdsa_cert_after if cert['type'] == 'TrustAnchor'][0]
    end_entity_after = [cert for cert in ecdsa_cert_after if cert['type'] == 'EndEntity'][0]

    assert trust_anchor_before['issuer'] != trust_anchor_after['issuer'], 'Trust Anchor not updated'
    assert end_entity_before['validFrom'] != end_entity_after['validFrom'], 'CMP Key not updated'
