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
    Public imageurl As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()

        'Get Image File location, determine if valid location (and if remotely hosted)
        imageurl = pd.getrequest("image")
        If Right(LCase(imageurl), 3) = "png" Or Right(LCase(imageurl), 3) = "jpg" Or Right(LCase(imageurl), 4) = "jpeg" Or Right(LCase(imageurl), 3) = "gif" Then
            If Left(LCase(imageurl), 4) <> "http" Then
                imageurl = pd.url & pd.pdimagesfolder & imageurl
            End If
        Else
            imageurl = ""
        End If
         
        'Encode
        imageurl = pd.dohtmlencode(imageurl)

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
    <link rel="stylesheet" type="text/css" href="shop-css.aspx" />
    <% If pd.popuptype = "I" Then%>
    <script type="text/javascript">
        parent.document.getElementById('popupControls').innerHTML = '<img width="19" height="19" src="<% =pd.pdimgurl %>close.gif" onclick="hidePopWin(false);" id="popCloseBox" />'
    </script>
    <% End If%>
</head>
<body class="popupbody">
    <div class="popupimages">
        <img src="<%=imageurl%>" border="0"></div>
        <div class="formbuttons_container">
            <% If pd.popuptype = "I" Then%>
            <%=pd.getButton("butts33", "", "javascript: parent.hidePopWin(false)","")%>
            <% Else%>
            <%= pd.getButton("butts33", "", "javascript: window.close()", "")%>
            <% End If%></div>
</body>
</html>
