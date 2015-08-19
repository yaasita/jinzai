#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use feature qw(say);

# Goal node
my $goal = "";

# 配列へ格納
my @map;
{
    open (my $fh, "<","data.txt") or die $!;
    my $i=0;
    while (<$fh>){
        chomp;
        my @line = split(//);
        my $char=0;
        for (@line){
            $map[$i][$char]={
                data => $_,
                status => "none",
                c => 0,
                h => 0,
                s => 0, 
                parent => ""
            };
            if ($map[$i][$char]->{data} eq "G"){
                $goal="${i}-$char";
            }
            $char++;
        }
        $i++;
    }
}
# スコア計算
sub next_node {
    my $start;
    my $r = 0;
    my @next;
    while ($r <= $#map){
        my $c = 0;
        for (@{$map[$r]}){
            $start = "$r-$c" if $_->{data} eq "S";
            push(@next, "$r-$c") if $_->{status} eq "open";
            $c++;
        }
        $r++;
    }
    my $score = sub {
        my ($r,$c) = split(/\-/,$_[0]);
        return $map[$r]->[$c]->{s};
    };
    if (@next > 0){
        @next = sort { $score->($a) <=> $score->($b) } @next;
        return $next[0];
    }
    else {
        return $start;
    }
}
sub open_node {
    my $calc = sub {
        my ($r,$c) = split(/\-/,$_[0]);
        my $op = $_[1];
        if ($op eq "up"){
            $r -= 1;
        }
        elsif ($op eq "down"){
            $r += 1;
        }
        elsif ($op eq "left"){
            $c -= 1;
        }
        elsif ($op eq "right"){
            $c += 1;
        }
        elsif ($op eq "base"){
            $map[$r]->[$c]->{status} = "close";
            return "";
        }
        my $node = $map[$r]->[$c];
        if ($node->{status} ne "none"){
            return "";
        }
        elsif ($node->{data} !~ / |G/ ){
            return "";
        }
        my $parent_cost = sub {
            my ($r,$c) = split(/\-/,$_[0]);
            return $map[$r]->[$c]->{c}+0;
        };
        my $distance = sub {
            my $r1 = shift;
            my $c1 = shift;
            my ($r2,$c2) = split(/\-/,$goal);
            return abs($r1-$r2) + abs($c1-$c2);
        };
        $map[$r]->[$c]->{status} = "open";
        $map[$r]->[$c]->{parent} = "$_[0]";
        $map[$r]->[$c]->{c}      = $parent_cost->($_[0])+1;
        $map[$r]->[$c]->{h}      = $distance->($r,$c);
        $map[$r]->[$c]->{s}      = $map[$r]->[$c]->{c} + $map[$r]->[$c]->{h};
        return $map[$r]->[$c]->{data};
    };
    for (qw/up down left right base/){
        if ( $calc->($_[0],$_) eq "G" ){
            return "G";
        }
    }
}
while (1){
    if (open_node(next_node()) eq "G"){
        last;
    }
}
# 後ろからゴールまで辿る
{
    my $parent = sub {
        my ($r,$c) = split(/\-/,$_[0]);
        return $map[$r]->[$c]->{parent};
    };
    my $s = $goal;
    my @path;
    while (1){
        if ($s !~ /\-/){
            last;
        }
        push (@path,$s);
        $s = $parent->($s);
    }
    my $write = sub {
        my ($r,$c) = split(/\-/,$_[0]);
        if ($map[$r][$c]->{data} eq " "){
            $map[$r][$c]->{data}= '$';
        }
    };
    for (@path){
        $write->($_);
    }
}
# 書き出し
for (@map){
    my $line = $_;
    print $_->{data} for @{$line};
    print "\n";
}
