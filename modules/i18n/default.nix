{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.i18n = {
    defaultLocale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      example = "nl_NL.UTF-8";
      description = ''
        The default locale.  It determines the language for program
        messages, the format for dates and times, sort order, and so on.
        It also determines the character set, such as UTF-8.
      '';
    };

    extraLocaleSettings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        LC_MESSAGES = "en_US.UTF-8";
        LC_TIME = "de_DE.UTF-8";
      };
      description = ''
        A set of additional system-wide locale settings other than
        `LANG` which can be configured with
        {option}`i18n.defaultLocale`.
      '';
    };

    supportedLocales = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = lib.unique (
        builtins.map
          (l: (lib.replaceStrings [ "utf8" "utf-8" "UTF8" ] [ "UTF-8" "UTF-8" "UTF-8" ] l) + "/UTF-8")
          (
            [
              "C.UTF-8"
              "en_US.UTF-8"
              config.i18n.defaultLocale
            ]
            ++ (lib.attrValues (lib.filterAttrs (n: v: n != "LANGUAGE") config.i18n.extraLocaleSettings))
          )
      );
      defaultText = lib.literalExpression ''
        lib.unique
          (builtins.map (l: (lib.replaceStrings [ "utf8" "utf-8" "UTF8" ] [ "UTF-8" "UTF-8" "UTF-8" ] l) + "/UTF-8") (
            [
              "C.UTF-8"
              "en_US.UTF-8"
              config.i18n.defaultLocale
            ] ++ (lib.attrValues (lib.filterAttrs (n: v: n != "LANGUAGE") config.i18n.extraLocaleSettings))
          ))
      '';
      example = [
        "en_US.UTF-8/UTF-8"
        "nl_NL.UTF-8/UTF-8"
        "nl_NL/ISO-8859-1"
      ];
      description = ''
        List of locales that the system should support.  The value
        `"all"` means that all locales supported by
        Glibc will be installed.  A full list of supported locales
        can be found at <https://sourceware.org/git/?p=glibc.git;a=blob;f=localedata/SUPPORTED>.
      '';
    };
  };

  config = {

    # Boot with a locale set as early as practical.
    boot.init.pid1.env = {
      LANG = config.i18n.defaultLocale;
      LOCALE_ARCHIVE = "/run/current-system/sw/lib/locale/locale-archive";
    }
    // config.i18n.extraLocaleSettings;

    # ‘/etc/locale.conf’ is used by systemd.
    environment.etc."locale.conf".text = ''
      LANG=${config.i18n.defaultLocale}
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (n: v: "${n}=${v}") config.i18n.extraLocaleSettings
      )}
    '';

    # Populate /etc/security/pam_env.conf.
    security.pam.environment = lib.mapAttrs (_: v: { override = v; }) (
      {
        LANG = config.i18n.defaultLocale;
        LOCALE_ARCHIVE = "/run/current-system/sw/lib/locale/locale-archive";
      }
      // config.i18n.extraLocaleSettings
    );
  };
}
