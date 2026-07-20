{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cmake,
  ninja,
  wayland,
  wayland-protocols,
  wayland-scanner,
  libdrm,
  libffi,
  libglvnd,
  libx11,
  libxcursor,
  libxkbcommon,
  libxrandr,
  libxinerama,
  libxi,
  freetype,
  fontconfig,
  makeDesktopItem,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "kakodemon";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "falbru";
    repo = "kakodemon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-P21YfuNuuSRJFey2kOijHwyh4BzQEeMGe6UV9lhJzSw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    wayland-scanner
    wayland-protocols
    pkg-config
  ];

  buildInputs = [
    wayland
    libdrm
    libxkbcommon
    libffi
    libx11
    libxrandr
    libxinerama
    libxcursor
    libxi
    freetype
    fontconfig
  ];

  patches = [
      ./001-include-fcfreetype.patch
  ];

  desktopItem = makeDesktopItem {
    name = "kakodemon";
    desktopName = "Kakodemon";
    comment = "An OpenGL-based GUI for Kakoune";
    exec = "kakod %f";
  };

  installPhase = ''
      mkdir -p $out/bin $out/share/applications
      install -D ./kakod $out/bin
      install -D ${finalAttrs.desktopItem}/share/applications/* $out/share/applications
  '';

  postFixup = ''
    patchelf \
      --add-rpath ${lib.makeLibraryPath [
        wayland
        libxkbcommon
        libglvnd
      ]} $out/bin/kakod
  '';

  cmakeBuildType = "Release";

  meta = {
    homepage = "https://github.com/falbru/kakodemon";
    description = "An OpenGL-based GUI for Kakoune";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "kakod";
    maintainers = with lib.maintainers; [ bartlomiejlitwin ];
  };
})
