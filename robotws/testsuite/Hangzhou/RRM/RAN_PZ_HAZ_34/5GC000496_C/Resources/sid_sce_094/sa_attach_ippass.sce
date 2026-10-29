<?xml version="1.0" encoding="UTF-8"?>
<!-- Scenario created in date 2019-01-18 10:23:18 by AirMosaic LTE Uu 7.5.0RC10 (Build 201812180944)-->
<TestScenario Version="7" Repetitions="1" RepetitionsDelay="1000" Looped="false" DurationEnable="false" DetachShutdown="false" Annotation="" GlobalVariables="" cellbinding="" AppVersion="AirMosaic LTE Uu 7.5.0RC10 (Build 201812180944)" TstmName="LTE_Tm">
  <Bearer>
    <db name="Bearer" formatname="Bearer" version="1.0 1.0" />
  </Bearer>
  <Groups>
    <Group name="1" extensible="true" enableGroup="true" loopenGroupRepetitions="false" groupRepetitionsNumber="1">
      "user 001"
      <TemplateProfileMobility name="Mobility.FixedPosition" Cell="1" RadioCondition="NOHO%normal%1000,15,0,15,0,1,2,Disabled,0.0,0.0,0.0,None,Disabled,0.0,0.0,No Fading,Not Applicable" ForcedRRCConnReestProc="None">
        <LoopedMode enable="false" />
        <SpeedModeEditable enable="false" />
        <db name="BRCDb" formatname="BRCDb" version="1.0">
          <record name="0" modifiable="true">
            <String name="Timestamp" value="1000" />
            <String name="WB_CQI_CW1" value="15" />
            <String name="SB_CQI_CW1" value="0" />
            <String name="WB_CQI_CW2" value="15" />
            <String name="SB_CQI_CW2" value="0" />
            <Integer name="PMI" value="1" />
            <String name="RI" value="2" />
            <String name="Pathloss" value="Disabled" />
            <Double name="UL_BLER_Coeff" value="0.0" />
            <Double name="DL_BLER_CoeffTxDiv" value="0.0" />
            <Double name="DL_BLER_CoeffMIMO" value="0.0" />
            <String name="NormPowHeadr" value="None" />
            <String name="AWGN" value="Disabled" />
            <Double name="RadialSpeed" value="0.0" />
            <Double name="Position" value="0.0" />
            <link name="FadingProfileIndex" value="No Fading" />
            <String name="RadioOff" value="Not Applicable" />
          </record>
        </db>
      </TemplateProfileMobility>
    </Group>
  </Groups>
  <SessionList>
    <Session name="New session 8" InterarrivalTime="1000" RandomRate="false" Repetitions="1" groupRate="10000" groupRep="1" groupBlockLoop="false" groupMode="Variable Rate" SessionMode="Normal" SchedulingKind="Timer Triggered" StartSession="000110013New session 800000000000100000" loop="false" Group="1">
      <TestTraceManager masterTraceLength="10" traces="1">
        <TestTrace>
          <TemplateProfile name="Attach" instance="" Mandatory="false" SuccessPercentage="100.0" />
          <TemplateProfile name="PDN Connection Activation" instance="" Mandatory="false" SuccessPercentage="100.0" REQUEST_TYPE="InitialRequest" PDN_TYPE="IPv4" ESM_INFO_TRANSFER_FLAG="false" APN="nn2" PCO="" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="2000" />
          <TemplateProfile name="IP Passthrough start" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" TIME_TO_WAIT_VIDEO="100" APN="nn2" APC_IP=";user 001:192.168.60.2" APC_IP_NETMASK="255.255.255.0" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="2147483647" />
          <TemplateProfile name="IP Passthrough stop" instance="" Mandatory="false" SuccessPercentage="100.0" BEARER_TAG="NONE" />
          <TemplateProfile name="FTP Session" instance="" Mandatory="false" SuccessPercentage="100.0" BearerType="Default bearer" TIME_TO_WAIT_VIDEO="100" APN="5gcn" Operation="Download" User="user" Password="user" Hostname="10.9.34.12" RemotePath="test" WriteDownload="false" URL_DEL="0" FTP_MODE="false" TEST_TIMEOUT="0" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="2147483647" />
          <TemplateProfile name="Delay" instance="" Mandatory="false" SuccessPercentage="100.0" DELAY="600000000" />
          <TemplateProfile name="Detach" instance="" Mandatory="false" SuccessPercentage="100.0" DETACH_SWOFF="true" />
        </TestTrace>
      </TestTraceManager>
    </Session>
  </SessionList>
  <globals />
  <SmartphoneSimulator userLibraryFilename="" />
  <cell_list />
  <func_low_list />
</TestScenario>

