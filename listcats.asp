<%@ Language=VBScript %>
<%
'This page is obsolete.
'This script is here to redirect any leftover traffic (from search engines, etc) to the new ASP.NET pages.
%>
<%

Response.Status="301 Moved Permanently"
Response.AddHeader "Location", "listcats.aspx"
%>
