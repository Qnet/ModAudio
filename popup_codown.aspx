<%@ Page Language="VB" Explicit="False" %>

<%@ Import Namespace="PDshop9" %>
<script runat="server">

    '************************************************************
    '*         TERMS & CONDITIONS / COPYRIGHT NOTICE            *
    '************************************************************
    '*   By Downloading or using this software, you agree to    *
    '*   the terms and conditions as stated in the Software     *
    '*   License Agreement.  An updated copy of this agreement  *
    '*   can be seen at http://www.pagedowntech.com/terms.      *
    '*                                                          *
    '*   NOTICE: We do not recommend changing the code below    *
    '*   as it may interfere with future updates/upgrades.      *
    '*                                                          *
    '*        PageDown Technology, LLC., Copyright 2011.        *
    '*             pagedowntech.com / pdshop.com                *
    '*                                                          *
    '*  (this copyright notice must not be altered or removed)  *
    '************************************************************

    Public pd As PDshopFunctions
    Public message, errormessage, thekey, thekey2, nexturl As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()

        message = pd.getrequest("message")
        errormessage = pd.getrequest("errormessage")

        'Get Download Key
        thekey = pd.getrequest("key")
        thekey2 = pd.getrequest("key2")

        If message = "1" Then
            errormessage = pd.geterrtext("err38")
        End If
        If message = "2" Then
            errormessage = pd.geterrtext("err38")
        End If
        If message = "3" Then
            errormessage = pd.geterrtext("err39")
        End If
        If message = "4" Then
            errormessage = pd.geterrtext("err40")
        End If
        If message = "5" Then
            errormessage = pd.geterrtext("err41")
        End If

        'Create Next Download URL
        'nexturl = pd.shopurl & "popup_codown2.aspx?key=" & thekey & "&key2=" & thekey2   
        nexturl = "popup_codown2.aspx?key=" & thekey & "&key2=" & thekey2

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
    <title>
        <%=pd.pagetitle%></title>
    <meta http-equiv="refresh" content="30; URL=<%=nexturl%>" />
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252" />
    <link rel="stylesheet" type="text/css" href="shop-css.aspx" />
</head>
<body class="popupbody">
    <% = pd.startSection("heads24")%>
    <div>
        <div class="popupmessages">
            <%=pd.fixERR(formerror)%></div>
        <div class="popupmessages">
            <%=errormessage%></div>
        <% If errormessage = "" And thekey <> "" Then%>
        <div class="popupmessages">
            <%=pd.geterrtext("err15")%></div>
        <br />
        <% End If%>
        <div class="formbuttons_container">
            <%=pd.getButton("butts31","",nexturl,"") %>
            <% If pd.popuptype = "I" Then%>
            <%=pd.getButton("butts33", "", "javascript: parent.hidePopWin(false)","")%>
            <% Else%>
            <%= pd.getButton("butts33", "", "javascript: window.close()", "")%>
            <% End If%>
        </div>
    </div>
    <%= pd.endSection()%>
</body>
</html>
