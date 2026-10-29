<?xml version="1.0" encoding="UTF-8"?>
<!-- Scenario created in date 2022-05-17 08:50:57 by AirMosaicLTEUu 8.22.1RC19 (Build 202201281618)-->
<TestScenario Version="7" Repetitions="1" RepetitionsDelay="1000" Looped="false" DurationEnable="false" Annotation="" GlobalVariables="" LayoutLinkEnabled="true" CountersLayoutPath="" ChartsLayoutPath="/mnt/nkpi_france$/I&amp;V-PS-327/Prisma/Config/Grouped_Charts_Throughput_Beam2.lch" PesqLayoutPath="" AppVersion="AirMosaicLTEUu 8.22.1RC19 (Build 202201281618)" TstmName="LTE_Tm">
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
    <Group name="Group1" extensible="true" enableGroup="true" loopenGroupRepetitions="false" groupRepetitionsNumber="1">
      "user sa 244 07 1"
      <TemplateProfileMobility property="true" mobilityName="Advanced Mobility" radiocondition="5gCell1_4G" spatialDisplacement="Round Robin" temporalDisplacement="Scenario Driven" Distribution="No Delay " upondetach="false" name="com.prisma.mobility.mobilityplugin.MapDrivenMobility" cellbinding="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;RadioConditionCellBinding&gt;&#xA;    &lt;cellBindingMap&gt;&#xA;        &lt;entry&gt;&#xA;            &lt;key&gt;New Custom Lte Cell 3&lt;/key&gt;&#xA;            &lt;value&gt;20&lt;/value&gt;&#xA;        &lt;/entry&gt;&#xA;        &lt;entry&gt;&#xA;            &lt;key&gt;New Custom Lte Cell 2&lt;/key&gt;&#xA;            &lt;value&gt;10&lt;/value&gt;&#xA;        &lt;/entry&gt;&#xA;    &lt;/cellBindingMap&gt;&#xA;    &lt;autoCellBinding&gt;false&lt;/autoCellBinding&gt;&#xA;&lt;/RadioConditionCellBinding&gt;&#xA;" nrcellbinding="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;RadioConditionNrCellBinding&gt;&#xA;    &lt;nrCellBindingMap&gt;&#xA;        &lt;entry&gt;&#xA;            &lt;key&gt;New Custom 5GNr Cell 0&lt;/key&gt;&#xA;            &lt;value&gt;1&lt;/value&gt;&#xA;        &lt;/entry&gt;&#xA;        &lt;entry&gt;&#xA;            &lt;key&gt;New Custom 5GNr Cell 1&lt;/key&gt;&#xA;            &lt;value&gt;2&lt;/value&gt;&#xA;        &lt;/entry&gt;&#xA;    &lt;/nrCellBindingMap&gt;&#xA;&lt;/RadioConditionNrCellBinding&gt;&#xA;" overrideoptions="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;OverrideOptions&gt;&#xA;    &lt;DEFAULT_OVERRIDE_OPTION&gt;None&lt;/DEFAULT_OVERRIDE_OPTION&gt;&#xA;    &lt;initialCellAttached&gt;default&lt;/initialCellAttached&gt;&#xA;    &lt;earfcnAttached&gt;100&lt;/earfcnAttached&gt;&#xA;    &lt;overrideOptionSelected&gt;NONE&lt;/overrideOptionSelected&gt;&#xA;&lt;/OverrideOptions&gt;&#xA;" />
    </Group>
  </Groups>
  <SessionList>
    <Session name="Session 1" ACCESS_NETWORK="NR" InterarrivalTime="1000" RandomRate="false" Repetitions="1" SessionRepetitionsMode="Repetitions" groupRate="1000" groupRep="1" groupBlockLoop="false" groupMode="Variable Rate" SessionMode="Normal" SchedulingKind="Timer Triggered" StartSession="0006Group10009Session 100000000000100000" loop="false" Group="Group1">
      <TestTraceManager masterTraceLength="9" traces="1">
        <TestTrace>
          <TemplateProfile name="GanAttach" instance="" Mandatory="true" SuccessPercentage="100.0" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="1000" />
          <TemplateProfile name="IPCanEstablishment" instance="" Mandatory="false" SuccessPercentage="100.0" NR_PDU_SESSION_ID="1" IPCAN_TYPE="IPv4" PDU_TYPE="IPv4" NRSM_INFO_TRANSFER_FLAG="false" NR_S_NSSAI="1-d143a5-?-?" IPCAN_NR_S_NSSAI="" NR_SSC_MODE="Not Present" APN="n26ho.paris.com" PCO="" SM_INFO_TRANSFER_FLAG="false" REQUEST_TYPE="InitialRequest" PDN_TYPE="IPv4" ESM_INFO_TRANSFER_FLAG="false" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="1000" />
          <TemplateProfile name="IP Passthrough start" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" BEARER_TAG="NONE" T_ACT_OFFSET="0" DEACT_FLAG_ENUM="Bearer not deactivated" TIME_TO_WAIT="100" BearerType_VIDEO="Default bearer" BEARER_TAG_VIDEO="NONE" T_ACT_OFFSET_VIDEO="0" DEACT_FLAG_ENUM_VIDEO="Bearer not deactivated" TIME_TO_WAIT_VIDEO="100" FlowType="Default flow" FLOW_TAG="NONE" T_ACT_OFFSET_5GC="0" DEACT_FLAG_ENUM_5GC="Flow not deactivated" TIME_TO_WAIT_FLOW="100" FlowType_VIDEO="Default flow" FLOW_TAG_VIDEO="NONE" T_ACT_OFFSET_5GC_VIDEO="0" DEACT_FLAG_ENUM_5GC_VIDEO="Flow not deactivated" TIME_TO_WAIT_VIDEO_FLOW="100" APN="Default APN" NR_PDU_SESSION_ID="1" APC_IP=";user sa:192.168.203.10" APC_IP_NETMASK="" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="30000" />
          <TemplateProfile name="IP Passthrough stop" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" BEARER_TAG="NONE" T_ACT_OFFSET="0" DEACT_FLAG_ENUM="Bearer not deactivated" TIME_TO_WAIT="100" BearerType_VIDEO="Default bearer" BEARER_TAG_VIDEO="NONE" T_ACT_OFFSET_VIDEO="0" DEACT_FLAG_ENUM_VIDEO="Bearer not deactivated" TIME_TO_WAIT_VIDEO="100" FlowType="Default flow" FLOW_TAG="NONE" T_ACT_OFFSET_5GC="0" DEACT_FLAG_ENUM_5GC="Flow not deactivated" TIME_TO_WAIT_FLOW="100" FlowType_VIDEO="Default flow" FLOW_TAG_VIDEO="NONE" T_ACT_OFFSET_5GC_VIDEO="0" DEACT_FLAG_ENUM_5GC_VIDEO="Flow not deactivated" TIME_TO_WAIT_VIDEO_FLOW="100" APN="Default APN" NR_PDU_SESSION_ID="1" />
          <TemplateProfile name="IPCanRelease" instance="" Mandatory="false" SuccessPercentage="100.0" NR_PDU_SESSION_ID="1" APN="Default APN" PCO="" />
          <TemplateProfile name="GanDetach" instance="" Mandatory="false" SuccessPercentage="100.0" DETACH_SWOFF_IRAT="false" DETACH_SWOFF="false" DEREGISTRATION_SWOFF="false" />
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
  <AmmExternalLinkedFiles rclibexternallinkedfilename="CV327_mobility_scenarios_v2_test_BeamLisLen1_2LTECells.rclib" />
</TestScenario>
