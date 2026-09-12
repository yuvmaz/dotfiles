; extends
;; Adds string captures (covers Python docstrings, which Tree-sitter parses
;; as (string) nodes, not comments). Enables as/is selects and ]S/[S jumps
;; from lua/plugins/textobjects.lua.
(string) @string.outer
(string
  (string_content) @string.inner)
