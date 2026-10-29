<?xml version="1.0" encoding="UTF-8"?>
<!-- Scenario created in date 2023-08-11 10:33:27 by AirMosaic 8.23.6-31 (Build 202304190825)-->
<TestScenario Version="7" Repetitions="1" RepetitionsDelay="1000" Looped="false" DurationEnable="false" Annotation="" GlobalVariables="" LayoutLinkEnabled="true" CountersLayoutPath="" ChartsLayoutPath="" PesqLayoutPath="" ScenarioType="" AppVersion="AirMosaic 8.23.6-31 (Build 202304190825)" TstmName="LTE_Tm">
  <Bearer>
    <db name="Bearer" formatname="Bearer" version="1.0 1.0" />
  </Bearer>
  <Flow>
    <db name="Flow" formatname="Flow" version="1.0 1.0" />
  </Flow>
  <BearerModificationProfileList>
    <db name="Bearer 0" formatname="BearerModDb" version="1.0" />
    <looped name="Bearer 0" value="false" />
    <db name="Bearer 1" formatname="BearerModDb" version="1.0" />
    <looped name="Bearer 1" value="false" />
  </BearerModificationProfileList>
  <Groups>
    <Group name="TDDnonCA" extensible="true" enableGroup="true" loopenGroupRepetitions="false" groupRepetitionsNumber="1">
      "user 01","user 02","user 03","user 04","user 05","user 06","user 07","user 08","user 09","user 10","user 11","user 12","user 13","user 14","user 15","user 16","user 17","user 18","user 19","user 20","user 21","user 22","user 23","user 24","user 25","user 26","user 27","user 28","user 29","user 30","user 31","user 32"
      <TemplateProfileMobility property="true" mobilityName="Advanced Mobility" radiocondition="New Mobility Environment 0" spatialDisplacement="Index" indexdisplacement="0" temporalDisplacement="Scenario Driven" Distribution="No Delay " upondetach="false" name="com.prisma.mobility.mobilityplugin.MapDrivenMobility" cellbinding="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;RadioConditionCellBinding&gt;&#xA;    &lt;cellBindingMap/&gt;&#xA;    &lt;autoCellBinding&gt;false&lt;/autoCellBinding&gt;&#xA;&lt;/RadioConditionCellBinding&gt;&#xA;" nrcellbinding="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;RadioConditionNrCellBinding&gt;&#xA;    &lt;nrCellBindingMap&gt;&#xA;        &lt;entry&gt;&#xA;            &lt;key&gt;New Custom 5GNr Cell 8&lt;/key&gt;&#xA;            &lt;value&gt;1&lt;/value&gt;&#xA;        &lt;/entry&gt;&#xA;    &lt;/nrCellBindingMap&gt;&#xA;&lt;/RadioConditionNrCellBinding&gt;&#xA;" overrideoptions="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;OverrideOptions&gt;&#xA;    &lt;DEFAULT_OVERRIDE_OPTION&gt;None&lt;/DEFAULT_OVERRIDE_OPTION&gt;&#xA;    &lt;initialCellAttached&gt;1&lt;/initialCellAttached&gt;&#xA;    &lt;earfcnAttached&gt;100&lt;/earfcnAttached&gt;&#xA;    &lt;overrideOptionSelected&gt;INITIAL_CELL_ATTACHED&lt;/overrideOptionSelected&gt;&#xA;&lt;/OverrideOptions&gt;&#xA;" />
    </Group>
  </Groups>
  <SessionList>
    <Session name="New session 15" ACCESS_NETWORK="NR" InterarrivalTime="1000" RandomRate="false" Repetitions="32" SessionRepetitionsMode="Repetitions" groupRate="1000" groupRep="1" groupBlockLoop="false" groupMode="Variable Rate" SessionMode="Normal" SchedulingKind="Timer Triggered" StartSession="0008TDDnonCA0014New session 1500000000000100000" loop="false" Group="TDDnonCA">
      <TestTraceManager masterTraceLength="11" traces="1">
        <TestTrace>
          <TemplateProfile name="Registration" instance="" Mandatory="false" SuccessPercentage="100.0" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="3000" />
          <TemplateProfile name="PDU Session Establish" instance="" Mandatory="false" SuccessPercentage="100.0" NR_PDU_SESSION_ID="1" MAX_DATA_RATE_UP_INT_PROT_UL="Full data rate" MAX_DATA_RATE_UP_INT_PROT_DL="Full data rate" IPCAN_TYPE="IPv4" NR_PDU_SESSION_SSC3_ID="" ALWAYS_ON_PDU_SESSION="(Default) Not Present" PDU_TYPE="IPv4" NRSM_INFO_TRANSFER_FLAG="false" NR_S_NSSAI="1-d143a5-?-?" IPCAN_NR_S_NSSAI="" NR_SSC_MODE="Not Present" APN="wap3.nokia.com" PCO="" SM_INFO_TRANSFER_FLAG="false" REQUEST_TYPE="InitialRequest" EAP_IDENTITY="" EAP_ALGORITHM="MD5" EAP_USERNAME="" EAP_PASSWORD="" DN_SPEC_ID_IN_CONTAINER="false" PDN_TYPE="IPv4" ESM_INFO_TRANSFER_FLAG="false" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="1000" />
          <TemplateProfile name="UDG Bidirectional Transmission" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" BEARER_TAG="NONE" T_ACT_OFFSET="0" DEACT_FLAG_ENUM="Bearer not deactivated" TIME_TO_WAIT="100" BearerType_VIDEO="Default bearer" BEARER_TAG_VIDEO="NONE" T_ACT_OFFSET_VIDEO="0" DEACT_FLAG_ENUM_VIDEO="Bearer not deactivated" TIME_TO_WAIT_VIDEO="100" FlowType="Default flow" FLOW_TAG="NONE" T_ACT_OFFSET_5GC="0" DEACT_FLAG_ENUM_5GC="Flow not deactivated" TIME_TO_WAIT_FLOW="100" FlowType_VIDEO="Default flow" FLOW_TAG_VIDEO="NONE" T_ACT_OFFSET_5GC_VIDEO="0" DEACT_FLAG_ENUM_5GC_VIDEO="Flow not deactivated" TIME_TO_WAIT_VIDEO_FLOW="100" APN="Default APN" traffic_type="Individual UE throughput configuration" EXP_THROUGHPUT_UL_Simpl="0.0" EXP_THROUGHPUT_DL_Simpl="0.0" EXP_THROUGHPUT_UL="0.0" EXP_THROUGHPUT_DL="28800.0" USR_PKT_LEN_TYPE="Fixed" USR_PKT_LEN="1200" USR_PKT_LEN_Simpl="100" USR_PKT_LEN_MIN="60" USR_PKT_LEN_MAX="140" NET_PKT_LEN_TYPE="Fixed" NET_PKT_LEN="1200" NET_PKT_LEN_Simpl="100" NET_PKT_LEN_MIN="60" NET_PKT_LEN_MAX="140" ProtocolLayer="IP" REMOTE_PORT="50101" UUDG_NET_IP="10.64.56.146" UUDG_NET_IPV6="2222::22" DELAY="100" NUM_TRAN="1" TRAN_TIME="500000000" TRAN_T_INT="1000" IDLE_OUT_TIME="0" IDLE_OUT_SIDE="UE Not Synchronous" RESTART_ON_ABORT="false" ENABLE_ETH_PDU_SESSION="false" ADDR_TYPE="IPv4" UUDG_IPV4_ETH_ADDR="22.22.22.22" UUDG_IPV6_ETH_ADDR="2222::22" UE_MAC_ADDRESS="000000000000" NET_MAC_ADDRESS="000000000000" NR_PDU_SESSION_ID="1" USR_N_PKT="1" USR_PKT_T_INT="10000000" USR_PKT_T_INT_UNIT="Millisecond" NET_N_PKT="3" NET_PKT_T_INT="1" NET_PKT_T_INT_UNIT="Millisecond" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="10000000" />
          <TemplateProfile name="UDG Monodirectional transmission Downlink" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" BEARER_TAG="NONE" T_ACT_OFFSET="0" DEACT_FLAG_ENUM="Bearer not deactivated" TIME_TO_WAIT="100" BearerType_VIDEO="Default bearer" BEARER_TAG_VIDEO="NONE" T_ACT_OFFSET_VIDEO="0" DEACT_FLAG_ENUM_VIDEO="Bearer not deactivated" TIME_TO_WAIT_VIDEO="100" FlowType="Default flow" FLOW_TAG="NONE" T_ACT_OFFSET_5GC="0" DEACT_FLAG_ENUM_5GC="Flow not deactivated" TIME_TO_WAIT_FLOW="100" FlowType_VIDEO="Default flow" FLOW_TAG_VIDEO="NONE" T_ACT_OFFSET_5GC_VIDEO="0" DEACT_FLAG_ENUM_5GC_VIDEO="Flow not deactivated" TIME_TO_WAIT_VIDEO_FLOW="100" APN="Default APN" traffic_type="Individual UE throughput configuration" EXP_THROUGHPUT_UL_Simpl="0.0" EXP_THROUGHPUT_DL_Simpl="0.0" EXP_THROUGHPUT_UL="0.0" EXP_THROUGHPUT_DL="48000.0" USR_PKT_LEN_TYPE="Fixed" USR_PKT_LEN="100" USR_PKT_LEN_Simpl="100" USR_PKT_LEN_MIN="60" USR_PKT_LEN_MAX="140" NET_PKT_LEN_TYPE="Fixed" NET_PKT_LEN="1200" NET_PKT_LEN_Simpl="100" NET_PKT_LEN_MIN="60" NET_PKT_LEN_MAX="140" ProtocolLayer="IP" REMOTE_PORT="50101" UUDG_NET_IP="10.64.56.146" UUDG_NET_IPV6="2222::22" DELAY="100" NUM_TRAN="1" TRAN_TIME="500000000" TRAN_T_INT="1000" IDLE_OUT_TIME="0" IDLE_OUT_SIDE="UE Not Synchronous" RESTART_ON_ABORT="false" ENABLE_ETH_PDU_SESSION="false" ADDR_TYPE="IPv4" UUDG_IPV4_ETH_ADDR="22.22.22.22" UUDG_IPV6_ETH_ADDR="2222::22" UE_MAC_ADDRESS="000000000000" NET_MAC_ADDRESS="000000000000" NR_PDU_SESSION_ID="1" NET_N_PKT="5" NET_PKT_T_INT="1" NET_PKT_T_INT_UNIT="Millisecond" />
          <TemplateProfile name="UDG Monodirectional transmission Uplink" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" BEARER_TAG="NONE" T_ACT_OFFSET="0" DEACT_FLAG_ENUM="Bearer not deactivated" TIME_TO_WAIT="100" BearerType_VIDEO="Default bearer" BEARER_TAG_VIDEO="NONE" T_ACT_OFFSET_VIDEO="0" DEACT_FLAG_ENUM_VIDEO="Bearer not deactivated" TIME_TO_WAIT_VIDEO="100" FlowType="Default flow" FLOW_TAG="NONE" T_ACT_OFFSET_5GC="0" DEACT_FLAG_ENUM_5GC="Flow not deactivated" TIME_TO_WAIT_FLOW="100" FlowType_VIDEO="Default flow" FLOW_TAG_VIDEO="NONE" T_ACT_OFFSET_5GC_VIDEO="0" DEACT_FLAG_ENUM_5GC_VIDEO="Flow not deactivated" TIME_TO_WAIT_VIDEO_FLOW="100" APN="Default APN" traffic_type="Individual UE throughput configuration" EXP_THROUGHPUT_UL_Simpl="0.0" EXP_THROUGHPUT_DL_Simpl="0.0" EXP_THROUGHPUT_UL="9600.0" EXP_THROUGHPUT_DL="0.0" USR_PKT_LEN_TYPE="Fixed" USR_PKT_LEN="1200" USR_PKT_LEN_Simpl="100" USR_PKT_LEN_MIN="60" USR_PKT_LEN_MAX="140" NET_PKT_LEN_TYPE="Fixed" NET_PKT_LEN="100" NET_PKT_LEN_Simpl="100" NET_PKT_LEN_MIN="60" NET_PKT_LEN_MAX="140" ProtocolLayer="IP" REMOTE_PORT="50101" UUDG_NET_IP="10.64.56.146" UUDG_NET_IPV6="2222::22" DELAY="100" NUM_TRAN="1" TRAN_TIME="500000000" TRAN_T_INT="1000" IDLE_OUT_TIME="0" IDLE_OUT_SIDE="UE Not Synchronous" RESTART_ON_ABORT="false" ENABLE_ETH_PDU_SESSION="false" ADDR_TYPE="IPv4" UUDG_IPV4_ETH_ADDR="22.22.22.22" UUDG_IPV6_ETH_ADDR="2222::22" UE_MAC_ADDRESS="000000000000" NET_MAC_ADDRESS="000000000000" NR_PDU_SESSION_ID="1" USR_N_PKT="1" USR_PKT_T_INT="1" USR_PKT_T_INT_UNIT="Millisecond" />
          <TemplateProfile name="PDU Session Release" instance="" Mandatory="false" SuccessPercentage="100.0" NR_PDU_SESSION_ID="1" APN="Default APN" PCO="" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="10000" />
          <TemplateProfile name="Deregistration" instance="" Mandatory="false" SuccessPercentage="100.0" DETACH_SWOFF_IRAT="false" DETACH_SWOFF="false" DEREGISTRATION_SWOFF="false" />
        </TestTrace>
      </TestTraceManager>
    </Session>
  </SessionList>
  <globals />
  <SmartphoneSimulator userLibraryFilename="" />
  <cell_list />
  <func_low_list />
  <MdmCellBinding>&lt;?xml version="1.0" encoding="UTF-8" standalone="yes"?&gt;
&lt;RadioConditionCellBinding&gt;
    &lt;cellBindingMap/&gt;
    &lt;autoCellBinding&gt;false&lt;/autoCellBinding&gt;
&lt;/RadioConditionCellBinding&gt;</MdmCellBinding>
  <MdmCellBindingNr>&lt;?xml version="1.0" encoding="UTF-8" standalone="yes"?&gt;
&lt;RadioConditionNrCellBinding&gt;
    &lt;nrCellBindingMap/&gt;
&lt;/RadioConditionNrCellBinding&gt;</MdmCellBindingNr>
  <AmmExternalLinkedFiles rclibexternallinkedfilename="Mobility_2cells.rclib" />
</TestScenario>

