<%@ Page Language="VB" Explicit="False" %>
<%@ Import Namespace="System.Xml" %>
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
        pd.LoadPDshop()

        'cartid = pd.getcookie("cartid")

        If Not (Page.IsPostBack) Then
        End If

        'Get Payment Gateway options, check if Google enabled.
        pd.getgatewayoptions()
      
        If pd.getform("serial-number") <> "" Then

            'Send Google an acknowledgment
            Response.Write("<notification-acknowledgment xmlns=""http://checkout.google.com/schema/2"" serial-number=""" & pd.dohtmlencode(pd.getform("serial-number")) & """ />")
            
            'Process Order Notifications (New Orders)
            If pd.doGoogleOrderNotification(pd.getform("serial-number")) = True Then
                
                'Create New order from Google New Order Notification
                pd.OpenDataWriter("orders")
                      
                'Address Details
                pd.AddData("billname", pd.sbillName, "T")
                pd.AddData("billstreet1", pd.sbillStreet1, "T")
                pd.AddData("billstreet2", pd.sbillStreet2, "T")
                pd.AddData("billstate", pd.sbillState, "T")
                pd.AddData("billcity", pd.sBillCity, "T")
                pd.AddData("billcountry", pd.sBillCountry, "T")
                pd.AddData("billzip", pd.sbillZip, "T")
                pd.AddData("billemail", pd.sbillEmail, "T")
                pd.AddData("billphone", pd.sbillPhone, "T")
                pd.AddData("shipname", pd.sShipName, "T")
                pd.AddData("shipstreet1", pd.sShipstreet1, "T")
                pd.AddData("shipstreet2", pd.sShipstreet2, "T")
                pd.AddData("shipstate", pd.sShipstate, "T")
                pd.AddData("shipcity", pd.sShipcity, "T")
                pd.AddData("shipcountry", pd.sShipcountry, "T")
                pd.AddData("shipzip", pd.sShipzip, "T")
                
                'Other Details
                pd.AddData("ccnoc", "", "T")
                pd.AddData("cctype", "Google Checkout", "T")
                pd.AddData("salestax", pd.gettaxrate(pd.sShipstate, pd.sShipcountry), "N")
                pd.AddData("taxship", pd.sTaxship, "T") 'must proceed gettaxrate.            
                pd.AddData("cartid", pd.sCartid, "T")
                pd.AddData("ccapproval", "", "T")
                pd.AddData("cctrxid", pd.sCctrxid, "T")
                pd.AddData("tracking", "", "T")
                pd.AddData("downen", pd.downen, "N")
                pd.AddData("status", "New", "T")
                pd.AddData("orderdate", pd.showdate(DateTime.Now.ToShortDateString), "D")
                pd.AddData("ordertime", DateTime.Now.ToLongTimeString, "T")
                pd.AddData("ipaddr", "", "T")
                pd.AddData("customerid", 0, "N")
                pd.iOrderno = pd.getorderno()
                pd.AddData("orderno", pd.iOrderno, "N")
                pd.AddData("shipresdel", 1, "N")
                pd.AddData("affillink", "", "T")
                pd.AddData("discpct", pd.dDiscpct, "N")
                pd.AddData("discamt", pd.dDiscamt, "N")
                pd.AddData("disccode", pd.sDisccode, "T")
                pd.AddData("carriername", pd.sCarriername, "T")
                pd.AddData("carrierrate", pd.dCarrierrate, "N")
                pd.AddData("ratemethod", 1, "N")
                orderid = pd.SaveData()
            
                'Order Cleanup
                pd.linkorderdetail(pd.sCartid, "", orderid)
                
                'Update inventory and create download keys.
                pd.updateinventory(orderid)

                'Finalize Gift Certificat if buying a GC
                pd.finalizegc(orderid)

                'Update Gift Certificate upon redemption (if applicable)
                pd.updategcstatus(orderid)
                
                
                'Send Emails                
                pd.OpenSetupDataReader("otherxml", "email")

                confemail = pd.ReadData("confemail")
                emailfrom1 = pd.ReadData("emailfrom1")
                emailfromname1 = pd.ReadData("emailfromname1")
                emailsubject1 = pd.ReadData("emailsubject1")
                emailbody1 = pd.ReadData("emailbody1")
                notifyadmin = pd.ReadData("notifyadmin")
                orderemailto = pd.ReadData("orderemailto")
                orderemailcc = pd.ReadData("orderemailcc")

                pd.CloseData()
                
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
                    pd.Sendemail(emailto, "", emailfrom, emailfromname, emailsubject, emailbody, "Text", "")

                End If

                'Send Admin Notification Email
                If notifyadmin = "ON" Then

                    emailto = orderemailto
                    emailcc = orderemailcc
                    emailtoname = "Admin"
                    emailfrom = pd.emailadmin
                    emailfromname = pd.storename
                    emailsubject = pd.storename & " - Order Notification"
                    emailbody = "New Order has arrived!" & vbCrLf & "Order Number: " & pd.iOrderno & vbCrLf & "LINK: " & pd.getadminorderlink(orderid)

                    'Arguments(semailto,semailfrom,semailsubject,semailbody,semailformat,semailattachment)
                    pd.Sendemail(emailto, emailcc, emailfrom, emailfromname, emailsubject, emailbody, "Text", "")

                End If
                
                
            End If
            
            
        End If
        
    End Sub



    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub
    
    
    
</script>