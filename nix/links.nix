{
  config,
  lib,
  ...
}:
let
  configRoot = ../config;
  dotfilesConfigDir = "${config.home.homeDirectory}/dotfiles/config";
  mkLink = relPath: config.lib.file.mkOutOfStoreSymlink "${dotfilesConfigDir}/${relPath}";

  # These applications write generated data alongside their configuration, so
  # keep their destination directories real and link only tracked files.
  fileLinkDirs = [
    "git"
    "herdr"
    "herdr-app"
    "opencode"
    "pi"
    "zed"
    "zsh"
  ];

  topLevelEntries = builtins.readDir configRoot;

  dirLinks = lib.concatMapAttrs (
    name: type:
    if type == "directory" && !(builtins.elem name fileLinkDirs) then
      { ${name}.source = mkLink name; }
    else
      { }
  ) topLevelEntries;

  topLevelFileLinks = lib.concatMapAttrs (
    name: type:
    if type != "directory" then
      { ${name}.source = mkLink name; }
    else
      { }
  ) topLevelEntries;

  perFileLinks = builtins.listToAttrs (
    lib.concatMap (
      dir:
      if builtins.hasAttr dir topLevelEntries then
        map (
          file:
          let
            relPath = lib.removePrefix "${toString configRoot}/" (toString file);
          in
          lib.nameValuePair relPath { source = mkLink relPath; }
        ) (lib.filesystem.listFilesRecursive (configRoot + "/${dir}"))
      else
        [ ]
    ) fileLinkDirs
  );
in
{
  # zsh doesn't follow XDG standards
  home.file.".zshenv".source = mkLink "zsh/.zshenv";

  xdg.configFile = dirLinks // topLevelFileLinks // perFileLinks;
}
