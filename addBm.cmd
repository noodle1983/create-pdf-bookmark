"C:\Perl\bin\perl" gen_bm_xml.pl input.txt 0
echo "c:\strawberry\perl\bin\perl.exe -MEncode -pi.bak -e "$_= encode("utf8", decode(gbk=>$_))" bookmark.xml"
.\PdfBookmark_c  -iold.pdf -onew.pdf -xbookmark.xml
pause