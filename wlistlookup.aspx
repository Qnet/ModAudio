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
    Public messagesent As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()
         
        'Checks your Shop Access/Checkout settings.
        pd.VerifyShopAccess()

        'If This feature is not enabled
        If pd.wishen <> 1 Then pd.pdRedirect("default.aspx")

        If Not (Page.IsPostBack) Then

        End If

        If Page.IsPostBack Then
            pd.checkForm(email.Text, pd.getsystext("sys23"), "E", 5, 50)
            pd.formerror = pd.formerror & pd.checkchr(email.Text, pd.getsystext("sys23"))

            'If no errors, open database get customer id
            If pd.formerror = "" Then

                pd.OpenDataReader("SELECT id FROM customer WHERE email='" & pd.FormatSqlText(LCase(email.Text)) & "'")
                If pd.ReadDataItem.Read Then
                Else
                    pd.formerror = pd.geterrtext("err50")
                End If
                pd.CloseData()

            End If

            'If customer found... go to wishtlist
            If pd.formerror = "" Then
                pd.saveCookie("wlistemail", LCase(email.Text), 0)
                pd.pdRedirect("wlistsearch.aspx")
            End If

        End If


    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg11)%>
<%= pd.startSection("heads27")%>
<div class="form_container">
    <form method="POST" action="wlistlookup.aspx" id="pageform" name="pageform" runat="server">
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="formheadings">
        <%=pd.getsystext("sys23")%></div>
    <div>
        <asp:textbox class="formfield" id="email" runat="server" />
    </div>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14","","","pageform")%></div>
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg11)%>
