<html>
<head>
	<script type="text/javascript" src="mtmcode.js"></script>
	<script type="text/javascript" src="util_gw.js"></script>
	<style>
	.on {display:on}
	.off {display:none}
	</style>
	<script language=JavaScript>
	<!--
		var count = <% getInfo("countDownTime"); %>*1;
		var pocketRouter_Mode="<% getInfo("pocketRouter_Mode_countdown"); %>"*1; /* 1:client 2:AP */
		var waitcount = <% getInfo("countDownTime_wait"); %>*1;
		var seconds_word=" seconds ";
		
		if(waitcount==1 && (pocketRouter_Mode==1 || pocketRouter_Mode==2) ){
			count=90;
		}else if(waitcount==2 && (pocketRouter_Mode==1 || pocketRouter_Mode==2) ){
			count=120;
		}
			
		function get_by_id(id)
		{
			with(document)
			{
				return getElementById(id);
			}
		}
		
		function change_state(istate)
		{
			if(parent.frames[1])
			{
			parent.frames[1].state = istate;			
			MTMDisplayMenu();
		}
		
			if(pocketRouter_Mode == 1){
				get_by_id("show_msg").innerHTML = "Please wait awhile and re-open browser to configure Pocket Router. ";
			}
		}
		
		function closeBrowser()
		{
			parent.window.close();			
		}
		
		function do_count_down()
		{
			show_div(false, "close_button");
			
		
			get_by_id("show_sec").innerHTML = count;
			
			if(count == 0) 
			{
				var browser=eval ( '"' + top.location + '"' );
				var ip_lan = "<% getInfo('ip-lan'); %>";
				var domainName = "<% getInfo('domainName'); %>";
				var connect_url;
				
				change_state('normal');
				
				if(pocketRouter_Mode != 0)
				{
					if(pocketRouter_Mode == 2)
						domainName = domainName+"ap";
					else
						domainName = domainName+"cl";
						
//alert("browser="+browser);
					domainName = domainName.toLowerCase();
//alert("domainName="+domainName);
					if (browser.indexOf(ip_lan) > -1 )
					{
						connect_url=ip_lan;
						
					}
					else if (browser.indexOf("www."+domainName+".net") > -1 )
					{
						connect_url = "www."+domainName+".com";
					}
					else if(browser.indexOf("www."+domainName+".com") > -1 )
					{
						connect_url = "www."+domainName+".net";
					}
					else if (browser.indexOf(domainName+".net") > -1 )
					{
						connect_url = domainName+".com";
					}
					else if(browser.indexOf(domainName+".com") > -1 )
					{
						connect_url = domainName+".net";
					}
					else if (browser.indexOf(domainName) > -1 )
					{
						connect_url = domainName+".com";
					}
					else
					{
						connect_url = domainName+".com";
					}
					
				}
				else
				{
					connect_url=ip_lan;
				}
				
				var lastUrl="<% getInfo("lastUrl"); %>";
				
				if(lastUrl == "/wizard.asp")
				{
					parent.location.href = 'http://'+connect_url;
				}
				else
				{
					
//alert("connect_url="+connect_url);
					var location_href = 'http://'+connect_url+lastUrl+'?t='+new Date().getTime();				
//alert("location_href="+location_href);				
					parent.frames[3].location.href=location_href;
				}
				
				return false;
			}
			
			if (count > 0) 
			{
				
				count--;
				setTimeout('do_count_down()',1000);
			}
		}
	//-->
	</script>
</head>
<body onload="change_state('normal');do_count_down();">
	<blockquote>
		<h4><h4>Change setting successfully!<BR><br>
			<SPAN id=show_msg>Do not turn off or reboot the Device during this time.</span>
		</h4>
		<P align=left>
			<h4><SPAN id=please_wait>Please wait </span><B><SPAN id=show_sec></SPAN></B>&nbsp;<SPAN id=show_seconds>seconds ...</SPAN></h4>
		</P>
		<span id = "close_button" class = "off" >
			<input type="button" value="  OK  " name="cancel" onClick='closeBrowser();'>
		</span>
	</blockquote>
</body>
</html>
