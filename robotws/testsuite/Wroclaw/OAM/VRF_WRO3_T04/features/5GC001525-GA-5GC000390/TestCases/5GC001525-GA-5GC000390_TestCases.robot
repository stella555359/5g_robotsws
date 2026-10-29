*** Settings ***
Documentation   Keywords for feature validate installation of nokia vendor certificate on cOAM BTS
...
...             author: Egor Kotko
...             contact: egor.kotko@nokia.com
...
...             maintainer: Jedrzej Kowalski
...             contact: jedrzej.kowalski@nokia.com

Library         taf.sbts.oam.coam.admin  WITH NAME   coam_admin
Library         ../Resources/certificates_keywords.py

*** Variables ***
${CERT_FILE_PATH}=    ${CURDIR}/../Resources/8154.pem
${CERT_TYPE}=         AdditionalCa
${CERT_FORMAT}=       PEM
${CERT_FINGERPRINT}=  12:A6:17:17:8A:F9:E3:57:1C:DB:69:22:16:33:5D:6A:01:57:51:51
${TEMP_CERT_CONN}=    temporary_cert_connection

*** Keywords ***
5GC001525_GA_Validate_installation_of_Nokia_Vendor_Certificate_on_cOAM_BTS
    certificates_keywords.check_certificate     ip=${SSH_IP}
    ...                                         username=${SSH_USERNAME}
    ...                                         password=${SSH_PASSWORD}

5GC001525_GA_2_Display_BTS_Vendor_Certificate_and_trust_chain_on_cOAM_BTS
    ${admin_conn}=  coam_admin.connect_to
    ...             bts_host=${SSH_IP}
    ...             username=${WEBEM_USERNAME}
    ...             password=${WEBEM_PASSWORD}
    ...             name=admin
    ${certs_list}=  coam_admin.get_certificate_list  Vendor  connection=${admin_conn}
    ${certs_status}=    certificates_keywords.verify_vendor_certificates  ${certs_list}
    Should Be True  ${certs_status}
    [Teardown]  coam_admin.Teardown  ${admin_conn}

5GC001525_GA_3_Restore_Vendor_Certificate_and_remove_Operator_Certificate_on_cOAM_BTS
    ${admin_conn}=  coam_admin.connect_to    bts_host=${SSH_IP}
    ...                                 username=${WEBEM_USERNAME}
    ...                                 password=${WEBEM_PASSWORD}
    ...                                 name=admin
    coam_admin.install_certificate   cert_file=${CERT_FILE_PATH}
    ...                         cert_type=${CERT_TYPE}
    ...                         cert_format=${CERT_FORMAT}
    ...                         connection=${admin_conn}
    coam_admin.delete_certificate    fingerprint=${CERT_FINGERPRINT}
    ...                         connection=${admin_conn}
    [Teardown]  coam_admin.Teardown  ${admin_conn}
