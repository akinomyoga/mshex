#%# -*- mode:sh -*-

#%m function_from_get (
%name%.__set() {
  local varname="$1" ; shift
  local return=
  %name%.__get "$@"
  eval "$varname='$return'"
}
%name%() {
  local return=
  %name%.__get "$@"
  echo "$return"
}
#%)
#%x function_from_get.r/%name%/mwg.String.Uppercase/
#%x function_from_get.r/%name%/mwg.String.Lowercase/
#%x function_from_get.r/%name%/mwg.Char.ToCharCode/
#%x function_from_get.r/%name%/mwg.Char.ToHexCode/
#%x function_from_get.r/%name%/mwg.String.HexEncode/
#%x function_from_get.r/%name%/mwg.String.Base64Encode/
