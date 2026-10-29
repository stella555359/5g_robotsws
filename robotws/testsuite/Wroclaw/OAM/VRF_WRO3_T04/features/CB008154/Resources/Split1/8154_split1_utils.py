import re


def find_CN_in_certificate(certificate, cn):
    """ Check if certificate list contains good CN
     :param: list certificate: Certificate list
     :param: string cn: searched CN
     return: boolen
     """
    cn_list = [str(x['issuer']) for x in certificate]
    for cert in cn_list:
        if bool(re.search(r"{}\b".format(cn), cert)):
            return True


def get_fingerprint_from_certificate(certificates):
    """ Get certificate's fingerprint.
     :param: list certificate: Certificate list
     return: str fingerprint
     """
    for certificate in certificates:
        issuer = str(certificate['issuer'])
        return str(certificate['fingerPrint']) if '8154' in issuer else None
