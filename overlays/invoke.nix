final: prev:
{
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pythonFinal: pythonPrev: {
      invoke = pythonPrev.invoke.overridePythonAttrs (oldAttrs: {
        version = "2.2.1";
        src = final.fetchPypi {
          inherit (oldAttrs) pname;
          version = "2.2.1";
          hash = "sha256:515bf49b4a48932b79b024590348da22f39c4942dff991ad1fb8b8baea1be707";
        };
      });
    })
  ];
}