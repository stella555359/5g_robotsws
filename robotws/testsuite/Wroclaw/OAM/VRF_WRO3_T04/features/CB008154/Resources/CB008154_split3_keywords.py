import datetime
from robot.api import logger


def get_cert_validity(cert_list, sw_release_name, fingerprint=None):
    months_list = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    if not cert_list:
        logger.error("Following cert list is empty: "+str(cert_list))
    if fingerprint:
        cert_position = -1
        for i in enumerate(cert_list):
            try:
                if i[1]['fingerPrint'] == fingerprint:
                    cert_position = int(i[0])
            except ValueError:
                logger.error("There is no fingeprint field in record: " + str(i[1]))
        if cert_position == -1:
            logger.error("There is no cert with following fingeprint: " + str(fingerprint))
    else:
        cert_position = 0
    try:
        cert_valid_date = cert_list[cert_position]['validTo']
    except ValueError:
        logger.error("There is no field validTo for: " + str(cert_list) + " at position " + str(cert_position))
    try:
        if 'SBTS24R1' in sw_release_name or 'SBTS23R4' in sw_release_name or 'SBTS23R3' in sw_release_name:
            cert_valid_date = cert_valid_date.split(' ')
            cert_valid_date = ' '.join(cert_valid_date).split()
            cert_valid_month = months_list.index(cert_valid_date[0])+1
            cert_valid_time = cert_valid_date[2].split(':')
            cert_valid_year = int(cert_valid_date[3])
            cert_valid_day = int(cert_valid_date[1])
            cert_valid_hour = int(cert_valid_time[0])
            cert_valid_min = int(cert_valid_time[1])
            cert_valid_sec = int(cert_valid_time[2])
        else:
            cert_valid_date = cert_valid_date.split('T')
            cert_date = cert_valid_date[0].split('-')
            cert_valid_month = int(cert_date[1])
            cert_valid_time = cert_valid_date[1].split('+')
            cert_valid_time = cert_valid_time[0].split(':')
            cert_valid_year = int(cert_date[0])
            cert_valid_day = int(cert_date[2])
            cert_valid_hour = int(cert_valid_time[0])
            cert_valid_min = int(cert_valid_time[1])
            cert_valid_sec = int(cert_valid_time[2])
    except ValueError:
        logger.error("There is an issue with conversion following date " + str(cert_valid_date))
    cert_valid_datetime = datetime.datetime(cert_valid_year,
                                            cert_valid_month,
                                            cert_valid_day,
                                            cert_valid_hour,
                                            cert_valid_min,
                                            cert_valid_sec,
                                            tzinfo=datetime.timezone.utc)
    current_time = datetime.datetime.now(datetime.timezone.utc)
    cert_diff = (cert_valid_datetime - current_time).days
    return cert_diff


def check_certs_validity(add_cert_validity, bts_cert_validity):
    if int(add_cert_validity) >= int(bts_cert_validity):
        return False
    return True


def check_add_cert_validity(add_cert_validity):
    valid_threshold = str(30)
    if int(add_cert_validity) < int(valid_threshold):
        if int(add_cert_validity) < 2:
            logger.error("Validity of End Entity cert from P12 file is less than 1 day. Please use a new one " +
                         "with validity at least" + valid_threshold + " days.")
        else:
            logger.warn("Validity of End Entity cert from P12 file (" + str(add_cert_validity) + " days) " +
                        "is below threshold (" + valid_threshold + " days). Please use (commit in repo) " +
                        "a newer cert.")


def check_faults_in_output(output, fauld_id):
    for i in output:
        if i["additionalText3"].find(fauld_id) != -1:
            return True
    return False
