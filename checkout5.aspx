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
    Public thankyoumessage, pptrx As String
    Public downloadcount As Int32

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        'Verify User.
        If pd.hasShipping() = "No" Then pd.pdRedirect("checkout3.aspx")
        If pd.hasPayment() = "No" Then pd.pdRedirect("checkout4.aspx")

        cartid = pd.getcookie("cartid")
        orderid = pd.getcookie("orderid")

        pd.OpenSetupDataReader("otherxml", "misc")

        If pd.getrequest("method") = "pbm" Then
            thankyoumessage = pd.ReadData("pbmnote")
        Else
            thankyoumessage = pd.ReadData("orderthanks")
        End If
               
        pd.ChangeSetupDataReaderNode("email")
         
        confemail = pd.ReadData("confemail")
        emailfrom1 = pd.ReadData("emailfrom1")
        emailfromname1 = pd.ReadData("emailfromname1")
        emailsubject1 = pd.ReadData("emailsubject1")
        emailbody1 = pd.ReadData("emailbody1")
        notifyadmin = pd.ReadData("notifyadmin")
        orderemailto = pd.ReadData("orderemailto")
        orderemailcc = pd.ReadData("orderemailcc")

        pd.CloseData()

        'Get PayPal IPN settings
        pd.OpenSetupDataReader("setupxml", "gateway")

        ppipnen = pd.ReadData("ppipnen")

        pd.CloseData()

        'After calling the functions below, some Public Variables will then be available...
        pd.getOrderVariables("", orderid, cartid)

        'Get Customer Downloads
        listdownloads.DataSource = pd.bindcustomerdownloads(0, orderid)
        downloadcount = listdownloads.DataSource.Count
        listdownloads.DataBind()

        'Send Order Confirmation Email
        If ppipnen = "ON" And pd.sCctype = "PayPal" Then
        Else
            If confemail = "ON" Then
                emailto = pd.sBillEmail
                emailtoname = pd.sBillName
                emailfrom = emailfrom1
                emailfromname = emailfromname1
                emailsubject = emailsubject1
                emailsubject = Replace(emailsubject, "##ORDERNO##", pd.iOrderno)
                emailbody = emailbody1
                emailbody = Replace(emailbody, "##ORDERNO##", pd.iOrderno)
                emailbody = Replace(emailbody, "##CUSTNAME##", pd.sBillName)
                emailbody = Replace(emailbody, "##DATE##", pd.showdate(DateTime.Now.ToShortDateString))
                emailbody = Replace(emailbody, "##ORDERLINK##", pd.getorderlink(orderid))

                'Arguments(semailto,semailfrom,semailsubject,semailbody,semailformat,semailattachment)
                pd.Sendemail(emailto, emailcc, emailfrom, emailfromname, emailsubject, emailbody, "Text", "")

            End If

            'Send Admin Notification Email
            If notifyadmin = "ON" Then

                emailto = orderemailto
                emailcc = orderemailcc
                emailfrom = pd.emailadmin
                emailfromname = pd.storename
                emailsubject = pd.storename & " - Order Notification"
                emailbody = "New Order has arrived!" & vbCrLf & "Order Number: " & pd.iOrderno & vbCrLf & "LINK: " & pd.getadminorderlink(orderid)

                'Arguments(semailto,semailfrom,semailsubject,semailbody,semailformat,semailattachment)
                pd.Sendemail(emailto, emailcc, emailfrom, emailfromname, emailsubject, emailbody, "Text", "")

            End If
        End If

        'Format Thank You message, add variables
        thankyoumessage = Replace(thankyoumessage, "##ORDERNO##", pd.iOrderno)
        thankyoumessage = Replace(thankyoumessage, "##CUSTNO##", pd.iCustomerid)

        'Cleanup
        pd.removeCookie("orderid")
        pd.removeCookie("cartid")
        pd.removeCookie("gift")
        pd.removeCookie("disc")
        pd.removeCookie("cc")
        pd.removeCookie("pptoken")

        'Check for PayPal Transaction ID
        pptrx = pd.getcookie("pptrx")
        pd.removeCookie("pptrx")

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg9)%>
<%= pd.startSection("heads23")%>
<div>
    <div class="messages">
        <%=pd.getFormError()%></div>
    <% If pptrx <> "" Then%>
    <div class="formheadings2">
        PayPal Transaction ID:
        <%=pptrx%></div>
    <% End If%>
    <div>
        <%=thankyoumessage%></div>
    <div class="cartbuttons_container">
        <% If pd.popuptype = "I" Then%>
        <%= pd.getButton("butts26", "", "javascript: showPopWin('popup_orderview.aspx?orderid=" & pd.iOrderid & "&key=" & pd.getOrderKey(pd.iOrderid) & "', " & pd.ordwinw & "," & pd.ordwinh & ", null, true, false)", "")%>
        <% Else%>
        <%= pd.getButton("butts26", "", "javascript: showwindow('popup_orderview.aspx?orderid=" & pd.iOrderid & "&key=" & pd.getOrderKey(pd.iOrderid) & "', " & pd.ordwinw & "," & pd.ordwinh & ", null)", "")%></div>
    <% End If%>
</div>
<%= pd.endSection()%>
<%  If downloadcount > 0 Then%>
<%= pd.startSection("heads24")%>
<div>
    <asp:repeater id="listdownloads" runat="server">
        <headertemplate>
           
        <hr class="rowline" />
        <div style="width: 100%;">
            <div class="formheadings" style="float: left; width: 33%;"><%=pd.getsystext("sys65")%></div>
            <div class="formheadings" style="float: left; width: 33%;"><%=pd.getsystext("sys1")%></div>
            <div class="formheadings" style="float: left; width: 33%;"></div>
            <div style="clear: both;"><!-- --></div>
        </div>
        <hr class="rowline" />

        </headertemplate>
        <itemtemplate>

        <div style="width: 100%;">
            <div class="cartdata" style="float: left; width: 33%;"><%# Container.DataItem("orderno") %></div>
            <div class="cartdata" style="float: left; width: 33%;"><%# Container.DataItem("itemname") %></div>
            <div class="cartdata" style="float: left; width: 33%;"><%# Container.DataItem("message") %><%# Container.DataItem("downloadbutton") %></div>
            <div style="clear: both; height: 10px;"><!-- --></div>
        </div>
             
        </itemtemplate>
        <footertemplate>
        </footertemplate>
    </asp:repeater>
</div>
<%= pd.endSection()%>
<%  End If%>
<%=pd.getBottomHtml(pd.pg9)%>