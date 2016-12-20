use Net::Telnet;
use Term::ReadKey;
use Data::Dumper;
use Switch;


$failphrase = "0 packets received";
print "\033[2J";    #clear the screen
print "\033[0;0H"; #jump to 0,0
print "What is your TACACS username: ";
my $username = <STDIN>;
chomp $username;
#$username = "dsievers";
print "What is your TACACS password: ";
ReadMode('noecho');
my $password = ReadLine(0);
ReadMode('restore');
#$password = "";
print "\nSelect you cable-mac (enter number only): ";
my $cableMac = <STDIN>;
chomp $cableMac;
print "Do you wish to ping IPv4, IPv6, or ALL IP addresses (enter 4, 6, or A): ";
my $pingchoice = <STDIN>;
chomp $pingchoice;

$arris_cmts = "172.31.17.66";



$telnet = new Net::Telnet (	Prompt => '/[\$%#>] $/',
							Timeout => 30);
$telnet->open("$arris_cmts");
$line = $telnet->lastline;
print $line;
$telnet->login($username, $password);
$telnet->cmd('terminal length 0');

print @scmcmac = $telnet->cmd("scm cable-mac $cableMac | include Operational");
pop @scmcmac;
map {$_ = $_} (@scmcmac);
foreach $scmcmac(@scmcmac) {
	#@fields = split /\S\S\S\S\.\S\S\S\S\.\S\S\S\S\s\s/, $scmcmac;
	@fields = split /\s+/, $scmcmac;
	$ip = pop @fields;
	$ip =~ s/\s*$//;
	$mac = pop @fields;
	$mac =~ s/\s*$//;
	push @allipaddresses, $ip;
	push @allmacaddresses, $mac;
}

@ipv6addresses = grep ( /\:/, @allipaddresses);
@ipv4addresses = grep ( /\./, @allipaddresses);
my %macandip;
@macandip{@allmacaddresses} = @allipaddresses;


print "\033[2J";    #clear the screen
print "\033[0;0H"; #jump to 0,0
print "NOW PAUSING SCRIPT WHILE USER ISSUES COMMANDS ON OTHER NETWORK DEVICE\n\n";
print "All current MAC and IP addresses on cable-mac $cableMac have been stored into memory. From\n";
print "this point on, no additional MAC or IP addresses will be obtained from cable-mac $cableMac.\n";
print "Once you press enter this script will begin pinging your selected modems.\n";
print "Please note that this script only targets modems in the \"Operational State\"\n\n";
print "(press enter to continue)";
<STDIN>;
print "\033[2J";    #clear the screen
print "\033[0;0H"; #jump to 0,0
print "########## OUTPUT FOR CMTS WITH IP $arris_cmts ##########\n\n";
while (1) {
	if ($pingchoice eq 'a') {
		foreach $ipv6addresses(@ipv6addresses) {
			print @pingresult = $telnet->cmd("ping ipv6 $ipv6addresses");
			$combinedresult = "@pingresult[0 .. 3]";
			push @results, $combinedresult;
			
		}
		foreach $ipv4addresses(@ipv4addresses) {
			print @pingresult = $telnet->cmd("ping $ipv4addresses");
			$combinedresult = "@pingresult[0 .. 4]";
			push @results, $combinedresult;
		}
	}
	if ($pingchoice eq '6') {
		foreach $ipv6addresses(@ipv6addresses) {
			print @pingresult = $telnet->cmd("ping ipv6 $ipv6addresses");
			$combinedresult = "@pingresult[0 .. 3]";
			push @results, $combinedresult;
			
		}
	}
	if ($pingchoice eq '4') {
		foreach $ipv4addresses(@ipv4addresses) {
			print @pingresult = $telnet->cmd("ping $ipv4addresses");
			$combinedresult = "@pingresult[0 .. 4]";
			push @results, $combinedresult;
		}
	}
	

	print "\033[2J";    #clear the screen
	print "\033[0;0H"; #jump to 0,0
	foreach $results (@results) {	
		if ((index $results, $failphrase) > int("-1")) {
			push @failures, $results;
		}
	}
	print "\n\n\n\n";
	print "BELOW ARE THE FAILURES\n\n\n";
	print @failures;
	print "\n\n\nABOVE ARE THE FAILURES\n\n\n\n";
	print "Would you like to repeat pinging these same modems on cable-mac $cableMac\n\n(enter y or n): ";
	$var = <STDIN>;
	chomp $var;
	print "\033[2J";    #clear the screen
	print "\033[0;0H"; #jump to 0,0
	if ($var eq 'n') {
		last;
	} 
	print "\nYou have chosen to continue pinging cable modems\n\n\n\n\n";
	
}
print "\nYou have chosen to stop pinging cable modems\n\n";
