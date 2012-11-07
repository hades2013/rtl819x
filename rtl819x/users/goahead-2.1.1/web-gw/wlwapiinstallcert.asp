<html>
<! Copyright (c) Realtek Semiconductor Corp., 2003. All Rights Reserved. ->
<head>
<meta http-equiv="Content-Type" content="text/html">
<title>WAPI Certification Installation</title>
<style>
.on {display:on}
.off {display:none}
</style>
<script type="text/javascript" src="util_gw.js"></script>
<script>
var MWJ_progBar = 0;
var time=0;
var delay_time=1000;
var loop_num=0;

function progress()
{
  if (loop_num == 3) {
	alert("Update firmware failed!");
	return false;
  }
  if (time < 1) 
	time = time + 0.033;
  else {
	time = 0;
	loop_num++;
  }
  setTimeout('progress()',delay_time);  
  myProgBar.setBar(time); 
}


function sendClicked(F)
{
  if(document.uploadCert.asu_binary.value == "" && document.uploadCert==F){
      	document.uploadCert.asu_binary.focus();
  	alert('File name can not be empty !');
  	return false;
  }

  if(document.uploadUserCert.user_binary.value == "" && document.uploadUserCert==F){
      	document.uploadUserCert.user_binary.focus();
  	alert('File name can not be empty !');
  	return false;
  }
	
  F.submit();
  show_div(true, "progress_div");   
  progress();
}

</script>

</head>
<BODY>
<blockquote>
<h2><font color="#0000FF">Certification Installation</font></h2>

<table border="0" cellspacing="4" width="500">
 <tr><font size=2>
  This page allows you to install ASU and user certification for our AP. Please note, certification type 
 X.509 is supported at present.
 </tr>
</table>

 <!-- Only for Remote AS0 -->
 <form method="post" action="/goform/formUploadWapiCertAS0" enctype="multipart/form-data" name="uploadCertAS0">
<table border="0" cellspacing="0" width="500">
 <tr><font size=2></tr>
  <tr><hr size=1 noshade align=top></tr>
  <tr>
  <td width="55%"><font size=2><b>Certificate Type of Remote AS0:</b></td>
  <td width="45%"><font size=2> <input name="cert_type" type=radio value=0 checked>X.509</td>
  </tr>
  <tr>
      <td width="55%"><font size=2><b>ASU Certificate from Remote AS0:</b></td>
      <td width="45%"><font size=2><input type="file" name="asu_binary" size=20></td>
  </tr>
  </table> 
	<input onclick=sendClicked(this.form) type=button value="Upload" name="send">&nbsp;&nbsp;    
	<input type="reset" value="Reset" name="reset">
	<input type="hidden" value="/wlwapiinstallcert.asp" name="submit-url">
	<input type="hidden" value="asu" name="uploadcerttype">
 </form>

<form method="post" action="/goform/formUploadWapiCertAS0" enctype="multipart/form-data" name="uploadUserCertAS0">
<table border="0" cellspacing="0" width="500">
 <tr><font size=2></tr>
  <tr>
      <td width="55%"><font size=2><b>User Certificate from Remote AS0:</b></td>
      <td width="45%"><font size=2><input type="file" name="user_binary" size=20></td>
  </tr>
  </table>
	<input onclick=sendClicked(this.form) type=button value="Upload" name="send">&nbsp;&nbsp;
	<input type="reset" value="Reset" name="reset">
	<input type="hidden" value="/wlwapiinstallcert.asp" name="submit-url">
	<input type="hidden" value="user" name="uploadcerttype">
 </form>


 <!-- Only for Remote AS1 -->
 <form method="post" action="/goform/formUploadWapiCertAS1" enctype="multipart/form-data" name="uploadCertAS1">
<table border="0" cellspacing="0" width="500">
 <tr><font size=2></tr>
  <tr><hr size=1 noshade align=top></tr>
  <tr>
  <td width="55%"><font size=2><b>Certificate Type of Remote AS1:</b></td>
  <td width="45%"><font size=2> <input name="cert_type" type=radio value=0 checked>X.509</td>
  </tr>
  <tr>
      <td width="55%"><font size=2><b>ASU Certificate from Remote AS1:</b></td>
      <td width="45%"><font size=2><input type="file" name="asu_binary" size=20></td>
  </tr>
  </table> 
	<input onclick=sendClicked(this.form) type=button value="Upload" name="send">&nbsp;&nbsp;    
	<input type="reset" value="Reset" name="reset">
	<input type="hidden" value="/wlwapiinstallcert.asp" name="submit-url">
	<input type="hidden" value="asu" name="uploadcerttype">
 </form>

<form method="post" action="/goform/formUploadWapiCertAS1" enctype="multipart/form-data" name="uploadUserCertAS1">
<table border="0" cellspacing="0" width="500">
 <tr><font size=2></tr>
  <tr>
      <td width="55%"><font size=2><b>User Certificate from Remote AS1:</b></td>
      <td width="45%"><font size=2><input type="file" name="user_binary" size=20></td>
  </tr>
  </table>
	<input onclick=sendClicked(this.form) type=button value="Upload" name="send">&nbsp;&nbsp;
	<input type="reset" value="Reset" name="reset">
	<input type="hidden" value="/wlwapiinstallcert.asp" name="submit-url">
	<input type="hidden" value="user" name="uploadcerttype">
 </form>

<!-- Only for Local AS -->
<% getInfo("wapiLocalAsCertsUploadForm");%>
 
 <script type="text/javascript" language="javascript1.2">
		var myProgBar = new progressBar(
			1,         //border thickness
			'#000000', //border colour
			'#ffffff', //background colour
			'#043db2', //bar colour
			300,       //width of bar (excluding border)
			15,        //height of bar (excluding border)
			1          //direction of progress: 1 = right, 2 = down, 3 = left, 4 = up
		);
</script>
 
 
 </blockquote>
</body>
</html>
