*** Settings ***
Documentation     resource file


*** Variables ***

${SW_BUILDS_DIR_PATH}    /home/ute/Downloads/

@{ALLOWED_FAULT} =    R&D Service Port enabled
...                SSH enabled
...                LMP access via port .*
...                Service account root access is enabled
...                Ethernet port security is disabled
...                BTS Reset Cause
...                Sanity Check Error
...                Vendor BTS certificate
...                Synchronization lost
...                BTS booted at .*? due to trs management reset
...                .*? ToP master service .*? unusable
...                NTP Server .*?
...                BTS time not corrected
...                R&D Service Port enabled
...                BTS Reset Cause
...                Beamforming Calibration Detect Continuous Exception
...                Service account root access is enabled
...                Ethernet port security is disabled
...                Sanity Check Error
...                Diagnostic Check Error
...                Increased BER detected on the optical connection to Radio Module


${SW_CONFIG_PATH}    ${CURDIR}/tools/swconfig.txt

@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}

&{LOG_SERVER_INFO}    HOST=10.69.69.233
...                  USERNAME=ute
...                  PASSWORD=Ut3pa5s#ff97

${UTE_EXECUTION_JSON}           /opt/ute/execution.context.json

${BTS_HOST}    192.168.255.129
