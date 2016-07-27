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
        pd.browserNoCache()
        pd.LoadPDshop()

        cartid = pd.getcookie("cartid")
        orderid = pd.getcookie("orderid")
        pptoken = pd.getcookie("pptoken")

        'Get customer/order variables
        pd.getOrderVariables("", orderid, cartid)

        If pd.iItemcount > 0 And pd.dOrdergrandtotal > 0 Then
            If pptoken <> "" Then pd.pdRedirect("paypal_express2.aspx")
        Else
            pd.pdRedirect("showcart.aspx")
        End If

        'Cleanup Before Proceeding (if already started checkout, abandon it.)
        pd.removeCookie("tkid")
        pd.removeCookie("customerid")
        pd.removeCookie("orderid")

        'Initialize PayPal
        pd.getgatewayoptions()

        If pd.setPayPalExpressCheckout() = "Success" Then

            'Create Order
            pd.OpenDataWriter("orders")

            'Temporarily store Token & CartID in order
            pd.AddData("cctrxid", pd.pptoken, "T")
            pd.AddData("cartid", pd.getcookie("cartid"), "T")

            'Temporarily tag if this is a "Mark Flow" transaction
            If Len(pd.sShipName) > 0 Then
                pd.AddData("ccapproval", "Mark", "T")
            End If

            pd.AddData("orderdate", pd.showdate(DateTime.Now.ToShortDateString), "D")
            pd.AddData("ordertime", DateTime.Now.ToLongTimeString, "T")
            pd.AddData("status", "Incomplete", "T")
            pd.AddData("ipaddr", Request.ServerVariables("REMOTE_ADDR"), "T")
            pd.AddData("customerid", 0, "N")
            pd.AddData("orderno", pd.getorderno(), "N")
            pd.AddData("shipresdel", 1, "N")
            pd.AddData("ratemethod", 0, "N") 'Signifies that shipping step not completed.
            pd.AddData("affillink", pd.getcookie("affillink"), "T")

            'Apply Discounts & Gift Cert. to order
            If pd.getcookie("disc") <> "" Then
                discarr = Split(pd.getcookie("disc"), "|")
                pd.AddData("discpct", Convert.ToDecimal(discarr(2)), "N")
                pd.AddData("discamt", Convert.ToDecimal(discarr(1)), "N")
                pd.AddData("disccode", discarr(0), "T")
            Else
                pd.AddData("discpct", 0, "N")
                pd.AddData("discamt", 0, "N")
                pd.AddData("disccode", "", "T")
            End If
            If pd.getcookie("gift") <> "" Then
                giftarr = Split(pd.getcookie("gift"), "|")
                pd.AddData("giftcode", giftarr(0), "T")
                pd.AddData("giftamt", Convert.ToDecimal(giftarr(1)), "N")
            Else
                pd.AddData("giftcode", "", "T")
                pd.AddData("giftamt", 0, "N")
            End If


            pd.SaveData()

            'Send Customer to PayPal to Make Payment
            pd.gotoPayPalExpressUrl()

        Else

        End If


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

    <div class="formbuttons_container">
        <%=pd.getButton("butts13", "", "checkout1.aspx","")%></div>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>
