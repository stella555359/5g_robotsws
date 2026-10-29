<?xml version="1.0" encoding="UTF-8"?>
<!-- Scenario created in date 2019-09-17 16:41:01 by AirMosaic LTE Uu 7.8.0RC10 (Build 201906191602)-->
<TestScenario Version="7" Repetitions="1" RepetitionsDelay="1000" Looped="false" DurationEnable="false" DetachShutdown="false" Annotation="" GlobalVariables="" AppVersion="AirMosaic LTE Uu 7.8.0RC10 (Build 201906191602)" TstmName="LTE_Tm">
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
    <Group name="Group1" extensible="true" enableGroup="true" loopenGroupRepetitions="false">
      "user 001","user 002","user 003","user 004"
      <TemplateProfileMobility mobilityName="Advanced Mobility" radiocondition="New Mobility Environment 0" spatialDisplacement="Round Robin" temporalDisplacement="Scenario Driven" Distribution="No Delay " upondetach="false" name="com.prisma.mobility.mobilityplugin.MapDrivenMobility" cellbinding="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;RadioConditionCellBinding&gt;&#xA;    &lt;cellBindingMap&gt;&#xA;        &lt;entry&gt;&#xA;            &lt;key&gt;New Custom Lte Cell 1&lt;/key&gt;&#xA;            &lt;value&gt;2&lt;/value&gt;&#xA;        &lt;/entry&gt;&#xA;    &lt;/cellBindingMap&gt;&#xA;    &lt;autoCellBinding&gt;false&lt;/autoCellBinding&gt;&#xA;&lt;/RadioConditionCellBinding&gt;&#xA;" nrcellbinding="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;RadioConditionNrCellBinding&gt;&#xA;    &lt;nrCellBindingMap&gt;&#xA;        &lt;entry&gt;&#xA;            &lt;key&gt;New Custom 5GNr Cell 0&lt;/key&gt;&#xA;            &lt;value&gt;1&lt;/value&gt;&#xA;        &lt;/entry&gt;&#xA;    &lt;/nrCellBindingMap&gt;&#xA;&lt;/RadioConditionNrCellBinding&gt;&#xA;" overrideoptions="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;OverrideOptions&gt;&#xA;    &lt;DEFAULT_OVERRIDE_OPTION&gt;Earfcn Attached&lt;/DEFAULT_OVERRIDE_OPTION&gt;&#xA;    &lt;initialCellAttached&gt;default&lt;/initialCellAttached&gt;&#xA;    &lt;earfcnAttached&gt;100&lt;/earfcnAttached&gt;&#xA;    &lt;overrideOptionSelected&gt;EARFCN_ATTACHED&lt;/overrideOptionSelected&gt;&#xA;&lt;/OverrideOptions&gt;&#xA;" />
    </Group>
  </Groups>
  <SessionList>
    <Session name="New session 1" ACCESS_NETWORK="LTE" InterarrivalTime="12000" RandomRate="true" Repetitions="4" groupRate="1000" groupRep="1" groupBlockLoop="false" groupMode="Variable Rate" SessionMode="Normal" SchedulingKind="Timer Triggered" StartSession="0006Group10013New session 100000000000100000" loop="false" Group="Group1">
      <TestTraceManager masterTraceLength="6" traces="1">
        <TestTrace>
          <TemplateProfile name="Attach" instance="" Mandatory="false" SuccessPercentage="100.0" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="1000" />
          <TemplateProfile name="IP Passthrough start" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" TIME_TO_WAIT_VIDEO="100" APN="Default APN" FlowType="Default flow" APC_IP=";user 001:192.168.60.2,user 002:192.168.60.3,user 003:192.168.60.4,user 004:192.168.60.5" APC_IP_NETMASK="255.255.255.0" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="720000000" />
          <TemplateProfile name="IP Passthrough stop" instance="" Mandatory="false" SuccessPercentage="100.0" BEARER_TAG="NONE" FLOW_TAG="NONE" />
          <TemplateProfile name="Detach" instance="" Mandatory="false" SuccessPercentage="100.0" DETACH_SWOFF="false" />
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
  <AmmExternalLinkedFiles rclibexternallinkedfilename="AMM-160ms.rclib" />
</TestScenario>

