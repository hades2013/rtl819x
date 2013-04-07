<html>
<! Copyright (c) Realtek Semiconductor Corp., 2003. All Rights Reserved. ->
<head>
<meta http-equiv="Content-Type" content="text/html">
<title>QoS</title>
<script type="text/javascript" src="util_gw.js"> </script>
<script type="text/javascript" src="util_qos.js"> </script>

<script>

function checkClientRange(start,end)
{
  var start_d, end_d;
  start_d = getDigit(start,4);
  start_d += getDigit(start,3)*256;
  start_d += getDigit(start,2)*256;
  start_d += getDigit(start,1)*256;

  end_d = getDigit(end,4);
  end_d += getDigit(end,3)*256;
  end_d += getDigit(end,2)*256;
  end_d += getDigit(end,1)*256;

  if ( start_d <= end_d )
	return true;

  return false;
}

function addRuleClick()
{
  if (!document.formQosAdd.enabled.checked)
  	return true;

  if (!document.formQosAdd.automaticUplinkSpeed.checked && (document.formQosAdd.manualUplinkSpeed.value=="" || document.formQosAdd.manualUplinkSpeed.value < 100)) {
	alert("Manual Uplink Speed cannot be empty or less then 100 when Automatic Uplink Speed is disabled.");
	document.formQosAdd.manualUplinkSpeed.focus();
	return false;
  }
  
  if (!document.formQosAdd.automaticDownlinkSpeed.checked && (document.formQosAdd.manualDownlinkSpeed.value=="" || document.formQosAdd.manualDownlinkSpeed.value<100)) {
	alert("Manual Downlink Speed cannot be empty or less then 100 when Automatic Downlink Speed is disabled.");
	document.formQosAdd.manualDownlinkSpeed.focus();
	return false;
  }


  if (document.formQosAdd.ipStart.value=="" && document.formQosAdd.ipEnd.value=="" &&
  	document.formQosAdd.mac.value=="" &&
	document.formQosAdd.bandwidth.value=="" && document.formQosAdd.bandwidth_downlink.value=="" && 
		document.formQosAdd.comment.value=="")
	return true;

  if (document.formQosAdd.addressType[0].checked==true) {
    
	if ( checkIpAddr(document.formQosAdd.ipStart, 'Invalid IP address') == false )
	    return false;
	if ( checkIpAddr(document.formQosAdd.ipEnd, 'Invalid IP address') == false )
	    return false;

        if ( !checkClientRange(document.formQosAdd.ipStart.value,document.formQosAdd.ipEnd.value) ) {
		alert('Invalid IP address range!\nEnding address should be greater than starting address.');
		document.formQosAdd.ipStart.focus();
		return false;
        }

	var LAN_IP = ipv4_to_unsigned_integer("<% getInfo("ip"); %>");
	var LAN_MASK = ipv4_to_unsigned_integer("<% getInfo("mask"); %>");			

	var tarIp = ipv4_to_unsigned_integer(document.formQosAdd.ipStart.value);

	if ((tarIp & LAN_MASK) != (LAN_IP & LAN_MASK))
	{
		alert("Invalid start IP address! It should be set within the current subnet.");
		return false;
	}
	tarIp = ipv4_to_unsigned_integer(document.formQosAdd.ipEnd.value);

	if ((tarIp & LAN_MASK) != (LAN_IP & LAN_MASK))
	{
		alert("Invalid end IP address! It should be set within the current subnet.");
		return false;
	}
		
  }
  else {
	  var str = document.formQosAdd.mac.value;
	  if ( str.length < 12) {
		alert("Input MAC address is not complete. It should be 12 digits in hex.");
		document.formQosAdd.mac.focus();
		return false;
	  }

	  for (var i=0; i<str.length; i++) {
	    if ( (str.charAt(i) >= '0' && str.charAt(i) <= '9') ||
			(str.charAt(i) >= 'a' && str.charAt(i) <= 'f') ||
			(str.charAt(i) >= 'A' && str.charAt(i) <= 'F') )
			continue;

		alert("Invalid MAC address. It should be in hex number (0-9 or a-f).");
		document.formQosAdd.mac.focus();
		return false;
	  }
  }
  if ( (document.formQosAdd.bandwidth.value == "" || document.formQosAdd.bandwidth.value == 0)
   	&& (document.formQosAdd.bandwidth_downlink.value == "" || document.formQosAdd.bandwidth_downlink.value == 0) ) {
	alert("Uplink Bandwidth or Downlink Bandwidth cannot be empty.");
	document.formQosAdd.bandwidth.focus();
	return false;
  }
  
  if (document.formQosAdd.bandwidth.value!="") {
  	if ( validateKey( document.formQosAdd.bandwidth.value ) == 0 ) {
		alert("Invalid input! It should be the decimal number (0-9).");
		document.formQosAdd.bandwidth.focus();
		return false;
  	}
   }
   
   if (document.formQosAdd.bandwidth_downlink.value!="") {
  	if ( validateKey( document.formQosAdd.bandwidth_downlink.value ) == 0 ) {
		alert("Invalid input! It should be the decimal number (0-9).");
		document.formQosAdd.bandwidth_downlink.focus();
		return false;
  	}
   }
   return true;
}

function deleteClick()
{
  if ( !confirm('Do you really want to delete the selected entry?') ) {
	return false;
  }
  else
	return true;
}

function deleteAllClick()
{
   if ( !confirm('Do you really want to delete the all entries?') ) {
	return false;
  }
  else
	return true;
}

function disableQosDelButton()
{
	disableButton(document.formQosDel.deleteSel);
	disableButton(document.formQosDel.deleteAll);
}

function ipAddrClicked()
{
 	enableTextField(document.formQosAdd.ipStart);
 	enableTextField(document.formQosAdd.ipEnd);
	disableTextField(document.formQosAdd.mac);
}

function macAddrClicked()
{
 	disableTextField(document.formQosAdd.ipStart);
 	disableTextField(document.formQosAdd.ipEnd);
	enableTextField(document.formQosAdd.mac);
}
	
function updateQosState()
{
  if (document.formQosAdd.enabled.checked) {  	
 	enableTextField(document.formQosAdd.automaticUplinkSpeed);
 	enableTextField(document.formQosAdd.automaticDownlinkSpeed);
 	enableTextField(document.formQosAdd.addressType[0]);
 	enableTextField(document.formQosAdd.addressType[1]);
	enableTextField(document.formQosAdd.mode);
	enableTextField(document.formQosAdd.bandwidth);
	enableTextField(document.formQosAdd.bandwidth_downlink);
	enableTextField(document.formQosAdd.comment);
	
	updateLinkState();
	
	if (document.formQosAdd.addressType[0].checked==true)
		ipAddrClicked();
	else
		macAddrClicked();
  }
  else {
 	disableTextField(document.formQosAdd.automaticUplinkSpeed);
 	disableTextField(document.formQosAdd.automaticDownlinkSpeed);
 	disableTextField(document.formQosAdd.manualUplinkSpeed);
 	disableTextField(document.formQosAdd.manualDownlinkSpeed);
 	disableTextField(document.formQosAdd.addressType[0]);
 	disableTextField(document.formQosAdd.addressType[1]);
 	disableTextField(document.formQosAdd.ipStart);
 	disableTextField(document.formQosAdd.ipEnd);
	disableTextField(document.formQosAdd.mac);
	disableTextField(document.formQosAdd.mode);
	disableTextField(document.formQosAdd.bandwidth);
	disableTextField(document.formQosAdd.bandwidth_downlink);
	disableTextField(document.formQosAdd.comment);
  }
}

function updateLinkState()
{
  if (document.formQosAdd.automaticUplinkSpeed.checked) {  	
 	disableTextField(document.formQosAdd.manualUplinkSpeed);
  }
  else {
 	enableTextField(document.formQosAdd.manualUplinkSpeed);
  }
  
  if (document.formQosAdd.automaticDownlinkSpeed.checked) {  	
 	disableTextField(document.formQosAdd.manualDownlinkSpeed);
  }
  else {
 	enableTextField(document.formQosAdd.manualDownlinkSpeed);
  }
}

</script>
</head>

<body>
<blockquote>
<h2><font color="#0000FF">QoS</font></h2>

<table border=0 width="550" cellspacing=4 cellpadding=0>
<tr><td><font size=2>
 Entries in this table improve your online gaming experience by ensuring that your 
 game traffic is prioritized over other network traffic, such as FTP or Web. 
</font></td></tr>


<table border=0 width=500>
  <tr><td><hr size=1 noshade align=top></td></tr>

<form action=/goform/formIpQoS method=POST name="formQosAdd">
<input type="hidden" value="/ip_qos.asp" name="submit-url">
<tr><td><font size=2><b>
   	<input type="checkbox" name="enabled" value="ON" <% if (getIndex("qosEnabled")) write("checked");%> ONCLICK=updateQosState()>&nbsp;&nbsp;Enable QoS</b><br>
 </td></tr>

<tr><td><font size=2><b>
   	<input type="checkbox" name="automaticUplinkSpeed" value="ON" <% if (getIndex("qosAutoUplinkSpeed")) write("checked");%> ONCLICK=updateLinkState()>&nbsp;&nbsp;Automatic Uplink Speed</b><br>
 </td></tr>

<tr><td><font size=2><b>
	<b>Manual Uplink Speed (Kbps):</b> <input type="text" name="manualUplinkSpeed" size="8" maxlength="8" value="<% getInfo("qosManualUplinkSpeed"); %>">
	<br><br>
</td></tr>

<tr><td><font size=2><b>
   	<input type="checkbox" name="automaticDownlinkSpeed" value="ON" <% getIndex("qosAutoDownlinkSpeed");%> ONCLICK=updateLinkState()>&nbsp;&nbsp;Automatic Downlink Speed</b><br>
 </td></tr>

<tr><td><font size=2><b>
	<b>Manual Downlink Speed (Kbps):</b> <input type="text" name="manualDownlinkSpeed" size="8" maxlength="8" value="<% getInfo("qosManualDownlinkSpeed"); %>">
	<br><br><br>
</td></tr>

</table>

<table border=0 width=500>

	<tr>
      <td width="45%"><font size=2><font color="#0000FF"><b>QoS Rule Setting:</b></font></font></td>
      <td>&nbsp;</td>
  </tr>

	<tr>
		<td width="45%"><font size=2><b>Address Type:</b></font></td>
		<td>
      <input type="radio" name="addressType" value="0" checked ONCLICK=ipAddrClicked()>IP&nbsp;&nbsp;
      <input type="radio" name="addressType" value="1" ONCLICK=macAddrClicked()>MAC<br>
		</td>
	</tr>

	<tr>
		<td width="45%"><font size=2><b>Local IP Address:</b></font></td>
		<td>
			<input type="text" name="ipStart" size="12" maxlength="15" value="">
      <font face="Arial" size="5">-</font>
      <input type="text" name="ipEnd" size="12" maxlength="15" value="">
    </td>
  </tr>

  <tr>
		<td width="45%"><font size=2><b>MAC Address:</b></font></td>
		<td><input type="text" name="mac" size="12" maxlength="12"></td>
	</tr>
    
	<tr>
		<td width="45%"><font size=2><b>Mode:</b></font></td>
		<td>
			<select size="1" name="mode">
      <option selected value="1">Guaranteed minimum bandwidth</option>
      	<option value="2">Restricted maximum bandwidth</option>
      </select>
    </td>
  </tr>
  
  <tr>
		<td width="45%"><font size=2><b>Uplink Bandwidth (Kbps):</b></font></td>
		<td><input type="text" name="bandwidth" size="8"></td>
	</tr>
	
	<tr>
		<td width="45%"><font size=2><b>Downlink Bandwidth (Kbps):</b></font></td>
		<td><input type="text" name="bandwidth_downlink" size="8"></td>
	</tr>
	
	<tr>
		<td width="45%"><font size=2><b>Comment:</b></font></td>
		<td><input type="text" name="comment" size="10" maxlength="15"></td>
	</tr>
</table>

<table border=0 width=100>
	<tr>
		<td><input type="submit" value="Apply Changes" name="addQos" onClick="return addRuleClick()">&nbsp;&nbsp;</td>
    <td><input type="reset" value="Reset" name="reset"></td>
  </tr>

  <script> updateQosState(); </script>
</form>
</table>


<br>
<form action=/goform/formIpQoS method=POST name="formQosDel">
<table border=0 width=500>
  <tr><font size=2><b>Current QoS Rules Table:</b></font></tr>
  <% ipQosList(); %>
</table>

 <br><input type="submit" value="Delete Selected" name="deleteSel" onClick="return deleteClick()">&nbsp;&nbsp;
     <input type="submit" value="Delete All" name="deleteAll" onClick="return deleteAllClick()">&nbsp;&nbsp;&nbsp;
     <input type="reset" value="Reset" name="reset">
 <script>
   	<% entryNum = getIndex("qosRuleNum");
   	  if ( entryNum == 0 ) {
      	  	write( "disableQosDelButton();" );
       	  } %>
 </script>
     <input type="hidden" value="/ip_qos.asp" name="submit-url">
</form>


</blockquote>
</body>
</html>
