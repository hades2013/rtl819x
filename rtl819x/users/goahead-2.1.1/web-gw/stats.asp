<html>
<! Copyright (c) Realtek Semiconductor Corp., 2003. All Rights Reserved. ->
<head>
<meta http-equiv="Content-Type" content="text/html">
<title>Statisitcs</title>
</head>
<body>
<blockquote>
<h2><font color="#0000FF">Statistics</font></h2>

<table border=0 width="500" cellpadding=0>
  <tr><font size=2>
 This page shows the packet counters for transmission and reception regarding to wireless
 and Ethernet networks.
  </tr>
  <tr><hr size=1 noshade align=top></tr>
</table>
<form action=/goform/formStats method=POST name="formStats">
<table border="1" width="360">
  <script>
	var wlan_num = <% write(getIndex("wlan_num")); %>;
	var wlanMode = <% write(getIndex("wlanMode")); %>;
	var ssid_drv=new Array();
  	var tx_pkt_num =new Array();
  	var rx_pkt_num =new Array();
  	var rp_enabled=new Array();
	var rp_tx_pkt_num =new Array();
  	var rp_rx_pkt_num =new Array();  	
	var mssid_num=<%write(getIndex("wlan_mssid_num"));%>;
	var mssid_disable=new Array();
	var mssid_tx_pkt_num=new Array();
	var mssid_rx_pkt_num=new Array();
	var wlanDisabled=new Array();
	var opMode="<% getInfo("opMode"); %>"*1;
	var vlanOnOff = "<% getInfo("vlanOnOff"); %>"*1;
	var isPocketRouter="<% getInfo("isPocketRouter"); %>"*1;
	
	for(i=0; i<wlan_num; i++)
	{
		mssid_disable[i] = new Array(mssid_num);
		mssid_tx_pkt_num[i] = new Array(mssid_num);
		mssid_rx_pkt_num[i] = new Array(mssid_num);		
	}
	
	<%
	var i ;
	for (i=0; i<getIndex("wlan_num"); i=i+1) 
	{ 
		wlan_name= "wlan"+i+"-status";
		getInfo(wlan_name);
		write("ssid_drv["+i+"] ='");getInfo("ssid_drv");write("';\n");
		write("tx_pkt_num["+i+"] =");getInfo("wlanTxPacketNum");write(";\n"); 
		write("rx_pkt_num["+i+"] =");getInfo("wlanRxPacketNum");write(";\n");
		write("rp_enabled["+i+"] ="+getIndex("isRepeaterEnabled")+";\n"); 
		write("rp_tx_pkt_num["+i+"] =");getInfo("wlanRepeaterTxPacketNum");write(";\n");
		write("rp_rx_pkt_num["+i+"] =");getInfo("wlanRepeaterRxPacketNum");write(";\n");
		write("wlanDisabled["+i+"] ="+getIndex("wlanDisabled")+";\n");			
		
		for (k=0; k<getIndex("wlan_mssid_num"); k=k+1)
		{
			write("mssid_disable["+i+"]["+k+"] ="+getVirtualIndex("wlanDisabled", k+1)+";\n");				
			write("mssid_tx_pkt_num["+i+"]["+k+"] =");getVirtualInfo("wlanTxPacketNum", k+1);write(";\n"); 			
			write("mssid_rx_pkt_num["+i+"]["+k+"] =");getVirtualInfo("wlanRxPacketNum", k+1);write(";\n");				
		}	
	}
	%>
  	for(i=0 ;i < wlan_num ; i++){
		if (!wlanDisabled[i]) {
			  if(ssid_drv[i]!=""){
			  document.write(' <tr>\
			    <td width="30%" rowspan="2"><font size=2><b>Wireless '+<% if (getIndex("wlan_num") > 1)  write("(i+1)+"); %>' LAN</b></td>\
			    <td width="30%"><font size=2><i>Sent Packets</i></td>\
			    <td width="20%"><font size=2>' + tx_pkt_num[i] +'</td>\
			  </tr>\
			  <tr>\
			    <td width="30%"><font size=2><i>Received Packets</i></td>\
			    <td width="20%"><font size=2>' + rx_pkt_num[i] + '</td>\
			  </tr>');
			} else {
			   mssid_num=0;
			}
			  if (rp_enabled[i])
			  {
			  document.write(' <tr>\
			    <td width="30%" rowspan="2"><font size=2><b>Wireless '+<% if (getIndex("wlan_num") > 1)  write("(i+1)+"); %>' Repeater LAN</b></td>\
			    <td width="30%"><font size=2><i>Sent Packets</i></td>\
			    <td width="20%"><font size=2>' + rp_tx_pkt_num[i] +'</td>\
			  </tr>\
			  <tr>\
			    <td width="30%"><font size=2><i>Received Packets</i></td>\
			    <td width="20%"><font size=2>' + rp_rx_pkt_num[i] + '</td>\
			  </tr>');	  	  
			  }	
			
			if (wlanMode==0 || wlanMode==3 ) {
			 for (idx=0; idx<mssid_num; idx++) {
				if (!mssid_disable[i][idx]) {
				  document.write(' <tr>\
				  	<td width="30%" rowspan="2"><font size=2><b>&nbsp;&nbsp;Virtual AP'+(idx+1)+'</b></td>\
					<td width="30%"><font size=2><i>Sent Packets</i></td>\
					<td width="20%"><font size=2>' + mssid_tx_pkt_num[i][idx] +'</td>\
					</tr>\
				  	<tr>\
					<td width="30%"><font size=2><i>Received Packets</i></td>\
					<td width="20%"><font size=2>' + mssid_rx_pkt_num[i][idx] + '</td>\
					</tr>');	  	  		
				}	  
			}
			}
		}
	 }
	 
		function drawLanStatistics()
		{
		
			if(isPocketRouter == 1 && "<% getInfo("vlanOnOff"); %>"*1 == 1)
				return;
			else if(isPocketRouter == 1 && opMode == 0)
				return;
				

			if( "<% getInfo("vlanOnOff"); %>"*1 == 0)
			{
				var lanTx="<% getInfo("lanTxPacketNum"); %>";
				var lanRx="<% getInfo("lanRxPacketNum"); %>";
				
				document.write("<tr><td width='30%' rowspan='2'><font size=2><b>Ethernet LAN</b></td>");
	    	document.write("<td width='30%'><font size=2><i>Sent Packets</i></td>");
	    	document.write("<td width='20%'><font size=2>"+lanTx+"</td></tr>");
	  		document.write("<tr><td width='30%'><font size=2><i>Received Packets</i></td>");
	    	document.write("<td width='20%'><font size=2>"+lanRx+"</td></tr>");
    	}
    	else
    	{
    		var lan1Tx="<% getInfo("lanTxPacketNum"); %>";
				var lan1Rx="<% getInfo("lanRxPacketNum"); %>";
				var lan2Tx="<% getInfo("lan2TxPacketNum"); %>";
				var lan2Rx="<% getInfo("lan2RxPacketNum"); %>";
				var lan3Tx="<% getInfo("lan3TxPacketNum"); %>";
				var lan3Rx="<% getInfo("lan3RxPacketNum"); %>";
				var lan4Tx="<% getInfo("lan4TxPacketNum"); %>";
				var lan4Rx="<% getInfo("lan4RxPacketNum"); %>";
				
	    	document.write("<tr><td width='30%' rowspan='2'><font size=2><b>Ethernet LAN1</b></td>");
	    	document.write("<td width='30%'><font size=2><i>Sent Packets</i></td>");
	    	document.write("<td width='20%'><font size=2>"+lan1Tx+"</td></tr>");
	  		document.write("<tr><td width='30%'><font size=2><i>Received Packets</i></td>");
	    	document.write("<td width='20%'><font size=2>"+lan1Rx+"</td></tr>");
	    	
	    	document.write("<tr><td width='30%' rowspan='2'><font size=2><b>Ethernet LAN2</b></td>");
	    	document.write("<td width='30%'><font size=2><i>Sent Packets</i></td>");
	    	document.write("<td width='20%'><font size=2>"+lan2Tx+"</td></tr>");
	  		document.write("<tr><td width='30%'><font size=2><i>Received Packets</i></td>");
	    	document.write("<td width='20%'><font size=2>"+lan2Rx+"</td></tr>");
	    	document.write("<tr><td width='30%' rowspan='2'><font size=2><b>Ethernet LAN3</b></td>");
	    	document.write("<td width='30%'><font size=2><i>Sent Packets</i></td>");
	    	document.write("<td width='20%'><font size=2>"+lan3Tx+"</td></tr>");
	  		document.write("<tr><td width='30%'><font size=2><i>Received Packets</i></td>");
	    	document.write("<td width='20%'><font size=2>"+lan3Rx+"</td></tr>");
	    	
	    	document.write("<tr><td width='30%' rowspan='2'><font size=2><b>Ethernet LAN4</b></td>");
	    	document.write("<td width='30%'><font size=2><i>Sent Packets</i></td>");
	    	document.write("<td width='20%'><font size=2>"+lan4Tx+"</td></tr>");
	  		document.write("<tr><td width='30%'><font size=2><i>Received Packets</i></td>");
	    	document.write("<td width='20%'><font size=2>"+lan4Rx+"</td></tr>");
	    }
			
		}
		
		function drawWanStatistics()
		{			
			var wanTx="<% getInfo("wanTxPacketNum"); %>";
			var wanRx="<% getInfo("wanRxPacketNum"); %>";
			var isAP = <% write(getIndex("isPureAP")); %>;
				
			if(opMode == 1 && vlanOnOff == 0)
				return;
			
			if(isPocketRouter == 1 && opMode == 1 && vlanOnOff == 1)
				document.write("<tr><td width='30%' rowspan='2'><font size=2><b>Ethernet LAN</b></td>");
			else if((opMode == 1 || opMode == 2) && vlanOnOff == 1)
				document.write("<tr><td width='30%' rowspan='2'><font size=2><b>Ethernet LAN5</b></td>");
			else if((opMode == 1 || opMode == 2) && vlanOnOff == 0)
				return;
			else if(vlanOnOff==1 && isAP == 1)
				document.write("<tr><td width='30%' rowspan='2'><font size=2><b>Ethernet LAN5</b></td>");
			else if(vlanOnOff==0 && isAP == 1)
				return;
			else if(opMode == 0)
				document.write("<tr><td width='30%' rowspan='2'><font size=2><b>Ethernet WAN</b></td>");
				
		  document.write("<td width='30%'><font size=2><i>Sent Packets</i></td>");
		  document.write("<td width='20%'><font size=2>"+wanTx+"</td></tr>");
		  document.write("<tr><td width='30%'><font size=2><i>Received Packets</i></td>");
		  document.write("<td width='20%'><font size=2>"+wanRx+"</td></tr>");
			
		}
  </script>
  <!--
  <tr>
   <td width="30%" rowspan="2"><font size=2><b>Ethernet LAN</b></td>
    <td width="30%"><font size=2><i>Sent Packets</i></td>
    <td width="20%"><font size=2><% getInfo("lanTxPacketNum"); %></td>
  </tr>
  <tr>
    <td width="30%"><font size=2><i>Received Packets</i></td>
    <td width="20%"><font size=2><% getInfo("lanRxPacketNum"); %></td>
  </tr>
  -->
  <SCRIPT >drawLanStatistics();</SCRIPT>
  <SCRIPT >drawWanStatistics();</SCRIPT>
</table>
  <br>
  <input type="hidden" value="/stats.asp" name="submit-url">
  <input type="submit" value="Refresh" name="refresh">
</form>
</blockquote>
</body>

</html>
