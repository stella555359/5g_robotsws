*** Settings ***
Library  taf.hw.rmod_serial_interface  WITH NAME  rsi_mumin
Library  Collections

Documentation  Exemple of __init__.py configuration:
...  from taf.config.testline.lmi import SerialOverTcp, Remote
...  from taf.config.testline.lmi import SerialOverHost, Local
...
...  MUMIN_AHFIG_BL2115W28QJ = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.3"), port=5001)])
...  MUMIN_AHLOA_K9183920894 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.3"), port=5002)])
...  MUMIN_AHFIG_K9194200561 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.3"), port=5003)])
...  MUMIN_AHFIG_K9194200562 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.3"), port=5004)])
...  MUMIN_AHLOA_K9190837419 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.3"), port=5005)])
...  MUMIN_AHLOA_K9183920949 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.3"), port=5006)])
...
...  _rmod_1 = RU(
...      ru_hw_group="FRMrRH5.1_4T4R",
...      radio_type=RadioTypes.AHFIG.value,
...      serial_number="K9194200562",
...      default_telnet_connection_details=TelnetConnectionDetails(
...          addr="172.16.33.132", port=2323
...      ),
...      pdu_port=_pdu_2.pdu_ports[4],
...      lmi=MUMIN_AHFIG_K9194200562,
...  )
...  _rmod_2 = RU(
...      ru_hw_group="",
...      radio_type=RadioTypes.AHPMDB.value,
...      serial_number="AS220890753",
...      default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.33.128", port=2323),
...      pdu_port=_pdu_1.pdu_ports[3],
...      lmi=SerialOverHost(
...          host=TestPc(
...              default_ssh_connection_details=SshServiceDetails(
...                  addr="10.5.53.161",
...                  username="rfsharing",
...                  password="Nokia2022!@1")),
...          uart_mapping=[Local(port="COM132")]))


*** Keywords ***
Setup Mumin
    [Documentation]  Sets up Mumin log collection: creates config from testline and starts collection for each RMOD with LMI.

    Log  Setup Mumin.  console=true

    ${mumin_config}  Create Mumin Config
    IF  ${mumin_config}
        Start Mumin Log Collection  ${mumin_config}
    ELSE
        ${RMOD_MUMIN_ALIASES}  Create List
        Set Test Variable  ${RMOD_MUMIN_ALIASES}
        Log  No Mumin found in __init__ file. TC will not collect mumin logs.  console=true
    END


Create Mumin Config
    [Documentation]    KW will return a dictionary with similar format:
    ...  {RMOD1_SN': {
    ...    type=RMOD1_TYPE,
    ...    serial_number=RMOD1_SERIAL_NUMBER,
    ...    address=RMOD1_ADDR,
    ...    port=RMOD1_PORT
    ...    fh_connection=""
    ...       },
    ...  'RMOD2_SN': {
    ...    type=RMOD2_TYPE,
    ...    serial_number=RMOD2_SERIAL_NUMBER,
    ...    address=RMOD2_ADDR,
    ...    port=RMOD2_PORT
    ...    fh_connection="CPRI"
    ...       }}

    ${mumin_all_sot}  Create List  # List for SerialOverTcp
    ${mumin_all_soh}  Create List  # List for SerialOverHost
    FOR  ${enb}  IN  @{tl.enbs}
        FOR  ${rm}  IN  @{enb.rms}
            ${status}  Run Keyword And Return Status  Variable Should Exist  ${rm.lmi}
            IF  not ${status}  CONTINUE
            ${mumin_connection_type}  Evaluate  type($rm.lmi)
            IF  "SerialOverTcp" in "${mumin_connection_type}"
                ${mumin_sot}  Create Dictionary
                ...  type=${rm.radio_type}
                ...  serial_number=${rm.serial_number}
                ...  address=${rm.lmi.uart_mapping[0].addr.v4}
                ...  port=${rm.lmi.uart_mapping[0].port}
                ...  fh_connection=${rm.ru_hw_group}  # This is added as a workaround for CPRI/eCPRI RU login password difference.
                Append To List  ${mumin_all_sot}  ${mumin_sot}
            ELSE IF  "SerialOverHost" in "${mumin_connection_type}"
                ${mumin_soh}  Create Dictionary
                ...  host_ip=${rm.lmi.host.default_ssh_connection_details.addr}
                ...  host_user=${rm.lmi.host.default_ssh_connection_details.username}
                ...  host_password=${rm.lmi.host.default_ssh_connection_details.password}
                ...  type=${rm.radio_type}
                ...  serial_number=${rm.serial_number}
                ...  port=${rm.lmi.uart_mapping[0].port}
                ...  fh_connection=${rm.ru_hw_group}
                Append To List  ${mumin_all_soh}  ${mumin_soh}
            END
        END
    END
    ${mumin_all}  Create Dictionary  mumin_sot=${mumin_all_sot}  mumin_soh=${mumin_all_soh}

    RETURN  ${mumin_all}


Start Mumin Log Collection
    [Documentation]  Starts Mumin log collection for all RMODs defined in the mumin config (SerialOverTcp and SerialOverHost).
    [Arguments]  ${mumin_config}

    Log  Start Mumin Log Collection.  console=true
    ${RMOD_MUMIN_ALIASES}  Create List
    Set Test Variable  ${RMOD_MUMIN_ALIASES}

    FOR  ${mumin}  IN  @{mumin_config.mumin_sot}
        IF  'RMOD_${mumin}[serial_number]' in ${RMOD_MUMIN_ALIASES}
            Log  Mumin alias RMOD_${mumin}[serial_number] already used.  console=true
            CONTINUE
        END
        Log  Start Mumin for RMOD_${mumin}[serial_number].  console=true
        ${fh_interface}  Set Variable If  "${mumin.fh_connection}" == "CPRI"  CPRI  eCPRI  # eCPRI is default
        rsi_mumin.Setup Rmod Connection  ${mumin}[type]  ${mumin}[address]:${mumin}[port]  alias=RMOD_${mumin}[serial_number]
        ...  fh_interface=${fh_interface}
        Append To List  ${RMOD_MUMIN_ALIASES}  RMOD_${mumin}[serial_number]
    END

    ${host_aliases}  Create List
    FOR  ${mumin}  IN  @{mumin_config.mumin_soh}
        IF  'host_alias_${mumin}[host_ip]' in ${host_aliases}
            Log  Host alias ${mumin}[host_ip] already used.  console=true
        ELSE
            rsi_mumin.Setup Host  ${mumin}[host_ip]  ${mumin}[host_user]  ${mumin}[host_password]  alias=host_alias_${mumin}[host_ip]
            Append To List  ${host_aliases}  host_alias_${mumin}[host_ip]
        END

        IF  'RMOD_${mumin}[serial_number]' in ${RMOD_MUMIN_ALIASES}
            Log  Mumin alias RMOD_${mumin}[serial_number] already used.  console=true
            CONTINUE
        END
        Log  Start Mumin for RMOD_${mumin}[serial_number].  console=true
        ${fh_interface}  Set Variable If  "${mumin.fh_connection}" == "CPRI"  CPRI  eCPRI  # eCPRI is default
        rsi_mumin.Setup Rmod Connection  ${mumin}[type]  ${mumin}[port]  alias=RMOD_${mumin}[serial_number]
        ...  fh_interface=${fh_interface}  host_connection=host_alias_${mumin}[host_ip]
        Append To List  ${RMOD_MUMIN_ALIASES}  RMOD_${mumin}[serial_number]
    END


Collect Mumin Logs
    [Documentation]  Downloads Mumin logs from all configured RMOD aliases to BTS_FILES/mumin or RESULTS/mumin.

    IF  not ${RMOD_MUMIN_ALIASES}  RETURN
    Log  Collecting Mumin logs.  console=true

    ${status}  Run Keyword And Return Status  Variable Should Exist  ${BTS_FILES}
    ${status_results}  Run Keyword And Return Status  Variable Should Exist  ${RESULTS}  #PS log storage location
    ${mumin_log_path}  Set Variable If
    ...  ${status}  ${BTS_FILES}/mumin
    ...  ${status_results}  ${RESULTS}/mumin
    ...  ${OUTPUT DIR}/mumin/${TEST NAME}
    FOR  ${rm}  IN  @{RMOD_MUMIN_ALIASES}
        rsi_mumin.Download Log  ${mumin_log_path}/MUMIN_${rm}.txt  alias=${rm}
    END
    Log  MUMIN logs collected at: ${mumin_log_path}  console=true


Teardown Mumin
    [Documentation]  Tears down all Mumin RMOD connections and all host connections.

    IF  not ${RMOD_MUMIN_ALIASES}  RETURN
    Log  Teardown Mumin aliases.  console=true

    FOR  ${mumin_alias}  IN  @{RMOD_MUMIN_ALIASES}
        rsi_mumin.Teardown  alias=${mumin_alias}
    END
    rsi_mumin.Teardown All Hosts
