require "./src/yogurt.cr"

case ARGV[0_i32]?
when "version", "--version", "-v"
  STDOUT.puts <<-EOF
    Version:
      Yogurt.cr - Concept Password Generator
      _Version_ - #{Yogurt::VERSION} (2020.04.19)
    EOF
when "help", "--help", "-h"
  STDOUT.puts <<-EOF
    Usage: yogurt [command] [--] [arguments]
    Command:
      version, --version, -v  Display Version Information of Yogurt.cr
      help, --help, -h        Show this Yogurt: Concept Password Generator Help
    Options:
      --iterations, -i [info]  Specify the number of Iterations (E.g. 8192, 32768)
      --length, -l [info]      Specify the length of SecretKey (Between 10 To 50)
      --without-symbol         Generate SecretKey without Symbol (Reduce Security)
      --by-secure-id           Use SecureId instead of TitleName
      --create-secure-id       Switch to creating SecureId only
      --show-master-key        Display the inputted MasterKey value
      --user-name [info]       Create UserName (E.g. 8192:10, 16384:12, 32768:15)
                               (I.e. --user-name iterations:length)
      --pin-code [info]        Create Secure PIN Code (E.g. 16384, 32768)
                               (I.e. --pin-code iterations)
      --email-address [info]   Create Email Address (E.g. 16384:12:example.com)
                               (I.e. --email-address iterations:length:domain)
    EOF
else
  Yogurt::CommandLine.create Yogurt::Config.parse ARGV
end
