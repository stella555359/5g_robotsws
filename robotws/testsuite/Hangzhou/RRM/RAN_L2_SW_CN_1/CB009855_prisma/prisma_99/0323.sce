<?xml version="1.0" encoding="UTF-8"?>
<!-- Scenario created in date 2023-06-29 05:02:39 by AirMosaic 8.23.6-31 (Build 202304190825)-->
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
    <Group name="nonCA" extensible="true" enableGroup="true" loopenGroupRepetitions="false" groupRepetitionsNumber="1">
      "user 001","user 002","user 003","user 004","user 005","user 006","user 007","user 008","user 009","user 010","user 011","user 012","user 013","user 014","user 015","user 016","user 017","user 018","user 019","user 020","user 021","user 022","user 023","user 024","user 025","user 026","user 027","user 028","user 029","user 030","user 031","user 032","user 033","user 034","user 035","user 036","user 037","user 038","user 039","user 040"
      <TemplateProfileMobility property="true" mobilityName="Advanced Mobility" radiocondition="New Mobility Environment 0" spatialDisplacement="Index" indexdisplacement="0" temporalDisplacement="Scenario Driven" Distribution="No Delay " upondetach="false" name="com.prisma.mobility.mobilityplugin.MapDrivenMobility" cellbinding="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;RadioConditionCellBinding&gt;&#xA;    &lt;cellBindingMap/&gt;&#xA;    &lt;autoCellBinding&gt;false&lt;/autoCellBinding&gt;&#xA;&lt;/RadioConditionCellBinding&gt;&#xA;" nrcellbinding="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;RadioConditionNrCellBinding&gt;&#xA;    &lt;nrCellBindingMap&gt;&#xA;        &lt;entry&gt;&#xA;            &lt;key&gt;New Custom 5GNr Cell 8&lt;/key&gt;&#xA;            &lt;value&gt;1&lt;/value&gt;&#xA;        &lt;/entry&gt;&#xA;    &lt;/nrCellBindingMap&gt;&#xA;&lt;/RadioConditionNrCellBinding&gt;&#xA;" overrideoptions="&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;yes&quot;?&gt;&#xA;&lt;OverrideOptions&gt;&#xA;    &lt;DEFAULT_OVERRIDE_OPTION&gt;None&lt;/DEFAULT_OVERRIDE_OPTION&gt;&#xA;    &lt;initialCellAttached&gt;1&lt;/initialCellAttached&gt;&#xA;    &lt;earfcnAttached&gt;100&lt;/earfcnAttached&gt;&#xA;    &lt;overrideOptionSelected&gt;INITIAL_CELL_ATTACHED&lt;/overrideOptionSelected&gt;&#xA;&lt;/OverrideOptions&gt;&#xA;" />
    </Group>
  </Groups>
  <SessionList>
    <Session name="New session 15" ACCESS_NETWORK="NR" InterarrivalTime="1000" RandomRate="false" Repetitions="1" SessionRepetitionsMode="Repetitions" groupRate="1000" groupRep="1" groupBlockLoop="false" groupMode="Variable Rate" SessionMode="Normal" SchedulingKind="Timer Triggered" StartSession="0005FDDCA0014New session 1500000000000100000" loop="false" Group="nonCA">
      <TestTraceManager masterTraceLength="8" traces="1">
        <TestTrace>
          <TemplateProfile name="Registration" instance="" Mandatory="false" SuccessPercentage="100.0" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="3000" />
          <TemplateProfile name="PDU Session Establish" instance="" Mandatory="false" SuccessPercentage="100.0" NR_PDU_SESSION_ID="1" MAX_DATA_RATE_UP_INT_PROT_UL="Full data rate" MAX_DATA_RATE_UP_INT_PROT_DL="Full data rate" IPCAN_TYPE="IPv4" NR_PDU_SESSION_SSC3_ID="" ALWAYS_ON_PDU_SESSION="(Default) Not Present" PDU_TYPE="IPv4" NRSM_INFO_TRANSFER_FLAG="false" NR_S_NSSAI="1-d143a5-?-?" IPCAN_NR_S_NSSAI="" NR_SSC_MODE="Not Present" APN="wap2.nokia.com" PCO="" SM_INFO_TRANSFER_FLAG="false" REQUEST_TYPE="InitialRequest" EAP_IDENTITY="" EAP_ALGORITHM="MD5" EAP_USERNAME="" EAP_PASSWORD="" DN_SPEC_ID_IN_CONTAINER="false" PDN_TYPE="IPv4" ESM_INFO_TRANSFER_FLAG="false" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="3000" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="10000000" />
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

