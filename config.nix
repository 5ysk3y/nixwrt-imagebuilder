{ vars ? {} }:

let
  username  =  vars.username; #or builtins.getEnv "USER";
  defaultSyncthingPath  =  vars.syncthingPath; #or "/home/${username}/Syncthing";
in {
  ROUTER_HOST = "openwrt.local";
  TARGET = "mvebu/cortexa9";
  PROFILE = "linksys_wrt3200acm";
  CUSTOM_PACKAGES_FILE = "${defaultSyncthingPath}/Private/Notes/wrt3200acm_pkgs.txt";
  EXCLUDE_PACKAGES_FILE = "${defaultSyncthingPath}/Private/Notes/wrt3200acm_exclude.txt";
}
