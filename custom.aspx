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
    Public recid, headname, customcontent, custpglayout As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()
         
        'Checks your Shop Access/Checkout settings.
        pd.VerifyShopAccess()
        recid = pd.getrequest("recid")

        'Not Used
        If Not (Page.IsPostBack) Then
        End If

        'Get Custom Page from database
        If pd.checkInt(recid) = True Then
            pd.OpenDataReader("SELECT * FROM custompages WHERE id=" & recid)
        ElseIf pd.shoprewriteSql <> "" Then
            'Find record based on a friendly Url name instead of id
            pd.OpenDataReader("SELECT * FROM custompages WHERE " & pd.shoprewriteSql)
        Else
            pd.pdRedirect("default.aspx")
        End If
        
        If pd.ReadDataItem.Read Then
            recid = pd.ReadData("id")
            headname = pd.ReadData("headname")
            customcontent = pd.ReadData("description")
            custpglayout = pd.ReadData("pglayout")
            metatitle = pd.ReadData("metatitle")
            metakeyw = pd.ReadData("metakeyw")
            metadesc = pd.ReadData("metadesc")
        Else
            pd.CloseData()
            pd.pdRedirect("default.aspx")
        End If
        pd.CloseData()
        
        'Fix Urls in Description Html, Change Relative to Virtual
        customcontent = pd.makeurlsrelative(customcontent)

        'Set Search engine meta tags.
        If metatitle <> "" Then
            pd.pagetitle = metatitle
        End If
        If metakeyw <> "" Then
            pd.keywords = metakeyw
        End If
        If metadesc <> "" Then
            pd.sitedesc = metadesc
        End If
         
        If customcontent = "" Then
            'Indicates that page only contains dynamic content (1=Yes, 0=No)
            pd.dynamiccontentonly = 1
        End If

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(custpglayout)%>
<%  If pd.dynamiccontentonly <> 1 Then%>
<%= pd.startSection("custom" & recid)%>
<div>
    <%=customcontent%>
</div>
<%= pd.endSection()%>
<%  Else%>
<%  End If%>
<%=pd.getBottomHtml(custpglayout)%>
