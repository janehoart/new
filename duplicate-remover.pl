#!/usr/bin/env perl

use strict;
use warnings;
#use autodie;
use Getopt::Long;
use File::Copy;

my ($path, $target, $help);
my @files;
my %h;

Getopt::Long::GetOptions(              
      'path|P=s'    => \$path,
      'target|T=s'  => \$target,
      'help|H!'	    => \$help,
);
$help||='0';

my $name=__FILE__;
sub help{
my $string=<<"HERE";

    脚本剔除源目录中相同的文件，复制目标文件到目标目录中
    使用方法:
	--path|-P: 指定源目录
	--target|-T: 指定目标目录
	--help|-H: 使用方法
    例子:
    $name --path|-P <PATH> --target|-T <TARGETPATH>
    $name --path /home/user/pic --target /home/user/tarpic
    $name --help|-H

HERE
    print "$string";
    exit;
}

if(($help == 1) || (!$path && !$target)){
    help;
}
if(!$path || !$target){
    print "请指定源目录或者目标目录！\n";
    exit;
}
if(!-e $path){
    print "没有这个源目录，请重新指定。\n";
    exit;
}elsif(!-e $target){
    print "不存在目标目录，现在创建。\n";
    mkdir($target,0755)||die "mkdir: $target: $!\n";
}

 
opendir(TD,$path) or die "$!\n";
@files=grep {!/^\./} readdir TD;

my ($pri,$sec,$suffix);
my %hash;

my $mytxt="$target/myinfo.txt";
open(OH,">>","$mytxt") or die "$!\n";
for(@files){
    my $size=-s "$path/$_";
    if($_=~m/(\S+[^P\s])(P?.*\.)(jpe?g)/){
	($pri,$sec,$suffix)=$_=~m/(\S+[^P\s])(P?.*\.)(jpe?g)/;
    }else{
	print OH "$_ faild\n";
    }
    $h{$pri}{$sec}=$size;
    $hash{$pri}=1;
}

open(FF,">>","yourinfo.txt") or die "$!\n";
while(my($key,$value)=each %hash){
    print FF "$key\n";
}

my %H;
foreach my $key1 (keys %h){
    my $hash2=$h{$key1};
    foreach my $key2 (sort{$hash2->{$a}<=>$hash2->{$b}} keys %$hash2){
	#print $key1."\t".$key2."\t".$hash2->{$key2}."\n";
	$H{$key1}=$hash2->{$key2};
    }
}

my %HH;
foreach my $k (keys %H){
    foreach my $key1 (keys %h){
	my $hash2=$h{$key1};
	foreach my $key2 (sort{$hash2->{$a}<=>$hash2->{$b}} keys %$hash2){
	    if ( $key1 eq $k && $hash2->{$key2} == $H{$k} ){
		print "$key1: $H{$k}\n";
		$HH{"$path/$key1${key2}jpg"}="$key1.jpg";
	    }
	}
    }
}


#while(my($key,$value)=each %HH){
#    print "$key=>$value\n";
#
#}

print "现在开始复制文件到目标目录......\n";
while(my($key,$value)=each %HH){
    #print "$key, $target\n";
    #copy($key,$target) or print OH "copy $value failed\n";
    print "$key, $target/$value\n";
    copy($key,"$target/$value") or print OH "copy $key failed\n";
}

if (-f $mytxt and -z _){
    print OH "全部文件复制成功\n";
}
close(OH);
print "文件复制完成，请查看目标目录下的 $mytxt 查看是否有失败文件\n";
