<%@ Language=VBScript %>
<%
'This page is obsolete.
'This script is here to redirect any leftover traffic (from search engines, etc) to the new ASP.NET pages.
%>
<%
if isnumeric(request.querystring("recid"))=True then

  Response.Status="301 Moved Permanently"
  Response.AddHeader "Location", "custom.aspx?recid=" & request.querystring("recid")

end if
%>
