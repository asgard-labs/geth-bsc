{ stdenv, autoPatchelfHook }:

stdenv.mkDerivation rec {
  name = "geth-bsc-${version}";
  version = "1.1.8";

  system = "x86_64-linux";

  src = builtins.fetchurl {
    url = "https://github.com/bnb-chain/bsc/releases/download/v${version}/geth_linux";
    sha256 = "0aiy5rkbh6wvm2dsvf4mf3lvxy17prlr7wyiz15kg0ibs6whx8vk";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    install -Dm755 -T $src $out/bin/geth
  '';

  meta.platforms = [ "x86_64-linux" ];
}
