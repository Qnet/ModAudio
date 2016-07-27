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
    Public paymentdue, nexturl As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        'Verify if can Checkout.
        If pd.hasCartItems() = "No" Then pd.pdRedirect("showcart.aspx")
        If pd.hasShipping() = "No" Then pd.pdRedirect("checkout3.aspx")

        'Get and check/sanitize ids
        orderid = pd.getcookie("orderid")
        cartid = pd.getcookie("cartid")

        'Get Order Total, determine if payment is due.
        'After calling the functions below, some Public Variables will then be available...
        pd.getOrderVariables("", orderid, cartid)

        'Check Inventory
        pd.bindorderdetail(cartid, "")
        If pd.inventoryerror = "Yes" Then pd.pdRedirect("showcart.aspx")

        'Do Calculations
        If pd.dOrdergrandtotal > 0 Then
            paymentdue = "Y"
        End If

        'Determine what form elements to display
        pd.getgatewayoptions()

        If Not (Page.IsPostBack) Then

            'Enforce Secure Connection, PCI Compliance
            If pd.urlen = "Yes" And InStr(LCase(pd.shopsslurl), "https") <> 0 Then
                pd.jssecureredirect(pd.shopsslurl & "checkout4.aspx")
            End If
            
            'Get Drop Down Lists
            cctype.DataSource = pd.getcctypes()
            cctype.DataBind()
            expmonth.DataSource = pd.getmonths()
            expmonth.DataBind()
            expyear.DataSource = pd.getyears() 'explist2
            expyear.DataBind()

            'Determine which payment option you want pre-selected.
            methodcc.Checked = True
            methodpp.Checked = True
            methodpbm.Checked = True
            method2c.Checked = True
            methodan.Checked = True
            methodpf.Checked = True
            methodwp.Checked = True
            methodlp.Checked = True
            methodcg.Checked = True

            'If Already submitted Credit Card, okay to redisplay
            If pd.getcookie("cc") = "Y" Then

                cctype.SelectedIndex = cctype.Items.IndexOf(cctype.Items.FindByValue(pd.sCctype))
                ccardno.Text = pd.sCcardno
                ccnoc.Text = pd.sCcnoc
                cccode.Text = pd.sCccode
                expmonth.SelectedIndex = expmonth.Items.IndexOf(expmonth.Items.FindByValue(pd.sExpmonth))
                expyear.SelectedIndex = expyear.Items.IndexOf(expyear.Items.FindByValue(pd.sExpyear))
                method = "cc"
                methodcc.Checked = True

            ElseIf pd.authtest = "ON" Then
                cctype.SelectedIndex = cctype.Items.IndexOf(cctype.Items.FindByValue("Mastercard"))
                ccardno.Text = "5424000000000015"
                ccnoc.Text = "Test Person"
                cccode.Text = "541"
                expmonth.SelectedIndex = expmonth.Items.IndexOf(expmonth.Items.FindByValue("10"))
                expyear.SelectedIndex = expyear.Items.IndexOf(expyear.Items.FindByValue("2015"))

            End If

        End If

        If Page.IsPostBack Then

            'Prepare Database
            pd.OpenDataWriter("orders WHERE id=" & orderid & " AND cartid='" & cartid & "'")

            If methodpbm.Checked = True Then
                'Pay By Mail
                pd.AddData("cctype", pd.getsystext("sys44"), "T")
                pd.AddData("downen", pd.downen, "N")
                pd.AddData("status", "New", "T")
                pd.AddData("ccardno", "", "T")
                pd.AddData("cccode", "", "T")
                nexturl = "checkout5.aspx?method=pbm"
                updateinv = "Yes"
                finalizegc = "Yes"
                updategc = "Yes"

            ElseIf methodcc.Checked = True Then
                'Credit Card
                pd.AddFormData("cctype", cctype.SelectedItem.Text, pd.getsystext("sys47"), "T", 1, 50)
                pd.AddFormData("ccardno", ccardno.Text, pd.getsystext("sys48"), "X", 10, 20)
                If pd.showccvoption = "Yes" And (pd.processthecc = "Yes" Or pd.savecardcodes = "ON") Then 'Only process Card Code if real-time processing is enabled.
                    pd.AddFormData("cccode", cccode.Text, pd.getsystext("sys49"), "T", 3, 4)
                End If
                pd.AddFormData("expmonth", expmonth.SelectedItem.Text, pd.getsystext("sys51"), "T", 2, 2)
                pd.AddFormData("expyear", expyear.SelectedItem.Text, pd.getsystext("sys52"), "T", 2, 4)
                pd.AddFormData("ccnoc", ccnoc.Text, pd.getsystext("sys58"), "T", 3, 50)

                'Check Credit Card Number (tests against standard CC Algorithm)
                If pd.formerror = "" Then
                    If pd.checkcc(ccardno.Text) = False Then pd.formerror = pd.formerror & pd.geterrtext("err29")
                    If pd.checkexp(expmonth.SelectedItem.Text & "/" & expyear.SelectedItem.Text) = False Then pd.formerror = pd.formerror & pd.geterrtext("err31")
                End If

                'Credit Card Processing
                If pd.processthecc = "Yes" Then

                    If pd.authver = "AIM" Then
                        'Authorize.net
                        pd.AddData("status", "Incomplete", "T")
                        pd.AddData("downen", 0, "N") 'make downloads unavailable
                        nexturl = "processcc.aspx"
                    ElseIf pd.authver = "PP" Then
                        'PayPal Pro
                        pd.AddData("status", "Incomplete", "T")
                        pd.AddData("downen", 0, "N") 'make downloads unavailable
                        nexturl = "processcc_paypal.aspx"
                    ElseIf pd.authver = "CG" Then
                        'Your own Custom real-time Gateway
                        pd.AddData("status", "Incomplete", "T")
                        pd.AddData("downen", 0, "N") 'make downloads unavailable
                        nexturl = "processcc_custom.aspx"
                    End If

                Else
                    'No Processing - Offline Mode
                    pd.AddData("downen", pd.downen, "N")
                    pd.AddData("status", "New", "T")
                    nexturl = "checkout5.aspx"
                    updateinv = "Yes"
                    finalizegc = "Yes"
                    updategc = "Yes"
                End If

            ElseIf methodpp.Checked = True Then
                'PayPal
                If pd.ppipnen = "ON" Then
                    'IPN
                    pd.AddData("downen", 0, "N") 'make downloads unavailable
                    pd.AddData("cctype", "PayPal", "T")
                    pd.AddData("status", "Incomplete", "T")
                    pd.AddData("ccardno", "", "T")
                    pd.AddData("cccode", "", "T")
                    nexturl = "gateway_out.aspx"
                Else
                    'no IPN
                    pd.AddData("downen", pd.downen, "N")
                    pd.AddData("cctype", "PayPal", "T")
                    pd.AddData("status", "New", "T")
                    pd.AddData("ccardno", "", "T")
                    pd.AddData("cccode", "", "T")
                    nexturl = "gateway_out.aspx"
                    updateinv = "Yes"
                    finalizegc = "Yes"
                    updategc = "Yes"
                End If

            ElseIf methodppec.Checked = True Then
                'PayPal Express Checkout
                pd.AddData("downen", 0, "N") 'make downloads unavailable
                pd.AddData("cctype", "PayPal", "T")
                pd.AddData("status", "Incomplete", "T")
                pd.AddData("ccardno", "", "T")
                pd.AddData("cccode", "", "T")
                nexturl = "paypal_express1.aspx"

            ElseIf method2c.Checked = True Then
                '2Checkout
                pd.AddData("cctype", "2Checkout.com", "T")
                pd.AddData("downen", pd.downen, "N")
                pd.AddData("status", "New", "T")
                pd.AddData("ccardno", "", "T")
                pd.AddData("cccode", "", "T")
                nexturl = "gateway_out.aspx"
                updateinv = "Yes"
                finalizegc = "Yes"
                updategc = "Yes"

            ElseIf methodan.Checked = True Then
                'Authorize.net (SIM)
                pd.AddData("cctype", "Authorize.net", "T")
                pd.AddData("downen", pd.downen, "N")
                pd.AddData("status", "New", "T")
                pd.AddData("ccardno", "", "T")
                pd.AddData("cccode", "", "T")
                nexturl = "gateway_out.aspx"
                updateinv = "Yes"
                finalizegc = "Yes"
                updategc = "Yes"

            ElseIf methodpf.Checked = True Then
                'Verisign Payflow Link
                pd.AddData("cctype", "PayFlow", "T")
                pd.AddData("downen", pd.downen, "N")
                pd.AddData("status", "New", "T")
                pd.AddData("ccardno", "", "T")
                pd.AddData("cccode", "", "T")
                nexturl = "gateway_out.aspx"
                updateinv = "Yes"
                finalizegc = "Yes"
                updategc = "Yes"

            ElseIf methodwp.Checked = True Then
                'WorldPay
                pd.AddData("cctype", "WorldPay", "T")
                pd.AddData("downen", pd.downen, "N")
                pd.AddData("status", "New", "T")
                pd.AddData("ccardno", "", "T")
                pd.AddData("cccode", "", "T")
                nexturl = "gateway_out.aspx"
                updateinv = "Yes"
                finalizegc = "Yes"
                updategc = "Yes"

            ElseIf methodlp.Checked = True Then
                'LinkPoint
                pd.AddData("cctype", "LinkPoint", "T")
                pd.AddData("downen", pd.downen, "N")
                pd.AddData("status", "New", "T")
                pd.AddData("ccardno", "", "T")
                pd.AddData("cccode", "", "T")
                nexturl = "gateway_out.aspx"
                updateinv = "Yes"
                finalizegc = "Yes"
                updategc = "Yes"

            ElseIf methodcg.Checked = True Then
                'Custom Gateway
                pd.AddData("cctype", "Payment Gateway", "T")
                pd.AddData("downen", pd.downen, "N")
                pd.AddData("status", "New", "T")
                pd.AddData("ccardno", "", "T")
                pd.AddData("cccode", "", "T")
                nexturl = "gateway_custom.aspx"
                updateinv = "Yes"
                finalizegc = "Yes"
                updategc = "Yes"

            ElseIf pd.dOrdergrandtotal = 0 Then
                'No Payment Due
                pd.AddData("cctype", "None", "T")
                pd.AddData("status", "New", "T")
                pd.AddData("downen", pd.downen, "N")
                pd.AddData("ccardno", "", "T")
                pd.AddData("cccode", "", "T")
                nexturl = "checkout5.aspx"
                updateinv = "Yes"
                finalizegc = "Yes"
                updategc = "Yes"

            Else
                pd.formerror = pd.geterrtext("err61")
                nexturl = ""

            End If
            
            'Click to Accept Terms
            If pd.clickterms = "ON" And coterms.Checked = False Then
                pd.formerror = pd.geterrtext("err75")
            End If

            'If no errors, Add record to database
            If pd.formerror = "" And nexturl <> "" Then

                pd.AddData("giftamt", pd.dGiftamt, "N")
                pd.SaveData()

                'Link Orderdetail to Order
                pd.linkorderdetail(cartid, "", orderid)

                'Adjust inventory and Create download keys
                If updateinv = "Yes" Then pd.updateinventory(orderid)

                'Finalize Gift Certificate if buying a GC
                If finalizegc = "Yes" Then pd.finalizegc(orderid)

                'Update Gift Certificate upon redemption (if applicable)
                If updategc = "Yes" Then pd.updategcstatus(orderid)
                
                'Auth/Capture Tax Cloud
                If updateinv = "Yes" Then pd.dotaxcloudauth(orderid)
                
                'Clear mini cart
                pd.removeCookie("mc1")
                pd.removeCookie("mc2")

                pd.pdRedirect(nexturl)
            End If

        End If


    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg9)%>
<%= pd.startSection("heads7")%>
<div class="form_container">
    <form method="POST" action="checkout4.aspx" id="pageform" name="pageform" runat="server">
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="formheadings2">
        <%=pd.getsystext("sys42")%></div>
    <div class="formordertotal">
        <%=pd.showCurr(pd.dOrdergrandtotal)%>
        <% If pd.currrate <> 1 Then%>(<%= pd.showPrimaryCurr(pd.dOrdergrandtotal)%>) &nbsp;<% End If%>
        <%= pd.getButton("butts6", "", pd.shopsslurl & "orderreview.aspx", "")%></div>
    <% If paymentdue = "Y" Then%>
    <div class="formheadings2">
        <%=pd.getsystext("sys43")%></div>
    <!-- Pay By Mail Option -->
    <% If pd.showpbmoption = "Yes" Then%>
    <div class="radiobuttons_container">
        <asp:radiobutton groupname="method" id="methodpbm" runat="server" class="radiobuttons" />
        <%=pd.getsystext("sys44")%></div>
    <% End If%>
    <!-- PayPal Option -->
    <% If pd.showppoption = "Yes" Then%>
    <div class="radiobuttons_container">
        <asp:radiobutton groupname="method" id="methodpp" runat="server" class="radiobuttons" />
        <%=pd.getsystext("sys45")%></div>
    <div class="gatewaylogo">
        <img border="0" src="img/ppcclogo.gif">
    </div>
    <% End If%>
    <!-- PayPal Express Checkout Option -->
    <% If pd.showppexpress = "Yes" Then%>
    <div class="radiobuttons_container">
        <asp:radiobutton groupname="method" id="methodppec" runat="server" class="radiobuttons" />
        <%=pd.getsystext("sys45")%></div>
    <div class="gatewaylogo">
        <a href="paypal_express1.aspx">
            <img border="0" src="img/pplogo.gif"></a>
    </div>
    <% End If%>
    <!-- 2Checkout Option -->
    <% If pd.show2coption = "Yes" Then%>
    <div class="radiobuttons_container">
        <asp:radiobutton groupname="method" id="method2c" runat="server" class="radiobuttons" />
        <%=pd.getsystext("sys53")%></div>
    <div class="gatewaylogo">
        <img border="0" src="img/2checkoutlogo.gif" width="150" height="41"></div>
    <% End If%>
    <!-- Authorize.net Weblink Option -->
    <% If pd.showanoption = "Yes" Then%>
    <div class="radiobuttons_container">
        <asp:radiobutton groupname="method" id="methodan" runat="server" class="radiobuttons" />
        <%=pd.getsystext("sys54")%></div>
    <div class="gatewaylogo">
        <img border="0" src="img/authnetlogo.gif" width="186" height="40"></div>
    <% End If%>
    <!-- Verisign PayFlow Link Option -->
    <% If pd.showpfoption = "Yes" Then%>
    <div class="radiobuttons_container">
        <asp:radiobutton groupname="method" id="methodpf" runat="server" class="radiobuttons" />
        <%=pd.getsystext("sys55")%></div>
    <div class="gatewaylogo">
        <img border="0" src="img/logo_verisign.gif" width="116" height="34"></div>
    <% End If%>
    <!-- WorldPay Option -->
    <% If pd.showwpoption = "Yes" Then%>
    <div class="radiobuttons_container">
        <asp:radiobutton groupname="method" id="methodwp" runat="server" class="radiobuttons" />
        <%=pd.getsystext("sys56")%></div>
    <div class="gatewaylogo">
        <img border="0" src="img/worldpay-logo.gif" width="200" height="42"></div>
    <% End If%>
    <!-- LinkPoint Option -->
    <% If pd.showlpoption = "Yes" Then%>
    <div class="radiobuttons_container">
        <asp:radiobutton groupname="method" id="methodlp" runat="server" class="radiobuttons" />
        <%=pd.getsystext("sys57")%></div>
    <% End If%>
    <!-- Custom Gateway -->
    <% If pd.showcgoption = "Yes" Then%>
    <div class="radiobuttons_container">
        <asp:radiobutton groupname="method" id="methodcg" runat="server" class="radiobuttons" />
        <%=pd.getsystext("sys116")%></div>
    <% End If%>
    <% If pd.showccoption = "Yes" Then%>
    <div class="radiobuttons_container">
        <asp:radiobutton groupname="method" id="methodcc" runat="server" class="radiobuttons" />
        <%=pd.getsystext("sys46")%></div>
    <!-- BEGIN Credit Card Form -->
    <div class="formheadings2">
        <%= pd.getsystext("sys46")%></div>
    <div class="formheadings">
        <%=pd.getsystext("sys47")%></div>
    <div>
        <asp:dropdownlist id="cctype" runat="server" datavaluefield="name" datatextfield="name" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys48")%></div>
    <div>
        <asp:textbox class="formfield" id="ccardno" runat="server" />
    </div>
    <% If pd.showccvoption = "Yes" Then%>
    <div class="formheadings">
        <%=pd.getsystext("sys49")%></div>
    <div>
        <asp:textbox class="formfield2" id="cccode" runat="server" />
    </div>
    <% End If%>
    <div class="formheadings">
        <%=pd.getsystext("sys50")%></div>
    <div>
        <div class="formheadings" style="float: left;">
            <%=pd.getsystext("sys51")%><br />
            <asp:dropdownlist class="formfield3" id="expmonth" runat="server" />
        </div>
        <div class="formheadings">
            <%=pd.getsystext("sys52")%><br />
            <asp:dropdownlist class="formfield3" id="expyear" runat="server" />
        </div>
        <div style="clear: both;">
            <!-- -->
        </div>
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys58")%></div>
    <div>
        <asp:textbox class="formfield" id="ccnoc" runat="server" />
    </div>
    <!-- END Credit Card Form -->
    <% End If%>
    <%Else%>
    <% End If%>
    <% If pd.clickterms = "ON" Then%>
    <div>
        <br><span class="formheadings2">
            <%= pd.getsystext("sys136")%>&nbsp;</span>
        <% If pd.popuptype = "I" Then%>
        <%= pd.getButton("butts40", "", "javascript: showPopWin('popup_terms.aspx', 600, 500, null, true, false)", "")%>
        <% Else%>
        <%= pd.getButton("butts40", "", "javascript: showwindow('popup_terms.aspx', 600, 500, null)", "")%>
        <% End If%>
    </div>
    <div class="checkboxes_container">
        <asp:checkbox id="coterms" runat="server" class="checkboxes" />
        <%= pd.geterrtext("err74")%></div>
    <% End If%>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14","","","pageform")%></div>
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>
