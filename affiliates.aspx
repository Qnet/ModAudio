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
    Public refer, affildesc As String
    
    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)
    
        If IsNothing(pd) = False Then pd.PDShopError()
    
    End Sub
    
    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)
    
        pd = New PDshopFunctions()
        pd.LoadPDshop()
    
        'Check if already signed in
        affiliateuserid = pd.getcookie("afuid")
        If IsNumeric(affiliateuserid) Then
            pd.pdRedirect("affilstatus.aspx")
        End If
    
        'Get Affiliate program description
        pd.OpenSetupDataReader("otherxml", "misc")

        affildesc = pd.ReadData("affildesc")

        pd.CloseData()
    
    End Sub
    
    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)
    
        If IsNothing(pd) = False Then pd.UnLoadPDshop()
    
    End Sub

</script>
<%=pd.getTopHtml(pd.pg7)%>
<%= pd.startSection("heads10")%>
<div>
    <div>
        <%=affildesc%></div>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14", "", pd.shopsslurl & "affilcout1.aspx","")%></div>
</div>
<%= pd.endSection()%>
<%= pd.startSection("heads18")%>
<div>
    <div class="cartbuttons_container">
        <%=pd.getButton("butts2", "", pd.shopsslurl & "affilsignin.aspx","")%></div>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg7)%>
