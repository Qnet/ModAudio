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
    Public itemid, saveditemid, customerid, messagesent As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()
    

        'Get email info
        pd.OpenSetupDataReader("otherxml", "email")

        emailfrom = pd.ReadData("emailfrom5")
        emailfromname = pd.ReadData("emailfromname5")
        emailsubject = pd.ReadData("emailsubject5")
        emailbody = pd.ReadData("emailbody5")

        pd.CloseData()
    
        'If This feature is not enabled
        If pd.email5en <> "ON" Then pd.pdRedirect(pd.shopurl & "default.aspx")

        'Check if returning after registering or signing in.
        saveditemid = pd.getcookie("emailanid")
        itemid = pd.getrequest("itemid")
        If saveditemid <> "" Then itemid = saveditemid
        If Not IsNumeric(itemid) Then pd.pdRedirect(pd.shopurl & "default.aspx")

        'See if customer is signed-in
        customerid = pd.getcookie("customerid")
        If Not IsNumeric(customerid) Then
            pd.saveCookie("emailanid", itemid, 0)
            pd.pdRedirect("signin.aspx?refer=emailafriend.aspx")
        End If


        If Not (Page.IsPostBack) Then

        End If

        If Page.IsPostBack Then

            'Check form for errors
            pd.checkForm(email.Text, pd.getsystext("sys80"), "T", 3, 50)
            pd.formerror = pd.formerror & pd.checkchr(email.Text, pd.getsystext("sys80"))
            pd.checkForm(comments.Text, pd.getsystext("sys82"), "T", 0, 255)


            If pd.formerror = "" Then

                'Call function to get customer record
                pd.getCustomerVariables(customerid)


                'Get Item details
                pd.OpenDataReader("SELECT * FROM items WHERE active='Yes' AND id=" & itemid)
                If pd.ReadDataItem.Read Then
                    itemname = pd.ReadData("name")
                    itemdesc = pd.ReadData("shortdesc")
                    itemno = pd.ReadData("itemno")
                End If
                pd.CloseData()

                'Replace variables in template with data
                emailsubject = Replace(emailsubject, "##SENDERNAME##", pd.sName)
                emailbody = Replace(emailbody, "##MESSAGE##", comments.Text)
                emailbody = Replace(emailbody, "##SENDERNAME##", pd.sName)
                emailbody = Replace(emailbody, "##ITEMNAME##", itemname)
                emailbody = Replace(emailbody, "##ITEMDESC##", itemdesc)
                emailbody = Replace(emailbody, "##ITEMNO##", itemno)
                emailbody = Replace(emailbody, "##ITEMURL##", pd.shopurl & "item.aspx?itemid=" & itemid)


                'Arguments(semailto,semailfrom,semailsubject,semailbody,semailformat,semailattachment)
                pd.formerror = pd.Sendemail(email.Text, "", emailfrom, emailfromname, emailsubject, emailbody, "Text", "")
                If pd.formerror = "" Then messagesent = "Yes"
                pd.removeCookie("emailanid")
                pd.pdRedirect(pd.shopurl & "item.aspx?showalert=emailed&itemid=" & itemid)

            End If


        End If


    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%= pd.getTopHtml(pd.pg4)%>
<%= pd.startSection("heads15")%>
<div class="form_container">
    <form method="POST" action="emailafriend.aspx" id="pageform" name="pageform" runat="server">
    <input type="hidden" name="itemid" value="<%=itemid%>" />
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="formheadings">
        <%=pd.getsystext("sys80")%></div>
    <div>
        <asp:textbox class="formfield" id="email" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys82")%></div>
    <div>
        <asp:textbox class="formtextarea1" id="comments" wrap="true"
            textmode="MultiLine" runat="server" />
    </div>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14","","","pageform")%></div>
    </form>
</div>
<%= pd.endSection()%>
<%= pd.getBottomHtml(pd.pg4)%>