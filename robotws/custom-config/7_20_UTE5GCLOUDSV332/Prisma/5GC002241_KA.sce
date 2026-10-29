<?xml version="1.0" encoding="UTF-8"?>
<!-- Scenario created in date 2021-07-16 16:06:00 by AirMosaicLTEUu 8.19.0RC20 (Build 202106180908)-->
<TestScenario Version="7" Repetitions="1" RepetitionsDelay="120000" Looped="false" DurationEnable="false" Annotation="" GlobalVariables="" LayoutLinkEnabled="true" CountersLayoutPath="" ChartsLayoutPath="" PesqLayoutPath="" AppVersion="AirMosaicLTEUu 8.19.0RC20 (Build 202106180908)" TstmName="LTE_Tm">
  <Bearer>
    <db name="Bearer" formatname="Bearer" version="1.0 1.0">
      <record name="Bearer 0" modifiable="true">
        <String name="instance" value="Bearer 0" />
        <Boolean name="Mandatory" value="false" />
        <Double name="SuccessPercentage" value="100.0" />
        <String name="QCI_MODE" value="Standard 3GPP QCI" />
        <String name="REQ_QCI" value="9" />
        <Integer name="OP_QCI" value="0" />
        <Object name="TFA" value="20" />
        <link name="REQ_MAX_BR_UL" value="Subscribed bitrate" />
        <link name="REQ_MAX_BR_DL" value="Subscribed bitrate" />
        <link name="REQ_GUAR_BR_UL" value="Subscribed bitrate" />
        <link name="REQ_GUAR_BR_DL" value="Subscribed bitrate" />
        <Object name="MOD_PROFILE" value="" />
        <Integer name="IDX_FOR_REORDER" value="-1" />
        <Boolean name="L1L2BearerEnable" value="true" />
        <Integer name="L1L2EPSBearerId" value="5" />
        <Integer name="T_ACT_OFFSET" value="0" />
        <String name="DEACT_FLAG_ENUM" value="UE triggered deactivation" />
      </record>
    </db>
  </Bearer>
  <Flow>
    <db name="Flow" formatname="Flow" version="1.0 1.0" />
  </Flow>
  <BearerModificationProfileList>
    <db name="Bearer 0" formatname="BearerModDb" version="1.0" />
    <looped name="Bearer 0" value="false" />
  </BearerModificationProfileList>
  <Groups>
    <Group name="Attach_Lte" extensible="true" enableGroup="true" loopenGroupRepetitions="false">
      "user 0001"
      <TemplateProfileMobility property="true" mobilityName="Advanced Mobility" radiocondition="RSRP_B1_Cell1_A3_Cell2_A5_Cell1_long" spatialDisplacement="Index" indexdisplacement="0" temporalDisplacement="Session Driven" Distribution="No Delay " SITCalculatedbyAMM="false" upondetach="true" name="com.prisma.mobility.mobilityplugin.MapDrivenMobility" cellbinding="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;RadioConditionCellBinding&gt;&#xA;    &lt;cellBindingMap&gt;&#xA;        &lt;entry&gt;&#xA;            &lt;key&gt;New Custom Lte Cell 2&lt;/key&gt;&#xA;            &lt;value&gt;10&lt;/value&gt;&#xA;        &lt;/entry&gt;&#xA;    &lt;/cellBindingMap&gt;&#xA;    &lt;autoCellBinding&gt;false&lt;/autoCellBinding&gt;&#xA;&lt;/RadioConditionCellBinding&gt;&#xA;" nrcellbinding="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;RadioConditionNrCellBinding&gt;&#xA;    &lt;nrCellBindingMap&gt;&#xA;        &lt;entry&gt;&#xA;            &lt;key&gt;New Custom 5GNr Cell 0&lt;/key&gt;&#xA;            &lt;value&gt;1&lt;/value&gt;&#xA;        &lt;/entry&gt;&#xA;        &lt;entry&gt;&#xA;            &lt;key&gt;New Custom 5GNr Cell 1&lt;/key&gt;&#xA;            &lt;value&gt;2&lt;/value&gt;&#xA;        &lt;/entry&gt;&#xA;    &lt;/nrCellBindingMap&gt;&#xA;&lt;/RadioConditionNrCellBinding&gt;&#xA;" overrideoptions="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;OverrideOptions&gt;&#xA;    &lt;DEFAULT_OVERRIDE_OPTION&gt;Earfcn Attached&lt;/DEFAULT_OVERRIDE_OPTION&gt;&#xA;    &lt;initialCellAttached&gt;default&lt;/initialCellAttached&gt;&#xA;    &lt;earfcnAttached&gt;100&lt;/earfcnAttached&gt;&#xA;    &lt;overrideOptionSelected&gt;EARFCN_ATTACHED&lt;/overrideOptionSelected&gt;&#xA;&lt;/OverrideOptions&gt;&#xA;" />
    </Group>
  </Groups>
  <SessionList>
    <Session name="New session 1" ACCESS_NETWORK="LTE" InterarrivalTime="240000" RandomRate="false" Repetitions="1" SessionRepetitionsMode="Repetitions" groupRate="1000" groupRep="1" groupBlockLoop="false" groupMode="Variable Rate" SessionMode="Normal" SchedulingKind="Timer Triggered" StartSession="0010Attach_Lte0013New session 100000000000100000" loop="false" Group="Attach_Lte">
      <TestTraceManager masterTraceLength="6" traces="1">
        <TestTrace>
          <TemplateProfile name="Attach" instance="" Mandatory="false" SuccessPercentage="100.0" />
          <TemplateProfile name="Delay" instance="" Mandatory="true" SuccessPercentage="100.0" DELAY="1000" />
          <TemplateProfile name="IP Passthrough start" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" BEARER_TAG="NONE" T_ACT_OFFSET="0" DEACT_FLAG_ENUM="Bearer not deactivated" TIME_TO_WAIT="100" BearerType_VIDEO="Default bearer" BEARER_TAG_VIDEO="NONE" T_ACT_OFFSET_VIDEO="0" DEACT_FLAG_ENUM_VIDEO="Bearer not deactivated" TIME_TO_WAIT_VIDEO="100" FlowType="Default flow" FLOW_TAG="NONE" T_ACT_OFFSET_5GC="0" DEACT_FLAG_ENUM_5GC="Flow not deactivated" TIME_TO_WAIT_FLOW="100" FlowType_VIDEO="Default flow" FLOW_TAG_VIDEO="NONE" T_ACT_OFFSET_5GC_VIDEO="0" DEACT_FLAG_ENUM_5GC_VIDEO="Flow not deactivated" TIME_TO_WAIT_VIDEO_FLOW="100" APN="Default APN" NR_PDU_SESSION_ID="1" APC_IP=";user 0001:192.168.203.10" APC_IP_NETMASK="" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="200000" />
          <TemplateProfile name="IP Passthrough stop" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" BEARER_TAG="NONE" T_ACT_OFFSET="0" DEACT_FLAG_ENUM="Bearer not deactivated" TIME_TO_WAIT="100" BearerType_VIDEO="Default bearer" BEARER_TAG_VIDEO="NONE" T_ACT_OFFSET_VIDEO="0" DEACT_FLAG_ENUM_VIDEO="Bearer not deactivated" TIME_TO_WAIT_VIDEO="100" FlowType="Default flow" FLOW_TAG="NONE" T_ACT_OFFSET_5GC="0" DEACT_FLAG_ENUM_5GC="Flow not deactivated" TIME_TO_WAIT_FLOW="100" FlowType_VIDEO="Default flow" FLOW_TAG_VIDEO="NONE" T_ACT_OFFSET_5GC_VIDEO="0" DEACT_FLAG_ENUM_5GC_VIDEO="Flow not deactivated" TIME_TO_WAIT_VIDEO_FLOW="100" APN="Default APN" NR_PDU_SESSION_ID="1" />
          <TemplateProfile name="Detach" instance="" Mandatory="false" SuccessPercentage="100.0" DETACH_SWOFF_IRAT="false" DETACH_SWOFF="false" DEREGISTRATION_SWOFF="false" />
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
  <AmmExternalLinkedFiles rclibexternallinkedfilename="CV332_Auto_josferna.rclib" />
</TestScenario>

