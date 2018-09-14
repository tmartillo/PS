# This script is to find all of the critical errors in check_mk.  This is site specific between the 3 check_mk installs - th 1/8/2018
# This one script can be used on all 3 check_MK servers.
# Todd Hammer 01092018

hn=`hostname`
if [ $hn = "ssiscackmk01" ]
then
        #echo ssiscackmk01
        ckuser=can
else
if [ $hn = "ssisbrckmk01" ]
then
        #echo ssisbrckmk01
        ckuser=latam
else
if [ $hn = "ssisusckmk01" ]
then
        #echo ssisusckmk01
        ckuser=us
fi
fi
fi

[ ! -e /tmp/critlist.txt ] || rm  /tmp/critlist.txt
for i in `/bin/su - $ckuser -c "cmk -l"`
do
echo $i
/bin/su - $ckuser -c "cmk -nv $i | grep CRIT >> /tmp/critlist.txt"
done
cat /tmp/critlist.txt | wc -l
