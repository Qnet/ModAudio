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
    Public gateway, authtest, authlogin, authtrankey, ppbusiness, ppcurrency, twocosid, pflogin, wplogin, wpcurrency, ppipnen, simalturlon, simalturl, lplogin, cototal As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        If Not (Page.IsPostBack) Then
        End If

        'Verify if can Checkout.
        If pd.hasCartItems() = "No" Then pd.pdRedirect("showcart.aspx")
        If pd.hasShipping() = "No" Then pd.pdRedirect("checkout3.aspx")
        If pd.shopdemomode = "Yes" Then pd.pdRedirect("gateway_demo.aspx")

        'Get Ids
        orderid = pd.getcookie("orderid")
        cartid = pd.getcookie("cartid")
        gateway = pd.getrequest("gateway")

        'Get Gateway settings
        pd.OpenSetupDataReader("setupxml", "gateway")

        authtest = pd.ReadData("authtest")
        authlogin = pd.ReadData("authlogin")
        authtrankey = pd.ReadData("authtrankey")
        ppbusiness = pd.ReadData("ppbusiness")
        ppcurrency = pd.ReadData("ppcurrency")
        twocosid = pd.ReadData("twocosid")
        pflogin = pd.ReadData("pflogin")
        wplogin = pd.ReadData("wplogin")
        wpcurrency = pd.ReadData("wpcurrency")
        ppipnen = pd.ReadData("ppipnen")
        simalturlon = pd.ReadData("simalturlon")
        simalturl = pd.ReadData("simalturl")
        lplogin = pd.ReadData("lplogin")

        pd.CloseData()

        'After calling the functions below, some Public Variables will then be available...
        pd.getOrderVariables("", orderid, cartid)

        'Get Cart Contents, used with 2CO Form
        If pd.sCctype = "2Checkout.com" Then
            orderdetail.DataSource = pd.bindorderdetail(cartid, orderid)
            orderdetail.DataBind()
        End If

        'Format WP total
        cototal = FormatNumber(pd.dOrdergrandtotal)
        cototal = Replace(cototal, ",", "")

        'Save Temp variables for Gateway Return (Save for 1 day)
        pd.saveCookie("gwidx", pd.iOrderno & "|" & pd.iOrderid & "|" & cartid, 1)

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
    <title></title>
    <link rel="stylesheet" type="text/css" href="shop-css.aspx" />
</head>
<body onload="document.getElementById('pageform').submit();">
    <!--Force browser out of frames, frames can interfere with gateway functions. -->
    <script language="javascript">
        if (top.location != self.location) { top.location = self.location }
    </script>
    <!-- BEGIN Visible portion of page -->
    <br />
    <br />
    <div class="messages3">
        <%=pd.geterrtext("err54")%></div>
    <br />
    <br />
    <%'=pd.getButton("butts14","","","pageform") %>
    <br />
    <br />
    <!-- END Visible portion of page -->
    <% If pd.sCctype = "PayPal" Then%>
    <!-- PayPal Payment Gateway -->
    <% If authtest = "ON" Then%>
    <form method="post" action="https://www.sandbox.paypal.com/cgi-bin/webscr" id="pageform"
    name="pageform">
    <% Else%>
    <form method="post" action="https://www.paypal.com/cgi-bin/webscr" id="pageform"
    name="pageform">
    <%End If%>
    <input type="hidden" name="cmd" value="_xclick">
    <input type="hidden" name="business" value="<%=ppbusiness%>">
    <input type="hidden" name="item_name" value="<%=pd.storename & " Order: " & pd.iOrderno %>">
    <input type="hidden" name="item_number" value="<%=pd.iOrderno%>">
    <input type="hidden" name="amount" value="<%=pd.dOrdergrandtotal%>">
    <input type="hidden" name="currency_code" value="<%=ppcurrency%>">
    <input type="hidden" name="first_name" value="<%=pd.sBillFirstName%>">
    <input type="hidden" name="last_name" value="<%=pd.sBillLastname%>">
    <input type="hidden" name="address1" value="<%=pd.sBillStreet1%>">
    <input type="hidden" name="address2" value="<%=pd.sBillStreet2%>">
    <input type="hidden" name="city" value="<%=pd.sBillCity%>">
    <input type="hidden" name="state" value="<%=pd.sBillState%>">
    <input type="hidden" name="zip" value="<%=pd.sBillZip%>">
    <input type="hidden" name="email" value="<%=pd.sBillEmail%>">
    <input type="hidden" name="phone" value="<%=pd.sBillPhone%>">
    <input type="hidden" name="bn" value="PageDownTech.PDshop">
    <input type="hidden" name="cancel_return" value="<%=pd.shopsslurl%>gateway_cancel.aspx">
    <% If ppipnen = "ON" Then%>
    <input type="hidden" name="custom" value="<%=pd.iOrderid%>">
    <input type="hidden" name="notify_url" value="<%=pd.shopsslurl%>gateway_ppipn.aspx">
    <% End If%>
    <input type="hidden" name="return" value="<%=pd.shopsslurl%>gateway_in.aspx">
    <input type="hidden" name="no_shipping" value="1">
    <input type="hidden" name="no_note" value="1">
    </form>
    <%End If%>
    <% If pd.sCctype = "PayFlow" Then%>
    <!-- Verisign PayFlow Link Gateway -->
    <form method="POST" action="https://payflowlink.paypal.com" name="pageform" id="pageform">
    <!--<input type="hidden" name="MFCIsapiCommand" value="Orders">-->
    <input type="hidden" name="LOGIN" value="<%=pflogin%>">
    <input type="hidden" name="PARTNER" value="VeriSign">
    <input type="hidden" name="AMOUNT" value="<%=pd.dOrdergrandtotal%>">
    <input type="hidden" name="TYPE" value="AUTH_CAPTURE">
    <input type="hidden" name="DESCRIPTION" value="<%=pd.storename & " Order: " & pd.iOrderno %>">
    <input type="hidden" name="NAME" value="<%=pd.sBillName%>">
    <input type="hidden" name="ADDRESS" value="<%=pd.sBillStreet1%>">
    <input type="hidden" name="CITY" value="<%=pd.sBillCity%>">
    <input type="hidden" name="STATE" value="<%=pd.sBillState%>">
    <input type="hidden" name="ZIP" value="<%=pd.sBillZip%>">
    <input type="hidden" name="COUNTRY" value="<%=pd.sBillCountry%>">
    <input type="hidden" name="ADDRESSTOSHIP" value="<%=pd.sShipstreet1%>">
    <input type="hidden" name="CITYTOSHIP" value="<%=pd.sShipcity%>">
    <input type="hidden" name="STATETOSHIP" value="<%=pd.sShipstate%>">
    <input type="hidden" name="ZIPTOSHIP" value="<%=pd.sShipzip%>">
    <input type="hidden" name="COUNTRYTOSHIP" value="<%=pd.sShipcountry%>">
    <input type="hidden" name="PHONE" value="<%=pd.sBillPhone%>">
    <input type="hidden" name="EMAIL" value="<%=pd.sBillEmail%>">
    </form>
    <%End If%>
    <% If pd.sCctype = "2Checkout.com" Then%>
    <!-- 2Checkout Gateway -->
    <form method="post" action="https://www2.2checkout.com/2co/buyer/purchase" id="pageform"
    name="pageform">
    <input type="hidden" name="sid" value="<%=twocosid%>">
    <input type="hidden" name="total" value="<%=cototal%>">
    <input type="hidden" name="cart_order_id" value="<%=pd.iOrderno%>">
    <input type="hidden" name="card_holder_name" value="<%=pd.sBillName%>">
    <input type="hidden" name="street_address" value="<%=pd.sBillStreet1%>">
    <input type="hidden" name="city" value="<%=pd.sBillCity%>">
    <input type="hidden" name="state" value="<%=pd.sBillState%>">
    <input type="hidden" name="zip" value="<%=pd.sBillZip%>">
    <input type="hidden" name="country" value="<%=pd.sBillCountry%>">
    <input type="hidden" name="email" value="<%=pd.sBillEmail%>">
    <input type="hidden" name="phone" value="<%=pd.sBillPhone%>">
    <!-- DEMO MODE -->
    <% If authtest = "ON" Then%>
    <input type="hidden" name="demo" value="Y">
    <%End If%>
    <!-- new V2 Parameters -->
    <input type="hidden" name="id_type" value="1">
    <!-- Product Details -->
    <asp:Repeater ID="orderdetail" runat="server">
        <ItemTemplate>
            <input type="hidden" name="c_prod_<%# Container.DataItem("count") %>" value="<%# Container.DataItem("itemno") %>">
            <input type="hidden" name="c_name_<%# Container.DataItem("count") %>" value="<%# Container.DataItem("itemname") %>">
            <input type="hidden" name="c_description_<%# Container.DataItem("count") %>" value="<%# Container.DataItem("shortdesc") %>">
            <input type="hidden" name="c_price_<%# Container.DataItem("count") %>" value="<%# Container.DataItem("pricetotalnumber") %>">
        </ItemTemplate>
    </asp:Repeater>
    </form>
    <%End If%>
    <% If pd.sCctype = "WorldPay" Then%>
    <!-- Worldpay Gateway -->
    <form action="https://select.worldpay.com/wcc/purchase" method="POST" name="pageform"
    id="pageform">
    <input type="hidden" name="instId" value="<%=wplogin%>">
    <input type="hidden" name="cartId" value="<%=pd.iOrderno%>">
    <input type="hidden" name="amount" value="<%=cototal%>">
    <input type="hidden" name="currency" value="<%=wpcurrency%>">
    <input type="hidden" name="desc" value="<%=pd.storename & " Order: " & pd.iOrderno %>">
    <% If authtest = "ON" Then%>
    <input type="hidden" name="testMode" value="100">
    <%End If%>
    <input type="hidden" name="name" value="<%=pd.sBillName%>">
    <input type="hidden" name="address" value="<%=pd.sBillStreet1%>, <%=pd.sBillStreet2%>, <%=pd.sBillCity%>, <%=pd.sBillState%>">
    <input type="hidden" name="postcode" value="<%=pd.sBillZip%>">
    <input type="hidden" name="country" value="<%=pd.sCountrycode%>">
    <input type="hidden" name="tel" value="<%=pd.sBillPhone%>">
    <input type="hidden" name="email" value="<%=pd.sBillEmail%>">
    </form>
    <%End If%>
    <% If pd.sCctype = "LinkPoint" Then%>
    <!-- LinkPoint Gateway -->
    <% If authtest = "ON" Then%>
    <form action="https://www.staging.linkpointcentral.com/lpc/servlet/lppay" method="POST"
    name="pageform" id="pageform">
    <%Else%>
    <form action="https://www.linkpointcentral.com/lpc/servlet/lppay" method="POST" name="pageform"
    id="pageform">
    <%End If%>
    <input type="hidden" name="mode" value="payplus">
    <input type="hidden" name="txntype" value="sale">
    <input type="hidden" name="chargetotal" value="<%=pd.dOrdergrandtotal%>">
    <input type="hidden" name="storename" value="<%=lplogin%>">
    <input type="hidden" name="oid" value="<%=pd.iOrderno%>">
    <input type="hidden" name="bname" value="<%=pd.sBillName%>">
    <input type="hidden" name="baddr1" value="<%=pd.sBillStreet1%>">
    <input type="hidden" name="baddr2" value="<%=pd.sBillStreet2%>">
    <input type="hidden" name="bcity" value="<%=pd.sBillCity%>">
    <% If pd.sBillcountry = "United States" Then%>
    <input type="hidden" name="bstate" value="<%=pd.sBillState%>">
    <% End If%>
    <input type="hidden" name="bzip" value="<%=pd.sBillZip%>">
    <input type="hidden" name="email" value="<%=pd.sBillEmail%>">
    <input type="hidden" name="saddr1" value="<%=pd.sShipstreet1%>">
    <input type="hidden" name="saddr2" value="<%=pd.sShipstreet2%>">
    <input type="hidden" name="sBillCity" value="<%=pd.sShipcity%>">
    <% If pd.sBillcountry = "United States" Then%>
    <input type="hidden" name="sBillState" value="<%=pd.sShipstate%>">
    <% End If%>
    <input type="hidden" name="phone" value="<%=pd.sBillPhone%>">
    </form>
    <%End If%>
    <script language="javascript">
        {
            document.getElementById('pageform').submit();
        }
    </script>
</body>
</html>
