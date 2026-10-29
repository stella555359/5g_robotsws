*** Variables ***
${cert_path}                   ${CURDIR}/certificates
${emssim_ssl_path}             /opt/emssim/proxy/ssl/
${emssim_apache_key}           /etc/apache2/ssl.key/
${emssim_apache_crt}           /etc/apache2/ssl.crt/

${EMSSIM_CONNECTION_TIMEOUT}=      300
${EMSSIM_BTS_CONNECTION_TIMEOUT}=  300
${EMSSIM_WAIT_CONNECTED}=          ${True}
${EMSSIM_WAIT_DISCOVERED}=         ${True}
${EMSSIM_ENB_ID}=                  1
${EMSSIM_HOST}=                    10.0.1.1
${EMSSIM_PORT}=                    4001
${EMSSIM_COMMAND_PARAMS}=          ${None}
${EMSSIM_COMMAND_TIMEOUT}=         ${None}
${EMSSIM_COMMAND_FULL_DATA}=       False
${EMSSIM_COMMAND_CAN_FAIL}=        False
${EMSSIM_LOG_DIR}=                 /home/flexi1/emssim_log.log
${EMSSIM_LOG_LEVEL}=               5
${EMSSIM_OUTPUT_LOG_DIR}=          ${EMPTY}
