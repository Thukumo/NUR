{
  nethack,
  fetchpatch,
  nkf,
  lib,
}:

nethack.overrideAttrs (oldAttrs: {
  pname = "jnethack";
  # NixpkgsのNetHackもなんか3.6.7なので耐えてる
  patches = [
    (fetchpatch {
      url = "https://ftp.jaist.ac.jp/pub/sourceforge.jp/jnethack/78334/jnethack-3.6.7-0.1.diff.gz";
      hash = "sha256-0Uom1uBnpi6dQx1ZGiv83t7ttCzts2CQkX5wSbATZ50=";
    })
  ];

  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ nkf ];

  # https://github.com/NixOS/nixpkgs/blob/3f879eca34191600e57e24e8cbd95cc2a25fa87e/pkgs/by-name/ne/nethack/function-parameters.patch
  postPatch = (oldAttrs.postPatch or "") + ''
    find ./ -type f -exec nkf --overwrite -e -Lu {} +

    substituteInPlace include/system.h \
      --replace "void (*)()" "void (*)(int)" \
      --replace "int (*)()" "int (*)(int)" \
      --replace "E void srand48();" "E void srand48(long);" \
      --replace "E void sleep();" "E void sleep(unsigned);" \
      --replace "E unsigned sleep();" "unsigned sleep(unsigned);" \

    substituteInPlace include/winX.h \
      --replace "E void (*input_func)();" "E void (*input_func)(Widget, XEvent *, String *, Cardinal *);"

    sed -i '/extern XFontStruct \*WindowFontStruct/c\struct Widget;\nextern XFontStruct *WindowFontStruct(struct Widget *);' include/xwindow.h
    sed -i '/extern Font WindowFont/c\extern Font WindowFont(struct Widget *);' include/xwindow.h
  '';
  postInstall = lib.replaceStrings [ "nethack" ] [ "jnethack" ] oldAttrs.postInstall;
})
