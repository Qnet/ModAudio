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
    Public message, errormessage, thekey, nexturl As String
    Public downmeth As Integer

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()

        'Get Download Key
        thekey = pd.getrequest("key")
        thekey2 = pd.getrequest("key2")

        'Open Database, check validity of Key
        If IsNumeric(thekey2) And IsNumeric(thekey) Then
            pd.OpenDataReader("SELECT orders.downen, orderdetail.downloads, orderdetail.expires, orderdetail.downloaded, orderdetail.itemno, orderdetail.downloaded, orderdetail.downdate, orderdetail.downtime, orderdetail.downip, orderdetail.expires FROM orderdetail INNER JOIN orders on orders.id=orderdetail.orderid WHERE orderdetail.digkey='" & pd.FormatSqlText(thekey) & "' AND orderdetail.id=" & thekey2)
        Else
            pd.pdRedirect("popup_codown.aspx?message=3")
        End If

        If pd.ReadDataItem.Read Then
            downloads = pd.ReadDataN("downloads")
            itemid = pd.ReadDataN("itemno")
            downen = pd.ReadDataN("downen")
            totaldown = pd.ReadDataN("downloaded")
            expires = pd.ReadData("expires")
            validkey = "Y"
        Else
            validkey = "N"
        End If
        pd.CloseData()

        'If key not valid
        If validkey = "N" Then
            pd.pdRedirect("popup_codown.aspx?message=3")
        End If

        'Check if download has been activated.
        If downen = 0 Then
            pd.pdRedirect("popup_codown.aspx?message=5")
        End If

        'Get file location
        pd.OpenDataReader("SELECT digfile, name FROM items WHERE id=" & itemid)
        If pd.ReadDataItem.Read Then
            digfile = pd.ReadData("digfile")
            itemname = Trim(pd.ReadData("name"))
        End If
        pd.CloseData()

        'Update Database
        pd.OpenDataWriter("orderdetail WHERE orderdetail.digkey='" & pd.FormatSqlText(thekey) & "'")
        If downloads > 0 Then

            pd.AddData("downloads", downloads - 1, "N")
            pd.AddData("downloaded", 1, "N")
            pd.AddData("downdate", DateTime.Now.ToShortDateString, "D")
            pd.AddData("downtime", DateTime.Now.ToLongTimeString, "T")
            pd.AddData("downip", Request.ServerVariables("REMOTE_ADDR"), "T")

            'Sets a 2 Day expiration
            pd.AddData("expires", DateTime.Now.AddDays(2).ToShortDateString, "D")

            'Sets a 4 Hour expiration (only supported when date format is mm-dd-yy)
            'pd.AddData("expires", DateTime.Now.AddHours(4).ToString, "T")

        Else
            'Allow additional downloads until link expires
            If System.DateTime.Now < Convert.ToDateTime(expires) Then
                'if downloaded more than 3 times
                If totaldown > 3 Then
                    pd.pdRedirect("popup_codown.aspx?message=1")
                End If
                pd.AddData("downloaded", totaldown + 1, "N")
            Else

                pd.pdRedirect("popup_codown.aspx?message=2")
            End If
        End If
        'Update Database
        pd.SaveData()


        'Get additional page setup info.
        pd.OpenSetupDataReader("setupxml", "setup")

        downmeth = pd.ReadDataN("downmeth")
        downfold = pd.ReadData("downfold")

        pd.CloseData()
         
        If Right(downfold, 1) <> "/" Then
            downfold = downfold & "/"
        End If

        'If Download Method is 'Stream'
        If downmeth = 0 Then

            'Initiate a download (folder,filename)
            pd.startDownload(downfold, digfile)

        End If
         
        'If Download Method is 'Stream'
        If downmeth = 2 Then

            'Initiate a download (folder,filename)
            pd.startDownloadChunks(downfold, digfile)

        End If
         

        'Create Next Download URL
        nexturl = downfold & digfile

    End Sub


    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
    <title>
        <%=pd.pagetitle%></title>
    <% If downmeth = 1 Then%>
    <meta http-equiv="refresh" content="0; URL=../<%=nexturl%>" />
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1252" />
    <%End If%>
    <link rel="stylesheet" type="text/css" href="shop-css.aspx" />
</head>
<body class="popupbody">
    <% = pd.startSection("heads24")%>
    <div>
        <div class="popupmessages">
            <%=pd.geterrtext("err54")%></div>
        <div class="popupmessages">
            If nothing happens after a few seconds, <a href="../<%=nexturl%>">click here</a>.</div>
    </div>
    <%= pd.endSection()%>
</body>
</html>
