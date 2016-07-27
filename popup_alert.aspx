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

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<html>
<head>
    <title>
        <%=pd.pagetitle%></title>
    <link rel="stylesheet" type="text/css" href="shop-css.aspx" />
    <script language="JavaScript">
        function getMessage() {

            //Get message from main page (parent frame)! 
            var themess = parent.document.alertform.elements['alertmessage'].value;
            if (document.all) {
                document.getElementById('theMessage').innerText = themess;
            } else {
                document.getElementById('theMessage').textContent = themess;
            }
            // Use innerText for IE & most... textContent for FF.

        }   
    </script>

    <% If pd.popuptype = "I" Then%>
    <script type="text/javascript">
        parent.document.getElementById('popupControls').innerHTML = '<img width="19" height="19" src="<% =pd.pdimgurl %>close.gif" onclick="hidePopWin(false);" id="popCloseBox" />'
    </script>
    <% End If%>

</head>
<body onload="getMessage();" class="popupbody">
    <div class="popupmessages">
        <div id="theMessage">
        </div>
    </div>
    <div>
        <% If pd.getrequest("showprintbutton") = "Y" Then%>
        <div class="formbuttons_container">
            <%=pd.getButton("butts32", "", "javascript: parent.popupFrame.printnormal();","")%></div>
        <% End If%>
        <div class="formbuttons_container">
            <%=pd.getButton("butts33", "", "javascript: parent.hidePopWin(false)","")%></div>
    </div>
</body>
</html>
