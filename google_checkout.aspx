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

        cartid = pd.getcookie("cartid")

        If Not (Page.IsPostBack) Then
        End If

        'Get Payment Gateway options, check if Google enabled.
        pd.getgatewayoptions()

        'Send shopping cart, shipping, and tax rules to Google's API, then redirect user.
        pd.startGoogleCheckout(cartid)

    End Sub



    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg9)%>
<%= pd.startSection("heads7")%>
<div>
    <div class="messages">
        <%=pd.getFormError()%></div>
    <br />
    <div>
        <%'=pd.getButton("butts5","", "showcart.aspx","") %></div>
    <div class="formbuttons_container">
        <%=pd.getButton("butts13", "", "checkout1.aspx","")%></div>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>
