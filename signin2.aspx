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
    Public task, refer As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.browserNoCache()
        pd.LoadPDshop()

        'Make sure site has two domains before continuing
        If pd.shopurlsame = "Yes" Then
            pd.pdRedirect(pd.shopsslurl & "signin.aspx")
        End If
        
        'Check for customerid & possible sign-out task.
        task = pd.getrequest("task")
        refer = pd.getrequest("refer")

        'Handle Task on domain before returning
        If task = "return" Then
         
            'Process the Sign In/Out
            pd.signInTransfer()
            
            'Default Refer
            If refer = "" Then refer = "orderstatus.aspx"

            'If Signin after WishList, do not go back to SSL
            If refer = "wlistcart.aspx" Then pd.pdRedirect(refer)
            If refer = "wlistsearch.aspx?mylist=Y" Then pd.pdRedirect(refer)
            If refer = "writeareview.aspx" Then pd.pdRedirect(refer)
             
        End If

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
    <title></title>
    <link rel="stylesheet" type="text/css" href="shop-css.aspx" />
</head>
<body onload="document.getElementById('siForm').submit();">
    <center>
        <% If task = "signin" Then%>
        <form method="post" action="<%=pd.shopurl%>signin2.aspx" id="siForm" name="siForm">
        <input type="hidden" name="customerid" value="<%=pd.getcookie("customerid")%>" />
        <input type="hidden" name="siauth" value="<%=pd.getRequest("siauth")%>" />
        <input type="hidden" name="refer" value="<%=pd.dohtmlencode(refer)%>" />
        <input type="hidden" name="task" value="return" />
        <br />
        <br />
        <div class="messages3">
            <%=pd.geterrtext("err54")%></div>
        <br />
        <br />
        </form>
        <%End If%>
        <% If task = "signout" Then%>
        <form method="post" action="<%=pd.shopurl%>signin2.aspx" id="siForm" name="siForm">
        <input type="hidden" name="refer" value="signin.aspx" />
        <input type="hidden" name="task" value="return" />
        <br />
        <br />
        <div class="messages3">
            <%=pd.geterrtext("err54")%></div>
        <br />
        <br />
        </form>
        <%End If%>
        <% If task = "return" Then%>
        <form method="post" action="<%=pd.shopsslurl%><%=refer%>" id="siForm" name="siForm">
        <br />
        <br />
        <div class="messages3">
            <%=pd.geterrtext("err54")%></div>
        <br />
        <br />
        </form>
        <%End If%>
        <script language="javascript">
            {
                document.getElementById('siForm').submit();
            }
        </script>
    </center>
</body>
</html>
