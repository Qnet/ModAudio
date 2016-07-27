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
    Public customerid, gateway, authtest, authlogin, authtrankey, ppbusiness, ppcurrency, twocosid, pflogin, wplogin, wpcurrency, ppipnen, simalturlon, simalturl, lplogin, cototal As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()

        If Not (Page.IsPostBack) Then
        End If
         
        'Verify if can Checkout.
        If pd.hasCartItems() = "No" Then pd.pdRedirect("showcart.aspx")
        If pd.hasShipping() = "No" Then pd.pdRedirect("checkout3.aspx")

        'Get Ids
        orderid = pd.getcookie("orderid")
        cartid = pd.getcookie("cartid")

        'After calling the functions below, some Public Variables will then be available...
        pd.getOrderVariables("", orderid, cartid)

        'Save Temp variables for Gateway Return (Save Cookie for 1 day)
        pd.saveCookie("gwidx", pd.iOrderno & "|" & pd.iOrderid & "|" & cartid, 1)

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<html>
<head>
    <title></title>
    <link rel="stylesheet" type="text/css" href="shop-css.aspx" />
</head>
<body onload="document.getElementById('pageform').submit();">
    <!--

BELOW IS A SAMPLE FORM THAT CAN BE USED TO SEND YOUR CUSTOMER, ALONG WITH
ORDER DETAILS, TO YOUR PAYMENT GATEWAY.  SELECT "OTHER GATEWAY" IN PDADMIN
TO ENABLE THIS FORM.

USE THE FORM OR THE VARIABLES
BELOW HOWEVER YOUR GATEWAY SUGGESTS.  YOU CAN EVEN PASTE IN HTML FROM YOUR
GATEWAY, INSERTING THE VARIABLES AS NEEDED.  SEE THEIR DOCUMENTATION.

PLEASE NOTE: QUESTIONS REGARDING CUSTOM GATEWAY
INTEGRATION MAY NOT BE INCLUDED FREE SUPPORT SERVICES
THAT WE OFFER.

-->
    <!--
********************************************************
HTML FORM START ----  BELOW IS THE FORM TO MODIFY
********************************************************
-->
    <form method="post" action="https://YOUR-GATEWAY-URL-GOES-HERE.com/" id="pageform"
    name="pageform">
    <input type="hidden" name="merchant_number" value="123456" />
    <input type="hidden" name="Store Name" value="<%=pd.storename%>" />
    <input type="hidden" name="Order_Total" value="<%=pd.dOrdergrandtotal%>" />
    <input type="hidden" name="Order_Number" value="<%=pd.iOrderno%>" />
    <input type="hidden" name="Customer_ID" value="<%=customerid%>" />
    <input type="hidden" name="First_Name" value="<%=pd.sBillFirstname%>" />
    <input type="hidden" name="Last_Name" value="<%=pd.sBillLastname%>" />
    <input type="hidden" name="Address1" value="<%=pd.sBillStreet1%>" />
    <input type="hidden" name="Address2" value="<%=pd.sBillStreet2%>" />
    <input type="hidden" name="City" value="<%=pd.sBillCity%>" />
    <input type="hidden" name="State" value="<%=pd.sBillState%>" />
    <input type="hidden" name="Zip" value="<%=pd.sBillZip%>" />
    <input type="hidden" name="Country" value="<%=pd.sBillCountry%>" />
    <input type="hidden" name="Phone" value="<%=pd.sBillPhone%>" />
    <input type="hidden" name="Email" value="<%=pd.sBillEmail%>" />
    <input type="hidden" name="Ship_To_First_Name" value="<%=pd.sShipFirstname%>" />
    <input type="hidden" name="Ship_To_Last_Name" value="<%=pd.sShipLastname%>" />
    <input type="hidden" name="Ship_To_Company" value="" />
    <input type="hidden" name="Ship_To_Address1" value="<%=pd.sShipstreet1%>" />
    <input type="hidden" name="Ship_To_Address2" value="<%=pd.sShipstreet2%>" />
    <input type="hidden" name="Ship_To_City" value="<%=pd.sShipCity%>" />
    <input type="hidden" name="Ship_To_State" value="<%=pd.sShipstate%>" />
    <input type="hidden" name="Ship_To_Zip" value="<%=pd.sShipzip%>" />
    <input type="hidden" name="Ship_To_Country" value="<%=pd.sShipcountry%>" />
    <input type="hidden" name="cancel_url" value="<%=pd.shopsslurl%>gateway_cancel.aspx" />
    <input type="hidden" name="return_url" value="<%=pd.shopsslurl%>gateway_in.aspx" />
    <!-- BEGIN Visible portion of page -->
    <br />
    <br />
    <span class="messages3">
        <%=pd.geterrtext("err54")%></span>
    <br />
    <br />
    <%'=pd.getButton("butts14","","","pageform") %>
    <br />
    <br />
    <!-- END Visible portion of page -->
    </form>
    <!--
********************************************************
HTML FORM END  ----  ABOVE IS THE FORM TO MODIFY
********************************************************
-->
    <script language="javascript">
        {
            document.getElementById('pageform').submit();
        }
    </script>
</body>
</html>
