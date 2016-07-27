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
    Public orderid, customerid, cartid As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        'Get Temp variables
        tempgid = pd.getcookie("gwidx")
        If InStr(tempgid, "|") > 0 Then
         
            temparr = Split(tempgid, "|")
            orderno = temparr(0)
            orderid = temparr(1)
            cartid = temparr(2)


            If IsNumeric(orderno) And IsNumeric(orderid) And IsNumeric(cartid) Then

                'Make sure there is sufficient info to log this person back in.
                pd.OpenDataReader("SELECT id, cartid FROM orders WHERE orders.orderno=" & orderno & " AND orders.id=" & orderid & " AND cartid='" & cartid & "'")
                If pd.ReadDataItem.Read Then
                    pd.saveCookie("orderid", orderid, 0)
                    pd.saveCookie("cartid", cartid, 0)
                    gidpass = "Y"
                End If
                pd.CloseData()
                 
  
                'Cancel Payment
                If gidpass = "Y" Then

                    pd.OpenDataWriter("orders WHERE id=" & orderid)
                    pd.AddData("status", "Incomplete", "T")
                    pd.AddData("cctype", "", "T")
                    pd.AddData("downen", 0, "N")
                    pd.SaveData()

                End If

            End If


        End If

        'If signed back in, continue.
        If gidpass = "Y" Then
            pd.removeCookie("gwidx")
            pd.pdRedirect("checkout4.aspx")
        End If

        'Not Used
        If Not (Page.IsPostBack) Then
        End If


    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg9)%>
<%= pd.startSection("heads7")%>
<div>
    <div class="messages2">
        <%=pd.geterrtext("err11")%></div>
    <br />
    <div class="formbuttons_container">
        <%=pd.getButton("butts6", "", "orderstatus.aspx","")%></div>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg9)%>
