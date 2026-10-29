# import ConfigParser
import configparser
import os
import sys
from threading import *


# ----------------
class ConfigClass:
    # ----------------
    traceDirectory = "/home/ute/traces/Cockpit"
    campaignTraceDirectory = traceDirectory + "/Campaign"

    # TL CONFIGURATION
    tlConfig = {}
    # gNodeB config
    tlConfig["CV29"] = {}
    tlConfig["CV29"]["type"] = "gNodeB_Classical"
    tlConfig["CV29"][
        "logbook"
    ] = "ispeedtools-logbook_cv29_auto@acos.alcatel-lucent.com"
    tlConfig["CV29"]["sshProxy"] = None
    tlConfig["CV29"]["testPC"] = {
        "hostname": "10.14.48.29",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV29"]["l1l2monitor"] = {
        "hostname": "10.14.54.174",
        "username": "wrsroot",
        "password": "uteadmin",
        "tcpDumpPath": "/run/log/L1L2/",
        "itf": "ens4f1",
    }
    tlConfig["CV29"]["rap01"] = {
        "hostname": "192.168.2.60",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV29"]["asik"] = {
        "hostname": "192.168.2.60",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV29"]["abil"] = {
        "hostname": "fsp-1-1c",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV29"]["ru"] = {
        "hostname": "172.16.1.5",
        "username": "root",
        "password": "umniedziala",
    }
    tlConfig["CV29"]["PrismaTestPC"] = {
        "hostname": "10.14.54.189",
        "username": "cv5g2_2",
        "password": "L@urent5G",
    }
    tlConfig["CV29"]["fct-0a"] = {
        "hostname": "192.168.255.1",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
        "tcpDumpPath": "/tmp/",
    }
    tlConfig["CV29"]["fct-0b"] = {
        "hostname": "192.168.253.17",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV29"]["fct-4b"] = {
        "hostname": "192.168.253.33",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV29"]["asp-1a"] = {
        "hostname": "192.168.23.20",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV29"]["asp-1b"] = {
        "hostname": "192.168.23.21",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV29"]["aspa-1c"] = {
        "hostname": "192.168.23.22",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }

    tlConfig["CV63"] = {}
    tlConfig["CV63"]["type"] = "gNodeB_Classical"
    tlConfig["CV63"]["logbook"] = "ispeedtools-logbook_cv63@acos.alcatel-lucent.com"
    tlConfig["CV63"]["sshProxy"] = None
    tlConfig["CV63"]["testPC"] = {
        "hostname": "10.14.48.63",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV63"]["ru"] = {
        "hostname": "172.16.1.5",
        "username": "root",
        "password": "umniedziala",
    }
    tlConfig["CV63"]["fct-0a"] = {
        "hostname": "192.168.255.1",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
        "tcpDumpPath": "/tmp/",
        "itf": "etha01",
    }
    tlConfig["CV63"]["fct-0b"] = {
        "hostname": "192.168.253.17",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
        "tcpDumpPath": "/tmp/",
        "itf": "etha01",
    }
    tlConfig["CV63"]["fct-4b"] = {
        "hostname": "192.168.253.33",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
        "tcpDumpPath": "/tmp/",
        "itf": "etha01",
    }
    tlConfig["CV63"]["asp-1a"] = {
        "hostname": "192.168.23.20",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV63"]["asp-1b"] = {
        "hostname": "192.168.23.21",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV63"]["aspa-1c"] = {
        "hostname": "192.168.23.22",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }

    tlConfig["CV36"] = {}
    tlConfig["CV36"]["type"] = "gNodeB_Classical"
    tlConfig["CV36"][
        "logbook"
    ] = "ispeedtools-logbook_cv36_auto@acos.alcatel-lucent.com"
    tlConfig["CV36"]["sshProxy"] = None
    tlConfig["CV36"]["testPC"] = {
        "hostname": "10.14.48.36",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV36"]["l1l2monitor"] = {
        "hostname": "10.14.56.170",
        "username": "wrsroot",
        "password": "uteadmin",
        "tcpDumpPath": "/run/log/L1L2/",
        "itf": "ens1f1",
    }

    tlConfig["CV36"]["ru"] = {
        "hostname": "192.168.102.2 ",
        "username": "root",
        "password": "umniedziala",
    }
    tlConfig["CV36"]["ru-pc"] = {
        "hostname": "10.14.57.186",
        "username": "cv5g2_2",
        "password": "L@urent5G",
    }
    tlConfig["CV36"]["rap01"] = {
        "hostname": "192.168.2.60",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV36"]["asik"] = {
        "hostname": "192.168.2.60",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
        "tcpDumpPath": "/tmp/",
        "itf": "etha01",
    }
    tlConfig["CV36"]["abil"] = {
        "hostname": "fsp-1-1c",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV36"]["ru"] = {
        "hostname": "172.16.1.5",
        "username": "root",
        "password": "umniedziala",
    }
    tlConfig["CV36"]["PrismaTestPC"] = {
        "hostname": "10.14.55.219",
        "username": "cv5g2_2",
        "password": "L@urent5G",
        "tcpDumpPath": "C:\\traces\\PE_Wireshark\\",
    }
    tlConfig["CV36"]["fct-0a"] = {
        "hostname": "192.168.255.1",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
        "tcpDumpPath": "/tmp/",
        "itf": "etha01",
    }
    tlConfig["CV36"]["fct-0b"] = {
        "hostname": "192.168.253.17",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
        "tcpDumpPath": "/tmp/",
        "itf": "etha01",
    }
    tlConfig["CV36"]["fct-4b"] = {
        "hostname": "192.168.253.33",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
        "tcpDumpPath": "/tmp/",
        "itf": "etha01",
    }
    tlConfig["CV36"]["asp-1a"] = {
        "hostname": "192.168.23.20",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV36"]["asp-1b"] = {
        "hostname": "192.168.23.21",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV36"]["aspa-1c"] = {
        "hostname": "192.168.23.22",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }

    tlConfig["CV39"] = {}
    tlConfig["CV39"]["type"] = "gNodeB_Classical"
    tlConfig["CV39"][
        "logbook"
    ] = "ispeedtools-logbook_cv39_auto@acos.alcatel-lucent.com"
    tlConfig["CV39"]["sshProxy"] = None
    # tlConfig["CV39"]["sshProxy"] = {"hostname":"10.14.34.211", "username":"wrsroot", "password":"uteadmin"}
    tlConfig["CV39"]["l1l2monitor"] = {
        "hostname": "10.14.34.211",
        "username": "wrsroot",
        "password": "uteadmin",
        "tcpDumpPath": "/run/log/L1L2/",
        "itf": "ens4f1",
    }
    tlConfig["CV39"]["rap01"] = {
        "hostname": "192.168.2.60",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV39"]["asik"] = {
        "hostname": "192.168.2.60",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV39"]["abil"] = {
        "hostname": "fsp-1-1c",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV39"]["ru"] = {
        "hostname": "192.168.102.2 ",
        "username": "root",
        "password": "umniedziala",
    }
    tlConfig["CV39"]["ru"] = {
        "hostname": "172.16.1.5",
        "username": "root",
        "password": "umniedziala",
    }
    tlConfig["CV39"]["PrismaTestPC"] = {
        "hostname": "10.14.54.189",
        "username": "cv5g2_2",
        "password": "L@urent5G",
    }
    tlConfig["CV39"]["fct-0a"] = {
        "hostname": "192.168.255.1",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
        "tcpDumpPath": "/tmp/",
    }
    tlConfig["CV39"]["fct-0b"] = {
        "hostname": "192.168.253.17",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV39"]["fct-4b"] = {
        "hostname": "192.168.253.33",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV39"]["asp-1a"] = {
        "hostname": "192.168.23.20",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV39"]["asp-1b"] = {
        "hostname": "192.168.23.21",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV39"]["aspa-1c"] = {
        "hostname": "192.168.23.22",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }

    tlConfig["CV49"] = {}
    tlConfig["CV49"]["type"] = "gNodeB_Classical"
    tlConfig["CV49"][
        "logbook"
    ] = "ispeedtools-logbook_cv49_auto@acos.alcatel-lucent.com"
    tlConfig["CV49"]["sshProxy"] = None
    tlConfig["CV49"]["testPC"] = {
        "hostname": "192.168.255.1",
        "username": "robot",
        "password": "rastre1",
    }
    tlConfig["CV49"]["l1l2monitor"] = {
        "hostname": "1.1.1.1",
        "username": "wrsroot",
        "password": "uteadmin",
        "tcpDumpPath": "/run/log/L1L2/",
        "itf": "ens4f1",
    }
    tlConfig["CV49"]["rap01"] = {
        "hostname": "192.168.255.1",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV49"]["asik"] = {
        "hostname": "192.168.255.1",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
        "tcpDumpPath": "/tmp/",
        "itf": "fp0.3001",
    }
    tlConfig["CV49"]["fct-1-0b"] = {
        "hostname": "192.168.253.17",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV49"]["abil"] = {
        "hostname": "aspa-1c",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV49"]["ru"] = {
        "hostname": "192.168.100.5",
        "username": "root",
        "password": "umniedziala",
    }
    tlConfig["CV49"]["fct-0a"] = {
        "hostname": "192.168.255.1",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV49"]["fct-0b"] = {
        "hostname": "192.168.253.17",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV49"]["fct-4b"] = {
        "hostname": "192.168.253.33",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV49"]["asp-1a"] = {
        "hostname": "192.168.23.20",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV49"]["asp-1b"] = {
        "hostname": "192.168.23.21",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV49"]["aspa-1c"] = {
        "hostname": "192.168.23.22",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }

    tlConfig["CV101"] = {}
    tlConfig["CV101"]["type"] = "gNodeB"
    tlConfig["CV101"][
        "logbook"
    ] = "ispeedtools-logbook_cv101_auto@acos.alcatel-lucent.com"
    tlConfig["CV101"]["sshProxy"] = None
    tlConfig["CV101"]["l1l2monitor"] = {
        "hostname": "10.14.56.7",
        "username": "wrsroot",
        "password": "uteadmin",
        "tcpDumpPath": "/run/log/L1L2/",
        "itf": "ens4f1",
    }
    tlConfig["CV101"]["oam-0"] = {
        "hostname": "10.14.49.20",
        "username": "robot",
        "password": "rastre1",
    }
    tlConfig["CV101"]["cpcl-0"] = {
        "hostname": "cpcl-0.local",
        "username": "robot",
        "password": "rastre1",
    }
    tlConfig["CV101"]["cpif-0"] = {
        "hostname": "cpif-0.local",
        "username": "robot",
        "password": "rastre1",
        "tcpDumpPath": "/run/log/",
        "itf": "backhaul",
    }
    tlConfig["CV101"]["cpnb-0"] = {
        "hostname": "cpnb-0.local",
        "username": "robot",
        "password": "rastre1",
    }
    tlConfig["CV101"]["cpue-0"] = {
        "hostname": "cpue-0.local",
        "username": "robot",
        "password": "rastre1",
    }
    tlConfig["CV101"]["upue-0"] = {
        "hostname": "upue-0.local",
        "username": "robot",
        "password": "rastre1",
    }
    tlConfig["CV101"]["rap01"] = {
        "hostname": "192.168.2.60",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV101"]["asik"] = {
        "hostname": "192.168.2.60",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV101"]["abil"] = {
        "hostname": "fsp-1-1c",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["CV101"]["ru"] = {
        "hostname": "172.16.1.5",
        "username": "root",
        "password": "umniedziala",
    }
    tlConfig["CV101"]["ru-pc"] = {
        "hostname": "10.14.57.194",
        "username": "cv5g2_2",
        "password": "L@urent5G",
    }

    # AirPhone config
    tlConfig["AP39"] = {}
    tlConfig["AP39"]["type"] = "UE AirPhone"
    tlConfig["AP39"]["sshProxy"] = None
    tlConfig["AP39"]["testPC"] = {
        "hostname": "10.14.38.35",
        "username": "localuser",
        "password": "10c@1user",
    }
    tlConfig["AP39"]["l1l2monitor"] = {
        "hostname": "10.14.34.228",
        "username": "wrsroot",
        "password": "uteadmin",
        "tcpDumpPath": "/run/log/L1L2/",
        "itf": "ens6f1",
    }
    tlConfig["AP39"]["oam-0"] = {
        "hostname": "10.14.49.1",
        "username": "robot",
        "password": "rastre1",
    }
    tlConfig["AP39"]["rtm"] = {
        "hostname": "10.14.34.224",
        "username": "_rcpadmin",
        "password": "RCP_owner",
    }
    tlConfig["AP39"]["lteemu"] = {
        "hostname": "10.14.34.226",
        "username": "ute",
        "password": "ute",
    }
    tlConfig["AP39"]["egate"] = {
        "hostname": "10.14.34.226",
        "username": "ute",
        "password": "ute",
    }
    tlConfig["AP39"]["rap01"] = {
        "hostname": "192.168.2.61",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["AP39"]["fspj-1a"] = {
        "hostname": "192.168.253.52",
        "username": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tlConfig["AP39"]["ru"] = {
        "hostname": "192.168.102.2",
        "username": "root",
        "password": "umniedziala",
    }

    # Prisma config
    tlConfig["PR_Cepha"] = {}
    tlConfig["PR_Cepha"]["type"] = "UE Prisma"
    tlConfig["PR_Cepha"]["sshProxy"] = None
    tlConfig["PR_Cepha"]["airMosaic"] = {
        "hostname": "10.14.54.189",
        "username": "cv5g2_2",
        "password": "L@urent5G",
        "options": {"enableAMM": "false", "clockTimer": "300"},
    }
    tlConfig["PR_Cepha"]["lsuS1"] = {
        "hostname": "10.5.114.187",
        "username": "user",
        "password": "user",
    }
    tlConfig["PR_Cepha"]["lsuUu"] = {
        "hostname": "10.5.114.188",
        "username": "user",
        "password": "user",
    }

    # Prisma config Paros
    tlConfig["PR_Paros"] = {}
    tlConfig["PR_Paros"]["type"] = "UE Prisma"
    tlConfig["PR_Paros"]["sshProxy"] = None
    tlConfig["PR_Paros"]["airMosaic"] = {
        "hostname": "10.14.55.219",
        "username": "cv5g2_2",
        "password": "L@urent5G",
        "options": {"enableAMM": "false", "clockTimer": "300"},
    }
    tlConfig["PR_Paros"]["lsuS1"] = {
        "hostname": "10.14.56.16",
        "username": "user",
        "password": "user",
    }
    tlConfig["PR_Paros"]["lsuUu"] = {
        "hostname": "10.14.56.17",
        "username": "user",
        "password": "user",
    }

    tlConfig["PR_Sikinos"] = {}
    tlConfig["PR_Sikinos"]["type"] = "UE Prisma"
    tlConfig["PR_Sikinos"]["sshProxy"] = None
    tlConfig["PR_Sikinos"]["airMosaic"] = {
        "hostname": "10.14.56.14",
        "username": "cv5g2_2",
        "password": "L@urent5G",
        "options": {"enableAMM": "false", "clockTimer": "300"},
    }
    tlConfig["PR_Sikinos"]["lsuS1"] = {
        "hostname": "10.14.57.144",
        "username": "user",
        "password": "user",
    }
    tlConfig["PR_Sikinos"]["lsuUu"] = {
        "hostname": "10.14.57.145",
        "username": "user",
        "password": "user",
    }

    # Spirent Vertex config
    tlConfig["SP_Vertex_1"] = {}
    tlConfig["SP_Vertex_1"]["type"] = "Spirent Vertex #1"
    tlConfig["SP_Vertex_1"]["sshProxy"] = None
    tlConfig["SP_Vertex_1"]["spirentPC"] = {
        "hostname": "10.xxx.xxx.xxx",
        "username": "cv5g2_2",
        "password": "L@urent5G",
        "port": "6002",
    }

    tlConfig["SP_Vertex_2"] = {}
    tlConfig["SP_Vertex_2"]["type"] = "Spirent Vertex #2"
    tlConfig["SP_Vertex_2"]["sshProxy"] = None
    tlConfig["SP_Vertex_2"]["spirentPC"] = {
        "hostname": "10.xxx.xxx.xxx",
        "username": "cv5g2_2",
        "password": "L@urent5G",
        "port": "6002",
    }

    tlConfig["SP_VR5_1"] = {}
    tlConfig["SP_VR5_1"]["type"] = "Spirent VR5 #1"
    tlConfig["SP_VR5_1"]["sshProxy"] = None
    tlConfig["SP_VR5_1"]["spirentPC"] = {
        "hostname": "10.xxx.xxx.xxx",
        "username": "cv5g2_2",
        "password": "L@urent5G",
        "port": "6002",
    }

    # LogBook Server Config
    tlConfig["LOGBOOK"] = {}
    tlConfig["LOGBOOK"]["type"] = "Logbook Server"
    tlConfig["LOGBOOK"]["sshProxy"] = None
    tlConfig["LOGBOOK"]["server"] = {
        "hostname": "135.120.10.21",
        "username": "logbook",
        "password": "logbook",
    }

    # State Variable Builder Config
    stateVariableBuilderConfig = {}
    stateVariableBuilderConfig["SysLog"] = {}
    stateVariableBuilderConfig["SysLog"]["asik"] = {}
    stateVariableBuilderConfig["SysLog"]["cpif-0"] = {}
    stateVariableBuilderConfig["SysLog"]["cpcl-0"] = {}
    stateVariableBuilderConfig["SysLog"]["cpue-0"] = {}
    stateVariableBuilderConfig["SysLog"]["oam-0"] = {}
    stateVariableBuilderConfig["SysLog"]["lsuUu"] = {}
    stateVariableBuilderConfig["SysLog"]["abil"] = {}
    stateVariableBuilderConfig["SysLog"]["asik"]["counterList"] = (
        "Received f1 setup response from CU",
        "CPRI link state is",
        "CPRI link state is F:Operation, uri=/mz/p/v1/pbts/1/fbb/1/optLink/1",
        "CPRI link state is F:Operation, uri=/mz/p/v1/pbts/1/fbb/1/optLink/2",
        "CPRI link state is F:Operation, uri=/mz/p/v1/pbts/1/fbb/1/optLink/3",
        "CPRI link state is F:Operation, uri=/mz/p/v1/pbts/1/fbb/1/optLink/4",
    )
    stateVariableBuilderConfig["SysLog"]["cpif-0"]["counterList"] = (
        "SgNBAdditionRequest",
        "SgNBAdditionResponse",
    )
    stateVariableBuilderConfig["SysLog"]["cpcl-0"]["counterList"] = (
        "CuConfigurationUpdate",
        "CuConfigurationUpdateAck",
        "CreateUeContextReq",
        "Received response of type messages::cplane_cell::CreateUeContextResp",
    )
    stateVariableBuilderConfig["SysLog"]["cpue-0"]["counterList"] = (
        "CreateUeContextRespAck",
        "Sending PdcpEnableReq",
        "Received message with type messages::hi_user_cu::PdcpEnableResp",
        "nsaInactivityTimer",
        "actInactDetNSAUe",
        "bearerInactivityTimer",
        "bearerInactivityDetectionFlag",
        "Received BearerInactivity",
    )

    stateVariableBuilderConfig["SysLog"]["oam-0"]["counterList"] = (
        "snap successfully",
    )

    stateVariableBuilderConfig["SysLog"]["lsuUu"]["counterList"] = (
        "Snr on Pss",
        "SYNC->SSS CELL_ID",
    )
    stateVariableBuilderConfig["SysLog"]["abil"]["counterList"] = (
        "triggered ULDATA_SYNC_IND sending",
    )

    stateVariableBuilderConfig["Tshark"] = {}
    stateVariableBuilderConfig["Tshark"]["cpif-0"] = {}
    stateVariableBuilderConfig["Tshark"]["cpif-0"]["counterList"] = (
        "GNBCUConfigurationUpdate",
        "GNBCUConfigurationUpdateAcknowledge",
        "F1SetupRequest",
        "F1SetupResponse",
        "ENDCX2SetupRequest",
        "ENDCX2SetupResponse",
        "ENDCX2SetupFailure",
        "SgNBAdditionRequest",
        "SgNBAdditionResponse",
        "SgNBAdditionFailure",
    )
    stateVariableBuilderConfig["Tshark"]["asik"] = {}

    stateVariableBuilderConfig["Tshark"]["asik"]["stateVariableList"] = {
        "itf_l2_ps_cell_CellSetupResp.availablePucchAndCsiRsResources_item_639.pucchResourceForCsiReport",
        "itf_l2_ps_cell_CellSetupResp.availablePucchAndCsiRsResources_item_639.csiRsResourcesInSsSlots",
        "itf_l2_ps_cell_CellSetupResp.availablePucchAndCsiRsResources_item_639.csiRsResourcesInDataSlots",
        "itf_l2_ps_cell_CellSetupResp.CellSetupResp.nrCellIdentity",
        "itf_l2_ps_cell_CellSetupReq.CellSetupReq.nrCellIdentity",
        "x2ap_nokia_7_02.SgNBReleaseRequestAcknowledge_element",
        "x2ap.radioNetwork",
        "nr-rrc_nokia_7_02.drb_Identity",
        "x2ap.SgNBReleaseRequest_element",
        "x2ap_nokia_7_02.e_RAB_ID",
        "nr-rrc_nokia_7_02.newUE_Identity",
        "x2ap_nokia_7_02.SgNB_UE_X2AP_ID",
        "x2ap_nokia_7_02.UE_X2AP_ID",
        "x2ap.UE_X2AP_ID",
        "x2ap.SgNB_UE_X2AP_ID",
        "x2ap.SgNBReconfigurationComplete_element",
        "x2ap_nokia_7_02.SgNBAdditionRequestAcknowledge_element",
    }

    stateVariableBuilderConfig["L1L2"] = {}
    stateVariableBuilderConfig["L1L2"]["l1l2monitor"] = {}
    stateVariableBuilderConfig["L1L2"]["l1l2monitor"]["stateVariableList"] = {
        "UlCell_SetupReq.SetupReq.ulBandwidth",
        "UlCell_SetupReq.SetupReq.physCellId",
        "UlCell_SetupReq.SetupReq.subcellId",
        "DlCell_SetupReq.SetupReq.dlBandwidth",
        "DlCell_SetupReq.SetupReq.physCellId",
        "DlCell_SetupReq.SetupReq.subcellId",
        "DlCell_SetupResp.SetupResp.subcellId",
        "DlCell_SetupResp.SetupResp.subcellId_padding",
        "UlCell_SetupResp.SetupResp.subcellId",
        "UlCell_SetupResp.SetupResp.subcellId_padding",
        # /!\ uint64
        "itf_l2_lo_cell_CellSetupReq.CellSetupReq.nrCellIdentity",
        "itf_l2_lo_cell_CellSetupResp.CellSetupResp.nrCellIdentity",
    }

    stateVariableBuilderConfig["PETshark"] = {}
    stateVariableBuilderConfig["PETshark"]["PrismaTestPC"] = {}
    stateVariableBuilderConfig["PETshark"]["PrismaTestPC"]["stateVariableList"] = {
        "nx2ap-v0503.procedureCode",
        "nx2ap-v0503.id",
        "s1ap.pLMNidentity",
        "nokia-nr-rrc-v0503.physCellId",
        "ip.src",
        "ip.dst",
        "nx2ap-v0503.SgNBAdditionRequest_element",
        "nokia-nr-rrc-v0503.RRCReconfiguration_element",
        "nx2ap-v0503.SgNBAdditionRequestAcknowledge_element",
        "nx2ap-v0503.success_SgNBReconfComp_element",
    }

    # Instance method
    def __init__(self):
        self.ConfObj = configparser.ConfigParser()
        self.ConfObj.read(os.path.dirname(__file__) + "/Cockpit.ini")

        self.WindowTitle = self.ConfObj.get("CUSTOM", "WindowTitle")
        self.TcpPort = self.ConfObj.getint("SERVER", "TcpPort")

        self.ErrorLevel = self.ConfObj.getint("DEBUG", "ErrorLevel")
        self.DebugLevel = self.ConfObj.getint("DEBUG", "DebugLevel")
        self.DebugConsole = self.ConfObj.getint("DEBUG", "DebugConsole")
        self.DebugFile = self.ConfObj.get("DEBUG", "DebugFile")
        self.traceDirectory = ConfigClass.traceDirectory

        if "linux" in sys.platform:
            # self.wiresharkDissector = "/usr/share/wireshark/interfacce_5G18_D/luashark.lua"
            self.wiresharkDissector = (
                "/home/ute/luashark/generated_luashark/luashark.lua"
            )
            self.useCaseDetectorDirectory = (
                os.path.dirname(
                    os.path.realpath(__file__)) +
                "/UseCaseDetector")
        else:
            # self.wiresharkDissector = "C:\\tools\\wireshark\\experimental_fixed_master_R3_luashark\\luashark.lua"
            self.wiresharkDissector = (
                "C:\\tools\\wireshark\\generated_luashark\\luashark.lua"
            )
            self.useCaseDetectorDirectory = "/Users/rjourdai/Documents/Automatization_getField_SMTest/source/" \
                                            "Cockpit/UseCaseDetector"

        self.tlConfig = ConfigClass.tlConfig

        self.eventStop = False
        self.threadSema = Semaphore()
        self.threadList = []
        self._totalNbOfThreadSinceStart = 0
        self.pOpenSema = Semaphore()

    def createConfig(self, OAM_IP):
        with open("debufile.txt", "w") as file:
            file.write("createConfig")
        cv = OAM_IP.split(".")[-1]
        ConfigClass.tlConfig = {}
        ConfigClass.tlConfig["type"] = "gNodeB_Classical"
        ConfigClass.tlConfig["logbook"] = (
            "ispeedtools-logbook_cv" + cv + "@acos.alcatel-lucent.com"
        )
        ConfigClass.tlConfig["sshProxy"] = None
        ConfigClass.tlConfig["testPC"] = {
            "hostname": OAM_IP,
            "username": "toor4nsn",
            "password": "oZPS0POrRieRtu",
        }
        ConfigClass.tlConfig["ru"] = {
            "hostname": "172.21.1.21",
            "username": "root",
            "password": "umniedziala",
        }
        ConfigClass.tlConfig["fct-0a"] = {
            "hostname": "192.168.255.1",
            "username": "toor4nsn",
            "password": "oZPS0POrRieRtu",
            "tcpDumpPath": "/tmp/",
            "itf": "etha01",
        }
        ConfigClass.tlConfig["fct-0b"] = {
            "hostname": "192.168.253.17",
            "username": "toor4nsn",
            "password": "oZPS0POrRieRtu",
            "tcpDumpPath": "/tmp/",
            "itf": "etha01",
        }
        ConfigClass.tlConfig["fct-4b"] = {
            "hostname": "192.168.253.33",
            "username": "toor4nsn",
            "password": "oZPS0POrRieRtu",
            "tcpDumpPath": "/tmp/",
            "itf": "etha01",
        }
        ConfigClass.tlConfig["asp-1a"] = {
            "hostname": "fsp-1-1a",
            "username": "toor4nsn",
            "password": "oZPS0POrRieRtu",
        }
        ConfigClass.tlConfig["asp-1b"] = {
            "hostname": "fsp-1-1b",
            "username": "toor4nsn",
            "password": "oZPS0POrRieRtu",
        }
        ConfigClass.tlConfig["aspa-1c"] = {
            "hostname": "fsp-1-1c",
            "username": "toor4nsn",
            "password": "oZPS0POrRieRtu",
        }
        self.tlConfig = ConfigClass.tlConfig

    def registerThread(self, thread, ueId):
        self.threadSema.acquire()
        self._totalNbOfThreadSinceStart += 1
        self.threadList.append((thread, ueId))
        self.threadSema.release()

    def releaseThread(self, thread, ueId):
        self.threadSema.acquire()
        self.threadList.remove((thread, ueId))
        self.threadSema.release()

    def getTotalNbOfThreadSinceStart(self):
        return self._totalNbOfThreadSinceStart

    def getNumberOfThread(self, parUeId=None):
        result = 0
        for (thread, ueId) in self.threadList:
            if (parUeId is None) | (parUeId == ueId):
                result += 1
        return result
