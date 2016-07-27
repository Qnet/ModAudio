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
    Public dosubmit, approvalcode, trxreference, processingerror, avsmessage, codemessage As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        'Verify if can Checkout.
        If pd.hasCartItems() = "No" Then pd.pdRedirect("showcart.aspx")
        If pd.hasOrder() = "No" Then pd.pdRedirect("checkout2.aspx")

        'Get Ids
        cartid = pd.getcookie("cartid")
        orderid = pd.getcookie("orderid")
        dosubmit = pd.getrequest("dosubmit")

        'After calling the functions below, some Public Variables will then be available...
        pd.getOrderVariables("", orderid, cartid)

        If Not (Page.IsPostBack) Then
            dosubmit = "Yes"
        End If

        If Page.IsPostBack Then

            'Initialize PayPal
            pd.getgatewayoptions()
             
            'Check if Maximum number of attempts has been reached.
            If pd.doTransactionCount() = "Pass" Then

                'Process Payment
                ppresponse = pd.doPayPalDirectPayment()
                If ppresponse = "Success" Or ppresponse = "SuccessWithWarning" Then

                    'Approved Transactions, save data and redirect to checkout5
                    pd.OpenDataWriter("orders WHERE id=" & pd.FormatSqlText(orderid))
                    pd.AddData("status", "New", "T")
                    pd.AddData("downen", pd.downen, "N")
                    pd.AddData("ccapproval", "Direct", "T")
                    pd.AddData("cctrxid", pd.sCctrxid, "T")

                    'If recommended security options are enabled, remove card after processing!
                    If InStr(pd.nosave, "CCN") > 0 Then pd.AddData("ccardno", "", "T")
                    If pd.savecardcodes <> "ON" Then pd.AddData("cccode", "", "T")

                    'Save
                    pd.SaveData()

                    'Finalize Order, adjust inventory, create download keys
                    pd.updateinventory(orderid)

                    'Update Gift Certificate upon redemption (if applicable)
                    pd.updategcstatus(orderid)
                    pd.finalizegc(orderid)
                    
                    'Auth/Capture Tax Cloud
                    pd.dotaxcloudauth(orderid)

                    pd.removeCookie("cc")

                    'Save PayPal Transaction ID (to display on next page)
                    pd.saveCookie("pptrx", pd.sCctrxid, 0)
                    pd.pdRedirect("checkout5.aspx")

                Else

                    'Allows Credit Card to be pre-populated when re-submitting
                    pd.saveCookie("cc", "Y", 0)
                     
                    'If recommended security options are enabled, remove card after failed processing!
                    pd.OpenDataWriter("orders WHERE id=" & pd.FormatSqlText(orderid))
                    If InStr(pd.nosave, "CCN") > 0 Then pd.AddData("ccardno", "", "T")
                    pd.AddData("cccode", "", "T")
                    pd.SaveData()
                     

                End If
            Else
                'If Maximum number of attempts reached.
                pd.formerror = pd.geterrtext("err65")
             
            End If

        End If


    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%  If dosubmit = "Yes" Then%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
    <title></title>
    <link rel="stylesheet" type="text/css" href="shop-css.aspx" />
</head>
<body onload="document.getElementById('pageform').submit();">
    <!-- Form used to submit... Displays the Please Wait while processing... -->
    <form method="POST" action="processcc_paypal.aspx" name="pageform" id="pageform"
    runat="server">
    <input type="hidden" name="dosubmit" value="No" />
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
    </form>
    <script language="javascript">
        {
            document.getElementById('pageform').submit();
        }
    </script>
</body>
</html>
<%  Else%>
<%=pd.getTopHtml(pd.pg9)%>
<%= pd.startSection("heads7")%>
<div><!-- Displayed if Credit Card is declined -->
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14","","checkout4.aspx","")%></div>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>
<%  End If%>
