{ vars ? {} }:

let
  username  = if vars ? username then vars.username else builtins.getEnv "USER";
  defaultConfigPath  =  vars.syncthingPath or "/home/${username}";
in {
  ROUTER_HOST = "openwrt.local";
  TARGET = "mvebu/cortexa9";
  PROFILE = "linksys_wrt3200acm";
  CUSTOM_PACKAGES_FILE = "${defaultConfigPath}/Private/Notes/wrt3200acm_pkgs.txt";
  EXCLUDE_PACKAGES_FILE = "${defaultConfigPath}/Private/Notes/wrt3200acm_exclude.txt";
}
