; extends

; Go HTML templates (.tmpl / gohtmltmpl) are parsed by the `gotmpl` parser,
; which treats everything outside {{ }} as plain `text`. Inject the html parser
; into those text regions so the surrounding markup is highlighted too.
; `injection.combined` parses all text chunks as one html document, so tags
; opened before a {{ }} action still match their closing tag after it.
((text) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined))
