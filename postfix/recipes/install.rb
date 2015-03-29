postfix_pkgs = value_for_platform(
  'default' => ['postfix', 'opendkim', 'php5-cli']
)

postfix_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end
