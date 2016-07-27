<%@ Page Language="VB" Explicit="False" %>

<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Collections" %>
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
        pd.browserNoCache()
            
        Dim captnumber As String
        captnumber = Right(pd.getrandseq(), 6)
            
        'Handle Demo Mode
        If ConfigurationManager.AppSettings("demomode") = "ON" Then
            captnumber = "123456"
        End If
                        
        pd.savecookie("capt", pd.captchahash(captnumber), 0)

        Dim imgbitmap As New Bitmap(100, 45)
        Dim imgobj As Graphics = Graphics.FromImage(imgbitmap)
        Dim imgfont As New Font("Arial", 25, FontStyle.Bold, GraphicsUnit.Pixel)
        Dim imgshape As New Rectangle(0, 0, 100, 45)

        imgobj.FillRectangle(Brushes.LightGray, imgshape)
        imgobj.DrawString(captnumber, imgfont, Brushes.Black, 0, 10)

        Response.ContentType = "Image/jpeg"
        imgbitmap.Save(Response.OutputStream, System.Drawing.Imaging.ImageFormat.Jpeg)

        imgbitmap.Dispose()
        imgobj.Dispose()

    End Sub
     
     
    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        'If isnothing(pd) = False Then pd.UnloadPDAdmin()

    End Sub

</script>
