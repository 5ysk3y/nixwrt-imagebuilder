# 🔧 nixwrt-imagebuilder

A lightweight, Nix-based utility for building customized OpenWRT images — specifically tuned for the Linksys WRT3200ACM (but adaptable to other targets with minor tweaks).

---

## 🚀 Features

- 🔍 **Version Detection**  
  Automatically checks your router's current OpenWRT version and compares it to the latest official release on [openwrt.org](https://downloads.openwrt.org/releases).

- 🏗️ **Automated Image Generation**   
  If a new release is available, it will:
  - Fetch the matching image builder
  - Apply custom **inclusions/exclusions** from defined package lists
  - Build a ready-to-flash image tailored for your router

- 📦 **Custom Package Management**  
  Use your own package lists to easily define what packages should be included or removed from the image using environment variables:
  - `CUSTOM_PACKAGES_FILE`
  - `EXCLUDE_PACKAGES_FILE`

- 🧪 **DevShell Convenience**  
  Comes with a `nix develop` shell environment that sets everything up and kicks off the build with a single command.

---

## 📂 Project Goals

This project exists as part of my journey to:

- Learn and explore **Nix Flakes** in real-world contexts
- Simplify the process of **rebuilding OpenWRT images**
- Create a more reproducible workflow for managing OpenWRT on my devices

While functional, this utility is experimental and evolving — use at your own discretion.

---

## 📋 To-Do / Roadmap

- [ ] ⚙️ Add support for dynamic router profiles and targets
- [ ] ✅ Implement validation for target/profile compatibility
- [ ] 🧠 Cache and reuse parsed profile data between releases
- [ ] 🛠️ Improve/expand `nix run`-style CLI with flags for overriding additional build parameters
- [ ] 🌐 Add versioning awareness to avoid unnecessary rebuilds
- [ ] 🧾 Optional support for OpenWRT config seed files (`.config`)

---

## 🧭 Related Work

If you're looking for a more complete and generalized solution, I highly recommend [astro/nix-openwrt-imagebuilder](https://github.com/astro/nix-openwrt-imagebuilder).  
That project is an excellent, well-established tool that integrates OpenWRT image customization deeply with Nix.

This repository is not a competitor — rather, it is a personal exploration of similar principles with a focus on simplicity and router-specific workflows.

---

## 🔧 Requirements

- **Nix** with Flake support enabled
- Internet connection for fetching OpenWRT release metadata
- Basic understanding of OpenWRT and router flashing processes

---

## 📌 Usage

**This can be ran in two ways:**

### Direct Clone

1. Clone the repo:
   ```bash
   git clone https://github.com/YOUR_USER/nix-wrt3200acm-imagebuilder
   cd nix-wrt3200acm-imagebuilder
   ```
   
2. Configure your variables in `config.nix` (all of these can be overriden by passing as environment variables too):
   ```bash
    ROUTER_HOST = "openwrt.local"; # Your existing OpenWRT host
    TARGET = "mvebu/cortexa9"; # The target device type
    PROFILE = "linksys_wrt3200acm"; # The default profile to use
    CUSTOM_PACKAGES_FILE = "/home/user/pkgs.txt"; # A space/line separated list of packages to include
    EXCLUDE_PACKAGES_FILE = "/home/user/exclude.txt"; # A space/line separated list of packages to exclude
   ```
   
   Note that, by default, these variables will pull from public variables defined in my main [nixos-config](https://github.com/5ysk3y/nixos-config) repository, so expect to get errors with them unless you override the values or happen to use the exact same folder structure as me.

3. Launch the dev environment and start the build:
    ```bash
    nix develop
    CUSTOM_PACKAGES_FILE=/home/someOtherUser/mypkgs.txt ./build.sh
    ```

### Using `nix-run`
    
1. Simply, from a terminal, run:
    ``` bash
    ROUTER_HOST=192.168.1.1 nix run github:5ysk3y/nixwrt-imagebuilder
    
    ## To forcefully run the latest builder
    nix run github:5ysk3y/nixwrt-imagebuilder -- --force
    ```
    
2. Flash the image to your router (manual step — follow OpenWRT’s guide).

---

## ⚠️ Disclaimer

This tool indiscriminently builds OpenWRT images for the target device/profile defined in the build script. Before using any generated image:
- Make sure you understand what you're flashing and why.
- Understand that flashing your router is your own responsibility.
- It is entirely possible to brick your device using images supplied by this tool if you dont know what you're doing. You’ve been warned.

## 📬 Contributions

Pull requests are welcome — especially if you're interested in adapting the flake to support other routers or making the configuration fully dynamic.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).
