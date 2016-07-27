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
    Public discountmessage, giftmessage As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()
         
        'Checks your Shop Access/Checkout settings.
        pd.VerifyShopAccess()

        If Not (Page.IsPostBack) Then
        End If

        'Get Task
        task = pd.getrequest("task")
        updatedisc = pd.getrequest("updatedisc")
        updategift = pd.getrequest("updategift")

        'Get WishList ID, use customerid for cartid db field.
        cartid = pd.getcookie("customerid")

        'Check if signed in.
        If Not IsNumeric(cartid) Then
            pd.saveCookie("wlistaddid", pd.getrequest("itemid"), 0)
            pd.pdRedirect(pd.shopsslurl & "signin.aspx?refer=wlistcart.aspx")
        End If

        'If returning after sigin-in
        If IsNumeric(pd.getcookie("wlistaddid")) Then
            itemid = pd.getcookie("wlistaddid")
            pd.removeCookie("wlistaddid")
            pd.pdRedirect("wlistcart.aspx?task=addnew&qty=1&itemid=" & itemid)
        End If

        'Add to Cart
        If task = "addnew" Then
            'Delete Record first if changed.
            If IsNumeric(pd.getrequest("edititemid")) Then
                pd.deletewishlistitem(pd.getrequest("edititemid"))
            End If
            pd.additemtowishlist(cartid)
        End If

        'Delete Cart Item
        If task = "delete" Then
            pd.deletewishlistitem(pd.getrequest("recid"))
        End If

        'Return to WishList View/Search Page
        pd.pdRedirect("wlistsearch.aspx?mylist=Y")

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg11)%>
<%=pd.getBottomHtml(pd.pg11)%>
