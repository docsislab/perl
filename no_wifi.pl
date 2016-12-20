use Net::Telnet::Cisco;
use Net::Telnet;
use Data::Validate::IP qw(is_ipv4 is_ipv6);
use Socket6;
use Net::SNMP;
use Data::Dumper;
use Term::ReadKey;

print "What is your TACACS username: ";
my $username = <STDIN>;
chomp $username;
print "What is your TACACS password: ";
ReadMode('noecho');
my $password = ReadLine(0);
ReadMode('restore');
print "\n";

@cisco_cmts = qw(
	172.31.240.3
	172.31.240.81
	172.31.240.87
);

@arris_cmts = qw(
	172.31.240.5
	172.31.240.94
	172.31.240.95
);

##create telnet session
foreach $arris_cmts (sort @arris_cmts)
	{

print "\n";
print "########## OUTPUT FOR CMTS WITH IP $arris_cmts ##########\n";
print "\n";

$telnet = new Net::Telnet (	Input_log => "arris_input.log",
							Output_log => "arris_output.log",
                      		Prompt => '/[\$%#>] $/',
							Timeout => 30);
$telnet->open("$arris_cmts");
$line = $telnet->lastline;
print $line;
$telnet->login($username, $password);
$telnet->dump_log('arris_dump.log');
$telnet->cmd('terminal length 0');
@sysDescr = $telnet->cmd("scm system-description");
map {$_ = $_} (@sysDescr);
print "\n";

Arris_DG1660A_No_Wifi();
Motorola_SBG900_No_Wifi();
Netgear_C3000100NAS_No_Wifi();
Netgear_C3700100NAS_No_Wifi();
Netgear_CG3000D_No_Wifi();
Netgear_CG3000DV2_No_Wifi();
SMC_SMCD3GN2BIZ_No_Wifi();
Technicolor_TC8715D_No_Wifi();
Ubee_DDW3652_No_Wifi();
Zoom_5350_No_Wifi();
SMC_SMCD3GN_RES_No_Wifi();
Netgear_C6300BD_No_Wifi();
Linksys_WCG200_No_Wifi();
#Netgear_CG814CMR_No_Wifi();

$telnet->close();
};

$i = 1;
##create telnet session
foreach $cisco_cmts (sort @cisco_cmts) {

print "\n";
print "########## OUTPUT FOR CMTS WITH IP $cisco_cmts ##########\n";
print "\n";

$telnet = Net::Telnet::Cisco->new(Host => "$cisco_cmts", 
#									Input_log => "cisco_input_$i.log",
#									Output_log => "cisco_output_$i.log",
									Timeout => 60);
$telnet->login($username, $password);
$telnet->cmd('terminal length 0');
++$i;

my @scm = grep /([0-9A-Fa-f]){4}\.([0-9A-Fa-f]){4}\.([0-9A-Fa-f]){4}/, $telnet->cmd('show cable modem');
map {$_ = $_} (@scm);
foreach $scm(@scm) {
	@fields = split / /, $scm;
	$mac = $fields[0];
	@sysDescrs = grep /([0-9A-Fa-f]){4}\.([0-9A-Fa-f]){4}\.([0-9A-Fa-f]){4}/, $telnet->cmd("show cable modem $mac sysDescr community walkme");
	push @sysDescr, @sysDescrs;
}

Arris_DG1660A_No_Wifi();
Motorola_SBG900_No_Wifi();
Netgear_C3000100NAS_No_Wifi();
Netgear_C3700100NAS_No_Wifi();
Netgear_CG3000D_No_Wifi();
Netgear_CG3000DV2_No_Wifi();
SMC_SMCD3GN2BIZ_No_Wifi();
Technicolor_TC8715D_No_Wifi();
Ubee_DDW3652_No_Wifi();
Zoom_5350_No_Wifi();
SMC_SMCD3GN_RES_No_Wifi();
Netgear_C6300BD_No_Wifi();
Linksys_WCG200_No_Wifi();
Netgear_CG814CMR_No_Wifi();

$telnet->close();

$num_of_shutoffs = scalar @ModelDG1660A + scalar @ModelSBG900 + scalar @ModelC3000100NAS + scalar @ModelC3700100NAS + scalar @ModelCG3000D + scalar @ModelCG3000DV2 + scalar @ModelSMCD3GN2BIZ + scalar @ModelTC8715D + scalar @ModelDDW3652 + scalar @Model5350 + scalar @ModelC6300BD + scalar @ModelSMCD3GNRES + scalar @ModelWCG200 + scalar @ModelCG814CMR;
print "\n";
print "Wifi was shutoff on $num_of_shutoffs devices";
push @num_of_shutoffs, $num_of_shutoffs;

undef @sysDescr;

};

$total = $num_of_shutoffs[0] + $num_of_shutoffs[1];
print "\n";
print "Wifi was shutoff on a total of $total device(s)\n\n";

## subroutine to shutoff the Arris DG1660A wifi
sub Arris_DG1660A_No_Wifi {

	# Define the OIDs and Values needed to disable Wifi
	my $oid1 = "1.3.6.1.4.1.4115.1.20.1.1.3.12.0";
	my $oid1_off_value = "2";
	my $oid2 = "1.3.6.1.4.1.4115.1.20.1.1.3.50.10.0";
	my $oid2_off_value = "2";
	@ModelDG1660A = grep {$_ =~ "DG1660A"} @sysDescr;
	if (scalar @ModelDG1660A > 0) {
	print scalar(grep $_, @ModelDG1660A), " qty of Arris DG1660A Wireless Devices\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
	foreach (@ModelDG1660A){
		snmp_session();
		

		# Get the Current Value of all OID's responsible for Wifi
		my $result1 = $session->get_request($oid1);
		my $result2 = $session->get_request($oid2);

		print "-------------------------------------------------------------------------";
		print "\n";
		# Print 1st OID's current Value / Then set the 1st OID value to turn off Wifi / Then get the 1st OIDs value again / Then print the new value of 1st OID
		print "OID $oid1 Value was: $result1->{$oid1}\n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID $oid1 Value is now: $result1->{$oid1}\n";
		print "\n";

		# Print 2nd OID's current Value / Then set the 2nd OID value to turn off Wifi / Then get the 2nd OID value again / Then print the new value of 2nd OID
		print "OID $oid2 Value was: $result2->{$oid2}\n";
		$request2 = $session->set_request($oid2, INTEGER, +$oid2_off_value);
		$result2 = $session->get_request($oid2);
		print "OID $oid2 Value is now: $result2->{$oid2}\n";
		
		$session->close;
		
		print "-------------------------------------------------------------------------";
		print "\n";
		print "\n";
		}
	print "\n";
	print "\n";
	}}

## subroutine to shutoff the Motorola SBG900 wifi
sub Motorola_SBG900_No_Wifi	{
	
# Define the OIDs and Values needed to disable Wifi
	my $oid1 = "1.3.6.1.4.1.1166.1.19.51.1.2.2.0";
	my $oid1_off_value = "2";
	@ModelSBG900 = grep {$_ =~ "SBG900"} @sysDescr;
	if (scalar @ModelSBG900 > 0) {
	print scalar(grep $_, @ModelSBG900), " qty of Motorola SBG900 Wireless Devices\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
	foreach (@ModelSBG900){
		snmp_session();
		

# Get the Current Value of all OID's responsible for Wifi
		my $result1 = $session->get_request($oid1);

		print "-------------------------------------------------------------------------";
		print "\n";
# Print 1st OID's current Value / Then set the 1st OID value to turn off Wifi / Then get the 1st OIDs value again / Then print the new value of 1st OID
		print "OID $oid1 Value was:  $result1->{$oid1} \n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID $oid1 Value is now: $result1->{$oid1}\n";
		print "\n";
		
		$session->close;
		
		print "-------------------------------------------------------------------------";
		print "\n";
		print "\n";
		}
	print "\n";
	print "\n";
	}}

## subroutine to shutoff the Netgear C3000-100NAS wifi	
sub Netgear_C3000100NAS_No_Wifi	{

# Define the OIDs and Values needed to disable Wifi
	$oid1 = "1.3.6.1.4.1.4413.2.2.2.1.18.1.1.2.1.1.32";
	$oid1_off_value = "1";
	$oid2 = "1.3.6.1.4.1.4413.2.2.2.1.18.1.1.1.0";
	$oid2_off_value = "1";
	@ModelC3000100NAS = grep {$_ =~ "C3000-100NAS"} @sysDescr;
	if (scalar @ModelC3000100NAS > 0) {
	print scalar(grep $_, @ModelC3000100NAS), " qty of Netgear C3000-100NAS Wireless Devices\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
#	print @ModelC3000100NAS;
	print "\n";
	foreach (@ModelC3000100NAS){
		snmp_session();
	

# Get the Current Value of all OID's responsible for Wifi
		my $result1 = $session->get_request($oid1);
		my $result2 = $session->get_request($oid2);

		print "-------------------------------------------------------------------------";
		print "\n";
# Print 1st OID's current Value / Then set the 1st OID value to turn off Wifi / Then get the 1st OIDs value again / Then print the new value of 1st OID
		print "OID omitted  Value was: $result1->{$oid1}\n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID omitted Value is now: $result1->{$oid1}\n";
		print "\n";

# Print 2nd OID's current Value / Then set the 2nd OID value to turn off Wifi / Then get the 2nd OID value again / Then print the new value of 2nd OID
		print "OID $oid2 Value was: $result2->{$oid2}\n";
		$request2 = $session->set_request($oid2, INTEGER, +$oid2_off_value);
		$result2 = $session->get_request($oid2);
		print "OID $oid2 Value is now: $result2->{$oid2}\n";
		
		$session->close;
		
		print "-------------------------------------------------------------------------";
		print "\n";
		print "\n";
		}
	print "\n";
	print "\n";
	}}

## subroutine to shutoff the NetgearC3700-100NAS wifi
sub Netgear_C3700100NAS_No_Wifi	{

# Define the OIDs and Values needed to disable Wifi
	$oid1 = "1.3.6.1.4.1.4413.2.2.2.1.18.1.1.2.1.1.32";
	$oid1_off_value = "1";
	$oid2 = "1.3.6.1.4.1.4413.2.2.2.1.18.1.1.2.1.1.112";
	$oid2_off_value = "1";
	$oid3 = "1.3.6.1.4.1.4413.2.2.2.1.18.1.1.1.0";
	$oid_apply_value = "1";
	@ModelC3700100NAS = grep {$_ =~ "C3700-100NAS"} @sysDescr;
	if (scalar @ModelC3700100NAS > 0) {
	print scalar(grep $_, @ModelC3700100NAS), " qty of Netgear C3700-100NAS Wireless Devices\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
#	print @ModelC3700100NAS;
	print "\n";
	foreach (@ModelC3700100NAS){
		snmp_session();
	

# Get the Current Value of all OID's responsible for Wifi
		my $result1 = $session->get_request($oid1);
		my $result2 = $session->get_request($oid2);

		print "-------------------------------------------------------------------------";
		print "\n";
# Print 1st OID's current Value / Then set the 1st OID value to turn off Wifi / Then get the 1st OIDs value again / Then print the new value of 1st OID
		print "OID $oid1 Value was: $result1->{$oid1}\n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID $oid1 Value is now: $result1->{$oid1}\n";
		print "\n";

# Print 2nd OID's current Value / Then set the 2nd OID value to turn off Wifi / Then get the 2nd OID value again / Then print the new value of 2nd OID
		print "OID $oid2 Value was: $result2->{$oid2}\n";
		$request2 = $session->set_request($oid2, INTEGER, +$oid2_off_value);
		$result2 = $session->get_request($oid2);
		print "OID $oid2 Value is now: $result2->{$oid2}\n";

# Apply all OID values that were just previously set
		$request3 = $session->set_request($oid3, INTEGER, +$oid_apply_value);
		
		$session->close;
		
		print "-------------------------------------------------------------------------";
		print "\n";
		print "\n";
		}
	print "\n";
	print "\n";
	}}
	
## subroutine to shutoff the Netgear CG3000D wifi
sub Netgear_CG3000D_No_Wifi	{

# Define the OIDs and Values needed to disable Wifi
	$oid1 = "1.3.6.1.4.1.4526.3.1.1.4.2.0";
	$oid1_off_value = "2";

	@ModelCG3000D = grep {$_ =~ "CG3000D"} @sysDescr;
	if (scalar @ModelCG3000D > 0) {
	print scalar(grep $_, @ModelCG3000D), " qty of Netgear CG3000D Wireless Devices\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
#	print @ModelCG3000D;
	print "\n";
    foreach (@ModelCG3000D){
	    snmp_session();
		

# Get the Current Value of all OID's responsible for Wifi
		my $result1 = $session->get_request($oid1);

		print "-------------------------------------------------------------------------";
		print "\n";
# Print 1st OID's current Value / Then set the 1st OID value to turn off Wifi / Then get the 1st OIDs value again / Then print the new value of 1st OID
		print "OID $oid1 Value was: $result1->{$oid1}\n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID $oid1 Value is now: $result1->{$oid1}\n";
		print "\n";
		
		$session->close;
		
		print "-------------------------------------------------------------------------";
		print "\n";
		print "\n";
		}
	print "\n";
	print "\n";
	}}

## subroutine to shutoff the Netgear CG3000DV2 wifi	
sub Netgear_CG3000DV2_No_Wifi {

# Define the OIDs and Values needed to disable Wifi
	$oid1 = "1.3.6.1.4.1.4526.3.1.1.4.2.0";
	$oid1_off_value = "2";
	@ModelCG3000DV2 = grep {$_ =~ "CG3000DV2"} @sysDescr;
	if (scalar @ModelCG3000DV2 > 0) {
	print scalar(grep $_, @ModelCG3000DV2), " qty of Netgear CG3000DV2 Wireless Devices\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
#	print @ModelCG3000DV2;
	print "\n";
	foreach (@ModelCG3000DV2){
		snmp_session();
		

# Get the Current Value of all OID's responsible for Wifi
		$result1 = $session->get_request($oid1);

		print "-------------------------------------------------------------------------";
		print "\n";
# Print 1st OID's current Value / Then set the 1st OID value to turn off Wifi / Then get the 1st OIDs value again / Then print the new value of 1st OID
		print "OID $oid1 Value was: $result1->{$oid1}\n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID $oid1 Value is now: $result1->{$oid1}\n";
		print "\n";
		
		$session->close;
		
		print "-------------------------------------------------------------------------";
		print "\n";
		print "\n";
		}
	print "\n";
	print "\n";
	}}
	
## subroutine to shutoff the SMC SMCD3GN2BIZ wifi
sub SMC_SMCD3GN2BIZ_No_Wifi	{

# Define the OIDs and Values needed to disable Wifi
	$oid1 = "1.3.6.1.4.1.202.62.1.0";
	$oid1_off_value = "2";

	@ModelSMCD3GN2BIZ = grep {$_ =~ "SMCD3GN2-BIZ"} @sysDescr;
	if (scalar @ModelSMCD3GN2BIZ > 0) {
	print scalar(grep $_, @ModelSMCD3GN2BIZ), " qty of SMC SMCD3GN2-BIZ Wireless Devices\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
#	print @ModelSMCD3GN2BIZ;
	print "\n";
	foreach (@ModelSMCD3GN2BIZ){
		snmp_session();
		

# Get the Current Value of all OID's responsible for Wifi
		$result1 = $session->get_request($oid1);

		print "-------------------------------------------------------------------------";
		print "\n";
# Print 1st OID's current Value / Then set the 1st OID value to turn off Wifi / Then get the 1st OIDs value again / Then print the new value of 1st OID
		print "OID $oid1 Value was: $result1->{$oid1}\n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID $oid1 Value is now: $result1->{$oid1}\n";
		print "\n";
		
		$session->close;
		
		print "-------------------------------------------------------------------------";
		print "\n";
		print "\n";
		}
	print "\n";
	print "\n";
	}}

## subroutine to shutoff the Technicolor TC8715D wifi
sub Technicolor_TC8715D_No_Wifi	{

# Define the OIDs and Values needed to disable Wifi
	$oid1 = "1.3.6.1.4.1.4413.2.2.2.1.18.1.1.2.1.1.10001";
	$oid1_off_value = "1";
	$oid2 = "1.3.6.1.4.1.4413.2.2.2.1.18.1.1.2.1.1.10101";
	$oid2_off_value = "1";
	$oid3 = "1.3.6.1.4.1.4413.2.2.2.1.18.1.1.1.0";
	$oid_apply_value = "1";

	@ModelTC8715D = grep {$_ =~ "TC8715D"} @sysDescr;
	if (scalar @ModelTC8715D > 0) {
	print scalar(grep $_, @ModelTC8715D), " qty of Technicolor TC8715D Wireless Devices\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
#	print @ModelTC8715D;
	print "\n";
	foreach (@ModelTC8715D){
		snmp_session();
		

# Get the Current Value of all OID's responsible for Wifi
		$result1 = $session->get_request($oid1);
		$result2 = $session->get_request($oid2);

		print "-------------------------------------------------------------------------";
		print "\n";
# Print 1st OID's current Value / Then set the 1st OID value to turn off Wifi / Then get the 1st OIDs value again / Then print the new value of 1st OID
		print "OID $oid1 Value was: $result1->{$oid1}\n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID $oid1 Value is now: $result1->{$oid1}\n";
		print "\n";

# Print 2nd OID's current Value / Then set the 2nd OID value to turn off Wifi / Then get the 2nd OID value again / Then print the new value of 2nd OID
		print "OID $oid2 Value was: $result2->{$oid2}\n";
		$request2 = $session->set_request($oid2, INTEGER, +$oid2_off_value);
		$result2 = $session->get_request($oid2);
		print "OID $oid2 Value is now: $result2->{$oid2}\n";

# Apply all OID values that were just previously set
		$request3 = $session->set_request($oid3, INTEGER, +$oid_apply_value);
		
		$session->close;
		
		print "-------------------------------------------------------------------------";
		print "\n";
		print "\n";
		}
	print "\n";
	print "\n";
	}}

## subroutine to shutoff the Ubee DDW3652 wifi	
sub Ubee_DDW3652_No_Wifi {

# Define the OIDs and Values needed to disable Wifi
	$oid1 = "1.3.6.1.4.1.4684.38.2.2.2.1.18.1.1.2.1.1.32";
	$oid1_off_value = "0";
	$oid2 = "1.3.6.1.4.1.4684.38.2.2.2.1.18.1.1.1.0";
	$oid2_off_value = "1";

	@ModelDDW3652 = grep {$_ =~ "DDW3652"} @sysDescr;
	if (scalar @ModelDDW3652 > 0) {
	print scalar(grep $_, @ModelDDW3652), " qty of Ubee DDW3652 Wireless Devices\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
#	print @ModelDDW3652;
	print "\n";
	foreach (@ModelDDW3652)	{
		snmp_session();
		

# Get the Current Value of all OID's responsible for Wifi
		$result1 = $session->get_request($oid1);
		$result2 = $session->get_request($oid2);

		print "-------------------------------------------------------------------------";
		print "\n";
# Print 1st OID's current Value / Then set the 1st OID value to turn off Wifi / Then get the 1st OIDs value again / Then print the new value of 1st OID
		print "OID $oid1 Value was: $result1->{$oid1}\n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID $oid1 Value is now: $result1->{$oid1}\n";
		print "\n";

# Print 2nd OID's current Value / Then set the 2nd OID value to turn off Wifi / Then get the 2nd OID value again / Then print the new value of 2nd OID
		print "OID $oid2 Value was: $result2->{$oid2}\n";
		$request2 = $session->set_request($oid2, INTEGER, +$oid2_off_value);
		$result2 = $session->get_request($oid2);
		print "OID $oid2 Value is now: $result2->{$oid2}\n";
		
		$session->close;
		
		print "-------------------------------------------------------------------------";
		print "\n";
		print "\n";
		}
	print "\n";
	print "\n";
	}}

## subroutine to shutoff the Zoom 5350 wifi		
sub Zoom_5350_No_Wifi {

# Define the OIDs and Values needed to disable Wifi
	$oid1 = "1.3.6.1.4.1.4413.2.2.2.1.5.1.1.0";
	$oid1_off_value = "0";
	$oid2 = "1.3.6.1.4.1.4413.2.2.2.1.5.100.0";
	$oid2_off_value = "1";

	@Model5350 = grep {$_ =~ "5350"} @sysDescr;
	if (scalar @Model5350 > 0) {
	print scalar(grep $_, @Model5350), " qty of Zoom 5350 Wireless Devices\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
#	print @Model5350;
	print "\n";
	foreach (@Model5350) {
		snmp_session();
	
# Get the Current Value of all OID's responsible for Wifi
		$result1 = $session->get_request($oid1);
		$result2 = $session->get_request($oid2);

		print "-------------------------------------------------------------------------";
		print "\n";
# Print 1st OID's current Value / Then set the 1st OID value to turn off Wifi / Then get the 1st OIDs value again / Then print the new value of 1st OID
		print "OID $oid1 Value was: $result1->{$oid1}\n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID $oid1 Value is now: $result1->{$oid1}\n";
		print "\n";

# Print 2nd OID's current Value / Then set the 2nd OID value to turn off Wifi / Then get the 2nd OID value again / Then print the new value of 2nd OID
		print "OID $oid2 Value was: $result2->{$oid2}\n";
		$request2 = $session->set_request($oid2, INTEGER, +$oid2_off_value);
		$result2 = $session->get_request($oid2);
		print "OID $oid2 Value is now: $result2->{$oid2}\n";
		
		$session->close;
		
		print "-------------------------------------------------------------------------";
		print "\n";
		print "\n";
		}
	print "\n";
	print "\n";
	}}

## subroutine to shutoff the Netgear C6300BD wifi
sub Netgear_C6300BD_No_Wifi	{

# Define the OIDs and Values needed to disable Wifi
	$oid1 = "1.3.6.1.4.1.4526.3.1.1.4.2.0";
	$oid1_off_value = "2";

	@ModelC6300BD = grep {$_ =~ "C6300BD"} @sysDescr;
	if (scalar @ModelC6300BD > 0) {
	print scalar(grep $_, @ModelC6300BD), " qty of SMC C6300BD Wireless Devices\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
#	print @ModelC6300BD;
	print "\n";
	foreach (@ModelC6300BD){
		snmp_session();

# Get the Current Value of all OID's responsible for Wifi
		$result1 = $session->get_request($oid1);

		print "-------------------------------------------------------------------------";
		print "\n";
# Print 1st OID's current Value / Then set the 1st OID value to turn off Wifi / Then get the 1st OIDs value again / Then print the new value of 1st OID
		print "OID $oid1 Value was: $result1->{$oid1}\n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID $oid1 Value is now: $result1->{$oid1}\n";
		print "\n";
		
		$session->close;
		
		print "-------------------------------------------------------------------------";
		print "\n";
		print "\n";
		}
	print "\n";
	print "\n";
	}}

## subroutine to shutoff the SMC_SMCD3GN_RES_No_Wifi wifi
sub SMC_SMCD3GN_RES_No_Wifi	{

# Define the OIDs and Values needed to disable Wifi
	$oid1 = "1.3.6.1.4.1.202.62.1.0";
	$oid1_off_value = "2";

	@ModelSMCD3GNRES = grep {$_ =~ "SMCD3GN-RES"} @sysDescr;
	if (scalar @ModelSMCD3GNRES > 0) {
	print scalar(grep $_, @ModelSMCD3GNRES), " qty of SMC SMCD3GN-RES Wireless Devices\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
#	print @ModelSMCD3GN_RES;
	print "\n";
	foreach (@ModelSMCD3GNRES){
		snmp_session();

# Get the Current Value of all OID's responsible for Wifi
		$result1 = $session->get_request($oid1);

		print "-------------------------------------------------------------------------";
		print "\n";
# Print 1st OID's current Value / Then set the 1st OID value to turn off Wifi / Then get the 1st OIDs value again / Then print the new value of 1st OID
		print "OID $oid1 Value was: $result1->{$oid1}\n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID $oid1 Value is now: $result1->{$oid1}\n";
		print "\n";
		
		$session->close;
		
		print "-------------------------------------------------------------------------";
		print "\n";
		print "\n";
		}
	print "\n";
	print "\n";
	}}

## subroutine to shutoff the Linksys WCG200 wifi		
sub Linksys_WCG200_No_Wifi {

# Define the OIDs and Values needed to disable Wifi
	$oid1 = "1.3.6.1.4.1.4413.2.2.2.1.5.1.1.0";
	$oid1_off_value = "1";
	$oid2 = "1.3.6.1.4.1.4413.2.2.2.1.5.100.0";
	$oid2_off_value = "1";

	@ModelWCG200 = grep {$_ =~ "WCG200>>"} @sysDescr;
	if (scalar @ModelWCG200 > 0) {
	print scalar(grep $_, @ModelWCG200), " qty of Linksys WCG200 Wireless Devices\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
#	print @ModelWCG200;
	print "\n";
	foreach (@ModelWCG200) {
		snmp_session();

# Get the Current Value of all OID's responsible for Wifi
		$result1 = $session->get_request($oid1);
		$result2 = $session->get_request($oid2);

		print "-------------------------------------------------------------------------";
		print "\n";
# Print 1st OID's current Value / Then set the 1st OID value to turn off Wifi / Then get the 1st OIDs value again / Then print the new value of 1st OID
		print "OID $oid1 Value was: $result1->{$oid1}\n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID $oid1 Value is now: $result1->{$oid1}\n";
		print "\n";

# Print 2nd OID's current Value / Then set the 2nd OID value to turn off Wifi / Then get the 2nd OID value again / Then print the new value of 2nd OID
		print "OID $oid2 Value was: $result2->{$oid2}\n";
		$request2 = $session->set_request($oid2, INTEGER, +$oid2_off_value);
		$result2 = $session->get_request($oid2);
		print "OID $oid2 Value is now: $result2->{$oid2}\n";
		
		$session->close;
		
		print "-------------------------------------------------------------------------";
		print "\n";
		print "\n";
		}
	print "\n";
	print "\n";
	}}

sub Netgear_CG814CMR_No_Wifi {

# Define the OIDs and Values needed to disable Wifi
	my $oid1 = "1.3.6.1.4.1.4413.2.2.2.1.5.1.1.0";
	my $oid1_off_value = "1";
	my $oid2 = "1.3.6.1.4.1.4413.2.2.2.1.5.100.0";
	my $oid2_off_value = "1";

	@ModelCG814CMR = grep {$_ =~ "CG814CMR"} @sysDescr;
	if (scalar @ModelCG814CMR > 0) {
	print scalar(grep $_, @ModelCG814CMR), " qty of Netgear CG814CMR Wireless Devices\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
#	print @ModelCG814CMR;
	print "\n";
	foreach (@ModelCG814CMR) {
		snmp_session();

# Get the Current Value of all OID's responsible for Wifi
		my $result1 = $session->get_request($oid1);
		my $result2 = $session->get_request($oid2);

		print "-------------------------------------------------------------------------";
		print "\n";
# Print 1st OID's current Value / Then set the 1st OID value to turn off Wifi / Then get the 1st OIDs value again / Then print the new value of 1st OID
		print "OID $oid1 Value was: $result1->{$oid1}\n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID $oid1 Value is now: $result1->{$oid1}\n";
		print "\n";

# Print 2nd OID's current Value / Then set the 2nd OID value to turn off Wifi / Then get the 2nd OID value again / Then print the new value of 2nd OID
		print "OID $oid2 Value was: $result2->{$oid2}\n";
		$request2 = $session->set_request($oid2, INTEGER, +$oid2_off_value);
		$result2 = $session->get_request($oid2);
		print "OID $oid2 Value is now: $result2->{$oid2}\n";
		
		$session->close;
		
		print "-------------------------------------------------------------------------";
		print "\n";
		print "\n";
		}
	print "\n";
	print "\n";
	}}

sub snmp_session {
		my ($cableInterface, $IP, $MAC) = split /\s+/, $_;
		print "IP Address: ", $IP, "     MAC Address: ";
		print $MAC, "\n";
		if (is_ipv4($IP)){
			($session,$error) = Net::SNMP->session(Hostname => $IP,
													Community => 'ch@rt3rl@b');
			} else {
			($session,$error) = Net::SNMP->session(Hostname => $IP,
													Community => 'ch@rt3rl@b',
													Domain => 'UDP/ipv6',
													Port => '161');
}}
=pod
sub 2_4ghz_oid {
		print "OID $oid1 Value was: $result1->{$oid1}\n";
		$request1 = $session->set_request($oid1, INTEGER, +$oid1_off_value);
		$result1 = $session->get_request($oid1);
		print "OID $oid1 Value is now: $result1->{$oid1}\n";
}
=cut
