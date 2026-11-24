# Pure helpers for the capture-settings, settings-diff and apply-settings apps.
# The apps evaluate this file with `nix eval --impure --expr` at run time; no
# host configuration imports it, so `rig switch` never applies settings.
#
# Settings files hold one nix-plist-manager option tree
# (`{ applications.systemSettings... = ...; }`), with user and system options
# side by side; nix-plist-manager's applyScript splits them again.
{ lib }:

let
  inherit (lib)
    concatStringsSep
    filter
    hasPrefix
    isAttrs
    mapAttrs
    mapAttrsToList
    recursiveUpdate
    splitString
    ;

  # Option paths under `prefix`, or `prefix` itself.
  covers = prefix: path: path == prefix || hasPrefix "${prefix}." path;

  # Drop every subtree whose dotted path is covered by an ignored prefix, and
  # any attrset left empty by that.
  strip =
    ignored:
    let
      go =
        path: tree:
        lib.filterAttrs (_: value: value != { }) (
          lib.filterAttrs (name: _: !(lib.any (prefix: covers prefix (join path name)) ignored)) (
            mapAttrs (name: value: if isAttrs value then go (join path name) value else value) tree
          )
        );
      join = path: name: if path == "" then name else "${path}.${name}";
    in
    go "";

  # Keep only the settings whose dotted path starts with `only` (a string
  # prefix, as nix-plist-manager's own --only).
  select =
    only:
    let
      go =
        path: tree:
        lib.filterAttrs (_: value: value != { }) (
          lib.mapAttrs (
            name: value:
            let
              here = if path == "" then name else "${path}.${name}";
            in
            if hasPrefix only here then
              value
            else if isAttrs value && hasPrefix here only then
              go here value
            else
              { }
          ) tree
        );
    in
    if only == "" then lib.id else go "";

  # `settings/ignore.txt`: one option-path prefix per line, `#` comments.
  readIgnore =
    file:
    filter (line: line != "") (
      map (line: lib.trim (lib.head (splitString "#" line))) (splitString "\n" (builtins.readFile file))
    );

  importIfExists = file: if builtins.pathExists file then import file else { };

  # Leaves as { "a.b.c" = value; }, for the diff.
  flatten =
    let
      go =
        path: tree:
        lib.concatLists (
          mapAttrsToList (
            name: value:
            let
              here = if path == "" then name else "${path}.${name}";
            in
            if isAttrs value then go here value else [ (lib.nameValuePair here value) ]
          ) tree
        );
    in
    tree: lib.listToAttrs (go "" tree);

  show = value: lib.generators.toPretty { multiline = false; } value;
in
rec {
  inherit strip select readIgnore;

  # The settings the repo wants on `host`: shared.nix, then the host's file.
  wanted =
    { settingsDir, host }:
    recursiveUpdate (importIfExists "${settingsDir}/shared.nix") (
      importIfExists "${settingsDir}/${host}/system.nix"
    );

  # Turn the `{ user = ...; system = ...; }` output of nix-plist-manager's
  # `current` into one tree without the ignored paths, rendered as Nix.
  capture =
    { raw, ignoreFile }:
    let
      scopes = import raw;
      tree = recursiveUpdate (scopes.user or { }) (scopes.system or { });
    in
    ''
      # Captured from this Mac by `nix run .#capture-settings`; edits here are
      # overwritten by the next capture. Put settings both Macs share in
      # ../shared.nix and paths that should never be captured in ../ignore.txt.
      ${lib.generators.toPretty { } (strip (readIgnore ignoreFile) tree)}
    '';

  # What differs between the repo and this Mac, one line per setting.
  diff =
    {
      settingsDir,
      host,
      raw,
      ignoreFile,
    }:
    let
      scopes = import raw;
      mac = flatten (
        strip (readIgnore ignoreFile) (recursiveUpdate (scopes.user or { }) (scopes.system or { }))
      );
      repo = flatten (wanted {
        inherit settingsDir host;
      });
      paths = lib.unique (lib.attrNames mac ++ lib.attrNames repo);
      line =
        path:
        if !(repo ? ${path}) then
          "+ ${path} = ${show mac.${path}}    (on this Mac, not in the repo)"
        else if !(mac ? ${path}) then
          "- ${path} = ${show repo.${path}}    (in the repo, at the macOS default or unread here)"
        else if repo.${path} != mac.${path} then
          "~ ${path}: repo ${show repo.${path}}, this Mac ${show mac.${path}}"
        else
          null;
    in
    concatStringsSep "\n" (filter (l: l != null) (map line (lib.sort (a: b: a < b) paths)));

  # The shell script that applies the repo's settings (optionally only those
  # under `only`) through nix-plist-manager.
  applyScript =
    {
      npm,
      settingsDir,
      host,
      only ? "",
    }:
    npm.lib.applyScript (
      select only (wanted {
        inherit settingsDir host;
      })
    );
}
