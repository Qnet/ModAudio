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
    
        'If isnothing(pd) = False Then pd.PDShopError()
    
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
                  
        'For testing (must be in test mode), uncomment below to force a decline:
        'pd.sCcardno = "4222222222222"
        'pd.dOrdergrandtotal = 2.00
    
        If Not (Page.IsPostBack) Then
            dosubmit = "Yes"
        End If
    
        If Page.IsPostBack Then
    
            '------------------------------------------------------------
            '   Your Credit Card Processing Goes Here....
            '------------------------------------------------------------
             
            'Call Authorize.net Functions (if maximum number of attempts not exceeded)
            If pd.doTransactionCount() = "Pass" Then
                pd.Authorizenet()
            Else
                pd.formerror = pd.geterrtext("err65")
            End If
    
            'For Testing purposes... you can write the http webrequest response to page.
            'pd.write(pd.httpresponse)
    
            'Look at Authorize.net Response
            If pd.anresponse1 = "1" Or pd.anresponse1 = "4" Then
                'If the response from your processor is 'Approved'
                approved = "Yes"
            Else
                'All other responses
                approved = "No"
            End If
    
            'Populate the local variables with your Gateway Response
            'The Authorize.net Function automatically returns the following variables
    
            avsresponse = pd.anresponse6
            ccvresponse = pd.anresponse39
            approvalcode = pd.anresponse5
            trxreference = pd.anresponse7
            pd.formerror = pd.formerror & pd.anresponse4
    
            '------------------------------------------------------------
            '  Your credit card processing goes above...
            '------------------------------------------------------------
    
            'Handle Response
            If approved = "Yes" Then
    
                'Approved Transactions, save data and redirect to checkout5
                pd.OpenDataWriter("orders WHERE id=" & pd.FormatSqlText(orderid))
                pd.AddData("status", "New", "T")
                pd.AddData("downen", pd.downen, "N")
                pd.AddData("ccapproval", approvalcode, "T")
                pd.AddData("cctrxid", trxreference, "T")
    
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
                pd.pdRedirect("checkout5.aspx")
    
            Else
    
                'Authorize.net AVS Response
                Select Case avsresponse
                    Case "A"
                        avsmessage = "Address (Street) matches, ZIP does not."
                    Case "B"
                        avsmessage = "Address Information not provided for AVS check."
                    Case "E"
                        avsmessage = "AVS Error"
                    Case "G"
                        avsmessage = "Non-U.S. Card Issing bank."
                    Case "N"
                        avsmessage = "No match on Address (Street) or ZIP"
                    Case "P"
                        'avsmessage = "AVS not applicable for this transaction."
                    Case "R"
                        avsmessage = "Retry - System unavailable or timed out."
                    Case "S"
                        avsmessage = "Service not supported by issuer."
                    Case "U"
                        avsmessage = "Address information is unavailable."
                    Case "W"
                        avsmessage = "9 Digit ZIP matches, Address (Street) does not."
                    Case "X"
                        avsmessage = "Address (Street) and 9 Digit ZIP match."
                    Case "Y"
                        avsmessage = "Address (Street) and 5 Digit ZIP match."
                    Case "Z"
                        avsmessage = "5 digit ZIP matches, Address (Street) does not."
                    Case Else
                End Select
    
                'Authorize.net Card Code Response
                Select Case ccvresponse
                    Case "M"
                        codemessage = "Card Code Matched."
                    Case "N"
                        'codemessage = "Card Code Does not match."
                        codemessage = "Card Code or Expiration Date Does not match."
                    Case "P"
                        codemessage = "Card Code was not processed."
                    Case "S"
                        codemessage = "Card Code should be on card but was not indicated."
                    Case "U"
                        codemessage = "User was not certified for Card Code"
                    Case Else
                End Select
    
                pd.formerror = pd.formerror & "<br />" & avsmessage & "<br />" & codemessage
    
                'Allows Credit Card to be pre-populated when re-submitting
                pd.saveCookie("cc", "Y", 0)
                 
                'If recommended security options are enabled, remove card after failed processing!
                pd.OpenDataWriter("orders WHERE id=" & pd.FormatSqlText(orderid))
                If InStr(pd.nosave, "CCN") > 0 Then pd.AddData("ccardno", "", "T")
                pd.AddData("cccode", "", "T")
                pd.SaveData()
                 
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
    <form method="POST" action="processcc.aspx" name="pageform" id="pageform" runat="server">
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