import sys
import pexpect
from io import BytesIO


class pcf:
    def __init__(self):
        pass

    def pcf_connect(self, ip, username, password):
        self.ip = ip
        self.username = username
        self.password = password
#        self.process = pexpect.spawn("ssh {}@{}".format(self.username, self.ip))
        self.process = pexpect.spawn("ssh {}@{}".format(self.username, self.ip), encoding='utf-8')
        self.process.logfile_read = sys.stdout
        self.process.expect("[Pp]assword:")
        self.process.sendline("{}".format(self.password))
        self.process.sendline("/home/sim-5g-pcf")
        self.process.expect("CLI>")

    def pcf_start(self, ims, ip):
        self.ims = ims
        self.ip = ip
        if len(self.ims) == 5:
            ims_cmd = "configure pcf-profile 1 match-imsi " + self.ims + "0000000000" + " " + self.ims + "9999999999"
        elif len(self.ims) == 6:
            ims_cmd = "configure pcf-profile 1 match-imsi " + self.ims + "000000000" + " " + self.ims + "999999999"
        service_cmd = "configure node pcf 1 server-service " + self.ip + ":8080"
        client_cmd = "configure node pcf 1 client-addr " + self.ip
        cmdList = (
            "configure create pcf-profile 1",
            "configure pcf-profile 1 generate-ref true",
            "configure pcf-profile 1 create-res 201",
            "configure pcf-profile 1 release-res 204",
            "configure pcf-profile 1 update-res 200",
            ims_cmd,
            "configure create node pcf 1",
            service_cmd,
            client_cmd,
            "configure node pcf 1 add-profile 1",
            "proc node pcf 1 start-service",
            "proc node pcf 1 start-client",
        )
        for cmd in cmdList:
            self.process.sendline(cmd)
            self.process.expect("CLI>")
            output = self.process.before
            print(output)

    def pcf_add_one_QoS(self, five_qi, priorityLevel, server_ip):
        self.five_qi = five_qi
        self.priorityLevel = priorityLevel
        self.server_ip = server_ip
        five_qi_cmd = 'configure custom-data 33 json add-number \
"/smPolicyDecision/qosDecs/qosIdForDefault1/5qi" ' + self.five_qi
        priorityLevel_cmd = 'configure custom-data 33 json add-number \
"/smPolicyDecision/qosDecs/qosIdForDefault1/arp/priorityLevel" ' + self.priorityLevel
        in_ip_1_cmd = 'configure custom-data 33 json add-string \
"/smPolicyDecision/pccRules/MDRB-50UDP/flowInfos/0/flowDescription" '
        in_ip_2_cmd = '"permit out 17 from ' + self.server_ip + ' to any"'
        in_server_ip_cmd = in_ip_1_cmd + in_ip_2_cmd
        out_ip_1_cmd = 'configure custom-data 33 json add-string \
"/smPolicyDecision/pccRules/MDRB-50UDP/flowInfos/0/flowDescription" '
        out_ip_2_cmd = '"permit in 17 from any to ' + server_ip + '"'
        out_server_ip_cmd = out_ip_1_cmd + out_ip_2_cmd
        cmdList = (
            "configure create custom-data 33",
            'configure custom-data 33 json add-object "/smPolicyDecision"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/qosId" '
            "qosIdForDefault1",
            five_qi_cmd,
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault1/arp"',
            priorityLevel_cmd,
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/maxbrUl" "37 Kbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/maxbrDl" "37 Kbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/gbrUl" "37 Kbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/gbrDl" "37 Kbps"',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs/tcIdForDefault1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1/tcId" '
            "tcIdForDefault1",
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1/flowStatus" '
            "ENABLED",
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1/flowStatus" '
            "ENABLED",
            'configure custom-data 33 json add-object "/smPolicyDecision/chgDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/chgDecs/chgData1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/chgDecs/chgData1/chgId" ' "chgData1",
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/MDRB-50UDP"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/MDRB-50UDP/pccRuleId" '
            "MDRB-50UDP",
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/MDRB-50UDP/flowInfos"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/MDRB-50UDP/flowInfos/0"',
            in_server_ip_cmd,
            out_server_ip_cmd,
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/MDRB-50UDP/flowInfos/0'
            '/flowDirection" BIDIRECTIONAL',
            'configure custom-data 33 json add-number "/smPolicyDecision/pccRules/MDRB-50UDP/precedence" 3',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/MDRB-50UDP/refQosData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/MDRB-50UDP/refQosData/-" '
            "qosIdForDefault1",
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/MDRB-50UDP/refTcData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/MDRB-50UDP/refTcData/-" '
            "tcIdForDefault1",
            'configure custom-data 33 json add-array "/smPolicyDecision/lastReqRuleData"',
            'configure custom-data 33 json add-object "/smPolicyDecision/lastReqRuleData/0"',
            'configure custom-data 33 json add-array "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds"',
            'configure custom-data 33 json add-string "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds/-" '
            "MDRB-50UDP",
            'configure custom-data 33 json add-array "/smPolicyDecision/policyCtrlReqTriggers"',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" PRA_CH',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" SCNN_CH',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" AN_CH_COR',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" UE_IP_CH',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" DEF_QOS_CH',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" AC_TY_CH',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" SE_AMBR_CH',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" QOS_NOTIF',
            "configure pcf-profile 1 policy-notification-data 33",
            "proc node pcf 1 policy-update-notify all",
        )

        for cmd in cmdList:
            self.process.sendline(cmd)
            self.process.expect("CLI>")
            output = self.process.before
            print(output)

    def pcf_add_two_5QI1(self, five_qi, priorityLevel1, priorityLevel2, server_ip1, server_ip2):
        self.five_qi = five_qi
        self.priorityLevel1 = priorityLevel1
        self.priorityLevel2 = priorityLevel2
        self.server_ip1 = server_ip1
        self.server_ip2 = server_ip2
        five_qi1_cmd = 'configure custom-data 33 json add-number \
    "/smPolicyDecision/qosDecs/qosIdForDefault1/5qi" ' + self.five_qi
        five_qi2_cmd = 'configure custom-data 33 json add-number \
            "/smPolicyDecision/qosDecs/qosIdForDefault2/5qi" ' + self.five_qi
        priorityLevel1_cmd = 'configure custom-data 33 json add-number \
    "/smPolicyDecision/qosDecs/qosIdForDefault1/arp/priorityLevel" ' + self.priorityLevel1
        priorityLevel2_cmd = 'configure custom-data 33 json add-number \
            "/smPolicyDecision/qosDecs/qosIdForDefault2/arp/priorityLevel" ' + self.priorityLevel2
        in_ip_1_cmd = 'configure custom-data 33 json add-string \
    "/smPolicyDecision/pccRules/MDRB-50UDP/flowInfos/0/flowDescription" '
        in_ip_1_cmd2 = 'configure custom-data 33 json add-string \
            "/smPolicyDecision/pccRules/MDRB-50TCP/flowInfos/0/flowDescription" '
        in_ip_2_cmd = '"permit out 17 from ' + self.server_ip1 + ' to any"'
        in_server_ip_cmd = in_ip_1_cmd + in_ip_2_cmd
        in_ip_2_cmd2 = '"permit out 17 from ' + self.server_ip2 + ' to any"'
        in_server_ip_cmd2 = in_ip_1_cmd2 + in_ip_2_cmd2
        out_ip_1_cmd = 'configure custom-data 33 json add-string \
    "/smPolicyDecision/pccRules/MDRB-50UDP/flowInfos/0/flowDescription" '
        out_ip_1_cmd2 = 'configure custom-data 33 json add-string \
            "/smPolicyDecision/pccRules/MDRB-50TCP/flowInfos/0/flowDescription" '
        out_ip_2_cmd = '"permit in 17 from any to ' + self.server_ip1 + '"'
        out_server_ip_cmd = out_ip_1_cmd + out_ip_2_cmd
        out_ip_2_cmd2 = '"permit in 17 from any to ' + self.server_ip2 + '"'
        out_server_ip_cmd2 = out_ip_1_cmd2 + out_ip_2_cmd2
        cmdList = (
            "configure create custom-data 33",
            'configure custom-data 33 json add-object "/smPolicyDecision"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/qosId" '
            "qosIdForDefault1",
            five_qi1_cmd,
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault1/arp"',
            priorityLevel1_cmd,
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/maxbrUl" "37 Kbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/maxbrDl" "37 Kbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/gbrUl" "37 Kbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault1/gbrDl" "37 Kbps"',
            'configure custom-data 33 json add-bool "/smPolicyDecision/qosDecs/qosIdForDefault1/qnc" "false"',
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault2"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault2/qosId" '
            "qosIdForDefault2",
            five_qi2_cmd,
            'configure custom-data 33 json add-object "/smPolicyDecision/qosDecs/qosIdForDefault2/arp"',
            priorityLevel2_cmd,
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault2/maxbrUl" "38 Kbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault2/maxbrDl" "38 Kbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault2/gbrUl" "38 Kbps"',
            'configure custom-data 33 json add-string "/smPolicyDecision/qosDecs/qosIdForDefault2/gbrDl" "38 Kbps"',
            'configure custom-data 33 json add-bool "/smPolicyDecision/qosDecs/qosIdForDefault2/qnc" "false"',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs"',
            'configure custom-data 33 json add-object "/smPolicyDecision/traffContDecs/tcIdForDefault1"',
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1/tcId" '
            "tcIdForDefault1",
            'configure custom-data 33 json add-string "/smPolicyDecision/traffContDecs/tcIdForDefault1/flowStatus" '
            "ENABLED",
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/MDRB-50UDP"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/MDRB-50UDP/pccRuleId" '
            "MDRB-50UDP",
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/MDRB-50UDP/flowInfos"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/MDRB-50UDP/flowInfos/0"',
            in_server_ip_cmd,
            out_server_ip_cmd,
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/MDRB-50UDP/flowInfos/0'
            '/flowDirection" BIDIRECTIONAL',
            'configure custom-data 33 json add-number "/smPolicyDecision/pccRules/MDRB-50UDP/precedence" 10',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/MDRB-50UDP/refQosData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/MDRB-50UDP/refQosData/-" '
            "qosIdForDefault1",
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/MDRB-50UDP/refTcData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/MDRB-50UDP/refTcData/-" '
            "tcIdForDefault1",
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/MDRB-50TCP"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/MDRB-50TCP/pccRuleId" MDRB-50TCP',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/MDRB-50TCP/flowInfos"',
            'configure custom-data 33 json add-object "/smPolicyDecision/pccRules/MDRB-50TCP/flowInfos/0"',
            in_server_ip_cmd2,
            out_server_ip_cmd2,
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/MDRB-50TCP/flowInfos/0/'
            'flowDirection" BIDIRECTIONAL',
            'configure custom-data 33 json add-number "/smPolicyDecision/pccRules/MDRB-50TCP/precedence" 20',
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/MDRB-50TCP/refQosData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/MDRB-50TCP/refQosData/-" '
            "qosIdForDefault2",
            'configure custom-data 33 json add-array "/smPolicyDecision/pccRules/MDRB-50TCP/refTcData"',
            'configure custom-data 33 json add-string "/smPolicyDecision/pccRules/MDRB-50TCP/refTcData/-" '
            "tcIdForDefault1",
            'configure custom-data 33 json add-array "/smPolicyDecision/lastReqRuleData"',
            'configure custom-data 33 json add-object "/smPolicyDecision/lastReqRuleData/0"',
            'configure custom-data 33 json add-array "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds"',
            'configure custom-data 33 json add-string "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds/-" '
            "MDRB-50UDP",
            'configure custom-data 33 json add-string "/smPolicyDecision/lastReqRuleData/0/refPccRuleIds/-" '
            "MDRB-50TCP",
            'configure custom-data 33 json add-array "/smPolicyDecision/policyCtrlReqTriggers"',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" PRA_CH',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" SCNN_CH',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" AN_CH_COR',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" UE_IP_CH',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" DEF_QOS_CH',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" AC_TY_CH',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" SE_AMBR_CH',
            'configure custom-data 33 json add-string "/smPolicyDecision/policyCtrlReqTriggers/-" QOS_NOTIF',
            "configure pcf-profile 1 policy-notification-data 33",
            "proc node pcf 1 policy-update-notify all",
        )

        for cmd in cmdList:
            self.process.sendline(cmd)
            self.process.expect("CLI>")
            output = self.process.before
            print(output)

    def pcf_disconnect(self):
        self.process.kill(0)

    def pcf_add_and_delete_QoS(self):
        self.pcf_add_QoS_for_delete
        self.pcf_delete_added_QoS
