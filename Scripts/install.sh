up

echo ":: Checking for local custom_packages.lst file"
CUSTOM_PACKAGES_PATH="../custom_packages.lst"
if [ -f "$CUSTOM_PACKAGES_PATH" ]; then
  echo "  => Setting file attribute to local custom_packages.lst"
  chmod u+r "$CUSTOM_PACKAGES_PATH"
else
  echo "  => Local custom_packages.lst not found. Downloading from remote."
  CUSTOM_PACKAGES_PATH="./custom_packages.lst"
  curl -o "$CUSTOM_PACKAGES_PATH" https://raw.githubusercontent.com/Da4ndo/HyDa4/HyDa4/custom_packages.lst
  if [ $? -eq 0 ]; then
    echo "  => Successfully downloaded custom_packages.lst. Setting file attribute."
    chmod u+r "$CUSTOM_PACKAGES_PATH"
  else
    echo -e "\033[31mError:\033[0m Failed to download custom_packages.lst."
    exit 1
  fi
fi

echo ":: Starting package installation from custom_packages.lst"
while IFS= read -r package || [ -n "$package" ]; do
  if [[ $package =~ ^# ]] || [[ -z $package ]]; then
    echo "  => Skipping empty line or comment"
  else
    echo ":: Installing $package"
    if $aurhelper -S --noconfirm $package; then
      echo "  => Successfully installed $package"
    else
      echo -e "\033[31mError:\033[0m Failed to install $package."
      exit 1
    fi
  fi
done < "$CUSTOM_PACKAGES_PATH"
echo ":: Package installation completed successfully"


echo ":: Attempting to install Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
if [ $? -eq 0 ]; then
  echo "  => Rust installation script downloaded and executed successfully."
else
  echo -e "\033[31mError:\033[0m Failed to download or execute Rust installation script."
  exit 1
fi

echo ":: Setting Rust to nightly build..."
rustup default nightly
if [ $? -eq 0 ]; then
  echo "  => Rust set to nightly build successfully."
else
  echo -e "\033[31mError:\033[0m Failed to set Rust to nightly build."
  exit 1
fi

echo ":: Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
if [ $? -eq 0 ]; then
  echo "  => NVM installation script downloaded and executed successfully."
else
  echo -e "\033[31mError:\033[0m Failed to download or execute NVM installation script."
  exit 1
fi

echo ":: Installing Bun..."
curl -fsSL https://bun.sh/install | bash
if [ $? -eq 0 ]; then
  echo "  => Bun installation script downloaded and executed successfully."
else
  echo -e "\033[31mError:\033[0m Failed to download or execute Bun installation script."
  exit 1
fi

echo ":: Sourcing .zshrc to ensure environment variables are up to date..."
source ~/.zshrc
if [ $? -eq 0 ]; then
  echo "  => .zshrc sourced successfully."
else
  echo -e "\033[31mError:\033[0m Failed to source .zshrc."
  exit 1
fi

echo ":: Installing latest Node version using NVM..."
nvm install node
if [ $? -eq 0 ]; then
  echo "  => Node installed successfully."
else
  echo -e "\033[31mError:\033[0m Failed to install Node."
  exit 1
fi
