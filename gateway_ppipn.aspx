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
    Public orderid, cartid, authtest As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()

        'Get Gateway and Email settings
        pd.OpenSetupDataReader("setupxml", "gateway")

        authtest = pd.ReadData("authtest")
        ppipnen = pd.ReadData("ppipnen")
             
        pd.CloseData()
 
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
         
         
        'If IPN Enabled
        If ppipnen = "ON" And pd.gatewayen = "ON" Then

            'Verify PayPal IPN Response
            Dim stringPost = Request.Form.ToString & "&cmd=_notify-validate"

            If authtest = "ON" Then
                stringResult = pd.httppost("https://www.sandbox.paypal.com/cgi-bin/webscr", stringPost)
            Else
                stringResult = pd.httppost("https://www.paypal.com/cgi-bin/webscr", stringPost)
            End If

            'Capture PayPal Data
            orderid = pd.getrequest("custom")
            paystatus = pd.getrequest("payment_status")
            payamount = pd.getrequest("mc_gross")
            paycurrency = pd.getrequest("mc_currency")
            trxid = pd.getrequest("txn_id")
            siteemail = pd.getrequest("receiver_email")
            custemail = pd.getrequest("payer_email")
            
            'For Testing purposes, writes IPN data to export folder for troubleshooting.
            'pd.logdata("IPN-Received-", stringPost)
            'pd.logdata("IPN-VerifyResponse-", stringResult)
            
        End If

        'If Verified...
        If stringResult = "VERIFIED" And IsNumeric(orderid) Then

            'Record Details
            pd.OpenDataReader("SELECT orderno, notes, status FROM orders WHERE id=" & orderid)
            If pd.ReadDataItem.Read Then
                oldnotes = pd.ReadData("notes")
                orderno = pd.ReadData("orderno")
                currstatus = pd.ReadData("status")
            End If
            pd.CloseData()

            'If order status is Incomplete (the waiting status for IPN).
            If currstatus = "Incomplete" Then


                newnotes = oldnotes & vbCrLf & "-" & pd.showdate(DateTime.Now.ToShortDateString) & " PayPal IPN: " & custemail & " Amount: " & payamount & paycurrency & " IPN Status: " & tempstatus & " " & paystatus
                pd.OpenDataWriter("orders WHERE id=" & orderid)
                pd.AddData("downen", pd.downen, "N")
                pd.AddData("status", "New", "T")
                pd.AddData("notes", newnotes, "T")
                pd.AddData("cctrxid", trxid, "T")
                pd.AddData("ccapproval", paystatus, "T")
                pd.SaveData()

                If paystatus = "Completed" Or paystatus = "Pending" Then

                    'After calling the functions below, some Public Variables will then be available...
                    pd.getOrderVariables("", orderid, cartid)

                    'Update inventory and create download keys.
                    pd.updateinventory(orderid)

                    'Finalize Gift Certificat if buying a GC
                    pd.finalizegc(orderid)

                    'Update Gift Certificate upon redemption (if applicable)
                    pd.updategcstatus(orderid)
                    
                    'Auth/Capture Tax Cloud
                    pd.dotaxcloudauth(orderid)

                    'Send Emails
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


        Else

        End If


    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
