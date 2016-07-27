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
    Public listdownloadscount, listorderscount As Int32

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        
        'Check if using Order Link to Access
        orderid = pd.getrequest("id")
        orderkey = pd.getrequest("key")
        If IsNumeric(orderid) And Len(orderkey) > 10 Then
            If pd.isOrderKeyValid(orderid, orderkey) = "Yes" Then
                pd.pdRedirect("orderstatus_guest.aspx?orderid=" & orderid & "&key=" & orderkey)
            End If
        End If
        
        If Not (Page.IsPostBack) Then
            
            'Enforce Secure Connection, PCI Compliance
            If pd.urlen = "Yes" And InStr(LCase(pd.shopsslurl), "https") <> 0 Then
                pd.jssecureredirect(pd.shopsslurl & "orderstatus.aspx")
                'pageform.Action = pd.shopsslurl & "orderstatus.aspx" '(only works with ASP.NET 2.0 SP2 and higher)
            End If
            
            'Demo Mode
            If pd.shopdemomode = "Yes" Then
                captcha.Text = "123456"
            End If
                
        End If
        
        'Redirect Customer as needed
        If pd.isSignedIn() = "Yes" Then
            pd.pdRedirect("orderstatus_customer.aspx")
        End If
        
        If Page.IsPostBack Then
            
            'Check for invalid characters
            pd.formerror = pd.checkchr(email.Text, pd.getsystext("sys23"))
            pd.formerror = pd.formerror & pd.checkchr(orderno.Text, pd.getsystext("sys138"))
            
            'Verify Captcha Code
            If pd.passShopCaptcha(captcha.Text) = False Then
                pd.formerror = pd.formerror & pd.geterrtext("err71")
                captcha.Text = ""
            End If
            
            'Order Lookup, by Order No (and by Trasaction ID, for PayPal and Google Order numbers)
            If pd.formerror = "" And Len(orderno.Text) > 0 And Len(email.Text) > 1 Then
                
                If IsNumeric(orderno.Text) Then
                    pd.OpenDataReader("SELECT customer.email As custemail, orders.id, orders.billemail, orders.orderno, orders.customerid FROM orders LEFT JOIN customer ON customer.id=orders.customerid WHERE orderno=" & pd.FormatSqlText(orderno.Text) & " OR cctrxid='" & pd.FormatSqlText(orderno.Text) & "'")
                Else
                    pd.OpenDataReader("SELECT customer.email As custemail, orders.id, orders.billemail, orders.orderno, orders.customerid FROM orders LEFT JOIN customer ON customer.id=orders.customerid WHERE cctrxid='" & pd.FormatSqlText(orderno.Text) & "'")
                End If
                
                If pd.ReadDataItem.Read Then
                    orderid = pd.ReadDataN("id")
                    If pd.ReadDataN("customerid") > 0 Then
                        billemail = pd.ReadData("custemail")
                    Else
                        billemail = pd.ReadData("billemail")
                    End If
                    
                    If LCase(billemail) = LCase(email.Text) Then
                        redirecttoorder = "Y"
                    Else
                        pd.formerror = pd.geterrtext("err76")
                    End If
                Else
                    pd.formerror = pd.geterrtext("err76")
                End If
                pd.CloseData()
                
                'Redirect to Order (AS GUEST)
                If redirecttoorder = "Y" Then
                    pd.pdRedirect(pd.getorderlink(orderid))
                End If

            End If
            
        End If

        If Not Page.IsPostBack Then

        End If


    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg9)%>
<%= pd.startSection("heads36")%>
<div class="form_container">
    <form method="POST" id="pageform" name="pageform" runat="server">
    <input type="hidden" name="task" value="post" />
    <input type="hidden" name="refer" value="<%=pd.dohtmlencode(refer)%>" />
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="formheadings">
        <%=pd.getsystext("sys23")%></div>
    <div>
        <asp:textbox class="formfield" id="email" runat="server" />
    </div>
    <div class="formheadings">
        <%= pd.getsystext("sys138")%></div>
    <div>
        <asp:textbox class="formfield" id="orderno" runat="server" />
    </div>

    <% If pd.shopcaptcha = "ON" Then%>
    <br />
    <div>
        <div class="formheadings" style="float: left;">
            <%=pd.getsystext("sys134")%>
            &nbsp;<br />
            <asp:textbox class="formfield3" id="captcha" runat="server" />
        </div>
        <div style="float: left;">
            <img src="captcha.aspx?rnum=<%=pd.getrandseq() %>" border="0" /></div>
        <div style="clear: both;">
            <!-- -->
        </div>
        <% If pd.shopdemomode = "Yes" Then%>
        <div class="formheadings">
            DEMO USERS: Because this is a Demo, the 'Captcha' Verification Code has been entered
            for you. Also note that this and other security features can be turned off.</div>
        <% End If%>
    </div>
    <br />
    <% End If%>

    <div class="formbuttons_container">
        <%=pd.getButton("butts14","","","pageform")%></div>
    </form>
</div>
<%= pd.endSection()%>
<%= pd.startSection("heads29")%>
<div>
    <div class="cartbuttons_container">
        <%=pd.getButton("butts2", "", pd.shopsslurl & "signin.aspx?refer=" & server.urlencode(refer),"")%></div>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>
