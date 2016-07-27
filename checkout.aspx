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
    Public task As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        'Verify if can Checkout, or where to go next.
        If pd.hasCartItems() = "No" Then pd.pdRedirect("showcart.aspx")
         
        'Redirect if necessary, depending on Checkout Options
        If pd.checkoutflow = 2 Then pd.pdRedirect("register.aspx?refer=checkout1.aspx")
        If pd.checkoutflow = 3 Then pd.pdRedirect("checkout1.aspx")
        If pd.checkoutflow = 4 Then pd.pdRedirect("checkout1.aspx")
         
        'Continue to Verify checkout status
        If pd.isSignedIn() = "Yes" Then pd.pdRedirect("checkout1.aspx")
        If pd.hasStartedPayPal() = "Yes" Then pd.pdRedirect("paypal_express2.aspx")
        If pd.hasBillingAddress() = "Yes" Then pd.pdRedirect("checkout1.aspx")
         
         
        If Not (Page.IsPostBack) Then
            'Set default
            guest.Checked = True
        End If
 
        If Page.IsPostBack Then

            If guest.Checked = True Then
                pd.pdRedirect("checkout1.aspx")
            End If
            
            If register.Checked = True Then
                pd.pdRedirect("register.aspx?refer=checkout1.aspx")
            End If
            
            If signin.Checked = True Then
                pd.pdRedirect("signin.aspx?refer=checkout1.aspx")
            End If
                  

        End If


    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg9)%>
<%= pd.startSection("heads33")%>
<div class="form_container">
    <form method="POST" action="checkout.aspx" id="pageform" name="pageform" runat="server">
    <div class="messages">
        <%=pd.getFormError()%></div>
    <%
        
        coflowguest = "ON"
        coflowregister = "ON"
        coflowsignin = "ON"
        
    %>
    <% If coflowguest = "ON" Then%>
    <div class="radiobuttons_container">
        <asp:radiobutton groupname="coflow" id="guest" runat="server" class="radiobuttons" />
        <%=pd.getsystext("sys131")%>
    </div>
    <% End If%>
    <% If coflowregister = "ON" Then%>
    <div class="radiobuttons_container">
        <asp:radiobutton groupname="coflow" id="register" runat="server" class="radiobuttons" />
        <%= pd.getsystext("sys132")%>
    </div>
    <% End If%>
    <% If coflowsignin = "ON" Then%>
    <div class="radiobuttons_container">
        <asp:radiobutton groupname="coflow" id="signin" runat="server" class="radiobuttons" />
        <%= pd.getsystext("sys133")%>
    </div>
    <% End If%>
    <div class="formbuttons_container">
        <%= pd.getButton("butts14", "", "", "pageform")%>
    </div>
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>
