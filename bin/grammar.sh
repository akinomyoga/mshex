#!/usr/bin/env bash

#set -- lightnucl.tex

awk '
  function replace(reg, rep, _, old) {
    old = $0;
    $0 = gensub(reg, rep, "g", $0);
    return $0 != old;
  }

  BEGIN {
    nalign = 0;
    ncite = 1;
    neqref = 1;
    mode = "text";
  }
  /\\begin\{align\*?\}/ { mode = "align"; }
  /\\end\{align\*?\}/ {
    mode = "text";
    print "$y=f(" nalign++ ")$";
    next;
  }

  mode == "inline" {
    if (sub(/^[^$]*\$/, "$x$"))
      mode = "text";
  }

  mode == "text" {
    gsub(/\$[^$]+\$/, "行内数式");
    if (sub(/[[:space:]]*\$[^$]*$/, "")) {
      mode = "inline";
      if ($0 == "") next;
    }
    gsub(/行内数式/, "$x$");

    if ($0 != "") {
      # \textit{...}
      $0 = gensub(/\\textit\{([^{}]*)\}/, "\\1", "g", $0);

      # \cite{...}
      old = $0;
      $0 = gensub(/\\cite\{([^{}]*)\}/, "[" ncite "]", "g", $0);
      if ($0 != old) ncite++;

      # \eqref{...}
      old = $0;
      $0 = gensub(/\\eqref\{([^{}]*)\}/, "(" neqref ")", "g", $0);
      if ($0 != old) neqref++;

      # \ref{...}
      $0 = gensub(/\\ref\{([^{}]*)\}/, "I A", "g", $0);

      gsub(/~/, " ", $0);
      gsub(/--/, "-", $0);
      gsub(/\\@/, "", $0);

      gsub(/%.*/, "", $0);
      if ($0 == "") next;
    }

    print;
  }
' "$1"
