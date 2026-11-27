{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  nodejs_24,
}:

# Cloudflare's `cf` CLI from npm; nixpkgs' `cloudflare-cli` is a different tool (`cfcli`).
# The npm tarball ships a prebuilt bundle and no lockfile, so package-lock.json is generated here:
#   npm pack cf@<version>, drop devDependencies and scripts from its package.json,
#   then `npm install --package-lock-only --ignore-scripts --min-release-age=0`.
# cf is an exempt tool (docs/adr/0003-seven-day-cooldown.md): it tracks the latest release, dependencies included.
buildNpmPackage (finalAttrs: {
  pname = "cf";
  version = "1.0.0-rc.6";

  src = fetchurl {
    url = "https://registry.npmjs.org/cf/-/cf-${finalAttrs.version}.tgz";
    hash = "sha512-w/L+DmEPrcOVJ9TrqtVJiZ2htnx+/fctGlDMrUZhuuEJSxayfc9QuEk2k3yaeXHPZIF5srovQLFxwB3YfVuwig==";
  };
  sourceRoot = "package";

  nodejs = nodejs_24;
  npmDepsHash = "sha256-MmdpAb5HrAfh8wlXvaYzAICp7bTKc1drK4RLpP+NtyA=";

  # Only the runtime dependencies are installed; the bundle in dist/ is already built.
  # postPatch also runs in fetchNpmDeps, which has no jq on PATH.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .scripts)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  meta = {
    description = "Cloudflare's official CLI for the Cloudflare API and Workers projects";
    homepage = "https://github.com/cloudflare/cf";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "cf";
  };
})
