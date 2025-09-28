{ vars ? {} }:

let
  username  = if vars ? username then vars.username else builtins.getEnv "USER";
  defaultConfigPath  =  vars.syncthingPath or "/home/${username}";
in {
  ROUTER_HOST = "openwrt.home.arpa";
  TARGET = "mediatek/filogic";
  PROFILE = "glinet_gl-mt6000";
  FILES = "./files/etc/uci-defaults/00-noop";
  CUSTOM_PACKAGES_FILE = "${defaultConfigPath}/Notes/OpenWRT/flint2_pkgs.out";
  EXCLUDE_PACKAGES_FILE = "${defaultConfigPath}/Notes/OpenWRT/flint2_exclude.out";
}
