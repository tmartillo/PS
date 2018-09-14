THIS IS THE SCRIPT
 

    #Get the start time for the email message.
 

$startTime = get-date
 

&C:\Program Files (x86)\VMware\VMware Converter\P2VTool.exe --import --source 

C:\job\nsbb.xml
 

    #Get the finish time for the email message.
 

$finishTime = get-date
 

Move-Item C:\ConverterTemp\NSBB\* C:\Converter\NSBB force
 

Remove-Item C:\ConverterTemp\NSBB
 

    #Set up the email parameters and send the email.
 
 

$emailFrom = "Tad@******.com"

$emailTo = "Tad@******.com"

$subject = "VM Migration Task Complete..."

$body = "Your VM Migration started at: $startTime
 

Your VM Migration completed at: $finishTime
 

Please log into the Virtual Infrastructure Client to remove

any unnecessary hardware and ensure that the newly migrated

VM is on the correct network."

$smtpServer = "********"

$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$smtp.Send($emailFrom, $emailTo, $subject, $body)
 

________________________________________________________________________

THIS IS THE XML CONFIG
 

<p2v uninstallAgentOnSuccess="0" version="2.2" xmlns="http://www.vmware.com/v2/sysimage/p2v" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.vmware.com/v2/sysimage/p2v p2vJob.xsd" xsi:type="P2VJob">

  <source>

    <liveSpec>

      <creds host="10.2.1.8" password="*****" port="0" username="NS\administrator"/>

    </liveSpec>

  </source>

  <dest>

    <hostedSpec path="\\10.2.1.6\ConverterTemp" password="******" username="NS\administrator" vmName="NSBB"/>

  </dest>

  <importParams clonePagefile="true" diskType="MONOLITHIC_SPARSE" keepIdentity="false" preallocateDisks="false" preserveDeviceBackingInfo="false" targetProductVersion="PRODUCT_WS_5X">

    <nicMappings preserveNicsInfo="false">

      <nicMapping network="Bridged"/>

    </nicMappings>

    <volumesToClone>

      <volumeCloneInfo newSize="12962482790" resize="true" volumeId="attVol={computer={8d56326b536472341b75b4f61b479869dbeb1967},1}"/>

    </volumesToClone>

  </importParams>

  <postProcessingParams installTools="false" powerOnVM="false">

    <reconfigParams/>

  </postProcessingParams>

  <jobState errorCode="0" id="8" startTime="2008-Oct-30 14:39:35" state="beingStopped" totalPercentComplete="18" type="import">

    <messages>

      <message id="Id_EstablishConnectionToAgent" type="Type_NewStep">

        <parameters>

          <parameter value="10.2.1.8"/>

        </parameters>

      </message>

      <message id="Id_CreateAndImport" type="Type_NewStep"/>

      <message id="Id_CreateConfigInfo" type="Type_Info"/>

      <message id="Id_CreateTargetVM" type="Type_Info"/>

      <message id="Id_FormatVolumeWithPath" type="Type_Info">

        <parameters>

          <parameter value="c:"/>

        </parameters>

      </message>

      <message id="Id_SnapshottingVolume" type="Type_Info"/>

      <message id="Id_CloningVolumeWithPath" type="Type_Info">

        <parameters>

          <parameter value="c:"/>

        </parameters>

      </message>

    </messages>

  </jobState>

</p2v>