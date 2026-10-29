import logging
import re


def get_mnc_length_from_scf(scf_content):
    logging.debug("============================== Begin get_mnc_length_from_scf()")
    f = re.search(r'<p name="mncLength">(\d)</p>', scf_content)
    mnc_length = f.group(1)
    logging.debug("============================== Begin get_mnc_length_from_scf()")
    return mnc_length


if __name__ == "__main__":
    scf_content = '<p name="mnc">489</p>\n          <p name="mncLength">3</p>\n        </item>\n'
    mnc_length = get_mnc_length_from_scf(scf_content)
    print("mnc_length = %s" % mnc_length)
